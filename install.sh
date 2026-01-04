#!/bin/bash
# Niri Fractal Rice Installer

set -e

echo "🎮 Installing Niri Fractal Rice..."

# Check for required commands
echo "Checking dependencies..."
commands=("niri" "swaybg" "wal" "quickshell" "flam3" "qt5ct" "qt6ct")
missing=()

for cmd in "${commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        missing+=("$cmd")
    fi
done

if [ ${#missing[@]} -gt 0 ]; then
    echo "❌ Missing dependencies: ${missing[*]}"
    echo "Install with: yay -S ${missing[*]}"
    exit 1
fi

echo "✅ All dependencies found"

# Backup existing configs
echo "Creating backups..."
timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir="$HOME/.config-backup-$timestamp"
mkdir -p "$backup_dir"

[ -d "$HOME/.config/quickshell" ] && cp -r "$HOME/.config/quickshell" "$backup_dir/"
[ -d "$HOME/.config/niri" ] && cp -r "$HOME/.config/niri" "$backup_dir/"
[ -d "$HOME/.config/systemd/user" ] && cp "$HOME/.config/systemd/user"/quickshell*.service "$backup_dir/" 2>/dev/null || true

echo "📁 Installing configuration files..."

# Create directories
mkdir -p ~/.config/quickshell/topbar
mkdir -p ~/.config/quickshell/sidebar
mkdir -p ~/.config/systemd/user
mkdir -p ~/.config/fish/functions
mkdir -p ~/.local/bin
mkdir -p ~/Pictures/wallpapers

# Copy files
cp -r quickshell/* ~/.config/quickshell/
cp scripts/* ~/.local/bin/
chmod +x ~/.local/bin/*.sh
cp systemd/* ~/.config/systemd/user/
cp fish/* ~/.config/fish/functions/

echo "⚙️  Configuring services..."
systemctl --user daemon-reload
systemctl --user enable quickshell-topbar.service
systemctl --user enable quickshell-sidebar.service

echo ""
echo "⚠️  MANUAL STEPS REQUIRED:"
echo ""
echo "1. Add to ~/.config/niri/config.kdl (in environment section):"
echo "   environment {"
echo "       QT_QPA_PLATFORMTHEME \"qt6ct\""
echo "       QT_STYLE_OVERRIDE \"Fusion\""
echo "   }"
echo ""
echo "2. Restart niri or reload config: niri msg action reload-config"
echo ""
echo "3. Generate initial wallpaper:"
echo "   ~/.local/bin/generate-flame.sh"
echo ""
echo "4. Start services:"
echo "   systemctl --user start quickshell-topbar.service"
echo "   systemctl --user start quickshell-sidebar.service"
echo ""
echo "✅ Installation complete! Backup saved to: $backup_dir"
