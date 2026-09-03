import QtQuick
import QtQuick.Controls
import "../.."

SpinBox {
    id: control
    objectName: "settingsSpinBox"

    property string availabilityReason: ""

    activeFocusOnTab: true
    Accessible.description: control.availabilityReason
    implicitHeight: 36
    editable: true
    font.pixelSize: 11
    leftPadding: 10
    rightPadding: 54

    contentItem: TextInput {
        z: 2
        text: control.textFromValue(control.value, control.locale)
        color: control.enabled ? Theme.textMuted : Theme.textFaint
        font: control.font
        horizontalAlignment: Qt.AlignLeft
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        selectByMouse: true
    }
    up.indicator: Rectangle {
        objectName: control.objectName + "_up"
        x: control.width - width
        y: 0
        width: 26
        height: control.height / 2
        color: control.up.pressed ? Theme.hover : "transparent"
        UiIcon {
            anchors.centerIn: parent
            name: "ui/chevron-up"
            iconSize: 12
            tone: control.enabled ? Theme.textMuted : Theme.textFaint
        }
    }
    down.indicator: Rectangle {
        objectName: control.objectName + "_down"
        x: control.width - width
        y: control.height / 2
        width: 26
        height: control.height / 2
        color: control.down.pressed ? Theme.hover : "transparent"
        UiIcon {
            anchors.centerIn: parent
            name: "ui/chevron-down"
            iconSize: 12
            tone: control.enabled ? Theme.textMuted : Theme.textFaint
        }
    }
    background: Rectangle {
        radius: Theme.radiusSmall
        color: control.activeFocus ? Theme.hover : Theme.elevated
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? Theme.accent : Theme.border
    }
}
