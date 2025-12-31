#!/bin/bash
# Niri Fractal Rice - Installation Script

set -e

echo "=================================="
echo "Niri Fractal Rice Installer"
echo "=================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "❌ Please do not run this script as root"
    exit 1
fi

# Detect package manager
if command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    echo "📦 Detected: Arch/CachyOS"
elif command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    echo "📦 Detected: Debian/Ubuntu"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    echo "📦 Detected: Fedora"
else
    echo "❌ Unsupported package manager"
    exit 1
fi

echo ""
echo "⚠️  This will install packages and overwrite existing configs!"
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Create backup
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"
echo ""
echo "💾 Creating backup at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
for dir in niri waybar quickshell kitty fastfetch fish; do
    if [ -d ~/.config/$dir ]; then
        cp -r ~/.config/$dir "$BACKUP_DIR/" 2>/dev/null || true
    fi
done
echo "✅ Backup created"

# Install dependencies
echo ""
echo "📥 Installing dependencies..."
# Add appropriate package manager commands here based on PKG_MANAGER

# Copy configurations
echo ""
echo "📋 Installing configurations..."
mkdir -p ~/.config ~/.local/bin

cp -r config/* ~/.config/
cp scripts/* ~/.local/bin/
chmod +x ~/.local/bin/*.sh

echo "✅ Configurations installed"

# Generate initial fractals
echo ""
echo "🎨 Generating initial fractals..."
if [ -x ~/.local/bin/generate-flame.sh ]; then
    ~/.local/bin/generate-flame.sh
fi

echo ""
echo "=================================="
echo "✨ Installation Complete! ✨"
echo "=================================="
echo ""
echo "Next steps:"
echo "1. Log out and select Niri as your session"
echo "2. Set a wallpaper with: wal -i /path/to/image"
echo "3. Enjoy your fractal rice!"
echo ""
echo "Backup location: $BACKUP_DIR"

