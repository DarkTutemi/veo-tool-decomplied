pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

AutomationDialog {
    id: root
    objectName: "workflowDuplicateDialog"
    acceptButtonObjectName: "workflowDuplicateDialog_acceptButton"
    cancelButtonObjectName: "workflowDuplicateDialog_cancelButton"
    property var workflow: ({})
    signal duplicateRequested(string workflowKey, string name)

    width: 440
    title: "Nhân bản workflow"
    acceptText: "Nhân bản"
    formValid: duplicateKey.text.trim().length > 0
        && duplicateName.text.trim().length > 0
        && duplicateKey.text.trim() !== String(root.workflow.workflow_key || "")
    invalidReason: "Nhập mã và tên bản sao; mã phải khác workflow nguồn"
    onOpened: {
        duplicateKey.text = String(root.workflow.workflow_key || "") + "_copy"
        duplicateName.text = String(root.workflow.name || "") + " (bản sao)"
        root.pending = false
        root.pendingEntityId = ""
        root.errorMessage = ""
    }
    onSubmitRequested: root.duplicateRequested(
        duplicateKey.text.trim(), duplicateName.text.trim())

    contentItem: ColumnLayout {
        spacing: 10
        Text {
            Layout.fillWidth: true
            text: "Bản sao luôn được tạo ở trạng thái tắt để kiểm tra trước khi chạy."
            color: Theme.textMuted
            font.pixelSize: 11
            wrapMode: Text.Wrap
        }
        WorkflowTextField {
            id: duplicateKey
            objectName: "workflowDuplicateKeyField"
            Layout.fillWidth: true
            placeholderText: "workflow_key mới"
            Accessible.name: "Mã workflow bản sao"
        }
        WorkflowTextField {
            id: duplicateName
            objectName: "workflowDuplicateNameField"
            Layout.fillWidth: true
            placeholderText: "Tên workflow bản sao"
            Accessible.name: "Tên workflow bản sao"
        }
    }
}
