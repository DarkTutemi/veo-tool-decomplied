import QtQuick

import "../theme"

Text {
    id: root

    property string actionId: ""
    property var payload: ({})
    property bool requireControlModifier: false

    signal clicked()
    signal actionRequested(string actionId, var payload)

    objectName: root.actionId
    color: root.enabled && mouse.containsMouse ? VfTheme.primary : VfTheme.text
    opacity: root.enabled ? 1 : 0.55
    font.family: VfTheme.fontFamily
    font.pixelSize: VfTheme.fontSection
    font.weight: Font.Bold
    elide: Text.ElideRight

    function actionPayload() {
        var data = {
            action_id: root.actionId,
            text: root.text
        }
        for (var key in root.payload)
            data[key] = root.payload[key]
        return data
    }

    function trigger(mouseEvent) {
        if (root.requireControlModifier && !(mouseEvent.modifiers & Qt.ControlModifier))
            return
        root.actionRequested(root.actionId, root.actionPayload())
        root.clicked()
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mouseEvent => root.trigger(mouseEvent)
    }
}
