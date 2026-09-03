pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Item {
    id: root
    property var fleet: ({})
    property var selectedChannel: ({})
    property var runtime: ({})
    property var rules: ({})
    property var controlPlaneBridge: null
    property var selectedChannelIds: []
    property string searchText: ""
    property string groupFilter: ""
    property string platformFilter: ""
    property string stateFilter: ""
    signal filtersRequested(string search, string group, string platform, string state)
    signal channelSelected(var item)
    signal deepLinkRequested(var link)
    signal actionRequested(var action)
    signal nextPageRequested()
    signal selectionToggled(string channelId, bool checked)
    signal selectPageRequested()
    signal clearSelectionRequested()
    signal bulkRuleRequested(var rule)

    readonly property var items: root.list(root.fleet.items)
    readonly property var catalog: root.map(root.fleet.catalog)
    readonly property var ruleItems: root.list(root.rules.items)

    function map(value) {
        return value === null || value === undefined ? ({}) : value
    }

    function list(value) {
        return value === null || value === undefined ? [] : value
    }

    function hasSelected(channelId) {
        const id = String(channelId || "")
        for (let index = 0; index < root.selectedChannelIds.length; ++index) {
            if (String(root.selectedChannelIds[index]) === id)
                return true
        }
        return false
    }

    function platformLabel(value) {
        const key = String(value || "").toLowerCase()
        if (key === "youtube") return "YouTube"
        if (key === "facebook") return "Facebook"
        if (key === "tiktok") return "TikTok"
        if (key === "instagram") return "Instagram"
        if (key === "linkedin") return "LinkedIn"
        if (key === "x") return "X"
        return key || "—"
    }

    RowLayout {
        anchors.fill: parent
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
                anchors.margins: Theme.space3
                spacing: Theme.space2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.space2
                    WorkflowTextField {
                        id: searchField
                        objectName: "automationFleetSearch"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        text: root.searchText
                        placeholderText: "Tìm tên kênh hoặc @handle…"
                        onAccepted: root.filtersRequested(
                            text.trim(), root.groupFilter,
                            root.platformFilter, root.stateFilter)
                    }
                    AppComboBox {
                        id: groupCombo
                        objectName: "automationFleetGroupFilter"
                        Layout.preferredWidth: 160
                        Layout.preferredHeight: 40
                        model: [{"key": "", "label": "Tất cả nhóm"}].concat(
                            root.catalog.groups || [])
                        textRole: "label"
                        valueRole: "key"
                        onActivated: root.filtersRequested(
                            searchField.text.trim(), String(currentValue || ""),
                            root.platformFilter, root.stateFilter)
                    }
                    AppComboBox {
                        id: platformCombo
                        objectName: "automationFleetPlatformFilter"
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 40
                        model: root.catalog.platforms || []
                        textRole: "label"
                        valueRole: "key"
                        onActivated: root.filtersRequested(
                            searchField.text.trim(), root.groupFilter,
                            String(currentValue || ""),
                            root.stateFilter)
                    }
                    AppComboBox {
                        id: stateCombo
                        objectName: "automationFleetStateFilter"
                        Layout.preferredWidth: 160
                        Layout.preferredHeight: 40
                        model: root.catalog.states || []
                        textRole: "label"
                        valueRole: "key"
                        onActivated: root.filtersRequested(
                            searchField.text.trim(), root.groupFilter,
                            root.platformFilter,
                            String(currentValue || ""))
                    }
                    AppButton {
                        objectName: "automationFleetApplyFilters"
                        text: "Lọc"
                        leadingIcon: "ui/filter"
                        onClicked: root.filtersRequested(
                            searchField.text.trim(), root.groupFilter,
                            root.platformFilter, root.stateFilter)
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    radius: Theme.radiusSmall
                    color: Theme.elevated
                    border.width: 1
                    border.color: Theme.borderSoft
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: Theme.space2
                        AppCheckBox {
                            objectName: "automationFleetSelectPage"
                            checked: root.items.length > 0
                                && root.selectedChannelIds.length >= root.items.length
                            text: "Chọn trang"
                            onClicked: checked
                                ? root.selectPageRequested()
                                : root.clearSelectionRequested()
                        }
                        Text {
                            text: String(root.selectedChannelIds.length) + " kênh đã chọn"
                            color: root.selectedChannelIds.length > 0 ? Theme.accent : Theme.textMuted
                            font.pixelSize: Theme.fontMetadata
                        }
                        Item { Layout.fillWidth: true }
                        AppComboBox {
                            id: bulkRuleCombo
                            objectName: "automationFleetBulkRuleCombo"
                            Layout.preferredWidth: 260
                            model: root.ruleItems
                            textRole: "name"
                            valueRole: "rule_key"
                            enabled: root.selectedChannelIds.length > 0 && count > 0
                            availabilityReason: root.selectedChannelIds.length === 0
                                ? "Chọn ít nhất một kênh" : "Chưa có quy tắc khả dụng"
                        }
                        AppButton {
                            objectName: "automationFleetBulkApplyButton"
                            text: "Áp dụng quy tắc"
                            leadingIcon: "semantic/workflow"
                            primary: true
                            enabled: root.selectedChannelIds.length > 0
                                && bulkRuleCombo.currentIndex >= 0
                                && ((root.ruleItems[bulkRuleCombo.currentIndex].actions || {}).apply || {}).available === true
                            availabilityReason: enabled
                                ? "" : "Chọn kênh và quy tắc server cho phép"
                            onClicked: root.bulkRuleRequested(
                                root.ruleItems[bulkRuleCombo.currentIndex])
                        }
                        AppButton {
                            objectName: "automationFleetClearSelection"
                            text: "Xóa chọn"
                            enabled: root.selectedChannelIds.length > 0
                            availabilityReason: enabled ? "" : "Chưa chọn kênh"
                            onClicked: root.clearSelectionRequested()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    color: Theme.elevated
                    radius: Theme.radiusSmall
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 0
                        Repeater {
                            model: [
                                ["KÊNH / NHÓM", 2.2], ["NGUỒN VIDEO", 1.35],
                                ["QUY TẮC ĐĂNG", 1.3], ["BÀI TIẾP THEO", 1.15],
                                ["COMMENT", 1.1], ["LẦN KIỂM TRA", 1.05],
                                ["TRẠNG THÁI", 0.85]
                            ]
                            delegate: Text {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredWidth: modelData[1] * 100
                                text: modelData[0]
                                color: Theme.textFaint
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                ListView {
                    id: fleetList
                    objectName: "automationFleetList"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    model: root.items
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {}
                        delegate: Rectangle {
                            id: row
                            required property var modelData
                            required property int index
                            readonly property var sourceInventory: root.map(modelData.source_inventory)
                            readonly property var sourcePreview: root.map(sourceInventory.preview)
                            readonly property var nextPublish: root.map(modelData.next_publish)
                            readonly property var commentCare: root.map(modelData.comment_care)
                        objectName: "automationFleetRow_" + String(modelData.channel.id || index)
                        activeFocusOnTab: true
                        Accessible.name: String(modelData.channel.name || "Kênh")
                        Accessible.role: Accessible.Button
                        Keys.onSpacePressed: rowMouse.clicked(Qt.NoButton)
                        Keys.onReturnPressed: rowMouse.clicked(Qt.NoButton)
                        width: fleetList.width
                        height: 68
                        radius: Theme.radiusMedium
                        color: String((root.selectedChannel.channel || {}).id || "")
                                === String(modelData.channel.id || "")
                            ? Theme.accentSoft : (rowMouse.containsMouse ? Theme.hover : Theme.panel)
                        border.width: 1
                        border.color: String((root.selectedChannel.channel || {}).id || "")
                                === String(modelData.channel.id || "")
                            ? Theme.accent : Theme.borderSoft

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.channelSelected(row.modelData)
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 0
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 220
                                spacing: 9
                                AppCheckBox {
                                    objectName: "automationFleetCheck_" + String(row.modelData.channel.id)
                                    checked: root.hasSelected(row.modelData.channel.id)
                                    onClicked: root.selectionToggled(
                                        String(row.modelData.channel.id), checked)
                                }
                                Rectangle {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    radius: 20
                                    color: Theme.elevated
                                    clip: true
                                    Image {
                                        id: rowAvatar
                                        anchors.fill: parent
                                        source: String(row.modelData.channel.avatar_url || "")
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        visible: status === Image.Ready
                                    }
                                    Item {
                                        anchors.centerIn: parent
                                        readonly property string platformKey: String(row.modelData.channel.platform || "")
                                        width: 23
                                        height: 23
                                        visible: rowAvatar.status !== Image.Ready
                                        SocialIcon {
                                            anchors.fill: parent
                                            platform: parent.platformKey
                                            visible: parent.platformKey.length > 0
                                        }
                                        UiIcon {
                                            anchors.centerIn: parent
                                            name: "semantic/channels"
                                            tone: Theme.textMuted
                                            iconSize: 23
                                            visible: parent.platformKey.length === 0
                                        }
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(row.modelData.channel.name || "—")
                                        color: Theme.text
                                        font.pixelSize: Theme.fontBody
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: root.platformLabel(row.modelData.channel.platform)
                                            + " · " + String(row.modelData.channel.handle || "chưa có handle")
                                        color: Theme.textMuted
                                        font.pixelSize: Theme.fontMetadata
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(root.map(row.modelData.channel.group).label || "Chưa phân nhóm")
                                        color: Theme.accent
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true; Layout.preferredWidth: 135; spacing: 2
                                RowLayout {
                                    spacing: 7
                                    Rectangle {
                                        Layout.preferredWidth: 42
                                        Layout.preferredHeight: 30
                                        radius: Theme.radiusSmall
                                        color: Theme.elevated
                                        clip: true
                                        Image {
                                            id: rowSourceImage
                                            anchors.fill: parent
                                            readonly property var previewData: row.sourcePreview
                                            source: root.controlPlaneBridge
                                                ? root.controlPlaneBridge.authorizedThumbnailUrl(
                                                    String(previewData.asset_id || ""),
                                                    String(previewData.thumbnail_url || ""))
                                                : ""
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            cache: true
                                            visible: status === Image.Ready
                                        }
                                        UiIcon {
                                            anchors.centerIn: parent
                                            name: "semantic/video"
                                            tone: Theme.textMuted
                                            iconSize: 17
                                            visible: rowSourceImage.status !== Image.Ready
                                        }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text {
                                            Layout.fillWidth: true
                                            text: String(row.sourcePreview.source_label || "Nguồn video")
                                            color: Theme.text
                                            font.pixelSize: 11
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: String(row.sourceInventory.available_packages || 0)
                                                + " video"
                                            color: Number(row.sourceInventory.available_packages || 0) > 0
                                                ? Theme.textMuted : Theme.warning
                                            font.pixelSize: 11
                                        }
                                    }
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true; Layout.preferredWidth: 130; spacing: 2
                                Text {
                                    text: "Theo quy tắc nhóm"
                                    color: Theme.text; font.pixelSize: Theme.fontMetadata
                                }
                                Text {
                                    text: String(row.modelData.channel.timezone || "UTC")
                                    color: Theme.textFaint; font.pixelSize: 11
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true; Layout.preferredWidth: 115; spacing: 2
                                Text {
                                    text: String(row.nextPublish.label || "Chưa có")
                                    color: row.nextPublish.at
                                        ? Theme.info : Theme.textFaint
                                    font.pixelSize: Theme.fontMetadata
                                }
                                Text {
                                    text: String(row.nextPublish.state || "—")
                                    color: Theme.textFaint; font.pixelSize: 11
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true; Layout.preferredWidth: 110; spacing: 2
                                Text {
                                    text: String(row.commentCare.cadence || "Chưa cấu hình")
                                    color: Theme.text; font.pixelSize: Theme.fontMetadata
                                }
                                Text {
                                    text: String(row.commentCare.comments_observed || 0)
                                        + " comment"
                                    color: Theme.textFaint; font.pixelSize: 11
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true; Layout.preferredWidth: 105; spacing: 2
                                Text {
                                    text: String(row.commentCare.last_run_label || "Chưa có")
                                    color: Theme.text; font.pixelSize: Theme.fontMetadata
                                }
                                Text {
                                    text: "Tiếp: " + String(row.commentCare.next_run_label || "Chưa có")
                                    color: Theme.textFaint; font.pixelSize: 11
                                }
                            }
                            Rectangle {
                                Layout.preferredWidth: 96
                                Layout.preferredHeight: 28
                                radius: 14
                                color: row.modelData.state === "active"
                                    ? Theme.successSoft : row.modelData.state === "attention"
                                        ? Theme.warningSoft : Theme.elevated
                                Text {
                                    anchors.centerIn: parent
                                    text: row.modelData.state === "active" ? "Đang chạy"
                                        : row.modelData.state === "attention" ? "Cần xử lý"
                                            : row.modelData.state === "paused" ? "Tạm dừng" : "Ngoại tuyến"
                                    color: row.modelData.state === "active" ? Theme.success
                                        : row.modelData.state === "attention" ? Theme.warning : Theme.textMuted
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: "Hiển thị " + String(root.items.length) + " / "
                            + String(root.fleet.total || 0) + " kênh"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                    }
                    AppButton {
                        objectName: "automationFleetNextPage"
                        text: "Trang tiếp"
                        trailingIcon: "ui/chevron-right"
                        enabled: Boolean(root.fleet.next_cursor)
                        availabilityReason: enabled ? "" : "Đã ở trang cuối"
                        onClicked: root.nextPageRequested()
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: 360
            Layout.fillHeight: true
            radius: Theme.radiusLarge
            color: Theme.panel
            border.width: 1
            border.color: Theme.borderSoft

            id: inspector
            property var channel: root.map(root.selectedChannel.channel)
            property var actions: root.map(root.selectedChannel.actions)
            property var browserHealth: root.map(root.selectedChannel.browser_health)
            property var sourceInventory: root.map(root.selectedChannel.source_inventory)
            property var nextPublish: root.map(root.selectedChannel.next_publish)
            property var commentCare: root.map(root.selectedChannel.comment_care)
            property var lastPublish: root.map(root.selectedChannel.last_publish)
            property var runCheckAction: root.map(actions.run_check)
            property var openChannelAction: root.map(actions.open_channel)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.space4
                spacing: Theme.space3
                Text {
                    text: "Chi tiết kênh"
                    color: Theme.text
                    font.pixelSize: Theme.fontSection
                    font.weight: Font.Bold
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Rectangle {
                        Layout.preferredWidth: 52
                        Layout.preferredHeight: 52
                        radius: 26
                        color: Theme.elevated
                        clip: true
                        Image {
                            id: inspectorAvatar
                            anchors.fill: parent
                            source: String(inspector.channel.avatar_url || "")
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            visible: status === Image.Ready
                        }
                        Item {
                            anchors.centerIn: parent
                            readonly property string platformKey: String(inspector.channel.platform || "")
                            width: 30
                            height: 30
                            visible: inspectorAvatar.status !== Image.Ready
                            SocialIcon {
                                anchors.fill: parent
                                platform: parent.platformKey
                                visible: parent.platformKey.length > 0
                            }
                            UiIcon {
                                anchors.centerIn: parent
                                name: "semantic/channels"
                                tone: Theme.textMuted
                                iconSize: 30
                                visible: parent.platformKey.length === 0
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 2
                        Text {
                            Layout.fillWidth: true
                            text: String(inspector.channel.name || "Chọn một kênh")
                            color: Theme.text; font.pixelSize: 15; font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: String(inspector.channel.handle || "")
                            color: Theme.textMuted; font.pixelSize: Theme.fontMetadata
                            elide: Text.ElideRight
                        }
                    }
                }
                Repeater {
                    model: [
                        ["Browser", String(inspector.browserHealth.code || "—")],
                        ["Video sẵn sàng", String(inspector.sourceInventory.available_packages || 0)],
                        ["Bài tiếp theo", String(inspector.nextPublish.label || "Chưa có")],
                        ["Comment", String(inspector.commentCare.cadence || "Chưa cấu hình")],
                        ["Lần quét cuối", String(inspector.commentCare.last_run_label || "Chưa có")],
                        ["Post ID", String(inspector.lastPublish.external_post_id || "Chưa có")]
                    ]
                    delegate: RowLayout {
                        id: fact
                        required property var modelData
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: fact.modelData[0]
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontMetadata
                        }
                        Text {
                            Layout.maximumWidth: 190
                            text: fact.modelData[1]
                            color: Theme.text
                            font.pixelSize: Theme.fontMetadata
                            font.weight: Font.DemiBold
                            elide: Text.ElideMiddle
                        }
                    }
                }
                Item { Layout.fillHeight: true }
                AppButton {
                    objectName: "automationChannelRunCheck"
                    Layout.fillWidth: true
                    text: "Chạy kiểm tra ngay"
                    leadingIcon: "ui/refresh-cw"
                    primary: true
                    enabled: inspector.runCheckAction.available === true
                    availabilityReason: String(inspector.runCheckAction.reason_code || "")
                    onClicked: root.actionRequested(inspector.runCheckAction)
                }
                AppButton {
                    objectName: "automationChannelOpen"
                    Layout.fillWidth: true
                    text: "Mở trong Kênh"
                    trailingIcon: "ui/external-link"
                    enabled: inspector.openChannelAction.available === true
                    availabilityReason: String(inspector.openChannelAction.reason_code || "")
                    onClicked: root.deepLinkRequested(inspector.openChannelAction.deep_link)
                }
                AppButton {
                    objectName: "automationChannelOpenSource"
                    Layout.fillWidth: true
                    text: "Xem nguồn video"
                    trailingIcon: "ui/external-link"
                    enabled: inspector.sourceInventory.deep_link !== null
                        && inspector.sourceInventory.deep_link !== undefined
                    availabilityReason: enabled ? "" : "Kênh chưa có nguồn video"
                    onClicked: root.deepLinkRequested(inspector.sourceInventory.deep_link)
                }
            }
        }
    }
}
