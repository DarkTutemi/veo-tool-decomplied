import QtQuick

import "../theme"

Text {
    id: root

    signal clicked()

    color: mouse.containsMouse ? VfTheme.primary : VfTheme.text
    font.family: VfTheme.fontFamily
    font.pixelSize: VfTheme.fontBody
    elide: Text.ElideRight

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
