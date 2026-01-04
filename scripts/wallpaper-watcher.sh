#!/bin/bash
# Wallpaper change watcher - runs until wallpaper changes

SIGNAL_FILE="$HOME/.cache/wallpaper-changed"
PID_FILE="$HOME/.cache/wallpaper-watcher.pid"

# If already running, exit
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        # Already running
        exit 0
    fi
fi

# Write our PID
echo $$ > "$PID_FILE"

# Watch for signal file
while true; do
    if [ -f "$SIGNAL_FILE" ]; then
        # Signal the sidebar to update
        rm -f "$SIGNAL_FILE"
        
        # Clean up and exit
        rm -f "$PID_FILE"
        exit 0
    fi
    
    sleep 2
done
