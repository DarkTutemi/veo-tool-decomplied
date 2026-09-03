pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../foundation" as Foundation
import "channels" as Channels

Item {
    id: root
    objectName: "channelsPage"
    Accessible.name: "Kênh và Browser"
    Accessible.role: Accessible.Pane

    property bool embeddedMode: false

    // qmllint disable unqualified
    readonly property var plane: controlPlane
    // qmllint enable unqualified
    property var channelsSnapshot: ({})
    property var snapshotError: ({})
    property string selectedProfileId: ""
    property string inspectorProfileId: ""
    property bool inspectorDismissed: false
    property var selectedProfileIds: []
    property int selectedSection: 0
    property int selectionRevision: 0
    property int commandRevision: 0
    property string pendingBatchId: ""
    property string pendingBatchOperation: ""
    property string pendingBatchPreviewCapability: "browser.batch.preview"
    property string pendingBatchExecuteCapability: "browser.batch.execute"
    property int pendingBatchCount: 0
    property bool bulkMenuVisible: false
    property string pendingImportId: ""
    property int pendingImportValid: 0
    property int pendingImportInvalid: 0
    property int importPreviewRevision: 0
    readonly property bool createBusy: root.plane.commandStore.isBusy(
        "browser.profile.create", "global", "global")
    readonly property bool importPreviewBusy: root.plane.commandStore.isBusy(
        "browser.import.preview", "global", "global")

    readonly property var projectionData: (root.channelsSnapshot || {}).data || ({})
    readonly property var counts: root.projectionData.counts || ({})
    readonly property var views: root.projectionData.views || ({})
    readonly property var profiles: root.plane.snapshotStore.collection("channels", "profiles")
    readonly property var snapshotSelectedProfile: root.projectionData.selectedProfile || ({})
    readonly property var platformHealth: root.plane.snapshotStore.collection(
        "channels", "platform_health")
    readonly property var accounts: root.plane.snapshotStore.collection(
        "channels", "accounts")
    readonly property var proxies: root.plane.snapshotStore.collection(
        "channels", "proxies")
    readonly property var templates: root.plane.snapshotStore.collection(
        "channels", "templates")
    readonly property var storageVaults: root.plane.snapshotStore.collection(
        "channels", "storage_vaults")
    readonly property var sections: root.projectionData.sections || ({})
    readonly property var currentFilter: root.projectionData.filter || ({})
    readonly property var snapshotPage: (root.channelsSnapshot || {}).page || ({})
    readonly property int profileCount: root.profiles.count
    readonly property int selectedBatchCount: root.selectedProfileIds.length
    readonly property bool batchConfirmationReady: root.pendingBatchId.length > 0
    readonly property var selectedProfile: {
        const revision = root.selectionRevision
        return root.profileForId(root.inspectorProfileId)
    }
    readonly property bool canRead: root.hasPermission("browser.read")
    readonly property bool canWrite: root.hasPermission("browser.write")
    readonly property string viewState: root.resolveViewState()

    function reloadSnapshot() {
        root.channelsSnapshot = root.plane.snapshotStore.snapshot("channels")
        root.snapshotError = root.plane.snapshotStore.error("channels")
        root.selectionRevision += 1
        root.reconcileSelection()
        root.reconcileBatchSelection()
    }

    function hasPermission(permission) {
        const requested = String(permission || "").trim()
        if (!requested) return false
        const permissions = (root.channelsSnapshot || {}).permissions || []
        return permissions.indexOf(requested) >= 0
            || permissions.indexOf("workspace.admin") >= 0
    }

    function hasProjectionData() {
        return root.profiles.count > 0
            || Object.keys(root.snapshotSelectedProfile).length > 0
    }

    function resolveViewState() {
        const snapshot = root.channelsSnapshot || ({})
        const error = root.snapshotError || ({})
        const hasSnapshot = String(snapshot.snapshot_id || "").length > 0
        const errorCode = String(error.code || "").toUpperCase()
        if (!hasSnapshot) {
            if (errorCode === "PERMISSION_DENIED" || errorCode === "FORBIDDEN")
                return "permission"
            return errorCode.length > 0 ? "error" : "loading"
        }
        if (!root.canRead) return "permission"
        if (errorCode === "NETWORK_ERROR" || errorCode === "OFFLINE")
            return "offline"
        if (errorCode.length > 0) return "error"
        if (!root.hasProjectionData()) return "empty"
        const freshness = String((snapshot.freshness || {}).state || "fresh").toLowerCase()
        if (freshness === "partial" || freshness === "stale") return freshness
        return "content"
    }

    function profileForId(profileId) {
        const identity = String(profileId || "")
        for (let index = 0; index < root.profiles.count; index++) {
            const profile = root.profiles.get(index)
            if (String(profile.profileId || "") === identity) return profile
        }
        if (String(root.snapshotSelectedProfile.profileId || "") === identity)
            return root.snapshotSelectedProfile
        return ({})
    }

    function sectionIndex(tab) {
        const normalized = String(tab || "browser").toLowerCase()
        if (normalized === "account") return 1
        if (normalized === "proxy") return 2
        if (normalized === "template") return 3
        if (["storage", "storage_vault"].indexOf(normalized) >= 0) return 4
        return 0
    }

    function reconcileSelection() {
        const selection = root.plane.entitySelection.current || ({})
        const entity = selection.entity || ({})
        const context = selection.context || ({})
        const selectionType = String(entity.type || "")
        if (String(selection.route || "") === "channels")
            root.selectedSection = root.sectionIndex(context.tab)
        if (String(selection.route || "") === "channels"
                && (selectionType === "browser_profile" || selectionType === "channel")) {
            const linkedId = selectionType === "channel"
                ? String(context.browser_profile_id || "")
                : String(entity.id || "")
            if (linkedId) {
                root.inspectorDismissed = false
                root.selectedProfileId = linkedId
                if (!browserInspector.pinned)
                    root.inspectorProfileId = linkedId
                if (!root.profileForId(linkedId).profileId)
                    root.requestSnapshot({"selected_profile_id": linkedId})
                return
            }
        }
        if (root.inspectorDismissed) {
            root.selectedProfileId = ""
            root.inspectorProfileId = ""
            return
        }
        if (root.selectedProfileId && root.profileForId(root.selectedProfileId).profileId) {
            if (!browserInspector.pinned
                    && !root.profileForId(root.inspectorProfileId).profileId)
                root.inspectorProfileId = root.selectedProfileId
            return
        }
        const snapshotId = String(root.snapshotSelectedProfile.profileId || "")
        if (snapshotId && root.profileForId(snapshotId).profileId) {
            root.selectedProfileId = snapshotId
            if (!browserInspector.pinned) root.inspectorProfileId = snapshotId
            return
        }
        root.selectedProfileId = root.profiles.count > 0
            ? String(root.profiles.get(0).profileId || "") : ""
        if (!browserInspector.pinned) root.inspectorProfileId = root.selectedProfileId
    }

    function reconcileBatchSelection() {
        const available = ({})
        for (let index = 0; index < root.profiles.count; index++)
            available[String(root.profiles.get(index).profileId || "")] = true
        const retained = []
        for (let selectedIndex = 0; selectedIndex < root.selectedProfileIds.length; selectedIndex++) {
            const identity = String(root.selectedProfileIds[selectedIndex] || "")
            if (available[identity]) retained.push(identity)
        }
        root.selectedProfileIds = retained
    }

    function selectProfile(profileId) {
        const identity = String(profileId || "")
        if (!root.profileForId(identity).profileId) return false
        root.inspectorDismissed = false
        root.selectedProfileId = identity
        if (!browserInspector.pinned) root.inspectorProfileId = identity
        root.selectionRevision += 1
        root.plane.navigateEntity("channels", "browser_profile", identity, {
            "tab": "browser",
            "subview": "overview",
            "source": "channels"
        })
        return true
    }

    function setProfileChecked(profileId, checked) {
        const identity = String(profileId || "")
        if (!identity) return false
        const next = root.selectedProfileIds.slice()
        const position = next.indexOf(identity)
        if (checked && position < 0) next.push(identity)
        else if (!checked && position >= 0) next.splice(position, 1)
        root.selectedProfileIds = next
        return true
    }

    function selectVisibleProfiles(checked) {
        if (!checked) {
            root.selectedProfileIds = []
            return true
        }
        const identities = []
        for (let index = 0; index < root.profiles.count; index++) {
            const identity = String(root.profiles.get(index).profileId || "")
            if (identity) identities.push(identity)
        }
        root.selectedProfileIds = identities
        return true
    }

    function requestSnapshot(query) {
        if (!root.canRead) return false
        root.plane.callTool("browser.inventory.snapshot", query || ({}))
        return true
    }

    function launchProfile(targetProfileId) {
        const profileId = String(targetProfileId || "")
        if (!root.canWrite || !profileId) return false
        root.plane.callTool("browser.profile.launch", {
            "profile_id": profileId,
            "headless": false,
            "check_updates": false,
            "holder_type": "operator",
            "holder_id": root.plane.appContext
                ? String(root.plane.appContext.operatorId || "operator_ui")
                : "operator_ui"
        })
        return true
    }

    function launchSelectedProfile() {
        return root.launchProfile(root.selectedProfile.profileId)
    }

    function closeProfile(targetProfileId) {
        const profileId = String(targetProfileId || "")
        if (!root.canWrite || !profileId) return false
        root.plane.callTool("browser.profile.close", {"profile_id": profileId})
        return true
    }

    function closeSelectedProfile() {
        return root.closeProfile(root.selectedProfile.profileId)
    }

    function rescanProfile(targetProfileId) {
        const profile = root.profileForId(targetProfileId)
        const profileId = String(profile.profileId || "")
        const platform = String(((profile || {}).platformSummary || {}).primary || "")
        if (!root.canWrite || !profileId
                || ["youtube", "facebook", "tiktok"].indexOf(platform) < 0)
            return false
        root.plane.callTool("browser.profile.scan", {
            "browser_profile_id": profileId,
            "platform": platform
        })
        return true
    }

    function rescanSelectedProfile() {
        return root.rescanProfile(root.selectedProfile.profileId)
    }

    function checkProfileProxy(targetProfileId) {
        const profile = root.profileForId(targetProfileId)
        const proxyId = String(((profile || {}).proxySummary || {}).proxyId || "")
        if (!root.canWrite || !proxyId) return false
        root.plane.callTool("proxy.health_check", {"proxy_id": proxyId})
        return true
    }

    function checkSelectedProxy() {
        return root.checkProfileProxy(root.selectedProfile.profileId)
    }

    function handleProfileAction(profileId, operation) {
        const normalized = String(operation || "")
        if (normalized === "launch") return root.launchProfile(profileId)
        if (normalized === "close") return root.closeProfile(profileId)
        if (normalized === "scan") return root.rescanProfile(profileId)
        if (normalized === "proxy.check") return root.checkProfileProxy(profileId)
        return false
    }

    function requestBatchPreview(operation) {
        const normalized = String(operation || "")
        if (!root.canWrite || root.selectedProfileIds.length === 0
                || ["close", "cache.clean", "launch", "proxy.assign",
                    "runtime_policy.patch", "health.check"].indexOf(normalized) < 0)
            return false
        root.pendingBatchOperation = normalized
        root.pendingBatchId = ""
        root.pendingBatchCount = 0
        root.pendingBatchPreviewCapability = normalized === "proxy.assign"
            ? "browser.proxy.assign.preview" : "browser.batch.preview"
        root.pendingBatchExecuteCapability = normalized === "proxy.assign"
            ? "browser.proxy.assign.execute"
            : normalized === "launch"
                ? "browser.launch.batch.execute" : "browser.batch.execute"
        let params = ({})
        if (normalized === "launch")
            params = {"headless": false, "check_updates": false}
        else if (normalized === "proxy.assign")
            params = {"strategy": "round_robin", "require_live": true}
        else if (normalized === "runtime_policy.patch")
            params = {"changes": {"mute_audio": true}}
        const payload = {
            "operation": normalized,
            "profile_ids": root.selectedProfileIds.slice(),
            "params": params,
            "idempotency_key": "qml-browser-" + normalized.replace(/\./g, "-")
                + "-" + String(root.channelsSnapshot.snapshot_id || "snapshot")
                + "-" + root.selectedProfileIds.slice().sort().join("_")
        }
        if (normalized === "proxy.assign")
            delete payload.operation
        if (normalized === "proxy.assign")
            root.plane.callTool("browser.proxy.assign.preview", payload)
        else
            root.plane.callTool("browser.batch.preview", payload)
        return true
    }

    function consumeBatchPreview() {
        const state = root.plane.commandStore.state(
            root.pendingBatchPreviewCapability, "global", "global") || ({})
        if (!state.ok) return false
        const result = state.result || ({})
        const batch = result.batch || result
        const batchId = String(batch.id || batch.batch_id || "")
        if (!batchId || batchId === root.pendingBatchId) return false
        root.pendingBatchId = batchId
        root.pendingBatchCount = Number(batch.total || root.selectedProfileIds.length)
        batchConfirm.open()
        return true
    }

    function confirmBatchExecution() {
        if (!root.pendingBatchId) return false
        if (root.pendingBatchOperation === "proxy.assign")
            root.plane.callTool(
                "browser.proxy.assign.execute", {"batch_id": root.pendingBatchId})
        else if (root.pendingBatchOperation === "launch")
            root.plane.callTool(
                "browser.launch.batch.execute", {"batch_id": root.pendingBatchId})
        else
            root.plane.callTool(
                "browser.batch.execute", {"batch_id": root.pendingBatchId})
        return true
    }

    function requestImportPreview(draft) {
        if (!root.canWrite || root.importPreviewBusy) return false
        const source = draft || ({})
        const csvContent = String(source.csv_content || "").trim()
        if (!csvContent) return false
        root.pendingImportId = ""
        root.pendingImportValid = 0
        root.pendingImportInvalid = 0
        root.importPreviewRevision += 1
        root.plane.callTool("browser.import.preview", {
            "csv_content": csvContent,
            "default_platform": String(source.default_platform || "tiktok"),
            "default_os": String(source.default_os || "windows"),
            "idempotency_key": "qml-browser-import-"
                + String(root.channelsSnapshot.snapshot_id || "snapshot")
                + "-" + String(root.importPreviewRevision)
        })
        return true
    }

    function consumeImportPreview() {
        const state = root.plane.commandStore.state(
            "browser.import.preview", "global", "global") || ({})
        if (!state.ok) return false
        const result = state.result || ({})
        const frozen = result["import"] || result
        const importId = String(frozen.id || frozen.import_id || "")
        if (!importId || importId === root.pendingImportId) return false
        root.pendingImportId = importId
        root.pendingImportValid = Number(frozen.valid || 0)
        root.pendingImportInvalid = Number(frozen.invalid || 0)
        importConfirm.open()
        return true
    }

    function confirmImportExecution() {
        if (!root.pendingImportId || !root.canWrite) return false
        root.plane.callTool(
            "browser.import.execute", {"import_id": root.pendingImportId})
        return true
    }

    function followDeepLink(link) {
        const target = link || ({})
        const entity = target.entity || ({})
        if (!target.route) return false
        root.plane.navigateEntity(
            String(target.route),
            String(entity.type || ""),
            String(entity.id || ""),
            target.context || ({})
        )
        return true
    }

    Component.onCompleted: root.reloadSnapshot()

    Connections {
        target: root.plane.snapshotStore
        function onChanged(route) {
            if (route === "channels") root.reloadSnapshot()
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
            if (capability === "browser.profile.create"
                    && entityType === "global" && entityId === "global") {
                const state = root.plane.commandStore.state(
                    capability, entityType, entityId)
                if (state && state.state === "succeeded") browserCreateDialog.close()
            }
            if (capability === root.pendingBatchPreviewCapability
                    && entityType === "global" && entityId === "global")
                root.consumeBatchPreview()
            if (capability === "browser.import.preview"
                    && entityType === "global" && entityId === "global")
                root.consumeImportPreview()
            if (capability === "browser.import.execute"
                    && entityType === "global" && entityId === "global") {
                const state = root.plane.commandStore.state(
                    capability, entityType, entityId) || ({})
                if (state.state === "succeeded") {
                    browserCreateDialog.close()
                    root.requestSnapshot({"limit": 10})
                }
            }
        }
    }

    Channels.BrowserCreateDialog {
        id: browserCreateDialog
        canCreate: root.canWrite
        busy: root.createBusy || root.importPreviewBusy
        onCreateRequested: function(payload) {
            root.plane.callTool("browser.profile.create", payload)
        }
        onImportPreviewRequested: function(payload) {
            root.requestImportPreview(payload)
        }
    }

    Foundation.ConfirmDialog {
        id: batchConfirm
        objectName: "browserBatchConfirmDialog"
        title: "Xác nhận thao tác hàng loạt"
        message: "Server đã đóng băng preview cho " + String(root.pendingBatchCount)
            + " browser. Chỉ thực thi đúng batch đã duyệt?"
        confirmText: "Thực thi"
        destructive: root.pendingBatchOperation === "close"
        onAccepted: root.confirmBatchExecution()
    }

    Foundation.ConfirmDialog {
        id: importConfirm
        objectName: "browserImportConfirmDialog"
        title: "Xác nhận nhập Browser"
        message: "Backend đã đóng băng " + String(root.pendingImportValid)
            + " dòng hợp lệ; " + String(root.pendingImportInvalid)
            + " dòng lỗi sẽ không được tạo. Thực thi đúng import ID này?"
        confirmText: "Nhập Browser"
        onAccepted: root.confirmImportExecution()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.embeddedMode ? 0 : 14
        spacing: root.embeddedMode ? 0 : 10

        Channels.BrowserHeader {
            visible: !root.embeddedMode
            Layout.fillWidth: true
            Layout.preferredHeight: root.embeddedMode ? 0 : 88
            counts: root.counts
            canWrite: root.canWrite
            selectionCount: root.selectedBatchCount
            onAddRequested: browserCreateDialog.open()
            onBulkRequested: root.bulkMenuVisible = !root.bulkMenuVisible
            onBulkMenuRequested: root.bulkMenuVisible = !root.bulkMenuVisible
        }

        Foundation.AsyncStateView {
            objectName: "browserAsyncState"
            Layout.fillWidth: true
            Layout.fillHeight: true
            viewState: root.viewState
            hasData: root.hasProjectionData()
            accessibleName: "Nội dung Kênh và Browser"
            emptyTitle: "Chưa có browser"
            emptyDescription: "Bạn chưa thêm Browser nào. Tạo Browser đầu tiên để đăng nhập và quản lý kênh."
            emptyIconName: "semantic/channels"
            emptyEyebrow: "KẾT NỐI KÊNH ĐẦU TIÊN"
            emptyGuidance: [
                {"title": "Chuẩn bị Browser", "description": "Chọn cấu hình, proxy và vùng chạy"},
                {"title": "Đăng nhập kênh", "description": "Mở Browser và đăng nhập tài khoản nền tảng"},
                {"title": "Kiểm tra kết nối", "description": "Xác nhận phiên đăng nhập và tình trạng kênh"}
            ]
            emptyActionText: "Thêm Browser"
            emptyActionIconName: "ui/plus"
            emptyActionEnabled: root.canWrite && !root.createBusy
            emptyActionReason: !root.canWrite ? "Bạn không có quyền thêm Browser"
                : root.createBusy ? "Đang tạo Browser" : ""
            emptySecondaryActionText: "Làm mới"
            emptySecondaryActionIconName: "ui/refresh-cw"
            onEmptyAction: browserCreateDialog.open()
            onEmptySecondaryAction: root.requestSnapshot({"limit": 10})
            errorMessage: String((root.snapshotError || {}).message || "Không thể tải inventory browser.")
            requiredPermission: "browser.read"
            onRetry: root.requestSnapshot({
                "limit": root.currentFilter.limit !== undefined
                    && root.currentFilter.limit !== null
                    ? root.currentFilter.limit : 10
            })

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Channels.BrowserInventory {
                        id: browserInventory
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: browserInspector.visible
                            ? browserInspector.left : parent.right
                        anchors.rightMargin: browserInspector.visible ? 10 : 0
                        profiles: root.profiles
                        views: root.views
                        accountItems: root.accounts
                        proxyItems: root.proxies
                        templateItems: root.templates
                        storageItems: root.storageVaults
                        sectionMetadata: root.sections
                        filter: root.currentFilter
                        page: root.snapshotPage
                        selectedProfileId: root.selectedProfileId
                        selectedProfileIds: root.selectedProfileIds
                        selectedSection: root.selectedSection
                        canWrite: root.canWrite
                        onSectionSelected: function(index) { root.selectedSection = index }
                        onProfileSelected: function(profileId) { root.selectProfile(profileId) }
                        onProfileChecked: function(profileId, checked) { root.setProfileChecked(profileId, checked) }
                        onSelectVisibleRequested: function(checked) { root.selectVisibleProfiles(checked) }
                        onClearSelectionRequested: root.selectedProfileIds = []
                        onSnapshotRequested: function(query) { root.requestSnapshot(query) }
                        onBatchPreviewRequested: function(operation) { root.requestBatchPreview(operation) }
                        onColumnChooserRequested: root.bulkMenuVisible = false
                        onBatchOverflowRequested: root.bulkMenuVisible = !root.bulkMenuVisible
                        onRowOverflowRequested: function(profileId) {
                            root.selectProfile(profileId)
                            root.bulkMenuVisible = false
                        }
                        onRowActionRequested: function(profileId, operation) {
                            root.handleProfileAction(profileId, operation)
                        }
                        onSectionRowRequested: function(link) {
                            root.followDeepLink(link)
                        }
                    }

                    Channels.BrowserInspector {
                        id: browserInspector
                        visible: root.selectedSection === 0
                        width: visible ? 370 : 0
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        profile: root.selectedProfile
                        canWrite: root.canWrite
                        controlPlaneBridge: root.plane
                        channelProfileModel: root.plane.channelProfileModel
                        commandRevision: root.commandRevision
                        onLaunchRequested: root.launchSelectedProfile()
                        onCloseRequested: root.closeSelectedProfile()
                        onDismissRequested: {
                            root.inspectorDismissed = true
                            root.selectedProfileId = ""
                            root.inspectorProfileId = ""
                            root.plane.entitySelection.clear()
                        }
                        onPinnedChanged: {
                            if (!pinned && root.selectedProfileId)
                                root.inspectorProfileId = root.selectedProfileId
                        }
                        onScanRequested: root.rescanSelectedProfile()
                        onProxyCheckRequested: root.checkSelectedProxy()
                        onDeepLinkRequested: function(link) { root.followDeepLink(link) }
                        onOverflowRequested: browserInventory.openRowMenu(
                            String(root.selectedProfile.profileId || ""))
                    }
                }

                Channels.PlatformHealthStrip {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 96
                    items: root.platformHealth
                    onTileRequested: function(link) { root.followDeepLink(link) }
                    onReportRequested: root.plane.navigateEntity("reports", "report_query", "platform_health", {"source": "channels"})
                }
            }
        }
    }

    Rectangle {
        id: bulkActionMenu
        objectName: "browserBulkActionMenu"
        visible: root.bulkMenuVisible
        width: 246
        height: 268
        x: root.width - width - 28
        y: 82
        z: 100
        radius: Theme.radiusSmall
        color: Theme.panel
        border.width: 1
        border.color: Theme.border
        Accessible.name: "Menu thao tác hàng loạt có preview server"
        Accessible.role: Accessible.PopupMenu
        Keys.onEscapePressed: root.bulkMenuVisible = false

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 3
            BulkMenuAction {
                objectName: "browserBulkMenuLaunch"
                label: "Mở Browser"
                iconName: "ui/play"
                onActivated: root.requestBatchPreview("launch")
            }
            BulkMenuAction {
                objectName: "browserBulkMenuClose"
                label: "Dừng Browser"
                iconName: "ui/power"
                onActivated: root.requestBatchPreview("close")
            }
            BulkMenuAction {
                objectName: "browserBulkMenuAssignProxy"
                label: "Gán proxy live"
                iconName: "ui/external-link"
                onActivated: root.requestBatchPreview("proxy.assign")
            }
            BulkMenuAction {
                objectName: "browserBulkMenuClearCache"
                label: "Xóa cache an toàn"
                iconName: "ui/refresh-cw"
                onActivated: root.requestBatchPreview("cache.clean")
            }
            BulkMenuAction {
                objectName: "browserBulkMenuMuteAudio"
                label: "Tắt âm thanh"
                iconName: "ui/volume-x"
                onActivated: root.requestBatchPreview("runtime_policy.patch")
            }
            BulkMenuAction {
                objectName: "browserBulkMenuHealthCheck"
                label: "Kiểm tra sức khỏe"
                iconName: "semantic/check-circle"
                onActivated: root.requestBatchPreview("health.check")
            }
        }
    }

    component BulkMenuAction: Button {
        id: menuAction
        required property string label
        required property string iconName
        signal activated()
        Layout.fillWidth: true
        Layout.preferredHeight: 39
        enabled: root.canWrite && root.selectedBatchCount > 0
        hoverEnabled: true
        activeFocusOnTab: true
        Accessible.name: menuAction.label
        Accessible.description: enabled
            ? "Tạo preview server trước khi execute"
            : "Chọn browser và cần quyền browser.write"
        onClicked: {
            menuAction.activated()
            root.bulkMenuVisible = false
        }
        contentItem: RowLayout {
            spacing: 9
            UiIcon {
                name: menuAction.iconName
                tone: menuAction.enabled ? Theme.info : Theme.textFaint
                iconSize: 15
            }
            Text {
                Layout.fillWidth: true
                text: menuAction.label
                color: menuAction.enabled ? Theme.textMuted : Theme.textFaint
                font.pixelSize: 11
            }
            UiIcon {
                name: "ui/chevron-right"
                tone: Theme.textFaint
                iconSize: 12
            }
        }
        background: Rectangle {
            radius: 5
            color: menuAction.hovered && menuAction.enabled
                ? Theme.hover : "transparent"
        }
    }
}
