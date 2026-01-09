#!/bin/bash
# Simple wallpaper application script
# Usage: apply-wallpaper.sh /path/to/image.png

WALLPAPER="$1"

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "Error: No valid wallpaper path provided"
    exit 1
fi

# Apply pywal colors
wal -i "$WALLPAPER" -a 85 -q

# Update theme components
~/.local/bin/update-niri-colors.sh 2>/dev/null
~/.local/bin/generate-qt-theme.sh 2>/dev/null
~/.local/bin/generate-terminal-logo.sh 2>/dev/null

sleep 0.5

# Copy templates
cp ~/.cache/wal/retro.rasi ~/.config/rofi/retro.rasi 2>/dev/null
cp ~/.cache/wal/mako-config ~/.config/mako/config 2>/dev/null

# Update other themes
~/.local/bin/update-floorp-theme.sh 2>/dev/null
~/.local/bin/create-gtk-theme.sh 2>/dev/null
~/.local/bin/update-sddm-theme.sh 2>/dev/null
~/.local/bin/update-wlogout-theme.sh 2>/dev/null

# Restart mako
killall mako 2>/dev/null
sleep 0.3

# Kill any competing wallpaper daemons
killall swaybg 2>/dev/null

# SET THE WALLPAPER
swww img "$WALLPAPER" --transition-type fade --transition-duration 2 --transition-fps 60

# Restart services
systemctl --user start mako.service 2>/dev/null
killall thunar 2>/dev/null &

# Signal bars to reload
touch ~/.cache/wallpaper-changed

notify-send "THEME UPDATED" "Wallpaper applied!" -t 1500
