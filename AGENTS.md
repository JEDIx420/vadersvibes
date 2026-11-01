# LEGO Star Wars: A Vader's Peace — Agent Guidelines

## 1. Asset & 3D Workflow Routing
Whenever authoring, converting, optimizing, or inspecting 3D assets, Blender scenes, LEGO brick assemblies, or Godot imports, activate and adhere to the project's master workflow skill:
- **`lego-world-workflow`**: Dispatches tasks to specialist Blender and LEGO skills (`blender-staged-scene-construction`, `lego-mcp`, `legolize-model`, `ImportLDraw`, `concept-target-visual-gate`, `blender-rig-verification`).

## 2. Style & Scale Conventions
- **Minifigure Reference:** Darth Vader is 1.80m tall in Godot world coordinates ($45\times$ scale of physical 40mm minifig).
- **Stud Pitch:** 1 stud $= 0.36\text{ m}$.
- **Brick Height:** 1 brick $= 0.432\text{ m}$.
- **Plate Height:** 1 plate $= 0.144\text{ m}$.
- **Style Direction:** Toy-world aesthetic akin to *LEGO Star Wars: Castaways* — authentic plastic ABS materials with subtle rounded bevels, visible cylindrical studs where appropriate, clear silhouettes, and warm coastal lighting.
- **Verification Rule:** Never claim an asset is ready based on code or a Blender render alone. Always verify its appearance, materials, and physics collision inside a running Godot scene.
