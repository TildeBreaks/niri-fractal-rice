#!/bin/bash
# Pywal post-hook to regenerate Kitty fractal with new theme colors
# Place this in ~/.config/wal/scripts/ and make it executable

echo "Regenerating Kitty fractal with new theme colors..."
~/.config/kitty/generate_fractal.sh &

# Optionally reload Kitty instances
# Uncomment if you want all Kitty windows to reload automatically
# killall -SIGUSR1 kitty 2>/dev/null
