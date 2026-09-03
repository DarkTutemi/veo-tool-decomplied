pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: root
    property int selectedIndex: -1
    readonly property var selectedVault: selectedIndex >= 0 ? controlPlane.browserStorageModel.get(selectedIndex) : ({})

    Connections {
        target: controlPlane.browserStorageModel
        function onCountChanged() {
            if (controlPlane.browserStorageModel.count === 0) root.selectedIndex = -1
            else if (root.selectedIndex < 0 || root.selectedIndex >= controlPlane.browserStorageModel.count) root.selectedIndex = 0
        }
    }
    Dialog {
        id: addDialog; anchors.centerIn: parent; modal: true; width: 520
        title: "Thêm kho browser"; standardButtons: Dialog.Save | Dialog.Cancel
        onAccepted: controlPlane.callTool("browser.storage.add", {"path": vaultPath.text.trim(), "label": vaultLabel.text.trim()})
        contentItem: ColumnLayout { spacing: 10
            Text { Layout.fillWidth: true; text: "Chọn thư mục cục bộ riêng cho profile Chromium. Backend sẽ kiểm tra quyền ghi, dung lượng và không cho lồng kho."; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
            TextField { id: vaultLabel; Layout.fillWidth: true; placeholderText: "Tên kho, ví dụ SSD Work" }
            TextField { id: vaultPath; Layout.fillWidth: true; placeholderText: "D:\\VeoFlowData\\Browsers" }
        }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }
    Dialog {
        id: removeDialog; anchors.centerIn: parent; modal: true; width: 430
        title: "Gỡ đăng ký kho"; standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: controlPlane.callTool("browser.storage.remove", {"vault_id": root.selectedVault.vaultId})
        contentItem: Text { width: 380; text: "Chỉ gỡ được kho không mặc định và không còn profile. Dữ liệu không bị xóa âm thầm."; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }

    Panel {
        anchors.fill: parent
        ColumnLayout { anchors.fill: parent; spacing: 0
            RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 64; Layout.leftMargin: 18; Layout.rightMargin: 14
                ColumnLayout { spacing: 2
                    Text { text: "Kho lưu trữ browser"; color: Theme.text; font.pixelSize: 16; font.weight: Font.Bold }
                    Text { text: controlPlane.browserStorageModel.count + " kho cục bộ đã xác thực"; color: Theme.textFaint; font.pixelSize: 11 }
                }
                Item { Layout.fillWidth: true }
                AppButton { text: "Kiểm tra dung lượng"; onClicked: controlPlane.callTool("browser.storage.health_check", {}) }
                AppButton { text: "+  Thêm kho"; primary: true; onClicked: addDialog.open() }
            }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
            ListView {
                id: vaultList; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; reuseItems: true
                model: controlPlane.browserStorageModel
                delegate: Rectangle {
                    id: row
                    required property int index; required property string vaultId; required property string label
                    required property string path; required property bool isDefault; required property string vaultStatus
                    required property string filesystem; required property double freeBytes; required property double totalBytes
                    required property string lastCheckedAt; required property string lastError
                    width: vaultList.width; height: 76
                    color: root.selectedIndex === index ? Theme.accentSoft : (mouse.containsMouse ? Theme.hover : "transparent")
                    border.width: 1; border.color: root.selectedIndex === index ? Theme.accent : Theme.borderSoft
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 18; anchors.rightMargin: 16; spacing: 14
                        ColumnLayout { Layout.preferredWidth: 280; spacing: 3
                            RowLayout { Text { text: row.label; color: Theme.text; font.pixelSize: 12; font.weight: Font.Bold } Text { text: row.isDefault ? "MẶC ĐỊNH" : ""; color: Theme.accent; font.pixelSize: 11; font.weight: Font.Bold } }
                            Text { text: row.path; color: Theme.textFaint; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideMiddle }
                        }
                        Text { text: row.filesystem; color: Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 80 }
                        ColumnLayout { Layout.fillWidth: true; spacing: 5
                            Text { text: Formatters.bytes(row.freeBytes) + " trống / " + Formatters.bytes(row.totalBytes); color: Theme.textMuted; font.pixelSize: 11 }
                            ProgressBar { Layout.fillWidth: true; from: 0; to: Math.max(1, row.totalBytes); value: Math.max(0, row.totalBytes - row.freeBytes) }
                        }
                        Text { text: row.vaultStatus; color: row.vaultStatus === "ready" ? Theme.success : Theme.warning; font.pixelSize: 11; font.weight: Font.DemiBold; Layout.preferredWidth: 70 }
                    }
                    MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedIndex = row.index }
                }
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            }
            RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 52; Layout.leftMargin: 14; Layout.rightMargin: 14
                Text { text: root.selectedVault.vaultId ? "Đã chọn: " + root.selectedVault.label : "Chọn một kho để quản lý"; color: Theme.textFaint; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
                AppButton { text: "Đặt mặc định"; enabled: Boolean(root.selectedVault.vaultId) && !root.selectedVault.isDefault; onClicked: controlPlane.callTool("browser.storage.set_default", {"vault_id": root.selectedVault.vaultId}) }
                AppButton { text: "Kiểm tra kho"; enabled: Boolean(root.selectedVault.vaultId); onClicked: controlPlane.callTool("browser.storage.health_check", {"vault_id": root.selectedVault.vaultId}) }
                AppButton { text: "Gỡ kho"; enabled: Boolean(root.selectedVault.vaultId) && !root.selectedVault.isDefault; onClicked: removeDialog.open() }
            }
        }
    }
}
