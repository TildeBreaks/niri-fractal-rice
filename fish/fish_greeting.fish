function fish_greeting
    # Pick a random fractal from the collection
    set -l fractals ~/.config/kitty/fractals/fractal_*.png
    set -l random_fractal (random choice $fractals 2>/dev/null || echo $fractals[1])
    if test -f "$random_fractal"
        fastfetch --logo $random_fractal --logo-type kitty-direct --logo-width 35 --logo-height 28
        # Regenerate this fractal in the background using pywal colors
        bash -c "
            # Source pywal colors (bash can handle it)
            if [ -f ~/.cache/wal/colors.sh ]; then
                source ~/.cache/wal/colors.sh
            fi
            temp_genome=/tmp/kitty-regen-\$RANDOM.flam3
            env symmetry=\$((RANDOM % 12 - 6)) flam3-genome > \$temp_genome 2>/dev/null
            if [ -s \"\$temp_genome\" ]; then
                # Generate palette from pywal colors - each color on its own line
                python3 << 'PYEOF' > /tmp/palette-\$\$.txt
colors = ['\$color0', '\$color1', '\$color2', '\$color3', '\$color4', '\$color5', '\$color6', '\$color7']
rgb_colors = []
for c in colors:
    c = c.lstrip('#')
    if len(c) == 6:
        r, g, b = int(c[0:2], 16), int(c[2:4], 16), int(c[4:6], 16)
        rgb_colors.append((r, g, b))
if len(rgb_colors) > 1:
    palette = []
    steps = 256 // (len(rgb_colors) - 1)
    for i in range(len(rgb_colors) - 1):
        r1, g1, b1 = rgb_colors[i]
        r2, g2, b2 = rgb_colors[i + 1]
        for j in range(steps):
            t = j / steps
            r = int(r1 + (r2 - r1) * t)
            g = int(g1 + (g2 - g1) * t)
            b = int(b1 + (b2 - b1) * t)
            palette.append((r, g, b))
    while len(palette) < 256:
        palette.append(palette[-1])
    # Print each color as a separate line with index
    for i, (r, g, b) in enumerate(palette):
        print(f'   <color index=\"{i}\" rgb=\"{r} {g} {b}\"/>')
PYEOF
                palette_lines=\$(cat /tmp/palette-\$\$.txt)
                # Replace palette in genome
                sed -i '/<palette/,/<\\/palette>/d' \$temp_genome
                sed -i \"s|</flame>|\$palette_lines\\n</flame>|\" \$temp_genome
                # Set rendering parameters - bigger for better quality
                sed -i 's/size=\"[0-9]* [0-9]*\"/size=\"2560 1440\"/' \$temp_genome
                sed -i 's/scale=\"[0-9.]*\"/scale=\"350\"/' \$temp_genome
                sed -i 's/oversample=\"[0-9]*\"/oversample=\"2\"/' \$temp_genome
                sed -i 's/quality=\"[0-9]*\"/quality=\"1000\"/' \$temp_genome
                env out='$random_fractal' format=png flam3-render < \$temp_genome 2>/dev/null
                rm -f \$temp_genome /tmp/palette-\$\$.txt
            fi
        " &
    else
        fastfetch
    end
end
