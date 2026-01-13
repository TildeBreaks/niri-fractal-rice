// Palette Creator - Create and manage custom color palettes
// Saves to ~/.config/quickshell/custom-palettes.txt

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

    // Load pywal colors
    Process {
        id: colorLoader
        command: ["bash", "-c", "jq -r '.special.background, .special.foreground, .colors.color0, .colors.color1, .colors.color2, .colors.color3, .colors.color4' ~/.cache/wal/colors.json 2>/dev/null"]
        running: true

        property var colorLines: []

        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length > 0) colorLoader.colorLines.push(line)
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

    // Custom palettes model
    ListModel {
        id: customPalettesModel
    }

    // Load custom palettes on startup
    Component.onCompleted: {
        loadCustomPalettes()
    }

    function loadCustomPalettes() {
        customPalettesModel.clear()
        paletteLoadProcess.running = true
    }

    Process {
        id: paletteLoadProcess
        command: ["bash", "-c", "[ -f ~/.config/quickshell/custom-palettes.txt ] && cat ~/.config/quickshell/custom-palettes.txt || echo ''"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length > 0 && line.indexOf("|") > 0) {
                    var parts = line.split("|")
                    if (parts.length === 2) {
                        customPalettesModel.append({
                            name: parts[0],
                            colors: parts[1]
                        })
                    }
                }
            }
        }
    }

    FloatingWindow {
        id: mainWindow

        implicitWidth: 900
        implicitHeight: 700
        visible: true
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: colorBg
            border.width: 3
            border.color: color2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "transparent"
                    border.width: 2
                    border.color: color2

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15

                        Text {
                            text: "🎨 PALETTE CREATOR"
                            color: colorFg
                            font.family: "Monospace"
                            font.pixelSize: 20
                            font.bold: true
                            Layout.fillWidth: true
                            style: Text.Outline
                            styleColor: color2
                        }

                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            color: closeArea.containsMouse ? "#ff0000" : color1
                            border.width: 2
                            border.color: closeArea.containsMouse ? "#ff0000" : color2

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: colorFg
                                font.pixelSize: 20
                                font.bold: true
                            }

                            MouseArea {
                                id: closeArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Qt.quit()
                            }
                        }
                    }
                }

                // Two column layout
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 20

                    // Left side: Color picker
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 500
                        color: color0
                        border.width: 2
                        border.color: color2

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15

                            Text {
                                text: ">> CREATE NEW PALETTE <<"
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
                                color: color2
                            }

                            // Palette name input
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: "NAME:"
                                    color: colorFg
                                    font.family: "Monospace"
                                    font.pixelSize: 14
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 35
                                    color: colorBg
                                    border.width: nameInput.activeFocus ? 3 : 2
                                    border.color: nameInput.activeFocus ? colorFg : color2

                                    TextInput {
                                        id: nameInput
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        color: colorFg
                                        font.family: "Monospace"
                                        font.pixelSize: 14
                                        clip: true
                                        selectByMouse: true
                                        text: ""
                                    }
                                }
                            }

                            // Color grid (8 colors, 2x4)
                            Text {
                                text: "COLORS: (click to edit)"
                                color: colorFg
                                font.family: "Monospace"
                                font.pixelSize: 12
                                opacity: 0.8
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 4
                                rowSpacing: 10
                                columnSpacing: 10

                                Repeater {
                                    id: colorRepeater
                                    model: 8

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 80
                                        color: getColorValue(index)
                                        border.width: 3
                                        border.color: colorFg

                                        property int colorIndex: index

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 5

                                            Text {
                                                text: getColorValue(colorIndex)
                                                color: getLuminance(getColorValue(colorIndex)) > 0.5 ? "#000000" : "#FFFFFF"
                                                font.family: "Monospace"
                                                font.pixelSize: 11
                                                font.bold: true
                                                Layout.alignment: Qt.AlignHCenter
                                            }

                                            Text {
                                                text: "CLK"
                                                color: getLuminance(getColorValue(colorIndex)) > 0.5 ? "#000000" : "#FFFFFF"
                                                font.family: "Monospace"
                                                font.pixelSize: 9
                                                opacity: colorMouseArea.containsMouse ? 1.0 : 0.5
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                        }

                                        MouseArea {
                                            id: colorMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                colorPickerPopup.currentIndex = colorIndex
                                                colorPickerPopup.visible = true
                                            }
                                        }
                                    }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            // Palette preview
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                color: colorBg
                                border.width: 2
                                border.color: color2

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    spacing: 2

                                    Repeater {
                                        model: 8
                                        Rectangle {
                                            width: (parent.width - 14) / 8
                                            height: parent.height
                                            color: getColorValue(index)
                                            border.width: 1
                                            border.color: "#00000040"
                                        }
                                    }
                                }
                            }

                            // Save button
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                color: saveArea.containsMouse ? color3 : color2
                                border.width: 3
                                border.color: colorFg

                                Text {
                                    anchors.centerIn: parent
                                    text: ">> SAVE PALETTE <<"
                                    color: colorBg
                                    font.family: "Monospace"
                                    font.pixelSize: 16
                                    font.bold: true
                                }

                                MouseArea {
                                    id: saveArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: savePalette()
                                }
                            }
                        }
                    }

                    // Right side: Saved palettes
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: color0
                        border.width: 2
                        border.color: color2

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: ">> SAVED PALETTES <<"
                                    color: colorFg
                                    font.family: "Monospace"
                                    font.pixelSize: 16
                                    font.bold: true
                                    Layout.fillWidth: true
                                    style: Text.Outline
                                    styleColor: color2
                                }

                                Rectangle {
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 35
                                    color: refreshArea.containsMouse ? color2 : color1
                                    border.width: 2
                                    border.color: color2

                                    Text {
                                        anchors.centerIn: parent
                                        text: "⟳"
                                        color: colorFg
                                        font.pixelSize: 20
                                    }

                                    MouseArea {
                                        id: refreshArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: loadCustomPalettes()
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 2
                                color: color2
                            }

                            ListView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 8
                                clip: true
                                model: customPalettesModel

                                delegate: Rectangle {
                                    width: ListView.view.width
                                    height: 80
                                    color: paletteItemArea.containsMouse ? color1 : colorBg
                                    border.width: 2
                                    border.color: color2

                                    property string paletteColors: model.colors || ""

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 6

                                        RowLayout {
                                            Layout.fillWidth: true

                                            Text {
                                                text: model.name
                                                color: colorFg
                                                font.family: "Monospace"
                                                font.pixelSize: 14
                                                font.bold: true
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }

                                            Rectangle {
                                                Layout.preferredWidth: 60
                                                Layout.preferredHeight: 28
                                                color: loadPalArea.containsMouse ? color3 : color2
                                                border.width: 2
                                                border.color: colorFg

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "LOAD"
                                                    color: colorBg
                                                    font.family: "Monospace"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }

                                                MouseArea {
                                                    id: loadPalArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: loadPaletteToEditor(model.name, model.colors)
                                                }
                                            }

                                            Rectangle {
                                                Layout.preferredWidth: 60
                                                Layout.preferredHeight: 28
                                                color: delPalArea.containsMouse ? "#ff0000" : color1
                                                border.width: 2
                                                border.color: delPalArea.containsMouse ? "#ff0000" : color2

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "DEL"
                                                    color: colorFg
                                                    font.family: "Monospace"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }

                                                MouseArea {
                                                    id: delPalArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: deletePalette(model.name)
                                                }
                                            }
                                        }

                                        // Color preview
                                        Row {
                                            Layout.fillWidth: true
                                            spacing: 2

                                            Repeater {
                                                model: parent.parent.parent.paletteColors.length > 0 ? parent.parent.parent.paletteColors.split(",") : []
                                                Rectangle {
                                                    width: 40
                                                    height: 28
                                                    color: modelData
                                                    border.width: 1
                                                    border.color: "#00000040"
                                                }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: paletteItemArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        propagateComposedEvents: true
                                        z: -1
                                    }
                                }

                                ScrollBar.vertical: ScrollBar {
                                    policy: ScrollBar.AsNeeded
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                visible: customPalettesModel.count === 0

                                Text {
                                    anchors.centerIn: parent
                                    text: "NO CUSTOM PALETTES\n\n>> CREATE ONE <<"
                                    color: colorFg
                                    font.family: "Monospace"
                                    font.pixelSize: 14
                                    opacity: 0.5
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }

            // Color picker popup (overlay)
            Rectangle {
                id: colorPickerPopup
                visible: false
                anchors.centerIn: parent
                width: 400
                height: 500
        color: colorBg
        border.width: 3
        border.color: colorFg
        z: 100

        property int currentIndex: 0

        onVisibleChanged: {
            if (visible) {
                hexInput.text = getColorValue(currentIndex)
            }
        }

        onCurrentIndexChanged: {
            if (visible) {
                hexInput.text = getColorValue(currentIndex)
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: ">> SELECT COLOR <<"
                color: colorFg
                font.family: "Monospace"
                font.pixelSize: 16
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                style: Text.Outline
                styleColor: color2
            }

            // Hex input
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "HEX:"
                    color: colorFg
                    font.family: "Monospace"
                    font.pixelSize: 14
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    color: colorBg
                    border.width: hexInput.activeFocus ? 3 : 2
                    border.color: hexInput.activeFocus ? colorFg : color2

                    TextInput {
                        id: hexInput
                        anchors.fill: parent
                        anchors.margins: 8
                        color: colorFg
                        font.family: "Monospace"
                        font.pixelSize: 14
                        text: ""
                        selectByMouse: true
                        maximumLength: 7

                        onTextEdited: {
                            if (text.match(/^#[0-9A-Fa-f]{6}$/)) {
                                setColorValue(colorPickerPopup.currentIndex, text)
                            }
                        }
                    }
                }
            }

            // Preview
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: getColorValue(colorPickerPopup.currentIndex)
                border.width: 3
                border.color: colorFg
            }

            // Preset colors grid
            Text {
                text: "PRESETS:"
                color: colorFg
                font.family: "Monospace"
                font.pixelSize: 12
                opacity: 0.8
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 6
                rowSpacing: 5
                columnSpacing: 5

                Repeater {
                    model: [
                        "#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF",
                        "#FF8800", "#88FF00", "#0088FF", "#8800FF", "#FF0088", "#00FF88",
                        "#FFFFFF", "#CCCCCC", "#888888", "#444444", "#222222", "#000000",
                        "#FFB6C1", "#FFE4E1", "#F0E68C", "#E0FFFF", "#E6E6FA", "#FFF0F5"
                    ]

                    Rectangle {
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 40
                        color: modelData
                        border.width: 2
                        border.color: colorFg

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                setColorValue(colorPickerPopup.currentIndex, modelData)
                                hexInput.text = modelData
                            }
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Done button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                color: doneArea.containsMouse ? color3 : color2
                border.width: 3
                border.color: colorFg

                Text {
                    anchors.centerIn: parent
                    text: "DONE"
                    color: colorBg
                    font.family: "Monospace"
                    font.pixelSize: 16
                    font.bold: true
                }

                MouseArea {
                    id: doneArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: colorPickerPopup.visible = false
                }
            }
        }  // Close ColumnLayout in colorPickerPopup
    }  // Close colorPickerPopup Rectangle
        }  // Close main background Rectangle
    }  // Close FloatingWindow

    // Color storage
    property var paletteColors: ["#FF0000", "#FF8800", "#FFFF00", "#00FF00", "#00FFFF", "#0000FF", "#8800FF", "#FF00FF"]
    property int colorUpdateTrigger: 0  // Used to force UI updates

    function getColorValue(index) {
        colorUpdateTrigger  // Access to create binding dependency
        return paletteColors[index] || "#FFFFFF"
    }

    function setColorValue(index, color) {
        var newColors = paletteColors.slice()
        newColors[index] = color
        paletteColors = newColors
        colorUpdateTrigger++  // Trigger UI update
    }

    function getLuminance(hexColor) {
        var c = hexColor.substring(1)
        var rgb = parseInt(c, 16)
        var r = (rgb >> 16) & 0xff
        var g = (rgb >> 8) & 0xff
        var b = (rgb >> 0) & 0xff
        return (0.299 * r + 0.587 * g + 0.114 * b) / 255
    }

    function savePalette() {
        var name = nameInput.text.trim()
        if (name.length === 0) {
            console.log("Error: Palette name is required")
            return
        }

        // Replace spaces with underscores
        name = name.replace(/\s+/g, "_")

        var colorsStr = paletteColors.join(",")
        var line = name + "|" + colorsStr

        savePaletteProcess.command = ["bash", "-c", "echo '" + line + "' >> ~/.config/quickshell/custom-palettes.txt"]
        savePaletteProcess.running = true
    }

    Process {
        id: savePaletteProcess
        running: false

        onExited: (exitCode, exitStatus) => {
            console.log("Palette saved!")
            nameInput.text = ""
            loadCustomPalettes()
        }
    }

    function loadPaletteToEditor(name, colorsStr) {
        nameInput.text = name
        var colors = colorsStr.split(",")
        for (var i = 0; i < Math.min(colors.length, 8); i++) {
            paletteColors[i] = colors[i]
        }
        paletteColors = paletteColors.slice() // Force update
    }

    function deletePalette(name) {
        deletePaletteProcess.command = ["bash", "-c", "sed -i '/^" + name + "|/d' ~/.config/quickshell/custom-palettes.txt"]
        deletePaletteProcess.running = true
    }

    Process {
        id: deletePaletteProcess
        running: false

        onExited: (exitCode, exitStatus) => {
            console.log("Palette deleted!")
            loadCustomPalettes()
        }
    }
}
