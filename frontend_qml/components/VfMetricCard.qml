import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root

    property string label: ""
    property string value: "0"
    property color accent: VfTheme.primary

    Layout.fillWidth: true
    Layout.preferredHeight: VfTheme.dp(56)
    radius: VfTheme.dp(8)
    color: VfTheme.surface
    border.color: VfTheme.border
    clip: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(10)
        spacing: VfTheme.dp(12)

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(8)
            Layout.fillHeight: true
            radius: VfTheme.dp(4)
            color: root.accent
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(2)

            Text {
                Layout.fillWidth: true
                text: root.label
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.capitalization: Font.AllUppercase
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                text: root.value
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: Font.Bold
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }
}
