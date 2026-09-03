pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

ScheduleDialog {
    id: root
    objectName: "scheduleCapacityDialog"
    property bool canWrite: false
    property var commandStore: null
    property int commandRevision: 0
    property var editor: ({})
    property var currentPolicy: ({})
    property bool revisionMode: String(root.currentPolicy.policy_key || "").length > 0
    property string draftPolicyKey: ""
    property string draftChannelId: ""
    property string draftPlatform: "tiktok"
    property string draftTimezone: "Asia/Bangkok"
    property int draftDailyLimit: 10
    property int draftMinimumGap: 30
    property string draftWeekdays: "0,1,2,3,4,5,6"
    property string draftStartTime: "09:00"
    property string draftEndTime: "21:00"
    property string draftObservedAt: ""
    property string draftExpiresAt: ""
    property var draftWindows: []
    property string pendingCapability: ""
    property string lastHandledRequestId: ""
    property string resultMessage: ""

    function timezoneLabel(value) {
        const text = String(value || "")
        if (text === "Asia/Bangkok" || text === "Asia/Ho_Chi_Minh")
            return "Giờ Việt Nam"
        if (text === "UTC")
            return "Giờ quốc tế (UTC)"
        return "Múi giờ của kênh"
    }
    property var scopeOptions: []
    property var scopeLabels: []
    property int draftScopeIndex: -1
    property string scopeLabel: ""
    property string evidenceLabel: ""
    readonly property bool editorAvailable: root.editor.available === true
    readonly property bool busy: {
        const unused = root.commandRevision
        const key = String(root.draftPolicyKey || "")
        if (!root.commandStore || !key)
            return unused < 0
        const capability = root.revisionMode
            ? "schedule.capacity.revise" : "schedule.capacity.create"
        return root.commandStore.isBusy(capability, "schedule_capacity", key)
    }
    readonly property bool weekdaysValid: root.validWeekdaysText(root.draftWeekdays)
    readonly property bool primaryWindowValid:
        root.validLocalTime(root.draftStartTime)
        && root.validLocalTime(root.draftEndTime)
        && root.draftStartTime < root.draftEndTime
    readonly property bool evidenceTimesValid:
        root.validAwareIso(root.draftObservedAt)
        && (!String(root.draftExpiresAt || "").trim()
            || (root.validAwareIso(root.draftExpiresAt)
                && Date.parse(root.draftExpiresAt) > Date.parse(root.draftObservedAt)))
    readonly property bool formValid:
        /^[A-Za-z0-9][A-Za-z0-9._:@-]{0,119}$/.test(
            String(root.draftPolicyKey || "")
        )
        && Boolean(root.normalizedOptional(root.draftPlatform))
        && Boolean(String(root.draftTimezone || "").trim())
        && root.draftDailyLimit >= 1 && root.draftDailyLimit <= 10000
        && root.draftMinimumGap >= 0 && root.draftMinimumGap <= 1440
        && root.weekdaysValid && root.primaryWindowValid
        && root.evidenceTimesValid
    signal createRequested(var payload)
    signal reviseRequested(var payload)
    width: 650
    height: 620
    title: root.revisionMode
        ? "Chỉnh sức chứa phát hành" : "Tạo chính sách sức chứa"
    showDefaultFooter: false

    function slug(value) {
        return String(value || "").trim().replace(/[^A-Za-z0-9._@-]+/g, "-")
            .replace(/^-+|-+$/g, "") || "policy"
    }

    function normalizedOptional(value) {
        if (value === undefined || value === null)
            return ""
        const text = String(value).trim()
        const lowered = text.toLowerCase()
        return lowered === "undefined" || lowered === "null" ? "" : text
    }

    function parseWeekdays() {
        const parts = String(root.draftWeekdays || "").split(",")
        const values = []
        for (let index = 0; index < parts.length; ++index) {
            const value = Number(String(parts[index]).trim())
            if (Number.isInteger(value) && value >= 0 && value <= 6
                    && values.indexOf(value) < 0)
                values.push(value)
        }
        return values
    }

    function validWeekdaysText(value) {
        const text = String(value || "")
        if (!/^[0-6](,[0-6])*$/.test(text))
            return false
        const parts = text.split(",")
        return root.parseWeekdays().length === parts.length
    }

    function validLocalTime(value) {
        return /^(?:[01]\d|2[0-3]):[0-5]\d$/.test(String(value || ""))
    }

    function validAwareIso(value) {
        const text = String(value || "")
        return /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?(?:Z|[+-]\d{2}:\d{2})$/.test(text)
            && !isNaN(Date.parse(text))
    }

    function cloneWindows(windows) {
        const source = windows || []
        const result = []
        for (let index = 0; index < source.length; ++index) {
            const value = source[index] || ({})
            result.push({
                "weekdays": (value.weekdays || []).slice(0),
                "start_time": String(value.start_time || value.start || "09:00"),
                "end_time": String(value.end_time || value.end || "21:00")
            })
        }
        return result
    }

    function rebuildScopeOptions() {
        const source = root.editor.scope_options || []
        const options = []
        const labels = []
        for (let index = 0; index < source.length; ++index) {
            const raw = source[index]
            if (raw === null || raw === undefined)
                continue
            options.push({
                "key": String(raw.key || ""),
                "label": String(raw.label || ""),
                "policy_key": String(raw.policy_key || ""),
                "channel_id": root.normalizedOptional(raw.channel_id),
                "platform": String(raw.platform || ""),
                "timezone": String(raw.timezone || root.editor.default_timezone || "UTC")
            })
            labels.push(String(raw.label || ""))
        }
        root.scopeOptions = options
        root.scopeLabels = labels
        return options.length
    }

    function applyScope(index) {
        const selectedIndex = Number(index)
        if (selectedIndex < 0 || selectedIndex >= root.scopeOptions.length)
            return false
        const option = root.scopeOptions[selectedIndex]
        root.draftScopeIndex = selectedIndex
        root.draftPolicyKey = String(option.policy_key || "")
        root.draftChannelId = root.normalizedOptional(option.channel_id)
        root.draftPlatform = String(option.platform || "")
        root.draftTimezone = String(option.timezone || root.editor.default_timezone || "UTC")
        root.scopeLabel = String(option.label || "")
        return true
    }

    function mergedWindows() {
        const windows = root.cloneWindows(root.draftWindows)
        const first = {
            "weekdays": root.parseWeekdays(),
            "start_time": String(root.draftStartTime || "").trim(),
            "end_time": String(root.draftEndTime || "").trim()
        }
        if (windows.length)
            windows[0] = first
        else
            windows.push(first)
        return windows
    }

    function openCreate() {
        if (!root.canWrite || !root.editorAvailable)
            return false
        root.currentPolicy = ({})
        root.rebuildScopeOptions()
        if (!root.scopeOptions.length)
            return false
        root.draftScopeIndex = -1
        root.draftPolicyKey = ""
        root.draftChannelId = ""
        root.draftPlatform = ""
        root.draftTimezone = String(root.editor.default_timezone || "Asia/Bangkok")
        if (root.scopeOptions.length)
            root.applyScope(0)
        root.draftDailyLimit = 10
        root.draftMinimumGap = 30
        root.draftWeekdays = "0,1,2,3,4,5,6"
        root.draftStartTime = "09:00"
        root.draftEndTime = "21:00"
        root.draftWindows = [{
            "weekdays": [0, 1, 2, 3, 4, 5, 6],
            "start_time": "09:00",
            "end_time": "21:00"
        }]
        root.draftObservedAt = String(root.editor.observed_at || "")
        root.draftExpiresAt = String(root.editor.default_expires_at || "")
        root.evidenceLabel = String(root.editor.evidence_label || "")
        root.resultMessage = ""
        root.open()
        return true
    }

    function openPolicy(policy) {
        const value = policy || ({})
        root.currentPolicy = value
        root.draftPolicyKey = String(value.policy_key || "")
        root.draftChannelId = root.normalizedOptional(value.channel_id)
        root.draftPlatform = root.normalizedOptional(value.platform).toLowerCase()
        root.draftTimezone = String(value.timezone || "UTC")
        root.draftDailyLimit = Number(value.daily_limit || value.limit || 1)
        root.draftMinimumGap = Number(value.minimum_gap_minutes || 0)
        root.draftWindows = root.cloneWindows(value.windows || [])
        const firstWindow = root.draftWindows[0] || ({})
        root.draftWeekdays = (firstWindow.weekdays || []).join(",")
        root.draftStartTime = String(firstWindow.start_time || "09:00")
        root.draftEndTime = String(firstWindow.end_time || "21:00")
        root.draftObservedAt = String(value.observed_at || new Date().toISOString())
        root.draftExpiresAt = String(value.expires_at || "")
        root.scopeLabel = String((value.scope || {}).label || "Phạm vi hiện tại")
        root.evidenceLabel = String((value.evidence || {}).label || "")
        root.resultMessage = ""
        root.open()
    }

    function payloadBase() {
        const payload = {
            "policy_key": String(root.draftPolicyKey || "").trim(),
            "platform": root.normalizedOptional(root.draftPlatform).toLowerCase(),
            "timezone": String(root.draftTimezone || "").trim(),
            "daily_limit": root.draftDailyLimit,
            "minimum_gap_minutes": root.draftMinimumGap,
            "windows": root.mergedWindows(),
            "observed_at": String(root.draftObservedAt || "").trim(),
            "idempotency_key": "ui.schedule.capacity:" + root.slug(root.draftPolicyKey)
                + ":" + (root.revisionMode
                    ? String(root.currentPolicy.version || 0) : "create")
        }
        const channelId = root.normalizedOptional(root.draftChannelId)
        const expiresAt = String(root.draftExpiresAt || "").trim()
        if (channelId)
            payload.channel_id = channelId
        if (expiresAt)
            payload.expires_at = expiresAt
        return payload
    }

    function submit() {
        if (!root.canWrite || root.busy || !root.formValid)
            return
        const payload = root.payloadBase()
        if (root.revisionMode) {
            payload.base_version = root.currentPolicy.version
            if (payload.base_version < 1)
                return
            root.pendingCapability = "schedule.capacity.revise"
            root.reviseRequested(payload)
        } else {
            root.pendingCapability = "schedule.capacity.create"
            root.createRequested(payload)
        }
    }

    function captureCommandResult() {
        const capability = String(root.pendingCapability || "")
        const key = String(root.draftPolicyKey || "")
        if (!capability || !key || !root.commandStore)
            return
        const state = root.commandStore.state(
            capability, "schedule_capacity", key
        ) || ({})
        const status = String(state.state || "")
        const requestId = String(state.request_id || "")
        if (!requestId || requestId === root.lastHandledRequestId
                || (status !== "succeeded" && status !== "failed"))
            return
        root.lastHandledRequestId = requestId
        if (status === "failed") {
            root.resultMessage = String(state.message || "Không thể lưu quy tắc sức chứa.")
            return
        }
        const policy = (state.result || {}).policy || ({})
        root.resultMessage = "Đã lưu quy tắc sức chứa thành công."
    }

    onCommandRevisionChanged: root.captureCommandResult()

    contentItem: Flickable {
        clip: true
        contentWidth: width
        contentHeight: form.implicitHeight + 16
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
        ColumnLayout {
            id: form
            width: parent.width
            spacing: 9
            Text {
                Layout.fillWidth: true
                text: "Mỗi lần lưu tạo một phiên bản mới để kiểm tra và đối chiếu; dữ liệu cũ không bị ghi đè."
                color: Theme.textFaint
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                visible: root.revisionMode && root.draftWindows.length > 1
                text: "Đang giữ nguyên " + (root.draftWindows.length - 1)
                    + " cửa sổ bổ sung từ server; form này chỉnh cửa sổ đầu tiên."
                color: Theme.info
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            FormLabel {
                objectName: "scheduleCapacityScopeLabel"
                text: "PHẠM VI ÁP DỤNG"
            }
            ScheduleCombo {
                id: scopeCombo
                objectName: "scheduleCapacityScopeCombo"
                visible: !root.revisionMode
                Layout.fillWidth: true
                model: root.scopeLabels
                currentIndex: root.draftScopeIndex
                displayText: root.draftScopeIndex >= 0
                    ? String(root.scopeLabels[root.draftScopeIndex] || "")
                    : "Chọn nền tảng hoặc kênh"
                Accessible.name: "Phạm vi áp dụng sức chứa"
                onActivated: function(index) { root.applyScope(index) }
            }
            Rectangle {
                objectName: "scheduleCapacityScopeSummary"
                visible: root.revisionMode
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    UiIcon { name: root.draftPlatform ? "product/" + root.draftPlatform : "ui/globe"; tone: Theme.accent; iconSize: 17 }
                    Text { objectName: "scheduleCapacityScopeSummaryText"; Layout.fillWidth: true; text: root.scopeLabel; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                    Text { text: root.timezoneLabel(root.draftTimezone); color: Theme.textMuted; font.pixelSize: 11 }
                }
                Accessible.name: "Phạm vi hiện tại: " + root.scopeLabel
                Accessible.role: Accessible.StaticText
            }
            FormLabel { text: "GIỚI HẠN XUẤT BẢN" }
            CaptionPair { leftText: "Tối đa mỗi ngày"; rightText: "Giãn cách tối thiểu" }
            RowLayout {
                Layout.fillWidth: true
                ScheduleSpin { objectName: "scheduleCapacityDailyLimitSpin"; Layout.fillWidth: true; from: 1; to: 10000; value: root.draftDailyLimit; editable: true; unitSuffix: "bài"; Accessible.name: "Giới hạn bài mỗi ngày"; onValueModified: root.draftDailyLimit = value }
                ScheduleSpin { objectName: "scheduleCapacityMinimumGapSpin"; Layout.fillWidth: true; from: 0; to: 1440; value: root.draftMinimumGap; editable: true; unitSuffix: "phút"; Accessible.name: "Khoảng cách tối thiểu giữa hai bài"; onValueModified: root.draftMinimumGap = value }
            }
            FormLabel {
                objectName: "scheduleCapacityWindowLabel"
                text: "KHUNG GIỜ HOẠT ĐỘNG"
            }
            Text { text: "Ngày áp dụng"; color: Theme.textMuted; font.pixelSize: 11 }
            ScheduleWeekdayPicker {
                objectName: "scheduleCapacityWeekdayPicker"
                Layout.fillWidth: true
                encodedDays: root.draftWeekdays
                onEncodedDaysEdited: function(value) { root.draftWeekdays = value }
            }
            RowLayout {
                Layout.fillWidth: true
                ScheduleField { objectName: "scheduleCapacityStartTimeField"; Layout.fillWidth: true; text: root.draftStartTime; placeholderText: "09:00"; Accessible.name: "Giờ bắt đầu cửa sổ"; onTextEdited: root.draftStartTime = text.trim() }
                ScheduleField { objectName: "scheduleCapacityEndTimeField"; Layout.fillWidth: true; text: root.draftEndTime; placeholderText: "21:00"; Accessible.name: "Giờ kết thúc cửa sổ"; onTextEdited: root.draftEndTime = text.trim() }
            }
            FormLabel { text: "HIỆU LỰC DỮ LIỆU" }
            Rectangle {
                objectName: "scheduleCapacityEvidenceSummary"
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                radius: Theme.radiusSmall
                color: Theme.accentSoft
                border.width: 1
                border.color: Theme.info
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    UiIcon { name: "ui/calendar"; tone: Theme.info; iconSize: 14 }
                    Text { objectName: "scheduleCapacityEvidenceSummaryText"; Layout.fillWidth: true; text: root.evidenceLabel || "Thời điểm hiệu lực do hệ thống quản lý"; color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                }
                Accessible.name: root.evidenceLabel
                Accessible.role: Accessible.StaticText
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.borderSoft
            }
            Text {
                objectName: "scheduleCapacityResult"
                Layout.fillWidth: true
                visible: Boolean(root.resultMessage)
                text: root.resultMessage
                color: Theme.info
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                AppButton { objectName: "scheduleCapacityCancelButton"; text: "Hủy"; Accessible.name: "Hủy chỉnh quy tắc sức chứa"; onClicked: root.reject() }
                AppButton {
                    objectName: "scheduleCapacitySubmitButton"
                    text: root.busy ? "Đang lưu…" : (root.revisionMode
                        ? "Lưu phiên bản mới" : "Tạo chính sách")
                    primary: true
                    enabled: root.canWrite && !root.busy && root.formValid
                    Accessible.name: text
                    Accessible.description: enabled
                        ? "Gửi yêu cầu lưu chính sách tới hệ thống"
                        : "Biểu mẫu chưa hợp lệ hoặc thiếu quyền quản trị"
                    onClicked: root.submit()
                }
            }
        }
    }

    component FormLabel: Text {
        Layout.fillWidth: true
        color: Theme.textFaint
        font.pixelSize: 11
        font.weight: Font.Bold
        font.letterSpacing: 0.7
    }

    component CaptionPair: RowLayout {
        property string leftText: ""
        property string rightText: ""
        Layout.fillWidth: true
        spacing: 9
        Text { Layout.fillWidth: true; text: parent.leftText; color: Theme.textMuted; font.pixelSize: 11 }
        Text { Layout.fillWidth: true; text: parent.rightText; color: Theme.textMuted; font.pixelSize: 11 }
    }
}
