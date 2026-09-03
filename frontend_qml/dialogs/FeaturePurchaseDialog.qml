import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import "../components"
import "../theme"

Dialog {
    id: root

    property var payload: ({})
    property var catalog: []
    property string triggerRoute: ""
    property string selectedFeatureCode: ""
    property int selectedDays: 30
    property string selectedMethod: "BANK_TRANSFER"
    property bool busy: false
    property bool paymentPolling: false
    property double paymentPollStartedAtMs: 0
    property bool paymentPollExpired: false
    property int entitlementRevision: 0
    property var featureStateProvider: null

    signal buyRequested(string featureCode, int days, string paymentMethod)
    signal paymentPollRequested(string orderCode)
    signal refreshRequested()
    signal openFeatureRequested(string route)
    signal dismissed()

    readonly property var payment: root.payload && root.payload.payment
        ? root.payload.payment : ({})
    readonly property string orderCode: String(root.payment.order_code || root.payment.code || "")
    readonly property bool hasOrder: root.orderCode.length > 0
    readonly property string paymentStatus: String(root.payment.status || (root.hasOrder ? "pending" : "")).toLowerCase()
    readonly property bool paymentPending: root.hasOrder
        && ["completed", "expired", "cancelled", "failed"].indexOf(root.paymentStatus) < 0
    readonly property bool accessReady: root.paymentStatus === "completed"
        && String(root.payment.entitlement_refresh_status || "") === "ready"
    readonly property var selectedFeature: root.featureByCode(root.selectedFeatureCode)
    readonly property bool selectedFeatureOwned: root.featureOwned(root.selectedFeatureCode)
    readonly property int monthlyPriceVnd: Math.ceil(Number(root.selectedFeature.monthly_price_vnd || 0))
    readonly property int uncappedPriceVnd: {
        if (root.monthlyPriceVnd <= 0)
            return 0
        var base = Math.ceil(root.monthlyPriceVnd * root.selectedDays / 30)
        return Math.ceil(Math.ceil(base * 1.5) / 1000) * 1000
    }
    readonly property int estimatedPriceVnd: root.uncappedPriceVnd > 0
        ? Math.min(root.uncappedPriceVnd, root.monthlyPriceVnd)
        : 0
    readonly property bool priceCapped: root.monthlyPriceVnd > 0
        && root.uncappedPriceVnd >= root.monthlyPriceVnd
    readonly property int lockedOrderDays: Number(root.payment.days || root.selectedDays)
    readonly property real lockedOrderAmount: Number(
        root.payment.total_amount || root.payment.total || root.payment.amount || root.estimatedPriceVnd || 0)
    readonly property string paymentQrUrl: String(root.payment.qr_url || "")

    parent: Overlay.overlay
    modal: true
    focus: true
    width: VfDialogMetrics.width(parent, VfTheme.dp(980), VfTheme.dp(32))
    height: VfDialogMetrics.height(parent, VfTheme.dp(680), VfTheme.dp(32))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    closePolicy: Popup.CloseOnEscape

    background: Rectangle {
        radius: VfTheme.dp(12)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("feature_purchase.title", "Mở khóa tính năng"))
        subtitle: (void i18n.revision, i18n.t("feature_purchase.subtitle", "Chọn tính năng và thời hạn phù hợp."))
        iconName: "key"
        onCloseClicked: root.close()
    }

    onClosed: {
        root.paymentPollExpired = false
        root.dismissed()
    }

    onPayloadChanged: root.syncPayload()

    Timer {
        interval: Qt.application.state === Qt.ApplicationActive ? 3000 : 12000
        repeat: true
        running: root.visible && root.paymentPending && !root.paymentPolling
                 && !root.paymentPollExpired
        onTriggered: {
            if (root.paymentPollStartedAtMs > 0
                    && Date.now() - root.paymentPollStartedAtMs >= 15 * 60 * 1000) {
                root.paymentPollExpired = true
                return
            }
            root.paymentPollRequested(root.orderCode)
        }
    }

    Connections {
        target: root.featureStateProvider
        function onFeatureStatesChanged() {
            root.entitlementRevision += 1
            root.syncPayload()
        }
    }

    function syncPayload() {
        var incoming = root.payload || {}
        var rows = incoming.store_features || []
        if (rows.length > 0)
            root.catalog = rows

        var code = String((incoming.payment || {}).feature_code
                          || incoming.selected_feature_code
                          || root.routeFeatureCode(root.triggerRoute)
                          || root.selectedFeatureCode).toUpperCase()
        if (code.length > 0)
            root.selectedFeatureCode = code

        if (root.orderCode.length > 0) {
            if (Number(root.payment.days || 0) > 0)
                root.selectedDays = Number(root.payment.days)
            root.selectedMethod = "BANK_TRANSFER"
            if (root.paymentPollStartedAtMs <= 0)
                root.paymentPollStartedAtMs = Date.now()
        } else {
            root.paymentPollStartedAtMs = 0
            root.paymentPollExpired = false
            var purchasableCode = root.firstPurchasableFeatureCode()
            if (!root.selectedFeatureCode.length && root.catalog.length > 0) {
                root.selectedFeatureCode = purchasableCode.length > 0
                    ? purchasableCode
                    : String((root.catalog[0] || {}).feature_code || "").toUpperCase()
            } else if (root.featureOwned(root.selectedFeatureCode) && purchasableCode.length > 0) {
                root.selectedFeatureCode = purchasableCode
            }
        }
    }

    function openForRoute(data, route) {
        root.triggerRoute = String(route || (data || {}).route || "")
        root.payload = data || ({})
        var code = root.routeFeatureCode(root.triggerRoute)
        if (code.length > 0 && !root.hasOrder)
            root.selectedFeatureCode = code
        root.syncPayload()
        root.open()
    }

    function routeFeatureCode(route) {
        var map = {
            master: "MASTER_PANEL",
            clone: "CLONE_PANEL",
            transcript: "TRANSCRIPT_PANEL",
            research: "DEEP_RESEARCH",
            normal: "NORMAL_PANEL",
            extend: "EXTEND_PANEL",
            timemachine: "TIME_MACHINE",
            batch: "IMAGE_PANEL",
            voice: "VOICE_STUDIO",
            affiliate: "AFFILIATE_PANEL"
        }
        return String(map[String(route || "").toLowerCase()] || "")
    }

    function routeForFeature(code) {
        var target = String(code || "").toUpperCase()
        var map = {
            MASTER_PANEL: "master",
            CLONE_PANEL: "clone",
            TRANSCRIPT_PANEL: "transcript",
            DEEP_RESEARCH: "research",
            NORMAL_PANEL: "normal",
            EXTEND_PANEL: "extend",
            TIME_MACHINE: "timemachine",
            IMAGE_PANEL: "batch",
            VOICE_STUDIO: "voice",
            AFFILIATE_PANEL: "affiliate"
        }
        return String(map[target] || root.triggerRoute || "")
    }

    function featureByCode(code) {
        var target = String(code || "").toUpperCase()
        var rows = root.catalog || []
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i] || {}
            if (String(row.feature_code || "").toUpperCase() === target)
                return row
        }
        return ({ feature_code: target, name: root.fallbackFeatureName(target) })
    }

    function featureOwned(code) {
        void root.entitlementRevision
        var knownCodes = [
            "MASTER_PANEL", "CLONE_PANEL", "TRANSCRIPT_PANEL", "DEEP_RESEARCH",
            "NORMAL_PANEL", "EXTEND_PANEL", "TIME_MACHINE", "IMAGE_PANEL",
            "VOICE_STUDIO", "AFFILIATE_PANEL"
        ]
        if (knownCodes.indexOf(String(code || "").toUpperCase()) < 0)
            return false
        var route = root.routeForFeature(code)
        if (!route.length || !root.featureStateProvider)
            return false
        var state = root.featureStateProvider.featureTabState(route) || ({})
        return state.enabled === true || String(state.badge || "") === "Bảo trì"
    }

    function firstPurchasableFeatureCode() {
        var rows = root.catalog || []
        for (var i = 0; i < rows.length; i++) {
            var code = String((rows[i] || {}).feature_code || "").toUpperCase()
            if (code.length > 0 && !root.featureOwned(code))
                return code
        }
        return ""
    }

    function fallbackFeatureName(code) {
        var names = {
            MASTER_PANEL: "MASTER PROMPT",
            CLONE_PANEL: "CLONE VIDEO",
            TRANSCRIPT_PANEL: "AUDIO TO VIDEO",
            DEEP_RESEARCH: "RESEARCH LABS",
            NORMAL_PANEL: "NORMAL PANEL",
            EXTEND_PANEL: "EXTEND PANEL",
            TIME_MACHINE: "TIME MACHINE",
            IMAGE_PANEL: "BATCH IMAGE",
            VOICE_STUDIO: "VOICE STUDIO",
            AFFILIATE_PANEL: "AFFILIATE"
        }
        return String(names[String(code || "").toUpperCase()] || code
                      || (void i18n.revision, i18n.t("feature_purchase.default_feature", "Tính năng")))
    }

    function featureIcon(code) {
        var target = String(code || "").toUpperCase()
        if (target === "CLONE_PANEL" || target === "TRANSCRIPT_PANEL")
            return "video-camera"
        if (target === "VOICE_STUDIO")
            return "music"
        if (target === "MASTER_PANEL")
            return "robot"
        if (target === "DEEP_RESEARCH")
            return "magnifying-glass"
        return "package"
    }

    function featureAccent(code) {
        var target = String(code || "").toUpperCase()
        if (target === "CLONE_PANEL") return "#7C3AED"
        if (target === "TRANSCRIPT_PANEL" || target === "VOICE_STUDIO") return "#0891B2"
        if (target === "AFFILIATE_PANEL") return "#D97706"
        if (target === "NORMAL_PANEL") return "#059669"
        return "#2563EB"
    }

    function featureBenefits(code) {
        var target = String(code || "").toUpperCase()
        if (target === "MASTER_PANEL")
            return [
                (void i18n.revision, i18n.t("feature_purchase.master_benefit_1", "Lập kế hoạch cảnh chi tiết")),
                (void i18n.revision, i18n.t("feature_purchase.master_benefit_2", "Giữ nhất quán nhân vật")),
                (void i18n.revision, i18n.t("feature_purchase.master_benefit_3", "Tối ưu prompt theo model"))
            ]
        if (target === "CLONE_PANEL")
            return [
                (void i18n.revision, i18n.t("feature_purchase.clone_benefit_1", "Phân tích video nguồn")),
                (void i18n.revision, i18n.t("feature_purchase.clone_benefit_2", "Dựng cấu trúc theo từng cảnh")),
                (void i18n.revision, i18n.t("feature_purchase.clone_benefit_3", "Tạo prompt bám sát nội dung"))
            ]
        if (target === "TRANSCRIPT_PANEL")
            return [
                (void i18n.revision, i18n.t("feature_purchase.transcript_benefit_1", "Tách nội dung từ âm thanh")),
                (void i18n.revision, i18n.t("feature_purchase.transcript_benefit_2", "Lập cảnh theo lời thoại")),
                (void i18n.revision, i18n.t("feature_purchase.transcript_benefit_3", "Tạo video đồng bộ nội dung"))
            ]
        if (target === "VOICE_STUDIO")
            return [
                (void i18n.revision, i18n.t("feature_purchase.voice_benefit_1", "Tạo giọng đọc chất lượng cao")),
                (void i18n.revision, i18n.t("feature_purchase.voice_benefit_2", "Quản lý nhiều giọng đọc")),
                (void i18n.revision, i18n.t("feature_purchase.voice_benefit_3", "Xuất audio theo từng đoạn"))
            ]
        return [
            (void i18n.revision, i18n.t("feature_purchase.generic_benefit_1", "Mở đầy đủ công cụ")),
            (void i18n.revision, i18n.t("feature_purchase.generic_benefit_2", "Sử dụng theo thời hạn đã mua")),
            (void i18n.revision, i18n.t("feature_purchase.generic_benefit_3", "Tự cập nhật quyền sau thanh toán"))
        ]
    }

    function moneyText(value) {
        var amount = Math.max(0, Math.round(Number(value || 0)))
        return amount.toLocaleString(Qt.locale("vi_VN"), "f", 0) + " VND"
    }

    function statusText(status) {
        var value = String(status || "").toLowerCase()
        if (!value) return (void i18n.revision, i18n.t("feature_purchase.not_created", "Chưa tạo đơn"))
        if (value === "owned")
            return (void i18n.revision, i18n.t("feature_purchase.owned", "Đã mua"))
        if (value === "completed") {
            return root.accessReady
                ? (void i18n.revision, i18n.t("feature_purchase.access_ready", "Đã mở khóa"))
                : (void i18n.revision, i18n.t("feature_purchase.updating_access", "Đang cập nhật quyền"))
        }
        if (value === "pending" || value === "waiting_payment")
            return (void i18n.revision, i18n.t("feature_purchase.waiting_payment", "Chờ thanh toán"))
        if (value === "expired")
            return (void i18n.revision, i18n.t("feature_purchase.expired", "Đã hết hạn"))
        if (value === "cancelled")
            return (void i18n.revision, i18n.t("feature_purchase.cancelled", "Đã hủy"))
        if (value === "failed")
            return (void i18n.revision, i18n.t("feature_purchase.failed", "Thanh toán lỗi"))
        return value
    }

    function statusTone(status) {
        var value = String(status || "").toLowerCase()
        if (value === "locked") return "amber"
        if (value === "completed" || value === "owned") return "green"
        if (["expired", "cancelled", "failed"].indexOf(value) >= 0) return "red"
        if (value.length > 0) return "amber"
        return "neutral"
    }

    function paymentRows() {
        var p = root.payment || {}
        var rows = [{
            label: (void i18n.revision, i18n.t("feature_purchase.bank", "Ngân hàng")),
            value: String(p.bank_name || p.bank_code || "—")
        }, {
            label: (void i18n.revision, i18n.t("feature_purchase.account_number", "Số tài khoản")),
            value: String(p.account_number || p.bank_account_number || "—")
        }, {
            label: (void i18n.revision, i18n.t("feature_purchase.account_name", "Chủ tài khoản")),
            value: String(p.account_name || p.bank_account_name || "—")
        }]
        rows.push({
            label: (void i18n.revision, i18n.t("feature_purchase.transfer_note", "Nội dung")),
            value: String(p.payment_code || root.orderCode || "—")
        })
        rows.push({
            label: (void i18n.revision, i18n.t("feature_purchase.payment_expires", "Hết hạn")),
            value: String(p.payment_expires_at || p.expires_at || "—")
        })
        return rows
    }

    contentItem: RowLayout {
        spacing: 0

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(316)
            Layout.fillHeight: true
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(14)
                spacing: VfTheme.dp(10)

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("feature_purchase.paid_features", "Tính năng trả phí"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        implicitWidth: countText.implicitWidth + VfTheme.dp(12)
                        implicitHeight: VfTheme.dp(22)
                        radius: height / 2
                        color: VfTheme.blueFill
                        border.color: VfTheme.blueBorderSoft

                        Text {
                            id: countText
                            anchors.centerIn: parent
                            text: String((root.catalog || []).length)
                            color: VfTheme.blueText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            font.weight: Font.Bold
                        }
                    }
                }

                ScrollView {
                    id: featureScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical: ThinScrollBar {}

                    Column {
                        width: featureScroll.availableWidth
                        spacing: VfTheme.dp(9)

                        Repeater {
                            model: root.catalog || []

                            delegate: Rectangle {
                                id: featureCard
                                required property var modelData
                                readonly property string code: String(modelData.feature_code || "").toUpperCase()
                                readonly property bool selected: featureCard.code === root.selectedFeatureCode
                                readonly property bool owned: root.featureOwned(featureCard.code)
                                width: parent ? parent.width : 0
                                height: VfTheme.dp(86)
                                radius: VfTheme.dp(10)
                                color: owned ? VfTheme.greenFill
                                                : selected ? VfTheme.blueFill
                                                : (featureMouse.containsMouse ? VfTheme.surface : VfTheme.surfaceSoft)
                                border.color: owned ? VfTheme.greenBorderSoft
                                                       : selected ? root.featureAccent(code)
                                                       : (featureMouse.containsMouse ? VfTheme.borderStrong : VfTheme.border)
                                border.width: selected ? 2 : 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(11)
                                    spacing: VfTheme.dp(10)

                                    Rectangle {
                                        Layout.preferredWidth: VfTheme.dp(38)
                                        Layout.preferredHeight: VfTheme.dp(38)
                                        Layout.alignment: Qt.AlignTop
                                        radius: VfTheme.dp(10)
                                        color: selected ? "#FFFFFF" : VfTheme.surface
                                        border.color: featureCard.owned ? VfTheme.greenBorderSoft
                                                                      : (selected ? root.featureAccent(featureCard.code) : VfTheme.border)

                                        VfAppIcon {
                                            anchors.centerIn: parent
                                            name: root.featureIcon(featureCard.code)
                                            size: VfTheme.dp(20)
                                            framed: false
                                            color: featureCard.owned ? VfTheme.greenText
                                                                     : root.featureAccent(featureCard.code)
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: VfTheme.dp(3)

                                        Text {
                                            Layout.fillWidth: true
                                            text: String(featureCard.modelData.name || root.fallbackFeatureName(featureCard.code))
                                            color: VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(11)
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            text: String(featureCard.modelData.description
                                                         || (void i18n.revision, i18n.t("feature_purchase.full_access", "Mở đầy đủ quyền sử dụng tính năng.")))
                                            color: VfTheme.textMuted
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(9)
                                            wrapMode: Text.WordWrap
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: featureCard.owned
                                                ? (void i18n.revision, i18n.t("feature_purchase.owned", "Đã mua"))
                                                : root.moneyText(featureCard.modelData.monthly_price_vnd)
                                                  + (void i18n.revision, i18n.t("feature_purchase.per_month", " / tháng"))
                                            color: featureCard.owned ? VfTheme.greenText
                                                                     : root.featureAccent(featureCard.code)
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(10)
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                MouseArea {
                                    id: featureMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: !featureCard.owned && !root.hasOrder && !root.busy
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: root.selectedFeatureCode = featureCard.code
                                }
                            }
                        }

                        Column {
                            width: parent ? parent.width : 0
                            visible: (root.catalog || []).length === 0
                            spacing: VfTheme.dp(10)
                            topPadding: VfTheme.dp(38)

                            BusyIndicator {
                                anchors.horizontalCenter: parent.horizontalCenter
                                running: root.busy
                                visible: root.busy
                            }

                            Text {
                                width: parent ? parent.width : 0
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                text: root.busy
                                    ? (void i18n.revision, i18n.t("feature_purchase.loading_catalog", "Đang tải bảng giá..."))
                                    : (void i18n.revision, i18n.t("feature_purchase.no_features", "Chưa có tính năng có thể mua."))
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                            }
                        }
                    }
                }
            }
        }

        ScrollView {
            id: detailScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical: ThinScrollBar {}

            ColumnLayout {
                width: Math.max(1, detailScroll.availableWidth - VfTheme.dp(32))
                x: VfTheme.dp(16)
                spacing: VfTheme.dp(12)

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(2)
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: featureDetail.implicitHeight + VfTheme.dp(24)
                    radius: VfTheme.dp(10)
                    color: VfTheme.surface
                    border.color: VfTheme.border

                    ColumnLayout {
                        id: featureDetail
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: VfTheme.dp(12)
                        spacing: VfTheme.dp(9)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(10)

                            Rectangle {
                                Layout.preferredWidth: VfTheme.dp(42)
                                Layout.preferredHeight: VfTheme.dp(42)
                                radius: VfTheme.dp(10)
                                color: VfTheme.blueFill
                                border.color: root.featureAccent(root.selectedFeatureCode)

                                VfAppIcon {
                                    anchors.centerIn: parent
                                    name: root.featureIcon(root.selectedFeatureCode)
                                    size: VfTheme.dp(22)
                                    framed: false
                                    color: root.featureAccent(root.selectedFeatureCode)
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(2)

                                Text {
                                    Layout.fillWidth: true
                                    text: String(root.selectedFeature.name
                                                 || root.fallbackFeatureName(root.selectedFeatureCode))
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(15)
                                    font.weight: Font.Bold
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: String(root.selectedFeature.description
                                                 || (void i18n.revision, i18n.t("feature_purchase.full_access", "Mở đầy đủ quyền sử dụng tính năng.")))
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    elide: Text.ElideRight
                                }
                            }

                            StatusBadge {
                                status: root.selectedFeatureOwned
                                    ? "owned" : (root.hasOrder ? root.paymentStatus : "locked")
                            }
                        }

                        Flow {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(7)

                            Repeater {
                                model: root.featureBenefits(root.selectedFeatureCode)

                                delegate: Rectangle {
                                    required property string modelData
                                    implicitWidth: benefitRow.implicitWidth + VfTheme.dp(16)
                                    implicitHeight: VfTheme.dp(26)
                                    radius: height / 2
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.border

                                    Row {
                                        id: benefitRow
                                        anchors.centerIn: parent
                                        spacing: VfTheme.dp(5)

                                        Text {
                                            text: "✓"
                                            color: VfTheme.greenText
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(10)
                                            font.weight: Font.Bold
                                        }

                                        Text {
                                            text: modelData
                                            color: VfTheme.textMuted
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(9)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: VfTheme.dp(12)
                    rowSpacing: VfTheme.dp(12)

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(126)
                        radius: VfTheme.dp(10)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(12)
                            spacing: VfTheme.dp(8)

                            Text {
                                text: (void i18n.revision, i18n.t("feature_purchase.duration", "Thời hạn sử dụng"))
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                font.weight: Font.Bold
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 4
                                columnSpacing: VfTheme.dp(6)

                                Repeater {
                                    model: [3, 7, 15, 30]

                                    delegate: Rectangle {
                                        id: dayOption
                                        required property int modelData
                                        readonly property bool selected: root.selectedDays === modelData
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: VfTheme.dp(34)
                                        radius: VfTheme.dp(7)
                                        color: selected ? VfTheme.primary : VfTheme.surface
                                        border.color: selected ? VfTheme.primary : VfTheme.borderStrong

                                        Text {
                                            anchors.centerIn: parent
                                            text: dayOption.modelData + " "
                                                  + (void i18n.revision, i18n.t("feature_purchase.day_unit", "ngày"))
                                            color: dayOption.selected ? "#FFFFFF" : VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(10)
                                            font.weight: Font.Bold
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            enabled: !root.hasOrder && !root.busy
                                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                            onClicked: root.selectedDays = dayOption.modelData
                                        }
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.priceCapped
                                    ? (void i18n.revision, i18n.t("feature_purchase.monthly_cap", "Đã áp trần giá tháng."))
                                    : (void i18n.revision, i18n.t("feature_purchase.short_plan", "Gói ngắn ngày có premium 50%."))
                                color: root.priceCapped ? VfTheme.greenText : VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(9)
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(126)
                        radius: VfTheme.dp(10)
                        color: VfTheme.greenFill
                        border.color: VfTheme.greenBorderSoft

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(12)
                            spacing: VfTheme.dp(4)

                            Text {
                                text: root.hasOrder
                                    ? (void i18n.revision, i18n.t("feature_purchase.locked_price", "Giá server đã khóa"))
                                    : (void i18n.revision, i18n.t("feature_purchase.estimated_price", "Giá tạm tính"))
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                font.weight: Font.Bold
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.moneyText(root.hasOrder ? root.lockedOrderAmount : root.estimatedPriceVnd)
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(20)
                                font.weight: Font.Black
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("feature_purchase.never_above_web", "Không cao hơn giá tháng trên web"))
                                color: VfTheme.greenText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(9)
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }

                            Item { Layout.fillHeight: true }

                            RowLayout {
                                Layout.fillWidth: true
                                visible: !root.hasOrder
                                spacing: VfTheme.dp(6)

                                MethodOption {
                                    Layout.fillWidth: true
                                    label: "Bank"
                                    value: "BANK_TRANSFER"
                                    iconName: "credit-card"
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: orderGrid.implicitHeight + VfTheme.dp(22)
                    radius: VfTheme.dp(10)
                    color: VfTheme.surface
                    border.color: VfTheme.border

                    GridLayout {
                        id: orderGrid
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: VfTheme.dp(11)
                        columns: 4
                        columnSpacing: VfTheme.dp(12)
                        rowSpacing: VfTheme.dp(4)

                        SectionTitle {
                            Layout.columnSpan: 3
                            text: (void i18n.revision, i18n.t("feature_purchase.order_info", "Thông tin đơn"))
                            iconName: "package"
                        }

                        StatusBadge {
                            Layout.alignment: Qt.AlignRight
                            status: root.paymentStatus
                        }

                        InfoCell {
                            label: (void i18n.revision, i18n.t("feature_purchase.order_code", "Mã đơn"))
                            value: root.orderCode || "—"
                        }
                        InfoCell {
                            label: (void i18n.revision, i18n.t("feature_purchase.feature", "Tính năng"))
                            value: String(root.selectedFeature.name
                                          || root.fallbackFeatureName(root.selectedFeatureCode))
                        }
                        InfoCell {
                            label: (void i18n.revision, i18n.t("feature_purchase.days", "Số ngày"))
                            value: String(root.hasOrder ? root.lockedOrderDays : root.selectedDays)
                        }
                        InfoCell {
                            label: (void i18n.revision, i18n.t("feature_purchase.total", "Tổng tiền"))
                            value: root.moneyText(root.hasOrder ? root.lockedOrderAmount : root.estimatedPriceVnd)
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: root.hasOrder ? VfTheme.dp(194) : VfTheme.dp(142)
                    radius: VfTheme.dp(10)
                    color: VfTheme.surfaceSoft
                    border.color: root.hasOrder ? VfTheme.blueBorderSoft : VfTheme.border

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(11)
                        spacing: VfTheme.dp(9)

                        SectionTitle {
                            Layout.fillWidth: true
                            text: (void i18n.revision, i18n.t("feature_purchase.payment_info", "Thông tin thanh toán"))
                            iconName: "credit-card"
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: VfTheme.dp(12)

                            Rectangle {
                                Layout.preferredWidth: root.hasOrder ? VfTheme.dp(184) : VfTheme.dp(132)
                                Layout.fillHeight: true
                                radius: VfTheme.dp(9)
                                color: VfTheme.surface
                                border.color: root.paymentQrUrl.length > 0 ? VfTheme.blueBorderSoft : VfTheme.border
                                clip: true

                                Image {
                                    id: paymentQr
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(8)
                                    source: root.paymentQrUrl
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    visible: root.paymentQrUrl.length > 0 && status !== Image.Error
                                }

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    width: parent.width - VfTheme.dp(18)
                                    visible: !paymentQr.visible
                                    spacing: VfTheme.dp(5)

                                    VfAppIcon {
                                        Layout.alignment: Qt.AlignHCenter
                                        name: root.hasOrder ? "credit-card" : "package"
                                        size: VfTheme.dp(28)
                                        framed: false
                                        color: root.hasOrder ? VfTheme.textSubtle : VfTheme.blueBorder
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        wrapMode: Text.WordWrap
                                        text: root.hasOrder
                                            ? (void i18n.revision, i18n.t("feature_purchase.qr_unavailable", "QR chưa khả dụng"))
                                            : (void i18n.revision, i18n.t("feature_purchase.create_order_hint", "Tạo đơn để nhận QR"))
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(9)
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: paymentQr.visible
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: qrPreview.open()
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: VfTheme.dp(5)

                                Text {
                                    Layout.fillWidth: true
                                    visible: !root.hasOrder
                                    wrapMode: Text.WordWrap
                                    text: (void i18n.revision, i18n.t("feature_purchase.payment_placeholder", "QR, tài khoản nhận và nội dung chuyển khoản sẽ hiển thị tại đây sau khi tạo đơn."))
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(11)
                                }

                                Repeater {
                                    model: root.hasOrder ? root.paymentRows() : []

                                    delegate: RowLayout {
                                        id: paymentRow
                                        required property var modelData
                                        Layout.fillWidth: true
                                        spacing: VfTheme.dp(8)

                                        Text {
                                            Layout.preferredWidth: VfTheme.dp(92)
                                            text: String(paymentRow.modelData.label || "")
                                            color: VfTheme.textSubtle
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(9)
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: String(paymentRow.modelData.value || "—")
                                            color: VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(10)
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideMiddle
                                        }
                                    }
                                }

                                Item { Layout.fillHeight: true }

                                Text {
                                    Layout.fillWidth: true
                                    visible: root.hasOrder
                                    text: root.paymentPollExpired
                                        ? (void i18n.revision, i18n.t("feature_purchase.poll_stopped", "Đã dừng tự kiểm tra. Bấm Làm mới."))
                                        : (root.paymentPending
                                           ? (void i18n.revision, i18n.t("feature_purchase.auto_check", "Tự động kiểm tra trạng thái thanh toán."))
                                           : root.statusText(root.paymentStatus))
                                    color: root.paymentStatus === "completed" ? VfTheme.greenText : VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9)
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: String(root.payload.status || "").length > 0
                    text: String(root.payload.status || "")
                    color: VfTheme.redText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    wrapMode: Text.WordWrap
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(2)
                }
            }
        }
    }

    footer: Rectangle {
        implicitHeight: VfTheme.dp(56)
        color: VfTheme.surface
        border.color: VfTheme.border

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(16)
            anchors.rightMargin: VfTheme.dp(16)
            spacing: VfTheme.dp(8)

            BusyIndicator {
                running: root.busy || root.paymentPolling
                visible: running
                implicitWidth: VfTheme.dp(22)
                implicitHeight: VfTheme.dp(22)
            }

            Text {
                Layout.fillWidth: true
                text: root.busy
                    ? (void i18n.revision, i18n.t("feature_purchase.processing", "Đang xử lý..."))
                    : (root.selectedFeatureOwned
                       ? (void i18n.revision,
                          i18n.t("feature_purchase.already_owned_note", "Module này đang active trên license hiện tại."))
                    : (root.hasOrder ? root.statusText(root.paymentStatus)
                                     : (void i18n.revision, i18n.t("feature_purchase.server_price_note", "Giá cuối cùng do server khóa khi tạo đơn."))))
                color: root.accessReady ? VfTheme.greenText : VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                elide: Text.ElideRight
            }

            VfButton {
                visible: !root.hasOrder
                text: (void i18n.revision, i18n.t("common.refresh", "Làm mới"))
                iconName: "clockwise-arrows"
                compact: true
                enabled: !root.busy
                onClicked: root.refreshRequested()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("feature_purchase.later", "Để sau"))
                compact: true
                onClicked: root.close()
            }

            VfButton {
                minWidth: VfTheme.dp(170)
                tone: root.accessReady || root.selectedFeatureOwned ? "green" : "primary"
                iconName: root.accessReady || root.selectedFeatureOwned
                    ? "check-mark-button"
                    : (root.hasOrder ? "clockwise-arrows" : "key")
                text: {
                    if (root.accessReady)
                        return (void i18n.revision, i18n.t("feature_purchase.open_feature", "Mở tính năng"))
                    if (root.selectedFeatureOwned)
                        return (void i18n.revision, i18n.t("feature_purchase.owned", "Đã sở hữu"))
                    if (root.paymentStatus === "completed")
                        return (void i18n.revision, i18n.t("feature_purchase.updating_access", "Đang cập nhật quyền"))
                    if (root.hasOrder)
                        return (void i18n.revision, i18n.t("feature_purchase.refresh_payment", "Làm mới thanh toán"))
                    return (void i18n.revision, i18n.t("feature_purchase.unlock_days", "Mở khóa"))
                           + " " + root.selectedDays + " "
                           + (void i18n.revision, i18n.t("feature_purchase.day_unit", "ngày"))
                }
                enabled: {
                    if (root.accessReady)
                        return true
                    if (root.selectedFeatureOwned)
                        return false
                    if (root.paymentStatus === "completed")
                        return false
                    if (root.hasOrder)
                        return !root.paymentPolling
                    return !root.busy && root.selectedFeatureCode.length > 0
                           && !root.selectedFeatureOwned && root.estimatedPriceVnd > 0
                }
                onClicked: {
                    if (root.accessReady) {
                        root.openFeatureRequested(root.routeForFeature(root.selectedFeatureCode))
                        root.close()
                    } else if (root.hasOrder) {
                        root.paymentPollRequested(root.orderCode)
                    } else if (!root.selectedFeatureOwned) {
                        root.buyRequested(root.selectedFeatureCode, root.selectedDays, "BANK_TRANSFER")
                    }
                }
            }
        }
    }

    Dialog {
        id: qrPreview
        parent: root.Overlay.overlay
        modal: true
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(64))
        height: VfDialogMetrics.height(parent, VfTheme.dp(480), VfTheme.dp(64))
        x: VfDialogMetrics.centerX(parent, width)
        y: VfDialogMetrics.centerY(parent, height)
        padding: VfTheme.dp(16)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        header: VfDialogHeader {
            title: (void i18n.revision, i18n.t("feature_purchase.payment_qr", "QR thanh toán"))
            iconName: "credit-card"
            compact: true
            onCloseClicked: qrPreview.close()
        }

        contentItem: Image {
            source: root.paymentQrUrl
            fillMode: Image.PreserveAspectFit
            asynchronous: true
        }
    }

    component SectionTitle: RowLayout {
        property string text: ""
        property string iconName: ""

        spacing: VfTheme.dp(6)

        VfAppIcon {
            name: parent.iconName
            size: VfTheme.dp(15)
            framed: false
            color: VfTheme.primary
        }

        Text {
            Layout.fillWidth: true
            text: parent.text
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
            font.weight: Font.Bold
        }
    }

    component InfoCell: ColumnLayout {
        property string label: ""
        property string value: ""

        Layout.fillWidth: true
        spacing: VfTheme.dp(2)

        Text {
            Layout.fillWidth: true
            text: parent.label
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(8)
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: parent.value
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            font.weight: Font.DemiBold
            elide: Text.ElideMiddle
        }
    }

    component StatusBadge: Rectangle {
        property string status: ""
        readonly property string tone: root.statusTone(status)

        implicitWidth: badgeText.implicitWidth + VfTheme.dp(18)
        implicitHeight: VfTheme.dp(24)
        radius: height / 2
        color: tone === "green" ? VfTheme.greenFill
             : tone === "red" ? VfTheme.redFill
             : tone === "amber" ? VfTheme.amberFill
             : VfTheme.surfaceSoft
        border.color: tone === "green" ? VfTheme.greenBorderSoft
                      : tone === "red" ? VfTheme.redBorderSoft
                      : tone === "amber" ? VfTheme.amberBorderSoft
                      : VfTheme.border

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: parent.status === "locked"
                ? (void i18n.revision, i18n.t("feature_purchase.locked", "Đang bị khóa"))
                : root.statusText(parent.status)
            color: parent.tone === "green" ? VfTheme.greenText
                 : parent.tone === "red" ? VfTheme.redText
                 : parent.tone === "amber" || parent.status === "locked" ? VfTheme.amberText
                 : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(9)
            font.weight: Font.Bold
        }
    }

    component MethodOption: Rectangle {
        id: methodOption
        property string label: ""
        property string value: ""
        property string iconName: ""
        readonly property bool selected: root.selectedMethod === value

        Layout.preferredHeight: VfTheme.dp(30)
        radius: VfTheme.dp(7)
        color: selected ? VfTheme.greenFill : VfTheme.surface
        border.color: selected ? VfTheme.greenBorder : VfTheme.borderStrong

        Row {
            anchors.centerIn: parent
            spacing: VfTheme.dp(5)

            VfAppIcon {
                name: methodOption.iconName
                size: VfTheme.dp(13)
                framed: false
                color: methodOption.selected ? VfTheme.greenText : VfTheme.textMuted
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: methodOption.label
                color: methodOption.selected ? VfTheme.greenText : VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.selectedMethod = methodOption.value
        }
    }

    component ThinScrollBar: ScrollBar {
        id: thinBar

        policy: ScrollBar.AsNeeded
        implicitWidth: VfTheme.dp(7)
        padding: VfTheme.dp(2)

        contentItem: Rectangle {
            implicitWidth: VfTheme.dp(3)
            radius: width / 2
            color: thinBar.pressed ? VfTheme.primary : VfTheme.borderStrong
            opacity: thinBar.active ? 0.85 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }

        background: Item {}
    }
}
