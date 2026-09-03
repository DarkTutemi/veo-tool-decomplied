import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "AboutDialog"

    property var payload: ({})
    property string version: ""
    property string toolCode: ""

    readonly property real sidebarWidth: VfTheme.dp(280)
    readonly property real titleSize: VfTheme.dp(15)
    readonly property real labelSize: VfTheme.dp(10)
    readonly property real bodySize: VfTheme.dp(12)
    readonly property real mutedSize: VfTheme.dp(11)
    readonly property real heroValueSize: VfTheme.dp(24)

    signal externalUrlRequested(string url)
    signal featurePurchaseRequested(string route)

    title: (void i18n.revision, i18n.t("about_dialog.window_title", "Giới thiệu"))
    header: null
    parent: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, VfTheme.dp(980), VfTheme.dp(32))
    height: VfDialogMetrics.height(parent, VfTheme.dp(660), VfTheme.dp(32))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton

    background: Rectangle {
        radius: VfTheme.dp(14)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        border.width: 1
        layer.enabled: true
    }

    function add_info_row(label, value, clickable, url) {
        var row = {
            label: String(label || ""),
            value: String(value || "")
        }
        if (clickable && String(url || "").length > 0)
            row.url = String(url || "")
        return row
    }

    function openFromPayload(p) {
        root.payload = p || ({})
        root.version = root._firstNonEmpty(
            root._veoflow().version,
            root._rowValue(["version", "current version"]),
            root._subtitleVersion()
        )
        root.toolCode = root._firstNonEmpty(
            root._veoflow().tool_code,
            root._rowValue(["tool code", "tool"]),
            ""
        )
        root.open()
    }

    function _veoflow()  { return root.payload.veoflow || ({}) }
    function _reseller() { return root.payload.reseller || ({}) }
    function _license()  { return root.payload.license || ({}) }
    function _money()    { return root.payload.money || ({}) }
    function _features() { return root.payload.features || [] }

    function _firstNonEmpty() {
        for (var i = 0; i < arguments.length; i += 1) {
            var value = String(arguments[i] || "").trim()
            if (value.length > 0 && value !== "-")
                return value
        }
        return ""
    }

    function _payloadRows() {
        var rows = []
        var sections = root.payload.sections || []
        for (var i = 0; i < sections.length; i += 1) {
            var sectionRows = (sections[i] || {}).rows || []
            for (var j = 0; j < sectionRows.length; j += 1)
                rows.push(sectionRows[j] || ({}))
        }
        return rows
    }

    function _rowValue(labels) {
        var wanted = {}
        for (var i = 0; i < labels.length; i += 1)
            wanted[String(labels[i] || "").toLowerCase()] = true
        var rows = root._payloadRows()
        for (var j = 0; j < rows.length; j += 1) {
            var label = String(rows[j].label || "").replace(":", "").trim().toLowerCase()
            if (wanted[label])
                return String(rows[j].value || "")
        }
        return ""
    }

    function _subtitleVersion() {
        var text = String(root.payload.subtitle || "").trim()
        return text.indexOf("v") === 0 ? text.slice(1) : text
    }

    function _displayVersion() {
        var value = root._firstNonEmpty(root.version, root._veoflow().version)
        if (!value.length)
            return ""
        return value.indexOf("v") === 0 ? value : "v" + value
    }

    function _website() {
        return root._firstNonEmpty(root._veoflow().website, "https://veoflow.dev")
    }

    function _partnerZalo() {
        return root._firstNonEmpty(root._reseller().zalo, root._reseller().phone, "")
    }

    function _zaloUrl() {
        var phone = root._firstNonEmpty(root._veoflow().contact_zalo, root._reseller().zalo, "0559747058")
        return phone.length ? "https://zalo.me/" + phone : ""
    }

    function _partnerName() {
        return root._firstNonEmpty(root._reseller().name, "")
    }

    function _hasReseller() {
        var r = root._reseller()
        return Boolean(r && r.verified && (
            String(r.name || "").length > 0
            || String(r.zalo || "").length > 0
            || String(r.phone || "").length > 0
            || String(r.website || "").length > 0
        ))
    }

    function _licenseStatusText() {
        var kind = String(root._license().status_kind || "unknown")
        if (kind === "active")
            return (void i18n.revision, i18n.t("about_dialog.status_active", "Đang hoạt động"))
        if (kind === "expiring_soon")
            return (void i18n.revision, i18n.t("about_dialog.status_expiring", "Sắp hết hạn"))
        if (kind === "expired")
            return (void i18n.revision, i18n.t("about_dialog.status_expired", "Đã hết hạn"))
        if (kind === "invalid")
            return (void i18n.revision, i18n.t("about_dialog.status_invalid", "Không hợp lệ"))
        return kind.length ? kind : (void i18n.revision, i18n.t("about_dialog.status_unknown", "Không rõ"))
    }

    function _statusColor(kind) {
        if (kind === "active")
            return VfTheme.greenText
        if (kind === "expiring_soon")
            return VfTheme.amberText
        if (kind === "expired" || kind === "invalid")
            return "#DC2626"
        return VfTheme.textSubtle
    }

    function _formatNumber(value) {
        var n = Number(value || 0)
        return n.toLocaleString(Qt.locale(), "f", n % 1 === 0 ? 0 : 2)
    }

    function _isVietnameseLocale() {
        return String(i18n.locale || "vi").toLowerCase().indexOf("vi") === 0
    }

    function _targetCurrency() {
        return root._isVietnameseLocale() ? "VND" : "USD"
    }

    function _sourceCurrency() {
        return String(root._money().currency || "VND").toUpperCase()
    }

    function _usdRate() {
        var rate = Number(root._money().usd_exchange_rate || root._money().vnd_per_usd || root.payload.usd_exchange_rate || 25000)
        return rate > 0 ? rate : 25000
    }

    function _moneyValue(key) {
        return Number(root._money()[key] || 0)
    }

    function _moneyText(value) {
        var amount = Number(value || 0)
        var sourceCurrency = root._sourceCurrency()
        var targetCurrency = root._targetCurrency()
        if (sourceCurrency !== targetCurrency) {
            if (sourceCurrency === "VND" && targetCurrency === "USD")
                amount = amount / root._usdRate()
            else if (sourceCurrency === "USD" && targetCurrency === "VND")
                amount = amount * root._usdRate()
        }
        var decimals = targetCurrency === "USD" ? 2 : 0
        return amount.toLocaleString(Qt.locale(), "f", decimals) + " " + targetCurrency
    }

    function _activeFeatureCount() {
        var count = 0
        var rows = root._features()
        for (var i = 0; i < rows.length; i += 1) {
            if (Boolean((rows[i] || {}).active))
                count += 1
        }
        return count
    }

    function _inactiveFeatureCount() {
        return Math.max(0, root._featureTotal() - root._activeFeatureCount())
    }

    function _featureTotal() {
        return Math.max(0, root._features().length)
    }

    function _featurePercent() {
        var total = root._featureTotal()
        return total <= 0 ? 0 : Math.round(root._activeFeatureCount() * 100 / total)
    }

    function _featureCaption() {
        var total = root._featureTotal()
        if (total <= 0)
            return (void i18n.revision, i18n.t("about_dialog.no_feature_data", "Chưa có dữ liệu module"))
        if (root._activeFeatureCount() === total)
            return (void i18n.revision, i18n.t("about_dialog.all_modules_active", "Tất cả module đang hoạt động"))
        return (void i18n.revision, i18n.t("about_dialog.active_modules", "{active}/{total} module đang bật"))
            .replace("{active}", String(root._activeFeatureCount()))
            .replace("{total}", String(total))
    }

    function _canPurchaseFeatures() {
        var kind = String(root._license().status_kind || "unknown")
        return kind === "active" || kind === "expiring_soon"
    }

    function _routeForFeature(code) {
        var routes = {
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
        return String(routes[String(code || "").toUpperCase()] || "")
    }

    contentItem: RowLayout {
        spacing: 0

        Rectangle {
            id: sidebar
            Layout.preferredWidth: root.sidebarWidth
            Layout.fillHeight: true
            radius: VfTheme.dp(14)
            clip: true

            gradient: Gradient {
                GradientStop { position: 0.0; color: VfTheme.blueFill }
                GradientStop { position: 0.7; color: VfTheme.blueFill }
                GradientStop { position: 1.0; color: VfTheme.blueFill }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: VfTheme.dp(168)
                opacity: 0.72
                color: VfTheme.cyanFill
            }

            Rectangle {
                width: VfTheme.dp(390)
                height: VfTheme.dp(112)
                x: -VfTheme.dp(42)
                y: parent.height - VfTheme.dp(154)
                radius: VfTheme.dp(56)
                rotation: -8
                color: "#BFEAFF"
                opacity: 0.62
            }

            Rectangle {
                width: VfTheme.dp(360)
                height: VfTheme.dp(92)
                x: VfTheme.dp(64)
                y: parent.height - VfTheme.dp(130)
                radius: VfTheme.dp(46)
                rotation: -17
                color: "#DFF7FF"
                opacity: 0.9
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(34)
                anchors.rightMargin: VfTheme.dp(34)
                anchors.topMargin: VfTheme.dp(78)
                anchors.bottomMargin: VfTheme.dp(30)
                spacing: VfTheme.dp(14)

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(210)

                    ColumnLayout {
                        anchors.centerIn: parent
                        width: parent.width
                        spacing: VfTheme.dp(10)

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: VfTheme.dp(124)
                            Layout.preferredHeight: VfTheme.dp(78)
                            source: Qt.resolvedUrl("../../resources/brand/veoflow-logo-transparent.png")
                            sourceClipRect: Qt.rect(0, 0, 630, 377)
                            fillMode: Image.PreserveAspectFit
                            sourceSize.width: 630
                            sourceSize.height: 377
                            smooth: true
                            mipmap: true
                            asynchronous: true
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "<span style='color:#071735'>Veo</span><span style='color:#1F6DF2'>Flow</span>"
                            textFormat: Text.RichText
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(32)
                            font.weight: Font.Bold
                        }

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: VfTheme.dp(174)
                            Layout.preferredHeight: 1
                            color: VfTheme.border
                        }

                        Text {
                            Layout.fillWidth: true
                            text: (void i18n.revision, i18n.t("about_dialog.studio_subtitle", "AI Video Creation Studio"))
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Rectangle {
                            visible: root._displayVersion().length > 0
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: versionText.implicitWidth + VfTheme.dp(26)
                            Layout.preferredHeight: VfTheme.dp(28)
                            radius: VfTheme.dp(14)
                            color: VfTheme.blueFill
                            border.color: VfTheme.blueBorderSoft

                            Text {
                                id: versionText
                                anchors.centerIn: parent
                                text: root._displayVersion()
                                color: "#1F6DF2"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                font.weight: Font.Bold
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(9)

                    SideLinkButton {
                        label: (void i18n.revision, i18n.t("about_dialog.website_btn", "Website"))
                        iconName: "globe-with-meridians"
                        iconColor: "#2275F4"
                        onClicked: root.externalUrlRequested(root._website())
                    }

                    SideLinkButton {
                        label: "Zalo"
                        iconName: "speech-balloon"
                        iconColor: "#088CFF"
                        visible: root._zaloUrl().length > 0
                        onClicked: root.externalUrlRequested(root._zaloUrl())
                    }

                }

                Item { Layout.fillHeight: true }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(6)

                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("about_dialog.copyright_short", "© 2025 VeoFlow"))
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("about_dialog.rights_reserved", "All rights reserved."))
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            IconButton {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: VfTheme.dp(18)
                anchors.rightMargin: VfTheme.dp(18)
                iconName: "cross-mark"
                tooltip: (void i18n.revision, i18n.t("common.close", "Đóng"))
                onClicked: root.close()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(28)
                anchors.rightMargin: VfTheme.dp(38)
                anchors.topMargin: VfTheme.dp(52)
                anchors.bottomMargin: VfTheme.dp(74)
                spacing: VfTheme.dp(12)

                LicenseBanner {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(106)
                }

                SectionCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(88)

                    content: MoneyRow {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

                SectionCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._featureTotal() > 0 ? VfTheme.dp(196) : VfTheme.dp(96)

                    content: FeatureCardSection {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

                SectionCard {
                    visible: root._hasReseller()
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? VfTheme.dp(86) : 0

                    content: PartnerRow {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: VfTheme.dp(68)
                color: VfTheme.surface
                border.color: VfTheme.border
                border.width: 1

                RowLayout {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: VfTheme.dp(28)
                    spacing: VfTheme.dp(12)

                    FooterButton {
                        label: (void i18n.revision, i18n.t("about_dialog.website_btn", "Website"))
                        iconName: "globe-with-meridians"
                        primary: true
                        onClicked: root.externalUrlRequested(root._website())
                    }

                    FooterButton {
                        label: (void i18n.revision, i18n.t("about_dialog.close_btn", "Close"))
                        iconName: "cross-mark"
                        onClicked: root.close()
                    }
                }
            }
        }
    }

    component SectionCard: Rectangle {
        id: sectionCardRoot

        default property alias content: sectionCardBody.data
        property real innerPadding: VfTheme.dp(12)

        radius: VfTheme.dp(12)
        color: VfTheme.surface
        border.color: VfTheme.border
        border.width: 1
        clip: true

        ColumnLayout {
            id: sectionCardBody
            anchors.fill: parent
            anchors.margins: sectionCardRoot.innerPadding
            spacing: VfTheme.dp(8)
        }
    }

    component LicenseBanner: Rectangle {
        radius: VfTheme.dp(12)
        color: VfTheme.greenFill
        border.color: VfTheme.greenBorderSoft
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(16)
            anchors.rightMargin: VfTheme.dp(20)
            spacing: VfTheme.dp(16)

            IconBubble {
                size: VfTheme.dp(56)
                iconName: "check-mark-button"
                iconColor: VfTheme.greenText
                backgroundColor: VfTheme.greenFill
                borderColor: "#CCEEDB"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)

                Text {
                    text: (void i18n.revision, i18n.t("about_dialog.license_title", "License"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: root.titleSize
                    font.weight: Font.Bold
                }

                RowLayout {
                    spacing: VfTheme.dp(14)

                    Text {
                        text: root._firstNonEmpty(root._license().type, "UNKNOWN")
                        color: root._statusColor(root._license().status_kind)
                        font.family: VfTheme.fontFamily
                    font.pixelSize: root.heroValueSize
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        Layout.preferredWidth: statusText.implicitWidth + VfTheme.dp(22)
                        Layout.preferredHeight: VfTheme.dp(26)
                        radius: VfTheme.dp(13)
                        color: VfTheme.greenFill

                        Text {
                            id: statusText
                            anchors.centerIn: parent
                            text: root._licenseStatusText()
                            color: VfTheme.greenText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            MetricBlock {
                Layout.preferredWidth: VfTheme.dp(126)
                label: (void i18n.revision, i18n.t("about_dialog.expires", "Hết hạn"))
                value: root._firstNonEmpty(root._license().expiry_display, root._license().expires_at, "-")
                valueColor: VfTheme.text
            }

            MetricBlock {
                Layout.preferredWidth: VfTheme.dp(134)
                label: (void i18n.revision, i18n.t("about_dialog.remaining", "Còn lại"))
                value: root._firstNonEmpty(root._license().remaining_text, "-")
                valueColor: VfTheme.greenText
            }
        }
    }

    component MoneyRow: RowLayout {
        spacing: VfTheme.dp(16)

        IconBubble {
            size: VfTheme.dp(50)
            iconName: "money-bag"
            iconColor: "#2275F4"
            backgroundColor: VfTheme.blueFill
            borderColor: VfTheme.blueBorderSoft
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(4)

            Text {
                text: (void i18n.revision, i18n.t("about_dialog.money_title", "Số dư sử dụng AI Gemini"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: root.titleSize
                font.weight: Font.Bold
            }

            Text {
                text: root._moneyText(root._moneyValue("available_balance"))
                color: "#1668E8"
                font.family: VfTheme.fontFamily
                font.pixelSize: root.heroValueSize
                font.weight: Font.Bold
            }
        }

        MetricBlock {
            Layout.preferredWidth: VfTheme.dp(126)
            label: (void i18n.revision, i18n.t("about_dialog.today_spend", "Đã dùng hôm nay"))
            value: root._moneyText(root._moneyValue("spent_today"))
            valueColor: VfTheme.text
        }

        MetricBlock {
            Layout.preferredWidth: VfTheme.dp(142)
            label: (void i18n.revision, i18n.t("about_dialog.month_spend", "Đã dùng tháng này"))
            value: root._moneyText(root._moneyValue("spent_month"))
            valueColor: "#1668E8"
        }
    }

    component FeatureCardSection: ColumnLayout {
        spacing: VfTheme.dp(8)

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(10)

            IconBubble {
                size: VfTheme.dp(38)
                iconName: "package"
                iconColor: "#5B35E6"
                backgroundColor: VfTheme.violetFill
                borderColor: VfTheme.violetBorderSoft
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(2)

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("about_dialog.features_title", "Modules"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: root.titleSize
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root._featureCaption()
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: root.mutedSize
                    elide: Text.ElideRight
                }
            }

            VfButton {
                objectName: "aboutFeaturePurchaseButton"
                visible: root._canPurchaseFeatures()
                text: (void i18n.revision,
                    i18n.t("about_dialog.buy_feature_days", "Mua theo ngày"))
                tone: "primary"
                iconName: "spiral-calendar"
                compact: true
                minWidth: VfTheme.dp(118)
                tooltip: root._inactiveFeatureCount() > 0
                    ? (void i18n.revision,
                       i18n.t("about_dialog.buy_feature_days_hint", "Chọn module và số ngày cần mở khóa."))
                    : (void i18n.revision,
                       i18n.t("about_dialog.all_features_owned_hint", "Xem catalog; module đã sở hữu không thể mua lại."))
                onClicked: root.featurePurchaseRequested("")
            }

            FeatureCountPill {
                label: (void i18n.revision, i18n.t("about_dialog.active_features", "Active"))
                value: String(root._activeFeatureCount())
                active: true
            }

            FeatureCountPill {
                label: (void i18n.revision, i18n.t("about_dialog.inactive_features", "Inactive"))
                value: String(root._inactiveFeatureCount())
                active: false
            }
        }

        FeatureCardGrid {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root._featureTotal() > 0
        }
    }

    component FeatureCardGrid: ScrollView {
        id: featureCardGridRoot

        clip: true
        contentWidth: availableWidth
        contentHeight: featureGrid.implicitHeight
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: featureGrid.implicitHeight > height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff

        GridLayout {
            id: featureGrid
            width: featureCardGridRoot.availableWidth
            columns: width >= VfTheme.dp(560) ? 3 : 2
            columnSpacing: VfTheme.dp(8)
            rowSpacing: VfTheme.dp(6)

            Repeater {
                model: root._features()

                delegate: FeatureCard {
                    Layout.fillWidth: true
                    featureData: modelData || ({})
                }
            }
        }
    }

    component FeatureCard: Rectangle {
        id: featureCardRoot
        objectName: "aboutFeatureCard_" + String(featureData.code || "").toLowerCase()

        property var featureData: ({})
        readonly property bool active: Boolean(featureData.active)
        readonly property string purchaseRoute: root._routeForFeature(featureData.code)
        readonly property bool purchasable: !active
            && root._canPurchaseFeatures() && purchaseRoute.length > 0

        implicitHeight: VfTheme.dp(34)
        radius: VfTheme.dp(9)
        color: active ? VfTheme.greenFill
                      : (featureCardMouse.containsMouse && purchasable
                         ? VfTheme.blueFill : VfTheme.surface)
        border.color: active ? VfTheme.greenBorderSoft
                             : (purchasable ? VfTheme.blueBorderSoft : VfTheme.border)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(8)
            anchors.rightMargin: VfTheme.dp(8)
            spacing: VfTheme.dp(6)

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(16)
                Layout.preferredHeight: VfTheme.dp(16)
                radius: VfTheme.dp(8)
                color: featureCardRoot.active ? VfTheme.greenFill : VfTheme.surfaceSoft

                VfAppIcon {
                    anchors.centerIn: parent
                    name: featureCardRoot.active ? "check-mark-button" : "cross-mark"
                    size: VfTheme.dp(9)
                    framed: false
                    color: featureCardRoot.active ? VfTheme.greenText : VfTheme.textSubtle
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: String(featureCardRoot.featureData.label || "-")
                    color: featureCardRoot.active ? VfTheme.greenText : VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                    font.weight: Font.DemiBold
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: featureCardRoot.active
                          ? (void i18n.revision, i18n.t("about_dialog.active", "Active"))
                          : featureCardRoot.purchasable
                            ? (void i18n.revision, i18n.t("about_dialog.buy_feature_days", "Mua theo ngày"))
                          : (void i18n.revision, i18n.t("about_dialog.inactive", "Inactive"))
                    color: featureCardRoot.active ? VfTheme.greenText
                                                  : (featureCardRoot.purchasable
                                                     ? "#1668E8" : VfTheme.textSubtle)
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(8)
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }
            }

            VfAppIcon {
                visible: featureCardRoot.purchasable
                name: "chevron-right"
                size: VfTheme.dp(11)
                framed: false
                color: "#1668E8"
            }
        }

        MouseArea {
            id: featureCardMouse
            anchors.fill: parent
            enabled: featureCardRoot.purchasable
            hoverEnabled: enabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.featurePurchaseRequested(featureCardRoot.purchaseRoute)
        }
    }

    component FeatureCountPill: Rectangle {
        property string label: ""
        property string value: ""
        property bool active: true

        Layout.preferredWidth: VfTheme.dp(82)
        Layout.preferredHeight: VfTheme.dp(30)
        radius: VfTheme.dp(9)
        color: active ? VfTheme.greenFill : VfTheme.surfaceSoft
        border.color: active ? VfTheme.greenBorderSoft : VfTheme.border
        border.width: 1

        RowLayout {
            anchors.centerIn: parent
            spacing: VfTheme.dp(5)

            Text {
                text: parent.parent.value
                color: parent.parent.active ? VfTheme.greenText : VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                font.weight: Font.Bold
            }

            Text {
                text: parent.parent.label
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                font.weight: Font.DemiBold
            }
        }
    }

    component FeatureRow: ColumnLayout {
        spacing: VfTheme.dp(8)

        IconBubble {
            size: VfTheme.dp(84)
            iconName: "package"
            iconColor: "#5B35E6"
            backgroundColor: VfTheme.violetFill
            borderColor: VfTheme.violetBorderSoft
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(10)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Text {
                    text: (void i18n.revision, i18n.t("about_dialog.features_title", "Tính năng đã kích hoạt"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: root.titleSize
                    font.weight: Font.Bold
                }

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(18)
                    Layout.preferredHeight: VfTheme.dp(18)
                    radius: VfTheme.dp(9)
                    color: VfTheme.surface
                    border.color: VfTheme.textSubtle

                    Text {
                        anchors.centerIn: parent
                        text: "i"
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        font.weight: Font.Bold
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(8)
                radius: VfTheme.dp(4)
                color: VfTheme.blueFill
                clip: true

                Rectangle {
                    width: parent.width * root._featurePercent() / 100
                    height: parent.height
                    radius: parent.radius
                    color: "#2563EB"
                }
            }

            Text {
                Layout.fillWidth: true
                text: root._featureCaption()
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: root.mutedSize
                elide: Text.ElideRight
            }
        }

        ColumnLayout {
            Layout.preferredWidth: VfTheme.dp(110)
            spacing: VfTheme.dp(6)

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: String(root._activeFeatureCount()) + " / " + String(root._featureTotal())
                color: "#1668E8"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(21)
                font.weight: Font.Bold
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: String(root._featurePercent()) + "%"
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(16)
            }
        }
    }

    component PartnerRow: RowLayout {
        spacing: VfTheme.dp(16)

        IconBubble {
            size: VfTheme.dp(48)
            iconName: "busts-in-silhouette"
            iconColor: VfTheme.cyanText
            backgroundColor: VfTheme.cyanFill
            borderColor: "#D0F4F6"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(7)

            Text {
                text: (void i18n.revision, i18n.t("about_dialog.partner_title", "Đối tác hỗ trợ"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: root.titleSize
                font.weight: Font.Bold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(18)

                ColumnLayout {
                    Layout.preferredWidth: VfTheme.dp(180)
                    spacing: VfTheme.dp(2)

                    Text {
                        text: (void i18n.revision, i18n.t("about_dialog.partner_name", "Tên"))
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: root.labelSize
                    }

                    Text {
                        text: root._partnerName()
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: root.bodySize
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: VfTheme.dp(42)
                    color: VfTheme.borderBox
                }

                ColumnLayout {
                    Layout.preferredWidth: VfTheme.dp(170)
                    spacing: VfTheme.dp(2)

                    Text {
                        text: "Zalo"
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: root.labelSize
                    }

                    Text {
                        text: root._firstNonEmpty(root._partnerZalo(), "-")
                        color: VfTheme.cyanText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: root.bodySize
                        font.weight: Font.Bold
                    }
                }
            }
        }
    }

    component AboutDivider: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: VfTheme.border
    }

    component MetricBlock: ColumnLayout {
        property string label: ""
        property string value: ""
        property color valueColor: VfTheme.text

        spacing: VfTheme.dp(5)

        Text {
            Layout.fillWidth: true
            text: parent.label
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: root.labelSize
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: parent.value
            color: parent.valueColor
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(13)
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
    }

    component IconBubble: Rectangle {
        property string iconName: ""
        property color iconColor: "#2563EB"
        property color backgroundColor: VfTheme.blueFill
        property color borderColor: VfTheme.blueBorderSoft
        property int size: VfTheme.dp(84)

        Layout.preferredWidth: size
        Layout.preferredHeight: size
        radius: size / 2
        color: backgroundColor
        border.color: borderColor
        border.width: 1

        VfAppIcon {
            anchors.centerIn: parent
            name: parent.iconName
            size: Math.round(parent.size * 0.45)
            framed: false
            color: parent.iconColor
        }
    }

    component SideLinkButton: Rectangle {
        property string label: ""
        property string iconName: ""
        property color iconColor: "#2275F4"
        signal clicked

        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(42)
        radius: VfTheme.dp(12)
        color: sideMouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface
        border.color: VfTheme.border
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(14)
            anchors.rightMargin: VfTheme.dp(12)
            spacing: VfTheme.dp(9)

            VfAppIcon {
                name: parent.parent.iconName
                size: VfTheme.dp(20)
                framed: false
                color: parent.parent.iconColor
            }

            Text {
                Layout.fillWidth: true
                text: parent.parent.label
                color: "#1668E8"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            VfAppIcon {
                name: "chevron-right"
                size: VfTheme.dp(13)
                framed: false
                color: VfTheme.textSubtle
            }
        }

        MouseArea {
            id: sideMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component FooterButton: Rectangle {
        property string label: ""
        property string iconName: ""
        property bool primary: false
        signal clicked

        Layout.preferredWidth: primary ? VfTheme.dp(136) : VfTheme.dp(138)
        Layout.preferredHeight: VfTheme.dp(46)
        radius: VfTheme.dp(10)
        color: primary ? "#2478F5" : (footerMouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface)
        border.color: primary ? "#2478F5" : VfTheme.border
        border.width: 1

        RowLayout {
            anchors.centerIn: parent
            spacing: VfTheme.dp(8)

            VfAppIcon {
                name: parent.parent.iconName
                size: VfTheme.dp(20)
                framed: false
                color: parent.parent.primary ? "#FFFFFF" : (parent.parent.iconName === "cross-mark" ? VfTheme.text : "#2478F5")
            }

            Text {
                text: parent.parent.label
                color: parent.parent.primary ? "#FFFFFF" : VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                font.weight: Font.Medium
            }
        }

        MouseArea {
            id: footerMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component IconButton: Rectangle {
        property string iconName: ""
        property string tooltip: ""
        signal clicked

        width: VfTheme.dp(32)
        height: VfTheme.dp(32)
        radius: VfTheme.dp(8)
        color: iconMouse.containsMouse ? VfTheme.surfaceSoft : "transparent"

        VfAppIcon {
            anchors.centerIn: parent
            name: iconName
            size: VfTheme.dp(17)
            framed: false
            color: VfTheme.text
        }

        MouseArea {
            id: iconMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }

        ToolTip.visible: iconMouse.containsMouse && tooltip.length > 0
        ToolTip.text: tooltip
        ToolTip.delay: 450
    }

}
