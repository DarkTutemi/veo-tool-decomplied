import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

// Provider-specific controls for SharedTtsInlinePanel. This component owns no
// persistence and no engine lifecycle: every edit is returned to the shared
// panel as one draft field, then applied through VoiceController's worker.
ColumnLayout {
    id: panel

    property string provider: "gemini"
    property var options: ({})
    property var engineInfo: ({})
    signal optionChanged(string key, var value)
    signal optionsPatched(var values)

    spacing: VfTheme.dp(8)
    implicitHeight: contentColumn.implicitHeight

    function fileName(path) {
        var parts = String(path || "").replace(/\\/g, "/").split("/")
        return parts.length ? parts[parts.length - 1] : ""
    }

    function chooseAudio(title, key, clearKeys) {
        var picked = nativeShell.pickFiles(
            title,
            "Audio Files (*.wav *.mp3 *.m4a *.flac);;All Files (*.*)", "")
        if (!picked || !picked.ok || !picked.paths || picked.paths.length === 0)
            return
        panel.optionChanged(key, String(picked.paths[0] || ""))
        var keys = clearKeys || []
        for (var i = 0; i < keys.length; i++)
            panel.optionChanged(String(keys[i]), "")
    }

    ColumnLayout {
        id: contentColumn
        Layout.fillWidth: true
        spacing: VfTheme.dp(8)

        // Gemini's model, voice and delivery preset are already in the quick
        // bar. The expanded area exposes only fields that affect its prompt.
        Rectangle {
            visible: panel.provider === "gemini"
            Layout.fillWidth: true
            implicitHeight: geminiGrid.implicitHeight + VfTheme.dp(18)
            radius: VfTheme.radiusPanel
            color: VfTheme.surface
            border.color: VfTheme.blueBorderSoft

            GridLayout {
                id: geminiGrid
                anchors.fill: parent
                anchors.margins: VfTheme.dp(9)
                columns: width >= VfTheme.dp(720) ? 2 : 1
                uniformCellWidths: true
                columnSpacing: VfTheme.dp(8)
                rowSpacing: VfTheme.dp(7)

                LabeledTextField {
                    Layout.fillWidth: true
                    label: "Audio profile"
                    value: String(panel.options.gemini_audio_profile
                                  || panel.options.audio_profile || "")
                    placeholder: "Ví dụ: người dẫn chuyện ấm, gần gũi"
                    onCommitted: value => panel.optionChanged(
                        "gemini_audio_profile", value)
                }
                LabeledTextField {
                    Layout.fillWidth: true
                    label: "Chỉ dẫn cách đọc"
                    value: String(panel.options.gemini_director_notes
                                  || panel.options.director_notes || "")
                    placeholder: "Ví dụ: rõ chữ, nhịp vừa, kết câu tự nhiên"
                    onCommitted: value => panel.optionChanged(
                        "gemini_director_notes", value)
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.columnSpan: geminiGrid.columns
                    implicitHeight: geminiNote.implicitHeight + VfTheme.dp(14)
                    radius: VfTheme.dp(8)
                    color: VfTheme.blueFill
                    border.color: VfTheme.blueBorderSoft
                    Text {
                        id: geminiNote
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: VfTheme.dp(9)
                            rightMargin: VfTheme.dp(9)
                        }
                        text: "Gemini dùng AI Studio cho cấu hình giọng dùng chung. "
                            + "Đường API Server không xuất hiện trong selector nhanh."
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        OmniVoiceStudioPanel {
            visible: panel.provider === "omnivoice"
            Layout.fillWidth: true
            options: panel.options
            showVoiceLibrary: false
            onOptionChanged: (key, value) => panel.optionChanged(key, value)
            onOptionsPatched: values => panel.optionsPatched(values)
        }

        MossVoiceStudioPanel {
            visible: panel.provider === "moss"
            Layout.fillWidth: true
            options: panel.options
            onOptionChanged: (key, value) => panel.optionChanged(key, value)
        }

        Rectangle {
            visible: panel.provider === "vieneu"
            Layout.fillWidth: true
            implicitHeight: vieneuColumn.implicitHeight + VfTheme.dp(18)
            radius: VfTheme.radiusPanel
            color: VfTheme.surface
            border.color: VfTheme.amberBorderSoft

            ColumnLayout {
                id: vieneuColumn
                anchors.fill: parent
                anchors.margins: VfTheme.dp(9)
                spacing: VfTheme.dp(8)

                GridLayout {
                    Layout.fillWidth: true
                    columns: width >= VfTheme.dp(720) ? 3 : 1
                    uniformCellWidths: true
                    columnSpacing: VfTheme.dp(8)
                    rowSpacing: VfTheme.dp(7)

                    VfSelectField {
                        Layout.fillWidth: true
                        label: "Chất lượng"
                        options: [
                            { label: "Nhanh · INT8", value: "int8" },
                            { label: "Chất lượng cao · FP32", value: "fp32" }
                        ]
                        value: String(panel.options.vieneu_precision || "int8")
                        accent: VfTheme.cyan
                        onSelected: value => panel.optionChanged(
                            "vieneu_precision", String(value))
                    }
                    VfSelectField {
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
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: VfTheme.fieldHeight
                        radius: VfTheme.radiusControl
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.borderSoft
                        Text {
                            anchors {
                                fill: parent
                                margins: VfTheme.dp(8)
                            }
                            text: "Một request / take · server tự chia câu"
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(6)
                    VfValueField {
                        Layout.fillWidth: true
                        label: "Audio mẫu để clone · khuyên dùng 3–8 giây"
                        value: panel.fileName(panel.options.vieneu_ref_audio)
                        placeholder: "Chưa chọn · dùng giọng preset"
                        actionText: String(panel.options.vieneu_ref_audio || "").length
                            ? "Đổi" : "Chọn"
                        accent: "#EC4899"
                        onActivated: panel.chooseAudio(
                            "Chọn giọng mẫu VieNeu", "vieneu_ref_audio", [])
                    }
                    VfButton {
                        visible: String(panel.options.vieneu_ref_audio || "").length > 0
                        text: "Bỏ"
                        onClicked: panel.optionChanged("vieneu_ref_audio", "")
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "VieNeu tối ưu tiếng Việt; code-switch Việt–Anh có thể "
                        + "không ổn định bằng một profile được thu đúng ngôn ngữ."
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    component LabeledTextField: ColumnLayout {
        id: field
        property string label: ""
        property string value: ""
        property string placeholder: ""
        signal committed(string value)
        spacing: VfTheme.dp(2)

        Text {
            text: field.label
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
        }
        TextField {
            Layout.fillWidth: true
            text: field.value
            placeholderText: field.placeholder
            selectByMouse: true
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            onEditingFinished: field.committed(text.trim())
            background: Rectangle {
                radius: VfTheme.dp(7)
                color: VfTheme.surfaceSoft
                border.color: parent.activeFocus
                    ? VfTheme.primary : VfTheme.borderBox
            }
        }
    }
}
