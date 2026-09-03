pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Item {
    id: root

    property var rules: ({})
    property var distribution: ({})
    property bool creating: false
    property bool editorOnly: false
    property var selectedChannelIds: []

    signal ruleSelected(var item)
    signal actionRequested(var action, var overrides)
    signal deepLinkRequested(var link)

    readonly property var items: root.list(root.map(root.rules).items)
    readonly property var plans: root.map(root.map(root.distribution).plans)
    readonly property var displayItems: root.list(root.plans.items).length > 0
        ? root.list(root.plans.items) : root.items
    readonly property var selected: root.creating ? ({}) : root.map(root.map(root.rules).selected)
    readonly property var selectedPlan: root.creating
        ? ({}) : root.map(root.plans.selected)
    readonly property var catalog: root.map(root.map(root.rules).catalog)
    readonly property var createAction: root.map(root.map(root.map(root.rules).actions).create)
    readonly property var preview: root.list(root.selectedPlan.next_slots).length > 0
        ? {
            "state": root.selectedPlan.enabled ? "ready" : "paused",
            "items": root.selectedPlan.next_slots,
            "total": root.selectedPlan.next_slots.length,
            "reason_code": null
        }
        : root.map(root.selected.preview)

    function itemKey(item) {
        const row = root.map(item)
        return String(row.plan_key || row.rule_key || "")
    }

    function itemGroup(item) {
        const row = root.map(item)
        return String(root.map(row.targets).group_key
            || root.map(row.scope).group_key || "—")
    }

    function itemChannelCount(item) {
        const row = root.map(item)
        const targets = root.map(row.targets)
        return targets.channel_count !== undefined
            ? Number(targets.channel_count)
            : root.list(root.map(row.scope).channel_ids).length
    }

    function itemInterval(item) {
        const row = root.map(item)
        return Number(root.map(row.cadence).interval_minutes
            || root.map(row.publish).interval_minutes || 0)
    }

    function present(value) {
        return value !== null && value !== undefined
    }

    function map(value) {
        return root.present(value) ? value : ({})
    }

    function list(value) {
        return root.present(value) ? value : []
    }

    function findIndexByKey(model, key) {
        const rows = root.list(model)
        for (let index = 0; index < rows.length; ++index) {
            if (String(rows[index].key) === String(key))
                return index
        }
        return rows.length > 0 ? 0 : -1
    }

    function hasChannel(channelId) {
        const id = String(channelId)
        for (let index = 0; index < root.selectedChannelIds.length; ++index) {
            if (String(root.selectedChannelIds[index]) === id)
                return true
        }
        return false
    }

    function setChannel(channelId, checked) {
        const id = String(channelId)
        const next = []
        for (let index = 0; index < root.selectedChannelIds.length; ++index) {
            const current = String(root.selectedChannelIds[index])
            if (current !== id)
                next.push(current)
        }
        if (checked)
            next.push(id)
        root.selectedChannelIds = next
    }

    function selectGroupChannels() {
        const groupKey = String(groupCombo.currentValue || "")
        const next = []
        const channels = root.list(root.catalog.channels)
        for (let index = 0; index < channels.length; ++index) {
            if (String(channels[index].group_key || "") === groupKey)
                next.push(String(channels[index].id))
        }
        root.selectedChannelIds = next
    }

    function openCreate() {
        root.creating = true
        root.syncForm()
    }

    function syncForm() {
        const item = root.creating ? root.map(root.createAction.input) : root.selected
        const publish = root.map(item.publish)
        const care = root.map(item.care)
        const scope = root.map(item.scope)
        const source = root.map(item.source)
        const failure = root.map(item.failure)
        ruleKeyField.text = root.creating ? "" : String(item.rule_key || "")
        ruleNameField.text = root.creating ? "" : String(item.name || "")
        groupCombo.currentIndex = root.findIndexByKey(
            root.catalog.groups,
            String(scope.group_key || "unassigned")
        )
        sourceCombo.currentIndex = root.findIndexByKey(
            root.catalog.source_kinds,
            String(source.kind || "content_library")
        )
        strategyCombo.currentIndex = root.findIndexByKey(
            root.catalog.source_strategies,
            String(source.strategy || "sequential")
        )
        timezoneCombo.currentIndex = root.findIndexByKey(
            root.catalog.timezone_modes,
            String(publish.timezone_mode || "channel")
        )
        replyModeCombo.currentIndex = root.findIndexByKey(
            root.catalog.reply_modes,
            String(care.reply_mode || "draft_only")
        )
        channelFailureCombo.currentIndex = root.findIndexByKey(
            root.catalog.channel_failure_behaviors,
            String(failure.channel_behavior || "pause")
        )
        groupFailureCombo.currentIndex = root.findIndexByKey(
            root.catalog.group_failure_behaviors,
            String(failure.group_behavior || "continue")
        )
        const channels = root.list(scope.channel_ids)
        const selectedIds = []
        for (let index = 0; index < channels.length; ++index)
            selectedIds.push(String(channels[index]))
        root.selectedChannelIds = selectedIds
        intervalSpin.value = publish.interval_minutes === undefined ? 120 : publish.interval_minutes
        dailyCapSpin.value = publish.daily_cap === undefined ? 8 : publish.daily_cap
        commentSpin.value = care.scan_interval_minutes === undefined ? 360 : care.scan_interval_minutes
        lowStockSpin.value = source.low_stock_threshold === undefined ? 5 : source.low_stock_threshold
        staggerMinSpin.value = publish.stagger_min_minutes === undefined ? 3 : publish.stagger_min_minutes
        staggerMaxSpin.value = publish.stagger_max_minutes === undefined ? 12 : publish.stagger_max_minutes
        allowReuseCheck.checked = source.allow_reuse === true
        highRiskCheck.checked = care.high_risk_requires_approval !== false
        windowStartField.text = String(publish.window_start || "07:00")
        windowEndField.text = String(publish.window_end || "22:00")
        approvalCheck.checked = true
    }

    function actionInput() {
        const action = root.creating
            ? root.createAction
            : root.map(root.map(root.selected.actions).revise)
        const input = root.map(action.input)
        return {
            "rule_key": ruleKeyField.text.trim(),
            "name": ruleNameField.text.trim(),
            "enabled": root.creating ? true : root.selected.enabled === true,
            "scope": {
                "group_key": String(groupCombo.currentValue || "unassigned"),
                "channel_ids": root.selectedChannelIds
            },
            "source": {
                "kind": String(sourceCombo.currentValue || "content_library"),
                "strategy": String(strategyCombo.currentValue || "sequential"),
                "low_stock_threshold": lowStockSpin.value,
                "allow_reuse": allowReuseCheck.checked
            },
            "publish": {
                "interval_minutes": intervalSpin.value,
                "window_start": windowStartField.text.trim(),
                "window_end": windowEndField.text.trim(),
                "timezone_mode": String(timezoneCombo.currentValue || "channel"),
                "daily_cap": dailyCapSpin.value,
                "stagger_min_minutes": staggerMinSpin.value,
                "stagger_max_minutes": staggerMaxSpin.value,
                "require_approval": true
            },
            "care": {
                "scan_interval_minutes": commentSpin.value,
                "reply_mode": String(replyModeCombo.currentValue || "draft_only"),
                "high_risk_requires_approval": highRiskCheck.checked
            },
            "failure": {
                "channel_behavior": String(channelFailureCombo.currentValue || "pause"),
                "group_behavior": String(groupFailureCombo.currentValue || "continue"),
                "unknown_publish_result": "verification_required",
                "blind_retry": false
            }
        }
    }

    onSelectedChanged: if (!root.creating) root.syncForm()
    Component.onCompleted: root.syncForm()

    RowLayout {
        anchors.fill: parent
        spacing: Theme.space3

        Rectangle {
            visible: !root.editorOnly
            Layout.preferredWidth: visible ? 292 : 0
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
                    Text {
                        Layout.fillWidth: true
                        text: "Kế hoạch phân phối"
                        color: Theme.text
                        font.pixelSize: Theme.fontSection
                        font.weight: Font.Bold
                    }
                    Text {
                        text: String(root.displayItems.length)
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontBody
                    }
                }

                AppButton {
                    objectName: "automationRuleNewButton"
                    Layout.fillWidth: true
                    text: "Kế hoạch mới"
                    leadingIcon: "ui/plus"
                    primary: true
                    enabled: root.createAction.available === true
                    availabilityReason: String(root.createAction.reason_code || "")
                    onClicked: root.openCreate()
                }

                ListView {
                    id: ruleList
                    objectName: "automationRuleList"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: root.displayItems
                    spacing: 7
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {}

                    delegate: Rectangle {
                        id: ruleRow
                        required property var modelData
                        required property int index
                        objectName: "automationRuleRow_" + root.itemKey(modelData)
                        activeFocusOnTab: true
                        Accessible.name: String(modelData.name || "Kế hoạch phân phối")
                        Accessible.role: Accessible.Button
                        Keys.onSpacePressed: ruleMouse.clicked(Qt.NoButton)
                        Keys.onReturnPressed: ruleMouse.clicked(Qt.NoButton)
                        width: ruleList.width
                        height: 94
                        radius: Theme.radiusMedium
                        color: String(root.selected.rule_key || "")
                                === root.itemKey(modelData) && !root.creating
                            ? Theme.accentSoft : (ruleMouse.containsMouse ? Theme.hover : Theme.elevated)
                        border.width: 1
                        border.color: String(root.selected.rule_key || "")
                                === root.itemKey(modelData) && !root.creating
                            ? Theme.accent : Theme.borderSoft

                        MouseArea {
                            id: ruleMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.creating = false
                                root.ruleSelected(ruleRow.modelData)
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 4
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: String(ruleRow.modelData.name || "—")
                                    color: Theme.text
                                    font.pixelSize: Theme.fontBody
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                Rectangle {
                                    Layout.preferredWidth: 54
                                    Layout.preferredHeight: 22
                                    radius: 11
                                    color: ruleRow.modelData.enabled ? Theme.successSoft : Theme.warningSoft
                                    Text {
                                        anchors.centerIn: parent
                                        text: ruleRow.modelData.enabled ? "Bật" : "Dừng"
                                        color: ruleRow.modelData.enabled ? Theme.success : Theme.warning
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: root.itemGroup(ruleRow.modelData)
                                    + " · " + String(root.itemChannelCount(ruleRow.modelData))
                                    + " kênh"
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontMetadata
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Mỗi " + String(root.itemInterval(ruleRow.modelData))
                                    + " phút · kiểm tra bình luận "
                                    + String(root.map(ruleRow.modelData.care).scan_interval_minutes || 0)
                                    + " phút"
                                color: Theme.textFaint
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

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

                ScrollView {
                    id: editorScroll
                    objectName: "automationRuleEditorScroll"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                ColumnLayout {
                    width: Math.max(720, editorScroll.availableWidth)
                    spacing: Theme.space3

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: root.creating ? "Tạo kế hoạch phân phối" : "Chỉnh sửa kế hoạch"
                            color: Theme.text
                            font.pixelSize: Theme.fontSection
                            font.weight: Font.Bold
                        }
                        Rectangle {
                            Layout.preferredWidth: 86
                            Layout.preferredHeight: 26
                            radius: 13
                            color: root.creating || root.selected.enabled ? Theme.successSoft : Theme.warningSoft
                            Text {
                                anchors.centerIn: parent
                                text: root.creating || root.selected.enabled ? "Đang bật" : "Tạm dừng"
                                color: root.creating || root.selected.enabled ? Theme.success : Theme.warning
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: Theme.space3
                        rowSpacing: Theme.space2
                        Text { text: "Mã kế hoạch"; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                        Text { text: "Tên kế hoạch"; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                        WorkflowTextField {
                            id: ruleKeyField
                            objectName: "automationRuleKeyField"
                            Layout.fillWidth: true
                            enabled: root.creating
                            availabilityReason: enabled ? "" : "Mã kế hoạch không đổi sau khi tạo"
                            placeholderText: "ban-hang-2h"
                        }
                        WorkflowTextField {
                            id: ruleNameField
                            objectName: "automationRuleNameField"
                            Layout.fillWidth: true
                            placeholderText: "Bán hàng · đăng mỗi 2 giờ"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 114
                        radius: Theme.radiusMedium
                        color: Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 7
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: "Kênh nhận video"
                                    color: Theme.text
                                    font.pixelSize: Theme.fontBody
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    text: String(root.selectedChannelIds.length) + " kênh đã chọn"
                                    color: root.selectedChannelIds.length > 0 ? Theme.success : Theme.warning
                                    font.pixelSize: Theme.fontMetadata
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.space2
                                AppComboBox {
                                    id: groupCombo
                                    objectName: "automationRuleGroupCombo"
                                    Layout.fillWidth: true
                                    model: root.list(root.catalog.groups)
                                    textRole: "label"
                                    valueRole: "key"
                                }
                                AppButton {
                                    objectName: "automationRuleSelectGroupButton"
                                    text: "Chọn cả nhóm"
                                    leadingIcon: "ui/check-square"
                                    enabled: groupCombo.currentIndex >= 0
                                    availabilityReason: enabled ? "" : "Chưa có nhóm kênh"
                                    onClicked: root.selectGroupChannels()
                                }
                                AppButton {
                                    objectName: "automationRuleChooseChannelsButton"
                                    text: "Chọn từng kênh"
                                    leadingIcon: "semantic/channels"
                                    onClicked: channelPopup.open()
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        radius: Theme.radiusMedium
                        color: Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 7
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: "Nguồn video"
                                    color: Theme.text
                                    font.pixelSize: Theme.fontBody
                                    font.weight: Font.DemiBold
                                }
                                AppButton {
                                    objectName: "automationRuleOpenSource"
                                    text: "Mở nguồn"
                                    trailingIcon: "ui/external-link"
                                    enabled: root.present(root.map(root.selected.source_descriptor).deep_link)
                                    availabilityReason: enabled ? "" : "Chọn nguồn sau khi tạo kế hoạch"
                                    onClicked: root.deepLinkRequested(
                                        root.map(root.selected.source_descriptor).deep_link)
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.space2
                                AppComboBox {
                                    id: sourceCombo
                                    objectName: "automationRuleSourceCombo"
                                    Layout.fillWidth: true
                                    model: root.list(root.catalog.source_kinds)
                                    textRole: "label"
                                    valueRole: "key"
                                }
                                AppComboBox {
                                    id: strategyCombo
                                    objectName: "automationRuleStrategyCombo"
                                    Layout.fillWidth: true
                                    model: root.list(root.catalog.source_strategies)
                                    textRole: "label"
                                    valueRole: "key"
                                }
                                WorkflowSpinBox {
                                    id: lowStockSpin
                                    objectName: "automationRuleLowStock"
                                    Layout.preferredWidth: 130
                                    from: 0
                                    to: 10000
                                    Accessible.name: "Ngưỡng sắp hết video"
                                }
                            }
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        columnSpacing: Theme.space3
                        rowSpacing: 5
                        Text { text: "Cách nhau (phút)"; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                        Text { text: "Khung giờ"; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                        Text { text: "Múi giờ"; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                        WorkflowSpinBox {
                            id: intervalSpin
                            objectName: "automationRuleInterval"
                            Layout.fillWidth: true
                            from: 15
                            to: 43200
                            stepSize: 15
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            WorkflowTextField {
                                id: windowStartField
                                objectName: "automationRuleWindowStart"
                                Layout.fillWidth: true
                                placeholderText: "07:00"
                            }
                            Text { text: "–"; color: Theme.textMuted }
                            WorkflowTextField {
                                id: windowEndField
                                objectName: "automationRuleWindowEnd"
                                Layout.fillWidth: true
                                placeholderText: "22:00"
                            }
                        }
                        AppComboBox {
                            id: timezoneCombo
                            objectName: "automationRuleTimezoneCombo"
                            Layout.fillWidth: true
                            model: root.list(root.catalog.timezone_modes)
                            textRole: "label"
                            valueRole: "key"
                        }
                        Text { text: "Giới hạn/ngày"; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                        Text { text: "Theo dõi sau đăng (phút)"; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                        Text { text: "Phê duyệt"; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                        WorkflowSpinBox {
                            id: dailyCapSpin
                            objectName: "automationRuleDailyCap"
                            Layout.fillWidth: true
                            from: 1
                            to: 100
                        }
                        WorkflowSpinBox {
                            id: commentSpin
                            objectName: "automationRuleCommentInterval"
                            Layout.fillWidth: true
                            from: 15
                            to: 43200
                            stepSize: 15
                        }
                        AppCheckBox {
                            id: approvalCheck
                            objectName: "automationRuleApprovalCheck"
                            text: "Luôn duyệt"
                            Layout.fillWidth: true
                            checked: true
                            enabled: false
                            availabilityReason: "Publishing bên ngoài luôn cần approval server-side"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 190
                        radius: Theme.radiusMedium
                        color: Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft

                        GridLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            columns: 4
                            columnSpacing: Theme.space3
                            rowSpacing: 6

                            Text { text: "Giãn cách tối thiểu"; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                            WorkflowSpinBox {
                                id: staggerMinSpin
                                objectName: "automationRuleStaggerMin"
                                Layout.fillWidth: true
                                from: 0
                                to: 1440
                            }
                            Text { text: "Giãn cách tối đa"; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                            WorkflowSpinBox {
                                id: staggerMaxSpin
                                objectName: "automationRuleStaggerMax"
                                Layout.fillWidth: true
                                from: staggerMinSpin.value
                                to: 1440
                            }

                            Text { text: "Phản hồi bình luận"; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                            AppComboBox {
                                id: replyModeCombo
                                objectName: "automationRuleReplyMode"
                                Layout.fillWidth: true
                                model: root.list(root.catalog.reply_modes)
                                textRole: "label"
                                valueRole: "key"
                            }
                            Text { text: "Kênh gặp lỗi"; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                            AppComboBox {
                                id: channelFailureCombo
                                objectName: "automationRuleChannelFailure"
                                Layout.fillWidth: true
                                model: root.list(root.catalog.channel_failure_behaviors)
                                textRole: "label"
                                valueRole: "key"
                            }

                            Text { text: "Nhóm khi có lỗi"; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                            AppComboBox {
                                id: groupFailureCombo
                                objectName: "automationRuleGroupFailure"
                                Layout.fillWidth: true
                                model: root.list(root.catalog.group_failure_behaviors)
                                textRole: "label"
                                valueRole: "key"
                            }
                            AppCheckBox {
                                id: allowReuseCheck
                                objectName: "automationRuleAllowReuse"
                                Layout.columnSpan: 2
                                Layout.fillWidth: true
                                text: "Dùng lại video"
                            }

                            AppCheckBox {
                                id: highRiskCheck
                                objectName: "automationRuleHighRiskApproval"
                                Layout.columnSpan: 2
                                Layout.fillWidth: true
                                text: "Duyệt rủi ro"
                            }
                            AppCheckBox {
                                objectName: "automationRuleBlindRetry"
                                Layout.columnSpan: 2
                                Layout.fillWidth: true
                                text: "Blind retry: tắt"
                                checked: false
                                enabled: false
                                availabilityReason: "Không blind retry khi chưa biết publish thành công hay thất bại"
                            }
                        }
                    }

                }
                }

                RowLayout {
                    objectName: "automationRuleFixedFooter"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    spacing: Theme.space2
                    AppButton {
                        objectName: "automationRuleToggleButton"
                        visible: !root.creating
                        text: root.selected.enabled ? "Tạm dừng" : "Bật lại"
                        leadingIcon: root.selected.enabled ? "ui/pause" : "ui/play"
                        enabled: root.map(root.map(root.selected.actions).set_enabled).available === true
                        availabilityReason: String(root.map(root.map(root.selected.actions).set_enabled).reason_code || "")
                        onClicked: root.actionRequested(root.map(root.map(root.selected.actions).set_enabled), {})
                    }
                    AppButton {
                        objectName: "automationRuleArchiveButton"
                        visible: !root.creating
                        text: "Lưu trữ"
                        leadingIcon: "ui/archive"
                        enabled: root.map(root.map(root.selected.actions).archive).available === true
                        availabilityReason: String(root.map(root.map(root.selected.actions).archive).reason_code || "")
                        onClicked: root.actionRequested(root.map(root.map(root.selected.actions).archive), {})
                    }
                    Item { Layout.fillWidth: true }
                    AppButton {
                        objectName: "automationRuleResetButton"
                        text: root.creating ? "Hủy" : "Đặt lại"
                        onClicked: {
                            root.creating = false
                            root.syncForm()
                        }
                    }
                    AppButton {
                        objectName: "automationRuleSaveButton"
                        text: root.creating ? "Tạo kế hoạch" : "Lưu thay đổi"
                        leadingIcon: "ui/check"
                        primary: true
                        enabled: ruleKeyField.text.trim().length > 0
                            && ruleNameField.text.trim().length > 0
                            && root.selectedChannelIds.length > 0
                            && (root.creating
                                ? root.createAction.available === true
                                : root.map(root.map(root.selected.actions).revise).available === true)
                        availabilityReason: enabled ? "" : "Cần tên, mã, ít nhất một kênh và quyền chỉnh sửa"
                        onClicked: root.actionRequested(
                            root.creating ? root.createAction : root.map(root.map(root.selected.actions).revise),
                            root.actionInput())
                    }
                }
            }
        }

        Rectangle {
            visible: !root.editorOnly
            Layout.preferredWidth: visible ? 356 : 0
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
                    Text {
                        Layout.fillWidth: true
                        text: "Lượt đăng sắp tới"
                        color: Theme.text
                        font.pixelSize: Theme.fontSection
                        font.weight: Font.Bold
                    }
                    Text {
                        text: String(root.preview.total || 0)
                        color: Theme.accent
                        font.pixelSize: Theme.fontBody
                        font.weight: Font.Bold
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: "Mỗi lượt dưới đây đã gắn video, kênh, thời điểm và trạng thái duyệt."
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontMetadata
                    wrapMode: Text.WordWrap
                }

                ListView {
                    id: previewList
                    objectName: "automationRulePreviewList"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: root.list(root.preview.items)
                    spacing: 7
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {}

                    delegate: Rectangle {
                        id: previewRow
                        required property var modelData
                        required property int index
                        objectName: "automationRulePreview_" + String(modelData.schedule_id || index)
                        activeFocusOnTab: true
                        width: previewList.width
                        height: 78
                        radius: Theme.radiusMedium
                        color: previewMouse.containsMouse ? Theme.hover : Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft
                        Accessible.name: String(modelData.local_time || "") + " "
                            + String(modelData.channel_name || "") + " "
                            + String(modelData.content_title || "")
                        Accessible.role: Accessible.Button
                        Keys.onSpacePressed: previewMouse.clicked(Qt.NoButton)
                        Keys.onReturnPressed: previewMouse.clicked(Qt.NoButton)

                        MouseArea {
                            id: previewMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: root.present(previewRow.modelData.deep_link)
                            onClicked: root.deepLinkRequested(previewRow.modelData.deep_link)
                        }
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 9
                            Rectangle {
                                Layout.preferredWidth: 42
                                Layout.preferredHeight: 42
                                radius: Theme.radiusSmall
                                color: Theme.accentSoft
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 0
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: String(previewRow.modelData.local_time || "—")
                                        color: Theme.accent
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                    }
                                    Item {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        readonly property string platformKey: String(previewRow.modelData.platform || "")
                                        width: 14
                                        height: 14
                                        SocialIcon {
                                            anchors.fill: parent
                                            platform: parent.platformKey
                                            visible: parent.platformKey.length > 0
                                        }
                                        UiIcon {
                                            anchors.centerIn: parent
                                            name: "semantic/workflow"
                                            tone: Theme.textMuted
                                            iconSize: 14
                                            visible: parent.platformKey.length === 0
                                        }
                                    }
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    Layout.fillWidth: true
                                    text: String(previewRow.modelData.content_title || "—")
                                    color: Theme.text
                                    font.pixelSize: Theme.fontMetadata
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(previewRow.modelData.channel_name || "—")
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: previewRow.modelData.approval_state === "pending"
                                        ? "Đang chờ duyệt" : "Trạng thái duyệt: "
                                            + String(previewRow.modelData.approval_state || "—")
                                    color: previewRow.modelData.approval_state === "pending"
                                        ? Theme.warning : Theme.success
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                            }
                            UiIcon { name: "ui/chevron-right"; iconSize: 14; tone: Theme.textFaint }
                        }
                    }
                }

                Rectangle {
                    visible: root.list(root.preview.items).length === 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? 88 : 0
                    radius: Theme.radiusMedium
                    color: Theme.warningSoft
                    border.width: 1
                    border.color: Theme.warning
                    Text {
                        anchors.fill: parent
                        anchors.margins: 12
                        text: root.creating
                            ? "Lưu kế hoạch để tạo các lượt đăng đầu tiên."
                            : "Chưa có lượt đăng hợp lệ. Hãy kiểm tra nguồn video và kênh đã chọn."
                        color: Theme.warning
                        font.pixelSize: Theme.fontMetadata
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                    radius: Theme.radiusMedium
                    color: Theme.accentSoft
                    border.width: 1
                    border.color: Theme.info
                    Text {
                        anchors.fill: parent
                        anchors.margins: 10
                        text: "Sau khi đăng, hệ thống lưu liên kết và bằng chứng. Kết quả chưa xác minh sẽ dừng để bạn kiểm tra."
                        color: Theme.info
                        font.pixelSize: Theme.fontMetadata
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    Popup {
        id: channelPopup
        objectName: "automationRuleChannelPopup"
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: 520
        height: 520
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0

        background: Rectangle {
            radius: Theme.radiusLarge
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.space4
            spacing: Theme.space3
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Chọn kênh cho kế hoạch"
                    color: Theme.text
                    font.pixelSize: Theme.fontSection
                    font.weight: Font.Bold
                }
                Text {
                    text: String(root.selectedChannelIds.length) + " đã chọn"
                    color: Theme.accent
                    font.pixelSize: Theme.fontBody
                }
            }
            ListView {
                id: channelList
                objectName: "automationRuleChannelList"
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: root.list(root.catalog.channels)
                spacing: 6
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {}
                delegate: Rectangle {
                    id: channelRow
                    required property var modelData
                    required property int index
                    objectName: "automationRuleChannel_" + String(modelData.id || index)
                    activeFocusOnTab: true
                    Accessible.name: String(modelData.label || "Kênh")
                    Accessible.role: Accessible.Button
                    Keys.onSpacePressed: channelMouse.clicked(Qt.NoButton)
                    Keys.onReturnPressed: channelMouse.clicked(Qt.NoButton)
                    width: channelList.width
                    height: 54
                    radius: Theme.radiusMedium
                    color: channelMouse.containsMouse ? Theme.hover : Theme.elevated
                    border.width: 1
                    border.color: Theme.borderSoft
                    MouseArea {
                        id: channelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.setChannel(
                            channelRow.modelData.id,
                            !root.hasChannel(channelRow.modelData.id))
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        Item {
                            readonly property string platformKey: String(channelRow.modelData.platform || "")
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                            SocialIcon {
                                anchors.fill: parent
                                platform: parent.platformKey
                                visible: parent.platformKey.length > 0
                            }
                            UiIcon {
                                anchors.centerIn: parent
                                name: "semantic/channels"
                                tone: Theme.textMuted
                                iconSize: 22
                                visible: parent.platformKey.length === 0
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                Layout.fillWidth: true
                                text: String(channelRow.modelData.label || "—")
                                color: Theme.text
                                font.pixelSize: Theme.fontBody
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: String(channelRow.modelData.handle || "")
                                    + " · " + String(channelRow.modelData.group_key || "")
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontMetadata
                                elide: Text.ElideRight
                            }
                        }
                        AppCheckBox {
                            objectName: "automationRuleChannelCheck_" + String(channelRow.modelData.id)
                            checked: root.hasChannel(channelRow.modelData.id)
                            onToggled: root.setChannel(channelRow.modelData.id, checked)
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                AppButton {
                    objectName: "automationRuleClearChannels"
                    text: "Bỏ chọn"
                    onClicked: root.selectedChannelIds = []
                }
                Item { Layout.fillWidth: true }
                AppButton {
                    objectName: "automationRuleChannelDone"
                    text: "Xong"
                    primary: true
                    enabled: root.selectedChannelIds.length > 0
                    availabilityReason: enabled ? "" : "Chọn ít nhất một kênh"
                    onClicked: channelPopup.close()
                }
            }
        }
    }
}
