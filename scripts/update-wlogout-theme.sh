#!/bin/bash
# Update wlogout theme with pywal colors

# Source pywal colors
source ~/.cache/wal/colors.sh

# Create wlogout config directory if it doesn't exist
mkdir -p ~/.config/wlogout

# Create wlogout CSS theme with pywal colors
cat > ~/.config/wlogout/style.css << EOF
* {
    background-image: none;
    box-shadow: none;
}

window {
    background-color: rgba(0, 0, 0, 0.9);
}

button {
    color: ${foreground};
    background-color: ${color0};
    border-style: solid;
    border-width: 2px;
    background-repeat: no-repeat;
    background-position: center;
    background-size: 25%;
    border-radius: 8px;
    margin: 10px;
    transition: all 0.3s ease;
}

button:focus, button:active, button:hover {
    background-color: ${color1};
    border-color: ${color2};
    outline-style: none;
}

#lock {
    background-image: url("$HOME/.config/wlogout/icons/lock.png");
    border-color: ${color4};
}

#logout {
    background-image: url("$HOME/.config/wlogout/icons/logout.png");
    border-color: ${color3};
}

#suspend {
    background-image: url("$HOME/.config/wlogout/icons/suspend.png");
    border-color: ${color5};
}

#hibernate {
    background-image: url("$HOME/.config/wlogout/icons/hibernate.png");
    border-color: ${color6};
}

#shutdown {
    background-image: url("$HOME/.config/wlogout/icons/shutdown.png");
    border-color: ${color1};
}

#reboot {
    background-image: url("$HOME/.config/wlogout/icons/reboot.png");
    border-color: ${color2};
}
EOF

echo "✅ wlogout theme updated with pywal colors!"
