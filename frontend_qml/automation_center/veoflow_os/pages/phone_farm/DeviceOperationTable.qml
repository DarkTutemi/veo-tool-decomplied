pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation
import "../../components/device" as Device

Panel {
    id: root
    objectName: "deviceOperationTable"
    color: Theme.panel
    property var operationModel: null
    property var deviceModel: null
    property bool visualProductionFixture: false
    readonly property bool demoProjection: root.hasDemoProjection()
    signal viewAllRequested()
    signal operationRequested(string operationId)
    Accessible.name: "Công việc thiết bị gần đây"
    Accessible.role: Accessible.Table

    function durationText(startedAt, createdAt, finishedAt) {
        const start = new Date(startedAt || createdAt || "")
        const finish = new Date(finishedAt || "")
        if (isNaN(start.getTime()) || isNaN(finish.getTime())) return "Không rõ"
        const seconds = Math.max(0, Math.floor((finish.getTime() - start.getTime()) / 1000))
        const minutes = Math.floor(seconds / 60)
        return minutes > 0 ? minutes + "m " + (seconds % 60) + "s" : seconds + "s"
    }

    function operationStateLabel(state) {
        const value = String(state || "unknown")
        if (value === "waiting_approval") return "Chờ phê duyệt"
        if (value === "verification_required") return "Cần đối soát"
        if (value === "stop_requested") return "Đang dừng an toàn"
        const labels = {
            "queued": "Đã xếp hàng",
            "running": "Đang chạy",
            "paused": "Tạm dừng",
            "succeeded": "Hoàn tất",
            "failed": "Thất bại",
            "cancelled": "Đã hủy",
            "stopped": "Đã dừng"
        }
        return labels[value] || value || "Không rõ"
    }

    function operationLabel(semanticType) {
        const labels = {
            "device.flow.start": "Chạy flow",
            "device.app.open_tiktok": "Mở TikTok",
            "device.media.stage": "Nạp video",
            "device.screenshot.capture": "Chụp màn hình",
            "device.runtime.inspect": "Kiểm tra runtime",
            "device.tiktok.publish.request": "Đăng video TikTok"
        }
        const value = String(semanticType || "")
        return labels[value] || value || "Không rõ"
    }

    function deviceLabel(deviceId) {
        const identity = String(deviceId || "")
        if (!root.deviceModel) return identity || "—"
        for (let index = 0; index < root.deviceModel.count; index++) {
            const device = root.deviceModel.get(index) || ({})
            if (String(device.deviceId || "") === identity)
                return String(device.label || identity)
        }
        return identity || "—"
    }

    function deviceStatus(deviceId) {
        const identity = String(deviceId || "")
        if (!root.deviceModel) return ({})
        for (let index = 0; index < root.deviceModel.count; index++) {
            const device = root.deviceModel.get(index) || ({})
            if (String(device.deviceId || "") === identity)
                return device.microStatuses || ({})
        }
        return ({})
    }

    function deviceProvenance(deviceId) {
        const status = root.deviceStatus(deviceId)
        const provenance = status.provenance || ({})
        const source = String(provenance.source || "").toLowerCase()
        return Boolean(provenance.simulated)
                || ["demo_seed", "demo_only", "simulated"].indexOf(source) >= 0
            ? "demo_seed" : "production"
    }

    function deviceVisualProductionFixture(deviceId) {
        return Boolean(root.deviceStatus(deviceId).visual_production_fixture)
    }

    function hasDemoProjection() {
        if (!root.deviceModel)
            return false
        const count = root.deviceModel.count
        for (let index = 0; index < count; index++) {
            const item = root.deviceModel.get(index) || ({})
            if (root.deviceProvenance(item.deviceId) !== "production")
                return true
        }
        return false
    }

    function evidenceItems(refs, deviceId) {
        if (refs === null || refs === undefined || typeof refs === "string"
                || typeof refs.length !== "number") return []
        const demo = root.deviceProvenance(deviceId) !== "production"
        const result = []
        for (let index = 0; index < refs.length; index++) {
            const item = refs[index]
            if (!item || typeof item !== "object") continue
            const artifactId = String(item.artifactId || item.id || "")
            if (!/^[A-Za-z0-9][A-Za-z0-9_.:-]{0,159}$/.test(artifactId)) continue
            result.push({
                "artifactId": artifactId,
                "kind": String(item.kind || item.type || "artifact"),
                "verificationState": String(item.verificationState
                    || (demo ? "demo_only" : "referenced")),
                "demoThumbnailKey": String(item.demoThumbnailKey || ""),
                "visualTone": String(item.visualTone || "")
            })
        }
        return result
    }

    function operationVisualFixture(parameters) {
        const candidate = (parameters || {}).visual_fixture || ({})
        return root.visualProductionFixture
                && String(candidate.kind || "") === "production_parity"
                && String(candidate.provenance || "") === "demo_seed"
                && Boolean(candidate.simulated)
            ? candidate : ({})
    }

    function timeText(value) {
        const timestamp = new Date(value || "")
        if (isNaN(timestamp.getTime())) return "—"
        const seconds = Math.max(0, Math.floor((new Date().getTime() - timestamp.getTime()) / 1000))
        if (seconds < 60) return seconds + " giây trước"
        const minutes = Math.floor(seconds / 60)
        if (minutes < 60) return minutes + " phút trước"
        const hours = Math.floor(minutes / 60)
        if (hours < 24) return hours + " giờ trước"
        return timestamp.toLocaleString(Qt.locale("vi_VN"), "dd/MM HH:mm")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: root.visualProductionFixture ? 5 : 6

        RowLayout {
            objectName: "deviceOperationHeaderRow"
            Layout.fillWidth: true
            Layout.preferredHeight: root.visualProductionFixture ? 26 : -1
            Layout.maximumHeight: root.visualProductionFixture ? 26 : 16777215
            Text { Layout.fillWidth: true; text: "Công việc thiết bị gần đây"; color: Theme.text; font.pixelSize: 14; font.weight: Font.Bold }
            Foundation.StatusPill {
                objectName: "deviceOperationDemoMarker"
                visible: root.demoProjection && !root.visualProductionFixture
                text: "DEMO"
                tone: Theme.accent
                showDot: true
                Accessible.name: "Bảng operation dùng dữ liệu DEMO"
            }
            AppButton {
                objectName: "viewAllDeviceOperationsButton"
                Layout.preferredHeight: root.visualProductionFixture ? 24 : -1
                Layout.maximumHeight: root.visualProductionFixture
                    ? 24 : 16777215
                text: "Xem tất cả"
                subtle: true
                activeFocusOnTab: true
                Accessible.name: text + " công việc thiết bị"
                onClicked: root.viewAllRequested()
            }
        }

        RowLayout {
            objectName: "deviceOperationColumnHeaderRow"
            Layout.fillWidth: true
            Layout.preferredHeight: 22
            spacing: 8
            Repeater {
                model: [
                    {"text": "Thời gian", "width": 120},
                    {"text": "Thiết bị", "width": 100},
                    {"text": "Tác vụ", "width": 210},
                    {"text": root.visualProductionFixture
                        ? "Tài khoản" : "Trạng thái", "width": 130},
                    {"text": root.visualProductionFixture
                        ? "Tiến trình / Kết quả" : "Tiến độ",
                        "width": root.visualProductionFixture ? 145 : 130},
                    {"text": "Thời lượng", "width": 80},
                    {"text": "Bằng chứng", "width": 124},
                    {"text": "", "width": 34}
                ]
                delegate: Text {
                    required property var modelData
                    Layout.fillWidth: modelData.text === "Tác vụ"
                    Layout.preferredWidth: Number(modelData.width)
                    text: String(modelData.text)
                    color: Theme.textFaint
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
            }
        }
        Rectangle {
            objectName: "deviceOperationHeaderDivider"
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        ListView {
            id: operationList
            objectName: "deviceOperationList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.operationModel
            clip: true
            reuseItems: true
            delegate: Item {
                id: operationRow
                required property int index
                required property string operation_id
                required property string device_id
                required property string semantic_type
                required property string state_value
                required property var progress_value
                required property var evidence_refs
                required property var parameters
                required property var started_at
                required property var finished_at
                required property var created_at
                objectName: "deviceOperationRow_" + String(operationRow.operation_id || index)
                readonly property var visualFixture: root.operationVisualFixture(
                    operationRow.parameters
                )
                readonly property bool hasVisualFixture:
                    Object.keys(operationRow.visualFixture).length > 0
                width: operationList.width
                height: 38
                Accessible.name: (operationRow.hasVisualFixture
                    ? String(operationRow.visualFixture.actionLabel || "Tác vụ")
                        + " trên "
                        + String(operationRow.visualFixture.deviceLabel || "thiết bị")
                        + ", "
                        + String(operationRow.visualFixture.resultLabel || "kết quả")
                        + ", fixture production mô phỏng từ demo_seed"
                    : root.operationLabel(operationRow.semantic_type)
                        + " trên " + root.deviceLabel(operationRow.device_id)
                        + ", " + root.operationStateLabel(operationRow.state_value))
                    + ", tiến độ " + (operationRow.progress_value === null || operationRow.progress_value === undefined ? "không rõ" : String(operationRow.progress_value) + "%")
                Accessible.role: Accessible.Row

                RowLayout {
                    anchors.fill: parent
                    spacing: 8
                    Text {
                        objectName: "operationTime_"
                            + String(operationRow.operation_id || operationRow.index)
                        Layout.preferredWidth: 120
                        text: operationRow.hasVisualFixture
                            ? String(operationRow.visualFixture.timeLabel || "—")
                            : root.timeText(operationRow.started_at
                                || operationRow.created_at)
                        color: Theme.textFaint
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    Text {
                        objectName: "operationDevice_"
                            + String(operationRow.operation_id || operationRow.index)
                        Layout.preferredWidth: 100
                        text: operationRow.hasVisualFixture
                            ? String(operationRow.visualFixture.deviceLabel || "—")
                            : root.deviceLabel(operationRow.device_id)
                        color: Theme.textMuted
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    Text {
                        objectName: "operationAction_"
                            + String(operationRow.operation_id || operationRow.index)
                        Layout.fillWidth: true
                        Layout.preferredWidth: 210
                        text: operationRow.hasVisualFixture
                            ? String(operationRow.visualFixture.actionLabel || "—")
                            : root.operationLabel(operationRow.semantic_type)
                        color: Theme.text
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    Item {
                        objectName: "operationAccountColumn_"
                            + String(operationRow.operation_id || operationRow.index)
                        Layout.preferredWidth: operationRow.hasVisualFixture ? 130 : 124
                        Layout.preferredHeight: 20

                        Text {
                            objectName: "operationHandle_"
                                + String(operationRow.operation_id
                                    || operationRow.index)
                            anchors.fill: parent
                            visible: operationRow.hasVisualFixture
                            text: String(operationRow.visualFixture.handleLabel || "—")
                            color: Theme.textMuted
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        Device.StatusBadge {
                            objectName: operationRow.hasVisualFixture ? ""
                                : "operationStatus_"
                                    + String(operationRow.operation_id
                                        || operationRow.index)
                            visible: !operationRow.hasVisualFixture
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 4
                            anchors.rightMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            status: String(operationRow.state_value || "unknown")
                            label: root.operationStateLabel(operationRow.state_value)
                            provenance: root.deviceProvenance(operationRow.device_id)
                            visualProductionFixture: root.visualProductionFixture
                                || root.deviceVisualProductionFixture(
                                    operationRow.device_id
                                )
                            compact: true
                            showDemoBadge: false
                            showIcon: true
                        }
                    }
                    Item {
                        objectName: "operationResultColumn_"
                            + String(operationRow.operation_id || operationRow.index)
                        Layout.preferredWidth: operationRow.hasVisualFixture ? 145 : 90
                        Layout.preferredHeight: operationRow.hasVisualFixture ? 23 : 20
                        Text {
                            anchors.fill: parent
                            visible: !operationRow.hasVisualFixture
                            text: operationRow.progress_value === null
                                    || operationRow.progress_value === undefined
                                ? "Không rõ"
                                : String(operationRow.progress_value) + "%"
                            color: operationRow.progress_value === null
                                    || operationRow.progress_value === undefined
                                ? Theme.warning : Theme.textMuted
                            font.pixelSize: 11
                            verticalAlignment: Text.AlignVCenter
                        }
                        Device.StatusBadge {
                            objectName: operationRow.hasVisualFixture
                                ? "operationStatus_"
                                    + String(operationRow.operation_id
                                        || operationRow.index)
                                : ""
                            visible: operationRow.hasVisualFixture
                            height: operationRow.hasVisualFixture ? 23 : implicitHeight
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 4
                            anchors.rightMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            status: String(operationRow.state_value || "unknown")
                            label: String(
                                operationRow.visualFixture.resultLabel || "—"
                            )
                            provenance: root.deviceProvenance(
                                operationRow.device_id
                            )
                            visualProductionFixture: root.visualProductionFixture
                            compact: true
                            showDemoBadge: false
                            showIcon: false
                            showStatusDot: true
                            fixtureOutlined: true
                        }
                    }
                    Text {
                        objectName: "operationDuration_"
                            + String(operationRow.operation_id || operationRow.index)
                        Layout.preferredWidth: 80
                        text: operationRow.hasVisualFixture
                            ? String(operationRow.visualFixture.durationLabel || "—")
                            : root.durationText(operationRow.started_at,
                                operationRow.created_at,
                                operationRow.finished_at)
                        color: text === "Không rõ" ? Theme.warning : Theme.textMuted
                        font.pixelSize: 11
                    }
                    Device.EvidenceStrip {
                        objectName: "operationEvidence_"
                            + String(operationRow.operation_id || operationRow.index)
                        Layout.preferredWidth: 124
                        evidenceItems: root.evidenceItems(
                            operationRow.evidence_refs,
                            operationRow.device_id
                        )
                        maximumVisible: 3
                        provenance: root.deviceProvenance(operationRow.device_id)
                        visualProductionFixture: root.visualProductionFixture
                            || root.deviceVisualProductionFixture(
                                operationRow.device_id
                            )
                        compact: true
                        showProvenanceLabel: false
                        showCountChip: true
                    }
                    Foundation.IconButton {
                        objectName: "operationOverflowButton_" + String(operationRow.operation_id || operationRow.index)
                        text: ""
                        iconName: "ui/more-horizontal"
                        accessibleName: "Tùy chọn tác vụ " + String(operationRow.operation_id || "")
                        activeFocusOnTab: true
                        onClicked: root.operationRequested(String(operationRow.operation_id || ""))
                    }
                }
                Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; height: 1; color: Theme.borderSoft }
            }

            Text { anchors.centerIn: parent; visible: !root.operationModel || root.operationModel.count === 0; text: "Không có operation projection"; color: Theme.warning; font.pixelSize: 11 }
        }
    }
}
