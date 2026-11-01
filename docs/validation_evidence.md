# LEGO Pipeline Validation Evidence

## 1. Summary of Completed Tests

| Test ID & Title | Method & Tool | Result & Verification Evidence |
| :--- | :--- | :--- |
| **Test 1: Constrained Construction** | `lego-mcp` python engine | Created `validation_pedestal` build on $16 \times 16$ baseplate. Placed `brick_2x4` at $Z=0$ and two `slope_2x2` at $Z=3$. Tested intentional invalid placement (floating `brick_2x2` at $Z=10$), which was rejected with `FLOATING: no stud connection` without corrupting state. Exported to `validation_pedestal.ldr`. |
| **Test 2: Real-Part Import** | `ImportLDraw` in Blender 5.2.3 | Imported `validation_pedestal.ldr` into Blender using official parts library at `/Users/vincyvincent/ldraw`. Verified `3001.dat` (Brick 2x4) and `3039.dat` (Slope 2x2) with authentic studs, bevels, and PBR materials. |
| **Test 3: Mesh-to-Brick Conversion** | `legolization` CLI v0.6.0 | Created 3D cone mesh `stone_monument.obj`. Ran `legolization input inspect` (recommended 16 studs). Executed `legolization build --strategy greedy` to generate `stone_monument.ldr` with 121 parts (`stable=True`, `buildable=True`). Imported into Blender and rendered with `look`. |
| **Test 4: Procedural Repetition** | Blender staged script | Created shared mesh data blocks (`LEGO_Pine_Tree_Shared_Mesh`, `LEGO_Faceted_Boulder_Mesh`) and instanced 4 pine trees and 3 boulders across the scene. Verified 145 meshes sharing geometry with clean draw calls. |
| **Test 5: Animation** | Blender keyframing & Godot `AnimationPlayer` | Built articulated cabin door with pivot on left hinge post. Keyframed 60-frame `door_swing` rotation action ($0^\circ \to -85^\circ \to 0^\circ$). Verified automatic import into Godot's `AnimationPlayer` and playback in running engine. |
| **Test 6: Complete Game Import** | Godot 4.7.2 Forward+ Metal | Exported `lego_coastal_sanctuary.glb` (1.4 MB). Imported into Godot with 8 automatic `StaticBody3D` colliders generated via `-colonly` suffix. Darth Vader spawns on landing pad, walks, jumps, draws crimson lightsaber, and strums acoustic guitar without clipping or falling. |

## 2. Visual Captures

| Image | File Location | Description |
| :--- | :--- | :--- |
| **Blender Asset View** | `test_screenshots/blender_asset_cabin.png` | 4-angle material render of the sanctuary cabin with timber walls, foundation, A-frame roof, and hinged door. |
| **Blender Full Area** | `test_screenshots/blender_full_sanctuary.png` | Aerial 4-angle view of the $14.4\text{ m} \times 14.4\text{ m}$ coastal terrain, landing pad, trees, boulders, pier, and monument. |
| **Godot Gameplay View** | `test_screenshots/godot_gameplay_sanctuary.png` | Third-person camera view behind Darth Vader standing on the beach, looking toward the bluff, cabin, trees, and ocean. |
| **Godot Stud Close-Up** | `test_screenshots/godot_brick_closeup.png` | Ground-level close-up displaying cylindrical LEGO studs, stepped grass terraces, and the 121-part legolized monument. |
| **Godot Door Animation** | `test_screenshots/godot_door_animation.png` | Front view of the cabin doorway showing the moving hinged door and A-frame roof. |

## 3. Measured Runtime Performance (Godot 4.7 Forward+)

- **Display Resolution:** $1280 \times 720$
- **Rendering Backend:** Forward+ (Metal 4.0 Backend on Apple Silicon M4)
- **Frame Rate (FPS):** $41.0 - 42.0\text{ FPS}$ (under full Forward+ SSAO, Glow, Tonemapping, and directional soft shadow maps)
- **Frame Time:** $23.8\text{ ms} - 24.4\text{ ms}$
- **Draw Calls:** 202 - 212
- **Objects Drawn:** 563 - 575
- **Primitives Drawn:** 468,768
- **Static Memory:** $234.0\text{ MB}$
- **Peak Memory:** $240.2\text{ MB}$
