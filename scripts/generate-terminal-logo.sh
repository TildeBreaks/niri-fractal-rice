#!/bin/bash
# Generate a terminal logo using pywal colors
# Creates a plasma-style pattern that fills the entire space

OUTPUT="$HOME/.config/fastfetch/logo.png"
SIZE="400x400"

# Source pywal colors
source ~/.cache/wal/colors.sh

# Create a plasma pattern with pywal colors - fills the entire space
magick -size $SIZE \
    plasma:"$color2"-"$color4" \
    -blur 0x2 \
    \( -size $SIZE plasma:"$color6"-"$color0" -blur 0x3 \) \
    -compose overlay -composite \
    -modulate 100,120,100 \
    -sigmoidal-contrast 3x50% \
    \( -size $SIZE radial-gradient:none-"$color0" \) \
    -compose multiply -composite \
    -bordercolor "$color0" -border 8 \
    -resize $SIZE! \
    "$OUTPUT"

echo "Terminal logo generated: $OUTPUT"
