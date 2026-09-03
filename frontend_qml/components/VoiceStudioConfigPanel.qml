import QtQuick
import QtQuick.Layouts

import "../components"
import "../theme"

Rectangle {
    id: root

    property string selectedVoice: "default"
    property string selectedModel: "default"
    property int minimaxKeyCount: 0
    property int elevenlabsKeyCount: 0
    property var sharedConfig: ({})

    signal voiceSelected(string voiceId)
    signal modelSelected(string modelId)
    signal outputFolderRequested()
    signal configureKeys(string provider)
    signal syncRequested()
    signal configureProviderRequested()

    function providerLabel(provider) {
        var value = String(provider || "")
        // MiniMax / ElevenLabs / Local TTS removed — Gemini only
        if (value === "gemini")
            return "Gemini Audio"
        return value.length > 0 ? value : "TTS"
    }

    function compiledSummary() {
        var cfg = root.sharedConfig || ({})
        var provider = root.providerLabel(cfg.provider || voiceController.provider)
        var model = String(cfg.model || root.selectedModel || "")
        var voice = String(cfg.voice_id || root.selectedVoice || "")
        var parts = [provider]
        if (model.length > 0)
            parts.push(model)
        if (voice.length > 0)
            parts.push(voice)
        return parts.join("  /  ")
    }

    function runtimeReady() {
        var cfg = root.sharedConfig || ({})
        var runtime = cfg.runtime || ({})
        return Boolean(runtime.ready)
    }

    function runtimeText() {
        var cfg = root.sharedConfig || ({})
        var runtime = cfg.runtime || ({})
        return root.runtimeReady() ? "Ready" : String(runtime.reason || "Needs config")
    }

    Layout.fillWidth: true
    implicitHeight: configGrid.implicitHeight + VfTheme.dp(18)
    radius: VfTheme.radiusPanel
    color: VfTheme.canvas
    border.color: VfTheme.borderBox
    border.width: 1

    GridLayout {
        id: configGrid
        anchors.fill: parent
        anchors.margins: VfTheme.dp(7)
        columns: root.width >= 1560 ? 8 : (root.width >= 1080 ? 4 : 2)
        rowSpacing: VfTheme.dp(6)
        columnSpacing: VfTheme.dp(6)

        VfSelectField {
            label: "Provider"
            options: voiceController.providers
            value: voiceController.provider
            accent: VfTheme.amber
            onSelected: value => voiceController.setProvider(String(value))
        }

        VfSelectField {
            label: "Voice"
            options: voiceController.voices
            value: root.selectedVoice
            iconRole: "flag"
            accent: VfTheme.violet
            onSelected: value => root.voiceSelected(String(value))
        }

        VfSelectField {
            label: "Model"
            options: voiceController.models
            value: root.selectedModel
            accent: VfTheme.cyan
            onSelected: value => root.modelSelected(String(value))
        }

        VfSelectField {
            label: "TTS Route"
            options: [
                { label: "Manual provider", value: "manual" },
                { label: "Auto fallback", value: "auto" }
            ]
            value: voiceController.ttsMode || "manual"
            accent: VfTheme.greenBorder
            onSelected: value => voiceController.setTtsMode(String(value))
        }

        VfValueField {
            label: "Output"
            value: voiceController.outputFolder || ""
            placeholder: "Not selected"
            actionText: "Set"
            accent: VfTheme.cyan
            onActivated: root.outputFolderRequested()
        }

        VfValueField {
            label: "API Keys"
            value: "Gemini gateway only"
            actionText: "—"
            accent: VfTheme.violet
            onActivated: { }
        }

        VfValueField {
            label: root.runtimeText()
            value: root.compiledSummary()
            placeholder: "Shared TTS config"
            actionText: "Sync"
            accent: root.runtimeReady() ? VfTheme.greenBorder : VfTheme.amber
            onActivated: root.syncRequested()
        }

        VfValueField {
            label: (void i18n.revision, i18n.t("voice_studio.provider_config", "Cấu hình chi tiết"))
            value: String(voiceController.provider || "")
            placeholder: "Provider settings"
            actionText: "⚙"
            accent: VfTheme.violet
            onActivated: root.configureProviderRequested()
        }
    }
}
