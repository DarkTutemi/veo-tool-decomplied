pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../.."

TextArea {
    id: control
    objectName: "alertsTextArea"
    property string availabilityReason: ""

    leftPadding: 10
    rightPadding: 10
    topPadding: 8
    bottomPadding: 8
    color: control.enabled ? Theme.text : Theme.textFaint
    placeholderTextColor: Theme.textFaint
    selectionColor: Theme.accent
    selectedTextColor: "white"
    font.pixelSize: 11
    activeFocusOnTab: true
    selectByMouse: true
    wrapMode: TextEdit.Wrap
    Accessible.name: placeholderText
    Accessible.description: control.availabilityReason
    background: Rectangle {
        radius: Theme.radiusSmall
        color: Theme.elevated
        border.width: 1
        border.color: control.activeFocus ? Theme.accent : Theme.borderSoft
    }
}
