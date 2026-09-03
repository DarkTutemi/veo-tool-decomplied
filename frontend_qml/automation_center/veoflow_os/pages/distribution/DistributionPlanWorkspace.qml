pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Item {
    id: root
    objectName: "distributionPlanWorkspace"
    Accessible.name: "Kế hoạch phân phối"
    Accessible.role: Accessible.Pane

    property var distribution: ({})
    property var activity: ({})
    property var runtime: ({})

    signal planSelected(var plan)
    signal createRequested()
    signal editRequested(var plan)
    signal deepLinkRequested(var link)

    readonly property var summary: root.map(root.distribution.summary)
    readonly property var plans: root.map(root.map(root.distribution).plans)
    readonly property var planItems: root.list(root.plans.items)
    readonly property var selectedPlan: root.map(root.plans.selected)
    readonly property var exceptions: root.list(root.map(root.activity).exceptions)
    readonly property var executors: root.list(root.distribution.executors)

    function present(value) {
        return value !== null && value !== undefined
    }

    function map(value) {
        return root.present(value) ? value : ({})
    }

    function list(value) {
        return root.present(value) ? value : []
    }

    function platformLabel(platform) {
        const key = String(platform || "").toLowerCase()
        if (key === "youtube") return "YouTube"
        if (key === "facebook") return "Facebook"
        if (key === "tiktok") return "TikTok"
        if (key === "instagram") return "Instagram"
        if (key === "linkedin") return "LinkedIn"
        if (key === "x") return "X"
        return key || "Kênh"
    }

    function executorLabel(executor) {
        const value = root.map(executor)
        if (String(value.mode) === "browser")
            return value.state === "ready" ? "Browser sẵn sàng" : "Browser chưa sẵn sàng"
        if (String(value.mode) === "phone_farm")
            return value.state === "ready" ? "Điện thoại sẵn sàng" : "Điện thoại chưa sẵn sàng"
        return "Chưa gán cách đăng"
    }

    function inventoryLabel(inventory) {
        const value = root.map(inventory)
        const available = Number(value.available || 0)
        const reserved = Number(value.reserved || 0)
        if (available > 0)
            return available + " video chưa xếp lịch"
        if (reserved > 0)
            return reserved + " video đã nằm trong lịch"
        return "Chưa có video sẵn sàng"
    }

    function slotStateLabel(value) {
        const state = String(value || "").toLowerCase()
        if (state === "approved") return "Đã duyệt"
        if (state === "scheduled") return "Đã xếp lịch"
        if (state === "ready") return "Sẵn sàng"
        if (state === "queued") return "Trong hàng đợi"
        if (state === "publishing" || state === "running") return "Đang đăng"
        if (state === "published" || state === "succeeded") return "Đã đăng"
        if (state === "failed" || state === "blocked") return "Cần xử lý"
        return "Đã xếp lịch"
    }

    component MetricCard: Rectangle {
        id: metric
        required property string metricKey
        required property string label
        required property string value
        required property string iconName
        required property color tone
        objectName: "distributionMetric_" + metricKey
        Layout.fillWidth: true
        Layout.preferredHeight: 70
        radius: Theme.radiusMedium
        color: Theme.panel
        border.width: 1
        border.color: Theme.borderSoft

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.space3
            spacing: Theme.space3
            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: 10
                color: Theme.elevated
                UiIcon {
                    anchors.centerIn: parent
                    name: metric.iconName
                    tone: metric.tone
                    iconSize: 19
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Text {
                    text: metric.value
                    color: Theme.text
                    font.pixelSize: 19
                    font.weight: Font.Bold
                }
                Text {
                    Layout.fillWidth: true
                    text: metric.label
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontMetadata
                    elide: Text.ElideRight
                }
            }
        }
    }

    component FlowCard: Rectangle {
        id: card
        required property string cardKey
        required property string eyebrow
        required property string title
        required property string detail
        required property string iconName
        required property color tone
        objectName: "distributionFlow_" + cardKey
        Layout.fillWidth: true
        Layout.preferredHeight: 126
        radius: Theme.radiusLarge
        color: Theme.elevated
        border.width: 1
        border.color: tone

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.space4
            spacing: 6
            RowLayout {
                Layout.fillWidth: true
                UiIcon { name: card.iconName; tone: card.tone; iconSize: 18 }
                Text {
                    Layout.fillWidth: true
                    text: card.eyebrow.toUpperCase()
                    color: card.tone
                    font.pixelSize: Theme.fontMetadata
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.6
                }
            }
            Text {
                Layout.fillWidth: true
                text: card.title
                color: Theme.text
                font.pixelSize: Theme.fontSection
                font.weight: Font.Bold
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: card.detail
                color: Theme.textMuted
                font.pixelSize: Theme.fontMetadata
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space3

        RowLayout {
            objectName: "distributionSummaryRow"
            Layout.fillWidth: true
            spacing: Theme.space3

            MetricCard {
                metricKey: "active_plans"
                label: "Kế hoạch đang chạy"
                value: String(Number(root.summary.active_plans || 0))
                iconName: "semantic/workflow"
                tone: Theme.accent
            }
            MetricCard {
                metricKey: "target_channels"
                label: "Kênh đang nhận video"
                value: String(Number(root.summary.target_channels || 0))
                iconName: "semantic/channels"
                tone: Theme.info
            }
            MetricCard {
                metricKey: "ready_videos"
                label: "Video chưa xếp lịch"
                value: String(Number(root.summary.ready_videos || 0))
                iconName: "semantic/video"
                tone: Theme.success
            }
            MetricCard {
                metricKey: "next_24h"
                label: "Lượt đăng trong 24 giờ"
                value: String(Number(root.summary.next_24h || 0))
                iconName: "ui/calendar"
                tone: Theme.info
            }
            MetricCard {
                metricKey: "attention"
                label: "Cần bạn xử lý"
                value: String(Number(root.summary.attention || 0))
                iconName: "semantic/alert-triangle"
                tone: Number(root.summary.attention || 0) > 0 ? Theme.warning : Theme.success
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.space3

            Panel {
                objectName: "distributionPlanRail"
                Layout.preferredWidth: 292
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.space3
                    spacing: Theme.space3
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Kế hoạch phân phối"
                                color: Theme.text
                                font.pixelSize: Theme.fontSection
                                font.weight: Font.Bold
                            }
                            Text {
                                text: "Mỗi kế hoạch trả lời 4 câu: video nào, kênh nào, khi nào, duyệt ra sao."
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontMetadata
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    AppButton {
                        objectName: "distributionNewPlanButton"
                        Layout.fillWidth: true
                        text: "Kế hoạch mới"
                        leadingIcon: "ui/plus"
                        primary: true
                        enabled: root.map(root.map(root.plans.actions).create).available === true
                        availabilityReason: String(root.map(root.map(root.plans.actions).create).reason_code || "")
                        onClicked: root.createRequested()
                    }

                    ListView {
                        id: planList
                        objectName: "distributionPlanList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 7
                        boundsBehavior: Flickable.StopAtBounds
                        ScrollBar.vertical: ScrollBar {}
                        model: root.planItems

                        delegate: Rectangle {
                            id: planRow
                            required property var modelData
                            required property int index
                            readonly property bool selected: String(root.selectedPlan.plan_key || "")
                                === String(modelData.plan_key || "")
                            objectName: "distributionPlanRow_" + String(modelData.plan_key || index)
                            width: planList.width
                            height: 94
                            radius: Theme.radiusMedium
                            color: selected ? Theme.accentSoft : (planMouse.containsMouse ? Theme.hover : Theme.elevated)
                            border.width: 1
                            border.color: selected ? Theme.accent : Theme.borderSoft
                            activeFocusOnTab: true
                            Accessible.role: Accessible.Button
                            Accessible.name: String(modelData.name || "Kế hoạch phân phối")
                            Keys.onReturnPressed: root.planSelected(modelData)
                            Keys.onSpacePressed: root.planSelected(modelData)
                            MouseArea {
                                id: planMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.planSelected(planRow.modelData)
                            }
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 11
                                spacing: 5
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(planRow.modelData.name || "Kế hoạch")
                                        color: Theme.text
                                        font.pixelSize: Theme.fontBody
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    Rectangle {
                                        Layout.preferredWidth: 8
                                        Layout.preferredHeight: 8
                                        radius: 4
                                        color: planRow.modelData.enabled === true ? Theme.success : Theme.textFaint
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: Number(root.map(planRow.modelData.targets).channel_count || 0)
                                        + " kênh · mỗi "
                                        + Number(root.map(planRow.modelData.cadence).interval_minutes || 0)
                                        + " phút"
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.fontMetadata
                                    elide: Text.ElideRight
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        Layout.fillWidth: true
                                        text: root.inventoryLabel(root.map(planRow.modelData.source).inventory)
                                        color: root.map(root.map(planRow.modelData.source).inventory).state === "ready"
                                            ? Theme.success : Theme.warning
                                        font.pixelSize: Theme.fontMetadata
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: Number(root.map(planRow.modelData.approval).pending || 0) > 0
                                            ? Number(root.map(planRow.modelData.approval).pending) + " chờ duyệt" : ""
                                        color: Theme.warning
                                        font.pixelSize: Theme.fontMetadata
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Panel {
                objectName: "distributionPlanDetail"
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.space4
                    spacing: Theme.space3

                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: String(root.selectedPlan.name || "Chọn một kế hoạch")
                                color: Theme.text
                                font.pixelSize: Theme.fontSection
                                font.weight: Font.Bold
                            }
                            Text {
                                Layout.fillWidth: true
                                text: root.selectedPlan.plan_key
                                    ? "Video được lấy theo nguồn đã chọn, phân bổ sang từng kênh và luôn chờ duyệt trước khi đăng."
                                    : "Tạo kế hoạch đầu tiên để hệ thống bắt đầu xếp video vào lịch."
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontMetadata
                                elide: Text.ElideRight
                            }
                        }
                        AppButton {
                            objectName: "distributionEditPlanButton"
                            text: "Chỉnh kế hoạch"
                            leadingIcon: "semantic/workflow"
                            enabled: root.selectedPlan.plan_key !== undefined
                                && root.map(root.map(root.selectedPlan.actions).revise).available === true
                            availabilityReason: String(root.map(root.map(root.map(root.selectedPlan.actions).revise)).reason_code || "")
                            onClicked: root.editRequested(root.selectedPlan)
                        }
                    }

                    RowLayout {
                        objectName: "distributionFlow"
                        Layout.fillWidth: true
                        spacing: Theme.space2
                        FlowCard {
                            cardKey: "source"
                            eyebrow: "1 · Nguồn video"
                            title: String(root.map(root.selectedPlan.source).label || "Chưa chọn nguồn")
                            detail: root.inventoryLabel(root.map(root.map(root.selectedPlan.source).inventory))
                            iconName: "semantic/video"
                            tone: root.map(root.map(root.selectedPlan.source).inventory).state === "ready"
                                ? Theme.success : Theme.warning
                        }
                        UiIcon { name: "ui/chevron-right"; tone: Theme.textFaint; iconSize: 20 }
                        FlowCard {
                            cardKey: "targets"
                            eyebrow: "2 · Kênh nhận"
                            title: Number(root.map(root.selectedPlan.targets).channel_count || 0) + " kênh"
                            detail: root.list(root.map(root.selectedPlan.targets).platforms)
                                .map(function(item) { return root.platformLabel(item) }).join(" · ") || "Chưa chọn kênh"
                            iconName: "semantic/channels"
                            tone: Theme.info
                        }
                        UiIcon { name: "ui/chevron-right"; tone: Theme.textFaint; iconSize: 20 }
                        FlowCard {
                            cardKey: "cadence"
                            eyebrow: "3 · Nhịp đăng"
                            title: "Mỗi " + Number(root.map(root.selectedPlan.cadence).interval_minutes || 0) + " phút"
                            detail: String(root.map(root.selectedPlan.cadence).window_start || "—")
                                + "–" + String(root.map(root.selectedPlan.cadence).window_end || "—")
                                + " · tối đa " + Number(root.map(root.selectedPlan.cadence).daily_cap || 0) + "/ngày"
                            iconName: "ui/calendar"
                            tone: Theme.accent
                        }
                    }

                    Rectangle {
                        objectName: "distributionApprovalGuardrail"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        radius: Theme.radiusMedium
                        color: Theme.warningSoft
                        border.width: 1
                        border.color: Theme.warning
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.space3
                            UiIcon { name: "semantic/shield-check"; tone: Theme.warning; iconSize: 18 }
                            Text {
                                Layout.fillWidth: true
                                text: "Mọi lượt đăng đều cần bạn duyệt. Nếu nền tảng không trả kết quả chắc chắn, hệ thống dừng để xác minh thay vì đăng lại mù."
                                color: Theme.text
                                font.pixelSize: Theme.fontMetadata
                                elide: Text.ElideRight
                            }
                            Text {
                                objectName: "distributionOutcomeEvidenceText"
                                text: Number(root.map(root.selectedPlan.outcomes).published || 0)
                                    + " đã đăng · "
                                    + Number(root.map(root.selectedPlan.outcomes).evidence_verified || 0)
                                    + " có bằng chứng"
                                color: Theme.success
                                font.pixelSize: Theme.fontMetadata
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: Number(root.map(root.selectedPlan.approval).pending || 0) + " đang chờ duyệt"
                                color: Theme.warning
                                font.pixelSize: Theme.fontMetadata
                                font.weight: Font.DemiBold
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: "Các lượt đăng sắp tới"
                            color: Theme.text
                            font.pixelSize: Theme.fontBody
                            font.weight: Font.Bold
                        }
                        Text {
                            text: String(root.list(root.selectedPlan.next_slots).length) + " lượt"
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontMetadata
                        }
                    }

                    ListView {
                        id: slotList
                        objectName: "distributionNextSlotList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: root.list(root.selectedPlan.next_slots)
                        clip: true
                        spacing: 6
                        boundsBehavior: Flickable.StopAtBounds
                        ScrollBar.vertical: ScrollBar {}
                        delegate: Rectangle {
                            id: slotRow
                            required property var modelData
                            required property int index
                            objectName: "distributionNextSlot_" + String(modelData.schedule_id || index)
                            width: slotList.width
                            height: 58
                            activeFocusOnTab: true
                            radius: Theme.radiusMedium
                            color: Theme.elevated
                            border.width: 1
                            border.color: Theme.borderSoft
                            Accessible.role: Accessible.Button
                            Accessible.name: String(modelData.content_title || "Video")
                                + " · " + String(modelData.channel_name || "Kênh")
                                + " · " + String(modelData.local_time || "")
                            Keys.onReturnPressed: root.deepLinkRequested(root.map(modelData.deep_link))
                            Keys.onSpacePressed: root.deepLinkRequested(root.map(modelData.deep_link))
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: Theme.space3
                                Item {
                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24
                                    SocialIcon {
                                        anchors.fill: parent
                                        platform: String(slotRow.modelData.platform || "")
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(slotRow.modelData.content_title || "Video")
                                        color: Theme.text
                                        font.pixelSize: Theme.fontBody
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(slotRow.modelData.channel_name || "Kênh")
                                            + " · " + String(slotRow.modelData.local_time || "—")
                                        color: Theme.textMuted
                                        font.pixelSize: Theme.fontMetadata
                                        elide: Text.ElideRight
                                    }
                                }
                                Text {
                                    objectName: "distributionNextSlotState_"
                                        + String(slotRow.modelData.schedule_id || slotRow.index)
                                    text: slotRow.modelData.approval_state === "pending"
                                        ? "Chờ duyệt" : root.slotStateLabel(slotRow.modelData.state)
                                    color: slotRow.modelData.approval_state === "pending"
                                        ? Theme.warning : Theme.info
                                    font.pixelSize: Theme.fontMetadata
                                    font.weight: Font.DemiBold
                                }
                                UiIcon { name: "ui/chevron-right"; tone: Theme.textFaint; iconSize: 14 }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.deepLinkRequested(root.map(slotRow.modelData.deep_link))
                            }
                        }
                    }

                    Rectangle {
                        visible: root.list(root.selectedPlan.next_slots).length === 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Theme.radiusMedium
                        color: Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft
                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            UiIcon { anchors.horizontalCenter: parent.horizontalCenter; name: "ui/calendar"; tone: Theme.textFaint; iconSize: 28 }
                            Text { text: "Chưa có lượt đăng"; color: Theme.text; font.pixelSize: Theme.fontBody; font.weight: Font.DemiBold }
                            Text { text: "Kiểm tra nguồn video và kênh của kế hoạch."; color: Theme.textMuted; font.pixelSize: Theme.fontMetadata }
                        }
                    }
                }
            }

            Panel {
                objectName: "distributionReadinessRail"
                Layout.preferredWidth: 310
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.space3
                    spacing: Theme.space3
                    Text {
                        text: "Kênh & cách đăng"
                        color: Theme.text
                        font.pixelSize: Theme.fontSection
                        font.weight: Font.Bold
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Chỉ kênh có cách đăng đã kết nối mới được chạy. Điện thoại và API chưa nối sẽ không được báo thành công."
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                        wrapMode: Text.WordWrap
                    }
                    ListView {
                        id: executorList
                        objectName: "distributionChannelExecutorList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: root.list(root.map(root.selectedPlan.targets).channels)
                        clip: true
                        spacing: 7
                        boundsBehavior: Flickable.StopAtBounds
                        ScrollBar.vertical: ScrollBar {}
                        delegate: Rectangle {
                            id: executorRow
                            required property var modelData
                            required property int index
                            objectName: "distributionChannelExecutor_" + String(modelData.id || index)
                            width: executorList.width
                            height: 68
                            radius: Theme.radiusMedium
                            color: Theme.elevated
                            border.width: 1
                            border.color: root.map(modelData.executor).state === "ready"
                                ? Theme.success : Theme.warning
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                Item {
                                    Layout.preferredWidth: 26
                                    Layout.preferredHeight: 26
                                    SocialIcon { anchors.fill: parent; platform: String(executorRow.modelData.platform || "") }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(executorRow.modelData.name || "Kênh")
                                        color: Theme.text
                                        font.pixelSize: Theme.fontBody
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: root.executorLabel(executorRow.modelData.executor)
                                        color: root.map(executorRow.modelData.executor).state === "ready"
                                            ? Theme.success : Theme.warning
                                        font.pixelSize: Theme.fontMetadata
                                        elide: Text.ElideRight
                                    }
                                }
                                AppButton {
                                    objectName: "distributionOpenChannel_" + String(executorRow.modelData.id || executorRow.index)
                                    implicitWidth: 60
                                    leftPadding: 9
                                    rightPadding: 9
                                    leadingIcon: "ui/external-link"
                                    text: "Mở"
                                    Accessible.name: "Mở kênh " + String(executorRow.modelData.name || "")
                                    onClicked: root.deepLinkRequested(root.map(executorRow.modelData.deep_link))
                                }
                            }
                        }
                    }

                    Rectangle {
                        objectName: "distributionExecutorTruth"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 132
                        radius: Theme.radiusMedium
                        color: Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 4
                            Text {
                                objectName: "distributionCareCadenceText"
                                Layout.fillWidth: true
                                text: "Sau đăng: bình luận + số liệu mỗi "
                                    + Number(root.map(root.selectedPlan.care).scan_interval_minutes || 0)
                                    + " phút"
                                color: Theme.text
                                font.pixelSize: Theme.fontMetadata
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Repeater {
                                model: root.executors
                                delegate: RowLayout {
                                    id: executorMode
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Rectangle {
                                        Layout.preferredWidth: 7
                                        Layout.preferredHeight: 7
                                        radius: 4
                                        color: executorMode.modelData.state === "enabled"
                                            ? Theme.success : Theme.textFaint
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(executorMode.modelData.label || "Cách đăng")
                                        color: Theme.textMuted
                                        font.pixelSize: Theme.fontMetadata
                                    }
                                    Text {
                                        text: executorMode.modelData.state === "enabled" ? "Đã bật" : "Chưa nối"
                                        color: executorMode.modelData.state === "enabled"
                                            ? Theme.success : Theme.textFaint
                                        font.pixelSize: Theme.fontMetadata
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
