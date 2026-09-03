pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: root
    property string previewImportId: ""
    property int validRows: 0
    property int invalidRows: 0

    Connections {
        target: controlPlane
        function onActionFinished(toolName, ok, data, message) {
            if (toolName !== "browser.import.preview" || !ok) return
            const frozen = data.import || {}
            root.previewImportId = String(frozen.id || "")
            root.validRows = Number(frozen.valid || 0)
            root.invalidRows = Number(frozen.invalid || 0)
            if (root.previewImportId) confirmDialog.open()
        }
    }
    Dialog {
        id: confirmDialog; anchors.centerIn: parent; modal: true; width: 450
        title: "Xác nhận tạo browser"; standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: controlPlane.callTool("browser.import.execute", {"import_id": root.previewImportId})
        contentItem: Text { width: 400; text: root.validRows + " dòng hợp lệ, " + root.invalidRows + " dòng lỗi. Chỉ dữ liệu đã đóng băng ở preview mới được thực thi."; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }

    RowLayout { anchors.fill: parent; spacing: 10
        Panel { Layout.fillWidth: true; Layout.fillHeight: true
            ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                Text { text: "Tạo browser hàng loạt"; color: Theme.text; font.pixelSize: 17; font.weight: Font.Bold }
                Text { Layout.fillWidth: true; text: "Dán CSV để kiểm tra ID, proxy, kho lưu trữ và fingerprint seed trước khi tạo profile."; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
                TextArea { id: csvInput; Layout.fillWidth: true; Layout.fillHeight: true; wrapMode: TextEdit.NoWrap; placeholderText: "label,platform,os,proxy_id,storage_vault_id,locale,timezone,notes,tags\nTikTok VN 01,tiktok,windows,,,,vi-VN,Asia/Bangkok,,farm-vn" }
                RowLayout { Layout.fillWidth: true
                    ComboBox { id: platformBox; model: ["tiktok", "youtube", "facebook", "linkedin"]; Layout.preferredWidth: 150 }
                    ComboBox { id: osBox; model: ["windows", "macos", "linux"]; Layout.preferredWidth: 130 }
                    Item { Layout.fillWidth: true }
                    AppButton { text: "Preview & kiểm tra"; primary: true; enabled: csvInput.text.trim().length > 0 && !controlPlane.actionBusy; onClicked: controlPlane.callTool("browser.import.preview", {"csv_content": csvInput.text, "default_platform": platformBox.currentText, "default_os": osBox.currentText, "idempotency_key": "qml-browser-import-" + Date.now()}) }
                }
            }
        }
        Panel { Layout.fillHeight: true; Layout.preferredWidth: 340
            ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 13
                Text { text: "Quy tắc nhập"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold }
                Rule { title: "Không lộ credential"; detail: "CSV chỉ dùng proxy_id; mật khẩu nằm trong vault backend." }
                Rule { title: "Identity duy nhất"; detail: "Fingerprint seed bị trùng sẽ bị chặn trước execute." }
                Rule { title: "Kho đã xác thực"; detail: "storage_vault_id phải tồn tại và có quyền ghi." }
                Rule { title: "Có thể khôi phục"; detail: "Lịch sử import lưu từng dòng và trạng thái lỗi." }
                Item { Layout.fillHeight: true }
                AppButton { Layout.fillWidth: true; text: "Xem lịch sử import"; onClicked: controlPlane.callTool("fleet.import.list", {"kind": "browser", "limit": 30}) }
            }
        }
    }
    component Rule: ColumnLayout {
        id: rule; property string title; property string detail; Layout.fillWidth: true; spacing: 2
        Text { text: rule.title; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
        Text { Layout.fillWidth: true; text: rule.detail; color: Theme.textFaint; font.pixelSize: 11; wrapMode: Text.Wrap }
    }
}
