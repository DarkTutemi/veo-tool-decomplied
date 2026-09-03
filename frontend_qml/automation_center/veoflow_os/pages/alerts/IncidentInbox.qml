pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "incidentInbox"
    clip: true
    property var inbox: ({})
    property var incidentModel: null
    property var filters: ({})
    property var page: ({})
    property string selectedIncidentId: ""
    property var selectedIncidentIds: []
    property bool canWrite: false
    property bool canResolve: false
    property bool bulkBusy: false
    property int pageLimit: Number((filters || {}).limit || 25)
    readonly property var filterCatalog: (root.filters || {}).catalog || ({})
    readonly property var pagination: (root.inbox || {}).pagination || ({})
    readonly property var bulkActions: (root.inbox || {}).bulk_actions || ({})
    readonly property int incidentCount: root.incidentModel ? root.incidentModel.count : 0
    readonly property int selectedCount: selectedIncidentIds.length
    readonly property int currentOffset: Number((inbox || {}).offset || 0)
    readonly property int currentPage: Math.floor(currentOffset / Math.max(1, pageLimit)) + 1
    signal incidentSelected(string incidentId)
    signal incidentChecked(string incidentId, bool checked)
    signal selectVisibleRequested(bool checked)
    signal clearSelectionRequested()
    signal snapshotRequested(var query)
    signal bulkRequested(string operation)
    Accessible.name: "Hộp thư sự cố"
    Accessible.role: Accessible.Pane

    function isSelected(incidentId) {
        return root.selectedIncidentIds.indexOf(String(incidentId || "")) >= 0
    }

    function incidentAt(index) {
        if (!root.incidentModel || index < 0 || index >= root.incidentModel.count)
            return ({})
        return root.incidentModel.get(index) || ({})
    }

    function sectionKey(incidentId) {
        const sections = (root.inbox || {}).sections || ({})
        if ((sections.now || []).indexOf(incidentId) >= 0) return "now"
        if ((sections.earlier_today || []).indexOf(incidentId) >= 0) return "earlier_today"
        return "older"
    }

    function sectionLabel(section) {
        if (section === "now") return "Bây giờ"
        if (section === "earlier_today") return "Sớm hơn hôm nay"
        return "Cũ hơn"
    }

    function strictQuery(offsetValue, projectedInput) {
        const query = {
            "limit": Math.max(1, root.pageLimit) | 0,
            "offset": Math.max(0, Number(
                offsetValue === undefined ? 0 : offsetValue
            )) | 0,
            "timezone": String((root.filters || {}).timezone || "Asia/Bangkok")
        }
        if (root.filters.status) query.status = String(root.filters.status)
        if (root.filters.severity) query.severity = String(root.filters.severity)
        if (root.filters.source) query.source = String(root.filters.source)
        if (root.filters.owner_id) query.owner_id = String(root.filters.owner_id)
        if (root.filters.time_window)
            query.time_window = String(root.filters.time_window)
        const search = searchFilter.text.trim()
        if (search) query.search = search
        if (root.filters.sort && String(root.filters.sort) !== "last_seen_desc")
            query.sort = String(root.filters.sort)
        const input = projectedInput || ({})
        const keys = Object.keys(input)
        for (let index = 0; index < keys.length; index++) {
            const key = keys[index]
            const value = input[key]
            if (value === null || value === undefined || value === "")
                delete query[key]
            else
                query[key] = value
        }
        if (root.selectedIncidentId)
            query.selected_incident_id = root.selectedIncidentId
        return query
    }

    function applyFilters(offsetValue) {
        root.snapshotRequested(root.strictQuery(offsetValue))
        return true
    }

    function applySnapshotAction(action) {
        const descriptor = action || ({})
        if (!descriptor.available || descriptor.kind !== "snapshot"
                || descriptor.capability !== "alerts.snapshot") return false
        root.snapshotRequested(root.strictQuery(0, descriptor.input || ({})))
        return true
    }

    function selectedIndex(items) {
        const rows = items || []
        for (let index = 0; index < rows.length; index++)
            if (Boolean((rows[index] || {}).selected)) return index
        return rows.length > 0 ? 0 : -1
    }

    function requestPreviousPage() {
        return root.applySnapshotAction(root.pagination.previous || ({}))
    }

    function requestNextPage() {
        return root.applySnapshotAction(root.pagination.next || ({}))
    }

    function severityTone(value) {
        const severity = String(value || "info").toLowerCase()
        if (severity === "critical" || severity === "error") return Theme.danger
        if (severity === "warning") return Theme.warning
        return Theme.info
    }

    function statusTone(value) {
        return String(value || "") === "resolved" ? Theme.success : Theme.warning
    }

    function descriptorTone(value, fallback) {
        const key = String(value || "")
        if (key === "danger") return Theme.danger
        if (key === "warning") return Theme.warning
        if (key === "success") return Theme.success
        if (key === "info") return Theme.info
        if (key === "accent") return Theme.accent
        return fallback || Theme.textFaint
    }

    function shortTime(value) {
        const date = new Date(String(value || ""))
        if (isNaN(date.getTime())) return "—"
        return Qt.formatDateTime(date, "HH:mm:ss")
    }

    function operationAvailable(operation) {
        const rows = root.bulkActions.operations || []
        for (let index = 0; index < rows.length; index++) {
            const row = rows[index] || ({})
            if (String(row.key || "") === String(operation || ""))
                return Boolean(row.available)
        }
        return false
    }

    function bulkOperation(operation) {
        const rows = root.bulkActions.operations || []
        for (let index = 0; index < rows.length; index++)
            if (String((rows[index] || {}).key || "") === String(operation || ""))
                return rows[index]
        return ({})
    }

    function slaLabel(sla) {
        const item = sla || ({})
        if (item.remaining_seconds === undefined || item.remaining_seconds === null)
            return "SLA —"
        const seconds = Number(item.remaining_seconds)
        const absolute = Math.abs(seconds)
        const minutes = Math.floor(absolute / 60)
        const label = String(Math.floor(minutes / 60)).padStart(2, "0") + ":"
            + String(minutes % 60).padStart(2, "0")
        return seconds < 0 ? "-" + label : label
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            objectName: "alertPrimaryFilters"
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            spacing: 6
            AlertsTextField {
                id: searchFilter
                objectName: "alertSearchField"
                Layout.fillWidth: true
                Layout.minimumWidth: 300
                placeholderText: "Tìm kiếm cảnh báo…"
                text: String((root.filters || {}).search || "")
                activeFocusOnTab: true
                Accessible.name: "Tìm kiếm sự cố"
                Accessible.description: "Tìm theo tiêu đề, tóm tắt, code hoặc entity ID"
                onAccepted: root.applyFilters(0)
            }
            AlertsComboBox {
                id: timeFilter
                objectName: "alertTimeFilter"
                Layout.preferredWidth: 160
                activeFocusOnTab: true
                Accessible.name: "Lọc thời gian sự cố"
                textRole: "label"
                valueRole: "key"
                model: root.filterCatalog.time_windows || []
                currentIndex: root.selectedIndex(model)
                enabled: count > 0
                availabilityReason: enabled ? "" : "Không có catalog thời gian từ server"
                onActivated: root.applySnapshotAction((model[currentIndex] || {}).action)
            }
            AlertsComboBox {
                id: severityFilter
                objectName: "alertSeverityFilter"
                Layout.preferredWidth: 160
                activeFocusOnTab: true
                Accessible.name: "Lọc mức độ sự cố"
                textRole: "label"
                valueRole: "key"
                model: root.filterCatalog.severities || []
                currentIndex: root.selectedIndex(model)
                enabled: count > 0
                availabilityReason: enabled ? "" : "Không có catalog mức độ từ server"
                onActivated: root.applySnapshotAction((model[currentIndex] || {}).action)
            }
            AlertsComboBox {
                id: sourceFilter
                objectName: "alertSourceFilter"
                Layout.preferredWidth: 180
                textRole: "label"
                valueRole: "key"
                model: root.filterCatalog.sources || []
                currentIndex: root.selectedIndex(model)
                enabled: count > 0
                availabilityReason: enabled ? "" : "Không có catalog nguồn từ server"
                activeFocusOnTab: true
                Accessible.name: "Lọc nguồn sự cố"
                onActivated: root.applySnapshotAction((model[currentIndex] || {}).action)
            }
        }

        RowLayout {
            objectName: "alertSecondaryFilters"
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            spacing: 6
            Text {
                text: "PHẠM VI XỬ LÝ"
                color: Theme.textFaint
                font.pixelSize: Theme.fontMetadata
                font.weight: Font.Bold
                Layout.preferredWidth: 112
            }
            AlertsComboBox {
                id: statusFilter
                objectName: "alertStatusFilter"
                Layout.preferredWidth: 170
                activeFocusOnTab: true
                Accessible.name: "Lọc trạng thái sự cố"
                textRole: "label"
                valueRole: "key"
                model: root.filterCatalog.statuses || []
                currentIndex: root.selectedIndex(model)
                enabled: count > 0
                availabilityReason: enabled ? "" : "Không có catalog trạng thái từ server"
                onActivated: root.applySnapshotAction((model[currentIndex] || {}).action)
            }
            AlertsComboBox {
                id: ownerFilter
                objectName: "alertOwnerFilter"
                Layout.fillWidth: true
                Layout.minimumWidth: 250
                Layout.maximumWidth: 360
                popupWidth: 330
                textRole: "label"
                valueRole: "key"
                model: root.filterCatalog.owners || []
                currentIndex: root.selectedIndex(model)
                enabled: count > 0
                availabilityReason: enabled ? "" : "Không có catalog người xử lý từ server"
                activeFocusOnTab: true
                Accessible.name: "Lọc người xử lý"
                onActivated: root.applySnapshotAction((model[currentIndex] || {}).action)
            }
            Foundation.IconButton {
                objectName: "alertAdvancedFilter"
                iconName: "ui/filter"
                text: ""
                accessibleName: "Bộ lọc nâng cao"
                activeFocusOnTab: true
                readonly property var descriptor: root.filterCatalog.advanced || ({})
                visible: Boolean(descriptor.available)
                enabled: visible
                Accessible.description: visible ? "Mở bộ lọc nâng cao" : String(
                    descriptor.reason_code || "INCIDENT_ADVANCED_FILTER_UNAVAILABLE"
                )
            }
            AlertsComboBox {
                id: sortFilter
                objectName: "alertSortFilter"
                Layout.preferredWidth: 190
                activeFocusOnTab: true
                Accessible.name: "Sắp xếp sự cố"
                textRole: "label"
                valueRole: "key"
                model: root.filterCatalog.sorts || []
                currentIndex: root.selectedIndex(model)
                enabled: count > 0
                availabilityReason: enabled ? "" : "Không có catalog sắp xếp từ server"
                onActivated: root.applySnapshotAction((model[currentIndex] || {}).action)
            }
            Text {
                Layout.fillWidth: true
                text: root.incidentCount > 0
                    ? String(root.incidentCount) + " sự cố trong trang"
                    : "Không có sự cố phù hợp"
                color: Theme.textFaint
                font.pixelSize: Theme.fontMetadata
                horizontalAlignment: Text.AlignRight
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        RowLayout {
            visible: root.selectedCount > 0
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 44 : 0
            Layout.leftMargin: 10
            Layout.rightMargin: 8
            spacing: 6
            Text { text: "Đã chọn " + String(root.selectedCount); color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
            AppButton {
                objectName: "incidentClearSelection"
                text: "Bỏ chọn"
                subtle: true
                activeFocusOnTab: true
                Accessible.name: text
                onClicked: root.clearSelectionRequested()
            }
            BulkButton {
                objectName: "incidentBulkClaim"
                operation: "claim"
                descriptor: root.bulkOperation(operation)
            }
            BulkButton {
                objectName: "incidentBulkResolve"
                operation: "resolve"
                descriptor: root.bulkOperation(operation)
            }
            BulkButton {
                objectName: "incidentBulkSeverity"
                operation: "change_severity"
                descriptor: root.bulkOperation(operation)
            }
            Item { Layout.fillWidth: true }
            Foundation.IconButton {
                objectName: "incidentBulkOverflow"
                iconName: "ui/more-horizontal"
                text: ""
                accessibleName: "Thêm thao tác hàng loạt"
                activeFocusOnTab: true
                readonly property var descriptor: root.bulkActions.overflow || ({})
                visible: Boolean(descriptor.available)
                enabled: visible && !root.bulkBusy
                Accessible.description: enabled ? "Mở thao tác hàng loạt bổ sung"
                    : String(descriptor.reason_code || "INCIDENT_BULK_OVERFLOW_UNAVAILABLE")
            }
        }
        Rectangle { visible: root.selectedCount > 0; Layout.fillWidth: true; Layout.preferredHeight: visible ? 1 : 0; color: Theme.borderSoft }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: Theme.base
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 7
                AlertsCheckDelegate {
                    objectName: "incidentSelectAll"
                    Layout.preferredWidth: 28
                    tristate: true
                    checkState: root.selectedCount === 0 ? Qt.Unchecked
                        : root.selectedCount >= root.incidentCount ? Qt.Checked
                        : Qt.PartiallyChecked
                    activeFocusOnTab: true
                    Accessible.name: "Chọn tất cả sự cố trong trang"
                    onClicked: root.selectVisibleRequested(root.selectedCount < root.incidentCount)
                }
                HeaderLabel { text: "MỨC"; Layout.preferredWidth: 32 }
                HeaderLabel { text: "SỰ CỐ"; Layout.fillWidth: true }
                HeaderLabel { text: "NGUỒN"; Layout.preferredWidth: 118 }
                HeaderLabel { text: "ĐỐI TƯỢNG"; Layout.preferredWidth: 142 }
                HeaderLabel { text: "THỜI GIAN"; Layout.preferredWidth: 118 }
                HeaderLabel { text: "LẦN"; Layout.preferredWidth: 42 }
                HeaderLabel { text: "OWNER"; Layout.preferredWidth: 88 }
                HeaderLabel { text: "TRẠNG THÁI"; Layout.preferredWidth: 82 }
                HeaderLabel { text: "SLA"; Layout.preferredWidth: 68 }
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
                    model: root.incidentModel
                    delegate: ColumnLayout {
                        id: incidentDelegate
                        required property int index
                        required property string incident_id
                        required property string status
                        required property string severity
                        required property string source
                        required property string code
                        required property string title
                        required property string summary
                        required property var entity
                        required property string first_seen_at
                        required property string last_seen_at
                        required property int occurrence_count
                        required property var owner_id
                        required property var sla
                        required property var severity_descriptor
                        required property var status_descriptor
                        required property var source_descriptor
                        required property var owner_display
                        required property var entity_display
                        required property var sla_descriptor
                        required property var operator_guidance
                        readonly property string incidentId: incidentDelegate.incident_id
                        readonly property string section: root.sectionKey(incidentId)
                        Layout.fillWidth: true
                        spacing: 0
                        Text {
                            visible: incidentDelegate.index === 0
                                || incidentDelegate.section !== root.sectionKey(
                                    String((root.incidentAt(incidentDelegate.index - 1) || {}).incident_id || ""))
                            Layout.fillWidth: true
                            Layout.preferredHeight: visible ? 28 : 0
                            Layout.leftMargin: 10
                            text: root.sectionLabel(incidentDelegate.section)
                            color: Theme.textMuted
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            verticalAlignment: Text.AlignVCenter
                        }
                        Rectangle {
                            id: incidentRow
                            signal activate()
                            objectName: "incidentRow_" + incidentDelegate.incidentId
                            readonly property string sourceDisplay:
                                String((incidentDelegate.source_descriptor || {}).label
                                    || incidentDelegate.source || "—")
                            readonly property string firstSeenDisplay:
                                root.shortTime(incidentDelegate.first_seen_at)
                            Layout.fillWidth: true
                            // The native 1080p viewport fits the six-row operational
                            // batch exactly. Keep three readable text lines without
                            // exposing a misleading partially clickable seventh edge.
                            Layout.preferredHeight: 74
                            color: root.selectedIncidentId === incidentDelegate.incidentId
                                ? Theme.accentSoft : (rowMouse.containsMouse ? Theme.hover : "transparent")
                            border.width: root.selectedIncidentId === incidentDelegate.incidentId ? 1 : 0
                            border.color: Theme.accent
                            Accessible.name: "Sự cố " + String(incidentDelegate.title || incidentDelegate.incidentId)
                            Accessible.role: Accessible.Row
                            activeFocusOnTab: true
                            Accessible.focusable: true
                            Keys.onReturnPressed: incidentRow.activate()
                            Keys.onEnterPressed: incidentRow.activate()
                            Keys.onSpacePressed: incidentRow.activate()
                            onActivate: root.incidentSelected(incidentDelegate.incidentId)
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 7
                                AlertsCheckDelegate {
                                    objectName: "incidentRowCheck_" + incidentDelegate.incidentId
                                    Layout.preferredWidth: 28
                                    checked: root.isSelected(incidentDelegate.incidentId)
                                    activeFocusOnTab: true
                                    Accessible.name: "Chọn " + String(incidentDelegate.title || incidentDelegate.incidentId)
                                    onClicked: root.incidentChecked(incidentDelegate.incidentId, checked)
                                }
                                Rectangle {
                                    Layout.preferredWidth: 26; Layout.preferredHeight: 26; radius: 13
                                    readonly property color severityColor: root.descriptorTone(
                                        (incidentDelegate.severity_descriptor || {}).tone_key,
                                        root.severityTone(incidentDelegate.severity)
                                    )
                                    color: Qt.rgba(severityColor.r, severityColor.g, severityColor.b, 0.15)
                                    UiIcon {
                                        anchors.centerIn: parent
                                        name: String((incidentDelegate.severity_descriptor || {}).icon_key || "")
                                        tone: parent.severityColor
                                        iconSize: 15
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text { Layout.fillWidth: true; text: String(incidentDelegate.title || incidentDelegate.incidentId); color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                    Text {
                                        objectName: "incidentRowImpact_" + incidentDelegate.incidentId
                                        Layout.fillWidth: true
                                        text: String((incidentDelegate.operator_guidance || {}).impact
                                            || incidentDelegate.summary || "Chưa xác định ảnh hưởng")
                                        color: Theme.textMuted
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        objectName: "incidentRowNextStep_" + incidentDelegate.incidentId
                                        Layout.fillWidth: true
                                        text: String((incidentDelegate.operator_guidance || {}).next_step
                                            || "Mở chi tiết để đối soát bằng chứng")
                                        color: root.descriptorTone(
                                            (incidentDelegate.operator_guidance || {}).tone_key,
                                            Theme.textFaint)
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                }
                                Text { Layout.preferredWidth: 118; text: incidentRow.sourceDisplay; color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                                ColumnLayout {
                                    Layout.preferredWidth: 142; spacing: 1
                                    Text { Layout.fillWidth: true; text: String((incidentDelegate.entity_display || {}).label || "Không khả dụng"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                                    Text { Layout.fillWidth: true; text: String(((incidentDelegate.entity_display || {}).ref || {}).id || "—"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideMiddle }
                                }
                                ColumnLayout {
                                    Layout.preferredWidth: 118; spacing: 1
                                    Foundation.RelativeTimeText { timestamp: String(incidentDelegate.last_seen_at || "") }
                                    Text { text: "Đầu " + incidentRow.firstSeenDisplay; color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                                }
                                Text { Layout.preferredWidth: 42; text: String(incidentDelegate.occurrence_count); color: Theme.textMuted; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter }
                                Text { Layout.preferredWidth: 88; text: String((incidentDelegate.owner_display || {}).label || "Chưa nhận"); color: (incidentDelegate.owner_display || {}).available ? Theme.textMuted : Theme.warning; font.pixelSize: 11; elide: Text.ElideRight }
                                Foundation.StatusPill { Layout.preferredWidth: 82; text: String((incidentDelegate.status_descriptor || {}).label || "Không rõ"); tone: root.descriptorTone((incidentDelegate.status_descriptor || {}).tone_key, root.statusTone(incidentDelegate.status)) }
                                Text { Layout.preferredWidth: 68; text: root.slaLabel(incidentDelegate.sla); color: (incidentDelegate.sla || {}).breached ? Theme.danger : Theme.warning; font.pixelSize: 11; font.weight: Font.Bold; horizontalAlignment: Text.AlignRight }
                            }
                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                anchors.leftMargin: 44
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: incidentRow.activate()
                            }
                        }
                    }
                }
                Text {
                    visible: root.incidentCount === 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 86
                    text: "Không có incident phù hợp với bộ lọc"
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
            Layout.leftMargin: 10
            Layout.rightMargin: 8
            spacing: 6
            Text {
                Layout.fillWidth: true
                text: "Hiển thị " + String(root.incidentCount) + " / "
                    + String((root.page || {}).total ?? (root.inbox || {}).total ?? "—")
                color: Theme.textFaint
                font.pixelSize: 11
            }
            Foundation.IconButton {
                objectName: "incidentPreviousPage"
                iconName: "ui/chevron-left"
                text: ""
                accessibleName: "Trang sự cố trước"
                activeFocusOnTab: true
                readonly property var descriptor: root.pagination.previous || ({})
                enabled: Boolean(descriptor.available)
                Accessible.description: enabled ? "" : String(
                    descriptor.reason_code || "INCIDENT_PAGE_AT_START"
                )
                onClicked: root.requestPreviousPage()
            }
            Rectangle {
                Layout.preferredWidth: 34; Layout.preferredHeight: 30; radius: Theme.radiusSmall
                color: Theme.accentSoft; border.width: 1; border.color: Theme.accent
                Accessible.name: "Trang " + String(root.currentPage)
                Accessible.role: Accessible.StaticText
                Text { anchors.centerIn: parent; text: String(root.currentPage); color: Theme.accent; font.pixelSize: 11; font.weight: Font.Bold }
            }
            Foundation.IconButton {
                objectName: "incidentNextPage"
                iconName: "ui/chevron-right"
                text: ""
                accessibleName: "Trang sự cố tiếp theo"
                activeFocusOnTab: true
                readonly property var descriptor: root.pagination.next || ({})
                enabled: Boolean(descriptor.available)
                Accessible.description: enabled ? "" : String(
                    descriptor.reason_code || "INCIDENT_PAGE_AT_END"
                )
                onClicked: root.requestNextPage()
            }
            AlertsComboBox {
                objectName: "incidentPageSize"
                Layout.preferredWidth: 88
                activeFocusOnTab: true
                Accessible.name: "Số sự cố mỗi trang"
                textRole: "label"
                valueRole: "key"
                model: root.pagination.page_sizes || root.filterCatalog.page_sizes || []
                currentIndex: root.selectedIndex(model)
                enabled: count > 0
                availabilityReason: enabled ? "" : "Không có page-size catalog từ server"
                onActivated: root.applySnapshotAction((model[currentIndex] || {}).action)
            }
        }
    }

    component HeaderLabel: Text {
        color: Theme.textFaint
        font.pixelSize: 11
        font.weight: Font.Bold
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    component BulkButton: AppButton {
        id: bulk
        required property string operation
        required property var descriptor
        readonly property var descriptorAction: (bulk.descriptor || {}).action || ({})
        readonly property bool permissionAllowed: bulk.operation === "resolve"
            ? root.canResolve : root.canWrite
        text: String((bulk.descriptor || {}).label || bulk.operation)
        leadingIcon: String((bulk.descriptor || {}).icon_key || "")
        enabled: root.selectedCount > 0 && bulk.permissionAllowed
            && Boolean(bulk.descriptorAction.available)
            && !root.bulkBusy
        activeFocusOnTab: true
        Accessible.name: text
        Accessible.description: enabled
            ? "Tạo server preview cho " + text
            : (!bulk.permissionAllowed ? "Workspace permission không cho phép bulk action"
                : root.bulkBusy ? "Đang xử lý bulk action"
                : String(bulk.descriptorAction.reason_code
                    || (bulk.descriptor || {}).reason_code
                    || "INCIDENT_BULK_UNAVAILABLE"))
        onClicked: root.bulkRequested(bulk.operation)
    }
}
