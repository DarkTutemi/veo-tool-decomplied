import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

// Layer-1 output config for Voice Studio. Branches on voiceController.outputMode.
// Config keys match the per-mode dataclasses in voice_studio_service.py:
//   video     -> model_key / market / aspect_ratio / quality / clip_duration_seconds
//   image     -> image_model / market / aspect_ratio / image_quality /
//                seconds_per_image / motion(kenburns|static) / transition
//   animation -> image_model / market / aspect_ratio / image_quality /
//                seconds_per_image / i2v_model / transition / motion_prompt
// Audio mode hides the whole panel.
Rectangle {
    id: root

    property string outputMode: voiceController.outputMode || "audio"
    property var videoConfig: voiceController.videoConfig || ({})
    property var masterOptions: masterOptionsController.options || ({})

    // Style catalog (read-only list of available styles). The CHOSEN style is stored
    // per-mode in this mode's own config — NOT borrowed from Master config.
    property var styleOptions: {
        var raw = masterOptionsController.styles || []
        var out = [{ label: (void i18n.revision, i18n.t("voice_studio.style_none", "(mặc định)")), value: "" }]
        for (var i = 0; i < raw.length; i++) {
            var s = raw[i] || ({})
            out.push({
                label: String(s.name || s.label || s.title || s.id || s.value || ""),
                value: String(s.id || s.value || s.style_id || "")
            })
        }
        return out
    }
    function styleNameFor(value) {
        var v = String(value || "")
        for (var i = 0; i < root.styleOptions.length; i++)
            if (String(root.styleOptions[i].value) === v) return String(root.styleOptions[i].label)
        return ""
    }

    readonly property bool isVideo: root.outputMode === "video"
    readonly property bool isImage: root.outputMode === "image"
    readonly property bool isAnimation: root.outputMode === "animation"
    readonly property bool isImageLike: root.isImage || root.isAnimation

    // ── Static option lists ──────────────────────────────────────────────────
    property var marketOptions: [
        { label: "Global", value: "global", flag: "global" },
        { label: "Vietnam", value: "vn", flag: "vn" },
        { label: "US", value: "us", flag: "us" },
        { label: "Japan", value: "jp", flag: "jp" },
        { label: "Korea", value: "kr", flag: "kr" },
        { label: "China", value: "cn", flag: "cn" }
    ]
    property var aspectOptions: [
        { label: "16:9", value: "16:9" },
        { label: "9:16", value: "9:16" }
    ]
    property var imageModelOptions: [
        { label: "GemPix 2", value: "GEM_PIX_2" },
        { label: "Narwhal", value: "NARWHAL" }
    ]
    property var imageQualityOptions: [
        { label: "Default (1024)", value: "720p" },
        { label: "2K Upscale", value: "2K" },
        { label: "4K Upscale", value: "4K" }
    ]
    property var imageSecondsOptions: [
        { label: (void i18n.revision, i18n.t("voice_studio_output_config_panel.image_8s", "8s / ảnh")), value: "8" },
        { label: (void i18n.revision, i18n.t("voice_studio_output_config_panel.image_12s", "12s / ảnh")), value: "12" },
        { label: (void i18n.revision, i18n.t("voice_studio_output_config_panel.image_16s", "16s / ảnh")), value: "16" },
        { label: (void i18n.revision, i18n.t("voice_studio_output_config_panel.image_20s", "20s / ảnh")), value: "20" }
    ]
    property var videoSecondsOptions: [
        { label: (void i18n.revision, i18n.t("voice_studio_output_config_panel.video_4s", "4s / cảnh")), value: "4" },
        { label: (void i18n.revision, i18n.t("voice_studio_output_config_panel.video_6s", "6s / cảnh")), value: "6" },
        { label: (void i18n.revision, i18n.t("voice_studio_output_config_panel.video_8s", "8s / cảnh")), value: "8" },
        { label: (void i18n.revision, i18n.t("voice_studio_output_config_panel.video_10s", "10s / cảnh")), value: "10" }
    ]
    property var motionOptions: [
        { label: "Ken Burns", value: "kenburns" },
        { label: (void i18n.revision, i18n.t("voice_studio_output_config_panel.motion_static", "Tĩnh")), value: "static" }
    ]
    property var i2vModelOptions: [
        { label: "Veo 3.1 I2V Fast", value: "veo_3_1_i2v_fast" }
    ]
    property var transitionOptions: [
        { label: "Fade", value: "fade" },
        { label: "Cut", value: "cut" },
        { label: "Wipe", value: "wipe" }
    ]

    Layout.fillWidth: true
    visible: root.outputMode !== "audio"
    implicitHeight: contentColumn.implicitHeight + VfTheme.dp(18)
    radius: VfTheme.radiusPanel
    color: VfTheme.canvas
    border.color: VfTheme.borderBox
    border.width: 1

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: VfTheme.dp(9)
        spacing: VfTheme.dp(8)

        Text {
            Layout.fillWidth: true
            text: root.isAnimation
                ? (void i18n.revision, i18n.t("voice_studio.animation_hint2", "AI tạo nội dung → TTS → Phân tích kịch bản → Tạo ảnh → I2V chuyển động → ghép video. Tự động."))
                : root.isImage
                    ? (void i18n.revision, i18n.t("voice_studio.image_hint2", "AI tạo nội dung → TTS → Phân tích kịch bản → Tạo ảnh từng cảnh → Ghép video (Ken Burns). Tự động."))
                    : (void i18n.revision, i18n.t("voice_studio.video_hint2", "AI tạo nội dung → TTS → Phân tích kịch bản → Tạo video (VEO3). Tự động, cấu hình riêng cho mode này."))
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            wrapMode: Text.WordWrap
        }

        GridLayout {
            Layout.fillWidth: true
            columns: root.width >= 1280 ? 6 : (root.width >= 820 ? 4 : 2)
            rowSpacing: VfTheme.dp(6)
            columnSpacing: VfTheme.dp(6)

            // STYLE — per-mode, stored in this mode's own config (not Master's).
            VfSelectField {
                label: (void i18n.revision, i18n.t("voice_studio.style", "Phong cách"))
                options: root.styleOptions
                value: String(root.videoConfig.style_id || "")
                accent: VfTheme.violet
                onSelected: value => {
                    voiceController.setVideoOption("style_id", String(value))
                    voiceController.setVideoOption("selected_style", root.styleNameFor(value))
                }
            }

            // MODEL — video uses the master model list, image/animation use static.
            VfSelectField {
                label: (void i18n.revision, i18n.t("voice_studio.model", "Model"))
                options: root.isImageLike ? root.imageModelOptions : (root.masterOptions.models || [])
                value: root.isImageLike
                    ? String(root.videoConfig.image_model || "GEM_PIX_2")
                    : String(root.videoConfig.model_key || "")
                accent: VfTheme.cyan
                onSelected: value => voiceController.setVideoOption(
                    root.isImageLike ? "image_model" : "model_key", String(value))
            }

            // MARKET
            VfSelectField {
                label: (void i18n.revision, i18n.t("voice_studio.market", "Thị trường"))
                options: root.marketOptions
                value: String(root.videoConfig.market || "global")
                iconRole: "flag"
                accent: VfTheme.cyan
                onSelected: value => voiceController.setVideoOption("market", String(value))
            }

            // ASPECT
            VfSelectField {
                label: (void i18n.revision, i18n.t("voice_studio.aspect_ratio", "Tỉ lệ"))
                options: (root.masterOptions.aspects && root.masterOptions.aspects.length > 0)
                    ? root.masterOptions.aspects
                    : root.aspectOptions
                value: String(root.videoConfig.aspect_ratio || "16:9")
                accent: VfTheme.violet
                onSelected: value => voiceController.setVideoOption("aspect_ratio", String(value))
            }

            // QUALITY — video master qualities vs image upscale tiers.
            VfSelectField {
                label: (void i18n.revision, i18n.t("voice_studio.quality", "Chất lượng"))
                options: root.isImageLike ? root.imageQualityOptions : (root.masterOptions.qualities || [])
                value: root.isImageLike
                    ? String(root.videoConfig.image_quality || "2K")
                    : String(root.videoConfig.quality || "720p")
                accent: VfTheme.amber
                onSelected: value => voiceController.setVideoOption(
                    root.isImageLike ? "image_quality" : "quality", String(value))
            }

            // CLIP / SECONDS-PER-IMAGE
            VfSelectField {
                label: root.isImageLike
                    ? (void i18n.revision, i18n.t("voice_studio.seconds_per_image", "Giây / ảnh"))
                    : (void i18n.revision, i18n.t("voice_studio.clip_duration", "Thời lượng cảnh"))
                options: root.isImageLike
                    ? root.imageSecondsOptions
                    : ((root.masterOptions.model_durations && root.masterOptions.model_durations.length > 0)
                        ? root.masterOptions.model_durations
                        : root.videoSecondsOptions)
                value: root.isImageLike
                    ? String(root.videoConfig.seconds_per_image || 8)
                    : String(root.videoConfig.clip_duration_seconds || 8)
                accent: VfTheme.amber
                onSelected: value => voiceController.setVideoOption(
                    root.isImageLike ? "seconds_per_image" : "clip_duration_seconds", Number(value))
            }

            // MOTION (image only — Ken Burns / Static)
            VfSelectField {
                visible: root.isImage
                label: (void i18n.revision, i18n.t("voice_studio.motion", "Chuyển động"))
                options: root.motionOptions
                value: String(root.videoConfig.motion || "kenburns")
                accent: VfTheme.violet
                onSelected: value => voiceController.setVideoOption("motion", String(value))
            }

            // I2V MODEL (animation only)
            VfSelectField {
                visible: root.isAnimation
                label: (void i18n.revision, i18n.t("voice_studio.i2v_model", "Model I2V"))
                options: root.i2vModelOptions
                value: String(root.videoConfig.i2v_model || "veo_3_1_i2v_fast")
                accent: VfTheme.violet
                onSelected: value => voiceController.setVideoOption("i2v_model", String(value))
            }

            // TRANSITION (image + animation)
            VfSelectField {
                visible: root.isImageLike
                label: (void i18n.revision, i18n.t("voice_studio.transition", "Chuyển cảnh"))
                options: root.transitionOptions
                value: String(root.videoConfig.transition || "fade")
                accent: VfTheme.violet
                onSelected: value => voiceController.setVideoOption("transition", String(value))
            }
        }

        // MOTION PROMPT (animation only) — short prompt steering the I2V motion.
        RowLayout {
            Layout.fillWidth: true
            visible: root.isAnimation
            spacing: VfTheme.dp(8)

            Text {
                text: (void i18n.revision, i18n.t("voice_studio.motion_prompt", "Prompt chuyển động"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightStrong
            }
            TextField {
                Layout.fillWidth: true
                placeholderText: (void i18n.revision, i18n.t("voice_studio.motion_prompt_ph", "VD: camera lia nhẹ, mây trôi, tóc bay..."))
                text: String(root.videoConfig.motion_prompt || "")
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                selectByMouse: true
                onEditingFinished: voiceController.setVideoOption("motion_prompt", text)
                background: Rectangle { radius: VfTheme.dp(7); color: VfTheme.surface; border.color: VfTheme.borderBox }
            }
        }
    }
}
