import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"

import "../theme"

Dialog {
    id: root
    objectName: "styleManagerDialog"

    property var styles: []
    property string selectedId: ""
    property string statusMessage: ""
    property int activeBucketIndex: 0
    property int sortIndex: 0
    property bool favoriteOnly: false
    property string searchText: ""
    property var bucketItems: []
    // Topic tree rows depend only on the full styles set (not on filters/tab),
    // so compute once when styles change instead of as a per-eval function
    // binding on the ListView model (that returned a fresh array every tick →
    // full delegate rebuild on each tab switch).
    property var topicTreeRowsCache: []
    property var currentItem: ({})
    property var previewState: ({})
    property string previewMessage: ""
    property string selectedCameraId: ""
    property string selectedStyleId: ""
    property string selectedSurfaceStyleId: ""
    // Draw tab lists native Draw contracts only. A saved motion profile can
    // still animate a job, but it does not move a Style Framework into this tab.
    property string initialBucketKey: ""
    property bool drawMotionAvailable: false
    property bool initialDrawMotionEnabled: false
    property string initialHandAssetId: "auto"
    property string initialActorMode: "auto"
    property bool drawMotionEnabled: false
    property var handAssetOptions: []
    property var savedDrawHandAssignments: ({})
    property var savedDrawMotionProfiles: ({})
    property string selectedHandAssetId: "auto"
    property string selectedActorMode: "auto"
    readonly property var actorModeOptions: [
        { label: "Auto theo style", value: "auto", symbol: "✨" },
        { label: "Move vật thể", value: "move", symbol: "✋" },
        { label: "Tay + bút", value: "hand_pen", symbol: "✍" },
        { label: "Chỉ bút", value: "pen", symbol: "✒" }
    ]
    // Per-dialog assignments keep the renderer asset attached to the Draw
    // framework it was chosen for. Only the selected primary Draw style is
    // emitted on Apply, but switching cards no longer leaks one pen into all.
    property var drawHandAssignments: ({})
    property string pendingHandStyleId: ""
    // Combo (structural + surface) is opt-in — single-select unless this is on.
    property bool comboEnabled: false
    // Clone route only: offer an "auto from source video" pseudo-selection at the top
    // of the style tab. Picking it means "no manual style — let the clone extract the
    // source video's look" (auto_style_framework). Any real card selection turns it off.
    property bool allowAutoStyle: false
    property bool autoStyleSelected: false
    // Opt-in: after the clone extracts the source look, save it as a reusable library style.
    property bool confirmApplyChecked: false
    property string pendingDeleteId: ""
    property string pendingDeleteName: ""
    property string pendingDeleteTopicId: ""
    property string pendingDeleteTopicName: ""
    property string previewPollCampaignId: ""
    property int previewPollTicks: 0
    // Set on open so the manager starts with NOTHING selected; cleared the moment
    // the user picks a style/camera, after which the selection is retained.
    property bool suppressInitialSelect: false
    property var pendingBulkItems: []
    property bool pendingBulkOnlyMissing: true
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property bool previewGenerationBusy: false
    property bool motionPreviewBusy: false
    property var motionPreviewState: ({})
    property bool topicGenerationBusy: false
    property string topicSeedText: ""
    property string topicTargetCountText: "96"
    property string selectedTopicFilter: ""
    property string selectedTopicGroupFilter: ""
    // Camera Framework đã bỏ (2026-07-15): camera do planner viết PER-SCENE trong
    // prompt (scene JSON có camera.shot riêng từng cảnh) — khoá 1 camera cho cả run
    // là anti-pattern. Item kind=camera trong library bị refreshBucket lọc bỏ vì
    // không còn bucket "camera"; plumbing camera_id phía backend giữ nguyên (rỗng).
    readonly property var bucketSpecs: [
        { key: "style", label: (void i18n.revision, i18n.t("style_manager.style_tab", "Style Framework")), shortLabel: (void i18n.revision, i18n.t("style_manager.style_short", "Style")) },
        { key: "draw", label: (void i18n.revision, i18n.t("style_manager.draw_tab", "Draw / VideoScribe")), shortLabel: (void i18n.revision, i18n.t("style_manager.draw_short", "Draw")) },
        { key: "topic", label: (void i18n.revision, i18n.t("style_manager.topic_tab", "Chủ đề")), shortLabel: (void i18n.revision, i18n.t("style_manager.topic_short", "Chủ đề")) }
    ]
    // Video routes use Draw frameworks as ordinary visual styles. The separate
    // Draw bucket exists only where the local image-motion renderer is usable.
    readonly property var visibleBucketSpecs: root.drawCatalogSeparated()
        ? root.bucketSpecs : [root.bucketSpecs[0], root.bucketSpecs[2]]

    signal refreshRequested(string search)
    signal addRequested(string kind)
    signal editRequested(var style)
    signal deleteRequested(string styleId)
    signal deleteTopicRequested(string topicId)
    signal toggleFavoriteRequested(string styleId)
    signal previewInfoRequested(string styleId)
    signal generatePreviewRequested(var style)
    signal comboPreviewRequested(var selection)
    signal bulkPreviewRequested(var items, bool onlyMissing)
    signal topicGenerateRequested(var payload)
    signal applyRequested(var selection)
    signal saveHandBindingRequested(string styleId, string assetId)
    signal saveDrawProfileRequested(string styleId, string actorMode, string assetId)
    signal motionPreviewRequested(string styleId, string actorMode, string handAsset, bool force)

    title: (void i18n.revision, i18n.t("style_manager.dialog_title", "Chọn Style Framework"))
    header: null
    parent: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, VfTheme.dp(1500), VfTheme.dp(40))
    height: VfDialogMetrics.height(parent, VfTheme.dp(1000), VfTheme.dp(40))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton

    onOpened: {
        if (root.initialBucketKey.length)
            root.activeBucketIndex = root.bucketIndexForKey(root.initialBucketKey)
        root.drawMotionEnabled = root.drawMotionAvailable && root.initialDrawMotionEnabled
        root.selectedHandAssetId = String(root.initialHandAssetId || "auto")
        root.selectedActorMode = String(root.initialActorMode || "auto")
        var restoredAssignments = ({})
        var savedKeys = Object.keys(root.savedDrawHandAssignments || ({}))
        for (var savedIndex = 0; savedIndex < savedKeys.length; savedIndex++)
            restoredAssignments[savedKeys[savedIndex]] = String(root.savedDrawHandAssignments[savedKeys[savedIndex]] || "")
        root.drawHandAssignments = restoredAssignments
        if (root.isDrawStyleId(root.selectedStyleId)) {
            var initialAsset = String(root.initialHandAssetId || "auto")
            if (!String(root.drawHandAssignments[root.selectedStyleId] || "").length
                    && initialAsset !== "auto")
                root.setHandForDrawStyle(root.selectedStyleId, initialAsset)
            root.selectedHandAssetId = root.handForDrawStyle(root.selectedStyleId)
        }
        // Reset selection each time the manager opens — nothing focused.
        root.suppressInitialSelect = true
        root.selectedId = ""
        root.currentItem = ({})
        // Combo mode follows whatever combo the config already carries.
        root.comboEnabled = root.selectedSurfaceStyleId.length > 0
        rebuildTopicTree()
        refreshBucket()
        // Auto is the default for clone whenever no manual style/camera is carried in.
        root.autoStyleSelected = root.allowAutoStyle
            && !root.selectedStyleId.length
            && !root.selectedSurfaceStyleId.length
            && !root.selectedCameraId.length
    }
    onClosed: {
        previewCampaignTimer.stop()
        root.previewPollCampaignId = ""
        root.initialBucketKey = ""
        root.pendingHandStyleId = ""
    }
    onStylesChanged: {
        rebuildTopicTree()
        refreshBucket()
        selectFromCurrentId()
    }
    onSavedDrawMotionProfilesChanged: {
        refreshBucket()
        if (root.selectedStyleId.length && root.itemIsDrawStyle(root.itemById(root.selectedStyleId)))
            root.selectedHandAssetId = root.handForDrawStyle(root.selectedStyleId)
    }
    onDrawMotionAvailableChanged: {
        if (!root.drawMotionAvailable) {
            root.drawMotionEnabled = false
            if (root.activeDrawMode())
                root.activeBucketIndex = root.bucketIndexForKey("style")
        }
        root.refreshBucket()
    }
    onSortIndexChanged: refreshBucket()
    onFavoriteOnlyChanged: refreshBucket()
    onSearchTextChanged: refreshBucket()
    onSelectedIdChanged: selectFromCurrentId()
    onCurrentItemChanged: {
        requestPreview()
        root.scheduleMotionPreview(false)
    }
    onSelectedCameraIdChanged: confirmApplyChecked = false
    onSelectedStyleIdChanged: {
        confirmApplyChecked = false
        if (root.isComboSelection())
            requestPreview()
    }
    onSelectedSurfaceStyleIdChanged: {
        confirmApplyChecked = false
        requestPreview()
    }
    // Deterministic realtime refresh: when a preview generation worker finishes
    // (busy flips false) re-query from disk. The worker's result signal payload
    // can intermittently get lost across the thread boundary; this edge always
    // fires, so the freshly saved image shows without reopening the dialog.
    onPreviewGenerationBusyChanged: {
        if (!previewGenerationBusy && root.visible)
            requestPreview()
    }
    onSelectedActorModeChanged: root.scheduleMotionPreview(false)
    onSelectedHandAssetIdChanged: root.scheduleMotionPreview(false)
    onActiveBucketIndexChanged: {
        refreshBucket()
        root.scheduleMotionPreview(false)
    }

    function itemId(item) {
        return String((item || {}).id || (item || {}).style_id || "")
    }

    function itemKind(item) {
        var kind = String((item || {}).kind || "style").toLowerCase()
        return kind === "camera" ? "camera" : "style"
    }

    function itemTopicId(item) {
        return String((item || {}).topic_id || "")
    }

    function itemTopicName(item) {
        return String((item || {}).topic_name || itemTopicId(item) || "")
    }

    function itemTopicGroupId(item) {
        return String((item || {}).topic_group_id || "")
    }

    function itemTopicGroup(item) {
        return String((item || {}).topic_group || itemTopicGroupId(item) || "")
    }

    function hasTopic(item) {
        return itemTopicId(item).length > 0
    }

    function topicPath(item) {
        var parts = []
        if (itemTopicName(item).length)
            parts.push(itemTopicName(item))
        if (itemTopicGroup(item).length)
            parts.push(itemTopicGroup(item))
        return parts.join(" / ")
    }

    function itemName(item) {
        return String((item || {}).display_name || (item || {}).name || itemId(item) || (void i18n.revision, i18n.t("style_manager.item_fallback", "Style")))
    }

    function displayName(item) {
        return cleanDisplayText(itemName(item))
    }

    function cleanDisplayText(text) {
        var value = String(text || "").trim()
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
        filtered = filtered.replace(/[ \t]+/g, " ").trim()
        return filtered.length ? filtered : String(text || "")
    }

    function formatNameText(templateText, nameText) {
        var value = String(nameText || "")
        return String(templateText || "")
            .replace("{name}", value)
            .replace("%1", value)
    }

    function compareText(left, right) {
        if (left < right)
            return -1
        if (left > right)
            return 1
        return 0
    }

    function itemPrompt(item) {
        return String((item || {}).veo3_prompt || (item || {}).prompt || (item || {}).description || "")
    }

    function fileUrl(raw) {
        var value = String(raw || "")
        if (!value.length)
            return ""
        return "file:///" + value.replace(/\\/g, "/")
    }

    function previewInfo() {
        return (root.previewState || {}).preview || {}
    }

    function previewStateForItem(item) {
        var payload = item || ({})
        var previewState = payload.preview_state || payload.previewState || ({})
        var preview = previewState.preview || ({})
        if (Boolean(preview.exists) && String(preview.path || "").length > 0)
            return previewState
        var path = thumbnailPath(payload)
        if (path.length > 0) {
            return {
                ok: true,
                style_id: itemId(payload),
                preview: {
                    exists: true,
                    path: path,
                    filename: path.split(/[\\/]/).pop()
                },
                message: (void i18n.revision, i18n.t("style_manager.preview_loaded_from_item", "Loaded preview from style data."))
            }
        }
        return ({})
    }

    function itemHasPreview(item) {
        var payload = item || ({})
        if (Boolean(payload.has_preview))
            return true
        var state = root.previewStateForItem(payload)
        var preview = state.preview || ({})
        return Boolean(preview.exists) && String(preview.path || "").length > 0
    }

    function previewPath() {
        return String(previewInfo().path || "")
    }

    function hasPreview() {
        return Boolean(previewInfo().exists && previewPath().length > 0)
    }

    function urlForPath(raw) {
        var value = String(raw || "")
        if (!value.length)
            return ""
        if (value.indexOf("file:/") === 0 || value.indexOf("qrc:/") === 0 || value.indexOf("http://") === 0 || value.indexOf("https://") === 0)
            return value
        return fileUrl(value)
    }

    function thumbnailPath(item) {
        var payload = item || ({})
        var preview = payload.preview || payload.preview_state || ({})
        var nestedPreview = preview.preview || ({})
        var value = String(
            payload.preview_thumb
            || payload.thumbnail
            || payload.thumbnail_path
            || payload.preview_path
            || preview.path
            || nestedPreview.path
            || ""
        )
        return value
    }

    function thumbnailUrl(item) {
        return urlForPath(thumbnailPath(item))
    }

    function isCurrent(item) {
        var id = itemId(item)
        return id.length > 0 && id === root.selectedId
    }

    function activeBucketKey() {
        return root.bucketSpecs[Math.max(0, Math.min(root.activeBucketIndex, root.bucketSpecs.length - 1))].key
    }

    function bucketIndexForKey(key) {
        var wanted = String(key || "style").toLowerCase()
        if (wanted === "draw" && !root.drawCatalogSeparated())
            wanted = "style"
        for (var i = 0; i < root.bucketSpecs.length; i++) {
            if (String(root.bucketSpecs[i].key) === wanted)
                return i
        }
        return 0
    }

    function openBucket(key) {
        root.initialBucketKey = String(key || "style").toLowerCase()
        root.activeBucketIndex = root.bucketIndexForKey(root.initialBucketKey)
        root.open()
    }

    function activeTopicMode() {
        return activeBucketKey() === "topic"
    }

    function activeDrawMode() {
        return activeBucketKey() === "draw"
    }

    function drawCatalogSeparated() {
        return root.drawMotionAvailable
    }

    function itemHasNativeDrawContract(item) {
        if (itemKind(item) !== "style")
            return false
        if (String((item || {}).authoring_mode || "").toLowerCase() === "draw"
                || itemTopicId(item).toLowerCase() === "draw_motion_2d")
            return true
        var framework = (item || {}).framework_definition
            || (item || {}).framework || (item || {}).resolved || ({})
        var capability = ((framework.render_capabilities || {}).image_motion || {})
        if (!Boolean(capability.enabled))
            return false
        var renderers = capability.renderers || []
        for (var i = 0; i < renderers.length; i++) {
            var renderer = String(renderers[i] || "").toLowerCase()
            if (renderer === "stroke_reveal" || renderer === "outline_fill"
                    || renderer === "object_place")
                return true
        }
        return false
    }

    function drawProfileForStyle(styleId) {
        var wanted = String(styleId || "").toLowerCase()
        return (root.savedDrawMotionProfiles || {})[wanted] || ({})
    }

    function styleHasDrawProfile(styleId) {
        return Boolean(root.drawProfileForStyle(styleId).enabled)
    }

    function itemIsDrawStyle(item) {
        return root.itemHasNativeDrawContract(item)
            || root.styleHasDrawProfile(root.itemId(item))
    }

    function itemUsesDrawBucket(item) {
        return root.itemUsesNativeDrawBucket(item)
    }

    function itemUsesNativeDrawBucket(item) {
        return root.drawCatalogSeparated() && root.itemHasNativeDrawContract(item)
    }

    function itemUsesTopicBucket(item) {
        return root.hasTopic(item) && !root.itemHasNativeDrawContract(item)
    }

    function styleIdUsesSeparatedBucket(styleId) {
        var item = root.itemById(styleId)
        return root.itemUsesNativeDrawBucket(item) || root.itemUsesTopicBucket(item)
    }

    function drawStyleSupportsVisibleHand(item) {
        if (root.styleHasDrawProfile(root.itemId(item)))
            return true
        var payload = item || ({})
        var framework = payload.framework_definition || payload.framework || payload.resolved || ({})
        var capability = ((framework.render_capabilities || {}).image_motion || {})
        var renderers = capability.renderers || []
        for (var i = 0; i < renderers.length; i++) {
            var renderer = String(renderers[i] || "").toLowerCase()
            if (renderer === "stroke_reveal" || renderer === "outline_fill"
                    || renderer === "object_place")
                return true
        }
        return false
    }

    function handOptionByValue(value) {
        var wanted = String(value || "auto")
        var items = root.handAssetOptions || []
        for (var i = 0; i < items.length; i++) {
            if (String((items[i] || {}).value || "") === wanted)
                return items[i] || ({})
        }
        return items.length > 0 ? (items[0] || ({})) : ({})
    }

    function defaultHandForDrawStyle(styleId) {
        var profile = root.drawProfileForStyle(styleId)
        if (String(profile.hand_asset || "auto") !== "auto")
            return String(profile.hand_asset)
        var item = root.itemById(styleId)
        var framework = (item || {}).framework_definition
            || (item || {}).framework || (item || {}).resolved || ({})
        var capability = ((framework.render_capabilities || {}).image_motion || {})
        return String(capability.default_hand_asset || "auto")
    }

    function nativeActorModeForDrawStyle(styleId) {
        var item = root.itemById(styleId)
        var framework = (item || {}).framework_definition
            || (item || {}).framework || (item || {}).resolved || ({})
        var capability = ((framework.render_capabilities || {}).image_motion || {})
        var mode = String(capability.default_actor_mode || "hand_pen")
        return mode === "move" || mode === "pen" ? mode : "hand_pen"
    }

    function actorFamilyForMode(mode) {
        return String(mode || "") === "move" ? "move" : "draw"
    }

    function actorModeAllowedForStyle(styleId, mode) {
        var wanted = String(mode || "auto")
        var native = root.nativeActorModeForDrawStyle(styleId)
        if (wanted === "auto")
            return true
        return root.actorFamilyForMode(wanted) === root.actorFamilyForMode(native)
    }

    function visibleActorModeOptions() {
        var native = root.nativeActorModeForDrawStyle(root.selectedStyleId)
        var allowed = native === "move"
            ? ["auto", "move"] : ["auto", "hand_pen", "pen"]
        var items = root.actorModeOptions || []
        var out = []
        for (var i = 0; i < items.length; i++) {
            var value = String((items[i] || {}).value || "")
            if (allowed.indexOf(value) >= 0)
                out.push(items[i])
        }
        return out
    }

    function defaultActorModeForDrawStyle(styleId) {
        var native = root.nativeActorModeForDrawStyle(styleId)
        var profile = root.drawProfileForStyle(styleId)
        var profileMode = String(profile.actor_mode || "")
        if (root.actorModeAllowedForStyle(styleId, profileMode) && profileMode !== "auto")
            return profileMode
        return native
    }

    function actorModeForDrawStyle(styleId) {
        var manual = String(root.selectedActorMode || "auto")
        if (String(styleId || "") === root.selectedStyleId
                && manual !== "auto"
                && root.actorModeAllowedForStyle(styleId, manual))
            return manual
        return root.defaultActorModeForDrawStyle(styleId)
    }

    function actorRoleForMode(mode) {
        var value = String(mode || "hand_pen")
        return value === "move" ? "hand_place"
            : (value === "pen" ? "tool_only" : "hand_draw")
    }

    function actorModeLabel(mode) {
        var value = String(mode || "hand_pen")
        if (value === "move")
            return "Move"
        if (value === "pen")
            return "Pen"
        return "Hand+Pen"
    }

    function effectiveHandOptionForDrawStyle(styleId) {
        var role = root.actorRoleForMode(root.actorModeForDrawStyle(styleId))
        var chosenId = String(styleId || "") === root.selectedStyleId
            && String(root.selectedHandAssetId || "auto") !== "auto"
            ? root.selectedHandAssetId : root.handForDrawStyle(styleId)
        var selected = root.handOptionByValue(chosenId)
        if (String(selected.motion_role || "") === role)
            return selected
        var items = root.handAssetOptions || []
        for (var i = 0; i < items.length; i++) {
            if (String((items[i] || {}).motion_role || "") === role)
                return items[i] || ({})
        }
        return selected
    }

    function selectedHandLabel() {
        var item = root.handOptionByValue(root.selectedHandAssetId)
        return String(item.label || root.selectedHandAssetId || "Auto")
    }

    function selectedHandPreviewUrl() {
        return root.urlForPath(String(root.handOptionByValue(root.selectedHandAssetId).preview_path || ""))
    }

    function handForDrawStyle(styleId) {
        var wanted = String(styleId || "")
        var saved = String((root.drawHandAssignments || {})[wanted] || "")
        return saved.length ? saved : root.defaultHandForDrawStyle(wanted)
    }

    function handLabelForDrawStyle(styleId) {
        var item = root.effectiveHandOptionForDrawStyle(styleId)
        return String(item.label || root.handForDrawStyle(styleId) || "Auto")
    }

    function handBadgeForDrawStyle(styleId) {
        return root.actorModeLabel(root.actorModeForDrawStyle(styleId))
    }

    function handPreviewForDrawStyle(styleId) {
        var item = root.effectiveHandOptionForDrawStyle(styleId)
        return root.urlForPath(String(item.preview_path || ""))
    }

    function setHandForDrawStyle(styleId, assetId) {
        var wanted = String(styleId || "")
        if (!wanted.length)
            return
        var next = ({})
        var current = root.drawHandAssignments || ({})
        var keys = Object.keys(current)
        for (var i = 0; i < keys.length; i++)
            next[keys[i]] = current[keys[i]]
        var selectedAsset = String(assetId || "auto")
        next[wanted] = selectedAsset === "auto"
            ? root.defaultHandForDrawStyle(wanted) : selectedAsset
        root.drawHandAssignments = next
        if (root.selectedStyleId === wanted)
            root.selectedHandAssetId = next[wanted]
    }

    function openHandLibraryForStyle(item) {
        if (!root.itemIsDrawStyle(item))
            return
        root.chooseItem(item)
        root.pendingHandStyleId = root.itemId(item)
        handLibraryDialog.openFor(root.handForDrawStyle(root.pendingHandStyleId))
    }

    function openHandLibraryForSelectedDrawStyle() {
        var item = root.itemById(root.selectedStyleId)
        if (!root.itemIsDrawStyle(item))
            return
        if (!root.drawStyleSupportsVisibleHand(item)) {
            root.showFeedback(
                (void i18n.revision, i18n.t("style_manager.hand_free_style_title", "Style dựng không dùng tay")),
                (void i18n.revision, i18n.t("style_manager.hand_free_style_message", "Framework này chỉ hỗ trợ dựng lớp/texture. Chọn tay hoặc bút sẽ không tạo chuyển động đúng bản chất."))
            )
            return
        }
        root.openHandLibraryForStyle(item)
    }

    function configureSelectedStyleForDraw() {
        var styleId = String(root.selectedStyleId || "")
        if (!styleId.length)
            return
        root.saveDrawProfileRequested(
            styleId,
            String(root.selectedActorMode || "auto"),
            String(root.selectedHandAssetId || "auto")
        )
        root.drawMotionEnabled = true
    }

    function matchesSearch(item, needle) {
        if (!needle.length)
            return true
        var haystack = [
            itemId(item),
            itemName(item),
            displayName(item),
            itemPrompt(item),
            String((item || {}).source || ""),
            String((item || {}).origin || ""),
            itemTopicId(item),
            itemTopicName(item),
            itemTopicGroup(item),
            String((item || {}).visual_value || ""),
            String((item || {}).usage_potential || "")
        ].join(" ").toLowerCase()
        return haystack.indexOf(needle) >= 0
    }

    function topicFilterMatches(item) {
        if (!root.selectedTopicFilter.length)
            return true
        if (itemTopicId(item) !== root.selectedTopicFilter)
            return false
        if (root.selectedTopicGroupFilter.length && itemTopicGroupId(item) !== root.selectedTopicGroupFilter)
            return false
        return true
    }

    function refreshBucket() {
        var needle = root.searchText.trim().toLowerCase()
        var key = activeBucketKey()
        var items = []
        for (var i = 0; i < root.styles.length; i++) {
            var item = root.styles[i]
            if (key === "draw") {
                if (!root.itemUsesDrawBucket(item))
                    continue
            } else if (key === "topic") {
                // Draw owns its own curated bucket. Do not duplicate those
                // frameworks inside the general topic tree.
                if (itemKind(item) !== "style" || !hasTopic(item)
                        || root.itemHasNativeDrawContract(item) || !topicFilterMatches(item))
                    continue
            } else {
                if (itemKind(item) !== key)
                    continue
                if (key === "style" && hasTopic(item)
                        && !(root.itemIsDrawStyle(item) && !root.drawCatalogSeparated()))
                    continue
            }
            if (root.favoriteOnly && !Boolean(item.favorite || item.is_favorite))
                continue
            if (!matchesSearch(item, needle))
                continue
            items.push(item)
        }
        items.sort(function(a, b) {
            if (key === "topic") {
                var topicDelta = compareText(itemTopicName(a).toLowerCase(), itemTopicName(b).toLowerCase())
                if (topicDelta !== 0)
                    return topicDelta
                var groupOrderDelta = Number((a || {}).topic_group_order || 0) - Number((b || {}).topic_group_order || 0)
                if (groupOrderDelta !== 0)
                    return groupOrderDelta
                var groupDelta = compareText(itemTopicGroup(a).toLowerCase(), itemTopicGroup(b).toLowerCase())
                if (groupDelta !== 0)
                    return groupDelta
                var indexDelta = Number((a || {}).topic_index || 0) - Number((b || {}).topic_index || 0)
                if (indexDelta !== 0)
                    return indexDelta
            }
            var groupDelta = sortGroupRank(a) - sortGroupRank(b)
            if (groupDelta !== 0)
                return groupDelta
            var left = itemName(a).toLowerCase()
            var right = itemName(b).toLowerCase()
            if (root.sortIndex === 1) {
                return -compareText(left, right)
            }
            if (root.sortIndex === 2) {
                var ca = Number((a || {}).last_used || (a || {}).updated_at || 0)
                var cb = Number((b || {}).last_used || (b || {}).updated_at || 0)
                if (ca !== cb)
                    return cb - ca
            }
            return compareText(left, right)
        })
        // Clone only: the "auto from source video" choice rides as the FIRST card of the
        // style tab (after sort, so it always stays at the top). It's a synthetic item the
        // delegate renders specially — never a real library style.
        if (root.allowAutoStyle && key === "style")
            items.unshift({ id: "__auto_source__", __auto_card__: true, kind: "style" })
        root.bucketItems = items
        // Fresh open: leave everything unselected until the user picks something.
        if (root.suppressInitialSelect) {
            root.currentItem = ({})
            return
        }
        var preferredId = selectedIdForBucket(key)
        if (preferredId.length) {
            for (var j = 0; j < items.length; j++) {
                if (itemId(items[j]) === preferredId) {
                    root.currentItem = items[j]
                    return
                }
            }
        }
        if (!root.currentItem || (key === "topic" ? !hasTopic(root.currentItem) : itemKind(root.currentItem) !== key))
            root.currentItem = ({})
    }

    function selectFromCurrentId() {
        if (!root.selectedId.length)
            return
        for (var i = 0; i < root.styles.length; i++) {
            var item = root.styles[i]
            if (itemId(item) === root.selectedId) {
                root.currentItem = item
                if (root.itemUsesNativeDrawBucket(item))
                    root.activeBucketIndex = root.bucketIndexForKey("draw")
                else if (root.itemUsesTopicBucket(item))
                    root.activeBucketIndex = root.bucketIndexForKey("topic")
                else if (!root.activeTopicMode())
                    root.activeBucketIndex = root.bucketIndexForKey("style")
                if (root.activeDrawMode()) {
                    root.selectedStyleId = itemId(item)
                    root.selectedHandAssetId = root.handForDrawStyle(root.selectedStyleId)
                } else if (root.activeTopicMode() || root.itemUsesTopicBucket(item)) {
                    root.selectedStyleId = itemId(item)
                    if (root.selectedSurfaceStyleId === root.selectedStyleId)
                        root.selectedSurfaceStyleId = ""
                } else if (root.comboEnabled && root.selectedStyleId.length && root.selectedStyleId !== itemId(item)) {
                    root.selectedSurfaceStyleId = itemId(item)
                } else {
                    root.selectedStyleId = itemId(item)
                    if (!root.comboEnabled || root.selectedSurfaceStyleId === root.selectedStyleId)
                        root.selectedSurfaceStyleId = ""
                }
                return
            }
        }
    }

    function chooseItem(item) {
        root.suppressInitialSelect = false
        root.autoStyleSelected = false  // a manual pick always wins over auto
        var previousStyleId = root.selectedStyleId
        root.currentItem = item || ({})
        root.selectedId = itemId(item)
        if (!root.selectedId.length)
            return
        if (itemKind(item) === "camera") {
            root.selectedCameraId = root.selectedId
        } else if (root.activeDrawMode()) {
            if (root.comboEnabled && previousStyleId.length
                    && previousStyleId !== root.selectedId
                    && !root.selectedSurfaceStyleId.length
                    && !root.isTopicStyleId(previousStyleId))
                root.selectedSurfaceStyleId = previousStyleId
            root.selectedStyleId = root.selectedId
            if (!root.comboEnabled || root.selectedSurfaceStyleId === root.selectedStyleId)
                root.selectedSurfaceStyleId = ""
            root.selectedHandAssetId = root.handForDrawStyle(root.selectedStyleId)
            if (root.drawMotionAvailable)
                root.drawMotionEnabled = true
        } else if (root.activeTopicMode() || root.itemUsesTopicBucket(item)) {
            if (root.comboEnabled && previousStyleId.length && previousStyleId !== root.selectedId && !root.selectedSurfaceStyleId.length && !root.isTopicStyleId(previousStyleId))
                root.selectedSurfaceStyleId = previousStyleId
            root.selectedStyleId = root.selectedId
            if (!root.comboEnabled || root.selectedSurfaceStyleId === root.selectedStyleId)
                root.selectedSurfaceStyleId = ""
        } else if (root.comboEnabled && root.selectedStyleId.length && root.selectedStyleId !== root.selectedId) {
            root.selectedSurfaceStyleId = root.selectedId
        } else {
            root.selectedStyleId = root.selectedId
            if (!root.comboEnabled || root.selectedSurfaceStyleId === root.selectedStyleId)
                root.selectedSurfaceStyleId = ""
        }
        // A route-level manual actor belongs to the style it was chosen with.
        // Switching visual styles must return to that style's saved profile,
        // otherwise Hand+Pen from the previous card leaks into a new Move style.
        if (itemKind(item) === "style" && previousStyleId !== root.selectedStyleId) {
            root.selectedActorMode = "auto"
            root.selectedHandAssetId = root.itemIsDrawStyle(item)
                ? root.handForDrawStyle(root.selectedStyleId) : "auto"
        }
    }

    function selectedIdForBucket(key) {
        if (key === "camera")
            return root.selectedCameraId
        if (key === "draw")
            return root.drawCatalogSeparated() ? root.selectedStyleId : ""
                ? root.selectedStyleId : ""
        if (key === "topic")
            return root.itemUsesTopicBucket(root.itemById(root.selectedStyleId))
                ? root.selectedStyleId : ""
        if (key === "style")
            return root.selectedSurfaceStyleId.length ? root.selectedSurfaceStyleId
                : (root.styleIdUsesSeparatedBucket(root.selectedStyleId) ? "" : root.selectedStyleId)
        return root.selectedStyleId
    }

    function selectedIdForSlot(slot) {
        var key = String(slot || "")
        if (key === "camera")
            return root.selectedCameraId
        if (key === "surface_style")
            return root.selectedSurfaceStyleId
        return root.selectedStyleId
    }

    function selectedNameForSlot(slot) {
        var wanted = selectedIdForSlot(slot)
        if (!wanted.length)
            return (void i18n.revision, i18n.t("style_manager.none_selected", "None"))
        for (var i = 0; i < root.styles.length; i++) {
            if (itemId(root.styles[i]) === wanted)
                return displayName(root.styles[i])
        }
        return wanted
    }

    function selectedNameForBucket(key) {
        return selectedNameForSlot(key)
    }

    function itemById(wantedId) {
        var wanted = String(wantedId || "")
        if (!wanted.length)
            return ({})
        for (var i = 0; i < root.styles.length; i++) {
            if (itemId(root.styles[i]) === wanted)
                return root.styles[i]
        }
        return ({})
    }

    function isTopicStyleId(styleId) {
        var item = itemById(styleId)
        return itemId(item).length > 0 && root.hasTopic(item)
    }

    function isDrawStyleId(styleId) {
        return root.itemIsDrawStyle(root.itemById(styleId))
    }

    function selectionRoleForItem(item) {
        var id = itemId(item)
        if (!id.length)
            return ""
        if (id === root.selectedCameraId)
            return "camera"
        if (id === root.selectedSurfaceStyleId)
            return "surface_style"
        if (id === root.selectedStyleId)
            return "primary_style"
        return ""
    }

    function isItemSelected(item) {
        return selectionRoleForItem(item).length > 0
    }

    function selectedCount() {
        var count = 0
        if (root.selectedCameraId.length)
            count += 1
        if (root.selectedStyleId.length)
            count += 1
        if (root.selectedSurfaceStyleId.length)
            count += 1
        return count
    }

    function selectionPayload() {
        return {
            camera_id: root.selectedCameraId,
            style_id: root.selectedStyleId.length ? root.selectedStyleId : root.selectedSurfaceStyleId,
            structural_camera_id: root.selectedCameraId,
            structural_style_id: root.selectedStyleId,
            surface_camera_id: "",
            surface_style_id: root.selectedSurfaceStyleId,
            selection_mode: root.selectionMode(),
            auto_style_framework: root.autoStyleSelected,
            // This describes route intent, not which catalog tab happened to be
            // active when Apply was pressed.
            draw_motion_configured: root.drawMotionAvailable,
            image_motion_mode: root.drawMotionAvailable && root.drawMotionEnabled ? "auto" : "off",
            image_motion_hand_asset: String(root.selectedHandAssetId || "auto"),
            image_motion_actor_mode: root.actorModeAllowedForStyle(
                root.selectedStyleId, root.selectedActorMode)
                ? String(root.selectedActorMode || "auto") : "auto"
        }
    }

    function selectionMode() {
        if (root.selectedStyleId.length && root.selectedSurfaceStyleId.length && root.selectedCameraId.length)
            return "style_style_camera"
        if (root.selectedStyleId.length && root.selectedSurfaceStyleId.length)
            return "style_style"
        if (root.selectedStyleId.length && root.selectedCameraId.length)
            return "style_camera"
        if (root.selectedCameraId.length)
            return "camera"
        if (root.selectedStyleId.length || root.selectedSurfaceStyleId.length)
            return "style"
        return "none"
    }

    function selectionTitle() {
        var parts = []
        if (root.selectedStyleId.length)
            parts.push(root.selectedNameForSlot("primary_style"))
        if (root.selectedSurfaceStyleId.length)
            parts.push(root.selectedNameForSlot("surface_style"))
        if (root.selectedCameraId.length)
            parts.push(root.selectedNameForSlot("camera"))
        if (parts.length)
            return parts.join(" + ")
        return (void i18n.revision, i18n.t("style_manager.preview_empty_title", "Chưa chọn framework"))
    }

    function selectionDetailText() {
        var lines = []
        if (root.selectedStyleId.length)
            lines.push((void i18n.revision, i18n.t("style_manager.primary_style_label", "Style chính")) + ": " + root.selectedNameForSlot("primary_style"))
        if (root.selectedSurfaceStyleId.length)
            lines.push((void i18n.revision, i18n.t("style_manager.surface_style_label", "Render style")) + ": " + root.selectedNameForSlot("surface_style"))
        if (root.selectedCameraId.length)
            lines.push((void i18n.revision, i18n.t("style_manager.camera_short", "Camera")) + ": " + root.selectedNameForSlot("camera"))
        if (!lines.length)
            lines.push((void i18n.revision, i18n.t("style_manager.preview_empty_hint", "Chọn một style hoặc camera để xem trước.")))
        return lines.join("\n")
    }

    function confirmDetailText() {
        var lines = []
        if (root.selectedStyleId.length)
            lines.push("- " + (void i18n.revision, i18n.t("style_manager.primary_style_label", "Style chính")) + ": " + root.selectedNameForSlot("primary_style"))
        if (root.selectedSurfaceStyleId.length)
            lines.push("- " + (void i18n.revision, i18n.t("style_manager.surface_style_label", "Render style")) + ": " + root.selectedNameForSlot("surface_style"))
        if (root.selectedCameraId.length)
            lines.push("- " + (void i18n.revision, i18n.t("style_manager.camera_short", "Camera")) + ": " + root.selectedNameForSlot("camera"))
        return lines.join("\n")
    }

    function isFavorite(item) {
        return Boolean((item || {}).favorite || (item || {}).is_favorite)
    }

    function isCustom(item) {
        var source = String((item || {}).source || (item || {}).origin || "").toLowerCase()
        return source === "custom" || Boolean((item || {}).can_delete) || Boolean((item || {}).is_override)
    }

    function sortGroupRank(item) {
        if (isFavorite(item))
            return 0
        if (isCustom(item))
            return 1
        return 2
    }

    function clearBucket(key) {
        var clearedId = ""
        if (key === "camera") {
            clearedId = root.selectedCameraId
            root.selectedCameraId = ""
        } else if (key === "draw") {
            if (root.isDrawStyleId(root.selectedStyleId)) {
                clearedId = root.selectedStyleId
                root.selectedStyleId = ""
            }
        } else if (key === "topic") {
            if (root.isTopicStyleId(root.selectedStyleId)
                    && !root.isDrawStyleId(root.selectedStyleId)) {
                clearedId = root.selectedStyleId
                root.selectedStyleId = ""
                root.promoteSurfaceStyleIfNeeded()
            }
        } else {
            if (root.selectedSurfaceStyleId.length) {
                clearedId = root.selectedSurfaceStyleId
                root.selectedSurfaceStyleId = ""
            } else if (root.selectedStyleId.length
                    && !root.styleIdUsesSeparatedBucket(root.selectedStyleId)) {
                clearedId = root.selectedStyleId
                root.selectedStyleId = ""
            }
        }
        if (clearedId.length && root.selectedId === clearedId) {
            root.currentItem = ({})
            root.selectedId = ""
        }
        refreshBucket()
    }

    function clearCurrentSelection() {
        root.clearBucket(root.activeBucketKey())
    }

    function clearSlot(slot) {
        var key = String(slot || "")
        var clearedId = selectedIdForSlot(key)
        if (key === "camera")
            root.selectedCameraId = ""
        else if (key === "surface_style")
            root.selectedSurfaceStyleId = ""
        else
            root.selectedStyleId = ""
        if (key === "primary_style")
            root.promoteSurfaceStyleIfNeeded()
        if (clearedId.length && root.selectedId === clearedId) {
            root.currentItem = ({})
            root.selectedId = ""
        }
        refreshBucket()
    }

    function clearItemSelection(item) {
        var role = root.selectionRoleForItem(item)
        if (!role.length)
            return false
        if (role === "camera")
            root.clearSlot("camera")
        else if (role === "surface_style")
            root.clearSlot("surface_style")
        else
            root.clearSlot("primary_style")
        return true
    }

    function toggleItemSelection(item) {
        if (!root.clearItemSelection(item))
            root.chooseItem(item)
    }

    function selectAutoStyle() {
        // Pick "auto from source video": drop every manual style/camera, flag auto.
        root.autoStyleSelected = true
        root.clearAllSelections()
    }

    function clearAllSelections() {
        root.selectedCameraId = ""
        root.selectedStyleId = ""
        root.selectedSurfaceStyleId = ""
        root.selectedId = ""
        root.currentItem = ({})
        root.previewState = ({})
        root.previewMessage = ""
        root.refreshBucket()
    }

    function setComboEnabled(on) {
        root.comboEnabled = !!on
        if (!root.comboEnabled && root.selectedSurfaceStyleId.length) {
            // Collapse a combo back to a single style — drop the surface, keep primary.
            root.selectedSurfaceStyleId = ""
            root.refreshBucket()
        }
    }

    function jumpToTab(key) {
        var value = String(key || "").toLowerCase()
        var targetKey = value.indexOf("draw") >= 0
            ? "draw" : (value.indexOf("topic") >= 0 ? "topic" : "style")
        var primaryItem = root.itemById(root.selectedStyleId)
        if (value.indexOf("primary") >= 0 && root.itemUsesDrawBucket(primaryItem))
            targetKey = "draw"
        else if (value.indexOf("primary") >= 0 && root.itemUsesTopicBucket(primaryItem))
            targetKey = "topic"
        if (value.indexOf("surface") >= 0)
            targetKey = "style"
        if (targetKey === "draw" && !root.drawCatalogSeparated())
            targetKey = "style"
        root.activeBucketIndex = root.bucketIndexForKey(targetKey)
        var preferredId = selectedIdForBucket(targetKey)
        if (preferredId.length) {
            root.selectedId = preferredId
            root.selectFromCurrentId()
            return
        }
        if (targetKey === "topic") {
            if (!hasTopic(root.currentItem))
                root.currentItem = ({})
            return
        }
        if (targetKey === "draw") {
            if (!root.itemIsDrawStyle(root.currentItem))
                root.currentItem = ({})
            return
        }
        if (itemKind(root.currentItem) !== targetKey)
            root.currentItem = ({})
    }

    function promoteSurfaceStyleIfNeeded() {
        if (!root.selectedStyleId.length && root.selectedSurfaceStyleId.length) {
            root.selectedStyleId = root.selectedSurfaceStyleId
            root.selectedSurfaceStyleId = ""
        }
    }

    function topicTreeRows() {
        var topics = ({})
        var order = []
        for (var i = 0; i < root.styles.length; i++) {
            var item = root.styles[i] || ({})
            if (root.itemKind(item) !== "style" || !root.hasTopic(item)
                    || root.itemIsDrawStyle(item))
                continue
            var topicId = root.itemTopicId(item)
            if (!topics[topicId]) {
                topics[topicId] = {
                    id: topicId,
                    name: root.itemTopicName(item),
                    count: 0,
                    groups: ({}),
                    groupOrder: []
                }
                order.push(topicId)
            }
            topics[topicId].count += 1
            var groupId = root.itemTopicGroupId(item) || "_ungrouped"
            if (!topics[topicId].groups[groupId]) {
                topics[topicId].groups[groupId] = {
                    id: groupId,
                    name: root.itemTopicGroup(item) || (void i18n.revision, i18n.t("style_manager.topic_ungrouped", "Khác")),
                    count: 0,
                    order: Number(item.topic_group_order || 0)
                }
                topics[topicId].groupOrder.push(groupId)
            }
            topics[topicId].groups[groupId].count += 1
        }
        order.sort(function(a, b) { return root.compareText(topics[a].name.toLowerCase(), topics[b].name.toLowerCase()) })
        var rows = [{ type: "all", topic_id: "", group_id: "", name: (void i18n.revision, i18n.t("style_manager.topic_all", "Tất cả chủ đề")), count: root.topicStyleCount(), level: 0 }]
        for (var t = 0; t < order.length; t++) {
            var topic = topics[order[t]]
            rows.push({ type: "topic", topic_id: topic.id, group_id: "", name: topic.name, count: topic.count, level: 0 })
            topic.groupOrder.sort(function(a, b) {
                var left = topic.groups[a]
                var right = topic.groups[b]
                if (left.order !== right.order)
                    return left.order - right.order
                return root.compareText(left.name.toLowerCase(), right.name.toLowerCase())
            })
            for (var g = 0; g < topic.groupOrder.length; g++) {
                var group = topic.groups[topic.groupOrder[g]]
                rows.push({ type: "group", topic_id: topic.id, group_id: group.id, name: group.name, count: group.count, level: 1 })
            }
        }
        return rows
    }

    function rebuildTopicTree() {
        root.topicTreeRowsCache = root.topicTreeRows()
    }

    function topicStyleCount() {
        var count = 0
        for (var i = 0; i < root.styles.length; i++) {
            if (root.itemKind(root.styles[i]) === "style"
                    && root.hasTopic(root.styles[i])
                    && !root.itemIsDrawStyle(root.styles[i]))
                count += 1
        }
        return count
    }

    function selectTopicTreeRow(row) {
        var data = row || ({})
        root.selectedTopicFilter = String(data.topic_id || "")
        root.selectedTopicGroupFilter = String(data.group_id || "")
        root.refreshBucket()
    }

    function topicTreeRowSelected(row) {
        var data = row || ({})
        return root.selectedTopicFilter === String(data.topic_id || "")
            && root.selectedTopicGroupFilter === String(data.group_id || "")
    }

    function requestTopicGeneration() {
        var topic = String(root.topicSeedText || "").trim()
        if (!topic.length) {
            root.showFeedback(
                (void i18n.revision, i18n.t("style_manager.topic_required_title", "Thiếu chủ đề")),
                (void i18n.revision, i18n.t("style_manager.topic_required_msg", "Nhập chủ đề tổng trước khi tạo style tree."))
            )
            return
        }
        var count = parseInt(root.topicTargetCountText)
        if (!count || count < 8)
            count = 48
        root.topicGenerateRequested({ topic: topic, target_count: Math.min(128, count) })
    }

    function footerSummary() {
        var parts = []
        if (root.selectedStyleId.length)
            parts.push("style=" + root.selectedStyleId)
        if (root.selectedSurfaceStyleId.length)
            parts.push("surface_style=" + root.selectedSurfaceStyleId)
        if (root.selectedCameraId.length)
            parts.push("camera=" + root.selectedCameraId)
        if (root.drawMotionAvailable) {
            parts.push("draw=" + (root.drawMotionEnabled ? "on" : "off"))
            parts.push("actor=" + String(root.selectedActorMode || "auto"))
            parts.push("hand=" + String(root.selectedHandAssetId || "auto"))
        }
        return parts.length ? parts.join(" | ") : (void i18n.revision, i18n.t("style_manager.no_selection", "(no selection)"))
    }

    function canApplySelection() {
        if (root.drawMotionAvailable && root.drawMotionEnabled)
            return root.isDrawStyleId(root.selectedStyleId)
        return root.selectedCount() > 0 || root.autoStyleSelected
            || (root.activeDrawMode() && root.drawMotionAvailable)
    }

    function itemsCountText(count) {
        var value = String(count)
        var templateText = (void i18n.revision, i18n.t("style_manager.items_count", "{count} mục"))
        if (String(templateText).indexOf("{count}") >= 0)
            return String(templateText).replace("{count}", value)
        return value + " " + templateText
    }

    function bulkPreviewCandidates(onlyMissing) {
        var candidates = []
        for (var i = 0; i < root.styles.length; i++) {
            var item = root.styles[i] || ({})
            if (!itemId(item).length)
                continue
            if (itemId(item) === "__camera_auto__")
                continue
            if (!itemPrompt(item).trim().length)
                continue
            if (Boolean(onlyMissing) && root.itemHasPreview(item))
                continue
            candidates.push(item)
        }
        return candidates
    }

    function requestBulkPreview(onlyMissing) {
        var items = bulkPreviewCandidates(Boolean(onlyMissing))
        if (!items.length) {
            showFeedback(
                (void i18n.revision, i18n.t("style_manager.bulk_nothing_title", "Nothing to generate")),
                Boolean(onlyMissing)
                    ? (void i18n.revision, i18n.t("style_manager.bulk_nothing_missing_msg", "All previewable styles already have previews."))
                    : (void i18n.revision, i18n.t("style_manager.bulk_nothing_msg", "No style previews qualified for this batch."))
            )
            return
        }
        root.pendingBulkItems = items
        root.pendingBulkOnlyMissing = Boolean(onlyMissing)
        bulkPreviewConfirmDialog.open()
    }

    function metadataText() {
        if (!itemId(root.currentItem).length)
            return ""
        return [
            "ID: " + itemId(root.currentItem),
            "Source: " + String((root.currentItem || {}).source || "system"),
            "",
            itemPrompt(root.currentItem)
        ].join("\n")
    }

    function requestDeleteCurrent() {
        if (!Boolean((root.currentItem || {}).can_delete))
            return
        var id = itemId(root.currentItem)
        if (!id.length)
            return
        root.pendingDeleteId = id
        root.pendingDeleteName = displayName(root.currentItem)
        deleteConfirmDialog.open()
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || (void i18n.revision, i18n.t("style_manager.feedback_title", "Style Manager")))
        root.feedbackMessage = String(message || "")
        if (root.feedbackMessage.length > 0)
            feedbackDialog.open()
    }

    function applyPreviewInfoResult(result) {
        var payload = result || ({})
        // Loading preview info is passive (runs on every selection change). A
        // "not found / missing" result just means no preview has been generated
        // yet — show the empty panel state, never a modal. Popping "Preview
        // unavailable" here interrupts the user for something they haven't done.
        if (payload.ok === false) {
            root.previewState = ({})
            root.previewMessage = ""
            return false
        }
        root.previewState = payload
        root.previewMessage = String(payload.message || payload.error || "")
        return true
    }

    function applyGeneratePreviewResult(result) {
        var payload = result || ({})
        if (payload.preview_state)
            root.previewState = payload.preview_state
        root.previewMessage = String(payload.message || payload.error || "")
        if (payload.ok === false) {
            showFeedback(
                (void i18n.revision, i18n.t("style_manager.preview_generate_failed", "Preview generation failed")),
                root.previewMessage || String(payload.code || (void i18n.revision, i18n.t("style_manager.preview_generate_failed_generic", "Could not generate preview for this style.")))
            )
            return false
        }
        return true
    }

    function startPreviewCampaignPolling(campaignId) {
        var id = String(campaignId || "")
        if (!id.length)
            return
        root.previewPollCampaignId = id
        root.previewPollTicks = 0
        previewCampaignTimer.restart()
    }

    function pollPreviewCampaignOnce() {
        if (!root.previewPollCampaignId.length) {
            previewCampaignTimer.stop()
            return
        }
        root.previewPollTicks += 1
        // Server-side this finalizes any landed PNG → WebP for completed rows.
        var progress = masterOptionsController.stylePreviewCampaignProgress(root.previewPollCampaignId)
        // Re-resolve preview paths so freshly-saved images appear in the grid.
        masterOptionsController.refreshStyles(root.searchText || "")
        var pending = Number((progress || {}).queued || 0) + Number((progress || {}).running || 0)
        if (pending <= 0 || root.previewPollTicks >= 80) {
            previewCampaignTimer.stop()
            root.previewPollCampaignId = ""
        }
    }

    Timer {
        id: previewCampaignTimer
        interval: 3000
        repeat: true
        onTriggered: root.pollPreviewCampaignOnce()
    }

    function applyBulkPreviewResult(result, refreshedPreview) {
        var payload = result || ({})
        if (refreshedPreview)
            root.previewState = refreshedPreview
        root.previewMessage = String(payload.message || payload.error || "")
        if (payload.ok === false) {
            showFeedback(
                (void i18n.revision, i18n.t("style_manager.bulk_preview_failed", "Bulk preview failed")),
                root.previewMessage || String(payload.code || (void i18n.revision, i18n.t("style_manager.bulk_preview_failed_generic", "Could not generate style previews.")))
            )
            return false
        }
        if (payload.campaign_id)
            root.startPreviewCampaignPolling(payload.campaign_id)
        showFeedback(
            payload.code === "master_config_style_bulk_preview_queued"
                ? (void i18n.revision, i18n.t("style_manager.bulk_queued_title", "Bulk preview queued"))
                : (void i18n.revision, i18n.t("style_manager.bulk_finished_title", "Bulk preview finished")),
            root.previewMessage || (void i18n.revision, i18n.t("style_manager.bulk_finished_msg", "Bulk preview finished."))
        )
        return true
    }

    function applyTopicGenerateResult(result) {
        var payload = result || ({})
        var message = String(payload.message || payload.error || payload.code || "")
        root.previewMessage = message
        if (payload.ok === false) {
            showFeedback(
                (void i18n.revision, i18n.t("style_manager.topic_generate_failed", "Tạo style tree thất bại")),
                message || (void i18n.revision, i18n.t("style_manager.topic_generate_failed_generic", "Không tạo được chủ đề style."))
            )
            return false
        }
        var topic = payload.topic || ({})
        root.activeBucketIndex = root.bucketIndexForKey("topic")
        root.selectedTopicFilter = String(topic.id || "")
        root.selectedTopicGroupFilter = ""
        root.refreshBucket()
        showFeedback(
            (void i18n.revision, i18n.t("style_manager.topic_generate_done", "Đã lưu style tree")),
            message || (void i18n.revision, i18n.t("style_manager.topic_generate_done_msg", "Đã lưu các sub framework của chủ đề."))
        )
        return true
    }

    function applyToggleFavoriteResult(result) {
        var payload = result || ({})
        var message = String(payload.message || "")
        if (message.length > 0)
            root.previewMessage = message
        if (payload.ok === false) {
            showFeedback((void i18n.revision, i18n.t("style_manager.favorite_failed", "Favorite update failed")),
                         message || String(payload.error || "Favorite update failed"))
            return
        }
        if (root.selectedId.length > 0)
            root.selectFromCurrentId()
    }

    function applyDeleteResult(result) {
        var payload = result || ({})
        var deletedId = String(payload.style_id || "")
        var message = String(payload.message || "")
        if (message.length > 0)
            root.previewMessage = message
        if (payload.ok === false || payload.deleted !== true) {
            showFeedback((void i18n.revision, i18n.t("style_manager.delete_failed", "Delete failed")),
                         message || String(payload.error || "Delete failed"))
            return
        }
        if (deletedId.length > 0 && root.selectedId === deletedId) {
            if (payload.restored_base !== true) {
                if (itemKind(root.currentItem) === "camera")
                    root.selectedCameraId = ""
                else {
                    root.selectedStyleId = ""
                }
                root.selectedId = ""
                root.currentItem = ({})
                root.previewState = ({})
            } else {
                root.selectFromCurrentId()
            }
        }
        showFeedback((void i18n.revision, i18n.t("style_manager.delete_done", "Delete complete")),
                     message || (void i18n.revision, i18n.t("style_manager.delete_done_msg", "Style updated.")))
    }

    function requestDeleteTopic(row) {
        var data = row || ({})
        root.pendingDeleteTopicId = String(data.topic_id || "")
        root.pendingDeleteTopicName = String(data.name || "")
        if (root.pendingDeleteTopicId.length > 0)
            deleteTopicConfirmDialog.open()
    }

    function applyDeleteTopicResult(result) {
        var payload = result || ({})
        var message = String(payload.message || "")
        if (message.length > 0)
            root.previewMessage = message
        if (payload.ok === false) {
            showFeedback((void i18n.revision, i18n.t("style_manager.delete_failed", "Delete failed")),
                         message || String(payload.error || "Delete failed"))
            return
        }
        if (root.selectedTopicFilter === String(payload.topic_id || ""))
            root.selectTopicTreeRow(({}))
        showFeedback((void i18n.revision, i18n.t("style_manager.delete_done", "Delete complete")),
                     message || (void i18n.revision, i18n.t("style_manager.delete_done_msg", "Style updated.")))
    }

    function applySelection() {
        var count = root.selectedCount()
        if (count <= 0 && !root.autoStyleSelected
                && !(root.activeDrawMode() && root.drawMotionAvailable))
            return
        if (root.drawMotionAvailable && root.drawMotionEnabled
                && !root.itemHasNativeDrawContract(root.itemById(root.selectedStyleId))) {
            root.showFeedback(
                (void i18n.revision, i18n.t("style_manager.draw_style_required_title", "Cần Draw Style")),
                (void i18n.revision, i18n.t("style_manager.draw_style_required", "Chọn một Draw Style ở tab Draw / VideoScribe, hoặc tắt Draw."))
            )
            return
        }
        if (count >= 2 && !root.confirmApplyChecked) {
            applyConfirmDialog.open()
            return
        }
        root.applyRequested(root.selectionPayload())
    }

    // Deterministic id for a structural+surface style combo preview. MUST match
    // MasterOptionsService._combo_preview_id so the saved image resolves.
    function comboPreviewId() {
        if (!root.isComboSelection())
            return ""
        var raw = root.selectedStyleId + "__" + root.selectedSurfaceStyleId
        var safe = raw.replace(/[^A-Za-z0-9_-]+/g, "_").replace(/^_+|_+$/g, "")
        return safe.length ? "combo__" + safe : ""
    }

    function isComboSelection() {
        return root.selectedStyleId.length > 0 && root.selectedSurfaceStyleId.length > 0
            && root.selectedStyleId !== root.selectedSurfaceStyleId
    }

    function canGenerateSelectionPreview() {
        if (root.isComboSelection())
            return true
        return itemId(root.currentItem).length > 0 && itemPrompt(root.currentItem).length > 0
    }

    function requestSelectionPreview() {
        if (root.previewGenerationBusy)
            return
        // Two+ styles → fuse via AI into one combined image; otherwise single.
        if (root.isComboSelection()) {
            root.comboPreviewRequested(root.selectionPayload())
            return
        }
        if (itemId(root.currentItem).length > 0 && itemPrompt(root.currentItem).length > 0)
            root.generatePreviewRequested(root.currentItem)
    }

    function motionPreviewPath() {
        var state = root.motionPreviewState || ({})
        return String(state.gif_path || state.path || "")
    }

    function hasMotionPreview() {
        var state = root.motionPreviewState || ({})
        return Boolean(state.exists && root.motionPreviewPath().length)
    }

    function motionPreviewExplanation() {
        return String((root.motionPreviewState || {}).explanation || "")
    }

    function motionPreviewActorLabel() {
        var mode = String((root.motionPreviewState || {}).actor_mode || "")
        if (mode === "move")
            return "Move"
        if (mode === "pen")
            return "Pen"
        if (mode === "hand_pen")
            return "Hand+Pen"
        return root.actorModeLabel(root.actorModeForDrawStyle(root.selectedStyleId))
    }

    function scheduleMotionPreview(force) {
        if (!root.activeDrawMode() || !root.itemHasNativeDrawContract(root.currentItem)) {
            root.motionPreviewState = ({})
            return
        }
        motionPreviewTimer.force = !!force
        motionPreviewTimer.restart()
    }

    function requestMotionPreview(force) {
        var styleId = root.itemId(root.currentItem)
        if (!styleId.length || !root.itemHasNativeDrawContract(root.currentItem)) {
            root.motionPreviewState = ({})
            return
        }
        root.motionPreviewRequested(
            styleId,
            String(root.selectedActorMode || "auto"),
            String(root.selectedHandAssetId || "auto"),
            !!force
        )
    }

    function applyMotionPreviewResult(result) {
        var payload = result || ({})
        var wantedId = root.itemId(root.currentItem)
        if (wantedId.length && String(payload.style_id || "") !== wantedId)
            return false
        root.motionPreviewState = payload
        if (String(payload.message || "").length)
            root.previewMessage = String(payload.message)
        return payload.ok !== false
    }

    Timer {
        id: motionPreviewTimer
        interval: 180
        repeat: false
        property bool force: false
        onTriggered: root.requestMotionPreview(force)
    }

    function requestPreview() {
        // A multi-style selection previews the fused combo image (resolved by its
        // deterministic id), not any single framework.
        if (root.isComboSelection()) {
            root.previewInfoRequested(root.comboPreviewId())
            return
        }
        if (!itemId(root.currentItem).length) {
            root.previewState = ({})
            root.previewMessage = ""
            return
        }
        var localPreview = root.previewStateForItem(root.currentItem)
        if (Boolean(((localPreview || {}).preview || {}).exists)) {
            root.previewState = localPreview
            root.previewMessage = String(localPreview.message || "")
            return
        }
        root.previewInfoRequested(itemId(root.currentItem))
    }

    background: Rectangle {
        color: VfTheme.canvas
        radius: VfTheme.radiusPanel
        border.width: 1
        border.color: VfTheme.borderStrong
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(10)
        spacing: VfTheme.dp(8)

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(48)
            spacing: VfTheme.dp(10)

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(40)
                Layout.preferredHeight: VfTheme.dp(40)
                radius: VfTheme.dp(10)
                color: VfTheme.blueFill
                border.width: 1
                border.color: VfTheme.blueBorderSoft

                VfAppIcon {
                    anchors.centerIn: parent
                    name: "artist-palette"
                    size: VfTheme.dp(22)
                    color: VfTheme.primary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(2)

                Label {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("style_manager.dialog_title", "Chọn Style Framework"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(18)
                    font.weight: VfTheme.weightTitle
                    elide: Text.ElideRight
                }

                Label {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("style_manager.header_hint", "Chọn style chủ đề, kết hợp thêm render style như Realistic/Cinematic. Góc máy do AI tự viết theo từng cảnh."))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    elide: Text.ElideRight
                }
            }

            // Dedicated icon-only close button. A VfButton with empty text reserves
            // label padding and renders an off-centre glyph; this stays a crisp
            // square with a clear hover state.
            Rectangle {
                Layout.preferredWidth: VfTheme.dp(36)
                Layout.preferredHeight: VfTheme.dp(36)
                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                radius: VfTheme.dp(8)
                color: closeHover.containsMouse ? "#FEE2E2" : VfTheme.surfaceSoft
                border.width: 1
                border.color: closeHover.containsMouse ? "#EF4444" : VfTheme.borderBox

                Behavior on color { ColorAnimation { duration: 110 } }
                Behavior on border.color { ColorAnimation { duration: 110 } }

                VfAppIcon {
                    anchors.centerIn: parent
                    name: "cross-mark"
                    size: VfTheme.dp(16)
                    framed: false
                }

                MouseArea {
                    id: closeHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.reject()
                }

                ToolTip.visible: closeHover.containsMouse
                ToolTip.text: (void i18n.revision, i18n.t("common.close", "Đóng"))
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(54)
            radius: VfTheme.dp(8)
            color: VfTheme.surfaceSoft
            border.width: 1
            border.color: VfTheme.borderBox

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(8)
                spacing: VfTheme.dp(8)

                Label {
                    text: (void i18n.revision, i18n.t("style_manager.selected_label", "Đã chọn"))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: VfTheme.weightControl
                }

                SelectionChip {
                    slotKey: "primary_style"
                    iconName: "artist-palette"
                    labelText: (void i18n.revision, i18n.t("style_manager.primary_style_label", "Style chính"))
                    valueText: root.selectedNameForSlot("primary_style")
                    selected: root.selectedStyleId.length > 0
                    accent: VfTheme.primary
                }

                SelectionChip {
                    slotKey: "surface_style"
                    iconName: "artist-palette"
                    labelText: (void i18n.revision, i18n.t("style_manager.surface_style_label", "Render style"))
                    valueText: root.selectedNameForSlot("surface_style")
                    selected: root.selectedSurfaceStyleId.length > 0
                    accent: VfTheme.violet
                    visible: root.comboEnabled || root.selectedSurfaceStyleId.length > 0
                }

                Rectangle {
                    visible: root.selectedCount() >= 2
                    Layout.preferredHeight: VfTheme.dp(30)
                    Layout.minimumWidth: warningText.implicitWidth + VfTheme.dp(24)
                    radius: VfTheme.dp(15)
                    color: VfTheme.amberFill
                    border.width: 1
                    border.color: VfTheme.amberBorderSoft

                    Label {
                        id: warningText
                        anchors.centerIn: parent
                        text: (void i18n.revision, i18n.t("style_manager.preview_required_pill", "Cần kiểm tra preview"))
                        color: VfTheme.amberText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        font.weight: VfTheme.weightStrong
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    id: comboToggle
                    objectName: "smCombo"
                    visible: true
                    Layout.preferredHeight: VfTheme.chipHeight
                    Layout.preferredWidth: visible ? implicitWidth : 0
                    implicitWidth: comboToggleRow.implicitWidth + VfTheme.dp(26)
                    radius: VfTheme.radiusControl
                    // Always violet so it stands out from the grey selection chips —
                    // soft-filled outline when off, solid when on.
                    color: root.comboEnabled ? VfTheme.violet : VfTheme.violetFill
                    border.width: root.comboEnabled ? 0 : 1
                    border.color: VfTheme.violetBorder

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Row {
                        id: comboToggleRow
                        anchors.centerIn: parent
                        spacing: VfTheme.dp(7)

                        Rectangle {
                            width: VfTheme.dp(9)
                            height: VfTheme.dp(9)
                            radius: width / 2
                            anchors.verticalCenter: parent.verticalCenter
                            color: root.comboEnabled ? "#FFFFFF" : VfTheme.violetBorder
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: (void i18n.revision, i18n.t("style_manager.combo_toggle", "Style kết hợp"))
                            color: root.comboEnabled ? "#FFFFFF" : VfTheme.violetText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                            font.weight: VfTheme.weightStrong
                        }
                    }

                    MouseArea {
                        id: comboToggleMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.setComboEnabled(!root.comboEnabled)
                    }
                    ToolTip.visible: comboToggleMouse.containsMouse
                    ToolTip.text: (void i18n.revision, i18n.t("style_manager.combo_toggle_hint", "Bật để ghép Style chính + Render style. Tắt = chỉ chọn 1 style."))
                    ToolTip.delay: 350
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: VfTheme.dp(10)

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: VfTheme.dp(8)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(8)

                    Repeater {
                        model: root.visibleBucketSpecs // perf-lint: disable=R2 fixed three-tab projection

                        BucketTab {
                            objectName: "smBucket_" + modelData.key
                            labelText: modelData.label
                            active: root.activeBucketKey() === modelData.key
                            iconName: modelData.key === "topic"
                                ? "light-bulb" : (modelData.key === "draw" ? "pencil" : "artist-palette")
                            onClicked: root.activeBucketIndex = root.bucketIndexForKey(modelData.key)
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(50)
                    radius: VfTheme.dp(8)
                    color: VfTheme.surface
                    border.width: 1
                    border.color: VfTheme.borderBox

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(7)
                        spacing: VfTheme.dp(7)

                        PyButton {
                            actionId: "style_manager.add"
                            text: (void i18n.revision, i18n.t("style_manager.btn_new", "Tạo mới"))
                            compact: true
                            minWidth: VfTheme.dp(92)
                            onClicked: root.addRequested(root.activeDrawMode() ? "draw" : "style")
                        }

                        PyButton {
                            actionId: "style_manager.edit"
                            text: (void i18n.revision, i18n.t("style_manager.btn_edit", "Sửa"))
                            compact: true
                            minWidth: VfTheme.dp(76)
                            enabled: Boolean((root.currentItem || {}).can_edit) && itemId(root.currentItem).length > 0
                            onClicked: root.editRequested(root.currentItem)
                        }

                        PyButton {
                            actionId: "style_manager.delete"
                            danger: true
                            text: (void i18n.revision, i18n.t("style_manager.btn_delete", "Xóa"))
                            compact: true
                            minWidth: VfTheme.dp(76)
                            enabled: Boolean((root.currentItem || {}).can_delete) && itemId(root.currentItem).length > 0
                            onClicked: root.requestDeleteCurrent()
                        }

                        PyButton {
                            actionId: isFavorite(root.currentItem)
                                ? "style_manager.unfavorite"
                                : "style_manager.favorite"
                            text: isFavorite(root.currentItem)
                                ? (void i18n.revision, i18n.t("style_manager.btn_unfavorite", "Bỏ yêu thích"))
                                : (void i18n.revision, i18n.t("style_manager.btn_favorite", "Yêu thích"))
                            compact: true
                            minWidth: VfTheme.dp(104)
                            enabled: itemId(root.currentItem).length > 0
                            onClicked: root.toggleFavoriteRequested(itemId(root.currentItem))
                        }

                        TextField {
                            id: searchInput
                            objectName: "smSearch"
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(34)
                            placeholderText: (void i18n.revision, i18n.t("style_manager.search_placeholder", "Tìm theo tên hoặc id..."))
                            text: root.searchText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            onTextChanged: root.searchText = text
                            onAccepted: root.refreshRequested(text)
                            background: Rectangle {
                                color: VfTheme.surface
                                border.width: 1
                                border.color: VfTheme.borderStrong
                                radius: VfTheme.dp(7)
                            }
                        }

                        NoScrollComboBox {
                            objectName: "smSort"
                            Layout.preferredWidth: VfTheme.dp(132)
                            Layout.preferredHeight: VfTheme.dp(34)
                            model: [
                                (void i18n.revision, i18n.t("style_manager.sort_az", "A -> Z")),
                                (void i18n.revision, i18n.t("style_manager.sort_za", "Z -> A")),
                                (void i18n.revision, i18n.t("style_manager.sort_recent", "Mới dùng"))
                            ]
                            currentIndex: root.sortIndex
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            onCurrentIndexChanged: root.sortIndex = currentIndex
                        }

                        CheckBox {
                            objectName: "smFavOnly"
                            text: (void i18n.revision, i18n.t("style_manager.fav_only", "Chỉ yêu thích"))
                            checked: root.favoriteOnly
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            onToggled: root.favoriteOnly = checked
                        }
                    }
                }

                Rectangle {
                    visible: root.drawMotionAvailable
                        && (root.activeDrawMode() || root.drawMotionEnabled)
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? VfTheme.dp(70) : 0
                    radius: VfTheme.dp(8)
                    color: VfTheme.amberFill
                    border.width: 1
                    border.color: VfTheme.amberBorderSoft
                    clip: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(9)
                        spacing: VfTheme.dp(10)

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(5)

                            Label {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("style_manager.draw_title", "Draw / VideoScribe"))
                                color: VfTheme.amberText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(13)
                                font.weight: VfTheme.weightStrong
                            }

                            Label {
                                Layout.fillWidth: true
                                text: root.drawMotionAvailable
                                    ? (void i18n.revision, i18n.t("style_manager.draw_hint", "Mỗi style khóa 1 họ: Move chỉ Move; Hand+Pen và Pen đổi được với nhau. Preview bên cạnh phát đúng họ đó."))
                                    : (void i18n.revision, i18n.t("style_manager.draw_unavailable", "Quản lý Draw Style và actor mặc định tại đây. Muốn bật dựng, mở từ Clone/Audio ở đầu ra Ảnh."))
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                wrapMode: Text.WordWrap
                            }

                        }

                        MotionHandSelector {
                            objectName: "smActorModeSelector"
                            options: root.visibleActorModeOptions()
                            value: root.actorModeAllowedForStyle(root.selectedStyleId, root.selectedActorMode)
                                ? root.selectedActorMode : "auto"
                            minWidth: VfTheme.dp(150)
                            enabled: root.selectedStyleId.length > 0
                            tooltip: (void i18n.revision, i18n.t(
                                "style_manager.actor_mode_hint",
                                "Auto dùng mode đã gắn cho style; có thể ép Move, Tay + bút hoặc Chỉ bút cho job này."
                            ))
                            onSelected: function(value) {
                                root.selectedActorMode = String(value || "auto")
                                var styleId = String(root.selectedStyleId || "")
                                if (!styleId.length)
                                    return
                                if (root.isDrawStyleId(styleId) && root.selectedActorMode !== "auto")
                                    root.saveDrawProfileRequested(
                                        styleId,
                                        root.selectedActorMode,
                                        String(root.selectedHandAssetId || "auto"))
                                var wantedRole = root.actorRoleForMode(
                                    root.actorModeForDrawStyle(styleId))
                                var current = root.handOptionByValue(root.selectedHandAssetId)
                                if (String(current.motion_role || "") !== wantedRole)
                                    root.selectedHandAssetId = "auto"
                            }
                        }

                        PyButton {
                            objectName: "smHandsPenButton"
                            actionId: "style_manager.hand_pen"
                            iconName: "pencil"
                            text: (void i18n.revision, i18n.t("style_manager.hand_pen_button", "Hands / Pen"))
                            compact: true
                            minWidth: VfTheme.dp(126)
                            enabled: root.isDrawStyleId(root.selectedStyleId)
                                && (root.handAssetOptions || []).length > 0
                            tooltip: {
                                var selected = root.itemById(root.selectedStyleId)
                                if (!root.itemIsDrawStyle(selected))
                                    return (void i18n.revision, i18n.t("style_manager.hand_pen_select_style", "Chọn một Draw Style trước."))
                                if (!root.drawStyleSupportsVisibleHand(selected))
                                    return (void i18n.revision, i18n.t("style_manager.hand_free_style_short", "Dựng lớp/texture — không dùng tay"))
                                return (void i18n.revision, i18n.t("style_manager.hand_pen_current", "Tay / bút hiện tại"))
                                    + ": " + root.selectedHandLabel()
                            }
                            onClicked: root.openHandLibraryForSelectedDrawStyle()
                        }
                    }
                }

                MotionHandLibraryDialog {
                    id: handLibraryDialog
                    options: root.handAssetOptions || [] // perf-lint: disable=R2 small static hand/tool catalog
                    roleFilter: root.actorRoleForMode(
                        root.actorModeForDrawStyle(root.pendingHandStyleId || root.selectedStyleId))
                    onAssetChosen: function(assetId) {
                        var styleId = String(root.pendingHandStyleId || root.selectedStyleId || "")
                        var selectedAsset = String(assetId || "auto")
                        root.selectedHandAssetId = selectedAsset
                        var manual = String(root.selectedActorMode || "auto")
                        if (manual === "auto"
                                || manual === root.defaultActorModeForDrawStyle(styleId)) {
                            root.setHandForDrawStyle(styleId, selectedAsset)
                            root.saveHandBindingRequested(styleId, selectedAsset)
                        }
                        root.pendingHandStyleId = ""
                    }
                }

                Rectangle {
                    visible: root.activeTopicMode()
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? VfTheme.dp(86) : 0
                    radius: VfTheme.dp(8)
                    color: VfTheme.violetFill
                    border.width: 1
                    border.color: VfTheme.violetBorderSoft

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(10)
                        spacing: VfTheme.dp(8)

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(5)

                            Label {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("style_manager.topic_generate_title", "Tạo style tree từ một chủ đề tổng"))
                                color: VfTheme.violetText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                font.weight: VfTheme.weightStrong
                                elide: Text.ElideRight
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(8)

                                TextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: VfTheme.dp(34)
                                    placeholderText: (void i18n.revision, i18n.t("style_manager.topic_placeholder", "Ví dụ: Phật giáo, Cyberpunk, Ẩm thực Việt..."))
                                    text: root.topicSeedText
                                    enabled: !root.topicGenerationBusy
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(12)
                                    onTextChanged: root.topicSeedText = text
                                    onAccepted: root.requestTopicGeneration()
                                    background: Rectangle {
                                        color: VfTheme.surface
                                        border.width: 1
                                        border.color: parent.activeFocus ? VfTheme.violetBorder : VfTheme.violetBorderSoft
                                        radius: VfTheme.dp(7)
                                    }
                                }

                                TextField {
                                    Layout.preferredWidth: VfTheme.dp(78)
                                    Layout.preferredHeight: VfTheme.dp(34)
                                    placeholderText: "96"
                                    text: root.topicTargetCountText
                                    enabled: !root.topicGenerationBusy
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(12)
                                    horizontalAlignment: TextInput.AlignHCenter
                                    validator: IntValidator { bottom: 8; top: 128 }
                                    onTextChanged: root.topicTargetCountText = text
                                    onAccepted: root.requestTopicGeneration()
                                    background: Rectangle {
                                        color: VfTheme.surface
                                        border.width: 1
                                        border.color: parent.activeFocus ? VfTheme.violetBorder : VfTheme.violetBorderSoft
                                        radius: VfTheme.dp(7)
                                    }
                                }

                                PyButton {
                                    actionId: "style_manager.topic_generate"
                                    Layout.preferredHeight: VfTheme.dp(34)
                                    text: root.topicGenerationBusy
                                        ? (void i18n.revision, i18n.t("style_manager.topic_generating", "Đang đề xuất..."))
                                        : (void i18n.revision, i18n.t("style_manager.topic_generate", "AI đề xuất style"))
                                    compact: true
                                    emphasized: true
                                    minWidth: VfTheme.dp(148)
                                    enabled: !root.topicGenerationBusy
                                    onClicked: root.requestTopicGeneration()
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: VfTheme.dp(8)
                    color: VfTheme.surface
                    border.width: 1
                    border.color: VfTheme.borderBox

                    Rectangle {
                        id: topicTreePanel
                        visible: root.activeTopicMode()
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: VfTheme.dp(8)
                        width: visible ? VfTheme.dp(230) : 0
                        radius: VfTheme.dp(8)
                        color: VfTheme.surfaceSoft
                        border.width: 1
                        border.color: VfTheme.border
                        clip: true

                        ListView {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(6)
                            clip: true
                            reuseItems: true
                            model: root.topicTreeRowsCache

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: VfTheme.dp(34)
                                radius: VfTheme.dp(7)
                                color: root.topicTreeRowSelected(modelData) ? VfTheme.blueFill : (topicRowMouse.containsMouse ? VfTheme.surface : "transparent")
                                border.width: root.topicTreeRowSelected(modelData) ? 1 : 0
                                border.color: VfTheme.blueBorderSoft

                                MouseArea {
                                    id: topicRowMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.selectTopicTreeRow(modelData)
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(8) + Number(modelData.level || 0) * VfTheme.dp(14)
                                    anchors.rightMargin: VfTheme.dp(8)
                                    spacing: VfTheme.dp(6)

                                    VfAppIcon {
                                        name: modelData.type === "group" ? "artist-palette" : "light-bulb"
                                        size: VfTheme.dp(14)
                                        framed: false
                                        color: modelData.type === "group" ? VfTheme.violetText : VfTheme.primary
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: String(modelData.name || "")
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(11)
                                        font.weight: modelData.type === "group" ? VfTheme.weightRegular : VfTheme.weightStrong
                                        elide: Text.ElideRight
                                    }

                                    Label {
                                        text: String(modelData.count || 0)
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(10)
                                    }

                                    VfAppIcon {
                                        name: "cross-mark"
                                        size: VfTheme.dp(12)
                                        framed: false
                                        color: deleteTopicMouse.containsMouse ? VfTheme.redText : VfTheme.textSubtle
                                        visible: modelData.type === "topic"
                                            && String(modelData.topic_id || "").length > 0
                                            && (topicRowMouse.containsMouse || deleteTopicMouse.containsMouse)

                                        MouseArea {
                                            id: deleteTopicMouse
                                            anchors.fill: parent
                                            anchors.margins: -VfTheme.dp(4)
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.requestDeleteTopic(modelData)
                                        }
                                    }
                                }
                            }

                            ScrollBar.vertical: ScrollBar { }
                        }
                    }

                    GridView {
                        id: styleGrid
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(8)
                        anchors.leftMargin: root.activeTopicMode() ? VfTheme.dp(246) : VfTheme.dp(8)
                        clip: true
                        reuseItems: true
                        model: root.bucketItems
                        readonly property int columnCount: width >= VfTheme.dp(960) ? 4 : (width >= VfTheme.dp(700) ? 3 : 2)
                        cellWidth: Math.max(VfTheme.dp(210), Math.floor(width / Math.max(1, columnCount)))
                        cellHeight: VfTheme.dp(244)

                        delegate: FrameworkCard {
                            width: styleGrid.cellWidth - VfTheme.dp(10)
                            height: styleGrid.cellHeight - VfTheme.dp(10)
                            cardItem: modelData
                        }

                        ScrollBar.vertical: ScrollBar { }
                    }

                    Label {
                        anchors.centerIn: parent
                        visible: root.bucketItems.length <= 0
                        text: (void i18n.revision, i18n.t("style_manager.empty_bucket", "Không có framework phù hợp."))
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(8)

                    PyButton {
                        actionId: "style_manager.clear"
                        text: (void i18n.revision, i18n.t("style_manager.btn_clear", "Bỏ chọn tab này"))
                        compact: true
                        minWidth: VfTheme.dp(118)
                        onClicked: root.clearCurrentSelection()
                    }

                    Label {
                        Layout.fillWidth: true
                        text: root.footerSummary()
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        elide: Text.ElideRight
                    }

                    Label {
                        text: root.itemsCountText(root.bucketItems.length)
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                    }
                }
            }

            PreviewPanel {
                Layout.preferredWidth: Math.max(VfTheme.dp(360), Math.min(VfTheme.dp(430), root.width * 0.29))
                Layout.fillHeight: true
            }
        }

        RowLayout { // perf-lint: disable=R5 desktop dialog footer has a bounded 1500dp design width
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            Label {
                Layout.fillWidth: true
                text: root.statusMessage || (void i18n.revision, i18n.t("style_manager.footer_hint", "Grid card giúp kiểm tra đúng style/camera trước khi áp dụng."))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                elide: Text.ElideRight
            }

            PyButton {
                actionId: "style_manager.bulk_missing"
                text: (void i18n.revision, i18n.t("style_manager.btn_bulk_missing", "Tạo preview còn thiếu"))
                compact: true
                minWidth: VfTheme.dp(156)
                enabled: !root.previewGenerationBusy && root.bulkPreviewCandidates(true).length > 0
                onClicked: root.requestBulkPreview(true)
            }

            PyButton {
                actionId: "style_manager.bulk_all"
                text: (void i18n.revision, i18n.t("style_manager.btn_bulk_all", "Tạo lại tất cả"))
                compact: true
                minWidth: VfTheme.dp(126)
                enabled: !root.previewGenerationBusy && root.bulkPreviewCandidates(false).length > 0
                onClicked: root.requestBulkPreview(false)
            }

            PyButton {
                actionId: "style_manager.clear"
                text: (void i18n.revision, i18n.t("style_manager.btn_clear_all", "Bỏ chọn tất cả"))
                compact: true
                minWidth: VfTheme.dp(128)
                onClicked: root.clearAllSelections()
            }

            PyButton {
                actionId: "style_manager.cancel"
                text: (void i18n.revision, i18n.t("style_manager.btn_cancel", "Hủy"))
                compact: true
                minWidth: VfTheme.dp(76)
                onClicked: root.reject()
            }

            PyButton {
                actionId: "style_manager.apply"
                text: (void i18n.revision, i18n.t("style_manager.btn_apply", "Áp dụng"))
                compact: true
                minWidth: VfTheme.dp(96)
                emphasized: true
                enabled: root.canApplySelection()
                onClicked: root.applySelection()
            }
        }
    }

    component PyButton: VfButton {
        id: pyButton

        property int minWidth: VfTheme.dp(92)
        property bool danger: false
        property bool emphasized: false
        property string toneOverride: ""

        Layout.minimumWidth: minWidth
        implicitHeight: VfTheme.dp(38)
        tone: toneOverride.length ? toneOverride : (danger ? "danger" : (emphasized ? "primary" : "neutral"))
    }

    component SelectionChip: Rectangle {
        id: chip

        property string slotKey: "primary_style"
        property string labelText: ""
        property string valueText: ""
        property string iconName: "artist-palette"
        property bool selected: false
        property color accent: VfTheme.primary

        Layout.preferredWidth: Math.max(VfTheme.dp(190), Math.min(VfTheme.dp(260), root.width * 0.17))
        Layout.preferredHeight: VfTheme.dp(34)
        radius: VfTheme.dp(17)
        color: selected ? VfTheme.surface : VfTheme.surfaceSoft
        border.width: 1
        border.color: selected ? accent : VfTheme.borderStrong

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(10)
            anchors.rightMargin: VfTheme.dp(8)
            spacing: VfTheme.dp(6)

            VfAppIcon {
                name: chip.iconName
                size: VfTheme.dp(15)
                color: chip.selected ? chip.accent : VfTheme.textSubtle
            }

            Label {
                text: chip.labelText + ":"
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                font.weight: VfTheme.weightStrong
            }

            Label {
                Layout.fillWidth: true
                text: chip.selected ? chip.valueText : (void i18n.revision, i18n.t("style_manager.none_selected", "Chưa chọn"))
                color: chip.selected ? VfTheme.text : VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(18)
                Layout.preferredHeight: VfTheme.dp(18)
                visible: chip.selected
                radius: VfTheme.dp(9)
                color: VfTheme.surfaceSoft
                border.width: 1
                border.color: VfTheme.borderStrong

                VfAppIcon {
                    anchors.centerIn: parent
                    name: "cross-mark"
                    size: VfTheme.dp(10)
                    color: VfTheme.textMuted
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.clearSlot(chip.slotKey)
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: !chip.selected
            cursorShape: Qt.PointingHandCursor
            onClicked: root.jumpToTab(chip.slotKey)
        }
    }

    component BucketTab: Rectangle {
        id: tab

        property string labelText: ""
        property string iconName: "artist-palette"
        property bool active: false
        signal clicked()

        Layout.preferredWidth: VfTheme.dp(190)
        Layout.preferredHeight: VfTheme.dp(38)
        radius: VfTheme.dp(8)
        // Keep border.width constant (1) so switching never shifts the centered
        // content; the active tab is a full primary fill (no underline) so the
        // selected state reads instantly. Transitions make switches feel smooth.
        color: active ? VfTheme.primary : (tabHover.containsMouse ? VfTheme.surface : VfTheme.surfaceSoft)
        border.width: 1
        border.color: active ? VfTheme.primary : (tabHover.containsMouse ? VfTheme.borderStrong : VfTheme.borderBox)

        Behavior on color { ColorAnimation { duration: 130; easing.type: Easing.OutCubic } }
        Behavior on border.color { ColorAnimation { duration: 130; easing.type: Easing.OutCubic } }

        RowLayout {
            anchors.centerIn: parent
            spacing: VfTheme.dp(7)

            VfAppIcon {
                name: tab.iconName
                size: VfTheme.dp(16)
                color: tab.active ? "#FFFFFF" : VfTheme.textSubtle
            }

            Label {
                text: tab.labelText
                color: tab.active ? "#FFFFFF" : (tabHover.containsMouse ? VfTheme.text : VfTheme.textMuted)
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                font.weight: tab.active ? VfTheme.weightStrong : VfTheme.weightControl
            }
        }

        MouseArea {
            id: tabHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tab.clicked()
        }
    }

    component MiniPill: Rectangle {
        id: pill

        property string textValue: ""
        property color fillColor: VfTheme.surfaceSoft
        property color strokeColor: VfTheme.borderStrong
        property color textColor: VfTheme.textMuted

        implicitWidth: label.implicitWidth + VfTheme.dp(14)
        implicitHeight: VfTheme.dp(22)
        radius: VfTheme.dp(11)
        color: fillColor
        border.width: 1
        border.color: strokeColor

        Label {
            id: label
            anchors.centerIn: parent
            text: pill.textValue
            color: pill.textColor
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            font.weight: VfTheme.weightStrong
        }
    }

    component FrameworkCard: Rectangle {
        id: card

        property var cardItem: ({})
        readonly property bool isAutoCard: Boolean((cardItem || {}).__auto_card__)
        readonly property string cardId: root.itemId(cardItem)
        readonly property string cardKind: root.itemKind(cardItem)
        readonly property string role: root.selectionRoleForItem(cardItem)
        readonly property bool selected: isAutoCard ? root.autoStyleSelected : role.length > 0
        readonly property bool current: root.isCurrent(cardItem)
        readonly property bool hasThumb: root.thumbnailUrl(cardItem).length > 0
        readonly property string drawHandAssetId: root.handForDrawStyle(cardId)
        readonly property color accent: cardKind === "camera" ? VfTheme.cyan : (role === "surface_style" ? VfTheme.violet : VfTheme.primary)

        radius: VfTheme.dp(8)
        color: selected ? VfTheme.blueFill : (hoverArea.containsMouse ? VfTheme.blueFill : VfTheme.surface)
        border.width: selected ? 2 : 1
        border.color: selected ? accent : (current ? VfTheme.textSubtle : VfTheme.borderBox)

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: card.isAutoCard ? root.selectAutoStyle() : root.toggleItemSelection(card.cardItem)
        }

        // Auto-style card content (clone only). A distinct, easy-to-spot first card:
        // big palette icon, title, short description, save toggle, and a ✓ when active.
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(12)
            spacing: VfTheme.dp(8)
            visible: card.isAutoCard

            Item { Layout.fillWidth: true; Layout.preferredHeight: VfTheme.dp(6) }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "🎨"
                font.pixelSize: VfTheme.dp(40)
            }

            Label {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("clone.auto_style_source", "🎨 Tự động theo video gốc"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                font.weight: VfTheme.weightStrong
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: (void i18n.revision, i18n.t("clone.auto_style_desc", "AI phân tích style của video gốc và áp cho mọi cảnh — không cần chọn style tay."))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                lineHeight: 1.15
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                visible: card.selected
                text: (void i18n.revision, i18n.t("clone.auto_style_saved_note", "💾 Tự động lưu vào thư viện"))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(8)
            spacing: VfTheme.dp(6)
            visible: !card.isAutoCard

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(118)
                radius: VfTheme.dp(7)
                color: card.hasThumb ? VfTheme.surface : VfTheme.surfaceSoft
                border.width: 1
                border.color: VfTheme.border
                clip: true

                Image {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(4)
                    source: card.hasThumb ? root.thumbnailUrl(card.cardItem) : ""
                    visible: card.hasThumb
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: true
                    smooth: true
                }

                Column {
                    anchors.centerIn: parent
                    spacing: VfTheme.dp(5)
                    visible: !card.hasThumb

                    VfAppIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: card.cardKind === "camera" ? "movie-camera" : "artist-palette"
                        size: VfTheme.dp(30)
                        color: card.accent
                    }

                    Label {
                        width: card.width - VfTheme.dp(32)
                        text: (void i18n.revision, i18n.t("style_manager.preview_placeholder", "Chưa có preview"))
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                }

                MiniPill {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: VfTheme.dp(6)
                    textValue: card.cardKind === "camera"
                        ? (void i18n.revision, i18n.t("style_manager.camera_short", "Camera"))
                        : (void i18n.revision, i18n.t("style_manager.style_short", "Style"))
                    fillColor: card.cardKind === "camera" ? VfTheme.cyanFill : VfTheme.blueFill
                    strokeColor: card.cardKind === "camera" ? VfTheme.cyanBorderSoft : VfTheme.blueBorderSoft
                    textColor: card.cardKind === "camera" ? VfTheme.cyanText : VfTheme.blueText
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: VfTheme.dp(6)
                    width: VfTheme.dp(28)
                    height: VfTheme.dp(28)
                    radius: VfTheme.dp(14)
                    color: VfTheme.surface
                    border.width: 1
                    border.color: root.isFavorite(card.cardItem) ? VfTheme.amberBorderSoft : VfTheme.borderStrong

                    VfAppIcon {
                        anchors.centerIn: parent
                        name: "star"
                        size: VfTheme.dp(15)
                        color: root.isFavorite(card.cardItem) ? "#D97706" : VfTheme.textSubtle
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleFavoriteRequested(card.cardId)
                    }
                }

                Rectangle {
                    visible: card.selected
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: VfTheme.dp(6)
                    width: selectedLabel.implicitWidth + VfTheme.dp(18)
                    height: VfTheme.dp(24)
                    radius: VfTheme.dp(12)
                    color: card.accent

                    Label {
                        id: selectedLabel
                        anchors.centerIn: parent
                        text: card.role === "camera"
                            ? (void i18n.revision, i18n.t("style_manager.camera_short", "Camera"))
                            : (card.role === "surface_style"
                                ? (void i18n.revision, i18n.t("style_manager.surface_style_short", "Render"))
                                : (root.hasTopic(card.cardItem) && !root.itemIsDrawStyle(card.cardItem)
                                    ? (void i18n.revision, i18n.t("style_manager.topic_short", "Chủ đề"))
                                    : (void i18n.revision, i18n.t("style_manager.primary_style_label", "Style chính"))))
                        color: "#FFFFFF"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                        font.weight: VfTheme.weightStrong
                    }
                }

                Rectangle {
                    id: drawToolBadge
                    visible: root.activeDrawMode() && root.itemIsDrawStyle(card.cardItem)
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: VfTheme.dp(6)
                    width: Math.min(parent.width * 0.72, drawToolRow.implicitWidth + VfTheme.dp(14))
                    height: VfTheme.dp(32)
                    radius: VfTheme.dp(16)
                    color: VfTheme.amberFill
                    border.width: 1
                    border.color: VfTheme.amberBorderSoft
                    clip: true

                    Row {
                        id: drawToolRow
                        anchors.centerIn: parent
                        spacing: VfTheme.dp(5)

                        Rectangle {
                            width: VfTheme.dp(27)
                            height: VfTheme.dp(27)
                            radius: VfTheme.dp(13.5)
                            color: "#F7F7F5"
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(2)
                                source: root.handPreviewForDrawStyle(card.cardId)
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                cache: true
                                sourceSize.width: VfTheme.dp(54)
                                sourceSize.height: VfTheme.dp(54)
                            }
                        }

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.handBadgeForDrawStyle(card.cardId)
                            color: VfTheme.amberText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(9)
                            font.weight: VfTheme.weightStrong
                        }
                    }

                    MouseArea {
                        id: drawToolMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }

                    ToolTip.visible: drawToolMouse.containsMouse
                    ToolTip.text: (void i18n.revision, i18n.t("style_manager.bound_hand_tool", "Tay / bút đã gắn"))
                        + ": " + root.handLabelForDrawStyle(card.cardId)
                    ToolTip.delay: 350
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)

                Label {
                    Layout.fillWidth: true
                    text: root.displayName(card.cardItem)
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                MiniPill {
                    textValue: root.isCustom(card.cardItem)
                        ? (void i18n.revision, i18n.t("style_manager.source_custom", "Custom"))
                        : (void i18n.revision, i18n.t("style_manager.source_system", "System"))
                    fillColor: root.isCustom(card.cardItem) ? VfTheme.violetFill : VfTheme.surfaceSoft
                    strokeColor: root.isCustom(card.cardItem) ? VfTheme.violetBorderSoft : VfTheme.border
                    textColor: root.isCustom(card.cardItem) ? VfTheme.violetText : VfTheme.textSubtle
                }
            }

            Label {
                Layout.fillWidth: true
                visible: root.hasTopic(card.cardItem)
                text: root.topicPath(card.cardItem)
                color: VfTheme.violetText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: VfTheme.weightStrong
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.cleanDisplayText(root.itemPrompt(card.cardItem) || root.displayName(card.cardItem))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                lineHeight: 1.12
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
            }
        }
    }

    component PreviewPanel: Rectangle {
        id: panel

        radius: VfTheme.dp(8)
        color: VfTheme.surface
        border.width: 1
        border.color: VfTheme.borderBox

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(10)
            spacing: VfTheme.dp(8)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                VfAppIcon {
                    name: "magnifying-glass"
                    size: VfTheme.dp(18)
                    color: VfTheme.primary
                }

                Label {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("style_manager.preview_panel_title", "Preview lựa chọn"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(14)
                    font.weight: VfTheme.weightStrong
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(226)
                radius: VfTheme.dp(8)
                color: VfTheme.surfaceSoft
                border.width: 1
                border.color: VfTheme.borderBox
                clip: true

                Image {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    source: root.hasPreview() ? root.urlForPath(root.previewPath()) : ""
                    visible: root.hasPreview() && !root.hasMotionPreview()
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                    smooth: true
                }

                AnimatedImage {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    source: root.hasMotionPreview() ? root.urlForPath(root.motionPreviewPath()) : ""
                    visible: root.hasMotionPreview()
                    playing: visible && root.opened
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                    speed: 1.0
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: VfTheme.dp(10)
                    visible: root.activeDrawMode() && (root.hasMotionPreview() || root.motionPreviewBusy)
                    radius: VfTheme.dp(6)
                    color: VfTheme.amberFill
                    border.width: 1
                    border.color: VfTheme.amberBorderSoft
                    width: motionBadgeLabel.implicitWidth + VfTheme.dp(14)
                    height: VfTheme.dp(22)

                    Label {
                        id: motionBadgeLabel
                        anchors.centerIn: parent
                        text: root.motionPreviewBusy
                            ? (void i18n.revision, i18n.t("style_manager.motion_preview_busy", "Đang render…"))
                            : (root.motionPreviewActorLabel()
                               + " · "
                               + String((root.motionPreviewState || {}).renderer || ""))
                        color: VfTheme.amberText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                        font.weight: VfTheme.weightStrong
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.hasMotionPreview() || root.hasPreview()
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onDoubleClicked: {
                        var path = root.hasMotionPreview()
                            ? (String((root.motionPreviewState || {}).mp4_path || "") || root.motionPreviewPath())
                            : root.previewPath()
                        if (path.length && typeof nativeShell !== "undefined")
                            nativeShell.openPath(path)
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: VfTheme.dp(6)
                    visible: !root.hasPreview() && !root.hasMotionPreview() && !root.motionPreviewBusy

                    VfAppIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: "artist-palette"
                        size: VfTheme.dp(34)
                        color: VfTheme.primary
                    }

                    Label {
                        width: panel.width - VfTheme.dp(50)
                        text: root.selectedCount() >= 2
                            ? (void i18n.revision, i18n.t("style_manager.preview_combo_missing", "Tạo preview kết hợp để kiểm tra cặp framework."))
                            : cleanDisplayText(itemId(root.currentItem).length && itemPrompt(root.currentItem).length
                                ? (void i18n.revision, i18n.t("style_manager.preview_no_preview", "Chưa có preview - bấm Tạo preview"))
                                : (void i18n.revision, i18n.t("style_manager.preview_no_prompt", "Chưa có prompt để tạo preview")))
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: root.selectionTitle()
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(14)
                font.weight: VfTheme.weightStrong
                elide: Text.ElideRight
            }

            Label {
                Layout.fillWidth: true
                text: root.activeDrawMode() && root.motionPreviewExplanation().length
                    ? root.motionPreviewExplanation()
                    : root.selectionDetailText()
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                lineHeight: 1.18
                wrapMode: Text.WordWrap
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.selectedCount() >= 2 ? VfTheme.dp(116) : VfTheme.dp(76)
                radius: VfTheme.dp(8)
                color: root.selectedCount() >= 2 ? VfTheme.amberFill : VfTheme.blueFill
                border.width: 1
                border.color: root.selectedCount() >= 2 ? VfTheme.amberBorderSoft : VfTheme.blueBorderSoft

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(9)
                    spacing: VfTheme.dp(5)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)

                        VfAppIcon {
                            name: root.selectedCount() >= 2 ? "red-triangle" : "light-bulb"
                            size: VfTheme.dp(15)
                            color: root.selectedCount() >= 2 ? "#EA580C" : VfTheme.primary
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.selectedCount() >= 2
                                ? (void i18n.revision, i18n.t("style_manager.confirm_guard_title", "Xác nhận để tránh nhầm"))
                                : (void i18n.revision, i18n.t("style_manager.preview_single_title", "Preview từng framework"))
                            color: root.selectedCount() >= 2 ? VfTheme.amberText : VfTheme.blueText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            font.weight: VfTheme.weightStrong
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: root.selectedCount() >= 2
                            ? (void i18n.revision, i18n.t("style_manager.guard_style_camera", "Bạn đang áp dụng nhiều lớp framework. Hãy kiểm tra preview để chắc prompt kết hợp đúng ý."))
                            : (root.activeDrawMode()
                                ? (void i18n.revision, i18n.t("style_manager.preview_draw_hint", "Style Move chỉ Move. Style vẽ chỉ đổi Tay+bút / Chỉ bút — không nhảy sang họ kia."))
                                : (void i18n.revision, i18n.t("style_manager.preview_single_hint", "Chọn card để xem preview và prompt chi tiết ở đây.")))
                        color: root.selectedCount() >= 2 ? VfTheme.amberText : VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        wrapMode: Text.WordWrap
                    }

                    CheckBox {
                        visible: root.selectedCount() >= 2
                        text: (void i18n.revision, i18n.t("style_manager.confirm_checked", "Tôi đã kiểm tra preview"))
                        checked: root.confirmApplyChecked
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        onToggled: root.confirmApplyChecked = checked
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: root.previewMessage
                visible: text.length > 0
                wrapMode: Text.WordWrap
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            TextArea {
                Layout.fillWidth: true
                Layout.fillHeight: true
                readOnly: true
                wrapMode: TextArea.Wrap
                text: root.metadataText()
                placeholderText: (void i18n.revision, i18n.t("style_manager.metadata_placeholder", "Chọn một framework để xem metadata."))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                background: Rectangle {
                    color: VfTheme.surface
                    border.width: 1
                    border.color: VfTheme.border
                    radius: VfTheme.dp(7)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: !root.hasPreview() || root.activeDrawMode()
                enabled: visible
                spacing: VfTheme.dp(7)

                PyButton {
                    actionId: "style_manager.preview"
                    text: root.isComboSelection()
                        ? (void i18n.revision, i18n.t("style_manager.btn_generate_combo_preview", "Tạo preview kết hợp"))
                        : (void i18n.revision, i18n.t("style_manager.btn_generate_preview", "Tạo preview"))
                    compact: true
                    visible: !root.hasPreview()
                    minWidth: VfTheme.dp(126)
                    enabled: visible && !root.previewGenerationBusy && root.canGenerateSelectionPreview()
                    onClicked: root.requestSelectionPreview()
                }

                PyButton {
                    actionId: "style_manager.motion_preview"
                    text: root.hasMotionPreview()
                        ? (void i18n.revision, i18n.t("style_manager.btn_rerender_motion", "Render lại chuyển động"))
                        : (void i18n.revision, i18n.t("style_manager.btn_render_motion", "Tạo preview chuyển động"))
                    compact: true
                    visible: root.activeDrawMode() && root.itemHasNativeDrawContract(root.currentItem)
                    minWidth: VfTheme.dp(168)
                    enabled: visible && !root.motionPreviewBusy && root.hasPreview()
                    onClicked: root.requestMotionPreview(true)
                }
            }
        }
    }

    Dialog {
        id: deleteConfirmDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(380), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.width: 1
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Label {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("style_manager.confirm_delete_title", "Confirm delete"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightStrong
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: root.formatNameText(
                    (void i18n.revision, i18n.t("style_manager.confirm_delete_msg", "Delete '{name}'?")),
                    root.pendingDeleteName.length ? root.pendingDeleteName : root.pendingDeleteId
                )
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(14)
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                PyButton {
                    actionId: "style_manager.cancel"
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    onClicked: deleteConfirmDialog.close()
                }

                PyButton {
                    actionId: "style_manager.delete"
                    danger: true
                    text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                    enabled: root.pendingDeleteId.length > 0
                    onClicked: {
                        root.deleteRequested(root.pendingDeleteId)
                        deleteConfirmDialog.close()
                    }
                }
            }
        }

        onClosed: {
            root.pendingDeleteId = ""
            root.pendingDeleteName = ""
        }
    }

    Dialog {
        id: deleteTopicConfirmDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(380), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.width: 1
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Label {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("style_manager.confirm_delete_topic_title", "Xoá cả chủ đề?"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightStrong
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: root.formatNameText(
                    (void i18n.revision, i18n.t("style_manager.confirm_delete_topic_msg", "Xoá tất cả style của chủ đề '{name}'?")),
                    root.pendingDeleteTopicName.length ? root.pendingDeleteTopicName : root.pendingDeleteTopicId
                )
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(14)
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                PyButton {
                    actionId: "style_manager.cancel"
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    onClicked: deleteTopicConfirmDialog.close()
                }

                PyButton {
                    actionId: "style_manager.delete_topic"
                    danger: true
                    text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                    enabled: root.pendingDeleteTopicId.length > 0
                    onClicked: {
                        root.deleteTopicRequested(root.pendingDeleteTopicId)
                        deleteTopicConfirmDialog.close()
                    }
                }
            }
        }

        onClosed: {
            root.pendingDeleteTopicId = ""
            root.pendingDeleteTopicName = ""
        }
    }

    Dialog {
        id: bulkPreviewConfirmDialog

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
            border.width: 1
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Label {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("style_manager.bulk_confirm_title", "Confirm bulk preview"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightStrong
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t(
                    "style_manager.bulk_confirm_msg",
                    "Generate previews for {count} item(s) ({scope})?"
                ))
                    .replace("{count}", String((root.pendingBulkItems || []).length))
                    .replace(
                        "{scope}",
                        root.pendingBulkOnlyMissing
                            ? (void i18n.revision, i18n.t("style_manager.bulk_scope_missing", "missing only"))
                            : (void i18n.revision, i18n.t("style_manager.bulk_scope_all", "all"))
                    )
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(14)
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                PyButton {
                    actionId: "style_manager.cancel"
                    text: (void i18n.revision, i18n.t("common.no", "No"))
                    onClicked: bulkPreviewConfirmDialog.close()
                }

                PyButton {
                    actionId: "style_manager.apply"
                    text: (void i18n.revision, i18n.t("common.yes", "Yes"))
                    enabled: !root.previewGenerationBusy && (root.pendingBulkItems || []).length > 0
                    onClicked: {
                        root.bulkPreviewRequested(root.pendingBulkItems || [], root.pendingBulkOnlyMissing)
                        bulkPreviewConfirmDialog.close()
                    }
                }
            }
        }

        onClosed: {
            root.pendingBulkItems = []
            root.pendingBulkOnlyMissing = true
        }
    }

    Dialog {
        id: applyConfirmDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(520), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.width: 1
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Label {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("style_manager.confirm_multi_title", "Xác nhận áp dụng framework"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightStrong
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("style_manager_dialog.confirm_applying_frameworks_warning", "Bạn đang áp dụng {count} framework cùng lúc.\n{detail}\n\nKiểm tra đúng cặp style/camera trước khi tiếp tục."))
                    .replace(
                        "{count}",
                        String(root.selectedCount())
                    )
                    .replace("{detail}", root.confirmDetailText())
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                wrapMode: Text.WordWrap
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(64)
                radius: VfTheme.dp(8)
                color: VfTheme.amberFill
                border.width: 1
                border.color: VfTheme.amberBorderSoft

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    spacing: VfTheme.dp(8)

                    VfAppIcon {
                        name: "red-triangle"
                        size: VfTheme.dp(18)
                        color: "#EA580C"
                    }

                    Label {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("style_manager.confirm_style_camera_warning", "Style + Camera sẽ thay đổi cả phong cách hình ảnh và grammar khung hình/chuyển động."))
                        color: VfTheme.amberText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        wrapMode: Text.WordWrap
                    }
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("style_manager.confirm_checked", "Tôi đã kiểm tra preview và đúng cặp muốn áp dụng"))
                checked: root.confirmApplyChecked
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                onToggled: root.confirmApplyChecked = checked
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                PyButton {
                    actionId: "style_manager.cancel"
                    text: (void i18n.revision, i18n.t("common.back", "Quay lại"))
                    onClicked: applyConfirmDialog.close()
                }

                PyButton {
                    actionId: "style_manager.apply"
                    text: (void i18n.revision, i18n.t("style_manager.btn_apply", "Áp dụng"))
                    emphasized: true
                    enabled: root.confirmApplyChecked
                    onClicked: {
                        root.applyRequested(root.selectionPayload())
                        applyConfirmDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: feedbackDialog

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
            border.width: 1
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Label {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightStrong
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(14)
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4

                Item { Layout.fillWidth: true }

                PyButton {
                    actionId: "style_manager.apply"
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    onClicked: feedbackDialog.close()
                }
            }
        }

        onClosed: {
            root.feedbackTitle = ""
            root.feedbackMessage = ""
        }
    }
}
