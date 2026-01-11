# [NIRI-FRACTAL-RICE]
function fish_greeting
    # Generate a fresh unique logo each time
    ~/.local/bin/generate-terminal-logo.sh >/dev/null 2>&1

    set -l logo ~/.config/fastfetch/logo.png
    if test -f "$logo"
        fastfetch --logo $logo --logo-type kitty-direct --logo-width 55 --logo-height 26
    else
        fastfetch
    end
end
