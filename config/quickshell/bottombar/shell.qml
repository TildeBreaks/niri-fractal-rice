// [NIRI-FRACTAL-RICE]
//@ pragma UseQApplication

// Quickshell Retro Gaming Bottom Bar - Terminal Animations Launcher
import QtQuick
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
    property string color8: "#778c76"
    
    // State
    property string currentApp: ""
    property bool terminalRunning: false
    property bool barExpanded: false
    property int barHeight: 500
    property int controlsWidth: 290
    
    // Terminal zone geometry (populated by the panel)
    property int termZoneX: 0
    property int termZoneY: 0
    property int termZoneWidth: 800
    property int termZoneHeight: 400
    
    // Pending command to launch
    property string pendingCmd: ""
    
    Component.onCompleted: {
        console.log("🎮 Retro Gaming Bottom Bar - Terminal Animations")
    }
    
    // Load pywal colors
    Process {
        id: colorLoader
        command: ["bash", "-c", "jq -r '.special.background, .special.foreground, .colors.color0, .colors.color1, .colors.color2, .colors.color3, .colors.color4, .colors.color5, .colors.color6, .colors.color7, .colors.color8' ~/.cache/wal/colors.json 2>/dev/null"]
        running: true
        
        property var colorLines: []
        
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length > 0) {
                    colorLoader.colorLines.push(line)
                }
            }
        }
        
        onExited: (exitCode, exitStatus) => {
            if (colorLoader.colorLines.length >= 11) {
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
                color8 = colorLoader.colorLines[10]
            }
        }
    }
    
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            colorLoader.colorLines = []
            colorLoader.running = true
        }
    }
    
    // Terminal apps
    property var terminalApps: [
        { name: "CAVA", cmd: "cava", icon: "♫", desc: "Audio Visualizer", category: "visual" },
        { name: "MATRIX", cmd: "cmatrix -b -C green", icon: "▓", desc: "Digital Rain", category: "visual" },
        { name: "PIPES", cmd: "pipes.sh", icon: "╠", desc: "Animated Pipes", category: "visual" },
        { name: "FIRE", cmd: "aafire", icon: "🔥", desc: "ASCII Fire", category: "visual" },
        { name: "TRAIN", cmd: "sl -e", icon: "🚂", desc: "Steam Locomotive", category: "visual" },
        { name: "NYAN", cmd: "nyancat", icon: "🐱", desc: "Nyan Cat", category: "visual" },
        { name: "LOLCAT", cmd: "while true; do fortune | lolcat; sleep 3; done", icon: "🌈", desc: "Rainbow Fortune", category: "text" },
        { name: "FIGLET", cmd: "while true; do clear; date '+%H:%M:%S' | figlet -f slant | lolcat; sleep 1; done", icon: "A", desc: "ASCII Clock", category: "text" },
        { name: "PONY", cmd: "while true; do clear; ponysay \"$(fortune -s)\"; sleep 5; done", icon: "🦄", desc: "Pony Fortune", category: "text" },
        { name: "BONSAI", cmd: "cbonsai -l -i -L 50 -m 'Terminal Art'", icon: "🌳", desc: "ASCII Bonsai", category: "text" },
        { name: "CLOCK", cmd: "tty-clock -c -C 2 -b -s", icon: "⏰", desc: "Terminal Clock", category: "realtime" },
        { name: "STARWARS", cmd: "telnet towel.blinkenlights.nl", icon: "⭐", desc: "ASCII Star Wars", category: "fun" },
        { name: "MOONBUG", cmd: "moon-buggy", icon: "🌙", desc: "Moon Buggy Game", category: "fun" },
        { name: "ASCIIQ", cmd: "asciiquarium", icon: "🐟", desc: "ASCII Aquarium", category: "visual" }
    ]
    
    // Main bar on primary screen
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            required property var modelData
            screen: modelData
            
            id: bottombar
            property bool isPrimary: modelData.primary !== undefined ? modelData.primary : (modelData.name === "DP-1")
            
            visible: isPrimary
            color: "transparent"
            
            anchors {
                bottom: true
                left: true
                right: true
            }
            
            margins {
                bottom: 0
                left: 0
                right: 0
            }
            
            implicitHeight: barExpanded ? barHeight : 10
            
            Behavior on implicitHeight {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
            
            // Kill terminal when collapsing
            onImplicitHeightChanged: {
                if (implicitHeight < 50 && terminalRunning) {
                    termKiller.running = true
                }
            }
            
            Rectangle {
                anchors.fill: parent
                color: colorBg
                border.width: barExpanded ? 3 : 1
                border.color: color2
                clip: true
                
                // Collapsed indicator
                Rectangle {
                    anchors.centerIn: parent
                    width: 150
                    height: 4
                    radius: 2
                    color: color2
                    visible: !barExpanded
                    
                    SequentialAnimation on opacity {
                        running: !barExpanded
                        loops: Animation.Infinite
                        NumberAnimation { from: 0.3; to: 0.8; duration: 1500 }
                        NumberAnimation { from: 0.8; to: 0.3; duration: 1500 }
                    }
                }
                
                // Expanded content
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 15
                    visible: barExpanded
                    opacity: barExpanded ? 1 : 0
                    
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    
                    // LEFT: Controls
                    Rectangle {
                        Layout.preferredWidth: controlsWidth
                        Layout.fillHeight: true
                        color: color0
                        border.width: 2
                        border.color: color2
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            
                            // Header
                            RowLayout {
                                Layout.fillWidth: true
                                
                                Text {
                                    text: ">> TERM FX <<"
                                    color: colorFg
                                    font.family: "Monospace"
                                    font.pixelSize: 16
                                    font.bold: true
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Rectangle {
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28
                                    color: collapseHover.containsMouse ? color1 : colorBg
                                    border.width: 2
                                    border.color: color2
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "▼"
                                        color: colorFg
                                        font.pixelSize: 14
                                    }
                                    
                                    MouseArea {
                                        id: collapseHover
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: barExpanded = false
                                    }
                                }
                            }
                            
                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 2; color: color2 }
                            
                            // Status
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                color: terminalRunning ? color1 : colorBg
                                border.width: 2
                                border.color: terminalRunning ? color3 : color2
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    
                                    Text {
                                        text: terminalRunning ? "▶ " + currentApp : "[ SELECT APP ]"
                                        color: colorFg
                                        font.family: "Monospace"
                                        font.pixelSize: 12
                                        font.bold: true
                                        Layout.fillWidth: true
                                    }
                                    
                                    Rectangle {
                                        Layout.preferredWidth: 50
                                        Layout.preferredHeight: 22
                                        color: stopHover.containsMouse ? color1 : colorBg
                                        border.width: 2
                                        border.color: color1
                                        visible: terminalRunning
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "STOP"
                                            color: color1
                                            font.family: "Monospace"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                        
                                        MouseArea {
                                            id: stopHover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: termKiller.running = true
                                        }
                                    }
                                }
                            }
                            
                            // Button grid
                            Flickable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentHeight: btnGrid.height
                                clip: true
                                
                                GridLayout {
                                    id: btnGrid
                                    width: parent.width
                                    columns: 2
                                    rowSpacing: 6
                                    columnSpacing: 6
                                    
                                    Repeater {
                                        model: terminalApps
                                        
                                        Rectangle {
                                            Layout.preferredWidth: 130
                                            Layout.preferredHeight: 50
                                            color: btnHover.containsMouse ? color1 : (currentApp === modelData.name ? color2 : color0)
                                            border.width: currentApp === modelData.name ? 3 : 2
                                            border.color: {
                                                if (currentApp === modelData.name) return colorFg
                                                switch(modelData.category) {
                                                    case "visual": return color3
                                                    case "text": return color4
                                                    case "realtime": return color5
                                                    case "fun": return color6
                                                    default: return color2
                                                }
                                            }
                                            
                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 4
                                                spacing: 2
                                                
                                                RowLayout {
                                                    spacing: 4
                                                    Text { text: modelData.icon; color: colorFg; font.pixelSize: 14 }
                                                    Text { text: modelData.name; color: colorFg; font.family: "Monospace"; font.pixelSize: 10; font.bold: true }
                                                }
                                                Text { text: modelData.desc; color: color7; font.family: "Monospace"; font.pixelSize: 9 }
                                            }
                                            
                                            MouseArea {
                                                id: btnHover
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    termKiller.running = true
                                                    currentApp = modelData.name
                                                    pendingCmd = modelData.cmd
                                                    launchTimer.start()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Legend
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Repeater {
                                    model: [
                                        { l: "VIS", c: color3 },
                                        { l: "TXT", c: color4 },
                                        { l: "RT", c: color5 },
                                        { l: "FUN", c: color6 }
                                    ]
                                    Rectangle {
                                        width: 32
                                        height: 16
                                        color: colorBg
                                        border.width: 1
                                        border.color: modelData.c
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.l
                                            color: modelData.c
                                            font.family: "Monospace"
                                            font.pixelSize: 8
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // RIGHT: Terminal zone
                    Rectangle {
                        id: termZone
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#000000"
                        border.width: 3
                        border.color: color2
                        
                        // Update root geometry when size changes
                        onWidthChanged: updateGeometry()
                        onHeightChanged: updateGeometry()
                        onXChanged: updateGeometry()
                        onYChanged: updateGeometry()
                        
                        function updateGeometry() {
                            var pos = termZone.mapToGlobal(0, 0)
                            root.termZoneX = Math.round(pos.x) + 5
                            root.termZoneY = Math.round(pos.y) + 5
                            root.termZoneWidth = Math.round(termZone.width) - 10
                            root.termZoneHeight = Math.round(termZone.height) - 10
                        }
                        
                        Component.onCompleted: Qt.callLater(updateGeometry)
                        
                        // Placeholder content
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 10
                            visible: !terminalRunning
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "┌───────────────────────────────┐"
                                color: color2
                                font.family: "Monospace"
                                font.pixelSize: 14
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "│   TERMINAL ANIMATION ZONE    │"
                                color: colorFg
                                font.family: "Monospace"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "├───────────────────────────────┤"
                                color: color2
                                font.family: "Monospace"
                                font.pixelSize: 14
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "│ Select app from left panel   │"
                                color: color7
                                font.family: "Monospace"
                                font.pixelSize: 14
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "│ Terminal embeds here         │"
                                color: color7
                                font.family: "Monospace"
                                font.pixelSize: 14
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "└───────────────────────────────┘"
                                color: color2
                                font.family: "Monospace"
                                font.pixelSize: 14
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "█"
                                color: colorFg
                                font.family: "Monospace"
                                SequentialAnimation on opacity {
                                    running: true
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0; duration: 500 }
                                    NumberAnimation { to: 1; duration: 500 }
                                }
                            }
                        }
                    }
                }
                
                // Expand on hover
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    enabled: !barExpanded
                    onEntered: expandTimer.start()
                    onExited: expandTimer.stop()
                    onClicked: function(mouse) { barExpanded = true; mouse.accepted = false }
                    onPressed: function(mouse) { mouse.accepted = false }
                }
                
                Timer {
                    id: expandTimer
                    interval: 200
                    onTriggered: barExpanded = true
                }
            }
        }
    }
    
    // Launch timer (at root level with access to root properties)
    Timer {
        id: launchTimer
        interval: 250
        onTriggered: {
            var w = root.termZoneWidth
            var h = root.termZoneHeight
            var escapedCmd = root.pendingCmd.replace(/'/g, "'\\''")
            
            console.log("Launching terminal:", w, "x", h, "cmd:", escapedCmd)
            
            termLauncher.command = ["kitty",
                "--class", "bottombar-term",
                "-o", "remember_window_size=no",
                "-o", "initial_window_width=" + w,
                "-o", "initial_window_height=" + h,
                "-o", "background_opacity=1.0",
                "-o", "hide_window_decorations=yes",
                "-o", "window_padding_width=8",
                "-o", "font_size=12",
                "-o", "background=#000000",
                "-o", "confirm_os_window_close=0",
                "-e", "bash", "-c", escapedCmd
            ]
            termLauncher.running = true
            terminalRunning = true
        }
    }
    
    Process {
        id: termLauncher
        running: false
        onExited: function(exitCode, exitStatus) {
            terminalRunning = false
            currentApp = ""
        }
    }
    
    Process {
        id: termKiller
        command: ["pkill", "-f", "bottombar-term"]
        running: false
        onExited: function(exitCode, exitStatus) {
            terminalRunning = false
            currentApp = ""
        }
    }
    
    // Monitor terminal
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: termChecker.running = true
    }
    
    Process {
        id: termChecker
        command: ["pgrep", "-f", "bottombar-term"]
        running: false
        property bool found: false
        
        stdout: SplitParser {
            onRead: function(data) {
                if (data.trim()) termChecker.found = true
            }
        }
        
        onStarted: found = false
        onExited: function(exitCode, exitStatus) {
            if (!found && terminalRunning) {
                terminalRunning = false
                currentApp = ""
            }
        }
    }
}
