import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"
import "../components/MediaSourceResolver.js" as MediaSourceResolver

Dialog {
    id: root
    objectName: "mediaLibraryDialog"

    property var items: []
    property var stats: ({})
    property var settings: ({})
    property string selectedMediaId: ""
    property bool importPanelOpen: false
    property var previewResult: ({})
    property var cropResult: ({})
    property string croppedImagePath: ""
    property var pendingDeleteIds: []
    property string pendingRenameMediaId: ""
    property string pendingRenameMediaName: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property string filterType: ""
    property string mode: "manage"
    property string launchContext: "manage" // manage | usage_picker
    property var allowedAssetTypes: []
    property var filteredMediaItems: []
    property var voiceServiceAdapter: typeof taxonomyController !== "undefined" ? taxonomyController : null
    property string voiceSearchText: ""
    property var voiceRows: []
    property string selectedVoiceId: ""
    property var voiceBoundRows: []
    property string selectedVoiceBoundMediaId: ""
    property string voiceDetailText: ""
    property var lastVoicePreviewResult: ({})
    property var lastVoiceBindResult: ({})
    property var lastVoiceUnbindResult: ({})
    property var voiceBaseOptions: []
    property string voiceGenStatus: ""
    property var voiceCharacterRows: []
    property string lastRefreshSearch: ""
    property string lastRefreshFilterType: "__never__"
    readonly property bool selectMode: root.mode === "select"
    readonly property bool managementMode: !root.selectMode && root.launchContext !== "usage_picker"
    property var selectedMediaIds: []
    property int maxSelection: 9999
    property bool appendSelection: false

    onSelectedMediaIdChanged: {
        if (root.maxSelection === 1)
            root.selectedMediaIds = root.selectedMediaId.length > 0 ? [root.selectedMediaId] : []
    }

    signal refreshRequested(string search, string assetType)
    signal mediaSelected(var selection)
    signal importRequested(string rawPaths, string tags, string assetType)

    onItemsChanged: {
        if (!root.visible)
            return
        root.rebuildFilteredItems()
        root._rebuild_voice_character_rows()
    }
    onFilterTypeChanged: root.rebuildFilteredItems()
    onAllowedAssetTypesChanged: {
        root.normalizeFilterForContext()
        root.rebuildFilteredItems()
    }
    onModeChanged: {
        root.normalizeFilterForContext()
        root.rebuildFilteredItems()
    }
    onLaunchContextChanged: {
        root.normalizeFilterForContext()
        root.rebuildFilteredItems()
    }
    Component.onCompleted: {
        root.normalizeFilterForContext()
        root.rebuildFilteredItems()
        root._rebuild_voice_character_rows()
    }

    modal: true
    parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, VfTheme.dp(1750), VfTheme.dp(40))
    height: VfDialogMetrics.height(parent, VfTheme.dp(1000), VfTheme.dp(40))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    header: VfDialogHeader {
        title: root.selectMode
            ? (void i18n.revision, i18n.t("media_library.select_title", "Chọn tệp Media"))
            : (void i18n.revision, i18n.t("media_library.title", "Media Library"))
        iconName: "framed-picture"
        compact: true
        onCloseClicked: root.reject()
    }

    onOpened: {
        root.normalizeFilterForContext()
        root.resetOpenState()
        if (!root.managementMode)
            root.importPanelOpen = false
        if (root.launchContext === "usage_picker" && searchInput.text.length > 0) {
            searchInput.text = ""
            searchRefreshTimer.stop()
        }
        root.rebuildFilteredItems()
        root._rebuild_voice_character_rows()
        Qt.callLater(function() {
            if (!root.visible)
                return
            root.normalizeFilterForContext()
            var search = String(searchInput.text || "")
            if ((root.items || []).length === 0
                    || search.length > 0
                    || root.lastRefreshSearch !== search
                    || root.lastRefreshFilterType !== String(root.filterType || ""))
                root.requestRefresh(search)
            if (root.managementMode)
                root._load_voice_library(root.voiceSearchText || search)
        })
    }

    Connections {
        target: root.voiceServiceAdapter
        ignoreUnknownSignals: true
        // Presync (entity + image + audio sync per account) finishes in a
        // background thread; refresh the binding readiness cards in realtime.
        function onMediaVoiceBindingSynced(result) {
            if (!root.visible || !root.managementMode)
                return
            root._load_voice_bound_characters(root._selected_voice_row())
            if (result && result.ok === false && String(result.message || "").length > 0)
                root.showFeedback(
                    (void i18n.revision, i18n.t("media_library.bind_voice_title", "Bind Voice")),
                    String(result.message)
                )
        }
    }

    function resetOpenState() {
        var keepIds = (root.selectMode && root.appendSelection) ? [].concat(root.selectedMediaIds || []) : []
        var keepId = (root.selectMode && root.appendSelection)
            ? String(root.selectedMediaId || (keepIds.length > 0 ? keepIds[0] : ""))
            : ""
        root.selectedMediaIds = keepIds
        root.selectedMediaId = keepId
        root.previewResult = ({})
        root._previewedMediaId = ""
        root.cropResult = ({})
        root.croppedImagePath = ""
        root.pendingDeleteIds = []
        root.pendingRenameMediaId = ""
        root.pendingRenameMediaName = ""
        if (typeof mediaGrid !== "undefined") {
            if (keepIds.length > 0)
                mediaGrid.commitSelection(keepIds)
            else
                mediaGrid.clearSelection()
        }
    }

    function selectedItem() {
        var list = root.items || []
        for (var i = 0; i < list.length; i++) {
            var item = list[i]
            if (String(item.id || item.media_id || "") === root.selectedMediaId)
                return item
        }
        return ({})
    }

    function selectedItems() {
        var ids = root.selectedMediaIds || []
        var wanted = {}
        for (var i = 0; i < ids.length; i++)
            wanted[String(ids[i] || "")] = true
        var list = root.items || []
        var out = []
        for (var j = 0; j < list.length; j++) {
            var item = list[j] || ({})
            var mediaId = String(item.id || item.media_id || "")
            if (mediaId.length > 0 && wanted[mediaId])
                out.push(item)
        }
        return out
    }

    function selectedSourcePath() {
        var item = root.selectedItem()
        return String(item.source_path || item.file_path || item.path || "")
    }

    function selectedDisplaySourcePath() {
        var item = root.selectedItem()
        if (Boolean(item.source_missing))
            return ""
        return String(item.original_source_path || item.source_path || item.file_path || item.path || "")
    }

    function selectedPreviewImageSource() {
        return MediaSourceResolver.previewImageSource(root.selectedItem())
    }

    function selectedName() {
        var item = root.selectedItem()
        return String(item.name || item.title || item.file_name || root.selectedMediaId || "")
    }

    function thumbSource(item) {
        return MediaSourceResolver.imageSource(item || ({}))
    }

    function localFileUrl(value) {
        return MediaSourceResolver.localFileUrl(value)
    }

    function dataImageMime(raw, item) {
        return MediaSourceResolver.dataImageMime(raw, item || ({}))
    }

    function dataImageUrl(raw, item) {
        return MediaSourceResolver.dataImageUrl(raw, item || ({}))
    }

    function requestRefresh(search) {
        root.normalizeFilterForContext()
        root.lastRefreshSearch = String(search || "")
        root.lastRefreshFilterType = String(root.filterType || "")
        // The voice tab filters characters client-side (characterRows()); no
        // media item has asset_type "voice", so a backend "voice" filter would
        // wipe items and blank the character grid after every bind/refresh.
        var backendAssetType = root.normalizedAssetType(root.filterType) === "voice"
            ? ""
            : root.lastRefreshFilterType
        root.refreshRequested(root.lastRefreshSearch, backendAssetType)
    }

    function normalizedAssetType(value) {
        var key = String(value || "").trim().toLowerCase()
        if (key === "characters")
            return "character"
        if (key === "objects")
            return "object"
        if (key === "backgrounds")
            return "background"
        return key
    }

    function allowedTypeList() {
        var raw = root.allowedAssetTypes || []
        var out = []
        if (!raw || raw.length === undefined)
            return out
        for (var i = 0; i < raw.length; i++) {
            var key = root.normalizedAssetType(raw[i])
            if (key.length > 0 && out.indexOf(key) < 0)
                out.push(key)
        }
        return out
    }

    function filterChipVisible(value) {
        var key = root.normalizedAssetType(value)
        if (key === "voice")
            return root.managementMode
        var allowed = root.allowedTypeList()
        if (allowed.length <= 0)
            return true
        if (key.length <= 0)
            return false
        return allowed.indexOf(key) >= 0
    }

    function firstAllowedFilter() {
        var allowed = root.allowedTypeList()
        if (allowed.length > 0)
            return allowed[0]
        if (root.normalizedAssetType(root.filterType) === "voice" && !root.managementMode)
            return ""
        return root.normalizedAssetType(root.filterType)
    }

    function normalizeFilterForContext() {
        var next = root.normalizedAssetType(root.filterType)
        if (!root.filterChipVisible(next))
            next = root.firstAllowedFilter()
        if (String(root.filterType || "") !== next)
            root.filterType = next
    }

    function openUsagePicker(initialFilter, allowedTypes, selectedIds, maxItems, append) {
        root.launchContext = "usage_picker"
        root.mode = "select"
        root.allowedAssetTypes = [].concat(allowedTypes || [])
        root.filterType = root.normalizedAssetType(initialFilter)
        root.maxSelection = Math.max(0, Number(maxItems === undefined ? root.maxSelection : maxItems))
        root.appendSelection = Boolean(append)
        root.selectedMediaIds = [].concat(selectedIds || [])
        root.selectedMediaId = root.selectedMediaIds.length > 0 ? String(root.selectedMediaIds[0] || "") : ""
        root.normalizeFilterForContext()
        root.open()
    }

    function isCharacterItem(item) {
        item = item || ({})
        var meta = item.ai_metadata || ({})
        var assetType = String(item.asset_type || meta.asset_type || item.type || "").toLowerCase()
        if (assetType === "character")
            return true
        var tags = item.tags || []
        for (var i = 0; i < tags.length; i++) {
            if (String(tags[i] || "").toLowerCase() === "character")
                return true
        }
        return false
    }

    function characterRows() {
        var out = []
        var list = root.items || []
        for (var i = 0; i < list.length; i++) {
            if (root.isCharacterItem(list[i]))
                out.push(list[i])
        }
        return out
    }

    function _rebuild_voice_character_rows() {
        // Rebuild the voice-tab character model explicitly (instead of a
        // characterRows() model binding) so the grid keeps its scroll position
        // when the media library refreshes after a bind.
        var grid = (typeof voiceCharacterCardGrid !== "undefined") ? voiceCharacterCardGrid : null
        var savedY = grid ? grid.contentY : 0
        root.voiceCharacterRows = root.characterRows()
        if (grid) {
            Qt.callLater(function() {
                var maxY = Math.max(0, grid.contentHeight - grid.height)
                grid.contentY = Math.min(Math.max(0, savedY), maxY)
            })
        }
    }

    function boundVoiceLabelForMedia(item) {
        item = item || ({})
        var meta = item.ai_metadata || ({})
        var structure = meta.structure || ({})
        var fv = structure.flow_voice || structure.flowVoice || null
        if (!fv)
            return ""
        return String(fv.base_voice || fv.baseVoice || fv.speaker || fv.name || "Voice")
    }

    function bindingStatusText(row) {
        row = row || ({})
        var required = Number(row.required_account_count || 0)
        if (String(row.status || "") === "no_accounts")
            return (void i18n.revision, i18n.t("media_library.voice_status_no_accounts", "Chưa có account live"))
        if (Boolean(row.ready))
            return (void i18n.revision, i18n.t("media_library.voice_status_ready", "Sẵn sàng"))
        return (void i18n.revision, i18n.t("media_library.voice_status_sync", "Ảnh {img}/{total} · Entity {entity}/{total} · Voice {voice}/{total}"))
            .replace(/\{img\}/g, String(row.image_uploaded_count || 0))
            .replace(/\{entity\}/g, String(row.entity_synced_count || 0))
            .replace(/\{voice\}/g, String(row.voice_synced_count || 0))
            .replace(/\{total\}/g, String(required))
    }

    function bindingStatusColor(row) {
        row = row || ({})
        if (Boolean(row.ready))
            return "#059669"
        if (String(row.status || "") === "no_accounts")
            return VfTheme.textSubtle
        if (String(row.status || "") === "stale")
            return "#D97706"
        return "#2563EB"
    }

    function voiceRowId(row) {
        return String((row || {}).id || (row || {}).media_id || "")
    }

    function voiceRowName(row) {
        return String((row || {}).name || voiceRowId(row))
    }

    function formatCountText(templateText, countValue) {
        var value = String(countValue || 0)
        return String(templateText || "")
            .replace("{count}", value)
            .replace("%1", value)
    }

    function requestNativeMediaPicker(kind) {
        if (!root.managementMode)
            return
        if (typeof nativeShell === "undefined")
            return
        if (kind === "folder") {
            var pickedFolder = nativeShell.pickFolder(
                (void i18n.revision, i18n.t("qml.media_library.browse_folder", "Browse Folder")),
                ""
            )
            if (pickedFolder && pickedFolder.ok)
                pathsInput.text = root.appendPaths(pathsInput.text, [pickedFolder.path || ""])
            return
        }
        var pickedFiles = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("qml.media_library.browse_files", "Browse Files")),
            "Images (*.png *.jpg *.jpeg *.webp *.gif);;Videos (*.mp4 *.mov *.avi *.mkv *.webm);;All Files (*.*)",
            ""
        )
        if (pickedFiles && pickedFiles.ok)
            pathsInput.text = root.appendPaths(pathsInput.text, pickedFiles.paths || [])
    }

    function appendPaths(current, paths) {
        var lines = []
        var text = String(current || "").trim()
        if (text.length > 0)
            lines.push(text)
        for (var i = 0; i < (paths || []).length; i++) {
            var path = String(paths[i] || "").trim()
            if (path.length > 0)
                lines.push(path)
        }
        return lines.join("\n")
    }

    function requestImportForVisualTest(rawPaths, tags, assetType) {
        if (!root.managementMode)
            return false
        var paths = String(rawPaths || "").trim()
        if (paths.length > 0)
            pathsInput.text = paths
        if (String(pathsInput.text || "").trim().length === 0)
            return false
        root.importPanelOpen = true
        root.importRequested(pathsInput.text, String(tags || ""), String(assetType || ""))
        return true
    }

    function requestImport(rawPaths, tags, assetType) {
        if (!root.managementMode)
            return
        if (typeof workPanelController !== "undefined" && workPanelController
                && typeof workPanelController.importMediaPaths === "function") {
            root.applyImportResult(workPanelController.importMediaPaths(rawPaths, tags, assetType))
            return
        }
        root.importRequested(rawPaths, tags, assetType)
    }

    function itemCountForVisualTest() {
        return (root.items || []).length
    }

    function selectedNameForVisualTest() {
        return root.selectedName()
    }

    function requestSelectFirstForVisualTest() {
        var list = root.filteredItems()
        if (!list || list.length <= 0)
            return false
        root.syncSingleSelection(list[0])
        root.requestSelectedPreview()
        return true
    }

    function controllerStatusMessage() {
        if (typeof workPanelController === "undefined" || !workPanelController)
            return ""
        return String(workPanelController.statusMessage || "")
    }

    function openSelectedSource() {
        if (typeof workPanelController === "undefined" || !workPanelController || typeof nativeShell === "undefined")
            return
        if (typeof workPanelController.prepareOpenMediaSource !== "function")
            return
        var result = workPanelController.prepareOpenMediaSource(root.selectedMediaId)
        if (!root.applyOpenSourceResult(result))
            return
        if (String(result.path || "").length > 0)
            root.applyOpenSourceResult(nativeShell.openPath(String(result.path)))
    }

    property string _previewedMediaId: ""

    function requestSelectedPreview() {
        if (root.selectedMediaId.length === 0 || typeof workPanelController === "undefined" || !workPanelController)
            return
        // Dedup: mỗi click grid phát cả selectionChanged + mediaSelected (2 call),
        // và re-click cùng item -> tránh gọi lại prepareMediaPreview (DB + base64).
        if (root.selectedMediaId === root._previewedMediaId)
            return
        if (typeof workPanelController.prepareMediaPreview !== "function")
            return
        root.previewResult = workPanelController.prepareMediaPreview(root.selectedMediaId)
        root._previewedMediaId = root.selectedMediaId
    }

    function invalidatePreviewCache() {
        root._previewedMediaId = ""
    }

    function requestCropPlan(payload) {
        if (typeof workPanelController === "undefined" || !workPanelController || typeof workPanelController.prepareMediaCrop !== "function") {
            root.cropResult = {
                ok: false,
                blocked: true,
                blocker: { code: "media_crop_controller_missing", message: "workPanelController.prepareMediaCrop is not available." }
            }
            cropperDialog.applyResult(root.cropResult)
            return
        }
        root.cropResult = workPanelController.prepareMediaCrop(payload)
        cropperDialog.applyResult(root.cropResult)
        root.croppedImagePath = String(root.cropResult.cropped_image_path || root.cropResult.output_path || "")
        if (root.selectMode && root.cropResult.ok && root.croppedImagePath.length > 0)
            root.mediaSelected(root.selectionPayload())
    }

    function openCropDialog() {
        if (root.selectedMediaIds.length !== 1 || root.selectedMediaId.length === 0) {
            cropSelectionWarningDialog.open()
            return
        }
        root.requestSelectedPreview()
        cropperDialog.openFor({
            sourcePath: root.selectedSourcePath(),
            mediaId: root.selectedMediaId,
            aspectRatio: "16:9"
        })
    }

    function selectionPayload() {
        var item = root.selectedItem()
        var items = root.selectedItems()
        return {
            mediaId: root.selectedMediaId,
            media_id: root.selectedMediaId,
            mediaIds: root.selectedMediaIds,
            media_ids: root.selectedMediaIds,
            media: item,
            item: item,
            items: items,
            merge: root.appendSelection,
            append: root.appendSelection,
            croppedImagePath: root.croppedImagePath,
            cropped_image_path: root.croppedImagePath,
            cropResult: root.cropResult
        }
    }

    function hasValidSelection() {
        var count = (root.selectedMediaIds || []).length
        if (count <= 0)
            return false
        return root.maxSelection === 0 || count <= root.maxSelection
    }

    function confirmSelection() {
        if (!root.hasValidSelection()) {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.select_failed", "Selection failed")),
                (void i18n.revision, i18n.t("media_library.select_missing", "Select at least one media item before confirming."))
            )
            return false
        }
        root.mediaSelected(root.selectionPayload())
        return true
    }

    function _load_voice_library(search) {
        if (!root.managementMode) {
            root.voiceRows = []
            root.voiceBoundRows = []
            root.selectedVoiceId = ""
            return
        }
        root.voiceSearchText = String(search !== undefined ? search : root.voiceSearchText || "")
        var payload = null
        if (root.voiceServiceAdapter && typeof root.voiceServiceAdapter.mediaVoiceLibraryPayload === "function")
            payload = root.voiceServiceAdapter.mediaVoiceLibraryPayload(root.voiceSearchText)
        else
            payload = {
                ok: false,
                blocked: true,
                code: "media_voice_library_controller_missing",
                message: "Voice library is unavailable in this host.",
                rows: []
            }

        var rows = [].concat((payload && (payload.rows || payload.items)) || [])
        root.voiceRows = rows

        var preferredId = String(root.selectedVoiceId || "")
        var selectedRow = null
        for (var i = 0; i < rows.length; i++) {
            if (root.voiceRowId(rows[i]) === preferredId) {
                selectedRow = rows[i]
                break
            }
        }
        if (!selectedRow && rows.length > 0)
            selectedRow = rows[0]

        if (selectedRow) {
            root.selectedVoiceId = root.voiceRowId(selectedRow)
            root._on_voice_selection_changed(selectedRow)
            return payload
        }

        root.selectedVoiceId = ""
        root.selectedVoiceBoundMediaId = ""
        root._update_voice_detail(null)
        root._load_voice_bound_characters({})
        return payload
    }

    function _selected_voice_row() {
        var wanted = String(root.selectedVoiceId || "")
        if (!wanted.length)
            return ({})
        for (var i = 0; i < root.voiceRows.length; i++) {
            var row = root.voiceRows[i]
            if (root.voiceRowId(row) === wanted)
                return row
        }
        return ({})
    }

    function _on_voice_selection_changed(item) {
        var row = ({})
        if (typeof item === "string") {
            root.selectedVoiceId = String(item || "")
            row = root._selected_voice_row()
        } else if (item && typeof item === "object") {
            row = item
            root.selectedVoiceId = root.voiceRowId(row)
        } else {
            row = root._selected_voice_row()
        }
        root._update_voice_detail(row)
        root._load_voice_bound_characters(row || {})
        return row
    }

    function _update_voice_detail(row) {
        row = row || ({})
        if (!root.voiceRowId(row).length) {
            root.voiceDetailText = "Select a voice"
            return root.voiceDetailText
        }

        var lines = [
            "Name: " + root.voiceRowName(row),
            "Type: " + String(row.kind || row.source || ""),
            "Media ID: " + root.voiceRowId(row)
        ]
        if (String(row.base_voice || "").length)
            lines.push("Base Voice: " + String(row.base_voice))
        if (String(row.speaker || "").length)
            lines.push("Speaker: " + String(row.speaker))
        if (String(row.voice_performance || "").length)
            lines.push("Performance: " + String(row.voice_performance))
        if (String(row.dialog || "").length)
            lines.push("Sample: " + String(row.dialog))
        if (String(row.workflow_id || "").length)
            lines.push("Workflow: " + String(row.workflow_id))
        if (String(row.preview_audio_path || row.sample_url || "").length)
            lines.push("Preview: " + String(row.preview_audio_path || row.sample_url))
        root.voiceDetailText = lines.join("\n")
        return root.voiceDetailText
    }

    function _load_voice_bound_characters(voiceRow) {
        if (!root.managementMode) {
            root.voiceBoundRows = []
            root.selectedVoiceBoundMediaId = ""
            return { ok: true, rows: [], items: [], total: 0 }
        }
        var payload = null
        if (root.voiceServiceAdapter && typeof root.voiceServiceAdapter.mediaVoiceBoundCharacters === "function")
            payload = root.voiceServiceAdapter.mediaVoiceBoundCharacters(voiceRow || {})
        else
            payload = { ok: true, rows: [], items: [], total: 0 }

        var previousBoundId = String(root.selectedVoiceBoundMediaId || "")
        root.voiceBoundRows = [].concat((payload && (payload.rows || payload.items)) || [])
        var keepBoundId = ""
        for (var i = 0; i < root.voiceBoundRows.length; i++) {
            if (String((root.voiceBoundRows[i] || {}).media_id || "") === previousBoundId) {
                keepBoundId = previousBoundId
                break
            }
        }
        root.selectedVoiceBoundMediaId = keepBoundId.length > 0
            ? keepBoundId
            : (root.voiceBoundRows.length > 0 ? String((root.voiceBoundRows[0] || {}).media_id || "") : "")
        return payload
    }

    function _on_create_voice() {
        if (!root.managementMode)
            return
        voiceCreateNameField.text = ""
        voiceCreateSpeakerField.text = ""
        voiceCreatePerformanceField.text = ""
        voiceCreateDialogField.text = ""
        root.voiceGenStatus = ""
        // Load base voices for the dropdown.
        root.voiceBaseOptions = []
        if (root.voiceServiceAdapter && typeof root.voiceServiceAdapter.mediaVoiceBaseOptions === "function") {
            var bo = root.voiceServiceAdapter.mediaVoiceBaseOptions()
            root.voiceBaseOptions = (bo && bo.rows) ? bo.rows : []
        }
        voiceCreateBaseCombo.currentIndex = root.voiceBaseOptions.length > 0 ? 0 : -1
        voiceCreateDialog.open()
    }

    function voicePreviewAvailable(row) {
        row = row || ({})
        return String(row.preview_audio_path || row.sample_url || "").length > 0
    }

    function _preview_voice_row(row) {
        if (!root.managementMode)
            return { ok: false, blocked: true, code: "media_voice_picker_disabled" }
        row = row || ({})
        var payload = null
        if (!root.voiceRowId(row).length) {
            payload = {
                ok: false,
                blocked: true,
                code: "media_voice_preview_missing_voice",
                action: "media.voice.preview",
                message: "Select a voice first."
            }
        } else if (root.voiceServiceAdapter && typeof root.voiceServiceAdapter.previewMediaVoice === "function") {
            root._on_voice_selection_changed(row)
            payload = root.voiceServiceAdapter.previewMediaVoice(row)
        } else {
            payload = {
                ok: false,
                blocked: true,
                code: "media_voice_preview_controller_missing",
                action: "media.voice.preview",
                message: "Voice preview is unavailable in this host."
            }
        }
        root.lastVoicePreviewResult = payload || ({})
        if (payload && payload.ok && Boolean(payload.played))
            return payload
        if (payload && payload.ok && typeof nativeShell !== "undefined" && nativeShell && String(payload.path || "").length > 0)
            nativeShell.openPath(String(payload.path))
        else if (payload && payload.ok === false && String(payload.message || "").length > 0)
            root.showFeedback((void i18n.revision, i18n.t("media_library.voice_preview_title", "Voice Preview")), String(payload.message))
        return payload
    }

    function _on_preview_voice() {
        return root._preview_voice_row(root._selected_voice_row())
    }

    function _on_bind_voice_to_character(mediaId) {
        if (!root.managementMode)
            return { ok: false, blocked: true, code: "media_voice_picker_disabled" }
        var row = root._selected_voice_row()
        if (!root.voiceRowId(row).length) {
            root.showFeedback((void i18n.revision, i18n.t("media_library.bind_voice_title", "Bind Voice")), (void i18n.revision, i18n.t("media_library.bind_voice_no_voice", "Select a voice first.")))
            return {
                ok: false,
                blocked: true,
                code: "media_voice_bind_missing_voice",
                action: "media.voice.bind",
                message: "Select a voice first."
            }
        }

        var targetId = String(mediaId || root.selectedMediaId || "")
        if (!targetId.length) {
            root.showFeedback((void i18n.revision, i18n.t("media_library.bind_voice_title", "Bind Voice")), (void i18n.revision, i18n.t("media_library.bind_voice_no_char", "Select a character first.")))
            return {
                ok: false,
                blocked: true,
                code: "media_voice_bind_missing_character",
                action: "media.voice.bind",
                message: "Select a character first."
            }
        }
        return root._bind_voice_row_to_character(row, targetId)
    }

    function _bind_voice_row_to_character(row, mediaId) {
        if (!root.managementMode)
            return { ok: false, blocked: true, code: "media_voice_picker_disabled" }
        var payload = null
        if (root.voiceServiceAdapter && typeof root.voiceServiceAdapter.bindMediaVoiceToCharacter === "function")
            payload = root.voiceServiceAdapter.bindMediaVoiceToCharacter(String(mediaId || ""), row || {})
        else
            payload = {
                ok: false,
                blocked: true,
                code: "media_voice_bind_controller_missing",
                action: "media.voice.bind",
                media_id: String(mediaId || ""),
                message: "Voice binding is unavailable in this host."
            }
        root.lastVoiceBindResult = payload || ({})
        if (payload && payload.ok) {
            root._load_voice_bound_characters(row || {})
            // Reload the grid so the bound character's card shows its voice
            // badge (the binding is written to ai_metadata.structure.flow_voice).
            root.requestRefresh(searchInput.text)
            return payload
        }
        if (String((payload || {}).message || "").length > 0)
            root.showFeedback((void i18n.revision, i18n.t("media_library.bind_voice_title", "Bind Voice")), String(payload.message))
        return payload
    }

    function _on_unbind_voice_from_character(mediaId) {
        if (!root.managementMode)
            return { ok: false, blocked: true, code: "media_voice_picker_disabled" }
        var targetId = String(mediaId || root.selectedVoiceBoundMediaId || "")
        var payload = null
        if (!targetId.length) {
            payload = {
                ok: false,
                blocked: true,
                code: "media_voice_unbind_missing_character",
                action: "media.voice.unbind",
                message: "Select a bound character first."
            }
            root.showFeedback((void i18n.revision, i18n.t("media_library.remove_voice_title", "Remove Voice")), payload.message)
            root.lastVoiceUnbindResult = payload
            return payload
        }
        if (root.voiceServiceAdapter && typeof root.voiceServiceAdapter.unbindMediaVoiceFromCharacter === "function")
            payload = root.voiceServiceAdapter.unbindMediaVoiceFromCharacter(targetId)
        else
            payload = {
                ok: false,
                blocked: true,
                code: "media_voice_unbind_controller_missing",
                action: "media.voice.unbind",
                media_id: targetId,
                message: "Voice removal is unavailable in this host."
            }
        root.lastVoiceUnbindResult = payload || ({})
        if (payload && payload.ok) {
            root._load_voice_bound_characters(root._selected_voice_row())
            // Reload the grid so the character's voice badge disappears.
            root.requestRefresh(searchInput.text)
            return payload
        }
        if (String((payload || {}).message || "").length > 0)
            root.showFeedback((void i18n.revision, i18n.t("media_library.remove_voice_title", "Remove Voice")), String(payload.message))
        return payload
    }

    function requestDeleteMedia(ids) {
        if (!root.managementMode)
            return
        var nextIds = [].concat(ids || []).filter(function(value) {
            return String(value || "").length > 0
        })
        if (nextIds.length === 0)
            return
        root.pendingDeleteIds = nextIds
        deleteConfirmDialog.open()
    }

    function requestRenameMedia() {
        if (!root.managementMode)
            return
        if (root.selectedMediaIds.length !== 1 || root.selectedMediaId.length === 0) {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.rename_failed", "Rename failed")),
                (void i18n.revision, i18n.t("media_library.rename_missing_selection", "Select exactly one media item before renaming it."))
            )
            return
        }
        root.pendingRenameMediaId = root.selectedMediaId
        root.pendingRenameMediaName = root.selectedName()
        renameInput.text = root.pendingRenameMediaName
        renameDialog.open()
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || "")
        root.feedbackMessage = String(message || "")
        feedbackDialog.open()
    }

    function applyDeleteResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            var failures = payload.failures || []
            var firstFailure = failures.length > 0 && failures[0] ? failures[0] : ({})
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.delete_failed", "Delete failed")),
                String(
                    payload.message
                    || firstFailure.message
                    || firstFailure.error
                    || payload.error
                    || (firstFailure.blocker && (firstFailure.blocker.message || firstFailure.blocker.code))
                    || (payload.blocker && (payload.blocker.message || payload.blocker.code))
                    || (void i18n.revision, i18n.t("media_library.delete_failed_generic", "Could not delete the selected media."))
                )
            )
            return false
        }
        return true
    }

    function applyImportResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.import_failed", "Import failed")),
                String(
                    payload.message
                    || (payload.errors && payload.errors.length > 0 ? payload.errors.join(", ") : "")
                    || payload.error
                    || (void i18n.revision, i18n.t("media_library.import_failed_generic", "Could not import the selected media paths."))
                )
            )
            return
        }

        pathsInput.text = ""
        tagsInput.text = ""
        assetTypeCombo.currentIndex = 0
        root.importPanelOpen = false
        root.showFeedback(
            (void i18n.revision, i18n.t("media_library.import_success", "Import complete")),
            String(
                payload.message
                || (void i18n.revision, i18n.t("media_library.import_success_message", "Imported %1 media item(s).")).arg(String(payload.imported || 0))
            )
        )
    }

    function applyOpenSourceResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.open_failed", "Open source failed")),
                String(
                    payload.message
                    || payload.error
                    || (payload.blocker && (payload.blocker.message || payload.blocker.code))
                    || (void i18n.revision, i18n.t("media_library.open_failed_generic", "Could not open the selected source path."))
                )
            )
            return false
        }
        return true
    }

    function applySelectionResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.select_failed", "Selection failed")),
                String(
                    payload.message
                    || payload.error
                    || (payload.blocker && (payload.blocker.message || payload.blocker.code))
                    || (void i18n.revision, i18n.t("media_library.select_failed_generic", "Could not use the selected media item."))
                )
            )
            return false
        }
        root.accept()
        return true
    }

    function applyRenameResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.rename_failed", "Rename failed")),
                String(
                    payload.message
                    || payload.error
                    || (payload.blocker && (payload.blocker.message || payload.blocker.code))
                    || (void i18n.revision, i18n.t("media_library.rename_failed_generic", "Could not rename the selected media item."))
                )
            )
            return false
        }
        root.selectedMediaId = String(payload.media_id || root.pendingRenameMediaId || root.selectedMediaId)
        root.selectedMediaIds = root.selectedMediaId.length > 0 ? [root.selectedMediaId] : []
        if (root.selectedMediaId.length > 0) {
            root.invalidatePreviewCache()
            root.requestSelectedPreview()
        }
        root.showFeedback(
            (void i18n.revision, i18n.t("media_library.rename_success", "Rename complete")),
            String(payload.message || (void i18n.revision, i18n.t("media_library.rename_success_message", "Media renamed successfully.")))
        )
        return true
    }

    function applyAssetTypeResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.asset_type_failed", "Asset type update failed")),
                String(
                    payload.message
                    || payload.error
                    || (payload.blocker && (payload.blocker.message || payload.blocker.code))
                    || (void i18n.revision, i18n.t("media_library.asset_type_failed_generic", "Could not update the selected media asset type."))
                )
            )
            return false
        }
        return true
    }

    function requestMediaTypeChange(media, assetType) {
        if (!root.managementMode)
            return
        var mediaId = String((media || {}).id || (media || {}).media_id || "")
        if (!mediaId.length)
            return
        if (typeof workPanelController === "undefined" || typeof workPanelController.updateMediaAssetType !== "function") {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.asset_type_failed", "Asset type update failed")),
                (void i18n.revision, i18n.t("media_library.asset_type_unavailable", "Asset type updates are not available in this screen."))
            )
            return
        }
        root.applyAssetTypeResult(workPanelController.updateMediaAssetType(mediaId, String(assetType || "")))
        root.invalidatePreviewCache()
        // Always reload so the grid reflects the canonical asset_type and
        // re-filters (the item may leave the current type tab). Previously this
        // only ran on failure, leaving the card showing a stale/local value.
        root.requestRefresh(searchInput.text)
    }

    function requestEditMedia(media) {
        if (!root.managementMode)
            return
        root.syncSingleSelection(media)
        root.requestLargePreview(media)
    }

    function requestLargePreview(media) {
        root.syncSingleSelection(media)
        root.requestSelectedPreview()
        if (root.selectedPreviewImageSource().length <= 0) {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.preview_failed", "Preview unavailable")),
                (void i18n.revision, i18n.t("media_library.preview_missing_image", "No local image preview is available for this media item."))
            )
            return
        }
        largePreviewDialog.open()
    }

    function commitDelete(ids) {
        if (!root.managementMode)
            return
        var nextIds = [].concat(ids || []).filter(function(value) {
            return String(value || "").length > 0
        })
        if (nextIds.length === 0) {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.delete_failed", "Delete failed")),
                (void i18n.revision, i18n.t("media_library.delete_missing_selection", "Choose at least one item to delete."))
            )
            return
        }
        if (typeof workPanelController === "undefined" || typeof workPanelController.deleteMedia !== "function") {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.delete_failed", "Delete failed")),
                (void i18n.revision, i18n.t("media_library.delete_unavailable", "Delete is not available in this screen."))
            )
            return
        }

        var result = null
        if (typeof workPanelController.deleteMediaItems === "function")
            result = workPanelController.deleteMediaItems(nextIds)
        else if (nextIds.length === 1)
            result = workPanelController.deleteMedia(String(nextIds[0]))
        else {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.delete_failed", "Delete failed")),
                (void i18n.revision, i18n.t("media_library.delete_batch_unavailable", "Batch delete is not available in this screen."))
            )
            return
        }

        if (!root.applyDeleteResult(result))
            return

        mediaGrid.clearSelection()
        root.selectedMediaIds = []
        root.selectedMediaId = ""
        root.showFeedback(
            (void i18n.revision, i18n.t("media_library.deleted", "Deleted")),
            root.formatCountText(
                (void i18n.revision, i18n.t("media_library.deleted_items", "Deleted {count} item(s).")),
                result.deleted || nextIds.length
            )
        )
    }

    function commitRename() {
        if (!root.managementMode)
            return
        var mediaId = String(root.pendingRenameMediaId || root.selectedMediaId || "")
        var newName = String(renameInput.text || "").trim()
        if (mediaId.length === 0) {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.rename_failed", "Rename failed")),
                (void i18n.revision, i18n.t("media_library.rename_missing_selection", "Select exactly one media item before renaming it."))
            )
            return
        }
        if (!newName.length) {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.rename_failed", "Rename failed")),
                (void i18n.revision, i18n.t("media_library.rename_missing_name", "Enter a media name before saving."))
            )
            renameInput.forceActiveFocus()
            return
        }
        if (typeof workPanelController === "undefined" || typeof workPanelController.renameMedia !== "function") {
            root.showFeedback(
                (void i18n.revision, i18n.t("media_library.rename_failed", "Rename failed")),
                (void i18n.revision, i18n.t("media_library.rename_unavailable", "Rename is not available in this screen."))
            )
            return
        }
        var result = workPanelController.renameMedia(mediaId, newName)
        if (!root.applyRenameResult(result))
            return
        renameDialog.close()
    }

    function previewSummary() {
        // Lấy trực tiếp từ grid item đã load (list_media) -> KHÔNG gọi backend mỗi
        // lần chọn. Tránh prepareMediaPreview đọc full-blob + base64 mỗi click.
        var item = root.selectedItem()
        var mid = String(item.id || item.media_id || "")
        if (mid.length === 0)
            return (void i18n.revision, i18n.t("media_library.preview_hint", "Select an item to preview, crop, open, or remove."))
        var title = String(item.name || item.file_name || mid)
        var ext = String(item.extension || item.mime_type || "metadata")
        var existsTxt = (item.source_missing && !item.exists)
            ? (void i18n.revision, i18n.t("media_library.source_missing_on_disk", "File đã bị xóa khỏi disk"))
            : (item.exists
                ? (void i18n.revision, i18n.t("media_library.preview_exists", "exists"))
                : (void i18n.revision, i18n.t("media_library.preview_missing", "missing")))
        return title + " | " + ext + " | " + existsTxt
    }

    function itemMediaType(item) {
        var mime = String(item.mime_type || "")
        var type = String(item.type || "")
        if (mime.indexOf("image/") === 0 || type === "image")
            return "image"
        if (mime.indexOf("video/") === 0 || type === "video")
            return "video"
        return type
    }

    function itemAssetType(item) {
        var meta = item.ai_metadata || ({})
        return String(item.asset_type || meta.asset_type || "")
    }

    function matchesFilter(item) {
        var allowed = root.allowedTypeList()
        if (!root.filterType.length) {
            if (allowed.length <= 0)
                return true
            var itemType = root.normalizedAssetType(root.itemAssetType(item))
            var itemTags = item.tags || []
            if (typeof itemTags === "string")
                itemTags = itemTags.split(",")
            if (allowed.indexOf(itemType) >= 0)
                return true
            for (var a = 0; a < allowed.length; a++) {
                for (var t = 0; t < itemTags.length; t++) {
                    if (root.normalizedAssetType(itemTags[t]) === allowed[a])
                        return true
                }
            }
            return false
        }
        if (root.filterType === "image" || root.filterType === "video")
            return root.itemMediaType(item) === root.filterType
        var tags = item.tags || []
        if (typeof tags === "string")
            tags = tags.split(",")
        var filter = root.normalizedAssetType(root.filterType)
        if (root.normalizedAssetType(root.itemAssetType(item)) === filter)
            return true
        for (var i = 0; i < tags.length; i++) {
            if (root.normalizedAssetType(tags[i]) === filter)
                    return true
        }
        return false
    }

    function syncSingleSelection(media) {
        var mediaId = String((media || {}).id || (media || {}).media_id || "")
        root.selectedMediaId = mediaId
        root.selectedMediaIds = mediaId.length > 0 ? [mediaId] : []
    }

    function doubleClickSelectionPayload(media) {
        if (root.maxSelection === 1) {
            root.syncSingleSelection(media)
            return root.selectionPayload()
        }

        var ids = [].concat(root.selectedMediaIds || [])
        var mediaId = String((media || {}).id || (media || {}).media_id || "")
        if (mediaId.length > 0 && ids.indexOf(mediaId) < 0) {
            if (root.maxSelection === 0 || ids.length < root.maxSelection) {
                ids.push(mediaId)
            } else if (root.maxSelection === 1) {
                ids = [mediaId]
            } else {
                ids.shift()
                ids.push(mediaId)
            }
        }

        root.selectedMediaIds = ids
        root.selectedMediaId = ids.length > 0 ? String(ids[0]) : ""
        return root.selectionPayload()
    }

    function filteredItems() {
        return root.filteredMediaItems || []
    }

    function rebuildFilteredItems() {
        var list = root.items || []
        if (!root.filterType.length && root.allowedTypeList().length <= 0) {
            root.filteredMediaItems = list
            return
        }
        var out = []
        for (var i = 0; i < list.length; i++) {
            if (root.matchesFilter(list[i]))
                out.push(list[i])
        }
        root.filteredMediaItems = out
    }

    function setFilterType(value) {
        var next = root.normalizedAssetType(value)
        if (!root.filterChipVisible(next))
            return
        root.filterType = next
    }

    function cleanDisplayText(text) {
        var value = String(text || "")
        var filtered = ""
        for (var i = 0; i < value.length; i++) {
            var code = value.charCodeAt(i)
            var ch = value.charAt(i)
            if (ch === "□" || ch === "�" || code === 0xfe0f || code === 0x200d
                    || (code >= 0x2300 && code <= 0x23ff)
                    || (code >= 0x2600 && code <= 0x27bf)
                    || (code >= 0x2b00 && code <= 0x2bff)
                    || (code >= 0xd800 && code <= 0xdfff))
                continue
            filtered += ch
        }
        return filtered.replace(/[ \t]+/g, " ").trim()
    }

    function statusText() {
        var data = root.stats || ({})
        var total = Number(data.total || (root.items || []).length || 0)
        var ready = Number(data.ready || 0)
        var analyzed = Number(data.analyzed || 0)
        var uploaded = Number(data.uploaded || 0)
        var selected = root.selectedMediaIds.length
        var text = (void i18n.revision, i18n.t("media_library_dialog.status_total", "Tổng: ")) + total
        if (selected > 0)
            text += (void i18n.revision, i18n.t("media_library_dialog.status_selected", " | Đã chọn: ")) + selected
        text += (void i18n.revision, i18n.t("media_library_dialog.status_ready", " | Sẵn sàng: ")) + ready + (void i18n.revision, i18n.t("media_library_dialog.status_analyzed", " | Đã phân tích: ")) + analyzed + (void i18n.revision, i18n.t("media_library_dialog.status_uploaded", " | Đã upload: ")) + uploaded
        return text
    }

    background: Rectangle {
        radius: VfTheme.radiusPanel
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    Timer {
        id: searchRefreshTimer

        interval: 350
        repeat: false
        onTriggered: {
            root.requestRefresh(searchInput.text)
            if (root.managementMode)
                root._load_voice_library(searchInput.text)
        }
    }

    contentItem: ColumnLayout {
        // anchors.fill makes this span the WHOLE dialog, including the header band (the
        // header is drawn on top), so the first row would sit behind the header and get
        // clipped. Push the top down past the header; keep 16dp insets on the other sides.
        anchors.fill: parent
        anchors.leftMargin: VfTheme.dp(16)
        anchors.rightMargin: VfTheme.dp(16)
        anchors.bottomMargin: VfTheme.dp(16)
        anchors.topMargin: (root.header ? root.header.height : 0) + VfTheme.dp(16)
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: toolbarRow.implicitHeight + VfTheme.dp(20)
            color: VfTheme.surfaceSoft
            border.width: 0

            // CONTROL block = actions only. Search pinned left; the ≤5 action buttons are pushed
            // to the right by a fillWidth spacer (natural order, no RTL). They sit DIRECTLY in the
            // RowLayout — NOT a nested Flow: a Flow with no Layout.fillWidth reports an unreliable
            // implicitWidth inside a Layout and spuriously wraps the last button even on a wide
            // window. R5 is suppressed on purpose: this row is bounded (a fixed search field + ≤5
            // fixed-width buttons in a ≥1300dp dialog can't overflow), so wrap-safety isn't needed.
            // Persistent settings (Auto AI / Auto Upload) are NOT here — see the STATUS strip below.
            RowLayout {  // perf-lint: disable=R5
                id: toolbarRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: VfTheme.dp(10)
                anchors.rightMargin: VfTheme.dp(10)
                spacing: VfTheme.dp(5)

                TextField {
                    id: searchInput
                    objectName: "mlSearchInput"
                    Layout.preferredWidth: VfTheme.dp(170)
                    Layout.preferredHeight: VfTheme.dp(28)
                    Layout.alignment: Qt.AlignVCenter
                    placeholderText: root.cleanDisplayText((void i18n.revision, i18n.t("media_library.search_placeholder", "Tìm kiếm...")))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    onTextChanged: searchRefreshTimer.restart()
                    onAccepted: {
                        searchRefreshTimer.stop()
                        root.requestRefresh(text)
                        if (root.managementMode)
                            root._load_voice_library(text)
                    }

                    background: Rectangle {
                        radius: VfTheme.radiusControl
                        color: VfTheme.surface
                        border.color: searchInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                    }
                }

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("media_library.select_all", "Tất cả"))
                    iconName: "check-box-with-check"
                    compact: true
                    minWidth: VfTheme.dp(74)
                    tone: "success"
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: mediaGrid.selectAll()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("media_library.deselect_all", "Bỏ chọn"))
                    iconName: "cross-mark"
                    compact: true
                    minWidth: VfTheme.dp(78)
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: mediaGrid.clearSelection()
                }

                VfButton {
                    objectName: "mlImportImages"
                    text: (void i18n.revision, i18n.t("media_library.import_images", "Nhập ảnh"))
                    iconName: "inbox-tray"
                    tone: "primary"
                    compact: true
                    minWidth: VfTheme.dp(72)
                    visible: root.managementMode
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: {
                        if (typeof nativeShell === "undefined") return
                        var picked = nativeShell.pickFiles(
                            (void i18n.revision, i18n.t("qml.media_library.browse_files", "Browse Files")),
                            "Images (*.png *.jpg *.jpeg *.webp *.gif);;All Files (*.*)",
                            ""
                        )
                        if (picked && picked.ok)
                            root.requestImport((picked.paths || []).join("\n"), "", "")
                    }
                }

                VfButton {
                    objectName: "mlImportFolder"
                    text: (void i18n.revision, i18n.t("media_library.import_folder", "Nhập thư mục ảnh"))
                    iconName: "open-folder"
                    tone: "primary"
                    compact: true
                    minWidth: VfTheme.dp(72)
                    visible: root.managementMode
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: {
                        if (typeof nativeShell === "undefined") return
                        var picked = nativeShell.pickFolder(
                            (void i18n.revision, i18n.t("qml.media_library.browse_folder", "Browse Folder")),
                            ""
                        )
                        if (picked && picked.ok)
                            root.requestImport(picked.path || "", "", "")
                    }
                }

                VfButton {
                    objectName: "mlDeleteSelected"
                    text: (void i18n.revision, i18n.t("common.delete", "Xóa"))
                    iconName: "cross-mark"
                    tone: "danger"
                    compact: true
                    minWidth: VfTheme.dp(48)
                    enabled: root.selectedMediaIds.length > 0
                    visible: root.managementMode
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: root.requestDeleteMedia(root.selectedMediaIds)
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.refresh", "Làm Mới"))
                    iconName: "clockwise-arrows"
                    compact: true
                    minWidth: VfTheme.dp(70)
                    visible: root.selectMode
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: root.requestRefresh(searchInput.text)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: chipFlow.implicitHeight + VfTheme.dp(14)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            Flow {
                id: chipFlow
                objectName: "mlFilterChips"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: VfTheme.dp(10)
                anchors.rightMargin: VfTheme.dp(10)
                anchors.topMargin: VfTheme.dp(7)
                spacing: VfTheme.dp(5)

                FilterChip { label: (void i18n.revision, i18n.t("common.all", "Tất cả")); value: ""; iconName: "framed-picture"; accent: "#2563EB" }
                FilterChip { label: (void i18n.revision, i18n.t("media_library.videos", "Video")); value: "video"; iconName: "video-camera"; accent: "#2563EB" }
                FilterChip { label: (void i18n.revision, i18n.t("media_library.character", "Nhân vật")); value: "character"; iconName: "busts-in-silhouette"; accent: "#8B5CF6" }
                FilterChip { label: (void i18n.revision, i18n.t("media_library.voice", "Voice")); value: "voice"; iconName: "studio-microphone"; accent: "#DB2777" }
                FilterChip { label: (void i18n.revision, i18n.t("media_library.object", "Object")); value: "object"; iconName: "package"; accent: "#F59E0B" }
                FilterChip { label: (void i18n.revision, i18n.t("media_library.setting", "Setting")); value: "setting"; iconName: "gear"; accent: "#10B981" }
                FilterChip { label: (void i18n.revision, i18n.t("media_library.background", "Background")); value: "background"; iconName: "framed-picture"; accent: "#0EA5E9" }
                FilterChip { label: (void i18n.revision, i18n.t("media_library.product", "Sản phẩm")); value: "product"; iconName: "shopping-bags"; accent: "#EF4444" }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 0
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: root.filterType === "voice" && root.managementMode
                Layout.preferredHeight: root.filterType === "voice" && root.managementMode ? -1 : 0
                visible: root.filterType === "voice" && root.managementMode
                radius: VfTheme.radiusPanel
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    spacing: VfTheme.dp(10)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)

                        TextField {
                            id: voiceSearchInputNew
                            objectName: "mlVoiceSearch"
                            Layout.preferredWidth: VfTheme.dp(360)
                            Layout.preferredHeight: VfTheme.dp(34)
                            text: root.voiceSearchText
                            placeholderText: (void i18n.revision, i18n.t("media_library.voice_search", "Tìm voice..."))
                            color: VfTheme.text
                            placeholderTextColor: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                            onAccepted: root._load_voice_library(text)
                            background: Rectangle {
                                radius: VfTheme.radiusControl
                                color: VfTheme.surface
                                border.color: voiceSearchInputNew.activeFocus ? VfTheme.primary : VfTheme.borderBox
                            }
                        }

                        VfButton {
                            text: (void i18n.revision, i18n.t("common.refresh", "Làm mới"))
                            minWidth: VfTheme.dp(92)
                            onClicked: root._load_voice_library(voiceSearchInputNew.text)
                        }

                        VfButton {
                            objectName: "mlVoiceCreate"
                            text: (void i18n.revision, i18n.t("media_library.create_voice", "Tạo Voice"))
                            tone: "primary"
                            minWidth: VfTheme.dp(110)
                            onClicked: root._on_create_voice()
                        }

                        VfButton {
                            objectName: "mlVoicePreview"
                            text: (void i18n.revision, i18n.t("media_library.voice_preview", "Nghe thử"))
                            minWidth: VfTheme.dp(96)
                            enabled: root.selectedVoiceId.length > 0
                            onClicked: root._on_preview_voice()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: (void i18n.revision, i18n.t("media_library.voice_tab_hint", "Chọn voice + character để bind, theo dõi entityId theo account."))
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideRight
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: VfTheme.dp(10)

                        Rectangle {
                            Layout.preferredWidth: VfTheme.dp(350)
                            Layout.fillHeight: true
                            radius: VfTheme.radiusPanel
                            color: VfTheme.surface
                            border.color: VfTheme.borderBox
                            clip: true

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(10)
                                spacing: VfTheme.dp(8)

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: VfTheme.dp(6)
                                    VfAppIcon { name: "studio-microphone"; size: VfTheme.dp(18); color: "#DB2777"; framed: false }
                                    Text {
                                        Layout.fillWidth: true
                                        text: (void i18n.revision, i18n.t("media_library.voice_library", "Thư viện voice"))
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(14)
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        text: String(root.voiceRows.length)
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: VfTheme.dp(10)
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.border
                                    clip: true

                                    GridView {
                                        id: voiceCardGrid
                                        objectName: "mlVoiceGrid"
                                        anchors.fill: parent
                                        anchors.margins: VfTheme.dp(8)
                                        clip: true
                                        reuseItems: true
                                        model: root.voiceRows
                                        readonly property int columnCount: Math.max(1, Math.floor(Math.max(1, width) / VfTheme.dp(190)))
                                        cellWidth: Math.max(VfTheme.dp(178), Math.floor(Math.max(1, width) / columnCount))
                                        cellHeight: VfTheme.dp(112)
                                        boundsBehavior: Flickable.StopAtBounds
                                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                                        delegate: Rectangle {
                                            width: voiceCardGrid.cellWidth - VfTheme.dp(8)
                                            height: voiceCardGrid.cellHeight - VfTheme.dp(8)
                                            radius: VfTheme.dp(10)
                                            readonly property bool rowSelected: root.voiceRowId(modelData) === root.selectedVoiceId
                                            color: rowSelected ? VfTheme.violetFill : (voiceCardHover.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface)
                                            border.color: rowSelected ? VfTheme.primary : VfTheme.blueFill
                                            border.width: rowSelected ? 2 : 1

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: VfTheme.dp(8)
                                                spacing: VfTheme.dp(5)
                                                z: 1

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: VfTheme.dp(5)

                                                    Rectangle {
                                                        Layout.preferredWidth: VfTheme.dp(26)
                                                        Layout.preferredHeight: VfTheme.dp(26)
                                                        radius: VfTheme.dp(13)
                                                        color: String((modelData || {}).kind || "") === "base" ? VfTheme.blueFill : VfTheme.pinkFill
                                                        VfAppIcon {
                                                            anchors.centerIn: parent
                                                            name: String((modelData || {}).kind || "") === "base" ? "studio-microphone" : "sparkles"
                                                            size: VfTheme.dp(15)
                                                            color: String((modelData || {}).kind || "") === "base" ? "#2563EB" : "#DB2777"
                                                            framed: false
                                                        }
                                                    }

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: root.voiceRowName(modelData)
                                                        color: VfTheme.text
                                                        font.family: VfTheme.fontFamily
                                                        font.pixelSize: VfTheme.fontSmall
                                                        font.weight: Font.DemiBold
                                                        elide: Text.ElideRight
                                                    }
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: String((modelData || {}).base_voice || (modelData || {}).speaker || (modelData || {}).kind || "")
                                                    color: VfTheme.textSubtle
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.fontTiny
                                                    elide: Text.ElideRight
                                                }

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: VfTheme.dp(24)
                                                    spacing: VfTheme.dp(6)

                                                    Rectangle {
                                                        Layout.preferredWidth: VfTheme.dp(64)
                                                        Layout.preferredHeight: VfTheme.dp(20)
                                                        radius: VfTheme.dp(10)
                                                        color: rowSelected ? "#2563EB" : VfTheme.cyanFill
                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: String((modelData || {}).kind || "voice")
                                                            color: rowSelected ? "#FFFFFF" : VfTheme.cyanText
                                                            font.family: VfTheme.fontFamily
                                                            font.pixelSize: VfTheme.fontTiny
                                                            font.weight: Font.DemiBold
                                                        }
                                                    }

                                                    Item { Layout.fillWidth: true }

                                                    Rectangle {
                                                        Layout.preferredWidth: VfTheme.dp(76)
                                                        Layout.preferredHeight: VfTheme.dp(22)
                                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                                        radius: VfTheme.dp(11)
                                                        color: voicePreviewHover.containsMouse ? VfTheme.blueFill : VfTheme.blueFill
                                                        border.color: VfTheme.blueBorderSoft
                                                        visible: root.voicePreviewAvailable(modelData || ({}))

                                                        Row {
                                                            anchors.centerIn: parent
                                                            spacing: VfTheme.dp(4)
                                                            VfAppIcon {
                                                                anchors.verticalCenter: parent.verticalCenter
                                                                name: "play"
                                                                size: VfTheme.dp(12)
                                                                color: "#2563EB"
                                                                framed: false
                                                            }
                                                            Text {
                                                                anchors.verticalCenter: parent.verticalCenter
                                                                text: (void i18n.revision, i18n.t("media_library.preview_short", "Nghe"))
                                                                color: VfTheme.blueText
                                                                font.family: VfTheme.fontFamily
                                                                font.pixelSize: VfTheme.fontTiny
                                                                font.weight: Font.DemiBold
                                                            }
                                                        }

                                                        MouseArea {
                                                            id: voicePreviewHover
                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            cursorShape: Qt.PointingHandCursor
                                                            onClicked: root._preview_voice_row(modelData || ({}))
                                                        }
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                id: voiceCardHover
                                                anchors.fill: parent
                                                z: 0
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root._on_voice_selection_changed(modelData)
                                            }
                                        }
                                    }

                                    Label {
                                        anchors.centerIn: parent
                                        visible: root.voiceRows.length === 0
                                        text: (void i18n.revision, i18n.t("media_library.no_voices", "Chưa có voice."))
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: VfTheme.radiusPanel
                            color: VfTheme.surface
                            border.color: VfTheme.borderBox
                            clip: true

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(10)
                                spacing: VfTheme.dp(8)

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: VfTheme.dp(6)
                                    VfAppIcon { name: "busts-in-silhouette"; size: VfTheme.dp(18); color: "#7C3AED"; framed: false }
                                    Text {
                                        Layout.fillWidth: true
                                        text: (void i18n.revision, i18n.t("media_library.character_grid", "Character"))
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(14)
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        text: String(root.voiceCharacterRows.length)
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: VfTheme.dp(10)
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.border
                                    clip: true

                                    GridView {
                                        id: voiceCharacterCardGrid
                                        objectName: "mlVoiceCharGrid"
                                        anchors.fill: parent
                                        anchors.margins: VfTheme.dp(8)
                                        clip: true
                                        reuseItems: true
                                        model: root.voiceCharacterRows
                                        readonly property int columnCount: Math.max(1, Math.floor(Math.max(1, width) / VfTheme.dp(170)))
                                        cellWidth: Math.max(VfTheme.dp(156), Math.floor(Math.max(1, width) / columnCount))
                                        cellHeight: VfTheme.dp(202)
                                        boundsBehavior: Flickable.StopAtBounds
                                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                                        delegate: Rectangle {
                                            width: voiceCharacterCardGrid.cellWidth - VfTheme.dp(8)
                                            height: voiceCharacterCardGrid.cellHeight - VfTheme.dp(8)
                                            radius: VfTheme.dp(10)
                                            readonly property string cardMediaId: String((modelData || {}).id || (modelData || {}).media_id || "")
                                            readonly property bool cardSelected: cardMediaId === root.selectedMediaId
                                            readonly property string cardThumbSource: root.thumbSource(modelData || ({}))
                                            color: cardSelected ? VfTheme.violetFill : (characterCardHover.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface)
                                            border.color: cardSelected ? "#7C3AED" : VfTheme.blueFill
                                            border.width: cardSelected ? 2 : 1

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: VfTheme.dp(8)
                                                spacing: VfTheme.dp(6)

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: VfTheme.dp(106)
                                                    radius: VfTheme.dp(8)
                                                    color: VfTheme.violetFill
                                                    clip: true

                                                    Image {
                                                        id: characterThumbImage
                                                        anchors.fill: parent
                                                        anchors.margins: VfTheme.dp(3)
                                                        source: cardThumbSource
                                                        fillMode: Image.PreserveAspectFit
                                                        asynchronous: true
                                                        cache: true
                                                        sourceSize.width: 360
                                                        sourceSize.height: 260
                                                        visible: cardThumbSource.length > 0 && status !== Image.Error
                                                    }

                                                    VfAppIcon {
                                                        anchors.centerIn: parent
                                                        name: "busts-in-silhouette"
                                                        size: VfTheme.dp(30)
                                                        color: "#7C3AED"
                                                        framed: false
                                                        visible: cardThumbSource.length === 0 || characterThumbImage.status === Image.Error
                                                    }
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: String((modelData || {}).name || (modelData || {}).title || cardMediaId)
                                                    color: VfTheme.text
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.fontSmall
                                                    font.weight: Font.DemiBold
                                                    elide: Text.ElideRight
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: root.boundVoiceLabelForMedia(modelData || ({})).length > 0
                                                        ? ((void i18n.revision, i18n.t("media_library.bound_voice_prefix", "Voice: ")) + root.boundVoiceLabelForMedia(modelData || ({})))
                                                        : (void i18n.revision, i18n.t("media_library.unbound_voice", "Chưa bind voice"))
                                                    color: root.boundVoiceLabelForMedia(modelData || ({})).length > 0 ? "#059669" : VfTheme.textSubtle
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.fontTiny
                                                    elide: Text.ElideRight
                                                }

                                                Rectangle {
                                                    Layout.preferredWidth: VfTheme.dp(88)
                                                    Layout.preferredHeight: VfTheme.dp(22)
                                                    radius: VfTheme.dp(11)
                                                    color: cardSelected ? "#7C3AED" : VfTheme.greenFill
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: cardSelected
                                                            ? (void i18n.revision, i18n.t("common.selected", "Đã chọn"))
                                                            : (void i18n.revision, i18n.t("media_library.pick_character", "Chọn"))
                                                        color: cardSelected ? "#FFFFFF" : VfTheme.greenText
                                                        font.family: VfTheme.fontFamily
                                                        font.pixelSize: VfTheme.fontTiny
                                                        font.weight: Font.DemiBold
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                id: characterCardHover
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.selectedMediaId = cardMediaId
                                            }
                                        }
                                    }

                                    Label {
                                        anchors.centerIn: parent
                                        visible: root.voiceCharacterRows.length === 0
                                        text: (void i18n.revision, i18n.t("media_library.no_characters", "Chưa có character."))
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: VfTheme.dp(410)
                            Layout.fillHeight: true
                            radius: VfTheme.radiusPanel
                            color: VfTheme.surface
                            border.color: VfTheme.borderBox
                            clip: true

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(10)
                                spacing: VfTheme.dp(8)

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: VfTheme.dp(6)
                                    VfAppIcon { name: "link"; size: VfTheme.dp(18); color: "#2563EB"; framed: false }
                                    Text {
                                        Layout.fillWidth: true
                                        text: (void i18n.revision, i18n.t("media_library.voice_binding", "Voice binding"))
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(14)
                                        font.weight: Font.DemiBold
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: VfTheme.dp(112)
                                    radius: VfTheme.dp(10)
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.blueFill

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: VfTheme.dp(10)
                                        spacing: VfTheme.dp(6)

                                        Text {
                                            Layout.fillWidth: true
                                            text: (void i18n.revision, i18n.t("media_library.selected_pair", "Cặp đang chọn"))
                                            color: VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontSmall
                                            font.weight: Font.DemiBold
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: (void i18n.revision, i18n.t("media_library.voice_label", "Voice")) + ": " + (root.selectedVoiceId.length > 0 ? root.voiceRowName(root._selected_voice_row()) : (void i18n.revision, i18n.t("common.none", "Chưa chọn")))
                                            color: VfTheme.textSubtle
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontTiny
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: (void i18n.revision, i18n.t("media_library.character_label", "Character")) + ": " + (root.selectedMediaId.length > 0 ? root.selectedName() : (void i18n.revision, i18n.t("common.none", "Chưa chọn")))
                                            color: VfTheme.textSubtle
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontTiny
                                            elide: Text.ElideRight
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: VfTheme.dp(6)

                                            VfButton {
                                                objectName: "mlVoiceBind"
                                                Layout.fillWidth: true
                                                text: (void i18n.revision, i18n.t("media_library.bind_voice", "Bind voice"))
                                                tone: "primary"
                                                enabled: root.selectedVoiceId.length > 0 && root.selectedMediaId.length > 0
                                                onClicked: root._on_bind_voice_to_character(root.selectedMediaId)
                                            }

                                            VfButton {
                                                objectName: "mlVoiceUnbind"
                                                Layout.fillWidth: true
                                                text: (void i18n.revision, i18n.t("media_library.unbind_voice", "Gỡ bind"))
                                                tone: "danger"
                                                enabled: root.selectedVoiceBoundMediaId.length > 0
                                                onClicked: root._on_unbind_voice_from_character(root.selectedVoiceBoundMediaId)
                                            }
                                        }
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: (void i18n.revision, i18n.t("media_library.bound_characters", "Character đã bind với voice đang chọn"))
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    font.weight: Font.DemiBold
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: VfTheme.dp(10)
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.border
                                    clip: true

                                    ListView {
                                        id: boundVoiceCardList
                                        anchors.fill: parent
                                        anchors.margins: VfTheme.dp(8)
                                        clip: true
                                        reuseItems: true
                                        spacing: VfTheme.dp(8)
                                        model: root.voiceBoundRows
                                        boundsBehavior: Flickable.StopAtBounds
                                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                                        delegate: Rectangle {
                                            width: boundVoiceCardList.width - VfTheme.dp(2)
                                            height: VfTheme.dp(94)
                                            radius: VfTheme.dp(10)
                                            readonly property bool boundSelected: String((modelData || {}).media_id || "") === root.selectedVoiceBoundMediaId
                                            readonly property string boundThumbSource: root.thumbSource(modelData || ({}))
                                            color: boundSelected ? VfTheme.blueFill : (boundCardHover.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface)
                                            border.color: boundSelected ? "#2563EB" : VfTheme.blueFill
                                            border.width: boundSelected ? 2 : 1

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: VfTheme.dp(8)
                                                spacing: VfTheme.dp(8)

                                                Rectangle {
                                                    Layout.preferredWidth: VfTheme.dp(78)
                                                    Layout.fillHeight: true
                                                    radius: VfTheme.dp(8)
                                                    color: VfTheme.violetFill
                                                    clip: true

                                                    Image {
                                                        id: boundCharacterThumbImage
                                                        anchors.fill: parent
                                                        anchors.margins: VfTheme.dp(3)
                                                        source: boundThumbSource
                                                        fillMode: Image.PreserveAspectFit
                                                        asynchronous: true
                                                        cache: true
                                                        sourceSize.width: 180
                                                        sourceSize.height: 160
                                                        visible: boundThumbSource.length > 0 && status !== Image.Error
                                                    }

                                                    VfAppIcon {
                                                        anchors.centerIn: parent
                                                        name: "busts-in-silhouette"
                                                        size: VfTheme.dp(26)
                                                        color: "#7C3AED"
                                                        framed: false
                                                        visible: boundThumbSource.length === 0 || boundCharacterThumbImage.status === Image.Error
                                                    }
                                                }

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    spacing: VfTheme.dp(4)

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: String((modelData || {}).character_name || (modelData || {}).media_id || "")
                                                        color: VfTheme.text
                                                        font.family: VfTheme.fontFamily
                                                        font.pixelSize: VfTheme.fontSmall
                                                        font.weight: Font.DemiBold
                                                        elide: Text.ElideRight
                                                    }

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: String((modelData || {}).base_voice || "")
                                                        color: VfTheme.textSubtle
                                                        font.family: VfTheme.fontFamily
                                                        font.pixelSize: VfTheme.fontTiny
                                                        elide: Text.ElideRight
                                                    }

                                                    Rectangle {
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: VfTheme.dp(22)
                                                        radius: VfTheme.dp(11)
                                                        color: Qt.rgba(37 / 255, 99 / 255, 235 / 255, 0.08)
                                                        border.color: Qt.rgba(37 / 255, 99 / 255, 235 / 255, 0.18)
                                                        Text {
                                                            anchors.centerIn: parent
                                                            width: parent.width - VfTheme.dp(14)
                                                            text: root.bindingStatusText(modelData || ({}))
                                                            color: root.bindingStatusColor(modelData || ({}))
                                                            font.family: VfTheme.fontFamily
                                                            font.pixelSize: VfTheme.fontTiny
                                                            font.weight: Font.DemiBold
                                                            elide: Text.ElideRight
                                                            horizontalAlignment: Text.AlignHCenter
                                                        }
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                id: boundCardHover
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.selectedVoiceBoundMediaId = String((modelData || {}).media_id || "")
                                            }
                                        }
                                    }

                                    Label {
                                        anchors.centerIn: parent
                                        visible: root.voiceBoundRows.length === 0
                                        text: (void i18n.revision, i18n.t("media_library.no_bound_characters", "Voice này chưa bind character nào."))
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.preferredHeight: 0
                visible: false
                radius: VfTheme.radiusPanel
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    spacing: VfTheme.dp(10)

                    ColumnLayout {
                        Layout.preferredWidth: VfTheme.dp(270)
                        Layout.fillHeight: true
                        spacing: VfTheme.dp(6)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(6)

                            TextField {
                                id: voiceSearchInput
                                Layout.fillWidth: true
                                text: root.voiceSearchText
                                placeholderText: "Search voices"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontControl
                                onAccepted: root._load_voice_library(text)
                                background: Rectangle {
                                    radius: VfTheme.radiusControl
                                    color: VfTheme.surface
                                    border.color: voiceSearchInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                                }
                            }

                            VfButton {
                                text: (void i18n.revision, i18n.t("common.refresh", "Refresh"))
                                minWidth: VfTheme.dp(80)
                                onClicked: root._load_voice_library(voiceSearchInput.text)
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(6)

                            VfButton {
                                Layout.fillWidth: true
                                text: "Create Voice"
                                tone: "primary"
                                onClicked: root._on_create_voice()
                            }

                            VfButton {
                                Layout.fillWidth: true
                                text: "Preview"
                                enabled: root.selectedVoiceId.length > 0
                                onClicked: root._on_preview_voice()
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: VfTheme.radiusControl
                            color: VfTheme.surface
                            border.color: VfTheme.borderBox
                            clip: true

                            // ListView (not ScrollView+ColumnLayout+Repeater): the
                            // latter left delegates at zero width in Qt6 → the row
                            // MouseArea had no hit area, so clicking a voice did
                            // nothing. ListView gives each delegate a definite
                            // width (ListView.view.width) so clicks register.
                            ListView {
                                id: voiceListView
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(6)
                                clip: true
                                reuseItems: true
                                spacing: VfTheme.dp(4)
                                model: root.voiceRows
                                boundsBehavior: Flickable.StopAtBounds
                                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                                delegate: Rectangle {
                                    width: ListView.view ? ListView.view.width : 0
                                    height: VfTheme.dp(34)
                                    radius: VfTheme.dp(8)
                                    readonly property bool rowSelected: root.voiceRowId(modelData) === root.selectedVoiceId
                                    color: rowSelected ? VfTheme.blueFill : (voiceRowHover.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface)
                                    border.color: rowSelected ? VfTheme.primary : VfTheme.borderSoft

                                    Text {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.leftMargin: VfTheme.dp(10)
                                        anchors.rightMargin: VfTheme.dp(10)
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: root.voiceRowName(modelData)
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        elide: Text.ElideRight
                                    }

                                    MouseArea {
                                        id: voiceRowHover
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root._on_voice_selection_changed(modelData)
                                    }
                                }
                            }

                            Label {
                                anchors.centerIn: parent
                                visible: root.voiceRows.length === 0
                                text: (void i18n.revision, i18n.t("media_library.no_voices", "No voices found."))
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        readOnly: true
                        wrapMode: TextArea.Wrap
                        text: root.voiceDetailText
                        placeholderText: (void i18n.revision, i18n.t("media_library.voice_detail_placeholder", "Chọn một voice để xem chi tiết"))
                        // Without an explicit color the read-only TextArea rendered
                        // near-white on white and was unreadable.
                        color: VfTheme.text
                        placeholderTextColor: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        padding: VfTheme.dp(8)
                        background: Rectangle {
                            radius: VfTheme.radiusControl
                            color: VfTheme.surface
                            border.color: VfTheme.borderBox
                        }
                    }

                    ColumnLayout {
                        Layout.preferredWidth: VfTheme.dp(300)
                        Layout.fillHeight: true
                        spacing: VfTheme.dp(6)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(6)

                            VfButton {
                                Layout.fillWidth: true
                                text: "Bind Current Media"
                                enabled: root.selectedVoiceId.length > 0 && root.selectedMediaId.length > 0
                                onClicked: root._on_bind_voice_to_character(root.selectedMediaId)
                            }

                            VfButton {
                                Layout.fillWidth: true
                                text: "Unbind"
                                tone: "danger"
                                enabled: root.selectedVoiceBoundMediaId.length > 0
                                onClicked: root._on_unbind_voice_from_character(root.selectedVoiceBoundMediaId)
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: VfTheme.radiusControl
                            color: VfTheme.surface
                            border.color: VfTheme.borderBox
                            clip: true

                            ListView {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(6)
                                clip: true
                                reuseItems: true
                                spacing: VfTheme.dp(4)
                                model: root.voiceBoundRows
                                boundsBehavior: Flickable.StopAtBounds
                                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                                delegate: Rectangle {
                                    width: ListView.view ? ListView.view.width : 0
                                    height: VfTheme.dp(34)
                                    radius: VfTheme.dp(8)
                                    readonly property bool boundSelected: String((modelData || {}).media_id || "") === root.selectedVoiceBoundMediaId
                                    color: boundSelected ? VfTheme.amberFill : (boundHover.containsMouse ? VfTheme.amberFill : VfTheme.surface)
                                    border.color: boundSelected ? "#F59E0B" : VfTheme.borderSoft

                                    Text {
                                        id: boundName
                                        anchors.left: parent.left
                                        anchors.leftMargin: VfTheme.dp(8)
                                        anchors.right: boundBase.left
                                        anchors.rightMargin: VfTheme.dp(6)
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: String((modelData || {}).character_name || (modelData || {}).media_id || "")
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        id: boundBase
                                        anchors.right: parent.right
                                        anchors.rightMargin: VfTheme.dp(8)
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: String((modelData || {}).base_voice || "")
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                    }

                                    MouseArea {
                                        id: boundHover
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.selectedVoiceBoundMediaId = String((modelData || {}).media_id || "")
                                    }
                                }
                            }

                            Label {
                                anchors.centerIn: parent
                                visible: root.voiceBoundRows.length === 0
                                text: (void i18n.revision, i18n.t("media_library.no_bound_characters", "No characters bound to this voice."))
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                            }
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                property string _msg: root.controllerStatusMessage()
                visible: root.selectMode && _msg.length > 0 && _msg !== "Ready"
                text: _msg
                color: _msg.indexOf("Blocked") === 0 ? VfTheme.redBorder : VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.managementMode && root.importPanelOpen ? 104 : 0
                visible: root.managementMode && root.importPanelOpen
                radius: VfTheme.radiusPanel
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderBox

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    spacing: VfTheme.dp(6)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)

                        TextField {
                            id: tagsInput

                            Layout.preferredWidth: VfTheme.dp(200)
                            Layout.preferredHeight: VfTheme.dp(28)
                            placeholderText: (void i18n.revision, i18n.t("media_library.tags", "Tags, comma separated"))
                            color: VfTheme.text
                            placeholderTextColor: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                            background: Rectangle {
                                color: VfTheme.surface
                                border.color: VfTheme.borderBox
                                border.width: 1
                                radius: VfTheme.radiusControl
                            }
                        }

                        NoScrollComboBox {
                            id: assetTypeCombo

                            Layout.preferredWidth: VfTheme.dp(164)
                            Layout.preferredHeight: VfTheme.dp(28)
                            model: [
                                { label: (void i18n.revision, i18n.t("common.auto", "Auto")), value: "" },
                                { label: "Character", value: "character" },
                                { label: "Object", value: "object" },
                                { label: "Setting", value: "setting" },
                                { label: "Background", value: "background" },
                                { label: "Product", value: "product" }
                            ]
                            textRole: "label"
                            valueRole: "value"
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                        }

                        Item { Layout.fillWidth: true }

                        VfButton {
                            text: (void i18n.revision, i18n.t("qml.media_library.browse_files", "Browse Files"))
                            compact: true
                            minWidth: VfTheme.dp(92)
                            onClicked: root.requestNativeMediaPicker("files")
                        }

                        VfButton {
                            text: (void i18n.revision, i18n.t("qml.media_library.browse_folder", "Browse Folder"))
                            compact: true
                            minWidth: VfTheme.dp(102)
                            onClicked: root.requestNativeMediaPicker("folder")
                        }

                        VfButton {
                            text: (void i18n.revision, i18n.t("media_library.import", "Import"))
                            tone: "primary"
                            compact: true
                            onClicked: root.requestImport(pathsInput.text, tagsInput.text, assetTypeCombo.currentValue)
                        }
                    }

                    TextArea {
                        id: pathsInput

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        placeholderText: (void i18n.revision, i18n.t("qml.media_library.path_hint", "Paste one image file or folder path per line, or separate paths with semicolons."))
                        wrapMode: TextArea.WrapAnywhere
                        color: VfTheme.text
                        placeholderTextColor: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        background: Rectangle {
                            color: VfTheme.surface
                            border.color: VfTheme.borderBox
                            border.width: 1
                            radius: VfTheme.radiusControl
                        }
                    }
                }
            }

            MediaGridWidget {
                id: mediaGrid
                objectName: "mlGrid"
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.filterType !== "voice"
                filterType: root.filterType
                managementMode: root.managementMode
                items: root.filteredItems()
                selectedId: root.selectedMediaId
                selectedIds: root.selectedMediaIds
                maxSelection: root.maxSelection
                onSelectionChanged: ids => {
                    root.selectedMediaIds = ids || []
                    root.selectedMediaId = root.selectedMediaIds.length > 0 ? String(root.selectedMediaIds[0]) : ""
                    // Không gọi prepareMediaPreview ở đây nữa: summary + ảnh preview
                    // đều lấy từ grid item đã load. Crop/Large-preview tự fetch khi cần.
                }
                onMediaSelected: media => {
                    root.selectedMediaId = String(media.id || media.media_id || "")
                    root.selectedMediaIds = mediaGrid.currentSelectedIds()
                }
                onMediaDoubleClicked: media => {
                    root.doubleClickSelectionPayload(media)
                    root.confirmSelection()
                }
                onMediaEditRequested: media => {
                    root.requestEditMedia(media)
                }
                onMediaRenameRequested: media => {
                    root.syncSingleSelection(media)
                    root.requestRenameMedia()
                }
                onMediaTypeChanged: (media, assetType) => {
                    root.requestMediaTypeChange(media, assetType)
                }
                onMediaPreviewRequested: media => {
                    root.requestLargePreview(media)
                }
                onMediaOpenRequested: media => {
                    root.syncSingleSelection(media)
                    root.openSelectedSource()
                }
                onMediaRemoveRequested: media => {
                    root.syncSingleSelection(media)
                    root.requestDeleteMedia([root.selectedMediaId])
                }
            }

            Text {
                Layout.fillWidth: true
                visible: false
                text: (void i18n.revision, i18n.t("qml.media_library.empty", "No media items found."))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(24)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            // STATUS block: media counters only. Auto analysis + auto upload are always ON
            // now (their on/off toggles were removed), so there is nothing to configure here.
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(16)
                anchors.rightMargin: VfTheme.dp(16)

                Text {
                    Layout.fillWidth: true
                    text: root.statusText()
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    elide: Text.ElideRight
                }
            }
        }
    }

    footer: Rectangle {
        visible: root.selectMode
        height: root.selectMode ? VfTheme.dp(56) : 0
        color: VfTheme.surface
        radius: VfTheme.dp(12)
        Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; height: 1; color: VfTheme.border }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: VfTheme.dp(16)
            anchors.verticalCenter: parent.verticalCenter
            spacing: VfTheme.dp(8)

            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Hủy"))
                minWidth: VfTheme.dp(88)
                onClicked: root.reject()
            }
            VfButton {
                text: (void i18n.revision, i18n.t("media_library.ok_btn", "Xác nhận"))
                tone: "accent"
                minWidth: VfTheme.dp(120)
                enabled: root.hasValidSelection()
                onClicked: root.confirmSelection()
            }
        }
    }

    Dialog {
        id: largePreviewDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(920), VfTheme.dp(80))
        height: VfDialogMetrics.height(parent, VfTheme.dp(720), VfTheme.dp(80))
        padding: 0
        title: ""
        header: VfDialogHeader {
            title: root.selectedName()
            iconName: "framed-picture"
            compact: true
            onCloseClicked: largePreviewDialog.close()
        }
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: VfTheme.dp(14)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: VfTheme.dp(14)
                radius: VfTheme.dp(10)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border
                clip: true

                Image {
                    id: largePreviewImage
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    source: root.selectedPreviewImageSource()
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: true
                    visible: source.toString().length > 0 && status !== Image.Error
                }

                Column {
                    anchors.centerIn: parent
                    spacing: VfTheme.dp(8)
                    visible: largePreviewImage.source.toString().length === 0 || largePreviewImage.status === Image.Error

                    VfAppIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: "framed-picture"
                        size: VfTheme.dp(38)
                        framed: false
                        color: VfTheme.textSubtle
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: (void i18n.revision, i18n.t("media_library.preview_missing_image", "No local image preview is available for this media item."))
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(58)
                color: VfTheme.surface
                border.color: VfTheme.border

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(16)
                    anchors.rightMargin: VfTheme.dp(16)
                    spacing: VfTheme.dp(10)

                    Text {
                        Layout.fillWidth: true
                        text: root.selectedSourcePath()
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        elide: Text.ElideMiddle
                    }

                    VfButton {
                        text: (void i18n.revision, i18n.t("common.close", "Close"))
                        iconName: "cross-mark"
                        minWidth: VfTheme.dp(96)
                        onClicked: largePreviewDialog.close()
                    }
                }
            }
        }
    }

    ProfessionalImageCropperDialog {
        id: cropperDialog
        onSourceRequested: root.openSelectedSource()
        onCropRequested: payload => root.requestCropPlan(payload)
    }

    Dialog {
        id: cropSelectionWarningDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(360), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("common.warning", "Warning"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("media_library.select_one_to_crop", "Select exactly one item to crop."))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: cropSelectionWarningDialog.close()
                }
            }
        }
    }

    Dialog {
        id: voiceCreateDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(400), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Text {
                text: (void i18n.revision, i18n.t("media_library.create_voice", "Tạo Voice mới"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(16)
                font.weight: Font.DemiBold
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(4)

                Text {
                    text: (void i18n.revision, i18n.t("media_library.voice_name", "Tên voice"))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                }

                TextField {
                    id: voiceCreateNameField
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    placeholderText: (void i18n.revision, i18n.t("media_library.voice_name_hint", "VD: Giọng Miền Nam Nữ"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    background: Rectangle {
                        radius: VfTheme.radiusControl
                        color: VfTheme.surface
                        border.color: voiceCreateNameField.activeFocus ? VfTheme.primary : VfTheme.borderBox
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(4)

                Text {
                    text: (void i18n.revision, i18n.t("media_library.base_voice", "Base Voice"))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                }

                ComboBox {
                    id: voiceCreateBaseCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    model: root.voiceBaseOptions
                    textRole: "label"
                    valueRole: "value"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(4)

                Text {
                    text: (void i18n.revision, i18n.t("media_library.voice_speaker", "Speaker (tên nhân vật)"))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                }

                TextField {
                    id: voiceCreateSpeakerField
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    placeholderText: (void i18n.revision, i18n.t("media_library.voice_speaker_hint", "VD: Cô gái trẻ miền Nam"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    background: Rectangle {
                        radius: VfTheme.radiusControl
                        color: VfTheme.surface
                        border.color: voiceCreateSpeakerField.activeFocus ? VfTheme.primary : VfTheme.borderBox
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(4)

                Text {
                    text: (void i18n.revision, i18n.t("media_library.voice_performance", "Voice Performance (tông, tuổi, nhịp)"))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                }

                TextField {
                    id: voiceCreatePerformanceField
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    placeholderText: (void i18n.revision, i18n.t("media_library.voice_performance_hint", "VD: trẻ trung, ấm áp, nói chậm rãi"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    background: Rectangle {
                        radius: VfTheme.radiusControl
                        color: VfTheme.surface
                        border.color: voiceCreatePerformanceField.activeFocus ? VfTheme.primary : VfTheme.borderBox
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(4)

                Text {
                    text: (void i18n.revision, i18n.t("media_library.voice_dialog", "Câu thoại mẫu"))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(70)
                    radius: VfTheme.radiusControl
                    color: VfTheme.surface
                    border.color: voiceCreateDialogField.activeFocus ? VfTheme.primary : VfTheme.borderBox
                    clip: true

                    TextArea {
                        id: voiceCreateDialogField
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(6)
                        placeholderText: (void i18n.revision, i18n.t("media_library.voice_dialog_hint", "Nhập 1-2 câu để tạo & nghe thử giọng..."))
                        wrapMode: TextEdit.Wrap
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        background: Item {}
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root.voiceGenStatus.length > 0
                text: root.voiceGenStatus
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.italic: true
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: VfTheme.dp(4)
                spacing: VfTheme.dp(8)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Hủy"))
                    minWidth: VfTheme.dp(88)
                    enabled: !(root.voiceServiceAdapter && root.voiceServiceAdapter.voiceGenBusy)
                    onClicked: voiceCreateDialog.close()
                }

                VfButton {
                    id: voiceGenerateBtn
                    text: (root.voiceServiceAdapter && root.voiceServiceAdapter.voiceGenBusy)
                        ? (void i18n.revision, i18n.t("media_library.voice_generating", "Đang tạo..."))
                        : (void i18n.revision, i18n.t("media_library.generate_voice_btn", "Tạo & nghe thử"))
                    tone: "primary"
                    minWidth: VfTheme.dp(132)
                    enabled: voiceCreateNameField.text.trim().length > 0
                        && voiceCreateSpeakerField.text.trim().length > 0
                        && voiceCreatePerformanceField.text.trim().length > 0
                        && voiceCreateDialogField.text.trim().length > 0
                        && voiceCreateBaseCombo.currentIndex >= 0
                        && !(root.voiceServiceAdapter && root.voiceServiceAdapter.voiceGenBusy)
                    onClicked: {
                        if (!root.voiceServiceAdapter || typeof root.voiceServiceAdapter.generateMediaVoice !== "function") {
                            root.voiceGenStatus = "Voice generation unavailable."
                            return
                        }
                        root.voiceGenStatus = (void i18n.revision, i18n.t("media_library.voice_generating_status", "Đang tạo giọng qua TTS (live account)..."))
                        root.voiceServiceAdapter.generateMediaVoice(
                            voiceCreateNameField.text.trim(),
                            String(voiceCreateBaseCombo.currentValue || ""),
                            voiceCreateSpeakerField.text.trim(),
                            voiceCreatePerformanceField.text.trim(),
                            voiceCreateDialogField.text.trim()
                        )
                    }
                }
            }
        }

        // Result of async generation arrives here (off-UI-thread → signal).
        Connections {
            target: root.voiceServiceAdapter
            ignoreUnknownSignals: true
            function onMediaVoiceGenerated(result) {
                if (!voiceCreateDialog.visible)
                    return
                root.voiceGenStatus = ""
                voiceCreateDialog.close()
                if (result && result.ok) {
                    root._load_voice_library(root.voiceSearchText)
                    root.showFeedback(
                        (void i18n.revision, i18n.t("media_library.create_voice", "Tạo Voice")),
                        String(result.message || (void i18n.revision, i18n.t("media_library.voice_created", "Đã tạo voice.")))
                    )
                } else {
                    root.showFeedback(
                        (void i18n.revision, i18n.t("media_library.create_voice_failed", "Tạo Voice thất bại")),
                        String((result && result.message) || (void i18n.revision, i18n.t("media_library.create_voice_failed_generic", "Không thể tạo voice.")))
                    )
                }
            }
        }
    }

    component FilterChip: Rectangle {
        property string label: ""
        property string value: ""
        property string iconName: ""
        property color accent: "#2563EB"
        property bool active: root.filterType === value

        visible: root.filterChipVisible(value)
        height: visible ? VfTheme.dp(27) : 0
        width: visible ? Math.max(68, chipText.implicitWidth + (iconName.length > 0 ? 36 : 22)) : 0
        radius: 0
        color: active ? accent : VfTheme.surfaceSoft
        border.color: active ? accent : VfTheme.border

        Row {
            anchors.centerIn: parent
            spacing: VfTheme.dp(4)

            VfAppIcon {
                visible: parent.parent.iconName.length > 0
                anchors.verticalCenter: parent.verticalCenter
                name: parent.parent.iconName
                size: VfTheme.dp(12)
                color: parent.parent.active ? "#FFFFFF" : parent.parent.accent
            }

            Text {
                id: chipText
                anchors.verticalCenter: parent.verticalCenter
                text: parent.parent.label
                color: parent.parent.active ? "#FFFFFF" : VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: parent.parent.active ? Font.DemiBold : Font.Medium
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: parent.visible
            cursorShape: Qt.PointingHandCursor
            onClicked: root.setFilterType(parent.value)
        }
    }

    Dialog {
        id: deleteConfirmDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(360), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("media_library.confirm_delete", "Confirm delete"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.formatCountText(
                    (void i18n.revision, i18n.t("media_library.delete_items", "Delete {count} selected item(s)?")),
                    root.pendingDeleteIds.length
                )
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: deleteConfirmDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                    tone: "danger"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        root.commitDelete(root.pendingDeleteIds)
                        deleteConfirmDialog.close()
                    }
                }
            }
        }

        onClosed: root.pendingDeleteIds = []
    }

    Dialog {
        id: feedbackDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(360), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Text {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: VfTheme.dp(10)

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

    Dialog {
        id: renameDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("media_library.rename_title", "Rename media"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("media_library.rename_prompt", "Enter a new name for the selected media item."))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            TextField {
                id: renameInput
                Layout.fillWidth: true
                placeholderText: (void i18n.revision, i18n.t("media_library.rename_placeholder", "Media name"))
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                background: Rectangle {
                    color: VfTheme.surface
                    border.width: 1
                    border.color: VfTheme.borderStrong
                    radius: VfTheme.dp(4)
                }
                onAccepted: root.commitRename()
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: renameDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.save", "Save"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: root.commitRename()
                }
            }
        }

        onOpened: renameInput.forceActiveFocus()
        onClosed: {
            root.pendingRenameMediaId = ""
            root.pendingRenameMediaName = ""
        }
    }
}
