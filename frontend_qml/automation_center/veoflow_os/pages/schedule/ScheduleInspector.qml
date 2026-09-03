pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "scheduleInspector"
    property var schedule: ({})
    property var publishDispatch: ({})
    property var controlPlaneBridge: null
    property bool canWrite: false
    property var commandStore: null
    property int commandRevision: 0
    property string draftRunAt: ""
    property string draftTimezone: "UTC"
    property string draftLocalDate: ""
    property string draftLocalDateText: ""
    property string draftLocalTime: ""
    property string localTimeError: ""
    property int draftDurationSeconds: 1800
    property string draftPublishingPolicy: "approval_required"
    property int draftRetryAttempts: 1
    property int draftRetryBackoffSeconds: 0
    property bool draftDirty: false
    property bool resettingDraft: false
    property string proposalKind: ""
    property var conflictPreviewResult: ({})
    property bool conflictPreviewPending: false
    property string conflictPreviewError: ""
    readonly property string scheduleId: String(root.schedule.id || "")
    readonly property int scheduleVersion: Number(root.schedule.version || 0)
    readonly property var actions: root.schedule.actions || ({})
    readonly property bool updateBusy: {
        const unused = root.commandRevision
        return root.commandStore && root.scheduleId
            ? root.commandStore.isBusy("schedule.update", "schedule", root.scheduleId)
            : unused < 0
    }
    readonly property bool publishBusy: {
        const unused = root.commandRevision
        return root.commandStore && root.scheduleId
            ? root.commandStore.isBusy(
                "schedule.publish_now.request", "schedule", root.scheduleId
            ) : unused < 0
    }
    readonly property bool cancelBusy: {
        const unused = root.commandRevision
        return root.commandStore && root.scheduleId
            ? root.commandStore.isBusy("schedule.cancel", "schedule", root.scheduleId)
            : unused < 0
    }
    readonly property bool canEdit: root.canWrite
        && Boolean((root.actions.save || {}).available)
        && root.scheduleId.length > 0 && root.scheduleVersion > 0
        && !root.updateBusy
    readonly property bool draftValid: Boolean(String(root.draftRunAt || "").trim())
        && Boolean(String(root.draftTimezone || "").trim())
        && Boolean(String(root.draftLocalDate || "").trim())
        && Boolean(String(root.draftLocalTime || "").trim())
        && !root.localTimeError
        && root.draftDurationSeconds >= 60
        && root.draftRetryAttempts >= 1 && root.draftRetryBackoffSeconds >= 0
    readonly property bool canSave: root.canEdit && root.draftValid
        && root.draftDirty
    readonly property bool canPublishNow: root.canWrite
        && Boolean((root.actions.publish_now || {}).available)
        && root.scheduleId.length > 0 && root.scheduleVersion > 0
        && !root.draftDirty && !root.publishBusy
    readonly property bool canCancel: root.canWrite
        && Boolean((root.actions.cancel || {}).available)
        && root.scheduleId.length > 0 && root.scheduleVersion > 0 && !root.cancelBusy
    readonly property var activeConflictAnalysis:
        root.conflictPreviewResult.conflict !== undefined
            ? root.conflictPreviewResult
            : (root.schedule.conflict_analysis || ({}))
    signal conflictPreviewRequested(var payload)
    signal saveRequested(var payload)
    signal publishNowRequested(var payload)
    signal cancelRequested()
    signal deepLinkRequested(var link)
    signal closeRequested()
    Accessible.name: "Chi tiết lịch xuất bản"
    Accessible.role: Accessible.Pane

    function slug(value) {
        let normalized = String(value || "").trim()
        normalized = normalized.replace(/[^A-Za-z0-9._@-]+/g, "-")
            .replace(/^-+|-+$/g, "")
        return normalized || "change"
    }

    function resetDraft() {
        root.resettingDraft = true
        root.draftRunAt = String(root.schedule.run_at || "")
        root.draftTimezone = String(root.schedule.timezone || "UTC")
        const local = String(root.schedule.local_time || "")
        root.draftLocalDate = local.slice(0, 10)
        root.draftLocalDateText = root.displayDate(root.draftLocalDate)
        root.draftLocalTime = local.slice(11, 16)
        root.localTimeError = ""
        if ((!root.draftLocalDate || !root.draftLocalTime)
                && root.controlPlaneBridge) {
            const projected = root.controlPlaneBridge.scheduleLocalFromUtc(
                root.draftRunAt, root.draftTimezone
            )
            if (projected.available === true) {
                root.draftLocalDate = String(projected.date)
                root.draftLocalDateText = root.displayDate(root.draftLocalDate)
                root.draftLocalTime = String(projected.time)
            }
        }
        root.draftDurationSeconds = Number(root.schedule.duration_seconds || 1800)
        root.draftPublishingPolicy = String(
            root.schedule.publishing_policy || "approval_required"
        )
        const retry = root.schedule.retry_policy || ({})
        root.draftRetryAttempts = Number(retry.max_attempts || 1)
        root.draftRetryBackoffSeconds = Number(retry.backoff_seconds || 0)
        root.proposalKind = ""
        root.conflictPreviewResult = ({})
        root.conflictPreviewPending = false
        root.conflictPreviewError = ""
        root.draftDirty = false
        root.resettingDraft = false
    }

    function localScheduleSummary() {
        const parts = root.draftLocalDate.split("-")
        const localDate = parts.length === 3
            ? parts[2] + "/" + parts[1] + "/" + parts[0]
            : root.draftLocalDate
        return localDate + " · " + root.draftLocalTime + " · "
            + root.timezoneLabel(root.draftTimezone)
    }

    function validDate(value) {
        const text = String(value || "")
        if (!/^\d{4}-\d{2}-\d{2}$/.test(text))
            return false
        const parsed = new Date(text + "T00:00:00Z")
        return !isNaN(parsed.getTime())
            && parsed.toISOString().slice(0, 10) === text
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
        return root.validDate(candidate) ? candidate : ""
    }

    function editLocalDate(value) {
        root.draftLocalDateText = String(value || "").trim()
        const parsed = root.parseDisplayDate(root.draftLocalDateText)
        if (parsed) {
            root.draftLocalDate = parsed
            return
        }
        root.draftRunAt = ""
        root.localTimeError = "Nhập ngày theo định dạng ngày/tháng/năm."
    }

    function observedAtLabel(value) {
        const raw = String(value || "")
        if (!raw)
            return "Chưa có thời điểm kiểm tra"
        if (root.controlPlaneBridge) {
            const projected = root.controlPlaneBridge.scheduleLocalFromUtc(
                raw, root.draftTimezone
            )
            if (projected.available === true)
                return "Đã kiểm tra " + root.displayDate(String(projected.date))
                    + " · " + String(projected.time)
        }
        const date = raw.slice(0, 10)
        const time = raw.slice(11, 16)
        return "Đã kiểm tra " + root.displayDate(date)
            + (time ? " · " + time : "")
    }

    function timezoneLabel(value) {
        const text = String(value || "")
        if (text === "Asia/Bangkok" || text === "Asia/Ho_Chi_Minh")
            return "Giờ Việt Nam"
        if (text === "UTC")
            return "Giờ quốc tế (UTC)"
        return "Múi giờ của kênh"
    }

    function syncLocalFromUtc(runAt, timezone) {
        const normalizedRunAt = String(runAt || "")
        const normalizedTimezone = String(timezone || root.draftTimezone || "UTC")
        if (!root.controlPlaneBridge || !normalizedRunAt || !normalizedTimezone)
            return false
        const projected = root.controlPlaneBridge.scheduleLocalFromUtc(
            normalizedRunAt, normalizedTimezone
        )
        if (projected.available !== true)
            return false
        const wasResetting = root.resettingDraft
        root.resettingDraft = true
        root.draftRunAt = normalizedRunAt
        root.draftTimezone = normalizedTimezone
        root.draftLocalDate = String(projected.date)
        root.draftLocalDateText = root.displayDate(root.draftLocalDate)
        root.draftLocalTime = String(projected.time)
        root.localTimeError = ""
        root.resettingDraft = wasResetting
        if (!wasResetting)
            root.markDraftChanged()
        return true
    }

    function updateRunAtFromLocal() {
        if (root.resettingDraft)
            return false
        const converted = root.controlPlaneBridge
            ? String(root.controlPlaneBridge.scheduleUtcFromLocal(
                root.draftLocalDate,
                root.draftLocalTime,
                root.draftTimezone
            ) || "") : ""
        root.localTimeError = converted ? ""
            : "Giờ này không tồn tại hoặc bị lặp trong múi giờ đã chọn."
        root.draftRunAt = converted
        return Boolean(converted)
    }

    function recommendationSummary() {
        const recommendation = (root.activeConflictAnalysis || {}).recommendation || ({})
        const projected = root.controlPlaneBridge
            ? root.controlPlaneBridge.scheduleLocalFromUtc(
                String(recommendation.run_at || ""),
                String(recommendation.timezone || root.draftTimezone)
            ) : ({})
        if (projected.available !== true)
            return "Hệ thống đề xuất một khung giờ khác"
        const parts = String(projected.date).split("-")
        const date = parts.length === 3
            ? parts[2] + "/" + parts[1] + "/" + parts[0]
            : String(projected.date)
        return date + " · " + String(projected.time) + " · "
            + root.timezoneLabel(projected.timezone)
    }

    function dependencyStateLabel(state) {
        switch (String(state || "")) {
        case "ready": return "Sẵn sàng"
        case "not_requested": return "Chưa yêu cầu"
        case "pending": return "Đang chờ"
        case "blocked": return "Đang bị chặn"
        case "failed": return "Thất bại"
        default: return "Chưa xác định"
        }
    }

    function approvalStateLabel(state) {
        switch (String(state || "")) {
        case "approved": return "Đã phê duyệt"
        case "pending": return "Đang chờ duyệt"
        case "rejected": return "Đã từ chối"
        case "not_requested": return "Chưa yêu cầu"
        default: return "Chưa yêu cầu"
        }
    }

    function conflictMessage(conflict) {
        const value = conflict || ({})
        switch (String(value.rule || "")) {
        case "minimum_gap":
            return "Khoảng cách với lịch gần nhất chưa đạt chính sách."
        case "overlap":
            return "Khung giờ này trùng với một lịch khác."
        case "daily_limit":
            return "Kênh đã đạt giới hạn xuất bản trong ngày."
        case "outside_window":
            return "Thời điểm này nằm ngoài khung giờ được phép xuất bản."
        default:
            return "Thời điểm này chưa phù hợp với chính sách xuất bản."
        }
    }

    function activitySummary(activity) {
        const value = activity || ({})
        switch (String(value.event_type || "")) {
        case "schedule.created": return "Đã tạo lịch xuất bản."
        case "schedule.updated": return "Đã cập nhật lịch xuất bản."
        case "schedule.cancelled": return "Đã hủy lịch xuất bản."
        case "schedule.publish_requested": return "Đã gửi yêu cầu đăng ngay."
        default: return "Hoạt động lịch đã được ghi nhận."
        }
    }

    function applyProposal(proposal) {
        const value = proposal || ({})
        if (String(value.id || "") !== root.scheduleId)
            return
        root.syncLocalFromUtc(
            String(value.run_at || root.draftRunAt),
            String(value.timezone || root.draftTimezone)
        )
        root.draftDurationSeconds = Number(
            value.duration_seconds || root.draftDurationSeconds
        )
        root.proposalKind = String(value.kind || "proposal")
        root.draftDirty = true
        root.previewConflict()
    }

    function previewConflict() {
        const channelId = String(root.schedule.channel_id || "")
        if (!root.canWrite || !channelId || !root.draftRunAt || !root.draftTimezone)
            return
        root.conflictPreviewResult = ({})
        root.conflictPreviewError = ""
        root.conflictPreviewPending = true
        root.conflictPreviewRequested({
            "channel_id": channelId,
            "platform": String(root.schedule.platform || ""),
            "run_at": root.draftRunAt,
            "timezone": root.draftTimezone,
            "duration_seconds": root.draftDurationSeconds,
            "exclude_schedule_id": root.scheduleId
        })
    }

    function saveChanges() {
        if (!root.canSave || !root.draftRunAt || !root.draftTimezone)
            return
        root.saveRequested({
            "schedule_id": root.scheduleId,
            "expected_version": root.scheduleVersion,
            "run_at": root.draftRunAt,
            "timezone": root.draftTimezone,
            "duration_seconds": root.draftDurationSeconds,
            "publishing_policy": root.draftPublishingPolicy,
            "retry_policy": {
                "max_attempts": root.draftRetryAttempts,
                "backoff_seconds": root.draftRetryBackoffSeconds
            },
            "idempotency_key": "ui.schedule.update:" + root.scheduleId + ":"
                + root.scheduleVersion + ":" + root.slug(root.draftRunAt)
        })
    }

    function publishNow() {
        if (!root.canPublishNow)
            return
        root.publishNowRequested({
            "schedule_id": root.scheduleId,
            "expected_version": root.scheduleVersion,
            "idempotency_key": "ui.schedule.publish-now:" + root.scheduleId
                + ":" + root.scheduleVersion
        })
    }

    function applyRecommendation() {
        if (!root.canEdit || root.conflictPreviewPending || root.conflictPreviewError)
            return
        const recommendation = (root.activeConflictAnalysis || {}).recommendation || ({})
        if (!String(recommendation.run_at || ""))
            return
        if (!root.syncLocalFromUtc(
                String(recommendation.run_at),
                String(recommendation.timezone || root.draftTimezone)))
            return
        root.proposalKind = "recommendation"
        root.draftDirty = true
    }

    function captureConflictPreview() {
        if (!root.conflictPreviewPending || !root.commandStore)
            return
        const channelId = String(root.schedule.channel_id || "")
        if (!channelId)
            return
        const state = root.commandStore.state(
            "schedule.conflict.preview", "channel", channelId
        ) || ({})
        const status = String(state.state || "")
        if (status === "succeeded") {
            const result = state.result || ({})
            if (result.conflict !== undefined) {
                root.conflictPreviewResult = result
                root.conflictPreviewError = ""
            } else {
                root.conflictPreviewError = "Server không trả conflict result hợp lệ."
            }
            root.conflictPreviewPending = false
        } else if (status === "failed") {
            root.conflictPreviewError = String(state.message || "Không thể phân tích xung đột.")
            root.conflictPreviewPending = false
        }
    }

    function markDraftChanged() {
        if (root.resettingDraft)
            return
        root.draftDirty = true
        if (root.conflictPreviewPending
                || root.conflictPreviewResult.conflict !== undefined) {
            root.conflictPreviewPending = false
            root.conflictPreviewResult = ({})
            root.conflictPreviewError = "Nháp đã thay đổi; cần phân tích lại."
        }
    }

    onDraftRunAtChanged: root.markDraftChanged()
    onDraftTimezoneChanged: {
        root.markDraftChanged()
        root.updateRunAtFromLocal()
    }
    onDraftLocalDateChanged: root.updateRunAtFromLocal()
    onDraftLocalTimeChanged: root.updateRunAtFromLocal()
    onDraftDurationSecondsChanged: root.markDraftChanged()
    onDraftPublishingPolicyChanged: root.markDraftChanged()
    onDraftRetryAttemptsChanged: root.markDraftChanged()
    onDraftRetryBackoffSecondsChanged: root.markDraftChanged()

    onScheduleChanged: root.resetDraft()
    onCommandRevisionChanged: root.captureConflictPreview()
    Component.onCompleted: root.resetDraft()

    Popup {
        id: inspectorActionMenu
        objectName: "scheduleInspectorActionMenu"
        parent: root
        x: Math.max(8, root.width - width - 8)
        y: Math.max(8, root.height - height - 58)
        width: 190
        padding: 5
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: ColumnLayout {
            spacing: 3
            ItemDelegate {
                id: cancelMenuItem
                objectName: "scheduleInspectorCancelMenuItem"
                Layout.fillWidth: true
                implicitHeight: 34
                enabled: root.canCancel
                Accessible.name: "Hủy lịch"
                Accessible.description: enabled
                    ? "Mở bước xác nhận hủy phía server"
                    : String((root.actions.cancel || {}).reason_code || "Không thể hủy lịch này")
                contentItem: RowLayout {
                    spacing: 8
                    UiIcon { name: "ui/close"; tone: Theme.danger; iconSize: 14 }
                    Text { Layout.fillWidth: true; text: "Hủy lịch"; color: Theme.danger; font.pixelSize: 11; font.weight: Font.DemiBold }
                }
                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: cancelMenuItem.hovered ? Theme.hover : "transparent"
                }
                onClicked: {
                    inspectorActionMenu.close()
                    root.cancelRequested()
                }
            }
        }
        background: Rectangle {
            radius: Theme.radiusSmall
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            Layout.leftMargin: 14
            Layout.rightMargin: 10
            Text { text: "Chi tiết lịch"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.DemiBold }
            Item { Layout.fillWidth: true }
            Foundation.IconButton {
                objectName: "scheduleInspectorCloseButton"
                iconName: "ui/close"
                text: ""
                accessibleName: "Đóng chi tiết lịch"
                activeFocusOnTab: true
                onClicked: root.closeRequested()
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
        Flickable {
            id: detailFlick
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: detailColumn.implicitHeight + 20
            ScrollBar.vertical: ScrollBar {
                id: detailScrollBar
                policy: ScrollBar.AsNeeded
                implicitWidth: 7
                contentItem: Rectangle {
                    implicitWidth: 5
                    radius: width / 2
                    color: detailScrollBar.pressed ? Theme.textFaint : Theme.border
                    opacity: detailScrollBar.active ? 0.85 : 0.45
                }
                background: Item {}
            }

            ColumnLayout {
                id: detailColumn
                width: detailFlick.width
                spacing: 10
                Item { Layout.preferredHeight: 2 }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    spacing: 9
                    Rectangle {
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 46
                        radius: Theme.radiusSmall
                        color: Theme.elevated
                        Image {
                            anchors.fill: parent
                            visible: Boolean((root.schedule.thumbnail || {}).available)
                                && root.controlPlaneBridge
                            source: visible ? root.controlPlaneBridge.authorizedThumbnailUrl(
                                String((root.schedule.thumbnail || {}).asset_id || ""),
                                String((root.schedule.thumbnail || {}).thumbnail_url || "")
                            ) : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                        }
                        SocialIcon {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            visible: !Boolean((root.schedule.thumbnail || {}).available)
                            platform: String(root.schedule.platform || "generic")
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text { Layout.fillWidth: true; text: String(root.schedule.title || "Chưa chọn lịch"); color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
                        Text { Layout.fillWidth: true; text: String((root.schedule.channel || {}).display_name || ""); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                    }
                    Foundation.StatusPill {
                        text: root.stateLabel(String(root.schedule.state || "unknown"))
                        tone: root.stateTone(String(root.schedule.state || "unknown"))
                        showDot: true
                    }
                }

                SectionTitle { text: "LỊCH & CHÍNH SÁCH" }
                FieldLabel { text: "Thời gian đăng theo kênh" }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.preferredHeight: 38
                    radius: Theme.radiusSmall
                    color: Theme.accentSoft
                    border.width: 1
                    border.color: Theme.accent
                    Text {
                        id: localSummaryText
                        objectName: "scheduleInspectorLocalSummary"
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        text: root.localScheduleSummary()
                        color: Theme.text
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }
                FieldLabel { text: "Ngày và giờ đăng" }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    spacing: 7
                    ScheduleField {
                        objectName: "scheduleInspectorLocalDateField"
                        Layout.fillWidth: true
                        text: root.draftLocalDateText
                        placeholderText: "Ngày (DD/MM/YYYY)"
                        onTextEdited: root.editLocalDate(text)
                        enabled: root.canEdit
                        Accessible.name: "Ngày đăng theo múi giờ của kênh"
                        Accessible.description: enabled
                            ? "Chỉnh ngày địa phương; chưa lưu phía server"
                            : "Lịch hiện tại không cho phép chỉnh sửa"
                    }
                    ScheduleField {
                        objectName: "scheduleInspectorLocalTimeField"
                        Layout.preferredWidth: 92
                        text: root.draftLocalTime
                        placeholderText: "HH:MM"
                        onTextEdited: root.draftLocalTime = text.trim()
                        enabled: root.canEdit
                        Accessible.name: "Giờ đăng theo múi giờ của kênh"
                    }
                }
                Text {
                    objectName: "scheduleInspectorLocalTimeError"
                    visible: Boolean(root.localTimeError)
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    text: root.localTimeError
                    color: Theme.danger
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                    Accessible.name: text
                    Accessible.role: Accessible.AlertMessage
                }
                Text {
                    visible: root.draftDirty
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    text: root.proposalKind
                        ? "Bản nháp " + root.proposalKind + " — chưa lưu"
                        : "Có thay đổi chưa lưu"
                    color: Theme.warning
                    font.pixelSize: 11
                    Accessible.name: text
                    Accessible.role: Accessible.StaticText
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    spacing: 7
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: Theme.radiusSmall
                        color: Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 7
                            UiIcon {
                                name: "ui/globe"
                                tone: Theme.info
                                iconSize: 14
                            }
                            Text {
                                objectName: "scheduleInspectorTimezoneText"
                                Layout.fillWidth: true
                                text: root.timezoneLabel(root.draftTimezone)
                                color: Theme.textMuted
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                        Accessible.name: "Múi giờ của kênh: "
                            + root.timezoneLabel(root.draftTimezone)
                        Accessible.role: Accessible.StaticText
                    }
                    ScheduleSpin {
                        objectName: "scheduleInspectorDurationField"
                        Layout.preferredWidth: 98
                        from: 60
                        to: 86400
                        stepSize: 60
                        value: root.draftDurationSeconds
                        editable: true
                        displayDivisor: 60
                        unitSuffix: "phút"
                        onValueModified: root.draftDurationSeconds = value
                        enabled: root.canEdit
                        Accessible.name: "Thời lượng slot theo phút"
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    spacing: 7
                    ScheduleCombo {
                        objectName: "schedulePublishingPolicyField"
                        Layout.fillWidth: true
                        model: ["approval_required", "scheduled_approval"]
                        displayLabels: ({
                            "approval_required": "Cần phê duyệt trước khi đăng",
                            "scheduled_approval": "Duyệt theo lịch đã đặt"
                        })
                        displayText: root.draftPublishingPolicy === "scheduled_approval"
                            ? "Duyệt theo lịch đã đặt"
                            : "Cần phê duyệt trước khi đăng"
                        currentIndex: Math.max(0, model.indexOf(root.draftPublishingPolicy))
                        enabled: root.canEdit
                        Accessible.name: "Chính sách phát hành"
                        onActivated: root.draftPublishingPolicy = String(currentText)
                    }
                    ScheduleSpin {
                        objectName: "scheduleInspectorRetryAttemptsField"
                        Layout.preferredWidth: 70
                        from: 1
                        to: 10
                        value: root.draftRetryAttempts
                        editable: true
                        unitSuffix: "lần"
                        enabled: root.canEdit
                        Accessible.name: "Số lần thử lại"
                        onValueModified: root.draftRetryAttempts = value
                    }
                    ScheduleSpin {
                        objectName: "scheduleInspectorRetryBackoffField"
                        Layout.preferredWidth: 82
                        from: 0
                        to: 86400
                        value: root.draftRetryBackoffSeconds
                        editable: true
                        unitSuffix: "giây"
                        enabled: root.canEdit
                        Accessible.name: "Khoảng lùi thử lại giây"
                        onValueModified: root.draftRetryBackoffSeconds = value
                    }
                }
                AppButton {
                    objectName: "scheduleConflictPreviewButton"
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    text: root.conflictPreviewPending
                        ? "Đang phân tích…" : "Phân tích xung đột"
                enabled: root.canEdit && root.draftValid
                availabilityReason: enabled ? ""
                    : !root.canEdit ? "Lịch hiện tại không cho phép chỉnh sửa"
                    : "Bản nháp lịch chưa hợp lệ"
                onClicked: root.previewConflict()
                    Accessible.description: "Chỉ preview; không tự đổi lịch"
                }

                SectionTitle { text: "PHỤ THUỘC" }
                Repeater {
                    model: root.schedule.dependencies || []
                    delegate: RowLayout {
                        id: dependencyRow
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        spacing: 7
                        Rectangle {
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            radius: 9
                            color: Qt.rgba(
                                dependencyRow.modelData.state === "ready" ? Theme.success.r : Theme.warning.r,
                                dependencyRow.modelData.state === "ready" ? Theme.success.g : Theme.warning.g,
                                dependencyRow.modelData.state === "ready" ? Theme.success.b : Theme.warning.b,
                                0.14
                            )
                            Text { anchors.centerIn: parent; text: dependencyRow.modelData.state === "ready" ? "✓" : "!"; color: dependencyRow.modelData.state === "ready" ? Theme.success : Theme.warning; font.pixelSize: 11; font.weight: Font.Bold }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text { Layout.fillWidth: true; text: root.dependencyLabel(String(dependencyRow.modelData.kind || "")); color: Theme.textMuted; font.pixelSize: 11 }
                            Text {
                                objectName: "scheduleDependencyObserved_"
                                    + String(dependencyRow.modelData.kind || "unknown")
                                Layout.fillWidth: true
                                text: root.observedAtLabel(
                                    dependencyRow.modelData.observed_at
                                )
                                color: Theme.textFaint
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                        Text {
                            objectName: "scheduleDependencyState_" + String(dependencyRow.modelData.kind || "unknown")
                            text: root.dependencyStateLabel(dependencyRow.modelData.state)
                            color: dependencyRow.modelData.state === "ready" ? Theme.success : Theme.warning
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }
                }

                Rectangle {
                    id: conflictPreviewBox
                    objectName: "scheduleConflictPreviewResult"
                    property string evidenceState: root.conflictPreviewPending
                        ? "loading"
                        : root.conflictPreviewError ? "error"
                        : root.conflictPreviewResult.conflict !== undefined
                            ? "ready"
                            : Boolean((root.schedule.conflict_analysis || {}).conflict)
                                ? "snapshot" : "idle"
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.preferredHeight: conflictColumn.implicitHeight + 18
                    visible: conflictPreviewBox.evidenceState !== "idle"
                    radius: Theme.radiusSmall
                    color: Qt.rgba(
                        root.activeConflictAnalysis.conflict ? Theme.warning.r : Theme.success.r,
                        root.activeConflictAnalysis.conflict ? Theme.warning.g : Theme.success.g,
                        root.activeConflictAnalysis.conflict ? Theme.warning.b : Theme.success.b,
                        0.10
                    )
                    border.width: 1
                    border.color: root.conflictPreviewError
                        ? Theme.danger
                        : Qt.rgba(
                            root.activeConflictAnalysis.conflict ? Theme.warning.r : Theme.success.r,
                            root.activeConflictAnalysis.conflict ? Theme.warning.g : Theme.success.g,
                            root.activeConflictAnalysis.conflict ? Theme.warning.b : Theme.success.b,
                            0.42
                        )
                    ColumnLayout {
                        id: conflictColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 10
                        anchors.rightMargin: 8
                        spacing: 4
                        Text {
                            text: root.conflictPreviewPending ? "Đang phân tích xung đột"
                                : root.conflictPreviewError ? "Phân tích thất bại"
                                : root.activeConflictAnalysis.conflict
                                    ? "Phân tích xung đột" : "Không phát hiện xung đột"
                            color: root.conflictPreviewError ? Theme.danger
                                : root.activeConflictAnalysis.conflict ? Theme.warning : Theme.success
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                        Text {
                            objectName: "scheduleConflictMessageText"
                            Layout.fillWidth: true
                            text: root.conflictPreviewPending
                                ? "Đang kiểm tra với dữ liệu lịch mới nhất…"
                                : root.conflictPreviewError
                                    ? root.conflictPreviewError
                                    : root.activeConflictAnalysis.conflict
                                        ? root.conflictMessage(
                                            (((root.activeConflictAnalysis || {}).conflicts || [])[0] || ({}))
                                        )
                                        : "Thời điểm hiện tại phù hợp với chính sách sức chứa."
                            color: Theme.textMuted
                            font.pixelSize: 11
                            wrapMode: Text.Wrap
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: !root.conflictPreviewPending
                                && !root.conflictPreviewError
                                && Boolean(((root.activeConflictAnalysis || {}).recommendation || {}).run_at)
                            Text {
                                objectName: "scheduleRecommendationText"
                                Layout.fillWidth: true
                                text: "Đề xuất: " + root.recommendationSummary()
                                color: Theme.textFaint
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                            }
                            AppButton {
                                objectName: "scheduleApplyRecommendation"
                                text: "Áp dụng"
                                implicitHeight: 28
                                Layout.alignment: Qt.AlignRight
                                enabled: root.canEdit
                                    && Boolean(((root.activeConflictAnalysis || {}).recommendation || {}).run_at)
                                availabilityReason: enabled ? ""
                                    : "Server chưa trả đề xuất slot có thể áp dụng"
                                onClicked: root.applyRecommendation()
                                Accessible.description: enabled
                                    ? "Chỉ sao chép đề xuất vào bản nháp"
                                    : "Lịch hiện tại không cho phép chỉnh sửa"
                            }
                        }
                    }
                }

                SectionTitle { text: "PHÊ DUYỆT & BẰNG CHỨNG" }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Text { text: "Phê duyệt"; color: Theme.textFaint; font.pixelSize: 11 }
                    Item { Layout.fillWidth: true }
                    Text {
                        objectName: "scheduleApprovalStateText"
                        text: root.approvalStateLabel((root.schedule.approval || {}).state)
                        color: (root.schedule.approval || {}).state === "approved" ? Theme.success : Theme.warning
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                    AppButton {
                        objectName: "scheduleApprovalDeepLinkButton"
                        visible: Boolean((root.schedule.approval || {}).deep_link)
                        text: "Mở"
                        implicitHeight: 26
                        onClicked: root.deepLinkRequested((root.schedule.approval || {}).deep_link)
                    }
                }
                Rectangle {
                    id: dispatchEvidence
                    objectName: "scheduleDispatchEvidence"
                    property string evidenceState: String(root.publishDispatch.state || "unavailable")
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.preferredHeight: 38
                    radius: Theme.radiusSmall
                    color: Theme.elevated
                    border.width: 1
                    border.color: Theme.borderSoft
                    Text {
                        anchors.centerIn: parent
                        width: parent.width - 16
                        text: dispatchEvidence.evidenceState === "unavailable"
                            ? "Chưa kết nối dịch vụ đăng bài — chưa thể xác nhận đã đăng"
                            : "Đã có xác nhận từ dịch vụ đăng bài"
                        color: Theme.textFaint
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                    Accessible.name: dispatchEvidence.evidenceState === "unavailable"
                        ? "Chưa có xác nhận đăng bài"
                        : "Đã có xác nhận đăng bài"
                    Accessible.role: Accessible.StaticText
                }

                SectionTitle { text: "HOẠT ĐỘNG GẦN ĐÂY" }
                Repeater {
                    model: (root.schedule.activity || []).slice(0, 4)
                    delegate: RowLayout {
                        id: activityRow
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        spacing: 6
                        Rectangle { Layout.preferredWidth: 6; Layout.preferredHeight: 6; radius: 3; color: Theme.info }
                        Text { Layout.fillWidth: true; text: root.activitySummary(activityRow.modelData); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                    }
                }
                Item { Layout.preferredHeight: 6 }
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 6
            AppButton {
                id: saveButton
                objectName: "scheduleSaveButton"
                Layout.fillWidth: true
                text: root.updateBusy ? "Đang lưu…" : "Lưu thay đổi"
                primary: true
                enabled: root.canSave
                onClicked: root.saveChanges()
                Accessible.description: enabled ? "Cập nhật lịch bằng CAS version"
                    : !root.canEdit ? "Thiếu quyền, action hoặc command đang chạy"
                    : !root.draftDirty ? "Chưa có thay đổi để lưu"
                    : "Bản nháp chưa hợp lệ"
            }
            AppButton {
                id: publishButton
                objectName: "schedulePublishNowButton"
                Layout.fillWidth: true
                text: root.publishBusy ? "Đang yêu cầu…" : "Đăng ngay"
                enabled: root.canPublishNow
                onClicked: root.publishNow()
                Accessible.description: enabled
                    ? "Chỉ yêu cầu approval phía server; nút không phải phê duyệt"
                    : root.draftDirty
                        ? "Lưu hoặc bỏ thay đổi bản nháp trước khi yêu cầu đăng ngay"
                        : String((root.actions.publish_now || {}).reason_code || "Không khả dụng")
            }
            Foundation.IconButton {
                objectName: "scheduleCancelButton"
                iconName: "ui/more-vertical"
                text: ""
                accessibleName: "Thao tác khác của lịch"
                Accessible.description: root.canCancel
                    ? "Mở menu thao tác; hủy cần xác nhận riêng"
                    : String((root.actions.cancel || {}).reason_code || "Không có thao tác khả dụng")
                onClicked: inspectorActionMenu.open()
            }
        }
    }

    function stateTone(state) {
        switch (state) {
        case "published": return Theme.success
        case "conflict": return Theme.warning
        case "verification_required":
        case "failed": return Theme.danger
        case "publishing": return Theme.info
        default: return Theme.accent
        }
    }

    function stateLabel(state) {
        switch (state) {
        case "published": return "Đã xuất bản"
        case "verification_required": return "Cần xác minh"
        case "waiting_approval": return "Chờ duyệt"
        case "conflict": return "Xung đột"
        case "publishing": return "Đang đăng"
        default: return "Đã lên lịch"
        }
    }

    function dependencyLabel(kind) {
        switch (kind) {
        case "final_video": return "Video hoàn thiện"
        case "qc": return "QC đạt"
        case "approval": return "Phê duyệt"
        case "browser": return "Browser sẵn sàng"
        default: return kind
        }
    }

    component SectionTitle: Text {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        color: Theme.textFaint
        font.pixelSize: 11
        font.weight: Font.Bold
        font.letterSpacing: 0.7
    }

    component FieldLabel: Text {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        color: Theme.textFaint
        font.pixelSize: 11
    }
}
