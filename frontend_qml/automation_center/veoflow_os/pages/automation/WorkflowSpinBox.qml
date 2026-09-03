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
    rightPadding: 28
    Accessible.name: "Giá trị số"
    Accessible.description: control.availabilityReason
    contentItem: TextInput {
        z: 2
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
    up.indicator: Rectangle {
        objectName: control.objectName + "_up"
        z: 3
        x: control.width - width
        y: 0
        width: 26
        height: control.height / 2
        color: control.up.pressed ? Theme.hover : "transparent"
        UiIcon {
            anchors.centerIn: parent
            name: "ui/chevron-up"
            iconSize: 10
            tone: control.enabled ? Theme.textMuted : Theme.textFaint
        }
    }
    down.indicator: Rectangle {
        objectName: control.objectName + "_down"
        z: 3
        x: control.width - width
        y: control.height / 2
        width: 26
        height: control.height / 2
        color: control.down.pressed ? Theme.hover : "transparent"
        UiIcon {
            anchors.centerIn: parent
            name: "ui/chevron-down"
            iconSize: 10
            tone: control.enabled ? Theme.textMuted : Theme.textFaint
        }
    }
    background: Rectangle {
        radius: Theme.radiusSmall
        color: Theme.elevated
        border.width: 1
        border.color: control.activeFocus ? Theme.accent : Theme.borderSoft
    }
}
