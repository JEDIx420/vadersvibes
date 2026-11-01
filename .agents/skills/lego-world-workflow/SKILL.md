---
name: lego-world-workflow
description: >-
  Master routing and orchestration skill for Blender 3D modeling, LEGO CAD construction,
  and Godot engine asset integration for the LEGO Star Wars: A Vader's Peace game project.
  Directs tasks to the appropriate specialist skills (Blender staged construction, LEGO MCP,
  Legolization, ImportLDraw, rig verification, visual gating). Triggers on: "Blender asset",
  "LEGO brick", "LEGO structure", "import to Godot", "staged build", "legolize", "speeder",
  "cottage", "prop", "LDraw".
---

# LEGO World Workflow Orchestrator

This routing skill coordinates 3D asset authoring, constrained LEGO construction, and Godot 4 engine integration for **LEGO Star Wars: A Vader's Peace**.

## Task Routing Map

| Task Category | Workflow Pipeline | Specialist Skills |
| :--- | :--- | :--- |
| **New Ordinary Prop / Environment Piece** | Staged construction &rarr; Visual review &rarr; Godot import check | `blender-staged-scene-construction`, `concept-target-visual-gate` |
| **Brick-by-Brick Structure** (cabin, wall, bridge) | LEGO MCP constrained placement &rarr; ImportLDraw / Blender PBR &rarr; Visual review | `lego-mcp`, `render-ldraw`, `concept-target-visual-gate` |
| **Mesh Converted into Bricks** | Prepare input &rarr; Legolize model &rarr; Render LDraw &rarr; Blender/Godot validation | `prepare-lego-input`, `legolize-model`, `render-ldraw` |
| **Existing Brick Assembly Optimization** | Optimize brick layout &rarr; Analyze stability &rarr; Render comparison | `optimize-lego-build`, `analyze-lego-assembly`, `repair-lego-assembly` |
| **Repeated Terrain or Vegetation Modules** | Staged construction + Voxel diorama techniques &rarr; Runtime performance check | `blender-staged-scene-construction`, `voxel-diorama-blender` |
| **Articulated Mechanism / Animated Prop** | Rig verification &rarr; Action bake &rarr; GLB export &rarr; Godot animation playback | `blender-rig-verification` |
| **Physical Building Instructions** | Publish instructions booklet &rarr; Step-by-step build audit | `publish-lego-instructions`, `inspect-instructions` |
| **Catalog / Algorithm Changes** | Focused placement test &rarr; Regression corpus evaluation | `extend-lego-part-support`, `eval-corpus` |
| **Independent / Background Blender Work** | Isolated session spinup &rarr; Ownership handshake &rarr; Background Cycles render | `blender-mcp-isolated-sessions` |

## Project Scale & Coordinate Agreement

To maintain visual harmony with the 1.80m tall Darth Vader minifigure:
- **Minifigure Scale:** Vader is rigged to $1.80\text{ m}$ height ($45\times$ scale compared to real-world $40\text{ mm}$ minifig).
- **1 LDraw Unit (LDU):** $0.4\text{ mm}$ real $\times 45 = 18\text{ mm} = 0.018\text{ m}$ in Godot.
- **1 Stud Pitch (20 LDU):** $8.0\text{ mm}$ real $\times 45 = 360\text{ mm} = 0.36\text{ m}$ in Godot.
- **1 Brick Height (24 LDU):** $9.6\text{ mm}$ real $\times 45 = 432\text{ mm} = 0.432\text{ m}$ in Godot.
- **1 Plate Height (8 LDU):** $3.2\text{ mm}$ real $\times 45 = 144\text{ mm} = 0.144\text{ m}$ in Godot.
- **Godot World Coordinates:** $+Y$ is Up, $-Z$ is Forward. 1 unit $= 1.0\text{ meter}$.

## Pipeline Execution Rules

1. **Checkpoints & Direct Mesh Creation:** Never run mesh operators in hot loops. Build meshes using `mesh.from_pydata()` and save `.blend` checkpoints between stages.
2. **Visual Gating:** Always capture actual rendered framebuffers from Blender and runtime screenshots from Godot before declaring an asset ready.
3. **Godot Runtime Verification:** A Blender render is not proof of game compatibility. Test materials, PBR roughness, collision shapes, animation players, and draw calls inside Godot.
