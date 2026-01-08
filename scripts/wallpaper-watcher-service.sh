#!/bin/bash
# [NIRI-FRACTAL-RICE]
# On-demand wallpaper watcher service
# Started by pickers, exits after detecting change

SIGNAL_FILE="$HOME/.cache/wallpaper-changed"
TIMEOUT=120  # Exit after 2 minutes if no change detected

echo "[wallpaper-watcher] Started, waiting for wallpaper change..."

count=0
while [ $count -lt $TIMEOUT ]; do
    if [ -f "$SIGNAL_FILE" ]; then
        echo "[wallpaper-watcher] Detected wallpaper change signal"
        
        # Signal BOTH bars to update
        touch "$HOME/.cache/topbar-reload-wallpaper"
        touch "$HOME/.cache/sidebar-reload-wallpaper"
        
        echo "[wallpaper-watcher] Created reload signals for topbar and sidebar"
        
        # Remove the main signal file
        rm -f "$SIGNAL_FILE"
        
        echo "[wallpaper-watcher] Done, exiting"
        exit 0
    fi
    sleep 0.5
    count=$((count + 1))
done

echo "[wallpaper-watcher] Timeout reached, exiting"
exit 0
