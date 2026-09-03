import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

// Feature action bar for Voice Studio — mirrors MasterFeatureToolbar pattern.
// Visible only in video / image / animation modes (hidden in audio mode).
// Chips toggle voiceController.videoConfig options + character consistency
// (which lives in the shared masterOptionsController, same as other tabs).
Rectangle {
    id: root

    property string outputMode: voiceController.outputMode || "audio"
    property var videoConfig: voiceController.videoConfig || ({})
    property var masterConfig: masterOptionsController.config || ({})
    property var voiceLanguageOptions: (masterOptionsController.options || {}).voice_languages || []

    readonly property bool charEnabled: Boolean(root.masterConfig.character_consistency)

    signal toggleRequested(string key, bool value)     // voiceController.setVideoOption
    signal masterToggleRequested(string key, bool value) // masterOptionsController.setOption

    Layout.fillWidth: true
    visible: root.outputMode !== "audio"
    implicitHeight: visible ? (outerCol.implicitHeight + VfTheme.dp(14)) : 0
    radius: VfTheme.radiusPanel
    color: root.charEnabled ? VfTheme.violetFill : VfTheme.surfaceSoft
    border.color: root.charEnabled ? VfTheme.violetBorderSoft : VfTheme.borderBox
    border.width: 1

    ColumnLayout {
        id: outerCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: VfTheme.dp(8)
        spacing: VfTheme.dp(8)

        // ── Feature chips row ─────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(7)

            VfChip {
                actionId: "voice_studio.feature.character_consistency"
                text: (void i18n.revision, i18n.t("qml.master.library_control", "Điều khiển nhân vật, đồ vật, bối cảnh"))
                iconName: "busts-in-silhouette"
                selected: root.charEnabled
                accent: VfTheme.violet
                minWidth: VfTheme.dp(148)
                onClicked: root.masterToggleRequested("character_consistency", !root.charEnabled)
            }

            VfChip {
                actionId: "voice_studio.feature.deep_analysis"
                text: (void i18n.revision, i18n.t("voice_studio.deep_analysis", "Phân tích sâu"))
                iconName: "brain"
                selected: Boolean(root.videoConfig.deep_analysis)
                accent: VfTheme.cyan
                minWidth: VfTheme.dp(120)
                onClicked: root.toggleRequested("deep_analysis", !Boolean(root.videoConfig.deep_analysis))
            }

            VfChip {
                actionId: "voice_studio.feature.auto_merge"
                visible: root.outputMode === "video"
                text: (void i18n.revision, i18n.t("master.auto_merge_video", "Tự động ghép video"))
                iconName: "package"
                selected: Boolean(root.videoConfig.auto_merge)
                accent: VfTheme.amber
                minWidth: VfTheme.dp(152)
                onClicked: root.toggleRequested("auto_merge", !Boolean(root.videoConfig.auto_merge))
            }

            Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }

            // Voice language label + combo (AI narration language)
            Text {
                Layout.alignment: Qt.AlignVCenter
                text: (void i18n.revision, i18n.t("master.voice", "Voice"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.weight: VfTheme.weightStrong
            }

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(160)
                Layout.preferredHeight: VfTheme.chipHeight
                radius: VfTheme.radiusControl
                color: VfTheme.surface
                border.color: voiceLangCombo.activeFocus ? VfTheme.violet : VfTheme.borderStrong
                border.width: 1
                clip: true

                ComboBox {
                    id: voiceLangCombo
                    anchors.fill: parent
                    model: root.voiceLanguageOptions
                    textRole: "label"
                    valueRole: "value"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    currentIndex: {
                        var cur = String(root.masterConfig.voice_language || "none")
                        for (var i = 0; i < root.voiceLanguageOptions.length; i++) {
                            if (String((root.voiceLanguageOptions[i] || {}).value || "") === cur)
                                return i
                        }
                        return 0
                    }
                    onActivated: masterOptionsController.setOption("voice_language", voiceLangCombo.currentValue)

                    contentItem: Text {
                        anchors.left: parent.left
                        anchors.leftMargin: VfTheme.dp(9)
                        anchors.right: parent.right
                        anchors.rightMargin: VfTheme.dp(18)
                        anchors.verticalCenter: parent.verticalCenter
                        text: voiceLangCombo.displayText
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        elide: Text.ElideRight
                    }

                    background: Item {}
                    indicator: VfAppIcon {
                        anchors.right: parent.right
                        anchors.rightMargin: VfTheme.dp(6)
                        anchors.verticalCenter: parent.verticalCenter
                        name: "down-arrow"
                        size: VfTheme.dp(12)
                        framed: false
                        color: VfTheme.textMuted
                    }
                }
            }
        }

        // ── Ref-limit hint ────────────────────────────────────────────────────
        Text {
            Layout.fillWidth: true
            visible: root.charEnabled
            text: {
                var lim = voiceController.referenceLimits()
                return (void i18n.revision, i18n.t("voice_studio.ref_limit_hint", "Ảnh tham chiếu tối đa: %1 · Nhân vật: %2"))
                    .replace("%1", String(lim.reference_images))
                    .replace("%2", String(lim.character_references))
            }
            color: VfTheme.violetText
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            font.weight: VfTheme.weightStrong
        }

    }
}
