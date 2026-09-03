pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: root
    property int selectedIndex: -1
    readonly property var selectedDevice: selectedIndex >= 0 ? controlPlane.deviceModel.get(selectedIndex) : ({})
    Connections { target: controlPlane.deviceModel; function onCountChanged() { if (controlPlane.deviceModel.count === 0) root.selectedIndex = -1; else if (root.selectedIndex < 0 || root.selectedIndex >= controlPlane.deviceModel.count) root.selectedIndex = 0 } }

    Dialog {
        id: registerDialog; anchors.centerIn: parent; modal: true; width: 520
        title: "Đăng ký Android device"; standardButtons: Dialog.Save | Dialog.Cancel
        onAccepted: controlPlane.callTool("device.upsert", {"label": deviceLabel.text.trim(), "serial": deviceSerial.text.trim(), "platform": devicePlatform.currentText, "os_version": androidVersion.text.trim(), "proxy_region": proxyRegion.text.trim().toUpperCase(), "virtual_camera": virtualCamera.currentText, "status": "offline"})
        contentItem: GridLayout { columns: 2; columnSpacing: 10; rowSpacing: 10
            TextField { id: deviceLabel; Layout.fillWidth: true; placeholderText: "Tên thiết bị" }
            TextField { id: deviceSerial; Layout.fillWidth: true; placeholderText: "ADB serial / agent id" }
            ComboBox { id: devicePlatform; Layout.fillWidth: true; model: ["tiktok", "youtube", "facebook"] }
            TextField { id: androidVersion; Layout.fillWidth: true; placeholderText: "Android 14" }
            TextField { id: proxyRegion; Layout.fillWidth: true; placeholderText: "Region, ví dụ VN" }
            ComboBox { id: virtualCamera; Layout.fillWidth: true; model: ["none", "foxcam", "ghostcam", "hal"] }
        }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }
    Dialog {
        id: bindDialog; anchors.centerIn: parent; modal: true; width: 470
        title: "Gắn tài khoản vào thiết bị"; standardButtons: Dialog.Save | Dialog.Cancel
        onAccepted: controlPlane.callTool("device.bind_account", {"device_id": root.selectedDevice.deviceId, "account_id": bindAccount.currentValue, "country_code": bindCountry.text.trim().toUpperCase()})
        contentItem: ColumnLayout { spacing: 10
            ComboBox { id: bindAccount; Layout.fillWidth: true; model: controlPlane.accountModel; textRole: "displayName"; valueRole: "accountId" }
            TextField { id: bindCountry; Layout.fillWidth: true; placeholderText: "Quốc gia tài khoản, ví dụ VN" }
            Text { Layout.fillWidth: true; text: "Backend kiểm tra liên kết 1:1 và khóa vùng giữa account với proxy device."; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
        }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }

    RowLayout { anchors.fill: parent; spacing: 10
        Panel { Layout.fillWidth: true; Layout.fillHeight: true
            ColumnLayout { anchors.fill: parent; spacing: 0
                RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 58; Layout.leftMargin: 16; Layout.rightMargin: 14
                    ColumnLayout { spacing: 1; Text { text: "Android fleet"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold } Text { text: controlPlane.deviceModel.count + " thiết bị đăng ký"; color: Theme.textFaint; font.pixelSize: 11 } }
                    Item { Layout.fillWidth: true }
                    AppButton { text: "Health check"; onClicked: controlPlane.callTool("device.health_check", {}) }
                    AppButton { text: "+  Thêm thiết bị"; primary: true; onClicked: registerDialog.open() }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                ListView { id: deviceList; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; reuseItems: true; model: controlPlane.deviceModel
                    delegate: Rectangle {
                        id: row
                        required property int index; required property string deviceId; required property string label; required property string platform; required property string serial
                        required property string modelName; required property string osVersion; required property string deviceStatus; required property string health
                        required property string proxyRegion; required property string virtualCamera; required property string lockedBy; required property string heartbeatAt
                        required property int lastSeenSeconds; required property int battery; required property string foreground; required property string accountId; required property string channelId
                        width: deviceList.width; height: 72
                        color: root.selectedIndex === index ? Theme.accentSoft : (mouse.containsMouse ? Theme.hover : "transparent")
                        border.width: 1; border.color: root.selectedIndex === index ? Theme.accent : Theme.borderSoft
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 14; spacing: 12
                            NavIcon { name: "channels"; active: root.selectedIndex === row.index; Layout.preferredWidth: 21; Layout.preferredHeight: 21 }
                            ColumnLayout { Layout.preferredWidth: 230; spacing: 2
                                Text { text: row.label; color: Theme.text; font.pixelSize: 12; font.weight: Font.Bold }
                                Text { text: row.serial + " · " + row.modelName; color: Theme.textFaint; font.pixelSize: 11 }
                            }
                            Text { text: row.osVersion; color: Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 90 }
                            Text { text: row.proxyRegion + " · " + row.virtualCamera; color: Theme.textMuted; font.pixelSize: 11; Layout.fillWidth: true }
                            Text { text: row.battery ? row.battery + "%" : "—"; color: row.battery > 20 ? Theme.success : Theme.warning; font.pixelSize: 11; Layout.preferredWidth: 45 }
                            Text { text: row.health; color: row.health === "healthy" || row.health === "online" ? Theme.success : Theme.warning; font.pixelSize: 11; font.weight: Font.Bold; Layout.preferredWidth: 75 }
                        }
                        MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedIndex = row.index }
                    }
                }
            }
        }
        Panel { Layout.fillHeight: true; Layout.preferredWidth: 370
            ColumnLayout { anchors.fill: parent; spacing: 0
                Text { Layout.fillWidth: true; Layout.margins: 16; text: root.selectedDevice.label || "Chi tiết thiết bị"; color: Theme.text; font.pixelSize: 16; font.weight: Font.Bold }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                ColumnLayout { Layout.fillWidth: true; Layout.margins: 16; spacing: 11
                    Detail { label: "Trạng thái"; value: root.selectedDevice.deviceStatus || "—" }
                    Detail { label: "Heartbeat"; value: root.selectedDevice.heartbeatAt || "Chưa kết nối" }
                    Detail { label: "Foreground"; value: root.selectedDevice.foreground || "—" }
                    Detail { label: "Account"; value: root.selectedDevice.accountId || "Chưa gắn" }
                    Detail { label: "Khóa bởi"; value: root.selectedDevice.lockedBy || "Không khóa" }
                    AppButton { Layout.fillWidth: true; text: "Gắn tài khoản"; primary: true; enabled: Boolean(root.selectedDevice.deviceId) && controlPlane.accountModel.count > 0; onClicked: bindDialog.open() }
                    AppButton { Layout.fillWidth: true; text: "Gỡ tài khoản"; enabled: Boolean(root.selectedDevice.accountId); onClicked: controlPlane.callTool("device.unbind_account", {"device_id": root.selectedDevice.deviceId}) }
                    AppButton { Layout.fillWidth: true; text: root.selectedDevice.lockedBy ? "Nhả khóa" : "Khóa cho operator"; enabled: Boolean(root.selectedDevice.deviceId); onClicked: controlPlane.callTool(root.selectedDevice.lockedBy ? "device.release" : "device.lock", root.selectedDevice.lockedBy ? {"device_id": root.selectedDevice.deviceId} : {"device_id": root.selectedDevice.deviceId, "locked_by": "native-operator"}) }
                    AppButton { Layout.fillWidth: true; text: "Kiểm tra thiết bị"; enabled: Boolean(root.selectedDevice.deviceId); onClicked: controlPlane.callTool("device.health_check", {"device_id": root.selectedDevice.deviceId}) }
                }
                Item { Layout.fillHeight: true }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 80; color: Theme.base; border.width: 1; border.color: Theme.borderSoft
                    Text { anchors.fill: parent; anchors.margins: 13; text: "View phone và automation chạy qua resident daemon; QML chỉ hiển thị trạng thái và gửi capability có policy."; color: Theme.textFaint; font.pixelSize: 11; wrapMode: Text.Wrap }
                }
            }
        }
    }
    component Detail: RowLayout { id: detail; property string label; property string value; Layout.fillWidth: true
        Text { text: detail.label; color: Theme.textFaint; font.pixelSize: 11 } Item { Layout.fillWidth: true } Text { text: detail.value; color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold; Layout.maximumWidth: 220; elide: Text.ElideRight }
    }
}
