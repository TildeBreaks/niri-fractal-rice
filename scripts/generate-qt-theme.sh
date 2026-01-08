#!/bin/bash
# [NIRI-FRACTAL-RICE]
# Generate Qt5/Qt6 color scheme from pywal colors

# Source pywal colors
source ~/.cache/wal/colors.sh

# Convert hex to Qt format (#aarrggbb - fully opaque)
to_qt() {
    echo "#ff${1#\#}"
}

# Generate color arrays
BG=$(to_qt "$color0")
FG=$(to_qt "$color7")
BASE=$(to_qt "$color0")
ALT_BASE=$(to_qt "$color8")
BUTTON=$(to_qt "$color1")
BUTTON_TEXT=$(to_qt "$color7")
HIGHLIGHT=$(to_qt "$color4")
HIGHLIGHT_TEXT=$(to_qt "$color0")
LINK=$(to_qt "$color4")
LINK_VISITED=$(to_qt "$color5")

# The 21 colors are:
# 0: WindowText, 1: Button, 2: Light, 3: Midlight, 4: Dark, 5: Mid,
# 6: Text, 7: BrightText, 8: ButtonText, 9: Base, 10: Window,
# 11: Shadow, 12: Highlight, 13: HighlightedText, 14: Link, 15: LinkVisited,
# 16: AlternateBase, 17: NoRole, 18: ToolTipBase, 19: ToolTipText, 20: PlaceholderText

# Active colors (normal state)
ACTIVE="${FG}, ${BUTTON}, $(to_qt "$color6"), $(to_qt "$color5"), $(to_qt "$color2"), $(to_qt "$color3"), ${FG}, ${FG}, ${BUTTON_TEXT}, ${BASE}, ${BG}, $(to_qt "$color0"), ${HIGHLIGHT}, ${HIGHLIGHT_TEXT}, ${LINK}, ${LINK_VISITED}, ${ALT_BASE}, ${FG}, $(to_qt "$color1"), ${FG}, #80${color7#\#}"

# Disabled colors (grayed out)
DISABLED_FG=$(to_qt "$color8")
DISABLED="${DISABLED_FG}, ${BUTTON}, $(to_qt "$color6"), $(to_qt "$color5"), $(to_qt "$color2"), $(to_qt "$color3"), ${DISABLED_FG}, ${FG}, ${DISABLED_FG}, ${BASE}, ${BG}, $(to_qt "$color0"), ${HIGHLIGHT}, ${DISABLED_FG}, ${LINK}, ${LINK_VISITED}, ${ALT_BASE}, ${FG}, $(to_qt "$color1"), ${FG}, #80${color8#\#}"

# Inactive colors (window not focused)
INACTIVE="${FG}, ${BUTTON}, $(to_qt "$color6"), $(to_qt "$color5"), $(to_qt "$color2"), $(to_qt "$color3"), ${FG}, ${FG}, ${BUTTON_TEXT}, ${BASE}, ${BG}, $(to_qt "$color0"), ${HIGHLIGHT}, ${HIGHLIGHT_TEXT}, ${LINK}, ${LINK_VISITED}, ${ALT_BASE}, ${FG}, $(to_qt "$color1"), ${FG}, #80${color7#\#}"

# Create Qt5 theme
mkdir -p ~/.config/qt5ct/colors
cat > ~/.config/qt5ct/colors/pywal.conf << EOF
[ColorScheme]
active_colors=${ACTIVE}
disabled_colors=${DISABLED}
inactive_colors=${INACTIVE}
EOF

# Create Qt6 theme
mkdir -p ~/.config/qt6ct/colors
cat > ~/.config/qt6ct/colors/pywal.conf << EOF
[ColorScheme]
active_colors=${ACTIVE}
disabled_colors=${DISABLED}
inactive_colors=${INACTIVE}
EOF

# Create Qt5ct config
cat > ~/.config/qt5ct/qt5ct.conf << 'CFGEOF'
[Appearance]
color_scheme_path=~/.config/qt5ct/colors/pywal.conf
custom_palette=true
icon_theme=breeze-dark
standard_dialogs=default
style=Fusion

[Fonts]
fixed="Monospace,10,-1,5,50,0,0,0,0,0"
general="Sans Serif,10,-1,5,50,0,0,0,0,0"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
CFGEOF

# Create Qt6ct config
cat > ~/.config/qt6ct/qt6ct.conf << 'CFGEOF'
[Appearance]
color_scheme_path=~/.config/qt6ct/colors/pywal.conf
custom_palette=true
icon_theme=breeze-dark
standard_dialogs=default
style=Fusion

[Fonts]
fixed="Monospace,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
general="Sans Serif,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
CFGEOF

echo "Qt themes generated from pywal colors!"
