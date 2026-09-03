import QtQuick
import QtQuick.Controls

import "../theme"

Rectangle {
    id: root

    property string text: ""
    property string tooltip: ""
    property string actionId: ""
    property bool checked: false
    property bool showLabel: true
    property color accent: "#10B981"
    property int minWidth: 0
    property int controlHeight: VfTheme.dp(34)

    readonly property bool hasVisibleLabel: root.showLabel
        && root.text.trim().length > 0

    signal toggled(bool checked)

    objectName: root.actionId
    implicitWidth: Math.max(
        root.minWidth,
        contentRow.implicitWidth + VfTheme.dp(root.hasVisibleLabel ? 18 : 12))
    implicitHeight: root.controlHeight
    radius: VfTheme.dp(8)
    opacity: root.enabled ? 1 : 0.58
    color: mouse.containsMouse && root.enabled ? VfTheme.panelRaised : VfTheme.surface
    border.width: 1
    border.color: root.checked && root.enabled ? root.accent : VfTheme.borderBox

    ToolTip.visible: mouse.containsMouse && root.tooltip.length > 0
    ToolTip.text: root.tooltip
    ToolTip.delay: 350

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.hasVisibleLabel ? VfTheme.dp(6) : 0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.hasVisibleLabel
            text: root.text
            color: root.enabled ? VfTheme.text : VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontControl
            font.weight: Font.DemiBold
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: VfTheme.dp(30)
            height: VfTheme.dp(18)
            radius: VfTheme.dp(9)
            color: root.checked && root.enabled ? root.accent : VfTheme.borderStrong

            Rectangle {
                width: VfTheme.dp(12)
                height: VfTheme.dp(12)
                radius: VfTheme.dp(6)
                y: VfTheme.dp(3)
                x: root.checked && root.enabled
                    ? parent.width - width - VfTheme.dp(3)
                    : VfTheme.dp(3)
                color: "#FFFFFF"

                Behavior on x {
                    NumberAnimation { duration: 120 }
                }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.toggled(!root.checked)
    }
}
