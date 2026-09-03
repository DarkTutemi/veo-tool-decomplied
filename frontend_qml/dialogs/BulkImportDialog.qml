import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../components/AppIconRegistry.js" as AppIconRegistry
import "../components/MediaSourceResolver.js" as MediaSourceResolver
import "../theme"

Dialog {
    id: root

    objectName: "bulkImportDialog"

    property bool scriptMode: false
    property bool spreadsheetImportEnabled: false
    property bool preferItemAccept: false
    property bool namedRefMode: false
    property var namedRefImagePaths: []
    property var namedRefImageMediaIds: ({})
    property var namedRefImageMediaNames: ({})
    property var namedRefImagePreviewSources: ({})
    property string namedRefCardMode: ""
    property string imageCardMode: ""
    property var imagePaths: []
    property var imageMediaIds: ({})
    property var imageMediaNames: ({})
    property var imagePreviewSources: ({})
    readonly property string imageModeNN: "n_images_n_prompts"
    readonly property string imageModeN1: "n_images_1_prompt"
    readonly property string imageMode1N: "1_image_n_prompts"
    property string imageImportSubmode: imageModeNN
    property var imageResultData: []
    property int imageSelectedIndex: -1
    property bool imageThumbnailsVisible: true
    readonly property bool imageModeActive: imageCardMode.length > 0 && !namedRefMode
    property int imageAssetsPerCard: maxMultiAssetReferenceImages
    property string imageImportStatusText: ""
    property int maxMultiAssetReferenceImages: 7
    property int namedRefAssetsPerCard: maxMultiAssetReferenceImages
    property bool manualMode: false
    property string parseMode: "auto"
    property string rawText: ""
    property var previewItems: []
    property var includedIndexes: []
    property int nextPromptId: 1
    property var markHistory: []
    property string markerInfoText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property bool thumbnailsVisible: true
    property int contextMenuIndex: -1
    property string contextMenuImagePath: ""
    property string modeLabel: imageModeActive || namedRefMode
        ? (void i18n.revision, i18n.t("bulk_import.card_label", "Card"))
        : scriptMode
            ? (void i18n.revision, i18n.t("master.script_mode", "Script"))
            : (void i18n.revision, i18n.t("master.idea_mode", "Idea"))

    signal acceptedText(string text)
    signal acceptedItems(var items)
    signal acceptedImageImport(var payload)
    signal imageFilesRequested()
    signal imageFolderRequested()
    signal mediaLibraryRequested()
    signal normalImageFilesRequested(string importMode, string cardMode, int assetsPerCard)
    signal loadTextRequested()
    signal loadSpreadsheetRequested()
    // Screen reads the chosen column + 1-based inclusive row range →
    // applyLoadItemsResult. Each non-empty row of that column becomes one prompt.
    signal spreadsheetColumnChosen(string path, int columnIndex, int startRow, int endRow)
    signal editPromptRequested(int index, string text)

    parent: Overlay.overlay
    modal: true
    // Chỉ đóng bằng Escape / nút X / Hủy — KHÔNG đóng khi click ra ngoài, tránh
    // lỡ tay mất hết prompt + ảnh đã nhập (CloseOnPressOutside đã bỏ).
    closePolicy: Popup.CloseOnEscape
    width: VfDialogMetrics.width(parent, VfTheme.dp(1300), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(860), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    header: VfDialogHeader {
        title: root.imageModeActive || root.namedRefMode
            ? root.imageDialogTitle()
            : root.scriptMode
                ? (void i18n.revision, i18n.t("bulk_import.title_script_mode", "Smart Bulk Import - Script"))
                : (void i18n.revision, i18n.t("bulk_import.title_text_mode", "Smart Bulk Import - 2 Modes"))
        iconName: root.imageModeActive || root.namedRefMode ? root.imageModeIconName() : "inbox-tray"
        onCloseClicked: root.reject()
    }

    onRawTextChanged: resetIncluded()
    onParseModeChanged: resetIncluded()
    onNamedRefModeChanged: resetIncluded()
    onClosed: {
        root.namedRefMode = false
        root.namedRefImagePaths = []
        root.namedRefImageMediaIds = ({})
        root.namedRefImageMediaNames = ({})
        root.namedRefImagePreviewSources = ({})
        root.namedRefCardMode = ""
        root.namedRefAssetsPerCard = root.maxMultiAssetReferenceImages
        root.imageCardMode = ""
        root.imagePaths = []
        root.imageMediaIds = ({})
        root.imageMediaNames = ({})
        root.imagePreviewSources = ({})
        root.imageImportSubmode = root.imageModeNN
        root.imageResultData = []
        root.imageSelectedIndex = -1
        root.imageThumbnailsVisible = true
        root.imageAssetsPerCard = root.maxMultiAssetReferenceImages
        root.imageImportStatusText = ""
        root.thumbnailsVisible = true
        root.contextMenuIndex = -1
        root.contextMenuImagePath = ""
    }
    onMaxMultiAssetReferenceImagesChanged: {
        root.imageAssetsPerCard = Math.max(1, Math.min(root.maxMultiAssetReferenceImages, Number(root.imageAssetsPerCard || root.maxMultiAssetReferenceImages)))
        root.namedRefAssetsPerCard = Math.max(1, Math.min(root.maxMultiAssetReferenceImages, Number(root.namedRefAssetsPerCard || root.maxMultiAssetReferenceImages)))
    }
    onImagePathsChanged: root.resetIncluded()
    onNamedRefImagePathsChanged: root.resetIncluded()
    onImageImportSubmodeChanged: root.resetIncluded()
    onImageAssetsPerCardChanged: {
        root.imageImportStatusText = root.imageModeInstructions()
        root.resetIncluded()
    }
    onManualModeChanged: {
        parseMode = manualMode ? "marker" : "auto"
        resetIncluded()
        if (manualMode && !root.markerInfoText.length)
            updateMarkerInfo((void i18n.revision, i18n.t("bulk_import.marker_info_default", "Select text, mark prompts, or auto-detect similar blocks.")))
    }

    function itemCount() {
        return previewRows().length
    }

    function setInputText(text) {
        root.rawText = String(text || "")
    }

    function openForNamedRef(imagePaths, options) {
        var config = options || ({})
        root.namedRefMode = true
        root.namedRefImagePaths = (imagePaths || []).slice()
        root.namedRefImageMediaIds = config.image_media_ids || ({})
        root.namedRefImageMediaNames = config.image_media_names || ({})
        root.namedRefImagePreviewSources = config.image_preview_sources || ({})
        root.namedRefCardMode = String(config.card_mode || "")
        var namedRefLimitSource = config.assets_per_card || root.maxMultiAssetReferenceImages
        var namedRefLimit = Number(namedRefLimitSource)
        root.namedRefAssetsPerCard = Math.max(1, Math.min(root.maxMultiAssetReferenceImages, namedRefLimit))
        root.imageCardMode = ""
        root.imagePaths = []
        root.imageMediaIds = ({})
        root.imageMediaNames = ({})
        root.imagePreviewSources = ({})
        root.imageResultData = []
        root.imageSelectedIndex = -1
        root.thumbnailsVisible = true
        root.contextMenuIndex = -1
        root.contextMenuImagePath = ""
        root.manualMode = false
        root.parseMode = "auto"
        root.markHistory = []
        root.nextPromptId = 1
        root.updateMarkerInfo((void i18n.revision, i18n.t("bulk_import.helper_named_ref", "Each prompt will match images by filename mentioned in the text.")))
        root.open()
    }

    function openForImageMode(cardMode, options) {
        var config = options || ({})
        root.namedRefMode = false
        root.namedRefImagePaths = []
        root.namedRefImageMediaIds = ({})
        root.namedRefImageMediaNames = ({})
        root.namedRefImagePreviewSources = ({})
        root.namedRefCardMode = ""
        root.imageCardMode = String(cardMode || "")
        root.imagePaths = []
        root.imageMediaIds = ({})
        root.imageMediaNames = ({})
        root.imagePreviewSources = ({})
        root.imageImportSubmode = root.imageModeNN
        root.imageResultData = []
        root.imageSelectedIndex = -1
        root.imageThumbnailsVisible = true
        root.imageAssetsPerCard = Math.max(
            1,
            Math.min(root.maxMultiAssetReferenceImages, Number(config.initial_assets_per_card || 1))
        )
        root.imageImportStatusText = ""
        root.clearInput()
        root.updateMarkerInfo(root.imageModeInstructions())
        root.open()
    }

    function imageAssetsPerCardOptions() {
        var out = []
        var limit = root.imageCardMode === "multi_ref" ? 10 : Math.max(1, Number(root.maxMultiAssetReferenceImages || 1))
        for (var i = 1; i <= limit; ++i) {
            out.push({
                label: root.imageCardMode === "multi_ref"
                    ? (void i18n.revision, i18n.t("bulk_import.refs_per_card", "{i} ref/card")).replace("{i}", String(i))
                    : (void i18n.revision, i18n.t("bulk_import.images_per_card_" + String(i), "{count} image(s)/card")).replace("{count}", String(i)),
                value: i
            })
        }
        return out
    }

    function imageModeAccent() {
        if (root.namedRefMode || root.imageCardMode === "named_ref")
            return "#10B981"
        if (root.imageCardMode === "interpolation")
            return "#2563EB"
        if (root.imageCardMode === "multi_asset")
            return "#7C3AED"
        if (root.imageCardMode === "multi_ref")
            return "#0891B2"
        return "#D97706"
    }

    function imageModeIconName() {
        if (root.namedRefMode || root.imageCardMode === "named_ref")
            return "link"
        if (root.imageCardMode === "interpolation")
            return "shuffle"
        if (root.imageCardMode === "multi_asset")
            return "puzzle-piece"
        if (root.imageCardMode === "multi_ref")
            return "link"
        return "framed-picture"
    }

    function imageSubmodeOptions() {
        if (root.imageCardMode === "interpolation") {
            return [
                { value: root.imageModeNN, label: (void i18n.revision, i18n.t("bulk_import.submode_n_pairs_n_prompts", "N pairs + N prompts")), iconName: "shuffle", accent: "#2563EB" },
                { value: root.imageModeN1, label: (void i18n.revision, i18n.t("bulk_import.submode_n_pairs_1_prompt", "N pairs + 1 prompt")), iconName: "link", accent: "#0891B2" },
                { value: root.imageMode1N, label: (void i18n.revision, i18n.t("bulk_import.submode_1_pair_n_prompts", "1 pair + N prompts")), iconName: "framed-picture", accent: "#D97706" }
            ]
        }
        if (root.imageCardMode === "multi_asset") {
            return [
                { value: root.imageModeNN, label: (void i18n.revision, i18n.t("bulk_import.submode_n_sets_n_prompts", "N image sets + N prompts")), iconName: "puzzle-piece", accent: "#7C3AED" },
                { value: root.imageModeN1, label: (void i18n.revision, i18n.t("bulk_import.submode_n_sets_1_prompt", "N image sets + 1 prompt")), iconName: "link", accent: "#0891B2" },
                { value: root.imageMode1N, label: (void i18n.revision, i18n.t("bulk_import.submode_1_set_n_prompts", "1 image set + N prompts")), iconName: "framed-picture", accent: "#D97706" }
            ]
        }
        if (root.imageCardMode === "multi_ref") {
            return [
                { value: root.imageModeNN, label: (void i18n.revision, i18n.t("bulk_import.submode_n_refs_n_prompts", "N ref sets + N prompts")), iconName: "link", accent: "#0891B2" },
                { value: root.imageModeN1, label: (void i18n.revision, i18n.t("bulk_import.submode_n_refs_1_prompt", "N ref sets + 1 prompt")), iconName: "check-box-with-check", accent: "#10B981" },
                { value: root.imageMode1N, label: (void i18n.revision, i18n.t("bulk_import.submode_1_ref_n_prompts", "1 ref set + N prompts")), iconName: "framed-picture", accent: "#D97706" }
            ]
        }
        return [
            { value: root.imageModeNN, label: (void i18n.revision, i18n.t("bulk_import.submode_n_images_n_prompts", "N images + N prompts")), iconName: "framed-picture", accent: "#D97706" },
            { value: root.imageModeN1, label: (void i18n.revision, i18n.t("bulk_import.submode_n_images_1_prompt", "N images + 1 prompt")), iconName: "link", accent: "#0891B2" },
            { value: root.imageMode1N, label: (void i18n.revision, i18n.t("bulk_import.submode_1_image_n_prompts", "1 image + N prompts")), iconName: "check-box-with-check", accent: "#10B981" }
        ]
    }

    function setImageSubmode(value) {
        root.imageImportSubmode = String(value || root.imageModeNN)
        root.imageImportStatusText = root.imageModeInstructions()
        root.resetIncluded()
    }

    function imageDialogTitle() {
        if (root.namedRefMode || root.imageCardMode === "named_ref")
            return (void i18n.revision, i18n.t("bulk_import.title_named_ref", "Smart Import - Named Reference (auto-match images by name in prompt)"))
        if (root.imageCardMode === "interpolation")
            return (void i18n.revision, i18n.t("bulk_import.title_interpolation", "Smart Import - Interpolation (2 images = 1 card)"))
        if (root.imageCardMode === "multi_asset")
            return (void i18n.revision, i18n.t("bulk_import.title_multi_asset", "Smart Import - Multi-Asset"))
        if (root.imageCardMode === "multi_ref")
            return (void i18n.revision, i18n.t("bulk_import.title_multi_ref", "Smart Import - Reference Images (1 image = 1 reference)"))
        return (void i18n.revision, i18n.t("bulk_import.title_image_single", "Smart Import - Image to Video (1 image = 1 card)"))
    }

    function inputAreaLabelText() {
        if (root.imageModeActive || root.namedRefMode)
            return (void i18n.revision, i18n.t("bulk_import.prompt_label", "Prompt (one per line):"))
        return (void i18n.revision, i18n.t("bulk_import.input_area_label", "Input Area (Preview):"))
    }

    function inputPlaceholderText() {
        if (root.imageModeActive || root.namedRefMode)
            return (void i18n.revision, i18n.t("bulk_import.prompt_placeholder_image", "Enter prompts here, one prompt per line."))
        return (void i18n.revision, i18n.t("bulk_import.auto_text_placeholder", "Paste prompts here (one per line):"))
    }

    function previewLabelText() {
        return (void i18n.revision, i18n.t("bulk_import.preview_label", "Preview & Edit:"))
    }

    function imageModeTitle() {
        return (void i18n.revision, i18n.t("bulk_import.image_prompt_mode", "Image + Prompt Matching Mode"))
    }

    function imageModeInstructions() {
        if (!root.imageCardMode.length)
            return ""
        if (root.imageCardMode === "multi_asset")
            return (void i18n.revision, i18n.t("bulk_import.multi_asset_images_per_card_note", "Current multi-asset limit: {count} image(s) per card."))
                .replace("{count}", String(root.imageAssetsPerCard))
        if (root.imageCardMode === "multi_ref")
            return (void i18n.revision, i18n.t("bulk_import.multi_ref_note", "Reference import keeps up to 10 image references in result payload."))
        if (root.imageCardMode === "interpolation")
            return (void i18n.revision, i18n.t("bulk_import.interpolation_prompt_note", "Pick image pairs, then import prompts in this dialog."))
        return (void i18n.revision, i18n.t("bulk_import.image_prompt_note", "Pick images, then import prompts in this dialog."))
    }

    function requestNormalImageFiles(importMode) {
        var mode = String(importMode || root.imageModeNN)
        if (mode === "standard")
            mode = root.imageModeNN
        else if (mode === "shared_prompt")
            mode = root.imageModeN1
        else if (mode === "single_image" || mode === "single_pair" || mode === "single_set")
            mode = root.imageMode1N
        else if (mode === "named_ref") {
            var currentPaths = (root.imagePaths || []).slice()
            if (currentPaths.length > 0)
                root.openForNamedRef(currentPaths, {
                    card_mode: root.imageCardMode,
                    assets_per_card: root.imageAssetsPerCard,
                    image_media_ids: root.imageMediaIds || ({}),
                    image_media_names: root.imageMediaNames || ({})
                })
            return
        }
        root.setImageSubmode(mode)
        root.imageImportStatusText = root.imageModeInstructions()
        root.imageFilesRequested()
    }

    function addImagePaths(paths, mediaIds, mediaNames, previewSources) {
        var incoming = paths || []
        var ids = mediaIds || ({})
        var names = mediaNames || ({})
        var previews = previewSources || ({})
        var current = (root.imagePaths || []).slice()
        var currentIds = root.imageMediaIds || ({})
        var currentNames = root.imageMediaNames || ({})
        var currentPreviews = root.imagePreviewSources || ({})
        var nextIds = ({})
        var nextNames = ({})
        var nextPreviews = ({})
        var seen = ({})
        for (var existingKey in currentIds)
            nextIds[existingKey] = currentIds[existingKey]
        for (var existingNameKey in currentNames)
            nextNames[existingNameKey] = currentNames[existingNameKey]
        for (var existingPreviewKey in currentPreviews)
            nextPreviews[existingPreviewKey] = currentPreviews[existingPreviewKey]
        for (var i = 0; i < current.length; ++i)
            seen[String(current[i] || "").toLowerCase()] = true
        for (var j = 0; j < incoming.length; ++j) {
            var path = String(incoming[j] || "")
            if (!path.length)
                continue
            var key = path.toLowerCase()
            if (seen[key])
                continue
            seen[key] = true
            current.push(path)
            if (ids[path])
                nextIds[path] = String(ids[path] || "")
            if (names[path])
                nextNames[path] = String(names[path] || "")
            if (previews[path])
                nextPreviews[path] = String(previews[path] || "")
        }
        root.imagePaths = current
        root.imageMediaIds = nextIds
        root.imageMediaNames = nextNames
        root.imagePreviewSources = nextPreviews
        if (root.imageSelectedIndex < 0 && current.length > 0)
            root.imageSelectedIndex = 0
        root.imageImportStatusText = root.imageModeInstructions()
        root.updateImagePreview()
    }

    function addNamedRefImagePaths(paths, mediaIds, mediaNames, previewSources) {
        var incoming = paths || []
        var ids = mediaIds || ({})
        var names = mediaNames || ({})
        var previews = previewSources || ({})
        var current = (root.namedRefImagePaths || []).slice()
        var currentIds = root.namedRefImageMediaIds || ({})
        var currentNames = root.namedRefImageMediaNames || ({})
        var currentPreviews = root.namedRefImagePreviewSources || ({})
        var nextIds = ({})
        var nextNames = ({})
        var nextPreviews = ({})
        var seen = ({})
        for (var existingKey in currentIds)
            nextIds[existingKey] = currentIds[existingKey]
        for (var existingNameKey in currentNames)
            nextNames[existingNameKey] = currentNames[existingNameKey]
        for (var existingPreviewKey in currentPreviews)
            nextPreviews[existingPreviewKey] = currentPreviews[existingPreviewKey]
        for (var i = 0; i < current.length; ++i)
            seen[String(current[i] || "").toLowerCase()] = true
        for (var j = 0; j < incoming.length; ++j) {
            var path = String(incoming[j] || "")
            if (!path.length)
                continue
            var key = path.toLowerCase()
            if (seen[key])
                continue
            seen[key] = true
            current.push(path)
            if (ids[path])
                nextIds[path] = String(ids[path] || "")
            if (names[path])
                nextNames[path] = String(names[path] || "")
            if (previews[path])
                nextPreviews[path] = String(previews[path] || "")
        }
        root.namedRefImagePaths = current
        root.namedRefImageMediaIds = nextIds
        root.namedRefImageMediaNames = nextNames
        root.namedRefImagePreviewSources = nextPreviews
        if (root.imageSelectedIndex < 0 && current.length > 0)
            root.imageSelectedIndex = 0
        root.resetIncluded()
    }

    function addImportImagePaths(paths, mediaIds, mediaNames, previewSources) {
        if (root.namedRefMode) {
            root.addNamedRefImagePaths(paths, mediaIds, mediaNames, previewSources)
            return
        }
        root.addImagePaths(paths, mediaIds, mediaNames, previewSources)
    }

    function mediaSelectionSourcePath(item) {
        var data = item || ({})
        var original = Boolean(data.source_missing) ? "" : String(data.original_source_path || "")
        return String(
            data.croppedImagePath
            || data.cropped_image_path
            || data.source_path
            || data.file_path
            || data.path
            || data.blob_path
            || data.preview_path
            || original
            || data.mediaId
            || data.media_id
            || data.id
            || ""
        )
    }

    function dataImageUrl(raw, item) {
        return MediaSourceResolver.dataImageUrl(raw, item || ({}))
    }

    function mediaSelectionPreviewSource(item) {
        return MediaSourceResolver.imageSource(item || ({}))
    }

    function addImageMediaSelections(selection) {
        var payload = selection || ({})
        var items = payload.items || []
        if (!items.length && (payload.item || payload.media))
            items = [payload.item || payload.media]
        if (!items.length && typeof payload === "object")
            items = [payload]
        var paths = []
        var ids = ({})
        var names = ({})
        var previews = ({})
        for (var i = 0; i < items.length; ++i) {
            var item = items[i] || ({})
            var path = root.mediaSelectionSourcePath(item)
            if (!path.length)
                continue
            paths.push(path)
            ids[path] = String(item.mediaId || item.media_id || "")
            names[path] = String(item.name || item.title || root.fileName(path))
            previews[path] = root.mediaSelectionPreviewSource(item)
        }
        if (!paths.length && (payload.croppedImagePath || payload.cropped_image_path)) {
            var cropped = String(payload.croppedImagePath || payload.cropped_image_path || "")
            paths.push(cropped)
            ids[cropped] = String(payload.mediaId || payload.media_id || "")
            names[cropped] = String(payload.name || payload.title || root.fileName(cropped))
            previews[cropped] = root.mediaSelectionPreviewSource(payload)
        }
        root.addImagePaths(paths, ids, names, previews)
    }

    function addNamedRefMediaSelections(selection) {
        var payload = selection || ({})
        var items = payload.items || []
        if (!items.length && (payload.item || payload.media))
            items = [payload.item || payload.media]
        if (!items.length && typeof payload === "object")
            items = [payload]
        var paths = []
        var ids = ({})
        var names = ({})
        var previews = ({})
        for (var i = 0; i < items.length; ++i) {
            var item = items[i] || ({})
            var path = root.mediaSelectionSourcePath(item)
            if (!path.length)
                continue
            paths.push(path)
            ids[path] = String(item.mediaId || item.media_id || "")
            names[path] = String(item.name || item.title || root.fileName(path))
            previews[path] = root.mediaSelectionPreviewSource(item)
        }
        if (!paths.length && (payload.croppedImagePath || payload.cropped_image_path)) {
            var cropped = String(payload.croppedImagePath || payload.cropped_image_path || "")
            paths.push(cropped)
            ids[cropped] = String(payload.mediaId || payload.media_id || "")
            names[cropped] = String(payload.name || payload.title || root.fileName(cropped))
            previews[cropped] = root.mediaSelectionPreviewSource(payload)
        }
        root.addNamedRefImagePaths(paths, ids, names, previews)
    }

    function removeSelectedImage() {
        var index = Number(root.imageSelectedIndex)
        var current = (root.imagePaths || []).slice()
        if (index < 0 || index >= current.length)
            return false
        var removed = current.splice(index, 1)[0]
        var ids = root.imageMediaIds || ({})
        var names = root.imageMediaNames || ({})
        var previews = root.imagePreviewSources || ({})
        delete ids[removed]
        delete names[removed]
        delete previews[removed]
        root.imagePaths = current
        root.imageMediaIds = ids
        root.imageMediaNames = names
        root.imagePreviewSources = previews
        root.imageSelectedIndex = current.length ? Math.min(index, current.length - 1) : -1
        root.updateImagePreview()
        return true
    }

    function clearImagePaths() {
        root.imagePaths = []
        root.imageMediaIds = ({})
        root.imageMediaNames = ({})
        root.imagePreviewSources = ({})
        root.imageResultData = []
        root.imageSelectedIndex = -1
        root.resetIncluded()
    }

    function moveSelectedImage(delta) {
        var from = Number(root.imageSelectedIndex)
        var target = from + Number(delta || 0)
        var current = (root.imagePaths || []).slice()
        if (from < 0 || target < 0 || from >= current.length || target >= current.length || from === target)
            return false
        var moved = current.splice(from, 1)[0]
        current.splice(target, 0, moved)
        root.imagePaths = current
        root.imageSelectedIndex = target
        root.updateImagePreview()
        return true
    }

    function removeSelectedImportImage() {
        if (!root.namedRefMode)
            return root.removeSelectedImage()
        return root._remove_named_ref_image(root.imageSelectedIndex)
    }

    function clearImportImagePaths() {
        if (!root.namedRefMode) {
            root.clearImagePaths()
            return
        }
        root.namedRefImagePaths = []
        root.namedRefImageMediaIds = ({})
        root.namedRefImageMediaNames = ({})
        root.namedRefImagePreviewSources = ({})
        root.imageSelectedIndex = -1
        root.resetIncluded()
    }

    function moveSelectedImportImage(delta) {
        if (!root.namedRefMode)
            return root.moveSelectedImage(delta)
        return root._move_named_ref_image(root.imageSelectedIndex, delta)
    }

    function activeImportImagePaths() {
        return root.namedRefMode ? (root.namedRefImagePaths || []) : (root.imagePaths || [])
    }

    function activeImportImageNames() {
        return root.namedRefMode ? (root.namedRefImageMediaNames || ({})) : (root.imageMediaNames || ({}))
    }

    function imageUnitSize() {
        if (root.imageCardMode === "interpolation")
            return 2
        if (root.imageCardMode === "multi_asset")
            return Math.max(1, Math.min(root.maxMultiAssetReferenceImages, Number(root.imageAssetsPerCard || 1)))
        if (root.imageCardMode === "multi_ref")
            return Math.max(1, Math.min(10, Number(root.imageAssetsPerCard || 1)))
        return 1
    }

    function imageUnitCount() {
        var count = (root.imagePaths || []).length
        var unitSize = root.imageUnitSize()
        if (unitSize <= 1)
            return count
        if (root.imageCardMode === "multi_ref")
            return Math.ceil(count / unitSize)
        return Math.floor(count / unitSize)
    }

    function imageUnitPaths(index) {
        var paths = root.imagePaths || []
        var unit = Math.max(1, root.imageUnitSize())
        var start = Number(index || 0) * unit
        if (start >= paths.length)
            start = 0
        var out = []
        for (var i = 0; i < unit && start + i < paths.length; ++i)
            out.push(paths[start + i])
        if (root.imageCardMode === "multi_ref")
            return out
        return out.length === unit || root.imageCardMode === "image" ? out : []
    }

    function promptDurationSeconds(prompt) {
        var match = String(prompt || "").match(/^\s*\[\s*(?:(?:duration|time)\s*[:=]\s*)?(4|6|8|10)\s*s\s*\]\s*/i)
        return match ? Number(match[1] || 0) : 0
    }

    function buildImageResultItem(idx, numUnits, numPrompts, overridePrompt, promptIndex) {
        var prompts = root.parseItems()
        var prompt = ""
        if (overridePrompt !== undefined && overridePrompt !== null)
            prompt = String(overridePrompt || "")
        else if (promptIndex !== undefined && promptIndex !== null && Number(promptIndex) < prompts.length)
            prompt = String(prompts[Number(promptIndex)] || "")
        else if (Number(idx) < prompts.length)
            prompt = String(prompts[Number(idx)] || "")

        var unitPaths = root.imageUnitPaths(Number(idx || 0))
        var images = ({})
        if (root.imageCardMode === "interpolation") {
            if (unitPaths.length >= 2) {
                images.start = unitPaths[0]
                images.end = unitPaths[1]
            }
        } else if (root.imageCardMode === "multi_asset") {
            for (var assetIndex = 0; assetIndex < unitPaths.length; ++assetIndex)
                images["asset" + String(assetIndex + 1)] = unitPaths[assetIndex]
        } else if (root.imageCardMode === "multi_ref") {
            for (var refIndex = 0; refIndex < unitPaths.length; ++refIndex)
                images["ref" + String(refIndex + 1)] = unitPaths[refIndex]
        } else if (unitPaths.length > 0) {
            images.single = unitPaths[0]
        }

        var keys = Object.keys(images)
        if (!keys.length)
            return null

        var item = {
            images: images,
            prompt: prompt,
            duration_seconds: root.promptDurationSeconds(prompt)
        }
        var mediaIds = ({})
        var mediaNames = ({})
        var referenceIds = []
        var referencePaths = []
        for (var i = 0; i < keys.length; ++i) {
            var slot = keys[i]
            var path = String(images[slot] || "")
            if ((root.imageMediaIds || ({}))[path]) {
                mediaIds[slot] = String(root.imageMediaIds[path] || "")
                referenceIds.push(mediaIds[slot])
            } else if (root.imageCardMode === "multi_ref") {
                referencePaths.push(path)
            }
            if ((root.imageMediaNames || ({}))[path])
                mediaNames[slot] = String(root.imageMediaNames[path] || "")
        }
        if (Object.keys(mediaIds).length)
            item.media_ids = mediaIds
        if (Object.keys(mediaNames).length)
            item.media_names = mediaNames
        if (root.imageCardMode === "multi_ref") {
            item.reference_ids = referenceIds
            item.reference_paths = referencePaths
        }
        return item
    }

    function updateImagePreview() {
        if (!root.imageModeActive) {
            root.imageResultData = []
            return []
        }
        var prompts = root.parseItems()
        var numPrompts = prompts.length
        var numUnits = root.imageUnitCount()
        var out = []
        if (root.imageImportSubmode === root.imageModeN1) {
            var masterPrompt = numPrompts > 0 ? String(prompts[0] || "") : ""
            if (root.imageCardMode === "multi_ref") {
                var refs = []
                var refIds = []
                var refPaths = []
                var limit = Math.min((root.imagePaths || []).length, Math.max(1, Math.min(10, Number(root.imageAssetsPerCard || 10))))
                var images = ({})
                for (var refIndex = 0; refIndex < limit; ++refIndex) {
                    var refPath = String(root.imagePaths[refIndex] || "")
                    refs.push(refPath)
                    images["ref" + String(refIndex + 1)] = refPath
                    if ((root.imageMediaIds || ({}))[refPath])
                        refIds.push(String(root.imageMediaIds[refPath] || ""))
                    else
                        refPaths.push(refPath)
                }
                if (refs.length)
                    out.push({ images: images, prompt: masterPrompt, duration_seconds: root.promptDurationSeconds(masterPrompt), reference_ids: refIds, reference_paths: refPaths })
            } else {
                for (var unitIndex = 0; unitIndex < numUnits; ++unitIndex) {
                    var sharedItem = root.buildImageResultItem(unitIndex, numUnits, 1, masterPrompt, null)
                    if (sharedItem)
                        out.push(sharedItem)
                }
            }
        } else if (root.imageImportSubmode === root.imageMode1N) {
            for (var promptIdx = 0; promptIdx < numPrompts; ++promptIdx) {
                var promptItem = root.buildImageResultItem(0, numUnits, numPrompts, null, promptIdx)
                if (promptItem)
                    out.push(promptItem)
            }
        } else {
            var count = numPrompts > 0 ? Math.max(numUnits, numPrompts) : numUnits
            for (var idx = 0; idx < count; ++idx) {
                var item = root.buildImageResultItem(idx, numUnits, numPrompts, null, null)
                if (item)
                    out.push(item)
            }
        }
        root.imageResultData = out
        return out
    }

    function selectedImageResultItems() {
        var items = root.updateImagePreview()
        var out = []
        for (var i = 0; i < items.length; ++i) {
            if (root.isIncluded(i))
                out.push(items[i])
        }
        return out
    }

    function imageResultDisplayLabel(path) {
        // Show the imported/library name (e.g. "Maeve [MAE-01]") instead of the
        // hashed local-cache filename. Mirrors the left image list (line ~2764).
        var key = String(path || "")
        if (!key.length)
            return ""
        var name = String(
            (root.imageMediaNames || ({}))[key]
            || (root.namedRefImageMediaNames || ({}))[key]
            || ""
        )
        return name.length ? name : root.fileName(key)
    }

    function imageResultDisplayLine(item) {
        var data = item || ({})
        var images = data.images || ({})
        var names = []
        var keys = Object.keys(images)
        for (var i = 0; i < keys.length; ++i)
            names.push(root.imageResultDisplayLabel(images[keys[i]]))
        if (root.imageCardMode === "interpolation" && images.start && images.end)
            return root.imageResultDisplayLabel(images.start) + " -> " + root.imageResultDisplayLabel(images.end)
        if (root.imageCardMode === "multi_ref")
            return names.length > 1 ? names.join(", ") : (names[0] || "")
        return names.join(", ")
    }

    function fileName(path) {
        var value = String(path || "")
        if (!value.length)
            return ""
        var normalized = value.replace(/\\/g, "/")
        var parts = normalized.split("/")
        return parts.length ? parts[parts.length - 1] : normalized
    }

    function localImageSource(path) {
        var value = String(path || "")
        if (!value.length)
            return ""
        if (/^[a-z]+:\/\//i.test(value))
            return value
        if (!value.match(/^[A-Za-z]:[\\/]/) && value.charAt(0) !== "/" && value.indexOf("\\\\") !== 0)
            return ""
        return "file:///" + value.replace(/\\/g, "/")
    }

    function imageDisplaySource(path) {
        var key = String(path || "")
        if (!key.length)
            return ""
        var source = String((root.imagePreviewSources || ({}))[key] || (root.namedRefImagePreviewSources || ({}))[key] || "")
        if (source.length)
            return source
        return root.localImageSource(key)
    }

    function _preview_named_ref_image(path) {
        var imagePath = String(path || "")
        if (!imagePath.length)
            return false
        imagePreviewDialog.imagePath = imagePath
        imagePreviewDialog.open()
        return true
    }

    function _move_named_ref_image(globalIndex, delta) {
        var current = (root.namedRefImagePaths || []).slice()
        var from = Number(globalIndex)
        var target = from + Number(delta || 0)
        if (from < 0 || target < 0 || from >= current.length || target >= current.length || from === target)
            return false
        var moved = current.splice(from, 1)[0]
        current.splice(target, 0, moved)
        root.namedRefImagePaths = current
        root.imageSelectedIndex = target
        root.contextMenuIndex = target
        root.contextMenuImagePath = String(moved || "")
        root.resetIncluded()
        return true
    }

    function _remove_named_ref_image(globalIndex) {
        var current = (root.namedRefImagePaths || []).slice()
        var index = Number(globalIndex)
        if (index < 0 || index >= current.length)
            return false
        var removed = current.splice(index, 1)[0]
        var ids = root.namedRefImageMediaIds || ({})
        var names = root.namedRefImageMediaNames || ({})
        var previews = root.namedRefImagePreviewSources || ({})
        delete ids[removed]
        delete names[removed]
        delete previews[removed]
        root.namedRefImagePaths = current
        root.namedRefImageMediaIds = ids
        root.namedRefImageMediaNames = names
        root.namedRefImagePreviewSources = previews
        root.imageSelectedIndex = current.length ? Math.min(index, current.length - 1) : -1
        root.contextMenuIndex = -1
        root.contextMenuImagePath = ""
        root.resetIncluded()
        imageContextMenu.close()
        return true
    }

    function _add_from_media_library() {
        root.mediaLibraryRequested()
        return true
    }

    function _toggle_thumbnails() {
        root.thumbnailsVisible = !root.thumbnailsVisible
        return root.thumbnailsVisible
    }

    function _show_image_context_menu(imagePath) {
        var path = String(imagePath || "")
        var globalIndex = (root.namedRefImagePaths || []).indexOf(path)
        if (globalIndex < 0)
            return false
        root.contextMenuIndex = globalIndex
        root.contextMenuImagePath = path
        imageContextMenu.popup()
        return true
    }

    function applyLoadTextResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (payload.ok) {
            // TXT import: each non-empty line is exactly one prompt. Loaded files
            // are commonly one-prompt-per-line, but the "auto" detector regroups
            // them by scene/numbered/bullet/paragraph heuristics and mis-splits.
            // Pin the parser to line mode so the container does not auto-split.
            if (!root.scriptMode) {
                root.manualMode = false
                root.parseMode = "line"
            }
            root.setInputText(String(payload.text || ""))
            if (!root.scriptMode)
                root.updateMarkerInfo(
                    (void i18n.revision, i18n.t("bulk_import.txt_line_mode", "Loaded TXT: each line is one prompt."))
                )
            return true
        }

        if (!payload.cancelled) {
            root.feedbackTitle = (void i18n.revision, i18n.t("bulk_import.load_failed", "Load failed"))
            root.feedbackMessage = String(
                payload.message
                || payload.error
                || (void i18n.revision, i18n.t("bulk_import.load_failed_generic", "Could not load text from the selected file."))
            )
            root.markerInfoText = root.feedbackMessage
            feedbackDialog.open()
        }
        return false
    }

    function requestLoadText() {
        root.loadTextRequested()
    }

    function requestLoadSpreadsheet() {
        root.loadSpreadsheetRequested()
    }

    property string _spreadsheetPath: ""
    property var _spreadsheetColumns: []
    property int _spreadsheetRowCount: 0
    property bool _spreadsheetHeaderDetected: true
    // Open the column picker after the screen has read the spreadsheet metadata
    // (columns + row_count + header_detected) via nativeShell.readSpreadsheetColumns.
    function openColumnPicker(path, result) {
        var payload = result && typeof result === "object" ? result : ({})
        var cols = (payload.columns && payload.columns.length) ? payload.columns : []
        if (!cols.length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("bulk_import.load_failed", "Load failed"))
            root.feedbackMessage = (void i18n.revision, i18n.t("bulk_import.no_columns", "No columns found in the spreadsheet."))
            feedbackDialog.open()
            return
        }
        root._spreadsheetPath = String(path || "")
        root._spreadsheetColumns = cols
        root._spreadsheetRowCount = Math.max(0, Number(payload.row_count || cols[0].count || 0))
        root._spreadsheetHeaderDetected = payload.header_detected !== false
        spreadsheetColumnDialog.selectedColumnIndex = Number(cols[0].index || 0)
        // Mặc định lấy từ dòng 1 — đỡ phải chỉnh cho file mà data bắt đầu ngay
        // dòng đầu. Nếu có tiêu đề thật thì hint bên dưới nhắc đặt 'từ dòng' = 2.
        spreadsheetColumnDialog.fromRow = 1
        spreadsheetColumnDialog.toRow = Math.max(1, root._spreadsheetRowCount)
        spreadsheetColumnDialog.open()
    }

    function applyLoadItemsResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (payload.ok) {
            var items = payload.items || []
            root.manualMode = true
            root.markHistory = []
            root.nextPromptId = 1
            root.rebuildRawText(items)
            root.nextPromptId = items.length + 1
            root.selectAllPrompts()
            root.updateMarkerInfo(
                (void i18n.revision, i18n.t("bulk_import.spreadsheet_loaded", "Loaded %1 items from spreadsheet")).arg(items.length)
            )
            return true
        }

        if (!payload.cancelled) {
            root.feedbackTitle = (void i18n.revision, i18n.t("bulk_import.load_failed", "Load failed"))
            root.feedbackMessage = String(
                payload.message
                || payload.error
                || (void i18n.revision, i18n.t("bulk_import.load_failed_generic", "Could not load text from the selected file."))
            )
            root.markerInfoText = root.feedbackMessage
            feedbackDialog.open()
        }
        return false
    }

    function clearInput() {
        root.rawText = ""
        root.manualMode = false
        root.parseMode = "auto"
        root.nextPromptId = 1
        root.markHistory = []
        root.markerInfoText = ""
        root.refreshPreviewRows(true)
    }

    function normalizeNamedRefKey(name) {
        var value = String(name || "")
        value = value.replace(/\.[^.]+$/, "")
        value = value.toLowerCase()
        value = value.replace(/[_\-]/g, " ")
        value = value.replace(/\s+/g, " ").trim()
        return value
    }

    function namedRefKeysForPath(path) {
        // Build match keys from BOTH the cache filename AND the friendly media
        // name (e.g. "Maeve [MAE-01]"). Library images carry a hashed local-cache
        // filename, so keying on the filename alone never hits the prompt text —
        // the name (which the user actually typed in the prompt) must be keyed too.
        var keys = {}
        var sources = [root.fileName(path), root.namedRefMediaNameForPath(path)]
        for (var s = 0; s < sources.length; ++s) {
            var raw = String(sources[s] || "")
            if (!raw.length)
                continue
            var noExt = raw.replace(/\.[^.]+$/, "")
            keys[raw.toLowerCase()] = true
            keys[noExt.toLowerCase()] = true
            var normalized = root.normalizeNamedRefKey(raw)
            if (normalized.length)
                keys[normalized] = true
            var stripped = normalized.replace(/^\d+\s*/, "").trim()
            if (stripped.length && stripped !== normalized)
                keys[stripped] = true
            // Bare leading token before a bracket/paren/separator so the name
            // "Maeve [MAE-01]" also matches a plain "Maeve" elsewhere in the prompt.
            var bare = noExt.split(/[\[\](){}|,:]/)[0].trim().toLowerCase()
            if (bare.length >= 2)
                keys[bare] = true
        }
        return Object.keys(keys)
    }

    function namedRefMatchesForPrompt(prompt) {
        var promptText = String(prompt || "")
        var promptLower = promptText.toLowerCase()
        var index = {}
        for (var i = 0; i < root.namedRefImagePaths.length; ++i) {
            var path = String(root.namedRefImagePaths[i] || "")
            var keys = root.namedRefKeysForPath(path)
            for (var j = 0; j < keys.length; ++j) {
                var key = String(keys[j] || "")
                if (!key.length)
                    continue
                if (!index[key])
                    index[key] = []
                if (index[key].indexOf(path) < 0)
                    index[key].push(path)
            }
        }
        var matched = []
        var seen = {}
        var sortedKeys = Object.keys(index).sort(function(a, b) { return b.length - a.length })
        for (var keyIndex = 0; keyIndex < sortedKeys.length; ++keyIndex) {
            var key = sortedKeys[keyIndex]
            var searchIndex = 0
            while (true) {
                var found = promptLower.indexOf(key, searchIndex)
                if (found < 0)
                    break
                var beforeOk = found === 0 || !/[a-z0-9]/i.test(promptLower.charAt(found - 1))
                var afterIndex = found + key.length
                var afterOk = afterIndex >= promptLower.length || !/[a-z0-9]/i.test(promptLower.charAt(afterIndex))
                if (beforeOk && afterOk) {
                    var candidates = index[key] || []
                    for (var candidateIndex = 0; candidateIndex < candidates.length; ++candidateIndex) {
                        var candidate = String(candidates[candidateIndex] || "")
                        if (!seen[candidate]) {
                            seen[candidate] = true
                            matched.push({ pos: found, path: candidate })
                        }
                    }
                    break
                }
                searchIndex = found + 1
            }
        }
        matched.sort(function(a, b) { return a.pos - b.pos })
        var paths = []
        for (var matchIndex = 0; matchIndex < matched.length && matchIndex < 10; ++matchIndex)
            paths.push(matched[matchIndex].path)
        return paths
    }

    function namedRefMediaIdForPath(path) {
        return String((root.namedRefImageMediaIds || ({}))[String(path || "")] || "")
    }

    function namedRefMediaNameForPath(path) {
        return String((root.namedRefImageMediaNames || ({}))[String(path || "")] || root.fileName(path))
    }

    function buildNamedRefResultItem(prompt) {
        var promptText = String(prompt || "")
        var matches = root.namedRefMatchesForPrompt(promptText)
        var matchedImages = []
        var referenceIds = []
        var referencePaths = []
        var images = ({})
        var mediaIds = ({})
        var mediaNames = ({})
        var namedRefMax = root.namedRefCardMode === "multi_ref" ? 10 : root.maxMultiAssetReferenceImages
        var cardLimit = (root.namedRefCardMode === "multi_asset" || root.namedRefCardMode === "multi_ref")
            ? Math.max(1, Math.min(namedRefMax, Number(root.namedRefAssetsPerCard || namedRefMax)))
            : 1

        for (var i = 0; i < matches.length; ++i) {
            var path = String(matches[i] || "")
            var mediaId = root.namedRefMediaIdForPath(path)
            var mediaName = root.namedRefMediaNameForPath(path)
            matchedImages.push({ path: path, media_id: mediaId, name: mediaName })
            if (mediaId.length)
                referenceIds.push(mediaId)
            else if (path.length)
                referencePaths.push(path)
        }

        for (var slotIndex = 0; slotIndex < matchedImages.length && slotIndex < cardLimit; ++slotIndex) {
            var matched = matchedImages[slotIndex] || ({})
            var slot = root.namedRefCardMode === "multi_asset"
                ? "asset" + String(slotIndex + 1)
                : (root.namedRefCardMode === "multi_ref" ? "ref" + String(slotIndex + 1) : "single")
            images[slot] = String(matched.path || "")
            if (String(matched.media_id || "").length)
                mediaIds[slot] = String(matched.media_id || "")
            if (String(matched.name || "").length)
                mediaNames[slot] = String(matched.name || "")
        }

        return {
            named_ref: true,
            prompt: promptText,
            duration_seconds: root.promptDurationSeconds(promptText),
            matched_images: matchedImages,
            matched_count: matchedImages.length,
            reference_ids: referenceIds,
            reference_paths: referencePaths,
            images: images,
            media_ids: mediaIds,
            media_names: mediaNames
        }
    }

    function namedRefPreviewItems() {
        var prompts = root.parseItems()
        var out = []
        for (var i = 0; i < prompts.length; ++i) {
            var prompt = String(prompts[i] || "")
            var matches = root.namedRefMatchesForPrompt(prompt)
            var labels = []
            var displayLimit = (root.namedRefCardMode === "multi_asset" || root.namedRefCardMode === "multi_ref")
                ? root.namedRefAssetsPerCard
                : 1
            for (var j = 0; j < matches.length && j < displayLimit; ++j)
                labels.push(root.namedRefMediaNameForPath(matches[j]))
            var details = labels.join(", ")
            if (matches.length > displayLimit)
                details += " +" + String(matches.length - displayLimit)
            out.push({
                prompt: prompt,
                matchedImages: matches,
                matchedCount: matches.length,
                displayLine: matches.length > 0
                    ? "-> " + details
                    : (void i18n.revision, i18n.t("bulk_import.named_ref_no_match", "No matching image found"))
            })
        }
        return out
    }

    function selectedNamedRefResultItems() {
        var prompts = root.parseItems()
        var out = []
        for (var i = 0; i < prompts.length; ++i) {
            if (root.isIncluded(i))
                out.push(root.buildNamedRefResultItem(prompts[i]))
        }
        return out
    }

    function computePreviewRows() {
        if (root.namedRefMode)
            return root.namedRefPreviewItems()
        if (root.imageModeActive)
            return root.updateImagePreview()
        return root.parseItems()
    }

    function refreshPreviewRows(resetSelection) {
        var rows = root.computePreviewRows()
        root.previewItems = rows
        if (resetSelection) {
            var next = []
            for (var i = 0; i < rows.length; i++)
                next.push(true)
            root.includedIndexes = next
        }
        if (previewList && previewList.currentIndex >= rows.length)
            previewList.currentIndex = rows.length > 0 ? rows.length - 1 : -1
        return rows
    }

    function previewRows() {
        return root.previewItems || []
    }

    function namedRefStatsText() {
        var rows = root.previewRows()
        if (!rows.length)
            return (void i18n.revision, i18n.t("common.ready", "Ready"))
        var matched = 0
        var noMatch = 0
        for (var i = 0; i < rows.length; ++i) {
            if (Number(rows[i].matchedCount || 0) > 0)
                matched += 1
            else
                noMatch += 1
        }
        return (void i18n.revision, i18n.t("bulk_import.named_ref_stats", "Matched: {matched}/{total} | No match: {no_match}"))
            .replace("{matched}", String(matched))
            .replace("{total}", String(rows.length))
            .replace("{no_match}", String(noMatch))
    }

    function imageStatsText() {
        var rows = root.previewRows()
        return (void i18n.revision, i18n.t("bulk_import.preview_stats", "Cards: {cards} | Units: {units} | Prompts: {prompts}"))
            .replace("{cards}", String(rows.length))
            .replace("{units}", String(root.imageUnitCount()))
            .replace("{unit_name}", root.imageUnitName())
            .replace("{prompts}", String(root.parseItems().length))
    }

    function imageUnitName() {
        if (root.imageCardMode === "interpolation")
            return (void i18n.revision, i18n.t("bulk_import.unit_pair", "pair"))
        if (root.imageCardMode === "multi_asset")
            return (void i18n.revision, i18n.t("bulk_import.unit_set", "set"))
        if (root.imageCardMode === "multi_ref")
            return (void i18n.revision, i18n.t("bulk_import.unit_ref", "ref"))
        return (void i18n.revision, i18n.t("bulk_import.unit_image", "image"))
    }

    function imageResultPaths(item) {
        var data = item || ({})
        var images = data.images || ({})
        var keys = Object.keys(images)
        var out = []
        for (var i = 0; i < keys.length; ++i) {
            var path = String(images[keys[i]] || "")
            if (path.length)
                out.push(path)
        }
        return out
    }

    function applyAcceptResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            root.feedbackTitle = (void i18n.revision, i18n.t("bulk_import.import_failed", "Import failed"))
            root.feedbackMessage = String(
                payload.message
                || payload.error
                || (void i18n.revision, i18n.t("bulk_import.import_failed_generic", "Could not add the selected prompts to queue."))
            )
            root.markerInfoText = root.feedbackMessage
            feedbackDialog.open()
            return false
        }
        root.clearInput()
        root.close()
        return true
    }

    function acceptSelection() {
        if (root.namedRefMode) {
            root.acceptedImageImport({
                named_ref: true,
                card_mode: root.namedRefCardMode || "image",
                image_paths: (root.namedRefImagePaths || []).slice(),
                image_media_ids: root.namedRefImageMediaIds || ({}),
                image_media_names: root.namedRefImageMediaNames || ({}),
                assets_per_card: Number(root.namedRefAssetsPerCard || root.maxMultiAssetReferenceImages),
                prompts: root.parseItems(),
                result_items: root.selectedNamedRefResultItems()
            })
            return
        }
        if (root.imageModeActive) {
            root.acceptedImageImport({
                card_mode: root.imageCardMode,
                import_submode: root.imageImportSubmode,
                image_paths: (root.imagePaths || []).slice(),
                image_media_ids: root.imageMediaIds || ({}),
                image_media_names: root.imageMediaNames || ({}),
                assets_per_card: Number(root.imageAssetsPerCard || 1),
                prompts: root.parseItems(),
                result_items: root.selectedImageResultItems()
            })
            return
        }
        if (root.preferItemAccept)
            root.acceptedItems(root.selectedItems())
        else
            root.acceptedText(root.selectedText())
    }

    function markerCount(text) {
        var matches = String(text || "").match(/\[START_PROMPT_\d+\]/g)
        return matches ? matches.length : 0
    }

    function updateMarkerInfo(message) {
        if (message && String(message).length > 0) {
            root.markerInfoText = String(message)
            return
        }
        var count = markerCount(root.rawText)
        if (count > 0) {
            root.markerInfoText = (void i18n.revision, i18n.t("bulk_import.marked_prompts", "Marked prompts: %1")).arg(count)
            return
        }
        root.markerInfoText = (void i18n.revision, i18n.t("bulk_import.marker_info_default", "Select text, mark prompts, or auto-detect similar blocks."))
    }

    function cleanItems(items) {
        var out = []
        for (var i = 0; i < items.length; i++) {
            var item = String(items[i] || "").replace(/\s+/g, " ").trim()
            if (item.length > 0)
                out.push(item)
        }
        return out
    }

    function splitBySentences(text) {
        var source = String(text || "").trim()
        if (!source.length)
            return []
        var parts = source.split(/\.(?=\s*[A-Z]|\s*\n|\s*$)/)
        var prompts = []
        for (var i = 0; i < parts.length; i++) {
            var sentence = String(parts[i] || "").trim()
            if (sentence.length <= 20)
                continue
            if (!/[.!?]$/.test(sentence))
                sentence += "."
            prompts.push(sentence)
        }
        if (prompts.length <= 1) {
            var lines = cleanItems(source.split(/\r?\n/))
            prompts = []
            for (var j = 0; j < lines.length; j++) {
                if (String(lines[j] || "").length > 20)
                    prompts.push(lines[j])
            }
        }
        return prompts.length ? prompts : [source]
    }

    function splitByLength(text, maxLength) {
        var source = String(text || "").trim()
        if (!source.length)
            return []
        var limit = Math.max(1, Number(maxLength || 800))
        var sentences = source.split(/[.!?]+\s+/)
        var prompts = []
        var current = []
        var currentLength = 0
        for (var i = 0; i < sentences.length; i++) {
            var sentence = String(sentences[i] || "").trim()
            if (!sentence.length)
                continue
            if (currentLength + sentence.length > limit && current.length) {
                prompts.push(current.join(". ") + ".")
                current = [sentence]
                currentLength = sentence.length
            } else {
                current.push(sentence)
                currentLength += sentence.length
            }
        }
        if (current.length)
            prompts.push(current.join(". ") + ".")
        return prompts
    }

    function parseItems() {
        var text = root.rawText.trim()
        if (!text.length)
            return []
        if (root.scriptMode)
            return [text]
        if (root.manualMode || root.parseMode === "marker") {
            var marker = /\[START_PROMPT_\d+\]([\s\S]*?)(?:\[END_PROMPT_\d+\]|(?=\[START_PROMPT_\d+\])|$)/gi
            var markerItems = []
            var markerMatch
            while ((markerMatch = marker.exec(text)) !== null)
                markerItems.push(markerMatch[1])
            return cleanItems(markerItems.length ? markerItems : text.split(/\r?\n/))
        }
        if (root.parseMode === "line")
            return cleanItems(text.split(/\r?\n/))
        if (root.parseMode === "paragraph")
            return cleanItems(text.split(/(?:\r?\n\s*){2,}/))
        if (root.parseMode === "scene" || root.parseMode === "auto") {
            var scene = /(?:^|\n)\s*Scene\s*(?:\(\s*\d+\s*\)|\d+)?\s*:\s*([\s\S]*?)(?=(?:^|\n)\s*Scene\s*(?:\(\s*\d+\s*\)|\d+)?\s*:|$)/gi
            var sceneItems = []
            var sceneMatch
            while ((sceneMatch = scene.exec(text)) !== null)
                sceneItems.push(sceneMatch[1])
            if (sceneItems.length >= 2 || root.parseMode === "scene")
                return cleanItems(sceneItems.length ? sceneItems : text.split(/\r?\n/))
        }
        if (root.parseMode === "numbered" || root.parseMode === "auto") {
            var numbered = /(?:^|\n)\s*\d+[\.)]\s*([\s\S]*?)(?=(?:^|\n)\s*\d+[\.)]\s*|$)/g
            var numberedItems = []
            var numberedMatch
            while ((numberedMatch = numbered.exec(text)) !== null)
                numberedItems.push(numberedMatch[1])
            if (numberedItems.length >= 2 || root.parseMode === "numbered")
                return cleanItems(numberedItems.length ? numberedItems : text.split(/\r?\n/))
        }
        if (root.parseMode === "bullet" || root.parseMode === "auto") {
            var bullet = /(?:^|\n)\s*[-*\u2022]\s*([\s\S]*?)(?=(?:^|\n)\s*[-*\u2022]\s*|$)/g
            var bulletItems = []
            var bulletMatch
            while ((bulletMatch = bullet.exec(text)) !== null)
                bulletItems.push(bulletMatch[1])
            if (bulletItems.length >= 2 || root.parseMode === "bullet")
                return cleanItems(bulletItems.length ? bulletItems : text.split(/\r?\n/))
        }
        var paragraphs = cleanItems(text.split(/(?:\r?\n\s*){2,}/))
        if (paragraphs.length >= 2)
            return paragraphs
        var sentenceItems = cleanItems(splitBySentences(text))
        if (sentenceItems.length >= 2)
            return sentenceItems
        if (text.length > 1000) {
            var lengthItems = cleanItems(splitByLength(text, 800))
            if (lengthItems.length >= 2)
                return lengthItems
        }
        return cleanItems(text.split(/\r?\n/))
    }

    function resetIncluded() {
        root.refreshPreviewRows(true)
    }

    function isIncluded(index) {
        if (index < 0)
            return false
        if (index >= root.includedIndexes.length)
            return true
        return Boolean(root.includedIndexes[index])
    }

    function setIncluded(index, checked) {
        var items = previewRows()
        var next = root.includedIndexes.slice()
        while (next.length < items.length)
            next.push(true)
        next[index] = Boolean(checked)
        root.includedIndexes = next
    }

    function selectAllPrompts() {
        var items = previewRows()
        var next = []
        for (var i = 0; i < items.length; i++)
            next.push(true)
        root.includedIndexes = next
    }

    function selectNonePrompts() {
        var items = previewRows()
        var next = []
        for (var i = 0; i < items.length; i++)
            next.push(false)
        root.includedIndexes = next
    }

    function selectedItems() {
        if (root.imageModeActive)
            return root.selectedImageResultItems()
        var items = previewRows()
        var out = []
        for (var i = 0; i < items.length; i++) {
            if (isIncluded(i))
                out.push(root.namedRefMode ? String((items[i] || {}).prompt || "") : items[i])
        }
        return out
    }

    function selectedText() {
        if (root.scriptMode)
            return root.rawText
        return selectedItems().join("\n")
    }

    function selectedCount() {
        return selectedItems().length
    }

    function rebuildRawText(items) {
        var rows = items || []
        if (root.scriptMode) {
            root.rawText = rows.length > 0 ? String(rows[0] || "") : ""
            return
        }
        if (root.manualMode || root.parseMode === "marker") {
            var blocks = []
            for (var i = 0; i < rows.length; i++) {
                blocks.push("[START_PROMPT_" + (i + 1) + "]\n" + String(rows[i] || "") + "\n[END_PROMPT_" + (i + 1) + "]")
            }
            root.rawText = blocks.join("\n\n")
            return
        }
        if (root.parseMode === "line") {
            root.rawText = rows.join("\n")
            return
        }
        root.rawText = rows.join("\n\n")
    }

    function markSelectedText() {
        if (!root.manualMode) {
            root.manualMode = true
            markerHighlighter.focusEditor()
        }
        if (!markerHighlighter.hasSelection()) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.notice", "Notice"))
            root.feedbackMessage = (void i18n.revision, i18n.t("bulk_import.select_text_first", "Select text first before marking."))
            feedbackDialog.open()
            updateMarkerInfo(root.feedbackMessage)
            return
        }
        var previous = root.rawText
        var nextText = manualMarkerParser.addMarkers(
            previous,
            markerHighlighter.selectionStart(),
            markerHighlighter.selectionEnd(),
            root.nextPromptId
        )
        if (nextText === previous)
            return
        root.markHistory = root.markHistory.concat([previous])
        root.rawText = nextText
        root.nextPromptId = markerCount(nextText) + 1
        updateMarkerInfo((void i18n.revision, i18n.t("bulk_import.marked_prompts", "Marked prompts: %1")).arg(markerCount(nextText)))
    }

    function autoMarkSimilar() {
        var cleanText = manualMarkerParser.removeAllMarkers(root.rawText).trim()
        if (!cleanText.length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.notice", "Notice"))
            root.feedbackMessage = (void i18n.revision, i18n.t("bulk_import.enter_text_first", "Enter text first."))
            feedbackDialog.open()
            updateMarkerInfo(root.feedbackMessage)
            return
        }
        var detected = autoPatternParser.parse(cleanText)
        if (!detected.length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.notice", "Notice"))
            root.feedbackMessage = (void i18n.revision, i18n.t("bulk_import.no_pattern_found", "No prompt pattern found for auto mark."))
            feedbackDialog.open()
            updateMarkerInfo(root.feedbackMessage)
            return
        }
        root.markHistory = root.markHistory.concat([root.rawText])
        root.manualMode = true
        root.rebuildRawText(detected)
        root.nextPromptId = detected.length + 1
        updateMarkerInfo((void i18n.revision, i18n.t("bulk_import.auto_detected", "Auto-detected %1 prompts")).arg(detected.length))
    }

    function clearAllMarkers() {
        var cleanText = manualMarkerParser.removeAllMarkers(root.rawText)
        if (cleanText === root.rawText) {
            updateMarkerInfo((void i18n.revision, i18n.t("bulk_import.cleared_all_markers", "No markers to clear.")))
            return
        }
        root.markHistory = root.markHistory.concat([root.rawText])
        root.rawText = cleanText
        root.nextPromptId = 1
        updateMarkerInfo((void i18n.revision, i18n.t("bulk_import.cleared_all_markers", "Cleared all markers.")))
    }

    function undoLastMark() {
        if (!root.markHistory.length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.notice", "Notice"))
            root.feedbackMessage = (void i18n.revision, i18n.t("bulk_import.no_undo_action", "Nothing to undo."))
            feedbackDialog.open()
            updateMarkerInfo(root.feedbackMessage)
            return
        }
        var previous = root.markHistory[root.markHistory.length - 1]
        root.markHistory = root.markHistory.slice(0, root.markHistory.length - 1)
        root.rawText = previous
        root.nextPromptId = markerCount(previous) + 1
        updateMarkerInfo((void i18n.revision, i18n.t("bulk_import.undone", "Undo complete. Marked prompts: %1")).arg(markerCount(previous)))
    }

    function replaceParsedItem(index, text) {
        var items = parseItems()
        if (index < 0 || index >= items.length)
            return
        items[index] = String(text || "").trim()
        rebuildRawText(cleanItems(items))
    }

    function removeParsedItem(index) {
        var items = parseItems()
        if (index < 0 || index >= items.length)
            return
        items.splice(index, 1)
        rebuildRawText(cleanItems(items))
    }

    function mergeSelectedPrompts() {
        var selected = selectedItems()
        if (selected.length < 2) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.info", "Info"))
            root.feedbackMessage = (void i18n.revision, i18n.t("bulk_import.select_at_least_2_prompts", "Select at least 2 prompts to merge!"))
            feedbackDialog.open()
            return
        }
        var items = parseItems()
        var rowsToKeep = []
        var firstRow = -1
        for (var i = 0; i < items.length; ++i) {
            if (isIncluded(i)) {
                if (firstRow < 0)
                    firstRow = i
                continue
            }
            rowsToKeep.push(items[i])
        }
        var mergedPrompt = selected.join(" ").replace(/\s+/g, " ").trim()
        if (firstRow < 0)
            firstRow = rowsToKeep.length
        rowsToKeep.splice(firstRow, 0, mergedPrompt)
        rebuildRawText(cleanItems(rowsToKeep))
        previewList.currentIndex = firstRow
    }

    function splitSelectedPrompt() {
        if (previewList.currentIndex < 0) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.info", "Info"))
            root.feedbackMessage = (void i18n.revision, i18n.t("bulk_import.select_prompt_first", "Please select a prompt first!"))
            feedbackDialog.open()
            return
        }
        var items = parseItems()
        if (previewList.currentIndex >= items.length)
            return
        var prompt = String(items[previewList.currentIndex] || "").trim()
        var markerMatch = prompt.match(/^\s*\[\s*(?:(?:duration|time)\s*[:=]\s*)?(4|6|8|10)\s*s\s*\]\s*/i)
        var durationMarker = ""
        if (markerMatch) {
            durationMarker = "[" + String(markerMatch[1] || "").trim() + "s]"
            prompt = prompt.slice(markerMatch[0].length).trim()
        }
        var sentences = prompt.split(/[.!?]+\s+/)
        var splitItems = []
        for (var i = 0; i < sentences.length; ++i) {
            var sentence = String(sentences[i] || "").trim()
            if (!sentence.length)
                continue
            if (!/[.!?]$/.test(sentence))
                sentence += "."
            if (durationMarker.length)
                sentence = durationMarker + " " + sentence
            splitItems.push(sentence)
        }
        if (splitItems.length < 2) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.info", "Info"))
            root.feedbackMessage = (void i18n.revision, i18n.t("bulk_import.cannot_split_further", "Cannot split this prompt further."))
            feedbackDialog.open()
            return
        }
        items.splice(previewList.currentIndex, 1)
        for (var sentenceIndex = 0; sentenceIndex < splitItems.length; ++sentenceIndex)
            items.splice(previewList.currentIndex + sentenceIndex, 0, splitItems[sentenceIndex])
        rebuildRawText(cleanItems(items))
    }

    function openEditor(index, text) {
        promptEditDialog.openFor(index, text)
    }

    function instructionsText() {
        if (root.imageModeActive)
            return root.imageModeInstructions()
        if (root.namedRefMode)
            return root.namedRefCardMode === "multi_asset"
                ? (void i18n.revision, i18n.t("bulk_import.instr_named_ref", "Named-ref import: prompts are matched against image filenames, and only matched images are attached per card."))
                    + " "
                    + (void i18n.revision, i18n.t("bulk_import.multi_asset_images_per_card_note", "Current multi-asset limit: {count} image(s) per card."))
                        .replace("{count}", String(root.namedRefAssetsPerCard))
                : (void i18n.revision, i18n.t("bulk_import.instr_named_ref", "Named-ref import: prompts are matched against image filenames, and only matched images are attached per card."))
        if (root.manualMode)
            return (void i18n.revision, i18n.t("bulk_import.instructions_manual", "MANUAL MODE: mark prompt boundaries, then review before import."))
        return (void i18n.revision, i18n.t("bulk_import.instructions_auto", "AUTO MODE: load TXT or paste prompts, then review before import."))
    }

    background: Rectangle {
        radius: VfTheme.dp(10)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    ManualMarkerParser {
        id: manualMarkerParser
    }

    AutoPatternParser {
        id: autoPatternParser
    }

    contentItem: Item {
        ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(16)
        spacing: VfTheme.dp(10)

        Rectangle {
            objectName: "bulkImportImagePanel"   // tour (image mode)
            visible: root.imageModeActive
            Layout.fillWidth: true
            Layout.rightMargin: 12
            Layout.topMargin: 12
            implicitHeight: visible ? imageModePanelColumn.implicitHeight + 18 : 0
            radius: VfTheme.dp(8)
            color: root.imageCardMode === "interpolation" ? VfTheme.blueFill
                : root.imageCardMode === "multi_asset" ? VfTheme.violetFill
                : root.imageCardMode === "multi_ref" ? VfTheme.cyanFill
                : VfTheme.amberFill
            border.color: root.imageModeAccent()

            ColumnLayout {
                id: imageModePanelColumn
                anchors.fill: parent
                anchors.margins: VfTheme.dp(9)
                spacing: VfTheme.dp(8)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(10)

                    Rectangle {
                        Layout.preferredWidth: VfTheme.dp(34)
                        Layout.preferredHeight: VfTheme.dp(34)
                        radius: VfTheme.dp(8)
                        color: root.imageModeAccent()

                        VfAppIcon {
                            anchors.centerIn: parent
                            name: root.imageModeIconName()
                            size: VfTheme.dp(20)
                            color: "#FFFFFF"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            text: root.imageModeTitle()
                            color: root.imageCardMode === "multi_asset" ? VfTheme.indigoText
                                : root.imageCardMode === "multi_ref" ? VfTheme.cyanText
                                : root.imageCardMode === "interpolation" ? VfTheme.blueText
                                : VfTheme.amberText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(13)
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.imageImportStatusText.length > 0 ? root.imageImportStatusText : root.imageModeInstructions()
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            elide: Text.ElideRight
                        }
                    }

                    Text {
                        text: (void i18n.revision, i18n.t("bulk_import.image_count_status", "{count} image(s)"))
                            .replace("{count}", String((root.imagePaths || []).length))
                        color: root.imageModeAccent()
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        font.weight: Font.Bold
                    }

                }

                RowLayout {
                    visible: root.imageCardMode === "multi_asset" || root.imageCardMode === "multi_ref"
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(8)

                    Text {
                        text: root.imageCardMode === "multi_ref"
                            ? (void i18n.revision, i18n.t("bulk_import.num_refs_label", "Refs:"))
                            : (void i18n.revision, i18n.t("bulk_import.num_images_label", "Images:"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        font.weight: Font.DemiBold
                    }

                    ComboBox {
                        id: imageAssetsPerCardCombo
                        Layout.preferredWidth: VfTheme.dp(190)
                        Layout.preferredHeight: VfTheme.dp(32)
                        model: root.imageAssetsPerCardOptions()
                        textRole: "label"
                        valueRole: "value"
                        currentIndex: Math.max(0, Math.min(count - 1, Number(root.imageAssetsPerCard || 1) - 1))
                        onActivated: {
                            var item = model[currentIndex] || ({})
                            var limit = root.imageCardMode === "multi_ref" ? 10 : root.maxMultiAssetReferenceImages
                            root.imageAssetsPerCard = Math.max(1, Math.min(limit, Number(item.value || 1)))
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.imageModeInstructions()
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        elide: Text.ElideRight
                    }
                }

                RowLayout {
                    objectName: "bulkImportSubmode"   // tour (image-prompt matching modes)
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(8)

                    Repeater {
                        model: root.imageSubmodeOptions()
                        delegate: ImageSubmodeButton {
                            Layout.fillWidth: true
                            option: modelData
                        }
                    }
                }
            }
        }

        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 0
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            Layout.topMargin: root.imageModeActive ? 0 : 12
            orientation: Qt.Horizontal
            clip: true

            Rectangle {
                SplitView.preferredWidth: Math.max(VfTheme.dp(360), Math.round((root.width - VfTheme.dp(24)) * (root.imageModeActive ? 0.48 : 0.52)))
                SplitView.minimumWidth: Math.min(VfTheme.dp(420), Math.max(VfTheme.dp(260), Math.round((root.width - VfTheme.dp(24)) * 0.30)))
                color: VfTheme.surface
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.rightMargin: VfTheme.dp(5)
                    spacing: VfTheme.dp(8)

                    TextImportModePanel {
                        objectName: "bulkImportModeToggle"   // tour
                        visible: !root.scriptMode && !root.namedRefMode && !root.imageModeActive
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? VfTheme.dp(62) : 0
                        Layout.minimumHeight: 0
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: instructionText.implicitHeight + 22
                        radius: VfTheme.dp(6)
                        color: VfTheme.blueFill
                        border.color: VfTheme.blueBorderSoft

                        Text {
                            id: instructionText
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(10)
                            text: root.instructionsText()
                            color: VfTheme.blueText
                            wrapMode: Text.WordWrap
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                        }
                    }

                    ImageListPanel {
                        id: imageListPanel
                        objectName: "bulkImportImageList"   // tour (image mode)
                        visible: root.imageModeActive || root.namedRefMode
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? VfTheme.dp(220) : 0
                        Layout.minimumHeight: 0
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: root.inputAreaLabelText()
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            font.weight: Font.Bold
                        }

                        VfButton {
                            objectName: "bulkImportLoadTxtButton"   // tour
                            text: (void i18n.revision, i18n.t("bulk_import.load_txt", "Load TXT"))
                            minWidth: VfTheme.dp(130)
                            implicitHeight: VfTheme.dp(42)
                            onClicked: root.requestLoadText()
                        }

                        VfButton {
                            // Excel/CSV chỉ load prompt (text) — giống Load TXT — nên dùng
                            // được ở mọi chế độ kể cả ảnh/named-ref (ảnh do hệ thống tự ref).
                            visible: root.spreadsheetImportEnabled
                            text: (void i18n.revision, i18n.t("bulk_import.load_excel_csv", "Import Excel/CSV"))
                            minWidth: VfTheme.dp(150)
                            implicitHeight: VfTheme.dp(42)
                            onClicked: root.requestLoadSpreadsheet()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 0
                        radius: VfTheme.dp(6)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.borderStrong
                        border.width: 2
                        clip: true

                        StackLayout {
                            anchors.fill: parent
                            currentIndex: root.manualMode ? 1 : 0

                            ScrollView {
                                id: autoInputScroll
                                contentWidth: availableWidth
                                contentHeight: autoInput.implicitHeight
                                clip: true
                                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                                TextArea {
                                    id: autoInput
                                    objectName: "bulkImportTextInput"   // tour
                                    width: autoInputScroll.availableWidth
                                    text: root.rawText
                                    placeholderText: root.inputPlaceholderText()
                                    wrapMode: TextEdit.Wrap
                                    selectByMouse: true
                                    color: VfTheme.text
                                    placeholderTextColor: VfTheme.textSubtle
                                    selectedTextColor: "#FFFFFF"
                                    selectionColor: VfTheme.primary
                                    font.family: "Consolas"
                                    font.pixelSize: VfTheme.dp(11)
                                    background: Item {}
                                    onTextChanged: {
                                        if (root.rawText !== text)
                                            root.setInputText(text)
                                    }
                                }
                            }

                            PromptMarkerHighlighter {
                                id: markerHighlighter
                                text: root.rawText
                                placeholderText: (void i18n.revision, i18n.t("bulk_import.manual_text_placeholder", "[START_PROMPT_1]\nPrompt text...\n[END_PROMPT_1]"))
                                onTextChangedByUser: text => {
                                    if (root.rawText !== text)
                                        root.setInputText(text)
                                }
                            }
                        }
                    }

                    AutoControls {
                        visible: !root.manualMode && !root.imageModeActive && !root.namedRefMode
                        Layout.fillWidth: true
                    }

                    ManualControls {
                        visible: root.manualMode && !root.imageModeActive && !root.namedRefMode
                        Layout.fillWidth: true
                    }
                }
            }

            Rectangle {
                SplitView.fillWidth: true
                SplitView.minimumWidth: Math.min(VfTheme.dp(360), Math.max(VfTheme.dp(240), Math.round((root.width - VfTheme.dp(24)) * 0.26)))
                color: VfTheme.surface
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(5)
                    anchors.rightMargin: VfTheme.dp(5)
                    spacing: VfTheme.dp(8)

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: root.previewLabelText()
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            font.weight: Font.Bold
                        }

                        Text {
                            Layout.maximumWidth: VfTheme.dp(280)
                            text: root.namedRefMode ? root.namedRefStatsText()
                                : root.imageModeActive ? root.imageStatsText()
                                : (void i18n.revision, i18n.t("common.ready", "Sẵn sàng"))
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Rectangle {
                        visible: !root.imageModeActive && !root.namedRefMode
                        Layout.fillWidth: true
                        implicitHeight: visible ? previewHelp.implicitHeight + 16 : 0
                        radius: VfTheme.dp(6)
                        color: VfTheme.amberFill
                        border.color: VfTheme.amberBorderSoft

                        Text {
                            id: previewHelp
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(8)
                            text: (void i18n.revision, i18n.t("bulk_import.preview_explanation", "This area is for fine-tuning results after analysis."))
                            color: VfTheme.amberText
                            wrapMode: Text.WordWrap
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 0
                        radius: VfTheme.dp(6)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.borderStrong
                        clip: true

                        ListView {
                            id: previewList
                            objectName: "bulkImportPreviewList"   // tour
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(5)
                            model: root.previewItems
                            clip: true
                            reuseItems: true

                            delegate: Rectangle {
                                id: previewCard
                                // Alias the card's model item so nested Repeater
                                // delegates (whose own modelData is an int index)
                                // can still reach this row's data.
                                property var cardItem: modelData
                                width: previewList.width
                                // Content-driven height so thumbnails/text never
                                // overflow the card (was a hardcoded 98/74/54).
                                implicitHeight: previewCardRow.implicitHeight + VfTheme.dp(12)
                                height: implicitHeight
                                radius: VfTheme.dp(4)
                                color: index === previewList.currentIndex ? VfTheme.primary : VfTheme.surface
                                border.color: index === previewList.currentIndex ? VfTheme.primaryHover : VfTheme.border
                                clip: true

                                RowLayout {
                                    id: previewCardRow
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: VfTheme.dp(8)
                                    anchors.rightMargin: VfTheme.dp(8)
                                    spacing: VfTheme.dp(8)

                                    CheckBox {
                                        Layout.preferredWidth: VfTheme.dp(28)
                                        checked: root.isIncluded(index)
                                        onToggled: root.setIncluded(index, checked)
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: VfTheme.dp(2)

                                        Text {
                                            Layout.fillWidth: true
                                            text: "#" + (index + 1) + " " + root.modeLabel
                                            color: index === previewList.currentIndex ? "#FFFFFF" : VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(11)
                                            font.weight: Font.Bold
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: root.namedRefMode
                                                ? String((modelData || {}).prompt || "")
                                                : root.imageModeActive
                                                ? String((modelData || {}).prompt || "")
                                                : String(modelData || "")
                                            color: index === previewList.currentIndex ? "#E0E7FF" : VfTheme.textSubtle
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(11)
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            visible: root.namedRefMode || root.imageModeActive
                                            Layout.fillWidth: true
                                            text: root.imageModeActive
                                                ? root.imageResultDisplayLine(modelData)
                                                : String((modelData || {}).displayLine || "")
                                            color: index === previewList.currentIndex
                                                ? VfTheme.blueFill
                                                : (root.imageModeActive ? root.imageModeAccent() : (Number((modelData || {}).matchedCount || 0) > 0 ? VfTheme.tealText : VfTheme.amberText))
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(10)
                                            elide: Text.ElideRight
                                        }

                                        RowLayout {
                                            visible: root.namedRefMode && root.thumbnailsVisible && Number((modelData || {}).matchedCount || 0) > 0
                                            Layout.fillWidth: true
                                            spacing: VfTheme.dp(6)

                                            Repeater {
                                                model: Math.min(root.namedRefAssetsPerCard, Number(((modelData || {}).matchedImages || []).length || 0))

                                                delegate: Rectangle {
                                                    property var imagePath: (((previewCard.cardItem || {}).matchedImages || [])[index] || "")

                                                    Layout.preferredWidth: VfTheme.dp(48)
                                                    Layout.preferredHeight: VfTheme.dp(48)
                                                    radius: VfTheme.dp(6)
                                                    color: VfTheme.border
                                                    border.color: VfTheme.borderStrong
                                                    clip: true

                                                    Image {
                                                        anchors.fill: parent
                                                        source: root.imageDisplaySource(parent.imagePath || "")
                                                        fillMode: Image.PreserveAspectCrop
                                                        asynchronous: true
                                                        cache: false
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                                                        onClicked: function(mouse) {
                                                            if (mouse.button === Qt.RightButton)
                                                                root._show_image_context_menu(parent.imagePath || "")
                                                            else if (mouse.button === Qt.LeftButton)
                                                                root._preview_named_ref_image(parent.imagePath || "")
                                                        }
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                visible: Number((modelData || {}).matchedCount || 0) > 3
                                                Layout.preferredWidth: VfTheme.dp(38)
                                                Layout.preferredHeight: VfTheme.dp(48)
                                                radius: VfTheme.dp(6)
                                                color: VfTheme.cyanFill
                                                border.color: VfTheme.cyanBorderSoft

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "+" + String(Number((modelData || {}).matchedCount || 0) - 3)
                                                    color: VfTheme.cyanText
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.dp(11)
                                                    font.weight: Font.Bold
                                                }
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }
                                        }

                                        RowLayout {
                                            visible: root.imageModeActive && root.imageThumbnailsVisible && root.imageResultPaths(modelData).length > 0
                                            Layout.fillWidth: true
                                            spacing: VfTheme.dp(6)

                                            Repeater {
                                                model: Math.min(6, root.imageResultPaths(modelData).length)

                                                delegate: Rectangle {
                                                    property var imagePath: root.imageResultPaths(previewCard.cardItem)[index] || ""

                                                    Layout.preferredWidth: VfTheme.dp(48)
                                                    Layout.preferredHeight: VfTheme.dp(48)
                                                    radius: VfTheme.dp(6)
                                                    color: VfTheme.border
                                                    border.color: index === 0 ? root.imageModeAccent() : VfTheme.borderStrong
                                                    clip: true

                                                    Image {
                                                        anchors.fill: parent
                                                        source: root.imageDisplaySource(parent.imagePath || "")
                                                        fillMode: Image.PreserveAspectCrop
                                                        asynchronous: true
                                                        cache: false
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        onClicked: root._preview_named_ref_image(parent.imagePath || "")
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                visible: root.imageResultPaths(modelData).length > 6
                                                Layout.preferredWidth: VfTheme.dp(38)
                                                Layout.preferredHeight: VfTheme.dp(48)
                                                radius: VfTheme.dp(6)
                                                color: VfTheme.cyanFill
                                                border.color: VfTheme.cyanBorderSoft

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "+" + String(root.imageResultPaths(modelData).length - 6)
                                                    color: VfTheme.cyanText
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.dp(11)
                                                    font.weight: Font.Bold
                                                }
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton
                                    onClicked: previewList.currentIndex = index
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: false
                            text: ""
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                        }
                    }

                    GridLayout {
                        id: previewActionGrid
                        Layout.fillWidth: true
                        columns: width >= VfTheme.dp(640) ? 6 : width >= VfTheme.dp(390) ? 3 : 2
                        columnSpacing: VfTheme.dp(6)
                        rowSpacing: VfTheme.dp(6)

                        VfButton {
                            objectName: "bulkImportSelectAllButton"   // tour
                            text: (void i18n.revision, i18n.t("bulk_import.select_all", "Select All"))
                            Layout.fillWidth: true
                            compact: previewActionGrid.columns < 6
                            minWidth: previewActionGrid.columns < 6 ? VfTheme.dp(78) : VfTheme.dp(84)
                            implicitHeight: VfTheme.dp(38)
                            tooltip: (void i18n.revision, i18n.t("bulk_import.select_all_tooltip", "Select all prompts"))
                            onClicked: root.selectAllPrompts()
                        }

                        VfButton {
                            text: (void i18n.revision, i18n.t("bulk_import.deselect", "Deselect"))
                            Layout.fillWidth: true
                            compact: previewActionGrid.columns < 6
                            minWidth: previewActionGrid.columns < 6 ? VfTheme.dp(78) : VfTheme.dp(80)
                            implicitHeight: VfTheme.dp(38)
                            tooltip: (void i18n.revision, i18n.t("bulk_import.deselect_tooltip", "Deselect all prompts"))
                            onClicked: root.selectNonePrompts()
                        }

                        VfButton {
                            objectName: "bulkImportEditButton"   // tour
                            text: (void i18n.revision, i18n.t("bulk_import.edit_btn", "Edit"))
                            Layout.fillWidth: true
                            compact: previewActionGrid.columns < 6
                            minWidth: VfTheme.dp(68)
                            implicitHeight: VfTheme.dp(38)
                            tooltip: (void i18n.revision, i18n.t("bulk_import.edit_tooltip", "Edit selected prompt in popup editor"))
                            enabled: previewList.currentIndex >= 0 && !root.imageModeActive
                            onClicked: root.openEditor(previewList.currentIndex, root.parseItems()[previewList.currentIndex] || "")
                        }

                        VfButton {
                            objectName: "bulkImportMergeButton"   // tour
                            text: (void i18n.revision, i18n.t("bulk_import.merge_btn", "Merge"))
                            Layout.fillWidth: true
                            compact: previewActionGrid.columns < 6
                            minWidth: VfTheme.dp(68)
                            implicitHeight: VfTheme.dp(38)
                            tooltip: (void i18n.revision, i18n.t("bulk_import.merge_tooltip", "Merge selected prompts"))
                            enabled: root.selectedCount() > 1 && !root.imageModeActive
                            onClicked: root.mergeSelectedPrompts()
                        }

                        VfButton {
                            objectName: "bulkImportSplitButton"   // tour
                            text: (void i18n.revision, i18n.t("bulk_import.split_btn", "Split"))
                            Layout.fillWidth: true
                            compact: previewActionGrid.columns < 6
                            minWidth: VfTheme.dp(68)
                            implicitHeight: VfTheme.dp(38)
                            tooltip: (void i18n.revision, i18n.t("bulk_import.split_tooltip", "Split selected prompt"))
                            enabled: previewList.currentIndex >= 0 && !root.imageModeActive
                            onClicked: root.splitSelectedPrompt()
                        }

                        VfButton {
                            text: (void i18n.revision, i18n.t("bulk_import.delete_btn", "Delete"))
                            tone: "danger"
                            Layout.fillWidth: true
                            compact: previewActionGrid.columns < 6
                            minWidth: VfTheme.dp(68)
                            implicitHeight: VfTheme.dp(38)
                            tooltip: (void i18n.revision, i18n.t("bulk_import.delete_tooltip", "Delete selected prompt"))
                            enabled: previewList.currentIndex >= 0 && !root.imageModeActive
                            onClicked: root.removeParsedItem(previewList.currentIndex)
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            Layout.bottomMargin: 12
            spacing: VfTheme.dp(8)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("bulk_import.stats_ready", "Ready to import"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
            }

            VfButton {
                text: (void i18n.revision, i18n.t("bulk_import.clear_all", "Clear All"))
                minWidth: VfTheme.dp(104)
                tooltip: (void i18n.revision, i18n.t("bulk_import.clear_markers_tooltip", "Clear all input"))
                onClicked: root.clearInput()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("bulk_import.cancel_btn", "Cancel"))
                minWidth: VfTheme.dp(96)
                tooltip: (void i18n.revision, i18n.t("bulk_import.cancel_btn", "Cancel"))
                onClicked: root.reject()
            }

            VfButton {
                objectName: "bulkImportAcceptButton"   // tour
                text: root.imageModeActive
                    ? (void i18n.revision, i18n.t("bulk_import.import_image_cards", "Import Image Cards"))
                    : root.namedRefMode
                    ? (void i18n.revision, i18n.t("bulk_import.import_named_ref", "Import Named-ref Prompts"))
                    : root.scriptMode
                    ? (void i18n.revision, i18n.t("bulk_import.import_scripts", "Import Scripts"))
                    : (void i18n.revision, i18n.t("bulk_import.import_prompts", "Import Prompts"))
                tone: "success"
                minWidth: VfTheme.dp(176)
                tooltip: text
                enabled: root.selectedCount() > 0
                onClicked: {
                    root.acceptSelection()
                }
            }
        }
        }
    }

    Menu {
        id: imageContextMenu

        MenuItem {
            text: (void i18n.revision, i18n.t("bulk_import.ctx_preview_image", "Preview image"))
            enabled: root.contextMenuImagePath.length > 0
            onTriggered: root._preview_named_ref_image(root.contextMenuImagePath)
        }

        MenuSeparator {}

        MenuItem {
            text: (void i18n.revision, i18n.t("bulk_import.ctx_move_up", "Move up"))
            enabled: root.contextMenuIndex > 0
            onTriggered: root._move_named_ref_image(root.contextMenuIndex, -1)
        }

        MenuItem {
            text: (void i18n.revision, i18n.t("bulk_import.ctx_move_down", "Move down"))
            enabled: root.contextMenuIndex >= 0 && root.contextMenuIndex < root.namedRefImagePaths.length - 1
            onTriggered: root._move_named_ref_image(root.contextMenuIndex, 1)
        }

        MenuSeparator {}

        MenuItem {
            text: (void i18n.revision, i18n.t("bulk_import.ctx_delete", "Delete"))
            enabled: root.contextMenuIndex >= 0
            onTriggered: root._remove_named_ref_image(root.contextMenuIndex)
        }
    }

    Dialog {
        id: promptEditDialog

        property int targetIndex: -1

        modal: true
        width: VfDialogMetrics.width(root, VfTheme.dp(760), VfTheme.dp(80))
        height: VfDialogMetrics.height(root, VfTheme.dp(420), VfTheme.dp(120))
        x: VfDialogMetrics.centerX(root, width)
        y: VfDialogMetrics.centerY(root, height)
        padding: VfTheme.dp(12)
        standardButtons: Dialog.NoButton

        function openFor(index, text) {
            targetIndex = Number(index)
            editArea.text = String(text || "")
            open()
        }

        background: Rectangle {
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
            radius: VfTheme.dp(8)
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            spacing: VfTheme.dp(8)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("bulk_import.edit_prompt_title", "Edit Prompt"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(14)
                font.weight: Font.Bold
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(6)
                color: VfTheme.surface
                border.color: VfTheme.borderStrong
                clip: true

                ScrollView {
                    id: editAreaScroll
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    contentWidth: availableWidth
                    contentHeight: editArea.implicitHeight
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    TextArea {
                        id: editArea
                        width: editAreaScroll.availableWidth
                        wrapMode: TextArea.Wrap
                        selectByMouse: true
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        background: Item {}
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("bulk_import.cancel_btn", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: promptEditDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.save", "Save"))
                    tone: "accent"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        root.replaceParsedItem(promptEditDialog.targetIndex, editArea.text)
                        promptEditDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: spreadsheetColumnDialog

        // Chosen column index + 1-based inclusive row range the user imports.
        property int selectedColumnIndex: 0
        property int fromRow: 1
        property int toRow: 1

        modal: true
        closePolicy: Popup.CloseOnEscape
        width: VfDialogMetrics.width(root, VfTheme.dp(500), VfTheme.dp(120))
        height: VfDialogMetrics.height(root, VfTheme.dp(452), VfTheme.dp(160))
        x: VfDialogMetrics.centerX(root, width)
        y: VfDialogMetrics.centerY(root, height)
        padding: VfTheme.dp(16)
        standardButtons: Dialog.NoButton

        function rowCap() {
            return Math.max(1, Number(root._spreadsheetRowCount || 1))
        }

        function clampRow(value, fallback) {
            var n = Math.floor(Number(value))
            if (!isFinite(n))
                n = Number(fallback || 1)
            return Math.max(1, Math.min(spreadsheetColumnDialog.rowCap(), n))
        }

        function selectedColumnMeta() {
            var cols = root._spreadsheetColumns || []
            for (var i = 0; i < cols.length; ++i) {
                if (Number(cols[i].index) === spreadsheetColumnDialog.selectedColumnIndex)
                    return cols[i]
            }
            return cols.length ? cols[0] : ({})
        }

        function estimatedCount() {
            // Honest upper bound: rows in range, capped by the column's filled cells.
            var meta = spreadsheetColumnDialog.selectedColumnMeta()
            var span = Math.max(0, spreadsheetColumnDialog.toRow - spreadsheetColumnDialog.fromRow + 1)
            var filled = Number(meta.count || 0)
            return filled > 0 ? Math.min(span, filled) : span
        }

        onOpened: {
            fromRowField.text = String(spreadsheetColumnDialog.fromRow)
            toRowField.text = String(spreadsheetColumnDialog.toRow)
        }

        background: Rectangle {
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
            radius: VfTheme.dp(8)
        }

        contentItem: ColumnLayout {
            // KHÔNG dùng anchors.fill: parent — nó phủ kín popup và bỏ qua padding
            // của Dialog → nút bấm sát viền. Để Dialog tự size contentItem trong
            // vùng padding (giống feedbackDialog).
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("bulk_import.choose_column_title", "Chọn cột & dòng để import"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(15)
                font.weight: Font.Bold
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("bulk_import.choose_column_hint", "Mỗi dòng của cột đã chọn = 1 prompt."))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                wrapMode: Text.WordWrap
            }

            VfSelectField {
                id: spreadsheetColumnSelect
                Layout.fillWidth: true
                Layout.topMargin: VfTheme.dp(2)
                label: (void i18n.revision, i18n.t("bulk_import.column_field_label", "Cột chứa prompt"))
                options: root._spreadsheetColumns
                value: spreadsheetColumnDialog.selectedColumnIndex
                accent: VfTheme.primary
                onSelected: value => spreadsheetColumnDialog.selectedColumnIndex = Number(value)
            }

            Text {
                Layout.fillWidth: true
                visible: text.length > 0
                text: {
                    var meta = spreadsheetColumnDialog.selectedColumnMeta()
                    var sample = String(meta.sample || "")
                    return sample.length
                        ? ((void i18n.revision, i18n.t("bulk_import.column_sample", "Mẫu: ")) + sample)
                        : ""
                }
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WordWrap
            }

            // "Chọn hàng": import only rows [from..to] (1-based, inclusive).
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: VfTheme.dp(2)
                spacing: VfTheme.dp(8)

                Text {
                    text: (void i18n.revision, i18n.t("bulk_import.row_range_label", "Dòng:"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: VfTheme.weightStrong
                }

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(82)
                    Layout.preferredHeight: VfTheme.dp(34)
                    radius: VfTheme.radiusControl - 2
                    color: VfTheme.surfaceSoft
                    border.width: 1
                    border.color: fromRowField.activeFocus ? VfTheme.primary : VfTheme.borderBox

                    TextField {
                        id: fromRowField
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(2)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 1; top: 9999999 }
                        selectByMouse: true
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                        background: null
                        onEditingFinished: {
                            var v = spreadsheetColumnDialog.clampRow(text, 1)
                            if (v > spreadsheetColumnDialog.toRow)
                                v = spreadsheetColumnDialog.toRow
                            spreadsheetColumnDialog.fromRow = v
                            text = String(v)
                        }
                    }
                }

                Text {
                    text: "→"
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                }

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(82)
                    Layout.preferredHeight: VfTheme.dp(34)
                    radius: VfTheme.radiusControl - 2
                    color: VfTheme.surfaceSoft
                    border.width: 1
                    border.color: toRowField.activeFocus ? VfTheme.primary : VfTheme.borderBox

                    TextField {
                        id: toRowField
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(2)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 1; top: 9999999 }
                        selectByMouse: true
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                        background: null
                        onEditingFinished: {
                            var v = spreadsheetColumnDialog.clampRow(text, spreadsheetColumnDialog.rowCap())
                            if (v < spreadsheetColumnDialog.fromRow)
                                v = spreadsheetColumnDialog.fromRow
                            spreadsheetColumnDialog.toRow = v
                            text = String(v)
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("bulk_import.row_total_hint", "/ %1 dòng")).arg(spreadsheetColumnDialog.rowCap())
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    elide: Text.ElideRight
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root._spreadsheetHeaderDetected
                text: (void i18n.revision, i18n.t("bulk_import.header_skip_hint", "Dòng 1 có vẻ là tiêu đề — đặt 'từ dòng' = 2 để bỏ qua nếu cần."))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                wrapMode: Text.WordWrap
            }

            Item { Layout.fillHeight: true }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("bulk_import.import_estimate", "≈ %1 prompt sẽ được import")).arg(spreadsheetColumnDialog.estimatedCount())
                color: VfTheme.primary
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                font.weight: VfTheme.weightStrong
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("bulk_import.cancel_btn", "Hủy"))
                    minWidth: VfTheme.dp(96)
                    onClicked: spreadsheetColumnDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("bulk_import.import_btn", "Import Prompts"))
                    tone: "accent"
                    minWidth: VfTheme.dp(120)
                    onClicked: {
                        var colIndex = Number(spreadsheetColumnDialog.selectedColumnIndex || 0)
                        var fromRow = Number(spreadsheetColumnDialog.fromRow || 1)
                        var toRow = Number(spreadsheetColumnDialog.toRow || 0)
                        spreadsheetColumnDialog.close()
                        root.spreadsheetColumnChosen(root._spreadsheetPath, colIndex, fromRow, toRow)
                    }
                }
            }
        }
    }

    Dialog {
        id: imagePreviewDialog

        property string imagePath: ""

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(root, VfTheme.dp(720), VfTheme.dp(80))
        height: VfDialogMetrics.height(root, VfTheme.dp(540), VfTheme.dp(120))
        padding: VfTheme.dp(16)
        title: ""
        header: null
        standardButtons: Dialog.NoButton

        background: Rectangle {
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
            radius: VfTheme.dp(8)
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                text: root.fileName(imagePreviewDialog.imagePath)
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(14)
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(8)
                color: "#0F172A"

                Image {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    source: root.imageDisplaySource(imagePreviewDialog.imagePath)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("about.close_btn", "Close"))
                    minWidth: VfTheme.dp(96)
                    onClicked: imagePreviewDialog.close()
                }
            }
        }
    }

    Dialog {
        id: feedbackDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(root, VfTheme.dp(460), VfTheme.dp(80))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        standardButtons: Dialog.NoButton

        background: Rectangle {
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
            radius: VfTheme.dp(8)
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Text {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }

    component TextImportModePanel: Rectangle {
        radius: VfTheme.dp(6)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        clip: true

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(12)
            anchors.rightMargin: VfTheme.dp(12)
            anchors.topMargin: VfTheme.dp(8)
            anchors.bottomMargin: VfTheme.dp(8)
            spacing: VfTheme.dp(12)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("bulk_import.import_mode", "Import Mode"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                font.weight: Font.Bold
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            RadioButton {
                text: (void i18n.revision, i18n.t("bulk_import.auto_mode", "AUTO"))
                checked: !root.manualMode
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                onClicked: root.manualMode = false
            }

            RadioButton {
                text: (void i18n.revision, i18n.t("bulk_import.manual_mode", "MANUAL"))
                checked: root.manualMode
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                onClicked: root.manualMode = true
            }
        }
    }

    component ImageListPanel: Rectangle {
        radius: VfTheme.dp(6)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(8)
            spacing: VfTheme.dp(7)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("bulk_import.image_list_label", "Image list"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Text {
                    text: (void i18n.revision, i18n.t("bulk_import.image_count_status", "{count} image(s)"))
                        .replace("{count}", String(root.activeImportImagePaths().length))
                    color: root.imageModeAccent()
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    font.weight: Font.DemiBold
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("bulk_import.add_image_folder", "Folder"))
                    iconName: "open-folder"
                    compact: true
                    minWidth: VfTheme.dp(84)
                    tooltip: root.namedRefMode
                        ? (void i18n.revision, i18n.t("bulk_import.add_image_folder_named_ref_tooltip", "Add a whole image folder. Files are matched to prompts by filename."))
                        : (void i18n.revision, i18n.t("bulk_import.add_image_folder_tooltip", "Add all images from a folder."))
                    onClicked: root.imageFolderRequested()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("bulk_import.add_image_files", "Files"))
                    iconName: "framed-picture"
                    compact: true
                    minWidth: VfTheme.dp(74)
                    tooltip: root.namedRefMode
                        ? (void i18n.revision, i18n.t("bulk_import.add_image_files_named_ref_tooltip", "Add individual image files. Name each file to match the word in its prompt."))
                        : (void i18n.revision, i18n.t("bulk_import.add_image_files_tooltip", "Add individual image files."))
                    onClicked: root.imageFilesRequested()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("bulk_import.media_library", "Media"))
                    iconName: "inbox-tray"
                    compact: true
                    minWidth: VfTheme.dp(82)
                    tooltip: (void i18n.revision, i18n.t("bulk_import.media_library_tooltip", "Pick images from the Media Library."))
                    onClicked: root.mediaLibraryRequested()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(6)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border
                clip: true

                ListView {
                    id: imageInputListView
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(5)
                    model: root.activeImportImagePaths()
                    clip: true
                    reuseItems: true

                    delegate: Rectangle {
                        width: imageInputListView.width
                        height: root.imageThumbnailsVisible ? VfTheme.dp(50) : VfTheme.dp(32)
                        radius: VfTheme.dp(4)
                        color: index === root.imageSelectedIndex ? root.imageModeAccent() : VfTheme.surface
                        border.color: index === root.imageSelectedIndex ? root.imageModeAccent() : VfTheme.border

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(7)
                            anchors.rightMargin: VfTheme.dp(7)
                            spacing: VfTheme.dp(7)

                            Rectangle {
                                visible: root.imageThumbnailsVisible
                                Layout.preferredWidth: VfTheme.dp(38)
                                Layout.preferredHeight: VfTheme.dp(38)
                                radius: VfTheme.dp(5)
                                color: VfTheme.border
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    source: root.imageDisplaySource(modelData)
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: false
                                }
                            }

                            Text {
                                text: String(index + 1) + "."
                                color: index === root.imageSelectedIndex ? "#FFFFFF" : root.imageModeAccent()
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                font.weight: Font.Bold
                            }

                            Text {
                                Layout.fillWidth: true
                                text: String((root.activeImportImageNames() || ({}))[modelData] || root.fileName(modelData))
                                color: index === root.imageSelectedIndex ? "#FFFFFF" : VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: function(mouse) {
                                root.imageSelectedIndex = index
                                if (mouse.button === Qt.RightButton)
                                    root._preview_named_ref_image(modelData)
                            }
                            onDoubleClicked: root._preview_named_ref_image(modelData)
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.activeImportImagePaths().length === 0
                    text: (void i18n.revision, i18n.t("bulk_import.image_list_empty", "Add image files, folder images, or Media Library items."))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    width: parent.width - VfTheme.dp(24)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)

                VfButton {
                    text: (void i18n.revision, i18n.t("bulk_import.move_up", "Up"))
                    iconName: "chevron-up"
                    compact: true
                    minWidth: VfTheme.dp(64)
                    enabled: root.imageSelectedIndex > 0
                    onClicked: root.moveSelectedImportImage(-1)
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("bulk_import.move_down", "Down"))
                    iconName: "chevron-down"
                    compact: true
                    minWidth: VfTheme.dp(74)
                    enabled: root.imageSelectedIndex >= 0 && root.imageSelectedIndex < root.activeImportImagePaths().length - 1
                    onClicked: root.moveSelectedImportImage(1)
                }

                VfButton {
                    text: root.imageThumbnailsVisible
                        ? (void i18n.revision, i18n.t("bulk_import.hide_thumbnails", "Hide thumbs"))
                        : (void i18n.revision, i18n.t("bulk_import.show_thumbnails", "Show thumbs"))
                    iconName: "magnifying-glass"
                    compact: true
                    minWidth: VfTheme.dp(112)
                    onClicked: root.imageThumbnailsVisible = !root.imageThumbnailsVisible
                }

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.remove", "Remove"))
                    iconName: "cross-mark"
                    compact: true
                    tone: "danger"
                    minWidth: VfTheme.dp(86)
                    enabled: root.imageSelectedIndex >= 0
                    onClicked: root.removeSelectedImportImage()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.clear", "Clear"))
                    iconName: "scissors"
                    compact: true
                    minWidth: VfTheme.dp(76)
                    enabled: root.activeImportImagePaths().length > 0
                    onClicked: root.clearImportImagePaths()
                }
            }
        }
    }

    component ImageSubmodeButton: Rectangle {
        id: submodeButton
        property var option: ({})
        readonly property bool selected: String(option.value || "") === root.imageImportSubmode
        readonly property color accent: option.accent || root.imageModeAccent()

        Layout.preferredHeight: VfTheme.dp(38)
        radius: VfTheme.dp(7)
        color: selected ? root.imageModeAccent() : VfTheme.surface
        border.color: selected ? root.imageModeAccent() : VfTheme.borderStrong
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(10)
            anchors.rightMargin: VfTheme.dp(10)
            spacing: VfTheme.dp(7)

            VfAppIcon {
                name: String(submodeButton.option.iconName || root.imageModeIconName())
                size: VfTheme.dp(18)
                color: submodeButton.selected
                    ? "#FFFFFF"
                    : (submodeButton.accent || AppIconRegistry.iconColor(name) || VfTheme.text)
            }

            Text {
                Layout.fillWidth: true
                text: String(submodeButton.option.label || "")
                color: submodeButton.selected ? "#FFFFFF" : VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                font.weight: submodeButton.selected ? Font.Bold : Font.DemiBold
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.setImageSubmode(submodeButton.option.value)
        }
    }

    component AutoControls: Rectangle {
        radius: VfTheme.dp(6)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        implicitHeight: VfTheme.dp(208)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(10)
            spacing: VfTheme.dp(8)

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("bulk_import.auto_detection_info", "Detection Info"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(14)
                    font.weight: Font.Bold
                }
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("bulk_import.analyzing", "Analyzing..."))
                color: VfTheme.textMuted
                wrapMode: Text.WordWrap
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(6)
                color: VfTheme.blueFill
                border.color: "#3B82F6"

                Text {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    text: (void i18n.revision, i18n.t("bulk_import.auto_mode_explanation", "Auto mode detects JSON, scenes, numbered lists, bullets, paragraphs, and sentence context."))
                    color: "#2563EB"
                    wrapMode: Text.WordWrap
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    component ManualControls: Rectangle {
        radius: VfTheme.dp(6)
        color: VfTheme.greenFill
        border.color: "#10B981"
        implicitHeight: VfTheme.dp(122)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(8)
            spacing: VfTheme.dp(6)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("bulk_import.manual_controls", "Manual controls"))
                color: VfTheme.greenText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                font.weight: Font.Bold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)

                VfButton {
                    text: (void i18n.revision, i18n.t("bulk_import.mark_btn", "Mark"))
                    minWidth: VfTheme.dp(72)
                    implicitHeight: VfTheme.dp(28)
                    onClicked: root.markSelectedText()
                }
                VfButton {
                    text: (void i18n.revision, i18n.t("bulk_import.auto_mark_btn", "Auto mark"))
                    minWidth: VfTheme.dp(92)
                    implicitHeight: VfTheme.dp(28)
                    onClicked: root.autoMarkSimilar()
                }
                VfButton {
                    text: (void i18n.revision, i18n.t("bulk_import.clear_all_markers", "Clear markers"))
                    minWidth: VfTheme.dp(112)
                    implicitHeight: VfTheme.dp(28)
                    onClicked: root.clearAllMarkers()
                }
                VfButton {
                    text: (void i18n.revision, i18n.t("bulk_import.undo_btn", "Undo"))
                    minWidth: VfTheme.dp(70)
                    implicitHeight: VfTheme.dp(28)
                    enabled: root.markHistory.length > 0
                    onClicked: root.undoLastMark()
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.markerInfoText.length > 0
                    ? root.markerInfoText
                    : (void i18n.revision, i18n.t("bulk_import.manual_mode_explanation", "Use markers when auto parsing cannot identify prompt boundaries reliably."))
                color: VfTheme.greenText
                wrapMode: Text.WordWrap
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
            }
        }
    }
}
