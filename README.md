# Niri Fractal Rice 🎮

A retro gaming-themed Wayland rice featuring procedurally generated fractal wallpapers, dynamic pywal theming, and custom Quickshell bars.

![Preview](preview.png)

## Features

- **Procedural Fractal Wallpapers**: Generate unique flame fractals with `flam3`
- **Dynamic Theming**: Pywal integration with automatic Qt5/Qt6 theme generation
- **Custom Quickshell Bars**: 
  - Feature-rich topbar with workspaces, system stats, system tray
  - Expandable sidebar with system controls and wallpaper picker
- **Multi-Monitor Support**: Per-monitor workspaces and window titles
- **Retro Gaming Aesthetic**: Scanlines, borders, monospace fonts, terminal-inspired UI

## Dependencies

```bash
# Core
niri swaybg pywal quickshell

# Fractal generation
flam3

# Qt theming
qt5ct qt6ct

# System utilities
pamixer rofi mako fish kitty
```

## Installation

1. **Install dependencies:**
```bash
yay -S niri swaybg python-pywal quickshell flam3 qt5ct qt6ct pamixer rofi mako fish kitty
```

2. **Copy configuration files:**
```bash
# Quickshell
cp -r quickshell ~/.config/

# Scripts (make executable)
cp scripts/* ~/.local/bin/
chmod +x ~/.local/bin/*.sh

# Systemd services
cp systemd/* ~/.config/systemd/user/

# Fish
cp fish/fish_greeting.fish ~/.config/fish/functions/

# Niri (backup your existing config first!)
cp niri/config.kdl ~/.config/niri/
```

3. **Enable services:**
```bash
systemctl --user enable --now quickshell-topbar.service
systemctl --user enable --now quickshell-sidebar.service
```

4. **Set Qt environment variables in niri config:**

Add to `~/.config/niri/config.kdl`:
```kdl
environment {
    QT_QPA_PLATFORMTHEME "qt6ct"
    QT_STYLE_OVERRIDE "Fusion"
}
```

5. **Generate initial wallpaper:**
```bash
mkdir -p ~/Pictures/wallpapers
~/.local/bin/generate-flame.sh
```

## Usage

### Keybindings (from niri config)

- `Mod+Shift+W`: Toggle sidebar
- `Mod+W`: Open standalone wallpaper picker
- `Mod+1..9`: Switch workspaces
- `Mod+Q`: Close window
- `Mod+T`: Launch terminal (kitty)

### Sidebar Features

- **Wallpaper Picker**: Browse and select wallpapers
- **Generate Random**: Create new fractal wallpaper
- **System Stats**: CPU, RAM, Temperature monitoring
- **Audio Controls**: Volume and output switching
- **Caffeine**: Prevent screen sleep
- **FPS Toggle**: MangoHud overlay control
- **Performance Modes**: ECO/BAL/MAX power profiles

### Topbar Features

- **Clock**: Click to toggle date/time
- **Workspaces**: Per-monitor workspace display
- **Window Title**: Shows focused window (per-monitor)
- **System Stats**: CPU, RAM, Temperature, Battery
- **System Tray**: Full Qt application support with menus
- **Network Status**: Ethernet connection indicator
- **Volume**: OSD with mouse wheel control
- **Audio Output Switcher**: Quick device switching

## File Structure

```
~/.config/
├── quickshell/
│   ├── topbar/shell.qml       # Main topbar
│   ├── sidebar/shell.qml      # Expandable sidebar
│   └── wallpaper-picker.qml   # Standalone picker
├── niri/config.kdl            # Window manager config
├── systemd/user/
│   ├── quickshell-topbar.service
│   └── quickshell-sidebar.service
└── fish/functions/
    └── fish_greeting.fish     # Retro ASCII art

~/.local/bin/
├── generate-flame.sh          # Fractal wallpaper generator
├── generate-qt-theme.sh       # Qt theme from pywal
├── update-niri-colors.sh      # Update niri colors
├── wallpaper-watcher.sh       # Background sync daemon
├── toggle-sidebar.sh          # Sidebar toggle helper
├── caffeine-*.sh             # Screen sleep control
└── mangohud-*.sh             # FPS overlay control
```

## Customization

### Color Schemes

Colors are automatically generated from wallpapers via pywal. To manually set a wallpaper:

```bash
wal -i /path/to/image.png -a 85
~/.local/bin/generate-qt-theme.sh
systemctl --user restart quickshell-topbar.service
```

### Fractal Generation

Edit `~/.local/bin/generate-flame.sh` to change:
- Resolution (default: 3440x1440)
- Quality (default: 2000)
- Oversample (default: 3)

### Topbar Modules

Edit `~/.config/quickshell/topbar/shell.qml` to:
- Hide/show modules (set `visible: false`)
- Adjust update intervals (change `Timer { interval: }`)
- Customize appearance (colors, fonts, borders)

## Troubleshooting

**Qt apps have wrong colors:**
```bash
# Ensure environment variables are set
echo $QT_QPA_PLATFORMTHEME  # should be "qt6ct"

# Regenerate Qt theme
~/.local/bin/generate-qt-theme.sh
```

**System tray menus don't appear:**
- Ensure topbar has `//@ pragma UseQApplication` at the very first line
- Restart topbar: `systemctl --user restart quickshell-topbar.service`

**Workspaces not showing correctly:**
- Niri uses per-monitor workspaces
- Each monitor shows only its own workspaces

**Wallpaper not updating:**
- Check if swaybg is running: `pgrep swaybg`
- Manually set: `swaybg -i ~/Pictures/wallpapers/your-image.png -m fill &`

## Credits

- Niri: Modern scrollable-tiling Wayland compositor
- Quickshell: QML-based Wayland shell framework
- Pywal: Terminal color scheme generator
- Flam3: Fractal flame renderer

## License

MIT License - Feel free to use and modify!
