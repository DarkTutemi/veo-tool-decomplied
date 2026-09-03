pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "browserInspector"
    clip: true
    property var profile: ({})
    property bool canWrite: false
    property var controlPlaneBridge: null
    property var channelProfileModel: null
    property int commandRevision: 0
    property int selectedTab: 0
    property bool pinned: false
    property color pinnedTone: Theme.accent
    signal launchRequested()
    signal closeRequested()
    signal dismissRequested()
    signal scanRequested()
    signal proxyCheckRequested()
    signal deepLinkRequested(var link)
    signal overflowRequested()

    readonly property string profileId: String((root.profile || {}).profileId || "")
    readonly property var commandStore: root.controlPlaneBridge
        ? root.controlPlaneBridge.commandStore : null
    readonly property bool launchBusy: {
        const revision = root.commandRevision
        return root.commandStore && root.profileId.length > 0
            ? root.commandStore.isBusy("browser.profile.launch", "profile", root.profileId)
            : false
    }
    readonly property bool closeBusy: {
        const revision = root.commandRevision
        return root.commandStore && root.profileId.length > 0
            ? root.commandStore.isBusy("browser.profile.close", "profile", root.profileId)
            : false
    }
    readonly property bool scanBusy: {
        const revision = root.commandRevision
        return root.commandStore && root.profileId.length > 0
            ? root.commandStore.isBusy("browser.profile.scan", "browser_profile", root.profileId)
            : false
    }
    readonly property bool proxyBusy: {
        const revision = root.commandRevision
        const proxyId = String(((root.profile || {}).proxySummary || {}).proxyId || "")
        return root.commandStore && proxyId.length > 0
            ? root.commandStore.isBusy("proxy.health_check", "proxy", proxyId)
            : false
    }
    readonly property bool canScan: ["youtube", "facebook", "tiktok"].indexOf(
        String(((root.profile || {}).platformSummary || {}).primary || "")) >= 0
    readonly property var visibleAdvisories: {
        const advisories = (root.profile || {}).advisories || []
        return advisories.length > 0 ? advisories : ((root.profile || {}).warnings || [])
    }
    Accessible.name: root.profileId.length > 0
        ? "Chi tiết browser " + String(root.profile.label || root.profileId)
        : "Chi tiết browser, chưa chọn"
    Accessible.role: Accessible.Pane

    function hasValue(value) {
        return value !== undefined && value !== null && String(value).length > 0
    }

    function exact(value) {
        return root.hasValue(value) ? String(value) : "Không khả dụng"
    }

    function bytes(value) {
        if (value === undefined || value === null) return "Không khả dụng"
        const count = Number(value)
        if (count < 1024 * 1024) return Math.round(count / 1024) + " KB"
        if (count < 1024 * 1024 * 1024) return (count / 1024 / 1024).toFixed(1) + " MB"
        return (count / 1024 / 1024 / 1024).toFixed(2) + " GB"
    }

    function primaryAccountMetrics() {
        const accounts = (root.profile || {}).accounts || []
        for (let index = 0; index < accounts.length; index++) {
            if (accounts[index].metrics) return accounts[index].metrics
        }
        return null
    }

    function compactCount(value) {
        if (value === undefined || value === null) return "—"
        const count = Number(value)
        if (count >= 1000000) return (count / 1000000).toFixed(count >= 10000000 ? 0 : 1) + "M"
        if (count >= 1000) return (count / 1000).toFixed(count >= 100000 ? 0 : 1) + "K"
        return String(Math.round(count))
    }

    function platformLabel(value) {
        const normalized = String(value || "").toLowerCase()
        if (normalized === "tiktok") return "TikTok"
        if (normalized === "youtube") return "YouTube"
        if (normalized === "facebook") return "Facebook"
        if (normalized === "instagram") return "Instagram"
        if (normalized === "x") return "X"
        if (normalized === "linkedin") return "LinkedIn"
        return normalized ? String(value) : "Chưa có nền tảng"
    }

    function duration(value) {
        if (value === undefined || value === null) return "—"
        const total = Math.max(0, Math.floor(Number(value)))
        const hours = Math.floor(total / 3600)
        const minutes = Math.floor((total % 3600) / 60)
        const seconds = total % 60
        function pad(part) { return String(part).padStart(2, "0") }
        return pad(hours) + ":" + pad(minutes) + ":" + pad(seconds)
    }

    function processLabel(value) {
        const state = String(value || "").toLowerCase()
        if (["opening", "running"].indexOf(state) >= 0) return "Đang chạy"
        if (state === "closing") return "Đang dừng"
        if (state === "stopped") return "Đã dừng"
        return root.exact(value)
    }

    function proxyDisplay() {
        const proxy = (root.profile || {}).proxySummary || ({})
        const latency = proxy.latencyMs === undefined || proxy.latencyMs === null
            ? "độ trễ —" : String(proxy.latencyMs) + " ms"
        return root.exact(proxy.exitIp) + " · " + root.exact(proxy.countryCode)
            + " · " + latency
    }

    function healthTone(value) {
        const state = String(value || "unknown").toLowerCase()
        if (state === "healthy") return Theme.success
        if (state === "attention") return Theme.warning
        if (state === "critical") return Theme.danger
        return Theme.textFaint
    }

    function healthLabel(value) {
        const state = String(value || "unknown").toLowerCase()
        if (state === "healthy") return "Tốt"
        if (state === "attention") return "Cần chú ý"
        if (state === "critical") return "Nghiêm trọng"
        return "Không rõ"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            Layout.leftMargin: 14
            Layout.rightMargin: 8
            Text {
                text: "Chi tiết Browser"
                color: Theme.text
                font.pixelSize: Theme.fontSection
                font.weight: Font.Bold
            }
            Item { Layout.fillWidth: true }
            Foundation.IconButton {
                objectName: "browserInspectorPin"
                iconName: "ui/pin"
                text: ""
                iconTone: root.pinned ? root.pinnedTone : Theme.textFaint
                accessibleName: root.pinned ? "Bỏ ghim inspector" : "Ghim inspector"
                activeFocusOnTab: true
                enabled: root.profileId.length > 0
                Accessible.description: root.pinned
                    ? "Inspector đang giữ nguyên browser này khi chọn hàng khác"
                    : "Giữ inspector này khi chọn hàng khác"
                onClicked: root.pinned = !root.pinned
                background: Rectangle {
                    radius: 8
                    color: root.pinned ? Theme.accentSoft : "transparent"
                    border.width: 1
                    border.color: root.pinned ? Theme.accent : "transparent"
                }
            }
            Foundation.IconButton {
                objectName: "browserInspectorClose"
                iconName: "ui/close"
                text: ""
                accessibleName: "Đóng inspector browser"
                activeFocusOnTab: true
                enabled: root.profileId.length > 0 && !root.pinned
                onClicked: root.dismissRequested()
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 14
            Layout.rightMargin: 14
            Layout.topMargin: 12
            Layout.bottomMargin: 10
            spacing: 7
            RowLayout {
                Layout.fillWidth: true
                spacing: 9
                Rectangle {
                    Layout.preferredWidth: 38; Layout.preferredHeight: 38; radius: 12
                    color: Theme.elevated
                    UiIcon {
                        anchors.centerIn: parent
                        name: "product/chrome"
                        tone: Theme.text
                        iconSize: 21
                        preserveColors: true
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        objectName: "browserInspectorProfileTitle"
                        Layout.fillWidth: true
                        text: root.profileId.length > 0
                            ? String(root.profile.label || root.profileId) + " · "
                                + root.platformLabel(((root.profile || {}).platformSummary || {}).primary)
                            : "Chưa chọn browser"
                        color: Theme.text
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }
                    Text {
                        objectName: "browserInspectorSessionLine"
                        Layout.fillWidth: true
                        text: root.profileId.length > 0
                            ? root.processLabel(root.profile.processState)
                                + (root.profile.sessionDurationSeconds === undefined
                                    || root.profile.sessionDurationSeconds === null
                                    ? "" : " · Phiên "
                                        + root.duration(root.profile.sessionDurationSeconds))
                            : "Chọn một browser từ inventory"
                        color: Theme.textFaint
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }
                Foundation.StatusPill {
                    text: root.healthLabel(root.profile.healthState)
                    tone: root.healthTone(root.profile.healthState)
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 7
                AppButton {
                    objectName: "browserInspectorLaunch"
                    Layout.fillWidth: true
                    text: root.launchBusy ? "Đang mở…" : "Mở Browser"
                    primary: true
                    activeFocusOnTab: true
                    enabled: root.profileId.length > 0 && root.canWrite
                        && !root.launchBusy && !root.closeBusy
                    Accessible.name: text
                    Accessible.description: enabled
                        ? "Mở browser dưới lease và policy của server"
                        : "Thiếu profile, quyền browser.write hoặc lệnh đang chạy"
                    onClicked: root.launchRequested()
                }
                AppButton {
                    objectName: "browserInspectorStop"
                    text: root.closeBusy ? "Đang dừng…" : "Dừng"
                    activeFocusOnTab: true
                    enabled: root.profileId.length > 0 && root.canWrite
                        && ["opening", "running"].indexOf(String(root.profile.processState || "")) >= 0
                        && !root.closeBusy && !root.launchBusy
                    Accessible.name: text
                    Accessible.description: enabled
                        ? "Yêu cầu đóng browser theo lease rule"
                        : "Browser không chạy, thiếu quyền hoặc lệnh đang xử lý"
                    onClicked: root.closeRequested()
                }
                Foundation.IconButton {
                    objectName: "browserInspectorOverflow"
                    iconName: "ui/more-horizontal"
                    text: ""
                    accessibleName: "Thêm thao tác cho browser"
                    activeFocusOnTab: true
                    enabled: root.profileId.length > 0 && root.canWrite
                    onClicked: root.overflowRequested()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            spacing: 2
            InspectorTab {
                objectName: "browserInspectorTabOverview"
                label: "Tổng quan"
                selected: root.selectedTab === 0
                onActivated: root.selectedTab = 0
            }
            InspectorTab {
                objectName: "browserInspectorTabIdentity"
                label: "Danh tính"
                selected: root.selectedTab === 1
                onActivated: root.selectedTab = 1
            }
            InspectorTab {
                objectName: "browserInspectorTabStorage"
                label: "Storage"
                selected: root.selectedTab === 2
                onActivated: root.selectedTab = 2
            }
            InspectorTab {
                objectName: "browserInspectorTabExtensions"
                label: "Extensions"
                selected: root.selectedTab === 3
                onActivated: root.selectedTab = 3
            }
            InspectorTab {
                objectName: "browserInspectorTabProduction"
                label: "Sản xuất"
                selected: root.selectedTab === 4
                onActivated: root.selectedTab = 4
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.selectedTab

            ScrollView {
                objectName: "browserInspectorOverviewScroll"
                clip: true
                contentWidth: availableWidth
                ColumnLayout {
                    width: parent.width
                    spacing: 4
                    Layout.topMargin: 5
                    SectionLabel { text: "RUNTIME ĐÃ RESOLVE" }
                    InspectorRows {
                        rowHeight: 22
                        rows: [
                            {"objectName": "browserInspectorOsValue", "label": "Hệ điều hành", "value": root.exact((root.profile.identitySummary || {}).osDisplay || (root.profile.identitySummary || {}).os)},
                            {"objectName": "browserInspectorScreenValue", "label": "Màn hình", "value": (root.profile.identitySummary || {}).screen ? String(root.profile.identitySummary.screen.width) + " × " + String(root.profile.identitySummary.screen.height) : "Không khả dụng"},
                            {"objectName": "browserInspectorLocaleValue", "label": "Ngôn ngữ / múi giờ", "value": root.exact((root.profile.identitySummary || {}).locale) + " · " + root.exact((root.profile.identitySummary || {}).timezone)},
                            {"objectName": "browserInspectorFingerprintValue", "label": "Fingerprint", "value": root.exact((root.profile.identitySummary || {}).fingerprintShortId)},
                            {"objectName": "browserInspectorBrowserValue", "label": "Trình duyệt", "value": root.exact((root.profile.identitySummary || {}).browserBuild || (root.profile.identitySummary || {}).engine)},
                            {"objectName": "browserInspectorTemplateValue", "label": "Template", "value": root.exact((root.profile.templateVersion || {}).displayVersion || (root.profile.templateVersion || {}).name)},
                            {"objectName": "browserInspectorProxyValue", "label": "Proxy", "value": root.proxyDisplay()}
                        ]
                    }
                    SectionLabel { text: "TÀI KHOẢN & KÊNH" }
                    Repeater {
                        model: root.profile.accounts || []
                        delegate: Button {
                            id: accountCard
                            required property int index
                            required property var modelData
                            readonly property var metrics: modelData.metrics || null
                            objectName: "browserAccountCard_" + String(modelData.accountId || "")
                            Layout.fillWidth: true
                            Layout.minimumHeight: 68
                            Layout.preferredHeight: 68
                            implicitHeight: 68
                            text: String(modelData.displayName || modelData.externalId || "Tài khoản")
                                + " · " + (modelData.loggedIn ? "Đã đăng nhập" : "Chưa đăng nhập")
                            hoverEnabled: true
                            activeFocusOnTab: true
                            Accessible.name: text
                            Accessible.description: "Mở tài khoản authoritative trong tab Tài khoản"
                            onClicked: root.deepLinkRequested({
                                "route": "channels",
                                "entity": {"type": "account", "id": String(accountCard.modelData.accountId || "")},
                                "context": {"tab": "account"}
                            })
                            contentItem: RowLayout {
                                spacing: 9
                                Rectangle {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    radius: 17
                                    color: Theme.elevated
                                    SocialIcon {
                                        anchors.centerIn: parent
                                        width: 21
                                        height: 21
                                        platform: String(accountCard.modelData.platform || "generic")
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            Layout.fillWidth: true
                                            text: String(accountCard.modelData.displayName
                                                || accountCard.modelData.externalId || "Tài khoản")
                                            color: Theme.text
                                            font.pixelSize: 11
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                        }
                                        Foundation.StatusPill {
                                            text: accountCard.modelData.loggedIn
                                                ? "Đã đăng nhập" : "Chưa đăng nhập"
                                            tone: accountCard.modelData.loggedIn
                                                ? Theme.success : Theme.warning
                                        }
                                    }
                                    Text {
                                        objectName: accountCard.index === 0
                                            ? "browserAccountMetrics"
                                            : "browserAccountMetrics_"
                                                + String(accountCard.modelData.accountId || accountCard.index)
                                        Layout.fillWidth: true
                                        text: accountCard.metrics
                                            ? "Follower " + root.compactCount(accountCard.metrics.followers)
                                                + " · Following " + root.compactCount(accountCard.metrics.following)
                                                + " · Thích " + root.compactCount(accountCard.metrics.likes)
                                            : "Metrics chưa có bằng chứng platform tin cậy"
                                        color: accountCard.metrics ? Theme.textMuted : Theme.warning
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }
                                UiIcon {
                                    name: "ui/chevron-right"
                                    tone: Theme.textFaint
                                    iconSize: 14
                                }
                            }
                            background: Rectangle {
                                radius: Theme.radiusSmall
                                color: accountCard.hovered ? Theme.hover : Theme.elevated
                                border.width: 1
                                border.color: accountCard.activeFocus ? Theme.accent : Theme.borderSoft
                            }
                        }
                    }
                    Repeater {
                        model: root.profile.channels || []
                        delegate: AppButton {
                            id: channelCard
                            required property int index
                            required property var modelData
                            objectName: "browserLinkedChannel_" + String(modelData.channelId || "")
                            Layout.fillWidth: true
                            Layout.minimumHeight: 28
                            implicitHeight: 28
                            text: "Kênh liên kết · " + String(modelData.displayName || modelData.handle || modelData.channelId || "")
                            trailingIcon: "ui/chevron-right"
                            subtle: true
                            activeFocusOnTab: true
                            Accessible.name: text
                            onClicked: root.deepLinkRequested(channelCard.modelData.deepLink || ({
                                "route": "channels",
                                "entity": {"type": "channel", "id": String(channelCard.modelData.channelId || "")},
                                "context": {"tab": "account"}
                            }))
                        }
                    }
                    SectionLabel { text: "SỨC KHỎE & CẢNH BÁO" }
                    Repeater {
                        model: root.visibleAdvisories
                        delegate: Button {
                            id: warningCard
                            required property int index
                            required property var modelData
                            readonly property var targetLink: modelData.deepLink || ({})
                            objectName: "browserWarning_" + String(modelData.incidentId
                                || modelData.advisoryId || modelData.id || modelData.code || index)
                            Layout.fillWidth: true
                            Layout.minimumHeight: 42
                            Layout.preferredHeight: 42
                            implicitHeight: 42
                            text: String(modelData.title || modelData.code || "Cảnh báo")
                                + (targetLink.route ? " · Xem chi tiết" : "")
                            readonly property color severityTone: String(
                                modelData.severity || "").toLowerCase() === "warning"
                                ? Theme.warning : Theme.success
                            enabled: Boolean(targetLink.route)
                            hoverEnabled: true
                            activeFocusOnTab: enabled
                            Accessible.name: text
                            Accessible.role: enabled ? Accessible.Button : Accessible.StaticText
                            Accessible.description: String(modelData.summary || modelData.message
                                || (enabled ? "Mở incident có bằng chứng" : "Trạng thái đã xác minh"))
                            onClicked: root.deepLinkRequested(warningCard.targetLink)
                            contentItem: RowLayout {
                                spacing: 8
                                UiIcon {
                                    name: String(warningCard.modelData.severity
                                        || "").toLowerCase() === "warning"
                                        ? "semantic/alert-triangle" : "semantic/check-circle"
                                    tone: warningCard.severityTone
                                    iconSize: 16
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(warningCard.modelData.title
                                            || warningCard.modelData.code || "Cảnh báo")
                                        color: Theme.text
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(warningCard.modelData.summary
                                            || warningCard.modelData.message || "Đã xác minh")
                                        color: Theme.textFaint
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }
                                UiIcon {
                                    visible: warningCard.enabled
                                    name: "ui/chevron-right"
                                    tone: Theme.textFaint
                                    iconSize: 13
                                }
                            }
                            background: Rectangle {
                                radius: Theme.radiusSmall
                                color: warningCard.hovered && warningCard.enabled
                                    ? Theme.hover : Qt.rgba(
                                        warningCard.severityTone.r,
                                        warningCard.severityTone.g,
                                        warningCard.severityTone.b, 0.08)
                                border.width: 1
                                border.color: Qt.rgba(
                                    warningCard.severityTone.r,
                                    warningCard.severityTone.g,
                                    warningCard.severityTone.b, 0.45)
                            }
                        }
                    }
                    Text {
                        visible: root.visibleAdvisories.length === 0
                        Layout.fillWidth: true
                        text: "Không có incident đang mở trong projection hiện tại."
                        color: Theme.textFaint
                        font.pixelSize: 11
                    }
                }
            }

            ScrollView {
                clip: true
                contentWidth: availableWidth
                ColumnLayout {
                    width: parent.width
                    spacing: 8
                    Layout.topMargin: 10
                    SectionLabel { text: "DANH TÍNH REDACTED" }
                    InspectorRows {
                        rows: [
                            {"label": "Fingerprint ID", "value": root.exact((root.profile.identitySummary || {}).fingerprintShortId)},
                            {"label": "Đóng băng lúc", "value": root.exact((root.profile.identitySummary || {}).identityFrozenAt)},
                            {"label": "OS", "value": root.exact((root.profile.identitySummary || {}).os)},
                            {"label": "Locale", "value": root.exact((root.profile.identitySummary || {}).locale)},
                            {"label": "Timezone", "value": root.exact((root.profile.identitySummary || {}).timezone)},
                            {"label": "Template version", "value": root.exact((root.profile.templateVersion || {}).appliedVersion)},
                            {"label": "Template state", "value": root.exact((root.profile.templateVersion || {}).state)}
                        ]
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Secret và material tạo fingerprint không được phép đi vào UI projection."
                        color: Theme.success
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                }
            }

            ScrollView {
                clip: true
                contentWidth: availableWidth
                ColumnLayout {
                    width: parent.width
                    spacing: 8
                    Layout.topMargin: 10
                    SectionLabel { text: "BỘ NHỚ PROFILE" }
                    InspectorRows {
                        rows: [
                            {"label": "Vault", "value": root.exact((root.profile.storageSummary || {}).vaultId)},
                            {"label": "Tổng dữ liệu", "value": root.bytes((root.profile.storageSummary || {}).totalBytes)},
                            {"label": "Cache", "value": root.bytes((root.profile.storageSummary || {}).cacheBytes)},
                            {"label": "Đo lúc", "value": root.exact((root.profile.storageSummary || {}).sizeScannedAt)}
                        ]
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Đường dẫn profile bị redacted. Mở thư mục chỉ được bật khi có capability kiểm tra canonical path."
                        color: Theme.warning
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                }
            }

            ScrollView {
                clip: true
                contentWidth: availableWidth
                ColumnLayout {
                    width: parent.width
                    spacing: 10
                    Layout.topMargin: 12
                    Text { text: "EXTENSIONS"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                    Text {
                        Layout.fillWidth: true
                        text: "Không khả dụng: browser.inventory.snapshot chưa có signed extension inventory. Không thể suy đoán package, chữ ký hoặc trạng thái cài đặt."
                        color: Theme.warning
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                }
            }

            ChannelProductionProfileEditor {
                objectName: "browserInspectorProductionProfile"
                profile: root.profile
                channelProfileModel: root.channelProfileModel
                controlPlaneBridge: root.controlPlaneBridge
                commandRevision: root.commandRevision
                canWrite: root.canWrite
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            spacing: 7
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                AppButton {
                    objectName: "browserRescanLogin"
                    Layout.fillWidth: true
                    text: root.scanBusy ? "Đang quét…" : "Quét lại đăng nhập"
                    activeFocusOnTab: true
                    enabled: root.profileId.length > 0 && root.canWrite && root.canScan && !root.scanBusy
                    Accessible.name: text
                    Accessible.description: enabled
                        ? "Tạo background browser.profile.scan"
                        : "Nền tảng chưa được scan hỗ trợ, thiếu quyền hoặc đang xử lý"
                    onClicked: root.scanRequested()
                }
                AppButton {
                    objectName: "browserCheckProxy"
                    Layout.fillWidth: true
                    text: root.proxyBusy ? "Đang kiểm tra…" : "Kiểm tra proxy"
                    activeFocusOnTab: true
                    enabled: root.profileId.length > 0 && root.canWrite
                        && String((root.profile.proxySummary || {}).proxyId || "").length > 0
                        && !root.proxyBusy
                    Accessible.name: text
                    Accessible.description: enabled
                        ? "Chạy proxy.health_check trên proxy ID đã gán"
                        : "Thiếu proxy ID, quyền hoặc lệnh đang chạy"
                    onClicked: root.proxyCheckRequested()
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                AppButton {
                    objectName: "browserOpenProfileFolder"
                    Layout.fillWidth: true
                    text: "Mở thư mục profile"
                    activeFocusOnTab: true
                    enabled: root.profileId.length > 0 && root.canWrite
                    Accessible.name: text
                    Accessible.description: enabled
                        ? "Mở thư mục canonical của profile đang chọn"
                        : "Thiếu profile hoặc quyền browser.write"
                    onClicked: root.controlPlaneBridge.openBrowserProfileFolder(root.profileId)
                }
                Foundation.IconButton {
                    objectName: "browserQuickOverflow"
                    iconName: "ui/more-horizontal"
                    text: ""
                    accessibleName: "Thêm thao tác nhanh"
                    activeFocusOnTab: true
                    enabled: root.profileId.length > 0 && root.canWrite
                    onClicked: root.overflowRequested()
                }
            }
        }
    }

    component InspectorTab: Button {
        id: tab
        required property string label
        required property bool selected
        readonly property bool railStyle: true
        signal activated()
        Layout.fillWidth: true
        implicitHeight: 33
        leftPadding: 6
        rightPadding: 6
        text: tab.label
        hoverEnabled: true
        activeFocusOnTab: true
        Accessible.name: tab.label
        Accessible.description: tab.selected ? "Tab inspector đang chọn" : "Chuyển tab inspector"
        Accessible.role: Accessible.PageTab
        onClicked: tab.activated()
        contentItem: Text {
            text: tab.label
            color: tab.selected ? Theme.accent : Theme.textMuted
            font.pixelSize: 11
            font.weight: tab.selected ? Font.DemiBold : Font.Medium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Item {
            Rectangle {
                anchors.fill: parent
                anchors.margins: 3
                radius: Theme.radiusSmall
                color: tab.hovered && !tab.selected ? Theme.hover : "transparent"
            }
            Rectangle {
                objectName: tab.objectName + "_indicator"
                visible: tab.selected
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 5
                anchors.rightMargin: 5
                height: 2
                radius: 1
                color: Theme.accent
            }
            Rectangle {
                anchors.fill: parent
                visible: tab.activeFocus
                radius: Theme.radiusSmall
                color: "transparent"
                border.width: 1
                border.color: Theme.accent
            }
        }
    }

    component SectionLabel: Text {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        color: Theme.textFaint
        font.pixelSize: 11
        font.weight: Font.Bold
        font.letterSpacing: 0.5
    }

    component InspectorRows: ColumnLayout {
        id: rowsRoot
        required property var rows
        property int rowHeight: 27
        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        spacing: 0
        Repeater {
            model: rowsRoot.rows
            delegate: Item {
                id: detailRow
                required property int index
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: rowsRoot.rowHeight
                Accessible.name: String(modelData.label) + ", " + String(modelData.value)
                Accessible.role: Accessible.Row
                RowLayout {
                    anchors.fill: parent
                    spacing: 8
                    Text { Layout.preferredWidth: 114; text: String(detailRow.modelData.label); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                    Text {
                        objectName: String(detailRow.modelData.objectName || "")
                        Layout.fillWidth: true
                        text: String(detailRow.modelData.value)
                        color: text === "Không khả dụng" ? Theme.warning : Theme.textMuted
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideMiddle
                    }
                }
                Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; height: 1; color: Theme.borderSoft }
            }
        }
    }
}
