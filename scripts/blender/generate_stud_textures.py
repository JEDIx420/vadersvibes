import numpy as np
from PIL import Image
import os

size = 512
img_normal = np.zeros((size, size, 3), dtype=np.uint8)
img_rough = np.zeros((size, size), dtype=np.uint8)

# 4x4 grid of studs in 512x512 -> each stud cell is 128x128
cells = 4
cell_size = size // cells
stud_radius = 42 # pixels (radius of LEGO stud)
bevel_width = 6   # pixels for smooth rounded edge

for y in range(size):
    for x in range(size):
        # find distance to center of current cell
        cx = (x // cell_size) * cell_size + cell_size // 2
        cy = (y // cell_size) * cell_size + cell_size // 2
        dx = x - cx
        dy = y - cy
        dist = np.sqrt(dx*dx + dy*dy)
        
        # Default flat normal pointing up (0, 0, 1) -> RGB (128, 128, 255)
        nx, ny, nz = 0.0, 0.0, 1.0
        rough = 75 # shiny LEGO plastic
        
        if dist < stud_radius + bevel_width:
            if dist < stud_radius - bevel_width:
                # Flat top of the stud
                nx, ny, nz = 0.0, 0.0, 1.0
                rough = 55 # polished stud top
            elif dist <= stud_radius:
                # Top outer bevel
                t = (dist - (stud_radius - bevel_width)) / bevel_width
                angle = t * np.pi * 0.45
                dir_x = dx / max(dist, 1e-5)
                dir_y = dy / max(dist, 1e-5)
                nx = dir_x * np.sin(angle)
                ny = dir_y * np.sin(angle)
                nz = np.cos(angle)
            else:
                # Base bevel into plate
                t = (dist - stud_radius) / bevel_width
                angle = (1.0 - t) * np.pi * 0.45
                dir_x = dx / max(dist, 1e-5)
                dir_y = dy / max(dist, 1e-5)
                nx = dir_x * np.sin(angle)
                ny = dir_y * np.sin(angle)
                nz = np.cos(angle)
                rough = 65
        
        # Normalize normal vector
        norm = np.sqrt(nx*nx + ny*ny + nz*nz)
        nx /= norm
        ny /= norm
        nz /= norm
        
        # Convert [-1, 1] to [0, 255]
        # In OpenGL/Godot normal maps: X is right, Y is up/inverted, Z is forward
        r = int(np.clip((nx * 0.5 + 0.5) * 255, 0, 255))
        g = int(np.clip((ny * 0.5 + 0.5) * 255, 0, 255))
        b = int(np.clip((nz * 0.5 + 0.5) * 255, 0, 255))
        
        img_normal[y, x] = [r, g, b]
        img_rough[y, x] = rough

out_dir = "/Users/vincyvincent/.gemini/antigravity/scratch/lego-vader-openworld/assets/textures"
os.makedirs(out_dir, exist_ok=True)
Image.fromarray(img_normal).save(os.path.join(out_dir, "lego_stud_normal.png"))
Image.fromarray(img_rough).save(os.path.join(out_dir, "lego_stud_roughness.png"))
print("Saved lego_stud_normal.png and lego_stud_roughness.png successfully!")
