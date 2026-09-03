pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "deviceBatchForm"
    property var readiness: ({})
    property var deviceModel: null
    property var permissionChecker: null
    property var selectedIds: ({})
    property int selectionRevision: 0
    readonly property var operations: (root.readiness || {}).operations || []
    readonly property bool executable: Boolean((root.readiness || {}).executable)
        && root.can("device.operate")
    readonly property var selectedOperation: root.operationAt(operationBox.currentIndex)
    readonly property bool selectedOperationSafe:
        String((root.selectedOperation || {}).op || "") === "agent"
        && String((root.selectedOperation || {}).risk || "") === "read_only"
    readonly property int selectedCount: root.selectedDeviceIds().length
    signal closeRequested()
    signal executeRequested(string operationKey, var deviceIds)
    Accessible.name: "Biểu mẫu thao tác hàng loạt thiết bị"
    Accessible.description: String((root.readiness || {}).summary || "Không có batch readiness")
    Accessible.role: Accessible.Dialog

    function can(permission) {
        return root.permissionChecker
            ? Boolean(root.permissionChecker(String(permission || ""))) : false
    }

    function operationAt(index) {
        const bounded = Number(index)
        return bounded >= 0 && bounded < root.operations.length
            ? root.operations[bounded] || ({}) : ({})
    }

    function isSelected(deviceId) {
        const revision = root.selectionRevision
        return Boolean((root.selectedIds || {})[String(deviceId || "")])
    }

    function toggleDevice(deviceId) {
        const identity = String(deviceId || "")
        if (!identity || !root.deviceModel) return false
        let exists = false
        for (let index = 0; index < root.deviceModel.count; index++) {
            if (String((root.deviceModel.get(index) || {}).deviceId || "") === identity) {
                exists = true
                break
            }
        }
        if (!exists) return false
        const next = Object.assign({}, root.selectedIds || ({}))
        if (next[identity]) delete next[identity]
        else next[identity] = true
        root.selectedIds = next
        root.selectionRevision += 1
        return true
    }

    function selectedDeviceIds() {
        const revision = root.selectionRevision
        const result = []
        if (!root.deviceModel) return result
        for (let index = 0; index < root.deviceModel.count; index++) {
            const identity = String((root.deviceModel.get(index) || {}).deviceId || "")
            if (identity && (root.selectedIds || {})[identity]) result.push(identity)
        }
        return result
    }

    function execute() {
        const operation = root.selectedOperation || ({})
        const targets = root.selectedDeviceIds()
        if (!root.executable || !root.selectedOperationSafe
                || targets.length === 0 || !operation.key)
            return false
        root.executeRequested(String(operation.key), targets)
        return true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: "Thao tác hàng loạt"; color: Theme.text; font.pixelSize: 21; font.weight: Font.Bold }
                Text { text: "Target và operation catalog lấy từ phone_farm.snapshot"; color: Theme.textFaint; font.pixelSize: 11 }
            }
            Foundation.StatusPill {
                text: root.executable ? "Read-only probes" : "Không khả dụng"
                tone: root.executable ? Theme.info : Theme.warning
            }
            Foundation.IconButton {
                objectName: "deviceBatchCloseButton"
                text: ""
                iconName: "ui/close"
                accessibleName: "Đóng biểu mẫu batch"
                activeFocusOnTab: true
                onClicked: root.closeRequested()
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    Text { text: "Thiết bị trong trang snapshot"; color: Theme.text; font.pixelSize: 13; font.weight: Font.DemiBold }
                    ListView {
                        id: targetList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: root.deviceModel
                        spacing: 4
                        clip: true
                        reuseItems: true
                        Accessible.name: "Chọn thiết bị từ projection"
                        Accessible.role: Accessible.List
                        delegate: AppCheckBox {
                            id: targetCheck
                            required property int index
                            required property string deviceId
                            required property var label
                            required property var healthState
                            objectName: "batchDeviceCheck_" + String(targetCheck.deviceId || index)
                            width: targetList.width
                            height: 38
                            text: String(targetCheck.label || targetCheck.deviceId || "Thiết bị")
                                + " · " + String(targetCheck.healthState || "unknown")
                            checked: root.isSelected(targetCheck.deviceId)
                            activeFocusOnTab: true
                            Accessible.name: text
                            Accessible.description: "Target authoritative " + String(targetCheck.deviceId || "")
                            onClicked: root.toggleDevice(String(targetCheck.deviceId || ""))
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: String(root.selectedCount) + " thiết bị được chọn"
                        color: root.selectedCount > 0 ? Theme.textMuted : Theme.warning
                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 370
                Layout.fillHeight: true
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10
                    Text { text: "Operation do server cho phép"; color: Theme.text; font.pixelSize: 13; font.weight: Font.DemiBold }
                    PhoneFarmFilterComboBox {
                        id: operationBox
                        objectName: "deviceBatchOperationBox"
                        Layout.fillWidth: true
                        model: root.operations
                        textRole: "label"
                        activeFocusOnTab: true
                        Accessible.name: "Chọn resident probe read-only"
                    }
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 8
                        rowSpacing: 7
                        Text { text: "Capability"; color: Theme.textFaint; font.pixelSize: 11 }
                        Text { text: String((root.readiness || {}).capability || "Không khả dụng"); color: Theme.textMuted; font.pixelSize: 11 }
                        Text { text: "Chế độ"; color: Theme.textFaint; font.pixelSize: 11 }
                        Text { text: String((root.readiness || {}).execution_mode || "Không khả dụng"); color: Theme.textMuted; font.pixelSize: 11 }
                        Text { text: "Server preview"; color: Theme.textFaint; font.pixelSize: 11 }
                        Text { text: Boolean((root.readiness || {}).supports_server_preview) ? "Có" : "Chưa có"; color: Boolean((root.readiness || {}).supports_server_preview) ? Theme.success : Theme.warning; font.pixelSize: 11 }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: String((root.readiness || {}).summary || "Không có lý do từ backend")
                        color: Theme.textMuted
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Không có lock, release, set, provision, LIVE, input, shell hay runtime update trong form này."
                        color: Theme.warning
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                    Item { Layout.fillHeight: true }
                    AppButton {
                        objectName: "deviceBatchExecuteButton"
                        Layout.fillWidth: true
                        text: "Chạy probe trên thiết bị đã chọn"
                        primary: true
                        activeFocusOnTab: true
                        enabled: root.executable && root.selectedCount > 0
                            && root.operations.length > 0 && root.selectedOperationSafe
                        Accessible.name: text
                        Accessible.description: enabled
                            ? "Gọi device.batch bằng operation catalog và target từ snapshot"
                            : "Thiếu permission, read-only operation hoặc target authoritative"
                        onClicked: root.execute()
                    }
                }
            }
        }
    }
}
