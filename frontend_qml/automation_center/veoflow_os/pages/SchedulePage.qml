pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import ".."
import "../foundation" as Foundation
import "schedule" as Schedule

Item {
    id: root
    objectName: "schedulePage"
    Accessible.name: "Lịch trình xuất bản"
    Accessible.role: Accessible.Pane

    property var scheduleSnapshot: ({})
    property var snapshotError: ({})
    property bool embeddedMode: false
    property string selectedScheduleId: ""
    property string selectionProjectionRequestedId: ""
    property bool inspectorVisible: true
    property string activeTab: "calendar"
    property string bannerMessage: ""
    property int commandRevision: 0
    property bool cancelConfirmationPending: false
    property var allocationResult: ({})
    property bool allocationConfirmationPending: false
    property var createCandidateLabels: []
    property var createCandidateRows: []
    property var recurrenceCandidateLabels: []
    property var recurrenceCandidateRows: []
    property int createCandidateIndex: -1
    property string createPackageId: ""
    property string createChannelId: ""
    property string createContentTitle: ""
    property string createChannelName: ""
    property string createPlatform: ""
    property string createRunAt: ""
    property string createLocalTime: ""
    property string createTimezone: "Asia/Bangkok"
    // qmllint disable unqualified
    readonly property var plane: controlPlane
    // qmllint enable unqualified
    readonly property var snapshotData: (root.scheduleSnapshot || {}).data || ({})
    readonly property var headerData: root.snapshotData.header || ({})
    readonly property var backlogData: root.snapshotData.backlog_meta || ({})
    readonly property var calendarData: root.snapshotData.calendar || ({})
    readonly property var selectedSchedule: root.snapshotData.selected_schedule || ({})
    readonly property var selectionData: root.snapshotData.selection || ({})
    readonly property var capacityData: root.snapshotData.capacity_meta || ({})
    readonly property var backlogModel: root.plane.snapshotStore.collection("schedule", "backlog")
    readonly property var occurrenceModel: root.plane.snapshotStore.collection("schedule", "occurrences")
    readonly property var capacityModel: root.plane.snapshotStore.collection("schedule", "capacity")
    readonly property var queueModel: root.plane.snapshotStore.collection("schedule", "queue")
    readonly property var recurrenceModel: root.plane.snapshotStore.collection("schedule", "recurrences")
    readonly property var historyModel: root.plane.snapshotStore.collection("schedule", "history")
    readonly property var permissions: (root.scheduleSnapshot || {}).permissions || []
    readonly property bool localTool1ScheduleAuthority:
        root.plane && root.plane.localScheduleWriteAllowed === true
    readonly property bool canRead: root.permissions.indexOf("workspace.read") >= 0
        || root.permissions.indexOf("workspace.admin") >= 0
    readonly property bool canWrite: root.permissions.indexOf("workspace.write") >= 0
        || root.permissions.indexOf("workspace.admin") >= 0
        || root.localTool1ScheduleAuthority
    readonly property bool canAdmin: root.permissions.indexOf("workspace.admin") >= 0
        || root.localTool1ScheduleAuthority
    readonly property bool hasProjectionData: root.occurrenceModel.count > 0
        || String(root.selectedSchedule.id || "").length > 0
        || root.capacityModel.count > 0
        || root.recurrenceModel.count > 0 || root.queueModel.count > 0
        || root.historyModel.count > 0
    readonly property string viewState: root.resolveViewState()
    readonly property int allocationProposalCount:
        ((root.allocationResult || {}).proposals || []).length
    readonly property bool allocationBusy: root.plane.commandStore.isBusy(
        "schedule.allocation.preview", "global", "global"
    )
    readonly property int eligibleBacklogCount:
        root.backlogData.eligible_total !== undefined
            && root.backlogData.eligible_total !== null
        ? Number(root.backlogData.eligible_total) : root.allocationItems().length
    readonly property bool canAutoAllocate: root.canWrite
        && String(root.backlogData.state || "") === "ready"
        && root.eligibleBacklogCount > 0 && root.capacityModel.count > 0
        && Boolean(String((root.calendarData.window || {}).start || ""))
        && Boolean(String((root.calendarData.window || {}).end || ""))
        && Boolean(String((root.calendarData.window || {}).timezone || ""))
    readonly property bool createFormValid:
        root.stableId(root.createPackageId, 80)
        && root.stableId(root.createChannelId, 80)
        && root.awareIso(root.createRunAt)
        && Boolean(root.createTimezone)

    function slug(value) {
        let normalized = String(value || "").trim()
        if (normalized.normalize)
            normalized = normalized.normalize("NFD").replace(/[\u0300-\u036f]/g, "")
        normalized = normalized.replace(/đ/g, "d").replace(/Đ/g, "D")
        normalized = normalized.replace(/[^A-Za-z0-9._:@-]+/g, "-")
            .replace(/^-+|-+$/g, "")
        return normalized || "change"
    }

    function stableId(value, maximum) {
        const text = String(value || "")
        return text.length > 0 && text.length <= Number(maximum || 160)
            && /^[A-Za-z0-9][A-Za-z0-9._:@-]*$/.test(text)
    }

    function awareIso(value) {
        const text = String(value || "")
        return /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?(?:Z|[+-]\d{2}:\d{2})$/.test(text)
            && !isNaN(Date.parse(text))
    }

    function scheduleStateLabel(state) {
        switch (String(state || "")) {
        case "waiting_approval": return "Chờ duyệt"
        case "queued": return "Trong hàng đợi"
        case "publishing": return "Đang đăng"
        case "failed": return "Thất bại"
        case "published": return "Đã xuất bản"
        case "conflict": return "Xung đột"
        default: return "Đã lên lịch"
        }
    }

    function platformLabel(value) {
        switch (String(value || "").toLowerCase()) {
        case "youtube": return "YouTube"
        case "tiktok": return "TikTok"
        case "facebook": return "Facebook"
        case "instagram": return "Instagram"
        case "linkedin": return "LinkedIn"
        case "x": return "X"
        default: return String(value || "Nền tảng")
        }
    }

    function timezoneLabel(value) {
        switch (String(value || "")) {
        case "Asia/Bangkok":
        case "Asia/Ho_Chi_Minh": return "Giờ Việt Nam"
        case "UTC": return "Giờ quốc tế (UTC)"
        default: return "Múi giờ của kênh"
        }
    }

    function createCandidateLabel(title, channelName, platform) {
        return String(title || "Nội dung chưa đặt tên") + " · "
            + String(channelName || "Kênh chưa đặt tên") + " · "
            + root.platformLabel(platform)
    }

    function localSlotSummary(localTime, timezone) {
        const text = String(localTime || "")
        const match = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})/.exec(text)
        if (!match)
            return "Chưa có slot khả dụng"
        return match[3] + "/" + match[2] + "/" + match[1]
            + " · " + match[4] + ":" + match[5]
            + " · " + root.timezoneLabel(timezone)
    }

    function nextCreateSlot() {
        let platformFallback = null
        for (let index = 0; index < root.capacityModel.count; ++index) {
            const rawPolicy = root.capacityModel.get(index)
            const policy = rawPolicy === null || rawPolicy === undefined
                ? ({}) : rawPolicy
            if (String(policy.next_free_slot_state || "") !== "available"
                    || !policy.next_free_slot_run_at)
                continue
            const candidate = {
                "run_at": String(policy.next_free_slot_run_at || ""),
                "local_time": String(policy.next_free_slot_local_time || ""),
                "timezone": String(policy.next_free_slot_timezone || "")
            }
            if (String(policy.channel_id || "") === root.createChannelId)
                return candidate
            if (!platformFallback && String(policy.platform || "") === root.createPlatform)
                platformFallback = candidate
        }
        return platformFallback
    }

    function createSlotFor(channelId, platform) {
        let platformFallback = null
        for (let index = 0; index < root.capacityModel.count; ++index) {
            const rawPolicy = root.capacityModel.get(index)
            const policy = rawPolicy === null || rawPolicy === undefined
                ? ({}) : rawPolicy
            if (String(policy.next_free_slot_state || "") !== "available"
                    || !policy.next_free_slot_run_at)
                continue
            const candidate = {
                "run_at": String(policy.next_free_slot_run_at || ""),
                "local_time": String(policy.next_free_slot_local_time || ""),
                "timezone": String(policy.next_free_slot_timezone || "")
            }
            if (String(policy.channel_id || "") === String(channelId || ""))
                return candidate
            if (!platformFallback
                    && String(policy.platform || "") === String(platform || ""))
                platformFallback = candidate
        }
        return platformFallback
    }

    function rebuildCreateCandidates() {
        const rows = []
        const labels = []
        for (let index = 0; index < root.backlogModel.count; ++index) {
            const rawItem = root.backlogModel.get(index)
            const item = rawItem === null || rawItem === undefined ? ({}) : rawItem
            const readiness = item.readiness === null
                    || item.readiness === undefined
                ? ({}) : item.readiness
            const channel = item.channel === null || item.channel === undefined
                ? ({}) : item.channel
            const packageId = String(item.content_package_id || "")
            const channelId = String(channel.id || "")
            const platform = String(item.platform || "")
            const slot = root.createSlotFor(channelId, platform)
            if (String(readiness.state || "") !== "ready"
                    || !root.stableId(packageId, 80)
                    || !root.stableId(channelId, 80)
                    || !slot)
                continue
            const row = {
                "package_id": packageId,
                "channel_id": channelId,
                "title": String(item.title || "Nội dung chưa đặt tên"),
                "channel_name": String(channel.display_name || "Kênh chưa đặt tên"),
                "platform": platform,
                "duration_seconds": Number(item.duration_seconds || 60),
                "run_at": String(slot.run_at || ""),
                "local_time": String(slot.local_time || ""),
                "timezone": String(slot.timezone || "")
            }
            rows.push(row)
            labels.push(root.createCandidateLabel(
                row.title, row.channel_name, row.platform
            ))
        }
        root.createCandidateRows = rows
        root.createCandidateLabels = labels
        return rows.length
    }

    function rebuildRecurrenceCandidates() {
        const rows = []
        const labels = []
        for (let index = 0; index < root.backlogModel.count; ++index) {
            const item = root.backlogModel.get(index) || ({})
            const readiness = item.readiness || ({})
            const channel = item.channel || ({})
            const packageId = String(item.content_package_id || "")
            const channelId = String(channel.id || "")
            const assignment = item.assignment_definition || ({})
            if (String(readiness.state || "") !== "ready"
                    || !root.stableId(packageId, 80)
                    || !root.stableId(channelId, 80)
                    || Number(assignment.version || 0) !== 2)
                continue
            const row = {
                "package_id": packageId,
                "channel_id": channelId,
                "title": String(item.title || "Assignment V2"),
                "channel_name": String(channel.display_name || channelId),
                "platform": String(item.platform || ""),
                "duration_seconds": Number(item.duration_seconds || 60),
                "assignment_definition": assignment
            }
            rows.push(row)
            labels.push(root.createCandidateLabel(
                row.title, row.channel_name, row.platform
            ))
        }
        root.recurrenceCandidateRows = rows
        root.recurrenceCandidateLabels = labels
        return rows.length
    }

    function selectCreateCandidate(index) {
        const selectedIndex = Number(index)
        if (selectedIndex < 0 || selectedIndex >= root.createCandidateRows.length)
            return false
        const row = root.createCandidateRows[selectedIndex]
        root.createCandidateIndex = selectedIndex
        root.createPackageId = String(row.package_id || "")
        root.createChannelId = String(row.channel_id || "")
        root.createContentTitle = String(row.title || "")
        root.createChannelName = String(row.channel_name || "")
        root.createPlatform = String(row.platform || "")
        root.createRunAt = String(row.run_at || "")
        root.createLocalTime = String(row.local_time || "")
        root.createTimezone = String(row.timezone || "Asia/Bangkok")
        createDurationField.value = Number(row.duration_seconds || 60)
        return true
    }

    function prepareCreateTiming() {
        if (root.createCandidateIndex >= 0
                && root.createCandidateIndex < root.createCandidateRows.length) {
            const row = root.createCandidateRows[root.createCandidateIndex]
            root.createRunAt = String(row.run_at || "")
            root.createLocalTime = String(row.local_time || "")
            root.createTimezone = String(row.timezone || "Asia/Bangkok")
            return
        }
        const nextSlot = root.nextCreateSlot()
        const slot = nextSlot === null || nextSlot === undefined ? ({}) : nextSlot
        root.createRunAt = String(slot.run_at || "")
        root.createLocalTime = String(slot.local_time || "")
        root.createTimezone = String(
            slot.timezone || (root.calendarData.window || {}).timezone || "Asia/Bangkok"
        )
    }

    function openCreateDialog() {
        if (!root.canWrite)
            return false
        if (root.rebuildCreateCandidates() < 1) {
            root.bannerMessage = "Chưa có nội dung đủ bằng chứng để lên lịch."
            return false
        }
        root.selectCreateCandidate(0)
        root.prepareCreateTiming()
        createDialog.open()
        return true
    }

    function reloadSnapshot() {
        const nextSnapshot = root.plane.snapshotStore.snapshot("schedule")
        const nextData = (nextSnapshot || {}).data || ({})
        root.scheduleSnapshot = nextSnapshot
        root.snapshotError = root.plane.snapshotStore.error("schedule")
        // Do not read a dependent QML binding in the same signal turn. Native
        // SnapshotStore updates can emit before snapshotData/selectionData have
        // re-evaluated, which used to drop the authoritative default selection.
        root.reconcileSelectionProjection(nextData)
        Qt.callLater(root.rebuildCreateCandidates)
        Qt.callLater(root.rebuildRecurrenceCandidates)
    }

    function reconcileSelectionProjection(data) {
        const snapshotData = data || ({})
        const selected = snapshotData.selected_schedule || ({})
        if (selected.id) {
            root.selectedScheduleId = String(selected.id)
            // Mark the projection as satisfied. Keeping the identity prevents
            // a later generic refresh from reissuing the same auto-selection.
            root.selectionProjectionRequestedId = root.selectedScheduleId
            return
        }

        let scheduleId = String(root.selectedScheduleId || "")
        const selection = snapshotData.selection || ({})
        if (!scheduleId && Boolean(selection.auto_select_allowed))
            scheduleId = String(selection.default_id || "")
        if (!scheduleId)
            return

        root.selectedScheduleId = scheduleId
        if (root.selectionProjectionRequestedId === scheduleId)
            return
        root.selectionProjectionRequestedId = scheduleId
        root.requestSnapshot({"selected_schedule_id": scheduleId})
    }

    function resolveViewState() {
        const snapshot = root.scheduleSnapshot || ({})
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
        const state = String((snapshot.freshness || {}).state || "fresh").toLowerCase()
        if (state === "partial" || state === "stale")
            return state
        return root.hasProjectionData ? "content" : "empty"
    }

    function snapshotQuery(overrides) {
        const extra = overrides || ({})
        const window = root.calendarData.window || ({})
        const filters = root.calendarData.filter || ({})
        const windowStart = String(extra.window_start || window.start || "")
        const windowEnd = String(extra.window_end || window.end || "")
        const timezone = String(extra.timezone || window.timezone || "")
        if (!windowStart || !windowEnd || !timezone)
            return null
        const query = {
            "window_start": windowStart,
            "window_end": windowEnd,
            "timezone": timezone,
            "limit": 100,
            "metric_window_days": 7,
            "history_limit": 50
        }
        const anchorDate = extra.anchor_date !== undefined
            ? String(extra.anchor_date || "") : ""
        const viewMode = extra.view_mode !== undefined
            ? String(extra.view_mode || "") : ""
        if (anchorDate && viewMode) {
            query.anchor_date = anchorDate
            query.view_mode = viewMode
        }
        const selectedPublishJob = extra.selected_publish_job_id !== undefined
            ? String(extra.selected_publish_job_id) : ""
        if (selectedPublishJob) {
            query.selected_publish_job_id = selectedPublishJob
        } else {
            const selected = extra.selected_schedule_id !== undefined
                ? String(extra.selected_schedule_id) : root.selectedScheduleId
            if (selected)
                query.selected_schedule_id = selected
        }
        const channelId = extra.channel_id !== undefined
            ? String(extra.channel_id) : String(filters.channel_id || "")
        const platform = extra.platform !== undefined
            ? String(extra.platform) : String(filters.platform || "")
        const state = extra.state !== undefined
            ? String(extra.state) : String(filters.state || "")
        const search = extra.search !== undefined
            ? String(extra.search) : String(filters.search || "")
        if (channelId) query.channel_id = channelId
        if (platform) query.platform = platform
        if (state) query.state = state
        if (search) query.search = search
        if (extra.cursor !== undefined && extra.cursor !== null && String(extra.cursor))
            query.cursor = String(extra.cursor)
        return query
    }

    function requestSnapshot(overrides) {
        const query = root.snapshotQuery(overrides)
        if (!query) {
            root.bannerMessage = "Đang tải cửa sổ lịch vận hành."
            return false
        }
        root.plane.callTool("schedule.workspace.snapshot", query)
        return true
    }

    function requestTab(tabKey) {
        root.activeTab = String(tabKey || "calendar")
        root.requestSnapshot({})
    }

    function retrySnapshot() {
        if (root.snapshotQuery({}))
            return root.requestSnapshot({})
        const accepted = root.plane.refreshSnapshotTool(
            "schedule.workspace.snapshot"
        )
        if (!accepted)
            root.bannerMessage = "Không thể tải lại dữ liệu lịch trình."
        return accepted
    }

    function openDeepLink(link) {
        const projected = link || ({})
        const entity = projected.entity || ({})
        const route = String(projected.route || "")
        if (!route)
            return
        root.plane.navigateEntity(
            route,
            String(entity.type || ""),
            String(entity.id || ""),
            projected.context || ({})
        )
    }

    function selectSchedule(item) {
        const schedule = item || ({})
        const scheduleId = String(schedule.id || "")
        if (!scheduleId)
            return
        root.selectedScheduleId = scheduleId
        root.selectionProjectionRequestedId = scheduleId
        root.inspectorVisible = true
        root.openDeepLink(schedule.deep_link)
        root.requestSnapshot({"selected_schedule_id": scheduleId})
    }

    function syncExternalSelection() {
        const selection = root.plane.entitySelection.current || ({})
        if (String(selection.route || "") !== "schedule")
            return
        const entity = selection.entity || ({})
        const context = selection.context || ({})
        const entityType = String(entity.type || "")
        let scheduleId = ""
        if (entityType === "schedule")
            scheduleId = String(entity.id || "")
        else if (entityType === "publish_job") {
            const publishJobId = String(entity.id || "")
            if (publishJobId)
                root.requestSnapshot({"selected_publish_job_id": publishJobId})
            return
        }
        else if (context.schedule_id)
            scheduleId = String(context.schedule_id)
        if (!scheduleId || scheduleId === root.selectedScheduleId)
            return
        root.selectedScheduleId = scheduleId
        root.selectionProjectionRequestedId = scheduleId
        root.requestSnapshot({"selected_schedule_id": scheduleId})
    }

    function createSchedule() {
        const packageId = String(root.createPackageId || "").trim()
        const channelId = String(root.createChannelId || "").trim()
        const runAt = String(root.createRunAt || "").trim()
        const timezone = String(root.createTimezone || "").trim()
        if (!root.canWrite || !root.createFormValid)
            return
        if (root.plane.commandStore.isBusy(
                "schedule.create", "content_package", packageId))
            return
        root.plane.callTool("schedule.create", {
            "content_package_id": packageId,
            "channel_id": channelId,
            "run_at": runAt,
            "timezone": timezone,
            "duration_seconds": createDurationField.value,
            "publishing_policy": String(
                createPolicyField.model[createPolicyField.currentIndex]
            ),
            "retry_policy": {
                "max_attempts": createRetryAttemptsField.value,
                "backoff_seconds": createRetryBackoffField.value
            },
            "allow_conflict": false,
            "source": "operator",
            "idempotency_key": "ui.schedule.create:"
                + root.slug(packageId).slice(0, 40) + ":"
                + root.slug(channelId).slice(0, 40) + ":"
                + root.slug(runAt).slice(0, 48)
        })
    }

    function stageBacklog(item) {
        const value = item || ({})
        const readiness = value.readiness || ({})
        if (!root.canWrite || String(readiness.state || "") !== "ready") {
            root.bannerMessage = "Nội dung chưa sẵn sàng để lập lịch."
            return
        }
        root.rebuildCreateCandidates()
        let selectedIndex = -1
        const packageId = String(value.content_package_id || "")
        for (let index = 0; index < root.createCandidateRows.length; ++index) {
            if (String(root.createCandidateRows[index].package_id || "") === packageId) {
                selectedIndex = index
                break
            }
        }
        if (selectedIndex < 0 || !root.selectCreateCandidate(selectedIndex)) {
            root.bannerMessage = "Nội dung không còn trong backlog sẵn sàng."
            return
        }
        root.prepareCreateTiming()
        createDialog.open()
    }

    function allocationItems() {
        const items = []
        for (let index = 0; index < root.backlogModel.count; ++index) {
            const row = root.backlogModel.get(index) || ({})
            const readiness = row.readiness || ({})
            const channel = row.channel || ({})
            const packageId = String(row.content_package_id || "")
            const channelId = String(channel.id || "")
            const duration = row.duration_seconds
            if (String(readiness.state || "") !== "ready" || !packageId || !channelId)
                continue
            if (!isFinite(duration) || duration < 60)
                continue
            items.push({
                "content_package_id": packageId,
                "channel_id": channelId,
                "duration_seconds": duration,
                "publishing_policy": "approval_required",
                "retry_policy": {"max_attempts": 2, "backoff_seconds": 30}
            })
        }
        return items
    }

    function requestAutoAllocation() {
        if (!root.canAutoAllocate || root.allocationBusy)
            return
        const window = root.calendarData.window || ({})
        const items = root.allocationItems()
        if (!items.length)
            return
        root.allocationResult = ({})
        root.allocationConfirmationPending = false
        root.plane.callTool("schedule.allocation.preview", {
            "items": items,
            "window_start": String(window.start),
            "window_end": String(window.end),
            "timezone": String(window.timezone)
        })
    }

    function captureAllocationResult() {
        const state = root.plane.commandStore.state(
            "schedule.allocation.preview", "global", "global"
        )
        if (String(state.state || "") !== "succeeded")
            return
        const result = state.result || ({})
        if (String(result.state || "") !== "preview" || result.materialized !== false)
            return
        root.allocationResult = result
        root.allocationConfirmationPending = ((result.proposals || []).length > 0)
        if (root.allocationConfirmationPending)
            allocationConfirm.open()
        else
            root.bannerMessage = "Không tìm thấy khung giờ hợp lệ trong cửa sổ hiện tại."
    }

    function confirmAllocation() {
        if (!root.canWrite || !root.allocationConfirmationPending)
            return
        const proposals = (root.allocationResult || {}).proposals || []
        for (let index = 0; index < proposals.length; ++index) {
            const command = (proposals[index] || {}).create_command || ({})
            if (!String(command.content_package_id || "")
                    || !String(command.channel_id || "")
                    || !String(command.run_at || "")
                    || !String(command.idempotency_key || ""))
                continue
            root.plane.callTool("schedule.create", command)
        }
        root.allocationConfirmationPending = false
        allocationConfirm.close()
    }


    function requestCancelSelected() {
        const action = (root.selectedSchedule.actions || {}).cancel || ({})
        if (!root.canWrite || !action.available || !String(root.selectedSchedule.id || ""))
            return
        root.cancelConfirmationPending = true
        cancelConfirm.open()
    }

    function confirmCancelSelected() {
        const scheduleId = String(root.selectedSchedule.id || "")
        const version = root.selectedSchedule.version
        const action = (root.selectedSchedule.actions || {}).cancel || ({})
        if (!root.canWrite || !action.available || !scheduleId || version < 1)
            return
        root.plane.callTool("schedule.cancel", {
            "schedule_id": scheduleId,
            "expected_version": version,
            "reason": "Operator cancelled schedule from Schedule screen",
            "idempotency_key": "ui.schedule.cancel:" + scheduleId + ":" + version
        })
        root.cancelConfirmationPending = false
        cancelConfirm.close()
    }

    Connections {
        target: root.plane.snapshotStore
        function onChanged(route) {
            if (route === "schedule")
                root.reloadSnapshot()
        }
    }

    Connections {
        target: root.plane.entitySelection
        function onSelectionChanged() { root.syncExternalSelection() }
    }

    Connections {
        target: root.plane.commandStore
        function onChanged(capability, entityType, entityId) {
            root.commandRevision += 1
            const commandState = root.plane.commandStore.state(
                capability, entityType, entityId
            ) || ({})
            const commandStatus = String(commandState.state || "")
            if (String(capability).indexOf("schedule.") === 0
                    && commandStatus === "failed") {
                root.bannerMessage = String(
                    commandState.message || "Thao tác lịch trình thất bại phía server."
                )
            } else if (commandStatus === "succeeded") {
                if (capability === "schedule.create")
                    root.bannerMessage = "Đã tạo lịch; đang cập nhật màn hình."
                else if (capability === "schedule.update")
                    root.bannerMessage = "Đã lưu thay đổi lịch trình."
                else if (capability === "schedule.publish_now.request")
                    root.bannerMessage = "Đã gửi yêu cầu đăng; vẫn cần phê duyệt theo chính sách."
                else if (capability === "schedule.cancel")
                    root.bannerMessage = "Đã hủy lịch; lịch sử thay đổi vẫn được bảo toàn."
            }
            if (capability === "schedule.allocation.preview"
                    && entityType === "global" && entityId === "global")
                root.captureAllocationResult()
            if ((capability === "schedule.capacity.create"
                    || capability === "schedule.capacity.revise"
                    || capability === "schedule.recurrence.create"
                    || capability === "schedule.recurrence.revise"
                    || capability === "schedule.capacity.list"
                    || capability === "schedule.recurrence.list")
                    && String((root.plane.commandStore.state(
                        capability, entityType, entityId
                    ) || {}).state || "") === "succeeded") {
                const result = (root.plane.commandStore.state(
                    capability, entityType, entityId
                ) || {}).result || ({})
                if (capability === "schedule.capacity.list")
                    root.bannerMessage = "Đã xác minh "
                        + ((result.policies || []).length) + " quy tắc sức chứa."
                else if (capability === "schedule.recurrence.list")
                    root.bannerMessage = "Đã xác minh "
                        + ((result.recurrences || []).length) + " quy tắc đăng định kỳ."
                // Versioned mutations fan out a fresh Schedule snapshot from
                // the desktop adapter. Explicit list commands do not mutate,
                // so refresh their projection once after the server result.
                if (capability === "schedule.capacity.list"
                        || capability === "schedule.recurrence.list")
                    root.requestSnapshot({})
            }
        }
    }

    Component.onCompleted: {
        root.reloadSnapshot()
        root.syncExternalSelection()
    }

    Schedule.ScheduleDialog {
        id: createDialog
        objectName: "scheduleCreateDialog"
        anchors.centerIn: parent
        width: 620
        title: "Lên lịch xuất bản"
        acceptText: "Tạo lịch"
        acceptEnabled: root.canWrite
            && root.createFormValid
        onAccepted: root.createSchedule()
        contentItem: ColumnLayout {
            spacing: 8
            Text {
                objectName: "scheduleCreateContentLabel"
                Layout.fillWidth: true
                text: "NỘI DUNG SẴN SÀNG"
                color: Theme.textFaint
                font.pixelSize: 11
                font.weight: Font.Bold
                font.letterSpacing: 0.7
            }
            Schedule.ScheduleCombo {
                id: createPackageCombo
                objectName: "scheduleCreatePackageCombo"
                Layout.fillWidth: true
                model: root.createCandidateLabels
                currentIndex: root.createCandidateIndex
                displayText: root.createCandidateIndex >= 0
                    ? String(root.createCandidateLabels[root.createCandidateIndex] || "")
                    : "Chưa có nội dung sẵn sàng"
                Accessible.name: "Chọn nội dung và kênh xuất bản"
                onActivated: function(index) { root.selectCreateCandidate(index) }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 9
                    UiIcon {
                        name: root.createPlatform
                            ? "product/" + root.createPlatform.toLowerCase() : "ui/calendar"
                        tone: Theme.accent
                        iconSize: 20
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { Layout.fillWidth: true; text: root.createContentTitle; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
                        Text { Layout.fillWidth: true; text: root.createChannelName + " · " + root.platformLabel(root.createPlatform); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                    }
                }
            }
            Text {
                objectName: "scheduleCreateTimingLabel"
                Layout.fillWidth: true
                Layout.topMargin: 4
                text: "THỜI ĐIỂM XUẤT BẢN"
                color: Theme.textFaint
                font.pixelSize: 11
                font.weight: Font.Bold
                font.letterSpacing: 0.7
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                radius: Theme.radiusSmall
                color: Theme.successSoft
                border.width: 1
                border.color: Theme.success
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 8
                    UiIcon { name: "ui/calendar"; tone: Theme.success; iconSize: 17 }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text { text: "Khung giờ gần nhất còn trống"; color: Theme.textMuted; font.pixelSize: 11 }
                        Text {
                            id: createLocalSlotText
                            objectName: "scheduleCreateLocalSlotText"
                            Layout.fillWidth: true
                            text: root.localSlotSummary(
                                root.createLocalTime, root.createTimezone
                            )
                            color: Theme.text
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                    }
                }
            }
            Text { Layout.fillWidth: true; text: "CẤU HÌNH PHÁT HÀNH"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 0.7 }
            RowLayout {
                Layout.fillWidth: true
                Schedule.ScheduleSpin { id: createDurationField; objectName: "scheduleCreateDurationSpin"; Layout.fillWidth: true; from: 60; to: 86400; stepSize: 60; value: 1800; editable: true; displayDivisor: 60; unitSuffix: "phút"; Accessible.name: "Thời lượng slot theo phút" }
                Schedule.ScheduleCombo { id: createPolicyField; objectName: "scheduleCreatePolicyCombo"; Layout.fillWidth: true; model: ["approval_required", "scheduled_approval"]; displayLabels: ({"approval_required": "Cần phê duyệt trước khi đăng", "scheduled_approval": "Duyệt theo lịch đã đặt"}); displayText: currentIndex === 1 ? "Duyệt theo lịch đã đặt" : "Cần phê duyệt trước khi đăng"; Accessible.name: "Chính sách phát hành" }
            }
            RowLayout {
                Layout.fillWidth: true
                Schedule.ScheduleSpin { id: createRetryAttemptsField; objectName: "scheduleCreateRetryAttemptsSpin"; Layout.fillWidth: true; from: 1; to: 10; value: 2; editable: true; unitSuffix: "lần"; Accessible.name: "Số lần thử lại" }
                Schedule.ScheduleSpin { id: createRetryBackoffField; objectName: "scheduleCreateRetryBackoffSpin"; Layout.fillWidth: true; from: 0; to: 86400; value: 30; editable: true; unitSuffix: "giây"; Accessible.name: "Khoảng chờ thử lại" }
            }
            Text {
                Layout.fillWidth: true
                text: "Lưu lịch không đồng nghĩa đã duyệt hoặc đã xuất bản."
                color: Theme.textFaint
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
        }
    }

    Foundation.ConfirmDialog {
        id: cancelConfirm
        objectName: "scheduleCancelConfirm"
        anchors.centerIn: parent
        title: "Hủy lịch xuất bản"
        message: "Hủy lịch đã chọn? Lịch sử thay đổi vẫn được giữ lại."
        confirmText: "Hủy lịch"
        destructive: true
        onAccepted: root.confirmCancelSelected()
    }

    Foundation.ConfirmDialog {
        id: allocationConfirm
        objectName: "scheduleAllocationConfirm"
        anchors.centerIn: parent
        title: "Xác nhận tạo lịch từ đề xuất"
        message: "Hệ thống đề xuất " + root.allocationProposalCount
            + " lịch hợp lệ. Chỉ khi xác nhận, các lịch mới được tạo; chưa có bài nào được đăng."
        confirmText: "Tạo " + root.allocationProposalCount + " lịch"
        onAccepted: root.confirmAllocation()
        onRejected: root.allocationConfirmationPending = false
    }

    Schedule.ScheduleCapacityDialog {
        id: capacityDialog
        objectName: "scheduleCapacityDialog"
        anchors.centerIn: parent
        canWrite: root.canAdmin
        commandStore: root.plane.commandStore
        commandRevision: root.commandRevision
        editor: root.capacityData.editor || ({})
        onCreateRequested: function(payload) {
            root.plane.callTool("schedule.capacity.create", payload)
        }
        onReviseRequested: function(payload) {
            root.plane.callTool("schedule.capacity.revise", payload)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.embeddedMode ? 0 : 14
        spacing: root.embeddedMode ? 0 : 8

        Schedule.ScheduleHeader {
            id: scheduleHeader
            objectName: "scheduleHeader"
            Layout.fillWidth: true
            Layout.preferredHeight: root.embeddedMode ? 0 : 108
            visible: !root.embeddedMode
            headerData: root.headerData
            activeTab: root.activeTab
            canWrite: root.canWrite
            canAutoAllocate: root.canAutoAllocate
            allocationBusy: root.allocationBusy
            autoAllocateReason: !root.canWrite ? "Bạn không có quyền chỉnh lịch"
                : String(root.backlogData.state || "") !== "ready"
                    ? "Nguồn nội dung chưa sẵn sàng"
                    : root.eligibleBacklogCount === 0
                        ? "Không có nội dung đủ điều kiện"
                    : root.capacityModel.count === 0
                        ? "Chưa có quy tắc sức chứa"
                    : !String((root.calendarData.window || {}).start || "")
                            || !String((root.calendarData.window || {}).end || "")
                        ? "Đang tải cửa sổ lịch vận hành"
                        : "Không có nội dung phù hợp"
            bannerMessage: root.bannerMessage
            onTabRequested: function(tabKey) { root.activeTab = tabKey }
            onCreateRequested: root.openCreateDialog()
            onAutoAllocateRequested: root.requestAutoAllocation()
        }

        Foundation.AsyncStateView {
            id: asyncState
            objectName: "scheduleAsyncState"
            Layout.fillWidth: true
            Layout.fillHeight: true
            accessibleName: "Dữ liệu lịch xuất bản"
            viewState: root.viewState
            hasData: root.hasProjectionData
            emptyTitle: "Chưa có lịch xuất bản"
            emptyDescription: "Tạo một lịch từ content package đã sẵn sàng."
            errorMessage: String((root.snapshotError || {}).message || "Không thể tải lịch xuất bản.")
            requiredPermission: "workspace.read"
            onRetry: root.retrySnapshot()

            Item {
                id: scheduleGrid
                objectName: "scheduleGrid"
                anchors.fill: parent
                visible: root.activeTab === "calendar"
                readonly property real gap: 8
                readonly property real backlogWidth: Math.max(248, Math.min(310, width * 0.19))
                readonly property real inspectorWidth: root.inspectorVisible
                    ? Math.max(300, Math.min(345, width * 0.21)) : 0
                readonly property real capacityHeight: 96
                readonly property real bodyHeight: Math.max(420, height - capacityHeight - gap)
                readonly property real calendarWidth: Math.max(
                    580,
                    width - backlogWidth - inspectorWidth - gap * 2
                )

                Schedule.ScheduleBacklog {
                    x: 0
                    y: 0
                    width: scheduleGrid.backlogWidth
                    height: scheduleGrid.bodyHeight
                    backlog: root.backlogData
                    backlogModel: root.backlogModel
                    controlPlaneBridge: root.plane
                    canWrite: root.canWrite
                    onScheduleRequested: function(item) { root.stageBacklog(item) }
                    onQueryRequested: function(query) { root.requestSnapshot(query) }
                    onDeepLinkRequested: function(link) { root.openDeepLink(link) }
                }

                Schedule.ScheduleInspector {
                    id: scheduleInspector
                    x: scheduleGrid.backlogWidth + scheduleGrid.calendarWidth + scheduleGrid.gap * 2
                    y: 0
                    width: scheduleGrid.inspectorWidth
                    height: scheduleGrid.bodyHeight
                    visible: root.inspectorVisible
                    schedule: root.selectedSchedule
                    publishDispatch: root.snapshotData.publish_dispatch || ({})
                    controlPlaneBridge: root.plane
                    canWrite: root.canWrite
                    commandStore: root.plane.commandStore
                    commandRevision: root.commandRevision
                    onConflictPreviewRequested: function(payload) {
                        root.plane.callTool("schedule.conflict.preview", payload)
                    }
                    onSaveRequested: function(payload) {
                        root.plane.callTool("schedule.update", payload)
                    }
                    onPublishNowRequested: function(payload) {
                        root.plane.callTool("schedule.publish_now.request", payload)
                    }
                    onCancelRequested: root.requestCancelSelected()
                    onDeepLinkRequested: function(link) { root.openDeepLink(link) }
                    onCloseRequested: root.inspectorVisible = false
                }

                Schedule.PublishingCalendar {
                    id: publishingCalendar
                    x: scheduleGrid.backlogWidth + scheduleGrid.gap
                    y: 0
                    width: scheduleGrid.calendarWidth
                    height: scheduleGrid.bodyHeight
                    calendar: root.calendarData
                    occurrenceModel: root.occurrenceModel
                    proposalTarget: scheduleInspector
                    canWrite: root.canWrite
                    selectedScheduleId: root.selectedScheduleId
                    onScheduleSelected: function(item) { root.selectSchedule(item) }
                    onNextPageRequested: root.requestSnapshot({"cursor": root.calendarData.next_cursor})
                    onWindowRequested: function(query) { root.requestSnapshot(query) }
                }

                Schedule.PublishingCapacityStrip {
                    x: 0
                    y: scheduleGrid.bodyHeight + scheduleGrid.gap
                    width: scheduleGrid.width
                    height: scheduleGrid.capacityHeight
                    capacity: root.capacityData
                    capacityModel: root.capacityModel
                    canWrite: root.canAdmin
                    onFilterRequested: function(filter) { root.requestSnapshot(filter) }
                    onSyncRequested: root.plane.callTool("schedule.capacity.list", {})
                    onCreateRequested: capacityDialog.openCreate()
                    onEditRequested: function(policy) { capacityDialog.openPolicy(policy) }
                }
            }

            Panel {
                id: queuePanel
                objectName: "scheduleQueuePanel"
                anchors.fill: parent
                visible: root.activeTab === "queue"
                Accessible.name: "Hàng đợi phát hành"
                Accessible.role: Accessible.Pane
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Layout.fillWidth: true
                            Text { text: "Hàng đợi phát hành"; color: Theme.text; font.pixelSize: 18; font.weight: Font.DemiBold }
                            Text { text: "Các lượt đăng đang chờ xử lý hoặc cần phê duyệt"; color: Theme.textFaint; font.pixelSize: 11 }
                        }
                        AppButton { objectName: "scheduleQueueRefreshButton"; text: "Làm mới"; leadingIcon: "ui/refresh-cw"; Accessible.name: "Làm mới hàng đợi phát hành"; onClicked: root.requestSnapshot({}) }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                    ListView {
                        id: queueList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        reuseItems: true
                        spacing: 6
                        model: root.queueModel
                        delegate: Rectangle {
                            id: queueRow
                            required property string entity_id
                            required property int version
                            required property string title
                            required property string platform
                            required property var channel
                            required property string state_value
                            required property string run_at
                            required property string local_time
                            required property string time_label
                            required property bool overdue
                            required property var deep_link
                            function activate() { root.openDeepLink(queueRow.deep_link) }
                            objectName: "scheduleQueue_" + queueRow.entity_id
                            width: queueList.width
                            height: 66
                            radius: Theme.radiusSmall
                            color: Theme.elevated
                            border.width: 1
                            border.color: queueRow.overdue ? Theme.danger : Theme.borderSoft
                            activeFocusOnTab: true
                            Accessible.name: String(queueRow.title || "Nội dung chưa đặt tên")
                                + ", " + root.scheduleStateLabel(queueRow.state_value)
                            Accessible.description: queueRow.time_label
                                + (queueRow.overdue ? ", quá hạn" : "")
                            Accessible.role: Accessible.ListItem
                            Accessible.focusable: true
                            Keys.onReturnPressed: queueRow.activate()
                            Keys.onSpacePressed: queueRow.activate()
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                SocialIcon {
                                    platform: String(queueRow.platform || "generic")
                                    Layout.preferredWidth: 22
                                    Layout.preferredHeight: 22
                                }
                                ColumnLayout {
                                    Layout.preferredWidth: 260
                                    spacing: 1
                                    Text { Layout.fillWidth: true; text: String(queueRow.title || queueRow.entity_id); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                    Text { Layout.fillWidth: true; text: String((queueRow.channel || {}).display_name || "Kênh chưa đặt tên"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                }
                                Foundation.StatusPill { text: root.scheduleStateLabel(queueRow.state_value); tone: queueRow.overdue ? Theme.danger : Theme.warning; showDot: true }
                                Item { Layout.fillWidth: true }
                                Text { text: queueRow.time_label; color: Theme.textMuted; font.pixelSize: 11 }
                                Text { visible: queueRow.overdue; text: "QUÁ HẠN"; color: Theme.danger; font.pixelSize: 11; font.weight: Font.Bold }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: queueRow.activate() }
                        }
                    }
                    Text { visible: root.queueModel.count === 0; Layout.fillWidth: true; text: "Hàng đợi hiện chưa có lượt đăng nào."; color: Theme.textFaint; horizontalAlignment: Text.AlignHCenter; Accessible.name: text }
                }
            }

            Schedule.ScheduleRecurrencePanel {
                id: recurrencePanel
                objectName: "scheduleRecurrencePanel"
                anchors.fill: parent
                visible: root.activeTab === "recurrence"
                recurrenceModel: root.recurrenceModel
                calendarWindow: root.calendarData.window || ({})
                timezoneOptions: (root.calendarData.filter_catalog || {}).timezones || []
                contentCandidateLabels: root.recurrenceCandidateLabels
                contentCandidates: root.recurrenceCandidateRows
                canWrite: root.canWrite
                commandStore: root.plane.commandStore
                commandRevision: root.commandRevision
                onListRequested: function(payload) {
                    root.plane.callTool("schedule.recurrence.list", payload)
                }
                onGetRequested: function(payload) {
                    root.plane.callTool("schedule.recurrence.get", payload)
                }
                onCreateRequested: function(payload) {
                    root.plane.callTool("schedule.recurrence.create", payload)
                }
                onReviseRequested: function(payload) {
                    root.plane.callTool("schedule.recurrence.revise", payload)
                }
                onPreviewRequested: function(payload) {
                    root.plane.callTool("schedule.recurrence.preview", payload)
                }
                onMaterializeRequested: function(payload) {
                    root.plane.callTool("schedule.recurrence.materialize", payload)
                }
                onStateRequested: function(payload) {
                    root.plane.callTool("schedule.recurrence.state", payload)
                }
                onDeepLinkRequested: function(link) { root.openDeepLink(link) }
            }

            Panel {
                id: historyPanel
                objectName: "scheduleHistoryPanel"
                anchors.fill: parent
                visible: root.activeTab === "history"
                Accessible.name: "Lịch sử lịch trình bất biến"
                Accessible.role: Accessible.Pane
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Layout.fillWidth: true
                            Text { text: "Lịch sử bất biến"; color: Theme.text; font.pixelSize: 18; font.weight: Font.DemiBold }
                            Text { text: "Bản ghi thay đổi không thể chỉnh sửa hoặc xóa"; color: Theme.textFaint; font.pixelSize: 11 }
                        }
                        AppButton { objectName: "scheduleHistoryRefreshButton"; text: "Làm mới"; leadingIcon: "ui/refresh-cw"; Accessible.name: "Làm mới lịch sử lịch trình"; onClicked: root.requestSnapshot({}) }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                    ListView {
                        id: historyList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6
                        clip: true
                        reuseItems: true
                        model: root.historyModel
                        delegate: Rectangle {
                            id: historyRow
                            required property string event_id
                            required property string event_type
                            required property string actor_id
                            required property int version
                            required property string summary
                            required property string event_label
                            required property string actor_label
                            required property var domain_event_id
                            required property var correlation_id
                            required property string created_at
                            required property string created_local
                            required property string time_label
                            objectName: "scheduleHistory_" + historyRow.event_id
                            width: historyList.width
                            height: 66
                            radius: Theme.radiusSmall
                            color: Theme.elevated
                            border.width: 1
                            border.color: Theme.borderSoft
                            Accessible.name: historyRow.event_label
                            Accessible.description: "Người thao tác: " + historyRow.actor_label
                            Accessible.role: Accessible.ListItem
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text { Layout.fillWidth: true; text: historyRow.event_label; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                    Text { text: "Người thao tác: " + historyRow.actor_label; color: Theme.textMuted; font.pixelSize: 11 }
                                    Text { text: "Đã ghi nhận và bảo toàn trong nhật ký hệ thống"; color: Theme.textFaint; font.pixelSize: 11 }
                                }
                                Text { text: historyRow.time_label; color: Theme.textFaint; font.pixelSize: 11 }
                            }
                        }
                    }
                    Text { visible: root.historyModel.count === 0; Layout.fillWidth: true; text: "Chưa có thay đổi nào được ghi nhận."; color: Theme.textFaint; horizontalAlignment: Text.AlignHCenter; Accessible.name: text }
                }
            }
        }
    }
}
