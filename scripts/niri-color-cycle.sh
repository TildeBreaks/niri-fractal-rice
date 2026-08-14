#!/bin/bash
# niri-color-cycle.sh — simple daemon to update niri colors when pywal colors change or wallpaper changes
# Watches ~/.cache/wal/colors.json and ~/.cache/wallpaper-changed and runs update-niri-colors.sh

set -euo pipefail

HOME_DIR="${HOME:-/home/$(whoami)}"
COLORS_JSON="$HOME_DIR/.cache/wal/colors.json"
WALLPAPER_SIGNAL="$HOME_DIR/.cache/wallpaper-changed"
UPDATE_SCRIPT="$HOME_DIR/.local/bin/update-niri-colors.sh"
SLEEP_INTERVAL=6

# If update script is missing, exit gracefully
if [ ! -x "$UPDATE_SCRIPT" ]; then
  echo "niri-color-cycle: update script not found at $UPDATE_SCRIPT — exiting"
  exit 0
fi

# Helper: run an update if colors exist
run_update() {
  if [ -f "$COLORS_JSON" ]; then
    "$UPDATE_SCRIPT" 2>/dev/null || true
  fi
}

# Trap to allow clean exit
trap "echo 'niri-color-cycle: terminating'; exit 0" SIGINT SIGTERM

# Initial run
run_update

# Record initial mtimes
last_colors_mtime=0
if [ -f "$COLORS_JSON" ]; then
  last_colors_mtime=$(stat -c %Y "$COLORS_JSON" 2>/dev/null || echo 0)
fi
last_signal_mtime=0
if [ -f "$WALLPAPER_SIGNAL" ]; then
  last_signal_mtime=$(stat -c %Y "$WALLPAPER_SIGNAL" 2>/dev/null || echo 0)
fi

# Main loop: check for changes and run update when detected
while true; do
  sleep "$SLEEP_INTERVAL"

  if [ -f "$COLORS_JSON" ]; then
    colors_mtime=$(stat -c %Y "$COLORS_JSON" 2>/dev/null || echo 0)
  else
    colors_mtime=0
  fi

  if [ -f "$WALLPAPER_SIGNAL" ]; then
    signal_mtime=$(stat -c %Y "$WALLPAPER_SIGNAL" 2>/dev/null || echo 0)
  else
    signal_mtime=0
  fi

  if [ "$colors_mtime" -gt "$last_colors_mtime" ] || [ "$signal_mtime" -gt "$last_signal_mtime" ]; then
    echo "niri-color-cycle: detected change — updating niri colors"
    run_update
    last_colors_mtime=$colors_mtime
    last_signal_mtime=$signal_mtime
    # Remove the signal file after handling
    [ -f "$WALLPAPER_SIGNAL" ] && rm -f "$WALLPAPER_SIGNAL" || true
  fi

done
