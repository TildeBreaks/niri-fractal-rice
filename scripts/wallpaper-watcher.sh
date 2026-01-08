#!/bin/bash
# [NIRI-FRACTAL-RICE]
# Wallpaper change watcher - runs until wallpaper changes
# Updates BOTH topbar and sidebar when any wallpaper change is detected

SIGNAL_FILE="$HOME/.cache/wallpaper-changed"
PID_FILE="$HOME/.cache/wallpaper-watcher.pid"

# If already running, just exit (let the existing watcher continue)
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        # Already running, exit silently
        exit 0
    fi
fi

# Write our PID
echo $$ > "$PID_FILE"

# Watch for signal file
while true; do
    if [ -f "$SIGNAL_FILE" ]; then
        # Signal BOTH bars to update
        touch "$HOME/.cache/topbar-reload-wallpaper"
        touch "$HOME/.cache/sidebar-reload-wallpaper"
        
        # Remove the main signal file
        rm -f "$SIGNAL_FILE"
        
        # Clean up PID and exit
        rm -f "$PID_FILE"
        exit 0
    fi
    sleep 1
done
