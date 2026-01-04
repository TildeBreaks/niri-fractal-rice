#!/bin/bash
# Caffeine toggle - prevents screen from sleeping
# Uses systemd-inhibit to block idle

INHIBIT_FILE="/tmp/caffeine-inhibit.pid"

if [ -f "$INHIBIT_FILE" ]; then
    # Caffeine is on, turn it off
    PID=$(cat "$INHIBIT_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
    fi
    rm -f "$INHIBIT_FILE"
    notify-send "Caffeine" "Screen sleep enabled" -i caffeine-cup-empty
else
    # Caffeine is off, turn it on
    systemd-inhibit --what=idle --who="Caffeine" --why="User requested" sleep infinity &
    echo $! > "$INHIBIT_FILE"
    notify-send "Caffeine" "Screen sleep disabled" -i caffeine-cup-full
fi
