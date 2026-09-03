import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtCore

import "components"
import "dialogs"
import "screens"
import "theme"
import "components/TourData.js" as TourData

ApplicationWindow {
    id: window

    // Start at the compact splash size — during bootstrap the WINDOW IS the
    // splash box (full-bleed, no inner card). expandMainWindowAfterBootstrap()
    // grows + maximizes the window once the license is verified.
    readonly property int splashWidth: 960
    readonly property int splashHeight: 600
    width: splashWidth
    height: splashHeight
    minimumWidth: 860
    minimumHeight: 520
    visible: false      // hidden until first frame is ready (prevents white flash)
    flags: Qt.Window | Qt.FramelessWindowHint
    title: (void i18n.revision, i18n.t("app.window_title", "VEO FLOW"))
    // Transparent window surface so the rounded splash box has soft (rounded)
    // corners on this frameless window — the 4 corners outside the box radius
    // show through as transparent instead of hard square edges. During the main
    // app the content fills the maximized window, so transparency is unseen.
    // On RDP / GPU-less / VM machines a translucent surface renders as a white
    // box (no alpha compositing) — transparentWindowSafe (set from Python) is
    // false there, so we fall back to an opaque splash-matching surface (square
    // corners, but never a mystery white window). Undefined → keep transparent.
    //
    // ONLY the 960×600 splash needs translucency (soft rounded corners). The MAXIMIZED
    // main window fills the whole screen, so it must be OPAQUE: the app never sets a
    // QSurfaceFormat alpha buffer, so a "transparent" clear color paints every pixel not
    // yet covered by content as a BLACK void (or WHITE on a non-compositing GPU). During
    // the maximize→async-Loader gap (shellReady false for a tick) that void is a full-screen
    // empty box covering the app. Once bootstrap ends we switch to the opaque theme
    // background so there is never a mystery black/white rectangle.
    color: (appController && appController.bootstrapVisible)
           ? ((typeof transparentWindowSafe !== 'undefined' && !transparentWindowSafe) ? "#111827" : "transparent")
           : VfTheme.appBackground

    // Dark-aware default palette for Qt Quick Controls. Controls that DON'T set
    // an explicit color (TextField input text, CheckBox/RadioButton labels,
    // MenuItem, SpinBox, ComboBox, Label) fall back to this palette instead of
    // the built-in light default — fixes "dark text invisible on dark bg".
    // Propagates down the item tree (incl. Popups/Menus in the overlay). In
    // light mode every token resolves to its light value, so no regression.
    palette.window: VfTheme.appBackground
    palette.windowText: VfTheme.text
    palette.base: VfTheme.surface
    palette.alternateBase: VfTheme.surfaceSoft
    palette.text: VfTheme.text
    palette.button: VfTheme.surface
    palette.buttonText: VfTheme.text
    palette.brightText: "#FFFFFF"
    palette.placeholderText: VfTheme.textSubtle
    palette.highlight: VfTheme.primary
    palette.highlightedText: "#FFFFFF"
    palette.mid: VfTheme.border
    palette.midlight: VfTheme.surfaceSoft
    palette.dark: VfTheme.borderStrong
    palette.light: VfTheme.surfaceSoft
    palette.toolTipBase: VfTheme.surface
    palette.toolTipText: VfTheme.text

    // Responsive breakpoints — screens reflow their layout based on available width.
    readonly property int bpCompact: 1100   // below this: stack/condense
    readonly property int bpMedium: 1500    // below this: reduce columns
    readonly property string currentRoute: appController ? String(appController.route || "master") : "master"
    readonly property var currentMasterStats: masterController ? (masterController.stats || ({})) : ({})
    property bool expandedAfterBootstrap: false
    // Gates the main shell's visibility. Kept false until the window has
    // finished maximizing, so the heavy layout + async Loader instantiation
    // does NOT happen in the same frame as the OS maximize (that simultaneous
    // work is what made the splash→main transition stutter).
    property bool shellReady: false
    onShellReadyChanged: {
        if (!window.shellReady)
            return
        if (typeof headerController !== "undefined" && headerController)
            headerController.notifyShellReady()
        // One-time welcome: run the current tab's tour once, the first time
        // the shell is ready. After that `onboarded` is set and nothing auto-runs.
        if (!tourSettings.onboarded)
            welcomeTimer.restart()
    }
    // Temporarily keep the completed module packaged but out of the release UI.
    readonly property bool automationCenterUiVisible: false
    property bool _logUnlocked: false
    // Background-preload route screens after the shell is up so switching to a
    // heavy tab is instant. CRITICAL: preload them ONE AT A TIME (staggered) — NOT
    // all at once. Activating all 7 async Loaders simultaneously raced the Qt6Qml
    // engine → intermittent native crash (0xC0000005 in Qt6Qml.dll, ~15-20s in).
    // Verified A/B: all-at-once = 5/5 crash; staggered = 0 crash. Each loader has a
    // preload rank; preloadTick advances 1 step (~1s) at a time so only ~one screen
    // compiles at a time.
    property int preloadTick: 0
    property string pendingSharedTtsContext: ""

    onClosing: close => {
        if (typeof automationCenterHost !== "undefined"
                && automationCenterHost
                && !automationCenterHost.requestWindowClose(window))
            close.accepted = false
    }

    Connections {
        target: (typeof automationCenterHost !== "undefined") ? automationCenterHost : null
        function onExitGuardRequested(message) {
            if (!window.visible)
                return
            automationExitGuardText.text = String(message || "VeoFlow vẫn còn tác vụ đang chạy.")
            automationExitGuardDialog.open()
        }
    }

    Dialog {
        id: automationExitGuardDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: Math.min(VfTheme.dp(480), Math.max(VfTheme.dp(320), window.width - VfTheme.dp(48)))
        title: (void i18n.revision, i18n.t("qml.automation.exit_guard_title", "Vẫn còn tác vụ đang chạy"))

        contentItem: Label {
            id: automationExitGuardText
            width: parent ? parent.width : implicitWidth
            wrapMode: Text.WordWrap
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: Math.max(VfTheme.fontBody, 14)
        }

        footer: DialogButtonBox {
            Button {
                text: "Tiếp tục làm việc"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                onClicked: automationExitGuardDialog.close()
            }
        }
    }

    Timer {
        id: preloadStagger
        interval: 1000   // > heaviest screen compile (~720ms) so screens load ~one at a time
        running: window.shellReady && window.preloadTick < 8
        repeat: true
        onTriggered: window.preloadTick = window.preloadTick + 1
    }

    property var navItems: [
        { route: "home", label: (void i18n.revision, i18n.t("tabs.home", "HOME")) },
        { route: "master", label: (void i18n.revision, i18n.t("tabs.master_prompt", "MASTER PROMPT")) },
        { route: "clone", label: (void i18n.revision, i18n.t("tabs.clone_video", "CLONE VIDEO")) },
        { route: "transcript", label: (void i18n.revision, i18n.t("tabs.transcript", "AUDIO TO VIDEO")) },
        { route: "affiliate", label: (void i18n.revision, i18n.t("qml.nav.affiliate", "AFFILIATE")) },
        { route: "timemachine", label: (void i18n.revision, i18n.t("qml.nav.timemachine", "TIME MACHINE")) },
        { route: "automation", label: (void i18n.revision, i18n.t("tabs.automation_center", "AUTOMATION CENTER")) },
        { route: "research", label: (void i18n.revision, i18n.t("tabs.deep_research", "RESEARCH LABS")) },
        { route: "voice", label: (void i18n.revision, i18n.t("qml.nav.voice", "VOICE STUDIO")) },
        { route: "normal", label: (void i18n.revision, i18n.t("tabs.normal_work", "NORMAL PANEL")) },
        { route: "extend", label: (void i18n.revision, i18n.t("tabs.extend_work", "EXTEND PANEL")) },
        { route: "batch", label: (void i18n.revision, i18n.t("tabs.batch_image", "BATCH IMAGE")) },
        { route: "settings", label: (void i18n.revision, i18n.t("tabs.accounts_settings", "TÀI KHOẢN & API SETTINGS")) },
        { route: "history", label: (void i18n.revision, i18n.t("qml.nav.history", "HISTORY")) }
    ].filter(function(item) {
        return window.automationCenterUiVisible
            || String(item.route || "") !== "automation"
    })

    function isWorkRoute(route) {
        return ["normal", "extend", "clone", "transcript", "batch", "affiliate"].indexOf(route) >= 0
    }

    function expandMainWindowAfterBootstrap() {
        if (window.expandedAfterBootstrap)
            return
        window.expandedAfterBootstrap = true
        // Floor = màn thật hẹp nhất cần hỗ trợ (LOGICAL width, sau DPI scale):
        // 1366×768 native, hoặc 1920×1080 @150% = 1280×720. Không có màn thật dưới mức
        // này nên minWidth = 1280 là chuẩn (không phải số bừa 1100/760). Layout đã
        // responsive theo tỉ lệ trong 1280→4K.
        window.minimumWidth = 1280
        window.minimumHeight = 720
        // No resize animation — go straight to maximized on primary screen.
        // Pin window to primary first so showMaximized() expands there.
        var screens = Qt.application.screens || []
        var primary = screens.length > 0 ? screens[0] : null
        if (primary) {
            var geo = primary.availableVirtualGeometry || primary.virtualGeometry
            if (geo && geo.width > 0 && geo.height > 0) {
                window.x = geo.x + 40
                window.y = geo.y + 40
            }
        }
        window.showMaximized()
        // Reveal the main shell only AFTER the maximize has been applied, on a
        // later event-loop tick, so layout + Loaders don't fight the resize.
        Qt.callLater(function() { window.shellReady = true })
    }

    function dialogItem(loader) {
        loader.active = true
        return loader.item
    }

    // ---------------------------------------------------------------- product tour
    // Per-tab "seen" flags persist across launches so a tab auto-tours only on its
    // FIRST open. Manual launch (header menu) ignores this. CSV of route ids.
    Settings {
        id: tourSettings
        category: "tour"
        // Welcome shown at most once (first activation).
        property bool onboarded: false
    }

    // De-dup is now DETERMINISTIC (no mutable "seen" accumulator that could get stuck
    // and make a tour start mid-way). Rule:
    //   • Per-tab guide (pick one tab)  → that tab's FULL tour, always step 1..N.
    //   • Auto-play (walk every tab)    → the FIRST tab shows everything; every later
    //     tab drops the `shared: true` steps (config bar · character panel · job panel
    //     · status bar) since they were already taught on the first tab.
    // `_stripShared(steps)` implements the drop; the caller decides when to apply it.
    // Because the decision comes from queue POSITION, not a runtime flag that
    // survives across runs, the same action always produces the same walkthrough.
    function _stripShared(list) {
        var out = []
        for (var i = 0; i < list.length; i += 1) {
            if (!(list[i] && list[i].shared === true))
                out.push(list[i])
        }
        return out
    }

    // A tab is tourable only if it HAS a tour AND the license currently allows it.
    // Reuses the SAME featureTabState gate as the tab strip / setRoute — the tour
    // can never surface or enter a feature the key doesn't own.
    function tabTourAvailable(route) {
        var r = String(route || "")
        if (!TourData.hasSteps(r))
            return false
        if (!appController)
            return true
        var st = appController.featureTabState(r)
        return !st || st.enabled !== false
    }

    // Guide-pick mode: the header "?" → "Hướng dẫn" doesn't open a duplicate tab
    // menu — it enters this mode so the TOURABLE tabs pulse in the strip itself
    // (the strip already IS the available-tab list). Clicking a pulsing tab starts
    // its tour. Esc / clicking any other tab cancels.
    property bool guidePickMode: false
    property var guideRoutes: []
    // Header feature dialogs (Media Library, Style Manager) that also pulse in
    // guide-pick — clicking one opens the dialog and tours the controls inside.
    property var guideDialogs: []

    function startGuidePick() {
        var routes = []
        var items = window.navItems || []
        for (var i = 0; i < items.length; i += 1) {
            var r = String((items[i] || {}).route || "")
            if (window.tabTourAvailable(r))
                routes.push(r)
        }
        var dialogs = []
        if (TourData.hasDialogTour("media_library")) dialogs.push("media_library")
        if (TourData.hasDialogTour("style_manager")) dialogs.push("style_manager")
        if (routes.length === 0 && dialogs.length === 0) {
            statusController.setStatusMessage(
                (void i18n.revision, i18n.t("qml.tour.none_available", "Chưa có hướng dẫn cho tab khả dụng.")))
            return
        }
        window.guideRoutes = routes
        window.guideDialogs = dialogs
        window.guidePickMode = true
        statusController.setStatusMessage(
            (void i18n.revision, i18n.t("qml.tour.pick_hint", "Chọn mục đang nhấp nháy để xem hướng dẫn (Esc để huỷ).")))
    }

    function cancelGuidePick() {
        window.guidePickMode = false
    }

    Shortcut {
        sequence: "Escape"
        enabled: window.guidePickMode || window.autoGuideActive || tourOverlay.active
        onActivated: {
            window._savedTour = null   // Esc quits fully — don't resume a tab tour
            if (window.guidePickMode)
                window.cancelGuidePick()
            if (window.autoGuideActive)
                window.stopAutoGuide()   // set false BEFORE stop() so it won't chain
            if (tourOverlay.active)
                tourOverlay.stop()
        }
    }

    // Entry point (first-open trigger + a picked guide tab). License-safe: bails if
    // the route isn't tourable, and navigates via setRoute (itself gate-checked).
    // stripShared=true drops the config/character/job/status steps (already taught on
    // an earlier tab of the same auto-play run). Returns true if a tour started.
    function startTabTour(route, stripShared) {
        var r = String(route || "")
        if (!window.tabTourAvailable(r))
            return false
        if (appController && appController.route !== r)
            appController.setRoute(r)   // gate-checked; a blocked route won't switch
        // Only proceed if the route actually became active (not blocked).
        if (appController && appController.route !== r)
            return false
        var steps = TourData.stepsFor(r)
        if (stripShared === true)
            steps = window._stripShared(steps)   // later auto-play tabs: specific only
        if (steps.length === 0) {
            statusController.setStatusMessage(
                (void i18n.revision, i18n.t("qml.tour.nothing_new", "Tab này không còn mục mới để hướng dẫn.")))
            return false
        }
        // Populate this tab's data-heavy widgets with baked sample data so the
        // features look alive during the tour (empty first-run demo otherwise).
        TourState.route = r
        TourState.preview = true
        tourOverlay.autoPlay = window._autoPlayMode
        tourOverlay.autoPaused = false
        tourOverlay.currentRoute = r
        tourOverlay.start(steps)
        return true
    }

    // Full auto-guide: walk EVERY available tab's tour back-to-back. Chained on
    // tourOverlay.finished (see _onTourFinished). Launched from the welcome dialog
    // or the header "?" menu.
    property var _autoGuideQueue: []
    property bool autoGuideActive: false
    // Guards the pending Qt.callLater(_autoGuideNext) so an Esc/stop between a tab
    // finishing and the next tab starting cancels the chain cleanly.
    property bool _autoGuidePendingNext: false
    // When true the walkthrough auto-advances each step (no clicking) — a hands-off
    // demo. Set by startAutoPlay(); read by startTabTour to arm the overlay.
    property bool _autoPlayMode: false
    // Auto-play only: has the first tab (which teaches the shared config/job/etc.)
    // already run this walkthrough? Later tabs then drop those shared steps. Reset
    // per startAutoGuide → deterministic, no stuck cross-run state.
    property bool _autoGuideShownOne: false

    // Hands-off demo: same tab-by-tab walk, but each step advances itself after a
    // reading-time delay (overlay.autoPlay). Launched from the welcome dialog.
    function startAutoPlay() {
        window.startAutoGuide(true)
    }

    function startAutoGuide(autoPlay) {
        window._autoPlayMode = (autoPlay === true)
        var q = []
        var items = window.navItems || []
        for (var i = 0; i < items.length; i += 1) {
            var r = String((items[i] || {}).route || "")
            if (window.tabTourAvailable(r))
                q.push(r)
        }
        if (q.length === 0) {
            window._autoPlayMode = false
            return
        }
        // Fresh walkthrough: the first tab teaches the shared bits, later tabs skip
        // them (deterministic — see _autoGuideNext).
        window._autoGuideShownOne = false
        window._autoGuideQueue = q
        window.autoGuideActive = true
        window._autoGuideNext()
    }

    function _autoGuideNext() {
        while (window.autoGuideActive && window._autoGuideQueue.length > 0) {
            var next = window._autoGuideQueue.shift()
            // First tab: full tour (incl. shared). Every later tab: specific only.
            if (window.startTabTour(next, window._autoGuideShownOne)) {
                window._autoGuideShownOne = true
                return   // started; the next one fires when this tour finishes
            }
        }
        window.autoGuideActive = false
        window._tourRestoreMaster()   // walkthrough done → restore real master settings
    }

    function stopAutoGuide() {
        window.autoGuideActive = false
        window._autoGuideQueue = []
        window._autoGuidePendingNext = false   // cancel any queued chain step
        window._autoPlayMode = false
        window._savedTour = null
        tourOverlay.autoPlay = false
        window._tourRestoreMaster()             // undo any section-reveal config changes
    }

    // Dialog tour: open a big feature dialog (Media Library / Style Manager / Bulk
    // Import) and spotlight the controls inside it. The dialog is closed when done.
    property string _pendingTourDialog: ""
    // When a dialog tour is launched FROM a tab tour (the "Mở thử" button on a step),
    // the outer tour is saved here and resumed at the next step once the dialog tour
    // finishes. Cleared on Esc/skip so it doesn't resurrect a stopped tour.
    property var _savedTour: null

    // Enter a dialog tour from within a running tab tour: remember where we were so
    // we can pick the tab tour back up afterwards.
    function enterDialogFromTour(dialogId) {
        var id = String(dialogId || "")
        if (!TourData.hasDialogTour(id))
            return
        // Only save a genuine tab tour (not another dialog tour) to resume.
        if (tourOverlay.active && String(tourOverlay.currentRoute).indexOf("dialog:") !== 0) {
            window._savedTour = {
                "steps": tourOverlay.steps,
                "index": tourOverlay.index,
                "route": String(tourOverlay.currentRoute),
                "autoPlay": tourOverlay.autoPlay
            }
        }
        window.startDialogTour(id)
    }

    function startDialogTour(dialogId) {
        var id = String(dialogId || "")
        if (!TourData.hasDialogTour(id))
            return
        window._pendingTourDialog = id
        if (id === "media_library")
            window.openHeaderMediaLibrary()
        else if (id === "style_manager")
            window.openHeaderStyleManager()
        else if (id === "bulk_import") {
            // Master owns its own Bulk Import dialog; the work tabs share theirs.
            var scr = (appController && appController.route === "master")
                ? masterLoader.item : workPanelLoader.item
            if (scr && scr.openBulkImportForTour)
                Qt.callLater(function() { scr.openBulkImportForTour() })
        } else if (id === "bulk_import_image") {
            // Same dialog as bulk_import, but forced into IMAGE mode for the tour.
            if (workPanelLoader.item && workPanelLoader.item.openBulkImportImageForTour)
                Qt.callLater(function() { workPanelLoader.item.openBulkImportImageForTour() })
        } else if (id === "bulk_import_named_ref") {
            if (workPanelLoader.item && workPanelLoader.item.openBulkImportNamedRefForTour)
                Qt.callLater(function() { workPanelLoader.item.openBulkImportNamedRefForTour() })
        } else if (id === "bulk_extend") {
            if (workPanelLoader.item && workPanelLoader.item.openBulkExtendForTour)
                Qt.callLater(function() { workPanelLoader.item.openBulkExtendForTour() })
        }
        tourOverlay.currentRoute = "dialog:" + id
        tourOverlay.autoPlay = false   // dialog tours are always hand-advanced
        // The dialog opens async; the overlay's bounded retry waits for its
        // controls to appear before spotlighting.
        tourOverlay.start(TourData.dialogStepsFor(id))
    }

    function _onTourFinished() {
        var id = window._pendingTourDialog
        window._pendingTourDialog = ""
        window._closeTourDialog(id)

        // Resume the tab tour that launched this dialog tour — but only on a natural
        // finish (Hoàn tất through all steps), not "Bỏ qua". Esc clears _savedTour so
        // it never resurrects here. preview stays true (the tab still needs demo data).
        if (window._savedTour) {
            var saved = window._savedTour
            window._savedTour = null
            var resumeIdx = saved.index + 1
            if (!tourOverlay.skipped && resumeIdx < saved.steps.length) {
                tourOverlay.currentRoute = saved.route
                tourOverlay.autoPlay = saved.autoPlay
                tourOverlay.start(saved.steps, resumeIdx)
                return
            }
        }

        TourState.preview = false   // real controller data returns
        if (window.autoGuideActive) {
            if (tourOverlay.skipped) {
                window.stopAutoGuide()                // "Bỏ qua" ends the whole walkthrough
            } else {
                // Chain to the next tab, but guarded so an Esc/stop before it fires
                // cancels cleanly instead of resurrecting a stopped walkthrough.
                window._autoGuidePendingNext = true
                Qt.callLater(function() {
                    if (window._autoGuidePendingNext) {
                        window._autoGuidePendingNext = false
                        window._autoGuideNext()
                    }
                })
            }
        } else {
            window._tourRestoreMaster()   // single-tab tour ended → restore settings
        }
    }

    // Step side-effects (currently: switch Media Library into a filter mode so the
    // step's control is visible before the tour spotlights it).
    // Snapshot of the MASTER config keys a tour pre-action may change, so we can
    // restore the user's real settings when the tour ends (master setOption PERSISTS;
    // work-tab activations are transient QML props that self-revert on tab switch).
    property var _tourStateSnap: null

    function _tourSnapshotMaster() {
        if (window._tourStateSnap || !masterOptionsController)
            return
        var c = masterOptionsController.config || ({})
        window._tourStateSnap = {
            "input_mode": String(c.input_mode || "idea"),
            "extra_requirements": c.extra_requirements === true,
            "character_consistency": c.character_consistency === true,
            "char_mode": String(c.char_mode || "full_ai"),
            "enable_narrator": c.enable_narrator === true
        }
    }

    function _tourRestoreMaster() {
        var s = window._tourStateSnap
        window._tourStateSnap = null
        if (!s || !masterOptionsController)
            return
        masterOptionsController.setOption("input_mode", s.input_mode)
        masterOptionsController.setOption("extra_requirements", s.extra_requirements)
        masterOptionsController.setOption("character_consistency", s.character_consistency)
        masterOptionsController.setOption("char_mode", s.char_mode)
        masterOptionsController.setOption("enable_narrator", s.enable_narrator === true)
    }

    // Reveal a conditional section BEFORE the step spotlights it. Voice/work tab
    // disclosures are UI-only; Master state changes are restored at tour end.
    function _tourStepPre(action) {
        var a = String(action || "")
        if (a.indexOf("filter:") === 0) {
            var f = a.substring(7)
            if (headerMediaLibraryDialogLoader.item)
                headerMediaLibraryDialogLoader.item.filterType = (f === "all" ? "" : f)
            return
        }
        var route = appController ? String(appController.route) : ""
        if (route === "voice") {
            if (voiceLoader.item && voiceLoader.item.tourActivateSection)
                voiceLoader.item.tourActivateSection(a)
        } else if (route === "master" && masterOptionsController) {
            if (a === "consistency:open") {
                if (masterLoader.item && masterLoader.item.tourActivateSection)
                    masterLoader.item.tourActivateSection(a)
                return
            }
            window._tourSnapshotMaster()
            if (a === "input:idea") {
                masterOptionsController.setOption("input_mode", "idea")
            } else if (a === "input:script") {
                masterOptionsController.setOption("input_mode", "script")
            } else if (a === "extra:on") {
                masterOptionsController.setOption("input_mode", "idea")
                masterOptionsController.setOption("extra_requirements", true)
            } else if (a === "narrator:on") {
                // "Mẫu dẫn truyện" only shows in script mode with the narrator on.
                masterOptionsController.setOption("input_mode", "script")
                masterOptionsController.setOption("enable_narrator", true)
            }
        } else if (a.length > 0) {
            if (workPanelLoader.item && workPanelLoader.item.tourActivateSection)
                workPanelLoader.item.tourActivateSection(a)
        }
    }

    function _closeTourDialog(id) {
        var d = String(id || "")
        if (d === "media_library") {
            if (headerMediaLibraryDialogLoader.item) {
                // Reset out of the (heavy) voice filter the tour may have switched
                // to, then close — so nothing keeps loading behind the scenes.
                headerMediaLibraryDialogLoader.item.filterType = ""
                if (headerMediaLibraryDialogLoader.item.close)
                    headerMediaLibraryDialogLoader.item.close()
            }
        } else if (d === "style_manager") {
            // StyleManagerDialog is a Popup (not an Item) → NOT findable by objectName
            // on Overlay.overlay. Close through whichever screen owns one (no-op when
            // already closed — mirrors the bulk_import handling below).
            if (masterLoader.item && masterLoader.item.closeStyleManagerForTour)
                masterLoader.item.closeStyleManagerForTour()
            if (workPanelLoader.item && workPanelLoader.item.closeStyleManagerForTour)
                workPanelLoader.item.closeStyleManagerForTour()
        } else if (d === "bulk_import" || d === "bulk_import_image" || d === "bulk_import_named_ref") {
            // BulkImportDialog is a Popup (not an Item) → NOT findable by objectName on
            // Overlay.overlay. Close through the owning screen instead. Both screens own
            // one; closing an already-closed dialog is a harmless no-op. (image mode uses
            // the same dialog instance as text mode.)
            if (masterLoader.item && masterLoader.item.closeBulkImportForTour)
                masterLoader.item.closeBulkImportForTour()
            if (workPanelLoader.item && workPanelLoader.item.closeBulkImportForTour)
                workPanelLoader.item.closeBulkImportForTour()
        } else if (d === "bulk_extend") {
            if (workPanelLoader.item && workPanelLoader.item.closeBulkExtendForTour)
                workPanelLoader.item.closeBulkExtendForTour()
        }
    }

    // First-activation welcome — shown once (persisted via `onboarded`), a short
    // delay after the shell is ready. Offers to run the full auto-guide.
    Timer {
        id: welcomeTimer
        interval: 900
        repeat: false
        onTriggered: {
            if (tourSettings.onboarded || !window.shellReady || (appController && appController.bootstrapVisible))
                return
            tourSettings.onboarded = true
            var dialog = window.dialogItem(welcomeDialogLoader)
            if (dialog)
                dialog.open()
        }
    }

    function closeVisualTestDialogs() {
        var seen = []
        function closeItem(item, depth) {
            if (!item || depth > 80)
                return
            if (seen.indexOf(item) >= 0)
                return
            seen.push(item)

            var visible = item.visible === undefined || item.visible
            if (visible && item.close)
                item.close()
            else if (visible && item.reject)
                item.reject()

            var childLists = [item.children, item.data]
            if (item.contentItem)
                childLists.push([item.contentItem])
            if (item.background)
                childLists.push([item.background])
            if (item.header)
                childLists.push([item.header])
            if (item.footer)
                childLists.push([item.footer])
            for (var listIndex = 0; listIndex < childLists.length; listIndex += 1) {
                var children = childLists[listIndex]
                if (!children)
                    continue
                for (var childIndex = 0; childIndex < children.length; childIndex += 1)
                    closeItem(children[childIndex], depth + 1)
            }
        }

        var loaders = [
            tokenMonitorDialogLoader,
            jobMonitorDialogLoader,
            errorLogDialogLoader,
            headerInfoDialogLoader,
            headerDataDialogLoader,
            headerUpdateDialogLoader,
            headerCommerceDialogLoader,
            headerMediaLibraryDialogLoader,
            aboutDialogLoader,
            apiKeysDialogLoader,
            themeManagerDialogLoader,
            strategyManagerDialogLoader,
            welcomeDialogLoader
        ]
        for (var i = 0; i < loaders.length; i += 1) {
            var item = loaders[i].item
            if (!item)
                continue
            if (item.close)
                item.close()
            else if (item.reject)
                item.reject()
        }
        closeItem(captureRoot, 0)
        closeItem(Overlay.overlay, 0)
    }

    function openTokenMonitorDialog() {
        var dialog = window.dialogItem(tokenMonitorDialogLoader)
        if (dialog)
            dialog.open()
    }

    function openJobMonitorDialog() {
        var dialog = window.dialogItem(jobMonitorDialogLoader)
        if (dialog)
            dialog.open()
    }

    function openErrorLogDialog() {
        var dialog = window.dialogItem(errorLogDialogLoader)
        if (dialog)
            dialog.open()
    }

    function openSystemLogDialog() {
        var dialog = window.dialogItem(systemLogDialogLoader)
        if (dialog)
            dialog.open()
    }

    function openRuntimeAlertDialog() {
        var dialog = window.dialogItem(runtimeAlertDialogLoader)
        if (dialog)
            dialog.openFromPayload(statusController.runtimeAlert)
    }

    function openHeaderInfoDialog() {
        window.closeHeaderInfoDialogs()
        var dialog = window.dialogItem(headerInfoDialogLoader)
        if (dialog)
            dialog.open()
    }

    function openHeaderDataDialog() {
        window.closeHeaderInfoDialogs()
        var dialog = window.dialogItem(headerDataDialogLoader)
        if (dialog)
            dialog.open()
    }

    function openHeaderMediaLibrary() {
        window.closeHeaderInfoDialogs()
        var dialog = window.dialogItem(headerMediaLibraryDialogLoader)
        if (!dialog)
            return
        dialog.mode = "manage"
        dialog.filterType = ""
        dialog.maxSelection = 9999
        dialog.open()
    }

    function openHeaderStyleManager() {
        window.closeHeaderInfoDialogs()
        masterOptionsController.refreshStyles("")
        if (window.currentRoute === "timemachine"
                && timeMachineLoader.item
                && timeMachineLoader.item.openStyleManager) {
            timeMachineLoader.item.openStyleManager()
            return
        }
        if (window.isWorkRoute(window.currentRoute)
                && workPanelLoader.item
                && workPanelLoader.item.openStyleManager) {
            workPanelLoader.item.openStyleManager()
            return
        }
        if (window.currentRoute === "master"
                && masterLoader.item
                && masterLoader.item.openStyleManager) {
            masterLoader.item.openStyleManager()
            return
        }
        appController.setRoute("master")
        masterOptionsController.requestOpenDialog("style_manager")
    }

    function openHeaderUpdateDialog() {
        window.closeHeaderInfoDialogs()
        var dialog = window.dialogItem(headerUpdateDialogLoader)
        if (dialog)
            dialog.open()
    }

    function openHeaderCommerceDialog() {
        window.openGatewayBillingDialog()
    }

    function openGatewayBillingDialog() {
        window.closeHeaderInfoDialogs()
        var dialog = window.dialogItem(headerCommerceDialogLoader)
        if (!dialog)
            return
        // Sync live provider settings into the dialog before show.
        if (typeof accountSettingsController !== "undefined" && accountSettingsController) {
            dialog.apiMode = String(accountSettingsController.apiMode || "aistudio")
            dialog.keys = accountSettingsController.apiKeys || []
        }
        if (dialog.openFromPayload)
            dialog.openFromPayload(headerController.dialog)
        else
            dialog.open()
    }

    function openFeaturePurchaseDialog(payload) {
        var data = payload || headerController.dialog || ({})
        if (featurePurchaseDialogLoader.active
                && featurePurchaseDialogLoader.item
                && featurePurchaseDialogLoader.item.visible) {
            featurePurchaseDialogLoader.item.openForRoute(data, String(data.route || ""))
            return
        }
        window.closeHeaderInfoDialogs()
        var dialog = window.dialogItem(featurePurchaseDialogLoader)
        if (!dialog)
            return
        dialog.openForRoute(data, String(data.route || ""))
    }

    function handleLockedFeature(route, message) {
        var featureRoute = String(route || "")
        var state = appController ? (appController.featureTabState(featureRoute) || ({})) : ({})
        if (String(state.badge || "") !== "Chưa mua") {
            statusController.setStatusMessage(
                String(message || state.message
                       || (void i18n.revision, i18n.t("app_qml.route_blocked", "Tính năng đang bảo trì hoặc chưa có quyền."))))
            return
        }
        headerController.openFeaturePurchase(featureRoute)
    }

    function closeHeaderInfoDialogs() {
        var loaders = [
            headerInfoDialogLoader,
            headerDataDialogLoader,
            headerUpdateDialogLoader,
            headerCommerceDialogLoader,
            featurePurchaseDialogLoader
        ]
        for (var index = 0; index < loaders.length; index += 1) {
            var loader = loaders[index]
            if (!loader || !loader.active || !loader.item)
                continue
            if (loader.item.close)
                loader.item.close()
            else if (loader.item.reject)
                loader.item.reject()
        }
    }

    function handleHeaderDialogAction(dialog, action, value) {
        if (action === "open_path") {
            nativeShell.openPath(value)
        } else if (action === "open_external_url" || action === "open_url") {
            nativeShell.openExternal(value)
            dialog.close()
        } else if (action === "route") {
            appController.setRoute(value)
            dialog.close()
        } else if (action === "dialog") {
            headerController.openNestedDialog(value)
        } else if (action === "master_style_manager") {
            appController.setRoute("master")
            masterOptionsController.refreshStyles("")
            masterOptionsController.requestOpenDialog("style_manager")
            dialog.close()
        } else if (action === "taxonomy_theme_manager") {
            taxonomyController.managementPayload("theme", "")
            window.openThemeManagerDialog("")
            dialog.close()
        } else if (action === "taxonomy_strategy_manager") {
            taxonomyController.managementPayload("strategy", "")
            window.openStrategyManagerDialog("")
            dialog.close()
        } else if (action === "status_token") {
            statusController.openTokenMonitor()
            dialog.close()
        } else if (action === "status_job_monitor") {
            statusController.openJobMonitor()
            dialog.close()
        } else if (action === "status_error_log") {
            statusController.openErrorLog()
            dialog.close()
        } else if (action === "status_log_panel") {
            statusController.toggleLogPanel()
            dialog.close()
        } else if (String(action).indexOf("commerce_") === 0 || action === "commerce") {
            headerController.executeAction(action, value)
        } else if (action === "update_check"
                || action === "update_download"
                || action === "update_apply") {
            headerController.executeAction(action, value)
        } else {
            statusController.setStatusMessage("Header action: " + action)
        }
    }

    function openAboutDialog(payload) {
        var dialog = window.dialogItem(aboutDialogLoader)
        if (dialog)
            dialog.openFromPayload(payload)
    }

    function openApiKeysDialog(mode) {
        var dialog = window.dialogItem(apiKeysDialogLoader)
        if (dialog) {
            accountSettingsController.refreshApiKeys()
            if (String(mode || "") === "add_gemini" && dialog.openForAddGemini)
                dialog.openForAddGemini()
            else
                dialog.open()
        }
    }

    function openThemeManagerDialog(kind) {
        var dialog = window.dialogItem(themeManagerDialogLoader)
        if (dialog)
            dialog.openManager(kind || "")
    }

    function openStrategyManagerDialog(kind) {
        var dialog = window.dialogItem(strategyManagerDialogLoader)
        if (dialog)
            dialog.openManager(kind || "")
    }

    function openSharedTtsProviderDialog(context) {
        window.pendingSharedTtsContext = String(context || "shared")
        sharedTtsProviderDialogLoader.active = true
        var dialog = sharedTtsProviderDialogLoader.item
        if (dialog && dialog.openFor) {
            dialog.openFor(window.pendingSharedTtsContext)
            window.pendingSharedTtsContext = ""
        }
    }

    // Main app canvas. Hidden during bootstrap so it never shows white behind
    // the rounded splash corners (window is transparent during bootstrap).
    Rectangle {
        anchors.fill: parent
        color: VfTheme.appBackground
        visible: !(appController && appController.bootstrapVisible)
    }

    Connections {
        target: masterController
        function onStatusMessageChanged() {
            statusController.setStatusMessage(masterController.statusMessage)
        }
    }

    // Admin allow-list: when the controller COERCES the api mode (a just-disabled mode
    // pushed from the gateway), keep the open billing dialog's shown mode in sync — its
    // buttons hide reactively via allowedModes, but apiMode is set imperatively so the
    // "đang dùng" indicator would otherwise lag on a hidden button until reopen.
    Connections {
        target: accountSettingsController
        function onApiModeChanged() {
            var d = headerCommerceDialogLoader.item
            if (d) {
                d.apiMode = String(accountSettingsController.apiMode || d.apiMode)
                d.previousApiMode = d.apiMode
            }
        }
    }

    Connections {
        target: appController
        function onBootstrapChanged() {
            if (!appController.bootstrapVisible)
                window.expandMainWindowAfterBootstrap()
        }
        // NOTE: no per-route auto-tour — switching tabs must NOT launch a tour.
    }

    Connections {
        target: masterOptionsController
        function onStatusMessageChanged() {
            statusController.setStatusMessage(masterOptionsController.statusMessage)
        }
    }

    Connections {
        target: workPanelController
        function onStatusMessageChanged() {
            statusController.setStatusMessage(workPanelController.statusMessage)
        }
    }

    Connections {
        target: homeController
        function onStatusMessageChanged() {
            statusController.setStatusMessage(homeController.statusMessage)
        }
    }

    Connections {
        target: headerController
        function onStatusMessageChanged() {
            statusController.setStatusMessage(headerController.statusMessage)
        }
        function onFeatureEntitlementsUpdated() {
            appController.notifyFeatureEntitlementsUpdated()
        }
        function onDialogRequested() {
            var mode = String(headerController.dialog.mode || "")
            if (mode === "about" || mode === "license_expired" || mode === "license" || mode === "renew")
                window.openAboutDialog(headerController.dialog)
            else if (mode === "data")
                window.openHeaderDataDialog()
            else if (mode === "media_library")
                window.openHeaderMediaLibrary()
            else if (mode === "styles")
                window.openHeaderStyleManager()
            else if (mode === "update" || mode.indexOf("update_") === 0)
                window.openHeaderUpdateDialog()
            else if (mode === "store" || mode === "payment" || mode === "credits"
                     || mode === "gateway_billing" || mode === "gateway_billing_gemini"
                     || mode === "gateway_billing_money")
                window.openGatewayBillingDialog()
            else if (mode === "feature_purchase")
                window.openFeaturePurchaseDialog(headerController.dialog)
            else
                window.openHeaderInfoDialog()
        }
    }

    Connections {
        target: statusController
        function onRuntimeAlertRequested() {
            window.openRuntimeAlertDialog()
        }
    }

    Connections {
        target: taxonomyController
        function onStatusMessageChanged() {
            statusController.setStatusMessage(taxonomyController.statusMessage)
        }
    }

    Connections {
        target: researchController
        function onStatusMessageChanged() {
            statusController.setStatusMessage(researchController.statusMessage)
        }
    }

    Connections {
        target: voiceController
        function onStatusMessageChanged() {
            statusController.setStatusMessage(voiceController.statusMessage)
        }
        function onTtsPickerRequested(context) {
            window.openSharedTtsProviderDialog(context)
        }
        function onNarrationSelectionChanged() {
            narratorController.notifyExternalChange()
        }
    }

    Connections {
        target: sequenceGraphicsController
        function onOpenRequested(route) {
            var target = String(route || "")
            if (target !== "timemachine" && target !== "transcript") {
                statusController.setStatusMessage(
                    "Sequence Graphics chỉ hỗ trợ Time Machine và Audio to Video")
                return
            }
            sequenceGraphicsStudioDialogLoader.active = true
            var dialog = sequenceGraphicsStudioDialogLoader.item
            if (dialog)
                dialog.open()
        }
        function onProfileApplied(route, profile) {
            var target = String(route || "timemachine")
            if (target === "transcript") {
                var transcriptResult = workPanelController.setRouteOption(
                    "transcript", "sequence_graphics", profile)
                statusController.setStatusMessage(
                    transcriptResult && transcriptResult.sequence_graphics
                        ? "Sóng âm đã áp dụng cho job Audio to Video mới"
                        : "Không thể áp dụng sóng âm cho Audio to Video")
                return
            }
            if (target !== "timemachine") {
                statusController.setStatusMessage(
                    "Sequence Graphics chỉ hỗ trợ Time Machine và Audio to Video")
                return
            }
            var result = timemachineController.setOption(
                "sequence_graphics", profile)
            statusController.setStatusMessage(result && result.ok
                ? ("Sequence Graphics đã áp dụng cho job mới · " + target)
                : String((result || {}).message
                    || "Không thể áp dụng Sequence Graphics"))
        }
    }

    Connections {
        target: subtitleStudioController
        function persistSubtitleProfile(route, profile) {
            var target = String(route || "master")
            var result = null
            var workRoute = ["clone", "transcript", "affiliate", "extend"].indexOf(target) >= 0
            if (target === "timemachine")
                result = timemachineController.setOption(
                    "subtitle_profile", profile)
            else if (workRoute)
                result = workPanelController.setRouteOption(
                    target, "subtitle_profile", profile)
            else if (target === "master")
                result = masterOptionsController.setOption(
                    "subtitle_profile", profile)
            else
                result = {
                    ok: false,
                    message: "Subtitle Studio chưa được gắn vào route " + target
                }
            // WorkPanel's setRouteOption returns the resulting route config,
            // while Master/TimeMachine return an operation envelope with ok.
            var applied = Boolean(result) && (result.ok === true
                || (result.ok === undefined && workRoute
                    && result.subtitle_profile !== undefined))
            return {
                target: target,
                applied: applied,
                message: applied
                    ? ("Cấu hình phụ đề đã áp dụng cho job mới · " + target)
                    : String((result || {}).message
                        || "Không thể áp dụng cấu hình phụ đề")
            }
        }
        function onOpenRequested(route) {
            subtitleStudioDialogLoader.active = true
            var dialog = subtitleStudioDialogLoader.item
            if (dialog)
                dialog.open()
        }
        function onProfileApplied(route, profile) {
            var outcome = persistSubtitleProfile(route, profile)
            statusController.setStatusMessage(outcome.message)
            subtitleStudioController.confirmRouteApply(outcome.target, {
                ok: outcome.applied,
                message: outcome.message
            })
        }
        function onRouteProfileAutosaved(route, profile) {
            var outcome = persistSubtitleProfile(route, profile)
            var message = outcome.applied
                ? ("Đã tự lưu cấu hình cho job mới · " + outcome.target)
                : outcome.message
            subtitleStudioController.confirmRouteAutosave(
                outcome.target,
                String((profile || {}).fingerprint || ""), {
                ok: outcome.applied,
                message: message
            })
        }
    }

    Connections {
        target: accountSettingsController
        function onStatusMessageChanged() {
            statusController.setStatusMessage(accountSettingsController.statusMessage)
        }
        function onPendingDialogChanged() {
            if (accountSettingsController.consumePendingDialog("api_keys_add_gemini"))
                window.openApiKeysDialog("add_gemini")
            if (accountSettingsController.consumePendingDialog("gemini_api"))
                window.openApiKeysDialog("add_gemini")
            if (accountSettingsController.consumePendingDialog("api_keys"))
                window.openApiKeysDialog()
        }
    }

    Connections {
        target: statusController
        function onTokenDialogRequested() {
            window.openTokenMonitorDialog()
        }
        function onJobMonitorDialogRequested() {
            window.openJobMonitorDialog()
        }
        function onErrorLogDialogRequested() {
            window.openErrorLogDialog()
        }
        function onSystemLogDialogRequested() {
            window.openSystemLogDialog()
        }
    }

    Connections {
        target: historyController
        function onStatusMessageChanged() {
            statusController.setStatusMessage(historyController.statusMessage)
        }
        function onOpenTargetRequested(kind, target) {
            var value = String(target || "")
            if (!value.length)
                return
            if (String(kind || "") === "url")
                nativeShell.openExternal(value)
            else
                nativeShell.openPath(value)
        }
        function onActionResult(payload) {
            var result = (payload && payload.result) ? payload.result : ({})
            if (!Boolean(result.ok)
                    || String(result.restoreTarget || "") !== "timemachine")
                return
            var restored = timemachineController.restoreHistoryProject(
                result.restorePayload || ({})
            )
            if (Boolean(restored.ok))
                appController.setRoute("timemachine")
            else
                statusController.setStatusMessage(
                    String(restored.message || restored.error
                           || "Không thể khôi phục project Time Machine.")
                )
        }
    }

    // True when the window can be resized (not maximized or fullscreen)
    readonly property bool resizable: !(visibility === Window.Maximized || visibility === Window.FullScreen)

    // Uniform design-unit scaling: every dimension = base * scaleFactor, so the
    // 1920x1080 design stays identical on every screen (like a video) but each
    // element is RE-RENDERED at the target size (sharp at any zoom — not a
    // raster scale). Window feeds the factor into VfTheme; widgets read tokens
    // and VfTheme.dp(n) for literals.
    readonly property real shellScale: Math.max(0.55, Math.min(2.0, Math.min(width / 1920, height / 1080)))
    Timer {
        id: scaleDebounce
        interval: 100
        repeat: false
        onTriggered: VfTheme.scaleFactor = window.shellScale
    }
    onShellScaleChanged: scaleDebounce.restart()

    // Dark mode: VfTheme.dark mirrors the persisted user preference and updates
    // live when toggled from the header (appController.setDarkMode).
    Binding {
        target: VfTheme
        property: "dark"
        value: appController.darkMode
    }

    // Auto perf tier: Python probe (utils/perf_tier.py, chạy trong build_engine
    // trước khi load QML) quyết định qua bool perfMotionEnabled — máy yếu
    // (GPU WARP/software, iGPU-only + RAM/core thấp) tắt toàn bộ infinite
    // animation. Preview/script không có property này → mặc định ON.
    Binding {
        target: VfTheme
        property: "motion"
        value: (typeof perfMotionEnabled !== "undefined") ? Boolean(perfMotionEnabled) : true
    }

    Component.onCompleted: {
        VfTheme.scaleFactor = shellScale
        // Force app onto PRIMARY screen (not the one where cursor happened to be).
        // Qt.application.screens[0] is the primary on Windows/Linux/macOS.
        var screens = Qt.application.screens || []
        var primary = screens.length > 0 ? screens[0] : null
        if (primary) {
            var geo = primary.availableVirtualGeometry || primary.virtualGeometry
            if (geo && geo.width > 0 && geo.height > 0) {
                // Responsive splash: size relative to the primary screen,
                // clamped so it stays a sensible compact box on tiny screens
                // and doesn't balloon on 4K. Only while bootstrap is up; the
                // main window maximizes afterwards.
                if (appController && appController.bootstrapVisible) {
                    window.width = Math.round(Math.max(900, Math.min(1180, geo.width * 0.52)))
                    window.height = Math.round(Math.max(560, Math.min(740, geo.height * 0.62)))
                }
                window.x = geo.x + Math.max(0, (geo.width - window.width) / 2)
                window.y = geo.y + Math.max(0, (geo.height - window.height) / 2)
            } else {
                window.x = primary.virtualX + Math.max(0, (primary.width - window.width) / 2)
                window.y = primary.virtualY + Math.max(0, (primary.height - window.height) / 2)
            }
        } else if (Screen.virtualX !== undefined) {
            window.x = Screen.virtualX + (Screen.width - window.width) / 2
            window.y = Screen.virtualY + (Screen.height - window.height) / 2
        } else {
            window.x = (Screen.width - window.width) / 2
            window.y = (Screen.height - window.height) / 2
        }
        // Reveal window AFTER position is set + first frame has rendered.
        // Defer to next event loop tick so QML scene is painted first → no white flash.
        Qt.callLater(function() { window.visible = true })
        // If bootstrap is not shown at startup (e.g. automation/tests), skip the
        // compact splash size and go straight to the maximized main window.
        if (!(appController && appController.bootstrapVisible))
            Qt.callLater(window.expandMainWindowAfterBootstrap)
    }

    Item {
        id: captureRoot
        objectName: "captureRoot"
        anchors.fill: parent
        clip: true

        function visualTextSnapshot() {
            var result = []
            var seen = []

            function pushText(value) {
                var text = String(value || "")
                if (text.length > 0)
                    result.push(text)
            }

            function visit(item, depth) {
                if (!item || depth > 80)
                    return
                if (seen.indexOf(item) >= 0)
                    return
                seen.push(item)
                if (item.visible === false)
                    return

                pushText(item.text)
                pushText(item.title)
                pushText(item.placeholderText)
                pushText(item.displayText)
                pushText(item.currentText)
                pushText(item.accessibleName)

                var childLists = [item.children, item.data]
                if (item.contentItem)
                    childLists.push([item.contentItem])
                if (item.background)
                    childLists.push([item.background])
                if (item.header)
                    childLists.push([item.header])
                if (item.footer)
                    childLists.push([item.footer])

                for (var listIndex = 0; listIndex < childLists.length; listIndex += 1) {
                    var children = childLists[listIndex]
                    if (!children)
                        continue
                    for (var i = 0; i < children.length; i += 1)
                        visit(children[i], depth + 1)
                }
            }

            visit(captureRoot, 0)
            visit(Overlay.overlay, 0)
            return result
        }

        Item {
            id: scaledShell
            anchors.fill: parent

            ColumnLayout {
                id: shellRoot
                anchors.fill: parent
                spacing: 0
                // Don't render main UI while splash is up — avoids ghost loads
                // (e.g. master screen pulling previews before license verifies).
                // shellReady is flipped one tick AFTER the window maximizes, so
                // this layout + its async Loaders don't instantiate in the same
                // frame as the resize (prevents the transition stutter).
                visible: window.shellReady

                HeaderComponent {
                    automationCenterVisible: window.automationCenterUiVisible
                    browserHealthText: headerController.browserHealthText
                    browserHealthTooltip: headerController.browserHealthTooltip
                    browserHealthTone: headerController.browserHealthTone
                    licenseStatus: headerController.licenseStatus
                    creditsText: headerController.creditsText
                    creditsTooltip: headerController.creditsTooltip
                    consumedText: headerController.consumedText
                    consumedTooltip: headerController.consumedTooltip
                    updateBusy: headerController.busy && String(headerController.currentAction || "").indexOf("update_") === 0
                    updateActionText: String(headerController.currentAction || "")
                    onAutomationCenterRequested: {
                        if (window.automationCenterUiVisible)
                            appController.setRoute("automation")
                    }
                    onMediaLibraryRequested: window.openHeaderMediaLibrary()
                    onStyleManagerRequested: window.openHeaderStyleManager()
                    onUpdateRequested: headerController.checkAndDownloadUpdate()
                    onAboutRequested: headerController.openDialog("about")
                    onGuideRequested: window.startGuidePick()
                    onAutoGuideRequested: window.startAutoPlay()
                    onWelcomeRequested: {
                        var dialog = window.dialogItem(welcomeDialogLoader)
                        if (dialog)
                            dialog.open()
                    }
                    guidePickActive: window.guidePickMode
                    guideDialogs: window.guideDialogs
                    onGuideDialogPicked: dialogId => {
                        window.cancelGuidePick()
                        window.startDialogTour(String(dialogId || ""))
                    }
                }

                AppTabStrip {
                    navItems: window.navItems
                    activeRoute: window.currentRoute
                    guidePickActive: window.guidePickMode
                    guideRoutes: window.guideRoutes
                    onRouteSelected: route => {
                        if (window.guidePickMode)
                            window.cancelGuidePick()
                        appController.setRoute(route)
                    }
                    onGuidePicked: route => {
                        window.cancelGuidePick()
                        window._autoPlayMode = false      // single-tab pick is manual
                        window.startTabTour(route, false) // full tour, always step 1..N
                    }
                    onTabBlocked: (route, message) => {
                        if (window.guidePickMode)
                            window.cancelGuidePick()
                        window.handleLockedFeature(route, message)
                    }
                }

                Connections {
                    target: appController
                    function onRouteBlockedNotice(route, message) {
                        window.handleLockedFeature(route, message)
                    }
                }

                Connections {
                    target: statusController
                    function onIpBlockRouteRequested(route) {
                        appController.setRoute(String(route || "settings"))
                    }
                }

                // Global IP-burn notice: reCAPTCHA Enterprise flags by IP. When 403s
                // hit across accounts, generation is paused + this sticky, dismissable
                // banner asks the user to route through a clean IP (proxy / WARP).
                Rectangle {
                    id: ipBlockBanner
                    Layout.fillWidth: true
                    Layout.leftMargin: VfTheme.dp(10)
                    Layout.rightMargin: VfTheme.dp(10)
                    Layout.topMargin: visible ? VfTheme.dp(6) : 0
                    visible: statusController.ipBlocked
                    Layout.preferredHeight: visible ? (ipBlockCol.implicitHeight + VfTheme.dp(24)) : 0
                    radius: VfTheme.dp(8)
                    color: VfTheme.amberFill
                    border.color: "#F59E0B"
                    clip: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(12)
                        spacing: VfTheme.dp(12)

                        Rectangle {
                            Layout.preferredWidth: VfTheme.dp(5)
                            Layout.fillHeight: true
                            radius: VfTheme.dp(3)
                            color: "#F59E0B"
                        }

                        ColumnLayout {
                            id: ipBlockCol
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(6)

                            Text {
                                text: (void i18n.revision, i18n.t("app_qml.ip_blocked_notice", "⚠  Google báo hoạt động bất thường (unusual activity)"))
                                color: VfTheme.amberText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(14)
                                font.weight: Font.Bold
                            }

                            Text {
                                Layout.fillWidth: true
                                text: statusController.ipBlockMessage
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                wrapMode: Text.WordWrap
                                lineHeight: 1.25
                            }

                            RowLayout {
                                Layout.topMargin: VfTheme.dp(2)
                                spacing: VfTheme.dp(8)

                                VfButton {
                                    text: (void i18n.revision, i18n.t("qml.account.open_settings", "Mở Cài đặt tài khoản"))
                                    tone: "primary"
                                    onClicked: statusController.openAccountSettings()
                                }
                                VfButton {
                                    text: (void i18n.revision, i18n.t("app_qml.retry_button", "Thử lại"))
                                    onClicked: statusController.retryIpBlock()
                                }
                                VfButton {
                                    text: (void i18n.revision, i18n.t("app_qml.dismiss_button", "Đóng"))
                                    onClicked: statusController.dismissIpBlock()
                                }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: VfTheme.canvas
                    border.color: "transparent"
                    clip: true

                    Item {
                        anchors.fill: parent

                        Loader {
                            id: masterLoader
                            anchors.fill: parent
                            active: window.currentRoute === "master" || window.preloadTick >= 1 || everActive
                            opacity: window.currentRoute === "master" ? 1 : 0
                            visible: opacity > 0
                            source: active ? "screens/MasterPromptScreen.qml" : ""
                            asynchronous: true
                            property bool everActive: false
                            onActiveChanged: if (active) everActive = true
                            Behavior on opacity {
                                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                            }
                        }

                        Loader {
                            id: homeLoader
                            anchors.fill: parent
                            active: window.currentRoute === "home" || window.preloadTick >= 3 || everActive
                            opacity: window.currentRoute === "home" ? 1 : 0
                            visible: opacity > 0
                            source: active ? "screens/HomeScreen.qml" : ""
                            asynchronous: true
                            property bool everActive: false
                            onActiveChanged: if (active) everActive = true
                            Behavior on opacity {
                                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                            }
                        }

                        Loader {
                            id: researchLoader
                            anchors.fill: parent
                            active: window.currentRoute === "research" || window.preloadTick >= 4 || everActive
                            opacity: window.currentRoute === "research" ? 1 : 0
                            visible: opacity > 0
                            source: active ? "screens/ResearchScreen.qml" : ""
                            asynchronous: true
                            property bool everActive: false
                            onActiveChanged: if (active) everActive = true
                            Behavior on opacity {
                                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                            }
                        }

                        Loader {
                            id: voiceLoader
                            anchors.fill: parent
                            active: window.currentRoute === "voice" || window.preloadTick >= 5 || everActive
                            opacity: window.currentRoute === "voice" ? 1 : 0
                            visible: opacity > 0
                            source: active ? "screens/VoiceStudioScreen.qml" : ""
                            asynchronous: true
                            property bool everActive: false
                            onActiveChanged: if (active) everActive = true
                            Behavior on opacity {
                                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                            }
                        }

                        Loader {
                            id: historyLoader
                            anchors.fill: parent
                            active: window.currentRoute === "history" || window.preloadTick >= 6 || everActive
                            opacity: window.currentRoute === "history" ? 1 : 0
                            visible: opacity > 0
                            source: active ? "screens/HistoryScreen.qml" : ""
                            asynchronous: true
                            property bool everActive: false
                            onActiveChanged: if (active) everActive = true
                            Behavior on opacity {
                                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                            }
                        }

                        Loader {
                            id: settingsLoader
                            anchors.fill: parent
                            active: window.currentRoute === "settings" || window.preloadTick >= 7 || everActive
                            opacity: window.currentRoute === "settings" ? 1 : 0
                            visible: opacity > 0
                            source: active ? "screens/AccountSettingsScreen.qml" : ""
                            asynchronous: true
                            property bool everActive: false
                            onActiveChanged: if (active) everActive = true
                            Behavior on opacity {
                                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                            }
                        }

                        Loader {
                            id: workPanelLoader
                            anchors.fill: parent
                            active: window.isWorkRoute(window.currentRoute) || window.preloadTick >= 2 || everActive   // work panel = core + heaviest → pre-warm early (was rank 7)
                            opacity: window.isWorkRoute(window.currentRoute) ? 1 : 0
                            visible: opacity > 0
                            source: active ? "screens/WorkPanelScreen.qml" : ""
                            asynchronous: true
                            property bool everActive: false
                            onActiveChanged: if (active) everActive = true
                            onLoaded: if (item) item.route = Qt.binding(function() { return appController.route })
                            Behavior on opacity {
                                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                            }
                        }

                        Loader {
                            id: timeMachineLoader
                            anchors.fill: parent
                            // Load-bearing: Time Machine gets its own final stagger tick.
                            // Never activate it in the same preload tick as another screen.
                            active: window.currentRoute === "timemachine"
                                    || window.preloadTick >= 8
                                    || everActive
                            opacity: window.currentRoute === "timemachine" ? 1 : 0
                            visible: opacity > 0
                            source: active ? "screens/TimeMachineScreen.qml" : ""
                            asynchronous: true
                            property bool everActive: false
                            onActiveChanged: if (active) everActive = true
                            Behavior on opacity {
                                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                            }
                        }

                        Loader {
                            id: automationCenterLoader
                            anchors.fill: parent
                            active: window.currentRoute === "automation" || everActive
                            visible: window.currentRoute === "automation"
                            source: active ? "screens/AutomationCenterScreen.qml" : ""
                            asynchronous: true
                            property bool everActive: false
                            onActiveChanged: if (active) everActive = true
                        }

                        // "Hướng dẫn" items in the Normal Bulk Import dropdown → run the
                        // in-dialog bulk-import tour for the chosen kind (text / image /
                        // named-ref), each opening the dialog in that mode. Standalone.
                        Connections {
                            target: workPanelLoader.item
                            enabled: workPanelLoader.item !== null
                            ignoreUnknownSignals: true
                            function onBulkImportGuideRequested(guide) {
                                var id = guide === "text" ? "bulk_import"
                                    : guide === "named_ref" ? "bulk_import_named_ref"
                                    : "bulk_import_image"
                                window.startDialogTour(id)
                            }
                        }

                        Loader {
                            id: placeholderLoader
                            anchors.fill: parent
                            active: !(window.currentRoute === "master" || window.currentRoute === "home" || window.currentRoute === "research" || window.currentRoute === "voice" || window.currentRoute === "history" || window.currentRoute === "settings" || window.currentRoute === "timemachine" || window.currentRoute === "automation" || window.isWorkRoute(window.currentRoute))
                            opacity: active ? 1 : 0
                            visible: opacity > 0
                            source: active ? "screens/PlaceholderScreen.qml" : ""
                            asynchronous: true
                            onLoaded: if (item) item.route = Qt.binding(function() { return appController.route })
                            Behavior on opacity {
                                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                            }
                        }
                    }
                }

                StatusBarComponent {
                    route: window.currentRoute
                    statusMessage: window.currentRoute === "timemachine"
                                   && timemachineController
                                   ? timemachineController.statusMessage
                                   : (statusController
                                      ? statusController.statusMessage : "")
                    pageBusy: window.currentRoute === "timemachine"
                              && timemachineController
                              && (Boolean(timemachineController.draftBusy)
                                  || Number((timemachineController.queueStats
                                             || {}).running || 0) > 0)
                    stats: window.currentMasterStats
                    dispatcherLabel: statusController ? statusController.dispatcherLabel : ""
                    serverQueueLabel: statusController ? statusController.serverQueueLabel : ""
                    errorCount: statusController ? statusController.errorCount : 0
                    logPanelVisible: statusController ? statusController.logPanelVisible : false
                    onTokenRequested: statusController.openTokenMonitor()
                    onMonitorRequested: statusController.openJobMonitor()
                    onErrorLogRequested: statusController.openErrorLog()
                    onLogPanelRequested: {
                        if (window._logUnlocked)
                            statusController.openSystemLog()
                        else
                            logPasswordDialog.open()
                    }
                }
            }

            AppBootstrap {
                id: bootstrapOverlay
                anchors.fill: parent
                z: 500
                bootstrapVisible: appController ? appController.bootstrapVisible : false
                title: appController ? appController.bootstrapTitle : "VeoFlow"
                message: appController ? appController.bootstrapMessage : "Starting..."
                detail: appController ? appController.bootstrapDetail : ""
                progress: appController ? appController.bootstrapProgress : 0
                statusTitle: appController ? appController.statusTitle : "Waiting for license..."
                statusSubtitle: appController ? appController.statusSubtitle : "Complete the steps below to start"
                deviceId: appController ? appController.deviceId : ""
                licenseKey: appController ? appController.licenseKey : ""
                licenseHint: appController ? appController.licenseHint : ""
                licenseBusy: appController ? appController.licenseBusy : false
                licenseCheckPending: appController ? appController.licenseCheckPending : false
                licenseVerified: appController ? appController.licenseVerified : false
                bootstrapError: appController ? appController.bootstrapError : ""
                showUpdateAction: appController ? appController.showUpdateAction : false
                progressLog: appController ? appController.progressLog : ""
                stages: appController ? appController.bootstrapStages : []
                systemInfo: appController ? appController.systemInfo : ""
                appVersion: appController ? appController.appVersion : ""
                onLicenseKeyEdited: text => appController.setLicenseKey(text)
                onVerifyRequested: appController.verifyLicense()
                onCopyDeviceRequested: appController.copyDeviceId()
                onExitRequested: appController.exitApplication()
                onUpdateRequested: appController.runBootstrapUpdateAction()
                onClearLicenseRequested: appController.clearLicense()

                Component.onCompleted: {
                    if (appController)
                        appController.startBootstrap()
                }
            }

            LogPanelWidget {
                z: 50
                visible: statusController ? statusController.logPanelVisible : false
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: VfTheme.dp(28)
                anchors.leftMargin: VfTheme.dp(12)
                anchors.rightMargin: VfTheme.dp(12)
                height: Math.min(260, Math.max(160, scaledShell.height * 0.28))
                entries: statusController ? statusController.logEntries : []
                onRefreshRequested: statusController.refreshLogEntries()
                onClearRequested: applyActionResult(statusController.clearLogEntries())
                onCopyRequested: applyActionResult(statusController.copyLogEntries())
                onCloseRequested: statusController.toggleLogPanel()
            }

            // Guided product tour. Sits above the shell, below the bootstrap
            // overlay (z:500). targetRoot = captureRoot so spotlight coords map 1:1.
            TourOverlay {
                id: tourOverlay
                // Live on the popup/overlay layer with a very high z so the
                // spotlight can also cover buttons INSIDE an open dialog. For shell
                // steps this is equivalent (it fills the window); geometry maps to
                // the overlay itself, so both shell and dialog targets resolve.
                parent: Overlay.overlay
                anchors.fill: parent
                z: 100000
                targetRoot: captureRoot
                dialogRoot: Overlay.overlay
                onOpenDialogRequested: dialogId => window.enterDialogFromTour(String(dialogId || ""))
                onStepPre: action => window._tourStepPre(action)
                onFinished: window._onTourFinished()
            }

            // Edge resize handles — OS-native, handles multi-monitor DPI correctly
            Item {
                anchors.fill: parent
                visible: window.resizable
                z: 100

                readonly property int handleSize: 4
                readonly property int cornerSize: 8

                // Top edge
                MouseArea {
                    x: parent.cornerSize
                    y: 0
                    width: parent.width - 2 * parent.cornerSize
                    height: parent.handleSize
                    cursorShape: Qt.SizeVerCursor
                    acceptedButtons: Qt.LeftButton
                    onPressed: window.startSystemResize(Qt.TopEdge)
                }
                // Bottom edge
                MouseArea {
                    x: parent.cornerSize
                    y: parent.height - parent.handleSize
                    width: parent.width - 2 * parent.cornerSize
                    height: parent.handleSize
                    cursorShape: Qt.SizeVerCursor
                    acceptedButtons: Qt.LeftButton
                    onPressed: window.startSystemResize(Qt.BottomEdge)
                }
                // Left edge
                MouseArea {
                    x: 0
                    y: parent.cornerSize
                    width: parent.handleSize
                    height: parent.height - 2 * parent.cornerSize
                    cursorShape: Qt.SizeHorCursor
                    acceptedButtons: Qt.LeftButton
                    onPressed: window.startSystemResize(Qt.LeftEdge)
                }
                // Right edge
                MouseArea {
                    x: parent.width - parent.handleSize
                    y: parent.cornerSize
                    width: parent.handleSize
                    height: parent.height - 2 * parent.cornerSize
                    cursorShape: Qt.SizeHorCursor
                    acceptedButtons: Qt.LeftButton
                    onPressed: window.startSystemResize(Qt.RightEdge)
                }
                // Top-left corner
                MouseArea {
                    x: 0; y: 0
                    width: parent.cornerSize; height: parent.cornerSize
                    cursorShape: Qt.SizeFDiagCursor
                    acceptedButtons: Qt.LeftButton
                    onPressed: window.startSystemResize(Qt.TopEdge | Qt.LeftEdge)
                }
                // Top-right corner
                MouseArea {
                    x: parent.width - parent.cornerSize; y: 0
                    width: parent.cornerSize; height: parent.cornerSize
                    cursorShape: Qt.SizeBDiagCursor
                    acceptedButtons: Qt.LeftButton
                    onPressed: window.startSystemResize(Qt.TopEdge | Qt.RightEdge)
                }
                // Bottom-left corner
                MouseArea {
                    x: 0; y: parent.height - parent.cornerSize
                    width: parent.cornerSize; height: parent.cornerSize
                    cursorShape: Qt.SizeBDiagCursor
                    acceptedButtons: Qt.LeftButton
                    onPressed: window.startSystemResize(Qt.BottomEdge | Qt.LeftEdge)
                }
                // Bottom-right corner
                MouseArea {
                    x: parent.width - parent.cornerSize; y: parent.height - parent.cornerSize
                    width: parent.cornerSize; height: parent.cornerSize
                    cursorShape: Qt.SizeFDiagCursor
                    acceptedButtons: Qt.LeftButton
                    onPressed: window.startSystemResize(Qt.BottomEdge | Qt.RightEdge)
                }
            }
        }
    }


    // Password gate for the System Log button on the status bar. Opening the
    // live log requires this password; closing it does not.
    Dialog {
        id: logPasswordDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: VfTheme.dp(340)
        padding: VfTheme.dp(18)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        readonly property string requiredPassword: "0971125260"
        property string errorText: ""

        background: Rectangle {
            color: VfTheme.surface
            border.color: VfTheme.border
            border.width: 1
            radius: VfTheme.dp(12)
        }

        onOpened: {
            logPasswordField.text = ""
            logPasswordDialog.errorText = ""
            logPasswordField.forceActiveFocus()
        }

        function tryUnlock() {
            if (logPasswordField.text === logPasswordDialog.requiredPassword) {
                logPasswordField.text = ""
                logPasswordDialog.errorText = ""
                logPasswordDialog.close()
                window._logUnlocked = true
                statusController.openSystemLog()
            } else {
                logPasswordDialog.errorText = (void i18n.revision, i18n.t("qml.status.log_password_wrong", "Sai mật khẩu"))
                logPasswordField.selectAll()
                logPasswordField.forceActiveFocus()
            }
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Text {
                text: (void i18n.revision, i18n.t("qml.status.log_password_title", "Nhập mật khẩu để mở System Log"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                font.weight: Font.Medium
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            TextField {
                id: logPasswordField
                Layout.fillWidth: true
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData
                placeholderText: (void i18n.revision, i18n.t("qml.status.log_password_hint", "Mật khẩu"))
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                onAccepted: logPasswordDialog.tryUnlock()
            }

            Text {
                text: logPasswordDialog.errorText
                visible: logPasswordDialog.errorText.length > 0
                color: VfTheme.redBorder
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)
                Item { Layout.fillWidth: true }
                Button {
                    text: (void i18n.revision, i18n.t("qml.common.cancel", "Hủy"))
                    onClicked: logPasswordDialog.close()
                }
                Button {
                    text: (void i18n.revision, i18n.t("qml.common.ok", "OK"))
                    highlighted: true
                    onClicked: logPasswordDialog.tryUnlock()
                }
            }
        }
    }

    Loader {
        id: sharedTtsProviderDialogLoader
        active: false
        asynchronous: true
        sourceComponent: SharedTtsProviderDialog {}
        onLoaded: {
            if (window.pendingSharedTtsContext.length > 0 && item && item.openFor) {
                item.openFor(window.pendingSharedTtsContext)
                window.pendingSharedTtsContext = ""
            }
        }
    }

    Loader {
        id: sequenceGraphicsStudioDialogLoader
        active: false
        asynchronous: true
        sourceComponent: SequenceGraphicsStudioDialog {}
        onLoaded: {
            if (item)
                item.open()
        }
    }

    Loader {
        id: subtitleStudioDialogLoader
        active: false
        asynchronous: true
        sourceComponent: SubtitleStudioDialog {}
        onLoaded: {
            if (item)
                item.open()
        }
    }

    Loader {
        id: runtimeAlertDialogLoader
        active: false
        sourceComponent: RuntimeAlertDialog {
            onActionRequested: function(action, value) {
                if (action === "route") {
                    appController.setRoute(value)
                    close()
                } else if (action === "open_login_browser") {
                    // value = email của account bị logout → mở đúng browser đó để đăng nhập lại
                    accountSettingsController.requestRelogin("", String(value))
                    appController.setRoute("settings")
                    close()
                } else if (action === "refresh_accounts") {
                    accountSettingsController.refreshAccounts()
                    appController.setRoute("settings")
                    close()
                } else if (action === "status_token") {
                    statusController.openTokenMonitor()
                    close()
                } else if (String(action).indexOf("commerce_") === 0 || action === "commerce") {
                    // Topup dialog retired — Token Monitor instead.
                    statusController.openTokenMonitor()
                    close()
                }
            }
            onClosed: statusController.dismissRuntimeAlert()
        }
    }

    Loader {
        id: tokenMonitorDialogLoader
        active: false
        sourceComponent: TokenMonitorDialog {
            id: tokenMonitorDialog
            summary: statusController.tokenSummary
            entries: statusController.tokenEntries
            models: statusController.tokenModels
            monitorDays: statusController.tokenMonitorDays
            monitorModel: statusController.tokenMonitorModel
            onRefreshRequested: statusController.refreshTokenMonitor()
            onDaysRequested: days => statusController.setTokenMonitorDays(days)
            onModelRequested: model => statusController.setTokenMonitorModel(model)
            onClearRequested: tokenMonitorDialog.applyActionResult(statusController.clearTokenHistory())
            onExportRequested: {
                var exported = statusController.exportTokenHistoryCsv()
                if (!exported || !exported.content) {
                    tokenMonitorDialog.applyActionResult({
                        ok: false,
                        action: "token_monitor.export",
                        error: String(exported && exported.error || "token_export_empty"),
                        message: String(exported && exported.message || "Token export unavailable")
                    })
                    return
                }
                var saved = nativeShell.saveTextFile(
                    "Export token history",
                    String(exported.filename || "usage_history_1d.csv"),
                    "CSV Files (*.csv);;All Files (*.*)",
                    String(exported.content || "")
                )
                if (saved && saved.ok) {
                    statusController.setStatusMessage(String(saved.message || "Usage history exported"))
                    tokenMonitorDialog.applyActionResult({
                        ok: true,
                        action: "token_monitor.export",
                        message: String(saved.message || "Usage history exported")
                    })
                } else if (saved && !saved.cancelled) {
                    statusController.setStatusMessage(String(saved.message || "Token export save failed"))
                    tokenMonitorDialog.applyActionResult({
                        ok: false,
                        action: "token_monitor.export",
                        error: "token_export_save_failed",
                        message: String(saved.message || "Token export save failed")
                    })
                }
            }
        }
    }

    Loader {
        id: jobMonitorDialogLoader
        active: false
        sourceComponent: JobMonitorDialog {
            id: jobMonitorDialog
            rows: statusController.jobRows
            historyRows: statusController.historyRows
            accounts: statusController.accountRows
            dispatcherRunning: statusController.dispatcherRunning
            onRefreshRequested: statusController.refreshJobMonitor()
            onStartRequested: jobMonitorDialog.applyActionResult(statusController.startJobDispatcher())
            onStopRequested: jobMonitorDialog.applyActionResult(statusController.stopJobDispatcher())
            onCancelAllRequested: jobMonitorDialog.applyActionResult(statusController.cancelAllActiveJobs())
            onCancelJobRequested: jobId => jobMonitorDialog.applyActionResult(statusController.cancelJob(jobId))
            onRegenJobRequested: jobId => jobMonitorDialog.applyActionResult(statusController.regenJob(jobId))
            onCopyPromptRequested: prompt => jobMonitorDialog.applyActionResult(statusController.copyJobPrompt(prompt))
            onCopyJobIdRequested: jobId => jobMonitorDialog.applyActionResult(statusController.copyJobId(jobId))
        }
    }

    Loader {
        id: errorLogDialogLoader
        active: false
        sourceComponent: ErrorLogDialog {
            id: errorLogDialog
            logText: statusController.errorLogText
            onRefreshRequested: statusController.refreshErrorLog()
            onClearRequested: errorLogDialog.applyActionResult(statusController.clearErrorLog())
        }
    }

    Loader {
        id: systemLogDialogLoader
        active: false
        sourceComponent: SystemLogDialog {
            id: systemLogDialog
            onRefreshRequested: (filterText, sourceFilter) => {
                systemLogDialog.applyRefreshResult(
                    statusController.refreshSystemLog(filterText, sourceFilter))
            }
            onClearRequested: systemLogDialog.applyActionResult(statusController.clearLogEntries())
            onCopyRequested: systemLogDialog.applyActionResult(statusController.copySystemLog())
            onExportRequested: {
                var exported = statusController.exportSystemLog()
                if (!exported || !exported.ok || !exported.content) {
                    systemLogDialog.applyActionResult({
                        ok: false,
                        action: "system_log.export",
                        message: String(exported && exported.message || "No log to export")
                    })
                    return
                }
                var saved = nativeShell.saveTextFile(
                    (void i18n.revision, i18n.t("system_log.export_title", "Export system log")),
                    String(exported.filename || "veoflow_log.txt"),
                    "Text Files (*.txt);;All Files (*.*)",
                    String(exported.content || "")
                )
                if (saved && saved.ok) {
                    systemLogDialog.applyActionResult({
                        ok: true,
                        action: "system_log.export",
                        message: String(saved.message || "Log exported")
                    })
                } else if (saved && !saved.cancelled) {
                    systemLogDialog.applyActionResult({
                        ok: false,
                        action: "system_log.export",
                        message: String(saved.message || "Export save failed")
                    })
                }
            }
        }
    }

    Loader {
        id: headerInfoDialogLoader
        active: false
        sourceComponent: HeaderInfoDialog {
            id: headerInfoDialog
            payload: headerController.dialog
            busy: headerController.busy
            currentActionId: headerController.currentAction
            actionProgressValue: headerController.actionProgressValue
            actionProgressText: headerController.actionProgressText
            actionProgressIndeterminate: headerController.actionProgressIndeterminate
            onActionRequested: (action, value) => window.handleHeaderDialogAction(headerInfoDialog, action, value)
        }
    }

    Loader {
        id: headerDataDialogLoader
        active: false
        sourceComponent: HeaderDataDialog {
            id: headerDataDialog
            payload: headerController.dialog
            onActionRequested: (action, value) => window.handleHeaderDialogAction(headerDataDialog, action, value)
        }
    }

    Loader {
        id: headerUpdateDialogLoader
        active: false
        sourceComponent: HeaderUpdateDialog {
            id: headerUpdateDialog
            payload: headerController.dialog
            busy: headerController.busy
            currentActionId: headerController.currentAction
            actionProgressValue: headerController.actionProgressValue
            actionProgressText: headerController.actionProgressText
            actionProgressIndeterminate: headerController.actionProgressIndeterminate
            onActionRequested: (action, value) => window.handleHeaderDialogAction(headerUpdateDialog, action, value)
        }
    }

    Loader {
        id: headerCommerceDialogLoader
        active: false
        sourceComponent: HeaderCommerceDialog {
            id: headerCommerceDialog
            payload: headerController.dialog
            // Reactive: admin allow-list updates live (async api-keys payload → controller
            // emits allowedModesChanged → buttons hide/show without reopening the dialog).
            allowedModes: accountSettingsController.allowedModes
            busy: headerController.busy
            paymentPolling: headerController.paymentPolling
            currentActionId: headerController.currentAction
            actionProgressValue: headerController.actionProgressValue
            actionProgressText: headerController.actionProgressText
            actionProgressIndeterminate: headerController.actionProgressIndeterminate
            onTopupRequested: value => window.handleHeaderDialogAction(headerCommerceDialog, "commerce_topup", value)
            onPaymentPollRequested: orderCode => headerController.pollPaymentInfo(orderCode)
            onActionRequested: (action, value) => window.handleHeaderDialogAction(headerCommerceDialog, action, value)
            onExternalUrlRequested: url => nativeShell.openExternal(url)
            onModeRequested: mode => {
                // Exclusive provider selection; no cross-provider fallback.
                var m = String(mode || "aistudio")
                if (m === "aistudio")
                    accountSettingsController.applyProviderMix(true, false, false)
                else if (m === "server")
                    accountSettingsController.applyProviderMix(false, true, false)
                else if (m === "personal")
                    accountSettingsController.applyProviderMix(false, false, true)
                else
                    accountSettingsController.setApiMode(m)
                headerCommerceDialog.apiMode = String(accountSettingsController.apiMode || m)
                headerCommerceDialog.applyModeResult({ ok: true, api_mode: headerCommerceDialog.apiMode, message: "Mode: " + m })
            }
            onAddRequested: (provider, label, key) => {
                var r = accountSettingsController.addApiKey(provider, key, label)
                headerCommerceDialog.applyAddResult(r || ({ ok: true, message: "Key save requested" }))
                // Async finish also refreshes list via settingsActionFinished if needed
                accountSettingsController.refreshApiKeys()
                headerCommerceDialog.keys = accountSettingsController.apiKeys || []
            }
            onDeleteRequested: keyId => {
                var r = accountSettingsController.removeApiKey(Number(keyId || 0))
                headerCommerceDialog.applyDeleteResult(r || ({ ok: true }))
                accountSettingsController.refreshApiKeys()
                headerCommerceDialog.keys = accountSettingsController.apiKeys || []
            }
            onRefreshRequested: {
                accountSettingsController.refreshApiKeys()
                headerCommerceDialog.keys = accountSettingsController.apiKeys || []
                headerController.executeAction("commerce_load_store", "")
            }
        }
    }

    Loader {
        id: featurePurchaseDialogLoader
        active: false
        sourceComponent: FeaturePurchaseDialog {
            id: featurePurchaseDialog
            payload: headerController.dialog
            featureStateProvider: appController
            busy: headerController.busy
            paymentPolling: headerController.paymentPolling
            onBuyRequested: (featureCode, days, paymentMethod) =>
                headerController.buyFeatureDays(featureCode, days, paymentMethod)
            onPaymentPollRequested: orderCode => headerController.pollPaymentInfo(orderCode)
            onRefreshRequested: headerController.executeAction("commerce_load_store", "")
            onOpenFeatureRequested: route => appController.setRoute(String(route || ""))
            onDismissed: headerController.dismissFeaturePurchase()
        }
    }

    Loader {
        id: headerMediaLibraryDialogLoader
        active: false
        sourceComponent: MediaLibraryDialog {
            id: headerMediaLibraryDialog
            items: visible ? workPanelController.mediaLibraryItems : []
            stats: workPanelController.mediaLibraryStats
            settings: workPanelController.mediaLibrarySettings
            onRefreshRequested: (search, assetType) => workPanelController.refreshMediaLibrary(search, assetType)
            onImportRequested: (rawPaths, tags, assetType) => headerMediaLibraryDialog.applyImportResult(workPanelController.importMediaPaths(rawPaths, tags, assetType))
        }
    }

    Loader {
        id: aboutDialogLoader
        active: false
        sourceComponent: AboutDialog {
            id: aboutDialog
            onExternalUrlRequested: url => nativeShell.openExternal(url)
            onFeaturePurchaseRequested: route => {
                aboutDialog.close()
                headerController.openFeaturePurchase(String(route || ""))
            }
        }
    }

    Loader {
        id: apiKeysDialogLoader
        active: false
        sourceComponent: ApiKeysDialog {
            id: apiKeysDialog
            keys: accountSettingsController.apiKeys
            apiMode: accountSettingsController.apiMode
            onRefreshRequested: accountSettingsController.refreshApiKeys()
            onAddRequested: (provider, label, key) => apiKeysDialog.applyAddResult(accountSettingsController.addApiKey(provider, key, label))
            onDeleteRequested: keyId => apiKeysDialog.applyDeleteResult(accountSettingsController.removeApiKey(Number(keyId || 0)))
            onModeRequested: mode => apiKeysDialog.applyModeResult(accountSettingsController.setApiMode(mode))
        }
    }

    Loader {
        id: themeManagerDialogLoader
        active: false
        sourceComponent: ThemeEditDialog {
            onHostBlocked: payload => statusController.setStatusMessage(String(payload.message || payload.code || "Theme manager blocked"))
            onSaved: result => statusController.setStatusMessage(String(result.message || "Theme saved"))
            onDeleted: result => statusController.setStatusMessage(String(result.message || "Theme deleted"))
        }
    }

    Loader {
        id: strategyManagerDialogLoader
        active: false
        sourceComponent: StrategyEditDialog {
            onHostBlocked: payload => statusController.setStatusMessage(String(payload.message || payload.code || "Strategy manager blocked"))
            onSaved: result => statusController.setStatusMessage(String(result.message || "Strategy saved"))
            onDeleted: result => statusController.setStatusMessage(String(result.message || "Strategy deleted"))
        }
    }

    // First-activation welcome. Offers the full auto-guide walkthrough.
    Loader {
        id: welcomeDialogLoader
        active: false
        sourceComponent: Dialog {
            id: welcomeDialog
            parent: Overlay.overlay
            modal: true
            anchors.centerIn: parent
            width: VfTheme.dp(640)
            padding: VfTheme.dp(28)
            title: ""
            header: null
            closePolicy: Popup.CloseOnEscape

            // Highlights shown in the welcome card — one compact row each. Flat
            // colour accents only (no gradients).
            readonly property var _features: [
                { c: "#2563EB", t: (void i18n.revision, i18n.t("qml.tour.wf_master_t", "Master Prompt")),
                  d: (void i18n.revision, i18n.t("qml.tour.wf_master_d", "Tạo hàng loạt video từ ý tưởng hoặc kịch bản — AI tự viết & phân cảnh.")) },
                { c: "#0EA5E9", t: (void i18n.revision, i18n.t("qml.tour.wf_clone_t", "Clone Video")),
                  d: (void i18n.revision, i18n.t("qml.tour.wf_clone_d", "Copy chính xác · Remix đổi nhân vật/bối cảnh · Sáng tạo lại theo công thức.")) },
                { c: "#22C55E", t: (void i18n.revision, i18n.t("qml.tour.wf_audio_t", "Audio → Video")),
                  d: (void i18n.revision, i18n.t("qml.tour.wf_audio_d", "Biến file giọng đọc thành video có hình, mỗi file 1 kịch bản riêng.")) },
                { c: "#F59E0B", t: (void i18n.revision, i18n.t("qml.tour.wf_pipe_t", "Normal · Extend · Batch")),
                  d: (void i18n.revision, i18n.t("qml.tour.wf_pipe_d", "Pipeline nâng cao: tạo ảnh, nối/gia hạn video, xử lý theo lô.")) },
                { c: "#7C3AED", t: (void i18n.revision, i18n.t("qml.tour.wf_job_t", "Bảng Job realtime")),
                  d: (void i18n.revision, i18n.t("qml.tour.wf_job_d", "Theo dõi tiến độ từng cảnh; tạo lại · upscale · sửa · xoá ngay tại chỗ.")) },
                { c: "#64748B", t: (void i18n.revision, i18n.t("qml.tour.wf_settings_t", "Tài khoản · Proxy · TTS")),
                  d: (void i18n.revision, i18n.t("qml.tour.wf_settings_d", "Thêm tài khoản Google, gán proxy, cấu hình database.")) }
            ]

            background: Rectangle {
                radius: VfTheme.dp(16)
                color: VfTheme.surface
                border.color: VfTheme.border
                border.width: 1
            }

            contentItem: ColumnLayout {
                spacing: VfTheme.dp(14)

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(6)
                    VfAppIcon {
                        Layout.alignment: Qt.AlignHCenter
                        name: "rocket"
                        size: VfTheme.dp(44)
                        framed: false
                    }
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: (void i18n.revision, i18n.t("qml.tour.welcome_title", "Chào mừng đến VeoFlow!"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(22)
                        font.weight: Font.Bold
                    }
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: (void i18n.revision, i18n.t("qml.tour.welcome_intro", "Xưởng sản xuất video AI hàng loạt. Dưới đây là các khu vực chính — bấm Bắt đầu để xem tour tự chạy qua từng tab."))
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                        wrapMode: Text.WordWrap
                        lineHeight: 1.3
                    }
                }

                // Feature highlights
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: VfTheme.dp(4)
                    spacing: VfTheme.dp(9)
                    Repeater {
                        model: welcomeDialog._features
                        delegate: RowLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(11)
                            Rectangle {
                                Layout.preferredWidth: VfTheme.dp(4)
                                Layout.fillHeight: true
                                Layout.topMargin: VfTheme.dp(2)
                                Layout.bottomMargin: VfTheme.dp(2)
                                radius: VfTheme.dp(2)
                                color: modelData.c
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(1)
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.t
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(14)
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.d
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(12)
                                    wrapMode: Text.WordWrap
                                    lineHeight: 1.25
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: VfTheme.dp(2)
                    text: (void i18n.revision, i18n.t("qml.tour.welcome_autonote", "Tour TỰ CHẠY: mỗi bước dừng vài giây cho bạn đọc rồi tự sang bước kế. Bạn có thể bấm Tạm dừng, Tiếp / Quay lại, hoặc Esc bất cứ lúc nào. Các tab không có trong gói của bạn sẽ được bỏ qua."))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    wrapMode: Text.WordWrap
                    lineHeight: 1.3
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: VfTheme.dp(6)
                    spacing: VfTheme.dp(8)
                    Item { Layout.fillWidth: true }
                    VfButton {
                        text: (void i18n.revision, i18n.t("qml.tour.welcome_later", "Để sau"))
                        onClicked: welcomeDialog.close()
                    }
                    VfButton {
                        tone: "primary"
                        text: (void i18n.revision, i18n.t("qml.tour.welcome_start", "Bắt đầu hướng dẫn"))
                        onClicked: {
                            welcomeDialog.close()
                            window.startAutoPlay()
                        }
                    }
                }
            }
        }
    }

    NativeDialogHost {
        id: nativeDialogHost
    }
}
