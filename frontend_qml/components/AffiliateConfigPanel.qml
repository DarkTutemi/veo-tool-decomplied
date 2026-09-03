import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

// Config bar RIÊNG cho tab affiliate (tab đặc thù). Model quyết định NGÂN SÁCH tham
// chiếu mỗi video: VEO 3.1 → 3 ref (SP + 1 KOL + 1 bối cảnh); ABRA/Omni → 7 (SP + 3 KOL
// + 3 obj). Ghi THẲNG `video_model_key` — đúng key mà sales_architect + dispatch affiliate
// đọc (panel master cũ ghi `model_key` → không tới dispatch, đây là lý do tách panel).
Rectangle {
    id: root
    objectName: "affiliateConfigPanel"

    Layout.fillWidth: true
    implicitHeight: panelCol.implicitHeight + VfTheme.dp(14)
    radius: VfTheme.radiusPanel
    color: VfTheme.canvas
    border.color: VfTheme.borderBox
    border.width: 1

    readonly property var config: (typeof workPanelController !== "undefined" && workPanelController)
        ? (workPanelController.currentRouteConfig || ({})) : ({})
    readonly property var options: (typeof workPanelController !== "undefined" && workPanelController)
        ? (workPanelController.currentRouteOptions || ({})) : ({})
    readonly property string modelKey: String(root.config.video_model_key || "")
    // Re-evaluates whenever the selected model changes (modelKey depends on config).
    readonly property var budget: (typeof workPanelController !== "undefined" && workPanelController)
        ? (workPanelController.affiliateModelBudget(root.modelKey) || ({})) : ({})
    readonly property var affiliateNarratorVoiceOptions: {
        var merged = []
        var voices = narratorController.voiceOptions || []
        for (var i = 0; i < voices.length; i += 1)
            merged.push(voices[i])
        return merged
    }
    readonly property string affiliateNarratorVoiceValue:
        String(narratorController.selectedVoiceValue || "auto")

    function writeOpt(key, value) {
        if (typeof workPanelController !== "undefined" && workPanelController)
            workPanelController.setRouteOption("affiliate", key, value)
    }
    // Narrator is independent from native KOL dialogue: OFF hands spoken selling
    // to visible characters; voice_language none/silent is the full mute.
    function pickFolder() {
        var picked = nativeShell.pickFolder(
            (void i18n.revision, i18n.t("master.select_output_folder", "Set output folder")),
            String(root.config.output_folder || ""))
        if (picked && picked.ok && String(picked.path || "").length > 0)
            root.writeOpt("output_folder", String(picked.path || ""))
    }

    ColumnLayout {
        id: panelCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: VfTheme.dp(7)
        spacing: VfTheme.dp(6)

    // MỘT HÀNG 8 field (bố chốt 21/7 — 2 hàng để trống thừa từng ô + block CHẠY lơ
    // lửng). Mọi con là field ĐƠN (không RowLayout lồng) nên cột không phình;
    // màn hẹp tự gãy 4 → 2 → 1 cột.
    GridLayout {
        id: grid
        Layout.fillWidth: true
        columns: width >= VfTheme.dp(1440) ? 8
                 : (width >= VfTheme.dp(900) ? 4 : (width >= VfTheme.dp(560) ? 2 : 1))
        rowSpacing: VfTheme.dp(6)
        columnSpacing: VfTheme.dp(6)

        VfSelectField {
            Layout.fillWidth: true
            label: (void i18n.revision, i18n.t("config_panel.model", "Model"))
            options: root.options.models || []
            value: root.config.video_model_key || ""
            accent: VfTheme.violet
            onSelected: value => root.writeOpt("video_model_key", value)
        }
        VfSelectField {
            Layout.fillWidth: true
            label: (void i18n.revision, i18n.t("qml.master.aspect", "Aspect"))
            options: root.options.aspects || []
            value: root.config.aspect_ratio || "9:16"
            accent: VfTheme.cyan
            onSelected: value => root.writeOpt("aspect_ratio", value)
        }
        VfSelectField {
            Layout.fillWidth: true
            label: (void i18n.revision, i18n.t("qml.master.quality", "Quality"))
            options: root.options.qualities || []
            value: root.config.quality || "720p"
            accent: VfTheme.amber
            onSelected: value => root.writeOpt("quality", value)
        }
        VfValueField {
            Layout.fillWidth: true
            actionId: "affiliate.config.folder_picker"
            label: (void i18n.revision, i18n.t("master.save_folder", "Save Folder"))
            value: root.config.output_folder || ""
            placeholder: (void i18n.revision, i18n.t("master.not_selected", "Not Selected"))
            actionText: (void i18n.revision, i18n.t("common.set", "Set"))
            accent: VfTheme.cyan
            onActivated: root.pickFolder()
        }
        VfSelectField {
            Layout.fillWidth: true
            label: (void i18n.revision, i18n.t("config_panel.market", "Thị trường"))
            options: root.options.markets || []
            value: String(root.config.market || "vietnam")
            iconRole: "flag"; accent: VfTheme.greenBorder
            onSelected: value => root.writeOpt("market", String(value))
        }
        VfSelectField {
            Layout.fillWidth: true
            label: (void i18n.revision, i18n.t("config_panel.voice_language", "Ngôn ngữ lời dẫn"))
            options: root.options.voice_languages || []
            value: String(root.config.voice_language || "vi")
            iconRole: "flag"; accent: VfTheme.greenBorder
            onSelected: value => root.writeOpt("voice_language", String(value))
        }
        VfSelectField {
            Layout.fillWidth: true
            label: (void i18n.revision, i18n.t("affiliate.narration_voice", "Giọng lời dẫn"))
            options: root.affiliateNarratorVoiceOptions
            value: root.affiliateNarratorVoiceValue
            accent: VfTheme.cyan
            onSelected: function(value) {
                var selectedVoice = String(value || "")
                narratorController.selectVoiceValue(selectedVoice)
                narratorController.previewVoice(selectedVoice, 1)
            }
        }
        VfSelectField {
            Layout.fillWidth: true
            label: (void i18n.revision, i18n.t("narrator.emotion", "Cảm xúc đọc"))
            options: narratorController.emotionOptions
            value: narratorController.emotion
            enabled: Boolean(root.config.enable_narrator)
            accent: VfTheme.cyan
            onSelected: function(value) { narratorController.setEmotion(String(value)) }
        }
    }

        // Ngân sách tham chiếu/video — strip tint xanh (đọc rõ cả 2 theme).
        Rectangle {
            objectName: "affiliateModelBudget"
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(28)
            radius: VfTheme.dp(6)
            color: VfTheme.blueFill
            border.color: VfTheme.blueBorderSoft
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(10)
                anchors.rightMargin: VfTheme.dp(10)
                spacing: VfTheme.dp(8)

                Text {
                    text: "ⓘ"
                    color: VfTheme.blueText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                    font.weight: Font.Bold
                }
                Text {
                    Layout.fillWidth: true
                    text: {
                        var b = root.budget || ({})
                        return (void i18n.revision, i18n.t("affiliate.model_budget_badge",
                            "%1 · %2 tham chiếu/video = SP + %3 KOL + %4 bối cảnh (chọn nhiều → xoay theo biến thể)"))
                            .replace("%1", String(b.label || "Model"))
                            .replace("%2", String(b.max_refs !== undefined ? b.max_refs : 3))
                            .replace("%3", String(b.max_chars !== undefined ? b.max_chars : 1))
                            .replace("%4", String(b.max_bg !== undefined ? b.max_bg : 1))
                            + "   ·   SRT ✓"
                    }
                    color: VfTheme.blueText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    elide: Text.ElideRight
                }
            }
        }
    }
}
