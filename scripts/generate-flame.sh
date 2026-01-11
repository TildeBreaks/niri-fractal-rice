#!/bin/bash
# Generate fractal flame with flam3
# Usage: generate-flame.sh [palette_name]
#   If palette_name is provided, use that palette instead of random

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
TIMESTAMP=$(date +%s)
OUTPUT="$WALLPAPER_DIR/flame-$TIMESTAMP.png"
GENOME_FILE="/tmp/flam3-genome-$TIMESTAMP.flam3"
PALETTE_NAME="${1:-}"

echo "Generating random fractal flame genome..."

# Use flam3-genome to create a proper random genome
env symmetry=$((RANDOM % 12 - 6)) flam3-genome > "$GENOME_FILE" 2>/dev/null

if [ ! -s "$GENOME_FILE" ]; then
    echo "✗ Failed to generate genome"
    notify-send 'ERROR' 'Flame genome generation failed' -t 2000
    exit 1
fi

echo "Rendering fractal flame at 3440x1440 (high quality)..."

# Edit the genome for high quality output
# - quality: iterations per pixel (higher = more detail, less noise)
# - oversample: anti-aliasing factor (higher = smoother edges)
# - scale: zoom level
sed -i 's/size="[0-9]* [0-9]*"/size="3440 1440"/' "$GENOME_FILE"
sed -i 's/scale="[0-9.]*"/scale="500"/' "$GENOME_FILE"
sed -i 's/supersample="[0-9]*"/supersample="2"/' "$GENOME_FILE"
sed -i 's/quality="[0-9]*"/quality="3000"/' "$GENOME_FILE"
sed -i 's/estimator_radius="[0-9]*"/estimator_radius="11"/' "$GENOME_FILE"

# Apply custom palette if specified
if [ -n "$PALETTE_NAME" ]; then
    echo "Applying palette: $PALETTE_NAME"
    ~/.local/bin/flam3-palette-util.sh apply "$PALETTE_NAME" "$GENOME_FILE"
fi

env out="$OUTPUT" format=png flam3-render < "$GENOME_FILE" 2>/dev/null

if [ -f "$OUTPUT" ]; then
    echo "✓ Fractal flame saved to $OUTPUT"

    # Apply as wallpaper and theme
    wal -i "$OUTPUT" -a 85 -q
    ~/.local/bin/update-niri-colors.sh
    ~/.local/bin/generate-qt-theme.sh
    ~/.local/bin/generate-terminal-logo.sh
    sleep 1
    cp ~/.cache/wal/retro.rasi ~/.config/rofi/retro.rasi 2>/dev/null
    cp ~/.cache/wal/mako-config ~/.config/mako/config 2>/dev/null
    ~/.local/bin/update-floorp-theme.sh 2>/dev/null
    ~/.local/bin/create-gtk-theme.sh 2>/dev/null
    ~/.local/bin/update-sddm-theme.sh 2>/dev/null
    ~/.local/bin/update-wlogout-theme.sh 2>/dev/null
    # Restart notification daemon (supports both mako and swaync)
    if pgrep -x swaync > /dev/null; then
        swaync-client --reload-css 2>/dev/null
    else
        killall mako 2>/dev/null
        sleep 0.3
        systemctl --user start mako.service 2>/dev/null
    fi
    killall thunar 2>/dev/null &
    # Use swww for wallpaper (consistent with manual selection)
    swww img "$OUTPUT" --transition-type fade --transition-duration 2 --transition-fps 60
    # Create signal file for QuickShell bars to detect
    touch ~/.cache/wallpaper-changed
    notify-send 'FRACTAL FLAME' 'New flame generated and applied!' -t 2000
else
    echo "✗ Failed to render fractal flame"
    notify-send 'ERROR' 'Fractal flame render failed' -t 2000
fi

rm -f "$GENOME_FILE"
