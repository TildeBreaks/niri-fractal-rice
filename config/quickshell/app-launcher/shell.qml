// [NIRI-FRACTAL-RICE]
// Quickshell App Launcher - Retro Gaming Theme
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Widgets

ShellRoot {
    // Pywal colors
    property string colorBg: "#0A120B"
    property string colorFg: "#aac5a8"
    property string color0: "#0A120B"
    property string color2: "#7FA87D"
    property string color8: "#778c76"
    
    // Load colors on startup
    Process {
        id: colorLoaderProcess
        command: ["bash", "-c", "jq -r '.special.background, .special.foreground, .colors.color0, .colors.color2, .colors.color8' ~/.cache/wal/colors.json 2>/dev/null"]
        running: true
        
        property var colorLines: []
        
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length > 0) colorLoaderProcess.colorLines.push(line)
            }
        }
        
        onExited: (exitCode, exitStatus) => {
            if (colorLoaderProcess.colorLines.length >= 5) {
                colorBg = colorLoaderProcess.colorLines[0]
                colorFg = colorLoaderProcess.colorLines[1]
                color0 = colorLoaderProcess.colorLines[2]
                color2 = colorLoaderProcess.colorLines[3]
                color8 = colorLoaderProcess.colorLines[4]
                wallpaperLoader.running = true
            }
        }
    }
    
    // Load wallpaper
    Process {
        id: wallpaperLoader
        command: ["bash", "-c", "pgrep -a swaybg | grep -oP '(?<=-i )[^ ]+' | head -1"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                var path = data.trim()
                if (path.length > 0) bgImage.source = "file://" + path
            }
        }
    }

    FloatingWindow {
        id: launcher
        visible: true
        screen: Quickshell.screens[0]
        color: "transparent"
        implicitWidth: 600
        implicitHeight: 700
        
        property string query: ""

        function launchSelected() {
            if (list.currentItem && list.currentItem.modelData) {
                list.currentItem.modelData.execute()
                Qt.quit()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: colorBg
            border.width: 3
            border.color: color2
            
            // Wallpaper background
            Image {
                id: bgImage
                anchors.centerIn: parent
                width: parent.width * 1.5
                height: parent.height * 1.5
                fillMode: Image.PreserveAspectCrop
                opacity: 0.15
                smooth: true
                scale: 1.0
                
                SequentialAnimation on scale {
                    running: true
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 1.2; duration: 6000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.2; to: 1.0; duration: 6000; easing.type: Easing.InOutSine }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: ">> APP LAUNCHER <<"
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 16
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        color: closeBtn.containsMouse ? colorFg : color0
                        border.width: 2
                        border.color: colorFg
                        
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: closeBtn.containsMouse ? color0 : colorFg
                            font.pixelSize: 16
                        }
                        
                        MouseArea {
                            id: closeBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.quit()
                        }
                    }
                }

                // Search
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    color: color0
                    border.width: input.activeFocus ? 3 : 2
                    border.color: input.activeFocus ? colorFg : color2
                    
                    TextField {
                        id: input
                        anchors.fill: parent
                        anchors.margins: 10
                        placeholderText: "[SEARCH...]"
                        placeholderTextColor: color8
                        font.family: "Monospace"
                        font.pixelSize: 16
                        font.bold: true
                        color: colorFg
                        focus: true
                        
                        background: Rectangle { color: "transparent" }

                        onTextChanged: {
                            launcher.query = text
                            list.currentIndex = filtered.values.length > 0 ? 0 : -1
                        }

                        Keys.onEscapePressed: Qt.quit()
                        Keys.onPressed: event => {
                            if (event.key == Qt.Key_Up) {
                                event.accepted = true
                                if (list.currentIndex > 0) list.currentIndex--
                            } else if (event.key == Qt.Key_Down) {
                                event.accepted = true
                                if (list.currentIndex < list.count - 1) list.currentIndex++
                            } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
                                event.accepted = true
                                launcher.launchSelected()
                            }
                        }
                    }
                }

                // Count
                Text {
                    text: launcher.query.length > 0 ? "RESULTS (" + filtered.values.length + ")" : "ALL APPS (" + filtered.values.length + ")"
                    color: color8
                    font.family: "Monospace"
                    font.pixelSize: 12
                    font.bold: true
                }

                // Filter
                ScriptModel {
                    id: filtered
                    values: {
                        const allEntries = [...DesktopEntries.applications.values]
                        const q = launcher.query.trim().toLowerCase()
                        
                        let results
                        if (q === "") {
                            results = allEntries
                        } else {
                            results = allEntries.filter(d => d.name && d.name.toLowerCase().includes(q))
                        }
                        
                        // Sort alphabetically
                        return results.sort((a, b) => a.name.localeCompare(b.name))
                    }
                }

                // List
                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 5
                    model: filtered.values
                    currentIndex: filtered.values.length > 0 ? 0 : -1
                    highlightMoveDuration: 100

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: list.width - 20
                        height: 45
                        
                        // Style based on selection
                        color: ListView.isCurrentItem ? colorFg : (ma.containsMouse ? color2 : color0)
                        border.width: ListView.isCurrentItem ? 3 : 2
                        border.color: ListView.isCurrentItem ? colorFg : color2

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: list.currentIndex = index
                            onDoubleClicked: launcher.launchSelected()
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            Text {
                                text: "▶"
                                color: parent.parent.ListView.isCurrentItem ? color0 : colorFg
                                font.family: "Monospace"
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Text {
                                text: modelData.name
                                color: parent.parent.ListView.isCurrentItem ? color0 : colorFg
                                font.family: "Monospace"
                                font.pixelSize: 14
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Keys.onReturnPressed: launcher.launchSelected()
                }
            }
        }
    }
}
