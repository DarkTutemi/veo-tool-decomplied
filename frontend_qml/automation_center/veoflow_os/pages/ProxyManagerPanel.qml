pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: root
    property int selectedIndex: -1
    property string previewImportId: ""
    property int previewImportCount: 0
    readonly property var selectedProxy: selectedIndex >= 0
        ? controlPlane.proxyModel.get(selectedIndex) : ({})

    Connections {
        target: controlPlane
        function onActionFinished(toolName, ok, data, message) {
            if (toolName === "proxy.import.preview" && ok) {
                const frozenImport = data.import || {}
                root.previewImportId = String(frozenImport.id || "")
                root.previewImportCount = Number(frozenImport.valid || 0)
                if (root.previewImportId) executeImportDialog.open()
            }
        }
    }
    Connections {
        target: controlPlane.proxyModel
        function onCountChanged() {
            if (controlPlane.proxyModel.count === 0) root.selectedIndex = -1
            else if (root.selectedIndex < 0 || root.selectedIndex >= controlPlane.proxyModel.count)
                root.selectedIndex = 0
        }
    }

    Dialog {
        id: addProxyDialog; anchors.centerIn: parent; modal: true; width: 480
        title: "Thêm proxy"; standardButtons: Dialog.Save | Dialog.Cancel
        onAccepted: controlPlane.callTool("proxy.upsert", {"label": proxyLabel.text.trim(), "url": proxyUrl.text.trim()})
        contentItem: ColumnLayout { spacing: 12
            Text { text: "Hỗ trợ scheme://user:pass@host:port, host:port hoặc host:port:user:pass"; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap; Layout.fillWidth: true }
            TextField { id: proxyLabel; Layout.fillWidth: true; placeholderText: "Tên gợi nhớ, ví dụ VN Mobile 01" }
            TextField { id: proxyUrl; Layout.fillWidth: true; placeholderText: "socks5://user:pass@host:port" }
        }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }
    Dialog {
        id: importProxyDialog; anchors.centerIn: parent; modal: true; width: 560
        title: "Nhập proxy hàng loạt"; standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: controlPlane.callTool("proxy.import.preview", {"proxy_lines": proxyLines.text.split(/\r?\n/).filter(line => line.trim().length > 0), "label_prefix": importPrefix.text.trim(), "check_after_import": checkAfterImport.checked})
        contentItem: ColumnLayout { spacing: 10
            TextArea { id: proxyLines; Layout.fillWidth: true; Layout.preferredHeight: 190; placeholderText: "Mỗi proxy một dòng"; wrapMode: TextEdit.NoWrap }
            TextField { id: importPrefix; Layout.fillWidth: true; placeholderText: "Tiền tố tên, ví dụ Farm VN" }
            CheckBox { id: checkAfterImport; text: "Kiểm tra proxy ngay sau khi nhập"; checked: true }
        }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }
    Dialog {
        id: executeImportDialog; anchors.centerIn: parent; modal: true; width: 430
        title: "Xác nhận nhập proxy"; standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: controlPlane.callTool("proxy.import.execute", {"import_id": root.previewImportId})
        contentItem: Text { width: 380; text: "Bản xem trước đã khóa " + root.previewImportCount + " proxy hợp lệ. Tiến hành lưu vào kho proxy?"; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }
    Dialog {
        id: deleteProxyDialog; anchors.centerIn: parent; modal: true; width: 420
        title: "Xóa proxy"; standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: controlPlane.callTool("proxy.delete", {"proxy_id": root.selectedProxy.proxyId})
        contentItem: Text { width: 370; text: "Xóa “" + (root.selectedProxy.label || "proxy") + "” khỏi kho? Browser đang gán proxy sẽ cần cấu hình lại."; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }

    Panel {
        anchors.fill: parent
        ColumnLayout {
            anchors.fill: parent; spacing: 0
            RowLayout {
                Layout.fillWidth: true; Layout.preferredHeight: 62
                Layout.leftMargin: 16; Layout.rightMargin: 14; spacing: 8
                ColumnLayout { spacing: 1
                    Text { text: "Kho proxy"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold }
                    Text { text: controlPlane.proxyModel.count + " proxy · credential không hiển thị lại"; color: Theme.textFaint; font.pixelSize: 11 }
                }
                Item { Layout.fillWidth: true }
                AppButton { text: "Kiểm tra tất cả"; enabled: controlPlane.proxyModel.count > 0 && !controlPlane.actionBusy; onClicked: controlPlane.callTool("proxy.health_check", {}) }
                AppButton { text: "Nhập hàng loạt"; onClicked: importProxyDialog.open() }
                AppButton { text: "+  Thêm proxy"; primary: true; onClicked: addProxyDialog.open() }
            }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
            ListView {
                id: proxyList; Layout.fillWidth: true; Layout.fillHeight: true
                clip: true; reuseItems: true; model: controlPlane.proxyModel
                delegate: Rectangle {
                    id: proxyRow
                    required property int index
                    required property string proxyId
                    required property string label
                    required property string proxyUrl
                    required property string scheme
                    required property string status
                    required property string countryCode
                    required property string city
                    required property int latencyMs
                    required property real downloadMbps
                    required property bool hasAuth
                    width: proxyList.width; height: 64
                    color: root.selectedIndex === index ? Theme.accentSoft : (mouse.containsMouse ? Theme.hover : "transparent")
                    border.width: 1; border.color: root.selectedIndex === index ? Theme.accent : Theme.borderSoft
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 14; spacing: 12
                        ColumnLayout { Layout.preferredWidth: 250; spacing: 2
                            Text { text: proxyRow.label; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; Layout.fillWidth: true; elide: Text.ElideRight }
                            Text { text: proxyRow.proxyUrl; color: Theme.textFaint; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideMiddle }
                        }
                        Text { text: proxyRow.scheme.toUpperCase() + (proxyRow.hasAuth ? " · AUTH" : ""); color: Theme.accent; font.pixelSize: 11; font.weight: Font.Bold; Layout.preferredWidth: 100 }
                        Text { text: (proxyRow.countryCode || "—") + (proxyRow.city ? " · " + proxyRow.city : ""); color: Theme.textMuted; font.pixelSize: 11; Layout.fillWidth: true }
                        Text { text: proxyRow.latencyMs ? proxyRow.latencyMs + " ms" : "—"; color: proxyRow.latencyMs > 800 ? Theme.warning : Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 80 }
                        Text { text: proxyRow.downloadMbps ? proxyRow.downloadMbps.toFixed(1) + " Mbps" : "—"; color: Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 90 }
                        Text { text: proxyRow.status; color: proxyRow.status === "live" ? Theme.success : proxyRow.status === "dead" ? Theme.danger : Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold; Layout.preferredWidth: 70 }
                        AppButton { text: "Kiểm tra"; enabled: !controlPlane.actionBusy; onClicked: controlPlane.callTool("proxy.health_check", {"proxy_id": proxyRow.proxyId}) }
                    }
                    MouseArea {
                        id: mouse
                        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                        width: Math.max(0, parent.width - 118)
                        hoverEnabled: true; acceptedButtons: Qt.LeftButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectedIndex = proxyRow.index
                    }
                }
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            }
            RowLayout {
                Layout.fillWidth: true; Layout.preferredHeight: 50; Layout.leftMargin: 14; Layout.rightMargin: 14
                Text { text: root.selectedProxy.proxyId ? "Đã chọn: " + root.selectedProxy.label : "Chọn proxy để thao tác"; color: Theme.textFaint; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
                AppButton { text: "Xóa proxy"; enabled: Boolean(root.selectedProxy.proxyId) && !controlPlane.actionBusy; onClicked: deleteProxyDialog.open() }
                AppButton { text: "Kiểm tra IP máy"; onClicked: controlPlane.callTool("proxy.local_ip", {}) }
            }
        }
    }
}
