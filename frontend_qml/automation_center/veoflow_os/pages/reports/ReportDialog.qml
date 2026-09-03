pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../.."

Dialog {
    id: control

    modal: true
    focus: true
    padding: 14
    standardButtons: Dialog.NoButton
    closePolicy: Popup.CloseOnEscape

    header: Rectangle {
        objectName: control.objectName + "_header"
        implicitHeight: 54
        color: Theme.panel
        Accessible.name: control.title
        Accessible.role: Accessible.Heading
        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            text: control.title
            color: Theme.text
            font.pixelSize: Theme.fontSection
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Theme.borderSoft
        }
    }

    background: Rectangle {
        objectName: control.objectName + "_background"
        radius: Theme.radiusLarge
        color: Theme.panel
        border.width: 1
        border.color: Theme.border
        Accessible.name: control.title
        Accessible.role: Accessible.Dialog
    }
}
