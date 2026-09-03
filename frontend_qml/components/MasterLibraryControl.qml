import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"
import "../dialogs"
import "LibraryPolicy.js" as LibraryPolicy

// Shared library-control block (nhan vat / do vat / boi canh) dung CHUNG cho
// Master va Voice Studio. Ca hai deu doc/ghi masterOptionsController.config +
// workPanelController, nen component tu chua: helper policy + panel + 3 dialog.
// Panel visibility is UI-only; backend state is derived from the three scopes.
Rectangle {
    id: ctl

    // Stable tour target — shared character/object/background control embedded in
    // Master + Voice + Clone/Transcript/Extend/Affiliate workspaces.
    objectName: "libraryControl"

    property var config: masterOptionsController.config || ({})
    property string mapping: "explicit_id_authoring"
    // UI-only disclosure state. Backend enablement is derived from the three
    // policy scopes and is never coupled to whether this panel is visible.
    property bool expanded: false

    // Input cho panel: cache + chi gan khi NOI DUNG doi. Truoc day panel bind thang
    // 6 function-call (ctl.characterMode(), ctl.buildLibraryPolicy().scopes, ...):
    // moi configChanged (BAT KY key nao cua master config) -> 6 ham chay lai, tra
    // object/array MOI -> QML coi la doi 100% -> toan bo ScopeCard + chip anh bi
    // huy/dung lai (~100-200ms GUI moi lan) => click giat, click nhanh dong bang.
    property string panelCharMode: "hybrid"
    property var panelScopeCategories: []
    property var panelScopePolicies: ({})
    property var panelCharacters: []
    property var panelObjects: []
    property var panelBackgrounds: []

    function syncPanelInputs() {
        var mode = ctl.characterMode()
        if (mode !== ctl.panelCharMode)
            ctl.panelCharMode = mode
        var cats = ctl.libraryPolicyCategories()
        if (JSON.stringify(cats) !== JSON.stringify(ctl.panelScopeCategories))
            ctl.panelScopeCategories = cats
        var scopes = ctl.buildLibraryPolicy().scopes
        if (JSON.stringify(scopes) !== JSON.stringify(ctl.panelScopePolicies))
            ctl.panelScopePolicies = scopes
        var chars = ctl.selectedCharacterAssets()
        if (JSON.stringify(chars) !== JSON.stringify(ctl.panelCharacters))
            ctl.panelCharacters = chars
        var objs = ctl.selectedObjectAssets()
        if (JSON.stringify(objs) !== JSON.stringify(ctl.panelObjects))
            ctl.panelObjects = objs
        var bgs = ctl.selectedBackgroundAssets()
        if (JSON.stringify(bgs) !== JSON.stringify(ctl.panelBackgrounds))
            ctl.panelBackgrounds = bgs
    }

    Connections {
        target: masterOptionsController
        // Component này có 2 instance (Master + Voice Studio) và screen ẩn vẫn SỐNG
        // (App.qml Loader latch everActive, ẩn bằng opacity) -> chỉ instance đang
        // hiển thị mới xử lý configChanged; instance ẩn bù sync ở onVisibleChanged.
        enabled: ctl.visible
        function onConfigChanged() { ctl.syncPanelInputs() }
    }
    onVisibleChanged: if (visible) syncPanelInputs()
    Component.onCompleted: syncPanelInputs()

    Layout.fillWidth: true
    visible: ctl.expanded
    implicitHeight: visible ? (characterColumn.implicitHeight + VfTheme.dp(14)) : 0
    radius: VfTheme.dp(10)
    color: VfTheme.violetFill
    border.color: VfTheme.violetBorderSoft
    border.width: 1

    // ── Helpers (doc thang masterOptionsController.config) ───────────────────
    function characterMode() {
        return "hybrid"
    }

    function characterConsistencyEnabled() {
        return ctl.categorySource("characters") !== "disabled"
    }

    function categorySource(category) {
        var policy = ctl.buildLibraryPolicy()
        var scope = ((policy || {}).scopes || ({}))[String(category || "")] || ({})
        return String(scope.source || scope.source_policy || "ai")
    }

    function activeCategoryCount() {
        var count = 0
        var categories = ["characters", "objects", "backgrounds"]
        for (var i = 0; i < categories.length; i += 1) {
            if (ctl.categorySource(categories[i]) !== "disabled")
                count += 1
        }
        return count
    }

    function disclosureText(baseText) {
        var count = ctl.activeCategoryCount()
        var state = count > 0
            ? (" " + String(count) + "/3")
            : ": " + String((void i18n.revision, i18n.t("master.consistency_off", "Tắt")))
        return String(baseText || "") + state + (ctl.expanded ? "  ▴" : "  ▾")
    }

    function disclosureTooltip() {
        var count = ctl.activeCategoryCount()
        if (count <= 0)
            return String((void i18n.revision, i18n.t(
                "master.consistency_all_off_tip",
                "Đồng nhất đang tắt cho cả nhân vật, đồ vật và bối cảnh. Nhấn để cấu hình.")))
        return String((void i18n.revision, i18n.t(
            "master.consistency_active_tip",
            "Đang bật {count}/3 nhóm đồng nhất. Nhấn để cấu hình."))).replace("{count}", String(count))
    }

    function voiceSyncSupported() {
        return Boolean((masterOptionsController.options || {}).flow_voice_lock_supported)
    }

    function voiceSyncHint() {
        if (!ctl.voiceSyncSupported())
            return String((void i18n.revision, i18n.t(
                "master.voice_lock_model_unsupported",
                "Model video hiện tại không hỗ trợ đồng bộ giọng.")))
        return String((void i18n.revision, i18n.t(
            "master.voice_lock_ready",
            "Sẽ áp dụng cho nhân vật sau khi AI phân tích nội dung.")))
    }

    function libraryPolicyCategories() {
        // library_policy_categories la key duoc sua LIVE khi bat/tat scope, nen doc
        // no TRUOC; library_policy.categories chi la ban da luu (cu hon 1 nhip).
        // Phan biet THIEU key (config moi -> default characters) vs RONG (user chon
        // "AI tu tao" cho moi scope -> phai ton trong, khong ep ve ["characters"]).
        var policy = ctl.config.library_policy || ({})
        var items = ctl.config.library_policy_categories
        if (items === undefined || items === null)
            items = policy.categories
        if (items === undefined || items === null)
            items = []
        var out = []
        for (var i = 0; i < items.length; i += 1) {
            var value = String(items[i] || "")
            if (value.length > 0 && out.indexOf(value) < 0)
                out.push(value)
        }
        return out
    }

    function storedScopePolicy(category) {
        var policy = ctl.config.library_policy || ({})
        var scopes = policy.scopes || ({})
        return scopes[String(category || "")] || ({})
    }

    function buildLibraryPolicy(overrideCategory, overrideKey, overrideValue, modeOverride) {
        // Phan matrix dung CHUNG o LibraryPolicy.build; tab chi cap nguon rieng.
        var mode = "hybrid"
        return LibraryPolicy.build(
            mode,
            ctl.libraryPolicyCategories(),
            function(category) { return ctl.storedScopePolicy(category) },
            ctl.mapping,
            overrideCategory, overrideKey, overrideValue)
    }

    function saveLibraryPolicy(overrideCategory, overrideKey, overrideValue, modeOverride) {
        var mode = "hybrid"
        var policy = ctl.buildLibraryPolicy(overrideCategory, overrideKey, overrideValue, mode)
        var cats = policy.categories || []
        var scopes = policy.scopes || ({})
        var charSource = String((scopes.characters || {}).source || "ai")
        var objectSource = String((scopes.objects || {}).source || "ai")
        var backgroundSource = String((scopes.backgrounds || {}).source || "ai")
        var charEnabled = charSource !== "disabled"
        var sceneEnabled = objectSource !== "disabled" || backgroundSource !== "disabled"
        ctl.config.library_policy = policy
        ctl.config.library_policy_categories = cats
        ctl.config.char_mode = mode
        masterOptionsController.setOptions({
            library_policy: policy,
            library_policy_categories: cats,
            char_mode: mode,
            character_consistency: charEnabled,
            scene_consistency: sceneEnabled
        })
    }

    function setLibraryCategoryEnabled(category, enabled) {
        var target = String(category || "")
        var items = ctl.libraryPolicyCategories()
        var index = items.indexOf(target)
        if (enabled && index < 0)
            items.push(target)
        if (!enabled && index >= 0)
            items.splice(index, 1)
        var ordered = []
        var order = ["characters", "objects", "backgrounds"]
        for (var i = 0; i < order.length; i += 1) {
            if (items.indexOf(order[i]) >= 0)
                ordered.push(order[i])
        }
        ctl.config.library_policy_categories = ordered
        ctl.saveLibraryPolicy(target, "", "")
    }

    function togglePanel() {
        ctl.expanded = !ctl.expanded
    }

    // ── Selected assets ──────────────────────────────────────────────────────
    function selectedCharacterAssets() {
        var info = ctl.config.multi_asset_info
        if (!info || typeof info !== "object")
            return []
        var items = info.assets || []
        var out = []
        for (var i = 0; i < items.length; i += 1) {
            var asset = items[i] || {}
            var assetType = String(asset.asset_type || asset.type || "character")
            if (assetType === "character")
                out.push(asset)
        }
        return out
    }

    function assetBucket(asset) {
        var value = String((asset || {}).asset_type || (asset || {}).type || "").toLowerCase()
        if (value === "character" || value === "characters")
            return "characters"
        if (value === "object" || value === "objects" || value === "prop" || value === "product")
            return "objects"
        if (value === "background" || value === "backgrounds" || value === "setting" || value === "settings")
            return "backgrounds"
        return ""
    }

    function selectedAssetsByBucket(bucket) {
        var info = ctl.config.multi_asset_info
        if (!info || typeof info !== "object")
            return []
        var items = info.assets || []
        var out = []
        for (var i = 0; i < items.length; i += 1) {
            var asset = items[i] || {}
            if (ctl.assetBucket(asset) === bucket)
                out.push(asset)
        }
        return out
    }

    function selectedObjectAssets() {
        return ctl.selectedAssetsByBucket("objects")
    }

    function selectedBackgroundAssets() {
        return ctl.selectedAssetsByBucket("backgrounds")
    }

    function selectedAssetIds(bucket) {
        var out = []
        var items = ctl.selectedAssetsByBucket(bucket)
        for (var i = 0; i < items.length; i += 1) {
            var mediaId = String(items[i].media_id || items[i].id || "")
            if (mediaId.length > 0)
                out.push(mediaId)
        }
        return out
    }

    function selectedCharacterIds() {
        var out = []
        var items = ctl.selectedCharacterAssets()
        for (var i = 0; i < items.length; i += 1) {
            var mediaId = String(items[i].media_id || items[i].id || "")
            if (mediaId.length > 0)
                out.push(mediaId)
        }
        return out
    }

    // ── Open library pickers ─────────────────────────────────────────────────
    function openCharacterLibrary() {
        if (typeof workPanelController === "undefined")
            return
        characterLibraryDialogLoader.active = true
        characterLibraryDialogLoader.item.openUsagePicker("character", ["character"], ctl.selectedCharacterIds(), 9999, true)
    }

    function openObjectLibrary() {
        if (typeof workPanelController === "undefined")
            return
        objectLibraryDialogLoader.active = true
        objectLibraryDialogLoader.item.openUsagePicker("object", ["object"], ctl.selectedAssetIds("objects"), 9999, true)
    }

    function openBackgroundLibrary() {
        if (typeof workPanelController === "undefined")
            return
        backgroundLibraryDialogLoader.active = true
        backgroundLibraryDialogLoader.item.openUsagePicker("background", ["background", "setting"], ctl.selectedAssetIds("backgrounds"), 9999, true)
    }

    ColumnLayout {
        id: characterColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: VfTheme.dp(7)
        spacing: VfTheme.dp(7)

        CharacterConsistencyPanel {
            Layout.fillWidth: true
            charMode: ctl.panelCharMode
            scopeCategories: ctl.panelScopeCategories
            scopePolicies: ctl.panelScopePolicies
            characters: ctl.panelCharacters
            objects: ctl.panelObjects
            backgrounds: ctl.panelBackgrounds
            allowObjectSelection: true
            allowBackgroundSelection: true
            // Nút "Tự động lưu nhân vật" dùng chung (thay chip riêng ở MasterPromptScreen);
            // Master + Voice Studio cùng đọc/ghi flag master save_ai_characters.
            showAutoSave: true
            autoSaveEnabled: Boolean(ctl.config.save_ai_characters)
            showVoiceSync: true
            voiceSyncEnabled: Boolean(ctl.config.enable_flow_voice_lock)
            voiceSyncSupported: ctl.voiceSyncSupported()
            voiceSyncHint: ctl.voiceSyncHint()
            voiceSyncCharacterCount: ctl.panelCharacters.length
            onVoiceSyncToggled: function(enabled) {
                masterOptionsController.setOption("enable_flow_voice_lock", enabled)
            }
            onAutoSaveToggled: function(enabled) {
                masterOptionsController.setOption("save_ai_characters", enabled)
            }
            onScopeToggled: function(category, enabled) { ctl.setLibraryCategoryEnabled(category, enabled) }
            onScopePolicyChanged: function(category, key, value) { ctl.saveLibraryPolicy(category, key, value, "") }
            onAddRequested: ctl.openCharacterLibrary()
            onAddObjectsRequested: ctl.openObjectLibrary()
            onAddBackgroundsRequested: ctl.openBackgroundLibrary()
            onClearRequested: masterOptionsController.clearCharacterLibrarySelection()
            onMoveRequested: function(mediaId, offset) { masterOptionsController.moveCharacterLibrarySelection(mediaId, offset) }
            onRemoveRequested: function(mediaId) { masterOptionsController.removeCharacterLibrarySelection(mediaId) }
            onRemoveObjectRequested: function(mediaId) { masterOptionsController.removeLibraryAssetSelection("objects", mediaId) }
            onRemoveBackgroundRequested: function(mediaId) { masterOptionsController.removeLibraryAssetSelection("backgrounds", mediaId) }
        }
    }

    // Lazy: build the heavy MediaLibraryDialog tree only on first open, not during the
    // background route preload — eager off-screen build flooded the render thread
    // ("Cannot find member data") and crashed Qt6Qml. Matches App.qml's header pattern.
    Loader {
        id: characterLibraryDialogLoader
        active: false
        sourceComponent: MediaLibraryDialog {
            id: characterLibraryDialog
            parent: Overlay.overlay
            mode: "select"
            appendSelection: true
            maxSelection: 9999
            filterType: "character"
            items: (visible && typeof workPanelController !== "undefined") ? workPanelController.mediaLibraryItems : []
            stats: typeof workPanelController !== "undefined" ? workPanelController.mediaLibraryStats : ({})
            settings: typeof workPanelController !== "undefined" ? workPanelController.mediaLibrarySettings : ({})
            onRefreshRequested: (search, assetType) => {
                if (typeof workPanelController !== "undefined")
                    workPanelController.refreshMediaLibrary(search || "", assetType || "")
            }
            onMediaSelected: selection => {
                var result
                if (typeof workPanelController === "undefined") {
                    result = { ok: false, blocked: true, message: "Media library controller is unavailable." }
                } else {
                    result = masterOptionsController.setCharacterLibrarySelection(
                        selection || ({}), workPanelController.mediaLibraryItems || [])
                }
                characterLibraryDialog.applySelectionResult(result)
            }
        }
    }

    Loader {
        id: objectLibraryDialogLoader
        active: false
        sourceComponent: MediaLibraryDialog {
            id: objectLibraryDialog
            parent: Overlay.overlay
            mode: "select"
            appendSelection: true
            maxSelection: 9999
            filterType: "object"
            items: (visible && typeof workPanelController !== "undefined") ? workPanelController.mediaLibraryItems : []
            stats: typeof workPanelController !== "undefined" ? workPanelController.mediaLibraryStats : ({})
            settings: typeof workPanelController !== "undefined" ? workPanelController.mediaLibrarySettings : ({})
            onRefreshRequested: (search, assetType) => {
                if (typeof workPanelController !== "undefined")
                    workPanelController.refreshMediaLibrary(search || "", assetType || "")
            }
            onMediaSelected: selection => {
                var result
                if (typeof workPanelController === "undefined") {
                    result = { ok: false, blocked: true, message: "Media library controller is unavailable." }
                } else {
                    result = masterOptionsController.setLibraryAssetSelection(
                        "objects", selection || ({}), workPanelController.mediaLibraryItems || [])
                }
                objectLibraryDialog.applySelectionResult(result)
            }
        }
    }

    Loader {
        id: backgroundLibraryDialogLoader
        active: false
        sourceComponent: MediaLibraryDialog {
            id: backgroundLibraryDialog
            parent: Overlay.overlay
            mode: "select"
            appendSelection: true
            maxSelection: 9999
            filterType: "background"
            items: (visible && typeof workPanelController !== "undefined") ? workPanelController.mediaLibraryItems : []
            stats: typeof workPanelController !== "undefined" ? workPanelController.mediaLibraryStats : ({})
            settings: typeof workPanelController !== "undefined" ? workPanelController.mediaLibrarySettings : ({})
            onRefreshRequested: (search, assetType) => {
                if (typeof workPanelController !== "undefined")
                    workPanelController.refreshMediaLibrary(search || "", assetType || "")
            }
            onMediaSelected: selection => {
                var result
                if (typeof workPanelController === "undefined") {
                    result = { ok: false, blocked: true, message: "Media library controller is unavailable." }
                } else {
                    result = masterOptionsController.setLibraryAssetSelection(
                        "backgrounds", selection || ({}), workPanelController.mediaLibraryItems || [])
                }
                backgroundLibraryDialog.applySelectionResult(result)
            }
        }
    }
}
