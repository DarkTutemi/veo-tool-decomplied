import QtQuick
import QtQuick.Controls as Controls

import "../components"
import "../theme"

Controls.CheckBox {
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
        radius: VfTheme.dp(6)
        color: control.checked ? control.accent : VfTheme.surface
        border.width: 1
        border.color: control.checked ? control.accent : VfTheme.borderStrong

        VfAppIcon {
            anchors.centerIn: parent
            name: control.checked ? "check-mark-button" : ""
            size: VfTheme.dp(12)
            framed: false
            color: "#FFFFFF"
            visible: name.length > 0
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
