pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "browserInventory"
    clip: true
    property var profiles
    property var views: ({})
    property var accountItems
    property var proxyItems
    property var templateItems
    property var storageItems
    property var sectionMetadata: ({})
    property var filter: ({})
    property var page: ({})
    property string selectedProfileId: ""
    property var selectedProfileIds: []
    property int selectedSection: 0
    property bool canWrite: false
    property string viewKey: String((filter || {}).view || "all")
    property string platformKey: String((filter || {}).platform || "")
    property string sortKey: String((filter || {}).sort || "last_activity")
    property string sortOrder: String((filter || {}).order || "desc")
    property int pageLimit: Number((filter || {}).limit || 10)
    property bool showProxyColumn: true
    property bool showSessionColumn: true
    property bool showLastActivityColumn: true
    property bool columnChooserOpen: false
    property bool rowMenuOpen: false
    property string rowMenuProfileId: ""
    readonly property real selectColumnWidth: 28
    readonly property real browserColumnWidth: 210
    readonly property real managedChannelColumnWidth: 190
    readonly property real proxyColumnWidth: 160
    readonly property real platformColumnWidth: 92
    readonly property real sessionColumnWidth: 100
    readonly property real healthColumnWidth: 104
    readonly property real lastActivityColumnWidth: 92
    readonly property real overflowColumnWidth: 34
    readonly property int selectedCount: selectedProfileIds.length
    readonly property int cursorOffset: Number((page || {}).cursor || 0)
    readonly property int pageNumber: Math.floor(cursorOffset / Math.max(1, pageLimit)) + 1
    readonly property int totalPages: Math.max(
        1, Math.ceil(Number((page || {}).total || 0) / Math.max(1, pageLimit)))
    readonly property int firstPageButton: Math.max(
        1, Math.min(root.pageNumber - 2, Math.max(1, root.totalPages - 4)))
    readonly property int targetVisibleRowCount: 8
    readonly property real inventoryRowHeight: Math.max(
        64, Number(listViewport.height || 0) / root.targetVisibleRowCount)
    readonly property int fullRowsInViewport: Math.min(
        root.profiles.count,
        Math.max(0, Math.floor(Number(listViewport.height || 0)
            / root.inventoryRowHeight + 0.001)))
    signal sectionSelected(int index)
    signal profileSelected(string profileId)
    signal profileChecked(string profileId, bool checked)
    signal selectVisibleRequested(bool checked)
    signal clearSelectionRequested()
    signal snapshotRequested(var query)
    signal batchPreviewRequested(string operation)
    signal columnChooserRequested()
    signal batchOverflowRequested()
    signal rowOverflowRequested(string profileId)
    signal rowActionRequested(string profileId, string operation)
    signal sectionRowRequested(var link)
    Accessible.name: "Danh sách browser và bộ lọc"
    Accessible.role: Accessible.Pane

    function isSelected(profileId) {
        return root.selectedProfileIds.indexOf(String(profileId || "")) >= 0
    }

    function strictQuery(cursorToken) {
        const query = {
            "limit": Math.max(1, Number(root.pageLimit || 10)),
            "view": String(root.viewKey || "all"),
            "sort": String(root.sortKey || "last_activity"),
            "order": String(root.sortOrder || "desc")
        }
        const search = searchField.text.trim()
        if (search.length > 0) query.search = search
        if (root.platformKey.length > 0) query.platform = root.platformKey
        const cursor = String(cursorToken === undefined || cursorToken === null
            ? "" : cursorToken)
        if (cursor.length > 0) query.cursor = cursor
        if (root.selectedProfileId.length > 0)
            query.selected_profile_id = root.selectedProfileId
        return query
    }

    function applyFilters(cursorToken) {
        root.snapshotRequested(root.strictQuery(cursorToken))
        return true
    }

    function requestPreviousPage() {
        if (root.cursorOffset <= 0) return false
        root.applyFilters(String(Math.max(0, root.cursorOffset - root.pageLimit)))
        return true
    }

    function requestNextPage() {
        const next = String((root.page || {}).next_cursor || "")
        if (!next) return false
        root.applyFilters(next)
        return true
    }

    function requestPage(targetPage) {
        const normalized = Math.max(1, Math.floor(Number(targetPage || 1)))
        if (normalized > root.totalPages || normalized === root.pageNumber) return false
        root.applyFilters(String((normalized - 1) * root.pageLimit))
        return true
    }

    function openRowMenu(profileId) {
        const identity = String(profileId || "")
        if (!identity || !root.canWrite) return false
        root.columnChooserOpen = false
        root.rowMenuProfileId = identity
        root.rowMenuOpen = true
        root.rowOverflowRequested(identity)
        return true
    }

    function rowMenuProfile() {
        for (let index = 0; index < root.profiles.count; index++) {
            const profile = root.profiles.get(index)
            if (String(profile.profileId || "") === root.rowMenuProfileId)
                return profile
        }
        return ({})
    }

    function triggerRowAction(operation) {
        if (!root.rowMenuProfileId || !root.canWrite) return false
        root.rowActionRequested(root.rowMenuProfileId, String(operation || ""))
        root.rowMenuOpen = false
        return true
    }

    function exact(value) {
        return value === undefined || value === null || String(value).length === 0
            ? "—" : String(value)
    }

    function bytes(value) {
        if (value === undefined || value === null) return "Không khả dụng"
        const count = Number(value)
        if (count < 1024 * 1024) return Math.round(count / 1024) + " KB"
        if (count < 1024 * 1024 * 1024) return (count / 1024 / 1024).toFixed(1) + " MB"
        return (count / 1024 / 1024 / 1024).toFixed(2) + " GB"
    }

    function duration(value) {
        if (value === undefined || value === null) return "Đang chạy"
        const total = Math.max(0, Math.floor(Number(value)))
        const hours = Math.floor(total / 3600)
        const minutes = Math.floor((total % 3600) / 60)
        const seconds = total % 60
        function pad(part) { return String(part).padStart(2, "0") }
        return hours > 0
            ? pad(hours) + ":" + pad(minutes) + ":" + pad(seconds)
            : pad(minutes) + ":" + pad(seconds)
    }

    function timestamp(value) {
        if (value === undefined || value === null || String(value).length < 16)
            return "Chưa có dữ liệu"
        const raw = String(value)
        const date = raw.slice(8, 10) + "/" + raw.slice(5, 7) + "/" + raw.slice(0, 4)
        const time = raw.slice(11, 16)
        const zone = raw.endsWith("Z") || raw.indexOf("+00:00") >= 0 ? " UTC" : ""
        return date + " · " + time + zone
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            Layout.leftMargin: 8
            spacing: 2
            SectionTab {
                objectName: "channelsTabBrowser"
                label: "Browser"
                selected: root.selectedSection === 0
                onActivated: root.sectionSelected(0)
            }
            SectionTab {
                objectName: "channelsTabAccount"
                label: "Tài khoản"
                selected: root.selectedSection === 1
                onActivated: root.sectionSelected(1)
            }
            SectionTab {
                objectName: "channelsTabProxy"
                label: "Proxy"
                selected: root.selectedSection === 2
                onActivated: root.sectionSelected(2)
            }
            SectionTab {
                objectName: "channelsTabTemplate"
                label: "Mẫu danh tính"
                selected: root.selectedSection === 3
                onActivated: root.sectionSelected(3)
            }
            SectionTab {
                objectName: "channelsTabStorage"
                label: "Bộ nhớ"
                selected: root.selectedSection === 4
                onActivated: root.sectionSelected(4)
            }
            Item { Layout.fillWidth: true }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.selectedSection

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 54
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        spacing: 7

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 310
                            Layout.preferredHeight: 36
                            radius: Theme.radiusSmall
                            color: Theme.base
                            border.width: 1
                            border.color: searchField.activeFocus ? Theme.accent : Theme.borderSoft
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 8
                                UiIcon { name: "ui/search"; tone: Theme.textFaint; iconSize: 15 }
                                TextField {
                                    id: searchField
                                    objectName: "browserSearchField"
                                    Layout.fillWidth: true
                                    text: String((root.filter || {}).search || "")
                                    placeholderText: "Tìm browser, account, kênh, proxy…"
                                    placeholderTextColor: Theme.textFaint
                                    color: Theme.text
                                    font.pixelSize: 12
                                    background: Item {}
                                    activeFocusOnTab: true
                                    Accessible.name: "Tìm browser, account, kênh hoặc proxy"
                                    Accessible.role: Accessible.EditableText
                                    onAccepted: root.applyFilters("")
                                }
                            }
                        }
                        FilterButton {
                            objectName: "browserFilterAll"
                            label: "Tất cả"
                            countValue: root.views.all
                            selected: root.viewKey === "all"
                            onActivated: { root.viewKey = "all"; root.applyFilters("") }
                        }
                        FilterButton {
                            objectName: "browserFilterRunning"
                            label: "Đang chạy"
                            countValue: root.views.running
                            selected: root.viewKey === "running"
                            onActivated: { root.viewKey = "running"; root.applyFilters("") }
                        }
                        FilterButton {
                            objectName: "browserFilterLoggedIn"
                            label: "Đã đăng nhập"
                            countValue: root.views.loggedIn
                            selected: root.viewKey === "logged_in"
                            onActivated: { root.viewKey = "logged_in"; root.applyFilters("") }
                        }
                        FilterButton {
                            objectName: "browserFilterAttention"
                            label: "Cần chú ý"
                            countValue: root.views.attention
                            selected: root.viewKey === "attention"
                            onActivated: { root.viewKey = "attention"; root.applyFilters("") }
                        }
                        BrowserComboBox {
                            id: platformFilter
                            objectName: "browserPlatformFilter"
                            Layout.preferredWidth: 138
                            Layout.preferredHeight: 36
                            activeFocusOnTab: true
                            Accessible.name: "Lọc theo nền tảng"
                            model: [
                                {"label": "Tất cả nền tảng", "value": ""},
                                {"label": "TikTok", "value": "tiktok"},
                                {"label": "YouTube", "value": "youtube"},
                                {"label": "Facebook", "value": "facebook"},
                                {"label": "Instagram", "value": "instagram"},
                                {"label": "X", "value": "x"},
                                {"label": "LinkedIn", "value": "linkedin"}
                            ]
                            onActivated: {
                                root.platformKey = String(currentValue || "")
                                root.applyFilters("")
                            }
                        }
                        BrowserComboBox {
                            id: sortFilter
                            objectName: "browserSortFilter"
                            Layout.preferredWidth: 152
                            Layout.preferredHeight: 36
                            activeFocusOnTab: true
                            Accessible.name: "Sắp xếp browser"
                            model: [
                                {"label": "Hoạt động mới nhất", "value": "last_activity", "sort": "last_activity", "order": "desc"},
                                {"label": "Tên A đến Z", "value": "label", "sort": "label", "order": "asc"},
                                {"label": "Sức khỏe xấu trước", "value": "health", "sort": "health", "order": "desc"},
                                {"label": "Tạo mới nhất", "value": "created_at", "sort": "created_at", "order": "desc"}
                            ]
                            onActivated: {
                                const choice = model[currentIndex] || ({})
                                root.sortKey = String(choice.sort || "last_activity")
                                root.sortOrder = String(choice.order || "desc")
                                root.applyFilters("")
                            }
                        }
                        Foundation.IconButton {
                            objectName: "browserColumnChooser"
                            iconName: "ui/columns-3"
                            text: ""
                            accessibleName: "Tùy chỉnh cột browser"
                            activeFocusOnTab: true
                            onClicked: {
                                root.rowMenuOpen = false
                                root.columnChooserOpen = !root.columnChooserOpen
                                root.columnChooserRequested()
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

                    RowLayout {
                        visible: root.selectedCount > 0
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? 46 : 0
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        spacing: 6
                        Text {
                            text: "Đã chọn " + String(root.selectedCount)
                            color: Theme.text
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                        AppButton {
                            objectName: "browserClearSelection"
                            text: "Bỏ chọn"
                            subtle: true
                            activeFocusOnTab: true
                            Accessible.name: text
                            onClicked: root.clearSelectionRequested()
                        }
                        BatchButton {
                            objectName: "browserBatchOpen"
                            label: "Mở"
                            enabled: root.canWrite && root.selectedCount > 0
                            reason: "Preview năng lực trước; execute yêu cầu approval server"
                            onActivated: root.batchPreviewRequested("launch")
                        }
                        BatchButton {
                            objectName: "browserBatchStop"
                            label: "Dừng"
                            enabled: root.canWrite && root.selectedCount > 0
                            reason: "Preview lease và browser bị ảnh hưởng trước khi đóng"
                            onActivated: root.batchPreviewRequested("close")
                        }
                        BatchButton {
                            objectName: "browserBatchAssignProxy"
                            label: "Gán proxy"
                            enabled: root.canWrite && root.selectedCount > 0
                            reason: "Server chọn proxy live theo round-robin và đóng băng assignment"
                            onActivated: root.batchPreviewRequested("proxy.assign")
                        }
                        BatchButton {
                            objectName: "browserBatchInstallExtension"
                            label: "Cài extension"
                            enabled: false
                            reason: "Signed extension batch capability chưa được triển khai"
                        }
                        BatchButton {
                            objectName: "browserBatchClearCache"
                            label: "Xóa cache"
                            enabled: root.canWrite && root.selectedCount > 0
                            reason: "Server preview mục cache bảo vệ trước khi xóa"
                            onActivated: root.batchPreviewRequested("cache.clean")
                        }
                        BatchButton {
                            objectName: "browserBatchMuteAudio"
                            label: "Tắt âm thanh"
                            enabled: root.canWrite && root.selectedCount > 0
                            reason: "Persist mute_audio vào runtime policy từng profile"
                            onActivated: root.batchPreviewRequested("runtime_policy.patch")
                        }
                        BatchButton {
                            objectName: "browserBatchCheck"
                            label: "Kiểm tra"
                            enabled: root.canWrite && root.selectedCount > 0
                            reason: "Reconcile registry/storage/identity theo từng profile"
                            onActivated: root.batchPreviewRequested("health.check")
                        }
                        Item { Layout.fillWidth: true }
                        Foundation.IconButton {
                            objectName: "browserBatchOverflow"
                            iconName: "ui/more-horizontal"
                            text: ""
                            accessibleName: "Thêm thao tác batch"
                            activeFocusOnTab: true
                            enabled: root.canWrite && root.selectedCount > 0
                            onClicked: root.batchOverflowRequested()
                        }
                    }

                    Rectangle { visible: root.selectedCount > 0; Layout.fillWidth: true; Layout.preferredHeight: visible ? 1 : 0; color: Theme.borderSoft }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        color: Theme.base
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 8
                            spacing: 8
                            AppCheckBox {
                                objectName: "browserSelectAll"
                                Layout.preferredWidth: root.selectColumnWidth
                                Layout.minimumWidth: root.selectColumnWidth
                                Layout.maximumWidth: root.selectColumnWidth
                                tristate: true
                                checkState: root.selectedCount === 0 ? Qt.Unchecked
                                    : root.selectedCount >= root.profiles.count ? Qt.Checked
                                    : Qt.PartiallyChecked
                                activeFocusOnTab: true
                                Accessible.name: "Chọn tất cả browser trong trang"
                                onClicked: root.selectVisibleRequested(
                                    root.selectedCount < root.profiles.count)
                            }
                            HeaderLabel { objectName: "browserNameHeader"; text: "BROWSER"; Layout.preferredWidth: root.browserColumnWidth; Layout.minimumWidth: root.browserColumnWidth; Layout.maximumWidth: root.browserColumnWidth }
                            HeaderLabel { objectName: "browserManagedChannelHeader"; text: "KÊNH QUẢN LÝ"; Layout.preferredWidth: root.managedChannelColumnWidth; Layout.minimumWidth: root.managedChannelColumnWidth; Layout.maximumWidth: root.managedChannelColumnWidth }
                            HeaderLabel { objectName: "browserIdentityHeader"; text: "DANH TÍNH"; Layout.fillWidth: true; Layout.minimumWidth: 120 }
                            HeaderLabel {
                                objectName: "browserProxyHeader"
                                text: "PROXY"
                                visible: root.showProxyColumn
                                Layout.preferredWidth: visible ? root.proxyColumnWidth : 0
                                Layout.minimumWidth: visible ? root.proxyColumnWidth : 0
                                Layout.maximumWidth: visible ? root.proxyColumnWidth : 0
                            }
                            HeaderLabel { objectName: "browserPlatformHeader"; text: "NỀN TẢNG"; Layout.preferredWidth: root.platformColumnWidth; Layout.minimumWidth: root.platformColumnWidth; Layout.maximumWidth: root.platformColumnWidth; horizontalAlignment: Text.AlignHCenter }
                            HeaderLabel {
                                objectName: "browserSessionHeader"
                                text: "PHIÊN"
                                visible: root.showSessionColumn
                                Layout.preferredWidth: visible ? root.sessionColumnWidth : 0
                                Layout.minimumWidth: visible ? root.sessionColumnWidth : 0
                                Layout.maximumWidth: visible ? root.sessionColumnWidth : 0
                            }
                            HeaderLabel { objectName: "browserHealthHeader"; text: "SỨC KHỎE"; Layout.preferredWidth: root.healthColumnWidth; Layout.minimumWidth: root.healthColumnWidth; Layout.maximumWidth: root.healthColumnWidth; horizontalAlignment: Text.AlignHCenter }
                            HeaderLabel {
                                objectName: "browserLastActivityHeader"
                                text: "GẦN NHẤT"
                                visible: root.showLastActivityColumn
                                Layout.preferredWidth: visible ? root.lastActivityColumnWidth : 0
                                Layout.minimumWidth: visible ? root.lastActivityColumnWidth : 0
                                Layout.maximumWidth: visible ? root.lastActivityColumnWidth : 0
                            }
                            Item { Layout.preferredWidth: root.overflowColumnWidth; Layout.minimumWidth: root.overflowColumnWidth; Layout.maximumWidth: root.overflowColumnWidth }
                        }
                    }

                    ScrollView {
                        id: listViewport
                        objectName: "browserInventoryListViewport"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentWidth: availableWidth
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        Column {
                            id: listColumn
                            width: parent.width
                            spacing: 0
                            Repeater {
                                model: root.profiles
                                delegate: Rectangle {
                                    id: browserRow
                                    required property int index
                                    required property string profileId
                                    required property var label
                                    required property var processState
                                    required property var lease
                                    required property var platformSummary
                                    required property var channelSummary
                                    required property var templateVersion
                                    required property var identitySummary
                                    required property var proxySummary
                                    required property var sessionStartedAt
                                    required property var sessionDurationSeconds
                                    required property var memoryBytes
                                    required property var healthState
                                    required property var lastActivityAt
                                    signal activate()
                                    objectName: "browserRow_" + profileId
                                    width: listColumn.width
                                    height: root.inventoryRowHeight
                                    color: root.selectedProfileId === profileId
                                        ? Theme.accentSoft : (rowMouse.containsMouse ? Theme.hover : "transparent")
                                    border.width: root.selectedProfileId === profileId ? 1 : 0
                                    border.color: Theme.accent
                                    Accessible.name: "Browser " + String(browserRow.label || profileId)
                                    Accessible.role: Accessible.Row
                                    activeFocusOnTab: true
                                    Accessible.focusable: true
                                    Keys.onReturnPressed: browserRow.activate()
                                    Keys.onEnterPressed: browserRow.activate()
                                    Keys.onSpacePressed: browserRow.activate()
                                    onActivate: root.profileSelected(profileId)

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 8
                                        spacing: 8
                                        AppCheckBox {
                                            objectName: "browserRowCheck_" + browserRow.profileId
                                            Layout.preferredWidth: root.selectColumnWidth
                                            Layout.minimumWidth: root.selectColumnWidth
                                            Layout.maximumWidth: root.selectColumnWidth
                                            checked: root.isSelected(browserRow.profileId)
                                            activeFocusOnTab: true
                                            Accessible.name: "Chọn " + String(browserRow.label || browserRow.profileId)
                                            onClicked: root.profileChecked(browserRow.profileId, checked)
                                        }
                                        RowLayout {
                                            objectName: "browserNameCell_" + browserRow.profileId
                                            Layout.preferredWidth: root.browserColumnWidth
                                            Layout.minimumWidth: root.browserColumnWidth
                                            Layout.maximumWidth: root.browserColumnWidth
                                            spacing: 8
                                            Rectangle {
                                                Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 14
                                                color: Theme.elevated
                                                UiIcon {
                                                    anchors.centerIn: parent
                                                    name: "product/chrome"
                                                    tone: Theme.textMuted
                                                    iconSize: 17
                                                    preserveColors: true
                                                }
                                            }
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 1
                                                Text { Layout.fillWidth: true; text: String(browserRow.label || browserRow.profileId); color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                                Text { Layout.fillWidth: true; text: root.exact(browserRow.processState) + " · " + root.exact((browserRow.lease || {}).state); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                            }
                                        }
                                        RowLayout {
                                            objectName: "browserManagedChannelCell_" + browserRow.profileId
                                            Layout.preferredWidth: root.managedChannelColumnWidth
                                            Layout.minimumWidth: root.managedChannelColumnWidth
                                            Layout.maximumWidth: root.managedChannelColumnWidth
                                            spacing: 7
                                            SocialIcon { platform: String((browserRow.platformSummary || {}).primary || "generic"); Layout.preferredWidth: 18; Layout.preferredHeight: 18 }
                                            ColumnLayout {
                                                Layout.fillWidth: true; spacing: 1
                                                Text { Layout.fillWidth: true; text: root.exact((browserRow.channelSummary || {}).displayName); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                                                Text { Layout.fillWidth: true; text: root.exact((browserRow.channelSummary || {}).handle); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                            }
                                        }
                                        ColumnLayout {
                                            objectName: "browserIdentityCell_" + browserRow.profileId
                                            Layout.fillWidth: true; Layout.minimumWidth: 120; spacing: 1
                                            Text { Layout.fillWidth: true; text: root.exact((browserRow.identitySummary || {}).label || (browserRow.templateVersion || {}).name); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                                            Text { Layout.fillWidth: true; text: root.exact((browserRow.identitySummary || {}).osDisplay || (browserRow.identitySummary || {}).os) + " · " + root.exact((browserRow.identitySummary || {}).locale); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                        }
                                        ColumnLayout {
                                            objectName: "browserProxyCell_" + browserRow.profileId
                                            visible: root.showProxyColumn
                                            Layout.preferredWidth: visible ? root.proxyColumnWidth : 0
                                            Layout.minimumWidth: visible ? root.proxyColumnWidth : 0
                                            Layout.maximumWidth: visible ? root.proxyColumnWidth : 0
                                            spacing: 1
                                            Text { Layout.fillWidth: true; text: root.exact((browserRow.proxySummary || {}).exitIp); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideMiddle }
                                            Text { Layout.fillWidth: true; text: root.exact((browserRow.proxySummary || {}).countryCode) + " · " + ((browserRow.proxySummary || {}).latencyMs === null || (browserRow.proxySummary || {}).latencyMs === undefined ? "Độ trễ —" : String((browserRow.proxySummary || {}).latencyMs) + " ms"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                        }
                                        Item {
                                            objectName: "browserPlatformCell_" + browserRow.profileId
                                            Layout.preferredWidth: root.platformColumnWidth
                                            Layout.minimumWidth: root.platformColumnWidth
                                            Layout.maximumWidth: root.platformColumnWidth
                                            Layout.fillHeight: true
                                            SocialIcon {
                                                anchors.centerIn: parent
                                                platform: String((browserRow.platformSummary || {}).primary || "generic")
                                                width: 22
                                                height: 22
                                            }
                                        }
                                        ColumnLayout {
                                            objectName: "browserSessionCell_" + browserRow.profileId
                                            visible: root.showSessionColumn
                                            Layout.preferredWidth: visible ? root.sessionColumnWidth : 0
                                            Layout.minimumWidth: visible ? root.sessionColumnWidth : 0
                                            Layout.maximumWidth: visible ? root.sessionColumnWidth : 0
                                            spacing: 1
                                            Text {
                                                text: browserRow.sessionStartedAt
                                                    ? root.duration(browserRow.sessionDurationSeconds) : "—"
                                                color: Theme.textMuted
                                                font.pixelSize: 11
                                            }
                                            Text { text: browserRow.memoryBytes === null || browserRow.memoryBytes === undefined ? "RAM không có" : root.bytes(browserRow.memoryBytes); color: browserRow.memoryBytes === null || browserRow.memoryBytes === undefined ? Theme.warning : Theme.textFaint; font.pixelSize: 11 }
                                        }
                                        Foundation.StatusPill {
                                            objectName: "browserHealthCell_" + browserRow.profileId
                                            Layout.preferredWidth: root.healthColumnWidth
                                            Layout.minimumWidth: root.healthColumnWidth
                                            Layout.maximumWidth: root.healthColumnWidth
                                            text: root.healthLabel(browserRow.healthState)
                                            tone: root.healthTone(browserRow.healthState)
                                        }
                                        Foundation.RelativeTimeText {
                                            objectName: "browserLastActivityCell_" + browserRow.profileId
                                            visible: root.showLastActivityColumn
                                            Layout.preferredWidth: visible ? root.lastActivityColumnWidth : 0
                                            Layout.minimumWidth: visible ? root.lastActivityColumnWidth : 0
                                            Layout.maximumWidth: visible ? root.lastActivityColumnWidth : 0
                                            timestamp: String(browserRow.lastActivityAt || "")
                                        }
                                        Foundation.IconButton {
                                            objectName: "browserRowOverflow_" + browserRow.profileId
                                            iconName: "ui/more-horizontal"
                                            text: ""
                                            accessibleName: "Thao tác cho " + String(browserRow.label || browserRow.profileId)
                                            activeFocusOnTab: true
                                            Layout.preferredWidth: root.overflowColumnWidth
                                            Layout.minimumWidth: root.overflowColumnWidth
                                            Layout.maximumWidth: root.overflowColumnWidth
                                            onClicked: root.openRowMenu(browserRow.profileId)
                                        }
                                    }
                                    MouseArea {
                                        id: rowMouse
                                        anchors.fill: parent
                                        anchors.leftMargin: 46
                                        anchors.rightMargin: 44
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: browserRow.activate()
                                    }
                                }
                            }
                            Text {
                                visible: root.profiles.count === 0
                                width: listColumn.width
                                height: 86
                                text: "Không có browser phù hợp với truy vấn hiện tại"
                                color: Theme.textFaint
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        Layout.leftMargin: 12
                        Layout.rightMargin: 8
                        spacing: 6
                        Text {
                            objectName: "browserVisibleWindowLabel"
                            Layout.fillWidth: true
                            text: root.fullRowsInViewport > 0
                                ? "Trong khung " + String(root.cursorOffset + 1) + "–"
                                    + String(root.cursorOffset + root.fullRowsInViewport)
                                    + " · đã tải " + String(root.profiles.count) + " / "
                                    + ((root.page || {}).total === undefined
                                        ? "—" : String(root.page.total))
                                : "Đã tải " + String(root.profiles.count) + " / "
                                    + ((root.page || {}).total === undefined
                                        ? "—" : String(root.page.total))
                            color: Theme.textFaint
                            font.pixelSize: 11
                        }
                        Foundation.IconButton {
                            objectName: "browserPreviousPage"
                            iconName: "ui/chevron-left"
                            text: ""
                            accessibleName: "Trang browser trước"
                            activeFocusOnTab: true
                            enabled: root.cursorOffset > 0
                            onClicked: root.requestPreviousPage()
                        }
                        Repeater {
                            model: 5
                            delegate: AppButton {
                                id: pageButton
                                required property int index
                                readonly property int targetPage: root.firstPageButton + index
                                objectName: "browserPageButton_" + String(pageButton.targetPage)
                                Layout.preferredWidth: 34
                                Layout.preferredHeight: 30
                                leftPadding: 0
                                rightPadding: 0
                                text: String(pageButton.targetPage)
                                primary: pageButton.targetPage === root.pageNumber
                                subtle: !primary
                                visible: true
                                enabled: pageButton.targetPage <= root.totalPages
                                activeFocusOnTab: true
                                Accessible.name: enabled
                                    ? "Trang browser " + text
                                    : "Trang " + text + " không có dữ liệu"
                                Accessible.description: primary ? "Trang đang chọn"
                                    : (enabled ? "Mở trang" : "Ngoài tổng số trang authoritative")
                                onClicked: root.requestPage(pageButton.targetPage)
                            }
                        }
                        Foundation.IconButton {
                            objectName: "browserNextPage"
                            iconName: "ui/chevron-right"
                            text: ""
                            accessibleName: "Trang browser tiếp theo"
                            activeFocusOnTab: true
                            enabled: String((root.page || {}).next_cursor || "").length > 0
                            onClicked: root.requestNextPage()
                        }
                        BrowserComboBox {
                            objectName: "browserPageSize"
                            Layout.preferredWidth: 104
                            Layout.preferredHeight: 34
                            Accessible.name: "Số browser mỗi trang"
                            model: [
                                {"label": "10 / trang", "value": 10},
                                {"label": "25 / trang", "value": 25},
                                {"label": "50 / trang", "value": 50},
                                {"label": "100 / trang", "value": 100}
                            ]
                            currentIndex: root.pageLimit === 100 ? 3
                                : (root.pageLimit === 50 ? 2
                                    : (root.pageLimit === 25 ? 1 : 0))
                            onActivated: {
                                root.pageLimit = Number(currentValue || 10)
                                root.applyFilters("")
                            }
                        }
                    }
                }
            }

            AuthoritativeProjection {
                objectName: "browserAccountsProjection"
                kind: "account"
                metadata: (root.sectionMetadata || {}).account || ({})
                rows: root.accountItems
                onRowRequested: function(link) { root.sectionRowRequested(link) }
            }
            AuthoritativeProjection {
                objectName: "browserProxyProjection"
                kind: "proxy"
                metadata: (root.sectionMetadata || {}).proxy || ({})
                rows: root.proxyItems
                onRowRequested: function(link) { root.sectionRowRequested(link) }
            }
            AuthoritativeProjection {
                objectName: "browserTemplateProjection"
                kind: "template"
                metadata: (root.sectionMetadata || {}).template || ({})
                rows: root.templateItems
                onRowRequested: function(link) { root.sectionRowRequested(link) }
            }
            AuthoritativeProjection {
                objectName: "browserStorageProjection"
                kind: "storage"
                metadata: (root.sectionMetadata || {}).storage || ({})
                rows: root.storageItems
                onRowRequested: function(link) { root.sectionRowRequested(link) }
            }
        }
    }

    Rectangle {
        id: columnChooserPopup
        objectName: "browserColumnChooserPopup"
        visible: root.columnChooserOpen
        width: 220
        height: 138
        x: root.width - width - 12
        y: 98
        z: 40
        radius: Theme.radiusSmall
        color: Theme.panel
        border.width: 1
        border.color: Theme.border
        Accessible.name: "Tùy chỉnh cột browser cho phiên hiện tại"
        Accessible.role: Accessible.PopupMenu

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 7
            spacing: 3
            ColumnToggle {
                objectName: "browserColumnProxyToggle"
                label: "Proxy"
                checked: root.showProxyColumn
                onActivated: root.showProxyColumn = checked
            }
            ColumnToggle {
                objectName: "browserColumnSessionToggle"
                label: "Phiên & RAM"
                checked: root.showSessionColumn
                onActivated: root.showSessionColumn = checked
            }
            ColumnToggle {
                objectName: "browserColumnLastActiveToggle"
                label: "Hoạt động gần nhất"
                checked: root.showLastActivityColumn
                onActivated: root.showLastActivityColumn = checked
            }
        }
    }

    Rectangle {
        id: profileActionMenu
        objectName: "browserProfileActionMenu"
        property string profileId: root.rowMenuProfileId
        readonly property var targetProfile: root.rowMenuProfile()
        visible: root.rowMenuOpen
        width: 232
        height: 190
        x: root.width - width - 12
        y: 138
        z: 45
        radius: Theme.radiusSmall
        color: Theme.panel
        border.width: 1
        border.color: Theme.border
        Accessible.name: "Thao tác browser "
            + String(targetProfile.label || profileId)
        Accessible.role: Accessible.PopupMenu
        Keys.onEscapePressed: root.rowMenuOpen = false

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 3
            MenuAction {
                objectName: "browserProfileMenuLaunch"
                label: "Mở Browser"
                iconName: "ui/play"
                enabled: root.canWrite && profileActionMenu.profileId.length > 0
                onActivated: root.triggerRowAction("launch")
            }
            MenuAction {
                objectName: "browserProfileMenuClose"
                label: "Dừng Browser"
                iconName: "ui/power"
                enabled: root.canWrite && ["opening", "running"].indexOf(
                    String(profileActionMenu.targetProfile.processState || "")) >= 0
                onActivated: root.triggerRowAction("close")
            }
            MenuAction {
                objectName: "browserProfileMenuScan"
                label: "Quét lại đăng nhập"
                iconName: "ui/refresh-cw"
                enabled: root.canWrite && ["youtube", "facebook", "tiktok"].indexOf(
                    String(((profileActionMenu.targetProfile || {}).platformSummary || {}).primary || "")) >= 0
                onActivated: root.triggerRowAction("scan")
            }
            MenuAction {
                objectName: "browserProfileMenuProxy"
                label: "Kiểm tra proxy"
                iconName: "semantic/check-circle"
                enabled: root.canWrite && String(
                    ((profileActionMenu.targetProfile || {}).proxySummary || {}).proxyId || "").length > 0
                onActivated: root.triggerRowAction("proxy.check")
            }
        }
    }

    function healthLabel(state) {
        const normalized = String(state || "unknown").toLowerCase()
        if (normalized === "healthy") return "Tốt"
        if (normalized === "attention") return "Chú ý"
        if (normalized === "critical") return "Nghiêm trọng"
        return "Không rõ"
    }

    function healthTone(state) {
        const normalized = String(state || "unknown").toLowerCase()
        if (normalized === "healthy") return Theme.success
        if (normalized === "attention") return Theme.warning
        if (normalized === "critical") return Theme.danger
        return Theme.textFaint
    }

    component SectionTab: Button {
        id: tab
        required property string label
        required property bool selected
        readonly property bool railStyle: true
        signal activated()
        text: tab.label
        implicitHeight: 42
        leftPadding: 14
        rightPadding: 14
        hoverEnabled: true
        activeFocusOnTab: true
        Accessible.name: tab.label
        Accessible.description: tab.selected ? "Tab đang chọn" : "Chuyển vùng inventory"
        Accessible.role: Accessible.PageTab
        onClicked: tab.activated()
        contentItem: Text {
            text: tab.label
            color: tab.selected ? Theme.accent : Theme.textMuted
            font.pixelSize: 12
            font.weight: tab.selected ? Font.DemiBold : Font.Medium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Item {
            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: Theme.radiusSmall
                color: tab.hovered && !tab.selected ? Theme.hover : "transparent"
            }
            Rectangle {
                objectName: tab.objectName + "_indicator"
                visible: tab.selected
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 8
                anchors.rightMargin: 8
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

    component FilterButton: AppButton {
        id: chip
        required property string label
        required property bool selected
        required property var countValue
        signal activated()
        implicitHeight: 34
        leftPadding: 10
        rightPadding: 10
        text: chip.label + (chip.countValue === undefined
            || chip.countValue === null ? "" : " " + String(chip.countValue))
        primary: chip.selected
        activeFocusOnTab: true
        Accessible.name: "Lọc " + chip.label
        onClicked: chip.activated()
    }

    component BatchButton: AppButton {
        id: batchButton
        required property string label
        property string reason: ""
        signal activated()
        implicitHeight: 32
        leftPadding: 10
        rightPadding: 10
        text: batchButton.label
        activeFocusOnTab: true
        Accessible.name: batchButton.label
        Accessible.description: batchButton.reason
        onClicked: batchButton.activated()
    }

    component ColumnToggle: Button {
        id: columnToggle
        required property string label
        signal activated()
        Layout.fillWidth: true
        Layout.preferredHeight: 38
        checkable: true
        hoverEnabled: true
        activeFocusOnTab: true
        Accessible.name: "Hiện cột " + columnToggle.label
        Accessible.role: Accessible.CheckBox
        onClicked: columnToggle.activated()
        contentItem: RowLayout {
            spacing: 8
            UiIcon {
                name: columnToggle.checked
                    ? "semantic/check-circle" : "ui/minus"
                tone: columnToggle.checked ? Theme.success : Theme.textFaint
                iconSize: 14
            }
            Text {
                Layout.fillWidth: true
                text: columnToggle.label
                color: Theme.textMuted
                font.pixelSize: 11
            }
        }
        background: Rectangle {
            radius: 5
            color: columnToggle.hovered ? Theme.hover : "transparent"
        }
    }

    component MenuAction: Button {
        id: menuAction
        required property string label
        required property string iconName
        signal activated()
        Layout.fillWidth: true
        Layout.preferredHeight: 41
        hoverEnabled: true
        activeFocusOnTab: true
        Accessible.name: menuAction.label
        Accessible.description: enabled ? "Thực thi capability semantic"
            : "Không khả dụng cho profile hoặc thiếu quyền"
        onClicked: menuAction.activated()
        contentItem: RowLayout {
            spacing: 9
            UiIcon {
                name: menuAction.iconName
                tone: menuAction.enabled ? Theme.info : Theme.textFaint
                iconSize: 15
            }
            Text {
                Layout.fillWidth: true
                text: menuAction.label
                color: menuAction.enabled ? Theme.textMuted : Theme.textFaint
                font.pixelSize: 11
            }
        }
        background: Rectangle {
            radius: 5
            color: menuAction.hovered && menuAction.enabled
                ? Theme.hover : "transparent"
        }
    }

    component HeaderLabel: Text {
        color: Theme.textFaint
        font.pixelSize: 11
        font.weight: Font.Bold
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    component AuthoritativeProjection: Item {
        id: section
        required property string kind
        required property var metadata
        required property var rows
        signal rowRequested(var link)
        readonly property int rowCount: section.rows && section.rows.count !== undefined
            ? Number(section.rows.count) : ((section.rows || []).length || 0)
        readonly property string sectionTitle: String(section.metadata.title
            || section.defaultTitle())
        readonly property var summaryItems: section.buildSummary()
        Accessible.name: section.sectionTitle
        Accessible.role: Accessible.Pane

        function rowAt(index) {
            if (!section.rows) return ({})
            if (section.rows.get) return section.rows.get(index) || ({})
            return section.rows[index] || ({})
        }

        function defaultTitle() {
            if (section.kind === "account") return "Tài khoản & kênh"
            if (section.kind === "proxy") return "Hạ tầng proxy"
            if (section.kind === "template") return "Hồ sơ danh tính"
            return "Dung lượng browser"
        }

        function description() {
            if (section.kind === "account")
                return "Theo dõi đăng nhập, kênh liên kết, chỉ số và lần quét gần nhất trên toàn bộ đội kênh."
            if (section.kind === "proxy")
                return "Quan sát IP thoát, vị trí, độ trễ và browser đang dùng proxy; credential luôn được ẩn."
            if (section.kind === "template")
                return "Quản lý phiên bản danh tính, môi trường chạy và phạm vi browser đã áp dụng."
            return "Theo dõi dung lượng đã dùng, còn trống và lần kiểm tra của từng vault đã đăng ký."
        }

        function compactCount(value) {
            if (value === undefined || value === null) return "—"
            const count = Number(value)
            if (count >= 1000000)
                return (count / 1000000).toFixed(count >= 10000000 ? 0 : 1) + "M"
            if (count >= 1000)
                return (count / 1000).toFixed(count >= 100000 ? 0 : 1) + "K"
            return String(Math.round(count))
        }

        function countWhere(field, expected) {
            let total = 0
            for (let index = 0; index < section.rowCount; index++) {
                const row = section.rowAt(index)
                if (row[field] === expected) total += 1
            }
            return total
        }

        function sumField(field) {
            let total = 0
            for (let index = 0; index < section.rowCount; index++)
                total += Number(section.rowAt(index)[field] || 0)
            return total
        }

        function buildSummary() {
            if (section.kind === "account") {
                return [
                    {"label": "Đã nhận diện", "value": section.rowCount, "tone": "info"},
                    {"label": "Đang đăng nhập", "value": section.countWhere("loggedIn", true), "tone": "success"},
                    {"label": "Cần xử lý", "value": section.rowCount - section.countWhere("loggedIn", true) + section.countWhere("authFreshness", "stale"), "tone": "warning"}
                ]
            }
            if (section.kind === "proxy") {
                let latencyTotal = 0
                let latencyCount = 0
                for (let index = 0; index < section.rowCount; index++) {
                    const latency = section.rowAt(index).latencyMs
                    if (latency !== undefined && latency !== null) {
                        latencyTotal += Number(latency)
                        latencyCount += 1
                    }
                }
                return [
                    {"label": "Proxy hoạt động", "value": section.countWhere("status", "live"), "tone": "success"},
                    {"label": "Browser đã gán", "value": section.sumField("assignedProfileCount"), "tone": "info"},
                    {"label": "Độ trễ trung bình", "value": latencyCount > 0 ? Math.round(latencyTotal / latencyCount) + " ms" : "—", "tone": "warning"}
                ]
            }
            if (section.kind === "template") {
                return [
                    {"label": "Mẫu danh tính", "value": section.rowCount, "tone": "info"},
                    {"label": "Mặc định", "value": section.countWhere("isDefault", true), "tone": "success"},
                    {"label": "Browser áp dụng", "value": section.sumField("assignedProfileCount"), "tone": "accent"}
                ]
            }
            return [
                {"label": "Kho lưu trữ", "value": section.rowCount, "tone": "info"},
                {"label": "Đã dùng", "value": root.bytes(section.sumField("usedBytes")), "tone": "accent"},
                {"label": "Còn trống", "value": root.bytes(section.sumField("freeBytes")), "tone": "success"}
            ]
        }

        function tone(name) {
            if (name === "success") return Theme.success
            if (name === "warning") return Theme.warning
            if (name === "accent") return Theme.accent
            return Theme.info
        }

        function rowId(row) {
            if (section.kind === "account") return String(row.accountId || "")
            if (section.kind === "proxy") return String(row.proxyId || "")
            if (section.kind === "template") return String(row.templateId || "")
            return String(row.vaultId || "")
        }

        function rowTitle(row) {
            if (section.kind === "account")
                return String(row.displayName || row.externalId || "Tài khoản không tên")
            if (section.kind === "proxy")
                return String(row.label || row.exitIp || "Proxy chưa đặt tên")
            if (section.kind === "template")
                return String(row.name || "Template chưa đặt tên")
            return String(row.label || row.vaultId || "Kho chưa đặt tên")
        }

        function rowDetail(row) {
            if (section.kind === "account")
                return String(row.platform || "unknown") + " · "
                    + (row.loggedIn ? "Đã đăng nhập" : "Chưa đăng nhập")
                    + " · " + String(row.authFreshness || "chưa có freshness")
            if (section.kind === "proxy")
                return String(row.exitIp || "IP chưa có") + " · "
                    + String(row.countryCode || "—") + " · "
                    + (row.latencyMs === null || row.latencyMs === undefined
                        ? "Độ trễ —" : String(row.latencyMs) + " ms")
            if (section.kind === "template")
                return String(row.displayVersion || ("v" + String(row.version || "—")))
                    + " · " + String(row.platform || "generic")
                    + " · " + String(row.os || "—")
            return root.bytes(row.usedBytes) + " đã dùng / "
                + root.bytes(row.totalBytes) + " · "
                + String(row.profileCount || 0) + " profile"
        }

        function accountStatus(row) {
            if (!row.loggedIn) return "Chưa đăng nhập"
            return String(row.authFreshness || "unknown") === "fresh"
                ? "Đã đăng nhập · Tươi" : "Đã đăng nhập · Cần làm mới"
        }

        function accountStatusTone(row) {
            if (!row.loggedIn) return Theme.danger
            return String(row.authFreshness || "unknown") === "fresh"
                ? Theme.success : Theme.warning
        }

        function accountMetrics(row) {
            const metrics = row.metrics === undefined || row.metrics === null
                ? ({}) : row.metrics
            return "Follower " + section.compactCount(metrics.followers)
                + " · Đang theo dõi " + section.compactCount(metrics.following)
                + " · Thích " + section.compactCount(metrics.likes)
        }

        function accountEvidence(row) {
            const evidence = row.operationEvidence === undefined
                || row.operationEvidence === null ? ({}) : row.operationEvidence
            const verification = String(evidence.verification || "")
            const state = verification.indexOf("verified") >= 0
                ? "Đã xác minh" : (verification.length > 0 ? verification : "Chưa xác minh")
            const operation = String(evidence.operation || "")
            const source = operation.indexOf("accountsession") >= 0
                ? "phiên đăng nhập"
                : (operation.indexOf("account.scan") >= 0
                    ? "quét tài khoản" : "bằng chứng backend")
            return state + " · " + source
        }

        function templateRuntime(row) {
            const policy = row.runtimePolicy === undefined || row.runtimePolicy === null
                ? ({}) : row.runtimePolicy
            const launch = policy.launchMode !== undefined
                ? policy.launchMode : policy.launch_mode
            const mute = policy.muteAudio !== undefined
                ? policy.muteAudio : policy.mute_audio
            const launchMode = launch === undefined ? "Chưa khai báo chế độ" : String(launch)
            const muteAudio = mute === undefined
                ? "Âm thanh chưa khai báo" : (Boolean(mute) ? "Tắt âm" : "Có âm thanh")
            return launchMode + " · " + muteAudio
        }

        function storageRatio(row) {
            const total = Number(row.totalBytes || 0)
            return total > 0 ? Math.max(0, Math.min(1, Number(row.usedBytes || 0) / total)) : 0
        }

        function rowSource(row) {
            if (section.kind === "account")
                return String(row.profileLabel || row.profileId || "Browser chưa liên kết")
            if (section.kind === "proxy")
                return String(row.assignedProfileCount || 0) + " browser · "
                    + String(row.status || "unknown")
            if (section.kind === "template")
                return String(row.assignedProfileCount || 0) + " browser · "
                    + (row.isDefault ? "Mặc định" : String(row.status || "active"))
            return String(row.status || "unknown") + " · "
                + root.bytes(row.freeBytes) + " trống"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 9
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: section.sectionTitle
                    color: Theme.text
                    font.pixelSize: 18
                    font.weight: Font.Bold
                }
                Foundation.StatusPill {
                    text: String(section.metadata.total === undefined
                        ? section.rowCount : section.metadata.total) + " mục"
                    tone: Theme.accent
                }
            }
            Text {
                Layout.fillWidth: true
                text: section.description()
                color: Theme.textFaint
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                spacing: 8
                Repeater {
                    model: section.summaryItems
                    delegate: Rectangle {
                        id: summaryCard
                        required property int index
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        radius: Theme.radiusSmall
                        color: Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 9
                            Rectangle {
                                Layout.preferredWidth: 8
                                Layout.preferredHeight: 28
                                radius: 4
                                color: section.tone(String(summaryCard.modelData.tone || "info"))
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: String(summaryCard.modelData.value)
                                    color: Theme.text
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: String(summaryCard.modelData.label)
                                    color: Theme.textFaint
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: availableWidth
                clip: true
                GridLayout {
                    width: parent.width
                    columns: section.kind === "template" ? 2 : 1
                    columnSpacing: 8
                    rowSpacing: 8
                    Repeater {
                        model: section.rows
                        delegate: Rectangle {
                            id: sectionRow
                            required property int index
                            readonly property var row: section.rowAt(index)
                            signal activate()
                            objectName: "channels" + section.kind.charAt(0).toUpperCase()
                                + section.kind.slice(1) + "Row_" + section.rowId(row)
                            Layout.fillWidth: true
                            Layout.preferredHeight: section.kind === "storage" ? 126
                                : (section.kind === "template" ? 112 : 94)
                            radius: Theme.radiusSmall
                            color: sectionMouse.containsMouse ? Theme.hover : Theme.elevated
                            border.width: 1
                            border.color: activeFocus ? Theme.accent : Theme.borderSoft
                            activeFocusOnTab: true
                            Accessible.name: section.rowTitle(row) + ", " + section.rowDetail(row)
                            Accessible.description: row.deepLink && row.deepLink.route
                                ? "Mở đúng entity từ projection" : "Không có deep link authoritative"
                            Accessible.role: Accessible.Row
                            onActivate: {
                                if (row.deepLink && row.deepLink.route)
                                    section.rowRequested(row.deepLink)
                            }
                            Keys.onReturnPressed: sectionRow.activate()
                            Keys.onSpacePressed: sectionRow.activate()
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 8

                                RowLayout {
                                    visible: section.kind === "account"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: visible ? 30 : 0
                                    spacing: 10
                                    SocialIcon {
                                        platform: String(sectionRow.row.platform || "generic")
                                        Layout.preferredWidth: 26
                                        Layout.preferredHeight: 26
                                    }
                                    ColumnLayout {
                                        Layout.preferredWidth: 250
                                        spacing: 0
                                        Text { Layout.fillWidth: true; text: section.rowTitle(sectionRow.row); color: Theme.text; font.pixelSize: 12; font.weight: Font.Bold; elide: Text.ElideRight }
                                        Text { Layout.fillWidth: true; text: String(sectionRow.row.externalId || "Chưa có external ID") + " · " + String(sectionRow.row.profileLabel || sectionRow.row.profileId || "Chưa liên kết browser"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                    }
                                    Foundation.StatusPill {
                                        objectName: "channelsAccountStatus_" + section.rowId(sectionRow.row)
                                        text: section.accountStatus(sectionRow.row)
                                        tone: section.accountStatusTone(sectionRow.row)
                                    }
                                    Foundation.StatusPill {
                                        text: String(sectionRow.row.channelCount || 0) + " kênh"
                                        tone: Theme.info
                                        showDot: false
                                    }
                                    Item { Layout.fillWidth: true }
                                    UiIcon { name: "ui/chevron-right"; tone: Theme.textFaint; iconSize: 15 }
                                }

                                RowLayout {
                                    visible: section.kind === "account"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: visible ? 24 : 0
                                    spacing: 16
                                    Text {
                                        objectName: "channelsAccountMetrics_" + section.rowId(sectionRow.row)
                                        Layout.fillWidth: true
                                        text: section.accountMetrics(sectionRow.row)
                                        color: Theme.textMuted
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        objectName: "channelsAccountEvidence_" + section.rowId(sectionRow.row)
                                        Layout.preferredWidth: 220
                                        text: section.accountEvidence(sectionRow.row)
                                        color: Theme.info
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        objectName: "channelsAccountChecked_" + section.rowId(sectionRow.row)
                                        Layout.preferredWidth: 250
                                        text: "Quét gần nhất · " + root.timestamp(sectionRow.row.lastScannedAt)
                                        color: Theme.textFaint
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }

                                RowLayout {
                                    visible: section.kind === "proxy"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 12
                                    Rectangle {
                                        Layout.preferredWidth: 42
                                        Layout.preferredHeight: 42
                                        radius: 12
                                        color: Theme.accentSoft
                                        UiIcon { anchors.centerIn: parent; name: "ui/lock"; tone: Theme.accent; iconSize: 20 }
                                    }
                                    ColumnLayout {
                                        Layout.preferredWidth: 220
                                        spacing: 2
                                        Text { Layout.fillWidth: true; text: section.rowTitle(sectionRow.row); color: Theme.text; font.pixelSize: 12; font.weight: Font.Bold; elide: Text.ElideRight }
                                        Text { Layout.fillWidth: true; text: String(sectionRow.row.country || sectionRow.row.countryCode || "Vị trí chưa có") + (sectionRow.row.city ? " · " + String(sectionRow.row.city) : ""); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3
                                        Text { objectName: "channelsProxyEndpoint_" + section.rowId(sectionRow.row); Layout.fillWidth: true; text: "IP thoát · " + root.exact(sectionRow.row.exitIp); color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                        Text { objectName: "channelsProxyChecked_" + section.rowId(sectionRow.row); Layout.fillWidth: true; text: "Kiểm tra gần nhất · " + root.timestamp(sectionRow.row.lastCheckedAt); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                    }
                                    ColumnLayout {
                                        Layout.preferredWidth: 170
                                        spacing: 3
                                        Text { objectName: "channelsProxyLatency_" + section.rowId(sectionRow.row); Layout.fillWidth: true; text: sectionRow.row.latencyMs === undefined || sectionRow.row.latencyMs === null ? "Độ trễ —" : "Độ trễ · " + String(sectionRow.row.latencyMs) + " ms"; color: Theme.textMuted; font.pixelSize: 11; horizontalAlignment: Text.AlignRight }
                                        Text { Layout.fillWidth: true; text: String(sectionRow.row.assignedProfileCount || 0) + " browser đang dùng"; color: Theme.textFaint; font.pixelSize: 11; horizontalAlignment: Text.AlignRight }
                                    }
                                    Foundation.StatusPill { text: String(sectionRow.row.status || "unknown") === "live" ? "Hoạt động" : String(sectionRow.row.status || "Không rõ"); tone: String(sectionRow.row.status || "") === "live" ? Theme.success : Theme.warning }
                                    UiIcon { name: "ui/chevron-right"; tone: Theme.textFaint; iconSize: 15 }
                                }

                                RowLayout {
                                    visible: section.kind === "template"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 12
                                    Rectangle {
                                        Layout.preferredWidth: 46
                                        Layout.preferredHeight: 46
                                        radius: 12
                                        color: Theme.accentSoft
                                        UiIcon { anchors.centerIn: parent; name: "ui/copy"; tone: Theme.accent; iconSize: 21 }
                                    }
                                    ColumnLayout {
                                        Layout.preferredWidth: 270
                                        spacing: 3
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Text { Layout.fillWidth: true; text: section.rowTitle(sectionRow.row); color: Theme.text; font.pixelSize: 13; font.weight: Font.Bold; elide: Text.ElideRight }
                                            Foundation.StatusPill { visible: Boolean(sectionRow.row.isDefault); text: "Mặc định"; tone: Theme.success; showDot: false }
                                        }
                                        Text { Layout.fillWidth: true; text: String(sectionRow.row.description || "Không có mô tả"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 4
                                        Text { objectName: "channelsTemplateVersion_" + section.rowId(sectionRow.row); Layout.fillWidth: true; text: root.exact(sectionRow.row.displayVersion); color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                        Text { objectName: "channelsTemplateLocale_" + section.rowId(sectionRow.row); Layout.fillWidth: true; text: String(sectionRow.row.platform || "generic") + " · " + String(sectionRow.row.os || "—") + " · " + String(sectionRow.row.locale || "—") + " · " + String(sectionRow.row.timezone || "—"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                        Text { objectName: "channelsTemplateRuntime_" + section.rowId(sectionRow.row); Layout.fillWidth: true; text: "Runtime · " + section.templateRuntime(sectionRow.row); color: Theme.info; font.pixelSize: 11; elide: Text.ElideRight }
                                    }
                                    ColumnLayout {
                                        Layout.preferredWidth: 150
                                        spacing: 3
                                        Text { Layout.fillWidth: true; text: String(sectionRow.row.assignedProfileCount || 0); color: Theme.text; font.pixelSize: 16; font.weight: Font.Bold; horizontalAlignment: Text.AlignRight }
                                        Text { Layout.fillWidth: true; text: "browser đang áp dụng"; color: Theme.textFaint; font.pixelSize: 11; horizontalAlignment: Text.AlignRight }
                                    }
                                    UiIcon { name: "ui/chevron-right"; tone: Theme.textFaint; iconSize: 15 }
                                }

                                RowLayout {
                                    visible: section.kind === "storage"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: visible ? 38 : 0
                                    spacing: 12
                                    Rectangle {
                                        Layout.preferredWidth: 38
                                        Layout.preferredHeight: 38
                                        radius: 11
                                        color: Theme.accentSoft
                                        UiIcon { anchors.centerIn: parent; name: "ui/folder"; tone: Theme.accent; iconSize: 19 }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text { Layout.fillWidth: true; text: section.rowTitle(sectionRow.row); color: Theme.text; font.pixelSize: 13; font.weight: Font.Bold; elide: Text.ElideRight }
                                        Text { Layout.fillWidth: true; text: String(sectionRow.row.profileCount || 0) + " browser · " + String(sectionRow.row.status || "unknown"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                    }
                                    Foundation.StatusPill { text: String(sectionRow.row.status || "unknown") === "ready" ? "Sẵn sàng" : String(sectionRow.row.status || "Không rõ"); tone: String(sectionRow.row.status || "") === "ready" ? Theme.success : Theme.warning }
                                    UiIcon { name: "ui/chevron-right"; tone: Theme.textFaint; iconSize: 15 }
                                }
                                Rectangle {
                                    visible: section.kind === "storage"
                                    objectName: "channelsStorageProgress_" + section.rowId(sectionRow.row)
                                    property real quotaRatio: section.storageRatio(sectionRow.row)
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: visible ? 9 : 0
                                    radius: height / 2
                                    color: Theme.borderSoft
                                    Rectangle {
                                        width: parent.width * parent.quotaRatio
                                        height: parent.height
                                        radius: height / 2
                                        color: parent.quotaRatio >= 0.9 ? Theme.danger
                                            : (parent.quotaRatio >= 0.75 ? Theme.warning : Theme.accent)
                                    }
                                }
                                RowLayout {
                                    visible: section.kind === "storage"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: visible ? 22 : 0
                                    spacing: 12
                                    Text { objectName: "channelsStorageUsage_" + section.rowId(sectionRow.row); Layout.fillWidth: true; text: root.bytes(sectionRow.row.usedBytes) + " đã dùng / " + root.bytes(sectionRow.row.totalBytes); color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold }
                                    Text { objectName: "channelsStorageFree_" + section.rowId(sectionRow.row); Layout.preferredWidth: 180; text: root.bytes(sectionRow.row.freeBytes) + " còn trống"; color: Theme.success; font.pixelSize: 11; horizontalAlignment: Text.AlignRight }
                                    Text { objectName: "channelsStorageChecked_" + section.rowId(sectionRow.row); Layout.preferredWidth: 260; text: "Kiểm tra gần nhất · " + root.timestamp(sectionRow.row.lastCheckedAt); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight; horizontalAlignment: Text.AlignRight }
                                }
                            }
                            MouseArea {
                                id: sectionMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: sectionRow.row.deepLink
                                    && sectionRow.row.deepLink.route
                                    ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: sectionRow.activate()
                            }
                        }
                    }
                    Text {
                        visible: section.rowCount === 0
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        text: "Projection chưa có " + section.sectionTitle.toLowerCase()
                        color: Theme.textFaint
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
