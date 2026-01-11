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

    // Recent apps tracking (stores desktop entry IDs)
    property var recentAppIds: []
    property int maxRecentApps: 5
    property int recentUpdateCounter: 0  // Force reactivity
    property string recentAppsFile: "/home/breaks/.config/quickshell/app-launcher/recent-apps.json"

    // Load recent apps on startup
    Process {
        id: loadRecentApps
        command: ["cat", recentAppsFile]
        running: true

        property string output: ""

        stdout: SplitParser {
            onRead: data => {
                loadRecentApps.output += data
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && loadRecentApps.output.trim().length > 0) {
                try {
                    var parsed = JSON.parse(loadRecentApps.output.trim())
                    if (Array.isArray(parsed)) {
                        recentAppIds = parsed
                        recentUpdateCounter++
                    }
                } catch (e) {
                    recentAppIds = []
                }
            }
        }
    }

    // Save recent apps helper
    function saveRecentApps() {
        var jsonData = JSON.stringify(recentAppIds)
        saveRecentProcess.command = ["bash", "-c", "printf '%s' '" + jsonData + "' > " + recentAppsFile]
        saveRecentProcess.running = true
    }

    Process {
        id: saveRecentProcess
        running: false
    }

    // Add app to recent list
    function addToRecent(appId) {
        if (!appId) return

        // Remove if already exists
        var newRecent = recentAppIds.filter(id => id !== appId)
        // Add to front
        newRecent.unshift(appId)
        // Keep only max items
        if (newRecent.length > maxRecentApps) {
            newRecent = newRecent.slice(0, maxRecentApps)
        }
        recentAppIds = newRecent
        recentUpdateCounter++
        saveRecentApps()
    }

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
            if (list.currentIndex >= 0 && list.currentIndex < filtered.values.length) {
                var item = filtered.values[list.currentIndex]
                if (!item.isSection && item.app) {
                    addToRecent(item.app.id)
                    item.app.execute()
                    Qt.quit()
                }
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
                            list.moveToNextApp(0)
                        }

                        Keys.onEscapePressed: Qt.quit()
                        Keys.onPressed: event => {
                            if (event.key == Qt.Key_Up) {
                                event.accepted = true
                                if (list.currentIndex > 0) list.moveToPrevApp(list.currentIndex - 1)
                            } else if (event.key == Qt.Key_Down) {
                                event.accepted = true
                                if (list.currentIndex < list.count - 1) list.moveToNextApp(list.currentIndex + 1)
                            } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
                                event.accepted = true
                                launcher.launchSelected()
                            }
                        }
                    }
                }

                // Count
                Text {
                    text: {
                        if (launcher.query.length > 0) {
                            return "RESULTS (" + filtered.values.length + ")"
                        } else {
                            var recentCount = recentApps.values.length
                            var allCount = allAppsFiltered.values.length
                            if (recentCount > 0) {
                                return "RECENT (" + recentCount + ") / ALL APPS (" + allCount + ")"
                            }
                            return "ALL APPS (" + allCount + ")"
                        }
                    }
                    color: color8
                    font.family: "Monospace"
                    font.pixelSize: 12
                    font.bold: true
                }

                // Recent apps model
                ScriptModel {
                    id: recentApps
                    values: {
                        // Depend on counter to force reactivity
                        var _ = recentUpdateCounter
                        if (launcher.query.length > 0) return []
                        const allEntries = [...DesktopEntries.applications.values]
                        var recent = []
                        for (var i = 0; i < recentAppIds.length; i++) {
                            var app = allEntries.find(e => e.id === recentAppIds[i])
                            if (app) recent.push(app)
                        }
                        return recent
                    }
                }

                // All apps (excluding recent when no query)
                ScriptModel {
                    id: allAppsFiltered
                    values: {
                        // Depend on counter to force reactivity
                        var _ = recentUpdateCounter
                        const allEntries = [...DesktopEntries.applications.values]
                        const q = launcher.query.trim().toLowerCase()

                        let results
                        if (q === "") {
                            // Exclude recent apps from main list
                            results = allEntries.filter(d => !recentAppIds.includes(d.id))
                        } else {
                            results = allEntries.filter(d => d.name && d.name.toLowerCase().includes(q))
                        }

                        return results.sort((a, b) => a.name.localeCompare(b.name))
                    }
                }

                // Combined filter with section markers
                ScriptModel {
                    id: filtered
                    values: {
                        var combined = []

                        // Add recent section if not searching and have recent apps
                        if (launcher.query.length === 0 && recentApps.values.length > 0) {
                            combined.push({ isSection: true, sectionName: "RECENT" })
                            for (var i = 0; i < recentApps.values.length; i++) {
                                combined.push({ isSection: false, app: recentApps.values[i] })
                            }
                            combined.push({ isSection: true, sectionName: "ALL APPS" })
                        }

                        // Add all apps
                        for (var j = 0; j < allAppsFiltered.values.length; j++) {
                            combined.push({ isSection: false, app: allAppsFiltered.values[j] })
                        }

                        return combined
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
                    highlightMoveDuration: 100

                    // Find first non-section item for initial selection
                    Component.onCompleted: moveToNextApp(0)

                    function moveToNextApp(startIdx) {
                        for (var i = startIdx; i < filtered.values.length; i++) {
                            if (!filtered.values[i].isSection) {
                                currentIndex = i
                                return
                            }
                        }
                        currentIndex = -1
                    }

                    function moveToPrevApp(startIdx) {
                        for (var i = startIdx; i >= 0; i--) {
                            if (!filtered.values[i].isSection) {
                                currentIndex = i
                                return
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: list.width - 20
                        height: modelData.isSection ? 30 : 45

                        // Section header
                        Loader {
                            active: modelData.isSection
                            anchors.fill: parent
                            sourceComponent: Rectangle {
                                color: "transparent"

                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "── " + modelData.sectionName + " ──"
                                    color: color2
                                    font.family: "Monospace"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }
                        }

                        // App item
                        Loader {
                            active: !modelData.isSection
                            anchors.fill: parent
                            sourceComponent: Rectangle {
                                property var app: modelData.app
                                property bool isCurrent: index === list.currentIndex

                                color: isCurrent ? colorFg : (appMa.containsMouse ? color2 : color0)
                                border.width: isCurrent ? 3 : 2
                                border.color: isCurrent ? colorFg : color2

                                MouseArea {
                                    id: appMa
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
                                        color: parent.parent.isCurrent ? color0 : colorFg
                                        font.family: "Monospace"
                                        font.pixelSize: 16
                                        font.bold: true
                                    }

                                    Text {
                                        text: app ? app.name : ""
                                        color: parent.parent.isCurrent ? color0 : colorFg
                                        font.family: "Monospace"
                                        font.pixelSize: 14
                                        font.bold: true
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }

                    Keys.onReturnPressed: launcher.launchSelected()
                }
            }
        }
    }
}
