import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../dialogs"
import "../theme"

Rectangle {
    id: root

    // Stable tour target — shared component embedded in Master + Work tabs.
    objectName: "masterConfigPanel"

    property string route: ""
    property var currentBatchConfig: ({})
    readonly property var styleManagerDialog: styleManagerDialogLoader.item

    function withStyleManager(callback) {
        styleManagerDialogLoader.active = true
        Qt.callLater(function() {
            var dialog = root.styleManagerDialog
            if (dialog && callback)
                callback(dialog)
        })
    }

    function openStyleManagerExternal() {
        masterOptionsController.refreshStyles("")
        root.withStyleManager(function(dialog) { dialog.openBucket("style") })
    }

    function openDrawManagerExternal() {
        masterOptionsController.refreshStyles("")
        root.withStyleManager(function(dialog) { dialog.openBucket("draw") })
    }

    // The dialog is a Popup (not an Item) → the tour overlay can't reach it by
    // objectName on Overlay.overlay; the tour closes it through here instead.
    function closeStyleManagerExternal() {
        var dialog = root.styleManagerDialog
        if (dialog && dialog.opened)
            dialog.close()
    }

    function openPendingDialogIfRequested() {
        if (masterOptionsController.consumePendingDialog("style_manager")) {
            masterOptionsController.refreshStyles("")
            root.withStyleManager(function(dialog) { dialog.openBucket("style") })
        }
    }
    property bool cloneRoute: route === "clone"
    property bool normalRoute: route === "normal"
    property bool extendRoute: route === "extend"
    property bool batchRoute: route === "batch"
    property bool affiliateRoute: route === "affiliate"
    property bool transcriptRoute: route === "transcript"
    property bool timemachineRoute: route === "timemachine"
    // Audio-to-Video / Clone "Đầu ra": dual branch row owns mode + VIDEO/ẢNH knobs
    // + Draw. Shared grid must not host exclusive branch fields for these routes.
    readonly property bool dualOutputRoute: root.cloneRoute || root.transcriptRoute
    readonly property string dualOutputMode: {
        if (root.cloneRoute)
            return String((root.config || {}).output_mode || "auto")
        if (root.transcriptRoute)
            return String((root.config || {}).output_mode || "video")
        return ""
    }
    readonly property bool dualAutoMode: root.dualOutputRoute && root.dualOutputMode === "auto"
    property bool imageMode: root.dualOutputRoute
        ? root.dualOutputMode === "image"
        : false
    // Image-native availability (explicit image OR dual auto for Draw package).
    readonly property bool showImageBranchConfig: root.imageMode || root.dualAutoMode
    // Video-native availability (not pure-image, or dual auto video branch).
    readonly property bool showVideoBranchConfig: !root.imageMode || root.dualAutoMode
    // Shared top grid: exclusive branch fields only for routes without dual row.
    readonly property bool mainVideoBranchConfig: root.showVideoBranchConfig && !root.dualOutputRoute
    readonly property bool mainImageBranchConfig: root.showImageBranchConfig && !root.dualOutputRoute
    readonly property bool showDualOutputBranchRow: root.dualOutputRoute
    // Always keep BOTH branch halves mounted so mode switches do not reflow.
    // Exclusive Video/Image only disables the inactive half.
    readonly property bool dualVideoBranchEnabled: root.dualOutputRoute
        && (root.dualOutputMode === "auto" || root.dualOutputMode === "video")
    readonly property bool dualImageBranchEnabled: root.dualOutputRoute
        && (root.dualOutputMode === "auto" || root.dualOutputMode === "image")
    readonly property bool dualDrawEnabled: String((root.config || {}).image_motion_mode || "off") === "auto"
    // Backward-compatible aliases used by older tests / StyleManager wiring.
    readonly property bool cloneAutoMode: root.cloneRoute && root.dualAutoMode
    readonly property string cloneOutputMode: root.cloneRoute ? root.dualOutputMode : ""
    readonly property bool showCloneOutputBranchRow: root.showDualOutputBranchRow
    readonly property bool cloneVideoBranchEnabled: root.cloneRoute && root.dualVideoBranchEnabled
    readonly property bool cloneImageBranchEnabled: root.cloneRoute && root.dualImageBranchEnabled
    readonly property bool cloneDrawEnabled: root.dualDrawEnabled
    // Work-panel routes own their OWN config (per-tab) via workPanelController.
    // Batch keeps its dedicated requestBatchConfigPatch path; master ("master"/"")
    // stays on the global masterOptionsController. This is what stops one tab's
    // config from leaking into another.
    property bool isWorkRoute: cloneRoute || normalRoute || extendRoute || affiliateRoute || transcriptRoute || batchRoute
    property bool hasWorkController: (typeof workPanelController !== "undefined") && workPanelController
    property bool showDuration: !(cloneRoute || normalRoute || extendRoute || batchRoute || affiliateRoute)
    property bool masterPromptRoute: !(cloneRoute || normalRoute || extendRoute || batchRoute || affiliateRoute || timemachineRoute)
    property bool showModelDuration: normalRoute
    property bool showNormalOutput: normalRoute
    property bool showFilename: normalRoute || batchRoute
    property bool masterScriptMode: !(cloneRoute || normalRoute || extendRoute || batchRoute || affiliateRoute) && String((masterOptionsController.config || {}).input_mode || "idea") === "script"
    // Số field TỐI ĐA route này hiện (để màn rộng nhồi hết vào MỘT hàng).
    // Dual-output branch knobs are on row 2; shared grid stays compact.
    readonly property int configMaxColumns: dualOutputRoute ? 7
        : extendRoute ? 6
        : batchRoute ? 7
        : affiliateRoute ? 6
        : timemachineRoute ? 8
        : normalRoute ? 9
        : 7
    // AUTO-FIT: nhồi bao nhiêu field ~dp(190) vừa bề rộng panel thì bấy nhiêu cột,
    // cap theo số field. Thay breakpoint px cứng cũ (980/1480) vốn rớt xuống 2 cột
    // quá sớm rồi kéo dãn mỗi dropdown ra nửa panel (bug "thừa, xuống hàng vô cớ").
    // Nhỏ dần → ít cột hơn nhưng field luôn ≥ ~180dp; rộng dần → tự gộp về 1 hàng.
    // Time Machine has eight compact selectors and a permanent right rail.  Its
    // fields are all eliding controls, so a ~145dp target remains readable and
    // keeps Model anh on the same row at normal desktop widths.
    readonly property real configTargetFieldWidth: root.timemachineRoute
        ? VfTheme.dp(145) : VfTheme.dp(190)
    readonly property int configColumns: Math.max(
        2,
        Math.min(
            configMaxColumns,
            Math.floor(
                (root.width - VfTheme.dp(8))
                / (root.configTargetFieldWidth + VfTheme.dp(6))))
    )
    property var config: root.timemachineRoute
        ? (timemachineController.config || ({}))
        : ((root.isWorkRoute && root.hasWorkController)
            ? (workPanelController.currentRouteConfig || ({}))
            : (masterOptionsController.config || ({})))
    property var options: root.timemachineRoute
        ? (timemachineController.options || ({}))
        : ((root.isWorkRoute && root.hasWorkController)
            ? (workPanelController.currentRouteOptions || ({}))
            : (masterOptionsController.options || ({})))

    // Route-aware single-option write: work routes (incl. batch) persist to
    // their own config; master keeps the global options path.
    function writeOption(key, value) {
        if (root.timemachineRoute)
            timemachineController.setOption(key, value)
        else if (root.isWorkRoute && root.hasWorkController && workPanelController.setRouteOption)
            workPanelController.setRouteOption(root.route, key, value)
        else
            masterOptionsController.setOption(key, value)
    }

    function writeCloneDialogueLanguage(value) {
        if (!root.hasWorkController || !workPanelController.setRouteOptions)
            return
        var code = String(value || "").trim().toLowerCase()
        workPanelController.setRouteOptions("clone", {
            dialogue_language: code,
            language_mode: code.length ? "translated" : "original"
        })
    }

    function dualOutputModeOptions() {
        return [
            {
                label: (void i18n.revision, i18n.t("clone.output_auto_short", "Đầu ra: Tự động")),
                value: "auto",
                icon: "magic-wand"
            },
            {
                label: (void i18n.revision, i18n.t("clone.output_image_short", "Đầu ra: Ảnh")),
                value: "image",
                icon: "framed-picture"
            },
            {
                label: (void i18n.revision, i18n.t("clone.output_video_short", "Đầu ra: Video")),
                value: "video",
                icon: "video-camera"
            }
        ]
    }

    // Alias kept for Clone layout tests.
    function cloneOutputModeOptions() {
        return root.dualOutputModeOptions()
    }

    function dualImageRhythmOptions() {
        return [
            { label: (void i18n.revision, i18n.t("config_panel.rhythm_auto", "Auto theo nội dung")), value: "auto" },
            { label: (void i18n.revision, i18n.t("config_panel.rhythm_fixed", "Đúng số ảnh chỉ định")), value: "fixed" },
            { label: (void i18n.revision, i18n.t("config_panel.rhythm_single", "Một ảnh xuyên suốt")), value: "single" },
            { label: (void i18n.revision, i18n.t("config_panel.rhythm_template", "Mẫu nhịp theo chủ đề")), value: "template" },
            { label: (void i18n.revision, i18n.t("config_panel.pacing_detailed", "Phân tích đầy đủ")), value: "detailed" },
            { label: (void i18n.revision, i18n.t("config_panel.pacing_moderate", "Cân bằng")), value: "balanced" },
            { label: (void i18n.revision, i18n.t("config_panel.pacing_sparse", "Theo chương")), value: "chapter" }
        ]
    }

    function cloneImageRhythmOptions() {
        return root.dualImageRhythmOptions()
    }

    function imageRhythmTemplateOptions() {
        return [
            { label: (void i18n.revision, i18n.t("config_panel.tpl_auto", "Tự động — LLM nghe audio và chọn")), value: "auto" },
            { label: (void i18n.revision, i18n.t("config_panel.tpl_sleep", "Đi ngủ / dỗ ngủ — dày đầu, thưa dần")), value: "sleep_winddown" },
            { label: (void i18n.revision, i18n.t("config_panel.tpl_meditation", "Thiền / thả lỏng có hướng dẫn")), value: "meditation_guide" },
            { label: (void i18n.revision, i18n.t("config_panel.tpl_listicle", "Danh sách / đếm mục")), value: "listicle" },
            { label: (void i18n.revision, i18n.t("config_panel.tpl_ranking", "Xếp hạng / so sánh bậc")), value: "ranking_compare" },
            { label: (void i18n.revision, i18n.t("config_panel.tpl_tutorial", "Hướng dẫn từng bước")), value: "tutorial_steps" },
            { label: (void i18n.revision, i18n.t("config_panel.tpl_story", "Kể chuyện — dày theo cao trào")), value: "story_narrative" },
            { label: (void i18n.revision, i18n.t("config_panel.tpl_essay", "Tiểu luận / triết lý")), value: "essay_philosophy" },
            { label: (void i18n.revision, i18n.t("config_panel.tpl_news", "Tin tức / phân tích")), value: "news_analysis" },
            { label: (void i18n.revision, i18n.t("config_panel.tpl_motivational", "Động lực / truyền cảm hứng")), value: "motivational_pep" },
            { label: (void i18n.revision, i18n.t("config_panel.tpl_history", "Lịch sử / dòng thời gian")), value: "history_timeline" },
            { label: (void i18n.revision, i18n.t("config_panel.tpl_music", "Nhạc / MV")), value: "music_mv" }
        ]
    }

    function imageRhythmTemplateId() {
        return String((root.config || {}).image_rhythm_template_id || "auto")
    }

    function imageRhythmMode() {
        var canonical = String((root.config || {}).image_rhythm_mode || "").toLowerCase()
        var modes = ["single", "auto", "fixed", "detailed", "balanced", "chapter", "template"]
        if (modes.indexOf(canonical) >= 0)
            return canonical
        var countMode = String((root.config || {}).image_count_mode || "auto").toLowerCase()
        var target = Math.max(1, Number((root.config || {}).image_target_count || 1))
        if (countMode === "manual")
            return target === 1 ? "single" : "fixed"
        var pacing = String((root.config || {}).image_pacing || "auto").toLowerCase()
        if (pacing === "scene" || pacing === "dense") return "detailed"
        if (pacing === "moderate") return "balanced"
        if (pacing === "sparse") return "chapter"
        return "auto"
    }

    function imageRhythmTarget() {
        return Math.max(1, Math.min(9999, Number(
            (root.config || {}).image_rhythm_target
            || (root.config || {}).image_target_count
            || 6
        ) || 6))
    }

    function styleOptionList(kind) {
        var targetKind = String(kind || "style")
        var out = []
        var items = masterOptionsController.styles || []
        for (var i = 0; i < items.length; i++) {
            var item = items[i] || {}
            if (String(item.kind || "style") !== targetKind)
                continue
            out.push({
                label: String(item.display_name || item.name || item.id || ""),
                value: String(item.id || item.style_id || "")
            })
        }
        return out
    }

    function styleLabelForId(styleId) {
        var wanted = String(styleId || "")
        if (!wanted.length)
            return ""
        var items = masterOptionsController.styles || []
        for (var i = 0; i < items.length; i++) {
            var item = items[i] || {}
            var candidate = String(item.id || item.style_id || "")
            if (candidate === wanted)
                return String(item.display_name || item.name || candidate)
        }
        return wanted
    }

    function selectedStyleSummary() {
        // Clone auto-style: the ids are intentionally empty, so show the auto label
        // instead of the blank "Mặc định" fallback. (The extracted look is auto-saved
        // to the library — no per-job toggle.)
        var manualStyleId = String(root.config.style_id || root.config.structural_style_id || root.config.surface_style_id || root.config.selected_style_id || "")
        if (root.cloneRoute && Boolean(root.config.auto_style_framework) && !manualStyleId.length) {
            return (void i18n.revision, i18n.t("clone.auto_style_short", "🎨 Auto (video gốc)"))
        }
        var parts = []
        var cameraId = String(root.config.camera_id || root.config.structural_camera_id || root.config.surface_camera_id || "")
        var styleId = String(root.config.style_id || root.config.structural_style_id || "")
        var surfaceStyleId = String(root.config.surface_style_id || "")
        var cameraLabel = root.styleLabelForId(cameraId)
        var styleLabel = root.styleLabelForId(styleId)
        var surfaceLabel = surfaceStyleId !== styleId ? root.styleLabelForId(surfaceStyleId) : ""
        if (styleLabel.length)
            parts.push(styleLabel)
        if (surfaceLabel.length)
            parts.push(surfaceLabel)
        if (cameraLabel.length)
            parts.push(cameraLabel)
        return parts.join(" + ")
    }

    function openFolderPicker(startPath) {
        var picked = nativeShell.pickFolder(
            (void i18n.revision, i18n.t("master.select_output_folder", "Set output folder")),
            String(startPath || root.config.output_folder || "")
        )
        if (picked && picked.ok && String(picked.path || "").length > 0) {
            if (root.timemachineRoute)
                timemachineController.setOption("output_folder", String(picked.path || ""))
            else if (root.isWorkRoute && root.hasWorkController && workPanelController.setRouteOption)
                workPanelController.setRouteOption(root.route, "output_folder", String(picked.path || ""))
            else
                masterOptionsController.setFolder(String(picked.path || ""))
        }
    }

    function batchConfigValue(key, fallback) {
        var cfg = root.currentBatchConfig || ({})
        if (cfg[key] !== undefined && cfg[key] !== null && String(cfg[key]).length > 0)
            return cfg[key]
        return fallback
    }

    function requestBatchConfigPatch(patch) {
        if (typeof workPanelController === "undefined" || !workPanelController || !workPanelController.executePrimitiveAction)
            return
        var cfg = root.currentBatchConfig || ({})
        var data = patch || ({})
        workPanelController.executePrimitiveAction("work_panel.batch_config_patch", {
            source: "batch_top_config",
            variations: Number(data.variations !== undefined ? data.variations : (cfg.variations || 10)),
            anti_duplicate: cfg.anti_duplicate === undefined ? true : Boolean(cfg.anti_duplicate),
            instructions: String(cfg.instructions || ""),
            character_strategy: String(cfg.character_strategy || "inherit"),
            variation_strength: String(cfg.variation_strength || "balanced"),
            aspect_ratio: String(data.aspect_ratio !== undefined ? data.aspect_ratio : (cfg.aspect_ratio || "16:9")),
            model: String(data.model !== undefined ? data.model : (cfg.model || "GEM_PIX_2")),
            resolution: data.resolution !== undefined ? String(data.resolution || "") : String(cfg.resolution || "")
        })
    }

    Layout.fillWidth: true
    implicitHeight: mainColumn.implicitHeight + VfTheme.dp(14)
    radius: VfTheme.radiusPanel
    color: VfTheme.canvas
    border.color: VfTheme.borderBox
    border.width: 1

    ColumnLayout {
        id: mainColumn
        anchors.fill: parent
        anchors.margins: VfTheme.dp(7)
        spacing: VfTheme.dp(6)

    GridLayout {
        id: configGrid
        Layout.fillWidth: true
        columns: root.configColumns
        rowSpacing: VfTheme.dp(6)
        columnSpacing: VfTheme.dp(6)

        VfSelectField {
            objectName: "cfgAspect"
            visible: !root.batchRoute
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("qml.master.aspect", "Aspect"))
            options: root.options.aspects || []
            value: root.config.aspect_ratio || "16:9"
            accent: VfTheme.cyan
            onSelected: value => root.writeOption("aspect_ratio", value)
        }

        VfSelectField {
            objectName: "cfgQuality"
            // Dual-output routes keep one quality selector for both resolved branches:
            // 720p video -> base image, 1080p video -> 2K image, 4K -> 4K.
            visible: !root.batchRoute && (!root.imageMode || root.dualOutputRoute)
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("qml.master.quality", "Quality"))
            options: root.options.qualities || []
            value: root.config.quality || "720p"
            accent: VfTheme.amber
            onSelected: value => root.writeOption("quality", value)
        }

        VfSelectField {
            objectName: "cfgModel"
            // Non-clone video routes only. Clone video knobs live on output branch row.
            visible: !root.batchRoute && root.mainVideoBranchConfig
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("config_panel.model", "Model"))
            options: root.options.models || []
            value: root.config.model_key || ""
            accent: VfTheme.violet
            onSelected: value => root.writeOption("model_key", value)
        }

        VfSelectField {
            objectName: "cfgGenrePack"
            // Genre tạm ẩn ở config bar — sẽ chuyển về khu nhập ý tưởng
            // (MasterPromptScreen Step 1) dưới dạng grid dialog chọn thể loại.
            // Config key + options payload vẫn chạy, chỉ thiếu UI.
            visible: false
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("config_panel.genre", "Content Genre"))
            options: root.options.templates || []
            value: root.config.template_name || ""
            accent: VfTheme.greenBorder
            onSelected: value => root.writeOption("template_name", value)
        }

        VfValueField {
            actionId: "master.config.folder_picker"
            label: (void i18n.revision, i18n.t("master.save_folder", "Save Folder"))
            value: root.config.output_folder || ""
            placeholder: (void i18n.revision, i18n.t("master.not_selected", "Not Selected"))
            actionText: (void i18n.revision, i18n.t("common.set", "Set"))
            accent: VfTheme.cyan
            onActivated: root.openFolderPicker(root.config.output_folder || "")
        }

        VfValueField {
            actionId: "master.config.style_manager"
            visible: true
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("config_panel.style", "Style"))
            value: root.selectedStyleSummary()
            placeholder: root.timemachineRoute
                ? "Giữ phong cách ảnh gốc"
                : (void i18n.revision, i18n.t("common.default", "Default"))
            actionText: (void i18n.revision, i18n.t("common.edit", "Edit"))
            accent: VfTheme.violet
            onActivated: {
                masterOptionsController.refreshStyles("")
                root.withStyleManager(function(dialog) { dialog.openBucket("style") })
            }
        }

        VfSelectField {
            objectName: "cfgMarket"
            // Normal route gen video không cần target-market => ẩn (mặc định "global").
            // Affiliate: Thị trường chuyển XUỐNG cạnh Ngôn ngữ trong job builder => ẩn ở top.
            visible: !root.batchRoute && !root.normalRoute && !root.affiliateRoute
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("config_panel.market", "Market"))
            options: root.options.markets || []
            iconRole: "flag"
            value: root.config.market || "global"
            accent: VfTheme.greenBorder
            onSelected: value => root.writeOption("market", value)
        }

        VfSelectField {
            objectName: "cfgCloneDialogueLanguage"
            // Clone: ngôn ngữ thoại cạnh Thị trường (market → dialogue sync).
            visible: root.cloneRoute
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("clone.dialogue_language", "Ngôn ngữ thoại"))
            options: root.hasWorkController
                ? (workPanelController.cloneDialogueLanguageOptions || [])
                : []  // perf-lint: disable=R2 static config catalog
            iconRole: "flag"
            value: String((root.config || {}).dialogue_language || "")
            accent: VfTheme.violet
            onSelected: value => root.writeCloneDialogueLanguage(value)
        }

        VfSelectField {
            objectName: "cfgOutputLanguage"
            visible: root.timemachineRoute
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: "Ngôn ngữ nội dung"
            options: root.options.languages || []
            iconRole: "flag"
            value: root.config.language || "vi"
            accent: VfTheme.cyan
            onSelected: value => root.writeOption("language", value)
        }

        VfSelectField {
            visible: root.showNormalOutput
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("config_panel.output_count", "Output"))
            options: root.options.output_counts || []
            value: root.config.output_count || 1
            accent: VfTheme.cyan
            onSelected: value => root.writeOption("output_count", value)
        }

        VfSelectField {
            visible: root.showModelDuration
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("master.model_duration", "Model Duration"))
            options: root.options.model_durations || []
            value: root.config.clip_duration_seconds || root.config.duration || 0
            accent: VfTheme.amber
            onSelected: value => root.writeOption("clip_duration_seconds", parseInt(value) || 8)
        }

        // NOTE: The idea/total "Duration" control was moved out of this top
        // config bar into the Step 1 idea-input area (MasterPromptScreen.qml),
        // where it is hidden in script mode. The top bar keeps only the
        // per-clip "Clip" duration below, which configures the model's clip
        // length and is independent of the idea total duration.

        VfSelectField {
            objectName: "cfgClipDuration"
            // Clip duration LÀ config (giống pyqt6 show_duration). Hiện ở master
            // prompt CẢ idea LẪN script (mỗi cảnh script vẫn thành 1 clip video, gen
            // dùng model+clip qua _build_master_pipeline_config) và clone. Trước đây
            // ẩn ở script mode là sai vì backend vẫn dùng clip/model lúc dispatch.
            // Pure IMAGE: clip cố định vô nghĩa. Clone clip lives on output branch row.
            visible: (root.masterPromptRoute || root.cloneRoute) && root.mainVideoBranchConfig
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("config_panel.clip_duration", "Clip"))
            options: root.options.model_durations || []
            value: String(root.config.clip_duration_seconds || "8")
            accent: VfTheme.amber
            onSelected: value => root.writeOption("clip_duration_seconds", parseInt(value) || 8)
        }

        VfSelectField {
            visible: root.showFilename
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("config_panel.filename_format", "Filename"))
            options: root.options.filename_formats || []
            value: root.config.filename_format || "number"
            accent: VfTheme.violet
            onSelected: value => root.writeOption("filename_format", value)
        }

        VfSelectField {
            visible: root.batchRoute
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("batch_image.aspect_dropdown", "Aspect"))
            options: [
                { label: "16:9", value: "16:9" },
                { label: "4:3", value: "4:3" },
                { label: "1:1", value: "1:1" },
                { label: "3:4", value: "3:4" },
                { label: "9:16", value: "9:16" }
            ]
            value: String(root.batchConfigValue("aspect_ratio", "16:9"))
            accent: VfTheme.cyan
            onSelected: value => root.requestBatchConfigPatch({ aspect_ratio: value })
        }

        VfSelectField {
            // Batch still owns an image-native quality selector. Dual-output routes
            // use cfgQuality above so AUTO/Ảnh/Video cannot drift apart.
            visible: root.batchRoute || (root.imageMode && !root.dualOutputRoute)
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("batch_image.quality_dropdown", "Quality"))
            // 4K image upscale = ULTRA-only (creditMapping INTERMEDIATE=UNAVAILABLE).
            // PRO chỉ thấy 2K. account_tier = mode đang chạy (master config).
            options: {
                var opts = [
                    { label: (void i18n.revision, i18n.t("common.default", "Default")), value: "" }
                ]
                opts.push({ label: "2K", value: "2K" })
                if (String((masterOptionsController.config || {}).account_tier || "").toLowerCase() === "ultra")
                    opts.push({ label: "4K", value: "4K" })
                return opts
            }
            value: root.batchRoute
                ? String(root.batchConfigValue("resolution", ""))
                : String((root.config || {}).image_resolution || "")
            accent: VfTheme.amber
            onSelected: value => {
                if (root.batchRoute)
                    root.requestBatchConfigPatch({ resolution: value })
                else
                    root.writeOption("image_resolution", value)
            }
        }

        VfSelectField {
            objectName: "cfgImageModel"
            // Non-clone image / batch only. Clone image knobs live on output branch row.
            visible: root.batchRoute || root.mainImageBranchConfig
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("batch_image.model_dropdown", "Model"))
            options: root.options.image_models || []
            value: root.batchRoute
                ? String(root.batchConfigValue("model", root.options.default_image_model || ""))
                : String((root.config || {}).image_model || root.options.default_image_model || "")
            accent: VfTheme.violet
            onSelected: value => {
                if (root.batchRoute)
                    root.requestBatchConfigPatch({ model: value })
                else
                    root.writeOption("image_model", value)
            }
        }

        VfSelectField {
            // One authority only. Compatibility image_pacing/image_count_* keys are
            // derived atomically by the backend Image Rhythm Framework.
            objectName: "cfgImageRhythm"
            visible: root.mainImageBranchConfig
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("config_panel.image_pacing", "Nhịp ảnh"))
            options: (root.transcriptRoute || root.cloneRoute) ? [
                { label: (void i18n.revision, i18n.t("config_panel.rhythm_auto", "Auto theo nội dung")), value: "auto" },
                { label: (void i18n.revision, i18n.t("config_panel.rhythm_fixed", "Đúng số ảnh chỉ định")), value: "fixed" },
                { label: (void i18n.revision, i18n.t("config_panel.rhythm_single", "Một ảnh xuyên suốt")), value: "single" },
                { label: (void i18n.revision, i18n.t("config_panel.rhythm_template", "Mẫu nhịp theo chủ đề")), value: "template" },
                { label: (void i18n.revision, i18n.t("config_panel.pacing_detailed", "Phân tích đầy đủ — mỗi nhịp ý nghĩa/ảnh")), value: "detailed" },
                { label: (void i18n.revision, i18n.t("config_panel.pacing_moderate", "Cân bằng — khoảng 1-3 phút/ảnh")), value: "balanced" },
                { label: (void i18n.revision, i18n.t("config_panel.pacing_sparse", "Theo chương — khoảng 3-8 phút/ảnh")), value: "chapter" }
            ] : [
                { label: (void i18n.revision, i18n.t("config_panel.rhythm_auto", "Auto theo nội dung")), value: "auto" },
                { label: (void i18n.revision, i18n.t("config_panel.rhythm_template", "Mẫu nhịp theo chủ đề")), value: "template" },
                { label: (void i18n.revision, i18n.t("config_panel.pacing_detailed", "Phân tích đầy đủ")), value: "detailed" },
                { label: (void i18n.revision, i18n.t("config_panel.pacing_moderate", "Cân bằng")), value: "balanced" },
                { label: (void i18n.revision, i18n.t("config_panel.pacing_sparse", "Theo chương")), value: "chapter" }
            ]
            value: root.imageRhythmMode()
            accent: VfTheme.cyan
            tooltip: (void i18n.revision, i18n.t(
                "config_panel.rhythm_tooltip",
                "Chỉ một chế độ được quyền quyết định số ảnh. Backend khóa manifest và không cho tầng dựng tự đổi số cảnh."))
            onSelected: value => root.writeOption("image_rhythm_mode", value)
        }

        VfTextField {
            objectName: "cfgImageRhythmTarget"
            visible: root.mainImageBranchConfig
                && (root.transcriptRoute || root.cloneRoute)
                && root.imageRhythmMode() === "fixed"
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("config_panel.rhythm_target", "Số ảnh chính xác"))
            value: String(root.imageRhythmTarget())
            placeholder: "6"
            accent: VfTheme.cyan
            onCommitted: function(value) {
                var target = Math.max(1, Math.min(9999, Number(value) || root.imageRhythmTarget()))
                root.writeOption("image_rhythm_target", Math.round(target))
            }
        }

        VfSelectField {
            objectName: "cfgImageRhythmTemplate"
            visible: root.mainImageBranchConfig
                && (root.transcriptRoute || root.cloneRoute)
                && root.imageRhythmMode() === "template"
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("config_panel.rhythm_template", "Mẫu chủ đề"))
            options: root.imageRhythmTemplateOptions()
            value: root.imageRhythmTemplateId()
            accent: VfTheme.cyan
            tooltip: (void i18n.revision, i18n.t(
                "config_panel.template_tooltip",
                "Tự động: LLM nghe audio tự chọn mẫu. Chọn thủ công: ép đường cong mật độ theo chủ đề."))
            onSelected: value => root.writeOption("image_rhythm_template_id", value)
        }

        VfSelectField {
            visible: root.batchRoute
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: (void i18n.revision, i18n.t("batch_image.quantity_dropdown", "Images"))
            options: [
                { label: "x1", value: 1 },
                { label: "x2", value: 2 },
                { label: "x3", value: 3 },
                { label: "x5", value: 5 },
                { label: "x10", value: 10 },
                { label: "x20", value: 20 },
                { label: "x50", value: 50 },
                { label: "x100", value: 100 }
            ]
            value: Number(root.batchConfigValue("variations", 10))
            accent: VfTheme.greenBorder
            onSelected: value => root.requestBatchConfigPatch({ variations: Number(value) })
        }

        VfSelectField {
            objectName: "cfgTimeMachineImageModel"
            visible: root.timemachineRoute
            Layout.preferredHeight: visible ? implicitHeight : 0
            label: "Model ảnh"
            options: root.options.image_models || []
            value: root.config.image_model || "NARWHAL"
            accent: VfTheme.violet
            onSelected: value => root.writeOption("image_model", value)
        }

    }

    // Dual output + branch config (Clone + A2V) — stable dual row. Both VIDEO and
    // ẢNH halves stay mounted; exclusive mode only disables the inactive half.
    Rectangle {
        id: dualOutputBranchRow
        objectName: root.cloneRoute ? "cloneAutoDualOutputRow" : "transcriptAutoDualOutputRow"
        visible: root.showDualOutputBranchRow
        Layout.fillWidth: true
        // VfSelectField needs full fieldHeight (label + combo). Fixed 52dp + clip
        // was shaving the field labels (Đầu ra / Model / Nhịp / Draw).
        Layout.preferredHeight: visible ? (VfTheme.fieldHeight + VfTheme.dp(12)) : 0
        Layout.minimumHeight: visible ? (VfTheme.fieldHeight + VfTheme.dp(12)) : 0
        radius: VfTheme.radiusControl
        color: VfTheme.surfaceSoft
        border.color: root.dualAutoMode ? VfTheme.violetBorder : VfTheme.borderSoft
        border.width: 1
        clip: false

        RowLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(6)
            spacing: VfTheme.dp(6)

            VfSelectField {
                objectName: root.cloneRoute ? "cloneOutputMode" : "transcriptOutputMode"
                Layout.preferredWidth: VfTheme.dp(168)
                Layout.maximumWidth: VfTheme.dp(190)
                Layout.fillWidth: false
                Layout.preferredHeight: implicitHeight
                Layout.alignment: Qt.AlignVCenter
                label: (void i18n.revision, i18n.t("clone.output_mode", "Đầu ra"))
                options: root.dualOutputModeOptions()
                value: root.dualOutputMode || (root.cloneRoute ? "auto" : "video")
                accent: VfTheme.violet
                onSelected: value => root.writeOption("output_mode", value)
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: VfTheme.dp(28)
                Layout.alignment: Qt.AlignVCenter
                color: root.dualVideoBranchEnabled ? VfTheme.blueBorder : VfTheme.border
                opacity: root.dualVideoBranchEnabled ? 1.0 : 0.45
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: root.dualAutoMode
                    ? (void i18n.revision, i18n.t("clone.auto_if_video", "NẾU → VIDEO"))
                    : (void i18n.revision, i18n.t("clone.branch_video", "VIDEO"))
                color: root.dualVideoBranchEnabled ? VfTheme.blueText : VfTheme.textSubtle
                opacity: root.dualVideoBranchEnabled ? 1.0 : 0.55
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: Font.Bold
            }

            VfSelectField {
                objectName: "cfgAutoVideoModel"
                enabled: root.dualVideoBranchEnabled
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.preferredHeight: implicitHeight
                Layout.alignment: Qt.AlignVCenter
                label: (void i18n.revision, i18n.t("clone.auto_video_model", "Model video"))
                options: root.options.models || []
                value: root.config.model_key || ""
                accent: VfTheme.blueBorder
                onSelected: value => root.writeOption("model_key", value)
            }

            VfSelectField {
                objectName: "cfgAutoVideoClip"
                enabled: root.dualVideoBranchEnabled
                Layout.preferredWidth: VfTheme.dp(110)
                Layout.maximumWidth: VfTheme.dp(130)
                Layout.preferredHeight: implicitHeight
                Layout.alignment: Qt.AlignVCenter
                label: (void i18n.revision, i18n.t("clone.auto_video_clip", "Clip"))
                options: root.options.model_durations || []
                value: String(root.config.clip_duration_seconds || "8")
                accent: VfTheme.amber
                onSelected: value => root.writeOption("clip_duration_seconds", parseInt(value) || 8)
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: VfTheme.dp(28)
                Layout.alignment: Qt.AlignVCenter
                color: VfTheme.borderSoft
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: root.dualAutoMode
                    ? (void i18n.revision, i18n.t("clone.auto_if_image", "NẾU → ẢNH"))
                    : (void i18n.revision, i18n.t("clone.branch_image", "ẢNH"))
                color: root.dualImageBranchEnabled ? VfTheme.cyanText : VfTheme.textSubtle
                opacity: root.dualImageBranchEnabled ? 1.0 : 0.55
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: Font.Bold
            }

            VfSelectField {
                objectName: "cfgAutoImageModel"
                enabled: root.dualImageBranchEnabled
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.preferredHeight: implicitHeight
                Layout.alignment: Qt.AlignVCenter
                label: (void i18n.revision, i18n.t("clone.auto_image_model", "Model ảnh"))
                options: root.options.image_models || []
                value: String((root.config || {}).image_model || root.options.default_image_model || "")
                accent: VfTheme.cyanBorder
                onSelected: value => root.writeOption("image_model", value)
            }

            VfSelectField {
                objectName: "cfgAutoImageRhythm"
                visible: !root.timemachineRoute
                enabled: root.dualImageBranchEnabled && visible
                Layout.fillWidth: visible
                Layout.preferredWidth: visible ? 1 : 0
                Layout.preferredHeight: implicitHeight
                Layout.alignment: Qt.AlignVCenter
                label: (void i18n.revision, i18n.t("config_panel.image_pacing", "Nhịp ảnh"))
                options: root.dualImageRhythmOptions()
                value: root.imageRhythmMode()
                accent: VfTheme.cyan
                onSelected: value => root.writeOption("image_rhythm_mode", value)
            }

            VfTextField {
                objectName: "cfgAutoImageRhythmTarget"
                // Only the fixed-count field may collapse; VIDEO/ẢNH halves stay mounted.
                visible: !root.timemachineRoute && root.imageRhythmMode() === "fixed"
                enabled: root.dualImageBranchEnabled && visible
                Layout.preferredWidth: visible ? VfTheme.dp(110) : 0
                Layout.maximumWidth: VfTheme.dp(120)
                Layout.preferredHeight: visible ? implicitHeight : 0
                Layout.alignment: Qt.AlignVCenter
                label: (void i18n.revision, i18n.t("config_panel.rhythm_target", "Số ảnh"))
                value: String(root.imageRhythmTarget())
                placeholder: "6"
                accent: VfTheme.cyan
                onCommitted: function(value) {
                    if (!root.dualImageBranchEnabled || root.imageRhythmMode() !== "fixed")
                        return
                    var target = Math.max(1, Math.min(9999, Number(value) || root.imageRhythmTarget()))
                    root.writeOption("image_rhythm_target", Math.round(target))
                }
            }

            VfSelectField {
                objectName: "cfgAutoImageRhythmTemplate"
                visible: !root.timemachineRoute && root.imageRhythmMode() === "template"
                enabled: root.dualImageBranchEnabled && visible
                Layout.fillWidth: visible
                Layout.preferredWidth: visible ? 1 : 0
                Layout.preferredHeight: implicitHeight
                Layout.alignment: Qt.AlignVCenter
                label: (void i18n.revision, i18n.t("config_panel.rhythm_template", "Mẫu chủ đề"))
                options: root.imageRhythmTemplateOptions()
                value: root.imageRhythmTemplateId()
                accent: VfTheme.cyan
                onSelected: value => {
                    if (!root.dualImageBranchEnabled || root.imageRhythmMode() !== "template")
                        return
                    root.writeOption("image_rhythm_template_id", value)
                }
            }

            // Draw = toggle ON/OFF + configure (style/hand) only when ON.
            // Do not force Style Manager just to disable Draw.
            VfToolbarSwitch {
                objectName: root.cloneRoute ? "cloneMasterDrawMode" : "transcriptMasterDrawMode"
                visible: !root.timemachineRoute
                enabled: root.dualImageBranchEnabled && visible
                Layout.preferredWidth: visible ? implicitWidth : 0
                Layout.preferredHeight: VfTheme.dp(34)
                Layout.alignment: Qt.AlignVCenter
                minWidth: VfTheme.dp(118)
                actionId: root.cloneRoute
                    ? "work_panel.clone_draw_toggle"
                    : "work_panel.transcript_draw_toggle"
                text: root.dualDrawEnabled
                    ? (void i18n.revision, i18n.t("clone.draw_mode_on", "Draw: Bật"))
                    : (void i18n.revision, i18n.t("clone.draw_mode_off", "Draw: Tắt"))
                tooltip: (void i18n.revision, i18n.t(
                    "clone.draw_toggle_hint",
                    "Bật/tắt Draw ngay tại đây. Khi bật, backend dựng Draw cho mọi cảnh ảnh; với Đầu ra Tự động chỉ chạy nếu hệ thống phân loại ra Ảnh. Dùng nút Cấu hình để chọn Draw Style và tay/bút."))
                    + "\n" + (void i18n.revision, i18n.t("clone.draw_hand_current", "Tay/bút hiện tại"))
                    + ": " + String((root.config || {}).image_motion_hand_asset || "auto")
                checked: root.dualDrawEnabled
                accent: "#F59E0B"
                onToggled: function(enabled) {
                    if (!root.dualImageBranchEnabled)
                        return
                    if (enabled) {
                        var styleId = String((root.config || {}).structural_style_id
                            || (root.config || {}).style_id || "")
                        if (!styleId.length
                                || !masterOptionsController.isDrawStyleConfigured(styleId)) {
                            // Keep the route OFF until the user explicitly binds a
                            // profile. This prevents backend "unsupported" skips.
                            root.openDrawManagerExternal()
                            return
                        }
                    }
                    root.writeOption("image_motion_mode", enabled ? "auto" : "off")
                }
            }

            VfButton {
                objectName: root.cloneRoute ? "cloneMasterDrawConfig" : "transcriptMasterDrawConfig"
                visible: !root.timemachineRoute
                enabled: root.dualImageBranchEnabled && root.dualDrawEnabled && visible
                Layout.preferredWidth: visible ? implicitWidth : 0
                Layout.preferredHeight: VfTheme.controlHeight
                Layout.alignment: Qt.AlignVCenter
                compact: true
                minWidth: VfTheme.dp(88)
                actionId: root.cloneRoute
                    ? "work_panel.clone_draw_settings"
                    : "work_panel.transcript_draw_settings"
                tone: (root.dualImageBranchEnabled && root.dualDrawEnabled) ? "accent" : "neutral"
                text: (void i18n.revision, i18n.t("clone.draw_configure", "Cấu hình"))
                tooltip: root.dualDrawEnabled
                    ? (void i18n.revision, i18n.t(
                        "clone.draw_configure_hint",
                        "Chọn Draw Style, actor (Auto/Move/Tay+bút/Chỉ bút) và tay/bút."))
                    : (void i18n.revision, i18n.t(
                        "clone.draw_configure_disabled_hint",
                        "Bật Draw trước rồi mới cấu hình style/tay."))
                onClicked: {
                    if (!root.dualImageBranchEnabled || !root.dualDrawEnabled)
                        return
                    root.openDrawManagerExternal()
                }
            }
        }
    }

    } // mainColumn


    // StyleManagerDialog is a large Popup tree (including the hand/pen library).
    // Work routes are preloaded off-screen and kept alive, so eagerly constructing
    // one manager per route makes multiple hidden delegate trees rebuild together
    // during master -> work route swaps. Qt can then evaluate delegates while their
    // model scope is being replaced ("Cannot find member data") and crash natively.
    // Load the tree only for an explicit open request, matching the media dialogs.
    Loader {
        id: styleManagerDialogLoader
        active: false
        sourceComponent: StyleManagerDialog {
            styles: masterOptionsController.styles
        // Clone is the only route with a source video to derive a look from.
        allowAutoStyle: root.cloneRoute
        topicGenerationBusy: masterOptionsController.styleTopicBusy
        previewGenerationBusy: masterOptionsController.stylePreviewBusy
        motionPreviewBusy: masterOptionsController.drawMotionPreviewBusy
        selectedId: root.config.structural_style_id || root.config.style_id || root.config.surface_style_id || root.config.camera_id || root.config.structural_camera_id || ""
        selectedCameraId: root.config.camera_id || root.config.structural_camera_id || root.config.surface_camera_id || ""
        selectedStyleId: root.config.structural_style_id || root.config.style_id || ""
        selectedSurfaceStyleId: (root.config.surface_style_id
                                 && root.config.surface_style_id !== (root.config.structural_style_id || root.config.style_id))
            ? root.config.surface_style_id : ""
        // Clone Auto may still resolve to image, so keep Draw package editable
        // whenever the route can produce stills (explicit image OR auto).
        drawMotionAvailable: (root.cloneRoute || root.transcriptRoute)
            && root.showImageBranchConfig
        initialDrawMotionEnabled: String(root.config.image_motion_mode || "off") === "auto"
        initialActorMode: String(root.config.image_motion_actor_mode || "auto")
        handAssetOptions: root.hasWorkController
            ? (workPanelController.imageMotionHandOptions || []) : []  // perf-lint: disable=R2 static catalog
        savedDrawHandAssignments: masterOptionsController.drawStyleHandBindings || ({})
        savedDrawMotionProfiles: masterOptionsController.drawStyleMotionProfiles || ({})
        initialHandAssetId: String(root.config.image_motion_hand_asset || "auto")
        statusMessage: masterOptionsController.statusMessage
        onRefreshRequested: function(search) {
            masterOptionsController.refreshStyles(search || "")
        }
        onApplyRequested: selection => {
            var sel = selection || ({})
            if (root.timemachineRoute) {
                var timeMachineResult = timemachineController.setStyleSelection(sel)
                if (!timeMachineResult || timeMachineResult.ok !== false)
                    styleManagerDialog.accept()
            } else if (root.isWorkRoute && root.hasWorkController && workPanelController.setRouteOptions) {
                // Per-route: write the chosen style/camera ids to THIS tab's config
                // (the controller resolves name/prompt from the ids). No master write,
                // so picking a style on one tab does not change the others.
                var autoStyle = Boolean(sel.auto_style_framework)
                // "Auto from source video" (clone only): clear every manual style/camera
                // so the clone runs its Phase-0 look extraction instead. A real pick sends
                // the ids and turns the flag off.
                var opts = {
                    auto_style_framework: autoStyle,
                    style_id: autoStyle ? "" : String(sel.style_id || ""),
                    camera_id: autoStyle ? "" : String(sel.camera_id || ""),
                    structural_style_id: autoStyle ? "" : String(sel.structural_style_id || sel.style_id || ""),
                    structural_camera_id: autoStyle ? "" : String(sel.structural_camera_id || sel.camera_id || ""),
                    surface_style_id: autoStyle ? "" : String(sel.surface_style_id || ""),
                    surface_camera_id: autoStyle ? "" : String(sel.surface_camera_id || "")
                }
                if (Boolean(sel.draw_motion_configured)) {
                    opts.image_motion_mode = String(sel.image_motion_mode || "off") === "auto"
                        ? "auto" : "off"
                    opts.image_motion_hand_asset = String(sel.image_motion_hand_asset || "auto")
                    opts.image_motion_actor_mode = String(sel.image_motion_actor_mode || "auto")
                }
                if (autoStyle) {
                    // Also clear the fields the bulk "apply style to all" path can leave behind,
                    // else _has_manual_clone_style would still see a stale manual pick.
                    opts.selected_style_id = ""
                    opts.selected_style = ""
                    opts.selected_style_name = ""
                    opts.use_ai_style = true
                }
                workPanelController.setRouteOptions(root.route, opts)
                styleManagerDialog.accept()
            } else {
                var result = masterOptionsController.selectStyleSelection(sel)
                if (!result || result.ok !== false)
                    styleManagerDialog.accept()
            }
        }
        onAddRequested: kind => styleEditDialog.openNew(kind || "style")
        onEditRequested: style => {
            var item = style || ({})
            var styleId = String(item.id || item.style_id || "")
            if (styleId.length > 0) {
                var previewInfo = masterOptionsController.stylePreview(styleId)
                if (previewInfo && previewInfo.ok !== false)
                    item.preview_state = previewInfo
            }
            styleEditDialog.openFor(item)
        }
        onDeleteRequested: styleId => styleManagerDialog.applyDeleteResult(masterOptionsController.deleteStyle(styleId))
        onDeleteTopicRequested: topicId => styleManagerDialog.applyDeleteTopicResult(masterOptionsController.deleteStyleTopic(topicId))
        onToggleFavoriteRequested: styleId => styleManagerDialog.applyToggleFavoriteResult(masterOptionsController.toggleStyleFavorite(styleId))
        onSaveHandBindingRequested: function(styleId, assetId) {
            masterOptionsController.setDrawStyleHandBinding(styleId, assetId)
        }
        onSaveDrawProfileRequested: function(styleId, actorMode, assetId) {
            masterOptionsController.setDrawStyleMotionProfile(
                styleId, actorMode, assetId)
        }
        onMotionPreviewRequested: function(styleId, actorMode, handAsset, force) {
            masterOptionsController.requestDrawMotionPreview(
                styleId, actorMode, handAsset, force)
        }
        onPreviewInfoRequested: styleId => {
            var result = masterOptionsController.stylePreview(styleId)
            styleManagerDialog.applyPreviewInfoResult(result)
        }
        onGeneratePreviewRequested: style => {
            var accepted = masterOptionsController.requestStylePreviewGeneration(style || ({}))
            if (accepted && accepted.ok === false)
                styleManagerDialog.applyGeneratePreviewResult(accepted)
        }
        onComboPreviewRequested: selection => {
            // AI fuses the selected styles, generates one combined image, saves it.
            var accepted = masterOptionsController.requestStyleComboPreviewGeneration(selection || ({}))
            if (accepted && accepted.ok === false)
                styleManagerDialog.applyGeneratePreviewResult(accepted)
        }
        onBulkPreviewRequested: (items, onlyMissing) => {
            var currentStyleId = ""
            if (styleManagerDialog.currentItem && styleManagerDialog.itemId(styleManagerDialog.currentItem).length > 0)
                currentStyleId = styleManagerDialog.itemId(styleManagerDialog.currentItem)
            var accepted = masterOptionsController.requestStylePreviewBulk(items || [], onlyMissing, currentStyleId)
            if (accepted && accepted.ok === false)
                styleManagerDialog.applyBulkPreviewResult(accepted, ({}))
        }
        onTopicGenerateRequested: payload => {
            // Curator v2: propose (curate medium + author surface) → review dialog.
            // Nothing is saved until the user picks in StyleTopicProposalDialog.
            masterOptionsController.requestStyleTopicProposal(payload || ({}))
        }

        Connections {
            target: masterOptionsController
            function onDrawMotionPreviewGenerated(result) {
                styleManagerDialog.applyMotionPreviewResult(result || ({}))
            }
            function onStylePreviewGenerated(result) {
                var payload = result || ({})
                if (String(payload.action || "") === "master.config.generate_style_preview_bulk")
                    styleManagerDialog.applyBulkPreviewResult(payload, payload.refreshed_preview || ({}))
                else
                    styleManagerDialog.applyGeneratePreviewResult(payload)
                // Curator v2: refresh a proposal card's thumbnail if it's open.
                if (styleTopicProposalDialog.visible)
                    styleTopicProposalDialog.applyPreviewResult(payload)
            }
            function onStyleTopicProposed(result) {
                styleTopicProposalDialog.openWith(result || ({}))
            }
        }
        }
    }

    Connections {
        target: styleManagerDialogLoader.item
        ignoreUnknownSignals: true

        function onClosed() {
            // A hidden manager still owns a large delegate/model tree. Release it
            // after close so later route swaps cannot rebuild that off-screen tree.
            Qt.callLater(function() {
                var dialog = root.styleManagerDialog
                if (dialog && dialog.opened)
                    return
                styleManagerDialogLoader.active = false
            })
        }
    }

    StyleTopicProposalDialog {
        id: styleTopicProposalDialog
        onCommitRequested: payload => {
            // Persist only the approved proposals; controller refreshes the library
            // + topic tree via styleTopicGenerated.
            masterOptionsController.commitStyleTopic(payload || ({}))
        }
        onPreviewRequested: proposal => {
            var p = proposal || ({})
            masterOptionsController.requestStylePreviewGeneration({
                id: String(p.style_id || ""),
                style_id: String(p.style_id || ""),
                name: String(p.name || ""),
                kind: "style",
                veo3_prompt: String(p.preview_prompt || ""),
                preview_prompt: String(p.preview_prompt || "")
            })
        }
    }

    StyleEditDialog {
        id: styleEditDialog
        aiBusy: typeof masterOptionsController !== "undefined" && masterOptionsController
            ? masterOptionsController.styleAiBusy
            : false
        aiPhaseKey: typeof masterOptionsController !== "undefined" && masterOptionsController
            ? String(masterOptionsController.styleAiPhase || "")
            : ""
        onSavePayloadRequested: payload => {
            var result = masterOptionsController.saveStyle(
                String((payload || {}).styleId || ""),
                String((payload || {}).name || ""),
                String((payload || {}).prompt || ""),
                String((payload || {}).kind || "style"),
                String((payload || {}).description || ""),
                String((payload || {}).framework_json || "")
            )
            var savedStyle = (result && (result.style || result.item)) || ({})
            var savedStyleId = String(savedStyle.id || savedStyle.style_id || "")
            var savedKind = String(savedStyle.kind || (payload || {}).kind || "style")
            var savedAsDraw = String(savedStyle.authoring_mode || (payload || {}).kind || "").toLowerCase() === "draw"
                || String(savedStyle.topic_id || "").toLowerCase() === "draw_motion_2d"
            if (result && result.ok !== false && savedStyleId.length > 0) {
                styleManagerDialog.selectedId = savedStyleId
                if (savedKind === "camera") {
                    styleManagerDialog.activeBucketIndex = styleManagerDialog.bucketIndexForKey("style")
                    styleManagerDialog.selectedCameraId = savedStyleId
                } else {
                    styleManagerDialog.activeBucketIndex = styleManagerDialog.bucketIndexForKey(savedAsDraw ? "draw" : "style")
                    if (styleManagerDialog.selectedStyleId.length > 0 && styleManagerDialog.selectedStyleId !== savedStyleId)
                        styleManagerDialog.selectedSurfaceStyleId = savedStyleId
                    else
                        styleManagerDialog.selectedStyleId = savedStyleId
                }
                styleManagerDialog.selectFromCurrentId()
            }
            styleEditDialog.applySaveResult(result, payload || ({}))
        }
        onAiGeneratePreviewRequested: payload => {
            // statusText + phase animation driven by StyleEditDialog.aiBusy
            masterOptionsController.requestStyleAiGeneration(payload || ({}), true)
        }
        onChooseReferenceRequested: {
            var picked = nativeShell.pickFiles(
                (void i18n.revision, i18n.t("styles_mgmt_v3.choose_image", "Choose reference image")),
                "Images (*.png *.jpg *.jpeg *.webp);;All Files (*.*)",
                styleEditDialog.referenceImagePath || ""
            )
            if (picked && picked.ok && picked.paths && picked.paths.length > 0) {
                styleEditDialog.referenceImagePath = String(picked.paths[0] || "")
                styleEditDialog.statusText = "Reference image selected."
            }
        }
        onPasteReferenceRequested: {
            var pasted = nativeShell.pasteImageFromClipboard("veoflow-style-reference-", ".png")
            if (pasted && pasted.ok && String(pasted.path || "").length > 0) {
                styleEditDialog.referenceImagePath = String(pasted.path || "")
                styleEditDialog.statusText = (void i18n.revision, i18n.t("style_edit.reference_pasted", "Reference image pasted from clipboard."))
            } else {
                styleEditDialog.statusText = String((pasted || {}).message || (void i18n.revision, i18n.t("style_edit.reference_clipboard_empty", "Clipboard does not contain a usable image.")))
            }
        }
    }

    Connections {
        target: masterOptionsController

        function onStyleAiGenerated(result) {
            if (!styleEditDialog.visible)
                return
            styleEditDialog.applyAiPayload(result || ({}))
        }

        function onStyleTopicGenerated(result) {
            var dialog = root.styleManagerDialog
            if (!dialog || !dialog.visible)
                return
            dialog.applyTopicGenerateResult(result || ({}))
        }
    }

    Connections {
        target: masterOptionsController
        function onPendingDialogChanged() {
            root.openPendingDialogIfRequested()
        }
    }

    Component.onCompleted: {
        masterOptionsController.refresh()
        root.openPendingDialogIfRequested()
    }
}
