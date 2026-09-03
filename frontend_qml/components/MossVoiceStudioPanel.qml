import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: panel

    property var options: ({})
    property bool advancedOpen: false
    signal optionChanged(string key, var value)

    readonly property string mode: String(options.moss_mode || "direct")
    readonly property bool needsReference: mode !== "direct"
    readonly property bool needsTranscript: mode === "continuation"
        || mode === "continuation_clone"

    function fileName(path) {
        var parts = String(path || "").replace(/\\/g, "/").split("/")
        return parts.length ? parts[parts.length - 1] : ""
    }

    function chooseReference() {
        var picked = nativeShell.pickFiles(
            "Chọn file giọng mẫu",
            "Audio Files (*.wav *.mp3 *.m4a *.flac);;All Files (*.*)", "")
        if (picked && picked.ok && picked.paths && picked.paths.length > 0)
            panel.optionChanged("moss_ref_audio", String(picked.paths[0] || ""))
    }

    implicitHeight: content.implicitHeight + VfTheme.dp(20)
    radius: VfTheme.dp(10)
    color: VfTheme.surfaceSoft
    border.color: VfTheme.borderBox

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: VfTheme.dp(10)
        spacing: VfTheme.dp(8)

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            Text {
                text: "MOSS-TTS v1.5"
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSection
                font.weight: VfTheme.weightStrong
            }
            Text {
                Layout.fillWidth: true
                text: "Long-form · direct · zero-shot clone · continuation"
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                elide: Text.ElideRight
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: width >= VfTheme.dp(660) ? 3 : 1
            uniformCellWidths: true
            columnSpacing: VfTheme.dp(8)
            rowSpacing: VfTheme.dp(8)

            VfSelectField {
                Layout.fillWidth: true
                label: "Chế độ"
                options: [
                    { label: "Direct — tạo trực tiếp", value: "direct" },
                    { label: "Clone giọng", value: "clone" },
                    { label: "Nối tiếp audio", value: "continuation" },
                    { label: "Nối tiếp + clone", value: "continuation_clone" }
                ]
                value: panel.mode
                accent: "#EC4899"
                onSelected: value => panel.optionChanged("moss_mode", String(value))
            }
            VfSelectField {
                Layout.fillWidth: true
                label: "Ngôn ngữ"
                options: [
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
                    { label: "Tự nhận", value: "auto" }
                ]
                value: String(panel.options.moss_language || "vi")
                accent: VfTheme.violet
                onSelected: value => panel.optionChanged("moss_language", String(value))
            }
            VfTextField {
                Layout.fillWidth: true
                label: "Thời lượng mong muốn (giây)"
                value: String(panel.options.moss_duration || "")
                placeholder: "0 / trống = tự động"
                onCommitted: value => panel.optionChanged("moss_duration", value)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: panel.needsReference
            spacing: VfTheme.dp(8)

            VfValueField {
                Layout.fillWidth: true
                label: "Audio mẫu"
                value: panel.fileName(panel.options.moss_ref_audio)
                placeholder: "Bắt buộc với mode đã chọn"
                actionText: String(panel.options.moss_ref_audio || "").length ? "Đổi" : "Chọn"
                accent: "#EC4899"
                onActivated: panel.chooseReference()
            }
            SmallPill {
                text: "Xóa"
                visible: String(panel.options.moss_ref_audio || "").length > 0
                onClicked: panel.optionChanged("moss_ref_audio", "")
            }
        }

        VfTextField {
            Layout.fillWidth: true
            visible: panel.needsTranscript
            label: "Transcript chính xác của audio mẫu"
            value: String(panel.options.moss_prompt_text || "")
            placeholder: "Bắt buộc để nối tiếp đúng ngữ điệu và nội dung"
            onCommitted: value => panel.optionChanged("moss_prompt_text", value)
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            SmallPill {
                text: panel.advancedOpen ? "Ẩn nâng cao" : "Nâng cao"
                selected: panel.advancedOpen
                onClicked: panel.advancedOpen = !panel.advancedOpen
            }
            Text {
                Layout.fillWidth: true
                text: "Giữ mặc định nếu không cần điều khiển sampling hoặc streaming."
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                elide: Text.ElideRight
            }
        }

        GridLayout {
            Layout.fillWidth: true
            visible: panel.advancedOpen
            columns: width >= VfTheme.dp(760) ? 4 : 2
            uniformCellWidths: true
            columnSpacing: VfTheme.dp(8)
            rowSpacing: VfTheme.dp(8)

            VfTextField {
                Layout.fillWidth: true
                label: "Temperature · 0.1–3.0"
                value: String(panel.options.moss_temperature || "1.7")
                onCommitted: value => panel.optionChanged("moss_temperature", value)
            }
            VfTextField {
                Layout.fillWidth: true
                label: "Top P · 0.1–1.0"
                value: String(panel.options.moss_top_p || "0.8")
                onCommitted: value => panel.optionChanged("moss_top_p", value)
            }
            VfTextField {
                Layout.fillWidth: true
                label: "Top K · 1–200"
                value: String(panel.options.moss_top_k || "25")
                onCommitted: value => panel.optionChanged("moss_top_k", value)
            }
            VfTextField {
                Layout.fillWidth: true
                label: "Lặp lại · 0.8–2.0"
                value: String(panel.options.moss_repetition_penalty || "1.0")
                onCommitted: value => panel.optionChanged(
                    "moss_repetition_penalty", value)
            }
            VfTextField {
                Layout.fillWidth: true
                label: "Max token · 256–7500"
                value: String(panel.options.moss_max_new_tokens || "7500")
                onCommitted: value => panel.optionChanged("moss_max_new_tokens", value)
            }
            VfTextField {
                Layout.fillWidth: true
                label: "Codec frames · 0–32"
                value: String(panel.options.moss_codec_chunk_frames || "0")
                onCommitted: value => panel.optionChanged(
                    "moss_codec_chunk_frames", value)
            }
            VfSelectField {
                Layout.fillWidth: true
                label: "Streaming"
                options: [
                    { label: "Tắt — ổn định", value: "0" },
                    { label: "Bật", value: "1" }
                ]
                value: String(panel.options.moss_streaming_generation || "0")
                accent: "#10B981"
                onSelected: value => panel.optionChanged(
                    "moss_streaming_generation", String(value))
            }
            VfTextField {
                Layout.fillWidth: true
                label: "Seed"
                value: String(panel.options.moss_seed || "")
                placeholder: "tự chọn theo mỗi take"
                onCommitted: value => panel.optionChanged("moss_seed", value)
            }
        }
    }

    component SmallPill: Rectangle {
        id: pill
        property string text: ""
        property bool selected: false
        signal clicked()
        implicitWidth: pillLabel.implicitWidth + VfTheme.dp(20)
        implicitHeight: VfTheme.dp(30)
        radius: VfTheme.dp(9)
        color: selected ? VfTheme.violetFill : VfTheme.surface
        border.color: selected ? VfTheme.violet : VfTheme.borderBox

        Text {
            id: pillLabel
            anchors.centerIn: parent
            text: pill.text
            color: selected ? VfTheme.violetText : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            font.weight: selected ? VfTheme.weightStrong : VfTheme.weightRegular
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: pill.clicked()
        }
    }
}
