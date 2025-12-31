#!/bin/bash
# Lock screen with pywal colors

COLORS_JSON="$HOME/.cache/wal/colors.json"

if [ -f "$COLORS_JSON" ]; then
    # Read colors
    COLOR_BG=$(jq -r '.special.background' "$COLORS_JSON")
    COLOR_FG=$(jq -r '.special.foreground' "$COLORS_JSON")
    COLOR0=$(jq -r '.colors.color0' "$COLORS_JSON")
    COLOR2=$(jq -r '.colors.color2' "$COLORS_JSON")
    COLOR4=$(jq -r '.colors.color4' "$COLORS_JSON")
    COLOR1=$(jq -r '.colors.color1' "$COLORS_JSON")
else
    # Fallback to retro green
    COLOR_BG="#0a0e14"
    COLOR_FG="#00ff41"
    COLOR0="#003300"
    COLOR2="#00ff41"
    COLOR4="#00aa00"
    COLOR1="#ff0000"
fi

# Lock with colors
swaylock \
    --config ~/.config/swaylock/config \
    --color "${COLOR_BG}ff" \
    --inside-color "${COLOR0}cc" \
    --inside-clear-color "${COLOR0}cc" \
    --inside-ver-color "${COLOR4}cc" \
    --inside-wrong-color "${COLOR1}cc" \
    --ring-color "${COLOR2}ff" \
    --ring-clear-color "${COLOR4}ff" \
    --ring-ver-color "${COLOR4}ff" \
    --ring-wrong-color "${COLOR1}ff" \
    --line-color "${COLOR_BG}00" \
    --line-clear-color "${COLOR_BG}00" \
    --line-ver-color "${COLOR_BG}00" \
    --line-wrong-color "${COLOR_BG}00" \
    --key-hl-color "${COLOR4}ff" \
    --bs-hl-color "${COLOR1}ff" \
    --separator-color "${COLOR_BG}00" \
    --text-color "${COLOR_FG}ff" \
    --text-clear-color "${COLOR_FG}ff" \
    --text-ver-color "${COLOR_BG}ff" \
    --text-wrong-color "${COLOR_BG}ff"
