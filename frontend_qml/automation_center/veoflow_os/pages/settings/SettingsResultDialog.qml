pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

SettingsDialog {
    id: root

    objectName: "settingsResultDialog"
    width: Math.min(680, (parent ? parent.width : 720) - 32)
    height: Math.min(480, (parent ? parent.height : 520) - 32)
    x: parent ? Math.max(16, (parent.width - width) / 2) : 0
    y: parent ? Math.max(16, (parent.height - height) / 2) : 0
    property string resultKind: ""
    property var resultData: ({})
    property string resultMessage: ""
    readonly property var detailLines: root.buildDetailLines()

    function memberMap(owner, key) {
        if (owner === null || owner === undefined || typeof owner !== "object")
            return ({})
        const value = owner[key]
        return value !== null && value !== undefined && typeof value === "object"
            && !Array.isArray(value) ? value : ({})
    }

    function listValue(owner, key) {
        if (owner === null || owner === undefined || typeof owner !== "object")
            return []
        const value = owner[key]
        return Array.isArray(value) ? value : []
    }

    function sizeText(value) {
        const bytes = Number(value)
        if (!Number.isFinite(bytes) || bytes < 0) return "Không khả dụng"
        if (bytes >= 1024 * 1024) return (bytes / 1024 / 1024).toFixed(1) + " MB"
        if (bytes >= 1024) return (bytes / 1024).toFixed(1) + " KB"
        return bytes + " B"
    }

    function textValue(owner, key, fallback) {
        if (owner === null || owner === undefined || typeof owner !== "object")
            return String(fallback || "Không khả dụng")
        const value = owner[key]
        if (value === null || value === undefined || String(value).trim().length === 0)
            return String(fallback || "Không khả dụng")
        return String(value)
    }

    function stateText(value) {
        const state = String(value === null || value === undefined ? "" : value).toLowerCase()
        if (state === "ok" || state === "ready" || state === "healthy"
                || state === "applied")
            return "Sẵn sàng"
        if (state === "partial" || state === "degraded"
                || state === "verification_required")
            return "Cần kiểm tra"
        if (state === "error" || state === "failed")
            return "Lỗi"
        return "Không khả dụng"
    }

    function diagnosticsLines(data) {
        const diagnostics = root.memberMap(data, "diagnostics")
        const service = root.memberMap(diagnostics, "service")
        const runtime = root.memberMap(diagnostics, "runtime")
        const health = root.memberMap(diagnostics, "health")
        const disk = root.memberMap(diagnostics, "disk")
        const logs = root.memberMap(diagnostics, "logs")
        return [
            "Dịch vụ: " + root.textValue(service, "name", "VeoFlow OS")
                + " · " + root.textValue(service, "version", "Không rõ phiên bản"),
            "Môi trường: " + root.textValue(service, "environment", "Không khả dụng")
                + " · Tình trạng: " + root.stateText(health.status),
            "Runtime: Python " + root.textValue(runtime, "python_version", "Không khả dụng")
                + " · " + root.textValue(runtime, "operating_system", "Không khả dụng")
                + " · " + root.textValue(runtime, "architecture", "Không khả dụng"),
            "Dung lượng trống: " + root.sizeText(disk.free_bytes)
                + " · Nhật ký: " + root.textValue(logs, "count", "0") + " tệp"
        ]
    }

    function buildDetailLines() {
        const data = root.resultData !== null && root.resultData !== undefined
            && typeof root.resultData === "object" ? root.resultData : ({})
        if (root.resultKind === "diagnostics")
            return root.diagnosticsLines(data)
        if (root.resultKind === "support") {
            const redaction = root.memberMap(data, "redaction")
            return [
                "Tệp: " + root.textValue(data, "bundle_path", "Không khả dụng"),
                "Kích thước: " + root.sizeText(data.size_bytes),
                "SHA-256: " + root.textValue(data, "sha256", "Không khả dụng"),
                "Che dữ liệu nhạy cảm: " + (redaction.enabled === false ? "Không" : "Có")
            ]
        }
        if (root.resultKind === "update")
            return [
                "Phiên bản hiện tại: " + String(data.current_version || "Không khả dụng"),
                "Phiên bản khả dụng: " + String(data.available_version || "Không có"),
                "Có cập nhật: " + (data.update_available === true ? "Có" : "Không"),
                "Chữ ký: " + String(data.signature_status || "Không khả dụng")
            ]
        if (root.resultKind === "certificate")
            return [
                "Thuật toán: " + String(data.algorithm || "Không khả dụng"),
                "Miền chữ ký: " + String(data.signature_domain || "Không khả dụng"),
                "Trust root: " + (data.trust_root_configured === true ? "Đã cấu hình" : "Chưa cấu hình"),
                "Số khóa tin cậy: " + root.listValue(data, "trusted_key_ids").length
            ]
        if (root.resultKind === "resources")
        {
            const reconciliation = root.memberMap(data, "reconciliation")
            return [
                "Trạng thái: " + root.stateText(data.state),
                "Tài nguyên đã kiểm tra: " + root.listValue(data, "resources").length,
                "Lỗi: " + root.listValue(data, "errors").length,
                "Đối soát: " + root.stateText(reconciliation.state)
            ]
        }
        if (root.resultKind === "catalog")
            return [
                "Catalog: " + (data.available === true ? "Đã đọc" : "Không khả dụng"),
                "Bản mới: " + root.listValue(data, "updates").length,
                "Tài nguyên công bố: " + root.listValue(data, "entries").length,
                "Quyền cài đặt: " + (data.trusted_for_install === true
                    ? "Có" : "Không · phải qua manifest ký riêng")
            ]
        if (root.resultKind === "resource") {
            const resource = root.memberMap(data, "resource")
            const reconciliation = root.memberMap(data, "reconciliation")
            return [
                "Tài nguyên: " + root.textValue(resource, "id", "Không khả dụng"),
                "Phiên bản: " + root.textValue(resource, "installed_version", "Không khả dụng"),
                "Đối soát: " + root.stateText(reconciliation.state)
            ]
        }
        if (root.resultKind === "rollback") {
            const reconciliation = root.memberMap(data, "reconciliation")
            return [
                "Phiên bản đã khôi phục: " + root.textValue(data, "restored_version", "Không khả dụng"),
                "Cần khởi động lại: " + (data.restart_required === true ? "Có" : "Không"),
                "Đối soát: " + root.stateText(reconciliation.state)
            ]
        }
        return [String(root.resultMessage || "Thao tác đã hoàn tất phía server.")]
    }

    function openResult(kind, heading, data, message) {
        root.resultKind = String(kind || "result")
        root.title = String(heading || "Kết quả cài đặt")
        root.resultData = data !== null && data !== undefined
            && typeof data === "object" ? data : ({})
        root.resultMessage = String(message || "")
        root.open()
        return true
    }

    contentItem: ColumnLayout {
        spacing: 10
        Text {
            objectName: "settingsResultSummary"
            Layout.fillWidth: true
            text: root.resultMessage.length > 0
                ? root.resultMessage : "Server đã trả kết quả có cấu trúc."
            color: Theme.textMuted
            font.pixelSize: 12
            wrapMode: Text.Wrap
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            Repeater {
                model: root.detailLines
                delegate: Rectangle {
                    id: detailRow
                    required property int index
                    required property var modelData
                    objectName: "settingsResultDetail_" + String(index)
                    property string displayText: String(detailRow.modelData || "Không khả dụng")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: Theme.radiusSmall
                    color: Theme.elevated
                    border.width: 1
                    border.color: Theme.borderSoft
                    Text {
                        objectName: "settingsResultDetailText_" + String(detailRow.index)
                        anchors.fill: parent
                        anchors.margins: 9
                        text: detailRow.displayText
                        color: Theme.textMuted
                        font.pixelSize: 11
                        wrapMode: Text.WrapAnywhere
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
        Item { Layout.fillHeight: true }
    }

    footer: Rectangle {
        objectName: "settingsResultDialog_footer"
        implicitHeight: 56
        color: Theme.panel
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            Item { Layout.fillWidth: true }
            AppButton {
                objectName: "settingsResultCloseButton"
                text: "Đóng"
                primary: true
                activeFocusOnTab: true
                Accessible.name: text
                onClicked: root.close()
            }
        }
    }
}
