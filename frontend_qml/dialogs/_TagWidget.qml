import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string text: ""

    signal removeRequested(string text)

    implicitWidth: tagRow.implicitWidth + 12
    implicitHeight: VfTheme.dp(24)
    radius: VfTheme.dp(12)
    color: VfTheme.cyanFill
    border.color: VfTheme.cyanBorderSoft

    RowLayout {
        id: tagRow
        anchors.fill: parent
        anchors.leftMargin: VfTheme.dp(8)
        anchors.rightMargin: VfTheme.dp(4)
        spacing: VfTheme.dp(2)

        Text {
            text: root.text
            color: VfTheme.cyanText
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
            elide: Text.ElideRight
        }

        Button {
            Layout.preferredWidth: VfTheme.dp(16)
            Layout.preferredHeight: VfTheme.dp(16)
            text: "x"
            padding: 0
            onClicked: root.removeRequested(root.text)
            contentItem: Text {
                text: parent.text
                color: parent.hovered ? "#DC2626" : VfTheme.cyanText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                font.weight: VfTheme.weightTitle
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Item {}
        }
    }
}
