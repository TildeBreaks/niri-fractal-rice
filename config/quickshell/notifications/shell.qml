// [NIRI-FRACTAL-RICE]
// Quickshell Notification Center - Retro Gaming Theme
// Handles notification display and history with settings panel

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

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
    property string colorUrgent: "#ff4444"

    // Notification history
    property var notificationHistory: []
    property int maxHistory: 50

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

    // Notification Server
    NotificationServer {
        id: notificationServer
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => {
            console.log("Notification received:", notification.summary)

            // Add to history
            var historyItem = {
                id: notification.id,
                appName: notification.appName,
                appIcon: notification.appIcon,
                summary: notification.summary,
                body: notification.body,
                urgency: notification.urgency,
                image: notification.image,
                time: new Date().toLocaleTimeString(Qt.locale(), "hh:mm"),
                actions: []
            }

            // Copy actions
            for (var i = 0; i < notification.actions.length; i++) {
                historyItem.actions.push({
                    identifier: notification.actions[i].identifier,
                    text: notification.actions[i].text
                })
            }

            notificationHistory.unshift(historyItem)
            if (notificationHistory.length > maxHistory) {
                notificationHistory.pop()
            }
            notificationHistoryChanged()

            // Track the notification
            notification.tracked = true

            // Show popup
            popupModel.append({ notification: notification })

            // Auto-dismiss after timeout (unless critical)
            if (notification.urgency !== NotificationUrgency.Critical) {
                var timeout = notification.expireTimeout > 0 ? notification.expireTimeout : 5000
                dismissTimer.createTimer(notification, timeout)
            }
        }
    }

    // Timer manager for auto-dismiss
    QtObject {
        id: dismissTimer

        function createTimer(notification, timeout) {
            var timer = Qt.createQmlObject(
                'import QtQuick; Timer { interval: ' + timeout + '; running: true; repeat: false }',
                root
            )
            timer.triggered.connect(function() {
                notification.expire()
                timer.destroy()
            })
        }
    }

    // Model for active popup notifications
    ListModel {
        id: popupModel
    }

    // Notification popups - top center
    PanelWindow {
        id: popupWindow
        visible: popupModel.count > 0

        anchors {
            top: true
        }

        margins {
            top: 95
        }

        // Center horizontally
        anchors.horizontalCenter: true

        implicitWidth: 400
        implicitHeight: Math.min(popupColumn.implicitHeight + 20, 600)

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        ColumnLayout {
            id: popupColumn
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Repeater {
                model: popupModel

                delegate: Rectangle {
                    id: popupDelegate
                    Layout.fillWidth: true
                    Layout.preferredHeight: popupContent.implicitHeight + 20

                    property var notif: model.notification

                    color: colorBg
                    opacity: 0.95
                    border.width: notif && notif.urgency === NotificationUrgency.Critical ? 3 : 2
                    border.color: notif && notif.urgency === NotificationUrgency.Critical ? colorUrgent : color2

                    // Slide in animation
                    x: 0
                    Component.onCompleted: {
                        slideIn.start()
                    }

                    NumberAnimation {
                        id: slideIn
                        target: popupDelegate
                        property: "x"
                        from: 400
                        to: 0
                        duration: 200
                        easing.type: Easing.OutCubic
                    }

                    ColumnLayout {
                        id: popupContent
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        // Header row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            // App icon
                            Image {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                source: notif && notif.image ? notif.image : (notif && notif.appIcon ? "image://icon/" + notif.appIcon : "")
                                visible: source !== ""
                                fillMode: Image.PreserveAspectFit
                            }

                            // App name
                            Text {
                                text: notif ? notif.appName : ""
                                color: color2
                                font.family: "Monospace"
                                font.pixelSize: 11
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            // Close button
                            Rectangle {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                color: closeArea.containsMouse ? color2 : "transparent"
                                border.width: 1
                                border.color: color2

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: colorFg
                                    font.pixelSize: 12
                                }

                                MouseArea {
                                    id: closeArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (notif) notif.dismiss()
                                        popupModel.remove(index)
                                    }
                                }
                            }
                        }

                        // Summary
                        Text {
                            text: notif ? notif.summary : ""
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 13
                            font.bold: true
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }

                        // Body
                        Text {
                            text: notif ? notif.body.replace(/<[^>]*>/g, '') : ""
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 11
                            opacity: 0.8
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                            visible: text.length > 0
                        }

                        // Actions
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            visible: notif && notif.actions.length > 0

                            Repeater {
                                model: notif ? notif.actions : []

                                Rectangle {
                                    Layout.preferredHeight: 28
                                    Layout.preferredWidth: actionText.implicitWidth + 16
                                    color: actionArea.containsMouse ? color2 : color1
                                    border.width: 1
                                    border.color: color2

                                    Text {
                                        id: actionText
                                        anchors.centerIn: parent
                                        text: modelData.text
                                        color: colorFg
                                        font.family: "Monospace"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: actionArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            modelData.invoke()
                                            popupModel.remove(index)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Remove from popup when notification is closed
                    Connections {
                        target: notif
                        function onClosed(reason) {
                            popupModel.remove(index)
                        }
                    }
                }
            }
        }
    }

    // Notification Center Panel - toggled visibility
    property bool centerVisible: false

    // Watch for toggle signal
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: notifToggleChecker.running = true
    }

    Process {
        id: notifToggleChecker
        command: ["bash", "-c", "if [ -f ~/.cache/notif-center-toggle ]; then rm -f ~/.cache/notif-center-toggle; echo 'toggle'; fi"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                if (data.trim() === "toggle") {
                    root.centerVisible = !root.centerVisible
                }
            }
        }
    }

    PanelWindow {
        id: centerPanel
        visible: root.centerVisible

        anchors {
            top: true
            bottom: true
        }

        margins {
            top: 95
            bottom: 10
        }

        // Center horizontally
        anchors.horizontalCenter: true

        implicitWidth: 420
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.fill: parent
            color: colorBg
            opacity: 0.95
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
                        text: "📬 NOTIFICATIONS"
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                        style: Text.Outline
                        styleColor: color2
                    }

                    // Clear all button
                    Rectangle {
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 35
                        color: clearArea.containsMouse ? color2 : color1
                        border.width: 2
                        border.color: colorFg
                        visible: notificationHistory.length > 0

                        Text {
                            anchors.centerIn: parent
                            text: "CLEAR"
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            id: clearArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                notificationHistory = []
                                notificationHistoryChanged()
                            }
                        }
                    }

                    // Close button
                    Rectangle {
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 35
                        color: centerCloseArea.containsMouse ? color2 : color1
                        border.width: 2
                        border.color: colorFg

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: colorFg
                            font.pixelSize: 16
                        }

                        MouseArea {
                            id: centerCloseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.centerVisible = false
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    color: colorFg
                }

                // Quick Settings
                Text {
                    text: ">> QUICK SETTINGS <<"
                    color: color2
                    font.family: "Monospace"
                    font.pixelSize: 12
                    font.bold: true
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    rowSpacing: 8
                    columnSpacing: 8

                    Repeater {
                        model: [
                            { name: "WiFi", icon: "📶", cmd: "kitty -e nmtui" },
                            { name: "Sound", icon: "🔊", cmd: "pavucontrol" },
                            { name: "Display", icon: "🖥", cmd: "niri msg action do-screen-transition" },
                            { name: "Power", icon: "⚡", cmd: "kitty -e btop" },
                            { name: "Theme", icon: "🎨", cmd: "quickshell -c ~/.config/quickshell/wallpaper-picker.qml" },
                            { name: "Settings", icon: "⚙", cmd: "gnome-control-center 2>/dev/null || systemsettings5 2>/dev/null || xfce4-settings-manager" }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            color: settingArea.containsMouse ? color2 : color1
                            border.width: 2
                            border.color: color2

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 20
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: modelData.name
                                    color: settingArea.containsMouse ? colorBg : colorFg
                                    font.family: "Monospace"
                                    font.pixelSize: 10
                                    font.bold: true
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }

                            MouseArea {
                                id: settingArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    settingsLauncher.command = ["bash", "-c", modelData.cmd + " &"]
                                    settingsLauncher.running = true
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    color: colorFg
                    opacity: 0.5
                }

                // Notification history header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: ">> HISTORY <<"
                        color: color2
                        font.family: "Monospace"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Text {
                        text: notificationHistory.length + " notifications"
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 10
                        opacity: 0.7
                    }
                }

                // Notification history list
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: color0
                    border.width: 2
                    border.color: color2

                    ListView {
                        id: historyList
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        clip: true

                        model: notificationHistory

                        delegate: Rectangle {
                            width: historyList.width
                            height: historyContent.implicitHeight + 16
                            color: historyItemArea.containsMouse ? color1 : color0
                            border.width: 1
                            border.color: color2

                            ColumnLayout {
                                id: historyContent
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: modelData.appName
                                        color: color2
                                        font.family: "Monospace"
                                        font.pixelSize: 10
                                        font.bold: true
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.time
                                        color: colorFg
                                        font.family: "Monospace"
                                        font.pixelSize: 9
                                        opacity: 0.6
                                    }
                                }

                                Text {
                                    text: modelData.summary
                                    color: colorFg
                                    font.family: "Monospace"
                                    font.pixelSize: 11
                                    font.bold: true
                                    Layout.fillWidth: true
                                    wrapMode: Text.WordWrap
                                }

                                Text {
                                    text: modelData.body ? modelData.body.replace(/<[^>]*>/g, '') : ""
                                    color: colorFg
                                    font.family: "Monospace"
                                    font.pixelSize: 10
                                    opacity: 0.7
                                    Layout.fillWidth: true
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                    visible: text.length > 0
                                }
                            }

                            MouseArea {
                                id: historyItemArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }
                    }

                    // Empty state
                    Text {
                        anchors.centerIn: parent
                        text: "NO NOTIFICATIONS\n\n>> ALL CLEAR <<"
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        opacity: 0.5
                        visible: notificationHistory.length === 0
                    }
                }
            }
        }
    }

    // Settings launcher process
    Process {
        id: settingsLauncher
        running: false
    }
}
