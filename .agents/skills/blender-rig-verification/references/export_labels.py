"""Project real assembly positions into the rendered camera for web labels.

Per frame, each labeled component's anchor point is projected with
world_to_camera_view and stored as [x, 1-y, z>0] (CSS-style top-left origin,
visibility flag). The web player lerps anchors between frames and positions
HTML labels — labels never drift off their parts during scroll.
"""
import bpy
import sys
import pathlib
import json
from mathutils import Vector
from bpy_extras.object_utils import world_to_camera_view

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "blender"))
from sequence import apply  # noqa: E402 — choreography: pure fn of t

s = bpy.context.scene
s.render.resolution_x = 1280
s.render.resolution_y = 1000

# Pick stable anchor points: a specific vertex on a deforming mesh (located
# by nearest stored flat-position), the origin of rigid parts.
screen = bpy.data.objects["Display | continuous flexible panel"]
screen_vertex = min(
    range(len(screen.data.vertices)),
    key=lambda i: (screen.data.attributes["flat_position"].data[i].vector
                   - Vector((-13, 31, 0))).length)
link = next(o for o in bpy.data.objects
            if o.get("link_x") == 30 and o.get("link_half") == 0)
parts = {
    "display": screen,
    "battery": bpy.data.objects["Cell | upper pouch"],
    "optics": bpy.data.objects["Optics | internal barrel 0"],
    "link": link,
    "flex": bpy.data.objects["Flex | continuous interconnect 1"],
}

records = []
for frame in range(480):
    apply(frame / 479)
    anchors = {}
    for name, obj in parts.items():
        if name == "display":
            local = obj.data.vertices[screen_vertex].co
        elif name == "flex":
            local = obj.data.vertices[92].co
        else:
            local = Vector((0, 0, 0))
        p = world_to_camera_view(s, s.camera, obj.matrix_world @ local)
        anchors[name] = [round(p.x, 5), round(1 - p.y, 5), p.z > 0]
    records.append(anchors)

out = ROOT / "website" / "public" / "animation"
out.mkdir(parents=True, exist_ok=True)
(out / "anchors.json").write_text(json.dumps(records, separators=(",", ":")))
print("Exported component anchors for 480 authored camera positions.", flush=True)
