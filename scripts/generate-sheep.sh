#!/bin/bash
# Generate Electric Sheep-style fractal (saves to wallpapers for manual selection)

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
TIMESTAMP=$(date +%s)
OUTPUT="$WALLPAPER_DIR/sheep-$TIMESTAMP.png"
GENOME_FILE="/tmp/sheep-genome-$TIMESTAMP.flam3"

echo "Generating Electric Sheep-style fractal..."
notify-send 'GENERATING SHEEP' 'Creating fractal... 30-60 seconds' -t 3000

# Generate random genome with high symmetry for sheep-like patterns
env symmetry=$((RANDOM % 6 + 2)) flam3-genome > "$GENOME_FILE" 2>/dev/null

if [ ! -s "$GENOME_FILE" ]; then
    echo "✗ Failed to generate genome"
    notify-send 'ERROR' 'Sheep genome generation failed' -t 2000
    exit 1
fi

# Render at high quality with full screen coverage
sed -i 's/size="[0-9]* [0-9]*"/size="3440 1440"/' "$GENOME_FILE"
sed -i 's/scale="[0-9.]*"/scale="400"/' "$GENOME_FILE"
sed -i 's/oversample="[0-9]*"/oversample="4"/' "$GENOME_FILE"
sed -i 's/quality="[0-9]*"/quality="3000"/' "$GENOME_FILE"

env out="$OUTPUT" format=png flam3-render < "$GENOME_FILE" 2>/dev/null

if [ -f "$OUTPUT" ]; then
    echo "✓ Electric Sheep saved to $OUTPUT"
    notify-send 'SHEEP READY' 'Fractal saved to wallpapers folder!' -t 2000
else
    echo "✗ Failed to generate sheep"
    notify-send 'ERROR' 'Sheep generation failed' -t 2000
fi

rm -f "$GENOME_FILE"
