import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"
import "AppIconRegistry.js" as AppIconRegistry
import "MediaSourceResolver.js" as MediaSourceResolver

Rectangle {
    id: root

    property var meta: ({})
    property var cards: []
    property var cardModel: null
    property var queueRows: []
    property var extendIdeaQueueModel: null
    property var stats: ({})
    property var currentBatchConfig: ({})
    property var routeConfig: ({})
    property var extendSessions: []
    property var extendSession: ({})
    property bool compact: width < 1040
    property int queueAreaHeight: Math.max(142, Math.min(190, Math.round(height * 0.18)))
    property string normalFeature: "text"
    property string selectedQueueRowId: ""
    property int maxMultiAssetReferenceImages: 7
    property int normalMultiAssetReferenceLimit: 7

    signal addCardsRequested(string text)
    signal addBlankRequested()
    signal bulkImportRequested()
    signal submitAllRequested()
    signal clearQueueRequested()
    signal clearCompletedRequested()
    signal startQueueRequested()
    signal pauseQueueRequested()
    signal historyRequested()
    signal routeToolRequested(string action)
    signal editCardRequested(var card)
    signal duplicateCardRequested(var card)
    signal deleteCardRequested(var card)
    signal mediaCardRequested(var card)
    signal submitCardRequested(var card)
    signal removeQueueRowRequested(string rowId)
    signal extendSessionNewRequested()
    signal extendSessionOpenRequested(string sessionKey)
    signal extendSessionDeleteRequested(string sessionKey)
    signal actionRequested(string actionId, var payload)

    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "transparent"
    border.width: 0
    // Khi clone mở char panel, bám content thật của CloneWorkspace để ScrollView
    // cha (leftScroll) grow + scroll được, không khoá layout / ép co work area.
    implicitHeight: (root.routeName() === "clone" && cloneLoader.visible && cloneLoader.item)
        ? Math.max(VfTheme.dp(720), cloneLoader.item.implicitHeight)
        : (root.routeName() === "affiliate" && affiliateWs.visible)
            ? Math.max(VfTheme.dp(720), affiliateWs.implicitHeight)
            : VfTheme.dp(720)

    function metaText(key, fallback) {
        if (root.meta && root.meta[key] !== undefined && root.meta[key] !== null && String(root.meta[key]).length > 0)
            return String(root.meta[key])
        return fallback || ""
    }

    function syncNormalMultiAssetCapabilities() {
        var defaults = root.routeConfig || ({})
        var payload = defaults
        if (typeof workPanelController !== "undefined" && workPanelController && workPanelController.normalMultiAssetCapabilities) {
            var livePayload = workPanelController.normalMultiAssetCapabilities()
            if (livePayload && typeof livePayload === "object")
                payload = livePayload
        }
        root.normalMultiAssetReferenceLimit = Math.max(
            1,
            Number(payload.asset_limit || defaults.multi_asset_reference_limit || root.maxMultiAssetReferenceImages)
        )
    }

    onRouteConfigChanged: {
        syncNormalMultiAssetCapabilities()
        syncRouteConfigUi()
    }

    Component.onCompleted: {
        syncNormalMultiAssetCapabilities()
        syncRouteConfigUi()
        syncSelectedQueueRow()
    }

    // Workspace ẩn không resync theo master/route config (screen + tab ẩn vẫn sống
    // vì App.qml Loader latch) — hiện lại thì onVisibleChanged bù 1 lần.
    // PHẢI sync CẢ feature button (syncRouteConfigUi): feature_type persist trong
    // route config (vd "multi_asset"), nhưng normalFeature mặc định "text". Nếu tab
    // hiện lại mà không có routeConfigChanged thì nút kẹt "Văn bản" trong khi submit
    // đọc route config = multi_asset → "No card ready for multi_asset". Đồng bộ lại
    // mỗi lần hiện tab để UI luôn khớp feature_type thật.
    onVisibleChanged: if (visible) { syncNormalMultiAssetCapabilities(); syncRouteConfigUi() }

    Connections {
        target: typeof masterOptionsController !== "undefined" ? masterOptionsController : null
        enabled: root.visible
        function onConfigChanged() {
            root.syncNormalMultiAssetCapabilities()
        }
    }

    function translatedMeta(key, fallback) {
        var translationKey = metaText(key + "Key", "")
        var fallbackText = metaText(key, fallback)
        return translationKey.length > 0 ? (void i18n.revision, i18n.t(translationKey, fallbackText)) : fallbackText
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

    // Wrapper for the controller slot (the brief TextInputs call root.affiliateBriefField
    // but the QML wrapper was missing → "not a function"; mirrors the other affiliate* helpers).
    function routeName() {
        return root.metaText("route", "normal")
    }

    function isExtendRoute() {
        return root.routeName() === "extend"
    }

    function routeAccent() {
        var route = root.routeName()
        if (route === "clone")
            return VfTheme.violet
        if (route === "transcript")
            return VfTheme.cyan
        if (route === "batch")
            return VfTheme.amber
        if (route === "affiliate")
            return VfTheme.greenBorder
        if (route === "extend")
            return VfTheme.violet
        return VfTheme.primary
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
        if (row.url)
            return String(row.url)
        if (row.local_path)
            return String(row.local_path)
        if (row.prompts && row.prompts.length > 0 && row.prompts[0].prompt)
            return String(row.prompts[0].prompt)
        return String(row.id || row.row_id || row.batch_id || "")
    }

    function queueStatusText(row) {
        if (!row)
            return (void i18n.revision, i18n.t("common.pending", "Pending"))
        return String(row.status || row.job_status || row.state || (void i18n.revision, i18n.t("common.pending", "Pending")))
    }

    function queueProgressText(row) {
        var statusText = root.queueStatusText(row)
        if (!row)
            return statusText

        var progress = Number(row.job_progress !== undefined ? row.job_progress : row.progress)
        var sceneCount = Number(row.scene_count || ((row.dispatcher_summary || {}).total) || 0)
        var videoCount = Number(
            row.video_count !== undefined
                ? row.video_count
                : ((row.dispatcher_summary || {}).complete !== undefined ? (row.dispatcher_summary || {}).complete : 0)
        )

        if (sceneCount > 0)
            return statusText + " " + String(Math.max(0, Math.round(progress))) + "% (" + String(videoCount) + "/" + String(sceneCount) + ")"
        if (progress > 0)
            return statusText + " " + String(Math.max(0, Math.round(progress))) + "%"
        return statusText
    }

    function queueProgressColor(row) {
        var status = String((row || {}).status || (row || {}).job_status || (row || {}).state || "").toLowerCase()
        if (status === "complete" || status === "completed" || status === "done")
            return VfTheme.greenText
        if (status === "failed" || status === "error" || status === "cancelled")
            return VfTheme.redText
        if (status === "running" || status === "generating" || status === "processing" || status === "polling" || status === "upscaling")
            return VfTheme.blueText
        return VfTheme.textMuted
    }

    function queueRowId(row) {
        if (!row)
            return ""
        return String(row.id || row.row_id || row.batch_id || row.job_id || "")
    }

    function selectedQueueRow() {
        var rows = root.queueRows || []
        var selected = String(root.selectedQueueRowId || "")
        if (selected.length > 0) {
            for (var i = 0; i < rows.length; i++) {
                if (root.queueRowId(rows[i]) === selected)
                    return rows[i] || ({})
            }
        }
        return rows.length > 0 ? (rows[0] || ({})) : ({})
    }

    function queueRowOutputFolder(row) {
        if (!row)
            return ""
        return String(row.output_folder || row.session_folder || row.folder || "")
    }

    function queueRowDetailMessage(row) {
        if (!row)
            return ""
        var errorMessage = String(row.error_message || row.error || "")
        if (errorMessage.length > 0)
            return errorMessage
        return String(row.progress_message || row.message || "")
    }

    function queueRowDetailMessageColor(row) {
        var status = String((row || {}).status || (row || {}).job_status || (row || {}).state || "").toLowerCase()
        if (status === "failed" || status === "error" || status === "cancelled")
            return VfTheme.redText
        if (status === "complete" || status === "completed" || status === "done")
            return VfTheme.greenText
        return VfTheme.textMuted
    }

    function queueRowBreakdownPreview(row) {
        var breakdown = (row || {}).dispatcher_breakdown || []
        if (!breakdown || breakdown.length === 0) {
            var scenes = (row || {}).scene_analysis || []
            if (!scenes || scenes.length === 0)
                return ""
            var sceneParts = []
            var sceneLimit = Math.min(3, scenes.length)
            for (var j = 0; j < sceneLimit; j++) {
                var scene = scenes[j] || ({})
                sceneParts.push(String(scene.scene_id || scene.id || ("Scene " + String(j + 1))) + ": " + String(scene.title || scene.prompt || "").slice(0, 40))
            }
            if (scenes.length > sceneLimit)
                sceneParts.push("+" + String(scenes.length - sceneLimit))
            return sceneParts.join("  |  ")
        }
        var parts = []
        var limit = Math.min(3, breakdown.length)
        for (var i = 0; i < limit; i++) {
            var item = breakdown[i] || ({})
            var label = String(item.scene_id || item.job_id || ("#" + String(i + 1)))
            var status = String(item.status || "")
            var progress = Number(item.progress || 0)
            var text = label
            if (status.length > 0)
                text += " " + status
            if (progress > 0)
                text += " " + String(Math.max(0, Math.round(progress))) + "%"
            parts.push(text)
        }
        if (breakdown.length > limit)
            parts.push("+" + String(breakdown.length - limit))
        return parts.join("  |  ")
    }

    function queueRowStatsText(row) {
        if (!row)
            return ""
        var sceneCount = Number(row.scene_count || ((row.dispatcher_summary || {}).total) || 0)
        var videoCount = Number(
            row.video_count !== undefined
                ? row.video_count
                : ((row.dispatcher_summary || {}).complete !== undefined ? (row.dispatcher_summary || {}).complete : 0)
        )
        if (sceneCount > 0)
            return String(videoCount) + "/" + String(sceneCount) + " scene(s)"
        var generated = (row.generated_videos || [])
        if (generated && generated.length > 0)
            return String(generated.length) + " output(s)"
        return ""
    }

    function queueRowClipItems(row) {
        var items = []
        var seen = ({})
        var generated = (row || {}).generated_videos || []
        for (var i = 0; i < generated.length; i++) {
            var clip = generated[i] || ({})
            var path = String(clip.path || clip.file_path || "")
            if (path.length === 0 || seen[path])
                continue
            seen[path] = true
            items.push({
                label: String(clip.scene_id || clip.name || clip.filename || ("Clip " + String(items.length + 1))),
                path: path
            })
        }
        if (items.length > 0)
            return items
        var breakdown = (row || {}).dispatcher_breakdown || []
        for (var j = 0; j < breakdown.length; j++) {
            var item = breakdown[j] || ({})
            var videoPath = String(item.video_path || item.path || "")
            if (videoPath.length === 0 || seen[videoPath])
                continue
            seen[videoPath] = true
            items.push({
                label: String(item.scene_id || item.job_id || ("Clip " + String(items.length + 1))),
                path: videoPath
            })
        }
        return items
    }

    function queueRowImageItems(row) {
        var items = []
        var seen = ({})
        var sources = []
        if ((row || {}).images && row.images.length)
            sources = sources.concat(row.images)
        var resultImages = ((row || {}).result_data || {}).images || []
        if (resultImages && resultImages.length)
            sources = sources.concat(resultImages)
        for (var i = 0; i < sources.length; i++) {
            var image = sources[i] || ({})
            var path = String(image.path || image.file_path || image.thumbnail_path || "")
            var thumb = String(image.thumbnail_source || image.thumbnail_path || image.thumbnail || path || "")
            if (path.length === 0 || seen[path])
                continue
            seen[path] = true
            items.push({
                label: String(image.name || image.media_name || image.id || ("Image " + String(items.length + 1))),
                path: path,
                thumbnail: thumb
            })
        }
        return items
    }

    function imageSource(value) {
        return MediaSourceResolver.normalizedImageSource(value)
    }

    function queueRowSceneItems(row) {
        var items = []
        var breakdown = (row || {}).dispatcher_breakdown || []
        if (breakdown && breakdown.length > 0) {
            for (var i = 0; i < breakdown.length; i++) {
                var item = breakdown[i] || ({})
                items.push({
                    scene_id: String(item.scene_id || item.job_id || ("Scene " + String(i + 1))),
                    title: "",
                    status: String(item.status || ""),
                    progress: Number(item.progress || 0),
                    error: String(item.error_message || ""),
                    path: String(item.video_path || item.path || "")
                })
            }
            return items
        }
        var scenes = (row || {}).scene_analysis || []
        for (var j = 0; j < scenes.length; j++) {
            var scene = scenes[j] || ({})
            items.push({
                scene_id: String(scene.scene_id || scene.id || ("Scene " + String(j + 1))),
                title: String(scene.title || scene.prompt || scene.notes || ""),
                status: "",
                progress: 0,
                error: "",
                path: ""
            })
        }
        return items
    }

    function syncSelectedQueueRow() {
        var rows = root.queueRows || []
        if (!rows || rows.length === 0) {
            root.selectedQueueRowId = ""
            return
        }
        var selected = String(root.selectedQueueRowId || "")
        if (selected.length === 0) {
            root.selectedQueueRowId = root.queueRowId(rows[0])
            return
        }
        for (var i = 0; i < rows.length; i++) {
            if (root.queueRowId(rows[i]) === selected)
                return
        }
        root.selectedQueueRowId = root.queueRowId(rows[0])
    }

    function cardId(card) {
        if (!card)
            return ""
        return String(card.id || card.row_id || card.batch_id || "")
    }

    function routeModeModel() {
        var currentMode = currentRouteMode("")
        var route = root.routeName()
        if (route === "clone") {
            return [
                { label: (void i18n.revision, i18n.t("qml.work.clone_mode_url", "Video URL")), key: "url", selected: currentMode === "url", minWidth: VfTheme.dp(96) },
                { label: (void i18n.revision, i18n.t("qml.work.clone_mode_local", "Local video")), key: "local", selected: currentMode === "local", minWidth: VfTheme.dp(108) },
                { label: (void i18n.revision, i18n.t("qml.work.clone_mode_channel", "Channel")), key: "channel", selected: currentMode === "channel", minWidth: VfTheme.dp(92) },
                { label: (void i18n.revision, i18n.t("qml.work.clone_mode_creative", "Creative remix")), key: "creative", selected: currentMode === "creative", minWidth: VfTheme.dp(126) }
            ]
        }
        if (route === "transcript") {
            return [
                { label: (void i18n.revision, i18n.t("qml.work.transcript_mode_audio", "Audio files")), key: "audio", selected: currentMode === "audio", minWidth: VfTheme.dp(104) },
                { label: (void i18n.revision, i18n.t("qml.work.transcript_mode_folder", "Folder batch")), key: "folder", selected: currentMode === "folder", minWidth: VfTheme.dp(112) },
                { label: (void i18n.revision, i18n.t("qml.work.transcript_mode_script", "Transcript")), key: "script", selected: currentMode === "script", minWidth: VfTheme.dp(104) }
            ]
        }
        if (route === "batch") {
            return [
                { label: (void i18n.revision, i18n.t("qml.work.batch_mode_prompt", "Prompt batch")), key: "prompt", selected: currentMode === "prompt", minWidth: VfTheme.dp(118) },
                { label: (void i18n.revision, i18n.t("qml.work.batch_mode_refs", "References")), key: "refs", selected: currentMode === "refs", minWidth: VfTheme.dp(106) },
                { label: (void i18n.revision, i18n.t("qml.work.batch_mode_matrix", "Variations")), key: "matrix", selected: currentMode === "matrix", minWidth: VfTheme.dp(104) }
            ]
        }
        if (route === "affiliate") {
            return [
                { label: (void i18n.revision, i18n.t("qml.work.affiliate_mode_product", "Product")), key: "product", selected: currentMode === "product", minWidth: VfTheme.dp(96) },
                { label: (void i18n.revision, i18n.t("qml.work.affiliate_mode_script", "Script")), key: "script", selected: currentMode === "script", minWidth: VfTheme.dp(92) },
                { label: (void i18n.revision, i18n.t("qml.work.affiliate_mode_assets", "Assets")), key: "assets", selected: currentMode === "assets", minWidth: VfTheme.dp(92) },
                { label: (void i18n.revision, i18n.t("qml.work.affiliate_mode_voice", "Voice")), key: "voice", selected: currentMode === "voice", minWidth: VfTheme.dp(86) }
            ]
        }
        if (route === "extend") {
            return [
                { label: (void i18n.revision, i18n.t("qml.work.extend_mode_root", "Root")), key: "root", selected: currentMode === "root", minWidth: VfTheme.dp(86) },
                { label: (void i18n.revision, i18n.t("qml.work.extend_mode_chain", "Extend chain")), key: "chain", selected: currentMode === "chain", minWidth: VfTheme.dp(116) },
                { label: (void i18n.revision, i18n.t("qml.work.extend_mode_timeline", "Timeline")), key: "timeline", selected: currentMode === "timeline", minWidth: VfTheme.dp(96) }
            ]
        }
        return [
            { label: (void i18n.revision, i18n.t("qml.work.normal_mode_t2v", "Text to Video")), key: "t2v", selected: currentMode === "t2v", minWidth: VfTheme.dp(118) },
            { label: (void i18n.revision, i18n.t("qml.work.normal_mode_i2v", "Image to Video")), key: "i2v", selected: currentMode === "i2v", minWidth: VfTheme.dp(124) },
            { label: (void i18n.revision, i18n.t("qml.work.normal_mode_v2v", "Video to Video")), key: "v2v", selected: currentMode === "v2v", minWidth: VfTheme.dp(124) }
        ]
    }

    function routeToolModel() {
        var route = root.routeName()
        if (route === "clone") {
            return [
                { label: (void i18n.revision, i18n.t("qml.work.video_files", "Video Files")), actionId: "work_panel.clone_video_files", routeTool: "clone_video_files", minWidth: VfTheme.dp(106), tone: "primary" },
                { label: (void i18n.revision, i18n.t("qml.work.analyze_scenes", "Analyze Scenes")), actionId: "work_panel.clone_analyze_scenes", routeTool: "clone_analyze_scenes", minWidth: VfTheme.dp(126), tone: "neutral" },
                { label: (void i18n.revision, i18n.t("qml.work.characters", "Characters")), actionId: "work_panel.route_characters", routeTool: "route_characters", minWidth: VfTheme.dp(110), tone: "neutral" },
                { label: (void i18n.revision, i18n.t("qml.work.clone_batch_config", "Clone Batch")), actionId: "work_panel.clone_batch_config", routeTool: "clone_batch_config", minWidth: VfTheme.dp(116), tone: "neutral" }
            ]
        }
        if (route === "transcript") {
            return [
                { label: (void i18n.revision, i18n.t("qml.work.audio_files", "Audio Files")), actionId: "work_panel.transcript_audio_files", routeTool: "transcript_audio_files", minWidth: VfTheme.dp(104), tone: "primary" },
                { label: (void i18n.revision, i18n.t("qml.work.audio_folder", "Audio Folder")), actionId: "work_panel.transcript_audio_folder", routeTool: "transcript_audio_folder", minWidth: VfTheme.dp(116), tone: "neutral" },
                { label: (void i18n.revision, i18n.t("qml.work.characters", "Characters")), actionId: "work_panel.route_characters", routeTool: "route_characters", minWidth: VfTheme.dp(110), tone: "neutral" }
            ]
        }
        if (route === "extend") {
            return [
                { label: (void i18n.revision, i18n.t("qml.work.extend_bulk_import", "Extend Import")), actionId: "work_panel.extend_bulk_import", routeTool: "extend_bulk_import", minWidth: VfTheme.dp(124), tone: "primary" }
            ]
        }
        if (route === "batch") {
            return [
                { label: (void i18n.revision, i18n.t("qml.work.reference_images", "References")), actionId: "work_panel.batch_reference_images", routeTool: "batch_reference_images", minWidth: VfTheme.dp(108), tone: "primary" },
                { label: (void i18n.revision, i18n.t("qml.work.batch_config", "Batch Config")), actionId: "work_panel.batch_config", routeTool: "batch_config", minWidth: VfTheme.dp(116), tone: "neutral" },
                { label: (void i18n.revision, i18n.t("qml.work.batch_actions", "Batch Actions")), actionId: "work_panel.batch_actions", routeTool: "batch_actions", minWidth: VfTheme.dp(122), tone: "neutral" }
            ]
        }
        if (route === "affiliate") {
            return [
                { label: (void i18n.revision, i18n.t("qml.work.product_library", "Products")), actionId: "work_panel.product_library", routeTool: "product_library", minWidth: VfTheme.dp(98), tone: "primary" },
                { label: (void i18n.revision, i18n.t("qml.work.affiliate_character", "Character")), actionId: "work_panel.affiliate_character", routeTool: "affiliate_character", minWidth: VfTheme.dp(108), tone: "neutral" },
                { label: (void i18n.revision, i18n.t("qml.work.affiliate_background", "Background")), actionId: "work_panel.affiliate_background", routeTool: "affiliate_background", minWidth: VfTheme.dp(118), tone: "neutral" }
            ]
        }
        return []
    }

    function routeHelpText() {
        var route = root.routeName()
        if (route === "clone")
            return (void i18n.revision, i18n.t("qml.work.clone_help", "Paste source URLs, select local videos, then analyze scenes or add clone cards to queue."))
        if (route === "transcript")
            return (void i18n.revision, i18n.t("qml.work.transcript_help", "Import audio, paste transcript notes, then queue audio-driven video jobs."))
        if (route === "batch")
            return (void i18n.revision, i18n.t("qml.work.batch_help", "Prepare image prompts, attach reference images, and run batch generation."))
        if (route === "affiliate")
            return (void i18n.revision, i18n.t("qml.work.affiliate_help", "Combine product, character, background and script notes for affiliate video jobs."))
        if (route === "extend")
            return (void i18n.revision, i18n.t("qml.work.extend_help", "Build a root scene and extend chain inside the active session."))
        return (void i18n.revision, i18n.t("qml.work.normal_help", "Create direct video cards from prompt, image, or video input."))
    }

    // Returns enriched product list for the affiliate card grid.
    // Each item: { ...product fields, selected, card_id }
    // Thumbnail is pre-embedded at add-product time (thumbnail_base64 / thumbnail_url).
    // Resolve product image source from embedded thumbnail (set at add-product time).
    // Same priority order as affiliateAssetSource().
    function currentRouteMode(fallback) {
        var config = root.routeConfig || ({})
        var value = config.mode
        if (value === undefined || value === null || String(value).length === 0)
            return fallback || defaultRouteMode()
        return String(value)
    }

    function defaultRouteMode() {
        var route = root.routeName()
        if (route === "clone")
            return "url"
        if (route === "transcript")
            return "audio"
        if (route === "batch")
            return "prompt"
        if (route === "affiliate")
            return "product"
        if (route === "extend")
            return "root"
        return "t2v"
    }

    function syncRouteConfigUi() {
        if (root.routeName() === "normal") {
            // Nguồn chính xác là routeConfig.feature_type (đặt khi load config). Mode_key
            // có dạng "{feature}_{aspect}" (vd "image_16_9") nên KHÔNG so trực tiếp được —
            // trước đây chỉ khớp "t2v/i2v/v2v" → restart với feature image bị rớt về "text".
            var nextFeature = String((root.routeConfig || {}).feature_type || "")
            if (["text", "image", "interpolation", "multi_asset"].indexOf(nextFeature) < 0) {
                // Fallback: suy feature từ mode_key khi thiếu feature_type.
                var mode = currentRouteMode("")
                if (mode === "t2v" || mode === "v2v" || mode.indexOf("text") === 0)
                    nextFeature = "text"
                else if (mode === "i2v" || mode.indexOf("image") === 0)
                    nextFeature = "image"
                else if (mode.indexOf("interpolation") === 0)
                    nextFeature = "interpolation"
                else if (mode.indexOf("multi_asset") === 0)
                    nextFeature = "multi_asset"
            }
            if (["text", "image", "interpolation", "multi_asset"].indexOf(nextFeature) >= 0)
                root.normalFeature = nextFeature
        }
    }

    function requestAction(actionId, payload) {
        var data = {
            action_id: actionId,
            route: root.routeName()
        }
        for (var key in payload || ({}))
            data[key] = payload[key]
        root.actionRequested(actionId, data)
        return data
    }

    function requestAddCards(text) {
        root.requestAction("work_panel.add_from_text", {
            text: text,
            source: "prompt_input"
        })
        root.addCardsRequested(text)
    }

    function requestAddBlank(source) {
        root.requestAction("work_panel.add_blank", {
            source: source || "toolbar"
        })
        root.addBlankRequested()
    }

    function requestBulkImport() {
        root.requestAction("work_panel.bulk_import", { source: "toolbar" })
        root.bulkImportRequested()
    }

    function requestQueueAction(actionId) {
        if (actionId === "work_panel.submit_all") {
            root.submitAllRequested()
            return
        }
        root.requestAction(actionId, { source: "queue_toolbar" })
        if (actionId === "work_panel.pause_queue") {
            root.pauseQueueRequested()
        } else if (actionId === "work_panel.clear_completed") {
            root.clearCompletedRequested()
        } else if (actionId === "work_panel.clear_queue") {
            root.clearQueueRequested()
        } else if (actionId === "work_panel.start_queue") {
            root.startQueueRequested()
        }
    }

    function requestBatchConfigPatch(patch) {
        var cfg = root.currentBatchConfig || ({})
        var data = patch || ({})
        root.requestAction("work_panel.batch_config_patch", {
            source: "batch_toolbar",
            variations: Number(data.variations !== undefined ? data.variations : (cfg.variations || 10)),
            anti_duplicate: cfg.anti_duplicate === undefined ? true : Boolean(cfg.anti_duplicate),
            instructions: String(cfg.instructions || ""),
            character_strategy: String(cfg.character_strategy || "inherit"),
            variation_strength: String(cfg.variation_strength || "balanced"),
            aspect_ratio: String(data.aspect_ratio !== undefined ? data.aspect_ratio : (cfg.aspect_ratio || "16:9")),
            model: String(data.model !== undefined ? data.model : (cfg.model || "GEM_PIX_2")),
            resolution: data.resolution !== undefined ? String(data.resolution || "") : String(cfg.resolution || "")
        })
    }

    function requestHistory(source) {
        root.requestAction("work_panel.history", { source: source || "toolbar" })
        root.historyRequested()
    }

    function requestRouteTool(action, actionId) {
        root.requestAction(actionId, {
            source: "route_tool",
            route_tool: action
        })
        root.routeToolRequested(action)
    }

    function normalFeatureModel() {
        return [
            { label: (void i18n.revision, i18n.t("normal_panel.feature_text", "Text")), key: "text", minWidth: VfTheme.dp(92), icon: "memo" },
            { label: (void i18n.revision, i18n.t("normal_panel.feature_image", "Image")), key: "image", minWidth: VfTheme.dp(104), icon: "framed-picture" },
            { label: (void i18n.revision, i18n.t("normal_panel.feature_interpolation", "2 Images")), key: "interpolation", minWidth: VfTheme.dp(118), icon: "shuffle" },
            { label: (void i18n.revision, i18n.t("normal_panel.feature_multi_asset", "Ingredients")), key: "multi_asset", minWidth: VfTheme.dp(132), icon: "puzzle-piece" }
        ]
    }

    function normalCardModel() {
        if (root.cards && root.cards.length > 0)
            return root.cards
        return [{
            id: "normal_draft_preview",
            title: (void i18n.revision, i18n.t("prompt_card.prompt_label", "PROMPT: #{num}")).replace("{num}", "1"),
            prompt: "",
            status: "draft",
            selected: true,
            route: "normal",
            feature: root.normalFeature,
            preview_only: true
        }]
    }

    function normalCardCount() {
        return Math.max(1, root.cards ? root.cards.length : 0)
    }

    function normalSelectedCount() {
        var items = root.cards || []
        if (items.length === 0)
            return 1
        var count = 0
        for (var i = 0; i < items.length; i++) {
            if (items[i].selected !== false)
                count += 1
        }
        return count
    }

    function normalAssetCount() {
        if (root.normalFeature === "image")
            return 1
        if (root.normalFeature === "interpolation")
            return 2
        if (root.normalFeature === "multi_asset")
            return root.normalMultiAssetReferenceLimit
        return 0
    }

    function normalAssetLabel(slotIndex) {
        if (root.normalFeature === "image")
            return (void i18n.revision, i18n.t("prompt_card.add_image", "+ Image"))
        if (root.normalFeature === "interpolation")
            return slotIndex === 0 ? (void i18n.revision, i18n.t("prompt_card.add_start", "+ Start")) : (void i18n.revision, i18n.t("prompt_card.add_end", "+ End"))
        return (void i18n.revision, i18n.t("prompt_card.add_asset", "+ Asset {index}")).replace("{index}", String(slotIndex + 1))
    }

    function requestQueueFocus() {
        root.requestAction("work_panel.queue_focus", { source: "header_toggle" })
        queueList.positionViewAtBeginning()
    }

    onQueueRowsChanged: syncSelectedQueueRow()

    function requestRemoveQueueRow(rowId) {
        root.requestAction("work_panel.queue_delete_row", {
            row_id: rowId,
            source: "queue_row"
        })
        root.removeQueueRowRequested(rowId)
    }

    function handlePromptCardAction(actionId, payload) {
        var data = root.requestAction(actionId, payload || ({}))
        var card = data.card || ({})
        if (actionId === "prompt_card.media") {
            root.mediaCardRequested(card)
        } else if (actionId === "prompt_card.edit") {
            root.editCardRequested(card)
        } else if (actionId === "prompt_card.duplicate") {
            root.duplicateCardRequested(card)
        } else if (actionId === "prompt_card.delete") {
            root.deleteCardRequested(card)
        } else if (actionId === "prompt_card.submit") {
            root.submitCardRequested(card)
        }
    }

    // Tour: reveal a conditional section by setting UI-only disclosure state
    // directly (immediate visual — no controller round-trip / persisted changes).
    function tourActivateSection(action) {
        var a = String(action || "")
        if (a === "normal:multi_asset") {
            root.normalFeature = "multi_asset"   // reveals Voice Sync
        } else if (a === "clone:remix" && cloneLoader.item) {
            cloneLoader.item.creativeMode = "remix"            // reveals Remix instructions
        } else if (a === "clone:output_image" && cloneLoader.item) {
            cloneLoader.item.outputMode = "image"              // reveals Draw settings
        } else if (a === "transcript:output_image" && transcriptLoader.item) {
            transcriptLoader.item.outputMode = "image"         // reveals image count + Draw
        } else if (a === "consistency:open") {
            if (root.routeName() === "clone" && cloneLoader.item)
                cloneLoader.item.consistencyPanelExpanded = true
            else if (root.routeName() === "transcript" && transcriptLoader.item)
                transcriptLoader.item.consistencyPanelExpanded = true
        }
    }

    // Pre-warm the two lazy sub-workspaces (Clone ~175KB, Transcript) a bit AFTER the
    // Work panel first exists, so the first Clone/Transcript click is instant instead
    // of paying an on-demand async compile. Deferred + one-shot (not eager at
    // construction, which would slow the first work-tab paint); still asynchronous so
    // the background build never freezes the GUI thread.
    property bool _prewarmHeavy: false
    Timer {
        running: true
        interval: 2600
        repeat: false
        onTriggered: root._prewarmHeavy = true
    }

    // Lazy: CloneWorkspace is a ~175KB sub-tree. Instantiate it only on the first
    // clone entry (then keep it via item !== null) and build it ASYNC so opening the
    // Work tab on another route never pays its instantiation cost / never freezes.
    Loader {
        id: cloneLoader
        anchors.fill: parent
        asynchronous: true
        active: root.routeName() === "clone" || item !== null || root._prewarmHeavy
        visible: root.routeName() === "clone"
        sourceComponent: cloneWorkspaceComponent
    }
    Component {
        id: cloneWorkspaceComponent
        CloneWorkspace {
            id: cloneWorkspaceRef
            anchors.fill: parent
            meta: root.meta
            cards: root.cards
            cardModel: root.cardModel
            queueRows: root.queueRows
            stats: root.stats
            routeConfig: root.routeConfig
            selectedQueueRowId: root.selectedQueueRowId
            onActionRequested: (actionId, payload) => root.actionRequested(actionId, payload)
            onAddCardsRequested: text => root.addCardsRequested(text)
            onAddBlankRequested: root.addBlankRequested()
            onBulkImportRequested: root.bulkImportRequested()
            onSubmitAllRequested: root.submitAllRequested()
            onClearQueueRequested: root.clearQueueRequested()
            onStartQueueRequested: root.startQueueRequested()
            onPauseQueueRequested: root.pauseQueueRequested()
            onHistoryRequested: root.historyRequested()
            onRouteToolRequested: action => root.routeToolRequested(action)
            onRemoveQueueRowRequested: rowId => root.removeQueueRowRequested(rowId)
            onSelectedQueueRowChanged: rowId => root.selectedQueueRowId = rowId
        }
    }

    Loader {
        id: transcriptLoader
        anchors.fill: parent
        asynchronous: true
        active: root.routeName() === "transcript" || item !== null || root._prewarmHeavy
        visible: root.routeName() === "transcript"
        sourceComponent: transcriptWorkspaceComponent
    }
    Component {
        id: transcriptWorkspaceComponent
        TranscriptWorkspace {
            anchors.fill: parent
            meta: root.meta
            cards: root.cards
            queueRows: root.queueRows
            stats: root.stats
            routeConfig: root.routeConfig
            onActionRequested: (actionId, payload) => root.actionRequested(actionId, payload)
            onAddCardsRequested: text => root.addCardsRequested(text)
            onSubmitAllRequested: root.submitAllRequested()
            onClearQueueRequested: root.clearQueueRequested()
            onStartQueueRequested: root.startQueueRequested()
            onPauseQueueRequested: root.pauseQueueRequested()
            onHistoryRequested: root.historyRequested()
            onRouteToolRequested: action => root.routeToolRequested(action)
            onRemoveQueueRowRequested: rowId => root.removeQueueRowRequested(rowId)
        }
    }

    // NORMAL route body moved to NormalWorkspace.qml (verbatim copy, props in /
    // signals out — same pattern as CloneWorkspace/BatchWorkspace).
    NormalWorkspace {
        id: normalWorkspace
        anchors.fill: parent
        visible: root.routeName() === "normal"
        cards: root.cards
        normalFeature: root.normalFeature
        normalMultiAssetReferenceLimit: root.normalMultiAssetReferenceLimit
        routeConfig: root.routeConfig
        onActionRequested: (actionId, payload) => root.actionRequested(actionId, payload)
        onAddCardsRequested: text => root.addCardsRequested(text)
        onAddBlankRequested: root.addBlankRequested()
        onBulkImportRequested: root.bulkImportRequested()
        onSubmitAllRequested: root.submitAllRequested()
        onClearQueueRequested: root.clearQueueRequested()
        onClearCompletedRequested: root.clearCompletedRequested()
        onStartQueueRequested: root.startQueueRequested()
        onPauseQueueRequested: root.pauseQueueRequested()
        onHistoryRequested: root.historyRequested()
        onRouteToolRequested: action => root.routeToolRequested(action)
        onMediaCardRequested: card => root.mediaCardRequested(card)
        onEditCardRequested: card => root.editCardRequested(card)
        onDuplicateCardRequested: card => root.duplicateCardRequested(card)
        onDeleteCardRequested: card => root.deleteCardRequested(card)
        onSubmitCardRequested: card => root.submitCardRequested(card)
    }

    // EXTEND route body moved to ExtendWorkspace.qml (verbatim copy, props in /
    // signals out — same pattern as NormalWorkspace/BatchWorkspace).
    ExtendWorkspace {
        anchors.fill: parent
        visible: root.routeName() === "extend"
        cards: root.cards
        cardModel: root.cardModel
        routeConfig: root.routeConfig
        extendSessions: root.extendSessions
        extendSession: root.extendSession
        ideaQueueModel: root.extendIdeaQueueModel
        queueStats: root.stats
        onActionRequested: (actionId, payload) => root.actionRequested(actionId, payload)
        onAddBlankRequested: root.addBlankRequested()
        onBulkImportRequested: root.bulkImportRequested()
        onSubmitAllRequested: root.submitAllRequested()
        onClearQueueRequested: root.clearQueueRequested()
        onClearCompletedRequested: root.clearCompletedRequested()
        onStartQueueRequested: root.startQueueRequested()
        onPauseQueueRequested: root.pauseQueueRequested()
        onExtendSessionNewRequested: root.extendSessionNewRequested()
        onExtendSessionOpenRequested: sessionKey => root.extendSessionOpenRequested(sessionKey)
        onExtendSessionDeleteRequested: sessionKey => root.extendSessionDeleteRequested(sessionKey)
    }

    // BATCH route body moved to BatchWorkspace.qml (data in via props, actions out
    // via signals — same pattern as CloneWorkspace/TranscriptWorkspace). Editing the
    // batch UI now lives in that file and can't touch the other route bodies.
    BatchWorkspace {
        anchors.fill: parent
        visible: root.routeName() === "batch"
        cards: root.cards
        cardModel: root.cardModel
        currentBatchConfig: root.currentBatchConfig
        maxMultiAssetReferenceImages: root.maxMultiAssetReferenceImages
        onActionRequested: (actionId, payload) => root.actionRequested(actionId, payload)
        onAddCardsRequested: text => root.addCardsRequested(text)
        onAddBlankRequested: root.addBlankRequested()
        onBulkImportRequested: root.bulkImportRequested()
        onSubmitAllRequested: root.submitAllRequested()
        onClearQueueRequested: root.clearQueueRequested()
        onStartQueueRequested: root.startQueueRequested()
        onPauseQueueRequested: root.pauseQueueRequested()
        onClearCompletedRequested: root.clearCompletedRequested()
        onMediaCardRequested: card => root.mediaCardRequested(card)
        onEditCardRequested: card => root.editCardRequested(card)
        onDuplicateCardRequested: card => root.duplicateCardRequested(card)
        onDeleteCardRequested: card => root.deleteCardRequested(card)
        onSubmitCardRequested: card => root.submitCardRequested(card)
    }

    // ── AFFILIATE WORKSPACE ──────────────────────────────────────────────────
    // AFFILIATE route body moved to AffiliateWorkspace.qml (verbatim copy, props in
    // / signals out — same pattern as NormalWorkspace/ExtendWorkspace).
    AffiliateWorkspace {
        id: affiliateWs
        anchors.fill: parent
        visible: root.routeName() === "affiliate"
        cards: root.cards
        routeConfig: root.routeConfig
        stats: root.stats
        queueRows: root.queueRows
        onActionRequested: (actionId, payload) => root.actionRequested(actionId, payload)
        onSubmitAllRequested: root.submitAllRequested()
        onClearQueueRequested: root.clearQueueRequested()
        onClearCompletedRequested: root.clearCompletedRequested()
        onStartQueueRequested: root.startQueueRequested()
        onPauseQueueRequested: root.pauseQueueRequested()
        onRouteToolRequested: action => root.routeToolRequested(action)
    }

    ColumnLayout {
        anchors.fill: parent
        visible: root.routeName() !== "clone" && root.routeName() !== "transcript" && root.routeName() !== "normal" && root.routeName() !== "extend" && root.routeName() !== "batch" && root.routeName() !== "affiliate"
        spacing: VfTheme.dp(9)

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(31)
            Layout.minimumHeight: VfTheme.dp(31)
            Layout.maximumHeight: VfTheme.dp(31)
            spacing: VfTheme.dp(7)

            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(31)
                Layout.minimumHeight: VfTheme.dp(31)
                Layout.maximumHeight: VfTheme.dp(31)
                clip: true
                contentWidth: routeModes.implicitWidth
                contentHeight: routeModes.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalFlick
                interactive: contentWidth > width

                Row {
                    id: routeModes
                    spacing: VfTheme.dp(7)
                    height: VfTheme.dp(30)

                    Repeater {
                        model: root.routeModeModel()

                        VfChip {
                            text: modelData.label
                            selected: !!modelData.selected
                            minWidth: modelData.minWidth || 90
                            accent: root.routeAccent()
                            showLeadingIcon: false
                            actionId: "work_panel.mode_toggle"
                            onClicked: root.requestAction("work_panel.mode_toggle", {
                                source: "route_mode",
                                mode: modelData.key
                            })
                        }
                    }
                }
            }

            Item { Layout.preferredWidth: VfTheme.dp(1) }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(34)
            Layout.minimumHeight: VfTheme.dp(34)
            Layout.maximumHeight: VfTheme.dp(34)
            clip: true
            contentWidth: actionStrip.implicitWidth
            contentHeight: actionStrip.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.HorizontalFlick
            interactive: contentWidth > width

            Row {
                id: actionStrip
                spacing: VfTheme.dp(7)
                height: VfTheme.dp(31)

                VfButton {
                    actionId: "work_panel.add_blank"
                    text: (void i18n.revision, i18n.t("qml.work.add_blank", "Add Card"))
                    tone: "primary"
                    minWidth: VfTheme.dp(94)
                    onClicked: root.requestAddBlank("toolbar")
                }

                VfButton {
                    actionId: "work_panel.add_from_text"
                    text: (void i18n.revision, i18n.t("qml.work.add_from_text", "Add From Text"))
                    minWidth: VfTheme.dp(120)
                    onClicked: root.requestAddCards(promptInput.text)
                }

                VfButton {
                    actionId: "work_panel.bulk_import"
                    text: (void i18n.revision, i18n.t("config_panel.bulk_import_short", "Bulk Import"))
                    minWidth: VfTheme.dp(108)
                    onClicked: root.requestBulkImport()
                }

                Repeater {
                    model: root.routeToolModel()

                    VfButton {
                        actionId: modelData.actionId
                        text: modelData.label
                        tone: modelData.tone || "neutral"
                        minWidth: modelData.minWidth || 96
                        onClicked: root.requestRouteTool(modelData.routeTool, modelData.actionId)
                    }
                }

                VfButton {
                    actionId: "work_panel.history"
                    text: (void i18n.revision, i18n.t("qml.history.title_short", "History"))
                    minWidth: VfTheme.dp(86)
                    onClicked: root.requestHistory("toolbar")
                }
            }
        }

        // Extend session list lives in ExtendWorkspace.qml (route body) now — the old
        // duplicate block here was dead (nested in the generic body that hides on extend).

        ResponsiveSplit {
            id: normalSplit
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(380, Math.min(540, Math.round(root.height * 0.50)))
            Layout.minimumHeight: VfTheme.dp(360)
            gap: VfTheme.dp(9)
            rightRatio: 0.30              // cards ~30%; input (fillWidth) takes the rest,
            stackBelow: VfTheme.dp(600)   // no hard min-width → the split never overflows

            VfPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                dense: true
                title: root.translatedMeta("inputTitle", (void i18n.revision, i18n.t("qml.work.prompt_input", "Prompt Input")))
                subtitle: root.routeHelpText()
                accent: root.routeAccent()

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(30)
                    radius: VfTheme.radiusControl
                    color: VfTheme.surfaceSoft
                    border.color: VfTheme.borderSoft
                    clip: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: VfTheme.dp(10)
                        anchors.rightMargin: VfTheme.dp(10)
                        spacing: VfTheme.dp(8)

                        Text {
                            text: String(root.metaText("mode", root.routeName().toUpperCase()))
                            color: root.routeAccent()
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            font.weight: VfTheme.weightStrong
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.translatedMeta("subtitle", (void i18n.revision, i18n.t("qml.work.subtitle", "Reusable QML workspace")))
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            elide: Text.ElideRight
                        }

                        Text {
                            text: (void i18n.revision, i18n.t("qml.work.ready", "Ready"))
                            color: VfTheme.greenBorder
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            font.weight: VfTheme.weightStrong
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: VfTheme.radiusControl
                    color: VfTheme.surface
                    border.color: VfTheme.borderBox
                    clip: true

                    TextArea {
                        id: promptInput
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(10)
                        placeholderText: root.translatedMeta("placeholder", (void i18n.revision, i18n.t("qml.work.placeholder", "Enter one prompt per line")))
                        wrapMode: TextEdit.Wrap
                        color: VfTheme.text
                        placeholderTextColor: VfTheme.textSubtle
                        selectedTextColor: "#FFFFFF"
                        selectionColor: VfTheme.primary
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontBody
                        background: Item {}
                    }
                }
            }

            VfPanel {
                Layout.preferredWidth: normalSplit.rightPaneWidth
                Layout.fillHeight: true
                dense: true
                title: (void i18n.revision, i18n.t("qml.work.prompt_cards", "Prompt Cards"))
                subtitle: String(root.cardModel ? root.cardModel.count : 0)
                accent: VfTheme.borderStrong

                ListView {
                    id: cardList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    reuseItems: true
                    cacheBuffer: height
                    spacing: VfTheme.dp(7)
                    // Bind the QAbstractListModel (cardModel), NOT the QVariantList
                    // (root.cards): a bulk import then appends N delegates via
                    // beginInsertRows instead of rebuilding every delegate. The
                    // delegate reads cardData (model role) and falls back to
                    // modelData only if bound to a plain array elsewhere.
                    model: root.cardModel && root.cardModel.count > 0 ? root.cardModel : []

                    delegate: PromptCard {
                        width: cardList.width
                        route: root.routeName()
                        card: typeof cardData !== "undefined" ? cardData : modelData
                        promptIndex: index
                        selected: (typeof cardData !== "undefined" ? cardData : modelData).selected !== false
                        multiAssetReferenceLimit: root.routeName() === "normal" ? root.normalMultiAssetReferenceLimit : root.maxMultiAssetReferenceImages
                        multiAssetVoiceReferenceLimit: 0
                        multiAssetVoiceReferences: []
                        onActionRequested: (actionId, payload) => root.handlePromptCardAction(actionId, payload)
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: cardList.count === 0
                    text: (void i18n.revision, i18n.t("qml.work.no_cards", "No prompt cards yet. Add a card or import text."))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }

        VfPanel {
            Layout.fillWidth: true
            Layout.preferredHeight: root.queueAreaHeight
            dense: true
            title: (void i18n.revision, i18n.t("qml.work.queue_rows", "Queue Rows"))
            subtitle: ""
            accent: VfTheme.primary

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(31)
                spacing: VfTheme.dp(7)

                VfButton {
                    actionId: "work_panel.submit_all"
                    text: (void i18n.revision, i18n.t("qml.work.submit_all", "Submit All"))
                    tone: "primary"
                    minWidth: VfTheme.dp(112)
                    onClicked: root.requestQueueAction(actionId)
                }

                VfButton {
                    actionId: "work_panel.pause_queue"
                    text: (void i18n.revision, i18n.t("common.pause", "Pause"))
                    minWidth: VfTheme.dp(76)
                    onClicked: root.requestQueueAction(actionId)
                }

                VfButton {
                    actionId: "work_panel.clear_queue"
                    text: (void i18n.revision, i18n.t("common.clear", "Clear"))
                    tone: "danger"
                    minWidth: VfTheme.dp(76)
                    onClicked: root.requestQueueAction(actionId)
                }

                VfButton {
                    visible: root.routeName() === "transcript"
                    actionId: "work_panel.clear_completed"
                    text: (void i18n.revision, i18n.t("qml.work.clear_completed", "Clear done"))
                    minWidth: VfTheme.dp(96)
                    onClicked: root.requestQueueAction(actionId)
                }

                VfButton {
                    actionId: "work_panel.start_queue"
                    text: (void i18n.revision, i18n.t("common.start", "Start"))
                    tone: "primary"
                    minWidth: VfTheme.dp(78)
                    onClicked: root.requestQueueAction(actionId)
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: (void i18n.revision, i18n.t("master.queue_stats", "Queue: {count} jobs")).replace("{count}", String(root.stats.total || 0))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    font.weight: VfTheme.weightControl
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.radiusControl
                color: VfTheme.surface
                border.color: VfTheme.borderSoft
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(24)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(8)
                            anchors.rightMargin: VfTheme.dp(8)
                            spacing: VfTheme.dp(6)

                            Text { Layout.fillWidth: true; text: (void i18n.revision, i18n.t("qml.work.queue_source", "Source / Prompt")); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(10); font.weight: Font.Bold; elide: Text.ElideRight }
                            Text { Layout.preferredWidth: VfTheme.dp(90); text: (void i18n.revision, i18n.t("qml.master.queue_aspect", "Aspect")); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(10); font.weight: Font.Bold; elide: Text.ElideRight }
                            Text { Layout.preferredWidth: VfTheme.dp(120); text: (void i18n.revision, i18n.t("master_prompt_tab.table_header_progress", "Progress")); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(10); font.weight: Font.Bold; elide: Text.ElideRight }
                            Text { Layout.preferredWidth: VfTheme.dp(88); text: (void i18n.revision, i18n.t("qml.work.actions", "Actions")); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(10); font.weight: Font.Bold; horizontalAlignment: Text.AlignRight }
                        }
                    }

                    ListView {
                        id: queueList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        cacheBuffer: height
                        model: workPanelController.queueModel
                        reuseItems: true

                        delegate: Rectangle {
                            width: queueList.width
                            height: VfTheme.dp(34)
                            readonly property var qrow: model.qrow
                            readonly property string rowId: root.queueRowId(qrow)
                            readonly property bool isSelected: root.selectedQueueRowId === rowId
                            color: isSelected ? VfTheme.blueFill : (index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft)
                            border.color: isSelected ? VfTheme.blueBorderSoft : VfTheme.surfaceSoft

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.selectedQueueRowId = parent.rowId
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(8)
                                anchors.rightMargin: VfTheme.dp(8)
                                spacing: VfTheme.dp(6)

                                Text {
                                    Layout.fillWidth: true
                                    text: root.rowTitle(qrow)
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.preferredWidth: VfTheme.dp(90)
                                    text: String(qrow.aspect || qrow.ratio || "16:9")
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.preferredWidth: VfTheme.dp(120)
                                    text: root.queueProgressText(qrow)
                                    color: root.queueProgressColor(qrow)
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    elide: Text.ElideRight
                                }

                                VfButton {
                                    actionId: "work_panel.queue_delete_row"
                                    Layout.preferredHeight: VfTheme.dp(25)
                                    text: (void i18n.revision, i18n.t("common.delete_short", "Delete"))
                                    minWidth: VfTheme.dp(72)
                                    tone: "danger"
                                    onClicked: root.requestRemoveQueueRow(String(qrow.id || qrow.row_id || qrow.batch_id || ""))
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: {
                            var baseHeight = 126
                            var clipExtra = root.queueRowClipItems(root.selectedQueueRow()).length > 0 ? 42 : 0
                            var imageExtra = root.queueRowImageItems(root.selectedQueueRow()).length > 0 ? 50 : 0
                            var sceneExtra = Math.min(3, root.queueRowSceneItems(root.selectedQueueRow()).length) * 30
                            return baseHeight + clipExtra + imageExtra + sceneExtra
                        }
                        visible: queueList.count > 0
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(8)
                            spacing: VfTheme.dp(4)

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(6)

                                Text {
                                    Layout.fillWidth: true
                                    text: root.rowTitle(root.selectedQueueRow())
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(11)
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    visible: root.queueRowStatsText(root.selectedQueueRow()).length > 0
                                    radius: VfTheme.dp(8)
                                    color: VfTheme.violetFill
                                    border.color: VfTheme.indigoBorderSoft
                                    implicitWidth: statsLabel.implicitWidth + 12
                                    implicitHeight: VfTheme.dp(22)

                                    Text {
                                        id: statsLabel
                                        anchors.centerIn: parent
                                        text: root.queueRowStatsText(root.selectedQueueRow())
                                        color: VfTheme.indigoText
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(10)
                                        font.weight: Font.Medium
                                    }
                                }

                                VfButton {
                                    visible: root.queueRowOutputFolder(root.selectedQueueRow()).length > 0
                                    actionId: "work_panel.queue_open_output"
                                    text: (void i18n.revision, i18n.t("common.open_folder", "Open Folder"))
                                    minWidth: VfTheme.dp(92)
                                    onClicked: root.requestAction(actionId, {
                                        source: "queue_details",
                                        output_folder: root.queueRowOutputFolder(root.selectedQueueRow())
                                    })
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: root.queueRowDetailMessage(root.selectedQueueRow()).length > 0
                                text: root.queueRowDetailMessage(root.selectedQueueRow())
                                color: root.queueRowDetailMessageColor(root.selectedQueueRow())
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: root.queueRowOutputFolder(root.selectedQueueRow()).length > 0
                                text: (void i18n.revision, i18n.t("common.folder", "Folder")) + ": " + root.queueRowOutputFolder(root.selectedQueueRow())
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                wrapMode: Text.NoWrap
                                elide: Text.ElideMiddle
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: root.queueRowBreakdownPreview(root.selectedQueueRow()).length > 0
                                text: (void i18n.revision, i18n.t("qml.work.breakdown", "Breakdown")) + ": " + root.queueRowBreakdownPreview(root.selectedQueueRow())
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                visible: root.queueRowSceneItems(root.selectedQueueRow()).length > 0
                                spacing: VfTheme.dp(4)

                                Repeater {
                                    model: root.queueRowSceneItems(root.selectedQueueRow()).slice(0, 3)

                                    delegate: Rectangle {
                                        required property var modelData

                                        Layout.fillWidth: true
                                        implicitHeight: VfTheme.dp(26)
                                        radius: VfTheme.dp(6)
                                        color: VfTheme.surface
                                        border.color: VfTheme.border

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: VfTheme.dp(6)
                                            anchors.rightMargin: VfTheme.dp(6)
                                            spacing: VfTheme.dp(6)

                                            Text {
                                                Layout.preferredWidth: VfTheme.dp(52)
                                                text: String(modelData.scene_id || "")
                                                color: VfTheme.blueText
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.dp(10)
                                                font.weight: Font.DemiBold
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: {
                                                    var line = String(modelData.status || "")
                                                    if (Number(modelData.progress || 0) > 0)
                                                        line += (line.length > 0 ? " " : "") + String(Math.max(0, Math.round(Number(modelData.progress || 0)))) + "%"
                                                    if (line.length === 0)
                                                        line = String(modelData.title || "")
                                                    if (String(modelData.error || "").length > 0)
                                                        line += " • " + String(modelData.error || "")
                                                    return line
                                                }
                                                color: String(modelData.error || "").length > 0 ? VfTheme.redText : VfTheme.textMuted
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.dp(10)
                                                elide: Text.ElideRight
                                            }

                                            VfButton {
                                                visible: String(modelData.path || "").length > 0
                                                actionId: "work_panel.queue_open_clip"
                                                text: (void i18n.revision, i18n.t("common.open", "Open"))
                                                minWidth: VfTheme.dp(54)
                                                onClicked: root.requestAction(actionId, {
                                                    source: "queue_scene_row",
                                                    clip_path: String(modelData.path || "")
                                                })
                                            }
                                        }
                                    }
                                }
                            }

                            Flow {
                                Layout.fillWidth: true
                                visible: root.queueRowClipItems(root.selectedQueueRow()).length > 0
                                spacing: VfTheme.dp(6)

                                Repeater {
                                    model: root.queueRowClipItems(root.selectedQueueRow())

                                    delegate: Rectangle {
                                        required property var modelData

                                        radius: VfTheme.dp(8)
                                        color: VfTheme.surface
                                        border.color: VfTheme.blueFill
                                        implicitWidth: clipRow.implicitWidth + 12
                                        implicitHeight: clipRow.implicitHeight + 8

                                        RowLayout {
                                            id: clipRow

                                            anchors.fill: parent
                                            anchors.margins: VfTheme.dp(4)
                                            spacing: VfTheme.dp(4)

                                            Text {
                                                text: String(modelData.label || "")
                                                color: VfTheme.blueText
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.dp(10)
                                                font.weight: Font.Medium
                                                elide: Text.ElideRight
                                            }

                                            VfButton {
                                                actionId: "work_panel.queue_open_clip"
                                                text: (void i18n.revision, i18n.t("common.open", "Open"))
                                                minWidth: VfTheme.dp(54)
                                                onClicked: root.requestAction(actionId, {
                                                    source: "queue_details_clip",
                                                    clip_path: String(modelData.path || "")
                                                })
                                            }
                                        }
                                    }
                                }
                            }

                            Flow {
                                Layout.fillWidth: true
                                visible: root.queueRowImageItems(root.selectedQueueRow()).length > 0
                                spacing: VfTheme.dp(6)

                                Repeater {
                                    model: root.queueRowImageItems(root.selectedQueueRow()).slice(0, 6)

                                    delegate: Rectangle {
                                        required property var modelData

                                        radius: VfTheme.dp(8)
                                        color: VfTheme.surface
                                        border.color: VfTheme.amberBorderSoft
                                        implicitWidth: imageOutputRow.implicitWidth + 12
                                        implicitHeight: imageOutputRow.implicitHeight + 8

                                        RowLayout {
                                            id: imageOutputRow

                                            anchors.fill: parent
                                            anchors.margins: VfTheme.dp(4)
                                            spacing: VfTheme.dp(5)

                                            Rectangle {
                                                Layout.preferredWidth: VfTheme.dp(30)
                                                Layout.preferredHeight: VfTheme.dp(30)
                                                radius: VfTheme.dp(5)
                                                color: VfTheme.amberFill
                                                clip: true

                                                Image {
                                                    anchors.fill: parent
                                                    source: root.imageSource(modelData.thumbnail || modelData.path || "")
                                                    fillMode: Image.PreserveAspectCrop
                                                    asynchronous: true
                                                    visible: String(source).length > 0
                                                }
                                            }

                                            Text {
                                                text: String(modelData.label || "")
                                                color: VfTheme.amberText
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.dp(10)
                                                font.weight: Font.Medium
                                                elide: Text.ElideRight
                                            }

                                            VfButton {
                                                actionId: "work_panel.queue_open_clip"
                                                text: (void i18n.revision, i18n.t("common.open", "Open"))
                                                minWidth: VfTheme.dp(54)
                                                onClicked: root.requestAction(actionId, {
                                                    source: "queue_details_image",
                                                    clip_path: String(modelData.path || "")
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: queueList.count === 0
                        text: (void i18n.revision, i18n.t("qml.work.empty_queue", "No queue rows yet."))
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // NormalSeparator / NormalButtonGroup / NormalToolbarButton moved to their own
    // files (qml/components/Normal*.qml) — same-directory auto-resolve. Isolates the
    // shared toolbar primitives so editing a route here can't break them.

    component BatchSelectBox: Rectangle {
        id: select

        property string text: ""
        property int minWidth: VfTheme.dp(120)

        implicitWidth: minWidth
        implicitHeight: VfTheme.dp(44)
        radius: VfTheme.dp(7)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong

        Text {
            anchors.left: parent.left
            anchors.leftMargin: VfTheme.dp(12)
            anchors.right: parent.right
            anchors.rightMargin: VfTheme.dp(12)
            anchors.verticalCenter: parent.verticalCenter
            text: root.cleanText(select.text)
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontControl
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    component BatchComboBox: Rectangle {
        id: box

        property string label: ""
        property var options: []
        property var value: ""
        property int minWidth: VfTheme.dp(120)
        property color accent: VfTheme.primary

        signal selected(var value)

        function optionIndex(searchValue) {
            var items = box.options || []
            for (var i = 0; i < items.length; i++) {
                if (String((items[i] || {}).value) === String(searchValue))
                    return i
            }
            return items.length > 0 ? 0 : -1
        }

        function optionLabel(item) {
            if (!item)
                return ""
            return root.cleanText(String(item.label || item.text || item.value || ""))
        }

        function displayLabel() {
            var idx = box.optionIndex(box.value)
            var items = box.options || []
            var optionText = idx >= 0 && idx < items.length ? box.optionLabel(items[idx]) : root.cleanText(combo.displayText)
            var labelText = root.cleanText(box.label)
            return labelText.length > 0 ? labelText + ": " + optionText : optionText
        }

        implicitWidth: box.minWidth
        implicitHeight: VfTheme.dp(36)
        radius: VfTheme.dp(7)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        border.width: 1
        clip: true

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: VfTheme.dp(6)
            anchors.top: parent.top
            anchors.topMargin: VfTheme.dp(7)
            width: VfTheme.dp(3)
            height: VfTheme.dp(8)
            radius: VfTheme.dp(2)
            color: box.accent
        }

        ComboBox {
            id: combo
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(8)
            anchors.rightMargin: VfTheme.dp(6)
            anchors.topMargin: VfTheme.dp(6)
            anchors.bottomMargin: VfTheme.dp(5)
            model: box.options || []
            textRole: "label"
            valueRole: "value"
            currentIndex: box.optionIndex(box.value)
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            onActivated: box.selected(combo.currentValue)

            contentItem: Text {
                leftPadding: VfTheme.dp(10)
                rightPadding: VfTheme.dp(20)
                text: box.displayLabel()
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            background: Rectangle {
                radius: VfTheme.dp(5)
                color: "transparent"
                border.color: "transparent"
            }

            indicator: Text {
                x: combo.width - width - VfTheme.dp(5)
                y: Math.round((combo.height - height) / 2)
                text: "v"
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
            }

            delegate: ItemDelegate {
                width: combo.width
                height: VfTheme.dp(48)
                highlighted: combo.highlightedIndex === index

                contentItem: Text {
                    leftPadding: VfTheme.dp(12)
                    rightPadding: VfTheme.dp(12)
                    text: box.optionLabel(modelData)
                    color: highlighted ? VfTheme.primary : VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                background: Rectangle {
                    color: highlighted ? VfTheme.primaryFill : VfTheme.surface
                    border.color: highlighted ? VfTheme.primary : "transparent"
                    border.width: highlighted ? 1 : 0
                }
            }

            popup: Popup {
                y: combo.height + VfTheme.dp(2)
                width: combo.width
                implicitHeight: Math.min(contentItem.implicitHeight, VfTheme.dp(240))
                padding: 0

                contentItem: ListView { // perf-lint: disable=R1  ComboBox popup dropdown—tiny fixed list, recycling overhead > benefit
                    clip: true
                    implicitHeight: contentHeight
                    model: combo.popup.visible ? combo.delegateModel : null
                    currentIndex: combo.highlightedIndex
                    ScrollIndicator.vertical: ScrollIndicator {}
                }

                background: Rectangle {
                    radius: VfTheme.dp(6)
                    color: VfTheme.surface
                    border.color: VfTheme.borderStrong
                    border.width: 1
                }
            }
        }

        ToolTip.visible: combo.hovered
        ToolTip.text: root.cleanText(box.label)
        ToolTip.delay: 450
    }

    // BatchPromptCard moved to its own file (qml/components/BatchPromptCard.qml) —
    // same-dir auto-resolve; root.maxMultiAssetReferenceImages is now a passed prop.

    // NormalPromptCard moved to qml/components/NormalPromptCard.qml (0-dep verbatim).
}
