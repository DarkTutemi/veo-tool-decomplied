pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

// Voice Studio is the producer surface. It stages provider settings through the
// shared panel and owns the OmniVoice candidate -> approve -> profile workflow.
// Master/Clone never instantiate this component; they keep the selection-only
// compact bar from SharedTtsInlinePanel.
Item {
    id: panel

    property var providerChoices: []
    property string provider: "gemini"
    property string providerDisplay: "Gemini TTS"
    property color accent: VfTheme.primary
    property var options: ({})
    property bool draftDirty: false
    property bool busy: false
    property bool hardwareBlocked: false
    property var engineInfo: ({})

    property string modeLabel: qsTr("Chế độ")
    property var modeOptions: []
    property string modeValue: ""
    property string voiceLabel: qsTr("Giọng")
    property var voiceOptions: []
    property string voiceValue: ""
    property string deliveryLabel: qsTr("Ngôn ngữ")
    property var deliveryOptions: []
    property string deliveryValue: ""

    property string selectedConfigPresetId: ""
    property string selectedConfigPresetName: ""
    property string pendingProfileId: ""
    property string pendingProfileName: ""
    property string profileQuery: ""
    property string profileFilter: "all"
    property int omniCandidateSteps: 32
    property bool omniCreateOpen: false
    property int omniBusyElapsedSec: 0

    Timer {
        interval: 1000
        repeat: true
        running: voiceController.omniProfileBusy
        onRunningChanged: {
            if (running)
                panel.omniBusyElapsedSec = 0
        }
        onTriggered: panel.omniBusyElapsedSec += 1
    }

    // The create flow grows with the real StepCard content. SharedTtsInlinePanel
    // uses this value instead of squeezing the candidate and approval steps into
    // a fixed-height surface when translated text or DPI makes them taller.
    readonly property real omniCreationPreferredHeight:
        workbenchLayout.implicitHeight + VfTheme.dp(14)

    readonly property bool omniCandidateReady:
        Boolean((voiceController.omniCandidate || {}).ok)
    readonly property string omniConsumerProfileId: {
        // Voice Studio "Đang dùng" follows the producer profile id. Stale
        // omni_consumer_voice from a previous save must not win the picker.
        if (panel.modeValue === "profile")
            return String(
                panel.options.omni_voice
                || panel.options.omni_consumer_voice || "")
        return String(panel.options.omni_consumer_voice || "")
    }
    readonly property bool omniConsumerProfileReady:
        panel.omniConsumerProfileId.trim().length > 0
    readonly property string omniConsumerProfileName: {
        void voiceController.omniProfileOptions
        return voiceController.omniVoiceLabel(panel.omniConsumerProfileId)
            || panel.omniConsumerProfileId
    }
    readonly property string omniPreviewText:
        panel.omniCandidateReady
            ? String((voiceController.omniCandidate || {}).sample_text || "")
            : voiceController.omniSampleText(panel.deliveryValue, i18n.locale)
    readonly property string omniSourceIssue: {
        if (String(panel.options.omni_ref_audio || "").trim().length < 1)
            return qsTr("Hãy chọn file audio nguồn")
        return ""
    }
    readonly property bool omniSourceReady:
        panel.omniSourceIssue.length < 1
    readonly property bool geminiDialogue:
        Boolean(panel.options.dialogue_enabled)
    readonly property int nonOmniFieldCount:
        panel.provider === "vieneu" ? 5
        : panel.provider === "moss"
            ? 5
                + (panel.modeValue === "direct" ? 0 : 1)
                + ((panel.modeValue === "continuation"
                    || panel.modeValue === "continuation_clone") ? 1 : 0)
            : 4
    readonly property bool nonOmniSingleRow:
        panel.width >= VfTheme.dp(1260)
    readonly property int nonOmniGridColumns:
        panel.nonOmniSingleRow
            ? panel.nonOmniFieldCount
            : Math.min(4, panel.nonOmniFieldCount)

    signal providerSelected(string value)
    signal modeSelected(string value)
    signal voiceSelected(string value)
    signal deliverySelected(string value)
    signal optionChanged(string key, var value)
    signal optionsPatched(var values)
    signal saveRequested()
    signal resetRequested()
    signal previewRequested()
    signal configPresetSelected(string presetId)
    signal continueRequested()

    onProfileQueryChanged: panel.refreshOmniProfileFilter()
    onProfileFilterChanged: panel.refreshOmniProfileFilter()
    onOptionsChanged: panel.refreshOmniProfileFilter()
    Component.onCompleted: panel.refreshOmniProfileFilter()

    function providerIcon(value) {
        if (value === "omnivoice")
            return "voice-provider-omni"
        if (value === "moss")
            return "voice-provider-moss"
        if (value === "vieneu")
            return "voice-provider-vieneu"
        return "voice-provider-gemini"
    }

    function providerAccent(value) {
        if (value === "omnivoice")
            return VfTheme.violet
        if (value === "moss")
            return VfTheme.cyan
        if (value === "vieneu")
            return VfTheme.greenBorder
        return VfTheme.primary
    }

    function fileName(path) {
        var parts = String(path || "").replace(/\\/g, "/").split("/")
        return parts.length > 0 ? parts[parts.length - 1] : ""
    }

    function chooseAudio(title, key) {
        var picked = nativeShell.pickFiles(
            title,
            "Audio Files (*.wav *.mp3 *.m4a *.flac);;All Files (*.*)", "")
        if (picked && picked.ok && picked.paths && picked.paths.length > 0) {
            if (String(key).indexOf("omni_") === 0)
                panel.invalidateOmniCandidate()
            panel.optionChanged(key, String(picked.paths[0] || ""))
        }
    }

    function refreshOmniProfileFilter() {
        if (panel.provider !== "omnivoice")
            return
        voiceController.setOmniProfileFilter(
            panel.profileQuery,
            panel.profileFilter,
            String(panel.options.omni_voice || ""))
    }

    function invalidateOmniCandidate() {
        voiceController.discardOmniCandidate()
    }

    function selectOmniCreationMode(value) {
        panel.invalidateOmniCandidate()
        panel.modeSelected(String(value || "new"))
    }

    function openOmniCreation() {
        panel.omniCreateOpen = true
        if (panel.modeValue !== "clone")
            panel.selectOmniCreationMode("clone")
    }

    function activateOmniProfile(value) {
        var selected = String(value || "")
        if (selected.length < 1)
            return
        panel.invalidateOmniCandidate()
        // selectOmniProfile writes omni_voice AND omni_consumer_voice. The old
        // draft-patch + saveRequested path dropped consumer voice, then sync
        // restored the previous "Đang dùng" id.
        voiceController.selectOmniProfile(selected)
        panel.optionsPatched({
            omni_mode: "profile",
            omni_voice: selected,
            omni_consumer_voice: selected,
            omni_recipe: "",
            omni_ref_audio: "",
            omni_ref_text: ""
        })
        panel.omniCreateOpen = false
        profilePickerPopup.close()
    }

    function cancelOmniCreation() {
        panel.invalidateOmniCandidate()
        panel.omniCreateOpen = false
        if (panel.omniConsumerProfileReady)
            panel.activateOmniProfile(panel.omniConsumerProfileId)
    }

    function changeOmniSource(key, value) {
        panel.invalidateOmniCandidate()
        panel.optionChanged(key, value)
    }

    function playActiveOmniSample() {
        var path = voiceController.omniProfileSamplePath(
            panel.omniConsumerProfileId)
        if (path.length)
            voiceController.startPlayback(path, qsTr("Mẫu đã lưu"))
        else if (panel.omniConsumerProfileId.length)
            voiceController.previewOmniProfile(panel.omniConsumerProfileId)
    }

    function createOmniCandidate() {
        voiceController.previewOmniCandidate(
            panel.options, i18n.locale, panel.omniCandidateSteps)
    }

    function saveOmniCandidate() {
        if (!panel.omniCandidateReady || voiceController.omniProfileBusy)
            return
        var name = String(approvedProfileName.text || "").trim()
        if (!name.length)
            return
        voiceController.approveOmniCandidate(name)
    }

    function numberValue(value, fallback) {
        var result = Number(value)
        return isFinite(result) ? result : fallback
    }

    function geminiSpeakers() {
        var source = panel.options.speakers || []
        var rows = []
        for (var i = 0; i < Math.min(2, source.length); i++) {
            var item = source[i] || ({})
            rows.push({
                name: String(item.name || ("Speaker " + (i + 1))),
                voice: String(item.voice || (i === 0
                    ? panel.voiceValue : "Puck")),
                audio_profile: String(item.audio_profile || ""),
                style: String(item.style || ""),
                pace: String(item.pace || ""),
                accent: String(item.accent || "")
            })
        }
        if (rows.length === 0) {
            rows.push({
                name: String(panel.options.speaker1 || "Speaker 1"),
                voice: String(panel.voiceValue || "Kore"),
                audio_profile: String(panel.options.audio_profile
                    || panel.options.gemini_audio_profile || ""),
                style: "",
                pace: "",
                accent: ""
            })
        }
        return rows
    }

    function geminiSpeakerValue(index, key, fallback) {
        var rows = panel.geminiSpeakers()
        if (index < 0 || index >= rows.length)
            return String(fallback || "")
        return String((rows[index] || ({}))[key] || fallback || "")
    }

    function patchGeminiSpeaker(index, key, value) {
        var rows = panel.geminiSpeakers()
        while (rows.length <= index) {
            rows.push({
                name: "Speaker " + String(rows.length + 1),
                voice: rows.length === 0
                    ? String(panel.voiceValue || "Kore") : "Puck",
                audio_profile: "",
                style: "",
                pace: "",
                accent: ""
            })
        }
        rows[index][key] = String(value || "")
        var patch = { speakers: rows, preset_id: "" }
        if (key === "name")
            patch[index === 0 ? "speaker1" : "speaker2"] = String(value || "")
        if (key === "voice" && index === 1)
            patch.voice2 = String(value || "Puck")
        panel.optionsPatched(patch)
        if (key === "voice" && index === 0)
            panel.voiceSelected(String(value || ""))
    }

    function setGeminiDialogue(value) {
        var enabled = String(value) === "dialogue"
        var rows = panel.geminiSpeakers().slice(0, enabled ? 2 : 1)
        if (enabled && rows.length < 2) {
            rows.push({
                name: String(panel.options.speaker2 || "Speaker 2"),
                voice: String(panel.options.voice2 || "Puck"),
                audio_profile: "",
                style: "",
                pace: "",
                accent: ""
            })
        }
        panel.optionsPatched({
            dialogue_enabled: enabled,
            speakers: rows,
            preset_id: ""
        })
    }

    function geminiPresetOptions() {
        var rows = [{ label: qsTr("Tùy chỉnh"), value: "" }]
        var source = voiceController.ttsPresets || []
        for (var i = 0; i < source.length; i++)
            rows.push(source[i])
        return rows
    }

    function applyGeminiStudioPreset(presetId) {
        var selected = String(presetId || "")
        if (selected.length < 1) {
            panel.optionChanged("preset_id", "")
            return
        }
        var payload = voiceController.ttsPresetPayload(selected)
        if (!payload || !payload.ok)
            return
        panel.optionsPatched({
            speakers: payload.speakers || [],
            scene: String(payload.scene || ""),
            sample_context: String(payload.sample_context || ""),
            dialogue_enabled: Boolean(payload.dialogue_enabled),
            preset_id: String(payload.id || selected),
            audio_profile: "",
            director_notes: "",
            gemini_audio_profile: "",
            gemini_director_notes: "",
            speaker1: String(((payload.speakers || [])[0] || {}).name || "Speaker 1"),
            speaker2: String(((payload.speakers || [])[1] || {}).name || "Speaker 2"),
            voice2: String(((payload.speakers || [])[1] || {}).voice || "Puck")
        })
        if (String(payload.voice || "").length > 0)
            panel.voiceSelected(String(payload.voice))
    }

    function saveConfigPreset() {
        var name = String(presetNameInput.text || "").trim()
        if (name.length < 1)
            return
        var result = voiceController.saveVoiceConfigPreset(
            name, panel.provider, panel.options || ({}))
        if (result && result.ok)
            presetNameInput.text = ""
    }

    function updateConfigPreset() {
        if (panel.selectedConfigPresetId.length < 1)
            return
        voiceController.updateVoiceConfigPreset(
            panel.selectedConfigPresetId, panel.provider, panel.options || ({}))
    }

    function renameConfigPreset() {
        var name = String(presetNameInput.text || "").trim()
        if (panel.selectedConfigPresetId.length < 1 || name.length < 1)
            return
        var result = voiceController.renameVoiceConfigPreset(
            panel.selectedConfigPresetId, name)
        if (result && result.ok)
            panel.selectedConfigPresetName = name
    }

    ColumnLayout {
        id: workbenchLayout
        anchors {
            fill: parent
            margins: VfTheme.dp(7)
        }
        spacing: VfTheme.dp(5)

        Item {
            id: providerSurface
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: implicitHeight
            // Hug content (owner 2026-08 redesign): the voice surface must NOT
            // stretch across the whole left column — the old Layout.fillHeight
            // left a huge empty box under the current-voice bar. The script /
            // audio sections below the panel absorb leftover space instead.
            implicitHeight: {
                if (panel.provider !== "omnivoice")
                    return nonOmniConfigColumn.implicitHeight + VfTheme.dp(16)
                var tabs = VfTheme.dp(30) + VfTheme.dp(5)
                if (panel.omniCreateOpen)
                    return tabs + omniProductionFlow.implicitHeight + VfTheme.dp(14)
                return tabs + omniCurrentVoiceCard.implicitHeight + VfTheme.dp(4)
            }

            // Internal 2-tab header (owner 2026-08): "Giọng đang dùng" ↔
            // "Tạo giọng mới". The create flow becomes a real internal tab
            // instead of a button that silently swaps the whole surface.
            // MUST stay a SIBLING of the surfaces below — anchors to a
            // non-sibling/non-parent item are illegal in QML and silently
            // collapse the anchored surfaces to 0×0.
            RowLayout {
                id: omniTabRow
                visible: panel.provider === "omnivoice"
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: VfTheme.dp(28)
                spacing: VfTheme.dp(5)

                VfButton {
                    objectName: "omniVoiceTabCurrent"
                    text: qsTr("Giọng đang dùng")
                    leadingIcon: "voice-content"
                    compact: true
                    tone: panel.omniCreateOpen ? "neutral" : "accent"
                    onClicked: if (panel.omniCreateOpen)
                        panel.cancelOmniCreation()
                }
                VfButton {
                    objectName: "omniVoiceTabCreate"
                    text: qsTr("Tạo giọng mới")
                    leadingIcon: "plus"
                    compact: true
                    tone: panel.omniCreateOpen ? "accent" : "neutral"
                    enabled: !voiceController.omniProfileBusy
                        && !panel.hardwareBlocked
                    onClicked: if (!panel.omniCreateOpen)
                        panel.openOmniCreation()
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: panel.omniConsumerProfileReady
                        ? qsTr("Đã duyệt · sẵn sàng")
                        : qsTr("Cần chọn một giọng trước khi tạo audio")
                    color: panel.omniConsumerProfileReady
                        ? VfTheme.greenText : VfTheme.amberText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                }
            }

            Item {
                id: surfaceHost
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    topMargin: panel.provider === "omnivoice"
                        ? VfTheme.dp(33) : 0
                }
            }

            Rectangle {
                id: omniCurrentVoiceCard
                objectName: "voiceOmniWorkSurface"
                anchors {
                    top: surfaceHost.top
                    left: surfaceHost.left
                    right: surfaceHost.right
                }
                implicitHeight: currentVoiceColumn.implicitHeight + VfTheme.dp(14)
                height: implicitHeight
                visible: panel.provider === "omnivoice"
                    && !panel.omniCreateOpen
                radius: VfTheme.dp(10)
                color: VfTheme.surface
                border.color: panel.omniConsumerProfileReady
                    ? VfTheme.violetBorderSoft : VfTheme.borderSoft

                ColumnLayout {
                    id: currentVoiceColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: VfTheme.dp(7)
                    }
                    spacing: VfTheme.dp(6)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)

                        Rectangle {
                            Layout.preferredWidth: VfTheme.dp(9)
                            Layout.preferredHeight: VfTheme.dp(9)
                            radius: VfTheme.dp(5)
                            color: panel.omniConsumerProfileReady
                                ? VfTheme.greenBorder : VfTheme.amber
                        }
                        VfAppIcon {
                            name: "voice-provider-omni"
                            size: VfTheme.dp(22)
                            framed: true
                            frameColor: VfTheme.violetFill
                            color: VfTheme.violet
                        }
                        Text {
                            objectName: "omniActiveVoiceCard"
                            Layout.preferredWidth: VfTheme.dp(250)
                            text: panel.omniConsumerProfileReady
                                ? panel.omniConsumerProfileName
                                : qsTr("Chưa chọn giọng")
                            color: panel.omniConsumerProfileReady
                                ? VfTheme.text : VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                            font.weight: VfTheme.weightStrong
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: panel.omniConsumerProfileReady
                                ? qsTr("OmniVoice · profile đã duyệt")
                                : qsTr("Chọn từ thư viện hoặc tạo một giọng mới")
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideRight
                        }
                        VfButton {
                            objectName: "omniChangeVoiceButton"
                            text: qsTr("Đổi giọng")
                            leadingIcon: "voice-content"
                            compact: true
                            enabled: !voiceController.omniProfileBusy
                            onClicked: {
                                panel.profileFilter = "all"
                                panel.profileQuery = ""
                                profilePickerPopup.open()
                            }
                        }
                        VfButton {
                            objectName: "omniCreateVoiceButton"
                            text: qsTr("Tạo giọng mới")
                            leadingIcon: "plus"
                            tone: "accent"
                            compact: true
                            tooltip: voiceController.busy
                                ? qsTr("Đang tạo audio — dừng hoặc chờ hoàn tất rồi hãy tạo giọng")
                                : ""
                            enabled: !voiceController.omniProfileBusy
                                && !voiceController.busy
                                && !panel.hardwareBlocked
                            onClicked: panel.openOmniCreation()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        visible: panel.omniConsumerProfileReady
                        implicitHeight: VfTheme.dp(36)
                        radius: VfTheme.dp(8)
                        color: VfTheme.violetFill
                        border.color: VfTheme.violetBorderSoft
                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: VfTheme.dp(8)
                                rightMargin: VfTheme.dp(8)
                            }
                            spacing: VfTheme.dp(8)
                            IconAction {
                                icon: "play"
                                tint: VfTheme.violet
                                accessibleName: qsTr("Nghe mẫu đã lưu")
                                enabled: !voiceController.omniProfileBusy
                                onClicked: panel.playActiveOmniSample()
                            }
                            Row {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: VfTheme.dp(2)
                                Repeater {
                                    model: 28
                                    Rectangle {
                                        required property int index
                                        width: VfTheme.dp(2)
                                        height: VfTheme.dp(4 + ((index * 17) % 14))
                                        radius: width / 2
                                        color: VfTheme.violet
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                            Text {
                                text: qsTr("Mẫu đã lưu · nghe lại")
                                color: VfTheme.violetText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                            }
                        }
                    }
                }
            }

            RowLayout {
                anchors.fill: surfaceHost
                visible: panel.provider === "omnivoice"
                    && panel.omniCreateOpen
                spacing: VfTheme.dp(7)

                Rectangle {
                    id: omniProductionFlow
                    objectName: "voiceOmniProductionFlow"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitHeight: omniProductionLayout.implicitHeight
                        + VfTheme.dp(14)
                    radius: VfTheme.dp(10)
                    color: VfTheme.surface
                    border.color: VfTheme.borderSoft

                    ColumnLayout {
                        id: omniProductionLayout
                        anchors {
                            fill: parent
                            margins: VfTheme.dp(7)
                        }
                        spacing: VfTheme.dp(5)

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(25)
                            spacing: VfTheme.dp(5)
                            VfAppIcon {
                                name: "voice-provider-omni"
                                size: VfTheme.dp(18)
                                framed: true
                                frameColor: VfTheme.violetFill
                                color: VfTheme.violet
                            }
                            Text {
                                text: qsTr("TẠO GIỌNG MỚI")
                                color: VfTheme.violetText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontControl
                                font.weight: VfTheme.weightStrong
                                font.letterSpacing: VfTheme.dp(0.35)
                            }
                            Item { Layout.fillWidth: true }
                            VfButton {
                                visible: panel.omniConsumerProfileReady
                                text: qsTr("Quay lại làm audio")
                                leadingIcon: "counterclockwise-arrows-button"
                                compact: true
                                enabled: !voiceController.omniProfileBusy
                                onClicked: panel.cancelOmniCreation()
                            }
                            Text {
                                text: qsTr("Tạo giọng bằng cách clone một bản thu thật")
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(9)
                            }
                        }

                        RowLayout {
                            id: omniStepRow
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredHeight: Layout.minimumHeight
                            Layout.minimumHeight: Math.max(
                                omniSourceStep.implicitHeight,
                                omniReviewColumn.implicitHeight)
                            spacing: VfTheme.dp(7)

                            StepCard {
                                id: omniSourceStep
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: implicitHeight
                                Layout.preferredHeight: implicitHeight
                                Layout.preferredWidth: 52
                                step: "1"
                                title: qsTr("Chuẩn bị audio clone")
                                state: panel.omniSourceReady ? "done" : "active"
                                accent: VfTheme.violet

                                VfValueField {
                                    Layout.fillWidth: true
                                    label: qsTr("1A · File audio nguồn")
                                    value: panel.fileName(panel.options.omni_ref_audio)
                                    placeholder: qsTr("WAV/MP3/M4A/FLAC · 3–10 giây, một người nói rõ ràng. File dài tự cắt một đoạn ~10s.")
                                    actionText: qsTr("Chọn file")
                                    accent: VfTheme.violet
                                    onActivated: panel.chooseAudio(
                                        qsTr("Chọn audio nguồn OmniVoice"), "omni_ref_audio")
                                }
                                StudioTextArea {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.preferredHeight: VfTheme.dp(132)
                                    Layout.minimumHeight: VfTheme.dp(92)
                                    label: qsTr("1B · Transcript audio (không bắt buộc)")
                                    value: String(panel.options.omni_ref_text || "")
                                    placeholder: qsTr("Nhập đúng lời nói trong mẫu giúp giọng clone giống hơn")
                                    accent: VfTheme.violet
                                    onCommitted: value => panel.changeOmniSource(
                                        "omni_ref_text", value)
                                }
                                Text {
                                    visible: String(panel.options.omni_ref_audio || "").trim().length > 0
                                    Layout.fillWidth: true
                                    text: qsTr("File dài hơn 10 giây sẽ tự cắt một đoạn ngắn trước khi tạo mẫu — không sửa file gốc.")
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    wrapMode: Text.WordWrap
                                }
                                Text {
                                    visible: panel.omniSourceIssue.length > 0
                                    Layout.fillWidth: true
                                    text: panel.omniSourceIssue
                                    color: VfTheme.redText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    wrapMode: Text.WordWrap
                                }
                                Item { Layout.fillHeight: true }
                            }

                            Rectangle {
                                Layout.preferredWidth: 1
                                Layout.fillHeight: true
                                color: VfTheme.borderSoft
                            }

                            ColumnLayout {
                                id: omniReviewColumn
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: implicitHeight
                                Layout.preferredWidth: panel.modeValue === "clone"
                                    ? 48 : 62
                                spacing: VfTheme.dp(6)

                                StepCard {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.minimumHeight: implicitHeight
                                    Layout.preferredHeight: implicitHeight
                                    step: "2"
                                    title: panel.omniCandidateReady
                                        ? qsTr("Nghe lại hoặc tạo biến thể khác")
                                        : qsTr("Tạo một mẫu để duyệt")
                                    state: panel.omniCandidateReady
                                        ? "done" : panel.omniSourceReady
                                            ? "active" : "pending"
                                    accent: VfTheme.cyan

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: VfTheme.dp(48)
                                        radius: VfTheme.dp(7)
                                        color: VfTheme.surfaceSoft
                                        border.color: VfTheme.borderSoft
                                        Text {
                                            anchors {
                                                fill: parent
                                                margins: VfTheme.dp(7)
                                            }
                                            text: qsTr("Câu dùng để kiểm tra: “%1”").arg(
                                                panel.omniPreviewText)
                                            color: VfTheme.textMuted
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(9)
                                            wrapMode: Text.WordWrap
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: VfTheme.dp(5)
                                        VfSelectField {
                                            Layout.preferredWidth: VfTheme.dp(124)
                                            compact: true
                                            label: qsTr("Chất lượng mẫu")
                                            options: [
                                                { label: qsTr("Chuẩn · 32"), value: "32" },
                                                { label: qsTr("Cao · 64"), value: "64" }
                                            ]
                                            value: String(panel.omniCandidateSteps)
                                            accent: VfTheme.cyan
                                            onSelected: value => {
                                                panel.invalidateOmniCandidate()
                                                panel.omniCandidateSteps = Number(value)
                                            }
                                        }
                                        VfButton {
                                            Layout.fillWidth: true
                                            text: voiceController.omniProfileBusy
                                                ? (panel.omniBusyElapsedSec > 0
                                                    ? qsTr("Đang tạo mẫu… %1s").arg(
                                                        panel.omniBusyElapsedSec)
                                                    : qsTr("Đang tạo mẫu…"))
                                                : panel.omniCandidateReady
                                                    ? qsTr("Tạo lại mẫu")
                                                    : qsTr("Tạo mẫu")
                                            leadingIcon: "voice-output"
                                            tone: "primary"
                                            compact: true
                                            tooltip: panel.omniSourceIssue
                                            enabled: !voiceController.omniProfileBusy
                                                && !voiceController.busy
                                                && !panel.hardwareBlocked
                                                && panel.omniSourceReady
                                            onClicked: panel.createOmniCandidate()
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.minimumHeight: VfTheme.dp(42)
                                        radius: VfTheme.dp(7)
                                        color: panel.omniCandidateReady
                                            ? VfTheme.violetFill : VfTheme.surfaceSoft
                                        border.color: panel.omniCandidateReady
                                            ? VfTheme.violetBorderSoft : VfTheme.borderSoft
                                        RowLayout {
                                            anchors {
                                                fill: parent
                                                margins: VfTheme.dp(6)
                                            }
                                            spacing: VfTheme.dp(6)
                                            IconAction {
                                                icon: "play"
                                                tint: VfTheme.violet
                                                enabled: panel.omniCandidateReady
                                                accessibleName: qsTr("Nghe lại mẫu vừa tạo")
                                                onClicked: voiceController.startPlayback(
                                                    String((voiceController.omniCandidate || {}).audio_path || ""),
                                                    qsTr("Mẫu OmniVoice chưa lưu"))
                                            }
                                            Row {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignVCenter
                                                spacing: VfTheme.dp(2)
                                                Repeater {
                                                    model: 34
                                                    Rectangle {
                                                        required property int index
                                                        width: VfTheme.dp(2)
                                                        height: VfTheme.dp(4 + ((index * 17) % 14))
                                                        radius: width / 2
                                                        color: panel.omniCandidateReady
                                                            ? VfTheme.violet : VfTheme.borderStrong
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }
                                            }
                                            Text {
                                                text: panel.omniCandidateReady
                                                    ? qsTr("Đã phát · %1 steps").arg(
                                                        String((voiceController.omniCandidate || {}).steps || 32))
                                                    : voiceController.omniProfileBusy
                                                        ? qsTr("Đang dựng audio…")
                                                        : qsTr("Chưa có mẫu")
                                                color: panel.omniCandidateReady
                                                    ? VfTheme.violetText : VfTheme.textSubtle
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.dp(8)
                                            }
                                        }
                                    }
                                }

                                StepCard {
                                    Layout.fillWidth: true
                                    Layout.minimumHeight: implicitHeight
                                    Layout.preferredHeight: implicitHeight
                                    step: "3"
                                    title: panel.omniCandidateReady
                                        ? qsTr("Đặt tên, lưu và dùng ngay")
                                        : qsTr("Lưu vào thư viện")
                                    state: panel.omniCandidateReady ? "active" : "pending"
                                    accent: VfTheme.greenBorder

                                    Text {
                                        Layout.fillWidth: true
                                        text: panel.omniCandidateReady
                                            ? qsTr("Lưu xong, giọng này sẽ tự được chọn cho script và job mới.")
                                            : qsTr("Bước này mở sau khi mẫu đã tạo và phát thành công.")
                                        color: panel.omniCandidateReady
                                            ? VfTheme.greenText : VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(9)
                                        wrapMode: Text.WordWrap
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: VfTheme.dp(5)
                                        TextField {
                                            id: approvedProfileName
                                            Layout.fillWidth: true
                                            implicitHeight: VfTheme.controlHeight
                                            placeholderText: qsTr("Đặt tên dễ nhớ, ví dụ: Nữ kể chuyện 01")
                                            selectByMouse: true
                                            enabled: panel.omniCandidateReady
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontSmall
                                            background: Rectangle {
                                                radius: VfTheme.radiusControl
                                                color: VfTheme.surface
                                                border.color: parent.activeFocus
                                                    ? VfTheme.greenBorder : VfTheme.borderBox
                                            }
                                        }
                                        VfButton {
                                            Layout.preferredWidth: VfTheme.dp(142)
                                            text: (voiceController.omniProfileBusy
                                                   && panel.omniCandidateReady)
                                                ? qsTr("Đang lưu…")
                                                : qsTr("Lưu & dùng giọng")
                                            leadingIcon: "save"
                                            tone: "accent"
                                            compact: true
                                            enabled: panel.omniCandidateReady
                                                && !voiceController.omniProfileBusy
                                                && approvedProfileName.text.trim().length > 0
                                            onClicked: panel.saveOmniCandidate()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    objectName: "voiceApprovedProfileLibrary"
                    visible: false
                    Layout.preferredWidth: Math.max(VfTheme.dp(380), panel.width * 0.34)
                    Layout.fillHeight: true
                    radius: VfTheme.dp(10)
                    color: VfTheme.surface
                    border.color: VfTheme.borderSoft

                    ColumnLayout {
                        anchors {
                            fill: parent
                            margins: VfTheme.dp(7)
                        }
                        spacing: VfTheme.dp(5)
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(25)
                            spacing: VfTheme.dp(5)
                            VfAppIcon {
                                name: "voice-output"
                                size: VfTheme.dp(17)
                                framed: true
                                frameColor: VfTheme.violetFill
                                color: VfTheme.violet
                            }
                            Text {
                                Layout.fillWidth: true
                                text: qsTr("THƯ VIỆN GIỌNG ĐÃ LƯU")
                                color: VfTheme.violetText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontControl
                                font.weight: VfTheme.weightStrong
                                elide: Text.ElideRight
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.controlHeight
                            spacing: VfTheme.dp(5)
                            TextField {
                                Layout.fillWidth: true
                                implicitHeight: VfTheme.controlHeight
                                placeholderText: qsTr("Tìm kiếm giọng…")
                                selectByMouse: true
                                leftPadding: VfTheme.dp(30)
                                rightPadding: VfTheme.dp(8)
                                topPadding: 0
                                bottomPadding: 0
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontControl
                                color: VfTheme.text
                                onTextChanged: panel.profileQuery = text
                                background: Rectangle {
                                    radius: VfTheme.radiusControl
                                    color: VfTheme.surfaceSoft
                                    border.color: parent.activeFocus
                                        ? VfTheme.violet : VfTheme.borderSoft
                                }
                                VfAppIcon {
                                    anchors {
                                        left: parent.left
                                        leftMargin: VfTheme.dp(9)
                                        verticalCenter: parent.verticalCenter
                                    }
                                    name: "magnifying-glass"
                                    size: VfTheme.dp(13)
                                    framed: false
                                    color: VfTheme.textMuted
                                }
                            }
                            VfSelectField {
                                Layout.preferredWidth: VfTheme.dp(112)
                                compact: true
                                label: qsTr("Lọc thư viện")
                                options: [
                                    { label: qsTr("Tất cả"), value: "all" },
                                    { label: qsTr("Đang dùng"), value: "selected" }
                                ]
                                value: panel.profileFilter
                                accent: VfTheme.violet
                                onSelected: value => panel.profileFilter = String(value)
                            }
                            IconAction {
                                icon: "counterclockwise-arrows-button"
                                tint: VfTheme.violet
                                accessibleName: qsTr("Đồng bộ thư viện")
                                enabled: !voiceController.omniProfileBusy
                                onClicked: voiceController.syncOmniProfiles("")
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(18)
                            spacing: VfTheme.dp(5)
                            Text {
                                Layout.fillWidth: true
                                text: qsTr("TÊN GIỌNG")
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                font.weight: VfTheme.weightStrong
                            }
                            Text {
                                Layout.preferredWidth: VfTheme.dp(78)
                                text: qsTr("LOẠI")
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                font.weight: VfTheme.weightStrong
                            }
                            Text {
                                Layout.preferredWidth: VfTheme.dp(126)
                                text: qsTr("THAO TÁC")
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                font.weight: VfTheme.weightStrong
                            }
                        }

                        ListView {
                            id: profileList
                            objectName: "voiceApprovedProfileList"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: VfTheme.dp(4)
                            reuseItems: true
                            model: voiceController.omniProfileModel

                            delegate: Rectangle {
                                id: profileRow
                                required property var modelData
                                readonly property bool selected:
                                    String(profileRow.modelData.value || "")
                                    === String(panel.options.omni_voice || "")
                                width: profileList.width
                                implicitHeight: VfTheme.dp(48)
                                radius: VfTheme.dp(8)
                                color: profileRow.selected
                                    ? VfTheme.violetFill : VfTheme.surfaceSoft
                                border.width: profileRow.selected ? 2 : 1
                                border.color: profileRow.selected
                                    ? VfTheme.violet : VfTheme.borderSoft

                                RowLayout {
                                    anchors {
                                        fill: parent
                                        leftMargin: VfTheme.dp(7)
                                        rightMargin: VfTheme.dp(6)
                                    }
                                    spacing: VfTheme.dp(6)
                                    VfAppIcon {
                                        name: "voice-provider-omni"
                                        size: VfTheme.dp(20)
                                        framed: true
                                        frameColor: VfTheme.violetFill
                                        color: VfTheme.violet
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0
                                        TextField {
                                            id: profileNameField
                                            Layout.fillWidth: true
                                            implicitHeight: VfTheme.dp(25)
                                            text: String(profileRow.modelData.name || qsTr("Giọng"))
                                            selectByMouse: true
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontSmall
                                            font.weight: VfTheme.weightStrong
                                            leftPadding: 0
                                            rightPadding: 0
                                            topPadding: 0
                                            bottomPadding: 0
                                            onEditingFinished: {
                                                var nextName = text.trim()
                                                if (nextName.length > 0
                                                        && nextName !== String(
                                                            profileRow.modelData.name || ""))
                                                    voiceController.renameOmniProfile(
                                                        String(profileRow.modelData.id || ""), nextName)
                                            }
                                            background: Item {}
                                        }
                                        Text {
                                            text: profileRow.selected
                                                ? qsTr("Đang dùng · OmniVoice") : qsTr("OmniVoice · đã duyệt")
                                            color: profileRow.selected
                                                ? VfTheme.violetText : VfTheme.textSubtle
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(8)
                                        }
                                    }
                                    Text {
                                        Layout.preferredWidth: VfTheme.dp(72)
                                        text: String(profileRow.modelData.kind
                                                     || qsTr("Profile"))
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        elide: Text.ElideRight
                                    }
                                    IconAction {
                                        icon: "play"
                                        tint: VfTheme.violet
                                        accessibleName: qsTr("Nghe profile")
                                        enabled: !voiceController.omniProfileBusy
                                        onClicked: voiceController.previewOmniProfile(
                                            String(profileRow.modelData.id || ""))
                                    }
                                    VfButton {
                                        text: profileRow.selected
                                            ? qsTr("Đang dùng") : qsTr("Dùng cho script")
                                        compact: true
                                        enabled: !voiceController.omniProfileBusy
                                        onClicked: {
                                            panel.modeSelected("profile")
                                            panel.voiceSelected(String(profileRow.modelData.value || ""))
                                        }
                                    }
                                    IconAction {
                                        icon: "cross-mark-button"
                                        tint: VfTheme.redText
                                        accessibleName: qsTr("Xóa profile")
                                        enabled: !voiceController.omniProfileBusy
                                        onClicked: {
                                            panel.pendingProfileId = String(profileRow.modelData.id || "")
                                            panel.pendingProfileName = String(profileRow.modelData.name || qsTr("Giọng"))
                                            profileDeleteConfirm.open()
                                        }
                                    }
                                }
                            }

                            Column {
                                anchors.centerIn: parent
                                visible: profileList.count === 0
                                spacing: VfTheme.dp(3)
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: voiceController.omniProfileBusy
                                        ? qsTr("Đang đồng bộ thư viện…")
                                        : qsTr("Chưa có giọng đã duyệt")
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    font.weight: VfTheme.weightStrong
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: panel.profileQuery.trim().length > 0
                                        || panel.profileFilter === "selected"
                                        ? qsTr("Không có giọng khớp bộ lọc")
                                        : qsTr("Tạo mẫu rồi chọn ‘Lưu & dùng giọng’ ở bên trái")
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                objectName: "voiceNonOmniSurface"
                anchors.fill: surfaceHost
                visible: panel.provider !== "omnivoice"
                radius: VfTheme.dp(10)
                color: VfTheme.surface
                border.color: panel.providerAccent(panel.provider)

                ColumnLayout {
                    id: nonOmniConfigColumn
                    anchors {
                        fill: parent
                        margins: VfTheme.dp(8)
                    }
                    spacing: VfTheme.dp(6)
                    RowLayout {
                        Layout.fillWidth: true
                        VfAppIcon {
                            name: panel.providerIcon(panel.provider)
                            size: VfTheme.dp(20)
                            framed: true
                            frameColor: VfTheme.surfaceSoft
                            color: panel.providerAccent(panel.provider)
                        }
                        Text {
                            text: panel.provider === "gemini"
                                ? qsTr("CẤU HÌNH GIỌNG CLOUD")
                                : panel.provider === "moss"
                                    ? qsTr("CẤU HÌNH MOSS LOCAL")
                                    : qsTr("CẤU HÌNH GIỌNG VIỆT")
                            color: panel.providerAccent(panel.provider)
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                            font.weight: VfTheme.weightStrong
                        }
                        Text {
                            Layout.fillWidth: true
                            text: panel.provider === "gemini"
                                ? qsTr("1 hoặc 2 người nói · model · chỉ dẫn đạo diễn")
                                : panel.provider === "moss"
                                    ? qsTr("Runtime, nguồn audio và sampling local")
                                    : qsTr("Giọng Việt, cách đọc và chất lượng local")
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideRight
                        }
                    }

                    ColumnLayout {
                        visible: panel.provider === "gemini"
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)

                        GridLayout {
                            Layout.fillWidth: true
                            columns: nonOmniConfigColumn.width >= VfTheme.dp(720) ? 4 : 2
                            rowSpacing: VfTheme.dp(5)
                            columnSpacing: VfTheme.dp(6)
                            VfSelectField {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                label: panel.modeLabel
                                options: panel.modeOptions
                                value: panel.modeValue
                                accent: panel.accent
                                onSelected: value => panel.modeSelected(String(value))
                            }
                            VfSelectField {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                label: qsTr("Người nói")
                                options: [
                                    { label: qsTr("1 người đọc"), value: "mono" },
                                    { label: qsTr("Hội thoại 2 người"), value: "dialogue" }
                                ]
                                value: panel.geminiDialogue ? "dialogue" : "mono"
                                accent: "#0891B2"
                                onSelected: value => panel.setGeminiDialogue(value)
                            }
                            VfSelectField {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                label: qsTr("Mẫu AI Studio")
                                options: panel.geminiPresetOptions()
                                value: String(panel.options.preset_id || "")
                                accent: VfTheme.violet
                                onSelected: value => panel.applyGeminiStudioPreset(String(value))
                            }
                            VfSelectField {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                label: panel.deliveryLabel
                                options: panel.deliveryOptions
                                value: panel.deliveryValue
                                accent: panel.accent
                                onSelected: value => panel.deliverySelected(String(value))
                            }
                        }

                        GeminiSpeakerCard {
                            speakerIndex: 0
                            heading: qsTr("NGƯỜI NÓI 1")
                        }
                        GeminiSpeakerCard {
                            visible: panel.geminiDialogue
                            speakerIndex: 1
                            heading: qsTr("NGƯỜI NÓI 2")
                        }
                        Text {
                            visible: panel.geminiDialogue
                            Layout.fillWidth: true
                            text: qsTr("Script hội thoại: mỗi dòng `Tên: lời thoại`. Tên phải khớp hai người nói.")
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            wrapMode: Text.WordWrap
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: nonOmniConfigColumn.width >= VfTheme.dp(720) ? 3 : 1
                            rowSpacing: VfTheme.dp(5)
                            columnSpacing: VfTheme.dp(6)
                            VfTextField {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                label: qsTr("Bối cảnh")
                                value: String(panel.options.scene || "")
                                placeholder: qsTr("Phòng thu yên tĩnh")
                                accent: VfTheme.cyan
                                onCommitted: value => panel.optionChanged("scene", value)
                            }
                            VfTextField {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                label: qsTr("Ngữ cảnh mẫu")
                                value: String(panel.options.sample_context || "")
                                placeholder: qsTr("Giọng kể tự nhiên")
                                accent: VfTheme.violet
                                onCommitted: value => panel.optionChanged("sample_context", value)
                            }
                            VfTextField {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                label: qsTr("Chỉ dẫn đạo diễn")
                                value: String(panel.options.director_notes
                                    || panel.options.gemini_director_notes || "")
                                placeholder: qsTr("Nhịp vừa, kết câu tự nhiên")
                                accent: VfTheme.cyan
                                onCommitted: value => panel.optionsPatched({
                                    director_notes: value,
                                    gemini_director_notes: value
                                })
                            }
                        }
                    }

                    GridLayout {
                        visible: panel.provider !== "gemini"
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight
                        columns: panel.nonOmniGridColumns
                        rowSpacing: VfTheme.dp(5)
                        columnSpacing: VfTheme.dp(6)

                        VfSelectField {
                            Layout.fillWidth: true
                            label: panel.modeLabel
                            options: panel.modeOptions
                            value: panel.modeValue
                            accent: panel.accent
                            onSelected: value => panel.modeSelected(String(value))
                        }
                        VfSelectField {
                            Layout.fillWidth: true
                            label: panel.voiceLabel
                            options: panel.voiceOptions
                            value: panel.voiceValue
                            accent: panel.accent
                            onSelected: value => panel.voiceSelected(String(value))
                        }
                        VfSelectField {
                            Layout.fillWidth: true
                            label: panel.deliveryLabel
                            options: panel.deliveryOptions
                            value: panel.deliveryValue
                            accent: panel.accent
                            onSelected: value => panel.deliverySelected(String(value))
                        }
                        VfTextField {
                            visible: panel.provider === "moss"
                            Layout.fillWidth: true
                            label: qsTr("Seed")
                            value: String(panel.options.moss_seed || "")
                            placeholder: qsTr("Trống = seed mới")
                            accent: VfTheme.cyan
                            onCommitted: value => panel.optionChanged("moss_seed", value)
                        }
                        VfValueField {
                            visible: panel.provider === "moss"
                                && panel.modeValue !== "direct"
                            Layout.fillWidth: true
                            label: qsTr("Audio mẫu")
                            value: panel.fileName(panel.options.moss_ref_audio)
                            placeholder: qsTr("Chưa chọn")
                            actionText: qsTr("Chọn")
                            accent: VfTheme.cyan
                            onActivated: panel.chooseAudio(
                                qsTr("Chọn audio mẫu MOSS"), "moss_ref_audio")
                        }
                        VfTextField {
                            visible: panel.provider === "moss"
                                && (panel.modeValue === "continuation"
                                    || panel.modeValue === "continuation_clone")
                            Layout.fillWidth: true
                            label: qsTr("Transcript audio mẫu")
                            value: String(panel.options.moss_prompt_text || "")
                            placeholder: qsTr("Transcript chính xác")
                            accent: VfTheme.cyan
                            onCommitted: value => panel.optionChanged("moss_prompt_text", value)
                        }
                        VfTextField {
                            visible: panel.provider === "moss"
                            Layout.fillWidth: true
                            label: qsTr("Thời lượng mong muốn")
                            value: String(panel.options.moss_duration || "")
                            placeholder: qsTr("Tự động")
                            accent: VfTheme.cyan
                            onCommitted: value => panel.optionChanged("moss_duration", value)
                        }
                        VfValueField {
                            visible: panel.provider === "vieneu"
                            Layout.fillWidth: true
                            label: qsTr("Audio mẫu clone")
                            value: panel.fileName(panel.options.vieneu_ref_audio)
                            placeholder: qsTr("Không bắt buộc")
                            actionText: qsTr("Chọn")
                            accent: VfTheme.greenBorder
                            onActivated: panel.chooseAudio(
                                qsTr("Chọn audio mẫu VieNeu"), "vieneu_ref_audio")
                        }
                        VfSelectField {
                            visible: panel.provider === "vieneu"
                            Layout.fillWidth: true
                            label: qsTr("Khử ồn audio mẫu")
                            options: [
                                { label: qsTr("Bật"), value: "1" },
                                { label: qsTr("Tắt"), value: "0" }
                            ]
                            value: String(panel.options.vieneu_denoise || "1")
                            accent: VfTheme.greenBorder
                            onSelected: value => panel.optionChanged(
                                "vieneu_denoise", String(value))
                        }
                    }
                }
            }
        }

        Rectangle {
            objectName: "voiceUsageConfiguration"
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(58)
            radius: VfTheme.dp(9)
            color: VfTheme.surfaceSoft
            border.color: panel.provider === "omnivoice"
                ? VfTheme.violetBorderSoft : VfTheme.borderSoft

            RowLayout {
                anchors {
                    fill: parent
                    margins: VfTheme.dp(5)
                }
                spacing: VfTheme.dp(5)

                ColumnLayout {
                    Layout.preferredWidth: VfTheme.dp(132)
                    spacing: 0
                    Text {
                        text: panel.provider === "omnivoice"
                            ? panel.omniCreateOpen
                                ? qsTr("THAM SỐ MẪU")
                                : qsTr("CẤU HÌNH AUDIO CUỐI")
                            : qsTr("CẤU HÌNH JOB")
                        color: panel.accent
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightStrong
                    }
                    Text {
                        Layout.fillWidth: true
                        text: panel.provider === "omnivoice"
                            ? panel.omniCreateOpen
                                ? qsTr("Ảnh hưởng mẫu duyệt")
                                : qsTr("Chỉ áp dụng cho audio tạo mới")
                            : qsTr("Chỉ áp dụng cho job mới")
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(8)
                        elide: Text.ElideRight
                    }
                }

                VfSelectField {
                    visible: panel.provider === "omnivoice"
                    Layout.preferredWidth: VfTheme.dp(150)
                    fieldHeight: VfTheme.dp(48)
                    selectorHeight: VfTheme.dp(23)
                    labelFontSize: VfTheme.dp(9)
                    valueFontSize: VfTheme.dp(9)
                    label: panel.deliveryLabel
                    options: panel.deliveryOptions
                    value: panel.deliveryValue
                    accent: VfTheme.violet
                    onSelected: value => {
                        panel.invalidateOmniCandidate()
                        panel.deliverySelected(String(value))
                    }
                }
                UsageSlider {
                    visible: panel.provider === "omnivoice"
                    Layout.preferredWidth: VfTheme.dp(150)
                    label: qsTr("Tốc độ")
                    from: 0.75
                    to: 1.5
                    stepSize: 0.05
                    value: panel.numberValue(panel.options.omni_speed, 1)
                    accent: VfTheme.violet
                    format: value => value.toFixed(2) + "×"
                    onCommitted: value => {
                        panel.invalidateOmniCandidate()
                        panel.optionChanged("omni_speed", value.toFixed(2))
                    }
                }
                UsageSlider {
                    visible: panel.provider === "omnivoice"
                    Layout.preferredWidth: VfTheme.dp(150)
                    label: qsTr("Độ bám chỉ dẫn")
                    from: 1
                    to: 5
                    stepSize: 0.1
                    value: panel.numberValue(panel.options.omni_guidance, 2)
                    accent: VfTheme.cyan
                    format: value => value.toFixed(1)
                    onCommitted: value => {
                        panel.invalidateOmniCandidate()
                        panel.optionChanged("omni_guidance", value.toFixed(1))
                    }
                }
                VfSelectField {
                    visible: panel.provider === "omnivoice"
                        && !panel.omniCreateOpen
                    Layout.preferredWidth: VfTheme.dp(150)
                    fieldHeight: VfTheme.dp(48)
                    selectorHeight: VfTheme.dp(23)
                    labelFontSize: VfTheme.dp(9)
                    valueFontSize: VfTheme.dp(9)
                    label: qsTr("Hậu kỳ")
                    options: [
                        { label: "Broadcast", value: "broadcast" },
                        { label: "Podcast", value: "podcast" },
                        { label: "Cinematic", value: "cinematic" },
                        { label: "Warm", value: "warm" },
                        { label: "Raw", value: "raw" }
                    ]
                    value: String(panel.options.omni_effect_preset || "broadcast")
                    accent: VfTheme.greenBorder
                    onSelected: value => panel.optionChanged(
                        "omni_effect_preset", String(value))
                }
                VfSelectField {
                    visible: panel.provider === "omnivoice"
                        && !panel.omniCreateOpen
                    Layout.preferredWidth: VfTheme.dp(150)
                    fieldHeight: VfTheme.dp(48)
                    selectorHeight: VfTheme.dp(23)
                    labelFontSize: VfTheme.dp(9)
                    valueFontSize: VfTheme.dp(9)
                    label: qsTr("Chất lượng audio cuối")
                    options: [
                        { label: qsTr("Nghe thử · 16"), value: "16" },
                        { label: qsTr("Narration · 32"), value: "32" },
                        { label: qsTr("Tối đa · 64"), value: "64" }
                    ]
                    value: String(panel.options.omni_num_step || "32")
                    accent: VfTheme.cyan
                    onSelected: value => panel.optionChanged(
                        "omni_num_step", String(value))
                }

                Item { Layout.fillWidth: true }

                Text {
                    visible: panel.provider === "omnivoice"
                        && panel.omniCreateOpen
                    Layout.preferredWidth: VfTheme.dp(230)
                    text: qsTr("Hậu kỳ và chất lượng audio cuối được chỉnh sau khi lưu giọng.")
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    wrapMode: Text.WordWrap
                }

                VfButton {
                    visible: panel.provider !== "omnivoice"
                        || !panel.omniCreateOpen
                    text: qsTr("Cấu hình (%1)").arg(
                        String(voiceController.voiceConfigPresetCount || 0))
                    leadingIcon: "save"
                    compact: true
                    onClicked: presetPopup.open()
                }
                VfButton {
                    visible: panel.provider !== "omnivoice"
                    text: qsTr("Nghe thử")
                    leadingIcon: "play"
                    compact: true
                    enabled: !panel.busy && !panel.hardwareBlocked
                    onClicked: panel.previewRequested()
                }
                VfButton {
                    visible: panel.provider !== "omnivoice"
                        || !panel.omniCreateOpen
                    text: panel.busy
                        ? qsTr("Đang lưu…")
                        : panel.provider === "omnivoice"
                            ? qsTr("Lưu làm mặc định") : qsTr("Áp dụng")
                    tone: "accent"
                    compact: true
                    enabled: panel.draftDirty && !panel.busy
                    onClicked: panel.saveRequested()
                }
                IconAction {
                    visible: panel.provider !== "omnivoice"
                        || !panel.omniCreateOpen
                    icon: "counterclockwise-arrows-button"
                    tint: VfTheme.textMuted
                    accessibleName: qsTr("Đặt lại thay đổi")
                    enabled: panel.draftDirty && !panel.busy
                    onClicked: panel.resetRequested()
                }
            }
        }
    }

    Popup {
        id: profilePickerPopup
        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: Math.min(VfTheme.dp(520), parent.width - VfTheme.dp(32))
        height: Math.min(
            VfTheme.dp(390),
            parent.height - VfTheme.dp(32),
            VfTheme.dp(132 + Math.max(
                2, Math.min(
                    5, voiceController.omniProfileOptions.length)) * 59))
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: VfTheme.dp(10)

        onOpened: {
            panel.profileFilter = "all"
            panel.profileQuery = ""
            profileSearchInput.forceActiveFocus()
        }

        background: Rectangle {
            radius: VfTheme.dp(11)
            color: VfTheme.surface
            border.color: VfTheme.violet
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(7)
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: qsTr("ĐỔI GIỌNG ĐANG DÙNG")
                    color: VfTheme.violetText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    font.weight: VfTheme.weightStrong
                }
                IconAction {
                    icon: "counterclockwise-arrows-button"
                    tint: VfTheme.violet
                    accessibleName: qsTr("Đồng bộ thư viện")
                    enabled: !voiceController.omniProfileBusy
                    onClicked: voiceController.syncOmniProfiles("")
                }
                IconAction {
                    icon: "cross-mark-button"
                    tint: VfTheme.textMuted
                    accessibleName: qsTr("Đóng thư viện giọng")
                    onClicked: profilePickerPopup.close()
                }
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("Chọn một profile đã duyệt. Thay đổi có hiệu lực cho audio và job tạo sau đó.")
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                wrapMode: Text.WordWrap
            }
            TextField {
                id: profileSearchInput
                Layout.fillWidth: true
                implicitHeight: VfTheme.controlHeight
                placeholderText: qsTr("Tìm kiếm giọng…")
                selectByMouse: true
                leftPadding: VfTheme.dp(30)
                rightPadding: VfTheme.dp(8)
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                color: VfTheme.text
                onTextChanged: panel.profileQuery = text
                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: VfTheme.surfaceSoft
                    border.color: parent.activeFocus
                        ? VfTheme.violet : VfTheme.borderSoft
                }
                VfAppIcon {
                    anchors {
                        left: parent.left
                        leftMargin: VfTheme.dp(9)
                        verticalCenter: parent.verticalCenter
                    }
                    name: "magnifying-glass"
                    size: VfTheme.dp(13)
                    framed: false
                    color: VfTheme.textMuted
                }
            }
            ListView {
                id: profilePickerList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: VfTheme.dp(5)
                reuseItems: true
                model: voiceController.omniProfileModel

                delegate: Rectangle {
                    id: pickerRow
                    required property var modelData
                    readonly property bool selected:
                        String(pickerRow.modelData.value || "")
                        === panel.omniConsumerProfileId
                    width: profilePickerList.width
                    implicitHeight: VfTheme.dp(54)
                    radius: VfTheme.dp(8)
                    color: pickerRow.selected
                        ? VfTheme.violetFill : VfTheme.surfaceSoft
                    border.width: pickerRow.selected ? 2 : 1
                    border.color: pickerRow.selected
                        ? VfTheme.violet : VfTheme.borderSoft

                    RowLayout {
                        anchors {
                            fill: parent
                            margins: VfTheme.dp(7)
                        }
                        spacing: VfTheme.dp(7)
                        VfAppIcon {
                            name: "voice-provider-omni"
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
                                text: String(pickerRow.modelData.name || qsTr("Giọng"))
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: VfTheme.weightStrong
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: pickerRow.selected
                                    ? qsTr("Đang dùng") : qsTr("OmniVoice · đã duyệt")
                                color: pickerRow.selected
                                    ? VfTheme.violetText : VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                            }
                        }
                        IconAction {
                            icon: "play"
                            tint: VfTheme.violet
                            accessibleName: qsTr("Nghe profile")
                            enabled: !voiceController.omniProfileBusy
                            onClicked: voiceController.previewOmniProfile(
                                String(pickerRow.modelData.id || ""))
                        }
                        VfButton {
                            text: pickerRow.selected
                                ? qsTr("Đang dùng") : qsTr("Chọn")
                            compact: true
                            enabled: !pickerRow.selected
                                && !voiceController.omniProfileBusy
                            onClicked: panel.activateOmniProfile(
                                String(pickerRow.modelData.value || ""))
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: profilePickerList.count === 0
                    text: voiceController.omniProfileBusy
                        ? qsTr("Đang tải thư viện giọng…")
                        : qsTr("Không có giọng phù hợp")
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                }
            }
        }
    }

    Popup {
        id: presetPopup
        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: VfTheme.dp(360)
        height: Math.min(
            parent.height - VfTheme.dp(48),
            VfTheme.dp(148)
                + Math.max(1, Math.min(4, Number(voiceController.voiceConfigPresetCount || 0)))
                    * VfTheme.dp(42))
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: VfTheme.dp(10)
        background: Rectangle {
            radius: VfTheme.dp(11)
            color: VfTheme.surface
            border.color: panel.accent
        }
        contentItem: ColumnLayout {
            spacing: VfTheme.dp(7)
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: qsTr("CẤU HÌNH PROVIDER ĐÃ LƯU")
                    color: panel.accent
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    font.weight: VfTheme.weightStrong
                }
                Text {
                    text: qsTr("Profile giọng là thư viện riêng")
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(8)
                }
            }
            ListView {
                id: presetList
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(
                    VfTheme.dp(38),
                    Math.min(4, Math.max(1, count)) * VfTheme.dp(42))
                clip: true
                spacing: VfTheme.dp(4)
                reuseItems: true
                model: voiceController.voiceConfigPresetModel
                delegate: Rectangle {
                    id: presetRow
                    required property var modelData
                    readonly property string presetId:
                        String(presetRow.modelData.id || "")
                    width: presetList.width
                    implicitHeight: VfTheme.dp(38)
                    radius: VfTheme.dp(7)
                    color: presetId === panel.selectedConfigPresetId
                        ? VfTheme.violetFill : VfTheme.surfaceSoft
                    border.color: presetId === panel.selectedConfigPresetId
                        ? panel.accent : VfTheme.borderSoft
                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: VfTheme.dp(7)
                            rightMargin: VfTheme.dp(7)
                        }
                        spacing: VfTheme.dp(6)
                        VfAppIcon {
                            name: panel.providerIcon(String(
                                presetRow.modelData.provider || "gemini"))
                            size: VfTheme.dp(15)
                            framed: false
                            color: panel.providerAccent(String(
                                presetRow.modelData.provider || "gemini"))
                        }
                        Text {
                            Layout.fillWidth: true
                            text: String(presetRow.modelData.name || qsTr("Cấu hình"))
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            font.weight: VfTheme.weightStrong
                            elide: Text.ElideRight
                        }
                        Text {
                            text: String(presetRow.modelData.provider_label || "")
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(8)
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            panel.selectedConfigPresetId = presetRow.presetId
                            panel.selectedConfigPresetName = String(
                                presetRow.modelData.name || "")
                            presetNameInput.text = panel.selectedConfigPresetName
                            panel.configPresetSelected(presetRow.presetId)
                        }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    visible: voiceController.voiceConfigPresetCount === 0
                    text: qsTr("Chưa có cấu hình đã lưu")
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                }
            }
            TextField {
                id: presetNameInput
                Layout.fillWidth: true
                implicitHeight: VfTheme.controlHeight
                placeholderText: qsTr("Tên cấu hình provider")
                selectByMouse: true
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: VfTheme.surfaceSoft
                    border.color: parent.activeFocus ? panel.accent : VfTheme.borderBox
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)
                VfButton {
                    Layout.fillWidth: true
                    text: qsTr("Lưu mới")
                    compact: true
                    enabled: !voiceController.voiceConfigPresetBusy
                        && presetNameInput.text.trim().length > 0
                    onClicked: panel.saveConfigPreset()
                }
                VfButton {
                    text: qsTr("Cập nhật")
                    compact: true
                    enabled: panel.selectedConfigPresetId.length > 0
                        && !voiceController.voiceConfigPresetBusy
                    onClicked: panel.updateConfigPreset()
                }
                VfButton {
                    text: qsTr("Đổi tên")
                    compact: true
                    enabled: panel.selectedConfigPresetId.length > 0
                        && presetNameInput.text.trim().length > 0
                        && !voiceController.voiceConfigPresetBusy
                    onClicked: panel.renameConfigPreset()
                }
                VfButton {
                    text: qsTr("Xóa")
                    tone: "danger"
                    compact: true
                    enabled: panel.selectedConfigPresetId.length > 0
                        && !voiceController.voiceConfigPresetBusy
                    onClicked: presetDeleteConfirm.open()
                }
            }
        }
    }

    Popup {
        id: presetDeleteConfirm
        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: VfTheme.dp(330)
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        padding: VfTheme.dp(14)
        background: Rectangle {
            radius: VfTheme.dp(10)
            color: VfTheme.surface
            border.color: VfTheme.redBorderSoft
        }
        contentItem: ColumnLayout {
            spacing: VfTheme.dp(9)
            Text {
                Layout.fillWidth: true
                text: qsTr("Xóa cấu hình ‘%1’?").arg(panel.selectedConfigPresetName)
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightStrong
                wrapMode: Text.WordWrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("Thao tác này không xóa profile giọng.")
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                VfButton {
                    text: qsTr("Hủy")
                    compact: true
                    onClicked: presetDeleteConfirm.close()
                }
                VfButton {
                    text: qsTr("Xóa")
                    tone: "danger"
                    compact: true
                    onClicked: {
                        var result = voiceController.removeVoiceConfigPreset(
                            panel.selectedConfigPresetId)
                        if (result && result.ok) {
                            panel.selectedConfigPresetId = ""
                            panel.selectedConfigPresetName = ""
                            presetNameInput.text = ""
                            presetDeleteConfirm.close()
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: profileDeleteConfirm
        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: VfTheme.dp(330)
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        padding: VfTheme.dp(14)
        background: Rectangle {
            radius: VfTheme.dp(10)
            color: VfTheme.surface
            border.color: VfTheme.redBorderSoft
        }
        contentItem: ColumnLayout {
            spacing: VfTheme.dp(9)
            Text {
                Layout.fillWidth: true
                text: qsTr("Xóa profile ‘%1’?").arg(panel.pendingProfileName)
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightStrong
                wrapMode: Text.WordWrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("Master/Clone sẽ không còn chọn được profile này.")
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                VfButton {
                    text: qsTr("Hủy")
                    compact: true
                    onClicked: profileDeleteConfirm.close()
                }
                VfButton {
                    text: qsTr("Xóa profile")
                    tone: "danger"
                    compact: true
                    onClicked: {
                        voiceController.removeOmniProfile(panel.pendingProfileId)
                        profileDeleteConfirm.close()
                    }
                }
            }
        }
    }

    component GeminiSpeakerCard: Rectangle {
        id: speakerCard
        property int speakerIndex: 0
        property string heading: qsTr("Người nói")

        Layout.fillWidth: true
        implicitHeight: speakerCol.implicitHeight + VfTheme.dp(12)
        radius: VfTheme.dp(8)
        color: VfTheme.surfaceSoft
        border.color: speakerCard.speakerIndex === 1
            ? VfTheme.violetBorderSoft : VfTheme.borderSoft

        ColumnLayout {
            id: speakerCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: VfTheme.dp(6)
            }
            spacing: VfTheme.dp(5)
            Text {
                text: speakerCard.heading
                color: speakerCard.speakerIndex === 1
                    ? VfTheme.violet : panel.accent
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.weight: VfTheme.weightStrong
                font.letterSpacing: VfTheme.dp(0.3)
            }
            GridLayout {
                Layout.fillWidth: true
                columns: speakerCol.width >= VfTheme.dp(720) ? 5 : 3
                rowSpacing: VfTheme.dp(5)
                columnSpacing: VfTheme.dp(6)
                VfTextField {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    label: qsTr("Tên trong script")
                    value: panel.geminiSpeakerValue(
                        speakerCard.speakerIndex, "name",
                        speakerCard.speakerIndex === 0
                            ? "Speaker 1" : "Speaker 2")
                    placeholder: speakerCard.speakerIndex === 0
                        ? "Speaker 1" : "Speaker 2"
                    accent: speakerCard.speakerIndex === 1
                        ? VfTheme.violet : panel.accent
                    onCommitted: value => panel.patchGeminiSpeaker(
                        speakerCard.speakerIndex, "name", value)
                }
                VfSelectField {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    label: qsTr("Giọng")
                    options: panel.voiceOptions
                    value: panel.geminiSpeakerValue(
                        speakerCard.speakerIndex, "voice",
                        speakerCard.speakerIndex === 0
                            ? panel.voiceValue : "Puck")
                    accent: speakerCard.speakerIndex === 1
                        ? VfTheme.violet : panel.accent
                    onSelected: value => panel.patchGeminiSpeaker(
                        speakerCard.speakerIndex, "voice", value)
                }
                VfSelectField {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    label: qsTr("Style")
                    options: voiceController.directorStyles
                    value: panel.geminiSpeakerValue(
                        speakerCard.speakerIndex, "style", "")
                    accent: "#10B981"
                    onSelected: value => panel.patchGeminiSpeaker(
                        speakerCard.speakerIndex, "style", value)
                }
                VfSelectField {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    label: qsTr("Nhịp")
                    options: voiceController.directorPaces
                    value: panel.geminiSpeakerValue(
                        speakerCard.speakerIndex, "pace", "")
                    accent: "#F59E0B"
                    onSelected: value => panel.patchGeminiSpeaker(
                        speakerCard.speakerIndex, "pace", value)
                }
                VfSelectField {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    label: qsTr("Chất giọng")
                    options: voiceController.directorAccents
                    value: panel.geminiSpeakerValue(
                        speakerCard.speakerIndex, "accent", "")
                    accent: "#EC4899"
                    onSelected: value => panel.patchGeminiSpeaker(
                        speakerCard.speakerIndex, "accent", value)
                }
            }
            VfTextField {
                Layout.fillWidth: true
                label: qsTr("Audio profile")
                value: panel.geminiSpeakerValue(
                    speakerCard.speakerIndex, "audio_profile",
                    speakerCard.speakerIndex === 0
                        ? String(panel.options.audio_profile
                            || panel.options.gemini_audio_profile || "")
                        : "")
                placeholder: speakerCard.speakerIndex === 0
                    ? qsTr("Ấm, gần gũi, rõ chữ")
                    : qsTr("Mô tả riêng người nói 2")
                accent: speakerCard.speakerIndex === 1
                    ? VfTheme.violet : VfTheme.primary
                onCommitted: value => {
                    panel.patchGeminiSpeaker(
                        speakerCard.speakerIndex, "audio_profile", value)
                    if (speakerCard.speakerIndex === 0)
                        panel.optionsPatched({
                            audio_profile: value,
                            gemini_audio_profile: value
                        })
                }
            }
        }
    }

    component StepCard: Rectangle {
        id: stepCard
        property string step: "1"
        property string title: ""
        property color accent: VfTheme.primary
        default property alias content: stepContent.data

        implicitHeight: stepFrame.implicitHeight + VfTheme.dp(12)
        radius: VfTheme.dp(8)
        color: stepCard.state === "done"
            ? VfTheme.greenFill
            : stepCard.state === "active"
                ? VfTheme.surfaceSoft : "transparent"
        border.width: 1
        border.color: stepCard.state === "done"
            ? VfTheme.greenBorderSoft
            : stepCard.state === "active"
                ? stepCard.accent : VfTheme.borderSoft
        ColumnLayout {
            id: stepFrame
            anchors {
                fill: parent
                margins: VfTheme.dp(6)
            }
            spacing: VfTheme.dp(4)
            RowLayout {
                Layout.fillWidth: true
                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(20)
                    Layout.preferredHeight: VfTheme.dp(20)
                    radius: width / 2
                    color: stepCard.state === "done"
                        ? VfTheme.greenBorder : stepCard.state === "pending"
                            ? VfTheme.borderStrong : stepCard.accent
                    Text {
                        anchors.centerIn: parent
                        text: stepCard.step
                        color: "#FFFFFF"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(9)
                        font.weight: VfTheme.weightStrong
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: stepCard.title
                    color: stepCard.state === "done"
                        ? VfTheme.greenText : stepCard.state === "pending"
                            ? VfTheme.textSubtle : stepCard.accent
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                }
            }
            ColumnLayout {
                id: stepContent
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: VfTheme.dp(4)
            }
        }
    }

    component StudioTextArea: Rectangle {
        id: textAreaCard
        property string label: ""
        property string value: ""
        property string placeholder: ""
        property color accent: VfTheme.primary
        signal committed(string value)

        Layout.fillWidth: true
        implicitHeight: VfTheme.dp(112)
        radius: VfTheme.radiusControl
        color: VfTheme.surfaceSoft
        border.color: editor.activeFocus
            ? textAreaCard.accent : VfTheme.borderSoft

        Rectangle {
            anchors {
                left: parent.left
                leftMargin: VfTheme.dp(7)
                top: parent.top
                topMargin: VfTheme.dp(8)
            }
            width: VfTheme.dp(3)
            height: VfTheme.dp(10)
            radius: width / 2
            color: textAreaCard.accent
        }
        Text {
            anchors {
                left: parent.left
                leftMargin: VfTheme.dp(15)
                right: parent.right
                rightMargin: VfTheme.dp(8)
                top: parent.top
                topMargin: VfTheme.dp(6)
            }
            text: textAreaCard.label
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontControl
            font.weight: VfTheme.weightStrong
            elide: Text.ElideRight
        }
        TextArea {
            id: editor
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                margins: VfTheme.dp(7)
                topMargin: VfTheme.dp(26)
            }
            text: textAreaCard.value
            placeholderText: textAreaCard.placeholder
            selectByMouse: true
            wrapMode: TextEdit.Wrap
            leftPadding: VfTheme.dp(8)
            rightPadding: VfTheme.dp(8)
            topPadding: VfTheme.dp(6)
            bottomPadding: VfTheme.dp(16)
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontBody
            color: VfTheme.text
            placeholderTextColor: VfTheme.textSubtle
            Accessible.name: textAreaCard.label
            onActiveFocusChanged: {
                if (!activeFocus && text.trim() !== textAreaCard.value)
                    textAreaCard.committed(text.trim())
            }
            background: Rectangle {
                radius: VfTheme.radiusControl - 2
                color: VfTheme.surface
                border.color: "transparent"
            }
        }
        Text {
            anchors {
                right: parent.right
                rightMargin: VfTheme.dp(14)
                bottom: parent.bottom
                bottomMargin: VfTheme.dp(10)
            }
            text: String(editor.length) + " / 2.000"
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(8)
        }
    }

    component IconAction: Rectangle {
        id: iconAction
        property string icon: "play"
        property color tint: VfTheme.textMuted
        property string accessibleName: ""
        signal clicked()

        implicitWidth: VfTheme.dp(29)
        implicitHeight: VfTheme.dp(29)
        radius: VfTheme.dp(8)
        color: iconMouse.containsMouse && enabled
            ? VfTheme.surface : "transparent"
        border.color: activeFocus ? iconAction.tint : VfTheme.borderSoft
        opacity: enabled ? 1 : 0.4
        activeFocusOnTab: enabled
        Accessible.role: Accessible.Button
        Accessible.name: iconAction.accessibleName
        VfAppIcon {
            anchors.centerIn: parent
            name: iconAction.icon
            size: VfTheme.dp(13)
            framed: false
            color: iconAction.tint
        }
        Keys.onReturnPressed: if (enabled) iconAction.clicked()
        Keys.onEnterPressed: if (enabled) iconAction.clicked()
        Keys.onSpacePressed: if (enabled) iconAction.clicked()
        MouseArea {
            id: iconMouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: iconAction.enabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                iconAction.forceActiveFocus()
                iconAction.clicked()
            }
        }
    }

    component UsageSlider: ColumnLayout {
        id: usageSlider
        property string label: ""
        property real from: 0
        property real to: 1
        property real stepSize: 0.1
        property real value: 0
        property color accent: VfTheme.primary
        property var format: (function(value) { return String(value) })
        signal committed(real value)

        spacing: 0
        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: usageSlider.label
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                font.weight: VfTheme.weightStrong
                elide: Text.ElideRight
            }
            Text {
                text: usageSlider.format(usageControl.value)
                color: usageSlider.accent
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                font.weight: VfTheme.weightStrong
            }
        }
        Slider {
            id: usageControl
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(28)
            from: usageSlider.from
            to: usageSlider.to
            stepSize: usageSlider.stepSize
            snapMode: Slider.SnapAlways
            value: usageSlider.value
            onMoved: {
                if (!pressed)
                    keyboardCommit.restart()
            }
            onPressedChanged: {
                if (!pressed) {
                    keyboardCommit.stop()
                    usageSlider.committed(value)
                }
            }
            background: Rectangle {
                x: usageControl.leftPadding
                y: usageControl.topPadding
                    + usageControl.availableHeight / 2 - height / 2
                width: usageControl.availableWidth
                height: VfTheme.dp(3)
                radius: height / 2
                color: VfTheme.borderStrong
                Rectangle {
                    width: usageControl.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: usageSlider.accent
                }
            }
            handle: Rectangle {
                x: usageControl.leftPadding + usageControl.visualPosition
                    * (usageControl.availableWidth - width)
                y: usageControl.topPadding
                    + usageControl.availableHeight / 2 - height / 2
                implicitWidth: VfTheme.dp(13)
                implicitHeight: VfTheme.dp(13)
                radius: width / 2
                color: usageSlider.accent
                border.width: 2
                border.color: "#FFFFFF"
            }
        }
        Timer {
            id: keyboardCommit
            interval: 180
            repeat: false
            onTriggered: usageSlider.committed(usageControl.value)
        }
    }
}
