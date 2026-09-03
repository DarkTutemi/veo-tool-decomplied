pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../.."

Dialog {
    id: control

    property bool pending: false
    property string pendingCapability: ""
    property string pendingEntityId: ""
    property string errorMessage: ""

    modal: true
    focus: true
    padding: 14
    standardButtons: Dialog.NoButton
    closePolicy: control.pending ? Popup.NoAutoClose : Popup.CloseOnEscape

    function beginPending(capability, entityId) {
        control.errorMessage = ""
        control.pendingCapability = String(capability || "")
        control.pendingEntityId = String(entityId || "")
        control.pending = true
    }

    function finishPending(ok, message) {
        control.pending = false
        control.pendingCapability = ""
        control.pendingEntityId = ""
        control.errorMessage = ok ? "" : String(message || "Thao tác bị server từ chối")
        if (ok)
            control.close()
    }

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
            font.pixelSize: 16
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
        border.color: control.errorMessage.length > 0 ? Theme.danger : Theme.border
        Accessible.name: control.title
        Accessible.role: Accessible.Dialog
    }
}
