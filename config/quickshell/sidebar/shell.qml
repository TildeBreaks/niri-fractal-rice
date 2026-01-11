// [NIRI-FRACTAL-RICE]
// QuickShell Gaming Sidebar - Retro Waybar Style
// Matching the glow aesthetic
// FIXED: Standardized wallpaper change detection
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Qt.labs.folderlistmodel

ShellRoot {
    id: root
    
    // Pywal colors - matching waybar
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
    
    Component.onCompleted: {
        console.log("🎮 Retro Gaming Sidebar - Waybar Style")
    }
    
    // Load pywal colors
    Process {
        id: colorLoader
        command: ["bash", "-c", "jq -r '.special.background, .special.foreground, .colors.color0, .colors.color1, .colors.color2, .colors.color3, .colors.color4, .colors.color5, .colors.color6, .colors.color7' ~/.cache/wal/colors.json 2>/dev/null"]
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
    
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            colorLoader.colorLines = []
            colorLoader.running = true
        }
    }

    // Palette model and loader for fractal generation
    ListModel {
        id: paletteListModel
    }

    Process {
        id: paletteLoader
        command: ["bash", "-c", "/home/breaks/.local/bin/flam3-palette-util.sh curated-colors"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length > 0) {
                    var parts = line.split("|")
                    var name = parts[0]
                    var colorStr = parts.length > 1 ? parts[1] : ""
                    paletteListModel.append({name: name, colorStr: colorStr})
                }
            }
        }
    }

    // Progress window for wallpaper operations
    PanelWindow {
        id: progressWindow

        visible: false
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        anchors {
            left: true
        }

        margins {
            left: 52
            top: 200
        }

        implicitWidth: 400
        implicitHeight: 200
        
        Rectangle {
            anchors.fill: parent
            color: colorBg
            opacity: 0.98
            border.width: 3
            border.color: color2
            
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 30
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: ">> APPLYING THEME <<"
                    color: colorFg
                    font.family: "Monospace"
                    font.pixelSize: 18
                    font.bold: true
                    style: Text.Outline
                    styleColor: color2
                }
                
                Text {
                    id: spinnerText
                    Layout.alignment: Qt.AlignHCenter
                    text: "⠋"
                    color: colorFg
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
                    text: "Please wait..."
                    color: colorFg
                    font.family: "Monospace"
                    font.pixelSize: 12
                }
            }
        }
    }

    // Wallpaper picker popup - retro styled
    PanelWindow {
        id: wallpaperPopup

        visible: false
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
        }

        margins {
            left: 52
            top: 45
            bottom: 10
        }

        implicitWidth: 450
        
        Rectangle {
            anchors.fill: parent
            color: colorBg
            opacity: 0.98
            border.width: 3
            border.color: colorFg
            
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "🌀 FRACTALS"
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                        style: Text.Outline
                        styleColor: color2
                    }

                    Rectangle {
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 45
                        color: rndArea.pressed ? color3 : (rndArea.containsMouse ? color2 : color1)
                        border.width: 3
                        border.color: colorFg

                        Text {
                            anchors.centerIn: parent
                            text: "RND"
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 16
                            font.bold: true
                            style: Text.Outline
                            styleColor: color2
                        }

                        MouseArea {
                            id: rndArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: wallpaperPopup.generateRandomFractal()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 45
                        color: palArea.pressed ? color3 : (palArea.containsMouse ? color2 : color1)
                        border.width: paletteListVisible ? 3 : 2
                        border.color: paletteListVisible ? colorFg : color2

                        property bool paletteListVisible: false

                        Text {
                            anchors.centerIn: parent
                            text: "PAL"
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 16
                            font.bold: true
                            style: Text.Outline
                            styleColor: color2
                        }

                        MouseArea {
                            id: palArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: parent.paletteListVisible = !parent.paletteListVisible
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 45
                        Layout.preferredHeight: 45
                        color: closeArea.containsMouse ? color2 : color1
                        border.width: 2
                        border.color: colorFg

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: colorFg
                            font.pixelSize: 20
                        }

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: wallpaperPopup.visible = false
                        }
                    }
                }

                // Palette selection list (shown when PAL button is clicked)
                Rectangle {
                    id: paletteSection
                    Layout.fillWidth: true
                    Layout.preferredHeight: palArea.parent.paletteListVisible ? 280 : 0
                    visible: palArea.parent.paletteListVisible
                    color: color0
                    border.width: 2
                    border.color: color2
                    clip: true

                    Behavior on Layout.preferredHeight {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 5

                        Text {
                            text: ">> SELECT PALETTE <<"
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 12
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: paletteListModel
                            spacing: 4

                            delegate: Rectangle {
                                id: palDelegate
                                width: ListView.view ? ListView.view.width : 200
                                height: 36
                                color: palMouseArea.containsMouse ? color2 : color1
                                border.width: palMouseArea.containsMouse ? 2 : 1
                                border.color: color2

                                property string paletteName: model.name
                                property string paletteColors: model.colorStr || ""

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    spacing: 6

                                    Text {
                                        text: palDelegate.paletteName.replace(/_/g, " ")
                                        color: palMouseArea.containsMouse ? colorBg : colorFg
                                        font.family: "Monospace"
                                        font.pixelSize: 10
                                        font.bold: true
                                        Layout.preferredWidth: 120
                                        elide: Text.ElideRight
                                    }

                                    // Color swatches
                                    Row {
                                        Layout.fillWidth: true
                                        spacing: 1

                                        Repeater {
                                            model: palDelegate.paletteColors.length > 0 ? palDelegate.paletteColors.split(",").slice(0, 6) : []
                                            Rectangle {
                                                width: 14
                                                height: 20
                                                color: modelData
                                                border.width: 1
                                                border.color: "#00000040"
                                            }
                                        }
                                    }

                                    Text {
                                        text: "▶"
                                        color: palMouseArea.containsMouse ? colorBg : colorFg
                                        font.pixelSize: 12
                                        opacity: palMouseArea.containsMouse ? 1.0 : 0.3
                                    }
                                }

                                MouseArea {
                                    id: palMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: wallpaperPopup.generateWithPalette(palDelegate.paletteName)
                                }
                            }

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                            }
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    color: colorFg
                }
                
                Text {
                    id: statusText
                    Layout.fillWidth: true
                    text: wallpaperModel.count + " wallpapers"
                    color: colorFg
                    font.family: "Monospace"
                    opacity: 0.7
                    font.pixelSize: 16
                    visible: wallpaperModel.count > 0
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: colorBg
                    border.width: 2
                    border.color: colorFg
                    
                    ListView {
                        id: wallpaperList
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12
                        clip: true
                        
                        model: FolderListModel {
                            id: wallpaperModel
                            folder: "file:///home/breaks/Pictures/wallpapers"
                            nameFilters: ["*.png", "*.jpg"]
                            sortField: FolderListModel.Time
                            sortReversed: true
                            showDirs: false
                        }
                        
                        delegate: Rectangle {
                            width: wallpaperList.width - 10
                            height: 120
                            color: delegateArea.containsMouse ? color2 : color1
                            border.width: delegateArea.containsMouse ? 2 : 1
                            border.color: colorFg
                            
                            Behavior on border.width {
                                NumberAnimation { duration: 100 }
                            }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 12
                                
                                Rectangle {
                                    Layout.preferredWidth: 160
                                    Layout.fillHeight: true
                                    color: colorBg
                                    border.width: 2
                                    border.color: colorFg
                                    clip: true
                                    
                                    Image {
                                        anchors.fill: parent
                                        source: "file://" + model.filePath
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                        asynchronous: true
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "🌀"
                                            font.pixelSize: 48
                                            color: colorFg
                                            visible: parent.status === Image.Error || parent.status === Image.Null
                                        }
                                    }
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6
                                    
                                    Text {
                                        text: model.fileName
                                        color: colorFg
                                        font.family: "Monospace"
                                        font.pixelSize: 13
                                        font.bold: true
                                        elide: Text.ElideMiddle
                                        Layout.fillWidth: true
                                    }
                                    
                                    Text {
                                        text: Qt.formatDateTime(model.fileModified, "MMM dd, hh:mm")
                                        color: colorFg
                                        font.family: "Monospace"
                                        opacity: 0.6
                                        font.pixelSize: 11
                                    }
                                    
                                    Item { Layout.fillHeight: true }
                                    
                                    Text {
                                        text: ">> CLICK TO APPLY <<"
                                        color: colorFg
                                        font.family: "Monospace"
                                        opacity: delegateArea.containsMouse ? 1.0 : 0.5
                                        font.pixelSize: 11
                                        font.bold: true
                                        
                                        Behavior on opacity {
                                            NumberAnimation { duration: 150 }
                                        }
                                    }
                                }
                            }
                            
                            MouseArea {
                                id: delegateArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: wallpaperPopup.applyWallpaper(model.filePath)
                            }
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "NO WALLPAPERS FOUND\n\n>> GENERATE ONE WITH RND <<"
                        color: colorFg
                        font.family: "Monospace"
                        opacity: 0.5
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        visible: wallpaperModel.count === 0
                    }
                }
            }
        }
        
        // Store the path being applied so we can use it directly
        property string pendingWallpaperPath: ""
        
        function applyWallpaper(path) {
            // Hide picker, show progress
            wallpaperPopup.visible = false
            progressWindow.visible = true
            
            // Store the path for direct use in onExited
            pendingWallpaperPath = path

            // Use the dedicated apply script
            var cmd = Quickshell.env("HOME") + '/.local/bin/apply-wallpaper.sh "' + path + '"'
            applyProcess.command = ["bash", "-c", cmd]
            applyProcess.running = true
        }
        
        Process {
            id: applyProcess
            running: false
            
            onExited: (exitCode, exitStatus) => {
                // FIXED: Directly set the wallpaper since we know the path
                // Don't rely on swww query which may not be ready
                if (wallpaperPopup.pendingWallpaperPath.length > 0) {
                    bgWallpaper.opacity = 0
                    bgWallpaper.source = "file://" + wallpaperPopup.pendingWallpaperPath
                    bgWallpaper.opacity = 0.25
                    wallpaperPopup.pendingWallpaperPath = ""
                }
                // Also reload colors
                colorLoader.colorLines = []
                colorLoader.running = true
                // Close progress window
                progressWindow.visible = false
            }
        }
        
        function generateRandomFractal() {
            // Hide picker, show progress
            wallpaperPopup.visible = false
            progressWindow.visible = true

            var homeDir = Quickshell.env("HOME")
            genProcess.command = ["bash", homeDir + "/.local/bin/generate-flame.sh"]
            genProcess.running = true
        }

        function generateWithPalette(paletteName) {
            // Hide picker, show progress
            wallpaperPopup.visible = false
            progressWindow.visible = true

            var homeDir = Quickshell.env("HOME")
            genProcess.command = ["bash", homeDir + "/.local/bin/generate-flame.sh", paletteName]
            genProcess.running = true
        }

        Process {
            id: genProcess
            running: false

            onExited: (exitCode, exitStatus) => {
                // FIXED: Force immediate reload of wallpaper AND colors
                currentWallpaperLoader.running = true
                colorLoader.colorLines = []
                colorLoader.running = true
                // Close progress window
                progressWindow.visible = false
            }
        }
    }

    // GPU Info Popup - retro styled
    PanelWindow {
        id: gpuPopup

        visible: false
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        anchors {
            left: true
        }

        margins {
            left: 52
            top: 60
        }

        implicitWidth: 220
        implicitHeight: 120
        
        Rectangle {
            anchors.fill: parent
            color: colorBg
            opacity: 0.98
            border.width: 3
            border.color: colorFg
            
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                Text {
                    text: "🎮 GPU STATUS"
                    color: colorFg
                    font.family: "Monospace"
                    font.pixelSize: 16
                    font.bold: true
                    style: Text.Outline
                    styleColor: color2
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    color: colorFg
                }
                
                Text {
                    text: "TEMPERATURE"
                    color: colorFg
                    font.family: "Monospace"
                    opacity: 0.7
                    font.pixelSize: 11
                    font.bold: true
                }
                
                Text {
                    text: gpuTemp.value
                    color: colorFg
                    font.family: "Monospace"
                    font.pixelSize: 24
                    font.bold: true
                    style: Text.Outline
                    styleColor: color2
                }
            }
        }
    }

    // Terminal FX popup - retro styled
    PanelWindow {
        id: tfxPopup

        visible: false
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
        }

        margins {
            left: 52
            top: 45
            bottom: 10
        }

        implicitWidth: 340
        
        // Terminal apps list - commands with fallbacks for missing programs
        property var terminalApps: [
            { name: "CAVA", cmd: "cava || echo 'Install: sudo pacman -S cava'", icon: "♫", desc: "Audio Visualizer", category: "visual" },
            { name: "MATRIX", cmd: "cmatrix -b || cmatrix || echo 'Install: sudo pacman -S cmatrix'", icon: "▓", desc: "Digital Rain", category: "visual" },
            { name: "PIPES", cmd: "pipes.sh || pipes-rs || echo 'Install: yay -S pipes.sh'", icon: "╠", desc: "Animated Pipes", category: "visual" },
            { name: "FIRE", cmd: "aafire -driver curses || cacafire || echo 'Install: sudo pacman -S aalib or libcaca'", icon: "🔥", desc: "ASCII Fire", category: "visual" },
            { name: "AQUA", cmd: "asciiquarium || echo 'Install: yay -S asciiquarium'", icon: "🐟", desc: "ASCII Aquarium", category: "visual" },
            { name: "CLOCK", cmd: "tty-clock -c -C 2 -s || echo 'Install: yay -S tty-clock'", icon: "⏰", desc: "Terminal Clock", category: "realtime" },
            { name: "HTOP", cmd: "htop || echo 'Install: sudo pacman -S htop'", icon: "📊", desc: "Process Monitor", category: "realtime" },
            { name: "BTOP", cmd: "btop || echo 'Install: sudo pacman -S btop'", icon: "📈", desc: "Resource Monitor", category: "realtime" },
            { name: "NYAN", cmd: "nyancat || echo 'Install: yay -S nyancat'", icon: "🐱", desc: "Nyan Cat", category: "fun" },
            { name: "TRAIN", cmd: "sl || echo 'Install: sudo pacman -S sl'", icon: "🚂", desc: "Steam Locomotive", category: "fun" },
            { name: "FORTUNE", cmd: "which fortune && which lolcat && while true; do clear; fortune | lolcat; sleep 4; done || echo 'Install: sudo pacman -S fortune-mod lolcat'", icon: "🌈", desc: "Rainbow Fortune", category: "text" },
            { name: "FIGLET", cmd: "which figlet && which lolcat && while true; do clear; date '+%H:%M:%S' | figlet -f slant | lolcat; sleep 1; done || echo 'Install: sudo pacman -S figlet lolcat'", icon: "A", desc: "ASCII Clock", category: "text" },
            { name: "CBONSAI", cmd: "cbonsai -li || echo 'Install: yay -S cbonsai'", icon: "🌳", desc: "Bonsai Tree", category: "visual" },
            { name: "RAIN", cmd: "rain || echo 'Install: sudo pacman -S bsd-games'", icon: "🌧", desc: "Rain Drops", category: "visual" }
        ]
        
        Rectangle {
            anchors.fill: parent
            color: colorBg
            opacity: 0.98
            border.width: 3
            border.color: colorFg
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12
                
                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text {
                        text: "♫ TERM FX"
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                        style: Text.Outline
                        styleColor: color2
                    }
                    
                    Rectangle {
                        Layout.preferredWidth: 45
                        Layout.preferredHeight: 45
                        color: tfxCloseArea.containsMouse ? color2 : color1
                        border.width: 2
                        border.color: colorFg
                        
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: colorFg
                            font.pixelSize: 20
                        }
                        
                        MouseArea {
                            id: tfxCloseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: tfxPopup.visible = false
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    color: colorFg
                }
                
                // Legend
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Repeater {
                        model: [
                            { l: "VISUAL", c: color3 },
                            { l: "REALTIME", c: color4 },
                            { l: "FUN", c: color5 },
                            { l: "TEXT", c: color6 }
                        ]
                        
                        Rectangle {
                            Layout.preferredWidth: 70
                            Layout.preferredHeight: 20
                            color: "transparent"
                            border.width: 2
                            border.color: modelData.c
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData.l
                                color: modelData.c
                                font.family: "Monospace"
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }
                    }
                }
                
                // Apps list
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: colorBg
                    border.width: 2
                    border.color: colorFg
                    
                    ListView {
                        id: tfxList
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        clip: true
                        
                        model: tfxPopup.terminalApps
                        
                        delegate: Rectangle {
                            width: tfxList.width - 4
                            height: 54
                            color: tfxItemArea.containsMouse ? color1 : color0
                            border.width: tfxItemArea.containsMouse ? 3 : 2
                            border.color: {
                                switch(modelData.category) {
                                    case "visual": return color3
                                    case "realtime": return color4
                                    case "fun": return color5
                                    case "text": return color6
                                    default: return color2
                                }
                            }
                            
                            Behavior on border.width {
                                NumberAnimation { duration: 100 }
                            }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 12
                                
                                Text {
                                    text: modelData.icon
                                    color: colorFg
                                    font.pixelSize: 24
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    
                                    Text {
                                        text: modelData.name
                                        color: colorFg
                                        font.family: "Monospace"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    
                                    Text {
                                        text: modelData.desc
                                        color: colorFg
                                        font.family: "Monospace"
                                        opacity: 0.6
                                        font.pixelSize: 10
                                    }
                                }
                                
                                Text {
                                    text: "▶"
                                    color: colorFg
                                    font.pixelSize: 16
                                    opacity: tfxItemArea.containsMouse ? 1.0 : 0.3
                                    
                                    Behavior on opacity {
                                        NumberAnimation { duration: 150 }
                                    }
                                }
                            }
                            
                            MouseArea {
                                id: tfxItemArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: tfxPopup.launchApp(modelData.cmd)
                            }
                        }
                    }
                }
            }
        }
        
        function launchApp(cmd) {
            // Spawn kitty fully detached using setsid so multiple can launch
            // The Process will exit immediately after spawning
            var fullCmd = "setsid kitty " +
                "-o remember_window_size=no " +
                "-o initial_window_width=900 " +
                "-o initial_window_height=600 " +
                "-o background_opacity=0.92 " +
                "-o window_padding_width=10 " +
                "-o font_size=14 " +
                "-o confirm_os_window_close=0 " +
                "-e bash -c '" + cmd.replace(/'/g, "'\\''") + "; read -p \"Press Enter to close...\"' &"
            
            tfxLauncher.command = ["bash", "-c", fullCmd]
            tfxLauncher.running = true
        }
    }
    
    // TFX launcher process - just spawns detached kitty instances
    Process {
        id: tfxLauncher
        running: false
    }

    // Media player popup - MPRIS control
    PanelWindow {
        id: mediaPopup

        visible: false
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        anchors {
            left: true
            bottom: true
        }

        margins {
            left: 52
            bottom: 60
        }

        implicitWidth: 320
        implicitHeight: 200

        Rectangle {
            anchors.fill: parent
            color: colorBg
            opacity: 0.98
            border.width: 3
            border.color: colorFg

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12

                // Header with player name
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "♫ " + mprisMonitor.playerName
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        style: Text.Outline
                        styleColor: color2
                    }

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        color: closeMediaArea.containsMouse ? color2 : color1
                        border.width: 2
                        border.color: colorFg

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: colorFg
                            font.pixelSize: 14
                        }

                        MouseArea {
                            id: closeMediaArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mediaPopup.visible = false
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    color: colorFg
                }

                // Track info
                Text {
                    text: mprisMonitor.title || "No media playing"
                    color: colorFg
                    font.family: "Monospace"
                    font.pixelSize: 13
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: mprisMonitor.artist
                    color: colorFg
                    font.family: "Monospace"
                    font.pixelSize: 11
                    opacity: 0.8
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    visible: mprisMonitor.artist.length > 0
                }

                // Progress bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    color: color0
                    border.width: 1
                    border.color: color2

                    Rectangle {
                        width: parent.width * mprisMonitor.progress
                        height: parent.height
                        color: color2
                    }
                }

                // Controls
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15

                    // Previous
                    Rectangle {
                        Layout.preferredWidth: 45
                        Layout.preferredHeight: 40
                        color: prevArea.containsMouse ? color2 : color1
                        border.width: 2
                        border.color: colorFg

                        Text {
                            anchors.centerIn: parent
                            text: "⏮"
                            color: colorFg
                            font.pixelSize: 18
                        }

                        MouseArea {
                            id: prevArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mprisControl.previous()
                        }
                    }

                    // Play/Pause
                    Rectangle {
                        Layout.preferredWidth: 55
                        Layout.preferredHeight: 45
                        color: playArea.containsMouse ? color2 : color1
                        border.width: 3
                        border.color: colorFg

                        Text {
                            anchors.centerIn: parent
                            text: mprisMonitor.playing ? "⏸" : "▶"
                            color: colorFg
                            font.pixelSize: 22
                        }

                        MouseArea {
                            id: playArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mprisControl.playPause()
                        }
                    }

                    // Next
                    Rectangle {
                        Layout.preferredWidth: 45
                        Layout.preferredHeight: 40
                        color: nextArea.containsMouse ? color2 : color1
                        border.width: 2
                        border.color: colorFg

                        Text {
                            anchors.centerIn: parent
                            text: "⏭"
                            color: colorFg
                            font.pixelSize: 18
                        }

                        MouseArea {
                            id: nextArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mprisControl.next()
                        }
                    }
                }
            }
        }
    }

    // MPRIS Monitor
    QtObject {
        id: mprisMonitor
        property string playerName: "Media"
        property string title: ""
        property string artist: ""
        property bool playing: false
        property real progress: 0.0

        property var infoProcess: Process {
            command: ["bash", "-c", "playerctl metadata --format '{{playerName}}|{{title}}|{{artist}}|{{status}}' 2>/dev/null || echo '||Stopped'"]
            running: false

            stdout: SplitParser {
                onRead: data => {
                    var parts = data.trim().split("|")
                    if (parts.length >= 4) {
                        mprisMonitor.playerName = parts[0] || "Media"
                        mprisMonitor.title = parts[1] || ""
                        mprisMonitor.artist = parts[2] || ""
                        mprisMonitor.playing = parts[3] === "Playing"
                    }
                }
            }
        }

        property var progressProcess: Process {
            command: ["bash", "-c", "playerctl metadata --format '{{position}}|{{mpris:length}}' 2>/dev/null || echo '0|1'"]
            running: false

            stdout: SplitParser {
                onRead: data => {
                    var parts = data.trim().split("|")
                    if (parts.length >= 2) {
                        var pos = parseInt(parts[0]) || 0
                        var len = parseInt(parts[1]) || 1
                        mprisMonitor.progress = len > 0 ? pos / len : 0
                    }
                }
            }
        }

        property var updateTimer: Timer {
            interval: 1000
            running: mediaPopup.visible
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                mprisMonitor.infoProcess.running = true
                mprisMonitor.progressProcess.running = true
            }
        }
    }

    // MPRIS Control
    QtObject {
        id: mprisControl

        function playPause() {
            playPauseProcess.running = true
        }

        function next() {
            nextProcess.running = true
        }

        function previous() {
            prevProcess.running = true
        }

        property var playPauseProcess: Process {
            command: ["playerctl", "play-pause"]
            running: false
            onExited: mprisMonitor.infoProcess.running = true
        }

        property var nextProcess: Process {
            command: ["playerctl", "next"]
            running: false
            onExited: mprisMonitor.infoProcess.running = true
        }

        property var prevProcess: Process {
            command: ["playerctl", "previous"]
            running: false
            onExited: mprisMonitor.infoProcess.running = true
        }
    }

    // Sidebar visibility state
    property bool sidebarVisible: true

    // Watch for toggle signal file
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: sidebarToggleChecker.running = true
    }

    Process {
        id: sidebarToggleChecker
        command: ["bash", "-c", "if [ -f ~/.cache/sidebar-toggle ]; then rm -f ~/.cache/sidebar-toggle; echo 'toggle'; fi"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                if (data.trim() === "toggle") {
                    root.sidebarVisible = !root.sidebarVisible
                    console.log("Sidebar toggled:", root.sidebarVisible)
                }
            }
        }
    }

    // Main compact sidebar - RETRO STYLE
    PanelWindow {
        id: sidebar

        visible: root.sidebarVisible

        anchors {
            left: true
            top: true
            bottom: true
        }

        margins {
            top: 0
        }

        implicitWidth: 48
        color: "transparent"
        
        Rectangle {
            anchors.fill: parent
            color: colorBg
            opacity: 0.92
            border.width: 3
            border.color: colorFg
            
            // Current wallpaper background - faster breathing
            Rectangle {
                anchors.fill: parent
                color: colorBg
                clip: true
                
                Image {
                    id: bgWallpaper
                    anchors.centerIn: parent
                    width: parent.width * 1.5
                    height: parent.height * 1.5
                    fillMode: Image.PreserveAspectCrop
                    opacity: 0.25
                    source: ""
                    smooth: true
                    
                    // Faster breathing animation
                    scale: 1.0
                    
                    SequentialAnimation on scale {
                        running: true
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 1.2; duration: 6000; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 1.2; to: 1.0; duration: 6000; easing.type: Easing.InOutSine }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 1500; easing.type: Easing.InOutQuad }
                    }
                }
                
                // Load current wallpaper on startup
                Timer {
                    interval: 500
                    running: true
                    onTriggered: currentWallpaperLoader.running = true
                }
            }
            
            
            // Color pulse overlay
            Rectangle {
                anchors.fill: parent
                opacity: 0.08
                color: colorFg
                
                SequentialAnimation on opacity {
                    running: true
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.05; to: 0.12; duration: 5000; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 0.12; to: 0.05; duration: 5000; easing.type: Easing.InOutQuad }
                }
            }
            
            Process {
                id: currentWallpaperLoader
                command: ["bash", "-c", "swww query | grep -oP 'image: \\K.*' | head -1 || ls -t ~/Pictures/wallpapers/*.png 2>/dev/null | head -1"]
                running: false
                
                stdout: SplitParser {
                    onRead: data => {
                        var path = data.trim()
                        if (path.length > 0 && path !== bgWallpaper.source.toString().replace("file://", "")) {
                            bgWallpaper.opacity = 0
                            bgWallpaper.source = "file://" + path
                            bgWallpaper.opacity = 0.25
                        }
                    }
                }
            }
            
            // FIXED: Watch for wallpaper-changed signal file (standardized)
            // Check if file EXISTS, then consume it
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    wallpaperChangeChecker.running = true
                }
            }
            
            Process {
                id: wallpaperChangeChecker
                // Check if signal file exists (don't delete immediately - let topbar see it too)
                command: ["bash", "-c", "if [ -f ~/.cache/wallpaper-changed ]; then echo 'reload'; fi"]
                running: false

                stdout: SplitParser {
                    onRead: data => {
                        if (data.trim() === "reload") {
                            console.log("Sidebar: Wallpaper change detected, reloading...")
                            currentWallpaperLoader.running = true
                            // Also reload colors
                            colorLoader.colorLines = []
                            colorLoader.running = true
                            // Delete signal file after delay so topbar can see it
                            signalFileCleanup.running = true
                        }
                    }
                }
            }

            // Delayed cleanup of signal file (gives topbar time to detect it)
            Process {
                id: signalFileCleanup
                command: ["bash", "-c", "sleep 3 && rm -f ~/.cache/wallpaper-changed"]
                running: false
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 8
                
                // GPU
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    color: gpuArea.containsMouse ? color0 : colorBg
                    border.width: gpuPopup.visible ? 3 : 2
                    border.color: gpuPopup.visible ? colorFg : color2
                    
                    Text {
                        anchors.centerIn: parent
                        text: "GPU"
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 16
                        font.bold: true
                        style: Text.Outline
                        styleColor: color2
                    }
                    
                    MouseArea {
                        id: gpuArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: gpuPopup.visible = !gpuPopup.visible
                    }
                }
                
                // FPS
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    color: fpsArea.containsMouse ? color0 : colorBg
                    border.width: fpsEnabled ? 3 : 2
                    border.color: fpsEnabled ? colorFg : color2
                    
                    property bool fpsEnabled: false
                    
                    Text {
                        anchors.centerIn: parent
                        text: "FPS"
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 16
                        font.bold: true
                        style: Text.Outline
                        styleColor: color2
                    }
                    
                    MouseArea {
                        id: fpsArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: parent.fpsEnabled = !parent.fpsEnabled
                    }
                }
                
                // Performance (cycles: ECO → BAL → MAX)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    color: perfArea.containsMouse ? color0 : colorBg
                    border.width: perfMode !== 0 ? 3 : 2
                    border.color: perfMode === 2 ? colorFg : color2
                    
                    property int perfMode: 0  // 0=ECO, 1=BAL, 2=MAX
                    
                    Text {
                        anchors.centerIn: parent
                        text: parent.perfMode === 0 ? "ECO" : (parent.perfMode === 1 ? "BAL" : "MAX")
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 16
                        font.bold: true
                        style: Text.Outline
                        styleColor: color2
                    }
                    
                    MouseArea {
                        id: perfArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            parent.perfMode = (parent.perfMode + 1) % 3
                        }
                    }
                }
                
                // Recording
                Rectangle {
                    id: recButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    color: recArea.containsMouse ? color0 : colorBg
                    border.width: recording ? 3 : 2
                    border.color: recording ? "#ff0000" : color2
                    
                    property bool recording: false
                    
                    Text {
                        anchors.centerIn: parent
                        text: "REC"
                        color: recButton.recording ? "#ff0000" : colorFg
                        font.family: "Monospace"
                        font.pixelSize: 16
                        font.bold: true
                        style: Text.Outline
                        styleColor: recButton.recording ? "#ff0000" : color2
                    }
                    
                    // Blink when recording
                    SequentialAnimation on opacity {
                        running: recButton.recording
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.5; duration: 500 }
                        NumberAnimation { to: 1.0; duration: 500 }
                    }
                    
                    MouseArea {
                        id: recArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: recButton.recording = !recButton.recording
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    color: colorFg
                    opacity: 0.3
                }
                
                Item { Layout.fillHeight: true }
                
                // Terminal FX - show off button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: tfxArea.containsMouse ? color0 : colorBg
                    border.width: tfxPopup.visible ? 3 : 2
                    border.color: tfxPopup.visible ? colorFg : color2
                    
                    Text {
                        anchors.centerIn: parent
                        text: "TFX"
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 16
                        font.bold: true
                        style: Text.Outline
                        styleColor: color2
                    }
                    
                    MouseArea {
                        id: tfxArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            wallpaperPopup.visible = false
                            tfxPopup.visible = !tfxPopup.visible
                        }
                    }
                }
                
                // Wallpaper - show off button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: wallpaperArea.containsMouse ? color0 : colorBg
                    border.width: wallpaperPopup.visible ? 3 : 2
                    border.color: wallpaperPopup.visible ? colorFg : color2

                    Text {
                        anchors.centerIn: parent
                        text: "WAL"
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 16
                        font.bold: true
                        style: Text.Outline
                        styleColor: color2
                    }

                    MouseArea {
                        id: wallpaperArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            tfxPopup.visible = false
                            mediaPopup.visible = false
                            wallpaperPopup.visible = !wallpaperPopup.visible
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    color: colorFg
                    opacity: 0.3
                }

                // Media player button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: mediaArea.containsMouse ? color0 : colorBg
                    border.width: mediaPopup.visible ? 3 : 2
                    border.color: mediaPopup.visible ? colorFg : color2

                    Text {
                        anchors.centerIn: parent
                        text: "♫"
                        color: colorFg
                        font.pixelSize: 22
                        font.bold: true
                    }

                    MouseArea {
                        id: mediaArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            tfxPopup.visible = false
                            wallpaperPopup.visible = false
                            mediaPopup.visible = !mediaPopup.visible
                        }
                    }
                }

            }
        }
    }
    
    // GPU temp monitor
    QtObject {
        id: gpuTemp
        property string value: "..."
        
        property var tempProcess: Process {
            command: ["bash", "-c", "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null || sensors 2>/dev/null | grep -i 'edge' | awk '{print $2}' | head -1 | tr -d '+°C' || echo '??'"]
            running: false
            
            stdout: SplitParser {
                onRead: data => {
                    var temp = data.trim()
                    if (temp && temp !== "??" && temp !== "") {
                        gpuTemp.value = temp + "°C"
                    } else {
                        gpuTemp.value = "N/A"
                    }
                }
            }
        }
        
        property var updateTimer: Timer {
            interval: 2500
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: gpuTemp.tempProcess.running = true
        }
    }
}
