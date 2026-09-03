import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../dialogs"
import "../theme"
import "AppIconRegistry.js" as AppIconRegistry
import "MediaSourceResolver.js" as MediaSourceResolver
import "LibraryPolicy.js" as LibraryPolicy
import "JobClock.js" as JobClock

Rectangle {
    id: root
    objectName: "transcriptWorkspace"

    property var meta: ({})
    property var cards: []
    property var queueRows: []
    property var stats: ({})
    property var routeConfig: ({})
    property var selectedCharacters: typeof workPanelController !== "undefined" ? workPanelController.selectedRouteCharacters : []
    property var selectedObjects: typeof workPanelController !== "undefined" ? workPanelController.selectedCloneObjects : []
    property var selectedBackgrounds: typeof workPanelController !== "undefined" ? workPanelController.selectedCloneBackgrounds : []
    property bool compact: width < 1120
    property bool consistencyPanelExpanded: false
    property bool autoMergeEnabled: false
    property bool autoNextEnabled: true
    property bool autoExtendEnabled: false
    property bool deepAnalysisEnabled: false
    property int clipDurationSeconds: 8
    // output_mode + Draw live on MasterConfig dual row (Layout A, same as Clone).
    // Keep lightweight mirrors for SRT policy labels and tour disclosure only.
    property string outputMode: "video"   // "auto" | "video" | "image"
    property string imageMotionMode: "off"
    property string imageMotionHandAsset: "auto"
    readonly property bool imageBranchActive: root.outputMode === "image" || root.outputMode === "auto"
    readonly property bool queuePaused: (
        typeof workPanelController !== "undefined"
        && !!workPanelController.transcriptQueuePaused
    )
    readonly property bool transcriptLinksFetching: (
        typeof workPanelController !== "undefined"
        && !!workPanelController.transcriptLinksFetching
    )
    property string charMode: "hybrid"
    property var libraryPolicyCategories: []
    property var libraryPolicy: ({
        mode: "matrix",
        categories: [],
        scopes: {
            characters: { source: "disabled", missing: "omit", rewrite: "fit_assets" },
            objects: { source: "disabled", missing: "omit", rewrite: "fit_assets" },
            backgrounds: { source: "disabled", missing: "omit", rewrite: "fit_assets" }
        }
    })
    property string selectedAudioCardId: ""
    property string selectedQueueRowId: ""
    // Date.now() is epoch-ms (~1.7e12); QML `int` is int32 and clamps → clock stuck at 0s.
    property double elapsedClockMs: Date.now()
    property double clockStartMs: 0
    readonly property var _audioCards: transcriptAudioCards()
    readonly property var sequenceGraphicsProfile:
        (root.routeConfig || {}).sequence_graphics || ({})
    readonly property bool audioVisualizerEnabled: String(
        root.sequenceGraphicsProfile.mode || "auto") !== "off"
        && Boolean((root.sequenceGraphicsProfile.waveform || {}).enabled)

    // One geometry contract for both the staged-audio header and its delegates.
    // Keep the SRT slot fixed even when its label changes between SRT/SRT-auto;
    // otherwise every flexible title cell receives a different leftover width.
    readonly property real audioTableSpacing: VfTheme.dp(6)
    readonly property real audioCheckColumnWidth: VfTheme.dp(40)
    readonly property real audioTypeColumnWidth: VfTheme.dp(58)
    readonly property real audioSizeColumnWidth: VfTheme.dp(74)
    readonly property real audioDurationColumnWidth: VfTheme.dp(64)
    readonly property real audioStatusColumnWidth: VfTheme.dp(88)
    readonly property real audioConfigActionWidth: VfTheme.dp(118)
    readonly property real audioSrtActionWidth: VfTheme.dp(72)
    readonly property real audioScriptActionWidth: VfTheme.dp(86)
    readonly property real audioDeleteActionWidth: VfTheme.dp(34)
    readonly property real audioActionsColumnWidth: audioConfigActionWidth
        + audioSrtActionWidth
        + audioScriptActionWidth
        + audioDeleteActionWidth
        + (3 * audioTableSpacing)
    // Queue table geometry — keep header + delegate widths identical to avoid skew.
    readonly property real queueTableSpacing: VfTheme.dp(6)
    readonly property real queueModeColumnWidth: VfTheme.dp(72)
    readonly property real queueAspectColumnWidth: VfTheme.dp(64)
    readonly property real queueStyleColumnWidth: VfTheme.dp(88)
    readonly property real queueStatusColumnWidth: VfTheme.dp(92)
    readonly property real queueProgressColumnWidth: VfTheme.dp(80)
    readonly property real queueSegmentsColumnWidth: VfTheme.dp(70)
    readonly property real queueActionsColumnWidth: VfTheme.dp(120)

    signal addCardsRequested(string text)
    signal submitAllRequested()
    signal clearQueueRequested()
    signal startQueueRequested()
    signal pauseQueueRequested()
    signal historyRequested()
    signal routeToolRequested(string action)
    signal removeQueueRowRequested(string rowId)
    signal actionRequested(string actionId, var payload)

    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "transparent"
    implicitHeight: VfTheme.dp(720)

    function trText(key, fallback) {
        var value = String((void i18n.revision, i18n.t(key, fallback || "")) || "")
        return value === key ? (fallback || "") : value
    }

    function openSubtitleStudio() {
        var audioContext = root.selectedAudioCard() || ({})
        var routeContext = root.routeConfig || ({})
        var audioTitle = root.rowTitle(audioContext)
        subtitleStudioController.openForRoute(
            "transcript",
            routeContext.subtitle_profile || ({}),
            {
                market: String(routeContext.market || "global"),
                content_language: String(routeContext.voice_language || routeContext.language || "vi"),
                aspect_ratio: String(routeContext.aspect_ratio || routeContext.ratio || "16:9"),
                title: audioTitle,
                idea: String(audioContext.description || audioContext.prompt || audioTitle || ""),
                script: String(
                    audioContext.transcript || audioContext.transcript_text
                    || audioContext.script || audioContext.script_text
                    || audioContext.srt_text || audioContext.subtitle_text || ""),
                tone: String(routeContext.tone || routeContext.emotion || ""),
                platform: String(routeContext.platform || "auto"),
                content_tags: routeContext.content_tags || [],
                inherited: true
            })
    }

    function openSequenceGraphicsStudio() {
        var audioContext = root.selectedAudioCard() || ({})
        var routeContext = root.routeConfig || ({})
        var subtitleProfile = routeContext.subtitle_profile || ({})
        var subtitleMode = String(subtitleProfile.mode || "auto").toLowerCase()
        var subtitleEnabled = subtitleProfile.enabled === undefined
            ? true : Boolean(subtitleProfile.enabled)
        sequenceGraphicsController.openForRouteContext(
            "transcript",
            routeContext.sequence_graphics || ({}),
            {
                enabled: subtitleEnabled && subtitleMode !== "off",
                profile: subtitleProfile,
                has_external_srt: String(
                    audioContext.srt_path || audioContext.subtitle_path || ""
                ).trim().length > 0,
                aspect_ratio: String(
                    routeContext.aspect_ratio || routeContext.ratio || "16:9"),
                timeline_reserved: false
            })
    }

    function cleanText(value) {
        var text = String(value || "")
        while (text.length > 0) {
            var code = text.charCodeAt(0)
            if (code === 0x20) {
                text = text.slice(1)
                continue
            }
            if (code >= 0xD800 && code <= 0xDBFF) {
                text = text.slice(2).replace(/^[\ufe0f\u200d\s]+/, "")
                continue
            }
            if ((code >= 0x2600 && code <= 0x27BF) || code === 0x25A1 || code === 0xFFFD) {
                text = text.slice(1).replace(/^[\ufe0f\u200d\s]+/, "")
                continue
            }
            if (text.indexOf((void i18n.revision, i18n.t("transcript_workspace.unicode_char_1", "ð"))) === 0 || text.indexOf((void i18n.revision, i18n.t("transcript_workspace.unicode_char_2", "ï"))) === 0 || text.indexOf((void i18n.revision, i18n.t("transcript_workspace.unicode_char_3", "â"))) === 0) {
                var firstSpace = text.indexOf(" ")
                if (firstSpace >= 0) {
                    text = text.slice(firstSpace + 1)
                    continue
                }
            }
            break
        }
        return text
    }

    function rowTitle(row) {
        if (!row)
            return ""
        if (row.name)
            return String(row.name)
        if (row.title)
            return String(row.title)
        if (row.prompt)
            return String(row.prompt)
        if (row.local_path)
            return String(row.local_path)
        return String(row.id || row.row_id || row.batch_id || "")
    }

    function libraryPolicyCategoryList() {
        // RONG la hop le (user chon "AI tu tao" cho moi scope) -> khong ep ["characters"].
        var items = root.libraryPolicyCategories || []
        var out = []
        for (var i = 0; i < items.length; i += 1) {
            var value = String(items[i] || "")
            if (value.length > 0 && out.indexOf(value) < 0)
                out.push(value)
        }
        return out
    }

    function storedScopePolicy(category) {
        var policy = root.libraryPolicy || ({})
        var scopes = policy.scopes || ({})
        return scopes[String(category || "")] || ({})
    }

    function buildLibraryPolicy(overrideCategory, overrideKey, overrideValue) {
        // Phan matrix dung CHUNG o LibraryPolicy.build; tab chi cap nguon rieng.
        return LibraryPolicy.build(
            root.charMode,
            root.libraryPolicyCategoryList(),
            function(category) { return root.storedScopePolicy(category) },
            "semantic_audio_role_match",
            overrideCategory, overrideKey, overrideValue)
    }

    function saveLibraryPolicy(overrideCategory, overrideKey, overrideValue) {
        root.charMode = "hybrid"
        root.libraryPolicy = root.buildLibraryPolicy(overrideCategory, overrideKey, overrideValue)
        root.libraryPolicyCategories = root.libraryPolicy.categories || []
        root.requestAction("work_panel.transcript_library_policy", {
            char_mode: root.charMode,
            categories: root.libraryPolicyCategories,
            library_policy: root.libraryPolicy,
            source: "transcript_library_policy"
        })
    }

    function consistencySource(category) {
        var policy = root.buildLibraryPolicy()
        var scope = ((policy || {}).scopes || ({}))[String(category || "")] || ({})
        return String(scope.source || scope.source_policy || "ai")
    }

    function consistencyActiveCount() {
        var count = 0
        var categories = ["characters", "objects", "backgrounds"]
        for (var i = 0; i < categories.length; i += 1) {
            if (root.consistencySource(categories[i]) !== "disabled")
                count += 1
        }
        return count
    }

    function consistencyDisclosureText() {
        var label = root.trText("transcript_workspace.library_control_short", "Đồng nhất")
        var count = root.consistencyActiveCount()
        var state = count > 0
            ? (" " + String(count) + "/3")
            : ": " + root.trText("transcript_workspace.consistency_off", "Tắt")
        return label + state + (root.consistencyPanelExpanded ? "  ▴" : "  ▾")
    }

    function consistencyDisclosureTooltip() {
        var count = root.consistencyActiveCount()
        if (count <= 0)
            return root.trText("transcript_workspace.consistency_all_off_tip", "Đồng nhất đang tắt cho cả nhân vật, đồ vật và bối cảnh. Nhấn để cấu hình.")
        return root.trText("transcript_workspace.consistency_active_tip", "Đang bật {count}/3 nhóm đồng nhất. Nhấn để cấu hình.")
            .replace("{count}", String(count))
    }

    function setLibraryCategoryEnabled(category, enabled) {
        var target = String(category || "")
        var items = root.libraryPolicyCategoryList()
        var index = items.indexOf(target)
        if (enabled && index < 0)
            items.push(target)
        if (!enabled && index >= 0)
            items.splice(index, 1)
        var ordered = []
        var order = ["characters", "objects", "backgrounds"]
        for (var i = 0; i < order.length; i += 1) {
            if (items.indexOf(order[i]) >= 0)
                ordered.push(order[i])
        }
        root.libraryPolicyCategories = ordered
        root.saveLibraryPolicy(target, "", "")
    }

    function selectedAudioCard() {
        var items = root.transcriptAudioCards()
        if (items.length === 0)
            return null
        var selectedId = String(root.selectedAudioCardId || "")
        for (var i = 0; i < items.length; i++) {
            if (String(items[i].id || items[i].row_id || items[i].batch_id || "") === selectedId)
                return items[i]
        }
        return items[0]
    }

    // Đẩy toàn bộ card đã stage (file / thư mục / link) vào hàng đợi.
    // Audio chỉ tải/ xử lý khi chạy hàng đợi (giọng đọc do Voice Studio lo,
    // tab này chỉ chọn audio CÓ SẴN — không sinh nội dung/voice tại đây).
    function submitCurrentMode() {
        root.requestAction("work_panel.transcript_add_audio_to_queue", { source: "transcript_audio_source" })
    }

    function cardId(card) {
        if (!card)
            return ""
        return String(card.id || card.row_id || card.batch_id || "")
    }

    function transcriptAudioCards() {
        var items = []
        var allCards = root.cards || []
        for (var i = 0; i < allCards.length; i++) {
            var card = allCards[i]
            if (card && String(card.source_type || "") === "transcript_audio"
                && (card.local_path || String(card.kind || "") === "link"))
                items.push(card)
        }
        return items
    }

    function audioCardIsQueueable(card) {
        if (!card)
            return false
        var status = String(card.status || "draft").toLowerCase()
        if (["submitted", "queued", "running", "complete", "completed"].indexOf(status) >= 0)
            return false
        if (String(card.kind || "").toLowerCase() !== "link")
            return String(card.local_path || "").trim().length > 0
        var url = String(card.url || "").trim().toLowerCase()
        return card.fetch_ok === true
            && (url.indexOf("http://") === 0 || url.indexOf("https://") === 0)
    }

    function audioCardSelected(card) {
        // Default true (like Clone) when field missing on older staged rows.
        return !card || card.selected !== false
    }

    function queueableAudioCardCount() {
        var items = root._audioCards || []
        var count = 0
        for (var i = 0; i < items.length; i++) {
            if (root.audioCardIsQueueable(items[i]) && root.audioCardSelected(items[i]))
                count += 1
        }
        return count
    }

    function queueOutputModeLabel(row) {
        if (!row)
            return "—"
        var requested = String(row.requested_output_mode || "").toLowerCase()
        var resolved = String(row.resolved_output_mode || "").toLowerCase()
        var imageLabel = root.trText("transcript_workspace.mode_image", "Ảnh")
        var videoLabel = root.trText("transcript_workspace.mode_video", "Video")
        var canned = String(row.output_mode_label || "").trim()
        // Prefer dynamic Auto→ resolved label over static backend "Ảnh"/"Video"
        // when the job was submitted as Auto.
        if (requested === "auto") {
            if (resolved === "image")
                return "Auto → " + imageLabel
            if (resolved === "video")
                return "Auto → " + videoLabel
            if (canned.length)
                return canned
            return root.trText("transcript_workspace.mode_auto_pending", "Auto · chờ phân loại")
        }
        if (canned.length)
            return canned
        if (resolved === "image" || requested === "image")
            return imageLabel
        if (resolved === "video" || requested === "video")
            return videoLabel
        if (requested === "auto" || resolved === "auto")
            return root.trText("transcript_workspace.mode_auto", "Auto")
        return "—"
    }

    function queueOutputModeColor(row) {
        var mode = String((row && (row.resolved_output_mode || row.requested_output_mode)) || "").toLowerCase()
        if (mode === "image")
            return "#0891B2"
        if (mode === "video")
            return "#7C3AED"
        if (mode === "auto")
            return "#D97706"
        return VfTheme.textMuted
    }

    function failedAudioLinkCount() {
        var items = root._audioCards || []
        var count = 0
        for (var i = 0; i < items.length; i++) {
            if (String(items[i].kind || "").toLowerCase() === "link"
                && !root.audioCardIsQueueable(items[i]))
                count += 1
        }
        return count
    }

    function fileSizeText(row) {
        if (!row)
            return "-"
        if (row.file_size_text)
            return String(row.file_size_text)
        var bytes = Number(row.file_size || row.size || 0)
        if (!bytes)
            return "-"
        if (bytes >= 1073741824)
            return (bytes / 1073741824).toFixed(1) + " GB"
        return (bytes / 1048576).toFixed(1) + " MB"
    }

    function durationText(row) {
        if (!row)
            return "-"
        if (row.duration)
            return String(row.duration)
        var seconds = Number(row.duration_seconds || 0)
        if (!seconds)
            return root.trText("clone.unknown", "Unknown")
        var minutes = Math.floor(seconds / 60)
        var rest = seconds % 60
        return String(minutes) + ":" + (rest < 10 ? "0" : "") + String(rest)
    }

    function selectedCharacterIds() {
        var out = []
        var items = root.selectedCharacters || []
        for (var i = 0; i < items.length; i += 1) {
            var mediaId = String(items[i].media_id || items[i].id || "")
            if (mediaId.length > 0)
                out.push(mediaId)
        }
        return out
    }

    function selectedCharacterSummary() {
        var items = root.selectedCharacters || []
        if (items.length <= 0)
            return root.trText("clone.no_characters_selected", "No library characters selected yet.")
        return root.trText("master.characters_selected", "{count} library character(s) selected")
            .replace("{count}", String(items.length))
    }

    function selectedCharacterDisplayName(asset) {
        var item = asset || {}
        return String(item.name || item.title || item.label || item.id || "")
    }

    function selectedCharacterThumbSource(asset) {
        return MediaSourceResolver.imageSource(asset || ({}))
    }

    function selectedCharacterCardSummary(asset) {
        var item = asset || {}
        var text = root.cleanText(item.summary || item.description || item.caption || "")
        var displayName = root.selectedCharacterDisplayName(item)
        if (text.length === 0 || text === displayName)
            return root.trText("master.character_card_fallback", "Saved library character ready for reuse.")
        return text
    }

    function selectedCharacterRole(asset, indexValue) {
        var item = asset || {}
        var direct = root.cleanText(item.role || "")
        if (direct === "primary" || direct === "main")
            return "primary"
        if (direct === "secondary")
            return "secondary"
        var assetId = root.cleanText(item.id || item.asset_id || "")
        if (assetId === "CHAR_000" || indexValue === 0)
            return "primary"
        if (assetId === "CHAR_001" || indexValue === 1)
            return "secondary"
        return ""
    }

    function selectedCharacterRoleLabel(asset, indexValue) {
        var role = root.selectedCharacterRole(asset, indexValue)
        if (role === "primary")
            return root.trText("clone.creative_char_main", "Main character")
        if (role === "secondary")
            return root.trText("clone.creative_char_secondary", "Secondary character")
        var item = asset || {}
        var assetId = root.cleanText(item.id || item.asset_id || "")
        if (assetId.indexOf("CHAR_") === 0)
            return assetId
        return ""
    }

    function selectedCharacterRoleFill(asset, indexValue) {
        var role = root.selectedCharacterRole(asset, indexValue)
        if (role === "primary")
            return VfTheme.violetFill
        if (role === "secondary")
            return VfTheme.violetFill
        return VfTheme.surfaceSoft
    }

    function selectedCharacterRoleBorder(asset, indexValue) {
        var role = root.selectedCharacterRole(asset, indexValue)
        if (role === "primary")
            return "#7C3AED"
        if (role === "secondary")
            return "#A78BFA"
        return VfTheme.violetBorderSoft
    }

    function selectedCharacterRoleTextColor(asset, indexValue) {
        var role = root.selectedCharacterRole(asset, indexValue)
        if (role === "primary")
            return VfTheme.violetText
        if (role === "secondary")
            return "#7C3AED"
        return VfTheme.violetText
    }

    function openCharacterLibrary() {
        if (typeof workPanelController === "undefined")
            return
        transcriptCharacterLibraryDialogLoader.active = true
        transcriptCharacterLibraryDialogLoader.item.openUsagePicker("character", ["character"], root.selectedCharacterIds(), 12, true)
    }

    function selectedObjectIds() {
        var out = []
        var items = root.selectedObjects || []
        for (var i = 0; i < items.length; i += 1) {
            var mediaId = String(items[i].media_id || items[i].id || "")
            if (mediaId.length > 0)
                out.push(mediaId)
        }
        return out
    }

    function selectedBackgroundIds() {
        var out = []
        var items = root.selectedBackgrounds || []
        for (var i = 0; i < items.length; i += 1) {
            var mediaId = String(items[i].media_id || items[i].id || "")
            if (mediaId.length > 0)
                out.push(mediaId)
        }
        return out
    }

    function openObjectLibrary() {
        if (typeof workPanelController === "undefined")
            return
        transcriptObjectLibraryDialogLoader.active = true
        transcriptObjectLibraryDialogLoader.item.openUsagePicker("object", ["object"], root.selectedObjectIds(), 12, true)
    }

    function openBackgroundLibrary() {
        if (typeof workPanelController === "undefined")
            return
        transcriptBackgroundLibraryDialogLoader.active = true
        transcriptBackgroundLibraryDialogLoader.item.openUsagePicker("background", ["background", "setting"], root.selectedBackgroundIds(), 12, true)
    }

    function rowStatusToken(row) {
        if (!row)
            return ""
        var status = String(row.status || row.job_status || "").toLowerCase()
        var stage = String(row.charcore_status || "").trim().toLowerCase()
        var step = String(row.step_status || row.status_label || "").trim().toLowerCase()
        // Terminal states win.
        if (["complete", "completed", "done"].indexOf(status) >= 0)
            return "complete"
        if (["failed", "error"].indexOf(status) >= 0
                || ["chargen_failed", "chargen_policy_error", "job_failed"].indexOf(stage) >= 0)
            return "failed"
        // step_status FREEZES at "analyzing" after the analysis phase — the character
        // + video phases only advance charcore_status. Read it FIRST (mirrors
        // activeTranscriptStepInfo) so the row doesn't stick at "Phân tích / 28%".
        if (stage === "video_jobs_submitted")
            return "generating"
        if (stage === "chargen_completed")
            return "chargen_done"
        if (root.isPoolSlotWaitMessage(row.progress_message))
            return "chargen"
        if (stage === "chargen_started")
            return "chargen"
        if (step === "image_story")
            return "generating"
        if (step.length > 0)
            return step
        return status
    }

    function prepLabel() {
        var token = root.rowStatusToken(root.activeQueueRow())
        if (token === "downloading") return root.trText("transcript_workspace.step_download", "Tải link")
        if (token === "ai_script") return root.trText("transcript_workspace.step_ai", "AI viết kịch bản")
        if (token === "tts") return root.trText("transcript_workspace.step_tts", "Tạo giọng")
        return root.trText("transcript_workspace.step_prep", "Chuẩn bị")
    }

    function isPoolSlotWaitMessage(message) {
        var t = String(message || "").toLowerCase()
        return t.indexOf("hết slot") >= 0
            || t.indexOf("het slot") >= 0
            || t.indexOf("chỗ trống") >= 0
            || t.indexOf("waiting for slot") >= 0
            || t.indexOf("pool saturated") >= 0
    }

    function rowProgressMessage(row) {
        if (!row)
            return ""
        return String(
            row.progress_message
            || row.detail_message
            || row.status_message
            || row.message
            || ""
        )
    }

    function activeQueueRow() {
        var rows = root.queueRows || []
        if (rows.length <= 0)
            return null
        var selectedId = String(root.selectedQueueRowId || "")
        if (selectedId.length > 0) {
            for (var selectedIndex = 0; selectedIndex < rows.length; selectedIndex += 1) {
                var selectedRowId = String(rows[selectedIndex].id || rows[selectedIndex].row_id || rows[selectedIndex].batch_id || "")
                if (selectedRowId === selectedId)
                    return rows[selectedIndex]
            }
        }
        for (var i = 0; i < rows.length; i += 1) {
            var token = root.rowStatusToken(rows[i])
            if (["downloading", "ai_script", "tts", "analyzing", "chargen", "chargen_done", "routing", "generating", "merging", "running", "processing"].indexOf(token) >= 0)
                return rows[i]
        }
        return rows[0]
    }

    function hasRunningQueueRow() {
        var rows = root.queueRows || []
        for (var i = 0; i < rows.length; i += 1) {
            var status = String(rows[i].status || rows[i].job_status || "").toLowerCase()
            if (["running", "processing", "routing", "analyzing", "generating"].indexOf(status) >= 0)
                return true
        }
        return false
    }

    function elapsedText(row) {
        var item = row || {}
        return JobClock.elapsedText(
            item,
            root.elapsedClockMs,
            root.rowStatusToken(item),
            root.clockStartMs
        )
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.hasRunningQueueRow()
        onRunningChanged: {
            root.elapsedClockMs = Date.now()
            if (running) {
                if (root.clockStartMs <= 0)
                    root.clockStartMs = root.elapsedClockMs
            } else {
                root.clockStartMs = 0
            }
        }
        onTriggered: root.elapsedClockMs = Date.now()
    }

    function phaseState(phaseName) {
        var row = root.activeQueueRow()
        var token = root.rowStatusToken(row)
        if (!row || token.length === 0)
            return "idle"
        if (["completed", "complete", "done"].indexOf(token) >= 0)
            return "complete"
        if (["failed", "error"].indexOf(token) >= 0)
            return phaseName === "merge" ? "active" : "idle"

        var order = ["prep", "analyze", "route", "generate", "merge"]
        var activeIndex = 1
        if (["downloading", "ai_script", "tts"].indexOf(token) >= 0)
            activeIndex = 0
        else if (token === "analyzing")
            activeIndex = 1
        else if (["chargen", "chargen_done", "routing"].indexOf(token) >= 0)
            activeIndex = 2
        else if (["generating", "running", "processing", "queued"].indexOf(token) >= 0)
            activeIndex = 3
        else if (token === "merging")
            activeIndex = 4
        var phaseIndex = order.indexOf(phaseName)
        if (phaseIndex < 0)
            return "idle"
        if (phaseIndex < activeIndex)
            return "complete"
        if (phaseIndex === activeIndex)
            return "active"
        return "idle"
    }

    // % tiến độ 0–100: nền theo từng pha (download→analyze→route→generate→merge);
    // riêng pha generate cộng tiến độ render scene thật (job_progress từ dispatcher).
    function rowProgressPercent(row) {
        if (!row)
            return 0
        var token = root.rowStatusToken(row)
        if (["completed", "complete", "done"].indexOf(token) >= 0)
            return 100
        if (["failed", "error"].indexOf(token) >= 0)
            return Math.max(0, Math.min(100, Number(row.job_progress || 0)))
        if (["downloading", "ai_script", "tts", "prep", "preparing"].indexOf(token) >= 0)
            return 8
        if (token === "analyzing")
            return 28
        if (token === "chargen")
            return 40
        if (token === "chargen_done")
            return 48
        if (token === "routing")
            return 45
        if (["generating", "running", "processing", "queued"].indexOf(token) >= 0) {
            if (row.image_assembly_progress !== undefined
                    && row.image_assembly_progress !== null
                    && row.image_assembly_progress !== "") {
                var ap = Math.max(0, Math.min(100, Number(row.image_assembly_progress)))
                return 95 + Math.round(ap * 0.04)
            }
            var jp = Math.max(0, Math.min(100, Number(row.job_progress || 0)))
            return 50 + Math.round(jp * 0.45)
        }
        if (token === "merging")
            return 96
        return 0
    }

    // Nhãn trạng thái thân thiện (thay cho RUNNING/PENDING thô) — cập nhật realtime.
    function rowStatusLabel(row) {
        if (!row)
            return ""
        var token = root.rowStatusToken(row)
        switch (token) {
        case "downloading": return root.trText("transcript_workspace.step_download", "Tải link")
        case "ai_script":   return root.trText("transcript_workspace.step_ai", "AI viết kịch bản")
        case "tts":         return root.trText("transcript_workspace.step_tts", "Tạo giọng")
        case "analyzing":   return root.trText("transcript_workspace.step_analyze", "Phân tích")
        case "chargen":     return root.trText("transcript_workspace.st_chars", "Đang tạo nhân vật...")
        case "chargen_done":return root.trText("transcript_workspace.st_chars_done", "Đã tạo nhân vật")
        case "routing":     return root.trText("transcript_workspace.step_route", "Định tuyến")
        case "generating":
        case "running":
        case "processing": {
            var generatingLive = root.rowProgressMessage(row).trim()
            if (generatingLive.length > 0)
                return generatingLive
            return root.trText("transcript_workspace.step_generate", "Dựng video")
        }
        case "merging": {
            var mergingLive = root.rowProgressMessage(row).trim()
            if (mergingLive.length > 0)
                return mergingLive
            return root.trText("transcript_workspace.step_merge", "Ghép")
        }
        case "complete":
        case "completed":
        case "done":        return root.trText("common.completed", "Hoàn thành")
        case "failed":
        case "error":       return root.trText("common.failed", "Lỗi")
        case "pending":
        case "queued":
        case "":            return root.trText("transcript_workspace.step_pending", "Chờ")
        default:            return token
        }
    }

    // "đã xong / tổng" scene — lấy từ dispatcher_summary, fallback video_count/scene_count.
    function rowSegmentsLabel(row) {
        if (!row)
            return "-"
        var summary = row.dispatcher_summary || null
        if (summary && Number(summary.total || 0) > 0)
            return String(Number(summary.complete || 0)) + "/" + String(Number(summary.total || 0))
        var sceneCount = Number(row.scene_count || 0)
        if (sceneCount > 0)
            return String(Number(row.video_count || 0)) + "/" + String(sceneCount)
        return "-"
    }

    function rowProgressColor(row) {
        var token = root.rowStatusToken(row)
        if (["failed", "error"].indexOf(token) >= 0)
            return VfTheme.redText
        if (["completed", "complete", "done"].indexOf(token) >= 0)
            return VfTheme.greenText
        return VfTheme.primary
    }

    // Map đúng STATUS BACKEND THẬT của transcript (đã verify): step_status chỉ phát
    // downloading/tts/analyzing/image_story (qua _step) và ĐÔNG CỨNG sau phân tích →
    // các pha sau (nhân vật + dựng video) PHẢI đọc charcore_status
    // (chargen_started/completed/video_jobs_submitted). status = pending/running/complete/failed.
    function activeTranscriptStepInfo() {
        var row = root.activeQueueRow() || {}
        var status = String(row.status || row.job_status || "").toLowerCase()
        var stage = String(row.charcore_status || "").trim().toLowerCase()
        var step = String(row.step_status || "").trim().toLowerCase()
        var total = 4
        if (["complete", "completed", "done"].indexOf(status) >= 0)
            return { label: root.trText("common.completed", "Hoàn thành"), icon: "check-mark-button", color: "#059669", step: total, total: total, indeterminate: false, failed: false }
        if (["failed", "error"].indexOf(status) >= 0 || ["chargen_failed", "chargen_policy_error", "job_failed"].indexOf(stage) >= 0)
            return { label: root.trText("common.failed", "Lỗi"), icon: "cross-mark", color: "#DC2626", step: 0, total: total, indeterminate: false, failed: true }
        if (stage === "video_jobs_submitted") {
            var videoLive = root.rowProgressMessage(row).trim()
            return {
                label: videoLive.length > 0
                    ? videoLive
                    : root.trText("transcript_workspace.st_video", "Đang dựng video..."),
                icon: "movie-camera",
                color: "#2563EB",
                step: 4,
                total: total,
                indeterminate: true,
                failed: false
            }
        }
        if (stage === "chargen_completed")
            return { label: root.trText("transcript_workspace.st_chars_done", "Đã tạo nhân vật"), icon: "check-mark-button", color: "#7C3AED", step: 3, total: total, indeterminate: false, failed: false }
        if (root.isPoolSlotWaitMessage(row.progress_message))
            return { label: root.trText("transcript_workspace.st_waiting_slot", "Hết slot — đang chờ..."), icon: "alarm-clock", color: "#D97706", step: 3, total: total, indeterminate: true, failed: false }
        if (stage === "chargen_started")
            return { label: root.trText("transcript_workspace.st_chars", "Đang tạo nhân vật..."), icon: "artist-palette", color: "#7C3AED", step: 3, total: total, indeterminate: true, failed: false }
        if (step === "image_story") {
            var imageLive = root.rowProgressMessage(row).trim()
            return {
                label: imageLive.length > 0
                    ? imageLive
                    : root.trText("transcript_workspace.st_image", "Đang dựng video ảnh..."),
                icon: "movie-camera",
                color: "#2563EB",
                step: 4,
                total: total,
                indeterminate: true,
                failed: false
            }
        }
        if (step === "analyzing")
            return { label: root.trText("transcript_workspace.st_analyze", "Đang phân tích..."), icon: "magnifying-glass", color: "#0891B2", step: 2, total: total, indeterminate: true, failed: false }
        if (step === "tts")
            return { label: root.trText("transcript_workspace.st_tts", "Đang tạo giọng..."), icon: "gear", color: "#0EA5E9", step: 1, total: total, indeterminate: true, failed: false }
        if (step === "downloading")
            return { label: root.trText("transcript_workspace.st_download", "Đang tải audio..."), icon: "inbox-tray", color: "#0EA5E9", step: 1, total: total, indeterminate: true, failed: false }
        if (["running", "generating", "processing", "queued", "routing"].indexOf(status) >= 0)
            return { label: root.trText("transcript_workspace.st_processing", "Đang xử lý..."), icon: "movie-camera", color: "#2563EB", step: 4, total: total, indeterminate: true, failed: false }
        return { label: root.trText("transcript_workspace.st_waiting", "Chờ xử lý"), icon: "alarm-clock", color: VfTheme.textMuted, step: 0, total: total, indeterminate: false, failed: false }
    }

    function requestAction(actionId, payload) {
        var data = {
            action_id: actionId,
            route: "transcript"
        }
        for (var key in payload || ({}))
            data[key] = payload[key]
        root.actionRequested(actionId, data)
        return data
    }

    function requestRouteTool(action, actionId) {
        root.requestAction(actionId, {
            source: "transcript_route_tool",
            route_tool: action
        })
        root.routeToolRequested(action)
    }

    function requestQueueAction(actionId) {
        root.requestAction(actionId, { source: "transcript_queue_toolbar" })
        if (actionId === "work_panel.submit_all")
            root.submitAllRequested()
        else if (actionId === "work_panel.pause_queue")
            root.pauseQueueRequested()
        else if (actionId === "work_panel.clear_queue")
            root.clearQueueRequested()
        else if (actionId === "work_panel.start_queue")
            root.startQueueRequested()
    }

    function requestRemoveQueueRow(rowId) {
        root.requestAction("work_panel.queue_delete_row", {
            row_id: rowId,
            source: "transcript_queue_row"
        })
        root.removeQueueRowRequested(rowId)
    }

    function configValue(key, fallback) {
        var config = typeof workPanelController !== "undefined" && workPanelController
            ? (workPanelController.currentRouteConfig || ({}))
            : (root.routeConfig || ({}))
        if (config[key] === undefined || config[key] === null)
            return fallback
        return config[key]
    }

    function syncFromRouteConfig() {
        root.autoMergeEnabled = !!root.configValue("auto_merge", root.autoMergeEnabled)
        root.autoNextEnabled = !!root.configValue("auto_next_job", root.autoNextEnabled)
        root.autoExtendEnabled = false
        root.deepAnalysisEnabled = !!root.configValue("deep_analysis", root.deepAnalysisEnabled)
        var _out = String(root.configValue("output_mode", root.outputMode || "video") || "video").toLowerCase()
        root.outputMode = (_out === "image" || _out === "auto") ? _out : "video"
        root.imageMotionMode = String(root.configValue("image_motion_mode", "off")) === "auto" ? "auto" : "off"
        root.imageMotionHandAsset = String(root.configValue("image_motion_hand_asset", "auto") || "auto")
        root.clipDurationSeconds = Number(root.configValue("clip_duration_seconds", root.clipDurationSeconds || 8)) || 8
        root.charMode = String(root.configValue("char_mode", root.charMode || "full_ai"))
        // Chỉ gán array/object khi NỘI DUNG đổi (configValue trả reference mới mỗi lần
        // -> gán thẳng sẽ ép panel re-render thừa mỗi emit). Xem CloneWorkspace cùng fix.
        var __cats = root.configValue("library_policy_categories", root.libraryPolicyCategories || ["characters"]) || ["characters"]
        if (JSON.stringify(__cats) !== JSON.stringify(root.libraryPolicyCategories))
            root.libraryPolicyCategories = __cats
        var __pol = root.configValue("library_policy", root.libraryPolicy || ({})) || ({})
        if (JSON.stringify(__pol) !== JSON.stringify(root.libraryPolicy))
            root.libraryPolicy = __pol
        var items = root.transcriptAudioCards()
        if (items.length === 0) {
            root.selectedAudioCardId = ""
        } else if (!root.selectedAudioCard()) {
            root.selectedAudioCardId = String(items[0].id || items[0].row_id || items[0].batch_id || "")
        }
    }

    onRouteConfigChanged: syncFromRouteConfig()
    // Mở/chuyển sang tab này → re-sync để pill khớp config đã lưu (chống stale sau restart).
    onVisibleChanged: if (visible) syncFromRouteConfig()
    Component.onCompleted: syncFromRouteConfig()

    Connections {
        target: masterOptionsController
        // Tab ẩn không resync theo master config (onVisibleChanged đã bù khi mở lại).
        enabled: root.visible
        function onConfigChanged() {
            root.syncFromRouteConfig()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: VfTheme.dp(9)

        Flow {
            objectName: "transcriptFeatureToolbar"
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            spacing: VfTheme.dp(7)

            TogglePill {
                text: root.consistencyDisclosureText()
                actionId: "work_panel.transcript_char_consistency"
                selected: root.consistencyActiveCount() > 0
                accent: "#7C3AED"
                minWidth: VfTheme.dp(108)
                tooltip: root.consistencyDisclosureTooltip()
                onClicked: root.consistencyPanelExpanded = !root.consistencyPanelExpanded
            }
            SpacerDot {}
            VfToolbarSwitch {
                text: root.trText("master.auto_merge_video", "Tự ghép video")
                actionId: "work_panel.transcript_auto_merge"
                tooltip: root.trText(
                    "transcript.auto_merge_hint",
                    "Tự động ghép các cảnh thành video hoàn chỉnh khi tạo xong.")
                checked: root.autoMergeEnabled
                accent: "#10B981"
                minWidth: VfTheme.dp(112)
                onToggled: function(enabled) {
                    root.autoMergeEnabled = enabled
                    root.requestAction("work_panel.transcript_auto_merge_toggle", {
                        enabled: enabled,
                        source: "transcript_feature_bar"
                    })
                }
            }
            SubtitleWorkflowButton {
                objectName: "transcriptSubtitleWorkflowButton"
                actionId: "work_panel.transcript_subtitle_workflow"
                minWidth: VfTheme.dp(174)
                controlHeight: VfTheme.controlHeight
                profile: (root.routeConfig || {}).subtitle_profile || ({})
                configuredLanguage: (root.routeConfig || {}).voice_language
                    || (root.routeConfig || {}).language || "vi"
                onClicked: root.openSubtitleStudio()
            }
            VfButton {
                objectName: "transcriptSequenceGraphicsButton"
                actionId: "work_panel.transcript_sequence_graphics"
                compact: true
                minWidth: VfTheme.dp(154)
                implicitHeight: VfTheme.controlHeight
                iconName: "timer"
                text: root.audioVisualizerEnabled
                    ? root.trText("transcript.waveform_on", "SÓNG ÂM · BẬT")
                    : root.trText("transcript.waveform_off", "SÓNG ÂM · TẮT")
                tone: root.audioVisualizerEnabled ? "accent" : "neutral"
                tooltip: root.trText(
                    "transcript.waveform_hint",
                    "Mở Audio Visualizer. Timeline sự kiện luôn tắt; sóng bám audio thật sau khi Tự động ghép video hoàn tất.")
                onClicked: root.openSequenceGraphicsStudio()
            }
            TogglePill {
                text: root.trText("transcript.auto_next_job", "Auto Next Job")
                actionId: "work_panel.transcript_auto_next"
                selected: root.autoNextEnabled
                accent: "#16A34A"
                minWidth: VfTheme.dp(128)
                onClicked: {
                    root.autoNextEnabled = !root.autoNextEnabled
                    root.requestAction("work_panel.transcript_auto_next_toggle", {
                        enabled: root.autoNextEnabled,
                        source: "transcript_feature_bar"
                    })
                }
            }
            TogglePill {
                text: root.trText("master.deep_analysis", "Deep Analysis")
                actionId: "work_panel.transcript_deep_analysis"
                selected: root.deepAnalysisEnabled
                accent: "#7C3AED"
                minWidth: VfTheme.dp(124)
                onClicked: {
                    root.deepAnalysisEnabled = !root.deepAnalysisEnabled
                    root.requestAction("work_panel.transcript_deep_analysis_toggle", {
                        enabled: root.deepAnalysisEnabled,
                        source: "transcript_feature_bar"
                    })
                }
            }
        }

        CharacterOptions {
            visible: root.consistencyPanelExpanded
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? implicitHeight : 0
        }

        ResponsiveSplit {
            id: transcriptSplit
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: VfTheme.dp(520)
            gap: VfTheme.dp(10)
            rightRatio: 0.46
            stackBelow: VfTheme.dp(880)

            SourceFrame {
                Layout.fillWidth: true
                Layout.fillHeight: !transcriptSplit.stacked
                Layout.preferredHeight: transcriptSplit.stacked ? implicitHeight : -1
            }

            QueueFrame {
                Layout.preferredWidth: transcriptSplit.rightPaneWidth
                Layout.fillWidth: transcriptSplit.stacked
                Layout.fillHeight: !transcriptSplit.stacked
                Layout.preferredHeight: transcriptSplit.stacked ? implicitHeight : -1
            }
        }
    }

    component SourceFrame: Rectangle {
        objectName: "transcriptSourceFrame"
        radius: VfTheme.dp(8)
        color: VfTheme.surface
        border.color: VfTheme.borderBox
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(8)
            spacing: VfTheme.dp(7)

            // ── Hàng 1: nguồn audio — chọn file / thư mục, dán link bên dưới ──
            // 1 ô input thống nhất: file, thư mục, 1 link hay danh sách link đều
            // gom chung vào bảng staged. (Không có "tạo voice" ở đây — Voice Studio lo.)
            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                FlatActionButton {
                    text: root.trText("transcript_workspace.pick_audio_btn", "Chọn file audio")
                    actionId: "work_panel.transcript_audio_files"
                    accent: "#2563EB"; minWidth: VfTheme.dp(150)
                    onClicked: root.requestRouteTool("transcript_audio_files", "work_panel.transcript_audio_files")
                }
                FlatActionButton {
                    text: root.trText("transcript_workspace.pick_audio_folder_btn", "Chọn thư mục")
                    actionId: "work_panel.transcript_audio_folder"
                    accent: "#0EA5E9"; minWidth: VfTheme.dp(140)
                    onClicked: root.requestRouteTool("transcript_audio_folder", "work_panel.transcript_audio_folder")
                }

                Item { Layout.fillWidth: true }

                FlatActionButton {
                    text: root.trText("common.select_all", "Select All")
                    actionId: "work_panel.transcript_select_all_audio"
                    accent: "#10B981"
                    minWidth: VfTheme.dp(86)
                    enabled: (root._audioCards || []).length > 0
                    opacity: enabled ? 1.0 : 0.48
                    onClicked: root.requestAction("work_panel.transcript_select_all_audio", {
                        source: "transcript_audio_toolbar"
                    })
                }
                FlatActionButton {
                    text: root.trText("common.deselect_all", "Deselect")
                    actionId: "work_panel.transcript_deselect_all_audio"
                    accent: "#EF4444"
                    minWidth: VfTheme.dp(82)
                    enabled: (root._audioCards || []).length > 0
                    opacity: enabled ? 1.0 : 0.48
                    onClicked: root.requestAction("work_panel.transcript_deselect_all_audio", {
                        source: "transcript_audio_toolbar"
                    })
                }
                FlatActionButton {
                    text: root.trText("transcript_workspace.add_queue", "Thêm vào hàng đợi")
                    actionId: "master.queue.add_to_queue"
                    accent: "#3B82F6"; selected: true; minWidth: VfTheme.dp(184)
                    enabled: !root.transcriptLinksFetching
                        && root.queueableAudioCardCount() > 0
                    opacity: enabled ? 1.0 : 0.48
                    tooltip: root.transcriptLinksFetching
                        ? root.trText("transcript_workspace.link_wait_before_queue", "Đợi hệ thống kiểm tra link xong trước khi thêm vào hàng đợi.")
                        : root.queueableAudioCardCount() <= 0 && root.failedAudioLinkCount() > 0
                            ? root.trText("transcript_workspace.link_error_queue_blocked", "Link lỗi hoặc chưa lấy được thông tin đã bị chặn. Hãy xóa link lỗi và dán lại link hợp lệ.")
                            : ""
                    onClicked: root.submitCurrentMode()
                }
            }

            // ── Dán link (1 hoặc nhiều dòng) → auto-fetch tiêu đề vào bảng dưới ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(66)
                    clip: true

                    TextArea {
                        id: linkInput
                        objectName: "transcriptUrlInput"
                        wrapMode: TextArea.Wrap
                        placeholderText: root.trText("transcript_workspace.link_multi_placeholder", "Dán link (mỗi dòng 1 link) — YouTube / TikTok / Facebook… Tự lấy tiêu đề vào danh sách dưới.")
                        color: VfTheme.text
                        placeholderTextColor: VfTheme.textSubtle
                        selectByMouse: true
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        background: Rectangle {
                            radius: VfTheme.dp(7)
                            color: VfTheme.surface
                            border.color: linkInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                            border.width: 1
                        }
                        onTextChanged: linkFetchTimer.restart()
                    }
                }

                // Hàng trạng thái: spinner "đang lấy tiêu đề…" khi fetch, ngược lại là gợi ý
                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(6)

                    property bool fetching: root.transcriptLinksFetching

                    BusyIndicator {
                        running: parent.fetching
                        visible: parent.fetching
                        implicitWidth: VfTheme.dp(14)
                        implicitHeight: VfTheme.dp(14)
                        Layout.preferredWidth: VfTheme.dp(14)
                        Layout.preferredHeight: VfTheme.dp(14)
                    }

                    Text {
                        Layout.fillWidth: true
                        text: parent.fetching
                            ? root.trText("transcript_workspace.link_fetching", "Đang lấy tiêu đề link…")
                            : root.trText("transcript_workspace.link_hint", 'Dán xong → tự lấy tiêu đề vào danh sách → bấm "Thêm vào hàng đợi". Audio chỉ tải khi xử lý hàng đợi.')
                        color: parent.fetching ? VfTheme.primary : VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                        wrapMode: Text.WordWrap
                    }
                }

                Timer {
                    id: linkFetchTimer
                    interval: 1500
                    repeat: false
                    onTriggered: {
                        if (typeof workPanelController === "undefined")
                            return
                        var t = String(linkInput.text || "").trim()
                        if (t.length > 0)
                            workPanelController.fetchTranscriptLinks(t)
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(7)
                color: VfTheme.surface
                border.color: VfTheme.borderBox
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    TableHeader {
                        spacing: root.audioTableSpacing
                        columns: [
                            { label: "✓", width: root.audioCheckColumnWidth, alignRight: false },
                            { label: root.trText("transcript_workspace.table_file_name", "Tên"), width: -1, alignRight: false },
                            { label: root.trText("transcript_workspace.table_type", "Loại"), width: root.audioTypeColumnWidth, alignRight: false },
                            { label: root.trText("transcript_workspace.table_size", "Dung lượng"), width: root.audioSizeColumnWidth, alignRight: false },
                            { label: root.trText("transcript_workspace.table_duration", "Thời lượng"), width: root.audioDurationColumnWidth, alignRight: false },
                            { label: root.trText("transcript_workspace.table_status", "Trạng thái"), width: root.audioStatusColumnWidth, alignRight: false },
                            { label: root.trText("transcript_workspace.actions_column", "Thao tác"), width: root.audioActionsColumnWidth, alignRight: true }
                        ]
                    }

                    ListView {
                        id: audioList
                        objectName: "transcriptAudioList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: root._audioCards
                        clip: true
                        reuseItems: true

                        delegate: Rectangle {
                            width: audioList.width
                            height: VfTheme.dp(56)
                            property string rowCardId: String(modelData.id || modelData.row_id || modelData.batch_id || "")
                            readonly property bool cardSelected: root.audioCardSelected(modelData)
                            // PA1: card đang "Config Override" → panel config transcript sửa
                            // ĐÚNG card này. cfgSummary re-eval khi đổi active hoặc config đổi.
                            readonly property bool cardActive: typeof workPanelController !== "undefined"
                                && rowCardId.length > 0
                                && rowCardId === String(workPanelController.activeTranscriptCardId || "")
                            readonly property var cfgSummary: {
                                void workPanelController.activeTranscriptCardId
                                void workPanelController.currentRouteConfig
                                return (typeof workPanelController !== "undefined")
                                    ? workPanelController.transcriptCardConfigSummary(rowCardId) : ({})
                            }
                            color: cardActive ? VfTheme.blueFill : (root.selectedAudioCardId === rowCardId ? VfTheme.blueFill : (index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft))
                            border.color: cardActive ? VfTheme.primary : (cardSelected ? VfTheme.blueBorderSoft : VfTheme.surfaceSoft)

                            RowLayout {
                                id: audioMainRow
                                z: 1
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: VfTheme.dp(38)
                                anchors.leftMargin: VfTheme.dp(8)
                                anchors.rightMargin: VfTheme.dp(8)
                                spacing: root.audioTableSpacing

                                Item {
                                    Layout.preferredWidth: root.audioCheckColumnWidth
                                    Layout.minimumWidth: root.audioCheckColumnWidth
                                    Layout.preferredHeight: audioMainRow.height
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: VfTheme.dp(30)
                                        height: VfTheme.dp(30)
                                        radius: VfTheme.dp(6)
                                        color: audioCheckArea.containsMouse ? VfTheme.blueFill : "transparent"
                                    }
                                    VfAppIcon {
                                        name: cardSelected ? "check-box-with-check" : "empty-box"
                                        size: VfTheme.dp(20)
                                        framed: false
                                        color: cardSelected
                                            ? VfTheme.primary
                                            : (audioCheckArea.containsMouse ? VfTheme.primary : VfTheme.textSubtle)
                                        anchors.centerIn: parent
                                    }
                                    MouseArea {
                                        id: audioCheckArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.requestAction("work_panel.transcript_toggle_audio_card", {
                                            card_id: rowCardId,
                                            selected: !cardSelected,
                                            source: "transcript_audio_list"
                                        })
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: root.rowTitle(modelData)
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(11)
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    wrapMode: Text.NoWrap
                                    verticalAlignment: Text.AlignVCenter
                                }
                                // Loại: Link (dán + fetch tiêu đề) hay File local
                                Text {
                                    Layout.preferredWidth: root.audioTypeColumnWidth
                                    Layout.minimumWidth: root.audioTypeColumnWidth
                                    text: String(modelData.kind || "") === "link"
                                        ? root.trText("transcript_workspace.kind_link", "Link")
                                        : root.trText("transcript_workspace.kind_file", "File")
                                    color: String(modelData.kind || "") === "link" ? "#0891B2" : VfTheme.blueText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                // Dung lượng (link chưa tải → "-")
                                Text {
                                    Layout.preferredWidth: root.audioSizeColumnWidth
                                    Layout.minimumWidth: root.audioSizeColumnWidth
                                    text: root.fileSizeText(modelData)
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                // Thời lượng
                                Text {
                                    Layout.preferredWidth: root.audioDurationColumnWidth
                                    Layout.minimumWidth: root.audioDurationColumnWidth
                                    text: root.durationText(modelData)
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                // Trạng thái: link fetch lỗi (đỏ) / sẵn sàng (xanh). Có chỉ dẫn
                                // kịch bản → nút "Kịch bản" tô màu tím đậm để nhận biết.
                                Text {
                                    Layout.preferredWidth: root.audioStatusColumnWidth
                                    Layout.minimumWidth: root.audioStatusColumnWidth
                                    text: (String(modelData.kind || "") === "link" && modelData.fetch_ok === false)
                                        ? root.trText("transcript_workspace.staged_link_failed", "Lỗi tiêu đề")
                                        : root.trText("transcript_workspace.staged_ready", "Sẵn sàng")
                                    color: (String(modelData.kind || "") === "link" && modelData.fetch_ok === false) ? VfTheme.redText : VfTheme.greenText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                // PA1: "Config Override" — sửa cấu hình RIÊNG cho file này
                                // (style/model/quality/aspect/nhân vật…). Sáng = đang sửa file đó;
                                // panel cấu hình bên trái bind vào config của file này.
                                Rectangle {
                                    id: cfgOverrideBtn
                                    Layout.preferredWidth: root.audioConfigActionWidth
                                    Layout.minimumWidth: root.audioConfigActionWidth
                                    Layout.preferredHeight: VfTheme.dp(26)
                                    radius: VfTheme.dp(6)
                                    color: cardActive ? "#6366F1" : (cfgMouse.containsMouse ? VfTheme.violetFill : VfTheme.surface)
                                    border.color: cardActive ? "#6366F1" : VfTheme.violetBorderSoft
                                    border.width: 1
                                    ToolTip.visible: cfgMouse.containsMouse
                                    ToolTip.delay: 350
                                    ToolTip.text: root.trText("transcript_workspace.config_override_tip", "Ghi đè cấu hình riêng cho file này; bấm rồi sửa panel cấu hình bên trái")
                                    Text {
                                        anchors.centerIn: parent
                                        text: root.trText("transcript_workspace.config_override_btn", "Config Override")
                                        color: cardActive ? "#FFFFFF" : VfTheme.violetText
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(10)
                                        font.weight: Font.DemiBold
                                    }
                                    MouseArea {
                                        id: cfgMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: { if (typeof workPanelController !== "undefined") workPanelController.setActiveTranscriptCard(rowCardId) }
                                    }
                                }
                                // Nút "Kịch bản" per-row: điều khiển cách AI hiểu/phân cảnh
                                // lời thoại của ĐÚNG file này (phong cách hình ảnh đã do Style lo).
                                Rectangle {
                                    id: srtAttachBtn
                                    objectName: "work_panel.transcript_srt_attach"
                                    // Policy phụ thuộc Đầu ra:
                                    //  • Ảnh: thiếu SRT → LLM tự chép bắt buộc để khóa nhịp
                                    //  • Video: SRT chỉ là shortcut; mặc định reuse audio URI
                                    readonly property bool hasSrt: String(modelData.srt_path || "").trim().length > 0
                                    readonly property bool autoSrt: !hasSrt && root.imageBranchActive
                                    readonly property string srtName: {
                                        // srt_path có thể là NHIỀU file lẻ nối bằng "\n" (sẽ ghép 1 timeline)
                                        var all = String(modelData.srt_path || "").split("\n").filter(function(x) { return x.trim().length > 0 })
                                        if (all.length === 0) return ""
                                        var p = all[0]
                                        var ix = Math.max(p.lastIndexOf("/"), p.lastIndexOf("\\"))
                                        var first = ix >= 0 ? p.substring(ix + 1) : p
                                        return all.length > 1 ? first + " +" + (all.length - 1) : first
                                    }
                                    Layout.preferredWidth: root.audioSrtActionWidth
                                    Layout.minimumWidth: root.audioSrtActionWidth
                                    Layout.preferredHeight: VfTheme.dp(26)
                                    radius: VfTheme.dp(6)
                                    color: srtAttachBtn.hasSrt ? VfTheme.greenFill
                                         : srtAttachBtn.autoSrt ? VfTheme.cyanFill
                                         : (srtMouse.containsMouse ? VfTheme.greenFill : VfTheme.surface)
                                    border.color: srtAttachBtn.hasSrt ? "#10B981"
                                                : srtAttachBtn.autoSrt ? "#0891B2"
                                                : VfTheme.greenBorderSoft
                                    border.width: 1
                                    ToolTip.visible: srtMouse.containsMouse
                                    ToolTip.delay: 350
                                    ToolTip.text: srtAttachBtn.hasSrt
                                        ? root.trText("transcript_workspace.srt_attached_tip", "SRT: {name} — hệ thống dùng timeline có sẵn làm đường text tăng tốc. Bấm để gỡ.").replace("{name}", srtAttachBtn.srtName)
                                        : root.imageBranchActive
                                            ? root.trText("transcript_workspace.srt_auto_tip", "Đầu ra Ảnh (hoặc Tự động→Ảnh) bắt buộc timeline chính xác: hệ thống tự chép bằng LLM. Audio dài chỉ upload một lần; AI chọn mốc nghỉ rồi chép các đoạn khoảng 30 phút song song và tự ghép/retry. Có SRT sẵn thì bấm để gắn và bỏ qua bước chép.")
                                            : root.trText("transcript_workspace.srt_optional_video_tip", "Đầu ra Video không bắt buộc SRT: hệ thống dùng nhịp clip cố định và tái dùng audio đã upload. Có SRT sẵn thì bấm để dùng đường text tăng tốc.")
                                    Row {
                                        anchors.centerIn: parent
                                        spacing: VfTheme.dp(4)
                                        VfAppIcon {
                                            anchors.verticalCenter: parent.verticalCenter
                                            name: srtAttachBtn.hasSrt ? "check-mark-button" : "clipboard"
                                            size: VfTheme.dp(12); framed: false
                                            color: srtAttachBtn.hasSrt ? "#10B981" : srtAttachBtn.autoSrt ? "#0891B2" : VfTheme.textMuted
                                        }
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: srtAttachBtn.autoSrt ? "SRT·auto" : "SRT"
                                            color: srtAttachBtn.hasSrt ? "#10B981" : srtAttachBtn.autoSrt ? "#0891B2" : VfTheme.textMuted
                                            font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(11); font.weight: Font.DemiBold
                                        }
                                    }
                                    MouseArea {
                                        id: srtMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (srtAttachBtn.hasSrt) {
                                                root.requestAction("work_panel.transcript_card_set_srt", { card_id: rowCardId, srt_path: "" })
                                                return
                                            }
                                            var picked = nativeShell.pickFiles(
                                                root.trText("transcript_workspace.srt_pick_title", "Chọn file phụ đề cho audio này (chọn nhiều file lẻ sẽ tự ghép 1 timeline)"),
                                                "Subtitle (*.srt *.vtt)", "")
                                            if (picked && picked.ok) {
                                                // Nhiều file lẻ → join "\n" (backend ghép thành 1 timeline duy nhất)
                                                var _plist = (picked.paths && picked.paths.length > 0) ? picked.paths : [String(picked.path || "")]
                                                _plist = _plist.filter(function(x) { return String(x || "").trim().length > 0 })
                                                if (_plist.length > 0)
                                                    root.requestAction("work_panel.transcript_card_set_srt", { card_id: rowCardId, srt_path: _plist.join("\n") })
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    objectName: "work_panel.transcript_instruction"   // tour target (per-row script control)
                                    readonly property bool hasNote: String(modelData.instruction || modelData.prompt_note || "").trim().length > 0
                                    Layout.preferredWidth: root.audioScriptActionWidth
                                    Layout.minimumWidth: root.audioScriptActionWidth
                                    Layout.preferredHeight: VfTheme.dp(26)
                                    radius: VfTheme.dp(6)
                                    color: (editMouse.containsMouse || hasNote) ? VfTheme.violetFill : VfTheme.surface
                                    border.color: hasNote ? "#7C3AED" : VfTheme.violetBorderSoft
                                    border.width: 1
                                    ToolTip.visible: editMouse.containsMouse
                                    ToolTip.delay: 350
                                    ToolTip.text: root.trText("transcript_workspace.script_control_tip", "Điều khiển kịch bản cho file này: hướng AI cách hiểu & phân cảnh lời thoại — nhịp, trọng tâm, gộp/tách cảnh, giữ nguyên hay tóm tắt. (Phong cách hình ảnh đã chọn ở Style framework.)")
                                    Row {
                                        anchors.centerIn: parent
                                        spacing: VfTheme.dp(4)
                                        VfAppIcon { anchors.verticalCenter: parent.verticalCenter; name: "memo"; size: VfTheme.dp(13); framed: false; color: VfTheme.violetText }
                                        Text { anchors.verticalCenter: parent.verticalCenter; text: root.trText("transcript_workspace.script_control_short", "Kịch bản"); color: VfTheme.violetText; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(11); font.weight: Font.DemiBold }
                                    }
                                    MouseArea {
                                        id: editMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.selectedAudioCardId = rowCardId
                                            root.requestAction("work_panel.transcript_instruction", {
                                                source: "transcript_audio_list_row",
                                                card_id: rowCardId,
                                                title: root.rowTitle(modelData),
                                                instruction: String(modelData.instruction || modelData.prompt_note || ""),
                                                file_path: String(modelData.local_path || "")
                                            })
                                        }
                                    }
                                }
                                // Xóa file này khỏi danh sách (action per-row)
                                Rectangle {
                                    Layout.preferredWidth: root.audioDeleteActionWidth
                                    Layout.minimumWidth: root.audioDeleteActionWidth
                                    Layout.preferredHeight: VfTheme.dp(26)
                                    radius: VfTheme.dp(6)
                                    color: delMouse.containsMouse ? VfTheme.redFill : VfTheme.surface
                                    border.color: VfTheme.redBorderSoft
                                    border.width: 1
                                    VfAppIcon { anchors.centerIn: parent; name: "cross-mark"; size: VfTheme.dp(13); framed: false; color: VfTheme.redText }
                                    MouseArea {
                                        id: delMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.requestAction("work_panel.transcript_remove_audio_file", { card_id: rowCardId })
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.selectedAudioCardId = parent.rowCardId
                                onDoubleClicked: {
                                    root.selectedAudioCardId = parent.rowCardId
                                    root.requestAction("work_panel.transcript_instruction", {
                                        source: "transcript_audio_list",
                                        card_id: parent.rowCardId,
                                        title: root.rowTitle(modelData),
                                        instruction: String(modelData.instruction || modelData.prompt_note || ""),
                                        file_path: String(modelData.local_path || "")
                                    })
                                }
                            }

                            // Sub-row bé: tóm tắt config file này (đang chỉnh gì) + badge
                            // Riêng/Theo chung → biết file nào đã Config Override (PA1).
                            Row {
                                z: 2
                                anchors.left: parent.left
                                anchors.leftMargin: VfTheme.dp(8)
                                anchors.right: parent.right
                                anchors.rightMargin: VfTheme.dp(8)
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: VfTheme.dp(4)
                                height: VfTheme.dp(15)
                                spacing: VfTheme.dp(6)

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: VfTheme.dp(14)
                                    width: tBadge.implicitWidth + VfTheme.dp(10)
                                    radius: VfTheme.dp(3)
                                    color: cfgSummary.overridden ? "#6366F1" : "transparent"
                                    border.width: 1
                                    border.color: cfgSummary.overridden ? "#6366F1" : VfTheme.blueBorderSoft
                                    Text {
                                        id: tBadge
                                        anchors.centerIn: parent
                                        text: cfgSummary.overridden
                                            ? root.trText("transcript_workspace.cfg_own", "● Riêng")
                                            : root.trText("transcript_workspace.cfg_shared", "Theo chung")
                                        color: cfgSummary.overridden ? "#FFFFFF" : VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(9)
                                    }
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - tBadge.implicitWidth - VfTheme.dp(28)
                                    elide: Text.ElideRight
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9)
                                    text: {
                                        var s = cfgSummary || ({})
                                        var parts = []
                                        parts.push(root.trText("transcript_workspace.cfg_style", "Style") + " " + (s.style || "—"))
                                        parts.push(s.aspect || "16:9")
                                        parts.push(s.quality || "720p")
                                        if (s.model && s.model !== "—") parts.push(s.model)
                                        if (s.char) parts.push(root.trText("transcript_workspace.cfg_char", "Nhân vật"))
                                        if (s.voice) parts.push("Voice")
                                        if (s.language) parts.push(s.language)
                                        return parts.join("   ·   ")
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: audioList.count === 0
                        text: root.trText("transcript_workspace.selected_files", "{count} selected file(s)").replace("{count}", "0")
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.trText("transcript_workspace.selected_files", "{count} selected file(s)").replace("{count}", String(root._audioCards.length))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                elide: Text.ElideRight
            }
        }
    }

    component QueueFrame: Rectangle {
        objectName: "transcriptQueueFrame"
        radius: VfTheme.dp(8)
        color: VfTheme.surface
        border.color: VfTheme.borderBox
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(8)
            spacing: VfTheme.dp(7)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Text {
                    text: root.cleanText(root.trText("transcript_workspace.queue_header", "QUEUE"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Item { Layout.fillWidth: true }

                FlatActionButton { text: root.trText("transcript_workspace.clear_queue_btn", "Clear"); accent: "#EF4444"; minWidth: VfTheme.dp(72); onClicked: root.requestQueueAction("work_panel.clear_queue") }
                FlatActionButton {
                    text: root.queuePaused
                        ? root.trText("transcript_workspace.paused_btn", "Paused")
                        : root.trText("transcript_workspace.pause_btn", "Pause")
                    tooltip: root.trText(
                        "transcript_workspace.pause_submit_tip",
                        "Dừng submit job mới; job đã gửi vẫn tiếp tục chạy.")
                    accent: "#D97706"
                    selected: root.queuePaused
                    enabled: !root.queuePaused
                    minWidth: VfTheme.dp(82)
                    onClicked: root.requestQueueAction("work_panel.pause_queue")
                }
                FlatActionButton {
                    actionId: "work_panel.transcript_skip"
                    text: root.trText("transcript_workspace.skip_btn", "Skip")
                    tooltip: root.trText(
                        "transcript_workspace.skip_tip",
                        "Bỏ qua job đang chạy và chuyển sang job kế tiếp.")
                    accent: "#F59E0B"
                    enabled: root.hasRunningQueueRow()
                    minWidth: VfTheme.dp(72)
                    onClicked: root.requestQueueAction("work_panel.transcript_skip")
                }
                FlatActionButton {
                    actionId: "work_panel.start_queue"
                    text: root.queuePaused
                        ? root.trText("transcript_workspace.continue_btn", "Continue")
                        : root.trText("transcript_workspace.start_btn", "Start")
                    tooltip: root.queuePaused
                        ? root.trText("transcript_workspace.continue_tip", "Mở lại cổng submit và tiếp tục hàng đợi.")
                        : ""
                    selected: true
                    accent: "#3B82F6"
                    minWidth: VfTheme.dp(82)
                    onClicked: root.requestQueueAction("work_panel.start_queue")
                }
            }

            Rectangle {
                id: tJobCard
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(162)
                radius: VfTheme.dp(6)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderStrong

                // Cache 1 lần (cache theo queueRows/selected) cho chip + stepper.
                readonly property var stepInfo: {
                    void root.queueRows
                    void root.selectedQueueRowId
                    return root.activeTranscriptStepInfo()
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    spacing: VfTheme.dp(8)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)

                        Item {
                            id: queueHeaderDot
                            Layout.preferredWidth: VfTheme.dp(12)
                            Layout.preferredHeight: VfTheme.dp(12)
                            Layout.alignment: Qt.AlignVCenter
                            visible: !!root.activeQueueRow()
                            readonly property bool busy: {
                                var r = root.activeQueueRow()
                                if (!r)
                                    return false
                                return ["completed", "complete", "done", "failed", "error"].indexOf(root.rowStatusToken(r)) < 0
                            }
                            readonly property color dotColor: root.activeQueueRow()
                                ? root.rowProgressColor(root.activeQueueRow())
                                : VfTheme.textSubtle

                            Rectangle {
                                anchors.centerIn: parent
                                width: VfTheme.dp(9)
                                height: width
                                radius: width / 2
                                color: "transparent"
                                border.width: Math.max(1, VfTheme.dp(1.5))
                                border.color: queueHeaderDot.dotColor
                                visible: queueHeaderDot.busy
                                SequentialAnimation on scale {
                                    running: queueHeaderDot.busy && VfTheme.motion
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.7; to: 2.0; duration: 1500; easing.type: Easing.OutCubic }
                                    PauseAnimation { duration: 80 }
                                }
                                SequentialAnimation on opacity {
                                    running: queueHeaderDot.busy && VfTheme.motion
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.5; to: 0.0; duration: 1500; easing.type: Easing.OutCubic }
                                    PauseAnimation { duration: 80 }
                                }
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: VfTheme.dp(9)
                                height: width
                                radius: width / 2
                                color: queueHeaderDot.dotColor
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.activeQueueRow()
                                ? root.rowTitle(root.activeQueueRow())
                                : root.trText("transcript_workspace.no_active_job", "No active job")
                            color: root.activeQueueRow() ? VfTheme.text : VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            font.weight: Font.Medium
                            font.italic: !root.activeQueueRow()
                            elide: Text.ElideRight
                        }
                        MiniStat {
                            Layout.preferredWidth: VfTheme.dp(68)
                            Layout.preferredHeight: VfTheme.dp(34)
                            label: root.trText("transcript_workspace.col_scenes", "Cảnh")
                            value: String(Number((root.activeQueueRow() || {}).scene_count || 0))
                        }
                        MiniStat {
                            Layout.preferredWidth: VfTheme.dp(68)
                            Layout.preferredHeight: VfTheme.dp(34)
                            label: root.trText("transcript_workspace.col_videos", "Video")
                            value: String(Number((root.activeQueueRow() || {}).video_count || 0))
                        }

                    }

                    // ── STATUS chip (nổi bật, màu theo pha) — NGAY TRÊN các bước ──
                    Rectangle {
                        id: tStatusChip
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(32)
                        radius: VfTheme.dp(9)
                        readonly property var info: tJobCard.stepInfo
                        readonly property color tone: info.color
                        color: Qt.rgba(tone.r, tone.g, tone.b, 0.12)
                        border.color: Qt.rgba(tone.r, tone.g, tone.b, 0.34)
                        border.width: 1
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(10)
                            anchors.rightMargin: VfTheme.dp(10)
                            spacing: VfTheme.dp(7)
                            VfAppIcon {
                                id: tChipIcon
                                name: tStatusChip.info.icon
                                size: VfTheme.dp(15)
                                framed: false
                                color: tStatusChip.tone
                                Layout.alignment: Qt.AlignVCenter
                                RotationAnimator {
                                    target: tChipIcon
                                    running: tStatusChip.info.indeterminate && tChipIcon.visible && VfTheme.motion
                                    loops: Animation.Infinite
                                    from: 0
                                    to: 360
                                    duration: 1600
                                    onRunningChanged: if (!running) tChipIcon.rotation = 0
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: tStatusChip.info.label
                                color: tStatusChip.tone
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Text {
                                visible: !!root.activeQueueRow()
                                text: root.rowProgressPercent(root.activeQueueRow()) + "%"
                                color: Qt.rgba(tStatusChip.tone.r, tStatusChip.tone.g, tStatusChip.tone.b, 0.8)
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                font.weight: Font.Bold
                            }
                        }
                    }

                    // Stepper 4 bước = pipeline transcript THẬT (Chuẩn bị → Phân tích →
                    // Nhân vật → Video). step lấy từ activeTranscriptStepInfo (đọc
                    // status+charcore_status+step_status), không còn pha "Routing/Merging"
                    // vốn backend KHÔNG phát.
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(4)
                        Repeater {
                            model: [
                                { n: 1, label: root.trText("transcript_workspace.pill_prep", "Chuẩn bị") },
                                { n: 2, label: root.trText("transcript_workspace.pill_analyze", "Phân tích") },
                                { n: 3, label: root.trText("transcript_workspace.pill_chars", "Nhân vật") },
                                { n: 4, label: root.trText("transcript_workspace.pill_video", "Video") }
                            ]
                            delegate: Rectangle {
                                readonly property int stepNo: modelData.n
                                readonly property int cur: tJobCard.stepInfo.step
                                readonly property bool isDone: !tJobCard.stepInfo.failed && cur > stepNo
                                readonly property bool isCurrent: !tJobCard.stepInfo.failed && cur === stepNo
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(22)
                                radius: VfTheme.dp(11)
                                color: isDone ? "#059669"
                                     : isCurrent ? tJobCard.stepInfo.color
                                     : VfTheme.surface
                                border.color: (isDone || isCurrent) ? "transparent" : VfTheme.border
                                border.width: 1
                                Row {
                                    anchors.centerIn: parent
                                    spacing: VfTheme.dp(4)
                                    VfAppIcon {
                                        name: isDone ? "check-mark-button" : ""
                                        size: VfTheme.dp(11)
                                        framed: false
                                        color: "#FFFFFF"
                                        visible: name.length > 0
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.label
                                        color: (isDone || isCurrent) ? "#FFFFFF" : VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(10)
                                        font.weight: (isDone || isCurrent) ? Font.DemiBold : Font.Normal
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }

                    // Thanh tiến độ thật: track bo tròn + fill gradient theo % (animate
                    // mượt) + shimmer quét khi đang chạy để thấy "đang hoạt động".
                    Rectangle {
                        id: progressTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(10)
                        radius: height / 2
                        color: VfTheme.surfaceSoft
                        border.color: root.activeQueueRow() ? VfTheme.blueBorderSoft : VfTheme.borderStrong
                        clip: true

                        Rectangle {
                            id: progressFill
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.margins: 1
                            radius: height / 2
                            visible: !!root.activeQueueRow() && root.rowProgressPercent(root.activeQueueRow()) > 0
                            width: Math.max(0, (progressTrack.width - 2)
                                * (root.rowProgressPercent(root.activeQueueRow()) / 100))
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Qt.lighter(root.rowProgressColor(root.activeQueueRow()), 1.25) }
                                GradientStop { position: 1.0; color: root.rowProgressColor(root.activeQueueRow()) }
                            }
                            Behavior on width { NumberAnimation { duration: 360; easing.type: Easing.OutCubic } }

                            Rectangle {
                                id: progressShimmer
                                width: VfTheme.dp(34)
                                height: parent.height
                                visible: !!root.activeQueueRow() && progressFill.width > width
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.5) }
                                    GradientStop { position: 1.0; color: "transparent" }
                                }
                                SequentialAnimation on x {
                                    running: progressShimmer.visible && VfTheme.motion
                                    loops: Animation.Infinite
                                    NumberAnimation { from: -progressShimmer.width; to: progressFill.width; duration: 1200; easing.type: Easing.InOutSine }
                                    PauseAnimation { duration: 450 }
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.activeQueueRow()
                            ? root.rowProgressMessage(root.activeQueueRow()) || String(root.activeQueueRow().status || "")
                            : root.trText("transcript_workspace.status_idle", "Status: waiting (Idle)...")
                        color: root.activeQueueRow() ? VfTheme.textMuted : VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        font.italic: true
                        elide: Text.ElideRight
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(7)
                color: VfTheme.surface
                border.color: VfTheme.borderBox
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    TableHeader {
                        spacing: root.queueTableSpacing
                        columns: [
                            { label: root.trText("transcript_workspace.table_audio", "Audio"), width: -1, alignRight: false },
                            { label: root.trText("transcript_workspace.table_mode", "Mode"), width: root.queueModeColumnWidth, alignRight: false },
                            { label: root.trText("transcript_workspace.table_aspect", "Aspect"), width: root.queueAspectColumnWidth, alignRight: false },
                            { label: root.trText("transcript_workspace.table_style", "Style"), width: root.queueStyleColumnWidth, alignRight: false },
                            { label: root.trText("transcript_workspace.table_status", "Status"), width: root.queueStatusColumnWidth, alignRight: false },
                            { label: root.trText("transcript_workspace.table_progress", "Progress"), width: root.queueProgressColumnWidth, alignRight: false },
                            { label: root.trText("transcript_workspace.table_segments", "Segments"), width: root.queueSegmentsColumnWidth, alignRight: false },
                            { label: root.trText("transcript_workspace.table_actions", "Actions"), width: root.queueActionsColumnWidth, alignRight: true }
                        ]
                    }

                    ListView {
                        id: queueList
                        objectName: "transcriptQueueList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: workPanelController.queueModel
                        clip: true
                        reuseItems: true

                        delegate: Rectangle {
                            readonly property var qrow: model.qrow
                            property string rowCardId: String(qrow.id || qrow.row_id || qrow.batch_id || "")
                            width: queueList.width
                            height: VfTheme.dp(38)
                            color: root.selectedQueueRowId === rowCardId
                                ? VfTheme.blueFill
                                : (index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft)
                            border.color: root.selectedQueueRowId === rowCardId ? VfTheme.blueBorderSoft : VfTheme.surfaceSoft

                            RowLayout {
                                // Sit ABOVE the row-select MouseArea below (same parent,
                                // declared later → it would otherwise cover the whole row
                                // and swallow the Folder/Delete button clicks). Buttons now
                                // receive clicks; clicks on the empty/Text cells have no
                                // handler here so they fall through to the MouseArea =
                                // row-select still works.
                                z: 1
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(8)
                                anchors.rightMargin: VfTheme.dp(8)
                                spacing: root.queueTableSpacing

                                Text {
                                    Layout.fillWidth: true
                                    text: root.rowTitle(qrow)
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.preferredWidth: root.queueModeColumnWidth
                                    Layout.minimumWidth: root.queueModeColumnWidth
                                    text: root.queueOutputModeLabel(qrow)
                                    color: root.queueOutputModeColor(qrow)
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.preferredWidth: root.queueAspectColumnWidth
                                    Layout.minimumWidth: root.queueAspectColumnWidth
                                    text: String(qrow.aspect || qrow.ratio || "16:9")
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.preferredWidth: root.queueStyleColumnWidth
                                    Layout.minimumWidth: root.queueStyleColumnWidth
                                    text: String(qrow.style_label || (qrow.use_ai_style ? "AI" : "—"))
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.preferredWidth: root.queueStatusColumnWidth
                                    Layout.minimumWidth: root.queueStatusColumnWidth
                                    text: root.rowStatusLabel(qrow)
                                    color: root.rowProgressColor(qrow)
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }
                                Column {
                                    Layout.preferredWidth: root.queueProgressColumnWidth
                                    Layout.minimumWidth: root.queueProgressColumnWidth
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 0
                                    Text {
                                        width: root.queueProgressColumnWidth
                                        text: root.rowProgressPercent(qrow) + "%"
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(10)
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        width: root.queueProgressColumnWidth
                                        text: {
                                            void root.elapsedClockMs
                                            return JobClock.rowElapsedLabel(
                                                qrow,
                                                root.elapsedClockMs,
                                                root.rowStatusToken(qrow)
                                            )
                                        }
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(9)
                                        elide: Text.ElideRight
                                    }
                                }
                                Text {
                                    Layout.preferredWidth: root.queueSegmentsColumnWidth
                                    Layout.minimumWidth: root.queueSegmentsColumnWidth
                                    text: root.rowSegmentsLabel(qrow)
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    elide: Text.ElideRight
                                }
                                RowLayout {
                                    Layout.preferredWidth: root.queueActionsColumnWidth
                                    Layout.minimumWidth: root.queueActionsColumnWidth
                                    Layout.maximumWidth: root.queueActionsColumnWidth
                                    Layout.alignment: Qt.AlignRight
                                    spacing: VfTheme.dp(4)
                                    Item { Layout.fillWidth: true }
                                    FlatActionButton {
                                        text: root.trText("transcript_workspace.folder_btn", "Folder")
                                        actionId: "job_panel.open_folder"
                                        minWidth: VfTheme.dp(54)
                                        contentPadding: VfTheme.dp(10)
                                        accent: "#2563EB"
                                        onClicked: root.requestAction("job_panel.open_folder", {
                                            row_id: String(qrow.id || qrow.row_id || qrow.batch_id || ""),
                                            source: "transcript_queue_row"
                                        })
                                    }
                                    FlatActionButton {
                                        text: root.trText("transcript_workspace.delete_btn", "Delete")
                                        actionId: "work_panel.queue_delete_row"
                                        tooltip: root.trText("transcript_workspace.delete_btn", "Delete")
                                        iconOnly: true
                                        minWidth: VfTheme.dp(34)
                                        accent: "#EF4444"
                                        onClicked: root.requestRemoveQueueRow(String(qrow.id || qrow.row_id || qrow.batch_id || ""))
                                    }
                                }
                            }

                            MouseArea {
                                z: 0
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                onClicked: {
                                    root.selectedQueueRowId = parent.rowCardId
                                    root.requestAction("work_panel.transcript_select_queue_row", {
                                        row_id: parent.rowCardId,
                                        source: "transcript_queue_row_select"
                                    })
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: queueList.count === 0
                        text: root.trText("transcript_workspace.empty_queue", "No queue rows yet.")
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    component PhaseChip: Rectangle {
        id: phaseChip
        property string text: ""
        property bool active: false
        property bool complete: false
        radius: height / 2
        implicitHeight: VfTheme.dp(26)
        color: phaseChip.active ? VfTheme.blueFill : (phaseChip.complete ? VfTheme.greenFill : VfTheme.surfaceSoft)
        border.width: 1
        border.color: phaseChip.active ? VfTheme.blueBorder : (phaseChip.complete ? VfTheme.greenBorderSoft : VfTheme.border)

        // Vòng glow nhịp nhàng khi pha đang chạy.
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: VfTheme.blueBorder
            visible: phaseChip.active
            opacity: 0
            SequentialAnimation on opacity {
                running: phaseChip.active && VfTheme.motion
                loops: Animation.Infinite
                NumberAnimation { from: 0.0; to: 0.75; duration: 800; easing.type: Easing.InOutSine }
                NumberAnimation { from: 0.75; to: 0.0; duration: 800; easing.type: Easing.InOutSine }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: VfTheme.dp(6)

            Item {
                width: VfTheme.dp(13)
                height: VfTheme.dp(13)
                anchors.verticalCenter: parent.verticalCenter

                // Done → vòng xanh + dấu ✓.
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    visible: phaseChip.complete
                    color: VfTheme.greenBorder
                    Text {
                        anchors.centerIn: parent
                        text: "✓"
                        color: "#FFFFFF"
                        font.pixelSize: VfTheme.dp(9)
                        font.weight: Font.Bold
                    }
                }

                // Active → chấm xanh nhấp nháy.
                Rectangle {
                    anchors.centerIn: parent
                    width: VfTheme.dp(9)
                    height: width
                    radius: width / 2
                    visible: phaseChip.active
                    color: VfTheme.primary
                    SequentialAnimation on opacity {
                        running: phaseChip.active && VfTheme.motion
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.3; duration: 650; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 0.3; to: 1.0; duration: 650; easing.type: Easing.InOutSine }
                    }
                }

                // Idle → chấm rỗng mờ.
                Rectangle {
                    anchors.centerIn: parent
                    width: VfTheme.dp(9)
                    height: width
                    radius: width / 2
                    visible: !phaseChip.active && !phaseChip.complete
                    color: "transparent"
                    border.width: 1
                    border.color: VfTheme.borderStrong
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: phaseChip.text
                color: phaseChip.active ? VfTheme.blueText : (phaseChip.complete ? VfTheme.greenText : VfTheme.textSubtle)
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: phaseChip.active || phaseChip.complete ? Font.DemiBold : Font.Normal
            }
        }
    }

    component CharacterOptions: Rectangle {
        radius: VfTheme.dp(8)
        color: VfTheme.violetFill
        border.color: VfTheme.violetBorderSoft
        implicitHeight: characterOptionsLayout.implicitHeight + 14
        clip: true

        ColumnLayout {
            id: characterOptionsLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: VfTheme.dp(7)
            spacing: VfTheme.dp(7)

            CharacterConsistencyPanel {
                Layout.fillWidth: true
                charMode: root.charMode
                scopeCategories: root.libraryPolicyCategoryList()
                scopePolicies: root.buildLibraryPolicy().scopes
                characters: root.selectedCharacters || []
                objects: root.selectedObjects || []
                backgrounds: root.selectedBackgrounds || []
                allowObjectSelection: true
                allowBackgroundSelection: true
                onScopeToggled: function(category, enabled) { root.setLibraryCategoryEnabled(category, enabled) }
                onScopePolicyChanged: function(category, key, value) { root.saveLibraryPolicy(category, key, value) }
                onAddRequested: root.openCharacterLibrary()
                onAddObjectsRequested: root.openObjectLibrary()
                onAddBackgroundsRequested: root.openBackgroundLibrary()
                onClearRequested: {
                    root.requestAction("work_panel.transcript_clear_characters", { source: "transcript_character_options" })
                    if (typeof workPanelController !== "undefined") {
                        workPanelController.setRouteLibraryAssetSelection("objects", { mediaIds: [] }, workPanelController.mediaLibraryItems || [])
                        workPanelController.setRouteLibraryAssetSelection("backgrounds", { mediaIds: [] }, workPanelController.mediaLibraryItems || [])
                    }
                }
                onMoveRequested: function(mediaId, offset) { workPanelController.moveRouteCharacterSelection(mediaId, offset) }
                onRemoveRequested: function(mediaId) { workPanelController.removeRouteCharacterSelection(mediaId) }
                onRemoveObjectRequested: function(mediaId) { workPanelController.removeRouteLibraryAssetSelection("objects", mediaId) }
                onRemoveBackgroundRequested: function(mediaId) { workPanelController.removeRouteLibraryAssetSelection("backgrounds", mediaId) }
            }
        }
    }

    // Lazy: build the heavy MediaLibraryDialog tree only on first open, not during the
    // background route preload — eager off-screen build flooded the render thread
    // ("Cannot find member data") and crashed Qt6Qml. Matches App.qml's header pattern.
    Loader {
        id: transcriptCharacterLibraryDialogLoader
        active: false
        sourceComponent: MediaLibraryDialog {
            id: transcriptCharacterLibraryDialog
            parent: Overlay.overlay
            mode: "select"
            appendSelection: true
            maxSelection: 12
            filterType: "character"
            items: (visible && typeof workPanelController !== "undefined") ? workPanelController.mediaLibraryItems : []
            stats: typeof workPanelController !== "undefined" ? workPanelController.mediaLibraryStats : ({})
            settings: typeof workPanelController !== "undefined" ? workPanelController.mediaLibrarySettings : ({})
            onRefreshRequested: (search, assetType) => {
                if (typeof workPanelController !== "undefined")
                    workPanelController.refreshMediaLibrary(search || "", assetType || "")
            }
            onMediaSelected: selection => {
                var result
                if (typeof workPanelController === "undefined") {
                    result = {
                        ok: false,
                        blocked: true,
                        message: "Media library controller is unavailable."
                    }
                } else {
                    result = workPanelController.setRouteCharacterSelection(
                        selection || ({}),
                        workPanelController.mediaLibraryItems || []
                    )
                }
                transcriptCharacterLibraryDialog.applySelectionResult(result)
            }
        }
    }

    Loader {
        id: transcriptObjectLibraryDialogLoader
        active: false
        sourceComponent: MediaLibraryDialog {
            id: transcriptObjectLibraryDialog
            parent: Overlay.overlay
            mode: "select"
            appendSelection: true
            maxSelection: 12
            filterType: "object"
            items: (visible && typeof workPanelController !== "undefined") ? workPanelController.mediaLibraryItems : []
            stats: typeof workPanelController !== "undefined" ? workPanelController.mediaLibraryStats : ({})
            settings: typeof workPanelController !== "undefined" ? workPanelController.mediaLibrarySettings : ({})
            onRefreshRequested: (search, assetType) => {
                if (typeof workPanelController !== "undefined")
                    workPanelController.refreshMediaLibrary(search || "", assetType || "")
            }
            onMediaSelected: selection => {
                var result
                if (typeof workPanelController === "undefined") {
                    result = {
                        ok: false,
                        blocked: true,
                        message: "Media library controller is unavailable."
                    }
                } else {
                    result = workPanelController.setRouteLibraryAssetSelection(
                        "objects",
                        selection || ({}),
                        workPanelController.mediaLibraryItems || []
                    )
                }
                transcriptObjectLibraryDialog.applySelectionResult(result)
            }
        }
    }

    Loader {
        id: transcriptBackgroundLibraryDialogLoader
        active: false
        sourceComponent: MediaLibraryDialog {
            id: transcriptBackgroundLibraryDialog
            parent: Overlay.overlay
            mode: "select"
            appendSelection: true
            maxSelection: 12
            filterType: "background"
            items: (visible && typeof workPanelController !== "undefined") ? workPanelController.mediaLibraryItems : []
            stats: typeof workPanelController !== "undefined" ? workPanelController.mediaLibraryStats : ({})
            settings: typeof workPanelController !== "undefined" ? workPanelController.mediaLibrarySettings : ({})
            onRefreshRequested: (search, assetType) => {
                if (typeof workPanelController !== "undefined")
                    workPanelController.refreshMediaLibrary(search || "", assetType || "")
            }
            onMediaSelected: selection => {
                var result
                if (typeof workPanelController === "undefined") {
                    result = {
                        ok: false,
                        blocked: true,
                        message: "Media library controller is unavailable."
                    }
                } else {
                    result = workPanelController.setRouteLibraryAssetSelection(
                        "backgrounds",
                        selection || ({}),
                        workPanelController.mediaLibraryItems || []
                    )
                }
                transcriptBackgroundLibraryDialog.applySelectionResult(result)
            }
        }
    }

    component AssetActionButton: Rectangle {
        property string label: ""
        property string tooltip: ""
        property string tone: "neutral"

        signal clicked()

        width: VfTheme.dp(22)
        height: VfTheme.dp(22)
        radius: VfTheme.dp(11)
        color: tone === "danger" ? VfTheme.redFill : VfTheme.surface
        border.color: tone === "danger" ? VfTheme.redBorderSoft : VfTheme.violetBorderSoft
        border.width: 1

        ToolTip.visible: actionMouseArea.containsMouse && tooltip.length > 0
        ToolTip.text: tooltip

        Text {
            anchors.centerIn: parent
            text: parent.label
            color: tone === "danger" ? "#DC2626" : "#7C3AED"
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            font.weight: Font.DemiBold
        }

        MouseArea {
            id: actionMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component TextLabel: Text {
        color: VfTheme.textMuted
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(11)
        font.weight: Font.Bold
        verticalAlignment: Text.AlignVCenter
        height: VfTheme.dp(28)
    }

    component SpacerDot: Rectangle {
        width: 1
        height: VfTheme.dp(26)
        radius: 1
        color: VfTheme.border
    }

    component SegmentButton: Rectangle {
        id: segment
        property string text: ""
        property string actionId: ""
        property string tooltip: ""
        property bool selected: false
        property color accent: VfTheme.primary
        property int minWidth: VfTheme.dp(80)
        signal clicked()

        // implicitWidth/Height (not width/height) so the button sizes correctly
        // inside BOTH a Flow (feature bar) and a RowLayout (action rows) — a
        // Layout ignores width: and would collapse/overlap the buttons.
        implicitWidth: Math.max(minWidth, segmentRow.implicitWidth + 28)
        implicitHeight: VfTheme.dp(34)
        radius: VfTheme.dp(7)
        opacity: segment.enabled ? 1.0 : 0.55
        color: selected && segment.enabled ? accent : VfTheme.surface
        border.width: 1
        border.color: selected && segment.enabled ? accent : VfTheme.borderSoft

        readonly property string _tooltip: AppIconRegistry.resolveActionTooltip(segment.actionId, segment.tooltip, root.cleanText(segment.text))
        ToolTip.visible: segmentMouse.containsMouse && segment._tooltip.length > 0
        ToolTip.text: segment._tooltip
        ToolTip.delay: 350

        Row {
            id: segmentRow
            anchors.centerIn: parent
            spacing: VfTheme.dp(5)

            VfAppIcon {
                id: segmentIcon
                name: AppIconRegistry.resolveActionIcon(segment.actionId, root.cleanText(segment.text), "")
                size: VfTheme.dp(16)
                framed: false
                visible: name.length > 0
                anchors.verticalCenter: parent.verticalCenter
                color: !segment.enabled ? VfTheme.textSubtle : (segment.selected ? "#FFFFFF" : (AppIconRegistry.iconColor(segmentIcon.name) || VfTheme.text))
            }

            Text {
                id: segmentLabel
                text: root.cleanText(segment.text)
                color: !segment.enabled ? VfTheme.textSubtle : (selected ? "#FFFFFF" : VfTheme.text)
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: segmentMouse
            anchors.fill: parent
            enabled: segment.enabled
            hoverEnabled: true
            cursorShape: segment.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: segment.clicked()
        }
    }

    component TogglePill: SegmentButton {
        selected: false
        minWidth: VfTheme.dp(112)
    }

    component FlatActionButton: Rectangle {
        id: flat
        property string text: ""
        property string actionId: ""
        property string tooltip: ""
        property bool selected: false
        property bool iconOnly: false
        property color accent: VfTheme.primary
        property int minWidth: VfTheme.dp(80)
        property int contentPadding: VfTheme.dp(28)
        signal clicked()

        implicitWidth: iconOnly ? minWidth : Math.max(minWidth, flatRow.implicitWidth + contentPadding)
        implicitHeight: VfTheme.dp(34)
        radius: VfTheme.dp(7)
        color: selected ? accent : VfTheme.surface
        border.width: 1
        border.color: selected ? accent : VfTheme.borderSoft

        readonly property string _tooltip: AppIconRegistry.resolveActionTooltip(flat.actionId, flat.tooltip, root.cleanText(flat.text))
        ToolTip.visible: flatMouse.containsMouse && flat._tooltip.length > 0
        ToolTip.text: flat._tooltip
        ToolTip.delay: 350

        Row {
            id: flatRow
            anchors.centerIn: parent
            spacing: VfTheme.dp(5)

            VfAppIcon {
                id: flatIcon
                name: AppIconRegistry.resolveActionIcon(flat.actionId, root.cleanText(flat.text), "")
                size: VfTheme.dp(16)
                framed: false
                visible: name.length > 0
                anchors.verticalCenter: parent.verticalCenter
                color: !flat.enabled ? VfTheme.textSubtle : (flat.selected ? "#FFFFFF" : flat.accent)
            }

            Text {
                id: label
                visible: !flat.iconOnly
                text: root.cleanText(flat.text)
                color: flat.selected ? "#FFFFFF" : flat.accent
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: flatMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: flat.clicked()
        }
    }

    component MiniStat: Rectangle {
        property string label: ""
        property string value: ""

        width: VfTheme.dp(74)
        height: VfTheme.dp(34)
        radius: VfTheme.dp(6)
        color: VfTheme.surface
        border.color: VfTheme.border

        Column {
            anchors.centerIn: parent
            spacing: 0
            Text { text: value; color: VfTheme.primary; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(12); font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter; width: VfTheme.dp(66); elide: Text.ElideRight }
            Text { text: label; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(9); horizontalAlignment: Text.AlignHCenter; width: VfTheme.dp(66); elide: Text.ElideRight }
        }
    }

    component TableHeader: Rectangle {
        property var columns: []
        property real spacing: VfTheme.dp(6)

        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(26)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.border

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(8)
            anchors.rightMargin: VfTheme.dp(8)
            spacing: parent.spacing

            Repeater {
                model: columns

                Text {
                    Layout.fillWidth: modelData.width < 0
                    Layout.preferredWidth: modelData.width > 0 ? modelData.width : 1
                    Layout.minimumWidth: modelData.width > 0 ? modelData.width : 0
                    text: modelData.label
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    font.weight: Font.Bold
                    horizontalAlignment: modelData.alignRight ? Text.AlignRight : Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }
    }
}
