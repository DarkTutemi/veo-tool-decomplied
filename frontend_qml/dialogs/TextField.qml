import QtQuick
import QtQuick.Controls
import QtQuick.Controls as Controls

import "../components"
import "../theme"

Controls.TextField {
    id: control

    property color accent: VfTheme.primary

    implicitHeight: VfTheme.dp(40)
    leftPadding: VfTheme.dp(12)
    rightPadding: VfTheme.dp(12)
    topPadding: VfTheme.dp(8)
    bottomPadding: VfTheme.dp(8)
    selectByMouse: true
    color: VfTheme.text
    placeholderTextColor: VfTheme.textSubtle
    selectedTextColor: "#FFFFFF"
    selectionColor: VfTheme.primary
    font.family: VfTheme.fontFamily
    font.pixelSize: VfTheme.dp(14)

    ContextMenu.menu: VfTextEditingContextMenu {
        editor: control
    }

    background: Rectangle {
        radius: VfTheme.radiusControl
        color: control.enabled ? VfTheme.surface : VfTheme.surfaceSoft
        border.width: 1
        border.color: control.activeFocus ? control.accent : (control.hovered ? VfTheme.borderStrong : VfTheme.borderBox)
    }
}
