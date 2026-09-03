pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../foundation" as Foundation
import "settings" as Settings

Item {
    id: root
    objectName: "settingsPage"
    Accessible.name: "Cài đặt hệ thống"
    Accessible.role: Accessible.Pane

    // qmllint disable unqualified
    readonly property var plane: controlPlane
    // qmllint enable unqualified
    readonly property var navigation: projectionData.navigation || ({})
    readonly property var navigationEntries: navigation.items || []
    readonly property int navigationEntryCount: navigationEntries.length
    property int selectedSectionIndex: -1
    readonly property string selectedSection: navigationEntries[selectedSectionIndex]
        ? String(navigationEntries[selectedSectionIndex].section) : ""
    property string searchQuery: ""

    property var settingsSnapshot: ({})
    property var snapshotError: ({})
    readonly property var projectionData: (settingsSnapshot || {}).data || ({})
    readonly property var registry: projectionData.registry || ({})
    readonly property var registryVersions: registry.versions || ({})
    readonly property var settingsDefinitions: registry.settings || []
    readonly property var historyModel: root.plane.snapshotStore.collection("settings", "history")
    readonly property var system: projectionData.system || ({})
    readonly property var app: system.app || ({})
    readonly property var appStateDescriptor: app.state_descriptor || ({})
    readonly property var release: system.release || ({})
    readonly property var license: system.license || ({})
    readonly property var resourceModel: root.plane.snapshotStore.collection("settings", "resources")
    readonly property var storage: system.storage || ({})
    readonly property var healthModel: root.plane.snapshotStore.collection("settings", "health")
    readonly property var support: system.support || ({})
    readonly property var privacy: system.privacy || ({})
    readonly property var externalHealthStatus: ((system.source_status || {}).external_health_probes) || ({})
    readonly property var externalHealthRetryAction: externalHealthStatus.retry || ({})
    readonly property var actions: projectionData.actions || ({})
    readonly property var aiRuntime: projectionData.ai_runtime || ({})
    readonly property var refreshAction: actions.refresh || ({})
    readonly property var applyAction: actions.apply || ({})
    readonly property var cancelAction: actions.cancel || ({})
    readonly property var resourceCheckAction: (system.resources_control || {}).check || ({})
    readonly property var resourceCatalogAction: (system.resources_control || {}).catalog || ({})
    readonly property var historyViewAllAction: (projectionData.history_control || {}).view_all || ({})
    readonly property int resourceCount: root.resourceModel.count

    property var baselineValues: ({})
    property var draftValues: ({})
    property var changedKeys: []
    property int draftRevision: 0
    property int commandRevision: 0
    property string submittedSnapshotId: ""
    property var pendingResultCapabilities: []
    property string actionBannerMessage: ""
    readonly property bool dirty: changedKeys.length > 0
    readonly property bool applyMergeContractValid: root.validApplyMergeContract(
        root.applyAction)
    readonly property bool cancelContractValid: root.actionAvailable(root.cancelAction)
        && String(root.cancelAction.kind || "") === "local_draft"
        && String(root.cancelAction.capability || "").length === 0
    readonly property bool draftRequiresRestart: root.computeDraftRequiresRestart()
    readonly property var applyCommandState: {
        const revision = root.commandRevision
        return root.plane.commandStore.state("settings.apply", "global", "global")
    }
    readonly property bool applyBusy: Boolean(applyCommandState.busy)
    readonly property bool snapshotBusy: {
        const revision = root.commandRevision
        return root.plane.commandStore.isBusy("settings.snapshot", "global", "global")
    }
    readonly property bool restartStaged: Boolean(registry.restart_required)
        || Boolean((applyCommandState.result || {}).restart_required)
    readonly property string viewState: root.resolveViewState()
    readonly property var filteredSettings: root.computeFilteredSettings()
    readonly property int filteredSettingCount: filteredSettings.length
    readonly property bool showRuntimeDashboard: searchQuery.trim().length === 0
        && selectedSection === "Runtime & Resources"
    readonly property bool showLicenseDashboard: searchQuery.trim().length === 0
        && selectedSection === "License"
    readonly property var runtimeSettings: root.settingsDefinitions.filter(function(item) {
        return String(item.section || "") === "Runtime & Resources"
    })

    onSettingsDefinitionsChanged: {
        if (root.dirty)
            root.recomputeChangedKeys(root.draftValues)
    }

    function reloadSnapshot() {
        const previousSection = root.selectedSection
        const previousId = String((root.settingsSnapshot || {}).snapshot_id || "")
        const next = root.plane.snapshotStore.snapshot("settings")
        root.settingsSnapshot = next
        root.snapshotError = root.plane.snapshotStore.error("settings")
        root.syncNavigation(previousSection)
        const nextId = String((next || {}).snapshot_id || "")
        if (!root.dirty || (root.submittedSnapshotId.length > 0
                && nextId.length > 0 && nextId !== root.submittedSnapshotId)) {
            root.syncDraft()
            if (nextId !== previousId)
                root.submittedSnapshotId = ""
        }
    }

    function memberMap(owner, key) {
        if (owner === null || owner === undefined || typeof owner !== "object")
            return ({})
        const value = owner[key]
        return value !== null && value !== undefined && typeof value === "object"
            ? value : ({})
    }

    function actionAvailable(action) {
        return action !== null && action !== undefined
            && typeof action === "object" && action.available === true
    }

    function actionReason(action, fallback) {
        if (root.actionAvailable(action))
            return ""
        const reason = action !== null && action !== undefined
            && typeof action === "object" ? String(action.reason_code || "") : ""
        return reason.length > 0 ? reason : String(fallback || "Hành động không khả dụng")
    }

    function actionInput(action) {
        return root.memberMap(action, "input")
    }

    function copyActionInput(action) {
        const source = root.actionInput(action)
        const result = ({})
        for (const key in source)
            result[key] = source[key]
        return result
    }

    function validApplyMergeContract(action) {
        const merge = root.memberMap(action, "input_merge")
        const required = merge.required
        if (String(merge.strategy || "") !== "object_merge"
                || required === null || required === undefined
                || typeof required !== "object")
            return false
        const count = Number(required.length)
        if (!Number.isFinite(count) || count < 0)
            return false
        for (let index = 0; index < count; index++) {
            if (String(required[index] || "") === "changes")
                return true
        }
        return false
    }

    function callAction(action, extra) {
        if (!root.actionAvailable(action))
            return false
        const capability = String(action.capability || "")
        if (!capability)
            return false
        const payload = root.copyActionInput(action)
        const additions = extra !== null && extra !== undefined
            && typeof extra === "object" ? extra : ({})
        for (const key in additions)
            payload[key] = additions[key]
        if (String(action.kind || "") !== "snapshot") {
            const pending = root.pendingResultCapabilities.slice()
            if (pending.indexOf(capability) < 0)
                pending.push(capability)
            root.pendingResultCapabilities = pending
        }
        root.plane.callTool(capability, payload)
        return true
    }

    function openDeepLink(link) {
        const projected = link !== null && link !== undefined
            && typeof link === "object" ? link : ({})
        const entity = root.memberMap(projected, "entity")
        const route = String(projected.route || "")
        if (!route)
            return false
        root.plane.navigateEntity(
            route,
            String(entity.type || ""),
            String(entity.id || ""),
            root.memberMap(projected, "context")
        )
        return true
    }

    function navigationIndex(key) {
        const identity = String(key || "")
        for (let index = 0; index < root.navigationEntries.length; index++) {
            if (String((root.navigationEntries[index] || {}).key || "") === identity)
                return index
        }
        return -1
    }

    function syncNavigation(previousSection) {
        const section = String(previousSection || "")
        for (let index = 0; index < root.navigationEntries.length; index++) {
            if (String((root.navigationEntries[index] || {}).section || "") === section) {
                root.selectedSectionIndex = index
                return
            }
        }
        root.selectedSectionIndex = root.navigationIndex(root.navigation.default_key)
    }

    function hasPermission(permission) {
        const requested = String(permission || "").trim()
        if (!requested)
            return false
        const permissions = (root.settingsSnapshot || {}).permissions || []
        return permissions.indexOf(requested) >= 0 || permissions.indexOf("workspace.admin") >= 0
    }

    function hasProjectionData() {
        return root.settingsDefinitions.length > 0 || root.historyModel.count > 0
            || root.resourceModel.count > 0 || root.healthModel.count > 0
            || Object.keys(root.app).length > 0 || Object.keys(root.release).length > 0
            || Object.keys(root.storage).length > 0 || Object.keys(root.support).length > 0
            || Object.keys(root.license).length > 0
            || Object.keys(root.privacy).length > 0
    }

    function resolveViewState() {
        const snapshot = root.settingsSnapshot || ({})
        const error = root.snapshotError || ({})
        const hasSnapshot = String(snapshot.snapshot_id || "").length > 0
        const errorCode = String(error.code || "").toUpperCase()
        if (!hasSnapshot) {
            if (errorCode === "PERMISSION_DENIED" || errorCode === "FORBIDDEN")
                return "permission"
            return errorCode.length > 0 ? "error" : "loading"
        }
        if (!root.hasPermission("settings.read"))
            return "permission"
        if (errorCode === "NETWORK_ERROR" || errorCode === "OFFLINE")
            return "offline"
        if (errorCode.length > 0)
            return "error"
        const state = String((snapshot.freshness || {}).state || "fresh").toLowerCase()
        if (state === "partial" || state === "stale")
            return state
        return root.hasProjectionData() ? "content" : "empty"
    }

    function safeBaselineValue(definition) {
        const type = String((definition || {}).value_type || "")
        const sensitivity = String((definition || {}).sensitivity || "")
        if (type === "secret" || sensitivity === "secret")
            return ""
        return (definition || {}).value
    }

    function syncDraft() {
        const baseline = ({})
        const draft = ({})
        for (let index = 0; index < root.settingsDefinitions.length; index++) {
            const definition = root.settingsDefinitions[index] || ({})
            const key = String(definition.key || "")
            if (!key)
                continue
            const value = root.safeBaselineValue(definition)
            baseline[key] = value
            draft[key] = value
        }
        root.baselineValues = baseline
        root.draftValues = draft
        root.changedKeys = []
        root.draftRevision += 1
    }

    function draftValueFor(definition) {
        const revision = root.draftRevision
        const key = String((definition || {}).key || "")
        if (String((definition || {}).sensitivity || "") === "secret"
                || String((definition || {}).value_type || "") === "secret")
            return String(root.draftValues[key] || "")
        return Object.prototype.hasOwnProperty.call(root.draftValues, key)
            ? root.draftValues[key] : (definition || {}).value
    }

    function definitionForKey(key) {
        const identity = String(key || "")
        for (let index = 0; index < root.settingsDefinitions.length; index++) {
            const definition = root.settingsDefinitions[index] || ({})
            if (String(definition.key || "") === identity)
                return definition
        }
        return ({})
    }

    function valuesEqual(left, right) {
        return JSON.stringify(left) === JSON.stringify(right)
    }

    function editorAvailable(definition) {
        const item = definition !== null && definition !== undefined
            && typeof definition === "object" ? definition : ({})
        const editor = root.memberMap(item, "editor")
        const effect = root.memberMap(editor, "effect")
        return root.actionAvailable(editor) && effect.connected === true
    }

    function setDraftValue(key, value) {
        const identity = String(key || "")
        const definition = root.definitionForKey(identity)
        if (!identity || !definition.key || !root.editorAvailable(definition))
            return false
        const next = Object.assign({}, root.draftValues)
        next[identity] = value
        root.draftValues = next
        root.recomputeChangedKeys(next)
        root.draftRevision += 1
        return true
    }

    function recomputeChangedKeys(values) {
        const next = values !== null && values !== undefined
            && typeof values === "object" ? values : ({})
        const changed = []
        for (let index = 0; index < root.settingsDefinitions.length; index++) {
            const item = root.settingsDefinitions[index] || ({})
            const itemKey = String(item.key || "")
            if (!itemKey || !root.editorAvailable(item))
                continue
            const secret = String(item.sensitivity || "") === "secret"
                || String(item.value_type || "") === "secret"
            if (secret) {
                if (String(next[itemKey] || "").trim().length > 0)
                    changed.push(itemKey)
            } else if (!root.valuesEqual(next[itemKey], root.baselineValues[itemKey])) {
                changed.push(itemKey)
            }
        }
        root.changedKeys = changed
    }

    function computeDraftRequiresRestart() {
        for (let index = 0; index < root.changedKeys.length; index++) {
            if (Boolean(root.definitionForKey(root.changedKeys[index]).requires_restart))
                return true
        }
        return false
    }

    function buildChanges() {
        const changes = ({})
        for (let index = 0; index < root.changedKeys.length; index++) {
            const key = root.changedKeys[index]
            if (!root.editorAvailable(root.definitionForKey(key)))
                continue
            changes[key] = root.draftValues[key]
        }
        return changes
    }

    function cancelDraft() {
        if (root.applyBusy || !root.cancelContractValid)
            return false
        root.syncDraft()
        return true
    }

    function applyDraft() {
        if (!root.dirty || root.applyBusy || !root.actionAvailable(root.applyAction)
                || !root.applyMergeContractValid)
            return false
        const changes = root.buildChanges()
        if (Object.keys(changes).length === 0) {
            root.recomputeChangedKeys(root.draftValues)
            return false
        }
        root.submittedSnapshotId = String((root.settingsSnapshot || {}).snapshot_id || "")
        return root.callAction(root.applyAction, {"changes": changes})
    }

    function computeFilteredSettings() {
        const query = root.searchQuery.trim().toLowerCase()
        return root.settingsDefinitions.filter(function(item) {
            const definition = item || ({})
            if (query.length > 0) {
                const searchable = [definition.key, definition.title, definition.section]
                    .map(function(value) { return String(value || "").toLowerCase() })
                    .join(" ")
                return searchable.indexOf(query) >= 0
            }
            return String(definition.section || "") === root.selectedSection
        })
    }

    function openStorageAction(action) {
        if (!root.actionAvailable(action)
                || String(action.kind || "") !== "local_open_path")
            return false
        const input = root.actionInput(action)
        const key = String(input.path_key || "")
        if (!key)
            return false
        return root.plane.openSettingsStoragePath(key)
    }

    function requestSettingBrowse(settingKey) {
        const key = String(settingKey || "")
        const definition = root.definitionForKey(key)
        const editor = root.memberMap(definition, "editor")
        const browseAction = root.memberMap(editor, "browse_action")
        if (key.length === 0 || !root.editorAvailable(definition)
                || !root.actionAvailable(browseAction)
                || String(browseAction.kind || "") !== "local_path_picker")
            return false
        return settingsPathDialog.openFor(key, root.draftValues[key])
    }

    Settings.SettingsPathDialog {
        id: settingsPathDialog
        onPathAccepted: function(settingKey, pathValue) {
            root.setDraftValue(settingKey, pathValue)
        }
    }

    Settings.SettingsResultDialog {
        id: settingsResultDialog
    }

    function refreshSettings() {
        return root.callAction(root.refreshAction, ({}))
    }

    function retrySettings() {
        if (!root.actionAvailable(root.refreshAction))
            return false
        const capability = String(root.refreshAction.capability || "")
        return capability.length > 0
            && Boolean(root.plane.refreshSnapshotTool(capability))
    }

    function descriptorTone(descriptor) {
        const tone = String((descriptor || {}).tone_key || "warning")
        if (tone === "success") return Theme.success
        if (tone === "danger") return Theme.danger
        if (tone === "info") return Theme.info
        return Theme.warning
    }

    function displayDateTime(value) {
        const raw = String(value || "")
        if (!raw) return "Không khả dụng"
        const parsed = new Date(raw)
        return isNaN(parsed.getTime()) ? raw
            : Qt.formatDateTime(parsed, "dd/MM/yyyy HH:mm")
    }

    function headerStatusText() {
        if (root.actionBannerMessage.length > 0)
            return root.actionBannerMessage
        if (root.viewState === "loading")
            return "Đang chờ snapshot cài đặt từ backend"
        if (root.viewState === "permission")
            return "Không có quyền settings.read"
        if (root.viewState === "offline")
            return "Ngoại tuyến · đang giữ dữ liệu gần nhất"
        if (root.viewState === "error")
            return String((root.snapshotError || {}).message || "Không thể tải snapshot cài đặt")
        if (root.viewState === "partial")
            return "Snapshot thiếu một phần nguồn dữ liệu"
        if (root.viewState === "stale")
            return "Snapshot có thể đã cũ"
        if (root.applyBusy)
            return "Đang lưu thay đổi"
        if (String(root.applyCommandState.state || "") === "failed")
            return String(root.applyCommandState.message || "Lưu thất bại")
        if (root.restartStaged)
            return "Đã lưu · backend đã xếp trạng thái cần khởi động lại"
        if (root.dirty)
            return root.changedKeys.length + " thay đổi chưa lưu"
        return "Không có thay đổi cục bộ"
    }

    Component.onCompleted: root.reloadSnapshot()

    Connections {
        target: root.plane
        function onActionFinished(toolName, ok, data, message) {
            const capability = String(toolName || "")
            const pendingIndex = root.pendingResultCapabilities.indexOf(capability)
            if (pendingIndex < 0)
                return
            const pending = root.pendingResultCapabilities.slice()
            pending.splice(pendingIndex, 1)
            root.pendingResultCapabilities = pending
            root.actionBannerMessage = ok
                ? String(message || "Thao tác cài đặt đã hoàn tất phía server.")
                : String(message || "Thao tác cài đặt bị server từ chối.")
            if (!ok || capability === "settings.apply")
                return
            const resultKinds = {
                "settings.resource.catalog.inspect": ["catalog", "Phiên bản tài nguyên CDN"],
                "settings.resources.check": ["resources", "Kết quả kiểm tra tài nguyên"],
                "settings.resource.update": ["resource", "Kết quả tài nguyên"],
                "settings.diagnostics.run": ["diagnostics", "Kết quả chẩn đoán"],
                "settings.support.export": ["support", "Gói hỗ trợ đã tạo"],
                "settings.update.check": ["update", "Kết quả kiểm tra cập nhật"],
                "settings.update.certificate.inspect": ["certificate", "Thông tin chứng chỉ"],
                "settings.update.rollback": ["rollback", "Kết quả khôi phục"]
            }
            const descriptor = resultKinds[capability]
            if (descriptor)
                settingsResultDialog.openResult(
                    descriptor[0], descriptor[1], data, message)
        }
    }

    Connections {
        target: root.plane.snapshotStore
        function onChanged(route) {
            if (route === "settings")
                root.reloadSnapshot()
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
        anchors.margins: 14
        spacing: 10

        Foundation.PageHeader {
            id: settingsHeader
            objectName: "settingsHeader"
            Layout.fillWidth: true
            eyebrow: "TRUNG TÂM HỆ THỐNG"
            title: "Cài đặt hệ thống"
            description: "Quản lý bản quyền, runtime, tài nguyên và chính sách hệ thống"

            Foundation.StatusPill {
                objectName: "settingsHeaderStatePill"
                visible: root.viewState !== "partial" && root.viewState !== "stale"
                text: root.viewState === "loading" ? "Đang tải"
                    : root.viewState === "permission" ? "Thiếu quyền"
                    : root.viewState === "offline" ? "Ngoại tuyến"
                    : root.viewState === "error" ? "Lỗi dữ liệu"
                    : root.viewState === "partial" ? "Dữ liệu một phần"
                    : root.viewState === "stale" ? "Dữ liệu cũ"
                    : root.dirty ? "Bản nháp"
                    : root.restartStaged ? "Đã xếp restart" : "Đã đồng bộ"
                tone: root.viewState === "permission" || root.viewState === "offline"
                        || root.viewState === "error" ? Theme.danger
                    : root.viewState === "loading" || root.viewState === "partial"
                        || root.viewState === "stale" || root.dirty ? Theme.warning
                    : root.restartStaged ? Theme.info : Theme.success
                showDot: true
            }
            TextField {
                id: settingsSearch
                objectName: "settingsSearchField"
                Layout.preferredWidth: 280
                implicitHeight: 38
                placeholderText: "Tìm trong cài đặt…"
                activeFocusOnTab: true
                Accessible.name: "Tìm trong cài đặt"
                Accessible.description: "Chỉ tìm theo tên, khóa và nhóm; không tìm trong giá trị bí mật"
                onTextChanged: root.searchQuery = text
                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: Theme.elevated
                    border.width: 1
                    border.color: settingsSearch.activeFocus ? Theme.accent : Theme.borderSoft
                }
                color: Theme.text
                placeholderTextColor: Theme.textFaint
            }
            AppButton {
                id: refreshButton
                objectName: "settingsRefreshButton"
                text: root.snapshotBusy ? "Đang tải…" : "Làm mới"
                activeFocusOnTab: true
                enabled: root.actionAvailable(root.refreshAction) && !root.snapshotBusy
                availabilityReason: enabled ? "" : (root.snapshotBusy
                    ? "Đang làm mới cài đặt"
                    : root.actionReason(root.refreshAction, "Không thể làm mới cài đặt"))
                Accessible.name: text
                Accessible.description: availabilityReason
                onClicked: root.refreshSettings()
            }
        }

        Foundation.AsyncStateView {
            id: settingsAsync
            objectName: "settingsAsyncState"
            Layout.fillWidth: true
            Layout.fillHeight: true
            viewState: root.viewState
            hasData: root.hasProjectionData()
            accessibleName: "Nội dung cài đặt hệ thống"
            emptyTitle: "Chưa tải được cài đặt"
            emptyDescription: "Hãy làm mới để tải lại cài đặt hệ thống."
            errorMessage: String((root.snapshotError || {}).message || "Không thể tải cài đặt hệ thống.")
            requiredPermission: "settings.read"
            freshnessBannerEnabled: false
            onRetry: root.retrySettings()

            RowLayout {
                anchors.fill: parent
                anchors.topMargin: settingsAsync.showFreshnessBanner ? 42 : 0
                spacing: 10

                Settings.SettingsNavigation {
                    Layout.preferredWidth: 208
                    Layout.fillHeight: true
                    entries: root.navigationEntries
                    currentIndex: root.selectedSectionIndex
                    onSectionSelected: function(index) {
                        root.selectedSectionIndex = index
                        settingsSearch.clear()
                    }
                }

                Loader {
                    id: centerLoader
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    sourceComponent: root.showLicenseDashboard ? licenseDashboardComponent
                        : root.showRuntimeDashboard ? runtimeDashboardComponent : settingsListComponent
                }

                Settings.SystemHealthPanel {
                    Layout.preferredWidth: 304
                    Layout.minimumWidth: 304
                    Layout.maximumWidth: 304
                    Layout.fillHeight: true
                    healthModel: root.healthModel
                    support: root.support
                    controlPlaneBridge: root.plane
                    commandRevision: root.commandRevision
                    onActionRequested: function(action) { root.callAction(action, ({})) }
                }
            }

            Rectangle {
                objectName: "settingsFreshnessDetail"
                visible: settingsAsync.showFreshnessBanner
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 0
                height: 32
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 4
                    spacing: 8
                    UiIcon {
                        name: "semantic/alert-circle"
                        iconSize: 14
                        tone: Theme.warning
                    }
                    Text {
                        objectName: "settingsFreshnessDetailText"
                        Layout.fillWidth: true
                        text: String(root.externalHealthStatus.label
                            || "Một phần nguồn dữ liệu chưa sẵn sàng")
                            + " · " + String(root.externalHealthStatus.detail
                                || ((root.settingsSnapshot.partial_errors || [])[0] || {}).message
                                || "Chưa có chi tiết để hiển thị")
                        color: Theme.textMuted
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    AppButton {
                        objectName: "settingsFreshnessRetryButton"
                        implicitHeight: 26
                        text: String(root.externalHealthRetryAction.label || "Thử lại")
                        activeFocusOnTab: true
                        enabled: root.actionAvailable(root.externalHealthRetryAction)
                            && !root.snapshotBusy
                        availabilityReason: enabled ? "" : (root.snapshotBusy
                            ? "Đang tải lại bằng chứng"
                            : root.actionReason(root.externalHealthRetryAction,
                                "Không thể tải lại nguồn dữ liệu"))
                        Accessible.name: text
                        Accessible.description: availabilityReason
                        onClicked: root.callAction(root.externalHealthRetryAction, ({}))
                    }
                }
            }
        }

        Panel {
            objectName: "settingsFooter"
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            Accessible.name: "Thao tác lưu cài đặt"
            Accessible.role: Accessible.ToolBar
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 10
                spacing: 10
                Text {
                    objectName: "settingsFooterStatusText"
                    text: root.draftRequiresRestart
                        ? "Các thay đổi đang chọn cần backend xếp trạng thái khởi động lại sau khi lưu."
                        : root.applyBusy ? "Đang lưu thay đổi"
                        : String(root.applyCommandState.state || "") === "failed"
                            ? String(root.applyCommandState.message || "Lưu thất bại")
                        : root.dirty ? root.changedKeys.length + " thay đổi chưa lưu"
                        : "Không có thay đổi cục bộ"
                    color: root.draftRequiresRestart || root.dirty ? Theme.warning
                        : String(root.applyCommandState.state || "") === "failed" ? Theme.danger : Theme.textFaint
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                AppButton {
                    objectName: "settingsCancelButton"
                    text: "Hủy bỏ"
                    activeFocusOnTab: true
                    enabled: root.dirty && root.cancelContractValid && !root.applyBusy
                    availabilityReason: enabled ? "" : (root.applyBusy
                        ? "Đang áp dụng thay đổi"
                        : !root.dirty ? "Không có thay đổi cục bộ để hủy"
                        : !root.cancelContractValid
                        ? "Không thể hủy thay đổi lúc này"
                        : root.actionReason(root.cancelAction, "Không thể hủy bản nháp"))
                    Accessible.name: text
                    Accessible.description: enabled
                        ? "Bỏ các thay đổi cục bộ chưa gửi lên backend"
                        : availabilityReason
                    onClicked: root.cancelDraft()
                }
                AppButton {
                    objectName: "settingsApplyButton"
                    text: root.applyBusy ? "Đang áp dụng…"
                        : root.draftRequiresRestart ? "Áp dụng & yêu cầu khởi động lại" : "Áp dụng"
                    primary: true
                    activeFocusOnTab: true
                    enabled: root.dirty && root.actionAvailable(root.applyAction)
                        && root.applyMergeContractValid && !root.applyBusy
                    availabilityReason: enabled ? "" : (root.applyBusy
                        ? "Đang áp dụng thay đổi"
                        : !root.dirty ? "Không có thay đổi để áp dụng"
                        : !root.applyMergeContractValid
                        ? "Không thể áp dụng thay đổi lúc này"
                        : root.actionReason(root.applyAction, "Không thể áp dụng cài đặt"))
                    Accessible.name: text
                    Accessible.description: !enabled ? availabilityReason
                        : root.draftRequiresRestart
                        ? "Lưu cài đặt; backend chỉ xếp trạng thái cần khởi động lại, ứng dụng không tự khởi động lại"
                        : "Lưu cài đặt qua backend"
                    onClicked: root.applyDraft()
                }
            }
        }
    }

    Component {
        id: licenseDashboardComponent
        Settings.LicenseCenterPanel {
            license: root.license
            controlPlaneBridge: root.plane
            commandRevision: root.commandRevision
            onActionRequested: function(action, extra) {
                root.callAction(action, extra)
            }
        }
    }

    Component {
        id: runtimeDashboardComponent
        ScrollView {
            id: runtimeScroll
            clip: true
            contentWidth: availableWidth

            ColumnLayout {
                width: runtimeScroll.availableWidth
                spacing: 10

                Panel {
                    objectName: "runtimeOverview"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 82
                    Accessible.name: "Tổng quan Runtime, phiên bản " + String(root.app.version || "không rõ")
                        + ", trạng thái " + String(root.appStateDescriptor.label || "Không rõ")
                    Accessible.role: Accessible.Pane
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 18
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 4
                            Text { text: "Tổng quan Runtime"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }
                            RowLayout {
                                spacing: 20
                                ColumnLayout {
                                    spacing: 2
                                    Text { text: "Phiên bản Runtime"; color: Theme.textFaint; font.pixelSize: 11 }
                                    Text { text: String(root.app.version || "Không khả dụng"); color: root.app.version ? Theme.text : Theme.warning; font.pixelSize: 13; font.weight: Font.DemiBold }
                                }
                                ColumnLayout {
                                    spacing: 2
                                    Text { text: "Trạng thái"; color: Theme.textFaint; font.pixelSize: 11 }
                                    Foundation.StatusPill {
                                        text: String(root.appStateDescriptor.label || "Không rõ")
                                        tone: root.descriptorTone(root.appStateDescriptor)
                                    }
                                }
                                ColumnLayout {
                                    spacing: 2
                                    Text { text: "Xác minh cuối"; color: Theme.textFaint; font.pixelSize: 11 }
                                    Text { text: root.displayDateTime(root.app.last_verified_at); color: root.app.last_verified_at ? Theme.textMuted : Theme.warning; font.pixelSize: 11 }
                                }
                            }
                        }
                        AppButton {
                            objectName: "runtimeRefreshButton"
                            text: root.snapshotBusy ? "Đang làm mới…" : "Làm mới"
                            activeFocusOnTab: true
                            enabled: root.actionAvailable(root.refreshAction)
                                && !root.snapshotBusy
                            availabilityReason: enabled ? "" : (root.snapshotBusy
                                ? "Đang làm mới cài đặt"
                                : root.actionReason(root.refreshAction,
                                    "Không thể làm mới Runtime"))
                            Accessible.name: "Làm mới tổng quan Runtime"
                            Accessible.description: availabilityReason
                            onClicked: root.refreshSettings()
                        }
                    }
                }

                Settings.ResourceTable {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    resourceModel: root.resourceModel
                    checkAction: root.resourceCheckAction
                    catalogAction: root.resourceCatalogAction
                    controlPlaneBridge: root.plane
                    commandRevision: root.commandRevision
                    onActionRequested: function(action) { root.callAction(action, ({})) }
                    onDeepLinkRequested: function(link) { root.openDeepLink(link) }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Settings.RuntimePathsPanel {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        storage: root.storage
                        onOpenRequested: function(action) { root.openStorageAction(action) }
                    }
                    Panel {
                        objectName: "automaticResourcesPanel"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: Math.max(
                            184, 48 + Math.ceil(root.runtimeSettings.length / 2) * 62
                        )
                        Accessible.name: "Cập nhật tài nguyên tự động"
                        Accessible.role: Accessible.Pane
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 14; spacing: 4
                            Text { text: "Cập nhật tài nguyên tự động"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }
                            Text { visible: root.runtimeSettings.length === 0; text: "Mục này chưa có tùy chọn cần cấu hình."; color: Theme.textMuted; font.pixelSize: 11 }
                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 14
                                rowSpacing: 2
                                Repeater {
                                    model: root.runtimeSettings
                                    delegate: Settings.TypedSettingEditor {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 1
                                        compact: true
                                        definition: modelData
                                        sourceValue: root.draftValueFor(modelData)
                                        editable: root.editorAvailable(modelData)
                                            && !root.applyBusy
                                        onValueEdited: function(key, value) { root.setDraftValue(key, value) }
                                        onBrowseRequested: function(key) { root.requestSettingBrowse(key) }
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Settings.ApplicationUpdatePanel {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        release: root.release
                        controlPlaneBridge: root.plane
                        commandRevision: root.commandRevision
                        onActionRequested: function(action) { root.callAction(action, ({})) }
                        onDeepLinkRequested: function(link) { root.openDeepLink(link) }
                    }
                    Settings.ChangeHistoryPanel {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        historyModel: root.historyModel
                        viewAllAction: root.historyViewAllAction
                        controlPlaneBridge: root.plane
                        onActionRequested: function(action) { root.callAction(action, ({})) }
                    }
                }
            }
        }
    }

    Component {
        id: settingsListComponent
        ScrollView {
            id: listScroll
            clip: true
            contentWidth: availableWidth
            Panel {
                objectName: "settingsRegistryList"
                width: listScroll.availableWidth
                implicitHeight: Math.max(
                    listScroll.availableHeight,
                    94 + root.filteredSettings.length * 68
                        + (root.selectedSection === "AI Providers" ? 190 : 0))
                Accessible.name: root.searchQuery.length > 0
                    ? "Kết quả tìm cài đặt" : "Cài đặt nhóm " + root.selectedSection
                Accessible.role: Accessible.List
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 5
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: root.searchQuery.length > 0
                                ? "Kết quả tìm kiếm"
                                : String((root.navigationEntries[root.selectedSectionIndex] || {}).label
                                    || "Cài đặt")
                            color: Theme.text; font.pixelSize: 17; font.weight: Font.Bold
                        }
                        Foundation.StatusPill {
                            visible: root.filteredSettingCount > 0
                                || root.searchQuery.length > 0
                            text: root.filteredSettingCount + " cài đặt"
                            tone: root.filteredSettingCount > 0 ? Theme.info : Theme.warning
                            showDot: false
                        }
                    }
                    Settings.AIProviderHealthPanel {
                        id: aiProviderHealthPanel
                        visible: root.selectedSection === "AI Providers"
                            && root.aiRuntime.available === true
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible
                            ? aiProviderHealthPanel.requiredHeight : 0
                        runtimeStatus: root.aiRuntime
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: root.filteredSettingCount === 0
                            && (root.selectedSection !== "AI Providers"
                                || root.searchQuery.length > 0)
                        text: root.searchQuery.length > 0
                            ? "Không có cài đặt phù hợp."
                            : "Mục này chưa có tùy chọn cần cấu hình."
                        color: Theme.textMuted
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                    }
                    Repeater {
                        model: root.filteredSettings
                        delegate: Settings.TypedSettingEditor {
                            required property var modelData
                            Layout.fillWidth: true
                            definition: modelData
                            sourceValue: root.draftValueFor(modelData)
                            editable: root.editorAvailable(modelData)
                                && !root.applyBusy
                            onValueEdited: function(key, value) { root.setDraftValue(key, value) }
                            onBrowseRequested: function(key) { root.requestSettingBrowse(key) }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
