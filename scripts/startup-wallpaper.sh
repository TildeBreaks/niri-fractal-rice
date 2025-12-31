#!/bin/bash
# Apply last wallpaper on startup

WALLPAPER=$(cat ~/.cache/wal/wal 2>/dev/null)

if [ -f "$WALLPAPER" ]; then
    echo "Applying wallpaper: $WALLPAPER"
    swaybg -i "$WALLPAPER" -m fill &
else
    echo "No wallpaper found, using first available"
    FIRST_WALL=$(find ~/Pictures/wallpapers -type f \( -iname "*.jpg" -o -iname "*.png" \) | head -1)
    if [ -f "$FIRST_WALL" ]; then
        swaybg -i "$FIRST_WALL" -m fill &
    fi
fi
