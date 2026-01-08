#!/bin/bash
# [NIRI-FRACTAL-RICE]
# Toggle Quickshell Bottom Bar (Terminal Animations)

BOTTOMBAR_PID=$(pgrep -f "quickshell.*bottombar")

if [ -n "$BOTTOMBAR_PID" ]; then
    # Kill any spawned terminals first
    pkill -f "bottombar-term" 2>/dev/null
    # Kill the bar
    kill $BOTTOMBAR_PID
    notify-send "Terminal Bar" "Hidden" -t 1000 -h string:x-canonical-private-synchronous:bottombar
else
    quickshell -c ~/.config/quickshell/bottombar &
    notify-send "Terminal Bar" "Shown" -t 1000 -h string:x-canonical-private-synchronous:bottombar
fi
