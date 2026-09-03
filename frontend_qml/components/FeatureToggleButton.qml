import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string text: ""
    property string hint: ""
    property string actionId: ""
    property var payload: ({})
    property bool checkable: true
    property bool selected: false
    property bool emphasized: false
    property bool showIndicator: false
    property color accent: VfTheme.primary
    property color selectedBackground: VfTheme.blueFill
    property color selectedBorder: VfTheme.blueBorderSoft
    property color selectedText: VfTheme.blueText
    property int minWidth: VfTheme.dp(112)

    signal clicked()
    signal toggledState(bool checked)
    signal actionRequested(string actionId, var payload)

    objectName: root.actionId
    implicitWidth: Math.max(root.minWidth, contentRow.implicitWidth + 24)
    implicitHeight: VfTheme.dp(32)
    opacity: root.enabled ? 1 : 0.55
    radius: VfTheme.radiusControl
    color: {
        if (root.emphasized)
            return root.accent
        if (root.selected)
            return root.selectedBackground
        return mouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface
    }
    border.width: 1
    border.color: {
        if (root.emphasized)
            return root.accent
        if (root.selected)
            return root.selectedBorder
        return mouse.containsMouse ? VfTheme.textSubtle : VfTheme.borderBox
    }

    function actionPayload() {
        var data = {
            action_id: root.actionId,
            text: root.text,
            hint: root.hint,
            selected: root.selected,
            emphasized: root.emphasized
        }
        for (var key in root.payload)
            data[key] = root.payload[key]
        return data
    }

    function trigger() {
        if (root.checkable) {
            root.selected = !root.selected
            root.toggledState(root.selected)
        }
        root.actionRequested(root.actionId, root.actionPayload())
        root.clicked()
    }

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: VfTheme.dp(10)
        anchors.rightMargin: VfTheme.dp(10)
        spacing: VfTheme.dp(6)

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(7)
            Layout.preferredHeight: VfTheme.dp(7)
            visible: root.showIndicator
            radius: VfTheme.dp(4)
            color: root.selected || root.emphasized ? "#FFFFFF" : root.accent
            opacity: root.selected || root.emphasized ? 0.95 : 0.85
        }

        Text {
            Layout.fillWidth: true
            text: root.text
            color: root.emphasized ? "#FFFFFF" : (root.selected ? root.selectedText : VfTheme.textSubtle)
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
            font.weight: root.selected || root.emphasized ? VfTheme.weightStrong : VfTheme.weightControl
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        Text {
            text: root.hint
            visible: root.hint.length > 0
            color: root.emphasized ? VfTheme.blueFill : (root.selected ? root.selectedText : VfTheme.textSubtle)
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            font.weight: VfTheme.weightStrong
            verticalAlignment: Text.AlignVCenter
            maximumLineCount: 1
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.trigger()
    }
}
