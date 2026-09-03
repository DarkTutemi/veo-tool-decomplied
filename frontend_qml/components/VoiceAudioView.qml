pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

// Voice Studio — AI Studio TTS workspace (audio only).
//
// Mirrors the AI Studio speech playground: one GLOBAL speaker config shared by
// the whole queue (1 or 2 speakers, each with voice + audio profile +
// Style/Pace/Accent), plus global Scene / Sample Context, plus the 8 built-in
// quickstart presets. Each queued job is just text — that is what makes batch
// work: import 100 files and they all run with this one config.
//
// Law 2: every text field commits through `commitTimer` (debounced), never per
// keystroke — configureProviderOptions used to be hit on every character.
Item {
    id: view
    objectName: "voiceAudioWorkspace"

    property string inputTab: "single"     // single | import
    property string rightTab: "queue"      // queue | history
    property string selectedModel: voiceController.models.length > 0 ? String(voiceController.models[0].value) : "default"
    property int importAdded: -1
    property string selectedQueueId: ""
    property var selectedQueueRow: ({})
    property string selectedHistoryPath: ""
    property var selectedHistoryRow: ({})
    property string inspectorTab: "overview"
    readonly property var outputRow: {
        if (view.rowAudioPath(view.selectedQueueRow).length > 0)
            return view.selectedQueueRow
        if (view.rowAudioPath(view.selectedHistoryRow).length > 0)
            return view.selectedHistoryRow
        return ({})
    }
    readonly property var outputAnalysis: view.rowAnalysis(view.outputRow)
    readonly property string outputPath: view.rowAudioPath(view.outputRow)
    readonly property var activeQueueRow: {
        var rows = voiceController.queueRows || []
        for (var i = 0; i < rows.length; i++) {
            var status = view.rowStatus(rows[i])
            if (status.indexOf("run") >= 0 || status.indexOf("generat") >= 0)
                return rows[i]
        }
        return ({})
    }

    // Gemini configuration is owned by the left rack. The workbench only reads
    // the saved/staged draft so authoring never grows a second config surface.
    readonly property bool dialogue: Boolean(
        (sharedTtsBar.draft || ({})).dialogue_enabled)

    Component.onCompleted: {
        view.syncSelectedQueueRow()
        view.syncSelectedHistoryRow()
    }

    function commitNow() {
        sharedTtsBar.submitDraft()
    }

    Connections {
        target: voiceController
        function onQueueRowsChanged() { view.syncSelectedQueueRow() }
        function onHistoryChanged() {
            var rows = voiceController.history || []
            if (rows.length > 0
                    && String((rows[0] || {}).job_id || "")
                    === String(voiceController.lastJobId || "")) {
                view.selectHistoryRow(rows[0])
                return
            }
            view.syncSelectedHistoryRow()
        }
    }

    // ── Import helpers (each TXT file = 1 job, each CSV row = 1 job) ───────────
    function importTxtFiles() {
        if (sharedTtsBar.hardwareBlocked
                || sharedTtsBar.voiceCreationOpen
                || !view.currentVoiceReady())
            return
        view.commitNow()
        var picked = nativeShell.pickFiles("Import TXT", "Text Files (*.txt *.md);;All Files (*.*)", "")
        if (!picked || !picked.ok) return
        var n = 0
        for (var i = 0; i < (picked.paths || []).length; i++) {
            var path = String(picked.paths[i] || "")
            var t = String(voiceController.importText(path) || "").trim()
            if (t.length > 0) {
                // Tên file làm tên hàng — 100 file import = 100 hàng gọn theo tên.
                var r = voiceController.addBlockToQueue(t, path.split(/[\\/]/).pop())
                if (r && r.ok) n++
            }
        }
        view.importAdded = n
    }
    function importCsvFiles() {
        if (sharedTtsBar.hardwareBlocked
                || sharedTtsBar.voiceCreationOpen
                || !view.currentVoiceReady())
            return
        view.commitNow()
        var pc = nativeShell.pickFiles("Import CSV", "CSV Files (*.csv);;All Files (*.*)", "")
        if (!pc || !pc.ok) return
        var n = 0
        for (var c = 0; c < (pc.paths || []).length; c++) {
            var res = voiceController.importCsv(String(pc.paths[c] || ""))
            if (res && res.ok) n += Number(res.added || 0)
        }
        view.importAdded = n
    }
    function addToQueue() {
        if (!view.currentVoiceReady() || sharedTtsBar.voiceCreationOpen)
            return
        view.commitNow()
        var body = String(scriptInput.text || "")
        // Tên hàng = dòng đầu (≤60 ký tự) — danh sách hàng đợi đọc được thay vì blob.
        voiceController.addBlockToQueue(body, body.trim().split("\n")[0].slice(0, 60))
    }

    function currentVoiceReady() {
        if (sharedTtsBar.provider !== "omnivoice")
            return true
        var options = sharedTtsBar.draft || ({})
        return String(
            options.omni_consumer_voice
            || (String(options.omni_mode || "") === "profile"
                ? options.omni_voice : "")
            || "").trim().length > 0
    }

    function currentExecutionVoiceId() {
        if (sharedTtsBar.provider !== "omnivoice")
            return sharedTtsBar.voiceValue()
        var options = sharedTtsBar.draft || ({})
        return String(
            options.omni_consumer_voice
            || (String(options.omni_mode || "") === "profile"
                ? options.omni_voice : "")
            || "")
    }

    function providerContextLabel() {
        if (sharedTtsBar.provider !== "omnivoice") {
            return sharedTtsBar.modeLabel() + ": "
                + sharedTtsBar.modeValue()
                + (sharedTtsBar.voiceValue().length > 0
                    ? "  ·  " + sharedTtsBar.voiceValue() : "")
        }
        if (sharedTtsBar.voiceCreationOpen)
            return qsTr("Đang tạo giọng") + "  ·  " + sharedTtsBar.modeValue()
        var profileId = view.currentExecutionVoiceId()
        return profileId.length > 0
            ? qsTr("Giọng đang dùng") + ": "
                + voiceController.omniVoiceLabel(profileId)
            : qsTr("Chưa chọn giọng để tạo audio")
    }

    function generateNow() {
        if (sharedTtsBar.hardwareBlocked
                || sharedTtsBar.voiceCreationOpen
                || !view.currentVoiceReady())
            return
        var body = String(scriptInput.text || "").trim()
        if (body.length < 1)
            return
        view.commitNow()
        voiceController.generateSingle(
            body,
            view.currentExecutionVoiceId(),
            sharedTtsBar.provider === "gemini"
                ? sharedTtsBar.modeValue() : view.selectedModel)
    }

    function chooseOutputFolder() {
        var folder = nativeShell.pickFolder(
            "Chọn thư mục lưu file âm thanh",
            String(voiceController.outputFolder || ""))
        if (folder && folder.ok)
            voiceController.setOutputFolder(String(folder.path || ""))
    }

    function fmtTime(seconds) {
        var s = Math.max(0, Math.round(Number(seconds) || 0))
        return Math.floor(s / 60) + ":" + ("0" + (s % 60)).slice(-2)
    }

    function wordCount(text) {
        var clean = String(text || "").trim()
        return clean.length > 0 ? clean.split(/\s+/).length : 0
    }

    function estimatedSeconds(text) {
        // Narration estimate only; the rendered duration remains provider-owned.
        return Math.round(view.wordCount(text) / 2.5)
    }

    function segmentCount(text) {
        var clean = String(text || "").trim()
        if (clean.length < 1)
            return 0
        var blocks = clean.split(/\n\s*\n+/).filter(function(value) {
            return String(value || "").trim().length > 0
        })
        return Math.max(1, blocks.length)
    }

    function insertVoiceTag(tag) {
        var value = String(tag || "")
        if (value.length < 1)
            return
        var position = Math.max(0, Number(scriptInput.cursorPosition) || 0)
        scriptInput.insert(position, value + " ")
        scriptInput.cursorPosition = position + value.length + 1
        scriptInput.forceActiveFocus()
    }

    function playOutput() {
        if (voiceController.playbackActive) {
            voiceController.stopPlayback()
            return
        }
        if (view.outputPath.length > 0)
            voiceController.playAudio(view.outputPath)
        else
            view.previewCurrentText()
    }

    function rowText(row) {
        var item = row || ({})
        var direct = String(item.prompt || item.text || item.idea || "")
        if (direct.length > 0)
            return direct
        var prompts = item.prompts || []
        if (prompts.length > 0) {
            var first = prompts[0] || ({})
            return String(first.prompt || first.text || first.value || first)
        }
        return ""
    }

    function fmtBytes(value) {
        var bytes = Math.max(0, Number(value) || 0)
        if (bytes >= 1024 * 1024)
            return (bytes / (1024 * 1024)).toFixed(1) + " MB"
        if (bytes >= 1024)
            return (bytes / 1024).toFixed(0) + " KB"
        return String(Math.round(bytes)) + " B"
    }

    function queueProgress() {
        var stats = voiceController.stats || ({})
        var total = Math.max(0, Number(stats.total || 0))
        if (total < 1)
            return 0
        return Math.min(1, (Number(stats.completed || 0) + Number(stats.failed || 0)) / total)
    }

    function historyBytes() {
        var total = 0
        var rows = voiceController.history || []
        for (var i = 0; i < rows.length; i++)
            total += Math.max(0, Number((rows[i] || {}).size_bytes || 0))
        return total
    }

    function rowOptions(row) {
        var item = row || ({})
        var meta = item.meta || ({})
        return item.provider_options || meta.provider_options || ({})
    }

    function rowRouteLabel(row) {
        var item = row || ({})
        var opts = view.rowOptions(item)
        var route = String(opts.tts_route || item.provider || "gemini").toLowerCase()
        if (route === "aistudio" || route === "gemini") return "AI Studio"
        if (route === "omnivoice") return "OmniVoice"
        if (route === "moss") return "MOSS TTS"
        if (route === "vieneu") return "VieNeu"
        return route.length > 0 ? route : "Tự động"
    }

    function rowVoiceLabel(row) {
        var item = row || ({})
        var opts = view.rowOptions(item)
        var route = String(opts.tts_route || "").toLowerCase()
        if (route === "omnivoice")
            return String(opts.omni_voice || opts.omni_recipe || opts.omni_mode || "Tự động")
        if (route === "vieneu")
            return String(opts.vieneu_voice || "Tự động")
        if (route === "moss")
            return String(opts.moss_mode || "Direct")
        var speakers = opts.speakers || []
        if (speakers.length > 0) {
            var names = []
            for (var i = 0; i < Math.min(2, speakers.length); i++)
                names.push(String((speakers[i] || {}).voice || (speakers[i] || {}).name || ""))
            return names.filter(function(value) { return value.length > 0 }).join(" + ")
        }
        return String(item.voice_id || item.voice || "Tự động")
    }

    function rowQualityLabel(row) {
        var item = row || ({})
        var opts = view.rowOptions(item)
        var route = String(opts.tts_route || "").toLowerCase()
        if (route === "omnivoice")
            return String(opts.omni_num_step || "32") + " steps"
        if (route === "vieneu")
            return String(opts.vieneu_precision || "auto")
        if (route === "moss")
            return String(opts.moss_language || "auto").toUpperCase()
        return String(item.model || "Gemini TTS")
    }

    function rowAnalysis(row) {
        var item = row || ({})
        var meta = item.meta || ({})
        return item.audio_analysis || meta.audio_analysis || ({})
    }

    function runtimeValue(row, key, fallback) {
        var item = row || ({})
        var meta = item.meta || ({})
        var value = item[key]
        if (value === undefined || value === null || value === "")
            value = meta[key]
        return value === undefined || value === null || value === "" ? fallback : value
    }

    function rowError(row) {
        var item = row || ({})
        var meta = item.meta || ({})
        var value = String(item.error_message || meta.error_message || "")
        if (value === "skipped_by_user") return "Đã bỏ qua theo yêu cầu"
        if (value === "stopped_by_user") return "Đã dừng theo yêu cầu"
        return value
    }

    function selectQueueRow(row) {
        var item = Object.assign({}, row || ({}))
        view.selectedQueueId = view.queueRowId(item)
        view.selectedQueueRow = item
    }

    function syncSelectedQueueRow() {
        var rows = voiceController.queueRows || []
        if (rows.length < 1) {
            view.selectedQueueId = ""
            view.selectedQueueRow = ({})
            return
        }
        var match = null
        for (var i = 0; i < rows.length; i++) {
            if (view.queueRowId(rows[i]) === view.selectedQueueId) {
                match = rows[i]
                break
            }
        }
        view.selectQueueRow(match || rows[0])
    }

    function selectHistoryRow(row) {
        var item = Object.assign({}, row || ({}))
        view.selectedHistoryPath = String(item.path || "")
        view.selectedHistoryRow = item
    }

    function syncSelectedHistoryRow() {
        var rows = voiceController.history || []
        if (rows.length < 1) {
            view.selectedHistoryPath = ""
            view.selectedHistoryRow = ({})
            return
        }
        var match = null
        for (var i = 0; i < rows.length; i++) {
            if (String((rows[i] || {}).path || "") === view.selectedHistoryPath) {
                match = rows[i]
                break
            }
        }
        view.selectHistoryRow(match || rows[0])
    }

    function previewCurrentText() {
        if (sharedTtsBar.hardwareBlocked
                || sharedTtsBar.voiceCreationOpen
                || !view.currentVoiceReady())
            return
        view.commitNow()
        var selected = String(scriptInput.selectedText || "").trim()
        var sample = selected.length > 0
            ? selected : String(scriptInput.text || "").trim().slice(0, 600)
        voiceController.previewNarrationSelection(
            sharedTtsBar.provider, sharedTtsBar.draft, sample)
    }

    // ── Queue-row helpers ─────────────────────────────────────────────────────
    function queueRowId(row) { return String((row || {}).id || (row || {}).row_id || (row || {}).job_id || "") }
    function rowAudioPath(row) { var r = row || ({}); return String(r.audio_path || r.path || r.output_path || r.saved_audio_path || r.result_path || "") }
    function rowStatus(row) { return String((row || {}).status || (row || {}).state || "pending").toLowerCase() }
    function isFailed(row) { var s = view.rowStatus(row); return s.indexOf("fail") >= 0 || s.indexOf("error") >= 0 || s.indexOf("skip") >= 0 }
    function isPendingRun(row) { var s = view.rowStatus(row); return s.indexOf("pend") >= 0 || s.indexOf("queue") >= 0 || s.indexOf("wait") >= 0 }
    function isDone(row) { var s = view.rowStatus(row); return s.indexOf("complete") >= 0 || s === "generated" || s === "done" }
    function mergeHistory() {
        var paths = [], h = voiceController.history || []
        for (var i = h.length - 1; i >= 0; i--) { var p = String((h[i] || {}).path || ""); if (p.length > 0) paths.push(p) }
        var r = voiceController.mergeAudio(paths)
        if (r && r.ok && String(r.path || "").length > 0) voiceController.playAudio(String(r.path || ""))
    }

    // Quick hand-off: đẩy WAV đã sinh sang tab Transcript (Audio → Video) làm
    // audio card đầu vào. Cards là per-route nên PHẢI setRoute("transcript")
    // trước addLocalFiles, không thì card rơi vào bucket của route đang mở.
    function sendToTranscript(path) {
        var p = String(path || "")
        if (!p.length)
            return
        appController.setRoute("transcript")
        if (String(appController.route) !== "transcript")
            return   // route bị gate (license) — không stage ngầm
        workPanelController.setRoute("transcript")
        workPanelController.addLocalFiles([p], "transcript_audio")
    }

    // Tour-only disclosure. These fields are local UI state, so the walkthrough
    // can show every region without persisting provider or job configuration.
    function tourActivateSection(action) {
        var value = String(action || "")
        if (value === "voice:single")
            view.inputTab = "single"
        else if (value === "voice:import")
            view.inputTab = "import"
        else if (value === "voice:queue")
            view.rightTab = "queue"
        else if (value === "voice:history")
            view.rightTab = "history"
    }

    // ── Layout ────────────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing: VfTheme.dp(8)

        Rectangle {
            objectName: "voiceProviderStatus"
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(58)
            Layout.minimumHeight: Layout.preferredHeight
            Layout.maximumHeight: Layout.preferredHeight
            radius: VfTheme.dp(11)
            color: sharedTtsBar.statusFill()
            border.color: sharedTtsBar.statusTextColor()

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: VfTheme.dp(11)
                    rightMargin: VfTheme.dp(10)
                }
                spacing: VfTheme.dp(9)
                VfAppIcon {
                    name: sharedTtsBar.provider === "gemini"
                        ? "voice-provider-gemini"
                        : sharedTtsBar.provider === "omnivoice"
                            ? "voice-provider-omni"
                            : sharedTtsBar.provider === "moss"
                                ? "voice-provider-moss"
                                : "voice-provider-vieneu"
                    size: VfTheme.dp(28)
                    framed: true
                    frameColor: VfTheme.surface
                    color: sharedTtsBar.statusTextColor()
                }
                RowLayout {
                    objectName: "voiceProviderChipRow"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: VfTheme.dp(6)

                    Repeater {
                        model: sharedTtsBar.providerChoices || []

                        delegate: Rectangle {
                            id: bannerProviderChip
                            required property var modelData

                            readonly property string providerValue:
                                String(modelData.value || "gemini")
                            readonly property bool selected:
                                providerValue === sharedTtsBar.provider
                            readonly property bool blocked:
                                modelData.disabled === true
                            readonly property color chipAccent:
                                sharedTtsBar.providerColor(providerValue)

                            Layout.preferredHeight: VfTheme.dp(36)
                            Layout.alignment: Qt.AlignVCenter
                            implicitWidth: chipRow.implicitWidth + VfTheme.dp(18)
                            radius: VfTheme.dp(9)
                            color: VfTheme.surface
                            border.width: selected ? 2 : 1
                            border.color: selected || activeFocus
                                ? chipAccent : VfTheme.borderSoft
                            opacity: blocked ? 0.55 : 1
                            activeFocusOnTab: !blocked
                            Accessible.role: Accessible.Button
                            Accessible.name: modelData.label || providerValue

                            Row {
                                id: chipRow
                                anchors.centerIn: parent
                                spacing: VfTheme.dp(6)

                                VfAppIcon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: bannerProviderChip.providerValue === "omnivoice"
                                        ? "voice-provider-omni"
                                        : bannerProviderChip.providerValue === "moss"
                                            ? "voice-provider-moss"
                                            : bannerProviderChip.providerValue === "vieneu"
                                                ? "voice-provider-vieneu"
                                                : "voice-provider-gemini"
                                    size: VfTheme.dp(16)
                                    framed: false
                                    color: bannerProviderChip.chipAccent
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: String(bannerProviderChip.modelData.label
                                                 || bannerProviderChip.providerValue)
                                    color: bannerProviderChip.selected
                                        ? bannerProviderChip.chipAccent : VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    font.weight: bannerProviderChip.selected
                                        ? VfTheme.weightStrong : VfTheme.weightRegular
                                }
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: VfTheme.dp(7)
                                    height: width
                                    radius: width / 2
                                    color: bannerProviderChip.blocked
                                        ? VfTheme.redBorder
                                        : String(bannerProviderChip.modelData.warning || "").length > 0
                                            ? VfTheme.amber : VfTheme.greenBorder
                                }
                            }

                            Keys.onReturnPressed: if (!bannerProviderChip.blocked)
                                sharedTtsBar.selectProviderFromShortcut(bannerProviderChip.providerValue)
                            Keys.onEnterPressed: if (!bannerProviderChip.blocked)
                                sharedTtsBar.selectProviderFromShortcut(bannerProviderChip.providerValue)
                            Keys.onSpacePressed: if (!bannerProviderChip.blocked)
                                sharedTtsBar.selectProviderFromShortcut(bannerProviderChip.providerValue)
                            HoverHandler { id: bannerChipHover }
                            ToolTip.visible: bannerChipHover.hovered
                            ToolTip.text: bannerProviderChip.blocked
                                ? String(bannerProviderChip.modelData.reason
                                         || "Phần cứng không đáp ứng")
                                : String(bannerProviderChip.modelData.warning || "")
                            ToolTip.delay: 350
                            MouseArea {
                                anchors.fill: parent
                                enabled: !bannerProviderChip.blocked
                                cursorShape: enabled
                                    ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                                onClicked: {
                                    bannerProviderChip.forceActiveFocus()
                                    sharedTtsBar.selectProviderFromShortcut(
                                        bannerProviderChip.providerValue)
                                }
                            }
                        }
                    }
                }
                ColumnLayout {
                    id: providerStatusHeader
                    Layout.fillWidth: true
                    spacing: 0
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(7)
                        Text {
                            text: "VOICE STUDIO"
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                            font.weight: VfTheme.weightStrong
                            font.letterSpacing: VfTheme.dp(0.5)
                        }
                        Text {
                            text: sharedTtsBar.providerLabel(
                                sharedTtsBar.provider)
                            color: sharedTtsBar.statusTextColor()
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            font.weight: VfTheme.weightStrong
                        }
                        Text {
                            Layout.fillWidth: true
                            text: view.providerContextLabel()
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideRight
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: view.queueRowId(view.activeQueueRow).length > 0
                            ? String(view.activeQueueRow.name || "Đang tạo voice")
                                + "  ·  " + String(view.runtimeValue(
                                    view.activeQueueRow, "runtime_message",
                                    "Đang xử lý"))
                            : sharedTtsBar.statusTitle() + "  ·  "
                                + sharedTtsBar.statusDetail()
                        color: sharedTtsBar.statusTextColor()
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                        elide: Text.ElideRight
                    }
                }
                StudioMetric {
                    label: view.queueRowId(view.activeQueueRow).length > 0
                        ? "TIẾN ĐỘ"
                        : (sharedTtsBar.provider === "gemini" ? "TỪ" : "GPU")
                    value: view.queueRowId(view.activeQueueRow).length > 0
                        ? String(view.runtimeValue(view.activeQueueRow,
                            "runtime_progress", 0)) + "%"
                        : sharedTtsBar.provider === "gemini"
                        ? String(view.wordCount(scriptInput.text))
                        : Number((voiceController.runtimeTelemetry || {}).gpu_percent
                            || 0).toFixed(0) + "% · "
                            + Number((voiceController.runtimeTelemetry || {}).gpu_temperature_c
                                || 0).toFixed(0) + "°"
                    accent: VfTheme.primary
                }
                StudioMetric {
                    label: view.queueRowId(view.activeQueueRow).length > 0
                        ? "ĐÃ CHẠY"
                        : (sharedTtsBar.provider === "gemini"
                            ? "ƯỚC TÍNH" : "VRAM")
                    value: view.queueRowId(view.activeQueueRow).length > 0
                        ? view.fmtTime(view.runtimeValue(view.activeQueueRow,
                            "runtime_elapsed_seconds", 0))
                        : sharedTtsBar.provider === "gemini"
                        ? view.fmtTime(view.estimatedSeconds(scriptInput.text))
                        : Number((voiceController.runtimeTelemetry || {}).vram_used_gb
                            || 0).toFixed(1) + "/"
                            + Number((voiceController.runtimeTelemetry || {}).vram_total_gb
                                || 0).toFixed(1) + "G"
                    accent: VfTheme.violet
                }
                StudioMetric {
                    label: view.queueRowId(view.activeQueueRow).length > 0
                        ? "ETA"
                        : (sharedTtsBar.provider === "gemini" ? "JOB" : "RAM")
                    value: view.queueRowId(view.activeQueueRow).length > 0
                        ? view.fmtTime(view.runtimeValue(view.activeQueueRow,
                            "runtime_eta_seconds", 0))
                        : sharedTtsBar.provider === "gemini"
                        ? String((voiceController.stats || {}).total || 0)
                        : Number((voiceController.runtimeTelemetry || {}).ram_used_gb
                            || 0).toFixed(1) + "/"
                            + Number((voiceController.runtimeTelemetry || {}).ram_total_gb
                                || 0).toFixed(1) + "G"
                    accent: VfTheme.greenText
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: VfTheme.dp(10)

            // Preserve the original Voice Studio split: provider production,
            // script and output all belong to the flexible left workspace;
            // queue/history stays pinned in the right rail from the top.
            ColumnLayout {
                objectName: "leftVoiceWorkspace"
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: VfTheme.dp(8)

                SharedTtsInlinePanel {
                    id: sharedTtsBar
                    objectName: "voiceSharedTtsBar"
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight
                    Layout.minimumHeight: implicitHeight
                    Layout.maximumHeight: implicitHeight
                    contextLabel: "Voice Studio"
                    presentation: "studio"
                    onContinueToScriptRequested: {
                        view.inputTab = "single"
                        Qt.callLater(function() {
                            scriptInput.forceActiveFocus()
                        })
                    }
                }

                // BLOCK 2 — the authoring canvas remains the dominant flexible column.
                ColumnLayout {
                    objectName: "mainWorkBlock"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: VfTheme.dp(8)

            // BLOCK 2 header — content mode stays beside the editor instead of
            // sharing space with provider configuration.
            Rectangle {
                objectName: "voiceInputTabs"   // tour target
                Layout.fillWidth: true
                implicitHeight: VfTheme.dp(50)
                radius: VfTheme.dp(10)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderSoft

                RowLayout {
                    id: inputTabsRow
                    anchors {
                        fill: parent
                        leftMargin: VfTheme.dp(8)
                        rightMargin: VfTheme.dp(8)
                    }
                    spacing: VfTheme.dp(6)

                    VfAppIcon {
                        name: "voice-content"
                        size: VfTheme.dp(25)
                        framed: true
                        frameColor: VfTheme.blueFill
                        color: VfTheme.primary
                    }
                    Text {
                        text: "SCRIPT"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightStrong
                    }
                    TabBtn { text: (void i18n.revision, i18n.t("voice_studio.mode_single", "Đơn")); selected: view.inputTab === "single"; onClicked: view.inputTab = "single" }
                    TabBtn { text: (void i18n.revision, i18n.t("voice_studio.mode_import", "Import")); selected: view.inputTab === "import"; onClicked: view.inputTab = "import" }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: String(scriptInput.text.length) + " ký tự  ·  "
                            + String(view.wordCount(scriptInput.text)) + " từ"
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                    }
                    Rectangle {
                        implicitWidth: activeProviderText.implicitWidth
                            + VfTheme.dp(18)
                        implicitHeight: VfTheme.dp(28)
                        radius: VfTheme.dp(9)
                        color: VfTheme.violetFill
                        border.color: VfTheme.violetBorderSoft
                        Text {
                            id: activeProviderText
                            anchors.centerIn: parent
                            text: sharedTtsBar.providerLabel(
                                sharedTtsBar.provider)
                            color: VfTheme.violetText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            font.weight: VfTheme.weightStrong
                        }
                    }
                }
            }

            Rectangle {
                objectName: "voiceScriptTools"
                visible: view.inputTab === "import"
                    || sharedTtsBar.provider === "moss"
                    || sharedTtsBar.provider === "vieneu"
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? VfTheme.dp(40) : 0
                Layout.minimumHeight: Layout.preferredHeight
                Layout.maximumHeight: Layout.preferredHeight
                radius: VfTheme.dp(9)
                color: VfTheme.surface
                border.color: VfTheme.borderSoft

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: VfTheme.dp(7)
                        rightMargin: VfTheme.dp(8)
                    }
                    spacing: VfTheme.dp(5)

                    VfButton {
                        id: pauseTagButton
                        visible: view.inputTab !== "import"
                            && sharedTtsBar.provider === "moss"
                        text: "Chèn nhịp nghỉ"
                        leadingIcon: "plus"
                        compact: true
                        onClicked: pauseTagMenu.popup()
                    }
                    Text {
                        visible: view.inputTab !== "import"
                            && sharedTtsBar.provider === "vieneu"
                        text: "VieNeu chưa có công cụ script riêng được backend xác nhận."
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                    }
                    Text {
                        visible: view.inputTab === "import"
                        text: "TXT: mỗi file là một job  ·  CSV: mỗi dòng là một job  ·  dùng chung cấu hình provider."
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        visible: view.inputTab !== "import"
                        text: String(view.segmentCount(scriptInput.text))
                            + " khối văn bản"
                            + "  ·  " + view.fmtTime(view.estimatedSeconds(scriptInput.text))
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                    }
                }
            }

            // ── Input area ─────────────────────────────────────────────────
            Rectangle {
                objectName: "inputArea"
                Layout.fillWidth: true; Layout.fillHeight: true
                radius: VfTheme.dp(8); color: VfTheme.surface; border.color: VfTheme.borderBox; clip: true

                TextArea {
                    id: scriptInput
                    objectName: "voiceSingleInput"
                    visible: view.inputTab !== "import"
                    anchors.fill: parent; anchors.margins: VfTheme.dp(12); wrapMode: TextArea.Wrap
                    placeholderText: (view.dialogue
                                      && sharedTtsBar.provider === "gemini")
                        ? (void i18n.revision, i18n.t(
                            "voice_studio.text_placeholder_dialogue",
                            "Speaker 1: ...\nSpeaker 2: ..."))
                        : (void i18n.revision, i18n.t("voice_studio.text_placeholder", "Dán / gõ văn bản cần đọc..."))
                    font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(14); selectByMouse: true
                    background: Rectangle { color: "transparent" }
                }

                ColumnLayout {
                    objectName: "voiceImportArea"
                    visible: view.inputTab === "import"
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(18)
                    spacing: VfTheme.dp(8)
                    Item { Layout.fillHeight: true }
                    VfAppIcon {
                        Layout.alignment: Qt.AlignHCenter
                        name: "voice-content"
                        size: VfTheme.dp(52)
                        framed: true
                        frameColor: VfTheme.blueFill
                        color: VfTheme.primary
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: (void i18n.revision, i18n.t("voice_studio.import_title", "Import hàng loạt vào hàng đợi"))
                        color: VfTheme.text; font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontBody; font.weight: VfTheme.weightStrong
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.maximumWidth: VfTheme.dp(620)
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: (void i18n.revision, i18n.t("voice_studio.import_rule", "Mỗi file TXT = 1 job · mỗi dòng CSV = 1 job. Tất cả dùng chung cấu hình giọng ở trên."))
                        color: VfTheme.textMuted; font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall; wrapMode: Text.WordWrap
                    }
                    Rectangle {
                        visible: view.importAdded >= 0
                        Layout.preferredWidth: VfTheme.dp(360)
                        Layout.alignment: Qt.AlignHCenter
                        implicitHeight: VfTheme.dp(38); radius: VfTheme.dp(8)
                        color: VfTheme.greenFill; border.color: VfTheme.greenBorderSoft
                        Text {
                            anchors.centerIn: parent
                            text: (void i18n.revision, i18n.t("voice_studio.import_added", "Đã thêm {count} job vào hàng đợi")).replace("{count}", String(view.importAdded))
                            color: "#16A34A"; font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall; font.weight: VfTheme.weightStrong
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            // The primary action belongs directly to its input. Output review
            // comes afterward, matching the human sequence: write → create → inspect.
            RowLayout {
                visible: view.inputTab !== "import"
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(48)
                spacing: VfTheme.dp(8)
                VfButton {
                    visible: scriptInput.selectedText.length > 0
                    minWidth: VfTheme.dp(150)
                    Layout.preferredHeight: VfTheme.dp(48)
                    text: "Tạo mẫu đoạn chọn"
                    leadingIcon: "loudspeaker"
                    enabled: !voiceController.busy
                        && !voiceController.narrationSelectionBusy
                        && !sharedTtsBar.hardwareBlocked
                        && !sharedTtsBar.voiceCreationOpen
                        && view.currentVoiceReady()
                    onClicked: view.previewCurrentText()
                }
                Item {
                    Layout.fillWidth: true
                }
                VfButton {
                    objectName: "voiceGenerateNow"
                    Layout.preferredWidth: VfTheme.dp(180)
                    Layout.preferredHeight: VfTheme.dp(48)
                    text: voiceController.busy
                        ? qsTr("Đang tạo audio…") : qsTr("Tạo audio")
                    leadingIcon: "loudspeaker"
                    tone: "accent"
                    enabled: !voiceController.busy
                        && !voiceController.narrationSelectionBusy
                        && !sharedTtsBar.hardwareBlocked
                        && !sharedTtsBar.voiceCreationOpen
                        && view.currentVoiceReady()
                        && String(scriptInput.text || "").trim().length > 0
                    onClicked: view.generateNow()
                }
                VfButton {
                    objectName: "voiceAddQueue"   // tour target
                    Layout.preferredWidth: VfTheme.dp(210)
                    Layout.preferredHeight: VfTheme.dp(48)
                    text: qsTr("Thêm vào hàng đợi")
                    leadingIcon: "plus"
                    // Thêm job mới là THAO TÁC VÀO HÀNG ĐỢI — hợp lệ cả khi
                    // audio đang chạy; job tự mang snapshot giọng của lúc thêm.
                    enabled: !sharedTtsBar.hardwareBlocked
                        && !sharedTtsBar.voiceCreationOpen
                        && view.currentVoiceReady()
                        && String(scriptInput.text || "").trim().length > 0
                    onClicked: view.addToQueue()
                }
                VfButton {
                    objectName: "voiceStopActions"
                    visible: voiceController.busy
                    Layout.preferredHeight: VfTheme.dp(48)
                    text: qsTr("Dừng")
                    leadingIcon: "stop-sign"
                    tone: "danger"
                    onClicked: voiceController.stopCurrentGeneration()
                }
            }

            RowLayout {
                visible: view.inputTab === "import"
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(48)
                spacing: VfTheme.dp(8)
                VfButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(48)
                    text: (void i18n.revision,
                        i18n.t("voice_studio.import_txt", "Import file TXT / Markdown"))
                    leadingIcon: "voice-content"
                    enabled: !sharedTtsBar.hardwareBlocked
                        && !sharedTtsBar.voiceCreationOpen
                        && view.currentVoiceReady()
                    onClicked: view.importTxtFiles()
                }
                VfButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(48)
                    text: (void i18n.revision,
                        i18n.t("voice_studio.import_csv", "Import bảng CSV"))
                    leadingIcon: "voice-content"
                    tone: "accent"
                    enabled: !sharedTtsBar.hardwareBlocked
                        && !sharedTtsBar.voiceCreationOpen
                        && view.currentVoiceReady()
                    onClicked: view.importCsvFiles()
                }
            }

            Rectangle {
                id: outputInspector
                objectName: "voiceOutputInspector"
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(160)
                Layout.minimumHeight: Layout.preferredHeight
                Layout.maximumHeight: Layout.preferredHeight
                radius: VfTheme.dp(10)
                color: VfTheme.surface
                border.color: VfTheme.violetBorderSoft
                property real elapsed: 0
                readonly property real totalDuration: Number(
                    view.outputAnalysis.duration_seconds
                    || voiceController.playbackDuration || 0)

                Timer {
                    interval: 200
                    repeat: true
                    running: outputInspector.visible && voiceController.playbackActive
                    onTriggered: {
                        outputInspector.elapsed = Math.min(
                            outputInspector.totalDuration,
                            Math.max(0, (Date.now()
                                - Number(voiceController.playbackStartedAt)) / 1000))
                        outputWaveform.requestPaint()
                    }
                }
                Connections {
                    target: voiceController
                    function onPlaybackChanged() {
                        if (voiceController.playbackActive)
                            outputInspector.elapsed = 0
                    }
                }

                ColumnLayout {
                    anchors { fill: parent; margins: VfTheme.dp(9) }
                    spacing: VfTheme.dp(7)
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(30)
                        spacing: VfTheme.dp(5)
                        Text {
                            text: "OUTPUT INSPECTOR"
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            font.weight: VfTheme.weightStrong
                            font.letterSpacing: VfTheme.dp(0.4)
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            Layout.maximumWidth: VfTheme.dp(300)
                            text: voiceController.statusMessage
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(68)
                        radius: VfTheme.dp(9)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.borderSoft
                        RowLayout {
                            anchors { fill: parent; margins: VfTheme.dp(7) }
                            spacing: VfTheme.dp(8)
                            IconBtn {
                                implicitWidth: VfTheme.dp(40)
                                implicitHeight: VfTheme.dp(40)
                                radius: VfTheme.dp(20)
                                icon: voiceController.playbackActive
                                    ? "stop-sign" : "play"
                                tint: voiceController.playbackActive
                                    ? VfTheme.redText : VfTheme.primary
                                enabled: view.outputPath.length > 0
                                    || (!sharedTtsBar.hardwareBlocked
                                        && !sharedTtsBar.voiceCreationOpen
                                        && view.currentVoiceReady()
                                        && String(scriptInput.text || "").trim().length > 0)
                                onClicked: view.playOutput()
                            }
                            Text {
                                text: view.fmtTime(outputInspector.elapsed)
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: VfTheme.weightStrong
                            }
                            Canvas {
                                id: outputWaveform
                                objectName: "voiceOutputWaveform"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                antialiasing: true
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.clearRect(0, 0, width, height)
                                    var data = view.outputAnalysis.waveform || []
                                    ctx.fillStyle = String(VfTheme.violet)
                                    if (data.length < 1) {
                                        ctx.globalAlpha = 0.22
                                        ctx.fillRect(0, height / 2, width, 1)
                                        ctx.globalAlpha = 1
                                        return
                                    }
                                    var step = width / data.length
                                    for (var i = 0; i < data.length; i++) {
                                        var h = Math.max(1,
                                            Number(data[i]) * (height - 8))
                                        ctx.fillRect(i * step, (height - h) / 2,
                                            Math.max(1, step - 1), h)
                                    }
                                    if (outputInspector.totalDuration > 0) {
                                        ctx.fillStyle = String(VfTheme.primary)
                                        var progress = Math.min(1,
                                            outputInspector.elapsed
                                            / outputInspector.totalDuration)
                                        ctx.fillRect(width * progress, 1, 2, height - 2)
                                    }
                                }
                                Connections {
                                    target: view
                                    function onOutputRowChanged() {
                                        outputWaveform.requestPaint()
                                    }
                                }
                                Connections {
                                    target: voiceController
                                    function onPlaybackChanged() {
                                        outputWaveform.requestPaint()
                                    }
                                }
                                onVisibleChanged: if (visible) requestPaint()
                            }
                            Text {
                                text: view.fmtTime(outputInspector.totalDuration)
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: VfTheme.dp(5)
                        OutputFact {
                            label: "SAMPLE RATE"
                            value: view.outputAnalysis.sample_rate
                                ? Math.round(Number(view.outputAnalysis.sample_rate) / 1000) + " kHz" : "—"
                        }
                        OutputFact {
                            label: "CHANNELS"
                            value: Number(view.outputAnalysis.channels || 0) === 1
                                ? "Mono" : (Number(view.outputAnalysis.channels || 0) === 2 ? "Stereo" : "—")
                        }
                        OutputFact {
                            label: "LOUDNESS"
                            value: view.outputAnalysis.loudness_lufs !== undefined
                                ? Number(view.outputAnalysis.loudness_lufs).toFixed(1) + " LUFS" : "—"
                        }
                        OutputFact {
                            label: "PEAK"
                            value: view.outputAnalysis.true_peak_dbfs !== undefined
                                ? Number(view.outputAnalysis.true_peak_dbfs).toFixed(1) + " dB" : "—"
                        }
                        OutputFact {
                            label: "RTF"
                            value: Number(view.runtimeValue(view.outputRow,
                                "runtime_rtf", 0)).toFixed(2) + "x"
                        }
                        OutputFact {
                            label: "FILE SIZE"
                            value: view.fmtBytes(view.outputAnalysis.size_bytes
                                || view.outputRow.size_bytes || 0)
                        }
                        Item { Layout.fillWidth: true }
                        VfButton {
                            text: "Mở thư mục"
                            leadingIcon: "open-folder"
                            compact: true
                            enabled: String(voiceController.outputFolder || "").length > 0
                            onClicked: nativeShell.openPath(
                                String(voiceController.outputFolder || ""))
                        }
                        VfButton {
                            text: "Gửi sang Video"
                            leadingIcon: "movie-camera"
                            tone: "primary"
                            compact: true
                            enabled: view.outputPath.length > 0
                            onClicked: view.sendToTranscript(view.outputPath)
                        }
                    }
                }
            }

                }
            }

            // RIGHT — queue / history. Ghim CỨNG bề rộng (min=pref=max): chỉ có
            // preferredWidth thì khi cột trái đổi implicit (vd tab Import) RowLayout
            // phân bố lại và panel phải nở/bẹp tuỳ hứng — layout "vỡ" theo tab.
            ColumnLayout {
                objectName: "rightPanel"
                Layout.preferredWidth: VfTheme.dp(370)
                Layout.minimumWidth: Layout.preferredWidth
                Layout.maximumWidth: Layout.preferredWidth
                Layout.fillHeight: true
                spacing: VfTheme.dp(8)

            Rectangle {
                objectName: "voiceRightTabs"   // tour target
                Layout.fillWidth: true; implicitHeight: VfTheme.dp(42)
                radius: VfTheme.dp(12); color: VfTheme.surfaceSoft
                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: VfTheme.dp(6)
                        rightMargin: VfTheme.dp(6)
                    }
                    spacing: VfTheme.dp(6)
                    VfAppIcon {
                        name: "voice-queue"
                        size: VfTheme.dp(22)
                        framed: true
                        frameColor: VfTheme.violetFill
                        color: VfTheme.violet
                    }
                    TabBtn { text: (void i18n.revision, i18n.t("voice_studio.queue", "Hàng đợi")) + " (" + voiceController.queueRows.length + ")"; selected: view.rightTab === "queue"; onClicked: view.rightTab = "queue" }
                    TabBtn { text: (void i18n.revision, i18n.t("voice_studio.history", "Lịch sử")); selected: view.rightTab === "history"; onClicked: view.rightTab = "history" }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: String((voiceController.stats || {}).completed || 0)
                            + " xong  ·  " + String((voiceController.stats || {}).failed || 0)
                            + " lỗi"
                        color: Number((voiceController.stats || {}).failed || 0) > 0
                            ? VfTheme.redText : VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                    }
                }
            }

            // Output destination belongs to the execution/queue block. It is
            // intentionally shown once and never competes with the editor.
            Rectangle {
                objectName: "voiceOutputFolder"
                Layout.fillWidth: true
                implicitHeight: VfTheme.dp(66)
                radius: VfTheme.dp(10)
                color: VfTheme.blueFill
                border.color: VfTheme.blueBorderSoft

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: VfTheme.dp(9)
                        rightMargin: VfTheme.dp(8)
                        topMargin: VfTheme.dp(7)
                        bottomMargin: VfTheme.dp(7)
                    }
                    spacing: VfTheme.dp(8)

                    VfAppIcon {
                        name: "voice-output"
                        size: VfTheme.dp(26)
                        framed: true
                        frameColor: VfTheme.surface
                        color: VfTheme.primary
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text {
                            Layout.fillWidth: true
                            text: "THƯ MỤC LƯU"
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            font.weight: VfTheme.weightStrong
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: String(voiceController.outputFolder || "").length > 0
                                ? String(voiceController.outputFolder)
                                : "Chưa chọn thư mục"
                            color: String(voiceController.outputFolder || "").length > 0
                                ? VfTheme.textMuted : VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideMiddle
                        }
                    }
                    VfButton {
                        objectName: "voiceOutputFolderButton"
                        minWidth: VfTheme.dp(108)
                        text: "Đổi thư mục"
                        actionId: "voice.output.pick_folder"
                        tone: "primary"
                        compact: true
                        onClicked: view.chooseOutputFolder()
                    }
                }
            }

            // QUEUE
            Rectangle {
                objectName: "voiceQueuePanel"
                Layout.fillWidth: true; Layout.fillHeight: true
                visible: view.rightTab === "queue"
                radius: VfTheme.radiusPanel; color: VfTheme.canvas; border.color: VfTheme.borderBox; border.width: 1
                ColumnLayout {
                    anchors { fill: parent; margins: VfTheme.dp(9) }
                    spacing: VfTheme.dp(7)
                    Rectangle {
                        objectName: "voiceQueueMonitor"
                        Layout.fillWidth: true
                        implicitHeight: VfTheme.dp(62)
                        radius: VfTheme.dp(9)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.borderSoft

                        ColumnLayout {
                            anchors { fill: parent; margins: VfTheme.dp(7) }
                            spacing: VfTheme.dp(5)
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(5)
                                QueueMetric { Layout.fillWidth: true; label: "ĐANG CHẠY"; value: String((voiceController.stats || {}).generating || 0); accent: "#7C3AED" }
                                QueueMetric { Layout.fillWidth: true; label: "CHỜ"; value: String((voiceController.stats || {}).pending || 0); accent: "#D97706" }
                                QueueMetric { Layout.fillWidth: true; label: "XONG"; value: String((voiceController.stats || {}).completed || 0); accent: "#16A34A" }
                                QueueMetric { Layout.fillWidth: true; label: "LỖI"; value: String((voiceController.stats || {}).failed || 0); accent: "#DC2626" }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: VfTheme.dp(3)
                                radius: height / 2
                                color: VfTheme.borderSoft
                                Rectangle {
                                    width: parent.width * view.queueProgress()
                                    height: parent.height
                                    radius: parent.radius
                                    color: Number((voiceController.stats || {}).failed || 0) > 0
                                        ? "#F59E0B" : "#16A34A"
                                    Behavior on width { NumberAnimation { duration: 180 } }
                                }
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true; spacing: VfTheme.dp(6)
                        VfButton {
                            objectName: "voiceRunQueue"   // tour target
                            Layout.fillWidth: true; visible: !voiceController.busy
                            text: (void i18n.revision, i18n.t("voice_studio.queue_run", "Chạy hàng đợi"))
                            actionId: "voice.queue.run"
                            tone: "primary"
                            enabled: voiceController.queueRows.length > 0
                                && !sharedTtsBar.hardwareBlocked
                                && !sharedTtsBar.voiceCreationOpen
                            tooltip: sharedTtsBar.voiceCreationOpen
                                ? qsTr("Hoàn tất hoặc đóng flow tạo giọng trước khi chạy hàng đợi")
                                : sharedTtsBar.hardwareBlocked
                                    ? sharedTtsBar.statusDetail()
                                    : ""
                            onClicked: { view.commitNow(); voiceController.startQueue() }
                        }
                        VfButton {
                            Layout.fillWidth: true; visible: voiceController.busy
                            text: (void i18n.revision, i18n.t("voice_studio.stop_btn", "Dừng job"))
                            tone: "danger"
                            onClicked: voiceController.stopCurrentGeneration()
                        }
                        VfButton {
                            visible: voiceController.busy
                            text: "Dừng sau job"
                            compact: true
                            leadingIcon: "pause-button"
                            onClicked: voiceController.pauseQueue()
                        }
                        VfButton {
                            Layout.fillWidth: true
                            text: (void i18n.revision, i18n.t("voice_studio.clear_done", "Xóa đã xong"))
                            visible: !voiceController.busy
                            enabled: !voiceController.busy
                                && Number((voiceController.stats || {}).completed || 0) > 0
                            onClicked: voiceController.clearCompletedQueue()
                        }
                        IconBtn {
                            icon: "cross-mark-button"
                            tint: VfTheme.redBorder
                            visible: !voiceController.busy
                            enabled: !voiceController.busy
                            onClicked: voiceController.clearQueue()
                        }
                    }
                    ListView {
                        id: queueList
                        objectName: "voiceQueueList"
                        Layout.fillWidth: true; Layout.fillHeight: true
                        model: voiceController.queueRowsModel
                        clip: true; spacing: VfTheme.dp(5); reuseItems: true
                        delegate: Rectangle {
                            id: queueRowItem
                            required property var modelData
                            readonly property bool runningNow: {
                                var s = String(modelData.status || "").toLowerCase()
                                return s.indexOf("run") >= 0 || s.indexOf("generat") >= 0
                            }
                            width: queueList.width; implicitHeight: jobCol.implicitHeight + VfTheme.dp(14)
                            radius: VfTheme.dp(9)
                            color: view.selectedQueueId === view.queueRowId(modelData)
                                ? VfTheme.violetFill : VfTheme.surfaceSoft
                            border.width: view.selectedQueueId === view.queueRowId(modelData) ? 2 : 1
                            border.color: view.selectedQueueId === view.queueRowId(modelData)
                                ? VfTheme.violet : (runningNow ? VfTheme.blueBorderSoft : VfTheme.borderSoft)
                            TapHandler { onTapped: view.selectQueueRow(modelData) }
                            ColumnLayout {
                                id: jobCol
                                anchors { left: parent.left; right: parent.right; top: parent.top; margins: VfTheme.dp(9) }
                                spacing: VfTheme.dp(5)
                                RowLayout {
                                    Layout.fillWidth: true; spacing: VfTheme.dp(7)
                                    Rectangle {
                                        Layout.preferredWidth: VfTheme.dp(8); Layout.preferredHeight: VfTheme.dp(8); radius: VfTheme.dp(4)
                                        color: view.isDone(modelData) ? "#16A34A"
                                            : (view.isFailed(modelData) ? "#DC2626"
                                                : (queueRowItem.runningNow ? VfTheme.violet
                                                    : (view.isPendingRun(modelData)
                                                        ? "#D97706" : VfTheme.textSubtle)))
                                        // Hiệu ứng đang chạy: chấm xanh thở — alwaysRunToEnd để
                                        // dừng đúng opacity 1 khi hàng chuyển trạng thái.
                                        SequentialAnimation on opacity {
                                            running: queueRowItem.runningNow && VfTheme.motion
                                            alwaysRunToEnd: true
                                            loops: Animation.Infinite
                                            NumberAnimation { from: 1.0; to: 0.25; duration: 450 }
                                            NumberAnimation { from: 0.25; to: 1.0; duration: 450 }
                                        }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true; spacing: 0
                                        Text { Layout.fillWidth: true; text: String(modelData.name || modelData.title || view.rowText(modelData) || "—"); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; elide: Text.ElideRight }
                                         Text {
                                            text: (queueRowItem.runningNow
                                                ? (void i18n.revision, i18n.t("voice_studio.st_running", "Đang tạo giọng đọc..."))
                                                : String(modelData.status || "pending"))
                                                + "  ·  " + String(modelData.provider || sharedTtsBar.provider)
                                                + "  ·  " + String(view.rowText(modelData).length) + " ký tự"
                                            color: queueRowItem.runningNow ? VfTheme.primary : VfTheme.textMuted
                                            font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny
                                         }
                                    }
                                    Text {
                                        visible: queueRowItem.runningNow
                                        text: String(view.runtimeValue(modelData, "runtime_progress", 0)) + "%"
                                        color: VfTheme.violet
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        font.weight: VfTheme.weightStrong
                                    }
                                    VfAppIcon {
                                        visible: queueRowItem.runningNow
                                        name: "clockwise-arrows"; size: VfTheme.dp(15); framed: false; color: VfTheme.primary
                                        RotationAnimation on rotation {
                                            running: visible && VfTheme.motion; from: 0; to: 360
                                            duration: 1100; loops: Animation.Infinite
                                        }
                                    }
                                    IconBtn { icon: view.isFailed(modelData) ? "counterclockwise-arrows-button" : "cross-mark"; tint: view.isFailed(modelData) ? "#D97706" : VfTheme.textMuted; visible: view.isFailed(modelData) || view.isPendingRun(modelData); onClicked: { if (view.isFailed(modelData)) voiceController.retryRow(view.queueRowId(modelData)); else voiceController.skipRow(view.queueRowId(modelData)) } }
                                    // "delete.svg" không tồn tại trong bộ icon → nút trắng; dùng cross-mark-button.
                                    IconBtn { icon: "cross-mark-button"; tint: "#DC2626"; onClicked: voiceController.removeRow(view.queueRowId(modelData)) }
                                }
                                RowLayout {
                                    Layout.fillWidth: true; visible: view.isDone(modelData) && view.rowAudioPath(modelData).length > 0; spacing: VfTheme.dp(6)
                                    VfButton { Layout.fillWidth: true; Layout.minimumWidth: 0; compact: true; text: (void i18n.revision, i18n.t("voice_studio.play_btn", "Phát")); leadingIcon: "loudspeaker"; tone: "success"; onClicked: voiceController.playQueuedRowAudio(view.queueRowId(modelData)) }
                                    VfButton { Layout.fillWidth: true; Layout.minimumWidth: 0; compact: true; text: "Mở file"; leadingIcon: "open-folder"; onClicked: nativeShell.openPath(view.rowAudioPath(modelData)) }
                                    VfButton { Layout.fillWidth: true; Layout.minimumWidth: 0; compact: true; text: (void i18n.revision, i18n.t("voice_studio.send_to_video", "Sang Video")); leadingIcon: "movie-camera"; onClicked: view.sendToTranscript(view.rowAudioPath(modelData)) }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    visible: queueRowItem.runningNow
                                    spacing: VfTheme.dp(3)
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: "Chunk "
                                                + String(view.runtimeValue(modelData,
                                                    "runtime_chunk_index", 0))
                                                + "/"
                                                + String(view.runtimeValue(modelData,
                                                    "runtime_chunk_total", 0))
                                            color: VfTheme.textMuted
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontTiny
                                        }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: "ETA " + view.fmtTime(
                                                view.runtimeValue(modelData,
                                                    "runtime_eta_seconds", 0))
                                            color: VfTheme.greenText
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontTiny
                                            font.weight: VfTheme.weightStrong
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight: VfTheme.dp(5)
                                        radius: height / 2
                                        color: VfTheme.borderSoft
                                        Rectangle {
                                            width: parent.width * Math.max(0,
                                                Math.min(1, Number(view.runtimeValue(
                                                    modelData, "runtime_progress", 0)) / 100))
                                            height: parent.height
                                            radius: parent.radius
                                            color: VfTheme.violet
                                            Behavior on width {
                                                NumberAnimation { duration: 180 }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Column {
                            anchors.centerIn: parent
                            visible: voiceController.queueRows.length === 0
                            spacing: VfTheme.dp(5)
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: (void i18n.revision,
                                    i18n.t("voice_studio.queue_empty", "Hàng đợi trống"))
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontBody
                                font.weight: VfTheme.weightStrong
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Nhập script hoặc import TXT/CSV để tạo job"
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                            }
                        }
                    }
                    Rectangle {
                        objectName: "voiceJobInspector"
                        Layout.fillWidth: true
                        implicitHeight: inspectorColumn.implicitHeight + VfTheme.dp(14)
                        visible: view.selectedQueueId.length > 0
                        radius: VfTheme.dp(10)
                        color: VfTheme.surface
                        border.color: view.isFailed(view.selectedQueueRow)
                            ? VfTheme.redBorder : VfTheme.violetBorder

                        ColumnLayout {
                            id: inspectorColumn
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: VfTheme.dp(8)
                            }
                            spacing: VfTheme.dp(4)

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(6)
                                VfAppIcon {
                                    name: "chart-increasing"
                                    size: VfTheme.dp(22)
                                    framed: true
                                    frameColor: VfTheme.violetFill
                                    color: VfTheme.violet
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(view.selectedQueueRow.name || view.selectedQueueRow.title || view.rowText(view.selectedQueueRow) || "Chi tiết job")
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        font.weight: VfTheme.weightStrong
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(view.selectedQueueId).slice(0, 12)
                                            + "  ·  " + String(view.rowStatus(view.selectedQueueRow)).toUpperCase()
                                        color: view.isFailed(view.selectedQueueRow) ? VfTheme.redText : VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                    }
                                }
                                IconBtn {
                                    icon: "clipboard"
                                    tint: VfTheme.primary
                                    onClicked: nativeShell.setClipboardText(view.selectedQueueId)
                                }
                            }
                            RowLayout {
                                objectName: "voiceInspectorTabs"
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(4)
                                TabBtn { Layout.fillWidth: true; Layout.minimumWidth: 0; text: "Overview"; selected: view.inspectorTab === "overview"; onClicked: view.inspectorTab = "overview" }
                                TabBtn { Layout.fillWidth: true; Layout.minimumWidth: 0; text: "Performance"; selected: view.inspectorTab === "performance"; onClicked: view.inspectorTab = "performance" }
                                TabBtn { Layout.fillWidth: true; Layout.minimumWidth: 0; text: "Audio QA"; selected: view.inspectorTab === "audio"; onClicked: view.inspectorTab = "audio" }
                                TabBtn { Layout.fillWidth: true; Layout.minimumWidth: 0; text: "Log"; selected: view.inspectorTab === "log"; onClicked: view.inspectorTab = "log" }
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: view.inspectorTab === "overview"
                                text: view.rowRouteLabel(view.selectedQueueRow)
                                    + "  ·  " + view.rowVoiceLabel(view.selectedQueueRow)
                                    + "  ·  " + view.rowQualityLabel(view.selectedQueueRow)
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: view.inspectorTab === "overview"
                                text: String(view.rowText(view.selectedQueueRow).length) + " ký tự"
                                    + "  ·  ước tính " + view.fmtTime(view.estimatedSeconds(view.rowText(view.selectedQueueRow)))
                                    + (view.rowAudioPath(view.selectedQueueRow).length > 0
                                        ? "  ·  " + view.rowAudioPath(view.selectedQueueRow) : "")
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                elide: Text.ElideMiddle
                            }
                            RowLayout {
                                objectName: "voicePerformanceInspector"
                                Layout.fillWidth: true
                                visible: view.inspectorTab === "performance"
                                spacing: VfTheme.dp(5)
                                QueueMetric { Layout.fillWidth: true; label: "THỜI GIAN"; value: view.fmtTime(view.runtimeValue(view.selectedQueueRow, "runtime_elapsed_seconds", 0)); accent: VfTheme.primary }
                                QueueMetric { Layout.fillWidth: true; label: "KÝ TỰ/GIÂY"; value: Number(view.runtimeValue(view.selectedQueueRow, "runtime_chars_per_second", 0)).toFixed(1); accent: "#0D9488" }
                                QueueMetric { Layout.fillWidth: true; label: "RTF"; value: Number(view.runtimeValue(view.selectedQueueRow, "runtime_rtf", 0)).toFixed(2) + "x"; accent: VfTheme.violet }
                                QueueMetric { Layout.fillWidth: true; label: "RETRY"; value: String(view.runtimeValue(view.selectedQueueRow, "runtime_retry_count", 0)); accent: "#D97706" }
                            }
                            Rectangle {
                                id: audioQaCard
                                objectName: "voiceAudioQaInspector"
                                Layout.fillWidth: true
                                implicitHeight: VfTheme.dp(74)
                                visible: view.inspectorTab === "audio"
                                radius: VfTheme.dp(8)
                                color: VfTheme.surfaceSoft
                                border.color: VfTheme.borderSoft
                                readonly property var analysis: view.rowAnalysis(view.selectedQueueRow)
                                RowLayout {
                                    anchors { fill: parent; margins: VfTheme.dp(6) }
                                    spacing: VfTheme.dp(7)
                                    Canvas {
                                        id: qaWaveform
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        antialiasing: true
                                        onPaint: {
                                            var ctx = getContext("2d")
                                            ctx.clearRect(0, 0, width, height)
                                            var data = audioQaCard.analysis.waveform || []
                                            if (data.length < 1) return
                                            var step = width / data.length
                                            ctx.fillStyle = String(VfTheme.violet)
                                            for (var i = 0; i < data.length; i++) {
                                                var h = Math.max(1, Number(data[i]) * (height - 4))
                                                ctx.fillRect(i * step, (height - h) / 2, Math.max(1, step - 1), h)
                                            }
                                        }
                                        Connections { target: view; function onSelectedQueueRowChanged() { qaWaveform.requestPaint() } }
                                        onVisibleChanged: if (visible) requestPaint()
                                    }
                                    ColumnLayout {
                                        Layout.preferredWidth: VfTheme.dp(92); spacing: 1
                                        Text { text: "LUFS  " + (audioQaCard.analysis.loudness_lufs !== undefined ? Number(audioQaCard.analysis.loudness_lufs).toFixed(1) : "—"); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                                        Text { text: "Peak  " + (audioQaCard.analysis.true_peak_dbfs !== undefined ? Number(audioQaCard.analysis.true_peak_dbfs).toFixed(1) + " dB" : "—"); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny }
                                        Text { text: String(audioQaCard.analysis.sample_rate || "—") + " Hz"; color: VfTheme.textSubtle; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny }
                                    }
                                }
                            }
                            Text {
                                objectName: "voiceRuntimeLog"
                                Layout.fillWidth: true
                                visible: view.inspectorTab === "log"
                                text: String(view.runtimeValue(view.selectedQueueRow, "runtime_message", "Chưa có log runtime"))
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                wrapMode: Text.Wrap
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: view.rowError(view.selectedQueueRow).length > 0
                                text: view.rowError(view.selectedQueueRow)
                                color: VfTheme.redText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                            RowLayout { // perf-lint: disable=R5 right panel pinned 370dp; buttons shrink (minimumWidth 0); X is Layout-pinned so it cannot wrap off the card
                                id: inspectorActions
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(5)
                                VfButton {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    visible: view.isDone(view.selectedQueueRow) && view.rowAudioPath(view.selectedQueueRow).length > 0
                                    text: "Phát"
                                    leadingIcon: "loudspeaker"
                                    tone: "success"
                                    compact: true
                                    onClicked: voiceController.playQueuedRowAudio(view.selectedQueueId)
                                }
                                VfButton {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    visible: view.rowAudioPath(view.selectedQueueRow).length > 0
                                    text: "Mở file"
                                    leadingIcon: "open-folder"
                                    compact: true
                                    onClicked: nativeShell.openPath(view.rowAudioPath(view.selectedQueueRow))
                                }
                                VfButton {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    visible: view.isDone(view.selectedQueueRow) && view.rowAudioPath(view.selectedQueueRow).length > 0
                                    text: "Sang Video"
                                    leadingIcon: "movie-camera"
                                    compact: true
                                    onClicked: view.sendToTranscript(view.rowAudioPath(view.selectedQueueRow))
                                }
                                VfButton {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    visible: view.isFailed(view.selectedQueueRow)
                                    text: "Thử lại"
                                    leadingIcon: "counterclockwise-arrows-button"
                                    compact: true
                                    onClicked: voiceController.retryRow(view.selectedQueueId)
                                }
                                VfButton {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    visible: view.isPendingRun(view.selectedQueueRow)
                                    text: "Bỏ qua"
                                    leadingIcon: "next-track-button"
                                    compact: true
                                    onClicked: voiceController.skipRow(view.selectedQueueId)
                                }
                                IconBtn {
                                    icon: "cross-mark-button"
                                    tint: "#DC2626"
                                    onClicked: voiceController.removeRow(view.selectedQueueId)
                                }
                            }
                        }
                    }
                }
            }

            // HISTORY
            Rectangle {
                objectName: "voiceHistoryPanel"
                Layout.fillWidth: true; Layout.fillHeight: true
                visible: view.rightTab === "history"
                radius: VfTheme.radiusPanel; color: VfTheme.canvas; border.color: VfTheme.borderBox; border.width: 1
                ColumnLayout {
                    anchors { fill: parent; margins: VfTheme.dp(9) }
                    spacing: VfTheme.dp(7)
                    RowLayout {
                        Layout.fillWidth: true; spacing: VfTheme.dp(6)
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: VfTheme.dp(34)
                            radius: VfTheme.dp(8)
                            color: VfTheme.blueFill
                            border.color: VfTheme.blueBorderSoft
                            RowLayout {
                                anchors { fill: parent; leftMargin: VfTheme.dp(8); rightMargin: VfTheme.dp(8) }
                                spacing: VfTheme.dp(6)
                                VfAppIcon { name: "bar-chart"; size: VfTheme.dp(16); framed: false; color: VfTheme.primary }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(voiceController.history.length) + " file  ·  " + view.fmtBytes(view.historyBytes())
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    font.weight: VfTheme.weightStrong
                                }
                            }
                        }
                        VfButton { text: (void i18n.revision, i18n.t("voice_studio.merge_audio", "Ghép tất cả")); enabled: voiceController.history.length > 1; compact: true; onClicked: view.mergeHistory() }
                        IconBtn { icon: "open-folder"; tint: VfTheme.primary; enabled: String(voiceController.outputFolder || "").length > 0; onClicked: nativeShell.openPath(String(voiceController.outputFolder || "")) }
                        IconBtn { icon: "counterclockwise-arrows-button"; onClicked: voiceController.refreshHistory() }
                    }
                    ListView {
                        id: historyList
                        objectName: "voiceHistoryList"
                        Layout.fillWidth: true; Layout.fillHeight: true
                        model: voiceController.historyModel
                        clip: true; spacing: VfTheme.dp(4); reuseItems: true
                        delegate: Rectangle {
                            required property var modelData
                            width: historyList.width; implicitHeight: VfTheme.dp(48)
                            radius: VfTheme.dp(8)
                            color: view.selectedHistoryPath === String(modelData.path || "")
                                ? VfTheme.violetFill : VfTheme.surfaceSoft
                            border.width: view.selectedHistoryPath === String(modelData.path || "") ? 2 : 1
                            border.color: view.selectedHistoryPath === String(modelData.path || "")
                                ? VfTheme.violetBorder : VfTheme.borderSoft
                            TapHandler { onTapped: view.selectHistoryRow(modelData) }
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: VfTheme.dp(9); anchors.rightMargin: VfTheme.dp(7); spacing: VfTheme.dp(7)
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 0
                                    Text { Layout.fillWidth: true; text: String(modelData.name || modelData.prompt || modelData.voice_id || "audio"); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; elide: Text.ElideRight }
                                    Text { text: view.fmtBytes(modelData.size_bytes) + "  ·  " + String(modelData.updated_at || "").slice(0, 16).replace("T", " "); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny }
                                }
                                IconBtn { icon: "loudspeaker"; tint: "#16A34A"; enabled: String(modelData.path || "").length > 0; onClicked: voiceController.playAudio(String(modelData.path || "")) }
                                IconBtn { icon: "movie-camera"; tint: "#7C3AED"; enabled: String(modelData.path || "").length > 0; onClicked: view.sendToTranscript(String(modelData.path || "")) }
                            }
                        }
                        Text { anchors.centerIn: parent; visible: voiceController.history.length === 0; text: (void i18n.revision, i18n.t("voice_studio.history_empty", "Chưa có lịch sử")); color: VfTheme.textSubtle; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall }
                    }
                    Rectangle {
                        objectName: "voiceHistoryInspector"
                        Layout.fillWidth: true
                        implicitHeight: historyInspectorColumn.implicitHeight + VfTheme.dp(14)
                        visible: view.selectedHistoryPath.length > 0
                        radius: VfTheme.dp(10)
                        color: VfTheme.surface
                        border.color: VfTheme.violetBorderSoft

                        ColumnLayout {
                            id: historyInspectorColumn
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: VfTheme.dp(8)
                            }
                            spacing: VfTheme.dp(4)
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(6)
                                VfAppIcon {
                                    name: "voice-output"
                                    size: VfTheme.dp(22)
                                    framed: true
                                    frameColor: VfTheme.blueFill
                                    color: VfTheme.primary
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(view.selectedHistoryRow.name || "Audio")
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        font.weight: VfTheme.weightStrong
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: view.fmtBytes(view.selectedHistoryRow.size_bytes)
                                            + "  ·  " + String(view.selectedHistoryRow.updated_at || "").slice(0, 19).replace("T", " ")
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                    }
                                }
                                IconBtn {
                                    icon: "clipboard"
                                    tint: VfTheme.primary
                                    onClicked: nativeShell.setClipboardText(view.selectedHistoryPath)
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: view.selectedHistoryPath
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                elide: Text.ElideMiddle
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(5)
                                VfButton { Layout.fillWidth: true; text: "Phát"; leadingIcon: "loudspeaker"; tone: "success"; compact: true; onClicked: voiceController.playAudio(view.selectedHistoryPath) }
                                VfButton { Layout.fillWidth: true; text: "Mở file"; leadingIcon: "open-folder"; compact: true; onClicked: nativeShell.openPath(view.selectedHistoryPath) }
                                VfButton { Layout.fillWidth: true; text: "Sang Video"; leadingIcon: "movie-camera"; compact: true; onClicked: view.sendToTranscript(view.selectedHistoryPath) }
                            }
                        }
                    }
                }
            }
            }
        }
        }

    Menu {
        id: pauseTagMenu
        parent: pauseTagButton
        y: pauseTagButton.height
        MenuItem {
            text: "[pause]  Nghỉ mặc định"
            onTriggered: view.insertVoiceTag("[pause]")
        }
        MenuItem {
            text: "[pause 0.5s]  Nghỉ 0,5 giây"
            onTriggered: view.insertVoiceTag("[pause 0.5s]")
        }
        MenuItem {
            text: "[pause 1.0s]  Nghỉ 1 giây"
            onTriggered: view.insertVoiceTag("[pause 1.0s]")
        }
    }

    // ── Inline components ─────────────────────────────────────────────────────
    component IconBtn: Rectangle {
        id: iconBtn
        property string icon: "play"; property color tint: VfTheme.textMuted
        signal clicked()
        implicitWidth: VfTheme.dp(30); implicitHeight: VfTheme.dp(30); radius: VfTheme.dp(8)
        Layout.minimumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        Layout.maximumWidth: implicitWidth
        Layout.minimumHeight: implicitHeight
        Layout.preferredHeight: implicitHeight
        Layout.alignment: Qt.AlignVCenter
        opacity: enabled ? 1.0 : 0.4
        color: im.containsMouse && enabled ? VfTheme.surface : "transparent"; border.color: VfTheme.borderSoft
        VfAppIcon { anchors.centerIn: parent; name: iconBtn.icon; size: VfTheme.dp(14); framed: false; color: iconBtn.tint }
        MouseArea { id: im; anchors.fill: parent; hoverEnabled: true; enabled: iconBtn.enabled; cursorShape: iconBtn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor; onClicked: iconBtn.clicked() }
    }

    component TabBtn: Rectangle {
        id: tabBtn
        property string text: ""; property bool selected: false
        signal clicked()
        implicitWidth: Math.max(VfTheme.dp(56), tabMetrics.implicitWidth + VfTheme.dp(16))
        implicitHeight: VfTheme.dp(34)
        radius: VfTheme.dp(12); color: selected ? VfTheme.surface : "transparent"; border.color: selected ? VfTheme.borderBox : "transparent"
        Text {
            id: tabMetrics
            visible: false
            text: tabBtn.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            font.weight: VfTheme.weightStrong
        }
        Text {
            id: tabLabel
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(6)
            anchors.rightMargin: VfTheme.dp(6)
            text: tabBtn.text
            color: selected ? VfTheme.text : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            font.weight: selected ? VfTheme.weightStrong : VfTheme.weightRegular
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: tabBtn.clicked() }
    }

    component StudioMetric: Rectangle {
        id: metric
        property string label: ""
        property string value: ""
        property color accent: VfTheme.primary
        implicitWidth: Math.max(
            VfTheme.dp(72), metricValue.implicitWidth + VfTheme.dp(16))
        implicitHeight: VfTheme.dp(38)
        radius: VfTheme.dp(8)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.borderSoft
        Column {
            anchors.centerIn: parent
            spacing: 0
            Text {
                id: metricValue
                anchors.horizontalCenter: parent.horizontalCenter
                text: metric.value
                color: metric.accent
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightStrong
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: metric.label
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(8)
                font.letterSpacing: VfTheme.dp(0.4)
            }
        }
    }

    component QueueMetric: ColumnLayout {
        id: queueMetric
        property string label: ""
        property string value: "0"
        property color accent: VfTheme.primary
        spacing: 0
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: queueMetric.value
            color: queueMetric.accent
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            font.weight: VfTheme.weightStrong
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: queueMetric.label
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(7)
            font.letterSpacing: VfTheme.dp(0.35)
        }
    }

    component OutputFact: Rectangle {
        id: outputFact
        property string label: ""
        property string value: "—"
        implicitWidth: VfTheme.dp(72)
        implicitHeight: VfTheme.dp(42)
        radius: VfTheme.dp(7)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.borderSoft
        Column {
            anchors.centerIn: parent
            spacing: 0
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: outputFact.value
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.weight: VfTheme.weightStrong
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: outputFact.label
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(7)
                font.letterSpacing: VfTheme.dp(0.25)
            }
        }
    }
}
