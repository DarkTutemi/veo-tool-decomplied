pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "scheduleRecurrencePanel"
    property var recurrenceModel: null
    property bool canWrite: false
    property var commandStore: null
    property int commandRevision: 0
    property var calendarWindow: ({})
    property var timezoneOptions: []
    property var contentCandidateLabels: []
    property var contentCandidates: []
    property int contentCandidateIndex: -1
    property string selectedRecurrenceKey: ""
    property int selectedVersion: 0
    property string draftKey: ""
    property string draftName: ""
    property string draftTimezone: "Asia/Bangkok"
    property string draftFrequency: "weekly"
    property int draftInterval: 1
    property string draftWeekdays: "0,1,2,3,4"
    property string draftLocalTime: "09:00"
    property string draftStartsOn: ""
    property string draftEndsOn: ""
    property string draftStartsOnText: ""
    property string draftEndsOnText: ""
    property string draftPackageId: ""
    property string draftChannelId: ""
    property string draftContentTitle: ""
    property string draftChannelName: ""
    property string draftPlatform: ""
    property var draftAssignmentDefinition: ({})
    property int draftDurationSeconds: 1800
    property string draftPublishingPolicy: "approval_required"
    property int draftRetryAttempts: 2
    property int draftRetryBackoffSeconds: 30
    property string pendingCapability: ""
    property string lastHandledRequestId: ""
    property var previewResult: ({})
    property string resultMessage: ""
    readonly property bool recurrenceBusy: {
        const unused = root.commandRevision
        const key = String(root.draftKey || root.selectedRecurrenceKey || "")
        if (!root.commandStore || !key)
            return unused < 0
        return root.commandStore.isBusy(
            root.selectedVersion > 0
                ? "schedule.recurrence.revise" : "schedule.recurrence.create",
            "schedule_recurrence",
            key
        )
    }
    readonly property bool weekdaysValid: root.draftFrequency !== "weekly"
        || (/^[0-6](,[0-6])*$/.test(String(root.draftWeekdays || ""))
            && root.weekdays().length > 0)
    readonly property string effectiveDraftKey: root.selectedVersion > 0
        ? root.draftKey : (root.draftKey || "rule-" + root.slug(root.draftName))
    readonly property bool formValid: root.stableIdentity(root.effectiveDraftKey, 120)
        && root.trimmedText(root.draftName, 240)
        && root.timezoneLike(root.draftTimezone)
        && root.validLocalTime(root.draftLocalTime)
        && root.validDateText(root.draftStartsOn)
        && (!String(root.draftEndsOn || "")
            || (root.validDateText(root.draftEndsOn)
                && String(root.draftEndsOn) >= String(root.draftStartsOn)))
        && root.stableIdentity(root.draftPackageId, 80)
        && root.stableIdentity(root.draftChannelId, 80)
        && Number((root.draftAssignmentDefinition || {}).version || 0) === 2
        && root.weekdaysValid && root.draftInterval >= 1
        && root.draftInterval <= 365
        && root.draftDurationSeconds >= 60
        && root.draftDurationSeconds <= 86400
        && root.draftRetryAttempts >= 1 && root.draftRetryAttempts <= 10
        && root.draftRetryBackoffSeconds >= 0
        && root.draftRetryBackoffSeconds <= 86400
    readonly property bool canPreview: Boolean(root.selectedRecurrenceKey)
        && root.selectedVersion > 0
        && Boolean(String(root.calendarWindow.start || ""))
        && Boolean(String(root.calendarWindow.end || ""))
    readonly property bool canMaterialize: root.canWrite && root.canPreview
        && String(root.selectedState || "active") === "active"
    property string selectedState: ""
    signal listRequested(var payload)
    signal getRequested(var payload)
    signal createRequested(var payload)
    signal reviseRequested(var payload)
    signal previewRequested(var payload)
    signal materializeRequested(var payload)
    signal stateRequested(var payload)
    signal deepLinkRequested(var link)
    Accessible.name: "Quy tắc lịch định kỳ"
    Accessible.role: Accessible.Pane

    function slug(value) {
        let normalized = String(value || "").trim()
        if (normalized.normalize)
            normalized = normalized.normalize("NFD").replace(/[\u0300-\u036f]/g, "")
        normalized = normalized.replace(/đ/g, "d").replace(/Đ/g, "D")
        return normalized.replace(/[^A-Za-z0-9._@-]+/g, "-")
            .replace(/^-+|-+$/g, "") || "recurrence"
    }

    function stableIdentity(value, maximum) {
        const text = String(value || "")
        return text.length > 0 && text.length <= Number(maximum || 160)
            && /^[A-Za-z0-9][A-Za-z0-9._:@-]*$/.test(text)
    }

    function trimmedText(value, maximum) {
        const text = String(value || "")
        return text.length > 0 && text.length <= Number(maximum)
            && text === text.trim()
    }

    function validLocalTime(value) {
        return /^(?:[01]\d|2[0-3]):[0-5]\d$/.test(String(value || ""))
    }

    function frequencyLabel(value) {
        return String(value || "") === "weekly" ? "Hàng tuần" : "Hàng ngày"
    }

    function stateLabel(value) {
        switch (String(value || "")) {
        case "active": return "Đang bật"
        case "paused": return "Tạm dừng"
        case "archived": return "Đã lưu trữ"
        default: return "Chưa xác định"
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
        const selected = String(value || "")
        for (let index = 0; index < root.timezoneOptions.length; ++index) {
            const option = root.timezoneOptions[index] || ({})
            if (String(option.value || "") === selected)
                return String(option.label || "Múi giờ của kênh")
        }
        if (selected === "Asia/Bangkok" || selected === "Asia/Ho_Chi_Minh")
            return "Giờ Việt Nam"
        if (selected === "UTC")
            return "Giờ quốc tế (UTC)"
        return "Múi giờ của kênh"
    }

    function timezoneLabels() {
        const result = []
        for (let index = 0; index < root.timezoneOptions.length; ++index)
            result.push(String((root.timezoneOptions[index] || {}).label || ""))
        return result
    }

    function timezoneIndex(value) {
        const selected = String(value || "")
        for (let index = 0; index < root.timezoneOptions.length; ++index) {
            if (String((root.timezoneOptions[index] || {}).value || "") === selected)
                return index
        }
        return -1
    }

    function selectContentCandidate(index) {
        const selectedIndex = Number(index)
        if (selectedIndex < 0 || selectedIndex >= root.contentCandidates.length)
            return false
        const item = root.contentCandidates[selectedIndex] || ({})
        root.contentCandidateIndex = selectedIndex
        root.draftPackageId = String(item.package_id || "")
        root.draftChannelId = String(item.channel_id || "")
        root.draftContentTitle = String(item.title || "")
        root.draftChannelName = String(item.channel_name || "")
        root.draftPlatform = String(item.platform || "")
        root.draftDurationSeconds = Number(item.duration_seconds || 60)
        root.draftAssignmentDefinition = item.assignment_definition || ({})
        return true
    }

    function contentSummary() {
        if (!root.draftContentTitle || !root.draftChannelName)
            return "Chưa có nội dung sẵn sàng để lên lịch"
        return root.draftContentTitle + " · " + root.draftChannelName
            + " · " + root.platformLabel(root.draftPlatform)
    }

    function validDateText(value) {
        const text = String(value || "")
        if (!/^\d{4}-\d{2}-\d{2}$/.test(text))
            return false
        const parsed = new Date(text + "T00:00:00Z")
        return !isNaN(parsed.getTime()) && parsed.toISOString().slice(0, 10) === text
    }

    function displayDate(value) {
        const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(String(value || ""))
        return match ? match[3] + "/" + match[2] + "/" + match[1]
            : String(value || "")
    }

    function parseDisplayDate(value) {
        const text = String(value || "").trim()
        const match = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec(text)
        const candidate = match
            ? match[3] + "-" + match[2] + "-" + match[1] : text
        return root.validDateText(candidate) ? candidate : ""
    }

    function editStartsOn(value) {
        root.draftStartsOnText = String(value || "").trim()
        root.draftStartsOn = root.parseDisplayDate(root.draftStartsOnText)
    }

    function editEndsOn(value) {
        root.draftEndsOnText = String(value || "").trim()
        root.draftEndsOn = root.draftEndsOnText
            ? root.parseDisplayDate(root.draftEndsOnText) : ""
    }

    function timezoneLike(value) {
        const text = String(value || "")
        return text.length > 0 && text.length <= 120 && text === text.trim()
            && (text === "UTC"
                || /^[A-Za-z_+-]+(?:\/[A-Za-z0-9_+.-]+)+$/.test(text))
    }

    onDraftStartsOnChanged: {
        if (root.validDateText(root.draftStartsOn)
                && root.parseDisplayDate(root.draftStartsOnText) !== root.draftStartsOn)
            root.draftStartsOnText = root.displayDate(root.draftStartsOn)
    }
    onDraftEndsOnChanged: {
        if (!root.draftEndsOn)
            root.draftEndsOnText = ""
        else if (root.validDateText(root.draftEndsOn)
                && root.parseDisplayDate(root.draftEndsOnText) !== root.draftEndsOn)
            root.draftEndsOnText = root.displayDate(root.draftEndsOn)
    }

    function idempotencyToken(value) {
        return root.slug(value).slice(0, 96)
    }

    function weekdays() {
        const result = []
        const parts = String(root.draftWeekdays || "").split(",")
        for (let index = 0; index < parts.length; ++index) {
            const value = Number(String(parts[index]).trim())
            if (Number.isInteger(value) && value >= 0 && value <= 6
                    && result.indexOf(value) < 0)
                result.push(value)
        }
        return result
    }

    function resetCreate() {
        root.selectedRecurrenceKey = ""
        root.selectedVersion = 0
        root.selectedState = ""
        root.draftKey = ""
        root.draftName = ""
        root.draftTimezone = String(root.calendarWindow.timezone || "Asia/Bangkok")
        root.draftFrequency = "weekly"
        root.draftInterval = 1
        root.draftWeekdays = "0,1,2,3,4"
        root.draftLocalTime = "09:00"
        root.draftStartsOn = String(root.calendarWindow.start || "").slice(0, 10)
        root.draftEndsOn = ""
        root.draftPackageId = ""
        root.draftChannelId = ""
        root.draftContentTitle = ""
        root.draftChannelName = ""
        root.draftPlatform = ""
        root.draftAssignmentDefinition = ({})
        root.draftDurationSeconds = 1800
        root.draftPublishingPolicy = "approval_required"
        root.draftRetryAttempts = 2
        root.draftRetryBackoffSeconds = 30
        root.previewResult = ({})
        root.resultMessage = ""
        if (root.contentCandidates.length > 0)
            root.selectContentCandidate(0)
    }

    function selectRule(item) {
        const value = item || ({})
        root.selectedRecurrenceKey = String(value.recurrence_key || "")
        root.selectedVersion = Number(value.version || 0)
        root.selectedState = String(value.state || "active")
        root.draftKey = root.selectedRecurrenceKey
        root.draftName = String(value.name || "")
        root.draftTimezone = String(value.timezone || "UTC")
        root.draftFrequency = String(value.frequency || "weekly")
        root.draftInterval = Number(value.interval || 1)
        root.draftWeekdays = (value.weekdays || []).join(",")
        root.draftLocalTime = String(value.local_time || "09:00")
        root.draftStartsOn = String(value.starts_on || "")
        root.draftEndsOn = String(value.ends_on || "")
        root.draftPackageId = String(value.content_package_id || "")
        root.draftChannelId = String(value.channel_id || "")
        root.draftAssignmentDefinition = value.assignment_definition || ({})
        const content = value.content === null || value.content === undefined
            ? ({}) : value.content
        const channel = value.channel === null || value.channel === undefined
            ? ({}) : value.channel
        const presentationMatches = root.draftPackageId === String(value.content_package_id)
            && root.draftChannelId === String(value.channel_id)
        if (content.available) {
            root.draftContentTitle = String(content.title || "")
        } else if (!presentationMatches || !root.draftContentTitle) {
            root.draftContentTitle = "Nội dung không còn khả dụng"
        }
        if (channel.available) {
            root.draftChannelName = String(channel.display_name || "")
            root.draftPlatform = String(channel.platform || "")
        } else if (!presentationMatches || !root.draftChannelName) {
            root.draftChannelName = "Kênh không còn khả dụng"
            root.draftPlatform = ""
        }
        root.draftDurationSeconds = Number(value.duration_seconds || 1800)
        root.draftPublishingPolicy = String(value.publishing_policy || "approval_required")
        const retry = value.retry_policy || ({})
        root.draftRetryAttempts = Number(retry.max_attempts || 1)
        root.draftRetryBackoffSeconds = Number(retry.backoff_seconds || 0)
        if (value.deep_link)
            root.deepLinkRequested(value.deep_link)
    }

    function baseCreatePayload() {
        const payload = {
            "recurrence_key": String(root.effectiveDraftKey || "").trim(),
            "name": String(root.draftName || "").trim(),
            "timezone": String(root.draftTimezone || "").trim(),
            "frequency": String(root.draftFrequency || "weekly"),
            "interval": root.draftInterval,
            "weekdays": root.draftFrequency === "weekly" ? root.weekdays() : [],
            "local_time": String(root.draftLocalTime || "").trim(),
            "starts_on": String(root.draftStartsOn || "").trim(),
            "content_package_id": String(root.draftPackageId || "").trim(),
            "channel_id": String(root.draftChannelId || "").trim(),
            "duration_seconds": root.draftDurationSeconds,
            "publishing_policy": String(root.draftPublishingPolicy),
            "retry_policy": {
                "max_attempts": root.draftRetryAttempts,
                "backoff_seconds": root.draftRetryBackoffSeconds
            },
            "assignment_definition": root.draftAssignmentDefinition,
            "idempotency_key": "ui.schedule.recurrence.create:"
                + root.idempotencyToken(root.effectiveDraftKey)
        }
        const endsOn = String(root.draftEndsOn || "").trim()
        if (endsOn)
            payload.ends_on = endsOn
        return payload
    }

    function submit() {
        if (!root.canWrite || root.recurrenceBusy || !root.formValid)
            return
        if (root.selectedVersion > 0) {
            const revise = {
                "recurrence_key": String(root.draftKey),
                "base_version": root.selectedVersion,
                "name": String(root.draftName),
                "timezone": String(root.draftTimezone),
                "frequency": String(root.draftFrequency),
                "interval": root.draftInterval,
                "weekdays": root.draftFrequency === "weekly" ? root.weekdays() : [],
                "local_time": String(root.draftLocalTime),
                "starts_on": String(root.draftStartsOn),
                "duration_seconds": root.draftDurationSeconds,
                "publishing_policy": String(root.draftPublishingPolicy),
                "retry_policy": {
                    "max_attempts": root.draftRetryAttempts,
                    "backoff_seconds": root.draftRetryBackoffSeconds
                },
                "assignment_definition": root.draftAssignmentDefinition,
                "idempotency_key": "ui.schedule.recurrence.revise:"
                    + root.idempotencyToken(root.draftKey) + ":"
                    + root.selectedVersion
            }
            const endsOn = String(root.draftEndsOn || "").trim()
            if (endsOn)
                revise.ends_on = endsOn
            root.pendingCapability = "schedule.recurrence.revise"
            root.reviseRequested(revise)
        } else {
            root.draftKey = root.effectiveDraftKey
            root.pendingCapability = "schedule.recurrence.create"
            root.createRequested(root.baseCreatePayload())
        }
    }

    function requestList() {
        root.pendingCapability = "schedule.recurrence.list"
        root.listRequested({})
    }

    function requestGet() {
        if (root.selectedRecurrenceKey) {
            root.pendingCapability = "schedule.recurrence.get"
            root.getRequested({"recurrence_key": root.selectedRecurrenceKey})
        }
    }

    function requestPreview() {
        const start = String(root.calendarWindow.start || "")
        const end = String(root.calendarWindow.end || "")
        const key = String(root.selectedRecurrenceKey || "")
        if (!root.canPreview || !key || !start || !end)
            return
        root.pendingCapability = "schedule.recurrence.preview"
        root.previewResult = ({})
        root.resultMessage = ""
        root.previewRequested({
            "recurrence_key": key,
            "window_start": start,
            "window_end": end,
            "limit": 100
        })
    }

    function requestMaterialize() {
        const start = String(root.calendarWindow.start || "")
        const end = String(root.calendarWindow.end || "")
        if (!root.canMaterialize || !start || !end)
            return
        root.pendingCapability = "schedule.recurrence.materialize"
        root.materializeRequested({
            "recurrence_key": root.selectedRecurrenceKey,
            "window_start": start,
            "window_end": end,
            "limit": 100,
            "auto_start": true
        })
    }

    function toggleState() {
        if (!root.canWrite || !root.selectedRecurrenceKey)
            return
        const nextState = root.selectedState === "paused" ? "active" : "paused"
        root.pendingCapability = "schedule.recurrence.state"
        root.stateRequested({
            "recurrence_key": root.selectedRecurrenceKey,
            "state": nextState
        })
    }

    function captureCommandResult() {
        const capability = String(root.pendingCapability || "")
        if (!capability || !root.commandStore)
            return
        const key = String(root.draftKey || root.selectedRecurrenceKey || "")
        const entityType = capability === "schedule.recurrence.list"
            ? "global" : "schedule_recurrence"
        const entityId = capability === "schedule.recurrence.list" ? "global" : key
        if (!entityId)
            return
        const state = root.commandStore.state(capability, entityType, entityId) || ({})
        const status = String(state.state || "")
        const requestId = String(state.request_id || "")
        if (!requestId || requestId === root.lastHandledRequestId
                || (status !== "succeeded" && status !== "failed"))
            return
        root.lastHandledRequestId = requestId
        if (status === "failed") {
            root.resultMessage = String(state.message || "Không thể xử lý quy tắc định kỳ.")
            return
        }
        const result = state.result || ({})
        if (capability === "schedule.recurrence.preview") {
            root.previewResult = result
            root.resultMessage = "Dự kiến " + ((result.occurrences || []).length)
                + " lịch; bỏ qua " + ((result.skipped || []).length) + " lượt."
        } else if (capability === "schedule.recurrence.materialize") {
            root.resultMessage = "Đã tạo " + Number(result.created || 0)
                + " work order; dùng lại " + Number(result.reused || 0)
                + "; chặn " + ((result.blocked || []).length) + " occurrence."
        } else if (capability === "schedule.recurrence.state") {
            const recurrence = result.recurrence || ({})
            if (recurrence.recurrence_key)
                root.selectRule(recurrence)
            root.resultMessage = "Đã cập nhật trạng thái lịch lặp."
        } else if (capability === "schedule.recurrence.get"
                || capability === "schedule.recurrence.create"
                || capability === "schedule.recurrence.revise") {
            const recurrence = result.recurrence || ({})
            if (recurrence.recurrence_key)
                root.selectRule(recurrence)
            root.resultMessage = "Đã lưu quy tắc định kỳ thành công."
        } else if (capability === "schedule.recurrence.list") {
            root.resultMessage = "Đã tải "
                + ((result.recurrences || []).length) + " quy tắc định kỳ."
        }
    }

    onCommandRevisionChanged: root.captureCommandResult()
    onContentCandidatesChanged: {
        if (root.selectedVersion === 0 && !root.draftPackageId
                && root.contentCandidates.length > 0)
            root.selectContentCandidate(0)
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        ColumnLayout {
            id: ruleColumn
            objectName: "scheduleRecurrenceRuleColumn"
            Layout.minimumWidth: Math.max(360, root.width * 0.34)
            Layout.preferredWidth: Math.max(360, root.width * 0.36)
            Layout.maximumWidth: Math.max(360, root.width * 0.38)
            Layout.fillHeight: true
            spacing: 8
            RowLayout {
                Layout.fillWidth: true
                Text { Layout.fillWidth: true; text: "Quy tắc định kỳ"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.DemiBold }
                AppButton { objectName: "scheduleRecurrenceRefreshButton"; text: "Đồng bộ"; leadingIcon: "ui/refresh-cw"; Accessible.name: "Tải danh sách quy tắc định kỳ"; onClicked: root.requestList() }
                AppButton {
                    objectName: "scheduleRecurrenceCreateButton"
                    text: "+ Quy tắc"
                    primary: true
                    enabled: root.canWrite
                    activeFocusOnTab: true
                    Accessible.name: "Tạo quy tắc định kỳ"
                    Accessible.description: enabled ? "Mở bản nháp quy tắc mới" : "Bạn không có quyền chỉnh lịch"
                    onClicked: root.resetCreate()
                }
            }
            Text {
                Layout.fillWidth: true
                text: "Mỗi lần chỉnh sửa tạo một phiên bản mới. Xem trước không tạo lịch thật."
                color: Theme.textFaint
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
            ListView {
                id: ruleList
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6
                clip: true
                reuseItems: true
                model: root.recurrenceModel
                delegate: Rectangle {
                    id: ruleRow
                    required property string entity_id
                    required property string recurrence_key
                    required property int version
                    required property var previous_version_id
                    required property string name
                    required property string state_value
                    required property string timezone
                    required property string frequency
                    required property int interval
                    required property var weekdays
                    required property string local_time
                    required property string starts_on
                    required property var ends_on
                    required property string content_package_id
                    required property string channel_id
                    required property var content
                    required property var channel
                    required property int duration_seconds
                    required property string publishing_policy
                    required property var retry_policy
                    required property var assignment_definition
                    required property string created_at
                    required property var deep_link
                    readonly property var itemData: ({
                        "id": ruleRow.entity_id,
                        "recurrence_key": ruleRow.recurrence_key,
                        "version": ruleRow.version,
                        "previous_version_id": ruleRow.previous_version_id,
                        "name": ruleRow.name,
                        "state": ruleRow.state_value,
                        "timezone": ruleRow.timezone,
                        "frequency": ruleRow.frequency,
                        "interval": ruleRow.interval,
                        "weekdays": ruleRow.weekdays,
                        "local_time": ruleRow.local_time,
                        "starts_on": ruleRow.starts_on,
                        "ends_on": ruleRow.ends_on,
                        "content_package_id": ruleRow.content_package_id,
                        "channel_id": ruleRow.channel_id,
                        "content": ruleRow.content,
                        "channel": ruleRow.channel,
                        "duration_seconds": ruleRow.duration_seconds,
                        "publishing_policy": ruleRow.publishing_policy,
                        "retry_policy": ruleRow.retry_policy,
                        "assignment_definition": ruleRow.assignment_definition,
                        "created_at": ruleRow.created_at,
                        "deep_link": ruleRow.deep_link
                    })
                    function activate() { root.selectRule(ruleRow.itemData) }
                    objectName: "scheduleRecurrence_" + ruleRow.recurrence_key
                    width: ruleList.width
                    height: 76
                    radius: Theme.radiusSmall
                    color: root.selectedRecurrenceKey === ruleRow.recurrence_key
                        ? Theme.accentSoft : Theme.elevated
                    border.width: 1
                    border.color: root.selectedRecurrenceKey === ruleRow.recurrence_key
                        ? Theme.accent : Theme.borderSoft
                    activeFocusOnTab: true
                    Accessible.name: ruleRow.name + ", phiên bản " + ruleRow.version
                    Accessible.description: root.frequencyLabel(ruleRow.frequency)
                        + " · " + ruleRow.local_time
                    Accessible.role: Accessible.ListItem
                    Accessible.focusable: true
                    Keys.onReturnPressed: ruleRow.activate()
                    Keys.onSpacePressed: ruleRow.activate()
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 2
                        RowLayout {
                            Layout.fillWidth: true
                            Text { Layout.fillWidth: true; text: ruleRow.name; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            Foundation.StatusPill { text: root.stateLabel(ruleRow.state_value); tone: ruleRow.state_value === "active" ? Theme.success : Theme.warning; showDot: true }
                        }
                        Text { text: root.frequencyLabel(ruleRow.frequency) + (ruleRow.interval > 1 ? " · mỗi " + ruleRow.interval + " chu kỳ" : "") + " · " + ruleRow.local_time + " · " + root.timezoneLabel(ruleRow.timezone); color: Theme.textMuted; font.pixelSize: 11 }
                        Text {
                            objectName: "scheduleRecurrenceChannel_" + ruleRow.recurrence_key
                            text: "Phiên bản " + ruleRow.version + " · "
                                + (ruleRow.channel.available
                                    ? String(ruleRow.channel.display_name || "Kênh")
                                    : "Kênh không còn khả dụng")
                            color: Theme.textFaint
                            font.pixelSize: 11
                        }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ruleRow.activate() }
                }
            }
            Text {
                visible: !root.recurrenceModel || root.recurrenceModel.count === 0
                Layout.fillWidth: true
                text: "Chưa có quy tắc đăng định kỳ."
                color: Theme.textFaint
                horizontalAlignment: Text.AlignHCenter
                Accessible.name: text
            }
        }

        Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: Theme.borderSoft }

        Flickable {
            id: recurrenceEditorScroll
            objectName: "scheduleRecurrenceEditorScroll"
            Layout.minimumWidth: 520
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: editor.implicitHeight + 16
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            ColumnLayout {
                id: editor
                width: parent.width
                spacing: 9
                Text { text: root.selectedVersion > 0 ? "Chỉnh phiên bản " + root.selectedVersion : "Quy tắc mới"; color: Theme.text; font.pixelSize: 16; font.weight: Font.DemiBold }
                Text { text: "TÊN & TẦN SUẤT"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 0.7 }
                RowLayout {
                    Layout.fillWidth: true
                    ScheduleField { objectName: "scheduleRecurrenceNameField"; Layout.fillWidth: true; text: root.draftName; placeholderText: "Ví dụ: Đăng video mỗi sáng"; Accessible.name: "Tên quy tắc định kỳ"; onTextEdited: { root.draftName = text.trim(); if (root.selectedVersion === 0) root.draftKey = "" } }
                }
                RowLayout {
                    Layout.fillWidth: true
                    ScheduleCombo { objectName: "scheduleRecurrenceFrequencyCombo"; Layout.preferredWidth: 140; model: ["daily", "weekly"]; displayLabels: ({"daily": "Hàng ngày", "weekly": "Hàng tuần"}); currentIndex: Math.max(0, model.indexOf(root.draftFrequency)); displayText: root.draftFrequency === "weekly" ? "Hàng tuần" : "Hàng ngày"; Accessible.name: "Tần suất lặp"; onActivated: root.draftFrequency = String(currentText) }
                    ScheduleSpin { objectName: "scheduleRecurrenceIntervalSpin"; Layout.preferredWidth: 92; from: 1; to: 365; value: root.draftInterval; editable: true; Accessible.name: "Khoảng lặp"; onValueModified: root.draftInterval = value }
                }
                ScheduleWeekdayPicker {
                    objectName: "scheduleRecurrenceWeekdayPicker"
                    Layout.fillWidth: true
                    visible: root.draftFrequency === "weekly"
                    enabled: visible
                    encodedDays: root.draftWeekdays
                    availabilityReason: "Chỉ áp dụng cho quy tắc hàng tuần"
                    onEncodedDaysEdited: function(value) { root.draftWeekdays = value }
                }
                Text { text: "KHUNG THỜI GIAN"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 0.7 }
                RowLayout {
                    Layout.fillWidth: true
                    ScheduleField { objectName: "scheduleRecurrenceLocalTimeField"; Layout.fillWidth: true; text: root.draftLocalTime; placeholderText: "Giờ đăng theo kênh, ví dụ 09:00"; Accessible.name: "Giờ địa phương của kênh"; onTextEdited: root.draftLocalTime = text.trim() }
                    ScheduleCombo {
                        objectName: "scheduleRecurrenceTimezoneField"
                        Layout.fillWidth: true
                        model: root.timezoneLabels()
                        currentIndex: root.timezoneIndex(root.draftTimezone)
                        displayText: root.timezoneLabel(root.draftTimezone)
                        Accessible.name: "Múi giờ của kênh"
                        onActivated: function(index) {
                            const option = root.timezoneOptions[index] || ({})
                            root.draftTimezone = String(option.value || root.draftTimezone)
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    ScheduleField { objectName: "scheduleRecurrenceStartsOnField"; Layout.fillWidth: true; text: root.draftStartsOnText; placeholderText: "Ngày bắt đầu (DD/MM/YYYY)"; Accessible.name: "Ngày bắt đầu quy tắc"; onTextEdited: root.editStartsOn(text) }
                    ScheduleField { objectName: "scheduleRecurrenceEndsOnField"; Layout.fillWidth: true; text: root.draftEndsOnText; placeholderText: "Ngày kết thúc (DD/MM/YYYY), không bắt buộc"; Accessible.name: "Ngày kết thúc quy tắc"; onTextEdited: root.editEndsOn(text) }
                }
                Text { text: "NỘI DUNG & KÊNH"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 0.7 }
                ScheduleCombo {
                    id: recurrenceContentCombo
                    objectName: "scheduleRecurrenceContentCombo"
                    Layout.fillWidth: true
                    visible: root.selectedVersion === 0
                    enabled: visible && root.contentCandidates.length > 0
                    model: root.contentCandidateLabels
                    currentIndex: root.contentCandidateIndex
                    displayText: root.contentCandidateIndex >= 0
                        ? String(root.contentCandidateLabels[root.contentCandidateIndex] || "")
                        : "Chưa có nội dung sẵn sàng"
                    Accessible.name: "Chọn nội dung và kênh cho quy tắc"
                    onActivated: function(index) { root.selectContentCandidate(index) }
                }
                Rectangle {
                    objectName: "scheduleRecurrenceContentSummary"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: Theme.radiusSmall
                    color: Theme.elevated
                    border.width: 1
                    border.color: Theme.borderSoft
                    Text {
                        objectName: "scheduleRecurrenceContentSummaryText"
                        anchors.fill: parent
                        anchors.margins: 10
                        text: root.contentSummary()
                        color: Theme.textMuted
                        font.pixelSize: 11
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }
                Text { text: "CHÍNH SÁCH PHÁT HÀNH"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 0.7 }
                RowLayout {
                    Layout.fillWidth: true
                    ScheduleSpin { objectName: "scheduleRecurrenceDurationSpin"; Layout.preferredWidth: 130; from: 60; to: 86400; stepSize: 60; value: root.draftDurationSeconds; editable: true; displayDivisor: 60; unitSuffix: "phút"; Accessible.name: "Thời lượng mỗi lịch theo phút"; onValueModified: root.draftDurationSeconds = value }
                    ScheduleCombo { objectName: "scheduleRecurrencePublishingPolicyCombo"; Layout.fillWidth: true; model: ["approval_required", "scheduled_approval"]; displayLabels: ({"approval_required": "Cần phê duyệt trước khi đăng", "scheduled_approval": "Duyệt theo lịch đã đặt"}); currentIndex: Math.max(0, model.indexOf(root.draftPublishingPolicy)); displayText: root.draftPublishingPolicy === "scheduled_approval" ? "Duyệt theo lịch đã đặt" : "Cần phê duyệt trước khi đăng"; Accessible.name: "Chính sách xuất bản định kỳ"; onActivated: root.draftPublishingPolicy = String(currentText) }
                    ScheduleSpin { objectName: "scheduleRecurrenceRetryAttemptsSpin"; Layout.preferredWidth: 90; from: 1; to: 10; value: root.draftRetryAttempts; editable: true; unitSuffix: "lần"; Accessible.name: "Số lần thử lại"; onValueModified: root.draftRetryAttempts = value }
                    ScheduleSpin { objectName: "scheduleRecurrenceRetryBackoffSpin"; Layout.preferredWidth: 105; from: 0; to: 86400; value: root.draftRetryBackoffSeconds; editable: true; unitSuffix: "giây"; Accessible.name: "Khoảng chờ thử lại"; onValueModified: root.draftRetryBackoffSeconds = value }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                RowLayout {
                    Layout.fillWidth: true
                    AppButton { objectName: "scheduleRecurrenceGetExactButton"; text: "Tải bản đã lưu"; enabled: Boolean(root.selectedRecurrenceKey); availabilityReason: enabled ? "" : "Chưa chọn quy tắc"; Accessible.name: "Tải quy tắc đã lưu"; onClicked: root.requestGet() }
                    AppButton { objectName: "scheduleRecurrencePreviewButton"; text: "Xem lịch dự kiến"; enabled: root.canPreview; availabilityReason: enabled ? "" : "Chọn một quy tắc đã lưu"; Accessible.name: "Xem trước các lịch trong cửa sổ hiện tại"; Accessible.description: enabled ? "Chỉ xem trước, không tạo lịch hoặc xuất bản" : availabilityReason; onClicked: root.requestPreview() }
                    Item { Layout.fillWidth: true }
                }
                RowLayout {
                    Layout.fillWidth: true
                    AppButton {
                        objectName: "scheduleRecurrenceStateButton"
                        text: root.selectedState === "paused" ? "Kích hoạt" : "Tạm dừng"
                        enabled: root.canWrite && Boolean(root.selectedRecurrenceKey)
                        leadingIcon: root.selectedState === "paused" ? "ui/play" : "ui/pause"
                        onClicked: root.toggleState()
                    }
                    AppButton {
                        objectName: "scheduleRecurrenceMaterializeButton"
                        text: "Tạo work order"
                        enabled: root.canMaterialize
                        leadingIcon: "ui/check"
                        onClicked: root.requestMaterialize()
                    }
                    Item { Layout.fillWidth: true }
                    AppButton {
                        objectName: "scheduleRecurrenceSubmitButton"
                        text: root.recurrenceBusy ? "Đang lưu…" : (root.selectedVersion > 0 ? "Lưu phiên bản mới" : "Tạo quy tắc")
                        primary: true
                        enabled: root.canWrite && !root.recurrenceBusy && root.formValid
                        Accessible.name: text
                        Accessible.description: enabled ? "Lưu thành một phiên bản mới" : "Biểu mẫu chưa hợp lệ hoặc thiếu quyền"
                        onClicked: root.submit()
                    }
                }
                Rectangle {
                    objectName: "scheduleRecurrenceResult"
                    Layout.fillWidth: true
                    Layout.preferredHeight: previewColumn.implicitHeight + 18
                    visible: Boolean(root.resultMessage)
                    radius: Theme.radiusSmall
                    color: Theme.elevated
                    border.width: 1
                    border.color: Theme.borderSoft
                    ColumnLayout {
                        id: previewColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 4
                        Text {
                            Layout.fillWidth: true
                            text: root.resultMessage
                            color: Theme.info
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            wrapMode: Text.Wrap
                        }
                        Repeater {
                            model: (root.previewResult.occurrences || []).slice(0, 5)
                            delegate: Text {
                                id: previewOccurrence
                                required property var modelData
                                Layout.fillWidth: true
                                text: String(previewOccurrence.modelData.local_date || "")
                                    + " · " + String(previewOccurrence.modelData.run_at || "")
                                color: Theme.textMuted
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
