#!/bin/bash
# Generate a terminal logo using pywal colors
# Creates randomized fractal/abstract patterns

OUTPUT="$HOME/.config/fastfetch/logo.png"
SIZE="1100x650"

# Source pywal colors
source ~/.cache/wal/colors.sh

# Random seed for variety
SEED=$RANDOM

# Pick a random effect (1-6)
EFFECT=$((RANDOM % 6 + 1))

case $EFFECT in
    1)
        # Swirled plasma with gradient map
        magick -size $SIZE -seed $SEED plasma:fractal \
            -swirl $((RANDOM % 180 + 90)) \
            -colorspace gray \
            \( -size 1x6 gradient: \( +size xc:"$color0" xc:"$color1" xc:"$color2" xc:"$color4" xc:"$color6" xc:"$color7" +append \) -clut \) \
            -clut \
            -modulate 100,120,100 \
            PNG24:"$OUTPUT"
        ;;
    2)
        # Fractal noise with color bands
        magick -size $SIZE -seed $SEED plasma:fractal \
            -blur 0x1 \
            -fx "sin(u*pi*8)/2+0.5" \
            -colorspace gray \
            \( -size 1x6 gradient: \( +size xc:"$color0" xc:"$color2" xc:"$color4" xc:"$color5" xc:"$color6" xc:"$color7" +append \) -clut \) \
            -clut \
            PNG24:"$OUTPUT"
        ;;
    3)
        # Layered plasma with multiply blend
        magick -size $SIZE -seed $SEED plasma:"$color1"-"$color4" \
            \( -size $SIZE -seed $((SEED+1)) plasma:"$color2"-"$color6" -blur 0x2 \) \
            -compose multiply -composite \
            \( -size $SIZE -seed $((SEED+2)) plasma:"$color0"-"$color7" -blur 0x4 \) \
            -compose screen -composite \
            -sigmoidal-contrast 4x50% \
            PNG24:"$OUTPUT"
        ;;
    4)
        # Spiral fractal
        magick -size $SIZE -seed $SEED plasma:fractal \
            -swirl $((RANDOM % 270 + 180)) \
            -implode -0.$((RANDOM % 4 + 2)) \
            -colorspace gray \
            \( -size 1x6 gradient: \( +size xc:"$color0" xc:"$color1" xc:"$color2" xc:"$color4" xc:"$color6" xc:"$color7" +append \) -clut \) \
            -clut \
            -modulate 100,130,100 \
            PNG24:"$OUTPUT"
        ;;
    5)
        # Turbulent waves
        magick -size $SIZE -seed $SEED plasma:fractal \
            -wave $((RANDOM % 15 + 5))x$((RANDOM % 80 + 40)) \
            -wave $((RANDOM % 10 + 3))x$((RANDOM % 60 + 30)) \
            -colorspace gray \
            \( -size 1x6 gradient: \( +size xc:"$color0" xc:"$color2" xc:"$color3" xc:"$color4" xc:"$color5" xc:"$color7" +append \) -clut \) \
            -clut \
            -gravity center -crop $SIZE+0+0 +repage \
            PNG24:"$OUTPUT"
        ;;
    6)
        # Kaleidoscope effect
        magick -size $SIZE -seed $SEED plasma:"$color2"-"$color6" \
            -blur 0x2 \
            \( +clone -rotate 90 \) -compose multiply -composite \
            \( +clone -flip \) -compose screen -composite \
            \( +clone -flop \) -compose overlay -composite \
            -modulate 100,140,100 \
            -sigmoidal-contrast 3x40% \
            PNG24:"$OUTPUT"
        ;;
esac

echo "Terminal logo generated (effect $EFFECT): $OUTPUT"
