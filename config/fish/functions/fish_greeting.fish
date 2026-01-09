# [NIRI-FRACTAL-RICE]
function fish_greeting
    # Use the pywal-themed logo (generated when wallpaper changes)
    set -l logo ~/.config/fastfetch/logo.png
    if test -f "$logo"
        fastfetch --logo $logo --logo-type kitty-direct --logo-width 20 --logo-height 16
    else
        fastfetch
    end
end
