#!/usr/bin/env python3
# Fast fractal wallpaper generator using vectorized numpy

import numpy as np
from PIL import Image
import sys
import os
from datetime import datetime

def mandelbrot_set(width=3440, height=1440, max_iter=50):
    # Random interesting area
    xmin, xmax = np.random.uniform(-2, 0.5), np.random.uniform(-0.5, 1)
    ymin, ymax = np.random.uniform(-1.5, 0), np.random.uniform(0, 1.5)
    
    # Create grid
    x = np.linspace(xmin, xmax, width)
    y = np.linspace(ymin, ymax, height)
    X, Y = np.meshgrid(x, y)
    C = X + 1j * Y
    
    # Calculate mandelbrot
    Z = np.zeros_like(C)
    M = np.zeros(C.shape)
    
    for i in range(max_iter):
        mask = np.abs(Z) <= 2
        Z[mask] = Z[mask]**2 + C[mask]
        M[mask] = i
    
    return M

def julia_set(width=3440, height=1440, max_iter=50):
    # Random Julia constant
    c = complex(np.random.uniform(-0.8, 0.8), np.random.uniform(-0.8, 0.8))
    
    # Create grid
    x = np.linspace(-2, 2, width)
    y = np.linspace(-1.5, 1.5, height)
    X, Y = np.meshgrid(x, y)
    Z = X + 1j * Y
    
    # Calculate Julia
    M = np.zeros(Z.shape)
    
    for i in range(max_iter):
        mask = np.abs(Z) <= 2
        Z[mask] = Z[mask]**2 + c
        M[mask] = i
    
    return M

def colorize(fractal):
    # Normalize
    fractal = fractal / fractal.max()
    
    # Random color scheme
    hue_base = np.random.random()
    
    # Vectorized coloring
    h = (hue_base + fractal * 0.5) % 1.0
    s = 0.6 + fractal * 0.4
    v = 0.3 + fractal * 0.7
    
    # HSV to RGB
    rgb = np.zeros((*fractal.shape, 3), dtype=np.uint8)
    
    import colorsys
    for i in range(fractal.shape[0]):
        for j in range(fractal.shape[1]):
            r, g, b = colorsys.hsv_to_rgb(h[i,j], s[i,j], v[i,j])
            rgb[i,j] = [int(r*255), int(g*255), int(b*255)]
    
    return rgb

if __name__ == "__main__":
    fractal_type = sys.argv[1] if len(sys.argv) > 1 else "mandelbrot"
    
    print(f"Generating {fractal_type} fractal (this may take 10-20 seconds)...", flush=True)
    
    if fractal_type == "mandelbrot":
        fractal = mandelbrot_set()
    else:
        fractal = julia_set()
    
    print("Colorizing...", flush=True)
    rgb = colorize(fractal)
    
    print("Saving...", flush=True)
    img = Image.fromarray(rgb)
    
    timestamp = int(datetime.now().timestamp())
    filename = f"{os.environ['HOME']}/Pictures/wallpapers/fractal-{fractal_type}-{timestamp}.png"
    
    img.save(filename)
    print(f"✓ Saved to {filename}")

