import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

// Full OmniVoice editor. VeoFlow owns the server lifecycle; this surface only
// exposes voice and rendering choices that are meaningful to an end user.
ColumnLayout {
    id: studio
    Layout.fillWidth: true
    spacing: VfTheme.dp(8)

    property var options: ({})
    property bool showVoiceLibrary: true
    signal optionChanged(string key, var value)
    signal optionsPatched(var values)

    readonly property var opts: studio.options || ({})
    readonly property string mode: String(opts.omni_mode || "new") === "auto"
        ? "new" : String(opts.omni_mode || "new")
    property bool advancedOpen: false

    readonly property var genderOptions: [
        { label: "Nữ", value: "female" },
        { label: "Nam", value: "male" }
    ]
    readonly property var ageOptions: [
        { label: "Trẻ em", value: "child" },
        { label: "Thiếu niên", value: "teenager" },
        { label: "Thanh niên", value: "young adult" },
        { label: "Trung niên", value: "middle-aged" },
        { label: "Lớn tuổi", value: "elderly" }
    ]
    readonly property var pitchOptions: [
        { label: "Rất trầm", value: "very low pitch" },
        { label: "Trầm", value: "low pitch" },
        { label: "Vừa", value: "moderate pitch" },
        { label: "Cao", value: "high pitch" },
        { label: "Rất cao", value: "very high pitch" }
    ]
    readonly property var accentOptions: [
        { label: "Tự động", value: "auto" },
        { label: "Mỹ", value: "american accent" },
        { label: "Anh", value: "british accent" },
        { label: "Úc", value: "australian accent" },
        { label: "Canada", value: "canadian accent" },
        { label: "Ấn Độ", value: "indian accent" },
        { label: "Trung Quốc", value: "chinese accent" },
        { label: "Nhật", value: "japanese accent" },
        { label: "Hàn", value: "korean accent" },
        { label: "Nga", value: "russian accent" }
    ]

    function setOpt(key, value) {
        // The parent shared panel owns the draft and serializes persistence.
        // OmniVoice is managed locally, so a stale external URL is never copied
        // into the shared selection.
        if (String(studio.opts.omni_url || "").length > 0)
            studio.optionChanged("omni_url", "")
        studio.optionChanged(key, value)
    }

    function switchMode(value) {
        var selected = ["new", "design", "profile", "clone"].indexOf(value) >= 0
            ? value : "new"
        var recipeFields = [
            "omni_recipe", "omni_gender", "omni_age", "omni_pitch",
            "omni_style", "omni_accent", "omni_instruct"
        ]
        var profileFields = ["omni_voice"]
        var refFields = ["omni_ref_audio", "omni_ref_text"]
        var clear = selected === "design"
            ? profileFields.concat(refFields)
            : selected === "profile"
                ? recipeFields.concat(refFields)
                : selected === "clone"
                    ? recipeFields.concat(profileFields)
                    : recipeFields.concat(profileFields).concat(refFields)
        var patch = ({ omni_mode: selected })
        for (var i = 0; i < clear.length; i++)
            patch[clear[i]] = ""
        studio.optionsPatched(patch)
    }

    function selectRecipe(value) {
        var selected = String(value || "")
        studio.optionsPatched({
            omni_mode: "design",
            omni_recipe: selected,
            omni_voice: "",
            omni_ref_audio: "",
            omni_ref_text: ""
        })
    }

    function selectProfile(value) {
        var selected = String(value || "")
        studio.optionsPatched({
            omni_mode: selected.length > 0 ? "profile" : "new",
            omni_voice: selected,
            omni_recipe: "",
            omni_ref_audio: "",
            omni_ref_text: ""
        })
    }

    function fileName(path) {
        var parts = String(path || "").replace(/\\/g, "/").split("/")
        return parts.length ? parts[parts.length - 1] : ""
    }

    function chooseReference() {
        var picked = nativeShell.pickFiles(
            "Chọn giọng mẫu OmniVoice",
            "Audio Files (*.wav *.mp3 *.m4a *.flac);;All Files (*.*)", "")
        if (picked && picked.ok && picked.paths && picked.paths.length > 0) {
            studio.optionsPatched({
                omni_mode: "clone",
                omni_voice: "",
                omni_recipe: "",
                omni_gender: "",
                omni_age: "",
                omni_pitch: "",
                omni_style: "",
                omni_accent: "",
                omni_instruct: "",
                omni_ref_audio: String(picked.paths[0] || ""),
                omni_ref_text: ""
            })
        }
    }

    Component.onCompleted: {
        if (String(studio.opts.omni_url || "").trim().length > 0)
            studio.setOpt("omni_url", "")
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: panelColumn.implicitHeight + VfTheme.dp(22)
        radius: VfTheme.radiusPanel
        color: VfTheme.surface
        border.color: VfTheme.violetBorderSoft
        border.width: 1

        ColumnLayout {
            id: panelColumn
            anchors.fill: parent
            anchors.margins: VfTheme.dp(11)
            spacing: VfTheme.dp(8)

            GridLayout {
                Layout.fillWidth: true
                columns: width >= VfTheme.dp(980) ? 2 : 1
                uniformCellWidths: true
                columnSpacing: VfTheme.dp(8)
                rowSpacing: VfTheme.dp(6)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(7)

                    Text {
                        text: "OmniVoice Studio"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontBody
                        font.weight: VfTheme.weightStrong
                    }
                    ModePill {
                        text: "Mới mỗi video"
                        selected: studio.mode === "new"
                        onClicked: studio.switchMode("new")
                    }
                    ModePill {
                        text: "Thiết kế mỗi video"
                        selected: studio.mode === "design"
                        onClicked: studio.switchMode("design")
                    }
                    ModePill {
                        text: "Giọng đã lưu"
                        selected: studio.mode === "profile"
                        onClicked: studio.switchMode("profile")
                    }
                    ModePill {
                        text: "Clone audio"
                        selected: studio.mode === "clone"
                        onClicked: studio.switchMode("clone")
                    }
                    Item { Layout.fillWidth: true }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: VfTheme.dp(28)
                    radius: VfTheme.dp(9)
                    color: VfTheme.violetFill
                    border.color: VfTheme.violetBorderSoft

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: VfTheme.dp(10)
                            rightMargin: VfTheme.dp(10)
                        }
                        Text {
                            text: "Xử lý bài dài"
                            color: VfTheme.violetText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            font.weight: VfTheme.weightStrong
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "1 request / bài · chia câu và crossfade trong server"
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            SectionTitle { text: "Nguồn giọng" }

            GridLayout {
                Layout.fillWidth: true
                columns: width >= VfTheme.dp(680) ? 2 : 1
                uniformCellWidths: true
                columnSpacing: VfTheme.dp(8)
                rowSpacing: VfTheme.dp(7)

                VfSelectField {
                    visible: studio.mode === "design"
                    Layout.fillWidth: true
                    label: "Công thức tạo tone"
                    options: voiceController.omniRecipeOptions || []
                    value: String(studio.opts.omni_recipe || "")
                    accent: "#EC4899"
                    onSelected: value => studio.selectRecipe(value)
                }

                VfSelectField {
                    visible: studio.mode === "profile"
                    Layout.fillWidth: true
                    label: "Giọng đã lưu"
                    options: voiceController.omniProfileOptions || []
                    value: String(studio.opts.omni_voice || "")
                    accent: "#10B981"
                    onSelected: value => studio.selectProfile(value)
                }

                RowLayout {
                    visible: studio.mode === "clone"
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(5)
                    VfValueField {
                        Layout.fillWidth: true
                        label: "Audio mẫu để clone"
                        value: studio.fileName(studio.opts.omni_ref_audio)
                        placeholder: "Chưa chọn · WAV/MP3/M4A/FLAC"
                        actionText: String(studio.opts.omni_ref_audio || "").length ? "Đổi" : "Chọn"
                        accent: VfTheme.primary
                        onActivated: studio.chooseReference()
                    }
                    VfButton {
                        visible: String(studio.opts.omni_ref_audio || "").length > 0
                        text: "Bỏ"
                        onClicked: {
                            studio.setOpt("omni_ref_audio", "")
                            studio.setOpt("omni_ref_text", "")
                        }
                    }
                }
            }

            TextField {
                Layout.fillWidth: true
                visible: studio.mode === "clone"
                    && String(studio.opts.omni_ref_audio || "").length > 0
                text: String(studio.opts.omni_ref_text || "")
                placeholderText: "Transcript chính xác của audio mẫu (khuyên dùng)"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                selectByMouse: true
                onEditingFinished: studio.setOpt("omni_ref_text", text.trim())
                background: FieldBackground { focused: parent.activeFocus }
            }

            SectionTitle {
                visible: studio.mode === "design"
                text: "Thiết kế chất giọng"
            }

            GridLayout {
                visible: studio.mode === "design"
                Layout.fillWidth: true
                columns: width >= VfTheme.dp(980) ? 5
                    : width >= VfTheme.dp(620) ? 3 : 1
                uniformCellWidths: true
                columnSpacing: VfTheme.dp(7)
                rowSpacing: VfTheme.dp(7)

                VfSelectField {
                    Layout.fillWidth: true
                    label: "Giới tính"
                    options: studio.genderOptions
                    value: String(studio.opts.omni_gender || "female")
                    accent: "#EC4899"
                    onSelected: value => studio.setOpt("omni_gender", String(value))
                }
                VfSelectField {
                    Layout.fillWidth: true
                    label: "Độ tuổi"
                    options: studio.ageOptions
                    value: String(studio.opts.omni_age || "young adult")
                    accent: VfTheme.amber
                    onSelected: value => studio.setOpt("omni_age", String(value))
                }
                VfSelectField {
                    Layout.fillWidth: true
                    label: "Cao độ"
                    options: studio.pitchOptions
                    value: String(studio.opts.omni_pitch || "moderate pitch")
                    accent: VfTheme.violet
                    onSelected: value => studio.setOpt("omni_pitch", String(value))
                }
                VfSelectField {
                    Layout.fillWidth: true
                    label: "Accent"
                    options: studio.accentOptions
                    value: String(studio.opts.omni_accent || "auto")
                    accent: VfTheme.cyan
                    onSelected: value => studio.setOpt("omni_accent", String(value))
                }
                VfSelectField {
                    Layout.fillWidth: true
                    label: "Cách đọc"
                    options: [
                        { label: "Tự động", value: "auto" },
                        { label: "Thì thầm", value: "whisper" }
                    ]
                    value: String(studio.opts.omni_style || "auto")
                    accent: "#10B981"
                    onSelected: value => studio.setOpt("omni_style", String(value))
                }
            }

            LabeledTextField {
                visible: studio.mode === "design"
                Layout.fillWidth: true
                label: "Chỉ dẫn chất giọng / cách đọc"
                value: String(studio.opts.omni_instruct || "")
                placeholder: "Ví dụ: warm, friendly, natural storyteller with clear diction"
                onCommitted: value => studio.setOpt("omni_instruct", value)
            }

            SectionTitle { text: "Chất lượng đầu ra" }

            GridLayout {
                Layout.fillWidth: true
                columns: width >= VfTheme.dp(760) ? 4 : width >= VfTheme.dp(440) ? 2 : 1
                uniformCellWidths: true
                columnSpacing: VfTheme.dp(7)
                rowSpacing: VfTheme.dp(7)

                VfSelectField {
                    Layout.fillWidth: true
                    label: "Tốc độ"
                    options: [
                        { label: "0.75×", value: "0.75" },
                        { label: "1.0×", value: "1.0" },
                        { label: "1.25×", value: "1.25" },
                        { label: "1.5×", value: "1.5" }
                    ]
                    value: String(studio.opts.omni_speed || "1.0")
                    accent: VfTheme.amber
                    onSelected: value => studio.setOpt("omni_speed", String(value))
                }
                VfSelectField {
                    Layout.fillWidth: true
                    label: "Chất lượng"
                    options: [
                        { label: "Nghe thử · 16", value: "16" },
                        { label: "Narration · 32", value: "32" },
                        { label: "Tối đa · 64", value: "64" }
                    ]
                    value: String(studio.opts.omni_num_step || "32")
                    accent: VfTheme.cyan
                    onSelected: value => studio.setOpt("omni_num_step", String(value))
                }
                VfSelectField {
                    Layout.fillWidth: true
                    label: "Hậu kỳ"
                    options: [
                        { label: "Broadcast", value: "broadcast" },
                        { label: "Podcast", value: "podcast" },
                        { label: "Cinematic", value: "cinematic" },
                        { label: "Warm", value: "warm" },
                        { label: "Raw", value: "raw" }
                    ]
                    value: String(studio.opts.omni_effect_preset || "broadcast")
                    accent: "#10B981"
                    onSelected: value => studio.setOpt("omni_effect_preset", String(value))
                }
                CompactField {
                    label: "Seed"
                    value: String(studio.opts.omni_seed || "")
                    placeholder: "tự chọn"
                    onCommitted: value => studio.setOpt("omni_seed", value)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)
                ModePill {
                    text: studio.advancedOpen ? "Ẩn thông số nâng cao" : "Thông số nâng cao"
                    selected: studio.advancedOpen
                    onClicked: studio.advancedOpen = !studio.advancedOpen
                }
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: VfTheme.dp(28)
                    radius: VfTheme.dp(8)
                    color: VfTheme.surfaceSoft
                    border.color: VfTheme.borderSoft

                    Text {
                        anchors {
                            fill: parent
                            leftMargin: VfTheme.dp(10)
                            rightMargin: VfTheme.dp(10)
                        }
                        verticalAlignment: Text.AlignVCenter
                        text: studio.advancedOpen
                            ? "Đang mở cấu hình nâng cao"
                            : "CFG " + String(studio.opts.omni_guidance || "2.0")
                                + " · một request · giữ một mốc giọng cho toàn bài"
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                        elide: Text.ElideRight
                    }
                }
            }

            GridLayout {
                visible: studio.advancedOpen
                Layout.fillWidth: true
                columns: width >= VfTheme.dp(760) ? 3 : width >= VfTheme.dp(440) ? 2 : 1
                uniformCellWidths: true
                columnSpacing: VfTheme.dp(7)
                rowSpacing: VfTheme.dp(7)

                CompactField {
                    label: "CFG"
                    value: String(studio.opts.omni_guidance || "2.0")
                    placeholder: "2.0"
                    onCommitted: value => studio.setOpt("omni_guidance", value)
                }
                VfSelectField {
                    Layout.fillWidth: true
                    label: "Ngôn ngữ"
                    options: [
                        { label: "Tự nhận", value: "auto" },
                        { label: "Tiếng Việt", value: "vi" },
                        { label: "English", value: "en" },
                        { label: "中文", value: "zh" }
                    ]
                    value: String(studio.opts.omni_language || "auto")
                    accent: VfTheme.violet
                    onSelected: value => studio.setOpt("omni_language", String(value))
                }
                VfSelectField {
                    Layout.fillWidth: true
                    label: "Hỗ trợ Việt–Anh"
                    options: [
                        { label: "Tự sửa cách đọc", value: "1" },
                        { label: "Giữ nguyên văn bản", value: "0" }
                    ]
                    value: String(studio.opts.omni_auto_pronunciation || "1")
                    accent: "#10B981"
                    onSelected: value => studio.setOpt(
                        "omni_auto_pronunciation", String(value))
                }
            }

            LabeledTextField {
                visible: studio.advancedOpen
                Layout.fillWidth: true
                label: "Từ điển phát âm riêng · term=cách đọc, ngăn cách bằng dấu ;"
                value: String(studio.opts.omni_pronunciation_lexicon || "")
                placeholder: "VeoFlow=vi-ô-phờ-lâu; workflow=uốc-phờ-lâu; API=ây pi ai"
                onCommitted: value => studio.setOpt(
                    "omni_pronunciation_lexicon", value)
            }

        }
    }

    component SectionTitle: Text {
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontSmall
        font.weight: VfTheme.weightStrong
    }

    component ModePill: Rectangle {
        id: pill
        property string text: ""
        property bool selected: false
        signal clicked()
        implicitWidth: label.implicitWidth + VfTheme.dp(18)
        implicitHeight: VfTheme.dp(28)
        radius: VfTheme.dp(9)
        color: selected ? VfTheme.violetFill : VfTheme.surfaceSoft
        border.color: selected ? VfTheme.violet : VfTheme.borderBox
        Text {
            id: label
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

    component CompactField: ColumnLayout {
        id: field
        property string label: ""
        property string value: ""
        property string placeholder: ""
        signal committed(string value)
        Layout.fillWidth: true
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
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            selectByMouse: true
            onEditingFinished: field.committed(text.trim())
            background: FieldBackground { focused: parent.activeFocus }
        }
    }

    component LabeledTextField: ColumnLayout {
        id: labeledField
        property string label: ""
        property string value: ""
        property string placeholder: ""
        signal committed(string value)
        spacing: VfTheme.dp(2)
        Text {
            text: labeledField.label
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
        }
        TextField {
            Layout.fillWidth: true
            text: labeledField.value
            placeholderText: labeledField.placeholder
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            selectByMouse: true
            onEditingFinished: labeledField.committed(text.trim())
            background: FieldBackground { focused: parent.activeFocus }
        }
    }

    component FieldBackground: Rectangle {
        property bool focused: false
        radius: VfTheme.dp(7)
        color: VfTheme.surfaceSoft
        border.color: focused ? VfTheme.primary : VfTheme.borderBox
    }
}
