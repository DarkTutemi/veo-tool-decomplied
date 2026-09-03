pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "../theme"

// One compact, route-owned post-production strip. Affiliate authors its own
// narration and timed subtitles; external Audio/SRT inputs do not belong here.
Rectangle {
    id: root
    objectName: "affiliateFeatureActions"

    property var config: ({})

    signal optionRequested(string key, var value)
    signal subtitleStudioRequested()

    readonly property int featureControlHeight: VfTheme.controlHeight

    function nativeAudioControlHeight(index) {
        var item = nativeAudioModeRepeater.itemAt(index)
        return item ? Number(item.height || 0) : 0
    }

    Layout.fillWidth: true
    implicitHeight: featureFlow.implicitHeight + VfTheme.dp(14)
    radius: VfTheme.dp(9)
    color: VfTheme.surfaceSoft
    border.color: VfTheme.border
    border.width: 1

    Flow {
        id: featureFlow
        objectName: "affiliateFeatureActionsFlow"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: VfTheme.dp(7)
        spacing: VfTheme.dp(7)

        Text {
            height: root.featureControlHeight
            text: "TÍNH NĂNG JOB"
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(9)
            font.weight: Font.Bold
            verticalAlignment: Text.AlignVCenter
        }

        VfToolbarSwitch {
            objectName: "affiliateNarrationToggle"
            actionId: "affiliate.narration"
            text: "Lời dẫn"
            checked: Boolean((root.config || {}).enable_narrator)
            accent: VfTheme.cyan
            minWidth: VfTheme.dp(112)
            implicitHeight: root.featureControlHeight
            tooltip: checked
                ? "Tạo lời dẫn và TTS cho video Affiliate."
                : "Giữ thoại/âm thanh Veo, không tạo người dẫn chuyện."
            onToggled: enabled => root.optionRequested("enable_narrator", enabled)
        }

        SubtitleWorkflowButton {
            objectName: "affiliateSubtitleWorkflowButton"
            actionId: "affiliate.subtitle_workflow"
            minWidth: VfTheme.dp(174)
            controlHeight: root.featureControlHeight
            profile: (root.config || {}).subtitle_profile || ({})
            configuredLanguage: (root.config || {}).voice_language
                || (root.config || {}).language || "vi"
            onClicked: root.subtitleStudioRequested()
        }

        Text {
            height: root.featureControlHeight
            text: "ÂM VEO"
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(8)
            font.weight: Font.Bold
            verticalAlignment: Text.AlignVCenter
        }

        Repeater {
            id: nativeAudioModeRepeater
            objectName: "affiliateNativeAudioModeRepeater"
            model: [
                { label: "AUTO", value: "auto" },
                { label: "50%", value: "half" },
                { label: "TẮT", value: "off" }
            ]

            delegate: VfChip {
                required property var modelData
                objectName: "affiliateNativeAudioChip_" + String(modelData.value || "")
                minWidth: VfTheme.dp(56)
                implicitHeight: root.featureControlHeight
                showLeadingIcon: false
                text: String(modelData.label || "")
                selected: String((root.config || {}).native_audio_mode || "auto")
                    === String(modelData.value || "auto")
                accent: VfTheme.cyan
                tooltip: "Mức giữ thoại, ambience và SFX gốc của clip Veo."
                onClicked: root.optionRequested(
                    "native_audio_mode", String(modelData.value || "auto"))
            }
        }

    }
}
