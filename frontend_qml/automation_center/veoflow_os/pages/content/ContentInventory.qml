pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Rectangle {
    id: root
    objectName: "contentInventory"
    property var lifecycle: ({})
    property var filters: ({})
    property var inventory: ({})
    property var inventoryModel
    property var controlPlaneBridge: null
    property int dataRevision: 0
    property string selectedContentId: ""
    property string selectedEntityId: selectedContentId
    property string activeTab: "library"
    property string searchText: ""
    property string channelFilter: ""
    property string campaignFilter: ""
    property string stageFilter: ""
    property string formatFilter: ""
    property string languageFilter: ""
    property string viewMode: "list"
    property int pageSize: 5
    property bool canWrite: false
    property var savedViews: ({})
    property string selectedSavedViewKey: ""
    property bool savedViewBusy: false
    property var bulkSelection: ({})
    property int bulkSelectionRevision: 0
    property int bulkSelectionCount: 0
    property int bulkStaleCount: 0
    property bool bulkEnabled: false
    property bool bulkBusy: false
    property string bulkAvailabilityReason: ""
    signal tabRequested(string tab)
    signal searchRequested(string value)
    signal channelRequested(string value)
    signal campaignRequested(string value)
    signal stageRequested(string value)
    signal formatRequested(string value)
    signal languageRequested(string value)
    signal viewRequested(string value)
    signal savedViewRequested(string viewKey)
    signal savedViewSaveRequested()
    signal itemRequested(var item)
    signal itemSelectionRequested(var item)
    signal selectVisibleRequested()
    signal clearSelectionRequested()
    signal bulkOperationRequested(string operation)
    signal createPackageRequested()
    signal scheduleRequested()
    signal nextPageRequested()
    signal previousPageRequested()
    signal pageRequested(int pageNumber)

    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    clip: true
    Accessible.name: "Kho nội dung và bộ lọc"
    Accessible.role: Accessible.Pane

    readonly property string entityType: String(root.inventory.entity_type || "content")
    readonly property var tabSchema: (root.filters.schema_by_tab || ({}))[root.activeTab]
        || ({})
    readonly property var projectedColumns: (root.inventory.columns || []).length > 0
        ? root.inventory.columns : (root.tabSchema.columns || [])
    readonly property bool hasNextPage: String(root.inventory.next_cursor || "").length > 0
    readonly property bool hasPreviousPage: {
        const cursor = String(root.inventory.cursor || "")
        return cursor.length > 0 && Number(cursor) > 0
    }
    readonly property int currentPage: Math.floor(
        Number(root.inventory.cursor || 0) / Math.max(1, root.pageSize)
    ) + 1
    readonly property int pageCount: Math.max(
        1,
        Math.ceil(Number(root.inventory.total || 0) / Math.max(1, root.pageSize))
    )
    readonly property real listRowHeight: Math.max(
        58,
        Math.min(
            75,
            Math.floor(
                (Math.max(0, listView.height)
                    - Math.max(0, root.pageSize - 1) * listView.spacing)
                    / Math.max(1, root.pageSize)
            )
        )
    )
    readonly property bool compactLifecycle: contentLifecycleStageList.width < 1100
    readonly property bool compactContentTable: listView.width > 0
        && listView.width < 1100
    readonly property int contentTitleWidth: compactContentTable ? 196 : 224
    readonly property int contentPillarWidth: compactContentTable ? 64 : 76
    readonly property int contentPlatformWidth: compactContentTable ? 100 : 112
    readonly property int contentCampaignWidth: compactContentTable ? 86 : 104
    readonly property int contentStageWidth: compactContentTable ? 100 : 112
    readonly property int contentCompletenessWidth: compactContentTable ? 68 : 76
    readonly property int contentScheduleWidth: compactContentTable ? 76 : 88
    readonly property int contentOwnerMinimumWidth: compactContentTable ? 70 : 78
    readonly property int contentUpdatedWidth: compactContentTable ? 70 : 84
    readonly property int contentTableSpacing: compactContentTable ? 6 : 8
    // SnapshotStore exposes a Python QVariantList. Nested list changes do not
    // reliably invalidate a Repeater binding, so materialize a fresh JS array
    // whenever the authoritative snapshot revision advances.
    readonly property var lifecycleItems: root.normalizedLifecycleItems()
    readonly property var paginationItems: root.visiblePages()
    readonly property string rendererKey: root.entityType === "campaign"
        ? "campaign"
        : root.entityType === "content_package"
            ? "package"
            : root.entityType === "asset" ? "asset" : "content"
    readonly property var operationalMetrics: (root.inventory.summary || {}).metrics || []
    readonly property string effectiveSavedViewKey: root.selectedSavedViewKey
        || String(root.savedViews.selected_view_key
            || root.savedViews.default_view_key || "")

    function listOrEmpty(value) {
        return value === null || value === undefined ? [] : value
    }

    function normalizedLifecycleItems() {
        const revision = root.dataRevision
        const source = root.listOrEmpty(root.lifecycle.items)
        const result = []
        for (let index = 0; index < source.length; index++) {
            const item = source[index]
            result.push({
                "key": String(item.key || ""),
                "label": String(item.label || ""),
                "count": Number(item.count || 0)
            })
        }
        return result
    }

    function lifecycleItem(stageIndex, expectedKey, fallbackLabel) {
        const items = root.lifecycleItems
        if (stageIndex >= 0 && stageIndex < items.length
                && String(items[stageIndex].key || "") === expectedKey)
            return items[stageIndex]
        for (let index = 0; index < items.length; index++) {
            if (String(items[index].key || "") === expectedKey)
                return items[index]
        }
        return {"key": expectedKey, "label": fallbackLabel, "count": 0}
    }

    function filterModel(items, allLabel) {
        const result = [{"id": "", "label": allLabel}]
        const source = items || []
        for (let index = 0; index < source.length; index++) {
            const item = source[index] || ({})
            result.push({
                "id": String(item.id !== undefined ? item.id : item),
                "label": String(item.label !== undefined ? item.label : item)
            })
        }
        return result
    }

    function comboIndex(model, value) {
        const target = String(value || "")
        for (let index = 0; index < model.length; index++) {
            if (String((model[index] || {}).id || "") === target)
                return index
        }
        return 0
    }

    function savedViewModel() {
        const result = [{"view_key": "", "name": "Góc nhìn hiện tại"}]
        const items = root.savedViews.items || []
        for (let index = 0; index < items.length; index++)
            result.push(items[index] || ({}))
        return result
    }

    function savedViewIndex(items, value) {
        const target = String(value || "")
        for (let index = 0; index < items.length; index++) {
            if (String((items[index] || {}).view_key || "") === target)
                return index
        }
        return 0
    }

    function bulkSelected(contentId) {
        const revision = root.bulkSelectionRevision
        return Boolean((root.bulkSelection || ({}))[String(contentId || "")])
    }

    function allVisibleSelected() {
        if (root.entityType !== "content" || root.inventoryModel.count <= 0)
            return false
        for (let index = 0; index < root.inventoryModel.count; index++) {
            const item = root.inventoryModel.get(index) || ({})
            if (!root.bulkSelected(item.id)) return false
        }
        return true
    }

    function stageTone(stage) {
        const key = String(stage || "")
        if (key === "published") return Theme.success
        if (key === "waiting_publish") return Theme.accent
        if (key === "writing") return Theme.warning
        if (key === "ready_production") return Theme.info
        if (key === "producing") return Theme.textMuted
        if (key === "attention" || key === "unmapped") return Theme.danger
        return Theme.textMuted
    }

    function stageIcon(stage) {
        const key = String(stage || "")
        if (key === "idea") return "semantic/lightbulb"
        if (key === "writing") return "semantic/workflow"
        if (key === "ready_production") return "semantic/check-circle"
        if (key === "producing") return "semantic/video"
        if (key === "waiting_publish") return "semantic/alert-circle"
        if (key === "published") return "semantic/upload-cloud"
        return "semantic/info"
    }

    function platformKey(value) {
        const key = String(value || "").toLowerCase()
        if (key.indexOf("tiktok") >= 0) return "tiktok"
        if (key.indexOf("youtube") >= 0) return "youtube"
        if (key.indexOf("facebook") >= 0) return "facebook"
        if (key.indexOf("instagram") >= 0) return "instagram"
        if (key === "x" || key.indexOf("twitter") >= 0) return "x"
        return ""
    }

    function platformIcon(value) {
        const key = root.platformKey(value)
        return key ? "product/" + key : "semantic/video"
    }

    function platformTone(value) {
        const key = root.platformKey(value)
        if (key === "youtube") return "#ff4d5f"
        if (key === "facebook") return "#5f8cff"
        if (key === "instagram") return "#e65ea3"
        if (key === "tiktok") return "#5eead4"
        if (key === "x") return "#5b6472"
        return Theme.textMuted
    }

    function ownerName(item) {
        const owner = (item || {}).owner || ({})
        if (!Boolean(owner.available)) return "Chưa có dữ liệu"
        return String(owner.display_name || owner.name || "—")
    }

    function ownerInitials(item) {
        const name = root.ownerName(item)
        if (!name || name === "—" || name === "Chưa có dữ liệu") return "?"
        const parts = name.trim().split(/\s+/)
        if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase()
        return String(parts[0].slice(0, 1)
            + parts[parts.length - 1].slice(0, 1)).toUpperCase()
    }

    function updatedText(value) {
        if (!value) return "—"
        const parsed = new Date(String(value))
        return isNaN(parsed.getTime())
            ? "—" : Qt.formatDateTime(parsed, "dd/MM/yyyy\nHH:mm")
    }

    function readinessPercent(readiness) {
        const data = readiness || ({})
        if (data.percent !== undefined && data.percent !== null) {
            const projected = Number(data.percent)
            if (isFinite(projected))
                return Math.max(0, Math.min(100, Math.round(projected)))
        }
        const score = data.score || ({})
        const total = Number(score.total || 0)
        return total > 0 ? Math.round(Number(score.passed || 0) * 100 / total) : null
    }

    function scheduleText(value) {
        if (!value) return "—"
        const parsed = new Date(String(value))
        return isNaN(parsed.getTime())
            ? "—" : Qt.formatDateTime(parsed, "dd/MM/yyyy\nHH:mm")
    }

    function rowTitle(item) {
        if (root.entityType === "campaign") return String(item.name || "Campaign")
        if (root.entityType === "content_package")
            return String(item.title || item.package_key || "Gói sản xuất")
        if (root.entityType === "asset") return String(item.file_name || "Tài nguyên")
        return String(item.title || "Nội dung")
    }

    function rowSubtitle(item) {
        if (root.entityType === "campaign")
            return String((item.channel || {}).name || "Chưa gắn kênh")
        if (root.entityType === "content_package")
            return String(item.platform || "") + " · v" + String(item.version || 1)
        if (root.entityType === "asset")
            return String(item.media_type || "asset") + " · " + String(item.mime_type || "")
        return String(item.subtitle || item.pillar || "")
    }

    function platformText(item) {
        if (root.entityType === "campaign") {
            const channel = item.channel || ({})
            return String(channel.name || "—")
                + (channel.platform ? "\n" + String(channel.platform) : "")
        }
        if (root.entityType === "content_package")
            return String(item.platform || "—")
        if (root.entityType === "asset")
            return String(item.media_type || "asset")
        const channel = item.channel || ({})
        return String(channel.name || "—") + "\n" + String(channel.platform || "")
    }

    function campaignText(item) {
        if (root.entityType === "campaign")
            return String(item.objective || "—")
        if (root.entityType === "content_package")
            return String(item.content_id || "—")
        if (root.entityType === "asset")
            return String((item.qc || {}).status || "Chưa QC")
        return String((item.campaign || {}).name || "—")
    }

    function pillarText(item) {
        if (root.entityType === "campaign")
            return String(item.objective || "Chưa có mục tiêu")
        if (root.entityType === "content_package") return "v" + String(item.version || 1)
        if (root.entityType === "asset")
            return root.mediaTypeText(item)
        return String(item.pillar || "—")
    }

    function typedStageText(item) {
        if (root.entityType === "campaign") {
            const status = String(item.status || "")
            if (status === "active") return "Đang chạy"
            if (status === "paused") return "Tạm dừng"
            if (status === "completed") return "Hoàn tất"
            return status || "—"
        }
        if (root.entityType === "content_package")
            return Boolean((item.readiness || {}).ready) ? "Sẵn sàng" : "Bị chặn"
        if (root.entityType === "asset") return root.qcText(item.qc)
        return String((item.stage || {}).label || item.status || "—")
    }

    function typedStageTone(item) {
        if (root.entityType === "campaign") {
            const status = String((item || {}).status || "").toLowerCase()
            if (status === "active" || status === "completed") return Theme.success
            if (status === "paused") return Theme.warning
            return Theme.textMuted
        }
        if (root.entityType === "content_package")
            return Boolean(((item || {}).readiness || {}).ready)
                ? Theme.success : Theme.warning
        if (root.entityType === "asset") {
            const status = String((((item || {}).qc || {}).status) || "").toLowerCase()
            if (status === "passed") return Theme.success
            if (status === "warning") return Theme.warning
            if (status === "failed") return Theme.danger
            return Theme.textMuted
        }
        return root.stageTone(((item || {}).stage || {}).key || (item || {}).status)
    }

    function mediaTypeText(item) {
        const type = String((item || {}).media_type || "").toLowerCase()
        const label = type === "video" ? "Video"
            : type === "audio" ? "Âm thanh"
                : type === "image" ? "Hình ảnh" : (type || "Tài nguyên")
        const mime = String((item || {}).mime_type || "")
        return label + (mime ? " · " + mime : "")
    }

    function probeText(item) {
        const probe = (item || {}).probe || ({})
        const width = Number(probe.width || 0)
        const height = Number(probe.height || 0)
        const fps = Number(probe.fps || 0)
        if (width > 0 && height > 0)
            return String(width) + "×" + String(height)
                + (fps > 0 ? " · " + String(Math.round(fps)) + " FPS" : "")
        const duration = Number((item || {}).duration_seconds
            || probe.duration_seconds || 0)
        if (duration > 0) return String(Math.round(duration)) + " giây"
        return String(probe.status || "Chưa có media probe")
    }

    function qcText(value) {
        const status = String((value || {}).status || "").toLowerCase()
        if (status === "passed") return "Đạt"
        if (status === "warning") return "Cảnh báo"
        if (status === "failed") return "Không đạt"
        return status || "Chưa QC"
    }

    function formatBytes(value) {
        const bytes = Number(value || 0)
        if (!isFinite(bytes) || bytes <= 0) return "—"
        if (bytes >= 1073741824)
            return (bytes / 1073741824).toFixed(1) + " GB"
        if (bytes >= 1048576)
            return (bytes / 1048576).toFixed(1) + " MB"
        if (bytes >= 1024)
            return (bytes / 1024).toFixed(1) + " KB"
        return String(Math.round(bytes)) + " B"
    }

    function metricTone(value) {
        const tone = String(value || "").toLowerCase()
        if (tone === "accent") return Theme.accent
        if (tone === "success") return Theme.success
        if (tone === "warning") return Theme.warning
        if (tone === "danger") return Theme.danger
        if (tone === "info") return Theme.info
        return Theme.textMuted
    }

    function metricValue(metric) {
        const item = metric || ({})
        return String(item.value_kind || "") === "bytes"
            ? root.formatBytes(item.value) : String(Number(item.value || 0))
    }

    function cardPrimaryDetail(item) {
        if (root.entityType === "campaign")
            return String(item.objective || "Chưa có mục tiêu")
        if (root.entityType === "content_package") {
            const channel = item.channel || ({})
            return String(channel.name || "Chưa gắn kênh") + " · "
                + String(item.platform || "Chưa có nền tảng")
        }
        if (root.entityType === "asset") return root.mediaTypeText(item)
        return root.pillarText(item) + " · "
            + root.platformText(item).replace("\n", " · ")
    }

    function cardEvidence(item) {
        if (root.entityType === "campaign")
            return String(Number(item.content_count || 0)) + "/"
                + String(Number(item.target_count || 0)) + " nội dung"
        if (root.entityType === "content_package") {
            const readiness = item.readiness || ({})
            const blockers = readiness.blocker_codes || []
            return Boolean(readiness.ready) ? "Đủ asset · QC · kênh"
                : String(blockers.length) + " blocker cần xử lý"
        }
        if (root.entityType === "asset")
            return root.probeText(item) + " · " + root.formatBytes(item.size_bytes)
        return root.campaignText(item)
    }

    function cardIcon(item) {
        if (root.entityType === "campaign")
            return root.platformIcon(((item || {}).channel || {}).platform)
        if (root.entityType === "content_package") return "semantic/workflow"
        if (root.entityType === "asset") {
            const type = String((item || {}).media_type || "").toLowerCase()
            if (type === "image") return "ui/camera"
            if (type === "audio") return "ui/volume-2"
            if (type === "subtitle") return "ui/folder"
            return "semantic/video"
        }
        return "semantic/video"
    }

    function cardIconTone(item) {
        if (root.entityType === "campaign")
            return root.platformTone(((item || {}).channel || {}).platform)
        return root.typedStageTone(item)
    }

    function campaignProgress(item) {
        const total = Math.max(0, Number((item || {}).target_count || 0))
        if (total <= 0) return 0
        return Math.max(0, Math.min(1,
            Number((item || {}).content_count || 0) / total))
    }

    function columnLabel(key, fallback) {
        const target = String(key || "")
        const columns = root.projectedColumns || []
        for (let index = 0; index < columns.length; index++) {
            const column = columns[index] || ({})
            if (String(column.key || "") === target)
                return String(column.label || fallback || target)
        }
        return String(fallback || target)
    }

    function filterFieldAvailable(key) {
        const fields = root.tabSchema.fields || []
        if (fields.length === 0) return true
        const target = String(key || "")
        for (let index = 0; index < fields.length; index++) {
            if (String((fields[index] || {}).key || "") === target) return true
        }
        return false
    }

    function visiblePages() {
        const total = root.pageCount
        const current = root.currentPage
        if (total <= 5) {
            const all = []
            for (let page = 1; page <= total; page++)
                all.push({"kind": "page", "page": page})
            return all
        }
        const pages = []
        if (current <= 3) {
            for (let page = 1; page <= Math.min(5, total - 1); page++)
                pages.push({"kind": "page", "page": page})
            pages.push({"kind": "ellipsis", "page": 0})
            pages.push({"kind": "page", "page": total})
            return pages
        }
        if (current >= total - 2) {
            pages.push({"kind": "page", "page": 1})
            pages.push({"kind": "ellipsis", "page": 0})
            for (let page = Math.max(2, total - 4); page <= total; page++)
                pages.push({"kind": "page", "page": page})
            return pages
        }
        pages.push({"kind": "page", "page": 1})
        pages.push({"kind": "ellipsis", "page": 0})
        for (let page = current - 1; page <= current + 1; page++)
            pages.push({"kind": "page", "page": page})
        pages.push({"kind": "ellipsis", "page": 0})
        pages.push({"kind": "page", "page": total})
        return pages
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: "transparent"
            Row {
                id: contentMainTabRow
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 10
                spacing: 2
                InventoryTabButton { tabKey: "library"; label: "Thư viện" }
                InventoryTabButton { tabKey: "campaigns"; label: "Chiến dịch" }
                InventoryTabButton { tabKey: "ideas"; label: "Ý tưởng" }
                InventoryTabButton { tabKey: "packages"; label: "Gói sản xuất" }
                InventoryTabButton { tabKey: "assets"; label: "Kho tài nguyên" }
            }
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: Number(root.inventory.total || 0) + " mục"
                color: Theme.textFaint
                font.pixelSize: 11
            }
        }

        Rectangle {
            objectName: "contentLifecycleRail"
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            Layout.preferredHeight: visible ? 66 : 0
            visible: root.entityType === "content"
            color: Theme.elevated
            radius: 30
            border.width: 1
            border.color: Theme.borderSoft
            clip: true
            Item {
                id: contentLifecycleStageList
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                clip: true
                readonly property int count: 6
                readonly property real spacing: Theme.space2
                Row {
                    id: lifecycleStageRow
                    anchors.fill: parent
                    spacing: contentLifecycleStageList.spacing
                    LifecycleStageButton { stageIndex: 0; expectedKey: "idea"; fallbackLabel: "Ý tưởng" }
                    LifecycleStageButton { stageIndex: 1; expectedKey: "writing"; fallbackLabel: "Đang viết" }
                    LifecycleStageButton { stageIndex: 2; expectedKey: "ready_production"; fallbackLabel: "Sẵn sàng SX" }
                    LifecycleStageButton { stageIndex: 3; expectedKey: "producing"; fallbackLabel: "Đang sản xuất" }
                    LifecycleStageButton { stageIndex: 4; expectedKey: "waiting_publish"; fallbackLabel: "Chờ đăng" }
                    LifecycleStageButton { stageIndex: 5; expectedKey: "published"; fallbackLabel: "Đã đăng" }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? (root.entityType === "content" ? 104 : 58) : 0
            visible: root.filterFieldAvailable("search")
            color: "transparent"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: root.contentTableSpacing
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.space3
                    ContentTextField {
                        id: searchField
                        objectName: "contentSearchField"
                        activeFocusOnTab: true
                        Layout.fillWidth: true
                        Layout.minimumWidth: 280
                        text: root.searchText
                        leadingIcon: "ui/search"
                        placeholderText: root.entityType === "campaign"
                            ? "Tìm chiến dịch, mục tiêu..."
                            : root.entityType === "content_package"
                                ? "Tìm gói sản xuất..."
                                : root.entityType === "asset"
                                    ? "Tìm tài nguyên, loại media..."
                                    : "Tìm tiêu đề, hook, chiến dịch, kênh..."
                        Accessible.name: "Tìm trong " + root.activeTab
                        onAccepted: root.searchRequested(text.trim())
                    }
                    ContentComboBox {
                        id: savedViewsCombo
                        objectName: "contentSavedViewsCombo"
                        activeFocusOnTab: true
                        visible: root.entityType === "content"
                        Layout.preferredWidth: visible ? 220 : 0
                        enabled: Boolean(root.savedViews.available)
                        model: root.savedViewModel()
                        textRole: "name"
                        valueRole: "view_key"
                        currentIndex: root.savedViewIndex(model, root.effectiveSavedViewKey)
                        displayText: "Góc nhìn đã lưu"
                        Accessible.name: "Góc nhìn đã lưu: " + textAt(currentIndex)
                        onActivated: {
                            const viewKey = String(currentValue || "")
                            if (viewKey) root.savedViewRequested(viewKey)
                        }
                    }
                    AppButton {
                        objectName: "contentSavedViewSaveButton"
                        visible: root.entityType === "content"
                        text: ""
                        leadingIcon: "semantic/check-circle"
                        implicitWidth: 38
                        enabled: root.canWrite && Boolean(root.savedViews.available)
                            && !root.savedViewBusy
                        Accessible.name: root.effectiveSavedViewKey
                            ? "Cập nhật góc nhìn đã lưu" : "Lưu góc nhìn hiện tại"
                        onClicked: root.savedViewSaveRequested()
                    }
                    AppButton {
                        objectName: "contentGridViewButton"
                        text: ""
                        leadingIcon: "ui/grid"
                        implicitWidth: 38
                        checkable: true
                        checked: root.viewMode === "grid"
                        primary: checked
                        Accessible.name: "Hiển thị dạng lưới"
                        onClicked: root.viewRequested("grid")
                    }
                    AppButton {
                        objectName: "contentListViewButton"
                        text: ""
                        leadingIcon: "ui/list"
                        implicitWidth: 38
                        checkable: true
                        checked: root.viewMode === "list"
                        primary: checked
                        Accessible.name: "Hiển thị dạng danh sách"
                        onClicked: root.viewRequested("list")
                    }
                }
                RowLayout {
                    visible: root.entityType === "content"
                    Layout.fillWidth: true
                    spacing: Theme.space3
                    FilterSelect {
                        objectName: "contentChannelFilter"
                        label: "Tất cả kênh"
                        visible: root.filterFieldAvailable("channel_id")
                        items: root.filterModel(root.filters.channels || [], "Tất cả kênh")
                        selectedValue: root.channelFilter
                        onValueRequested: value => root.channelRequested(value)
                    }
                    FilterSelect {
                        objectName: "contentCampaignFilter"
                        label: "Tất cả chiến dịch"
                        visible: root.filterFieldAvailable("campaign_id")
                        items: root.filterModel(root.filters.campaigns || [], "Tất cả chiến dịch")
                        selectedValue: root.campaignFilter
                        onValueRequested: value => root.campaignRequested(value)
                    }
                    FilterSelect {
                        objectName: "contentStageFilter"
                        label: "Tất cả giai đoạn"
                        visible: root.filterFieldAvailable("stage")
                        items: root.filterModel(root.lifecycleItems, "Tất cả giai đoạn")
                        selectedValue: root.stageFilter
                        onValueRequested: value => root.stageRequested(value)
                    }
                    FilterSelect {
                        objectName: "contentFormatFilter"
                        label: "Mọi định dạng"
                        visible: root.filterFieldAvailable("format")
                        items: root.filterModel(root.filters.formats || [], "Mọi định dạng")
                        selectedValue: root.formatFilter
                        onValueRequested: value => root.formatRequested(value)
                    }
                    FilterSelect {
                        objectName: "contentLanguageFilter"
                        label: "Mọi ngôn ngữ"
                        visible: root.filterFieldAvailable("language")
                        items: root.filterModel(root.filters.languages || [], "Mọi ngôn ngữ")
                        selectedValue: root.languageFilter
                        onValueRequested: value => root.languageRequested(value)
                    }
                }
            }
        }

        Rectangle {
            id: operationalSummary
            objectName: "contentOperationalSummary"
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 96 : 0
            visible: root.entityType !== "content" && root.operationalMetrics.length > 0
            color: Theme.elevated
            border.width: 1
            border.color: Theme.borderSoft
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                Repeater {
                    model: root.operationalMetrics
                    delegate: Rectangle {
                        id: metricCard
                        required property var modelData
                        readonly property string metricKey: String(metricCard.modelData.key || "metric")
                        objectName: "contentSummary_" + metricKey
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Theme.radiusMedium
                        color: Qt.rgba(root.metricTone(metricCard.modelData.tone).r,
                            root.metricTone(metricCard.modelData.tone).g,
                            root.metricTone(metricCard.modelData.tone).b, 0.10)
                        border.width: 1
                        border.color: Qt.rgba(root.metricTone(metricCard.modelData.tone).r,
                            root.metricTone(metricCard.modelData.tone).g,
                            root.metricTone(metricCard.modelData.tone).b, 0.30)
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            Rectangle {
                                Layout.preferredWidth: 38
                                Layout.preferredHeight: 38
                                radius: 12
                                color: Qt.rgba(root.metricTone(metricCard.modelData.tone).r,
                                    root.metricTone(metricCard.modelData.tone).g,
                                    root.metricTone(metricCard.modelData.tone).b, 0.16)
                                UiIcon {
                                    anchors.centerIn: parent
                                    name: String(metricCard.modelData.icon || "semantic/info")
                                    tone: root.metricTone(metricCard.modelData.tone)
                                    iconSize: 19
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    objectName: "contentSummaryValue_" + metricCard.metricKey
                                    text: root.metricValue(metricCard.modelData)
                                    color: Theme.text
                                    font.pixelSize: 20
                                    font.weight: Font.Bold
                                }
                                Text {
                                    objectName: "contentSummaryLabel_" + metricCard.metricKey
                                    Layout.fillWidth: true
                                    text: String(metricCard.modelData.label || "")
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(metricCard.modelData.detail || "")
                                    color: Theme.textFaint
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            objectName: "contentBulkActionBar"
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 56 : 0
            visible: root.entityType === "content" && root.bulkSelectionCount > 0
            color: Theme.elevated
            border.width: 1
            border.color: Theme.borderSoft
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                spacing: Theme.space3
                Text {
                    text: String(root.bulkSelectionCount) + " mục đã chọn"
                    color: root.bulkSelectionCount > 0 ? Theme.text : Theme.textMuted
                    font.pixelSize: 11
                    font.weight: root.bulkSelectionCount > 0 ? Font.DemiBold : Font.Normal
                }
                Text {
                    visible: root.bulkStaleCount > 0
                    text: String(root.bulkStaleCount) + " phiên bản đã đổi"
                    color: Theme.warning
                    font.pixelSize: 11
                }
                AppButton {
                    objectName: "contentBulkSelectVisibleButton"
                    text: "Chọn trang"
                    leadingIcon: "semantic/check-circle"
                    enabled: root.bulkEnabled && root.inventoryModel.count > 0 && !root.bulkBusy
                    Accessible.name: "Chọn tất cả nội dung đang hiển thị"
                    onClicked: root.selectVisibleRequested()
                }
                AppButton {
                    objectName: "contentBulkClearButton"
                    text: "Bỏ chọn"
                    enabled: root.bulkSelectionCount > 0 && !root.bulkBusy
                    availabilityReason: enabled ? ""
                        : root.bulkBusy ? "Đang xử lý thao tác hàng loạt"
                        : "Chưa chọn nội dung"
                    Accessible.name: "Bỏ chọn tất cả nội dung"
                    onClicked: root.clearSelectionRequested()
                }
                Item { Layout.fillWidth: true }
                AppButton {
                    objectName: "contentBulkAssignCampaignButton"
                    text: "Gán campaign"
                    leadingIcon: "semantic/workflow"
                    enabled: root.bulkEnabled && root.bulkSelectionCount > 0 && !root.bulkBusy
                    availabilityReason: enabled ? ""
                        : !root.bulkEnabled ? (root.bulkAvailabilityReason
                            || "Thao tác hàng loạt chưa khả dụng")
                        : root.bulkBusy ? "Đang xử lý thao tác hàng loạt"
                        : "Chưa chọn nội dung"
                    Accessible.name: "Xem trước gán campaign hàng loạt"
                    onClicked: root.bulkOperationRequested("assign_campaign")
                }
                AppButton {
                    objectName: "contentBulkChangeStageButton"
                    text: "Đổi giai đoạn"
                    leadingIcon: "ui/refresh-cw"
                    enabled: root.bulkEnabled && root.bulkSelectionCount > 0 && !root.bulkBusy
                    availabilityReason: enabled ? ""
                        : !root.bulkEnabled ? (root.bulkAvailabilityReason
                            || "Thao tác hàng loạt chưa khả dụng")
                        : root.bulkBusy ? "Đang xử lý thao tác hàng loạt"
                        : "Chưa chọn nội dung"
                    Accessible.name: "Xem trước đổi giai đoạn hàng loạt"
                    onClicked: root.bulkOperationRequested("change_stage")
                }
                AppButton {
                    objectName: "contentBulkCreatePackageButton"
                    text: "Tạo gói"
                    leadingIcon: "semantic/video"
                    enabled: root.canWrite && root.bulkSelectionCount === 1
                        && root.bulkSelected(root.selectedContentId) && !root.bulkBusy
                    availabilityReason: enabled ? ""
                        : "Chọn đúng một nội dung đang mở để tạo gói"
                    Accessible.name: "Tạo production package hàng loạt"
                    onClicked: root.createPackageRequested()
                }
                AppButton {
                    objectName: "contentBulkScheduleButton"
                    text: "Lên lịch"
                    leadingIcon: "semantic/upload-cloud"
                    enabled: root.canWrite && root.bulkSelectionCount === 1
                        && root.bulkSelected(root.selectedContentId) && !root.bulkBusy
                    availabilityReason: enabled ? ""
                        : "Chọn đúng một nội dung đang mở để chuyển sang lịch"
                    Accessible.name: "Lên lịch nội dung hàng loạt"
                    onClicked: root.scheduleRequested()
                }
                AppButton {
                    objectName: "contentBulkArchiveButton"
                    text: "Lưu trữ"
                    leadingIcon: "ui/minus"
                    enabled: root.bulkEnabled && root.bulkSelectionCount > 0 && !root.bulkBusy
                    availabilityReason: enabled ? ""
                        : !root.bulkEnabled ? (root.bulkAvailabilityReason
                            || "Thao tác hàng loạt chưa khả dụng")
                        : root.bulkBusy ? "Đang xử lý thao tác hàng loạt"
                        : "Chưa chọn nội dung"
                    Accessible.name: "Xem trước lưu trữ hàng loạt"
                    onClicked: root.bulkOperationRequested("archive")
                }
                AppButton {
                    objectName: "contentBulkSelectionCloseButton"
                    text: ""
                    leadingIcon: "ui/close"
                    enabled: root.bulkSelectionCount > 0 && !root.bulkBusy
                    availabilityReason: enabled ? "" : "Không có lựa chọn để đóng"
                    Accessible.name: "Đóng thanh thao tác hàng loạt"
                    onClicked: root.clearSelectionRequested()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 44 : 0
            visible: root.viewMode === "list"
            color: Theme.panel
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8
                visible: root.rendererKey === "content"
                CheckBox {
                    id: bulkHeaderCheck
                    objectName: "contentBulkSelectAllHeader"
                    activeFocusOnTab: true
                    Layout.preferredWidth: 28
                    Layout.minimumWidth: 28
                    Layout.maximumWidth: 28
                    Layout.preferredHeight: 28
                    padding: 0
                    enabled: root.bulkEnabled && root.inventoryModel.count > 0
                        && !root.bulkBusy
                    checked: root.allVisibleSelected()
                    indicator: Rectangle {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        radius: 4
                        color: bulkHeaderCheck.checked ? Theme.accentSoft : Theme.elevated
                        border.width: 1
                        border.color: bulkHeaderCheck.checked ? Theme.accent : Theme.border
                        UiIcon {
                            anchors.centerIn: parent
                            visible: bulkHeaderCheck.checked
                            name: "ui/check"
                            tone: Theme.accent
                            iconSize: 12
                        }
                    }
                    Accessible.name: checked ? "Bỏ chọn trang" : "Chọn toàn bộ trang"
                    Accessible.description: enabled ? ""
                        : (root.bulkAvailabilityReason || "Chọn hàng loạt chưa khả dụng")
                    onClicked: checked ? root.selectVisibleRequested()
                        : root.clearSelectionRequested()
                }
                Text { objectName: "contentColumnTitle"; Layout.preferredWidth: root.contentTitleWidth; Layout.minimumWidth: root.contentTitleWidth; Layout.maximumWidth: root.contentTitleWidth; text: root.columnLabel("title", root.entityType === "content" ? "NỘI DUNG" : "TÊN").toUpperCase(); color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                Text { objectName: "contentColumnPillar"; Layout.preferredWidth: root.contentPillarWidth; Layout.minimumWidth: root.contentPillarWidth; Layout.maximumWidth: root.contentPillarWidth; text: root.columnLabel("pillar", "PILLAR").toUpperCase(); color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                Text { objectName: "contentColumnPlatform"; Layout.preferredWidth: root.contentPlatformWidth; Layout.minimumWidth: root.contentPlatformWidth; Layout.maximumWidth: root.contentPlatformWidth; text: root.columnLabel("platform", "KÊNH / NỀN TẢNG").toUpperCase(); color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                Text { objectName: "contentColumnCampaign"; Layout.preferredWidth: root.contentCampaignWidth; Layout.minimumWidth: root.contentCampaignWidth; Layout.maximumWidth: root.contentCampaignWidth; text: root.columnLabel("campaign", "CAMPAIGN").toUpperCase(); color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                Text { objectName: "contentColumnStage"; Layout.preferredWidth: root.contentStageWidth; Layout.minimumWidth: root.contentStageWidth; Layout.maximumWidth: root.contentStageWidth; text: root.columnLabel("stage", "GIAI ĐOẠN").toUpperCase(); color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                Text { objectName: "contentColumnCompleteness"; Layout.preferredWidth: root.contentCompletenessWidth; Layout.minimumWidth: root.contentCompletenessWidth; Layout.maximumWidth: root.contentCompletenessWidth; text: root.columnLabel("completeness", "HOÀN TẤT").toUpperCase(); color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                Text { objectName: "contentColumnSchedule"; Layout.preferredWidth: root.contentScheduleWidth; Layout.minimumWidth: root.contentScheduleWidth; Layout.maximumWidth: root.contentScheduleWidth; text: root.columnLabel("schedule", "LÊN LỊCH").toUpperCase(); color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                Text { objectName: "contentColumnOwner"; Layout.fillWidth: true; Layout.minimumWidth: root.contentOwnerMinimumWidth; text: root.columnLabel("owner", "CHỦ SỞ HỮU").toUpperCase(); color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                Text { objectName: "contentColumnUpdated"; Layout.preferredWidth: root.contentUpdatedWidth; Layout.minimumWidth: root.contentUpdatedWidth; Layout.maximumWidth: root.contentUpdatedWidth; text: root.columnLabel("updated_at", "CẬP NHẬT").toUpperCase(); color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
            }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12
                visible: root.rendererKey !== "content"
                Text {
                    objectName: "contentTypedColumnTitle"
                    Layout.preferredWidth: 310
                    Layout.minimumWidth: 310
                    Layout.maximumWidth: 310
                    text: root.columnLabel(
                        root.rendererKey === "asset" ? "file_name" : "title",
                        root.rendererKey === "campaign" ? "CAMPAIGN"
                            : root.rendererKey === "package" ? "GÓI SẢN XUẤT"
                                : "TÀI NGUYÊN"
                    ).toUpperCase()
                    color: Theme.textFaint
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }
                Text {
                    objectName: "contentTypedColumnKind"
                    Layout.preferredWidth: 150
                    Layout.minimumWidth: 150
                    Layout.maximumWidth: 150
                    text: root.columnLabel(
                        root.rendererKey === "campaign" ? "objective"
                            : root.rendererKey === "asset" ? "media_type"
                                : root.rendererKey === "package" ? "version" : "kind",
                        root.rendererKey === "campaign" ? "MỤC TIÊU"
                            : root.rendererKey === "asset" ? "LOẠI"
                                : "LOẠI / PHIÊN BẢN"
                    ).toUpperCase()
                    color: Theme.textFaint
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }
                Text {
                    objectName: "contentTypedColumnScope"
                    Layout.preferredWidth: 180
                    Layout.minimumWidth: 180
                    Layout.maximumWidth: 180
                    text: root.columnLabel(
                        root.rendererKey === "campaign" ? "channel"
                            : root.rendererKey === "asset" ? "probe" : "platform",
                        root.rendererKey === "asset" ? "MEDIA PROBE"
                            : "KÊNH / NỀN TẢNG"
                    ).toUpperCase()
                    color: Theme.textFaint
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }
                Text {
                    objectName: "contentTypedColumnState"
                    Layout.preferredWidth: 130
                    Layout.minimumWidth: 130
                    Layout.maximumWidth: 130
                    text: root.columnLabel(
                        root.rendererKey === "asset" ? "qc"
                            : root.rendererKey === "package" ? "readiness" : "status",
                        root.rendererKey === "asset" ? "QC" : "TRẠNG THÁI"
                    ).toUpperCase()
                    color: Theme.textFaint
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }
                Text {
                    objectName: "contentTypedColumnEvidence"
                    Layout.fillWidth: true
                    text: root.columnLabel(
                        root.rendererKey === "campaign" ? "content_count"
                            : root.rendererKey === "asset" ? "size_bytes" : "evidence",
                        root.rendererKey === "campaign" ? "NỘI DUNG / MỤC TIÊU"
                            : root.rendererKey === "asset" ? "DUNG LƯỢNG"
                                : "BẰNG CHỨNG"
                    ).toUpperCase()
                    color: Theme.textFaint
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }
                Text {
                    objectName: "contentTypedColumnUpdated"
                    Layout.preferredWidth: 110
                    Layout.minimumWidth: 110
                    Layout.maximumWidth: 110
                    text: root.columnLabel("updated_at", "CẬP NHẬT").toUpperCase()
                    color: Theme.textFaint
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }
            }
        }

        Item {
            objectName: "contentRenderer_" + root.rendererKey
            Layout.preferredWidth: 0
            Layout.preferredHeight: 0
            visible: true
            Accessible.name: "Bộ hiển thị " + root.rendererKey
            Accessible.role: Accessible.Pane
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: listView
                objectName: "contentInventoryList"
                anchors.fill: parent
                visible: root.viewMode === "list"
                clip: true
                model: root.inventoryModel
                cacheBuffer: 1200
                spacing: 1
                interactive: false
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    objectName: "contentInventoryListScrollBar"
                    policy: ScrollBar.AlwaysOff
                }
                delegate: Rectangle {
                id: row
                required property string entity_id
                required property var title
                required property var subtitle
                required property var aspect_ratio
                required property var pillar
                required property var channel
                required property var campaign
                required property var stage
                required property var readiness
                required property var schedule
                required property var owner
                required property var thumbnail
                required property var updated_at
                required property var deep_link
                required property var name
                required property var objective
                required property var status
                required property var package_key
                required property var version
                required property var platform
                required property var file_name
                required property var media_type
                required property var mime_type
                required property var content_count
                required property var target_count
                required property var content_id
                required property var asset_id
                required property var size_bytes
                required property var probe
                required property var qc
                property var itemData: ({
                    "id": row.entity_id,
                    "title": row.title,
                    "subtitle": row.subtitle,
                    "aspect_ratio": row.aspect_ratio,
                    "pillar": row.pillar,
                    "channel": row.channel,
                    "campaign": row.campaign,
                    "stage": row.stage,
                    "readiness": row.readiness,
                    "schedule": row.schedule,
                    "owner": row.owner,
                    "thumbnail": row.thumbnail,
                    "updated_at": row.updated_at,
                    "deep_link": row.deep_link,
                    "name": row.name,
                    "objective": row.objective,
                    "status": row.status,
                    "package_key": row.package_key,
                    "version": row.version,
                    "platform": row.platform,
                    "file_name": row.file_name,
                    "media_type": row.media_type,
                    "mime_type": row.mime_type,
                    "content_count": row.content_count,
                    "target_count": row.target_count,
                    "content_id": row.content_id,
                    "asset_id": row.asset_id,
                    "size_bytes": row.size_bytes,
                    "probe": row.probe,
                    "qc": row.qc
                })
                property bool thumbnailAvailable: Boolean((row.itemData.thumbnail || {}).available)
                property bool ownerAvailable: Boolean((row.itemData.owner || {}).available)
                property bool selected: String(row.itemData.id || "") === root.selectedEntityId
                property bool bulkSelected: root.bulkSelected(row.itemData.id)
                objectName: "contentRow_" + String(row.itemData.id || "unknown")
                width: ListView.view.width
                height: root.listRowHeight
                color: row.selected ? Theme.accentSoft : (mouseArea.containsMouse ? Theme.hover : Theme.panel)
                border.width: row.selected ? 1 : 0
                border.color: Theme.accent
                Accessible.name: root.rowTitle(row.itemData)
                Accessible.role: Accessible.ListItem
                activeFocusOnTab: true
                Accessible.focusable: true
                Keys.onReturnPressed: row.activate()
                Keys.onEnterPressed: row.activate()
                Keys.onSpacePressed: row.activate()

                function activate() {
                    root.itemRequested(row.itemData)
                    return true
                }

                RowLayout {
                    z: 1
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: root.contentTableSpacing
                    visible: root.rendererKey === "content"
                    CheckBox {
                        id: bulkListCheck
                        objectName: "contentBulkSelect_" + String(row.itemData.id || "unknown")
                        activeFocusOnTab: true
                        Layout.preferredWidth: 28
                        Layout.minimumWidth: 28
                        Layout.maximumWidth: 28
                        padding: 0
                        visible: root.entityType === "content"
                        enabled: root.bulkEnabled && Number(row.itemData.version || 0) > 0
                            && !root.bulkBusy
                        checked: row.bulkSelected
                        indicator: Rectangle {
                            id: bulkListIndicator
                            implicitWidth: 18
                            implicitHeight: 18
                            x: 5
                            y: Math.round((parent.height - height) / 2)
                            radius: 4
                            color: bulkListCheck.checked ? Theme.accentSoft : Theme.elevated
                            border.width: 1
                            border.color: bulkListCheck.checked ? Theme.accent : Theme.border
                            UiIcon {
                                anchors.centerIn: parent
                                visible: bulkListCheck.checked
                                name: "semantic/check-circle"
                                tone: Theme.accent
                                iconSize: 12
                            }
                        }
                        Accessible.name: (checked ? "Bỏ chọn " : "Chọn ")
                            + root.rowTitle(row.itemData)
                        onClicked: root.itemSelectionRequested(row.itemData)
                    }
                    RowLayout {
                        objectName: "contentRowTitleCell_"
                            + String(row.itemData.id || "unknown")
                        Layout.preferredWidth: root.contentTitleWidth
                        Layout.minimumWidth: root.contentTitleWidth
                        Layout.maximumWidth: root.contentTitleWidth
                        spacing: 9
                        Rectangle {
                            Layout.preferredWidth: 84
                            Layout.preferredHeight: 58
                            radius: Theme.radiusSmall
                            color: Theme.elevated
                            border.width: 1
                            border.color: Theme.borderSoft
                            Image {
                                id: rowThumbnailImage
                                readonly property string resolvedThumbnailUrl:
                                    row.thumbnailAvailable && root.controlPlaneBridge
                                    ? root.controlPlaneBridge.authorizedThumbnailUrl(
                                        String((row.itemData.thumbnail || {}).asset_id || ""),
                                        String((row.itemData.thumbnail || {}).thumbnail_url || ""))
                                    : ""
                                objectName: "contentThumbnail_" + String(
                                    row.itemData.id || "unknown")
                                anchors.fill: parent
                                anchors.margins: 1
                                visible: resolvedThumbnailUrl.length > 0
                                source: resolvedThumbnailUrl
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                            }
                            UiIcon {
                                anchors.centerIn: parent
                                visible: rowThumbnailImage.resolvedThumbnailUrl.length === 0
                                name: "semantic/video"
                                tone: Theme.textFaint
                                iconSize: 19
                            }
                            Rectangle {
                                visible: Boolean(row.itemData.aspect_ratio)
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.margins: 4
                                width: aspectText.implicitWidth + 8
                                height: 16
                                radius: 4
                                color: Qt.rgba(0, 0, 0, 0.64)
                                Text {
                                    id: aspectText
                                    anchors.centerIn: parent
                                    text: String(row.itemData.aspect_ratio || "")
                                    color: "white"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                Layout.fillWidth: true
                                text: root.rowTitle(row.itemData)
                                color: Theme.text
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: root.rowSubtitle(row.itemData)
                                color: Theme.textFaint
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }
                    Text {
                        objectName: "contentRowPillar_"
                            + String(row.itemData.id || "unknown")
                        Layout.preferredWidth: root.contentPillarWidth
                        Layout.minimumWidth: root.contentPillarWidth
                        Layout.maximumWidth: root.contentPillarWidth
                        text: root.pillarText(row.itemData)
                        color: Theme.textMuted
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    RowLayout {
                        objectName: "contentRowPlatform_"
                            + String(row.itemData.id || "unknown")
                        Layout.preferredWidth: root.contentPlatformWidth
                        Layout.minimumWidth: root.contentPlatformWidth
                        Layout.maximumWidth: root.contentPlatformWidth
                        spacing: 7
                        Rectangle {
                            objectName: "contentPlatformMark_"
                                + String(row.itemData.id || "unknown")
                            Layout.preferredWidth: 26
                            Layout.minimumWidth: 26
                            Layout.maximumWidth: 26
                            Layout.preferredHeight: 26
                            radius: 7
                            color: root.platformTone(
                                (row.itemData.channel || {}).platform)
                            UiIcon {
                                anchors.centerIn: parent
                                name: root.platformIcon(
                                    (row.itemData.channel || {}).platform)
                                tone: "white"
                                iconSize: 15
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                Layout.fillWidth: true
                                text: String((row.itemData.channel || {}).name || "—")
                                color: Theme.textMuted
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: String((row.itemData.channel || {}).platform || "")
                                color: Theme.textFaint
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }
                    Text {
                        objectName: "contentRowCampaign_"
                            + String(row.itemData.id || "unknown")
                        Layout.preferredWidth: root.contentCampaignWidth
                        Layout.minimumWidth: root.contentCampaignWidth
                        Layout.maximumWidth: root.contentCampaignWidth
                        text: root.campaignText(row.itemData)
                        color: Theme.textMuted
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    Foundation.StatusPill {
                        objectName: "contentRowStage_"
                            + String(row.itemData.id || "unknown")
                        Layout.preferredWidth: root.contentStageWidth
                        Layout.minimumWidth: root.contentStageWidth
                        Layout.maximumWidth: root.contentStageWidth
                        text: root.typedStageText(row.itemData)
                        tone: root.stageTone((row.itemData.stage || {}).key || row.itemData.status)
                    }
                    ColumnLayout {
                        objectName: "contentRowCompleteness_"
                            + String(row.itemData.id || "unknown")
                        Layout.preferredWidth: root.contentCompletenessWidth
                        Layout.minimumWidth: root.contentCompletenessWidth
                        Layout.maximumWidth: root.contentCompletenessWidth
                        spacing: 2
                        Text {
                            objectName: "contentReadinessPercent_"
                                + String(row.itemData.id || "unknown")
                            text: root.readinessPercent(row.itemData.readiness) === null
                                ? "—" : String(root.readinessPercent(
                                    row.itemData.readiness)) + "%"
                            color: Boolean((row.itemData.readiness || {}).ready)
                                ? Theme.success : Theme.warning
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                        Foundation.ProgressMeter {
                            Layout.preferredWidth: 62
                            value: root.readinessPercent(row.itemData.readiness) === null
                                ? 0 : root.readinessPercent(row.itemData.readiness) / 100
                            tone: Boolean((row.itemData.readiness || {}).ready)
                                ? Theme.success : Theme.warning
                        }
                    }
                    Text {
                        objectName: "contentRowSchedule_"
                            + String(row.itemData.id || "unknown")
                        Layout.preferredWidth: root.contentScheduleWidth
                        Layout.minimumWidth: root.contentScheduleWidth
                        Layout.maximumWidth: root.contentScheduleWidth
                        text: root.scheduleText(
                            (row.itemData.schedule || {}).scheduled_at)
                        color: Theme.textMuted
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    RowLayout {
                        objectName: "contentRowOwner_"
                            + String(row.itemData.id || "unknown")
                        Layout.fillWidth: true
                        Layout.minimumWidth: root.contentOwnerMinimumWidth
                        spacing: 6
                        Rectangle {
                            objectName: "contentOwnerAvatar_"
                                + String(row.itemData.id || "unknown")
                            Layout.preferredWidth: 25
                            Layout.minimumWidth: 25
                            Layout.maximumWidth: 25
                            Layout.preferredHeight: 25
                            radius: 13
                            color: row.ownerAvailable ? Theme.accentSoft : Theme.elevated
                            border.width: 1
                            border.color: row.ownerAvailable ? Theme.accent : Theme.borderSoft
                            Text {
                                anchors.centerIn: parent
                                text: root.ownerInitials(row.itemData)
                                color: row.ownerAvailable ? Theme.accent : Theme.textFaint
                                font.pixelSize: 11
                                font.weight: Font.Bold
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.ownerName(row.itemData)
                            color: row.ownerAvailable ? Theme.textMuted : Theme.textFaint
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }
                    Text {
                        objectName: "contentRowUpdated_"
                            + String(row.itemData.id || "unknown")
                        Layout.preferredWidth: root.contentUpdatedWidth
                        Layout.minimumWidth: root.contentUpdatedWidth
                        Layout.maximumWidth: root.contentUpdatedWidth
                        text: root.updatedText(row.itemData.updated_at)
                        color: Theme.textFaint
                        font.pixelSize: 11
                        lineHeight: 0.9
                        horizontalAlignment: Text.AlignRight
                    }
                }
                RowLayout {
                    z: 1
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12
                    visible: root.rendererKey !== "content"
                    RowLayout {
                        objectName: "contentTypedTitleCell_"
                            + String(row.itemData.id || "unknown")
                        Layout.preferredWidth: 310
                        Layout.minimumWidth: 310
                        Layout.maximumWidth: 310
                        spacing: 9
                        Rectangle {
                            Layout.preferredWidth: 72
                            Layout.preferredHeight: 45
                            radius: Theme.radiusSmall
                            color: Theme.elevated
                            border.width: 1
                            border.color: Theme.borderSoft
                            UiIcon {
                                anchors.centerIn: parent
                                name: root.rendererKey === "campaign"
                                    ? "semantic/bar-chart" : "semantic/video"
                                tone: Theme.textFaint
                                iconSize: 19
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                Layout.fillWidth: true
                                text: root.rowTitle(row.itemData)
                                color: Theme.text
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: root.rowSubtitle(row.itemData)
                                color: Theme.textFaint
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }
                    Text {
                        objectName: "contentTypedKind_"
                            + String(row.itemData.id || "unknown")
                        Layout.preferredWidth: 150
                        Layout.minimumWidth: 150
                        Layout.maximumWidth: 150
                        text: root.pillarText(row.itemData)
                        color: Theme.textMuted
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    Text {
                        objectName: "contentTypedScope_"
                            + String(row.itemData.id || "unknown")
                        Layout.preferredWidth: 180
                        Layout.minimumWidth: 180
                        Layout.maximumWidth: 180
                        text: root.rendererKey === "asset"
                            ? root.probeText(row.itemData)
                            : root.platformText(row.itemData)
                        color: Theme.textMuted
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                    Foundation.StatusPill {
                        objectName: "contentTypedState_"
                            + String(row.itemData.id || "unknown")
                        Layout.preferredWidth: 130
                        Layout.minimumWidth: 130
                        Layout.maximumWidth: 130
                        text: root.typedStageText(row.itemData)
                        tone: root.typedStageTone(row.itemData)
                    }
                    Text {
                        objectName: "contentTypedEvidence_"
                            + String(row.itemData.id || "unknown")
                        Layout.fillWidth: true
                        text: root.rendererKey === "campaign"
                            ? String(Number(row.itemData.content_count || 0))
                                + "/" + String(Number(row.itemData.target_count || 0))
                                + " nội dung"
                            : root.rendererKey === "package"
                                ? (Boolean((row.itemData.readiness || {}).ready)
                                    ? "Đủ lineage" : "Còn blocker")
                                : root.formatBytes(row.itemData.size_bytes)
                        color: root.rendererKey === "package"
                            && !Boolean((row.itemData.readiness || {}).ready)
                            ? Theme.warning : Theme.textMuted
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    Text {
                        objectName: "contentTypedUpdated_"
                            + String(row.itemData.id || "unknown")
                        Layout.preferredWidth: 110
                        Layout.minimumWidth: 110
                        Layout.maximumWidth: 110
                        text: root.updatedText(row.itemData.updated_at)
                        color: Theme.textFaint
                        font.pixelSize: 11
                        lineHeight: 0.9
                        horizontalAlignment: Text.AlignRight
                    }
                }
                MouseArea {
                    id: mouseArea
                    z: 0
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: row.activate()
                }
            }
        }

            GridView {
                id: gridView
                objectName: "contentInventoryGrid"
                anchors.fill: parent
                visible: root.viewMode === "grid"
                clip: true
                model: root.inventoryModel
                cellWidth: Math.max(1, Math.floor(width / Math.max(1, root.pageSize)))
                cellHeight: Math.min(188, Math.max(160, height))
                cacheBuffer: 900
                interactive: false
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    objectName: "contentInventoryGridScrollBar"
                    policy: ScrollBar.AlwaysOff
                }

            delegate: Rectangle {
                id: card
                required property string entity_id
                required property var title
                required property var subtitle
                required property var aspect_ratio
                required property var pillar
                required property var channel
                required property var campaign
                required property var stage
                required property var readiness
                required property var schedule
                required property var owner
                required property var thumbnail
                required property var updated_at
                required property var deep_link
                required property var name
                required property var objective
                required property var status
                required property var package_key
                required property var version
                required property var platform
                required property var file_name
                required property var media_type
                required property var mime_type
                required property var content_count
                required property var target_count
                required property var content_id
                required property var asset_id
                required property var size_bytes
                required property var probe
                required property var qc
                property var itemData: ({
                    "id": card.entity_id,
                    "title": card.title,
                    "subtitle": card.subtitle,
                    "aspect_ratio": card.aspect_ratio,
                    "pillar": card.pillar,
                    "channel": card.channel,
                    "campaign": card.campaign,
                    "stage": card.stage,
                    "readiness": card.readiness,
                    "schedule": card.schedule,
                    "owner": card.owner,
                    "thumbnail": card.thumbnail,
                    "updated_at": card.updated_at,
                    "deep_link": card.deep_link,
                    "name": card.name,
                    "objective": card.objective,
                    "status": card.status,
                    "package_key": card.package_key,
                    "version": card.version,
                    "platform": card.platform,
                    "file_name": card.file_name,
                    "media_type": card.media_type,
                    "mime_type": card.mime_type,
                    "content_count": card.content_count,
                    "target_count": card.target_count,
                    "content_id": card.content_id,
                    "asset_id": card.asset_id,
                    "size_bytes": card.size_bytes,
                    "probe": card.probe,
                    "qc": card.qc
                })
                readonly property bool thumbnailAvailable: Boolean(
                    (card.itemData.thumbnail || {}).available
                )
                readonly property bool selected: String(card.itemData.id || "")
                    === root.selectedEntityId
                readonly property bool bulkSelected: root.bulkSelected(card.itemData.id)

                objectName: "contentGridCard_" + String(card.itemData.id || "unknown")
                width: GridView.view.cellWidth - 8
                height: GridView.view.cellHeight - 8
                radius: Theme.radiusMedium
                color: card.selected ? Theme.accentSoft
                    : (cardMouse.containsMouse ? Theme.hover : Theme.panel)
                border.width: card.selected ? 1 : 1
                border.color: card.selected ? Theme.accent : Theme.borderSoft
                activeFocusOnTab: true
                Accessible.role: Accessible.ListItem
                Accessible.name: root.rowTitle(card.itemData)
                Accessible.focusable: true
                Keys.onReturnPressed: card.activate()
                Keys.onEnterPressed: card.activate()
                Keys.onSpacePressed: card.activate()

                function activate() {
                    root.itemRequested(card.itemData)
                    return true
                }

                ColumnLayout {
                    z: 1
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 5

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 88
                        radius: Theme.radiusSmall
                        color: Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft

                        Image {
                            id: cardThumbnailImage
                            readonly property string resolvedThumbnailUrl:
                                card.thumbnailAvailable && root.controlPlaneBridge
                                ? root.controlPlaneBridge.authorizedThumbnailUrl(
                                    String((card.itemData.thumbnail || {}).asset_id || ""),
                                    String((card.itemData.thumbnail || {}).thumbnail_url || ""))
                                : ""
                            objectName: "contentGridThumbnail_"
                                + String(card.itemData.id || "unknown")
                            anchors.fill: parent
                            anchors.margins: 1
                            visible: resolvedThumbnailUrl.length > 0
                            source: resolvedThumbnailUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                        }
                        UiIcon {
                            objectName: "contentGridHeroIcon_"
                                + String(card.itemData.id || "unknown")
                            anchors.centerIn: parent
                            visible: cardThumbnailImage.resolvedThumbnailUrl.length === 0
                            name: root.cardIcon(card.itemData)
                            tone: root.cardIconTone(card.itemData)
                            iconSize: root.rendererKey === "content" ? 22 : 28
                        }
                        Rectangle {
                            objectName: "contentCampaignProgressTrack_"
                                + String(card.itemData.id || "unknown")
                            visible: root.rendererKey === "campaign"
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 8
                            height: 5
                            radius: 3
                            color: Theme.borderSoft
                            Rectangle {
                                objectName: "contentCampaignProgress_"
                                    + String(card.itemData.id || "unknown")
                                width: parent.width * root.campaignProgress(card.itemData)
                                height: parent.height
                                radius: parent.radius
                                color: root.cardIconTone(card.itemData)
                            }
                        }
                        Foundation.StatusPill {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 5
                            text: root.typedStageText(card.itemData)
                            tone: root.typedStageTone(card.itemData)
                        }
                        CheckBox {
                            id: bulkGridCheck
                            objectName: "contentGridBulkSelect_"
                                + String(card.itemData.id || "unknown")
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.margins: 4
                            width: 22
                            height: 22
                            padding: 0
                            visible: root.entityType === "content"
                            enabled: root.bulkEnabled && Number(card.itemData.version || 0) > 0
                                && !root.bulkBusy
                            checked: card.bulkSelected
                            indicator: Rectangle {
                                id: bulkGridIndicator
                                anchors.centerIn: parent
                                width: 18
                                height: 18
                                radius: 4
                                color: bulkGridCheck.checked
                                    ? Theme.accentSoft : Theme.elevated
                                border.width: 1
                                border.color: bulkGridCheck.checked
                                    ? Theme.accent : Theme.border
                                UiIcon {
                                    anchors.centerIn: parent
                                    visible: bulkGridCheck.checked
                                    name: "semantic/check-circle"
                                    tone: Theme.accent
                                    iconSize: 12
                                }
                            }
                            activeFocusOnTab: true
                            Accessible.name: (checked ? "Bỏ chọn " : "Chọn ")
                                + root.rowTitle(card.itemData)
                            onClicked: root.itemSelectionRequested(card.itemData)
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.rowTitle(card.itemData)
                        color: Theme.text
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.cardPrimaryDetail(card.itemData)
                        color: Theme.textMuted
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: root.cardEvidence(card.itemData)
                            color: Theme.textFaint
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                        Text {
                            text: root.rendererKey === "content"
                                ? (root.readinessPercent(card.itemData.readiness) === null
                                    ? "—" : String(root.readinessPercent(card.itemData.readiness)) + "%")
                                : root.updatedText(card.itemData.updated_at).replace("\n", " · ")
                            color: Boolean((card.itemData.readiness || {}).ready)
                                ? Theme.success : Theme.warning
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }
                }

                MouseArea {
                    id: cardMouse
                    z: 0
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: card.activate()
                }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: Theme.elevated
            border.width: 1
            border.color: Theme.borderSoft
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                Text {
                    Layout.fillWidth: true
                    text: "Hiển thị "
                        + String(Number(root.inventory.cursor || 0) + 1)
                        + "–" + String(Number(root.inventory.cursor || 0)
                            + root.inventoryModel.count)
                        + " của " + String(Number(root.inventory.total || 0))
                    color: Theme.textFaint
                    font.pixelSize: 11
                }
                AppButton {
                    objectName: "contentPreviousPageButton"
                    text: ""
                    leadingIcon: "ui/chevron-left"
                    enabled: root.hasPreviousPage
                    availabilityReason: enabled ? "" : "Không có trang trước"
                    Accessible.name: "Trang trước"
                    onClicked: root.previousPageRequested()
                }
                Item {
                    id: contentPageList
                    Layout.preferredWidth: Math.max(
                        0, contentPageRepeater.count * 34
                            + Math.max(0, contentPageRepeater.count - 1) * 6)
                    Layout.preferredHeight: 34
                    clip: true
                    Row {
                        anchors.fill: parent
                        spacing: 6
                        Repeater {
                            id: contentPageRepeater
                            model: root.paginationItems
                            delegate: Loader {
                        id: pageLoader
                        required property int index
                        required property var modelData
                        width: 34
                        height: 34
                        sourceComponent: String(pageLoader.modelData.kind) === "ellipsis"
                            ? ellipsisComponent : pageComponent
                        Component {
                            id: pageComponent
                            AppButton {
                                readonly property int pageNumber: Number(
                                    pageLoader.modelData.page || 0)
                                objectName: "contentPaginationPage_" + String(pageNumber)
                                text: String(pageNumber)
                                implicitWidth: 34
                                checkable: true
                                checked: root.currentPage === pageNumber
                                primary: checked
                                Accessible.name: "Trang " + String(pageNumber)
                                onClicked: root.pageRequested(pageNumber)
                            }
                        }
                        Component {
                            id: ellipsisComponent
                            Text {
                                objectName: "contentPaginationEllipsis"
                                text: "…"
                                color: Theme.textFaint
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                Accessible.name: "Các trang ở giữa"
                                Accessible.role: Accessible.StaticText
                            }
                        }
                            }
                        }
                    }
                }
                AppButton {
                    objectName: "contentNextPageButton"
                    text: ""
                    leadingIcon: "ui/chevron-right"
                    enabled: root.hasNextPage
                    availabilityReason: enabled ? "" : "Không có trang sau"
                    Accessible.name: "Trang sau"
                    onClicked: root.nextPageRequested()
                }
                Rectangle {
                    Layout.preferredWidth: 88
                    Layout.preferredHeight: 34
                    radius: Theme.radiusSmall
                    color: Theme.panel
                    border.width: 1
                    border.color: Theme.borderSoft
                    Text {
                        objectName: "contentPageCapacityLabel"
                        anchors.centerIn: parent
                        text: String(root.pageSize) + " / trang"
                        color: Theme.textMuted
                        font.pixelSize: 11
                    }
                    Accessible.name: "Hiển thị " + String(root.pageSize)
                        + " nội dung mỗi trang"
                    Accessible.role: Accessible.StaticText
                }
            }
        }
    }

    component InventoryTabButton: Button {
        id: tabButton
        required property string tabKey
        required property string label
        objectName: "contentTab_" + tabKey
        width: tabKey === "packages" ? 116 : 96
        height: 44
        text: label
        flat: true
        activeFocusOnTab: true
        Accessible.name: "Mở " + text
        onClicked: root.tabRequested(tabKey)
        contentItem: Text {
            text: tabButton.text
            color: root.activeTab === tabButton.tabKey
                ? Theme.accent : Theme.textMuted
            font.pixelSize: 12
            font.weight: root.activeTab === tabButton.tabKey
                ? Font.DemiBold : Font.Normal
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: "transparent"
            Rectangle {
                visible: root.activeTab === tabButton.tabKey
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 2
                color: Theme.accent
            }
        }
    }

    component LifecycleStageButton: Button {
        id: lifecycleButton
        required property int stageIndex
        required property string expectedKey
        required property string fallbackLabel
        readonly property var stageData: root.lifecycleItem(
            stageIndex, expectedKey, fallbackLabel)
        readonly property string stageKey: String(stageData.key || expectedKey)
        objectName: "contentLifecycle_" + stageKey
        width: Math.max(
            150,
            (contentLifecycleStageList.width
                - contentLifecycleStageList.spacing
                    * Math.max(0, contentLifecycleStageList.count - 1))
                / Math.max(1, contentLifecycleStageList.count)
        )
        height: lifecycleStageRow.height
        activeFocusOnTab: true
        Accessible.name: String(stageData.label || fallbackLabel)
            + ": " + Number(stageData.count || 0)
        onClicked: root.stageRequested(root.stageFilter === stageKey ? "" : stageKey)
        background: Rectangle {
            radius: Theme.radiusSmall
            color: root.stageFilter === lifecycleButton.stageKey
                ? Qt.rgba(root.stageTone(lifecycleButton.stageKey).r,
                    root.stageTone(lifecycleButton.stageKey).g,
                    root.stageTone(lifecycleButton.stageKey).b, 0.14)
                : "transparent"
            border.width: root.stageFilter === lifecycleButton.stageKey ? 1 : 0
            border.color: root.stageTone(lifecycleButton.stageKey)
        }
        contentItem: RowLayout {
            spacing: root.compactLifecycle ? 4 : 7
            Rectangle {
                objectName: "contentLifecycleIcon_" + lifecycleButton.stageKey
                Layout.preferredWidth: root.compactLifecycle ? 28 : 32
                Layout.minimumWidth: root.compactLifecycle ? 28 : 32
                Layout.maximumWidth: root.compactLifecycle ? 28 : 32
                Layout.preferredHeight: root.compactLifecycle ? 28 : 32
                radius: (root.compactLifecycle ? 28 : 32) / 2
                color: Qt.rgba(root.stageTone(lifecycleButton.stageKey).r,
                    root.stageTone(lifecycleButton.stageKey).g,
                    root.stageTone(lifecycleButton.stageKey).b, 0.15)
                border.width: 1
                border.color: Qt.rgba(root.stageTone(lifecycleButton.stageKey).r,
                    root.stageTone(lifecycleButton.stageKey).g,
                    root.stageTone(lifecycleButton.stageKey).b, 0.45)
                UiIcon {
                    anchors.centerIn: parent
                    name: root.stageIcon(lifecycleButton.stageKey)
                    tone: root.stageTone(lifecycleButton.stageKey)
                    iconSize: 16
                }
            }
            Text {
                objectName: "contentLifecycleLabel_" + lifecycleButton.stageKey
                Layout.fillWidth: true
                Layout.fillHeight: true
                // Keep the canonical lifecycle rail concise. The full
                // server-projected label remains available to accessibility
                // through the parent button.
                text: lifecycleButton.fallbackLabel
                color: Theme.textMuted
                font.pixelSize: root.compactLifecycle ? 10 : 11
                wrapMode: Text.NoWrap
                verticalAlignment: Text.AlignVCenter
            }
            Rectangle {
                Layout.preferredWidth: Math.max(
                    root.compactLifecycle ? 24 : 28,
                    lifecycleCount.implicitWidth + (root.compactLifecycle ? 8 : 12)
                )
                Layout.preferredHeight: root.compactLifecycle ? 20 : 22
                radius: Layout.preferredHeight / 2
                color: Theme.panel
                border.width: 1
                border.color: Theme.borderSoft
                Text {
                    id: lifecycleCount
                    anchors.centerIn: parent
                    text: String(Number(lifecycleButton.stageData.count || 0))
                    color: Theme.text
                    font.pixelSize: root.compactLifecycle ? 10 : 11
                    font.weight: Font.Bold
                }
            }
            Item {
                objectName: "contentLifecycleConnector_" + lifecycleButton.stageKey
                visible: lifecycleButton.stageIndex < contentLifecycleStageList.count - 1
                Layout.preferredWidth: visible ? (root.compactLifecycle ? 14 : 22) : 0
                Layout.minimumWidth: visible ? (root.compactLifecycle ? 14 : 22) : 0
                Layout.maximumWidth: visible ? (root.compactLifecycle ? 14 : 22) : 0
                Layout.preferredHeight: root.compactLifecycle ? 28 : 32
                UiIcon {
                    anchors.centerIn: parent
                    name: "ui/chevron-right"
                    tone: Theme.textFaint
                    iconSize: 20
                }
            }
        }
    }

    component FilterSelect: ContentComboBox {
        id: combo
        property string label: ""
        property var items: []
        property string selectedValue: ""
        signal valueRequested(string value)
        activeFocusOnTab: true
        Layout.fillWidth: true
        Layout.preferredWidth: combo.label.indexOf("chiến dịch") >= 0 ? 180
            : combo.label.indexOf("giai đoạn") >= 0 ? 175
            : combo.label.indexOf("ngôn ngữ") >= 0 ? 160
            : combo.label.indexOf("định dạng") >= 0 ? 160 : 150
        Layout.minimumWidth: 130
        model: combo.items
        textRole: "label"
        valueRole: "id"
        currentIndex: root.comboIndex(combo.items, combo.selectedValue)
        displayText: combo.selectedValue.length === 0
            ? combo.label : combo.textAt(combo.currentIndex)
        Accessible.name: combo.label
        onActivated: combo.valueRequested(String(currentValue || ""))
    }
}
