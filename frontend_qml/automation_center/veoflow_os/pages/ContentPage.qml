pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import ".."
import "../foundation" as Foundation
import "content" as Content

Item {
    id: root
    objectName: "contentPage"
    Accessible.name: "Không gian nội dung"
    Accessible.role: Accessible.Pane

    // qmllint disable unqualified
    readonly property var plane: controlPlane
    // qmllint enable unqualified
    property var contentSnapshot: ({})
    property var snapshotError: ({})
    property string selectedContentId: ""
    property bool inspectorVisible: true
    property string selectedInventoryEntityId: ""
    property string activeTab: "library"
    property string searchText: ""
    property string channelFilter: ""
    property string campaignFilter: ""
    property string stageFilter: ""
    property string formatFilter: ""
    property string languageFilter: ""
    property string viewMode: "list"
    property string contentViewMode: "list"
    property string sortMode: "updated_desc"
    property bool includeArchived: false
    property int pageSize: 5
    property string createTitleDraft: ""
    property string createChannelId: ""
    property string createCampaignId: ""
    property string importPathDraft: ""
    property string packageAssetId: ""
    property string selectedSavedViewKey: ""
    property string savedViewKeyDraft: ""
    property string savedViewNameDraft: ""
    property string updateStageDraft: "writing"
    property var bulkSelection: ({})
    property int bulkSelectionRevision: 0
    property string bulkOperationDraft: "change_stage"
    property string bulkCampaignIdDraft: ""
    property string bulkTargetStageDraft: "writing"
    property var bulkBatch: ({})
    property string bulkPreviewIdempotencyKey: ""
    property string bulkExecuteIdempotencyKey: ""
    property string bulkMessage: ""
    property int commandRevision: 0
    property int selectionRevision: 0
    property int commandSequence: 0

    readonly property var snapshotData: (root.contentSnapshot || {}).data || ({})
    readonly property var headerData: root.snapshotData.header || ({})
    // A Python QVariantMap is not guaranteed to be truthy in QML. Preserve
    // the authoritative lifecycle map explicitly instead of falling through
    // to an empty object and silently hiding the entire lifecycle rail.
    readonly property var lifecycleData: root.mapOrEmpty(root.snapshotData.lifecycle)
    readonly property var filterData: root.snapshotData.filters || ({})
    readonly property var inventoryData: root.snapshotData.inventory || ({})
    readonly property var inventoryModel: root.plane.snapshotStore.collection(
        "content", "inventory")
    readonly property var historyModel: root.plane.snapshotStore.collection(
        "content", "history")
    readonly property var reuseModel: root.plane.snapshotStore.collection(
        "content", "reuse")
    readonly property var rawSelection: root.snapshotData.selection || ({})
    readonly property bool selectionMatchesProjection: !root.selectedContentId
        || String((root.rawSelection.content || {}).id || "") === root.selectedContentId
    readonly property var selectionData: root.selectionMatchesProjection
        ? root.rawSelection
        : ({"state": "pending", "content": null})
    readonly property var historyData: root.selectionMatchesProjection
        ? (root.snapshotData.history || ({})) : ({"items": [], "total": 0})
    readonly property var reuseData: root.snapshotData.reuse || ({})
    readonly property var savedViewsData: root.snapshotData.saved_views || ({})
    readonly property var bulkActionData: (root.headerData.actions || {}).bulk || ({})
    readonly property var campaignOptions: root.campaignOptionsForChannel(
        root.createChannelId
    )
    readonly property var snapshotPage: (root.contentSnapshot || {}).page || ({})
    readonly property bool hasProjectionData: root.inventoryModel.count > 0
        || Number(root.inventoryData.total || 0) > 0
        || String((root.rawSelection.content || {}).id || "").length > 0
        || root.reuseModel.count > 0
    readonly property bool canRead: root.hasPermission("content.read")

    function mapOrEmpty(value) {
        return value === null || value === undefined ? ({}) : value
    }
    readonly property bool canWrite: root.hasPermission("content.write")
    readonly property string viewState: root.resolveViewState()
    readonly property bool createBusy: root.commandBusy(
        "content.create", root.createChannelId ? "channel" : "global",
        root.createChannelId || "global"
    )
    readonly property bool importBusy: root.commandBusy(
        "asset.register.local", "global", "global"
    )
    readonly property bool packageBusy: root.commandBusy(
        "content.package.create",
        (root.selectionData.content || {}).id ? "content" : "global",
        String((root.selectionData.content || {}).id || "global")
    )
    readonly property bool deleteBusy: root.commandBusy(
        "content.delete", "content", root.selectedContentId || "none"
    )
    readonly property int selectedContentVersion: root.contentVersion(
        root.selectedContentId
    )
    readonly property int bulkSelectionCount: root.selectedBulkTargets().length
    readonly property int bulkStaleCount: root.countStaleBulkTargets()
    readonly property bool bulkAvailable: root.canWrite
        && Boolean(root.bulkActionData.enabled)
        && String(root.inventoryData.entity_type || "") === "content"
    readonly property bool bulkBusy: root.bulkCommandBusy()
    readonly property bool selectedContentUpdateBusy: root.selectedContentId
        ? root.commandBusy("content.update", "content", root.selectedContentId)
        : false
    readonly property bool savedViewBusy: root.commandBusy(
        "content.saved_view.upsert", "content_saved_view",
        root.savedViewKeyDraft || root.selectedSavedViewKey || "new"
    )
    readonly property var safeStageOptions: [
        {"id": "idea", "label": "Ý tưởng"},
        {"id": "writing", "label": "Đang viết"},
        {"id": "ready_production", "label": "Sẵn sàng sản xuất"}
    ]

    function hasPermission(permission) {
        const requested = String(permission || "").trim()
        if (!requested) return false
        const permissions = (root.contentSnapshot || {}).permissions || []
        if (permissions.indexOf(requested) >= 0
                || permissions.indexOf("workspace.admin") >= 0)
            return true
        if (requested === "content.read")
            return permissions.indexOf("workspace.read") >= 0
        if (requested === "content.write")
            return permissions.indexOf("workspace.write") >= 0
        return false
    }

    function optionIndex(items, identity) {
        const source = items || []
        const target = String(identity || "")
        for (let index = 0; index < source.length; index++) {
            if (String((source[index] || {}).id || "") === target)
                return index
        }
        return 0
    }

    function channelOptionExists(channelId) {
        const target = String(channelId || "")
        if (!target) return false
        const channels = root.filterData.channels || []
        for (let index = 0; index < channels.length; index++) {
            if (String((channels[index] || {}).id || "") === target)
                return true
        }
        return false
    }

    function campaignBelongsToChannel(campaignId, channelId) {
        const campaignTarget = String(campaignId || "")
        if (!campaignTarget) return true
        const channelTarget = String(channelId || "")
        if (!channelTarget) return false
        const campaigns = root.filterData.campaigns || []
        for (let index = 0; index < campaigns.length; index++) {
            const campaign = campaigns[index] || ({})
            if (String(campaign.id || "") === campaignTarget)
                return String(campaign.channel_id || "") === channelTarget
        }
        return false
    }

    function campaignOptionsForChannel(channelId) {
        const channelTarget = String(channelId || "")
        const options = [{"id": "", "label": "Không gắn campaign"}]
        if (!channelTarget) return options
        const campaigns = root.filterData.campaigns || []
        for (let index = 0; index < campaigns.length; index++) {
            const campaign = campaigns[index] || ({})
            if (String(campaign.channel_id || "") === channelTarget)
                options.push(campaign)
        }
        return options
    }

    function setCreateChannel(channelId) {
        root.createChannelId = String(channelId || "")
        if (!root.campaignBelongsToChannel(
                root.createCampaignId, root.createChannelId))
            root.createCampaignId = ""
        return root.channelOptionExists(root.createChannelId)
    }

    function savedViewForKey(viewKey) {
        const target = String(viewKey || root.selectedSavedViewKey
            || root.savedViewsData.selected_view_key
            || root.savedViewsData.default_view_key || "")
        const items = root.savedViewsData.items || []
        for (let index = 0; index < items.length; index++) {
            const item = items[index] || ({})
            if (String(item.view_key || "") === target)
                return item
        }
        return ({})
    }

    function reconcileSavedViewSelection(savedViews) {
        const data = savedViews || ({})
        if (!Boolean(data.available)) {
            root.selectedSavedViewKey = ""
            return
        }
        const projectedKey = String(data.selected_view_key
            || data.default_view_key || "")
        const items = data.items || []
        for (let index = 0; index < items.length; index++) {
            if (String((items[index] || {}).view_key || "") === projectedKey) {
                root.selectedSavedViewKey = projectedKey
                return
            }
        }
        root.selectedSavedViewKey = ""
    }

    function validSavedViewKey(value) {
        return /^[a-z][a-z0-9_-]{0,79}$/.test(String(value || "").trim())
    }

    function savedViewDraftValid() {
        const viewKey = root.savedViewKeyDraft.trim()
        return root.canWrite && Boolean(root.savedViewsData.available)
            && root.validSavedViewKey(viewKey)
            && root.savedViewNameDraft.trim().length > 0
            && !root.commandBusy(
                "content.saved_view.upsert", "content_saved_view", viewKey)
    }

    function updateStageDraftValid() {
        const target = String(root.updateStageDraft || "")
        return root.canWrite && Boolean(root.selectedContentId)
            && root.selectedContentVersion > 0
            && ["idea", "writing", "ready_production"].indexOf(target) >= 0
            && !root.selectedContentUpdateBusy
    }

    function bulkPreviewDraftValid() {
        const operation = String(root.bulkOperationDraft || "")
        if (!root.bulkAvailable || root.bulkSelectionCount < 1 || root.bulkBusy
                || !root.bulkOperationAvailable(operation))
            return false
        if (operation === "assign_campaign")
            return root.bulkCampaignIdDraft.trim().length > 0
        if (operation === "change_stage")
            return ["idea", "writing", "ready_production"].indexOf(
                String(root.bulkTargetStageDraft || "")) >= 0
        return operation === "archive"
    }

    function createDraftValid() {
        return root.canWrite && root.createTitleDraft.trim().length > 0
            && root.channelOptionExists(root.createChannelId)
            && root.campaignBelongsToChannel(
                root.createCampaignId, root.createChannelId)
            && !root.createBusy
            && Boolean(((root.headerData.actions || {}).create || {}).enabled)
    }

    function packageDraftValid() {
        const selection = root.selectionData || ({})
        const content = selection.content || ({})
        const assets = selection.related_assets || []
        const channel = content.channel || ({})
        if (!root.canWrite || root.packageBusy
                || !Boolean(((selection.actions || {}).create_package || {}).enabled)
                || !content.id || !channel.id || !root.packageAssetId)
            return false
        for (let index = 0; index < assets.length; index++) {
            if (String((assets[index] || {}).id || "") === root.packageAssetId)
                return true
        }
        return false
    }

    function savedViewQuery() {
        const query = root.snapshotQuery({"selected_content_id": ""})
        delete query.cursor
        delete query.selected_content_id
        return query
    }

    function applySavedView(viewKey) {
        if (!root.canRead || !Boolean(root.savedViewsData.available)) return false
        const saved = root.savedViewForKey(viewKey)
        if (!saved.view_key) return false
        const query = saved.query || ({})
        root.selectedSavedViewKey = String(saved.view_key)
        root.activeTab = String(query.tab || "library")
        root.searchText = String(query.search || "")
        root.channelFilter = String(query.channel_id || "")
        root.campaignFilter = String(query.campaign_id || "")
        root.stageFilter = String(query.stage || "")
        root.formatFilter = String(query.format || "")
        root.languageFilter = String(query.language || "")
        root.viewMode = String(query.view || "list")
        root.sortMode = String(query.sort || "updated_desc")
        root.includeArchived = Boolean(query.include_archived)
        // The desktop table is a paginated surface, not a nested scrolling
        // document. Saved views keep their filters but use the visible row
        // capacity of this workspace.
        root.pageSize = 5
        return root.requestSnapshot({"cursor": ""})
    }

    function prepareSavedViewUpsert() {
        if (!root.canWrite || !Boolean(root.savedViewsData.available)) return false
        const saved = root.savedViewForKey(root.selectedSavedViewKey)
        root.savedViewKeyDraft = String(saved.view_key || "")
        root.savedViewNameDraft = String(saved.name || "")
        savedViewDialog.open()
        return true
    }

    function confirmSavedViewUpsert() {
        const viewKey = root.savedViewKeyDraft.trim()
        const name = root.savedViewNameDraft.trim()
        if (!root.savedViewDraftValid()) return false
        const saved = root.savedViewForKey(viewKey)
        const payload = {
            "view_key": viewKey,
            "name": name,
            "query": root.savedViewQuery()
        }
        const version = saved.version
        if (Number(version || 0) > 0) payload.expected_version = version
        root.plane.callTool("content.saved_view.upsert", payload)
        root.selectedSavedViewKey = viewKey
        return true
    }

    function contentVersion(contentId) {
        const item = root.contentForId(contentId) || ({})
        return Number(item.version || 0)
    }

    function isBulkSelected(contentId) {
        const revision = root.bulkSelectionRevision
        return Boolean((root.bulkSelection || ({}))[String(contentId || "")])
    }

    function toggleBulkSelection(item) {
        const row = item || ({})
        const contentId = String(row.id || "")
        const version = row.version
        if (!root.bulkAvailable || !contentId || Number(version || 0) < 1)
            return false
        const next = Object.assign({}, root.bulkSelection || ({}))
        if (next[contentId]) {
            delete next[contentId]
        } else {
            next[contentId] = {
                "content_id": contentId,
                "version": version,
                "title": String(row.title || "Nội dung")
            }
        }
        root.bulkSelection = next
        root.bulkSelectionRevision += 1
        root.bulkBatch = ({})
        root.bulkPreviewIdempotencyKey = ""
        root.bulkExecuteIdempotencyKey = ""
        return true
    }

    function clearBulkSelection() {
        root.bulkSelection = ({})
        root.bulkSelectionRevision += 1
        root.bulkBatch = ({})
        root.bulkPreviewIdempotencyKey = ""
        root.bulkExecuteIdempotencyKey = ""
        return true
    }

    function selectVisibleBulkItems() {
        if (!root.bulkAvailable) return false
        const next = Object.assign({}, root.bulkSelection || ({}))
        let selected = 0
        for (let index = 0; index < root.inventoryModel.count; index++) {
            const row = root.inventoryModel.get(index) || ({})
            const contentId = String(row.id || "")
            const version = row.version
            if (!contentId || Number(version || 0) < 1) continue
            next[contentId] = {
                "content_id": contentId,
                "version": version,
                "title": String(row.title || "Nội dung")
            }
            selected += 1
        }
        if (selected < 1) return false
        root.bulkSelection = next
        root.bulkSelectionRevision += 1
        root.bulkBatch = ({})
        return true
    }

    function selectedBulkTargets() {
        const revision = root.bulkSelectionRevision
        const selection = root.bulkSelection || ({})
        const ids = Object.keys(selection).sort()
        const targets = []
        for (let index = 0; index < ids.length; index++) {
            const selected = selection[ids[index]] || ({})
            if (selected.content_id && Number(selected.version || 0) > 0) {
                targets.push({
                    "content_id": String(selected.content_id),
                    "version": selected.version
                })
            }
        }
        return targets
    }

    function countStaleBulkTargets() {
        const revision = root.bulkSelectionRevision + root.selectionRevision
        const targets = root.selectedBulkTargets()
        let stale = 0
        for (let index = 0; index < targets.length; index++) {
            const target = targets[index]
            const projected = root.contentForId(target.content_id) || ({})
            if (projected.id && Number(projected.version || 0) !== Number(target.version))
                stale += 1
        }
        return stale
    }

    function bulkIdentity() {
        const targets = root.selectedBulkTargets()
        const parts = []
        for (let index = 0; index < targets.length; index++)
            parts.push(targets[index].content_id + "@" + targets[index].version)
        return parts.join(",") || "none"
    }

    function bulkCommandBusy() {
        const revision = root.commandRevision + root.bulkSelectionRevision
        if (root.plane.commandStore.isBusy(
                "content.bulk.preview", "content_bulk", root.bulkIdentity()))
            return true
        const batchId = String((root.bulkBatch || {}).id || "")
        if (batchId && root.plane.commandStore.isBusy(
                "content.bulk.execute", "content_bulk_batch", batchId))
            return true
        const targets = root.selectedBulkTargets()
        for (let index = 0; index < targets.length; index++) {
            if (root.plane.commandStore.isBusy(
                    "content.update", "content", targets[index].content_id))
                return true
        }
        return false
    }

    function bulkOperationAvailable(operation) {
        const key = String(operation || "")
        if (["assign_campaign", "change_stage", "archive"].indexOf(key) < 0)
            return false
        const operations = root.bulkActionData.operations || []
        for (let index = 0; index < operations.length; index++) {
            const projected = operations[index] || ({})
            if (String(projected.key || "") === key)
                return Boolean(projected.available)
        }
        return false
    }

    function resolveViewState() {
        const snapshot = root.contentSnapshot || ({})
        const error = root.snapshotError || ({})
        const hasSnapshot = String(snapshot.snapshot_id || "").length > 0
        const errorCode = String(error.code || "").toUpperCase()
        if (!hasSnapshot) {
            if (errorCode === "PERMISSION_DENIED" || errorCode === "FORBIDDEN")
                return "permission"
            return errorCode.length > 0 ? "error" : "loading"
        }
        if (!root.canRead)
            return "permission"
        if (errorCode === "NETWORK_ERROR" || errorCode === "OFFLINE")
            return "offline"
        if (errorCode.length > 0)
            return "error"
        const state = String((snapshot.freshness || {}).state || "fresh").toLowerCase()
        if (state === "partial" || state === "stale")
            return state
        return root.hasProjectionData ? "content" : "empty"
    }

    function snapshotErrorText() {
        const code = String((root.snapshotError || {}).code || "CONTENT_SNAPSHOT_FAILED")
            .trim().toUpperCase()
        if (code === "NETWORK_ERROR" || code === "OFFLINE")
            return "Không thể kết nối Control Plane. Hãy kiểm tra kết nối và thử lại."
        if (code === "PERMISSION_DENIED" || code === "FORBIDDEN")
            return "Tài khoản hiện tại không có quyền đọc không gian nội dung."
        return "Không thể tải không gian nội dung (" + code
            + "). Chi tiết kỹ thuật đã được giữ khỏi giao diện operator."
    }

    function reloadSnapshot() {
        root.contentSnapshot = root.plane.snapshotStore.snapshot("content")
        root.snapshotError = root.plane.snapshotStore.error("content")
        root.selectionRevision += 1
        const inventory = root.snapshotData.inventory || ({})
        if (inventory.tab)
            root.activeTab = String(inventory.tab)
        if (inventory.view) {
            root.viewMode = String(inventory.view)
            if (String(inventory.entity_type || "content") === "content")
                root.contentViewMode = root.viewMode
        }
        root.reconcileSavedViewSelection(
            ((root.contentSnapshot || {}).data || {}).saved_views || ({})
        )
        const previousId = root.selectedContentId
        root.reconcileSelection()
        root.requestMissingSelectionProjection(previousId)
    }

    function contentForId(contentId) {
        const identity = String(contentId || "")
        for (let index = 0; index < root.inventoryModel.count; index++) {
            const item = root.inventoryModel.get(index)
            if (String(item.id || "") === identity)
                return item
        }
        const projected = root.rawSelection.content || ({})
        return String(projected.id || "") === identity ? projected : ({})
    }

    function inventoryEntityForId(entityId) {
        const identity = String(entityId || "")
        for (let index = 0; index < root.inventoryModel.count; index++) {
            const item = root.inventoryModel.get(index) || ({})
            if (String(item.id || "") === identity)
                return item
        }
        return ({})
    }

    function reconcileSelection() {
        const selection = root.plane.entitySelection.current || ({})
        const entity = selection.entity || ({})
        if (String(selection.route || "") === "content"
                && String(entity.type || "") === "content") {
            const linkedId = String(entity.id || "")
            if (linkedId) {
                root.selectedContentId = linkedId
                root.selectedInventoryEntityId = linkedId
                return
            }
        }
        if (String(selection.route || "") === "content"
                && String(entity.type || "") === "campaign") {
            const linkedId = String(entity.id || "")
            const context = selection.context || ({})
            if (!linkedId) return
            root.selectedContentId = ""
            root.selectedInventoryEntityId = linkedId
            root.activeTab = "campaigns"
            root.channelFilter = String(context.channel_id || "")
            root.searchText = String(context.search || "")
            if (String(root.inventoryData.entity_type || "") !== "campaign"
                    || !root.inventoryEntityForId(linkedId).id) {
                root.requestSnapshot({
                    "tab": "campaigns",
                    "channel_id": root.channelFilter,
                    "search": root.searchText,
                    "cursor": ""
                })
            }
            return
        }
        if (root.selectedContentId && root.contentForId(root.selectedContentId).id)
            return
        const projectedId = String((root.rawSelection.content || {}).id || "")
        if (projectedId) {
            root.selectedContentId = projectedId
            return
        }
        const contentEntity = String(root.inventoryData.entity_type || "") === "content"
        root.selectedContentId = contentEntity && root.inventoryModel.count > 0
            ? String(root.inventoryModel.get(0).id || "") : ""
        root.selectedInventoryEntityId = root.selectedContentId
    }

    function requestMissingSelectionProjection(previousId) {
        const projectedId = String((root.rawSelection.content || {}).id || "")
        const contentEntity = String(root.inventoryData.entity_type || "") === "content"
        if (!contentEntity || !root.selectedContentId
                || projectedId === root.selectedContentId
                || String(previousId || "") === root.selectedContentId)
            return false
        return root.requestSnapshot({"selected_content_id": root.selectedContentId})
    }

    function snapshotQuery(overrides) {
        const extra = overrides || ({})
        const tab = extra.tab !== undefined ? String(extra.tab) : root.activeTab
        const query = {
            "tab": tab,
            "view": extra.view !== undefined ? String(extra.view) : root.viewMode,
            "sort": extra.sort !== undefined ? String(extra.sort) : root.sortMode,
            "include_archived": extra.include_archived !== undefined
                ? Boolean(extra.include_archived) : root.includeArchived,
            "limit": extra.limit !== undefined ? extra.limit : root.pageSize
        }
        const search = extra.search !== undefined ? String(extra.search).trim() : root.searchText.trim()
        const channel = extra.channel_id !== undefined ? String(extra.channel_id) : root.channelFilter
        const campaign = extra.campaign_id !== undefined ? String(extra.campaign_id) : root.campaignFilter
        const stage = extra.stage !== undefined ? String(extra.stage) : root.stageFilter
        const format = extra.format !== undefined ? String(extra.format) : root.formatFilter
        const language = extra.language !== undefined ? String(extra.language) : root.languageFilter
        const selectedId = extra.selected_content_id !== undefined
            ? String(extra.selected_content_id) : root.selectedContentId
        if (search) query.search = search
        if (channel) query.channel_id = channel
        if (campaign) query.campaign_id = campaign
        if (stage) query.stage = stage
        if (format) query.format = format
        if (language) query.language = language
        if ((tab === "library" || tab === "ideas") && selectedId)
            query.selected_content_id = selectedId
        if (extra.cursor !== undefined && extra.cursor !== null && String(extra.cursor))
            query.cursor = String(extra.cursor)
        return query
    }

    function requestSnapshot(overrides) {
        if (!root.canRead) return false
        root.plane.callTool("content.workspace.snapshot", root.snapshotQuery(overrides))
        return true
    }

    function loadInitialSnapshot() {
        root.reloadSnapshot()
        if (String((root.contentSnapshot || {}).snapshot_id || "")) return true
        if (!root.plane || !root.plane.refreshSnapshotTool) return false
        return root.plane.refreshSnapshotTool("content.workspace.snapshot")
    }

    function applyFilters() {
        return root.requestSnapshot({"cursor": ""})
    }

    function nextPage() {
        const cursor = String(root.inventoryData.next_cursor
            || root.snapshotPage.next_cursor || "")
        if (!cursor) return false
        return root.requestSnapshot({"cursor": cursor})
    }

    function previousPage() {
        const cursor = Number(root.inventoryData.cursor || root.snapshotPage.cursor || 0)
        if (cursor <= 0) return false
        const previous = Math.max(0, cursor - root.pageSize)
        return root.requestSnapshot({"cursor": previous > 0 ? String(previous) : ""})
    }

    function setTab(tab) {
        const next = String(tab || "")
        if (["library", "campaigns", "ideas", "packages", "assets"].indexOf(next) < 0)
            return false
        root.activeTab = next
        const contentTab = next === "library" || next === "ideas"
        const targetView = contentTab ? root.contentViewMode : "grid"
        root.viewMode = targetView
        root.selectedInventoryEntityId = ""
        if (!contentTab) {
            root.selectedContentId = ""
            root.inspectorVisible = false
        } else {
            root.inspectorVisible = true
        }
        return root.requestSnapshot({"tab": next, "view": targetView, "cursor": ""})
    }

    function setPage(pageNumber) {
        const target = Math.max(1, Number(pageNumber || 1))
        const total = Math.max(0, Number(root.inventoryData.total || 0))
        const pageCount = Math.max(1, Math.ceil(total / Math.max(1, root.pageSize)))
        if (target > pageCount) return false
        const cursor = (target - 1) * root.pageSize
        return root.requestSnapshot({"cursor": cursor > 0 ? String(cursor) : ""})
    }

    function setSearch(value) {
        root.searchText = String(value || "").trim()
        return root.applyFilters()
    }

    function setChannel(value) {
        root.channelFilter = String(value || "")
        return root.applyFilters()
    }

    function setCampaign(value) {
        root.campaignFilter = String(value || "")
        return root.applyFilters()
    }

    function setStage(value) {
        root.stageFilter = String(value || "")
        return root.applyFilters()
    }

    function setFormat(value) {
        root.formatFilter = String(value || "")
        return root.applyFilters()
    }

    function setLanguage(value) {
        root.languageFilter = String(value || "")
        return root.applyFilters()
    }

    function setView(value) {
        const next = String(value || "")
        if (["list", "grid"].indexOf(next) < 0) return false
        root.viewMode = next
        if (root.activeTab === "library" || root.activeTab === "ideas")
            root.contentViewMode = next
        return root.applyFilters()
    }

    function openDeepLink(link) {
        const projected = link || ({})
        const entity = projected.entity || ({})
        const route = String(projected.route || "")
        if (!route || !entity.type || !entity.id)
            return false
        root.plane.navigateEntity(
            route,
            String(entity.type),
            String(entity.id),
            projected.context || ({})
        )
        return true
    }

    function selectInventoryItem(item) {
        const row = item || ({})
        const entityId = String(row.id || "")
        if (!entityId) return false
        const contentEntity = String(root.inventoryData.entity_type || "") === "content"
        if (!contentEntity) {
            root.selectedInventoryEntityId = entityId
            root.openDeepLink(row.deep_link || ({}))
            return true
        }
        root.selectedContentId = entityId
        root.inspectorVisible = true
        root.selectedInventoryEntityId = entityId
        root.selectionRevision += 1
        root.openDeepLink(row.deep_link || ({}))
        return root.requestSnapshot({"selected_content_id": entityId})
    }

    function commandBusy(capability, entityType, entityId) {
        const revision = root.commandRevision
        return root.plane.commandStore.isBusy(
            String(capability || ""),
            String(entityType || "global"),
            String(entityId || "global")
        )
    }

    function idempotencyKey(capability, entityId) {
        root.commandSequence += 1
        return "qml-content:" + String(capability || "command") + ":"
            + String(entityId || "global").slice(0, 72) + ":"
            + String(Date.now()) + ":" + String(root.commandSequence)
    }

    function prepareUpdateStage() {
        if (!root.canWrite || !root.selectedContentId
                || root.selectedContentVersion < 1
                || root.selectedContentUpdateBusy)
            return false
        const currentStage = String(((root.selectionData.content || {}).stage || {}).key || "")
        root.updateStageDraft = ["idea", "writing", "ready_production"]
            .indexOf(currentStage) >= 0 ? currentStage : "writing"
        updateStageDialog.open()
        return true
    }

    function confirmUpdateStage() {
        const target = String(root.updateStageDraft || "")
        if (!root.updateStageDraftValid()) return false
        root.plane.callTool("content.update", {
            "content_id": root.selectedContentId,
            "expected_version": root.selectedContentVersion,
            "target_stage": target
        })
        return true
    }

    function prepareArchiveContent() {
        if (!root.canWrite || !root.selectedContentId
                || root.selectedContentVersion < 1
                || root.selectedContentUpdateBusy)
            return false
        archiveDialog.open()
        return true
    }

    function confirmArchiveContent() {
        if (!root.canWrite || !root.selectedContentId
                || root.selectedContentVersion < 1
                || root.selectedContentUpdateBusy)
            return false
        root.plane.callTool("content.update", {
            "content_id": root.selectedContentId,
            "expected_version": root.selectedContentVersion,
            "target_stage": "archived"
        })
        return true
    }

    function prepareBulkOperation(operation) {
        const next = String(operation || "")
        if (!root.bulkAvailable || root.bulkSelectionCount < 1 || root.bulkBusy
                || !root.bulkOperationAvailable(next))
            return false
        root.bulkOperationDraft = next
        if (next === "assign_campaign" && !root.bulkCampaignIdDraft) {
            const campaigns = root.filterData.campaigns || []
            root.bulkCampaignIdDraft = campaigns.length > 0
                ? String((campaigns[0] || {}).id || "") : ""
        }
        if (next === "change_stage"
                && ["idea", "writing", "ready_production"]
                    .indexOf(root.bulkTargetStageDraft) < 0)
            root.bulkTargetStageDraft = "writing"
        root.bulkPreviewIdempotencyKey = root.idempotencyKey(
            "content.bulk.preview", next + ":" + root.bulkIdentity()
        )
        root.bulkExecuteIdempotencyKey = ""
        root.bulkBatch = ({})
        root.bulkMessage = ""
        bulkParametersDialog.open()
        return true
    }

    function prepareBulkPreview() {
        return root.prepareBulkOperation(root.bulkOperationDraft)
    }

    function confirmBulkPreview() {
        const operation = String(root.bulkOperationDraft || "")
        const targets = root.selectedBulkTargets()
        if (!root.bulkPreviewDraftValid() || targets.length < 1) return false
        const payload = {
            "operation": operation,
            "targets": targets,
            "idempotency_key": root.bulkPreviewIdempotencyKey
                || root.idempotencyKey(
                    "content.bulk.preview", operation + ":" + root.bulkIdentity()
                )
        }
        root.bulkPreviewIdempotencyKey = String(payload.idempotency_key)
        if (operation === "assign_campaign") {
            const campaignId = root.bulkCampaignIdDraft.trim()
            if (!campaignId) return false
            payload.campaign_id = campaignId
        } else if (operation === "change_stage") {
            const target = String(root.bulkTargetStageDraft || "")
            if (["idea", "writing", "ready_production"].indexOf(target) < 0)
                return false
            payload.target_stage = target
        }
        root.bulkMessage = ""
        root.plane.callTool("content.bulk.preview", payload)
        return true
    }

    function confirmBulkExecute() {
        const batch = root.bulkBatch || ({})
        const batchId = String(batch.id || "")
        if (!root.bulkAvailable || !batchId
                || String(batch.state || "") !== "previewed"
                || Number(batch.eligible_count || 0) < 1
                || root.bulkBusy)
            return false
        if (!root.bulkExecuteIdempotencyKey) {
            root.bulkExecuteIdempotencyKey = root.idempotencyKey(
                "content.bulk.execute", batchId
            )
        }
        root.plane.callTool("content.bulk.execute", {
            "batch_id": batchId,
            "idempotency_key": root.bulkExecuteIdempotencyKey
        })
        return true
    }

    function prepareCreateContent() {
        if (!root.canWrite || !Boolean(((root.headerData.actions || {}).create || {}).enabled))
            return false
        const channels = root.filterData.channels || []
        if (!root.createChannelId && channels.length > 0)
            root.setCreateChannel(String((channels[0] || {}).id || ""))
        if (!root.campaignBelongsToChannel(
                root.createCampaignId, root.createChannelId))
            root.createCampaignId = ""
        createDialog.open()
        return true
    }

    function confirmCreateContent() {
        const title = root.createTitleDraft.trim()
        if (!root.createDraftValid()) return false
        const payload = {
            "title": title,
            "channel_id": root.createChannelId,
            "status": "idea",
            "source_type": "operator_ui",
            "inputs": {"surface": "content_workspace"}
        }
        if (root.createCampaignId)
            payload.campaign_id = root.createCampaignId
        root.plane.callTool("content.create", payload)
        root.createTitleDraft = ""
        return true
    }

    function prepareImportResource() {
        if (!root.canWrite || root.importBusy
                || !Boolean(((root.headerData.actions || {}).import || {}).enabled))
            return false
        resourceDialog.open()
        return true
    }

    function confirmImportResource() {
        const path = root.importPathDraft.trim()
        if (!root.canWrite || !path || root.importBusy
                || !Boolean(((root.headerData.actions || {}).import || {}).enabled))
            return false
        root.plane.callTool("asset.register.local", {
            "path": path,
            "provider": "native_operator",
            "provenance": {"surface": "content_workspace"}
        })
        root.importPathDraft = ""
        return true
    }

    function prepareCreatePackage() {
        if (!root.canWrite || root.packageBusy
                || !Boolean(((root.selectionData.actions || {}).create_package || {}).enabled))
            return false
        const assets = root.selectionData.related_assets || []
        const content = root.selectionData.content || ({})
        if (assets.length === 0 || !content.id || !(content.channel || {}).id)
            return false
        let projected = false
        for (let index = 0; index < assets.length; index++) {
            if (String((assets[index] || {}).id || "") === root.packageAssetId) {
                projected = true
                break
            }
        }
        if (!projected)
            root.packageAssetId = String((assets[0] || {}).id || "")
        packageDialog.open()
        return true
    }

    function openSelectedContentSchedule() {
        if (!root.canWrite || !root.selectedContentId
                || !root.isBulkSelected(root.selectedContentId)
                || root.bulkSelectionCount !== 1)
            return false
        root.plane.navigateEntity(
            "schedule",
            "content",
            root.selectedContentId,
            {"source": "content", "action": "schedule"}
        )
        return true
    }

    function confirmCreatePackage() {
        const selection = root.selectionData || ({})
        const content = selection.content || ({})
        const assets = selection.related_assets || []
        const channel = content.channel || ({})
        if (!root.packageDraftValid()) return false
        let asset = ({})
        for (let index = 0; index < assets.length; index++) {
            const candidate = assets[index] || ({})
            if (!root.packageAssetId || String(candidate.id || "") === root.packageAssetId) {
                asset = candidate
                break
            }
        }
        if (!asset.id) return false
        root.plane.callTool("content.package.create", {
            "asset_id": String(asset.id),
            "content_id": String(content.id),
            "channel_id": String(channel.id),
            "platform": String(channel.platform || ""),
            "title": String(content.title || "Nội dung"),
            "idempotency_key": root.idempotencyKey(
                "content.package.create", String(content.id) + ":" + String(asset.id)
            )
        })
        return true
    }

    function prepareDeleteContent() {
        if (!root.canWrite || !root.selectedContentId || root.deleteBusy)
            return false
        deleteDialog.open()
        return true
    }

    function confirmDeleteContent() {
        if (!root.canWrite || !root.selectedContentId || root.deleteBusy)
            return false
        root.plane.callTool("content.delete", {"content_id": root.selectedContentId})
        return true
    }

    Component.onCompleted: root.loadInitialSnapshot()

    Connections {
        target: root.plane.snapshotStore
        function onChanged(route) {
            if (route === "content") root.reloadSnapshot()
        }
    }

    Connections {
        target: root.plane.entitySelection
        function onSelectionChanged() {
            root.selectionRevision += 1
            const previousId = root.selectedContentId
            root.reconcileSelection()
            root.requestMissingSelectionProjection(previousId)
        }
    }

    Connections {
        target: root.plane.commandStore
        function onChanged(capability, entityType, entityId) {
            root.commandRevision += 1
        }
    }

    Connections {
        target: root.plane
        function onActionFinished(toolName, ok, data, message) {
            const capability = String(toolName || "")
            if (capability === "content.saved_view.upsert") {
                if (ok) {
                    savedViewDialog.close()
                    root.requestSnapshot({"cursor": ""})
                }
                return
            }
            if (capability === "content.update") {
                if (ok) {
                    updateStageDialog.close()
                    archiveDialog.close()
                    root.requestSnapshot({
                        "selected_content_id": root.selectedContentId,
                        "cursor": ""
                    })
                }
                return
            }
            if (capability === "content.bulk.preview") {
                if (!ok) {
                    root.bulkMessage = "Không thể tạo bản xem trước. Dữ liệu chưa được thay đổi."
                    return
                }
                const previewBatch = (data || {}).batch || ({})
                if (!previewBatch.id) return
                root.bulkBatch = previewBatch
                root.bulkExecuteIdempotencyKey = ""
                root.bulkMessage = ""
                bulkParametersDialog.close()
                bulkResultDialog.open()
                return
            }
            if (capability !== "content.bulk.execute") return
            if (!ok) {
                root.bulkMessage = "Không thể thực thi batch. Có thể thử lại cùng idempotency key."
                return
            }
            const executedBatch = (data || {}).batch || ({})
            if (executedBatch.id)
                root.bulkBatch = executedBatch
            root.bulkMessage = ""
            root.requestSnapshot({"cursor": ""})
        }
    }

    Foundation.AsyncStateView {
        anchors.fill: parent
        anchors.margins: Theme.pageGutter
        viewState: root.viewState
        hasData: root.hasProjectionData
        accessibleName: "Không gian nội dung"
        emptyTitle: "Kho nội dung đang trống"
        emptyDescription: "Tạo nội dung đầu tiên hoặc nhập tài nguyên cục bộ đã được xác minh."
        emptyIconName: "semantic/video"
        emptyEyebrow: "BẮT ĐẦU TỪ NGUỒN NỘI DUNG"
        emptyGuidance: [
                {"title": "Tạo nội dung", "description": "Ghi mục tiêu, kênh và chủ đề"},
            {"title": "Thêm video", "description": "Nhập file nguồn đã xác minh"},
            {"title": "Sẵn sàng Studio", "description": "Đủ nguồn rồi mới tạo gói sản xuất"}
        ]
        emptyActionText: "Tạo nội dung"
        emptyActionIconName: "ui/plus"
        emptyActionEnabled: root.canWrite
            && Boolean(((root.headerData.actions || {}).create || {}).enabled)
        emptyActionReason: !root.canWrite ? "Thiếu quyền content.write"
            : String(((root.headerData.actions || {}).create || {}).reason_code || "CONTENT_CREATE_UNAVAILABLE")
        emptySecondaryActionText: "Nhập tài nguyên"
        emptySecondaryActionIconName: "semantic/upload-cloud"
        emptySecondaryActionEnabled: root.canWrite && !root.importBusy
            && Boolean(((root.headerData.actions || {}).import || {}).enabled)
        emptySecondaryActionReason: !root.canWrite ? "Thiếu quyền content.write"
            : String(((root.headerData.actions || {}).import || {}).reason_code || "CONTENT_IMPORT_UNAVAILABLE")
        onEmptyAction: root.prepareCreateContent()
        onEmptySecondaryAction: root.prepareImportResource()
        errorMessage: root.snapshotErrorText()
        requiredPermission: "content.read"
        onRetry: root.requestSnapshot({})

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Content.ContentHeader {
                Layout.fillWidth: true
                Layout.preferredHeight: 83
                Layout.minimumHeight: 83
                Layout.maximumHeight: 83
                headerData: root.headerData
                canWrite: root.canWrite
                createBusy: root.createBusy
                importBusy: root.importBusy
                onCreateRequested: root.prepareCreateContent()
                onImportRequested: root.prepareImportResource()
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.rightMargin: 3
                spacing: 14

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 16
                    Content.ContentInventory {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        lifecycle: root.lifecycleData
                        filters: root.filterData
                        inventory: root.inventoryData
                        inventoryModel: root.inventoryModel
                        controlPlaneBridge: root.plane
                        dataRevision: root.selectionRevision
                        selectedContentId: root.selectedContentId
                        selectedEntityId: root.selectedInventoryEntityId
                        activeTab: root.activeTab
                        searchText: root.searchText
                        channelFilter: root.channelFilter
                        campaignFilter: root.campaignFilter
                        stageFilter: root.stageFilter
                        formatFilter: root.formatFilter
                        languageFilter: root.languageFilter
                        viewMode: root.viewMode
                        pageSize: root.pageSize
                        canWrite: root.canWrite
                        savedViews: root.savedViewsData
                        selectedSavedViewKey: root.selectedSavedViewKey
                        savedViewBusy: root.savedViewBusy
                        bulkSelection: root.bulkSelection
                        bulkSelectionRevision: root.bulkSelectionRevision
                        bulkSelectionCount: root.bulkSelectionCount
                        bulkStaleCount: root.bulkStaleCount
                        bulkEnabled: root.bulkAvailable
                        bulkBusy: root.bulkBusy
                        bulkAvailabilityReason: String(
                            root.bulkActionData.reason_code || ""
                        )
                        onTabRequested: tab => root.setTab(tab)
                        onSearchRequested: value => root.setSearch(value)
                        onChannelRequested: value => root.setChannel(value)
                        onCampaignRequested: value => root.setCampaign(value)
                        onStageRequested: value => root.setStage(value)
                        onFormatRequested: value => root.setFormat(value)
                        onLanguageRequested: value => root.setLanguage(value)
                        onViewRequested: value => root.setView(value)
                        onSavedViewRequested: viewKey => root.applySavedView(viewKey)
                        onSavedViewSaveRequested: root.prepareSavedViewUpsert()
                        onItemRequested: item => root.selectInventoryItem(item)
                        onItemSelectionRequested: item => root.toggleBulkSelection(item)
                        onSelectVisibleRequested: root.selectVisibleBulkItems()
                        onClearSelectionRequested: root.clearBulkSelection()
                        onBulkOperationRequested: operation => root.prepareBulkOperation(operation)
                        onCreatePackageRequested: root.prepareCreatePackage()
                        onScheduleRequested: root.openSelectedContentSchedule()
                        onNextPageRequested: root.nextPage()
                        onPreviousPageRequested: root.previousPage()
                        onPageRequested: pageNumber => root.setPage(pageNumber)
                    }

                    Content.ReuseStrip {
                        visible: root.activeTab === "library" || root.activeTab === "ideas"
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? 168 : 0
                        Layout.minimumHeight: visible ? 168 : 0
                        Layout.maximumHeight: visible ? 168 : 0
                        reuseData: root.reuseData
                        reuseModel: root.reuseModel
                        controlPlaneBridge: root.plane
                        onItemRequested: item => root.openDeepLink((item || {}).deep_link || ({}))
                    }
                }

                Content.ContentInspector {
                    Layout.preferredWidth: root.inspectorVisible ? 390 : 0
                    Layout.fillHeight: true
                    visible: root.inspectorVisible
                    selection: root.selectionData
                    historyData: root.historyData
                    historyModel: root.historyModel
                    controlPlaneBridge: root.plane
                    canWrite: root.canWrite
                    packageBusy: root.packageBusy
                    deleteBusy: root.deleteBusy
                    updateBusy: root.selectedContentUpdateBusy
                    onOpenDeepLink: link => root.openDeepLink(link)
                    onPackageRequested: root.prepareCreatePackage()
                    onUpdateStageRequested: root.prepareUpdateStage()
                    onArchiveRequested: root.prepareArchiveContent()
                    onDeleteRequested: root.prepareDeleteContent()
                    onCloseRequested: root.inspectorVisible = false
                }
            }
        }
    }

    Content.ContentDialog {
        id: savedViewDialog
        objectName: "contentSavedViewDialog"
        anchors.centerIn: parent
        modal: true
        width: 500
        title: root.savedViewForKey(root.selectedSavedViewKey).view_key
            ? "Cập nhật góc nhìn đã lưu" : "Lưu góc nhìn hiện tại"
        acceptText: "Lưu góc nhìn"
        acceptEnabled: root.savedViewDraftValid()
        onAccepted: root.confirmSavedViewUpsert()
        contentItem: ColumnLayout {
            spacing: 10
            Content.ContentTextField {
                objectName: "contentSavedViewKeyField"
                activeFocusOnTab: true
                Layout.fillWidth: true
                text: root.savedViewKeyDraft
                readOnly: Boolean(root.savedViewForKey(root.selectedSavedViewKey).view_key)
                placeholderText: "Mã góc nhìn, ví dụ ready-short-video"
                Accessible.name: "Mã góc nhìn đã lưu"
                onTextChanged: root.savedViewKeyDraft = text.trim()
            }
            Content.ContentTextField {
                objectName: "contentSavedViewNameField"
                activeFocusOnTab: true
                Layout.fillWidth: true
                text: root.savedViewNameDraft
                placeholderText: "Tên hiển thị"
                Accessible.name: "Tên góc nhìn đã lưu"
                onTextChanged: root.savedViewNameDraft = text
            }
            Text {
                Layout.fillWidth: true
                text: "Lưu bộ lọc, tab, kiểu hiển thị và sắp xếp hiện tại. Cursor và mục đang chọn không được lưu."
                color: Theme.textFaint
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
        }
        background: Rectangle {
            radius: Theme.radiusLarge
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }

    Content.ContentDialog {
        id: updateStageDialog
        objectName: "contentUpdateStageDialog"
        anchors.centerIn: parent
        modal: true
        width: 440
        title: "Đổi giai đoạn nội dung"
        acceptText: "Lưu thay đổi"
        acceptEnabled: root.updateStageDraftValid()
        onAccepted: root.confirmUpdateStage()
        contentItem: ColumnLayout {
            spacing: 10
            Content.ContentComboBox {
                objectName: "contentUpdateStageCombo"
                activeFocusOnTab: true
                Layout.fillWidth: true
                model: root.safeStageOptions
                textRole: "label"
                valueRole: "id"
                currentIndex: root.optionIndex(model, root.updateStageDraft)
                Accessible.name: "Giai đoạn đích"
                onActivated: root.updateStageDraft = String(currentValue || "")
            }
            Text {
                Layout.fillWidth: true
                text: "Cập nhật dùng expected_version " + String(root.selectedContentVersion)
                    + ". Nếu dữ liệu đã đổi, Control Plane sẽ từ chối thay vì ghi đè."
                color: Theme.textFaint
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
        }
        background: Rectangle {
            radius: Theme.radiusLarge
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }

    Foundation.ConfirmDialog {
        id: archiveDialog
        objectName: "contentArchiveConfirmDialog"
        title: "Lưu trữ nội dung"
        message: "Lưu trữ nội dung đang chọn theo đúng phiên bản hiện tại? Nội dung không bị xóa và có thể được truy vấn lại khi bật mục đã lưu trữ."
        confirmText: "Lưu trữ"
        destructive: true
        onAccepted: root.confirmArchiveContent()
    }

    Content.ContentDialog {
        id: bulkParametersDialog
        objectName: "contentBulkParametersDialog"
        anchors.centerIn: parent
        modal: true
        width: 520
        title: root.bulkOperationDraft === "assign_campaign"
            ? "Xem trước gán campaign"
            : root.bulkOperationDraft === "archive"
                ? "Xem trước lưu trữ hàng loạt"
                : "Xem trước đổi giai đoạn"
        acceptText: "Tạo bản xem trước"
        acceptEnabled: root.bulkPreviewDraftValid()
        onAccepted: root.confirmBulkPreview()
        contentItem: ColumnLayout {
            spacing: 10
            Text {
                Layout.fillWidth: true
                text: String(root.bulkSelectionCount) + " nội dung được khóa theo phiên bản đã chọn."
                color: Theme.textMuted
                font.pixelSize: 11
            }
            Content.ContentComboBox {
                objectName: "contentBulkCampaignCombo"
                activeFocusOnTab: true
                Layout.fillWidth: true
                visible: root.bulkOperationDraft === "assign_campaign"
                model: root.filterData.campaigns || []
                textRole: "label"
                valueRole: "id"
                currentIndex: root.optionIndex(model, root.bulkCampaignIdDraft)
                Accessible.name: "Campaign đích cho batch"
                onActivated: root.bulkCampaignIdDraft = String(currentValue || "")
            }
            Content.ContentComboBox {
                objectName: "contentBulkStageCombo"
                activeFocusOnTab: true
                Layout.fillWidth: true
                visible: root.bulkOperationDraft === "change_stage"
                model: root.safeStageOptions
                textRole: "label"
                valueRole: "id"
                currentIndex: root.optionIndex(model, root.bulkTargetStageDraft)
                Accessible.name: "Giai đoạn đích cho batch"
                onActivated: root.bulkTargetStageDraft = String(currentValue || "")
            }
            Text {
                Layout.fillWidth: true
                visible: root.bulkOperationDraft === "archive"
                text: "Batch chỉ lưu trữ; không có thao tác publish hoặc delete hàng loạt."
                color: Theme.warning
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                visible: root.bulkStaleCount > 0
                text: String(root.bulkStaleCount)
                    + " mục đã đổi phiên bản sau khi chọn. Preview server sẽ đánh dấu stale; UI không tự cập nhật CAS."
                color: Theme.warning
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                visible: root.bulkMessage.length > 0
                text: root.bulkMessage
                color: Theme.danger
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
        }
        background: Rectangle {
            radius: Theme.radiusLarge
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }

    Content.ContentDialog {
        id: bulkResultDialog
        objectName: "contentBulkResultDialog"
        anchors.centerIn: parent
        modal: true
        width: 640
        height: 520
        title: String((root.bulkBatch || {}).state || "previewed") === "previewed"
            ? "Xác nhận batch" : "Kết quả batch"
        showDefaultFooter: false
        closePolicy: Popup.NoAutoClose
        contentItem: ColumnLayout {
            spacing: 10
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Batch " + String((root.bulkBatch || {}).id || "—")
                    color: Theme.text
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }
                Foundation.StatusPill {
                    text: String((root.bulkBatch || {}).state || "—")
                    tone: String((root.bulkBatch || {}).state || "") === "completed"
                        ? Theme.success
                        : String((root.bulkBatch || {}).state || "") === "previewed"
                            ? Theme.info : Theme.warning
                }
            }
            Text {
                Layout.fillWidth: true
                text: "Hợp lệ " + String(Number((root.bulkBatch || {}).eligible_count || 0))
                    + " · thành công " + String(Number((root.bulkBatch || {}).succeeded_count || 0))
                    + " · lỗi " + String(Number((root.bulkBatch || {}).failed_count || 0))
                color: Theme.textMuted
                font.pixelSize: 11
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                ListView {
                    anchors.fill: parent
                    anchors.margins: 6
                    clip: true
                    spacing: 4
                    model: ((root.bulkBatch || {}).result_rows || []).length > 0
                        ? (root.bulkBatch || {}).result_rows
                        : (root.bulkBatch || {}).preview_rows || []
                    delegate: Rectangle {
                        id: bulkResultRow
                        required property var modelData
                        objectName: "contentBulkResult_"
                            + String(bulkResultRow.modelData.content_id || "unknown")
                        width: ListView.view.width
                        height: 48
                        radius: Theme.radiusSmall
                        color: Theme.panel
                        border.width: 1
                        border.color: Theme.borderSoft
                        Accessible.name: String(bulkResultRow.modelData.content_id || "Nội dung")
                            + " " + String(bulkResultRow.modelData.reason_code || "")
                        Accessible.role: Accessible.ListItem
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            Text {
                                Layout.fillWidth: true
                                text: String(bulkResultRow.modelData.content_id || "—")
                                color: Theme.text
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                            Text {
                                text: String(bulkResultRow.modelData.reason_code || "Sẵn sàng")
                                color: Boolean(bulkResultRow.modelData.eligible)
                                    || Boolean(bulkResultRow.modelData.succeeded)
                                    ? Theme.success : Theme.warning
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }
            Text {
                Layout.fillWidth: true
                visible: root.bulkMessage.length > 0
                text: root.bulkMessage
                color: Theme.danger
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
        }
        footer: Rectangle {
            implicitHeight: 54
            color: Theme.panel
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                Item { Layout.fillWidth: true }
                AppButton {
                    objectName: "contentBulkCloseButton"
                    text: "Đóng"
                    Accessible.name: "Đóng kết quả batch"
                    onClicked: bulkResultDialog.close()
                }
                AppButton {
                    objectName: "contentBulkExecuteButton"
                    visible: String((root.bulkBatch || {}).state || "") === "previewed"
                    text: root.bulkBusy ? "Đang thực thi..." : "Xác nhận thực thi"
                    primary: true
                    enabled: root.canWrite && !root.bulkBusy
                        && Number((root.bulkBatch || {}).eligible_count || 0) > 0
                    Accessible.name: "Xác nhận thực thi batch đã xem trước"
                    onClicked: root.confirmBulkExecute()
                }
            }
        }
        background: Rectangle {
            radius: Theme.radiusLarge
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }

    Content.ContentDialog {
        id: createDialog
        objectName: "contentCreateDialog"
        anchors.centerIn: parent
        modal: true
        width: 520
        title: "Tạo nội dung"
        acceptText: "Tạo nội dung"
        acceptEnabled: root.createDraftValid()
        onAccepted: root.confirmCreateContent()
        contentItem: ColumnLayout {
            spacing: 10
            Content.ContentTextField {
                objectName: "contentCreateTitleField"
                activeFocusOnTab: true
                Layout.fillWidth: true
                placeholderText: "Tiêu đề nội dung"
                text: root.createTitleDraft
                Accessible.name: "Tiêu đề nội dung"
                onTextChanged: root.createTitleDraft = text
            }
            Content.ContentComboBox {
                objectName: "contentCreateChannelCombo"
                activeFocusOnTab: true
                Layout.fillWidth: true
                model: root.filterData.channels || []
                textRole: "label"
                valueRole: "id"
                currentIndex: root.optionIndex(model, root.createChannelId)
                Accessible.name: "Kênh đích"
                onActivated: root.setCreateChannel(String(currentValue || ""))
            }
            Content.ContentComboBox {
                objectName: "contentCreateCampaignCombo"
                activeFocusOnTab: true
                Layout.fillWidth: true
                model: root.campaignOptions
                textRole: "label"
                valueRole: "id"
                currentIndex: root.optionIndex(model, root.createCampaignId)
                Accessible.name: "Campaign"
                onActivated: root.createCampaignId = String(currentValue || "")
            }
            Text {
                Layout.fillWidth: true
                text: "Nội dung được tạo ở giai đoạn Ý tưởng. Mọi thay đổi được audit bởi Control Plane."
                color: Theme.textFaint
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
        }
        background: Rectangle {
            radius: Theme.radiusLarge
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }

    FileDialog {
        id: resourceDialog
        title: "Chọn tài nguyên cục bộ"
        fileMode: FileDialog.OpenFile
        nameFilters: [
            "Media (*.mp4 *.mov *.mkv *.webm *.png *.jpg *.jpeg *.webp *.wav *.mp3 *.srt *.vtt)",
            "Tất cả file (*)"
        ]
        onAccepted: {
            root.importPathDraft = root.plane.localPath(selectedFile)
            importConfirmDialog.open()
        }
    }

    Foundation.ConfirmDialog {
        id: importConfirmDialog
        objectName: "contentImportConfirmDialog"
        title: "Nhập tài nguyên"
        message: "Đăng ký file đã chọn vào kho tài nguyên workspace? Backend sẽ xác minh metadata và QC; giao diện không tự giả định thumbnail hoặc độ tương thích."
        confirmText: "Nhập tài nguyên"
        onAccepted: root.confirmImportResource()
    }

    Content.ContentDialog {
        id: packageDialog
        objectName: "contentPackageConfirmDialog"
        anchors.centerIn: parent
        modal: true
        width: 500
        title: "Tạo gói sản xuất"
        acceptText: "Tạo gói"
        acceptEnabled: root.packageDraftValid()
        onAccepted: root.confirmCreatePackage()
        contentItem: ColumnLayout {
            spacing: 10
            Text {
                Layout.fillWidth: true
                text: "Chọn đúng tài nguyên đã được backend liên kết. Gói mới khóa một phiên bản; phiên bản cũ không bị sửa tại chỗ."
                color: Theme.textMuted
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            Content.ContentComboBox {
                objectName: "contentPackageAssetCombo"
                activeFocusOnTab: true
                Layout.fillWidth: true
                model: root.selectionData.related_assets || []
                textRole: "file_name"
                valueRole: "id"
                currentIndex: root.optionIndex(model, root.packageAssetId)
                Accessible.name: "Tài nguyên cho gói sản xuất"
                onActivated: root.packageAssetId = String(currentValue || "")
            }
            Text {
                Layout.fillWidth: true
                text: "Kênh: " + String(((root.selectionData.content || {}).channel || {}).name || "—")
                color: Theme.textFaint
                font.pixelSize: 11
            }
        }
        background: Rectangle {
            radius: Theme.radiusLarge
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }

    Foundation.ConfirmDialog {
        id: deleteDialog
        objectName: "contentDeleteConfirmDialog"
        title: "Xóa nội dung"
        message: "Xóa nội dung đang chọn? Đây là thao tác phá hủy, được kiểm tra quyền và ghi audit trên server."
        confirmText: "Xóa nội dung"
        destructive: true
        onAccepted: root.confirmDeleteContent()
    }
}
