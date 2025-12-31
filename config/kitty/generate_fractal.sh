#!/bin/bash
# Generate a fractal flame for Kitty terminal startup background
# Uses pywal colors for theme cohesion

FRACTAL_DIR="$HOME/.config/kitty/fractals"
FRACTAL_IMAGE="$FRACTAL_DIR/startup_fractal.png"
WAL_COLORS="$HOME/.cache/wal/colors.sh"

# Create directory if it doesn't exist
mkdir -p "$FRACTAL_DIR"

# Source pywal colors if available
if [ -f "$WAL_COLORS" ]; then
    source "$WAL_COLORS"
    echo "Using pywal theme colors..."
else
    echo "Warning: pywal colors not found, using default colors"
    # Default fallback colors
    color0="#1e1e1e"
    color1="#d16969"
    color2="#608b4e"
    color3="#d7ba7d"
    color4="#569cd6"
    color5="#c586c0"
    color6="#4ec9b0"
    color7="#d4d4d4"
fi

# Function to convert hex to RGB
hex_to_rgb() {
    hex="${1#\#}"
    printf "%d %d %d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

# Check if flam3 is available
if command -v flam3-render &> /dev/null && command -v flam3-genome &> /dev/null; then
    echo "Using flam3 to generate themed fractal..."

    # Create a temporary genome file using flam3-genome for complex patterns
    GENOME_FILE="$FRACTAL_DIR/temp_genome.flam3"

    # Generate a random complex genome like the wallpaper generator does
    env symmetry=$((RANDOM % 12 - 6)) flam3-genome > "$GENOME_FILE" 2>/dev/null

    if [ ! -s "$GENOME_FILE" ]; then
        echo "Failed to generate genome, trying fallback method..."
    else
        # Edit the genome to set proper size for fastfetch display
        sed -i 's/size="[0-9]* [0-9]*"/size="1920 1080"/' "$GENOME_FILE"
        sed -i 's/scale="[0-9.]*"/scale="300"/' "$GENOME_FILE"
        sed -i 's/oversample="[0-9]*"/oversample="2"/' "$GENOME_FILE"
        sed -i 's/quality="[0-9]*"/quality="1000"/' "$GENOME_FILE"

        # Render the fractal
        env out="$FRACTAL_IMAGE" format=png flam3-render < "$GENOME_FILE" 2>/dev/null

        if [ -f "$FRACTAL_IMAGE" ]; then
            echo "Themed fractal generated successfully at $FRACTAL_IMAGE"
            rm "$GENOME_FILE" 2>/dev/null
            exit 0
        fi
    fi
fi

# Fallback: Check for Electric Sheep sheep files
if [ -d "$HOME/.electricsheep" ]; then
    SHEEP_FILE=$(find "$HOME/.electricsheep" -name "*.mp4" -o -name "*.avi" | head -1)
    if [ -n "$SHEEP_FILE" ] && command -v ffmpeg &> /dev/null; then
        echo "Extracting frame from Electric Sheep..."
        ffmpeg -i "$SHEEP_FILE" -vframes 1 "$FRACTAL_IMAGE" -y 2>/dev/null
        if [ -f "$FRACTAL_IMAGE" ]; then
            echo "Fractal extracted from Electric Sheep"
            exit 0
        fi
    fi
fi

# Fallback: Generate a simple fractal using ImageMagick if available
if command -v convert &> /dev/null; then
    echo "Generating themed plasma fractal using ImageMagick..."
    # Use primary theme colors for plasma generation
    convert -size 1920x1080 \
        plasma:"${color1:-#d16969}-${color4:-#569cd6}" \
        -blur 0x1 \
        "$FRACTAL_IMAGE" 2>/dev/null
    if [ -f "$FRACTAL_IMAGE" ]; then
        echo "Themed plasma fractal generated"
        exit 0
    fi
fi

# Final fallback: Use Python with PIL/numpy to generate themed Mandelbrot set
if command -v python3 &> /dev/null; then
    echo "Generating themed Mandelbrot fractal using Python..."
    python3 << PYTHON_EOF
import numpy as np
from PIL import Image
import os

# Parse theme colors from environment or use defaults
colors_hex = [
    "${color0:-#1e1e1e}",
    "${color1:-#d16969}",
    "${color2:-#608b4e}",
    "${color3:-#d7ba7d}",
    "${color4:-#569cd6}",
    "${color5:-#c586c0}",
    "${color6:-#4ec9b0}",
    "${color7:-#d4d4d4}"
]

# Convert hex to RGB
def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

theme_colors = [hex_to_rgb(c) for c in colors_hex]

def mandelbrot(c, max_iter=256):
    z = 0
    for n in range(max_iter):
        if abs(z) > 2:
            return n
        z = z*z + c
    return max_iter

def get_gradient_color(value, max_value):
    # Map iteration value to theme colors
    if value == max_value:
        return theme_colors[0]  # Use background color for set members
    
    # Create smooth gradient through theme colors
    num_colors = len(theme_colors)
    position = (value / max_value) * (num_colors - 1)
    idx = int(position)
    t = position - idx
    
    if idx >= num_colors - 1:
        return theme_colors[-1]
    
    # Interpolate between two colors
    c1 = theme_colors[idx]
    c2 = theme_colors[idx + 1]
    
    r = int(c1[0] + (c2[0] - c1[0]) * t)
    g = int(c1[1] + (c2[1] - c1[1]) * t)
    b = int(c1[2] + (c2[2] - c1[2]) * t)
    
    return (r, g, b)

width, height = 1920, 1080
xmin, xmax, ymin, ymax = -2.5, 1.0, -1.2, 1.2

img = np.zeros((height, width, 3), dtype=np.uint8)

print("Generating fractal with theme colors...")
for y in range(height):
    if y % 100 == 0:
        print(f"Progress: {int(y/height*100)}%")
    for x in range(width):
        c = complex(xmin + (xmax - xmin) * x / width,
                   ymin + (ymax - ymin) * y / height)
        m = mandelbrot(c, 256)
        color = get_gradient_color(m, 256)
        img[y, x] = color

output_path = os.path.expanduser('~/.config/kitty/fractals/startup_fractal.png')
Image.fromarray(img).save(output_path)
print("Themed Mandelbrot fractal generated successfully!")
PYTHON_EOF
    
    if [ -f "$FRACTAL_IMAGE" ]; then
        echo "Fractal ready at $FRACTAL_IMAGE"
        exit 0
    fi
fi

echo "Fractal image ready!"
