import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import VeoFlow

import "../components"
import "../theme"

Rectangle {
    id: root

    // Stable tour target. Baked into the shared component so EVERY tab that embeds
    // a job panel is guided uniformly (the tour resolver picks the visible one).
    objectName: "jobPanel"

    property var rows: []
    property var jobModel: null
    property var stats: ({})
    property string route: ""
    // Screens with a compact drawer keep TWO JobPanelWidget instances. The hidden
    // one still has full geometry (visible does not walk the parent chain), so it
    // would bind the shared model, steal the hot window, and decode every
    // thumbnail a second time. Bind panelActive to the surface that is actually
    // on screen; the pager unhooks and the ListView drops its delegates.
    property bool panelActive: visible
    // Pagination (bound-N): 0 = off → classic scroll over every row (unchanged behavior,
    // what every existing screen gets). >0 = render only this many cards per page + show
    // page controls — lighter, and the generating aurora stays smooth (N stable delegates).
    property int pageSize: 0
    // autoPageSize: fit the page to the visible rail height (≈ how many cards a page holds).
    // jobList.height is parent-driven (Layout.fillHeight), not content-driven → no loop.
    property bool autoPageSize: false
    property int perCardHeight: VfTheme.dp(112)
    readonly property int effectivePageSize: (root.autoPageSize && jobList.height > 0)
        ? Math.max(3, Math.floor(jobList.height / Math.max(1, root.perCardHeight)))
        : root.pageSize
    readonly property bool paginated: root.effectivePageSize > 0 && !!root.jobModel
    readonly property bool usePager: root.panelActive && !!root.jobModel
        && (root.paginated || root.statusFilter.length > 0)
    signal viewRequested(var row)
    signal regenerateRequested(var row)
    signal deleteRequested(var row)
    signal editRequested(var row)
    signal assetRequested(var row, int index)
    signal clearRequested()
    signal retryRequested()
    signal actionRequested(string actionId, var payload)

    property string assetPreviewSource: ""
    property string assetPreviewTitle: ""
    property string statusFilter: ""
    property var computedStats: root.counts()
    readonly property bool queueBusy: (root.computedStats.generating || 0) > 0
    readonly property real progressRatio: {
        var t = root.computedStats.total || 0
        if (t <= 0)
            return 0
        var done = root.computedStats.completed || 0
        var gen = root.computedStats.generating || 0
        return Math.max(0, Math.min(1, (done + gen * 0.5) / t))
    }

    Layout.fillHeight: true
    color: "transparent"
    border.color: "transparent"
    border.width: 0

    function rowId(row) {
        if (!row)
            return ""
        return String(row.id || row.row_id || row.job_id || row.batch_id || "")
    }

    function rowStatus(row) {
        return String((row || {}).status || (row || {}).status_label || (row || {}).state || "").toLowerCase()
    }

    function showAssetPreview(source, title) {
        var resolvedSource = String(source || "").trim()
        if (resolvedSource.length === 0)
            return
        root.assetPreviewSource = resolvedSource
        root.assetPreviewTitle = String(title || "").trim()
        assetPreviewPopup.open()
    }

    function displayRows() {
        if (!root.rows)
            return []
        if (Array.isArray(root.rows))
            return root.rows

        var result = []
        var keys = Object.keys(root.rows)
        for (var i = 0; i < keys.length; i++)
            result.push(root.rows[keys[i]])
        return result
    }

    function counts() {
        var visibleRows = root.displayRows()
        var result = {
            total: visibleRows.length,
            pending: 0,
            queued: 0,
            generating: 0,
            completed: 0,
            failed: 0
        }

        for (var i = 0; i < visibleRows.length; i++) {
            var status = root.rowStatus(visibleRows[i])
            if (status === "queued") {
                result.queued += 1
                result.pending += 1
            } else if (status === "pending" || status === "waiting") {
                result.pending += 1
            } else if (status === "generating" || status === "processing" || status === "polling" || status === "upscaling") {
                result.generating += 1
            } else if (status === "complete" || status === "completed" || status === "done") {
                result.completed += 1
            } else if (status === "failed" || status === "error" || status === "cancelled") {
                result.failed += 1
            }
        }

        if (root.stats) {
            if (root.stats.total !== undefined)
                result.total = Number(root.stats.total) || result.total
            if (root.stats.pending !== undefined)
                result.pending = Number(root.stats.pending) || result.pending
            if (root.stats.queued !== undefined)
                result.queued = Number(root.stats.queued) || result.queued
            if (root.stats.generating !== undefined)
                result.generating = Number(root.stats.generating) || result.generating
            if (root.stats.completed !== undefined)
                result.completed = Number(root.stats.completed) || result.completed
            if (root.stats.failed !== undefined)
                result.failed = Number(root.stats.failed) || result.failed
        }

        return result
    }

    function actionPayload(actionId, jobId, index) {
        var commandJobId = String(jobId || "")
        return {
            action_id: actionId,
            action: String(actionId || "").replace("job_panel.", ""),
            route: root.route,
            job_id: commandJobId,
            row_id: commandJobId,
            slot_index: index
        }
    }

    function commandRow(jobId) {
        var commandJobId = String(jobId || "")
        return commandJobId.length > 0 ? { id: commandJobId, row_id: commandJobId, job_id: commandJobId } : ({})
    }

    function flagState(row, primaryKey, alternateKey, roleValue) {
        var payload = row || ({})
        if (payload[primaryKey] !== undefined)
            return payload[primaryKey] ? 1 : 0
        if (payload[alternateKey] !== undefined)
            return payload[alternateKey] ? 1 : 0
        if (roleValue === undefined || roleValue === null)
            return -1
        return roleValue ? 1 : 0
    }

    // Tri-state from a narrow bool|null role: true→1, false→0, missing→-1. Used for the
    // card action flags so they depend ONLY on their role (no rowValue → no `row` churn).
    function triState(roleValue) {
        if (roleValue === undefined || roleValue === null)
            return -1
        return roleValue ? 1 : 0
    }

    function listCount(value) {
        if (!value || typeof value === "string")
            return 0
        return Number(value.length || 0)
    }

    property bool reviewPending: false

    function canReview() {
        return root.panelActive && !!root.jobModel && typeof root.jobModel.rowCount === "function"
            && root.jobModel.rowCount() > 0
    }

    function openReview() {
        if (!root.canReview())
            return
        root.reviewPending = true
        reviewLoader.active = true
        if (reviewLoader.status === Loader.Ready && reviewLoader.item)
            root._showReview()
    }

    function _showReview() {
        if (!reviewLoader.item)
            return
        root.reviewPending = false
        reviewLoader.item.openFor(root.jobModel, root.route)
    }

    function requestReviewStatus(jobId, status) {
        var payload = root.actionPayload("job_panel.review", jobId, -1)
        payload.review_status = String(status || "")
        root.actionRequested("job_panel.review", payload)
    }

    function requestPanelAction(actionId, jobId, index) {
        var payload = root.actionPayload(actionId, jobId, index)
        var legacyRow = root.commandRow(payload.row_id)
        root.actionRequested(actionId, payload)
        if (actionId === "job_panel.clear") {
            root.clearRequested()
        } else if (actionId === "job_panel.regenerate"
                   || actionId === "job_panel.retry") {
            if (payload.row_id.length > 0)
                root.regenerateRequested(legacyRow)
            else
                root.retryRequested()
        } else if (actionId === "job_panel.view") {
            root.viewRequested(legacyRow)
        } else if (actionId === "job_panel.delete") {
            root.deleteRequested(legacyRow)
        } else if (actionId === "job_panel.edit") {
            root.editRequested(legacyRow)
        } else if (actionId === "job_panel.asset") {
            root.assetRequested(legacyRow, index)
        }
    }

    function statsText() {
        var total = root.computedStats.total || 0
        if (total <= 0)
            return (void i18n.revision, i18n.t("job_panel.no_jobs", "No jobs"))
        var noun = root.route === "batch"
            ? (void i18n.revision, i18n.t("job_panel.images_label", "Images"))
            : (void i18n.revision, i18n.t("job_panel.videos_label", "Videos"))

        var parts = []
        if ((root.computedStats.queued || 0) > 0)
            parts.push((void i18n.revision, i18n.t("job_panel.status_queued", "Queued")) + " " + String(root.computedStats.queued))
        if ((root.computedStats.generating || 0) > 0)
            parts.push((void i18n.revision, i18n.t("job_panel.status_generating", "Generating")) + " " + String(root.computedStats.generating))
        if ((root.computedStats.completed || 0) > 0)
            parts.push((void i18n.revision, i18n.t("job_panel.status_completed", "Completed")) + " " + String(root.computedStats.completed))
        if ((root.computedStats.failed || 0) > 0)
            parts.push((void i18n.revision, i18n.t("job_panel.status_failed", "Failed")) + " " + String(root.computedStats.failed))

        if (parts.length > 0)
            return "{noun}: {total} ({details})"
                .replace("{noun}", noun)
                .replace("{total}", String(total))
                .replace("{details}", parts.join(" / "))
        return "{noun}: {count}"
            .replace("{noun}", noun)
            .replace("{count}", String(total))
    }

    component HeaderPanelButton: Rectangle {
        id: headerButton

        property string text: ""
        property string actionId: ""
        property bool emphasis: false
        signal clicked()

        Layout.preferredWidth: Math.max(58, headerLabel.implicitWidth + 24)
        Layout.preferredHeight: VfTheme.dp(24)
        radius: VfTheme.dp(6)
        color: emphasis ? (mouse.containsMouse ? VfTheme.indigoFill : VfTheme.violetFill) : (mouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface)
        border.color: emphasis ? (mouse.containsMouse ? "#4F46E5" : "#6366F1") : (mouse.containsMouse ? VfTheme.borderStrong : VfTheme.border)
        border.width: 1

        function cleanText(value) {
            var label = String(value || "").trim()
            label = label.replace(/^[\uD800-\uDBFF][\uDC00-\uDFFF]\uFE0F?\s*/, "")
            label = label.replace(/^[\u2600-\u27BF]\uFE0F?\s*/, "")
            return label.trim()
        }

        Text {
            id: headerLabel
            anchors.centerIn: parent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: VfTheme.dp(8)
            anchors.rightMargin: VfTheme.dp(8)
            text: headerButton.cleanText(headerButton.text)
            color: headerButton.emphasis ? "#6366F1" : VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
            font.weight: headerButton.emphasis ? Font.Bold : Font.Medium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: headerButton.clicked()
        }
    }

    // Status count chip: colored dot + "Label N". Pulses when `pulse` (in-flight).
    component StatPill: Item {
        id: pill
        property string label: ""
        property int count: 0
        property color accent: VfTheme.textSubtle
        property bool pulse: false
        property bool selected: false
        property bool toggleable: false
        signal clicked()
        visible: pill.count > 0 || pill.selected
        implicitWidth: pillRow.implicitWidth
        implicitHeight: pillRow.implicitHeight

        Row {
            id: pillRow
            spacing: VfTheme.dp(5)

            Rectangle {
                width: VfTheme.dp(7)
                height: VfTheme.dp(7)
                radius: width / 2
                anchors.verticalCenter: parent.verticalCenter
                color: pill.accent
                SequentialAnimation on opacity {
                    running: pill.pulse && VfTheme.motion
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.3; duration: 720; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.3; to: 1.0; duration: 720; easing.type: Easing.InOutSine }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: pill.label + " " + pill.count
                color: pill.selected ? pill.accent : VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: pill.selected ? VfTheme.weightStrong : VfTheme.weightControl
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: pill.toggleable
            hoverEnabled: pill.toggleable
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            ToolTip.visible: pill.toggleable && containsMouse
            ToolTip.text: (void i18n.revision, i18n.t("job_panel.toggle_filter_tooltip", "Toggle: ALL / FAILED only"))
            onClicked: pill.clicked()
        }
    }

    // Live activity indicator: solid dot + expanding pulse ring while busy.
    // Blue = generating, green = has jobs/idle, grey = empty.
    component ActivityDot: Item {
        id: activityDot
        property bool busy: false
        property bool hasJobs: false
        readonly property color dotColor: activityDot.busy ? VfTheme.primary
                                                           : (activityDot.hasJobs ? VfTheme.greenBorder : VfTheme.textSubtle)
        implicitWidth: VfTheme.dp(14)
        implicitHeight: VfTheme.dp(14)

        Rectangle {
            anchors.centerIn: parent
            width: VfTheme.dp(10)
            height: width
            radius: width / 2
            color: "transparent"
            border.width: Math.max(1, VfTheme.dp(1.5))
            border.color: activityDot.dotColor
            visible: activityDot.busy
            SequentialAnimation on scale {
                running: activityDot.busy && VfTheme.motion
                loops: Animation.Infinite
                NumberAnimation { from: 0.7; to: 2.0; duration: 1500; easing.type: Easing.OutCubic }
                PauseAnimation { duration: 80 }
            }
            SequentialAnimation on opacity {
                running: activityDot.busy && VfTheme.motion
                loops: Animation.Infinite
                NumberAnimation { from: 0.5; to: 0.0; duration: 1500; easing.type: Easing.OutCubic }
                PauseAnimation { duration: 80 }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: VfTheme.dp(8)
            height: width
            radius: width / 2
            color: activityDot.dotColor
        }
    }

    // Bound-N page window over the shared job model. pageSize 0 ⇒ pass-through; the
    // ListView only binds to this when paginated, so non-paginated screens never touch it.
    JobPanelPageProxy {
        id: pager
        // Inert (no source wiring) unless this panel actually paginates → zero cost for
        // the screens that bind the model directly. Also inert when panelActive is
        // false so a hidden drawer instance cannot steal the source hot window.
        sourceModel: root.usePager ? root.jobModel : null
        pageSize: root.panelActive ? root.effectivePageSize : 0
        statusFilter: root.statusFilter
    }

    // Compact ‹ / › page navigation button.
    component PageNavButton: Rectangle {
        id: navBtn
        property string text: ""
        signal clicked()
        Layout.preferredWidth: VfTheme.dp(30)
        Layout.preferredHeight: VfTheme.dp(22)
        radius: VfTheme.dp(6)
        color: navMouse.containsMouse && navBtn.enabled ? VfTheme.surfaceSoft : VfTheme.surface
        border.color: navBtn.enabled ? VfTheme.border : VfTheme.border
        border.width: 1
        opacity: navBtn.enabled ? 1.0 : 0.4
        Text {
            anchors.centerIn: parent
            text: navBtn.text
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(14)
            font.weight: Font.Bold
        }
        MouseArea {
            id: navMouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: navBtn.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: navBtn.clicked()
        }
    }

    Loader {
        id: reviewLoader
        active: false
        asynchronous: true
        source: Qt.resolvedUrl("../dialogs/SceneReviewDialog.qml")
        onLoaded: {
            if (!item)
                return
            item.reviewStatusRequested.connect(function(jobId, status) {
                root.requestReviewStatus(jobId, status)
            })
            item.editRequested.connect(function(jobId) {
                root.requestPanelAction("job_panel.edit", jobId, -1)
            })
            item.regenerateRequested.connect(function(jobId) {
                root.requestPanelAction("job_panel.regenerate", jobId, -1)
            })
            item.openOutputRequested.connect(function(jobId) {
                root.requestPanelAction("job_panel.view", jobId, -1)
            })
            item.assetReplaceRequested.connect(function(jobId, slotIndex) {
                root.requestPanelAction("job_panel.asset", jobId, slotIndex)
            })
            item.closed.connect(function() {
                reviewLoader.active = false
            })
            if (root.reviewPending)
                root._showReview()
        }
        onStatusChanged: {
            if (status === Loader.Ready && root.reviewPending)
                root._showReview()
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(4)
        radius: VfTheme.dp(10)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.border
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(10)
            anchors.rightMargin: VfTheme.dp(10)
            anchors.topMargin: VfTheme.dp(8)
            anchors.bottomMargin: VfTheme.dp(10)
            spacing: VfTheme.dp(6)

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(30)
                spacing: VfTheme.dp(8)

                ActivityDot {
                    Layout.alignment: Qt.AlignVCenter
                    busy: root.queueBusy
                    hasJobs: (root.computedStats.total || 0) > 0
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("job_panel.active_panel", "Active Panel"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        font.weight: VfTheme.weightStrong
                        font.letterSpacing: 0.6
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: text.length > 0
                        text: root.queueBusy
                            ? ((void i18n.revision, i18n.t("job_panel.status_generating", "Generating")) + " · " + String(root.computedStats.generating || 0))
                            : ((root.computedStats.total || 0) > 0
                                ? (void i18n.revision, i18n.t("job_panel.status_idle", "Idle"))
                                : "")
                        color: root.queueBusy ? VfTheme.primary : VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(9)
                        font.weight: VfTheme.weightControl
                        elide: Text.ElideRight
                    }
                }

                HeaderPanelButton {
                    Layout.alignment: Qt.AlignVCenter
                    actionId: "job_panel.review"
                    text: (void i18n.revision, i18n.t("job_panel.review_btn", "Review"))
                    enabled: root.panelActive && !!root.jobModel && (root.computedStats.total || 0) > 0
                    onClicked: root.openReview()
                }

                HeaderPanelButton {
                    Layout.alignment: Qt.AlignVCenter
                    actionId: "job_panel.clear"
                    text: (void i18n.revision, i18n.t("job_panel.clear_btn", "Clear"))
                    onClicked: root.requestPanelAction(actionId, "", -1)
                }

                HeaderPanelButton {
                    Layout.alignment: Qt.AlignVCenter
                    actionId: "job_panel.retry"
                    text: (void i18n.revision, i18n.t("job_panel.retry_btn", "Retry"))
                    emphasis: true
                    onClicked: root.requestPanelAction(actionId, "", -1)
                }
            }

            // Aggregate progress: completed (+ half of in-flight) over total.
            // Gradient fill animates; a shimmer sweeps while the queue is working.
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(5)
                radius: height / 2
                color: VfTheme.border
                visible: (root.computedStats.total || 0) > 0
                clip: true

                Rectangle {
                    id: aggregateFill
                    height: parent.height
                    width: parent.width * root.progressRatio
                    radius: height / 2
                    Behavior on width { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: VfTheme.primary }
                        GradientStop { position: 1.0; color: VfTheme.greenBorder }
                    }

                    Rectangle {
                        id: aggregateShimmer
                        width: VfTheme.dp(40)
                        height: parent.height
                        visible: root.queueBusy && aggregateFill.width > width
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.45) }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                        SequentialAnimation on x {
                            running: aggregateShimmer.visible && VfTheme.motion
                            loops: Animation.Infinite
                            NumberAnimation { from: -aggregateShimmer.width; to: aggregateFill.width; duration: 1300; easing.type: Easing.InOutSine }
                            PauseAnimation { duration: 500 }
                        }
                    }
                }
            }

            ListView {
                id: jobList
                objectName: "debugJobPanelListView"
                readonly property bool lightweightDelegates: false
                property double progressTick: 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                reuseItems: true
                cacheBuffer: Math.min(height, VfTheme.dp(480))
                spacing: VfTheme.dp(5)
                model: !root.panelActive ? 0 : (root.usePager ? pager : (root.jobModel ? root.jobModel : (root.rows || [])))

                Timer {
                    interval: 1000
                    repeat: true
                    running: jobList.count > 0
                    onTriggered: jobList.progressTick = Date.now()
                }

                delegate: Item {
                    id: cardLoader

                    width: jobList.width
                    // Whole-number delegate size (Qt perf rec) — avoids sub-pixel
                    // alignment of items, which softens/jitters text + edges on scroll.
                    height: Math.round(fullCard.implicitHeight)

                    property var rowValue: model.row || modelData || ({})

                    // Pause the card's animations while it's pooled off-viewport (reuseItems),
                    // so off-screen generating cards don't burn GUI-thread animation time during
                    // a long NON-paginated scroll. (On a paginated panel nothing pools — all N
                    // cards stay visible — so this stays false there and is a no-op.)
                    property bool pooled: false
                    ListView.onPooled: cardLoader.pooled = true
                    ListView.onReused: cardLoader.pooled = false

                    JobCardWidget {
                        id: fullCard
                        width: cardLoader.width
                        row: cardLoader.rowValue
                        progressTick: fullCard.isGeneratingState ? jobList.progressTick : 0
                        jobId: String(model.jobId || "")
                        modelKind: String(model.kind || "")
                        modelTitle: String(model.title || "")
                        modelSubtitle: String(model.subtitle || "")
                        modelStatus: String(model.status || "")
                        modelStatusText: String(model.statusText || "")
                        modelStatusChipText: String(model.statusChipText || "")
                        modelProgress: model.progress === undefined ? -1 : Number(model.progress)
                        // model.thumbnailUrl is a role on the QAbstractListModel; for a
                        // plain JS ARRAY feed (tour demo) that role is undefined, so fall
                        // back to the row object (modelData) — and referencing modelData
                        // makes the binding re-evaluate per item on reuseItems recycle.
                        modelThumbnailUrl: String(model.thumbnailUrl || (modelData ? modelData.thumbnailUrl : "") || "")
                        modelThumbnailPlaceholder: String(model.thumbnailPlaceholder || "")
                        modelAssetPreviews: model.assetPreviews || []
                        modelAssetSlots: model.assetSlots || []
                        modelAspectRatio: String(model.aspectRatio || "")
                        modelVideoPath: String(model.videoPath || "")
                        modelMediaId: String(model.mediaId || "")
                        modelSourceMediaId: String(model.sourceMediaId || "")
                        modelSourceMediaName: String(model.sourceMediaName || "")
                        modelCurrentResolution: String(model.currentResolution || "")
                        modelOutputPath: String(model.outputPath || "")
                        modelOutputFolder: String(model.outputFolder || "")
                        modelTierMode: String(model.tierMode || "")
                        modelAccountName: String(model.accountName || "")
                        modelAccountEmail: String(model.accountEmail || "")
                        // Read action flags from the NARROW roles only (not rowValue) so a
                        // status change repaints them WITHOUT re-emitting the heavy `row` var.
                        modelCanRetry: root.triState(model.canRetry)
                        modelCanUpscale: root.triState(model.canUpscale)
                        modelCanEdit: root.triState(model.canEdit)
                        modelCanDelete: root.triState(model.canDelete)
                        sequenceNumber: Number(model.sequenceNumber || (index + 1))
                        lightweightMode: false
                        animationsEnabled: !cardLoader.pooled
                        onAssetPreviewRequested: (source, title) => root.showAssetPreview(source, title)
                        onActionRequested: (actionId, jobId, index) => root.requestPanelAction(actionId, jobId, index)
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(22)
                visible: root.statusFilter === "failed" && jobList.count <= 0
                text: (void i18n.revision, i18n.t("job_panel.failed_empty", "No failed jobs."))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                horizontalAlignment: Text.AlignHCenter
            }

            // Page navigation — only when paginating and there is more than one page.
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(24)
                visible: root.paginated && pager.pageCount > 1
                spacing: VfTheme.dp(8)

                Item { Layout.fillWidth: true }

                PageNavButton {
                    text: "‹"
                    enabled: pager.activePage > 0
                    onClicked: pager.prevPage()
                }
                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: (void i18n.revision, i18n.t("job_panel.page_label", "Page")) + " " + (pager.activePage + 1) + " / " + pager.pageCount
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    font.weight: VfTheme.weightStrong
                }
                PageNavButton {
                    text: "›"
                    enabled: pager.activePage < pager.pageCount - 1
                    onClicked: pager.nextPage()
                }

                Item { Layout.fillWidth: true }

                // ● Live — following ON: a passive pulsing indicator (the page auto-tracks the
                // generating frontier as pages complete). User paged away (following OFF): a
                // clickable CTA back to where jobs are generating.
                Rectangle {
                    Layout.preferredHeight: VfTheme.dp(22)
                    Layout.preferredWidth: liveRow.implicitWidth + VfTheme.dp(14)
                    radius: VfTheme.dp(11)
                    color: pager.following ? "transparent" : Qt.rgba(0.13, 0.70, 0.40, 0.16)
                    border.color: VfTheme.greenBorder
                    border.width: 1
                    opacity: pager.following ? 0.6 : 1.0

                    Row {
                        id: liveRow
                        anchors.centerIn: parent
                        spacing: VfTheme.dp(5)
                        Rectangle {
                            width: VfTheme.dp(7); height: VfTheme.dp(7); radius: width / 2
                            anchors.verticalCenter: parent.verticalCenter
                            color: VfTheme.greenBorder
                            SequentialAnimation on opacity {
                                running: pager.following && VfTheme.motion
                                loops: Animation.Infinite
                                NumberAnimation { from: 1.0; to: 0.3; duration: 700; easing.type: Easing.InOutSine }
                                NumberAnimation { from: 0.3; to: 1.0; duration: 700; easing.type: Easing.InOutSine }
                            }
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: (void i18n.revision, i18n.t("job_panel.live", "Live"))
                            color: VfTheme.greenBorder
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            font.weight: VfTheme.weightControl
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: !pager.following
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pager.goLive()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(20)
                spacing: VfTheme.dp(12)

                Text {
                    text: {
                        var total = root.computedStats.total || 0
                        var noun = root.route === "batch"
                            ? (void i18n.revision, i18n.t("job_panel.images_label", "Images"))
                            : (void i18n.revision, i18n.t("job_panel.videos_label", "Videos"))
                        return total > 0 ? (noun + " · " + String(total))
                                         : (void i18n.revision, i18n.t("job_panel.no_jobs", "No jobs"))
                    }
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    font.weight: VfTheme.weightControl
                    elide: Text.ElideRight
                }

                Item { Layout.fillWidth: true }

                StatPill {
                    label: (void i18n.revision, i18n.t("job_panel.status_queued", "Queued"))
                    count: root.computedStats.queued || 0
                    accent: VfTheme.textSubtle
                }
                StatPill {
                    label: (void i18n.revision, i18n.t("job_panel.status_generating", "Generating"))
                    count: root.computedStats.generating || 0
                    accent: VfTheme.primary
                    pulse: true
                }
                StatPill {
                    label: (void i18n.revision, i18n.t("job_panel.status_completed", "Completed"))
                    count: root.computedStats.completed || 0
                    accent: VfTheme.greenBorder
                }
                StatPill {
                    label: (void i18n.revision, i18n.t("job_panel.status_failed", "Failed"))
                    count: root.computedStats.failed || 0
                    accent: VfTheme.redBorder
                    toggleable: true
                    selected: root.statusFilter === "failed"
                    onClicked: root.statusFilter = (root.statusFilter === "failed" ? "" : "failed")
                }
            }
        }
    }

    Popup {
        id: assetPreviewPopup
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min((parent ? parent.width : VfTheme.dp(1280)) * 0.84, VfTheme.dp(1180))
        height: Math.min((parent ? parent.height : VfTheme.dp(800)) * 0.88, VfTheme.dp(820))
        modal: true
        dim: true
        padding: VfTheme.dp(12)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        onClosed: {
            root.assetPreviewSource = ""
            root.assetPreviewTitle = ""
        }

        background: Rectangle {
            color: VfTheme.surface
            radius: VfTheme.dp(12)
            border.color: VfTheme.borderStrong
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(10)

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(30)
                spacing: VfTheme.dp(8)

                Text {
                    Layout.fillWidth: true
                    text: root.assetPreviewTitle.length > 0
                        ? root.assetPreviewTitle
                        : (void i18n.revision, i18n.t("job_panel.asset_preview", "Asset preview"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideMiddle
                    maximumLineCount: 1
                }

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(30)
                    Layout.preferredHeight: VfTheme.dp(30)
                    radius: VfTheme.dp(7)
                    color: closePreviewMouse.containsMouse ? VfTheme.surfaceSoft : "transparent"
                    border.color: VfTheme.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: closePreviewMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: assetPreviewPopup.close()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(8)
                color: "#101216"
                clip: true

                BusyIndicator {
                    anchors.centerIn: parent
                    running: assetPreviewImage.status === Image.Loading
                    visible: running
                }

                Image {
                    id: assetPreviewImage
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    source: root.assetPreviewSource
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: true
                    sourceSize.width: Math.min(width, VfTheme.dp(1920))
                    sourceSize.height: Math.min(height, VfTheme.dp(1440))
                }

                Text {
                    anchors.centerIn: parent
                    visible: assetPreviewImage.status === Image.Error
                    text: (void i18n.revision, i18n.t("job_panel.asset_preview_failed", "Không thể tải ảnh xem trước."))
                    color: "#FFFFFF"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                }
            }
        }
    }
}
