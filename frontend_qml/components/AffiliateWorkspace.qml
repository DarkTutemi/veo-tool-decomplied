import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"
import "MediaSourceResolver.js" as MediaSourceResolver

// Affiliate Studio — rolling-pool cockpit:
//   TOP BAR  : cấu hình chung của toàn pool
//   TRÁI  ①  : KHO SP dọc (master) — import/bulk, trạng thái chuẩn hoá, click chọn SP
//   GIỮA  ②  : HỒ SƠ BÁN HÀNG per-SP — nhận diện + checklist + biến thể của SP đang chọn
//   PHẢI  ③  : NHÂN VẬT + BỐI CẢNH dùng cho lượt chuẩn bị hiện tại
//   FOOTER   : BỂ HÀNG CHỜ dùng queueModel bền vững, chạy cuốn chiếu từng video.
// Public API (props in / signals out) GIỮ NGUYÊN → wiring WorkPanelWorkspace không đổi.
ColumnLayout {
    id: root
    objectName: "affiliateWorkspace"

    property var cards: []
    property var routeConfig: ({})
    property var stats: ({})
    property var queueRows: []

    signal actionRequested(string actionId, var payload)
    signal submitAllRequested()
    signal clearQueueRequested()
    signal clearCompletedRequested()
    signal startQueueRequested()
    signal pauseQueueRequested()
    signal routeToolRequested(string action)

    property bool affiliateGenerating: false
    readonly property bool poolOrchestrating:
        Boolean((root.routeConfig || {})._pool_orchestrating)
    readonly property bool pipelineBusy:
        root.affiliateGenerating || root.poolOrchestrating
    readonly property int maxVariantsPerProduct:
        (typeof workPanelController !== "undefined" && workPanelController)
            ? Number(workPanelController.affiliateMaxVariants()) : 5

    spacing: VfTheme.dp(8)

    // ── Helpers dữ liệu (giữ nguyên contract cũ) ─────────────────────────────
    readonly property var _products: {
        var src = root.cards || [], out = []
        for (var i = 0; i < src.length; i++) {
            var c = src[i] || ({})
            if (String(c.product_id || "").length === 0) continue
            out.push(c)
        }
        return out
    }
    function productCount() { return (root._products || []).length }
    // SP nhập từ sàn (có link gốc) → mới sinh được link tiếp thị.
    function productsWithUrl() {
        // Chỉ đếm SP SHOPEE — TikTok showcase không cần sinh link (SP đã gắn sẵn),
        // đếm cả nó thì nút 🔗 hiện rồi bấm vô nghĩa (bug log 23/7).
        var ps = root._products || [], n = 0
        for (var i = 0; i < ps.length; i++) {
            var u = String((ps[i].product || {}).product_url || "")
            if (u.length > 0 && u.indexOf("shopee") >= 0) n++
        }
        return n
    }
    function campaignPlan() { var v = (root.routeConfig || {}).campaign_plan; return (v && typeof v === "object") ? v : ({}) }
    function planFor(pid) { var p = root.campaignPlan()[String(pid)]; return (p && p.length !== undefined) ? p : [] }
    function pidOf(card) { return String((card || {}).product_id || ((card || {}).product || {}).product_id || "") }
    function campaignStatus() { return String((root.routeConfig || {})._campaign_status || "") }
    function campaignTotalVideos() {
        var t = 0, ps = root._products || []
        for (var i = 0; i < ps.length; i++) t += root.planFor(root.pidOf(ps[i])).length
        return t
    }
    function prodImage(pd) {
        var p = pd || ({})
        return MediaSourceResolver.imageSource({
            thumbnail_base64: p.thumbnail_base64 || p.image_base64 || p.thumbnail_data || "",
            thumbnail_url: (String(p.thumbnail_url || "").indexOf("http") === 0 ? p.thumbnail_url : "")
        })
    }
    // Lightbox xem nhanh ảnh SP (popup nội bộ — không mở trình ảnh hệ thống).
    property var _previewList: []
    property int _previewIdx: 0
    function openImagePreview(list, idx) {
        root._previewList = list || []
        root._previewIdx = Math.max(0, Math.min((list || []).length - 1, idx || 0))
        if (root._previewList.length > 0) imgPreviewPopup.open()
    }
    function setOpt(key, val) {
        if (workPanelController.affiliateUiPreview) return
        workPanelController.setRouteOption("affiliate", key, val)
    }
    function openAffiliateSubtitleStudio() {
        var context = root.routeConfig || ({})
        var product = root.brainProduct() || ({})
        subtitleStudioController.openForRoute(
            "affiliate",
            context.subtitle_profile || ({}),
            {
                market: String(context.market || "vietnam"),
                content_language: String(
                    context.voice_language || context.language || "vi"),
                aspect_ratio: String(context.aspect_ratio || "9:16"),
                title: String(product.name || "Affiliate"),
                idea: String(
                    context.brief_offer || context.brief_problem
                    || product.description || product.name || ""),
                script: String(
                    context.script || context.script_text || context.narration
                    || context.voiceover || product.script || ""),
                tone: String(context.brief_tone || context.tone || ""),
                platform: String(context.platform || "affiliate"),
                content_tags: context.content_tags || [],
                inherited: true
            })
    }
    function requestAction(actionId, payload) {
        var data = { action_id: actionId, route: "affiliate" }
        var p = payload || ({})
        for (var key in p) data[key] = p[key]
        root.actionRequested(actionId, data)
        return data
    }
    function requestRouteTool(action) {
        root.requestAction("work_panel." + action, { source: "route_tool", route_tool: action })
        root.routeToolRequested(action)
    }
    function scopeOf(assetType) {
        var c = root.routeConfig || {}
        var k = assetType === "character" ? "character_scope" : "background_scope"
        return String(c[k] || c.asset_mode || "global")
    }
    function autoOf(assetType) {
        var c = root.routeConfig || {}
        return Boolean(assetType === "character" ? c.character_auto : c.background_auto)
    }
    function activePidOf(assetType) {
        var c = root.routeConfig || {}
        var k = assetType === "character" ? "_active_product_id_character" : "_active_product_id_background"
        var p = String(c[k] || c._active_product_id || "")
        if (p.length > 0) return p
        var ps = root._products || []
        return ps.length > 0 ? root.pidOf(ps[0]) : ""
    }
    function assetsOf(key) {
        var assetType = key === "character_slots" ? "character" : "background"
        if (root.scopeOf(assetType) === "per_product") {
            var pa = ((root.routeConfig || {}).product_assets || {})[root.activePidOf(assetType)] || {}
            var pv = pa[key]
            return (pv && pv.length !== undefined) ? pv : []
        }
        var v = (root.routeConfig || {})[key]; return (v && v.length !== undefined) ? v : []
    }
    readonly property string currentModelKey: String((root.routeConfig || {}).video_model_key || "")
    readonly property var modelBudget: (typeof workPanelController !== "undefined" && workPanelController)
        ? (workPanelController.affiliateModelBudget(root.currentModelKey) || ({})) : ({})
    function productOptions() {
        var ps = root._products || [], out = []
        for (var i = 0; i < ps.length; i++)
            out.push({ label: String((ps[i].product || {}).name || ("SP " + (i + 1))), value: root.pidOf(ps[i]) })
        return out
    }

    // ── Hồ sơ bán hàng: SP đang soi + sales kit ─────────────────────────────────────
    property string _brainPid: ""
    function brainPid() {
        if (root._brainPid.length > 0) {
            var ps = root._products || []
            for (var i = 0; i < ps.length; i++)
                if (root.pidOf(ps[i]) === root._brainPid) return root._brainPid
        }
        var first = (root._products || [])[0]
        return first ? root.pidOf(first) : ""
    }
    function brainProduct() {
        var pid = root.brainPid(), ps = root._products || []
        for (var i = 0; i < ps.length; i++)
            if (root.pidOf(ps[i]) === pid) return (ps[i].product || {})
        return ({})
    }
    function brainCard() {
        var pid = root.brainPid(), ps = root._products || []
        for (var i = 0; i < ps.length; i++)
            if (root.pidOf(ps[i]) === pid) return ps[i] || ({})
        return ({})
    }
    // Import runs Call 1 + identity-sheet preparation. Durable admission is an
    // explicit snapshot gesture after the user has chosen CHAR/BG and settings.
    function brainPrepStatus() {
        var pid = root.brainPid(), ps = root._products || []
        for (var i = 0; i < ps.length; i++)
            if (root.pidOf(ps[i]) === pid)
                return String(ps[i].prep_status || (ps[i].product || {}).prep_status || "")
        return ""
    }
    function readyVariantCount() {
        var pid = root.brainPid()
        var planned = root.planFor(pid)
        if (planned && planned.length > 0) return planned.length
        var prepared = (root.brainProduct() || {}).prep_variants
        return prepared && prepared.length !== undefined ? prepared.length : 0
    }
    function queueReadinessText() {
        var card = root.brainCard(), product = root.brainProduct()
        var pid = root.brainPid()
        if (pid.length === 0) return "Chọn sản phẩm để chốt job"
        if (String(card.campaign_id || "").length > 0)
            return "Sản phẩm này đã được chốt vào hàng chờ"
        var state = String(card.status || "").toLowerCase()
        if (state === "pool preparing") return "Đang khóa snapshot và viết campaign…"
        if (state === "queued" || state === "running" || state === "complete"
                || state === "completed" || state === "done")
            return "Sản phẩm này đã có job trong hàng chờ"
        var prep = root.brainPrepStatus().toLowerCase()
        if (prep === "error") return "Chuẩn bị lỗi · bấm Chuẩn bị lại"
        if (prep !== "ready" && prep !== "prepared")
            return "Đang lấy thông tin và chuẩn hóa ảnh sản phẩm…"
        var wantedAspect = String((root.routeConfig || {}).aspect_ratio || "9:16")
        var preparedAspect = String(product.prep_aspect_ratio || "")
        if (preparedAspect.length > 0 && preparedAspect !== wantedAspect)
            return "Tỷ lệ đã đổi sang " + wantedAspect + " · cần Chuẩn bị lại"
        var sheets = product.prep_sheets || ({})
        if (String(sheets.SHEET_IDENTITY || "").length === 0)
            return "Chưa có sheet sản phẩm hoàn chỉnh · cần Chuẩn bị lại"
        var variants = root.readyVariantCount()
        if (variants <= 0) return "Chưa có phương án biến thể để chốt"
        return "Sẵn sàng · bấm để khóa " + variants
                + " biến thể cùng cấu hình và tài nguyên hiện tại"
    }
    function canQueueCurrentProduct() {
        var card = root.brainCard(), product = root.brainProduct()
        var prep = root.brainPrepStatus().toLowerCase()
        var state = String(card.status || "").toLowerCase()
        var wantedAspect = String((root.routeConfig || {}).aspect_ratio || "9:16")
        var preparedAspect = String(product.prep_aspect_ratio || "")
        var sheets = product.prep_sheets || ({})
        return root.brainPid().length > 0
                && card.selected !== false
                && String(card.campaign_id || "").length === 0
                && (prep === "ready" || prep === "prepared")
                && state !== "pool preparing"
                && state !== "queued" && state !== "running"
                && state !== "complete" && state !== "completed" && state !== "done"
                && (preparedAspect.length === 0 || preparedAspect === wantedAspect)
                && String(sheets.SHEET_IDENTITY || "").length > 0
                && root.readyVariantCount() > 0
    }
    property var _kit: ({})
    property string _kitPid: ""      // pid của _kit đang giữ — chống fetch lại thừa
    // Bố 23/7: click SP 1↔2 lag — affiliateSalesKit chạy ĐỒNG BỘ trên GUI thread mỗi
    // lần _brainPid đổi VÀ mỗi onCardsChanged (storm khi prep/queue cập nhật). Debounce
    // gộp nhịp + bỏ qua khi pid không đổi (Law 1: không nặng đồng bộ trên GUI thread).
    Timer {
        id: kitDebounce
        interval: 90; repeat: false
        onTriggered: root._doRefreshKit()
    }
    function _doRefreshKit() {
        var pid = root.brainPid()
        if (pid === root._kitPid) return          // đã có kit đúng SP → khỏi gọi lại
        root._kitPid = pid
        root._kit = (pid.length > 0 && typeof workPanelController !== "undefined" && workPanelController)
            ? (workPanelController.affiliateSalesKit(pid) || ({})) : ({})
    }
    function refreshKit() { kitDebounce.restart() }
    // cardsChanged có thể mang data prep mới CHO SP ĐANG SOI → ép fetch lại (bỏ guard).
    onCardsChanged: { root._kitPid = ""; kitDebounce.restart() }
    on_BrainPidChanged: root.refreshKit()
    Component.onCompleted: root._doRefreshKit()
    function joinList(v) {
        if (v && v.length !== undefined && typeof v !== "string") {
            var out = []
            for (var i = 0; i < v.length; i++) out.push(String(v[i]))
            return out.join("; ")
        }
        return String(v || "")
    }
    function setProductField(key, value) {
        var pid = root.brainPid()
        if (pid.length === 0) return
        root.requestAction("work_panel.affiliate_product_set", { product_id: pid, key: key, value: value })
        root.refreshKit()
    }

    // Compact, read-only status projection for the workspace. These helpers only
    // consume the controller snapshots already present in memory; they must never
    // trigger preparation work or backend reads from a QML binding.
    function cardStatusLabel(card) {
        var item = card || ({})
        var product = item.product || ({})
        var state = String(item.status || "").toLowerCase()
        var prep = String(item.prep_status || product.prep_status || "").toLowerCase()
        if (state.indexOf("fail") >= 0 || state.indexOf("error") >= 0
                || prep === "error")
            return "LỖI"
        if (state === "complete" || state === "completed" || state === "done")
            return "HOÀN TẤT"
        if (state === "running") return "ĐANG CHẠY"
        if (state === "queued") return "ĐÃ XẾP"
        if (state === "pool preparing" || String(item.campaign_id || "").length > 0)
            return "ĐANG CHỐT"
        if (prep === "importing_media") return "NHẬP ẢNH"
        if (prep === "analyzing") return "PHÂN TÍCH"
        if (prep === "prepared") return "ĐÃ PHÂN TÍCH"
        if (prep === "normalizing" || prep === "sheets") return "LÀM SHEET"
        if (prep === "ready") return "SẴN SÀNG"
        return "CHỜ"
    }
    function cardStatusTone(card) {
        var label = root.cardStatusLabel(card)
        if (label === "LỖI") return "error"
        if (label === "HOÀN TẤT" || label === "SẴN SÀNG"
                || label === "ĐÃ PHÂN TÍCH")
            return "success"
        if (label === "ĐANG CHẠY" || label === "ĐÃ XẾP") return "info"
        if (label === "ĐANG CHỐT" || label === "NHẬP ẢNH"
                || label === "PHÂN TÍCH" || label === "LÀM SHEET")
            return "working"
        return "neutral"
    }
    function identityBadgeLabel() {
        var prep = root.brainPrepStatus().toLowerCase()
        if (prep === "error") return "LỖI"
        if (prep === "importing_media" || prep === "analyzing")
            return "ĐANG PHÂN TÍCH"
        if (prep === "prepared" || prep === "normalizing"
                || prep === "sheets" || prep === "ready")
            return "ĐÃ NHẬN DIỆN"
        return "CHỜ DỮ LIỆU"
    }
    function identityBadgeTone() {
        var prep = root.brainPrepStatus().toLowerCase()
        if (prep === "error") return "error"
        if (prep === "importing_media" || prep === "analyzing") return "working"
        if (prep === "prepared" || prep === "normalizing"
                || prep === "sheets" || prep === "ready")
            return "success"
        return "neutral"
    }
    function kitItems() {
        var items = (root._kit || {}).items
        return items && items.length !== undefined ? items : []
    }
    function kitReadyCount() {
        var items = root.kitItems(), ready = 0
        for (var i = 0; i < items.length; i++) {
            var state = String((items[i] || {}).state || "").toLowerCase()
            if (state === "ok" || state === "auto") ready++
        }
        return ready
    }
    function kitBadgeLabel() {
        var total = root.kitItems().length
        if (total <= 0) {
            var prep = root.brainPrepStatus().toLowerCase()
            return prep === "analyzing" || prep === "importing_media"
                    ? "ĐANG TÍNH" : "CHƯA CÓ"
        }
        var ready = root.kitReadyCount()
        return ready >= total ? "ĐỦ " + ready + "/" + total
                              : "THIẾU " + (total - ready)
    }
    function kitBadgeTone() {
        var total = root.kitItems().length
        if (total <= 0) return root.brainPrepStatus().toLowerCase() === "analyzing"
                ? "working" : "neutral"
        return root.kitReadyCount() >= total ? "success" : "working"
    }
    function variantBadgeLabel() {
        var count = root.readyVariantCount()
        return count > 0 ? count + " SẴN SÀNG" : "CHƯA CÓ"
    }
    function productAnalysisReady() {
        var prep = root.brainPrepStatus().toLowerCase()
        return prep === "prepared" || prep === "normalizing"
                || prep === "sheets" || prep === "ready"
    }
    function productSheetReady() {
        var sheets = (root.brainProduct() || {}).prep_sheets || ({})
        return String(sheets.SHEET_IDENTITY || "").length > 0
    }
    function assetStatusLabel(assetType, key) {
        if (root.autoOf(assetType)) return "AUTO KHI CHẠY"
        var selected = root.assetsOf(key).length
        return selected > 0 ? "ĐÃ KHÓA " + selected : "CHƯA CHỌN"
    }
    function assetStatusTone(assetType, key) {
        if (root.autoOf(assetType)) return "auto"
        return root.assetsOf(key).length > 0 ? "ready" : "warning"
    }

    // Narrator toggle + giọng/cảm xúc giờ sống ở AffiliateConfigPanel (hàng 2).

    readonly property var _videoTypes: [
        { value: "problem_solution", label: (void i18n.revision, i18n.t("affiliate.vt_problem_solution", "Nỗi đau→Giải")) },
        { value: "before_after",     label: (void i18n.revision, i18n.t("affiliate.vt_before_after", "Trước/Sau")) },
        { value: "unboxing",         label: (void i18n.revision, i18n.t("affiliate.vt_unboxing", "Đập hộp")) },
        { value: "demo_review",      label: (void i18n.revision, i18n.t("affiliate.vt_demo_review", "Demo/Review")) },
        { value: "testimonial",      label: (void i18n.revision, i18n.t("affiliate.vt_testimonial", "Chứng thực")) },
        { value: "listicle",         label: (void i18n.revision, i18n.t("affiliate.vt_listicle", "Top N")) },
        { value: "comparison",       label: (void i18n.revision, i18n.t("affiliate.vt_comparison", "So sánh")) }
    ]

    component PrepStatusBadge: Rectangle {
        id: prepBadge
        property string label: ""
        property string tone: "neutral"
        readonly property color toneFill:
            tone === "success" ? VfTheme.greenFill
          : tone === "error" ? VfTheme.redFill
          : tone === "working" ? VfTheme.amberFill
          : tone === "info" ? VfTheme.cyanFill
          : tone === "violet" ? VfTheme.violetFill
          : VfTheme.surfaceSoft
        readonly property color toneBorder:
            tone === "success" ? VfTheme.greenBorder
          : tone === "error" ? VfTheme.redBorder
          : tone === "working" ? VfTheme.amberBorder
          : tone === "info" ? VfTheme.cyanBorder
          : tone === "violet" ? VfTheme.violetBorder
          : VfTheme.borderSoft
        readonly property color toneText:
            tone === "success" ? VfTheme.greenText
          : tone === "error" ? VfTheme.redText
          : tone === "working" ? VfTheme.amberText
          : tone === "info" ? VfTheme.cyanText
          : tone === "violet" ? VfTheme.violetText
          : VfTheme.textMuted
        visible: label.length > 0
        implicitWidth: prepBadgeText.implicitWidth + VfTheme.dp(8)
        implicitHeight: VfTheme.dp(17)
        radius: height / 2
        color: toneFill
        // Fill + text carry normal status; reserve an outline for actual errors.
        border.width: tone === "error" ? 1 : 0
        border.color: Qt.alpha(toneBorder, 0.82)
        Text {
            id: prepBadgeText
            anchors.centerIn: parent
            text: prepBadge.label
            color: prepBadge.toneText
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(8)
            font.weight: VfTheme.weightStrong
        }
    }
    function videoTypesFor(row) {
        var item = row || ({})
        var current = String(item.video_type || "adaptive")
        var adaptiveLabel = String(
            item.format_name || item.video_type_label ||
            (void i18n.revision, i18n.t("affiliate.vt_adaptive", "AI theo sản phẩm"))
        )
        var out = [{ value: "adaptive", label: adaptiveLabel }]
        var currentFound = current === "adaptive"
        for (var i = 0; i < root._videoTypes.length; i++) {
            var option = root._videoTypes[i]
            out.push(option)
            if (String(option.value) === current)
                currentFound = true
        }
        if (!currentFound) {
            out.unshift({
                value: current,
                label: String(item.format_name || item.video_type_label || current)
            })
        }
        return out
    }
    // Ô form chuẩn khu Hồ sơ bán hàng: label nhỏ TRÊN + field CÓ VIỀN (hết chữ trôi lơ lửng).
    component BrainField: ColumnLayout {
        id: bf
        property string label: ""
        property string value: ""
        property string ph: ""
        signal committed(string val)
        spacing: VfTheme.dp(2)
        Text {
            text: bf.label
            color: VfTheme.textMuted; font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong
        }
        TextField {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(30)
            text: bf.value
            placeholderText: bf.ph
            color: VfTheme.text; placeholderTextColor: VfTheme.textSubtle; selectByMouse: true
            autoScroll: activeFocus
            font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; leftPadding: VfTheme.dp(8)
            background: Rectangle {
                radius: VfTheme.radiusControl; color: VfTheme.surface
                border.color: VfTheme.borderBox; border.width: 1
            }
            onActiveFocusChanged: {
                if (!activeFocus) {
                    deselect()
                    cursorPosition = 0
                }
            }
            Component.onCompleted: cursorPosition = 0
            onEditingFinished: {
                bf.committed(text)
                cursorPosition = 0
            }
        }
    }

    readonly property var _categories: [
        { value: "cosmetics",   label: "Mỹ phẩm" },
        { value: "beauty",      label: "Làm đẹp" },
        { value: "fashion",     label: "Thời trang" },
        { value: "electronics", label: "Điện tử" },
        { value: "home",        label: "Gia dụng" },
        { value: "food",        label: "Thực phẩm" },
        { value: "health",      label: "Sức khỏe" },
        { value: "sports",      label: "Thể thao" },
        { value: "baby",        label: "Mẹ & Bé" },
        { value: "other",       label: "Khác" }
    ]

    // ══════════ MASTER CONFIG — MỘT hàng 8 field full-width (bố chốt V3 22/7:
    // block CHẠY rời khỏi hàng đỉnh, xuống THANH HÀNH ĐỘNG dưới 3 cột → config
    // nhẹ, đủ chỗ 8 field 1 hàng trên màn bố).
    AffiliateConfigPanel {
        Layout.fillWidth: true
    }

    AffiliateFeatureActions {
        Layout.fillWidth: true
        config: root.routeConfig || ({})
        onOptionRequested: (key, value) => root.setOpt(key, value)
        onSubtitleStudioRequested: root.openAffiliateSubtitleStudio()
    }

    // ══════════ 3 CỘT ══════════
    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        // Sàn an toàn: hàng đỉnh có lỗi layout cỡ nào cũng không được ép 3 cột về 0.
        Layout.minimumHeight: VfTheme.dp(300)
        spacing: VfTheme.dp(8)

        // ── TRÁI ①: KHO SP (master) — mở rộng: mỗi hàng 1 SP kèm strip ảnh ───
        AffiliateSection {
            objectName: "affiliateProductLibrary"
            Layout.preferredWidth: VfTheme.dp(344)
            Layout.minimumWidth: VfTheme.dp(300)
            Layout.fillHeight: true
            accent: VfTheme.primary
            accentFill: VfTheme.blueFill
            badgeText: "①"
            title: (void i18n.revision, i18n.t("affiliate.products_short", "KHO SP")) +
                   (root.productCount() > 0 ? " · " + root.productCount() : "")
            hint: (void i18n.revision, i18n.t("affiliate.hint_products",
                  "NHIỆM VỤ: nhập sản phẩm cần bán — MỘT cửa Import duy nhất: ảnh rời (mỗi ảnh = 1 SP) hoặc folder cha (mỗi thư mục con = 1 SP, nhóm ảnh cùng SP vào 1 thư mục để không lẫn; tối đa 10 ảnh/SP). Nhập được GIÁ ngay lúc import. Hệ thống tự chuẩn hoá: tách nền → gộp sheet sạch → AI điền thông tin. Click SP để soi ở cột giữa."))
            // Nút Import NGANG HÀNG tiêu đề KHO SP (bố 23/7) — body chỉ còn list SP.
            // Nút "Thư viện" ĐÃ BỎ (23/7: thừa — KHO SP ngay đây là thư viện rồi).
            headerActions: [
                NormalToolbarButton {
                    actionId: "affiliate.product.import"
                    compact: true
                    text: "＋ " + (void i18n.revision, i18n.t("affiliate.import_sp", "Import SP"))
                    selected: true
                    onClicked: root.requestRouteTool("product_builder")
                }
            ]

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(8)
                anchors.topMargin: VfTheme.dp(44)
                spacing: VfTheme.dp(6)

                Flow {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(5)
                    // Link tiếp thị: 1 call batch cho mọi SP nhập từ sàn (có link gốc).
                    NormalToolbarButton {
                        visible: root.productsWithUrl() > 0
                        text: "🔗 " + (void i18n.revision, i18n.t("affiliate.get_links", "Lấy link tiếp thị"))
                        tooltip: (void i18n.revision, i18n.t("affiliate.get_links_tip",
                                 "Đổi link sản phẩm → link hoa hồng (1 lần cho tất cả SP). Cần đăng nhập Shopee trong cửa sổ lướt chọn."))
                        onClicked: workPanelController.fetchAffiliateLinks(false)
                    }
                }
                Text {
                    Layout.fillWidth: true
                    visible: (typeof workPanelController !== "undefined" && workPanelController) ? workPanelController.affiliateImageBusy : false
                    text: "⏳ " + (void i18n.revision, i18n.t("affiliate.normalizing", "Đang chuẩn hoá…"))
                    color: VfTheme.amberText; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall
                }

                ListView {
                    id: spList
                    objectName: "affiliateProductList"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    reuseItems: true
                    spacing: VfTheme.dp(5)
                    model: root._products
                    // Empty: khu thả gợi ý ngay tại chỗ.
                    Rectangle {
                        anchors.fill: parent
                        visible: spList.count === 0
                        radius: VfTheme.dp(8)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.borderSoft
                        border.width: 1
                        Column {
                            anchors.centerIn: parent
                            width: parent.width - VfTheme.dp(20)
                            spacing: VfTheme.dp(6)
                            VfAppIcon { anchors.horizontalCenter: parent.horizontalCenter; name: "package"; size: VfTheme.dp(26); framed: false; color: VfTheme.primary }
                            Text {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                text: (void i18n.revision, i18n.t("affiliate.products_empty_hint", "Thêm ảnh SP — hệ thống tách nền, gộp sheet sạch + AI điền thông tin"))
                                color: VfTheme.textSubtle; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                    delegate: Rectangle {
                        id: spRow
                        width: ListView.view.width
                        height: VfTheme.dp(114)
                        radius: VfTheme.dp(7)
                        color: VfTheme.surfaceSoft
                        border.color: root.brainPid() === root.pidOf(modelData) ? VfTheme.primary : VfTheme.border
                        border.width: root.brainPid() === root.pidOf(modelData) ? 2 : 1
                        // Ảnh preview của SP (main + extras, backend resolve sẵn cap 10);
                        // SP import trước khi có image_previews → fallback 1 thumb chính.
                        readonly property var previews: {
                            var p = (modelData || {}).product || {}
                            var arr = p.image_previews || []
                            if (arr.length > 0) return arr
                            if (root.prodImage(p) !== "")
                                return [{ thumbnail_base64: p.thumbnail_base64 || p.image_base64 || "",
                                          thumbnail_url: p.thumbnail_url || "" }]
                            return []
                        }
                        // Ref RIÊNG SP NÀY (bố chốt V3 22/7) — card.col override global.
                        readonly property string columnId: String((modelData || {}).id || "")
                        readonly property var ovrChar: {
                            var v = ((modelData || {}).col || {}).character_slots
                            return (v && v.length !== undefined) ? v : []
                        }
                        readonly property var ovrBg: {
                            var v = ((modelData || {}).col || {}).background_slots
                            return (v && v.length !== undefined) ? v : []
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root._brainPid = root.pidOf(modelData)
                                root.requestAction(
                                    "work_panel.affiliate_focus_product",
                                    { product_id: root.pidOf(modelData) }
                                )
                            }
                        }
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(7)
                            spacing: VfTheme.dp(5)
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(6)
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(((modelData || {}).product || {}).name || ((modelData || {}).title) || "SP")
                                        color: VfTheme.text; font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall; font.weight: VfTheme.weightStrong
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: {
                                            var p = (modelData || {}).product || {}
                                            var bits = []
                                            if (String(p.price || "").length > 0) bits.push(String(p.price))
                                            var n = root.planFor(root.pidOf(modelData)).length
                                            if (n > 0) bits.push("🎬" + n)
                                            bits.push(spRow.previews.length > 0 ? (spRow.previews.length + " ảnh") : "⚠ ảnh")
                                            if (String(p.affiliate_link || "").length > 0) bits.push("🔗 có link")
                                            return bits.join(" · ")
                                        }
                                        color: VfTheme.textSubtle; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny
                                        elide: Text.ElideRight
                                    }
                                }
                                PrepStatusBadge {
                                    label: root.cardStatusLabel(modelData)
                                    tone: root.cardStatusTone(modelData)
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                NormalToolbarButton {
                                    text: "✕"; minWidth: VfTheme.dp(26)
                                    onClicked: root.requestAction("work_panel.affiliate_column_remove", { column_id: String((modelData || {}).id || "") })
                                }
                            }
                            // Strip ảnh scroll ngang — click 1 ảnh xem nhanh (popup nội bộ).
                            ListView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(34)
                                orientation: ListView.Horizontal
                                clip: true
                                reuseItems: true
                                spacing: VfTheme.dp(4)
                                model: spRow.previews
                                delegate: Rectangle {
                                    width: VfTheme.dp(34); height: VfTheme.dp(34)
                                    radius: VfTheme.dp(5)
                                    color: VfTheme.surface
                                    border.color: VfTheme.borderSoft; border.width: 1
                                    clip: true
                                    Image {
                                        anchors.fill: parent
                                        source: MediaSourceResolver.imageSource({
                                            thumbnail_base64: (modelData || {}).thumbnail_base64 || "",
                                            thumbnail_url: (modelData || {}).thumbnail_url || "" })
                                        fillMode: Image.PreserveAspectCrop; asynchronous: true
                                        sourceSize.width: 96; sourceSize.height: 96
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.openImagePreview(spRow.previews, index)
                                    }
                                }
                            }
                            // RIÊNG SP NÀY: ref KOL/bối cảnh override global cho riêng SP
                            // (trống = theo khu global dưới / Auto AI). Click thumb = gỡ.
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(3)
                                Text {
                                    text: "👤"
                                    font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(11)
                                }
                                Repeater {
                                    model: spRow.ovrChar
                                    Rectangle {
                                        width: VfTheme.dp(22); height: VfTheme.dp(22)
                                        radius: VfTheme.dp(4)
                                        color: VfTheme.surface
                                        border.color: VfTheme.violet; border.width: 1
                                        clip: true
                                        Image {
                                            anchors.fill: parent
                                            source: MediaSourceResolver.imageSource(modelData || ({}))
                                            fillMode: Image.PreserveAspectCrop; asynchronous: true
                                            sourceSize.width: 64; sourceSize.height: 64
                                        }
                                        MouseArea {
                                            id: ovrCharMouse
                                            anchors.fill: parent; hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.requestAction("work_panel.affiliate_character", {
                                                mode: "remove",
                                                asset_id: String((modelData || {}).id || (modelData || {}).media_id || ""),
                                                column_id: spRow.columnId,
                                                source: "affiliate_sp_override_remove" })
                                        }
                                        ToolTip.visible: ovrCharMouse.containsMouse
                                        ToolTip.text: (void i18n.revision, i18n.t("affiliate.ovr_remove_tip", "✕ Gỡ ref riêng SP này"))
                                        ToolTip.delay: 300
                                    }
                                }
                                Rectangle {
                                    width: VfTheme.dp(22); height: VfTheme.dp(22)
                                    radius: VfTheme.dp(4)
                                    color: "transparent"
                                    border.color: VfTheme.primary; border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "＋"; color: VfTheme.primary
                                        font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(11); font.weight: Font.Bold
                                    }
                                    MouseArea {
                                        id: ovrCharAdd
                                        anchors.fill: parent; hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.requestAction("work_panel.affiliate_character", {
                                            mode: "choose", column_id: spRow.columnId,
                                            source: "affiliate_sp_override_choose" })
                                    }
                                    ToolTip.visible: ovrCharAdd.containsMouse
                                    ToolTip.text: (void i18n.revision, i18n.t("affiliate.ovr_char_tip", "Gắn KOL RIÊNG cho SP này — override khu NHÂN VẬT chung"))
                                    ToolTip.delay: 300
                                }
                                Rectangle { width: 1; Layout.preferredHeight: VfTheme.dp(14); color: VfTheme.borderSoft }
                                Text {
                                    text: "🏞"
                                    font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(11)
                                }
                                Repeater {
                                    model: spRow.ovrBg
                                    Rectangle {
                                        width: VfTheme.dp(22); height: VfTheme.dp(22)
                                        radius: VfTheme.dp(4)
                                        color: VfTheme.surface
                                        border.color: VfTheme.cyan; border.width: 1
                                        clip: true
                                        Image {
                                            anchors.fill: parent
                                            source: MediaSourceResolver.imageSource(modelData || ({}))
                                            fillMode: Image.PreserveAspectCrop; asynchronous: true
                                            sourceSize.width: 64; sourceSize.height: 64
                                        }
                                        MouseArea {
                                            id: ovrBgMouse
                                            anchors.fill: parent; hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.requestAction("work_panel.affiliate_background", {
                                                mode: "remove",
                                                asset_id: String((modelData || {}).id || (modelData || {}).media_id || ""),
                                                column_id: spRow.columnId,
                                                source: "affiliate_sp_override_remove" })
                                        }
                                        ToolTip.visible: ovrBgMouse.containsMouse
                                        ToolTip.text: (void i18n.revision, i18n.t("affiliate.ovr_remove_tip", "✕ Gỡ ref riêng SP này"))
                                        ToolTip.delay: 300
                                    }
                                }
                                Rectangle {
                                    width: VfTheme.dp(22); height: VfTheme.dp(22)
                                    radius: VfTheme.dp(4)
                                    color: "transparent"
                                    border.color: VfTheme.cyan; border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "＋"; color: VfTheme.cyan
                                        font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(11); font.weight: Font.Bold
                                    }
                                    MouseArea {
                                        id: ovrBgAdd
                                        anchors.fill: parent; hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.requestAction("work_panel.affiliate_background", {
                                            mode: "choose", column_id: spRow.columnId,
                                            source: "affiliate_sp_override_choose" })
                                    }
                                    ToolTip.visible: ovrBgAdd.containsMouse
                                    ToolTip.text: (void i18n.revision, i18n.t("affiliate.ovr_bg_tip", "Gắn bối cảnh RIÊNG cho SP này — override khu BỐI CẢNH chung"))
                                    ToolTip.delay: 300
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    visible: spRow.ovrChar.length > 0 || spRow.ovrBg.length > 0
                                    text: (void i18n.revision, i18n.t("affiliate.ovr_badge", "riêng SP"))
                                    color: VfTheme.amberText
                                    font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(9); font.weight: VfTheme.weightStrong
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── GIỮA ②: HỒ SƠ BÁN HÀNG per-SP (detail) ──────────────────────────
        AffiliateSection {
            objectName: "affiliateSalesProfile"
            Layout.fillWidth: true
            Layout.fillHeight: true
            accent: VfTheme.violet
            accentFill: VfTheme.violetFill
            badgeText: "②"
            title: (void i18n.revision, i18n.t("affiliate.brain_short", "HỒ SƠ BÁN HÀNG")) +
                   (root.productCount() > 0 ? " — " + String(root.brainProduct().name || "") : "")
            hint: (void i18n.revision, i18n.t("affiliate.hint_brain",
                  "NHIỆM VỤ: hiểu SP đang chọn để bán đúng cách. Nhận diện AI SỬA ĐƯỢC (kịch bản bám theo); checklist báo còn thiếu gì; bảng biến thể = ma trận A/B test, mỗi dòng 1 video khác nhau đúng 1 trục. Nút ⚡ nhìn ảnh MỌI SP một lượt → đẻ biến thể riêng từng SP."))

            headerActions: [
                // Import tự phân tích; Run mới materialize sheet theo aspect/model
                // snapshot. Header phản ánh đúng hai pha, không gọi cả hai là ready.
                Text {
                    text: {
                        var st = root.brainPrepStatus()
                        if (st === "analyzing") return "🧠 " + (void i18n.revision, i18n.t("affiliate.prep_analyzing", "Đang phân tích SP…"))
                        if (st === "prepared") return "✓ " + (void i18n.revision, i18n.t("affiliate.prep_prepared", "Đã phân tích · chuẩn hoá khi Chạy"))
                        if (st === "normalizing" || st === "sheets") return "🖼 " + (void i18n.revision, i18n.t("affiliate.prep_sheets", "Đang chuẩn hoá ảnh…"))
                        if (st === "error") return "⚠ " + (void i18n.revision, i18n.t("affiliate.prep_error", "Chuẩn bị lỗi — bấm ↻"))
                        if (st === "ready") return "✅ " + (void i18n.revision, i18n.t("affiliate.prep_ready", "Tài nguyên sẵn sàng"))
                        return root.productCount() > 0
                            ? "⏳ " + (void i18n.revision, i18n.t("affiliate.prep_waiting", "Chờ chuẩn bị…")) : ""
                    }
                    color: root.brainPrepStatus() === "error" ? VfTheme.redText
                         : (root.brainPrepStatus() === "ready" ? VfTheme.greenText : VfTheme.violetText)
                    font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                    width: Math.min(implicitWidth, VfTheme.dp(240))
                    height: VfTheme.dp(26); verticalAlignment: Text.AlignVCenter
                    // Đang phân tích/chuẩn hoá → chữ THỞ cho thấy còn chạy (bố 23/7).
                    SequentialAnimation on opacity {
                        running: (root.brainPrepStatus() === "analyzing"
                                  || root.brainPrepStatus() === "normalizing"
                                  || root.brainPrepStatus() === "sheets")
                                 && VfTheme.motion
                        loops: Animation.Infinite
                        alwaysRunToEnd: true
                        NumberAnimation { to: 0.4; duration: 620; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 620; easing.type: Easing.InOutQuad }
                    }
                },
                NormalToolbarButton {
                    compact: true
                    text: "↻ " + (void i18n.revision, i18n.t("affiliate.reprep", "Chuẩn bị lại"))
                    enabled: root.productCount() > 0
                             && root.brainPrepStatus() !== "analyzing"
                             && root.brainPrepStatus() !== "normalizing"
                             && root.brainPrepStatus() !== "sheets"
                    onClicked: root.requestAction("work_panel.affiliate_reprep", { product_id: root.brainPid() })
                }
            ]

            // Empty
            Column {
                anchors.centerIn: parent
                visible: root.productCount() === 0
                spacing: VfTheme.dp(6)
                width: parent.width - VfTheme.dp(60)
                VfAppIcon { anchors.horizontalCenter: parent.horizontalCenter; name: "magic-wand"; size: VfTheme.dp(28); framed: false; color: VfTheme.violet }
                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: (void i18n.revision, i18n.t("affiliate.campaign_empty_nosp", "Thêm sản phẩm ở khu ① — hồ sơ bán hàng sẽ nhận diện, đề xuất công thức bán + biến thể test riêng từng SP."))
                    color: VfTheme.textSubtle; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontControl
                    wrapMode: Text.WordWrap
                }
            }

            ColumnLayout {
                id: brainCol
                anchors.fill: parent
                anchors.margins: VfTheme.dp(10)
                anchors.topMargin: VfTheme.dp(44)
                visible: root.productCount() > 0
                spacing: VfTheme.dp(8)

                    // Nhận diện | Checklist — 2 card ÉP BẰNG CHIỀU CAO (hết hở răng cưa).
                    GridLayout {
                        id: brainCards
                        objectName: "affiliateProductAnalysis"
                        Layout.fillWidth: true
                        columns: width >= VfTheme.dp(700) ? 2 : 1
                        columnSpacing: VfTheme.dp(8); rowSpacing: VfTheme.dp(8)
                        readonly property int cardH: Math.max(identCol.implicitHeight, kitCol.implicitHeight) + VfTheme.dp(18)

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: brainCards.columns === 2 ? brainCards.cardH : identCol.implicitHeight + VfTheme.dp(18)
                            radius: VfTheme.dp(8); color: VfTheme.surfaceSoft
                            border.color: VfTheme.border; border.width: 1
                            ColumnLayout {
                                id: identCol
                                anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                                anchors.margins: VfTheme.dp(9)
                                spacing: VfTheme.dp(6)
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: VfTheme.dp(6)
                                    Text {
                                        Layout.fillWidth: true
                                        text: (void i18n.revision, i18n.t("affiliate.brain_identity", "NHẬN DIỆN SẢN PHẨM")) + "  ·  " +
                                              String((root._kit || {}).industry_label || "")
                                        color: VfTheme.violetText; font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong
                                        elide: Text.ElideRight
                                    }
                                    PrepStatusBadge {
                                        label: root.identityBadgeLabel()
                                        tone: root.identityBadgeTone()
                                    }
                                }
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2; columnSpacing: VfTheme.dp(8); rowSpacing: VfTheme.dp(6)
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: VfTheme.dp(2)
                                        Text {
                                            text: (void i18n.revision, i18n.t("affiliate.f_category", "Ngành"))
                                            color: VfTheme.textMuted; font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong
                                        }
                                        NoScrollComboBox {
                                            Layout.fillWidth: true; Layout.preferredHeight: VfTheme.dp(30)
                                            model: root._categories; textRole: "label"; valueRole: "value"
                                            currentIndex: indexOfValue(String(root.brainProduct().category || "other"))
                                            Component.onCompleted: currentIndex = indexOfValue(String(root.brainProduct().category || "other"))
                                            onActivated: idx => root.setProductField("category", String(valueAt(idx)))
                                        }
                                    }
                                    BrainField {
                                        Layout.fillWidth: true
                                        label: (void i18n.revision, i18n.t("affiliate.f_price", "Giá"))
                                        value: String(root.brainProduct().price || "")
                                        ph: "199k…"
                                        onCommitted: val => root.setProductField("price", val)
                                    }
                                    BrainField {
                                        Layout.fillWidth: true
                                        label: (void i18n.revision, i18n.t("affiliate.f_function", "Chức năng"))
                                        value: String(root.brainProduct().function || "")
                                        ph: (void i18n.revision, i18n.t("affiliate.f_function_ph", "SP này LÀM gì"))
                                        onCommitted: val => root.setProductField("function", val)
                                    }
                                    BrainField {
                                        Layout.fillWidth: true
                                        label: (void i18n.revision, i18n.t("affiliate.f_uses", "Công dụng"))
                                        value: root.joinList(root.brainProduct().uses)
                                        ph: (void i18n.revision, i18n.t("affiliate.f_uses_ph", "cách dùng, cách nhau ;"))
                                        onCommitted: val => root.setProductField("uses", val)
                                    }
                                    BrainField {
                                        Layout.fillWidth: true
                                        label: (void i18n.revision, i18n.t("affiliate.f_pain", "Nỗi đau"))
                                        value: String(root.brainProduct().pain_point || "")
                                        ph: (void i18n.revision, i18n.t("affiliate.f_pain_ph", "vấn đề khách đang khổ"))
                                        onCommitted: val => root.setProductField("pain_point", val)
                                    }
                                    BrainField {
                                        Layout.fillWidth: true
                                        label: (void i18n.revision, i18n.t("affiliate.f_audience", "Khách"))
                                        value: String(root.brainProduct().target_audience || "")
                                        ph: (void i18n.revision, i18n.t("affiliate.f_audience_ph", "ai mua"))
                                        onCommitted: val => root.setProductField("target_audience", val)
                                    }
                                    BrainField {
                                        Layout.fillWidth: true
                                        Layout.columnSpan: 2
                                        label: (void i18n.revision, i18n.t("affiliate.f_sell_angle", "Góc bán"))
                                        value: String(root.brainProduct().sell_angle || "")
                                        ph: (void i18n.revision, i18n.t("affiliate.f_sell_angle_ph", "cách pitch thuyết phục nhất"))
                                        onCommitted: val => root.setProductField("sell_angle", val)
                                    }
                                    // Mô tả thật từ trang/nhà bán — nguồn chính cho AI viết kịch bản
                                    // (import từ link/overlay tự đổ vào đây; architect đọc field này).
                                    BrainField {
                                        Layout.fillWidth: true
                                        Layout.columnSpan: 2
                                        label: (void i18n.revision, i18n.t("affiliate.f_description", "Mô tả (nguồn kịch bản)"))
                                        value: String(root.brainProduct().description || "")
                                        ph: (void i18n.revision, i18n.t("affiliate.f_description_ph", "mô tả sản phẩm — bóc từ trang khi import link, sửa/bổ sung được"))
                                        onCommitted: val => root.setProductField("description", val)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: brainCards.columns === 2 ? brainCards.cardH : kitCol.implicitHeight + VfTheme.dp(18)
                            radius: VfTheme.dp(8); color: VfTheme.surfaceSoft
                            border.color: VfTheme.border; border.width: 1
                            ColumnLayout {
                                id: kitCol
                                anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                                anchors.margins: VfTheme.dp(9)
                                spacing: VfTheme.dp(5)
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: VfTheme.dp(6)
                                    Text {
                                        Layout.fillWidth: true
                                        text: (void i18n.revision, i18n.t("affiliate.brain_checklist", "VIDEO NÀY CẦN GÌ (tự động)"))
                                        color: VfTheme.violetText; font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong
                                        elide: Text.ElideRight
                                    }
                                    PrepStatusBadge {
                                        label: root.kitBadgeLabel()
                                        tone: root.kitBadgeTone()
                                    }
                                }
                                Repeater {
                                    model: (root._kit || {}).items || []
                                    RowLayout {
                                        Layout.fillWidth: true; spacing: VfTheme.dp(7)
                                        Text {
                                            Layout.preferredWidth: VfTheme.dp(16)
                                            text: {
                                                var s = String((modelData || {}).state || "")
                                                return s === "ok" ? "✓" : (s === "auto" ? "◈" : "⚠")
                                            }
                                            color: {
                                                var s = String((modelData || {}).state || "")
                                                return s === "ok" ? VfTheme.greenBorder : (s === "auto" ? VfTheme.cyan : VfTheme.amber)
                                            }
                                            font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontControl; font.weight: VfTheme.weightStrong
                                        }
                                        ColumnLayout {
                                            Layout.fillWidth: true; spacing: 0
                                            Text {
                                                Layout.fillWidth: true
                                                text: String((modelData || {}).label || "")
                                                color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; font.weight: VfTheme.weightStrong
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                text: String((modelData || {}).detail || "")
                                                color: VfTheme.textSubtle; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny
                                                wrapMode: Text.WordWrap
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // PHIÊN BẢN THỬ NGHIỆM A/B của SP ĐANG CHỌN — fillHeight LẤP HẾT
                    // khoảng trống; nhiều phiên bản thì scroll TRONG card.
                    Rectangle {
                        objectName: "affiliateVariantMatrix"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: VfTheme.dp(120)
                        radius: VfTheme.dp(8); color: VfTheme.surfaceSoft
                        border.color: VfTheme.border; border.width: 1
                        ColumnLayout {
                            id: varCol
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(9)
                            spacing: VfTheme.dp(4)
                            RowLayout {
                                Layout.fillWidth: true; spacing: VfTheme.dp(8)
                                Text {
                                    text: (void i18n.revision, i18n.t("affiliate.seg_ab", "PHIÊN BẢN THỬ NGHIỆM A/B"))
                                    color: VfTheme.violetText; font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong
                                }
                                PrepStatusBadge {
                                    label: root.variantBadgeLabel()
                                    tone: root.readyVariantCount() > 0 ? "success" : "working"
                                }
                                Item { Layout.fillWidth: true }
                                NormalToolbarButton {
                                    actionId: "affiliate.variant.add"
                                    text: "+ " + (void i18n.revision, i18n.t("affiliate.add_version", "Thêm phiên bản"))
                                    enabled: root.planFor(root.brainPid()).length < root.maxVariantsPerProduct
                                    onClicked: root.requestAction("work_panel.affiliate_campaign_add", { product_id: root.brainPid() })
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: root.planFor(root.brainPid()).length === 0
                                text: (void i18n.revision, i18n.t("affiliate.campaign_empty_sp", "Chưa có biến thể — bấm ⚡ định hình (header) hoặc + thêm tay."))
                                color: VfTheme.textSubtle; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall
                            }
                            // Header cột — đọc như BẢNG thật.
                            RowLayout {
                                Layout.fillWidth: true; spacing: VfTheme.dp(6)
                                visible: root.planFor(root.brainPid()).length > 0
                                Text { text: "#"; Layout.preferredWidth: VfTheme.dp(30); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                                Text { text: "Format"; Layout.preferredWidth: VfTheme.dp(136); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                                Text { text: (void i18n.revision, i18n.t("affiliate.hook_col", "Hook mở đầu")); Layout.fillWidth: true; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                                Text { text: "CTA"; Layout.preferredWidth: VfTheme.dp(170); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                                Item { Layout.preferredWidth: VfTheme.dp(28) }
                            }
                            // Danh sách phiên bản — scroll TRONG card khi nhiều.
                            Flickable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentWidth: width
                                contentHeight: abRows.implicitHeight
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds
                                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                ColumnLayout {
                                    id: abRows
                                    width: parent.width
                                    spacing: VfTheme.dp(4)
                            Repeater {
                                model: root.planFor(root.brainPid())
                                RowLayout {
                                    Layout.fillWidth: true; spacing: VfTheme.dp(6)
                                    Text {
                                        text: "🎬" + String(index + 1)
                                        color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall
                                        Layout.preferredWidth: VfTheme.dp(30)
                                    }
                                    NoScrollComboBox {
                                        Layout.preferredWidth: VfTheme.dp(136); Layout.preferredHeight: VfTheme.dp(30)
                                        model: root.videoTypesFor(modelData); textRole: "label"; valueRole: "value"
                                        currentIndex: indexOfValue(String((modelData || {}).video_type || "adaptive"))
                                        // Fix combo trống: re-set sau khi model sẵn sàng (không phụ thuộc thứ tự init).
                                        Component.onCompleted: currentIndex = indexOfValue(String((modelData || {}).video_type || "adaptive"))
                                        onActivated: idx => root.requestAction("work_panel.affiliate_campaign_set", { product_id: root.brainPid(), index: index, key: "video_type", value: valueAt(idx) })
                                    }
                                    TextField {
                                        Layout.fillWidth: true; Layout.preferredHeight: VfTheme.dp(30)
                                        placeholderText: (void i18n.revision, i18n.t("affiliate.hook_ph", "hook mở đầu"))
                                        text: String((modelData || {}).hook || "")
                                        color: VfTheme.text; placeholderTextColor: VfTheme.textSubtle; selectByMouse: true
                                        autoScroll: activeFocus
                                        font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; leftPadding: VfTheme.dp(8)
                                        background: Rectangle { radius: VfTheme.radiusControl; color: VfTheme.surface; border.color: VfTheme.borderBox; border.width: 1 }
                                        onActiveFocusChanged: {
                                            if (!activeFocus) {
                                                deselect()
                                                cursorPosition = 0
                                            }
                                        }
                                        Component.onCompleted: cursorPosition = 0
                                        onEditingFinished: {
                                            root.requestAction("work_panel.affiliate_campaign_set", { product_id: root.brainPid(), index: index, key: "hook", value: text })
                                            cursorPosition = 0
                                        }
                                    }
                                    TextField {
                                        Layout.preferredWidth: VfTheme.dp(170); Layout.preferredHeight: VfTheme.dp(30)
                                        placeholderText: (void i18n.revision, i18n.t("affiliate.cta_ph", "CTA"))
                                        text: String((modelData || {}).cta || "")
                                        color: VfTheme.text; placeholderTextColor: VfTheme.textSubtle; selectByMouse: true
                                        autoScroll: activeFocus
                                        font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; leftPadding: VfTheme.dp(8)
                                        background: Rectangle { radius: VfTheme.radiusControl; color: VfTheme.surface; border.color: VfTheme.borderBox; border.width: 1 }
                                        onActiveFocusChanged: {
                                            if (!activeFocus) {
                                                deselect()
                                                cursorPosition = 0
                                            }
                                        }
                                        Component.onCompleted: cursorPosition = 0
                                        onEditingFinished: {
                                            root.requestAction("work_panel.affiliate_campaign_set", { product_id: root.brainPid(), index: index, key: "cta", value: text })
                                            cursorPosition = 0
                                        }
                                    }
                                    NormalToolbarButton { text: "✕"; minWidth: VfTheme.dp(28)
                                        onClicked: root.requestAction("work_panel.affiliate_campaign_remove", { product_id: root.brainPid(), index: index }) }
                                }
                            }
                                }
                            }
                        }
                    }
                }
            }

        // ── PHẢI ③: SẢN XUẤT (thay right-rail job panel chung) ───────────────
        Loader {
            active: false
            visible: false
            Layout.preferredWidth: 0
            sourceComponent: AffiliateSection {
            // Legacy vertical queue rail retained for rollback compatibility but
            // removed from layout. The live queue is now the full-width pool below.
            visible: false
            Layout.preferredWidth: 0
            Layout.minimumWidth: 0
            Layout.maximumWidth: 0
            Layout.fillHeight: true
            accent: VfTheme.amber
            accentFill: VfTheme.amberFill
            badgeText: "③"
            title: (void i18n.revision, i18n.t("affiliate.production", "SẢN XUẤT"))
            hint: (void i18n.revision, i18n.t("affiliate.hint_queue",
                  "NHIỆM VỤ: hàng chờ sản xuất. Mỗi card = 1 video (1 SP × 1 biến thể) chạy chuỗi: Kịch bản → Giọng dẫn TTS → Render Veo → Ghép + SRT. ▶ chạy (tối đa 2 batch song song); ↻ chỉ chạy lại scene lỗi — không tốn lại tiền kịch bản/giọng."))

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(8)
                anchors.topMargin: VfTheme.dp(44)
                spacing: VfTheme.dp(6)

                // Đếm queue + trạng thái generating giờ sống ở THANH HÀNH ĐỘNG dưới
                // (bố chốt V3 22/7) — cột này chỉ còn danh sách card video.
                ListView {
                    id: prodList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    reuseItems: true
                    spacing: VfTheme.dp(5)
                    model: (typeof workPanelController !== "undefined" && workPanelController) ? workPanelController.queueModel : null
                    Column {
                        anchors.centerIn: parent
                        visible: prodList.count === 0 && !root.affiliateGenerating
                        width: parent.width - VfTheme.dp(20)
                        spacing: VfTheme.dp(5)
                        VfAppIcon { anchors.horizontalCenter: parent.horizontalCenter; name: "inbox-tray"; size: VfTheme.dp(24); framed: false; color: VfTheme.textSubtle }
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: (void i18n.revision, i18n.t("affiliate.empty_queue_rail", "Chưa có video nào.\nBấm ▶ CHẠY ở thanh dưới — mỗi biến thể thành 1 video: Kịch bản → Giọng TTS → Render → Ghép + SRT"))
                            color: VfTheme.textSubtle; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall
                            wrapMode: Text.WordWrap
                        }
                    }
                    delegate: Rectangle {
                        required property var qrow
                        width: ListView.view.width
                        height: qCol.implicitHeight + VfTheme.dp(14)
                        radius: VfTheme.dp(7)
                        color: VfTheme.surfaceSoft
                        border.color: {
                            var st = String((qrow || {}).status || "").toLowerCase()
                            if (String((qrow || {}).error_message || "").length > 0 || st.indexOf("fail") >= 0) return VfTheme.redBorder
                            if (st.indexOf("run") >= 0 || st.indexOf("generat") >= 0) return VfTheme.amberBorder
                            return VfTheme.border
                        }
                        border.width: 1
                        ColumnLayout {
                            id: qCol
                            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                            anchors.margins: VfTheme.dp(7)
                            spacing: VfTheme.dp(4)
                            RowLayout {
                                Layout.fillWidth: true; spacing: VfTheme.dp(6)
                                Rectangle {
                                    Layout.preferredWidth: VfTheme.dp(24); Layout.preferredHeight: VfTheme.dp(24)
                                    radius: VfTheme.dp(5); color: VfTheme.surface; clip: true
                                    Image {
                                        anchors.fill: parent
                                        source: String((qrow || {}).product_image || "").length > 0
                                                ? "file:///" + String(qrow.product_image).replace(/\\/g, "/") : ""
                                        fillMode: Image.PreserveAspectCrop; asynchronous: true
                                        sourceSize.width: 64; sourceSize.height: 64
                                        visible: source.toString() !== ""
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 0
                                    Text {
                                        Layout.fillWidth: true
                                        text: String((qrow || {}).product_name || (qrow || {}).name || "Video")
                                        color: VfTheme.text; font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall; font.weight: VfTheme.weightStrong
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        // biến thể · hook · 🎙 giọng narrator đã chốt (bố 23/7)
                                        text: String((qrow || {}).video_type_label || (qrow || {}).video_type || "") +
                                              (String((qrow || {}).hook || "").length > 0 ? " · " + String(qrow.hook) : "") +
                                              (String((qrow || {}).narrator_voice || "").length > 0 ? " · 🎙 " + String(qrow.narrator_voice) : "")
                                        color: VfTheme.violet; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                            // 3 chặng đo được thật: CHUẨN BỊ (plan+voice+ảnh) → RENDER → GHÉP
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(3)
                                Rectangle {
                                    id: prepSeg
                                    readonly property bool preparing: Number((qrow || {}).scene_total || 0) === 0
                                                                      && String((qrow || {}).status || "").toLowerCase().indexOf("run") >= 0
                                    Layout.preferredWidth: VfTheme.dp(34); Layout.preferredHeight: VfTheme.dp(5); radius: VfTheme.dp(3)
                                    color: Number((qrow || {}).scene_total || 0) > 0 ? VfTheme.greenBorder
                                         : (prepSeg.preparing ? VfTheme.amber : VfTheme.borderSoft)
                                    // Chuẩn bị (viết kịch bản/voice/ảnh, chưa có scene) → dải THỞ.
                                    SequentialAnimation on opacity {
                                        running: prepSeg.preparing && VfTheme.motion
                                        loops: Animation.Infinite
                                        alwaysRunToEnd: true
                                        NumberAnimation { to: 0.35; duration: 600; easing.type: Easing.InOutQuad }
                                        NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
                                    }
                                    onPreparingChanged: if (!preparing) opacity = 1
                                }
                                Rectangle {
                                    Layout.fillWidth: true; Layout.preferredHeight: VfTheme.dp(5); radius: VfTheme.dp(3)
                                    color: VfTheme.borderSoft
                                    Rectangle {
                                        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                                        radius: parent.radius
                                        width: {
                                            var total = Number((qrow || {}).scene_total || 0)
                                            var done = Number((qrow || {}).scene_done || 0)
                                            return total > 0 ? parent.width * Math.min(1, done / total) : 0
                                        }
                                        color: VfTheme.greenBorder
                                    }
                                }
                                Rectangle {
                                    Layout.preferredWidth: VfTheme.dp(34); Layout.preferredHeight: VfTheme.dp(5); radius: VfTheme.dp(3)
                                    color: (Boolean((qrow || {}).auto_merge_completed) || String((qrow || {}).merged_video || "").length > 0)
                                           ? VfTheme.greenBorder : VfTheme.borderSoft
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true; spacing: VfTheme.dp(5)
                                Text {
                                    Layout.fillWidth: true
                                    text: {
                                        var err = String((qrow || {}).error_message || "")
                                        if (err.length > 0) return "⛔ " + err
                                        var total = Number((qrow || {}).scene_total || 0)
                                        if (total > 0)
                                            return Number((qrow || {}).scene_done || 0) + "/" + total +
                                                   (void i18n.revision, i18n.t("affiliate.scenes_unit", " cảnh")) +
                                                   " · " + Number((qrow || {}).job_progress || 0) + "%"
                                        return String((qrow || {}).status || (void i18n.revision, i18n.t("common.pending", "Chờ")))
                                    }
                                    color: String((qrow || {}).error_message || "").length > 0 ? VfTheme.redText : VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny
                                    elide: Text.ElideRight
                                }
                                NormalToolbarButton {
                                    visible: String((qrow || {}).merged_video || "").length > 0
                                    text: "▶"; selected: true; minWidth: VfTheme.dp(26)
                                    onClicked: root.requestAction("work_panel.affiliate_open_path", { path: String(qrow.merged_video) })
                                }
                                NormalToolbarButton {
                                    visible: {
                                        var st = String((qrow || {}).status || "").toLowerCase()
                                        var hasErr = String((qrow || {}).error_message || "").length > 0
                                            || st.indexOf("fail") >= 0 || st.indexOf("error") >= 0
                                        var total = Number((qrow || {}).scene_total || 0)
                                        var partial = total > 0 && Number((qrow || {}).scene_done || 0) < total
                                            && (st.indexOf("done") >= 0 || st.indexOf("complete") >= 0)
                                        return hasErr || partial
                                    }
                                    text: "↻ " + (void i18n.revision, i18n.t("affiliate.retry_short", "Lỗi"))
                                    minWidth: VfTheme.dp(40)
                                    tooltip: (void i18n.revision, i18n.t("affiliate.retry_tip", "Chạy lại CHỈ các scene lỗi — không tốn lại tiền kịch bản/giọng"))
                                    onClicked: root.requestAction("work_panel.affiliate_retry_failed", { row_id: String((qrow || {}).id || (qrow || {}).row_id || (qrow || {}).batch_id || "") })
                                }
                                NormalToolbarButton {
                                    text: "📁"; minWidth: VfTheme.dp(26)
                                    tooltip: (void i18n.revision, i18n.t("affiliate.open_folder_tip", "Mở thư mục video"))
                                    onClicked: root.requestAction("work_panel.affiliate_open_path", { path: String((qrow || {}).output_folder || "") })
                                }
                                NormalToolbarButton {
                                    text: "🗑"; danger: true; minWidth: VfTheme.dp(26)
                                    tooltip: (void i18n.revision, i18n.t("affiliate.delete_row_tip", "Xoá video này khỏi hàng chờ"))
                                    onClicked: root.requestAction("work_panel.queue_delete_row", { row_id: String((qrow || {}).id || (qrow || {}).row_id || (qrow || {}).batch_id || ""), row: qrow })
                                }
                            }
                        }
                    }
                }
            }
        }
        }

        // ── PHẢI ③: tài nguyên dùng để chuẩn bị từng lượt trong pool ─────────
        ColumnLayout {
            // Rail tài nguyên chỉ cần đủ cho 1–3 slot; nhường chiều ngang cho hồ sơ.
            Layout.preferredWidth: VfTheme.dp(344)
            Layout.minimumWidth: VfTheme.dp(320)
            Layout.maximumWidth: VfTheme.dp(372)
            Layout.fillHeight: true
            spacing: VfTheme.dp(8)

            AffiliateAssetPicker {
                objectName: "affiliateCharacterPicker"
                Layout.fillWidth: true
                Layout.fillHeight: true
                assetType: "character"
                accentColor: VfTheme.primary
                titleText: (void i18n.revision,
                            i18n.t("affiliate.kol_character", "NHÂN VẬT KOL"))
                titleIcon: "users-round"
                aiMode: root.autoOf("character")
                maxAiSlots: Number((root.modelBudget || {}).max_chars || 1)
                aiLabel: "AI tạo (tự lưu Thư viện)"
                previewHint: "AI sẽ tạo KOL hợp ngành "
                             + String((root._kit || {}).industry_label || "SP")
                footNote: "Mặt + giọng khóa theo nhau · dùng chung pipeline consistency"
                hintText: "Nhân vật cầm, diễn và nói về sản phẩm. Auto sẽ chọn hoặc tạo KOL phù hợp từng sản phẩm khi tới lượt."
                assetsModel: root.assetsOf("character_slots")
                statusText: root.assetStatusLabel("character", "character_slots")
                statusTone: root.assetStatusTone("character", "character_slots")
                showAutoSave: true
                autoSaveOn: (root.routeConfig || {}).character_auto_save_library !== false
                onAutoSaveToggled: on => root.setOpt("character_auto_save_library", on)
                onChoose: root.requestAction(
                    "work_panel.affiliate_character",
                    { mode: "choose", source: "affiliate_character_choose" }
                )
                onRemove: assetId => root.requestAction(
                    "work_panel.affiliate_character",
                    { mode: "remove", asset_id: assetId,
                      source: "affiliate_character_remove" }
                )
                onAiToggled: on => {
                    if (typeof workPanelController !== "undefined"
                            && workPanelController)
                        workPanelController.toggleAffiliateRouteAssetAuto(
                            "character", on)
                }
                imageResolver: a => MediaSourceResolver.imageSource(a || ({}))
                voiceResolver: a => String((a || {}).voice_name
                                            || (a || {}).bound_voice_name || "")
            }

            AffiliateAssetPicker {
                objectName: "affiliateBackgroundPicker"
                Layout.fillWidth: true
                Layout.fillHeight: true
                assetType: "background"
                accentColor: VfTheme.cyan
                titleText: (void i18n.revision,
                            i18n.t("affiliate.common_context", "BỐI CẢNH"))
                titleIcon: "image"
                aiMode: root.autoOf("background")
                maxAiSlots: Number((root.modelBudget || {}).max_bg || 1)
                aiLabel: "AI tạo (tự lưu Thư viện)"
                previewHint: "AI dựng bối cảnh hợp ngành "
                             + String((root._kit || {}).industry_label || "SP")
                footNote: "Tối đa 1 bối cảnh/scene · có thể mô tả bằng text khi thiếu slot"
                hintText: "Bối cảnh quay cho từng sản phẩm. Auto tạo khi cần; model có thể dành slot ảnh cho sản phẩm và nhân vật."
                assetsModel: root.assetsOf("background_slots")
                statusText: root.assetStatusLabel("background", "background_slots")
                statusTone: root.assetStatusTone("background", "background_slots")
                showAutoSave: true
                autoSaveOn: (root.routeConfig || {}).background_auto_save_library !== false
                onAutoSaveToggled: on => root.setOpt("background_auto_save_library", on)
                onChoose: root.requestAction(
                    "work_panel.affiliate_background",
                    { mode: "choose", source: "affiliate_background_choose" }
                )
                onRemove: assetId => root.requestAction(
                    "work_panel.affiliate_background",
                    { mode: "remove", asset_id: assetId,
                      source: "affiliate_background_remove" }
                )
                onAiToggled: on => {
                    if (typeof workPanelController !== "undefined"
                            && workPanelController)
                        workPanelController.toggleAffiliateRouteAssetAuto(
                            "background", on)
                }
                imageResolver: a => MediaSourceResolver.imageSource(a || ({}))
                voiceResolver: a => ""
            }
        }
    }

    // ══════════ THANH HÀNH ĐỘNG (bố chốt V3 22/7) — MỘT thể thống nhất:
    // trạng thái + đếm queue (trái) · Xóa – Dừng – Tiếp tục – CHẠY (phải).
    // Nút gọi THẲNG controller (bug 20/7: 3 signal queue của workspace mồ côi).
    Loader {
        active: false
        visible: false
        Layout.preferredHeight: 0
        sourceComponent: Rectangle {
        visible: false
        Layout.fillWidth: true
        Layout.preferredHeight: 0
        Layout.maximumHeight: 0
        implicitHeight: actionRow.implicitHeight + VfTheme.dp(14)
        radius: VfTheme.radiusPanel
        color: VfTheme.canvas
        border.color: VfTheme.borderBox
        border.width: 1

        RowLayout {
            id: actionRow
            anchors.left: parent.left; anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: VfTheme.dp(10); anchors.rightMargin: VfTheme.dp(7)
            spacing: VfTheme.dp(7)

            // Trạng thái: chấm màu + chữ (generating thắng, rồi lỗi, rồi sẵn sàng).
            Rectangle {
                id: statusDot
                readonly property bool busy: root.affiliateGenerating || Number((root.stats || {}).generating || 0) > 0
                Layout.preferredWidth: VfTheme.dp(9)
                Layout.preferredHeight: VfTheme.dp(9)
                radius: VfTheme.dp(5)
                color: statusDot.busy
                       ? VfTheme.amber
                       : (Number((root.stats || {}).failed || 0) > 0 ? VfTheme.redBorder : VfTheme.greenBorder)
                // Hiệu ứng hoạt động (bố 23/7): đang chạy thì chấm THỞ để thấy hệ
                // thống còn sống, kể cả khi % chưa nhúc nhích. Opacity cục bộ — rẻ.
                SequentialAnimation on opacity {
                    running: statusDot.busy && VfTheme.motion
                    loops: Animation.Infinite
                    alwaysRunToEnd: true
                    NumberAnimation { to: 0.3; duration: 650; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 650; easing.type: Easing.InOutQuad }
                }
                onBusyChanged: if (!busy) opacity = 1
            }
            Text {
                Layout.maximumWidth: VfTheme.dp(360)
                text: {
                    if (root.affiliateGenerating)
                        return "⏳ " + (void root.routeConfig, String(workPanelController.affiliateGeneratingStatusText()
                               || (void i18n.revision, i18n.t("affiliate.generating", "Đang tạo kịch bản…"))))
                    if (Number((root.stats || {}).generating || 0) > 0)
                        return (void i18n.revision, i18n.t("affiliate.st_running", "Đang xử lý…"))
                    return (void i18n.revision, i18n.t("affiliate.st_ready", "Sẵn sàng"))
                }
                color: root.affiliateGenerating ? VfTheme.amberText : VfTheme.text
                font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightStrong
                elide: Text.ElideRight
            }

            // Đếm queue — 4 pill, cùng nguồn stats với cột ③.
            Repeater {
                model: [
                    { lb: (void i18n.revision, i18n.t("affiliate.cnt_run", "Chạy")), v: Number((root.stats || {}).generating || 0), warn: false },
                    { lb: (void i18n.revision, i18n.t("affiliate.cnt_wait", "Chờ")), v: Number((root.stats || {}).pending || 0), warn: false },
                    { lb: (void i18n.revision, i18n.t("affiliate.cnt_done", "Xong")), v: Number((root.stats || {}).completed || 0), warn: false },
                    { lb: (void i18n.revision, i18n.t("affiliate.cnt_fail", "Lỗi")), v: Number((root.stats || {}).failed || 0), warn: true }
                ]
                Rectangle {
                    required property var modelData
                    Layout.preferredWidth: pillText.implicitWidth + VfTheme.dp(16)
                    Layout.preferredHeight: VfTheme.dp(22)
                    radius: VfTheme.dp(11)
                    color: VfTheme.surfaceSoft
                    border.color: modelData.warn && modelData.v > 0 ? VfTheme.redBorder : VfTheme.borderSoft
                    border.width: 1
                    Text {
                        id: pillText
                        anchors.centerIn: parent
                        text: modelData.lb + " " + modelData.v
                        color: modelData.warn && modelData.v > 0 ? VfTheme.redText : VfTheme.textSubtle
                        font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny
                        font.weight: VfTheme.weightStrong
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Xóa – Dừng – Tiếp tục dùng cùng một AUTO gate với header để
            // không tạo hai state machine lệch nhau. Queue admission chỉ có
            // một cửa ở nút "Thêm vào danh sách công việc" phía trên bảng.
            NormalToolbarButton {
                text: "🗑 " + (void i18n.revision, i18n.t("affiliate.clear_all", "Xóa"))
                danger: true
                onClicked: workPanelController.clearQueue()
            }
            NormalToolbarButton {
                text: "⏸ " + (void i18n.revision, i18n.t("affiliate.pause", "Dừng"))
                onClicked: root.requestAction(
                    "work_panel.affiliate_auto_pool_toggle",
                    { enabled: false }
                )
            }
            NormalToolbarButton {
                text: "▶ " + (void i18n.revision, i18n.t("affiliate.resume", "Tiếp tục"))
                onClicked: root.requestAction(
                    "work_panel.affiliate_auto_pool_toggle",
                    { enabled: true }
                )
            }
        }
    }
    }

    // ══════════ TÀI NGUYÊN — LUÔN HIỆN, CHUNG MỌI SP, AUTO MẶC ĐỊNH ══════════
    // 2 block chia đôi full-width (giọng + thị trường đã lên master config).
    // Per-SP là GÓC NHÌN: card preview đổi theo ngành SP đang chọn ở khu ①.
    Loader {
        active: false
        visible: false
        Layout.preferredHeight: 0
        sourceComponent: RowLayout {
        visible: false
        Layout.fillWidth: true
        Layout.preferredHeight: 0
        Layout.minimumHeight: 0
        Layout.maximumHeight: 0
        spacing: VfTheme.dp(8)

        AffiliateAssetPicker {
            Layout.preferredWidth: Math.floor(root.width * 0.49)
            Layout.fillHeight: true
            assetType: "character"
            accentColor: VfTheme.primary
            titleText: (void i18n.revision, i18n.t("affiliate.kol_character", "NHÂN VẬT KOL"))
            titleIcon: "users-round"
            aiMode: root.autoOf("character")
            maxAiSlots: Number((root.modelBudget || {}).max_chars || 1)
            aiLabel: (void i18n.revision, i18n.t("affiliate.create_char_ai", "AI tạo (tự lưu Thư viện)"))
            previewHint: (void i18n.revision, i18n.t("affiliate.kol_preview", "AI sẽ tạo KOL hợp ngành")) +
                         " " + String((root._kit || {}).industry_label || "SP")
            footNote: (void i18n.revision, i18n.t("affiliate.kol_footnote",
                      "CHUNG mọi SP · AI tự chọn/tạo KOL hợp ngành TỪNG SP lúc chạy · mặt + giọng khoá theo nhau · tự lưu Thư viện"))
            hintText: (void i18n.revision, i18n.t("affiliate.hint_kol",
                      "NHIỆM VỤ: người cầm/diễn sản phẩm trong video. Auto = AI thiết kế KOL hợp ngành TỪNG SP lúc chạy rồi tự lưu Thư viện (mặt + giọng khoá theo nhau). Thư viện = dùng lại KOL đã có. Chọn nhiều KOL → mỗi phiên bản A/B xoay 1 người khác."))
            assetsModel: root.assetsOf("character_slots")
            showAutoSave: true
            autoSaveOn: (root.routeConfig || {}).character_auto_save_library !== false
            onAutoSaveToggled: on => root.setOpt("character_auto_save_library", on)
            onChoose: root.requestAction("work_panel.affiliate_character", { mode: "choose", source: "affiliate_character_choose" })
            onRemove: assetId => root.requestAction("work_panel.affiliate_character", { mode: "remove", asset_id: assetId, source: "affiliate_character_remove" })
            onAiToggled: on => { if (typeof workPanelController !== "undefined" && workPanelController) workPanelController.toggleAffiliateRouteAssetAuto("character", on) }
            imageResolver: a => MediaSourceResolver.imageSource(a || ({}))
            voiceResolver: a => String((a || {}).voice_name || (a || {}).bound_voice_name || "")
        }
        AffiliateAssetPicker {
            Layout.fillWidth: true
            Layout.fillHeight: true
            assetType: "background"
            accentColor: VfTheme.cyan
            titleText: (void i18n.revision, i18n.t("affiliate.common_context", "BỐI CẢNH"))
            titleIcon: "image"
            aiMode: root.autoOf("background")
            maxAiSlots: Number((root.modelBudget || {}).max_bg || 1)
            aiLabel: (void i18n.revision, i18n.t("affiliate.create_bg_ai", "AI tạo (tự lưu Thư viện)"))
            previewHint: (void i18n.revision, i18n.t("affiliate.bg_preview", "AI dựng bối cảnh hợp ngành")) +
                         " " + String((root._kit || {}).industry_label || "SP")
            footNote: (void i18n.revision, i18n.t("affiliate.bg_footnote",
                      "Đồng bộ shared consistency như Master/Clone · max 1 bối cảnh/scene theo ngân sách model · gen xong tự lưu Thư viện"))
            hintText: (void i18n.revision, i18n.t("affiliate.hint_bg",
                      "NHIỆM VỤ: không gian quay video (phòng tắm, bếp, studio…). Auto = BG-Gen dựng bối cảnh hợp ngành TỪNG SP lúc chạy rồi tự lưu Thư viện. Mỗi scene tối đa 1 bối cảnh theo ngân sách model."))
            assetsModel: root.assetsOf("background_slots")
            showAutoSave: true
            autoSaveOn: (root.routeConfig || {}).background_auto_save_library !== false
            onAutoSaveToggled: on => root.setOpt("background_auto_save_library", on)
            onChoose: root.requestAction("work_panel.affiliate_background", { mode: "choose", source: "affiliate_background_choose" })
            onRemove: assetId => root.requestAction("work_panel.affiliate_background", { mode: "remove", asset_id: assetId, source: "affiliate_background_remove" })
            onAiToggled: on => { if (typeof workPanelController !== "undefined" && workPanelController) workPanelController.toggleAffiliateRouteAssetAuto("background", on) }
            imageResolver: a => MediaSourceResolver.imageSource(a || ({}))
            voiceResolver: a => ""
        }
    }
    }

    AffiliateQueuePool {
        queueModel: (typeof workPanelController !== "undefined"
                     && workPanelController)
                    ? workPanelController.affiliateLifecycleModel : null
        stats: root.stats
        routeConfig: root.routeConfig
        pipelineBusy: root.pipelineBusy
        readyProductId: root.brainPid()
        readyProductName: String((root.brainProduct() || {}).name || "")
        readyVariantCount: root.readyVariantCount()
        readyToQueue: root.canQueueCurrentProduct()
        readinessText: root.queueReadinessText()
        analysisReady: root.productAnalysisReady()
        sheetReady: root.productSheetReady()
        characterStatus: root.autoOf("character") ? "CHAR AUTO"
                         : (root.assetsOf("character_slots").length > 0
                            ? "CHAR " + root.assetsOf("character_slots").length
                            : "CHAR —")
        characterConfigured: root.autoOf("character")
                             || root.assetsOf("character_slots").length > 0
        backgroundStatus: root.autoOf("background") ? "BG AUTO"
                        : (root.assetsOf("background_slots").length > 0
                           ? "BG " + root.assetsOf("background_slots").length
                           : "BG —")
        backgroundConfigured: root.autoOf("background")
                              || root.assetsOf("background_slots").length > 0
        onActionRequested: (actionId, payload) =>
            root.requestAction(actionId, payload)
        onClearRequested: {
            if (typeof workPanelController !== "undefined"
                    && workPanelController
                    && !workPanelController.affiliateUiPreview)
                workPanelController.clearQueue()
        }
    }

    // Backend persists/queues only after the explicit snapshot button. QML only
    // releases busy state; it never mutates a durable transaction speculatively.
    Connections {
        target: workPanelController
        function onAffiliateScriptReady() {
            root.affiliateGenerating = false
        }
        function onAffiliateScriptFailed() {
            root.affiliateGenerating = false
        }
    }

    // Lightbox ảnh SP — xem nhanh trong app, ‹ › chuyển, click ngoài/✕ đóng.
    Popup {
        id: imgPreviewPopup
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min((parent ? parent.width : 900) * 0.72, VfTheme.dp(680))
        height: Math.min((parent ? parent.height : 700) * 0.85, VfTheme.dp(720))
        modal: true
        dim: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            color: VfTheme.surface
            radius: VfTheme.dp(10)
            border.color: VfTheme.border; border.width: 1
        }
        contentItem: ColumnLayout {
            spacing: VfTheme.dp(8)
            Image {
                Layout.fillWidth: true
                Layout.fillHeight: true
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                // Ảnh to: resolver ưu tiên file/url gốc trước base64 thumbnail.
                source: {
                    var it = (root._previewList || [])[root._previewIdx] || ({})
                    return MediaSourceResolver.imageSource(it)
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)
                NormalToolbarButton {
                    text: "‹"; minWidth: VfTheme.dp(34)
                    enabled: root._previewIdx > 0
                    onClicked: root._previewIdx = Math.max(0, root._previewIdx - 1)
                }
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: (root._previewIdx + 1) + " / " + (root._previewList || []).length
                    color: VfTheme.textSubtle; font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall; font.weight: Font.DemiBold
                }
                NormalToolbarButton {
                    text: "›"; minWidth: VfTheme.dp(34)
                    enabled: root._previewIdx < (root._previewList || []).length - 1
                    onClicked: root._previewIdx = Math.min((root._previewList || []).length - 1, root._previewIdx + 1)
                }
                NormalToolbarButton {
                    text: "✕ " + (void i18n.revision, i18n.t("common.close", "Đóng"))
                    onClicked: imgPreviewPopup.close()
                }
            }
        }
    }
}
