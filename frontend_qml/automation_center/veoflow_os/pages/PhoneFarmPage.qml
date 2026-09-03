pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../foundation" as Foundation
import "phone_farm" as Phone

Item {
    id: root
    objectName: "phoneFarmPage"
    Accessible.name: "Phone Farm"
    Accessible.role: Accessible.Pane

    property bool embeddedMode: false

    // qmllint disable unqualified
    readonly property var plane: controlPlane
    // qmllint enable unqualified
    property var phoneFarmSnapshot: ({})
    property var snapshotError: ({})
    property string selectedDeviceId: ""
    property int commandRevision: 0
    property int selectionRevision: 0
    property bool enrollmentOpen: false
    property bool batchOpen: false
    readonly property var projectionData: (phoneFarmSnapshot || {}).data || ({})
    readonly property var counts: projectionData.counts || ({})
    readonly property var onboardingReadiness: projectionData.onboarding || ({})
    readonly property var batchReadiness: projectionData.batch || ({})
    readonly property var deviceModel: root.plane.snapshotStore.collection("phone_farm", "devices")
    readonly property var snapshotSelectedDevice: projectionData.selected_device || ({})
    readonly property var operationModel: root.plane.snapshotStore.collection("phone_farm", "operations")
    readonly property var attentionModel: root.plane.snapshotStore.collection("phone_farm", "attention")
    readonly property var currentFilter: projectionData.filter || ({})
    readonly property var snapshotPage: (phoneFarmSnapshot || {}).page || ({})
    readonly property int deviceCount: root.deviceModel ? root.deviceModel.count : 0
    readonly property var selectedDevice: {
        const revision = root.selectionRevision
        return root.deviceForId(root.selectedDeviceId)
    }
    readonly property bool visualProductionFixture: Boolean(
        ((root.selectedDevice || {}).microStatuses || {})
            .visual_production_fixture
    )
    readonly property bool canRead: root.hasPermission("device.read")
    readonly property bool canOperate: root.hasPermission("device.operate")
    readonly property bool canOperateSelected: root.canOperate
        && String((root.selectedDevice || {}).deviceId || "").length > 0
        && !Boolean((root.selectedDevice || {}).demoReadOnly)
        && String((root.selectedDevice || {}).leaseId || "").length > 0
        && Number((root.selectedDevice || {}).leaseFencingToken || 0) > 0
    readonly property string viewState: root.resolveViewState()

    function reloadSnapshot() {
        root.phoneFarmSnapshot = root.plane.snapshotStore.snapshot("phone_farm")
        root.snapshotError = root.plane.snapshotStore.error("phone_farm")
        root.selectionRevision += 1
        root.reconcileSelection()
    }

    function hasPermission(permission) {
        const requested = String(permission || "").trim()
        if (!requested) return false
        const permissions = (root.phoneFarmSnapshot || {}).permissions || []
        return permissions.indexOf(requested) >= 0 || permissions.indexOf("workspace.admin") >= 0
    }

    function hasProjectionData() {
        return root.deviceCount > 0
            || (root.operationModel && root.operationModel.count > 0)
            || (root.attentionModel && root.attentionModel.count > 0)
            || Object.keys(root.snapshotSelectedDevice).length > 0
    }

    function isDemoOnlyProjection() {
        if (!root.deviceModel || root.deviceModel.count === 0) return false
        for (let index = 0; index < root.deviceModel.count; index++) {
            if (!Boolean((root.deviceModel.get(index) || {}).demoReadOnly)) return false
        }
        return true
    }

    function hasOnlyExpectedDemoPartial() {
        if (!root.isDemoOnlyProjection()) return false
        const errors = (root.phoneFarmSnapshot || {}).partial_errors || []
        if (errors.length === 0) return false
        for (let index = 0; index < errors.length; index++) {
            if (String((errors[index] || {}).code || "") !== "PHONE_RELAY_DEMO_ONLY")
                return false
        }
        return true
    }

    function resolveViewState() {
        const snapshot = root.phoneFarmSnapshot || ({})
        const error = root.snapshotError || ({})
        const hasSnapshot = String(snapshot.snapshot_id || "").length > 0
        const errorCode = String(error.code || "").toUpperCase()
        if (!hasSnapshot) {
            if (errorCode === "PERMISSION_DENIED" || errorCode === "FORBIDDEN") return "permission"
            return errorCode.length > 0 ? "error" : "loading"
        }
        if (!root.canRead) return "permission"
        if (errorCode === "NETWORK_ERROR" || errorCode === "OFFLINE") return "offline"
        if (errorCode.length > 0) return "error"
        if (!root.hasProjectionData()) return "empty"
        const freshness = String((snapshot.freshness || {}).state || "fresh").toLowerCase()
        if (freshness === "partial" && root.hasOnlyExpectedDemoPartial()) return "content"
        if (freshness === "partial" || freshness === "stale") return freshness
        return "content"
    }

    function deviceForId(deviceId) {
        const identity = String(deviceId || "")
        if (!root.deviceModel)
            return ({})
        for (let index = 0; index < root.deviceModel.count; index++) {
            const device = root.deviceModel.get(index) || ({})
            if (String(device.deviceId || "") === identity) return device
        }
        if (String(root.snapshotSelectedDevice.deviceId || "") === identity)
            return root.snapshotSelectedDevice
        return ({})
    }

    function reconcileSelection() {
        const selection = root.plane.entitySelection.current || ({})
        const entity = selection.entity || ({})
        if (String(selection.route || "") === "phone_farm") {
            const linkedId = String(entity.id || "")
            if (linkedId && root.deviceForId(linkedId).deviceId) {
                root.selectedDeviceId = linkedId
                return
            }
        }
        if (root.selectedDeviceId && root.deviceForId(root.selectedDeviceId).deviceId)
            return
        const snapshotId = String(root.snapshotSelectedDevice.deviceId || "")
        if (snapshotId && root.deviceForId(snapshotId).deviceId) {
            root.selectedDeviceId = snapshotId
            return
        }
        root.selectedDeviceId = root.deviceCount > 0
            ? String((root.deviceModel.get(0) || {}).deviceId || "") : ""
    }

    function selectDevice(deviceId) {
        const identity = String(deviceId || "")
        if (!root.deviceForId(identity).deviceId) return false
        root.selectedDeviceId = identity
        root.selectionRevision += 1
        root.plane.navigateEntity("phone_farm", "device", identity, {
            "source": "phone_farm"
        })
        return true
    }

    function requestSnapshot(query) {
        if (!root.canRead) return false
        root.plane.callTool("phone_farm.snapshot", query || ({}))
        return true
    }

    function refreshCurrentSnapshot() {
        const query = {"limit": root.currentFilter.limit !== undefined
            && root.currentFilter.limit !== null ? root.currentFilter.limit : 25}
        if (root.selectedDeviceId) query.selected_device_id = root.selectedDeviceId
        return root.requestSnapshot(query)
    }

    function projectedBatchOperation(operationKey) {
        const key = String(operationKey || "")
        const operations = (root.batchReadiness || {}).operations || []
        for (let index = 0; index < operations.length; index++) {
            const candidate = operations[index] || ({})
            if (String(candidate.key || "") === key) return candidate
        }
        return null
    }

    function runDeviceBatch(operationKey, deviceIds) {
        if (!root.canOperate || !Boolean((root.batchReadiness || {}).executable))
            return false
        const operation = root.projectedBatchOperation(operationKey)
        if (!operation || String(operation.op || "") !== "agent"
                || String(operation.risk || "") !== "read_only")
            return false
        const supplied = Array.isArray(deviceIds) ? deviceIds : []
        const targets = []
        const seen = ({})
        for (let index = 0; index < supplied.length; index++) {
            const identity = String(supplied[index] || "")
            const device = root.deviceForId(identity)
            if (!identity || seen[identity] || !device.deviceId
                    || Boolean(device.demoReadOnly))
                continue
            seen[identity] = true
            targets.push(identity)
        }
        if (targets.length === 0) return false
        const params = JSON.parse(JSON.stringify(operation.params || ({})))
        root.plane.callTool("device.batch", {
            "op": "agent",
            "device_ids": targets,
            "params": params
        })
        return true
    }

    function leaseAcquire() {
        if (!root.canOperate || !root.selectedDevice.deviceId
                || Boolean(root.selectedDevice.demoReadOnly) || root.selectedDevice.leaseId)
            return false
        root.plane.callTool("device.lease.acquire", {
            "device_id": String(root.selectedDevice.deviceId),
            "purpose": "operator_interactive",
            "ttl_seconds": 600
        })
        return true
    }

    function leaseExtend() {
        if (!root.canOperateSelected) return false
        root.plane.callTool("device.lease.extend", {
            "lease_id": String(root.selectedDevice.leaseId),
            "fencing_token": root.selectedDevice.leaseFencingToken,
            "ttl_seconds": 600
        })
        return true
    }

    function leaseRelease() {
        if (!root.canOperateSelected) return false
        root.plane.callTool("device.lease.release", {
            "lease_id": String(root.selectedDevice.leaseId),
            "fencing_token": root.selectedDevice.leaseFencingToken
        })
        return true
    }

    function operationRefs() {
        const refs = []
        if (root.selectedDevice.accountId)
            refs.push({"type": "account", "id": String(root.selectedDevice.accountId)})
        if (root.selectedDevice.channelId)
            refs.push({"type": "channel", "id": String(root.selectedDevice.channelId)})
        return refs
    }

    function semanticKey(semanticType) {
        const value = String(semanticType || "")
        if (value === "device.app.open_tiktok") return "open_tiktok"
        if (value === "device.screenshot.capture") return "screenshot"
        if (value === "device.runtime.inspect") return "runtime_inspect"
        return value.replace(/^device\./, "").replace(/\./g, "_")
    }

    function startOperation(semanticType, parameters) {
        if (!root.canOperateSelected) return false
        const snapshotId = String((root.phoneFarmSnapshot || {}).snapshot_id || "snapshot")
        root.plane.callTool("device.operation.start", {
            "device_id": String(root.selectedDevice.deviceId),
            "lease_id": String(root.selectedDevice.leaseId),
            "fencing_token": root.selectedDevice.leaseFencingToken,
            "semantic_type": String(semanticType),
            "parameters": parameters || ({}),
            "entity_refs": root.operationRefs(),
            "idempotency_key": "qml-phone-" + String(root.selectedDevice.deviceId)
                + "-" + root.semanticKey(semanticType) + "-" + snapshotId
        })
        return true
    }

    function runProjectedOperation(action) {
        if (action === null || action === undefined
                || action.available !== true
                || String(action.capability || "") !== "device.operation.start")
            return false
        const input = action.input
        if (input === null || input === undefined
                || String(input.device_id || "") !== root.selectedDeviceId
                || String(input.lease_id || "").length === 0
                || input.fencing_token === null
                || input.fencing_token === undefined)
            return false
        root.plane.callTool(String(action.capability), input)
        return true
    }

    function stopActiveOperation() {
        const operationId = String(root.selectedDevice.activeOperationId || "")
        if (!root.canOperate || Boolean(root.selectedDevice.demoReadOnly) || !operationId)
            return false
        root.plane.callTool("device.operation.stop", {"operation_id": operationId})
        return true
    }

    function followAttention(deepLink) {
        const link = deepLink || ({})
        const entity = link.entity || ({})
        if (!link.route || !entity.type || !entity.id) return false
        root.plane.navigateEntity(String(link.route), String(entity.type), String(entity.id), link.context || ({}))
        return true
    }

    Component.onCompleted: root.reloadSnapshot()

    Connections {
        target: root.plane.snapshotStore
        function onChanged(route) {
            if (route === "phone_farm") root.reloadSnapshot()
        }
    }

    Connections {
        target: root.plane.entitySelection
        function onSelectionChanged() {
            root.selectionRevision += 1
            root.reconcileSelection()
        }
    }

    Connections {
        target: root.plane.commandStore
        function onChanged(capability, entityType, entityId) {
            root.commandRevision += 1
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.embeddedMode ? 0 : 14
        spacing: root.embeddedMode ? 0 : 10

        Phone.PhoneFarmHeader {
            visible: !root.embeddedMode
            Layout.fillWidth: true
            Layout.preferredHeight: root.embeddedMode ? 0 : implicitHeight
            counts: root.counts
            canOperate: root.canOperate
            onAddDeviceRequested: root.enrollmentOpen = true
            onBulkRequested: root.batchOpen = true
            onBulkMenuRequested: root.batchOpen = true
        }

        Foundation.AsyncStateView {
            objectName: "phoneFarmAsyncState"
            Layout.fillWidth: true
            Layout.fillHeight: true
            viewState: root.viewState
            hasData: root.hasProjectionData()
            accessibleName: "Nội dung Phone Farm"
            emptyTitle: "Chưa có thiết bị"
            emptyDescription: "Chưa có thiết bị Android nào được kết nối với workspace này."
            emptyIconName: "semantic/smartphone"
            emptyEyebrow: "PHONE FARM ĐANG CHỜ THIẾT BỊ"
            emptyGuidance: [
                {"title": "Chuẩn bị thiết bị", "description": "Cài ứng dụng điều khiển đã được xác minh"},
                {"title": "Kết nối hệ thống", "description": "Ghép thiết bị bằng mã dùng một lần"},
                {"title": "Nhận công việc", "description": "Chỉ chạy công việc đã được cấp quyền"}
            ]
            emptyActionText: "Thêm thiết bị"
            emptyActionIconName: "ui/plus"
            emptyActionEnabled: root.canOperate
            emptyActionReason: emptyActionEnabled ? "" : "Bạn không có quyền thêm thiết bị"
            emptySecondaryActionText: "Làm mới"
            emptySecondaryActionIconName: "ui/refresh-cw"
            onEmptyAction: root.enrollmentOpen = true
            onEmptySecondaryAction: root.requestSnapshot({"limit": 25})
            errorMessage: String((root.snapshotError || {}).message || "Không thể tải Phone Farm.")
            requiredPermission: "device.read"
            onRetry: root.requestSnapshot({
                "limit": root.currentFilter.limit !== undefined
                    && root.currentFilter.limit !== null
                    ? root.currentFilter.limit : 25
            })

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 5
                    spacing: 10

                    Phone.DeviceInventory {
                        Layout.fillWidth: false
                        Layout.minimumWidth: 370
                        Layout.preferredWidth: 370
                        Layout.maximumWidth: 370
                        Layout.fillHeight: true
                        deviceModel: root.deviceModel
                        snapshotRevision: root.selectionRevision
                        filter: root.currentFilter
                        page: root.snapshotPage
                        selectedDeviceId: root.selectedDeviceId
                        onDeviceSelected: function(deviceId) { root.selectDevice(deviceId) }
                        onSnapshotRequested: function(query) { root.requestSnapshot(query) }
                    }

                    Phone.DeviceCastGrid {
                        Layout.fillWidth: false
                        Layout.minimumWidth: 358
                        Layout.preferredWidth: 358
                        Layout.maximumWidth: 358
                        Layout.fillHeight: true
                        selectedDevice: root.selectedDevice
                        canOperateSelected: root.canOperateSelected
                        visualProductionFixture: root.visualProductionFixture
                        visualFixture: (root.selectedDevice || {}).visualFixture || ({})
                        onDeviceSelected: function(deviceId) { root.selectDevice(deviceId) }
                        onScreenshotRequested: root.startOperation("device.screenshot.capture", {})
                        onCastMenuRequested: function(deviceId) { root.plane.navigateEntity("phone_farm", "device_cast", deviceId, {"source": "phone_farm", "decoder_available": false}) }
                    }

                    Phone.DeviceInspector {
                        Layout.fillWidth: false
                        Layout.minimumWidth: 435
                        Layout.preferredWidth: 435
                        Layout.maximumWidth: 435
                        Layout.fillHeight: true
                        device: root.selectedDevice
                        visualProductionFixture: root.visualProductionFixture
                        visualFixture: (root.selectedDevice || {}).visualFixture || ({})
                        controlPlaneBridge: root.plane
                        commandRevision: root.commandRevision
                        permissionChecker: function(permission) { return root.hasPermission(permission) }
                        onAcquireLeaseRequested: root.leaseAcquire()
                        onExtendLeaseRequested: root.leaseExtend()
                        onReleaseLeaseRequested: root.leaseRelease()
                        onInspectRuntimeRequested: root.startOperation("device.runtime.inspect", {})
                    }

                    Phone.TikTokQuickPanel {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 360
                        Layout.preferredWidth: 424
                        Layout.fillHeight: true
                        device: root.selectedDevice
                        visualProductionFixture: root.visualProductionFixture
                        operationModel: root.operationModel
                        controlPlaneBridge: root.plane
                        commandRevision: root.commandRevision
                        permissionChecker: function(permission) { return root.hasPermission(permission) }
                        onOpenTikTokRequested: root.startOperation("device.app.open_tiktok", {})
                        onScreenshotRequested: root.startOperation("device.screenshot.capture", {})
                        onSafeStopRequested: root.stopActiveOperation()
                        onSelectContentRequested: root.plane.navigateEntity("content", "content_package", "selector", {"source": "phone_farm", "device_id": root.selectedDeviceId})
                        onOperationRequested: function(action) {
                            root.runProjectedOperation(action)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 2
                    spacing: 10
                    Phone.DeviceOperationTable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 3
                        operationModel: root.operationModel
                        deviceModel: root.deviceModel
                        visualProductionFixture: root.visualProductionFixture
                        onViewAllRequested: root.plane.navigateEntity("phone_farm", "device_operation", "all", {"source": "phone_farm"})
                        onOperationRequested: function(operationId) { root.plane.navigateEntity("phone_farm", "device_operation", operationId, {"source": "phone_farm"}) }
                    }
                    Phone.DeviceAttentionPanel {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 2
                        attentionModel: root.attentionModel
                        visualProductionFixture: root.visualProductionFixture
                        onViewAllRequested: root.plane.navigateEntity("alerts", "incident_query", "phone_farm", {"source": "phone_farm"})
                        onAttentionRequested: function(deepLink) { root.followAttention(deepLink) }
                    }
                }
            }
        }
    }

    Item {
        id: enrollmentLayer
        objectName: "deviceEnrollmentLayer"
        anchors.fill: parent
        visible: root.enrollmentOpen
        z: 100
        Accessible.name: "Lớp trình enrollment"
        Accessible.role: Accessible.Pane

        Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, 0.62) }
        MouseArea { anchors.fill: parent }
        Phone.DeviceEnrollmentWizard {
            anchors.centerIn: parent
            width: Math.min(parent.width - 80, 1040)
            height: Math.min(parent.height - 70, 720)
            readiness: root.onboardingReadiness
            onCloseRequested: root.enrollmentOpen = false
            onRefreshRequested: root.refreshCurrentSnapshot()
        }
    }

    Item {
        id: batchLayer
        objectName: "deviceBatchLayer"
        anchors.fill: parent
        visible: root.batchOpen
        z: 101
        Accessible.name: "Lớp batch thiết bị"
        Accessible.role: Accessible.Pane

        Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, 0.62) }
        MouseArea { anchors.fill: parent }
        Phone.DeviceBatchForm {
            anchors.centerIn: parent
            width: Math.min(parent.width - 100, 960)
            height: Math.min(parent.height - 90, 650)
            readiness: root.batchReadiness
            deviceModel: root.deviceModel
            permissionChecker: function(permission) { return root.hasPermission(permission) }
            onCloseRequested: root.batchOpen = false
            onExecuteRequested: function(operationKey, deviceIds) {
                root.runDeviceBatch(operationKey, deviceIds)
            }
        }
    }
}
