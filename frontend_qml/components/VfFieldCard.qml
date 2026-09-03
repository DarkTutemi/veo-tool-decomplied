import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root

    property string label: ""
    property string value: ""
    property color accent: VfTheme.primary

    Layout.fillWidth: true
    implicitHeight: VfTheme.compactFieldHeight
    radius: VfTheme.radiusControl
    color: VfTheme.surface
    border.color: VfTheme.borderBox

    RowLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(8)
        spacing: VfTheme.dp(8)

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(4)
            Layout.fillHeight: true
            radius: VfTheme.dp(2)
            color: root.accent
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                text: root.label
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.capitalization: Font.AllUppercase
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.value
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }
}
