pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "CenterFormat.js" as Fmt

Item {
    id: root
    objectName: "centerPublishingSchedulePage"

    required property var plane

    property int selectedOccurrenceIndex: 0
    property int selectedBacklogIndex: -1
    property int modelRevision: 0
    property int weekOffset: 0
    property string backlogQuery: ""
    property string channelFilter: ""
    property string platformFilter: ""
    readonly property bool compactLayout: width < 1450
    readonly property var occurrenceModel: root.plane.scheduleOccurrenceModel
    readonly property var selectedOccurrence: root.modelRow(
        root.occurrenceModel, root.selectedOccurrenceIndex)
    readonly property var selectedBacklog: root.modelRow(
        root.plane.allStepModel, root.selectedBacklogIndex)
    readonly property var selectedOccurrenceOrder: root.findModelRow(
        root.plane.orderModel, "orderId", root.selectedOccurrence.orderId)
    readonly property var selectedOccurrenceProfile: root.findModelRow(
        root.plane.profileModel, "profileId", root.selectedOccurrence.profileId)
    readonly property var selectedPublishStep: root.findPublishStep(
        root.selectedOccurrence.orderId)

    function modelRow(model, index) {
        const revision = root.modelRevision
        if (!model || index < 0 || index >= Number(model.count || 0))
            return ({})
        return model.get(index) || ({})
    }

    function findModelRow(model, field, value) {
        const revision = root.modelRevision
        const expected = String(value || "")
        if (!model || !expected)
            return ({})
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const row = model.get(index) || ({})
            if (String(row[field] || "") === expected)
                return row
        }
        return ({})
    }

    function findPublishStep(orderId) {
        const revision = root.modelRevision
        const expected = String(orderId || "")
        const model = root.plane.allStepModel
        if (!model || !expected)
            return ({})
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const row = model.get(index) || ({})
            if (String(row.orderId || "") === expected
                    && String(row.kind || "").toLowerCase() === "publish")
                return row
        }
        return ({})
    }

    function isBacklog(row) {
        const kind = String(row.kind || "").toLowerCase()
        const status = String(row.status || "").toLowerCase()
        return kind === "publish" && ["queued", "ready", "waiting_approval"].indexOf(status) >= 0
    }

    function backlogMatches(row) {
        if (!root.isBacklog(row))
            return false
        if (root.platformFilter
                && String(row.platform || "").toLowerCase() !== root.platformFilter)
            return false
        if (root.channelFilter
                && String(row.channelId || "") !== root.channelFilter)
            return false
        if (!root.backlogQuery)
            return true
        const haystack = [row.title, row.channelId, row.platform, row.workflow,
            row.profileId].join(" ").toLowerCase()
        return haystack.indexOf(root.backlogQuery) >= 0
    }

    function backlogCount() {
        const revision = root.modelRevision
        const model = root.plane.allStepModel
        let count = 0
        if (!model)
            return count
        for (let index = 0; index < Number(model.count || 0); ++index) {
            if (root.backlogMatches(model.get(index) || ({})))
                count++
        }
        return count
    }

    function backlogTitle(row) {
        const order = root.findModelRow(root.plane.orderModel, "orderId", row.orderId)
        return String(order.title || row.title || qsTr("Nội dung chờ đăng"))
    }

    function backlogWorkflow(row) {
        const revision = root.modelRevision
        const expected = String(row.orderId || "")
        const model = root.plane.allStepModel
        if (model && expected) {
            for (let index = 0; index < Number(model.count || 0); ++index) {
                const step = model.get(index) || ({})
                if (String(step.orderId || "") === expected
                        && String(step.kind || "").toLowerCase() === "workflow")
                    return String(step.workflow || row.workflow || "publish")
            }
        }
        return String(row.workflow || "publish")
    }

    function backlogChannelLabel(row) {
        const profile = root.findModelRow(root.plane.profileModel, "profileId", row.profileId)
        return String(profile.label || row.channelId || qsTr("Chưa gán kênh"))
    }

    function platformOccurrenceCount(platform) {
        const revision = root.modelRevision
        const expected = String(platform || "").toLowerCase()
        let count = 0
        if (!root.occurrenceModel)
            return count
        for (let index = 0; index < Number(root.occurrenceModel.count || 0); ++index) {
            const row = root.occurrenceModel.get(index) || ({})
            if (String(row.platform || "").toLowerCase() === expected
                    && root.occurrenceMatches(row))
                count++
        }
        return count
    }

    function firstOccurrenceDate() {
        if (!root.occurrenceModel || Number(root.occurrenceModel.count || 0) === 0)
            return new Date()
        const row = root.occurrenceModel.get(0) || ({})
        const date = new Date(String(row.scheduledAtUtc || ""))
        return isNaN(date.getTime()) ? new Date() : date
    }

    function weekStart() {
        const date = root.firstOccurrenceDate()
        const day = date.getDay() === 0 ? 7 : date.getDay()
        const result = new Date(date.getFullYear(), date.getMonth(), date.getDate())
        result.setDate(result.getDate() - day + 1)
        result.setDate(result.getDate() + root.weekOffset * 7)
        result.setHours(0, 0, 0, 0)
        return result
    }

    function dayAt(index) {
        const date = root.weekStart()
        date.setDate(date.getDate() + index)
        return date
    }

    function dayIndex(value) {
        const date = new Date(String(value || ""))
        if (isNaN(date.getTime()))
            return 0
        const delta = Math.floor((new Date(date.getFullYear(), date.getMonth(), date.getDate()).getTime()
            - root.weekStart().getTime()) / 86400000)
        return Math.max(0, Math.min(6, delta))
    }

    function occurrenceMatches(row) {
        if (root.platformFilter
                && String(row.platform || "").toLowerCase() !== root.platformFilter)
            return false
        if (root.channelFilter
                && String(row.channelId || "") !== root.channelFilter)
            return false
        const date = new Date(String(row.scheduledAtUtc || ""))
        if (isNaN(date.getTime()))
            return false
        const localDay = new Date(date.getFullYear(), date.getMonth(), date.getDate())
        const delta = Math.floor((localDay.getTime() - root.weekStart().getTime()) / 86400000)
        return delta >= 0 && delta <= 6
    }

    function occurrenceTitle(row) {
        const order = root.findModelRow(root.plane.orderModel, "orderId", row.orderId)
        return String(order.title || row.channelId || qsTr("Lịch đăng"))
    }

    function minutesOfDay(value) {
        const date = new Date(String(value || ""))
        return isNaN(date.getTime()) ? 720 : date.getHours() * 60 + date.getMinutes()
    }

    function two(value) { return String(value).padStart(2, "0") }

    function dayLabel(index) {
        const date = root.dayAt(index)
        const names = [qsTr("Thứ 2"), qsTr("Thứ 3"), qsTr("Thứ 4"), qsTr("Thứ 5"),
            qsTr("Thứ 6"), qsTr("Thứ 7"), qsTr("Chủ nhật")]
        return names[index] + "\n" + root.two(date.getDate()) + "/" + root.two(date.getMonth() + 1)
    }

    function weekLabel() {
        const start = root.dayAt(0)
        const end = root.dayAt(6)
        return root.two(start.getDate()) + "/" + root.two(start.getMonth() + 1)
            + " – " + root.two(end.getDate()) + "/" + root.two(end.getMonth() + 1)
            + "/" + end.getFullYear()
    }

    Connections {
        target: root.occurrenceModel
        function onModelReset() { root.modelRevision++ }
        function onDataChanged() { root.modelRevision++ }
        function onCountChanged() {
            root.modelRevision++
            if (root.selectedOccurrenceIndex >= Number(root.occurrenceModel.count || 0))
                root.selectedOccurrenceIndex = Math.max(0, Number(root.occurrenceModel.count || 0) - 1)
        }
    }

    Connections {
        target: root.plane.allStepModel
        function onModelReset() { root.modelRevision++ }
        function onDataChanged() { root.modelRevision++ }
        function onCountChanged() { root.modelRevision++ }
    }

    Connections {
        target: root.plane.orderModel
        function onModelReset() { root.modelRevision++ }
        function onDataChanged() { root.modelRevision++ }
        function onCountChanged() { root.modelRevision++ }
    }

    Connections {
        target: root.plane.profileModel
        function onModelReset() { root.modelRevision++ }
        function onDataChanged() { root.modelRevision++ }
        function onCountChanged() { root.modelRevision++ }
    }

    component SectionTitle: Text {
        color: CenterTokens.text
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.sectionTitle
        font.weight: Font.DemiBold
    }

    component MetaText: Text {
        color: CenterTokens.muted
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.metadata + 1
        elide: Text.ElideRight
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: CenterTokens.pageGutter
        anchors.rightMargin: CenterTokens.pageGutter
        anchors.topMargin: 14
        anchors.bottomMargin: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            spacing: 10
            ColumnLayout {
                Layout.minimumWidth: 0
                Layout.preferredWidth: root.compactLayout ? 330 : 430
                spacing: 3
                Text {
                    text: qsTr("Lịch đăng")
                    color: CenterTokens.text
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.pageTitle
                    font.weight: Font.Bold
                }
                Text {
                    Layout.fillWidth: true
                    text: qsTr("Xếp lịch PublishKit theo sức chứa, múi giờ và trạng thái hồ sơ đăng.")
                    color: CenterTokens.muted
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.body
                    elide: Text.ElideRight
                }
            }
            Item { Layout.fillWidth: true }
            AppButton {
                objectName: "schedulePreviousWeekButton"
                text: "‹"
                subtle: true
                onClicked: root.weekOffset--
            }
            Rectangle {
                objectName: "scheduleCalendarDateField"
                Layout.preferredWidth: root.compactLayout ? 180 : 200
                Layout.preferredHeight: CenterTokens.controlHeight
                radius: CenterTokens.radiusSmall
                color: CenterTokens.panel
                border.width: 1
                border.color: CenterTokens.border
                RowLayout {
                    anchors.centerIn: parent
                    UiIcon {
                        name: "ui/calendar"
                        tone: CenterTokens.primary
                        iconSize: 15
                        Layout.preferredWidth: 15
                        Layout.preferredHeight: 15
                    }
                    Text {
                        text: root.weekLabel()
                        color: CenterTokens.text
                        font.family: CenterTokens.fontFamily
                        font.pixelSize: CenterTokens.body
                        font.weight: Font.DemiBold
                    }
                }
            }
            AppButton {
                objectName: "scheduleNextWeekButton"
                text: "›"
                subtle: true
                onClicked: root.weekOffset++
            }
            AppButton {
                objectName: "scheduleTodayButton"
                text: qsTr("Hôm nay")
                subtle: true
                onClicked: root.weekOffset = 0
            }
            AppComboBox {
                objectName: "scheduleChannelFilter"
                Layout.preferredWidth: root.compactLayout ? 150 : 187
                Layout.preferredHeight: CenterTokens.controlHeight
                model: root.plane.profileModel
                textRole: "label"
                currentIndex: -1
                displayText: currentIndex < 0 ? qsTr("Tất cả kênh") : currentText
                onActivated: root.channelFilter = String(
                    (model.get(currentIndex) || ({})).channelId || "")
            }
            AppComboBox {
                objectName: "schedulePlatformFilter"
                Layout.preferredWidth: 180
                Layout.preferredHeight: CenterTokens.controlHeight
                model: [
                    {"text": qsTr("Tất cả nền tảng"), "value": ""},
                    {"text": "YouTube", "value": "youtube"},
                    {"text": "TikTok", "value": "tiktok"},
                    {"text": "Facebook", "value": "facebook"}
                ]
                textRole: "text"
                valueRole: "value"
                onActivated: root.platformFilter = String(currentValue || "")
                visible: !root.compactLayout
            }
            AppButton {
                Layout.preferredWidth: root.compactLayout ? 110 : 130
                text: qsTr("Xếp lịch")
                leadingIcon: "ui/plus"
                primary: true
                enabled: false
                visualEnabled: true
                availabilityReason: qsTr("Chọn Assignment V2 đã duyệt từ Điều phối trước khi xếp lịch.")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: CenterTokens.gap

            CenterPanel {
                Layout.minimumWidth: 0
                Layout.preferredWidth: root.compactLayout
                    ? Math.max(255, root.width * 0.22)
                    : Math.max(320, root.width * 0.25)
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: CenterTokens.panelPadding
                    spacing: 8
                    SectionTitle { text: qsTr("Backlog sẵn sàng đăng") }
                    CenterSearchField {
                        Layout.fillWidth: true
                        placeholderText: qsTr("Tìm nội dung...")
                        onQueryCommitted: query => root.backlogQuery = query.toLowerCase()
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        CenterStatusBadge { text: qsTr("Sẵn sàng"); status: "success" }
                        CenterStatusBadge { text: qsTr("Cần metadata"); status: "warning" }
                        CenterStatusBadge { text: qsTr("Cần xử lý"); status: "danger" }
                    }
                    ListView {
                        id: backlogList
                        objectName: "scheduleBacklogList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: root.plane.allStepModel
                        spacing: 0
                        clip: true
                        reuseItems: true
                        boundsBehavior: Flickable.StopAtBounds
                        delegate: Item {
                            id: backlogItem
                            required property int index
                            required property var modelData
                            readonly property bool matches: root.backlogMatches(modelData)
                            width: ListView.view.width
                            height: matches ? 80 : 0
                            visible: matches
                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: 73
                                radius: CenterTokens.radiusSmall
                                color: root.selectedBacklogIndex === backlogItem.index
                                    ? CenterTokens.primarySoft : CenterTokens.panel
                                border.width: 1
                                border.color: root.selectedBacklogIndex === backlogItem.index
                                    ? CenterTokens.primary : CenterTokens.border
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 9
                                    Rectangle {
                                        Layout.preferredWidth: 96
                                        Layout.fillHeight: true
                                        radius: 5
                                        color: CenterTokens.panelSoft
                                        UiIcon {
                                            anchors.centerIn: parent
                                            name: "ui/play"
                                            tone: CenterTokens.faint
                                            iconSize: 18
                                        }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        CenterStatusBadge {
                                            text: Fmt.workflowLabel(root.backlogWorkflow(backlogItem.modelData))
                                            status: Fmt.workflowTone(root.backlogWorkflow(backlogItem.modelData))
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: root.backlogTitle(backlogItem.modelData)
                                            color: CenterTokens.text
                                            font.family: CenterTokens.fontFamily
                                            font.pixelSize: CenterTokens.body
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }
                                        RowLayout {
                                            Layout.fillWidth: true
                                            PlatformIcon {
                                                platform: String(backlogItem.modelData.platform || "generic")
                                                iconSize: 13
                                                Layout.preferredWidth: 13
                                                Layout.preferredHeight: 13
                                            }
                                            MetaText {
                                                Layout.fillWidth: true
                                                text: root.backlogChannelLabel(backlogItem.modelData)
                                            }
                                        }
                                    }
                                    CenterStatusBadge {
                                        text: backlogItem.modelData.gateState === "ready"
                                            ? qsTr("Ready")
                                            : backlogItem.modelData.gateState === "waiting_metadata"
                                            ? qsTr("Thiếu metadata") : qsTr("Chờ gate")
                                        status: backlogItem.modelData.gateState === "ready" ? "success" : "warning"
                                    }
                                }
                                TapHandler { onTapped: root.selectedBacklogIndex = backlogItem.index }
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: backlogList.count === 0 || backlogList.contentHeight === 0
                            text: qsTr("Chưa có PublishKit đủ điều kiện xếp lịch.")
                            width: parent.width - 30
                            color: CenterTokens.faint
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                        }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: CenterTokens.border }
                    MetaText {
                        Layout.fillWidth: true
                        text: qsTr("%1 nội dung chưa xếp lịch").arg(root.backlogCount())
                    }
                }
            }

            CenterPanel {
                id: calendarPanel
                objectName: "publishingCalendar"
                Layout.minimumWidth: 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        spacing: 16
                        CenterStatusBadge {
                            text: "YouTube · " + String(root.platformOccurrenceCount("youtube"))
                            status: "danger"
                            iconName: "product/youtube"
                        }
                        CenterStatusBadge {
                            text: "TikTok · " + String(root.platformOccurrenceCount("tiktok"))
                            status: "neutral"
                            iconName: "product/tiktok"
                        }
                        CenterStatusBadge {
                            text: "Facebook · " + String(root.platformOccurrenceCount("facebook"))
                            status: "info"
                            iconName: "product/facebook"
                        }
                        Item { Layout.fillWidth: true }
                    }

                    Item {
                        id: calendarGrid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        readonly property real labelWidth: 46
                        readonly property real headerHeight: 42
                        readonly property real columnWidth: (width - labelWidth) / 7
                        readonly property real hourHeight: (height - headerHeight) / 14
                        readonly property date currentTime: new Date()
                        readonly property int currentMinute: currentTime.getHours() * 60
                            + currentTime.getMinutes()
                        readonly property int currentDay: Math.floor((new Date(
                            currentTime.getFullYear(), currentTime.getMonth(), currentTime.getDate()).getTime()
                            - root.weekStart().getTime()) / 86400000)

                        Row {
                            x: calendarGrid.labelWidth
                            y: 0
                            width: calendarGrid.width - calendarGrid.labelWidth
                            height: calendarGrid.headerHeight
                            Repeater {
                                model: 7
                                delegate: Rectangle {
                                    id: dayHeader
                                    required property int index
                                    width: calendarGrid.columnWidth
                                    height: calendarGrid.headerHeight
                                    color: CenterTokens.panel
                                    border.width: 1
                                    border.color: CenterTokens.border
                                    Text {
                                        anchors.centerIn: parent
                                        text: root.dayLabel(dayHeader.index)
                                        horizontalAlignment: Text.AlignHCenter
                                        color: CenterTokens.text
                                        font.family: CenterTokens.fontFamily
                                        font.pixelSize: CenterTokens.metadata + 1
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }
                        }

                        Repeater {
                            model: 15
                            delegate: Item {
                                id: hourLine
                                required property int index
                                x: 0
                                y: calendarGrid.headerHeight + hourLine.index * calendarGrid.hourHeight
                                width: calendarGrid.width
                                height: 1
                                Text {
                                    x: 0
                                    y: -7
                                    width: calendarGrid.labelWidth - 6
                                    text: root.two(8 + hourLine.index) + ":00"
                                    horizontalAlignment: Text.AlignRight
                                    color: CenterTokens.faint
                                    font.family: CenterTokens.fontFamily
                                    font.pixelSize: CenterTokens.metadata
                                }
                                Rectangle {
                                    x: calendarGrid.labelWidth
                                    width: calendarGrid.width - calendarGrid.labelWidth
                                    height: 1
                                    color: CenterTokens.border
                                }
                            }
                        }

                        Repeater {
                            model: 8
                            delegate: Rectangle {
                                required property int index
                                x: calendarGrid.labelWidth + index * calendarGrid.columnWidth
                                y: calendarGrid.headerHeight
                                width: 1
                                height: calendarGrid.height - calendarGrid.headerHeight
                                color: CenterTokens.border
                            }
                        }

                        Rectangle {
                            visible: calendarGrid.currentDay >= 0 && calendarGrid.currentDay <= 6
                                && calendarGrid.currentMinute >= 8 * 60
                                && calendarGrid.currentMinute <= 22 * 60
                            x: calendarGrid.labelWidth
                            y: calendarGrid.headerHeight + (calendarGrid.currentMinute - 8 * 60)
                                / 60 * calendarGrid.hourHeight
                            width: calendarGrid.width - calendarGrid.labelWidth
                            height: 1
                            color: CenterTokens.danger
                            z: 3
                            Rectangle {
                                x: -3
                                y: -3
                                width: 7
                                height: 7
                                radius: 4
                                color: CenterTokens.danger
                            }
                            MetaText {
                                x: -44
                                y: -7
                                width: 38
                                text: root.two(calendarGrid.currentTime.getHours()) + ":"
                                    + root.two(calendarGrid.currentTime.getMinutes())
                                horizontalAlignment: Text.AlignRight
                                color: CenterTokens.danger
                            }
                        }

                        Repeater {
                            model: root.occurrenceModel
                            delegate: Rectangle {
                                id: occurrenceCard
                                required property int index
                                required property var modelData
                                readonly property bool matches: root.occurrenceMatches(modelData)
                                readonly property int minute: root.minutesOfDay(modelData.scheduledAtUtc)
                                objectName: "scheduleOccurrenceCard_" + String(modelData.occurrenceId || index)
                                visible: matches
                                x: calendarGrid.labelWidth + root.dayIndex(modelData.scheduledAtUtc)
                                    * calendarGrid.columnWidth + 5
                                y: calendarGrid.headerHeight + Math.max(0, minute - 8 * 60)
                                    / 60 * calendarGrid.hourHeight + 3
                                width: calendarGrid.columnWidth - 10
                                height: Math.max(94, calendarGrid.hourHeight * 2.45)
                                radius: 6
                                color: Fmt.statusKind(modelData.status) === "danger"
                                    ? CenterTokens.dangerSoft
                                    : Fmt.statusKind(modelData.status) === "warning"
                                    ? CenterTokens.warningSoft : CenterTokens.primarySoft
                                border.width: root.selectedOccurrenceIndex === index ? 2 : 1
                                border.color: Fmt.statusKind(modelData.status) === "danger"
                                    ? CenterTokens.danger
                                    : Fmt.statusKind(modelData.status) === "warning"
                                    ? CenterTokens.warning : CenterTokens.primary
                                clip: true
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 2
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            Layout.fillWidth: true
                                            text: {
                                                const date = new Date(String(occurrenceCard.modelData.scheduledAtUtc || ""))
                                                return isNaN(date.getTime()) ? "--:--"
                                                    : root.two(date.getHours()) + ":" + root.two(date.getMinutes())
                                            }
                                            color: CenterTokens.text
                                            font.family: CenterTokens.fontFamily
                                            font.pixelSize: CenterTokens.metadata + 1
                                            font.weight: Font.Bold
                                        }
                                        PlatformIcon {
                                            platform: String(occurrenceCard.modelData.platform || "generic")
                                            iconSize: 13
                                            Layout.preferredWidth: 13
                                            Layout.preferredHeight: 13
                                        }
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: root.occurrenceTitle(occurrenceCard.modelData)
                                        color: CenterTokens.text
                                        font.family: CenterTokens.fontFamily
                                        font.pixelSize: CenterTokens.metadata + 1
                                        font.weight: Font.DemiBold
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }
                                    MetaText {
                                        Layout.fillWidth: true
                                        text: String(occurrenceCard.modelData.channelId || qsTr("Chưa gán kênh"))
                                    }
                                    CenterStatusBadge {
                                        text: occurrenceCard.modelData.hasConflict ? qsTr("Xung đột")
                                            : Fmt.statusLabel(occurrenceCard.modelData.status,
                                                occurrenceCard.modelData.statusLabel)
                                        status: occurrenceCard.modelData.hasConflict
                                            ? "danger" : Fmt.statusKind(occurrenceCard.modelData.status)
                                    }
                                }
                                TapHandler { onTapped: root.selectedOccurrenceIndex = occurrenceCard.index }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !root.occurrenceModel || root.occurrenceModel.count === 0
                            text: qsTr("Chưa có occurrence trong tuần này")
                            color: CenterTokens.faint
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                        }
                    }
                }
            }

            CenterPanel {
                id: inspector
                objectName: "scheduleInspector"
                Layout.minimumWidth: 0
                Layout.preferredWidth: root.compactLayout
                    ? Math.max(250, root.width * 0.20)
                    : Math.max(290, root.width * 0.205)
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.compactLayout ? 10 : CenterTokens.panelPadding
                    spacing: root.compactLayout ? 6 : 9
                    SectionTitle { text: qsTr("Lịch phát hành") }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.compactLayout ? 48 : 58
                        spacing: 10
                        Rectangle {
                            Layout.preferredWidth: 86
                            Layout.fillHeight: true
                            radius: 5
                            color: CenterTokens.panelSoft
                            UiIcon {
                                anchors.centerIn: parent
                                name: "ui/play"
                                tone: CenterTokens.faint
                                iconSize: 18
                            }
                            MetaText {
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.margins: 4
                                text: root.selectedOccurrence.durationSeconds
                                    ? Math.max(1, Math.round(Number(root.selectedOccurrence.durationSeconds) / 60))
                                        + qsTr(" phút") : ""
                                color: CenterTokens.text
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: String(root.selectedOccurrenceOrder.title
                                || root.selectedOccurrence.channelId
                                || qsTr("Chọn một lịch trên calendar"))
                            color: CenterTokens.text
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                            font.weight: Font.DemiBold
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 10
                        rowSpacing: root.compactLayout ? 4 : 6
                        MetaText { text: qsTr("Kênh") }
                        MetaText { text: String(root.selectedOccurrence.channelId || "—"); color: CenterTokens.text }
                        MetaText { text: qsTr("Nền tảng") }
                        MetaText { text: Fmt.platformLabel(root.selectedOccurrence.platform); color: CenterTokens.text }
                        MetaText { text: qsTr("Thời gian") }
                        MetaText { text: Fmt.timeLabel(root.selectedOccurrence.scheduledAtUtc); color: CenterTokens.text }
                        MetaText { text: qsTr("Múi giờ") }
                        MetaText { text: String(root.selectedOccurrence.timezone || root.plane.localTimezone || "UTC"); color: CenterTokens.text }
                        MetaText { text: qsTr("Hồ sơ") }
                        MetaText { text: String(root.selectedOccurrence.profileId || "—"); color: CenterTokens.text }
                        MetaText { text: qsTr("Trình duyệt") }
                        MetaText { text: String(root.selectedOccurrenceProfile.browserKey || "—"); color: CenterTokens.text }
                        MetaText { text: qsTr("Caption") }
                        MetaText { text: String(root.selectedPublishStep.captionMode || "—"); color: CenterTokens.text }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: CenterTokens.border }
                    SectionTitle { text: qsTr("Preflight checklist") }
                    Repeater {
                        model: [
                            {"label": qsTr("Assignment V2 đã đóng băng"), "ok": Boolean(root.selectedOccurrence.assignmentHash)},
                            {"label": qsTr("Không xung đột sức chứa"), "ok": !Boolean(root.selectedOccurrence.hasConflict)},
                            {"label": qsTr("Có profile đăng"), "ok": Boolean(root.selectedOccurrence.profileId)},
                            {"label": qsTr("Browser đã xác minh"), "ok": ["verified", "ready", "active"].indexOf(String(root.selectedOccurrenceProfile.authState || "").toLowerCase()) >= 0},
                            {"label": qsTr("Có thời gian UTC + timezone"), "ok": Boolean(root.selectedOccurrence.scheduledAtUtc && root.selectedOccurrence.timezone)}
                        ]
                        delegate: RowLayout {
                            id: checklistRow
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 8
                            UiIcon {
                                name: checklistRow.modelData.ok ? "semantic/check-circle" : "semantic/alert-triangle"
                                tone: checklistRow.modelData.ok ? CenterTokens.success : CenterTokens.warning
                                iconSize: 14
                                Layout.preferredWidth: 14
                                Layout.preferredHeight: 14
                            }
                            MetaText { Layout.fillWidth: true; text: String(checklistRow.modelData.label) }
                            MetaText {
                                text: checklistRow.modelData.ok ? "OK" : qsTr("Thiếu")
                                color: checklistRow.modelData.ok
                                    ? CenterTokens.success : CenterTokens.warning
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: warningText.implicitHeight + 18
                        radius: CenterTokens.radiusSmall
                        color: root.selectedOccurrence.hasConflict ? CenterTokens.dangerSoft : CenterTokens.successSoft
                        border.width: 1
                        border.color: root.selectedOccurrence.hasConflict ? CenterTokens.danger : CenterTokens.success
                        Text {
                            id: warningText
                            anchors.fill: parent
                            anchors.margins: 9
                            text: root.selectedOccurrence.hasConflict
                                ? String(((root.selectedOccurrence.conflicts || [])[0] || {}).message
                                    || qsTr("Không được materialize lịch khi còn xung đột."))
                                : qsTr("Không phát hiện xung đột trong projection hiện tại.")
                            color: root.selectedOccurrence.hasConflict ? CenterTokens.danger : CenterTokens.success
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.metadata + 1
                            wrapMode: Text.Wrap
                        }
                    }
                    Item { Layout.fillHeight: true }
                    RowLayout {
                        Layout.fillWidth: true
                        AppButton {
                            Layout.fillWidth: true
                            text: qsTr("Mở job")
                            leadingIcon: "ui/external-link"
                            enabled: Boolean(root.selectedOccurrence.orderId)
                            onClicked: root.plane.selectOrder(
                                String(root.selectedOccurrence.orderId || ""))
                        }
                        AppButton {
                            Layout.fillWidth: true
                            text: qsTr("Đổi lịch")
                            leadingIcon: "ui/calendar"
                            enabled: false
                            visualEnabled: true
                            availabilityReason: qsTr("Đổi lịch cần tạo bản recurrence mới có kiểm tra xung đột.")
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        AppButton {
                            Layout.fillWidth: true
                            text: qsTr("Tạm dừng")
                            leadingIcon: "ui/pause"
                            enabled: Boolean(root.selectedOccurrence.recurrenceId)
                            onClicked: root.plane.callTool("schedule.recurrence.state", {
                                "recurrence_id": String(root.selectedOccurrence.recurrenceId || ""),
                                "state": "paused"
                            })
                        }
                        AppButton {
                            Layout.fillWidth: true
                            text: qsTr("Xác nhận lịch")
                            leadingIcon: "ui/check"
                            primary: true
                            enabled: Boolean(root.selectedOccurrence.recurrenceId)
                                && !Boolean(root.selectedOccurrence.hasConflict)
                            onClicked: root.plane.callTool("schedule.recurrence.state", {
                                "recurrence_id": String(root.selectedOccurrence.recurrenceId || ""),
                                "state": "active"
                            })
                        }
                    }
                }
            }
        }
    }
}
