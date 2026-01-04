// QuickShell Gaming Sidebar - Retro Waybar Style
// Matching the scanline/glow aesthetic
import QtQuick
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
    
    Component.onCompleted: {
        console.log("🎮 Retro Gaming Sidebar - Waybar Style")
    }
    
    // Load pywal colors
    Process {
        id: colorLoader
        command: ["bash", "-c", "jq -r '.special.background, .special.foreground, .colors.color0, .colors.color1, .colors.color2, .colors.color3, .colors.color4' ~/.cache/wal/colors.json 2>/dev/null"]
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
            if (colorLoader.colorLines.length >= 7) {
                colorBg = colorLoader.colorLines[0]
                colorFg = colorLoader.colorLines[1]
                color0 = colorLoader.colorLines[2]
                color1 = colorLoader.colorLines[3]
                color2 = colorLoader.colorLines[4]
                color3 = colorLoader.colorLines[5]
                color4 = colorLoader.colorLines[6]
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

    // Progress window for wallpaper operations
    PanelWindow {
        id: progressWindow
        
        visible: false
        color: "transparent"
        
        anchors {
            left: true
        }
        
        margins {
            left: 50
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
            
            // Scanline effect
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = color2
                    ctx.globalAlpha = 0.1
                    ctx.lineWidth = 1
                    
                    for (var y = 0; y < height; y += 2) {
                        ctx.beginPath()
                        ctx.moveTo(0, y)
                        ctx.lineTo(width, y)
                        ctx.stroke()
                    }
                }
                
                Component.onCompleted: requestPaint()
            }
            
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
        
        anchors {
            top: true
            bottom: true
            left: true
        }
        
        margins {
            left: 50
            top: 0
        }
        
        implicitWidth: 450
        
        Rectangle {
            anchors.fill: parent
            color: colorBg
            opacity: 0.98
            border.width: 3
            border.color: colorFg
            
            // Scanline effect
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = color2
                    ctx.globalAlpha = 0.1
                    ctx.lineWidth = 1
                    
                    for (var y = 0; y < height; y += 2) {
                        ctx.beginPath()
                        ctx.moveTo(0, y)
                        ctx.lineTo(width, y)
                        ctx.stroke()
                    }
                }
                
                Component.onCompleted: requestPaint()
            }
            
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
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 45
                        color: rndArea.pressed ? color3 : (rndArea.containsMouse ? color2 : color1)
                        border.width: 3
                        border.color: colorFg
                        
                        Text {
                            anchors.centerIn: parent
                            text: "RND"
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 18
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
        
        function applyWallpaper(path) {
            // Hide picker, show progress
            wallpaperPopup.visible = false
            progressWindow.visible = true

            var cmd = 'wal -i "' + path + '" -a 85 -q && '
            cmd += Quickshell.env("HOME") + '/.local/bin/update-niri-colors.sh && '
            cmd += Quickshell.env("HOME") + '/.local/bin/generate-qt-theme.sh && '
            cmd += 'sleep 2 && '
            cmd += 'cp ~/.cache/wal/retro.rasi ~/.config/rofi/retro.rasi && '
            cmd += 'cp ~/.cache/wal/mako-config ~/.config/mako/config && '
            cmd += '~/.local/bin/update-niri-colors.sh && '
            cmd += '~/.local/bin/update-floorp-theme.sh && '
            cmd += '~/.local/bin/create-gtk-theme.sh 2>/dev/null && '
            cmd += '~/.local/bin/update-sddm-theme.sh 2>/dev/null && '
            cmd += '~/.local/bin/update-wlogout-theme.sh 2>/dev/null && '
            cmd += 'killall mako 2>/dev/null; sleep 0.5 && '
            cmd += 'killall thunar 2>/dev/null & '
            cmd += 'killall swaybg 2>/dev/null; sleep 0.3 && '
            cmd += 'swaybg -i "' + path + '" -m fill & '
            cmd += 'sleep 0.3 && '
            cmd += 'systemctl --user restart quickshell-topbar.service && '
            cmd += 'systemctl --user start mako.service && '
            cmd += 'touch ~/.cache/wallpaper-changed'

            applyProcess.command = ["bash", "-c", cmd]
            applyProcess.running = true
        }
        
        Process {
            id: applyProcess
            running: false
            
            onExited: (exitCode, exitStatus) => {
                // Update sidebar background
                currentWallpaperLoader.running = true
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
        
        Process {
            id: genProcess
            running: false
            
            onExited: (exitCode, exitStatus) => {
                // Reload wallpapers in sidebar
                currentWallpaperLoader.running = true
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
        
        anchors {
            left: true
        }
        
        margins {
            left: 50
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
            
            // Scanline effect
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = color2
                    ctx.globalAlpha = 0.1
                    ctx.lineWidth = 1
                    
                    for (var y = 0; y < height; y += 2) {
                        ctx.beginPath()
                        ctx.moveTo(0, y)
                        ctx.lineTo(width, y)
                        ctx.stroke()
                    }
                }
                
                Component.onCompleted: requestPaint()
            }
            
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

    // Main compact sidebar - RETRO STYLE
    PanelWindow {
        id: sidebar
        
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
            
            // Scanline overlay
            Canvas {
                anchors.fill: parent
                opacity: 0.15
                
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = color2
                    ctx.lineWidth = 1
                    
                    for (var y = 0; y < height; y += 2) {
                        ctx.beginPath()
                        ctx.moveTo(0, y)
                        ctx.lineTo(width, y)
                        ctx.stroke()
                    }
                }
                
                Component.onCompleted: requestPaint()
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
                command: ["bash", "-c", "pgrep -a swaybg | grep -oP '(?<=-i )[^ ]+' | head -1 || ls -t ~/Pictures/wallpapers/*.png 2>/dev/null | head -1"]
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
            
            // Start watcher when popup opens
            Component.onCompleted: {
                if (wallpaperPopup.visible) {
                    watcherStarter.running = true
                }
            }
            
            onVisibleChanged: {
                if (visible) {
                    watcherStarter.running = true
                }
            }
            
            Process {
                id: watcherStarter
                command: ["bash", Quickshell.env("HOME") + "/.local/bin/wallpaper-watcher.sh"]
                running: false
            }
            
            // Check if watcher detected change (by checking if signal file is gone AND PID file is gone)
            Timer {
                interval: 2000
                running: wallpaperPopup.visible
                repeat: true
                onTriggered: {
                    watcherChecker.running = true
                }
            }
            
            Process {
                id: watcherChecker
                command: ["bash", "-c", "if [ ! -f ~/.cache/wallpaper-watcher.pid ] && [ ! -f ~/.cache/wallpaper-changed ]; then echo 'changed'; fi"]
                running: false
                
                stdout: SplitParser {
                    onRead: data => {
                        if (data.trim() === "changed") {
                            currentWallpaperLoader.running = true
                        }
                    }
                }
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
                        styleColor: recButton.recording ? "#ff0000" : colorFg
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
                
                // Wallpaper
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
                        onClicked: wallpaperPopup.visible = !wallpaperPopup.visible
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
