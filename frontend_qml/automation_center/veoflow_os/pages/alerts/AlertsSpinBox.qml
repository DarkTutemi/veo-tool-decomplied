pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../.."

SpinBox {
    id: control
    property string availabilityReason: ""

    implicitHeight: 34
    editable: true
    activeFocusOnTab: true
    font.pixelSize: 11
    Accessible.name: "Giá trị số"
    Accessible.description: control.availabilityReason
    contentItem: TextInput {
        text: control.textFromValue(control.value, control.locale)
        color: control.enabled ? Theme.text : Theme.textFaint
        selectionColor: Theme.accent
        selectedTextColor: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }
    background: Rectangle {
        radius: Theme.radiusSmall
        color: Theme.elevated
        border.width: 1
        border.color: control.activeFocus ? Theme.accent : Theme.borderSoft
    }
}
