pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "publishingCalendar"
    property var calendar: ({})
    property var occurrenceModel: null
    property var occurrenceRows: []
    property bool occurrenceRowsRebuildQueued: false
    property var proposalTarget: null
    property bool canWrite: false
    property string selectedScheduleId: ""
    property string viewMode: "week"
    property string draftDate: ""
    property string draftDateText: ""
    property string draftTimezone: ""
    property string draftChannelFilter: String(root.filterData.channel_id || "")
    property string draftPlatformFilter: String(root.filterData.platform || "")
    property string navigationError: ""
    property string monthDialogDate: ""
    property int lastComputedDayIndex: -1
    readonly property var windowData: root.calendar.window || ({})
    readonly property var filterData: root.calendar.filter || ({})
    readonly property var filterCatalog: root.calendar.filter_catalog || ({})
    readonly property var channelOptions: root.filterCatalog.channels || []
    readonly property var platformOptions: root.filterCatalog.platforms || []
    readonly property var timezoneOptions: root.filterCatalog.timezones || []
    readonly property var channelLabels: root.optionLabels(root.channelOptions)
    readonly property var platformLabels: root.optionLabels(root.platformOptions)
    readonly property var timezoneLabels: root.optionLabels(root.timezoneOptions)
    readonly property var daysData: root.calendar.days || []
    readonly property var currentTimeData: root.calendar.current_time || ({})
    readonly property var optimalWindows: root.calendar.optimal_windows || []
    readonly property var hiddenItems: root.calendar.hidden_items || []
    readonly property var visibilityData: root.calendar.visibility || ({})
    readonly property var visibleHoursData: root.calendar.visible_hours || ({})
    readonly property var navigationData: root.calendar.navigation || ({})
    readonly property real axisStartHour: root.clockHour(
        root.visibleHoursData.start_time, 8
    )
    readonly property real axisEndHour: root.clockHour(
        root.visibleHoursData.end_time, 22
    )
    readonly property real axisHourSpan: Math.max(
        1, root.axisEndHour - root.axisStartHour
    )
    readonly property var hourTicks: root.buildHourTicks()
    readonly property bool visibilityPartial: Boolean(root.visibilityData.is_partial)
    readonly property int totalInRange: Number(
        root.visibilityData.total_in_range ?? root.calendar.total_in_range
            ?? root.calendar.total ?? 0
    )
    readonly property int visibleCount: Number(
        root.visibilityData.visible_count ?? root.calendar.visible_count ?? 0
    )
    readonly property int hiddenCount: Number(
        root.visibilityData.hidden_outside_visible_hours
            ?? root.calendar.hidden_count ?? 0
    )
    readonly property string visibilityReason: String(
        root.visibilityData.reason_code || ""
    )
    readonly property string visibilitySummary: root.visibleCount + "/"
        + root.totalInRange + " lịch trong "
        + String(root.visibleHoursData.start_time || "—") + "–"
        + String(root.visibleHoursData.end_time || "—") + "; "
        + root.hiddenCount + " lịch ngoài khung"
    readonly property int serverDayCount: root.daysData.length
    readonly property int viewDayCount: root.viewMode === "month" ? 42 : 7
    readonly property bool compactToolbar: width < 980
    readonly property string anchorDateValue: root.parseDisplayDate(root.draftDateText)
    readonly property bool anchorInputValid: root.validDate(root.anchorDateValue)
        && Boolean(String(root.draftTimezone || "").trim())
    signal scheduleSelected(var item)
    signal scheduleProposal(var proposal)
    signal nextPageRequested()
    signal windowRequested(var query)
    Accessible.name: "Lịch xuất bản theo tuần hoặc tháng"
    Accessible.role: Accessible.Pane

    function optionLabels(options) {
        const result = []
        for (let index = 0; index < options.length; ++index)
            result.push(String((options[index] || {}).label || ""))
        return result
    }

    function optionIndex(options, value) {
        const selected = String(value || "")
        for (let index = 0; index < options.length; ++index) {
            if (String((options[index] || {}).value || "") === selected)
                return index
        }
        return -1
    }

    function selectOption(options, index, fallback) {
        const selectedIndex = Number(index)
        if (selectedIndex < 0 || selectedIndex >= options.length)
            return String(fallback || "")
        return String((options[selectedIndex] || {}).value || "")
    }

    function clockHour(value, fallback) {
        const match = /^(\d{2}):(\d{2})$/.exec(String(value || ""))
        if (!match)
            return Number(fallback)
        return Number(match[1]) + Number(match[2]) / 60
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
        const text = String(value || "")
        const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(text)
        return match ? match[3] + "/" + match[2] + "/" + match[1] : text
    }

    function parseDisplayDate(value) {
        const text = String(value || "").trim()
        const displayMatch = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec(text)
        const candidate = displayMatch
            ? displayMatch[3] + "-" + displayMatch[2] + "-" + displayMatch[1]
            : text
        return root.validDate(candidate) ? candidate : ""
    }

    function queueOccurrenceRowsRebuild() {
        if (root.occurrenceRowsRebuildQueued)
            return
        root.occurrenceRowsRebuildQueued = true
        Qt.callLater(root.rebuildOccurrenceRows)
    }

    function rebuildOccurrenceRows() {
        root.occurrenceRowsRebuildQueued = false
        const rows = []
        const model = root.occurrenceModel
        if (model) {
            const count = Number(model.count || 0)
            for (let index = 0; index < count; ++index) {
                const row = model.get(index)
                rows.push(row === null || row === undefined ? ({}) : row)
            }
        }
        // Model reset is emitted before SchedulePage receives SnapshotStore.changed.
        // At this deferred boundary the authoritative calendar projection is ready;
        // align the mode before publishing rows so week-only overlap bindings never
        // run against an incoming month collection.
        const projectedMode = String(root.windowData.view_mode || "")
        if (projectedMode === "week" || projectedMode === "month")
            root.viewMode = projectedMode
        root.occurrenceRows = rows
    }

    function syncDraftWindow() {
        const projectedMode = String(root.windowData.view_mode || "")
        if (projectedMode === "week" || projectedMode === "month")
            root.viewMode = projectedMode
        const projectedDate = String(
            root.windowData.anchor_date
                || (root.daysData[0] || {}).local_date || ""
        )
        if (projectedDate) {
            root.draftDate = projectedDate
            root.draftDateText = root.displayDate(projectedDate)
        }
        const projectedTimezone = String(
            root.windowData.timezone || root.visibleHoursData.timezone || ""
        )
        if (projectedTimezone)
            root.draftTimezone = projectedTimezone
    }

    function buildHourTicks() {
        const values = []
        let value = root.axisStartHour
        while (value < root.axisEndHour) {
            values.push(value)
            value += 2
        }
        if (!values.length || values[values.length - 1] !== root.axisEndHour)
            values.push(root.axisEndHour)
        return values
    }

    function hourLabel(value) {
        const hour = Math.floor(Number(value))
        const minute = Math.round((Number(value) - hour) * 60)
        return String(hour).padStart(2, "0") + ":"
            + String(minute).padStart(2, "0")
    }

    function evidenceLabel(evidence) {
        const value = evidence || ({})
        if (typeof value === "string")
            return value
        const identity = String(value.policy_id || value.kind || "Server evidence")
        const version = value.version === undefined ? "" : " v" + value.version
        const observed = value.observed_at
            ? " · " + String(value.observed_at) : ""
        return identity + version + observed
    }

    function navigationWindow(mode, direction) {
        const scope = root.navigationData[String(mode || root.viewMode)] || ({})
        return scope[String(direction || "current")] || ({})
    }

    function hasNavigation(mode, direction) {
        const payload = root.navigationWindow(mode, direction)
        return Boolean(String(payload.window_start || ""))
            && Boolean(String(payload.window_end || ""))
            && Boolean(String(payload.timezone || ""))
    }

    function requestProjectedWindow(mode, direction) {
        const targetMode = String(mode || root.viewMode)
        const targetDirection = String(direction || "current")
        const payload = root.navigationWindow(targetMode, targetDirection)
        if (!root.hasNavigation(targetMode, targetDirection)) {
            root.navigationError = "Server chưa trả cửa sổ điều hướng "
                + targetMode + "/" + targetDirection + "."
            return
        }
        root.navigationError = ""
        root.windowRequested({
            "window_start": String(payload.window_start),
            "window_end": String(payload.window_end),
            "timezone": String(payload.timezone),
            "channel_id": root.draftChannelFilter,
            "platform": root.draftPlatformFilter
        })
    }

    function computeDayIndex(item) {
        const localDate = String((item || {}).local_time || "").slice(0, 10)
        let index = -1
        for (let day = 0; day < root.daysData.length; ++day) {
            if (String((root.daysData[day] || {}).local_date || "") === localDate) {
                index = day
                break
            }
        }
        return index >= 0 && index < root.viewDayCount ? index : -1
    }

    function dayIndex(item) {
        root.lastComputedDayIndex = root.computeDayIndex(item)
        return root.lastComputedDayIndex
    }

    function dayData(index) {
        const projected = root.daysData[index] || ({})
        if (projected.local_date)
            return projected
        return {
            "local_date": "",
            "weekday_label": "—",
            "date_label": "—",
            "is_today": false
        }
    }

    function requestPreviousWindow() {
        root.requestProjectedWindow(root.viewMode, "previous")
    }

    function requestNextWindow() {
        root.requestProjectedWindow(root.viewMode, "next")
    }

    function requestTodayWindow() {
        root.requestProjectedWindow(root.viewMode, "today")
    }

    function requestWeekWindow() {
        root.requestAnchorWindow("week")
    }

    function requestMonthWindow() {
        root.requestAnchorWindow("month")
    }

    function applyServerFilters() {
        root.requestAnchorWindow(root.viewMode)
    }

    function requestAnchorWindow(mode) {
        const targetMode = String(mode || root.viewMode)
        if (!root.anchorInputValid
                || (targetMode !== "week" && targetMode !== "month")) {
            root.navigationError = "Chọn ngày và múi giờ hợp lệ."
            return
        }
        const anchorDate = root.anchorDateValue
        root.navigationError = ""
        root.draftDate = anchorDate
        root.windowRequested({
            "anchor_date": anchorDate,
            "view_mode": targetMode,
            "timezone": root.draftTimezone,
            "channel_id": root.draftChannelFilter,
            "platform": root.draftPlatformFilter
        })
    }

    onCalendarChanged: Qt.callLater(root.syncDraftWindow)
    onDraftDateChanged: {
        if (root.validDate(root.draftDate)
                && root.parseDisplayDate(root.draftDateText) !== root.draftDate)
            root.draftDateText = root.displayDate(root.draftDate)
    }
    onOccurrenceModelChanged: root.queueOccurrenceRowsRebuild()
    Component.onCompleted: {
        Qt.callLater(root.syncDraftWindow)
        root.queueOccurrenceRowsRebuild()
    }

    Connections {
        target: root.occurrenceModel
        ignoreUnknownSignals: true
        function onModelReset() { root.queueOccurrenceRowsRebuild() }
        function onCountChanged() { root.queueOccurrenceRowsRebuild() }
        function onDataChanged() { root.queueOccurrenceRowsRebuild() }
        function onRowsInserted() { root.queueOccurrenceRowsRebuild() }
        function onRowsRemoved() { root.queueOccurrenceRowsRebuild() }
        function onRowsMoved() { root.queueOccurrenceRowsRebuild() }
    }

    function localHour(item) {
        const value = String((item || {}).local_time || "")
        const match = /T(\d{2}):(\d{2})/.exec(value)
        if (!match)
            return root.axisStartHour
        return Number(match[1]) + Number(match[2]) / 60
    }

    function overlaps(left, right) {
        if (root.computeDayIndex(left) !== root.computeDayIndex(right))
            return false
        const leftStart = root.localHour(left) * 3600
        const rightStart = root.localHour(right) * 3600
        // A semantic 30-second post still occupies a readable ~62px card.
        // Convert that exact visual footprint back into the current time-axis
        // span so responsive heights never let adjacent cards paint together.
        const visualSpanSeconds = 62 / Math.max(1, calendarCanvas.gridHeight)
            * root.axisHourSpan * 3600
        const leftEnd = leftStart + Math.max(
            visualSpanSeconds, Number(left.duration_seconds || 60)
        )
        const rightEnd = rightStart + Math.max(
            visualSpanSeconds, Number(right.duration_seconds || 60)
        )
        return leftStart < rightEnd && rightStart < leftEnd
    }

    function visualInterval(item) {
        const start = root.localHour(item) * 3600
        const visualSpan = 62 / Math.max(1, calendarCanvas.gridHeight)
            * root.axisHourSpan * 3600
        return {
            "start": start,
            "end": start + Math.max(
                visualSpan, Number((item || {}).duration_seconds || 60)
            )
        }
    }

    function overlapCluster(item) {
        const rows = root.occurrenceRows || []
        if (!rows.length)
            return [item]
        const cluster = [item]
        const included = ({})
        included[root.occurrenceKey(item, -1)] = true
        let changed = true
        while (changed) {
            changed = false
            for (let index = 0; index < rows.length; ++index) {
                const candidate = rows[index] || ({})
                const key = root.occurrenceKey(candidate, index)
                if (included[key])
                    continue
                for (let clusterIndex = 0;
                        clusterIndex < cluster.length; ++clusterIndex) {
                    if (!root.overlaps(candidate, cluster[clusterIndex]))
                        continue
                    included[key] = true
                    cluster.push(candidate)
                    changed = true
                    break
                }
            }
        }
        return cluster
    }

    function occurrenceKey(item, index) {
        const value = item || ({})
        return String(value.id || value.entity_id || "index:" + index)
    }

    function overlapOrdinal(item, itemIndex) {
        const rows = root.occurrenceRows || []
        if (!rows.length)
            return 0
        let ordinal = 0
        for (let index = 0; index < Math.min(itemIndex, rows.length); ++index) {
            const other = rows[index] || ({})
            if (root.overlaps(item, other))
                ordinal += 1
        }
        return ordinal
    }

    function overlapLaneCount(item) {
        const cluster = root.overlapCluster(item)
        let maximum = 1
        for (let pointIndex = 0; pointIndex < cluster.length; ++pointIndex) {
            const point = root.visualInterval(cluster[pointIndex]).start
            let concurrent = 0
            for (let itemIndex = 0; itemIndex < cluster.length; ++itemIndex) {
                const bounds = root.visualInterval(cluster[itemIndex])
                if (bounds.start <= point && point < bounds.end)
                    concurrent += 1
            }
            maximum = Math.max(maximum, concurrent)
        }
        return maximum
    }

    function overlapLane(item, itemIndex) {
        const rows = root.occurrenceRows || []
        if (!rows.length || itemIndex <= 0)
            return 0
        const lanes = root.overlapLaneCount(item)
        const used = []
        for (let lane = 0; lane < lanes; ++lane)
            used.push(false)
        for (let index = 0; index < Math.min(itemIndex, rows.length); ++index) {
            const other = rows[index] || ({})
            if (!root.overlaps(item, other))
                continue
            const otherLane = root.overlapLane(other, index)
            if (otherLane >= 0 && otherLane < used.length)
                used[otherLane] = true
        }
        for (let lane = 0; lane < lanes; ++lane) {
            if (!used[lane])
                return lane
        }
        return itemIndex % lanes
    }

    function dayOrdinal(item, itemIndex) {
        const rows = root.occurrenceRows || []
        if (!rows.length)
            return 0
        const day = root.computeDayIndex(item)
        let ordinal = 0
        for (let index = 0; index < Math.min(itemIndex, rows.length); ++index) {
            const other = rows[index] || ({})
            if (root.computeDayIndex(other) === day)
                ordinal += 1
        }
        return ordinal
    }

    function monthDayCount(dayOrDate) {
        const rows = root.occurrenceRows || []
        if (!rows.length)
            return 0
        const localDate = typeof dayOrDate === "number"
            ? String((root.dayData(dayOrDate) || {}).local_date || "")
            : String(dayOrDate || "")
        if (!localDate)
            return 0
        let total = 0
        for (let index = 0; index < rows.length; ++index) {
            const item = rows[index] || ({})
            if (String(item.local_time || "").slice(0, 10) === localDate)
                total += 1
        }
        return total
    }

    function monthSelectedOrdinal(dayIndex) {
        const rows = root.occurrenceRows || []
        if (!rows.length || !root.selectedScheduleId)
            return -1
        for (let index = 0; index < rows.length; ++index) {
            const item = rows[index] || ({})
            if (String(item.id || "") === root.selectedScheduleId
                    && root.computeDayIndex(item) === dayIndex)
                return root.dayOrdinal(item, index)
        }
        return -1
    }

    function monthDisplayedCount(dayIndex) {
        const total = root.monthDayCount(dayIndex)
        const rawSlots = calendarCanvas.monthRawSlotCount
        return total > rawSlots ? Math.max(1, rawSlots - 1) : total
    }

    function monthDisplayOrdinal(item, itemIndex) {
        const day = root.computeDayIndex(item)
        if (day < 0)
            return -1
        const ordinal = root.dayOrdinal(item, itemIndex)
        const displayed = root.monthDisplayedCount(day)
        const total = root.monthDayCount(day)
        if (total <= calendarCanvas.monthRawSlotCount)
            return ordinal
        const selectedOrdinal = root.monthSelectedOrdinal(day)
        if (selectedOrdinal >= displayed) {
            if (String((item || {}).id || "") === root.selectedScheduleId)
                return displayed - 1
            return ordinal < displayed - 1 ? ordinal : -1
        }
        return ordinal < displayed ? ordinal : -1
    }

    function openMonthDay(localDate) {
        const value = String(localDate || "")
        if (!value || root.monthDayCount(value) < 1)
            return
        root.monthDialogDate = value
        monthDayDialog.open()
    }

    function stateTone(state) {
        switch (String(state || "")) {
        case "published": return Theme.success
        case "failed":
        case "verification_required": return Theme.danger
        case "conflict":
        case "waiting_approval": return Theme.warning
        case "publishing": return Theme.info
        default: return Theme.accent
        }
    }

    function stateLabel(state) {
        switch (String(state || "")) {
        case "published": return "Đã xuất bản"
        case "verification_required": return "Cần xác minh"
        case "waiting_approval": return "Chờ duyệt"
        case "publishing": return "Đang đăng"
        case "conflict": return "Xung đột"
        case "failed": return "Thất bại"
        case "queued": return "Trong hàng đợi"
        default: return "Đã lên lịch"
        }
    }

    function compactStateLabel(state) {
        switch (String(state || "")) {
        case "published": return "Đã đăng"
        case "verification_required": return "Xác minh"
        case "waiting_approval": return "Chờ duyệt"
        case "publishing": return "Đang đăng"
        case "conflict": return "Xung đột"
        case "failed": return "Lỗi"
        case "queued": return "Đợi"
        default: return "Đã lịch"
        }
    }

    ScheduleDialog {
        id: hiddenScheduleDialog
        objectName: "scheduleHiddenItemsDialog"
        anchors.centerIn: parent
        width: Math.min(520, root.width - 28)
        height: Math.min(430, root.height - 28)
        title: "Lịch ngoài khung giờ hiển thị"
        showDefaultFooter: false
        contentItem: ColumnLayout {
            spacing: 10
            Text {
                Layout.fillWidth: true
                text: root.visibilitySummary + ". "
                    + (root.visibilityReason || "Server không trả reason code.")
                color: Theme.textMuted
                font.pixelSize: 11
                wrapMode: Text.Wrap
                Accessible.name: text
            }
            Flickable {
                id: hiddenScheduleFlick
                objectName: "scheduleHiddenItemsList"
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: width
                contentHeight: hiddenScheduleColumn.implicitHeight
                ColumnLayout {
                    id: hiddenScheduleColumn
                    width: hiddenScheduleFlick.width
                    spacing: 6
                    Repeater {
                        model: root.hiddenItems
                        delegate: Rectangle {
                            id: hiddenCard
                            required property int index
                            required property var modelData
                            objectName: "scheduleHiddenCard_"
                                + String(hiddenCard.modelData.id || hiddenCard.index)
                            function activate() {
                                root.scheduleSelected(hiddenCard.modelData)
                                hiddenScheduleDialog.close()
                            }
                            Layout.fillWidth: true
                            Layout.preferredHeight: 58
                            radius: Theme.radiusSmall
                            color: Theme.elevated
                            border.width: 1
                            border.color: Theme.borderSoft
                            activeFocusOnTab: true
                            Accessible.name: String(hiddenCard.modelData.title || "Lịch")
                                + ", ngoài khung giờ hiển thị"
                            Accessible.description: String(hiddenCard.modelData.local_time || "")
                                + ", " + String(hiddenCard.modelData.hidden_reason_code || "")
                            Accessible.role: Accessible.ListItem
                            Accessible.focusable: true
                            Keys.onReturnPressed: hiddenCard.activate()
                            Keys.onSpacePressed: hiddenCard.activate()
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                SocialIcon {
                                    platform: String(hiddenCard.modelData.platform || "generic")
                                    Layout.preferredWidth: 18
                                    Layout.preferredHeight: 18
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text { Layout.fillWidth: true; text: String(hiddenCard.modelData.title || ""); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                    Text { Layout.fillWidth: true; text: String((hiddenCard.modelData.channel || {}).display_name || ""); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                }
                                Text {
                                    text: String(hiddenCard.modelData.local_time || "").slice(11, 16)
                                    color: Theme.warning
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: hiddenCard.activate()
                            }
                        }
                    }
                }
            }
            Text {
                visible: root.hiddenItems.length === 0
                Layout.fillWidth: true
                text: "Trang hiện tại không chứa row ngoài giờ; dùng trang tiếp để xem phần còn lại."
                color: Theme.textFaint
                font.pixelSize: 11
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            RowLayout {
                Layout.fillWidth: true
                AppButton {
                    objectName: "scheduleHiddenNextPageButton"
                    visible: Boolean(root.calendar.next_cursor)
                    text: "Trang tiếp"
                    Accessible.name: "Tải trang lịch tiếp theo"
                    onClicked: {
                        hiddenScheduleDialog.close()
                        root.nextPageRequested()
                    }
                }
                Item { Layout.fillWidth: true }
                AppButton {
                    objectName: "scheduleHiddenItemsCloseButton"
                    text: "Đóng"
                    onClicked: hiddenScheduleDialog.close()
                }
            }
        }
    }

    ScheduleDialog {
        id: monthDayDialog
        objectName: "scheduleMonthDayDialog"
        property string localDate: root.monthDialogDate
        property int itemCount: root.monthDayCount(monthDayDialog.localDate)
        anchors.centerIn: parent
        width: Math.min(540, root.width - 28)
        height: Math.min(500, root.height - 28)
        title: "Lịch ngày " + root.displayDate(monthDayDialog.localDate || "")
        showDefaultFooter: false
        contentItem: ColumnLayout {
            spacing: 10
            Text {
                Layout.fillWidth: true
                text: monthDayDialog.itemCount
                    + " lịch trong ngày "
                    + root.displayDate(monthDayDialog.localDate || "")
                color: Theme.textMuted
                font.pixelSize: 11
                Accessible.name: text
            }
            Flickable {
                id: monthDayFlick
                objectName: "scheduleMonthDayList"
                property int itemCount: monthDayDialog.itemCount
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: width
                contentHeight: monthDayColumn.implicitHeight
                ColumnLayout {
                    id: monthDayColumn
                    width: monthDayFlick.width
                    spacing: 6
                    Repeater {
                        model: root.occurrenceModel
                        delegate: Rectangle {
                            id: monthDayCard
                            required property int index
                            required property string entity_id
                            required property int version
                            required property string content_id
                            required property string content_package_id
                            required property string channel_id
                            required property string title
                            required property string platform
                            required property var channel
                            required property string run_at
                            required property string local_time
                            required property string timezone
                            required property int duration_seconds
                            required property string state_value
                            required property bool has_conflict
                            required property var deep_link
                            readonly property bool belongsToDate:
                                monthDayCard.local_time.slice(0, 10)
                                    === monthDayDialog.localDate
                            readonly property var itemData: ({
                                "id": monthDayCard.entity_id,
                                "version": monthDayCard.version,
                                "content_id": monthDayCard.content_id,
                                "content_package_id": monthDayCard.content_package_id,
                                "channel_id": monthDayCard.channel_id,
                                "title": monthDayCard.title,
                                "platform": monthDayCard.platform,
                                "channel": monthDayCard.channel,
                                "run_at": monthDayCard.run_at,
                                "local_time": monthDayCard.local_time,
                                "timezone": monthDayCard.timezone,
                                "duration_seconds": monthDayCard.duration_seconds,
                                "state": monthDayCard.state_value,
                                "has_conflict": monthDayCard.has_conflict,
                                "deep_link": monthDayCard.deep_link
                            })
                            objectName: "scheduleMonthDayCard_"
                                + monthDayCard.entity_id
                            function activate() {
                                if (!monthDayCard.belongsToDate)
                                    return
                                root.scheduleSelected(monthDayCard.itemData)
                                monthDayDialog.close()
                            }
                            visible: monthDayCard.belongsToDate
                            Layout.fillWidth: true
                            Layout.preferredHeight: visible ? 58 : 0
                            radius: Theme.radiusSmall
                            color: root.selectedScheduleId === monthDayCard.entity_id
                                ? Theme.accentSoft : Theme.elevated
                            border.width: root.selectedScheduleId
                                === monthDayCard.entity_id ? 2 : 1
                            border.color: root.selectedScheduleId
                                === monthDayCard.entity_id
                                ? Theme.accent : Theme.borderSoft
                            activeFocusOnTab: visible
                            Accessible.name: monthDayCard.title + ", "
                                + root.stateLabel(monthDayCard.state_value)
                            Accessible.description: monthDayCard.local_time
                                + ", chọn để mở chi tiết server"
                            Accessible.role: Accessible.ListItem
                            Accessible.focusable: visible
                            Keys.onReturnPressed: monthDayCard.activate()
                            Keys.onSpacePressed: monthDayCard.activate()
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                SocialIcon {
                                    platform: monthDayCard.platform || "generic"
                                    Layout.preferredWidth: 18
                                    Layout.preferredHeight: 18
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        Layout.fillWidth: true
                                        text: monthDayCard.title
                                        color: Theme.text
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: String((monthDayCard.channel || {}).display_name || "")
                                            + " · " + root.stateLabel(monthDayCard.state_value)
                                        color: root.stateTone(monthDayCard.state_value)
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }
                                Text {
                                    text: monthDayCard.local_time.slice(11, 16)
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: monthDayCard.activate()
                            }
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                AppButton {
                    objectName: "scheduleMonthDayCloseButton"
                    text: "Đóng"
                    onClicked: monthDayDialog.close()
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        GridLayout {
            id: calendarToolbar
            objectName: "scheduleCalendarToolbar"
            Layout.fillWidth: true
            Layout.preferredHeight: root.compactToolbar
                ? Math.max(76, calendarNavigationGroup.implicitHeight + 48)
                : 44
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.topMargin: 6
            Layout.bottomMargin: 6
            columns: root.compactToolbar ? 1 : 2
            columnSpacing: 6
            rowSpacing: 6

            Flow {
                id: calendarNavigationGroup
                objectName: "scheduleCalendarNavigationGroup"
                Layout.row: 0
                Layout.column: 0
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(30, implicitHeight)
                spacing: 6

                AppButton {
                    objectName: "scheduleTodayButton"
                    text: "Hôm nay"
                    height: 30
                    enabled: root.hasNavigation(root.viewMode, "today")
                    availabilityReason: enabled ? ""
                        : "Chưa có cửa sổ lịch cho hôm nay"
                    onClicked: root.requestTodayWindow()
                    Accessible.description: "Tải cửa sổ bảy ngày bắt đầu từ hôm nay"
                }
                Foundation.IconButton {
                    objectName: "schedulePreviousWeekButton"
                    iconName: "ui/chevron-left"
                    text: ""
                    width: 30
                    height: 30
                    accessibleName: "Khoảng trước"
                    enabled: root.hasNavigation(root.viewMode, "previous")
                    Accessible.description: enabled ? ""
                        : "Chưa có cửa sổ lịch liền trước"
                    onClicked: root.requestPreviousWindow()
                }
                Foundation.IconButton {
                    objectName: "scheduleNextWeekButton"
                    iconName: "ui/chevron-right"
                    text: ""
                    width: 30
                    height: 30
                    accessibleName: "Khoảng sau"
                    enabled: root.hasNavigation(root.viewMode, "next")
                    Accessible.description: enabled ? ""
                        : "Chưa có cửa sổ lịch liền sau"
                    onClicked: root.requestNextWindow()
                }
                ScheduleField {
                    id: dateField
                    objectName: "scheduleCalendarDateField"
                    width: 110
                    height: 30
                    text: root.draftDateText
                    placeholderText: "DD/MM/YYYY"
                    enabled: true
                    activeFocusOnTab: true
                    Accessible.name: "Ngày bắt đầu lịch"
                    Accessible.description: root.anchorInputValid
                        ? "Ngày bắt đầu theo giờ của kênh"
                        : "Nhập ngày theo định dạng ngày/tháng/năm"
                    onTextEdited: root.draftDateText = text.trim()
                    onAccepted: root.requestAnchorWindow(root.viewMode)
                }
                AppButton {
                    objectName: "scheduleWeekViewButton"
                    text: "Tuần"
                    height: 30
                    primary: root.viewMode === "week"
                    enabled: root.anchorInputValid
                    availabilityReason: enabled ? ""
                        : "Cần ngày và múi giờ hợp lệ"
                    Accessible.name: "Xem theo tuần"
                    onClicked: root.requestWeekWindow()
                }
                AppButton {
                    objectName: "scheduleMonthViewButton"
                    text: "Tháng"
                    height: 30
                    primary: root.viewMode === "month"
                    enabled: root.anchorInputValid
                    availabilityReason: enabled ? ""
                        : "Cần ngày và múi giờ hợp lệ"
                    Accessible.name: "Xem theo tháng"
                    onClicked: root.requestMonthWindow()
                }
            }

            RowLayout {
                id: calendarFilterGroup
                objectName: "scheduleCalendarFilterGroup"
                Layout.row: root.compactToolbar ? 1 : 0
                Layout.column: root.compactToolbar ? 0 : 1
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                spacing: 6

                Rectangle {
                    visible: !root.compactToolbar
                    Layout.preferredWidth: visible ? 1 : 0
                    Layout.preferredHeight: 22
                    color: Theme.borderSoft
                }
                ScheduleCombo {
                    objectName: "scheduleChannelFilter"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 92
                    Layout.preferredHeight: 30
                    model: root.channelLabels
                    currentIndex: root.optionIndex(
                        root.channelOptions, root.draftChannelFilter
                    )
                    displayText: currentIndex >= 0
                        ? String(root.channelLabels[currentIndex] || "Tất cả kênh")
                        : "Tất cả kênh"
                    activeFocusOnTab: true
                    Accessible.name: "Lọc theo kênh"
                    onActivated: function(index) {
                        root.draftChannelFilter = root.selectOption(
                            root.channelOptions, index, ""
                        )
                    }
                }
                ScheduleCombo {
                    objectName: "schedulePlatformFilter"
                    Layout.preferredWidth: 132
                    Layout.preferredHeight: 30
                    model: root.platformLabels
                    currentIndex: root.optionIndex(
                        root.platformOptions, root.draftPlatformFilter
                    )
                    displayText: currentIndex >= 0
                        ? String(root.platformLabels[currentIndex] || "Tất cả nền tảng")
                        : "Tất cả nền tảng"
                    activeFocusOnTab: true
                    Accessible.name: "Lọc theo nền tảng"
                    onActivated: function(index) {
                        root.draftPlatformFilter = root.selectOption(
                            root.platformOptions, index, ""
                        )
                    }
                }
                ScheduleCombo {
                    objectName: "scheduleTimezoneField"
                    Layout.preferredWidth: 142
                    Layout.preferredHeight: 30
                    model: root.timezoneLabels
                    currentIndex: root.optionIndex(
                        root.timezoneOptions, root.draftTimezone
                    )
                    displayText: currentIndex >= 0
                        ? String(root.timezoneLabels[currentIndex] || "Múi giờ của kênh")
                        : "Múi giờ của kênh"
                    enabled: true
                    activeFocusOnTab: true
                    Accessible.name: "Múi giờ lịch"
                    Accessible.description: "Thời gian được quy đổi theo múi giờ đã chọn"
                    onActivated: function(index) {
                        root.draftTimezone = root.selectOption(
                            root.timezoneOptions, index, root.draftTimezone
                        )
                    }
                }
                AppButton {
                    objectName: "scheduleApplyFiltersButton"
                    text: "Áp dụng"
                    Layout.preferredHeight: 30
                    enabled: root.anchorInputValid
                    availabilityReason: enabled ? ""
                        : "Cần ngày và múi giờ hợp lệ"
                    Accessible.name: "Áp dụng bộ lọc lịch"
                    onClicked: root.applyServerFilters()
                }
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        Rectangle {
            id: visibilityBanner
            objectName: "scheduleVisibilityBanner"
            property int total: root.totalInRange
            property int visibleCount: root.visibleCount
            property int hiddenCount: root.hiddenCount
            property string reason: root.visibilityReason
            property string summaryText: root.visibilitySummary
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 34 : 0
            visible: root.visibilityPartial || Boolean(root.navigationError)
            color: Qt.rgba(
                (root.navigationError ? Theme.danger : Theme.warning).r,
                (root.navigationError ? Theme.danger : Theme.warning).g,
                (root.navigationError ? Theme.danger : Theme.warning).b,
                0.10
            )
            border.width: 1
            border.color: Qt.rgba(
                (root.navigationError ? Theme.danger : Theme.warning).r,
                (root.navigationError ? Theme.danger : Theme.warning).g,
                (root.navigationError ? Theme.danger : Theme.warning).b,
                0.35
            )
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 8
                spacing: 8
                UiIcon {
                    name: root.navigationError
                        ? "semantic/alert-triangle" : "semantic/info"
                    tone: root.navigationError ? Theme.danger : Theme.warning
                    iconSize: 14
                }
                Text {
                    Layout.fillWidth: true
                    text: root.navigationError || root.visibilitySummary
                    color: root.navigationError ? Theme.danger : Theme.warning
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                AppButton {
                    objectName: "scheduleVisibilityNavigateButton"
                    visible: root.hiddenCount > 0
                    text: "Xem " + root.hiddenCount + " ngoài giờ"
                    implicitHeight: 26
                    Accessible.name: text
                    Accessible.description: root.visibilityReason
                    onClicked: hiddenScheduleDialog.open()
                }
            }
            Accessible.name: visibilityBanner.summaryText
            Accessible.description: visibilityBanner.reason
            Accessible.role: Accessible.AlertMessage
        }

        Item {
            id: calendarCanvas
            objectName: "scheduleCalendarCanvas"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            readonly property real gutter: root.viewMode === "week" ? 48 : 0
            readonly property real dayHeaderHeight: 36
            readonly property real footerHeight: 28
            readonly property real gridHeight: Math.max(248, height - dayHeaderHeight - footerHeight)
            readonly property real columnWidth: Math.max(70, (width - gutter) / 7)
            readonly property int monthRows: 6
            readonly property real monthCellHeight: gridHeight / monthRows
            readonly property int monthRawSlotCount: Math.max(
                1, Math.floor((monthCellHeight - 20) / 25)
            )

            Rectangle {
                x: calendarCanvas.gutter
                y: 0
                width: calendarCanvas.width - calendarCanvas.gutter
                height: calendarCanvas.dayHeaderHeight
                color: Theme.elevated
            }
            Repeater {
                model: 7
                delegate: Item {
                    id: dayHeader
                    required property int index
                    property var projectedDay: root.dayData(dayHeader.index)
                    property string dateLabel: String(dayHeader.projectedDay.date_label || "—")
                    objectName: "scheduleDayHeader_" + dayHeader.index
                    x: calendarCanvas.gutter + index * calendarCanvas.columnWidth
                    y: 0
                    width: calendarCanvas.columnWidth
                    height: calendarCanvas.dayHeaderHeight
                    Rectangle {
                        anchors.fill: parent
                        color: Boolean(dayHeader.projectedDay.is_today)
                            ? Theme.accentSoft : "transparent"
                    }
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0
                        Text { text: String(dayHeader.projectedDay.weekday_label || "—"); color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold; Layout.alignment: Qt.AlignHCenter }
                        Text { text: dayHeader.dateLabel; color: Boolean(dayHeader.projectedDay.is_today) ? Theme.accent : Theme.textFaint; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
                    }
                    Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: Theme.borderSoft }
                }
            }
            Repeater {
                model: root.viewMode === "week" ? root.hourTicks : []
                delegate: Item {
                    id: hourLine
                    required property int index
                    required property var modelData
                    x: 0
                    y: calendarCanvas.dayHeaderHeight
                        + (Number(hourLine.modelData) - root.axisStartHour)
                            / root.axisHourSpan * calendarCanvas.gridHeight
                    width: calendarCanvas.width
                    height: 1
                    Rectangle { x: calendarCanvas.gutter; width: parent.width - calendarCanvas.gutter; height: 1; color: Theme.borderSoft }
                    Text { x: 4; y: -7; text: root.hourLabel(hourLine.modelData); color: Theme.textFaint; font.pixelSize: 11 }
                }
            }
            Repeater {
                model: 8
                delegate: Rectangle {
                    required property int index
                    x: calendarCanvas.gutter + index * calendarCanvas.columnWidth
                    y: calendarCanvas.dayHeaderHeight
                    width: 1
                    height: calendarCanvas.gridHeight
                    color: Theme.borderSoft
                }
            }
            Repeater {
                model: root.viewMode === "month" ? 7 : 0
                delegate: Rectangle {
                    required property int index
                    x: 0
                    y: calendarCanvas.dayHeaderHeight + index * calendarCanvas.monthCellHeight
                    width: calendarCanvas.width
                    height: 1
                    color: Theme.borderSoft
                }
            }
            Repeater {
                model: root.viewMode === "month" ? 42 : 0
                delegate: Text {
                    id: monthDate
                    required property int index
                    readonly property var projectedDay: root.dayData(monthDate.index)
                    x: (monthDate.index % 7) * calendarCanvas.columnWidth + 6
                    y: calendarCanvas.dayHeaderHeight
                        + Math.floor(monthDate.index / 7) * calendarCanvas.monthCellHeight + 4
                    text: String(monthDate.projectedDay.local_date || "").slice(8, 10) || "—"
                    color: Boolean(monthDate.projectedDay.is_today)
                        ? Theme.accent : Theme.textFaint
                    font.pixelSize: 11
                    font.weight: Boolean(monthDate.projectedDay.is_today)
                        ? Font.Bold : Font.Normal
                }
            }

            Repeater {
                model: root.viewMode === "week" ? root.optimalWindows : []
                delegate: Rectangle {
                    id: optimalWindow
                    required property int index
                    required property var modelData
                    readonly property int projectedDay: Number(
                        optimalWindow.modelData.day_index ?? -1
                    )
                    readonly property real startHour: Number(
                        optimalWindow.modelData.start_hour ?? 8
                    )
                    readonly property real endHour: Number(
                        optimalWindow.modelData.end_hour ?? optimalWindow.startHour
                    )
                    objectName: "scheduleOptimalWindow_"
                        + String(optimalWindow.modelData.id || optimalWindow.index)
                    visible: optimalWindow.projectedDay >= 0
                        && optimalWindow.projectedDay < 7
                        && optimalWindow.endHour > optimalWindow.startHour
                        && optimalWindow.endHour > root.axisStartHour
                        && optimalWindow.startHour < root.axisEndHour
                    x: calendarCanvas.gutter
                        + Math.max(0, optimalWindow.projectedDay)
                            * calendarCanvas.columnWidth + 1
                    y: calendarCanvas.dayHeaderHeight + Math.max(
                        0,
                        (Math.max(optimalWindow.startHour, root.axisStartHour)
                            - root.axisStartHour) / root.axisHourSpan
                            * calendarCanvas.gridHeight
                    )
                    width: calendarCanvas.columnWidth - 2
                    height: Math.max(
                        2,
                        (Math.min(optimalWindow.endHour, root.axisEndHour)
                            - Math.max(optimalWindow.startHour, root.axisStartHour))
                            / root.axisHourSpan
                            * calendarCanvas.gridHeight
                    )
                    color: Qt.rgba(
                        Theme.success.r, Theme.success.g, Theme.success.b, 0.055
                    )
                    border.width: 0
                    Accessible.name: "Khung giờ tối ưu "
                        + String(optimalWindow.modelData.start_time || "") + "–"
                        + String(optimalWindow.modelData.end_time || "")
                    Accessible.description: root.evidenceLabel(
                        optimalWindow.modelData.evidence
                    )
                }
            }

            Rectangle {
                id: currentTimeLine
                objectName: "scheduleCurrentTimeLine"
                property bool outsideVisibleHours:
                    Number(root.currentTimeData.hour_fraction ?? -1)
                        < root.axisStartHour
                    || Number(root.currentTimeData.hour_fraction ?? -1)
                        > root.axisEndHour
                visible: root.viewMode === "week"
                    && Boolean(root.currentTimeData.available)
                    && Number(root.currentTimeData.day_index ?? -1) >= 0
                    && Number(root.currentTimeData.day_index ?? -1) < 7
                x: calendarCanvas.gutter
                y: calendarCanvas.dayHeaderHeight + Math.max(
                    0,
                    Math.min(
                        1,
                        (Number(root.currentTimeData.hour_fraction
                            ?? root.axisStartHour) - root.axisStartHour)
                            / root.axisHourSpan
                    ) * calendarCanvas.gridHeight
                )
                width: calendarCanvas.width - calendarCanvas.gutter
                height: 1
                color: currentTimeLine.outsideVisibleHours
                    ? Theme.warning : Theme.danger
                z: 5
                Rectangle {
                    x: -1
                    anchors.verticalCenter: parent.verticalCenter
                    width: 8
                    height: 8
                    radius: 4
                    color: currentTimeLine.outsideVisibleHours
                        ? Theme.warning : Theme.danger
                }
                Text {
                    x: 5
                    y: -15
                    text: String(root.currentTimeData.local_time || "").slice(11, 16)
                        + (currentTimeLine.outsideVisibleHours
                            ? " · ngoài khung" : "")
                    color: currentTimeLine.outsideVisibleHours
                        ? Theme.warning : Theme.danger
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
                Accessible.name: "Thời gian hiện tại "
                    + String(root.currentTimeData.local_time || "")
                    + (currentTimeLine.outsideVisibleHours
                        ? ", ngoài khung giờ hiển thị" : "")
                Accessible.role: Accessible.StaticText
            }

            Repeater {
                objectName: "scheduleCardRepeater"
                model: root.occurrenceRows
                delegate: Rectangle {
                    id: scheduleCard
                    required property int index
                    required property var modelData
                    readonly property string entity_id: String(
                        scheduleCard.modelData.entity_id || ""
                    )
                    readonly property int version: Number(
                        scheduleCard.modelData.version ?? 0
                    )
                    readonly property string content_id: String(
                        scheduleCard.modelData.content_id || ""
                    )
                    readonly property string content_package_id: String(
                        scheduleCard.modelData.content_package_id || ""
                    )
                    readonly property string channel_id: String(
                        scheduleCard.modelData.channel_id || ""
                    )
                    readonly property string title: String(
                        scheduleCard.modelData.title || ""
                    )
                    readonly property string platform: String(
                        scheduleCard.modelData.platform || ""
                    )
                    readonly property var channel: scheduleCard.modelData.channel
                    readonly property string run_at: String(
                        scheduleCard.modelData.run_at || ""
                    )
                    readonly property string local_time: String(
                        scheduleCard.modelData.local_time || ""
                    )
                    readonly property string timezone: String(
                        scheduleCard.modelData.timezone || ""
                    )
                    readonly property int duration_seconds: Number(
                        scheduleCard.modelData.duration_seconds ?? 0
                    )
                    readonly property string state_value: String(
                        scheduleCard.modelData.state_value || ""
                    )
                    readonly property bool has_conflict: Boolean(
                        scheduleCard.modelData.has_conflict
                    )
                    readonly property var deep_link: scheduleCard.modelData.deep_link
                    objectName: "scheduleCard_" + scheduleCard.entity_id
                    readonly property string stateValue: scheduleCard.state_value
                    readonly property var itemData: ({
                        "id": scheduleCard.entity_id,
                        "version": scheduleCard.version,
                        "content_id": scheduleCard.content_id,
                        "content_package_id": scheduleCard.content_package_id,
                        "channel_id": scheduleCard.channel_id,
                        "title": scheduleCard.title,
                        "platform": scheduleCard.platform,
                        "channel": scheduleCard.channel,
                        "run_at": scheduleCard.run_at,
                        "local_time": scheduleCard.local_time,
                        "timezone": scheduleCard.timezone,
                        "duration_seconds": scheduleCard.duration_seconds,
                        "state": scheduleCard.state_value,
                        "has_conflict": scheduleCard.has_conflict,
                        "deep_link": scheduleCard.deep_link
                    })
                    property int gridDay: root.computeDayIndex(scheduleCard.itemData)
                    readonly property int overlapOrdinal: root.viewMode === "week"
                        ? root.overlapOrdinal(
                            scheduleCard.itemData, scheduleCard.index
                        ) : 0
                    readonly property int overlapLanes: root.viewMode === "week"
                        ? root.overlapLaneCount(scheduleCard.itemData) : 1
                    readonly property int overlapLane: root.viewMode === "week"
                        ? root.overlapLane(
                            scheduleCard.itemData, scheduleCard.index
                        ) : 0
                    readonly property int monthDayOrdinal: root.viewMode === "month"
                        ? root.dayOrdinal(
                            scheduleCard.itemData, scheduleCard.index
                        ) : -1
                    readonly property int monthDisplayOrdinal:
                        root.viewMode === "month"
                            ? root.monthDisplayOrdinal(
                                scheduleCard.itemData, scheduleCard.index
                            ) : -1
                    function activate() { root.scheduleSelected(scheduleCard.itemData) }
                    function proposeMoveMinutes(minutes: int) {
                        if (!root.canWrite)
                            return
                        const current = new Date(String(scheduleCard.run_at || ""))
                        if (isNaN(current.getTime()))
                            return
                        const proposed = new Date(current.getTime() + Number(minutes) * 60000)
                        const proposal = {
                            "id": scheduleCard.entity_id,
                            "channel_id": scheduleCard.channel_id,
                            "run_at": proposed.toISOString(),
                            "timezone": scheduleCard.timezone,
                            "duration_seconds": scheduleCard.duration_seconds,
                            "kind": "move"
                        }
                        if (root.proposalTarget)
                            root.proposalTarget.applyProposal(proposal)
                        root.scheduleProposal(proposal)
                    }
                    function proposeResizeMinutes(minutes: int) {
                        if (!root.canWrite)
                            return
                        const proposal = {
                            "id": scheduleCard.entity_id,
                            "channel_id": scheduleCard.channel_id,
                            "run_at": scheduleCard.run_at,
                            "timezone": scheduleCard.timezone,
                            "duration_seconds": Math.max(60, scheduleCard.duration_seconds + Number(minutes) * 60),
                            "kind": "resize"
                        }
                        if (root.proposalTarget)
                            root.proposalTarget.applyProposal(proposal)
                        root.scheduleProposal(proposal)
                    }
                    visible: scheduleCard.gridDay >= 0
                        && (root.viewMode === "week"
                            || scheduleCard.monthDisplayOrdinal >= 0)
                    x: calendarCanvas.gutter + (Math.max(0, scheduleCard.gridDay) % 7)
                        * calendarCanvas.columnWidth + 4
                    y: root.viewMode === "week"
                        ? calendarCanvas.dayHeaderHeight + Math.max(
                            0,
                            (root.localHour(scheduleCard.itemData)
                                - root.axisStartHour) / root.axisHourSpan
                                * calendarCanvas.gridHeight
                        ) + (scheduleCard.overlapLanes > 1
                            ? scheduleCard.overlapLane * 31 : 0)
                        : calendarCanvas.dayHeaderHeight
                            + Math.floor(Math.max(0, scheduleCard.gridDay) / 7)
                                * calendarCanvas.monthCellHeight + 20
                                + scheduleCard.monthDisplayOrdinal * 25
                    width: root.viewMode === "week"
                        ? calendarCanvas.columnWidth - 8
                        : calendarCanvas.columnWidth - 8
                    height: root.viewMode === "week"
                        ? (scheduleCard.overlapLanes > 1
                            ? 30 : Math.max(
                                62,
                                Math.min(82, calendarCanvas.gridHeight * 0.145)
                            ))
                        : 24
                    radius: Theme.radiusSmall
                    clip: true
                    color: Qt.rgba(
                        root.stateTone(scheduleCard.state_value).r,
                        root.stateTone(scheduleCard.state_value).g,
                        root.stateTone(scheduleCard.state_value).b,
                        root.selectedScheduleId === scheduleCard.entity_id ? 0.22 : 0.11
                    )
                    border.width: root.selectedScheduleId === scheduleCard.entity_id ? 2 : 1
                    border.color: root.stateTone(scheduleCard.state_value)
                    z: root.selectedScheduleId === scheduleCard.entity_id ? 4 : 2
                    activeFocusOnTab: true
                    Accessible.name: String(scheduleCard.title || "Lịch")
                        + ", " + root.stateLabel(scheduleCard.state_value)
                    Accessible.description: root.canWrite
                        ? "Kéo để tạo đề xuất; dữ liệu chỉ đổi sau khi lưu phía server"
                        : "Chỉ xem; thiếu quyền workspace.write"
                    Accessible.role: Accessible.ListItem
                    Accessible.focusable: true
                    Keys.onReturnPressed: scheduleCard.activate()
                    Keys.onEnterPressed: scheduleCard.activate()
                    Keys.onSpacePressed: scheduleCard.activate()
                    Keys.onPressed: function(event) {
                        if (event.key !== Qt.Key_Left && event.key !== Qt.Key_Right)
                            return
                        const amount = event.key === Qt.Key_Left ? -15 : 15
                        if ((event.modifiers & Qt.ShiftModifier) !== 0)
                            scheduleCard.proposeResizeMinutes(amount)
                        else
                            scheduleCard.proposeMoveMinutes(amount)
                        event.accepted = true
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: root.viewMode === "week" ? 7 : 4
                        spacing: 1
                        visible: root.viewMode === "month"
                            || scheduleCard.overlapLanes === 1
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            SocialIcon { platform: String(scheduleCard.platform || "generic"); Layout.preferredWidth: 14; Layout.preferredHeight: 14 }
                            Text { Layout.fillWidth: true; text: scheduleCard.title; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                        }
                        Text { visible: root.viewMode === "week"; Layout.fillWidth: true; text: String((scheduleCard.channel || {}).display_name || ""); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                        Text { visible: root.viewMode === "week"; text: scheduleCard.local_time.slice(11, 16); color: Theme.textMuted; font.pixelSize: 11 }
                        Text { visible: root.viewMode === "week"; text: root.stateLabel(scheduleCard.state_value); color: root.stateTone(scheduleCard.state_value); font.pixelSize: 11; font.weight: Font.DemiBold }
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 4
                        visible: root.viewMode === "week"
                            && scheduleCard.overlapLanes > 1
                        Text {
                            Layout.fillWidth: true
                            text: scheduleCard.title
                            color: Theme.text
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Text {
                            text: root.compactStateLabel(scheduleCard.state_value)
                            color: root.stateTone(scheduleCard.state_value)
                            font.pixelSize: Theme.fontMetadata
                            font.weight: Font.DemiBold
                        }
                    }
                    MouseArea {
                        id: moveArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: root.canWrite ? Qt.OpenHandCursor : Qt.PointingHandCursor
                        property real startY: 0
                        onPressed: function(mouse) {
                            moveArea.startY = mouse.y
                            cursorShape = root.canWrite
                                ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                        }
                        onReleased: function(mouse) {
                            cursorShape = root.canWrite
                                ? Qt.OpenHandCursor : Qt.PointingHandCursor
                            const delta = mouse.y - moveArea.startY
                            if (root.canWrite && Math.abs(delta) >= 8)
                                scheduleCard.proposeMoveMinutes(Math.round(delta / 8) * 15)
                            else
                                scheduleCard.activate()
                        }
                    }
                    Rectangle {
                        visible: root.viewMode === "week" && root.canWrite
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 5
                        color: Qt.rgba(1, 1, 1, 0.12)
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.SizeVerCursor
                            property real startY: 0
                            onPressed: function(mouse) { startY = mouse.y }
                            onReleased: function(mouse) {
                                const delta = mouse.y - startY
                                if (Math.abs(delta) >= 2)
                                    scheduleCard.proposeResizeMinutes(Math.round(delta / 4) * 15)
                            }
                        }
                    }
                }
            }

            Repeater {
                model: root.viewMode === "month" ? 42 : 0
                delegate: AppButton {
                    id: monthOverflow
                    required property int index
                    readonly property string localDate: String(
                        (root.dayData(monthOverflow.index) || {}).local_date || ""
                    )
                    property int totalCount: root.monthDayCount(
                        monthOverflow.index
                    )
                    property int displayedCount: root.monthDisplayedCount(
                        monthOverflow.index
                    )
                    property int overflowCount: Math.max(
                        0, monthOverflow.totalCount - monthOverflow.displayedCount
                    )
                    objectName: "scheduleMonthOverflow_" + monthOverflow.localDate
                    visible: monthOverflow.localDate.length > 0
                        && monthOverflow.overflowCount > 0
                    x: (monthOverflow.index % 7) * calendarCanvas.columnWidth + 4
                    y: calendarCanvas.dayHeaderHeight
                        + Math.floor(monthOverflow.index / 7)
                            * calendarCanvas.monthCellHeight + 20
                        + monthOverflow.displayedCount * 25
                    width: calendarCanvas.columnWidth - 8
                    height: 24
                    implicitHeight: 24
                    text: "+" + monthOverflow.overflowCount + " lịch · Xem ngày"
                    Accessible.name: text + " "
                        + root.displayDate(monthOverflow.localDate)
                    Accessible.description: "Mở danh sách đầy đủ "
                        + monthOverflow.totalCount + " lịch trong ngày"
                    onClicked: root.openMonthDay(monthOverflow.localDate)
                    z: 6
                }
            }

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                height: calendarCanvas.footerHeight
                spacing: 14
                Text {
                    objectName: "scheduleVisibilityFooter"
                    text: root.visibleCount + "/" + root.totalInRange
                        + " trong khung · " + root.hiddenCount + " ngoài giờ"
                    color: root.hiddenCount > 0 ? Theme.warning : Theme.textMuted
                    font.pixelSize: 11
                    Accessible.name: root.visibilitySummary
                }
                Text { text: "● ExternalPost xác minh = đã xuất bản"; color: Theme.success; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
                AppButton {
                    objectName: "scheduleCalendarNextPageButton"
                    visible: Boolean(root.calendar.next_cursor)
                    text: "Trang tiếp"
                    implicitHeight: 24
                    availabilityReason: visible ? "" : "Server không trả cursor trang tiếp"
                    onClicked: root.nextPageRequested()
                }
            }
        }
    }
}
