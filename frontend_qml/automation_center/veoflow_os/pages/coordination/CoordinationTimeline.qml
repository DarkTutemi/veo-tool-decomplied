pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "coordinationTimeline"
    property var operationModel
    property int modelRevision: 0
    property var laneCounts: ({})
    property int timelineTotal: -1
    property string selectedOperationKey: ""
    property string authoritativeNow: ""
    property int maximumVisiblePerLane: 5
    readonly property double authoritativeNowMs: new Date(
        root.authoritativeNow).getTime()
    readonly property bool hasAuthoritativeClock: root.authoritativeNow.length > 0
        && !isNaN(root.authoritativeNowMs)
    readonly property string clockAuthority: root.hasAuthoritativeClock
        ? "snapshot" : "local"
    property double serverClockOffsetMs: 0
    property date nowDate: new Date()
    signal operationSelected(string operationKey)
    signal operationOpened(string operationKey)

    readonly property double windowStartMs: nowDate.getTime() - 2 * 60 * 60 * 1000
    readonly property double windowSpanMs: 8 * 60 * 60 * 1000
    readonly property double windowEndMs: root.windowStartMs + root.windowSpanMs
    readonly property real layoutAvailableWidth: Math.max(0, root.width - 142)
    readonly property var timelineLayoutMap: root.buildTimelineLayouts(
        root.layoutAvailableWidth)
    readonly property int renderedBlockCount: Number(
        root.timelineLayoutMap.__total || 0)
    readonly property int projectedBlockCount: root.timelineTotal >= 0
        ? root.timelineTotal : root.renderedBlockCount
    readonly property var lanes: [
        {"key": "idea", "label": "Ý tưởng", "tone": Theme.success, "icon": "semantic/lightbulb"},
        {"key": "production", "label": "Sản xuất", "tone": Theme.info, "icon": "semantic/video"},
        {"key": "publish", "label": "Đăng tải", "tone": Theme.accent, "icon": "semantic/upload-cloud"},
        {"key": "care", "label": "Chăm sóc", "tone": Theme.warning, "icon": "semantic/heart"}
    ]

    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    clip: true
    Accessible.name: "Dòng thời gian vận hành"
    Accessible.description: root.projectedBlockCount
        + " operation trong cửa sổ hiển thị"
    Accessible.role: Accessible.Pane

    function isValidTimestamp(value) {
        if (!String(value || ""))
            return false
        return !isNaN(new Date(value).getTime())
    }

    function isActiveState(value) {
        return ["running", "producing", "rendering", "publishing", "caring",
            "in_progress", "queued", "scheduled", "awaiting_approval"
        ].indexOf(String(value || "").toLowerCase()) >= 0
    }

    function isTimelineCandidate(stage, state, startAt, estimatedEndAt) {
        if (!root.isActiveState(state) || !root.isValidTimestamp(startAt)
                || ["idea", "production", "publish", "care"].indexOf(
                    String(stage || "")) < 0)
            return false
        const startMs = new Date(startAt).getTime()
        const endMs = new Date(estimatedEndAt).getTime()
        const hasEnd = root.isValidTimestamp(estimatedEndAt) && endMs > startMs
        return startMs <= root.windowEndMs
            && (!hasEnd || endMs >= root.windowStartMs)
    }

    function countLane(stage) {
        return Number((root.timelineLayoutMap.__counts || ({}))[
            String(stage || "")] || 0)
    }

    function visibleLaneCount(stage) {
        return Number((root.timelineLayoutMap.__visibleCounts || ({}))[
            String(stage || "")] || 0)
    }

    function hiddenLaneCount(stage) {
        return Math.max(0, root.projectedLaneCount(stage) - root.visibleLaneCount(stage))
    }

    function hasTimelineLayout(operationKey) {
        const key = String(operationKey || "")
        return key.length > 0 && root.timelineLayoutMap[key] !== undefined
    }

    function projectedLaneCount(stage) {
        const value = Number((root.laneCounts || ({}))[String(stage || "")])
        return isFinite(value) && value >= 0 ? Math.floor(value) : root.countLane(stage)
    }

    function xForTimestamp(value, availableWidth) {
        const parsed = new Date(value).getTime()
        if (isNaN(parsed) || availableWidth <= 0)
            return 0
        return Math.max(0, Math.min(availableWidth - 12,
            ((parsed - root.windowStartMs) / root.windowSpanMs) * availableWidth))
    }

    function widthForRange(startAt, estimatedEndAt, availableWidth) {
        const start = new Date(startAt).getTime()
        const end = new Date(estimatedEndAt).getTime()
        if (!isNaN(start) && !isNaN(end) && end > start)
            return Math.max(148, Math.min(availableWidth * 0.46,
                ((end - start) / root.windowSpanMs) * availableWidth))
        return Math.max(156, Math.min(210, availableWidth * 0.22))
    }

    function buildTimelineLayouts(availableWidth) {
        const revision = root.modelRevision
        const groups = {"idea": [], "production": [], "publish": [], "care": []}
        const result = {
            "__counts": {"idea": 0, "production": 0, "publish": 0, "care": 0},
            "__visibleCounts": {"idea": 0, "production": 0, "publish": 0, "care": 0},
            "__total": 0
        }
        if (!root.operationModel || availableWidth <= 0)
            return result
        for (let index = 0; index < root.operationModel.count; index++) {
            const item = root.operationModel.get(index)
            const stage = String(item.stage || "")
            if (!root.isTimelineCandidate(stage, item.state_value,
                        item.start_at, item.estimated_end_at))
                continue
            groups[stage].push({
                "key": String(item.operation_key || ""),
                "start": String(item.start_at || ""),
                "end": String(item.estimated_end_at || "")
            })
            result.__counts[stage]++
        }
        const stages = ["idea", "production", "publish", "care"]
        for (let stageIndex = 0; stageIndex < stages.length; stageIndex++) {
            const stage = stages[stageIndex]
            const candidates = groups[stage]
            candidates.sort(function(left, right) {
                const timeDelta = new Date(left.start).getTime()
                    - new Date(right.start).getTime()
                return timeDelta !== 0
                    ? timeDelta : left.key.localeCompare(right.key)
            })
            let visibleCandidates = candidates.slice(0, root.maximumVisiblePerLane)
            if (candidates.length > root.maximumVisiblePerLane
                    && root.selectedOperationKey.length > 0) {
                const selectedIndex = candidates.findIndex(function(candidate) {
                    return candidate.key === root.selectedOperationKey
                })
                if (selectedIndex >= root.maximumVisiblePerLane) {
                    visibleCandidates[root.maximumVisiblePerLane - 1] = candidates[selectedIndex]
                    visibleCandidates.sort(function(left, right) {
                        const timeDelta = new Date(left.start).getTime()
                            - new Date(right.start).getTime()
                        return timeDelta !== 0
                            ? timeDelta : left.key.localeCompare(right.key)
                    })
                }
            }
            result.__visibleCounts[stage] = visibleCandidates.length
            result.__total += visibleCandidates.length
            const overflowReserve = candidates.length > visibleCandidates.length ? 76 : 0
            const stageAvailableWidth = Math.max(96, availableWidth - overflowReserve)
            const gap = 8
            const maximumWidth = Math.max(96,
                (stageAvailableWidth - gap * Math.max(0, visibleCandidates.length - 1))
                    / Math.max(1, visibleCandidates.length))
            const positions = []
            let previousRight = -gap
            for (let index = 0; index < visibleCandidates.length; index++) {
                const candidate = visibleCandidates[index]
                const width = Math.min(maximumWidth,
                    root.widthForRange(candidate.start, candidate.end, stageAvailableWidth))
                const desiredX = root.xForTimestamp(candidate.start, stageAvailableWidth)
                const x = Math.max(desiredX, previousRight + gap)
                positions.push({"key": candidate.key, "x": x, "width": width})
                previousRight = x + width
            }
            if (positions.length > 0 && previousRight > stageAvailableWidth) {
                const overflow = previousRight - stageAvailableWidth
                if (overflow <= positions[0].x) {
                    for (let index = 0; index < positions.length; index++)
                        positions[index].x -= overflow
                } else {
                    let nextX = 0
                    for (let index = 0; index < positions.length; index++) {
                        positions[index].x = nextX
                        nextX += positions[index].width + gap
                    }
                }
            }
            for (let index = 0; index < positions.length; index++) {
                const position = positions[index]
                result[position.key] = position
            }
        }
        return result
    }

    function timelineLayout(operationKey, startAt, estimatedEndAt, availableWidth) {
        return root.timelineLayoutMap[String(operationKey || "")] || {
            "x": root.xForTimestamp(startAt, availableWidth),
            "width": root.widthForRange(startAt, estimatedEndAt, availableWidth)
        }
    }

    function timeLabel(milliseconds) {
        const date = new Date(milliseconds)
        return String(date.getHours()).padStart(2, "0") + ":"
            + String(date.getMinutes()).padStart(2, "0")
    }

    function stageTone(stage) {
        if (stage === "idea") return Theme.success
        if (stage === "production") return Theme.info
        if (stage === "publish") return Theme.accent
        if (stage === "care") return Theme.warning
        return Theme.textFaint
    }

    Timer {
        interval: 30000
        running: root.visible
        repeat: true
        onTriggered: root.nowDate = new Date(Date.now() + root.serverClockOffsetMs)
    }

    function syncAuthoritativeClock() {
        const localNowMs = Date.now()
        const parsedMs = new Date(root.authoritativeNow).getTime()
        if (root.authoritativeNow.length > 0 && !isNaN(parsedMs)) {
            root.serverClockOffsetMs = parsedMs - localNowMs
            root.nowDate = new Date(parsedMs)
            return
        }
        root.serverClockOffsetMs = 0
        root.nowDate = new Date(localNowMs)
    }

    onAuthoritativeNowChanged: root.syncAuthoritativeClock()
    Component.onCompleted: root.syncAuthoritativeClock()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            Item {
                id: timeRuler
                anchors.left: parent.left
                anchors.leftMargin: 132
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                Repeater {
                    model: 9
                    delegate: Item {
                        id: tick
                        required property int index
                        x: tick.index * (parent.width / 8) - (tick.index === 8 ? 34 : 0)
                        width: 68
                        height: parent.height
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 6
                            text: root.timeLabel(root.windowStartMs + tick.index * root.windowSpanMs / 8)
                            color: Theme.textFaint
                            font.pixelSize: 12
                        }
                    }
                }

                Rectangle {
                    objectName: "coordinationNowMarkerLabel"
                    x: Math.max(0, Math.min(timeRuler.width - width,
                        root.xForTimestamp(root.nowDate.toISOString(), timeRuler.width)
                            - width / 2))
                    y: 2
                    width: 92
                    height: 22
                    radius: 7
                    color: Theme.accent
                    z: 2
                    Accessible.name: "Mốc thời gian hiện tại"
                    Accessible.role: Accessible.StaticText
                    Text {
                        anchors.centerIn: parent
                        text: "Hiện tại " + root.timeLabel(root.nowDate.getTime())
                        color: "white"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                }
            }
        }

        Repeater {
            model: root.lanes
            delegate: Rectangle {
                id: lane
                required property var modelData
                required property int index
                objectName: "timelineLane_" + String(lane.modelData.key || "")
                readonly property int projectedCount: root.projectedLaneCount(
                    String(lane.modelData.key || ""))
                readonly property int visibleCount: root.visibleLaneCount(
                    String(lane.modelData.key || ""))
                readonly property int hiddenCount: root.hiddenLaneCount(
                    String(lane.modelData.key || ""))
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 48
                color: lane.index % 2 === 0 ? Qt.rgba(Theme.elevated.r, Theme.elevated.g, Theme.elevated.b, 0.34) : "transparent"
                border.width: 0

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 1
                    color: Theme.borderSoft
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 132
                    anchors.leftMargin: 12
                    spacing: 9
                    Rectangle {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        radius: 8
                        color: Qt.rgba(lane.modelData.tone.r, lane.modelData.tone.g, lane.modelData.tone.b, 0.12)
                        border.width: 1
                        border.color: Qt.rgba(lane.modelData.tone.r, lane.modelData.tone.g, lane.modelData.tone.b, 0.42)
                        UiIcon {
                            anchors.centerIn: parent
                            name: String(lane.modelData.icon || "semantic/workflow")
                            tone: lane.modelData.tone
                            iconSize: 15
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text {
                            text: lane.modelData.label
                            color: Theme.text
                            font.pixelSize: Theme.fontSection
                            font.weight: Font.DemiBold
                        }
                        Text { text: lane.projectedCount + " đang chạy"; color: Theme.textFaint; font.pixelSize: 12 }
                    }
                }

                Item {
                    id: canvas
                    anchors.left: parent.left
                    anchors.leftMargin: 132
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    clip: true

                    Repeater {
                        model: root.operationModel
                        delegate: Loader {
                            id: operationLoader
                            objectName: "timelineLoader_" + operationLoader.operationKey
                            required property string operation_key
                            required property var operation_id
                            required property var operation_kind
                            required property string stage
                            required property var title
                            required property var platform
                            required property var channel_name
                            required property var start_at
                            required property var estimated_end_at
                            required property var eta_source
                            required property var progress_value
                            required property var state_value
                            required property var approval_id
                            required property var blocking_incident_id

                            readonly property string operationKey: String(
                                operationLoader.operation_key || "")
                            readonly property string operationId: String(
                                operationLoader.operation_id || "")
                            readonly property string operationKind: String(
                                operationLoader.operation_kind || "")
                            readonly property string channelName: String(
                                operationLoader.channel_name || "Chưa gán kênh")
                            readonly property string startAt: String(operationLoader.start_at || "")
                            readonly property string estimatedEndAt: String(
                                operationLoader.estimated_end_at || "")
                            readonly property string etaSource: String(
                                operationLoader.eta_source || "")
                            readonly property bool progressKnown: operationLoader.progress_value
                                && operationLoader.progress_value.value !== null
                                && operationLoader.progress_value.value !== undefined
                            readonly property real progressValue: operationLoader.progressKnown
                                ? Number(operationLoader.progress_value.value) : 0
                            readonly property string progressSource: String(
                                (operationLoader.progress_value || {}).source || "")
                            readonly property string operationState: String(
                                operationLoader.state_value || "unknown")
                            readonly property string approvalId: String(
                                operationLoader.approval_id || "")
                            readonly property string blockingIncidentId: String(
                                operationLoader.blocking_incident_id || "")

                            active: operationLoader.stage === lane.modelData.key
                                && root.isTimelineCandidate(
                                    operationLoader.stage,
                                    operationLoader.operationState,
                                    operationLoader.startAt,
                                    operationLoader.estimatedEndAt)
                                && root.hasTimelineLayout(operationLoader.operationKey)
                            asynchronous: false
                            readonly property var timelineGeometry: root.timelineLayout(
                                operationLoader.operationKey,
                                operationLoader.startAt,
                                operationLoader.estimatedEndAt,
                                canvas.width)
                            x: Number(operationLoader.timelineGeometry.x || 0)
                            y: 6
                            width: Math.min(Number(operationLoader.timelineGeometry.width || 96),
                                Math.max(96, canvas.width - x))
                            height: Math.max(34, canvas.height - 12)

                            sourceComponent: Rectangle {
                                id: block
                                objectName: "timelineBlock_" + operationLoader.operationKey
                                readonly property bool etaKnown: root.isValidTimestamp(operationLoader.estimatedEndAt)
                                    && new Date(operationLoader.estimatedEndAt).getTime() > new Date(operationLoader.startAt).getTime()
                                readonly property bool progressKnown: operationLoader.progressKnown
                                readonly property string progressText: progressKnown
                                    ? Math.round(Math.max(0, Math.min(1, operationLoader.progressValue)) * 100) + "%"
                                    : "Không rõ"

                                radius: 7
                                color: blockMouse.containsMouse
                                    ? Qt.rgba(root.stageTone(operationLoader.stage).r,
                                        root.stageTone(operationLoader.stage).g,
                                        root.stageTone(operationLoader.stage).b, 0.24)
                                    : Qt.rgba(root.stageTone(operationLoader.stage).r,
                                        root.stageTone(operationLoader.stage).g,
                                        root.stageTone(operationLoader.stage).b, 0.16)
                                border.width: root.selectedOperationKey === operationLoader.operationKey ? 2 : 1
                                border.color: root.selectedOperationKey === operationLoader.operationKey
                                    ? root.stageTone(operationLoader.stage)
                                    : Qt.rgba(root.stageTone(operationLoader.stage).r,
                                        root.stageTone(operationLoader.stage).g,
                                        root.stageTone(operationLoader.stage).b, 0.45)
                                Behavior on color { ColorAnimation { duration: 120 } }
                                Behavior on border.color { ColorAnimation { duration: 120 } }
                                activeFocusOnTab: true
                                Accessible.name: operationLoader.title + ". "
                                    + (block.progressKnown ? "Tiến độ " + block.progressText : "Tiến độ không rõ")
                                    + (block.etaKnown ? ". Có ETA" : ". Chưa có ETA")
                                Accessible.role: Accessible.Button
                                Keys.onReturnPressed: root.operationOpened(operationLoader.operationKey)
                                Keys.onEnterPressed: root.operationOpened(operationLoader.operationKey)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 9
                                    anchors.rightMargin: 7
                                    anchors.topMargin: 6
                                    anchors.bottomMargin: 6
                                    spacing: 8
                                    SocialIcon {
                                        visible: operationLoader.width >= 112
                                        platform: operationLoader.platform || "generic"
                                        Layout.preferredWidth: 20
                                        Layout.preferredHeight: 20
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        spacing: 2

                                        Text {
                                            objectName: "timelineTitle_" + operationLoader.operationKey
                                            Layout.fillWidth: true
                                            text: operationLoader.title || "Công việc chưa có tiêu đề"
                                            color: Theme.text
                                            font.pixelSize: 12
                                            font.weight: Font.DemiBold
                                            maximumLineCount: 1
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            objectName: "timelineContext_" + operationLoader.operationKey
                                            Layout.fillWidth: true
                                            visible: operationLoader.width >= 132
                                            text: operationLoader.channelName + " · " + block.progressText
                                            color: block.progressKnown ? Theme.textMuted : Theme.warning
                                            font.pixelSize: 11
                                            maximumLineCount: 1
                                            elide: Text.ElideRight
                                        }
                                    }
                                    UiIcon {
                                        visible: !block.etaKnown
                                            && operationLoader.width >= 168
                                        name: "ui/chevron-right"
                                        tone: Theme.textFaint
                                        iconSize: 13
                                    }
                                }

                                Rectangle {
                                    visible: operationLoader.approvalId.length > 0 || operationLoader.blockingIncidentId.length > 0
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: 3
                                    radius: 2
                                    color: operationLoader.blockingIncidentId.length > 0 ? Theme.danger : Theme.warning
                                }

                                MouseArea {
                                    id: blockMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        block.forceActiveFocus()
                                        root.operationSelected(operationLoader.operationKey)
                                    }
                                    onDoubleClicked: root.operationOpened(operationLoader.operationKey)
                                }
                                ToolTip.visible: blockMouse.containsMouse
                                ToolTip.text: "Bắt đầu: " + operationLoader.startAt
                                    + "\nETA: " + (block.etaKnown ? operationLoader.estimatedEndAt : "Không rõ")
                                    + "\nNguồn ETA: " + (operationLoader.etaSource || "Không rõ")
                                    + "\nNguồn tiến độ: " + (operationLoader.progressSource || "Không rõ")
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: root.countLane(lane.modelData.key) === 0
                        text: "Chưa có hoạt động có mốc bắt đầu"
                        color: Theme.textFaint
                        font.pixelSize: 12
                    }

                    Rectangle {
                        objectName: "timelineLaneOverflow_" + String(
                            lane.modelData.key || "")
                        property string text: "+" + lane.hiddenCount + " khác"
                        visible: lane.hiddenCount > 0
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 66
                        height: 28
                        radius: 8
                        color: Qt.rgba(lane.modelData.tone.r,
                            lane.modelData.tone.g, lane.modelData.tone.b, 0.11)
                        border.width: 1
                        border.color: Qt.rgba(lane.modelData.tone.r,
                            lane.modelData.tone.g, lane.modelData.tone.b, 0.34)
                        Accessible.name: lane.hiddenCount
                            + " hoạt động khác trong " + lane.modelData.label
                        Accessible.role: Accessible.StaticText

                        Text {
                            anchors.centerIn: parent
                            text: parent.text
                            color: lane.modelData.tone
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }

                    Rectangle {
                        x: root.xForTimestamp(root.nowDate.toISOString(), canvas.width)
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Theme.accent
                        opacity: 0.75
                    }
                }
            }
        }
    }
}
