#!/bin/bash
# [NIRI-FRACTAL-RICE]
# Apply last used wallpaper/theme at startup without regenerating

COLORS_JSON="$HOME/.cache/wal/colors.json"

# Check if we have a cached theme
if [ ! -f "$COLORS_JSON" ]; then
    echo "No cached theme found, generating initial theme..."
    ~/.local/bin/generate-flame.sh
    exit 0
fi

echo "Loading cached theme from last session..."

# Get the last wallpaper
LAST_WALLPAPER=$(jq -r '.wallpaper' "$COLORS_JSON" 2>/dev/null)

if [ -z "$LAST_WALLPAPER" ] || [ ! -f "$LAST_WALLPAPER" ]; then
    # Fallback: find most recent wallpaper
    LAST_WALLPAPER=$(ls -t ~/Pictures/wallpapers/*.png 2>/dev/null | head -1)
fi

if [ -z "$LAST_WALLPAPER" ]; then
    echo "No wallpaper found, generating new one..."
    ~/.local/bin/generate-flame.sh
    exit 0
fi

echo "Applying wallpaper: $LAST_WALLPAPER"

# Apply the wallpaper with swww
swww img "$LAST_WALLPAPER" --transition-type fade --transition-duration 1 --transition-fps 60

# Regenerate all theme files from cached pywal colors (fast, no rendering)
~/.local/bin/generate-qt-theme.sh
~/.local/bin/update-niri-colors.sh
cp ~/.cache/wal/retro.rasi ~/.config/rofi/retro.rasi 2>/dev/null
~/.local/bin/update-floorp-theme.sh 2>/dev/null
~/.local/bin/update-zen-colors.sh 2>/dev/null
~/.local/bin/create-gtk-theme.sh 2>/dev/null
~/.local/bin/update-wlogout-theme.sh 2>/dev/null

# Start color cycling daemon in background
pkill -f "niri-color-cycle.sh" 2>/dev/null
~/.local/bin/niri-color-cycle.sh &

# Mako notifications (keep for now - quickshell notifications still in development)
# TODO: Replace with quickshell notifications once ready
# quickshell -c ~/.config/quickshell/notifications &

echo "✓ Theme loaded from cache!"
