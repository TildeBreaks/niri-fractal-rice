#!/bin/bash
# Niri Fractal Rice - Comprehensive Installation Script

set -e

echo "=================================="
echo "Niri Fractal Rice Installer"
echo "=================================="
echo ""

# 1. PRE-FLIGHT CHECKS
# ==================================

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "❌ Please do not run this script as root. It will ask for sudo permission when needed."
    exit 1
fi

# Check for sudo
if ! command -v sudo &> /dev/null; then
    echo "❌ 'sudo' command not found. Please install it first."
    exit 1
fi

# Check for pacman
if ! command -v pacman &> /dev/null; then
    echo "❌ This script is designed for Arch-based systems using pacman. Aborting."
    exit 1
fi

echo "✅ Pre-flight checks passed."
echo ""
echo "⚠️  This script will install numerous packages and overwrite existing"
echo "   configuration files in your home directory."
echo ""
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "🛑 Installation aborted."
    exit 1
fi

# 2. BACKUP EXISTING CONFIGS
# ==================================
BACKUP_DIR="$HOME/.config-backup-niri-fractal-$(date +%Y%m%d_%H%M%S)"
echo ""
echo "💾 Creating backup of existing configs at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
CONFIG_TO_BACKUP=(
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
    ".local/bin"
)
for item in "${CONFIG_TO_BACKUP[@]}"; do
    if [ -e "$HOME/$item" ]; then
        # Ensure the target directory exists in the backup folder
        mkdir -p "$(dirname "$BACKUP_DIR/$item")"
        cp -r "$HOME/$item" "$BACKUP_DIR/$item" 2>/dev/null || true
    fi
done
echo "✅ Backup complete."

# 3. PACKAGE INSTALLATION
# ==================================
echo ""
echo "📥 Installing dependencies with pacman..."

# It's highly recommended to review this list and adjust to your needs.
PACKAGES=(
    # --- Core Components ---
    "niri"
    "sddm"
    "kitty"
    "fish"
    # --- Theming & Visuals ---
    "python-pywal"
    "swww"
    "flam3"
    "electricsheep"
    "fastfetch"
    # --- UI & Utilities ---
    "mako"              # Notification daemon
    "swaylock"
    "swayidle"
    "thunar"            # File manager
    "floorp"            # Browser
    "pamixer"           # Audio control
    "jq"                # JSON processor for scripts
    "wlogout"           # Logout menu
    "mangohud"          # OSD for gaming
    "xsettingsd"        # For GTK themeing in Wayland
    # --- GTK & QT Theming ---
    "gtk3"
    "gtk4"

    "qt5-graphicaleffects"
    "qt5-quickcontrols2"
    "qt6-declarative"   # General QT6 dependency for quickshell
    # Add any other specific qt5/qt6 packages if needed
)

sudo pacman -Syu --needed --noconfirm "${PACKAGES[@]}"
echo "✅ Package installation complete."


# 4. FILE DEPLOYMENT
# ==================================
echo ""
echo "📋 Copying configuration files and scripts..."

# Copy .config files
rsync -a .config/ "$HOME/.config/"

# Copy .local/bin scripts
mkdir -p "$HOME/.local/bin"
rsync -a .local/bin/ "$HOME/.local/bin/"

# Make all scripts in .local/bin executable
echo "🔐 Setting permissions for scripts..."
chmod +x "$HOME/.local/bin/"*

# Handle the SDDM helper script which needs root permissions
if [ -f "sddm/sddm-update-helper.sh" ]; then
    echo "🔑 Installing SDDM helper script to /usr/local/bin..."
    sudo cp "sddm/sddm-update-helper.sh" "/usr/local/bin/sddm-update-helper.sh"
    sudo chmod +x "/usr/local/bin/sddm-update-helper.sh"
else
    echo "⚠️  Could not find sddm/sddm-update-helper.sh, skipping."
fi

echo "✅ File deployment complete."


# 5. SYSTEMD SERVICES
# ==================================
echo ""
echo "⚙️  Setting up systemd user services..."
mkdir -p "$HOME/.config/systemd/user"

# Mako notification service is often started by the WM, but we can ensure it's enabled.
# Note: You might need a `mako.service` file if it's not provided by the package.
# This is a placeholder; many configs start mako directly.
# systemctl --user enable mako.service --now

# Wallpaper Watcher Service
# Create the service file
cat > "$HOME/.config/systemd/user/wallpaper-watcher.service" << EOF
[Unit]
Description=Watches for wallpaper changes to update themes
After=graphical-session.target

[Service]
Type=simple
ExecStart=$HOME/.local/bin/wallpaper-watcher.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=graphical-session.target
EOF

echo "  -> Enabling wallpaper-watcher service..."
systemctl --user daemon-reload
systemctl --user enable --now wallpaper-watcher.service

# Quickshell services are typically managed by niri itself when it starts.
# No extra service setup should be needed if niri's config is correct.
echo "  -> Quickshell services will be managed by Niri."

echo "✅ Systemd setup complete."

# 6. FINAL STEPS
# ==================================
echo ""
echo "=================================="
echo "✨ Installation Complete! ✨"
echo "=================================="
echo ""
echo "Next steps:"
echo "1. Log out and select 'Niri' from your login manager (SDDM)."
echo "2. If themes or colors look wrong, try running:"
echo "   'wal -i /path/to/your/favorite/wallpaper.png'"
echo "3. Review the backup of your old configs in: $BACKUP_DIR"
echo ""
echo "Enjoy your new Fractal Rice!"
