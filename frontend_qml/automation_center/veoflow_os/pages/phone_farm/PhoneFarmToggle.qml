pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../.."

Button {
    id: control
    objectName: "phoneFarmToggle"

    property string availabilityReason: ""
    property bool fixtureVisualActive: false

    checkable: true
    implicitWidth: 42
    implicitHeight: 28
    padding: 0
    activeFocusOnTab: true
    hoverEnabled: true
    Accessible.role: Accessible.CheckBox
    Accessible.name: text
    Accessible.description: control.availabilityReason
    Accessible.checked: control.checked

    contentItem: Item {
        implicitWidth: 42
        implicitHeight: 28

        Rectangle {
            anchors.centerIn: parent
            width: 40
            height: 22
            radius: 11
            color: control.checked
                && (control.enabled || control.fixtureVisualActive)
                ? Theme.accent : Theme.elevated
            border.width: control.activeFocus ? 2 : 1
            border.color: control.activeFocus
                ? Theme.accent
                : (control.checked ? Theme.accent : Theme.border)

            Rectangle {
                x: control.checked ? parent.width - width - 3 : 3
                y: 3
                width: 16
                height: 16
                radius: 8
                color: control.enabled || control.fixtureVisualActive
                    ? Theme.text : Theme.textFaint

                Behavior on x { NumberAnimation { duration: 110 } }
            }
        }
    }

    background: Rectangle {
        radius: Theme.radiusSmall
        color: control.hovered && control.enabled ? Theme.hover : "transparent"
        border.width: 0
    }
}
