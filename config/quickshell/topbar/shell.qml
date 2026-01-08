// [NIRI-FRACTAL-RICE]
//@ pragma UseQApplication

// Quickshell Retro Gaming Top Bar - Full Featured
// Complete waybar replacement with all modules
// FIXED: Standardized wallpaper change detection
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.SystemTray

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
    
    Component.onCompleted: {
        console.log("🎮 Retro Gaming Top Bar - Full Featured")
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

    // Volume OSD popup
    PanelWindow {
        id: volumeOSD

        visible: false
        color: "transparent"

        anchors {
            top: true
            right: true
        }

        margins {
            top: 50
            right: 20
        }

        implicitWidth: 300
        implicitHeight: 100

        Rectangle {
            anchors.fill: parent
            color: colorBg
            opacity: 0.98
            border.width: 3
            border.color: color2


            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Text {
                    text: audioMonitor.muted ? "VOL:MUTE" : "VOL:" + audioMonitor.volume + "%"
                    color: colorFg
                    font.family: "Monospace"
                    font.pixelSize: 18
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                    style: Text.Outline
                    styleColor: color2
                }

                // Visual progress bar (no ASCII text)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: colorBg
                    border.width: 2
                    border.color: color2

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: audioMonitor.muted ? 0 : (parent.width * audioMonitor.volume / 100)
                        color: colorFg

                        Behavior on width {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }
            }
        }

        Timer {
            id: osdHideTimer
            interval: 2000
            onTriggered: volumeOSD.visible = false
        }

        function show() {
            volumeOSD.visible = true
            osdHideTimer.restart()
        }
    }

    // Audio output switcher popup
    PanelWindow {
        id: audioSwitcher
        
        visible: false
        color: "transparent"
        
        anchors {
            top: true
            right: true
        }
        
        margins {
            top: 50
            right: 20
        }
        
        implicitWidth: 400
        implicitHeight: Math.min(audioDeviceModel.count * 60 + 100, 500)
        
        Rectangle {
            anchors.fill: parent
            color: colorBg
            opacity: 0.98
            border.width: 3
            border.color: color2
            
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: ">> AUDIO OUTPUT <<"
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 16
                        font.bold: true
                        Layout.fillWidth: true
                        style: Text.Outline
                        styleColor: color2
                    }
                    
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        color: closeArea.containsMouse ? color2 : color1
                        border.width: 2
                        border.color: color2
                        
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
                            onClicked: audioSwitcher.visible = false
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    color: colorFg
                }
                
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8
                    clip: true
                    
                    model: ListModel {
                        id: audioDeviceModel
                    }
                    
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 50
                        color: deviceArea.containsMouse ? color2 : (model.isDefault ? color1 : color0)
                        border.width: model.isDefault ? 3 : 2
                        border.color: model.isDefault ? colorFg : color2
                        
                        Text {
                            anchors.centerIn: parent
                            anchors.leftMargin: 15
                            text: (model.isDefault ? ">>> " : "    ") + model.name + (model.isDefault ? " <<<" : "")
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 14
                            font.bold: model.isDefault
                            elide: Text.ElideRight
                            width: parent.width - 30
                        }
                        
                        MouseArea {
                            id: deviceArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: audioSwitcher.switchToDevice(model.sink)
                        }
                    }
                }
            }
        }
        
        Component.onCompleted: {
            loadAudioDevices()
        }
        
        onVisibleChanged: {
            if (visible) {
                loadAudioDevices()
            }
        }
        
        function loadAudioDevices() {
            audioDeviceLoader.running = true
        }
        
        function switchToDevice(sinkName) {
            audioSwitchProcess.command = ["pactl", "set-default-sink", sinkName]
            audioSwitchProcess.running = true
            audioSwitcher.visible = false
        }
        
        Process {
            id: audioDeviceLoader
            command: ["bash", "-c", "default=$(pactl get-default-sink); pactl list short sinks | while read -r line; do sink=$(echo \"$line\" | awk '{print $2}'); desc=$(pactl list sinks | grep -A20 \"Name: $sink\" | grep 'Description:' | cut -d: -f2 | xargs); isDefault='false'; if [ \"$sink\" = \"$default\" ]; then isDefault='true'; fi; echo \"$sink|$desc|$isDefault\"; done"]
            running: false
            
            stdout: SplitParser {
                onRead: data => {
                    var line = data.trim()
                    if (line.length > 0) {
                        var parts = line.split("|")
                        if (parts.length === 3) {
                            audioDeviceModel.append({
                                sink: parts[0],
                                name: parts[1],
                                isDefault: parts[2] === "true"
                            })
                        }
                    }
                }
            }
            
            onStarted: {
                audioDeviceModel.clear()
            }
        }
        
        Process {
            id: audioSwitchProcess
            running: false
            
            onExited: (exitCode, exitStatus) => {
                // Reload audio monitor
                audioMonitor.volProcess.running = true
            }
        }
    }

    // Main top bar
    // Topbar - shows on all screens
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            required property var modelData
            screen: modelData
            
            id: topbar
            
            // Per-screen workspace model
            property var workspaceModel: ListModel {}
            property string screenName: modelData.name
            property bool isPrimary: modelData.primary !== undefined ? modelData.primary : (modelData.name === "DP-1")
            property string windowTitle: "Desktop"
            
            anchors {
                top: true
                left: true
                right: true
            }
            
            margins {
                top: 0
                left: 0
                right: 0
            }
            
            implicitHeight: 41
            color: "transparent"
        
        Rectangle {
            anchors.fill: parent
            color: colorBg
            border.width: 3
            border.color: color2
            
            // Current wallpaper background - breathing animation
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
                    opacity: 0.15
                    source: ""
                    smooth: true
                    
                    // Breathing animation
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
                    onTriggered: wallpaperLoader.running = true
                }
                
                Process {
                    id: wallpaperLoader
                    command: ["bash", "-c", "swww query | grep -oP 'image: \\K.*' | head -1 || ls -t ~/Pictures/wallpapers/*.png 2>/dev/null | head -1"]
                    running: false
                    
                    stdout: SplitParser {
                        onRead: data => {
                            var path = data.trim()
                            if (path.length > 0) {
                                bgWallpaper.source = "file://" + path
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
                        wallpaperReloadChecker.running = true
                    }
                }

                Process {
                    id: wallpaperReloadChecker
                    // FIXED: Check if file EXISTS (standardized signal file)
                    // Note: We don't consume it here - let sidebar handle that
                    // We just check and reload if it exists
                    command: ["bash", "-c", "if [ -f ~/.cache/wallpaper-changed ]; then echo 'reload'; fi"]
                    running: false

                    stdout: SplitParser {
                        onRead: data => {
                            if (data.trim() === "reload") {
                                console.log("Topbar: Wallpaper change detected, reloading...")
                                wallpaperLoader.running = true
                                // Also reload colors
                                colorLoader.colorLines = []
                                colorLoader.running = true
                            }
                        }
                    }
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
            
            
            // Window title - absolutely centered overlay
            Text {
                anchors.centerIn: parent
                text: ">> " + topbar.windowTitle + " <<"
                color: colorFg
                font.family: "Monospace"
                font.pixelSize: 16
                font.bold: true
                style: Text.Outline
                styleColor: color2
                horizontalAlignment: Text.AlignHCenter
                z: 10
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 8
                
                // LEFT: Clock + Workspaces
                RowLayout {
                    Layout.fillHeight: true
                    spacing: 8
                    
                    // Clock
                    Rectangle {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: clockText.width + 32
                        color: colorBg
                        border.width: 3
                        border.color: color2
                        
                        Text {
                            id: clockText
                            anchors.centerIn: parent
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 14
                            font.bold: true
                            text: "[ " + Qt.formatTime(clockTimer.currentTime, "HH:mm:ss") + " ]"
                            style: Text.Outline
                            styleColor: color2
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                clockTimer.showDate = !clockTimer.showDate
                                clockText.text = clockTimer.showDate ? 
                                    "[ " + Qt.formatDate(clockTimer.currentTime, "yyyy-MM-dd") + " ]" :
                                    "[ " + Qt.formatTime(clockTimer.currentTime, "HH:mm:ss") + " ]"
                            }
                        }
                    }
                    
                    // Dynamic workspaces from niri
                    RowLayout {
                        Layout.fillHeight: true
                        spacing: 6
                        
                        Repeater {
                            model: topbar.workspaceModel
                            
                            Rectangle {
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 30
                                color: colorBg
                                border.width: model.active ? 3 : 2
                                border.color: model.active ? colorFg : color2
                                
                                // Glow effect
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: -2
                                    color: "transparent"
                                    border.width: 1
                                    border.color: model.active ? colorFg : color2
                                    opacity: 0.3
                                    z: -1
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "[" + model.id + "]"
                                    color: colorFg
                                    font.family: "Monospace"
                                    font.pixelSize: 18
                                    font.bold: true
                                    style: Text.Outline
                                    styleColor: color2
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onEntered: parent.color = color0
                                    onExited: parent.color = colorBg
                                    onClicked: {
                                        workspaceSwitcher.command = ["niri", "msg", "action", "focus-workspace", model.id.toString()]
                                        workspaceSwitcher.running = true
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Spacer
                Item { Layout.fillWidth: true }
                
                // RIGHT: System stats (only on primary monitor)
                RowLayout {
                    Layout.fillHeight: true
                    spacing: 8
                    visible: topbar.isPrimary
                    
                    // Volume with OSD
                    Rectangle {
                        Layout.preferredWidth: volText.width + 24
                        Layout.preferredHeight: 30
                        color: volArea.containsMouse ? color0 : colorBg
                        border.width: 2
                        border.color: color2
                        
                        Text {
                            id: volText
                            anchors.centerIn: parent
                            text: audioMonitor.muted ? "VOL:MUTE" : ("VOL:" + audioMonitor.volume + "%")
                            color: audioMonitor.muted ? color8 : colorFg
                            font.family: "Monospace"
                            font.pixelSize: 16
                            font.bold: true
                            style: Text.Outline
                            styleColor: color2
                        }
                        
                        MouseArea {
                            id: volArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                volumeToggle.running = true
                                volumeOSD.show()
                            }
                            onWheel: wheel => {
                                if (wheel.angleDelta.y > 0) {
                                    volumeUp.running = true
                                } else {
                                    volumeDown.running = true
                                }
                                volumeOSD.show()
                            }
                        }
                    }
                    
                    // Audio output switcher
                    Rectangle {
                        Layout.preferredWidth: audText.width + 24
                        Layout.preferredHeight: 30
                        color: audArea.containsMouse ? color0 : colorBg
                        border.width: audioSwitcher.visible ? 3 : 2
                        border.color: audioSwitcher.visible ? colorFg : color2
                        
                        // Glow effect
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -2
                            color: "transparent"
                            border.width: 1
                            border.color: audioSwitcher.visible ? colorFg : color2
                            opacity: 0.3
                            z: -1
                        }
                        
                        Text {
                            id: audText
                            anchors.centerIn: parent
                            text: "[AUD]"
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 16
                            font.bold: true
                            style: Text.Outline
                            styleColor: color2
                        }
                        
                        MouseArea {
                            id: audArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: audioSwitcher.visible = !audioSwitcher.visible
                        }
                    }
                    
                    // Network
                    Rectangle {
                        Layout.preferredWidth: netText.width + 24
                        Layout.preferredHeight: 30
                        color: colorBg
                        border.width: 2
                        border.color: color2
                        
                        Text {
                            id: netText
                            anchors.centerIn: parent
                            text: networkMonitor.status
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 16
                            font.bold: true
                            style: Text.Outline
                            styleColor: color2
                        }
                    }
                    
                    // CPU
                    Rectangle {
                        Layout.preferredWidth: cpuText.width + 24
                        Layout.preferredHeight: 30
                        color: cpuArea.containsMouse ? color0 : colorBg
                        border.width: 2
                        border.color: color2
                        
                        Text {
                            id: cpuText
                            anchors.centerIn: parent
                            text: "CPU:" + cpuMonitor.usage + "%"
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 16
                            font.bold: true
                            style: Text.Outline
                            styleColor: color2
                        }
                        
                        MouseArea {
                            id: cpuArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btopLauncher.running = true
                        }
                    }
                    
                    // Memory
                    Rectangle {
                        Layout.preferredWidth: memText.width + 24
                        Layout.preferredHeight: 30
                        color: memArea.containsMouse ? color0 : colorBg
                        border.width: 2
                        border.color: color2
                        
                        Text {
                            id: memText
                            anchors.centerIn: parent
                            text: "RAM:" + memMonitor.usage + "%"
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 16
                            font.bold: true
                            style: Text.Outline
                            styleColor: color2
                        }
                        
                        MouseArea {
                            id: memArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btopLauncher.running = true
                        }
                    }
                    
                    // Temperature
                    Rectangle {
                        Layout.preferredWidth: tempText.width + 24
                        Layout.preferredHeight: 30
                        color: tempArea.containsMouse ? color0 : colorBg
                        border.width: 2
                        border.color: tempMonitor.critical ? color1 : color2
                        
                        // Glow effect
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -2
                            color: "transparent"
                            border.width: 1
                            border.color: tempMonitor.critical ? color1 : color2
                            opacity: 0.3
                            z: -1
                        }
                        
                        Text {
                            id: tempText
                            anchors.centerIn: parent
                            text: "TEMP:" + tempMonitor.temp + "°C"
                            color: tempMonitor.critical ? color1 : colorFg
                            font.family: "Monospace"
                            font.pixelSize: 16
                            font.bold: true
                            style: Text.Outline
                            styleColor: tempMonitor.critical ? color1 : color2
                        }
                        
                        SequentialAnimation on opacity {
                            running: tempMonitor.critical
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.5; duration: 500 }
                            NumberAnimation { to: 1.0; duration: 500 }
                        }
                        
                        MouseArea {
                            id: tempArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btopLauncher.running = true
                        }
                    }
                    
                    // Battery (only show if battery exists and not at 100%)
                    Rectangle {
                        Layout.preferredWidth: batText.width + 24
                        Layout.preferredHeight: 30
                        color: colorBg
                        border.width: 2
                        border.color: batteryMonitor.critical ? color1 : (batteryMonitor.warning ? color3 : color2)
                        visible: batteryMonitor.hasBattery && (batteryMonitor.capacity < 99 || !batteryMonitor.charging)
                        
                        Text {
                            id: batText
                            anchors.centerIn: parent
                            text: batteryMonitor.charging ? "CHG:" + batteryMonitor.capacity + "%" : "BAT:" + batteryMonitor.capacity + "%"
                            color: batteryMonitor.critical ? color1 : colorFg
                            font.family: "Monospace"
                            font.pixelSize: 16
                            font.bold: true
                            style: Text.Outline
                            styleColor: color2
                        }
                        
                        SequentialAnimation on opacity {
                            running: batteryMonitor.charging
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.7; duration: 2000 }
                            NumberAnimation { to: 1.0; duration: 2000 }
                        }
                        
                        SequentialAnimation on opacity {
                            running: batteryMonitor.critical && !batteryMonitor.charging
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.5; duration: 500 }
                            NumberAnimation { to: 1.0; duration: 500 }
                        }
                    }
                    
                    // System Tray
                    Repeater {
                        model: SystemTray.items
                        
                        Rectangle {
                            id: trayItemRect
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            color: trayMouseArea.containsMouse ? color0 : colorBg
                            border.width: 2
                            border.color: color2
                            
                            Image {
                                anchors.centerIn: parent
                                width: 20
                                height: 20
                                source: modelData.icon
                                sourceSize.width: 20
                                sourceSize.height: 20
                                smooth: true
                            }
                            
                            MouseArea {
                                id: trayMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                
                                onClicked: mouse => {
                                    console.log("Tray clicked:", modelData.id, "hasMenu:", modelData.hasMenu, "onlyMenu:", modelData.onlyMenu)
                                    
                                    if (mouse.button === Qt.LeftButton) {
                                        if (modelData.onlyMenu) {
                                            console.log("Display menu (onlyMenu)")
                                            var globalPos = mapToItem(null, 0, height)
                                            modelData.display(topbar, globalPos.x, globalPos.y)
                                        } else {
                                            console.log("Activate")
                                            modelData.activate()
                                        }
                                    } else if (mouse.button === Qt.RightButton) {
                                        console.log("Right click - hasMenu:", modelData.hasMenu)
                                        if (modelData.hasMenu) {
                                            var globalPos = mapToItem(null, 0, height)
                                            console.log("Calling display at x:", globalPos.x, "y:", globalPos.y)
                                            modelData.display(topbar, globalPos.x, globalPos.y)
                                        }
                                    } else if (mouse.button === Qt.MiddleButton) {
                                        console.log("Secondary activate")
                                        modelData.secondaryActivate()
                                    }
                                }
                            }
                        }
                    }
                    
                    // Caffeine
                    Rectangle {
                        Layout.preferredWidth: cafText.width + 24
                        Layout.preferredHeight: 30
                        color: caffeineMonitor.active ? color0 : colorBg
                        border.width: 2
                        border.color: caffeineMonitor.active ? color3 : color2
                        
                        // Glow effect
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -2
                            color: "transparent"
                            border.width: 1
                            border.color: caffeineMonitor.active ? color3 : color2
                            opacity: 0.3
                            z: -1
                        }
                        
                        Text {
                            id: cafText
                            anchors.centerIn: parent
                            text: caffeineMonitor.text
                            color: caffeineMonitor.active ? color3 : colorFg
                            font.family: "Monospace"
                            font.pixelSize: 16
                            font.bold: true
                            style: Text.Outline
                            styleColor: caffeineMonitor.active ? color3 : color2
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: caffeineToggle.running = true
                        }
                    }
                }
            }
        }
        
        // Per-screen workspace monitor
        QtObject {
            id: screenWorkspaceMonitor
            
            property var process: Process {
                command: ["bash", "-c", "niri msg -j workspaces 2>/dev/null || echo '[]'"]
                running: false
                
                stdout: SplitParser {
                    onRead: data => {
                        try {
                            var workspaces = JSON.parse(data.trim())
                            topbar.workspaceModel.clear()
                            
                            if (Array.isArray(workspaces) && workspaces.length > 0) {
                                // Filter to only this screen's workspaces
                                var filtered = []
                                for (var i = 0; i < workspaces.length; i++) {
                                    if (workspaces[i].output === topbar.screenName) {
                                        filtered.push(workspaces[i])
                                    }
                                }
                                
                                // Sort by idx
                                filtered.sort((a, b) => (a.idx || 0) - (b.idx || 0))
                                
                                // Add to model
                                for (var j = 0; j < filtered.length; j++) {
                                    var ws = filtered[j]
                                    topbar.workspaceModel.append({
                                        id: ws.idx,
                                        active: ws.is_focused || ws.is_active
                                    })
                                }
                            }
                            
                            if (topbar.workspaceModel.count === 0) {
                                topbar.workspaceModel.append({id: 1, active: true})
                            }
                        } catch (e) {
                            console.log("Workspace parse error:", e)
                        }
                    }
                }
            }
            
            property var timer: Timer {
                interval: 500
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: screenWorkspaceMonitor.process.running = true
            }
        }
        
        // Per-screen window title monitor
        QtObject {
            id: screenWindowMonitor
            
            property var process: Process {
                command: ["bash", "-c", "niri msg -j workspaces 2>/dev/null; echo '---SEPARATOR---'; niri msg -j focused-window 2>/dev/null || echo '{}'"]
                running: false
                
                property var workspaceData: []
                property var windowData: null
                property bool parsingWorkspaces: true
                
                stdout: SplitParser {
                    onRead: data => {
                        var line = data.trim()
                        
                        if (line === "---SEPARATOR---") {
                            screenWindowMonitor.process.parsingWorkspaces = false
                            return
                        }
                        
                        if (screenWindowMonitor.process.parsingWorkspaces) {
                            try {
                                screenWindowMonitor.process.workspaceData = JSON.parse(line)
                            } catch (e) {}
                        } else {
                            try {
                                screenWindowMonitor.process.windowData = JSON.parse(line)
                            } catch (e) {}
                        }
                    }
                }
                
                onExited: (exitCode, exitStatus) => {
                    try {
                        var window = screenWindowMonitor.process.windowData
                        var workspaces = screenWindowMonitor.process.workspaceData
                        
                        if (window && window.is_focused && window.title && window.workspace_id) {
                            // Find which output this workspace_id is on
                            var windowOutput = null
                            for (var i = 0; i < workspaces.length; i++) {
                                if (workspaces[i].id === window.workspace_id) {
                                    windowOutput = workspaces[i].output
                                    break
                                }
                            }
                            
                            // Show title only if window is on this screen
                            if (windowOutput === topbar.screenName) {
                                topbar.windowTitle = window.title
                            } else {
                                topbar.windowTitle = "Desktop"
                            }
                        } else {
                            topbar.windowTitle = "Desktop"
                        }
                        
                        // Reset for next run
                        screenWindowMonitor.process.workspaceData = []
                        screenWindowMonitor.process.windowData = null
                        screenWindowMonitor.process.parsingWorkspaces = true
                    } catch (e) {
                        topbar.windowTitle = "Desktop"
                    }
                }
            }
            
            property var timer: Timer {
                interval: 500
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: screenWindowMonitor.process.running = true
            }
        }
    }
    
    } // End Variants
    
    // Clock timer
    QtObject {
        id: clockTimer
        property var currentTime: new Date()
        property bool showDate: false
        
        property var timer: Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockTimer.currentTime = new Date()
        }
    }
    
    // CPU Monitor
    QtObject {
        id: cpuMonitor
        property string usage: "0"
        
        property var process: Process {
            command: ["bash", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1"]
            running: false
            
            stdout: SplitParser {
                onRead: data => {
                    var val = data.trim()
                    if (val.length > 0) {
                        cpuMonitor.usage = Math.round(parseFloat(val))
                    }
                }
            }
        }
        
        property var timer: Timer {
            interval: 2000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: cpuMonitor.process.running = true
        }
    }
    
    // Memory Monitor
    QtObject {
        id: memMonitor
        property string usage: "0"
        
        property var process: Process {
            command: ["bash", "-c", "free | awk '/^Mem:/ {printf \"%.0f\", $3/$2 * 100}'"]
            running: false
            
            stdout: SplitParser {
                onRead: data => {
                    var val = data.trim()
                    if (val.length > 0) {
                        memMonitor.usage = val
                    }
                }
            }
        }
        
        property var timer: Timer {
            interval: 2000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: memMonitor.process.running = true
        }
    }
    
    // Temperature Monitor
    QtObject {
        id: tempMonitor
        property string temp: "0"
        property bool critical: false
        
        property var process: Process {
            command: ["bash", "-c", "sensors 2>/dev/null | grep -E 'Tctl|Tdie|edge' | head -1 | grep -oP '\\+\\K[0-9]+' || cat /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -1 | awk '{print int($1/1000)}' || echo '0'"]
            running: false
            
            stdout: SplitParser {
                onRead: data => {
                    var val = data.trim()
                    if (val.length > 0 && val !== "0") {
                        tempMonitor.temp = val
                        tempMonitor.critical = parseInt(val) > 80
                    }
                }
            }
        }
        
        property var timer: Timer {
            interval: 2000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: tempMonitor.process.running = true
        }
    }
    
    // Battery Monitor
    QtObject {
        id: batteryMonitor
        property string capacity: "100"
        property bool charging: false
        property bool warning: false
        property bool critical: false
        property bool hasBattery: false
        
        property var process: Process {
            command: ["bash", "-c", "if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then cat /sys/class/power_supply/BAT*/capacity; echo 'HAS_BATTERY'; else echo '100'; fi"]
            running: false
            
            stdout: SplitParser {
                onRead: data => {
                    var val = data.trim()
                    if (val === "HAS_BATTERY") {
                        batteryMonitor.hasBattery = true
                    } else if (val.length > 0 && val !== "HAS_BATTERY") {
                        batteryMonitor.capacity = val
                        var cap = parseInt(val)
                        batteryMonitor.warning = cap <= 30
                        batteryMonitor.critical = cap <= 15
                    }
                }
            }
        }
        
        property var statusProcess: Process {
            command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/status 2>/dev/null || echo 'Unknown'"]
            running: false
            
            stdout: SplitParser {
                onRead: data => {
                    var val = data.trim()
                    batteryMonitor.charging = (val === "Charging" || val === "Full")
                }
            }
        }
        
        property var timer: Timer {
            interval: 5000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                batteryMonitor.process.running = true
                batteryMonitor.statusProcess.running = true
            }
        }
    }
    
    // Network Monitor
    QtObject {
        id: networkMonitor
        property string status: "NET:..."
        
        property var process: Process {
            command: ["bash", "-c", "if ip link show | grep -q 'state UP'; then echo 'ETH:ON'; else echo 'NET:OFF'; fi"]
            running: false
            
            stdout: SplitParser {
                onRead: data => {
                    var val = data.trim()
                    if (val.length > 0) {
                        networkMonitor.status = val
                    }
                }
            }
        }
        
        property var timer: Timer {
            interval: 5000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: networkMonitor.process.running = true
        }
    }
    
    // Audio Monitor
    QtObject {
        id: audioMonitor
        property string volume: "50"
        property bool muted: false
        property string lastVolume: "50"
        property bool lastMuted: false

        property var volProcess: Process {
            command: ["pamixer", "--get-volume"]
            running: false

            stdout: SplitParser {
                onRead: data => {
                    var val = data.trim()
                    if (val.length > 0) {
                        var newVolume = val

                        // Check if volume changed from hardware/external control
                        if (audioMonitor.lastVolume !== "" &&
                            audioMonitor.lastVolume !== newVolume &&
                            audioMonitor.lastVolume !== "50") {
                            // Volume changed externally, show OSD
                            volumeOSD.show()
                            }

                            audioMonitor.lastVolume = audioMonitor.volume
                            audioMonitor.volume = newVolume
                    }
                }
            }
        }

        property var muteProcess: Process {
            command: ["pamixer", "--get-mute"]
            running: false

            stdout: SplitParser {
                onRead: data => {
                    var newMuted = data.trim() === "true"

                    // Check if mute state changed externally
                    if (audioMonitor.lastMuted !== newMuted && audioMonitor.lastVolume !== "50") {
                        volumeOSD.show()
                    }

                    audioMonitor.lastMuted = audioMonitor.muted
                    audioMonitor.muted = newMuted
                }
            }
        }

        property var timer: Timer {
            interval: 500
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                audioMonitor.volProcess.running = true
                audioMonitor.muteProcess.running = true
            }
        }
    }
    
    // Caffeine Monitor
    QtObject {
        id: caffeineMonitor
        property string text: "[SLP]"
        property bool active: false
        
        property var process: Process {
            command: ["bash", Quickshell.env("HOME") + "/.local/bin/caffeine-status-retro.sh"]
            running: false
            
            stdout: SplitParser {
                onRead: data => {
                    try {
                        var json = JSON.parse(data.trim())
                        caffeineMonitor.text = json.text
                        caffeineMonitor.active = json.class === "active"
                    } catch (e) {
                        // Parsing failed
                    }
                }
            }
        }
        
        property var timer: Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: caffeineMonitor.process.running = true
        }
    }
    
    
    // Workspace switcher
    Process {
        id: workspaceSwitcher
        running: false
    }
    
    // Launchers and controls
    Process {
        id: btopLauncher
        command: ["kitty", "-e", "btop"]
        running: false
    }
    
    Process {
        id: volumeToggle
        command: ["pamixer", "-t"]
        running: false
        onExited: (exitCode, exitStatus) => {
            audioMonitor.volProcess.running = true
            audioMonitor.muteProcess.running = true
        }
    }
    
    Process {
        id: volumeUp
        command: ["pamixer", "-i", "5"]
        running: false
        onExited: (exitCode, exitStatus) => {
            audioMonitor.volProcess.running = true
        }
    }
    
    Process {
        id: volumeDown
        command: ["pamixer", "-d", "5"]
        running: false
        onExited: (exitCode, exitStatus) => {
            audioMonitor.volProcess.running = true
        }
    }
    
    Process {
        id: caffeineToggle
        command: ["bash", Quickshell.env("HOME") + "/.local/bin/caffeine-toggle.sh"]
        running: false
        onExited: (exitCode, exitStatus) => {
            caffeineMonitor.process.running = true
        }
    }
}
