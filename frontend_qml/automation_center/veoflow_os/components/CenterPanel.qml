import QtQuick
import ".."

Rectangle {
    id: root
    property bool elevated: false
    color: root.elevated ? CenterTokens.panelSoft : CenterTokens.panel
    radius: CenterTokens.radius
    border.width: 1
    border.color: CenterTokens.border
}

