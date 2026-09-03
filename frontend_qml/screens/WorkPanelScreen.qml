import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../dialogs"
import "../theme"
import "../components/TourPreviewData.js" as TourPreviewData
import "../components/SubtitleContentIntent.js" as SubtitleIntent

Item {
    id: screen
    objectName: "workPanelScreen"

    // Emitted when the user picks "Hướng dẫn" in the Bulk Import dropdown → App starts
    // the in-dialog bulk-import tour (App wires this via workPanelLoader.item).
    signal bulkImportGuideRequested(string mode)

    property string route: "normal"
    // Job panel rail GIỮ NGUYÊN mọi tab (kể cả affiliate — nó hiện SCENE job đang
    // chạy, khác cột SẢN XUẤT của workspace vốn hiện VIDEO/batch).
    property bool showRightRail: width >= 1280
    property bool compactJobRail: !showRightRail
    property bool rightRailExpanded: false
    property string mediaTargetCardId: ""
    property string mediaTargetMode: "card_attach"
    property string mediaTargetCharacterId: ""
    property int mediaTargetSlotIndex: -1
    property int mediaTargetExtendRootSlot: -1
    property int mediaTargetAffiliateStartSlot: -1
    property string mediaTargetAffiliateAssetType: ""
    property string mediaTargetProductId: ""
    property string mediaTargetColumnId: ""   // affiliate column-targeted asset add ("" = shared default)
    property string mediaTargetProductImageMode: ""
    property string pendingBulkImportMode: ""
    property var pendingBulkImportImagePaths: []
    property string pendingBulkImportFeature: ""
    property int maxMultiAssetReferenceImages: 7
    property int pendingBulkImportAssetsPerCard: maxMultiAssetReferenceImages
    property var pendingExtendDeleteSession: ({})
    property var currentBatchConfig: workPanelController.currentBatchConfig || ({})
    // Keep one detached, atomic snapshot for the workspace. Binding the child
    // directly to currentRouteConfig made its change handler re-enter the same
    // controller property while a route switch was emitting routeConfigChanged.
    property var workspaceRouteConfig: ({})
    property var clonePromptEditContext: ({})
    property bool pendingClonePromptRegen: false
    property var cloneSceneRegenContext: ({})
    property var cloneSceneDeleteContext: ({})
    property var transcriptPromptEditContext: ({})
    property bool pendingTranscriptPromptRegen: false
    property var transcriptSceneRegenContext: ({})
    property var transcriptSceneDeleteContext: ({})
    property var jobPromptEditContext: ({})
    property var jobSceneRegenContext: ({})
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property var cloneClearQueuePreview: ({})
    property var cloneDeleteRowContext: ({})
    property var cloneRetryRowContext: ({})
    readonly property bool imageJobRail: route === "batch" || route === "image" || route === "batch_image_generation"
    // Job panel toàn cục hiện cho MỌI route, kể cả affiliate (Bố cần theo dõi job render):
    // HÀNG CHỜ affiliate = batch/biến thể, job panel = scene jobs chi tiết → bổ trợ nhau.
    // Rail width = VfTheme.jobRailWidth (SINGLE source, derived từ nhu cầu thật của job card
    // + chrome, capped logical). Dùng CHUNG với MasterPrompt/VoiceStudio → đồng nhất mọi tab,
    // hết "lệch giữa các tab". Xem VfTheme.jobRailWidth cho chi tiết công thức.
    property int rightRailWidth: showRightRail ? VfTheme.jobRailWidth : 0
    property int compactRailWidth: VfTheme.jobRailWidthCompact(width)
    // Tour preview: while a guided tour runs, swap controller data for baked sample
    // rows so the queue/job panel look alive (empty first-run demo otherwise).
    property var queueRowsSafe: TourState.preview ? TourPreviewData.workQueue() : (workPanelController.queueRows || [])
    property var jobPanelRowsSafe: TourState.preview ? TourPreviewData.workJobs() : (workPanelController.jobPanelRows || [])
    property var queueStatsSafe: TourState.preview ? TourPreviewData.workStats() : (workPanelController.stats || ({}))
    readonly property var _failedQueueRows: (screen.queueRowsSafe || []).filter(function(r) { var s = String(r.status || r.state || "").toLowerCase(); return s === "failed" || s === "error" })
    readonly property var _failedJobPanelRows: (screen.jobPanelRowsSafe || []).filter(function(r) { var s = String(r.status || r.state || "").toLowerCase(); return s === "failed" || s === "error" })

    Timer {
        id: queueRefreshTimer
        interval: 1500
        // repeat MUST be true — a QML Timer defaults to repeat:false (single-shot),
        // which fired this poll exactly ONCE when `running` first turned true (route
        // entry) and then stopped forever. Clone batches run unattended on a daemon
        // thread, so with no user action there were no force=True refresh() calls and
        // the queue/active card froze at the last snapshot while the backend ran.
        repeat: true
        // Transcript + extend queues are live event-driven (BatchAggregateFeed +
        // job_changed handoff) — exclude them from polling. Every other work route
        // still polls as a fallback until migrated.
        running: screen.visible
                 && !TourState.preview
                 && screen.isWorkRoute(screen.route)
                 && !screen.imageJobRail
                 && !(screen.route === "affiliate"
                      && workPanelController.affiliateUiPreview)
                 && screen.route !== "transcript"
                 && screen.route !== "extend"
        onTriggered: {
            // Clone dispatches its scenes to the dispatcher while the batch row can
            // still read 0 active / 0 pending in `stats` (row status only syncs back
            // INSIDE refreshQueueAndStats → list_queue → _sync_dispatch_runtime).
            // Gating on that stale stats snapshot here deadlocked the live queue and
            // froze auto-next: the dispatcher kept running but nothing ever called
            // refreshQueueAndStats to observe it. The Python side already no-ops
            // cheaply when nothing changed (_reload_queue_and_stats guards on the
            // off-thread _queue_dirty flag), so for clone always tick and let it
            // decide; keep the stats short-circuit for the other polled routes.
            var stats = workPanelController.stats || ({})
            var activeCount = Number(stats.generating || stats.running || 0)
            var pendingCount = Number(stats.pending || stats.queued || 0)
            if (screen.route !== "clone" && activeCount <= 0 && pendingCount <= 0)
                return
            workPanelController.refreshQueueAndStats()
        }
    }

    Timer {
        id: routeSyncTimer
        interval: 60
        repeat: false
        onTriggered: screen.syncRoute()
    }

    function cardId(card) {
        if (!card)
            return ""
        return String(card.id || card.row_id || card.batch_id || "")
    }

    function isMultiAssetPayload(payload) {
        var data = payload || ({})
        var mode = String(data.mode || data.card_mode || data.feature || data.type || "").toLowerCase()
        if (mode === "multi_asset" || mode === "multi_asset_video")
            return true
        if (Boolean(data.multi_asset_enabled))
            return true
        var assetIds = data.asset_ids || []
        if (assetIds && assetIds.length > 0)
            return true
        if (data.full_json_text || data.json)
            return true
        var prompt = String(data.prompt || data.text || "").trim()
        if (prompt.length > 1 && prompt.charAt(0) === "{") {
            try {
                var parsed = JSON.parse(prompt)
                return Boolean(parsed.scene || parsed.multi_asset_info || parsed.asset_ids || parsed.multi_asset_enabled)
            } catch (error) {
            }
        }
        return false
    }

    function cardsForVisualTest() {
        return workPanelController.cards || []
    }

    function firstCardForVisualTest() {
        var list = screen.cardsForVisualTest()
        return list && list.length > 0 ? list[0] : ({})
    }

    function firstCardCountForVisualTest() {
        return (screen.cardsForVisualTest() || []).length
    }

    function firstCardPromptForVisualTest() {
        var card = screen.firstCardForVisualTest()
        return String(card.prompt || card.text || "")
    }

    function openFirstCardEditForVisualTest() {
        var card = screen.firstCardForVisualTest()
        var cardId = screen.cardId(card)
        if (cardId.length === 0)
            return false
        screen.handleWorkspaceAction("prompt_card.edit", {
            card_id: cardId,
            row_id: cardId,
            card: card
        })
        return true
    }

    function duplicateFirstCardForVisualTest() {
        var card = screen.firstCardForVisualTest()
        var cardId = screen.cardId(card)
        if (cardId.length === 0)
            return false
        screen.handleWorkspaceAction("prompt_card.duplicate", {
            card_id: cardId,
            row_id: cardId,
            card: card
        })
        return true
    }

    function deleteFirstCardForVisualTest() {
        var card = screen.firstCardForVisualTest()
        var cardId = screen.cardId(card)
        if (cardId.length === 0)
            return false
        screen.handleWorkspaceAction("prompt_card.delete", {
            card_id: cardId,
            row_id: cardId,
            card: card
        })
        return true
    }

    function isWorkRoute(routeName) {
        var routeText = String(routeName || "")
        return routeText === "normal"
            || routeText === "clone"
            || routeText === "transcript"
            || routeText === "extend"
            || routeText === "batch"
            || routeText === "affiliate"
    }

    function perfLog(message) {
        if (typeof appController !== "undefined" && appController && appController.perfLogging)
            console.log("[PERF][WorkPanelScreen] " + message)
    }

    function syncRoute() {
        var routeName = String(screen.route || "")
        if (!screen.isWorkRoute(routeName)) {
            screen.perfLog("syncRoute ignored non-work route=" + routeName)
            return
        }
        var started = Date.now()
        workPanelController.setRoute(routeName)
        screen.perfLog("syncRoute route=" + routeName + " elapsed=" + String(Date.now() - started) + "ms")
    }

    function scheduleRouteSync() {
        routeSyncTimer.restart()
    }

    function openCharacterImagePicker(character) {
        screen.mediaTargetMode = "character_replace"
        screen.mediaTargetCardId = ""
        screen.mediaTargetCharacterId = String((character || {}).id || (character || {}).media_id || "")
        mediaLibraryDialog.mode = "select"
        mediaLibraryDialog.filterType = "character"
        mediaLibraryDialog.maxSelection = 1
        mediaLibraryDialog.open()
    }

    function resetMediaSelectionTarget() {
        screen.mediaTargetMode = "card_attach"
        screen.mediaTargetCardId = ""
        screen.mediaTargetCharacterId = ""
        screen.mediaTargetExtendRootSlot = -1
        screen.mediaTargetAffiliateStartSlot = -1
        screen.mediaTargetAffiliateAssetType = ""
        screen.mediaTargetProductId = ""
        screen.mediaTargetProductImageMode = ""
        screen.mediaTargetSlotIndex = -1
        mediaLibraryDialog.mode = "manage"
        mediaLibraryDialog.launchContext = "manage"
        mediaLibraryDialog.allowedAssetTypes = []
        mediaLibraryDialog.appendSelection = false
        mediaLibraryDialog.filterType = ""
        mediaLibraryDialog.maxSelection = 9999
    }

    function openMediaLibrary(mode) {
        var m = String(mode || "manage")
        screen.resetMediaSelectionTarget()
        mediaLibraryDialog.mode = m
        mediaLibraryDialog.launchContext = m === "select" ? "usage_picker" : "manage"
        mediaLibraryDialog.allowedAssetTypes = []
        mediaLibraryDialog.filterType = ""
        mediaLibraryDialog.maxSelection = 9999
        mediaLibraryDialog.open()
    }

    function openStyleManager() {
        if (masterConfigPanelRef)
            masterConfigPanelRef.openStyleManagerExternal()
    }

    function closeStyleManagerForTour() {
        if (masterConfigPanelRef && masterConfigPanelRef.closeStyleManagerExternal)
            masterConfigPanelRef.closeStyleManagerExternal()
    }

    function openExtendRootAssetPicker(slotIndex) {
        screen.mediaTargetMode = "extend_root_asset"
        screen.mediaTargetCardId = ""
        screen.mediaTargetCharacterId = ""
        screen.mediaTargetExtendRootSlot = Math.max(0, Number(slotIndex || 0))
        screen.mediaTargetAffiliateAssetType = ""
        screen.mediaTargetProductId = ""
        screen.mediaTargetProductImageMode = ""
        mediaLibraryDialog.mode = "select"
        mediaLibraryDialog.filterType = "image"
        mediaLibraryDialog.maxSelection = 1
        mediaLibraryDialog.open()
    }

    function openAffiliateAssetPicker(assetType, columnId) {
        screen.mediaTargetMode = "affiliate_route_asset"
        screen.mediaTargetCardId = ""
        screen.mediaTargetCharacterId = ""
        screen.mediaTargetAffiliateStartSlot = -1
        screen.mediaTargetColumnId = String(columnId || "")
        screen.mediaTargetAffiliateAssetType = String(assetType || "")
        mediaLibraryDialog.mode = "select"
        mediaLibraryDialog.filterType = screen.mediaTargetAffiliateAssetType
        mediaLibraryDialog.maxSelection = 1
        mediaLibraryDialog.open()
    }

    function openAffiliateStartImagePicker(slotIndex) {
        screen.mediaTargetMode = "affiliate_start_image"
        screen.mediaTargetCardId = ""
        screen.mediaTargetCharacterId = ""
        screen.mediaTargetExtendRootSlot = -1
        screen.mediaTargetAffiliateStartSlot = Math.max(0, Number(slotIndex || 0))
        screen.mediaTargetAffiliateAssetType = ""
        screen.mediaTargetProductId = ""
        screen.mediaTargetProductImageMode = ""
        mediaLibraryDialog.mode = "select"
        mediaLibraryDialog.filterType = "image"
        mediaLibraryDialog.maxSelection = 1
        mediaLibraryDialog.open()
    }

    function currentBatchReferenceCount(payload) {
        var data = payload || ({})
        var item = data.card || ({})
        var refs = item.reference_previews || item.reference_images || item.references || item.refs || []
        if (refs && refs.length !== undefined)
            return refs.length
        var ids = item.reference_image_ids || item.referenceImageIds || []
        if (ids && ids.length !== undefined)
            return ids.length
        var config = workPanelController.currentRouteConfig || ({})
        var routeRefs = config.reference_images || []
        if (routeRefs && routeRefs.length !== undefined)
            return routeRefs.length
        var routeIds = config.reference_image_ids || []
        return routeIds && routeIds.length !== undefined ? routeIds.length : 0
    }

    function openBatchReferencePicker(payload) {
        var data = payload || ({})
        var targetCard = data.card || ({})
        var targetId = String(data.card_id || data.row_id || "")
        if (Boolean(targetCard.preview_only) || targetId === "batch_draft_preview") {
            workPanelController.executePrimitiveAction("work_panel.add_blank", { source: "batch_reference_preview_row" })
            var createdBatchCards = workPanelController.cards || []
            var createdBatchCard = createdBatchCards.length > 0 ? createdBatchCards[createdBatchCards.length - 1] : ({})
            targetCard = createdBatchCard
            targetId = screen.cardId(createdBatchCard)
            data.card = createdBatchCard
            data.card_id = targetId
            data.row_id = targetId
        }
        var currentCount = Math.max(0, currentBatchReferenceCount(data))
        if (currentCount >= 10) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("batch_image.limit_reached", "Limit Reached")),
                (void i18n.revision, i18n.t("batch_image.max_refs_reached", "Maximum 10 reference images per prompt."))
            )
            return
        }
        screen.mediaTargetMode = "batch_reference"
        screen.mediaTargetCardId = targetId
        screen.mediaTargetCharacterId = ""
        screen.mediaTargetAffiliateAssetType = ""
        mediaLibraryDialog.mode = "select"
        mediaLibraryDialog.filterType = "image"
        mediaLibraryDialog.maxSelection = Math.min(10, Math.max(1, 10 - currentCount))
        mediaLibraryDialog.open()
    }

    function openProductImagePicker(productId, imageMode, currentCount) {
        screen.mediaTargetMode = "product_image"
        screen.mediaTargetCardId = ""
        screen.mediaTargetCharacterId = ""
        screen.mediaTargetAffiliateStartSlot = -1
        screen.mediaTargetAffiliateAssetType = ""
        screen.mediaTargetProductId = String(productId || "")
        screen.mediaTargetProductImageMode = String(imageMode || "main")
        mediaLibraryDialog.mode = "select"
        mediaLibraryDialog.filterType = "image"
        mediaLibraryDialog.maxSelection = screen.mediaTargetProductImageMode === "extra"
            ? Math.max(1, 3 - Math.max(0, Number(currentCount || 0)))
            : 1
        mediaLibraryDialog.open()
    }

    function handleHistoryRequested() {
        var sourceByRoute = {
            "normal": "normal_panel",
            "clone": "clone_video",
            "transcript": "transcript_video",
            "extend": "extend_panel",
            "batch": "batch_image_generation",
            "affiliate": "affiliate_video"
        }
        historyController.setSource(String(sourceByRoute[screen.route] || "all"))
        appController.setRoute("history")
    }

    function openAffiliateProductEditor(product) {
        var item = product || ({})
        var productId = String(item.product_id || item.id || "")
        workPanelController.refreshProductLibrary("", "")
        productLibraryDialog.selectMode = false
        productLibraryDialog.selectedProductIds = []
        if (productId.length > 0) {
            var products = workPanelController.productLibraryItems || []
            for (var i = 0; i < products.length; ++i) {
                var candidate = products[i] || ({})
                var candidateId = String(candidate.product_id || candidate.id || "")
                if (candidateId === productId) {
                    productLibraryDialog.selectedProduct = candidate
                    productLibraryDialog.open()
                    return
                }
            }
        }
        productLibraryDialog.selectedProduct = item
        productLibraryDialog.open()
    }

    function showFeedback(title, message) {
        screen.feedbackTitle = String(title || "")
        screen.feedbackMessage = String(message || "")
        queueFeedbackDialog.open()
    }

    function cloneClearQueueConfirmText() {
        var preview = screen.cloneClearQueuePreview || ({})
        return (void i18n.revision, i18n.t(
            "dialog.confirm_delete_all_clone",
            "Delete all {total} clone jobs?\n\nCompleted: {completed}\nFailed: {failed}\nQueued: {queued}\nProcessing: {processing}"
        ))
        .replace("{total}", String(Number(preview.total || 0)))
        .replace("{completed}", String(Number(preview.completed || 0)))
        .replace("{failed}", String(Number(preview.failed || 0)))
        .replace("{queued}", String(Number(preview.queued || 0)))
        .replace("{processing}", String(Number(preview.processing || 0)))
    }

    function openCloneClearQueueConfirm() {
        var preview = workPanelController.previewCloneClearQueue()
        if (!preview || preview.ok !== true) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String((preview && (preview.message || preview.error)) || (void i18n.revision, i18n.t("qml.work.clear_queue_failed", "Could not clear the queue.")))
            )
            return
        }
        if (Number(preview.total || 0) <= 0) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.info", "Info")),
                (void i18n.revision, i18n.t("clone.no_jobs_queue", "No clone jobs in queue."))
            )
            return
        }
        screen.cloneClearQueuePreview = preview
        cloneClearQueueConfirmDialog.open()
    }

    function openCloneSceneAnalysisForRow(rowId) {
        var targetRowId = String(rowId || "")
        var sceneAnalysis = workPanelController.analyzeQueueRow(targetRowId)
        if (sceneAnalysis && sceneAnalysis.ok && (sceneAnalysis.scenes || []).length > 0) {
            cloneSceneAnalysisDialog.openFor({
                row_id: sceneAnalysis.row_id,
                scenes: sceneAnalysis.scenes || [],
                note: sceneAnalysis.note || ""
            })
            return
        }
        screen.showFeedback(
            (void i18n.revision, i18n.t("common.warning", "Warning")),
            String(
                (sceneAnalysis && (sceneAnalysis.message || sceneAnalysis.error))
                || (void i18n.revision, i18n.t("clone.scene_analysis_failed", "Could not analyze scenes for the current clone row."))
            )
        )
    }

    function cloneDeleteRowConfirmText() {
        var context = screen.cloneDeleteRowContext || ({})
        var row = context.row || ({})
        var status = String(row.status || row.job_status || "")
        var title = String(row.title || row.url || row.source_url || context.row_id || "")
        var aspect = String(row.aspect || row.ratio || "16:9")
        if (status === "running") {
            return (void i18n.revision, i18n.t(
                "dialog.confirm_delete_job_running",
                "Delete running clone job?\n\nSource: {title}\nStatus: {status}"
            ))
            .replace("{title}", title)
            .replace("{status}", status)
        }
        return (void i18n.revision, i18n.t(
            "dialog.confirm_delete_job_queue",
            "Delete clone queue row?\n\nSource: {title}\nAspect: {aspect}\nStatus: {status}"
        ))
        .replace("{title}", title)
        .replace("{aspect}", aspect)
        .replace("{status}", status || "queued")
    }

    function openCloneDeleteRowConfirm(rowData) {
        var row = rowData || ({})
        var rowId = String(row.row_id || row.id || row.batch_id || "")
        if (rowId.length === 0) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                (void i18n.revision, i18n.t("clone.queue_row_missing", "The selected clone queue row was not found."))
            )
            return
        }
        screen.cloneDeleteRowContext = {
            row_id: rowId,
            row: row
        }
        cloneDeleteRowConfirmDialog.open()
    }

    function cloneRetryRowConfirmText() {
        var context = screen.cloneRetryRowContext || ({})
        var row = context.row || ({})
        var title = String(row.title || row.url || row.source_url || context.row_id || "")
        var errorText = String(row.error_message || "")
        if (errorText.length > 0) {
            return (void i18n.revision, i18n.t(
                "clone.retry_job_with_error",
                "Retry clone row?\n\nSource: {title}\nReason: {error}"
            ))
            .replace("{title}", title)
            .replace("{error}", errorText)
        }
        return (void i18n.revision, i18n.t(
            "clone.retry_job_confirm",
            "Retry clone row?\n\nSource: {title}"
        )).replace("{title}", title)
    }

    function openCloneRetryRowConfirm(rowData) {
        var row = rowData || ({})
        var rowId = String(row.row_id || row.id || row.batch_id || "")
        if (rowId.length === 0) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                (void i18n.revision, i18n.t("clone.queue_row_missing", "The selected clone queue row was not found."))
            )
            return
        }
        screen.cloneRetryRowContext = {
            row_id: rowId,
            row: row
        }
        cloneRetryRowConfirmDialog.open()
    }

    function saveAffiliateGeneratedAsset(assetType, payload, dialog) {
        var targetType = String(assetType || "")
        var result = workPanelController.saveAffiliateAssetContract(payload || ({}))
        if (result && result.ok && String(result.media_id || "").length > 0) {
            var attachResult = workPanelController.addAffiliateRouteAssetFromSaved(targetType, result)
            if (!(attachResult && attachResult.ok)) {
                result = {
                    ok: false,
                    route: "affiliate",
                    action: "affiliate.asset.save_and_attach",
                    code: String((attachResult || {}).code || (attachResult || {}).error || "affiliate_route_asset_attach_failed"),
                    error: String((attachResult || {}).error || (attachResult || {}).code || "affiliate_route_asset_attach_failed"),
                    message: String(
                        (attachResult || {}).message
                        || (attachResult || {}).error
                        || "Asset was saved but could not be attached to the affiliate route."
                    ),
                    media_id: String(result.media_id || ""),
                    saved: true,
                    selected_index: Number(result.selected_index || -1),
                    selected_preview: result.selected_preview || ({}),
                    card_id: String(result.card_id || payload.card_id || ""),
                    job_id: String(result.job_id || payload.job_id || "")
                }
            }
        }
        if (dialog && dialog.applySaveResult)
            dialog.applySaveResult(result)
        return result
    }

    function resetPendingBulkImport() {
        screen.pendingBulkImportMode = ""
        screen.pendingBulkImportImagePaths = []
        screen.pendingBulkImportFeature = ""
        screen.pendingBulkImportAssetsPerCard = screen.normalMultiAssetReferenceLimit()
    }

    function normalMultiAssetReferenceLimit() {
        var config = workPanelController.currentRouteConfig || ({})
        var payload = config
        if (workPanelController && workPanelController.normalMultiAssetCapabilities) {
            var livePayload = workPanelController.normalMultiAssetCapabilities()
            if (livePayload && typeof livePayload === "object")
                payload = livePayload
        }
        return Math.max(
            1,
            Number(payload.asset_limit || config.multi_asset_reference_limit || screen.maxMultiAssetReferenceImages)
        )
    }

    function clampMultiAssetCount(value) {
        var limit = screen.normalMultiAssetReferenceLimit()
        return Math.max(1, Math.min(limit, Number(value || limit)))
    }

    function pickNormalBulkImagePaths() {
        var picked = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("media_library.import_files", "Import files")),
            "Image Files (*.png *.jpg *.jpeg *.webp *.bmp *.gif);;All Files (*.*)",
            ""
        )
        if (!(picked && picked.ok && picked.paths && picked.paths.length > 0))
            return []
        return picked.paths
    }

    function prepareNormalPromptImageImport(featureType, pendingMode, imagePaths, assetsPerCard) {
        screen.pendingBulkImportFeature = String(featureType || "")
        screen.pendingBulkImportMode = String(pendingMode || "")
        screen.pendingBulkImportImagePaths = (imagePaths || []).slice()
        screen.pendingBulkImportAssetsPerCard = screen.clampMultiAssetCount(assetsPerCard)
        bulkImportDialog.clearInput()
        if (!bulkImportDialog.visible)
            bulkImportDialog.open()
    }

    function handleNormalBulkImageFilesRequested(importMode, cardMode, assetsPerCard) {
        var paths = screen.pickNormalBulkImagePaths()
        if (!paths.length)
            return
        bulkImportDialog.addImagePaths(paths)
    }

    function handleBulkImportImageFilesRequested() {
        var paths = screen.pickNormalBulkImagePaths()
        if (paths.length > 0)
            bulkImportDialog.addImportImagePaths(paths)
    }

    function handleBulkImportImageFolderRequested() {
        var picked = nativeShell.pickFolder(
            (void i18n.revision, i18n.t("bulk_import.select_image_folder", "Select image folder")),
            ""
        )
        if (!(picked && picked.ok && String(picked.path || "").length > 0))
            return
        var result = workPanelController.scanNormalImageFolder(String(picked.path || ""))
        if (result && result.ok && result.paths && result.paths.length > 0) {
            bulkImportDialog.addImportImagePaths(result.paths)
            return
        }
        screen.showFeedback(
            (void i18n.revision, i18n.t("common.warning", "Warning")),
            String((result && (result.message || result.error)) || (void i18n.revision, i18n.t("bulk_import.no_images_in_folder", "No supported images found in this folder.")))
        )
    }

    function handleNormalImageImportAccepted(payload) {
        var data = payload || ({})
        var result = workPanelController.addNormalImageImportItems(
            data.result_items || [],
            String(data.card_mode || "image"),
            Number(data.assets_per_card || screen.normalMultiAssetReferenceLimit())
        )
        var accepted = bulkImportDialog.applyAcceptResult(result)
        if (accepted)
            screen.resetPendingBulkImport()
    }

    function mediaItemSourcePath(item) {
        var data = item || ({})
        var original = Boolean(data.source_missing) ? "" : String(data.original_source_path || "")
        return String(
            data.croppedImagePath
            || data.cropped_image_path
            || data.source_path
            || data.file_path
            || data.path
            || data.blob_path
            || data.preview_path
            || original
            || data.mediaId
            || data.media_id
            || data.id
            || ""
        )
    }

    function mediaSelectionImagePaths(selection) {
        var payload = selection || ({})
        var out = []
        var seen = ({})
        function appendPath(value) {
            var path = String(value || "")
            if (!path.length || seen[path])
                return
            seen[path] = true
            out.push(path)
        }

        appendPath(payload.croppedImagePath || payload.cropped_image_path)
        var items = payload.items || []
        for (var i = 0; i < items.length; ++i)
            appendPath(screen.mediaItemSourcePath(items[i] || ({})))
        if (!out.length)
            appendPath(screen.mediaItemSourcePath(payload.item || payload.media || payload))
        return out
    }

    function openBulkImportMediaLibrary() {
        screen.mediaTargetMode = bulkImportDialog.imageModeActive ? "bulk_import_image" : "bulk_import_named_ref"
        screen.mediaTargetCardId = ""
        screen.mediaTargetCharacterId = ""
        screen.mediaTargetExtendRootSlot = -1
        screen.mediaTargetAffiliateStartSlot = -1
        screen.mediaTargetAffiliateAssetType = ""
        screen.mediaTargetProductId = ""
        screen.mediaTargetProductImageMode = ""
        mediaLibraryDialog.mode = "select"
        mediaLibraryDialog.filterType = "image"
        mediaLibraryDialog.maxSelection = 9999
        mediaLibraryDialog.open()
    }

    function runNormalStandardBulkImport(featureType, assetsPerCard) {
        var feature = String(featureType || "")
        var assetLimit = screen.clampMultiAssetCount(assetsPerCard)
        var picked = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("media_library.import_files", "Import files")),
            "Image Files (*.png *.jpg *.jpeg *.webp *.bmp *.gif);;All Files (*.*)",
            ""
        )
        if (!(picked && picked.ok && picked.paths && picked.paths.length > 0))
            return
        var result = null
        if (feature === "image")
            result = workPanelController.addNormalImageCards(picked.paths)
        else if (feature === "multi_asset")
            result = workPanelController.addNormalMultiAssetCards(picked.paths, assetLimit)
        else if (feature === "interpolation")
            result = workPanelController.addNormalInterpolationCards(picked.paths)
        if (result && !result.ok) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(result.message || result.error || (void i18n.revision, i18n.t("common.action_failed", "Action failed")))
            )
        }
    }

    function runNormalNamedRefImport(featureType, assetsPerCard) {
        var feature = String(featureType || "")
        var assetLimit = screen.clampMultiAssetCount(assetsPerCard)
        var picked = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("media_library.import_files", "Import files")),
            "Image Files (*.png *.jpg *.jpeg *.webp *.bmp *.gif);;All Files (*.*)",
            ""
        )
        if (!(picked && picked.ok && picked.paths && picked.paths.length > 0))
            return
        screen.pendingBulkImportFeature = feature
        screen.pendingBulkImportMode = feature === "multi_asset" ? "normal_named_ref_multi_asset" : "normal_named_ref_image"
        screen.pendingBulkImportImagePaths = picked.paths
        screen.pendingBulkImportAssetsPerCard = assetLimit
        bulkImportDialog.clearInput()
        bulkImportDialog.openForNamedRef(picked.paths, {
            card_mode: feature,
            assets_per_card: assetLimit
        })
    }

    function runNormalSingleSetMultiAssetImport(assetsPerCard) {
        var assetLimit = screen.clampMultiAssetCount(assetsPerCard)
        var picked = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("media_library.import_files", "Import files")),
            "Image Files (*.png *.jpg *.jpeg *.webp *.bmp *.gif);;All Files (*.*)",
            ""
        )
        if (!(picked && picked.ok && picked.paths && picked.paths.length > 0))
            return
        screen.pendingBulkImportFeature = "multi_asset"
        screen.pendingBulkImportMode = "normal_multi_asset_single_set"
        screen.pendingBulkImportImagePaths = picked.paths
        screen.pendingBulkImportAssetsPerCard = assetLimit
        bulkImportDialog.clearInput()
        bulkImportDialog.open()
    }

    function runNormalSharedPromptMultiAssetImport(assetsPerCard) {
        var assetLimit = screen.clampMultiAssetCount(assetsPerCard)
        var picked = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("media_library.import_files", "Import files")),
            "Image Files (*.png *.jpg *.jpeg *.webp *.bmp *.gif);;All Files (*.*)",
            ""
        )
        if (!(picked && picked.ok && picked.paths && picked.paths.length > 0))
            return
        screen.pendingBulkImportFeature = "multi_asset"
        screen.pendingBulkImportMode = "normal_multi_asset_shared_prompt"
        screen.pendingBulkImportImagePaths = picked.paths
        screen.pendingBulkImportAssetsPerCard = assetLimit
        bulkImportDialog.clearInput()
        bulkImportDialog.open()
    }

    function runNormalSinglePairInterpolationImport() {
        var picked = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("media_library.import_files", "Import files")),
            "Image Files (*.png *.jpg *.jpeg *.webp *.bmp *.gif);;All Files (*.*)",
            ""
        )
        if (!(picked && picked.ok && picked.paths && picked.paths.length > 0))
            return
        screen.pendingBulkImportFeature = "interpolation"
        screen.pendingBulkImportMode = "normal_interpolation_single_pair"
        screen.pendingBulkImportImagePaths = picked.paths
        bulkImportDialog.clearInput()
        bulkImportDialog.open()
    }

    function runNormalSharedPromptInterpolationImport() {
        var picked = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("media_library.import_files", "Import files")),
            "Image Files (*.png *.jpg *.jpeg *.webp *.bmp *.gif);;All Files (*.*)",
            ""
        )
        if (!(picked && picked.ok && picked.paths && picked.paths.length > 0))
            return
        screen.pendingBulkImportFeature = "interpolation"
        screen.pendingBulkImportMode = "normal_interpolation_shared_prompt"
        screen.pendingBulkImportImagePaths = picked.paths
        bulkImportDialog.clearInput()
        bulkImportDialog.open()
    }

    function runNormalSingleImageImport() {
        var picked = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("media_library.import_files", "Import files")),
            "Image Files (*.png *.jpg *.jpeg *.webp *.bmp *.gif);;All Files (*.*)",
            ""
        )
        if (!(picked && picked.ok && picked.paths && picked.paths.length > 0))
            return
        screen.pendingBulkImportFeature = "image"
        screen.pendingBulkImportMode = "normal_image_single_image"
        screen.pendingBulkImportImagePaths = picked.paths
        bulkImportDialog.clearInput()
        bulkImportDialog.open()
    }

    function runNormalSharedPromptImageImport() {
        var picked = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("media_library.import_files", "Import files")),
            "Image Files (*.png *.jpg *.jpeg *.webp *.bmp *.gif);;All Files (*.*)",
            ""
        )
        if (!(picked && picked.ok && picked.paths && picked.paths.length > 0))
            return
        screen.pendingBulkImportFeature = "image"
        screen.pendingBulkImportMode = "normal_image_shared_prompt"
        screen.pendingBulkImportImagePaths = picked.paths
        bulkImportDialog.clearInput()
        bulkImportDialog.open()
    }

    // --- Thay asset cho slot job panel (dùng chung media library sẵn có) ---
    property string pendingJobAssetRowId: ""
    property int pendingJobAssetSlot: -1
    function jobAssetArray(row) {
        var meta = (row && row.meta) ? row.meta : ({})
        var candidates = [
            row && row.assets,
            meta.assets,
            row && row.reference_previews,
            meta.reference_previews,
            row && row.reference_images,
            meta.reference_images,
            row && row.reference_paths,
            meta.reference_paths,
            row && row.start_images,
            meta.start_images
        ]
        for (var i = 0; i < candidates.length; i++) {
            var candidate = candidates[i]
            if (candidate && typeof candidate !== "string" && candidate.length > 0)
                return candidate
        }
        return []
    }
    function jobAssetLocalPath(row, index) {
        var assets = screen.jobAssetArray(row)
        var item = assets && assets.length > index ? assets[index] : null
        if (!item)
            return ""
        if (typeof item === "string")
            return item
        return String(
            item.file_path
            || item.path
            || item.source_path
            || item.preview_path
            || item.thumbnail_path
            || ""
        )
    }
    function fileUriToLocalPath(value) {
        var s = String(value || "")
        if (s.indexOf("file:///") === 0)
            return decodeURIComponent(s.substring(8))
        if (s.indexOf("file://") === 0)
            return decodeURIComponent(s.substring(7))
        return s
    }
    // Ảnh local của 1 slot asset trên scene job card. Nguồn CHUẨN là
    // multi_asset_info.assets (clone/transcript/master nhúng selection ở đây,
    // enrich đã hydrate file:// từ Library khi asset chỉ còn media_id);
    // jobAssetArray (assets/reference_previews...) chỉ là fallback route khác.
    function jobSlotImagePath(row, index) {
        var meta = (row && row.meta) ? row.meta : ({})
        var info = (row && row.multi_asset_info) || meta.multi_asset_info || null
        var assets = info && info.assets ? info.assets : null
        var item = assets && assets.length > index ? assets[index] : null
        if (item && typeof item !== "string") {
            var keys = ["file_url", "thumbnail_file_url", "blob_file_url", "file_path", "path", "preview_path", "thumbnail_path", "image_path"]
            for (var i = 0; i < keys.length; i++) {
                var v = String(item[keys[i]] || "")
                if (v.length > 0 && v.indexOf("data:") !== 0 && v.indexOf("http://") !== 0 && v.indexOf("https://") !== 0)
                    return screen.fileUriToLocalPath(v)
            }
        }
        return screen.jobAssetLocalPath(row, Number(index))
    }
    function openJobSlotPreview(row, index) {
        var assetPath = screen.jobSlotImagePath(row, Number(index))
        if (assetPath.length > 0 && assetPath.indexOf("data:") !== 0 && assetPath.indexOf("http://") !== 0 && assetPath.indexOf("https://") !== 0) {
            var assetOpenResult = nativeShell.openPath(assetPath)
            if (!(assetOpenResult && assetOpenResult.ok)) {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    String((assetOpenResult && (assetOpenResult.message || assetOpenResult.error || assetOpenResult.code)) || assetPath)
                )
            }
            return true
        }
        return false
    }
    function handleJobAssetRequested(row, index) {
        if (screen.route === "batch") {
            screen.openJobSlotPreview(row, Number(index))
            return
        }
        // Clone/Transcript: card là SCENE JOB đã dispatch — click ảnh slot = XEM ảnh
        // (mở trình xem hệ thống, cùng pattern click thumbnail), KHÔNG mở picker thay
        // asset (job đã chạy, thay asset ở đây vô nghĩa và làm user tưởng hỏng).
        if (screen.route === "clone" || screen.route === "transcript") {
            if (!screen.openJobSlotPreview(row, Number(index)))
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    (void i18n.revision, i18n.t("job_panel.asset_no_local_image", "Ảnh của slot này chưa có trên máy (chỉ còn media_id trên server)."))
                )
            return
        }
        screen.openJobAssetReplacePicker(row, index)
    }

    function openJobAssetReplacePicker(row, index) {
        screen.pendingJobAssetRowId = String((row && (row.id || row.row_id || row.job_id)) || "")
        screen.pendingJobAssetSlot = Number(index)
        screen.mediaTargetMode = "job_asset_replace"
        mediaLibraryDialog.mode = "select"
        mediaLibraryDialog.filterType = ""
        mediaLibraryDialog.maxSelection = 1
        mediaLibraryDialog.open()
    }

    function refreshPromptEditorAssets(jobId) {
        var model = workPanelController ? workPanelController.jobPanelModel : null
        if (model && model.assetSlotsForJob)
            promptEditDialog.setAssetSlots(model.assetSlotsForJob(String(jobId || "")))
    }

    // --- Pre-queue confirmation gate (all video-producing WorkPanel routes) ---
    property var _pendingQueueAction: null
    function gateQueue(fn) {
        var r = String(workPanelController.route || "")
        if (["clone", "transcript", "normal", "batch", "affiliate"].indexOf(r) < 0) { fn(); return }
        // Confirmation is mandatory — the pre-queue gate always shows (no skip option).
        screen._pendingQueueAction = fn
        queuePreflightDialog.route = r
        queuePreflightDialog.imageOutput = r === "batch"
            || ((r === "transcript" || r === "clone")
                && String((workPanelController.currentRouteConfig || {}).output_mode || "video") === "image")
        workPanelController.requestQueueCost(r)
        queuePreflightDialog.openFor(screen.buildConfigRows())
    }

    function configStyleSummary(c) {
        var cfg = c || ({})
        var named = String(cfg.selected_style_name || cfg.selected_style || "").trim()
        if (named.length)
            return named
        if (masterConfigPanelRef && masterConfigPanelRef.styleLabelForId) {
            var styleId = String(cfg.structural_style_id || cfg.style_id || cfg.selected_style_id || "").trim()
            var surfaceId = String(cfg.surface_style_id || "").trim()
            var cameraId = String(cfg.camera_id || cfg.structural_camera_id || cfg.surface_camera_id || "").trim()
            var parts = []
            var styleLabel = masterConfigPanelRef.styleLabelForId(styleId)
            var surfaceLabel = (surfaceId.length && surfaceId !== styleId)
                ? masterConfigPanelRef.styleLabelForId(surfaceId) : ""
            var cameraLabel = masterConfigPanelRef.styleLabelForId(cameraId)
            if (styleLabel.length)
                parts.push(styleLabel)
            if (surfaceLabel.length)
                parts.push(surfaceLabel)
            if (cameraLabel.length)
                parts.push(cameraLabel)
            if (parts.length)
                return parts.join(" + ")
        }
        return ""
    }

    function configFolderSummary(c) {
        return String((c || ({})).output_folder || "").trim()
    }
    function configSubtitleRows(c) {
        var cfg = c || ({})
        var row = SubtitleIntent.queueConfirmRow(
            cfg.subtitle_profile || ({}),
            String(cfg.dialogue_language || cfg.voice_language || cfg.language || "vi")
        )
        return [{
            label: (void i18n.revision, i18n.t("queue_confirm.subtitle", "Phụ đề")),
            value: String((row && row.value) || "—"),
            warn: Boolean(row && row.warn)
        }]
    }
    function _onOff(v) { return v ? (void i18n.revision, i18n.t("common.on", "Bật")) : (void i18n.revision, i18n.t("common.off", "Tắt")) }
    function buildConfigRows() {
        var c = workPanelController.currentRouteConfig || ({})
        var clip = Number(c.clip_duration_seconds || 0)
        if (String(workPanelController.route || "") === "affiliate") {
            var aWarn = (void i18n.revision, i18n.t("queue_confirm.not_set", "⚠ Chưa chọn"))
            var aModel = String(c.video_model_key || c.model_key || "").trim()
            var aFolder = screen.configFolderSummary(c)
            var aVariants = Boolean(c.variation_auto)
                ? (void i18n.revision, i18n.t("affiliate.variation_auto", "Tự động"))
                : String(Math.max(1, Number(c.variation_count || 1)))
            var aChars = c.character_slots && c.character_slots.length !== undefined
                ? c.character_slots : []
            var aBgs = c.background_slots && c.background_slots.length !== undefined
                ? c.background_slots : []
            var aCharPerProduct = String(c.character_scope || c.asset_mode || "global") === "per_product"
            var aBgPerProduct = String(c.background_scope || c.asset_mode || "global") === "per_product"
            var aCharValue = Boolean(c.character_auto)
                ? (void i18n.revision, i18n.t("affiliate.asset_auto", "AI tự chọn / tạo"))
                : (aCharPerProduct
                    ? (void i18n.revision, i18n.t("affiliate.per_product", "Theo từng sản phẩm"))
                    : aChars.length > 0
                    ? String(aChars.length) + " " + (void i18n.revision, i18n.t("affiliate.assets_selected", "đã chọn"))
                    : (void i18n.revision, i18n.t("common.off", "Tắt")))
            var aBgValue = Boolean(c.background_auto)
                ? (void i18n.revision, i18n.t("affiliate.asset_auto", "AI tự chọn / tạo"))
                : (aBgPerProduct
                    ? (void i18n.revision, i18n.t("affiliate.per_product", "Theo từng sản phẩm"))
                    : aBgs.length > 0
                    ? String(aBgs.length) + " " + (void i18n.revision, i18n.t("affiliate.assets_selected", "đã chọn"))
                    : (void i18n.revision, i18n.t("common.off", "Tắt")))
            return [
                { label: (void i18n.revision, i18n.t("config_panel.model", "Model video")),
                  value: aModel.length > 0 ? aModel : (void i18n.revision, i18n.t("queue_confirm.model_default", "⚠ Chưa chọn — sẽ dùng mặc định")),
                  warn: aModel.length <= 0 },
                { label: (void i18n.revision, i18n.t("master.aspect_ratio", "Tỷ lệ")), value: String(c.aspect_ratio || "9:16") },
                { label: (void i18n.revision, i18n.t("queue_confirm.quality", "Chất lượng")), value: String(c.quality || c.resolution || "720p") },
                { label: (void i18n.revision, i18n.t("queue_confirm.market", "Thị trường")), value: String(c.market || c.target_market || "vietnam") },
                { label: (void i18n.revision, i18n.t("master.voice_language", "Giọng đọc")), value: String(c.voice_language || "vi") },
                { label: (void i18n.revision, i18n.t("queue_confirm.output_folder", "Thư mục lưu")),
                  value: aFolder.length > 0 ? aFolder : aWarn,
                  warn: aFolder.length <= 0 },
                { label: (void i18n.revision, i18n.t("affiliate.variants", "Biến thể")), value: aVariants },
                { label: (void i18n.revision, i18n.t("affiliate.characters", "Nhân vật")), value: aCharValue },
                { label: (void i18n.revision, i18n.t("affiliate.backgrounds", "Bối cảnh")), value: aBgValue },
                { label: (void i18n.revision, i18n.t("affiliate.narrator", "Người dẫn")), value: screen._onOff(c.enable_narrator !== false) },
                { label: (void i18n.revision, i18n.t("affiliate.auto_pool", "Tự động chạy")), value: screen._onOff(Boolean(c.auto_pool_enabled)) }
            ].concat(screen.configSubtitleRows(c))
        }
        // Normal route: a last-chance review of model / style / folder so the user can
        // catch an unset model (→ silent veo-fast fallback), a forgotten style, or a
        // missing output folder BEFORE the batch dispatches.
        if (String(workPanelController.route || "") === "batch") {
            var bWarn = (void i18n.revision, i18n.t("queue_confirm.not_set", "⚠ Chưa chọn"))
            var bModel = String(c.model || c.image_model || c.model_key || "").trim()
            var bStyle = screen.configStyleSummary(c)
            var bFolder = screen.configFolderSummary(c)
            var bRes = String(c.resolution || "").trim()
            return [
                { label: (void i18n.revision, i18n.t("queue_confirm.image_model", "Model ảnh")),
                  value: bModel.length > 0 ? bModel : (void i18n.revision, i18n.t("queue_confirm.model_default", "⚠ Chưa chọn — sẽ dùng mặc định")) },
                { label: (void i18n.revision, i18n.t("master.aspect_ratio", "Tỷ lệ")), value: String(c.aspect_ratio || "16:9") },
                { label: (void i18n.revision, i18n.t("queue_confirm.image_resolution", "Độ phân giải")),
                  value: bRes.length > 0 ? bRes : (void i18n.revision, i18n.t("queue_confirm.base_resolution", "Gốc (không upscale)")) },
                { label: (void i18n.revision, i18n.t("queue_confirm.style", "Style")),
                  value: bStyle.length > 0 ? bStyle : bWarn },
                { label: (void i18n.revision, i18n.t("queue_confirm.output_folder", "Thư mục lưu")),
                  value: bFolder.length > 0 ? bFolder : bWarn },
                { label: (void i18n.revision, i18n.t("qml.work.batch_variations", "Số biến thể")), value: String(c.variations || 1) }
            ]
        }
        if (String(workPanelController.route || "") === "normal") {
            var nWarn = (void i18n.revision, i18n.t("queue_confirm.not_set", "⚠ Chưa chọn"))
            var nModel = String(c.model_key || "").trim()
            var nStyle = screen.configStyleSummary(c)
            var nFolder = screen.configFolderSummary(c)
            var nCount = Number(c.output_count || 1)
            return [
                { label: (void i18n.revision, i18n.t("config_panel.model", "Model")),
                  value: nModel.length > 0 ? nModel : (void i18n.revision, i18n.t("queue_confirm.model_default", "⚠ Chưa chọn — sẽ dùng mặc định")) },
                { label: (void i18n.revision, i18n.t("queue_confirm.style", "Style")),
                  value: nStyle.length > 0 ? nStyle : nWarn },
                { label: (void i18n.revision, i18n.t("queue_confirm.output_folder", "Thư mục lưu")),
                  value: nFolder.length > 0 ? nFolder : nWarn },
                { label: (void i18n.revision, i18n.t("master.aspect_ratio", "Tỷ lệ")), value: String(c.aspect_ratio || "16:9") },
                { label: (void i18n.revision, i18n.t("master.model_duration", "Độ dài clip")), value: clip > 0 ? (clip + "s") : "Auto" },
                { label: (void i18n.revision, i18n.t("queue_confirm.output_count", "Số video / prompt")), value: String(nCount) },
                { label: (void i18n.revision, i18n.t("queue_confirm.market", "Thị trường")), value: String(c.target_market || c.market || "global") },
                { label: (void i18n.revision, i18n.t("queue_confirm.quality", "Chất lượng")), value: String(c.quality || c.resolution || "720p") },
                { label: (void i18n.revision, i18n.t("queue_confirm.ai_tier", "AI phân tích")), value: (void i18n.revision, i18n.t("queue_confirm.ai_auto", "Tự động · model mới nhất → dự phòng · suy nghĩ thấp")) }
            ]
        }
        // Shared building blocks for clone / transcript (per-tab lists below).
        var styleName = screen.configStyleSummary(c)
        var vModel = String(c.video_model_key || c.model_key || "").trim()
        var tierRow = {
            label: (void i18n.revision, i18n.t("queue_confirm.ai_tier", "AI phân tích")),
            value: (void i18n.revision, i18n.t("queue_confirm.ai_auto", "Tự động · model mới nhất → dự phòng · suy nghĩ thấp"))
        }
        var mModel = { label: (void i18n.revision, i18n.t("config_panel.model", "Model video")),
                       value: vModel.length > 0 ? vModel : (void i18n.revision, i18n.t("queue_confirm.model_default", "⚠ dùng mặc định")) }
        var mAspect = { label: (void i18n.revision, i18n.t("master.aspect_ratio", "Tỷ lệ")), value: String(c.aspect_ratio || "16:9") }
        var mClip = { label: (void i18n.revision, i18n.t("master.model_duration", "Độ dài clip")), value: clip > 0 ? (clip + "s") : "Auto" }
        var mQuality = { label: (void i18n.revision, i18n.t("queue_confirm.quality", "Chất lượng")), value: String(c.quality || c.resolution || "720p") }
        var mMarket = { label: (void i18n.revision, i18n.t("queue_confirm.market", "Thị trường")), value: String(c.target_market || c.market || "global") }
        var mLibCtrl = { label: (void i18n.revision, i18n.t("qml.master.library_control", "Điều khiển NV/đồ vật/bối cảnh")), value: screen._onOff(c.char_consistency || c.enable_char_consistency) }

        // ── AUDIO/CLONE→ẢNH: use the route-owned image snapshot, never Batch Image.
        // Resolve the display label from the same live catalog as the top picker.
        if ((String(workPanelController.route || "") === "transcript"
                || String(workPanelController.route || "") === "clone")
                && String(c.output_mode || "video") === "image") {
            var routeOptions = workPanelController.currentRouteOptions || ({})
            var imageOptions = routeOptions.image_models || []
            var imgModelVal = String(c.image_model || routeOptions.default_image_model || "")
            var imgModelName = imgModelVal
            for (var imgIdx = 0; imgIdx < imageOptions.length; imgIdx++) {
                if (String((imageOptions[imgIdx] || {}).value || "") === imgModelVal) {
                    imgModelName = String((imageOptions[imgIdx] || {}).label || imgModelVal)
                    break
                }
            }
            // Empty means Clone's base 720p image contract (no forced upscale).
            // Show the shared quality label so the dialog matches the top picker,
            // rather than exposing the provider's internal blank sentinel.
            var imgResValue = String(c.image_resolution || "").trim()
            var imgRes = imgResValue.length > 0
                ? imgResValue
                : String(c.quality || c.resolution || "720p")
            return [
                { label: (void i18n.revision, i18n.t("queue_confirm.image_model", "Model ảnh")), value: imgModelName },
                mAspect,
                { label: (void i18n.revision, i18n.t("queue_confirm.image_resolution", "Độ phân giải")), value: imgRes },
                mMarket, mLibCtrl,
                { label: (void i18n.revision, i18n.t("queue_confirm.style", "Style")),
                  value: styleName.length > 0 ? styleName : (void i18n.revision, i18n.t("queue_confirm.not_set", "⚠ Chưa chọn")) },
                { label: (void i18n.revision, i18n.t("transcript.auto_merge", "Tự ghép video")), value: screen._onOff(c.auto_merge) },
                { label: (void i18n.revision, i18n.t("transcript.deep_analysis", "Phân tích sâu")), value: screen._onOff(c.deep_analysis) },
                tierRow
            ].concat(screen.configSubtitleRows(c))
        }

        // ── CLONE: sao chép video gốc → KHÔNG hiện "Giọng" (giọng theo nguồn) ──
        if (String(workPanelController.route || "") === "clone") {
            return [
                mModel, mAspect, mClip, mQuality, mMarket, mLibCtrl,
                { label: (void i18n.revision, i18n.t("queue_confirm.style", "Style")),
                  value: styleName.length > 0 ? styleName : (void i18n.revision, i18n.t("clone.style_source", "Theo video gốc")) },
                tierRow
            ].concat(screen.configSubtitleRows(c))
        }
        // ── TRANSCRIPT: sinh giọng đọc → CÓ "Giọng" ──
        return [
            mModel, mAspect, mClip, mQuality, mMarket, mLibCtrl,
            { label: (void i18n.revision, i18n.t("queue_confirm.style", "Style")),
              value: styleName.length > 0 ? styleName : (void i18n.revision, i18n.t("queue_confirm.not_set", "⚠ Chưa chọn")) },
            { label: (void i18n.revision, i18n.t("master.voice_language", "Giọng đọc")), value: String(c.voice_name || c.voice_language || "—") },
            { label: (void i18n.revision, i18n.t("transcript.auto_merge", "Tự ghép video")), value: screen._onOff(c.auto_merge) },
            { label: (void i18n.revision, i18n.t("transcript.deep_analysis", "Phân tích sâu")), value: screen._onOff(c.deep_analysis) },
            tierRow
        ].concat(screen.configSubtitleRows(c))
    }

    function applyQueueResult(result, fallbackError, fallbackSuccess, silentSuccess) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            // `alerted` = a gate already popped a runtime-alert dialog for this reason;
            // showing the generic feedback dialog too would stack two dialogs.
            if (!payload.alerted)
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    String(payload.message || payload.error || fallbackError || (void i18n.revision, i18n.t("common.action_failed", "Action failed")))
                )
            return false
        }
        // A partial add still returns ok=true. `warn_message` means some rows were
        // dropped (too long / not fetched) — surface it even for a silent-success
        // caller, otherwise the skipped videos disappear without a word.
        var warn = String(payload.warn_message || "")
        if (warn.length > 0) {
            screen.showFeedback((void i18n.revision, i18n.t("common.warning", "Warning")), warn)
            return true
        }
        if (Boolean(silentSuccess))
            return true
        screen.showFeedback(
            (void i18n.revision, i18n.t("common.success", "Success")),
            String(payload.message || fallbackSuccess || (void i18n.revision, i18n.t("common.done", "Done")))
        )
        return true
    }

    function openJobPanelBatchActions() {
        jobPanelBatchActionsDialog.open()
    }

    function scenePromptPreview(row) {
        var value = String((row && (row.prompt || row.source || row.title || row.idea)) || "").trim()
        if (value.length <= 100)
            return value
        return value.slice(0, 100)
    }

    function requestCloneSceneRegen(row) {
        cloneSceneRegenContext = {
            jobId: String((row && (row.job_id || row.id || row.row_id)) || ""),
            row: row || ({})
        }
        cloneSceneRegenDialog.open()
    }

    function requestCloneSceneDelete(row) {
        cloneSceneDeleteContext = {
            jobId: String((row && (row.job_id || row.id || row.row_id)) || ""),
            row: row || ({})
        }
        cloneSceneDeleteDialog.open()
    }

    function requestTranscriptSceneRegen(row) {
        transcriptSceneRegenContext = {
            jobId: String((row && (row.job_id || row.id || row.row_id)) || ""),
            row: row || ({})
        }
        transcriptSceneRegenDialog.open()
    }

    function requestTranscriptSceneDelete(row) {
        transcriptSceneDeleteContext = {
            jobId: String((row && (row.job_id || row.id || row.row_id)) || ""),
            row: row || ({})
        }
        transcriptSceneDeleteDialog.open()
    }

    Timer {
        id: workspaceRouteConfigSync
        interval: 0
        repeat: false
        onTriggered: screen.refreshWorkspaceRouteConfig()
    }

    function refreshWorkspaceRouteConfig() {
        var live = (typeof workPanelController !== "undefined"
                    && workPanelController)
            ? (workPanelController.currentRouteConfig || ({})) : ({})
        var snapshot = ({})
        for (var key in live)
            snapshot[key] = live[key]
        screen.workspaceRouteConfig = snapshot
    }

    function requestJobPanelSceneRegen(row) {
        jobSceneRegenContext = {
            reason: "direct",
            jobId: String((row && (row.job_id || row.id || row.row_id)) || ""),
            row: row || ({})
        }
        jobSceneRegenDialog.open()
    }

    function extendSessionRecord(sessionKey) {
        var key = String(sessionKey || "")
        if (key.length === 0)
            return {}
        var sessions = workPanelController.extendSessions || []
        for (var i = 0; i < sessions.length; i++) {
            var item = sessions[i] || {}
            if (String(item.session_key || item.id || "") === key)
                return item
        }
        var current = workPanelController.extendSessionState || {}
        if (String(current.session_key || current.id || "") === key)
            return current
        return {}
    }

    function requestExtendSessionDelete(sessionKey) {
        var key = String(sessionKey || "")
        if (key.length === 0) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                (void i18n.revision, i18n.t("qml.work.extend_missing_session", "Missing extend session id"))
            )
            return
        }
        screen.pendingExtendDeleteSession = screen.extendSessionRecord(key)
        if (String((screen.pendingExtendDeleteSession || {}).session_key || (screen.pendingExtendDeleteSession || {}).id || "").length === 0)
            screen.pendingExtendDeleteSession = { session_key: key }
        extendSessionDeleteDialog.open()
    }

    function applyExtendSessionResult(result, fallbackError, fallbackSuccess, silentSuccess) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(payload.message || payload.error || fallbackError || (void i18n.revision, i18n.t("common.action_failed", "Action failed")))
            )
            return false
        }
        // Session = browser tab: switching/creating/closing must not pop a toast.
        if (!silentSuccess) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.success", "Success")),
                String(payload.message || fallbackSuccess || (void i18n.revision, i18n.t("common.done", "Done")))
            )
        }
        return true
    }

    function createExtendSessionForAccount(account) {
        var sres = workPanelController.createExtendSessionForAccount(account || ({}))
        if (sres && sres.blocked) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("extend.sessions_full_title", "Session limit")),
                (void i18n.revision, i18n.t("extend.sessions_full_msg", "Each account allows up to {max} sessions. Close one to add a new session."))
                    .replace("{max}", String(sres.max_slots || 5))
            )
            return
        }
        // Silent on success — creating a session = opening a new tab.
        screen.applyExtendSessionResult(sres, "Could not create extend session.", "", true)
    }

    function handleRouteTool(action, payload) {
        var routePayload = payload || ({})
        if (action === "extend_bulk_import") {
            var stats = workPanelController.stats || {}
            var generating = Number(stats.generating || 0)
            var pending = Number(stats.pending || stats.queued || 0)
            bulkExtendImportDialog.openForImport(generating > 0, pending)
        } else if (action === "extend_bulk_preview") {
            // Preview the GENERATED timeline (stashed by Tạo Timeline) — not the session
            // cards. Read it via the dedicated slot (raw stash), not the merged routeConfig.
            // Confirming the dialog imports the beats into the session.
            var genBeats = workPanelController.extendGeneratedTimeline() || []
            if (!genBeats || genBeats.length === 0) {
                statusController.setStatusMessage("Chưa có timeline — bấm Tạo Timeline trước khi xem.")
                return
            }
            bulkExtendImportDialog.openForGenerated(genBeats)
        } else if (action === "extend_import_session") {
            // Commit the stashed generated timeline into this session's prompt cards (one step).
            var importResult = workPanelController.importExtendGeneratedTimeline()
            if (importResult && importResult.ok)
                statusController.setStatusMessage(String(importResult.message || "Imported to session"))
            else
                screen.showFeedback(
                    (void i18n.revision, i18n.t("extend_ai.import_to_session", "Import to Session")),
                    String((importResult && (importResult.message || importResult.error)) || "Chưa có timeline để import."))
        } else if (action === "batch_config") {
            // Batch Image: Model + Tỷ lệ hợp lệ (image model).
            batchConfigDialog.showMediaFields = true
            batchConfigDialog.openFor(workPanelController.currentBatchConfig || {})
        } else if (action === "batch_actions") {
            batchActionsDialog.open()
        } else if (action === "route_characters") {
            workPanelController.refreshCharacters("")
            characterManagerDialog.open()
        } else if (action === "clone_batch_config") {
            // Clone batch: KHÔNG có image model (kế thừa model/tỷ lệ từ motif gốc).
            batchConfigDialog.showMediaFields = false
            batchConfigDialog.openFor(workPanelController.currentBatchConfig || {})
        } else if (action === "clone_analyze_scenes") {
            var selectedCloneRowId = String(workPanelContent.selectedQueueRowId || "")
            screen.openCloneSceneAnalysisForRow(selectedCloneRowId)
        } else if (action === "clone_pipeline") {
            clonePipelineDialog.openFor({
                raw_input: String(routePayload.raw_input || ""),
                video_type: String(routePayload.video_type || (workPanelController.currentRouteConfig || {}).video_filter || "all"),
                min_views: Number(routePayload.min_views || 0)
            })
        } else if (action === "clone_toggle_frame_slicing") {
            var isFrameSlicing = Boolean((workPanelController.currentRouteConfig || {}).frame_slicing)
            workPanelController.toggleFrameSlicing(!isFrameSlicing)
        } else if (action === "clone_set_model") {
            workPanelController.setCloneModel(String(routePayload.model_key || ""))
        } else if (action === "clone_manage_characters") {
            var charJobId = String(routePayload.job_id || "")
            var charResult = workPanelController.manageJobCharacters(charJobId)
            if (!charResult.ok)
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    String(charResult.message || "Character management unavailable.")
                )
        } else if (action === "master_toggle_multi_asset") {
            var isMultiAsset = Boolean((workPanelController.currentRouteConfig || {}).multi_asset_mode)
            workPanelController.setMultiAssetMode(!isMultiAsset)
        } else if (action === "master_toggle_char_consistency") {
            var isCharConsistency = Boolean((workPanelController.currentRouteConfig || {}).char_consistency)
            workPanelController.setCharConsistencyMode(!isCharConsistency)
        } else if (action === "master_poll_job") {
            workPanelController.pollJobCompletion(String(routePayload.job_id || ""))
        } else if (action === "extend_validate_cards") {
            var validateResult = workPanelController.validateExtendCards()
            if (!validateResult.valid)
                screen.showFeedback(
                    (void i18n.revision, i18n.t("extend.validation_failed", "Validation")),
                    String(validateResult.message || "Cards are not ready.")
                )
        } else if (action === "extend_check_chains") {
            workPanelController.checkExtendChains()
        } else if (action === "normal_set_aspect") {
            workPanelController.setNormalAspectRatio(String(routePayload.ratio || "16:9"))
        } else if (action === "normal_validate") {
            var normalValidResult = workPanelController.validateNormalCards()
            if (!normalValidResult.valid)
                screen.showFeedback(
                    (void i18n.revision, i18n.t("normal.validation_failed", "Validation")),
                    String(normalValidResult.message || "Add prompts first.")
                )
        } else if (action === "normal_detect_job") {
            workPanelController.detectActiveJob()
        } else if (action === "normal_refresh_multi_asset") {
            workPanelController.refreshMultiAssetCapability()
        } else if (action === "transcript_auto_merge") {
            workPanelController.triggerTranscriptAutoMerge(String(routePayload.row_id || ""))
        } else if (action === "transcript_save_snapshot") {
            workPanelController.saveTranscriptJobSnapshot(String(routePayload.row_id || ""))
        } else if (action === "affiliate_gen_asset") {
            workPanelController.generateAffiliateAssetByType(
                String(routePayload.asset_type || "character"),
                String(routePayload.product_id || "")
            )
        } else if (action === "affiliate_auto_fill_slots") {
            workPanelController.autoFillAffiliateProductSlots(String(routePayload.product_id || ""))
        } else if (action === "research_set_model") {
            workPanelController.setResearchModel(String(routePayload.model_id || ""))
        } else if (action === "clone_skip_job") {
            var skipResult = workPanelController.skipOrNextJob()
            if (skipResult && !skipResult.ok)
                screen.showFeedback(
                    (void i18n.revision, i18n.t("clone.skip_failed", "Skip failed")),
                    String(skipResult.message || skipResult.error || "Could not skip job.")
                )
        } else if (action === "clone_toggle_manual_mode") {
            var isManual = workPanelController.isManualMode()
            workPanelController.setManualMode(!isManual)
        } else if (action === "clone_platform_login") {
            var platform = String(routePayload.platform || "youtube")
            var loginResult = workPanelController.loginPlatform(platform)
            if (loginResult && loginResult.ok)
                screen.showFeedback(
                    (void i18n.revision, i18n.t("clone.login_initiated", "Login")),
                    String(loginResult.message || "Platform login initiated.")
                )
        } else if (action === "clone_count_tokens") {
            var tokenResult = workPanelController.countTokensAuto()
            screen.showFeedback(
                (void i18n.revision, i18n.t("clone.token_count", "Token count")),
                String(tokenResult.message || "Token count unavailable.")
            )
        } else if (action === "clone_delete_selected") {
            var selectedIds = workPanelContent.selectedCardIds || []
            if (selectedIds.length > 0) {
                screen.applyQueueResult(
                    workPanelController.deleteSelectedVideos(selectedIds),
                    "Could not delete selected videos.",
                    "Videos removed."
                )
            }
        } else if (action === "transcript_poll_status") {
            var rowId = String(routePayload.row_id || "")
            if (rowId.length > 0)
                workPanelController.pollTranscriptJobStatus(rowId)
        } else if (action === "batch_check_upscale_tier") {
            var tierResult = workPanelController.checkUpscaleTierGate()
            if (!tierResult.upscale_4k_allowed)
                screen.showFeedback(
                    (void i18n.revision, i18n.t("batch.tier_gate", "Tier required")),
                    String(tierResult.message || "4K upscale requires premium tier.")
                )
        } else if (action === "clone_video_files") {
            screen.pickCloneVideoFiles()
        } else if (action === "clone_video_folder") {
            screen.pickCloneVideoFolder()
        } else if (action === "transcript_audio_files") {
            screen.pickTranscriptAudioFiles()
        } else if (action === "transcript_audio_folder") {
            screen.pickTranscriptAudioFolder()
        } else if (action === "batch_reference_images") {
            screen.openBatchReferencePicker(routePayload)
        } else if (action === "product_builder") {
            // Affiliate: MỘT cửa import duy nhất — ảnh rời (mỗi ảnh = 1 SP) hoặc
            // folder cha (mỗi thư mục con = 1 SP); hệ thống tự chuẩn hoá tất cả.
            affiliateImportDialog.resetForm()
            affiliateImportDialog.open()
        } else if (action === "product_library") {
            workPanelController.refreshProductLibrary("", "")
            // Affiliate: mở ở chế độ chọn nhiều SP → addAffiliateProductCards.
            productLibraryDialog.selectMode = (screen.route === "affiliate")
            productLibraryDialog.selectedProductIds = []
            productLibraryDialog.open()
        } else if (action === "affiliate_character") {
            affiliateCharacterDialog.open()
        } else if (action === "affiliate_background") {
            affiliateBackgroundDialog.open()
        } else {
            workPanelController.executeRouteTool(action)
        }
    }

    function pickTranscriptAudioFiles() {
        var picked = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("transcript.select_audio_files", "Select audio files")),
            "Audio Files (*.mp3 *.wav *.m4a *.ogg);;Subtitle (*.srt *.vtt);;All Files (*.*)",
            ""
        )
        if (picked && picked.ok)
            screen.applyQueueResult(
                workPanelController.addLocalFiles(picked.paths || [], "transcript_audio"),
                (void i18n.revision, i18n.t("transcript.add_audio_failed", "Could not add local audio files.")),
                (void i18n.revision, i18n.t("transcript.add_audio_success", "Local audio files added."))
            )
    }

    function pickTranscriptAudioFolder() {
        var picked = nativeShell.pickFolder(
            (void i18n.revision, i18n.t("transcript.select_audio_folder", "Select audio folder")),
            ""
        )
        if (picked && picked.ok)
            screen.applyQueueResult(
                workPanelController.addLocalFolder(String(picked.path || ""), "transcript_audio"),
                (void i18n.revision, i18n.t("transcript.add_audio_folder_failed", "Could not add audio folder.")),
                (void i18n.revision, i18n.t("transcript.add_audio_folder_success", "Audio folder added."))
            )
    }

    function pickCloneVideoFiles() {
        var picked = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("media.select_video_files", "Select video files")),
            "Video Files (*.mp4 *.avi *.mov *.mkv *.webm *.flv *.wmv *.3gpp *.mpeg *.mpg);;All Files (*.*)",
            ""
        )
        if (picked && picked.ok)
            screen.applyQueueResult(
                workPanelController.addLocalFiles(picked.paths || [], "clone_video"),
                (void i18n.revision, i18n.t("clone.add_video_failed", "Could not add local videos.")),
                (void i18n.revision, i18n.t("clone.add_video_success", "Local videos added."))
            )
    }

    function pickCloneVideoFolder() {
        var picked = nativeShell.pickFolder(
            (void i18n.revision, i18n.t("clone.select_folder", "Select Folder")),
            ""
        )
        if (picked && picked.ok)
            screen.applyQueueResult(
                workPanelController.addLocalFolder(String(picked.path || ""), "clone_video"),
                (void i18n.revision, i18n.t("clone.add_video_folder_failed", "Could not add video folder.")),
                (void i18n.revision, i18n.t("clone.add_video_folder_success", "Video folder added."))
            )
    }

    function handleWorkspaceAction(actionId, payload) {
        var data = payload || ({})
        if (screen.route === "affiliate"
                && workPanelController.affiliateUiPreview) {
            statusController.setStatusMessage(
                "Affiliate UI Preview: thao tác thật đã được khóa.")
            return
        }
        if (screen.route === "affiliate" && [
                "work_panel.submit_all",
                "work_panel.start_queue",
                "work_panel.pause_queue",
                "work_panel.affiliate_start"
            ].indexOf(String(actionId || "")) >= 0) {
            workPanelController.saveAffiliateMode(
                String(workPanelContent.affiliateStartMode || (workPanelController.currentRouteConfig || {}).start_mode || "direct")
            )
        }
        if (!actionId || actionId === "work_panel.section_toggle")
            return
        var affiliateProductionActions = [
            "work_panel.affiliate_auto_pool_toggle",
            "work_panel.affiliate_continue_submit",
            "work_panel.affiliate_manual_enqueue",
            "work_panel.affiliate_analyze_campaign",
            "work_panel.affiliate_reprep",
            "work_panel.affiliate_replan",
            "work_panel.affiliate_retry_failed",
            "work_panel.affiliate_generate_script",
            "work_panel.affiliate_start"
        ]
        if (screen.route === "affiliate"
                && affiliateProductionActions.indexOf(String(actionId)) >= 0) {
            var runAffiliateAction = function() {
                screen.applyQueueResult(
                    workPanelController.executeAffiliateQueueAction(actionId, data),
                    (void i18n.revision, i18n.t(
                        "affiliate.production_action_failed",
                        "Không thể chạy tác vụ Affiliate."
                    )),
                    (void i18n.revision, i18n.t(
                        "affiliate.production_action_started",
                        "Affiliate đã nhận yêu cầu xử lý."
                    )),
                    true
                )
            }
            var enablingAutopilot = actionId === "work_panel.affiliate_auto_pool_toggle"
                && Boolean(data.enabled)
            var requiresConfigReview = actionId === "work_panel.affiliate_manual_enqueue"
                || actionId === "work_panel.affiliate_continue_submit"
                || actionId === "work_panel.affiliate_start"
                || actionId === "work_panel.affiliate_generate_script"
                || enablingAutopilot
            if (requiresConfigReview)
                screen.gateQueue(runAffiliateAction)
            else
                runAffiliateAction()
            return
        }
        if (actionId === "work_panel.clone_draw_settings"
                || actionId === "work_panel.transcript_draw_settings") {
            if (masterConfigPanelRef && masterConfigPanelRef.openDrawManagerExternal)
                masterConfigPanelRef.openDrawManagerExternal()
            return
        }
        if (actionId === "work_panel.bulk_import_guide") {
            screen.bulkImportGuideRequested(String((data && data.guide) || "image"))
            return
        }
        if (actionId === "work_panel.clone_submit_worklist") {
            // Route the clone "Add to worklist" submit through the pre-queue
            // confirmation gate (gateQueue → QueuePreflightDialog). The PA1 path
            // called submitCloneCardsWithConfig directly and silently skipped it.
            var _cloneCards = (data && data.cards) || []
            screen.gateQueue(function() {
                screen.applyQueueResult(
                    workPanelController.submitCloneCardsWithConfig(_cloneCards),
                    (void i18n.revision, i18n.t("qml.work.submit_all_failed", "Could not submit cards to the queue.")),
                    (void i18n.revision, i18n.t("qml.work.submit_all_success", "Cards submitted to the queue.")),
                    true
                )
            })
            return
        }
        if (actionId === "work_panel.transcript_add_audio_to_queue") {
            // Same bypass as clone: the transcript "Add to queue" button submitted
            // directly (controller _submit_cards) and skipped the confirmation gate.
            // Route it through gateQueue → QueuePreflightDialog like every other tab.
            screen.gateQueue(function() {
                workPanelController.executePrimitiveAction(actionId, data)
            })
            return
        }
        if (actionId === "work_panel.queue_focus" || actionId === "work_panel.extend_queue_view") {
            if (screen.compactJobRail)
                screen.rightRailExpanded = true
            if (workPanelContent && workPanelContent.requestQueueFocus)
                workPanelContent.requestQueueFocus()
            workPanelController.executePrimitiveAction(actionId, data)
            return
        }
        if (actionId === "work_panel.import_from_batch_image") {
            var imported = workPanelController.importFromBatchImage()
            if (workPanelContent && workPanelContent.syncRouteConfigUi)
                workPanelContent.syncRouteConfigUi()
            if (!(imported && imported.ok)) {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    String(
                        (imported && (imported.message || imported.error))
                        || (void i18n.revision, i18n.t(
                            "normal_panel.no_batch_images",
                            "Chưa có ảnh hoàn thành trên tab Tạo Hình Ảnh."
                        ))
                    )
                )
            }
            return
        }
        if (actionId === "work_panel.bulk_import") {
            var bulkMode = String((data && data.mode) || "")
            if (screen.route === "normal") {
                var normalFeature = String((workPanelController.currentRouteConfig || {}).feature_type || "")
                if (bulkMode === "named_ref") {
                    if (normalFeature === "image" || normalFeature === "multi_asset") {
                        screen.pendingBulkImportFeature = normalFeature
                        screen.pendingBulkImportMode = normalFeature === "multi_asset" ? "normal_named_ref_multi_asset" : "normal_named_ref_image"
                        screen.pendingBulkImportAssetsPerCard = screen.normalMultiAssetReferenceLimit()
                        bulkImportDialog.clearInput()
                        bulkImportDialog.openForNamedRef([], {
                            card_mode: normalFeature,
                            assets_per_card: screen.normalMultiAssetReferenceLimit()
                        })
                        return
                    }
                    bulkImportDialog.open()
                    return
                }
                if (normalFeature === "image") {
                    bulkImportDialog.openForImageMode("image", {
                        assets_per_card: screen.normalMultiAssetReferenceLimit()
                    })
                    return
                }
                if (normalFeature === "interpolation") {
                    bulkImportDialog.openForImageMode("interpolation", {
                        assets_per_card: screen.normalMultiAssetReferenceLimit()
                    })
                    return
                }
                if (normalFeature === "multi_asset") {
                    bulkImportDialog.openForImageMode("multi_asset", {
                        assets_per_card: screen.normalMultiAssetReferenceLimit()
                    })
                    return
                }
                // Text feature (and any unrecognized feature) -> plain text bulk
                // import. imageCardMode / namedRefMode are ONLY cleared by onClosed,
                // so without an explicit reset a previous image / interpolation /
                // multi_asset import session leaks into the text import and the
                // dialog wrongly re-opens as "bulk image import". Reset to a clean
                // text session before opening.
                screen.resetPendingBulkImport()
                bulkImportDialog.imageCardMode = ""
                bulkImportDialog.namedRefMode = false
                bulkImportDialog.clearInput()
                bulkImportDialog.open()
                return
            }
            if (screen.route === "batch") {
                screen.resetPendingBulkImport()
                if (bulkMode === "named_ref") {
                    bulkImportDialog.clearInput()
                    bulkImportDialog.openForNamedRef([], {
                        card_mode: "multi_ref",
                        assets_per_card: 10
                    })
                    return
                }
                bulkImportDialog.open()
                return
            }
            if (bulkMode === "named_ref") {
                screen.pendingBulkImportMode = "normal_named_ref_image"
                bulkImportDialog.open()
                return
            }
            bulkImportDialog.open()
            return
        }
        if (actionId === "work_panel.batch_import_images") {
            screen.resetPendingBulkImport()
            bulkImportDialog.clearInput()
            bulkImportDialog.openForImageMode("multi_ref", {
                initial_assets_per_card: 1
            })
            return
        }
        if (actionId === "work_panel.queue_open_output") {
            var outputFolder = String(data.output_folder || data.folder || "")
            var openResult = nativeShell.openPath(outputFolder)
            if (!openResult || openResult.ok !== true) {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    String(
                        (openResult && (openResult.message || openResult.error))
                        || (void i18n.revision, i18n.t("common.open_failed", "Could not open the requested folder."))
                    )
                )
            }
            return
        }
        if (actionId === "work_panel.queue_open_clip") {
            var clipPath = String(data.clip_path || data.path || "")
            var clipResult = nativeShell.openPath(clipPath)
            if (!clipResult || clipResult.ok !== true) {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    String(
                        (clipResult && (clipResult.message || clipResult.error))
                        || (void i18n.revision, i18n.t("common.open_failed", "Could not open the requested file."))
                    )
                )
            }
            return
        }
        if (actionId === "work_panel.clear_queue") {
            if (screen.route === "clone") {
                screen.openCloneClearQueueConfirm()
            } else {
                screen.applyQueueResult(
                    workPanelController.clearQueue(),
                    (void i18n.revision, i18n.t("qml.work.clear_queue_failed", "Could not clear the queue.")),
                    (void i18n.revision, i18n.t("qml.work.queue_cleared", "Queue cleared."))
                )
            }
            return
        }
        if (actionId === "work_panel.check_upscale_tier") {
            workPanelController.checkUpscaleTierGate()
            return
        }
        if (actionId === "work_panel.poll_account_credits") {
            workPanelController.pollAccountCredits()
            return
        }
        if (actionId === "work_panel.recover_dead_account") {
            var accountId = String(data.account_id || "")
            if (accountId.length > 0)
                workPanelController.recoverDeadAccount(accountId)
            return
        }
        if (actionId === "work_panel.clear_completed") {
            screen.applyQueueResult(
                workPanelController.clearCompleted(),
                (void i18n.revision, i18n.t("qml.work.clear_completed_failed", "Could not clear completed rows.")),
                (void i18n.revision, i18n.t("qml.work.clear_completed", "Completed rows cleared."))
            )
            return
        }
        if (actionId === "work_panel.start_queue") {
            var startResult
            if (screen.route === "clone" && workPanelController.cloneAuthPauseRequired)
                startResult = workPanelController.resumeCloneQueueAfterAuthUpdate()
            else if (screen.route === "transcript" && workPanelController.transcriptQueuePaused)
                startResult = workPanelController.continueQueue()
            else
                startResult = workPanelController.startQueue()
            screen.applyQueueResult(
                startResult,
                (void i18n.revision, i18n.t("qml.work.start_queue_failed", "Could not start the queue.")),
                (void i18n.revision, i18n.t("qml.work.start_queue", "Start requested"))
            )
            return
        }
        if (actionId === "work_panel.pause_queue") {
            screen.applyQueueResult(
                workPanelController.pauseQueue(),
                (void i18n.revision, i18n.t("qml.work.pause_queue_failed", "Could not pause the queue.")),
                (void i18n.revision, i18n.t("qml.work.pause_queue", "Pause requested"))
            )
            return
        }
        if (actionId === "work_panel.transcript_skip") {
            var transcriptSkipResult = workPanelController.skipTranscriptJob()
            if (transcriptSkipResult && !transcriptSkipResult.ok)
                screen.showFeedback(
                    (void i18n.revision, i18n.t("transcript_workspace.skip_failed", "Skip failed")),
                    String(transcriptSkipResult.message || transcriptSkipResult.error || "Could not skip Audio-to-Video job.")
                )
            return
        }
        if (actionId === "work_panel.clone_apply_style") {
            masterOptionsController.refreshStyles("")
            cloneApplyStyleDialog.openFor(masterOptionsController.styles || [])
            return
        }
        if (actionId === "work_panel.clone_batch_source_config") {
            var cloneBatchCardId = String(data.card_id || data.row_id || "")
            if (cloneBatchCardId.length <= 0)
                return
            cloneBatchConfigDialog.targetCardId = cloneBatchCardId
            var existingBatch = (data.card && data.card._batch_config) || ({})
            cloneBatchConfigDialog.openFor(existingBatch)
            return
        }
        if (actionId === "work_panel.clone_view_uploaded") {
            cloneUploadedCacheDialog.openFor(
                workPanelController.recentCloneUploads(),
                workPanelController.cloneUploadCachePath()
            )
            workPanelController.executePrimitiveAction(actionId, data)
            return
        }
        // Giọng affiliate giờ đi qua NARRATOR chung (narratorController trong
        // AffiliateWorkspace khu ③) — voice dialog/per-scene cũ đã gỡ (mồ côi).
        if (actionId === "work_panel.affiliate_image") {
            var pickedImg = nativeShell.pickFiles(
                (void i18n.revision, i18n.t("affiliate.pick_image_title", "Chọn ảnh sản phẩm")),
                (void i18n.revision, i18n.t("affiliate.pick_image_filter", "Images (*.png *.jpg *.jpeg *.webp);;All Files (*.*)")),
                ""
            )
            if (pickedImg && pickedImg.ok && pickedImg.paths && pickedImg.paths.length > 0)
                workPanelController.importAffiliateImagesAsync(pickedImg.paths)
            return
        }
        if (actionId === "work_panel.affiliate_image_drop") {
            if (data.paths && data.paths.length > 0)
                workPanelController.importAffiliateImagesAsync(data.paths)
            return
        }
        if (actionId === "work_panel.affiliate_import_folder") {
            // Hợp nhất: folder giờ nằm TRONG dialog Import SP (một cửa duy nhất).
            affiliateImportDialog.resetForm()
            affiliateImportDialog.open()
            return
        }
        if (actionId === "work_panel.affiliate_product_edit") {
            screen.openAffiliateProductEditor(data.product || (data.card && data.card.product) || data.card || ({}))
            return
        }
        if (actionId === "work_panel.affiliate_start_image_pick") {
            screen.openAffiliateStartImagePicker(Number(data.slot_index || 0))
            return
        }
        if (actionId === "work_panel.affiliate_start_image_auto_fill") {
            screen.applyQueueResult(
                workPanelController.autoFillAffiliateStartImages(),
                (void i18n.revision, i18n.t("affiliate.start_images_auto_fill_failed", "Could not auto-fill affiliate start images.")),
                (void i18n.revision, i18n.t("affiliate.start_images_auto_fill_done", "Affiliate start images updated."))
            )
            return
        }
        if (actionId === "work_panel.affiliate_start_image_clear") {
            screen.applyQueueResult(
                workPanelController.clearAffiliateStartImages(),
                (void i18n.revision, i18n.t("affiliate.start_images_clear_failed", "Could not clear affiliate start images.")),
                (void i18n.revision, i18n.t("affiliate.start_images_clear_done", "Affiliate start images cleared."))
            )
            return
        }
        if (actionId === "work_panel.affiliate_start_image_remove") {
            screen.applyQueueResult(
                workPanelController.removeAffiliateStartImage(Number(data.slot_index || 0)),
                (void i18n.revision, i18n.t("affiliate.start_images_remove_failed", "Could not remove the affiliate start image.")),
                (void i18n.revision, i18n.t("affiliate.start_images_remove_done", "Affiliate start image removed."))
            )
            return
        }
        if (actionId === "work_panel.transcript_instruction") {
            transcriptInstructionDialog.openFor(data)
            return
        }
        if (actionId === "work_panel.extend_rules") {
            extendRulesDialog.openFor(workPanelController.loadExtendRules())
            workPanelController.executePrimitiveAction(actionId, data)
            return
        }
        if (actionId === "work_panel.extend_preview") {
            // Quick ffmpeg-concat of completed chain clips → temp file → OS player.
            // Python emits openPathRequested on success (no timeline dialog).
            var preview = workPanelController.previewExtendSessionTimeline()
            if (preview && preview.ok) {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("qml.work.extend_preview_ok", "Preview")),
                    String(preview.message || (void i18n.revision, i18n.t("qml.work.extend_preview_ok_detail", "Opening quick preview…")))
                )
            } else {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("qml.work.extend_preview_failed", "Could not load extend preview.")),
                    String(
                        (preview && (
                            preview.message
                            || preview.error
                            || (preview.blocker && preview.blocker.message)
                        ))
                        || (void i18n.revision, i18n.t("qml.work.extend_preview_failed", "Could not load extend preview."))
                    )
                )
            }
            return
        }
        if (actionId === "work_panel.extend_generate_timeline") {
            var timeline = workPanelController.generateExtendTimeline(String(data.idea || ""))
            if (timeline && timeline.deferred)
                return  // analysing the ROOT scene first; beats fill the Overview when ready
            if (timeline && timeline.ok)
                bulkExtendImportDialog.openForGenerated(timeline.items || [])
            else
                screen.showFeedback(
                    (void i18n.revision, i18n.t("qml.work.extend_generate_timeline_failed", "Could not build extend timeline.")),
                    String(
                        (timeline && (
                            timeline.message
                            || timeline.error
                            || (timeline.blocker && timeline.blocker.message)
                        ))
                        || (void i18n.revision, i18n.t("qml.work.extend_generate_timeline_failed", "Could not build extend timeline."))
                    )
                )
            return
        }
        if (actionId === "work_panel.extend_queue_idea") {
            var queuedIdea = workPanelController.queueExtendIdea(String(data.idea || ""))
            if (!(queuedIdea && queuedIdea.ok)) {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    String(
                        (queuedIdea && (
                            queuedIdea.message
                            || queuedIdea.error
                            || (queuedIdea.blocker && queuedIdea.blocker.message)
                        ))
                        || "Không thể thêm ý tưởng vào hàng chờ."
                    )
                )
            }
            return
        }
        if (actionId === "work_panel.extend_analyze_source") {
            var analysisResult = workPanelController.analyzeExtendSource(String(data.idea || ""))
            if (!(analysisResult && analysisResult.ok)) {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("qml.work.extend_analyze_source_failed", "Could not analyze extend source.")),
                    String(
                        (analysisResult && (
                            analysisResult.message
                            || analysisResult.error
                            || (analysisResult.blocker && analysisResult.blocker.message)
                        ))
                        || (void i18n.revision, i18n.t("qml.work.extend_analyze_source_failed", "Could not analyze extend source."))
                    )
                )
            }
            return
        }
        if (actionId === "work_panel.extend_apply_selected") {
            var applySelectedResult = workPanelController.applySelectedExtendBeat(Number(data.selected_index || -1))
            if (!(applySelectedResult && applySelectedResult.ok)) {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("qml.work.extend_apply_selected_failed", "Could not apply the selected extend beat.")),
                    String(
                        (applySelectedResult && (
                            applySelectedResult.message
                            || applySelectedResult.error
                            || (applySelectedResult.blocker && applySelectedResult.blocker.message)
                        ))
                        || (void i18n.revision, i18n.t("qml.work.extend_apply_selected_failed", "Could not apply the selected extend beat."))
                    )
                )
            }
            return
        }
        if (actionId === "work_panel.extend_regenerate_selected") {
            var regenSelectedResult = workPanelController.regenerateSelectedExtendBeat(
                Number(data.selected_index || -1),
                String(data.idea || "")
            )
            if (!(regenSelectedResult && regenSelectedResult.ok)) {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("qml.work.extend_regenerate_selected_failed", "Could not regenerate the selected extend beat.")),
                    String(
                        (regenSelectedResult && (
                            regenSelectedResult.message
                            || regenSelectedResult.error
                            || (regenSelectedResult.blocker && regenSelectedResult.blocker.message)
                        ))
                        || (void i18n.revision, i18n.t("qml.work.extend_regenerate_selected_failed", "Could not regenerate the selected extend beat."))
                    )
                )
            }
            return
        }
        if (actionId === "work_panel.extend_queue_selected") {
            screen.applyQueueResult(
                workPanelController.queueSelectedExtendBeat(Number(data.selected_index || -1)),
                (void i18n.revision, i18n.t("qml.work.extend_queue_selected_failed", "Could not queue the selected extend beat.")),
                (void i18n.revision, i18n.t("qml.work.extend_queue_selected_success", "Selected extend beat queued."))
            )
            return
        }
        if (actionId === "work_panel.extend_root_asset_pick") {
            screen.openExtendRootAssetPicker(Number(data.slot_index || 0))
            return
        }
        if (actionId === "work_panel.extend_delete_session") {
            var currentSession = workPanelController.extendSessionState || {}
            screen.requestExtendSessionDelete(String(currentSession.session_key || currentSession.id || ""))
            return
        }
        // These open the bulk-import dialog via handleRouteTool. Without an
        // explicit branch they fall through to executePrimitiveAction (which
        // only sets a status message in Python and returns true), so the QML
        // dialog never opens. Route them here before that fallthrough.
        if (actionId === "work_panel.extend_set_mode") {
            workPanelController.setExtendMode(String(data.mode || "standard"))
            return
        }
        if (actionId === "work_panel.extend_bulk_import") {
            // Extend "Add" must open the extend-aware BulkExtendImportDialog (ROOT/EXTEND
            // chain editor), NOT the generic BulkImportDialog used by other routes.
            screen.handleRouteTool("extend_bulk_import", data)
            return
        }
        if (actionId === "work_panel.extend_bulk_preview") {
            screen.handleRouteTool("extend_bulk_preview", data)
            return
        }
        if (actionId === "work_panel.extend_import_session") {
            screen.handleRouteTool("extend_import_session", data)
            return
        }
        if (actionId === "work_panel.history") {
            screen.handleHistoryRequested()
            return
        }
        if (actionId === "prompt_card.edit") {
            var cardPayload = data.card || ({})
            if (screen.route === "batch" && Boolean(cardPayload.preview_only)) {
                workPanelController.executePrimitiveAction("work_panel.add_blank", { source: "batch_preview_row" })
                var createdBatchCards = workPanelController.cards || []
                var createdBatchCard = createdBatchCards.length > 0 ? createdBatchCards[createdBatchCards.length - 1] : ({})
                promptEditDialog.openFor(createdBatchCard)
                return
            }
            if (!cardPayload.mode && data.mode)
                cardPayload.mode = String(data.mode)
            if (!cardPayload.card_mode && data.card_mode)
                cardPayload.card_mode = String(data.card_mode)
            if (screen.isMultiAssetPayload(cardPayload))
                multiAssetPromptEditDialog.openFor(cardPayload)
            else
                promptEditDialog.openFor(cardPayload)
            return
        }
        if (actionId === "work_panel.batch_add_prompt") {
            workPanelController.executePrimitiveAction("work_panel.add_blank", { source: "batch_toolbar" })
            var batchCards = workPanelController.cards || []
            var newCard = batchCards.length > 0 ? batchCards[batchCards.length - 1] : ({})
            promptEditDialog.openFor(newCard)
            return
        }
        if (actionId === "prompt_card.media") {
            screen.mediaTargetMode = "card_attach"
            screen.mediaTargetCardId = String(data.card_id || screen.cardId(data.card || ({})))
            screen.mediaTargetCharacterId = ""
            var slotIdx = (data.slot_index !== undefined && data.slot_index !== null) ? Number(data.slot_index) : -1
            // Prompt-card slots pass their identity in button_type ("asset1".."asset7" /
            // "single" / "start" / "end"), NOT slot_index — derive the index so the media
            // lands in the RIGHT slot (was attaching to slot -1, so the image never showed).
            if (slotIdx < 0) {
                var bt = String(data.button_type || data.slot_role || "")
                var btNum = bt.match(/(\d+)\s*$/)
                if (btNum) slotIdx = Number(btNum[1]) - 1
                else if (bt === "single" || bt === "start") slotIdx = 0
                else if (bt === "end") slotIdx = 1
                else slotIdx = 0
            }
            screen.mediaTargetSlotIndex = slotIdx
            var mediaFilterType = String(data.media_filter_type || data.slot_role || "")
            // Normal ingredient slots are UI-role aware only: character slots
            // open the Character library, object slots open the Object library.
            // Backend placement still uses slot_index and keeps its flat payload.
            mediaLibraryDialog.mode = "select"
            mediaLibraryDialog.filterType = mediaFilterType
            mediaLibraryDialog.maxSelection = 1
            mediaLibraryDialog.open()
            return
        }
        if (actionId === "work_panel.extend_render_video") {
            extendRenderDialog.openFor(data)
            return
        }
        if (actionId === "work_panel.affiliate_character") {
            var charMode = String(data.mode || "")
            if (charMode === "remove")
                // column_id → gỡ khỏi override RIÊNG SP (card.col); rỗng → global slots.
                String(data.column_id || "").length > 0
                    ? workPanelController.removeAffiliateRouteAssetFromColumn("character", String(data.asset_id || ""), String(data.column_id))
                    : workPanelController.removeAffiliateRouteAsset("character", String(data.asset_id || ""))
            else if (charMode === "create_ai")
                affiliateCharGenDialog.open()
            else
                screen.openAffiliateAssetPicker("character", String(data.column_id || ""))   // Chọn → media library (column-targeted nếu có column_id)
            return
        }
        if (actionId === "work_panel.affiliate_background") {
            var bgMode = String(data.mode || "")
            if (bgMode === "remove")
                String(data.column_id || "").length > 0
                    ? workPanelController.removeAffiliateRouteAssetFromColumn("background", String(data.asset_id || ""), String(data.column_id))
                    : workPanelController.removeAffiliateRouteAsset("background", String(data.asset_id || ""))
            else if (bgMode === "create_ai")
                affiliateBgGenDialog.open()
            else
                screen.openAffiliateAssetPicker("background", String(data.column_id || ""))   // Chọn → media library (column-targeted nếu có column_id)
            return
        }
        if (actionId === "work_panel.batch_open_folder") {
            data.output_folder = String((masterOptionsController.config || {}).output_folder || "")
        }
        if (actionId === "work_panel.batch_reference_remove") {
            screen.applyQueueResult(
                workPanelController.removeBatchReferenceImageFromTarget(
                    String(data.card_id || data.row_id || ""),
                    Number(data.ref_index || 0)
                ),
                (void i18n.revision, i18n.t("batch.reference_images_failed", "Could not attach batch reference images.")),
                (void i18n.revision, i18n.t("batch.reference_images_removed", "Batch reference image removed."))
            )
            return
        }
        if (actionId === "prompt_card.generate_extend") {
            screen.applyQueueResult(
                workPanelController.generateExtendForCard(String(data.card_id || data.row_id || screen.cardId(data.card || ({})))),
                (void i18n.revision, i18n.t("qml.work.generate_extend_failed", "Could not continue extend queue.")),
                (void i18n.revision, i18n.t("qml.work.generate_extend_success", "Extend queue submitted."))
            )
            return
        }
        if (actionId === "prompt_card.commit_prompt") {
            // Persist an inline prompt edit (TextArea focus-out) into the backend card,
            // so the Extend guard and session-save see what the user typed.
            workPanelController.commitExtendCardPrompt(
                String(data.card_id || data.row_id || screen.cardId(data.card || ({}))),
                String((data.card || ({})).prompt || "")
            )
            return
        }
        if (actionId === "prompt_card.extend") {
            // The "Extend" (kéo dài) button spawns a new EXTEND segment. Commit the
            // inline prompt FIRST so the guard sees the text just typed, then surface
            // the result so a blocked action shows a reason instead of doing nothing.
            var extCardId = String(data.card_id || data.row_id || screen.cardId(data.card || ({})))
            workPanelController.commitExtendCardPrompt(extCardId, String((data.card || ({})).prompt || ""))
            var extResult = workPanelController.extendCard(extCardId)
            if (extResult && extResult.ok === false)
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    String(extResult.message || extResult.error || (void i18n.revision, i18n.t("common.action_failed", "Action failed")))
                )
            return
        }
        if (actionId === "prompt_card.insert_after_requested") {
            var insResult = workPanelController.insertExtendAfter(String(data.card_id || data.row_id || screen.cardId(data.card || ({}))))
            if (insResult && insResult.ok === false)
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    String(insResult.message || insResult.error || (void i18n.revision, i18n.t("common.action_failed", "Action failed")))
                )
            return
        }
        if (actionId === "prompt_card.remove_timeline") {
            var rmResult = workPanelController.toggleExtendTimeline(String(data.card_id || data.row_id || screen.cardId(data.card || ({}))))
            if (rmResult && rmResult.ok === false)
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    String(rmResult.message || rmResult.error || (void i18n.revision, i18n.t("common.action_failed", "Action failed")))
                )
            return
        }
        if (actionId === "prompt_card.submit") {
            var _submitCardId = String(data.card_id || data.row_id || screen.cardId(data.card || ({})))
            screen.gateQueue(function() {
                screen.applyQueueResult(
                    workPanelController.submitCard(_submitCardId),
                    (void i18n.revision, i18n.t("qml.work.submit_card_failed", "Could not submit card to the queue.")),
                    (void i18n.revision, i18n.t("qml.work.submit_card_success", "Card submitted to the queue.")),
                    true
                )
            })
            return
        }
        if (actionId.indexOf("job_panel.") === 0) {
            screen.handleJobPanelAction(actionId, data)
            return
        }
        if (workPanelController.executePrimitiveAction(actionId, data))
            return
        var routeTool = String(data.route_tool || "")
        if (routeTool.length > 0)
            screen.handleRouteTool(routeTool, data)
    }

    function resolveJobPanelRow(jobId) {
        var target = String(jobId || "")
        if (target.length <= 0)
            return ({})
        if (workPanelController && workPanelController.jobPanelRow) {
            var resolved = workPanelController.jobPanelRow(jobId)
            if (resolved && Object.keys(resolved).length > 0)
                return resolved
        }
        return { id: target, row_id: target, job_id: target }
    }

    function handleJobPanelAction(actionId, payload) {
        if (screen.route === "affiliate"
                && workPanelController.affiliateUiPreview) {
            statusController.setStatusMessage(
                "Affiliate UI Preview: thao tác job thật đã được khóa.")
            return
        }
        var data = payload || ({})
        var targetJobId = String(data.job_id || data.row_id || "")
        var row = data.row || screen.resolveJobPanelRow(targetJobId)
        if (targetJobId.length <= 0)
            targetJobId = String(row.job_id || row.id || screen.cardId(row) || "")
        var isCloneQueueRow = screen.route === "clone" && String(data.source || "") === "clone_queue_row"
        if (actionId === "job_panel.review") {
            workPanelController.setJobPanelReview(
                targetJobId,
                String(data.review_status || data.status || "")
            )
            return
        }
        if (actionId === "job_panel.view") {
            if (isCloneQueueRow) {
                screen.openCloneSceneAnalysisForRow(targetJobId)
                return
            }
            if (screen.route === "batch") {
                var batchImageOpened = workPanelController.openBatchImageJobOutput(targetJobId)
                if (!(batchImageOpened && batchImageOpened.ok)) {
                    screen.showFeedback(
                        (void i18n.revision, i18n.t("common.warning", "Warning")),
                        String((batchImageOpened && (
                            batchImageOpened.message
                            || batchImageOpened.error
                            || batchImageOpened.code
                        )) || (void i18n.revision, i18n.t("batch_image.output_missing", "Batch image output is not available yet.")))
                    )
                }
                return
            }
            if (screen.route === "clone") {
                var opened = workPanelController.openCloneJobOutput(
                    targetJobId
                )
                if (!(opened && opened.ok)) {
                    screen.showFeedback(
                        (void i18n.revision, i18n.t("common.warning", "Warning")),
                        String((opened && (
                            opened.message
                            || opened.error
                            || opened.code
                        )) || (void i18n.revision, i18n.t("clone.output_missing", "Clone scene output is not available yet.")))
                    )
                }
                return
            }
            if (screen.route === "transcript") {
                var transcriptOpened = workPanelController.openTranscriptJobOutput(
                    String(data.row_id || row.job_id || screen.cardId(row) || "")
                )
                if (!(transcriptOpened && transcriptOpened.ok)) {
                    screen.showFeedback(
                        (void i18n.revision, i18n.t("common.warning", "Warning")),
                        String((transcriptOpened && (
                            transcriptOpened.message
                            || transcriptOpened.error
                            || transcriptOpened.code
                        )) || (void i18n.revision, i18n.t("transcript.output_missing", "Transcript scene output is not available yet.")))
                    )
                }
                return
            }
            promptEditDialog.openReadOnly(row)
            return
        }
        if (actionId === "job_panel.open_folder") {
            var folder = String((row || {}).output_folder || (row || {}).session_folder || "")
            if (folder.length > 0) {
                nativeShell.openPath(folder)
                return
            }
            // The panel row carried no folder — transcript/clone queue rows are keyed
            // by BATCH id (not a job-panel scene row), so resolveJobPanelRow can't
            // attach output_folder/session_folder here. Fall through to the
            // controller's route resolver (openTranscriptQueueRowFolder /
            // openCloneQueueRowFolder) which looks the batch up by row_id.
            if (workPanelController.executePrimitiveAction(actionId, data))
                return
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                (void i18n.revision, i18n.t("job_panel.output_folder_missing", "No output folder for this row yet."))
            )
            return
        }
        if (actionId === "job_panel.edit") {
            if (isCloneQueueRow) {
                screen.jobPromptEditContext = ({})
                screen.clonePromptEditContext = ({})
                screen.pendingClonePromptRegen = false
                screen.transcriptPromptEditContext = ({})
                screen.pendingTranscriptPromptRegen = false
                promptEditDialog.openFor(row)
                screen.refreshPromptEditorAssets(String(row.id || row.row_id || row.job_id || ""))
                return
            }
            if (screen.route === "clone") {
                screen.jobPromptEditContext = ({})
                screen.clonePromptEditContext = {
                    jobId: targetJobId,
                    row: row
                }
                screen.pendingClonePromptRegen = false
                screen.transcriptPromptEditContext = ({})
                screen.pendingTranscriptPromptRegen = false
            } else if (screen.route === "transcript") {
                screen.jobPromptEditContext = ({})
                screen.transcriptPromptEditContext = {
                    jobId: String(data.row_id || screen.cardId(row) || row.job_id || ""),
                    row: row
                }
                screen.pendingTranscriptPromptRegen = false
                screen.clonePromptEditContext = ({})
                screen.pendingClonePromptRegen = false
            } else {
                screen.clonePromptEditContext = ({})
                screen.pendingClonePromptRegen = false
                screen.transcriptPromptEditContext = ({})
                screen.pendingTranscriptPromptRegen = false
                screen.jobPromptEditContext = {
                    jobId: targetJobId,
                    row: row,
                    route: screen.route
                }
            }
            promptEditDialog.openFor(row)
            screen.refreshPromptEditorAssets(targetJobId)
            return
        }
        if (actionId === "job_panel.regenerate"
                || actionId === "job_panel.retry") {
            if (isCloneQueueRow) {
                screen.openCloneRetryRowConfirm(row)
                return
            }
            if (targetJobId.length === 0) {
                screen.openJobPanelBatchActions()
                return
            }
            if (screen.route === "clone") {
                screen.requestCloneSceneRegen(row)
            } else if (screen.route === "transcript") {
                screen.requestTranscriptSceneRegen(row)
            } else {
                screen.requestJobPanelSceneRegen(row)
            }
            return
        }
        if (actionId === "job_panel.asset") {
            screen.handleJobAssetRequested(row, Number(data.slot_index || 0))
            return
        }
        if (workPanelController.executePrimitiveAction(actionId, data))
            return
        if (actionId === "job_panel.delete")
            if (isCloneQueueRow) {
                screen.openCloneDeleteRowConfirm(row)
            } else
            if (screen.route === "clone") {
                screen.requestCloneSceneDelete(row)
            } else if (screen.route === "transcript") {
                screen.requestTranscriptSceneDelete(row)
            } else {
                screen.applyQueueResult(
                    workPanelController.removeRow(String(data.row_id || screen.cardId(row))),
                    (void i18n.revision, i18n.t("common.delete_failed", "Delete failed")),
                    (void i18n.revision, i18n.t("messages.deleted_job", "Deleted job."))
                )
            }
    }

    onRouteChanged: {
        screen.scheduleRouteSync()
        workspaceRouteConfigSync.restart()
    }
    onShowRightRailChanged: {
        if (showRightRail)
            rightRailExpanded = false
    }

    Connections {
        target: typeof masterOptionsController !== "undefined" ? masterOptionsController : null
        // Screen ẩn vẫn sống (App.qml Loader latch) -> chỉ relay master config khi
        // đang hiển thị; lúc hiện lại onVisibleChanged dưới đây bù 1 lần.
        enabled: screen.visible
        function onConfigChanged() {
            if (typeof workPanelController !== "undefined" && workPanelController && workPanelController.refreshMasterRouteConfig)
                workPanelController.refreshMasterRouteConfig()
        }
    }
    onVisibleChanged: {
        if (visible && typeof workPanelController !== "undefined" && workPanelController && workPanelController.refreshMasterRouteConfig)
            workPanelController.refreshMasterRouteConfig()
    }

    Connections {
        target: workPanelController

        function onRouteConfigChanged() {
            workspaceRouteConfigSync.restart()
        }

        function onOpenPathRequested(path) {
            nativeShell.openPath(path)
        }

        // Backend blocks the transcript queue when no style is picked (add_to_queue →
        // style_required). Without this the block was SILENT — surface it so the user
        // knows why nothing was queued.
        function onTranscriptStyleRequired() {
            if (screen.route !== "transcript")
                return
            screen.showFeedback(
                (void i18n.revision, i18n.t("transcript.style_required_title", "Chưa chọn style")),
                (void i18n.revision, i18n.t(
                    "transcript.style_required_message",
                    "Hãy chọn một style trước khi thêm vào hàng chờ.\n\nMở Master Config → chọn style rồi thêm lại."
                ))
            )
        }

        // Genuinely image-less characters (no inline base64, no file, not in the media
        // library) can't supply a reference. The preflight now resolves library picks by
        // media_id, so this only fires for truly broken selections — tell the user which.
        function onTranscriptCharactersMissingBase64(missing) {
            if (screen.route !== "transcript")
                return
            var names = (missing && missing.length) ? String(missing.join(", ")) : ""
            screen.showFeedback(
                (void i18n.revision, i18n.t("transcript.char_missing_image_title", "Nhân vật thiếu ảnh tham chiếu")),
                (void i18n.revision, i18n.t(
                    "transcript.char_missing_image_message",
                    "Các nhân vật sau không có ảnh tham chiếu hợp lệ: {names}.\n\nChọn lại ảnh nhân vật (từ Media Library hoặc file) rồi thêm lại."
                )).replace("{names}", names)
            )
        }

        function onCloneNoLiveAccountsPauseDialogRequested() {
            if (screen.route !== "clone")
                return
            screen.showFeedback(
                (void i18n.revision, i18n.t("clone.queue_paused_title", "Queue Paused - No Live Account")),
                (void i18n.revision, i18n.t(
                    "clone.queue_paused_no_account",
                    "Queue has been PAUSED because no Live account available!\n\nPlease:\n1. Check ACCOUNTS tab\n2. Ensure at least 1 account has 'Live' status\n3. Click 'Continue Clone' to resume queue"
                ))
            )
        }

        function onCloneTerminalPauseDialogRequested(code, detail) {
            if (screen.route !== "clone")
                return
            if (code === "gemini_not_configured") {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("clone.gemini_not_configured_title", "Gemini API Not Configured")),
                    (void i18n.revision, i18n.t(
                        "clone.gemini_not_configured_message",
                        "Gemini AI provider is not configured.\n\nPlease add Gemini API key in:\nSettings -> AI Providers -> Gemini API Keys\n\nOr check server connection if using Server Mode."
                    ))
                )
                return
            }
            if (code === "personal_api_key_required") {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("clone.personal_api_key_required_title", "Personal API Key Required")),
                    (void i18n.revision, i18n.t(
                        "clone.personal_api_key_required_message",
                        "Personal API mode does not have a valid Gemini API key yet.\n\nAdd a Gemini API key in the Gemini API Keys dialog, or switch to Server mode to use the shared system key pool.\n\nAfter configuring it, press Start again to continue."
                    ))
                )
                return
            }
            if (code === "insufficient_credits") {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("clone.insufficient_credits_pause_title", "Insufficient Credits")),
                    (void i18n.revision, i18n.t(
                        "clone.insufficient_credits_pause_message",
                        "Not enough credits to continue.\n\n{detail}\n\nPlease top up more credits at veoflow.dev/credits/topup"
                    )).replace("{detail}", String(detail || (void i18n.revision, i18n.t("clone.insufficient_credits_msg", "Insufficient credits to generate video"))))
                )
                return
            }
            if (code === "source_upload_limit_exceeded") {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("clone.source_upload_limit_title", "Source Video Exceeds Upload Limit")),
                    (void i18n.revision, i18n.t(
                        "clone.source_upload_limit_message",
                        "{detail}\n\nThe job was stopped before analysis and the video was not loaded as base64 into RAM.\n\nSwitch to API Server/Both mode, or use a smaller source, then retry this row."
                    )).replace("{detail}", String(detail || "The selected provider cannot upload this source video."))
                )
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: VfTheme.canvas
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(10)
        spacing: VfTheme.dp(10)

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            border.color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: VfTheme.dp(8)

                MasterConfigPanel {
                    id: masterConfigPanelRef
                    Layout.fillWidth: true
                    // Affiliate nhúng config bar BÊN TRONG tab Chuẩn bị (job builder) →
                    // ẩn bar trên cùng để khỏi nhân đôi.
                    visible: screen.route !== "affiliate"
                    Layout.preferredHeight: visible ? implicitHeight : 0
                    route: screen.route
                    currentBatchConfig: screen.currentBatchConfig
                }

                ScrollView {
                    id: leftScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    contentWidth: workPanelContent.width

                    WorkPanelWorkspace {
                        id: workPanelContent
                        // Fill the scroll column exactly (skill gotcha: a ScrollView child
                        // must size to <scrollView>.availableWidth, NOT a hand-computed
                        // screen.width - rail - 40). The old magic calc left a gap on the
                        // right and forced a horizontal scrollbar when narrow. The inner
                        // ResponsiveSplit handles shrinking, so no min-width floor is needed.
                        width: leftScroll.availableWidth
                        height: Math.max(leftScroll.availableHeight, leftScroll.height, screen.height - 170, implicitHeight)
                        meta: workPanelController.screenMeta
                        // ARCHITECTURE NOTE:
                        // Batch passes an empty legacy cards list and renders from
                        // cardModel. QML should display/select only; all build-job
                        // work must go through WorkPanelController -> backend gateway.
                        cards: screen.route === "batch" ? [] : workPanelController.cards
                        cardModel: workPanelController.cardModel
                        queueRows: screen.queueRowsSafe
                        extendIdeaQueueModel: workPanelController.extendIdeaQueueModel
                        stats: screen.queueStatsSafe
                        currentBatchConfig: screen.currentBatchConfig
                        routeConfig: screen.workspaceRouteConfig
                        extendSessions: workPanelController.extendSessions
                        extendSession: workPanelController.extendSessionState
                        maxMultiAssetReferenceImages: screen.route === "batch" ? 10 : screen.maxMultiAssetReferenceImages
                        onActionRequested: (actionId, payload) => screen.handleWorkspaceAction(actionId, payload)
                        onSubmitAllRequested: screen.gateQueue(function() {
                            var submitResult = workPanelController.submitAllCards()
                            // batch + extend STAGE cards into their own queue (add_to_queue only)
                            // and need an explicit dispatch start; without it the jobs sit in the
                            // queue and never run. Other routes dispatch on submit. So after a
                            // successful extend/batch submit, kick startQueue() to actually run.
                            if (screen.route === "batch" || screen.route === "extend") {
                                if (!submitResult || !submitResult.ok) {
                                    screen.applyQueueResult(
                                        submitResult,
                                        (void i18n.revision, i18n.t("qml.work.submit_all_failed", "Could not submit cards to the queue.")),
                                        (void i18n.revision, i18n.t("qml.work.submit_all_success", "Cards submitted to the queue."))
                                    )
                                    return
                                }
                                screen.applyQueueResult(
                                    workPanelController.startQueue(),
                                    (void i18n.revision, i18n.t("qml.work.start_queue_failed", "Could not start the queue.")),
                                    (void i18n.revision, i18n.t("batch_image.batch_started", "Batch started.")),
                                    true
                                )
                                return
                            }
                            screen.applyQueueResult(
                                submitResult,
                                (void i18n.revision, i18n.t("qml.work.submit_all_failed", "Could not submit cards to the queue.")),
                                (void i18n.revision, i18n.t("qml.work.submit_all_success", "Cards submitted to the queue.")),
                                true
                            )
                        })
                        onExtendSessionNewRequested: {
                            // Port of the legacy AccountTabBar "+" flow: pick which Live account
                            // (with a free slot) the new session binds to, so multi-account users
                            // know which session belongs to which account.
                            var accounts = workPanelController.extendAvailableAccounts() || []
                            if (accounts.length === 0) {
                                screen.showFeedback(
                                    (void i18n.revision, i18n.t("account_tab.no_account_title", "Không có tài khoản")),
                                    (void i18n.revision, i18n.t("account_tab.no_account_msg", "Không có tài khoản Live nào còn slot phiên trống. Thêm/refresh tài khoản Live, hoặc đóng bớt phiên."))
                                )
                                return
                            }
                            if (accounts.length === 1) {
                                screen.createExtendSessionForAccount(accounts[0])
                                return
                            }
                            extendAccountPickerDialog.openWith(accounts)
                        }
                        onExtendSessionOpenRequested: sessionKey => screen.applyExtendSessionResult(
                            workPanelController.openExtendSession(sessionKey),
                            "Could not open extend session.",
                            "",
                            true
                        )
                        onExtendSessionDeleteRequested: sessionKey => screen.requestExtendSessionDelete(sessionKey)
                    }
                }
            }
        }

        JobPanelWidget {
            Layout.preferredWidth: screen.rightRailWidth
            Layout.fillHeight: true
            visible: screen.showRightRail
            panelActive: screen.showRightRail
            jobModel: TourState.preview ? null : workPanelController.jobPanelModel
            rows: screen.jobPanelRowsSafe
            stats: screen.queueStatsSafe
            route: screen.route
            autoPageSize: true
            onActionRequested: (actionId, payload) => screen.handleJobPanelAction(actionId, payload)
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: screen.compactJobRail && screen.rightRailExpanded
        z: 20
        color: "#4D0F172A"

        MouseArea {
            anchors.fill: parent
            onClicked: screen.rightRailExpanded = false
        }
    }

    Rectangle {
        id: compactJobDrawer
        visible: screen.compactJobRail
        z: 21
        x: screen.rightRailExpanded ? screen.width - width : screen.width
        y: 0
        width: screen.compactRailWidth
        height: screen.height
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        border.width: 1

        Behavior on x {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            id: drawerHeader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: VfTheme.dp(42)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            Text {
                anchors.left: parent.left
                anchors.leftMargin: VfTheme.dp(12)
                anchors.verticalCenter: parent.verticalCenter
                text: (void i18n.revision, i18n.t("job_panel.drawer_title", "Job Panel"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                font.weight: Font.Bold
            }

            VfButton {
                anchors.right: parent.right
                anchors.rightMargin: VfTheme.dp(8)
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: VfTheme.dp(28)
                text: (void i18n.revision, i18n.t("common.close", "Close"))
                onClicked: screen.rightRailExpanded = false
            }
        }

        Loader {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: drawerHeader.bottom
            anchors.bottom: parent.bottom
            active: screen.compactJobRail
            sourceComponent: JobPanelWidget {
                anchors.fill: parent
                panelActive: screen.rightRailExpanded
                jobModel: TourState.preview ? null : workPanelController.jobPanelModel
                rows: screen.jobPanelRowsSafe
                stats: screen.queueStatsSafe
                route: screen.route
                autoPageSize: true
                onActionRequested: (actionId, payload) => screen.handleJobPanelAction(actionId, payload)
            }
        }
    }

    Rectangle {
        visible: screen.compactJobRail && !screen.rightRailExpanded
        z: 22
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: VfTheme.dp(32)
        height: VfTheme.dp(108)
        radius: VfTheme.dp(8)
        color: VfTheme.primary
        border.color: VfTheme.primaryHover

        Text {
            anchors.centerIn: parent
            rotation: -90
            text: (void i18n.revision, i18n.t("job_panel.open_drawer", "Jobs"))
            color: "#FFFFFF"
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
            font.weight: Font.Bold
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: screen.rightRailExpanded = true
        }
    }

    // Tour hooks: App.qml opens these (via workPanelLoader.item) for the in-dialog
    // Bulk Import / Bulk Extend walkthroughs. Dialog `id`s aren't reachable outside.
    // Tour reveals a conditional section (Voice Sync / Remix box / character panel /
    // scope columns) by activating the workspace's mode. App calls via loader.item.
    function tourActivateSection(action) { if (workPanelContent) workPanelContent.tourActivateSection(action) }

    function openBulkImportForTour() { bulkImportDialog.open() }
    // Force IMAGE mode so the tour can spotlight the image-prompt matching controls
    // regardless of the tab's current mode (openForImageMode, not the plain text open).
    function openBulkImportImageForTour() { bulkImportDialog.openForImageMode("image", { "initial_assets_per_card": 1 }) }
    // Force NAMED-REF mode (auto-match images to prompts by filename) for its tour.
    function openBulkImportNamedRefForTour() { bulkImportDialog.openForNamedRef([], { "card_mode": "image" }) }
    function openBulkExtendForTour() { bulkExtendImportDialog.openForImport(false, 0) }
    // Close via the dialog id (a Popup isn't an Item findable by objectName on
    // Overlay.overlay — App reaches it through these screen functions).
    function closeBulkImportForTour() { if (bulkImportDialog.opened) bulkImportDialog.close() }
    function closeBulkExtendForTour() { if (bulkExtendImportDialog.opened) bulkExtendImportDialog.close() }

    BulkImportDialog {
        id: bulkImportDialog
        scriptMode: false
        spreadsheetImportEnabled: true
        preferItemAccept: true
        maxMultiAssetReferenceImages: screen.route === "batch" ? 10 : screen.normalMultiAssetReferenceLimit()
        onLoadTextRequested: {
            var picked = nativeShell.pickFiles(
                (void i18n.revision, i18n.t("voice_studio.import_txt", "Import TXT")),
                "Text Files (*.txt *.md);;All Files (*.*)",
                ""
            )
            if (picked && picked.ok && picked.paths && picked.paths.length > 0) {
                var loaded = nativeShell.readTextFile(String(picked.paths[0] || ""))
                bulkImportDialog.applyLoadTextResult(loaded)
            }
        }
        onLoadSpreadsheetRequested: {
            var picked = nativeShell.pickFiles(
                (void i18n.revision, i18n.t("bulk_import.import_excel_csv", "Import Excel/CSV")),
                "Excel Files (*.xlsx *.xlsm);;CSV Files (*.csv);;All Files (*.*)",
                ""
            )
            if (picked && picked.ok && picked.paths && picked.paths.length > 0) {
                var path = String(picked.paths[0] || "")
                var cols = nativeShell.readSpreadsheetColumns(path)
                if (cols && cols.ok && cols.columns && cols.columns.length > 0)
                    bulkImportDialog.openColumnPicker(path, cols)
                else
                    bulkImportDialog.applyLoadItemsResult(cols)
            }
        }
        onSpreadsheetColumnChosen: (path, columnIndex, startRow, endRow) =>
            bulkImportDialog.applyLoadItemsResult(nativeShell.readSpreadsheetColumn(path, columnIndex, startRow, endRow))
        onAcceptedText: text => bulkImportDialog.applyAcceptResult(workPanelController.addCardsFromText(text))
        onAcceptedItems: items => {
            var result = null
            if (screen.pendingBulkImportMode === "normal_named_ref_image")
                result = workPanelController.addNormalNamedRefImageCards(items, screen.pendingBulkImportImagePaths)
            else if (screen.pendingBulkImportMode === "normal_named_ref_multi_asset")
                result = workPanelController.addNormalNamedRefMultiAssetCards(
                    items,
                    screen.pendingBulkImportImagePaths,
                    screen.pendingBulkImportAssetsPerCard
                )
            else if (screen.pendingBulkImportMode === "normal_multi_asset_single_set")
                result = workPanelController.addNormalSingleSetMultiAssetCards(
                    items,
                    screen.pendingBulkImportImagePaths,
                    screen.pendingBulkImportAssetsPerCard
                )
            else if (screen.pendingBulkImportMode === "normal_multi_asset_shared_prompt")
                result = workPanelController.addNormalSharedPromptMultiAssetCards(
                    items,
                    screen.pendingBulkImportImagePaths,
                    screen.pendingBulkImportAssetsPerCard
                )
            else if (screen.pendingBulkImportMode === "normal_interpolation_single_pair")
                result = workPanelController.addNormalSinglePairInterpolationCards(
                    items,
                    screen.pendingBulkImportImagePaths
                )
            else if (screen.pendingBulkImportMode === "normal_interpolation_shared_prompt")
                result = workPanelController.addNormalSharedPromptInterpolationCards(
                    items,
                    screen.pendingBulkImportImagePaths
                )
            else if (screen.pendingBulkImportMode === "normal_image_single_image")
                result = workPanelController.addNormalSingleImagePromptCards(
                    items,
                    screen.pendingBulkImportImagePaths
                )
            else if (screen.pendingBulkImportMode === "normal_image_shared_prompt")
                result = workPanelController.addNormalSharedPromptImageCards(
                    items,
                    screen.pendingBulkImportImagePaths
                )
            else
                result = workPanelController.addCardsFromItems(items)
            var accepted = bulkImportDialog.applyAcceptResult(result)
            if (accepted)
                screen.resetPendingBulkImport()
        }
        onAcceptedImageImport: payload => {
            if (screen.route === "batch") {
                var data = payload || ({})
                // Batch import creates prompt cards only. Queue jobs are built
                // later by submitAllCards through the shared backend gateway.
                var result = workPanelController.addCardsFromItems(data.result_items || [])
                var accepted = bulkImportDialog.applyAcceptResult(result)
                if (accepted)
                    screen.resetPendingBulkImport()
                return
            }
            screen.handleNormalImageImportAccepted(payload)
        }
        onImageFilesRequested: screen.handleBulkImportImageFilesRequested()
        onImageFolderRequested: screen.handleBulkImportImageFolderRequested()
        onNormalImageFilesRequested: (importMode, cardMode, assetsPerCard) => {
            screen.handleNormalBulkImageFilesRequested(importMode, cardMode, assetsPerCard)
        }
        onMediaLibraryRequested: screen.openBulkImportMediaLibrary()
        onClosed: screen.resetPendingBulkImport()
    }

    BulkExtendImportDialog {
        id: bulkExtendImportDialog
        onImportItemsRequested: (items, queueMode) => bulkExtendImportDialog.applyCommitResult(workPanelController.importExtendItems(items, queueMode))
        onBatchUpdated: (batchId, items) => {
            if (String(batchId || "") === "extend_bulk_preview")
                bulkExtendImportDialog.applyCommitResult(workPanelController.replaceExtendCards(items))
        }
    }

    ExtendAccountPickerDialog {
        id: extendAccountPickerDialog
        onAccountChosen: account => screen.createExtendSessionForAccount(account)
    }

    ExtendRenderDialog {
        id: extendRenderDialog
        onBrowseSourceRequested: {
            var picked = nativeShell.pickFolder((void i18n.revision, i18n.t("extend_render.source_folder", "Source folder")), extendRenderDialog.sourceFolder)
            if (picked && picked.ok) {
                extendRenderDialog.sourceFolder = String(picked.path || "")
                extendRenderDialog.applySourceListingResult(
                    workPanelController.previewExtendRenderFolder(extendRenderDialog.sourceFolder)
                )
            }
        }
        onBrowseOutputRequested: {
            var picked = nativeShell.pickFolder((void i18n.revision, i18n.t("extend_render.output_folder", "Output folder")), extendRenderDialog.outputFolder || extendRenderDialog.sourceFolder)
            if (picked && picked.ok)
                extendRenderDialog.outputFolder = String(picked.path || "")
        }
        onRenderRequested: payload => extendRenderDialog.applyRenderResult(workPanelController.startExtendRender(payload))
        onTrackingStatusRequested: trackingJobId => extendRenderDialog.applyTrackingStatus(workPanelController.getExtendRenderTrackingStatus(trackingJobId))
        onCancelRequested: trackingJobId => extendRenderDialog.applyCancelResult(workPanelController.cancelExtendRender(trackingJobId))
    }

    BatchConfigDialog {
        id: batchConfigDialog
        initialVariations: Number((workPanelController.currentBatchConfig || {}).variations || 10)
        initialAntiDuplicate: (workPanelController.currentBatchConfig || {}).anti_duplicate === undefined
            ? true
            : Boolean((workPanelController.currentBatchConfig || {}).anti_duplicate)
        onSaveRequested: (variations, antiDuplicate, instructions, characterStrategy, variationStrength, aspectRatio, model) => batchConfigDialog.applySaveResult(workPanelController.setBatchConfig(
            variations,
            antiDuplicate,
            instructions,
            characterStrategy,
            variationStrength,
            aspectRatio,
            model
        ))
    }

    // Per-row Batch on a fetched clone result: configure N variations then mark
    // the card (parity clone_video_tab._on_batch_source_clicked → BatchConfigDialog).
    BatchConfigDialog {
        id: cloneBatchConfigDialog
        property string targetCardId: ""
        // Clone batch kế thừa model/tỷ lệ từ motif gốc → ẩn Model + Tỷ lệ
        // (chúng chỉ dùng cho tab Batch Image).
        showMediaFields: false
        onSaveRequested: (variations, antiDuplicate, instructions, characterStrategy, variationStrength, aspectRatio, model) => {
            workPanelController.markCloneBatchSource(cloneBatchConfigDialog.targetCardId, {
                variations: variations,
                anti_duplicate: antiDuplicate,
                instructions: instructions,
                character_strategy: characterStrategy,
                variation_strength: variationStrength
            })
            cloneBatchConfigDialog.accept()
        }
    }

    CharacterManagerDialog {
        id: characterManagerDialog
        characters: workPanelController.characters
        onReplaceImageRequested: character => screen.openCharacterImagePicker(character)
    }

    BatchActionsDialog {
        id: batchActionsDialog
        jobs: workPanelController.queueRows
        selectedJobs: []
        failedJobs: screen._failedQueueRows
        onApplyRequested: result => batchActionsDialog.applyResult(workPanelController.applyBatchActions(result))
    }

    BatchActionsDialog {
        id: jobPanelBatchActionsDialog
        jobs: workPanelController.jobPanelRows
        selectedJobs: []
        failedJobs: screen._failedJobPanelRows
        onApplyRequested: result => jobPanelBatchActionsDialog.applyResult(workPanelController.applyJobPanelBatchActions(result))
    }

    CloneSceneAnalysisDialog {
        id: cloneSceneAnalysisDialog
        onSaveSceneRequested: (sceneId, title, prompt, notes) => cloneSceneAnalysisDialog.applySaveResult(workPanelController.updateCloneScene(sceneId, title, prompt, notes), sceneId, title, prompt, notes)
        onCopyJsonRequested: rowId => {
            var copyResult = workPanelController.copyCloneQueueRowJson(String(rowId || ""))
            if (copyResult && copyResult.ok === false) {
                cloneSceneAnalysisDialog.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    String(copyResult.message || copyResult.error || copyResult.code || (void i18n.revision, i18n.t("clone.copy_json_failed", "Could not copy clone JSON.")))
                )
            } else {
                cloneSceneAnalysisDialog.showFeedback(
                    (void i18n.revision, i18n.t("common.success", "Success")),
                    String(copyResult.message || (void i18n.revision, i18n.t("clone.copied_json", "Copied JSON to clipboard.")))
                )
            }
        }
    }

    CloneApplyStyleDialog {
        id: cloneApplyStyleDialog
        onApplyRequested: style => cloneApplyStyleDialog.applyResult(workPanelController.applyCloneStyleToAll(style))
    }

    ClonePipelineDialog {
        id: clonePipelineDialog
        onFetchRequested: (inputs, videoType, minViews) => {
            var preview = workPanelController.previewClonePipeline(inputs, videoType, minViews)
            clonePipelineDialog.openFor(preview)
            if (preview && (preview.blocked || preview.ok === false)) {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    String(
                        preview.message
                        || preview.error
                        || (void i18n.revision, i18n.t("clone.fetch_failed", "Could not fetch clone pipeline videos."))
                    )
                )
            }
        }
        onAcceptedVideos: urls => screen.applyQueueResult(
            workPanelController.addClonePipelineUrls(urls),
            (void i18n.revision, i18n.t("clone.pipeline_add_failed", "Could not add pipeline videos.")),
            (void i18n.revision, i18n.t("clone.pipeline_add_success", "Pipeline videos added."))
        )
    }

    CloneUploadedCacheDialog {
        id: cloneUploadedCacheDialog
        onUseRequested: filePath => cloneUploadedCacheDialog.applyUseResult(workPanelController.useCachedCloneUpload(filePath))
    }

    TranscriptInstructionDialog {
        id: transcriptInstructionDialog
        onSaveRequested: (cardId, instruction) => transcriptInstructionDialog.applySaveResult(workPanelController.updateTranscriptInstruction(cardId, instruction))
    }

    ExtendRulesDialog {
        id: extendRulesDialog
        onSaveRequested: text => extendRulesDialog.applySaveResult(workPanelController.saveExtendRules(text))
    }

    ExtendTimelinePreviewDialog {
        id: extendTimelinePreviewDialog
        onOpenFolderRequested: folder => nativeShell.openPath(folder)
        onOpenClipRequested: path => nativeShell.openPath(path)
        onPlayClipRequested: path => nativeShell.openPath(path)
    }

    Dialog {
        id: extendSessionDeleteDialog
        modal: true
        title: ""
        parent: Overlay.overlay
        anchors.centerIn: parent
        standardButtons: Dialog.NoButton
        width: VfDialogMetrics.width(screen, 520, 48)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property var sessionInfo: screen.pendingExtendDeleteSession || ({})
        property var stats: (sessionInfo.stats || ({}))

        function sessionKey() {
            return String(sessionInfo.session_key || sessionInfo.id || "")
        }

        function sessionTitle() {
            var title = String(sessionInfo.title || sessionInfo.name || "")
            return title.length > 0 ? title : sessionKey()
        }

        function queueSummary() {
            var total = Number(stats.total || 0)
            var pending = Number(stats.pending || stats.queued || 0)
            var generating = Number(stats.generating || 0)
            var failed = Number(stats.failed || 0)
            return "Queue: " + total + " | Pending: " + pending + " | Generating: " + generating + " | Failed: " + failed
        }

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("extend.delete_session", "Delete Session"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: VfTheme.weightTitle
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("qml.work.extend_delete_confirm", "Delete this extend session and its saved local session state?"))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
                wrapMode: Text.WordWrap
            }

            Rectangle {
                Layout.fillWidth: true
                radius: VfTheme.dp(10)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(12)
                    spacing: VfTheme.dp(6)

                    Text {
                        Layout.fillWidth: true
                        text: extendSessionDeleteDialog.sessionTitle()
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        font.weight: VfTheme.weightStrong
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        Layout.fillWidth: true
                        text: extendSessionDeleteDialog.queueSummary()
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        wrapMode: Text.WordWrap
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: extendSessionDeleteDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                    tone: "danger"
                    minWidth: VfTheme.dp(110)
                    onClicked: {
                        var key = extendSessionDeleteDialog.sessionKey()
                        extendSessionDeleteDialog.close()
                        screen.applyExtendSessionResult(
                            workPanelController.deleteExtendSession(key),
                            "Could not delete extend session.",
                            "",
                            true
                        )
                    }
                }
            }
        }
    }

    Dialog {
        id: queueFeedbackDialog
        modal: true
        title: ""
        standardButtons: Dialog.NoButton
        // parent + center vào Overlay nếu không Dialog rơi về (0,0) góc trên-trái.
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(screen, 420, 48)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: screen.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: VfTheme.weightTitle
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: screen.feedbackMessage
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    minWidth: VfTheme.dp(96)
                    tone: "primary"
                    onClicked: queueFeedbackDialog.close()
                }
            }
        }
    }

    Dialog {
        id: cloneClearQueueConfirmDialog
        modal: true
        header: null
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(460), VfTheme.dp(48))
        padding: VfTheme.dp(20)
        title: (void i18n.revision, i18n.t("common.confirm", "Confirm"))

        background: Rectangle {
            radius: VfTheme.radiusPanel
            color: VfTheme.panel
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: VfTheme.dp(56)
                radius: VfTheme.radiusPanel
                color: VfTheme.redFill
                border.color: VfTheme.redBorderSoft

                Text {
                    anchors.centerIn: parent
                    text: (void i18n.revision, i18n.t("clone.clear_button", "Clear"))
                    color: VfTheme.redText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(20)
                    font.weight: Font.Bold
                }
            }

            Text {
                Layout.fillWidth: true
                text: screen.cloneClearQueueConfirmText()
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: cloneClearQueueConfirmDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                    tone: "danger"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        cloneClearQueueConfirmDialog.close()
                        screen.applyQueueResult(
                            workPanelController.clearQueue(),
                            (void i18n.revision, i18n.t("qml.work.clear_queue_failed", "Could not clear the queue.")),
                            (void i18n.revision, i18n.t("qml.work.queue_cleared", "Queue cleared."))
                        )
                    }
                }
            }
        }

        onClosed: screen.cloneClearQueuePreview = ({})
    }

    Dialog {
        id: cloneDeleteRowConfirmDialog
        modal: true
        header: VfDialogHeader {
            title: cloneDeleteRowConfirmDialog.title
            compact: true
            onCloseClicked: cloneDeleteRowConfirmDialog.close()
        }
        title: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(screen, 520, 48)
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.radiusPanel
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: screen.cloneDeleteRowConfirmText()
                wrapMode: Text.WordWrap
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: cloneDeleteRowConfirmDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                    tone: "danger"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        var rowId = String((screen.cloneDeleteRowContext || ({})).row_id || "")
                        cloneDeleteRowConfirmDialog.close()
                        screen.applyQueueResult(
                            workPanelController.removeRow(rowId),
                            (void i18n.revision, i18n.t("common.delete_failed", "Delete failed")),
                            (void i18n.revision, i18n.t("messages.deleted_job", "Deleted job."))
                        )
                    }
                }
            }
        }

        onClosed: screen.cloneDeleteRowContext = ({})
    }

    Dialog {
        id: cloneRetryRowConfirmDialog
        modal: true
        header: VfDialogHeader {
            title: cloneRetryRowConfirmDialog.title
            compact: true
            onCloseClicked: cloneRetryRowConfirmDialog.close()
        }
        title: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(screen, 520, 48)
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.radiusPanel
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: screen.cloneRetryRowConfirmText()
                wrapMode: Text.WordWrap
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: cloneRetryRowConfirmDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("job_panel.retry_btn", "Retry"))
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        var rowId = String((screen.cloneRetryRowContext || ({})).row_id || "")
                        cloneRetryRowConfirmDialog.close()
                        screen.applyQueueResult(
                            workPanelController.retryRow(rowId),
                            (void i18n.revision, i18n.t("job_panel.retry_failed", "Retry failed")),
                            (void i18n.revision, i18n.t("job_panel.retry_btn", "Retry"))
                        )
                    }
                }
            }
        }

        onClosed: screen.cloneRetryRowContext = ({})
    }

    PromptEditDialog {
        id: promptEditDialog
        onAssetReplaceRequested: (jobId, slotIndex) => screen.openJobAssetReplacePicker(
            { id: jobId, job_id: jobId, row_id: jobId },
            slotIndex
        )
        onRejected: {
            screen.clonePromptEditContext = ({})
            screen.pendingClonePromptRegen = false
            screen.transcriptPromptEditContext = ({})
            screen.pendingTranscriptPromptRegen = false
            screen.jobPromptEditContext = ({})
        }
        onSaveRequested: (cardId, title, prompt) => {
            if (screen.route === "clone" && screen.clonePromptEditContext.jobId) {
                var cloneResult = workPanelController.updateCloneJobPrompt(
                    String(screen.clonePromptEditContext.jobId || cardId || ""),
                    prompt
                )
                promptEditDialog.applySaveResult(cloneResult, prompt)
                if (cloneResult && cloneResult.ok && cloneResult.prompt_changed) {
                    screen.pendingClonePromptRegen = true
                    clonePromptRegenDialog.open()
                } else {
                    screen.pendingClonePromptRegen = false
                    screen.clonePromptEditContext = ({})
                }
                return
            }
            if (screen.route === "transcript" && screen.transcriptPromptEditContext.jobId) {
                var result = workPanelController.updateTranscriptJobPrompt(
                    String(screen.transcriptPromptEditContext.jobId || cardId || ""),
                    prompt
                )
                promptEditDialog.applySaveResult(result, prompt)
                if (result && result.ok && result.prompt_changed) {
                    screen.pendingTranscriptPromptRegen = true
                    transcriptPromptRegenDialog.open()
                } else {
                    screen.pendingTranscriptPromptRegen = false
                    screen.transcriptPromptEditContext = ({})
                }
                return
            }
            if (screen.jobPromptEditContext.jobId) {
                var jobResult = workPanelController.updateJobPanelPrompt(
                    String(screen.jobPromptEditContext.jobId || cardId || ""),
                    prompt
                )
                promptEditDialog.applySaveResult(jobResult, prompt)
                if (jobResult && jobResult.ok && jobResult.prompt_changed) {
                    screen.jobSceneRegenContext = {
                        reason: "prompt_edit",
                        jobId: String(jobResult.job_id || screen.jobPromptEditContext.jobId || ""),
                        row: screen.jobPromptEditContext.row || ({})
                    }
                    jobSceneRegenDialog.open()
                } else {
                    screen.jobPromptEditContext = ({})
                }
                return
            }
            promptEditDialog.applySaveResult(workPanelController.updateCardOrRow(cardId, title, prompt), prompt)
        }
    }

    Dialog {
        id: jobSceneRegenDialog
        modal: true
        header: VfDialogHeader {
            title: jobSceneRegenDialog.title
            compact: true
            onCloseClicked: jobSceneRegenDialog.close()
        }
        title: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(screen, 440, 48)
        standardButtons: Dialog.NoButton
        onClosed: {
            screen.jobPromptEditContext = ({})
            screen.jobSceneRegenContext = ({})
        }

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: {
                    var context = screen.jobSceneRegenContext || ({})
                    if (String(context.reason || "") === "prompt_edit")
                        return (void i18n.revision, i18n.t(
                            "job_panel.prompt_updated_regen",
                            "Scene prompt updated. Regenerate this scene now?"
                        ))
                    var prompt = screen.scenePromptPreview(context.row || ({}))
                    return (void i18n.revision, i18n.t(
                        "dialog.confirm_regenerate_job",
                        "Regenerate this job now?\n\nPrompt: {prompt}"
                    )).replace(
                        "{prompt}",
                        prompt.length > 0
                            ? prompt
                            : (void i18n.revision, i18n.t("master.not_available_yet", "Not available yet"))
                    )
                }
                wrapMode: Text.WordWrap
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.no", "No"))
                    minWidth: VfTheme.dp(96)
                    onClicked: jobSceneRegenDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.yes", "Yes"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        var jobId = String(screen.jobSceneRegenContext.jobId || "")
                        var result = workPanelController.regenerateJobPanelJob(jobId)
                        if (!(result && result.ok)) {
                            screen.showFeedback(
                                (void i18n.revision, i18n.t("common.warning", "Warning")),
                                String((result && (
                                    result.message
                                    || result.error
                                    || result.code
                                )) || (void i18n.revision, i18n.t("job.cannot_regen", "Could not regenerate this job.")))
                            )
                        }
                        jobSceneRegenDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: clonePromptRegenDialog
        modal: true
        header: VfDialogHeader {
            title: clonePromptRegenDialog.title
            compact: true
            onCloseClicked: clonePromptRegenDialog.close()
        }
        title: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(screen, 440, 48)
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t(
                    "clone.prompt_updated_regen",
                    "Clone scene prompt updated. Regenerate this scene now?"
                ))
                wrapMode: Text.WordWrap
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.no", "No"))
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        screen.pendingClonePromptRegen = false
                        screen.clonePromptEditContext = ({})
                        clonePromptRegenDialog.close()
                    }
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.yes", "Yes"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        var cloneRegen = workPanelController.regenCloneJob(
                            String(screen.clonePromptEditContext.jobId || "")
                        )
                        if (!(cloneRegen && cloneRegen.ok)) {
                            screen.showFeedback(
                                (void i18n.revision, i18n.t("common.warning", "Warning")),
                                String(
                                    (cloneRegen && (
                                        cloneRegen.message
                                        || cloneRegen.error
                                        || cloneRegen.code
                                    )) || (void i18n.revision, i18n.t("clone.regen_error", "Could not regenerate clone scene."))
                                )
                            )
                        }
                        screen.pendingClonePromptRegen = false
                        screen.clonePromptEditContext = ({})
                        clonePromptRegenDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: cloneSceneRegenDialog
        modal: true
        header: VfDialogHeader {
            title: cloneSceneRegenDialog.title
            compact: true
            onCloseClicked: cloneSceneRegenDialog.close()
        }
        title: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(screen, 440, 48)
        standardButtons: Dialog.NoButton
        onClosed: screen.cloneSceneRegenContext = ({})

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: {
                    var row = screen.cloneSceneRegenContext.row || ({})
                    var sceneLabel = String(row.scene_index || row.scene_id || row.title || "")
                    var prompt = screen.scenePromptPreview(row)
                    var base = (void i18n.revision, i18n.t(
                        "dialog.confirm_regenerate_scene",
                        "Regenerate this scene now?\n\nScene: {scene}\nPrompt: {prompt}"
                    ))
                    return base
                        .replace("{scene}", sceneLabel.length > 0 ? sceneLabel : "scene")
                        .replace("{prompt}", prompt.length > 0 ? prompt : (void i18n.revision, i18n.t("master.not_available_yet", "Not available yet")))
                }
                wrapMode: Text.WordWrap
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.no", "No"))
                    minWidth: VfTheme.dp(96)
                    onClicked: cloneSceneRegenDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.yes", "Yes"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        var cloneRegen = workPanelController.regenCloneJob(
                            String(screen.cloneSceneRegenContext.jobId || "")
                        )
                        if (!(cloneRegen && cloneRegen.ok)) {
                            screen.showFeedback(
                                (void i18n.revision, i18n.t("common.warning", "Warning")),
                                String((cloneRegen && (
                                    cloneRegen.message
                                    || cloneRegen.error
                                    || cloneRegen.code
                                )) || (void i18n.revision, i18n.t("job.cannot_regen", "Could not regenerate this job.")))
                            )
                        }
                        cloneSceneRegenDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: cloneSceneDeleteDialog
        modal: true
        header: VfDialogHeader {
            title: cloneSceneDeleteDialog.title
            compact: true
            onCloseClicked: cloneSceneDeleteDialog.close()
        }
        title: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(screen, 440, 48)
        standardButtons: Dialog.NoButton
        onClosed: screen.cloneSceneDeleteContext = ({})

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: {
                    var row = screen.cloneSceneDeleteContext.row || ({})
                    var prompt = screen.scenePromptPreview(row)
                    return (void i18n.revision, i18n.t(
                        "dialog.confirm_delete_job",
                        "Delete this generated scene job?\n\nPrompt: {prompt}"
                    )).replace("{prompt}", prompt.length > 0 ? prompt : (void i18n.revision, i18n.t("master.not_available_yet", "Not available yet")))
                }
                wrapMode: Text.WordWrap
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.no", "No"))
                    minWidth: VfTheme.dp(96)
                    onClicked: cloneSceneDeleteDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.yes", "Yes"))
                    tone: "danger"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        screen.applyQueueResult(
                            workPanelController.deleteCloneJob(String(screen.cloneSceneDeleteContext.jobId || "")),
                            (void i18n.revision, i18n.t("common.delete_failed", "Delete failed")),
                            (void i18n.revision, i18n.t("messages.deleted_job", "Deleted job."))
                        )
                        cloneSceneDeleteDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: transcriptPromptRegenDialog
        modal: true
        header: VfDialogHeader {
            title: transcriptPromptRegenDialog.title
            compact: true
            onCloseClicked: transcriptPromptRegenDialog.close()
        }
        title: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(screen, 440, 48)
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t(
                    "transcript.prompt_updated_regen",
                    "Transcript scene prompt updated. Regenerate this scene now?"
                ))
                wrapMode: Text.WordWrap
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.no", "No"))
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        screen.pendingTranscriptPromptRegen = false
                        screen.transcriptPromptEditContext = ({})
                        transcriptPromptRegenDialog.close()
                    }
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.yes", "Yes"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        var result = workPanelController.regenTranscriptJob(
                            String(screen.transcriptPromptEditContext.jobId || "")
                        )
                        if (!(result && result.ok)) {
                            screen.showFeedback(
                                (void i18n.revision, i18n.t("common.warning", "Warning")),
                                String(
                                    (result && (
                                        result.message
                                        || result.error
                                        || result.code
                                    )) || (void i18n.revision, i18n.t("transcript.regen_error", "Could not regenerate transcript scene."))
                                )
                            )
                        }
                        screen.pendingTranscriptPromptRegen = false
                        screen.transcriptPromptEditContext = ({})
                        transcriptPromptRegenDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: transcriptSceneRegenDialog
        modal: true
        header: VfDialogHeader {
            title: transcriptSceneRegenDialog.title
            compact: true
            onCloseClicked: transcriptSceneRegenDialog.close()
        }
        title: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(screen, 440, 48)
        standardButtons: Dialog.NoButton
        onClosed: screen.transcriptSceneRegenContext = ({})

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: {
                    var row = screen.transcriptSceneRegenContext.row || ({})
                    var segmentId = String(row.segment_id || row.scene_id || row.title || "")
                    var prompt = screen.scenePromptPreview(row)
                    var base = (void i18n.revision, i18n.t(
                        "transcript.confirm_regen",
                        "Regenerate transcript scene {id} now?\n\nPrompt: {prompt}"
                    ))
                    return base
                        .replace("{id}", segmentId.length > 0 ? segmentId : "scene")
                        .replace("{prompt}", prompt.length > 0 ? prompt : (void i18n.revision, i18n.t("master.not_available_yet", "Not available yet")))
                }
                wrapMode: Text.WordWrap
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.no", "No"))
                    minWidth: VfTheme.dp(96)
                    onClicked: transcriptSceneRegenDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.yes", "Yes"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        var transcriptRegen = workPanelController.regenTranscriptJob(
                            String(screen.transcriptSceneRegenContext.jobId || "")
                        )
                        if (!(transcriptRegen && transcriptRegen.ok)) {
                            screen.showFeedback(
                                (void i18n.revision, i18n.t("common.warning", "Warning")),
                                String((transcriptRegen && (
                                    transcriptRegen.message
                                    || transcriptRegen.error
                                    || transcriptRegen.code
                                )) || (void i18n.revision, i18n.t("job.cannot_regen", "Could not regenerate this job.")))
                            )
                        }
                        transcriptSceneRegenDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: transcriptSceneDeleteDialog
        modal: true
        header: VfDialogHeader {
            title: transcriptSceneDeleteDialog.title
            compact: true
            onCloseClicked: transcriptSceneDeleteDialog.close()
        }
        title: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(screen, 440, 48)
        standardButtons: Dialog.NoButton
        onClosed: screen.transcriptSceneDeleteContext = ({})

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: {
                    var row = screen.transcriptSceneDeleteContext.row || ({})
                    var prompt = screen.scenePromptPreview(row)
                    return (void i18n.revision, i18n.t(
                        "transcript.confirm_delete_job_full",
                        "Delete this transcript scene job?\n\nPrompt: {prompt}"
                    )).replace("{prompt}", prompt.length > 0 ? prompt : (void i18n.revision, i18n.t("master.not_available_yet", "Not available yet")))
                }
                wrapMode: Text.WordWrap
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.no", "No"))
                    minWidth: VfTheme.dp(96)
                    onClicked: transcriptSceneDeleteDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.yes", "Yes"))
                    tone: "danger"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        screen.applyQueueResult(
                            workPanelController.deleteTranscriptJob(String(screen.transcriptSceneDeleteContext.jobId || "")),
                            (void i18n.revision, i18n.t("common.delete_failed", "Delete failed")),
                            (void i18n.revision, i18n.t("messages.deleted_job", "Deleted job."))
                        )
                        transcriptSceneDeleteDialog.close()
                    }
                }
            }
        }
    }

    MultiAssetPromptEditDialog {
        id: multiAssetPromptEditDialog
        onSaveRequested: (cardId, text, advancedMode) => multiAssetPromptEditDialog.applySaveResult(workPanelController.updateMultiAssetCardOrRow(cardId, text, advancedMode))
    }

    Connections {
        target: workPanelController
        ignoreUnknownSignals: true
        function onAffiliateQueueActionFinished(result) {
            if (screen.route !== "affiliate")
                return
            var payload = result || ({})
            if (!payload.ok) {
                if (!payload.alerted)
                    screen.showFeedback(
                        (void i18n.revision, i18n.t("common.warning", "Warning")),
                        String(payload.message || payload.error || (void i18n.revision,
                            i18n.t("affiliate.production_action_failed", "Không thể chạy tác vụ Affiliate.")))
                    )
                return
            }
            var warning = String(payload.warn_message || "")
            if (warning.length > 0)
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    warning
                )
        }
    }

    QueuePreflightDialog {
        id: queuePreflightDialog
        route: workPanelController.route
        onConfirmed: {
            if (screen._pendingQueueAction)
                screen._pendingQueueAction()
            screen._pendingQueueAction = null
        }
    }

    MediaLibraryDialog {
        id: mediaLibraryDialog
        items: visible ? workPanelController.mediaLibraryItems : []
        stats: workPanelController.mediaLibraryStats
        settings: workPanelController.mediaLibrarySettings
        onClosed: screen.resetMediaSelectionTarget()
        onRefreshRequested: (search, assetType) => workPanelController.refreshMediaLibrary(search, assetType)
        onMediaSelected: selection => {
            var mediaId = ""
            if (typeof selection === "string") {
                mediaId = selection
            } else if (selection) {
                mediaId = String(selection.mediaId || selection.media_id || "")
            }
            if (screen.mediaTargetMode === "bulk_import_named_ref") {
                bulkImportDialog.addNamedRefMediaSelections(selection)
                if ((bulkImportDialog.namedRefImagePaths || []).length > 0) {
                    mediaLibraryDialog.applySelectionResult({
                        ok: true,
                        message: (void i18n.revision, i18n.t("bulk_import.media_added", "Media added to bulk import."))
                    })
                }
                return
            }
            if (screen.mediaTargetMode === "bulk_import_image") {
                bulkImportDialog.addImageMediaSelections(selection)
                mediaLibraryDialog.applySelectionResult({
                    ok: true,
                    message: (void i18n.revision, i18n.t("bulk_import.media_added", "Media added to bulk import."))
                })
                return
            }
            if (screen.mediaTargetMode !== "batch_reference" && mediaId.length === 0)
                return
            if (screen.mediaTargetMode === "job_asset_replace") {
                var jobId = screen.pendingJobAssetRowId
                if (mediaId.length > 0 && jobId.length > 0)
                    mediaLibraryDialog.applySelectionResult(
                        workPanelController.replaceRowAsset(jobId, screen.pendingJobAssetSlot, mediaId)
                    )
                screen.pendingJobAssetRowId = ""
                screen.pendingJobAssetSlot = -1
                screen.refreshPromptEditorAssets(jobId)
                return
            }
            if (screen.mediaTargetMode === "character_replace") {
                var replaceResult = (selection && typeof selection === "object")
                    ? workPanelController.replaceRouteCharacterImageSelection(screen.mediaTargetCharacterId, selection)
                    : workPanelController.replaceRouteCharacterImage(screen.mediaTargetCharacterId, mediaId)
                if (mediaLibraryDialog.applySelectionResult(replaceResult))
                    characterManagerDialog.applyReplaceImageResult(replaceResult)
            } else if (screen.mediaTargetMode === "extend_root_asset") {
                mediaLibraryDialog.applySelectionResult(
                    workPanelController.addExtendRootAssetSelection(
                        screen.mediaTargetExtendRootSlot,
                        selection || ({ mediaId: mediaId })
                    )
                )
            } else if (screen.mediaTargetMode === "batch_reference") {
                mediaLibraryDialog.applySelectionResult(
                    screen.mediaTargetCardId.length > 0
                        ? workPanelController.attachBatchMediaReferencesToTarget(screen.mediaTargetCardId, selection || ({ mediaId: mediaId }))
                        : workPanelController.addBatchMediaReferences(selection || ({ mediaId: mediaId }))
                )
            } else if (screen.mediaTargetMode === "product_image") {
                mediaLibraryDialog.applySelectionResult(
                    screen.mediaTargetProductImageMode === "extra"
                        ? workPanelController.attachProductExtraImageSelection(screen.mediaTargetProductId, selection || ({ mediaId: mediaId }))
                        : workPanelController.attachProductMainImageSelection(screen.mediaTargetProductId, selection || ({ mediaId: mediaId }))
                )
            } else if (screen.mediaTargetMode === "affiliate_route_asset") {
                var affSel = selection || ({ media_id: mediaId })
                affSel.column_id = screen.mediaTargetColumnId   // column-targeted (empty = shared default)
                mediaLibraryDialog.applySelectionResult(
                    workPanelController.addAffiliateRouteAssetSelection(screen.mediaTargetAffiliateAssetType, affSel)
                )
            } else if (screen.mediaTargetMode === "affiliate_start_image") {
                mediaLibraryDialog.applySelectionResult(
                    workPanelController.addAffiliateStartImageSelection(
                        screen.mediaTargetAffiliateStartSlot,
                        selection || ({ mediaId: mediaId })
                    )
                )
            } else {
                if (selection && typeof selection === "object") {
                    var cardSel = selection
                    cardSel.slot_index = screen.mediaTargetSlotIndex
                    mediaLibraryDialog.applySelectionResult(
                        workPanelController.attachMediaSelection(screen.mediaTargetCardId, cardSel)
                    )
                } else {
                    mediaLibraryDialog.applySelectionResult(
                        workPanelController.attachMediaSelection(
                            screen.mediaTargetCardId,
                            { mediaId: mediaId, slot_index: screen.mediaTargetSlotIndex }
                        )
                    )
                }
            }
        }
        onImportRequested: (rawPaths, tags, assetType) => mediaLibraryDialog.applyImportResult(workPanelController.importMediaPaths(rawPaths, tags, assetType))
    }

    ProductLibraryDialog {
        id: productLibraryDialog
        products: workPanelController.productLibraryItems
        onRefreshRequested: (search, category) => workPanelController.refreshProductLibrary(search, category)
        onProductSelected: product => productLibraryDialog.applySelectionResult(workPanelController.addAffiliateProductCard(product))
        onProductsSelected: products => productLibraryDialog.applySelectionResult(workPanelController.addAffiliateProductCards(products))
        onAddRequested: productLibraryDialog.applyAddResult(workPanelController.addBlankProduct())
        onImportRequested: {
            var pickedCsv = nativeShell.pickFiles(
                (void i18n.revision, i18n.t("product_library.import_csv_title", "Select product CSV")),
                "CSV Files (*.csv);;All Files (*.*)",
                ""
            )
            if (pickedCsv && pickedCsv.ok && pickedCsv.paths && pickedCsv.paths.length > 0) {
                var csvPath = String(pickedCsv.paths[0] || "")
                var preview = workPanelController.previewProductCsv(csvPath)
                if (preview && preview.ok) {
                    csvImportDialog.filePath = csvPath
                    csvImportDialog.previewRows = preview.rows || []
                    csvImportDialog.open()
                } else {
                    screen.showFeedback(
                        (void i18n.revision, i18n.t("product_library.csv_preview_failed", "Could not preview product CSV.")),
                        String(
                            (preview && (
                                preview.message
                                || preview.error
                                || (preview.blocker && preview.blocker.message)
                            ))
                            || (void i18n.revision, i18n.t("product_library.csv_preview_failed", "Could not preview product CSV."))
                        )
                    )
                }
            }
        }
        onSaveRequested: product => productLibraryDialog.applySaveResult(workPanelController.saveProduct(product), product)
        onChooseMainImageRequested: productId => screen.openProductImagePicker(productId, "main", 0)
        onChooseExtraImagesRequested: productId => screen.openProductImagePicker(
            productId,
            "extra",
            (productLibraryDialog.formExtraImageIds || []).length
        )
        onDeleteRequested: productId => productLibraryDialog.applyDeleteResult(workPanelController.deleteProduct(productId))
    }

    AffiliateImportDialog {
        id: affiliateImportDialog
        onImportRequested: items => workPanelController.importAffiliateProductsAsync(items)
    }

    // SP từ overlay lướt Shopee/TikTok (bố 22/7): dialog Import đang mở → đổ vào
    // BẢNG duyệt (dialog GIỮ MỞ khi bấm 🛍); dialog đã đóng → thẳng cổng import.
    Connections {
        target: workPanelController
        function onAffiliateOverlayProductReady(row) {
            if (affiliateImportDialog.opened)
                affiliateImportDialog.appendOverlayRow(row)
            else
                workPanelController.importAffiliateProductsAsync([row])
        }
        // NHIỀU hàng (TikTok showcase): dialog mở → đổ hết vào bảng duyệt; đóng →
        // import thẳng MỘT lần cho cả lô.
        function onAffiliateImportRowsReady(rows) {
            var list = rows || []
            if (list.length === 0)
                return
            if (affiliateImportDialog.opened) {
                for (var i = 0; i < list.length; i++)
                    affiliateImportDialog.appendOverlayRow(list[i])
            } else {
                workPanelController.importAffiliateProductsAsync(list)
            }
        }
    }

    CsvImportDialog {
        id: csvImportDialog
        onChooseFileRequested: {
            var pickedCsv = nativeShell.pickFiles(
                (void i18n.revision, i18n.t("product_library.import_csv_title", "Select product CSV")),
                "CSV Files (*.csv);;All Files (*.*)",
                csvImportDialog.filePath
            )
            if (pickedCsv && pickedCsv.ok && pickedCsv.paths && pickedCsv.paths.length > 0) {
                var csvPath = String(pickedCsv.paths[0] || "")
                var preview = workPanelController.previewProductCsv(csvPath)
                if (preview && preview.ok) {
                    csvImportDialog.filePath = csvPath
                    csvImportDialog.previewRows = preview.rows || []
                } else {
                    screen.showFeedback(
                        (void i18n.revision, i18n.t("product_library.csv_preview_failed", "Could not preview product CSV.")),
                        String(
                            (preview && (
                                preview.message
                                || preview.error
                                || (preview.blocker && preview.blocker.message)
                            ))
                            || (void i18n.revision, i18n.t("product_library.csv_preview_failed", "Could not preview product CSV."))
                        )
                    )
                }
            }
        }
        onDownloadTemplateRequested: {
            var template = workPanelController.downloadProductCsvTemplate()
            if (template && template.ok) {
                nativeShell.saveTextFile(
                    (void i18n.revision, i18n.t("product_library.download_template", "Download CSV template")),
                    String(template.filename || "san_pham_mau.csv"),
                    "CSV Files (*.csv);;All Files (*.*)",
                    String(template.content || "")
                )
            } else {
                screen.showFeedback(
                    (void i18n.revision, i18n.t("product_library.csv_template_failed", "Could not download product CSV template.")),
                    String(
                        (template && (
                            template.message
                            || template.error
                            || (template.blocker && template.blocker.message)
                        ))
                        || (void i18n.revision, i18n.t("product_library.csv_template_failed", "Could not download product CSV template."))
                    )
                )
            }
        }
        onImportRequested: rows => csvImportDialog.applyImportResult(workPanelController.importProductCsvRows(rows))
    }

    CharacterDialog {
        id: affiliateCharacterDialog
        slots: ((workPanelController.currentRouteConfig || {}).character_slots || [])
        onChooseRequested: screen.openAffiliateAssetPicker("character")
        onCreateAiRequested: affiliateCharGenDialog.open()
        onRemoveRequested: assetId => affiliateCharacterDialog.applyRemoveResult(workPanelController.removeAffiliateRouteAsset("character", assetId))
    }

    BackgroundDialog {
        id: affiliateBackgroundDialog
        slots: ((workPanelController.currentRouteConfig || {}).background_slots || [])
        onChooseRequested: screen.openAffiliateAssetPicker("background")
        onCreateAiRequested: affiliateBgGenDialog.open()
        onRemoveRequested: assetId => affiliateBackgroundDialog.applyRemoveResult(workPanelController.removeAffiliateRouteAsset("background", assetId))
    }

    AffiliateCharGenDialog {
        id: affiliateCharGenDialog
        onGenerateRequested: payload => affiliateCharGenDialog.applyGenerationResult(workPanelController.generateAffiliateAssetContract(payload))
        onSelectRequested: payload => affiliateCharGenDialog.applySelectionResult(workPanelController.selectAffiliateAssetContract(payload))
        onSaveRequested: payload => screen.saveAffiliateGeneratedAsset("character", payload, affiliateCharGenDialog)
    }

    AffiliateBgGenDialog {
        id: affiliateBgGenDialog
        onGenerateRequested: payload => affiliateBgGenDialog.applyGenerationResult(workPanelController.generateAffiliateAssetContract(payload))
        onSelectRequested: payload => affiliateBgGenDialog.applySelectionResult(workPanelController.selectAffiliateAssetContract(payload))
        onSaveRequested: payload => screen.saveAffiliateGeneratedAsset("background", payload, affiliateBgGenDialog)
    }

    Component.onCompleted: {
        screen.refreshWorkspaceRouteConfig()
        screen.scheduleRouteSync()
    }
}
