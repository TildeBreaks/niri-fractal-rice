#!/bin/bash
# MangoHud Status Script for Quickshell Sidebar

ENABLED_FILE="$HOME/.cache/mangohud-enabled"

if [ -f "$ENABLED_FILE" ]; then
    echo '{"enabled":true,"text":"[FPS:ON]","class":"active"}'
else
    echo '{"enabled":false,"text":"[FPS:OFF]","class":"inactive"}'
fi
