#!/bin/bash
# Update Zen Browser theme with pywal colors

COLORS_JSON="$HOME/.cache/wal/colors.json"

if [ ! -f "$COLORS_JSON" ]; then
    echo "Pywal colors not found"
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

# Find Zen profile directory - look for any .Default folder
ZEN_PROFILE=$(find "$HOME/.zen" -maxdepth 1 -type d -name "*.Default*" 2>/dev/null | head -1)

if [ -z "$ZEN_PROFILE" ]; then
    echo "⚠ Zen Browser profile not found"
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
    background: ${COLOR_BG} !important;
}

#TabsToolbar-customization-target {
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
[class*="gradient"],
.zen-essentials-gradient,
#zen-essentials-gradient {
    background: linear-gradient(180deg, ${COLOR2}, ${COLOR4}) !important;
    background-image: linear-gradient(180deg, ${COLOR2}, ${COLOR4}) !important;
}

/* Override any purple gradients */
*[style*="gradient"] {
    background: ${COLOR_BG} !important;
}

/* Zen accent bar */
.zen-sidebar-panel-wrapper::before,
#zen-sidebar-panels-wrapper::before,
#zen-sidebar-panels-wrapper {
    background: ${COLOR_BG} !important;
    border-color: ${COLOR1} !important;
}

/* Zen primary gradient variable overrides */
:root {
    --zen-appcontent-separator-color: ${COLOR1} !important;
    --zen-themed-toolbar-bg: ${COLOR_BG} !important;
    --zen-dialog-background: ${COLOR_BG} !important;
    --zen-sidebar-gradient: linear-gradient(180deg, ${COLOR2}, ${COLOR4}) !important;
    --gradient: linear-gradient(180deg, ${COLOR2}, ${COLOR4}) !important;
    --zen-main-browser-background: ${COLOR_BG} !important;
}

/* Zen workspaces */
.zen-workspace-button {
    background-color: ${COLOR_BG} !important;
}

.zen-workspace-button:hover {
    background-color: ${COLOR2} !important;
}

.zen-workspace-button[selected="true"] {
    background-color: ${COLOR4} !important;
}

/* Toolbar */
#nav-bar {
    background-color: var(--zen-bg) !important;
    border-color: var(--zen-border) !important;
}

/* Tabs */
.tabbrowser-tab {
    background-color: var(--zen-dark) !important;
    color: var(--zen-fg) !important;
}

.tabbrowser-tab[selected="true"] {
    background-color: var(--zen-accent) !important;
    color: var(--zen-fg) !important;
}

.tabbrowser-tab:hover:not([selected="true"]) {
    background-color: var(--zen-secondary) !important;
}

/* URL bar */
#urlbar {
    background-color: var(--zen-dark) !important;
    color: var(--zen-fg) !important;
    border: 1px solid var(--zen-border) !important;
}

#urlbar:focus-within {
    border-color: var(--zen-accent) !important;
}

#urlbar-input {
    color: var(--zen-fg) !important;
}

/* Sidebar */
#sidebar-box {
    background-color: var(--zen-bg) !important;
    border-color: var(--zen-border) !important;
}

#sidebar {
    background-color: var(--zen-bg) !important;
}

/* Context menus */
menupopup {
    background-color: var(--zen-bg) !important;
    color: var(--zen-fg) !important;
    border: 1px solid var(--zen-border) !important;
}

menuitem {
    color: var(--zen-fg) !important;
}

menuitem:hover {
    background-color: var(--zen-hover) !important;
    color: var(--zen-fg) !important;
}

menu:hover {
    background-color: var(--zen-hover) !important;
}

/* Bookmarks bar */
#PersonalToolbar {
    background-color: var(--zen-bg) !important;
}

/* Panels and popups */
panel, .panel-arrowcontent {
    background-color: var(--zen-bg) !important;
    color: var(--zen-fg) !important;
    border-color: var(--zen-border) !important;
}

/* Findbar */
findbar {
    background-color: var(--zen-bg) !important;
    color: var(--zen-fg) !important;
}

/* Autocomplete popup */
#PopupAutoComplete {
    background-color: var(--zen-bg) !important;
    color: var(--zen-fg) !important;
}

.autocomplete-richlistitem {
    background-color: var(--zen-bg) !important;
    color: var(--zen-fg) !important;
}

.autocomplete-richlistitem:hover {
    background-color: var(--zen-accent) !important;
}

/* Buttons */
button {
    background-color: var(--zen-secondary) !important;
    color: var(--zen-fg) !important;
}

button:hover {
    background-color: var(--zen-accent) !important;
}

/* Scrollbars */
scrollbar {
    background-color: var(--zen-bg) !important;
}

scrollbar thumb {
    background-color: var(--zen-border) !important;
}

scrollbar thumb:hover {
    background-color: var(--zen-accent) !important;
}
EOF

# Create userContent.css for internal pages
cat > "$CHROME_DIR/userContent.css" << EOF
/* Zen Browser - Pywal Dynamic Content Theme */
/* Auto-generated - DO NOT EDIT MANUALLY */

:root {
    --zen-bg: ${COLOR_BG};
    --zen-fg: ${COLOR_FG};
    --zen-accent: ${COLOR4};
    --zen-border: ${COLOR1};
}

/* Style internal pages (about:*, new tab, etc) */
@-moz-document url-prefix("about:") {
    :root {
        --in-content-page-background: ${COLOR_BG} !important;
        --in-content-text-color: ${COLOR_FG} !important;
        --in-content-primary-button-background: ${COLOR4} !important;
        --in-content-primary-button-text-color: ${COLOR_FG} !important;
        --in-content-box-background: ${COLOR0} !important;
        --in-content-border-color: ${COLOR1} !important;
        --in-content-item-hover: ${COLOR2} !important;
        --in-content-item-selected: ${COLOR4} !important;
    }

    body {
        background-color: ${COLOR_BG} !important;
        color: ${COLOR_FG} !important;
    }

    a {
        color: ${COLOR4} !important;
    }

    a:hover {
        color: ${COLOR5} !important;
    }
}

/* New tab page */
@-moz-document url("about:newtab"), url("about:home") {
    body {
        background-color: ${COLOR_BG} !important;
    }

    .search-wrapper input {
        background-color: ${COLOR0} !important;
        color: ${COLOR_FG} !important;
        border-color: ${COLOR1} !important;
    }
}

/* Preferences/Settings page */
@-moz-document url-prefix("about:preferences") {
    body {
        background-color: ${COLOR_BG} !important;
    }

    .navigation {
        background-color: ${COLOR0} !important;
    }

    .category:hover {
        background-color: ${COLOR2} !important;
    }

    .category[selected] {
        background-color: ${COLOR4} !important;
    }
}
EOF

echo "✓ Zen Browser theme updated!"
