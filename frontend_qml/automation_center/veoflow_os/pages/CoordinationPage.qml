pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import ".."
import "../foundation" as Foundation
import "coordination" as Coordination

Item {
    id: root
    objectName: "coordinationPage"
    Accessible.name: "Trung tâm điều phối"
    Accessible.role: Accessible.Pane

    property string selectedOperationKey: ""
    property bool embeddedMode: false
    property bool inspectorVisible: true
    property var coordinationSnapshot: ({})
    property var snapshotError: ({})
    property int operationRevision: 0
    property int timelineRevision: 0
    property int snapshotRevision: 0
    property string channelFilter: ""
    property string stageFilter: ""
    property string operationSort: "operational"
    property int pageLimit: 50
    property var bulkSelection: ({})
    property int bulkSelectionRevision: 0
    // qmllint disable unqualified
    readonly property var plane: controlPlane
    // qmllint enable unqualified

    readonly property var coordinationData: {
        const snapshot = root.coordinationSnapshot || ({})
        return snapshot.data || ({})
    }
    readonly property var coordinationKpis: root.coordinationData.kpis || ({})
    readonly property var operationModel: root.plane.snapshotStore.collection(
        "coordination", "operations")
    readonly property var timelineModel: root.plane.snapshotStore.collection(
        "coordination", "timeline")
    readonly property var healthModel: root.plane.snapshotStore.collection(
        "coordination", "health")
    readonly property var approvalModel: root.plane.snapshotStore.collection(
        "coordination", "approvals")
    readonly property var operationsData: {
        return root.coordinationData.operations || ({})
    }
    readonly property var operationFilters: root.operationsData.filters || ({})
    readonly property var bulkActions: root.operationsData.bulk_actions || ({})
    readonly property int bulkSelectionCount: root.countBulkSelection()
    readonly property int bulkStaleCount: root.countStaleBulkSelection()
    readonly property bool hasProjectionData: root.operationModel.count > 0
        || root.timelineModel.count > 0
        || root.healthModel.count > 0
        || root.approvalModel.count > 0
    readonly property var selectedOperation: {
        const revision = root.operationRevision
        const timelineRevision = root.timelineRevision
        return root.operationForKey(root.selectedOperationKey)
    }
    readonly property string viewState: root.resolveViewState()

    function reloadSnapshot() {
        root.coordinationSnapshot = root.plane.snapshotStore.snapshot("coordination")
        root.snapshotError = root.plane.snapshotStore.error("coordination")
        root.snapshotRevision++
        // SnapshotStore.changed is emitted only after every typed collection
        // has been updated. Reconcile synchronously at that authoritative
        // boundary so both preloaded lazy pages and async first loads select.
        root.reconcileSelection()
    }

    function resolveViewState() {
        const snapshot = root.coordinationSnapshot || ({})
        const error = root.snapshotError || ({})
        const hasSnapshot = String(snapshot.snapshot_id || "").length > 0
        const errorCode = String(error.code || "").toUpperCase()

        if (!hasSnapshot) {
            if (errorCode === "PERMISSION_DENIED" || errorCode === "FORBIDDEN")
                return "permission"
            return errorCode.length > 0 ? "error" : "loading"
        }
        if (errorCode === "NETWORK_ERROR" || errorCode === "OFFLINE")
            return "offline"
        if (errorCode.length > 0)
            return "error"

        const freshness = snapshot.freshness || ({})
        const state = String(freshness.state || "fresh").toLowerCase()
        if (state === "partial" || state === "stale")
            return state
        return root.hasProjectionData ? "content" : "empty"
    }

    function kpiText(name, suffix) {
        const value = root.coordinationKpis[name]
        if (value === undefined || value === null || value === "")
            return "—"
        if (typeof value === "number") {
            const formatted = Number.isInteger(value) ? String(value) : value.toFixed(1)
            return formatted + (suffix || "")
        }
        return String(value) + (suffix || "")
    }

    function kpiDelta(name) {
        const deltas = root.coordinationKpis.deltas
        const evidence = (root.coordinationKpis.delta_evidence || ({}))[name] || ({})
        if (!Boolean(evidence.available)
                || !deltas || deltas[name] === undefined || deltas[name] === null)
            return "Chưa có so sánh"
        const value = deltas[name]
        if (typeof value === "number") {
            const suffix = name === "success_rate" ? "%" : ""
            return (value > 0 ? "+" : "") + String(value) + suffix
                + " so với kỳ trước"
        }
        return String(value)
    }

    function operationFromModel(model, operationKey) {
        const key = String(operationKey || "")
        if (!key || !model)
            return ({})
        for (let index = 0; index < model.count; index++) {
            const operation = model.get(index)
            if (String(operation.operation_key || "") === key)
                return operation
        }
        return ({})
    }

    function operationForKey(operationKey) {
        const queued = root.operationFromModel(root.operationModel, operationKey)
        return queued.operation_key
            ? queued : root.operationFromModel(root.timelineModel, operationKey)
    }

    function selectedVersion(operationKey) {
        const revision = root.bulkSelectionRevision
        return String((root.bulkSelection || ({}))[String(operationKey || "")] || "")
    }

    function countBulkSelection() {
        const revision = root.bulkSelectionRevision
        return Object.keys(root.bulkSelection || ({})).length
    }

    function countStaleBulkSelection() {
        const selectionRevision = root.bulkSelectionRevision
        const modelRevision = root.operationRevision
        const snapshotRevision = root.snapshotRevision
        const selected = root.bulkSelection || ({})
        let stale = 0
        if (selectionRevision < 0 || modelRevision < 0 || snapshotRevision < 0)
            return stale
        for (const key of Object.keys(selected)) {
            const operation = root.operationForKey(key)
            if (!operation.operation_key
                    || String(operation.version_fingerprint || "") !== String(selected[key] || ""))
                stale++
        }
        return stale
    }

    function setOperationSelected(operationKey, versionToken, selected) {
        const key = String(operationKey || "")
        if (!key)
            return
        const next = Object.assign({}, root.bulkSelection || ({}))
        if (selected)
            next[key] = String(versionToken || "")
        else
            delete next[key]
        root.bulkSelection = next
        root.bulkSelectionRevision++
    }

    function selectAllOperations(selected) {
        if (!selected) {
            root.bulkSelection = ({})
            root.bulkSelectionRevision++
            return
        }
        const next = ({})
        for (let index = 0; index < root.operationModel.count; index++) {
            const operation = root.operationModel.get(index)
            const key = String(operation.operation_key || "")
            if (key)
                next[key] = String(operation.version_fingerprint || "")
        }
        root.bulkSelection = next
        root.bulkSelectionRevision++
    }

    function requestSnapshot(cursor) {
        const payload = {
            "window_hours": 24,
            "sort": root.operationSort,
            "limit": root.pageLimit
        }
        if (root.channelFilter)
            payload.channel_id = root.channelFilter
        if (root.stageFilter)
            payload.stage = root.stageFilter
        if (cursor)
            payload.cursor = String(cursor)
        root.plane.callTool("coordination.snapshot", payload)
    }

    function applyProjectedDeepLink(deepLink) {
        const link = deepLink || ({})
        const entity = link.entity || ({})
        const route = String(link.route || "")
        const entityType = String(entity.type || "")
        const entityId = String(entity.id || "")
        if (!route || !entityType || !entityId)
            return
        root.plane.navigateEntity(route, entityType, entityId, link.context || ({}))
    }

    function operationKeyForEntity(entityId) {
        const identity = String(entityId || "")
        if (!identity)
            return ""
        const models = [root.operationModel, root.timelineModel]
        for (let modelIndex = 0; modelIndex < models.length; modelIndex++) {
            const model = models[modelIndex]
            if (!model)
                continue
            for (let index = 0; index < model.count; index++) {
                const operation = model.get(index)
                if (String(operation.operation_key || "") === identity
                        || String(operation.operation_id || "") === identity)
                    return String(operation.operation_key || "")
            }
        }
        return ""
    }

    function reconcileSelection() {
        if (root.operationForKey(root.selectedOperationKey).operation_key)
            return

        const selection = root.plane.entitySelection.current || ({})
        const entity = selection.entity || ({})
        if (String(selection.route || "") === "coordination") {
            const linkedKey = root.operationKeyForEntity(entity.id)
            if (linkedKey) {
                root.selectedOperationKey = linkedKey
                return
            }
        }

        if (root.operationModel.count > 0) {
            const first = root.operationModel.get(0)
            root.selectOperation(String(first.operation_key || ""))
        } else if (root.timelineModel.count > 0) {
            const firstTimelineOperation = root.timelineModel.get(0)
            root.selectOperation(String(firstTimelineOperation.operation_key || ""))
        } else {
            root.selectedOperationKey = ""
        }
    }

    function syncExternalSelection() {
        const selection = root.plane.entitySelection.current || ({})
        if (String(selection.route || "") !== "coordination")
            return
        const entity = selection.entity || ({})
        const linkedKey = root.operationKeyForEntity(entity.id)
        if (linkedKey)
            root.selectedOperationKey = linkedKey
        else if (!entity.id)
            root.reconcileSelection()
    }

    function selectOperation(operationKey) {
        const operation = root.operationForKey(operationKey)
        if (!operation.operation_key)
            return
        root.selectedOperationKey = String(operation.operation_key)
        root.inspectorVisible = true
        const current = root.plane.entitySelection.current || ({})
        const currentEntity = current.entity || ({})
        if (String(current.route || "") === "coordination"
                && String(currentEntity.id || "") === root.selectedOperationKey)
            return
        root.plane.entitySelection.select(
            "coordination",
            "operation",
            root.selectedOperationKey,
            {
                "operation_kind": String(operation.operation_kind || "unknown"),
                "operation_id": String(operation.operation_id || "")
            }
        )
    }

    function selectOperationIndex(index) {
        if (!root.operationModel || index < 0 || index >= root.operationModel.count)
            return false
        const item = root.operationModel.get(index)
        if (!item || !item.operation_key)
            return false
        root.selectOperation(String(item.operation_key))
        return true
    }

    function routeForOperation(operationKind) {
        const kind = String(operationKind || "").toLowerCase()
        if (kind === "render") return "studio"
        if (kind === "publish") return "schedule"
        if (kind === "care") return "automation"
        return "content"
    }

    function openOperation(operationKey) {
        const operation = root.operationForKey(operationKey)
        if (!operation.operation_key)
            return
        const deepLink = operation.deep_link || ({})
        if (String(deepLink.route || "")) {
            root.applyProjectedDeepLink(deepLink)
            return
        }
        root.plane.navigateEntity(
            root.routeForOperation(operation.operation_kind),
            String(operation.operation_kind || "operation"),
            String(operation.operation_id || ""),
            {
                "source": "coordination",
                "operation_key": String(operation.operation_key)
            }
        )
    }

    function openChannel(channelId, healthCode) {
        const id = String(channelId || "")
        if (!id)
            return
        root.plane.navigateEntity(
            "channels",
            "channel",
            id,
            {
                "source": "coordination",
                "health_code": String(healthCode || "UNKNOWN")
            }
        )
    }

    function startChannelOnboarding() {
        root.plane.navigateEntity(
            "channels",
            "",
            "",
            {"source": "coordination", "subview": "onboarding"}
        )
    }

    Connections {
        target: root.plane.snapshotStore
        function onChanged(route) {
            if (route === "coordination")
                root.reloadSnapshot()
        }
    }

    Connections {
        target: root.plane.entitySelection
        function onSelectionChanged() {
            root.syncExternalSelection()
        }
    }

    Connections {
        target: root.operationModel
        function onCountChanged() {
            root.operationRevision++
        }
        function onModelReset() {
            root.operationRevision++
        }
        function onDataChanged() {
            root.operationRevision++
        }
        function onRowsMoved() {
            root.operationRevision++
        }
        function onRowsInserted() {
            root.operationRevision++
        }
        function onRowsRemoved() {
            root.operationRevision++
        }
    }

    Connections {
        target: root.timelineModel
        function onCountChanged() {
            root.timelineRevision++
        }
        function onModelReset() {
            root.timelineRevision++
        }
        function onDataChanged() {
            root.timelineRevision++
        }
        function onRowsMoved() {
            root.timelineRevision++
        }
        function onRowsInserted() {
            root.timelineRevision++
        }
        function onRowsRemoved() {
            root.timelineRevision++
        }
    }

    Component.onCompleted: root.reloadSnapshot()

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: root.embeddedMode ? 0 : 18
        anchors.rightMargin: root.embeddedMode ? 0 : 34
        anchors.topMargin: root.embeddedMode ? 0 : 18
        anchors.bottomMargin: root.embeddedMode ? 0 : 18
        spacing: 12

        Rectangle {
            objectName: "coordinationHeader"
            Layout.fillWidth: true
            Layout.preferredHeight: 72
            property bool repeatedTitleRemoved: true
            radius: Theme.radiusLarge
            color: "transparent"
            border.width: 0
            border.color: "transparent"
            Accessible.role: Accessible.Pane
            Accessible.name: "Tóm tắt vận hành điều phối"

            RowLayout {
                anchors.fill: parent
                spacing: 10

                Foundation.MetricCell {
                    objectName: "coordinationMetricRunning"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 190
                    Layout.fillHeight: true
                    value: root.kpiText("running", "")
                    label: "đang chạy"
                    delta: root.kpiDelta("running")
                    iconName: "ui/play"
                    tone: Theme.success
                    pulse: (Number(root.coordinationKpis.running) || 0) > 0
                }
                Foundation.MetricCell {
                    objectName: "coordinationMetricSuccess"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 190
                    Layout.fillHeight: true
                    value: root.kpiText("success_rate", "%")
                    label: "thành công"
                    delta: root.kpiDelta("success_rate")
                    iconName: "semantic/check-circle"
                    tone: Theme.success
                }
                Foundation.MetricCell {
                    objectName: "coordinationMetricNeedsAction"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 190
                    Layout.fillHeight: true
                    value: root.kpiText("needs_action", "")
                    label: "cần xử lý"
                    delta: root.kpiDelta("needs_action")
                    iconName: "semantic/alert-triangle"
                    tone: Theme.warning
                    pulse: (Number(root.coordinationKpis.needs_action) || 0) > 0
                }
                Foundation.MetricCell {
                    objectName: "coordinationMetricChannels"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 190
                    Layout.fillHeight: true
                    value: root.kpiText("channels", "")
                    label: "kênh"
                    delta: root.kpiDelta("channels")
                    iconName: "semantic/channels"
                    tone: Theme.accent
                }
            }
        }

        Foundation.AsyncStateView {
            id: asyncState
            objectName: "coordinationAsyncState"
            Layout.fillWidth: true
            Layout.fillHeight: true
            accessibleName: "Dữ liệu vận hành điều phối"
            viewState: root.viewState
            hasData: root.hasProjectionData
            emptyTitle: "Chưa có hoạt động điều phối"
            emptyDescription: "Khi có công việc chuẩn bị nội dung, chỉnh video, đăng bài hoặc chăm sóc kênh, tiến độ sẽ xuất hiện tại đây."
            emptyIconName: "semantic/workflow"
            emptyEyebrow: "HỆ THỐNG ĐANG CHỜ CÔNG VIỆC"
            emptyGuidance: [
                {"title": "Thêm nội dung", "description": "Tạo brief hoặc nhập video nguồn"},
                {"title": "Hoàn thiện video", "description": "Kiểm tra, chỉnh sửa và render trong Studio"},
                {"title": "Lập kế hoạch", "description": "Chọn kênh, nhịp đăng và phê duyệt"}
            ]
            emptyActionText: "Mở kho nội dung"
            emptyActionIconName: "semantic/video"
            emptyActionEnabled: true
            emptyActionReason: ""
            emptySecondaryActionText: "Làm mới"
            emptySecondaryActionIconName: "ui/refresh-cw"
            onEmptyAction: root.plane.navigateEntity(
                "content", "", "", {"source": "coordination_empty"})
            onEmptySecondaryAction: root.requestSnapshot("")
            errorMessage: String(root.snapshotError.message || "Không thể tải snapshot điều phối.")
            requiredPermission: "coordination.read"
            onRetry: root.requestSnapshot("")

            Item {
                id: operationalGrid
                objectName: "coordinationOperationalGrid"
                width: asyncState.width
                height: asyncState.height
                readonly property real gap: 14
                readonly property real inspectorWidth: root.inspectorVisible ? 408 : 0
                readonly property real healthHeight: 114
                readonly property real upperHeight: Math.max(558, height - healthHeight - gap)
                readonly property real leftWidth: Math.max(760, width - inspectorWidth - gap)

                Coordination.CoordinationQueue {
                    x: 0
                    y: 0
                    width: operationalGrid.leftWidth
                    height: operationalGrid.upperHeight
                    operationModel: root.operationModel
                    selectedOperationKey: root.selectedOperationKey
                    channelOptions: root.operationFilters.channels || []
                    stageOptions: root.operationFilters.stages || []
                    sortOptions: root.operationFilters.sorts || []
                    currentChannelId: root.channelFilter
                    currentStage: root.stageFilter
                    currentSort: root.operationSort
                    selectionVersions: root.bulkSelection
                    selectionRevision: root.bulkSelectionRevision
                    selectionCount: root.bulkSelectionCount
                    staleSelectionCount: root.bulkStaleCount
                    bulkActions: root.bulkActions
                    referenceTimestamp: String(
                        root.coordinationSnapshot.generated_at || "")
                    onOperationSelected: function(operationKey) {
                        root.selectOperation(operationKey)
                    }
                    onOperationOpened: function(operationKey) {
                        root.openOperation(operationKey)
                    }
                    onChannelFilterRequested: function(channelId) {
                        root.channelFilter = channelId
                        root.requestSnapshot("")
                    }
                    onStageFilterRequested: function(stage) {
                        root.stageFilter = stage
                        root.requestSnapshot("")
                    }
                    onSortRequested: function(sort) {
                        root.operationSort = sort
                        root.requestSnapshot("")
                    }
                    onOperationSelectionRequested: function(operationKey, versionToken, selected) {
                        root.setOperationSelected(operationKey, versionToken, selected)
                    }
                    onSelectAllRequested: function(selected) {
                        root.selectAllOperations(selected)
                    }
                }

                Coordination.OperationInspector {
                    x: operationalGrid.leftWidth + operationalGrid.gap
                    y: 0
                    width: operationalGrid.inspectorWidth
                    height: operationalGrid.upperHeight
                    visible: root.inspectorVisible
                    operation: root.selectedOperation
                    approvalModel: root.approvalModel
                    commandStore: root.plane.commandStore
                    controlPlaneBridge: root.plane
                    referenceTimestamp: String(
                        root.coordinationSnapshot.generated_at || "")
                    onOpenOperation: function(operationKey) {
                        root.openOperation(operationKey)
                    }
                    onNavigateDeepLink: function(deepLink) {
                        root.applyProjectedDeepLink(deepLink)
                    }
                    onCloseRequested: root.inspectorVisible = false
                }

                Coordination.ChannelHealthStrip {
                    x: 0
                    y: operationalGrid.upperHeight + operationalGrid.gap
                    width: operationalGrid.width
                    height: operationalGrid.healthHeight
                    healthModel: root.healthModel
                    referenceTimestamp: String(
                        root.coordinationSnapshot.generated_at || "")
                    onChannelActivated: function(channelId, healthCode) {
                        root.openChannel(channelId, healthCode)
                    }
                    onAddChannelRequested: root.startChannelOnboarding()
                }
            }
        }
    }
}
