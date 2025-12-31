#!/bin/bash
# SDDM Theme Update Helper - runs as root via pkexec
# Args: wallpaper bg fg color2 color4 color0

WALLPAPER="$1"
COLOR_BG="$2"
COLOR_FG="$3"
COLOR2="$4"
COLOR4="$5"
COLOR0="$6"

THEME_DIR="/usr/share/sddm/themes/pywal-retro"

# Copy wallpaper
if [ -f "$WALLPAPER" ]; then
    cp "$WALLPAPER" "$THEME_DIR/background.jpg"
fi

# Update theme.conf
cat > "$THEME_DIR/theme.conf" << EOF
[General]
background=${THEME_DIR}/background.jpg
backgroundMode=scaled

[Input]
background=${COLOR0}
color=${COLOR_FG}

[Design]
background=${COLOR_BG}
color=${COLOR_FG}
fontSize=12
font=Monospace
EOF

# Update Main.qml
cat > "$THEME_DIR/Main.qml" << EOF
import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    width: 3440
    height: 1440
    
    Image {
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
    }
    
    Rectangle {
        anchors.fill: parent
        color: "${COLOR_BG}"
        opacity: 0.7
    }

    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -200
        text: ">> NIRI RETRO SYSTEM <<"
        color: "${COLOR_FG}"
        font.family: "Monospace"
        font.pixelSize: 32
        font.bold: true
    }

    Column {
        anchors.centerIn: parent
        spacing: 20

        TextField {
            id: usernameField
            width: 400
            height: 50
            placeholderText: "USERNAME"
            font.family: "Monospace"
            font.pixelSize: 18
            background: Rectangle {
                color: "${COLOR0}"
                border.color: "${COLOR2}"
                border.width: 3
            }
            color: "${COLOR_FG}"
        }

        TextField {
            id: passwordField
            width: 400
            height: 50
            placeholderText: "PASSWORD"
            echoMode: TextInput.Password
            font.family: "Monospace"
            font.pixelSize: 18
            background: Rectangle {
                color: "${COLOR0}"
                border.color: "${COLOR2}"
                border.width: 3
            }
            color: "${COLOR_FG}"
            onAccepted: sddm.login(usernameField.text, passwordField.text, sessionCombo.currentIndex)
        }

        ComboBox {
            id: sessionCombo
            width: 400
            height: 50
            model: sessionModel
            currentIndex: sessionModel.lastIndex
            font.family: "Monospace"
            font.pixelSize: 16
            background: Rectangle {
                color: "${COLOR0}"
                border.color: "${COLOR2}"
                border.width: 3
            }
            contentItem: Text {
                text: sessionCombo.displayText
                color: "${COLOR_FG}"
                font: sessionCombo.font
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
            }
        }

        Button {
            width: 400
            height: 50
            text: "[LOGIN]"
            font.family: "Monospace"
            font.pixelSize: 18
            font.bold: true
            background: Rectangle {
                color: "${COLOR0}"
                border.color: "${COLOR4}"
                border.width: 3
            }
            contentItem: Text {
                text: parent.text
                color: "${COLOR_FG}"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font: parent.font
            }
            onClicked: sddm.login(usernameField.text, passwordField.text, sessionCombo.currentIndex)
        }
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 30
        text: new Date().toLocaleString(Qt.locale(), "dddd, MMMM d, yyyy hh:mm AP")
        color: "${COLOR_FG}"
        font.family: "Monospace"
        font.pixelSize: 16
    }
}
EOF

echo "SDDM theme files updated"
