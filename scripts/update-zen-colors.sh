#!/bin/bash
# Update Zen Browser theme with pywal colors
# Robust version with better profile detection

COLORS_JSON="$HOME/.cache/wal/colors.json"

if [ ! -f "$COLORS_JSON" ]; then
    echo "Pywal colors not found. Run pywal first."
    exit 1
fi

# Read colors
COLOR_BG=$(jq -r '.special.background' "$COLORS_JSON")
COLOR_FG=$(jq -r '.special.foreground' "$COLORS_JSON")
COLOR0=$(jq -r '.colors.color0' "$COLORS_JSON")
COLOR1=$(jq -r '.colors.color1' "$COLORS_JSON")
COLOR2=$(jq -r '.colors.color2' "$COLORS_JSON")
COLOR3=$(jq -r '.colors.color3' "$COLORS_JSON")
COLOR4=$(jq -r '.colors.color4' "$COLORS_JSON")
COLOR5=$(jq -r '.colors.color5' "$COLORS_JSON")
COLOR6=$(jq -r '.colors.color6' "$COLORS_JSON")
COLOR7=$(jq -r '.colors.color7' "$COLORS_JSON")

# Potential Zen profile locations
SEARCH_PATHS=(
    "$HOME/.zen"
    "$HOME/.mozilla/zen"
)

ZEN_PROFILE=""

for path in "${SEARCH_PATHS[@]}"; do
    if [ -d "$path" ]; then
        # Search case-insensitively for a profile containing 'default'
        # head -1 picks the first one found
        PROFILE_DIR=$(find "$path" -maxdepth 1 -type d -iname "*default*" 2>/dev/null | head -1)
        if [ -n "$PROFILE_DIR" ]; then
            ZEN_PROFILE="$PROFILE_DIR"
            echo "✓ Found Zen profile at: $ZEN_PROFILE"
            break
        fi
    fi
done

if [ -z "$ZEN_PROFILE" ]; then
    echo "⚠ Zen Browser profile not found. Please ensure Zen has been run at least once."
    echo "Checked: ${SEARCH_PATHS[*]}"
    exit 1
fi

# Create chrome directory if it doesn't exist
CHROME_DIR="$ZEN_PROFILE/chrome"
mkdir -p "$CHROME_DIR"

# Create userChrome.css with pywal colors
cat > "$CHROME_DIR/userChrome.css" << EOF
/* Zen Browser - Pywal Dynamic Theme */
/* Auto-generated - DO NOT EDIT MANUALLY */

:root {
    --zen-bg: ${COLOR_BG} !important;
    --zen-fg: ${COLOR_FG} !important;
    --zen-accent: ${COLOR4} !important;
    --zen-dark: ${COLOR0} !important;
    --zen-border: ${COLOR1} !important;
    --zen-hover: ${COLOR5} !important;
    --zen-secondary: ${COLOR2} !important;

    /* Override Zen's accent colors */
    --zen-primary-color: ${COLOR4} !important;
    --zen-colors-primary: ${COLOR4} !important;
    --zen-colors-secondary: ${COLOR2} !important;
    --zen-colors-tertiary: ${COLOR1} !important;
    --zen-colors-border: ${COLOR1} !important;
    --toolbarbutton-icon-fill: ${COLOR_FG} !important;
    --toolbar-bgcolor: ${COLOR_BG} !important;
    --toolbar-color: ${COLOR_FG} !important;
    --lwt-accent-color: ${COLOR_BG} !important;
    --lwt-text-color: ${COLOR_FG} !important;
    --arrowpanel-background: ${COLOR_BG} !important;
    --arrowpanel-color: ${COLOR_FG} !important;
    --arrowpanel-border-color: ${COLOR1} !important;
}

/* Tab bar / toolbar area */
#titlebar, #TabsToolbar, #navigator-toolbox {
    background-color: ${COLOR_BG} !important;
}

/* Zen sidebar */
#zen-sidebar-top-buttons,
#zen-sidebar-bottom-buttons,
#zen-sidebar-icons-wrapper {
    background-color: ${COLOR_BG} !important;
}

#zen-sidebar-splitter {
    background-color: ${COLOR1} !important;
}

/* Zen gradient bar / accent strip */
.zen-sidebar-gradient,
#zen-sidebar-gradient,
.zen-essentials-gradient,
#zen-essentials-gradient {
    background: linear-gradient(180deg, ${COLOR2}, ${COLOR4}) !important;
}

/* Override any purple gradients */
*[style*="gradient"] {
    background: ${COLOR_BG} !important;
}

/* Zen primary gradient variable overrides */
:root {
    --zen-appcontent-separator-color: ${COLOR1} !important;
    --zen-themed-toolbar-bg: ${COLOR_BG} !important;
    --zen-sidebar-gradient: linear-gradient(180deg, ${COLOR2}, ${COLOR4}) !important;
    --gradient: linear-gradient(180deg, ${COLOR2}, ${COLOR4}) !important;
    --zen-main-browser-background: ${COLOR_BG} !important;
}

/* Zen workspaces */
.zen-workspace-button[selected="true"] {
    background-color: ${COLOR4} !important;
}

/* URL bar */
#urlbar {
    background-color: ${COLOR0} !important;
    color: ${COLOR_FG} !important;
    border: 1px solid ${COLOR1} !important;
}

/* Context menus */
menupopup {
    background-color: ${COLOR_BG} !important;
    color: ${COLOR_FG} !important;
    border: 1px solid ${COLOR1} !important;
}

/* Scrollbars */
scrollbar {
    background-color: ${COLOR_BG} !important;
}

scrollbar thumb {
    background-color: ${COLOR1} !important;
}

/* Fullscreen handling */
:root[inFullscreen] #navigator-toolbox,
:root[inFullscreen] #titlebar {
    display: none !important;
}
EOF

# Create userContent.css for internal pages
cat > "$CHROME_DIR/userContent.css" << EOF
/* Zen Browser - Pywal Dynamic Content Theme */
@-moz-document url-prefix("about:") {
    :root {
        --in-content-page-background: ${COLOR_BG} !important;
        --in-content-text-color: ${COLOR_FG} !important;
        --in-content-primary-button-background: ${COLOR4} !important;
        --in-content-box-background: ${COLOR0} !important;
        --in-content-border-color: ${COLOR1} !important;
    }

    body {
        background-color: ${COLOR_BG} !important;
        color: ${COLOR_FG} !important;
    }
}
EOF

echo "✓ Zen Browser theme updated! "
echo "ℹ Note: Restart Zen or reload tabs for changes to take effect."
echo "ℹ Ensure 'toolkit.legacyUserProfileCustomizations.stylesheets' is set to true in about:config"
