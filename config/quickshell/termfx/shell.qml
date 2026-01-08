// [NIRI-FRACTAL-RICE]
//@ pragma UseQApplication

// Quickshell Terminal FX Launcher
// Simple popup with buttons - terminal opens beside it
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
    property string pendingCmd: ""
    
    Component.onCompleted: {
        console.log("🎮 Terminal FX Launcher")
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
    
    // Launcher popup - anchored bottom-left
    PanelWindow {
        id: launcher
        
        screen: Quickshell.screens[0]
        color: "transparent"
        
        anchors {
            bottom: true
            left: true
        }
        
        margins {
            bottom: 10
            left: 10
        }
        
        implicitWidth: 320
        implicitHeight: 520
        
        Rectangle {
            anchors.fill: parent
            color: colorBg
            border.width: 3
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
                    
                    // Status indicator
                    Rectangle {
                        Layout.preferredWidth: 12
                        Layout.preferredHeight: 12
                        radius: 6
                        color: terminalRunning ? color3 : color8
                        border.width: 1
                        border.color: terminalRunning ? colorFg : color2
                        
                        SequentialAnimation on opacity {
                            running: terminalRunning
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.4; duration: 600 }
                            NumberAnimation { to: 1.0; duration: 600 }
                        }
                    }
                }
                
                // Current app display
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    color: terminalRunning ? color1 : color0
                    border.width: 2
                    border.color: terminalRunning ? color3 : color2
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        
                        Text {
                            text: terminalRunning ? "▶ " + currentApp : "[ SELECT ]"
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 11
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        
                        // Stop button
                        Rectangle {
                            Layout.preferredWidth: 45
                            Layout.preferredHeight: 20
                            color: stopHover.containsMouse ? color1 : "transparent"
                            border.width: 1
                            border.color: color1
                            visible: terminalRunning
                            
                            Text {
                                anchors.centerIn: parent
                                text: "STOP"
                                color: color1
                                font.family: "Monospace"
                                font.pixelSize: 9
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
                
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 2; color: color2 }
                
                // Button grid
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 2
                    rowSpacing: 6
                    columnSpacing: 6
                    
                    Repeater {
                        model: terminalApps
                        
                        Rectangle {
                            Layout.preferredWidth: 145
                            Layout.preferredHeight: 48
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
                                    Text { 
                                        text: modelData.name
                                        color: colorFg
                                        font.family: "Monospace"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                                Text { 
                                    text: modelData.desc
                                    color: color7
                                    font.family: "Monospace"
                                    font.pixelSize: 8
                                }
                            }
                            
                            MouseArea {
                                id: btnHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // Kill existing terminal if running
                                    if (terminalRunning) {
                                        termKiller.running = true
                                    }
                                    currentApp = modelData.name
                                    pendingCmd = modelData.cmd
                                    launchTimer.start()
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
                            height: 14
                            color: "transparent"
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
                    
                    Item { Layout.fillWidth: true }
                }
            }
        }
    }
    
    // Launch timer
    Timer {
        id: launchTimer
        interval: 150
        onTriggered: {
            var escapedCmd = root.pendingCmd.replace(/'/g, "'\\''")
            
            termLauncher.command = ["kitty",
                "--class", "termfx",
                "--name", "termfx",
                "-o", "remember_window_size=no",
                "-o", "initial_window_width=900",
                "-o", "initial_window_height=500",
                "-o", "background_opacity=0.95",
                "-o", "hide_window_decorations=yes",
                "-o", "window_padding_width=10",
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
        command: ["pkill", "-f", "class=termfx"]
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
        command: ["pgrep", "-f", "termfx"]
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
