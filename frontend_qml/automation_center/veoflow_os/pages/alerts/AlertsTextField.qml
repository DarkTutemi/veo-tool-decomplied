pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../.."

TextField {
    id: control
    objectName: "alertsTextField"
    property string availabilityReason: ""

    implicitHeight: 36
    leftPadding: 10
    rightPadding: 10
    color: control.enabled ? Theme.text : Theme.textFaint
    placeholderTextColor: Theme.textFaint
    selectionColor: Theme.accent
    selectedTextColor: "white"
    font.pixelSize: 11
    activeFocusOnTab: true
    selectByMouse: true
    Accessible.name: placeholderText
    Accessible.description: control.availabilityReason
    background: Rectangle {
        radius: Theme.radiusSmall
        color: Theme.elevated
        border.width: 1
        border.color: control.activeFocus ? Theme.accent : Theme.borderSoft
    }
}
