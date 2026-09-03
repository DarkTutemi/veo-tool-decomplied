pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Templates as T

import "../components"
import "../theme"

Dialog {
    id: dialog
    objectName: "sequenceGraphicsStudioDialog"
    parent: Overlay.overlay
    modal: true
    anchors.centerIn: parent
    width: Math.min(
        parent ? parent.width - VfTheme.dp(28) : VfTheme.dp(1450),
        VfTheme.dp(1450))
    height: Math.min(
        parent ? parent.height - VfTheme.dp(28) : VfTheme.dp(860),
        VfTheme.dp(860))
    padding: 0
    closePolicy: Popup.CloseOnEscape

    // qmllint disable unqualified
    readonly property var controller: sequenceGraphicsController
    // qmllint enable unqualified
    readonly property var draft: controller.draft || ({})
    readonly property var previewStyle: controller.previewPreset || ({})
    readonly property var subtitlePreview: controller.subtitlePreview || ({})
    readonly property var previewCanvasPlan: subtitlePreview.canvas || ({
        width: 1920, height: 1080, aspect: "16:9"
    })
    readonly property var socialSafeZonePlan: subtitlePreview.safe_zone || ({})
    readonly property var socialSafeBounds:
        socialSafeZonePlan.content_bounds || ({
            left: 0.04, top: 0.04, right: 0.96, bottom: 0.96
        })
    readonly property var socialReservedOverlays:
        socialSafeZonePlan.reserved_overlays || []
    readonly property var socialPreviewLayer:
        socialSafeZonePlan.preview_layer || ({})
    readonly property string socialSafeZoneValue: String(
        socialSafeZonePlan.requested_platform
            || socialSafeZonePlan.platform || "none")
    readonly property string socialOverlayAssetName: String(
        socialPreviewLayer.asset_name || "")
    readonly property url socialOverlayAssetSource:
        socialPlatformChromeVisible && socialOverlayAssetName.length > 0
            ? Qt.resolvedUrl("../../resources/subtitle_studio/"
                + socialOverlayAssetName)
            : ""
    readonly property bool portraitCanvas: String(
        previewCanvasPlan.aspect || "16:9") === "9:16"
    readonly property bool socialGuideVisible: portraitCanvas
        && socialSafeZoneValue !== "none"
    readonly property bool socialPlatformChromeVisible: portraitCanvas
        && (String(socialPreviewLayer.mode || "") === "platform_asset"
            || String(socialPreviewLayer.mode || "") === "combined_asset")
        && socialOverlayAssetName.length > 0
    readonly property bool combinedSocialGuideVisible: portraitCanvas
        && socialGuideVisible
        && (socialSafeZoneValue === "auto"
            || socialSafeZoneValue === "average")
    readonly property bool combinedSocialReservedVisible:
        combinedSocialGuideVisible && socialReservedOverlays.length > 0
    readonly property string activeRoute: String(
        controller.activeRoute || "timemachine")
    readonly property bool timelineAvailable: activeRoute === "timemachine"
    readonly property string activePreset: String(draft.preset_id || "auto")
    readonly property string activeSignature: String(
        draft.signature_id || "auto")
    readonly property string activeMode: String(draft.mode || "auto")
    readonly property string density: String(draft.density || "balanced")
    readonly property int variationSeed: Number(controller.variationSeed || 0)
    readonly property bool graphicsEnabled: activeMode !== "off"
    readonly property bool timelineEnabled: timelineAvailable && graphicsEnabled
        && Boolean((draft.timeline || {}).enabled)
    readonly property var waveform: draft.waveform || ({})
    readonly property bool waveformEnabled: graphicsEnabled
        && Boolean(waveform.enabled)
    readonly property string waveformStyle: String(waveform.style || "auto")
    readonly property string waveformLength: String(waveform.length || "auto")
    readonly property string waveformPosition: String(waveform.position || "auto")
    readonly property string waveformIntensity: String(
        waveform.intensity || "balanced")
    readonly property var waveformLayout: controller.waveformLayout || ({})
    readonly property var timelineLayout: controller.timelineLayout || ({})
    readonly property string previewAspectRatio: String(
        previewCanvasPlan.aspect || subtitlePreview.aspect_ratio || "16:9")
    readonly property real previewCanvasAspect: {
        var raw = String(dialog.previewAspectRatio || "16:9").replace("/", ":")
        if (raw === "9:16")
            return 9 / 16
        if (raw === "1:1")
            return 1
        if (raw === "4:3")
            return 4 / 3
        return 16 / 9
    }
    readonly property int waveformSeed: Number(
        controller.waveformSeed || variationSeed || 7919)
    readonly property var waveformStyleOptions: timelineAvailable ? [
        {label: qsTr("Ngẫu nhiên theo seed"), value: "auto"},
        {label: qsTr("Timeline · Đường liền"), value: "wave_line"},
        {label: qsTr("Timeline · Dải kép"), value: "twin_ribbon"},
        {label: qsTr("Timeline · Peak bars"), value: "peak_bars"},
        {label: qsTr("Timeline · Một phía"), value: "one_sided"},
        {label: qsTr("Timeline · Chấm biên độ"), value: "dot_trace"},
        {label: qsTr("Timeline · Capsule"), value: "capsule_chain"},
        {label: qsTr("Timeline · Nhịp tim"), value: "heartbeat_trace"},
        {label: qsTr("Timeline · Khối bậc"), value: "stepped_blocks"},
        {label: qsTr("Timeline · Stereo ribbon"), value: "stereo_ribbon"},
        {label: qsTr("Timeline · LED phân đoạn"), value: "segmented_led"},
        {label: qsTr("Timeline · Sóng phản chiếu"), value: "reflection_wave"},
        {label: qsTr("Timeline · Kim dao động"), value: "needle_ticks"},
        {label: qsTr("Timeline · Kênh trái phải"), value: "split_channel"},
        {label: qsTr("Visualizer · Equalizer"), value: "live_equalizer"},
        {label: qsTr("Visualizer · Phổ đối xứng"), value: "mirror_spectrum"},
        {label: qsTr("Visualizer · Oscilloscope"), value: "oscilloscope"},
        {label: qsTr("Visualizer · 3 dải tần"), value: "three_band"},
        {label: qsTr("Visualizer · Beat pulse"), value: "beat_pulse"},
        {label: qsTr("Visualizer · Voice meter"), value: "voice_meter"},
        {label: qsTr("Visualizer · Cột phổ"), value: "spectral_columns"},
        {label: qsTr("Visualizer · Ma trận chấm"), value: "dot_matrix"},
        {label: qsTr("Visualizer · Quỹ đạo"), value: "radial_orbit"},
        {label: qsTr("Visualizer · LED spectrum"), value: "led_spectrum"},
        {label: qsTr("Visualizer · Dải octave"), value: "octave_bands"},
        {label: qsTr("Visualizer · Radial spectrum"), value: "radial_spectrum"},
        {label: qsTr("Visualizer · Radial hướng tâm"), value: "radial_invert"},
        {label: qsTr("Visualizer · Phổ phản chiếu"), value: "spectrum_reflection"},
        {label: qsTr("Visualizer · Waterfall"), value: "waterfall"},
        {label: qsTr("Visualizer · Peak hold"), value: "peak_hold"},
        {label: qsTr("Visualizer · Hạt dao động"), value: "particle_spine"}
    ] : [
        {label: qsTr("Ngẫu nhiên theo seed"), value: "auto"},
        {label: qsTr("Đường liền"), value: "wave_line"},
        {label: qsTr("Dải kép"), value: "twin_ribbon"},
        {label: qsTr("Peak bars"), value: "peak_bars"},
        {label: qsTr("Sóng một phía"), value: "one_sided"},
        {label: qsTr("Chấm biên độ"), value: "dot_trace"},
        {label: qsTr("Chuỗi capsule"), value: "capsule_chain"},
        {label: qsTr("Nhịp tim"), value: "heartbeat_trace"},
        {label: qsTr("Khối bậc"), value: "stepped_blocks"},
        {label: qsTr("Stereo ribbon"), value: "stereo_ribbon"},
        {label: qsTr("LED phân đoạn"), value: "segmented_led"},
        {label: qsTr("Sóng phản chiếu"), value: "reflection_wave"},
        {label: qsTr("Kim dao động"), value: "needle_ticks"},
        {label: qsTr("Kênh trái phải"), value: "split_channel"},
        {label: qsTr("Equalizer"), value: "live_equalizer"},
        {label: qsTr("Phổ đối xứng"), value: "mirror_spectrum"},
        {label: qsTr("Oscilloscope"), value: "oscilloscope"},
        {label: qsTr("3 dải tần"), value: "three_band"},
        {label: qsTr("Beat pulse"), value: "beat_pulse"},
        {label: qsTr("Voice meter"), value: "voice_meter"},
        {label: qsTr("Cột phổ"), value: "spectral_columns"},
        {label: qsTr("Ma trận chấm"), value: "dot_matrix"},
        {label: qsTr("Quỹ đạo"), value: "radial_orbit"},
        {label: qsTr("LED spectrum"), value: "led_spectrum"},
        {label: qsTr("Dải octave"), value: "octave_bands"},
        {label: qsTr("Radial spectrum"), value: "radial_spectrum"},
        {label: qsTr("Radial hướng tâm"), value: "radial_invert"},
        {label: qsTr("Phổ phản chiếu"), value: "spectrum_reflection"},
        {label: qsTr("Waterfall"), value: "waterfall"},
        {label: qsTr("Peak hold"), value: "peak_hold"},
        {label: qsTr("Hạt dao động"), value: "particle_spine"}
    ]
    readonly property var waveformLengthOptions: [
        {label: qsTr("Tự chọn"), value: "auto"},
        {label: qsTr("Toàn chiều rộng"), value: "full"},
        {label: qsTr("Nửa khung"), value: "half"}
    ]
    readonly property var waveformPositionOptions: [
        {label: qsTr("Tự chọn an toàn"), value: "auto"},
        {label: qsTr("Cạnh trên"), value: "top"},
        {label: qsTr("Cạnh dưới"), value: "bottom"},
        {label: qsTr("Trên trái"), value: "top_left"},
        {label: qsTr("Trên phải"), value: "top_right"},
        {label: qsTr("Dưới trái"), value: "bottom_left"},
        {label: qsTr("Dưới phải"), value: "bottom_right"},
        {label: qsTr("Kéo trực tiếp"), value: "custom"}
    ]
    readonly property var waveformIntensityOptions: [
        {label: qsTr("Nhẹ"), value: "subtle"},
        {label: qsTr("Cân bằng"), value: "balanced"},
        {label: qsTr("Mạnh"), value: "strong"}
    ]
    readonly property color previewAccent: "#" + colorHex(
        localTimelineAccentHex.length ? localTimelineAccentHex
            : String(previewStyle.accent || "4E8CFF"))
    readonly property color previewSecondary: "#" + colorHex(
        localTimelineSecondaryHex.length ? localTimelineSecondaryHex
            : String(previewStyle.secondary || "7C5CFC"))
    readonly property color previewPrimary: "#" + colorHex(
        localTimelinePrimaryHex.length ? localTimelinePrimaryHex
            : String(previewStyle.primary || "FFFFFF"))
    readonly property color previewMuted: "#" + String(
        previewStyle.muted || "C9D4E5")
    readonly property color previewPanel: "#" + String(
        previewStyle.panel || "101827")
    readonly property color previewPanelAlt: "#" + String(
        previewStyle.panel_alt || "171F30")
    readonly property string visualSystemId: String(
        previewStyle.visual_system_id || "cinematic_chronicle")
    readonly property string visualMaterial: String(
        previewStyle.material || "transparent_overlay")
    readonly property string timelineGrammar: String(
        previewStyle.timeline_grammar || "data_nodes")
    readonly property string compositionGrammar: String(
        previewStyle.composition_grammar || "radial_clock")
    readonly property string motionGrammar: String(
        previewStyle.motion_grammar || "precision_build")
    readonly property int markerCount: density === "minimal"
        ? 3 : (density === "editorial" ? 5 : 4)
    property string searchText: ""
    property string categoryFilter: "all"
    property bool showBefore: false
    property bool showSubtitlePreview: true
    readonly property bool subtitlesEnabled: Boolean(subtitlePreview.enabled)
    readonly property bool subtitlePreviewVisible: subtitlesEnabled
        && showSubtitlePreview && !showBefore
    readonly property color subtitleTextColor: "#" + String(
        subtitlePreview.text_hex || "FFFFFF")
    readonly property color subtitleAccentColor: "#" + String(
        subtitlePreview.accent_hex || "4E8CFF")
    readonly property color subtitleFillColor: "#" + String(
        subtitlePreview.fill_hex || "080B12")
    property string localError: ""
    property real previewProgress: 0
    property string configTab: "graphic"
    readonly property string activeSignatureHint: {
        var rows = dialog.controller.signatureSelectOptions || []
        var id = String(dialog.activeSignature || "auto")
        for (var i = 0; i < rows.length; ++i) {
            if (String(rows[i].value) === id)
                return String(rows[i].description || "")
        }
        return String(dialog.previewStyle.description || "")
    }
    property bool waveformCustomExpanded: true
    property string activeWaveformColorRole: "accent_hex"
    property real localWaveformThickness: 1.0
    property real localWaveformAmplitude: 1.0
    property real localWaveformGlow: 1.0
    property real localWaveformWidth: 0.0
    property real localWaveformX: -1.0
    property real localWaveformY: -1.0
    property string localWaveformAccentHex: ""
    property string localWaveformSecondaryHex: ""
    property bool timelineCustomExpanded: true
    property string customColorTarget: "wave"
    property string localTimelineAccentHex: ""
    property string localTimelineSecondaryHex: ""
    property string localTimelinePrimaryHex: ""
    property string localTimelineFontRole: "display"
    property real localTimelineFontScale: 1.0
    property real localTimelineGlow: 0.0
    property real localTimelineShadow: 0.0
    property bool localTimelineMirror: false
    property real localTimelineRailY: -1.0
    property real localTimelineX: -1.0
    property real localTimelineY: -1.0
    property string selectedTimelineTextRole: "heading"
    property string localTimelineTextColorHex: ""
    readonly property var waveformCustom: waveform.custom || ({})
    readonly property bool waveformCustomEnabled: Boolean(waveformCustom.enabled)
    readonly property var timelineCustom: (draft.timeline || {}).custom || ({})
    readonly property bool timelineCustomEnabled: Boolean(timelineCustom.enabled)
    readonly property var timelineTextStyles: timelineCustom.text_styles || ({})
    readonly property var timelineFontOptions: [
        {label: qsTr("Be Vietnam"), value: "display"},
        {label: qsTr("Noto Serif"), value: "editorial"},
        {label: qsTr("IBM Plex"), value: "data"},
        {label: qsTr("Barlow"), value: "condensed"},
        {label: qsTr("Be Vietnam Bold"), value: "rounded"}
    ]
    readonly property color effectiveWaveformAccent: "#" + colorHex(
        localWaveformAccentHex.length ? localWaveformAccentHex
            : String(previewStyle.accent || "4E8CFF"))
    readonly property color effectiveWaveformSecondary: "#" + colorHex(
        localWaveformSecondaryHex.length ? localWaveformSecondaryHex
            : String(previewStyle.secondary || "7C5CFC"))

    onOpened: {
        showSubtitlePreview = true
        configTab = dialog.timelineAvailable ? "graphic" : "wave"
        syncWaveformCustom()
        syncTimelineCustom()
    }

    onTimelineAvailableChanged: {
        if (!timelineAvailable)
            configTab = "wave"
    }

    function colorHex(value) {
        var clean = String(value || "").replace("#", "").toUpperCase()
        return clean.length >= 6 ? clean.slice(clean.length - 6) : "FFFFFF"
    }

    function syncWaveformCustom() {
        var custom = dialog.waveformCustom || ({})
        localWaveformThickness = Number(custom.thickness_scale || 1.0)
        localWaveformAmplitude = Number(custom.amplitude_scale || 1.0)
        localWaveformGlow = Number(custom.glow_scale === undefined
            ? 1.0 : custom.glow_scale)
        localWaveformWidth = Number(custom.width_ratio || 0.0)
        localWaveformX = Number(custom.x_norm === undefined ? -1.0 : custom.x_norm)
        localWaveformY = Number(custom.y_norm === undefined ? -1.0 : custom.y_norm)
        localWaveformAccentHex = String(custom.accent_hex || "")
        localWaveformSecondaryHex = String(custom.secondary_hex || "")
    }

    function commitWaveformCustom(field, value) {
        var patch = {}
        patch[String(field)] = value
        controller.patchWaveformCustom(patch)
    }

    function openWaveformColor(role, currentColor) {
        customColorTarget = "wave"
        activeWaveformColorRole = String(role || "accent_hex")
        waveformColorDialog.selectedColor = currentColor
        waveformColorDialog.open()
    }

    function syncTimelineCustom() {
        var custom = dialog.timelineCustom || ({})
        localTimelineAccentHex = String(custom.accent_hex || "")
        localTimelineSecondaryHex = String(custom.secondary_hex || "")
        localTimelinePrimaryHex = String(custom.primary_hex || "")
        localTimelineFontRole = String(custom.font_role || "display")
        localTimelineFontScale = Number(custom.font_scale || 1.0)
        localTimelineGlow = Number(custom.glow_scale || 0.0)
        localTimelineShadow = Number(custom.shadow_scale || 0.0)
        localTimelineMirror = Boolean(custom.mirror)
        localTimelineRailY = Number(custom.rail_y === undefined
            ? -1.0 : custom.rail_y)
        localTimelineX = Number(custom.x_norm === undefined
            ? -1.0 : custom.x_norm)
        localTimelineY = Number(custom.y_norm === undefined
            ? -1.0 : custom.y_norm)
        syncTimelineTextSelection()
    }

    function timelineTextRoleLabel(role) {
        if (String(role) === "event")
            return qsTr("Sự kiện")
        if (String(role) === "axis")
            return qsTr("Mốc năm")
        return qsTr("Tiêu đề")
    }

    function timelineTextFallbackColor(role) {
        if (String(role) === "heading")
            return dialog.previewAccent
        if (String(role) === "axis")
            return dialog.previewMuted
        return dialog.previewPrimary
    }

    function timelineTextStyle(role) {
        return (dialog.timelineTextStyles || ({}))[String(role)] || ({})
    }

    function syncTimelineTextSelection() {
        var row = timelineTextStyle(dialog.selectedTimelineTextRole)
        localTimelineFontRole = String(row.font_role
            || (dialog.selectedTimelineTextRole === "axis" ? "data" : "display"))
        localTimelineFontScale = Number(row.font_scale || 1.0)
        localTimelineGlow = Number(row.glow_scale || 0.0)
        localTimelineShadow = Number(row.shadow_scale || 0.0)
        localTimelineTextColorHex = String(row.color_hex || "")
    }

    function selectTimelineTextRole(role) {
        var requested = String(role || "heading")
        if (["heading", "event", "axis"].indexOf(requested) < 0)
            requested = "heading"
        selectedTimelineTextRole = requested
        syncTimelineTextSelection()
        configTab = "graphic"
    }

    function timelineTextValue(role, field, fallback) {
        if (String(role) === dialog.selectedTimelineTextRole) {
            if (String(field) === "font_role")
                return dialog.localTimelineFontRole
            if (String(field) === "font_scale")
                return dialog.localTimelineFontScale
            if (String(field) === "glow_scale")
                return dialog.localTimelineGlow
            if (String(field) === "shadow_scale")
                return dialog.localTimelineShadow
            if (String(field) === "color_hex")
                return dialog.localTimelineTextColorHex
        }
        var row = timelineTextStyle(role)
        return row[field] === undefined || row[field] === "" ? fallback : row[field]
    }

    function timelineTextColor(role) {
        var value = String(timelineTextValue(role, "color_hex", ""))
        return value.length > 0 ? "#" + colorHex(value)
            : timelineTextFallbackColor(role)
    }

    function commitTimelineTextStyle(field, value) {
        var source = dialog.timelineTextStyles || ({})
        var next = ({})
        var roles = ["heading", "event", "axis"]
        for (var i = 0; i < roles.length; ++i) {
            var role = roles[i]
            var row = source[role] || ({})
            next[role] = {
                font_role: String(row.font_role
                    || (role === "axis" ? "data" : "display")),
                font_scale: Number(row.font_scale || 1.0),
                color_hex: String(row.color_hex || ""),
                glow_scale: Number(row.glow_scale || 0.0),
                shadow_scale: Number(row.shadow_scale || 0.0)
            }
        }
        next[dialog.selectedTimelineTextRole][String(field)] = value
        dialog.controller.patchTimelineCustom({text_styles: next})
    }

    function commitTimelineCustom(field, value) {
        var patch = {}
        patch[String(field)] = value
        controller.patchTimelineCustom(patch)
    }

    function openTimelineColor(role, currentColor) {
        customColorTarget = "rail"
        activeWaveformColorRole = String(role || "accent_hex")
        waveformColorDialog.selectedColor = currentColor
        waveformColorDialog.open()
    }

    function openTimelineTextColor(currentColor) {
        customColorTarget = "timeline_text"
        waveformColorDialog.selectedColor = currentColor
        waveformColorDialog.open()
    }

    Connections {
        target: dialog.controller
        function onDraftChanged() {
            if (!waveformThicknessSlider.editing
                    && !waveformAmplitudeSlider.editing
                    && !waveformWidthSlider.editing
                    && !waveformGlowSlider.editing)
                dialog.syncWaveformCustom()
            if (!timelineFontScaleSlider.editing
                    && !timelineGlowSlider.editing
                    && !timelineShadowSlider.editing
                    && !timelineRailYSlider.editing)
                dialog.syncTimelineCustom()
        }
    }

    component WaveformCustomSlider: RowLayout {
        id: customSlider
        property string title: ""
        property real minimum: 0
        property real maximum: 1
        property real stepSize: 0.05
        property real currentValue: 0
        property int decimals: 2
        property color accent: VfTheme.cyan
        readonly property bool editing: waveformSlider.pressed
            || numericInput.activeFocus
        signal previewed(real value)
        signal committed(real value)
        spacing: VfTheme.dp(7)
        implicitHeight: VfTheme.dp(32)
        Layout.preferredHeight: implicitHeight

        Text {
            Layout.preferredWidth: VfTheme.dp(66)
            text: customSlider.title
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(8)
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Timer {
            id: keyboardCommit
            interval: 140
            onTriggered: customSlider.committed(waveformSlider.value)
        }

        T.Slider {
            id: waveformSlider
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(26)
            from: customSlider.minimum
            to: customSlider.maximum
            stepSize: customSlider.stepSize
            value: customSlider.currentValue
            background: Rectangle {
                x: waveformSlider.leftPadding
                y: waveformSlider.topPadding
                    + (waveformSlider.availableHeight - height) / 2
                implicitWidth: VfTheme.dp(150)
                implicitHeight: VfTheme.dp(3)
                width: waveformSlider.availableWidth
                height: implicitHeight
                radius: height / 2
                color: VfTheme.borderStrong
                Rectangle {
                    width: waveformSlider.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: customSlider.accent
                }
            }
            handle: Rectangle {
                x: waveformSlider.leftPadding
                    + waveformSlider.visualPosition
                        * (waveformSlider.availableWidth - width)
                y: waveformSlider.topPadding
                    + (waveformSlider.availableHeight - height) / 2
                implicitWidth: VfTheme.dp(13)
                implicitHeight: VfTheme.dp(13)
                radius: width / 2
                color: customSlider.accent
                border.width: 2
                border.color: VfTheme.surface
            }
            onMoved: {
                customSlider.previewed(value)
                if (!pressed)
                    keyboardCommit.restart()
            }
            onPressedChanged: {
                if (!pressed) {
                    keyboardCommit.stop()
                    customSlider.committed(value)
                }
            }
        }

        TextField {
            id: numericInput
            Layout.preferredWidth: VfTheme.dp(43)
            Layout.preferredHeight: VfTheme.dp(24)
            text: Number(customSlider.currentValue).toFixed(customSlider.decimals)
            horizontalAlignment: Text.AlignHCenter
            selectByMouse: true
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(8)
            padding: 1
            validator: DoubleValidator {
                bottom: customSlider.minimum
                top: customSlider.maximum
                decimals: customSlider.decimals
            }
            background: Rectangle {
                radius: VfTheme.dp(4)
                color: VfTheme.surface
                border.color: numericInput.activeFocus
                    ? customSlider.accent : VfTheme.border
            }
            onEditingFinished: {
                var bounded = Math.max(customSlider.minimum,
                    Math.min(customSlider.maximum, Number(text)))
                customSlider.previewed(bounded)
                customSlider.committed(bounded)
            }
        }
    }

    ColorDialog {
        id: waveformColorDialog
        title: dialog.activeWaveformColorRole === "secondary_hex"
            ? qsTr("Màu phụ waveform")
            : (dialog.customColorTarget === "timeline_text"
                ? qsTr("Màu chữ · %1").arg(
                    dialog.timelineTextRoleLabel(dialog.selectedTimelineTextRole))
                : qsTr("Màu chính waveform"))
        onAccepted: {
            var hex = dialog.colorHex(selectedColor)
            var role = dialog.activeWaveformColorRole
            if (dialog.customColorTarget === "timeline_text") {
                dialog.localTimelineTextColorHex = hex
                dialog.commitTimelineTextStyle("color_hex", hex)
                return
            }
            if (dialog.customColorTarget === "rail") {
                if (role === "secondary_hex")
                    dialog.localTimelineSecondaryHex = hex
                else if (role === "primary_hex")
                    dialog.localTimelinePrimaryHex = hex
                else
                    dialog.localTimelineAccentHex = hex
                dialog.commitTimelineCustom(role, hex)
                return
            }
            if (role === "secondary_hex")
                dialog.localWaveformSecondaryHex = hex
            else
                dialog.localWaveformAccentHex = hex
            dialog.commitWaveformCustom(role, hex)
        }
    }

    onPreviewProgressChanged: controller.setPreviewProgress(previewProgress)

    NumberAnimation on previewProgress {
        from: 0
        to: 1
        duration: dialog.motionGrammar === "calm_dissolve" ? 7200
            : (dialog.motionGrammar === "kinetic_push" ? 4300
                : (dialog.motionGrammar === "playful_pulse" ? 5000 : 5800))
        loops: Animation.Infinite
        running: dialog.visible && dialog.graphicsEnabled
            && (dialog.timelineEnabled || dialog.waveformEnabled)
            && !dialog.showBefore
    }

    function motionEnvelope(progress) {
        var edge = 0.14
        if (progress < edge)
            return progress / edge
        if (progress > 1 - edge)
            return (1 - progress) / edge
        return 1
    }

    function presetMatches(row) {
        var query = dialog.searchText.trim().toLowerCase()
        var category = String((row || {}).category || "all")
        if (dialog.categoryFilter !== "all") {
            var groups = {
                minimal: ["minimal"],
                glow: ["neon", "nodes", "signal"],
                marks: ["dots", "dashes", "ticks", "segments"],
                dual: ["dual"]
            }
            if ((groups[dialog.categoryFilter] || []).indexOf(category) < 0)
                return false
        }
        if (!query.length)
            return true
        var haystack = [
            String((row || {}).label || ""),
            String((row || {}).description || ""),
            String((row || {}).recommended_for || ""),
            String((row || {}).timeline_label || ""),
            String((row || {}).motion_label || "")
        ].join(" ").toLowerCase()
        return haystack.indexOf(query) >= 0
    }

    function markerYear(index) {
        var rows = dialog.markerCount === 3
            ? ["1800", "1946", "Hiện tại"]
            : (dialog.markerCount === 4
                ? ["1800", "1900", "1946", "Hiện tại"]
                : ["1800", "1850", "1946", "2000", "Hiện tại"])
        return rows[Math.max(0, Math.min(rows.length - 1, index))]
    }

    function markerLabel(index) {
        var rows = dialog.markerCount === 3
            ? ["Khởi đầu", "Bước ngoặt", "Ngày nay"]
            : (dialog.markerCount === 4
                ? ["Khởi đầu", "Chuyển dịch", "Bước ngoặt", "Ngày nay"]
                : ["Khởi đầu", "Giai đoạn 2", "Bước ngoặt", "Mở rộng", "Ngày nay"])
        return rows[Math.max(0, Math.min(rows.length - 1, index))]
    }

    header: Rectangle {
        implicitHeight: VfTheme.dp(66)
        color: VfTheme.surface
        border.color: VfTheme.border

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(18)
            anchors.rightMargin: VfTheme.dp(14)
            spacing: VfTheme.dp(12)

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(42)
                Layout.preferredHeight: VfTheme.dp(42)
                radius: VfTheme.dp(12)
                color: VfTheme.violetFill
                VfAppIcon {
                    anchors.centerIn: parent
                    name: "timer"
                    size: VfTheme.dp(22)
                    color: VfTheme.violetText
                }
            }

            ColumnLayout {
                spacing: 1
                Text {
                    text: dialog.timelineAvailable
                        ? "SEQUENCE GRAPHICS" : "AUDIO VISUALIZER"
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(17)
                    font.weight: Font.Bold
                }
                Text {
                    text: dialog.timelineAvailable
                        ? "Thiết kế lớp thông tin theo nhịp video sau picture-lock"
                        : "Sóng âm PCM thật cho video Audio to Video · timeline đã tắt"
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9.5)
                }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: VfTheme.dp(7)
                Repeater {
                    model: dialog.timelineAvailable
                        ? ["Chọn thanh", "Xem trước", "Áp dụng"]
                        : ["Chọn sóng", "Xem trước", "Áp dụng"]
                    delegate: RowLayout {
                        id: stepDelegate
                        required property var modelData
                        required property int index
                        spacing: VfTheme.dp(6)
                        Rectangle {
                            Layout.preferredWidth: VfTheme.dp(27)
                            Layout.preferredHeight: VfTheme.dp(27)
                            radius: width / 2
                            color: stepDelegate.index === 0
                                ? VfTheme.violet : VfTheme.surfaceSoft
                            border.color: stepDelegate.index === 0
                                ? VfTheme.violet : VfTheme.borderStrong
                            Text {
                                anchors.centerIn: parent
                                text: String(stepDelegate.index + 1)
                                color: stepDelegate.index === 0
                                    ? "#FFFFFF" : VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                font.weight: Font.Bold
                            }
                        }
                        Text {
                            text: String(stepDelegate.modelData)
                            color: stepDelegate.index === 0
                                ? VfTheme.text : VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(9.5)
                            font.weight: stepDelegate.index === 0
                                ? Font.DemiBold : Font.Normal
                        }
                        Rectangle {
                            visible: stepDelegate.index < 2
                            Layout.preferredWidth: VfTheme.dp(28)
                            Layout.preferredHeight: 1
                            color: VfTheme.borderStrong
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            VfButton {
                compact: true
                minWidth: VfTheme.dp(36)
                text: "×"
                tooltip: "Đóng"
                showLeadingIcon: false
                onClicked: dialog.close()
            }
        }
    }

    background: Rectangle {
        color: VfTheme.canvas
        radius: VfTheme.dp(13)
        border.color: VfTheme.borderStrong
    }

    contentItem: ColumnLayout {
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: VfTheme.dp(12)
            spacing: VfTheme.dp(12)

            Rectangle {
                objectName: "sequenceGraphicsSidebar"
                Layout.preferredWidth: dialog.timelineAvailable
                    ? Math.min(VfTheme.dp(370), Math.max(
                        VfTheme.dp(310), dialog.width * 0.27))
                    : VfTheme.dp(300)
                Layout.minimumWidth: dialog.timelineAvailable
                    ? VfTheme.dp(300) : VfTheme.dp(280)
                Layout.fillHeight: true
                radius: VfTheme.dp(10)
                color: VfTheme.surface
                border.color: VfTheme.border

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    spacing: VfTheme.dp(8)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)
                        visible: dialog.timelineAvailable
                        VfChip {
                            objectName: "sequenceGraphicTab"
                            Layout.fillWidth: true
                            minWidth: 0
                            text: qsTr("Graphic")
                            selected: dialog.configTab === "graphic"
                            accent: VfTheme.violet
                            showLeadingIcon: false
                            onClicked: dialog.configTab = "graphic"
                        }
                        VfChip {
                            objectName: "sequenceWaveTab"
                            Layout.fillWidth: true
                            minWidth: 0
                            text: qsTr("Sóng")
                            selected: dialog.configTab === "wave"
                            accent: VfTheme.violet
                            showLeadingIcon: false
                            onClicked: dialog.configTab = "wave"
                        }
                    }

                    VfSelectField {
                        id: presetList
                        objectName: "graphicsPresetLibrary"
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(52)
                        Layout.minimumHeight: VfTheme.dp(52)
                        Layout.maximumHeight: VfTheme.dp(52)
                        fieldHeight: VfTheme.dp(52)
                        popupMinWidth: width
                        label: qsTr("Kiểu timeline")
                        options: dialog.controller.signatureSelectOptions
                        value: dialog.activeSignature
                        accent: VfTheme.violet
                        visible: dialog.timelineAvailable
                            && dialog.configTab === "graphic"
                        onSelected: value => dialog.controller.selectSignature(
                            String(value || "auto"))
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: dialog.timelineAvailable
                            && dialog.configTab === "graphic"
                            && dialog.activeSignatureHint.length > 0
                        text: dialog.activeSignatureHint
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(9)
                        wrapMode: Text.WordWrap
                    }

                    Rectangle {
                        id: timelineCustomPanel
                        objectName: "timelineCustomPanel"
                        readonly property bool contentFits:
                            timelineCustomContent.implicitHeight <= height + 0.5
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: timelineCustomContent.implicitHeight
                        visible: dialog.timelineAvailable
                            && dialog.configTab === "graphic"
                            && dialog.timelineEnabled
                        color: "transparent"
                        border.width: 0

                        ColumnLayout {
                            id: timelineCustomContent
                            anchors.fill: parent
                            spacing: VfTheme.dp(8)

                            Rectangle {
                                objectName: "timelineRealtimeHeader"
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(38)
                                radius: VfTheme.dp(8)
                                color: VfTheme.violetFill
                                border.color: dialog.timelineCustomEnabled
                                    ? VfTheme.violetBorder : VfTheme.border

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(9)
                                    anchors.rightMargin: VfTheme.dp(6)
                                    spacing: VfTheme.dp(6)
                                    Text {
                                        Layout.fillWidth: true
                                        text: qsTr("THANH · PREVIEW REALTIME")
                                        color: VfTheme.violetText
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(8)
                                        font.weight: Font.Bold
                                    }
                                    VfButton {
                                        compact: true
                                        minWidth: VfTheme.dp(48)
                                        text: qsTr("Reset")
                                        showLeadingIcon: false
                                        enabled: dialog.timelineCustomEnabled
                                        onClicked: dialog.controller.resetTimelineCustom()
                                    }
                                }
                            }

                            Rectangle {
                                objectName: "timelineTypographySection"
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(126)
                                radius: VfTheme.dp(8)
                                color: VfTheme.surfaceSoft
                                border.color: VfTheme.border

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(8)
                                    spacing: VfTheme.dp(4)
                                    Text {
                                        Layout.fillWidth: true
                                        text: qsTr("KIỂU CHỮ · %1").arg(
                                            dialog.timelineTextRoleLabel(
                                                dialog.selectedTimelineTextRole).toUpperCase())
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(8)
                                        font.weight: Font.Bold
                                    }
                                    VfSelectField {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: VfTheme.dp(50)
                                        Layout.minimumHeight: VfTheme.dp(50)
                                        fieldHeight: VfTheme.dp(50)
                                        label: qsTr("Font")
                                        options: dialog.timelineFontOptions
                                        value: dialog.localTimelineFontRole
                                        accent: VfTheme.violet
                                        onSelected: value => {
                                            dialog.localTimelineFontRole = value
                                            dialog.commitTimelineTextStyle("font_role", value)
                                        }
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: VfTheme.dp(6)
                                        Repeater {
                                            model: [
                                                {label: qsTr("Tiêu đề"), value: "heading"},
                                                {label: qsTr("Sự kiện"), value: "event"},
                                                {label: qsTr("Mốc năm"), value: "axis"}
                                            ]
                                            delegate: VfChip {
                                                id: fontRoleChip
                                                required property var modelData
                                                Layout.fillWidth: true
                                                minWidth: 0
                                                text: fontRoleChip.modelData.label
                                                objectName: "sequenceTimelineTextRole_"
                                                    + fontRoleChip.modelData.value
                                                selected: dialog.selectedTimelineTextRole
                                                    === fontRoleChip.modelData.value
                                                accent: VfTheme.violet
                                                showLeadingIcon: false
                                                fontPixelSize: VfTheme.dp(7.5)
                                                onClicked: {
                                                    dialog.selectTimelineTextRole(
                                                        fontRoleChip.modelData.value)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                objectName: "timelineShapeSection"
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(170)
                                radius: VfTheme.dp(8)
                                color: VfTheme.surfaceSoft
                                border.color: VfTheme.border

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(8)
                                    spacing: VfTheme.dp(2)
                                    Text {
                                        Layout.fillWidth: true
                                        text: qsTr("HÌNH DÁNG")
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(8)
                                        font.weight: Font.Bold
                                    }
                                    WaveformCustomSlider {
                                        id: timelineFontScaleSlider
                                        objectName: "timelineFontScaleSlider"
                                        Layout.fillWidth: true
                                        title: qsTr("Cỡ chữ")
                                        accent: VfTheme.violet
                                        minimum: 0.70
                                        maximum: 1.60
                                        stepSize: 0.05
                                        currentValue: dialog.localTimelineFontScale
                                        onPreviewed: value => dialog.localTimelineFontScale = value
                                        onCommitted: value => dialog.commitTimelineTextStyle(
                                            "font_scale", value)
                                    }
                                    WaveformCustomSlider {
                                        id: timelineGlowSlider
                                        objectName: "timelineGlowSlider"
                                        Layout.fillWidth: true
                                        title: qsTr("Glow")
                                        accent: VfTheme.violet
                                        minimum: 0.0
                                        maximum: 2.0
                                        stepSize: 0.05
                                        currentValue: dialog.localTimelineGlow
                                        onPreviewed: value => dialog.localTimelineGlow = value
                                        onCommitted: value => dialog.commitTimelineTextStyle(
                                            "glow_scale", value)
                                    }
                                    WaveformCustomSlider {
                                        id: timelineShadowSlider
                                        objectName: "timelineShadowSlider"
                                        Layout.fillWidth: true
                                        title: qsTr("Shadow")
                                        accent: VfTheme.violet
                                        minimum: 0.0
                                        maximum: 2.0
                                        stepSize: 0.05
                                        currentValue: dialog.localTimelineShadow
                                        onPreviewed: value => dialog.localTimelineShadow = value
                                        onCommitted: value => dialog.commitTimelineTextStyle(
                                            "shadow_scale", value)
                                    }
                                    WaveformCustomSlider {
                                        id: timelineRailYSlider
                                        objectName: "timelineRailYSlider"
                                        Layout.fillWidth: true
                                        title: qsTr("Cao rail")
                                        accent: VfTheme.violet
                                        minimum: 0.72
                                        maximum: 0.95
                                        stepSize: 0.01
                                        currentValue: dialog.localTimelineRailY >= 0
                                            ? dialog.localTimelineRailY
                                            : Number(dialog.previewStyle.rail_y || 0.91)
                                        onPreviewed: value => dialog.localTimelineRailY = value
                                        onCommitted: value => dialog.commitTimelineCustom(
                                            "rail_y", value)
                                    }
                                }
                            }

                            Rectangle {
                                objectName: "timelineColorsSection"
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(72)
                                radius: VfTheme.dp(8)
                                color: VfTheme.surfaceSoft
                                border.color: VfTheme.border

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(8)
                                    spacing: VfTheme.dp(5)
                                    Text {
                                        Layout.fillWidth: true
                                        text: qsTr("MÀU SẮC")
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(8)
                                        font.weight: Font.Bold
                                    }
                                    GridLayout {
                                        Layout.fillWidth: true
                                        columns: 3
                                        columnSpacing: VfTheme.dp(5)
                                        Repeater {
                                            model: [
                                                {label: qsTr("Accent"), role: "accent_hex",
                                                 color: dialog.previewAccent},
                                                {label: qsTr("Phụ"), role: "secondary_hex",
                                                 color: dialog.previewSecondary},
                                                {label: dialog.timelineTextRoleLabel(
                                                    dialog.selectedTimelineTextRole),
                                                 role: "text_color_hex",
                                                 color: dialog.timelineTextColor(
                                                    dialog.selectedTimelineTextRole)}
                                            ]
                                            delegate: Rectangle {
                                                id: timelineColorCard
                                                required property var modelData
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: VfTheme.dp(36)
                                                radius: VfTheme.dp(6)
                                                color: VfTheme.surface
                                                border.color: VfTheme.border
                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: VfTheme.dp(6)
                                                    Rectangle {
                                                        Layout.preferredWidth: VfTheme.dp(17)
                                                        Layout.preferredHeight: VfTheme.dp(17)
                                                        radius: VfTheme.dp(4)
                                                        color: timelineColorCard.modelData.color
                                                    }
                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: timelineColorCard.modelData.label
                                                        color: VfTheme.text
                                                        font.family: VfTheme.fontFamily
                                                        font.pixelSize: VfTheme.dp(8)
                                                    }
                                                }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (timelineColorCard.modelData.role
                                                                === "text_color_hex") {
                                                            dialog.openTimelineTextColor(
                                                                timelineColorCard.modelData.color)
                                                            return
                                                        }
                                                        dialog.openTimelineColor(
                                                            timelineColorCard.modelData.role,
                                                            timelineColorCard.modelData.color)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                objectName: "timelineOptionsSection"
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(102)
                                radius: VfTheme.dp(8)
                                color: VfTheme.surfaceSoft
                                border.color: VfTheme.border

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(8)
                                    spacing: VfTheme.dp(5)
                                    Text {
                                        Layout.fillWidth: true
                                        text: qsTr("TÙY CHỌN")
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(8)
                                        font.weight: Font.Bold
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: VfTheme.dp(31)
                                        Text {
                                            Layout.fillWidth: true
                                            text: qsTr("Gương")
                                            color: VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(8.5)
                                            font.weight: Font.DemiBold
                                        }
                                        Text {
                                            text: dialog.localTimelineMirror
                                                ? qsTr("Bật") : qsTr("Tắt")
                                            color: VfTheme.textMuted
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(8)
                                        }
                                        VfToolbarSwitch {
                                            Layout.preferredWidth: VfTheme.dp(42)
                                            Layout.preferredHeight: VfTheme.dp(28)
                                            minWidth: VfTheme.dp(42)
                                            implicitHeight: VfTheme.dp(28)
                                            showLabel: false
                                            accent: VfTheme.violet
                                            checked: dialog.localTimelineMirror
                                            tooltip: checked
                                                ? qsTr("Tắt gương") : qsTr("Bật gương")
                                            onToggled: function(nextChecked) {
                                                dialog.localTimelineMirror = nextChecked
                                                dialog.commitTimelineCustom(
                                                    "mirror", nextChecked)
                                            }
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: VfTheme.dp(31)
                                        radius: VfTheme.dp(6)
                                        color: VfTheme.surface
                                        border.color: VfTheme.border
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: VfTheme.dp(6)
                                            Text {
                                                text: qsTr("Vùng an toàn")
                                                color: VfTheme.text
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.dp(8)
                                                font.weight: Font.DemiBold
                                            }
                                            Item { Layout.fillWidth: true }
                                            Rectangle {
                                                Layout.preferredWidth: VfTheme.dp(32)
                                                Layout.preferredHeight: VfTheme.dp(18)
                                                radius: VfTheme.dp(5)
                                                color: dialog.subtitlesEnabled
                                                    ? VfTheme.greenFill : VfTheme.surfaceSoft
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: dialog.subtitlesEnabled
                                                        ? qsTr("BẬT") : qsTr("TẮT")
                                                    color: dialog.subtitlesEnabled
                                                        ? VfTheme.greenText : VfTheme.textMuted
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.dp(7)
                                                    font.weight: Font.Bold
                                                }
                                            }
                                            Text {
                                                text: qsTr("Phụ đề trên timeline")
                                                color: VfTheme.textMuted
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.dp(7.5)
                                            }
                                        }
                                    }
                                }
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }

                    Rectangle {
                        objectName: "transcriptWaveformOnlyNotice"
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(62)
                        visible: !dialog.timelineAvailable
                        radius: VfTheme.dp(9)
                        color: VfTheme.cyanFill
                        border.color: VfTheme.cyanBorder

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(9)
                            spacing: VfTheme.dp(3)
                            Text {
                                Layout.fillWidth: true
                                text: qsTr("AUDIO TO VIDEO · CHỈ SÓNG ÂM")
                                color: VfTheme.cyanText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(9)
                                font.weight: Font.Bold
                            }
                            Text {
                                Layout.fillWidth: true
                                text: qsTr("Timeline sự kiện và bản đồ bị khóa. Sóng lấy trực tiếp từ PCM sau khi Tự động ghép video hoàn tất.")
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8.5)
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Rectangle {
                        id: waveformControls
                        objectName: "waveformGraphicsControls"
                        readonly property real contentPadding: 0
                        readonly property bool contentFits: waveformControlsContent.implicitHeight
                            + contentPadding * 2 <= height + 0.5
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: Math.ceil(
                            waveformControlsContent.implicitHeight
                            + contentPadding * 2)
                        visible: !dialog.timelineAvailable
                            || dialog.configTab === "wave"
                        color: "transparent"
                        border.width: 0

                        ColumnLayout {
                            id: waveformControlsContent
                            anchors.fill: parent
                            anchors.margins: waveformControls.contentPadding
                            spacing: VfTheme.dp(8)

                            Rectangle {
                                objectName: "waveformEnableSection"
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(88)
                                radius: VfTheme.dp(8)
                                color: VfTheme.surfaceSoft
                                border.color: dialog.waveformEnabled
                                    ? VfTheme.cyanBorder : VfTheme.border

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(8)
                                    spacing: VfTheme.dp(6)
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: VfTheme.dp(6)
                                        Text {
                                            Layout.fillWidth: true
                                            text: qsTr("SÓNG ÂM · 18 KIỂU")
                                            color: VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(9)
                                            font.weight: Font.Bold
                                        }
                                        VfToolbarSwitch {
                                            id: waveformSwitch
                                            actionId: "waveformEnabledSwitch"
                                            Layout.preferredWidth: VfTheme.dp(42)
                                            Layout.preferredHeight: VfTheme.dp(28)
                                            minWidth: VfTheme.dp(42)
                                            implicitHeight: VfTheme.dp(28)
                                            showLabel: false
                                            accent: VfTheme.violet
                                            checked: dialog.waveformEnabled
                                            tooltip: checked
                                                ? qsTr("Tắt sóng âm")
                                                : qsTr("Bật sóng âm")
                                            onToggled: function(nextChecked) {
                                                dialog.localError = ""
                                                var result = dialog.controller.patchDraft(
                                                    "waveform.enabled", nextChecked)
                                                if (!(result && result.ok))
                                                    dialog.localError = String(
                                                        (result || {}).message
                                                        || qsTr("Không thể đổi trạng thái sóng âm"))
                                            }
                                        }
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: VfTheme.dp(6)
                                        VfButton {
                                            Layout.fillWidth: true
                                            compact: true
                                            minWidth: 0
                                            text: qsTr("Đổi seed")
                                            iconName: "counterclockwise-arrows-button"
                                            enabled: dialog.waveformEnabled
                                            tooltip: qsTr("Đổi hình thức; giữ nguyên biên độ audio")
                                            onClicked: dialog.controller.rerollWaveform()
                                        }
                                        VfButton {
                                            objectName: "waveformCustomButton"
                                            Layout.fillWidth: true
                                            compact: true
                                            minWidth: 0
                                            text: qsTr("Reset sóng")
                                            tone: "neutral"
                                            enabled: dialog.waveformCustomEnabled
                                            showLeadingIcon: false
                                            onClicked: dialog.controller.resetWaveformCustom()
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                objectName: "waveformLayoutSection"
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(145)
                                radius: VfTheme.dp(8)
                                color: VfTheme.surfaceSoft
                                border.color: VfTheme.border

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(8)
                                    spacing: VfTheme.dp(5)
                                    Text {
                                        Layout.fillWidth: true
                                        text: qsTr("KIỂU & BỐ CỤC")
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(8)
                                        font.weight: Font.Bold
                                    }
                                    GridLayout {
                                        Layout.fillWidth: true
                                        columns: 2
                                        columnSpacing: VfTheme.dp(8)
                                        rowSpacing: VfTheme.dp(6)
                                        VfSelectField {
                                            objectName: "waveformStyleSelect"
                                            Layout.fillWidth: true
                                            Layout.minimumHeight: fieldHeight
                                            Layout.preferredHeight: fieldHeight
                                            fieldHeight: VfTheme.dp(50)
                                            popupMinWidth: width
                                            label: qsTr("Kiểu sóng")
                                            options: dialog.waveformStyleOptions
                                            value: dialog.waveformStyle
                                            accent: VfTheme.cyan
                                            enabled: dialog.waveformEnabled
                                            onSelected: value => dialog.controller.patchDraft(
                                                "waveform.style", value)
                                        }
                                        VfSelectField {
                                            objectName: "waveformLengthSelect"
                                            Layout.fillWidth: true
                                            Layout.minimumHeight: fieldHeight
                                            Layout.preferredHeight: fieldHeight
                                            fieldHeight: VfTheme.dp(50)
                                            popupMinWidth: width
                                            label: qsTr("Chiều dài")
                                            options: dialog.waveformLengthOptions
                                            value: dialog.waveformLength
                                            accent: VfTheme.cyan
                                            enabled: dialog.waveformEnabled
                                            onSelected: value => dialog.controller.setWaveformLength(
                                                String(value))
                                        }
                                        VfSelectField {
                                            objectName: "waveformPositionSelect"
                                            Layout.fillWidth: true
                                            Layout.minimumHeight: fieldHeight
                                            Layout.preferredHeight: fieldHeight
                                            fieldHeight: VfTheme.dp(50)
                                            popupMinWidth: width
                                            label: qsTr("Vị trí")
                                            options: dialog.waveformPositionOptions
                                            value: dialog.waveformPosition
                                            accent: VfTheme.cyan
                                            enabled: dialog.waveformEnabled
                                            onSelected: value => dialog.controller.patchDraft(
                                                "waveform.position", value)
                                        }
                                        VfSelectField {
                                            objectName: "waveformIntensitySelect"
                                            Layout.fillWidth: true
                                            Layout.minimumHeight: fieldHeight
                                            Layout.preferredHeight: fieldHeight
                                            fieldHeight: VfTheme.dp(50)
                                            popupMinWidth: width
                                            label: qsTr("Cường độ")
                                            options: dialog.waveformIntensityOptions
                                            value: dialog.waveformIntensity
                                            accent: VfTheme.cyan
                                            enabled: dialog.waveformEnabled
                                            onSelected: value => dialog.controller.patchDraft(
                                                "waveform.intensity", value)
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: waveformCustomPanel
                                objectName: "waveformCustomPanel"
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(220)
                                Layout.minimumHeight: VfTheme.dp(220)
                                visible: true
                                radius: VfTheme.dp(8)
                                color: VfTheme.surfaceSoft
                                border.color: dialog.waveformCustomEnabled
                                    ? VfTheme.cyanBorder : VfTheme.border

                                ColumnLayout {
                                    id: waveformCustomContent
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(8)
                                    spacing: VfTheme.dp(4)

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: VfTheme.dp(28)
                                        Layout.maximumHeight: VfTheme.dp(28)
                                        spacing: VfTheme.dp(5)
                                        Text {
                                            Layout.fillWidth: true
                                            text: qsTr("CUSTOM · PREVIEW REALTIME")
                                            color: VfTheme.cyanText
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(8)
                                            font.weight: Font.Bold
                                        }
                                        VfButton {
                                            compact: true
                                            minWidth: VfTheme.dp(48)
                                            text: qsTr("Reset")
                                            showLeadingIcon: false
                                            enabled: dialog.waveformCustomEnabled
                                            onClicked: dialog.controller.resetWaveformCustom()
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: VfTheme.dp(4)

                                        WaveformCustomSlider {
                                            id: waveformThicknessSlider
                                            objectName: "waveformThicknessSlider"
                                            Layout.fillWidth: true
                                            title: qsTr("Độ dày")
                                            minimum: 0.45
                                            maximum: 3.0
                                            stepSize: 0.05
                                            currentValue: dialog.localWaveformThickness
                                            onPreviewed: value => dialog.localWaveformThickness = value
                                            onCommitted: value => dialog.commitWaveformCustom(
                                                "thickness_scale", value)
                                        }
                                        WaveformCustomSlider {
                                            id: waveformAmplitudeSlider
                                            objectName: "waveformAmplitudeSlider"
                                            Layout.fillWidth: true
                                            title: qsTr("Chiều cao")
                                            minimum: 0.40
                                            maximum: 2.0
                                            stepSize: 0.05
                                            currentValue: dialog.localWaveformAmplitude
                                            onPreviewed: value => dialog.localWaveformAmplitude = value
                                            onCommitted: value => dialog.commitWaveformCustom(
                                                "amplitude_scale", value)
                                        }
                                        WaveformCustomSlider {
                                            id: waveformWidthSlider
                                            objectName: "waveformWidthSlider"
                                            Layout.fillWidth: true
                                            title: qsTr("Chiều dài")
                                            minimum: 0.20
                                            maximum: 0.98
                                            stepSize: 0.01
                                            currentValue: dialog.localWaveformWidth > 0
                                                ? dialog.localWaveformWidth
                                                : (dialog.waveformLength === "half" ? 0.46 : 0.98)
                                            onPreviewed: value => dialog.localWaveformWidth = value
                                            onCommitted: value => dialog.commitWaveformCustom(
                                                "width_ratio", value)
                                        }
                                        WaveformCustomSlider {
                                            id: waveformGlowSlider
                                            objectName: "waveformGlowSlider"
                                            Layout.fillWidth: true
                                            title: qsTr("Phát sáng")
                                            minimum: 0.0
                                            maximum: 2.0
                                            stepSize: 0.05
                                            currentValue: dialog.localWaveformGlow
                                            onPreviewed: value => dialog.localWaveformGlow = value
                                            onCommitted: value => dialog.commitWaveformCustom(
                                                "glow_scale", value)
                                        }
                                    }

                                }
                            }

                            Rectangle {
                                objectName: "waveformColorsSection"
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(76)
                                radius: VfTheme.dp(8)
                                color: VfTheme.surfaceSoft
                                border.color: VfTheme.border

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(8)
                                    spacing: VfTheme.dp(5)
                                    Text {
                                        Layout.fillWidth: true
                                        text: qsTr("MÀU SẮC")
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(8)
                                        font.weight: Font.Bold
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: VfTheme.dp(6)
                                        Repeater {
                                            model: [
                                                {label: qsTr("Màu chính"), role: "accent_hex",
                                                 color: dialog.effectiveWaveformAccent},
                                                {label: qsTr("Màu phụ"), role: "secondary_hex",
                                                 color: dialog.effectiveWaveformSecondary}
                                            ]
                                            delegate: Rectangle {
                                                id: waveformColorCard
                                                required property var modelData
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: VfTheme.dp(38)
                                                radius: VfTheme.dp(6)
                                                color: VfTheme.surface
                                                border.color: VfTheme.border
                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: VfTheme.dp(6)
                                                    Rectangle {
                                                        Layout.preferredWidth: VfTheme.dp(18)
                                                        Layout.preferredHeight: VfTheme.dp(18)
                                                        radius: VfTheme.dp(4)
                                                        color: waveformColorCard.modelData.color
                                                    }
                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: waveformColorCard.modelData.label
                                                        color: VfTheme.text
                                                        font.family: VfTheme.fontFamily
                                                        font.pixelSize: VfTheme.dp(8)
                                                    }
                                                }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: dialog.openWaveformColor(
                                                        waveformColorCard.modelData.role,
                                                        waveformColorCard.modelData.color)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                objectName: "waveformDragHint"
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(40)
                                radius: VfTheme.dp(8)
                                color: VfTheme.surfaceSoft
                                border.color: VfTheme.border
                                Text {
                                    anchors.centerIn: parent
                                    width: parent.width - VfTheme.dp(14)
                                    text: qsTr("Kéo trực tiếp sóng trên preview để đặt vị trí.")
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(7.5)
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                            }

                            Item { Layout.fillHeight: true }

                        }
                    }


                }
            }

            ColumnLayout {
                id: rightPane
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: VfTheme.dp(620)
                spacing: VfTheme.dp(10)

                Rectangle {
                    id: canvasToolbar
                    objectName: "sequenceGraphicsCanvasToolbar"
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(48)
                    radius: VfTheme.dp(9)
                    color: VfTheme.surfaceSoft
                    border.width: 1
                    border.color: VfTheme.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(6)
                        spacing: VfTheme.dp(8)

                        ColumnLayout {
                            Layout.preferredWidth: VfTheme.dp(132)
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: qsTr("DESIGN CANVAS")
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSection
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: String(dialog.previewCanvasPlan.width || 1920)
                                    + " × "
                                    + String(dialog.previewCanvasPlan.height || 1080)
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            id: socialPlatformStatus
                            objectName: "sequenceGraphicsSocialPlatformStatus"
                            readonly property string value:
                                dialog.socialSafeZoneValue
                            visible: dialog.portraitCanvas
                            Layout.fillWidth: true
                            Layout.minimumWidth: VfTheme.dp(300)
                            Layout.preferredHeight: VfTheme.dp(36)
                            radius: VfTheme.dp(8)
                            color: VfTheme.surface
                            border.width: 1
                            border.color: VfTheme.border

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(3)
                                spacing: VfTheme.dp(3)

                                Repeater {
                                    // Stable five-state contract shared with Subtitle Studio.
                                    model: ["auto", "tiktok", "facebook", "youtube", "none"]

                                    delegate: VfChip {
                                        id: socialStatusChip
                                        required property string modelData
                                        readonly property string platformValue: modelData
                                        objectName: "sequenceGraphicsSocialPlatform_" + platformValue
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        minWidth: VfTheme.dp(48)
                                        text: platformValue === "none" ? qsTr("Tắt")
                                            : (platformValue === "auto" ? qsTr("All")
                                            : (platformValue === "tiktok" ? qsTr("TikTok")
                                            : (platformValue === "facebook" ? qsTr("Facebook")
                                            : qsTr("YouTube"))))
                                        tooltip: platformValue === "auto"
                                            ? qsTr("Vùng chung an toàn cho TikTok, Facebook và YouTube")
                                            : text
                                        showLeadingIcon: false
                                        fontPixelSize: VfTheme.fontTiny
                                        accent: platformValue === "none"
                                            ? VfTheme.textMuted : VfTheme.primary
                                        selected: dialog.socialSafeZoneValue === platformValue
                                        onClicked: dialog.controller.setPlatformSafeZone(
                                            socialStatusChip.platformValue)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            objectName: "sequenceGraphicsLandscapeSocialStatus"
                            visible: !dialog.portraitCanvas
                            Layout.fillWidth: true
                            Layout.minimumWidth: VfTheme.dp(300)
                            Layout.preferredHeight: VfTheme.dp(36)
                            radius: VfTheme.dp(8)
                            color: VfTheme.surface
                            border.width: 1
                            border.color: VfTheme.border

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("16:9 · không dùng overlay social")
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: Font.DemiBold
                            }
                        }

                        Rectangle {
                            objectName: "sequenceGraphicsCanvasAspectStatus"
                            Layout.preferredWidth: VfTheme.dp(96)
                            Layout.preferredHeight: VfTheme.dp(36)
                            radius: VfTheme.dp(8)
                            color: VfTheme.primary

                            Column {
                                anchors.centerIn: parent
                                spacing: 0

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: dialog.previewAspectRatio
                                    color: "#FFFFFF"
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    font.weight: Font.Bold
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: qsTr("theo job")
                                    color: "#FFFFFF"
                                    opacity: 0.80
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(7)
                                }
                            }
                        }
                    }
                }

                Item {
                    id: graphicsCanvasStage
                    objectName: "sequenceGraphicsCanvasStage"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        id: graphicsPreview
                        objectName: "graphicsPreview"
                    property string previewPresetId: dialog.activePreset
                    property string previewSignatureId: dialog.activeSignature
                    property string previewTimelineGrammar: dialog.timelineGrammar
                    property string previewCompositionGrammar:
                        dialog.compositionGrammar
                    property string previewMotionGrammar: dialog.motionGrammar
                    property string previewDensity: dialog.density
                    property int previewVariationSeed: dialog.variationSeed
                    property int previewVariationNumber: Number(
                        (dialog.previewStyle._variation || {}).number || 1)
                    property bool previewTimelineEnabled: dialog.timelineEnabled
                    property bool previewMapEnabled: false
                    readonly property real videoViewportHeight: Math.max(
                        1, height - previewControls.height)
                    readonly property real videoViewportAspect: width
                        / videoViewportHeight
                    readonly property real widthFromStageHeight: Math.max(
                        1, graphicsCanvasStage.height - previewControls.height)
                        * dialog.previewCanvasAspect
                    property real motionEnvelope: dialog.motionEnvelope(
                        dialog.previewProgress)
                    anchors.centerIn: parent
                    width: Math.min(graphicsCanvasStage.width, widthFromStageHeight)
                    height: Math.min(
                        graphicsCanvasStage.height,
                        width / Math.max(0.01, dialog.previewCanvasAspect)
                            + previewControls.height)
                    radius: VfTheme.dp(11)
                    clip: true
                    color: dialog.previewPanel
                    border.color: VfTheme.borderStrong

                    Canvas {
                        id: landscapeCanvas
                        anchors.fill: parent
                        property color accent: dialog.previewAccent
                        property color panel: dialog.previewPanel
                        property int seed: dialog.variationSeed
                        function jitter(salt) {
                            var value = Math.sin((seed + salt) * 12.9898) * 43758.5453
                            return value - Math.floor(value)
                        }
                        onAccentChanged: requestPaint()
                        onPanelChanged: requestPaint()
                        onSeedChanged: requestPaint()
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                        Component.onCompleted: requestPaint()
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            var sky = ctx.createLinearGradient(0, 0, width, height)
                            sky.addColorStop(0, String(dialog.previewPanel))
                            sky.addColorStop(0.55, "#263B49")
                            sky.addColorStop(1, "#10161F")
                            ctx.fillStyle = sky
                            ctx.fillRect(0, 0, width, height)

                            ctx.globalAlpha = 0.26
                            ctx.fillStyle = String(dialog.previewAccent)
                            ctx.beginPath()
                            ctx.moveTo(0, height * 0.76)
                            ctx.lineTo(width * 0.18, height * (0.33 + jitter(1) * 0.10))
                            ctx.lineTo(width * 0.31, height * 0.69)
                            ctx.lineTo(width * 0.48, height * (0.20 + jitter(2) * 0.10))
                            ctx.lineTo(width * 0.62, height * 0.67)
                            ctx.lineTo(width * 0.82, height * (0.29 + jitter(3) * 0.12))
                            ctx.lineTo(width, height * 0.72)
                            ctx.lineTo(width, height)
                            ctx.lineTo(0, height)
                            ctx.closePath()
                            ctx.fill()

                            ctx.globalAlpha = 0.70
                            ctx.fillStyle = "#0C131B"
                            ctx.beginPath()
                            ctx.moveTo(0, height * 0.84)
                            ctx.lineTo(width * 0.23, height * (0.54 + jitter(4) * 0.09))
                            ctx.lineTo(width * 0.40, height * 0.82)
                            ctx.lineTo(width * 0.61, height * (0.44 + jitter(5) * 0.10))
                            ctx.lineTo(width * 0.76, height * 0.79)
                            ctx.lineTo(width, height * 0.58)
                            ctx.lineTo(width, height)
                            ctx.lineTo(0, height)
                            ctx.closePath()
                            ctx.fill()
                            ctx.globalAlpha = 1.0
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop { position: 0; color: "#28000000" }
                            GradientStop { position: 0.68; color: "#08000000" }
                            GradientStop { position: 1; color: "#B8000000" }
                        }
                    }

                    Item {
                        id: videoSafeFrame
                        objectName: "sequenceGraphicsVideoSafeFrame"
                        readonly property real targetAspect: dialog.previewCanvasAspect
                        width: Math.min(
                            parent.width,
                            parent.videoViewportHeight * targetAspect)
                        height: Math.min(
                            parent.videoViewportHeight,
                            width / Math.max(0.01, targetAspect))
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                    }

                    SequenceCompositionPreview {
                        id: structuralPreview
                        objectName: "sequenceCompositionPreview"
                        parent: videoSafeFrame
                        anchors.fill: parent
                        visible: true
                        compositionGrammar: dialog.compositionGrammar
                        accent: dialog.previewAccent
                        secondary: dialog.previewSecondary
                        primary: dialog.previewPrimary
                        muted: dialog.previewMuted
                        panel: dialog.previewPanel
                        panelAlt: dialog.previewPanelAlt
                        visualSystemId: dialog.visualSystemId
                        material: dialog.visualMaterial
                        headlineFontRole: dialog.localTimelineFontRole
                        bodyFontRole: dialog.localTimelineFontRole
                        numericFontRole: "data"
                        interactive: dialog.configTab === "graphic"
                            && dialog.timelineEnabled && !dialog.showBefore
                        layoutXNorm: dialog.localTimelineX >= 0
                            ? dialog.localTimelineX
                            : Number(dialog.timelineLayout.x_norm || 0.5)
                        layoutYNorm: dialog.localTimelineY >= 0
                            ? dialog.localTimelineY
                            : Number(dialog.timelineLayout.y_norm || 0.5)
                        layoutWidthNorm: Number(
                            dialog.timelineLayout.width_norm || 1.0)
                        layoutHeightNorm: Number(
                            dialog.timelineLayout.height_norm || 1.0)
                        selectedTextRole: dialog.selectedTimelineTextRole
                        headingTextColor: dialog.timelineTextColor("heading")
                        eventTextColor: dialog.timelineTextColor("event")
                        axisTextColor: dialog.timelineTextColor("axis")
                        headingTextFontRole: String(dialog.timelineTextValue(
                            "heading", "font_role", "display"))
                        eventTextFontRole: String(dialog.timelineTextValue(
                            "event", "font_role", "display"))
                        axisTextFontRole: String(dialog.timelineTextValue(
                            "axis", "font_role", "data"))
                        headingTextScale: Number(dialog.timelineTextValue(
                            "heading", "font_scale", 1.0))
                        eventTextScale: Number(dialog.timelineTextValue(
                            "event", "font_scale", 1.0))
                        axisTextScale: Number(dialog.timelineTextValue(
                            "axis", "font_scale", 1.0))
                        headingTextGlow: Number(dialog.timelineTextValue(
                            "heading", "glow_scale", 0.0))
                        eventTextGlow: Number(dialog.timelineTextValue(
                            "event", "glow_scale", 0.0))
                        axisTextGlow: Number(dialog.timelineTextValue(
                            "axis", "glow_scale", 0.0))
                        headingTextShadow: Number(dialog.timelineTextValue(
                            "heading", "shadow_scale", 0.0))
                        eventTextShadow: Number(dialog.timelineTextValue(
                            "event", "shadow_scale", 0.0))
                        axisTextShadow: Number(dialog.timelineTextValue(
                            "axis", "shadow_scale", 0.0))
                        progress: dialog.previewProgress
                        markerCount: dialog.markerCount
                        railY: dialog.localTimelineRailY >= 0
                            ? dialog.localTimelineRailY
                            : Number(dialog.previewStyle.rail_y || 0.91)
                        glowScale: Number(dialog.timelineCustom.glow_scale || 0.0)
                        shadowScale: Number(dialog.timelineCustom.shadow_scale || 0.0)
                        fontScale: Number(dialog.timelineCustom.font_scale || 1.0)
                        mirrorEnabled: dialog.localTimelineMirror
                        previewEnabled: dialog.graphicsEnabled && dialog.timelineEnabled
                            && !dialog.showBefore
                        presetTitle: dialog.activeSignature === "auto"
                            ? "AI CHỌN THANH TIMELINE"
                            : String(dialog.previewStyle.label
                                || dialog.previewStyle.visual_system_label
                                || "DÒNG THỜI GIAN")
                        onTextRoleClicked: role => dialog.selectTimelineTextRole(role)
                        onPositionPreviewed: (xNorm, yNorm) => {
                            dialog.localTimelineX = xNorm
                            dialog.localTimelineY = yNorm
                        }
                        onPositionCommitted: (xNorm, yNorm) => {
                            dialog.controller.patchTimelineCustom({
                                x_norm: xNorm,
                                y_norm: yNorm
                            })
                        }
                    }

                    SequenceWaveformPreview {
                        id: waveformPreview
                        objectName: "sequenceWaveformPreview"
                        parent: videoSafeFrame
                        anchors.fill: parent
                        previewEnabled: dialog.waveformEnabled
                            && !dialog.showBefore
                        requestedStyle: dialog.waveformStyle
                        requestedLength: dialog.waveformLength
                        requestedPosition: dialog.waveformPosition
                        intensity: dialog.waveformIntensity
                        seed: dialog.waveformSeed
                        progress: dialog.previewProgress
                        accent: dialog.effectiveWaveformAccent
                        secondary: dialog.effectiveWaveformSecondary
                        muted: dialog.previewMuted
                        bottomReserved: dialog.timelineEnabled || dialog.subtitlesEnabled
                        customEnabled: dialog.waveformCustomEnabled
                            || dialog.waveformCustomExpanded
                        thicknessScale: dialog.localWaveformThickness
                        amplitudeScale: dialog.localWaveformAmplitude
                        glowScale: dialog.localWaveformGlow
                        customWidthRatio: dialog.localWaveformWidth
                        customXNorm: dialog.localWaveformX
                        customYNorm: dialog.localWaveformY
                        layoutXNorm: Number(dialog.waveformLayout.x_norm)
                        layoutYNorm: Number(dialog.waveformLayout.y_norm)
                        layoutWidthNorm: Number(dialog.waveformLayout.width_norm)
                        layoutHeightNorm: Number(dialog.waveformLayout.height_norm)
                        interactive: dialog.waveformEnabled
                            && dialog.waveformCustomExpanded
                        onPositionPreviewed: (xNorm, yNorm) => {
                            dialog.localWaveformX = xNorm
                            dialog.localWaveformY = yNorm
                        }
                        onPositionCommitted: (xNorm, yNorm) => {
                            dialog.controller.patchWaveformCustom({
                                x_norm: xNorm,
                                y_norm: yNorm
                            })
                        }
                    }

                    Image {
                        id: sequenceSocialPlatformAssetOverlay
                        objectName: "sequenceGraphicsSocialPlatformAssetOverlay"
                        readonly property int nativeStatus: status
                        parent: videoSafeFrame
                        anchors.fill: parent
                        visible: dialog.socialPlatformChromeVisible
                        source: dialog.socialOverlayAssetSource
                        sourceSize: Qt.size(1080, 1920)
                        fillMode: Image.Stretch
                        asynchronous: true
                        cache: true
                        smooth: true
                        mipmap: true
                        z: 1
                        Accessible.ignored: true
                    }

                    Rectangle {
                        objectName: "sequenceGraphicsSocialSafeBounds"
                        parent: videoSafeFrame
                        x: videoSafeFrame.width * Number(
                            dialog.socialSafeBounds.left || 0)
                        y: videoSafeFrame.height * Number(
                            dialog.socialSafeBounds.top || 0)
                        width: videoSafeFrame.width * Math.max(
                            0, Number(dialog.socialSafeBounds.right || 1)
                                - Number(dialog.socialSafeBounds.left || 0))
                        height: videoSafeFrame.height * Math.max(
                            0, Number(dialog.socialSafeBounds.bottom || 1)
                                - Number(dialog.socialSafeBounds.top || 0))
                        visible: dialog.combinedSocialGuideVisible
                        color: "transparent"
                        border.width: Math.max(1, VfTheme.dp(1))
                        border.color: "#34D399"
                        radius: VfTheme.dp(4)
                        z: 1

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: VfTheme.dp(4)
                            anchors.topMargin: VfTheme.dp(4)
                            width: sequenceSafeBoundsLabel.implicitWidth
                                + VfTheme.dp(10)
                            height: sequenceSafeBoundsLabel.implicitHeight
                                + VfTheme.dp(5)
                            radius: height / 2
                            color: Qt.rgba(0.02, 0.31, 0.22, 0.90)

                            Text {
                                id: sequenceSafeBoundsLabel
                                anchors.centerIn: parent
                                text: qsTr("VÙNG NỘI DUNG AN TOÀN")
                                color: "#A7F3D0"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: Math.max(
                                    VfTheme.dp(7), VfTheme.fontTiny)
                                font.weight: Font.Bold
                            }
                        }
                    }

                    Item {
                        objectName: "sequenceGraphicsSocialReservedOverlays"
                        parent: videoSafeFrame
                        anchors.fill: parent
                        visible: dialog.combinedSocialReservedVisible
                        z: 1

                        Repeater {
                            model: dialog.socialReservedOverlays

                            delegate: SubtitleSocialGuideOverlay {
                                id: sequenceReservedOverlay
                                required property var modelData
                                guide: sequenceReservedOverlay.modelData
                                maskMode: dialog.combinedSocialReservedVisible
                            }
                        }
                    }

                    Item {
                        id: subtitlePreviewLayer
                        objectName: "graphicsSubtitleCollisionPreview"
                        parent: videoSafeFrame
                        anchors.fill: parent
                        visible: dialog.subtitlePreviewVisible
                        z: 2
                        readonly property real timelineTopNorm:
                            structuralPreview.timelineReservedTopNorm
                        readonly property real minimumGapNorm: 0.018
                        readonly property real requestedY: Number(
                            dialog.subtitlePreview.y_norm || 0.68)
                        readonly property real resolvedY: {
                            if (!dialog.timelineEnabled || height <= 0)
                                return requestedY
                            var halfBox = subtitleCaptionBox.height / (2 * height)
                            return Math.min(
                                requestedY,
                                timelineTopNorm - minimumGapNorm - halfBox)
                        }
                        readonly property real captionBottomNorm: height > 0
                            ? (subtitleCaptionBox.y + subtitleCaptionBox.height) / height
                            : 1
                        readonly property bool collisionSafe: !dialog.timelineEnabled
                            || captionBottomNorm <= timelineTopNorm - minimumGapNorm + 0.001
                        readonly property string collisionPolicy: String(
                            dialog.subtitlePreview.collision_policy || "profile_position")

                        Rectangle {
                            id: subtitleCaptionBox
                            width: Math.min(
                                parent.width - VfTheme.dp(24),
                                Math.max(
                                    VfTheme.dp(180),
                                    parent.width * Number(
                                        dialog.subtitlePreview.box_width_norm || 0.72)))
                            height: Math.max(
                                VfTheme.dp(34),
                                subtitleSample.implicitHeight + VfTheme.dp(14))
                            x: Math.max(
                                VfTheme.dp(12),
                                Math.min(
                                    parent.width - width - VfTheme.dp(12),
                                    parent.width * Number(
                                        dialog.subtitlePreview.x_norm || 0.5)
                                        - width / 2))
                            y: Math.max(
                                VfTheme.dp(10),
                                Math.min(
                                    parent.height - height - VfTheme.dp(10),
                                    parent.height * subtitlePreviewLayer.resolvedY
                                        - height / 2))
                            radius: VfTheme.dp(5)
                            color: Boolean(dialog.subtitlePreview.panel_enabled)
                                ? Qt.rgba(
                                    dialog.subtitleFillColor.r,
                                    dialog.subtitleFillColor.g,
                                    dialog.subtitleFillColor.b,
                                    Math.max(0.18, Math.min(
                                        1, Number(dialog.subtitlePreview.fill_alpha || 0) / 255)))
                                : "transparent"
                            border.width: Boolean(dialog.subtitlePreview.panel_enabled) ? 1 : 0
                            border.color: dialog.subtitleAccentColor

                            Text {
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: VfTheme.dp(1)
                                anchors.verticalCenterOffset: VfTheme.dp(1)
                                width: parent.width - VfTheme.dp(18)
                                text: subtitleSample.text
                                color: "#D9000000"
                                font: subtitleSample.font
                                horizontalAlignment: subtitleSample.horizontalAlignment
                                wrapMode: Text.Wrap
                                maximumLineCount: 1
                                elide: Text.ElideRight
                            }
                            Text {
                                id: subtitleSample
                                anchors.centerIn: parent
                                width: parent.width - VfTheme.dp(18)
                            text: Boolean(dialog.subtitlePreview.has_external_srt)
                                    ? (dialog.timelineAvailable
                                        ? "Phụ đề mẫu từ SRT · không đè timeline"
                                        : "Phụ đề mẫu từ SRT · kiểm tra cùng sóng âm")
                                    : (dialog.timelineAvailable
                                        ? "Phụ đề tự động · không đè timeline"
                                        : "Phụ đề tự động · kiểm tra cùng sóng âm")
                                color: dialog.subtitleTextColor
                                font.family: VfTheme.fontFamily
                                font.pixelSize: Math.max(
                                    VfTheme.dp(10),
                                    parent.parent.height * Number(
                                        dialog.subtitlePreview.font_height_norm || 0.042)
                                        * Number(dialog.subtitlePreview.font_scale || 1))
                                font.weight: Font.DemiBold
                                horizontalAlignment: String(
                                    dialog.subtitlePreview.text_align || "center") === "left"
                                    ? Text.AlignLeft : Text.AlignHCenter
                                wrapMode: Text.Wrap
                                maximumLineCount: 1
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.bottom: parent.top
                                anchors.bottomMargin: VfTheme.dp(5)
                                width: subtitleSafeLabel.implicitWidth + VfTheme.dp(12)
                                height: VfTheme.dp(20)
                                radius: height / 2
                                color: subtitlePreviewLayer.collisionSafe
                                    ? "#CC0F5132" : "#CCD53B36"
                                border.color: subtitlePreviewLayer.collisionSafe
                                    ? "#6686EFAC" : "#66FCA5A5"
                                Text {
                                    id: subtitleSafeLabel
                                    anchors.centerIn: parent
                                    text: subtitlePreviewLayer.collisionSafe
                                        ? (dialog.timelineAvailable
                                            ? "SAFE · PHỤ ĐỀ TRÊN TIMELINE"
                                            : "SAFE · TIMELINE ĐÃ TẮT")
                                        : "CẢNH BÁO · PHỤ ĐỀ ĐÈ TIMELINE"
                                    color: "#FFFFFF"
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(7.5)
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }

                    Column {
                        id: previewTitleBlock
                        visible: false
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: VfTheme.dp(28)
                        anchors.topMargin: VfTheme.dp(24)
                        spacing: VfTheme.dp(5)
                        opacity: graphicsPreview.motionEnvelope
                        transform: Translate {
                            x: dialog.motionGrammar === "kinetic_push"
                                ? (-VfTheme.dp(56)
                                    * (1 - graphicsPreview.motionEnvelope))
                                : 0
                            y: dialog.motionGrammar === "calm_dissolve"
                                ? VfTheme.dp(14)
                                    * (1 - graphicsPreview.motionEnvelope)
                                : (dialog.motionGrammar === "playful_pulse"
                                    ? VfTheme.dp(20)
                                        * (1 - graphicsPreview.motionEnvelope)
                                    : 0)
                        }
                        scale: dialog.motionGrammar === "playful_pulse"
                            ? 0.82 + 0.18 * graphicsPreview.motionEnvelope
                            : (dialog.motionGrammar === "kinetic_push"
                                ? 0.9 + 0.1 * graphicsPreview.motionEnvelope : 1)
                        Rectangle {
                            width: VfTheme.dp(82)
                            height: VfTheme.dp(23)
                            radius: height / 2
                            color: "#66000000"
                            border.color: "#88FFFFFF"
                            Text {
                                anchors.centerIn: parent
                                text: "CHƯƠNG 02"
                                color: "#FFFFFF"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8.5)
                            }
                        }
                        Text {
                            text: dialog.activeSignature === "auto"
                                ? "AI CHỌN TRONG 10 KIỂU TIMELINE"
                                : String(dialog.previewStyle.signature_label
                                    || "DÒNG THỜI GIAN")
                            color: "#FFFFFF"
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(18)
                            font.weight: Font.Bold
                        }
                        Text {
                            text: "Các mốc quan trọng xuất hiện theo nhịp video"
                            color: "#E3EAF2"
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                        }
                    }

                    Column {
                        id: previewDateBlock
                        visible: false
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: VfTheme.dp(28)
                        anchors.topMargin: VfTheme.dp(24)
                        spacing: 1
                        opacity: graphicsPreview.motionEnvelope
                        scale: dialog.motionGrammar === "playful_pulse"
                            ? 0.78 + 0.22 * graphicsPreview.motionEnvelope : 1
                        transform: Translate {
                            x: dialog.motionGrammar === "kinetic_push"
                                ? VfTheme.dp(42)
                                    * (1 - graphicsPreview.motionEnvelope)
                                : 0
                        }
                        Text {
                            anchors.right: parent.right
                            text: "1946"
                            color: dialog.previewAccent
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(30)
                            font.weight: Font.Bold
                        }
                        Text {
                            anchors.right: parent.right
                            text: "12.08.1946"
                            color: "#FFFFFF"
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                        }
                    }

                    Item {
                        id: graphicsTimelineLayer
                        objectName: "graphicsTimelineLayer"
                        property bool layerEnabled: dialog.timelineEnabled
                        visible: false
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: previewControls.top
                        anchors.leftMargin: VfTheme.dp(42)
                        anchors.rightMargin: VfTheme.dp(42)
                        anchors.bottomMargin: VfTheme.dp(18)
                        height: VfTheme.dp(92)
                        opacity: graphicsPreview.motionEnvelope
                        transform: Translate {
                            y: dialog.motionGrammar === "calm_dissolve"
                                ? VfTheme.dp(12)
                                    * (1 - graphicsPreview.motionEnvelope)
                                : (dialog.motionGrammar === "playful_pulse"
                                    ? VfTheme.dp(18)
                                        * (1 - graphicsPreview.motionEnvelope)
                                    : 0)
                        }
                        scale: dialog.motionGrammar === "kinetic_push"
                            ? 0.9 + 0.1 * graphicsPreview.motionEnvelope
                            : (dialog.motionGrammar === "playful_pulse"
                                ? 0.80 + 0.20 * graphicsPreview.motionEnvelope : 1)

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: VfTheme.dp(16)
                            height: VfTheme.dp(2)
                            color: dialog.timelineGrammar === "minimal_line"
                                ? "#66FFFFFF" : "#8AFFFFFF"
                            border.width: dialog.timelineGrammar === "dual_track"
                                ? 1 : 0
                            border.color: dialog.previewAccent
                        }
                        Repeater {
                            model: 5
                            delegate: Item {
                                id: markerDelegate
                                required property int index
                                visible: markerDelegate.index < dialog.markerCount
                                x: markerDelegate.index
                                    * (graphicsTimelineLayer.width - width)
                                    / Math.max(1, dialog.markerCount - 1)
                                y: 0
                                width: VfTheme.dp(70)
                                height: graphicsTimelineLayer.height
                                transform: Translate { x: -markerDelegate.width / 2 }
                                Column {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 1
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: dialog.markerYear(markerDelegate.index)
                                        color: markerDelegate.index === Math.floor(
                                            (dialog.markerCount - 1) / 2)
                                            ? dialog.previewAccent : "#FFFFFF"
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(10)
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: VfTheme.dp(90)
                                        horizontalAlignment: Text.AlignHCenter
                                        text: dialog.markerLabel(markerDelegate.index)
                                        color: "#DCE5EF"
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(8)
                                        elide: Text.ElideRight
                                    }
                                }
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: VfTheme.dp(11)
                                    width: markerDelegate.index === Math.floor(
                                        (dialog.markerCount - 1) / 2)
                                        ? VfTheme.dp(14) : VfTheme.dp(9)
                                    height: width
                                    radius: dialog.timelineGrammar === "process_steps"
                                        ? VfTheme.dp(2) : width / 2
                                    rotation: dialog.timelineGrammar
                                        === "milestone_cards" ? 45 : 0
                                    color: markerDelegate.index === Math.floor(
                                        (dialog.markerCount - 1) / 2)
                                        ? dialog.previewAccent : "#DCE5EF"
                                    border.width: markerDelegate.index === Math.floor(
                                        (dialog.markerCount - 1) / 2) ? 3 : 0
                                    border.color: "#99FFFFFF"
                                    scale: markerDelegate.index === Math.floor(
                                        (dialog.markerCount - 1) / 2)
                                        && dialog.timelineGrammar === "pulse_focus"
                                        ? 1.0 + 0.18 * Math.sin(
                                            dialog.previewProgress * Math.PI * 8)
                                        : 1
                                }
                            }
                        }
                        Rectangle {
                            visible: dialog.timelineGrammar === "dual_track"
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: VfTheme.dp(24)
                            height: VfTheme.dp(1)
                            color: dialog.previewAccent
                            opacity: 0.52
                        }
                    }

                    Rectangle {
                        visible: !dialog.graphicsEnabled || dialog.showBefore
                        anchors.centerIn: parent
                        width: Math.min(parent.width * 0.55, VfTheme.dp(410))
                        height: VfTheme.dp(72)
                        radius: VfTheme.dp(10)
                        color: "#A8111824"
                        border.color: "#55FFFFFF"
                        Column {
                            anchors.centerIn: parent
                            spacing: 3
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: dialog.showBefore
                                    ? "TRƯỚC KHI ÁP DỤNG GRAPHICS"
                                    : "KHÔNG DÙNG SEQUENCE GRAPHICS"
                                color: "#FFFFFF"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                font.weight: Font.Bold
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Video gốc được giữ nguyên, không có lớp thông tin."
                                color: "#D7DFEA"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8.5)
                            }
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.bottom: previewControls.top
                        anchors.leftMargin: VfTheme.dp(12)
                        anchors.bottomMargin: VfTheme.dp(9)
                        width: previewNotice.implicitWidth + VfTheme.dp(16)
                        height: VfTheme.dp(24)
                        radius: height / 2
                        color: "#99101824"
                        border.color: "#44FFFFFF"
                        Text {
                            id: previewNotice
                            anchors.centerIn: parent
                            text: dialog.waveformEnabled
                                ? "PREVIEW MINH HỌA · JOB RENDER ĐỌC AUDIO THẬT"
                                : "PREVIEW MINH HỌA · CHƯA CÓ VIDEO"
                            color: "#DDE5EF"
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(8)
                            font.weight: Font.DemiBold
                        }
                    }

                    Rectangle {
                        id: previewControls
                        objectName: "graphicsPreviewControls"
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: VfTheme.dp(46)
                        color: "#DB101927"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(12)
                            anchors.rightMargin: VfTheme.dp(12)
                            spacing: VfTheme.dp(10)
                            VfButton {
                                compact: true
                                minWidth: VfTheme.dp(38)
                                text: "Ⅱ"
                                showLeadingIcon: false
                            }
                            Text {
                                text: "00:32 / 02:18"
                                color: "#FFFFFF"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(9)
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(14)
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: VfTheme.dp(3)
                                    radius: height / 2
                                    color: "#5A6677"
                                }
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width * 0.33
                                    height: VfTheme.dp(3)
                                    radius: height / 2
                                    color: dialog.previewAccent
                                }
                                Rectangle {
                                    x: parent.width * 0.33 - width / 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: VfTheme.dp(10)
                                    height: width
                                    radius: width / 2
                                    color: "#FFFFFF"
                                    border.color: dialog.previewAccent
                                    border.width: 2
                                }
                            }
                            VfButton {
                                visible: dialog.subtitlesEnabled
                                compact: true
                                minWidth: VfTheme.dp(96)
                                text: dialog.showSubtitlePreview
                                    ? "Ẩn phụ đề" : "Hiện phụ đề"
                                showLeadingIcon: false
                                tooltip: "Bật/tắt lớp phụ đề mẫu để kiểm tra va chạm với timeline"
                                onClicked: dialog.showSubtitlePreview
                                    = !dialog.showSubtitlePreview
                            }
                            VfButton {
                                compact: true
                                minWidth: VfTheme.dp(92)
                                text: dialog.showBefore ? "Xem sau" : "Trước / Sau"
                                showLeadingIcon: false
                                onClicked: dialog.showBefore = !dialog.showBefore
                            }
                        }
                    }
                }

                }

            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: VfTheme.border
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: VfTheme.dp(12)
            Text {
                objectName: "sequenceGraphicsAutosaveStatus"
                Layout.fillWidth: true
                text: String(dialog.controller.autosaveStatus
                    || "Tự lưu đang bật.")
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                elide: Text.ElideRight
            }
            Text {
                Layout.maximumWidth: VfTheme.dp(360)
                visible: dialog.localError.length > 0
                text: dialog.localError
                color: VfTheme.redText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
            }
            VfButton {
                objectName: "graphicsResetButton"
                compact: true
                iconName: "counterclockwise-arrows-button"
                text: "Khôi phục đề xuất"
                onClicked: {
                    dialog.localError = ""
                    dialog.controller.resetDraft()
                }
            }
            VfButton {
                objectName: "graphicsCloseButton"
                compact: true
                text: "Đóng"
                onClicked: dialog.close()
            }
            VfButton {
                id: graphicsApplyButton
                objectName: "graphicsApplyButton"
                compact: true
                tone: "primary"
                iconName: "save"
                minWidth: VfTheme.dp(176)
                text: dialog.timelineAvailable
                    ? "ÁP DỤNG CHO JOB MỚI"
                    : "ÁP DỤNG SÓNG ÂM"
                onClicked: {
                    var result = dialog.controller.applyToRoute()
                    if (result && result.ok)
                        dialog.close()
                    else
                        dialog.localError = String(
                            (result || {}).message || "Không thể áp dụng")
                }
            }
        }
    }
}
