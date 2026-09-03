import QtQuick
import QtQuick.Controls as Controls

import "../theme"

Controls.TabButton {
    id: control

    implicitHeight: VfTheme.dp(38)
    implicitWidth: Math.max(132, tabLabel.implicitWidth + 28)
    font.family: VfTheme.fontFamily
    font.pixelSize: VfTheme.dp(14)
    font.weight: control.checked ? VfTheme.weightStrong : VfTheme.weightControl

    contentItem: Text {
        id: tabLabel
        text: control.text
        color: control.checked ? VfTheme.text : VfTheme.textMuted
        font: control.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: VfTheme.dp(8)
        color: control.checked ? VfTheme.surface : VfTheme.surfaceSoft
        border.width: 1
        border.color: control.checked ? VfTheme.primary : VfTheme.borderBox
    }
}
