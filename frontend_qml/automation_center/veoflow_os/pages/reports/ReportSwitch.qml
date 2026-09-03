import QtQuick
import QtQuick.Controls
import "../.."

Switch {
    id: control
    activeFocusOnTab: true
    Accessible.name: text
    implicitHeight: 34
    spacing: 7
    font.pixelSize: 11
    indicator: Rectangle {
        implicitWidth: 38
        implicitHeight: 20
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: height / 2
        color: control.checked ? Theme.accent : Theme.elevated
        border.width: 1
        border.color: control.checked ? Theme.accent : Theme.border
        Rectangle {
            x: control.checked ? parent.width - width - 3 : 3
            y: 3
            width: 14
            height: 14
            radius: 7
            color: control.checked ? "white" : Theme.textFaint
        }
    }
    contentItem: Text {
        leftPadding: control.indicator.width + control.spacing
        text: control.text
        color: control.enabled ? Theme.textMuted : Theme.textFaint
        font: control.font
        verticalAlignment: Text.AlignVCenter
    }
}
