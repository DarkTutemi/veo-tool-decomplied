pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Item {
    id: root
    property var activity: ({})
    property var controlPlaneBridge: null
    property string kindFilter: ""
    property string groupFilter: ""
    property string platformFilter: ""
    property int selectedIndex: -1
    property int pageOffset: 0
    readonly property int pageSize: 12
    signal filtersRequested(string group, string platform, string kind)
    signal deepLinkRequested(var link)

    readonly property var items: root.listValue(root.activity.items)
    readonly property var visibleItems: root.items.slice(
        root.pageOffset, root.pageOffset + root.pageSize)
    readonly property var throughput: root.mapValue(root.activity.throughput)
    readonly property var exceptions: root.listValue(root.activity.exceptions)
    readonly property var lastChecks: root.listValue(root.activity.last_checks)
    readonly property var catalog: root.mapValue(root.activity.catalog)
    readonly property var selectedEvent: root.selectedIndex >= 0
        && root.selectedIndex < root.items.length ? root.items[root.selectedIndex] : ({})

    function mapValue(value) {
        return value === null || value === undefined ? ({}) : value
    }

    function listValue(value) {
        return value === null || value === undefined ? [] : value
    }

    function kindLabel(kind) {
        const value = String(kind || "")
        if (value === "publish") return "Đăng & xác minh"
        if (value === "care") return "Quét bình luận"
        if (value === "browser") return "Browser"
        if (value === "approval") return "Phê duyệt"
        return "Hệ thống"
    }

    function tone(kind) {
        const value = String(kind || "")
        if (value === "publish") return Theme.success
        if (value === "care") return Theme.info
        if (value === "approval") return Theme.warning
        if (value === "browser") return Theme.accent
        return Theme.textMuted
    }

    function resetPage() {
        root.pageOffset = 0
        root.selectedIndex = -1
    }

    RowLayout {
        anchors.fill: parent
        spacing: Theme.space3

        Rectangle {
            Layout.preferredWidth: 196
            Layout.fillHeight: true
            radius: Theme.radiusLarge
            color: Theme.panel
            border.width: 1
            border.color: Theme.borderSoft
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.space3
                spacing: Theme.space2
                Text {
                    text: "Nhóm kênh"
                    color: Theme.text
                    font.pixelSize: Theme.fontSection
                    font.weight: Font.Bold
                }
                AppComboBox {
                    id: groupCombo
                    objectName: "automationActivityGroupFilter"
                    Layout.fillWidth: true
                    model: [{"key": "", "label": "Toàn bộ"}].concat(
                        root.catalog.groups || [])
                    textRole: "label"
                    valueRole: "key"
                    onActivated: root.filtersRequested(
                        String(currentValue || ""), root.platformFilter, root.kindFilter)
                }
                Text {
                    text: "Nền tảng"
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontMetadata
                    font.weight: Font.DemiBold
                }
                AppComboBox {
                    id: platformCombo
                    objectName: "automationActivityPlatformFilter"
                    Layout.fillWidth: true
                    model: root.catalog.platforms || []
                    textRole: "label"
                    valueRole: "key"
                    onActivated: root.filtersRequested(
                        root.groupFilter, String(currentValue || ""), root.kindFilter)
                }
                Text {
                    text: "Loại hoạt động"
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontMetadata
                    font.weight: Font.DemiBold
                }
                Repeater {
                    model: [
                        ["", "Tất cả"], ["publish", "Đăng bài"],
                        ["care", "Bình luận"], ["browser", "Browser"],
                        ["approval", "Phê duyệt"], ["system", "Hệ thống"]
                    ]
                    delegate: Button {
                        id: kindButton
                        required property var modelData
                        objectName: "automationActivityFilter_" + (modelData[0] || "all")
                        activeFocusOnTab: true
                        Accessible.name: text
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        text: modelData[1]
                        checked: root.kindFilter === modelData[0]
                        contentItem: Text {
                            text: kindButton.text
                            color: kindButton.checked ? Theme.accent : Theme.textMuted
                            font.pixelSize: Theme.fontMetadata
                            font.weight: kindButton.checked ? Font.DemiBold : Font.Normal
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: Theme.radiusSmall
                            color: kindButton.checked ? Theme.accentSoft : "transparent"
                            border.width: kindButton.checked ? 1 : 0
                            border.color: Theme.accent
                        }
                        onClicked: root.filtersRequested(
                            root.groupFilter, root.platformFilter, String(modelData[0]))
                    }
                }
                Item { Layout.fillHeight: true }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                    radius: Theme.radiusMedium
                    color: Theme.elevated
                    border.width: 1
                    border.color: Theme.borderSoft
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        Text { text: "Cửa sổ quan sát"; color: Theme.textMuted; font.pixelSize: 11 }
                        Text { text: String(root.activity.window_hours || 24) + " giờ gần nhất"; color: Theme.text; font.pixelSize: Theme.fontBody; font.weight: Font.DemiBold }
                        Text { Layout.fillWidth: true; text: String(root.activity.observed_at || "—"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideMiddle }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.space3
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radiusLarge
                color: Theme.panel
                border.width: 1
                border.color: Theme.borderSoft
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        Layout.leftMargin: 14
                        Layout.rightMargin: 14
                        Text { Layout.fillWidth: true; text: String(root.items.length) + " sự kiện mới nhất"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }
                        Rectangle { Layout.preferredWidth: 8; Layout.preferredHeight: 8; radius: 4; color: Theme.success }
                        Text { text: "LIVE"; color: Theme.success; font.pixelSize: 11; font.weight: Font.Bold }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: Theme.elevated
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            Repeater {
                                model: [["THỜI GIAN", 0.75], ["KÊNH / NỀN TẢNG", 1.2], ["HÀNH ĐỘNG", 1.2], ["NGUỒN / NỘI DUNG", 1.5], ["KẾT QUẢ", 0.95]]
                                delegate: Text { required property var modelData; Layout.fillWidth: true; Layout.preferredWidth: modelData[1] * 100; text: modelData[0]; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
                            }
                        }
                    }
                    ListView {
                        id: eventList
                        objectName: "automationActivityList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: root.visibleItems
                        boundsBehavior: Flickable.StopAtBounds
                        ScrollBar.vertical: ScrollBar {}
                        delegate: Rectangle {
                            id: eventRow
                            required property var modelData
                            required property int index
                            objectName: "automationActivityRow_" + String(modelData.id || index)
                            activeFocusOnTab: true
                            Accessible.name: root.kindLabel(modelData.kind) + " " + String(modelData.summary || "")
                            Accessible.role: Accessible.Button
                            Keys.onSpacePressed: eventMouse.clicked(Qt.NoButton)
                            Keys.onReturnPressed: eventMouse.clicked(Qt.NoButton)
                            width: eventList.width
                            height: root.selectedIndex === root.pageOffset + index ? 150 : 58
                            color: root.selectedIndex === root.pageOffset + index ? Theme.accentSoft : (index % 2 ? Theme.panel : Theme.elevated)
                            border.width: root.selectedIndex === root.pageOffset + index ? 1 : 0
                            border.color: Theme.accent
                            MouseArea {
                                id: eventMouse
                                anchors.fill: parent
                                onClicked: root.selectedIndex = root.pageOffset + eventRow.index
                            }
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 0
                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 58
                                    spacing: 8
                                    Text { Layout.fillWidth: true; Layout.preferredWidth: 75; text: String(eventRow.modelData.occurred_at || "—"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideLeft }
                                    RowLayout {
                                        Layout.fillWidth: true; Layout.preferredWidth: 120; spacing: 6
                                        Item {
                                            readonly property string platformKey: String(
                                                root.mapValue(eventRow.modelData.channel).platform || "")
                                            Layout.preferredWidth: 18
                                            Layout.preferredHeight: 18
                                            SocialIcon {
                                                anchors.fill: parent
                                                platform: parent.platformKey
                                                visible: parent.platformKey.length > 0
                                            }
                                            UiIcon {
                                                anchors.centerIn: parent
                                                name: "semantic/workflow"
                                                tone: Theme.textMuted
                                                iconSize: 18
                                                visible: parent.platformKey.length === 0
                                            }
                                        }
                                        ColumnLayout { Layout.fillWidth: true; spacing: 1
                                            Text { Layout.fillWidth: true; text: String(root.mapValue(eventRow.modelData.channel).name || "Hệ thống"); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                            Text { Layout.fillWidth: true; text: String(root.mapValue(eventRow.modelData.channel).platform || "system"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                                        }
                                    }
                                    Text { Layout.fillWidth: true; Layout.preferredWidth: 120; text: root.kindLabel(eventRow.modelData.kind); color: root.tone(eventRow.modelData.kind); font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                    RowLayout {
                                        Layout.fillWidth: true; Layout.preferredWidth: 150; spacing: 6
                                        Rectangle {
                                            Layout.preferredWidth: 42; Layout.preferredHeight: 30; radius: Theme.radiusSmall; color: Theme.elevated; clip: true
                                            Image { id: activityThumb; anchors.fill: parent; readonly property var sourceData: root.mapValue(eventRow.modelData.source); source: root.controlPlaneBridge ? root.controlPlaneBridge.authorizedThumbnailUrl(String(sourceData.asset_id || ""), String(sourceData.thumbnail_url || "")) : ""; fillMode: Image.PreserveAspectCrop; asynchronous: true; cache: true; visible: status === Image.Ready }
                                            UiIcon { anchors.centerIn: parent; name: "semantic/video"; tone: Theme.textMuted; iconSize: 16; visible: activityThumb.status !== Image.Ready }
                                        }
                                        Text { Layout.fillWidth: true; text: String(root.mapValue(eventRow.modelData.source).title || eventRow.modelData.summary || "—"); color: Theme.text; font.pixelSize: 11; elide: Text.ElideRight }
                                    }
                                    Text { Layout.fillWidth: true; Layout.preferredWidth: 95; text: String(root.mapValue(eventRow.modelData.result).label || "—"); color: String(root.mapValue(eventRow.modelData.result).state) === "attention" ? Theme.warning : Theme.success; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: root.selectedIndex === root.pageOffset + eventRow.index ? 82 : 0
                                    visible: root.selectedIndex === root.pageOffset + eventRow.index
                                    radius: Theme.radiusSmall
                                    color: Theme.panel
                                    border.width: 1
                                    border.color: Theme.borderSoft
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        ColumnLayout { Layout.fillWidth: true; spacing: 3
                                            Text { Layout.fillWidth: true; text: String(eventRow.modelData.summary || eventRow.modelData.event_type || "Sự kiện"); color: Theme.text; font.pixelSize: Theme.fontBody; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                            Text { Layout.fillWidth: true; text: "Event: " + String(eventRow.modelData.event_type || "—"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideMiddle }
                                            Text { Layout.fillWidth: true; text: "Correlation: " + String(eventRow.modelData.id || "—"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideMiddle }
                                        }
                                        AppButton { objectName: "automationActivityOpen_" + String(eventRow.modelData.id); text: "Mở bằng chứng"; trailingIcon: "ui/external-link"; enabled: eventRow.modelData.deep_link !== null && eventRow.modelData.deep_link !== undefined; availabilityReason: enabled ? "" : "Sự kiện không có thực thể liên kết"; onClicked: root.deepLinkRequested(eventRow.modelData.deep_link) }
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        Text {
                            Layout.fillWidth: true
                            text: root.items.length === 0 ? "Không có sự kiện"
                                : "Hiển thị " + String(root.pageOffset + 1) + "–"
                                    + String(Math.min(root.pageOffset + root.pageSize, root.items.length))
                                    + " / " + String(root.items.length)
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontMetadata
                        }
                        AppButton {
                            objectName: "automationActivityPreviousPage"
                            text: "Trước"
                            leadingIcon: "ui/chevron-left"
                            enabled: root.pageOffset > 0
                            availabilityReason: enabled ? "" : "Đã ở trang đầu"
                            onClicked: {
                                root.pageOffset = Math.max(0, root.pageOffset - root.pageSize)
                                root.selectedIndex = -1
                            }
                        }
                        AppButton {
                            objectName: "automationActivityNextPage"
                            text: "Tiếp"
                            trailingIcon: "ui/chevron-right"
                            enabled: root.pageOffset + root.pageSize < root.items.length
                            availabilityReason: enabled ? "" : "Đã ở trang cuối"
                            onClicked: {
                                root.pageOffset += root.pageSize
                                root.selectedIndex = -1
                            }
                        }
                    }
                }
            }
            RowLayout {
                objectName: "automationActivityThroughputRail"
                Layout.fillWidth: true
                Layout.preferredHeight: 118
                Layout.minimumHeight: 118
                Layout.maximumHeight: 118
                spacing: Theme.space3
                Rectangle {
                    Layout.fillWidth: true; Layout.fillHeight: true; radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.borderSoft
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 12; spacing: Theme.space3
                        Text { text: "Thông lượng 24 giờ"; color: Theme.text; font.pixelSize: Theme.fontBody; font.weight: Font.Bold }
                        Repeater {
                            model: [["Đã xác minh", root.throughput.published_verified || 0, Theme.success], ["Quét bình luận", root.throughput.comments_scanned || 0, Theme.info], ["Lỗi", root.throughput.errors || 0, Theme.danger]]
                            delegate: Rectangle {
                                id: throughputCard
                                required property var modelData
                                required property int index
                                objectName: "automationThroughputCard_" + String(index)
                                Layout.fillWidth: true; Layout.fillHeight: true; radius: Theme.radiusMedium; color: Theme.elevated
                                ColumnLayout { anchors.centerIn: parent; spacing: 2
                                    Text { Layout.alignment: Qt.AlignHCenter; text: String(throughputCard.modelData[1]); color: throughputCard.modelData[2]; font.pixelSize: 22; font.weight: Font.Bold }
                                    Text { text: throughputCard.modelData[0]; color: Theme.textMuted; font.pixelSize: 11 }
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.preferredWidth: 360; Layout.fillHeight: true; radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.borderSoft
                    ColumnLayout { anchors.fill: parent; anchors.margins: 10; spacing: 4
                        Text { text: "Lần kiểm tra theo nhóm"; color: Theme.text; font.pixelSize: Theme.fontBody; font.weight: Font.Bold }
                        Repeater { model: root.lastChecks.slice(0, 2)
                            delegate: RowLayout { id: lastCheckRow; required property var modelData; Layout.fillWidth: true
                                Rectangle { Layout.preferredWidth: 7; Layout.preferredHeight: 7; radius: 4; color: lastCheckRow.modelData.state === "attention" ? Theme.warning : Theme.success }
                                Text { Layout.fillWidth: true; text: String(lastCheckRow.modelData.label) + " · " + String(lastCheckRow.modelData.channel_count) + " kênh"; color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                                Text { text: String(lastCheckRow.modelData.last_check_label); color: Theme.text; font.pixelSize: 11 }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: 330
            Layout.fillHeight: true
            radius: Theme.radiusLarge
            color: Theme.panel
            border.width: 1
            border.color: Theme.borderSoft
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.space3
                spacing: Theme.space2
                RowLayout {
                    Layout.fillWidth: true
                    Text { Layout.fillWidth: true; text: "Cần làm ngay"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }
                    Rectangle { Layout.preferredWidth: 28; Layout.preferredHeight: 24; radius: 12; color: root.exceptions.length ? Theme.dangerSoft : Theme.successSoft
                        Text { anchors.centerIn: parent; text: String(root.exceptions.length); color: root.exceptions.length ? Theme.danger : Theme.success; font.pixelSize: 11; font.weight: Font.Bold }
                    }
                }
                ListView {
                    id: exceptionList
                    objectName: "automationExceptionList"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: root.exceptions
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {}
                    delegate: Rectangle {
                        id: exceptionCard
                        required property var modelData
                        required property int index
                        objectName: "automationException_" + String(modelData.id || index)
                        width: exceptionList.width
                        height: 126
                        radius: Theme.radiusMedium
                        color: modelData.severity === "critical" ? Theme.dangerSoft : Theme.warningSoft
                        border.width: 1
                        border.color: modelData.severity === "critical" ? Theme.danger : Theme.warning
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 10; spacing: 5
                            RowLayout { Layout.fillWidth: true
                                Item {
                                    readonly property string platformKey: String(exceptionCard.modelData.platform || "")
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 20
                                    SocialIcon {
                                        anchors.fill: parent
                                        platform: parent.platformKey
                                        visible: parent.platformKey.length > 0
                                    }
                                    UiIcon {
                                        anchors.centerIn: parent
                                        name: "semantic/alert-triangle"
                                        tone: Theme.warning
                                        iconSize: 20
                                        visible: parent.platformKey.length === 0
                                    }
                                }
                                Text { Layout.fillWidth: true; text: String(exceptionCard.modelData.title || "Cần xử lý"); color: Theme.text; font.pixelSize: Theme.fontBody; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            }
                            Text { Layout.fillWidth: true; text: String(exceptionCard.modelData.detail || exceptionCard.modelData.reason_code || ""); color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight }
                            AppButton { objectName: "automationExceptionOpen_" + String(exceptionCard.modelData.id); Layout.fillWidth: true; Layout.preferredHeight: 30; text: exceptionCard.modelData.kind === "login" ? "Kết nối lại" : exceptionCard.modelData.kind === "source" ? "Thêm video" : "Xem bằng chứng"; trailingIcon: "ui/chevron-right"; enabled: exceptionCard.modelData.deep_link !== null && exceptionCard.modelData.deep_link !== undefined; availabilityReason: enabled ? "" : "Không có điểm xử lý được sở hữu"; onClicked: root.deepLinkRequested(exceptionCard.modelData.deep_link) }
                        }
                    }
                }
            }
        }
    }
}
