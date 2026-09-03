pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import ".."
import "../foundation" as Foundation
import "reports" as Reports

Item {
    id: root
    objectName: "reportsPage"
    Accessible.role: Accessible.Pane
    Accessible.name: "Báo cáo và hiệu suất"

    // qmllint disable unqualified
    readonly property var plane: controlPlane
    // qmllint enable unqualified
    property var reportSnapshot: ({})
    property var snapshotError: ({})
    property string selectedContentId: ""
    property int selectionRevision: 0
    property int commandRevision: 0

    readonly property var reportData: (root.reportSnapshot || {}).data || ({})
    readonly property var scope: root.reportData.scope || ({})
    readonly property var filterCatalog: root.reportData.filter_catalog || ({})
    readonly property var headerProjection: root.reportData.header || ({})
    readonly property var metricDictionary: root.reportData.metric_dictionary || ({})
    readonly property var kpis: root.reportData.kpis || ({})
    readonly property var trend: root.reportData.trend || ({})
    readonly property var contentPerformance: root.reportData.content_performance || ({})
    readonly property var contentModel: root.plane.snapshotStore.collection("reports", "content")
    readonly property var channelComparison: root.reportData.channel_comparison || ({})
    readonly property var channelModel: root.plane.snapshotStore.collection("reports", "channels")
    readonly property var trendPointModel: root.plane.snapshotStore.collection("reports", "trend_points")
    readonly property var funnel: root.reportData.funnel || ({})
    readonly property var attribution: root.reportData.attribution || ({})
    readonly property var costs: root.reportData.costs || ({})
    readonly property var insights: root.reportData.insights || ({})
    readonly property var exports: root.reportData.exports || ({})
    readonly property var exportItems: root.exports.items || []
    readonly property var exportCreateAction: (root.exports.actions || {}).create || ({})
    readonly property int contentCount: root.contentModel.count
    readonly property bool canRead: root.hasPermission("reports.read")
    readonly property var headerExportAction:
        (root.headerProjection.actions || {}).export || ({})
    readonly property bool canExport: root.hasPermission("reports.export")
        && (root.headerExportAction.available === true
            || root.exportCreateAction.available === true
            || Boolean(root.exportCreateAction.enabled))
        && String(root.headerExportAction.capability
            || root.exportCreateAction.capability || "") === "reports.export.create"
    readonly property string viewState: root.resolveViewState()
    readonly property bool snapshotBusy: {
        const revision = root.commandRevision
        return root.plane.commandStore.isBusy("reports.snapshot", "global", "global")
    }
    readonly property var exportCreateCommandState: {
        const revision = root.commandRevision
        return root.plane.commandStore.state(
            "reports.export.create", "global", "global"
        )
    }
    readonly property bool exportCreateBusy: Boolean(root.exportCreateCommandState.busy)
    readonly property var exportGetCommandState: {
        const revision = root.commandRevision
        if (!root.selectedExportJobId) return ({})
        return root.plane.commandStore.state(
            "reports.export.get", "export_job", root.selectedExportJobId
        )
    }
    readonly property bool exportGetBusy: Boolean(root.exportGetCommandState.busy)
    readonly property var exportDownloadCommandState: {
        const revision = root.commandRevision
        if (!root.selectedExportJobId) return ({})
        return root.plane.commandStore.state(
            "reports.export.download.prepare", "export_job", root.selectedExportJobId
        )
    }
    readonly property bool exportDownloadBusy: Boolean(root.exportDownloadCommandState.busy)
    readonly property bool exportBusy: root.exportCreateBusy || root.exportGetBusy
        || root.exportDownloadBusy
    readonly property var selectedExportJob: root.resolveSelectedExportJob()
    readonly property string selectedExportState: String(root.selectedExportJob.state || "")
    readonly property var selectedExportActions:
        root.selectedExportJob.actions || ({})
    readonly property var selectedExportRefreshAction:
        root.selectedExportActions.refresh || ({})
    readonly property var selectedExportDownloadAction:
        root.selectedExportActions.download_prepare || ({})
    readonly property bool canRefreshExport: root.exportActionMatchesSelection(
        root.selectedExportRefreshAction, "reports.export.get"
    )
    readonly property bool canDownload: root.exportActionMatchesSelection(
        root.selectedExportDownloadAction, "reports.export.download.prepare"
    )
    property string selectedExportJobId: ""
    property string pendingExportIdempotencyKey: ""
    property string pendingExportFormat: ""
    property string exportCommandMessage: ""
    property string pendingInsightId: ""
    property string pendingInsightIdempotencyKey: ""
    readonly property var insightPlanCommandState: {
        const revision = root.commandRevision
        if (!root.pendingInsightId) return ({})
        return root.plane.commandStore.state(
            "reports.insight.plan.create", "insight", root.pendingInsightId
        )
    }
    readonly property bool insightPlanBusy: Boolean(root.insightPlanCommandState.busy)

    function reloadSnapshot() {
        root.reportSnapshot = root.plane.snapshotStore.snapshot("reports")
        root.snapshotError = root.plane.snapshotStore.error("reports")
        root.selectionRevision += 1
        root.reconcileSelection()
        root.reconcileExportSelection()
    }

    function hasPermission(permission) {
        const requested = String(permission || "").trim()
        if (!requested) return false
        const permissions = (root.reportSnapshot || {}).permissions || []
        return permissions.indexOf(requested) >= 0
            || permissions.indexOf("workspace.admin") >= 0
    }

    function hasProjectionData() {
        return root.contentModel.count > 0
            || root.trendPointModel.count > 0
            || root.channelModel.count > 0
    }

    function resolveViewState() {
        const snapshot = root.reportSnapshot || ({})
        const error = root.snapshotError || ({})
        const hasSnapshot = String(snapshot.snapshot_id || "").length > 0
        const errorCode = String(error.code || "").toUpperCase()
        if (!hasSnapshot) {
            if (errorCode === "PERMISSION_DENIED" || errorCode === "FORBIDDEN")
                return "permission"
            return errorCode.length > 0 ? "error" : "loading"
        }
        if (!root.canRead) return "permission"
        if (errorCode === "NETWORK_ERROR" || errorCode === "OFFLINE") return "offline"
        if (errorCode.length > 0) return "error"
        if (!root.hasProjectionData()) return "empty"
        const freshness = String((snapshot.freshness || {}).state || "fresh").toLowerCase()
        if (freshness === "partial" || freshness === "stale") return freshness
        return "content"
    }

    function contentForId(contentId) {
        const identity = String(contentId || "")
        for (let index = 0; index < root.contentModel.count; index++) {
            const item = root.contentModel.get(index) || ({})
            if (String(item.content_id || "") === identity) return item
        }
        return ({})
    }

    function reconcileSelection() {
        if (root.selectedContentId && root.contentForId(root.selectedContentId).content_id)
            return
        root.selectedContentId = ""
    }

    function exportForId(exportJobId) {
        const identity = String(exportJobId || "")
        for (let index = 0; index < root.exportItems.length; index++) {
            const item = root.exportItems[index] || ({})
            if (String(item.id || "") === identity) return item
        }
        return ({})
    }

    function reconcileExportSelection() {
        if (root.selectedExportJobId) {
            const projected = root.exportForId(root.selectedExportJobId)
            const commandJob = ((root.exportGetCommandState.result || {}).export_job || {})
            const createdJob = ((root.exportCreateCommandState.result || {}).export_job || {})
            if (projected.id || String(commandJob.id || "") === root.selectedExportJobId
                    || String(createdJob.id || "") === root.selectedExportJobId)
                return
        }
        root.selectedExportJobId = root.exportItems.length > 0
            ? String((root.exportItems[0] || {}).id || "") : ""
    }

    function resolveSelectedExportJob() {
        const selected = String(root.selectedExportJobId || "")
        if (!selected) return ({})
        const fetched = (root.exportGetCommandState.result || {}).export_job || ({})
        if (String(fetched.id || "") === selected) return fetched
        const created = (root.exportCreateCommandState.result || {}).export_job || ({})
        if (String(created.id || "") === selected) return created
        return root.exportForId(selected)
    }

    function exportActionMatchesSelection(action, capability): bool {
        const descriptor = action || ({})
        const input = descriptor.input || ({})
        return descriptor.available === true
            && String(descriptor.capability || "") === String(capability || "")
            && String(input.export_job_id || "") === root.selectedExportJobId
    }

    function safeIdPart(value: string): string {
        return String(value || "unknown").replace(/[^A-Za-z0-9._:@\/-]+/g, "-")
            .replace(/^-+|-+$/g, "") || "unknown"
    }

    function openExportDialog(): bool {
        root.reconcileExportSelection()
        exportDialog.open()
        return true
    }

    function selectExportJob(exportJobId: string): bool {
        const identity = String(exportJobId || "").trim()
        if (!identity) return false
        root.selectedExportJobId = identity
        root.exportCommandMessage = ""
        root.commandRevision += 1
        return true
    }

    function requestExport(formatOption): bool {
        const option = formatOption || ({})
        const optionAction = option.action || ({})
        const normalized = String((optionAction.input || {}).format || "").trim()
        if (!root.canExport || root.exportCreateBusy
                || optionAction.available !== true
                || String(optionAction.capability || "") !== "reports.export.create"
                || !normalized)
            return false
        if (!root.pendingExportIdempotencyKey
                || root.pendingExportFormat !== normalized) {
            root.pendingExportFormat = normalized
            root.pendingExportIdempotencyKey = "ui.reports.export:"
                + root.safeIdPart((root.reportSnapshot || {}).snapshot_id)
                + ":" + normalized + ":" + String(Date.now())
        }
        root.exportCommandMessage = "Đang tạo export job từ snapshot hiện tại…"
        const payload = Object.assign({}, root.headerExportAction.input || ({}))
        Object.assign(payload, optionAction.input || ({}))
        payload.idempotency_key = root.pendingExportIdempotencyKey
        root.plane.callTool("reports.export.create", payload)
        return true
    }

    function refreshExportJob(action): bool {
        const descriptor = action || ({})
        const input = descriptor.input || ({})
        const identity = String(input.export_job_id || "").trim()
        if (!root.exportActionMatchesSelection(
                descriptor, "reports.export.get"
            ) || root.plane.commandStore.isBusy(
                "reports.export.get", "export_job", identity))
            return false
        root.exportCommandMessage = "Đang kiểm tra trạng thái export job…"
        root.plane.callTool("reports.export.get", Object.assign({}, input))
        return true
    }

    function requestExportDownload(action): bool {
        const descriptor = action || ({})
        const input = descriptor.input || ({})
        if (!root.exportActionMatchesSelection(
                descriptor, "reports.export.download.prepare"
            ) || root.exportDownloadBusy)
            return false
        root.exportCommandMessage = "Đang cấp liên kết tải xuống ngắn hạn…"
        root.plane.callTool(
            "reports.export.download.prepare",
            Object.assign({}, input)
        )
        return true
    }

    function requestInsightPlan(action) {
        const descriptor = action || ({})
        const input = descriptor.input || ({})
        const insightId = String(input.insight_id || "").trim()
        if (descriptor.available !== true
                || String(descriptor.capability || "")
                    !== "reports.insight.plan.create"
                || String(descriptor.kind || "") !== "mutation"
                || !insightId || root.insightPlanBusy) return false
        if (root.pendingInsightId !== insightId
                || !root.pendingInsightIdempotencyKey) {
            root.pendingInsightId = insightId
            root.pendingInsightIdempotencyKey = "ui.reports.insight-plan:"
                + root.safeIdPart(insightId) + ":" + String(Date.now())
        }
        const payload = Object.assign({}, input)
        payload.idempotency_key = root.pendingInsightIdempotencyKey
        root.plane.callTool("reports.insight.plan.create", payload)
        return true
    }

    function syncExportCommand(capability, entityType, entityId) {
        if (capability === "reports.export.create"
                && entityType === "global" && entityId === "global") {
            const state = root.plane.commandStore.state(capability, entityType, entityId)
            if (state.state === "succeeded") {
                const job = (state.result || {}).export_job || ({})
                if (job.id) root.selectedExportJobId = String(job.id)
                root.exportCommandMessage = "Export job đã được tạo; artifact sẽ xuất hiện khi worker hoàn tất."
                root.pendingExportIdempotencyKey = ""
                root.pendingExportFormat = ""
            } else if (state.state === "failed") {
                root.exportCommandMessage = String(state.message || "Không thể tạo export job. Có thể thử lại cùng idempotency key.")
            }
            return
        }
        if (capability === "reports.export.get"
                && entityType === "export_job"
                && entityId === root.selectedExportJobId) {
            const getState = root.plane.commandStore.state(capability, entityType, entityId)
            if (getState.state === "succeeded")
                root.exportCommandMessage = "Đã đồng bộ trạng thái export job từ server."
            else if (getState.state === "failed")
                root.exportCommandMessage = String(getState.message || "Không thể đọc export job.")
            return
        }
        if (capability === "reports.export.download.prepare"
                && entityType === "export_job"
                && entityId === root.selectedExportJobId) {
            const downloadState = root.plane.commandStore.state(
                capability, entityType, entityId
            )
            if (downloadState.state === "succeeded") {
                const url = String((downloadState.result || {}).download_url || "")
                root.exportCommandMessage = root.plane.openReportDownloadUrl(url)
                    ? "Đã mở tải báo cáo bằng liên kết ngắn hạn."
                    : "Liên kết tải báo cáo bị từ chối hoặc không thể mở."
            } else if (downloadState.state === "failed") {
                root.exportCommandMessage = String(
                    downloadState.message || "Không thể chuẩn bị tải báo cáo."
                )
            }
        }
    }

    function syncInsightCommand(capability, entityType, entityId) {
        if (capability !== "reports.insight.plan.create"
                || entityType !== "insight"
                || entityId !== root.pendingInsightId) return
        const state = root.plane.commandStore.state(capability, entityType, entityId)
        if (state.state !== "succeeded" && state.state !== "failed") return
        const ok = state.state === "succeeded"
        const data = state.result || ({})
        if (ok && String((data.insight || {}).id || "") !== root.pendingInsightId)
            return
        insightPanel.finishPlanCommand(ok, String(state.message || ""), data)
        if (ok) {
            root.pendingInsightId = ""
            root.pendingInsightIdempotencyKey = ""
        }
    }

    function followDeepLink(link) {
        const target = link || ({})
        const entity = target.entity || ({})
        if (!target.route || !entity.type || !entity.id) return false
        root.plane.navigateEntity(
            String(target.route), String(entity.type), String(entity.id),
            target.context || ({})
        )
        return true
    }

    function selectContent(contentId, link) {
        const identity = String(contentId || "")
        if (!root.contentForId(identity).content_id) return false
        root.selectedContentId = identity
        root.selectionRevision += 1
        return root.followDeepLink(link)
    }

    function strictQuery() {
        return Object.assign({}, reportsHeader.composeDraftQuery() || ({}))
    }

    function requestSnapshotQuery(query) {
        if (!root.canRead || root.snapshotBusy || !query) return false
        root.plane.callTool("reports.snapshot", Object.assign({}, query))
        return true
    }

    function executeSnapshotAction(action) {
        const descriptor = action || ({})
        if (descriptor.available !== true
                || String(descriptor.capability || "") !== "reports.snapshot"
                || String(descriptor.kind || "") !== "snapshot") return false
        return root.requestSnapshotQuery(descriptor.input || ({}))
    }

    function applyFilters() {
        return root.requestSnapshotQuery(root.strictQuery())
    }

    function applyFilterQuery(query) {
        return root.requestSnapshotQuery(query)
    }

    function retrySnapshot() {
        const snapshot = root.reportSnapshot || ({})
        if (String(snapshot.snapshot_id || "") && root.canRead)
            return root.applyFilters()
        if (!root.plane || !root.plane.refreshSnapshotTool) return false
        return root.plane.refreshSnapshotTool("reports.snapshot")
    }

    Component.onCompleted: root.reloadSnapshot()

    Connections {
        target: root.plane.snapshotStore
        function onChanged(route) {
            if (route === "reports") root.reloadSnapshot()
        }
    }
    Connections {
        target: root.plane.commandStore
        function onChanged(capability, entityType, entityId) {
            root.commandRevision += 1
            root.syncExportCommand(capability, entityType, entityId)
            root.syncInsightCommand(capability, entityType, entityId)
        }
    }

    Reports.ExportDialog {
        id: exportDialog
        x: Math.max(0, (root.width - width) / 2)
        y: Math.max(0, (root.height - height) / 2)
        canCreate: root.canExport
        canRefresh: root.canRefreshExport
        createBusy: root.exportCreateBusy
        getBusy: root.exportGetBusy
        canDownload: root.canDownload
        downloadBusy: root.exportDownloadBusy
        jobs: root.exportItems
        formatOptions: root.exports.format_options || []
        selectedJobId: root.selectedExportJobId
        selectedJob: root.selectedExportJob
        refreshAction: root.selectedExportRefreshAction
        downloadAction: root.selectedExportDownloadAction
        commandMessage: root.exportCommandMessage
        onCreateRequested: function(option) { root.requestExport(option) }
        onRefreshRequested: function(action) { root.refreshExportJob(action) }
        onDownloadRequested: function(action) { root.requestExportDownload(action) }
        onSelectRequested: function(exportJobId) { root.selectExportJob(exportJobId) }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 9

        Reports.ReportsHeader {
            id: reportsHeader
            Layout.fillWidth: true
            Layout.preferredHeight: 72
            scope: root.scope
            snapshotId: String((root.reportSnapshot || {}).snapshot_id || "")
            filterCatalog: root.filterCatalog
            headerProjection: root.headerProjection
            canRead: root.canRead
            canExport: root.canExport
            busy: root.snapshotBusy
            exportBusy: root.exportBusy
            onApplyRequested: function(query) { root.applyFilterQuery(query) }
            onExportRequested: root.openExportDialog()
        }

        Foundation.AsyncStateView {
            id: reportsStateView
            objectName: "reportsAsyncState"
            Layout.fillWidth: true
            Layout.fillHeight: true
            viewState: root.viewState
            hasData: root.hasProjectionData()
            accessibleName: "Nội dung báo cáo có nguồn"
            emptyTitle: "Chưa có dữ liệu báo cáo"
            emptyDescription: "Chưa có nội dung đã phát hành hoặc số liệu hợp lệ trong phạm vi này."
            emptyIconName: "semantic/bar-chart"
            emptyEyebrow: "BÁO CÁO ĐANG CHỜ DỮ LIỆU"
            emptyGuidance: [
                {"title": "Tạo nội dung", "description": "Có video và mục tiêu cần theo dõi"},
                {"title": "Phân phối", "description": "Đăng lên kênh bằng kế hoạch đã duyệt"},
                {"title": "Thu thập số liệu", "description": "Báo cáo xuất hiện khi có số liệu đã xác minh"}
            ]
            emptyActionText: "Mở kho nội dung"
            emptyActionIconName: "semantic/video"
            emptyActionEnabled: true
            emptyActionReason: ""
            emptySecondaryActionText: "Làm mới"
            emptySecondaryActionIconName: "ui/refresh-cw"
            emptySecondaryActionEnabled: !root.snapshotBusy
            emptySecondaryActionReason: emptySecondaryActionEnabled ? "" : "Đang tải báo cáo"
            onEmptyAction: root.plane.navigateEntity(
                "content", "", "", {"source": "reports_empty"})
            onEmptySecondaryAction: root.retrySnapshot()
            errorMessage: String((root.snapshotError || {}).message || "Không thể tải báo cáo.")
            requiredPermission: "reports.read"
            freshnessBannerEnabled: false
            onRetry: root.retrySnapshot()

            ColumnLayout {
                anchors.fill: parent
                spacing: 9

                Rectangle {
                    id: sourceStatusBanner
                    objectName: "reportsSourceStatusBanner"
                    visible: reportsStateView.showFreshnessBanner
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? 36 : 0
                    radius: Theme.radiusMedium
                    color: Qt.rgba(
                        (root.viewState === "offline" || root.viewState === "error"
                            ? Theme.danger : Theme.warning).r,
                        (root.viewState === "offline" || root.viewState === "error"
                            ? Theme.danger : Theme.warning).g,
                        (root.viewState === "offline" || root.viewState === "error"
                            ? Theme.danger : Theme.warning).b,
                        0.10
                    )
                    border.width: 1
                    border.color: root.viewState === "offline" || root.viewState === "error"
                        ? Theme.danger : Theme.warning
                    Accessible.role: Accessible.AlertMessage
                    Accessible.name: sourceStatusText.text
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 8
                        spacing: 8
                        UiIcon {
                            name: root.viewState === "offline"
                                ? "semantic/alert-circle" : "semantic/info"
                            tone: root.viewState === "offline" || root.viewState === "error"
                                ? Theme.danger : Theme.warning
                            iconSize: 16
                        }
                        Text {
                            id: sourceStatusText
                            Layout.fillWidth: true
                            text: root.viewState === "offline"
                                ? "Mất kết nối · đang hiển thị số liệu gần nhất"
                                : root.viewState === "error"
                                    ? "Lần làm mới gần nhất thất bại · số liệu cũ vẫn được giữ"
                                    : root.viewState === "stale"
                                        ? "Số liệu đã cũ · nên làm mới trước khi ra quyết định"
                                        : "Một phần nguồn chưa sẵn sàng · các chỉ số thiếu được đánh dấu rõ"
                            color: root.viewState === "offline" || root.viewState === "error"
                                ? Theme.danger : Theme.warning
                            font.pixelSize: Theme.fontMetadata
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        AppButton {
                            objectName: "reportSourceRetryButton"
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 28
                            text: root.snapshotBusy ? "Đang tải…" : "Làm mới"
                            leadingIcon: "ui/refresh-cw"
                            subtle: true
                            enabled: root.canRead && !root.snapshotBusy
                            availabilityReason: enabled ? "" : "Snapshot báo cáo đang tải"
                            onClicked: root.retrySnapshot()
                        }
                    }
                }

                Reports.KpiStrip {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 128
                    kpis: root.kpis
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 410
                    spacing: 9
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 9
                        Reports.TrendPanel {
                            id: trendPanel
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 210
                            Layout.preferredHeight: 216
                            trend: root.trend
                            pointModel: root.trendPointModel
                            scope: root.scope
                            snapshotId: String(
                                (root.reportSnapshot || {}).snapshot_id || "")
                            filterCatalog: root.filterCatalog
                            onSnapshotRequested: function(action) {
                                root.executeSnapshotAction(action)
                            }
                            onDeepLinkRequested: function(link) { root.followDeepLink(link) }
                        }
                        Reports.PerformanceTable {
                            id: performanceTable
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 230
                            Layout.preferredHeight: 244
                            projection: root.contentPerformance
                            snapshotId: String(
                                (root.reportSnapshot || {}).snapshot_id || "")
                            filterCatalog: root.filterCatalog
                            controlPlaneBridge: root.plane
                            contentModel: root.contentModel
                            selectedContentId: root.selectedContentId
                            initialLimit: root.scope.limit
                            canExport: root.canExport
                            exportBusy: root.exportBusy
                            onSnapshotRequested: function(action) {
                                root.executeSnapshotAction(action)
                            }
                            onExportRequested: root.openExportDialog()
                            onContentRequested: function(contentId, link) {
                                root.selectContent(contentId, link)
                            }
                        }
                    }
                    Reports.InsightPanel {
                        id: insightPanel
                        Layout.minimumWidth: 480
                        Layout.preferredWidth: 520
                        Layout.fillHeight: true
                        scope: root.scope
                        insights: root.insights
                        coverage: root.contentPerformance.coverage || ({})
                        planBusy: root.insightPlanBusy
                        onPlanRequested: function(action) {
                            root.requestInsightPlan(action)
                        }
                        onDeepLinkRequested: function(link) {
                            root.followDeepLink(link)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 230
                    Layout.preferredHeight: 250
                    Layout.maximumHeight: 250
                    spacing: 9
                    Reports.ChannelComparison {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 560
                        Layout.fillHeight: true
                        projection: root.channelComparison
                        channelModel: root.channelModel
                        onChannelRequested: function(link) { root.followDeepLink(link) }
                    }
                    Reports.FunnelPanel {
                        Layout.minimumWidth: 410
                        Layout.preferredWidth: 430
                        Layout.fillHeight: true
                        funnel: root.funnel
                    }
                    ColumnLayout {
                        Layout.minimumWidth: 550
                        Layout.preferredWidth: 580
                        Layout.fillHeight: true
                        spacing: 9
                        Reports.AttributionPanel {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            attribution: root.attribution
                        }
                        Reports.CostPanel {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            costs: root.costs
                        }
                    }
                }
            }
        }
    }
}
