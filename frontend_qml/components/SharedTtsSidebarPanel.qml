pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

// Compact three-column Voice Studio configuration surface. The parent
// SharedTtsInlinePanel owns the draft and the async persistence contract.
// This component only stages edits and emits one explicit save request.
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
    property string selectedConfigPresetId: ""
    property string selectedConfigPresetName: ""
    property string configPresetDialogMode: "save"

    property var engineInfo: ({})

    readonly property var hardware:
        (panel.engineInfo || ({})).hardware || ({})
    readonly property string mossBackend:
        String(panel.options.moss_backend || "auto").toLowerCase()
    readonly property bool mossNano: {
        if (panel.provider !== "moss"
                || panel.mossBackend === "local_4b"
                || panel.mossBackend === "local_4b_hybrid")
            return false
        if (panel.mossBackend === "nano_cpu")
            return true
        var metrics = (panel.hardware || ({})).metrics || ({})
        return String(metrics.engine || "") === "moss_nano"
    }
    readonly property bool mossHybrid: {
        if (panel.provider !== "moss" || panel.mossNano)
            return false
        if (panel.mossBackend === "local_4b_hybrid")
            return true
        if (panel.mossBackend !== "auto")
            return false
        var metrics = (panel.hardware || ({})).metrics || ({})
        var vram = Number(metrics.nvidia_vram_gb || 0)
        return vram > 0 && vram < 16
    }
    readonly property bool omniCloneSourceReady:
        panel.modeValue !== "clone"
        || String(panel.options.omni_ref_audio || "").length > 0

    property string modeLabel: "Chế độ"
    property var modeOptions: []
    property string modeValue: ""
    property string voiceLabel: "Giọng"
    property var voiceOptions: []
    property string voiceValue: ""
    property string deliveryLabel: "Ngôn ngữ"
    property var deliveryOptions: []
    property string deliveryValue: ""

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
            return "#0D9488"
        if (value === "vieneu")
            return "#10B981"
        return VfTheme.primary
    }

    function numberValue(value, fallback) {
        var result = Number(value)
        return isFinite(result) ? result : fallback
    }

    function fileName(path) {
        var parts = String(path || "").replace(/\\/g, "/").split("/")
        return parts.length ? parts[parts.length - 1] : ""
    }

    function chooseAudio(title, key) {
        var picked = nativeShell.pickFiles(
            title,
            "Audio Files (*.wav *.mp3 *.m4a *.flac);;All Files (*.*)", "")
        if (picked && picked.ok && picked.paths && picked.paths.length > 0)
            panel.optionChanged(key, String(picked.paths[0] || ""))
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
                name: "Speaker 1",
                voice: String(panel.voiceValue || "Kore"),
                audio_profile: "",
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
        panel.optionsPatched({ speakers: rows })
    }

    function setGeminiDialogue(value) {
        var enabled = String(value) === "dialogue"
        var rows = panel.geminiSpeakers().slice(0, enabled ? 2 : 1)
        if (enabled && rows.length < 2) {
            rows.push({
                name: "Speaker 2",
                voice: "Puck",
                audio_profile: "",
                style: "",
                pace: "",
                accent: ""
            })
        }
        panel.optionsPatched({
            dialogue_enabled: enabled,
            speakers: rows
        })
    }

    function providerKind(value) {
        return value === "gemini" ? "CLOUD" : "LOCAL"
    }

    function workflowTitle() {
        if (panel.provider === "omnivoice")
            return "XƯỞNG GIỌNG OMNI"
        if (panel.provider === "gemini")
            return "GIỌNG CLOUD GEMINI"
        if (panel.provider === "moss")
            return "GIỌNG LOCAL MOSS"
        return "GIỌNG VIỆT VIENEU"
    }

    function workflowHint() {
        if (panel.provider === "omnivoice")
            return "Sản xuất: nguồn → tạo thử → nghe → lưu profile"
        if (panel.provider === "gemini")
            return "Chọn model, cast giọng và chỉ dẫn cách đọc"
        if (panel.provider === "moss")
            return "Chọn runtime phù hợp máy rồi cấu hình sinh audio"
        return "Chọn giọng Việt, cách đọc và chất lượng local"
    }

    function openPresetDialog(mode, presetId, presetName) {
        panel.configPresetDialogMode = String(mode || "save")
        panel.selectedConfigPresetId = String(presetId || "")
        panel.selectedConfigPresetName = String(presetName || "")
        presetNameInput.text = panel.configPresetDialogMode === "save"
            ? panel.providerDisplay + " · cấu hình mới"
            : panel.selectedConfigPresetName
        configPresetDialog.open()
        if (panel.configPresetDialogMode !== "delete") {
            presetNameInput.forceActiveFocus()
            presetNameInput.selectAll()
        }
    }

    function confirmPresetDialog() {
        var result = ({ ok: false })
        if (panel.configPresetDialogMode === "save") {
            result = voiceController.saveVoiceConfigPreset(
                String(presetNameInput.text || ""), panel.provider,
                panel.options || ({}))
        } else if (panel.configPresetDialogMode === "rename") {
            result = voiceController.renameVoiceConfigPreset(
                panel.selectedConfigPresetId,
                String(presetNameInput.text || ""))
        } else {
            result = voiceController.removeVoiceConfigPreset(
                panel.selectedConfigPresetId)
        }
        if (result && result.ok) {
            if (panel.configPresetDialogMode === "delete") {
                panel.selectedConfigPresetId = ""
                panel.selectedConfigPresetName = ""
            } else if (panel.configPresetDialogMode === "rename") {
                panel.selectedConfigPresetName = String(
                    presetNameInput.text || "").trim()
            }
            configPresetDialog.close()
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: VfTheme.dp(10)
        }
        spacing: VfTheme.dp(8)

        RowLayout {
            objectName: "voiceConfigHeader"
            Layout.fillWidth: true
            spacing: VfTheme.dp(7)

            VfAppIcon {
                name: "voice-config"
                size: VfTheme.dp(28)
                framed: true
                frameColor: VfTheme.violetFill
                color: VfTheme.violet
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Text {
                    Layout.fillWidth: true
                    text: panel.workflowTitle()
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: panel.workflowHint()
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    elide: Text.ElideRight
                }
            }
        }

        Rectangle {
            objectName: "voiceProviderConfigBlock"
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: VfTheme.dp(10)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.borderSoft

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: VfTheme.dp(8)
                }
                spacing: VfTheme.dp(7)

        GridLayout {
            objectName: "voiceProviderList"
            Layout.fillWidth: true
            columns: 2
            rowSpacing: VfTheme.dp(5)
            columnSpacing: VfTheme.dp(5)

            Repeater {
                model: panel.providerChoices || []
                delegate: Rectangle {
                    id: providerCard
                    required property var modelData

                    readonly property string providerValue:
                        String(providerCard.modelData.value || "gemini")
                    readonly property bool selected:
                        providerCard.providerValue === panel.provider
                    readonly property bool blocked:
                        providerCard.modelData.disabled === true

                    Layout.fillWidth: true
                    implicitHeight: VfTheme.dp(52)
                    radius: VfTheme.dp(8)
                    color: providerCard.selected
                        ? VfTheme.violetFill : VfTheme.surface
                    border.width: providerCard.selected ? 2 : 1
                    border.color: providerCard.selected
                        ? panel.providerAccent(providerCard.providerValue)
                        : VfTheme.borderSoft
                    opacity: providerCard.blocked ? 0.55 : 1

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: VfTheme.dp(9)
                            rightMargin: VfTheme.dp(9)
                        }
                        spacing: VfTheme.dp(8)
                        VfAppIcon {
                            name: panel.providerIcon(providerCard.providerValue)
                            size: VfTheme.dp(22)
                            framed: false
                            color: panel.providerAccent(providerCard.providerValue)
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                Layout.fillWidth: true
                                text: String(providerCard.modelData.label
                                             || providerCard.providerValue)
                                color: providerCard.selected
                                    ? panel.providerAccent(providerCard.providerValue)
                                    : VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: providerCard.selected
                                    ? VfTheme.weightStrong : VfTheme.weightRegular
                                elide: Text.ElideRight
                            }
                            Text {
                                text: panel.providerKind(providerCard.providerValue)
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(9)
                                font.letterSpacing: VfTheme.dp(0.4)
                            }
                        }
                        Rectangle {
                            implicitWidth: VfTheme.dp(8)
                            implicitHeight: implicitWidth
                            radius: implicitWidth / 2
                            color: providerCard.blocked
                                ? VfTheme.redBorder
                                : String(providerCard.modelData.warning || "").length > 0
                                    ? VfTheme.amber : "#10B981"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: !providerCard.blocked
                        cursorShape: enabled
                            ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                        onClicked: panel.providerSelected(
                            providerCard.providerValue)
                    }
                }
            }
        }

        ColumnLayout {
            objectName: "voiceSavedConfigLibrary"
            Layout.fillWidth: true
            spacing: VfTheme.dp(5)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)
                Text {
                    Layout.fillWidth: true
                    text: "CẤU HÌNH ĐÃ LƯU · "
                        + String(voiceController.voiceConfigPresetCount || 0)
                    color: panel.accent
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                }
                VfButton {
                    text: "Lưu mới"
                    actionId: "save"
                    compact: true
                    minWidth: VfTheme.dp(76)
                    enabled: !voiceController.voiceConfigPresetBusy
                    onClicked: panel.openPresetDialog("save", "", "")
                }
            }

            ListView {
                id: configPresetList
                objectName: "voiceSavedConfigList"
                Layout.fillWidth: true
                implicitHeight: VfTheme.dp(47)
                orientation: ListView.Horizontal
                spacing: VfTheme.dp(5)
                clip: true
                reuseItems: true
                model: voiceController.voiceConfigPresetModel

                delegate: Rectangle {
                    id: configPresetCard
                    required property var modelData
                    readonly property string presetId:
                        String(configPresetCard.modelData.id || "")
                    readonly property bool selected:
                        presetId === panel.selectedConfigPresetId
                    width: Math.min(VfTheme.dp(150), configPresetList.width - VfTheme.dp(2))
                    height: configPresetList.height
                    radius: VfTheme.dp(7)
                    color: selected ? VfTheme.violetFill : VfTheme.surface
                    border.width: selected ? 2 : 1
                    border.color: selected ? panel.accent : VfTheme.borderSoft

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: VfTheme.dp(7)
                            rightMargin: VfTheme.dp(7)
                        }
                        spacing: VfTheme.dp(6)
                        VfAppIcon {
                            name: panel.providerIcon(String(
                                configPresetCard.modelData.provider || "gemini"))
                            size: VfTheme.dp(16)
                            color: panel.providerAccent(String(
                                configPresetCard.modelData.provider || "gemini"))
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                Layout.fillWidth: true
                                text: String(configPresetCard.modelData.name || "Cấu hình")
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                font.weight: VfTheme.weightStrong
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: String(configPresetCard.modelData.provider_label || "")
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(9)
                                elide: Text.ElideRight
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: !voiceController.voiceConfigPresetBusy
                        onClicked: {
                            panel.selectedConfigPresetId = configPresetCard.presetId
                            panel.selectedConfigPresetName = String(
                                configPresetCard.modelData.name || "")
                            panel.configPresetSelected(configPresetCard.presetId)
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: voiceController.voiceConfigPresetCount === 0
                    text: voiceController.voiceConfigPresetBusy
                        ? "Đang tải cấu hình…" : "Chưa có cấu hình đã lưu"
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: panel.selectedConfigPresetId.length > 0
                spacing: VfTheme.dp(5)
                Item { Layout.fillWidth: true }
                VfButton {
                    text: "Cập nhật"
                    compact: true
                    minWidth: VfTheme.dp(66)
                    enabled: !voiceController.voiceConfigPresetBusy
                    onClicked: voiceController.updateVoiceConfigPreset(
                        panel.selectedConfigPresetId, panel.provider,
                        panel.options || ({}))
                }
                VfButton {
                    text: "Đổi tên"
                    compact: true
                    minWidth: VfTheme.dp(70)
                    enabled: !voiceController.voiceConfigPresetBusy
                    onClicked: panel.openPresetDialog(
                        "rename", panel.selectedConfigPresetId,
                        panel.selectedConfigPresetName)
                }
                VfButton {
                    text: "Xóa"
                    compact: true
                    minWidth: VfTheme.dp(48)
                    enabled: !voiceController.voiceConfigPresetBusy
                    onClicked: panel.openPresetDialog(
                        "delete", panel.selectedConfigPresetId,
                        panel.selectedConfigPresetName)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(6)
            VfAppIcon {
                name: panel.providerIcon(panel.provider)
                size: VfTheme.dp(18)
                color: panel.accent
            }
            Text {
                Layout.fillWidth: true
                text: panel.providerDisplay
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
                font.weight: VfTheme.weightStrong
                elide: Text.ElideRight
            }
            Text {
                text: panel.draftDirty ? "Chưa lưu" : "Đã lưu"
                color: panel.draftDirty ? "#B45309" : VfTheme.greenText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.weight: VfTheme.weightStrong
            }
        }

        ScrollView {
            id: sidebarScroll
            objectName: "voiceProviderSettings"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: sidebarScroll.availableWidth
                spacing: VfTheme.dp(7)

                VfSelectField {
                    visible: panel.provider === "gemini"
                    Layout.fillWidth: true
                    label: panel.modeLabel
                    options: panel.modeOptions
                    value: panel.modeValue
                    accent: panel.accent
                    onSelected: value => panel.modeSelected(String(value))
                }

                Flow {
                    visible: panel.provider !== "gemini"
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(5)

                    Repeater {
                        model: panel.modeOptions || []
                        delegate: ModeChip {
                            required property var modelData
                            text: String(modelData.label || modelData.value || "")
                            selected: String(modelData.value || "")
                                === panel.modeValue
                            accent: panel.accent
                            onClicked: panel.modeSelected(
                                String(modelData.value || ""))
                        }
                    }
                }

                VfSelectField {
                    visible: !(panel.provider === "omnivoice"
                             && panel.modeValue !== "design"
                             && panel.modeValue !== "profile")
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

                Text {
                    objectName: "voiceGeminiDirector"
                    visible: panel.provider === "gemini"
                    Layout.fillWidth: true
                    Layout.topMargin: VfTheme.dp(3)
                    text: "ĐẠO DIỄN GIỌNG"
                    color: panel.accent
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    font.weight: VfTheme.weightStrong
                    font.letterSpacing: VfTheme.dp(0.4)
                }

                GridLayout {
                    objectName: "voiceGeminiSpeakerControls"
                    visible: panel.provider === "gemini"
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: VfTheme.dp(5)
                    columnSpacing: VfTheme.dp(6)

                    VfSelectField {
                        Layout.fillWidth: true
                        Layout.preferredWidth: VfTheme.dp(145)
                        label: "Người nói"
                        options: [
                            { label: "1 người", value: "mono" },
                            { label: "2 người", value: "dialogue" }
                        ]
                        value: Boolean(panel.options.dialogue_enabled)
                            ? "dialogue" : "mono"
                        accent: "#0891B2"
                        onSelected: value => panel.setGeminiDialogue(value)
                    }
                    VfSelectField {
                        Layout.fillWidth: true
                        Layout.preferredWidth: VfTheme.dp(145)
                        label: "Style"
                        options: voiceController.directorStyles
                        value: panel.geminiSpeakerValue(0, "style", "")
                        accent: "#10B981"
                        onSelected: value => panel.patchGeminiSpeaker(
                            0, "style", value)
                    }
                    VfSelectField {
                        Layout.fillWidth: true
                        Layout.preferredWidth: VfTheme.dp(145)
                        label: "Nhịp"
                        options: voiceController.directorPaces
                        value: panel.geminiSpeakerValue(0, "pace", "")
                        accent: "#F59E0B"
                        onSelected: value => panel.patchGeminiSpeaker(
                            0, "pace", value)
                    }
                    VfSelectField {
                        Layout.fillWidth: true
                        Layout.preferredWidth: VfTheme.dp(145)
                        label: "Chất giọng"
                        options: voiceController.directorAccents
                        value: panel.geminiSpeakerValue(0, "accent", "")
                        accent: "#EC4899"
                        onSelected: value => panel.patchGeminiSpeaker(
                            0, "accent", value)
                    }
                }

                Text {
                    visible: panel.provider === "gemini"
                        && Boolean(panel.options.dialogue_enabled)
                    Layout.fillWidth: true
                    text: "NGƯỜI NÓI 2"
                    color: VfTheme.violet
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    font.weight: VfTheme.weightStrong
                }
                GridLayout {
                    visible: panel.provider === "gemini"
                        && Boolean(panel.options.dialogue_enabled)
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: VfTheme.dp(5)
                    columnSpacing: VfTheme.dp(6)

                    VfSelectField {
                        Layout.fillWidth: true
                        Layout.preferredWidth: VfTheme.dp(145)
                        label: "Giọng 2"
                        options: voiceController.voices
                        value: panel.geminiSpeakerValue(1, "voice", "Puck")
                        accent: VfTheme.violet
                        onSelected: value => panel.patchGeminiSpeaker(
                            1, "voice", value)
                    }
                    VfSelectField {
                        Layout.fillWidth: true
                        Layout.preferredWidth: VfTheme.dp(145)
                        label: "Style 2"
                        options: voiceController.directorStyles
                        value: panel.geminiSpeakerValue(1, "style", "")
                        accent: "#10B981"
                        onSelected: value => panel.patchGeminiSpeaker(
                            1, "style", value)
                    }
                    VfSelectField {
                        Layout.fillWidth: true
                        Layout.preferredWidth: VfTheme.dp(145)
                        label: "Nhịp 2"
                        options: voiceController.directorPaces
                        value: panel.geminiSpeakerValue(1, "pace", "")
                        accent: "#F59E0B"
                        onSelected: value => panel.patchGeminiSpeaker(
                            1, "pace", value)
                    }
                    VfSelectField {
                        Layout.fillWidth: true
                        Layout.preferredWidth: VfTheme.dp(145)
                        label: "Chất giọng 2"
                        options: voiceController.directorAccents
                        value: panel.geminiSpeakerValue(1, "accent", "")
                        accent: "#EC4899"
                        onSelected: value => panel.patchGeminiSpeaker(
                            1, "accent", value)
                    }
                }
                VfTextField {
                    visible: panel.provider === "gemini"
                        && Boolean(panel.options.dialogue_enabled)
                    Layout.fillWidth: true
                    label: "Audio profile giọng 2"
                    value: panel.geminiSpeakerValue(
                        1, "audio_profile", "")
                    placeholder: "Mô tả riêng cho người nói thứ hai"
                    accent: VfTheme.violet
                    onCommitted: value => panel.patchGeminiSpeaker(
                        1, "audio_profile", value)
                }

                Rectangle {
                    visible: panel.provider === "omnivoice"
                    Layout.fillWidth: true
                    implicitHeight: omniModeHelp.implicitHeight + VfTheme.dp(16)
                    radius: VfTheme.dp(8)
                    color: VfTheme.violetFill
                    border.color: VfTheme.violetBorderSoft
                    Text {
                        id: omniModeHelp
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            margins: VfTheme.dp(8)
                        }
                        text: {
                            if (panel.modeValue === "design")
                                return "Recipe chỉ tạo tone mới. Seed trống = mỗi video một giọng mới."
                            if (panel.modeValue === "profile")
                                return "Chọn một giọng đã duyệt trong thư viện dùng chung."
                            if (panel.modeValue === "clone")
                                return "Dùng audio thật làm mốc giọng; recipe và profile đã được bỏ."
                            return "Mỗi video lấy một giọng mới; chunk đầu giữ giọng cho toàn video."
                        }
                        wrapMode: Text.Wrap
                        color: VfTheme.violetText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                    }
                }

                Rectangle {
                    visible: panel.provider === "moss"
                    Layout.fillWidth: true
                    implicitHeight: mossModeHelp.implicitHeight + VfTheme.dp(16)
                    radius: VfTheme.dp(8)
                    color: Qt.rgba(0.05, 0.58, 0.53, 0.09)
                    border.color: Qt.rgba(0.05, 0.58, 0.53, 0.28)
                    Text {
                        id: mossModeHelp
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            margins: VfTheme.dp(8)
                        }
                        text: panel.mossNano
                            ? "Nano ONNX chạy CPU, có giọng dựng sẵn và clone audio. Văn bản dài được chia nội bộ nhưng giữ cùng voice/seed."
                            : panel.mossHybrid
                                ? "Hybrid 12 GB: model 4B chạy CUDA, codec chạy CPU/BF16. Đủ tính năng Local v1.5; encode/decode sẽ chậm hơn GPU đầy đủ."
                                : "Local 4B GPU đầy đủ đặt model và codec trên CUDA. Hỗ trợ direct, clone, nối tiếp, [pause], Pinyin và IPA."
                        wrapMode: Text.Wrap
                        color: "#0F766E"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                    }
                }

                // Gemini: categorical choices above, natural-language direction
                // below. Text is committed only on editingFinished.
                VfTextField {
                    visible: panel.provider === "gemini"
                    Layout.fillWidth: true
                    label: "Audio profile"
                    value: String(panel.options.gemini_audio_profile
                                  || panel.options.audio_profile || "")
                    placeholder: "Người dẫn chuyện ấm, gần gũi"
                    accent: panel.accent
                    onCommitted: value => panel.optionChanged(
                        "gemini_audio_profile", value)
                }
                VfTextField {
                    visible: panel.provider === "gemini"
                    Layout.fillWidth: true
                    label: "Chỉ dẫn cách đọc"
                    value: String(panel.options.gemini_director_notes
                                  || panel.options.director_notes || "")
                    placeholder: "Rõ chữ, nhịp vừa, kết câu tự nhiên"
                    accent: panel.accent
                    onCommitted: value => panel.optionChanged(
                        "gemini_director_notes", value)
                }
                VfTextField {
                    visible: panel.provider === "gemini"
                    Layout.fillWidth: true
                    label: "Bối cảnh"
                    value: String(panel.options.scene || "")
                    placeholder: "Phòng thu yên tĩnh, không gian gần…"
                    accent: "#0891B2"
                    onCommitted: value => panel.optionChanged("scene", value)
                }
                VfTextField {
                    visible: panel.provider === "gemini"
                    Layout.fillWidth: true
                    label: "Ngữ cảnh mẫu"
                    value: String(panel.options.sample_context || "")
                    placeholder: "Nhịp đều, giọng ấm, trấn an…"
                    accent: "#0891B2"
                    onCommitted: value => panel.optionChanged(
                        "sample_context", value)
                }

                // OmniVoice exposes only real continuous backend values as
                // sliders. Quality/effects remain categorical fields.
                DraftSlider {
                    visible: panel.provider === "omnivoice"
                    Layout.fillWidth: true
                    label: "Tốc độ"
                    from: 0.75
                    to: 1.5
                    stepSize: 0.05
                    value: panel.numberValue(panel.options.omni_speed, 1)
                    accent: VfTheme.violet
                    format: value => value.toFixed(2) + "×"
                    onCommitted: value => panel.optionChanged(
                        "omni_speed", value.toFixed(2))
                }
                DraftSlider {
                    visible: panel.provider === "omnivoice"
                    Layout.fillWidth: true
                    label: "Độ bám chỉ dẫn"
                    from: 1
                    to: 5
                    stepSize: 0.1
                    value: panel.numberValue(panel.options.omni_guidance, 2)
                    accent: VfTheme.cyan
                    format: value => value.toFixed(1)
                    onCommitted: value => panel.optionChanged(
                        "omni_guidance", value.toFixed(1))
                }
                VfSelectField {
                    visible: panel.provider === "omnivoice"
                    Layout.fillWidth: true
                    label: "Chất lượng"
                    options: [
                        { label: "Nghe thử · 16", value: "16" },
                        { label: "Narration · 32", value: "32" },
                        { label: "Tối đa · 64", value: "64" }
                    ]
                    value: String(panel.options.omni_num_step || "32")
                    accent: VfTheme.cyan
                    onSelected: value => panel.optionChanged(
                        "omni_num_step", String(value))
                }
                VfSelectField {
                    visible: panel.provider === "omnivoice"
                    Layout.fillWidth: true
                    label: "Hậu kỳ"
                    options: [
                        { label: "Broadcast", value: "broadcast" },
                        { label: "Podcast", value: "podcast" },
                        { label: "Cinematic", value: "cinematic" },
                        { label: "Warm", value: "warm" },
                        { label: "Raw", value: "raw" }
                    ]
                    value: String(panel.options.omni_effect_preset || "broadcast")
                    accent: "#10B981"
                    onSelected: value => panel.optionChanged(
                        "omni_effect_preset", String(value))
                }
                VfTextField {
                    visible: panel.provider === "omnivoice"
                        && (panel.modeValue === "new"
                            || panel.modeValue === "design")
                    Layout.fillWidth: true
                    label: "Seed (tùy chọn)"
                    value: String(panel.options.omni_seed || "")
                    placeholder: "Trống = mỗi video một giọng mới"
                    accent: VfTheme.violet
                    onCommitted: value => panel.optionChanged(
                        "omni_seed", value)
                }

                VfSelectField {
                    visible: panel.provider === "moss" && panel.mossNano
                        && panel.modeValue === "direct"
                    Layout.fillWidth: true
                    label: "Giọng Nano"
                    options: voiceController.listEngineVoices("moss_nano")
                    value: String(panel.options.moss_nano_voice || "Ava")
                    accent: "#0D9488"
                    onSelected: value => panel.optionChanged(
                        "moss_nano_voice", String(value))
                }
                VfSelectField {
                    visible: panel.provider === "moss" && panel.mossNano
                    Layout.fillWidth: true
                    label: "Cách lấy mẫu"
                    options: [
                        { label: "Đầy đủ · tự nhiên", value: "full" },
                        { label: "Cố định · ổn định", value: "fixed" },
                        { label: "Greedy · nhanh", value: "greedy" }
                    ]
                    value: String(panel.options.moss_nano_sample_mode || "full")
                    accent: "#0D9488"
                    onSelected: value => panel.optionChanged(
                        "moss_nano_sample_mode", String(value))
                }
                DraftSlider {
                    visible: panel.provider === "moss" && panel.mossNano
                    Layout.fillWidth: true
                    label: "Giới hạn frame"
                    from: 64
                    to: 1500
                    stepSize: 16
                    value: panel.numberValue(
                        panel.options.moss_nano_max_frames, 375)
                    accent: "#0D9488"
                    format: value => Math.round(value) + ""
                    onCommitted: value => panel.optionChanged(
                        "moss_nano_max_frames", Math.round(value) + "")
                }
                DraftSlider {
                    visible: panel.provider === "moss" && panel.mossNano
                    Layout.fillWidth: true
                    label: "CPU threads"
                    from: 1
                    to: 16
                    stepSize: 1
                    value: panel.numberValue(
                        panel.options.moss_nano_cpu_threads, 4)
                    accent: VfTheme.cyan
                    format: value => Math.round(value) + ""
                    onCommitted: value => panel.optionChanged(
                        "moss_nano_cpu_threads", Math.round(value) + "")
                }
                VfSelectField {
                    visible: panel.provider === "moss" && panel.mossNano
                    Layout.fillWidth: true
                    label: "Chuẩn hóa văn bản"
                    options: [
                        { label: "Bật", value: "1" },
                        { label: "Tắt", value: "0" }
                    ]
                    value: String(
                        panel.options.moss_nano_text_normalization || "1")
                    accent: VfTheme.cyan
                    onSelected: value => panel.optionChanged(
                        "moss_nano_text_normalization", String(value))
                }
                VfTextField {
                    visible: panel.provider === "moss"
                    Layout.fillWidth: true
                    label: "Seed (tùy chọn)"
                    value: String(panel.options.moss_seed || "")
                    placeholder: "Trống = seed mới cho mỗi lần tạo"
                    accent: "#0D9488"
                    onCommitted: value => panel.optionChanged(
                        "moss_seed", value)
                }

                // MOSS 4B sampling controls are continuous and therefore suit
                // the compact release-commit sliders.
                DraftSlider {
                    visible: panel.provider === "moss" && !panel.mossNano
                    Layout.fillWidth: true
                    label: "Temperature"
                    from: 0.1
                    to: 3
                    stepSize: 0.1
                    value: panel.numberValue(panel.options.moss_temperature, 1.7)
                    accent: "#EC4899"
                    format: value => value.toFixed(1)
                    onCommitted: value => panel.optionChanged(
                        "moss_temperature", value.toFixed(1))
                }
                DraftSlider {
                    visible: panel.provider === "moss" && !panel.mossNano
                    Layout.fillWidth: true
                    label: "Top P"
                    from: 0.1
                    to: 1
                    stepSize: 0.05
                    value: panel.numberValue(panel.options.moss_top_p, 0.8)
                    accent: "#0D9488"
                    format: value => value.toFixed(2)
                    onCommitted: value => panel.optionChanged(
                        "moss_top_p", value.toFixed(2))
                }
                VfTextField {
                    visible: panel.provider === "moss" && !panel.mossNano
                    Layout.fillWidth: true
                    label: "Thời lượng mong muốn (giây)"
                    value: String(panel.options.moss_duration || "")
                    placeholder: "Trống = tự động"
                    accent: "#0D9488"
                    onCommitted: value => panel.optionChanged(
                        "moss_duration", value)
                }

                VfSelectField {
                    visible: panel.provider === "vieneu"
                    Layout.fillWidth: true
                    label: "Khử ồn audio mẫu"
                    options: [
                        { label: "Bật", value: "1" },
                        { label: "Tắt", value: "0" }
                    ]
                    value: String(panel.options.vieneu_denoise || "1")
                    accent: VfTheme.amber
                    onSelected: value => panel.optionChanged(
                        "vieneu_denoise", String(value))
                }

                VfValueField {
                    visible: (panel.provider === "omnivoice"
                              && panel.modeValue === "clone")
                        || (panel.provider === "moss"
                            && panel.modeValue !== "direct")
                        || panel.provider === "vieneu"
                    Layout.fillWidth: true
                    label: "Audio mẫu"
                    value: panel.fileName(
                        panel.provider === "omnivoice"
                            ? panel.options.omni_ref_audio
                            : panel.provider === "moss"
                                ? panel.options.moss_ref_audio
                                : panel.options.vieneu_ref_audio)
                    placeholder: "Chưa chọn · WAV/MP3/M4A/FLAC"
                    actionText: "Chọn"
                    accent: "#EC4899"
                    onActivated: {
                        var key = panel.provider === "omnivoice"
                            ? "omni_ref_audio"
                            : panel.provider === "moss"
                                ? "moss_ref_audio" : "vieneu_ref_audio"
                        panel.chooseAudio("Chọn audio mẫu", key)
                    }
                }

                VfTextField {
                    visible: panel.provider === "omnivoice"
                        && panel.modeValue === "clone"
                        && String(panel.options.omni_ref_audio || "").length > 0
                    Layout.fillWidth: true
                    label: "Transcript audio mẫu"
                    value: String(panel.options.omni_ref_text || "")
                    placeholder: "Gõ đúng câu nói trong file mẫu"
                    accent: "#EC4899"
                    onCommitted: value => panel.optionChanged(
                        "omni_ref_text", value)
                }

                VfTextField {
                    visible: panel.provider === "moss"
                        && (panel.modeValue === "continuation"
                            || panel.modeValue === "continuation_clone")
                    Layout.fillWidth: true
                    label: "Transcript audio mẫu"
                    value: String(panel.options.moss_prompt_text || "")
                    placeholder: "Transcript chính xác để nối tiếp"
                    accent: "#EC4899"
                    onCommitted: value => panel.optionChanged(
                        "moss_prompt_text", value)
                }

                ColumnLayout {
                    visible: panel.provider === "omnivoice"
                        && (panel.modeValue === "new"
                            || panel.modeValue === "design"
                            || panel.modeValue === "clone")
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(6)

                    Text {
                        Layout.fillWidth: true
                        text: panel.modeValue === "clone"
                            ? "CLONE · THỬ VÀ DUYỆT"
                            : "TẠO VÀ DUYỆT GIỌNG"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                        font.weight: VfTheme.weightStrong
                    }
                    Text {
                        Layout.fillWidth: true
                        text: panel.modeValue === "clone"
                            ? "Audio nguồn tạo một mẫu đọc mới. Nghe kết quả, đặt tên rồi mới lưu thành voice dùng chung."
                            : "Mẫu dùng đúng ngôn ngữ đang chọn, hậu kỳ raw. Chỉ lưu sau khi bạn nghe và đặt tên."
                        wrapMode: Text.Wrap
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                    }
                    Text {
                        visible: panel.modeValue === "clone"
                            && !panel.omniCloneSourceReady
                        Layout.fillWidth: true
                        text: "Chọn audio mẫu ở trên để bật tạo thử voice clone."
                        wrapMode: Text.Wrap
                        color: VfTheme.amberText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(5)
                        VfButton {
                            Layout.fillWidth: true
                            text: voiceController.omniProfileBusy
                                ? "Đang tạo…" : "Tạo thử · 32"
                            enabled: !voiceController.omniProfileBusy
                                && !panel.hardwareBlocked
                                && panel.omniCloneSourceReady
                            onClicked: voiceController.previewOmniCandidate(
                                panel.options, i18n.locale, 32)
                        }
                        VfButton {
                            Layout.fillWidth: true
                            text: "Tạo thử · 64"
                            enabled: !voiceController.omniProfileBusy
                                && !panel.hardwareBlocked
                                && panel.omniCloneSourceReady
                            onClicked: voiceController.previewOmniCandidate(
                                panel.options, i18n.locale, 64)
                        }
                    }
                    Rectangle {
                        visible: Boolean(
                            (voiceController.omniCandidate || {}).ok)
                        Layout.fillWidth: true
                        implicitHeight: candidateColumn.implicitHeight
                            + VfTheme.dp(14)
                        radius: VfTheme.dp(8)
                        color: VfTheme.greenFill
                        border.color: VfTheme.greenBorderSoft
                        ColumnLayout {
                            id: candidateColumn
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                margins: VfTheme.dp(7)
                            }
                            spacing: VfTheme.dp(5)
                            Text {
                                Layout.fillWidth: true
                                text: "✓ Mẫu chưa lưu · "
                                    + String((voiceController.omniCandidate || {}).steps || "32")
                                    + " steps · raw"
                                color: VfTheme.greenText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                font.weight: VfTheme.weightStrong
                            }
                            TextField {
                                id: approvedProfileName
                                Layout.fillWidth: true
                                placeholderText: "Đặt tên giọng đã duyệt…"
                                selectByMouse: true
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                background: Rectangle {
                                    radius: VfTheme.dp(7)
                                    color: VfTheme.surface
                                    border.color: parent.activeFocus
                                        ? VfTheme.primary : VfTheme.borderBox
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                VfButton {
                                    Layout.fillWidth: true
                                    text: "Nghe lại"
                                    enabled: !voiceController.omniProfileBusy
                                    onClicked: voiceController.startPlayback(
                                        String((voiceController.omniCandidate || {}).audio_path || ""),
                                        "Mẫu OmniVoice chưa lưu")
                                }
                                VfButton {
                                    Layout.fillWidth: true
                                    text: "Lưu thành giọng"
                                    tone: "accent"
                                    enabled: !voiceController.omniProfileBusy
                                        && approvedProfileName.text.trim().length > 0
                                    onClicked: voiceController.approveOmniCandidate(
                                        approvedProfileName.text.trim())
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    visible: panel.provider === "omnivoice"
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(5)

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: "GIỌNG ĐÃ LƯU"
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            font.weight: VfTheme.weightStrong
                        }
                        VfButton {
                            text: "Đồng bộ"
                            enabled: !voiceController.omniProfileBusy
                            onClicked: voiceController.syncOmniProfiles("")
                        }
                    }
                    Text {
                        visible: (voiceController.omniProfileOptions || []).length === 0
                        Layout.fillWidth: true
                        text: voiceController.omniProfileBusy
                            ? "Đang đồng bộ thư viện OmniVoice…"
                            : "Chưa có giọng đã duyệt. Tạo thử, nghe và lưu ở phía trên."
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                    }
                    Repeater {
                        model: voiceController.omniProfileModel
                        delegate: Rectangle {
                            id: profileRow
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: VfTheme.dp(68)
                            radius: VfTheme.dp(8)
                            color: String(profileRow.modelData.value || "")
                                === String(panel.options.omni_voice || "")
                                ? VfTheme.violetFill : VfTheme.surface
                            border.color: String(profileRow.modelData.value || "")
                                === String(panel.options.omni_voice || "")
                                ? VfTheme.violet : VfTheme.borderSoft

                            ColumnLayout {
                                anchors {
                                    fill: parent
                                    margins: VfTheme.dp(6)
                                }
                                spacing: VfTheme.dp(4)
                                TextField {
                                    id: profileNameField
                                    Layout.fillWidth: true
                                    text: String(profileRow.modelData.name || "Giọng")
                                    selectByMouse: true
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    onEditingFinished: {
                                        var nextName = text.trim()
                                        if (nextName.length > 0
                                                && nextName !== String(
                                                    profileRow.modelData.name || ""))
                                            voiceController.renameOmniProfile(
                                                String(profileRow.modelData.id || ""),
                                                nextName)
                                    }
                                    background: Rectangle {
                                        radius: VfTheme.dp(6)
                                        color: "transparent"
                                        border.color: parent.activeFocus
                                            ? VfTheme.primary : "transparent"
                                    }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: VfTheme.dp(4)
                                    VfButton {
                                        Layout.fillWidth: true
                                        text: "Chọn"
                                        enabled: !voiceController.omniProfileBusy
                                        onClicked: {
                                            panel.modeSelected("profile")
                                            panel.voiceSelected(String(
                                                profileRow.modelData.value || ""))
                                        }
                                    }
                                    VfButton {
                                        Layout.fillWidth: true
                                        text: "Nghe"
                                        enabled: !voiceController.omniProfileBusy
                                        onClicked: voiceController.previewOmniProfile(
                                            String(profileRow.modelData.id || ""))
                                    }
                                    VfButton {
                                        text: "Xóa"
                                        enabled: !voiceController.omniProfileBusy
                                        onClicked: voiceController.removeOmniProfile(
                                            String(profileRow.modelData.id || ""))
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: VfTheme.dp(2)
                }
            }
        }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(5)
            VfButton {
                Layout.fillWidth: true
                text: "Nghe thử"
                actionId: "voice.preview"
                enabled: !panel.busy && !panel.hardwareBlocked
                onClicked: panel.previewRequested()
            }
            VfButton {
                Layout.fillWidth: true
                text: panel.busy ? "Đang áp dụng…" : "Áp dụng"
                actionId: "voice.config.apply"
                tone: "accent"
                enabled: panel.draftDirty && !panel.busy
                onClicked: panel.saveRequested()
            }
            VfButton {
                text: "Đặt lại thay đổi"
                actionId: "voice.config.reset"
                compact: true
                enabled: panel.draftDirty && !panel.busy
                onClicked: panel.resetRequested()
            }
        }
    }

    Popup {
        id: configPresetDialog
        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: VfTheme.dp(360)
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        padding: VfTheme.dp(16)

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.borderBox
        }
        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)
            Text {
                Layout.fillWidth: true
                text: panel.configPresetDialogMode === "save"
                    ? "LƯU CẤU HÌNH MỚI"
                    : panel.configPresetDialogMode === "rename"
                        ? "ĐỔI TÊN CẤU HÌNH" : "XÓA CẤU HÌNH"
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
                font.weight: VfTheme.weightStrong
            }
            Text {
                visible: panel.configPresetDialogMode === "delete"
                Layout.fillWidth: true
                text: "Xóa ‘" + panel.selectedConfigPresetName
                    + "’? Thao tác này không ảnh hưởng profile giọng."
                wrapMode: Text.Wrap
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
            }
            TextField {
                id: presetNameInput
                visible: panel.configPresetDialogMode !== "delete"
                Layout.fillWidth: true
                implicitHeight: VfTheme.controlHeight
                placeholderText: "Ví dụ: Quảng cáo nữ · Gemini"
                selectByMouse: true
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                onAccepted: panel.confirmPresetDialog()
                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: VfTheme.surfaceSoft
                    border.width: 1
                    border.color: presetNameInput.activeFocus
                        ? panel.accent : VfTheme.borderBox
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                VfButton {
                    text: "Hủy"
                    compact: true
                    onClicked: configPresetDialog.close()
                }
                VfButton {
                    text: panel.configPresetDialogMode === "delete"
                        ? "Xóa" : "Lưu"
                    tone: panel.configPresetDialogMode === "delete"
                        ? "danger" : "accent"
                    compact: true
                    enabled: !voiceController.voiceConfigPresetBusy
                        && (panel.configPresetDialogMode === "delete"
                            || String(presetNameInput.text || "").trim().length > 0)
                    onClicked: panel.confirmPresetDialog()
                }
            }
        }
    }

    component ModeChip: Rectangle {
        id: chip
        property string text: ""
        property bool selected: false
        property color accent: VfTheme.primary
        signal clicked()

        implicitWidth: chipText.implicitWidth + VfTheme.dp(22)
        implicitHeight: VfTheme.dp(30)
        radius: VfTheme.dp(8)
        color: selected ? accent : VfTheme.surface
        border.color: selected ? accent : VfTheme.borderBox
        Text {
            id: chipText
            anchors.centerIn: parent
            text: chip.text
            color: chip.selected ? "#FFFFFF" : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            font.weight: chip.selected
                ? VfTheme.weightStrong : VfTheme.weightRegular
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }
    }

    component DraftSlider: ColumnLayout {
        id: field
        property string label: ""
        property real from: 0
        property real to: 1
        property real stepSize: 0.1
        property real value: 0
        property color accent: VfTheme.primary
        property var format: (function(value) { return String(value) })
        signal committed(real value)

        spacing: 0

        Timer {
            id: sliderCommit
            interval: 140
            repeat: false
            onTriggered: field.committed(control.value)
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: field.label
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightStrong
            }
            Rectangle {
                implicitWidth: sliderValue.implicitWidth + VfTheme.dp(14)
                implicitHeight: VfTheme.dp(24)
                radius: VfTheme.dp(7)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderSoft
                Text {
                    id: sliderValue
                    anchors.centerIn: parent
                    text: field.format(control.value)
                    color: field.accent
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    font.weight: VfTheme.weightStrong
                }
            }
        }

        Slider {
            id: control
            Layout.fillWidth: true
            from: field.from
            to: field.to
            stepSize: field.stepSize
            snapMode: Slider.SnapAlways
            value: field.value
            onMoved: {
                if (!pressed)
                    sliderCommit.restart()
            }
            onPressedChanged: {
                if (!pressed) {
                    sliderCommit.stop()
                    field.committed(value)
                }
            }
            background: Rectangle {
                x: control.leftPadding
                y: control.topPadding + control.availableHeight / 2 - height / 2
                width: control.availableWidth
                height: VfTheme.dp(4)
                radius: height / 2
                color: VfTheme.borderSoft
                Rectangle {
                    width: control.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: field.accent
                }
            }
            handle: Rectangle {
                x: control.leftPadding + control.visualPosition
                    * (control.availableWidth - width)
                y: control.topPadding + control.availableHeight / 2 - height / 2
                implicitWidth: VfTheme.dp(16)
                implicitHeight: VfTheme.dp(16)
                radius: width / 2
                color: field.accent
                border.width: 3
                border.color: "#FFFFFF"
            }
        }
    }
}
