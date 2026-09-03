pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

ReportDialog {
    id: root
    objectName: "reportExportDialog"
    property bool canCreate: false
    property bool canRefresh: false
    property bool createBusy: false
    property bool getBusy: false
    property bool canDownload: false
    property bool downloadBusy: false
    property var formatOptions: []
    property var jobs: []
    property string selectedJobId: ""
    property var selectedJob: ({})
    property var refreshAction: ({})
    property var downloadAction: ({})
    property string commandMessage: ""
    property bool hasFormatSelection: false
    property string selectedFormatKey: ""
    property string selectedFormatLabel: ""
    property string selectedFormatValue: ""
    property bool selectedFormatAvailable: false
    property string selectedFormatCapability: ""
    property var selectedFormatReason: null
    property string selectedFormatIcon: ""
    readonly property var selectedFormatOption: {
        if (!root.hasFormatSelection) return ({})
        return {
            "key": root.selectedFormatKey,
            "label": root.selectedFormatLabel,
            "action": root.selectedFormatAction
        }
    }
    readonly property var selectedFormatAction: root.hasFormatSelection ? {
        "available": root.selectedFormatAvailable,
        "capability": root.selectedFormatCapability,
        "reason_code": root.selectedFormatReason,
        "input": {"format": root.selectedFormatValue},
        "label": root.selectedFormatLabel,
        "icon_key": root.selectedFormatIcon
    } : ({})
    function recordFormatOption(option) {
        const action = option.action
        const input = action.input
        root.selectedFormatKey = String(option.key || "")
        root.selectedFormatLabel = String(option.label || "")
        root.selectedFormatValue = String(input.format || "")
        root.selectedFormatAvailable = action.available === true
        root.selectedFormatCapability = String(action.capability || "")
        root.selectedFormatReason = action.reason_code
        root.selectedFormatIcon = String(action.icon_key || "")
        root.hasFormatSelection = true
        return true
    }
    function syncDefaultFormat() {
        let index = -1
        for (let optionIndex = 0; optionIndex < root.formatOptions.length; optionIndex++) {
            if (Boolean(root.formatOptions[optionIndex].selected_default)) {
                index = optionIndex
                break
            }
        }
        if (index < 0 && root.formatOptions.length > 0) index = 0
        if (index >= 0) {
            formatSelector.currentIndex = index
            root.recordFormatOption(root.formatOptions[index])
        }
    }
    onFormatOptionsChanged: Qt.callLater(root.syncDefaultFormat)
    Component.onCompleted: Qt.callLater(root.syncDefaultFormat)
    signal createRequested(var option)
    signal refreshRequested(var action)
    signal downloadRequested(var action)
    signal selectRequested(string exportJobId)
    modal: true
    width: 650
    height: 560
    title: "Xuất báo cáo bất biến"
    standardButtons: Dialog.NoButton
    function statusTone(state) {
        const normalized = String(state || "").toLowerCase()
        if (normalized === "completed") return Theme.success
        if (normalized === "failed") return Theme.danger
        return Theme.warning
    }

    contentItem: ColumnLayout {
        spacing: 10

        Text {
            Layout.fillWidth: true
            text: "CSV hoặc JSON được tạo bất đồng bộ từ đúng report snapshot hiện tại. UI chỉ hiển thị metadata artifact do server trả về."
            color: Theme.textMuted
            font.pixelSize: 12
            wrapMode: Text.Wrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            ReportComboBox {
                id: formatSelector
                objectName: "reportExportFormatSelector"
                Layout.preferredWidth: 150
                model: root.formatOptions
                textRole: "label"
                valueRole: "key"
                currentIndex: {
                    for (let index = 0; index < root.formatOptions.length; index++)
                        if (Boolean(root.formatOptions[index].selected_default))
                            return index
                    return root.formatOptions.length > 0 ? 0 : -1
                }
                enabled: count > 0 && !root.createBusy
                availabilityReason: enabled ? "" : "Server chưa cung cấp định dạng export"
                activeFocusOnTab: true
                Accessible.name: "Định dạng file xuất"
                onOptionSelected: function(index, option) {
                    root.recordFormatOption(option)
                }
            }
            AppButton {
                objectName: "reportExportCreateButton"
                Layout.preferredWidth: 190
                text: root.createBusy ? "Đang tạo job…" : "Tạo export job"
                primary: true
                activeFocusOnTab: true
                enabled: root.canCreate && !root.createBusy
                    && root.selectedFormatAction.available === true
                    && String(root.selectedFormatAction.capability || "")
                        === "reports.export.create"
                    && String((root.selectedFormatAction.input || {}).format || "")
                Accessible.name: text
                Accessible.description: enabled
                    ? "Gọi reports.export.create với report query hiện tại"
                    : String(root.selectedFormatAction.reason_code
                        || "Thiếu quyền reports.export, định dạng hoặc command đang chạy")
                onClicked: root.createRequested(root.selectedFormatOption)
            }
            Item { Layout.fillWidth: true }
            AppButton {
                objectName: "reportExportRefreshButton"
                text: root.getBusy ? "Đang kiểm tra…" : "Kiểm tra trạng thái"
                activeFocusOnTab: true
                enabled: root.canRefresh && !root.getBusy
                Accessible.name: text
                Accessible.description: enabled
                    ? "Gọi reports.export.get cho job đang chọn"
                    : String(root.refreshAction.reason_code
                        || "Server chưa cho phép cập nhật export job hoặc command đang chạy")
                onClicked: root.refreshRequested(root.refreshAction)
            }
            AppButton {
                objectName: "reportExportDownloadButton"
                text: root.downloadBusy ? "Đang chuẩn bị…" : "Tải xuống"
                primary: root.canDownload
                activeFocusOnTab: true
                enabled: root.canDownload && !root.downloadBusy
                Accessible.name: text
                Accessible.description: enabled
                    ? "Cấp liên kết loopback ký ngắn hạn rồi tải artifact đã xác minh"
                    : String(root.downloadAction.reason_code
                        || "Server chưa cho phép tải export job này")
                onClicked: root.downloadRequested(root.downloadAction)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        Text {
            Layout.fillWidth: true
            text: "Export jobs gần nhất"
            color: Theme.text
            font.pixelSize: 12
            font.weight: Font.Bold
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Repeater {
                model: (root.jobs || []).slice(0, 4)
                delegate: AppButton {
                    id: jobButton
                    required property int index
                    required property var modelData
                    objectName: "reportExportJob_" + String(jobButton.modelData.id || jobButton.index)
                    Layout.fillWidth: true
                    text: String(jobButton.modelData.format || "—").toUpperCase()
                        + " · " + String(jobButton.modelData.state || "unknown")
                    subtle: root.selectedJobId !== String(jobButton.modelData.id || "")
                    primary: root.selectedJobId === String(jobButton.modelData.id || "")
                    activeFocusOnTab: true
                    Accessible.name: "Export " + String(jobButton.modelData.id || "không rõ")
                        + ", " + String(jobButton.modelData.state || "unknown")
                    onClicked: root.selectRequested(String(jobButton.modelData.id || ""))
                }
            }
            Text {
                visible: (root.jobs || []).length === 0
                Layout.fillWidth: true
                text: "Chưa có export job trong projection"
                color: Theme.textFaint
                font.pixelSize: 12
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Theme.radiusMedium
            color: Theme.elevated
            border.width: 1
            border.color: Theme.borderSoft

            GridLayout {
                anchors.fill: parent
                anchors.margins: 14
                columns: 2
                columnSpacing: 14
                rowSpacing: 7

                LabelText { text: "Job ID" }
                ValueText { text: String(root.selectedJob.id || root.selectedJobId || "—") }
                LabelText { text: "Snapshot ID" }
                ValueText { text: String(root.selectedJob.report_snapshot_id || "—") }
                LabelText { text: "Trạng thái" }
                ValueText {
                    objectName: "reportExportSelectedState"
                    text: String(root.selectedJob.state || "—")
                    color: root.statusTone(root.selectedJob.state)
                }
                LabelText { text: "Phiên bản / định dạng" }
                ValueText {
                    text: "v" + String(root.selectedJob.version || "—")
                        + " · " + String(root.selectedJob.format || "—").toUpperCase()
                }
                LabelText { text: "Artifact" }
                ValueText {
                    text: {
                        const artifact = root.selectedJob.artifact || ({})
                        if (!artifact.artifact_id) return "—"
                        return String(artifact.artifact_id) + " · "
                            + String(artifact.media_type || "—") + " · "
                            + String(artifact.size_bytes ?? "—") + " bytes"
                    }
                }
                LabelText { text: "SHA-256" }
                ValueText {
                    text: String((root.selectedJob.artifact || {}).sha256 || "—")
                }
                LabelText { text: "Lỗi" }
                ValueText {
                    text: String(root.selectedJob.error_code || "—")
                    color: root.selectedJob.error_code ? Theme.danger : Theme.textMuted
                }
            }
        }

        Text {
            objectName: "reportExportCommandMessage"
            Layout.fillWidth: true
            text: root.commandMessage || "Trạng thái chỉ thay đổi khi server trả command result hoặc snapshot mới."
            color: root.commandMessage ? Theme.textMuted : Theme.textFaint
            font.pixelSize: 11
            wrapMode: Text.Wrap
        }

        RowLayout {
            Layout.fillWidth: true
            Item { Layout.fillWidth: true }
            AppButton {
                objectName: "reportExportCloseButton"
                text: "Đóng"
                activeFocusOnTab: true
                Accessible.name: text
                onClicked: root.close()
            }
        }
    }

    background: Rectangle {
        radius: Theme.radiusLarge
        color: Theme.panel
        border.width: 1
        border.color: Theme.border
    }

    component LabelText: Text {
        Layout.preferredWidth: 110
        color: Theme.textFaint
        font.pixelSize: 11
    }

    component ValueText: Text {
        Layout.fillWidth: true
        color: Theme.textMuted
        font.pixelSize: 11
        elide: Text.ElideMiddle
    }
}
