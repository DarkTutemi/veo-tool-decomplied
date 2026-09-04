import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../dialogs"
import "../theme"
import "AppIconRegistry.js" as AppIconRegistry
import "JobClock.js" as JobClock
import "MediaSourceResolver.js" as MediaSourceResolver
import "LibraryPolicy.js" as LibraryPolicy

Rectangle {
    id: root
    objectName: "cloneWorkspace"

    property var meta: ({})
    property var cards: []
    property var cardModel: null
    property var queueRows: []
    property var stats: ({})
    // Có "danh sách công việc" (queue có job) hay không → gate các nút Xóa/Dừng/Bỏ qua/Clone.
    readonly property bool hasWorkList: (root.stats ? (root.stats.total || 0) : 0) > 0
                                        || (root.queueRows || []).length > 0
    property var routeConfig: ({})
    property var selectedCharacters: typeof workPanelController !== "undefined" ? workPanelController.selectedRouteCharacters : []
    property var selectedVoices: typeof workPanelController !== "undefined" ? workPanelController.selectedCloneVoices : []
    property var selectedObjects: typeof workPanelController !== "undefined" ? workPanelController.selectedCloneObjects : []
    property var selectedBackgrounds: typeof workPanelController !== "undefined" ? workPanelController.selectedCloneBackgrounds : []
    property bool authPauseRequired: typeof workPanelController !== "undefined" ? workPanelController.cloneAuthPauseRequired : false
    property bool noLiveAccountsPauseRequired: typeof workPanelController !== "undefined" ? workPanelController.cloneNoLiveAccountsPauseRequired : false
    property var flowVoiceOptions: typeof workPanelController !== "undefined" ? workPanelController.cloneFlowVoiceOptions : []
    property int flowVoiceReferenceLimit: typeof workPanelController !== "undefined" ? workPanelController.cloneFlowVoiceReferenceLimit : 0
    property bool flowVoiceReferencesSupported: typeof workPanelController !== "undefined" ? workPanelController.cloneFlowVoiceReferencesSupported : false
    property bool flowVoiceLockSupported: typeof workPanelController !== "undefined" ? workPanelController.cloneFlowVoiceLockSupported : false
    property var audioVoiceOptions: typeof workPanelController !== "undefined" ? workPanelController.cloneAudioVoiceOptions : []
    property var audioModelOptions: typeof workPanelController !== "undefined" ? workPanelController.cloneAudioModelOptions : []
    property var audioPresetOptions: typeof workPanelController !== "undefined" ? workPanelController.cloneAudioPresetOptions : []
    property string selectedQueueRowId: ""
    property string observedMarketCode: ""
    property bool compact: width < 1120
    property string videoFilter: "all"
    property string creativeMode: "original"
    // Recipe chips (19/7): giá trị chip lưu ở config.remix_recipe (object), ghi chú
    // tay ở config.remix_notes; backend tự ghép thành remix_instructions.
    property var remixRecipe: ({})
    property string remixNotes: ""
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
    property string remixInstructions: ""
    property int clipDurationSeconds: 8
    property string outputMode: "auto"
    property string narrationPolicy: "auto"
    property string imageMotionMode: "off"
    property string imageMotionHandAsset: "auto"
    property bool frameSlicingEnabled: false
    property bool consistencyPanelExpanded: false
    property bool flowVoiceLockEnabled: false
    property bool autoExtendEnabled: false
    property bool autoMergeEnabled: true
    property bool creativeAutosaveEnabled: true
    property bool autoNextEnabled: true
    property bool autoAddEnabled: true
    property bool uploadDropActive: false
    property string pendingCloneAutoFetchText: ""
    property int queueAreaHeight: Math.max(250, Math.round(height * 0.38))
    // Date.now() is epoch-ms (~1.7e12); QML `int` is int32 and clamps → clock stuck at 0s.
    property double elapsedClockMs: Date.now()
    property double clockStartMs: 0
    signal addCardsRequested(string text)
    signal addBlankRequested()
    signal bulkImportRequested()
    signal submitAllRequested()
    signal clearQueueRequested()
    signal startQueueRequested()
    signal pauseQueueRequested()
    signal historyRequested()
    signal routeToolRequested(string action)
    signal removeQueueRowRequested(string rowId)
    signal selectedQueueRowChanged(string rowId)
    signal actionRequested(string actionId, var payload)

    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "transparent"
    // implicitHeight bám theo content thật để khi char panel mở ra, vùng cha
    // (WorkPanelWorkspace → ScrollView) grow + scroll được, không khoá layout.
    implicitHeight: Math.max(VfTheme.dp(820), cloneMainColumn.implicitHeight + VfTheme.dp(16))

    function metaText(key, fallback) {
        if (root.meta && root.meta[key] !== undefined && root.meta[key] !== null && String(root.meta[key]).length > 0)
            return String(root.meta[key])
        return fallback || ""
    }

    function openSubtitleStudio() {
        var cloneContext = root.routeConfig || ({})
        var recipeText = String(
            (root.remixRecipe || ({}))[root.primaryRecipeKey]
            || root.metaText("description", "")
            || root.metaText("prompt", ""))
        subtitleStudioController.openForRoute(
            "clone",
            cloneContext.subtitle_profile || ({}),
            {
                market: String(cloneContext.market || "global"),
                content_language: String(cloneContext.voice_language || cloneContext.language || "vi"),
                aspect_ratio: String(cloneContext.aspect_ratio || cloneContext.ratio || "16:9"),
                title: root.metaText("title", recipeText.split("\n")[0]),
                idea: recipeText,
                script: String(
                    cloneContext.script || cloneContext.script_text
                    || root.metaText("transcript", "")
                    || root.metaText("script", "")
                    || root.metaText("subtitle_text", "")),
                tone: String(cloneContext.tone || cloneContext.emotion || ""),
                platform: String(
                    cloneContext.platform
                    || root.cloneInputPlatform(root.pendingCloneAutoFetchText)
                    || "auto"),
                content_tags: cloneContext.content_tags || [],
                inherited: true
            })
    }

    function trText(key, fallback) {
        var value = String((void i18n.revision, i18n.t(key, fallback || "")) || "")
        return value === key ? (fallback || "") : value
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
            if (text.indexOf("ð") === 0 || text.indexOf("ï") === 0 || text.indexOf("â") === 0) {
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
        if (!row) return ""
        if (row.name) return String(row.name)
        if (row.title) return String(row.title)
        if (row.prompt) return String(row.prompt)
        if (row.url) return String(row.url)
        if (row.local_path) return String(row.local_path)
        return String(row.id || row.row_id || row.batch_id || "")
    }

    function optionIndex(options, value) {
        var items = options || []
        for (var i = 0; i < items.length; i++) {
            if (String(items[i].value) === String(value))
                return i
        }
        return items.length > 0 ? 0 : -1
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

    function cardId(row) {
        if (!row)
            return ""
        return String(row.id || row.row_id || row.batch_id || "")
    }

    function requestAction(actionId, payload) {
        var data = {
            action_id: actionId,
            route: "clone"
        }
        for (var key in payload || ({}))
            data[key] = payload[key]
        root.actionRequested(actionId, data)
        return data
    }

    function requestAddCards(text) {
        root.requestAction("work_panel.add_from_text", {
            text: text,
            source: "clone_url_input"
        })
        root.addCardsRequested(text)
    }

    function requestAddBlank(source) {
        root.requestAction("work_panel.add_blank", {
            source: source || "clone_toolbar"
        })
        root.addBlankRequested()
    }

    function requestBulkImport() {
        root.requestAction("work_panel.bulk_import", { source: "clone_toolbar" })
        root.bulkImportRequested()
    }

    function requestRouteTool(action, actionId, payload) {
        var data = {
            source: "clone_route_tool",
            route_tool: action
        }
        for (var key in payload || ({}))
            data[key] = payload[key]
        root.requestAction(actionId, data)
        root.routeToolRequested(action)
    }

    function cloneInputPlatform(text) {
        var lines = String(text || "").split(/\r?\n/)
        for (var i = 0; i < lines.length; i += 1) {
            var line = String(lines[i] || "").trim().toLowerCase()
            if (line.length === 0)
                continue
            if (line.indexOf("tiktok.com") >= 0 || line.indexOf("douyin.com") >= 0)
                return "tiktok"
            if (line.indexOf("instagram.com") >= 0)
                return "instagram"
            if (line.indexOf("facebook.com") >= 0 || line.indexOf("fb.watch") >= 0)
                return "facebook"
            if (line.indexOf("youtube.com") >= 0 || line.indexOf("youtu.be") >= 0 || line.indexOf("@") === 0)
                return "youtube"
            if (line.indexOf("http://") === 0 || line.indexOf("https://") === 0)
                return "generic"
        }
        return ""
    }

    // inputText được truyền từ TextArea (id cloneUrlInput sống trong component
    // SourceFrame nên hàm root này KHÔNG with tay vào id được — sẽ ReferenceError).
    function _on_tiktok_input_changed(inputText) {
        cloneAutoFetchTimer.stop()
        var text = String(inputText || "").trim()
        var previous = String(root.pendingCloneAutoFetchText || "")
        root.pendingCloneAutoFetchText = text
        var platform = root.cloneInputPlatform(text)
        if (text.length === 0 || platform.length === 0)
            return
        // Spec A3 (docs/CLONE_INPUT_GATE_SPEC.md): text nhảy cả cụm = dán link → fetch
        // gần như ngay; gõ tay từng phím → debounce ngắn. Fetch sớm trên URL dở dang
        // vô hại: seq guard huỷ nó ngay khi user gõ tiếp.
        var pasted = text.length - previous.length > 8
        cloneAutoFetchTimer.interval = pasted ? 150 : 800
        cloneAutoFetchTimer.start()
    }

    // ── Recipe: mỗi mode 1 Ô CHÍNH mô tả tự do (20/7: BỎ bộ chip cố định —
    // video nào knob nấy; chip per-video là kết quả của nút "AI gợi ý").
    readonly property string primaryRecipeKey: creativeMode === "original" ? "copy_focus"
                                             : creativeMode === "remix" ? "direction"
                                             : creativeMode === "creative" ? "topic"
                                             : creativeMode === "series" ? "situation" : ""

    function recipeChipLabel(key) {
        void i18n.revision
        if (key === "copy_focus") return root.trText("clone.recipe_copy_focus_label", "Yêu cầu ưu tiên khi sao chép")
        if (key === "direction") return root.trText("clone.recipe_direction_label", "Muốn đổi gì ở video này?")
        if (key === "topic") return root.trText("clone.recipe_topic_label", "Chủ đề video mới")
        if (key === "situation") return root.trText("clone.recipe_situation_label", "Tình huống tập mới")
        return String(key || "")
    }

    function recipeChipPlaceholder(key) {
        void i18n.revision
        if (key === "copy_focus") return root.trText("clone.recipe_copy_focus_ph", "Không bắt buộc · ví dụ: ưu tiên giữ nguyên lời thoại, nhịp dựng và góc máy...")
        if (key === "direction") return root.trText("clone.recipe_direction_ph", "Không bắt buộc · ví dụ: đổi nhân vật thành mèo hoạt hình, bối cảnh Sài Gòn, style anime...")
        if (key === "topic") return root.trText("clone.recipe_topic_ph", "Không bắt buộc · ví dụ: mèo mập tập gym, review quán phở, mẹo tiết kiệm điện...")
        if (key === "situation") return root.trText("clone.recipe_situation_ph", "Không bắt buộc · ví dụ: cả nhóm đi cắm trại và gặp mưa bất chợt...")
        return ""
    }

    function recipeModeExplanation() {
        void i18n.revision
        if (root.creativeMode === "original")
            return root.trText(
                "clone.recipe_copy_explain",
                "AI tái tạo sát nội dung, lời thoại, hình ảnh và nhịp của video gốc. Chỉ nhập nếu có điểm cần ưu tiên.")
        if (root.creativeMode === "creative")
            return root.trText(
                "clone.recipe_creative_explain",
                "AI học hook, cấu trúc, nhịp và cảm xúc của video gốc để viết một câu chuyện mới. Có thể nhập chủ đề mong muốn.")
        if (root.creativeMode === "series")
            return root.trText(
                "clone.recipe_series_explain",
                "AI giữ nguyên dàn nhân vật, thế giới và chemistry để viết tập tiếp theo. Có thể nhập tình huống mới.")
        return root.trText(
            "clone.recipe_remix_explain",
            "AI giữ cốt truyện, nhịp và ý nghĩa lời thoại rồi tự chọn cách đổi nhân vật, bối cảnh và phong cách. Có thể chỉ định hướng đổi.")
    }

    function setRecipeValue(key, value) {
        var current = String((root.remixRecipe || ({}))[key] || "")
        if (current === String(value || ""))
            return
        var next = {}
        var source = root.remixRecipe || ({})
        for (var k in source)
            next[k] = source[k]
        next[key] = String(value || "")
        root.remixRecipe = next
    }

    function queuePrimaryRecipeUpdate(value) {
        var key = root.primaryRecipeKey
        if (!key.length)
            return
        var nextValue = String(value || "")
        var current = String((root.remixRecipe || ({}))[key] || "")
        if (current === nextValue)
            return
        root.setRecipeValue(key, nextValue)
        primaryRecipeDebounce.pendingKey = key
        primaryRecipeDebounce.pendingValue = nextValue
        primaryRecipeDebounce.restart()
    }

    function overrideCardTitle() {
        var acid = (typeof workPanelController !== "undefined")
            ? String(workPanelController.activeCloneCardId || "") : ""
        if (!acid)
            return ""
        var cs = root.cards || []
        for (var i = 0; i < cs.length; i++) {
            if (String(cs[i].id || "") === acid)
                return String(cs[i].title || cs[i].url || cs[i].prompt || acid)
        }
        return acid
    }

    function overrideCardSummary() {
        if (typeof workPanelController === "undefined")
            return ""
        void workPanelController.activeCloneCardId
        void workPanelController.currentRouteConfig
        var acid = String(workPanelController.activeCloneCardId || "")
        if (!acid)
            return ""
        var s = workPanelController.cloneCardConfigSummary(acid) || ({})
        var parts = []
        if (s.model && s.model !== "—") parts.push(s.model)
        parts.push(root.trText("clone.cfg_style", "Style") + " " + (s.style || "—"))
        parts.push(s.aspect || "16:9")
        parts.push(s.quality || "720p")
        if (s.char) parts.push(root.trText("clone.cfg_char", "Nhân vật"))
        if (s.voice) parts.push("Voice")
        if (s.language) parts.push(s.language)
        return parts.join("   ·   ")
    }

    function requestQueueAction(actionId) {
        root.requestAction(actionId, { source: "clone_queue_toolbar" })
        if (actionId === "work_panel.submit_all")
            root.submitAllRequested()
        else if (actionId === "work_panel.pause_queue")
            root.pauseQueueRequested()
        else if (actionId === "work_panel.clear_queue")
            root.clearQueueRequested()
        else if (actionId === "work_panel.start_queue")
            root.startQueueRequested()
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
            return root.trText("clone.no_characters_selected", "No library characters selected yet. Open Characters to choose reusable people/assets.")
        return root.trText("master.characters_selected", "{count} library character(s) selected")
            .replace("{count}", String(items.length))
    }

    function libraryPolicyCategoryList() {
        var items = root.libraryPolicyCategories || []
        var out = []
        for (var i = 0; i < items.length; i += 1) {
            var value = String(items[i] || "")
            if (value.length > 0 && out.indexOf(value) < 0)
                out.push(value)
        }
        return out
    }

    function libraryCategoryEnabled(category) {
        return root.libraryPolicyCategoryList().indexOf(String(category || "")) >= 0
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
            "source_role_binding_exact_ids",
            overrideCategory, overrideKey, overrideValue)
    }

    function saveLibraryPolicy(overrideCategory, overrideKey, overrideValue) {
        // char_mode chỉ còn là compatibility field cho backend cũ. Toàn bộ ý
        // định thật nằm trong policy matrix theo từng category.
        root.charMode = "hybrid"
        root.libraryPolicy = root.buildLibraryPolicy(overrideCategory, overrideKey, overrideValue)
        root.libraryPolicyCategories = root.libraryPolicy.categories || []
        root.requestAction("work_panel.clone_library_policy", {
            char_mode: root.charMode,
            categories: root.libraryPolicyCategories,
            library_policy: root.libraryPolicy,
            source: "clone_library_policy"
        })
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

    function selectedLibraryAssetSummary(items, emptyText, countText) {
        var list = items || []
        if (list.length <= 0)
            return emptyText
        return countText.replace("{count}", String(list.length))
    }

    function selectedVoiceIds() {
        var out = []
        var items = root.selectedVoices || []
        for (var i = 0; i < items.length; i += 1) {
            var mediaId = String(items[i].media_id || items[i].id || "")
            if (mediaId.length > 0)
                out.push(mediaId)
        }
        return out
    }

    function selectedVoiceDisplayName(asset) {
        var item = asset || {}
        return String(item.name || item.title || item.label || item.media_id || item.id || "")
    }

    function selectedVoiceCardSummary(asset) {
        var item = asset || {}
        var targetSpeaker = String(item.target_speaker || "")
        var text = root.cleanText(item.description || item.summary || item.caption || "")
        if (targetSpeaker.length > 0 && text.length > 0)
            return targetSpeaker + " • " + text
        if (targetSpeaker.length > 0)
            return root.trText("clone.voice_target_summary", "Target speaker: {name}").replace("{name}", targetSpeaker)
        if (text.length > 0)
            return text
        return root.trText("clone.voice_reference_card_fallback", "Flow voice reference ready for clone scenes.")
    }

    function flowVoiceLockHint() {
        if (!root.characterConsistencyActive())
            return root.trText("clone.voice_lock_requires_char_scope", "Chọn AI tạo, AI + Thư viện hoặc Chỉ Thư viện cho Nhân vật trước.")
        if (!root.flowVoiceLockSupported)
            return root.trText("clone.voice_lock_model_unsupported", "Current model/aspect/clip setup does not support Flow voice lock.")
        return root.trText("clone.voice_lock_ready", "Flow voice lock will send character voice/entity specs instead of plain voice reference ids.")
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
        var label = root.trText("clone.consistency_short", "Đồng nhất")
        var count = root.consistencyActiveCount()
        var state = count > 0 ? (" " + String(count) + "/3") : ": " + root.trText("clone.consistency_off", "Tắt")
        return label + state + (root.consistencyPanelExpanded ? "  ▴" : "  ▾")
    }

    function consistencyDisclosureTooltip() {
        var count = root.consistencyActiveCount()
        if (count <= 0)
            return root.trText("clone.consistency_all_off_tip", "Đồng nhất đang tắt cho cả nhân vật, đồ vật và bối cảnh. Nhấn để cấu hình.")
        return root.trText("clone.consistency_active_tip", "Đang bật {count}/3 nhóm đồng nhất. Nhấn để cấu hình.")
            .replace("{count}", String(count))
    }

    function characterConsistencyActive() {
        return root.consistencySource("characters") !== "disabled"
    }

    function voiceTargetOptions() {
        var options = [
            {
                text: root.trText("clone.voice_target_auto", "Auto / none"),
                value: ""
            }
        ]
        var items = root.selectedCharacters || []
        for (var i = 0; i < items.length; i += 1) {
            var name = root.selectedCharacterDisplayName(items[i])
            if (name.length <= 0)
                continue
            options.push({
                text: name,
                value: name
            })
        }
        return options
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

    function selectedGenericAssetCardSummary(asset, fallback) {
        var item = asset || {}
        var text = root.cleanText(item.summary || item.description || item.caption || "")
        var displayName = root.selectedCharacterDisplayName(item)
        if (text.length === 0 || text === displayName)
            return fallback
        return text
    }

    function queueStatusKey(row) {
        return String((row || {}).status || (row || {}).job_status || "").trim().toLowerCase()
    }

    // Job đang chạy (đã dispatch) → khoá nút Xoá để không gỡ giữa chừng, giống PyQt cũ.
    function queueIsRunning(row) {
        var s = root.queueStatusKey(row)
        return s === "running" || s === "processing" || s === "generating" || s === "cloning" || s === "routing"
    }

    function queueStatusTone(row) {
        var status = root.queueStatusKey(row)
        if (status === "complete")
            return VfTheme.greenBorder
        if (status === "failed" || status === "cancelled")
            return "#DC2626"
        if (status === "running" || status === "processing" || status === "generating" || status === "cloning" || status === "routing")
            return "#2563EB"
        if (status === "paused")
            return "#D97706"
        return VfTheme.textMuted
    }

    function queueStatusLabel(row) {
        var status = root.queueStatusKey(row)
        if (status === "complete")
            return root.trText("common.complete", "Complete")
        if (status === "failed" || status === "cancelled")
            return root.trText("common.failed", "Failed")
        if (status === "running" || status === "processing" || status === "generating" || status === "cloning" || status === "routing")
            return root.trText("common.running", "Running")
        if (status === "paused")
            return root.trText("common.paused", "Paused")
        if (status === "queued" || status === "pending" || status === "waiting" || status === "draft")
            return root.trText("common.pending", "Pending")
        return root.cleanText(String((row || {}).status || root.trText("clone.status_waiting", "Waiting")))
    }

    function queueProgressValue(row) {
        var item = row || {}
        var summary = item.dispatcher_summary || ({})
        var progress = Number(item.job_progress !== undefined ? item.job_progress : (item.progress !== undefined ? item.progress : summary.progress))
        if (!isFinite(progress))
            progress = 0
        return Math.max(0, Math.min(100, Math.round(progress)))
    }

    function queueProgressText(row) {
        var progress = root.queueProgressValue(row)
        var label = root.queueStatusLabel(row)
        if (progress > 0 || root.queueStatusKey(row) === "complete")
            return String(progress) + "% • " + label
        return label
    }

    function queueOutputLabel(row) {
        var item = row || {}
        var requested = String(item.requested_output_mode || "auto").toLowerCase()
        var resolved = String(item.resolved_output_mode || "").toLowerCase()
        var imageLabel = root.trText("clone.output_image_short", "Ảnh")
        var videoLabel = root.trText("clone.output_video_short", "Video")
        if (requested === "auto") {
            if (resolved === "image")
                return "Auto → " + imageLabel
            if (resolved === "video")
                return "Auto → " + videoLabel
            return root.trText("clone.output_auto_pending", "Auto · chờ phân loại")
        }
        return requested === "image" ? imageLabel : videoLabel
    }

    function queueResolvedModelText(row) {
        var item = row || {}
        var requested = String(item.requested_output_mode || "auto").toLowerCase()
        var resolved = String(item.resolved_output_mode || "").toLowerCase()
        if (requested === "auto" && resolved.length === 0)
            return root.queueOutputLabel(item)
        var modelName = root.cleanText(String(item.model_name || item.model || ""))
        return root.queueOutputLabel(item) + (modelName.length > 0 ? " · " + modelName : "")
    }

    function queueOutputTone(row) {
        var resolved = String((row || {}).resolved_output_mode || "").toLowerCase()
        if (resolved === "image")
            return VfTheme.cyanText
        if (resolved === "video")
            return VfTheme.blueText
        return VfTheme.violetText
    }

    // Cache active row: chỉ re-eval khi queueRows / selectedQueueRowId đổi.
    // Trước đây resolveActiveQueueRow() lặp toàn bộ queueRows MỖI lần gọi, mà
    // binding elapsedText (Timer 1Hz) gọi nó mỗi giây => lặp liên tục. Tham
    // chiếu 2 dependency qua `void` để QML track đúng, KHÔNG track elapsedClockMs.
    readonly property var activeQueueRow: {
        void root.queueRows
        void root.selectedQueueRowId
        return root.computeActiveQueueRow()
    }

    function resolveActiveQueueRow() {
        return root.activeQueueRow || ({})
    }

    function computeActiveQueueRow() {
        var rows = root.queueRows || []
        if (!rows || rows.length === 0)
            return ({})
        for (var i = 0; i < rows.length; i += 1) {
            var status = root.queueStatusKey(rows[i])
            if (status === "running" || status === "processing" || status === "generating" || status === "cloning" || status === "routing")
                return rows[i] || ({})
        }
        if (root.selectedQueueRowId.length > 0) {
            for (var selectedIndex = 0; selectedIndex < rows.length; selectedIndex += 1) {
                var selectedRow = rows[selectedIndex] || ({})
                if (String(selectedRow.id || selectedRow.row_id || selectedRow.batch_id || "") === root.selectedQueueRowId)
                    return selectedRow
            }
        }
        for (var pendingIndex = 0; pendingIndex < rows.length; pendingIndex += 1) {
            var pendingStatus = root.queueStatusKey(rows[pendingIndex])
            if (pendingStatus === "queued" || pendingStatus === "pending" || pendingStatus === "waiting" || pendingStatus === "draft")
                return rows[pendingIndex] || ({})
        }
        return rows[0] || ({})
    }

    function activeQueueTitle() {
        var row = root.resolveActiveQueueRow()
        if (!row || Object.keys(row).length === 0)
            return root.cleanText(root.trText("clone.active_job", "Active Job"))
        return root.rowTitle(row)
    }

    function activeQueueMessage() {
        var row = root.resolveActiveQueueRow()
        var message = root.cleanText(String((row || {}).progress_message || ""))
        if (message.length > 0)
            return message
        if (!row || Object.keys(row).length === 0)
            return root.cleanText(root.trText("clone.status_waiting", "Waiting"))
        return root.queueProgressText(row)
    }

    function activeQueueSceneCount() {
        var row = root.resolveActiveQueueRow()
        return Number((row || {}).scene_count || ((row || {}).dispatcher_summary || {}).total || 0)
    }

    function activeQueueVideoCount() {
        var row = root.resolveActiveQueueRow()
        return Number((row || {}).video_count || ((row || {}).dispatcher_summary || {}).complete || 0)
    }

    function activeQueueRowId() {
        var row = root.resolveActiveQueueRow()
        return String((row || {}).row_id || (row || {}).id || (row || {}).batch_id || "")
    }

    function isPoolSlotWaitMessage(message) {
        var t = String(message || "").toLowerCase()
        return t.indexOf("hết slot") >= 0
            || t.indexOf("het slot") >= 0
            || t.indexOf("chỗ trống") >= 0
            || t.indexOf("waiting for slot") >= 0
            || t.indexOf("pool saturated") >= 0
    }

    function cloneImagePipelineStep(row, status) {
        var imgStage = String((row || {}).clone_image_stage || "").trim().toLowerCase()
        var feature = String((row || {}).dispatch_feature || "").trim().toLowerCase()
        var live = String((row || {}).progress_message || "").trim()
        var liveLow = live.toLowerCase()
        var isImage = feature.indexOf("clone_image") >= 0 || imgStage.length > 0
        if (!isImage)
            return null
        if (status === "complete" || status === "completed" || status === "done"
                || status === "failed" || status === "error")
            return null
        var charcore = String((row || {}).charcore_status || "").trim().toLowerCase()
        var drawing = liveLow.indexOf("vẽ") >= 0 || liveLow.indexOf("draw") >= 0 || liveLow.indexOf("stroke") >= 0
        var muxing = liveLow.indexOf("ghép") >= 0 || liveLow.indexOf("mux") >= 0
                || liveLow.indexOf("hoàn thiện video") >= 0
                || imgStage === "merge" || imgStage === "mux"
        var stills = imgStage === "waiting_images" || liveLow.indexOf("tạo ảnh") >= 0
        var cuts = imgStage === "analyzing_audio_story"
        if (charcore === "chargen_started" && !drawing && !muxing && !stills)
            return null
        if (drawing || muxing || stills || cuts) {
            var lateLabel = live
            if (!lateLabel.length) {
                if (drawing)
                    lateLabel = (void i18n.revision, i18n.t("clone_workspace.status_draw", "Đang vẽ chuyển động..."))
                else if (muxing)
                    lateLabel = (void i18n.revision, i18n.t("clone_workspace.status_mux", "Đang ghép video..."))
                else if (cuts)
                    lateLabel = (void i18n.revision, i18n.t("clone_workspace.status_image_cuts", "Đang cắt nhịp ảnh..."))
                else
                    lateLabel = (void i18n.revision, i18n.t("clone_workspace.status_stills", "Đang tạo ảnh..."))
            }
            return { label: lateLabel, icon: "movie-camera", step: 4, total: 4, indeterminate: true, failed: false, color: "#2563EB" }
        }
        if (imgStage === "narration")
            return { label: live || (void i18n.revision, i18n.t("clone_workspace.status_narration", "Đang tạo giọng...")), icon: "inbox-tray", step: 2, total: 4, indeterminate: true, failed: false, color: "#0EA5E9" }
        if (imgStage === "srt")
            return { label: live || (void i18n.revision, i18n.t("clone_workspace.status_srt", "Đang lấy SRT...")), icon: "magnifying-glass", step: 2, total: 4, indeterminate: true, failed: false, color: "#0891B2" }
        return null
    }

    // Map charcore_status (+ status bucket) -> bước hệ thống để hiển thị step + progress.
    // Chuỗi bước: Phân tích → Tạo nhân vật → Tạo video → Hoàn thành.
    function activeQueueStepInfo() {
        var row = root.resolveActiveQueueRow() || {}
        var status = root.queueStatusKey(row)
        var stage = String(row.charcore_status || "").trim().toLowerCase()
        var msg = String(row.progress_message || "").toLowerCase()
        var total = 4
        if (status === "complete" || status === "completed" || status === "done")
            return { label: (void i18n.revision, i18n.t("clone_workspace.status_completed_next", "Hoàn thành")), icon: "check-mark-button", step: total, total: total, indeterminate: false, failed: false, color: "#059669" }
        if (status === "failed" || status === "error" || stage === "chargen_failed" || stage === "chargen_policy_error")
            return { label: (void i18n.revision, i18n.t("clone_workspace.status_error", "Lỗi")), icon: "cross-mark", step: 0, total: total, indeterminate: false, failed: true, color: "#DC2626" }
        var imageStep = root.cloneImagePipelineStep(row, status)
        if (imageStep)
            return imageStep
        if (stage === "video_jobs_submitted") {
            var videoLive = String(row.progress_message || "").trim()
            return { label: videoLive.length > 0 ? videoLive : (void i18n.revision, i18n.t("clone_workspace.status_generating_videos", "Đang tạo video...")), icon: "movie-camera", step: 4, total: total, indeterminate: true, failed: false, color: "#2563EB" }
        }
        if (stage === "chargen_completed")
            return { label: (void i18n.revision, i18n.t("clone_workspace.status_chars_generated", "Đã tạo nhân vật")), icon: "check-mark-button", step: 3, total: total, indeterminate: false, failed: false, color: "#7C3AED" }
        if (root.isPoolSlotWaitMessage(msg))
            return { label: (void i18n.revision, i18n.t("clone_workspace.status_waiting_slot", "Hết slot — đang chờ...")), icon: "alarm-clock", step: 3, total: total, indeterminate: true, failed: false, color: "#D97706" }
        if (stage === "chargen_started")
            return { label: (void i18n.revision, i18n.t("clone_workspace.status_generating_chars", "Đang tạo nhân vật...")), icon: "artist-palette", step: 3, total: total, indeterminate: true, failed: false, color: "#7C3AED" }
        var isRunning = (status === "running" || status === "processing" || status === "generating" || status === "cloning" || status === "routing")
        // Heuristic bước "Tải": đang chạy + progress_message là thông điệp download
        // (📥 Đang tải...). Backend chưa có charcore_status riêng cho download.
        if (isRunning && (msg.indexOf("tải") >= 0 || msg.indexOf("📥") >= 0 || msg.indexOf("download") >= 0))
            return { label: (void i18n.revision, i18n.t("clone_workspace.status_downloading", "Đang tải video gốc...")), icon: "inbox-tray", step: 1, total: total, indeterminate: true, failed: false, color: "#0EA5E9" }
        if (isRunning)
            return { label: (void i18n.revision, i18n.t("clone_workspace.status_cloning", "Đang phân tích / clone...")), icon: "magnifying-glass", step: 2, total: total, indeterminate: true, failed: false, color: "#0891B2" }
        if (status === "paused")
            return { label: (void i18n.revision, i18n.t("clone_workspace.status_paused", "Tạm dừng")), icon: "pause-button", step: 0, total: total, indeterminate: false, failed: false, color: "#D97706" }
        return { label: (void i18n.revision, i18n.t("clone_workspace.status_waiting", "Chờ xử lý")), icon: "alarm-clock", step: 0, total: total, indeterminate: false, failed: false, color: VfTheme.textMuted }
    }

    function hasRunningQueueRow() {
        var rows = root.queueRows || []
        for (var i = 0; i < rows.length; i++) {
            var status = root.queueStatusKey(rows[i])
            if (status === "running" || status === "processing" || status === "routing" || status === "cloning" || status === "generating")
                return true
        }
        return false
    }

    function hasPendingQueueRow() {
        var rows = root.queueRows || []
        for (var i = 0; i < rows.length; i++) {
            var status = root.queueStatusKey(rows[i])
            if (status === "pending" || status === "queued" || status === "waiting" || status === "draft")
                return true
        }
        return false
    }

    function skipActionIsNextMode() {
        return !root.autoNextEnabled && !root.hasRunningQueueRow() && root.hasPendingQueueRow()
    }

    function timestampMs(value) {
        return JobClock.timestampMs(value)
    }

    function elapsedText(row) {
        return JobClock.elapsedText(
            row,
            root.elapsedClockMs,
            root.queueStatusKey(row),
            root.clockStartMs
        )
    }

    function formatElapsedSeconds(totalSeconds) {
        return JobClock.formatElapsedSeconds(totalSeconds)
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

    Timer {
        id: cloneAutoFetchTimer
        interval: 800   // ghi đè mỗi lần input đổi (_on_tiktok_input_changed): paste 150 / gõ 800
        repeat: false
        onTriggered: {
            // pendingCloneAutoFetchText là text mới nhất (set ở _on_tiktok_input_changed).
            // Dùng nó thay cho cloneUrlInput.text — id đó nằm trong SourceFrame, root không thấy.
            var text = String(root.pendingCloneAutoFetchText || "").trim()
            if (text.length === 0)
                return
            if (typeof workPanelController !== "undefined")
                workPanelController.executePrimitiveAction("work_panel.clone_auto_fetch", {
                    raw_input: text,
                    video_type: root.videoFilter
                })
        }
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
        cloneCharacterLibraryDialogLoader.active = true
        cloneCharacterLibraryDialogLoader.item.openUsagePicker("character", ["character"], root.selectedCharacterIds(), 12, true)
    }

    function openObjectLibrary() {
        if (typeof workPanelController === "undefined")
            return
        cloneObjectLibraryDialogLoader.active = true
        cloneObjectLibraryDialogLoader.item.openUsagePicker("object", ["object"], root.selectedObjectIds(), 12, true)
    }

    function openBackgroundLibrary() {
        if (typeof workPanelController === "undefined")
            return
        cloneBackgroundLibraryDialogLoader.active = true
        cloneBackgroundLibraryDialogLoader.item.openUsagePicker("background", ["background", "setting"], root.selectedBackgroundIds(), 12, true)
    }

    function openVoicePicker() {
        if (typeof workPanelController === "undefined")
            return
        var guard = workPanelController.prepareCloneVoicePicker()
        if (!guard.ok) {
            root.showVoiceGuardDialog(root.voiceGuardMessage(guard))
            return
        }
        var selectedIds = root.selectedVoiceIds()
        cloneVoicePickerDialog.selectedMediaId = selectedIds.length > 0 ? String(selectedIds[0] || "") : ""
        cloneVoicePickerDialog.targetSpeaker = ""
        cloneVoicePickerDialog.open()
    }

    function voiceGuardMessage(guard) {
        var code = String((guard || {}).code || "")
        if (code === "voice_reference_not_supported")
            return root.trText("clone.voice_reference_not_supported_msg", "Selected model does not support voice references.")
        if (code === "voice_reference_limit_reached")
            return root.trText("clone.voice_reference_limit_reached_msg", "Selected model supports up to {count} voice reference(s).")
                .replace("{count}", String((guard || {}).limit || root.flowVoiceReferenceLimit || 0))
        return String((guard || {}).message || "")
    }

    function showVoiceGuardDialog(message) {
        cloneVoiceGuardDialog.guardMessage = String(message || "")
        cloneVoiceGuardDialog.open()
    }

    function requestRemoveQueueRow(rowId) {
        root.requestAction("work_panel.queue_delete_row", {
            row_id: rowId,
            source: "clone_queue_row"
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

        function currentMasterMarket() {
        // Per-tab: read the CLONE route's own market (not the master panel) so the
        // dialogue-language sync follows this tab, not whatever master is set to.
        if (typeof workPanelController !== "undefined" && workPanelController)
            return String((workPanelController.currentRouteConfig || {}).market || "")
        return ""
    }

    function syncDialogueLanguageFromMarket(force) {
        var marketCode = root.currentMasterMarket()
        if (!force && String(marketCode || "") === String(root.observedMarketCode || ""))
            return
        root.observedMarketCode = String(marketCode || "")
        if (typeof workPanelController === "undefined" || !workPanelController || !workPanelController.syncCloneDialogueLanguageForMarket)
            return
        workPanelController.syncCloneDialogueLanguageForMarket(root.observedMarketCode)
    }

    function syncFromRouteConfig() {
        root.videoFilter = String(root.configValue("video_filter", root.videoFilter || "all"))
        root.creativeMode = String(root.configValue("creative_mode", root.creativeMode || "original"))
        root.charMode = String(root.configValue("char_mode", root.charMode || "full_ai"))
        // Chỉ gán array/object khi NỘI DUNG đổi. configValue trả reference mới mỗi lần
        // -> nếu gán thẳng, QML so theo reference => luôn "đổi" => panel re-render thừa
        // mỗi emit routeConfigChanged (perf bug: click giật, click nhanh chồng đống).
        var __cats = root.configValue("library_policy_categories", root.libraryPolicyCategories || ["characters"]) || ["characters"]
        if (JSON.stringify(__cats) !== JSON.stringify(root.libraryPolicyCategories))
            root.libraryPolicyCategories = __cats
        var __pol = root.configValue("library_policy", root.libraryPolicy || ({})) || ({})
        if (JSON.stringify(__pol) !== JSON.stringify(root.libraryPolicy))
            root.libraryPolicy = __pol
        var __recipe = root.configValue("remix_recipe", root.remixRecipe || ({})) || ({})
        if (JSON.stringify(__recipe) !== JSON.stringify(root.remixRecipe))
            root.remixRecipe = __recipe
        var __notes = String(root.configValue("remix_notes", root.remixNotes || "") || "")
        if (__notes !== root.remixNotes)
            root.remixNotes = __notes
        root.remixInstructions = String(root.configValue("remix_instructions", root.remixInstructions || ""))
        root.clipDurationSeconds = Number(root.configValue("clip_duration_seconds", root.clipDurationSeconds || 8)) || 8
        root.outputMode = String(root.configValue("output_mode", "auto"))
        if (["auto", "video", "image"].indexOf(root.outputMode) < 0)
            root.outputMode = "auto"
        root.narrationPolicy = String(root.configValue("narration_policy", "auto"))
        if (["auto", "on", "off"].indexOf(root.narrationPolicy) < 0)
            root.narrationPolicy = "auto"
        root.imageMotionMode = String(root.configValue("image_motion_mode", "off")) === "auto" ? "auto" : "off"
        root.imageMotionHandAsset = String(root.configValue("image_motion_hand_asset", "auto") || "auto")
        root.frameSlicingEnabled = !!root.configValue("frame_slicing", root.frameSlicingEnabled)
        root.flowVoiceLockEnabled = !!root.configValue("enable_flow_voice_lock", root.flowVoiceLockEnabled)
        root.autoExtendEnabled = false
        root.autoMergeEnabled = !!root.configValue("auto_merge", root.autoMergeEnabled)
        root.creativeAutosaveEnabled = !!root.configValue("creative_autosave", root.creativeAutosaveEnabled)
        root.autoNextEnabled = !!root.configValue("auto_next", root.autoNextEnabled)
        root.autoAddEnabled = !!root.configValue("auto_add", root.autoAddEnabled)
    }

    onRouteConfigChanged: {
        // Market is owned by the top config panel. Mirror its language here as
        // soon as that route config changes; observedMarketCode prevents the
        // language write from re-entering this path indefinitely.
        root.syncDialogueLanguageFromMarket(false)
        root.syncFromRouteConfig()
    }
    // Mở/chuyển sang tab này → đọc lại config đã lưu để pill khớp trạng thái
    // (tránh stale-display sau khi khởi động lại app). Đồng thời bù lại các đợt
    // master configChanged đã bỏ qua khi tab ẩn (Connections gate theo visible).
    onVisibleChanged: {
        if (!visible)
            return
        syncFromRouteConfig()
        root.syncDialogueLanguageFromMarket(false)
        if (typeof workPanelController !== "undefined" && workPanelController.refreshCloneVoiceReferences)
            workPanelController.refreshCloneVoiceReferences()
    }
    Component.onCompleted: {
        syncFromRouteConfig()
        root.syncDialogueLanguageFromMarket(true)
    }

    Connections {
        target: masterOptionsController
        // Tab ẩn không xử lý master config: trước đây mỗi click option ở tab khác
        // vẫn kéo clone resync + ghi đĩa clone config -> giật toàn cục.
        enabled: root.visible
        function onConfigChanged() {
            root.syncDialogueLanguageFromMarket(false)
            if (typeof workPanelController !== "undefined" && workPanelController.refreshCloneVoiceReferences)
                workPanelController.refreshCloneVoiceReferences()
            root.syncFromRouteConfig()
        }
    }

    ColumnLayout {
        id: cloneMainColumn
        anchors.fill: parent
        spacing: VfTheme.dp(9)

        ColumnLayout {
            id: featureRows
            objectName: "cloneFeatureRows"
            Layout.fillWidth: true
            // This is primary route chrome, not expendable workspace content.
            // When the consistency panel grows (library cards / voice refs), a
            // constrained layout must grow the ScrollView content instead of
            // resolving the shortage by collapsing these two action rows.
            Layout.minimumHeight: implicitHeight
            Layout.preferredHeight: implicitHeight
            spacing: VfTheme.dp(7)

            Rectangle {
                id: cloneCopyBlock
                objectName: "cloneCopyFunctions"
                Layout.fillWidth: true
                Layout.minimumHeight: implicitHeight
                Layout.preferredHeight: implicitHeight
                implicitHeight: VfTheme.dp(46)
                radius: VfTheme.dp(8)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderSoft
                clip: true

                // Bounded desktop toolbar: under 1120px the expanding request
                // field is replaced by the compact popup button, keeping the
                // remaining controls below the supported workspace width.
                RowLayout { // perf-lint: disable=R5
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(5)
                    spacing: VfTheme.dp(5)

                    Text {
                        text: root.trText("clone.copy_functions", "Chức năng sao chép")
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        font.weight: Font.Bold
                    }

                    SegmentButton {
                        minWidth: VfTheme.dp(82)
                        actionId: "work_panel.clone_creative_original"
                        text: root.trText("clone.creative_copy_original", "Copy gốc")
                        tooltip: root.trText("clone.mode_copy_tip", "Tái tạo sát video gốc: giữ nguyên câu chuyện, lời thoại và hướng hình ảnh.")
                        selected: root.creativeMode === "original"
                        accent: "#2563EB"
                        onClicked: {
                            root.creativeMode = "original"
                            root.requestAction("work_panel.clone_creative_original", { source: "clone_feature_bar" })
                        }
                    }
                    SegmentButton {
                        minWidth: VfTheme.dp(118)
                        actionId: "work_panel.clone_creative_remix"
                        text: root.trText("clone.creative_remix", "Giữ chuyện, đổi vỏ")
                        tooltip: root.trText("clone.mode_remix_tip", "Giữ nguyên cốt truyện và lời thoại; chỉ đổi nhân vật, bối cảnh, style hoặc sản phẩm.")
                        selected: root.creativeMode === "remix"
                        accent: "#2563EB"
                        onClicked: {
                            root.creativeMode = "remix"
                            root.requestAction("work_panel.clone_creative_remix", { source: "clone_feature_bar" })
                        }
                    }
                    SegmentButton {
                        minWidth: VfTheme.dp(148)
                        actionId: "work_panel.clone_creative_create"
                        text: root.trText("clone.creative_create", "Giữ công thức, chuyện mới")
                        tooltip: root.trText("clone.mode_create_tip", "Học hook, cấu trúc và nhịp của video gốc rồi viết một câu chuyện hoàn toàn mới.")
                        selected: root.creativeMode === "creative"
                        accent: "#2563EB"
                        onClicked: {
                            root.creativeMode = "creative"
                            root.requestAction("work_panel.clone_creative_create", { source: "clone_feature_bar" })
                        }
                    }
                    SegmentButton {
                        minWidth: VfTheme.dp(106)
                        actionId: "work_panel.clone_creative_series"
                        text: root.trText("clone.creative_series", "Tập tiếp theo")
                        tooltip: root.trText("clone.mode_series_tip", "Giữ dàn nhân vật và thế giới của video gốc rồi viết tình huống cho tập tiếp theo.")
                        selected: root.creativeMode === "series"
                        accent: "#2563EB"
                        onClicked: {
                            root.creativeMode = "series"
                            root.requestAction("work_panel.clone_creative_series", { source: "clone_feature_bar" })
                        }
                    }

                    // Desktop: yêu cầu riêng nằm ngay trong khoảng trống còn lại,
                    // cùng chiều cao với các nút.  Không còn một panel TextArea
                    // cao riêng làm đẩy toàn bộ nguồn/queue xuống dưới.
                    Rectangle {
                        id: cloneRecipeInline
                        objectName: "remixInstructionsInput"
                        visible: !root.compact
                        Layout.fillWidth: true
                        Layout.minimumWidth: VfTheme.dp(220)
                        implicitHeight: VfTheme.dp(34)
                        radius: VfTheme.dp(7)
                        color: root.creativeMode === "original" ? VfTheme.blueFill
                             : root.creativeMode === "creative" ? VfTheme.violetFill
                             : root.creativeMode === "series" ? VfTheme.cyanFill : VfTheme.redFill
                        border.color: root.creativeMode === "original" ? VfTheme.blueBorderSoft
                                      : root.creativeMode === "creative" ? VfTheme.violetBorderSoft
                                      : root.creativeMode === "series" ? VfTheme.cyanBorderSoft : VfTheme.redBorderSoft

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(9)
                            anchors.rightMargin: VfTheme.dp(7)
                            spacing: VfTheme.dp(7)

                            Text {
                                Layout.maximumWidth: VfTheme.dp(160)
                                text: root.recipeChipLabel(root.primaryRecipeKey)
                                color: root.creativeMode === "original" ? VfTheme.blueText
                                     : root.creativeMode === "creative" ? VfTheme.violetText
                                     : root.creativeMode === "series" ? VfTheme.cyanText : VfTheme.redText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                Layout.preferredWidth: 1
                                Layout.preferredHeight: VfTheme.dp(18)
                                color: cloneRecipeInline.border.color
                            }

                            TextField {
                                id: primaryRecipeField
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: String((root.remixRecipe || ({}))[root.primaryRecipeKey] || "")
                                placeholderText: (void i18n.revision, root.recipeChipPlaceholder(root.primaryRecipeKey))
                                selectByMouse: true
                                color: VfTheme.text
                                placeholderTextColor: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                verticalAlignment: TextInput.AlignVCenter
                                leftPadding: 0
                                rightPadding: 0
                                topPadding: 0
                                bottomPadding: 0
                                background: Item { }
                                onTextChanged: root.queuePrimaryRecipeUpdate(text)
                            }
                        }

                        HoverHandler { id: cloneRecipeHover }
                        ToolTip.visible: cloneRecipeHover.hovered && !primaryRecipeField.activeFocus
                        ToolTip.text: root.recipeModeExplanation()
                        ToolTip.delay: 450
                    }

                    SegmentButton {
                        visible: root.compact
                        minWidth: VfTheme.dp(112)
                        actionId: "master.input.extra_requirements"
                        text: root.trText("clone.extra_request_short", "Yêu cầu thêm")
                        tooltip: root.recipeModeExplanation()
                        selected: String((root.remixRecipe || ({}))[root.primaryRecipeKey] || "").length > 0
                        accent: "#2563EB"
                        onClicked: cloneRecipeDialog.open()
                    }
                }
            }

            Rectangle {
                id: cloneOutputOptionsBlock
                objectName: "cloneJobOptions"
                Layout.fillWidth: true
                Layout.minimumHeight: implicitHeight
                Layout.preferredHeight: implicitHeight
                implicitHeight: VfTheme.dp(46)
                radius: VfTheme.dp(8)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderSoft
                clip: true

                // Left cluster keeps intrinsic width (no fill). TTS compactBar
                // takes leftover space so the old empty gap is the voice row.
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(5)
                    anchors.rightMargin: VfTheme.dp(6)
                    spacing: VfTheme.dp(7)

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: root.trText("clone.job_options", "Tùy chọn job")
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        font.weight: Font.Bold
                    }

                    SegmentButton {
                        Layout.alignment: Qt.AlignVCenter
                        minWidth: VfTheme.dp(108)
                        actionId: "work_panel.clone_char_consistency"
                        text: root.consistencyDisclosureText()
                        tooltip: root.consistencyDisclosureTooltip()
                        selected: root.consistencyActiveCount() > 0
                        accent: "#7C3AED"
                        onClicked: root.consistencyPanelExpanded = !root.consistencyPanelExpanded
                    }

                    VfToolbarSwitch {
                        Layout.alignment: Qt.AlignVCenter
                        actionId: "work_panel.clone_auto_merge"
                        text: root.trText("master.auto_merge_video", "Tự ghép video")
                        tooltip: root.trText("clone.auto_merge_hint", "Ghép video ngay khi đủ cảnh.")
                        checked: root.autoMergeEnabled
                        accent: "#10B981"
                        onToggled: function(enabled) {
                            root.autoMergeEnabled = enabled
                            root.requestAction("work_panel.clone_auto_merge_toggle", {
                                enabled: enabled,
                                source: "clone_feature_bar"
                            })
                        }
                    }

                    SubtitleWorkflowButton {
                        objectName: "cloneSubtitleWorkflowButton"
                        Layout.alignment: Qt.AlignVCenter
                        actionId: "work_panel.clone_subtitle_workflow"
                        minWidth: VfTheme.dp(174)
                        controlHeight: VfTheme.controlHeight
                        profile: (root.routeConfig || {}).subtitle_profile || ({})
                        configuredLanguage: (root.routeConfig || {}).voice_language
                            || (root.routeConfig || {}).language || "vi"
                        onClicked: root.openSubtitleStudio()
                    }

                    SharedTtsInlinePanel {
                        objectName: "cloneNarrationVoice"
                        Layout.fillWidth: true
                        Layout.minimumWidth: VfTheme.dp(72)
                        Layout.preferredHeight: VfTheme.controlHeight
                        Layout.maximumHeight: VfTheme.controlHeight
                        Layout.alignment: Qt.AlignVCenter
                        presentation: "compactBar"
                        contextLabel: "TTS"
                        selectionOnly: true
                        usageHintInStatus: true
                        showNarrationPolicy: root.outputMode !== "image"
                        narrationPolicy: root.narrationPolicy
                        usageHint: root.outputMode === "image"
                            ? root.trText(
                                "clone.tts_image_required_hint",
                                "Đầu ra Ảnh dùng một WAV TTS hoàn chỉnh làm mốc dựng hình.")
                            : root.narrationPolicy === "off"
                                ? root.trText(
                                    "clone.tts_video_off_hint",
                                    "Narrator app đã tắt · giữ audio/hội thoại native của Veo.")
                                : root.narrationPolicy === "on"
                                    ? root.trText(
                                        "clone.tts_video_on_hint",
                                        "Narrator app được buộc bật; lời nhân vật vẫn do Veo đọc.")
                                    : root.trText(
                                        "clone.tts_usage_hint",
                                        "Tự động · chỉ tạo TTS khi nguồn có bằng chứng narrator.")
                        onNarrationPolicySelected: function(policy) {
                            root.narrationPolicy = String(policy || "auto")
                            root.requestAction("work_panel.clone_narration_policy", {
                                policy: root.narrationPolicy,
                                source: "clone_tts_bar"
                            })
                        }
                    }
                }
            }

            Timer {
                id: primaryRecipeDebounce
                property string pendingKey: ""
                property string pendingValue: ""
                interval: 400
                repeat: false
                onTriggered: {
                    if (!pendingKey.length)
                        return
                    root.requestAction("work_panel.clone_recipe_update", {
                        key: pendingKey,
                        value: pendingValue,
                        source: "clone_recipe_input"
                    })
                }
            }
        }

        // ── Banner Config Override (19/7): đang ghi đè cấu hình cho link nào,
        // với cấu hình gì — và nút thoát về cấu hình chung. Hết cảnh sửa panel
        // mà không biết đang sửa cho ai.
        Rectangle {
            Layout.fillWidth: true
            visible: typeof workPanelController !== "undefined"
                && String(workPanelController.activeCloneCardId || "").length > 0
            Layout.preferredHeight: visible ? overrideBannerRow.implicitHeight + VfTheme.dp(12) : 0
            radius: VfTheme.dp(8)
            color: VfTheme.indigoFill
            border.color: VfTheme.indigoBorder
            border.width: 2
            clip: true

            RowLayout {
                id: overrideBannerRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: VfTheme.dp(10)
                anchors.rightMargin: VfTheme.dp(8)
                spacing: VfTheme.dp(8)

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(1)

                    Text {
                        Layout.fillWidth: true
                        text: {
                            void workPanelController.activeCloneCardId
                            return root.trText("clone.override_banner_title", "⚙ Đang chỉnh cấu hình RIÊNG cho:")
                                + " " + root.overrideCardTitle()
                        }
                        color: VfTheme.indigoText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.overrideCardSummary()
                        visible: text.length > 0
                        color: VfTheme.indigoText
                        opacity: 0.8
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                        elide: Text.ElideRight
                    }
                }
                FlatActionButton {
                    text: root.trText("clone.override_apply_all", "Áp cho tất cả link")
                    tooltip: root.trText("clone.override_apply_all_tip", "Chép cấu hình riêng của link này sang MỌI link trong danh sách.")
                    accent: "#6366F1"
                    minWidth: VfTheme.dp(122)
                    onClicked: {
                        if (typeof workPanelController === "undefined")
                            return
                        var ids = []
                        var cs = root.cards || []
                        for (var i = 0; i < cs.length; i++)
                            ids.push(String(cs[i].id || ""))
                        workPanelController.applyCloneCardConfigToAll(ids)
                    }
                }
                FlatActionButton {
                    text: root.trText("clone.override_exit", "Về cấu hình chung")
                    tooltip: root.trText("clone.override_exit_tip", "Thoát chế độ ghi đè — panel cấu hình quay lại chỉnh cho TẤT CẢ link chưa có config riêng.")
                    selected: true
                    accent: "#10B981"
                    minWidth: VfTheme.dp(128)
                    onClicked: {
                        if (typeof workPanelController !== "undefined")
                            workPanelController.clearActiveCloneCard()
                    }
                }
            }
        }

        CharacterConsistencyOptions {
            visible: root.consistencyPanelExpanded
            Layout.fillWidth: true
            Layout.minimumHeight: visible ? implicitHeight : 0
            Layout.preferredHeight: visible ? implicitHeight : 0
        }

        ResponsiveSplit {
            id: cloneSplit
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: VfTheme.dp(520)
            gap: VfTheme.dp(10)
            rightRatio: 0.46          // queue ~46% side-by-side; input takes the rest
            stackBelow: VfTheme.dp(880)   // narrower → stack input over queue (no clip)

            SourceFrame {
                Layout.fillWidth: true
                Layout.fillHeight: !cloneSplit.stacked
                Layout.preferredHeight: cloneSplit.stacked ? implicitHeight : -1
            }

            QueueFrame {
                Layout.preferredWidth: cloneSplit.rightPaneWidth
                Layout.fillWidth: cloneSplit.stacked
                Layout.fillHeight: !cloneSplit.stacked
                Layout.preferredHeight: cloneSplit.stacked ? implicitHeight : -1
            }
        }
    }

    component SourceFrame: Rectangle {
        objectName: "cloneSourceFrame"
        radius: VfTheme.dp(8)
        color: VfTheme.surface
        border.color: root.uploadDropActive ? "#2563EB" : VfTheme.borderBox
        border.width: root.uploadDropActive ? 2 : 1
        clip: true

        // Kéo-thả file video vào BẤT KỲ đâu trong khung nguồn → addLocalFiles
        // (cùng đường với nút Select Files; card xếp chung bảng với link fetch).
        // DropArea chỉ nhận drag, không chặn chuột thường → đặt phủ toàn khung.
        DropArea {
            anchors.fill: parent
            onEntered: function(drag) {
                root.uploadDropActive = true
                drag.acceptProposedAction()
            }
            onExited: root.uploadDropActive = false
            onDropped: function(drop) {
                root.uploadDropActive = false
                var urls = []
                if (drop && drop.urls) {
                    for (var index = 0; index < drop.urls.length; ++index)
                        urls.push(String(drop.urls[index]))
                }
                if (urls.length > 0)
                    root.requestAction("work_panel.clone_drop_upload_files", { urls: urls, source: "clone_upload_drop" })
                drop.acceptProposedAction()
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(8)
            spacing: VfTheme.dp(7)

            // Hợp nhất 1 đường (thiết kế Bố 19/7): bỏ tab Video URL / Upload Files.
            // Link paste + file chọn/kéo-thả cùng xếp vào MỘT bảng kết quả bên dưới,
            // cùng 1 nút "Thêm vào danh sách công việc" (file tự upload trong job).
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 185
                Layout.minimumHeight: 185
                Layout.maximumHeight: 185
                spacing: VfTheme.dp(6)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(8)

                    Text {
                        // fillWidth + elide: nhãn co lại / cắt "…" khi hàng chật để nút Login
                        // LUÔN đủ chỗ, không bị cắt cụt ở mép phải (SourceFrame có clip:true).
                        // Trước đây nhãn dài cố định + spacer đẩy nút tràn ra ngoài → bị clip.
                        Layout.fillWidth: true
                        text: root.cleanText(root.trText("clone.enter_video_urls", "Video sources (URLs or files)"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }
                    FlatActionButton {
                        actionId: "work_panel.clone_video_files"
                        text: root.trText("clone.select_files_btn", "Select Files")
                        selected: true
                        accent: "#8B5CF6"
                        minWidth: VfTheme.dp(104)
                        onClicked: root.requestRouteTool("clone_video_files", "work_panel.clone_video_files")
                    }
                    FlatActionButton {
                        actionId: "work_panel.clone_video_folder"
                        text: root.trText("clone.select_folder", "Select Folder")
                        accent: "#3B82F6"
                        minWidth: VfTheme.dp(108)
                        onClicked: root.requestRouteTool("clone_video_folder", "work_panel.clone_video_folder")
                    }
                    VfButton {
                        actionId: "work_panel.clone_login_platform"
                        text: root.trText("clone.login_platform", "Login Platform")
                        tone: "neutral"
                        Layout.alignment: Qt.AlignVCenter
                        minWidth: VfTheme.dp(112)
                        onClicked: root.requestAction("work_panel.clone_login_platform", {
                            source: "clone_source",
                            url_text: cloneUrlInput.text
                        })
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: VfTheme.dp(6)
                    color: VfTheme.surface
                    border.color: VfTheme.borderBox
                    clip: true

                    TextArea {
                        id: cloneUrlInput
                        objectName: "cloneUrlInput"   // tour target
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(8)
                        placeholderText: root.trText("clone.unified_input_placeholder", "Paste YouTube/TikTok/channel URLs (one per line) — or drag & drop video files anywhere here...")
                        wrapMode: TextEdit.Wrap
                        color: VfTheme.text
                        placeholderTextColor: VfTheme.textSubtle
                        selectedTextColor: "#FFFFFF"
                        selectionColor: VfTheme.primary
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        onTextChanged: root._on_tiktok_input_changed(cloneUrlInput.text)
                        background: Item {}
                    }
                }

                // Hàng trạng thái: spinner "đang lấy link…" khi auto-fetch yt-dlp chạy
                // (chỉ yt-dlp; Facebook reel có thể mất vài giây) → user không tưởng treo.
                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(6)
                    visible: typeof workPanelController !== "undefined"
                        && workPanelController.cloneLinksFetching

                    BusyIndicator {
                        running: parent.visible
                        implicitWidth: VfTheme.dp(14)
                        implicitHeight: VfTheme.dp(14)
                        Layout.preferredWidth: VfTheme.dp(14)
                        Layout.preferredHeight: VfTheme.dp(14)
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.trText("clone_workspace.link_fetching", "Đang lấy link… (yt-dlp)")
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        elide: Text.ElideRight
                    }
                }

            }

            // Vừa 1 hàng → filter TRÁI, action SÁT PHẢI (space-between, không để trống
            // lệch vào trong như Flow căn trái). Hẹp không đủ → action tự xuống hàng 2,
            // vẫn sát phải, KHÔNG bao giờ bị cắt (bỏ giả định "window luôn ≥1280").
            Item {
                id: sourceToolbar
                Layout.fillWidth: true
                readonly property bool oneLine: filterRow.implicitWidth + sourceActionRow.implicitWidth + VfTheme.dp(12) <= sourceToolbar.width
                implicitHeight: oneLine ? filterRow.implicitHeight
                                        : filterRow.implicitHeight + sourceActionRow.implicitHeight + VfTheme.dp(6)
                Layout.preferredHeight: implicitHeight

                Row {
                    id: filterRow
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: VfTheme.dp(5)
                    SegmentButton {
                        text: root.trText("clone.filter_all", "All")
                        selected: root.videoFilter === "all"
                        minWidth: VfTheme.dp(78)
                        onClicked: {
                            root.videoFilter = "all"
                            root.requestAction("work_panel.clone_video_filter", { video_filter: "all", source: "clone_results_filter" })
                        }
                    }
                    SegmentButton {
                        text: root.trText("clone.filter_shorts", "Shorts")
                        selected: root.videoFilter === "shorts"
                        minWidth: VfTheme.dp(86)
                        onClicked: {
                            root.videoFilter = "shorts"
                            root.requestAction("work_panel.clone_video_filter", { video_filter: "shorts", source: "clone_results_filter" })
                        }
                    }
                    SegmentButton {
                        text: root.trText("clone.filter_long", "Long")
                        selected: root.videoFilter === "long"
                        minWidth: VfTheme.dp(78)
                        onClicked: {
                            root.videoFilter = "long"
                            root.requestAction("work_panel.clone_video_filter", { video_filter: "long", source: "clone_results_filter" })
                        }
                    }
                }

                Row {
                    id: sourceActionRow
                    anchors.right: parent.right
                    anchors.top: sourceToolbar.oneLine ? parent.top : filterRow.bottom
                    anchors.topMargin: sourceToolbar.oneLine ? 0 : VfTheme.dp(6)
                    spacing: VfTheme.dp(5)
                    FlatActionButton { actionId: "work_panel.clone_select_all"; text: root.trText("common.select_all", "Select All"); accent: "#10B981"; minWidth: VfTheme.dp(86); onClicked: root.requestAction("work_panel.clone_select_all", { source: "clone_results" }) }
                    FlatActionButton { text: root.trText("common.deselect_all", "Deselect"); accent: "#EF4444"; minWidth: VfTheme.dp(82); onClicked: root.requestAction("work_panel.clone_deselect_all", { source: "clone_results" }) }
                    FlatActionButton {
                        actionId: "work_panel.clone_submit_worklist"
                        text: root.trText("clone.add_to_worklist", "Thêm vào danh sách công việc")
                        selected: true
                        enabled: true
                        minWidth: VfTheme.dp(186)
                        onClicked: {
                            var cs = root.cards || []
                            if (cs.length > 0) {
                                var arr = []
                                for (var i = 0; i < cs.length; i++) {
                                    if (cs[i].selected === false)
                                        continue
                                    arr.push({ id: String(cs[i].id || ""), url: String(cs[i].url || cs[i].prompt || "") })
                                }
                                // Route through the screen's pre-queue confirmation gate
                                // (gateQueue → QueuePreflightDialog) instead of submitting
                                // directly — the PA1 direct call had bypassed the confirm.
                                root.requestAction("work_panel.clone_submit_worklist", { cards: arr })
                            } else {
                                // Chưa có card nào. Trước đây dựng card thẳng từ URL thô
                                // (requestAddCards → _make_card), nhưng card đó KHÔNG hỏi
                                // yt-dlp nên không có title/duration thật — trust boundary
                                // chặn nó ở queue, còn người dùng chỉ thấy một dòng link trần.
                                // Nguyên nhân thường gặp: auto-fetch là Timer debounce 2s, dán
                                // link rồi bấm ngay thì nó CHƯA chạy. Nên bấm nút = chạy fetch
                                // luôn, đúng cái auto-fetch sắp làm.
                                var pendingText = String(cloneUrlInput.text || "").trim()
                                if (pendingText.length > 0 && typeof workPanelController !== "undefined")
                                    workPanelController.executePrimitiveAction("work_panel.clone_auto_fetch", {
                                        raw_input: pendingText,
                                        video_type: root.videoFilter
                                    })
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: VfTheme.dp(200)
                Layout.minimumHeight: VfTheme.dp(120)
                radius: VfTheme.dp(7)
                color: VfTheme.surface
                border.color: VfTheme.borderBox
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    TableHeader {
                        columns: [
                            { label: "✓", width: VfTheme.dp(40), alignRight: false },
                            { label: root.trText("clone.header_title", "Title / Source"), width: -1, alignRight: false },
                            { label: root.trText("clone.header_duration", "Duration"), width: VfTheme.dp(92), alignRight: false },
                            { label: root.trText("clone.header_views", "Views"), width: VfTheme.dp(82), alignRight: false },
                            { label: root.trText("clone.header_status", "Status"), width: VfTheme.dp(90), alignRight: false },
                            { label: root.trText("clone.header_actions", "Actions"), width: VfTheme.dp(264), alignRight: true }
                        ]
                    }

                    ListView {
                        id: cloneResults
                        objectName: "cloneSourceList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: root.cards || []  // perf-lint: disable=R2  user-action list via a component alias; reuseItems recycles delegates — QAbstractListModel deferred
                        clip: true
                        cacheBuffer: height * 2
                        reuseItems: true

                        delegate: Rectangle {
                            readonly property string cardId: String(modelData.id || "")
                            readonly property bool cardSelected: modelData.selected !== false
                            readonly property bool cardActive: typeof workPanelController !== "undefined" && cardId.length > 0 && cardId === String(workPanelController.activeCloneCardId || "")
                            // Tóm tắt config link này cho sub-row. Re-eval khi đổi link active
                            // HOẶC khi config bất kỳ thay đổi (currentRouteConfig đổi mỗi lần ghi).
                            readonly property var cfgSummary: {
                                void workPanelController.activeCloneCardId
                                void workPanelController.currentRouteConfig
                                return (typeof workPanelController !== "undefined")
                                    ? workPanelController.cloneCardConfigSummary(cardId) : ({})
                            }
                            width: cloneResults.width
                            height: VfTheme.dp(56)
                            color: cardActive ? VfTheme.blueFill : (index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft)
                            border.color: cardActive ? VfTheme.primary : (cardSelected ? VfTheme.blueBorderSoft : VfTheme.surfaceSoft)

                            RowLayout {
                                id: cardMainRow
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: VfTheme.dp(38)
                                anchors.leftMargin: VfTheme.dp(8)
                                anchors.rightMargin: VfTheme.dp(8)
                                spacing: VfTheme.dp(6)
                                // Select-this-video checkbox. The old 12dp glyph in a 34dp box
                                // was near-impossible to aim at — users missed it entirely and
                                // then hit the "no video selected" warning on Add. Bigger glyph
                                // + bigger hit target + hover highlight so it reads as clickable.
                                Item {
                                    Layout.preferredWidth: VfTheme.dp(40)
                                    // minimumWidth (like the actions cluster below): `preferredWidth`
                                    // alone is only a HINT — RowLayout squeezes it toward 0 on a narrow
                                    // panel/split, shrinking the hit target back to unclickable. The text
                                    // columns may compress; an interactive control must not.
                                    Layout.minimumWidth: VfTheme.dp(40)
                                    Layout.preferredHeight: cardMainRow.height

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: VfTheme.dp(30)
                                        height: VfTheme.dp(30)
                                        radius: VfTheme.dp(6)
                                        color: cardCheckArea.containsMouse ? VfTheme.blueFill : "transparent"
                                    }

                                    VfAppIcon {
                                        name: cardSelected ? "check-box-with-check" : "empty-box"
                                        size: VfTheme.dp(20)
                                        framed: false
                                        color: cardSelected
                                            ? VfTheme.primary
                                            : (cardCheckArea.containsMouse ? VfTheme.primary : VfTheme.textSubtle)
                                        anchors.centerIn: parent
                                    }

                                    MouseArea {
                                        id: cardCheckArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.requestAction("work_panel.clone_toggle_source_card", {
                                            card_id: cardId,
                                            selected: !cardSelected,
                                            source: "clone_results"
                                        })
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: root.rowTitle(modelData)
                                    color: parent.parent.cardActive ? VfTheme.primary : VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(11)
                                    elide: Text.ElideRight
                                    // Click the link title → make this card active so the config
                                    // panel edits THIS link's own config (PA1).
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: { if (typeof workPanelController !== "undefined") workPanelController.setActiveCloneCard(cardId) }
                                    }
                                }
                                Text { Layout.preferredWidth: VfTheme.dp(92); Layout.minimumWidth: VfTheme.dp(92); text: String(modelData.duration || "-"); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(10); elide: Text.ElideRight }
                                Text { Layout.preferredWidth: VfTheme.dp(82); Layout.minimumWidth: VfTheme.dp(82); text: String(modelData.views || "-"); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(10); elide: Text.ElideRight }
                                Text { Layout.preferredWidth: VfTheme.dp(90); Layout.minimumWidth: VfTheme.dp(90); text: String(modelData.status || "Ready"); color: VfTheme.primary; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(10); elide: Text.ElideRight }
                                RowLayout {
                                    // Actions ÔM SÁT nội dung (KHÔNG cố định width) + alignRight →
                                    // mép phải luôn thẳng header "Thao tác" (cũng alignRight) dù tên
                                    // nút dài/ngắn. minimumWidth giữ nguyên cụm nút khi panel hẹp
                                    // (cột text co trước) nên nút Xoá KHÔNG bao giờ bị cắt. Title
                                    // fillWidth đã đẩy cụm nút sang phải — KHÔNG cần spacer.
                                    // 264 = đúng width cột Actions của header → cột giữa thẳng cột.
                                    Layout.minimumWidth: VfTheme.dp(264)
                                    Layout.alignment: Qt.AlignRight
                                    spacing: VfTheme.dp(6)

                                    // PA1: nút chỉnh config RIÊNG cho link này → panel config
                                    // clone bind vào link này (sáng = đang chỉnh link đó).
                                    FlatActionButton {
                                        text: cardActive
                                            ? root.trText("clone.edit_card_config_active", "⚙ Đang chỉnh riêng")
                                            : root.trText("clone.edit_card_config_btn", "Config Override")
                                        tooltip: cardActive
                                            ? root.trText("clone.edit_card_config_active_tip", "Panel cấu hình đang ghi đè cho CHÍNH link này (xem banner phía trên). Bấm lần nữa để thoát về cấu hình chung.")
                                            : root.trText("clone.edit_card_config", "Ghi đè cấu hình riêng cho link này; bấm rồi sửa panel bên trái")
                                        selected: cardActive
                                        accent: "#6366F1"
                                        minWidth: VfTheme.dp(118)
                                        Layout.minimumWidth: VfTheme.dp(118)
                                        onClicked: {
                                            if (typeof workPanelController === "undefined")
                                                return
                                            if (cardActive)
                                                workPanelController.clearActiveCloneCard()
                                            else
                                                workPanelController.setActiveCloneCard(cardId)
                                        }
                                    }

                                    // Batch: mở dialog cấu hình nhân bản N video từ video này
                                    // rồi mark _batch_config (parity _on_batch_source_clicked).
                                    VfButton {
                                        readonly property int batchCount: {
                                            var bc = modelData._batch_config || ({})
                                            return Number(bc.variations || 0)
                                        }
                                        compact: true
                                        Layout.preferredHeight: VfTheme.dp(28)
                                        text: batchCount > 0
                                            ? root.trText("clone.batch_button", "Batch") + " x" + batchCount
                                            : root.trText("clone.batch_button", "Batch")
                                        minWidth: VfTheme.dp(88)
                                        Layout.minimumWidth: VfTheme.dp(88)
                                        onClicked: root.requestAction("work_panel.clone_batch_source_config", {
                                            card_id: cardId,
                                            row_id: cardId,
                                            card: modelData,
                                            source: "clone_result_row"
                                        })
                                    }
                                    // Xoá: gỡ video đã fetch khỏi bảng kết quả
                                    // (parity _delete_single_video). Icon vuông gọn, không tràn cột.
                                    VfButton {
                                        compact: true
                                        Layout.preferredHeight: VfTheme.dp(28)
                                        Layout.preferredWidth: VfTheme.dp(34)
                                        Layout.minimumWidth: VfTheme.dp(34)
                                        text: ""
                                        iconName: "cross-mark"
                                        minWidth: VfTheme.dp(34)
                                        tone: "danger"
                                        tooltip: (void i18n.revision, i18n.t("clone_workspace.delete_video_tooltip", "Xoá video"))
                                        onClicked: root.requestAction("work_panel.clone_delete_source_card", {
                                            card_id: cardId,
                                            row_id: cardId,
                                            source: "clone_result_row"
                                        })
                                    }
                                }
                            }

                            // Sub-row bé: tóm tắt config link này (đang chỉnh gì) + badge
                            // Riêng/Theo chung → nhìn là biết link nào đã override (PA1),
                            // cái nào còn theo config chung.
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: VfTheme.dp(42)
                                anchors.right: parent.right
                                anchors.rightMargin: VfTheme.dp(8)
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: VfTheme.dp(4)
                                height: VfTheme.dp(15)
                                spacing: VfTheme.dp(6)

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: VfTheme.dp(14)
                                    width: badgeText.implicitWidth + VfTheme.dp(10)
                                    radius: VfTheme.dp(3)
                                    color: cfgSummary.overridden ? "#6366F1" : "transparent"
                                    border.width: 1
                                    border.color: cfgSummary.overridden ? "#6366F1" : VfTheme.blueBorderSoft
                                    Text {
                                        id: badgeText
                                        anchors.centerIn: parent
                                        text: cfgSummary.overridden
                                            ? root.trText("clone.cfg_own", "● Riêng")
                                            : root.trText("clone.cfg_shared", "Theo chung")
                                        color: cfgSummary.overridden ? "#FFFFFF" : VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(9)
                                    }
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - badgeText.implicitWidth - VfTheme.dp(28)
                                    elide: Text.ElideRight
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9)
                                    text: {
                                        var s = cfgSummary || ({})
                                        var parts = []
                                        parts.push(root.trText("clone.cfg_style", "Style") + " " + (s.style || "—"))
                                        parts.push(s.aspect || "16:9")
                                        parts.push(s.quality || "720p")
                                        if (s.model && s.model !== "—") parts.push(s.model)
                                        if (s.char) parts.push(root.trText("clone.cfg_char", "Nhân vật"))
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
                        visible: cloneResults.count === 0
                        text: root.trText("clone.no_results", "No videos loaded. Paste URLs or import local videos.")
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

    component QueueFrame: Rectangle {
        objectName: "cloneQueueFrame"
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
                spacing: VfTheme.dp(6)

                Text {
                    text: "Queue: " + String(root.stats.total || 0) + "/10"
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    Layout.maximumWidth: VfTheme.dp(110)
                }

                Item { Layout.fillWidth: true }

                Row {
                    id: queueActionRow
                    Layout.alignment: Qt.AlignVCenter
                    spacing: VfTheme.dp(5)
                    FlatActionButton { text: root.trText("clone.clear_button", "Clear"); accent: "#EF4444"; minWidth: VfTheme.dp(72); enabled: root.hasWorkList; onClicked: root.requestQueueAction("work_panel.clear_queue") }
                    FlatActionButton { text: root.trText("clone.stop_btn", "Stop"); accent: "#D97706"; minWidth: VfTheme.dp(70); enabled: root.hasWorkList && !root.authPauseRequired && !root.noLiveAccountsPauseRequired; onClicked: root.requestQueueAction("work_panel.pause_queue") }
                    FlatActionButton {
                        text: workPanelController.cloneSkipLabel === "Next"
                            ? root.trText("common.next", "Next")
                            : root.trText("clone.skip_button", "Skip")
                        accent: workPanelController.cloneSkipLabel === "Next" ? "#2563EB" : "#F59E0B"
                        minWidth: VfTheme.dp(70)
                        enabled: root.hasWorkList && !root.noLiveAccountsPauseRequired
                        onClicked: root.requestAction("work_panel.clone_skip", { source: "clone_queue_header" })
                    }
                    FlatActionButton {
                        // Trạng thái động: chạy → "Đang chạy..." + icon xoay; tạm dừng →
                        // Tiếp tục; rảnh → Clone. Có SVG icon (fast-forward / clockwise).
                        actionId: "work_panel.start_queue"
                        readonly property bool _cloneRunning: root.hasRunningQueueRow()
                        text: root.noLiveAccountsPauseRequired
                            ? root.trText("clone.continue_clone", "Continue Clone")
                            : root.authPauseRequired
                            ? root.trText("clone.resume_queue", "Resume Queue")
                            : _cloneRunning
                            ? root.trText("clone.running_button", "Đang chạy...")
                            : root.trText("clone.clone_button", "Clone")
                        iconName: _cloneRunning ? "clockwise-arrows" : "fast-forward-button"
                        spinning: _cloneRunning
                        selected: true
                        minWidth: VfTheme.dp(118)
                        enabled: root.hasWorkList
                        onClicked: {
                            if (_cloneRunning)
                                return
                            root.requestQueueAction("work_panel.start_queue")
                        }
                    }
                }
            }

            Rectangle {
                id: activeJobCard
                Layout.fillWidth: true
                // Chiều cao TỰ theo nội dung (cột anchored top) → hết băng trống dưới.
                Layout.preferredHeight: jobInfoColumn.implicitHeight + VfTheme.dp(20)
                radius: VfTheme.dp(8)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border

                // step hiện tại (cache theo queueRows/selectedQueueRowId, không theo clock)
                readonly property var step: {
                    void root.queueRows
                    void root.selectedQueueRowId
                    return root.activeQueueStepInfo()
                }

                ColumnLayout {
                    id: jobInfoColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: VfTheme.dp(10)
                    spacing: VfTheme.dp(8)

                    // ── HÀNG 1 — Tiêu đề (trái) + nút Characters (phải) ──
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)
                        Text {
                            Layout.fillWidth: true
                            text: root.activeQueueTitle()
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(13)
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }
                        VfButton {
                            text: root.trText("clone.manage_characters", "Characters")
                            minWidth: VfTheme.dp(100)
                            visible: workPanelController.cloneHasCharacters && (workPanelController.cloneIsManualCharMode || workPanelController.clonePendingNextJob)
                            onClicked: root.requestRouteTool("route_characters", "work_panel.route_characters")
                        }
                    }

                    // ── HÀNG 2 — STATUS chip (nổi bật, NGAY TRÊN 4 step) + ĐẾM (phải) ──
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)
                        Rectangle {
                            id: statusChip
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(34)
                            radius: VfTheme.dp(9)
                            // Nền + viền tint theo MÀU trạng thái → chip nổi, không "cùi".
                            readonly property color tone: activeJobCard.step.color
                            color: Qt.rgba(tone.r, tone.g, tone.b, 0.12)
                            border.color: Qt.rgba(tone.r, tone.g, tone.b, 0.34)
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(10)
                                anchors.rightMargin: VfTheme.dp(10)
                                spacing: VfTheme.dp(7)
                                VfAppIcon {
                                    id: chipIcon
                                    name: activeJobCard.step.icon
                                    size: VfTheme.dp(15)
                                    framed: false
                                    color: statusChip.tone
                                    Layout.alignment: Qt.AlignVCenter
                                    RotationAnimator {
                                        target: chipIcon
                                        running: activeJobCard.step.indeterminate && chipIcon.visible && VfTheme.motion
                                        loops: Animation.Infinite
                                        from: 0
                                        to: 360
                                        duration: 1600
                                        onRunningChanged: if (!running) chipIcon.rotation = 0
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: activeJobCard.step.label
                                    color: statusChip.tone
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(12)
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                Text {
                                    visible: !activeJobCard.step.failed && activeJobCard.step.step > 0
                                    text: root.trText("clone.step_word", "Bước") + " " + String(activeJobCard.step.step) + "/" + String(activeJobCard.step.total)
                                    color: Qt.rgba(statusChip.tone.r, statusChip.tone.g, statusChip.tone.b, 0.78)
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                        MiniStat { label: root.trText("clone.scenes_label", "Scenes"); value: String(root.activeQueueSceneCount()) }
                        MiniStat { label: root.trText("clone.videos_label", "Videos"); value: String(root.activeQueueVideoCount()) }
                    }

                    // ── HÀNG 3 — STEP: stepper pills (dưới status) ──
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(4)
                        Repeater {
                            model: [
                                { n: 1, label: (void i18n.revision, i18n.t("clone_workspace.step_download", "Tải")) },
                                { n: 2, label: (void i18n.revision, i18n.t("clone_workspace.step_analyze", "Phân tích")) },
                                { n: 3, label: (void i18n.revision, i18n.t("clone_workspace.step_chars", "Nhân vật")) },
                                { n: 4, label: (void i18n.revision, i18n.t("clone_workspace.step_video", "Video")) }
                            ]
                            delegate: Rectangle {
                                readonly property int stepNo: modelData.n
                                readonly property int cur: activeJobCard.step.step
                                readonly property bool isDone: !activeJobCard.step.failed && cur > stepNo
                                readonly property bool isCurrent: !activeJobCard.step.failed && cur === stepNo
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(22)
                                radius: VfTheme.dp(11)
                                color: isDone ? "#059669"
                                     : isCurrent ? activeJobCard.step.color
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

                    ProgressBar {
                        id: jobProgress
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(7)
                        from: 0
                        to: activeJobCard.step.total
                        value: activeJobCard.step.step
                        indeterminate: activeJobCard.step.indeterminate
                        // Thanh bo tròn, fill theo MÀU trạng thái (thay style mặc định cùi).
                        background: Rectangle {
                            radius: height / 2
                            color: VfTheme.surface
                            border.color: VfTheme.border
                            border.width: 1
                        }
                        contentItem: Item {
                            Rectangle {
                                height: parent.height
                                radius: height / 2
                                color: activeJobCard.step.color
                                width: jobProgress.indeterminate
                                    ? parent.width
                                    : Math.max(height, parent.width * jobProgress.visualPosition)
                                opacity: jobProgress.indeterminate ? 0.5 : 1
                                Behavior on width {
                                    enabled: !jobProgress.indeterminate
                                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                    }

                    // Chi tiết backend (progress_message) — chỉ hiện khi CÓ và KHÁC status.
                    Text {
                        Layout.fillWidth: true
                        visible: text.length > 0 && text !== activeJobCard.step.label
                        text: root.activeQueueMessage()
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                        elide: Text.ElideRight
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)

                Row {
                    id: secondaryRow
                    Layout.preferredHeight: VfTheme.dp(30)
                    spacing: VfTheme.dp(5)
                    FlatActionButton {
                        text: root.trText("clone.auto_next_job_label", "Auto run next job")
                        iconName: "fast-forward-button"
                        selected: root.autoNextEnabled
                        minWidth: VfTheme.dp(142)
                        onClicked: {
                            root.autoNextEnabled = !root.autoNextEnabled
                            root.requestAction("work_panel.clone_auto_next", { enabled: root.autoNextEnabled, source: "clone_queue" })
                        }
                    }
                    FlatActionButton {
                        text: root.trText("clone.auto_add_from_worklist", "Tự động add video từ danh sách chờ")
                        iconName: "video-camera"
                        selected: root.autoAddEnabled
                        accent: "#10B981"
                        minWidth: VfTheme.dp(228)
                        onClicked: {
                            root.autoAddEnabled = !root.autoAddEnabled
                            root.requestAction("work_panel.clone_auto_add", { enabled: root.autoAddEnabled, source: "clone_queue" })
                        }
                    }
                }
                Item { Layout.fillWidth: true }
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
                        columns: [
                            // Spacer khớp ĐÚNG width ô ✓ của delegate (40) — thiếu cột
                            // này làm MỌI cột sau lệch ~46dp so với hàng (bug 28/8).
                            { label: "", width: VfTheme.dp(40), alignRight: false },
                            { label: root.trText("clone.col_source", "Nguồn"), width: -1, alignRight: false },
                            { label: root.trText("clone.col_output_model", "Đầu ra / Model"), width: VfTheme.dp(160), alignRight: false },
                            { label: root.trText("clone.col_quality", "Chất lượng"), width: VfTheme.dp(66), alignRight: false },
                            { label: root.trText("clone.col_style", "Style"), width: VfTheme.dp(92), alignRight: false },
                            { label: root.trText("clone.col_language", "Ngôn ngữ"), width: VfTheme.dp(62), alignRight: false },
                            { label: root.trText("master_prompt_tab.table_header_progress", "Tiến độ"), width: VfTheme.dp(88), alignRight: false },
                            { label: root.trText("qml.work.actions", "Actions"), width: VfTheme.dp(124), alignRight: true }
                        ]
                    }

                    ListView {
                        id: queueList
                        objectName: "cloneQueueList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: workPanelController.queueModel
                        clip: true
                        // Incremental QAbstractListModel: a row delta emits dataChanged
                        // for just that row, so only the affected delegate's bindings
                        // re-evaluate — no whole-list rebuild. reuseItems recycles the
                        // delegate pool on the rare structural (add/remove) reset.
                        reuseItems: true
                        cacheBuffer: VfTheme.dp(240)

                        delegate: Rectangle {
                            readonly property var qrow: model.qrow
                            readonly property string rowId: String(qrow.id || qrow.row_id || qrow.batch_id || "")
                            width: queueList.width
                            height: VfTheme.dp(36)
                            color: root.selectedQueueRowId === rowId
                                ? VfTheme.blueFill
                                : (index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft)
                            border.color: root.selectedQueueRowId === rowId ? VfTheme.blueBorderSoft : VfTheme.surfaceSoft

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(8)
                                anchors.rightMargin: VfTheme.dp(8)
                                spacing: VfTheme.dp(6)

                                Text { Layout.fillWidth: true; text: root.rowTitle(qrow); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(10); elide: Text.ElideRight }
                                Text {
                                    Layout.preferredWidth: VfTheme.dp(160)
                                    Layout.minimumWidth: VfTheme.dp(160)
                                    text: root.queueResolvedModelText(qrow)
                                    color: root.queueOutputTone(qrow)
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                    ToolTip.visible: modelMouse.containsMouse
                                    ToolTip.text: text
                                    MouseArea {
                                        id: modelMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        acceptedButtons: Qt.NoButton
                                    }
                                }
                                Text { Layout.preferredWidth: VfTheme.dp(66); Layout.minimumWidth: VfTheme.dp(66); text: String(qrow.quality || "—"); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(10); elide: Text.ElideRight }
                                Text { Layout.preferredWidth: VfTheme.dp(92); Layout.minimumWidth: VfTheme.dp(92); text: String(qrow.style_label || (qrow.use_ai_style ? "AI" : "—")); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(10); elide: Text.ElideRight }
                                Text { Layout.preferredWidth: VfTheme.dp(62); Layout.minimumWidth: VfTheme.dp(62); text: qrow.language ? String(qrow.language).toUpperCase() : root.trText("clone.lang_original", "Gốc"); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(10); elide: Text.ElideRight }
                                Column {
                                    Layout.preferredWidth: VfTheme.dp(88)
                                    Layout.minimumWidth: VfTheme.dp(88)
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 0
                                    Text {
                                        width: VfTheme.dp(88)
                                        text: root.queueProgressText(qrow)
                                        color: root.queueStatusTone(qrow)
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(10)
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        width: VfTheme.dp(88)
                                        text: {
                                            void root.elapsedClockMs
                                            return JobClock.rowElapsedLabel(
                                                qrow,
                                                root.elapsedClockMs,
                                                root.queueStatusKey(qrow)
                                            )
                                        }
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(9)
                                        elide: Text.ElideRight
                                    }
                                }
                                RowLayout {
                                    Layout.preferredWidth: VfTheme.dp(124)
                                    Layout.minimumWidth: VfTheme.dp(124)
                                    Layout.alignment: Qt.AlignRight
                                    spacing: VfTheme.dp(5)

                                    Item { Layout.fillWidth: true }

                                    // Icon-only + tooltip. Chỉ giữ nút thực sự có tác dụng cho 1 queue row:
                                    // Thử lại (failed) + Xoá (khoá khi đang chạy). Bỏ "Xem chi tiết" vì
                                    // scene-analysis của 1 row hàng chờ thường rỗng (chưa xử lý) → không hiện gì.
                                    FlatActionButton {
                                        iconName: "counterclockwise-arrows-button"
                                        minWidth: VfTheme.dp(34)
                                        accent: "#D97706"
                                        visible: root.queueStatusKey(qrow) === "failed"
                                        tooltip: (void i18n.revision, i18n.t("clone_workspace.retry_btn", "Thử lại"))
                                        onClicked: root.actionRequested("job_panel.retry", {
                                            row_id: rowId, row: qrow, source: "clone_queue_row"
                                        })
                                    }
                                    FlatActionButton {
                                        iconName: "file-folder"
                                        minWidth: VfTheme.dp(34)
                                        accent: "#2563EB"
                                        tooltip: (void i18n.revision, i18n.t("clone_workspace.open_folder_tooltip", "Mở thư mục"))
                                        onClicked: root.actionRequested("job_panel.open_folder", {
                                            row_id: rowId, row: qrow, source: "clone_queue_row"
                                        })
                                    }
                                    FlatActionButton {
                                        iconName: "cross-mark"
                                        minWidth: VfTheme.dp(34)
                                        accent: "#DC2626"
                                        enabled: !root.queueIsRunning(qrow)
                                        tooltip: (void i18n.revision, i18n.t("clone_workspace.delete_short", "Xoá"))
                                        onClicked: root.actionRequested("job_panel.delete", {
                                            row_id: rowId, row: qrow, source: "clone_queue_row"
                                        })
                                    }
                                }
                            }

                            // z:-1 keeps this row-select catcher BEHIND the action
                            // buttons (declared earlier → otherwise on top), so it no
                            // longer swallows the per-row button clicks.
                            MouseArea {
                                anchors.fill: parent
                                z: -1
                                acceptedButtons: Qt.LeftButton
                                onClicked: {
                                    root.selectedQueueRowChanged(parent.rowId)
                                    root.actionRequested("work_panel.clone_select_queue_row", {
                                        row_id: parent.rowId,
                                        source: "clone_queue_row_select"
                                    })
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: queueList.count === 0
                        text: root.trText("qml.work.empty_queue", "No queue rows yet.")
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

    component AudioInlineCombo: ComboBox {
        id: combo

        property int minWidth: VfTheme.dp(120)
        property color accent: "#0891B2"
        // Optional semantic tone supplied by a model item. Used by output mode
        // so Auto/Image/Video remain visually distinct without cloning ComboBox.
        property bool useOptionTone: false
        // Tên field chứa cờ/icon trong mỗi option (vd "flag"); rỗng = chỉ text.
        property string iconRole: ""
        // Tên field chứa icon SVG trong resources/icons/app/line. Tách khỏi
        // iconRole để cờ bitmap và icon app không bị trộn đường dẫn.
        property string appIconRole: ""

        // Resolve đường dẫn cờ cho 1 option (mirror VfSelectField.optionIconPath).
        function _iconSource(item) {
            if (!combo.iconRole.length || !item || typeof item !== "object")
                return ""
            var raw = String(item[combo.iconRole] || "")
            if (!raw.length)
                return ""
            if (raw.indexOf(":/") === 0 || raw.indexOf("qrc:/") === 0 || raw.indexOf("file:/") === 0 || raw.indexOf("data:") === 0)
                return raw
            if (raw.indexOf("/") >= 0 || raw.indexOf("\\") >= 0)
                return Qt.resolvedUrl(raw)
            return Qt.resolvedUrl("../../assets/flags/" + raw + ".png")
        }
        function _appIconName(item) {
            if (!combo.appIconRole.length || !item || typeof item !== "object")
                return ""
            return String(item[combo.appIconRole] || "")
        }
        function _currentItem() {
            var items = combo.model || []
            var idx = combo.currentIndex
            if (idx < 0 || idx >= items.length)
                return null
            return items[idx]
        }
        function _tone(name, fallback) {
            var item = combo._currentItem()
            if (!combo.useOptionTone || !item || typeof item !== "object")
                return fallback
            var value = item[name]
            return value === undefined || value === null || String(value).length === 0
                ? fallback : value
        }

        // implicitWidth để dùng được cả trong Row/Flow (positioner đọc width),
        // Layout.* chỉ áp trong RowLayout/ColumnLayout.
        implicitWidth: minWidth
        Layout.preferredWidth: minWidth
        Layout.preferredHeight: VfTheme.dp(34)
        height: VfTheme.dp(34)
        textRole: "label"
        valueRole: "value"
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(12)
        clip: true
        // palette trắng để popup mặc định không bị nền đen / chữ tối
        palette.base: VfTheme.surface
        palette.text: VfTheme.text
        palette.window: VfTheme.surface
        palette.windowText: VfTheme.text
        palette.button: VfTheme.surface
        palette.buttonText: VfTheme.text
        palette.highlight: VfTheme.blueFill
        palette.highlightedText: VfTheme.text

        contentItem: Item {
            VfAppIcon {
                id: curAppIcon
                anchors.left: parent.left
                anchors.leftMargin: VfTheme.dp(8)
                anchors.verticalCenter: parent.verticalCenter
                name: combo._appIconName(combo._currentItem())
                size: VfTheme.dp(16)
                framed: false
                color: combo._tone("textColor", combo.accent)
            }
            Image {
                id: curFlag
                anchors.left: parent.left
                anchors.leftMargin: VfTheme.dp(8)
                anchors.verticalCenter: parent.verticalCenter
                width: visible ? VfTheme.dp(18) : 0
                height: visible ? VfTheme.dp(12) : 0
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: combo._iconSource(combo._currentItem())
                visible: !curAppIcon.visible && String(source).length > 0
            }
            Text {
                anchors.left: curAppIcon.visible ? curAppIcon.right : curFlag.right
                anchors.leftMargin: curAppIcon.visible || curFlag.visible
                    ? VfTheme.dp(6) : 0
                anchors.right: parent.right
                anchors.rightMargin: VfTheme.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                text: combo.displayText
                color: combo.enabled
                    ? combo._tone("textColor", VfTheme.text)
                    : VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                font.weight: combo.useOptionTone ? Font.DemiBold : Font.Medium
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        background: Rectangle {
            radius: VfTheme.dp(6)
            color: combo._tone("fill", VfTheme.surface)
            border.color: combo.activeFocus || combo.useOptionTone
                ? combo._tone("accent", combo.accent)
                : VfTheme.borderStrong
            border.width: combo.useOptionTone ? 2 : 1
        }

        indicator: VfAppIcon {
            x: combo.width - width - VfTheme.dp(8)
            y: Math.round((combo.height - height) / 2)
            name: "chevron-down"
            size: VfTheme.dp(13)
            framed: false
            color: combo._tone("textColor", VfTheme.textSubtle)
        }

        delegate: ItemDelegate {
            id: optionDelegate
            width: combo.width
            height: VfTheme.dp(30)
            highlighted: combo.highlightedIndex === index
            readonly property bool optionSelected: combo.currentIndex === index

            background: Rectangle {
                // Semantic color belongs ONLY to the committed option. Other
                // choices stay neutral; hover/focus gets a subtle gray highlight.
                color: combo.useOptionTone && optionDelegate.optionSelected
                        && modelData && modelData.fill
                    ? modelData.fill
                    : optionDelegate.highlighted ? VfTheme.surfaceSoft : VfTheme.surface
                border.color: combo.useOptionTone && optionDelegate.optionSelected
                        && modelData && modelData.accent
                    ? modelData.accent
                    : optionDelegate.highlighted ? VfTheme.borderStrong : "transparent"
                border.width: optionDelegate.optionSelected
                        || optionDelegate.highlighted ? 1 : 0
                radius: VfTheme.dp(6)
            }

            contentItem: Item {
                VfAppIcon {
                    id: itemAppIcon
                    anchors.left: parent.left
                    anchors.leftMargin: VfTheme.dp(6)
                    anchors.verticalCenter: parent.verticalCenter
                    name: combo._appIconName(modelData)
                    size: VfTheme.dp(16)
                    framed: false
                    color: modelData && modelData.textColor
                        ? modelData.textColor : combo.accent
                }
                Image {
                    id: itemFlag
                    anchors.left: parent.left
                    anchors.leftMargin: VfTheme.dp(6)
                    anchors.verticalCenter: parent.verticalCenter
                    width: visible ? VfTheme.dp(18) : 0
                    height: visible ? VfTheme.dp(12) : 0
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    source: combo._iconSource(modelData)
                    visible: !itemAppIcon.visible && String(source).length > 0
                }
                Text {
                    anchors.left: itemAppIcon.visible ? itemAppIcon.right : itemFlag.right
                    anchors.leftMargin: itemAppIcon.visible || itemFlag.visible
                        ? VfTheme.dp(6) : 0
                    anchors.right: parent.right
                    anchors.rightMargin: VfTheme.dp(6)
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.label
                    color: combo.useOptionTone && optionDelegate.optionSelected
                            && modelData && modelData.textColor
                        ? modelData.textColor : VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: optionDelegate.optionSelected
                        ? Font.DemiBold : Font.Medium
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        popup: Popup {
            y: combo.height + 4
            width: combo.width
            padding: VfTheme.dp(4)
            implicitHeight: Math.min(contentItem.implicitHeight + topPadding + bottomPadding, 260)

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: combo.popup.visible ? combo.delegateModel : null
                currentIndex: combo.highlightedIndex
                reuseItems: true  // perf-lint: disable=R1  small popup list for ComboBox
                ScrollIndicator.vertical: ScrollIndicator { }
            }

            background: Rectangle {
                radius: VfTheme.dp(8)
                color: VfTheme.surface
                border.color: VfTheme.borderStrong
                border.width: 1
            }
        }
    }

    component CharacterConsistencyOptions: Rectangle {
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

            // Picker nhan vat DUNG CHUNG (shared CharacterConsistencyPanel)
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
                showAutoSave: true
                autoSaveEnabled: root.creativeAutosaveEnabled
                showVoiceSync: true
                voiceSyncEnabled: root.flowVoiceLockEnabled
                voiceSyncSupported: root.flowVoiceLockSupported
                voiceSyncHint: root.flowVoiceLockHint()
                voiceSyncCharacterCount: (root.selectedCharacters || []).length
                onVoiceSyncToggled: function(enabled) {
                    root.flowVoiceLockEnabled = enabled
                    root.requestAction("work_panel.clone_voice_lock_toggle", {
                        enabled: enabled,
                        source: "clone_character_options"
                    })
                }
                onScopeToggled: function(category, enabled) { root.setLibraryCategoryEnabled(category, enabled) }
                onScopePolicyChanged: function(category, key, value) { root.saveLibraryPolicy(category, key, value) }
                onAddRequested: root.openCharacterLibrary()
                onAddObjectsRequested: root.openObjectLibrary()
                onAddBackgroundsRequested: root.openBackgroundLibrary()
                onClearRequested: {
                    root.requestAction("work_panel.clone_clear_characters", { source: "clone_character_options" })
                    if (typeof workPanelController !== "undefined") {
                        workPanelController.setCloneLibraryAssetSelection("objects", { mediaIds: [] }, workPanelController.mediaLibraryItems || [])
                        workPanelController.setCloneLibraryAssetSelection("backgrounds", { mediaIds: [] }, workPanelController.mediaLibraryItems || [])
                    }
                }
                onMoveRequested: function(mediaId, offset) { workPanelController.moveRouteCharacterSelection(mediaId, offset) }
                onRemoveRequested: function(mediaId) { workPanelController.removeRouteCharacterSelection(mediaId) }
                onRemoveObjectRequested: function(mediaId) { workPanelController.removeCloneLibraryAssetSelection("objects", mediaId) }
                onRemoveBackgroundRequested: function(mediaId) { workPanelController.removeCloneLibraryAssetSelection("backgrounds", mediaId) }
                onAutoSaveToggled: function(enabled) {
                    root.creativeAutosaveEnabled = enabled
                    root.requestAction("work_panel.clone_creative_autosave_toggle", { enabled: enabled, source: "clone_character_options" })
                }
            }

            // Flow-voice hint + "chưa chọn voice" + summary count removed: redundant.
            // Selected voices already show as chips in selectedVoiceList below.

            ListView {
                id: selectedVoiceList
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 86 : 0
                visible: root.consistencyPanelExpanded
                    && root.characterConsistencyActive()
                    && root.flowVoiceReferencesSupported
                    && (root.selectedVoices || []).length > 0
                orientation: ListView.Horizontal
                spacing: VfTheme.dp(8)
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.selectedVoices || []
                reuseItems: true

                delegate: Rectangle {
                    required property var modelData

                    width: VfTheme.dp(280)
                    height: VfTheme.dp(78)
                    radius: VfTheme.dp(12)
                    color: VfTheme.blueFill
                    border.color: VfTheme.blueBorderSoft
                    border.width: 1

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.openVoicePicker()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(8)
                        spacing: VfTheme.dp(10)

                        Rectangle {
                            Layout.preferredWidth: VfTheme.dp(60)
                            Layout.preferredHeight: VfTheme.dp(60)
                            radius: VfTheme.dp(10)
                            color: VfTheme.blueFill
                            border.color: VfTheme.blueBorderSoft
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: root.selectedVoiceDisplayName(modelData).length > 0
                                    ? root.selectedVoiceDisplayName(modelData).substring(0, 1).toUpperCase()
                                    : "V"
                                color: VfTheme.blueText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(20)
                                font.weight: Font.Bold
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(3)

                            Text {
                                Layout.fillWidth: true
                                text: root.selectedVoiceDisplayName(modelData)
                                color: VfTheme.blueText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.selectedVoiceCardSummary(modelData)
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(6)

                                Item { Layout.fillWidth: true }

                                AssetActionButton {
                                    label: "✕"
                                    tooltip: root.trText("clone.voice_remove", "Remove voice")
                                    tone: "danger"
                                    onClicked: workPanelController.removeCloneVoiceSelection(
                                        String(modelData.media_id || modelData.id || "")
                                    )
                                }
                            }
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: false
                text: root.trText("clone.creative_directions_label", "Creative directions")
                color: VfTheme.violetText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            TextArea {
                Layout.fillWidth: true
                Layout.preferredHeight: 0
                visible: false
                text: root.remixInstructions
                placeholderText: root.trText("clone.creative_directions_placeholder", "Optional: describe character style, clothing, camera notes, or consistency constraints.")
                wrapMode: TextEdit.Wrap
                color: VfTheme.text
                placeholderTextColor: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                onTextChanged: {
                    if (String(root.remixInstructions) === String(text))
                        return
                    root.remixInstructions = String(text || "")
                    root.requestAction("work_panel.clone_remix_instructions", {
                        value: root.remixInstructions,
                        source: "clone_creative_directions_legacy"
                    })
                }
                background: Rectangle {
                    radius: VfTheme.dp(5)
                    color: VfTheme.surface
                    border.color: VfTheme.violetBorderSoft
                }
            }
        }
    }

    // Trên màn hình hẹp, ô yêu cầu riêng được thu thành một nút ở block Sao
    // chép. Popup chỉ thay đổi cách trình bày; dữ liệu và debounce vẫn dùng
    // chung một đường với ô inline trên desktop.
    Dialog {
        id: cloneRecipeDialog
        parent: Overlay.overlay
        modal: true
        width: VfDialogMetrics.width(Overlay.overlay, 620, 48)
        x: VfDialogMetrics.centerX(Overlay.overlay, width)
        y: VfDialogMetrics.centerY(Overlay.overlay, implicitHeight)
        title: root.recipeChipLabel(root.primaryRecipeKey)

        header: VfDialogHeader {
            title: cloneRecipeDialog.title
            iconName: "memo"
            onCloseClicked: cloneRecipeDialog.close()
        }

        background: Rectangle {
            radius: VfTheme.dp(14)
            color: VfTheme.surface
            border.color: VfTheme.blueBorderSoft
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                text: root.recipeModeExplanation()
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                wrapMode: Text.WordWrap
            }

            TextArea {
                id: compactRecipeField
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(132)
                text: String((root.remixRecipe || ({}))[root.primaryRecipeKey] || "")
                placeholderText: (void i18n.revision, root.recipeChipPlaceholder(root.primaryRecipeKey))
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                color: VfTheme.text
                placeholderTextColor: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                topPadding: VfTheme.dp(8)
                bottomPadding: VfTheme.dp(8)
                leftPadding: VfTheme.dp(10)
                rightPadding: VfTheme.dp(10)
                background: Rectangle {
                    radius: VfTheme.dp(7)
                    color: VfTheme.canvas
                    border.color: compactRecipeField.activeFocus
                        ? VfTheme.blueBorder : VfTheme.borderSoft
                }
                onTextChanged: root.queuePrimaryRecipeUpdate(text)
            }
        }

        footer: DialogButtonBox {
            standardButtons: DialogButtonBox.Close
        }
    }

    Dialog {
        id: cloneVoiceGuardDialog
        parent: Overlay.overlay
        modal: true
        width: VfDialogMetrics.width(Overlay.overlay, 420, 48)
        x: VfDialogMetrics.centerX(Overlay.overlay, width)
        y: VfDialogMetrics.centerY(Overlay.overlay, implicitHeight)

        property string guardMessage: ""

        background: Rectangle {
            radius: VfTheme.dp(14)
            color: VfTheme.surface
            border.color: VfTheme.blueFill
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                text: root.trText("clone.voice_reference_dialog_title", "Flow Voice")
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(16)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: cloneVoiceGuardDialog.guardMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                wrapMode: Text.WordWrap
            }
        }

        footer: DialogButtonBox {
            standardButtons: DialogButtonBox.Ok
        }
    }

    Dialog {
        id: cloneVoicePickerDialog
        parent: Overlay.overlay
        modal: true
        width: VfDialogMetrics.width(Overlay.overlay, 680, 48)
        height: VfDialogMetrics.height(Overlay.overlay, 520, 48)
        x: VfDialogMetrics.centerX(Overlay.overlay, width)
        y: VfDialogMetrics.centerY(Overlay.overlay, height)
        title: root.trText("clone.voice_picker_title", "Select Flow voices")
        header: VfDialogHeader {
            title: cloneVoicePickerDialog.title
            iconName: "speaker-high-volume"
            onCloseClicked: cloneVoicePickerDialog.close()
        }

        property string selectedMediaId: ""
        property string targetSpeaker: ""

        background: Rectangle {
            radius: VfTheme.dp(14)
            color: VfTheme.surface
            border.color: VfTheme.blueFill
            border.width: 1
        }

        onOpened: {
            var selectedIds = root.selectedVoiceIds()
            cloneVoicePickerDialog.selectedMediaId = selectedIds.length > 0 ? String(selectedIds[0] || "") : ""
            var options = root.voiceTargetOptions()
            cloneVoicePickerDialog.targetSpeaker = options.length > 1 ? String(options[1].value || "") : ""
            voiceTargetSpeakerBox.currentIndex = options.length > 1 ? 1 : 0
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                text: root.trText("clone.voice_picker_subtitle", "Choose reusable Flow voices and optionally map them to a selected character.")
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(10)

                Text {
                    text: root.trText("clone.voice_target_label", "Target speaker")
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    font.weight: Font.DemiBold
                }

                ComboBox {
                    id: voiceTargetSpeakerBox
                    Layout.fillWidth: true
                    model: root.voiceTargetOptions()
                    textRole: "text"

                    background: Rectangle {
                        radius: VfTheme.dp(8)
                        color: VfTheme.surface
                        border.color: VfTheme.blueFill
                    }

                    contentItem: Text {
                        leftPadding: VfTheme.dp(10)
                        rightPadding: VfTheme.dp(28)
                        text: voiceTargetSpeakerBox.displayText
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        verticalAlignment: Text.AlignVCenter
                    }

                    popup: Popup {
                        y: voiceTargetSpeakerBox.height + 4
                        width: voiceTargetSpeakerBox.width
                        padding: VfTheme.dp(4)
                        contentItem: ListView {
                            clip: true
                            model: voiceTargetSpeakerBox.popup.visible ? voiceTargetSpeakerBox.delegateModel : null
                            implicitHeight: contentHeight
                            boundsBehavior: Flickable.StopAtBounds
                            reuseItems: true  // perf-lint: disable=R1  small popup list for ComboBox
                        }
                        background: Rectangle {
                            radius: VfTheme.dp(8)
                            color: VfTheme.surface
                            border.color: VfTheme.blueFill
                        }
                    }

                    onActivated: function(index) {
                        var options = root.voiceTargetOptions()
                        if (index >= 0 && index < options.length)
                            cloneVoicePickerDialog.targetSpeaker = String(options[index].value || "")
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.trText("clone.voice_reference_limit", "Model supports up to {count} Flow voice reference(s).")
                    .replace("{count}", String(root.flowVoiceReferenceLimit))
                color: VfTheme.blueText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                font.weight: Font.DemiBold
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: VfTheme.dp(8)
                model: root.flowVoiceOptions || []
                reuseItems: true

                delegate: Rectangle {
                    required property var modelData

                    width: ListView.view ? ListView.view.width : 540
                    height: VfTheme.dp(64)
                    radius: VfTheme.dp(10)
                    color: String(modelData.media_id || modelData.id || "") === cloneVoicePickerDialog.selectedMediaId ? VfTheme.blueFill : VfTheme.surface
                    border.color: String(modelData.media_id || modelData.id || "") === cloneVoicePickerDialog.selectedMediaId ? "#60A5FA" : VfTheme.blueFill
                    border.width: 1

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: cloneVoicePickerDialog.selectedMediaId = String(modelData.media_id || modelData.id || "")
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(10)
                        spacing: VfTheme.dp(10)

                        Rectangle {
                            Layout.preferredWidth: VfTheme.dp(44)
                            Layout.preferredHeight: VfTheme.dp(44)
                            radius: VfTheme.dp(22)
                            color: VfTheme.blueFill
                            border.color: VfTheme.blueBorderSoft

                            Text {
                                anchors.centerIn: parent
                                text: root.selectedVoiceDisplayName(modelData).length > 0
                                    ? root.selectedVoiceDisplayName(modelData).substring(0, 1).toUpperCase()
                                    : "V"
                                color: VfTheme.blueText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(16)
                                font.weight: Font.Bold
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(2)

                            Text {
                                Layout.fillWidth: true
                                text: root.selectedVoiceDisplayName(modelData)
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.selectedVoiceCardSummary(modelData)
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        footer: DialogButtonBox {
            standardButtons: DialogButtonBox.Cancel

            VfButton {
                text: root.trText("clone.voice_picker_add", "Add Voice")
                tone: "primary"
                enabled: cloneVoicePickerDialog.selectedMediaId.length > 0
                onClicked: {
                    if (typeof workPanelController === "undefined")
                        return
                    var result = workPanelController.setCloneVoiceSelection(
                        {
                            mediaIds: [cloneVoicePickerDialog.selectedMediaId],
                            targetSpeaker: cloneVoicePickerDialog.targetSpeaker,
                            append: true
                        },
                        workPanelController.cloneFlowVoiceOptions || []
                    )
                    if (result.ok)
                        cloneVoicePickerDialog.close()
                    else if (result.blocked)
                        root.showVoiceGuardDialog(root.voiceGuardMessage(result))
                }
            }
        }
    }

    // Lazy: the heavy MediaLibraryDialog tree builds only on first open — NOT during the
    // background route preload, which was building 3 of these off-screen and flooding the
    // render thread ("Cannot find member data") → native Qt6Qml crash. (active: false until
    // the open helper flips it; matches the header dialog's Loader pattern in App.qml.)
    Loader {
        id: cloneCharacterLibraryDialogLoader
        active: false
        sourceComponent: MediaLibraryDialog {
            id: cloneCharacterLibraryDialog
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
                cloneCharacterLibraryDialog.applySelectionResult(result)
            }
        }
    }

    Loader {
        id: cloneObjectLibraryDialogLoader
        active: false
        sourceComponent: MediaLibraryDialog {
            id: cloneObjectLibraryDialog
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
                    result = workPanelController.setCloneLibraryAssetSelection(
                        "objects",
                        selection || ({}),
                        workPanelController.mediaLibraryItems || []
                    )
                }
                cloneObjectLibraryDialog.applySelectionResult(result)
            }
        }
    }

    Loader {
        id: cloneBackgroundLibraryDialogLoader
        active: false
        sourceComponent: MediaLibraryDialog {
            id: cloneBackgroundLibraryDialog
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
                    result = workPanelController.setCloneLibraryAssetSelection(
                        "backgrounds",
                        selection || ({}),
                        workPanelController.mediaLibraryItems || []
                    )
                }
                cloneBackgroundLibraryDialog.applySelectionResult(result)
            }
        }
    }

    component AssetActionButton: Rectangle {
        property string label: ""
        property string tooltip: ""
        property string tone: "neutral"

        signal clicked()

        readonly property string _iconName: {
            if (label === "▶" || label === "▷") return "chevron-right"
            if (label === "◀" || label === "◁") return "chevron-left"
            if (label === "✕" || label === "✗" || label === "×") return "cross-mark"
            if (label === "✓") return "check-mark-button"
            return ""
        }

        width: VfTheme.dp(22)
        height: VfTheme.dp(22)
        radius: VfTheme.dp(11)
        color: tone === "danger" ? VfTheme.redFill : VfTheme.surface
        border.color: tone === "danger" ? VfTheme.redBorderSoft : VfTheme.violetBorderSoft
        border.width: 1

        ToolTip.visible: assetActionMouseArea.containsMouse && tooltip.length > 0
        ToolTip.text: tooltip

        VfAppIcon {
            anchors.centerIn: parent
            name: parent._iconName
            size: VfTheme.dp(12)
            framed: false
            color: tone === "danger" ? "#DC2626" : "#7C3AED"
            visible: parent._iconName.length > 0
        }

        Text {
            anchors.centerIn: parent
            text: parent.label
            color: tone === "danger" ? "#DC2626" : "#7C3AED"
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            font.weight: Font.DemiBold
            visible: parent._iconName.length === 0
        }

        MouseArea {
            id: assetActionMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component ToolGroup: Rectangle {
        radius: VfTheme.dp(7)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        implicitHeight: VfTheme.dp(32)
    }

    component SpacerDot: Rectangle {
        width: 1
        height: VfTheme.dp(26)
        radius: 1
        color: VfTheme.border
    }

    component UploadHintChip: Rectangle {
        property string text: ""

        width: label.implicitWidth + 16
        height: VfTheme.dp(22)
        radius: VfTheme.dp(11)
        color: VfTheme.blueFill
        border.color: VfTheme.blueBorderSoft

        Text {
            id: label
            anchors.centerIn: parent
            text: parent.text
            color: VfTheme.primaryPressed
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            font.weight: Font.DemiBold
        }
    }

    component MiniSelectBox: Rectangle {
        property string label: ""
        property string value: ""
        property color accent: VfTheme.primary
        property int minWidth: VfTheme.dp(140)

        readonly property string _valueIcon: AppIconRegistry.iconForGlyph(value)
        readonly property string _valueText: _valueIcon.length > 0 ? AppIconRegistry.stripGlyph(value) : root.cleanText(value)

        width: Math.max(minWidth, miniValueRow.implicitWidth + miniLabel.implicitWidth + 34)
        height: VfTheme.dp(28)
        radius: VfTheme.dp(6)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: VfTheme.dp(7)
            anchors.verticalCenter: parent.verticalCenter
            width: VfTheme.dp(3)
            height: VfTheme.dp(12)
            radius: VfTheme.dp(2)
            color: accent
        }

        Text {
            id: miniLabel
            anchors.left: parent.left
            anchors.leftMargin: VfTheme.dp(15)
            anchors.verticalCenter: parent.verticalCenter
            text: root.cleanText(label)
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            font.weight: Font.Bold
            elide: Text.ElideRight
        }

        Row {
            id: miniValueRow
            anchors.left: miniLabel.right
            anchors.leftMargin: VfTheme.dp(6)
            anchors.right: parent.right
            anchors.rightMargin: VfTheme.dp(8)
            anchors.verticalCenter: parent.verticalCenter
            spacing: VfTheme.dp(4)

            VfAppIcon {
                name: _valueIcon
                size: VfTheme.dp(11)
                framed: false
                color: VfTheme.text
                anchors.verticalCenter: parent.verticalCenter
                visible: name.length > 0
            }

            Text {
                id: miniValue
                anchors.verticalCenter: parent.verticalCenter
                text: _valueText
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
        }
    }

    component SegmentButton: Rectangle {
        id: segment
        property string text: ""
        property string actionId: ""
        property string tooltip: ""
        property bool selected: false
        property color accent: VfTheme.primary
        property int minWidth: VfTheme.dp(104)
        // tinted = color-code: khi KHÔNG chọn vẫn hiện nền/viền/chữ theo accent
        // (để 3 mode Copy/Remix/Sáng tạo nhận ra ngay); khi chọn = fill + ring đậm.
        property bool tinted: false
        signal clicked()

        readonly property string _iconName: AppIconRegistry.resolveActionIcon(segment.actionId, segment.text, "")

        // implicit* để hoạt động cả trong Flow (đọc width) lẫn RowLayout/ColumnLayout
        // (đọc implicitWidth). Trước dùng width: -> trong RowLayout bị cấp 0 -> chồng nút.
        implicitWidth: Math.max(minWidth, segmentRow.implicitWidth + 30)
        implicitHeight: VfTheme.dp(34)
        radius: VfTheme.dp(7)
        color: !enabled ? VfTheme.surfaceSoft : (selected ? accent : (tinted ? Qt.rgba(accent.r, accent.g, accent.b, 0.12) : VfTheme.surface))
        border.color: !enabled ? VfTheme.border : (selected ? accent : (tinted ? accent : VfTheme.borderSoft))
        border.width: selected ? 2 : 1

        readonly property string _tooltip: AppIconRegistry.resolveActionTooltip(segment.actionId, segment.tooltip, root.cleanText(segment.text))
        ToolTip.visible: segmentMa.containsMouse && segment._tooltip.length > 0
        ToolTip.text: segment._tooltip
        ToolTip.delay: 350

        Row {
            id: segmentRow
            anchors.centerIn: parent
            spacing: VfTheme.dp(5)

            VfAppIcon {
                name: segment._iconName
                size: VfTheme.dp(15)
                framed: false
                anchors.verticalCenter: parent.verticalCenter
                visible: segment._iconName.length > 0
                opacity: !segment.enabled ? 0.45 : (segment.selected ? 1 : 0.72)
                color: !segment.enabled ? VfTheme.textSubtle : (segment.selected ? "#FFFFFF" : (AppIconRegistry.iconColor(segment._iconName) || VfTheme.text))
            }

            Text {
                id: segmentLabel
                anchors.verticalCenter: parent.verticalCenter
                text: root.cleanText(segment.text)
                color: !segment.enabled ? VfTheme.textSubtle : (segment.selected ? "#FFFFFF" : (segment.tinted ? segment.accent : VfTheme.text))
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: segmentMa
            anchors.fill: parent
            enabled: segment.enabled
            hoverEnabled: true
            cursorShape: segment.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: segment.clicked()
        }
    }

    component FlatActionButton: Rectangle {
        id: flat
        property string actionId: ""
        property string text: ""
        property string tooltip: ""
        property string iconName: ""
        property bool spinning: false   // icon xoay (vd trạng thái "đang chạy")
        property bool selected: false
        property color accent: VfTheme.primary
        property int minWidth: VfTheme.dp(96)
        signal clicked()

        readonly property string _iconName: AppIconRegistry.resolveActionIcon(flat.actionId, flat.text, flat.iconName)

        // Icon-only buttons (no text) need far less horizontal padding than
        // labelled ones; the old flat +30 made 5 queue icons (≈45dp each) overflow
        // the 208dp Actions column and spill past the panel edge.
        implicitWidth: Math.max(minWidth, flatRow.implicitWidth + (flat.text === "" ? 14 : 30))
        implicitHeight: VfTheme.dp(34)
        radius: VfTheme.dp(6)
        opacity: flat.enabled ? 1 : 0.58
        color: !flat.enabled ? VfTheme.surfaceSoft : (selected ? accent : VfTheme.surface)
        border.color: !flat.enabled ? VfTheme.borderSoft : (selected ? accent : VfTheme.borderSoft)
        border.width: 1

        readonly property string _tooltip: AppIconRegistry.resolveActionTooltip(flat.actionId, flat.tooltip, root.cleanText(flat.text))
        ToolTip.visible: flatMa.containsMouse && flat._tooltip.length > 0
        ToolTip.text: flat._tooltip
        ToolTip.delay: 350

        Row {
            id: flatRow
            anchors.centerIn: parent
            spacing: VfTheme.dp(5)

            VfAppIcon {
                id: flatIcon
                name: flat._iconName
                size: VfTheme.dp(15)
                framed: false
                anchors.verticalCenter: parent.verticalCenter
                visible: flat._iconName.length > 0
                opacity: !flat.enabled ? 0.45 : (flat.selected ? 1 : 0.78)
                color: !flat.enabled ? VfTheme.textSubtle : (flat.selected ? "#FFFFFF" : flat.accent)
                RotationAnimator {
                    target: flatIcon
                    running: flat.spinning && flatIcon.visible && VfTheme.motion
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 1400
                    onRunningChanged: if (!running) flatIcon.rotation = 0
                }
            }

            Text {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                text: root.cleanText(flat.text)
                color: !flat.enabled ? VfTheme.textSubtle : (flat.selected ? "#FFFFFF" : flat.accent)
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: flatMa
            anchors.fill: parent
            enabled: flat.enabled
            hoverEnabled: true
            cursorShape: flat.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: flat.clicked()
        }
    }

    component MiniStat: Rectangle {
        property string label: ""
        property string value: ""

        Layout.preferredWidth: VfTheme.dp(74)
        Layout.preferredHeight: VfTheme.dp(34)
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

        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(26)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.border

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(8)
            anchors.rightMargin: VfTheme.dp(8)
            spacing: VfTheme.dp(6)

            Repeater {
                model: columns

                Item {
                    readonly property string _icon: AppIconRegistry.iconForGlyph(modelData.label)
                    readonly property string _text: _icon.length > 0 ? "" : modelData.label

                    Layout.fillWidth: modelData.width < 0
                    Layout.preferredWidth: modelData.width > 0 ? modelData.width : 1
                    // Chống nén: không có minimum, RowLayout co TẤT CẢ cột theo tỷ lệ
                    // riêng của header (tổng width khác hàng) → cột lệch dần khi panel
                    // hẹp. Fixed cột giữ nguyên size; cột -1 (title) co thay.
                    Layout.minimumWidth: modelData.width > 0 ? modelData.width : 0
                    Layout.fillHeight: true

                    VfAppIcon {
                        name: parent._icon
                        size: VfTheme.dp(11)
                        framed: false
                        color: VfTheme.textMuted
                        anchors.centerIn: parent
                        visible: name.length > 0
                    }

                    Text {
                        anchors.fill: parent
                        text: parent._text
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                        font.weight: Font.Bold
                        horizontalAlignment: modelData.alignRight ? Text.AlignRight : Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        visible: parent._icon.length === 0
                    }
                }
            }
        }
    }
}
