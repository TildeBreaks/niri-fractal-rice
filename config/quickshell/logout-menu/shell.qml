// [NIRI-FRACTAL-RICE]
// Quickshell Logout Menu - Retro Gaming Theme
// Replaces wlogout with native quickshell implementation

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    // Pywal colors
    property string colorBg: "#0A120B"
    property string colorFg: "#aac5a8"
    property string color0: "#0A120B"
    property string color1: "#6A8C69"
    property string color2: "#7FA87D"
    property string color3: "#94B692"
    property string color4: "#A9C4A7"
    property string color5: "#BDD2BC"
    property string color6: "#D2E0D1"
    property string color7: "#aac5a8"

    // Load pywal colors
    Process {
        id: colorLoader
        command: ["bash", "-c", "jq -r '.special.background, .special.foreground, .colors.color0, .colors.color1, .colors.color2, .colors.color3, .colors.color4, .colors.color5, .colors.color6, .colors.color7' ~/.cache/wal/colors.json 2>/dev/null"]
        running: true

        property var colorLines: []

        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length > 0) colorLoader.colorLines.push(line)
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (colorLoader.colorLines.length >= 10) {
                colorBg = colorLoader.colorLines[0]
                colorFg = colorLoader.colorLines[1]
                color0 = colorLoader.colorLines[2]
                color1 = colorLoader.colorLines[3]
                color2 = colorLoader.colorLines[4]
                color3 = colorLoader.colorLines[5]
                color4 = colorLoader.colorLines[6]
                color5 = colorLoader.colorLines[7]
                color6 = colorLoader.colorLines[8]
                color7 = colorLoader.colorLines[9]
            }
        }
    }

    // Reload colors periodically
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            colorLoader.colorLines = []
            colorLoader.running = true
        }
    }

    // Menu visibility state
    property bool menuVisible: false
    property string pendingAction: ""
    property bool showConfirmation: false
    property int selectedIndex: 0

    // Watch for toggle signal
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: logoutToggleChecker.running = true
    }

    Process {
        id: logoutToggleChecker
        command: ["bash", "-c", "if [ -f ~/.cache/logout-menu-toggle ]; then rm -f ~/.cache/logout-menu-toggle; echo 'toggle'; fi"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                if (data.trim() === "toggle") {
                    root.menuVisible = !root.menuVisible
                    root.showConfirmation = false
                    root.pendingAction = ""
                    root.selectedIndex = 0
                }
            }
        }
    }

    // Logout menu overlay - centered on screen
    Variants {
        model: Quickshell.screens

        FloatingWindow {
            id: logoutWindow
            property var modelData
            screen: modelData
            visible: root.menuVisible

            color: "transparent"
            mask: Region { item: overlayRect }

            implicitWidth: 800
            implicitHeight: 600

            Rectangle {
                id: overlayRect
                anchors.fill: parent
                color: colorBg
                opacity: 0.98
                border.width: 4
                border.color: colorFg

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 30
                    spacing: 20

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        Text {
                            text: showConfirmation ? "⚠ CONFIRM ACTION ⚠" : "⏻ SESSION CONTROL ⏻"
                            color: showConfirmation ? "#ff4444" : colorFg
                            font.family: "Monospace"
                            font.pixelSize: 28
                            font.bold: true
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            style: Text.Outline
                            styleColor: color2
                        }

                        // Close button
                        Rectangle {
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            color: closeArea.containsMouse ? color2 : color1
                            border.width: 3
                            border.color: colorFg

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: colorFg
                                font.pixelSize: 24
                            }

                            MouseArea {
                                id: closeArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.menuVisible = false
                                    root.showConfirmation = false
                                    root.pendingAction = ""
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 3
                        color: colorFg
                    }

                    // Main content - either action grid or confirmation
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Action grid
                        GridLayout {
                            anchors.centerIn: parent
                            columns: 3
                            rowSpacing: 20
                            columnSpacing: 20
                            visible: !showConfirmation

                            Repeater {
                                model: [
                                    { name: "Lock", icon: "🔒", cmd: "swaylock -f", confirm: false, desc: "Lock screen" },
                                    { name: "Logout", icon: "🚪", cmd: "niri msg action quit", confirm: true, desc: "Exit session" },
                                    { name: "Suspend", icon: "💤", cmd: "systemctl suspend", confirm: false, desc: "Suspend to RAM" },
                                    { name: "Hibernate", icon: "💾", cmd: "systemctl hibernate", confirm: true, desc: "Suspend to disk" },
                                    { name: "Reboot", icon: "🔄", cmd: "systemctl reboot", confirm: true, desc: "Restart system" },
                                    { name: "Shutdown", icon: "⏻", cmd: "systemctl poweroff", confirm: true, desc: "Power off" }
                                ]

                                Rectangle {
                                    Layout.preferredWidth: 220
                                    Layout.preferredHeight: 180
                                    color: (selectedIndex === index && !showConfirmation) ? colorFg : (actionArea.containsMouse ? color2 : color1)
                                    border.width: (selectedIndex === index && !showConfirmation) ? 5 : 3
                                    border.color: (selectedIndex === index && !showConfirmation) ? colorFg : color3
                                    opacity: 1.0

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 12

                                        Text {
                                            text: modelData.icon
                                            font.pixelSize: 64
                                            Layout.alignment: Qt.AlignHCenter
                                        }

                                        Text {
                                            text: modelData.name.toUpperCase()
                                            color: (selectedIndex === index && !showConfirmation) ? colorBg : (actionArea.containsMouse ? colorBg : colorFg)
                                            font.family: "Monospace"
                                            font.pixelSize: 18
                                            font.bold: true
                                            Layout.alignment: Qt.AlignHCenter
                                        }

                                        Text {
                                            text: modelData.desc
                                            color: (selectedIndex === index && !showConfirmation) ? colorBg : (actionArea.containsMouse ? colorBg : colorFg)
                                            font.family: "Monospace"
                                            font.pixelSize: 11
                                            opacity: 0.8
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }

                                    MouseArea {
                                        id: actionArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (modelData.confirm) {
                                                root.pendingAction = modelData.cmd
                                                root.showConfirmation = true
                                            } else {
                                                actionLauncher.command = ["bash", "-c", modelData.cmd]
                                                actionLauncher.running = true
                                                root.menuVisible = false
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Confirmation dialog
                        Rectangle {
                            anchors.centerIn: parent
                            width: 500
                            height: 300
                            color: color0
                            border.width: 4
                            border.color: "#ff4444"
                            visible: showConfirmation

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 30
                                spacing: 25

                                Text {
                                    text: "Are you sure?"
                                    color: colorFg
                                    font.family: "Monospace"
                                    font.pixelSize: 24
                                    font.bold: true
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: pendingAction
                                    color: color2
                                    font.family: "Monospace"
                                    font.pixelSize: 14
                                    Layout.alignment: Qt.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    spacing: 20

                                    // Cancel button
                                    Rectangle {
                                        Layout.preferredWidth: 180
                                        Layout.preferredHeight: 60
                                        color: cancelArea.containsMouse ? color2 : color1
                                        border.width: 3
                                        border.color: colorFg

                                        Text {
                                            anchors.centerIn: parent
                                            text: "❌ CANCEL"
                                            color: colorFg
                                            font.family: "Monospace"
                                            font.pixelSize: 16
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: cancelArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                root.showConfirmation = false
                                                root.pendingAction = ""
                                            }
                                        }
                                    }

                                    // Confirm button
                                    Rectangle {
                                        Layout.preferredWidth: 180
                                        Layout.preferredHeight: 60
                                        color: confirmArea.containsMouse ? "#ff4444" : "#cc3333"
                                        border.width: 3
                                        border.color: colorFg

                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓ CONFIRM"
                                            color: colorFg
                                            font.family: "Monospace"
                                            font.pixelSize: 16
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: confirmArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                actionLauncher.command = ["bash", "-c", pendingAction]
                                                actionLauncher.running = true
                                                root.menuVisible = false
                                                root.showConfirmation = false
                                                root.pendingAction = ""
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Footer hint
                    Text {
                        text: showConfirmation ? ">> Press ESC to cancel or ENTER to confirm <<" : ">> Use Arrow Keys to navigate • Press ENTER to select • Press ESC to cancel <<"
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 12
                        opacity: 0.6
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // ESC key to close
            Shortcut {
                sequence: "Escape"
                onActivated: {
                    if (root.showConfirmation) {
                        root.showConfirmation = false
                        root.pendingAction = ""
                    } else {
                        root.menuVisible = false
                    }
                }
            }

            // Arrow key navigation
            Shortcut {
                sequence: "Left"
                onActivated: {
                    if (!root.showConfirmation && root.selectedIndex > 0) {
                        root.selectedIndex--
                    }
                }
            }

            Shortcut {
                sequence: "Right"
                onActivated: {
                    if (!root.showConfirmation && root.selectedIndex < 5) {
                        root.selectedIndex++
                    }
                }
            }

            Shortcut {
                sequence: "Up"
                onActivated: {
                    if (!root.showConfirmation && root.selectedIndex >= 3) {
                        root.selectedIndex -= 3
                    }
                }
            }

            Shortcut {
                sequence: "Down"
                onActivated: {
                    if (!root.showConfirmation && root.selectedIndex <= 2) {
                        root.selectedIndex += 3
                    }
                }
            }

            // Enter key to select
            Shortcut {
                sequence: "Return"
                onActivated: {
                    if (!root.showConfirmation) {
                        var actions = [
                            { name: "Lock", icon: "🔒", cmd: "swaylock -f", confirm: false, desc: "Lock screen" },
                            { name: "Logout", icon: "🚪", cmd: "niri msg action quit", confirm: true, desc: "Exit session" },
                            { name: "Suspend", icon: "💤", cmd: "systemctl suspend", confirm: false, desc: "Suspend to RAM" },
                            { name: "Hibernate", icon: "💾", cmd: "systemctl hibernate", confirm: true, desc: "Suspend to disk" },
                            { name: "Reboot", icon: "🔄", cmd: "systemctl reboot", confirm: true, desc: "Restart system" },
                            { name: "Shutdown", icon: "⏻", cmd: "systemctl poweroff", confirm: true, desc: "Power off" }
                        ]
                        var action = actions[root.selectedIndex]
                        if (action.confirm) {
                            root.pendingAction = action.cmd
                            root.showConfirmation = true
                        } else {
                            actionLauncher.command = ["bash", "-c", action.cmd]
                            actionLauncher.running = true
                            root.menuVisible = false
                        }
                    } else {
                        // Confirm action in confirmation dialog
                        actionLauncher.command = ["bash", "-c", root.pendingAction]
                        actionLauncher.running = true
                        root.menuVisible = false
                        root.showConfirmation = false
                        root.pendingAction = ""
                    }
                }
            }
        }
    }

    // Action launcher process
    Process {
        id: actionLauncher
        running: false
    }
}
