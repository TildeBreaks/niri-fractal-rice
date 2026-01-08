# Niri Fractal Rice

A complete Wayland desktop rice featuring Niri window manager with dynamic fractal flame wallpapers and themed terminal fractals.

## Features

- 🌀 **Dynamic Fractal Wallpapers**: Generate beautiful fractal flame wallpapers with one click
- 🎨 **Automatic Theming**: Pywal generates color schemes from wallpapers
- 🖼️ **Themed Terminal Fractals**: Kitty terminal displays matching fractals on startup
- ⚡ **Niri Window Manager**: Scrollable tiling with smooth animations
- 🎛️ **Quickshell UI**: Complete QML-based interface (topbar, sidebar, app launcher, wallpaper picker)
- 🔧 **Terminal Effects Widget**: Bottom bar with animated terminal effects
- 📊 **System Monitoring**: Real-time CPU, memory, network stats in topbar

## Preview

[Add screenshots here]

## Requirements

### Core Dependencies
- **niri** - Scrollable tiling window manager
- **quickshell-git** - QML-based desktop shell (AUR)
- **kitty** - GPU-accelerated terminal emulator
- **python-pywal** - Color scheme generator
- **flam3** - Fractal flame generator (AUR)
- **swww** - Wayland wallpaper daemon
- **jq** - JSON processor

### UI Components
- **mako** - Notification daemon
- **swayidle** - Idle management daemon
- **swaylock-effects** - Screen locker

### Utilities
- **brightnessctl** - Brightness control
- **pamixer** - Audio control
- **playerctl** - Media control
- **btop** - System monitor
- **wl-clipboard**, **grim**, **slurp** - Screenshot tools

### Optional (Legacy Alternatives)
- **rofi** - Application launcher (if you prefer it over quickshell app-launcher)
- **waybar** - Status bar (if you prefer it over quickshell topbar)
- **floorp-bin** - Firefox-based browser (AUR)
- **cava**, **cmatrix**, **lolcat** - Terminal animations

For a complete list, see the install script.

## Installation

### Automatic Installation (Recommended)

The install script automatically detects your distribution and installs all dependencies:

```bash
git clone https://github.com/TildeBreaks/niri-fractal-rice
cd niri-fractal-rice
chmod +x install.sh
./install.sh
```

Supported distributions:
- Arch Linux / CachyOS (full support)
- Debian / Ubuntu (experimental)
- Fedora (experimental)

### Manual Installation

If you prefer to install manually or the script doesn't work for your distribution:

1. Install all dependencies listed above
2. Copy configs: `cp -r config/* ~/.config/`
3. Copy scripts: `cp scripts/* ~/.local/bin/ && chmod +x ~/.local/bin/*.sh`
4. Copy systemd services: `cp systemd/*.service ~/.config/systemd/user/`
5. Enable services: `systemctl --user enable quickshell-topbar quickshell-sidebar mako`
6. Generate initial theme: `wal -i /path/to/wallpaper.jpg -a 85`

## Post-Installation

After installation:
1. Log out of your current session
2. Select "Niri" at your login screen
3. Log in and enjoy your fractal rice!

## Directory Structure

```
niri-fractal-rice/
├── config/
│   ├── niri/              # Niri window manager config
│   ├── quickshell/        # Quickshell UI components (PRIMARY UI)
│   │   ├── topbar/        # Top status bar (replaces waybar)
│   │   ├── sidebar/       # Quick settings sidebar
│   │   ├── bottombar/     # Bottom terminal bar
│   │   ├── termfx/        # Terminal effects widget
│   │   ├── app-launcher/  # Application launcher (replaces rofi)
│   │   └── wallpaper-picker.qml  # Wallpaper selection UI
│   ├── waybar/            # [Optional] Legacy waybar config
│   ├── kitty/             # Terminal config and fractal generation
│   ├── wal/               # Pywal hooks for auto-theming
│   └── [other configs]    # Mako, Swaylock, etc.
├── scripts/               # 25+ utility scripts
│   ├── generate-flame.sh          # Generate fractal wallpapers
│   ├── generate-sheep.sh          # Alternative fractal generator
│   ├── update-niri-colors.sh      # Apply colors to niri
│   ├── startup-theme.sh           # Initialize theme on startup
│   ├── toggle-sidebar.sh          # Toggle quickshell sidebar
│   ├── toggle-bottombar.sh        # Toggle bottombar
│   ├── toggle-termfx.sh           # Toggle terminal effects
│   ├── wallpaper-watcher.sh       # Monitor wallpaper changes
│   ├── generate-fractal.py        # Python fractal generator
│   ├── generate-palette.py        # Palette generator
│   └── [theme updaters]           # GTK, Qt, browser themes
├── systemd/               # Systemd user services
│   ├── quickshell-topbar.service
│   └── quickshell-sidebar.service
├── README.md              # This file
└── install.sh             # Automated installation script
```

## Usage

### Key Bindings (Default)

- **Mod+D** - Open quickshell app launcher
- **Mod+Return** - Open Kitty terminal
- **Mod+Q** - Close window
- **Mod+Escape** - Lock screen
- **Mod+Shift+E** - Power menu (logout/shutdown/reboot)

(See ~/.config/niri/config.kdl for complete keybind list)

### Changing Wallpapers

Use the quickshell wallpaper picker or click the RND button to generate a new fractal wallpaper. The theme will automatically update across all UI components.

### Terminal Fractals

Open Kitty terminal to see a themed fractal. Each new terminal shows a different fractal that matches your current color scheme.

### Theme Updates

Themes automatically update when you change wallpapers. All quickshell components (topbar, sidebar, app-launcher), Mako notifications, and terminals adapt to the new color scheme.

## Customization

See [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md) for detailed customization options.

## Credits

- **Niri** - YaLTeR
- **Quickshell** - outfoxxed
- **flam3** - Scott Draves (Electric Sheep)
- **pywal** - dylanaraps
- **Kitty** - Kovid Goyal
- **Fastfetch** - LinusDierheimer
- **Waybar** - Alexays

## License

MIT License

---

Enjoy your fractal-powered rice! 🌀✨
