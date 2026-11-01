# LEGO Star Wars: A Vader's Peace (vadersvibes)

[![Godot Engine](https://img.shields.io/badge/Godot-v4.7.2%20Forward%2B-blue.svg)](https://godotengine.org)
[![Blender](https://img.shields.io/badge/Blender-5.2.3%20LTS-orange.svg)](https://blender.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An open-world sandbox game where **Darth Vader** turns his back on Emperor Palpatine and the destructive galactic civil war, settling peacefully on a remote outer-rim sanctuary planet (**Pelagia-Prime**).

Built in **Godot 4.7 Forward+** with an integrated **Blender + LEGO CAD** asset pipeline (`lego-mcp`, `ImportLDraw`, `legolization`, and `blender-agent-skills`).

---

## 🌟 Gameplay Highlights

- **Vader's Peaceful Sanctuary:** A single-player open world without compulsory grinds or war missions.
- **Hands-Free Holstering:** Vader's hands remain empty when roaming. Crimson lightsaber mounts to hip peg; acoustic guitar slung across the back.
- **Karplus-Strong Acoustic Guitar:** Real physical modeling polyphonic acoustic chords (keys `1`–`6`) for relaxing sunsets.
- **Land, Sea & Space Vehicles:**
  - **74-Z Speeder Bike:** Raycast hovering, banking lean, repulsor boost (`Shift`), and defensive blasters (`Space`/Left-Click).
  - **Coastal Skiff Boat:** Water buoyancy physics, cruising, and dockside pier fishing (`C`).
  - **Sub-Orbital Shuttle:** 6-DOF ion thruster flight with high-altitude planetary barrier deflection.
- **Wildlife Defense:** Non-lethal lightsaber flourishes peacefully pacify wild fauna (Dune Massiff, Loth-Wolf).

---

## 🎮 Controls

| Action | Key / Input | Notes |
| :--- | :--- | :--- |
| **Move** | `W` / `A` / `S` / `D` | Camera-relative movement |
| **Look** | `Mouse` | Decoupled 3rd-person spring-arm orbital camera |
| **Sprint** | `Shift` | High-speed dash |
| **Jump** | `Space` | Minifigure jump |
| **Lightsaber** | `F` | Toggle draw & ignition / holster to hip |
| **Acoustic Guitar** | `G` | Toggle equip / holster to back |
| **Strum Chords** | `1`, `2`, `3`, `4`, `5`, `6` | Realistic Karplus-Strong string synthesis (Chords G, D, Em, C, A, E) |
| **Interact / Mount** | `E` | Mount speeder bike, board skiff, enter shuttle |
| **Fishing** | `C` | Cast fishing line near coastal docks |

---

## 🏗️ Integrated LEGO + Blender Asset Pipeline

The project features a verified, production-grade 3D asset authoring pipeline:
- **`lego-mcp`:** Constraint-verified LEGO brick building engine enforcing physical stud-tube connectivity.
- **`ImportLDraw`:** Automatic import of official LDraw/Studio `.ldr` assemblies with studs, bevels, and PBR plastic shaders.
- **`legolization`:** Converts raw 3D meshes into physically stable, buildable LEGO brick assemblies.
- **`blender-agent-skills`:** Staged scene construction (`bmesh`/`from_pydata`), visual gating review frames, and rig verification.

See the full documentation:
- [Visual Style Brief](docs/style_brief.md)
- [Workflow Guide](docs/workflow_guide.md)
- [Setup Manifest](docs/setup_manifest.md)
- [Validation Evidence](docs/validation_evidence.md)

---

## 🚀 How to Run

### Main Game
```bash
godot res://scenes/world/world.tscn
```

### LEGO Pipeline Validation Scene
```bash
godot res://scenes/test/lego_pipeline_test.tscn
```

### Automated End-to-End Test Suite
```bash
godot res://scenes/tests/test_world_runner.tscn
```

---

*Peace is not the absence of the Force, but the balance of it.*
