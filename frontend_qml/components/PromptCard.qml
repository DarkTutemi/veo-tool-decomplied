import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"
import "MediaSourceResolver.js" as MediaSourceResolver

Rectangle {
    id: root

    property var card: ({})
    // Renamed from "index": a delegate property named "index" shadows the
    // view's context index, so "index: index" self-binds to 0 (all cards "#1").
    property int promptIndex: 0
    property bool selected: false
    property string route: "normal"
    property string mode: String(card.mode || card.card_type || card.type || "text")
    property bool isExtendCard: Boolean(card.is_extend_card || card.is_extend || false)
    property bool showCardType: !isExtendCard && String(route).indexOf("extend") >= 0
    // Extend cards store a JSON scene in `prompt` — too big to edit inline, so on the extend
    // route the prompt box is read-only and a click opens the full edit dialog instead.
    readonly property bool _isExtendRoute: String(route).indexOf("extend") >= 0
    property bool showExtendButton: Boolean(card.show_extend || false)
    property bool showInsertAfterButton: Boolean(card.show_insert_after || false)
    property bool showGenerateExtendButton: Boolean(card.show_generate_extend || false)
    property bool showRemoveTimelineButton: Boolean(card.show_remove_timeline || false)
    // Route workspace may opt into a taller editor without forking PromptCard.
    // Default preserves the compact cards used by Normal/Batch/Clone.
    property int promptEditorHeight: VfTheme.dp(52)
    property int maxMultiAssetReferenceImages: 7
    property int multiAssetReferenceLimit: maxMultiAssetReferenceImages
    property int multiAssetVoiceReferenceLimit: 0
    property var multiAssetVoiceReferences: []
    property int _multiAssetAssetLimit: maxMultiAssetReferenceImages
    property int _multiAssetVoiceLimit: 0
    property bool _multiAssetVoiceSlotsExpanded: false
    readonly property var _slotDefs: slotDefinitions()

    signal editRequested(var card)
    signal duplicateRequested(var card)
    signal deleteRequested(var card)
    signal mediaRequested(var card)
    signal submitRequested(var card)
    signal actionRequested(string actionId, var payload)

    implicitHeight: Math.max(70, cardBody.implicitHeight + 12)
    radius: VfTheme.dp(8)
    color: root.selected ? VfTheme.blueFill : VfTheme.surface
    border.width: 1
    border.color: root.selected ? VfTheme.primary : VfTheme.borderStrong
    clip: true

    Component.onCompleted: root.set_multi_asset_slot_limits(root.multiAssetReferenceLimit, root.multiAssetVoiceReferenceLimit)
    onMultiAssetReferenceLimitChanged: root.set_multi_asset_slot_limits(root.multiAssetReferenceLimit, root.multiAssetVoiceReferenceLimit)
    onMultiAssetVoiceReferenceLimitChanged: root.set_multi_asset_slot_limits(root.multiAssetReferenceLimit, root.multiAssetVoiceReferenceLimit)
    onModeChanged: {
        if (root.mode !== "multi_asset")
            root.show_multi_asset_voice_slots(false)
    }

    function textValue(key, fallback) {
        if (root.card && root.card[key] !== undefined && root.card[key] !== null && String(root.card[key]).length > 0)
            return String(root.card[key])
        return fallback || ""
    }

    function promptText() {
        return textValue("prompt", textValue("text", ""))
    }

    function cardId() {
        return textValue("id", textValue("row_id", textValue("batch_id", "")))
    }

    function labelText() {
        if (root.isExtendCard)
            return textValue("extend_label", (void i18n.revision, i18n.t("prompt_card.extend_label", "Extend #{position}")).replace("{position}", String(root.promptIndex + 1)))
        // ROOT shows its 1-based ROOT number (counting ROOT cards only), not the
        // flat Repeater index which also counts extend cards.
        return (void i18n.revision, i18n.t("prompt_card.prompt_label", "PROMPT: #{num}")).replace("{num}", textValue("display_number", String(root.promptIndex + 1)))
    }

    function durationLabel() {
        var raw = root.card ? (root.card.duration_seconds || root.card.duration || "") : ""
        var value = Number(raw || 0)
        if (value > 0)
            return String(value) + "s"
        var marker = textValue("duration_marker", "")
        return marker
    }

    function actionPayload(actionId, slotType) {
        return {
            action_id: actionId,
            card_id: root.cardId(),
            row_id: root.cardId(),
            route: root.route,
            index: root.promptIndex,
            mode: root.mode,
            card_mode: root.mode,
            button_type: slotType || "",
            card: root.card
        }
    }

    function requestCardAction(actionId, slotType) {
        var payload = root.actionPayload(actionId, slotType)
        root.actionRequested(actionId, payload)
        if (actionId === "prompt_card.media") {
            root.mediaRequested(root.card)
        } else if (actionId === "prompt_card.edit") {
            root.editRequested(root.card)
        } else if (actionId === "prompt_card.duplicate") {
            root.duplicateRequested(root.card)
        } else if (actionId === "prompt_card.delete") {
            root.deleteRequested(root.card)
        } else if (actionId === "prompt_card.submit") {
            root.submitRequested(root.card)
        }
    }

    function set_multi_asset_slot_limits(asset_slots, voice_slots) {
        root._multiAssetAssetLimit = Math.max(1, Number(asset_slots || root.maxMultiAssetReferenceImages || 1))
        root._multiAssetVoiceLimit = Math.max(0, Number(voice_slots || 0))
        if (root._multiAssetVoiceLimit <= 0)
            root._multiAssetVoiceSlotsExpanded = false
    }

    function show_multi_asset_voice_slots(expanded) {
        root._multiAssetVoiceSlotsExpanded = Boolean(expanded) && root._multiAssetVoiceLimit > 0
    }

    function slotAsset(slotType) {
        // card.assets arrives as a QVariantList through the model layer — Array.isArray() returns
        // FALSE for it, so the slots read empty even though the backend attached the images. Copy by
        // .length into a real JS array (same fix as JobPanelCard.firstArrayValue).
        var raw = root.card ? root.card.assets : null
        var assets = []
        if (raw && typeof raw !== "string" && raw.length !== undefined) {
            for (var k = 0; k < raw.length; k++)
                assets.push(raw[k] || ({}))
        }
        // I2V: single image, or start/end for 2-image interpolation.
        if (root.mode === "image_single")
            return assets.length > 0 ? (assets[0] || ({})) : ({})
        if (root.mode === "image_interpolation") {
            if (slotType === "start")
                return assets.length > 0 ? (assets[0] || ({})) : ({})
            if (slotType === "end")
                return assets.length > 1 ? (assets[1] || ({})) : ({})
        }
        if (root.mode === "multi_asset" && String(slotType).indexOf("asset") === 0) {
            var assetIndex = Number(String(slotType).slice(5)) - 1
            if (assetIndex < 0)
                return ({})
            // Backend stores assets DENSE but tags each with its slot_index (slots can be
            // filled out of order), so match by the tag — reading positionally put the image
            // in the wrong slot (or none). Fall back to positional for untagged/legacy data.
            for (var i = 0; i < assets.length; i++) {
                var a = assets[i] || ({})
                var si = (a.slot_index !== undefined && a.slot_index !== null) ? Number(a.slot_index) : i
                if (si === assetIndex)
                    return a
            }
            if (assetIndex < assets.length)
                return assets[assetIndex] || ({})
        }
        return ({})
    }

    function multiAssetVoiceReference(slotType) {
        var items = Array.isArray(root.multiAssetVoiceReferences) ? root.multiAssetVoiceReferences : []
        var voiceIndex = Number(String(slotType).slice(5)) - 1
        if (voiceIndex >= 0 && voiceIndex < items.length)
            return items[voiceIndex] || ({})
        return ({})
    }

    function slotDefinitions() {
        // I2V single image (one slot) or 2-image interpolation (start + end).
        if (root.mode === "image_single")
            return [{ label: (void i18n.revision, i18n.t("prompt_card.add_image", "+ Image")), type: "single", isVoiceSlot: false }]
        if (root.mode === "image_interpolation")
            return [
                { label: (void i18n.revision, i18n.t("prompt_card.add_start", "+ Start")), type: "start", isVoiceSlot: false },
                { label: (void i18n.revision, i18n.t("prompt_card.add_end", "+ End")), type: "end", isVoiceSlot: false }
            ]
        if (root.mode === "multi_asset") {
            var slots = []
            for (var i = 1; i <= root._multiAssetAssetLimit; ++i) {
                slots.push({
                    label: (void i18n.revision, i18n.t("prompt_card.add_asset", "+ Asset {index}")).replace("{index}", String(i)),
                    type: "asset" + String(i),
                    isVoiceSlot: false
                })
            }
            if (root._multiAssetVoiceSlotsExpanded) {
                for (var j = 1; j <= root._multiAssetVoiceLimit; ++j) {
                    var voiceRef = root.multiAssetVoiceReference("voice" + String(j))
                    slots.push({
                        label: String(voiceRef.name || voiceRef.label || voiceRef.media_id || voiceRef.id || "")
                            || (void i18n.revision, i18n.t("prompt_card.add_voice", "+ Voice {index}")).replace("{index}", String(j)),
                        type: "voice" + String(j),
                        isVoiceSlot: true
                    })
                }
            }
            return slots
        }
        return []
    }

    function slotPath(slotType) {
        if (String(slotType).indexOf("voice") === 0)
            return ""
        if (root.card && root.card.image_paths && root.card.image_paths[slotType])
            return String(root.card.image_paths[slotType])
        if (root.card && root.card.images && root.card.images[slotType])
            return String(root.card.images[slotType])
        var asset = root.slotAsset(slotType)
        if (asset && asset.preview_path)
            return String(asset.preview_path)
        if (asset && asset.path)
            return String(asset.path)
        if (asset && asset.source_path)
            return String(asset.source_path)
        if (asset && asset.file_path)
            return String(asset.file_path)
        return ""
    }

    function normalizedImageSource(rawValue) {
        return MediaSourceResolver.normalizedImageSource(rawValue)
    }

    function appendImageSource(target, rawValue) {
        var source = root.normalizedImageSource(rawValue)
        if (source.length === 0 || target.indexOf(source) >= 0)
            return
        target.push(source)
    }

    function appendBase64ImageSource(target, rawValue) {
        var raw = String(rawValue || "").trim()
        if (raw.length === 0)
            return
        if (raw.indexOf("data:") === 0) {
            root.appendImageSource(target, raw)
            return
        }
        var source = MediaSourceResolver.dataImageUrl(raw)
        if (target.indexOf(source) < 0)
            target.push(source)
    }

    function slotImageSources(slotData) {
        var slotType = typeof slotData === "object" ? String(slotData.type || "") : String(slotData || "")
        if (slotType.indexOf("voice") === 0)
            return []
        var asset = root.slotAsset(slotType)
        var sources = []
        if (asset) {
            root.appendBase64ImageSource(sources, asset.thumbnail_base64 || "")
            root.appendImageSource(sources, asset.thumbnail_file_url || "")
            root.appendImageSource(sources, asset.thumbnail_url || "")
            root.appendImageSource(sources, asset.preview_url || "")
            root.appendImageSource(sources, asset.blob_file_url || "")
            root.appendImageSource(sources, asset.thumbnail_path || "")
            root.appendImageSource(sources, asset.thumbnail_file_path || "")
            root.appendImageSource(sources, asset.file_url || "")
            root.appendImageSource(sources, asset.blob_path || "")
            root.appendImageSource(sources, asset.preview_path || "")
            root.appendImageSource(sources, asset.original_source_path || "")
            root.appendImageSource(sources, asset.path || "")
            root.appendImageSource(sources, asset.source_path || "")
            root.appendImageSource(sources, asset.file_path || "")
            root.appendBase64ImageSource(sources, asset.image_base64 || "")
            root.appendBase64ImageSource(sources, asset.base64 || "")
            root.appendImageSource(sources, asset.thumbnail || "")
        }
        root.appendImageSource(sources, root.slotPath(slotType))
        return sources
    }

    function slotImageSource(slotData) {
        var sources = root.slotImageSources(slotData)
        return sources.length > 0 ? String(sources[0] || "") : ""
    }

    function slotLabelText(slotData) {
        if (slotData.isVoiceSlot) {
            var voiceRef = root.multiAssetVoiceReference(slotData.type)
            return String(voiceRef.name || voiceRef.label || voiceRef.media_id || voiceRef.id || slotData.label)
        }
        var asset = root.slotAsset(slotData.type)
        var assetName = String(asset.name || asset.title || asset.file_name || "")
        if (assetName.length > 0)
            return assetName
        var path = root.slotPath(slotData.type)
        if (path.length > 0)
            return path.split(/[\\/]/).pop().slice(0, 18)
        return slotData.label
    }

    function slotHasValue(slotData) {
        if (slotData.isVoiceSlot) {
            var voiceRef = root.multiAssetVoiceReference(slotData.type)
            return String(voiceRef.media_id || voiceRef.id || voiceRef.name || "").length > 0
        }
        return root.slotImageSources(slotData).length > 0 || root.slotPath(slotData.type).length > 0 || root.slotLabelText(slotData) !== slotData.label
    }

    function modeIndex() {
        // image_interpolation is the 2-image variant of I2V → show the I2V badge.
        var value = String(root.mode) === "image_interpolation" ? "image_single" : String(root.mode)
        for (var i = 0; i < cardTypeCombo.model.length; i++) {
            if (String(cardTypeCombo.model[i].value) === value)
                return i
        }
        return 0
    }

    ColumnLayout {
        id: cardBody
        anchors.fill: parent
        anchors.margins: VfTheme.dp(8)
        spacing: VfTheme.dp(6)

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(28)
            spacing: VfTheme.dp(8)

            CheckBox {
                Layout.preferredWidth: VfTheme.dp(22)
                Layout.preferredHeight: VfTheme.dp(22)
                checked: root.selected
                visible: !root.isExtendCard
                onToggled: root.actionRequested("prompt_card.selection", root.actionPayload("prompt_card.selection", checked ? "checked" : "unchecked"))
            }

            Text {
                Layout.fillWidth: true
                // Allow the label to shrink (and elide) so inline action buttons never
                // overflow the header row. Without a minimumWidth a Text keeps its full
                // implicit width and pushes buttons past the card edge.
                Layout.minimumWidth: VfTheme.dp(30)
                text: root.labelText()
                color: root.isExtendCard ? VfTheme.primary : "#333333"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                font.weight: Font.Bold
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Rectangle {
                visible: root.durationLabel().length > 0
                Layout.preferredWidth: visible ? Math.max(46, durationBadgeText.implicitWidth + 16) : 0
                Layout.preferredHeight: VfTheme.dp(24)
                radius: VfTheme.dp(12)
                color: VfTheme.amberFill
                border.width: 1
                border.color: "#F59E0B"

                Text {
                    id: durationBadgeText
                    anchors.centerIn: parent
                    text: root.durationLabel()
                    color: VfTheme.amberText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    font.weight: Font.Bold
                }
            }

            ComboBox {
                id: cardTypeCombo

                visible: root.showCardType
                Layout.preferredWidth: VfTheme.dp(74)   // snug: "R2V" + chevron, no big gap
                Layout.preferredHeight: VfTheme.dp(28)
                // ROOT generation type badge — T2V / I2V / R2V for the chain's first
                // scene. I2V is one image (image_single); a 2nd image attached upgrades
                // it to interpolation at dispatch. R2V = ingredients (multi-asset).
                model: [
                    { label: (void i18n.revision, i18n.t("prompt_card.mode_t2v", "T2V")), value: "text" },
                    { label: (void i18n.revision, i18n.t("prompt_card.mode_i2v", "I2V")), value: "image_single" },
                    { label: (void i18n.revision, i18n.t("prompt_card.mode_r2v", "R2V")), value: "multi_asset" }
                ]
                textRole: "label"
                valueRole: "value"
                currentIndex: root.modeIndex()
                onActivated: {
                    root.mode = String(currentValue)
                    if (root.card) {
                        root.card.mode = root.mode
                        root.card.card_mode = root.mode
                    }
                    root.actionRequested("prompt_card.type_changed", root.actionPayload("prompt_card.type_changed", root.mode))
                }

                // Explicit delegate — the default native item delegate renders greyed/broken
                // on this custom style. Theme the popup rows cleanly.
                delegate: ItemDelegate {
                    width: cardTypeCombo.width
                    height: VfTheme.dp(30)
                    contentItem: Text {
                        leftPadding: VfTheme.dp(10)
                        text: (modelData && modelData.label !== undefined) ? modelData.label : String(modelData)
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: VfTheme.dp(4)
                        color: cardTypeCombo.highlightedIndex === index ? VfTheme.violetFill : "transparent"
                    }
                }

                contentItem: Text {
                    leftPadding: VfTheme.dp(10)
                    rightPadding: VfTheme.dp(20)
                    text: cardTypeCombo.displayText
                    color: VfTheme.violetText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    radius: VfTheme.dp(14)
                    color: VfTheme.violetFill
                    border.width: 1
                    border.color: "#8B5CF6"
                }

                // Crisp down-chevron drawn as 2 strokes (replaces the stray "v" letter).
                indicator: Canvas {
                    x: cardTypeCombo.width - width - VfTheme.dp(9)
                    y: Math.round((cardTypeCombo.height - height) / 2)
                    width: VfTheme.dp(10)
                    height: VfTheme.dp(6)
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.strokeStyle = VfTheme.violetText
                        ctx.lineWidth = 1.5
                        ctx.lineCap = "round"
                        ctx.beginPath()
                        ctx.moveTo(1, 1)
                        ctx.lineTo(width / 2, height - 1)
                        ctx.lineTo(width - 1, 1)
                        ctx.stroke()
                    }
                }

                popup: Popup {
                    y: cardTypeCombo.height + 4
                    width: cardTypeCombo.width
                    padding: 4
                    background: Rectangle {
                        color: VfTheme.surface
                        border.color: VfTheme.border
                        border.width: 1
                        radius: 6
                    }
                    contentItem: ListView { // perf-lint: disable=R1  static combobox popup (3 items)
                        clip: true
                        implicitHeight: contentHeight
                        model: cardTypeCombo.delegateModel
                        currentIndex: cardTypeCombo.highlightedIndex
                    }
                }
            }

            VfButton {
                actionId: "prompt_card.delete"
                text: (void i18n.revision, i18n.t("prompt_card.delete", "Delete"))
                tone: "danger"
                minWidth: VfTheme.dp(70)
                implicitHeight: VfTheme.dp(28)
                onClicked: root.requestCardAction(actionId, "")
            }

            // Extend chain actions sit inline on the header row (no extra row). They
            // only appear for extend cards via their show_* flags, and "Extend" now
            // shows on the LAST card only, so the row stays short.
            VfButton {
                actionId: "prompt_card.extend"
                visible: root.showExtendButton
                text: (void i18n.revision, i18n.t("prompt_card.extend", "Extend"))
                minWidth: VfTheme.dp(80)
                implicitHeight: VfTheme.dp(28)
                onClicked: root.requestCardAction(actionId, "")
            }

            VfButton {
                actionId: "prompt_card.generate_extend"
                visible: root.showGenerateExtendButton
                text: (void i18n.revision, i18n.t("prompt_card.continue_extend", "Continue"))
                tone: "success"
                minWidth: VfTheme.dp(92)
                implicitHeight: VfTheme.dp(28)
                onClicked: root.requestCardAction(actionId, "")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.promptEditorHeight
            spacing: VfTheme.dp(8)

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(4)
                color: VfTheme.surface
                border.width: 1
                border.color: VfTheme.borderStrong
                clip: true

                TextArea {
                    id: promptArea
                    anchors.fill: parent
                    // Extend prompts are a JSON scene — read-only inline; click opens the dialog.
                    readOnly: root._isExtendRoute
                    // padding: 0 — TextArea's default internal padding (~6-9px) stacked on top
                    // of the inset pushed text down so the last line's bottom got clipped.
                    padding: VfTheme.dp(6)
                    text: root.promptText()
                    placeholderText: (void i18n.revision, i18n.t("prompt_card.prompt_placeholder", "Enter prompt"))
                    wrapMode: TextEdit.Wrap
                    color: VfTheme.text
                    placeholderTextColor: VfTheme.textSubtle
                    selectedTextColor: "#FFFFFF"
                    selectionColor: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    background: Item {}
                    onTextChanged: {
                        if (root.card)
                            root.card.prompt = text
                    }
                    // The model card is a COPY: onTextChanged only updates the JS copy.
                    // On focus-out, commit the text to the backend card (extend route) so
                    // the Extend guard / session-save see the prompt the user typed.
                    onActiveFocusChanged: {
                        if (!activeFocus && root.card && String(root.route).indexOf("extend") >= 0)
                            root.actionRequested("prompt_card.commit_prompt", root.actionPayload("prompt_card.commit_prompt", ""))
                    }
                }

                // Extend: click the prompt box → open the full edit dialog (reuses the existing
                // prompt_card.edit action → promptEditDialog). On top of the read-only TextArea.
                MouseArea {
                    anchors.fill: parent
                    enabled: root._isExtendRoute
                    visible: root._isExtendRoute
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.requestCardAction("prompt_card.edit", "")
                }
            }

            RowLayout {
                visible: root._slotDefs.length > 0
                Layout.preferredWidth: (root._slotDefs.length * (root.mode === "multi_asset" ? 96 : 106))
                    + ((root.mode === "multi_asset" && root._multiAssetVoiceLimit > 0) ? 102 : 0)
                Layout.fillHeight: true
                spacing: VfTheme.dp(6)

                Repeater {
                    model: root._slotDefs

                    Rectangle {
                        readonly property bool isVoiceSlot: Boolean(modelData && modelData.isVoiceSlot)
                        readonly property bool hasValue: root.slotHasValue(modelData)
                        property var imageSources: root.slotImageSources(modelData)
                        property int imageSourceIndex: 0
                        readonly property string imageSource: imageSources.length > imageSourceIndex ? String(imageSources[imageSourceIndex] || "") : ""
                        onImageSourcesChanged: imageSourceIndex = 0

                        Layout.preferredWidth: root.mode === "multi_asset" ? 90 : 100
                        Layout.fillHeight: true
                        radius: VfTheme.dp(8)
                        color: isVoiceSlot ? VfTheme.blueFill : VfTheme.surfaceSoft
                        border.width: 2
                        border.color: {
                            if (isVoiceSlot)
                                return hasValue ? "#2563EB" : "#93C5FD"
                            return hasValue ? "#8B5CF6" : VfTheme.borderStrong
                        }
                        border.pixelAligned: true

                        Image {
                            id: slotImage
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(4)
                            source: parent.imageSourceIndex <= 0 ? root.slotImageSource(modelData) : parent.imageSource
                            fillMode: Image.PreserveAspectCrop
                            visible: String(source).length > 0
                            asynchronous: true
                            cache: false
                            sourceSize.width: 320
                            sourceSize.height: 240
                            onStatusChanged: {
                                if (status === Image.Error && parent.imageSourceIndex + 1 < parent.imageSources.length)
                                    parent.imageSourceIndex += 1
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            anchors.margins: VfTheme.dp(6)
                            text: root.slotLabelText(modelData)
                            color: parent.hasValue ? VfTheme.text : (parent.isVoiceSlot ? "#2563EB" : VfTheme.textMuted)
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            visible: parent.isVoiceSlot || parent.imageSource.length === 0 || slotImage.status === Image.Error
                        }

                        MouseArea {
                            property string actionId: "prompt_card.media"
                            anchors.fill: parent
                            enabled: !parent.isVoiceSlot
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: root.requestCardAction(actionId, modelData.type)
                        }
                    }
                }

                VfButton {
                    id: multi_asset_voice_reveal_btn
                    visible: root.mode === "multi_asset" && root._multiAssetVoiceLimit > 0
                    text: root._multiAssetVoiceSlotsExpanded
                        ? (void i18n.revision, i18n.t("prompt_card.hide_voice_refs", "Hide Voice"))
                        : (void i18n.revision, i18n.t("prompt_card.show_voice_refs", "Show Voice"))
                    tone: root._multiAssetVoiceSlotsExpanded ? "accent" : "neutral"
                    minWidth: VfTheme.dp(96)
                    implicitHeight: VfTheme.dp(28)
                    onClicked: root.show_multi_asset_voice_slots(!root._multiAssetVoiceSlotsExpanded)
                }
            }
        }
    }
}
