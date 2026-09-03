import QtQuick
import QtQuick.Controls as Controls

import "../theme"

Controls.RadioButton {
    id: control

    property color accent: VfTheme.primary

    implicitHeight: VfTheme.dp(32)
    spacing: VfTheme.dp(8)
    font.family: VfTheme.fontFamily
    font.pixelSize: VfTheme.dp(14)

    indicator: Rectangle {
        implicitWidth: VfTheme.dp(20)
        implicitHeight: VfTheme.dp(20)
        x: control.leftPadding
        y: Math.round((control.height - height) / 2)
        radius: VfTheme.dp(10)
        color: VfTheme.surface
        border.width: 1
        border.color: control.checked ? control.accent : VfTheme.borderStrong

        Rectangle {
            anchors.centerIn: parent
            width: VfTheme.dp(10)
            height: VfTheme.dp(10)
            radius: VfTheme.dp(5)
            color: control.checked ? control.accent : "transparent"
        }
    }

    contentItem: Text {
        text: control.text
        color: control.enabled ? VfTheme.text : VfTheme.textSubtle
        font: control.font
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
        elide: Text.ElideRight
    }
}
