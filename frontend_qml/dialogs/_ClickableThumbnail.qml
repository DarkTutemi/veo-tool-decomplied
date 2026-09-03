import QtQuick

import "../theme"

Rectangle {
    id: root

    property string sourcePath: ""
    property bool selected: false
    property bool clickable: true
    property int rowIndex: -1
    property string label: "No image"
    property string status: ""

    signal clicked(int rowIndex)

    radius: VfTheme.dp(8)
    color: image.visible ? VfTheme.border : VfTheme.surfaceSoft
    border.color: selected ? VfTheme.primary : VfTheme.borderBox
    border.width: selected ? 2 : 1
    clip: true

    function normalizedSource() {
        var raw = String(root.sourcePath || "")
        if (raw.length === 0)
            return ""
        if (raw.indexOf("data:") === 0 || raw.indexOf("file:") === 0 || raw.indexOf("qrc:") === 0)
            return raw
        if (raw.match(/^[A-Za-z]:/) || raw.indexOf("\\") >= 0)
            return "file:///" + raw.replace(/\\/g, "/")
        return raw
    }

    Image {
        id: image
        anchors.fill: parent
        source: root.normalizedSource()
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        visible: String(source).length > 0 && status !== Image.Error
    }

    Rectangle {
        anchors.fill: parent
        visible: root.selected
        color: "transparent"
        border.color: VfTheme.primary
        border.width: 2
        radius: root.radius
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - 12
        spacing: VfTheme.dp(2)
        visible: !image.visible

        Text {
            width: parent.width
            text: root.status.length > 0 ? root.status : root.label
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            font.weight: VfTheme.weightControl
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: enabled
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked(root.rowIndex)
    }
}
