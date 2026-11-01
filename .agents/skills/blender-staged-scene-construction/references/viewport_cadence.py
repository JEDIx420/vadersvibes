"""Bounded live-orbit measurement of viewport draw callbacks — NOT fake FPS.

Records intervals between POST_PIXEL draw callbacks during a scripted
+/-10 degree orbit (2 s warmup, 20 s measurement), restores the view, and
writes viewport-cadence.json whose metric field honestly labels the result.
Observed on one Apple-silicon box, material preview, 2137x1222 region:
median 11.55 ms, p95 16.95 ms, p99 21.56 ms.
"""
import bpy
import time
import math
import json
import statistics
from pathlib import Path
from mathutils import Quaternion, Vector

ROOT = Path(__file__).resolve().parent
area = next(a for a in bpy.context.screen.areas if a.type == "VIEW_3D")
space = area.spaces.active
rv = space.region_3d
region = next(r for r in area.regions if r.type == "WINDOW")
original = (rv.view_rotation.copy(), rv.view_location.copy(),
            rv.view_distance, rv.view_perspective)
base = bpy.context.scene.camera.rotation_euler.to_quaternion()
rv.view_location = Vector((-3, 6, 45))
rv.view_distance = 147
rv.view_perspective = "PERSP"
rv.view_rotation = base
state = {"started": time.perf_counter(), "draws": []}


def draw():
    now = time.perf_counter()
    if now - state["started"] > 2:
        state["draws"].append(now)


handle = bpy.types.SpaceView3D.draw_handler_add(draw, (), "WINDOW", "POST_PIXEL")


def step():
    t = time.perf_counter() - state["started"]
    if t >= 22:
        bpy.types.SpaceView3D.draw_handler_remove(handle, "WINDOW")
        (rv.view_rotation, rv.view_location,
         rv.view_distance, rv.view_perspective) = original
        samples = [(b - a) * 1000 for a, b in zip(state["draws"], state["draws"][1:])]
        ordered = sorted(samples)

        def pct(p):
            return ordered[min(len(ordered) - 1, int((len(ordered) - 1) * p))] if ordered else None

        report = {
            "metric": ("Blender POST_PIXEL draw callback cadence during a bounded "
                       "+/-10 degree orbit. Not GPU-present frame time or a gameplay "
                       "FPS guarantee."),
            "hardware": "Apple-silicon workstation",
            "region_pixels": [region.width, region.height],
            "shading": space.shading.type,
            "observed_draws": len(state["draws"]),
            "warmup_seconds": 2,
            "measurement_seconds": 20,
            "median_interval_ms": statistics.median(samples) if samples else None,
            "p95_interval_ms": pct(0.95),
            "p99_interval_ms": pct(0.99),
            "mean_draws_per_second": 1000 / statistics.mean(samples) if samples else None,
        }
        (ROOT / "viewport-cadence.json").write_text(json.dumps(report, indent=2))
        area.tag_redraw()
        return None
    rv.view_rotation = Quaternion((0, 0, 1), 0.175 * math.sin(t * math.pi / 12)) @ base
    area.tag_redraw()
    return 1 / 60


bpy.app.timers.register(step, first_interval=0.05)
print("Started 22-second viewport orbit/cadence check; restores view automatically.")
