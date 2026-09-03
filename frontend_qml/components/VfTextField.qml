import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

// Text-entry sibling of VfSelectField/VfValueField. All three deliberately use
// the same fieldHeight, label position and inner control height.
Rectangle {
    id: root

    property string label: ""
    property string value: ""
    property string placeholder: ""
    property color accent: VfTheme.primary
    signal committed(string value)

    Layout.fillWidth: true
    implicitHeight: VfTheme.fieldHeight
    radius: VfTheme.radiusControl
    color: root.enabled ? VfTheme.surfaceSoft : VfTheme.panelRaised
    border.color: root.enabled ? VfTheme.borderSoft : VfTheme.border
    border.width: 1
    clip: true
    opacity: root.enabled ? 1.0 : 0.55

    Rectangle {
        id: accentBar
        anchors.left: parent.left
        anchors.leftMargin: VfTheme.dp(6)
        anchors.top: parent.top
        anchors.topMargin: VfTheme.dp(8)
        width: VfTheme.dp(3)
        height: VfTheme.dp(9)
        radius: VfTheme.dp(2)
        color: root.enabled ? root.accent : VfTheme.textSubtle
    }

    Text {
        anchors.left: accentBar.right
        anchors.leftMargin: VfTheme.dp(5)
        anchors.right: parent.right
        anchors.rightMargin: VfTheme.dp(6)
        anchors.verticalCenter: accentBar.verticalCenter
        text: root.label
        color: root.enabled ? VfTheme.textMuted : VfTheme.textSubtle
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontSmall
        font.weight: VfTheme.weightStrong
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    TextField {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: VfTheme.dp(6)
        anchors.rightMargin: VfTheme.dp(6)
        anchors.bottomMargin: VfTheme.dp(6)
        height: VfTheme.dp(26)
        text: root.value
        placeholderText: root.placeholder
        selectByMouse: true
        enabled: root.enabled
        readOnly: !root.enabled
        leftPadding: VfTheme.dp(7)
        rightPadding: VfTheme.dp(7)
        topPadding: 0
        bottomPadding: 0
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontSmall
        color: root.enabled ? VfTheme.text : VfTheme.textSubtle
        onEditingFinished: root.committed(text.trim())
        background: Rectangle {
            radius: VfTheme.radiusControl - 3
            color: VfTheme.surface
            border.color: parent.activeFocus && root.enabled ? root.accent : VfTheme.borderBox
            border.width: 1
        }
    }
}
