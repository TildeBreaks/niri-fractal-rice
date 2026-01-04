#!/bin/bash
# Caffeine status for waybar - Retro Gaming Edition

INHIBIT_FILE="/tmp/caffeine-inhibit.pid"

if [ -f "$INHIBIT_FILE" ]; then
    PID=$(cat "$INHIBIT_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        # Caffeine is active - screen won't sleep
        echo '{"text": "[PWR]", "tooltip": "╔══════════════════════╗\n║ POWER SAVE: OFF     ║\n║ DISPLAY: ACTIVE     ║\n╚══════════════════════╝", "class": "active"}'
        exit 0
    else
        # PID file exists but process is dead
        rm -f "$INHIBIT_FILE"
    fi
fi

# Caffeine is inactive - normal power management
echo '{"text": "[SLP]", "tooltip": "╔══════════════════════╗\n║ POWER SAVE: ON      ║\n║ DISPLAY: AUTO-SLEEP ║\n╚══════════════════════╝", "class": "inactive"}'
