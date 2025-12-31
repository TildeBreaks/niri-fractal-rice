#!/bin/bash
# Create GTK theme from pywal colors

COLORS_JSON="$HOME/.cache/wal/colors.json"

if [ ! -f "$COLORS_JSON" ]; then
    echo "Pywal colors not found"
    exit 1
fi

# Read colors with jq
COLOR_BG=$(jq -r '.special.background' "$COLORS_JSON")
COLOR_FG=$(jq -r '.special.foreground' "$COLORS_JSON")
COLOR0=$(jq -r '.colors.color0' "$COLORS_JSON")
COLOR1=$(jq -r '.colors.color1' "$COLORS_JSON")
COLOR2=$(jq -r '.colors.color2' "$COLORS_JSON")
COLOR4=$(jq -r '.colors.color4' "$COLORS_JSON")

echo "Creating GTK theme with colors:"
echo "  BG: $COLOR_BG"
echo "  FG: $COLOR_FG"
echo "  Accent: $COLOR4"

# Create theme directories
THEME_DIR="$HOME/.themes/Pywal-Retro"
mkdir -p "$THEME_DIR/gtk-3.0"
mkdir -p "$THEME_DIR/gtk-4.0"

# Create index.theme
cat > "$THEME_DIR/index.theme" << INDEXEOF
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=Pywal-Retro
Comment=Retro theme from pywal
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=Pywal-Retro
IconTheme=Papirus-Dark
INDEXEOF

# Create GTK3 CSS
cat > "$THEME_DIR/gtk-3.0/gtk.css" << CSSEOF
* {
    background-color: $COLOR_BG;
    color: $COLOR_FG;
    border-color: $COLOR2;
}

window {
    background-color: $COLOR_BG;
    color: $COLOR_FG;
}

toolbar, headerbar {
    background-color: $COLOR0;
    color: $COLOR_FG;
    border-bottom: 2px solid $COLOR2;
}

.sidebar {
    background-color: $COLOR0;
    border-right: 2px solid $COLOR2;
}

.sidebar row:selected {
    background-color: $COLOR4;
    color: $COLOR_BG;
}

list, treeview {
    background-color: $COLOR_BG;
    color: $COLOR_FG;
}

list row:selected, treeview:selected {
    background-color: $COLOR4;
    color: $COLOR_BG;
}

entry {
    background-color: $COLOR0;
    color: $COLOR_FG;
    border: 2px solid $COLOR2;
}

button {
    background-color: $COLOR0;
    color: $COLOR_FG;
    border: 2px solid $COLOR2;
}

button:hover {
    background-color: $COLOR2;
}

button:active {
    background-color: $COLOR4;
}

menubar, menu {
    background-color: $COLOR0;
}

menuitem:hover {
    background-color: $COLOR4;
    color: $COLOR_BG;
}

scrollbar slider {
    background-color: $COLOR2;
}
CSSEOF

# Copy to GTK4
cp "$THEME_DIR/gtk-3.0/gtk.css" "$THEME_DIR/gtk-4.0/gtk.css"

# Update GTK settings
mkdir -p "$HOME/.config/gtk-3.0"
cat > "$HOME/.config/gtk-3.0/settings.ini" << SETTINGSEOF
[Settings]
gtk-theme-name=Pywal-Retro
gtk-application-prefer-dark-theme=true
gtk-icon-theme-name=Papirus-Dark
SETTINGSEOF

cp "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini" 2>/dev/null || true

# Update xsettingsd
mkdir -p "$HOME/.config/xsettingsd"
cat > "$HOME/.config/xsettingsd/xsettingsd.conf" << XSETEOF
Net/ThemeName "Pywal-Retro"
Net/IconThemeName "Papirus-Dark"
Xft/Antialias 1
Xft/Hinting 1
XSETEOF

# Reload xsettingsd
if pgrep xsettingsd > /dev/null; then
    pkill -HUP xsettingsd
    echo "✓ xsettingsd reloaded"
fi

echo "✓ GTK theme created successfully!"
