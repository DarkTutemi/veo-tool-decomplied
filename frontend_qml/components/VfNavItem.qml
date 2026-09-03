import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root

    property string label: ""
    property string shortLabel: ""
    property bool active: false
    signal clicked()

    Layout.fillWidth: true
    Layout.preferredHeight: VfTheme.dp(34)
    radius: VfTheme.dp(6)
    color: active ? VfTheme.blueFill : (mouseArea.containsMouse ? VfTheme.surfaceSoft : "transparent")
    border.width: active ? 1 : 0
    border.color: active ? VfTheme.primary : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: VfTheme.dp(10)
        anchors.rightMargin: VfTheme.dp(10)
        spacing: VfTheme.dp(10)

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(24)
            Layout.preferredHeight: VfTheme.dp(24)
            radius: VfTheme.dp(5)
            color: root.active ? VfTheme.primary : VfTheme.border

            Text {
                anchors.centerIn: parent
                text: root.shortLabel
                color: root.active ? "#FFFFFF" : VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: Font.Bold
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.label
            color: root.active ? VfTheme.primaryPressed : VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontBody
            font.weight: root.active ? Font.DemiBold : Font.Normal
            elide: Text.ElideRight
            visible: parent.width > 72
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
