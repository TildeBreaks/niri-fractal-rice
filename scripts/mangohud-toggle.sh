#!/bin/bash
# [NIRI-FRACTAL-RICE]
# MangoHud Toggle Script for Quickshell Sidebar

CONFIG_FILE="$HOME/.config/MangoHud/MangoHud.conf"
ENABLED_FILE="$HOME/.cache/mangohud-enabled"

# Create config directory if it doesn't exist
mkdir -p "$HOME/.config/MangoHud"

# Check current state
if [ -f "$ENABLED_FILE" ]; then
    # MangoHud is enabled, disable it
    rm "$ENABLED_FILE"
    
    # Set vsync to 0 (disabled) in MangoHud config
    if [ -f "$CONFIG_FILE" ]; then
        sed -i 's/^vsync=.*/vsync=0/' "$CONFIG_FILE"
    else
        echo "vsync=0" > "$CONFIG_FILE"
    fi
    
    echo '{"enabled":false,"text":"[FPS:OFF]","class":"inactive"}'
else
    # MangoHud is disabled, enable it
    touch "$ENABLED_FILE"
    
    # Set vsync to 3 (adaptive) in MangoHud config
    if [ -f "$CONFIG_FILE" ]; then
        sed -i 's/^vsync=.*/vsync=3/' "$CONFIG_FILE"
    else
        echo "vsync=3" > "$CONFIG_FILE"
    fi
    
    echo '{"enabled":true,"text":"[FPS:ON]","class":"active"}'
fi
