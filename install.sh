#!/bin/bash
# Niri Fractal Rice - Complete Installation Script
# This script installs all dependencies and configurations for the niri-fractal-rice setup

set -e

echo "=========================================="
echo "   Niri Fractal Rice Complete Installer"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please do not run this script as root"
    exit 1
fi

# Detect package manager and distro
if command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    DISTRO="arch"
    echo "📦 Detected: Arch Linux / CachyOS"
elif command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    DISTRO="debian"
    echo "📦 Detected: Debian / Ubuntu"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    DISTRO="fedora"
    echo "📦 Detected: Fedora"
else
    echo "❌ Unsupported package manager"
    echo "This script supports: pacman (Arch/CachyOS), apt (Debian/Ubuntu), dnf (Fedora)"
    exit 1
fi

echo ""
echo "⚠️  This installer will:"
echo "   • Install 40+ packages and dependencies"
echo "   • Overwrite existing niri/quickshell/kitty configs"
echo "   • Create backups of your current configs"
echo "   • Install scripts to ~/.local/bin"
echo ""
read -p "Continue with installation? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 1
fi

# Ask about optional UI components
echo ""
echo "📋 UI Component Selection"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This setup uses Quickshell for all UI components:"
echo "  • Topbar (status bar with system info and audio switcher)"
echo "  • Sidebar (quick settings and fractal wallpaper generator)"
echo "  • Notifications Center (quick settings and palette creator)"
echo "  • App Launcher (application menu)"
echo "  • Wallpaper Picker (with custom palette support)"
echo "  • Palette Creator (design custom color palettes for fractals)"
echo ""
echo "Legacy alternatives are available:"
echo "  • Waybar (alternative status bar)"
echo "  • Rofi (alternative app launcher)"
echo ""

INSTALL_ROFI="n"
INSTALL_WAYBAR="n"

read -p "Install Rofi as alternative app launcher? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    INSTALL_ROFI="y"
    echo "  ✓ Will install Rofi and configure keybind"
fi

read -p "Install Waybar as alternative status bar? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    INSTALL_WAYBAR="y"
    echo "  ✓ Will install Waybar"
fi

# Create backup
BACKUP_DIR="$HOME/.config-backup-niri-$(date +%Y%m%d_%H%M%S)"
echo ""
echo "💾 Creating backup at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
for dir in niri waybar quickshell kitty fastfetch fish mako rofi swaylock; do
    if [ -d ~/.config/$dir ]; then
        cp -r ~/.config/$dir "$BACKUP_DIR/" 2>/dev/null || true
    fi
done
if [ -d ~/.local/bin ]; then
    mkdir -p "$BACKUP_DIR/bin"
    cp ~/.local/bin/*.sh "$BACKUP_DIR/bin/" 2>/dev/null || true
    cp ~/.local/bin/*.py "$BACKUP_DIR/bin/" 2>/dev/null || true
fi
echo "✅ Backup created"

# Install dependencies based on distro
echo ""
echo "📥 Installing dependencies (this may take a while)..."
echo ""

if [ "$DISTRO" = "arch" ]; then
    # Core dependencies
    CORE_PKGS=(
        niri
        kitty
        python
        python-pip
        python-pillow
        python-numpy
        jq
        bash
    )

    # UI and shell components
    UI_PKGS=(
        mako
        swayidle
        swaylock-effects
        brightnessctl
        pamixer
        playerctl
    )

    # Theming and wallpaper
    THEME_PKGS=(
        python-pywal
        swww
    )

    # File managers and browsers
    APP_PKGS=(
        thunar
        firefox
    )

    # System utilities
    UTIL_PKGS=(
        btop
        wl-clipboard
        grim
        slurp
        libnotify
        pulseaudio
        qt6ct
        polkit-gnome
    )

    # Optional terminal eye-candy
    OPTIONAL_PKGS=(
        cava
        cmatrix
        lolcat
        figlet
        cbonsai
        fortune-mod
    )

    echo "Installing core packages..."
    sudo pacman -S --needed --noconfirm "${CORE_PKGS[@]}"

    echo "Installing UI components..."
    sudo pacman -S --needed --noconfirm "${UI_PKGS[@]}"

    echo "Installing theming tools..."
    sudo pacman -S --needed --noconfirm "${THEME_PKGS[@]}"

    echo "Installing applications..."
    sudo pacman -S --needed --noconfirm "${APP_PKGS[@]}"

    echo "Installing system utilities..."
    sudo pacman -S --needed --noconfirm "${UTIL_PKGS[@]}"

    # AUR packages (if yay is available)
    if command -v yay &> /dev/null; then
        echo "Installing AUR packages..."
        AUR_PKGS=(
            quickshell-git
            flam3
            floorp-bin
        )
        yay -S --needed --noconfirm "${AUR_PKGS[@]}" || echo "⚠️  Some AUR packages failed to install"
    else
        echo ""
        echo "⚠️  YAY AUR helper not found. Please manually install:"
        echo "   • quickshell-git (required for UI)"
        echo "   • flam3 (required for fractal generation)"
        echo "   • floorp-bin (optional browser)"
        echo ""
        echo "Install yay with:"
        echo "   git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
    fi

    # Optional packages
    read -p "Install optional terminal animations (cava, cmatrix, etc.)? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo pacman -S --needed --noconfirm "${OPTIONAL_PKGS[@]}"
    fi

    # Install optional UI alternatives
    if [ "$INSTALL_ROFI" = "y" ]; then
        echo "Installing Rofi..."
        sudo pacman -S --needed --noconfirm rofi
    fi

    if [ "$INSTALL_WAYBAR" = "y" ]; then
        echo "Installing Waybar..."
        sudo pacman -S --needed --noconfirm waybar
    fi

elif [ "$DISTRO" = "debian" ]; then
    echo "⚠️  Debian/Ubuntu support is experimental"
    sudo apt update

    DEBIAN_PKGS=(
        kitty
        python3
        python3-pip
        python3-pil
        python3-numpy
        jq
        mako-notifier
        swayidle
        swaylock
        brightnessctl
        pamixer
        playerctl
        thunar
        firefox-esr
        btop
        wl-clipboard
        grim
        slurp
        libnotify-bin
        pulseaudio
        qt6ct
        polkit-gnome
    )

    sudo apt install -y "${DEBIAN_PKGS[@]}"

    # Install optional UI alternatives
    if [ "$INSTALL_ROFI" = "y" ]; then
        echo "Installing Rofi..."
        sudo apt install -y rofi
    fi

    if [ "$INSTALL_WAYBAR" = "y" ]; then
        echo "Installing Waybar..."
        sudo apt install -y waybar
    fi

    echo ""
    echo "⚠️  Manual installation required for:"
    echo "   • niri (compile from source: https://github.com/YaLTeR/niri)"
    echo "   • quickshell (compile from source: https://github.com/quickshell/quickshell)"
    echo "   • pywal (pip install pywal)"
    echo "   • swww (cargo install swww)"
    echo "   • flam3 (compile from source)"

elif [ "$DISTRO" = "fedora" ]; then
    echo "⚠️  Fedora support is experimental"
    sudo dnf install -y \
        kitty \
        python3 \
        python3-pip \
        python3-pillow \
        python3-numpy \
        jq \
        mako \
        swayidle \
        swaylock \
        brightnessctl \
        pamixer \
        playerctl \
        thunar \
        firefox \
        btop \
        wl-clipboard \
        grim \
        slurp \
        libnotify \
        pulseaudio \
        qt6ct \
        polkit-gnome

    # Install optional UI alternatives
    if [ "$INSTALL_ROFI" = "y" ]; then
        echo "Installing Rofi..."
        sudo dnf install -y rofi
    fi

    if [ "$INSTALL_WAYBAR" = "y" ]; then
        echo "Installing Waybar..."
        sudo dnf install -y waybar
    fi

    echo ""
    echo "⚠️  Manual installation required for:"
    echo "   • niri (compile from source: https://github.com/YaLTeR/niri)"
    echo "   • quickshell (compile from source: https://github.com/quickshell/quickshell)"
    echo "   • pywal (pip install pywal)"
    echo "   • swww (cargo install swww)"
    echo "   • flam3 (compile from source)"
fi

# Install Python packages
echo ""
echo "📦 Installing Python packages..."
pip install --user pywal pillow numpy 2>/dev/null || pip3 install --user pywal pillow numpy

# Create necessary directories
echo ""
echo "📁 Creating directory structure..."
mkdir -p ~/.config
mkdir -p ~/.config/quickshell
mkdir -p ~/.local/bin
mkdir -p ~/Pictures/wallpapers
mkdir -p ~/Pictures/wallpapers/flame
mkdir -p ~/Pictures/wallpapers/sheep
mkdir -p ~/.cache/wal

# Create empty custom palettes file if it doesn't exist
touch ~/.config/quickshell/custom-palettes.txt

# Install configurations
echo ""
echo "📋 Installing configurations..."

# Copy all config files
if [ -d "config" ]; then
    cp -r config/* ~/.config/
    echo "✅ Config files installed"
fi

# Modify niri config if Rofi is selected
if [ "$INSTALL_ROFI" = "y" ]; then
    echo ""
    echo "🔧 Configuring niri to use Rofi for app launcher..."
    if [ -f ~/.config/niri/config.kdl ]; then
        # Replace the quickshell app-launcher keybind with rofi (Mod+D)
        sed -i 's|Mod+D { spawn "quickshell" "-c" "[^"]*app-launcher[^"]*"; }|Mod+D { spawn "rofi" "-show" "drun"; }|g' ~/.config/niri/config.kdl
        echo "  ✓ Niri config updated to use Rofi (Mod+D)"
        echo "  ℹ️  You can switch back to quickshell app-launcher by editing ~/.config/niri/config.kdl"
    fi
fi

# Copy all scripts
if [ -d "scripts" ]; then
    cp scripts/* ~/.local/bin/
    chmod +x ~/.local/bin/*.sh
    chmod +x ~/.local/bin/*.py 2>/dev/null || true
    echo "✅ Scripts installed to ~/.local/bin"
fi

# Install systemd services
if [ -d "systemd" ]; then
    mkdir -p ~/.config/systemd/user
    cp systemd/*.service ~/.config/systemd/user/
    echo "✅ Systemd services installed"
fi

# Set up systemd services
echo ""
echo "🔧 Configuring systemd services..."
systemctl --user daemon-reload
systemctl --user enable quickshell-topbar.service 2>/dev/null || echo "⚠️  quickshell-topbar service not available"
systemctl --user enable quickshell-sidebar.service 2>/dev/null || echo "⚠️  quickshell-sidebar service not available"
systemctl --user enable mako.service 2>/dev/null || echo "⚠️  mako service not available"

# Generate initial theme
echo ""
echo "🎨 Generating initial theme..."

# Check if we have a wallpaper to use
if [ -f ~/Pictures/wallpapers/*.jpg ] || [ -f ~/Pictures/wallpapers/*.png ]; then
    WALLPAPER=$(find ~/Pictures/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | head -1)
    if [ -n "$WALLPAPER" ]; then
        echo "Using existing wallpaper: $WALLPAPER"
        wal -i "$WALLPAPER" -a 85 -q
    fi
else
    echo "📸 No wallpaper found. Generating fractal..."
    if [ -x ~/.local/bin/generate-flame.sh ]; then
        ~/.local/bin/generate-flame.sh
        # Find the generated wallpaper
        WALLPAPER=$(find ~/Pictures/wallpapers -type f -name "*.png" | head -1)
        if [ -n "$WALLPAPER" ]; then
            wal -i "$WALLPAPER" -a 85 -q
        fi
    fi
fi

# Apply initial theme
if [ -x ~/.local/bin/startup-theme.sh ]; then
    ~/.local/bin/startup-theme.sh 2>/dev/null || true
fi

echo ""
echo "=========================================="
echo "✨ Installation Complete! ✨"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Log out of your current session"
echo "2. At the login screen, select 'Niri' as your session"
echo "3. Log in to start using your new setup"
echo ""
echo "Useful commands:"
echo "  • Change wallpaper: wal -i /path/to/image.jpg"
echo "  • Generate fractal: ~/.local/bin/generate-flame.sh"
echo "  • Toggle sidebar: Mod+D (or Super+D)"
echo "  • Launch apps: Mod+R (or Super+R)"
echo "  • Lock screen: Mod+Escape"
echo ""
echo "New features:"
echo "  • Audio Switcher: Click [AUD] in topbar for output/input tabs"
echo "  • Palette Creator: Open notification center → click Palette button"
echo "  • Custom Palettes: Created palettes appear in wallpaper picker"
echo "  • Fractal Generator: Use sidebar [WAL] button or palette selector"
echo ""
echo "Configuration files:"
echo "  • Niri config: ~/.config/niri/config.kdl"
echo "  • Quickshell UI: ~/.config/quickshell/"
echo "  • Scripts: ~/.local/bin/"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
echo "If you encounter issues:"
echo "  1. Check ~/.local/bin scripts have execute permissions"
echo "  2. Verify quickshell is installed (quickshell --version)"
echo "  3. Check systemd services: systemctl --user status quickshell-topbar"
echo "  4. Review niri logs: journalctl --user -u niri"
echo ""
echo "Enjoy your fractal rice! 🌈"
