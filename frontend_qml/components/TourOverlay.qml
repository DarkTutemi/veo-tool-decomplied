import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"
import "AppIconRegistry.js" as AppIconRegistry

// Guided product-tour overlay.
//
// Design constraints (repo laws — see .claude/skills/qml-patterns):
//   - Spotlight is FOUR plain Rectangles around the target hole. NO Qt5Compat
//     GraphicalEffects / ShaderEffectSource cutout (that class = native crash
//     Qt6Qml.dll +0x3fa03).
//   - Target geometry is recomputed on step-change, on overlay resize, and when
//     the enclosing scroller moves — via signals/Connections, NEVER a poll Timer.
//     The only Timer is a BOUNDED one-shot retry to wait out async screen loads.
//   - Modal: a full-cover MouseArea eats clicks; the user advances with Next.
//
// Usage: set `targetRoot` to the item whose coordinate space the spotlight uses
// (App.qml passes captureRoot). Call start(steps). Emits finished() when done.
Item {
    id: overlay

    // Primary search root for targets (the app shell). Geometry is mapped to THIS
    // overlay's own coordinate space, so targetRoot only needs to CONTAIN targets.
    property Item targetRoot: null
    // Secondary search root — the popup/overlay layer (Overlay.overlay). Lets the
    // tour also spotlight buttons INSIDE an open dialog (Media Library / Style
    // Manager). Requires this overlay to be parented into that same layer with a
    // high z so it renders ABOVE the dialog.
    property Item dialogRoot: null

    property var steps: []
    property int index: 0
    property bool active: false
    property string currentRoute: ""

    signal finished()
    // Emitted when a step's target is actually resolved + displayed (NOT for
    // auto-skipped steps). App.qml uses it to remember shared/common intro steps
    // so they aren't repeated in later tab tours.
    signal stepShown(var step)
    // A step may carry `dialog: "<id>"` — a big feature dialog (Media Library,
    // Style Manager). The callout then shows a "Mở thử" button; clicking it asks
    // App.qml to open that dialog so the user can look inside hands-on. The dialog
    // (modal, in the overlay layer) covers the tour; closing it returns to the tour.
    signal openDialogRequested(string dialogId)
    // A step may carry `pre: "<action>"` (e.g. "filter:voice") — a side-effect run
    // ONCE when the step is entered, before its target is resolved. Used to switch
    // a dialog into the mode where the step's control is visible.
    signal stepPre(string action)

    readonly property var currentStep: (active && index >= 0 && index < steps.length)
        ? steps[index] : null
    readonly property int stepCount: steps ? steps.length : 0

    // --- Resolved target + hole geometry (in overlay coords) ---
    property Item _target: null
    property Item _scroller: null
    readonly property int _pad: VfTheme.dp(6)
    readonly property real _holeRadius: VfTheme.dp(10)
    property real holeX: 0
    property real holeY: 0
    property real holeW: 0
    property real holeH: 0
    property bool _hasHole: false
    // True when the tour ended because the user pressed "Bỏ qua" (vs. finishing all
    // steps). Auto-guide uses it: SKIP ends the whole walkthrough; DONE chains on.
    property bool skipped: false

    // Auto-play: advance each step on its own after a reading-time delay (no clicking).
    // autoPaused freezes the countdown; _autoProgress (0→1) drives the callout timer bar.
    property bool autoPlay: false
    property bool autoPaused: false
    property real _autoProgress: 0

    // Reading time for the current callout — floor ~1.6 s, +~35 ms per character of
    // title+body, capped ~7 s so a long explanation isn't cut off but a one-liner
    // doesn't drag. (User: "cách mỗi 1,5 giây hoặc đủ cho người đọc".)
    function _autoDelay(step) {
        if (!step)
            return 2200
        var len = String(step.title || "").length + String(overlay._bodyText || "").length
        return Math.max(1600, Math.min(7000, 1800 + len * 35))
    }

    function _startAuto(step) {
        autoAnim.stop()
        overlay._autoProgress = 0
        if (!overlay.autoPlay)
            return
        autoAnim.duration = overlay._autoDelay(step)
        autoAnim.start()
        if (overlay.autoPaused)
            autoAnim.pause()
    }

    function toggleAutoPause() {
        overlay.autoPaused = !overlay.autoPaused
        if (overlay.autoPaused)
            autoAnim.pause()
        else
            autoAnim.resume()
    }

    // ---------------------------------------------------------------- lifecycle
    // startIndex lets a resumed tour continue partway through (e.g. after a nested
    // dialog tour returns to the tab tour at the next step).
    function start(stepList, startIndex) {
        overlay.skipped = false
        overlay.steps = stepList || []
        overlay.index = overlay.steps.length > 0
            ? Math.max(0, Math.min(Number(startIndex || 0), overlay.steps.length - 1))
            : 0
        overlay.active = overlay.steps.length > 0
        if (overlay.active)
            overlay._resolveCurrent()
        else
            overlay.finished()
    }

    function skip() {
        overlay.skipped = true
        overlay.stop()
    }

    function stop() {
        retryTimer.stop()
        settleTimer.stop()
        autoAnim.stop()
        overlay._autoProgress = 0
        overlay._target = null
        overlay._scroller = null
        overlay._hasHole = false
        overlay.active = false
        overlay.finished()
    }

    function next() {
        if (overlay.index < overlay.steps.length - 1) {
            overlay.index += 1
            overlay._resolveCurrent()
        } else {
            overlay.stop()
        }
    }

    function prev() {
        if (overlay.index > 0) {
            overlay.index -= 1
            overlay._resolveCurrent()
        }
    }

    // ------------------------------------------------------------ target lookup
    function _resolveCurrent() {
        retryTimer.stop()
        settleTimer.stop()
        autoAnim.stop()
        overlay._autoProgress = 0
        overlay._target = null
        overlay._scroller = null
        retryTimer._elapsed = 0
        var step = overlay.currentStep
        if (step && String(step.pre || "").length > 0)
            overlay.stepPre(String(step.pre))
        overlay._tryResolve()
    }

    readonly property bool _isDialogTour: String(overlay.currentRoute).indexOf("dialog:") === 0

    function _resolveTarget(step) {
        var prop = String(step.objectName || "").length > 0 ? "objectName" : "actionId"
        var wanted = prop === "objectName" ? String(step.objectName) : String(step.actionId || "")
        // Search the open-dialog layer ONLY during a dialog tour — a shell tour must
        // not traverse the (large) dialog trees on the overlay layer (that was lag).
        if (overlay._isDialogTour && overlay.dialogRoot) {
            var inDialog = overlay._findByProp(overlay.dialogRoot, prop, wanted)
            if (inDialog)
                return inDialog
        }
        return overlay._findByProp(overlay.targetRoot, prop, wanted)
    }

    function _tryResolve() {
        var step = overlay.currentStep
        if (!step || (!overlay.targetRoot && !overlay.dialogRoot))
            return
        var found = overlay._resolveTarget(step)
        if (found) {
            overlay._target = found
            overlay._scroller = overlay._findFlickable(found)
            overlay._ensureVisible(found)
            // Recompute after any scroll settles on the next tick.
            Qt.callLater(overlay._updateGeometry)
            overlay._updateGeometry()
            // Async screens (e.g. CloneWorkspace) keep REFLOWING for a few frames
            // after the target first appears — its size grows, ancestors shift — and
            // that motion fires NO contentY signal, so the hole would stick to the
            // stale position ("lệch nút"). Re-hug the target over a short bounded
            // burst (NOT an ongoing poll) until layout settles.
            settleTimer.stop(); settleTimer._ticks = 0; settleTimer.start()
            overlay.stepShown(step)
            overlay._startAuto(step)
            return
        }
        // Not found as a VISIBLE target. Two very different reasons:
        //   (a) the control EXISTS in the tree but sits under a visible:false subtree
        //       — a deliberate conditional hide (per-row button with no rows, the
        //       hidden half of a mutually-exclusive Install/Start pair, a mode-specific
        //       chip). It will NOT appear on its own → skip NOW, so no nowhere-pointing
        //       callout parks on screen for 6 s.
        //   (b) the control is ABSENT from the tree entirely — an async Loader still
        //       compiling (e.g. CloneWorkspace ~175KB) or a not-yet-laid-out item.
        //       That one really can appear → keep retrying up to the full budget.
        // Skip a deliberately-hidden target — but NOT on the very first (synchronous)
        // attempt: right after a tab switch the incoming screen is still at opacity 0
        // (visible:false) for a frame, so give it one retry to appear before deciding
        // it's hidden. Otherwise every step of the new tab false-skips.
        // Also NEVER fast-skip a step carrying a `pre:` action: that action is about to
        // reveal the (currently-hidden) section, so wait the full budget for it to show.
        var _hasPre = String(step.pre || "").length > 0
        if (!_hasPre && retryTimer._elapsed > 0 && overlay._existsButHidden(step)) {
            overlay.next()
            return
        }
        if (retryTimer._elapsed >= retryTimer._budget) {
            overlay.next()   // absent for the whole budget → give up (async never came)
            return
        }
        retryTimer.start()
    }

    function _findByProp(root, prop, wanted) {
        if (!root || String(wanted).length === 0)
            return null
        var stack = [root]
        var guard = 0
        while (stack.length > 0 && guard < 20000) {
            guard += 1
            var item = stack.pop()
            if (!item)
                continue
            // Skip invisible sub-trees entirely.
            if (item.visible === false)
                continue
            if (String(item[prop] || "") === wanted
                    && item.width > 0 && item.height > 0)
                return item
            var kids = item.children
            if (kids) {
                for (var i = 0; i < kids.length; i += 1)
                    stack.push(kids[i])
            }
            if (item.contentItem && item.contentItem !== item)
                stack.push(item.contentItem)
        }
        return null
    }

    // Classify a not-found target: does it EXIST in the tree but sit under a
    // visible:false subtree (deliberate conditional hide → skip now), versus being
    // absent (async-compiling / not laid out → keep waiting)? Mirrors the root
    // selection of _resolveTarget.
    function _existsButHidden(step) {
        if (!step)
            return false
        var prop = String(step.objectName || "").length > 0 ? "objectName" : "actionId"
        var wanted = prop === "objectName" ? String(step.objectName) : String(step.actionId || "")
        if (wanted.length === 0)
            return false
        var foundAny = false
        var roots = []
        if (overlay._isDialogTour && overlay.dialogRoot)
            roots.push(overlay.dialogRoot)
        if (overlay.targetRoot)
            roots.push(overlay.targetRoot)
        for (var r = 0; r < roots.length; r += 1) {
            var res = overlay._scanProp(roots[r], prop, wanted)
            // A NON-hidden instance exists — the current route's control (maybe just
            // not laid out yet) OR the same id in a still-visible workspace. It can
            // still appear → do NOT fast-skip. This is the fix for shared work_panel.*
            // ids: an off-route sibling workspace holds a hidden copy, which must not
            // make the tour skip the real (current-tab) control.
            if (res.nonHidden)
                return false
            if (res.found)
                foundAny = true
        }
        // Found ONLY under visible:false subtrees → deliberately hidden → skip.
        return foundAny
    }

    // Scan for a prop match ignoring visibility/size. Returns whether ANY match exists
    // (`found`) and whether any match is NOT under a hidden (visible:false) chain
    // (`nonHidden`). Used ONLY to classify a not-found target.
    function _scanProp(root, prop, wanted) {
        var out = { "found": false, "nonHidden": false }
        if (!root || String(wanted).length === 0)
            return out
        var stack = [root]
        var guard = 0
        while (stack.length > 0 && guard < 20000) {
            guard += 1
            var item = stack.pop()
            if (!item)
                continue
            if (String(item[prop] || "") === wanted) {
                out.found = true
                if (!overlay._isHiddenChain(item))
                    out.nonHidden = true
            }
            var kids = item.children
            if (kids) {
                for (var i = 0; i < kids.length; i += 1)
                    stack.push(kids[i])
            }
            if (item.contentItem && item.contentItem !== item)
                stack.push(item.contentItem)
        }
        return out
    }

    // True if the item or any ancestor is explicitly visible:false — i.e. deliberately
    // hidden, not merely un-laid-out (size 0 but visible, which we still wait for).
    function _isHiddenChain(item) {
        var p = item
        var guard = 0
        while (p && guard < 200) {
            guard += 1
            if (p.visible === false)
                return true
            p = p.parent
        }
        return false
    }

    function _findFlickable(item) {
        var p = item ? item.parent : null
        var guard = 0
        while (p && guard < 200) {
            guard += 1
            if (p.contentY !== undefined && p.contentHeight !== undefined
                    && p.flickableDirection !== undefined)
                return p
            p = p.parent
        }
        return null
    }

    function _ensureVisible(item) {
        var fl = overlay._scroller
        if (!fl || !item)
            return
        var pos = item.mapToItem(fl.contentItem, 0, 0)
        var margin = VfTheme.dp(28)
        var top = pos.y
        var bottom = pos.y + item.height
        var maxY = Math.max(0, fl.contentHeight - fl.height)
        if (top < fl.contentY + margin)
            fl.contentY = Math.max(0, Math.min(maxY, top - margin))
        else if (bottom > fl.contentY + fl.height - margin)
            fl.contentY = Math.max(0, Math.min(maxY, bottom - fl.height + margin))
    }

    function _updateGeometry() {
        var item = overlay._target
        if (!item || item.width <= 0 || item.height <= 0) {
            overlay._hasHole = false
            return
        }
        // Map straight into THIS overlay's coordinate space — works whether the
        // target lives in the shell or inside a dialog on the overlay layer.
        var r = item.mapToItem(overlay, 0, 0)
        overlay.holeX = r.x - overlay._pad
        overlay.holeY = r.y - overlay._pad
        overlay.holeW = item.width + overlay._pad * 2
        overlay.holeH = item.height + overlay._pad * 2
        overlay._hasHole = true
    }

    // Bounded retry — waits out async Loader compile / conditional visibility.
    // NOT a coordinate poll: it stops the moment the target resolves. Budget is
    // generous because heavy tabs lazy-compile async (e.g. CloneWorkspace ~175KB):
    // the first control on such a tab can take a while to appear in the tree.
    Timer {
        id: retryTimer
        interval: 120
        repeat: false
        property int _elapsed: 0
        readonly property int _budget: 6000
        onTriggered: {
            retryTimer._elapsed += retryTimer.interval
            overlay._tryResolve()
        }
    }

    // Bounded settle burst after a target resolves — re-hugs the hole for ~640 ms
    // while an async screen's layout is still reflowing (content height growing,
    // ancestors shifting) with no scroll signal to react to. One-shot per step,
    // NOT an ongoing coordinate poll.
    Timer {
        id: settleTimer
        interval: 80
        repeat: true
        property int _ticks: 0
        onTriggered: {
            overlay._updateGeometry()
            settleTimer._ticks += 1
            if (settleTimer._ticks >= 8)
                settleTimer.stop()
        }
    }

    // Auto-play driver: a single animation both fills the callout timer bar
    // (_autoProgress 0→1) and, on natural completion, advances to the next step.
    // stop() (manual next / step change) fires onStopped, not onFinished, so a
    // hand advance never double-fires.
    NumberAnimation {
        id: autoAnim
        target: overlay
        property: "_autoProgress"
        from: 0
        to: 1
        duration: 2200
        onFinished: {
            // Defer to the next tick so we don't restart this same animation from
            // inside its own finished handler (re-entrancy).
            if (overlay.active && overlay.autoPlay && !overlay.autoPaused)
                Qt.callLater(overlay.next)
        }
    }

    // Keep the spotlight glued while the scroller animates into position, and on
    // resize / scale change. Signal-driven, per the no-poll law.
    Connections {
        target: overlay._scroller
        enabled: overlay.active && overlay._scroller !== null
        ignoreUnknownSignals: true
        function onContentYChanged() { overlay._updateGeometry() }
        function onContentXChanged() { overlay._updateGeometry() }
        function onContentHeightChanged() { overlay._updateGeometry() }
        function onContentWidthChanged() { overlay._updateGeometry() }
    }
    // Re-hug when the target itself moves/resizes (its own geometry signals).
    Connections {
        target: overlay._target
        enabled: overlay.active && overlay._target !== null
        ignoreUnknownSignals: true
        function onXChanged() { overlay._updateGeometry() }
        function onYChanged() { overlay._updateGeometry() }
        function onWidthChanged() { overlay._updateGeometry() }
        function onHeightChanged() { overlay._updateGeometry() }
    }
    onWidthChanged: if (active) overlay._updateGeometry()
    onHeightChanged: if (active) overlay._updateGeometry()

    visible: active
    z: 300

    // -------------------------------------------------------------- click block
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onClicked: {}
        onWheel: {}
    }

    // ------------------------------------------------------------- dim + hole
    readonly property color _dim: Qt.rgba(0, 0, 0, 0.58)

    // Four masks around the hole. When there's no hole yet (resolving), a single
    // full-cover mask (top) dims everything.
    Rectangle {   // top
        color: overlay._dim
        x: 0; y: 0
        width: overlay.width
        height: overlay._hasHole ? Math.max(0, overlay.holeY) : overlay.height
    }
    Rectangle {   // bottom
        color: overlay._dim
        visible: overlay._hasHole
        x: 0
        y: overlay.holeY + overlay.holeH
        width: overlay.width
        height: Math.max(0, overlay.height - (overlay.holeY + overlay.holeH))
    }
    Rectangle {   // left
        color: overlay._dim
        visible: overlay._hasHole
        x: 0
        y: overlay.holeY
        width: Math.max(0, overlay.holeX)
        height: overlay.holeH
    }
    Rectangle {   // right
        color: overlay._dim
        visible: overlay._hasHole
        x: overlay.holeX + overlay.holeW
        y: overlay.holeY
        width: Math.max(0, overlay.width - (overlay.holeX + overlay.holeW))
        height: overlay.holeH
    }

    // Round the four square corners of the rectangular hole so the spotlight
    // matches the rounded controls (no square-corner dim leak). Each piece dims
    // just the corner triangle, its inner corner carved by a per-corner radius
    // (Qt 6.7+). Plain Rectangles — no Qt5Compat effect.
    Rectangle {   // top-left
        visible: overlay._hasHole
        color: overlay._dim
        x: overlay.holeX; y: overlay.holeY
        width: overlay._holeRadius; height: overlay._holeRadius
        bottomRightRadius: overlay._holeRadius
    }
    Rectangle {   // top-right
        visible: overlay._hasHole
        color: overlay._dim
        x: overlay.holeX + overlay.holeW - overlay._holeRadius; y: overlay.holeY
        width: overlay._holeRadius; height: overlay._holeRadius
        bottomLeftRadius: overlay._holeRadius
    }
    Rectangle {   // bottom-left
        visible: overlay._hasHole
        color: overlay._dim
        x: overlay.holeX; y: overlay.holeY + overlay.holeH - overlay._holeRadius
        width: overlay._holeRadius; height: overlay._holeRadius
        topRightRadius: overlay._holeRadius
    }
    Rectangle {   // bottom-right
        visible: overlay._hasHole
        color: overlay._dim
        x: overlay.holeX + overlay.holeW - overlay._holeRadius
        y: overlay.holeY + overlay.holeH - overlay._holeRadius
        width: overlay._holeRadius; height: overlay._holeRadius
        topLeftRadius: overlay._holeRadius
    }

    // Highlight ring around the target.
    Rectangle {
        visible: overlay._hasHole
        x: overlay.holeX
        y: overlay.holeY
        width: overlay.holeW
        height: overlay.holeH
        radius: overlay._holeRadius
        color: "transparent"
        border.color: VfTheme.primary
        border.width: 2
        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
    }

    // ------------------------------------------------------------------ callout
    readonly property string _bodyText: {
        var step = overlay.currentStep
        if (!step)
            return ""
        var body = String(step.body || "")
        if (body.length > 0)
            return body
        return AppIconRegistry.resolveActionTooltip(String(step.actionId || ""), "", String(step.title || ""))
    }

    Rectangle {
        id: callout
        width: Math.min(VfTheme.dp(440), overlay.width - VfTheme.dp(32))
        implicitHeight: calloutCol.implicitHeight + VfTheme.dp(28)
        height: implicitHeight
        radius: VfTheme.dp(12)
        color: VfTheme.surface
        border.color: VfTheme.border
        border.width: 1
        visible: overlay.active

        // Place the callout on the best free side of the hole: below → above →
        // beside. A tall target (e.g. the full-height Job Panel) has no room above or
        // below, so the callout goes to the emptier SIDE, vertically centred on the
        // hole — instead of being shoved to the very bottom, disconnected from it.
        readonly property real _gap: VfTheme.dp(14)
        readonly property real _edge: VfTheme.dp(12)
        readonly property var _place: {
            var w = width, h = height
            if (!overlay._hasHole)
                return { "x": Math.round((overlay.width - w) / 2), "y": Math.round((overlay.height - h) / 2) }
            var cx = overlay.holeX + overlay.holeW / 2
            var cy = overlay.holeY + overlay.holeH / 2
            var clampX = Math.max(_edge, Math.min(cx - w / 2, overlay.width - w - _edge))
            var clampYc = Math.max(_edge, Math.min(cy - h / 2, overlay.height - h - _edge))
            var below = overlay.holeY + overlay.holeH + _gap
            if (below + h <= overlay.height - _edge)
                return { "x": clampX, "y": below }
            var above = overlay.holeY - h - _gap
            if (above >= _edge)
                return { "x": clampX, "y": above }
            // Beside — pick the side with more room.
            var leftX = overlay.holeX - w - _gap
            var rightX = overlay.holeX + overlay.holeW + _gap
            var spaceLeft = overlay.holeX
            var spaceRight = overlay.width - (overlay.holeX + overlay.holeW)
            if (spaceRight >= spaceLeft && rightX + w <= overlay.width - _edge)
                return { "x": rightX, "y": clampYc }
            if (leftX >= _edge)
                return { "x": leftX, "y": clampYc }
            if (rightX + w <= overlay.width - _edge)
                return { "x": rightX, "y": clampYc }
            return { "x": clampX, "y": Math.max(_edge, Math.min(below, overlay.height - h - _edge)) }
        }
        x: _place.x
        y: _place.y
        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        // Auto-play countdown bar along the callout's bottom edge — fills as the
        // reading timer runs; frozen (dim) while paused.
        Rectangle {
            visible: overlay.autoPlay && overlay._hasHole
            x: 0
            y: parent.height - height
            height: VfTheme.dp(3)
            width: parent.width * Math.max(0, Math.min(1, overlay._autoProgress))
            radius: height / 2
            color: overlay.autoPaused ? VfTheme.textSubtle : VfTheme.primary
        }

        ColumnLayout {
            id: calloutCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: VfTheme.dp(14)
            spacing: VfTheme.dp(8)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Text {
                    Layout.fillWidth: true
                    text: overlay.currentStep ? String(overlay.currentStep.title || "") : ""
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(15)
                    font.weight: Font.Bold
                    wrapMode: Text.WordWrap
                }

                Text {
                    text: (overlay.index + 1) + " / " + overlay.stepCount
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    font.weight: Font.DemiBold
                }
            }

            Text {
                Layout.fillWidth: true
                text: overlay._bodyText
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                lineHeight: 1.3
                wrapMode: Text.WordWrap
            }

            RowLayout {   // perf-lint: disable=R5  (bounded 440dp callout, ≤4 buttons ever visible at once)
                Layout.fillWidth: true
                Layout.topMargin: VfTheme.dp(2)
                spacing: VfTheme.dp(8)

                VfButton {
                    text: (void i18n.revision, i18n.t("qml.tour.skip", "Bỏ qua"))
                    onClicked: overlay.skip()
                }

                VfButton {
                    visible: overlay.autoPlay
                    text: overlay.autoPaused
                        ? (void i18n.revision, i18n.t("qml.tour.resume", "Tiếp tục"))
                        : (void i18n.revision, i18n.t("qml.tour.pause", "Tạm dừng"))
                    onClicked: overlay.toggleAutoPause()
                }

                Item { Layout.fillWidth: true }

                VfButton {
                    tone: "accent"
                    text: (void i18n.revision, i18n.t("qml.tour.open_dialog", "Mở thử"))
                    visible: overlay.currentStep && String(overlay.currentStep.dialog || "").length > 0
                    onClicked: {
                        if (overlay.currentStep)
                            overlay.openDialogRequested(String(overlay.currentStep.dialog || ""))
                    }
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("qml.tour.back", "Quay lại"))
                    enabled: overlay.index > 0
                    onClicked: overlay.prev()
                }

                VfButton {
                    tone: "primary"
                    text: overlay.index >= overlay.stepCount - 1
                        ? (void i18n.revision, i18n.t("qml.tour.done", "Hoàn tất"))
                        : (void i18n.revision, i18n.t("qml.tour.next", "Tiếp"))
                    onClicked: overlay.next()
                }
            }
        }
    }
}
