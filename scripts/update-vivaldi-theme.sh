#!/bin/bash
# Update Vivaldi theme with pywal colors using Vivaldi's built-in theming

COLORS_JSON="$HOME/.cache/wal/colors.json"

if [ ! -f "$COLORS_JSON" ]; then
    echo "Pywal colors not found"
    exit 1
fi

# Read colors
COLOR_BG=$(jq -r '.special.background' "$COLORS_JSON")
COLOR_FG=$(jq -r '.special.foreground' "$COLORS_JSON")
COLOR0=$(jq -r '.colors.color0' "$COLORS_JSON")
COLOR2=$(jq -r '.colors.color2' "$COLORS_JSON")
COLOR4=$(jq -r '.colors.color4' "$COLORS_JSON")

# Convert hex to RGB
hex_to_rgb() {
    hex=${1#"#"}
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
    echo "$r,$g,$b"
}

BG_RGB=$(hex_to_rgb "$COLOR_BG")
FG_RGB=$(hex_to_rgb "$COLOR_FG")
ACCENT_RGB=$(hex_to_rgb "$COLOR2")
HIGHLIGHT_RGB=$(hex_to_rgb "$COLOR4")

echo "Updating Vivaldi theme..."
echo "  Background: $COLOR_BG ($BG_RGB)"
echo "  Accent: $COLOR2 ($ACCENT_RGB)"

# Find Vivaldi preferences file
VIVALDI_PREFS=$(find ~/.config -path "*/vivaldi*/Default/Preferences" -o -path "*/vivaldi-snapshot/Default/Preferences" 2>/dev/null | head -1)

if [ -z "$VIVALDI_PREFS" ]; then
    echo "✗ Vivaldi preferences not found"
    echo "  Make sure Vivaldi is installed and run it at least once"
    exit 1
fi

echo "Found preferences: $VIVALDI_PREFS"

# Backup preferences
cp "$VIVALDI_PREFS" "$VIVALDI_PREFS.backup"

# Update theme colors in preferences using jq
# Create vivaldi.theme object if it doesn't exist, then update colors
jq --arg bg "$BG_RGB" \
   --arg fg "$FG_RGB" \
   --arg accent "$ACCENT_RGB" \
   --arg highlight "$HIGHLIGHT_RGB" \
   '
   .vivaldi = (.vivaldi // {}) |
   .vivaldi.theme = (.vivaldi.theme // {}) |
   .vivaldi.theme.colors = {
       "accentColor": $accent,
       "backgroundColor": $bg,
       "foregroundColor": $fg,
       "highlightColor": $highlight
   }
   ' "$VIVALDI_PREFS" > "$VIVALDI_PREFS.tmp" && mv "$VIVALDI_PREFS.tmp" "$VIVALDI_PREFS"

echo "✓ Vivaldi theme updated!"
echo "  Restart Vivaldi to see changes"
