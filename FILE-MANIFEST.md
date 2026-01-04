# File Manifest

## Quickshell Configurations

### Topbar (`~/.config/quickshell/topbar/shell.qml`)
- Multi-monitor support with per-screen workspaces
- System tray with Qt application menu support
- CPU, RAM, temperature, battery monitoring
- Volume control with OSD
- Audio output switcher
- Network status
- Caffeine mode toggle
- Dynamic pywal theming
- Breathing wallpaper background

### Sidebar (`~/.config/quickshell/sidebar/shell.qml`)
- Expandable/collapsible design (60px → 250px)
- Wallpaper picker with thumbnail grid
- Fractal generator integration
- System monitoring widgets
- Audio controls
- FPS/MangoHud toggle
- Performance mode selector (ECO/BAL/MAX)
- Dynamic pywal theming

### Standalone Wallpaper Picker (`~/.config/quickshell/wallpaper-picker.qml`)
- Full-screen wallpaper browser
- Fractal generation with progress indicator
- Grid layout with hover effects
- Auto-applies theme on selection

## Scripts (`~/.local/bin/`)

### Wallpaper & Theming

**generate-flame.sh**
- Generates fractal flames using flam3
- Creates 5 kitty terminal fractals simultaneously
- Applies wallpaper and full system theme
- Resolution: 3440x1440, Quality: 2000, Oversample: 3

**generate-qt-theme.sh**
- Generates Qt5ct and Qt6ct color schemes from pywal
- Creates both color configs and app configs
- Uses Fusion style with custom palette
- Supports active/disabled/inactive states

**update-niri-colors.sh**
- Updates niri config with pywal colors
- Preserves all other niri settings
- Applies colors to borders and UI elements

**wallpaper-watcher.sh**
- On-demand background daemon
- Watches for ~/.cache/wallpaper-changed signal
- Triggers wallpaper reload in sidebar/topbar
- Auto-terminates when picker closes

### System Controls

**toggle-sidebar.sh**
- Toggles quickshell-sidebar service
- Used by niri keybinding

**caffeine-toggle.sh**
- Toggles screen idle inhibit
- Uses systemd-inhibit for sleep prevention

**caffeine-status-retro.sh**
- Returns JSON status for sidebar display
- Format: {"text": "[SLP]", "class": "inactive"}

**mangohud-toggle.sh**
- Toggles MangoHud FPS overlay
- Updates vsync settings in MangoHud config
- Creates ~/.cache/mangohud-enabled flag

**mangohud-status.sh**
- Returns JSON status for FPS widget
- Format: {"enabled": true, "text": "[FPS:ON]"}

## Systemd Services

**quickshell-topbar.service**
```
Description=Quickshell Topbar
PartOf=graphical-session.target
ExecStart=/usr/bin/quickshell -c %h/.config/quickshell/topbar
Restart=on-failure
```

**quickshell-sidebar.service**
```
Description=Quickshell Sidebar
PartOf=graphical-session.target
ExecStart=/usr/bin/quickshell -c %h/.config/quickshell/sidebar
Restart=on-failure
```

## Fish Configuration

**fish_greeting.fish**
- Retro ASCII art banner
- System info display (OS, kernel, uptime, shell)
- Pywal color integration

## Niri Configuration

**config.kdl**
- Window manager settings
- Keybindings for sidebar, wallpaper picker
- Workspace configuration
- Border styling with pywal colors
- Environment variables for Qt theming

## Feature Details

### Multi-Monitor Support
- Per-monitor workspaces (niri native)
- Window titles only show on window's monitor
- System stats only on primary monitor
- Workspaces filtered by output name

### System Tray
- Uses `//@ pragma UseQApplication` for menu support
- Left-click: activate app
- Right-click: show context menu
- Proper menu positioning below icons

### Dynamic Theming
- Pywal generates color scheme from wallpaper
- Qt5ct/Qt6ct themes auto-generated
- Niri colors updated automatically
- All components restart/reload on theme change

### Wallpaper Generation
- Flam3 fractal flames with random genomes
- Parallel kitty fractal generation (5 images)
- Adjustable quality, resolution, oversample
- Automatic theme application

### Performance Optimizations
- Passive monitoring (no constant polling)
- Shared workspace models per-screen
- Efficient process spawning
- Minimal CPU/memory overhead
