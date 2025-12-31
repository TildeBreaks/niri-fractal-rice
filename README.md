# Niri Fractal Rice

A complete Wayland desktop rice featuring Niri window manager with dynamic fractal flame wallpapers and themed terminal fractals.

## Features

- 🌀 **Dynamic Fractal Wallpapers**: Generate beautiful fractal flame wallpapers with one click
- 🎨 **Automatic Theming**: Pywal generates color schemes from wallpapers
- 🖼️ **Themed Terminal Fractals**: Kitty terminal displays matching fractals on startup
- ⚡ **Niri Window Manager**: Scrollable tiling with smooth animations
- 🎯 **Quickshell Wallpaper Picker**: Visual wallpaper selector with random generation
- 📊 **Waybar**: Customized status bar with theme integration
- 🐟 **Fish Shell**: Modern shell with fractal greeting

## Preview

[Add screenshots here]

## Requirements

- Niri (window manager)
- Waybar (status bar)
- Quickshell (wallpaper picker widget)
- Kitty (terminal)
- Fastfetch (system info)
- Fish (shell)
- Pywal (color scheme generator)
- flam3 (fractal generator)
- Python 3 with PIL and NumPy

## Installation

See [INSTALL.md](docs/INSTALL.md) for detailed installation instructions.

Quick start:
```bash
git clone https://github.com/yourusername/niri-fractal-rice
cd niri-fractal-rice
chmod +x install.sh
./install.sh
```

## Directory Structure

```
niri-fractal-rice/
├── config/
│   ├── niri/              # Niri window manager config
│   ├── waybar/            # Waybar configuration and styling
│   ├── quickshell/        # Wallpaper picker widget
│   ├── kitty/             # Terminal config and fractal generation
│   ├── fastfetch/         # System info display
│   ├── fish/              # Shell configuration
│   ├── wal/               # Pywal hooks
│   ├── rofi/              # Application launcher theme
│   └── mako/              # Notification daemon config
├── scripts/               # Utility scripts
│   ├── generate-flame.sh
│   ├── update-niri-colors.sh
│   ├── update-floorp-theme.sh
│   ├── create-gtk-theme.sh
│   └── update-sddm-theme.sh
├── docs/                  # Documentation
└── install.sh             # Installation script
```

## Usage

### Changing Wallpapers

Use the Quickshell wallpaper picker or click the RND button to generate a new fractal wallpaper.

### Terminal Fractals

Open Kitty terminal to see a themed fractal. Each new terminal shows a different fractal that matches your current color scheme.

### Theme Updates

Themes automatically update when you change wallpapers. All applications (Waybar, Rofi, Mako, terminals, etc.) will adapt to the new color scheme.

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
