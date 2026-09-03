import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../dialogs"
import "../theme"
import "../components/TourPreviewData.js" as TourPreviewData
import "../components/JobClock.js" as JobClock
import "../components/SubtitleContentIntent.js" as SubtitleIntent

Item {
    id: screen
    objectName: "masterPromptScreen"

    property bool showRightRail: width >= 1280
    property bool compactJobRail: !showRightRail
    property bool rightRailExpanded: false
    // Dùng CHUNG VfTheme.jobRailWidth với WorkPanel/VoiceStudio → job panel đồng nhất mọi tab.
    property int rightRailWidth: showRightRail ? VfTheme.jobRailWidth : 0
    property int compactRailWidth: VfTheme.jobRailWidthCompact(width)
    property int inputAreaHeight: Math.max(300, Math.min(440, Math.round(height * 0.36)))
    property int queueAreaHeight: Math.max(145, Math.min(205, Math.round(height * 0.16)))
    property string reviewRowId: ""
    property var masterConfig: masterOptionsController.config || ({})
    property var queueTechniqueOptions: screen.queueStyleOptions("camera")
    property var queueMaterialOptions: screen.queueStyleOptions("style")
    property var queueDurationOptions: (masterOptionsController.options || {}).durations || []
    property var queueLanguageOptions: (masterOptionsController.options || {}).voice_languages || []
    property var queueAspectOptions: (masterOptionsController.options || {}).aspects || []
    property string inputMode: String(masterConfig.input_mode || "idea")
    property bool extraRequirementsEnabled: Boolean(masterConfig.extra_requirements)
    property bool saveAiCharacters: Boolean(masterConfig.save_ai_characters)
    property bool ideaMode: inputMode === "idea"
    property bool scriptMode: inputMode === "script"
    property var lastQueueAction: masterController ? (masterController.lastAction || ({})) : ({})
    // Tour preview: while a guided tour runs, swap controller data for baked
    // sample rows so the queue/jobs look alive (empty first-run demo otherwise).
    property var queueRowsSafe: TourState.preview
        ? TourPreviewData.masterQueue()
        : (masterController ? (masterController.queueRows || []) : [])
    property var jobPanelRowsSafe: TourState.preview
        ? TourPreviewData.masterJobs()
        : (masterController ? (masterController.jobPanelRows || []) : [])
    readonly property var _failedJobPanelRows: screen.jobPanelRowsSafe.filter(function(r) { var s = String(r.status || r.state || "").toLowerCase(); return s === "failed" || s === "error" })
    property var queueStatsSafe: TourState.preview
        ? TourPreviewData.masterStats()
        : (masterController ? (masterController.stats || ({})) : ({}))
    property var pendingDeleteRow: ({})
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property var promptEditContext: ({ mode: "row" })
    property var pendingSceneRegen: ({})
    property var pendingSceneDelete: ({})
    property bool masterQueueLifecycleArmed: false
    property bool masterQueueLifecycleWasActive: false
    // Date.now() is epoch-ms (~1.7e12); QML `int` is int32 and clamps → clock stuck at 0s.
    property double elapsedClockMs: Date.now()
    property double clockStartMs: 0

    function openStyleManager() {
        if (masterConfigPanel && masterConfigPanel.openStyleManagerExternal)
            masterConfigPanel.openStyleManagerExternal()
    }

    function closeStyleManagerForTour() {
        if (masterConfigPanel && masterConfigPanel.closeStyleManagerExternal)
            masterConfigPanel.closeStyleManagerExternal()
    }

    function tourActivateSection(action) {
        if (String(action || "") === "consistency:open"
                && featureToolbar && featureToolbar.openConsistencyForTour)
            featureToolbar.openConsistencyForTour()
    }

    function rowId(row) {
        if (!row)
            return ""
        return String(row.id || row.row_id || row.batch_id || "")
    }


    function resolveJobPanelRow(jobId) {
        var target = String(jobId || "")
        if (target.length <= 0)
            return ({})
        if (masterController && masterController.jobPanelRow) {
            var resolved = masterController.jobPanelRow(jobId)
            if (resolved && Object.keys(resolved).length > 0)
                return resolved
        }
        return { id: target, row_id: target, job_id: target }
    }

    function handleJobPanelAction(actionId, payload) {
        var data = payload || ({})
        var jobId = String(data.job_id || data.row_id || "")
        var row = data.row || screen.resolveJobPanelRow(jobId)
        if (actionId === "job_panel.view") {
            masterController.openJobOutput(jobId)
            return
        }
        if (actionId === "job_panel.review") {
            masterController.setJobPanelReview(
                jobId,
                String(data.review_status || data.status || "")
            )
            return
        }
        if (actionId === "job_panel.regenerate"
                || actionId === "job_panel.retry") {
            if (jobId.length > 0)
                screen.requestSceneRegen(row)
            else
                screen.openJobPanelBatchActions()
            return
        }
        if (actionId === "job_panel.delete") {
            screen.requestSceneDelete(row)
            return
        }
        if (actionId === "job_panel.edit") {
            screen.openJobPanelPromptEditor(row)
            return
        }
        if (actionId === "job_panel.asset") {
            screen.handleAssetRequested(row, Number(data.slot_index || 0))
            return
        }
        if (actionId === "job_panel.clear") {
            screen.applyClearQueueResult(masterController.clearJobPanelCompleted())
            return
        }
    }

    function rowScript(row) {
        if (!row)
            return ""
        var resultData = screen.rowResultData(row)
        if (resultData)
            return JSON.stringify(resultData, null, 2)
        if (row.prompts && row.prompts.length > 0 && row.prompts[0].prompt)
            return String(row.prompts[0].prompt)
        return String(row.prompt || row.idea || row.name || "")
    }

    function rowResultData(row) {
        if (!row)
            return null
        if (row.result_data && typeof row.result_data === "object")
            return row.result_data
        if (row.job_meta && row.job_meta.result && typeof row.job_meta.result === "object")
            return row.job_meta.result
        if (row.meta && row.meta.result && typeof row.meta.result === "object")
            return row.meta.result
        return null
    }

    function rowScriptObject(row) {
        var resultData = screen.rowResultData(row)
        if (resultData)
            return resultData
        var text = screen.rowScript(row)
        if (!text.trim())
            return null
        try {
            return JSON.parse(text)
        } catch (err) {
            return null
        }
    }

    function reviewModeForScriptData(data) {
        if (!data || typeof data !== "object")
            return "normal"
        if (data.multi_asset_info)
            return "multi_asset"
        if (data.asset_library)
            return "normal"
        if (data.metadata && data.scenes)
            return "multi_asset"
        if (data.scenes)
            return "script_splitting"
        return "normal"
    }

    function reviewModeForRow(row) {
        return screen.reviewModeForScriptData(screen.rowScriptObject(row))
    }

    function queueStyleOptions(kind) {
        var items = [{ label: "--", value: "" }]
        var styles = masterOptionsController.styles || []
        var targetKind = String(kind || "style")
        for (var i = 0; i < styles.length; i++) {
            var item = styles[i] || ({})
            if (String(item.kind || "style") !== targetKind)
                continue
            var value = String(item.id || item.style_id || "")
            if (!value.length)
                continue
            items.push({
                label: String(item.display_name || item.name || value),
                value: value
            })
        }
        return items
    }

    function openRowFolder(row) {
        var configuredFolder = String((masterOptionsController.config || {}).output_folder || "")
        var result = masterController.openFolder(screen.rowId(row), configuredFolder)
        if (result && !result.ok) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(
                    result.message
                    || result.error
                    || (void i18n.revision, i18n.t("master.open_folder_failed", "Could not open the output folder."))
                )
            )
        }
    }

    function openClipPath(path) {
        var result = nativeShell.openPath(String(path || ""))
        if (result && !result.ok) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(
                    result.message
                    || result.error
                    || (void i18n.revision, i18n.t("master.open_clip_failed", "Could not open the generated clip."))
                )
            )
        }
    }

    function openPromptEditor(row) {
        screen.promptEditContext = {
            mode: "row",
            rowId: screen.rowId(row),
            sceneId: "",
            jobId: ""
        }
        promptEditDialog.openFor(row || ({}))
    }

    function openScenePromptEditor(row, sceneItem) {
        var payload = masterController.getSceneEditPayload(
            String((sceneItem && sceneItem.job_id) || ""),
            String((sceneItem && sceneItem.scene_id) || ""),
            screen.rowId(row)
        )
        if (!payload || !payload.ok) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(payload.message || payload.error || (void i18n.revision, i18n.t("master.edit_scene_prompt_failed", "Could not load the scene prompt.")))
            )
            return
        }
        screen.promptEditContext = {
            mode: "scene",
            rowId: screen.rowId(row),
            sceneId: String(payload.scene_id || ""),
            jobId: String(payload.job_id || "")
        }
        promptEditDialog.openFor({
            id: String(payload.job_id || ""),
            prompt: String(payload.prompt || "")
        })
        promptEditDialog.dialogTitle = String(payload.dialog_title || (void i18n.revision, i18n.t("common.edit", "Edit")))
        screen.refreshPromptEditorAssets(String(payload.job_id || ""))
    }

    function openJobPanelPromptEditor(row) {
        var payload = masterController.getSceneEditPayload(
            String((row && (row.job_id || row.id || row.row_id)) || ""),
            String((row && row.scene_id) || ""),
            String((row && row.master_prompt_job_id) || "")
        )
        if (!payload || !payload.ok) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(payload.message || payload.error || (void i18n.revision, i18n.t("master.edit_scene_prompt_failed", "Could not load the scene prompt.")))
            )
            return
        }
        screen.promptEditContext = {
            mode: "scene",
            rowId: String(payload.row_id || (row && row.master_prompt_job_id) || ""),
            sceneId: String(payload.scene_id || ""),
            jobId: String(payload.job_id || "")
        }
        promptEditDialog.openFor({
            id: String(payload.job_id || ""),
            prompt: String(payload.prompt || "")
        })
        promptEditDialog.dialogTitle = String(payload.dialog_title || (void i18n.revision, i18n.t("common.edit", "Edit")))
        screen.refreshPromptEditorAssets(String(payload.job_id || ""))
    }

    function refreshPromptEditorAssets(jobId) {
        var model = masterController ? masterController.jobPanelModel : null
        if (model && model.assetSlotsForJob)
            promptEditDialog.setAssetSlots(model.assetSlotsForJob(String(jobId || "")))
    }

    function retryRow(row) {
        return masterController.retryRow(screen.rowId(row))
    }

    function applyRetryRowResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(payload.message || payload.error || (void i18n.revision, i18n.t("master.retry_failed", "Could not retry the row.")))
            )
            return false
        }
        screen.showFeedback(
            (void i18n.revision, i18n.t("common.success", "Success")),
            String(payload.message || (void i18n.revision, i18n.t("master.retry_success_message", "Retry request accepted.")))
        )
        return true
    }

    function applySceneRegenResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(payload.message || payload.error || (void i18n.revision, i18n.t("master.scene_regen_failed", "Could not regenerate the selected scene.")))
            )
            return false
        }
        screen.showFeedback(
            (void i18n.revision, i18n.t("common.success", "Success")),
            String(payload.message || (void i18n.revision, i18n.t("master.scene_regen_success", "Scene regeneration requested.")))
        )
        return true
    }

    function queueCount(statusKey) {
        return Number(screen.queueStatsSafe[statusKey] || 0)
    }

    function hasActiveMasterQueue() {
        if (screen.queueCount("generating") > 0)
            return true
        var rows = screen.queueRowsSafe || []
        for (var i = 0; i < rows.length; i++) {
            var status = String((rows[i] && (rows[i].status || rows[i].status_label || rows[i].job_status)) || "").toLowerCase()
            if (status === "running" || status === "generating" || status === "processing" || status === "polling" || status === "upscaling")
                return true
        }
        var jobs = screen.jobPanelRowsSafe || []
        for (var j = 0; j < jobs.length; j++) {
            var jobStatus = String((jobs[j] && (jobs[j].status || jobs[j].status_label || jobs[j].job_status)) || "").toLowerCase()
            if (jobStatus === "running" || jobStatus === "generating" || jobStatus === "processing" || jobStatus === "polling" || jobStatus === "upscaling")
                return true
        }
        return false
    }

    function activeMasterQueueRow() {
        var rows = screen.queueRowsSafe || []
        for (var i = 0; i < rows.length; i++) {
            var status = String((rows[i] && (rows[i].status || rows[i].status_label || rows[i].job_status)) || "").toLowerCase()
            if (status === "running" || status === "generating" || status === "processing" || status === "polling" || status === "upscaling")
                return rows[i]
        }
        return rows.length > 0 ? rows[0] : ({})
    }

    function elapsedText(row) {
        var item = row || {}
        return JobClock.elapsedText(
            item,
            screen.elapsedClockMs,
            String(item.status || item.status_label || item.job_status || ""),
            screen.clockStartMs
        )
    }

    Timer {
        interval: 1000
        repeat: true
        running: screen.hasActiveMasterQueue()
        onRunningChanged: {
            screen.elapsedClockMs = Date.now()
            if (running) {
                if (screen.clockStartMs <= 0)
                    screen.clockStartMs = screen.elapsedClockMs
            } else {
                screen.clockStartMs = 0
            }
        }
        onTriggered: screen.elapsedClockMs = Date.now()
    }

    function handleMasterQueueLifecycle() {
        if (masterController.authPauseRequired) {
            screen.masterQueueLifecycleArmed = false
            screen.masterQueueLifecycleWasActive = false
            return
        }
        var active = screen.hasActiveMasterQueue()
        if (active) {
            if (screen.masterQueueLifecycleArmed)
                screen.masterQueueLifecycleWasActive = true
            return
        }
        if (!screen.masterQueueLifecycleArmed || !screen.masterQueueLifecycleWasActive)
            return
        screen.masterQueueLifecycleArmed = false
        screen.masterQueueLifecycleWasActive = false
        var completed = screen.queueCount("completed")
        var failed = screen.queueCount("failed")
        if (completed <= 0 && failed <= 0)
            return
        var message = (void i18n.revision, i18n.t("queue.queue_completed_msg", "Queue completed!\n\nCompleted: {completed}\nFailed: {failed}"))
            .replace("{completed}", String(completed))
            .replace("{failed}", String(failed))
        screen.showFeedback(
            (void i18n.revision, i18n.t("queue.queue_completed_title", "Queue Completed")),
            message
        )
    }

    function requestStartQueue() {
        if (masterController.authPauseRequired) {
            screen.applyStartQueueResult(masterController.resumeQueueAfterAuthUpdate())
            return
        }
        // Confirmation is mandatory — always show the start-queue dialog (no skip option).
        masterQueueStartDialog.open()
    }

    // --- Pre-queue confirmation gate ---
    function _labelFor(options, value) {
        var arr = options || []
        var v = String(value === undefined || value === null ? "" : value)
        for (var i = 0; i < arr.length; i++)
            if (String((arr[i] || {}).value || "") === v)
                return String((arr[i] || {}).label || v)
        return v
    }
    function buildConfigRows() {
        var c = masterController.currentConfig() || ({})
        var opts = masterOptionsController.options || ({})
        var isScript = screen.inputMode === "script"
        var clip = Number(c.clip_duration_seconds || 0)
        var totalDur = Number(c.duration || 0)
        var sceneCount = (totalDur > 0 && clip > 0) ? Math.ceil(totalDur / clip) : 0
        // Tổng thời lượng + số cảnh dự kiến = số clip thật sự được tạo (1 clip/cảnh).
        // Master KHÔNG dùng output_count (không nhân biến thể), nên bỏ "Số lượng".
        // SCRIPT mode KHÔNG ép tổng — số cảnh + thời lượng do PHÂN TÍCH kịch bản
        // quyết khi tạo (khác idea ép tổng → chia cảnh). Không hiện "60s · 8 cảnh".
        var durValue = isScript
            ? (void i18n.revision, i18n.t("master.total_by_script", "Theo kịch bản (phân tích khi tạo)"))
            : (totalDur > 0
                ? (totalDur + "s" + (sceneCount > 0 ? (" · ~" + sceneCount + " " + (void i18n.revision, i18n.t("master.scenes_unit", "cảnh"))) : ""))
                : "Auto")
        var voiceLockOn = (c.enable_flow_voice_lock !== undefined ? c.enable_flow_voice_lock : c.voice_lock) ? true : false
        var styleName = String(c.selected_style_name || "").trim()
        if (!styleName.length) {
            var styleId = String(c.structural_style_id || c.style_id || c.selected_style_id || "").trim()
            styleName = styleId ? (screen._labelFor(opts.styles, styleId) || styleId) : ""
        }
        var folder = String(c.output_folder || "").trim()
        var unset = (void i18n.revision, i18n.t("queue_confirm.not_set", "⚠ Chưa chọn"))
        var subtitleRow = SubtitleIntent.queueConfirmRow(
            c.subtitle_profile || ({}),
            String(c.voice_language || c.language || "vi")
        )
        return [
            { label: (void i18n.revision, i18n.t("config_panel.model", "Model")), value: screen._labelFor(opts.models, c.model_key) },
            { label: (void i18n.revision, i18n.t("queue_confirm.style", "Style")), value: styleName.length > 0 ? styleName : unset },
            { label: (void i18n.revision, i18n.t("queue_confirm.output_folder", "Thư mục lưu")), value: folder.length > 0 ? folder : unset },
            { label: (void i18n.revision, i18n.t("config_panel.aspect", "Tỷ lệ")), value: String(c.aspect_ratio || "16:9") },
            { label: (void i18n.revision, i18n.t("config_panel.quality", "Chất lượng")), value: String(c.quality || "—") },
            { label: (void i18n.revision, i18n.t("master.model_duration", "Độ dài clip")), value: clip > 0 ? (clip + "s") : "Auto" },
            { label: (void i18n.revision, i18n.t("master.total_duration", "Tổng thời lượng")), value: durValue },
            { label: (void i18n.revision, i18n.t("master.voice_language", "Giọng")), value: screen._labelFor(opts.voice_languages, c.voice_language) || "—" },
            { label: (void i18n.revision, i18n.t("master.voice_lock", "Đồng bộ giọng")), value: voiceLockOn ? (void i18n.revision, i18n.t("common.on", "Bật")) : (void i18n.revision, i18n.t("common.off", "Tắt")) },
            { label: (void i18n.revision, i18n.t("qml.master.library_control", "Điều khiển nhân vật, đồ vật, bối cảnh")), value: c.character_consistency ? (void i18n.revision, i18n.t("common.on", "Bật")) : (void i18n.revision, i18n.t("common.off", "Tắt")) },
            {
                label: (void i18n.revision, i18n.t("queue_confirm.subtitle", "Phụ đề")),
                value: String((subtitleRow && subtitleRow.value) || "—"),
                warn: Boolean(subtitleRow && subtitleRow.warn)
            }
        ]
    }
    function doAddToQueue() {
        if (screen.inputMode !== "idea") {
            screen.applyAddInputResult(masterController.addInput(
                ideaInput.text, screen.inputMode,
                screen.extraRequirementsEnabled ? extraRequirementsInput.text : "",
                screen.saveAiCharacters))
            return
        }
        var preview = masterController.parseIdeasPreview(ideaInput.text)
        if (!preview.ok || preview.count <= 1) {
            screen.applyAddInputResult(masterController.addInput(
                ideaInput.text, screen.inputMode,
                screen.extraRequirementsEnabled ? extraRequirementsInput.text : "",
                screen.saveAiCharacters))
            return
        }
        ideaConfirmDialog.pendingItems = preview.items.slice()
        ideaConfirmDialog.open()
    }
    function commitIdeaDuration() {
        if (!screen.ideaMode)
            return
        var val = parseInt(ideaDurationInput.text)
        if (isNaN(val) || val < 0)
            val = 0
        if (val > 3600)
            val = 3600
        ideaDurationInput.text = String(val)
        if (Number(screen.masterConfig.duration || 0) !== val)
            masterOptionsController.setOption("duration", val)
    }
    function requestAddToQueue() {
        // Commit once before preflight so the queue snapshot sees the number
        // currently visible in the field, even if focus has not changed yet.
        screen.commitIdeaDuration()
        // Confirmation is mandatory — always show the pre-queue gate (no skip option).
        queuePreflightDialog.openFor(screen.buildConfigRows())
    }

    function requestPauseQueue() {
        screen.masterQueueLifecycleArmed = false
        screen.masterQueueLifecycleWasActive = false
        screen.applyPauseQueueResult(masterController.pauseQueue())
    }

    function showFeedback(title, message) {
        screen.feedbackTitle = String(title || "")
        screen.feedbackMessage = String(message || "")
        masterQueueFeedbackDialog.open()
    }

    // Click ô asset → mở thư viện media (chọn 1) → thay asset cho slot.
    property string pendingAssetRowId: ""
    property int pendingAssetSlot: -1
    function handleAssetRequested(row, index) {
        screen.pendingAssetRowId = screen.rowId(row)
        screen.pendingAssetSlot = Number(index)
        var filterType = ""
        var model = masterController ? masterController.jobPanelModel : null
        if (model && model.assetSlotsForJob) {
            var slots = model.assetSlotsForJob(screen.pendingAssetRowId) || []
            var slot = slots[Number(index)] || ({})
            var slotType = String(slot.slotType || slot.asset_type || "")
            if (slotType.toLowerCase() === "character" || slot.entityLocked === true)
                filterType = "character"
        }
        masterAssetLibraryDialog.mode = "select"
        masterAssetLibraryDialog.filterType = filterType
        masterAssetLibraryDialog.maxSelection = 1
        masterAssetLibraryDialog.open()
    }

    function requestDeleteRow(row) {
        screen.pendingDeleteRow = row || ({})
        masterQueueDeleteDialog.open()
    }

    function requestClearQueue() {
        masterQueueClearDialog.open()
    }

    function openJobPanelBatchActions() {
        jobPanelBatchActionsDialog.open()
    }

    function requestSceneRegen(row) {
        var sceneIndexValue = Number((row && row.scene_index) !== undefined ? row.scene_index : -1)
        pendingSceneRegen = {
            reason: "direct",
            jobId: String((row && (row.job_id || row.id || row.row_id)) || ""),
            rowId: String((row && row.master_prompt_job_id) || ""),
            sceneId: String((row && row.scene_id) || ""),
            sceneLabel: String((row && (row.scene_label || row.scene_id || row.title)) || "scene"),
            sceneIndex: isNaN(sceneIndexValue) ? -1 : sceneIndexValue,
            promptPreview: String((row && (row.prompt || row.idea || row.title)) || "")
        }
        masterSceneRegenDialog.open()
    }

    function requestSceneDelete(row) {
        pendingSceneDelete = {
            jobId: String((row && (row.job_id || row.id || row.row_id)) || ""),
            sceneId: String((row && row.scene_id) || ""),
            sceneLabel: String((row && (row.scene_label || row.scene_id || row.title)) || "scene"),
            promptPreview: String((row && (row.prompt || row.idea || row.title)) || "")
        }
        masterSceneDeleteDialog.open()
    }

    function applyRemoveRowResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(payload.message || payload.error || (void i18n.revision, i18n.t("common.delete_failed", "Delete failed")))
            )
            return false
        }
        screen.showFeedback(
            (void i18n.revision, i18n.t("common.success", "Success")),
            String(payload.message || (void i18n.revision, i18n.t("messages.deleted_job", "Deleted job.")))
        )
        return true
    }

    function applyClearQueueResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(payload.message || payload.error || (void i18n.revision, i18n.t("common.delete_failed", "Delete failed")))
            )
            return false
        }
        screen.masterQueueLifecycleArmed = false
        screen.masterQueueLifecycleWasActive = false
        screen.showFeedback(
            (void i18n.revision, i18n.t("common.success", "Success")),
            String(payload.message || (void i18n.revision, i18n.t("messages.deleted_all_jobs", "Deleted {count} jobs")).replace("{count}", String(payload.removed || 0)))
        )
        return true
    }

    function applyStartQueueResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            // `alerted` → a gate already popped a runtime-alert dialog; skip the generic
            // feedback dialog so two dialogs don't stack.
            if (!payload.alerted)
                screen.showFeedback(
                    (void i18n.revision, i18n.t("common.warning", "Warning")),
                    String(payload.message || payload.error || (void i18n.revision, i18n.t("master.start_failed", "Could not start queue.")))
                )
            return false
        }
        if (Number(payload.started || 0) > 0 || String(payload.batch_id || payload.running_batch_id || "").length > 0) {
            screen.masterQueueLifecycleArmed = true
            screen.masterQueueLifecycleWasActive = screen.hasActiveMasterQueue()
        }
        screen.showFeedback(
            (void i18n.revision, i18n.t("common.success", "Success")),
            String(payload.message || (void i18n.revision, i18n.t("master.start_processing", "Start Processing")))
        )
        return true
    }

    function applyPauseQueueResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(payload.message || payload.error || (void i18n.revision, i18n.t("master.stop_failed", "Could not stop the queue.")))
            )
            return false
        }
        screen.masterQueueLifecycleArmed = false
        screen.masterQueueLifecycleWasActive = false
        screen.showFeedback(
            (void i18n.revision, i18n.t("common.success", "Success")),
            String(payload.message || (void i18n.revision, i18n.t("master.stop_delete", "Stop & Delete")))
        )
        return true
    }

    function applyAddInputResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            screen.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(payload.message || payload.error || (void i18n.revision, i18n.t("master.add_failed", "Could not add input to queue.")))
            )
            return false
        }
        screen.showFeedback(
            (void i18n.revision, i18n.t("common.success", "Success")),
            String(payload.message || (void i18n.revision, i18n.t("master.add_success", "Added input to queue.")))
        )
        return true
    }

    function openChargenPolicy(row) {
        if (!row)
            return
        chargenPolicyDialog.openFor(row.policy_failed_characters || ((row.result_data || {}).policy_failed_characters) || (((row.job_meta || {}).result || {}).policy_failed_characters) || [])
        chargenPolicyDialog.policyRowId = screen.rowId(row)
    }

    onShowRightRailChanged: {
        if (showRightRail) {
            rightRailExpanded = false
        }
    }

    Connections {
        target: masterController

        function onOpenPathRequested(path) {
            nativeShell.openPath(path)
        }

        function onQueueRowsChanged() {
            screen.handleMasterQueueLifecycle()
        }

        function onStatsChanged() {
            screen.handleMasterQueueLifecycle()
        }
    }

    Timer {
        id: masterQueueRefreshTimer
        interval: 1500
        repeat: true
        running: screen.visible && !TourState.preview   // don't refresh over demo data
        onTriggered: {
            if (!screen.hasActiveMasterQueue())
                return
            masterController.refresh()
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
            id: leftContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            border.color: "transparent"

            ScrollView {
                id: leftScroll
                anchors.fill: parent
                anchors.margins: 0
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                contentWidth: contentColumn.width
                contentHeight: contentColumn.implicitHeight

                ColumnLayout {
                    id: contentColumn
                    width: leftScroll.availableWidth > 0 ? leftScroll.availableWidth : leftContainer.width
                    // Fill the scroll viewport when content is shorter than it, so
                    // the fillHeight queue panel can expand; grow + scroll when the
                    // content (config + toolbar + step1 + step2) is taller.
                    height: Math.max(implicitHeight, leftScroll.availableHeight)
                    spacing: VfTheme.dp(9)

                    MasterConfigPanel {
                        id: masterConfigPanel
                    }

                    MasterFeatureToolbar {
                        id: featureToolbar
                    }

                    VfPanel {
                        Layout.fillWidth: true
                        Layout.preferredHeight: screen.inputAreaHeight
                        title: (void i18n.revision, i18n.t("master.step1_title", "Step 1: Enter ideas"))
                        subtitle: ""
                        accent: VfTheme.greenBorder
                        dense: true

                        Flow {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(7)

                            VfChip {
                                actionId: "master.input.idea_mode"
                                text: (void i18n.revision, i18n.t("master.idea_mode", "Idea"))
                                selected: screen.inputMode === "idea"
                                accent: VfTheme.primary
                                onClicked: masterOptionsController.setOption("input_mode", "idea")
                            }

                            VfChip {
                                actionId: "master.input.script_mode"
                                text: (void i18n.revision, i18n.t("master.script_mode", "Script"))
                                selected: screen.inputMode === "script"
                                accent: VfTheme.primary
                                onClicked: masterOptionsController.setOption("input_mode", "script")
                            }

                            // Người dẫn truyện thuộc về NỘI DUNG (cách viết ý tưởng/kịch bản),
                            // không phải feature hậu kỳ — nên sống cạnh Idea/Script (chốt Bố Độ 19/7).
                            // Director mode là MẶC ĐỊNH (config narration_director=true): kịch bản
                            // kể cả chỉ đạo chi tiết chỉ là xương sống — lời đọc được LLM dựng sau
                            // khi video về, khớp frame + speech window thật. Không toggle UI.
                            VfChip {
                                actionId: "master.input.narrator"
                                text: (void i18n.revision, i18n.t("master.narrator", "Người dẫn truyện"))
                                selected: Boolean(screen.masterConfig.enable_narrator)
                                accent: VfTheme.cyan
                                onClicked: masterOptionsController.setOption("enable_narrator", !Boolean(screen.masterConfig.enable_narrator))
                            }

                            VfButton {
                                actionId: "master.dialog.narrator_template"
                                text: (void i18n.revision, i18n.t("master.narrator_template", "Mẫu dẫn truyện"))
                                minWidth: VfTheme.dp(120)
                                visible: screen.scriptMode && Boolean(screen.masterConfig.enable_narrator)
                                onClicked: scriptGuideDialog.showNarratorTemplate()
                            }

                            VfChip {
                                actionId: "master.input.extra_requirements"
                                text: (void i18n.revision, i18n.t("master.extra_requirements", "Extra requirements"))
                                selected: screen.extraRequirementsEnabled
                                accent: VfTheme.amber
                                visible: screen.ideaMode
                                onClicked: masterOptionsController.setOption("extra_requirements", !screen.extraRequirementsEnabled)
                            }

                            // Nút "Tự động lưu nhân vật AI" chuyển vào shared
                            // CharacterConsistencyPanel (MasterLibraryControl) để mọi
                            // tab dùng chung 1 chỗ; flag save_ai_characters giữ nguyên.

                            VfButton {
                                actionId: "master.dialog.script_guide"
                                text: (void i18n.revision, i18n.t("qml.master.script_guide", "Script Guide"))
                                minWidth: VfTheme.dp(120)
                                visible: screen.scriptMode
                                onClicked: scriptGuideDialog.openGuide()
                            }

                            // (Nút "Chuẩn hoá kịch bản" thủ công đã bỏ — chuẩn hoá giờ
                            // chạy TỰ ĐỘNG trong luồng gen, trước bước split.)

                            // Idea total duration (moved here from the top config
                            // bar). This is the target duration of the IDEA/video,
                            // not the per-clip model duration. Idea mode only.
                            Rectangle {
                                visible: screen.ideaMode
                                height: VfTheme.chipHeight
                                width: ideaDurationRow.implicitWidth + VfTheme.dp(16)
                                radius: VfTheme.radiusControl
                                color: VfTheme.surface
                                border.color: VfTheme.borderBox
                                border.width: 1

                                Row {
                                    id: ideaDurationRow
                                    anchors.centerIn: parent
                                    spacing: VfTheme.dp(6)

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: (void i18n.revision, i18n.t("master.duration", "Duration"))
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontControl
                                        font.weight: Font.DemiBold
                                    }

                                    TextField {
                                        id: ideaDurationInput
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: VfTheme.dp(72)
                                        height: VfTheme.dp(28)
                                        // TextField's default top/bottom padding + font is taller
                                        // than 28dp and clips the digits — zero the vertical padding
                                        // and center instead.
                                        topPadding: 0
                                        bottomPadding: 0
                                        leftPadding: VfTheme.dp(6)
                                        rightPadding: VfTheme.dp(6)
                                        text: String(screen.masterConfig.duration || "0")
                                        validator: IntValidator { bottom: 0; top: 3600 }
                                        placeholderText: "0=Auto"
                                        horizontalAlignment: TextInput.AlignHCenter
                                        verticalAlignment: TextInput.AlignVCenter
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontControl
                                        // Total video duration. 0 = Auto (AI decides);
                                        // hard limit 3600s (60 min), matching the PyQt6 baseline.
                                        ToolTip.visible: hovered
                                        ToolTip.delay: 450
                                        ToolTip.text: (void i18n.revision, i18n.t("master.duration_hint", "0 = Auto • tối đa 3600s (60 phút)"))
                                        background: Rectangle {
                                            color: VfTheme.surface
                                            border.color: VfTheme.borderBox
                                            radius: VfTheme.dp(6)
                                        }
                                        onEditingFinished: {
                                            screen.commitIdeaDuration()
                                        }
                                    }

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: VfTheme.dp(26)
                                        height: VfTheme.dp(26)
                                        radius: VfTheme.dp(6)
                                        color: ideaPresetMouse.containsMouse ? VfTheme.surfaceSoft : "transparent"
                                        border.color: VfTheme.borderBox
                                        VfAppIcon { anchors.centerIn: parent; name: "chevron-down"; size: 14; framed: false }
                                        MouseArea {
                                            id: ideaPresetMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: ideaDurationPresetMenu.open()
                                        }
                                        // Total-video duration presets only (the
                                        // short clip-level values 4/6/8/10s belong
                                        // to the "Clip" selector, not here). Each
                                        // item is styled so the highlight is light
                                        // blue, not the unstyled black default.
                                        Menu {
                                            id: ideaDurationPresetMenu
                                            implicitWidth: VfTheme.dp(180)
                                            background: Rectangle {
                                                color: VfTheme.surface
                                                border.color: VfTheme.border
                                                border.width: 1
                                                radius: 6
                                                implicitWidth: VfTheme.dp(180)
                                            }
                                            Repeater {
                                                model: [
                                                    { v: 60,  t: (void i18n.revision, i18n.t("master_prompt_screen.duration_60s_1min", "60s (1 phút)")) },
                                                    { v: 90,  t: (void i18n.revision, i18n.t("master_prompt_screen.duration_90s_1_5min", "90s (1.5 phút)")) },
                                                    { v: 120, t: (void i18n.revision, i18n.t("master_prompt_screen.duration_120s_2min", "120s (2 phút)")) },
                                                    { v: 180, t: (void i18n.revision, i18n.t("master_prompt_screen.duration_180s_3min", "180s (3 phút)")) },
                                                    { v: 300, t: (void i18n.revision, i18n.t("master_prompt_screen.duration_300s_5min", "300s (5 phút)")) },
                                                    { v: 480, t: (void i18n.revision, i18n.t("master_prompt_screen.duration_480s_8min", "480s (8 phút)")) }
                                                ]
                                                delegate: MenuItem {
                                                    required property var modelData
                                                    text: modelData.t
                                                    height: VfTheme.dp(30)
                                                    contentItem: Text {
                                                        text: modelData.t
                                                        color: VfTheme.text
                                                        font.family: VfTheme.fontFamily
                                                        font.pixelSize: VfTheme.fontControl
                                                        verticalAlignment: Text.AlignVCenter
                                                        leftPadding: VfTheme.dp(8)
                                                    }
                                                    background: Rectangle {
                                                        color: highlighted ? VfTheme.blueFill : "transparent"
                                                        radius: VfTheme.dp(4)
                                                    }
                                                    onTriggered: {
                                                        ideaDurationInput.text = String(modelData.v)
                                                        masterOptionsController.setOption("duration", modelData.v)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Inline note (beside the box) so the allowed range is
                            // visible without hovering. Free input 0–3600s; 0 = Auto.
                            Text {
                                visible: screen.ideaMode
                                height: VfTheme.chipHeight
                                verticalAlignment: Text.AlignVCenter
                                text: (void i18n.revision, i18n.t("master.duration_note", "0 = Auto · nhập 1–3600s (tối đa 60 phút)"))
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.italic: true
                            }
                        }

                        NarratorControl {
                            expanded: Boolean(screen.masterConfig.enable_narrator)
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: VfTheme.radiusControl
                            color: VfTheme.surface
                            border.color: VfTheme.borderBox
                            clip: true

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(8)
                                spacing: VfTheme.dp(8)

                                // Bọc TextArea trong ScrollView để kịch bản DÀI scroll
                                // nội bộ (trước đây TextArea trần trong ColumnLayout bị
                                // khoá chiều cao → text tràn, không scroll được).
                                ScrollView {
                                    id: ideaScroll
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                                    TextArea {
                                        id: ideaInput
                                        objectName: "ideaInput"   // tour target
                                        width: ideaScroll.availableWidth
                                        placeholderText: screen.inputMode === "script"
                                            ? (void i18n.revision, i18n.t("qml.master.script_input_placeholder", "Paste one complete script here"))
                                            : (void i18n.revision, i18n.t("master.idea_input_placeholder", "Enter video ideas, one per line"))
                                        wrapMode: TextEdit.Wrap
                                        color: VfTheme.text
                                        placeholderTextColor: VfTheme.textSubtle
                                        selectedTextColor: "#FFFFFF"
                                        selectionColor: VfTheme.primary
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontBody
                                        background: Item {}

                                        // Ý tưởng (idea) và kịch bản (script) là 2 buffer
                                        // RIÊNG, không thông nhau. Ô này hiển thị/lưu buffer
                                        // theo mode hiện tại; đổi mode → nạp lại buffer tương ứng.
                                        function activeBuffer() {
                                            if (typeof masterOptionsController === "undefined" || !masterOptionsController)
                                                return ""
                                            return screen.inputMode === "script"
                                                ? String(masterOptionsController.scriptText || "")
                                                : String(masterOptionsController.ideaText || "")
                                        }
                                        Component.onCompleted: text = activeBuffer()
                                        onTextChanged: {
                                            if (typeof masterOptionsController === "undefined" || !masterOptionsController)
                                                return
                                            if (screen.inputMode === "script")
                                                masterOptionsController.setScriptText(text)
                                            else
                                                masterOptionsController.setIdeaText(text)
                                        }

                                        // Đổi idea↔script → nạp lại đúng buffer (không bleed).
                                        Connections {
                                            target: screen
                                            ignoreUnknownSignals: true
                                            function onInputModeChanged() {
                                                var v = ideaInput.activeBuffer()
                                                if (ideaInput.text !== v)
                                                    ideaInput.text = v
                                            }
                                        }

                                        // Phản ánh thay đổi buffer từ ngoài (restore, chuẩn
                                        // hoá kịch bản…); guard theo mode chống vòng lặp.
                                        Connections {
                                            target: typeof masterOptionsController !== "undefined" ? masterOptionsController : null
                                            ignoreUnknownSignals: true
                                            function onIdeaTextChanged() {
                                                if (screen.inputMode !== "script" && ideaInput.text !== masterOptionsController.ideaText)
                                                    ideaInput.text = masterOptionsController.ideaText
                                            }
                                            function onScriptTextChanged() {
                                                if (screen.inputMode === "script" && ideaInput.text !== masterOptionsController.scriptText)
                                                    ideaInput.text = masterOptionsController.scriptText
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: (screen.ideaMode && screen.extraRequirementsEnabled) ? 86 : 0
                                    visible: screen.ideaMode && screen.extraRequirementsEnabled
                                    radius: VfTheme.radiusControl
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.borderBox
                                    clip: true

                                    TextArea {
                                        id: extraRequirementsInput
                                        anchors.fill: parent
                                        anchors.margins: VfTheme.dp(8)
                                        placeholderText: (void i18n.revision, i18n.t("qml.master.extra_requirements_placeholder", "Extra rules, constraints, character notes, negative prompts..."))
                                        wrapMode: TextEdit.Wrap
                                        color: VfTheme.text
                                        placeholderTextColor: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        background: Item {}
                                        Component.onCompleted: {
                                            if (typeof masterOptionsController !== "undefined")
                                                text = masterOptionsController.extraRequirementsText
                                        }
                                        onTextChanged: {
                                            if (typeof masterOptionsController !== "undefined")
                                                masterOptionsController.setExtraRequirementsText(text)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    VfPanel {
                        id: step2Panel
                        Layout.fillWidth: true
                        // Grow to fill leftover space when the queue is short, but
                        // never shrink below its own content — so every queued job is
                        // shown without an inner scrollbar; the page scrolls instead.
                        Layout.fillHeight: true
                        Layout.minimumHeight: step2Panel.implicitHeight
                        title: (void i18n.revision, i18n.t("master.step2_title", "Step 2: Create script"))
                        subtitle: ""
                        accent: VfTheme.primary
                        dense: true

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(7)

                            VfButton {
                                actionId: "master.queue.add_to_queue"
                                text: (void i18n.revision, i18n.t("master.add_to_queue", "Add to Queue")).toUpperCase()
                                tone: "primary"
                                minWidth: VfTheme.dp(148)
                                onClicked: screen.requestAddToQueue()
                            }

                            VfButton {
                                actionId: "master.dialog.bulk_import"
                                text: (void i18n.revision, i18n.t("config_panel.bulk_import_short", "Bulk Import"))
                                tone: "accent"
                                minWidth: VfTheme.dp(118)
                                onClicked: bulkImportDialog.open()
                            }

                            Item { Layout.fillWidth: true }

                            VfToolbarSwitch {
                                actionId: "master.queue.auto_clear_completed"
                                text: (void i18n.revision, i18n.t("master.auto_clear_completed", "Tự xóa job xong"))
                                tooltip: (void i18n.revision, i18n.t(
                                    "master.auto_clear_completed_tooltip",
                                    "Bật: tự xóa các job đã hoàn thành, luôn giữ lại job xong cuối cùng để còn mở thư mục. Tắt: mọi job xong vẫn nằm trong hàng chờ. Chỉ chạy 1 job thì job đó ở lại. File trên máy không bị xóa."))
                                checked: screen.masterConfig.auto_clear_completed !== false
                                accent: "#F59E0B"
                                minWidth: VfTheme.dp(128)
                                implicitHeight: VfTheme.dp(31)
                                onToggled: function(enabled) {
                                    masterOptionsController.setOption("auto_clear_completed", enabled)
                                    if (enabled && masterController)
                                        masterController.pruneOlderCompleted()
                                }
                            }

                            Text {
                                text: (void i18n.revision, i18n.t("master.queue_stats", "Queue: {count} jobs")).replace("{count}", String(screen.queueStatsSafe.total || 0))
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                font.weight: VfTheme.weightControl
                            }

                            Row {
                                id: queueActions
                                Layout.preferredHeight: VfTheme.dp(31)
                                Layout.preferredWidth: implicitWidth
                                spacing: VfTheme.dp(5)

                                VfButton {
                                    actionId: "master.queue.stop_delete"
                                    text: (void i18n.revision, i18n.t("master.stop_delete", "Stop & Delete"))
                                    tone: "danger"
                                    minWidth: VfTheme.dp(112)
                                    enabled: !masterController.authPauseRequired && (screen.queueStatsSafe.total || 0) > 0
                                    onClicked: screen.requestPauseQueue()
                                }

                                VfButton {
                                    actionId: "master.queue.clear_all"
                                    text: (void i18n.revision, i18n.t("common.delete_all", "Delete All"))
                                    minWidth: VfTheme.dp(96)
                                    tone: "danger"
                                    onClicked: screen.requestClearQueue()
                                }

                                VfButton {
                                    actionId: "master.queue.start_processing"
                                    text: masterController.authPauseRequired
                                        ? (void i18n.revision, i18n.t("master.resume_queue", "Resume Queue"))
                                        : (void i18n.revision, i18n.t("master.start_processing", "Start Processing"))
                                    minWidth: VfTheme.dp(138)
                                    tone: "primary"
                                    onClicked: screen.requestStartQueue()
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: visible ? 30 : 0
                            visible: String(screen.lastQueueAction.message || "").length > 0
                                && String(screen.lastQueueAction.message || "") !== "Ready"
                            radius: VfTheme.radiusControl
                            color: screen.lastQueueAction.blocked ? VfTheme.redFill : VfTheme.surfaceSoft
                            border.color: screen.lastQueueAction.blocked ? VfTheme.redBorderSoft : VfTheme.borderBox
                            clip: true

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(10)
                                anchors.rightMargin: VfTheme.dp(10)
                                spacing: VfTheme.dp(8)

                                Text {
                                    text: screen.lastQueueAction.blocked
                                        ? (void i18n.revision, i18n.t("qml.master.queue_blocked", "Blocked"))
                                        : (void i18n.revision, i18n.t("qml.master.queue_status", "Status"))
                                    color: screen.lastQueueAction.blocked ? VfTheme.redText : VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(11)
                                    font.weight: Font.Bold
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: {
                                        var code = String(screen.lastQueueAction.code || "")
                                        var message = String(screen.lastQueueAction.message || "")
                                        return code.length > 0 ? code + ": " + message : message
                                    }
                                    color: screen.lastQueueAction.blocked ? VfTheme.redText : VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(11)
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        MasterQueueTable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            elapsedClockMs: screen.elapsedClockMs
                            rows: screen.queueRowsSafe
                            stats: screen.queueStatsSafe
                            techniqueOptions: screen.queueTechniqueOptions
                            materialOptions: screen.queueMaterialOptions
                            durationOptions: screen.queueDurationOptions
                            languageOptions: screen.queueLanguageOptions
                            aspectOptions: screen.queueAspectOptions
                            onPreviewRequested: row => {
                                jobDetailsDialog.scriptData = screen.rowScriptObject(row)
                                jobDetailsDialog.scriptMode = screen.reviewModeForRow(row)
                                jobDetailsDialog.openFor(row)
                            }
                            onOpenFolderRequested: row => screen.openRowFolder(row)
                            onOpenClipRequested: path => screen.openClipPath(path)
                            onRemoveRequested: row => screen.requestDeleteRow(row)
                            onTitleChanged: (row, title) => masterController.updateRowTitle(screen.rowId(row), title)
                            onTechniqueChanged: (row, techniqueId) => masterController.updateRowTechnique(screen.rowId(row), techniqueId)
                            onMaterialChanged: (row, materialId) => masterController.updateRowMaterial(screen.rowId(row), materialId)
                            onDurationChanged: (row, durationSeconds) => masterController.updateRowDuration(screen.rowId(row), durationSeconds)
                            onLanguageChanged: (row, languageCode) => masterController.updateRowLanguage(screen.rowId(row), languageCode)
                            onAspectChanged: (row, aspectRatio) => masterController.updateRowAspect(screen.rowId(row), aspectRatio)
                        }
                    }
                }
            }
        }

        JobPanelWidget {
            Layout.preferredWidth: screen.rightRailWidth
            Layout.fillHeight: true
            visible: screen.showRightRail
            panelActive: screen.showRightRail
            autoPageSize: true
            jobModel: TourState.preview ? null : masterController.jobPanelModel
            rows: screen.jobPanelRowsSafe
            stats: screen.queueStatsSafe
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
            id: compactJobDrawerHeader
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
            anchors.top: compactJobDrawerHeader.bottom
            anchors.bottom: parent.bottom
            active: screen.compactJobRail
            sourceComponent: JobPanelWidget {
                anchors.fill: parent
                panelActive: screen.rightRailExpanded
                autoPageSize: true
                jobModel: TourState.preview ? null : masterController.jobPanelModel
                rows: screen.jobPanelRowsSafe
                stats: screen.queueStatsSafe
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

    // Tour hook: App.qml opens this dialog (via masterLoader.item) to run the
    // in-dialog Bulk Import walkthrough. The `id` isn't reachable from outside; a
    // function is.
    function openBulkImportForTour() { bulkImportDialog.open() }
    // Close via the dialog id (a Popup isn't an Item, so App can't find it by
    // objectName on Overlay.overlay — it must go through this screen function).
    function closeBulkImportForTour() { if (bulkImportDialog.opened) bulkImportDialog.close() }

    BulkImportDialog {
        id: bulkImportDialog
        scriptMode: screen.inputMode === "script"
        spreadsheetImportEnabled: true
        preferItemAccept: true
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
        onAcceptedText: text => bulkImportDialog.applyAcceptResult(masterController.addInput(
            text,
            screen.inputMode,
            screen.extraRequirementsEnabled ? extraRequirementsInput.text : "",
            screen.saveAiCharacters
        ))
        onAcceptedItems: items => bulkImportDialog.applyAcceptResult(masterController.addInputItems(
            items,
            screen.inputMode,
            screen.extraRequirementsEnabled ? extraRequirementsInput.text : "",
            screen.saveAiCharacters
        ))
    }

    ScriptReviewDialog {
        id: scriptReviewDialog
        onApproveRequested: (scriptText, scriptData) => scriptReviewDialog.applyApproveResult(
            masterController.approveScriptWithData(screen.reviewRowId, scriptText, scriptData)
        )
    }

    ScriptGuideDialog {
        id: scriptGuideDialog
    }

    JobDetailsDialog {
        id: jobDetailsDialog
        onEditRequested: row => screen.openPromptEditor(row)
        onEditSceneRequested: (row, sceneItem) => screen.openScenePromptEditor(row, sceneItem)
        onRetryRequested: row => jobDetailsDialog.applyRetryResult(screen.retryRow(row))
        onOpenFolderRequested: row => screen.openRowFolder(row)
        onRecreateRequested: (row, aspectRatio) => jobDetailsDialog.applyRecreateResult(masterController.recreateRow(screen.rowId(row), aspectRatio))
        onRegenScenesRequested: (row, sceneIds) => jobDetailsDialog.applyRegenScenesResult(masterController.regenScenes(screen.rowId(row), sceneIds))
        onFixPolicyRequested: row => screen.openChargenPolicy(row)
        onEditScriptRequested: (row, scriptData, scriptMode) => {
            screen.reviewRowId = screen.rowId(row)
            scriptReviewDialog.scriptText = screen.rowScript(row)
            scriptReviewDialog.mode = scriptMode
            scriptReviewDialog.originalScriptData = scriptData
            scriptReviewDialog.open()
        }
    }

    BatchActionsDialog {
        id: jobPanelBatchActionsDialog
        jobs: screen.jobPanelRowsSafe
        selectedJobs: []
        failedJobs: screen._failedJobPanelRows
        onApplyRequested: result => jobPanelBatchActionsDialog.applyResult(masterController.applyJobPanelBatchActions(result))
    }

    PromptEditDialog {
        id: promptEditDialog
        onRejected: screen.promptEditContext = ({ mode: "row" })
        onAssetReplaceRequested: (jobId, slotIndex) => screen.handleAssetRequested(
            { id: jobId, job_id: jobId, row_id: jobId },
            slotIndex
        )
        onSaveRequested: (rowId, title, prompt) => {
            if (screen.promptEditContext.mode === "scene") {
                var result = masterController.updateScenePrompt(
                    String(screen.promptEditContext.jobId || rowId || ""),
                    prompt,
                    String(screen.promptEditContext.sceneId || ""),
                    String(screen.promptEditContext.rowId || "")
                )
                promptEditDialog.applySaveResult(result, prompt)
                if (result && result.ok && result.prompt_changed) {
                    screen.pendingSceneRegen = {
                        reason: "prompt_edit",
                        jobId: String(result.job_id || screen.promptEditContext.jobId || ""),
                        rowId: String(result.row_id || screen.promptEditContext.rowId || ""),
                        sceneId: String(result.scene_id || screen.promptEditContext.sceneId || ""),
                        sceneLabel: String(result.scene_label || screen.promptEditContext.sceneId || "scene"),
                        sceneIndex: Number(result.scene_index !== undefined ? result.scene_index : -1),
                        promptPreview: String(prompt || "")
                    }
                    masterSceneRegenDialog.open()
                }
                return
            }
            promptEditDialog.applySaveResult(masterController.updateRow(rowId, title, prompt), prompt)
        }
    }

    component CappedPromptPreview: Rectangle {
        id: previewRoot
        property string promptText: ""

        implicitHeight: VfTheme.dp(180)
        radius: VfTheme.dp(8)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.border
        clip: true

        ScrollView {
            id: previewScroll
            anchors.fill: parent
            anchors.margins: VfTheme.dp(10)
            clip: true
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Text {
                width: previewScroll.availableWidth
                text: previewRoot.promptText
                wrapMode: Text.Wrap
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
            }
        }
    }

    Dialog {
        id: masterSceneRegenDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(480), VfTheme.dp(48))
        height: {
            var maxH = VfDialogMetrics.height(parent, VfTheme.dp(460), VfTheme.dp(48))
            return masterSceneRegenDialog.showPromptPreview ? maxH : Math.min(VfTheme.dp(220), maxH)
        }
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape
        onClosed: screen.pendingSceneRegen = ({})

        readonly property string regenReason: String((screen.pendingSceneRegen || {}).reason || "prompt_edit")
        readonly property string regenPrompt: String((screen.pendingSceneRegen || {}).promptPreview || "")
        readonly property bool showPromptPreview: regenReason !== "prompt_edit" && regenPrompt.length > 0

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.border
            clip: true
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("generation.regenerate_video", "Regenerate Video"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: {
                    if (masterSceneRegenDialog.regenReason === "prompt_edit")
                        return (void i18n.revision, i18n.t("master_prompt.prompt_updated_regen_confirm", "Prompt updated. Regenerate now?"))
                    var indexValue = Number((screen.pendingSceneRegen || {}).sceneIndex)
                    var sceneLabel = !isNaN(indexValue) && indexValue >= 0
                        ? String(indexValue + 1)
                        : String((screen.pendingSceneRegen || {}).sceneLabel || "scene")
                    var raw = (void i18n.revision, i18n.t(
                        "master_prompt.confirm_regen_scene",
                        "Regenerate scene {index} now?\n\nPrompt: {prompt}"
                    ))
                    return String(raw).split("\n")[0].replace("{index}", sceneLabel)
                }
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            CappedPromptPreview {
                visible: masterSceneRegenDialog.showPromptPreview
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: VfTheme.dp(120)
                promptText: masterSceneRegenDialog.regenPrompt
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.no", "No"))
                    onClicked: masterSceneRegenDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.yes", "Yes"))
                    tone: "primary"
                    onClicked: {
                        // Capture before close: onClosed clears pendingSceneRegen.
                        var jobId = String(screen.pendingSceneRegen.jobId || "")
                        var sceneId = String(screen.pendingSceneRegen.sceneId || "")
                        var rowId = String(screen.pendingSceneRegen.rowId || "")
                        var result = masterController.regenSceneJob(
                            jobId,
                            sceneId,
                            rowId
                        )
                        masterSceneRegenDialog.close()
                        screen.applySceneRegenResult(result)
                    }
                }
            }
        }
    }

    Dialog {
        id: masterSceneDeleteDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(480), VfTheme.dp(48))
        height: {
            var maxH = VfDialogMetrics.height(parent, VfTheme.dp(460), VfTheme.dp(48))
            return masterSceneDeleteDialog.showPromptPreview ? maxH : Math.min(VfTheme.dp(220), maxH)
        }
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape
        onClosed: screen.pendingSceneDelete = ({})

        readonly property string deletePrompt: String((screen.pendingSceneDelete || {}).promptPreview || "")
        readonly property bool showPromptPreview: deletePrompt.length > 0

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.border
            clip: true
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: {
                    var raw = (void i18n.revision, i18n.t(
                        "master_prompt.confirm_delete_job",
                        "Delete this generated scene job?\n\nPrompt: {prompt}"
                    ))
                    return String(raw).split("\n")[0]
                }
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            CappedPromptPreview {
                visible: masterSceneDeleteDialog.showPromptPreview
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: VfTheme.dp(120)
                promptText: masterSceneDeleteDialog.deletePrompt
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.no", "No"))
                    onClicked: masterSceneDeleteDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.yes", "Yes"))
                    tone: "danger"
                    onClicked: {
                        masterSceneDeleteDialog.close()
                        screen.applyRemoveRowResult(
                            masterController.deleteSceneJob(String(screen.pendingSceneDelete.jobId || ""))
                        )
                    }
                }
            }
        }
    }

    ChargenPolicyDialog {
        id: chargenPolicyDialog
        property string policyRowId: ""
        onRetryRequested: editedCharacters => chargenPolicyDialog.applyRetryResult(
            masterController.retryChargenPolicy(policyRowId, editedCharacters)
        )
        onSkipRequested: {
            if (chargenPolicyDialog.policyRowId.length > 0)
                masterController.skipChargenPolicy(chargenPolicyDialog.policyRowId)
            policyRowId = ""
        }
        onClosed: {
            if (!visible)
                policyRowId = ""
        }
    }

    Dialog {
        id: masterQueueDeleteDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(460), VfTheme.dp(48))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: {
                    var row = screen.pendingDeleteRow || ({})
                    var title = String(row.name || row.idea || row.id || row.row_id || "")
                    var templateName = String(row.template || row.template_name || "N/A")
                    var status = String(row.status || (void i18n.revision, i18n.t("common.pending", "Pending")))
                    if (status.toLowerCase() === "running") {
                        return (void i18n.revision, i18n.t("queue.confirm_cancel_running_job_msg",
                            "This job is running!\n\nTitle: {title}\nStatus: {status}\n\nAre you sure you want to CANCEL and DELETE this job?\nJob will be stopped immediately!"))
                            .replace("{title}", title)
                            .replace("{status}", status)
                    }
                    return (void i18n.revision, i18n.t("dialog.confirm_delete_job_queue",
                        "Are you sure you want to delete this job?\n\nTitle: {title}\nTemplate: {template}\nStatus: {status}\n\nThis action cannot be undone!"))
                        .replace("{title}", title)
                        .replace("{template}", templateName)
                        .replace("{status}", status)
                }
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: masterQueueDeleteDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                    tone: "danger"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        var pendingStatus = String(((screen.pendingDeleteRow || {}).status) || "").toLowerCase()
                        if (pendingStatus === "running") {
                            screen.masterQueueLifecycleArmed = false
                            screen.masterQueueLifecycleWasActive = false
                        }
                        var rowId = screen.rowId(screen.pendingDeleteRow)
                        masterQueueDeleteDialog.close()
                        screen.applyRemoveRowResult(masterController.removeRow(rowId))
                    }
                }
            }
        }

        onClosed: screen.pendingDeleteRow = ({})
    }

    Dialog {
        id: masterQueueClearDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(480), VfTheme.dp(48))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("dialog.confirm_delete_all_queue",
                    "Are you sure you want to delete ALL jobs in queue?\n\nTotal: {total} job(s)\nPending: {pending}\nRunning: {running}\nCompleted: {completed}\nFailed: {failed}\n\nThis action cannot be undone!"))
                    .replace("{total}", String(screen.queueCount("total")))
                    .replace("{pending}", String(screen.queueCount("pending")))
                    .replace("{running}", String(screen.queueCount("generating")))
                    .replace("{completed}", String(screen.queueCount("completed")))
                    .replace("{failed}", String(screen.queueCount("failed")))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: masterQueueClearDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.delete_all", "Delete All"))
                    tone: "danger"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        screen.masterQueueLifecycleArmed = false
                        screen.masterQueueLifecycleWasActive = false
                        masterQueueClearDialog.close()
                        screen.applyClearQueueResult(masterController.clearQueue())
                    }
                }
            }
        }
    }

    QueuePreflightDialog {
        id: queuePreflightDialog
        route: "master"
        onConfirmed: screen.doAddToQueue()
    }

    // Thư viện media để thay asset cho slot job panel (dùng chung dữ liệu media
    // qua workPanelController — thư viện media là toàn cục, không theo route).
    MediaLibraryDialog {
        id: masterAssetLibraryDialog
        items: (visible && typeof workPanelController !== "undefined" && workPanelController) ? workPanelController.mediaLibraryItems : []
        stats: (typeof workPanelController !== "undefined" && workPanelController) ? workPanelController.mediaLibraryStats : ({})
        settings: (typeof workPanelController !== "undefined" && workPanelController) ? workPanelController.mediaLibrarySettings : ({})
        onRefreshRequested: (search, assetType) => {
            if (typeof workPanelController !== "undefined" && workPanelController
                && typeof workPanelController.refreshMediaLibrary === "function")
                workPanelController.refreshMediaLibrary(search, assetType || "")
        }
        onMediaSelected: selection => {
            var ids = (selection && (selection.mediaIds || selection.media_ids)) || []
            var mediaId = ids.length > 0 ? String(ids[0]) : ""
            var jobId = screen.pendingAssetRowId
            if (mediaId.length > 0 && jobId.length > 0)
                masterController.replaceRowAsset(jobId, screen.pendingAssetSlot, mediaId)
            screen.pendingAssetRowId = ""
            screen.pendingAssetSlot = -1
            masterAssetLibraryDialog.close()
            screen.refreshPromptEditorAssets(jobId)
        }
    }

    Dialog {
        id: masterQueueStartDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(480), VfTheme.dp(48))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: {
                    var total = screen.queueCount("total")
                    var pendingScript = screen.queueCount("pending_script")
                    var pending = screen.queueCount("pending")
                    var failed = screen.queueCount("failed")
                    var details = []
                    if (pendingScript > 0)
                        details.push((void i18n.revision, i18n.t("master_prompt.pending_script_count", "{count} pending script")).replace("{count}", String(pendingScript)))
                    if (pending > 0)
                        details.push((void i18n.revision, i18n.t("master_prompt.pending_count", "{count} pending")).replace("{count}", String(pending)))
                    if (failed > 0)
                        details.push((void i18n.revision, i18n.t("master_prompt.failed_retry_count", "{count} failed (retry)")).replace("{count}", String(failed)))
                    return (void i18n.revision, i18n.t("master_prompt.start_processing_confirm",
                        "Start processing {total} queue job(s)?\n\n{details}"))
                        .replace("{total}", String(total))
                        .replace("{details}", details.join("\n"))
                }
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: masterQueueStartDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("master.start_processing", "Start Processing"))
                    tone: "primary"
                    minWidth: VfTheme.dp(132)
                    onClicked: {
                        masterQueueStartDialog.close()
                        screen.applyStartQueueResult(masterController.startQueue())
                    }
                }
            }
        }
    }

    Dialog {
        id: masterQueueFeedbackDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(48))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(8)
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
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: screen.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: masterQueueFeedbackDialog.close()
                }
            }
        }
    }

    Dialog {
        id: ideaConfirmDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(500), VfTheme.dp(48))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        property var pendingItems: []

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("master.confirm_ideas_title", "Confirm Ideas"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.DemiBold
            }

            // Action bar: Add, Split All, Merge All
            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)

                VfButton {
                    text: (void i18n.revision, i18n.t("master.idea_add", "+ Add"))
                    minWidth: VfTheme.dp(70)
                    onClicked: {
                        var arr = ideaConfirmDialog.pendingItems.slice()
                        arr.push("")
                        ideaConfirmDialog.pendingItems = arr
                    }
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("master.idea_split_all", "Split All"))
                    minWidth: VfTheme.dp(82)
                    onClicked: {
                        var arr = []
                        for (var i = 0; i < ideaConfirmDialog.pendingItems.length; i++) {
                            var lines = String(ideaConfirmDialog.pendingItems[i] || "").split("\n")
                            for (var j = 0; j < lines.length; j++) {
                                var l = lines[j].trim()
                                if (l.length > 0)
                                    arr.push(l)
                            }
                        }
                        if (arr.length === 0)
                            arr = ideaConfirmDialog.pendingItems.slice()
                        ideaConfirmDialog.pendingItems = arr
                    }
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("master.idea_merge_all", "Merge All"))
                    minWidth: VfTheme.dp(88)
                    onClicked: {
                        var joined = ideaConfirmDialog.pendingItems.join("\n")
                        ideaConfirmDialog.pendingItems = [joined]
                    }
                }

                Item { Layout.fillWidth: true }
            }

            // Scrollable list of idea rows
            Rectangle {
                Layout.fillWidth: true
                height: Math.min(300, ideaListColumn.implicitHeight + 8)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border
                radius: VfTheme.dp(6)
                clip: true

                Flickable {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(4)
                    contentHeight: ideaListColumn.implicitHeight
                    flickableDirection: Flickable.VerticalFlick
                    clip: true

                    Column {
                        id: ideaListColumn
                        width: parent.width
                        spacing: VfTheme.dp(4)

                        Repeater {
                            model: ideaConfirmDialog.pendingItems.length

                            delegate: RowLayout {
                                id: ideaRow
                                required property int index
                                width: ideaListColumn.width
                                spacing: VfTheme.dp(4)

                                TextInput {
                                    Layout.fillWidth: true
                                    text: String(ideaConfirmDialog.pendingItems[ideaRow.index] || "")
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontControl
                                    padding: VfTheme.dp(6)
                                    wrapMode: TextInput.WrapAnywhere

                                    ContextMenu.menu: VfTextEditingContextMenu {
                                        editor: parent
                                    }
                                    onTextEdited: {
                                        var arr = ideaConfirmDialog.pendingItems.slice()
                                        arr[ideaRow.index] = text
                                        ideaConfirmDialog.pendingItems = arr
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: VfTheme.surface
                                        border.color: VfTheme.borderStrong
                                        radius: VfTheme.dp(4)
                                        z: -1
                                    }
                                }

                                // Move Up
                                VfAppIcon {
                                    name: "chevron-up"
                                    size: VfTheme.dp(16)
                                    framed: false
                                    color: ideaRow.index > 0 ? "#60A5FA" : VfTheme.borderStrong
                                    anchors.verticalCenter: parent.verticalCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (ideaRow.index === 0)
                                                return
                                            var arr = ideaConfirmDialog.pendingItems.slice()
                                            var tmp = arr[ideaRow.index - 1]
                                            arr[ideaRow.index - 1] = arr[ideaRow.index]
                                            arr[ideaRow.index] = tmp
                                            ideaConfirmDialog.pendingItems = arr
                                        }
                                    }
                                }

                                // Move Down
                                VfAppIcon {
                                    name: "chevron-down"
                                    size: VfTheme.dp(16)
                                    framed: false
                                    color: ideaRow.index < ideaConfirmDialog.pendingItems.length - 1 ? "#60A5FA" : VfTheme.borderStrong
                                    anchors.verticalCenter: parent.verticalCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (ideaRow.index >= ideaConfirmDialog.pendingItems.length - 1)
                                                return
                                            var arr = ideaConfirmDialog.pendingItems.slice()
                                            var tmp = arr[ideaRow.index + 1]
                                            arr[ideaRow.index + 1] = arr[ideaRow.index]
                                            arr[ideaRow.index] = tmp
                                            ideaConfirmDialog.pendingItems = arr
                                        }
                                    }
                                }

                                // Remove
                                VfAppIcon {
                                    name: "cross-mark"
                                    size: VfTheme.dp(16)
                                    framed: false
                                    color: "#EF4444"
                                    anchors.verticalCenter: parent.verticalCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var arr = ideaConfirmDialog.pendingItems.slice()
                                            arr.splice(ideaRow.index, 1)
                                            ideaConfirmDialog.pendingItems = arr
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(80)
                    onClicked: ideaConfirmDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    tone: "primary"
                    minWidth: VfTheme.dp(80)
                    onClicked: {
                        var items = ideaConfirmDialog.pendingItems.slice()
                        ideaConfirmDialog.close()
                        screen.applyAddInputResult(masterController.addInputItems(
                            items,
                            screen.inputMode,
                            screen.extraRequirementsEnabled ? extraRequirementsInput.text : "",
                            screen.saveAiCharacters
                        ))
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        Qt.callLater(function() {
            masterController.refresh()
            masterOptionsController.refresh()
        })
    }
}
