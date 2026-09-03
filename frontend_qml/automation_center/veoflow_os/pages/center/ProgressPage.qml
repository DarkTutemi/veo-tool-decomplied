pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "CenterFormat.js" as Fmt

Item {
    id: root
    objectName: "centerProgressPage"

    required property var plane
    signal openWorkflowRequested(string workflow)

    property string query: ""
    property string workflowFilter: ""
    property string channelFilter: ""
    property string activityFilter: ""
    property int modelRevision: 0
    readonly property bool compactLayout: width < 1450
    readonly property var selectedOrder: root.plane.selectedOrder || ({})
    readonly property string selectedOrderId: String(root.plane.selectedOrderId || "")
    readonly property var selectedAssignment: root.selectedOrder.assignmentDefinition || ({})
    readonly property var selectedProduction: root.selectedAssignment.production_control
        || root.selectedAssignment.productionControl || ({})
    readonly property var selectedDelivery: root.selectedAssignment.delivery || ({})

    function categoryFor(status) {
        switch (String(status || "").toLowerCase()) {
        case "queued": return "waiting"
        case "starting": return "production"
        case "dispatching": return "production"
        case "running": return "production"
        case "pausing": return "production"
        case "paused": return "production"
        case "succeeded": return "ready"
        case "completed": return "ready"
        case "needs_attention": return "post"
        case "failed": return "post"
        default: return "waiting"
        }
    }

    function orderMatches(row) {
        const assignment = row.assignmentDefinition || ({})
        const production = assignment.production_control || assignment.productionControl || ({})
        const delivery = assignment.delivery || ({})
        const workflow = String(row.workflow || production.workflow || "").toLowerCase()
        const channel = String(row.channelId || delivery.channel_id || delivery.channelId || "")
        const category = root.categoryFor(row.status)
        if (root.workflowFilter && workflow !== root.workflowFilter)
            return false
        if (root.channelFilter && channel !== root.channelFilter)
            return false
        if (root.activityFilter && category !== root.activityFilter)
            return false
        if (!root.query)
            return true
        const haystack = (String(row.title || "") + " "
            + String(row.orderId || "") + " "
            + String(row.currentStepTitle || "")).toLowerCase()
        return haystack.indexOf(root.query) >= 0
    }

    function categoryCount(category) {
        const revision = root.modelRevision
        const model = root.plane.orderModel
        if (!model)
            return 0
        let count = 0
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const row = model.get(index) || ({})
            if (root.categoryFor(row.status) === category && root.orderMatches(row))
                count += 1
        }
        return count
    }

    function failureCount() {
        const revision = root.modelRevision
        const model = root.plane.orderModel
        if (!model)
            return 0
        let count = 0
        for (let index = 0; index < Number(model.count || 0); ++index) {
            if (String((model.get(index) || ({})).status || "") === "failed")
                count += 1
        }
        return count
    }

    function selectedWorkflow() {
        const model = root.plane.stepModel
        if (!model)
            return ""
        let fallback = ""
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const row = model.get(index) || ({})
            const workflow = String(row.workflow || "")
            if (workflow && !fallback)
                fallback = workflow
            if (Boolean(row.active) || ["running", "dispatching"].indexOf(String(row.status || "")) >= 0)
                return workflow
        }
        return fallback
    }

    function selectedStepSummary() {
        const model = root.plane.stepModel
        if (!model || Number(model.count || 0) === 0)
            return qsTr("Chưa có bước thực thi")
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const row = model.get(index) || ({})
            if (Boolean(row.active) || ["running", "dispatching", "needs_attention"].indexOf(String(row.status || "")) >= 0)
                return String(row.title || row.statusLabel || qsTr("Đang xử lý"))
        }
        return String((model.get(Number(model.count || 0) - 1) || {}).title || qsTr("Đã cập nhật"))
    }

    Connections {
        target: root.plane.orderModel
        function onModelReset() { root.modelRevision++ }
        function onDataChanged() { root.modelRevision++ }
        function onCountChanged() { root.modelRevision++ }
    }

    component MetaText: Text {
        color: CenterTokens.muted
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.metadata + 1
        elide: Text.ElideRight
    }

    component ProgressLane: CenterPanel {
        id: lane
        required property var sourceModel
        required property string category
        required property string title
        required property string iconName
        required property color tone
        property int revision: 0
        signal orderSelected(string orderId)
        signal workflowOpened(string workflow)

        function countRows() {
            const update = lane.revision
            let count = 0
            for (let index = 0; index < Number(lane.sourceModel.count || 0); ++index) {
                const row = lane.sourceModel.get(index) || ({})
                if (root.categoryFor(row.status) === lane.category && root.orderMatches(row))
                    ++count
            }
            return count
        }

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: 0
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8
            RowLayout {
                Layout.fillWidth: true
                UiIcon {
                    name: lane.iconName
                    tone: lane.tone
                    iconSize: 17
                    Layout.preferredWidth: 17
                    Layout.preferredHeight: 17
                }
                Text {
                    Layout.fillWidth: true
                    text: lane.title
                    color: lane.tone
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.sectionTitle
                    font.weight: Font.DemiBold
                }
                Text {
                    text: String(lane.countRows())
                    color: CenterTokens.text
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.body
                    font.weight: Font.Bold
                }
            }
            ListView {
                id: laneList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: lane.sourceModel
                readonly property int cardGap: 7
                spacing: 0
                clip: true
                reuseItems: true
                boundsBehavior: Flickable.StopAtBounds
                delegate: Item {
                    id: orderItem
                    required property var modelData
                    readonly property bool matches: root.categoryFor(modelData.status) === lane.category
                        && root.orderMatches(modelData)
                    width: ListView.view.width
                    height: matches ? orderCard.implicitHeight + laneList.cardGap : 0
                    visible: matches
                    Rectangle {
                        id: orderCard
                        width: parent.width
                        implicitHeight: lane.category === "waiting" ? 78
                            : lane.category === "ready" ? 102 : 88
                        height: implicitHeight
                        radius: CenterTokens.radiusSmall
                        color: root.selectedOrderId === String(orderItem.modelData.orderId || "")
                            ? CenterTokens.primarySoft : CenterTokens.panel
                        border.width: 1
                        border.color: root.selectedOrderId === String(orderItem.modelData.orderId || "")
                            ? CenterTokens.primary : CenterTokens.border
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 7
                            spacing: 3
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 7
                                UiIcon {
                                    name: String(orderItem.modelData.status || "") === "needs_attention"
                                        ? "semantic/alert-triangle" : "ui/file-text"
                                    tone: Fmt.statusKind(orderItem.modelData.status) === "danger"
                                        ? CenterTokens.danger
                                        : Fmt.statusKind(orderItem.modelData.status) === "warning"
                                        ? CenterTokens.warning : CenterTokens.primary
                                    iconSize: 14
                                    Layout.preferredWidth: 14
                                    Layout.preferredHeight: 14
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(orderItem.modelData.title || qsTr("Work order"))
                                    color: CenterTokens.text
                                    font.family: CenterTokens.fontFamily
                                    font.pixelSize: CenterTokens.body
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                CenterStatusBadge {
                                    text: Fmt.statusLabel(orderItem.modelData.status,
                                        orderItem.modelData.statusLabel)
                                    status: Fmt.statusKind(orderItem.modelData.status)
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                CenterStatusBadge {
                                    text: Fmt.workflowLabel(
                                        (orderItem.modelData.assignmentDefinition || {}).production_control?.workflow
                                        || orderItem.modelData.workflow || "workflow")
                                    status: "info"
                                }
                                MetaText {
                                    Layout.fillWidth: true
                                    text: String(orderItem.modelData.currentStepTitle || qsTr("Chờ coordinator"))
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                visible: lane.category !== "waiting"
                                spacing: 7
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 4
                                    radius: 2
                                    color: CenterTokens.border
                                    Rectangle {
                                        width: parent.width * Math.max(0, Math.min(100,
                                            Number(orderItem.modelData.progress || 0))) / 100
                                        height: parent.height
                                        radius: 2
                                        color: CenterTokens.primary
                                    }
                                }
                                MetaText {
                                    text: String(Math.round(Number(orderItem.modelData.progress || 0))) + "%"
                                }
                                AppButton {
                                    Layout.preferredHeight: 24
                                    text: qsTr("Mở")
                                    subtle: true
                                    leftPadding: 7
                                    rightPadding: 7
                                    onClicked: lane.orderSelected(String(orderItem.modelData.orderId || ""))
                                }
                            }
                        }
                        TapHandler { onTapped: lane.orderSelected(String(orderItem.modelData.orderId || "")) }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    visible: lane.countRows() === 0
                    text: qsTr("Không có job")
                    color: CenterTokens.faint
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.body
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: CenterTokens.pageGutter
        anchors.rightMargin: CenterTokens.pageGutter
        anchors.topMargin: 14
        anchors.bottomMargin: 0
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            spacing: 10
            ColumnLayout {
                Layout.minimumWidth: 0
                Layout.preferredWidth: root.compactLayout ? 285 : 360
                spacing: 3
                Text {
                    text: qsTr("Tiến trình")
                    color: CenterTokens.text
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.pageTitle
                    font.weight: Font.Bold
                }
                Text {
                    Layout.fillWidth: true
                    text: qsTr("Theo dõi trạng thái thật của mọi job đang chạy trong các tab Tool 1.")
                    color: CenterTokens.muted
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.body
                    elide: Text.ElideRight
                }
            }
            Item { Layout.fillWidth: true }
            CenterSearchField {
                Layout.preferredWidth: root.compactLayout ? 170 : 210
                placeholderText: qsTr("Tìm job, kênh...")
                onQueryCommitted: query => root.query = query.toLowerCase()
            }
            AppComboBox {
                objectName: "progressWorkflowFilter"
                Layout.preferredWidth: root.compactLayout ? 135 : 160
                Layout.preferredHeight: CenterTokens.controlHeight
                model: [
                    {"text": qsTr("Tất cả workflow"), "value": ""},
                    {"text": "Master Prompt", "value": "master"},
                    {"text": "Clone Video", "value": "clone"},
                    {"text": "Audio to Video", "value": "transcript"},
                    {"text": "Affiliate", "value": "affiliate"},
                    {"text": "Time Machine", "value": "timemachine"}
                ]
                textRole: "text"
                valueRole: "value"
                onActivated: root.workflowFilter = String(currentValue || "")
            }
            AppComboBox {
                objectName: "progressChannelFilter"
                Layout.preferredWidth: 160
                Layout.preferredHeight: CenterTokens.controlHeight
                model: root.plane.profileModel
                textRole: "label"
                currentIndex: -1
                displayText: currentIndex < 0 ? qsTr("Tất cả kênh") : currentText
                visible: !root.compactLayout
                onActivated: root.channelFilter = String((model.get(currentIndex) || ({})).channelId || "")
            }
            AppComboBox {
                objectName: "progressActivityFilter"
                Layout.preferredWidth: root.compactLayout ? 125 : 145
                Layout.preferredHeight: CenterTokens.controlHeight
                model: [
                    {"text": qsTr("Đang hoạt động"), "value": ""},
                    {"text": qsTr("Đang chờ"), "value": "waiting"},
                    {"text": qsTr("Đang sản xuất"), "value": "production"},
                    {"text": qsTr("Hậu xử lý"), "value": "post"},
                    {"text": qsTr("Chờ đăng"), "value": "ready"}
                ]
                textRole: "text"
                valueRole: "value"
                onActivated: root.activityFilter = String(currentValue || "")
            }
            CenterStatusBadge {
                Layout.preferredWidth: root.compactLayout ? 96 : 105
                text: String(root.categoryCount("production") + root.categoryCount("post")) + qsTr(" đang chạy")
                status: "info"
                iconName: "semantic/workflow"
            }
            CenterStatusBadge {
                Layout.preferredWidth: 75
                text: String(root.categoryCount("waiting")) + qsTr(" chờ")
                status: root.categoryCount("waiting") > 0 ? "warning" : "success"
                iconName: "ui/timer"
                visible: !root.compactLayout
            }
            CenterStatusBadge {
                Layout.preferredWidth: 65
                text: String(root.failureCount()) + qsTr(" lỗi")
                status: root.failureCount() > 0 ? "danger" : "success"
                iconName: "semantic/alert-circle"
                visible: !root.compactLayout
            }
            AppButton {
                text: qsTr("Làm mới")
                leadingIcon: "ui/refresh-cw"
                primary: true
                enabled: !root.plane.actionBusy
                onClicked: root.plane.refresh()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            ProgressLane {
                sourceModel: root.plane.orderModel
                category: "waiting"
                title: qsTr("Đang chờ")
                iconName: "ui/timer"
                tone: CenterTokens.warning
                revision: root.modelRevision
                onOrderSelected: orderId => root.plane.selectOrder(orderId)
            }
            ProgressLane {
                sourceModel: root.plane.orderModel
                category: "production"
                title: qsTr("Đang sản xuất")
                iconName: "ui/play"
                tone: CenterTokens.primary
                revision: root.modelRevision
                onOrderSelected: orderId => root.plane.selectOrder(orderId)
            }
            ProgressLane {
                sourceModel: root.plane.orderModel
                category: "post"
                title: qsTr("Hậu xử lý")
                iconName: "semantic/workflow"
                tone: CenterTokens.violet
                revision: root.modelRevision
                onOrderSelected: orderId => root.plane.selectOrder(orderId)
            }
            ProgressLane {
                sourceModel: root.plane.orderModel
                category: "ready"
                title: qsTr("Chờ đăng")
                iconName: "semantic/check-circle"
                tone: CenterTokens.success
                revision: root.modelRevision
                onOrderSelected: orderId => root.plane.selectOrder(orderId)
            }
        }

        CenterPanel {
            id: detailDrawer
            objectName: "progressSelectedOrderDrawer"
            Layout.fillWidth: true
            Layout.preferredHeight: root.selectedOrderId ? 105 : 0
            visible: root.selectedOrderId.length > 0
            clip: true
            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                spacing: 7
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    UiIcon {
                        name: "ui/chevron-up"
                        tone: CenterTokens.muted
                        iconSize: 14
                        Layout.preferredWidth: 14
                        Layout.preferredHeight: 14
                    }
                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Job #") + Fmt.compactId(root.selectedOrderId)
                            + " · " + String(root.selectedOrder.title || qsTr("Work order"))
                        color: CenterTokens.text
                        font.family: CenterTokens.fontFamily
                        font.pixelSize: CenterTokens.body
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    MetaText {
                        text: qsTr("Assignment v%1").arg(
                            String(root.selectedOrder.definitionVersion || 1))
                        color: CenterTokens.success
                    }
                    UiIcon {
                        name: "ui/chevron-right"
                        tone: CenterTokens.faint
                        iconSize: 12
                        Layout.preferredWidth: 12
                        Layout.preferredHeight: 12
                    }
                    CenterStatusBadge {
                        text: Fmt.workflowLabel(root.selectedProduction.workflow
                            || root.selectedWorkflow())
                        status: Fmt.workflowTone(root.selectedProduction.workflow
                            || root.selectedWorkflow())
                    }
                    UiIcon {
                        name: "ui/chevron-right"
                        tone: CenterTokens.faint
                        iconSize: 12
                        Layout.preferredWidth: 12
                        Layout.preferredHeight: 12
                    }
                    MetaText {
                        Layout.preferredWidth: 190
                        text: root.selectedStepSummary()
                        color: CenterTokens.primary
                    }
                    CenterStatusBadge {
                        text: Fmt.statusLabel(root.selectedOrder.status, root.selectedOrder.statusLabel)
                        status: Fmt.statusKind(root.selectedOrder.status)
                        iconName: Fmt.statusKind(root.selectedOrder.status) === "success"
                            ? "semantic/check-circle" : ""
                    }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: CenterTokens.border }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 18
                    ColumnLayout {
                        Layout.preferredWidth: 120
                        MetaText { text: qsTr("ID nội bộ") }
                        Text {
                            text: Fmt.compactId(root.selectedOrderId)
                            color: CenterTokens.text
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                        }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 130
                        MetaText { text: qsTr("Bắt đầu") }
                        Text {
                            text: Fmt.timeLabel(root.selectedOrder.createdAt)
                            color: CenterTokens.text
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                        }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 155
                        MetaText { text: qsTr("Cấu hình") }
                        Text {
                            text: "v" + String(root.selectedOrder.definitionVersion || 2)
                                + " · " + Fmt.compactId(root.selectedOrder.definitionHash)
                            color: CenterTokens.text
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                        }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 170
                        MetaText { text: qsTr("Đích đăng") }
                        Text {
                            text: String(root.selectedDelivery.channel_id
                                || root.selectedDelivery.channelId
                                || root.selectedDelivery.profile_id
                                || root.selectedDelivery.profileId || qsTr("Chưa gán"))
                            color: CenterTokens.text
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                            elide: Text.ElideRight
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        MetaText { text: qsTr("Bước hiện tại") }
                        Text {
                            Layout.fillWidth: true
                            text: root.selectedStepSummary()
                            color: CenterTokens.text
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                            elide: Text.ElideRight
                        }
                    }
                    AppButton {
                        text: qsTr("Mở tab gốc")
                        leadingIcon: "ui/external-link"
                        enabled: root.selectedWorkflow().length > 0
                        onClicked: root.openWorkflowRequested(root.selectedWorkflow())
                    }
                    AppButton {
                        text: String(root.selectedOrder.status || "") === "paused"
                            ? qsTr("Tiếp tục") : qsTr("Tạm dừng")
                        leadingIcon: String(root.selectedOrder.status || "") === "paused"
                            ? "ui/play" : "ui/pause"
                        enabled: ["running", "paused"].indexOf(String(root.selectedOrder.status || "")) >= 0
                        onClicked: root.plane.callTool(
                            String(root.selectedOrder.status || "") === "paused"
                                ? "tool1.order.resume" : "tool1.order.pause",
                            {"order_id": root.selectedOrderId})
                    }
                    AppButton {
                        text: qsTr("Yêu cầu dừng")
                        leadingIcon: "ui/close"
                        enabled: ["running", "queued", "paused"].indexOf(String(root.selectedOrder.status || "")) >= 0
                        onClicked: root.plane.callTool("tool1.order.cancel", {
                            "order_id": root.selectedOrderId
                        })
                    }
                }
            }
        }
    }
}
