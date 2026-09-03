pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "reportPerformanceTable"
    clip: true
    property var projection: ({})
    property var filterCatalog: ({})
    property var controlPlaneBridge: null
    property string snapshotId: ""
    property var contentModel: null
    property string selectedContentId: ""
    property int initialLimit: 50
    property bool canExport: false
    property bool exportBusy: false
    readonly property int rowCount: root.contentModel ? root.contentModel.count : 0
    readonly property string searchText: searchField.text
    property var columnOverrides: ({})
    readonly property var searchAction: (root.projection.actions || {}).search || ({})
    readonly property var columnsAction: (root.projection.actions || {}).columns || ({})
    readonly property var pagination: root.projection.pagination || ({})
    readonly property bool conversionsColumnVisible:
        root.columnVisible("conversions")
    readonly property bool retentionColumnVisible:
        root.columnVisible("retention")
    readonly property bool ctrColumnVisible:
        root.columnVisible("ctr")
    readonly property var pageLimit: {
        const options = root.filterCatalog.page_sizes || []
        const index = pageSize.currentIndex
        if (index >= 0 && index < options.length)
            return ((((options[index] || {}).action || {}).input || {}).limit)
        return root.initialLimit
    }
    signal snapshotRequested(var action)
    signal exportRequested()
    signal contentRequested(string contentId, var link)
    Accessible.name: "Bảng hiệu suất nội dung"
    Accessible.role: Accessible.Table

    function metricText(metric) {
        const item = metric || ({})
        if (!item.available || item.value === null || item.value === undefined) return "—"
        const value = Number(item.value)
        let text = isFinite(value) ? String(Math.round(value * 100) / 100) : String(item.value)
        if (item.unit === "percent") text += "%"
        else if (item.unit && item.unit !== "count") text += " " + String(item.unit)
        return text
    }

    function displayTimestamp(value) {
        const parsed = new Date(String(value || ""))
        if (isNaN(parsed.getTime())) return "—"
        return Qt.formatDateTime(parsed, "dd/MM/yyyy HH:mm")
    }

    function selectedIndex(options) {
        const source = options || []
        for (let index = 0; index < source.length; index++)
            if (Boolean((source[index] || {}).selected)) return index
        return source.length > 0 ? 0 : -1
    }

    function mapOrEmpty(value) {
        return value === null || value === undefined || typeof value !== "object"
            ? ({}) : value
    }

    function syncSnapshotSelection() {
        pageSize.currentIndex = root.selectedIndex(root.filterCatalog.page_sizes)
    }

    onSnapshotIdChanged: Qt.callLater(root.syncSnapshotSelection)
    Component.onCompleted: Qt.callLater(root.syncSnapshotSelection)

    function columnDescriptor(key) {
        const columns = root.projection.columns || []
        for (let index = 0; index < columns.length; index++) {
            const column = columns[index] || ({})
            if (String(column.key || "") === key) return column
        }
        return ({})
    }

    function columnVisible(key) {
        if ((root.columnOverrides || ({}))[key] !== undefined)
            return Boolean(root.columnOverrides[key])
        return Boolean(root.columnDescriptor(key).selected)
    }

    function applyColumnAction(action) {
        const descriptor = action || ({})
        const input = descriptor.input || ({})
        const key = String(input.column_key || "")
        if (descriptor.available !== true
                || String(descriptor.kind || "") !== "presentation"
                || !key || input.visible === undefined) return false
        const next = Object.assign({}, root.columnOverrides || ({}))
        next[key] = !root.columnVisible(key)
        root.columnOverrides = next
        return true
    }

    function requestSearch() {
        if (root.searchAction.available !== true
                || String(root.searchAction.capability || "") !== "reports.snapshot")
            return false
        const action = Object.assign({}, root.searchAction)
        action.input = Object.assign({}, root.searchAction.input || ({}))
        action.input.search = String(searchField.text || "").trim() || null
        action.input.offset = 0
        root.snapshotRequested(action)
        return true
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 39
            Layout.leftMargin: 9
            Layout.rightMargin: 8
            spacing: 6
            Text { text: "Hiệu suất nội dung"; color: Theme.text; font.pixelSize: 12; font.weight: Font.Bold }
            Item { Layout.fillWidth: true }
            ReportTextField {
                id: searchField
                objectName: "reportSearchField"
                Layout.preferredWidth: 190
                text: ""
                placeholderText: "Tìm tiêu đề nội dung…"
                activeFocusOnTab: true
                Accessible.name: "Tìm nội dung trong báo cáo"
                enabled: root.searchAction.available === true
                availabilityReason: enabled ? "" : String(
                    root.searchAction.reason_code || "Tìm kiếm báo cáo không khả dụng"
                )
                onAccepted: root.requestSearch()
            }
            Foundation.IconButton {
                id: columnsButton
                objectName: "reportColumnsButton"
                iconName: String(root.columnsAction.icon_key || "")
                text: ""
                accessibleName: "Tùy chỉnh cột báo cáo"
                activeFocusOnTab: true
                enabled: root.columnsAction.available === true
                    && (root.columnsAction.options || []).length > 0
                Accessible.description: enabled ? "" : String(
                    root.columnsAction.reason_code || "Danh mục cột không khả dụng"
                )
                onClicked: columnsMenu.openAtTrigger()
            }
            AppButton {
                objectName: "reportTableExportButton"
                text: "Xuất bảng"
                leadingIcon: "semantic/upload-cloud"
                enabled: root.canExport && !root.exportBusy
                availabilityReason: enabled
                    ? "Mở export job cho report query hiện tại"
                    : "Thiếu quyền reports.export, server action bị khóa hoặc command đang chạy"
                onClicked: root.exportRequested()
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            color: Theme.base
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 9
                anchors.rightMargin: 9
                spacing: 6
                HeaderText { visible: root.columnVisible("content"); text: "NỘI DUNG"; Layout.fillWidth: visible }
                HeaderText { visible: root.columnVisible("platform"); text: "KÊNH / NỀN TẢNG"; Layout.preferredWidth: visible ? 130 : 0 }
                HeaderText { visible: root.columnVisible("published_at"); text: "ĐÃ XUẤT BẢN"; Layout.preferredWidth: visible ? 112 : 0 }
                HeaderText { visible: root.columnVisible("views"); text: "LƯỢT XEM"; Layout.preferredWidth: visible ? 72 : 0 }
                HeaderText { visible: root.columnVisible("retention"); text: "RETENTION"; Layout.preferredWidth: visible ? 72 : 0 }
                HeaderText { visible: root.columnVisible("engagement_rate"); text: "TƯƠNG TÁC"; Layout.preferredWidth: visible ? 75 : 0 }
                HeaderText { visible: root.columnVisible("ctr"); text: "CTR"; Layout.preferredWidth: visible ? 55 : 0 }
                HeaderText { visible: root.columnVisible("conversions"); text: "CHUYỂN ĐỔI"; Layout.preferredWidth: visible ? 72 : 0 }
                HeaderText { visible: root.columnVisible("estimated_revenue"); text: "DOANH THU"; Layout.preferredWidth: visible ? 90 : 0 }
                HeaderText { visible: root.columnVisible("status"); text: "TRẠNG THÁI"; Layout.preferredWidth: visible ? 75 : 0 }
            }
        }
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ColumnLayout {
                width: parent.width
                spacing: 0
                Repeater {
                    model: root.contentModel
                    delegate: Rectangle {
                        id: contentRow
                        required property string external_post_record_id
                        required property string content_id
                        required property var campaign_id
                        required property var campaign_label
                        required property string title
                        required property var thumbnail_uri
                        required property string channel_id
                        required property string channel_name
                        required property string platform
                        required property string published_at
                        required property string status
                        required property var status_label
                        required property var metrics
                        required property var deep_link
                        readonly property string contentId: contentRow.content_id
                        readonly property bool selected: root.selectedContentId === contentRow.contentId
                        readonly property string retentionText: root.metricText((contentRow.metrics || {}).retention)
                        readonly property string retentionReason: String(
                            ((contentRow.metrics || {}).retention || {}).reason || ""
                        )
                        readonly property string ctrText:
                            root.metricText((contentRow.metrics || {}).ctr)
                        readonly property string ctrReason: String(
                            ((contentRow.metrics || {}).ctr || {}).reason || ""
                        )
                        signal activate()
                        objectName: "reportContentRow_" + contentRow.contentId
                        Layout.fillWidth: true
                        Layout.preferredHeight: 27
                        color: contentRow.selected ? Theme.accentSoft : (rowMouse.containsMouse ? Theme.hover : "transparent")
                        border.width: contentRow.selected ? 1 : 0
                        border.color: Theme.accent
                        activeFocusOnTab: true
                        Accessible.name: "Nội dung " + String(contentRow.title || contentRow.contentId)
                            + ", " + String(contentRow.platform || "unknown")
                        Accessible.description: Boolean((contentRow.deep_link || {}).route)
                            ? "Mở trang nội dung theo deep link server" : "Không có deep link"
                        Accessible.role: Accessible.Row
                        onActivate: {
                            const link = contentRow.deep_link || ({})
                            if (contentRow.contentId && link.route)
                                root.contentRequested(contentRow.contentId, link)
                        }
                        Keys.onSpacePressed: contentRow.activate()
                        Keys.onReturnPressed: contentRow.activate()
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 9
                            spacing: 6
                            RowLayout {
                                visible: root.columnVisible("content")
                                Layout.fillWidth: true
                                spacing: 7
                                Rectangle {
                                    id: thumbnailFrame
                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24
                                    radius: 6
                                    color: Theme.elevated
                                    border.width: 1
                                    border.color: Theme.borderSoft
                                    readonly property string resolvedThumbnailUrl:
                                        root.controlPlaneBridge && contentRow.thumbnail_uri
                                            ? String(root.controlPlaneBridge.authorizedThumbnailUrl(
                                                String(contentRow.thumbnail_uri))) : ""
                                    Image {
                                        id: thumbnailImage
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        source: thumbnailFrame.resolvedThumbnailUrl
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        visible: source.toString().length > 0
                                            && status !== Image.Error
                                    }
                                    UiIcon {
                                        anchors.centerIn: parent
                                        visible: !thumbnailImage.visible
                                            || thumbnailImage.status === Image.Error
                                        name: "ui/play"
                                        tone: Theme.textFaint
                                        iconSize: 14
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text { Layout.fillWidth: true; text: String(contentRow.title || "Không có tiêu đề"); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                    Text { Layout.fillWidth: true; text: String(contentRow.campaign_label || "Không thuộc chiến dịch"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                }
                            }
                            RowLayout {
                                visible: root.columnVisible("platform")
                                Layout.preferredWidth: visible ? 130 : 0
                                spacing: 5
                                SocialIcon { platform: String(contentRow.platform || ""); Layout.preferredWidth: 18; Layout.preferredHeight: 18 }
                                Text { Layout.fillWidth: true; text: String(contentRow.channel_name || contentRow.channel_id || "—"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                            }
                            CellText { visible: root.columnVisible("published_at"); value: root.displayTimestamp(contentRow.published_at); widthHint: visible ? 112 : 0 }
                            CellText { visible: root.columnVisible("views"); value: root.metricText((contentRow.metrics || {}).views); widthHint: visible ? 72 : 0 }
                            CellText {
                                objectName: "reportRetentionCell_" + contentRow.contentId
                                visible: root.columnVisible("retention")
                                value: contentRow.retentionText
                                widthHint: visible ? 72 : 0
                                warning: value === "—"
                                availabilityReason: contentRow.retentionReason
                                Accessible.name: "Retention " + String(contentRow.title || contentRow.contentId)
                                Accessible.description: availabilityReason
                            }
                            CellText { visible: root.columnVisible("engagement_rate"); value: root.metricText((contentRow.metrics || {}).engagement_rate); widthHint: visible ? 75 : 0 }
                            CellText {
                                objectName: "reportCtrCell_" + contentRow.contentId
                                visible: root.columnVisible("ctr")
                                value: contentRow.ctrText
                                widthHint: visible ? 55 : 0
                                warning: value === "—"
                                availabilityReason: contentRow.ctrReason
                                Accessible.name: "CTR " + String(contentRow.title || contentRow.contentId)
                                Accessible.description: availabilityReason
                            }
                            CellText { visible: root.columnVisible("conversions"); value: root.metricText((contentRow.metrics || {}).conversions); widthHint: visible ? 72 : 0 }
                            CellText { visible: root.columnVisible("estimated_revenue"); value: root.metricText((contentRow.metrics || {}).estimated_revenue); widthHint: visible ? 90 : 0 }
                            Foundation.StatusPill { visible: root.columnVisible("status"); Layout.preferredWidth: visible ? 86 : 0; text: String(contentRow.status_label || (contentRow.status === "verified" ? "Đã xác minh" : "Cần kiểm tra")); tone: String(contentRow.status || "") === "verified" ? Theme.success : Theme.warning }
                        }
                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Boolean((contentRow.deep_link || {}).route) ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: Boolean((contentRow.deep_link || {}).route)
                            onClicked: contentRow.activate()
                        }
                    }
                }
                Text {
                    visible: root.rowCount === 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    text: "Không có nội dung trong report projection"
                    color: Theme.textFaint
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
        RowLayout {
            Layout.fillWidth: true
            Layout.minimumHeight: 38
            Layout.preferredHeight: 38
            Layout.bottomMargin: 1
            Layout.leftMargin: 9
            Layout.rightMargin: 8
            Text { Layout.fillWidth: true; text: "Hiển thị " + String(root.rowCount) + " / " + String(root.projection.total ?? "—") + " nội dung"; color: Theme.textFaint; font.pixelSize: 11 }
            Foundation.IconButton {
                objectName: "reportPreviousPage"
                iconName: "ui/chevron-left"
                text: ""
                accessibleName: "Trang báo cáo trước"
                activeFocusOnTab: true
                readonly property var projectedAction: root.pagination.previous || ({})
                enabled: projectedAction.available === true
                    && String(projectedAction.capability || "") === "reports.snapshot"
                Accessible.description: enabled ? "" : String(
                    projectedAction.reason_code || "REPORT_PAGE_START_REACHED"
                )
                onClicked: root.snapshotRequested(projectedAction)
            }
            Foundation.IconButton {
                objectName: "reportNextPage"
                iconName: "ui/chevron-right"
                text: ""
                accessibleName: "Trang báo cáo tiếp theo"
                activeFocusOnTab: true
                readonly property var projectedAction: root.pagination.next || ({})
                enabled: projectedAction.available === true
                    && String(projectedAction.capability || "") === "reports.snapshot"
                Accessible.description: enabled ? "" : String(
                    projectedAction.reason_code || "REPORT_PAGE_END_REACHED"
                )
                onClicked: root.snapshotRequested(projectedAction)
            }
            ReportComboBox {
                id: pageSize
                objectName: "reportPageSize"
                Layout.preferredWidth: 96
                model: root.filterCatalog.page_sizes || []
                textRole: "label"
                valueRole: "key"
                currentIndex: root.selectedIndex(model)
                enabled: count > 0
                availabilityReason: enabled ? "" : "Server chưa cung cấp kích thước trang"
                Accessible.name: "Giới hạn số nội dung"
                onOptionSelected: function(index, option) {
                    root.snapshotRequested(option.action)
                }
            }
        }
    }

    Popup {
        id: columnsMenu
        objectName: "reportColumnsMenu"
        parent: Overlay.overlay
        function openAtTrigger() {
            const overlay = Overlay.overlay
            const position = columnsButton.mapToItem(overlay, 0, 0)
            x = Math.max(12, Math.min(
                overlay.width - width - 12,
                position.x + columnsButton.width - width
            ))
            const below = position.y + columnsButton.height + 6
            y = below + height <= overlay.height - 12
                ? below : Math.max(12, position.y - height - 6)
            open()
        }
        width: 245
        height: Math.min(340, 10 + (root.columnsAction.options || []).length * 34)
        padding: 5
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: ListView {
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.columnsAction.options || []
            delegate: AppButton {
                id: columnOption
                required property int index
                required property var modelData
                readonly property var projectedAction:
                    columnOption.modelData.action || ({})
                objectName: "reportColumn_" + String(
                    columnOption.modelData.key || columnOption.index)
                width: ListView.view.width
                height: 34
                text: (root.columnVisible(String(columnOption.modelData.key || ""))
                    ? "✓  " : "") + String(columnOption.modelData.label || "Cột")
                subtle: true
                enabled: projectedAction.available === true
                    && String(projectedAction.kind || "") === "presentation"
                availabilityReason: enabled ? "" : String(
                    projectedAction.reason_code || columnOption.modelData.reason_code
                        || "Cột không khả dụng"
                )
                onClicked: {
                    root.applyColumnAction(projectedAction)
                    columnsMenu.close()
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

    component HeaderText: Text {
        color: Theme.textFaint
        font.pixelSize: 11
        font.weight: Font.Bold
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    component CellText: Text {
        required property string value
        required property int widthHint
        property bool warning: false
        property string availabilityReason: ""
        Layout.preferredWidth: widthHint
        text: value
        color: warning ? Theme.warning : Theme.textMuted
        font.pixelSize: 11
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignRight
    }
}
