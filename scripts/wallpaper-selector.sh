#!/bin/bash
# Wallpaper Selector using Wofi (Wayland-native)

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Check if wofi is installed
if ! command -v wofi &> /dev/null; then
    notify-send "INSTALL REQUIRED" "sudo pacman -S wofi" -u critical
    exit 1
fi

cd "$WALLPAPER_DIR" || exit 1

# Create entries with just images (no text)
OPTIONS=""
INDEX=0
declare -a IMAGE_MAP
for img in *.jpg *.jpeg *.png *.JPG *.JPEG *.PNG; do
    [ -f "$img" ] || continue
    IMAGE_MAP[$INDEX]="$img"
    OPTIONS="${OPTIONS}img:${WALLPAPER_DIR}/${img}:text:${INDEX}\n"
    INDEX=$((INDEX + 1))
done

# Show wofi with images and retro styling
SELECTED_INDEX=$(echo -en "$OPTIONS" | wofi \
    --show dmenu \
    --prompt ">> WALLPAPER >>" \
    --width 1400 \
    --height 900 \
    --allow-images \
    --allow-markup \
    --image-size 300 \
    --columns 4 \
    --lines 8 \
    --insensitive \
    --style ~/.config/wofi/style.css \
    --cache-file /dev/null | awk -F':text:' '{print $2}')

[ -z "$SELECTED_INDEX" ] && exit 0

SELECTED="${IMAGE_MAP[$SELECTED_INDEX]}"

# Apply pywal colors
wal -i "$WALLPAPER_DIR/$SELECTED" -a 85 -q

# Update all theme components
~/.local/bin/update-niri-colors.sh 2>/dev/null
~/.local/bin/generate-qt-theme.sh 2>/dev/null
~/.local/bin/generate-terminal-logo.sh 2>/dev/null
sleep 1
cp ~/.cache/wal/retro.rasi ~/.config/rofi/retro.rasi 2>/dev/null
cp ~/.cache/wal/mako-config ~/.config/mako/config 2>/dev/null
~/.local/bin/update-floorp-theme.sh 2>/dev/null
~/.local/bin/create-gtk-theme.sh 2>/dev/null
~/.local/bin/update-sddm-theme.sh 2>/dev/null
~/.local/bin/update-wlogout-theme.sh 2>/dev/null
killall mako 2>/dev/null
sleep 0.3
killall thunar 2>/dev/null &

# Apply wallpaper with swww (consistent with QuickShell)
swww img "$WALLPAPER_DIR/$SELECTED" --transition-type fade --transition-duration 2 --transition-fps 60

# Restart mako
systemctl --user start mako.service 2>/dev/null

# Signal QuickShell bars to reload
touch ~/.cache/wallpaper-changed

notify-send "DONE" "Theme updated" -t 1500
