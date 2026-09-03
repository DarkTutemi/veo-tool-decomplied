import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

// Quick shared narration picker for Master / Clone / other narration callers.
// Voice creation and advanced engine tuning belong to Voice Studio; this dialog
// only selects an existing provider + voice and stores one shared snapshot.
Dialog {
    id: dialog
    parent: Overlay.overlay
    modal: true
    width: VfDialogMetrics.width(Overlay.overlay, 880, 48)
    height: dialogHeader.implicitHeight + bodyColumn.implicitHeight
        + dialogFooter.implicitHeight
    x: VfDialogMetrics.centerX(Overlay.overlay, width)
    y: VfDialogMetrics.centerY(Overlay.overlay, height)
    padding: 0
    closePolicy: Popup.CloseOnEscape

    property string contextLabel: ""
    property string selectedProvider: "gemini"
    property var draft: ({})
    property var providerStatus: ({})
    property var vieneuVoices: []
    property var vieneuStyles: []

    function copyObject(source) {
        return Object.assign({}, source || ({}))
    }

    function setDraft(key, value) {
        var next = copyObject(dialog.draft)
        next[key] = value
        dialog.draft = next
    }

    function providerFromRoute(route) {
        var value = String(route || "").toLowerCase()
        return ["omnivoice", "moss", "vieneu"].indexOf(value) >= 0
            ? value : "gemini"
    }

    function providerTitle() {
        if (dialog.selectedProvider === "omnivoice")
            return "Chọn profile OmniVoice"
        if (dialog.selectedProvider === "moss")
            return "Giọng MOSS-TTS hiện tại"
        if (dialog.selectedProvider === "vieneu")
            return "Chọn giọng VieNeu"
        return "Chọn giọng Gemini"
    }

    function providerHint() {
        if (dialog.selectedProvider === "omnivoice")
            return "Chọn một profile/recipe đã có. Tạo hoặc chỉnh giọng trong Voice Studio."
        if (dialog.selectedProvider === "moss")
            return "Popup dùng cấu hình giọng MOSS đã lưu trong Voice Studio."
        if (dialog.selectedProvider === "vieneu")
            return "Chọn nhanh giọng và cách đọc có sẵn."
        return "Gemini TTS luôn gọi trực tiếp qua AI Studio."
    }

    function mossModeLabel() {
        var mode = String(dialog.draft.moss_mode || "direct")
        if (mode === "clone")
            return "Voice clone"
        if (mode === "continuation")
            return "Nối tiếp audio"
        if (mode === "continuation_clone")
            return "Nối tiếp + voice clone"
        return "Giọng mặc định MOSS"
    }

    function refreshStatus() {
        dialog.providerStatus = dialog.selectedProvider === "gemini"
            ? ({ state: "ready", message: "AI Studio" })
            : voiceController.engineStatus(dialog.selectedProvider)
    }

    function openFor(context) {
        dialog.contextLabel = String(context || "")
        var opts = copyObject(voiceController.providerOptions || ({}))
        dialog.selectedProvider = providerFromRoute(opts.tts_route)

        // The shared picker intentionally owns no gateway choice. Gemini
        // narration selected here is always the direct AI Studio route.
        opts.gemini_route = "aistudio"

        var narratorValue = String(
            narratorController.selectedVoiceValue || "auto")
        opts.gemini_voice = narratorValue
        opts.voice_mode = narratorValue === "auto" ? "auto" : "manual"
        opts.voice = narratorValue === "auto" ? "" : narratorValue
        opts.voice2 = String(narratorController.voice2Value || "off")
        opts.emotion = String(narratorController.emotion || "")
        opts.omni_url = ""

        dialog.draft = opts
        dialog.vieneuVoices = voiceController.listEngineVoices("vieneu")
        dialog.vieneuStyles = voiceController.listEngineStyles("vieneu")
        dialog.refreshStatus()
        voiceController.refreshOmniProfiles("")
        dialog.open()
    }

    function selectProvider(provider) {
        dialog.selectedProvider = String(provider || "gemini")
        if (dialog.selectedProvider === "gemini")
            dialog.setDraft("gemini_route", "aistudio")
        dialog.refreshStatus()
    }

    function selectOmniRecipe(value) {
        var selected = String(value || "")
        var next = copyObject(dialog.draft)
        next.omni_recipe = selected
        next.omni_voice = ""
        next.omni_ref_audio = ""
        next.omni_ref_text = ""
        next.omni_mode = "design"
        dialog.draft = next
    }

    function selectOmniProfile(value) {
        var selected = String(value || "")
        var next = copyObject(dialog.draft)
        next.omni_recipe = ""
        next.omni_voice = selected
        next.omni_ref_audio = ""
        next.omni_ref_text = ""
        next.omni_mode = selected.length ? "profile" : "new"
        dialog.draft = next
    }

    header: VfDialogHeader {
        id: dialogHeader
        title: "Chọn giọng dẫn"
        subtitle: dialog.contextLabel.length
            ? "Dùng cho " + dialog.contextLabel
                + " · job mới sẽ giữ snapshot riêng"
            : "Dùng chung cho các job mới · mỗi job giữ snapshot riêng"
        iconName: "speaker-high-volume"
        onCloseClicked: dialog.close()
    }

    background: Rectangle {
        radius: VfTheme.dp(14)
        color: VfTheme.surface
        border.color: VfTheme.violetBorderSoft
        border.width: 1
    }

    contentItem: ColumnLayout {
        id: bodyColumn
        spacing: VfTheme.dp(12)

        Text {
            Layout.leftMargin: VfTheme.dp(16)
            Layout.rightMargin: VfTheme.dp(16)
            Layout.topMargin: VfTheme.dp(12)
            text: "1  ·  Nhà cung cấp"
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            font.weight: VfTheme.weightStrong
        }

        GridLayout {
            Layout.leftMargin: VfTheme.dp(16)
            Layout.rightMargin: VfTheme.dp(16)
            Layout.fillWidth: true
            columns: width >= VfTheme.dp(700) ? 4 : 2
            uniformCellWidths: true
            columnSpacing: VfTheme.dp(8)
            rowSpacing: VfTheme.dp(8)

            Repeater {
                model: voiceController.narrationProviderOptions // perf-lint: disable=R2 constant provider catalogue
                ProviderTab {
                    Layout.fillWidth: true
                    title: String(modelData.label || modelData.value || "")
                    summary: String(modelData.summary || "")
                    accent: String(modelData.accent || VfTheme.primary)
                    selected: dialog.selectedProvider
                        === String(modelData.value || "")
                    onClicked: dialog.selectProvider(
                        String(modelData.value || "gemini"))
                }
            }
        }

        Rectangle {
            Layout.leftMargin: VfTheme.dp(16)
            Layout.rightMargin: VfTheme.dp(16)
            Layout.fillWidth: true
            implicitHeight: quickColumn.implicitHeight + VfTheme.dp(22)
            radius: VfTheme.dp(11)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.borderBox

            ColumnLayout {
                id: quickColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: VfTheme.dp(11)
                spacing: VfTheme.dp(9)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(9)

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(1)
                        Text {
                            text: "2  ·  " + dialog.providerTitle()
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontBody
                            font.weight: Font.DemiBold
                        }
                        Text {
                            Layout.fillWidth: true
                            text: dialog.providerHint()
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideRight
                        }
                    }

                    StatusPill {
                        statusState: String(
                            dialog.providerStatus.state || "ready")
                        message: String(
                            dialog.providerStatus.message || "Sẵn sàng")
                    }
                }

                GridLayout {
                    visible: dialog.selectedProvider === "gemini"
                    Layout.fillWidth: true
                    columns: width >= VfTheme.dp(620) ? 2 : 1
                    uniformCellWidths: true
                    columnSpacing: VfTheme.dp(9)
                    rowSpacing: VfTheme.dp(7)

                    VfSelectField {
                        Layout.fillWidth: true
                        label: "Giọng dẫn truyện"
                        options: narratorController.voiceOptions
                        value: String(dialog.draft.gemini_voice || "auto")
                        accent: VfTheme.primary
                        onSelected: function(value) {
                            var voice = String(value || "auto")
                            dialog.setDraft("gemini_voice", voice)
                            dialog.setDraft(
                                "voice_mode",
                                voice === "auto" ? "auto" : "manual")
                            dialog.setDraft(
                                "voice", voice === "auto" ? "" : voice)
                        }
                    }

                    VfSelectField {
                        Layout.fillWidth: true
                        label: "Cảm xúc"
                        options: narratorController.emotionOptions
                        value: String(dialog.draft.emotion || "")
                        accent: "#EC4899"
                        onSelected: value => dialog.setDraft(
                            "emotion", String(value))
                    }
                }

                GridLayout {
                    visible: dialog.selectedProvider === "omnivoice"
                    Layout.fillWidth: true
                    columns: width >= VfTheme.dp(620) ? 2 : 1
                    uniformCellWidths: true
                    columnSpacing: VfTheme.dp(9)
                    rowSpacing: VfTheme.dp(7)
                    VfSelectField {
                        Layout.fillWidth: true
                        label: "Công thức tạo tone mới"
                        options: voiceController.omniRecipeOptions || []
                        value: String(dialog.draft.omni_recipe || "")
                        accent: VfTheme.violet
                        onSelected: value => dialog.selectOmniRecipe(String(value))
                    }
                    VfSelectField {
                        Layout.fillWidth: true
                        label: "Giọng đã lưu"
                        options: voiceController.omniProfileOptions || []
                        value: String(dialog.draft.omni_voice || "")
                        accent: "#10B981"
                        onSelected: value => dialog.selectOmniProfile(String(value))
                    }
                }

                GridLayout {
                    visible: dialog.selectedProvider === "vieneu"
                    Layout.fillWidth: true
                    columns: width >= VfTheme.dp(620) ? 2 : 1
                    uniformCellWidths: true
                    columnSpacing: VfTheme.dp(9)
                    rowSpacing: VfTheme.dp(7)

                    VfSelectField {
                        Layout.fillWidth: true
                        label: "Giọng"
                        options: dialog.vieneuVoices
                        value: String(dialog.draft.vieneu_voice || "")
                        accent: VfTheme.primary
                        onSelected: value => dialog.setDraft(
                            "vieneu_voice", String(value))
                    }
                    VfSelectField {
                        Layout.fillWidth: true
                        label: "Cách đọc"
                        options: dialog.vieneuStyles
                        value: String(dialog.draft.vieneu_style || "")
                        accent: "#10B981"
                        onSelected: value => dialog.setDraft(
                            "vieneu_style", String(value))
                    }
                }

                RowLayout {
                    visible: dialog.selectedProvider === "moss"
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(9)

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: VfTheme.dp(42)
                        radius: VfTheme.dp(8)
                        color: VfTheme.surface
                        border.color: VfTheme.borderBox

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(11)
                            anchors.rightMargin: VfTheme.dp(11)
                            spacing: VfTheme.dp(8)
                            Text {
                                text: "Cấu hình đang dùng"
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: dialog.mossModeLabel()
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: VfTheme.weightStrong
                            }
                        }
                    }
                }
            }
        }

        Text {
            Layout.leftMargin: VfTheme.dp(16)
            Layout.rightMargin: VfTheme.dp(16)
            Layout.bottomMargin: VfTheme.dp(10)
            Layout.fillWidth: true
            text: "Clone giọng, voice design và thông số nâng cao được quản lý riêng trong Voice Studio."
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            wrapMode: Text.WordWrap
        }
    }

    footer: Rectangle {
        id: dialogFooter
        implicitHeight: VfTheme.dp(58)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.borderSoft

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(14)
            anchors.rightMargin: VfTheme.dp(14)
            anchors.topMargin: VfTheme.dp(8)
            anchors.bottomMargin: VfTheme.dp(8)
            spacing: VfTheme.dp(8)

            VfButton {
                text: voiceController.narrationSelectionBusy
                    ? "Đang tải / tạo mẫu…" : "▶ Nghe thử"
                enabled: !voiceController.narrationSelectionBusy
                onClicked: voiceController.previewNarrationSelection(
                    dialog.selectedProvider, dialog.draft,
                    "Xin chào, đây là bản nghe thử giọng dẫn truyện của VeoFlow.")
            }
            Item { Layout.fillWidth: true }
            VfButton {
                text: "Hủy"
                enabled: !voiceController.narrationSelectionBusy
                onClicked: dialog.close()
            }
            VfButton {
                text: "Dùng giọng này"
                tone: "primary"
                enabled: !voiceController.narrationSelectionBusy
                onClicked: {
                    if (dialog.selectedProvider === "gemini")
                        dialog.setDraft("gemini_route", "aistudio")
                    voiceController.applyNarrationSelection(
                        dialog.selectedProvider, dialog.draft)
                    dialog.close()
                }
            }
        }
    }

    component ProviderTab: Rectangle {
        id: tab
        property string title: ""
        property string summary: ""
        property color accent: VfTheme.primary
        property bool selected: false
        signal clicked()
        implicitHeight: VfTheme.dp(58)
        radius: VfTheme.dp(10)
        color: selected
            ? Qt.rgba(accent.r, accent.g, accent.b, 0.13)
            : VfTheme.surfaceSoft
        border.color: selected ? accent : VfTheme.borderBox
        border.width: selected ? 2 : 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(10)
            anchors.rightMargin: VfTheme.dp(9)
            spacing: VfTheme.dp(7)

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(4)
                Layout.preferredHeight: VfTheme.dp(30)
                radius: VfTheme.dp(2)
                color: tab.accent
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(1)
                Text {
                    Layout.fillWidth: true
                    text: tab.title
                    color: tab.selected ? tab.accent : VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: tab.summary
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: tab.clicked()
        }
    }

    component StatusPill: Rectangle {
        id: status
        property string statusState: "ready"
        property string message: "Sẵn sàng"
        readonly property bool failed: statusState === "error"
            || statusState === "blocked"
        implicitWidth: Math.min(
            statusRow.implicitWidth + VfTheme.dp(18), VfTheme.dp(190))
        implicitHeight: VfTheme.dp(30)
        radius: VfTheme.dp(15)
        color: failed ? VfTheme.redFill : VfTheme.greenFill
        border.color: failed ? VfTheme.redBorderSoft : VfTheme.greenBorderSoft

        RowLayout {
            id: statusRow
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(9)
            anchors.rightMargin: VfTheme.dp(9)
            spacing: VfTheme.dp(5)
            Rectangle {
                Layout.preferredWidth: VfTheme.dp(7)
                Layout.preferredHeight: VfTheme.dp(7)
                radius: VfTheme.dp(4)
                color: status.failed ? VfTheme.redText : "#16A34A"
            }
            Text {
                Layout.fillWidth: true
                text: status.message
                color: status.failed
                    ? VfTheme.redText : VfTheme.greenText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.weight: VfTheme.weightStrong
                elide: Text.ElideRight
            }
        }
    }
}
