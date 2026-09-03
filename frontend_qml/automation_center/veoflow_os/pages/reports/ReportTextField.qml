import QtQuick
import QtQuick.Controls
import "../.."

TextField {
    id: control
    property string availabilityReason: ""
    activeFocusOnTab: true
    Accessible.name: placeholderText.length > 0 ? placeholderText : "Trường bộ lọc báo cáo"
    Accessible.description: control.availabilityReason
    implicitHeight: 36
    leftPadding: 10
    rightPadding: 10
    color: Theme.textMuted
    placeholderTextColor: Theme.textFaint
    selectionColor: Theme.accent
    selectedTextColor: "white"
    font.pixelSize: 11
    background: Rectangle {
        radius: Theme.radiusSmall
        color: control.activeFocus ? Theme.hover : Theme.elevated
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? Theme.accent : Theme.border
    }
}
