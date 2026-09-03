import QtQuick
import QtQuick.Controls
import ".."

Button {
    id: root
    objectName: "iconButton"
    property string accessibleName: text
    property string iconName: ""
    property color iconTone: root.enabled ? Theme.textMuted : Theme.textFaint
    property int iconSize: 17
    implicitWidth: 34
    implicitHeight: 34
    hoverEnabled: true
    Accessible.name: accessibleName
    Accessible.role: Accessible.Button
    contentItem: Item {
        implicitWidth: root.iconName.length > 0 ? root.iconSize : label.implicitWidth
        implicitHeight: Math.max(root.iconSize, label.implicitHeight)
        UiIcon {
            anchors.centerIn: parent
            visible: root.iconName.length > 0
            name: root.iconName
            tone: root.iconTone
            iconSize: root.iconSize
        }
        Text {
            id: label
            anchors.fill: parent
            visible: root.iconName.length === 0
            text: root.text
            color: root.enabled ? Theme.textMuted : Theme.textFaint
            font.pixelSize: 15
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    background: Rectangle { radius: 8; color: root.down ? Theme.accentSoft : root.hovered ? Theme.hover : "transparent"; border.width: 1; border.color: root.activeFocus ? Theme.accent : "transparent" }
}
