"""Background-only Cycles review render; never runs in the live viewport.

Run from a shell (interactive Blender stays open and responsive):

    blender -b outputs/scene/Scene.blend --python outputs/scene/render_preview.py

FIXED thread count leaves cores for the interactive session; observed ~84 s
for a 1440x1800 128-sample frame on an Apple-silicon workstation.
"""
import bpy
from pathlib import Path

ROOT = Path(__file__).resolve().parent
scene = bpy.data.scenes["Your Scene Name"]
bpy.context.window.scene = scene
scene.render.engine = "CYCLES"
scene.cycles.samples = 128
scene.cycles.use_denoising = True
scene.cycles.adaptive_threshold = 0.035
scene.cycles.max_bounces = 6
scene.cycles.diffuse_bounces = 3
scene.cycles.glossy_bounces = 3
scene.render.threads_mode = "FIXED"
scene.render.threads = 6
scene.render.resolution_x = 1440
scene.render.resolution_y = 1800
scene.render.resolution_percentage = 100
scene.render.filepath = str(ROOT / "film-final.png")
scene.render.image_settings.file_format = "PNG"
scene.camera = bpy.data.objects["CAMERA • Cinematic portrait"]
bpy.ops.render.render(write_still=True)
