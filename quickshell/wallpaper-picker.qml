// QuickShell Wallpaper Picker - Dynamic Pywal Colors
// Reads current theme colors from pywal

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    // Read pywal colors - will update on load
    property string colorBg: "#0a0e14"
    property string colorFg: "#00ff41"
    property string colorAccent: "#00ff41"
    property string colorDark: "#003300"

    Component.onCompleted: {
        // Try to read colors synchronously
        var homeDir = Quickshell.env("HOME")
        console.log("Attempting to load colors from:", homeDir + "/.cache/wal/colors.json")
    }

    Process {
        id: colorLoader
        command: ["bash", "-c", "jq -r '.special.background, .special.foreground, .colors.color2, .colors.color0' ~/.cache/wal/colors.json 2>/dev/null || echo '#0a0e14\n#00ff41\n#00ff41\n#003300'"]
        running: true

        property var colorLines: []

        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length > 0) {
                    colorLoader.colorLines.push(line)
                    console.log("Read color line:", line)
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (colorLoader.colorLines.length >= 4) {
                colorBg = colorLoader.colorLines[0]
                colorFg = colorLoader.colorLines[1]
                colorAccent = colorLoader.colorLines[2]
                colorDark = colorLoader.colorLines[3]
                console.log("Applied colors - BG:", colorBg, "Accent:", colorAccent)
            } else {
                console.log("Not enough color lines, using defaults")
            }
        }
    }

    Process {
        id: findProcess
        command: ["bash", "-c", "find ~/Pictures/wallpapers -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \\) 2>/dev/null"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var path = data.trim()
                if (path.length > 0) {
                    wallpaperModel.append({path: path})
                }
            }
        }
    }

    Process {
        id: applyProcess
        command: ["true"]
        running: false
        
        onExited: (exitCode, exitStatus) => {
            console.log("Apply process finished with code:", exitCode)
            progressWindow.visible = false
            Qt.quit()
        }
    }

    Process {
        id: flameProcess
        running: false

        onExited: (exitCode, exitStatus) => {
            console.log("Flame process finished with code:", exitCode)
            progressWindow.visible = false
            Qt.quit()
        }
    }
    
    // Watcher starter - starts when picker opens
    Process {
        id: watcherStarter
        command: ["bash", Quickshell.env("HOME") + "/.local/bin/wallpaper-watcher.sh"]
        running: false
    }

    PanelWindow {
        id: progressWindow
        visible: false

        width: 400
        height: 200

        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: colorBg
            border.color: colorAccent
            border.width: 3

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 30

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: ">> GENERATING FRACTAL <<"
                    color: colorAccent
                    font.family: "monospace"
                    font.pixelSize: 18
                    font.bold: true
                }

                Text {
                    id: spinnerText
                    Layout.alignment: Qt.AlignHCenter
                    text: "⠋"
                    color: colorAccent
                    font.pixelSize: 48
                    font.bold: true
                    
                    property int frame: 0
                    property var frames: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
                    
                    Timer {
                        interval: 100
                        running: progressWindow.visible
                        repeat: true
                        onTriggered: {
                            spinnerText.frame = (spinnerText.frame + 1) % spinnerText.frames.length
                            spinnerText.text = spinnerText.frames[spinnerText.frame]
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "This may take 10-30 seconds..."
                    color: colorFg
                    font.family: "monospace"
                    font.pixelSize: 12
                }
            }
        }
    }

    PanelWindow {
        id: wallpaperPicker

        implicitWidth: 1200
        implicitHeight: 800
        visible: true

        color: "transparent"
        
        Component.onCompleted: {
            console.log("Wallpaper picker loaded with dynamic colors")
            // Start the watcher
            watcherStarter.running = true
        }

        Rectangle {
            anchors.fill: parent
            color: colorBg
            border.color: colorAccent
            border.width: 3

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // Header with close button and random gradient button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "transparent"
                    border.color: colorAccent
                    border.width: 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        // Random gradient button
                        Rectangle {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 40
                            color: colorDark
                            border.color: colorAccent
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "[RND]"
                                color: colorAccent
                                font.pixelSize: 14
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onEntered: {
                                    parent.border.width = 3
                                    parent.color = colorAccent
                                    parent.children[0].color = colorBg
                                }

                                onExited: {
                                    parent.border.width = 2
                                    parent.color = colorDark
                                    parent.children[0].color = colorAccent
                                }

                                onClicked: {
                                    wallpaperPicker.generateRandomGradient()
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: ">> SELECT WALLPAPER <<"
                            color: colorAccent
                            font.family: "monospace"
                            font.pixelSize: 16
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            color: colorBg
                            border.color: "#ff0000"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "X"
                                color: "#ff0000"
                                font.pixelSize: 20
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Qt.quit()
                            }
                        }
                    }
                }

                // Grid of wallpapers
                GridView {
                    id: wallpaperGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    cellWidth: 280
                    cellHeight: 280

                    clip: true

                    model: ListModel {
                        id: wallpaperModel
                    }

                    delegate: Rectangle {
                        width: 260
                        height: 260
                        color: colorBg
                        border.color: colorDark
                        border.width: 2

                        Image {
                            anchors.fill: parent
                            anchors.margins: 5
                            source: "file://" + model.path
                            fillMode: Image.PreserveAspectCrop
                            cache: false
                            asynchronous: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: {
                                parent.border.color = colorAccent
                                parent.border.width = 3
                            }

                            onExited: {
                                parent.border.color = colorDark
                                parent.border.width = 2
                            }

                            onClicked: {
                                wallpaperPicker.selectWallpaper(model.path)
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
        }

        function selectWallpaper(path) {
            console.log("Selected wallpaper:", path)

            // Show progress window
            progressWindow.visible = true

            // Hide main picker
            wallpaperPicker.visible = false

            // Run the apply process and wait for it
            applyProcess.command = ["bash", "-c",
                "wal -i '" + path + "' -a 85 -q && " +
                "~/.local/bin/update-niri-colors.sh && " +
                "~/.local/bin/generate-qt-theme.sh && " +
                "sleep 2 && " +
                "cp ~/.cache/wal/retro.rasi ~/.config/rofi/retro.rasi && " +
                "cp ~/.cache/wal/mako-config ~/.config/mako/config && " +
                "~/.local/bin/update-niri-colors.sh && " +
                "~/.local/bin/update-floorp-theme.sh && " +
                "~/.local/bin/create-gtk-theme.sh 2>/dev/null && " +
                "~/.local/bin/update-sddm-theme.sh 2>/dev/null && " +
                "~/.local/bin/update-wlogout-theme.sh 2>/dev/null && " +
                "killall mako 2>/dev/null ; sleep 0.5 && " +
                "killall thunar 2>/dev/null & " +
                "killall swaybg 2>/dev/null ; sleep 0.3 && " +
                "swaybg -i '" + path + "' -m fill & " +
                "sleep 0.3 && " +
                "systemctl --user restart quickshell-topbar.service && " +
                "systemctl --user start mako.service && " +
                "touch ~/.cache/wallpaper-changed && " +
                "notify-send 'THEME UPDATED' 'System theme applied!' -t 2500"
            ]
            applyProcess.running = true
        }
    }
}
