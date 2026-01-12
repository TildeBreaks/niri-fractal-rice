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

# Render at EXTREME quality for detailed sheep-style fractals
# - scale: Lower for better framing and screen coverage
# - supersample: Maximum anti-aliasing for silky smooth edges
# - quality: Very high iteration count for incredible detail
# - estimator_radius: Better density estimation
sed -i 's/size="[0-9]* [0-9]*"/size="3440 1440"/' "$GENOME_FILE"
sed -i 's/scale="[0-9.]*"/scale="250"/' "$GENOME_FILE"
sed -i 's/supersample="[0-9]*"/supersample="4"/' "$GENOME_FILE"
sed -i 's/quality="[0-9]*"/quality="12000"/' "$GENOME_FILE"
sed -i 's/estimator_radius="[0-9]*"/estimator_radius="15"/' "$GENOME_FILE"

env out="$OUTPUT" format=png flam3-render < "$GENOME_FILE" 2>/dev/null

if [ -f "$OUTPUT" ]; then
    echo "✓ Electric Sheep saved to $OUTPUT"

    # Apply as wallpaper and theme (same workflow as flame script)
    wal -i "$OUTPUT" -a 85 -q
    ~/.local/bin/update-niri-colors.sh
    ~/.local/bin/generate-qt-theme.sh
    ~/.local/bin/generate-terminal-logo.sh
    sleep 1
    cp ~/.cache/wal/retro.rasi ~/.config/rofi/retro.rasi 2>/dev/null
    cp ~/.cache/wal/mako-config ~/.config/mako/config 2>/dev/null
    ~/.local/bin/update-floorp-theme.sh 2>/dev/null
    ~/.local/bin/update-zen-colors.sh 2>/dev/null
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
    # Restart color cycling daemon with new colors
    pkill -f "niri-color-cycle.sh" 2>/dev/null
    ~/.local/bin/niri-color-cycle.sh &
    # Use swww for wallpaper (consistent with manual selection)
    swww img "$OUTPUT" --transition-type fade --transition-duration 2 --transition-fps 60
    # Create signal file for QuickShell bars to detect
    touch ~/.cache/wallpaper-changed
    notify-send 'ELECTRIC SHEEP' 'Sheep generated and applied!' -t 2000
else
    echo "✗ Failed to generate sheep"
    notify-send 'ERROR' 'Sheep generation failed' -t 2000
fi

rm -f "$GENOME_FILE"
