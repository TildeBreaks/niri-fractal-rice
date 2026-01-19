#!/bin/bash
# hypringmyborder-watchdog.sh
# Monitors system activity and updates hypringmyborder configuration/speed

# Configuration - update these paths as needed for your system
CONFIG_PATH="$HOME/.config/hypringmyborder/config.json"
HYPRING_BIN="hypringmyborder"

# Speed values (adjust these to your preference)
IDLE_FPS=10
IDLE_STEP=0.01
BUSY_FPS=30
BUSY_STEP=0.03

# Current state
BUSY_STATE=0
CHECK_INTERVAL=2 # Check every 2 seconds

is_busy() {
    # Check for compile/update processes
    if pgrep -x "pacman|yay|paru|make|gcc|g++|cargo|cmake|ninja|npm|yarn|rustc" > /dev/null; then
        return 0
    fi

    # Check for browser downloads
    if find "$HOME/Downloads" -maxdepth 1 \( -name "*.part" -o -name "*.crdownload" -o -name "*.wget-hs" -o -name "*.tmp" \) 2>/dev/null | grep -q .; then
        return 0
    fi

    return 1
}

# Function to update hypringmyborder settings
# Note: Since I don't have the exact JSON format, this is a placeholder
# for your local agent to finalize.
update_hypring_config() {
    local fps=$1
    local step=$2

    # Example JSON update if it's a simple flat structure:
    # jq ".fps = $fps | .hue_step = $step" "$CONFIG_PATH" > "${CONFIG_PATH}.tmp" && mv "${CONFIG_PATH}.tmp" "$CONFIG_PATH"

    # If hypringmyborder doesn't auto-reload, we might need to restart it
    pkill -x "$HYPRING_BIN"
    $HYPRING_BIN &
}

# Initial start
$HYPRING_BIN &

while true; do
    if is_busy; then
        if [ $BUSY_STATE -eq 0 ]; then
            echo "🔥 System busy, speeding up borders..."
            update_hypring_config $BUSY_FPS $BUSY_STEP
            BUSY_STATE=1
        fi
    else
        if [ $BUSY_STATE -eq 1 ]; then
            echo "🍃 System idle, slowing down borders..."
            update_hypring_config $IDLE_FPS $IDLE_STEP
            BUSY_STATE=0
        fi
    fi

    sleep $CHECK_INTERVAL
done
