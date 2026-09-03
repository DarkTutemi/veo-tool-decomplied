pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "tool1WorkOrdersPanel"

    required property var controlPlaneBridge

    readonly property var orderModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.orderModel : null
    readonly property var stepModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.stepModel : null
    readonly property string selectedOrderId: root.controlPlaneBridge
        ? String(root.controlPlaneBridge.selectedOrderId || "") : ""
    readonly property var selectedOrder: root.controlPlaneBridge
        ? root.controlPlaneBridge.selectedOrder : ({})
    readonly property string selectedStatus: String(
        root.selectedOrder.status || "")
    readonly property bool actionBusy: root.controlPlaneBridge
        ? Boolean(root.controlPlaneBridge.actionBusy) : false
    property string reconciliationStepId: ""
    property string reconciliationPlatform: ""

    clip: true
    Accessible.name: "Điều hành work order nội bộ Tool 1"
    Accessible.role: Accessible.Pane

    function stateTone(state) {
        const value = String(state || "").toLowerCase()
        if (value === "succeeded" || value === "completed")
            return Theme.success
        if (value === "failed" || value === "needs_attention"
                || value === "reconciliation_required")
            return Theme.danger
        if (value === "paused" || value === "retryable")
            return Theme.warning
        if (value === "running" || value === "dispatching"
                || value === "starting")
            return Theme.accent
        return Theme.textFaint
    }

    function gateLabel(gate) {
        const value = String(gate || "")
        if (value === "waiting_artifact") return "Đang chờ video đã xác minh"
        if (value === "scheduled") return "Đang chờ tới lịch đăng"
        if (value === "waiting_approval") return "Đang chờ xác nhận"
        if (value === "ready") return "Sẵn sàng chạy"
        return value
    }

    function platformLabel(platform) {
        const value = String(platform || "").toLowerCase()
        if (value === "youtube") return "YouTube"
        if (value === "facebook") return "Facebook"
        if (value === "tiktok") return "TikTok"
        return value.length ? value : "Nền tảng"
    }

    function selectOrder(orderId) {
        if (root.controlPlaneBridge)
            root.controlPlaneBridge.selectOrder(String(orderId || ""))
    }

    function requestAction(toolName) {
        if (!root.controlPlaneBridge || !root.selectedOrderId.length)
            return
        root.controlPlaneBridge.callTool(toolName, {
            "order_id": root.selectedOrderId
        })
    }

    function resolveAttention(stepId, resolution, evidence) {
        if (!root.controlPlaneBridge || !root.selectedOrderId.length)
            return
        root.controlPlaneBridge.callTool("tool1.order.resolve_attention", {
            "order_id": root.selectedOrderId,
            "step_id": String(stepId || ""),
            "resolution": String(resolution || ""),
            "evidence": evidence || ({})
        })
    }

    function openPublishedEvidence(stepId, platform) {
        root.reconciliationStepId = String(stepId || "")
        root.reconciliationPlatform = String(platform || "")
        postIdInput.clear()
        postUrlInput.clear()
        reconciliationPopup.open()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 66
            Layout.leftMargin: Theme.space4
            Layout.rightMargin: Theme.space3
            spacing: Theme.space3

            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 11
                color: Theme.accentSoft
                UiIcon {
                    anchors.centerIn: parent
                    name: "ui/list"
                    tone: Theme.accent
                    iconSize: 21
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "Đang thực hiện"
                    color: Theme.text
                    font.pixelSize: Theme.fontSection
                    font.weight: Font.DemiBold
                }
                Text {
                    Layout.fillWidth: true
                    text: "Một hàng đợi nội bộ: sản xuất → xác minh artifact → đăng video."
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontMetadata
                    elide: Text.ElideRight
                }
            }
            Foundation.StatusPill {
                text: root.controlPlaneBridge.runActive
                    ? "Tool 1 đang bận" : "Coordinator nội bộ"
                tone: root.controlPlaneBridge.runActive
                    ? Theme.warning : Theme.success
                pulse: root.controlPlaneBridge.runActive
            }
            AppButton {
                objectName: "tool1PublishHistoryButton"
                text: "Lịch sử đăng"
                leadingIcon: "ui/calendar"
                enabled: !root.actionBusy
                onClicked: publishHistoryPopup.open()
            }
            AppButton {
                objectName: "tool1OrdersRefreshButton"
                text: "Làm mới"
                leadingIcon: "ui/refresh-cw"
                enabled: !root.actionBusy
                onClicked: root.controlPlaneBridge.refresh()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Theme.space3
            spacing: Theme.space3

            Rectangle {
                Layout.preferredWidth: 390
                Layout.minimumWidth: 320
                Layout.fillHeight: true
                radius: Theme.radiusMedium
                color: Theme.panel
                border.width: 1
                border.color: Theme.borderSoft

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        Text {
                            Layout.fillWidth: true
                            text: "WORK ORDER"
                            color: Theme.textFaint
                            font.pixelSize: Theme.fontMetadata
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: String(root.orderModel
                                ? root.orderModel.count : 0) + " mục"
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontMetadata
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.borderSoft
                    }

                    ListView {
                        id: orderList
                        objectName: "tool1OrderList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 8
                        spacing: 6
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        reuseItems: true
                        model: root.orderModel

                        delegate: Rectangle {
                            id: orderRow
                            required property var modelData

                            readonly property string orderId: String(
                                orderRow.modelData.orderId || "")
                            readonly property bool selected:
                                root.selectedOrderId === orderRow.orderId

                            objectName: "tool1OrderRow_" + orderId
                            width: orderList.width
                            height: 104
                            radius: Theme.radiusSmall
                            color: selected ? Theme.accentSoft
                                : (orderHover.hovered ? Theme.hover : Theme.panel)
                            border.width: activeFocus || selected ? 1 : 0
                            border.color: Theme.accent
                            activeFocusOnTab: true
                            Accessible.name: String(
                                orderRow.modelData.title || "Work order")
                            Accessible.role: Accessible.Button
                            Keys.onReturnPressed: root.selectOrder(orderRow.orderId)
                            Keys.onEnterPressed: root.selectOrder(orderRow.orderId)
                            Keys.onSpacePressed: root.selectOrder(orderRow.orderId)
                            HoverHandler { id: orderHover }
                            TapHandler {
                                onTapped: root.selectOrder(orderRow.orderId)
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 6
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(orderRow.modelData.title
                                            || "Work order")
                                        color: Theme.text
                                        font.pixelSize: Theme.fontBody
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    Foundation.StatusPill {
                                        text: String(orderRow.modelData.statusLabel
                                            || orderRow.modelData.status || "")
                                        tone: root.stateTone(
                                            orderRow.modelData.status)
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(orderRow.modelData.currentStepTitle
                                        || "Chưa bắt đầu")
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.fontMetadata
                                    elide: Text.ElideRight
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    Foundation.ProgressMeter {
                                        Layout.fillWidth: true
                                        value: Number(orderRow.modelData.progress || 0) / 100
                                        tone: root.stateTone(
                                            orderRow.modelData.status)
                                    }
                                    Text {
                                        text: String(Number(
                                            orderRow.modelData.completedSteps || 0))
                                            + "/" + String(Number(
                                                orderRow.modelData.totalSteps || 0))
                                        color: Theme.textFaint
                                        font.pixelSize: Theme.fontMetadata
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !root.orderModel
                                || Number(root.orderModel.count || 0) === 0
                            width: Math.min(parent.width - 32, 260)
                            text: "Chưa có work order. Tạo việc ở tab Giao việc."
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontBody
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radiusMedium
                color: Theme.panel
                border.width: 1
                border.color: Theme.borderSoft

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 58
                        Layout.leftMargin: 14
                        Layout.rightMargin: 14
                        spacing: 10
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                Layout.fillWidth: true
                                text: root.selectedOrderId.length
                                    ? String(root.selectedOrder.title || "Work order")
                                    : "Chọn một work order"
                                color: Theme.text
                                font.pixelSize: Theme.fontSection
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: root.selectedOrderId.length
                                    ? String(root.selectedOrder.currentStepTitle
                                        || "Đang chờ bước tiếp theo")
                                    : "Xem chuỗi bước, đích đăng và lỗi cần xử lý."
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontMetadata
                                elide: Text.ElideRight
                            }
                        }
                        Foundation.StatusPill {
                            visible: root.selectedOrderId.length > 0
                            text: String(root.selectedOrder.statusLabel
                                || root.selectedStatus)
                            tone: root.stateTone(root.selectedStatus)
                            pulse: root.selectedStatus === "running"
                                || root.selectedStatus === "dispatching"
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.borderSoft
                    }

                    ListView {
                        id: stepList
                        objectName: "tool1StepList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 12
                        spacing: 8
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        reuseItems: true
                        model: root.stepModel

                        delegate: Rectangle {
                            id: stepRow
                            required property var modelData

                            width: stepList.width
                            height: Math.max(70, stepContent.implicitHeight + 22)
                            radius: Theme.radiusSmall
                            color: stepRow.modelData.active
                                ? Theme.accentSoft : Theme.elevated
                            border.width: 1
                            border.color: stepRow.modelData.active
                                ? Theme.accent : Theme.borderSoft
                            Accessible.name: String(stepRow.modelData.title
                                || "Bước automation")
                            Accessible.role: Accessible.Row

                            RowLayout {
                                id: stepContent
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Rectangle {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    radius: 17
                                    color: stepRow.modelData.active
                                        ? Theme.accent : Theme.panel
                                    border.width: 1
                                    border.color: stepRow.modelData.active
                                        ? Theme.accent : Theme.border
                                    Text {
                                        anchors.centerIn: parent
                                        text: String(Number(
                                            stepRow.modelData.position || 0) + 1)
                                        color: stepRow.modelData.active
                                            ? "white" : Theme.textMuted
                                        font.pixelSize: Theme.fontMetadata
                                        font.weight: Font.DemiBold
                                    }
                                }
                                UiIcon {
                                    name: String(stepRow.modelData.kind || "")
                                        === "publish"
                                        ? "semantic/upload-cloud"
                                        : "semantic/workflow"
                                    tone: stepRow.modelData.active
                                        ? Theme.accent : Theme.textMuted
                                    iconSize: 20
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 20
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(stepRow.modelData.title
                                            || stepRow.modelData.workflow
                                            || "Bước automation")
                                        color: Theme.text
                                        font.pixelSize: Theme.fontBody
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        visible: String(
                                            stepRow.modelData.kind || "") === "publish"
                                        Layout.fillWidth: true
                                        text: root.platformLabel(
                                            stepRow.modelData.platform) + " · " + String(
                                            stepRow.modelData.channelId
                                            || stepRow.modelData.profileId
                                            || "chưa gán kênh")
                                            + (String(stepRow.modelData.availableAtUtc
                                                || "").length
                                                ? " · " + new Date(
                                                    stepRow.modelData.availableAtUtc
                                                ).toLocaleString(Qt.locale())
                                                : "")
                                        color: Theme.textMuted
                                        font.pixelSize: Theme.fontMetadata
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        visible: String(stepRow.modelData.gateState
                                            || "").length > 0
                                        Layout.fillWidth: true
                                        text: root.gateLabel(
                                            stepRow.modelData.gateState)
                                        color: Theme.accent
                                        font.pixelSize: Theme.fontMetadata
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        visible: String(stepRow.modelData.errorMessage
                                            || "").length > 0
                                        Layout.fillWidth: true
                                        text: String(stepRow.modelData.errorMessage || "")
                                        color: Theme.danger
                                        font.pixelSize: Theme.fontMetadata
                                        wrapMode: Text.Wrap
                                    }
                                    RowLayout {
                                        visible: String(stepRow.modelData.postUrl || "").length > 0
                                            || String(stepRow.modelData.externalPostId || "").length > 0
                                            || String(stepRow.modelData.evidencePath || "").length > 0
                                        Layout.fillWidth: true
                                        spacing: 8
                                        Image {
                                            visible: String(stepRow.modelData.evidencePath || "").length > 0
                                            Layout.preferredWidth: visible ? 64 : 0
                                            Layout.preferredHeight: visible ? 40 : 0
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            sourceSize.width: 128
                                            sourceSize.height: 80
                                            source: visible
                                                ? root.controlPlaneBridge.authorizedThumbnailUrl(
                                                    "", String(stepRow.modelData.evidencePath || ""))
                                                : ""
                                            Accessible.name: "Ảnh bằng chứng sau đăng"
                                        }
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            Text {
                                                Layout.fillWidth: true
                                                text: String(stepRow.modelData.externalPostId || "").length
                                                    ? "Post ID: " + String(stepRow.modelData.externalPostId)
                                                    : "Đã lưu bằng chứng sau đăng"
                                                color: Theme.success
                                                font.pixelSize: Theme.fontMetadata
                                                elide: Text.ElideMiddle
                                            }
                                            Text {
                                                visible: String(stepRow.modelData.evidenceSha256 || "").length > 0
                                                Layout.fillWidth: true
                                                text: "SHA-256: " + String(stepRow.modelData.evidenceSha256)
                                                color: Theme.textFaint
                                                font.pixelSize: Theme.fontMetadata
                                                elide: Text.ElideMiddle
                                            }
                                        }
                                        AppButton {
                                            visible: String(stepRow.modelData.postUrl || "").length > 0
                                            text: "Mở bài đăng"
                                            leadingIcon: "ui/external-link"
                                            onClicked: Qt.openUrlExternally(
                                                String(stepRow.modelData.postUrl || ""))
                                        }
                                    }
                                }
                                ColumnLayout {
                                    spacing: 5
                                    Foundation.StatusPill {
                                        Layout.alignment: Qt.AlignRight
                                        text: String(stepRow.modelData.statusLabel
                                            || stepRow.modelData.status || "")
                                        tone: root.stateTone(
                                            stepRow.modelData.status)
                                        pulse: Boolean(stepRow.modelData.active)
                                    }
                                    RowLayout {
                                        visible: String(stepRow.modelData.status || "")
                                            === "needs_attention"
                                        spacing: 5
                                        AppButton {
                                            visible: String(stepRow.modelData.kind || "")
                                                === "workflow"
                                            text: "Đối soát lại"
                                            leadingIcon: "ui/refresh-cw"
                                            enabled: !root.actionBusy
                                            onClicked: root.controlPlaneBridge.refresh()
                                        }
                                        AppButton {
                                            visible: String(stepRow.modelData.kind || "")
                                                === "publish"
                                            text: "Đã đăng"
                                            leadingIcon: "semantic/check-circle"
                                            primary: true
                                            enabled: !root.actionBusy
                                            onClicked: root.openPublishedEvidence(
                                                stepRow.modelData.stepId,
                                                stepRow.modelData.platform)
                                        }
                                        AppButton {
                                            text: String(stepRow.modelData.kind || "")
                                                === "publish" ? "Chưa đăng" : "Xác nhận lỗi"
                                            leadingIcon: "ui/close"
                                            enabled: !root.actionBusy
                                            onClicked: root.resolveAttention(
                                                stepRow.modelData.stepId,
                                                String(stepRow.modelData.kind || "")
                                                    === "publish"
                                                    ? "not_published" : "failed",
                                                {"confirmation": "operator_reviewed"})
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: root.selectedOrderId.length === 0
                                || !root.stepModel
                                || Number(root.stepModel.count || 0) === 0
                            width: Math.min(parent.width - 32, 420)
                            text: root.selectedOrderId.length
                                ? "Work order chưa có bước để hiển thị."
                                : "Chọn một work order ở danh sách bên trái."
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontBody
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                        }
                    }

                    Rectangle {
                        visible: String(root.selectedOrder.errorMessage
                            || "").length > 0
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? 42 : 0
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        radius: Theme.radiusSmall
                        color: Theme.dangerSoft
                        Text {
                            anchors.fill: parent
                            anchors.margins: 10
                            text: String(root.selectedOrder.errorMessage || "")
                            color: Theme.danger
                            font.pixelSize: Theme.fontMetadata
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }

                    RowLayout { // perf-lint: disable=R5 — start/pause/resume are mutually exclusive
                        Layout.fillWidth: true
                        Layout.preferredHeight: 58
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        spacing: 8
                        Text {
                            Layout.fillWidth: true
                            text: root.selectedOrderId.length
                                ? "ID: " + root.selectedOrderId : ""
                            color: Theme.textFaint
                            font.pixelSize: Theme.fontMetadata
                            elide: Text.ElideMiddle
                        }
                        AppButton {
                            objectName: "tool1OrderStartButton"
                            visible: root.selectedStatus === "queued"
                            text: "Chạy"
                            leadingIcon: "ui/play"
                            primary: true
                            enabled: !root.actionBusy
                                && root.selectedOrderId.length > 0
                            onClicked: root.requestAction("tool1.order.start")
                        }
                        AppButton {
                            objectName: "tool1OrderPauseButton"
                            visible: root.selectedStatus === "running"
                            text: "Tạm dừng"
                            leadingIcon: "ui/pause"
                            enabled: !root.actionBusy
                            onClicked: root.requestAction("tool1.order.pause")
                        }
                        AppButton {
                            objectName: "tool1OrderResumeButton"
                            visible: root.selectedStatus === "paused"
                                && !Boolean(root.selectedOrder.cancelRequested)
                            text: "Tiếp tục"
                            leadingIcon: "ui/play"
                            primary: true
                            enabled: !root.actionBusy
                            onClicked: root.requestAction("tool1.order.resume")
                        }
                        AppButton {
                            objectName: "tool1OrderRetryButton"
                            visible: Boolean(root.selectedOrder.retryable)
                                || root.selectedStatus === "retryable"
                            text: "Thử lại bước lỗi"
                            leadingIcon: "ui/refresh-cw"
                            enabled: !root.actionBusy
                            onClicked: root.requestAction("tool1.order.retry")
                        }
                        AppButton {
                            objectName: "tool1OrderCancelButton"
                            visible: root.selectedOrderId.length > 0
                                && ["succeeded", "cancelled"].indexOf(
                                    root.selectedStatus) < 0
                                && !Boolean(root.selectedOrder.cancelRequested)
                            text: "Hủy work order"
                            leadingIcon: "ui/close"
                            enabled: !root.actionBusy
                            onClicked: cancelOrderPopup.open()
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: cancelOrderPopup
        objectName: "tool1CancelOrderPopup"
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(500, parent ? parent.width - 64 : 500)
        modal: true
        focus: true
        padding: 0
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: Theme.panel
            radius: Theme.radiusLarge
            border.width: 1
            border.color: Theme.border
        }

        contentItem: ColumnLayout {
            spacing: Theme.space3
            anchors.margins: Theme.space4

            Text {
                Layout.fillWidth: true
                text: "Hủy work order?"
                color: Theme.text
                font.pixelSize: Theme.fontSection
                font.weight: Font.DemiBold
            }
            Text {
                Layout.fillWidth: true
                text: "Tool 1 sẽ dừng trước bước kế tiếp. Workflow đang chạy được yêu cầu hủy tại điểm an toàn; bước đăng đã vào vùng tác động ngoài sẽ không bị ngắt mù."
                color: Theme.textMuted
                font.pixelSize: Theme.fontBody
                wrapMode: Text.Wrap
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                AppButton {
                    text: "Giữ lại"
                    enabled: !root.actionBusy
                    onClicked: cancelOrderPopup.close()
                }
                AppButton {
                    objectName: "tool1ConfirmCancelOrderButton"
                    text: "Xác nhận hủy"
                    leadingIcon: "ui/close"
                    primary: true
                    enabled: !root.actionBusy
                    onClicked: {
                        root.requestAction("tool1.order.cancel")
                        cancelOrderPopup.close()
                    }
                }
            }
        }
    }

    Popup {
        id: publishHistoryPopup
        objectName: "tool1PublishHistoryPopup"
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(1040, parent ? parent.width - 72 : 1040)
        height: Math.min(720, parent ? parent.height - 72 : 720)
        modal: true
        focus: true
        padding: 0
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: Theme.panel
            radius: Theme.radiusLarge
            border.width: 1
            border.color: Theme.border
        }

        contentItem: Loader {
            id: publishHistoryLoader
            active: publishHistoryPopup.opened
            asynchronous: true
            source: "PublishHistoryPanel.qml"
            onLoaded: item.controlPlaneBridge = root.controlPlaneBridge
        }

        Connections {
            target: publishHistoryLoader.item
            ignoreUnknownSignals: true
            function onCloseRequested() { publishHistoryPopup.close() }
            function onWorkOrderRequested(orderId) {
                if (String(orderId || ""))
                    publishHistoryPopup.close()
            }
        }
    }

    Popup {
        id: reconciliationPopup
        objectName: "tool1PublishReconciliationPopup"
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(520, parent ? parent.width - 64 : 520)
        modal: true
        focus: true
        padding: 0
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: Theme.panel
            radius: Theme.radiusLarge
            border.width: 1
            border.color: Theme.border
        }

        contentItem: ColumnLayout {
            spacing: Theme.space3
            anchors.margins: Theme.space4

            Text {
                Layout.fillWidth: true
                text: "Xác nhận video đã đăng"
                color: Theme.text
                font.pixelSize: Theme.fontSection
                font.weight: Font.DemiBold
            }
            Text {
                Layout.fillWidth: true
                text: "Nhập ít nhất một bằng chứng "
                    + root.platformLabel(root.reconciliationPlatform)
                    + ". Hệ thống chỉ hoàn tất bước đăng sau khi bạn xác nhận."
                color: Theme.textMuted
                font.pixelSize: Theme.fontBody
                wrapMode: Text.Wrap
            }
            WorkflowTextField {
                id: postIdInput
                objectName: "tool1ReconciledPostId"
                Layout.fillWidth: true
                placeholderText: "Post ID (nếu có)"
            }
            WorkflowTextField {
                id: postUrlInput
                objectName: "tool1ReconciledPostUrl"
                Layout.fillWidth: true
                placeholderText: "URL chuẩn của bài đăng"
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.space2
                Item { Layout.fillWidth: true }
                AppButton {
                    text: "Huỷ"
                    enabled: !root.actionBusy
                    onClicked: reconciliationPopup.close()
                }
                AppButton {
                    objectName: "tool1ConfirmPublishedButton"
                    text: "Xác nhận đã đăng"
                    leadingIcon: "semantic/check-circle"
                    primary: true
                    enabled: !root.actionBusy
                        && (postIdInput.text.trim().length > 0
                            || postUrlInput.text.trim().length > 0)
                    onClicked: {
                        root.resolveAttention(
                            root.reconciliationStepId,
                            "published",
                            {
                                "external_post_id": postIdInput.text.trim(),
                                "post_url": postUrlInput.text.trim(),
                                "confirmation": "operator_confirmed"
                            })
                        reconciliationPopup.close()
                    }
                }
            }
        }
    }
}
