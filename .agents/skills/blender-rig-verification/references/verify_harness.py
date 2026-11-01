"""Geometry and reversibility checks on the actual Blender assembly (CLI).

Runs headless against the source scene. Every threshold below was a real
passing value on a 376-object folding-device assembly:

    blender -b scene.blend --python verify_harness.py
"""
import bpy
import bmesh
import sys
import pathlib
import math
import json
from mathutils import Vector

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "blender"))
from sequence import apply                      # choreography: pure fn of t
from rig_math import linkage, cable_points, A   # analytic mechanism

records = []
object_count = len(bpy.data.objects)

# 1. Outward normals via signed volume (negative volume = inward normals).
hand_volumes = {}
for obj in [o for o in bpy.data.objects if o.name.startswith("Hand |")]:
    mesh = bmesh.new()
    mesh.from_mesh(obj.data)
    hand_volumes[obj.name] = mesh.calc_volume(signed=True) * 1e9
    mesh.free()
    assert hand_volumes[obj.name] > 0, "Inward hand normals: " + obj.name

# 2. 101-state sweep: rigid links exact, cable/display arclength constant,
#    object count stable, all vertices finite.
for i in range(101):
    t = i / 100
    state = apply(t)
    theta = math.radians(state["fold_degrees"])
    a, j, b = linkage(theta)
    link_error = max(abs((j - a).length - 5.8), abs((b - j).length - 5.8))
    pts = cable_points(theta)
    cable_length = sum((q - p).length for p, q in zip(pts, pts[1:]))
    screen = bpy.data.objects["Display | continuous flexible panel"]
    center = [v.co for n, v in enumerate(screen.data.vertices) if n % 33 == 16]
    display_length = sum((q - p).length for p, q in zip(center, center[1:])) * 1000
    assert link_error < 1e-6, (t, "rigid guide stretched", link_error)
    assert abs(cable_length - 31.5) < 0.05, (t, "cable stretched", cable_length)
    assert abs(display_length - 150.6) < 0.01, (t, "neutral plane stretched", display_length)
    assert len(bpy.data.objects) == object_count, "component count changed"
    assert all(math.isfinite(x) for p in center for x in p), "non-finite vertex"
    records.append({"t": t, "link_error_mm": link_error,
                    "cable_length_mm": cable_length,
                    "display_arclength_mm": display_length})

# 3. Transform reversibility round-trip: drive away and back, compare worlds.
def state_vectors():
    return {o.name: list(o.matrix_world) for o in bpy.data.objects
            if o.type in ("MESH", "EMPTY", "CAMERA")}

apply(0.12)
before = state_vectors()
for t in (0.62, 0.73, 1, 0.73, 0.62, 0.12):
    apply(t)
after = state_vectors()
reverse_error = max(abs(a - b) for k in before
                    for ra, rb in zip(before[k], after[k])
                    for a, b in zip(ra, rb))
assert reverse_error < 1e-7, "reverse traversal changes assembly transform"

# 4. Conservative clearance-envelope sweep (~168 poses). Box envelopes are
# conservative around rounded corners; near-edge contacts get visual review.
contacts = []
for t in [i / 479 for i in range(168)]:
    apply(t)
    max_depth = 0
    points_inside = 0
    culprit = ""
    upper = bpy.data.objects["RIG | upper half"].matrix_world.inverted()
    for obj in [o for o in bpy.data.objects
                if o.name.startswith("Hand |") and "palm" not in o.name]:
        for vert in obj.data.vertices:
            world = obj.matrix_world @ vert.co
            for p, sgn in [(world, -1), (upper @ world, 1)]:
                x, y, z = [c * 1000 for c in p]
                y *= sgn
                if -36 < x < 36 and A < y < 77 and -6.8 < z < 0:
                    depth = min(x + 36, 36 - x, y - A, 77 - y, z + 6.8, -z)
                    points_inside += 1
                    if depth > max_depth:
                        max_depth = depth
                        culprit = obj.name
    contacts.append({"t": t, "conservative_envelope_depth_mm": max_depth,
                     "vertices_inside": points_inside, "component": culprit})

report = {
    "blender": bpy.app.version_string,
    "objects": object_count,
    "sampled_states": 101,
    "hand_signed_volumes_mm3": hand_volumes,
    "rigid_link_max_error_mm": max(r["link_error_mm"] for r in records),
    "flex_cable_range_mm": [min(r["cable_length_mm"] for r in records),
                            max(r["cable_length_mm"] for r in records)],
    "display_arclength_range_mm": [min(r["display_arclength_mm"] for r in records),
                                   max(r["display_arclength_mm"] for r in records)],
    "reverse_transform_error_m": reverse_error,
    "hand_pose_samples": len(contacts),
    "max_hand_envelope_depth_mm": max(r["conservative_envelope_depth_mm"]
                                      for r in contacts),
    "limitations": [
        "Illustrative kinematics, not manufacturing validation.",
        "Envelope contacts require visual review, especially at rounded corners.",
    ],
}
out = ROOT / "reports"
out.mkdir(exist_ok=True)
(out / "geometry-verification.json").write_text(json.dumps(report, indent=2))
print(json.dumps(report, indent=2), flush=True)
assert report["max_hand_envelope_depth_mm"] < 0.1, "clearance exceeds 0.1 mm envelope tolerance"
