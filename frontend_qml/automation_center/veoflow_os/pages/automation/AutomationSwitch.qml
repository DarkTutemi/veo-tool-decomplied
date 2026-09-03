import QtQuick
import QtQuick.Controls
import "../.."

Switch {
    id: control
    property string availabilityReason: ""
    implicitWidth: 44
    implicitHeight: 30
    leftPadding: 3
    rightPadding: 3
    activeFocusOnTab: true
    hoverEnabled: true
    Accessible.name: text
    Accessible.description: control.availabilityReason

    indicator: Rectangle {
        implicitWidth: 38
        implicitHeight: 20
        x: control.leftPadding
        y: (control.height - height) / 2
        radius: height / 2
        color: !control.enabled
            ? Theme.borderSoft
            : control.checked ? Theme.success : Theme.border
        border.width: 1
        border.color: control.activeFocus ? Theme.accent
            : control.checked ? Qt.lighter(Theme.success, 1.1) : Theme.textFaint
        Rectangle {
            width: 16
            height: 16
            y: 1
            x: control.checked ? parent.width - width - 2 : 2
            radius: 8
            color: control.enabled ? "white" : Theme.textFaint
            Behavior on x { NumberAnimation { duration: 100 } }
        }
    }

    contentItem: Item {}
}
