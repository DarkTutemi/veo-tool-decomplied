import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "AppIconRegistry.js" as AppIconRegistry
import "MediaSourceResolver.js" as MediaSourceResolver
import "../components"
import "../dialogs"
import "../theme"

Rectangle {
    id: root

    objectName: "masterFeatureToolbar"

    property var config: masterOptionsController.config || ({})
    readonly property var voiceOptions: (masterOptionsController.options || {}).voice_languages || []
    readonly property real featureControlHeight: VfTheme.dp(34)

    function cleanText(value) {
        var text = String(value || "").trim()
        text = text.replace(/^[\uD800-\uDBFF][\uDC00-\uDFFF]\uFE0F?\s*/, "")
        text = text.replace(/^[\u2600-\u27BF]\uFE0F?\s*/, "")
        return text.trim()
    }

    function flagPath(flagValue) {
        var raw = String(flagValue || "")
        if (!raw.length)
            return ""
        if (raw.indexOf(":/") === 0 || raw.indexOf("qrc:/") === 0 || raw.indexOf("file:/") === 0 || raw.indexOf("data:") === 0)
            return raw
        if (raw.indexOf("/") >= 0 || raw.indexOf("\\") >= 0)
            return Qt.resolvedUrl(raw)
        return Qt.resolvedUrl("../../assets/flags/" + raw + ".png")
    }

    function voiceLanguage() {
        return String(root.config.voice_language || root.config.voice_id || "none")
    }

    function currentVoiceOption() {
        var code = root.voiceLanguage()
        for (var i = 0; i < root.voiceOptions.length; i += 1) {
            var item = root.voiceOptions[i] || {}
            if (String(item.value || "") === code)
                return item
        }
        return root.voiceOptions.length > 0 ? (root.voiceOptions[0] || {}) : ({ label: (void i18n.revision, i18n.t("master.no_voice", "No voice")), value: "none", flag: "global" })
    }

    function voiceDisplayText() {
        var item = root.currentVoiceOption()
        return String(item.label || (void i18n.revision, i18n.t("master.no_voice", "No voice")))
    }

    function voiceOptionIndex() {
        var code = root.voiceLanguage()
        for (var i = 0; i < root.voiceOptions.length; i += 1) {
            if (String((root.voiceOptions[i] || {}).value || "") === code)
                return i
        }
        return 0
    }

    function inputMode() {
        return String(root.config.input_mode || "idea")
    }

    function scriptFormat() {
        return String((masterOptionsController.options || {}).script_format || root.config.script_format || "monologue")
    }

    function openSubtitleStudio() {
        subtitleStudioController.openForRoute(
            "master",
            root.config.subtitle_profile || ({}),
            {
                market: String(root.config.market || "global"),
                content_language: String(root.config.voice_language || "vi"),
                aspect_ratio: String(root.config.aspect_ratio || root.config.ratio || "16:9"),
                title: String(masterOptionsController.ideaText || "").split("\n")[0],
                idea: String(masterOptionsController.ideaText || ""),
                script: String(masterOptionsController.scriptText || ""),
                tone: String(root.config.tone || root.config.emotion || ""),
                platform: String(root.config.platform || "auto"),
                content_tags: root.config.content_tags || [],
                inherited: true
            })
    }

    function dialogueMode() {
        return Boolean((masterOptionsController.options || {}).dialogue_mode)
    }

    function voice2Language() {
        return String((masterOptionsController.options || {}).voice2_language || root.config.voice2_language || "none")
    }

    function currentVoice2Option() {
        var code = root.voice2Language()
        for (var i = 0; i < root.voiceOptions.length; i += 1) {
            var item = root.voiceOptions[i] || {}
            if (String(item.value || "") === code)
                return item
        }
        return root.voiceOptions.length > 0 ? (root.voiceOptions[0] || {}) : ({ label: (void i18n.revision, i18n.t("master.no_voice", "No voice")), value: "none", flag: "global" })
    }

    function voice2DisplayText() {
        var item = root.currentVoice2Option()
        return String(item.label || (void i18n.revision, i18n.t("master.no_voice", "No voice")))
    }

    function openConsistencyForTour() {
        masterLibControl.expanded = true
    }

    Layout.fillWidth: true
    implicitHeight: toolbarColumn.implicitHeight
    color: "transparent"
    border.width: 0

    ColumnLayout {
        id: toolbarColumn
        width: parent.width
        spacing: VfTheme.dp(8)

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: VfTheme.dp(46)
            radius: VfTheme.dp(10)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border
            border.width: 1
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(7)
                anchors.rightMargin: VfTheme.dp(7)
                spacing: VfTheme.dp(7)

                // Packed left cluster. RowLayout otherwise splits leftover
                // width across every child when TTS is hidden.
                Row {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: false
                    height: root.featureControlHeight
                    spacing: VfTheme.dp(7)

                // "Script Control" (Auto/Manual) đã gỡ: luôn chạy auto. Manual chỉ
                // giam job ở "sẵn sàng - chờ route" mà không cho xem/sửa/submit lại.

                VfChip {
                    anchors.verticalCenter: parent.verticalCenter
                    actionId: "master.feature.character_consistency"
                    text: masterLibControl.disclosureText(
                        root.cleanText((void i18n.revision, i18n.t("master.consistency_short", "Đồng nhất"))))
                    tooltip: masterLibControl.disclosureTooltip()
                    // Màu phản ánh ma trận thật; mũi tên trong nhãn phản ánh panel mở/đóng.
                    selected: masterLibControl.activeCategoryCount() > 0
                    accent: VfTheme.violet
                    minWidth: VfTheme.dp(108)
                    implicitHeight: root.featureControlHeight
                    onClicked: masterLibControl.togglePanel()
                }

                // "Người dẫn truyện" sống ở khu nhập Ý tưởng/Kịch bản (Step 1,
                // MasterPromptScreen) — nó thuộc về NỘI DUNG, không phải feature hậu kỳ.

                // Thinking + Script Architect are always-on by default (matching
                // legacy) — no toggle chips. Config defaults enforce true.

                VfToolbarSwitch {
                    anchors.verticalCenter: parent.verticalCenter
                    actionId: "master.feature.auto_merge_video"
                    text: root.cleanText((void i18n.revision, i18n.t("master.auto_merge_video", "Tự ghép video")))
                    tooltip: root.cleanText((void i18n.revision, i18n.t(
                        "master.auto_merge_tooltip",
                        "Tự động ghép các cảnh thành video hoàn chỉnh khi tạo xong.")))
                    checked: Boolean(root.config.auto_merge_video)
                    accent: "#10B981"
                    minWidth: VfTheme.dp(112)
                    implicitHeight: root.featureControlHeight
                    onToggled: function(enabled) {
                        masterOptionsController.setOption("auto_merge_video", enabled)
                    }
                }

                SubtitleWorkflowButton {
                    objectName: "masterSubtitleWorkflowButton"
                    anchors.verticalCenter: parent.verticalCenter
                    actionId: "master.feature.subtitle_workflow"
                    minWidth: VfTheme.dp(174)
                    controlHeight: root.featureControlHeight
                    profile: root.config.subtitle_profile || ({})
                    configuredLanguage: root.config.voice_language || "vi"
                    onClicked: root.openSubtitleStudio()
                }

                GroupLabel {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.cleanText((void i18n.revision, i18n.t("master.voice", "Language")))
                    neutral: false
                }

                // Voice language selector — chip-height inline combo so it lines
                // up with the chips (the old VfSelectField was field-height and
                // broke the row). Shows the per-language flag inline.
                Rectangle {
                    objectName: "masterVoiceLanguage"
                    anchors.verticalCenter: parent.verticalCenter
                    width: VfTheme.dp(168)
                    height: root.featureControlHeight
                    radius: VfTheme.radiusControl
                    color: VfTheme.surface
                    border.color: voiceLangCombo.activeFocus ? VfTheme.violet : VfTheme.borderStrong
                    border.width: 1
                    clip: true

                    ComboBox {
                        id: voiceLangCombo
                        anchors.fill: parent
                        model: root.voiceOptions // perf-lint: disable=R2 static voice-language catalog
                        textRole: "label"
                        valueRole: "value"
                        currentIndex: root.voiceOptionIndex()
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        onActivated: masterOptionsController.setOption("voice_language", voiceLangCombo.currentValue)

                        contentItem: Row {
                            anchors.left: parent.left
                            anchors.leftMargin: VfTheme.dp(9)
                            anchors.right: parent.right
                            anchors.rightMargin: VfTheme.dp(18)
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: VfTheme.dp(6)

                            Image {
                                anchors.verticalCenter: parent.verticalCenter
                                width: source.toString().length > 0 ? 18 : 0
                                height: source.toString().length > 0 ? 12 : 0
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                source: root.flagPath((root.currentVoiceOption() || {}).flag || "")
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: voiceLangCombo.displayText
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontControl
                                elide: Text.ElideRight
                            }
                        }

                        background: Rectangle { color: "transparent" }

                        indicator: Text {
                            x: voiceLangCombo.width - width - VfTheme.dp(6)
                            y: Math.round((voiceLangCombo.height - height) / 2)
                            text: "v"
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            font.weight: VfTheme.weightStrong
                        }

                        delegate: ItemDelegate {
                            width: voiceLangCombo.width
                            height: VfTheme.dp(28)
                            highlighted: voiceLangCombo.highlightedIndex === index
                            background: Rectangle {
                                color: parent.highlighted ? VfTheme.violetFill : VfTheme.surface
                                radius: VfTheme.dp(6)
                            }
                            contentItem: Row {
                                spacing: VfTheme.dp(6)
                                Image {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: source.toString().length > 0 ? 18 : 0
                                    height: source.toString().length > 0 ? 12 : 0
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    source: root.flagPath((modelData || {}).flag || "")
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: String((modelData || {}).label || "")
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontControl
                                }
                            }
                        }

                        popup: Popup {
                            y: voiceLangCombo.height + 4
                            width: voiceLangCombo.width
                            implicitHeight: Math.min(contentItem.implicitHeight + topPadding + bottomPadding, 280)
                            padding: VfTheme.dp(4)
                            contentItem: ListView { // perf-lint: disable=R1  ComboBox popup with 16 static voice languages — recycling pointless
                                clip: true
                                implicitHeight: contentHeight
                                model: voiceLangCombo.popup.visible ? voiceLangCombo.delegateModel : null
                                currentIndex: voiceLangCombo.highlightedIndex
                                ScrollIndicator.vertical: ScrollIndicator { }
                            }
                            background: Rectangle {
                                radius: VfTheme.radiusControl
                                color: VfTheme.surface
                                border.color: VfTheme.borderBox
                                border.width: 1
                            }
                        }
                    }
                }
                }

                SharedTtsInlinePanel {
                    objectName: "masterNarrationVoice"
                    visible: Boolean(root.config.enable_narrator)
                    Layout.fillWidth: visible
                    Layout.minimumWidth: visible ? VfTheme.dp(72) : 0
                    Layout.maximumWidth: visible ? -1 : 0
                    Layout.preferredHeight: root.featureControlHeight
                    Layout.maximumHeight: root.featureControlHeight
                    Layout.alignment: Qt.AlignVCenter
                    presentation: "compactBar"
                    contextLabel: "TTS"
                    selectionOnly: true
                    usageHintInStatus: true
                    usageHint: Boolean(root.config.enable_narrator)
                        ? (void i18n.revision, i18n.t(
                            "master.tts_narrator_on_hint",
                            "Người dẫn truyện dùng WAV TTS này cho job Master."))
                        : (void i18n.revision, i18n.t(
                            "master.tts_narrator_off_hint",
                            "Giọng dùng chung — bật Người dẫn truyện ở Step 1 để gắn vào job."))
                }
            }
        }

        MasterLibraryControl {
            id: masterLibControl
            Layout.fillWidth: true
        }
    }

    component GroupLabel: Rectangle {
        property string text: ""
        property bool neutral: true

        implicitWidth: Math.max(74, labelText.implicitWidth + 22)
        implicitHeight: root.featureControlHeight
        width: implicitWidth
        height: implicitHeight
        radius: VfTheme.radiusControl
        color: neutral ? VfTheme.surface : VfTheme.violetFill
        border.color: neutral ? VfTheme.borderStrong : VfTheme.violetBorderSoft
        border.width: 1

        Text {
            id: labelText
            anchors.centerIn: parent
            text: parent.text
            color: neutral ? VfTheme.textMuted : VfTheme.violetText
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontControl
            font.weight: Font.DemiBold
        }
    }

    component AssetActionButton: Rectangle {
        property string label: ""
        property string tooltip: ""
        property string tone: "neutral"

        signal clicked()

        readonly property string _iconName: {
            if (label === "▶" || label === "▷") return "chevron-right"
            if (label === "◀" || label === "◁") return "chevron-left"
            if (label === "✕" || label === "✗" || label === "×") return "cross-mark"
            if (label === "✓") return "check-mark-button"
            return ""
        }

        implicitWidth: VfTheme.dp(26)
        implicitHeight: VfTheme.dp(24)
        radius: VfTheme.dp(8)
        color: tone === "danger" ? VfTheme.redFill : VfTheme.surface
        border.color: tone === "danger" ? VfTheme.redBorderSoft : VfTheme.violetBorderSoft
        border.width: 1

        VfAppIcon {
            anchors.centerIn: parent
            name: parent._iconName
            size: VfTheme.dp(13)
            framed: false
            color: tone === "danger" ? "#DC2626" : "#7C3AED"
            visible: parent._iconName.length > 0
        }

        Text {
            anchors.centerIn: parent
            text: parent.label
            color: tone === "danger" ? "#DC2626" : "#7C3AED"
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
            font.weight: Font.DemiBold
            visible: parent._iconName.length === 0
        }

        ToolTip.visible: actionMouse.containsMouse && tooltip.length > 0
        ToolTip.text: tooltip
        ToolTip.delay: 350

        MouseArea {
            id: actionMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component SegmentButton: Rectangle {
        id: segmentRoot
        property string text: ""
        property bool selected: false
        property color accent: VfTheme.primary
        property string actionId: ""
        property int minWidth: VfTheme.dp(92)

        signal clicked()

        readonly property string resolvedIconName: AppIconRegistry.resolveActionIcon(actionId, text, "")

        implicitWidth: Math.max(minWidth, segmentRow.implicitWidth + 24)
        implicitHeight: VfTheme.chipHeight
        radius: VfTheme.radiusControl
        color: selected ? accent : VfTheme.surface
        border.color: selected ? accent : VfTheme.borderStrong
        border.width: 1

        Row {
            id: segmentRow
            anchors.centerIn: parent
            spacing: segmentIcon.visible ? 6 : 0

            VfAppIcon {
                id: segmentIcon
                name: segmentRoot.resolvedIconName
                size: VfTheme.dp(18)
                framed: false
                color: segmentRoot.selected ? "#FFFFFF" : (AppIconRegistry.iconColor(segmentRoot.resolvedIconName) || VfTheme.text)
                visible: name.length > 0
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: segmentText
                text: segmentRoot.text
                color: segmentRoot.selected ? "#FFFFFF" : VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                font.weight: segmentRoot.selected ? Font.DemiBold : Font.Medium
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
