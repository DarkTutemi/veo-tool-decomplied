import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string label: ""
    property string value: ""
    property string placeholder: "--"
    property string actionText: ""
    property color accent: VfTheme.primary
    property string actionId: ""

    signal activated()

    function cleanText(value) {
        var text = String(value || "").trim()
        text = text.replace(/^[\uD800-\uDBFF][\uDC00-\uDFFF]\uFE0F?\s*/, "")
        text = text.replace(/^[\u2600-\u27BF]\uFE0F?\s*/, "")
        return text.trim()
    }

    Layout.fillWidth: true
    implicitHeight: VfTheme.fieldHeight
    radius: VfTheme.radiusControl
    color: VfTheme.surfaceSoft
    border.color: VfTheme.borderSoft
    border.width: 1
    clip: true

    Rectangle {
        id: accentBar
        anchors.left: parent.left
        anchors.leftMargin: VfTheme.dp(6)
        anchors.top: parent.top
        anchors.topMargin: VfTheme.dp(8)
        width: VfTheme.dp(3)
        height: VfTheme.dp(9)
        radius: VfTheme.dp(2)
        color: root.accent
    }

    Text {
        id: labelText
        anchors.left: accentBar.right
        anchors.leftMargin: VfTheme.dp(5)
        anchors.right: parent.right
        anchors.rightMargin: VfTheme.dp(6)
        anchors.verticalCenter: accentBar.verticalCenter
        text: root.cleanText(root.label)
        color: VfTheme.textMuted
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontSmall
        font.weight: VfTheme.weightStrong
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    Rectangle {
        id: valueBox
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: VfTheme.dp(6)
        anchors.rightMargin: VfTheme.dp(6)
        anchors.bottomMargin: VfTheme.dp(6)
        height: VfTheme.dp(26)
        radius: VfTheme.radiusControl - 3
        color: VfTheme.surface
        border.color: VfTheme.borderBox
        border.width: 1
        clip: true

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(7)
            anchors.rightMargin: VfTheme.dp(7)
            spacing: VfTheme.dp(6)

            Text {
                Layout.fillWidth: true
                text: root.value.length > 0 ? root.value : root.placeholder
                color: root.value.length > 0 ? VfTheme.text : VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightRegular
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideMiddle
                maximumLineCount: 1
            }

            Text {
                text: root.actionText
                color: VfTheme.primary
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.weight: VfTheme.weightStrong
                visible: root.actionText.length > 0
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: 1
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
