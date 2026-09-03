import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property var jobModel: null
    property string route: ""
    property int currentIndex: 0
    property string filterId: "all"
    property var current: ({})
    property var assetSlots: []
    property bool playerFailed: false
    property bool playerMuted: false
    property int countUnseen: 0
    property int countPass: 0
    property int countFlagged: 0
    property int countRegen: 0
    property int countFailed: 0

    signal reviewStatusRequested(string jobId, string status)
    signal editRequested(string jobId)
    signal regenerateRequested(string jobId)
    signal openOutputRequested(string jobId)
    signal assetReplaceRequested(string jobId, int slotIndex)

    parent: Overlay.overlay
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape
    width: VfDialogMetrics.width(parent, VfTheme.dp(1100), VfTheme.dp(32))
    height: VfDialogMetrics.height(parent, VfTheme.dp(760), VfTheme.dp(32))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("job_panel.review_title", "Scene review"))
        subtitle: root.headerSubtitle()
        iconName: "framed-picture"
        onCloseClicked: root.close()
    }

    onClosed: {
        root.releasePlayer()
        root.playerFailed = false
    }

    Timer {
        id: countTimer
        interval: 250
        repeat: false
        onTriggered: root.refreshCounts()
    }

    function openFor(model, routeName) {
        root.jobModel = model
        root.route = String(routeName || "")
        root.filterId = "all"
        root.currentIndex = root.firstMatching(0, 1)
        root.refreshCounts()
        root.open()
        root.reloadCurrent()
        root.forceActiveFocus()
    }

    function modelCount() {
        if (!root.jobModel || !root.jobModel.rowCount)
            return 0
        return Number(root.jobModel.rowCount())
    }

    function payloadAt(index) {
        if (!root.jobModel || !root.jobModel.reviewPayloadAt)
            return ({})
        return root.jobModel.reviewPayloadAt(index) || ({})
    }

    function reloadCurrent() {
        root.current = root.payloadAt(root.currentIndex)
        root.playerFailed = false
        root.reloadAssetSlots()
        root.syncPlayer()
    }

    function reloadAssetSlots() {
        var jobId = root.currentJobId()
        if (jobId.length > 0 && root.jobModel && root.jobModel.assetSlotsForJob)
            root.assetSlots = root.jobModel.assetSlotsForJob(jobId) || []
        else
            root.assetSlots = []
    }

    function assetPreview(slot) {
        if (!slot)
            return ""
        var raw = String(slot.previewSrc || slot.preview_src || slot.path || "")
        if (raw.length === 0 && slot.asset)
            raw = String(slot.asset.previewSrc || slot.asset.path || "")
        if (raw.length === 0)
            return ""
        return root.toUrl(raw)
    }

    function slotIsCharacter(slot) {
        if (!slot)
            return false
        var typeName = String(slot.slotType || slot.asset_type || slot.type || "")
        if (typeName.toLowerCase() === "character")
            return true
        var asset = slot.asset || ({})
        var id = String(slot.id || asset.id || "")
        return id.toUpperCase().indexOf("CHAR_") === 0
    }

    function requestAssetReplace(slotIndex) {
        var jobId = root.currentJobId()
        if (jobId.length > 0)
            root.assetReplaceRequested(jobId, Number(slotIndex))
    }

    function releasePlayer() {
        if (playerLoader.item)
            playerLoader.item.teardown()
        playerLoader.active = false
    }

    function syncPlayer() {
        if (root.isVideo() && root.visible) {
            if (!playerLoader.active) {
                playerLoader.active = true
                return
            }
            if (playerLoader.item)
                playerLoader.item.bindSource(root.videoUrl())
            return
        }
        root.releasePlayer()
    }

    function headerSubtitle() {
        var total = root.modelCount()
        if (total <= 0)
            return ""
        return (root.currentIndex + 1) + " / " + total
            + " · "
            + (void i18n.revision, i18n.t("job_panel.review_pass", "Pass")) + " " + root.countPass
            + " · "
            + (void i18n.revision, i18n.t("job_panel.review_flagged", "Flagged")) + " " + root.countFlagged
    }

    function refreshCounts() {
        var unseen = 0
        var pass = 0
        var flagged = 0
        var regen = 0
        var failed = 0
        var total = root.modelCount()
        for (var i = 0; i < total; i++) {
            if (root.matchesFilterAt(i, "unseen"))
                unseen += 1
            if (root.matchesFilterAt(i, "pass"))
                pass += 1
            if (root.matchesFilterAt(i, "flagged"))
                flagged += 1
            if (root.matchesFilterAt(i, "regen"))
                regen += 1
            if (root.matchesFilterAt(i, "failed"))
                failed += 1
        }
        root.countUnseen = unseen
        root.countPass = pass
        root.countFlagged = flagged
        root.countRegen = regen
        root.countFailed = failed
    }

    function matchesFilterAt(index, kind) {
        var p = root.payloadAt(index)
        var rs = String(p.reviewStatus || "unseen")
        var st = String(p.status || "").toLowerCase()
        var live = st.indexOf("generat") >= 0 || st === "polling" || st === "queued"
            || st === "upscaling" || st === "pending" || st === "waiting"
        if (kind === "all")
            return true
        if (kind === "unseen")
            return rs === "unseen" && !live
        if (kind === "pass")
            return rs === "pass"
        if (kind === "flagged")
            return rs === "flagged"
        if (kind === "regen")
            return live
        if (kind === "failed")
            return st === "failed" || st === "error" || st === "cancelled" || st === "canceled"
        return true
    }

    function firstMatching(start, step) {
        var total = root.modelCount()
        if (total <= 0)
            return 0
        var i = start
        for (var n = 0; n < total; n++) {
            var idx = ((i % total) + total) % total
            if (root.matchesFilterAt(idx, root.filterId))
                return idx
            i += step
        }
        return Math.max(0, Math.min(start, total - 1))
    }

    function goRelative(step) {
        var total = root.modelCount()
        if (total <= 0)
            return
        root.currentIndex = root.firstMatching(root.currentIndex + step, step)
        root.reloadCurrent()
        strip.positionViewAtIndex(root.currentIndex, ListView.Center)
    }

    function currentJobId() {
        return String((root.current && root.current.jobId) || "")
    }

    function isVideo() {
        if (String((root.current && root.current.kind) || "") === "IMG")
            return false
        return String((root.current && root.current.videoPath) || "").length > 0
    }

    function previewUrl() {
        var p = root.current || ({})
        var raw = String(p.thumbnailUrl || p.outputPath || p.videoPath || "")
        return root.toUrl(raw)
    }

    function videoUrl() {
        return root.toUrl(String((root.current && root.current.videoPath) || ""))
    }

    function toUrl(path) {
        var raw = String(path || "").trim()
        if (raw.length === 0)
            return ""
        if (raw.indexOf("file:") === 0 || raw.indexOf("qrc:") === 0
                || raw.indexOf("image://") === 0 || raw.indexOf("data:") === 0
                || raw.indexOf("http://") === 0 || raw.indexOf("https://") === 0)
            return raw
        return encodeURI("file:///" + raw.replace(/\\/g, "/"))
    }

    function markAndMaybeNext(status, goNext) {
        var jobId = root.currentJobId()
        if (jobId.length === 0)
            return
        root.reviewStatusRequested(jobId, status)
        if (goNext)
            root.goRelative(1)
        else
            root.reloadCurrent()
        root.refreshCounts()
    }

    function markPassNext() { root.markAndMaybeNext("pass", true) }
    function markFlag() { root.markAndMaybeNext("flagged", false) }
    function skipNext() { root.goRelative(1) }
    function goPrev() { root.goRelative(-1) }

    function requestEdit() {
        var jobId = root.currentJobId()
        if (jobId.length > 0)
            root.editRequested(jobId)
    }

    function requestRegen() {
        var jobId = root.currentJobId()
        if (jobId.length > 0)
            root.regenerateRequested(jobId)
    }

    function requestOpen() {
        var jobId = root.currentJobId()
        if (jobId.length > 0)
            root.openOutputRequested(jobId)
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Right && (event.modifiers & Qt.ShiftModifier)) {
            root.skipNext(); event.accepted = true
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
            root.markPassNext(); event.accepted = true
        } else if (event.key === Qt.Key_Left) {
            root.goPrev(); event.accepted = true
        } else if (event.key === Qt.Key_F) {
            root.markFlag(); event.accepted = true
        } else if (event.key === Qt.Key_E) {
            root.requestEdit(); event.accepted = true
        } else if (event.key === Qt.Key_R) {
            root.requestRegen(); event.accepted = true
        } else if (event.key === Qt.Key_Space) {
            if (root.isVideo())
                root.requestOpen()
            event.accepted = true
        }
    }

    Connections {
        target: root.jobModel
        function onDataChanged() {
            root.reloadCurrent()
            countTimer.restart()
        }
        function onModelReset() {
            if (root.currentIndex >= root.modelCount())
                root.currentIndex = Math.max(0, root.modelCount() - 1)
            root.reloadCurrent()
            countTimer.restart()
        }
    }

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.dp(12)
        border.color: VfTheme.border
        border.width: 1
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(12)
        spacing: VfTheme.dp(10)

        Row {
            Layout.fillWidth: true
            spacing: VfTheme.dp(6)
            Repeater {
                model: [
                    { id: "all", label: (void i18n.revision, i18n.t("job_panel.review_filter_all", "All")) },
                    { id: "unseen", label: (void i18n.revision, i18n.t("job_panel.review_filter_unseen", "Unseen")) },
                    { id: "pass", label: (void i18n.revision, i18n.t("job_panel.review_pass", "Pass")) },
                    { id: "flagged", label: (void i18n.revision, i18n.t("job_panel.review_flagged", "Flagged")) },
                    { id: "regen", label: (void i18n.revision, i18n.t("job_panel.review_filter_regen", "Regen")) },
                    { id: "failed", label: (void i18n.revision, i18n.t("job_panel.status_failed", "Failed")) }
                ]
                VfChip {
                    required property var modelData
                    text: modelData.label + (modelData.id === "all" ? ""
                          : (modelData.id === "unseen" ? (" " + root.countUnseen)
                          : (modelData.id === "pass" ? (" " + root.countPass)
                          : (modelData.id === "flagged" ? (" " + root.countFlagged)
                          : (modelData.id === "failed" ? (" " + root.countFailed)
                          : (" " + root.countRegen))))))
                    selected: root.filterId === modelData.id
                    minWidth: VfTheme.dp(64)
                    showLeadingIcon: false
                    onClicked: {
                        root.filterId = modelData.id
                        root.currentIndex = root.firstMatching(root.currentIndex, 1)
                        root.reloadCurrent()
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: VfTheme.dp(12)

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(10)
                color: VfTheme.canvas
                border.color: VfTheme.border
                clip: true

                Image {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    visible: !playerLoader.active || root.playerFailed
                    source: root.previewUrl()
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: true
                    sourceSize.width: Math.ceil(width)
                    sourceSize.height: Math.ceil(height)
                }

                Loader {
                    id: playerLoader
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    active: false
                    asynchronous: false
                    source: Qt.resolvedUrl("SceneReviewPlayer.qml")
                    onLoaded: {
                        if (item) {
                            item.failed.connect(function() { root.playerFailed = true })
                            item.muted = root.playerMuted
                            item.bindSource(root.videoUrl())
                        }
                    }
                    onStatusChanged: {
                        if (status === Loader.Error)
                            root.playerFailed = true
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: String(root.previewUrl() || "").length === 0 && !playerLoader.active
                    text: (void i18n.revision, i18n.t("job_panel.review_no_preview", "No preview yet"))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                }

                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: root.requestOpen()
                }

                VfChip {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: VfTheme.dp(10)
                    z: 2
                    visible: playerLoader.active && !root.playerFailed
                    text: root.playerMuted
                          ? (void i18n.revision, i18n.t("job_panel.review_unmute", "Unmute"))
                          : (void i18n.revision, i18n.t("job_panel.review_mute", "Mute"))
                    selected: !root.playerMuted
                    minWidth: VfTheme.dp(72)
                    showLeadingIcon: false
                    onClicked: {
                        root.playerMuted = !root.playerMuted
                        if (playerLoader.item)
                            playerLoader.item.muted = root.playerMuted
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(300)
                Layout.fillHeight: true
                radius: VfTheme.dp(10)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(12)
                    spacing: VfTheme.dp(8)

                    Text {
                        Layout.fillWidth: true
                        text: String((root.current && root.current.title) || root.currentJobId() || "")
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                        font.weight: Font.DemiBold
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.badgeText()
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: root.assetSlots && root.assetSlots.length > 0
                        text: (void i18n.revision, i18n.t("job_panel.edit_assets_hint", "Replace objects or characters. Voice-locked CHAR must pick a library character that already has voice sync."))
                        color: VfTheme.textMuted
                        wrapMode: Text.Wrap
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                    }

                    Row {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)
                        visible: root.assetSlots && root.assetSlots.length > 0
                        Repeater {
                            model: root.assetSlots
                            Rectangle {
                                id: reviewSlot
                                required property var modelData
                                required property int index
                                width: VfTheme.dp(48)
                                height: VfTheme.dp(48)
                                radius: VfTheme.dp(8)
                                color: VfTheme.canvas
                                border.color: VfTheme.border
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    source: root.assetPreview(reviewSlot.modelData)
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.margins: VfTheme.dp(2)
                                    width: VfTheme.dp(14)
                                    height: VfTheme.dp(14)
                                    radius: VfTheme.dp(3)
                                    color: VfTheme.surface
                                    opacity: 0.92
                                    Text {
                                        anchors.centerIn: parent
                                        text: root.slotIsCharacter(reviewSlot.modelData) ? "👤" : "📦"
                                        font.pixelSize: VfTheme.dp(8)
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: Boolean(reviewSlot.modelData && reviewSlot.modelData.filled)
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: root.requestAssetReplace(reviewSlot.index)
                                }
                            }
                        }
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentWidth: width
                        contentHeight: promptLabel.implicitHeight
                        boundsBehavior: Flickable.StopAtBounds

                        Text {
                            id: promptLabel
                            width: parent.width
                            text: String((root.current && root.current.prompt) || "")
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            wrapMode: Text.Wrap
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)
                        VfButton {
                            Layout.fillWidth: true
                            compact: true
                            tone: "success"
                            text: (void i18n.revision, i18n.t("job_panel.review_pass", "Pass"))
                            onClicked: root.markPassNext()
                        }
                        VfButton {
                            Layout.fillWidth: true
                            compact: true
                            tone: "danger"
                            text: (void i18n.revision, i18n.t("job_panel.review_flag", "Flag"))
                            onClicked: root.markFlag()
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)
                        VfButton {
                            Layout.fillWidth: true
                            compact: true
                            text: (void i18n.revision, i18n.t("job_panel.edit_prompt_tooltip", "Edit prompt"))
                            enabled: Boolean((root.current && root.current.canEdit) !== false)
                            onClicked: root.requestEdit()
                        }
                        VfButton {
                            Layout.fillWidth: true
                            compact: true
                            tone: "primary"
                            text: (void i18n.revision, i18n.t("qml.master.regenerate_short", "Regen"))
                            enabled: Boolean(root.current && root.current.canRetry)
                            onClicked: root.requestRegen()
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("job_panel.review_keys", "→ Pass+next   F Flag   Shift+→ Skip   E Edit   R Regen"))
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                        wrapMode: Text.Wrap
                    }
                }
            }
        }

        VfListView {
            id: strip
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(78)
            orientation: ListView.Horizontal
            spacing: VfTheme.dp(6)
            model: root.jobModel
            currentIndex: root.currentIndex
            highlightFollowsCurrentItem: true
            clip: true

            delegate: Rectangle {
                id: tile
                required property int index
                required property string jobId
                required property string thumbnailUrl
                required property string reviewStatus
                width: VfTheme.dp(110)
                height: strip.height
                radius: VfTheme.dp(8)
                color: VfTheme.canvas
                border.width: tile.index === root.currentIndex ? 2 : 1
                border.color: tile.index === root.currentIndex ? VfTheme.primary : VfTheme.border
                clip: true

                Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    source: root.toUrl(tile.thumbnailUrl)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    sourceSize.width: Math.ceil(width * 1.5)
                    sourceSize.height: Math.ceil(height * 1.5)
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: VfTheme.dp(4)
                    width: VfTheme.dp(8)
                    height: width
                    radius: width / 2
                    color: tile.reviewStatus === "pass" ? VfTheme.greenBorder
                         : (tile.reviewStatus === "flagged" ? "#DC2626" : VfTheme.textSubtle)
                }

                Text {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: VfTheme.dp(4)
                    text: String(tile.index + 1)
                    color: "#FFFFFF"
                    font.pixelSize: VfTheme.dp(10)
                    font.bold: true
                    style: Text.Outline
                    styleColor: "#80000000"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.currentIndex = tile.index
                        root.reloadCurrent()
                    }
                }
            }
        }
    }

    function badgeText() {
        var p = root.current || ({})
        var parts = []
        var rs = String(p.reviewStatus || "unseen")
        if (rs === "pass")
            parts.push((void i18n.revision, i18n.t("job_panel.review_pass", "Pass")))
        else if (rs === "flagged")
            parts.push((void i18n.revision, i18n.t("job_panel.review_flagged", "Flagged")))
        else
            parts.push((void i18n.revision, i18n.t("job_panel.review_unseen", "Unseen")))
        var gen = Number(p.reviewGen || 0)
        if (gen > 0)
            parts.push((void i18n.revision, i18n.t("job_panel.review_gen", "gen")) + " #" + gen)
        var st = String(p.status || "")
        if (st.length > 0)
            parts.push(st)
        return parts.join(" · ")
    }
}
