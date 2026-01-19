#!/bin/bash
# Updates Hyprland border colors and hyprmodoro colors from pywal

COLORS_FILE="$HOME/.cache/wal/colors.json"

if [[ ! -f "$COLORS_FILE" ]]; then
    echo "No pywal colors found"
    exit 1
fi

# Extract colors (remove # prefix, add alpha)
color1=$(jq -r '.colors.color1' "$COLORS_FILE" | sed 's/#//')
color2=$(jq -r '.colors.color2' "$COLORS_FILE" | sed 's/#//')
color3=$(jq -r '.colors.color3' "$COLORS_FILE" | sed 's/#//')
color4=$(jq -r '.colors.color4' "$COLORS_FILE" | sed 's/#//')
color8=$(jq -r '.colors.color8' "$COLORS_FILE" | sed 's/#//')
fg=$(jq -r '.special.foreground' "$COLORS_FILE" | sed 's/#//')
bg=$(jq -r '.special.background' "$COLORS_FILE" | sed 's/#//')

# Set animated gradient border (active)
hyprctl keyword general:col.active_border "rgba(${color2}ff) rgba(${color4}ff) rgba(${color3}ff) 45deg"

# Set inactive border
hyprctl keyword general:col.inactive_border "rgba(${color8}88)"

# Set hyprmodoro colors
# Using color4 for progress border and foreground for text
hyprctl keyword plugin:hyprmodoro:border:color "rgba(${color4}88)"
hyprctl keyword plugin:hyprmodoro:text:color "rgba(${fg}ff)"
hyprctl keyword plugin:hyprmodoro:buttons:color:foreground "rgba(${fg}ff)"
hyprctl keyword plugin:hyprmodoro:buttons:color:background "rgba(${color2}44)"

echo "Updated Hyprland borders and hyprmodoro with pywal colors"
