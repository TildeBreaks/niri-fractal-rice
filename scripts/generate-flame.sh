#!/bin/bash
# Generate fractal flame with flam3

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
TIMESTAMP=$(date +%s)
OUTPUT="$WALLPAPER_DIR/flame-$TIMESTAMP.png"
GENOME_FILE="/tmp/flam3-genome-$TIMESTAMP.flam3"

echo "Generating random fractal flame genome..."

# Use flam3-genome to create a proper random genome
env symmetry=$((RANDOM % 12 - 6)) flam3-genome > "$GENOME_FILE" 2>/dev/null

if [ ! -s "$GENOME_FILE" ]; then
    echo "✗ Failed to generate genome"
    notify-send 'ERROR' 'Flame genome generation failed' -t 2000
    exit 1
fi

echo "Rendering fractal flame at 3440x1440..."

# Edit the genome to set proper size, scale, and oversample
sed -i 's/size="[0-9]* [0-9]*"/size="3440 1440"/' "$GENOME_FILE"
sed -i 's/scale="[0-9.]*"/scale="400"/' "$GENOME_FILE"
sed -i 's/oversample="[0-9]*"/oversample="3"/' "$GENOME_FILE"
sed -i 's/quality="[0-9]*"/quality="2000"/' "$GENOME_FILE"

env out="$OUTPUT" format=png flam3-render < "$GENOME_FILE" 2>/dev/null

if [ -f "$OUTPUT" ]; then
    echo "✓ Fractal flame saved to $OUTPUT"

    # Generate 5 kitty fractals with the same theme
    echo "Generating 5 kitty fractals..."
    KITTY_FRACTAL_DIR="$HOME/.config/kitty/fractals"
    mkdir -p "$KITTY_FRACTAL_DIR"

    # Clear old fractals
    rm -f "$KITTY_FRACTAL_DIR"/fractal_*.png

    # Generate 5 new ones
    for i in {1..5}; do
        KITTY_GENOME="/tmp/kitty-genome-$i-$TIMESTAMP.flam3"
        env symmetry=$((RANDOM % 12 - 6)) flam3-genome > "$KITTY_GENOME" 2>/dev/null

        if [ -s "$KITTY_GENOME" ]; then
            # Smaller size and quality for faster rendering
            sed -i 's/size="[0-9]* [0-9]*"/size="1920 1080"/' "$KITTY_GENOME"
            sed -i 's/scale="[0-9.]*"/scale="300"/' "$KITTY_GENOME"
            sed -i 's/oversample="[0-9]*"/oversample="2"/' "$KITTY_GENOME"
            sed -i 's/quality="[0-9]*"/quality="800"/' "$KITTY_GENOME"

            env out="$KITTY_FRACTAL_DIR/fractal_$i.png" format=png flam3-render < "$KITTY_GENOME" 2>/dev/null &
            rm -f "$KITTY_GENOME"
        fi
    done

    # Wait for all fractals to finish
    wait
    echo "✓ Kitty fractals generated"
    
    # Apply as wallpaper and theme
    wal -i "$OUTPUT" -a 85 -q
    sleep 2
    cp ~/.cache/wal/retro.rasi ~/.config/rofi/retro.rasi
    cp ~/.cache/wal/mako-config ~/.config/mako/config
    ~/.local/bin/update-niri-colors.sh
    ~/.local/bin/update-floorp-theme.sh
    ~/.local/bin/create-gtk-theme.sh 2>/dev/null
    ~/.local/bin/update-sddm-theme.sh 2>/dev/null
    killall mako 2>/dev/null
    sleep 0.5
    killall thunar 2>/dev/null &
    killall swaybg 2>/dev/null
    sleep 0.3
    swaybg -i "$OUTPUT" -m fill &
    sleep 0.3
    systemctl --user restart waybar.service
    systemctl --user start mako.service
    notify-send 'FRACTAL FLAME' 'New flame generated and applied!' -t 2000
else
    echo "✗ Failed to render fractal flame"
    notify-send 'ERROR' 'Fractal flame render failed' -t 2000
fi

rm -f "$GENOME_FILE"
