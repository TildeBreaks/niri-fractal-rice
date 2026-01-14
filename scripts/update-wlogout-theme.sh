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
    background-color: ${color2};
    border-color: ${foreground};
    border-width: 4px;
    outline-style: none;
    transform: scale(1.05);
}

#lock {
    background-image: image(url("icons/lock.png"));
    border-color: ${color4};
}

#logout {
    background-image: image(url("icons/logout.png"));
    border-color: ${color3};
}

#suspend {
    background-image: image(url("icons/suspend.png"));
    border-color: ${color5};
}

#hibernate {
    background-image: image(url("icons/hibernate.png"));
    border-color: ${color6};
}

#shutdown {
    background-image: image(url("icons/shutdown.png"));
    border-color: ${color1};
}

#reboot {
    background-image: image(url("icons/reboot.png"));
    border-color: ${color2};
}
EOF

echo "✅ wlogout theme updated with pywal colors!"
