import QtQuick
import QtQuick.Controls
import ".."

CheckBox {
    id: control

    property string availabilityReason: ""

    implicitWidth: text.length > 0 ? Math.max(28, contentItem.implicitWidth) : 28
    implicitHeight: 32
    leftPadding: text.length > 0 ? 28 : 0
    rightPadding: 0
    spacing: 8
    activeFocusOnTab: true
    Accessible.name: text
    Accessible.description: availabilityReason
    Accessible.role: Accessible.CheckBox

    indicator: Rectangle {
        objectName: control.objectName + "_indicator"
        x: control.text.length > 0 ? 2 : Math.round((control.width - width) / 2)
        y: Math.round((control.height - height) / 2)
        width: 18
        height: 18
        radius: 4
        color: control.checkState === Qt.Unchecked
            ? Theme.panel : Theme.accent
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus
            ? Theme.accent
            : (control.checkState === Qt.Unchecked ? Theme.border : Theme.accent)

        UiIcon {
            anchors.centerIn: parent
            visible: control.checkState !== Qt.Unchecked
            name: control.checkState === Qt.PartiallyChecked ? "ui/minus" : "ui/check"
            tone: "white"
            iconSize: 13
        }
    }

    contentItem: Text {
        text: control.text
        color: control.enabled ? Theme.textMuted : Theme.textFaint
        font: control.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
