#!/bin/bash
# Launch Quickshell Sidebar

# Kill any existing sidebar instances
killall -q quickshell-sidebar 2>/dev/null

# Wait for processes to die
sleep 0.5

# Launch sidebar
quickshell -c ~/.config/quickshell/sidebar.qml &

echo "Sidebar launched"
echo "Toggle with Super+B (add to niri config)"
