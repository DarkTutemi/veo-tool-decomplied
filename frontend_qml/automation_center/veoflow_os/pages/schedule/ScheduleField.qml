import QtQuick
import QtQuick.Controls
import "../.."

TextField {
    id: control
    activeFocusOnTab: true
    Accessible.name: placeholderText.length > 0 ? placeholderText : "Trường lịch trình"
    implicitHeight: 34
    leftPadding: 10
    rightPadding: 10
    color: control.enabled ? Theme.text : Theme.textFaint
    placeholderTextColor: Theme.textFaint
    selectionColor: Theme.accent
    selectedTextColor: "white"
    font.pixelSize: 11
    background: Rectangle {
        radius: Theme.radiusSmall
        color: Theme.elevated
        border.width: 1
        border.color: control.activeFocus ? Theme.accent : Theme.borderSoft
    }
}
