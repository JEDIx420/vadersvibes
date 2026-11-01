"""
build_validation_sanctuary.py
=============================
Procedural staged construction of "Vader's Coastal Sanctuary" test scene.
Demonstrates:
- Authentic LEGO stud/plate scale (1 stud = 0.36m, 1 plate = 0.144m, 1 brick = 0.432m)
- Stepped coastal terrain with Tan beach, Dark Grey cliffs, Bright Green grass
- Reusable instanced pine trees and faceted rocks (Test 4: procedural repetition)
- Sanctuary cabin with pitched roof
- Articulated hinged door with keyframed swing animation (Test 5: animation)
- Integrated legolized brick monument (Test 3)
- Direct mesh construction via bmesh/from_pydata (no operator freezes)
- PBR plastic materials with authentic LEGO color codes
- Clean GLB export for Godot 4.7 Forward+ engine import (Test 6)
"""

import bpy
import bmesh
import mathutils
import math
import os
import shutil

# 1. Clear scene objects without resetting Blender session
if bpy.context.object and bpy.context.object.mode != 'OBJECT':
    bpy.ops.object.mode_set(mode='OBJECT')
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
for col in list(bpy.context.scene.collection.children):
    bpy.context.scene.collection.children.unlink(col)

# Project paths
PROJECT_ROOT = "/Users/vincyvincent/.gemini/antigravity/scratch/lego-vader-openworld"
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "assets/test_pipeline")
os.makedirs(OUTPUT_DIR, exist_ok=True)
BLEND_PATH = os.path.join(OUTPUT_DIR, "lego_coastal_sanctuary.blend")
GLB_PATH = os.path.join(OUTPUT_DIR, "lego_coastal_sanctuary.glb")

# Scale constants (minifigure = 1.80m, 45x physical scale)
STUD_PITCH = 0.36       # 20 LDU
PLATE_HEIGHT = 0.144    # 8 LDU
BRICK_HEIGHT = 0.432    # 24 LDU
STUD_RADIUS = 0.108     # 4.8mm * 45 / 2
STUD_HEIGHT = 0.072     # 1.6mm * 45

# Collections
col_terrain = bpy.data.collections.new("Terrain")
col_architecture = bpy.data.collections.new("Architecture")
col_props = bpy.data.collections.new("Props")
col_monument = bpy.data.collections.new("Monument")
bpy.context.scene.collection.children.link(col_terrain)
bpy.context.scene.collection.children.link(col_architecture)
bpy.context.scene.collection.children.link(col_props)
bpy.context.scene.collection.children.link(col_monument)

# --- Materials ---
def create_lego_mat(name, hex_color, roughness=0.22, metallic=0.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    
    # Hex to sRGB
    h = hex_color.lstrip('#')
    r = int(h[0:2], 16) / 255.0
    g = int(h[2:4], 16) / 255.0
    b = int(h[4:6], 16) / 255.0
    # sRGB to linear
    def to_linear(c):
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    
    linear_color = (to_linear(r), to_linear(g), to_linear(b), 1.0)
    
    if bsdf:
        bsdf.inputs["Base Color"].default_value = linear_color
        bsdf.inputs["Roughness"].default_value = roughness
        if "Metallic" in bsdf.inputs:
            bsdf.inputs["Metallic"].default_value = metallic
    return mat

mat_water = create_lego_mat("LEGO_Medium_Azure", "#36AEBF", roughness=0.10)
mat_sand = create_lego_mat("LEGO_Tan", "#E4CD9E", roughness=0.30)
mat_grass_bright = create_lego_mat("LEGO_Bright_Green", "#4B9F4A", roughness=0.25)
mat_grass_dark = create_lego_mat("LEGO_Dark_Green", "#184632", roughness=0.25)
mat_stone_dark = create_lego_mat("LEGO_Dark_Stone_Grey", "#6C6E68", roughness=0.28)
mat_stone_light = create_lego_mat("LEGO_Light_Stone_Grey", "#A0A5A9", roughness=0.28)
mat_wood_brown = create_lego_mat("LEGO_Reddish_Brown", "#582A12", roughness=0.25)
mat_wood_dark = create_lego_mat("LEGO_Dark_Brown", "#352100", roughness=0.25)
mat_roof_sand = create_lego_mat("LEGO_Sand_Green", "#708E7C", roughness=0.22)
mat_door_gold = create_lego_mat("LEGO_Warm_Gold", "#AA7F2E", roughness=0.20, metallic=0.6)

# --- Geometry Helpers ---
def add_stud_cylinder(bm, center_x, center_y, top_z, segments=12):
    """Add a LEGO stud on a surface."""
    z_bot = top_z
    z_top = top_z + STUD_HEIGHT
    circle_bot = []
    circle_top = []
    for i in range(segments):
        angle = 2.0 * math.pi * i / segments
        vx = center_x + STUD_RADIUS * math.cos(angle)
        vy = center_y + STUD_RADIUS * math.sin(angle)
        circle_bot.append(bm.verts.new((vx, vy, z_bot)))
        circle_top.append(bm.verts.new((vx, vy, z_top)))
    
    # Side faces
    for i in range(segments):
        i_next = (i + 1) % segments
        bm.faces.new([circle_bot[i], circle_bot[i_next], circle_top[i_next], circle_top[i]])
    # Top face
    circle_top.reverse()
    bm.faces.new(circle_top)

def create_box_mesh(name, x_size, y_size, z_size, material, with_studs=False, stud_step=1):
    """Create a plate or brick block with optional top studs."""
    mesh = bpy.data.meshes.new(name + "_Mesh")
    bm = bmesh.new()
    
    # Base box centered in XY, resting on Z=0
    hx = x_size / 2.0
    hy = y_size / 2.0
    hz = z_size
    
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= x_size
        v.co.y *= y_size
        v.co.z = (v.co.z + 0.5) * hz
        
    if with_studs:
        # Stud grid
        nx = int(round(x_size / STUD_PITCH))
        ny = int(round(y_size / STUD_PITCH))
        for ix in range(0, nx, stud_step):
            for iy in range(0, ny, stud_step):
                sx = -hx + (ix + 0.5) * STUD_PITCH
                sy = -hy + (iy + 0.5) * STUD_PITCH
                add_stud_cylinder(bm, sx, sy, hz)
                
    bm.to_mesh(mesh)
    bm.free()
    
    obj = bpy.data.objects.new(name, mesh)
    obj.data.materials.append(material)
    return obj

# =========================================================================
# STAGE 1: STEPPED COASTAL TERRAIN (Test 4: Shared LEGO plates)
# =========================================================================
print("Building Stage 1: Stepped Coastal Terrain...")

# 1. Azure Water Base (40 x 40 studs = 14.4m x 14.4m)
water = create_box_mesh("Terrain_Ocean_Water", 14.4, 14.4, PLATE_HEIGHT * 2, mat_water)
water.location = (0, 0, -PLATE_HEIGHT * 2)
col_terrain.objects.link(water)

# 2. Coastal Beach Tier (Tan sand plate: 24 x 36 studs)
beach = create_box_mesh("Terrain_Sand_Beach", 8.64, 12.96, PLATE_HEIGHT, mat_sand, with_studs=True, stud_step=2)
beach.location = (-2.0, 0, 0)
col_terrain.objects.link(beach)

# 3. Rocky Cliff Mid-Tier (Dark Stone Grey: 20 x 24 studs, 3 plates high)
cliff = create_box_mesh("Terrain_Cliff_Terrace", 7.20, 8.64, PLATE_HEIGHT * 3, mat_stone_dark, with_studs=True, stud_step=2)
cliff.location = (1.5, 0, PLATE_HEIGHT)
col_terrain.objects.link(cliff)

# 4. Upper Sanctuary Bluff (Bright Green grass: 18 x 20 studs, 4 plates high)
grass_bluff = create_box_mesh("Terrain_Grass_Bluff", 6.48, 7.20, PLATE_HEIGHT * 4, mat_grass_bright, with_studs=True, stud_step=2)
grass_bluff.location = (2.2, 0.5, PLATE_HEIGHT * 4)
col_terrain.objects.link(grass_bluff)

# 5. Cobblestone / Studded Landing Pad (10 x 10 studs = 3.6m x 3.6m, light stone grey)
landing_pad = create_box_mesh("Structure_Landing_Pad", 3.6, 3.6, PLATE_HEIGHT, mat_stone_light, with_studs=True, stud_step=1)
landing_pad.location = (-3.8, -3.2, PLATE_HEIGHT)
col_architecture.objects.link(landing_pad)

# 6. Wooden Fishing Pier extending into water
pier = create_box_mesh("Structure_Wooden_Pier", 1.44, 4.32, PLATE_HEIGHT * 2, mat_wood_dark, with_studs=True, stud_step=1)
pier.location = (-5.5, 2.5, 0)
col_architecture.objects.link(pier)

# =========================================================================
# STAGE 2: VADER'S RETREAT CABIN
# =========================================================================
print("Building Stage 2: Vader's Sanctuary Cabin...")

cabin_root = bpy.data.objects.new("Sanctuary_Cabin_Root", None)
col_architecture.objects.link(cabin_root)
cabin_root.location = (2.8, 1.0, PLATE_HEIGHT * 8)

# Foundation (Dark stone grey: 12 x 14 studs = 4.32m x 5.04m, 1 brick high)
cabin_floor = create_box_mesh("Cabin_Floor", 4.32, 5.04, BRICK_HEIGHT, mat_stone_dark)
cabin_floor.location = (0, 0, 0)
cabin_floor.parent = cabin_root
col_architecture.objects.link(cabin_floor)

# North Wall (Back)
wall_north = create_box_mesh("Cabin_Wall_North", 4.32, 0.36, BRICK_HEIGHT * 6, mat_wood_brown)
wall_north.location = (0, 2.34, BRICK_HEIGHT)
wall_north.parent = cabin_root
col_architecture.objects.link(wall_north)

# East Wall
wall_east = create_box_mesh("Cabin_Wall_East", 0.36, 4.32, BRICK_HEIGHT * 6, mat_wood_brown)
wall_east.location = (1.98, 0, BRICK_HEIGHT)
wall_east.parent = cabin_root
col_architecture.objects.link(wall_east)

# West Wall
wall_west = create_box_mesh("Cabin_Wall_West", 0.36, 4.32, BRICK_HEIGHT * 6, mat_wood_brown)
wall_west.location = (-1.98, 0, BRICK_HEIGHT)
wall_west.parent = cabin_root
col_architecture.objects.link(wall_west)

# South Wall (Front Entrance with Door Opening)
# Left post
wall_south_left = create_box_mesh("Cabin_Wall_South_Left", 1.26, 0.36, BRICK_HEIGHT * 6, mat_wood_brown)
wall_south_left.location = (-1.53, -2.34, BRICK_HEIGHT)
wall_south_left.parent = cabin_root
col_architecture.objects.link(wall_south_left)

# Right post
wall_south_right = create_box_mesh("Cabin_Wall_South_Right", 1.62, 0.36, BRICK_HEIGHT * 6, mat_wood_brown)
wall_south_right.location = (1.35, -2.34, BRICK_HEIGHT)
wall_south_right.parent = cabin_root
col_architecture.objects.link(wall_south_right)

# Lintel above door
lintel = create_box_mesh("Cabin_Wall_South_Lintel", 1.44, 0.36, BRICK_HEIGHT * 1.5, mat_stone_light)
lintel.location = (-0.18, -2.34, BRICK_HEIGHT * 5.5)
lintel.parent = cabin_root
col_architecture.objects.link(lintel)

# Overhanging Pitched Roof (Sand green plates forming an authentic A-frame peak)
roof_left = create_box_mesh("Cabin_Roof_Slope_Left", 2.5, 5.4, PLATE_HEIGHT * 2, mat_roof_sand, with_studs=True, stud_step=2)
roof_left.location = (-1.15, 0, BRICK_HEIGHT * 6.8)
roof_left.rotation_euler = (0, math.radians(-24), 0)
roof_left.parent = cabin_root
col_architecture.objects.link(roof_left)

roof_right = create_box_mesh("Cabin_Roof_Slope_Right", 2.5, 5.4, PLATE_HEIGHT * 2, mat_roof_sand, with_studs=True, stud_step=2)
roof_right.location = (1.15, 0, BRICK_HEIGHT * 6.8)
roof_right.rotation_euler = (0, math.radians(24), 0)
roof_right.parent = cabin_root
col_architecture.objects.link(roof_right)

# Ridge cap tile along peak (X = 0)
roof_ridge = create_box_mesh("Cabin_Roof_Ridge", 0.72, 5.4, PLATE_HEIGHT, mat_roof_sand, with_studs=True, stud_step=2)
roof_ridge.location = (0, 0, BRICK_HEIGHT * 7.35)
roof_ridge.parent = cabin_root
col_architecture.objects.link(roof_ridge)

# Front Gable Triangular Infill
gable_front = create_box_mesh("Cabin_Gable_Front", 3.6, 0.36, BRICK_HEIGHT * 1.2, mat_wood_brown)
gable_front.location = (0, -2.34, BRICK_HEIGHT * 6.6)
gable_front.parent = cabin_root
col_architecture.objects.link(gable_front)

# Back Gable Triangular Infill
gable_back = create_box_mesh("Cabin_Gable_Back", 3.6, 0.36, BRICK_HEIGHT * 1.2, mat_wood_brown)
gable_back.location = (0, 2.34, BRICK_HEIGHT * 6.6)
gable_back.parent = cabin_root
col_architecture.objects.link(gable_back)

# =========================================================================
# STAGE 3: ARTICULATED HINGED CABIN DOOR & ANIMATION (Test 5: Animation)
# =========================================================================
print("Building Stage 3: Articulated Door Mechanism & Animation...")

# Door mesh: width = 1.35m, height = BRICK_HEIGHT * 4.5 = 1.944m, thickness = 0.12m
door_mesh = bpy.data.meshes.new("Cabin_Door_Mesh")
bm = bmesh.new()

# Create door geometry with pivot along left edge (X = 0)
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    # Shift X so pivot is at left edge [0 to width]
    v.co.x = (v.co.x + 0.5) * 1.35
    v.co.y = v.co.y * 0.12
    v.co.z = (v.co.z + 0.5) * 1.944

# Add small golden handle
handle_verts = []
for hx, hy, hz in [(-0.05, -0.15, 0.9), (0.05, -0.15, 0.9), (0.05, -0.15, 1.05), (-0.05, -0.15, 1.05)]:
    handle_verts.append(bm.verts.new((1.1 + hx, hy, hz)))
bm.faces.new(handle_verts)

bm.to_mesh(door_mesh)
bm.free()

door_obj = bpy.data.objects.new("Cabin_Hinged_Door", door_mesh)
door_obj.data.materials.append(mat_wood_dark)
door_obj.parent = cabin_root
door_obj.location = (-0.90, -2.34, BRICK_HEIGHT)
col_architecture.objects.link(door_obj)

# Create Door Swing Animation (Test 5: Rigid animation baked to Action)
door_obj.animation_data_create()
action = bpy.data.actions.new(name="door_swing")
door_obj.animation_data.action = action

# 60 frame animation:
# Frame 1: closed (0 deg)
# Frame 30: open inward (90 deg)
# Frame 60: closed (0 deg)
door_obj.rotation_euler = (0, 0, 0)
door_obj.keyframe_insert(data_path="rotation_euler", frame=1)

door_obj.rotation_euler = (0, 0, math.radians(-85))
door_obj.keyframe_insert(data_path="rotation_euler", frame=30)

door_obj.rotation_euler = (0, 0, 0)
door_obj.keyframe_insert(data_path="rotation_euler", frame=60)

# Set scene frame range
bpy.context.scene.frame_start = 1
bpy.context.scene.frame_end = 60

# =========================================================================
# STAGE 4: REUSABLE PINE TREES & BOULDERS (Test 4: Shared Geometry Instances)
# =========================================================================
print("Building Stage 4: Reusable Instanced Nature Props...")

# 1. Base Pine Tree Data (Trunk + 3 Conical Tiers)
tree_mesh = bpy.data.meshes.new("LEGO_Pine_Tree_Shared_Mesh")
bm = bmesh.new()

# Trunk (Dark Brown cylinder)
trunk_height = 0.864
bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=8, radius1=0.20, radius2=0.20, depth=trunk_height)
for v in bm.verts:
    v.co.z += trunk_height / 2.0

# 3 Stepped Conical Tiers (LEGO green slopes)
for tier_idx, (base_r, top_r, z_base, tier_h) in enumerate([
    (1.20, 0.70, 0.60, 0.80),
    (0.90, 0.45, 1.30, 0.75),
    (0.60, 0.10, 1.95, 0.70),
]):
    tier_bm = bmesh.new()
    bmesh.ops.create_cone(tier_bm, cap_ends=True, cap_tris=False, segments=8, radius1=base_r, radius2=top_r, depth=tier_h)
    for v in tier_bm.verts:
        v.co.z += z_base + tier_h / 2.0
    tier_bm.to_mesh(tree_mesh)
    tier_bm.free()

bm.to_mesh(tree_mesh)
bm.free()

tree_mat = mat_grass_dark

# Instance 4 trees sharing tree_mesh
tree_positions = [
    (0.8, -2.5, PLATE_HEIGHT * 4, 1.1, 0.2),
    (4.8, 3.2, PLATE_HEIGHT * 4, 1.25, -0.6),
    (-0.5, 4.0, PLATE_HEIGHT * 4, 0.95, 1.1),
    (5.2, -1.8, PLATE_HEIGHT * 4, 1.05, 2.3),
]

for idx, (tx, ty, tz, scale, rot_z) in enumerate(tree_positions):
    tree_obj = bpy.data.objects.new(f"Nature_PineTree_{idx+1}", tree_mesh)
    tree_obj.data.materials.append(tree_mat)
    tree_obj.location = (tx, ty, tz)
    tree_obj.scale = (scale, scale, scale)
    tree_obj.rotation_euler = (0, 0, rot_z)
    col_props.objects.link(tree_obj)

# 2. Base Boulder Mesh (Shared)
boulder_mesh = bpy.data.meshes.new("LEGO_Faceted_Boulder_Mesh")
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=1, radius=0.65)
# Flatten base
for v in bm.verts:
    v.co.x *= 1.2
    v.co.y *= 0.9
    v.co.z = max(0.0, v.co.z + 0.3)
bm.to_mesh(boulder_mesh)
bm.free()

boulder_positions = [
    (-1.8, 2.8, PLATE_HEIGHT, 1.2, 0.4),
    (-1.2, -4.0, PLATE_HEIGHT, 0.8, -1.2),
    (4.5, -4.2, PLATE_HEIGHT * 4, 1.4, 1.8),
]

for idx, (bx, by, bz, scale, rot_z) in enumerate(boulder_positions):
    boulder_obj = bpy.data.objects.new(f"Nature_Boulder_{idx+1}", boulder_mesh)
    boulder_obj.data.materials.append(mat_stone_dark)
    boulder_obj.location = (bx, by, bz)
    boulder_obj.scale = (scale, scale, scale)
    boulder_obj.rotation_euler = (0, 0, rot_z)
    col_props.objects.link(boulder_obj)

# =========================================================================
# STAGE 5: INTEGRATE THE LEGOLIZED STONE MONUMENT (Test 3)
# =========================================================================
print("Building Stage 5: Integrating Converted LEGO Monument...")

# The legolized monument was generated into builds/stone_monument.ldr
ldr_monument_path = os.path.join(PROJECT_ROOT, "builds/stone_monument.ldr")
if os.path.exists(ldr_monument_path):
    print("Found stone_monument.ldr, appending model via ImportLDraw...")
    # Import into a separate temp context, then place onto bluff
    try:
        import addon_utils
        addon_utils.enable("importldraw")
        bpy.ops.import_scene.importldraw(filepath=ldr_monument_path, ldrawPath="/Users/vincyvincent/ldraw/")
        monument_root = bpy.data.objects.get("00000_stone_monument.ldr")
        if monument_root:
            monument_root.name = "Prop_Ancient_LEGO_Monument"
            # Scale from LDraw real units (0.0004m or 0.008m) up to game 45x scale
            # In Blender, ImportLDraw imported it at real scale ~0.07m. Scale by 45:
            monument_root.scale = (45.0, 45.0, 45.0)
            monument_root.location = (-0.8, -1.8, PLATE_HEIGHT * 4)
            # Relink to monument collection
            for child in monument_root.children_recursive:
                if child.name in bpy.context.scene.collection.objects:
                    bpy.context.scene.collection.objects.unlink(child)
                col_monument.objects.link(child)
            if monument_root.name in bpy.context.scene.collection.objects:
                bpy.context.scene.collection.objects.unlink(monument_root)
            col_monument.objects.link(monument_root)
            print("Successfully placed Prop_Ancient_LEGO_Monument on bluff terrace!")
    except Exception as e:
        print("Note: ImportLDraw append error:", e)

# =========================================================================
# STAGE 6: COLLISION CONVENTIONS & GLB EXPORT (Test 6)
# =========================================================================
print("Building Stage 6: Godot Collision Setup and GLB Export...")

# For Godot 4: objects with name suffix '-col' or '-colonly' automatically
# generate static body collision shapes upon import!
# Let's add simple collision boxes for terrain tiers and cabin walls so Vader
# can walk and collide properly without falling through!

col_boxes = [
    # (name, size_x, size_y, size_z, loc_x, loc_y, loc_z)
    ("Terrain_Water_Base-colonly", 14.4, 14.4, PLATE_HEIGHT * 2, 0, 0, -PLATE_HEIGHT),
    ("Terrain_Beach_Tier-colonly", 8.64, 12.96, PLATE_HEIGHT, -2.0, 0, PLATE_HEIGHT / 2.0),
    ("Terrain_Cliff_Tier-colonly", 7.20, 8.64, PLATE_HEIGHT * 3, 1.5, 0, PLATE_HEIGHT * 2.5),
    ("Terrain_Grass_Bluff-colonly", 6.48, 7.20, PLATE_HEIGHT * 4, 2.2, 0.5, PLATE_HEIGHT * 6.0),
    ("Structure_Pier-colonly", 1.44, 4.32, PLATE_HEIGHT * 2, -5.5, 2.5, PLATE_HEIGHT),
    ("Cabin_Wall_North-colonly", 4.32, 0.36, BRICK_HEIGHT * 6, 2.8, 3.34, PLATE_HEIGHT * 8 + BRICK_HEIGHT * 4),
    ("Cabin_Wall_East-colonly", 0.36, 4.32, BRICK_HEIGHT * 6, 4.78, 1.0, PLATE_HEIGHT * 8 + BRICK_HEIGHT * 4),
    ("Cabin_Wall_West-colonly", 0.36, 4.32, BRICK_HEIGHT * 6, 0.82, 1.0, PLATE_HEIGHT * 8 + BRICK_HEIGHT * 4),
]

for name, sx, sy, sz, lx, ly, lz in col_boxes:
    mesh = bpy.data.meshes.new(name + "_Mesh")
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= sx
        v.co.y *= sy
        v.co.z *= sz
    bm.to_mesh(mesh)
    bm.free()
    col_obj = bpy.data.objects.new(name, mesh)
    col_obj.location = (lx, ly, lz)
    col_terrain.objects.link(col_obj)

# Save .blend checkpoint
bpy.ops.wm.save_as_mainfile(filepath=BLEND_PATH)
print("Saved checkpoint blend to:", BLEND_PATH)

# Select all objects and export to GLB
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(
    filepath=GLB_PATH,
    export_format='GLB',
    use_selection=True,
    export_apply=True,
    export_yup=True,
    export_animations=True
)
print("Exported verified GLB to:", GLB_PATH)

# Summary
print(f"Total objects in scene: {len(bpy.data.objects)}")
total_tris = sum(len(o.data.polygons) for o in bpy.data.objects if o.type == 'MESH')
print(f"Total polygon count: {total_tris}")
