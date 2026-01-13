# Claude Context - Niri Fractal Rice

Quick reference for Claude to understand this project.

## What This Is
A heavily customized Linux rice using Niri (Wayland compositor) with fractal flame wallpapers and pywal theming. All UI components dynamically update colors from the current wallpaper.

## Key Locations
- **Live configs**: `~/.config/quickshell/`, `~/.config/niri/`, `~/.config/fish/`
- **Scripts**: `~/.local/bin/`
- **Repo**: `~/niri-fractal-rice/` (copy files here before committing)

## Quickshell Components
All in `~/.config/quickshell/`:
- `sidebar/shell.qml` - Left sidebar with GPU, FPS, REC, TFX, WAL (wallpaper picker w/ palette selector), media controls
- `topbar/shell.qml` - Top bar with workspaces, time, system tray, **AUD button (audio output/input switcher with tabs)**
- `app-launcher/shell.qml` - App launcher (Mod+D) with RECENT apps section (persists to `recent-apps.json`)
- `wallpaper-picker.qml` - Standalone wallpaper picker (Mod+W)
- `notifications/shell.qml` - Notification center with popup notifications, history, and quick settings (Mod+N to toggle)
- `logout-menu/shell.qml` - Session control menu (Ctrl+Alt+P to toggle) - replaces wlogout
- `display-settings/shell.qml` - Display/monitor settings editor (edits outputs.kdl)
- `keybind-editor/shell.qml` - Keybind editor (edits keybinds.kdl)
- `palette-creator/shell.qml` - **Custom palette creator with color picker (launched from notification center Palette button)**

## Theme System
1. `generate-flame.sh` - Creates fractal wallpaper using flam3, runs pywal
2. `apply-wallpaper.sh` - Applies existing wallpaper, runs pywal
3. Pywal generates colors to `~/.cache/wal/colors.*`
4. Update scripts read pywal and update: niri, waybar, kitty, zen browser, GTK, quickshell

## Key Scripts in `~/.local/bin/`
- `generate-flame.sh [palette]` - Generate fractal wallpaper (optional palette name)
- `apply-wallpaper.sh <path>` - Apply wallpaper and update all themes
- `flam3-palette-util.sh` - List/apply palettes (108 curated + custom palettes from `~/.config/quickshell/custom-palettes.txt`)
- `generate-terminal-logo.sh` - Random ImageMagick pattern for fastfetch
- `update-zen-colors.sh` - Update Zen browser theme from pywal
- `update-niri-colors.sh` - Update Niri borders/focus-ring from pywal
- `startup-theme.sh` - Called at login to initialize theme

## Recent Features Added (Jan 12, 2026)
- **Audio Input/Output Switcher**: Topbar [AUD] button opens popup with OUTPUT/INPUT tabs for switching audio devices
  - Uses `pactl` to list and switch default sinks/sources
  - Scrollable device lists with visual indicators for active device
  - Fixed height window (500px) for consistent UI
- **Palette Creator**: Visual color palette designer accessible from notification center Palette button
  - 8-color palette editor with hex input and preset colors
  - Save custom palettes to `~/.config/quickshell/custom-palettes.txt`
  - Load/Edit/Delete existing palettes
  - Custom palettes automatically appear in wallpaper picker and sidebar palette menus
  - Uses FloatingWindow for proper keyboard input support
- **Custom Palette Integration**: `flam3-palette-util.sh` now loads custom palettes alongside 108 curated options
- **App launcher recent apps**: Tracks 5 most recently launched, shown at top
- **Sidebar palette picker**: PAL button shows all palettes (curated + custom) with color swatches
- **Terminal logo**: 6 random effects (swirl, waves, kaleidoscope, etc.), regenerates each terminal open
- **Zen browser theming**: Auto-updates userChrome.css from pywal

## File Patterns
- Quickshell uses QML with `Process {}` for shell commands
- Colors loaded via `jq` from `~/.cache/wal/colors.json`
- Signal files in `~/.cache/` for cross-component communication (e.g., `wallpaper-changed`)

## Common Tasks
- Edit live config, test, then copy to repo and commit
- Quickshell auto-reloads on file save (usually)
- Test with: `quickshell -c ~/.config/quickshell/sidebar`

## Notification Center & Logout Menu
Locations: `~/.config/quickshell/notifications/` and `~/.config/quickshell/logout-menu/`

### Notification Center (notifications/shell.qml)
**Features:**
- D-Bus NotificationServer for receiving notifications
- Popup notifications (centered at top of screen with slide-in animation)
- Notification center panel (right side, toggle with Mod+N)
- Notification history (up to 50, with working individual close buttons)
- Quick settings grid (WiFi, Sound, Display, Session, Palette, Keybinds)
- Session button launches logout menu
- Pywal theme integration with auto-reload

**Usage:**
- Systemd service: `quickshell-notifications.service`
- Toggle: `touch ~/.cache/notif-center-toggle` or Mod+N keybind
- Can replace mako when ready

### Logout Menu (logout-menu/shell.qml)
**Features:**
- Replaces wlogout with native quickshell implementation
- Centered overlay with 6 actions: Lock, Logout, Suspend, Hibernate, Reboot, Shutdown
- Confirmation dialog for destructive actions (logout, hibernate, reboot, shutdown)
- Lock and Suspend execute immediately
- ESC key or X button to cancel
- Pywal theme integration

**Usage:**
- Systemd service: `quickshell-logout-menu.service`
- Toggle: `touch ~/.cache/logout-menu-toggle` or Ctrl+Alt+P keybind
- Lock uses swaylock, logout uses `niri msg action quit`

### Setup
To enable both components:
```bash
systemctl --user daemon-reload
systemctl --user enable --now quickshell-notifications.service
systemctl --user enable --now quickshell-logout-menu.service
# Can disable mako if notifications work well:
# systemctl --user disable --now mako.service
```

## Niri Config Structure
The niri configuration is modular using the `include` directive (requires niri 25.11+):

- **config.kdl** - Main config file with includes
- **outputs.kdl** - Monitor/display configuration (mode, scale, position)
- **keybinds.kdl** - All keybindings

**Benefits:**
- Easier to edit specific sections without touching main config
- Ready for GUI editors (Display Settings and Keybind Editor)
- Live-reload works on all included files
- Clean separation of concerns

**To edit:**
```bash
# Edit monitors
nano ~/.config/niri/outputs.kdl

# Edit keybinds
nano ~/.config/niri/keybinds.kdl

# Reload config
niri msg action load-config-file
```

## Display Settings & Keybind Editor
Two GUI editors for the modular niri config:

### Display Settings (`display-settings/shell.qml`)
- Launched from notification center Display button
- Text editor for `~/.config/niri/outputs.kdl`
- Save & Apply button saves and reloads niri config
- Toggle: `touch ~/.cache/display-settings-toggle`
- Systemd service: `quickshell-display-settings.service`

### Keybind Editor (`keybind-editor/shell.qml`)
- Launched from notification center Keybinds button
- Text editor for `~/.config/niri/keybinds.kdl`
- Save & Apply button saves and reloads niri config
- Toggle: `touch ~/.cache/keybind-editor-toggle`
- Systemd service: `quickshell-keybind-editor.service`

**Usage:**
```bash
systemctl --user daemon-reload
systemctl --user enable --now quickshell-display-settings.service
systemctl --user enable --now quickshell-keybind-editor.service
```

## Palette Creator (`palette-creator/shell.qml`)
A visual tool for creating custom 8-color palettes for fractal generation.

**Features:**
- 8 color slots arranged in 2x4 grid
- Click any color to open color picker popup with:
  - Hex input field (e.g., `#FF0000`)
  - Large preview box
  - 24 preset colors
  - Live updates across all views
- Palette preview bar showing all 8 colors
- Name input field with save functionality
- Saved palettes list with Load/Delete buttons
- Palettes stored in `~/.config/quickshell/custom-palettes.txt` (format: `name|#color1,#color2,...`)

**Usage:**
- Launched from notification center Palette button
- Command: `quickshell -c ~/.config/quickshell/palette-creator`
- Custom palettes automatically integrate with:
  - Wallpaper picker PAL dropdown
  - Sidebar PAL button menu
  - `generate-flame.sh` palette parameter

**Implementation Notes:**
- Uses `FloatingWindow` (not PanelWindow) for keyboard input support
- Color picker popup is inside main window for proper overlay
- Uses `colorUpdateTrigger` property to force reactive updates on color changes
- Palettes loaded by `flam3-palette-util.sh curated-colors`

### Future Enhancements
- Add notification count badge to topbar
- More advanced keybind editor with visual keybind picker
- Display settings with graphical monitor arrangement
- Palette creator: Add import from image feature
- Palette creator: Add palette preview with actual fractal thumbnail
