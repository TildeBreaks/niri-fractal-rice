#!/bin/bash
# Update SDDM theme with current pywal colors and wallpaper

COLORS_JSON="$HOME/.cache/wal/colors.json"
CURRENT_WALLPAPER=$(cat ~/.cache/wal/wal 2>/dev/null)

if [ ! -f "$COLORS_JSON" ]; then
    echo "No pywal colors found"
    exit 1
fi

# Read colors
COLOR_BG=$(jq -r '.special.background' "$COLORS_JSON")
COLOR_FG=$(jq -r '.special.foreground' "$COLORS_JSON")
COLOR2=$(jq -r '.colors.color2' "$COLORS_JSON")
COLOR4=$(jq -r '.colors.color4' "$COLORS_JSON")
COLOR0=$(jq -r '.colors.color0' "$COLORS_JSON")

echo "Updating SDDM theme..."

# Call helper with pkexec (single password prompt) - timeout after 5 seconds if no response
timeout 5 pkexec /usr/local/bin/sddm-update-helper.sh "$CURRENT_WALLPAPER" "$COLOR_BG" "$COLOR_FG" "$COLOR2" "$COLOR4" "$COLOR0" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ SDDM theme updated!"
else
    echo "⚠ SDDM theme not updated (no password or timeout)"
fi
