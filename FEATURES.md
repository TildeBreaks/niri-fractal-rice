# Features

## Core Features

### 🌀 Dynamic Fractal Wallpapers
- Generate beautiful fractal flame wallpapers with one click (RND button)
- High-quality flam3 rendering with complex variations
- Automatic theme generation from wallpapers using pywal
- Wallpaper history and favorites in Quickshell picker

### 🎨 Automatic Theme Synchronization
- **Waybar**: Status bar updates with new color scheme
- **Rofi**: Application launcher matches theme
- **Mako**: Notifications use theme colors
- **Kitty**: Terminal background and fractals sync
- **GTK Applications**: System-wide GTK theme generation
- **Floorp Browser**: Custom theme updates automatically
- **SDDM Login**: Optional login screen theming

### 🖼️ Themed Terminal Fractals
- Displays unique fractal on each terminal launch
- Fractals use current pywal color palette
- Self-regenerating: each fractal creates a new one in background
- Never see the same fractal twice
- Replaces boring ASCII logos with actual artwork

### ⚡ Niri Window Manager
- Scrollable tiling with smooth animations
- Per-workspace wallpapers
- Gesture support for touchpads
- Efficient Wayland compositor

### 🎯 Quickshell Wallpaper Picker
- Visual grid of wallpapers
- One-click wallpaper selection
- Random fractal generation (RND button)
- Generates themed Kitty fractals automatically
- Integrated with pywal for instant theming

## System Components

### Window Management
- **Niri**: Modern scrollable tiling window manager
- **Waybar**: Customizable status bar with modules
- **Rofi**: Application launcher
- **Mako**: Notification daemon

### Terminal Setup
- **Kitty**: GPU-accelerated terminal with fractal backgrounds
- **Fish**: Modern shell with syntax highlighting
- **Fastfetch**: System info with fractal logo display

### Lock Screen & Power Management
- **Swaylock**: Themed lock screen with pywal colors
- **Swayidle**: Automatic screen locking and power management
- Configurable timeout periods

### Theme Management
- **Pywal**: Generates color schemes from wallpapers
- **Custom Scripts**: Update all applications automatically
- **Template System**: Consistent theming across all apps

## Wallpaper Generation

### Fractal Flame Generation
Uses flam3 (Electric Sheep algorithm) to create:
- Complex, mathematically beautiful patterns
- Smooth color gradients
- Infinite variety through random genomes
- Configurable quality and resolution

### Generation Modes
1. **Quick Generation**: Fast fractals for immediate use
2. **High Quality**: Detailed fractals for wallpapers
3. **Theme-Matched**: Fractals using current color palette

## Power User Features

### Keyboard-Driven Workflow
- Niri keybindings for window management
- Rofi for quick application launching
- Waybar shortcuts for common actions

### Customization Options
- Adjustable fractal quality/render time
- Configurable color scheme application
- Custom keybindings for all actions
- Theme switching without restart

### Integration Points
All theme updates trigger automatically:
- GTK applications
- Qt applications (with patches)
- Terminal emulators
- Notification daemon
- Status bar
- Application launchers
- Login screen (optional)

## Technical Details

### Fractal Generation Pipeline
1. `flam3-genome` generates random flame parameters
2. Pywal colors injected into palette
3. `flam3-render` creates PNG image
4. Image set as wallpaper via `swaybg`
5. Pywal extracts colors and generates themes
6. All update scripts triggered automatically

### Performance Optimizations
- Fractals pre-generated for instant terminal display
- Background regeneration doesn't block UI
- Efficient theme caching
- Minimal overhead from theme updates

### File Locations
```
~/.config/niri/           # Window manager config
~/.config/waybar/         # Status bar
~/.config/kitty/          # Terminal + fractal generation
~/.config/quickshell/     # Wallpaper picker
~/.local/bin/             # Theme update scripts
~/Pictures/wallpapers/    # Generated wallpapers
```

## Automation

### On Boot
- Last wallpaper restored automatically
- All themes reapplied
- Services started (waybar, mako, etc.)

### On Wallpaper Change
- Pywal generates new color scheme
- GTK theme created
- Waybar restarted with new colors
- Rofi theme updated
- Mako reloaded
- 4 new Kitty fractals generated
- Browser theme updated

### On Terminal Open
- Random fractal displayed instantly
- That fractal slot regenerated in background
- System info shown via fastfetch

## Screenshots

[Add screenshots of various features here]

---

For installation and configuration, see the main [README.md](README.md)
