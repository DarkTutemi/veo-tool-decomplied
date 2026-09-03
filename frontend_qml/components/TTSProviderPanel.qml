import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

Item {
    id: root

    property string provider: "gemini"
    property string voice: voices.length > 0 ? String(voices[0].value) : "Kore"
    property string ttsModel: models.length > 0 ? String(models[0].value) : "gemini-2.5-flash-preview-tts"
    property string preset: ""
    property bool showPreview: true
    property bool showStyle: true
    property var voices: [{ label: "Kore", value: "Kore" }]
    property var models: [{ label: "Gemini 2.5 Flash Preview TTS", value: "gemini-2.5-flash-preview-tts" }]
    property var providers: [
        { label: "Gemini", value: "gemini" }
    ]
    property var presets: [{ label: "None", value: "" }]

    signal providerSelected(string provider)
    signal voiceSelected(string voice)
    signal modelSelected(string model)
    signal presetSelected(string preset)
    signal previewRequested(string voice)

    Layout.fillWidth: true
    implicitHeight: VfTheme.dp(30)

    component InlineLabel: Text {
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(11)
        font.weight: VfTheme.weightStrong
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    component InlineCombo: ComboBox {
        id: combo

        property var options: []
        property var selectedValue: ""
        property color accent: VfTheme.primary
        signal selected(var value)

        function optionIndex(searchValue) {
            var items = combo.options || []
            for (var i = 0; i < items.length; i++) {
                if (String(items[i].value) === String(searchValue))
                    return i
            }
            return items.length > 0 ? 0 : -1
        }

        Layout.preferredHeight: VfTheme.dp(28)
        Layout.minimumWidth: VfTheme.dp(100)
        model: options || []
        textRole: "label"
        valueRole: "value"
        currentIndex: optionIndex(selectedValue)
        enabled: (options || []).length > 0
        clip: true
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(11)
        onActivated: selected(combo.currentValue)

        contentItem: Text {
            leftPadding: VfTheme.dp(8)
            rightPadding: VfTheme.dp(20)
            text: combo.displayText
            color: combo.enabled ? VfTheme.text : VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        background: Rectangle {
            radius: VfTheme.dp(6)
            color: VfTheme.surface
            border.width: 1
            border.color: combo.activeFocus ? combo.accent : VfTheme.borderStrong
        }

        indicator: Text {
            x: combo.width - width - 8
            y: Math.round((combo.height - height) / 2)
            width: VfTheme.dp(10)
            height: combo.height
            text: "v"
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(9)
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        delegate: ItemDelegate {
            width: combo.width
            height: VfTheme.dp(26)

            contentItem: Text {
                text: modelData.label
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        popup: Popup {
            y: combo.height + 4
            width: combo.width
            padding: 4
            background: Rectangle {
                color: VfTheme.surface
                border.color: VfTheme.border
                border.width: 1
                radius: 6
            }
            contentItem: ListView { // perf-lint: disable=R1  combobox popup with 2-5 tiny items; recycling pointless
                clip: true
                implicitHeight: contentHeight
                model: combo.delegateModel
                currentIndex: combo.highlightedIndex
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: VfTheme.dp(6)

        InlineLabel {
            text: (void i18n.revision, i18n.t("clone.voice_select", "Voice"))
        }

        InlineCombo {
            Layout.fillWidth: true
            Layout.minimumWidth: VfTheme.dp(150)
            options: root.voices
            selectedValue: root.voice
            accent: VfTheme.cyan
            onSelected: value => {
                root.voice = String(value)
                root.voiceSelected(root.voice)
            }
        }

        VfButton {
            visible: root.showPreview
            text: (void i18n.revision, i18n.t("voice_studio.play_btn", "Play"))
            tone: "primary"
            minWidth: VfTheme.dp(58)
            implicitHeight: VfTheme.dp(28)
            onClicked: root.previewRequested(root.voice)
        }

        InlineLabel {
            visible: root.provider !== "local_tts"
            text: (void i18n.revision, i18n.t("clone.tts_model", "TTS Model"))
        }

        InlineCombo {
            visible: root.provider !== "local_tts"
            Layout.preferredWidth: VfTheme.dp(150)
            Layout.maximumWidth: VfTheme.dp(220)
            options: root.models
            selectedValue: root.ttsModel
            accent: VfTheme.violet
            onSelected: value => {
                root.ttsModel = String(value)
                root.modelSelected(root.ttsModel)
            }
        }

        InlineLabel {
            text: (void i18n.revision, i18n.t("voice_studio.provider_label", "Provider:"))
        }

        InlineCombo {
            Layout.preferredWidth: VfTheme.dp(128)
            Layout.maximumWidth: VfTheme.dp(160)
            options: root.providers
            selectedValue: root.provider
            accent: VfTheme.greenBorder
            onSelected: value => {
                root.provider = String(value)
                root.providerSelected(root.provider)
            }
        }

        InlineLabel {
            visible: root.showStyle && root.provider !== "local_tts"
            text: (void i18n.revision, i18n.t("voice_studio.preset_label", "Preset:"))
        }

        InlineCombo {
            visible: root.showStyle && root.provider !== "local_tts"
            Layout.preferredWidth: VfTheme.dp(128)
            Layout.maximumWidth: VfTheme.dp(190)
            options: root.presets
            selectedValue: root.preset
            accent: VfTheme.cyan
            onSelected: value => {
                root.preset = String(value)
                root.presetSelected(root.preset)
            }
        }
    }
}
