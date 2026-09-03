import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Dialog {
    id: control

    property string acceptText: "Lưu"
    property string cancelText: "Hủy"
    property bool formValid: true
    property bool pending: false
    property string pendingEntityId: ""
    property string errorMessage: ""
    property string invalidReason: "Chưa đủ dữ liệu hợp lệ"
    property string acceptButtonObjectName: control.objectName + "_acceptButton"
    property string cancelButtonObjectName: control.objectName + "_cancelButton"
    signal submitRequested()

    modal: true
    focus: true
    padding: 14
    standardButtons: Dialog.NoButton
    closePolicy: control.pending ? Popup.NoAutoClose : Popup.CloseOnEscape

    function beginPending(entityId) {
        control.errorMessage = ""
        control.pendingEntityId = String(entityId || "")
        control.pending = true
    }

    function finishPending(ok, message) {
        control.pending = false
        control.pendingEntityId = ""
        control.errorMessage = ok ? "" : String(message || "Thao tác bị server từ chối")
        if (ok)
            control.close()
    }

    Shortcut {
        sequence: "Return"
        enabled: control.visible && control.formValid && !control.pending
        context: Qt.WindowShortcut
        onActivated: control.submitRequested()
    }
    Shortcut {
        sequence: "Enter"
        enabled: control.visible && control.formValid && !control.pending
        context: Qt.WindowShortcut
        onActivated: control.submitRequested()
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

    footer: Rectangle {
        objectName: control.objectName + "_footer"
        implicitHeight: control.errorMessage.length > 0 ? 82 : 60
        color: Theme.panel
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: Theme.borderSoft
        }
        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            spacing: 5
            Text {
                objectName: control.objectName + "_errorText"
                visible: control.errorMessage.length > 0
                Layout.fillWidth: true
                text: control.errorMessage
                color: Theme.danger
                font.pixelSize: 11
                elide: Text.ElideRight
                Accessible.name: text
                Accessible.role: Accessible.AlertMessage
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Item { Layout.fillWidth: true }
                AppButton {
                    objectName: control.cancelButtonObjectName
                    text: control.cancelText
                    enabled: !control.pending
                    availabilityReason: enabled ? "" : "Đang chờ kết quả từ server"
                    onClicked: control.reject()
                }
                AppButton {
                    objectName: control.acceptButtonObjectName
                    text: control.pending ? "Đang xử lý…" : control.acceptText
                    primary: true
                    enabled: control.formValid && !control.pending
                    availabilityReason: control.pending
                        ? "Đang chờ kết quả từ server"
                        : enabled ? "" : control.invalidReason
                    onClicked: control.submitRequested()
                }
            }
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
