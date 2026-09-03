import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../dialogs"
import "../theme"

Item {
    id: screen
    objectName: "researchScreen"

    // ── Output display model (right pane) ───────────────────────────
    // group: "research" | "script" | "production"
    property string outputGroup: "research"
    // Tự chọn: có báo cáo → hiện báo cáo, chưa có → kế hoạch (bỏ pill bật tay)
    readonly property string researchSub: researchController.reportMarkdown.length > 0 ? "report" : "plan"
    property string productionSub: "audio"  // audio | metadata | asset
    property bool opsOpen: false
    property string opsView: "history"       // history | queue | schedule
    // Derived legacy view string (used by chat target + ResultTab def)
    readonly property string resultView: outputGroup === "script"
        ? "script"
        : (outputGroup === "research" ? researchSub : productionSub)

    // Map an action's target token to (group, sub) and switch the display.
    function showOutput(view) {
        var v = String(view || "")
        if (v === "plan" || v === "report" || v === "evidence" || v === "lab") { outputGroup = "research" }
        else if (v === "script") { outputGroup = "script" }
        // "Sản xuất" bỏ khỏi Research Labs (đi thẳng Audio-to-Video). Audio/metadata/asset
        // = output phụ → về tab Nghiên cứu, không còn group "production" riêng.
        else if (v === "audio" || v === "metadata" || v === "knowledge" || v === "assets" || v === "asset") { outputGroup = "research" }
        else if (v === "history") { opsView = "history"; opsOpen = true }
        else if (v === "queue") { opsView = "queue"; opsOpen = true }
        else if (v === "schedule") { opsView = "schedule"; opsOpen = true }
    }

    // Default display for a step when navigating the wizard manually.
    // 2-step model: 0 Nghiên cứu · 1 Sản xuất (kịch bản + giọng đọc + xuất bản)
    function gotoStepView(idx) {
        if (idx === 0) screen.showOutput("report")
        else screen.showOutput("script")
    }

    property string plannerTemplateId: plannerStore.templateId
    property var uploadedFiles: []
    property var lastAction: researchController.lastAction || ({})
    property int currentStep: 0
    property var stepDone: [false, false]
    // Pha panel trái: "research" (chuẩn bị + chạy nghiên cứu) | "produce" (cấu hình sản xuất).
    // Dialogue = 2 giọng (hiện Giọng 2 + người nói). Suy từ định dạng kịch bản.
    // Cấu hình TTS fallback — KHÔNG còn UI (Audio Overview là đường audio duy nhất
    // người dùng thấy; script→TTS chỉ chạy ngầm khi Overview lỗi). Template vẫn nạp được.
    property var ttsFallback: ({
        script_format: "dialogue",
        duration: "auto",
        voice_name: "Kore",
        voice2_name: "Zephyr",
        speaker1: "host",
        speaker2: "expert",
        tts_provider: "gemini",
        tts_model: "gemini-3.1-flash-tts-preview",
        tts_preset: "warm_narrator",
        tts_director_notes: ""
    })
    // Quality gate: production (script/TTS/publish) locked until content approved.
    property bool contentApproved: false
    // Nguồn chủ đề: "question" (nhập câu hỏi) | "document" (từ tài liệu)
    property string topicSource: "question"
    property string templateStyleGuide: ""
    property string templateSaveName: ""

    // Đồng hồ đếm giây khi job chạy — cảm giác realtime giữa 2 nhịp poll
    property int runningElapsedSec: 0
    Timer {
        interval: 1000
        repeat: true
        running: researchController.activeJobRunning === true
        onRunningChanged: if (running) screen.runningElapsedSec = 0
        onTriggered: screen.runningElapsedSec = screen.runningElapsedSec + 1
    }
    Connections {
        target: researchController

        function onActiveRunningChanged() {
            var status = String(researchController.activeJobStatus || "")
            if (status === "running") {
                screen.contentApproved = false
                screen.stepDone = [false, false]
                screen.currentStep = 0
            } else if (status === "complete" && researchController.reportMarkdown.length > 0) {
                var productionReady = researchController.scriptText.length > 0
                screen.contentApproved = productionReady
                screen.stepDone = [true, productionReady]
                screen.currentStep = productionReady ? 1 : 0
            } else if (status === "failed" || status === "paused" || status === "cancelled") {
                screen.contentApproved = false
            }
        }
    }

    // Bắt đầu = LUÔN auto cả pipeline: nghiên cứu → podcast → (auto import).
    // Không duyệt tay giữa chừng; chỉnh sửa = chat sau khi có báo cáo, chốt = tạo lại podcast.
    function startResearch() {
        screen.runAutoProduction("report")
    }

    function advanceStep(toStep) {
        var done = screen.stepDone.slice()
        if (screen.currentStep >= 0 && screen.currentStep < done.length)
            done[screen.currentStep] = true
        screen.stepDone = done
        screen.currentStep = toStep
    }
    // Tên ngôn ngữ để bản địa (tự nhận diện, không cần dịch)
    property var languageOptions: [
        { label: "Tiếng Việt", value: "vi", flag: "vn" },
        { label: "English", value: "en", flag: "us" },
        { label: "日本語", value: "ja", flag: "jp" },
        { label: "한국어", value: "ko", flag: "kr" },
        { label: "中文", value: "zh", flag: "cn" },
        { label: "Français", value: "fr", flag: "fr" },
        { label: "Deutsch", value: "de", flag: "de" },
        { label: "Español", value: "es", flag: "es" },
        { label: "ไทย", value: "th", flag: "th" },
        { label: "Português", value: "pt", flag: "pt" },
        { label: "Русский", value: "ru", flag: "ru" },
        { label: "العربية", value: "ar", flag: "sa" },
        { label: "हिन्दी", value: "hi", flag: "in" },
        { label: "Bahasa Indonesia", value: "id", flag: "id" },
        { label: "Türkçe", value: "tr", flag: "tr" }
    ]
    property var durationOptions: [
        { label: (void i18n.revision, i18n.t("deep_research.duration_auto", "Tự động")), value: "auto" },
        { label: (void i18n.revision, i18n.t("deep_research.duration_5", "5 min")), value: "5" },
        { label: (void i18n.revision, i18n.t("deep_research.duration_10", "10 min")), value: "10" },
        { label: (void i18n.revision, i18n.t("deep_research.duration_15", "15 min")), value: "15" },
        { label: (void i18n.revision, i18n.t("deep_research.duration_30", "30 min")), value: "30" },
        { label: (void i18n.revision, i18n.t("deep_research.duration_60", "60 min")), value: "60" }
    ]
    property var formatOptions: [
        { label: (void i18n.revision, i18n.t("deep_research.format_monologue", "Monologue")), value: "monologue" },
        { label: (void i18n.revision, i18n.t("deep_research.format_dialogue", "Dialogue")), value: "dialogue" }
    ]
    property var ttsVoiceOptions: [
        { label: (void i18n.revision, i18n.t("deep_research.voice_kore", "Kore — chắc giọng")), value: "Kore" },
        { label: (void i18n.revision, i18n.t("deep_research.voice_zephyr", "Zephyr — tươi sáng")), value: "Zephyr" },
        { label: (void i18n.revision, i18n.t("deep_research.voice_puck", "Puck — sôi nổi")), value: "Puck" },
        { label: (void i18n.revision, i18n.t("deep_research.voice_charon", "Charon — trầm tĩnh")), value: "Charon" }
    ]
    property var speakerRoleOptions: [
        { label: (void i18n.revision, i18n.t("deep_research.speaker_host", "Người dẫn (Host)")), value: "host" },
        { label: (void i18n.revision, i18n.t("deep_research.speaker_expert", "Chuyên gia")), value: "expert" },
        { label: (void i18n.revision, i18n.t("deep_research.speaker_narrator", "Người kể chuyện")), value: "narrator" }
    ]

    PlannerDataStore {
        id: plannerStore
        controller: researchController
        hostPath: researchController.plannerStorePath
    }

    function templateOptions() {
        var items = plannerStore.templates || []
        var output = [
            { label: (void i18n.revision, i18n.t("deep_research.no_template", "No template")), value: "" }
        ]
        for (var i = 0; i < items.length; i++) {
            var item = items[i] || ({})
            output.push({
                label: String(item.name || item.id || "Template"),
                value: String(item.id || "")
            })
        }
        if (output.length === 0)
            output.push({ label: "General Research", value: "general" })
        return output
    }

    function templateIndex(value) {
        var items = screen.templateOptions()
        for (var i = 0; i < items.length; i++) {
            if (String(items[i].value) === String(value))
                return i
        }
        return items.length > 0 ? 0 : -1
    }

    function currentTopic() {
        return String(topicInput.text || "").trim()
    }

    function effectiveTopic() {
        var typed = screen.currentTopic()
        if (typed.length > 0)
            return typed
        if (screen.topicSource === "document" && screen.uploadedFiles.length > 0) {
            return String(languageSelect.value || "vi") === "vi"
                ? "Nghiên cứu, đối chiếu và tổng hợp nội dung từ các tài liệu đính kèm"
                : "Research, cross-check, and synthesize the attached documents"
        }
        return ""
    }

    function optionLabel(options, value) {
        var items = options || []
        for (var i = 0; i < items.length; i++) {
            var item = items[i] || ({})
            if (String(item.value) === String(value))
                return String(item.label || item.value || "")
        }
        return String(value || "")
    }

    function _optionValue(options, rawValue) {
        var normalized = String(rawValue || "").trim()
        if (!normalized.length)
            return ""
        var lowered = normalized.toLowerCase()
        var items = options || []
        for (var i = 0; i < items.length; i++) {
            var item = items[i] || ({})
            if (String(item.value || "").toLowerCase() === lowered)
                return String(item.value || "")
            if (String(item.label || "").toLowerCase() === lowered)
                return String(item.value || "")
        }
        return ""
    }

    function _speakerRoleValue(rawValue, fallbackValue) {
        var normalized = String(rawValue || "").trim()
        if (!normalized.length)
            return String(fallbackValue || "host")
        var direct = screen._optionValue(screen.speakerRoleOptions, normalized)
        if (direct.length > 0)
            return direct
        var lowered = normalized.toLowerCase()
        if (lowered.indexOf("narrat") !== -1 || lowered.indexOf("detective") !== -1 || lowered.indexOf("investigator") !== -1 || lowered.indexOf("traveler") !== -1 || lowered.indexOf("teacher") !== -1 || lowered.indexOf("scientist") !== -1)
            return "narrator"
        if (lowered.indexOf("guest") !== -1 || lowered.indexOf("expert") !== -1 || lowered.indexOf("reporter") !== -1 || lowered.indexOf("witness") !== -1 || lowered.indexOf("source") !== -1 || lowered.indexOf("guide") !== -1 || lowered.indexOf("analyst") !== -1 || lowered.indexOf("defense") !== -1)
            return "expert"
        return String(fallbackValue || "host")
    }

    function _durationTemplateValue(rawValue) {
        var normalized = String(rawValue || "").trim()
        if (!normalized.length)
            return String(screen.ttsFallback.duration || "auto")
        var direct = screen._optionValue(screen.durationOptions, normalized)
        if (direct.length > 0)
            return direct
        var numeric = Math.round(Number(normalized))
        if (!isNaN(numeric)) {
            var optionValue = screen._optionValue(screen.durationOptions, String(numeric))
            if (optionValue.length > 0)
                return optionValue
        }
        return String(screen.ttsFallback.duration || "auto")
    }

    function _applyTemplate(templateData, topicOverride) {
        var template = templateData || ({})
        var existingTopic = String(topicOverride || topicInput.text || "").trim()
        var prompt = String(template.research_prompt || "").trim()
        if (prompt.length > 0) {
            if (prompt.indexOf("{topic}") !== -1 && existingTopic.length > 0)
                prompt = prompt.split("{topic}").join(existingTopic)
            topicInput.text = prompt
        }

        // Template nạp vào cấu hình TTS fallback (không còn UI riêng)
        var fb = JSON.parse(JSON.stringify(screen.ttsFallback))
        var formatValue = screen._optionValue(screen.formatOptions, template.script_format)
        if (formatValue.length > 0)
            fb.script_format = formatValue
        var voiceOne = screen._optionValue(screen.ttsVoiceOptions, template.voice_name)
        if (voiceOne.length > 0)
            fb.voice_name = voiceOne
        var voiceTwo = screen._optionValue(screen.ttsVoiceOptions, template.voice2_name)
        if (voiceTwo.length > 0)
            fb.voice2_name = voiceTwo
        fb.speaker1 = screen._speakerRoleValue(template.speaker1, fb.speaker1 || "host")
        fb.speaker2 = screen._speakerRoleValue(template.speaker2, fb.speaker2 || "expert")
        fb.tts_director_notes = String(template.tts_director_notes || "").trim()
        screen.templateStyleGuide = String(template.script_prompt || "").trim()
        var durationValue = screen._durationTemplateValue(template.target_duration_minutes)
        if (durationValue.length > 0)
            fb.duration = durationValue
        screen.ttsFallback = fb
    }

    function applyTemplate(templateData, topicOverride) {
        var template = templateData || ({})
        if (!String(template.id || plannerTemplateId || "").trim().length)
            return false
        screen._applyTemplate(template, topicOverride)
        if (String(topicInput.text || "").trim().length > 0)
            researchController.assessTopicAsync(topicInput.text, languageSelect.value)
        screen.showOutput("plan")
        return true
    }

    function saveTemplate() {
        var templateName = String(screen.templateSaveName || "").trim()
        if (!templateName.length)
            return false
        var selectedTemplate = plannerStore.selectedTemplate || ({})
        var result = researchController.saveTemplate(
            {
                name: templateName,
                template_id: plannerStore.templateId,
                research_prompt: String(topicInput.text || "").trim(),
                metadata_prompt: String(selectedTemplate.metadata_prompt || "").trim(),
                script_prompt: String(screen.templateStyleGuide || "").trim(),
                script_format: String(screen.ttsFallback.script_format || "monologue"),
                tts_audio_profile: String(selectedTemplate.tts_audio_profile || "").trim(),
                tts_scene: String(selectedTemplate.tts_scene || "").trim(),
                tts_director_notes: String(screen.ttsFallback.tts_director_notes || "").trim(),
                voice_name: String(screen.ttsFallback.voice_name || "Kore"),
                voice2_name: String(screen.ttsFallback.voice2_name || "Zephyr"),
                speaker1: screen.optionLabel(screen.speakerRoleOptions, screen.ttsFallback.speaker1),
                speaker2: screen.optionLabel(screen.speakerRoleOptions, screen.ttsFallback.speaker2)
            }
        )
        if (result && result.ok) {
            screen.templateSaveName = ""
            plannerStore.refresh(String(result.template_id || ""))
        }
        return Boolean(result && result.ok)
    }

    function deleteTemplate() {
        var selectedTemplate = plannerStore.selectedTemplate || ({})
        if (String(selectedTemplate.category || "") !== "custom")
            return false
        var result = researchController.deleteTemplate(String(selectedTemplate.id || ""))
        if (result && result.ok)
            plannerStore.refresh("")
        return Boolean(result && result.ok)
    }


    function metadataTitles() {
        var titles = (screen.lastAction || {}).titles || (((screen.lastAction || {}).metadata || {}).titles) || []
        if ((!titles || titles.length === 0) && String((((screen.lastAction || {}).metadata || {}).title || "")).trim().length > 0)
            titles = [String(((screen.lastAction || {}).metadata || {}).title).trim()]
        return titles || []
    }

    function metadataDescriptions() {
        var descriptions = (screen.lastAction || {}).descriptions || (((screen.lastAction || {}).metadata || {}).descriptions) || []
        if ((!descriptions || descriptions.length === 0) && String((((screen.lastAction || {}).metadata || {}).description || "")).trim().length > 0)
            descriptions = [String(((screen.lastAction || {}).metadata || {}).description).trim()]
        return descriptions || []
    }

    function metadataThumbnailPrompts() {
        var thumbnail_prompts = (screen.lastAction || {}).thumbnail_prompts || (((screen.lastAction || {}).metadata || {}).thumbnail_prompts) || []
        if ((!thumbnail_prompts || thumbnail_prompts.length === 0) && String((((screen.lastAction || {}).metadata || {}).thumbnail_prompt || "")).trim().length > 0)
            thumbnail_prompts = [String(((screen.lastAction || {}).metadata || {}).thumbnail_prompt).trim()]
        return thumbnail_prompts || []
    }

    function currentNotes() {
        var notes = []
        if (String(screen.templateStyleGuide || "").trim().length > 0)
            notes.push("Template notes: " + screen.templateStyleGuide)
        if (String(screen.ttsFallback.tts_director_notes || "").trim().length > 0)
            notes.push("Director notes: " + screen.ttsFallback.tts_director_notes)
        if (screen.uploadedFiles.length > 0)
            notes.push("Context files: " + screen.uploadedFiles.join("; "))
        return notes.join("\n")
    }

    function currentResearchConfig(autoImport) {
        var tpl = researchController.plannerTemplate || ({})
        return {
            language: String(languageSelect.value || "vi"),
            duration: String(screen.ttsFallback.duration || "auto"),
            script_format: String(screen.ttsFallback.script_format || "dialogue"),
            voice_name: String(screen.ttsFallback.voice_name || "Kore"),
            voice2_name: String(screen.ttsFallback.voice2_name || "Zephyr"),
            speaker1: screen.optionLabel(screen.speakerRoleOptions, screen.ttsFallback.speaker1),
            speaker2: screen.optionLabel(screen.speakerRoleOptions, screen.ttsFallback.speaker2),
            tts_provider: String(screen.ttsFallback.tts_provider || "gemini"),
            tts_model: String(screen.ttsFallback.tts_model || "gemini-3.1-flash-tts-preview"),
            tts_preset: String(screen.ttsFallback.tts_preset || "warm_narrator"),
            tts_director_notes: String(screen.ttsFallback.tts_director_notes || "").trim(),
            // Đường audio CHÍNH = script→TTS của mình: tin cậy + sinh SRT chi tiết cho
            // A2V (Audio Overview của Gemini harvest ngẫu nhiên, không ra SRT — chỉ để
            // dành làm tuỳ chọn). SRT = voiceover research giàu → scene A2V bám sát.
            audio_route: "tts",
            context_files: screen.uploadedFiles,
            // script prompt from selected template
            script_prompt: String(screen.templateStyleGuide || tpl.script_prompt || "").trim(),
            metadata_prompt: String(tpl.metadata_prompt || "").trim(),
            // research prompt (template angle/focus) — injected into the Deep Research query
            research_prompt: String(tpl.research_prompt || "").trim(),
            market_code: "global",
            quality_mode: true,
            auto_import: autoImport === true
        }
    }

    function runStep(step, targetView) {
        var result = researchController.runStepForTopicConfigured(
            screen.effectiveTopic(),
            step,
            screen.currentResearchConfig(false)
        )
        if (result && (result.ok || result.blocked) && targetView && targetView.length > 0)
            screen.showOutput(targetView)
        if (result && result.ok) {
            // 2-step map: 0 Nghiên cứu · 1 Sản xuất
            if (step === "script" || step === "tts") screen.currentStep = 1
            // plan/research stay on step 0 (research phase)
        }
    }

    function runAutoProduction(targetView) {
        var result = researchController.runAutoConfigured(
            screen.effectiveTopic(),
            screen.currentResearchConfig(true)
        )
        if (result && (result.ok || result.blocked) && targetView && targetView.length > 0)
            screen.showOutput(targetView)
        if (result && result.ok) {
            // Accepted is not completed. The controller's terminal status signal
            // unlocks Production only after report + script have reached QML.
            screen.contentApproved = false
            screen.stepDone = [false, false]
            screen.currentStep = 0
        }
    }

    function loadHistoryEntry(jobId, targetView) {
        var result = researchController.loadHistory(jobId)
        if (result && result.ok && targetView && targetView.length > 0)
            screen.showOutput(targetView)
    }

    function loadScriptHistory(jobId) {
        var result = researchController.loadScriptHistory(jobId)
        if (result && result.ok)
            screen.showOutput("script")
    }

    function runAssetPack(targetView) {
        var result = researchController.generateAssetPack(
            screen.effectiveTopic(),
            screen.currentNotes()
        )
        if (result && result.ok && targetView && targetView.length > 0)
            screen.showOutput(targetView)
    }

    function runMetadata(targetView) {
        var result = researchController.extractMetadata(
            screen.effectiveTopic(),
            researchController.reportMarkdown,
            screen.currentNotes(),
            languageSelect.value
        )
        if (result && (result.ok || result.blocked) && targetView && targetView.length > 0)
            screen.showOutput(targetView)
    }

    function approveResearch(targetView) {
        var result = researchController.approveContent(
            screen.effectiveTopic(),
            screen.currentNotes()
        )
        if (result && (result.ok || result.blocked) && targetView && targetView.length > 0)
            screen.showOutput(targetView)
        // Audio Overview là MẶC ĐỊNH: duyệt báo cáo xong tự tạo podcast, không cần nút riêng
        if (result && result.ok && researchController.reportMarkdown.length > 0)
            screen.runStep("audio_overview", "report")
    }

    function requestMoreResearch(targetView) {
        var result = researchController.requestMoreResearch(
            screen.effectiveTopic(),
            screen.currentNotes()
        )
        if (result && (result.ok || result.blocked) && targetView && targetView.length > 0)
            screen.showOutput(targetView)
    }

    function sendChatMessage() {
        var message = String(reportChatInput.text || "").trim()
        if (message.length === 0)
            return
        var result = researchController.sendChat(
            message,
            screen.resultView,
            screen.effectiveTopic(),
            screen.currentNotes()
        )
        if (result && (result.ok || result.blocked))
            reportChatInput.text = ""
    }

    function pickResearchFiles() {
        var picked = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("deep_research.upload_title", "Upload research files")),
            (void i18n.revision, i18n.t("deep_research.file_filter_research", "Research Files (*.txt *.md *.pdf *.docx *.json);;All Files (*.*)")),
            ""
        )
        if (!picked || !picked.ok)
            return
        var next = screen.uploadedFiles.slice()
        var paths = picked.paths || []
        for (var i = 0; i < paths.length; i++) {
            var path = String(paths[i] || "")
            if (path.length > 0 && next.indexOf(path) < 0)
                next.push(path)
        }
        screen.uploadedFiles = next
        researchController.captureContextFiles(next)
    }

    function removeLastResearchFile() {
        if (screen.uploadedFiles.length === 0)
            return
        var next = screen.uploadedFiles.slice()
        next.pop()
        screen.uploadedFiles = next
        researchController.captureContextFiles(next)
    }

    Rectangle {
        anchors.fill: parent
        color: VfTheme.canvas
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // ══ PANEL TRÁI — 1 mạch dọc 3 block (cuộn) · action bar dính đáy ══
        Rectangle {
            Layout.preferredWidth: Math.max(460, Math.min(780, Math.round(screen.width * 0.38)))
            Layout.fillHeight: true
            color: VfTheme.surfaceSoft

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                ScrollView {
                    id: leftScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: VfTheme.dp(6)
                            radius: VfTheme.dp(3)
                            color: VfTheme.borderStrong
                        }
                        background: Rectangle { color: "transparent" }
                    }
                    contentWidth: leftColumn.width
                    contentHeight: leftColumn.implicitHeight

                    ColumnLayout {
                        id: leftColumn
                        width: leftScroll.availableWidth - VfTheme.dp(16)
                        x: VfTheme.dp(8)
                        spacing: VfTheme.dp(8)

                        Item { Layout.preferredHeight: VfTheme.dp(1) }

                        // ── BLOCK 1: Chủ đề ──
                        BlockCard {
                            id: topicCard
                            number: "1"
                            title: (void i18n.revision, i18n.t("research_screen.block_topic", "Chủ đề"))

                            // ── IDEA — nguồn chủ đề ──
                            RowLayout {
                                objectName: "researchTopicTabs"   // tour target
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(6)
                                OutSubTab {
                                    label: (void i18n.revision, i18n.t("research_screen.topic_question", "📝 Câu hỏi"))
                                    active: screen.topicSource === "question"
                                    onClicked: screen.topicSource = "question"
                                }
                                OutSubTab {
                                    label: (void i18n.revision, i18n.t("research_screen.topic_suggest", "✨ Gợi ý"))
                                    active: screen.topicSource === "suggest"
                                    onClicked: { screen.topicSource = "suggest"; plannerStore.refresh(plannerStore.templateId) }
                                }
                                OutSubTab {
                                    label: (void i18n.revision, i18n.t("research_screen.topic_document", "📄 Tài liệu"))
                                    active: screen.topicSource === "document"
                                    onClicked: screen.topicSource = "document"
                                }
                                Item { Layout.fillWidth: true }
                            }

                            // Ô chủ đề — luôn hiện (chủ đề thực sự dùng để nghiên cứu)
                            TextArea {
                                id: topicInput
                                objectName: "researchTopicInput"   // tour target
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(120)
                                wrapMode: TextArea.Wrap
                                placeholderText: screen.topicSource === "document"
                                    ? (void i18n.revision, i18n.t("research_screen.topic_placeholder_doc", "Câu hỏi định hướng (tùy chọn) — nghiên cứu sẽ dựa trên tài liệu bên dưới..."))
                                    : (void i18n.revision, i18n.t("research_screen.topic_placeholder", "Nhập chủ đề / câu hỏi cần nghiên cứu...\nVí dụ: Xu hướng AI trong giáo dục 2025"))
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontBody
                                background: Rectangle {
                                    radius: VfTheme.dp(8)
                                    color: VfTheme.surface
                                    border.color: topicInput.activeFocus ? "#0EA5E9" : VfTheme.borderBox
                                }
                                // Tự đánh giá chủ đề khi ngừng gõ (debounce) — không cần bấm nút
                                onTextChanged: assessDebounce.restart()
                            }

                            Timer {
                                id: assessDebounce
                                interval: 900
                                repeat: false
                                onTriggered: {
                                    if (screen.currentTopic().length >= 12)
                                        researchController.assessTopicAsync(screen.currentTopic(), languageSelect.value)
                                }
                            }

                            // Badge đánh giá chủ đề (tự động chạy sau khi nhập)
                            Rectangle {
                                id: assessBadge
                                Layout.fillWidth: true
                                visible: researchController.assessing
                                    || (researchController.assessment && researchController.assessment.content_score !== undefined)
                                radius: VfTheme.dp(8)
                                implicitHeight: assessBadgeCol.implicitHeight + VfTheme.dp(14)
                                readonly property int score: researchController.assessment
                                    ? Number(researchController.assessment.content_score || 0) : 0
                                color: researchController.assessing ? VfTheme.surfaceSoft
                                    : (assessBadge.score >= 70 ? VfTheme.greenFill
                                        : (assessBadge.score >= 40 ? VfTheme.amberFill : VfTheme.redFill))
                                border.color: researchController.assessing ? VfTheme.border
                                    : (assessBadge.score >= 70 ? VfTheme.greenBorderSoft
                                        : (assessBadge.score >= 40 ? VfTheme.amberBorderSoft : VfTheme.redBorderSoft))

                                ColumnLayout {
                                    id: assessBadgeCol
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.margins: VfTheme.dp(8)
                                    spacing: VfTheme.dp(2)
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: VfTheme.dp(6)
                                        Text {
                                            text: researchController.assessing ? "⏳"
                                                : (assessBadge.score >= 70 ? "★" : (assessBadge.score >= 40 ? "◐" : "✕"))
                                            font.pixelSize: VfTheme.fontSmall
                                            color: VfTheme.text
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: researchController.assessing
                                                ? (void i18n.revision, i18n.t("research_screen.assessing_topic", "Đang đánh giá chủ đề..."))
                                                : (assessBadge.score + "/100 · " + (assessBadge.score >= 70 ? (void i18n.revision, i18n.t("research_screen.assess_good", "Nên làm"))
                                                    : (assessBadge.score >= 40 ? (void i18n.revision, i18n.t("research_screen.assess_medium", "Cân nhắc")) : (void i18n.revision, i18n.t("research_screen.assess_poor", "Chưa đáng research")))))
                                            color: VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontSmall
                                            font.weight: VfTheme.weightStrong
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }

                            // ── Khu GỢI Ý CHỦ ĐỀ (inline) — chỉ hiện ở tab Gợi ý ──
                            ColumnLayout {
                                Layout.fillWidth: true
                                visible: screen.topicSource === "suggest"
                                spacing: VfTheme.dp(6)

                                VfButton {
                                    text: researchController.plannerGenerating
                                        ? (void i18n.revision, i18n.t("research_screen.generating_ideas", "⏳ Đang tạo ý tưởng — chờ AI..."))
                                        : (void i18n.revision, i18n.t("research_screen.generate_ideas", "✨ Tạo ý tưởng từ AI"))
                                    tone: "primary"
                                    Layout.fillWidth: true
                                    minWidth: VfTheme.dp(140)
                                    enabled: String(plannerStore.templateId || "").length > 0 && !researchController.plannerGenerating
                                    tooltip: (void i18n.revision, i18n.t("research_screen.generate_ideas_tooltip", "AI sinh danh sách chủ đề gợi ý theo template + chủ đề đang nhập (5–30 giây). Bấm một ý tưởng để dùng làm chủ đề."))
                                    onClicked: plannerStore.generateIdeas(plannerStore.templateId, screen.currentTopic(), 6)
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: VfTheme.dp(170)
                                    radius: VfTheme.dp(7)
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.border
                                    clip: true

                                    Text {
                                        anchors.centerIn: parent
                                        width: parent.width - VfTheme.dp(20)
                                        visible: (plannerStore.ideas || []).length === 0
                                        text: researchController.plannerGenerating
                                            ? (void i18n.revision, i18n.t("research_screen.generating_ideas_hint", "AI đang nghĩ ý tưởng theo template + chủ đề của bạn (5–30 giây)..."))
                                            : (String(researchController.plannerNotice || "").length > 0
                                                ? String(researchController.plannerNotice)
                                                : (String(plannerStore.templateId || "").length === 0
                                                    ? (void i18n.revision, i18n.t("research_screen.select_template_first", "Chọn một template ở trên rồi bấm \"Tạo ý tưởng từ AI\"."))
                                                    : (void i18n.revision, i18n.t("research_screen.no_ideas_yet", "Chưa có ý tưởng. Bấm \"Tạo ý tưởng từ AI\" để sinh danh sách chủ đề."))))
                                        color: String(researchController.plannerNotice || "").length > 0 && !researchController.plannerGenerating
                                            ? VfTheme.redText : VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        horizontalAlignment: Text.AlignHCenter
                                        wrapMode: Text.WordWrap
                                    }

                                    ScrollView {
                                        anchors.fill: parent
                                        anchors.margins: VfTheme.dp(5)
                                        clip: true
                                        contentWidth: availableWidth
                                        contentHeight: plannerIdeasCol.implicitHeight
                                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                        ColumnLayout {
                                            id: plannerIdeasCol
                                            width: parent.availableWidth
                                            spacing: VfTheme.dp(4)
                                            Repeater {
                                                model: plannerStore.ideas || []
                                                delegate: Rectangle {
                                                    Layout.fillWidth: true
                                                    implicitHeight: ideaRow.implicitHeight + VfTheme.dp(10)
                                                    radius: VfTheme.dp(6)
                                                    color: VfTheme.surface
                                                    border.color: VfTheme.borderBox
                                                    RowLayout {
                                                        id: ideaRow
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        anchors.margins: VfTheme.dp(6)
                                                        spacing: VfTheme.dp(6)
                                                        Text {
                                                            Layout.fillWidth: true
                                                            text: String((modelData || {}).topic || "")
                                                            color: VfTheme.text
                                                            font.family: VfTheme.fontFamily
                                                            font.pixelSize: VfTheme.fontTiny
                                                            wrapMode: Text.WordWrap
                                                        }
                                                        VfButton {
                                                            text: (void i18n.revision, i18n.t("research_screen.idea_use", "Dùng"))
                                                            tone: "success"
                                                            minWidth: VfTheme.dp(54)
                                                            tooltip: (void i18n.revision, i18n.t("research_screen.idea_use_tooltip", "Dùng ý tưởng này làm chủ đề nghiên cứu."))
                                                            onClicked: {
                                                                topicInput.text = String((modelData || {}).topic || "")
                                                                screen.topicSource = "question"
                                                            }
                                                        }
                                                        VfButton {
                                                            text: "✕"
                                                            tone: "danger"
                                                            minWidth: VfTheme.dp(32)
                                                            tooltip: (void i18n.revision, i18n.t("research_screen.idea_delete_tooltip", "Xóa ý tưởng này."))
                                                            onClicked: plannerStore.removeIdea(String((modelData || {}).id || ""))
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Khu tài liệu — chỉ hiện khi chọn "Từ tài liệu"
                            ColumnLayout {
                                Layout.fillWidth: true
                                visible: screen.topicSource === "document"
                                spacing: VfTheme.dp(4)
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: VfTheme.dp(6)
                                    VfButton {
                                        text: (void i18n.revision, i18n.t("research_screen.upload_document", "Tải tài liệu lên"))
                                        tone: "primary"
                                        Layout.fillWidth: true
                                        minWidth: VfTheme.dp(120)
                                        tooltip: (void i18n.revision, i18n.t("research_screen.upload_document_tooltip", "Đính kèm tài liệu (PDF/DOCX/TXT/MD) làm nguồn nghiên cứu."))
                                        onClicked: screen.pickResearchFiles()
                                    }
                                    VfButton {
                                        text: (void i18n.revision, i18n.t("research_screen.delete_document", "Xóa tài liệu"))
                                        Layout.fillWidth: true
                                        minWidth: VfTheme.dp(96)
                                        tooltip: (void i18n.revision, i18n.t("research_screen.delete_document_tooltip", "Bỏ tài liệu đính kèm gần nhất."))
                                        onClicked: screen.removeLastResearchFile()
                                    }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: VfTheme.dp(46)
                                    radius: VfTheme.dp(7)
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.border
                                    clip: true
                                    ListView {
                                        anchors.fill: parent
                                        anchors.margins: VfTheme.dp(5)
                                        model: screen.uploadedFiles
                                        clip: true
                                        reuseItems: true
                                        delegate: Text {
                                            width: ListView.view.width
                                            height: VfTheme.dp(18)
                                            text: "📄  " + String(modelData).split(/[\\/]/).pop()
                                            color: VfTheme.textMuted
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontTiny
                                            elide: Text.ElideMiddle
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        visible: screen.uploadedFiles.length === 0
                                        text: (void i18n.revision, i18n.t("research_screen.no_documents", "Chưa có tài liệu nào."))
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                    }
                                }
                            }

                        }

                        // ── BLOCK 2: Thiết lập nghiên cứu ──
                        BlockCard {
                            id: setupCard
                            objectName: "researchSetupCard"   // tour target
                            number: "2"
                            title: (void i18n.revision, i18n.t("research_screen.block_setup", "Thiết lập nghiên cứu"))

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(6)
                                VfSelectField {
                                    id: templateSelect
                                    objectName: "researchModeSelect"   // tour target (giữ tên cũ)
                                    Layout.fillWidth: true
                                    label: (void i18n.revision, i18n.t("research_screen.template_label", "Mẫu nghiên cứu"))
                                    options: screen.templateOptions()
                                    value: plannerStore.templateId
                                    accent: "#8B5CF6"
                                    tooltip: (void i18n.revision, i18n.t("research_screen.template_tooltip", "Chọn mẫu để nạp sẵn phong cách kịch bản, giọng đọc, thời lượng. Không chọn cũng được."))
                                    onSelected: function(v) { plannerStore.refresh(String(v || "")) }
                                }
                                VfSelectField {
                                    id: languageSelect
                                    Layout.fillWidth: true
                                    label: (void i18n.revision, i18n.t("research_screen.output_language_short", "Ngôn ngữ đầu ra"))
                                    options: screen.languageOptions
                                    value: "vi"
                                    accent: VfTheme.primary
                                    iconRole: "flag"
                                }
                            }

                        }

                        // ── BLOCK 3: Đã nghiên cứu — chủ đề đã làm · lịch sắp chạy ──
                        BlockCard {
                            objectName: "researchDoneCard"   // tour target
                            number: "3"
                            title: (void i18n.revision, i18n.t("research_screen.block_done", "Đã nghiên cứu"))

                            // Teaser lịch tự động — bấm mở quản lý lịch
                            Rectangle {
                                Layout.fillWidth: true
                                radius: VfTheme.dp(8)
                                implicitHeight: schedTeaserRow.implicitHeight + VfTheme.dp(12)
                                color: VfTheme.blueFill
                                border.color: VfTheme.borderSoft
                                RowLayout {
                                    id: schedTeaserRow
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.margins: VfTheme.dp(8)
                                    spacing: VfTheme.dp(6)
                                    Text {
                                        Layout.fillWidth: true
                                        text: (void i18n.revision, i18n.t("research_screen.schedule_teaser", "⏰ Lịch tự động: "))
                                            + String((researchController.schedules || []).length)
                                            + (void i18n.revision, i18n.t("research_screen.schedule_teaser_suffix", " — nghiên cứu → audio định kỳ"))
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: (void i18n.revision, i18n.t("research_screen.schedule_manage", "Quản lý ›"))
                                        color: VfTheme.primary
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        font.weight: VfTheme.weightStrong
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { screen.opsView = "schedule"; screen.opsOpen = true }
                                }
                            }

                            // Chủ đề đã nghiên cứu — bấm mở lại báo cáo (🎧 = có audio)
                            ListView {
                                id: doneTopicsList
                                Layout.fillWidth: true
                                // Chiếm trọn phần panel còn lại — show cả lịch sử tại chỗ, không cần mở dialog
                                Layout.preferredHeight: Math.max(
                                    VfTheme.dp(220),
                                    leftScroll.height - topicCard.height - setupCard.height - VfTheme.dp(140)
                                )
                                clip: true
                                reuseItems: true
                                spacing: VfTheme.dp(4)
                                model: researchController.historyModel
                                delegate: Rectangle {
                                    width: ListView.view.width
                                    implicitHeight: doneRow.implicitHeight + VfTheme.dp(12)
                                    radius: VfTheme.dp(7)
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.borderSoft
                                    RowLayout {
                                        id: doneRow
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: VfTheme.dp(7)
                                        spacing: VfTheme.dp(6)
                                        Rectangle {
                                            width: VfTheme.dp(7); height: VfTheme.dp(7); radius: VfTheme.dp(4)
                                            color: String(modelData.status || "") === "complete" ? "#10B981"
                                                : (String(modelData.status || "") === "running" ? "#F59E0B"
                                                    : (String(modelData.status || "") === "failed" ? "#EF4444" : VfTheme.borderStrong))
                                        }
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: VfTheme.dp(1)
                                            Text {
                                                Layout.fillWidth: true
                                                text: String(modelData.topic || modelData.job_id || "")
                                                color: VfTheme.text
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.fontTiny
                                                font.weight: VfTheme.weightStrong
                                                elide: Text.ElideRight
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                text: String(modelData.updated_at || modelData.created_at || "").replace("T", " ").slice(0, 16)
                                                color: VfTheme.textSubtle
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.fontTiny
                                                elide: Text.ElideRight
                                            }
                                        }
                                        Text {
                                            visible: String(modelData.audio_path || "").length > 0
                                            text: "🎧"
                                            font.pixelSize: VfTheme.fontSmall
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: screen.loadHistoryEntry(String(modelData.job_id || ""), "report")
                                    }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    visible: (researchController.history || []).length === 0
                                    width: parent.width - VfTheme.dp(24)
                                    text: (void i18n.revision, i18n.t("research_screen.no_done_topics", "Chưa có chủ đề nào. Nhập chủ đề ở khối 1 và bấm Bắt đầu nghiên cứu — audio podcast sẽ tự tạo khi xong."))
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }

                        Item { Layout.preferredHeight: VfTheme.dp(2) }
                    }
                }

                // ── ACTION BAR — dính đáy panel trái ──
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: actionBarCol.implicitHeight + VfTheme.dp(16)
                    color: VfTheme.surface

                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: VfTheme.borderBox
                    }

                    ColumnLayout {
                        id: actionBarCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: VfTheme.dp(8)
                        anchors.rightMargin: VfTheme.dp(8)
                        spacing: VfTheme.dp(6)

                        // Submit chính của pipeline + lên lịch tự động
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(6)
                            VfButton {
                                objectName: "researchStartBtn"   // tour target
                                text: (void i18n.revision, i18n.t("research_screen.start_research", "▶  Bắt đầu nghiên cứu"))
                                tone: "primary"
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(44)
                                enabled: screen.effectiveTopic().length > 0
                                tooltip: (void i18n.revision, i18n.t("research_screen.start_research_tooltip", "Chạy nghiên cứu theo chế độ đã chọn. Báo cáo hiện ở khung bên phải."))
                                onClicked: screen.startResearch()
                            }
                            VfButton {
                                text: (void i18n.revision, i18n.t("research_screen.btn_open_scheduler", "Lịch"))
                                minWidth: VfTheme.dp(64)
                                Layout.preferredHeight: VfTheme.dp(44)
                                tooltip: (void i18n.revision, i18n.t("research_screen.open_scheduler_tooltip", "Lên lịch nghiên cứu tự động — chạy định kỳ, tự ra audio (Audio Overview / TTS theo cấu hình ở Block 3)."))
                                onClicked: { screen.opsView = "schedule"; screen.opsOpen = true }
                            }
                        }


                    }
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(1)
            Layout.fillHeight: true
            color: VfTheme.borderBox
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: VfTheme.dp(4)
            Layout.leftMargin: 6
            Layout.rightMargin: 6
            Layout.topMargin: 4
            Layout.bottomMargin: 4

            VfPanel {
                title: ""
                dense: true
                Layout.fillWidth: true

                // Status row + ops drawer trigger
                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(8)

                    Text {
                        text: (void i18n.revision, i18n.t("research_screen.status_label", "Trạng thái"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightStrong
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: VfTheme.dp(24)
                        radius: VfTheme.dp(5)
                        color: VfTheme.amberFill
                        border.color: VfTheme.amberBorderSoft

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(8)
                            anchors.rightMargin: VfTheme.dp(8)
                            text: researchController.statusMessage
                            color: VfTheme.amberText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                    VfButton {
                        text: (void i18n.revision, i18n.t("deep_research.btn_cancel_short", "⏹ Dừng"))
                        tone: "danger"
                        minWidth: VfTheme.dp(72)
                        tooltip: (void i18n.revision, i18n.t("research_screen.cancel_task_tooltip", "Hủy tác vụ nghiên cứu/kịch bản/TTS đang chạy."))
                        onClicked: researchController.cancelCurrent()
                    }
                    VfButton {
                        objectName: "researchOpsBtn"   // tour target
                        text: (void i18n.revision, i18n.t("research_screen.history_button", "⋯ Lịch sử"))
                        minWidth: VfTheme.dp(96)
                        tooltip: (void i18n.revision, i18n.t("research_screen.history_tooltip", "Mở Lịch sử · Hàng đợi · Lịch chạy (các view vận hành)."))
                        onClicked: { screen.opsView = "history"; screen.opsOpen = true }
                    }
                }

                // Progress stepper (chỉ hiển thị tiến trình, không lặp điều khiển)
                RowLayout {
                    objectName: "researchStepper"   // tour target
                    Layout.fillWidth: true
                    spacing: 0

                    Repeater {
                        model: [(void i18n.revision, i18n.t("research_screen.step_research", "Nghiên cứu")), (void i18n.revision, i18n.t("research_screen.step_production", "Sản xuất"))]
                        delegate: RowLayout {
                            spacing: 0
                            Layout.fillWidth: true
                            property bool stepActive: screen.currentStep === index
                            property bool stepDoneFlag: screen.stepDone.length > index && screen.stepDone[index] === true

                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                width: VfTheme.dp(18)
                                height: VfTheme.dp(18)
                                radius: VfTheme.dp(9)
                                color: stepDoneFlag ? VfTheme.greenBorder : (stepActive ? VfTheme.primary : VfTheme.borderStrong)
                                Text {
                                    anchors.centerIn: parent
                                    text: stepDoneFlag ? "✓" : String(index + 1)
                                    color: "#ffffff"
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    font.weight: VfTheme.weightStrong
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { screen.currentStep = index; screen.gotoStepView(index) }
                                }
                            }
                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                leftPadding: VfTheme.dp(4)
                                text: modelData
                                color: stepActive ? VfTheme.text : VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                font.weight: stepActive ? VfTheme.weightStrong : Font.Normal
                                elide: Text.ElideRight
                            }
                            // connector line
                            Rectangle {
                                visible: index < 1
                                Layout.fillWidth: true
                                Layout.leftMargin: VfTheme.dp(4)
                                Layout.rightMargin: VfTheme.dp(4)
                                Layout.alignment: Qt.AlignVCenter
                                height: VfTheme.dp(2)
                                radius: 1
                                color: stepDoneFlag ? VfTheme.greenBorder : VfTheme.borderSoft
                            }
                        }
                    }
                }
            }

            VfPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: ""
                subtitle: ""
                dense: true
                showFrame: false

                // Group selector — 2 tab: Nghiên cứu (stream realtime) · Kịch bản (freeform).
                // "Sản xuất" đã bỏ: sản xuất video đi thẳng sang Audio-to-Video.
                RowLayout {
                    objectName: "researchOutputTabs"   // tour target
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(6)

                    OutGroupTab { label: (void i18n.revision, i18n.t("research_screen.output_group_research", "Nghiên cứu")); active: screen.outputGroup === "research"; onClicked: screen.outputGroup = "research" }
                    OutGroupTab { label: (void i18n.revision, i18n.t("research_screen.output_group_script", "Kịch bản")); active: screen.outputGroup === "script"; onClicked: screen.outputGroup = "script" }
                    OutGroupTab {
                        label: (void i18n.revision, i18n.t("research_screen.output_group_library", "🎧 Kho Audio"))
                        active: screen.outputGroup === "audiolib"
                        onClicked: {
                            screen.outputGroup = "audiolib"
                            researchController.refreshSeries()
                            researchController.refreshAudios()
                        }
                    }
                    Item { Layout.fillWidth: true }
                }

                Rectangle {
                    Layout.fillWidth: true
                    visible: Boolean(screen.lastAction.blocked)
                    radius: VfTheme.dp(8)
                    color: VfTheme.redFill
                    border.color: VfTheme.redBorderSoft
                    implicitHeight: researchBlockerText.implicitHeight + 18

                    Text {
                        id: researchBlockerText
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(9)
                        text: String(screen.lastAction.code || "research_action_blocked") + ": " + String(screen.lastAction.message || "")
                        color: VfTheme.redText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        wrapMode: Text.WordWrap
                    }
                }

                Rectangle {
                    id: resultFrame
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: VfTheme.dp(8)
                    color: VfTheme.surface
                    border.color: VfTheme.borderBox
                    clip: true

                    // responsive split: report|evidence (review) & script|report (ref)
                    readonly property bool contentWide: width > VfTheme.dp(820)
                    readonly property bool splitView: screen.outputGroup === "script"
                    readonly property bool showSplit: splitView && contentWide

                    // Kho Audio & Series — embedded as the 3rd tab of Research Labs
                    // (it's the audio/series library PRODUCED here, not a top-level feature).
                    Loader {
                        anchors.fill: parent
                        active: screen.outputGroup === "audiolib" || everActive
                        visible: screen.outputGroup === "audiolib"
                        source: active ? "AudioLibraryScreen.qml" : ""
                        asynchronous: true
                        property bool everActive: false
                        onActiveChanged: if (active) everActive = true
                    }

                    RowLayout {
                        anchors.fill: parent
                        visible: screen.outputGroup !== "audiolib"
                        anchors.margins: VfTheme.dp(8)
                        spacing: VfTheme.dp(8)

                        // ── LEFT PANE (primary) ─────────────────────────
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            // equal-weight base so a wide child (script TextArea) can't
                            // steal the split from the reference pane — 50/50 deterministic.
                            Layout.preferredWidth: 1
                            spacing: VfTheme.dp(4)

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(6)

                                Text {
                                    Layout.fillWidth: true
                                    text: screen.outputGroup === "script" ? (void i18n.revision, i18n.t("research_screen.content_script", "✏  Kịch bản"))
                                        : (screen.outputGroup === "research"
                                            ? (screen.researchSub === "plan" ? (void i18n.revision, i18n.t("research_screen.content_plan_assess", "🧭  Kế hoạch & Đánh giá"))
                                                : (void i18n.revision, i18n.t("research_screen.content_research_report", "📄  Báo cáo nghiên cứu")))
                                            : (screen.productionSub === "audio" ? (void i18n.revision, i18n.t("research_screen.content_voice", "🔊  Giọng đọc"))
                                                : (screen.productionSub === "metadata" ? (void i18n.revision, i18n.t("research_screen.content_video_info", "🎬  Thông tin video")) : (void i18n.revision, i18n.t("research_screen.content_asset_pack", "🖼  Gói hình ảnh")))))
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    font.weight: VfTheme.weightStrong
                                    elide: Text.ElideRight
                                }

                                // ● nhịp đập + đồng hồ giây — job đang chạy là THẤY nó sống
                                Rectangle {
                                    id: runningPulseDot
                                    visible: researchController.activeJobRunning === true
                                    width: VfTheme.dp(8); height: VfTheme.dp(8); radius: VfTheme.dp(4)
                                    color: "#F59E0B"
                                    SequentialAnimation on opacity {
                                        running: runningPulseDot.visible && VfTheme.motion
                                        loops: Animation.Infinite
                                        NumberAnimation { from: 1.0; to: 0.25; duration: 600 }
                                        NumberAnimation { from: 0.25; to: 1.0; duration: 600 }
                                    }
                                }
                                Text {
                                    visible: researchController.activeJobRunning === true
                                    text: (void i18n.revision, i18n.t("research_screen.running_label", "Đang chạy"))
                                        + " · " + Math.floor(screen.runningElapsedSec / 60) + "p"
                                        + ("0" + (screen.runningElapsedSec % 60)).slice(-2) + "s"
                                    color: "#F59E0B"
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    font.weight: VfTheme.weightStrong
                                }
                            }

                            // Plan + assessment
                            MarkdownViewer {
                                visible: screen.outputGroup === "research" && screen.researchSub === "plan"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                markdown: researchController.planMarkdown.length > 0
                                    ? researchController.planMarkdown
                                    : (researchController.previewPrompt.length > 0
                                        ? researchController.previewPrompt
                                        : researchController.reportMarkdown)
                                emptyText: (void i18n.revision, i18n.t("research_screen.plan_empty_hint", "Bấm \"Đánh giá\" hoặc \"Lập kế hoạch\" — kết quả sẽ hiện ở đây."))
                            }

                            // Report (research → report)
                            MarkdownViewer {
                                visible: screen.outputGroup === "research" && screen.researchSub === "report"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                markdown: researchController.reportMarkdown
                                emptyText: (void i18n.revision, i18n.t("research_screen.report_empty_hint", "Chạy \"Research\" — báo cáo nghiên cứu sẽ hiện ở đây."))
                            }

                            // Script editor — WRAPPED in ScrollView so long scripts
                            // scroll instead of clipping, and the TextArea's content
                            // implicitWidth can't balloon the pane (which squeezed the
                            // reference pane to one-word-per-line). Bug 22/7.
                            ScrollView {
                                visible: screen.outputGroup === "script"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                TextArea {
                                    id: scriptEditor
                                    text: researchController.scriptText.length > 0
                                        ? researchController.scriptText
                                        : researchController.reportMarkdown
                                    placeholderText: (void i18n.revision, i18n.t("research_screen.script_empty_hint", "Bấm \"Tạo kịch bản\" — kịch bản sẽ hiện ở đây."))
                                    wrapMode: TextArea.Wrap
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontBody
                                    background: Rectangle {
                                        radius: VfTheme.dp(7)
                                        color: VfTheme.surface
                                        border.color: VfTheme.border
                                    }
                                }
                            }

                            // Audio panel
                            ColumnLayout {
                                visible: screen.outputGroup === "production" && screen.productionSub === "audio"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: VfTheme.dp(8)
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: VfTheme.dp(64)
                                    radius: VfTheme.dp(8)
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.borderBox
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: VfTheme.dp(12)
                                        spacing: VfTheme.dp(10)
                                        Text {
                                            Layout.fillWidth: true
                                            text: (void i18n.revision, i18n.t("research_screen.audio_info", "Audio TTS — bấm Nghe thử để phát, hoặc Lưu audio ở phần Xuất bản."))
                                            color: VfTheme.textMuted
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontSmall
                                            wrapMode: Text.WordWrap
                                        }
                                        VfButton {
                                            text: (void i18n.revision, i18n.t("research_screen.play_audio", "▶ Nghe thử"))
                                            tone: "primary"
                                            minWidth: VfTheme.dp(96)
                                            onClicked: researchController.playAudio(researchController.lastJobId)
                                        }
                                        VfButton {
                                            text: (void i18n.revision, i18n.t("deep_research.btn_save_audio_bilingual", "Lưu audio"))
                                            minWidth: VfTheme.dp(90)
                                            tooltip: (void i18n.revision, i18n.t("research_screen.save_audio_tooltip", "Lưu file audio TTS ra ổ đĩa."))
                                            onClicked: researchController.saveAudio(researchController.lastJobId)
                                        }
                                    }
                                }
                                Item { Layout.fillHeight: true }
                            }

                            // Metadata kit
                            ScrollView {
                                visible: screen.outputGroup === "production" && screen.productionSub === "metadata"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                contentWidth: availableWidth
                                contentHeight: metadataKitCol.implicitHeight
                                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                ColumnLayout {
                                    id: metadataKitCol
                                    width: parent.availableWidth
                                    spacing: VfTheme.dp(8)

                                    function refreshFromAction() {
                                        metaTitlesArea.text = screen.metadataTitles().join("\n")
                                        metaDescArea.text = screen.metadataDescriptions().join("\n\n")
                                        metaThumbArea.text = screen.metadataThumbnailPrompts().join("\n")
                                    }

                                    Connections {
                                        target: screen
                                        function onLastActionChanged() { metadataKitCol.refreshFromAction() }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { Layout.fillWidth: true; text: (void i18n.revision, i18n.t("research_screen.metadata_title", "Tiêu đề")); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; font.weight: Font.DemiBold }
                                        VfButton { compact: true; text: (void i18n.revision, i18n.t("common.copy", "Sao chép")); onClicked: { metaTitlesArea.selectAll(); metaTitlesArea.copy(); metaTitlesArea.deselect() } }
                                    }
                                    TextArea {
                                        id: metaTitlesArea
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: VfTheme.dp(96)
                                        text: screen.metadataTitles().join("\n")
                                        placeholderText: (void i18n.revision, i18n.t("research_screen.metadata_title_placeholder", "Tiêu đề — bấm \"Thông tin (Metadata)\" ở phần Xuất bản để tạo."))
                                        wrapMode: TextArea.Wrap
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        color: VfTheme.text
                                        background: Rectangle { radius: VfTheme.dp(6); color: VfTheme.surfaceSoft; border.color: VfTheme.borderStrong }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { Layout.fillWidth: true; text: (void i18n.revision, i18n.t("research_screen.metadata_description", "Mô tả")); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; font.weight: Font.DemiBold }
                                        VfButton { compact: true; text: (void i18n.revision, i18n.t("common.copy", "Sao chép")); onClicked: { metaDescArea.selectAll(); metaDescArea.copy(); metaDescArea.deselect() } }
                                    }
                                    TextArea {
                                        id: metaDescArea
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: VfTheme.dp(150)
                                        text: screen.metadataDescriptions().join("\n\n")
                                        placeholderText: (void i18n.revision, i18n.t("research_screen.metadata_description_placeholder", "Mô tả (descriptions)"))
                                        wrapMode: TextArea.Wrap
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        color: VfTheme.text
                                        background: Rectangle { radius: VfTheme.dp(6); color: VfTheme.surfaceSoft; border.color: VfTheme.borderStrong }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { Layout.fillWidth: true; text: (void i18n.revision, i18n.t("research_screen.metadata_thumbnail_prompt", "Prompt thumbnail")); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; font.weight: Font.DemiBold }
                                        VfButton { compact: true; text: (void i18n.revision, i18n.t("common.copy", "Sao chép")); onClicked: { metaThumbArea.selectAll(); metaThumbArea.copy(); metaThumbArea.deselect() } }
                                    }
                                    TextArea {
                                        id: metaThumbArea
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: VfTheme.dp(110)
                                        text: screen.metadataThumbnailPrompts().join("\n")
                                        placeholderText: "Prompt thumbnail"
                                        wrapMode: TextArea.Wrap
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        color: VfTheme.text
                                        background: Rectangle { radius: VfTheme.dp(6); color: VfTheme.surfaceSoft; border.color: VfTheme.borderStrong }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: VfTheme.dp(8)
                                        Item { Layout.fillWidth: true }
                                        VfButton {
                                            text: (void i18n.revision, i18n.t("common.save", "Save"))
                                            tone: "primary"
                                            minWidth: VfTheme.dp(100)
                                            onClicked: researchController.saveMetadataKit(
                                                metaTitlesArea.text,
                                                metaDescArea.text,
                                                metaThumbArea.text
                                            )
                                        }
                                    }
                                }
                            }

                            // Asset pack
                            MarkdownViewer {
                                visible: screen.outputGroup === "production" && screen.productionSub === "asset"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                markdown: researchController.assetPackText
                                emptyText: (void i18n.revision, i18n.t("research_screen.asset_pack_empty_hint", "Bấm \"Gói hình ảnh\" ở phần Xuất bản — gói tài sản hình ảnh sẽ hiện ở đây."))
                            }
                        }

                        // divider
                        Rectangle {
                            visible: resultFrame.showSplit
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            color: VfTheme.borderBox
                        }

                        // ── RIGHT PANE (báo cáo tham chiếu khi viết kịch bản) ──
                        ColumnLayout {
                            visible: resultFrame.showSplit
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1
                            spacing: VfTheme.dp(4)

                            Text {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("research_screen.content_report_reference", "📄  Báo cáo (tham chiếu)"))
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                font.weight: VfTheme.weightStrong
                                elide: Text.ElideRight
                            }
                            MarkdownViewer {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                markdown: researchController.reportMarkdown
                                emptyText: (void i18n.revision, i18n.t("research_screen.report_reference_hint", "Báo cáo nghiên cứu để bám sát khi viết kịch bản."))
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: screen.outputGroup !== "audiolib"
                    spacing: VfTheme.dp(6)

                    TextField {
                        id: reportChatInput
                        objectName: "researchChatInput"   // tour target
                        Layout.fillWidth: true
                        placeholderText: screen.resultView === "script"
                            ? (void i18n.revision, i18n.t("deep_research.chat_placeholder_refine_script", "Refine current script..."))
                            : (void i18n.revision, i18n.t("deep_research.chat_placeholder_refine_step", "Refine / clarify the current step..."))
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontBody
                        selectByMouse: true
                        onAccepted: screen.sendChatMessage()
                        background: Rectangle {
                            radius: VfTheme.dp(7)
                            color: VfTheme.surface
                            border.color: VfTheme.borderBox
                        }
                    }
                    VfButton {
                        text: (void i18n.revision, i18n.t("deep_research.btn_chat_send", "Send"))
                        minWidth: VfTheme.dp(78)
                        tone: "primary"
                        onClicked: screen.sendChatMessage()
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: screen.outputGroup !== "audiolib"
                    text: (void i18n.revision, i18n.t("deep_research.chat_examples_plan", "Example: narrow the plan to 3 angles, prioritize authoritative sources."))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    wrapMode: Text.WordWrap
                }

                // ── Duyệt nghiên cứu (hiện khi có báo cáo, chưa duyệt) ──
                VfButton {
                    visible: researchController.reportMarkdown.length > 0 && !screen.contentApproved && screen.outputGroup !== "audiolib"
                    text: (void i18n.revision, i18n.t("research_screen.approve_and_proceed", "🎙  Chốt báo cáo — tạo lại podcast"))
                    tone: "success"
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(38)
                    tooltip: (void i18n.revision, i18n.t("research_screen.approve_tooltip", "Chốt nội dung nghiên cứu, mở khóa bước Sản xuất."))
                    onClicked: {
                        screen.approveResearch("report")
                        screen.contentApproved = true
                        screen.advanceStep(1)
                        screen.showOutput("script")
                    }
                }

                // ── Finale: hoàn tất → gửi sang Video ──
                RowLayout {
                    Layout.fillWidth: true
                    visible: screen.outputGroup !== "audiolib"
                    spacing: VfTheme.dp(6)
                    VfButton {
                        objectName: "researchSendVideoBtn"   // tour target
                        text: (void i18n.revision, i18n.t("deep_research.btn_send_video_step", "▶  Import sang Audio-to-Video"))
                        tone: "success"
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(38)
                        enabled: screen.contentApproved || researchController.scriptText.length > 0
                        tooltip: (void i18n.revision, i18n.t("research_screen.send_to_video_tooltip", "Import audio + báo cáo sang tab Audio-to-Video để dựng video. Đây là bước cuối của quy trình."))
                        onClicked: researchController.sendToTranscript(screen.effectiveTopic(), screen.currentNotes())
                    }
                    VfButton {
                        text: (void i18n.revision, i18n.t("deep_research.btn_save_report", "Lưu báo cáo"))
                        minWidth: VfTheme.dp(96)
                        tooltip: (void i18n.revision, i18n.t("research_screen.save_report_tooltip", "Lưu báo cáo nghiên cứu ra file."))
                        onClicked: researchController.saveReport(researchController.lastJobId, "txt")
                    }
                }

                // ── Series: chat tiếp NGAY TRONG phiên này để AI vạch kế hoạch ──
                // 1 chat = 1 series. Nút này chat tiếp trong chính conversation vừa
                // nghiên cứu (đã sẵn context) → AI vạch nhiều tập → lưu vào Kho Audio
                // để chạy từng tập (mỗi tập lấy tin mới nhất, robust, không cần DR mới).
                VfButton {
                    visible: researchController.reportMarkdown.length > 0 && screen.outputGroup !== "audiolib"
                    enabled: !researchController.creatingSeries
                    text: researchController.creatingSeries
                        ? "⏳ Đang lập kế hoạch series trong chat…"
                        : "🎬 Tạo series (AI vạch các tập trong chính chat này)"
                    tone: "accent"
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(38)
                    tooltip: "Chat tiếp trong phiên nghiên cứu này để AI vạch kế hoạch nhiều tập. Xong mở tab KHO AUDIO để chạy từng tập (mỗi tập tự lấy tin mới nhất)."
                    onClicked: researchController.createSeries(researchController.lastJobId, 8)
                }

                Text {
                    Layout.fillWidth: true
                    visible: researchController.creatingSeries && screen.outputGroup !== "audiolib"
                    text: "AI đang chat tiếp trong phiên này để vạch các tập… Xong mở tab KHO AUDIO để chạy."
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // ── Operational drawer overlay: Lịch sử / Hàng đợi / Lịch chạy ──
    Rectangle {
        id: opsDrawer
        anchors.fill: parent
        visible: screen.opsOpen
        z: 1000
        color: Qt.rgba(0, 0, 0, 0.45)

        MouseArea {
            anchors.fill: parent
            onClicked: screen.opsOpen = false
        }

        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width - VfTheme.dp(80), VfTheme.dp(900))
            height: Math.min(parent.height - VfTheme.dp(80), VfTheme.dp(720))
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong

            MouseArea { anchors.fill: parent }  // block click-through

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(12)
                spacing: VfTheme.dp(8)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(6)
                    OutSubTab { label: (void i18n.revision, i18n.t("research_screen.ops_history", "Lịch sử")); active: screen.opsView === "history"; onClicked: screen.opsView = "history" }
                    OutSubTab { label: (void i18n.revision, i18n.t("research_screen.ops_queue", "Hàng đợi")); active: screen.opsView === "queue"; onClicked: screen.opsView = "queue" }
                    OutSubTab { label: (void i18n.revision, i18n.t("research_screen.ops_schedule", "Lịch chạy")); active: screen.opsView === "schedule"; onClicked: screen.opsView = "schedule" }
                    Item { Layout.fillWidth: true }
                    VfButton {
                        text: (void i18n.revision, i18n.t("research_screen.close_button", "✕ Đóng"))
                        tone: "danger"
                        minWidth: VfTheme.dp(80)
                        onClicked: screen.opsOpen = false
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: VfTheme.dp(8)
                    color: VfTheme.surfaceSoft
                    border.color: VfTheme.borderBox
                    clip: true

                    ScrollView {
                        id: opsScroll
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(8)
                        clip: true
                        contentWidth: availableWidth
                        contentHeight: opsCol.implicitHeight
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        ColumnLayout {
                            id: opsCol
                            width: opsScroll.availableWidth
                            spacing: VfTheme.dp(8)

                            QueueView {
                                visible: screen.opsView === "queue"
                                Layout.fillWidth: true
                            }
                            HistoryView {
                                visible: screen.opsView === "history"
                                Layout.fillWidth: true
                            }
                            SchedulerView {
                                visible: screen.opsView === "schedule"
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Output group / sub tab pills (right pane) ───────────────────
    component OutGroupTab: Rectangle {
        id: gtab
        property string label: ""
        property bool active: false
        signal clicked()
        implicitWidth: gtabText.implicitWidth + VfTheme.dp(28)
        implicitHeight: VfTheme.dp(30)
        radius: VfTheme.dp(7)
        color: active ? VfTheme.primary : VfTheme.surfaceSoft
        border.width: active ? 0 : 1
        border.color: VfTheme.borderBox
        Text {
            id: gtabText
            anchors.centerIn: parent
            text: gtab.label
            color: gtab.active ? "#ffffff" : VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            font.weight: VfTheme.weightStrong
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: gtab.clicked() }
    }

    component OutSubTab: Rectangle {
        id: stab
        property string label: ""
        property bool active: false
        signal clicked()
        implicitWidth: stabText.implicitWidth + VfTheme.dp(22)
        implicitHeight: VfTheme.dp(26)
        radius: VfTheme.dp(13)
        color: active ? VfTheme.blueFill : "transparent"
        border.width: 1
        border.color: active ? VfTheme.primary : VfTheme.borderBox
        Text {
            id: stabText
            anchors.centerIn: parent
            text: stab.label
            color: stab.active ? VfTheme.primary : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            font.weight: stab.active ? VfTheme.weightStrong : VfTheme.weightControl
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: stab.clicked() }
    }

    // ── BlockCard: card block đánh số của panel trái (1 Chủ đề · 2 Thiết lập · 3 Sản xuất) ──
    component BlockCard: Rectangle {
        id: bcard
        property string number: ""
        property string title: ""
        default property alias content: bcardBody.data

        Layout.fillWidth: true
        implicitHeight: bcardCol.implicitHeight + VfTheme.dp(18)
        radius: VfTheme.dp(9)
        color: VfTheme.surface
        border.width: 1
        border.color: VfTheme.borderBox

        ColumnLayout {
            id: bcardCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: VfTheme.dp(9)
            spacing: VfTheme.dp(7)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)
                Rectangle {
                    width: VfTheme.dp(17); height: VfTheme.dp(17); radius: VfTheme.dp(9)
                    color: VfTheme.primary
                    Text {
                        anchors.centerIn: parent
                        text: bcard.number
                        color: "#ffffff"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                        font.weight: VfTheme.weightStrong
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: bcard.title
                    color: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                }
            }

            ColumnLayout {
                id: bcardBody
                Layout.fillWidth: true
                spacing: VfTheme.dp(7)
            }
        }
    }

    component QueueView: ColumnLayout {
        spacing: VfTheme.dp(8)

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(6)
            Text {
                Layout.fillWidth: true
                text: "Queue: " + String(researchController.stats.queued || researchController.stats.pending || 0)
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                elide: Text.ElideRight
            }
            VfButton { text: (void i18n.revision, i18n.t("common.start", "Start")); tone: "primary"; minWidth: VfTheme.dp(70); onClicked: researchController.startQueue() }
            VfButton { text: (void i18n.revision, i18n.t("common.pause", "Pause")); minWidth: VfTheme.dp(70); onClicked: researchController.pauseQueue() }
            VfButton { text: (void i18n.revision, i18n.t("common.clear", "Clear")); tone: "danger"; minWidth: VfTheme.dp(70); onClicked: researchController.clearQueue() }
        }

        Text {
            visible: researchController.queueRows.length === 0
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("qml.research.empty_queue", "No research queue items."))
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontBody
            horizontalAlignment: Text.AlignHCenter
            topPadding: VfTheme.dp(36)
        }

        Repeater {
            model: researchController.queueRowsModel

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: rowLayout.implicitHeight + 14
                radius: VfTheme.dp(8)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderSoft

                RowLayout {
                    id: rowLayout
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    spacing: VfTheme.dp(8)

                    Text {
                        Layout.fillWidth: true
                        text: String(modelData.name || modelData.topic || modelData.id || "")
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontBody
                        elide: Text.ElideRight
                    }
                    VfStatusPill { value: String(modelData.status || "pending"); tone: "blue" }
                    VfButton {
                        text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                        minWidth: VfTheme.dp(70)
                        onClicked: researchController.removeRow(String(modelData.id || modelData.row_id || modelData.batch_id || ""))
                    }
                }
            }
        }
    }

    component HistoryView: ColumnLayout {
        spacing: VfTheme.dp(8)

        Text {
            visible: researchController.history.length === 0
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("deep_research.no_history", "No research history yet."))
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontBody
            horizontalAlignment: Text.AlignHCenter
            topPadding: VfTheme.dp(36)
        }

        Repeater {
            model: researchController.historyModel

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: historyRow.implicitHeight + 18
                radius: VfTheme.dp(9)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderSoft

                ColumnLayout {
                    id: historyRow
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(9)
                    spacing: VfTheme.dp(5)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)
                        Text {
                            Layout.fillWidth: true
                            text: String(modelData.topic || modelData.job_id || "")
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontBody
                            font.weight: VfTheme.weightStrong
                            elide: Text.ElideRight
                        }
                        Text {
                            text: String(modelData.status || "") + " | " + String(modelData.updated_at || modelData.created_at || "")
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideRight
                        }
                    }

                    Flow {
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight
                        spacing: VfTheme.dp(5)

                        VfButton { text: (void i18n.revision, i18n.t("common.load", "Load")); minWidth: VfTheme.dp(62); onClicked: screen.loadHistoryEntry(String(modelData.job_id || ""), "report") }
                        VfButton { text: (void i18n.revision, i18n.t("common.copy", "Copy")); minWidth: VfTheme.dp(62); onClicked: researchController.copyHistory(String(modelData.job_id || "")) }
                        VfButton { text: (void i18n.revision, i18n.t("deep_research.btn_load_script", "Script")); minWidth: VfTheme.dp(68); onClicked: screen.loadScriptHistory(String(modelData.job_id || "")) }
                        VfButton { text: (void i18n.revision, i18n.t("deep_research.btn_copy_script", "Copy Script")); minWidth: VfTheme.dp(94); onClicked: researchController.copyScriptHistory(String(modelData.job_id || "")) }
                        VfButton { text: (void i18n.revision, i18n.t("deep_research.btn_save_report", "Save")); minWidth: VfTheme.dp(62); onClicked: researchController.saveReport(String(modelData.job_id || ""), "md") }
                        VfButton { text: (void i18n.revision, i18n.t("deep_research.btn_play_audio", "Audio")); minWidth: VfTheme.dp(62); onClicked: researchController.playAudio(String(modelData.job_id || "")) }
                        VfButton { text: (void i18n.revision, i18n.t("common.open", "Open")); minWidth: VfTheme.dp(66); onClicked: researchController.openHistoryFolder(String(modelData.job_id || "")) }
                        VfButton { text: (void i18n.revision, i18n.t("common.delete", "Delete")); tone: "danger"; minWidth: VfTheme.dp(70); onClicked: researchController.deleteHistory(String(modelData.job_id || "")) }
                    }
                }
            }
        }
    }

    component SchedulerView: ColumnLayout {
        spacing: VfTheme.dp(8)

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            TextField {
                id: scheduleTopic
                Layout.fillWidth: true
                placeholderText: (void i18n.revision, i18n.t("deep_research.scheduler_topic_placeholder", "Topic"))
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }
            TextField {
                id: scheduleCron
                Layout.preferredWidth: VfTheme.dp(160)
                placeholderText: "daily"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }
            CheckBox {
                id: scheduleQuality
                text: (void i18n.revision, i18n.t("deep_research.scheduler_quality", "Quality"))
                checked: true
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
            }
            CheckBox {
                id: scheduleDirectorNotes
                text: (void i18n.revision, i18n.t("deep_research.scheduler_director_notes", "Director notes"))
                checked: true
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
            }
            CheckBox {
                id: scheduleAutoImport
                text: (void i18n.revision, i18n.t("deep_research.scheduler_auto_import", "Auto import"))
                checked: true
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
            }
            VfButton {
                text: (void i18n.revision, i18n.t("deep_research.scheduler_add", "Thêm lịch"))
                tone: "primary"
                tooltip: (void i18n.revision, i18n.t("research_screen.scheduler_add_tooltip", "Lịch chạy tự động: nghiên cứu → audio theo cấu hình hiện tại ở panel trái (Block 3 quyết định Audio Overview hay TTS)."))
                onClicked: {
                    var cfg = screen.currentResearchConfig(scheduleAutoImport.checked)
                    cfg.quality_mode = scheduleQuality.checked
                    cfg.auto_director_notes = scheduleDirectorNotes.checked
                    researchController.addScheduleConfigured(
                        scheduleTopic.text,
                        scheduleCron.text,
                        cfg
                    )
                }
            }
        }

        Text {
            visible: researchController.schedules.length === 0
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("deep_research.scheduler_idle", "No scheduled research job."))
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontBody
            horizontalAlignment: Text.AlignHCenter
            topPadding: VfTheme.dp(36)
        }

        Repeater {
            model: researchController.schedulesModel

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: String(modelData.name || modelData.topic || modelData.schedule_id || "")
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontBody
                        elide: Text.ElideRight
                    }
                    VfButton { text: (void i18n.revision, i18n.t("deep_research.scheduler_run_now", "Run now")); minWidth: VfTheme.dp(84); onClicked: researchController.runScheduleNow(String(modelData.schedule_id || "")) }
                    VfButton { text: modelData.enabled ? (void i18n.revision, i18n.t("common.pause", "Pause")) : (void i18n.revision, i18n.t("common.start", "Start")); minWidth: VfTheme.dp(70); onClicked: researchController.toggleSchedule(String(modelData.schedule_id || ""), !modelData.enabled) }
                    VfButton { text: (void i18n.revision, i18n.t("deep_research.scheduler_reset", "Reset")); minWidth: VfTheme.dp(70); onClicked: researchController.resetSchedule(String(modelData.schedule_id || "")) }
                    VfButton { text: (void i18n.revision, i18n.t("common.delete", "Delete")); minWidth: VfTheme.dp(70); onClicked: researchController.removeSchedule(String(modelData.schedule_id || "")) }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(10)

                    Text {
                        id: scheduleNextRun
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("deep_research.scheduler_next_run", "Next run")) + ": "
                            + String(modelData.next_run || modelData.run_at || "-")
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                        elide: Text.ElideRight
                    }
                    Text {
                        id: scheduleLastError
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("deep_research.scheduler_last_error", "Last error")) + ": "
                            + String(modelData.last_error || "-")
                        color: String(modelData.last_error || "").length > 0 ? VfTheme.redText : VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    Timer {
        id: activeSyncTimer
        interval: 1500
        repeat: true
        running: researchController.activeJobRunning === true
        onTriggered: researchController.syncActive()
    }

    Component.onCompleted: Qt.callLater(researchController.refresh)
}
