"""Direct mesh construction + per-stage checkpoint merging.

Why: bpy.ops mesh operators froze Blender at scale. Direct from_pydata
construction plus merging only the stage's NEW meshes (grouped by material)
kept a 295-object / ~7M-rendered-triangle scene fully responsive.
Usage pattern inside every numbered stage script:

    _before = set(scene.objects)          # snapshot at stage start
    ... build with box()/cone()/mesh() ...
    checkpoint('02b_towers')              # merge + save at stage end
"""
import bpy
import math
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent
scene = bpy.context.scene
BLEND_PATH = ROOT / "Scene.blend"


def mesh(name, verts, faces, material):
    me = bpy.data.meshes.new(name)
    me.from_pydata(verts, [], faces)
    me.update()
    ob = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(ob)
    if material:
        ob.data.materials.append(material)
    return ob


def box(name, loc, size, material=None, bevel=0.07):
    a, b, c = [t / 2 for t in size]
    v = [(dx * a, dy * b, dz * c) for dx, dy, dz in
         [(-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1),
          (-1, -1, 1), (1, -1, 1), (1, 1, 1), (-1, 1, 1)]]
    ob = mesh(name, v, [(0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4),
                        (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)], material)
    ob.location = loc
    if bevel:
        mod = ob.modifiers.new("Edge", "BEVEL")
        mod.width = bevel
        mod.segments = 2
    return ob


def cone(name, x, y, z, r1, r2, h, material=None, n=48):
    v = [(r * math.cos(i * math.tau / n), r * math.sin(i * math.tau / n), zz)
         for r, zz in [(r1, -h / 2), (r2, h / 2)] for i in range(n)]
    f = ([tuple(range(n - 1, -1, -1)), tuple(range(n, 2 * n))]
         + [(i, (i + 1) % n, (i + 1) % n + n, i + n) for i in range(n)])
    ob = mesh(name, v, f, material)
    ob.location = (x, y, z + h / 2)
    for p in ob.data.polygons:
        p.use_smooth = len(p.vertices) == 4
    return ob


def checkpoint(label):
    """Merge only this stage's new meshes, by material, without operator loops."""
    groups = defaultdict(list)
    bpy.context.view_layer.update()
    for ob in set(scene.objects) - _before:  # noqa: F821 — _before is stage-level
        if ob.type == "MESH" and len(ob.data.materials) == 1:
            groups[ob.data.materials[0]].append(ob)
    obsolete = []
    for material, obs in groups.items():
        verts, faces, smooth = [], [], []
        for ob in obs:
            offset = len(verts)
            matx = ob.matrix_world
            verts.extend([matx @ v.co for v in ob.data.vertices])
            faces.extend([tuple(offset + i for i in p.vertices) for p in ob.data.polygons])
            smooth.extend([p.use_smooth for p in ob.data.polygons])
        combined = mesh(label + " | " + material.name, verts, faces, material)
        for p, s in zip(combined.data.polygons, smooth):
            p.use_smooth = s
        obsolete.extend(obs)
    bpy.data.batch_remove(ids=obsolete)
    bpy.context.view_layer.update()
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_PATH))
    print(label, "saved;", len(scene.objects), "scene objects;",
          sum(len(o.data.polygons) for o in scene.objects if o.type == "MESH"),
          "polygons")
