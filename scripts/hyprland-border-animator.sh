#!/bin/bash
# Hyprland Border Animator & Activity Watchdog
# Rotates the active window border and speeds up during busy tasks (downloads, compiles)

COLORS_FILE="$HOME/.cache/wal/colors.json"

# Default colors (will be updated from pywal)
COLOR2="ffffff"
COLOR4="888888"
COLOR3="444444"

# State variables
IS_BUSY=1 # 1 is false in shell return logic for my is_busy check, but let's use 0/1 properly
BUSY_STATE=0
CHECK_INTERVAL=20 # Check for busy status every 20 iterations
ITERATION=0

update_colors() {
    if [[ -f "$COLORS_FILE" ]]; then
        COLOR2=$(jq -r '.colors.color2' "$COLORS_FILE" | sed 's/#//')
        COLOR4=$(jq -r '.colors.color4' "$COLORS_FILE" | sed 's/#//')
        COLOR3=$(jq -r '.colors.color3' "$COLORS_FILE" | sed 's/#//')
    fi
}

check_busy_status() {
    # Check for compile/update processes
    if pgrep -x "pacman|yay|paru|make|gcc|g++|cargo|cmake|ninja|npm|yarn|rustc" > /dev/null; then
        BUSY_STATE=1
        return
    fi

    # Check for browser downloads
    if find "$HOME/Downloads" -maxdepth 1 \( -name "*.part" -o -name "*.crdownload" -o -name "*.wget-hs" -o -name "*.tmp" \) 2>/dev/null | grep -q .; then
        BUSY_STATE=1
        return
    fi

    BUSY_STATE=0
}

angle=0
update_colors
check_busy_status

# Main loop
while true; do
    # Throttle the "is_busy" check to save CPU/IO
    if [ $((ITERATION % CHECK_INTERVAL)) -eq 0 ]; then
        check_busy_status
        # Also refresh colors periodically
        update_colors
    fi
    ITERATION=$((ITERATION + 1))

    # Determine speed/step based on BUSY_STATE
    if [ $BUSY_STATE -eq 1 ]; then
        # Busy mode: Fast rotation
        angle=$(( (angle + 10) % 360 ))
        delay=0.04
    else
        # Idle mode: Slow, smooth rotation
        angle=$(( (angle + 2) % 360 ))
        delay=0.08
    fi

    # Apply the rotating gradient to Hyprland
    hyprctl keyword general:col.active_border "rgba(${COLOR2}ff) rgba(${COLOR4}ff) rgba(${COLOR3}ff) ${angle}deg"

    sleep $delay
done
