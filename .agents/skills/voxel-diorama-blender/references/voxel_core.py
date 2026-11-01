"""Voxel core: palette with proper sRGB->linear, epsilon-inset box(),
per-(group,palette,shade) batching, and one-shot mesh compile.

Proven scale: ~28k cells -> ~57 objects. Run:
    blender -b -t 8 -P build.py -- /path/to/output
"""
import bpy
import os
import sys
import json
import random
from collections import defaultdict

random.seed(82)
OUT = os.path.abspath(sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv
                      else os.path.dirname(__file__))
os.makedirs(OUT, exist_ok=True)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

# ~37 named hexes covering stone, foliage, water, cloth, skin, metal.
PALETTE = {
    "sand": "C9985D", "limestone": "E4CB93", "ivory": "F3E4BB",
    "ochre": "AA723E", "granite": "9A8F76", "shadow": "5D5146",
    "brick": "A95939", "tile": "BB6340", "tilelight": "D88954",
    "earth": "A67648", "soil": "624A38", "grass": "758749",
    "moss": "5E7541", "leaf": "426C43", "leaf2": "648744",
    "leaf3": "8C9F51", "leafdark": "2C503A", "wood": "69432D",
    "woodlight": "A07448", "water": "277D83", "water2": "328E92",
    "wave": "86B9AE", "saffron": "E9A02C", "red": "AA3D34",
    "indigo": "3E6379", "teal": "2A7D73", "cream": "E9D8AB",
    "pink": "CA7763", "gold": "CDA34A", "skin": "965F40",
    "skin2": "BB8154", "hair": "332D29", "elephant": "797E76",
    "tusk": "E7D6AD", "banana": "CEB547", "grain": "D1B371",
    "purple": "765B72",
}
MATS = {}


def lin(c):
    # Real sRGB -> linear transfer; skipping this muddies every shade.
    return c / 12.92 if c < 0.04045 else ((c + 0.055) / 1.055) ** 2.4


for key, h in PALETTE.items():
    for j in range(4):
        fac = [0.86, 0.95, 1.0, 1.07][j]
        rgb = [lin(min(1, int(h[i:i + 2], 16) / 255 * fac)) for i in (0, 2, 4)]
        m = bpy.data.materials.new(key + "_" + str(j))
        m.diffuse_color = (*rgb, 1)
        m.use_nodes = True
        p = m.node_tree.nodes.get("Principled BSDF")
        p.inputs["Base Color"].default_value = (*rgb, 1)
        p.inputs["Roughness"].default_value = (
            0.83 if key not in ("water", "water2", "wave") else 0.3)
        MATS[(key, j)] = m

BATCH = defaultdict(lambda: ([], []))
GROUP = "Land"
COUNTS = defaultdict(int)


def box(x, y, z, w, d, h, c, shade=None):
    if min(w, d, h) <= 0:
        return
    # Deterministic epsilon inset: kills coincident-face black patches.
    # Scales with block size; %17 jitter keeps neighbors off shared planes.
    eps = min(min(w, d, h) * 0.025, 0.0015 + (sum(COUNTS.values()) % 17) * 0.00009)
    x += eps; y += eps; z += eps
    w -= 2 * eps; d -= 2 * eps; h -= 2 * eps
    key = (GROUP, c, shade if shade is not None
           else random.choices(range(4), [1, 3, 7, 1])[0])
    v, f = BATCH[key]
    a = len(v)
    v.extend([(x, y, z), (x + w, y, z), (x + w, y + d, z), (x, y + d, z),
              (x, y, z + h), (x + w, y, z + h), (x + w, y + d, z + h),
              (x, y + d, z + h)])
    f.extend([tuple(a + i for i in face) for face in
              [(0, 3, 2, 1), (0, 1, 5, 4), (1, 2, 6, 5),
               (2, 3, 7, 6), (3, 0, 4, 7), (4, 5, 6, 7)]])
    COUNTS[GROUP] += 1


def compile_scene():
    for (group, c, shade), (v, f) in BATCH.items():
        coll = bpy.data.collections.get(group)
        if not coll:
            coll = bpy.data.collections.new(group)
            bpy.context.scene.collection.children.link(coll)
        me = bpy.data.meshes.new(group + " " + c)
        me.from_pydata(v, [], f)
        me.update()
        ob = bpy.data.objects.new(group + " " + c + str(shade), me)
        coll.objects.link(ob)
        me.materials.append(MATS[(c, shade)])
    print("BLOCKS", dict(COUNTS), "OBJECTS", len(bpy.data.objects), flush=True)
    with open(os.path.join(OUT, "scene_stats.json"), "w") as fh:
        json.dump({"blocks": dict(COUNTS),
                   "total_blocks": sum(COUNTS.values()),
                   "objects": len(bpy.data.objects)}, fh, indent=2)

# ... component functions (terrain/temple/market/trees/figures) call box()
# with GROUP set to their collection name; reseed per pass:
# random.seed(904) before the detail pass, random.seed(905) before polish.
# Finish with compile_scene() then cameras/lighting/render.
