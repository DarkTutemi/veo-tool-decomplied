import QtQuick
import QtQuick.Controls
import "../.."

TextField {
    id: control

    objectName: "settingsTextField"
    property string availabilityReason: ""
    activeFocusOnTab: true
    implicitHeight: 36
    leftPadding: 10
    rightPadding: 10
    color: control.enabled ? Theme.textMuted : Theme.textFaint
    placeholderTextColor: Theme.textFaint
    selectionColor: Theme.accent
    selectedTextColor: "white"
    font.pixelSize: 11
    Accessible.name: placeholderText
    Accessible.description: control.availabilityReason
    background: Rectangle {
        radius: Theme.radiusSmall
        color: control.activeFocus ? Theme.hover : Theme.elevated
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? Theme.accent : Theme.border
    }
}
