#!/bin/bash
# Update Floorp theme with pywal colors

COLORS_JSON="$HOME/.cache/wal/colors.json"

if [ ! -f "$COLORS_JSON" ]; then
    echo "Pywal colors not found"
    exit 1
fi

# Find Floorp profile
FLOORP_PROFILE=$(find ~/.floorp -name "*.default-default" -o -name "*.default-release" -type d 2>/dev/null | head -1)

if [ -z "$FLOORP_PROFILE" ]; then
    echo "✗ Floorp profile not found. Launch Floorp at least once first."
    exit 1
fi

echo "Found Floorp profile: $FLOORP_PROFILE"

# Create chrome directory
CHROME_DIR="$FLOORP_PROFILE/chrome"
mkdir -p "$CHROME_DIR"

# Read colors
COLOR_BG=$(jq -r '.special.background' "$COLORS_JSON")
COLOR_FG=$(jq -r '.special.foreground' "$COLORS_JSON")
COLOR0=$(jq -r '.colors.color0' "$COLORS_JSON")
COLOR1=$(jq -r '.colors.color1' "$COLORS_JSON")
COLOR2=$(jq -r '.colors.color2' "$COLORS_JSON")
COLOR3=$(jq -r '.colors.color3' "$COLORS_JSON")
COLOR4=$(jq -r '.colors.color4' "$COLORS_JSON")
COLOR7=$(jq -r '.colors.color7' "$COLORS_JSON")
COLOR8=$(jq -r '.colors.color8' "$COLORS_JSON")

echo "Updating Floorp theme..."
echo "  Background: $COLOR_BG"
echo "  Foreground: $COLOR_FG"
echo "  Accent: $COLOR2"

# Generate userChrome.css
cat > "$CHROME_DIR/userChrome.css" << EOF
/* Floorp Pywal Retro Theme - Auto-generated */

:root {
    --floorp-bg: ${COLOR_BG} !important;
    --floorp-fg: ${COLOR_FG} !important;
    --floorp-dark: ${COLOR0} !important;
    --floorp-accent: ${COLOR2} !important;
    --floorp-highlight: ${COLOR4} !important;
    --floorp-error: ${COLOR1} !important;
}

/* Toolbar and main UI */
#navigator-toolbox,
#nav-bar,
toolbar,
#PersonalToolbar {
    background-color: var(--floorp-bg) !important;
    color: var(--floorp-fg) !important;
    border: none !important;
}

/* Tabs */
.tabbrowser-tab {
    background-color: var(--floorp-dark) !important;
    color: var(--floorp-fg) !important;
    border: 1px solid var(--floorp-accent) !important;
    margin: 2px !important;
}

.tabbrowser-tab[selected="true"] {
    background-color: var(--floorp-accent) !important;
    color: var(--floorp-bg) !important;
    border: 2px solid var(--floorp-highlight) !important;
    font-weight: bold !important;
}

.tabbrowser-tab:hover {
    background-color: var(--floorp-highlight) !important;
    color: var(--floorp-bg) !important;
}

/* URL bar */
#urlbar,
#urlbar-background,
#searchbar {
    background-color: var(--floorp-dark) !important;
    color: var(--floorp-fg) !important;
    border: 2px solid var(--floorp-accent) !important;
}

#urlbar[focused="true"] {
    border: 2px solid var(--floorp-highlight) !important;
}

/* Dropdowns and panels */
#BMB_bookmarksPopup,
menupopup,
panel,
.panel-arrowcontent {
    background-color: var(--floorp-dark) !important;
    color: var(--floorp-fg) !important;
    border: 2px solid var(--floorp-accent) !important;
}

menuitem:hover,
menu:hover {
    background-color: var(--floorp-accent) !important;
    color: var(--floorp-bg) !important;
}

/* Sidebar */
#sidebar-box,
#sidebar-header {
    background-color: var(--floorp-bg) !important;
    color: var(--floorp-fg) !important;
    border-right: 2px solid var(--floorp-accent) !important;
}

/* Context menus */
menupopup > menuitem,
menupopup > menu {
    color: var(--floorp-fg) !important;
}

/* Buttons */
.toolbarbutton-1,
toolbarbutton {
    color: var(--floorp-fg) !important;
}

.toolbarbutton-1:hover,
toolbarbutton:hover {
    background-color: var(--floorp-accent) !important;
    color: var(--floorp-bg) !important;
}

/* Scrollbars */
scrollbar {
    background-color: var(--floorp-bg) !important;
}

thumb {
    background-color: var(--floorp-accent) !important;
    border: 2px solid var(--floorp-bg) !important;
}

thumb:hover {
    background-color: var(--floorp-highlight) !important;
}

/* Findbar */
.findbar-textbox {
    background-color: var(--floorp-dark) !important;
    color: var(--floorp-fg) !important;
    border: 2px solid var(--floorp-accent) !important;
}

/* Status panel */
#statuspanel-label {
    background-color: var(--floorp-dark) !important;
    color: var(--floorp-fg) !important;
    border: 2px solid var(--floorp-accent) !important;
}
EOF

# Generate userContent.css for web pages
cat > "$CHROME_DIR/userContent.css" << EOF
/* Floorp Pywal Content Theme - Auto-generated */

/* Optional: Theme new tab page and about: pages */
@-moz-document url("about:home"), url("about:newtab"), url("about:blank") {
    body {
        background-color: ${COLOR_BG} !important;
        color: ${COLOR_FG} !important;
    }
}

/* Scrollbars on web pages */
* {
    scrollbar-color: ${COLOR2} ${COLOR_BG} !important;
    scrollbar-width: thin !important;
}
EOF

echo "✓ Floorp theme updated!"
echo "  Restart Floorp to see changes"
