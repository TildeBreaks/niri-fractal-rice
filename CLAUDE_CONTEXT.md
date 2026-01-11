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

**Current state - DO NOT replace mako yet, still testing**

**What's done:**
- NotificationServer receiving D-Bus notifications
- Notification center panel (right side, toggle via `~/.cache/notif-center-toggle`)
- Quick settings grid (WiFi, Sound work; others are placeholders)
- Notification history (up to 50)
- Pywal theme integration

**Issues to fix:**
1. **Big gap** between topbar and notification center top - reduce margin
2. **Popup notifications** should be CENTERED on screen, not right-aligned
3. **Notification center panel** should stay on RIGHT (this is correct)
4. **Display button** - placeholder, opens niri config in terminal (useless)
5. **Keybind button** - placeholder, opens niri config in terminal (useless)

**Future features needed:**
- Display settings GUI (quickshell window to modify monitor settings in niri config)
- Keybind editor GUI (quickshell window to view/add/edit keybinds)
- May need to modularize/source out niri config sections to make parsing easier
- Add notification button to topbar with count badge

**To test (keep mako running normally, only kill for testing):**
```bash
pkill mako
quickshell -c ~/.config/quickshell/notifications &
notify-send "Test" "Hello world"
touch ~/.cache/notif-center-toggle  # toggle center
# When done testing, restart mako or just reboot
```

## NEXT SESSION TODO:
1. Fix notification popup centering (need FloatingWindow or different approach)
2. Reduce gap between topbar and notification center (currently top: 95, try 50)
3. Plan Display/Keybind settings GUI approach
4. Consider splitting niri config into includable sections
