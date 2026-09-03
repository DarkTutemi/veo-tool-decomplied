pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

// Shared inline narration bus for Master, Clone and future authoring tabs.
// All quick changes are submitted through the asynchronous shared voice worker;
// this component never persists settings or probes an engine on the GUI thread.
Rectangle {
    id: root

    property string contextLabel: "Dùng chung"
    property var draft: ({})
    property bool draftDirty: false
    property var vieneuVoices: []
    property var vieneuStyles: []
    property var providerChoices: []
    property var engineInfo: ({})
    property bool expanded: false
    property int statusRefreshBudget: 0
    property bool omniProfilesRefreshed: false
    property string presentation: "toolbar"
    // Feature tabs may select the shared provider/voice, but Voice Studio owns
    // preview and provider-specific tuning.  ``selectionOnly`` keeps that
    // boundary explicit without cloning a second TTS selector for Clone.
    property bool selectionOnly: false
    property string usageHint: ""
    // Dense feature bars can render the usage note as the healthy status
    // subline, keeping TTS a single row. Runtime/install errors always win.
    property bool usageHintInStatus: false
    // Optional route-owned narrator gate. The shared voice bar renders the
    // control, while the feature tab owns persistence/job snapshots.
    property bool showNarrationPolicy: false
    property string narrationPolicy: "auto"
    signal narrationPolicySelected(string policy)
    signal continueToScriptRequested()
    onSelectionOnlyChanged: {
        if (selectionOnly)
            expanded = false
    }
    // Optional per-job language lock. The shared provider/voice preference stays
    // global, while the frozen job snapshot and preview use this output language.
    property string outputLanguage: ""

    readonly property string route: String(draft.tts_route || "auto").toLowerCase()
    readonly property string provider: providerFromRoute(route)
    readonly property bool sidebarMode: presentation === "sidebar"
    readonly property bool studioMode: presentation === "studio"
    readonly property bool producerMode: sidebarMode || studioMode
    readonly property bool compactBar: presentation === "compactBar"
    readonly property bool voiceCreationOpen:
        studioMode && provider === "omnivoice"
        && studioWorkbench.omniCreateOpen
    // Voice Studio produces OmniVoice profiles. Feature tabs only consume the
    // approved profile catalogue plus per-job rendering controls.
    readonly property bool omniConsumer:
        selectionOnly && provider === "omnivoice"
    readonly property bool showModeSelector: !omniConsumer
    readonly property int compactFieldCount:
        3 + (showModeSelector ? 1 : 0)
        + (showNarrationPolicy ? 1 : 0) + (provider === "omnivoice" ? 2 : 0)
    readonly property int compactSelectMinWidth:
        compactFieldCount * VfTheme.dp(104) + VfTheme.dp(76)
    readonly property bool collapseSelects:
        compactBar && width > 0 && width < compactSelectMinWidth
    onCollapseSelectsChanged: {
        if (!collapseSelects && compactMenu.visible)
            compactMenu.close()
    }
    readonly property bool localProvider:
        ["omnivoice", "moss", "vieneu"].indexOf(provider) >= 0
    readonly property color accent: providerColor(provider)
    readonly property var runtime: (voiceController.sharedTtsConfig || ({})).runtime || ({})
    readonly property var hardware: (engineInfo || ({})).hardware || ({})
    readonly property string installState:
        String((engineInfo || {}).state || "idle").toLowerCase()
    readonly property string serverState:
        String(((engineInfo || {}).server || {}).state || "stopped").toLowerCase()
    readonly property bool hardwareBlocked:
        localProvider && String(hardware.tier || "") === "blocked"
    readonly property bool statusFailed: hardwareBlocked
        || installState === "error" || serverState === "error"
        || (!localProvider && (
            (voiceController.sharedTtsConfig || ({})).ok === false
            || runtime.ready === false))
    readonly property bool languageLockedForProvider:
        outputLanguage.length > 0
        && (provider === "omnivoice" || provider === "moss")
    readonly property int quickControlCount:
        5 + (showNarrationPolicy ? 1 : 0)
        + (provider === "omnivoice" ? 2 : 0) + (selectionOnly ? 0 : 2)

    readonly property var narrationPolicyChoices: [
        { label: "Tự động", value: "auto" },
        { label: "Bật", value: "on" },
        { label: "Tắt", value: "off" }
    ]

    readonly property var geminiModels: [
        { label: "Gemini 3.1 Flash TTS", value: "gemini-3.1-flash-tts-preview" },
        { label: "Gemini 2.5 Flash TTS", value: "gemini-2.5-flash-preview-tts" },
        { label: "Gemini 2.5 Pro TTS", value: "gemini-2.5-pro-preview-tts" }
    ]
    readonly property var omniModes: [
        { label: "Tạo tự động", value: "new" },
        { label: "Theo công thức", value: "design" },
        { label: "Giọng đã lưu", value: "profile" },
        { label: "Clone từ audio", value: "clone" }
    ]
    readonly property var mossModes: [
        { label: "Direct", value: "direct" },
        { label: "Clone giọng", value: "clone" },
        { label: "Nối tiếp audio", value: "continuation" },
        { label: "Nối tiếp + clone", value: "continuation_clone" }
    ]
    readonly property var mossNanoModes: [
        { label: "Direct · giọng có sẵn", value: "direct" },
        { label: "Clone audio", value: "clone" }
    ]
    readonly property var mossBackends: [
        { label: "Tự chọn theo máy", value: "auto" },
        { label: "Nano · CPU/ONNX", value: "nano_cpu" },
        { label: "Local 4B · Hybrid 12 GB", value: "local_4b_hybrid" },
        { label: "Local 4B · GPU đầy đủ 16 GB+", value: "local_4b" }
    ]
    readonly property var languageChoices: [
        { label: "Tự động", value: "auto" },
        { label: "Tiếng Việt", value: "vi" },
        { label: "English", value: "en" },
        { label: "中文", value: "zh" },
        { label: "日本語", value: "ja" },
        { label: "한국어", value: "ko" },
        { label: "Français", value: "fr" },
        { label: "Deutsch", value: "de" },
        { label: "Español", value: "es" },
        { label: "Português", value: "pt" },
        { label: "Русский", value: "ru" },
        { label: "العربية", value: "ar" },
        { label: "हिन्दी", value: "hi" },
        { label: "Indonesia", value: "id" },
        { label: "ไทย", value: "th" },
        { label: "Türkçe", value: "tr" }
    ]
    readonly property var speedChoices: [
        { label: "0.8×", value: "0.8" },
        { label: "0.9×", value: "0.9" },
        { label: "1.0×", value: "1.0" },
        { label: "1.1×", value: "1.1" },
        { label: "1.2×", value: "1.2" }
    ]
    readonly property var precisionChoices: [
        { label: "Nhanh · INT8", value: "int8" },
        { label: "Chất lượng cao · FP32", value: "fp32" }
    ]
    readonly property var omniQualityChoices: [
        { label: "Nghe thử · 16", value: "16" },
        { label: "Narration · 32", value: "32" },
        { label: "Tối đa · 64", value: "64" }
    ]
    Layout.fillWidth: true
    implicitHeight: root.studioMode
        ? studioWorkbench.omniCreationPreferredHeight
        : root.sidebarMode
            ? VfTheme.dp(320)
        : (root.compactBar
            ? VfTheme.controlHeight
            : contentColumn.implicitHeight + VfTheme.dp(18))
    radius: root.compactBar ? 0 : VfTheme.dp(10)
    color: root.compactBar || root.studioMode
        ? "transparent" : VfTheme.surfaceSoft
    border.color: providerBorder(provider)
    border.width: root.compactBar || root.studioMode ? 0 : 1
    clip: root.producerMode

    function copyObject(source) {
        return Object.assign({}, source || ({}))
    }

    function withSelected(items, selectedValue, selectedLabel) {
        var value = String(selectedValue || "")
        var source = items || []
        if (!value.length)
            return source
        for (var i = 0; i < source.length; i++) {
            if (String(source[i].value || "") === value)
                return source
        }
        var result = [{ label: String(selectedLabel || value), value: value }]
        for (var j = 0; j < source.length; j++)
            result.push(source[j])
        return result
    }

    function providerFromRoute(value) {
        return ["omnivoice", "moss", "vieneu"].indexOf(value) >= 0
            ? value : "gemini"
    }

    function mossBackendValue() {
        var value = String(root.draft.moss_backend || "auto").toLowerCase()
        return [
            "auto", "nano_cpu", "local_4b_hybrid", "local_4b"
        ].indexOf(value) >= 0
            ? value : "auto"
    }

    function mossEngineId() {
        var backend = root.mossBackendValue()
        if (backend === "nano_cpu")
            return "moss_nano"
        if (backend === "local_4b" || backend === "local_4b_hybrid")
            return "moss"
        var localStatus = voiceController.engineStatus("moss")
        var localHardware = (localStatus || {}).hardware || ({})
        return String(localHardware.tier || "checking") === "blocked"
            ? "moss_nano" : "moss"
    }

    function providerLabel(value) {
        var items = root.providerChoices || []
        for (var i = 0; i < items.length; i++) {
            if (String(items[i].value || "") === String(value || ""))
                return String(items[i].label || value)
        }
        return String(value || "Giọng đọc")
    }

    function providerColor(value) {
        if (value === "omnivoice")
            return VfTheme.violet
        if (value === "moss")
            return "#0D9488"
        if (value === "vieneu")
            return VfTheme.amber
        return VfTheme.primary
    }

    function providerBorder(value) {
        if (value === "omnivoice")
            return VfTheme.violetBorderSoft
        if (value === "moss")
            return VfTheme.greenBorderSoft
        if (value === "vieneu")
            return VfTheme.amberBorderSoft
        return VfTheme.blueBorderSoft
    }

    function refreshProviderChoices() {
        var source = voiceController.narrationProviderOptions || []
        var result = []
        for (var i = 0; i < source.length; i++) {
            var item = copyObject(source[i])
            var value = String(item.value || "")
            if (["omnivoice", "moss", "vieneu"].indexOf(value) >= 0) {
                var status = voiceController.engineStatus(
                    value === "moss" ? root.mossEngineId() : value)
                var hw = (status || {}).hardware || ({})
                var providerBlocked = String(hw.tier || "") === "blocked"
                if (value === "moss") {
                    var localStatus = voiceController.engineStatus("moss")
                    var nanoStatus = voiceController.engineStatus("moss_nano")
                    var localHw = (localStatus || {}).hardware || ({})
                    var nanoHw = (nanoStatus || {}).hardware || ({})
                    if (String(localHw.tier || "") === "blocked"
                            && String(nanoHw.tier || "") !== "blocked") {
                        item.warning = "Local 4B không phù hợp; Nano CPU vẫn dùng được"
                    }
                    providerBlocked = String(localHw.tier || "") === "blocked"
                        && String(nanoHw.tier || "") === "blocked"
                }
                if (providerBlocked) {
                    item.disabled = true
                    item.reason = String(hw.reason || "Phần cứng không đáp ứng")
                } else if (String(hw.warning || "").length > 0) {
                    item.warning = String(hw.warning)
                }
                if (value === root.provider)
                    root.engineInfo = status
            }
            result.push(item)
        }
        root.providerChoices = result
        if (!root.localProvider)
            root.engineInfo = ({})
    }

    function refreshEngineInfo() {
        if (!root.localProvider) {
            root.engineInfo = ({})
            return
        }
        root.engineInfo = voiceController.engineStatus(
            root.provider === "moss" ? root.mossEngineId() : root.provider)
        root.refreshProviderChoices()
    }

    function statusTitle() {
        if (voiceController.narrationSelectionBusy)
            return "Đang áp dụng"
        if (!root.localProvider)
            return root.statusFailed ? "Chưa sẵn sàng" : "Sẵn sàng"
        if (root.hardwareBlocked)
            return "Bị chặn phần cứng"
        if (root.installState === "downloading")
            return "Đang tải · " + String((root.engineInfo || {}).progress || 0) + "%"
        if (root.installState === "installing")
            return "Đang cài runtime"
        if (root.serverState === "starting")
            return "Đang nạp model"
        if (root.installState === "error" || root.serverState === "error")
            return "Lỗi · thử lại"
        if ((root.engineInfo || {}).installed !== true)
            return "Chưa cài"
        if (root.serverState === "running")
            return "Sẵn sàng"
        return "Sẵn sàng khi dùng"
    }

    function statusDetail() {
        if (root.hardwareBlocked)
            return String(root.hardware.reason || "Máy không đáp ứng cấu hình tối thiểu")
        if (root.installState === "downloading"
                || root.installState === "installing"
                || root.installState === "error")
            return String((root.engineInfo || {}).message || root.statusTitle())
        if (root.serverState === "starting" || root.serverState === "error")
            return String(((root.engineInfo || {}).server || {}).message
                          || root.statusTitle())
        if (root.localProvider && String(root.hardware.warning || "").length > 0)
            return String(root.hardware.warning)
        if (root.localProvider && (root.engineInfo || {}).installed !== true)
            return "Model chỉ tải sau khi bạn chọn provider"
        if (root.localProvider && root.serverState === "stopped")
            return "Server đang nghỉ · tự bật khi tạo audio"
        if (!root.localProvider)
            return "AI Studio · cấu hình dùng cho job mới"
        return "Cấu hình dùng chung cho job mới"
    }

    function visibleStatusDetail() {
        if (!root.usageHintInStatus || root.usageHint.length === 0)
            return root.statusDetail()
        if (root.statusFailed
                || voiceController.narrationSelectionBusy
                || root.installState === "downloading"
                || root.installState === "installing"
                || root.serverState === "starting"
                || (root.localProvider
                    && (root.engineInfo || {}).installed !== true))
            return root.statusDetail()
        return root.usageHint
    }

    function statusFill() {
        if (root.statusFailed)
            return VfTheme.redFill
        if (voiceController.narrationSelectionBusy
                || root.installState === "downloading"
                || root.installState === "installing"
                || root.serverState === "starting")
            return VfTheme.amberFill
        if (root.localProvider && (root.engineInfo || {}).installed !== true)
            return VfTheme.surface
        return VfTheme.greenFill
    }

    function statusTextColor() {
        if (root.statusFailed)
            return VfTheme.redText
        if (voiceController.narrationSelectionBusy
                || root.installState === "downloading"
                || root.installState === "installing"
                || root.serverState === "starting")
            return "#B45309"
        return root.localProvider && (root.engineInfo || {}).installed !== true
            ? VfTheme.textMuted : VfTheme.greenText
    }

    function syncFromController() {
        if (root.draftDirty)
            return
        var next = copyObject(voiceController.providerOptions || ({}))
        var narratorVoice = String(narratorController.selectedVoiceValue || "auto")
        next.gemini_voice = narratorVoice
        next.gemini_model = String(
            (voiceController.sharedTtsConfig || ({})).model
            || "gemini-3.1-flash-tts-preview")
        next.voice_mode = narratorVoice === "auto" ? "auto" : "manual"
        next.voice = narratorVoice === "auto" ? "" : narratorVoice
        next.voice2 = String(narratorController.voice2Value || "off")
        next.emotion = String(narratorController.emotion || "")
        next.gemini_audio_profile = String(next.audio_profile || "")
        next.gemini_director_notes = String(next.director_notes || "")
        next.omni_url = ""
        if (root.selectionOnly
                && root.providerFromRoute(next.tts_route) === "omnivoice")
            next = root.consumerOmniDraft(next)
        root.draft = next
        root.refreshEngineInfo()
    }

    function scheduleDraftCommit() {
        if (root.producerMode)
            return
        // Feature-tab dropdowns are discrete choices and must land before the
        // queue can snapshot them. Producer tuning keeps the existing debounce.
        if (root.selectionOnly)
            root.submitDraft()
        else
            commitTimer.restart()
    }

    function updateDraft(key, value) {
        var next = copyObject(root.draft)
        next[key] = value
        root.draft = next
        root.draftDirty = true
        root.scheduleDraftCommit()
    }

    function updateDraftPatch(patch) {
        var next = copyObject(root.draft)
        var values = patch || ({})
        var keys = Object.keys(values)
        for (var i = 0; i < keys.length; i++)
            next[keys[i]] = values[keys[i]]
        root.draft = next
        root.draftDirty = true
        root.scheduleDraftCommit()
    }

    function selectProvider(value) {
        var selected = String(value || "gemini")
        if (root.producerMode)
            voiceController.setRuntimeTelemetryActive(
                ["omnivoice", "moss", "vieneu"].indexOf(selected) >= 0,
                selected === "moss" ? root.mossEngineId() : selected)
        if (selected === "omnivoice" && root.selectionOnly) {
            var consumer = root.consumerOmniDraft(root.draft)
            consumer.tts_route = "omnivoice"
            root.draft = consumer
            root.draftDirty = true
            root.scheduleDraftCommit()
            voiceController.activateOmniProfileLibrary("")
        } else {
            updateDraft("tts_route", selected === "gemini" ? "aistudio" : selected)
        }
        if (["omnivoice", "moss", "vieneu"].indexOf(selected) >= 0) {
            var selectedEngine = selected === "moss"
                ? root.mossEngineId() : selected
            var status = voiceController.engineStatus(selectedEngine)
            var hw = (status || {}).hardware || ({})
            root.engineInfo = status
            if (!root.selectionOnly
                    && String(hw.tier || "") !== "blocked") {
                if (selected === "omnivoice")
                    root.omniProfilesRefreshed = false
                root.statusRefreshBudget = 12
                voiceController.ensureEngine(selectedEngine)
                statusPoll.start()
            }
        } else {
            root.engineInfo = ({})
        }
    }

    function selectVoice(value) {
        var selected = String(value || "")
        if (root.provider === "gemini") {
            var next = copyObject(root.draft)
            next.gemini_voice = selected || "auto"
            next.voice_mode = selected === "auto" || !selected ? "auto" : "manual"
            next.voice = next.voice_mode === "auto" ? "" : selected
            var speakers = Array.isArray(next.speakers)
                ? next.speakers.slice(0, 2) : []
            if (speakers.length === 0) {
                speakers.push({
                    name: "Speaker 1",
                    voice: selected || "Kore",
                    audio_profile: "",
                    style: "",
                    pace: "",
                    accent: ""
                })
            } else {
                speakers[0] = Object.assign({}, speakers[0] || ({}), {
                    voice: selected || "Kore"
                })
            }
            // Consumer jobs are one narrator. Leftover Voice Studio dialogue
            // rows (Speaker 2 / Kore) must not ride into the speech_config wire.
            next.speakers = root.selectionOnly ? [speakers[0]] : speakers
            root.draft = next
            // Consumer tabs hide Nghe thử. Bundled WAV is instant and must not
            // share the persist worker busy flag (previewNarrationSelection).
            if (root.selectionOnly && selected)
                narratorController.previewVoice(selected, 1)
        } else if (root.provider === "omnivoice") {
            var omni = root.omniConsumer
                ? root.consumerOmniDraft(root.draft)
                : copyObject(root.draft)
            if (root.modeValue() === "design") {
                omni.omni_recipe = selected
                omni.omni_voice = ""
            } else if (root.modeValue() === "profile") {
                omni.omni_recipe = ""
                omni.omni_voice = selected
                if (root.omniConsumer)
                    omni.omni_consumer_voice = selected
                if (root.omniConsumer && selected)
                    voiceController.previewOmniProfile(selected)
            }
            root.draft = omni
        } else if (root.provider === "moss") {
            var moss = copyObject(root.draft)
            var backend = [
                "auto", "nano_cpu", "local_4b_hybrid", "local_4b"
            ].indexOf(selected) >= 0
                ? selected : "auto"
            moss.moss_backend = backend
            var localStatus = voiceController.engineStatus("moss")
            var localHw = (localStatus || {}).hardware || ({})
            var nanoSelected = backend === "nano_cpu"
                || (backend === "auto"
                    && String(localHw.tier || "") === "blocked")
            if (nanoSelected
                    && ["direct", "clone"].indexOf(
                        String(moss.moss_mode || "direct")) < 0) {
                moss.moss_mode = String(moss.moss_ref_audio || "").length > 0
                    ? "clone" : "direct"
                moss.moss_prompt_text = ""
            }
            root.draft = moss
            var engineId = root.mossEngineId()
            root.engineInfo = voiceController.engineStatus(engineId)
            if (!root.selectionOnly
                    && String((root.engineInfo.hardware || {}).tier || "") !== "blocked") {
                root.statusRefreshBudget = 12
                voiceController.ensureEngine(engineId)
                statusPoll.start()
            }
        } else if (root.provider === "vieneu") {
            var vieneu = copyObject(root.draft)
            vieneu.vieneu_voice = selected
            root.draft = vieneu
        }
        root.draftDirty = true
        root.scheduleDraftCommit()
    }

    function modeLabel() {
        if (root.provider === "gemini")
            return "Model"
        if (root.provider === "vieneu")
            return "Chất lượng"
        return "Chế độ"
    }

    function modeOptions() {
        if (root.provider === "gemini") {
            var model = root.modeValue()
            return root.withSelected(root.geminiModels, model, model)
        }
        if (root.omniConsumer)
            return [{ label: "Giọng đã lưu", value: "profile" }]
        if (root.provider === "omnivoice")
            return root.omniModes
        if (root.provider === "moss")
            return root.mossEngineId() === "moss_nano"
                ? root.mossNanoModes : root.mossModes
        return root.precisionChoices
    }

    function modeValue() {
        if (root.provider === "gemini")
            return String(root.draft.gemini_model || "gemini-3.1-flash-tts-preview")
        if (root.omniConsumer)
            return "profile"
        if (root.provider === "omnivoice")
            return String(root.draft.omni_mode || "new") === "auto"
                ? "new" : String(root.draft.omni_mode || "new")
        if (root.provider === "moss")
            return String(root.draft.moss_mode || "direct")
        return String(root.draft.vieneu_precision || "int8")
    }

    function setOmniMode(value) {
        var selected = ["new", "design", "profile", "clone"].indexOf(value) >= 0
            ? value : "new"
        var next = copyObject(root.draft)
        next.omni_mode = selected
        var recipeFields = [
            "omni_recipe", "omni_gender", "omni_age", "omni_pitch",
            "omni_style", "omni_accent", "omni_instruct"
        ]
        var profileFields = ["omni_voice"]
        var refFields = ["omni_ref_audio", "omni_ref_text"]
        var clear = []
        if (selected === "design")
            clear = profileFields.concat(refFields)
        else if (selected === "profile")
            clear = recipeFields.concat(refFields)
        else if (selected === "clone")
            clear = recipeFields.concat(profileFields)
        else
            clear = recipeFields.concat(profileFields).concat(refFields)
        for (var i = 0; i < clear.length; i++)
            next[clear[i]] = ""
        root.draft = next
        root.draftDirty = true
        root.scheduleDraftCommit()
    }

    function consumerOmniDraft(source) {
        var next = copyObject(source)
        var selected = next.omni_consumer_only
            ? String(next.omni_voice || "")
            : String(next.omni_consumer_voice || next.omni_voice || "")
        next.omni_mode = "profile"
        next.omni_voice = selected
        next.omni_consumer_voice = selected
        next.omni_consumer_only = true
        var clear = [
            "omni_recipe", "omni_gender", "omni_age", "omni_pitch",
            "omni_style", "omni_accent", "omni_instruct",
            "omni_ref_audio", "omni_ref_text"
        ]
        for (var i = 0; i < clear.length; i++)
            next[clear[i]] = ""
        return next
    }

    function setMode(value) {
        if (root.provider === "gemini")
            updateDraft("gemini_model", String(value))
        else if (root.provider === "omnivoice")
            setOmniMode(String(value))
        else if (root.provider === "moss") {
            var moss = copyObject(root.draft)
            var mode = String(value)
            if (root.mossEngineId() === "moss_nano"
                    && ["direct", "clone"].indexOf(mode) < 0)
                mode = "direct"
            moss.moss_mode = mode
            if (mode === "direct") {
                moss.moss_ref_audio = ""
                moss.moss_prompt_text = ""
            } else if (mode === "clone") {
                moss.moss_prompt_text = ""
            }
            root.draft = moss
            root.draftDirty = true
            root.scheduleDraftCommit()
        }
        else
            updateDraft("vieneu_precision", String(value))
    }

    function voiceFieldLabel() {
        if (root.provider === "omnivoice") {
            if (root.modeValue() === "design")
                return "Công thức tạo tone"
            if (root.modeValue() === "profile")
                return "Giọng đã lưu"
            return "Nguồn giọng"
        }
        if (root.provider === "moss")
            return "Runtime"
        return "Giọng"
    }

    function voiceOptions() {
        if (root.provider === "gemini") {
            var geminiVoice = root.voiceValue()
            return root.withSelected(
                narratorController.voiceOptions || [],
                geminiVoice, geminiVoice)
        }
        if (root.provider === "omnivoice") {
            var omniVoice = root.voiceValue()
            var source = root.modeValue() === "design"
                ? (voiceController.omniRecipeOptions || [])
                : root.modeValue() === "profile"
                    ? (voiceController.omniProfileOptions || []) : []
            if (root.omniConsumer && source.length === 0) {
                return [{
                    label: voiceController.omniProfileBusy
                        ? "Đang tải thư viện giọng…"
                        : "Chưa có giọng đã lưu",
                    value: "",
                    disabled: true,
                    reason: "Tạo và duyệt giọng trong Voice Studio trước."
                }]
            }
            return root.withSelected(
                source,
                omniVoice, voiceController.omniVoiceLabel(omniVoice))
        }
        if (root.provider === "moss") {
            var localStatus = voiceController.engineStatus("moss")
            var hardware = (localStatus || {}).hardware || ({})
            var metrics = (hardware || {}).metrics || ({})
            var vram = Number(metrics.nvidia_vram_gb || 0)
            var backends = []
            for (var i = 0; i < root.mossBackends.length; i++) {
                var item = root.copyObject(root.mossBackends[i])
                if (item.value === "local_4b_hybrid" && vram > 0 && vram < 12) {
                    item.disabled = true
                    item.reason = "Hybrid cần GPU NVIDIA tối thiểu 12 GB VRAM"
                } else if (item.value === "local_4b" && vram > 0 && vram < 16) {
                    item.disabled = true
                    item.reason = "GPU đầy đủ cần tối thiểu 16 GB; hãy dùng Hybrid 12 GB"
                }
                backends.push(item)
            }
            return backends
        }
        var vieneuVoice = root.voiceValue()
        return root.withSelected(
            root.vieneuVoices, vieneuVoice, vieneuVoice)
    }

    function optionLabel(items, value, fallback) {
        var current = String(value || "")
        var source = items || []
        for (var i = 0; i < source.length; i++) {
            if (String(source[i].value || "") === current)
                return String(source[i].label || current)
        }
        return String(fallback || current)
    }

    function compactChipLabel() {
        var voice = root.optionLabel(root.voiceOptions(), root.voiceValue(), "")
        if (!voice.length)
            return root.omniConsumer ? "TTS · Chưa chọn giọng" : "TTS"
        return "TTS · " + voice
    }

    function compactChipTooltip() {
        if (root.statusFailed)
            return root.statusDetail()
        if (root.usageHint.length > 0)
            return root.usageHint
        return root.statusTitle() + " · " + root.statusDetail()
    }

    function voiceValue() {
        if (root.provider === "gemini")
            return String(root.draft.gemini_voice || "auto")
        if (root.provider === "omnivoice")
            return root.modeValue() === "design"
                ? String(root.draft.omni_recipe || "")
                : root.modeValue() === "profile"
                    ? String(root.draft.omni_voice || "") : ""
        if (root.provider === "moss")
            return root.mossBackendValue()
        return String(root.draft.vieneu_voice || "")
    }

    function mossVoiceLabel() {
        var mode = String(root.draft.moss_mode || "direct")
        if (mode === "clone" || mode === "continuation_clone")
            return "Voice clone hiện tại"
        if (mode === "continuation")
            return "Audio nối tiếp hiện tại"
        return "Giọng mặc định"
    }

    function deliveryLabel() {
        if (root.provider === "gemini")
            return "Cảm xúc"
        if (root.provider === "vieneu")
            return "Cách đọc"
        return "Ngôn ngữ"
    }

    function deliveryOptions() {
        if (root.provider === "gemini")
            return root.withSelected(
                narratorController.emotionOptions || [],
                root.deliveryValue(), root.deliveryValue())
        if (root.provider === "vieneu")
            return root.withSelected(
                root.vieneuStyles,
                root.deliveryValue(), root.deliveryValue())
        return root.languageChoices
    }

    function deliveryValue() {
        if (root.provider === "gemini")
            return String(root.draft.emotion || "")
        if (root.provider === "omnivoice")
            return root.outputLanguage.length > 0
                ? root.outputLanguage
                : String(root.draft.omni_language || "auto")
        if (root.provider === "moss")
            return root.outputLanguage.length > 0
                ? root.outputLanguage
                : String(root.draft.moss_language || "vi")
        return String(root.draft.vieneu_style || "tu_nhien")
    }

    function setDelivery(value) {
        if (root.languageLockedForProvider)
            return
        if (root.provider === "gemini")
            updateDraft("emotion", String(value))
        else if (root.provider === "omnivoice")
            updateDraft("omni_language", String(value))
        else if (root.provider === "moss")
            updateDraft("moss_language", String(value))
        else
            updateDraft("vieneu_style", String(value))
    }

    function finalLabel() {
        return "Tốc độ"
    }

    function finalOptions() {
        return root.speedChoices
    }

    function finalValue() {
        return String(root.draft.omni_speed || "1.0")
    }

    function setFinal(value) {
        updateDraft("omni_speed", String(value))
    }

    function qualityLabel() {
        return "Chất lượng"
    }

    function qualityOptions() {
        return root.omniQualityChoices
    }

    function qualityValue() {
        return String(root.draft.omni_num_step || "32")
    }

    function previewText() {
        var samples = {
            "en": "Hello, this is a preview of the VeoFlow narration voice.",
            "zh": "你好，这是 VeoFlow 旁白声音的试听。",
            "ja": "こんにちは。VeoFlowのナレーション音声サンプルです。",
            "ko": "안녕하세요. VeoFlow 내레이션 음성 미리듣기입니다。",
            "es": "Hola, esta es una muestra de la voz narrativa de VeoFlow.",
            "fr": "Bonjour, voici un aperçu de la voix de narration VeoFlow.",
            "de": "Hallo, dies ist eine Vorschau der VeoFlow-Erzählstimme.",
            "pt": "Olá, esta é uma prévia da voz de narração do VeoFlow.",
            "ru": "Здравствуйте, это пример голоса закадрового рассказчика VeoFlow.",
            "ar": "مرحبًا، هذه معاينة لصوت التعليق في VeoFlow.",
            "hi": "नमस्ते, यह VeoFlow वर्णन आवाज़ का नमूना है।",
            "id": "Halo, ini adalah pratinjau suara narasi VeoFlow.",
            "th": "สวัสดี นี่คือตัวอย่างเสียงบรรยายของ VeoFlow",
            "tr": "Merhaba, bu VeoFlow anlatım sesinin bir ön izlemesidir."
        }
        return String(samples[root.outputLanguage]
                      || "Xin chào, đây là bản nghe thử giọng dẫn truyện của VeoFlow.")
    }

    function previewDraft() {
        var previewOptions = root.copyObject(root.draft)
        if (root.outputLanguage.length > 0) {
            previewOptions.output_language = root.outputLanguage
            if (root.provider === "omnivoice")
                previewOptions.omni_language = root.outputLanguage
            else if (root.provider === "moss")
                previewOptions.moss_language = root.outputLanguage
        }
        voiceController.previewNarrationSelection(
            root.provider, previewOptions, root.previewText())
    }

    function applyConfigPreset(presetId) {
        var result = voiceController.voiceConfigPreset(String(presetId || ""))
        if (!result || !result.ok)
            return
        var selected = String(result.provider || "gemini")
        var next = copyObject(result.config || ({}))
        next.tts_route = selected === "gemini" ? "aistudio" : selected
        root.draft = next
        root.draftDirty = true
        if (root.producerMode) {
            var local = ["omnivoice", "moss", "vieneu"].indexOf(selected) >= 0
            voiceController.setRuntimeTelemetryActive(
                local, selected === "moss" ? root.mossEngineId() : selected)
            if (local) {
                var engineId = selected === "moss" ? root.mossEngineId() : selected
                root.engineInfo = voiceController.engineStatus(engineId)
                if (String((root.engineInfo.hardware || {}).tier || "") !== "blocked") {
                    root.statusRefreshBudget = 12
                    voiceController.ensureEngine(engineId)
                    statusPoll.start()
                }
            } else {
                root.engineInfo = ({})
            }
        }
        root.submitDraft()
    }

    function setQuality(value) {
        updateDraft("omni_num_step", String(value))
    }

    function retryProvider() {
        if (!root.localProvider || root.hardwareBlocked)
            return
        if (root.selectionOnly) {
            root.openVoiceStudio()
            return
        }
        root.statusRefreshBudget = 12
        voiceController.ensureEngine(
            root.provider === "moss" ? root.mossEngineId() : root.provider)
        statusPoll.start()
    }

    function submitDraft() {
        commitTimer.stop()
        var submitted = root.omniConsumer
            ? root.consumerOmniDraft(root.draft)
            : root.draft
        if (root.omniConsumer)
            root.draft = submitted
        voiceController.applyNarrationSelection(root.provider, submitted)
    }

    function resetDraft() {
        commitTimer.stop()
        root.draftDirty = false
        root.syncFromController()
    }

    function executionSnapshot() {
        var executionDraft = root.omniConsumer
            ? root.consumerOmniDraft(root.draft)
            : root.copyObject(root.draft)
        if (root.outputLanguage.length > 0) {
            executionDraft.output_language = root.outputLanguage
            if (root.provider === "omnivoice")
                executionDraft.omni_language = root.outputLanguage
            else if (root.provider === "moss")
                executionDraft.moss_language = root.outputLanguage
        }
        return voiceController.narrationExecutionSnapshot(
            root.provider, executionDraft)
    }

    function openVoiceStudio() {
        if (root.draftDirty)
            root.submitDraft()
        appController.setRoute("voice")
    }

    function selectProviderFromShortcut(value) {
        // Banner/provider-chip shortcut: same contract as the workbench switcher
        // (drop a highlighted config preset so it cannot survive the provider swap).
        studioWorkbench.selectedConfigPresetId = ""
        studioWorkbench.selectedConfigPresetName = ""
        root.selectProvider(String(value || "gemini"))
    }

    Component.onCompleted: {
        root.vieneuVoices = voiceController.listEngineVoices("vieneu")
        root.vieneuStyles = voiceController.listEngineStyles("vieneu")
        root.refreshProviderChoices()
        root.syncFromController()
        if (root.provider === "omnivoice")
            voiceController.activateOmniProfileLibrary("")
        else
            voiceController.refreshOmniProfiles("")
        if (root.producerMode)
            voiceController.setRuntimeTelemetryActive(
                root.localProvider,
                root.provider === "moss" ? root.mossEngineId() : root.provider)
    }
    Component.onDestruction: {
        if (root.producerMode)
            voiceController.setRuntimeTelemetryActive(false, "")
    }

    Timer {
        id: commitTimer
        interval: 220
        repeat: false
        onTriggered: root.submitDraft()
    }

    Timer {
        id: statusPoll
        interval: 800
        repeat: true
        running: false
        onTriggered: {
            root.refreshEngineInfo()
            if (root.provider === "omnivoice"
                    && root.serverState === "running"
                    && !root.omniProfilesRefreshed) {
                root.omniProfilesRefreshed = true
                voiceController.refreshOmniProfiles("")
            }
            if (root.statusRefreshBudget > 0)
                root.statusRefreshBudget--
            var transientState = root.installState === "downloading"
                || root.installState === "installing"
                || root.serverState === "starting"
            if (root.statusRefreshBudget <= 0 && !transientState)
                stop()
        }
    }

    Connections {
        target: voiceController
        function onProviderOptionsChanged() {
            root.syncFromController()
            if (root.producerMode)
                voiceController.setRuntimeTelemetryActive(
                    root.localProvider,
                    root.provider === "moss" ? root.mossEngineId() : root.provider)
        }
        function onNarrationSelectionChanged() {
            root.draftDirty = false
            root.syncFromController()
        }
        function onOmniProfileApproved(profileId) {
            if (!root.studioMode || root.provider !== "omnivoice")
                return
            root.draftDirty = false
            root.syncFromController()
            studioWorkbench.omniCreateOpen = false
        }
        function onSharedTtsConfigChanged() {
            if (!root.localProvider)
                root.refreshProviderChoices()
        }
        function onOptionsChanged() {
            // Hardware verdicts are probed off-thread. Refresh from the
            // completed RAM cache when VoiceController publishes them.
            root.refreshProviderChoices()
        }
    }

    Connections {
        target: narratorController
        function onConfigChanged() {
            root.syncFromController()
        }
    }

    RowLayout {
        id: compactBarRow
        visible: root.compactBar
        anchors.fill: parent
        spacing: VfTheme.dp(6)

        Rectangle {
            id: ttsChip
            Layout.preferredWidth: root.collapseSelects
                ? Math.min(VfTheme.dp(176), Math.max(VfTheme.dp(72), compactBarRow.width))
                : VfTheme.dp(68)
            Layout.preferredHeight: VfTheme.controlHeight
            Layout.maximumWidth: root.collapseSelects ? compactBarRow.width : VfTheme.dp(72)
            radius: VfTheme.dp(8)
            color: root.statusFill()
            border.color: root.statusFailed ? VfTheme.redBorder : VfTheme.greenBorder
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(7)
                anchors.rightMargin: VfTheme.dp(7)
                spacing: VfTheme.dp(5)

                VfAppIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "speaker-high-volume"
                    size: VfTheme.dp(14)
                    framed: false
                    color: root.statusTextColor()
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(0, ttsChip.width - VfTheme.dp(36)
                        - (root.collapseSelects ? VfTheme.dp(12) : 0))
                    text: root.collapseSelects ? root.compactChipLabel() : "TTS"
                    color: root.statusTextColor()
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Rectangle {
                    visible: root.collapseSelects
                    anchors.verticalCenter: parent.verticalCenter
                    width: VfTheme.dp(7)
                    height: width
                    radius: width / 2
                    color: root.statusFailed ? VfTheme.redBorder : VfTheme.greenBorder
                }
            }

            HoverHandler { id: ttsChipHover }
            ToolTip.visible: ttsChipHover.hovered
            ToolTip.text: root.compactChipTooltip()
            ToolTip.delay: 350

            MouseArea {
                anchors.fill: parent
                enabled: root.collapseSelects
                    || (root.localProvider
                        && (root.installState === "error"
                            || root.serverState === "error"))
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.localProvider
                            && (root.installState === "error"
                                || root.serverState === "error")) {
                        root.retryProvider()
                        return
                    }
                    if (root.collapseSelects)
                        compactMenu.visible ? compactMenu.close() : compactMenu.open()
                }
            }
        }

        VfSelectField {
            visible: !root.collapseSelects && root.showNarrationPolicy
            compact: true
            Layout.fillWidth: true
            Layout.preferredWidth: VfTheme.dp(96)
            Layout.minimumWidth: VfTheme.dp(84)
            Layout.preferredHeight: VfTheme.controlHeight
            label: "Narrator video"
            options: root.narrationPolicyChoices
            value: root.narrationPolicy
            accent: root.accent
            onSelected: value => root.narrationPolicySelected(String(value))
        }

        VfSelectField {
            visible: !root.collapseSelects
            compact: true
            Layout.fillWidth: true
            Layout.preferredWidth: VfTheme.dp(112)
            Layout.minimumWidth: VfTheme.dp(88)
            Layout.preferredHeight: VfTheme.controlHeight
            label: "Provider"
            options: root.providerChoices
            value: root.provider
            accent: root.accent
            onSelected: value => root.selectProvider(value)
        }

        VfSelectField {
            visible: !root.collapseSelects && root.showModeSelector
            compact: true
            Layout.fillWidth: true
            Layout.preferredWidth: VfTheme.dp(128)
            Layout.minimumWidth: VfTheme.dp(96)
            Layout.preferredHeight: VfTheme.controlHeight
            label: root.modeLabel()
            options: root.modeOptions()
            value: root.modeValue()
            accent: root.accent
            onSelected: value => root.setMode(value)
        }

        VfSelectField {
            visible: !root.collapseSelects
            compact: true
            Layout.fillWidth: true
            Layout.preferredWidth: VfTheme.dp(148)
            Layout.minimumWidth: VfTheme.dp(108)
            Layout.preferredHeight: VfTheme.controlHeight
            label: root.voiceFieldLabel()
            options: root.voiceOptions()
            value: root.voiceValue()
            accent: root.accent
            onSelected: value => root.selectVoice(value)
        }

        VfSelectField {
            visible: !root.collapseSelects
            compact: true
            Layout.fillWidth: true
            Layout.preferredWidth: VfTheme.dp(108)
            Layout.minimumWidth: VfTheme.dp(84)
            Layout.preferredHeight: VfTheme.controlHeight
            label: root.deliveryLabel()
            options: root.deliveryOptions()
            value: root.deliveryValue()
            accent: root.accent
            enabled: !root.languageLockedForProvider
            tooltip: root.languageLockedForProvider
                ? "Ngôn ngữ TTS theo Ngôn ngữ nội dung của job."
                : ""
            onSelected: value => root.setDelivery(value)
        }

        VfSelectField {
            visible: !root.collapseSelects && root.provider === "omnivoice"
            compact: true
            Layout.fillWidth: true
            Layout.preferredWidth: VfTheme.dp(96)
            Layout.minimumWidth: VfTheme.dp(80)
            Layout.preferredHeight: VfTheme.controlHeight
            label: root.finalLabel()
            options: root.finalOptions()
            value: root.finalValue()
            accent: root.accent
            onSelected: value => root.setFinal(value)
        }

        VfSelectField {
            visible: !root.collapseSelects && root.provider === "omnivoice"
            compact: true
            Layout.fillWidth: true
            Layout.preferredWidth: VfTheme.dp(108)
            Layout.minimumWidth: VfTheme.dp(84)
            Layout.preferredHeight: VfTheme.controlHeight
            label: root.qualityLabel()
            options: root.qualityOptions()
            value: root.qualityValue()
            accent: root.accent
            onSelected: value => root.setQuality(value)
        }
    }

    Popup {
        id: compactMenu
        visible: false
        x: 0
        y: parent.height + VfTheme.dp(4)
        width: Math.max(VfTheme.dp(320), parent.width)
        padding: VfTheme.dp(8)
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        popupType: Popup.Item

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        ColumnLayout {
            width: compactMenu.availableWidth
            spacing: VfTheme.dp(6)

            Text {
                Layout.fillWidth: true
                text: root.compactChipTooltip()
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                wrapMode: Text.WordWrap
            }

            VfSelectField {
                visible: root.showNarrationPolicy
                Layout.fillWidth: true
                label: "Narrator video"
                options: root.narrationPolicyChoices
                value: root.narrationPolicy
                accent: root.accent
                onSelected: value => root.narrationPolicySelected(String(value))
            }

            VfSelectField {
                Layout.fillWidth: true
                label: "Provider"
                options: root.providerChoices
                value: root.provider
                accent: root.accent
                onSelected: value => root.selectProvider(value)
            }

            VfSelectField {
                visible: root.showModeSelector
                Layout.fillWidth: true
                label: root.modeLabel()
                options: root.modeOptions()
                value: root.modeValue()
                accent: root.accent
                onSelected: value => root.setMode(value)
            }

            VfSelectField {
                Layout.fillWidth: true
                label: root.voiceFieldLabel()
                options: root.voiceOptions()
                value: root.voiceValue()
                accent: root.accent
                onSelected: value => root.selectVoice(value)
            }

            VfButton {
                visible: root.omniConsumer
                    && (voiceController.omniProfileOptions || []).length === 0
                    && !voiceController.omniProfileBusy
                Layout.fillWidth: true
                text: "Tạo giọng trong Voice Studio"
                tone: "accent"
                onClicked: root.openVoiceStudio()
            }

            VfSelectField {
                Layout.fillWidth: true
                label: root.deliveryLabel()
                options: root.deliveryOptions()
                value: root.deliveryValue()
                accent: root.accent
                enabled: !root.languageLockedForProvider
                onSelected: value => root.setDelivery(value)
            }

            VfSelectField {
                visible: root.provider === "omnivoice"
                Layout.fillWidth: true
                label: root.finalLabel()
                options: root.finalOptions()
                value: root.finalValue()
                accent: root.accent
                onSelected: value => root.setFinal(value)
            }

            VfSelectField {
                visible: root.provider === "omnivoice"
                Layout.fillWidth: true
                label: root.qualityLabel()
                options: root.qualityOptions()
                value: root.qualityValue()
                accent: root.accent
                onSelected: value => root.setQuality(value)
            }
        }
    }

    ColumnLayout {
        id: contentColumn
        visible: !root.producerMode && !root.compactBar
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: VfTheme.dp(9)
        }
        spacing: VfTheme.dp(8)

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? VfTheme.dp(18) : 0
            visible: root.usageHint.length > 0 && !root.usageHintInStatus
            spacing: VfTheme.dp(6)

            VfAppIcon {
                name: "light-bulb"
                size: VfTheme.dp(13)
                framed: false
                color: root.accent
            }

            Text {
                Layout.fillWidth: true
                text: root.usageHint
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.weight: VfTheme.weightStrong
                elide: Text.ElideRight
            }
        }

        // OmniVoice has two real quick choices (speed + quality). Other
        // providers keep those slots out of the layout instead of presenting
        // singleton dropdowns that cannot change anything.
        // they intentionally become two ordered rows instead of shrinking into
        // unreadable dropdowns or overflowing the screen.
        GridLayout {
            id: quickGrid
            Layout.fillWidth: true
            // Breakpoints use physical window pixels. VfTheme.dp() intentionally
            // scales down on small displays; using it here would make a 1366px
            // laptop incorrectly qualify for the desktop one-row layout.
            columns: width >= 1400
                ? root.quickControlCount
                : width >= 850 ? Math.min(5, root.quickControlCount) : 2
            rowSpacing: VfTheme.dp(7)
            columnSpacing: VfTheme.dp(7)

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: VfTheme.dp(250)
                Layout.minimumWidth: quickGrid.columns >= 5
                    ? VfTheme.dp(220) : VfTheme.dp(160)
                implicitHeight: VfTheme.fieldHeight
                radius: VfTheme.dp(8)
                color: root.statusFill()
                border.color: root.providerBorder(root.provider)

                Rectangle {
                    id: statusIcon
                    anchors.left: parent.left
                    anchors.leftMargin: VfTheme.dp(8)
                    anchors.verticalCenter: parent.verticalCenter
                    width: VfTheme.dp(32)
                    height: VfTheme.dp(32)
                    radius: VfTheme.dp(9)
                    color: root.provider === "gemini"
                        ? VfTheme.blueFill
                        : root.provider === "omnivoice"
                            ? VfTheme.violetFill
                            : root.provider === "moss"
                                ? VfTheme.greenFill : VfTheme.amberFill
                    VfAppIcon {
                        anchors.centerIn: parent
                        name: "speaker-high-volume"
                        size: VfTheme.dp(16)
                        framed: false
                        color: root.accent
                    }
                }

                Column {
                    anchors.left: statusIcon.right
                    anchors.leftMargin: VfTheme.dp(7)
                    anchors.right: parent.right
                    anchors.rightMargin: VfTheme.dp(8)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0
                    Text {
                        width: parent.width
                        text: root.contextLabel + " · " + root.statusTitle()
                        color: root.statusTextColor()
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightStrong
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: root.visibleStatusDetail()
                        color: root.statusFailed
                            ? VfTheme.redText : VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    visible: root.localProvider
                        && (root.installState === "error"
                            || root.serverState === "error")
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.retryProvider()
                }
            }

            VfSelectField {
                visible: root.showNarrationPolicy
                Layout.fillWidth: true
                Layout.preferredWidth: VfTheme.dp(120)
                label: "Narrator video"
                options: root.narrationPolicyChoices
                value: root.narrationPolicy
                accent: root.accent
                tooltip: root.narrationPolicy === "off"
                    ? "Tắt hoàn toàn TTS narrator của app; giữ audio/hội thoại native của video."
                    : root.narrationPolicy === "on"
                        ? "Buộc tạo narrator cho đầu ra; vẫn giữ lời nhân vật là dialogue của video."
                        : "Chỉ tạo TTS khi phân tích nguồn có mốc và câu nói chứng minh narrator thật sự tồn tại."
                onSelected: value => root.narrationPolicySelected(String(value))
            }

            VfSelectField {
                Layout.fillWidth: true
                Layout.preferredWidth: VfTheme.dp(140)
                label: "Provider"
                options: root.providerChoices
                value: root.provider
                accent: root.accent
                onSelected: value => root.selectProvider(value)
            }

            VfSelectField {
                visible: root.showModeSelector
                Layout.fillWidth: true
                Layout.preferredWidth: VfTheme.dp(155)
                label: root.modeLabel()
                options: root.modeOptions()
                value: root.modeValue()
                accent: root.accent
                onSelected: value => root.setMode(value)
            }

            VfSelectField {
                Layout.fillWidth: true
                Layout.preferredWidth: VfTheme.dp(175)
                label: root.voiceFieldLabel()
                options: root.voiceOptions()
                value: root.voiceValue()
                accent: root.accent
                onSelected: value => root.selectVoice(value)
            }

            VfSelectField {
                Layout.fillWidth: true
                Layout.preferredWidth: VfTheme.dp(125)
                label: root.deliveryLabel()
                options: root.deliveryOptions()
                value: root.deliveryValue()
                accent: root.accent
                enabled: !root.languageLockedForProvider
                tooltip: root.languageLockedForProvider
                    ? "Ngôn ngữ TTS theo Ngôn ngữ nội dung của job."
                    : ""
                onSelected: value => root.setDelivery(value)
            }

            VfSelectField {
                visible: root.provider === "omnivoice"
                Layout.fillWidth: true
                Layout.preferredWidth: VfTheme.dp(105)
                label: root.finalLabel()
                options: root.finalOptions()
                value: root.finalValue()
                accent: root.accent
                onSelected: value => root.setFinal(value)
            }

            VfSelectField {
                visible: root.provider === "omnivoice"
                Layout.fillWidth: true
                Layout.preferredWidth: VfTheme.dp(125)
                label: root.qualityLabel()
                options: root.qualityOptions()
                value: root.qualityValue()
                accent: root.accent
                onSelected: value => root.setQuality(value)
            }

            VfButton {
                visible: !root.selectionOnly
                Layout.fillWidth: true
                Layout.preferredWidth: VfTheme.dp(110)
                text: voiceController.narrationSelectionBusy
                    ? "Đang tạo mẫu…" : "Nghe thử"
                enabled: !voiceController.narrationSelectionBusy
                    && !root.hardwareBlocked
                onClicked: root.previewDraft()
            }

            VfButton {
                visible: !root.selectionOnly
                Layout.fillWidth: true
                Layout.preferredWidth: VfTheme.dp(132)
                text: root.expanded ? "Ẩn tùy chỉnh" : "Tùy chỉnh giọng"
                tone: root.expanded ? "accent" : "neutral"
                onClicked: root.expanded = !root.expanded
            }
        }

        Rectangle {
            Layout.fillWidth: true
            visible: root.expanded && !root.selectionOnly
            implicitHeight: visible ? advancedColumn.implicitHeight + VfTheme.dp(14) : 0
            radius: VfTheme.dp(9)
            color: VfTheme.canvas
            border.color: root.providerBorder(root.provider)
            clip: true

            ColumnLayout {
                id: advancedColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: VfTheme.dp(7)
                }
                spacing: VfTheme.dp(6)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(7)
                    Text {
                        text: "Tùy chỉnh giọng · "
                            + root.providerLabel(root.provider)
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightStrong
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Chỉ các tùy chọn có tác dụng với provider hiện tại"
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                        elide: Text.ElideRight
                    }
                    VfButton {
                        visible: root.contextLabel !== "Voice Studio"
                        text: "Mở Voice Studio"
                        onClicked: root.openVoiceStudio()
                    }
                }

                ScrollView {
                    id: advancedScroll
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(
                        VfTheme.dp(360),
                        Math.max(VfTheme.dp(110), advancedLoader.implicitHeight))
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    Loader {
                        id: advancedLoader
                        width: advancedScroll.availableWidth
                        asynchronous: true
                        active: root.expanded
                        sourceComponent: SharedTtsAdvancedPanel {
                            width: advancedLoader.width
                            provider: root.provider
                            options: root.draft
                            engineInfo: root.engineInfo
                            onOptionChanged: (key, value) =>
                                root.updateDraft(key, value)
                            onOptionsPatched: values =>
                                root.updateDraftPatch(values)
                        }
                    }
                }
            }
        }
    }

    SharedTtsSidebarPanel {
        id: sidebarPanel
        visible: root.sidebarMode
        anchors.fill: parent

        providerChoices: root.providerChoices
        provider: root.provider
        providerDisplay: root.providerLabel(root.provider)
        accent: root.accent
        options: root.draft
        draftDirty: root.draftDirty
        busy: voiceController.narrationSelectionBusy
        hardwareBlocked: root.hardwareBlocked

        engineInfo: root.engineInfo

        modeLabel: root.modeLabel()
        modeOptions: root.modeOptions()
        modeValue: root.modeValue()
        voiceLabel: root.voiceFieldLabel()
        voiceOptions: root.voiceOptions()
        voiceValue: root.voiceValue()
        deliveryLabel: root.deliveryLabel()
        deliveryOptions: root.deliveryOptions()
        deliveryValue: root.deliveryValue()

        onProviderSelected: value => {
            sidebarPanel.selectedConfigPresetId = ""
            sidebarPanel.selectedConfigPresetName = ""
            root.selectProvider(value)
        }
        onModeSelected: value => root.setMode(value)
        onVoiceSelected: value => root.selectVoice(value)
        onDeliverySelected: value => root.setDelivery(value)
        onOptionChanged: (key, value) => root.updateDraft(key, value)
        onOptionsPatched: values => root.updateDraftPatch(values)
        onSaveRequested: root.submitDraft()
        onResetRequested: root.resetDraft()
        onPreviewRequested: root.previewDraft()
        onConfigPresetSelected: presetId => root.applyConfigPreset(presetId)
    }

    VoiceStudioProviderWorkbench {
        id: studioWorkbench
        visible: root.studioMode
        anchors.fill: parent

        providerChoices: root.providerChoices
        provider: root.provider
        providerDisplay: root.providerLabel(root.provider)
        accent: root.accent
        options: root.draft
        draftDirty: root.draftDirty
        busy: voiceController.narrationSelectionBusy
        hardwareBlocked: root.hardwareBlocked
        engineInfo: root.engineInfo

        modeLabel: root.modeLabel()
        modeOptions: root.modeOptions()
        modeValue: root.modeValue()
        voiceLabel: root.voiceFieldLabel()
        voiceOptions: root.voiceOptions()
        voiceValue: root.voiceValue()
        deliveryLabel: root.deliveryLabel()
        deliveryOptions: root.deliveryOptions()
        deliveryValue: root.deliveryValue()

        onProviderSelected: value => {
            studioWorkbench.selectedConfigPresetId = ""
            studioWorkbench.selectedConfigPresetName = ""
            root.selectProvider(value)
        }
        onModeSelected: value => root.setMode(value)
        onVoiceSelected: value => root.selectVoice(value)
        onDeliverySelected: value => root.setDelivery(value)
        onOptionChanged: (key, value) => root.updateDraft(key, value)
        onOptionsPatched: values => root.updateDraftPatch(values)
        onSaveRequested: root.submitDraft()
        onResetRequested: root.resetDraft()
        onPreviewRequested: root.previewDraft()
        onConfigPresetSelected: presetId => root.applyConfigPreset(presetId)
        onContinueRequested: root.continueToScriptRequested()
    }
}
