# LEGO Star Wars: A Vader's Peace — Visual Style Brief & Art Direction

## 1. Core Vision & Aesthetic Reference
The visual benchmark is the warm, tactile toy-world feeling of **LEGO Star Wars: Castaways** combined with the majestic, solitary peace of a secluded outer-rim haven (**Pelagia-Prime**).
The world is built from authentic LEGO elements, with glossy ABS plastic finishes, subtle molding parting lines, cylindrical stud connectors with crisp embossed circular tops, and cohesive proportions.

## 2. Mathematical Scale & Coordinate System
- **Character Baseline:** LEGO Minifigure Darth Vader $= 1.80\text{ m}$ height in Godot ($45\times$ scale of physical $40\text{ mm}$ minifig).
- **Horizontal Unit (Stud Pitch):** $20\text{ LDU} = 8.0\text{ mm} \times 45 = 0.36\text{ m}$.
- **Vertical Unit (Plate Height):** $8\text{ LDU} = 3.2\text{ mm} \times 45 = 0.144\text{ m}$.
- **Vertical Unit (Brick Height):** $24\text{ LDU} = 9.6\text{ mm} \times 45 = 0.432\text{ m}$ ($3\times$ plate height).
- **Stud Geometry:** Cylinder diameter $= 4.8\text{ mm} \times 45 = 0.216\text{ m}$, stud height $= 1.6\text{ mm} \times 45 = 0.072\text{ m}$.
- **Slope Proportions:** Standard $33^\circ$ and $45^\circ$ slopes (e.g. $2\times 2$ slope $= 0.72\text{ m}$ width $\times 0.432\text{ m}$ height).

## 3. Restrained Color Palette
To avoid visual chaos, the sanctuary uses an intentional, curated palette based on official LEGO color standards:
- **Architecture (Sanctuary Cottage & Walls):**
  - Dark Stone Grey / Dark Bluish Gray (LDraw 72, Hex `#6C6E68`) — foundation, cornerstone blocks, piers.
  - Medium Stone Grey / Light Bluish Gray (LDraw 71, Hex `#A0A5A9`) — masonry walls, lintels.
  - Reddish Brown (LDraw 70, Hex `#582A12`) & Dark Brown (LDraw 308, Hex `#352100`) — timber beams, roof trusses, deck planks.
  - Sand Green (LDraw 378, Hex `#708E7C`) & Warm Gold (LDraw 297, Hex `#AA7F2E`) — accent tiles and trim.
- **Terrain & Nature:**
  - Sand Yellow / Tan (LDraw 19, Hex `#E4CD9E`) — beaches, coastal paths, dunes.
  - Bright Green (LDraw 10, Hex `#4B9F4A`) & Dark Green (LDraw 288, Hex `#184632`) — grass plates, stepped cliff terraces.
  - Medium Azure (LDraw 322, Hex `#36AEBF`) & Dark Azure (LDraw 321, Hex `#078BC9`) — shallow coastal waters.
  - White (LDraw 15, Hex `#FFFFFF`) & Trans-Clear — wave foam, lightsaber flare, glowing energy nodes.

## 4. Materials & Surface Shading
- **Plastic Shading:** High-specularity PBR material.
  - Metallic $= 0.0$.
  - Roughness $= 0.18 - 0.28$ (glossy plastic with gentle soft-sheen reflections).
  - Clearcoat $= 0.35$, Clearcoat Roughness $= 0.15$.
  - Subsurface Scattering $= 0.05$ (slight optical warmth on thin edges).
- **Bevels:** Micro-bevels on sharp corners ($1.0 - 2.0\text{ mm}$ real scale / $0.045 - 0.09\text{ m}$ game scale) to capture natural specular highlights.

## 5. Camera & Level of Detail (LOD) Rules
- **Gameplay Camera:** Third-person orbital follow camera positioned $3.6\text{ m}$ behind Vader at $1.2\text{ m}$ eye level, with an FOV of $65^\circ$.
- **Near-Field Detail ($< 15\text{ m}$):** Real 3D studs, seam lines between bricks, individual plate steps, and articulated hinges.
- **Mid-Field Detail ($15\text{ m} - 50\text{ m}$):** Stepped plate contours, textured stud surfaces, silhouette-dominant tree canopies.
- **Far-Field Detail ($> 50\text{ m}$):** Merged cluster geometry, simplified smooth slope profiles, low-draw-call chunking.
