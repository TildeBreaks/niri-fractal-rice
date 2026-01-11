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
- `topbar/shell.qml` - Top bar with workspaces, time, system tray
- `app-launcher/shell.qml` - App launcher (Mod+D) with RECENT apps section (persists to `recent-apps.json`)
- `wallpaper-picker.qml` - Standalone wallpaper picker (Mod+W)

## Theme System
1. `generate-flame.sh` - Creates fractal wallpaper using flam3, runs pywal
2. `apply-wallpaper.sh` - Applies existing wallpaper, runs pywal
3. Pywal generates colors to `~/.cache/wal/colors.*`
4. Update scripts read pywal and update: niri, waybar, kitty, zen browser, GTK, quickshell

## Key Scripts in `~/.local/bin/`
- `generate-flame.sh [palette]` - Generate fractal wallpaper (optional palette name)
- `apply-wallpaper.sh <path>` - Apply wallpaper and update all themes
- `flam3-palette-util.sh` - List/apply palettes (108 curated options)
- `generate-terminal-logo.sh` - Random ImageMagick pattern for fastfetch
- `update-zen-colors.sh` - Update Zen browser theme from pywal
- `update-niri-colors.sh` - Update Niri borders/focus-ring from pywal
- `startup-theme.sh` - Called at login to initialize theme

## Recent Features Added
- **App launcher recent apps**: Tracks 5 most recently launched, shown at top
- **Sidebar palette picker**: PAL button shows 108 palettes with color swatches
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

## IN PROGRESS: Notification Center
Location: `~/.config/quickshell/notifications/shell.qml`

**What's done:**
- NotificationServer receiving D-Bus notifications
- Popup notifications (centered, below topbar)
- Notification center panel (centered, toggle via `~/.cache/notif-center-toggle`)
- Quick settings grid (WiFi, Sound, Display, Power, Theme, Settings)
- Notification history (up to 50)
- Pywal theme integration

**Still needed:**
- Add notification button to topbar (`~/.config/quickshell/topbar/shell.qml`) that:
  - Shows notification count badge
  - Clicks to toggle notification center (touch `~/.cache/notif-center-toggle`)
- Test thoroughly with mako stopped (`pkill mako`)
- Once working, integrate into startup (replace mako)

**To test:**
```bash
pkill mako
quickshell -c ~/.config/quickshell/notifications &
notify-send "Test" "Hello world"
touch ~/.cache/notif-center-toggle  # toggle center
```
