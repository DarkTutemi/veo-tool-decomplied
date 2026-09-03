pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../.."

CheckDelegate {
    id: control
    property string availabilityReason: ""

    implicitHeight: 36
    leftPadding: 38
    rightPadding: 10
    font.pixelSize: 11
    activeFocusOnTab: true
    hoverEnabled: true
    Accessible.name: text
    Accessible.description: control.availabilityReason

    indicator: Rectangle {
        x: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 18
        height: 18
        radius: 5
        color: control.checked ? Theme.accent : Theme.base
        border.width: 1
        border.color: control.checked || control.activeFocus
            ? Theme.accent : Theme.border
        UiIcon {
            anchors.centerIn: parent
            visible: control.checked
            name: "semantic/check-circle"
            tone: "white"
            iconSize: 12
        }
    }

    contentItem: Text {
        text: control.text
        color: control.enabled ? Theme.textMuted : Theme.textFaint
        font: control.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: Theme.radiusSmall
        color: control.down || control.hovered ? Theme.hover : "transparent"
        border.width: control.activeFocus ? 1 : 0
        border.color: Theme.accent
    }
}
