#!/bin/bash
# Toggle Quickshell Sidebar

SIDEBAR_PID=$(pgrep -f "quickshell.*sidebar")

if [ -n "$SIDEBAR_PID" ]; then
    # Sidebar is running, kill it
    kill $SIDEBAR_PID
    notify-send "Sidebar" "Hidden" -t 1000
else
    # Sidebar not running, start it
    quickshell -c ~/.config/quickshell/sidebar &
    notify-send "Sidebar" "Shown" -t 1000
fi
