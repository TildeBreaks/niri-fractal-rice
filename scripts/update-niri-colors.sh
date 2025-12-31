#!/bin/bash
# Update Niri colors from pywal theme
NIRI_CONFIG="$HOME/.config/niri/config.kdl"
COLORS_JSON="$HOME/.cache/wal/colors.json"
if [ ! -f "$COLORS_JSON" ]; then
    echo "Pywal colors not found. Run: wal -i /path/to/wallpaper.jpg -a 85"
    exit 1
fi
# Read colors from pywal
COLOR_BG=$(jq -r '.special.background' "$COLORS_JSON")
COLOR_FG=$(jq -r '.special.foreground' "$COLORS_JSON")
COLOR0=$(jq -r '.colors.color0' "$COLORS_JSON")
COLOR1=$(jq -r '.colors.color1' "$COLORS_JSON")
COLOR2=$(jq -r '.colors.color2' "$COLORS_JSON")
COLOR3=$(jq -r '.colors.color3' "$COLORS_JSON")
COLOR4=$(jq -r '.colors.color4' "$COLORS_JSON")
COLOR7=$(jq -r '.colors.color7' "$COLORS_JSON")
echo "Updating Niri colors..."
echo "Active border: $COLOR4"
echo "Inactive border: $COLOR0"
echo "Focus ring: $COLOR2"
# Backup current config
cp "$NIRI_CONFIG" "$NIRI_CONFIG.backup"
# Update colors in config using sed
sed -i "s/active-color \"#[0-9a-fA-F]\{6\}\"/active-color \"$COLOR2\"/g" "$NIRI_CONFIG"
sed -i "s/inactive-color \"#[0-9a-fA-F]\{6\}\"/inactive-color \"$COLOR0\"/g" "$NIRI_CONFIG"
# Reload Niri config
niri msg action load-config-file
echo "✓ Niri colors updated and reloaded!"
