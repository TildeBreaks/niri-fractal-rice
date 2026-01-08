#!/bin/bash
# Launch QuickShell Wallpaper Picker

if ! command -v quickshell &> /dev/null; then
    notify-send "ERROR" "QuickShell not installed
Install with: yay -S quickshell-git" -u critical
    exit 1
fi

# QuickShell needs the full path
quickshell -p ~/.config/quickshell/wallpaper-picker.qml
