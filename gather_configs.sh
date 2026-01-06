#!/bin/bash
# Gathers all necessary configuration files and scripts for the niri-fractal-rice setup.

set -e

# Define source and destination directories
SRC_DIR="$HOME"
DEST_DIR="$(pwd)"

echo "=================================="
echo "Gathering Niri Fractal Rice Files"
echo "=================================="
echo ""

# List of configuration directories to copy (relative to $HOME)
CONFIG_DIRS=(
    ".config/niri"
    ".config/quickshell"
    ".config/kitty"
    ".config/fish"
    ".config/mako"
    ".config/swaylock"
    ".config/fastfetch"
    ".config/wal"
    ".config/gtk-3.0"
    ".config/gtk-4.0"
    ".config/xsettingsd"
)

# List of scripts to copy (relative to $HOME/.local/bin)
SCRIPTS=(
    "audio-switch-retro.sh"
    "audio-switch.sh"
    "caffeine-status-retro.sh"
    "caffeine-status.sh"
    "caffeine-toggle.sh"
    "change-wallpaper"
    "create-gtk-theme.sh"
    "gather-all-files.sh"
    "generate-flame.sh"
    "generate-fractal.py"
    "generate-palette.py"
    "generate-qt-theme.sh"
    "generate-sheep.sh"
    "get-current-wallpaper.sh"
    "launch-sidebar.sh"
    "launch-wallpaper-picker.sh"
    "launch-wlogout.sh"
    "lock-screen.sh"
    "mangohud-status.sh"
    "mangohud-toggle.sh"
    "reload-theme"
    "startup-theme.sh"
    "startup-wallpaper.sh"
    "swayidle-config.sh"
    "system-monitor-retro.sh"
    "tag-and-gather.sh"
    "thunar-themed.sh"
    "toggle-sidebar.sh"
    "update-floorp-theme.sh"
    "update-gtk-colors.sh"
    "update-niri-colors.sh"
    "update-sddm-theme.sh"
    "update-vivaldi-theme.sh"
    "update-wlogout-theme.sh"
    "update-zen-colors.sh"
    "volume-osd-retro.sh"
    "volume-osd.sh"
    "wallpaper-selector.sh"
    "wallpaper-watcher-service.sh"
    "wallpaper-watcher.sh"
)

echo "📋 Copying configuration directories..."

for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$SRC_DIR/$dir" ]; then
        echo "  -> Found $dir"
        # Using rsync to preserve structure and handle contents correctly
        rsync -a --relative "$SRC_DIR/$dir" "$DEST_DIR"
    else
        echo "  -> WARNING: Could not find directory $SRC_DIR/$dir. Skipping."
    fi
done

echo "✅ Configuration directories copied."
echo ""
echo " Copying scripts..."

# Create the target directory for scripts if it doesn't exist
mkdir -p "$DEST_DIR/.local/bin"

for script in "${SCRIPTS[@]}"; do
    if [ -f "$SRC_DIR/.local/bin/$script" ]; then
        echo "  -> Found $script"
        cp "$SRC_DIR/.local/bin/$script" "$DEST_DIR/.local/bin/"
    else
        echo "  -> WARNING: Could not find script $SRC_DIR/.local/bin/$script. Skipping."
    fi
done

echo "✅ Scripts copied."
echo ""
echo "🔑 Copying SDDM helper script..."

# Define the source and destination for the SDDM helper script
SDDM_HELPER_SRC="/usr/local/bin/sddm-update-helper.sh"
SDDM_HELPER_DEST_DIR="$DEST_DIR/sddm"

if [ -f "$SDDM_HELPER_SRC" ]; then
    echo "  -> Found sddm-update-helper.sh"
    mkdir -p "$SDDM_HELPER_DEST_DIR"
    cp "$SDDM_HELPER_SRC" "$SDDM_HELPER_DEST_DIR/"
    echo "✅ SDDM helper script copied."
else
    echo "  -> WARNING: Could not find sddm-update-helper.sh at $SDDM_HELPER_SRC. Skipping."
fi

echo ""
echo "=================================="
echo "✨ File Gathering Complete! ✨"
echo "=================================="
echo "The necessary files have been copied into the '$(basename "$DEST_DIR")' directory."
