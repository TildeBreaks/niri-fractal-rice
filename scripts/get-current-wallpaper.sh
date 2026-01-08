#!/bin/bash
# Get current wallpaper path

# Method 1: From pywal cache
if [ -f ~/.cache/wal/colors.json ]; then
    wallpaper=$(jq -r '.wallpaper // empty' ~/.cache/wal/colors.json 2>/dev/null)
    if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
        echo "$wallpaper"
        exit 0
    fi
fi

# Method 2: From swaybg process
wallpaper=$(pgrep -a swaybg | grep -oP '(?<=-i ).*?(?= |$)' | head -1)
if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
    echo "$wallpaper"
    exit 0
fi

# Method 3: Get most recent wallpaper
wallpaper=$(ls -t ~/Pictures/wallpapers/*.png 2>/dev/null | head -1)
if [ -n "$wallpaper" ]; then
    echo "$wallpaper"
    exit 0
fi

# Fallback
echo ""
