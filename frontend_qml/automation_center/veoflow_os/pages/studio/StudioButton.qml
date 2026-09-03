import QtQuick
import QtQuick.Controls
import "../.."

Button {
    id: root
    property bool primary: false
    property string availabilityReason: ""
    property string iconName: ""
    property string accessibleName: text
    implicitWidth: Math.max(34, contentItem.implicitWidth + 20)
    implicitHeight: 32
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: accessibleName
    Accessible.description: availabilityReason

    contentItem: Item {
        implicitWidth: root.iconName.length > 0 ? 16 : label.implicitWidth
        implicitHeight: Math.max(16, label.implicitHeight)
        UiIcon {
            anchors.centerIn: parent
            visible: root.iconName.length > 0
            name: root.iconName
            tone: !root.enabled ? Theme.textFaint : root.primary ? "white"
                : root.checked ? Theme.accent : Theme.textMuted
            iconSize: 16
        }
        Text {
            id: label
            anchors.fill: parent
            visible: root.iconName.length === 0
            text: root.text
            color: !root.enabled ? Theme.textFaint : root.primary ? "white"
                : root.checked ? Theme.accent : Theme.textMuted
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font.pixelSize: 11
            font.weight: root.primary || root.checked ? Font.DemiBold : Font.Normal
        }
    }
    background: Rectangle {
        radius: 7
        color: !root.enabled ? Theme.elevated
            : root.primary ? (root.down ? Qt.darker(Theme.accent, 1.14) : Theme.accent)
            : root.checked ? Theme.accentSoft
            : root.hovered ? Theme.hover : Theme.elevated
        border.width: root.primary && root.enabled ? 0 : 1
        border.color: root.activeFocus || root.checked ? Theme.accent : Theme.borderSoft
    }
}
