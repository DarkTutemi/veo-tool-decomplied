pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "reportsHeader"

    property var scope: ({})
    property string snapshotId: ""
    property var filterCatalog: ({})
    property var headerProjection: ({})
    property bool canRead: false
    property bool canExport: false
    property bool busy: false
    property bool exportBusy: false
    property bool hasDraftRange: false
    property var draftStartAt: null
    property var draftEndAt: null
    property bool hasDraftChannel: false
    property var draftChannelId: null
    property bool hasDraftCampaign: false
    property var draftCampaignId: null
    property bool hasDraftPlatform: false
    property var draftPlatformValue: null
    property int draftRevision: 0

    readonly property var applyAction:
        root.memberMap(root.memberMap(root.headerProjection, "actions"), "apply")
    readonly property var exportAction:
        root.memberMap(root.memberMap(root.headerProjection, "actions"), "export")
    readonly property var advancedAction:
        root.memberMap(root.memberMap(root.filterCatalog, "advanced"), "action")
    readonly property bool compareEnabled: compareToggle.checked
    readonly property var draftQuery: root.draftRevision >= 0
        ? root.composeDraftQuery() : ({})
    readonly property string startAt: String(root.draftQuery.start_at || "")
    readonly property string endAt: String(root.draftQuery.end_at || "")
    readonly property string channelId: String(root.draftQuery.channel_id || "")
    readonly property string campaignId: String(root.draftQuery.campaign_id || "")
    readonly property string platformValue: String(root.draftQuery.platform || "")

    signal applyRequested(var query)
    signal exportRequested()

    Accessible.name: "Phạm vi và bộ lọc báo cáo"
    Accessible.role: Accessible.Pane

    function selectedIndex(options) {
        const source = root.listOrEmpty(options)
        for (let index = 0; index < source.length; index++)
            if (Boolean((source[index] || {}).selected)) return index
        return source.length > 0 ? 0 : -1
    }

    function clearDraftActions() {
        root.hasDraftRange = false
        root.draftStartAt = null
        root.draftEndAt = null
        root.hasDraftChannel = false
        root.draftChannelId = null
        root.hasDraftCampaign = false
        root.draftCampaignId = null
        root.hasDraftPlatform = false
        root.draftPlatformValue = null
        root.draftRevision += 1
    }

    function syncSnapshotSelection() {
        rangeFilter.currentIndex = root.selectedIndex(root.filterCatalog.ranges)
        channelFilter.currentIndex = root.selectedIndex(root.filterCatalog.channels)
        campaignFilter.currentIndex = root.selectedIndex(root.filterCatalog.campaigns)
        platformFilter.currentIndex = root.selectedIndex(root.filterCatalog.platforms)
        compareToggle.checked = Boolean(root.scope.compare)
    }

    onSnapshotIdChanged: {
        root.clearDraftActions()
        Qt.callLater(root.syncSnapshotSelection)
    }
    Component.onCompleted: Qt.callLater(root.syncSnapshotSelection)

    function mapOrEmpty(value) {
        return value === null || value === undefined || typeof value !== "object"
            ? ({}) : value
    }

    function listOrEmpty(value) {
        return value === null || value === undefined ? [] : value
    }

    function memberMap(value, key) {
        const source = root.mapOrEmpty(value)
        return root.mapOrEmpty(source[key])
    }

    function actionInput(action) {
        return root.memberMap(action, "input")
    }

    function composeDraftQuery() {
        const query = Object.assign({}, root.actionInput(root.applyAction))
        if (root.hasDraftRange) {
            query.start_at = root.draftStartAt
            query.end_at = root.draftEndAt
        }
        if (root.hasDraftChannel) query.channel_id = root.draftChannelId
        if (root.hasDraftCampaign) query.campaign_id = root.draftCampaignId
        if (root.hasDraftPlatform) query.platform = root.draftPlatformValue
        query.compare = Boolean(compareToggle.checked)
        query.offset = 0
        return query
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 10
        spacing: 7

        ColumnLayout {
            Layout.preferredWidth: 245
            spacing: 1
            Text {
                objectName: "reportsHeaderEyebrow"
                text: String(root.headerProjection.eyebrow || "ĐIỀU HÀNH HIỆU SUẤT")
                color: Theme.accent
                font.pixelSize: Theme.fontMetadata
                font.weight: Font.Bold
                font.letterSpacing: 1.0
            }
            Text {
                text: String(root.headerProjection.title || "Báo cáo & Hiệu suất")
                color: Theme.text
                font.pixelSize: Theme.fontPageTitle
                font.weight: Font.Bold
            }
            Text {
                objectName: "reportsHeaderSubtitle"
                Layout.fillWidth: true
                text: String(root.headerProjection.subtitle
                    || "Đọc kết quả, nhận diện cơ hội và chọn việc cần làm tiếp theo")
                color: Theme.textFaint
                font.pixelSize: Theme.fontMetadata
                elide: Text.ElideRight
            }
        }

        ReportComboBox {
            id: rangeFilter
            objectName: "reportRangeFilter"
            Layout.preferredWidth: 132
            popupWidth: 190
            textRole: "label"
            valueRole: "key"
            model: root.filterCatalog.ranges || []
            currentIndex: root.selectedIndex(model)
            enabled: count > 0 && root.canRead && !root.busy
            availabilityReason: enabled ? "" : "Server chưa cung cấp khoảng thời gian báo cáo"
            Accessible.name: "Khoảng thời gian báo cáo"
            onOptionSelected: function(index, option) {
                const input = option.action.input
                root.draftStartAt = input.start_at
                root.draftEndAt = input.end_at
                root.hasDraftRange = true
                root.draftRevision += 1
            }
        }

        ReportSwitch {
            id: compareToggle
            objectName: "reportCompareToggle"
            text: "So sánh"
            checked: Boolean(root.scope.compare)
            enabled: root.canRead && !root.busy
            activeFocusOnTab: true
            Accessible.name: "So sánh kỳ trước"
            Accessible.description: enabled ? "" : "Không thể đổi so sánh khi snapshot đang tải"
        }

        ReportComboBox {
            id: channelFilter
            objectName: "reportChannelFilter"
            Layout.preferredWidth: 150
            popupWidth: 260
            textRole: "label"
            valueRole: "key"
            model: root.filterCatalog.channels || []
            currentIndex: root.selectedIndex(model)
            enabled: count > 0 && root.canRead && !root.busy
            availabilityReason: enabled ? "" : "Server chưa cung cấp danh mục kênh"
            Accessible.name: "Lọc kênh"
            onOptionSelected: function(index, option) {
                const input = option.action.input
                root.draftChannelId = input.channel_id
                root.hasDraftChannel = true
                root.draftRevision += 1
            }
        }

        ReportComboBox {
            id: platformFilter
            objectName: "reportPlatformFilter"
            Layout.preferredWidth: 138
            popupWidth: 210
            textRole: "label"
            valueRole: "key"
            model: root.filterCatalog.platforms || []
            currentIndex: root.selectedIndex(model)
            enabled: count > 0 && root.canRead && !root.busy
            availabilityReason: enabled ? "" : "Server chưa cung cấp danh mục nền tảng"
            Accessible.name: "Lọc nền tảng"
            onOptionSelected: function(index, option) {
                const input = option.action.input
                root.draftPlatformValue = input.platform
                root.hasDraftPlatform = true
                root.draftRevision += 1
            }
        }

        Foundation.IconButton {
            id: advancedFilterButton
            objectName: "reportAdvancedFilter"
            visible: root.advancedAction.available === true
            iconName: String(root.advancedAction.icon_key || "")
            text: ""
            accessibleName: String(root.advancedAction.label || "Bộ lọc nâng cao")
            activeFocusOnTab: true
            enabled: visible && !root.busy
            Accessible.description: enabled ? "" : String(
                root.advancedAction.reason_code || "Bộ lọc nâng cao không khả dụng"
            )
            onClicked: advancedFilterPopup.openAtTrigger()
        }

        AppButton {
            objectName: "reportApplyFilters"
            Layout.preferredWidth: 104
            text: root.busy ? "Đang tải…" : String(root.applyAction.label || "Áp dụng")
            leadingIcon: String(root.applyAction.icon_key || "")
            primary: true
            enabled: root.canRead && root.applyAction.available === true && !root.busy
            availabilityReason: enabled ? "" : (root.busy
                ? "Snapshot báo cáo đang tải"
                : String(root.applyAction.reason_code || "REPORTS_READ_PERMISSION_REQUIRED"))
            onClicked: root.applyRequested(root.composeDraftQuery())
        }

        AppButton {
            objectName: "reportExportButton"
            Layout.preferredWidth: 150
            text: String(root.exportAction.label || "Xuất báo cáo")
            leadingIcon: String(root.exportAction.icon_key || "")
            enabled: root.canExport && !root.exportBusy
            availabilityReason: enabled ? "" : (root.exportBusy
                ? "Đang xử lý export job"
                : String(root.exportAction.reason_code || "REPORT_EXPORT_PERMISSION_REQUIRED"))
            onClicked: root.exportRequested()
        }
    }

    Popup {
        id: advancedFilterPopup
        objectName: "reportAdvancedFilterMenu"
        parent: Overlay.overlay
        function openAtTrigger() {
            const overlay = Overlay.overlay
            const position = advancedFilterButton.mapToItem(overlay, 0, 0)
            x = Math.max(12, Math.min(
                overlay.width - width - 12,
                position.x + advancedFilterButton.width - width
            ))
            const below = position.y + advancedFilterButton.height + 6
            y = below + height <= overlay.height - 12
                ? below : Math.max(12, position.y - height - 6)
            open()
        }
        width: 380
        height: 116
        padding: 10
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: ColumnLayout {
            spacing: 8
            Text {
                Layout.fillWidth: true
                text: "Chiến dịch"
                color: Theme.textMuted
                font.pixelSize: Theme.fontMetadata
                font.weight: Font.DemiBold
            }
            ReportComboBox {
                id: campaignFilter
                objectName: "reportCampaignFilter"
                Layout.fillWidth: true
                popupWidth: 400
                textRole: "label"
                valueRole: "key"
                model: root.filterCatalog.campaigns || []
                currentIndex: root.selectedIndex(model)
                enabled: count > 0 && root.canRead && !root.busy
                availabilityReason: enabled ? "" : "Server chưa cung cấp danh mục chiến dịch"
                Accessible.name: "Lọc chiến dịch"
                onOptionSelected: function(index, option) {
                    const input = option.action.input
                    root.draftCampaignId = input.campaign_id
                    root.hasDraftCampaign = true
                    root.draftRevision += 1
                }
            }
        }
        background: Rectangle {
            radius: Theme.radiusMedium
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }
}
