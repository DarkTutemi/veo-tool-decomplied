pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import "../components"
import "../theme"

Dialog {
    id: dialog
    objectName: "subtitleStudioDialog"
    parent: Overlay.overlay
    modal: true
    anchors.centerIn: parent
    width: Math.min(parent ? parent.width - VfTheme.dp(48) : VfTheme.dp(1660), VfTheme.dp(1660))
    height: Math.min(parent ? parent.height - VfTheme.dp(42) : VfTheme.dp(940), VfTheme.dp(940))
    padding: 0
    closePolicy: Popup.CloseOnEscape

    // qmllint disable unqualified
    readonly property var controller: subtitleStudioController
    // qmllint enable unqualified
    readonly property var draft: controller.draft || ({})
    readonly property var plan: controller.paintPlan || ({})
    readonly property var canvasPlan: plan.canvas || ({ width: 1920, height: 1080, aspect: "16:9" })
    readonly property var captionPlan: plan.caption || ({})
    readonly property var overlayPlan: plan.overlay || ({})
    readonly property var learningStackPlan: plan.learning_stack || ({
        row_gap_px: Math.round(Number(canvasPlan.height || 1080) * 0.022),
        row_gap_norm: 0.022
    })
    readonly property var safeZonePlan: plan.safe_zone || ({})
    readonly property var safeZoneBounds: safeZonePlan.content_bounds || ({
        left: 0.04, top: 0.04, right: 0.96, bottom: 0.96
    })
    readonly property var safeZoneOverlays: safeZonePlan.reserved_overlays || []
    readonly property string safeZoneValue: String(draft.platform_safe_zone || "auto")
    readonly property bool portraitCanvas: String(canvasPlan.aspect || "16:9") === "9:16"
    readonly property var platformPreviewLayer: safeZonePlan.preview_layer || ({})
    readonly property string platformOverlayAssetName: String(
        platformPreviewLayer.asset_name || "")
    readonly property url platformOverlayAssetSource: platformChromeVisible
        && platformOverlayAssetName.length > 0
        ? Qt.resolvedUrl("../../resources/subtitle_studio/" + platformOverlayAssetName)
        : ""
    readonly property bool socialSafeZoneVisible: portraitCanvas
        && safeZoneValue !== "none"
    readonly property bool platformChromeVisible: portraitCanvas
        && (String(platformPreviewLayer.mode || "") === "platform_asset"
            || String(platformPreviewLayer.mode || "") === "combined_asset")
        && platformOverlayAssetName.length > 0
    readonly property bool combinedSafeZoneVisible: portraitCanvas
        && socialSafeZoneVisible
        && (safeZoneValue === "auto" || safeZoneValue === "average")
    readonly property bool combinedReservedZonesVisible: combinedSafeZoneVisible
        && safeZoneOverlays.length > 0
    readonly property var previewCue: controller.activePreviewCue || ({})
    readonly property var selectedStyleData: controller.selectedStyleData || ({})
    readonly property var selectedGeomData: controller.selectedGeomData || ({})
    readonly property string selectedObject: String(controller.selectedObject || "caption")
    readonly property string selectedStyle: String(controller.selectedStyle || "spoken")
    readonly property bool subtitleEnabled: Boolean(controller.subtitlesEnabled)
    readonly property bool overlayEnabled: Boolean(controller.overlayEnabled)
    readonly property string captionMode: String(controller.contentMode || "subtitle")
    readonly property int fontCatalogRevision: controller.fontCount
    readonly property string selectedFontId: String(selectedStyleData.font_id || "auto")
    readonly property string selectedFontRole: String(selectedStyleData.font_role || "display")
    readonly property string selectedFontName: {
        var revision = dialog.fontCatalogRevision
        if (selectedFontId === "" || selectedFontId === "auto")
            return controller.fontRoleDisplayName(selectedFontRole)
        return controller.fontDisplayName(selectedFontId)
    }
    readonly property string selectedFontSource: {
        var revision = dialog.fontCatalogRevision
        if (selectedFontId === "" || selectedFontId === "auto")
            return controller.fontRoleSourceLabel(selectedFontRole)
        return controller.fontSourceLabel(selectedFontId)
    }
    readonly property real canvasAspect: Number(canvasPlan.width || 1920) / Number(canvasPlan.height || 1080)
    readonly property var inspectorTabs: selectedObject === "caption"
        ? (captionMode === "bilingual"
            ? [
                { label: qsTr("Gốc"), objectId: "caption", styleId: "spoken" },
                { label: qsTr("Bản dịch"), objectId: "caption", styleId: "translation" }
            ]
            : [{ label: qsTr("Gốc"), objectId: "caption", styleId: "spoken" }])
        : [
            { label: qsTr("Từ"), objectId: "overlay", styleId: "lemma" },
            { label: qsTr("Cách đọc"), objectId: "overlay", styleId: "reading" }
        ]

    property bool applyPending: false
    property string localError: ""
    property real captionPreviewX: 0.50
    property real captionPreviewY: 0.86
    property real overlayPreviewX: 0.50
    property real overlayPreviewY: 0.42
    property real lemmaLayerOffsetX: 0.0
    property real lemmaLayerOffsetY: 0.0
    property real readingLayerOffsetX: 0.0
    property real readingLayerOffsetY: 0.0
    property real meaningLayerOffsetX: 0.0
    property real meaningLayerOffsetY: 0.0
    property string learningLayerDragging: ""
    property bool learningGroupMoveMode: false
    readonly property bool previewLearningBlock: dialog.overlayEnabled
        && String((dialog.previewCue || {}).lemma || "").length > 0
    readonly property string selectedLayerLabel: {
        if (!dialog.previewLearningBlock) {
            if (dialog.selectedStyle === "translation")
                return qsTr("Bản dịch")
            if (dialog.selectedStyle === "reading")
                return qsTr("Cách đọc")
            if (dialog.selectedStyle === "lemma")
                return qsTr("Từ / câu gốc")
            return qsTr("Phụ đề")
        }
        if (dialog.selectedObject === "caption")
            return qsTr("Nghĩa / bản dịch")
        return dialog.selectedStyle === "reading"
            ? qsTr("Cách đọc / phiên âm") : qsTr("Từ / câu gốc")
    }
    readonly property string selectedLayerSample: {
        if (!dialog.previewLearningBlock)
            return String((dialog.previewCue || {}).caption || qsTr("Phụ đề mẫu"))
        if (dialog.selectedObject === "caption")
            return String((dialog.previewCue || {}).native_meaning
                || (dialog.previewCue || {}).caption || qsTr("Nghĩa của câu"))
        if (dialog.selectedStyle === "reading")
            return String((dialog.previewCue || {}).reading || "/hɑːt/")
        return String((dialog.previewCue || {}).lemma || "HOT")
    }
    readonly property string effectiveCaptionAlignment: dialog.previewLearningBlock
        ? String((dialog.overlayPlan.pos || {}).align || "center")
        : String((dialog.captionPlan.pos || {}).align || "center")
    readonly property real effectiveCaptionPreviewX: {
        if (!dialog.previewLearningBlock)
            return dialog.captionPreviewX
        var captionWidth = Number((dialog.captionPlan.pos || {}).box_width_norm || 0.72)
        var overlayWidth = Number((dialog.overlayPlan.pos || {}).box_width_norm || 0.72)
        if (dialog.effectiveCaptionAlignment === "left")
            return dialog.clampNorm(dialog.overlayPreviewX - overlayWidth / 2 + captionWidth / 2)
        if (dialog.effectiveCaptionAlignment === "right")
            return dialog.clampNorm(dialog.overlayPreviewX + overlayWidth / 2 - captionWidth / 2)
        return dialog.overlayPreviewX
    }
    readonly property string effectiveSelectedAlignment:
        dialog.previewLearningBlock && dialog.selectedObject === "caption"
            ? dialog.effectiveCaptionAlignment
            : String(dialog.selectedGeomData.align || "center")
    property bool captionDragging: false
    property bool overlayDragging: false
    property string activeColorKey: "fill"
    property string presetCategory: "all"
    property string presetSearch: ""
    property bool realtimePreviewPlaying: true
    property real realtimePreviewPlayhead: 0.0
    readonly property var previewChrome: plan.chrome || ({})
    readonly property string previewMotion: String(previewChrome.motion || "static")
    readonly property string previewEffect: String(previewChrome.ass_effect || "clean_hold")
    readonly property string previewWordState: String(previewChrome.word_state || "off")
    readonly property real previewMotionStrength: Number(previewChrome.motion_strength || 1.0)

    component SelectionCorner: Rectangle {
        required property color accentColor
        width: VfTheme.dp(7)
        height: width
        radius: VfTheme.dp(2)
        color: VfTheme.surface
        border.width: 1
        border.color: accentColor
    }

    component TextSelectionFrame: Item {
        id: selectionFrame
        required property bool selected
        required property real textWidth
        required property real textHeight
        required property real availableWidth
        required property int horizontalAlignment
        required property color accentColor

        visible: selectionFrame.selected
        width: Math.min(selectionFrame.availableWidth,
            Math.max(VfTheme.dp(28), selectionFrame.textWidth + VfTheme.dp(12)))
        height: Math.max(VfTheme.dp(20), selectionFrame.textHeight + VfTheme.dp(8))
        x: selectionFrame.horizontalAlignment === Text.AlignLeft
            ? 0 : (selectionFrame.horizontalAlignment === Text.AlignRight
                ? Math.max(0, selectionFrame.availableWidth - selectionFrame.width)
                : Math.max(0, (selectionFrame.availableWidth - selectionFrame.width) / 2))
        y: (selectionFrame.parent.height - selectionFrame.height) / 2
        z: 20

        Rectangle {
            anchors.fill: parent
            radius: VfTheme.dp(3)
            color: "transparent"
            border.width: 1
            border.color: selectionFrame.accentColor
        }

        SelectionCorner {
            accentColor: selectionFrame.accentColor
            anchors.left: parent.left
            anchors.top: parent.top
        }
        SelectionCorner {
            accentColor: selectionFrame.accentColor
            anchors.right: parent.right
            anchors.top: parent.top
        }
        SelectionCorner {
            accentColor: selectionFrame.accentColor
            anchors.left: parent.left
            anchors.bottom: parent.bottom
        }
        SelectionCorner {
            accentColor: selectionFrame.accentColor
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
    }

    component LearningLayerDragArea: MouseArea {
        id: layerDrag
        required property Item canvasItem
        required property Item layerItem
        required property string objectId
        required property string styleId
        required property real offsetX
        required property real offsetY
        signal layerPressed()
        signal previewMoved(real offsetX, real offsetY)
        signal layerCommitted(real offsetX, real offsetY)
        signal layerCanceled()

        property real startCanvasX: 0
        property real startCanvasY: 0
        property real startCenterX: 0
        property real startCenterY: 0
        property real startOffsetX: 0
        property real startOffsetY: 0

        hoverEnabled: true
        preventStealing: true
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

        onPressed: function(mouse) {
            layerDrag.layerPressed()
            var point = layerDrag.mapToItem(
                layerDrag.canvasItem, mouse.x, mouse.y)
            var center = layerDrag.layerItem.mapToItem(
                layerDrag.canvasItem,
                layerDrag.layerItem.width / 2,
                layerDrag.layerItem.height / 2)
            layerDrag.startCanvasX = point.x
            layerDrag.startCanvasY = point.y
            layerDrag.startCenterX = center.x / Math.max(1, layerDrag.canvasItem.width)
            layerDrag.startCenterY = center.y / Math.max(1, layerDrag.canvasItem.height)
            layerDrag.startOffsetX = layerDrag.offsetX
            layerDrag.startOffsetY = layerDrag.offsetY
        }
        onPositionChanged: function(mouse) {
            if (!pressed)
                return
            var point = layerDrag.mapToItem(
                layerDrag.canvasItem, mouse.x, mouse.y)
            var deltaX = (point.x - layerDrag.startCanvasX)
                / Math.max(1, layerDrag.canvasItem.width)
            var deltaY = (point.y - layerDrag.startCanvasY)
                / Math.max(1, layerDrag.canvasItem.height)
            var nextCenterX = Math.max(0, Math.min(1,
                layerDrag.startCenterX + deltaX))
            var nextCenterY = Math.max(0, Math.min(1,
                layerDrag.startCenterY + deltaY))
            layerDrag.previewMoved(
                layerDrag.startOffsetX + nextCenterX - layerDrag.startCenterX,
                layerDrag.startOffsetY + nextCenterY - layerDrag.startCenterY)
        }
        onReleased: layerDrag.layerCommitted(layerDrag.offsetX, layerDrag.offsetY)
        onCanceled: layerDrag.layerCanceled()
    }

    function clampNorm(value) {
        return Math.max(0.0, Math.min(1.0, Number(value)))
    }

    function clampOffset(value) {
        return Math.max(-1.0, Math.min(1.0, Number(value)))
    }

    function hexColor(value, fallback) {
        var raw = String(value || fallback || "FFFFFF").replace("#", "")
        return "#" + (raw.length >= 6 ? raw.slice(0, 6) : String(fallback || "FFFFFF"))
    }

    function alphaColor(value, alpha255) {
        var color = hexColor(value, "080B12")
        var alpha = Math.max(0, Math.min(255, Number(alpha255 || 0))) / 255.0
        return Qt.rgba(
            parseInt(color.slice(1, 3), 16) / 255.0,
            parseInt(color.slice(3, 5), 16) / 255.0,
            parseInt(color.slice(5, 7), 16) / 255.0,
            alpha)
    }

    function colorHex(value) {
        function channel(number) {
            var text = Math.round(Math.max(0, Math.min(1, Number(number))) * 255)
                .toString(16).toUpperCase()
            return text.length < 2 ? "0" + text : text
        }
        return channel(value.r) + channel(value.g) + channel(value.b)
    }

    function horizontalAlignment(value) {
        if (String(value) === "left")
            return Text.AlignLeft
        if (String(value) === "right")
            return Text.AlignRight
        return Text.AlignHCenter
    }

    function scaledFont(style) {
        return Math.max(VfTheme.dp(9), Number((style || {}).font_px || 48)
            * previewCanvas.height / Math.max(1, Number(canvasPlan.height || 1080)))
    }

    function scaledDesignFont(fontPx) {
        return Math.max(VfTheme.dp(9), Number(fontPx || 1)
            * previewCanvas.height / Math.max(1, Number(canvasPlan.height || 1080)))
    }

    function subtitleCharacterUnits(character) {
        if (/\s/.test(character))
            return 0.34
        if (/[\u1100-\u11FF\u2E80-\u9FFF\uAC00-\uD7AF\uF900-\uFAFF\uFE10-\uFE6F\uFF00-\uFFEF]/.test(character))
            return 1.0
        if ("ilI.,'`|!".indexOf(character) >= 0)
            return 0.30
        if ("MW@#%&".indexOf(character) >= 0)
            return 0.92
        return 0.58
    }

    function subtitleTextUnits(value) {
        var text = String(value || "")
        var units = 0.0
        for (var index = 0; index < text.length; index += 1)
            units += subtitleCharacterUnits(text.charAt(index))
        return units
    }

    function fittedDesignFont(value, style, boxWidthPx) {
        var text = String(value || "").replace(/\s+/g, " ").trim()
        var data = style || ({})
        var configured = Math.max(1, Math.round(Number(data.font_px || 1)))
        if (text.length === 0)
            return configured
        var outline = Math.max(0.0, Number(data.outline_px || 0))
        var shadow = Math.max(0.0, Number(data.shadow_px || 0))
        var available = Math.max(1.0, Number(boxWidthPx || 1)
            - 32.0 - 2.0 * (outline + shadow))
        var units = subtitleTextUnits(text)
        if (units <= 0.0)
            return configured
        var tracking = Number(data.tracking_px || 0)
        var trackingTotal = Math.max(0, text.length - 1) * tracking
        if (units * configured + trackingTotal <= available * 0.90)
            return configured
        return Math.max(1, Math.min(configured,
            Math.floor((Math.max(1.0, available - trackingTotal) / units) * 0.90)))
    }

    function previewTextLayout(value, style, boxWidthPx) {
        var text = String(value || "").replace(/\s+/g, " ").trim()
        var configured = Math.max(1, Math.round(Number((style || {}).font_px || 1)))
        var lines = text.length > 0 ? [text] : []
        if (text.length > 0 && fittedDesignFont(text, style, boxWidthPx) < configured) {
            var words = text.split(" ").filter(function(word) { return word.length > 0 })
            if (words.length >= 2) {
                var best = null
                for (var splitAt = 1; splitAt < words.length; splitAt += 1) {
                    var first = words.slice(0, splitAt).join(" ")
                    var second = words.slice(splitAt).join(" ")
                    var firstUnits = subtitleTextUnits(first)
                    var secondUnits = subtitleTextUnits(second)
                    var candidate = {
                        maximum: Math.max(firstUnits, secondUnits),
                        difference: Math.abs(firstUnits - secondUnits),
                        splitAt: splitAt,
                        first: first,
                        second: second
                    }
                    if (best === null || candidate.maximum < best.maximum
                            || (candidate.maximum === best.maximum
                                && candidate.difference < best.difference)
                            || (candidate.maximum === best.maximum
                                && candidate.difference === best.difference
                                && candidate.splitAt < best.splitAt))
                        best = candidate
                }
                lines = [best.first, best.second]
            } else if (text.length >= 2) {
                var midpoint = Math.max(1, Math.floor(text.length / 2))
                lines = [text.slice(0, midpoint), text.slice(midpoint)]
            }
        }
        var fontPx = configured
        for (var lineIndex = 0; lineIndex < lines.length; lineIndex += 1)
            fontPx = Math.min(fontPx,
                fittedDesignFont(lines[lineIndex], style, boxWidthPx))
        return { text: lines.join("\n"), lines: lines, font_px: fontPx }
    }

    function previewLayoutHeight(layout) {
        var data = layout || ({})
        return Number(data.font_px || 1)
            * Math.max(1, Number((data.lines || []).length || 1))
    }

    function learningMeaningPreviewY() {
        if (!dialog.previewLearningBlock)
            return dialog.captionPreviewY
        var designHeight = Math.max(1, Number(dialog.canvasPlan.height || 1080))
        var lemmaHeight = previewLayoutHeight(lemmaPreview.fittedPreviewLayout)
        var readingVisible = String(dialog.previewCue.reading || "").length > 0
        var readingHeight = readingVisible
            ? previewLayoutHeight(readingPreview.fittedPreviewLayout) : 0
        var rowGap = Number(dialog.learningStackPlan.row_gap_px || 0)
        var overlayHeight = lemmaHeight + readingHeight
            + (readingVisible ? rowGap : 0)
        var meaningHeight = previewLayoutHeight(spokenPreview.fittedPreviewLayout)
        var centerDesignY = dialog.overlayPreviewY * designHeight
            + overlayHeight / 2
            + rowGap
            + meaningHeight / 2
        return dialog.clampNorm(centerDesignY / designHeight)
    }

    function scaledOutline(style) {
        return Math.max(0, Number((style || {}).outline_px || 0)
            * previewCanvas.height / Math.max(1, Number(canvasPlan.height || 1080)))
    }

    function fontRoleFamily(role) {
        var families = {
            "display": "Be Vietnam Pro",
            "rounded": "Be Vietnam Pro",
            "editorial": "Noto Serif",
            "data": "IBM Plex Sans",
            "condensed": "Barlow Condensed",
            "universal": "Noto Sans"
        }
        return String(families[String(role || "display")] || families.display)
    }

    function languageFontFamily(language, role, forceUniversal) {
        if (forceUniversal)
            return "Noto Sans"
        var scripts = {
            "zh": "Noto Sans CJK SC",
            "ja": "Noto Sans CJK JP",
            "ko": "Noto Sans CJK KR",
            "ar": "Noto Sans Arabic",
            "ur": "Noto Sans Arabic",
            "hi": "Noto Sans Devanagari",
            "th": "Noto Sans Thai",
            "bn": "Noto Sans Bengali"
        }
        return String(scripts[String(language || "").toLowerCase()]
            || fontRoleFamily(role))
    }

    function languageFontNeedsLoader(language, forceUniversal) {
        if (forceUniversal)
            return false
        var scripts = ["zh", "ja", "ko", "ar", "ur", "hi", "th", "bn"]
        return scripts.indexOf(String(language || "").toLowerCase()) >= 0
    }

    function previewFontFamily(loader, style, language, forceUniversal) {
        if (loader.status === FontLoader.Ready && String(loader.name || "").length > 0)
            return String(loader.name)
        var data = style || ({})
        var fontId = String(data.font_id || "auto")
        if (fontId !== "" && fontId !== "auto")
            return dialog.controller.previewFontFamily(fontId)
        var fallbackLanguage = String(language || (dialog.controller.jobContext || {}).content_language || "vi")
        return languageFontFamily(fallbackLanguage, data.font_role, forceUniversal)
    }

    function fontRoleAssetName(role) {
        var assets = {
            "display": "BeVietnamPro-SemiBold.ttf",
            "rounded": "BeVietnamPro-Bold.ttf",
            "editorial": "NotoSerif-SemiBold.ttf",
            "data": "IBMPlexSans-SemiBold.ttf",
            "condensed": "BarlowCondensed-SemiBold.ttf",
            "universal": "NotoSans-SemiBold.ttf"
        }
        return String(assets[String(role || "display")] || assets.display)
    }

    function languageFontAssetName(language, role, forceUniversal) {
        if (forceUniversal)
            return "NotoSans-SemiBold.ttf"
        var scripts = {
            "zh": "NotoSansCJKsc-Regular.otf",
            "ja": "NotoSansCJKjp-Regular.otf",
            "ko": "NotoSansCJKkr-Regular.otf",
            "ar": "NotoSansArabic-SemiBold.ttf",
            "ur": "NotoSansArabic-SemiBold.ttf",
            "hi": "NotoSansDevanagari-SemiBold.ttf",
            "th": "NotoSansThai-SemiBold.ttf",
            "bn": "NotoSansBengali-SemiBold.ttf"
        }
        var scriptAsset = scripts[String(language || "").toLowerCase()]
        return String(scriptAsset || fontRoleAssetName(role))
    }

    function previewFontSource(style, language, forceUniversal) {
        var data = style || ({})
        var fontId = String(data.font_id || "auto")
        if (fontId === "" || fontId === "auto") {
            if (!languageFontNeedsLoader(language, forceUniversal))
                return ""
            return Qt.resolvedUrl("../../resources/fonts/timemachine/"
                + languageFontAssetName(language, data.font_role, forceUniversal))
        }
        if (!dialog.controller.previewFontNeedsLoader(fontId))
            return ""
        return dialog.controller.previewFontUrl(fontId)
    }

    function applyPresetFilter() {
        dialog.controller.setPresetFilter(dialog.presetCategory, dialog.presetSearch)
    }

    function restartRealtimePreview() {
        dialog.realtimePreviewPlayhead = 0.0
        if (dialog.visible && dialog.realtimePreviewPlaying)
            realtimePreviewClock.restart()
    }

    function motionLabel(value) {
        var labels = {
            "static": qsTr("Tĩnh"),
            "fade": qsTr("Mờ dần"),
            "pop": qsTr("Nảy vào"),
            "slide_left": qsTr("Trượt trái"),
            "slide_up": qsTr("Trượt lên"),
            "bounce": qsTr("Bật nảy"),
            "pulse": qsTr("Nhịp đập"),
            "wave": qsTr("Lượn sóng")
        }
        return String(labels[String(value || "static")] || labels.static)
    }

    function syncPreviewPositions() {
        if (!dialog.captionDragging) {
            dialog.captionPreviewX = Number((dialog.captionPlan.pos || {}).x_norm === undefined
                ? 0.50 : dialog.captionPlan.pos.x_norm)
            dialog.captionPreviewY = Number((dialog.captionPlan.pos || {}).y_norm === undefined
                ? 0.86 : dialog.captionPlan.pos.y_norm)
        }
        if (!dialog.overlayDragging) {
            dialog.overlayPreviewX = Number((dialog.overlayPlan.pos || {}).x_norm === undefined
                ? 0.50 : dialog.overlayPlan.pos.x_norm)
            dialog.overlayPreviewY = Number((dialog.overlayPlan.pos || {}).y_norm === undefined
                ? 0.42 : dialog.overlayPlan.pos.y_norm)
        }
        if (dialog.learningLayerDragging !== "lemma") {
            dialog.lemmaLayerOffsetX = Number(
                (dialog.overlayPlan.lemma || {}).offset_x_norm || 0)
            dialog.lemmaLayerOffsetY = Number(
                (dialog.overlayPlan.lemma || {}).offset_y_norm || 0)
        }
        if (dialog.learningLayerDragging !== "reading") {
            dialog.readingLayerOffsetX = Number(
                (dialog.overlayPlan.reading || {}).offset_x_norm || 0)
            dialog.readingLayerOffsetY = Number(
                (dialog.overlayPlan.reading || {}).offset_y_norm || 0)
        }
        if (dialog.learningLayerDragging !== "meaning") {
            dialog.meaningLayerOffsetX = Number(
                (dialog.captionPlan.spoken || {}).offset_x_norm || 0)
            dialog.meaningLayerOffsetY = Number(
                (dialog.captionPlan.spoken || {}).offset_y_norm || 0)
        }
    }

    function nudgeSelected(dx, dy) {
        if (dialog.previewLearningBlock) {
            if (dialog.learningGroupMoveMode) {
                dialog.overlayPreviewX = dialog.clampNorm(
                    dialog.overlayPreviewX + dx)
                dialog.overlayPreviewY = dialog.clampNorm(
                    dialog.overlayPreviewY + dy)
                dialog.controller.setObjectPosition(
                    "overlay", dialog.overlayPreviewX, dialog.overlayPreviewY)
                return
            }
            if (dialog.selectedObject === "caption") {
                dialog.meaningLayerOffsetX = dialog.clampOffset(
                    dialog.meaningLayerOffsetX + dx)
                dialog.meaningLayerOffsetY = dialog.clampOffset(
                    dialog.meaningLayerOffsetY + dy)
                dialog.controller.setLearningLayerOffset(
                    "caption", "spoken",
                    dialog.meaningLayerOffsetX, dialog.meaningLayerOffsetY)
                return
            }
            if (dialog.selectedStyle === "reading") {
                dialog.readingLayerOffsetX = dialog.clampOffset(
                    dialog.readingLayerOffsetX + dx)
                dialog.readingLayerOffsetY = dialog.clampOffset(
                    dialog.readingLayerOffsetY + dy)
                dialog.controller.setLearningLayerOffset(
                    "overlay", "reading",
                    dialog.readingLayerOffsetX, dialog.readingLayerOffsetY)
                return
            }
            dialog.lemmaLayerOffsetX = dialog.clampOffset(
                dialog.lemmaLayerOffsetX + dx)
            dialog.lemmaLayerOffsetY = dialog.clampOffset(
                dialog.lemmaLayerOffsetY + dy)
            dialog.controller.setLearningLayerOffset(
                "overlay", "lemma",
                dialog.lemmaLayerOffsetX, dialog.lemmaLayerOffsetY)
            return
        }
        if (dialog.selectedObject === "overlay" && dialog.overlayEnabled) {
            dialog.overlayPreviewX = dialog.clampNorm(dialog.overlayPreviewX + dx)
            dialog.overlayPreviewY = dialog.clampNorm(dialog.overlayPreviewY + dy)
            dialog.controller.setObjectPosition("overlay", dialog.overlayPreviewX, dialog.overlayPreviewY)
            return
        }
        dialog.captionPreviewX = dialog.clampNorm(dialog.captionPreviewX + dx)
        dialog.captionPreviewY = dialog.clampNorm(dialog.captionPreviewY + dy)
        dialog.controller.setObjectPosition("caption", dialog.captionPreviewX, dialog.captionPreviewY)
    }

    function setSelectedAlignment(align) {
        var objectId = dialog.previewLearningBlock && dialog.selectedObject === "caption"
            ? "overlay" : dialog.selectedObject
        dialog.controller.setObjectAlign(objectId, String(align || "center"))
    }

    function colorLabel() {
        if (dialog.selectedObject === "overlay" && dialog.selectedStyle === "lemma")
            return qsTr("Màu nhấn")
        return qsTr("Màu chữ")
    }

    function colorKey() {
        return dialog.selectedObject === "overlay" && dialog.selectedStyle === "lemma"
            ? "accent" : "fill"
    }

    onAboutToShow: {
        syncPreviewPositions()
        realtimePreviewPlaying = true
        Qt.callLater(restartRealtimePreview)
    }
    onAboutToHide: controller.persistDraft()

    NumberAnimation {
        id: realtimePreviewClock
        target: dialog
        property: "realtimePreviewPlayhead"
        from: 0.0
        to: 1.0
        duration: 2400
        loops: Animation.Infinite
        easing.type: Easing.Linear
        running: dialog.visible
        paused: !dialog.realtimePreviewPlaying
            || dialog.captionDragging || dialog.overlayDragging
    }

    Connections {
        target: dialog.controller

        function onDraftChanged() {
            dialog.restartRealtimePreview()
        }
    }

    component CommitSlider: ColumnLayout {
        id: commitRoot
        property string label: ""
        property real from: 0
        property real to: 1
        property real stepSize: 0.1
        property int decimals: 1
        property alias value: control.value
        property string suffix: ""
        property bool showStepButtons: false
        signal committed(real value)

        spacing: VfTheme.dp(2)

        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: commitRoot.label
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: Font.DemiBold
            }
            Text {
                text: Number(control.value).toFixed(commitRoot.decimals) + commitRoot.suffix
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: Font.Bold
            }
        }

        RowLayout {
            Layout.fillWidth: true

            VfChip {
                objectName: String(commitRoot.objectName || "") + "Decrease"
                visible: commitRoot.showStepButtons
                Layout.preferredWidth: visible ? VfTheme.dp(36) : 0
                minWidth: VfTheme.dp(36)
                text: "-"
                showLeadingIcon: false
                tooltip: qsTr("Giảm một nấc")
                onClicked: commitRoot.committed(Math.max(
                    commitRoot.from, control.value - commitRoot.stepSize))
            }

            Slider {
                id: control
                Layout.fillWidth: true
                from: commitRoot.from
                to: commitRoot.to
                stepSize: commitRoot.stepSize
                live: true

                Timer {
                    id: keyboardCommit
                    interval: 260
                    repeat: false
                    onTriggered: commitRoot.committed(control.value)
                }

                onMoved: {
                    if (!pressed)
                        keyboardCommit.restart()
                }
                onPressedChanged: {
                    if (!pressed) {
                        keyboardCommit.stop()
                        commitRoot.committed(value)
                    }
                }
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Left || event.key === Qt.Key_Right
                            || event.key === Qt.Key_Up || event.key === Qt.Key_Down)
                        keyboardCommit.restart()
                }
            }

            VfChip {
                objectName: String(commitRoot.objectName || "") + "Increase"
                visible: commitRoot.showStepButtons
                Layout.preferredWidth: visible ? VfTheme.dp(36) : 0
                minWidth: VfTheme.dp(36)
                text: "+"
                showLeadingIcon: false
                tooltip: qsTr("Tăng một nấc")
                onClicked: commitRoot.committed(Math.min(
                    commitRoot.to, control.value + commitRoot.stepSize))
            }
        }
    }

    Connections {
        target: dialog.controller
        function onDraftChanged() {
            dialog.syncPreviewPositions()
        }
        function onRouteApplyCompleted(route, ok, message) {
            if (String(route || "") !== String(dialog.controller.activeRoute || ""))
                return
            dialog.applyPending = false
            if (ok)
                dialog.close()
            else
                dialog.localError = String(message || qsTr("Không thể áp dụng cấu hình phụ đề"))
        }
    }

    ColorDialog {
        id: styleColorDialog
        title: dialog.colorLabel()
        onAccepted: {
            dialog.controller.patchStyle(
                dialog.selectedObject,
                dialog.selectedStyle,
                dialog.activeColorKey,
                dialog.colorHex(selectedColor))
        }
    }

    FontLoader {
        id: spokenFontLoader
        objectName: "subtitleSpokenFontLoader"
        readonly property int nativeStatus: status
        readonly property string nativeName: name
        source: {
            var revision = dialog.fontCatalogRevision
            var language = dialog.previewLearningBlock
                ? String(dialog.previewCue.meaning_language || "vi")
                : String((dialog.controller.jobContext || {}).content_language || "vi")
            return dialog.previewFontSource(dialog.captionPlan.spoken, language, false)
        }
    }
    FontLoader {
        id: translationFontLoader
        objectName: "subtitleTranslationFontLoader"
        source: {
            var revision = dialog.fontCatalogRevision
            if (dialog.captionMode !== "bilingual" || dialog.previewLearningBlock)
                return ""
            return dialog.previewFontSource(
                dialog.captionPlan.translation,
                String((dialog.draft.caption || {}).target_language || "en"),
                false)
        }
    }
    FontLoader {
        id: lemmaFontLoader
        objectName: "subtitleLemmaFontLoader"
        readonly property int nativeStatus: status
        readonly property string nativeName: name
        source: {
            var revision = dialog.fontCatalogRevision
            if (!dialog.previewLearningBlock)
                return ""
            return dialog.previewFontSource(
                dialog.overlayPlan.lemma,
                String(dialog.previewCue.preview_language || "en"),
                false)
        }
    }
    FontLoader {
        id: readingFontLoader
        objectName: "subtitleReadingFontLoader"
        readonly property int nativeStatus: status
        readonly property string nativeName: name
        source: {
            var revision = dialog.fontCatalogRevision
            if (!dialog.previewLearningBlock)
                return ""
            return dialog.previewFontSource(dialog.overlayPlan.reading, "en", true)
        }
    }

    FileDialog {
        id: fontImportDialog
        title: qsTr("Nhập font phụ đề")
        nameFilters: [qsTr("Font (*.ttf *.otf *.ttc)")]
        onAccepted: dialog.controller.importCustomFont(String(selectedFile))
    }

    Popup {
        id: fontPopup
        objectName: "subtitleFontPicker"
        parent: Overlay.overlay
        modal: true
        focus: true
        anchors.centerIn: parent
        width: Math.min(dialog.width - VfTheme.dp(80), VfTheme.dp(620))
        height: Math.min(dialog.height - VfTheme.dp(100), VfTheme.dp(610))
        padding: VfTheme.dp(12)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        onOpened: {
            if (!dialog.controller.fontCatalogBusy
                    && !dialog.controller.systemFontsLoaded)
                dialog.controller.refreshFontCatalog()
        }

        background: Rectangle {
            radius: VfTheme.radiusPanel
            color: VfTheme.panel
            border.width: 1
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(8)

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: qsTr("Chọn font cho lớp đang chỉnh")
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSection
                    font.weight: Font.Bold
                }
                BusyIndicator {
                    visible: dialog.controller.fontCatalogBusy
                    running: visible
                    Layout.preferredWidth: VfTheme.dp(22)
                    Layout.preferredHeight: width
                }
                VfButton {
                    compact: true
                    minWidth: VfTheme.dp(84)
                    text: qsTr("Làm mới")
                    onClicked: dialog.controller.refreshFontCatalog()
                }
                VfButton {
                    compact: true
                    minWidth: VfTheme.dp(84)
                    text: qsTr("Nhập font")
                    onClicked: fontImportDialog.open()
                }
            }

            VfTextField {
                Layout.fillWidth: true
                label: qsTr("Tìm font")
                placeholder: qsTr("Tên font")
                onCommitted: function(value) { dialog.controller.setFontFilter("all", value) }
            }

            VfListView {
                id: fontList
                objectName: "subtitleFontRowLoader"
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: VfTheme.dp(5)
                model: fontPopup.visible ? dialog.controller.fontModel : null
                delegate: Rectangle {
                    id: fontRow
                    required property var modelData
                    width: fontList.width
                    height: VfTheme.dp(52)
                    radius: VfTheme.dp(7)
                    color: String(fontRow.modelData.font_id || "") === String(dialog.selectedStyleData.font_id || "auto")
                        ? VfTheme.blueFill : VfTheme.surfaceSoft
                    border.width: 1
                    border.color: String(fontRow.modelData.font_id || "") === String(dialog.selectedStyleData.font_id || "auto")
                        ? VfTheme.blueBorder : VfTheme.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(8)
                        spacing: VfTheme.dp(8)
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                Layout.fillWidth: true
                                text: String(fontRow.modelData.label || fontRow.modelData.family || qsTr("Tự động"))
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontControl
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: String(fontRow.modelData.source || "auto") + " · "
                                    + String(fontRow.modelData.note || fontRow.modelData.style || "")
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                elide: Text.ElideRight
                            }
                        }
                        Text {
                            text: qsTr("Aa")
                            color: VfTheme.text
                            font.family: String(fontRow.modelData.family || VfTheme.fontFamily)
                            font.pixelSize: VfTheme.fontTitle
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            dialog.controller.selectFont(String(fontRow.modelData.font_id || "auto"))
                            fontPopup.close()
                        }
                    }
                }
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            }
        }
    }

    header: Rectangle {
        objectName: "subtitleStudioHeader"
        implicitWidth: dialog.width
        implicitHeight: VfTheme.dp(64)
        color: VfTheme.panel
        radius: VfTheme.radiusPanel

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: VfTheme.border
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: VfTheme.dp(20)
            anchors.right: parent.right
            anchors.rightMargin: VfTheme.dp(20)
            anchors.verticalCenter: parent.verticalCenter
            height: implicitHeight
            spacing: 0

            Text {
                width: parent.width
                text: qsTr("SUBTITLE STUDIO") + " · "
                    + String(dialog.controller.activeRoute || "master").toUpperCase()
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTitle
                font.weight: Font.Bold
                elide: Text.ElideRight
            }
            Text {
                width: parent.width
                text: qsTr("Hai object độc lập · preview và render dùng chung paint plan")
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                elide: Text.ElideRight
            }
        }

    }

    background: Rectangle {
        color: VfTheme.appBackground
        radius: VfTheme.radiusPanel
        border.width: 1
        border.color: VfTheme.borderStrong
    }

    contentItem: ColumnLayout {
        spacing: VfTheme.dp(8)

        SubtitleUnifiedContentBar {
            Layout.fillWidth: true
            Layout.leftMargin: VfTheme.dp(12)
            Layout.rightMargin: VfTheme.dp(12)
            Layout.topMargin: VfTheme.dp(10)
            controller: dialog.controller
            onObjectChosen: function(objectId) {
                if (objectId === "overlay")
                    dialog.controller.setSelected("overlay", "lemma")
                else
                    dialog.controller.setSelected("caption", "spoken")
                previewCanvas.forceActiveFocus()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: VfTheme.dp(12)
            Layout.rightMargin: VfTheme.dp(12)
            spacing: VfTheme.dp(9)

            Rectangle {
                id: presetRail
                objectName: "subtitlePresetRail"
                Layout.preferredWidth: dialog.width >= VfTheme.dp(1500)
                    ? VfTheme.dp(520)
                    : (dialog.width >= VfTheme.dp(1280) ? VfTheme.dp(420) : VfTheme.dp(340))
                Layout.fillHeight: true
                radius: VfTheme.radiusPanel
                color: VfTheme.panel
                border.width: 1
                border.color: VfTheme.border

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    spacing: VfTheme.dp(7)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)

                        Text {
                            Layout.fillWidth: true
                            text: qsTr("MẪU PHỤ ĐỀ")
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSection
                            font.weight: Font.Bold
                        }

                        Rectangle {
                            Layout.preferredWidth: templateCount.implicitWidth + VfTheme.dp(14)
                            Layout.preferredHeight: VfTheme.dp(24)
                            radius: height / 2
                            color: VfTheme.violetFill
                            border.width: 1
                            border.color: VfTheme.violetBorder

                            Text {
                                id: templateCount
                                anchors.centerIn: parent
                                text: String(presetGrid.count) + " / "
                                    + String(dialog.controller.presetCount)
                                color: VfTheme.violetText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                font.weight: Font.Bold
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Ảnh xem trước render từ chính contract ASS; không đè vị trí đã kéo.")
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    VfTextField {
                        Layout.fillWidth: true
                        label: qsTr("Tìm preset")
                        value: dialog.presetSearch
                        placeholder: qsTr("Karaoke, social, dễ đọc…")
                        onCommitted: function(value) {
                            dialog.presetSearch = String(value || "")
                            dialog.applyPresetFilter()
                        }
                    }

                    VfListView {
                        id: presetCategoryStrip
                        objectName: "subtitlePresetCategoryStrip"
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(34)
                        orientation: ListView.Horizontal
                        spacing: VfTheme.dp(5)
                        model: dialog.controller.presetCategoryModel
                        ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }

                        delegate: VfChip {
                            id: categoryChip
                            required property var modelData
                            readonly property string categoryValue: String(modelData.value || "all")
                            width: implicitWidth
                            height: VfTheme.dp(28)
                            minWidth: VfTheme.dp(66)
                            showLeadingIcon: false
                            fontPixelSize: VfTheme.fontTiny
                            text: String(modelData.label || categoryValue)
                            selected: dialog.presetCategory === categoryValue
                            accent: VfTheme.primary
                            onClicked: {
                                dialog.presetCategory = categoryValue
                                dialog.applyPresetFilter()
                            }
                        }
                    }

                    VfGridView {
                        id: presetGrid
                        objectName: "subtitlePresetGallery"
                        // Every card is an independent ASS treatment. Wider cards make
                        // typography and panel structure readable before selection.
                        // Three cards remain readable down to 128dp each. Below that,
                        // fall back to two columns instead of depending on host DPR.
                        readonly property int galleryColumns: width >= VfTheme.dp(384)
                            ? 3 : 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        cellWidth: Math.floor(width / galleryColumns)
                        cellHeight: VfTheme.dp(142)
                        model: dialog.controller.presetModel
                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                        delegate: Rectangle {
                            id: presetCard
                            required property var modelData
                            readonly property string presetId: String(modelData.preset_id || "clean")
                            readonly property string archetype: String(modelData.archetype || "ASS")
                            readonly property bool selected: presetId === String(dialog.draft.preset_id || "clean")
                            objectName: "subtitlePresetCard_" + presetId
                            width: presetGrid.cellWidth - VfTheme.dp(6)
                            height: presetGrid.cellHeight - VfTheme.dp(6)
                            radius: VfTheme.dp(8)
                            color: "#1E2026"
                            border.width: selected ? 2 : 1
                            border.color: selected ? VfTheme.violetBorder : VfTheme.border

                            Rectangle {
                                id: thumbnailFrame
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: VfTheme.dp(4)
                                height: parent.height - VfTheme.dp(34)
                                radius: VfTheme.dp(6)
                                color: "#22242B"
                                clip: true

                                SubtitleMotionPreview {
                                    anchors.fill: parent
                                    motion: String(presetCard.modelData.preview_motion || "static")
                                    effect: String(presetCard.modelData.preview_effect || "clean_hold")
                                    playhead: presetCard.selected || presetCardMouse.containsMouse
                                        ? dialog.realtimePreviewPlayhead : 1.0
                                    strength: 0.72
                                    canvasWidth: width
                                    canvasHeight: height
                                    motionEnabled: (presetCard.selected || presetCardMouse.containsMouse)
                                        && motion !== "static"

                                    Image {
                                        id: templateThumb
                                        objectName: "subtitlePresetThumb_" + presetCard.presetId
                                        readonly property bool readyForSmoke: status === Image.Ready
                                        anchors.fill: parent
                                        asynchronous: true
                                        cache: true
                                        fillMode: Image.PreserveAspectCrop
                                        sourceSize.width: 384
                                        sourceSize.height: 216
                                        source: Qt.resolvedUrl(
                                            "../../resources/subtitle_studio/presets/"
                                            + String(presetCard.modelData.preview_asset || ""))
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    width: parent.width - VfTheme.dp(10)
                                    visible: templateThumb.status !== Image.Ready
                                    text: String(presetCard.modelData.sample || qsTr("Phụ đề mẫu"))
                                    color: dialog.hexColor(presetCard.modelData.preview_fill, "FFFFFF")
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    font.weight: Font.Bold
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }
                            }

                            RowLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: VfTheme.dp(7)
                                anchors.rightMargin: VfTheme.dp(6)
                                height: VfTheme.dp(29)
                                spacing: VfTheme.dp(3)

                                Text {
                                    Layout.fillWidth: true
                                    text: String(presetCard.modelData.label || presetCard.presetId)
                                    color: presetCard.selected ? VfTheme.violetText : "#F8FAFC"
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    font.weight: presetCard.selected ? Font.Bold : Font.DemiBold
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }

                                Text {
                                    text: presetCard.archetype
                                    color: dialog.hexColor(presetCard.modelData.preview_accent, "A78BFA")
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    font.weight: Font.Bold
                                }

                                Text {
                                    visible: presetCard.selected
                                    text: "✓"
                                    color: VfTheme.violetText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    font.weight: Font.Bold
                                }
                            }

                            MouseArea {
                                id: presetCardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: dialog.restartRealtimePreview()
                                onClicked: dialog.controller.selectPreset(presetCard.presetId)
                                ToolTip.visible: containsMouse
                                ToolTip.delay: 450
                                ToolTip.text: String(presetCard.modelData.description || "")
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: previewPanel
                objectName: "subtitlePreviewPanel"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: VfTheme.dp(420)
                radius: VfTheme.radiusPanel
                color: VfTheme.panel
                border.width: 1
                border.color: VfTheme.border

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    spacing: VfTheme.dp(8)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)
                        ColumnLayout {
                            Layout.preferredWidth: VfTheme.dp(116)
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
                                text: String(dialog.canvasPlan.width || 1920)
                                    + " × " + String(dialog.canvasPlan.height || 1080)
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            id: socialSafeZoneSelect
                            objectName: "subtitleSocialSafeZoneSelect"
                            property string value: dialog.safeZoneValue
                            readonly property var platformValues: [
                                "auto", "tiktok", "facebook", "youtube", "none"
                            ]

                            function platformAt(localX) {
                                var rowX = Number(localX) - platformRow.x
                                for (var index = 0; index < platformRepeater.count; index += 1) {
                                    var chip = platformRepeater.itemAt(index)
                                    if (chip !== null && rowX >= chip.x
                                            && rowX <= chip.x + chip.width)
                                        return String(socialSafeZoneSelect.platformValues[index])
                                }
                                return ""
                            }

                            visible: dialog.portraitCanvas
                            Layout.fillWidth: true
                            Layout.minimumWidth: VfTheme.dp(290)
                            Layout.preferredHeight: VfTheme.dp(40)
                            radius: VfTheme.dp(8)
                            color: VfTheme.surfaceSoft
                            border.width: 1
                            border.color: VfTheme.border

                            RowLayout {
                                id: platformRow
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(4)
                                spacing: VfTheme.dp(3)

                                Repeater {
                                    id: platformRepeater
                                    // Stable five-state product contract: no mutable QVariantList model.
                                    model: socialSafeZoneSelect.platformValues

                                    delegate: VfChip {
                                        id: platformChip
                                        required property string modelData
                                        readonly property string platformValue: modelData
                                        objectName: "subtitleSocialPlatform_" + platformValue
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        minWidth: VfTheme.dp(48)
                                        text: platformValue === "none" ? qsTr("Tắt")
                                            : (platformValue === "auto" ? qsTr("All")
                                            : (platformValue === "tiktok" ? qsTr("TikTok")
                                            : (platformValue === "facebook" ? qsTr("Facebook")
                                            : qsTr("YouTube"))))
                                        tooltip: platformValue === "auto"
                                            ? qsTr("Vùng chung đo từ alpha asset TikTok, Facebook và YouTube")
                                            : text
                                        showLeadingIcon: false
                                        fontPixelSize: VfTheme.fontSmall
                                        accent: platformValue === "none" ? VfTheme.textMuted : VfTheme.primary
                                        selected: dialog.safeZoneValue === platformValue
                                        onClicked: dialog.controller.setPlatformSafeZone(platformChip.platformValue)
                                    }
                                }
                            }

                            MouseArea {
                                objectName: "subtitleSocialSafeZoneHitArea"
                                anchors.fill: parent
                                z: 100
                                cursorShape: Qt.PointingHandCursor
                                onClicked: function(mouse) {
                                    var platform = socialSafeZoneSelect.platformAt(mouse.x)
                                    if (platform.length > 0)
                                        dialog.controller.setPlatformSafeZone(platform)
                                }
                            }
                        }

                        Rectangle {
                            objectName: "subtitleLandscapeSocialStatus"
                            visible: !dialog.portraitCanvas
                            Layout.fillWidth: true
                            Layout.minimumWidth: VfTheme.dp(290)
                            Layout.preferredHeight: VfTheme.dp(40)
                            radius: VfTheme.dp(8)
                            color: VfTheme.surfaceSoft
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

                        Repeater {
                            model: ["16:9", "9:16"]
                            delegate: VfChip {
                                id: aspectChip
                                required property string modelData
                                minWidth: VfTheme.dp(68)
                                text: modelData
                                showLeadingIcon: false
                                selected: String(dialog.canvasPlan.aspect || "16:9") === modelData
                                onClicked: dialog.controller.setAspectRatio(aspectChip.modelData)
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            id: previewCanvas
                            objectName: "subtitleDesignCanvas"
                            anchors.centerIn: parent
                            width: Math.min(parent.width, parent.height * dialog.canvasAspect)
                            height: width / dialog.canvasAspect
                            radius: VfTheme.dp(6)
                            color: "#131827"
                            border.width: 1
                            border.color: VfTheme.borderStrong
                            clip: true
                            activeFocusOnTab: true
                            focus: dialog.visible

                            Keys.onPressed: function(event) {
                                var step = (event.modifiers & Qt.ShiftModifier) ? 0.01 : 0.0025
                                if (event.key === Qt.Key_Left) {
                                    dialog.nudgeSelected(-step, 0)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Right) {
                                    dialog.nudgeSelected(step, 0)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Up) {
                                    dialog.nudgeSelected(0, -step)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Down) {
                                    dialog.nudgeSelected(0, step)
                                    event.accepted = true
                                }
                            }

                            Rectangle {
                                objectName: "subtitleSolidPreviewBackground"
                                anchors.fill: parent
                                color: "#475569"
                            }

                            Rectangle {
                                id: realtimePreviewToolbar
                                objectName: "subtitleRealtimePreviewToolbar"
                                readonly property real playheadForSmoke: dialog.realtimePreviewPlayhead
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.margins: VfTheme.dp(10)
                                width: Math.min(previewCanvas.width - VfTheme.dp(20), VfTheme.dp(270))
                                height: VfTheme.dp(38)
                                radius: VfTheme.dp(8)
                                color: "#D90F172A"
                                border.width: 1
                                border.color: "#66778AA8"
                                z: 10

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(4)
                                    spacing: VfTheme.dp(5)

                                    VfChip {
                                        objectName: "subtitleRealtimePreviewToggle"
                                        Layout.preferredWidth: VfTheme.dp(86)
                                        Layout.fillHeight: true
                                        minWidth: VfTheme.dp(78)
                                        showLeadingIcon: false
                                        fontPixelSize: VfTheme.fontTiny
                                        text: dialog.realtimePreviewPlaying
                                            ? qsTr("Tạm dừng") : qsTr("Phát lại")
                                        selected: dialog.realtimePreviewPlaying
                                        accent: VfTheme.cyan
                                        onClicked: {
                                            if (dialog.realtimePreviewPlaying) {
                                                dialog.realtimePreviewPlaying = false
                                            } else {
                                                dialog.realtimePreviewPlaying = true
                                                dialog.restartRealtimePreview()
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: 1

                                        Text {
                                            Layout.fillWidth: true
                                            text: qsTr("REALTIME") + " · "
                                                + dialog.motionLabel(dialog.previewMotion)
                                            color: "#F8FAFC"
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(9)
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                        }

                                        Rectangle {
                                            objectName: "subtitleRealtimePreviewProgress"
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: VfTheme.dp(3)
                                            radius: height / 2
                                            color: "#536174"

                                            Rectangle {
                                                width: parent.width * dialog.realtimePreviewPlayhead
                                                height: parent.height
                                                radius: height / 2
                                                color: VfTheme.cyan
                                            }
                                        }
                                    }
                                }
                            }

                            Image {
                                id: socialPlatformAssetOverlay
                                objectName: "subtitleSocialPlatformAssetOverlay"
                                readonly property int nativeStatus: status
                                anchors.fill: parent
                                visible: dialog.platformChromeVisible
                                source: dialog.platformOverlayAssetSource
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
                                objectName: "subtitleSocialSafeBounds"
                                x: previewCanvas.width * Number(dialog.safeZoneBounds.left || 0)
                                y: previewCanvas.height * Number(dialog.safeZoneBounds.top || 0)
                                width: previewCanvas.width * Math.max(0,
                                    Number(dialog.safeZoneBounds.right || 1)
                                    - Number(dialog.safeZoneBounds.left || 0))
                                height: previewCanvas.height * Math.max(0,
                                    Number(dialog.safeZoneBounds.bottom || 1)
                                    - Number(dialog.safeZoneBounds.top || 0))
                                visible: dialog.combinedSafeZoneVisible
                                color: "transparent"
                                border.width: Math.max(1, VfTheme.dp(1))
                                border.color: "#34D399"
                                radius: VfTheme.dp(4)
                                z: 1

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.leftMargin: VfTheme.dp(5)
                                    anchors.topMargin: VfTheme.dp(5)
                                    width: safeBoundsLabel.implicitWidth + VfTheme.dp(10)
                                    height: safeBoundsLabel.implicitHeight + VfTheme.dp(5)
                                    radius: height / 2
                                    color: Qt.rgba(0.02, 0.31, 0.22, 0.90)

                                    Text {
                                        id: safeBoundsLabel
                                        anchors.centerIn: parent
                                        text: qsTr("ĐẶT PHỤ ĐỀ TRONG VÙNG NÀY")
                                        color: "#A7F3D0"
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: Math.max(VfTheme.dp(8), VfTheme.fontTiny)
                                        font.weight: Font.Bold
                                    }
                                }
                            }

                            Item {
                                objectName: "subtitleSocialReservedOverlays"
                                anchors.fill: parent
                                visible: dialog.combinedReservedZonesVisible
                                z: 1

                                Repeater {
                                    model: dialog.safeZoneOverlays
                                    delegate: SubtitleSocialGuideOverlay {
                                        id: reservedOverlay
                                        required property var modelData
                                        guide: reservedOverlay.modelData
                                        maskMode: dialog.combinedReservedZonesVisible
                                    }
                                }
                            }

                            Item {
                                id: captionBox
                                objectName: "captionPlacementBox"
                                width: previewCanvas.width * Number((dialog.captionPlan.pos || {}).box_width_norm || 0.72)
                                height: captionColumn.implicitHeight + VfTheme.dp(8)
                                x: dialog.effectiveCaptionPreviewX * previewCanvas.width - width / 2
                                y: dialog.learningMeaningPreviewY() * previewCanvas.height - height / 2
                                z: dialog.selectedObject === "caption" ? 3 : 2
                                visible: dialog.subtitleEnabled

                                SubtitleMotionPreview {
                                    id: captionMotionFrame
                                    objectName: "subtitleRealtimeCaptionMotion"
                                    anchors.fill: parent
                                    motion: dialog.previewMotion
                                    effect: dialog.previewEffect
                                    playhead: dialog.realtimePreviewPlayhead
                                    strength: dialog.previewMotionStrength
                                    canvasWidth: previewCanvas.width
                                    canvasHeight: previewCanvas.height
                                    motionEnabled: dialog.previewWordState !== "reveal"
                                        && !dialog.captionDragging && !dialog.overlayDragging

                                    Rectangle {
                                        objectName: "captionRenderedPanel"
                                        anchors.fill: parent
                                        radius: VfTheme.dp(5)
                                        color: String((dialog.plan.chrome || {}).panel || "preset") === "off"
                                            ? "transparent"
                                            : dialog.alphaColor(
                                                (dialog.plan.chrome || {}).panel_fill || "080B12",
                                                (dialog.plan.chrome || {}).panel_alpha || 0)
                                        border.width: 0
                                    }

                                    Column {
                                        id: captionColumn
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.leftMargin: 8 * previewCanvas.height
                                            / Math.max(1, Number(dialog.canvasPlan.height || 1080))
                                        anchors.rightMargin: anchors.leftMargin
                                        spacing: Number(dialog.captionPlan.translation_gap_px || 8)
                                            * previewCanvas.height / Math.max(1, Number(dialog.canvasPlan.height || 1080))

                                        SubtitleRealtimeText {
                                            id: spokenPreview
                                            objectName: "captionSpokenPreview"
                                            property string renderedPreviewText: Boolean((dialog.captionPlan.spoken || {}).uppercase)
                                                ? String(dialog.previewCue.caption || qsTr("Phụ đề mẫu.")).toUpperCase()
                                                : String(dialog.previewCue.caption || qsTr("Phụ đề mẫu."))
                                            property var fittedPreviewLayout: dialog.previewTextLayout(
                                                renderedPreviewText,
                                                dialog.captionPlan.spoken,
                                                Number((dialog.captionPlan.pos || {}).box_width_px || 1))
                                            width: parent.width
                                            height: implicitHeight
                                            sourceText: fittedPreviewLayout.text
                                            wordState: dialog.previewWordState
                                            playhead: dialog.realtimePreviewPlayhead
                                            primaryColor: dialog.hexColor((dialog.captionPlan.spoken || {}).fill, "FFFFFF")
                                            accentColor: dialog.hexColor((dialog.captionPlan.spoken || {}).accent, "FACC15")
                                            outlineColor: dialog.hexColor((dialog.plan.chrome || {}).stroke, "0B1220")
                                            fontFamily: dialog.previewFontFamily(
                                                spokenFontLoader,
                                                dialog.captionPlan.spoken,
                                                dialog.previewLearningBlock
                                                    ? String(dialog.previewCue.meaning_language || "vi")
                                                    : String((dialog.controller.jobContext || {}).content_language || "vi"),
                                                false)
                                            fontPixelSize: dialog.scaledDesignFont(fittedPreviewLayout.font_px)
                                            fontWeight: Number((dialog.captionPlan.spoken || {}).weight || 600)
                                            fontItalic: Boolean((dialog.captionPlan.spoken || {}).italic)
                                            fontUnderline: Boolean((dialog.captionPlan.spoken || {}).underline)
                                            fontStrikeout: Boolean((dialog.captionPlan.spoken || {}).strike)
                                            uppercase: Boolean((dialog.captionPlan.spoken || {}).uppercase)
                                            letterSpacing: Number((dialog.captionPlan.spoken || {}).tracking_px || 0)
                                                * previewCanvas.height / Math.max(1, Number(dialog.canvasPlan.height || 1080))
                                            horizontalAlignment: dialog.horizontalAlignment(dialog.effectiveCaptionAlignment)
                                            outlineEnabled: dialog.scaledOutline(dialog.captionPlan.spoken) > 0
                                            transform: Translate {
                                                x: dialog.previewLearningBlock
                                                    ? dialog.meaningLayerOffsetX * previewCanvas.width : 0
                                                y: dialog.previewLearningBlock
                                                    ? dialog.meaningLayerOffsetY * previewCanvas.height : 0
                                            }

                                            TextSelectionFrame {
                                                objectName: "captionSpokenSelectionFrame"
                                                selected: !dialog.learningGroupMoveMode
                                                    && dialog.selectedObject === "caption"
                                                    && dialog.selectedStyle === "spoken"
                                                textWidth: spokenPreview.paintedWidth
                                                textHeight: spokenPreview.paintedHeight
                                                availableWidth: spokenPreview.width
                                                horizontalAlignment: spokenPreview.horizontalAlignment
                                                accentColor: dialog.previewLearningBlock
                                                    ? VfTheme.violetBorder : VfTheme.cyanBorder
                                            }

                                            TapHandler {
                                                objectName: "captionSpokenTapHandler"
                                                enabled: !dialog.previewLearningBlock
                                                onTapped: {
                                                    dialog.controller.setSelected("caption", "spoken")
                                                    previewCanvas.forceActiveFocus()
                                                }
                                            }

                                            LearningLayerDragArea {
                                                objectName: "meaningLearningLayerDragArea"
                                                anchors.fill: parent
                                                z: 30
                                                enabled: dialog.previewLearningBlock
                                                    && !dialog.learningGroupMoveMode
                                                canvasItem: previewCanvas
                                                layerItem: spokenPreview
                                                objectId: "caption"
                                                styleId: "spoken"
                                                offsetX: dialog.meaningLayerOffsetX
                                                offsetY: dialog.meaningLayerOffsetY
                                                onLayerPressed: {
                                                    dialog.controller.setSelected("caption", "spoken")
                                                    previewCanvas.forceActiveFocus()
                                                    dialog.learningLayerDragging = "meaning"
                                                    dialog.captionDragging = true
                                                }
                                                onPreviewMoved: function(offsetX, offsetY) {
                                                    dialog.meaningLayerOffsetX = dialog.clampOffset(offsetX)
                                                    dialog.meaningLayerOffsetY = dialog.clampOffset(offsetY)
                                                }
                                                onLayerCommitted: function(offsetX, offsetY) {
                                                    dialog.controller.setLearningLayerOffset(
                                                        "caption", "spoken", offsetX, offsetY)
                                                    dialog.learningLayerDragging = ""
                                                    dialog.captionDragging = false
                                                    dialog.syncPreviewPositions()
                                                }
                                                onLayerCanceled: {
                                                    dialog.learningLayerDragging = ""
                                                    dialog.captionDragging = false
                                                    dialog.syncPreviewPositions()
                                                }
                                            }
                                        }

                                        Text {
                                            id: translationPreview
                                            property string renderedPreviewText: Boolean((dialog.captionPlan.translation || {}).uppercase)
                                                ? String(dialog.previewCue.translation || qsTr("Sample translation.")).toUpperCase()
                                                : String(dialog.previewCue.translation || qsTr("Sample translation."))
                                            property var fittedPreviewLayout: dialog.previewTextLayout(
                                                renderedPreviewText,
                                                dialog.captionPlan.translation,
                                                Number((dialog.captionPlan.pos || {}).box_width_px || 1))
                                            width: parent.width
                                            visible: dialog.captionMode === "bilingual"
                                                && !dialog.previewLearningBlock
                                            text: fittedPreviewLayout.text
                                            color: dialog.hexColor((dialog.captionPlan.translation || {}).fill, "D1D5DB")
                                        font.family: dialog.previewFontFamily(
                                            translationFontLoader,
                                            dialog.captionPlan.translation,
                                            String((dialog.draft.caption || {}).target_language || "en"),
                                            false)
                                            font.pixelSize: dialog.scaledDesignFont(fittedPreviewLayout.font_px)
                                            fontSizeMode: Text.HorizontalFit
                                            minimumPixelSize: 1
                                            font.weight: Number((dialog.captionPlan.translation || {}).weight || 500)
                                            font.italic: Boolean((dialog.captionPlan.translation || {}).italic)
                                            font.underline: Boolean((dialog.captionPlan.translation || {}).underline)
                                            font.strikeout: Boolean((dialog.captionPlan.translation || {}).strike)
                                            font.letterSpacing: Number((dialog.captionPlan.translation || {}).tracking_px || 0)
                                                * previewCanvas.height / Math.max(1, Number(dialog.canvasPlan.height || 1080))
                                            horizontalAlignment: dialog.horizontalAlignment(dialog.effectiveCaptionAlignment)
                                            wrapMode: Text.NoWrap
                                            elide: Text.ElideNone
                                            style: dialog.scaledOutline(dialog.captionPlan.translation) > 0 ? Text.Outline : Text.Normal
                                            styleColor: dialog.hexColor((dialog.plan.chrome || {}).stroke, "0B1220")

                                            TextSelectionFrame {
                                                objectName: "captionTranslationSelectionFrame"
                                                selected: dialog.selectedObject === "caption"
                                                    && dialog.selectedStyle === "translation"
                                                textWidth: translationPreview.paintedWidth
                                                textHeight: translationPreview.paintedHeight
                                                availableWidth: translationPreview.width
                                                horizontalAlignment: translationPreview.horizontalAlignment
                                                accentColor: VfTheme.cyanBorder
                                            }

                                            TapHandler {
                                                objectName: "captionTranslationTapHandler"
                                                onTapped: {
                                                    dialog.controller.setSelected("caption", "translation")
                                                    previewCanvas.forceActiveFocus()
                                                }
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: captionMouse
                                    objectName: "captionTextHitArea"
                                    anchors.fill: parent
                                    z: -1
                                    enabled: !dialog.previewLearningBlock
                                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                                    property real startCanvasX: 0
                                    property real startCanvasY: 0
                                    property real startNormX: 0
                                    property real startNormY: 0
                                    onPressed: function(mouse) {
                                        var translationPoint = captionMouse.mapToItem(
                                            translationPreview, mouse.x, mouse.y)
                                        var styleId = translationPreview.visible
                                            && translationPoint.y >= -captionColumn.spacing / 2
                                            && translationPoint.y <= translationPreview.height
                                                + captionColumn.spacing / 2
                                            ? "translation" : "spoken"
                                        dialog.controller.setSelected("caption", styleId)
                                        previewCanvas.forceActiveFocus()
                                        var point = captionMouse.mapToItem(previewCanvas, mouse.x, mouse.y)
                                        startCanvasX = point.x
                                        startCanvasY = point.y
                                        startNormX = dialog.previewLearningBlock
                                            ? dialog.overlayPreviewX : dialog.captionPreviewX
                                        startNormY = dialog.previewLearningBlock
                                            ? dialog.overlayPreviewY : dialog.captionPreviewY
                                        dialog.captionDragging = true
                                    }
                                    onPositionChanged: function(mouse) {
                                        if (!pressed)
                                            return
                                        var point = captionMouse.mapToItem(previewCanvas, mouse.x, mouse.y)
                                        var nextX = dialog.clampNorm(startNormX + (point.x - startCanvasX) / previewCanvas.width)
                                        var nextY = dialog.clampNorm(startNormY + (point.y - startCanvasY) / previewCanvas.height)
                                        if (dialog.previewLearningBlock) {
                                            dialog.overlayPreviewX = nextX
                                            dialog.overlayPreviewY = nextY
                                        } else {
                                            dialog.captionPreviewX = nextX
                                            dialog.captionPreviewY = nextY
                                        }
                                    }
                                    onReleased: {
                                        if (dialog.previewLearningBlock)
                                            dialog.controller.setObjectPosition("overlay", dialog.overlayPreviewX, dialog.overlayPreviewY)
                                        else
                                            dialog.controller.setObjectPosition("caption", dialog.captionPreviewX, dialog.captionPreviewY)
                                        dialog.captionDragging = false
                                        dialog.syncPreviewPositions()
                                    }
                                    onCanceled: {
                                        dialog.captionDragging = false
                                        dialog.syncPreviewPositions()
                                    }
                                }
                            }

                            Item {
                                id: overlayBox
                                objectName: "overlayPlacementBox"
                                width: previewCanvas.width * Number((dialog.overlayPlan.pos || {}).box_width_norm || 0.72)
                                height: overlayColumn.implicitHeight + VfTheme.dp(8)
                                x: dialog.overlayPreviewX * previewCanvas.width - width / 2
                                y: dialog.overlayPreviewY * previewCanvas.height - height / 2
                                z: dialog.selectedObject === "overlay" ? 3 : 2
                                visible: dialog.subtitleEnabled && dialog.overlayEnabled

                                SubtitleMotionPreview {
                                    id: overlayMotionFrame
                                    objectName: "subtitleRealtimeOverlayMotion"
                                    anchors.fill: parent
                                    motion: dialog.previewMotion
                                    effect: dialog.previewEffect
                                    playhead: dialog.realtimePreviewPlayhead
                                    strength: dialog.previewMotionStrength
                                    canvasWidth: previewCanvas.width
                                    canvasHeight: previewCanvas.height
                                    motionEnabled: !dialog.captionDragging && !dialog.overlayDragging

                                    Rectangle {
                                        objectName: "overlayRenderedPanel"
                                        anchors.fill: parent
                                        radius: VfTheme.dp(5)
                                        color: String((dialog.plan.chrome || {}).panel || "preset") === "off"
                                            ? "transparent"
                                            : dialog.alphaColor(
                                                (dialog.plan.chrome || {}).panel_fill || "080B12",
                                                (dialog.plan.chrome || {}).panel_alpha || 0)
                                        border.width: 0
                                    }

                                    Column {
                                        id: overlayColumn
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.leftMargin: 8 * previewCanvas.height
                                            / Math.max(1, Number(dialog.canvasPlan.height || 1080))
                                        anchors.rightMargin: anchors.leftMargin
                                        spacing: Number(dialog.learningStackPlan.row_gap_px || 8)
                                            * previewCanvas.height / Math.max(1, Number(dialog.canvasPlan.height || 1080))

                                    Text {
                                        id: lemmaPreview
                                        objectName: "overlayLemmaPreview"
                                        readonly property string resolvedFontFamily: font.family
                                        property string renderedPreviewText: Boolean((dialog.overlayPlan.lemma || {}).uppercase)
                                            ? String(dialog.previewCue.lemma || "HOT").toUpperCase()
                                            : String(dialog.previewCue.lemma || "HOT")
                                        property var fittedPreviewLayout: dialog.previewTextLayout(
                                            renderedPreviewText,
                                            dialog.overlayPlan.lemma,
                                            Number((dialog.overlayPlan.pos || {}).box_width_px || 1))
                                        width: parent.width
                                        text: fittedPreviewLayout.text
                                        color: dialog.hexColor((dialog.overlayPlan.lemma || {}).accent, "FACC15")
                                        font.family: dialog.previewFontFamily(
                                            lemmaFontLoader,
                                            dialog.overlayPlan.lemma,
                                            String(dialog.previewCue.preview_language || "en"),
                                            false)
                                        font.pixelSize: dialog.scaledDesignFont(fittedPreviewLayout.font_px)
                                        fontSizeMode: Text.HorizontalFit
                                        minimumPixelSize: 1
                                        font.weight: Number((dialog.overlayPlan.lemma || {}).weight || 900)
                                        font.italic: Boolean((dialog.overlayPlan.lemma || {}).italic)
                                        font.underline: Boolean((dialog.overlayPlan.lemma || {}).underline)
                                        font.strikeout: Boolean((dialog.overlayPlan.lemma || {}).strike)
                                        font.letterSpacing: Number((dialog.overlayPlan.lemma || {}).tracking_px || 0)
                                            * previewCanvas.height / Math.max(1, Number(dialog.canvasPlan.height || 1080))
                                        horizontalAlignment: dialog.horizontalAlignment((dialog.overlayPlan.pos || {}).align)
                                        wrapMode: Text.NoWrap
                                        elide: Text.ElideNone
                                        style: dialog.scaledOutline(dialog.overlayPlan.lemma) > 0 ? Text.Outline : Text.Normal
                                        styleColor: dialog.hexColor((dialog.plan.chrome || {}).stroke, "0B1220")
                                        transform: Translate {
                                            x: dialog.previewLearningBlock
                                                ? dialog.lemmaLayerOffsetX * previewCanvas.width : 0
                                            y: dialog.previewLearningBlock
                                                ? dialog.lemmaLayerOffsetY * previewCanvas.height : 0
                                        }

                                        TextSelectionFrame {
                                            objectName: "overlayLemmaSelectionFrame"
                                            selected: !dialog.learningGroupMoveMode
                                                && dialog.selectedObject === "overlay"
                                                && dialog.selectedStyle === "lemma"
                                            textWidth: lemmaPreview.paintedWidth
                                            textHeight: lemmaPreview.paintedHeight
                                            availableWidth: lemmaPreview.width
                                            horizontalAlignment: lemmaPreview.horizontalAlignment
                                            accentColor: VfTheme.violetBorder
                                        }

                                        TapHandler {
                                            objectName: "overlayLemmaTapHandler"
                                            enabled: !dialog.previewLearningBlock
                                            onTapped: {
                                                dialog.controller.setSelected("overlay", "lemma")
                                                previewCanvas.forceActiveFocus()
                                            }
                                        }

                                        LearningLayerDragArea {
                                            objectName: "lemmaLearningLayerDragArea"
                                            anchors.fill: parent
                                            z: 30
                                            enabled: dialog.previewLearningBlock
                                                && !dialog.learningGroupMoveMode
                                            canvasItem: previewCanvas
                                            layerItem: lemmaPreview
                                            objectId: "overlay"
                                            styleId: "lemma"
                                            offsetX: dialog.lemmaLayerOffsetX
                                            offsetY: dialog.lemmaLayerOffsetY
                                            onLayerPressed: {
                                                dialog.controller.setSelected("overlay", "lemma")
                                                previewCanvas.forceActiveFocus()
                                                dialog.learningLayerDragging = "lemma"
                                                dialog.overlayDragging = true
                                            }
                                            onPreviewMoved: function(offsetX, offsetY) {
                                                dialog.lemmaLayerOffsetX = dialog.clampOffset(offsetX)
                                                dialog.lemmaLayerOffsetY = dialog.clampOffset(offsetY)
                                            }
                                            onLayerCommitted: function(offsetX, offsetY) {
                                                dialog.controller.setLearningLayerOffset(
                                                    "overlay", "lemma", offsetX, offsetY)
                                                dialog.learningLayerDragging = ""
                                                dialog.overlayDragging = false
                                                dialog.syncPreviewPositions()
                                            }
                                            onLayerCanceled: {
                                                dialog.learningLayerDragging = ""
                                                dialog.overlayDragging = false
                                                dialog.syncPreviewPositions()
                                            }
                                        }
                                    }

                                    Text {
                                        id: readingPreview
                                        objectName: "overlayReadingPreview"
                                        readonly property string resolvedFontFamily: font.family
                                        property string renderedPreviewText: String(dialog.previewCue.reading || "/hɑːt/")
                                        property var fittedPreviewLayout: dialog.previewTextLayout(
                                            renderedPreviewText,
                                            dialog.overlayPlan.reading,
                                            Number((dialog.overlayPlan.pos || {}).box_width_px || 1))
                                        width: parent.width
                                        visible: String(dialog.previewCue.reading || "").length > 0
                                        text: fittedPreviewLayout.text
                                        color: dialog.hexColor((dialog.overlayPlan.reading || {}).fill, "A5F3FC")
                                        font.family: dialog.previewFontFamily(
                                            readingFontLoader,
                                            dialog.overlayPlan.reading,
                                            "en",
                                            true)
                                        font.pixelSize: dialog.scaledDesignFont(fittedPreviewLayout.font_px)
                                        fontSizeMode: Text.HorizontalFit
                                        minimumPixelSize: 1
                                        font.weight: Number((dialog.overlayPlan.reading || {}).weight || 500)
                                        font.italic: Boolean((dialog.overlayPlan.reading || {}).italic)
                                        font.underline: Boolean((dialog.overlayPlan.reading || {}).underline)
                                        font.strikeout: Boolean((dialog.overlayPlan.reading || {}).strike)
                                        font.letterSpacing: Number((dialog.overlayPlan.reading || {}).tracking_px || 0)
                                            * previewCanvas.height / Math.max(1, Number(dialog.canvasPlan.height || 1080))
                                        horizontalAlignment: dialog.horizontalAlignment((dialog.overlayPlan.pos || {}).align)
                                        wrapMode: Text.NoWrap
                                        elide: Text.ElideNone
                                        style: dialog.scaledOutline(dialog.overlayPlan.reading) > 0 ? Text.Outline : Text.Normal
                                        styleColor: dialog.hexColor((dialog.plan.chrome || {}).stroke, "0B1220")
                                        transform: Translate {
                                            x: dialog.previewLearningBlock
                                                ? dialog.readingLayerOffsetX * previewCanvas.width : 0
                                            y: dialog.previewLearningBlock
                                                ? dialog.readingLayerOffsetY * previewCanvas.height : 0
                                        }

                                        TextSelectionFrame {
                                            objectName: "overlayReadingSelectionFrame"
                                            selected: !dialog.learningGroupMoveMode
                                                && dialog.selectedObject === "overlay"
                                                && dialog.selectedStyle === "reading"
                                            textWidth: readingPreview.paintedWidth
                                            textHeight: readingPreview.paintedHeight
                                            availableWidth: readingPreview.width
                                            horizontalAlignment: readingPreview.horizontalAlignment
                                            accentColor: VfTheme.violetBorder
                                        }

                                        TapHandler {
                                            objectName: "overlayReadingTapHandler"
                                            enabled: !dialog.previewLearningBlock
                                            onTapped: {
                                                dialog.controller.setSelected("overlay", "reading")
                                                previewCanvas.forceActiveFocus()
                                            }
                                        }

                                        LearningLayerDragArea {
                                            objectName: "readingLearningLayerDragArea"
                                            anchors.fill: parent
                                            z: 30
                                            enabled: dialog.previewLearningBlock
                                                && !dialog.learningGroupMoveMode
                                            canvasItem: previewCanvas
                                            layerItem: readingPreview
                                            objectId: "overlay"
                                            styleId: "reading"
                                            offsetX: dialog.readingLayerOffsetX
                                            offsetY: dialog.readingLayerOffsetY
                                            onLayerPressed: {
                                                dialog.controller.setSelected("overlay", "reading")
                                                previewCanvas.forceActiveFocus()
                                                dialog.learningLayerDragging = "reading"
                                                dialog.overlayDragging = true
                                            }
                                            onPreviewMoved: function(offsetX, offsetY) {
                                                dialog.readingLayerOffsetX = dialog.clampOffset(offsetX)
                                                dialog.readingLayerOffsetY = dialog.clampOffset(offsetY)
                                            }
                                            onLayerCommitted: function(offsetX, offsetY) {
                                                dialog.controller.setLearningLayerOffset(
                                                    "overlay", "reading", offsetX, offsetY)
                                                dialog.learningLayerDragging = ""
                                                dialog.overlayDragging = false
                                                dialog.syncPreviewPositions()
                                            }
                                            onLayerCanceled: {
                                                dialog.learningLayerDragging = ""
                                                dialog.overlayDragging = false
                                                dialog.syncPreviewPositions()
                                            }
                                        }
                                    }
                                }
                            }

                                MouseArea {
                                    id: overlayMouse
                                    objectName: "overlayTextHitArea"
                                    anchors.fill: parent
                                    z: -1
                                    enabled: dialog.overlayEnabled && !dialog.previewLearningBlock
                                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                                    property real startCanvasX: 0
                                    property real startCanvasY: 0
                                    property real startNormX: 0
                                    property real startNormY: 0
                                    onPressed: function(mouse) {
                                        var readingPoint = overlayMouse.mapToItem(
                                            readingPreview, mouse.x, mouse.y)
                                        var styleId = readingPreview.visible
                                            && readingPoint.y >= -overlayColumn.spacing / 2
                                            && readingPoint.y <= readingPreview.height
                                                + overlayColumn.spacing / 2
                                            ? "reading" : "lemma"
                                        dialog.controller.setSelected("overlay", styleId)
                                        previewCanvas.forceActiveFocus()
                                        var point = overlayMouse.mapToItem(previewCanvas, mouse.x, mouse.y)
                                        startCanvasX = point.x
                                        startCanvasY = point.y
                                        startNormX = dialog.overlayPreviewX
                                        startNormY = dialog.overlayPreviewY
                                        dialog.overlayDragging = true
                                    }
                                    onPositionChanged: function(mouse) {
                                        if (!pressed)
                                            return
                                        var point = overlayMouse.mapToItem(previewCanvas, mouse.x, mouse.y)
                                        dialog.overlayPreviewX = dialog.clampNorm(startNormX + (point.x - startCanvasX) / previewCanvas.width)
                                        dialog.overlayPreviewY = dialog.clampNorm(startNormY + (point.y - startCanvasY) / previewCanvas.height)
                                    }
                                    onReleased: {
                                        dialog.overlayDragging = false
                                        dialog.controller.setObjectPosition("overlay", dialog.overlayPreviewX, dialog.overlayPreviewY)
                                    }
                                    onCanceled: {
                                        dialog.overlayDragging = false
                                        dialog.syncPreviewPositions()
                                    }
                                }
                            }

                            Rectangle {
                                id: learningGroupDragBox
                                objectName: "subtitleLearningGroupDragBox"
                                readonly property real framePadding: VfTheme.dp(5)
                                readonly property real leftEdge: Math.min(
                                    captionBox.x, overlayBox.x)
                                readonly property real topEdge: Math.min(
                                    captionBox.y, overlayBox.y)
                                readonly property real rightEdge: Math.max(
                                    captionBox.x + captionBox.width,
                                    overlayBox.x + overlayBox.width)
                                readonly property real bottomEdge: Math.max(
                                    captionBox.y + captionBox.height,
                                    overlayBox.y + overlayBox.height)

                                x: leftEdge - framePadding
                                y: topEdge - framePadding
                                width: rightEdge - leftEdge + framePadding * 2
                                height: bottomEdge - topEdge + framePadding * 2
                                visible: dialog.previewLearningBlock
                                    && dialog.learningGroupMoveMode
                                z: 20
                                radius: VfTheme.dp(5)
                                color: "#147C3AED"
                                border.width: Math.max(1, VfTheme.dp(1))
                                border.color: VfTheme.violetBorder

                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: VfTheme.dp(4)
                                    width: groupDragLabel.implicitWidth + VfTheme.dp(12)
                                    height: groupDragLabel.implicitHeight + VfTheme.dp(6)
                                    radius: height / 2
                                    color: "#E67C3AED"

                                    Text {
                                        id: groupDragLabel
                                        anchors.centerIn: parent
                                        text: qsTr("KÉO CẢ BỘ")
                                        color: "#FFFFFF"
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        font.weight: Font.Bold
                                    }
                                }

                            }

                            MouseArea {
                                id: learningGroupDragSurface
                                objectName: "subtitleLearningGroupDragSurface"
                                anchors.fill: parent
                                z: 21
                                enabled: dialog.previewLearningBlock
                                    && dialog.learningGroupMoveMode
                                hoverEnabled: true
                                preventStealing: true
                                cursorShape: pressed
                                    ? Qt.ClosedHandCursor
                                    : (pointerInsideGroup
                                        ? Qt.OpenHandCursor : Qt.ArrowCursor)
                                property bool pointerInsideGroup: false
                                property real startCanvasX: 0
                                property real startCanvasY: 0
                                property real startNormX: 0
                                property real startNormY: 0

                                function isInsideGroup(canvasX, canvasY) {
                                    var point = learningGroupDragBox.mapFromItem(
                                        learningGroupDragSurface,
                                        canvasX,
                                        canvasY)
                                    return learningGroupDragBox.visible
                                        && point.x >= 0
                                        && point.y >= 0
                                        && point.x <= learningGroupDragBox.width
                                        && point.y <= learningGroupDragBox.height
                                }

                                onPressed: function(mouse) {
                                    if (!isInsideGroup(mouse.x, mouse.y)) {
                                        mouse.accepted = false
                                        return
                                    }
                                    previewCanvas.forceActiveFocus()
                                    startCanvasX = mouse.x
                                    startCanvasY = mouse.y
                                    startNormX = dialog.overlayPreviewX
                                    startNormY = dialog.overlayPreviewY
                                    dialog.learningLayerDragging = "group"
                                    dialog.captionDragging = true
                                    dialog.overlayDragging = true
                                }
                                onPositionChanged: function(mouse) {
                                    pointerInsideGroup = isInsideGroup(
                                        mouse.x, mouse.y)
                                    if (!pressed
                                            || dialog.learningLayerDragging !== "group")
                                        return
                                    dialog.overlayPreviewX = dialog.clampNorm(
                                        startNormX + (mouse.x - startCanvasX)
                                            / Math.max(1, previewCanvas.width))
                                    dialog.overlayPreviewY = dialog.clampNorm(
                                        startNormY + (mouse.y - startCanvasY)
                                            / Math.max(1, previewCanvas.height))
                                }
                                onReleased: {
                                    if (dialog.learningLayerDragging !== "group")
                                        return
                                    dialog.controller.setObjectPosition(
                                        "overlay",
                                        dialog.overlayPreviewX,
                                        dialog.overlayPreviewY)
                                    dialog.learningLayerDragging = ""
                                    dialog.captionDragging = false
                                    dialog.overlayDragging = false
                                    dialog.syncPreviewPositions()
                                }
                                onCanceled: {
                                    dialog.learningLayerDragging = ""
                                    dialog.captionDragging = false
                                    dialog.overlayDragging = false
                                    dialog.syncPreviewPositions()
                                }
                                onExited: {
                                    if (!pressed)
                                        pointerInsideGroup = false
                                }
                            }

                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(7)
                        Rectangle {
                            Layout.preferredWidth: VfTheme.dp(8)
                            Layout.preferredHeight: width
                            radius: width / 2
                            color: dialog.selectedObject === "overlay" ? VfTheme.violet : VfTheme.cyan
                        }
                        Text {
                            Layout.fillWidth: true
                            text: !dialog.portraitCanvas
                                ? qsTr("16:9 · không overlay social · subtitle dùng vùng ngang rộng hơn")
                                : (dialog.socialSafeZoneVisible
                                ? (dialog.safeZoneValue === "auto"
                                    ? qsTr("All · hợp alpha 3 asset · vùng chung 72,192 → 876,1386")
                                    : (dialog.platformChromeVisible
                                        ? String(dialog.safeZonePlan.label || "")
                                            + qsTr(" · asset PNG trong suốt · chuẩn 1080 × 1920")
                                        : String(dialog.safeZonePlan.label || qsTr("Né giao diện"))))
                                : qsTr("Không né giao diện · click lớp để kéo, phím mũi tên để tinh chỉnh"))
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                            elide: Text.ElideRight
                        }
                        Text {
                            text: dialog.previewLearningBlock
                                ? (dialog.learningGroupMoveMode
                                    ? qsTr("Đang di chuyển: CẢ BỘ 3 LỚP")
                                    : qsTr("Đang chỉnh riêng: %1").arg(dialog.selectedLayerLabel))
                                : qsTr("Đang chỉnh: CAPTION")
                            color: dialog.previewLearningBlock ? VfTheme.violetText : VfTheme.cyanText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            Rectangle {
                id: inspector
                objectName: "subtitleUnifiedContentInspector"
                Layout.preferredWidth: dialog.width >= VfTheme.dp(1460)
                    ? VfTheme.dp(338) : VfTheme.dp(300)
                Layout.fillHeight: true
                radius: VfTheme.radiusPanel
                color: VfTheme.panel
                border.width: 1
                border.color: dialog.previewLearningBlock
                    ? VfTheme.violetBorderSoft : VfTheme.cyanBorderSoft

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        objectName: "subtitleUnifiedStyleEditor"
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(58)
                        color: dialog.previewLearningBlock ? VfTheme.violetFill : VfTheme.cyanFill
                        radius: VfTheme.radiusPanel

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(10)
                            Text {
                                Layout.fillWidth: true
                                text: dialog.previewLearningBlock
                                    ? (dialog.learningGroupMoveMode
                                        ? qsTr("DI CHUYỂN CẢ BỘ 3 LỚP")
                                        : qsTr("CHỈNH RIÊNG 3 LỚP"))
                                    : qsTr("CAPTION · PHỤ ĐỀ")
                                color: dialog.previewLearningBlock ? VfTheme.violetText : VfTheme.cyanText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSection
                                font.weight: Font.Bold
                            }
                            Text {
                                text: dialog.previewLearningBlock
                                    ? (dialog.learningGroupMoveMode
                                        ? qsTr("Vị trí chung")
                                        : dialog.selectedLayerLabel)
                                    : qsTr("Lời SRT")
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                            }
                        }
                    }

                    SubtitleLearningLayerPanel {
                        active: dialog.previewLearningBlock
                        Layout.fillWidth: true
                        Layout.leftMargin: VfTheme.dp(8)
                        Layout.rightMargin: VfTheme.dp(8)
                        Layout.topMargin: VfTheme.dp(7)
                        selectedObject: dialog.selectedObject
                        selectedStyle: dialog.selectedStyle
                        groupMoveActive: dialog.learningGroupMoveMode
                        profile: dialog.draft
                        cue: dialog.previewCue
                        onGroupMoveChosen: {
                            dialog.learningGroupMoveMode = true
                            previewCanvas.forceActiveFocus()
                        }
                        onLayerChosen: function(objectId, styleId) {
                            dialog.learningGroupMoveMode = false
                            dialog.controller.setSelected(objectId, styleId)
                            previewCanvas.forceActiveFocus()
                        }
                    }

                    CommitSlider {
                        objectName: "subtitleLearningRowGapSlider"
                        visible: dialog.previewLearningBlock
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? implicitHeight : 0
                        Layout.leftMargin: VfTheme.dp(10)
                        Layout.rightMargin: VfTheme.dp(10)
                        label: qsTr("Giãn hàng · áp dụng cả bộ 3 lớp")
                        from: 0.6
                        to: 8.0
                        stepSize: 0.2
                        decimals: 1
                        suffix: "%H"
                        showStepButtons: true
                        value: Number((((dialog.draft || {}).learning_stack || {}).row_gap)
                            || 0.022) * 100
                        onCommitted: function(value) {
                            dialog.controller.setLearningRowGap(value / 100)
                        }
                    }

                    RowLayout {
                        visible: !dialog.previewLearningBlock
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? VfTheme.dp(42) : 0
                        Layout.leftMargin: VfTheme.dp(8)
                        Layout.rightMargin: VfTheme.dp(8)
                        Layout.topMargin: VfTheme.dp(6)
                        spacing: VfTheme.dp(5)

                        Repeater {
                            model: dialog.inspectorTabs
                            delegate: VfChip {
                                id: styleTab
                                required property var modelData
                                Layout.fillWidth: true
                                minWidth: VfTheme.dp(90)
                                text: String(modelData.label)
                                showLeadingIcon: false
                                accent: String(modelData.objectId) === "overlay"
                                    ? VfTheme.violet : VfTheme.cyan
                                selected: dialog.selectedObject === String(modelData.objectId)
                                    && dialog.selectedStyle === String(modelData.styleId)
                                onClicked: dialog.controller.setSelected(
                                    String(styleTab.modelData.objectId),
                                    String(styleTab.modelData.styleId))
                            }
                        }
                    }

                    ScrollView {
                        id: inspectorScroll
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded

                        ColumnLayout {
                            width: inspectorScroll.availableWidth
                            spacing: VfTheme.dp(8)

                            Item { Layout.preferredHeight: 1 }

                            Rectangle {
                                id: fontFamilyControl
                                objectName: "subtitleFontFamilyControl"
                                property string displayName: dialog.selectedFontName
                                property string sourceLabel: dialog.selectedFontSource
                                Layout.fillWidth: true
                                Layout.leftMargin: VfTheme.dp(10)
                                Layout.rightMargin: VfTheme.dp(10)
                                Layout.preferredHeight: VfTheme.dp(52)
                                radius: VfTheme.dp(8)
                                color: fontFamilyMouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface
                                border.width: 1
                                border.color: fontFamilyControl.activeFocus
                                    ? VfTheme.primary : VfTheme.borderStrong
                                activeFocusOnTab: true
                                Accessible.role: Accessible.Button
                                Accessible.name: qsTr("Chọn phông chữ") + " · " + dialog.selectedFontName
                                Keys.onEnterPressed: fontPopup.open()
                                Keys.onReturnPressed: fontPopup.open()
                                Keys.onSpacePressed: fontPopup.open()

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(8)
                                    spacing: VfTheme.dp(7)

                                    VfIcon {
                                        name: "file-text"
                                        size: VfTheme.dp(18)
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0

                                        Text {
                                            Layout.fillWidth: true
                                            text: qsTr("Phông chữ")
                                            color: VfTheme.textMuted
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontTiny
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: dialog.selectedFontName
                                            color: VfTheme.text
                                            font.family: dialog.previewFontFamily(
                                                dialog.selectedObject === "overlay"
                                                    ? (dialog.selectedStyle === "reading"
                                                        ? readingFontLoader : lemmaFontLoader)
                                                    : (dialog.selectedStyle === "translation"
                                                        ? translationFontLoader : spokenFontLoader),
                                                dialog.selectedStyleData)
                                            font.pixelSize: VfTheme.fontControl
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: sourceBadgeText.implicitWidth + VfTheme.dp(14)
                                        Layout.preferredHeight: VfTheme.dp(24)
                                        radius: height / 2
                                        color: VfTheme.blueFill
                                        border.width: 1
                                        border.color: VfTheme.blueBorder

                                        Text {
                                            id: sourceBadgeText
                                            anchors.centerIn: parent
                                            text: dialog.selectedFontSource
                                            color: VfTheme.blueText
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontTiny
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                MouseArea {
                                    id: fontFamilyMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        fontFamilyControl.forceActiveFocus()
                                        fontPopup.open()
                                    }
                                }
                            }

                            CommitSlider {
                                objectName: "subtitleFontSizeSlider"
                                Layout.fillWidth: true
                                Layout.leftMargin: VfTheme.dp(10)
                                Layout.rightMargin: VfTheme.dp(10)
                                label: dialog.previewLearningBlock
                                    ? qsTr("Cỡ chữ riêng · %1").arg(dialog.selectedLayerLabel)
                                    : qsTr("Cỡ chữ")
                                from: 0.35
                                to: 2.5
                                stepSize: 0.05
                                decimals: 2
                                suffix: "×"
                                showStepButtons: dialog.previewLearningBlock
                                value: Number(dialog.selectedStyleData.scale === undefined ? 1.0 : dialog.selectedStyleData.scale)
                                onCommitted: function(value) {
                                    dialog.controller.patchStyle(dialog.selectedObject, dialog.selectedStyle, "scale", value)
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: VfTheme.dp(10)
                                Layout.rightMargin: VfTheme.dp(10)
                                spacing: VfTheme.dp(5)

                                Repeater {
                                    model: [
                                        { label: "B", key: "weight", active: Number(dialog.selectedStyleData.weight || 500) >= 700 },
                                        { label: "I", key: "italic", active: Boolean(dialog.selectedStyleData.italic) },
                                        { label: "U", key: "underline", active: Boolean(dialog.selectedStyleData.underline) },
                                        { label: "AA", key: "uppercase", active: Boolean(dialog.selectedStyleData.uppercase) }
                                    ]
                                    delegate: VfChip {
                                        id: traitChip
                                        required property var modelData
                                        Layout.fillWidth: true
                                        minWidth: VfTheme.dp(48)
                                        text: String(modelData.label)
                                        showLeadingIcon: false
                                        accent: dialog.selectedObject === "overlay" ? VfTheme.violet : VfTheme.cyan
                                        selected: Boolean(modelData.active)
                                        onClicked: {
                                            var key = String(traitChip.modelData.key)
                                            var value = key === "weight"
                                                ? (traitChip.modelData.active ? 600 : 800)
                                                : !Boolean(traitChip.modelData.active)
                                            dialog.controller.patchStyle(dialog.selectedObject, dialog.selectedStyle, key, value)
                                        }
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                Layout.leftMargin: VfTheme.dp(10)
                                Layout.rightMargin: VfTheme.dp(10)
                                text: qsTr("MÀU")
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                font.weight: Font.Bold
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: VfTheme.dp(10)
                                Layout.rightMargin: VfTheme.dp(10)
                                Layout.preferredHeight: VfTheme.dp(44)
                                radius: VfTheme.dp(7)
                                color: VfTheme.surfaceSoft
                                border.width: 1
                                border.color: VfTheme.border

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(7)
                                    Text {
                                        Layout.fillWidth: true
                                        text: dialog.colorLabel()
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontControl
                                        font.weight: Font.DemiBold
                                    }
                                    Rectangle {
                                        Layout.preferredWidth: VfTheme.dp(52)
                                        Layout.fillHeight: true
                                        radius: VfTheme.dp(5)
                                        color: dialog.hexColor(dialog.selectedStyleData[dialog.colorKey()], "FFFFFF")
                                        border.width: 1
                                        border.color: VfTheme.borderStrong
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        dialog.activeColorKey = dialog.colorKey()
                                        styleColorDialog.selectedColor = dialog.hexColor(
                                            dialog.selectedStyleData[dialog.activeColorKey], "FFFFFF")
                                        styleColorDialog.open()
                                    }
                                }
                            }

                            Rectangle {
                                visible: dialog.selectedObject === "caption" && dialog.selectedStyle === "spoken"
                                Layout.fillWidth: true
                                Layout.leftMargin: VfTheme.dp(10)
                                Layout.rightMargin: VfTheme.dp(10)
                                Layout.preferredHeight: visible ? VfTheme.dp(44) : 0
                                radius: VfTheme.dp(7)
                                color: VfTheme.surfaceSoft
                                border.width: 1
                                border.color: VfTheme.border

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(7)
                                    Text {
                                        Layout.fillWidth: true
                                        text: qsTr("Màu nhấn karaoke")
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontControl
                                        font.weight: Font.DemiBold
                                    }
                                    Rectangle {
                                        Layout.preferredWidth: VfTheme.dp(52)
                                        Layout.fillHeight: true
                                        radius: VfTheme.dp(5)
                                        color: dialog.hexColor(dialog.selectedStyleData.accent, "FACC15")
                                        border.width: 1
                                        border.color: VfTheme.borderStrong
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        dialog.activeColorKey = "accent"
                                        styleColorDialog.selectedColor = dialog.hexColor(dialog.selectedStyleData.accent, "FACC15")
                                        styleColorDialog.open()
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                Layout.leftMargin: VfTheme.dp(10)
                                Layout.rightMargin: VfTheme.dp(10)
                                text: qsTr("BỐ CỤC OBJECT")
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                font.weight: Font.Bold
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: VfTheme.dp(10)
                                Layout.rightMargin: VfTheme.dp(10)
                                spacing: VfTheme.dp(5)

                                Repeater {
                                    model: [
                                        { label: qsTr("Trái"), value: "left" },
                                        { label: qsTr("Giữa"), value: "center" },
                                        { label: qsTr("Phải"), value: "right" }
                                    ]
                                    delegate: VfChip {
                                        id: alignChip
                                        required property var modelData
                                        Layout.fillWidth: true
                                        minWidth: VfTheme.dp(76)
                                        text: String(modelData.label)
                                        showLeadingIcon: false
                                        selected: dialog.effectiveSelectedAlignment === String(modelData.value)
                                        onClicked: dialog.setSelectedAlignment(String(alignChip.modelData.value))
                                    }
                                }
                            }

                            CommitSlider {
                                objectName: "subtitleBoxWidthSlider"
                                Layout.fillWidth: true
                                Layout.leftMargin: VfTheme.dp(10)
                                Layout.rightMargin: VfTheme.dp(10)
                                label: qsTr("Độ rộng box")
                                from: 0.25
                                to: 0.96
                                stepSize: 0.01
                                decimals: 2
                                value: Number(dialog.selectedGeomData.box_width === undefined ? 0.72 : dialog.selectedGeomData.box_width)
                                onCommitted: function(value) { dialog.controller.setObjectBoxWidth(dialog.selectedObject, value) }
                            }

                            CommitSlider {
                                objectName: "subtitleOutlineSlider"
                                Layout.fillWidth: true
                                Layout.leftMargin: VfTheme.dp(10)
                                Layout.rightMargin: VfTheme.dp(10)
                                label: qsTr("Viền")
                                from: 0
                                to: 3
                                stepSize: 0.1
                                decimals: 1
                                suffix: "×"
                                value: Number(dialog.selectedStyleData.outline_scale === undefined ? 1 : dialog.selectedStyleData.outline_scale)
                                onCommitted: function(value) {
                                    dialog.controller.patchStyle(dialog.selectedObject, dialog.selectedStyle, "outline_scale", value)
                                }
                            }

                            CommitSlider {
                                objectName: "subtitleShadowSlider"
                                Layout.fillWidth: true
                                Layout.leftMargin: VfTheme.dp(10)
                                Layout.rightMargin: VfTheme.dp(10)
                                label: qsTr("Bóng")
                                from: 0
                                to: 3
                                stepSize: 0.1
                                decimals: 1
                                suffix: "×"
                                value: Number(dialog.selectedStyleData.shadow_scale === undefined ? 1 : dialog.selectedStyleData.shadow_scale)
                                onCommitted: function(value) {
                                    dialog.controller.patchStyle(dialog.selectedObject, dialog.selectedStyle, "shadow_scale", value)
                                }
                            }

                            CommitSlider {
                                objectName: "subtitleTrackingSlider"
                                Layout.fillWidth: true
                                Layout.leftMargin: VfTheme.dp(10)
                                Layout.rightMargin: VfTheme.dp(10)
                                Layout.bottomMargin: VfTheme.dp(12)
                                label: qsTr("Giãn chữ")
                                from: -0.08
                                to: 0.20
                                stepSize: 0.01
                                decimals: 2
                                value: Number(dialog.selectedStyleData.tracking || 0)
                                onCommitted: function(value) {
                                    dialog.controller.patchStyle(dialog.selectedObject, dialog.selectedStyle, "tracking", value)
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
            Layout.preferredHeight: VfTheme.dp(58)
            Layout.leftMargin: VfTheme.dp(12)
            Layout.rightMargin: VfTheme.dp(12)
            Layout.bottomMargin: VfTheme.dp(8)
            spacing: VfTheme.dp(8)

            VfButton {
                text: qsTr("Khôi phục đề xuất")
                onClicked: dialog.controller.resetDraft()
            }

            Text {
                Layout.fillWidth: true
                text: dialog.localError.length > 0
                    ? dialog.localError
                    : (String(dialog.controller.autosaveStatus || "").length > 0
                        ? String(dialog.controller.autosaveStatus)
                        : (String(dialog.controller.statusMessage || "").length > 0
                            ? String(dialog.controller.statusMessage)
                            : qsTr("Tự lưu lựa chọn · dùng cho job mới")))
                color: dialog.localError.length > 0 ? VfTheme.redText : VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            VfButton {
                text: qsTr("Đóng")
                onClicked: dialog.close()
            }

            VfButton {
                objectName: "subtitleApplyButton"
                enabled: !dialog.applyPending
                tone: "primary"
                text: dialog.applyPending ? qsTr("ĐANG ÁP DỤNG…") : qsTr("ÁP DỤNG")
                onClicked: {
                    dialog.applyPending = true
                    dialog.localError = ""
                    var result = dialog.controller.applyToRoute()
                    if (!result || !result.ok) {
                        dialog.applyPending = false
                        dialog.localError = String((result || {}).message || qsTr("Không thể áp dụng"))
                    }
                }
            }
        }
    }
}
