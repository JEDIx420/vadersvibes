# LEGO & Blender Asset Integration Workflow Guide

## 1. Overview
This guide instructs developers and AI agents on how to construct, convert, inspect, and export authentic LEGO 3D assets into Godot 4.7 Forward+ for **LEGO Star Wars: A Vader's Peace**.

## 2. Mathematical Scale & Coordinate Agreement
To ensure assets fit seamlessly with the $1.80\text{ m}$ tall LEGO Darth Vader minifigure:
- **Minifigure Scale:** 1.80m ($45\times$ scale of real-world 40mm minifig).
- **1 Stud Pitch (20 LDU):** $0.36\text{ m}$.
- **1 Brick Height (24 LDU):** $0.432\text{ m}$.
- **1 Plate Height (8 LDU):** $0.144\text{ m}$.
- **Stud Cylinder:** Diameter $= 0.216\text{ m}$, Height $= 0.072\text{ m}$.
- **Blender Coordinate Convention:** $+Z$ is Up, $+Y$ is North.
- **Godot Coordinate Convention:** $+Y$ is Up, $-Z$ is Forward. 1 unit $= 1\text{ meter}$.

## 3. Creation Pathways

### Pathway A: Direct Staged Construction in Blender
*Use for architecture, terrain tiers, vehicles, and articulated props.*
1. Build meshes programmatically using `bmesh` / `mesh.from_pydata()` in numbered stage scripts (`01_terrain.py`, `02_cabin.py`, etc.). Avoid `bpy.ops` in loops.
2. Group repeated geometry into shared mesh data blocks (`tree_mesh`, `boulder_mesh`, `stud_mesh`).
3. Apply standard LEGO PBR plastic materials (Roughness $0.18 - 0.28$, Metallic $0.0$, subtle clearcoat).
4. For collision, add simplified collider meshes named with `-colonly` suffix. Godot automatically creates `StaticBody3D` and `CollisionShape3D` nodes upon import.
5. Save `.blend` checkpoint and export to `.glb` with `export_yup=True, export_animations=True`.

### Pathway B: Physical Brick-by-Brick Construction via LEGO MCP
*Use for masonry walls, small huts, bridges, and monuments requiring physical interlocking validity.*
1. Start build with `new_build(name, width, depth)`.
2. Place parts using `place_brick(part, x, y, z, rotation, color)`. The engine validates stud-tube connectivity and rejects floating or intersecting pieces.
3. Export to LDraw: `export_build("ldraw")` &rarr; `builds/<name>.ldr`.
4. Import into Blender using `ImportLDraw` (`bpy.ops.import_scene.importldraw(filepath, ldrawPath="/Users/vincyvincent/ldraw/")`).

### Pathway C: 3D Mesh to LEGO Brick Conversion via Legolization
*Use for organic shapes, statues, terrain rocks, and complex non-rectilinear shapes.*
1. Export source mesh as `.obj` or `.ply`.
2. Inspect input: `legolization input inspect <model.obj>` to determine recommended target studs.
3. Convert to bricks: `legolization build <model.obj> -o <model.ldr> --target-studs 8 --strategy greedy`.
4. Import into Blender via `ImportLDraw` and scale by $45\times$ to match minifigure proportions.

## 4. Visual Verification Gate (`concept-target-visual-gate`)
Before declaring any asset complete:
1. Capture 4-angle frames in Blender using `look(mode="angles", shading="material")`.
2. Inspect roof slope directions, stud pitch, clearances, and material response.
3. Import into Godot and capture gameplay-camera runtime screenshots.
4. Correct concrete defects and re-verify.

## 5. Resuming After an Error
- **Blender MCP Socket Disconnect:** If Blender closes or disconnects, run:
  `nohup /Applications/Blender.app/Contents/MacOS/Blender > /tmp/blender.log 2>&1 &`
- **Rebuilding Staged Scenes:** If a stage fails, reload the previous checkpoint `.blend` file rather than executing into a dirty scene.
