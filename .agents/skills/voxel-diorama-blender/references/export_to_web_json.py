"""Export the Blender generator to web-viewer JSON by REPLAY, not parsing.

The generator is the single source of truth: we truncate its source before
its final build-call line, exec the prefix (so every component function and
the palette exist), then monkey-patch box()/person() to capture records
instead of building meshes. Deterministic seeds mean the JSON matches the
rendered scene exactly — a captured export reproduced the committed viewer
JSON byte-for-byte.

Run with Blender's python or any python that can exec the generator:
    blender -b -P export_to_web_json.py -- /path/to/public/village.json
"""
import os
import sys
import json
from pathlib import Path

EXPORT_PATH = (Path(sys.argv[sys.argv.index("--") + 1]).resolve()
               if "--" in sys.argv else Path("work/village.json").resolve())
EXPORT_PATH.parent.mkdir(parents=True, exist_ok=True)

source = "/path/to/project/blender/build_scene.py"  # the generator
# The builder expects an output directory after '--'; keep scratch isolated.
sys.argv = [source, "--", str(EXPORT_PATH.parent)]
s = open(source).read()
s = s[: s.rindex("terrain();temple();")]  # strip the final build-call line
exec(s)  # noqa: S102 — replaying OUR deterministic generator

static = []
actors = []
capture = None


# Preserve the exact procedural palette and all architectural additions.
def box(x, y, z, w, d, h, c, shade=None):
    if min(w, d, h) <= 0:
        return
    j = shade if shade is not None else random.choices(range(4), [1, 3, 7, 1])[0]
    row = [round(v, 4) for v in (x, y, z, w, d, h)] + [c, j, GROUP]
    if capture is not None:
        capture.append(row)
    elif GROUP not in ("People clothing and belongings", "River",
                       "Waterfront ropes and planks"):
        # Fluid/overlay groups are re-implemented natively on the web.
        static.append(row)


base_person = person  # noqa: F821 — defined by the exec'd generator


def person(x, y, z=0, c="cream", pose="walk"):
    global capture
    if z > 0.2:  # riders etc. stay baked into their vehicle's static blocks
        return base_person(x, y, z, c, pose)
    capture = []
    base_person(x, y, z, c, pose)
    parts = capture
    capture = None
    for p in parts:  # recenter to the figure origin for web-side articulation
        p[0] -= x; p[1] -= y; p[2] -= z
    actors.append({"x": x, "y": y, "z": z, "parts": parts, "pose": pose})


# Same call order as the generator's stripped build-call line:
terrain(); temple(); tank(); market(); elephant(34, 53); cart(49, 54)  # noqa: F821
nature(); boat(30, 69); boat(69, 66); detail_pass(); polish_pass()  # noqa: F821

with open(EXPORT_PATH, "w") as f:
    json.dump({"palette": PALETTE, "blocks": static, "actors": actors},  # noqa: F821
              f, separators=(",", ":"))
print("EXPORTED", len(static), len(actors))

# Web side (three.js): convert Z-up -> Y-up, one InstancedMesh per
# (color, shade) bucket, palette hexes from the JSON, actors as articulated
# assemblies. Validate: positive dimensions on every block, all corners
# inside the enclosure, TS + production build green; record what was NOT
# interactively QA-tested.
