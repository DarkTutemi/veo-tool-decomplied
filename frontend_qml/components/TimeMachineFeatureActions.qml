pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root
    objectName: "timeMachineFeatureActions"

    property var controller: null

    signal subtitleStudioRequested()
    signal graphicsStudioRequested()

    readonly property var config: root.controller
        ? (root.controller.config || ({})) : ({})
    readonly property var options: root.controller
        ? (root.controller.options || ({})) : ({})
    // A Flow does not normalize child heights. VfButton.compact is 28dp,
    // VfChip is 32dp and VfToolbarSwitch is 34dp, so this row used to look
    // visibly uneven. Keep compact typography/padding, but lock every action
    // surface to the app's standard control height.
    readonly property int featureControlHeight: VfTheme.controlHeight
    readonly property bool graphicsEnabled: String(
        (root.config.sequence_graphics || ({})).mode || "auto") !== "off"
    property bool graphicsTogglePending: false
    property bool requestedGraphicsEnabled: true
    readonly property bool effectiveGraphicsEnabled: root.graphicsTogglePending
        ? root.requestedGraphicsEnabled : root.graphicsEnabled

    Timer {
        id: graphicsToggleSettle
        interval: 0
        repeat: false
        onTriggered: root.graphicsTogglePending = false
    }

    onGraphicsEnabledChanged: root.graphicsTogglePending = false

    function graphicsProfileLabel() {
        var profile = root.config.sequence_graphics || ({})
        var mode = String(profile.mode || "auto")
        if (mode === "off")
            return "TẮT"
        if (mode !== "locked")
            return "AI TỰ CHỌN"
        var selected = String(profile.preset_id || "auto")
        var rows = root.options.graphics_presets || []
        for (var i = 0; i < rows.length; ++i) {
            if (String(rows[i].value || "") === selected)
                return String(rows[i].label || selected)
        }
        return selected === "auto" ? "AI TỰ CHỌN" : selected
    }

    function setGraphicsEnabled(enabled) {
        if (!root.controller)
            return
        root.requestedGraphicsEnabled = Boolean(enabled)
        root.graphicsTogglePending = true
        if (root.controller.setGraphicsEnabled) {
            var toggleResult = root.controller.setGraphicsEnabled(Boolean(enabled))
            if (!(toggleResult && toggleResult.ok))
                root.graphicsTogglePending = false
            else
                graphicsToggleSettle.restart()
            return
        }
        var current = root.config.sequence_graphics || ({})
        var maps = current.maps || ({})
        var variation = current.variation || ({})
        var locale = current.locale || ({})
        var signature = String(current.signature_id || "auto")
        var preset = String(current.preset_id || "auto")
        var nextMode = enabled
            ? (signature !== "auto" ? "locked" : "auto") : "off"
        var result = root.controller.setOption("sequence_graphics", {
            version: String(current.version || "1.1"),
            mode: nextMode,
            preset_id: nextMode === "auto" ? "auto" : preset,
            signature_id: nextMode === "auto" ? "auto" : signature,
            density: String(current.density || "balanced"),
            variation: {
                enabled: variation.enabled === undefined
                    ? true : Boolean(variation.enabled),
                seed: Number(variation.seed || 0)
            },
            timeline: { enabled: Boolean(enabled) },
            maps: {
                enabled: false,
                preset_id: String(maps.preset_id || "route_minimal")
            },
            locale: {
                language: String(locale.language || "content_config"),
                market: String(locale.market || "content_config")
            }
        })
        if (!(result && result.ok))
            root.graphicsTogglePending = false
        else
            graphicsToggleSettle.restart()
    }

    function subtitleProfileLabel() {
        var profile = root.config.subtitle_profile || ({})
        var mode = String(profile.mode || "auto")
        if (mode === "off")
            return "TẮT"
        var preset = String(profile.preset_id || "documentary")
        return mode === "locked" ? preset : "AI TỰ CHỌN"
    }

    Layout.fillWidth: true
    implicitHeight: featureFlow.implicitHeight + VfTheme.dp(14)
    radius: VfTheme.dp(9)
    color: VfTheme.surfaceSoft
    border.color: VfTheme.border
    border.width: 1

    Flow {
        id: featureFlow
        objectName: "timeMachineFeatureActionsFlow"
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
            objectName: "timeMachineNarrationToggle"
            actionId: "timemachine.narration"
            text: "Lời dẫn"
            tooltip: checked
                ? "AI viết lời dẫn theo storyboard và tạo giọng đọc."
                : "Không viết lời dẫn và không tạo TTS cho job."
            checked: Boolean(root.config.narration_enabled)
            accent: VfTheme.cyan
            minWidth: VfTheme.dp(112)
            implicitHeight: root.featureControlHeight
            onToggled: function(enabled) {
                if (root.controller)
                    root.controller.setOption("narration_enabled", enabled)
            }
        }

        SubtitleWorkflowButton {
            objectName: "timeMachineSubtitleWorkflowButton"
            actionId: "timemachine.subtitle_workflow"
            minWidth: VfTheme.dp(174)
            controlHeight: root.featureControlHeight
            profile: root.config.subtitle_profile || ({})
            configuredLanguage: root.config.content_language || root.config.language || "vi"
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
            model: [
                { label: "AUTO", value: "auto" },
                { label: "50%", value: "half" },
                { label: "TẮT", value: "off" }
            ]

            delegate: VfChip {
                required property var modelData
                minWidth: VfTheme.dp(54)
                implicitHeight: root.featureControlHeight
                showLeadingIcon: false
                text: String(modelData.label || "")
                selected: String(root.config.native_audio_mode || "auto")
                    === String(modelData.value || "auto")
                accent: VfTheme.cyan
                tooltip: "Mức giữ âm thanh gốc của các clip Veo."
                onClicked: {
                    if (root.controller)
                        root.controller.setOption(
                            "native_audio_mode", String(modelData.value || "auto"))
                }
            }
        }

        VfToolbarSwitch {
            objectName: "timeMachineGraphicsToggle"
            actionId: "timemachine.graphics_toggle"
            text: "Đồ họa"
            tooltip: checked
                ? "Chèn Sequence Graphics vào video sau picture-lock."
                : "Giữ nguyên video, không chèn Sequence Graphics."
            checked: root.effectiveGraphicsEnabled
            accent: VfTheme.violet
            minWidth: VfTheme.dp(112)
            implicitHeight: root.featureControlHeight
            onToggled: function(enabled) {
                root.setGraphicsEnabled(enabled)
            }
        }

        VfButton {
            objectName: "timemachine.graphics_configure"
            actionId: "timemachine.graphics_configure"
            iconName: "artist-palette"
            compact: true
            minWidth: VfTheme.dp(112)
            implicitHeight: root.featureControlHeight
            text: "CẤU HÌNH"
            enabled: root.effectiveGraphicsEnabled
            tooltip: root.effectiveGraphicsEnabled
                ? "Đang dùng: " + root.graphicsProfileLabel()
                    + ". Mở thư viện Sequence Graphics."
                : "Bật Đồ họa trước khi mở cấu hình."
            onClicked: root.graphicsStudioRequested()
        }

    }
}
