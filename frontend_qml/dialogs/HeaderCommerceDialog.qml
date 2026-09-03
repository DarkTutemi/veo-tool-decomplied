import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "GatewayBillingDialog"

    property var payload: ({})
    property var keys: []
    property string apiMode: "aistudio"
    property string previousApiMode: "aistudio"
    // Admin allow-list (mode -> bool). A mode whose flag is false is hidden. Empty/missing
    // flag defaults to allowed, so nothing is blocked until the gateway pushes a policy.
    property var allowedModes: ({})
    function isModeAllowed(v) {
        var p = root.allowedModes || ({})
        return p[String(v)] !== false
    }
    readonly property bool onlyAiStudioModeEnabled: root.isModeAllowed("aistudio")
        && !root.isModeAllowed("server")
        && !root.isModeAllowed("personal")
    readonly property bool creditTopupAvailable: !root.onlyAiStudioModeEnabled
    property string selectedKeyId: ""
    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property bool busy: false
    property bool paymentPolling: false
    property string currentActionId: ""
    property int actionProgressValue: 0
    property string actionProgressText: ""
    property bool actionProgressIndeterminate: false
    property int selectedAmount: 100000
    readonly property int minTopupAmount: 30000
    readonly property int maxTopupAmount: 100000000
    property string selectedMethod: "BANK_TRANSFER"
    property double paymentPollStartedAtMs: 0
    property bool paymentPollExpired: false

    // Hiển thị/nhập theo display_currency (USD khi locale=EN), nhưng số tiền nạp
    // luôn được quy đổi về VND ở ranh giới gửi /credits/topup (backend không có
    // field currency). minTopupAmount/maxTopupAmount là cận VND chuẩn của backend.
    readonly property string displayCurrency: String((root.payload && root.payload.display_currency)
        || ((String(i18n.locale).indexOf("vi") === 0) ? "VND" : "USD"))
    readonly property real usdRate: Number((root.money && root.money.usd_exchange_rate)
        || (root.payload && root.payload.usd_exchange_rate) || 25000) || 25000
    readonly property var vndPresets: [30000, 50000, 100000, 200000, 500000, 1000000]
    readonly property var usdPresets: [2, 5, 10, 20, 50, 100]
    readonly property var amountPresets: root.displayCurrency === "USD" ? root.usdPresets : root.vndPresets
    readonly property int minDisplayAmount: root.displayCurrency === "USD" ? Math.max(1, Math.ceil(root.minTopupAmount / root.usdRate)) : root.minTopupAmount
    readonly property int maxDisplayAmount: root.displayCurrency === "USD" ? Math.floor(root.maxTopupAmount / root.usdRate) : root.maxTopupAmount
    // selectedAmount theo đơn vị hiển thị → quy đổi về VND cho moneyText() và wire.
    readonly property int topupWireVnd: root.displayCurrency === "USD" ? Math.round(root.selectedAmount * root.usdRate) : Math.round(root.selectedAmount)

    readonly property string payloadMode: String(root.payload && root.payload.mode || "")
    readonly property var money: root.payload && root.payload.money ? root.payload.money : ({})
    readonly property string currency: String((root.payload && root.payload.currency) || (root.money && root.money.currency) || "VND")
    readonly property string supportUrl: String((root.payload && root.payload.support_url) || "")
    readonly property string focusSection: String(root.payload && root.payload.focus || "money")
    readonly property var usageRows: root.payload && root.payload.usage_rows ? root.payload.usage_rows : []
    readonly property int usageRowCount: root.usageRowsModel().length
    readonly property var payloadSections: root.payload && root.payload.sections ? root.payload.sections : []
    readonly property real keyNameColumnWidth: VfTheme.dp(132)
    readonly property real keyStatusColumnWidth: VfTheme.dp(92)
    readonly property real keySpendColumnWidth: VfTheme.dp(104)
    readonly property real keyLastUsedColumnWidth: VfTheme.dp(100)
    readonly property string currentModeTitle: root.modeTitle(root.apiMode)
    readonly property string currentModeDescription: root.modeDescription(root.apiMode)
    readonly property var paymentRowMap: {
        if (root.payloadMode !== "payment")
            return ({})
        var map = {}
        for (var si = 0; si < root.payloadSections.length; si++) {
            var rows = (root.payloadSections[si] && root.payloadSections[si].rows) ? root.payloadSections[si].rows : []
            for (var ri = 0; ri < rows.length; ri++) {
                var row = rows[ri] || {}
                if (row.label)
                    map[String(row.label)] = String(row.value || "")
                if (row.action && row.action_value)
                    map["__action_" + row.label] = String(row.action_value || "")
            }
        }
        return map
    }
    readonly property string orderCode: root.paymentRowMap["Order"] || root.paymentRowMap["Payment code"] || ""
    readonly property string paymentStatus: root.paymentRowMap["Status"] || ""
    readonly property string paymentAmount: root.paymentRowMap["Amount"] || ""
    readonly property string paymentMethod: root.paymentRowMap["Payment method"] || ""
    readonly property string paymentQrUrl: root.paymentRowMap["QR URL"] || root.paymentRowMap["__action_QR URL"] || ""
    readonly property bool hasPayment: root.payloadMode === "payment" && root.orderCode.length > 0
    readonly property bool paymentPending: {
        var status = String(root.paymentStatus || "").toLowerCase()
        return root.hasPayment && (status === "" || status === "pending" || status === "waiting" || status === "unpaid")
    }

    signal refreshRequested()
    signal addRequested(string provider, string label, string key)
    signal deleteRequested(string keyId)
    signal modeRequested(string mode)
    signal topupRequested(string value)
    signal paymentPollRequested(string orderCode)
    signal actionRequested(string action, string value)
    signal externalUrlRequested(string url)

    Timer {
        interval: Qt.application.state === Qt.ApplicationActive ? 3000 : 12000
        repeat: true
        running: root.hasPayment && root.paymentPending && root.visible
                 && !root.paymentPolling && !root.paymentPollExpired
        onTriggered: {
            if (root.paymentPollStartedAtMs > 0
                    && Date.now() - root.paymentPollStartedAtMs >= 15 * 60 * 1000) {
                root.paymentPollExpired = true
                root.statusText = (void i18n.revision,
                    i18n.t("billing.payment_poll_expired", "Đã dừng kiểm tra sau 15 phút. Hãy làm mới thủ công nếu cần."))
                return
            }
            root.paymentPollRequested(root.orderCode)
        }
    }

    onOrderCodeChanged: {
        root.paymentPollStartedAtMs = root.orderCode.length > 0 ? Date.now() : 0
        root.paymentPollExpired = false
    }

    parent: Overlay.overlay
    modal: true
    width: VfDialogMetrics.width(parent, VfTheme.dp(1060), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(740), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        radius: VfTheme.dp(12)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    function syncStatusFromPayload() {
        root.statusText = String(root.payload.subtitle || "")
    }

    function syncDefaultAmount() {
        // Đổi mặc định theo đơn vị hiển thị (VND preset ~100K ↔ USD preset ~$10).
        if (root.displayCurrency === "USD" && root.selectedAmount > 1000)
            root.selectedAmount = 10
        else if (root.displayCurrency !== "USD" && root.selectedAmount < 1000)
            root.selectedAmount = 100000
    }

    onPayloadChanged: {
        root.syncStatusFromPayload()
        root.syncDefaultAmount()
    }

    function openFromPayload(data) {
        root.syncStatusFromPayload()
        root.open()
        Qt.callLater(function() {
            if (root.focusSection === "keys" && root.apiMode !== "server")
                keyInput.forceActiveFocus()
        })
    }

    onOpened: root.refreshRequested()

    function numberText(value) {
        var n = Math.round(Number(value || 0))
        var sign = n < 0 ? "-" : ""
        var text = String(Math.abs(n))
        return sign + text.replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    }

    function moneyText(value) {
        // Mirror header_service._fmt_money_for_locale: quy đổi từ source currency
        // sang display currency rồi format ($x.xx cho USD, "x VND" cho VND).
        var amount = Number(value || 0)
        var source = String(root.currency || "VND").toUpperCase()
        var target = String(root.displayCurrency || "VND").toUpperCase()
        if (source === "VND" && target === "USD")
            amount = amount / root.usdRate
        else if (source === "USD" && target === "VND")
            amount = amount * root.usdRate
        if (target === "USD")
            return "$" + amount.toFixed(2)
        return root.numberText(amount) + " VND"
    }

    function paymentFieldsModel() {
        if (!root.hasPayment)
            return []
        var visibleLabels = {
            "Bank": true,
            "Account number": true,
            "Account name": true,
            "USDT wallet": true,
            "USDT network": true,
            "USDT amount": true,
            "Expires": true,
            "Feature": true,
            "Days": true,
            "Access preview": true
        }
        var rowsOut = []
        for (var si = 0; si < root.payloadSections.length; si++) {
            var rows = (root.payloadSections[si] && root.payloadSections[si].rows) ? root.payloadSections[si].rows : []
            for (var ri = 0; ri < rows.length; ri++) {
                var row = rows[ri] || {}
                var label = String(row.label || "")
                var value = String(row.value || "")
                if (visibleLabels[label] && value.length > 0 && value !== "-")
                    rowsOut.push({ "label": label, "value": value })
                if (rowsOut.length >= 4)
                    return rowsOut
            }
        }
        return rowsOut
    }

    function keyId(item) {
        return String(item.id || item.key_id || "")
    }

    function keyLabel(item) {
        return String(item.label || item.name || item.provider || "Gemini key")
    }

    function maskedKey(item) {
        return String(item.masked_key || item.maskedKey || item.key_masked || item.api_key_masked || item.key || "")
    }

    function keySpend(item) {
        return Number(item.spend || item.spent || item.cost || item.usage_cost || 0)
    }

    function keyLastUsed(item) {
        return String(item.last_used || item.lastUsed || item.updated_at || item.updatedAt || item.created_at || item.createdAt || "")
    }

    function keyLastUsedText(item) {
        var value = root.keyLastUsed(item)
        return value.length ? value : (void i18n.revision, i18n.t("billing.never_used", "Chưa dùng"))
    }

    function hasKeyId(keyId) {
        var target = String(keyId || "")
        if (!target.length)
            return false
        var rows = root.keys || []
        for (var i = 0; i < rows.length; i++) {
            if (root.keyId(rows[i]) === target)
                return true
        }
        return false
    }

    readonly property bool showTopup: {
        var m = String(root.apiMode || "").toLowerCase()
        return root.creditTopupAvailable && m === "server"
    }

    function setMode(mode) {
        var normalized = String(mode || "aistudio").toLowerCase()
        if (["aistudio", "server", "personal"].indexOf(normalized) < 0)
            normalized = "aistudio"
        if (normalized === String(root.apiMode || "").toLowerCase())
            return
        root.previousApiMode = String(root.apiMode || "aistudio")
        root.apiMode = normalized
        root.statusText = (void i18n.revision, i18n.t("billing.updating_mode", "Đang cập nhật nguồn AI..."))
        root.modeRequested(normalized)
    }

    function saveKey() {
        if (root.apiMode !== "personal") {
            root.setMode("personal")
        }
        var apiKey = keyInput.text.trim()
        if (!apiKey.length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("billing.missing_key_title", "Thiếu key"))
            root.feedbackMessage = (void i18n.revision, i18n.t("billing.enter_key_first", "Nhập Gemini API key trước."))
            root.statusText = root.feedbackMessage
            feedbackDialog.open()
            return
        }
        root.statusText = (void i18n.revision, i18n.t("billing.save_requested", "Đã gửi yêu cầu lưu key."))
        root.addRequested("gemini", labelInput.text.trim(), apiKey)
    }

    function checkKey() {
        if (!keyInput.text.trim().length) {
            root.statusText = (void i18n.revision, i18n.t("billing.enter_key_first", "Nhập Gemini API key trước."))
            keyInput.forceActiveFocus()
            return
        }
        root.statusText = (void i18n.revision, i18n.t("billing.key_validate_note", "Key sẽ được gateway validate sau khi lưu."))
    }

    function requestDeleteKey() {
        if (!root.selectedKeyId.length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("billing.no_key_selected_title", "Chưa chọn key"))
            root.feedbackMessage = (void i18n.revision, i18n.t("billing.select_key_first", "Chọn một key trước."))
            root.statusText = root.feedbackMessage
            feedbackDialog.open()
            return
        }
        root.deleteRequested(root.selectedKeyId)
    }

    function applyAddResult(result) {
        var response = result || ({})
        if (response.ok) {
            keyInput.text = ""
            labelInput.text = ""
        } else {
            root.feedbackTitle = "Error"
            root.feedbackMessage = String(response.message || response.error || "API key save failed")
            feedbackDialog.open()
        }
        root.statusText = String(response.message || response.error || root.statusText)
    }

    function applyDeleteResult(result) {
        var response = result || ({})
        if (response.ok) {
            if (String(response.key_id || "") === root.selectedKeyId || !root.hasKeyId(root.selectedKeyId))
                root.selectedKeyId = ""
        } else {
            root.feedbackTitle = "Error"
            root.feedbackMessage = String(response.message || response.error || "API key remove failed")
            feedbackDialog.open()
        }
        root.statusText = String(response.message || response.error || root.statusText)
    }

    function applyModeResult(result) {
        var response = result || ({})
        if (response.ok) {
            root.apiMode = String(response.api_mode || root.apiMode || "server")
            root.previousApiMode = root.apiMode
        } else {
            root.apiMode = String(root.previousApiMode || "server")
            root.feedbackTitle = "Error"
            root.feedbackMessage = String(response.message || response.error || "API mode update failed")
            feedbackDialog.open()
        }
        root.statusText = String(response.message || response.error || root.statusText)
    }

    function topup() {
        if (!root.creditTopupAvailable)
            return
        // Client KHÔNG quy đổi: gửi số theo đơn vị hiển thị + currency; server tự đổi
        // (USD -> USDT tròn + VND theo usd_vnd_rate động). minTopup/maxTopup chỉ là
        // clamp UX mềm; server mới là nơi validate cận thật.
        var raw = Number(String(amountInput.text || root.selectedAmount).replace(/[,\s]/g, ""))
        if (!isFinite(raw) || raw <= 0)
            raw = root.selectedAmount
        raw = Math.min(root.maxDisplayAmount, Math.max(root.minDisplayAmount, raw))
        root.selectedAmount = root.displayCurrency === "USD" ? raw : Math.round(raw)
        amountInput.text = String(root.selectedAmount)
        var method = String(root.selectedMethod || "BANK_TRANSFER")
        var value = String(root.selectedAmount) + ":" + method + ":" + root.displayCurrency
        root.statusText = (void i18n.revision, i18n.t("billing.creating_topup", "Đang tạo lệnh nạp tiền..."))
        root.actionRequested("commerce_topup", value)
    }

    function modeTitle(mode) {
        var value = String(mode || "aistudio")
        if (value === "personal")
            return (void i18n.revision, i18n.t("billing.mode_personal", "API Cá nhân"))
        if (value === "aistudio")
            return (void i18n.revision, i18n.t("billing.mode_aistudio", "AI Studio"))
        return (void i18n.revision, i18n.t("billing.mode_gateway", "API Server"))
    }

    function modeDescription(mode) {
        var value = String(mode || "aistudio")
        if (value === "personal")
            return (void i18n.revision, i18n.t("billing.mode_personal_desc", "Dùng Gemini API key riêng. Nhập key bên dưới."))
        if (value === "aistudio")
            return (void i18n.revision, i18n.t("billing.mode_aistudio_desc", "Chỉ dùng AI Studio; lỗi sẽ dừng, không chuyển sang gateway."))
        return (void i18n.revision, i18n.t("billing.mode_server_desc", "Gateway trả phí — nạp tiền ở panel bên phải."))
    }

    function usageRowsModel() {
        // Ưu tiên breakdown thật từ gateway; nếu thưa/vắng thì nhồi tóm tắt
        // từ money (paid + freepath + wallet) cho panel trái đỡ trống.
        var out = []
        var seen = {}
        var src = root.usageRows || []
        if ((!src || src.length === 0) && root.money && root.money.usage_rows)
            src = root.money.usage_rows
        var i
        for (i = 0; i < (src || []).length; i++) {
            var r = src[i] || {}
            var key = String(r.model || "") + "|" + String(r.task || "") + "|" + String(r.source || "")
            if (seen[key])
                continue
            seen[key] = true
            out.push({
                model: String(r.model || r.provider || "Gateway"),
                task: String(r.task || r.action || r.label || "Sử dụng"),
                requests: Number(r.requests || r.count || r.jobs || 0),
                cost: Number(r.cost || r.amount || r.spent || r.total_cost || 0),
                source: String(r.source || r.mode || "Gateway")
            })
        }

        function pushSummary(model, task, requests, cost, source) {
            var k = model + "|" + task + "|" + source
            if (seen[k])
                return
            // Chỉ ẩn dòng cost=0 requests=0 nếu đã có breakdown thật khá dày.
            if (out.length >= 6 && Number(requests || 0) === 0 && Number(cost || 0) === 0)
                return
            seen[k] = true
            out.push({
                model: model,
                task: task,
                requests: Number(requests || 0),
                cost: Number(cost || 0),
                source: source
            })
        }

        var m = root.money || ({})
        pushSummary(
            (void i18n.revision, i18n.t("billing.usage_gateway_paid", "Gateway (trả phí)")),
            (void i18n.revision, i18n.t("billing.usage_month", "Tháng này")),
            m.requests_month, m.spent_month, "Gateway"
        )
        pushSummary(
            (void i18n.revision, i18n.t("billing.usage_gateway_paid", "Gateway (trả phí)")),
            (void i18n.revision, i18n.t("billing.usage_today", "Hôm nay")),
            m.requests_today, m.spent_today, "Gateway"
        )
        pushSummary(
            (void i18n.revision, i18n.t("billing.usage_freepath", "Freepath (free)")),
            (void i18n.revision, i18n.t("billing.usage_month", "Tháng này")),
            0, m.consumed_month, "AI Studio"
        )
        pushSummary(
            (void i18n.revision, i18n.t("billing.usage_freepath", "Freepath (free)")),
            (void i18n.revision, i18n.t("billing.usage_today", "Hôm nay")),
            0, m.consumed_today, "AI Studio"
        )
        pushSummary(
            (void i18n.revision, i18n.t("billing.usage_freepath", "Freepath (free)")),
            (void i18n.revision, i18n.t("billing.usage_total_free", "Tổng free đã dùng")),
            0, m.consumed_total, "AI Studio"
        )
        pushSummary(
            (void i18n.revision, i18n.t("billing.usage_wallet", "Ví gateway")),
            (void i18n.revision, i18n.t("billing.usage_wallet_paid", "Số dư paid")),
            0, m.wallet_balance, "Wallet"
        )
        pushSummary(
            (void i18n.revision, i18n.t("billing.usage_wallet", "Ví gateway")),
            (void i18n.revision, i18n.t("billing.usage_wallet_bonus", "Bonus / free credit")),
            0, m.bonus_balance, "Bonus"
        )
        pushSummary(
            (void i18n.revision, i18n.t("billing.usage_wallet", "Ví gateway")),
            (void i18n.revision, i18n.t("billing.usage_pending", "Pending topup")),
            0, m.pending_topup, "Pending"
        )

        return out
    }

    function metricsModel() {
        return [
            { label: (void i18n.revision, i18n.t("billing.available_balance", "Số dư khả dụng")), value: root.moneyText(root.money.available_balance) },
            { label: (void i18n.revision, i18n.t("billing.spent_month", "Đã tiêu thụ tháng này")), value: root.moneyText(root.money.spent_month) },
            { label: (void i18n.revision, i18n.t("billing.spent_today", "Hôm nay")), value: root.moneyText(root.money.spent_today) },
            { label: (void i18n.revision, i18n.t("billing.col_requests", "Requests")), value: root.numberText(root.money.requests_month) }
        ]
    }

    function renderSections() {
        return root.payloadSections || []
    }

    function statusTextForVisualTest() {
        return String(root.statusText || "")
    }

    function closeFeedbackForVisualTest() {
        feedbackDialog.close()
        return true
    }

    function setApiModeForVisualTest(mode) {
        root.previousApiMode = String(root.apiMode || "server")
        root.apiMode = String(mode || "server")
        return true
    }

    function setKeyFieldsForVisualTest(label, key) {
        labelInput.text = String(label || "")
        keyInput.text = String(key || "")
        return true
    }

    Dialog {
        id: feedbackDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(440), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

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
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                VfButton {
                    text: "OK"
                    tone: "primary"
                    iconName: "check-mark-button"
                    minWidth: VfTheme.dp(96)
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }

    Dialog {
        id: qrPreviewDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(64))
        height: VfDialogMetrics.height(parent, VfTheme.dp(500), VfTheme.dp(64))
        padding: VfTheme.dp(18)
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(2)

                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("billing.qr_title", "QR thanh toán"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(17)
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.orderCode + " - " + root.paymentAmount
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        elide: Text.ElideRight
                    }
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Đóng"))
                    compact: true
                    iconName: "cross-mark"
                    minWidth: VfTheme.dp(78)
                    onClicked: qrPreviewDialog.close()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(12)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border
                clip: true

                Image {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - VfTheme.dp(36), parent.height - VfTheme.dp(36), VfTheme.dp(340))
                    height: width
                    source: root.paymentQrUrl
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    visible: root.paymentQrUrl.length > 0
                }
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("billing.qr_help", "Nếu ngân hàng không đọc được QR, dùng nội dung chuyển khoản/mã đơn bên dưới."))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(78)
            color: VfTheme.surface
            radius: VfTheme.dp(12)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(24)
                anchors.rightMargin: VfTheme.dp(18)
                spacing: VfTheme.dp(14)

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(40)
                    Layout.preferredHeight: VfTheme.dp(40)
                    radius: VfTheme.dp(10)
                    color: VfTheme.blueFill
                    border.color: VfTheme.blueBorderSoft

                    VfAppIcon {
                        anchors.centerIn: parent
                        name: "key"
                        size: VfTheme.dp(24)
                        framed: false
                        color: "#2563EB"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(3)

                    Text {
                        Layout.fillWidth: true
                        text: "Gateway Billing & Gemini API"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(20)
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("billing.subtitle", "Quản lý Gemini key, chế độ sử dụng và chi phí thực tế."))
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(88)
                    Layout.preferredHeight: VfTheme.dp(34)
                    radius: VfTheme.dp(8)
                    color: VfTheme.violetFill
                    border.color: VfTheme.indigoBorderSoft

                    Text {
                        anchors.centerIn: parent
                        text: "v90.1.9"
                        color: "#4F46E5"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        font.weight: Font.Bold
                    }
                }

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(34)
                    Layout.preferredHeight: VfTheme.dp(34)
                    radius: VfTheme.dp(8)
                    color: closeMouse.containsMouse ? VfTheme.redFill : "transparent"

                    VfAppIcon {
                        anchors.centerIn: parent
                        name: "cross-mark"
                        size: VfTheme.dp(16)
                        framed: false
                        color: closeMouse.containsMouse ? "#DC2626" : VfTheme.textSubtle
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: VfTheme.border
            }
        }

        ColumnLayout {
            id: bodyColumn
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(64)
            Layout.maximumHeight: VfTheme.dp(64)
            Layout.leftMargin: VfTheme.dp(20)
            Layout.rightMargin: VfTheme.dp(20)
            Layout.topMargin: VfTheme.dp(10)
            spacing: VfTheme.dp(10)

            MetricCard {
                label: (void i18n.revision, i18n.t("billing.available_balance", "Số dư khả dụng"))
                value: root.moneyText(root.money.available_balance)
                iconName: "money-bag"
                accent: "#059669"
                fill: VfTheme.greenFill
                stroke: VfTheme.greenBorderSoft
            }

            MetricCard {
                label: (void i18n.revision, i18n.t("billing.spent_month", "Đã tiêu thụ tháng này"))
                value: root.moneyText(root.money.spent_month)
                iconName: "chart-increasing"
                accent: "#2563EB"
                fill: VfTheme.blueFill
                stroke: VfTheme.blueBorderSoft
            }

            MetricCard {
                label: (void i18n.revision, i18n.t("billing.spent_today", "Hôm nay"))
                value: root.moneyText(root.money.spent_today)
                iconName: "credit-card"
                accent: "#0E7490"
                fill: VfTheme.cyanFill
                stroke: VfTheme.cyanBorderSoft
            }

            MetricCard {
                label: (void i18n.revision, i18n.t("billing.col_requests", "Requests"))
                value: root.numberText(root.money.requests_month)
                iconName: "clipboard"
                accent: "#7C3AED"
                fill: VfTheme.violetFill
                stroke: VfTheme.violetBorderSoft
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: VfTheme.dp(460)
            Layout.leftMargin: VfTheme.dp(20)
            Layout.rightMargin: VfTheme.dp(20)
            Layout.topMargin: VfTheme.dp(10)
            Layout.bottomMargin: VfTheme.dp(8)
            spacing: VfTheme.dp(12)

            // LEFT — cấu hình AI (co giãn)
            SurfacePanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: VfTheme.dp(420)
                title: (void i18n.revision, i18n.t("billing.ai_config_panel", "Cấu hình AI"))
                iconName: "key"

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(6)

                    ModeButton { text: "AI Studio"; value: "aistudio"; hint: root.modeDescription("aistudio"); visible: root.isModeAllowed("aistudio") }
                    ModeButton { text: "API Server"; value: "server"; hint: root.modeDescription("server"); visible: root.isModeAllowed("server") }
                    ModeButton { text: "API Cá nhân"; value: "personal"; hint: root.modeDescription("personal"); visible: root.isModeAllowed("personal") }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(46)
                    radius: VfTheme.dp(8)
                    color: root.apiMode === "aistudio" ? "#EDE9FE" : (root.apiMode === "server" ? VfTheme.greenFill : VfTheme.cyanFill)
                    border.color: root.apiMode === "aistudio" ? "#C4B5FD" : (root.apiMode === "server" ? VfTheme.greenBorderSoft : "#67E8F9")

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: VfTheme.dp(12)
                        anchors.rightMargin: VfTheme.dp(12)
                        spacing: VfTheme.dp(10)

                        VfAppIcon {
                            name: root.apiMode === "aistudio" ? "globe-with-meridians" : (root.apiMode === "server" ? "money-bag" : "key")
                            size: VfTheme.dp(18)
                            framed: false
                            color: root.apiMode === "aistudio" ? "#7C3AED" : (root.apiMode === "server" ? "#059669" : "#0891B2")
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(1)

                            Text {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("billing.using_prefix", "Đang dùng: ")) + root.currentModeTitle
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.currentModeDescription
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // Personal keys table — only when API Cá nhân
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: VfTheme.dp(8)
                    color: VfTheme.surface
                    border.color: VfTheme.border
                    clip: true
                    visible: root.apiMode === "personal"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(32)
                            color: VfTheme.surfaceSoft

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(10)
                                anchors.rightMargin: VfTheme.dp(10)
                                spacing: 0

                                HeaderCell { Layout.preferredWidth: root.keyNameColumnWidth; text: (void i18n.revision, i18n.t("billing.col_name", "Tên")) }
                                HeaderCell { Layout.fillWidth: true; text: (void i18n.revision, i18n.t("billing.col_key", "Key")) }
                                HeaderCell { Layout.preferredWidth: root.keyStatusColumnWidth; text: (void i18n.revision, i18n.t("billing.col_status", "Trạng thái")); horizontalAlignment: Text.AlignHCenter }
                                HeaderCell { Layout.preferredWidth: root.keySpendColumnWidth; text: (void i18n.revision, i18n.t("billing.col_cost", "Chi phí")); horizontalAlignment: Text.AlignRight }
                                HeaderCell { Layout.preferredWidth: root.keyLastUsedColumnWidth; text: (void i18n.revision, i18n.t("billing.col_last_used", "Lần dùng")); horizontalAlignment: Text.AlignRight }
                            }
                        }

                        ListView {
                            id: keyTable
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            reuseItems: true
                            model: root.keys || []

                            delegate: Rectangle {
                                width: keyTable.width
                                height: VfTheme.dp(36)
                                color: root.selectedKeyId === root.keyId(modelData) ? VfTheme.blueFill : VfTheme.surface
                                border.color: VfTheme.border

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(10)
                                    anchors.rightMargin: VfTheme.dp(10)
                                    spacing: 0

                                    BodyCell { Layout.preferredWidth: root.keyNameColumnWidth; text: root.keyLabel(modelData) }
                                    BodyCell { Layout.fillWidth: true; text: root.maskedKey(modelData) }
                                    StatusCell {
                                        Layout.preferredWidth: root.keyStatusColumnWidth
                                        text: root.keyLastUsed(modelData) === "" ? (void i18n.revision, i18n.t("billing.status_idle", "Idle")) : (void i18n.revision, i18n.t("billing.status_active", "Active"))
                                        active: root.keyLastUsed(modelData) !== ""
                                    }
                                    BodyCell { Layout.preferredWidth: root.keySpendColumnWidth; text: root.moneyText(root.keySpend(modelData)); horizontalAlignment: Text.AlignRight }
                                    BodyCell { Layout.preferredWidth: root.keyLastUsedColumnWidth; text: root.keyLastUsedText(modelData); horizontalAlignment: Text.AlignRight }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.selectedKeyId = root.keyId(modelData)
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: (root.keys || []).length === 0
                            text: (void i18n.revision, i18n.t("billing.no_keys", "Chưa có Gemini key."))
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                // Usage / chi phí — fill left when not personal keys
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: VfTheme.dp(8)
                    color: VfTheme.surface
                    border.color: VfTheme.border
                    clip: true
                    visible: root.apiMode !== "personal"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(30)
                            color: VfTheme.surfaceSoft

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(10)
                                anchors.rightMargin: VfTheme.dp(10)
                                spacing: VfTheme.dp(8)

                                Text {
                                    text: (void i18n.revision, i18n.t("billing.recent_cost", "Chi phí / tiêu thụ"))
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(11)
                                    font.weight: Font.Bold
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: root.usageRowCount + " " + (void i18n.revision, i18n.t("billing.usage_rows_count", "dòng"))
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(26)
                            color: VfTheme.surfaceSoft
                            opacity: 0.85

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(10)
                                anchors.rightMargin: VfTheme.dp(10)
                                spacing: 0

                                HeaderCell { Layout.preferredWidth: VfTheme.dp(150); text: (void i18n.revision, i18n.t("billing.col_model", "Model")) }
                                HeaderCell { Layout.fillWidth: true; text: (void i18n.revision, i18n.t("billing.col_task", "Tác vụ")) }
                                HeaderCell { Layout.preferredWidth: VfTheme.dp(64); text: (void i18n.revision, i18n.t("billing.col_requests", "Req")); horizontalAlignment: Text.AlignRight }
                                HeaderCell { Layout.preferredWidth: VfTheme.dp(100); text: (void i18n.revision, i18n.t("billing.col_cost", "Chi phí")); horizontalAlignment: Text.AlignRight }
                                HeaderCell { Layout.preferredWidth: VfTheme.dp(84); text: (void i18n.revision, i18n.t("billing.col_source", "Nguồn")); horizontalAlignment: Text.AlignRight }
                            }
                        }

                        ListView {
                            id: usageTableLeft
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            reuseItems: true
                            model: root.usageRowsModel()
                            boundsBehavior: Flickable.StopAtBounds
                            interactive: contentHeight > height
                            ScrollBar.vertical: ScrollBar {
                                policy: usageTableLeft.contentHeight > usageTableLeft.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                            }

                            delegate: Rectangle {
                                id: usageRowLeft
                                required property int index
                                required property var modelData
                                width: usageTableLeft.width
                                height: VfTheme.dp(28)
                                color: usageRowLeft.index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(10)
                                    anchors.rightMargin: VfTheme.dp(10)
                                    spacing: 0

                                    BodyCell { Layout.preferredWidth: VfTheme.dp(150); text: String(usageRowLeft.modelData.model || "Gateway") }
                                    BodyCell { Layout.fillWidth: true; text: String(usageRowLeft.modelData.task || "Usage") }
                                    BodyCell {
                                        Layout.preferredWidth: VfTheme.dp(64)
                                        text: Number(usageRowLeft.modelData.requests || 0) > 0
                                            ? root.numberText(usageRowLeft.modelData.requests)
                                            : "—"
                                        horizontalAlignment: Text.AlignRight
                                    }
                                    BodyCell {
                                        Layout.preferredWidth: VfTheme.dp(100)
                                        text: root.moneyText(usageRowLeft.modelData.cost)
                                        horizontalAlignment: Text.AlignRight
                                    }
                                    BodyCell {
                                        Layout.preferredWidth: VfTheme.dp(84)
                                        text: String(usageRowLeft.modelData.source || "Gateway")
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(48)
                            visible: root.usageRowCount === 0
                            text: (void i18n.revision, i18n.t("billing.no_cost_data", "Gateway chưa trả về dữ liệu chi phí."))
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                // Personal key form — only when personal
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(82)
                    radius: VfTheme.dp(8)
                    color: VfTheme.surfaceSoft
                    border.color: VfTheme.violetBorderSoft
                    visible: root.apiMode === "personal"

                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(10)
                        columns: 3
                        columnSpacing: VfTheme.dp(8)
                        rowSpacing: VfTheme.dp(6)

                        FieldLabel { text: (void i18n.revision, i18n.t("billing.key_name", "Tên key")) }
                        FieldLabel { text: (void i18n.revision, i18n.t("billing.gemini_api_key", "Gemini API key")) }
                        Item { Layout.preferredWidth: VfTheme.dp(150) }

                        TextField {
                            id: labelInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(32)
                            placeholderText: (void i18n.revision, i18n.t("billing.key_name_placeholder", "Key chính"))
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            background: FieldBackground { active: labelInput.activeFocus }
                        }

                        TextField {
                            id: keyInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(32)
                            placeholderText: "AIza..."
                            echoMode: TextInput.PasswordEchoOnEdit
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            background: FieldBackground { active: keyInput.activeFocus }
                        }

                        RowLayout {
                            Layout.preferredWidth: VfTheme.dp(150)
                            spacing: VfTheme.dp(6)

                            VfButton {
                                text: (void i18n.revision, i18n.t("billing.check", "Kiểm tra"))
                                compact: true
                                minWidth: VfTheme.dp(68)
                                onClicked: root.checkKey()
                            }

                            VfButton {
                                text: (void i18n.revision, i18n.t("billing.save_key", "Lưu key"))
                                tone: "primary"
                                compact: true
                                iconName: "check-mark-button"
                                minWidth: VfTheme.dp(74)
                                onClicked: root.saveKey()
                            }
                        }
                    }
                }
            }

            // RIGHT — thanh toán cố định
            SurfacePanel {
                visible: root.creditTopupAvailable || root.hasPayment
                Layout.preferredWidth: VfTheme.dp(340)
                Layout.maximumWidth: VfTheme.dp(360)
                Layout.minimumWidth: VfTheme.dp(300)
                Layout.fillWidth: false
                Layout.fillHeight: true
                title: (void i18n.revision, i18n.t("billing.topup_panel_title", "Nạp tiền & thanh toán"))
                iconName: "credit-card"

                Rectangle {
                    visible: !root.hasPayment
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(54)
                    radius: VfTheme.dp(8)
                    color: VfTheme.surfaceSoft
                    border.color: VfTheme.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: VfTheme.dp(10)
                        anchors.rightMargin: VfTheme.dp(10)
                        spacing: VfTheme.dp(9)

                        VfAppIcon {
                            name: "credit-card"
                            size: VfTheme.dp(18)
                            framed: false
                            color: "#2563EB"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(1)

                            Text {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("billing.payment_order", "Lệnh thanh toán"))
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("billing.payment_hint", "QR và thông tin chuyển khoản sẽ hiện sau khi bấm Nạp tiền."))
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            text: root.moneyText(root.topupWireVnd)
                            color: VfTheme.greenText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }
                    }
                }

                ColumnLayout {
                    visible: root.creditTopupAvailable && !root.hasPayment
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(8)

                    FieldLabel { text: (void i18n.revision, i18n.t("billing.choose_amount", "Chọn số tiền")) }

                    Flow {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(7)

                        Repeater {
                            model: root.amountPresets

                            VfChip {
                                required property int modelData
                                text: root.displayCurrency === "USD"
                                    ? "$" + modelData
                                    : (modelData >= 1000000 ? "1M" : (modelData / 1000) + "K")
                                selected: root.selectedAmount === modelData
                                accent: "#16A34A"
                                minWidth: VfTheme.dp(72)
                                iconName: "money-bag"
                                onClicked: root.selectedAmount = modelData
                            }
                        }
                    }

                    TextField {
                        id: amountInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(34)
                        text: String(root.selectedAmount)
                        placeholderText: (void i18n.revision, i18n.t("billing.custom_amount", "Số tiền tùy chỉnh"))
                        color: VfTheme.text
                        placeholderTextColor: VfTheme.textSubtle
                        selectionColor: "#2563EB"
                        selectedTextColor: "#FFFFFF"
                        validator: IntValidator { bottom: root.minDisplayAmount; top: root.maxDisplayAmount }
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        font.weight: Font.DemiBold
                        onEditingFinished: {
                            if (text.length > 0)
                                root.selectedAmount = Math.max(root.minDisplayAmount, Number(text))
                        }
                        background: FieldBackground { active: amountInput.activeFocus }
                    }
                }

                ColumnLayout {
                    visible: root.creditTopupAvailable && !root.hasPayment
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(8)

                    FieldLabel { text: (void i18n.revision, i18n.t("billing.method", "Phương thức")) }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)

                        MethodButton { text: "Bank"; value: "BANK_TRANSFER"; iconName: "credit-card" }
                        MethodButton { text: "USDT"; value: "USDT"; iconName: "globe-with-meridians" }
                    }
                }

                VfButton {
                    visible: root.creditTopupAvailable && !root.hasPayment
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("billing.topup_button", "Nạp tiền"))
                    tone: "green"
                    iconName: "money-bag"
                    enabled: !root.busy && root.showTopup
                    tooltip: root.showTopup
                        ? ((void i18n.revision, i18n.t("billing.topup_tooltip_prefix", "Tạo lệnh nạp ")) + root.moneyText(root.topupWireVnd) + (void i18n.revision, i18n.t("billing.topup_tooltip_via", " qua ")) + root.selectedMethod)
                        : (void i18n.revision, i18n.t("billing.topup_need_server", "Chọn API Server để nạp tiền gateway"))
                    onClicked: root.topup()
                }

                Text {
                    visible: root.creditTopupAvailable && !root.showTopup && !root.hasPayment
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: (void i18n.revision, i18n.t("billing.topup_only_server_note", "Nạp tiền chỉ dùng khi nguồn = API Server (số dư gateway)."))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                }

                Item {
                    // Đẩy form nạp lên trên — panel phải luôn đầy chiều cao
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: !root.hasPayment
                }

                Rectangle {
                    visible: root.hasPayment
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: root.hasPayment ? VfTheme.dp(286) : 0
                    radius: VfTheme.dp(8)
                    color: VfTheme.amberFill
                    border.color: VfTheme.amberBorderSoft

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(10)
                        spacing: VfTheme.dp(8)

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: VfTheme.dp(190)
                            Layout.preferredHeight: VfTheme.dp(190)
                            radius: VfTheme.dp(10)
                            color: VfTheme.surface
                            border.color: VfTheme.amberBorderSoft
                            clip: true

                            Image {
                                id: paymentQrImage
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(8)
                                source: root.paymentQrUrl
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                visible: root.paymentQrUrl.length > 0 && status !== Image.Error
                            }

                            ColumnLayout {
                                anchors.centerIn: parent
                                visible: !paymentQrImage.visible
                                spacing: VfTheme.dp(3)

                                VfAppIcon {
                                    Layout.alignment: Qt.AlignHCenter
                                    name: "credit-card"
                                    size: VfTheme.dp(24)
                                    framed: false
                                    color: "#D97706"
                                }

                                Text {
                                    text: "QR"
                                    color: VfTheme.amberText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    font.weight: Font.Bold
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: root.paymentQrUrl.length > 0
                                cursorShape: Qt.PointingHandCursor
                                onClicked: qrPreviewDialog.open()
                            }
                        }

                        VfButton {
                            Layout.fillWidth: true
                            visible: root.supportUrl.length > 0
                            text: (void i18n.revision, i18n.t("billing.notify_support", "Đã chuyển — Liên hệ hỗ trợ"))
                            tone: "primary"
                            iconName: "loudspeaker"
                            onClicked: {
                                root.externalUrlRequested(root.supportUrl)
                                root.statusText = (void i18n.revision, i18n.t("billing.notify_support_status", "Đã mở kênh hỗ trợ — gửi mã đơn này để được xác nhận: ")) + root.orderCode
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(8)

                            Text {
                                Layout.fillWidth: true
                                text: root.orderCode
                                color: VfTheme.amberText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                font.weight: Font.Bold
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }

                            StatusCell {
                                Layout.preferredWidth: VfTheme.dp(82)
                                text: root.paymentStatus || "pending"
                                active: !root.paymentPending
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.paymentAmount + " - " + root.paymentMethod
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: VfTheme.dp(7)
                            color: VfTheme.surface
                            border.color: VfTheme.amberBorderSoft
                            clip: true

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(8)
                                spacing: VfTheme.dp(3)

                                Repeater {
                                    model: root.paymentFieldsModel()
                                    delegate: RowLayout {
                                        id: paymentFieldRow
                                        required property var modelData
                                        width: parent ? parent.width : 0
                                        spacing: VfTheme.dp(6)

                                        Text {
                                            Layout.preferredWidth: VfTheme.dp(92)
                                            text: String(paymentFieldRow.modelData.label || "")
                                            color: VfTheme.textSubtle
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(10)
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: String(paymentFieldRow.modelData.value || "")
                                            color: VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(10)
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                Layout.fillWidth: true
                                text: root.paymentPolling
                                    ? (void i18n.revision, i18n.t("billing.checking_payment", "Đang kiểm tra trạng thái thanh toán..."))
                                    : (root.paymentPending ? (void i18n.revision, i18n.t("billing.auto_refresh_note", "Tự động cập nhật trạng thái mỗi 3 giây. Click QR để phóng to.")) : (void i18n.revision, i18n.t("billing.order_updated", "Lệnh đã được cập nhật.")))
                                color: VfTheme.amberText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                elide: Text.ElideRight
                            }

                            VfButton {
                                text: (void i18n.revision, i18n.t("common.refresh", "Làm mới"))
                                compact: true
                                iconName: "clockwise-arrows"
                                minWidth: VfTheme.dp(86)
                                enabled: !root.paymentPolling
                                onClicked: root.paymentPollRequested(root.orderCode)
                            }
                        }
                    }
                }
            }
        }

        } // bodyColumn

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(48)
            Layout.leftMargin: 1
            Layout.rightMargin: 1
            Layout.bottomMargin: 1
            color: "transparent"
            border.width: 0

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 1
                color: VfTheme.border
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(24)
                anchors.rightMargin: VfTheme.dp(24)
                spacing: VfTheme.dp(8)

                BusyIndicator {
                    running: root.busy
                    visible: root.busy
                    implicitWidth: VfTheme.dp(22)
                    implicitHeight: VfTheme.dp(22)
                }

                Text {
                    Layout.fillWidth: true
                    text: root.busy ? (root.actionProgressText || (void i18n.revision, i18n.t("billing.processing", "Đang xử lý..."))) : (root.statusText || (void i18n.revision, i18n.t("billing.ready", "Sẵn sàng")))
                    color: String(text).indexOf("failed") >= 0 || String(text).indexOf("Error") >= 0 ? "#DC2626" : VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    elide: Text.ElideRight
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.refresh", "Làm mới"))
                    iconName: "clockwise-arrows"
                    minWidth: VfTheme.dp(88)
                    enabled: !root.busy
                    onClicked: {
                        root.refreshRequested()
                        root.actionRequested("commerce_load_store", "")
                    }
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("billing.delete_key", "Xóa key"))
                    tone: "danger"
                    iconName: "cross-mark"
                    minWidth: VfTheme.dp(88)
                    enabled: !root.busy
                    onClicked: root.requestDeleteKey()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("billing.token_monitor", "Theo dõi token"))
                    iconName: "money-bag"
                    minWidth: VfTheme.dp(120)
                    onClicked: root.actionRequested("status_token", "")
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Đóng"))
                    iconName: "cross-mark"
                    minWidth: VfTheme.dp(76)
                    onClicked: root.close()
                }
            }
        }
    }

    component MetricCard: Rectangle {
        id: metricCard
        property string label: ""
        property string value: ""
        property string iconName: ""
        property color accent: "#2563EB"
        property color fill: VfTheme.blueFill
        property color stroke: VfTheme.blueBorderSoft

        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(58)
        implicitHeight: VfTheme.dp(58)
        radius: VfTheme.dp(8)
        color: fill
        border.color: stroke

        RowLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(10)
            spacing: VfTheme.dp(8)

            VfAppIcon {
                name: metricCard.iconName
                size: VfTheme.dp(20)
                framed: false
                color: metricCard.accent
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(1)

                Text {
                    Layout.fillWidth: true
                    text: metricCard.label
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: metricCard.value
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(15)
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
            }
        }
    }

    component SurfacePanel: Rectangle {
        id: panelRoot
        default property alias content: panelContent.data
        property string title: ""
        property string iconName: ""

        radius: VfTheme.dp(8)
        color: VfTheme.surface
        border.color: VfTheme.borderBox

        ColumnLayout {
            id: panelContent
            anchors.fill: parent
            anchors.margins: VfTheme.dp(12)
            spacing: VfTheme.dp(10)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(7)

                VfAppIcon {
                    name: panelRoot.iconName
                    size: VfTheme.dp(16)
                    framed: false
                    color: "#2563EB"
                    visible: panelRoot.iconName.length > 0
                }

                Text {
                    Layout.fillWidth: true
                    text: panelRoot.title
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(14)
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
            }
        }
    }

    component HeaderCell: Text {
        color: VfTheme.textMuted
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(10)
        font.weight: Font.Bold
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    component BodyCell: Text {
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(11)
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    component StatusCell: Item {
        property string text: ""
        property bool active: false

        Layout.preferredHeight: VfTheme.dp(24)

        StatusPill {
            width: Math.max(VfTheme.dp(48), Math.min(parent.width - VfTheme.dp(8), VfTheme.dp(86)))
            height: VfTheme.dp(22)
            anchors.centerIn: parent
            text: parent.text
            active: parent.active
        }
    }

    component FieldLabel: Text {
        color: VfTheme.textSubtle
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(10)
        font.weight: Font.Bold
    }

    component FieldBackground: Rectangle {
        property bool active: false
        radius: VfTheme.dp(7)
        color: VfTheme.surface
        border.color: active ? "#2563EB" : VfTheme.borderStrong
    }

    component ModeButton: Rectangle {
        id: modeButton
        property string text: ""
        property string value: ""
        property string hint: ""
        readonly property bool active: root.apiMode === value

        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(34)
        Layout.minimumWidth: VfTheme.dp(88)
        radius: VfTheme.dp(7)
        color: active ? "#2563EB" : (modeMouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface)
        border.color: active ? "#1D4ED8" : (modeMouse.containsMouse ? VfTheme.blueBorderSoft : VfTheme.borderStrong)
        border.width: active ? 2 : 1

        Text {
            anchors.centerIn: parent
            width: parent.width - VfTheme.dp(8)
            horizontalAlignment: Text.AlignHCenter
            text: modeButton.text
            color: modeButton.active ? "#FFFFFF" : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
            font.weight: Font.Bold
            elide: Text.ElideRight
        }

        MouseArea {
            id: modeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.setMode(modeButton.value)
        }

        ToolTip.visible: modeMouse.containsMouse
        ToolTip.text: hint
        ToolTip.delay: 450
    }

    component StatusPill: Rectangle {
        property string text: ""
        property bool active: false

        Layout.preferredHeight: VfTheme.dp(22)
        radius: VfTheme.dp(11)
        color: active ? VfTheme.greenFill : VfTheme.surfaceSoft
        border.color: active ? VfTheme.greenBorderSoft : VfTheme.borderStrong

        Text {
            anchors.centerIn: parent
            text: parent.text
            color: parent.active ? VfTheme.greenText : VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            font.weight: Font.Bold
        }
    }

    component MethodButton: Rectangle {
        id: methodButton
        property string text: ""
        property string value: ""
        property string iconName: ""
        readonly property bool active: root.selectedMethod === value

        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(34)
        radius: VfTheme.dp(7)
        color: active ? VfTheme.greenFill : VfTheme.surface
        border.color: active ? "#10B981" : VfTheme.borderStrong

        Row {
            anchors.centerIn: parent
            spacing: VfTheme.dp(6)

            VfAppIcon {
                name: methodButton.iconName
                size: VfTheme.dp(15)
                framed: false
                color: methodButton.active ? VfTheme.greenText : VfTheme.textMuted
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: methodButton.text
                color: methodButton.active ? VfTheme.greenText : VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: methodMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.selectedMethod = methodButton.value
        }

        ToolTip.visible: methodMouse.containsMouse
        ToolTip.text: methodButton.value === "USDT" ? (void i18n.revision, i18n.t("billing.method_usdt_tooltip", "Tạo lệnh nạp bằng USDT nếu backend đã cấu hình ví.")) : (void i18n.revision, i18n.t("billing.method_bank_tooltip", "Tạo lệnh chuyển khoản ngân hàng."))
        ToolTip.delay: 450
    }
}
