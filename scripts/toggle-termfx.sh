#!/bin/bash
# [NIRI-FRACTAL-RICE]
# Toggle Terminal FX Launcher

TERMFX_PID=$(pgrep -f "quickshell.*termfx")

if [ -n "$TERMFX_PID" ]; then
    # Kill terminal first
    pkill -f "class=termfx" 2>/dev/null
    # Kill launcher
    kill $TERMFX_PID
    notify-send "Term FX" "Closed" -t 1000 -h string:x-canonical-private-synchronous:termfx
else
    quickshell -c ~/.config/quickshell/termfx &
    notify-send "Term FX" "Opened" -t 1000 -h string:x-canonical-private-synchronous:termfx
fi
