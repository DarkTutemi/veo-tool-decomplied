pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation
import "../../components/device" as Device

Panel {
    id: root
    objectName: "deviceInventory"
    property var deviceModel: null
    property int snapshotRevision: 0
    property var filter: ({})
    property var page: ({})
    property string selectedDeviceId: ""
    signal deviceSelected(string deviceId)
    signal snapshotRequested(var query)
    Accessible.name: "Danh sách thiết bị Phone Farm"
    Accessible.role: Accessible.List

    readonly property int limit: {
        const value = Number((root.filter || {}).limit)
        return Number.isInteger(value) && value >= 1 && value <= 100 ? value : 25
    }
    readonly property var regionOptions: root.buildRegionOptions()
    readonly property int cursorOffset: {
        const value = String((root.page || {}).cursor || "")
        return value.length > 0 && /^\d+$/.test(value) ? Number(value) : 0
    }
    readonly property int pageNumber: Math.floor(cursorOffset / limit) + 1

    function statusProvenance(statuses, fallback) {
        const source = String(((statuses || {}).provenance || {}).source || fallback || "")
            .toLowerCase()
        const simulated = Boolean(((statuses || {}).provenance || {}).simulated)
        return simulated || ["demo_seed", "demo_only", "simulated"].indexOf(source) >= 0
            ? "demo_seed" : "production"
    }

    function powerStatus(value) {
        const state = String(value || "unknown").toLowerCase()
        if (state === "normal") return "healthy"
        if (state === "low") return "attention"
        return state
    }

    function buildRegionOptions() {
        const revision = root.snapshotRevision
        const seen = ({})
        const result = [{"label": "Khu vực: Tất cả", "value": ""}]
        if (!root.deviceModel)
            return result
        for (let index = 0; index < root.deviceModel.count; index++) {
            const region = String((root.deviceModel.get(index) || {}).proxyRegion || "").toUpperCase()
            if (region && !seen[region]) {
                result.push({"label": region, "value": region})
                seen[region] = true
            }
        }
        return result
    }

    function buildQuery(cursorValue) {
        const query = {"limit": root.limit}
        const search = searchField.text.trim()
        const status = String(statusFilter.currentValue || "")
        const region = String(regionFilter.currentValue || "")
        const cursor = String(cursorValue === undefined || cursorValue === null ? "" : cursorValue)
        if (cursor.length > 0 && cursor !== "0") query.cursor = cursor
        if (search.length > 0) query.search = search
        if (status.length > 0) query.status = status
        if (region.length > 0) query.region = region
        if (root.selectedDeviceId.length > 0) query.selected_device_id = root.selectedDeviceId
        return query
    }

    function applyFilters() {
        root.snapshotRequested(root.buildQuery(""))
        return true
    }

    function requestPreviousPage() {
        if (root.cursorOffset <= 0) return false
        root.snapshotRequested(root.buildQuery(String(Math.max(0, root.cursorOffset - root.limit))))
        return true
    }

    function requestNextPage() {
        const next = String((root.page || {}).next_cursor || "")
        if (!next) return false
        root.snapshotRequested(root.buildQuery(next))
        return true
    }

    function syncFilterControls() {
        searchField.text = String((root.filter || {}).search || "")
        const status = String((root.filter || {}).status || "")
        for (let index = 0; index < statusFilter.model.length; index++) {
            if (String(statusFilter.model[index].value) === status) {
                statusFilter.currentIndex = index
                break
            }
        }
        const region = String((root.filter || {}).region || "")
        for (let regionIndex = 0; regionIndex < root.regionOptions.length; regionIndex++) {
            if (String(root.regionOptions[regionIndex].value) === region) {
                regionFilter.currentIndex = regionIndex
                break
            }
        }
    }

    onFilterChanged: syncFilterControls()
    Component.onCompleted: syncFilterControls()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: 10
            spacing: 7
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                TextField {
                    id: searchField
                    objectName: "deviceSearchField"
                    Layout.fillWidth: true
                    implicitHeight: 36
                    placeholderText: "Tìm thiết bị hoặc model…"
                    activeFocusOnTab: true
                    Accessible.name: "Tìm thiết bị hoặc model"
                    Keys.onReturnPressed: root.applyFilters()
                    onEditingFinished: root.applyFilters()
                    color: Theme.text
                    placeholderTextColor: Theme.textFaint
                    background: Rectangle { radius: Theme.radiusSmall; color: Theme.elevated; border.width: 1; border.color: searchField.activeFocus ? Theme.accent : Theme.borderSoft }
                }
                Foundation.IconButton {
                    objectName: "deviceAdvancedFilterButton"
                    text: ""
                    iconName: "ui/filter"
                    accessibleName: "Bộ lọc nâng cao"
                    activeFocusOnTab: true
                    onClicked: advancedHint.visible = !advancedHint.visible
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                PhoneFarmFilterComboBox {
                    id: statusFilter
                    objectName: "deviceStatusFilter"
                    Layout.fillWidth: true
                    implicitHeight: 34
                    activeFocusOnTab: true
                    textRole: "label"
                    valueRole: "value"
                    model: [
                        {"label": "Trạng thái: Tất cả", "value": ""},
                        {"label": "Đang hoạt động", "value": "live"},
                        {"label": "Nhàn rỗi", "value": "idle"},
                        {"label": "Ngoại tuyến", "value": "offline"},
                        {"label": "Bị chặn", "value": "banned"}
                    ]
                    Accessible.name: "Lọc trạng thái thiết bị"
                    onActivated: root.applyFilters()
                }
                PhoneFarmFilterComboBox {
                    id: regionFilter
                    objectName: "deviceRegionFilter"
                    Layout.fillWidth: true
                    implicitHeight: 34
                    activeFocusOnTab: true
                    textRole: "label"
                    valueRole: "value"
                    model: root.regionOptions
                    Accessible.name: "Lọc khu vực thiết bị"
                    onActivated: root.applyFilters()
                }
            }
            Rectangle {
                id: advancedHint
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 42 : 0
                visible: false
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                Accessible.name: "Backend hiện chỉ hỗ trợ tìm kiếm, trạng thái và khu vực"
                Accessible.role: Accessible.StaticText
                Text {
                    anchors.fill: parent; anchors.margins: 8
                    text: "Projection hiện chỉ hỗ trợ search, status và region. Không áp dụng bộ lọc giả phía client."
                    color: Theme.textFaint; font.pixelSize: 11; wrapMode: Text.Wrap
                }
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ListView {
                id: deviceList
                objectName: "deviceInventoryList"
                anchors.fill: parent
                clip: true
                model: root.deviceModel
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                // Device fixtures and the operator's first viewport are
                // bounded. Cache the semantic rows so selection by stable ID
                // survives a snapshot reorder before scrolling begins.
                cacheBuffer: 4096
                reuseItems: false
                ScrollBar.vertical: ScrollBar {}
                delegate: Rectangle {
                id: deviceRow
                required property int index
                required property string deviceId
                required property var label
                required property var device_model
                required property var androidVersion
                required property var healthState
                required property var handle
                required property var accountId
                required property var proxyRegion
                required property var latencyMs
                required property var battery
                required property var leaseHolder
                required property var activeOperationId
                required property var presentationProvenance
                required property var microStatuses
                readonly property var statusData: deviceRow.microStatuses || ({})
                readonly property var networkStatus: statusData.network || ({})
                readonly property var powerStatus: statusData.power || ({})
                readonly property var leaseStatus: statusData.lease || ({})
                readonly property bool visualProductionFixture: Boolean(
                    statusData.visual_production_fixture
                )
                readonly property string statusProvenance: root.statusProvenance(
                    statusData, deviceRow.presentationProvenance
                )
                objectName: "deviceRow_" + String(deviceRow.deviceId || index)
                width: deviceList.width
                height: 76
                radius: Theme.radiusSmall
                color: root.selectedDeviceId === String(deviceRow.deviceId || "")
                    ? Theme.accentSoft
                    : rowMouse.containsMouse ? Theme.hover : "transparent"
                border.width: 1
                border.color: root.selectedDeviceId === String(deviceRow.deviceId || "") ? Theme.accent : Theme.borderSoft
                Accessible.name: String(deviceRow.label || deviceRow.deviceId || "Thiết bị")
                    + ", " + String(deviceRow.device_model || "model không rõ")
                    + ", Android " + String(deviceRow.androidVersion || "không rõ")
                    + ", sức khỏe " + String(deviceRow.healthState || "không rõ")
                Accessible.description: "Account " + String(deviceRow.handle || deviceRow.accountId || "chưa gắn")
                    + ", khu vực " + String(deviceRow.proxyRegion || "không rõ")
                    + ", lease " + String(deviceRow.leaseHolder || "không có")
                    + (deviceRow.visualProductionFixture
                        ? ", fixture production mô phỏng từ demo_seed" : "")
                Accessible.role: Accessible.ListItem
                activeFocusOnTab: true
                Accessible.focusable: true
                Keys.onReturnPressed: deviceRow.activate()
                Keys.onEnterPressed: deviceRow.activate()
                Keys.onSpacePressed: deviceRow.activate()

                function activate() {
                    root.deviceSelected(String(deviceRow.deviceId || ""))
                    return true
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8
                    spacing: 8
                    Device.DeviceAvatar {
                        objectName: "deviceAvatar_" + String(deviceRow.deviceId || deviceRow.index)
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        deviceId: String(deviceRow.deviceId || "")
                        label: String(deviceRow.label || "")
                        healthState: String((deviceRow.statusData.health || {}).state
                            || deviceRow.healthState || "unknown")
                        selected: root.selectedDeviceId === String(deviceRow.deviceId || "")
                        hasActiveOperation: String(deviceRow.activeOperationId || "").length > 0
                        leaseState: String(deviceRow.leaseStatus.state || "none")
                        provenance: deviceRow.statusProvenance
                        visualProductionFixture:
                            deviceRow.visualProductionFixture
                        avatarSize: 40
                        showDemoBadge: false
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        RowLayout {
                            Layout.fillWidth: true
                            Text { Layout.fillWidth: true; text: String(deviceRow.label || deviceRow.deviceId || "—"); color: Theme.text; font.pixelSize: 12; font.weight: Font.Bold; elide: Text.ElideRight }
                            Rectangle {
                                objectName: "deviceInventoryProvenance_"
                                    + String(deviceRow.deviceId || deviceRow.index)
                                visible: deviceRow.statusProvenance !== "production"
                                    && !deviceRow.visualProductionFixture
                                    && root.selectedDeviceId
                                        === String(deviceRow.deviceId || "")
                                Layout.preferredWidth: visible ? 34 : 0
                                Layout.preferredHeight: 16
                                radius: 5
                                color: Theme.accentSoft
                                border.width: visible ? 1 : 0
                                border.color: Theme.accent
                                Accessible.name: "Thiết bị đang chọn dùng dữ liệu DEMO"
                                Accessible.role: Accessible.StaticText
                                Text {
                                    anchors.centerIn: parent
                                    text: "DEMO"
                                    color: Theme.accent
                                    font.pixelSize: 8
                                    font.weight: Font.Bold
                                }
                            }
                        }
                        Text { Layout.fillWidth: true; text: String(deviceRow.device_model || "Model không rõ") + " · Android " + String(deviceRow.androidVersion || "—"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                        Text { Layout.fillWidth: true; text: String(deviceRow.handle || deviceRow.accountId || "Chưa gắn account"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 76
                        Layout.topMargin: 12
                        spacing: 1
                        RowLayout {
                            Layout.alignment: Qt.AlignRight
                            spacing: 4
                            Text {
                                objectName: "deviceRegion_"
                                    + String(deviceRow.deviceId || deviceRow.index)
                                text: String(deviceRow.networkStatus.region
                                    || deviceRow.proxyRegion || "—")
                                color: Theme.textMuted
                                font.pixelSize: 11
                            }
                            Device.SignalIndicator {
                                objectName: "deviceNetworkSignal_"
                                    + String(deviceRow.deviceId || deviceRow.index)
                                level: deviceRow.networkStatus.qualityLevel
                                latencyMs: deviceRow.networkStatus.rttMs
                                status: String(deviceRow.networkStatus.state || "unknown")
                                sampleFresh: Boolean(deviceRow.networkStatus.isFresh)
                                showBars: false
                                showLatency: true
                                provenance: deviceRow.statusProvenance
                                compact: true
                                showDemoBadge: false
                                showProvenanceLabel: false
                            }
                        }
                        Device.BatteryIndicator {
                            objectName: "deviceBattery_"
                                + String(deviceRow.deviceId || deviceRow.index)
                            Layout.alignment: Qt.AlignRight
                            Layout.preferredWidth: 64
                            Layout.minimumWidth: 64
                            Layout.maximumWidth: 64
                            Layout.preferredHeight: 20
                            percent: deviceRow.powerStatus.batteryPercent === undefined
                                ? deviceRow.battery : deviceRow.powerStatus.batteryPercent
                            charging: String(deviceRow.powerStatus.chargingState || "")
                                === "charging"
                            status: root.powerStatus(deviceRow.powerStatus.state)
                            sampleFresh: Boolean(deviceRow.powerStatus.isFresh)
                            showLabel: true
                            provenance: deviceRow.statusProvenance
                            compact: true
                            showDemoBadge: false
                            showProvenanceLabel: false
                        }
                    }
                    Foundation.IconButton {
                        objectName: "deviceHealthButton_" + String(deviceRow.deviceId || deviceRow.index)
                        text: ""
                        iconName: "semantic/info"
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        accessibleName: "Xem bằng chứng sức khỏe " + String(deviceRow.label || deviceRow.deviceId || "thiết bị")
                        activeFocusOnTab: true
                        onClicked: root.deviceSelected(String(deviceRow.deviceId || ""))
                    }
                    Foundation.IconButton {
                        objectName: "deviceLeaseButton_" + String(deviceRow.deviceId || deviceRow.index)
                        text: ""
                        iconName: "ui/external-link"
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        accessibleName: "Xem lease " + String(deviceRow.label || deviceRow.deviceId || "thiết bị")
                        activeFocusOnTab: true
                        onClicked: root.deviceSelected(String(deviceRow.deviceId || ""))
                    }
                }
                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    anchors.rightMargin: 74
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: deviceRow.activate()
                }
                }
            }

            Text {
                anchors.centerIn: parent
                width: parent.width - 24
                height: 72
                visible: !root.deviceModel || root.deviceModel.count === 0
                text: "Không có thiết bị trong projection hiện tại"
                color: Theme.warning
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            Layout.leftMargin: 10
            Layout.rightMargin: 8
            Text {
                Layout.fillWidth: true
                text: "Hiển thị " + String(root.deviceModel ? root.deviceModel.count : 0) + " / "
                    + ((root.page || {}).total === undefined ? "—" : String(root.page.total)) + " thiết bị"
                color: Theme.textFaint
                font.pixelSize: 11
            }
            Foundation.IconButton {
                objectName: "devicePreviousPageButton"
                text: ""
                iconName: "ui/chevron-left"
                accessibleName: "Trang thiết bị trước"
                activeFocusOnTab: true
                enabled: root.cursorOffset > 0
                onClicked: root.requestPreviousPage()
            }
            Rectangle {
                objectName: "deviceCurrentPage"
                Layout.preferredWidth: 34; Layout.preferredHeight: 30; radius: Theme.radiusSmall
                color: Theme.accentSoft; border.width: 1; border.color: Theme.accent
                Accessible.name: "Trang " + String(root.pageNumber)
                Accessible.role: Accessible.StaticText
                Text { anchors.centerIn: parent; text: String(root.pageNumber); color: Theme.accent; font.pixelSize: 11; font.weight: Font.Bold }
            }
            Foundation.IconButton {
                objectName: "deviceNextPageButton"
                text: ""
                iconName: "ui/chevron-right"
                accessibleName: "Trang thiết bị tiếp theo"
                activeFocusOnTab: true
                enabled: String((root.page || {}).next_cursor || "").length > 0
                onClicked: root.requestNextPage()
            }
        }
    }
}
