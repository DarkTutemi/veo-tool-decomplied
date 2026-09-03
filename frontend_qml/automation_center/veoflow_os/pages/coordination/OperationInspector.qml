pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Foundation.InspectorPane {
    id: root
    objectName: "operationInspector"
    property var operation: ({})
    property var approvalModel
    property var commandStore
    property var controlPlaneBridge
    property int commandRevision: 0
    property string pendingApprovalId: ""
    property string pendingDecision: ""
    property string referenceTimestamp: ""

    signal openOperation(string operationKey)
    signal navigateDeepLink(var deepLink)
    signal closeRequested()

    preferredWidth: 360
    accessibleName: "Chi tiết công việc và phê duyệt"

    readonly property bool hasOperation: String(operation.operation_key || "").length > 0
    readonly property string operationKey: String(operation.operation_key || "")
    readonly property var operationActions: operation.actions || ({})
    readonly property var editAction: operationActions.edit || ({})

    function stateTone(value) {
        const state = String(value || "").toLowerCase()
        if (["failed", "blocked", "verification_required"].indexOf(state) >= 0)
            return Theme.danger
        if (["succeeded", "completed", "published", "done"].indexOf(state) >= 0)
            return Theme.success
        if (["awaiting_approval", "scheduled"].indexOf(state) >= 0)
            return Theme.warning
        if (["running", "producing", "rendering", "publishing", "caring", "in_progress"].indexOf(state) >= 0)
            return Theme.info
        return Theme.textFaint
    }

    function stateLabel(value) {
        const labels = {
            "running": "Đang chạy", "producing": "Đang sản xuất",
            "rendering": "Đang render", "publishing": "Đang đăng",
            "caring": "Đang chăm sóc", "in_progress": "Đang xử lý",
            "awaiting_approval": "Chờ phê duyệt", "scheduled": "Đã lên lịch",
            "failed": "Thất bại", "blocked": "Bị chặn",
            "succeeded": "Hoàn tất", "completed": "Hoàn tất",
            "published": "Đã đăng", "done": "Hoàn tất", "unknown": "Không rõ"
        }
        return labels[String(value || "unknown").toLowerCase()] || String(value || "Không rõ")
    }

    function stageLabel(value) {
        const labels = {
            "idea": "Ý tưởng", "production": "Sản xuất",
            "publish": "Đăng tải", "care": "Chăm sóc"
        }
        return labels[value] || "Không rõ"
    }

    function progressLabel() {
        const progress = root.operation.progress || ({})
        if (progress.value === null || progress.value === undefined)
            return "Không rõ"
        return Math.round(Math.max(0, Math.min(1, Number(progress.value || 0))) * 100) + "%"
    }

    function etaLabel() {
        const value = String(root.operation.estimated_end_at || "")
        if (!value)
            return "Không rõ"
        const parsed = new Date(value)
        return isNaN(parsed.getTime()) ? "Không rõ" : Qt.formatDateTime(parsed, "dd/MM · HH:mm")
    }

    function ownerLabel() {
        const owner = root.operation.owner || ({})
        if (!owner.available || !owner.id) return "Chưa gán"
        const id = String(owner.id)
        if (id === "operator_demo" || id === "local-operator") return "Người vận hành"
        return id
    }

    function formatProgressSource(source) {
        const str = String(source || "")
        if (!str) return "Không rõ"
        if (str.indexOf("publish.runner") >= 0) return "Tiến trình phát hành"
        if (str.indexOf("studio.runner") >= 0) return "Tiến trình Studio"
        if (str.indexOf("care.runner") >= 0) return "Tiến trình chăm sóc"
        return str
    }

    function scopeLabel(value) {
        const labels = {
            "publish.finalize": "Phê duyệt phát hành",
            "media.generate": "Phê duyệt chi phí AI",
            "channel.update": "Cập nhật kênh",
            "browser.action": "Thao tác trình duyệt",
            "comment.reply": "Phê duyệt trả lời"
        }
        return labels[String(value || "")] || String(value || "Yêu cầu phê duyệt")
    }

    function riskLabel(risk) {
        const value = String(risk || "").toLowerCase()
        if (value === "high") return "Rủi ro cao"
        if (value === "medium") return "Rủi ro trung bình"
        if (value === "low") return "Rủi ro thấp"
        return risk || ""
    }

    function targetLabel(target) {
        const item = target || ({})
        const type = String(item.type || "")
        const id = String(item.id || "")
        if (!type && !id) return ""
        const typeLabels = {
            "publish_job": "Tác vụ phát hành",
            "media_request": "Tạo media",
            "channel": "Kênh",
            "content_package": "Gói nội dung"
        }
        const friendlyType = typeLabels[type] || type
        return friendlyType + (id ? ": " + id : "")
    }

    function descriptionLabel() {
        const description = root.operation.description || ({})
        return description.available && description.text
            ? String(description.text) : "Chưa có mô tả"
    }

    function approvalMatches(operationKey) {
        return String(operationKey || "") === root.operationKey
    }

    function matchingApprovalCount() {
        const revision = root.commandRevision
        let count = 0
        if (!root.approvalModel || !root.operationKey)
            return count
        for (let index = 0; index < root.approvalModel.count; index++) {
            if (root.approvalMatches(root.approvalModel.get(index).operation_key))
                count++
        }
        return count
    }

    function syncApprovalIndex() {
        if (!root.approvalModel || !root.operationKey)
            return
        for (let index = 0; index < root.approvalModel.count; index++) {
            if (root.approvalMatches(root.approvalModel.get(index).operation_key)) {
                approvalList.currentIndex = index
                approvalList.positionViewAtIndex(index, ListView.Contain)
                return
            }
        }
        approvalList.currentIndex = -1
    }

    onOperationKeyChanged: Qt.callLater(root.syncApprovalIndex)

    function approvalBusy(approvalId) {
        const revision = root.commandRevision
        return root.commandStore
            ? root.commandStore.isBusy("approval.resolve", "approval", String(approvalId || ""))
            : false
    }

    function approvalCommandState(approvalId) {
        const revision = root.commandRevision
        return root.commandStore
            ? root.commandStore.state("approval.resolve", "approval", String(approvalId || ""))
            : ({})
    }

    function requestDecision(approvalId, decision) {
        if (!approvalId || root.approvalBusy(approvalId))
            return
        root.pendingApprovalId = String(approvalId)
        root.pendingDecision = String(decision)
        confirmDialog.open()
    }

    function resolvePendingApproval() {
        const approvalId = root.pendingApprovalId
        const decision = root.pendingDecision
        if (!approvalId || root.approvalBusy(approvalId))
            return
        root.controlPlaneBridge.callTool("approval.resolve", {
            "approval_id": approvalId,
            "decision": decision
        })
    }

    function previewApproval(deepLink) {
        const link = deepLink || ({})
        if (String(link.route || ""))
            root.navigateDeepLink(link)
    }

    Connections {
        target: root.commandStore
        function onChanged(capability, entityType, entityId) {
            if (capability === "approval.resolve" && entityType === "approval")
                root.commandRevision++
        }
    }

    Foundation.ConfirmDialog {
        id: confirmDialog
        objectName: "coordinationApprovalConfirmDialog"
        parent: root.Overlay.overlay ? root.Overlay.overlay : root
        anchors.centerIn: parent
        title: root.pendingDecision === "approved" ? "Xác nhận phê duyệt" : "Xác nhận từ chối"
        message: root.pendingDecision === "approved"
            ? "Gửi quyết định phê duyệt tới server để xác thực operator và policy?"
            : "Gửi quyết định từ chối tới server? Công việc vẫn ở trạng thái an toàn cho tới khi server phản hồi."
        confirmText: root.pendingDecision === "approved" ? "Phê duyệt" : "Từ chối"
        destructive: root.pendingDecision === "rejected"
        onAccepted: root.resolvePendingApproval()
    }

    ScrollView {
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Chi tiết công việc"
                    color: Theme.text
                    font.pixelSize: 15
                    font.weight: Font.Bold
                }
                Foundation.IconButton {
                    objectName: "openSelectedOperationButton"
                    visible: root.hasOperation
                    iconName: "ui/external-link"
                    text: ""
                    accessibleName: "Mở công việc trong màn hình sở hữu"
                    onClicked: root.openOperation(root.operationKey)
                }
                Foundation.IconButton {
                    objectName: "coordinationInspectorCloseButton"
                    iconName: "ui/close"
                    text: ""
                    accessibleName: "Đóng chi tiết công việc"
                    activeFocusOnTab: true
                    onClicked: root.closeRequested()
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

            Foundation.EmptyState {
                visible: !root.hasOperation
                Layout.fillWidth: true
                Layout.preferredHeight: 164
                title: "Chưa chọn công việc"
                description: "Chọn một operation theo định danh ổn định để xem chi tiết."
            }

            ColumnLayout {
                visible: root.hasOperation
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Rectangle {
                        objectName: "coordinationOperationIdChip"
                        Layout.preferredWidth: 152
                        Layout.preferredHeight: 30
                        radius: Theme.radiusSmall
                        color: Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft
                        Accessible.name: "ID công việc: "
                            + String(root.operation.operation_id || root.operationKey)
                        Accessible.role: Accessible.StaticText
                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 9
                            text: "ID: " + String(
                                root.operation.operation_id || root.operationKey)
                            color: Theme.textMuted
                            font.pixelSize: 11
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideMiddle
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Foundation.StatusPill {
                        objectName: "coordinationStateField"
                        text: root.stateLabel(root.operation.state)
                        tone: root.stateTone(root.operation.state)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 9
                    SocialIcon { platform: String(root.operation.platform || "generic"); Layout.preferredWidth: 28; Layout.preferredHeight: 28 }
                    Text { Layout.fillWidth: true; text: String(root.operation.title || "Công việc chưa có tiêu đề"); color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold; wrapMode: Text.Wrap }
                }

                DetailRow { label: "Kênh"; value: String(root.operation.channel_name || root.operation.channel_id || "Chưa gán") }
                DetailRow { label: "Giai đoạn"; value: root.stageLabel(root.operation.stage) + (root.operation.substage ? " · " + root.operation.substage : "") }
                DetailRow { label: "Tiến độ"; value: root.progressLabel(); unknown: (root.operation.progress || {}).value === null || (root.operation.progress || {}).value === undefined }
                DetailRow { label: "Nguồn tiến độ"; value: root.formatProgressSource((root.operation.progress || {}).source); unknown: !(root.operation.progress || {}).source }
                DetailRow { label: "ETA"; value: root.etaLabel(); unknown: root.etaLabel() === "Không rõ" }

                EvidenceField {
                    objectName: "coordinationOwnerField"
                    label: "Chủ sở hữu"
                    displayValue: root.ownerLabel()
                    available: Boolean((root.operation.owner || {}).available)
                }

                Text {
                    objectName: "coordinationDescriptionField"
                    property string displayValue: root.descriptionLabel()
                    Layout.fillWidth: true
                    text: displayValue
                    color: (root.operation.description || {}).available ? Theme.textMuted : Theme.warning
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Accessible.name: "Mô tả công việc. " + displayValue
                    Accessible.role: Accessible.StaticText
                }

                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }
                    AppButton {
                        objectName: "coordinationEditOperationButton"
                        text: "Chỉnh sửa"
                        primary: true
                        Layout.preferredWidth: 112
                        enabled: Boolean(root.editAction.available)
                            && Boolean((root.editAction.deep_link || {}).route)
                        activeFocusOnTab: true
                        Accessible.name: enabled
                            ? "Mở công việc để chỉnh sửa"
                            : "Không có đích chỉnh sửa được server cung cấp"
                        onClicked: root.navigateDeepLink(root.editAction.deep_link || ({}))
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

            ColumnLayout {
                id: approvalSection
                objectName: "coordinationApprovalSection"
                property bool expanded: true
                readonly property int matchingCount: root.matchingApprovalCount()
                Layout.fillWidth: true
                spacing: 8

                Button {
                    objectName: "coordinationApprovalSectionToggle"
                    Layout.fillWidth: true
                    implicitHeight: 34
                    activeFocusOnTab: true
                    Accessible.name: (approvalSection.expanded ? "Thu gọn" : "Mở rộng")
                        + " yêu cầu phê duyệt của công việc"
                    onClicked: approvalSection.expanded = !approvalSection.expanded
                    contentItem: RowLayout {
                        Text { Layout.fillWidth: true; text: "Cần xử lý"; color: Theme.text; font.pixelSize: 13; font.weight: Font.Bold }
                        Foundation.StatusPill { text: String(approvalSection.matchingCount); tone: approvalSection.matchingCount > 0 ? Theme.warning : Theme.success }
                        UiIcon {
                            name: approvalSection.expanded ? "ui/chevron-up" : "ui/chevron-down"
                            tone: Theme.textMuted
                            iconSize: 16
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                        }
                    }
                    background: Rectangle { color: "transparent" }
                }

                Foundation.EmptyState {
                    visible: approvalSection.expanded && approvalSection.matchingCount === 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 110
                    title: "Không có yêu cầu chờ duyệt"
                    description: "Operation này không có quyết định được bảo vệ đang chờ operator."
                }

                ListView {
                    id: approvalList
                    objectName: "coordinationApprovalList"
                    visible: approvalSection.expanded && approvalSection.matchingCount > 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(300, approvalSection.matchingCount * 150)
                    model: root.approvalModel
                    spacing: 8
                    clip: true
                    cacheBuffer: 1000
                    displayMarginBeginning: 1000
                    displayMarginEnd: 1000
                    reuseItems: false
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        id: approvalCard
                        objectName: "approvalCard_" + approvalCard.approvalId
                        required property string approval_id
                        required property var scope
                        required property var target
                        required property var operation_key
                        required property var preview_deep_link
                        required property var reason
                        required property var risk_level
                        required property var requested_by

                        readonly property string approvalId: String(approvalCard.approval_id || "")
                        readonly property bool matchesOperation: root.approvalMatches(approvalCard.operation_key)
                        readonly property bool busy: root.approvalBusy(approvalCard.approvalId)
                        readonly property var commandState: root.approvalCommandState(approvalCard.approvalId)

                        width: approvalList.width
                        height: matchesOperation ? 142 : 0
                        visible: matchesOperation
                        radius: Theme.radiusMedium
                        color: Theme.elevated
                        border.width: 1
                        border.color: approvalCard.busy ? Theme.accent : Theme.borderSoft
                        Accessible.name: "Yêu cầu " + approvalCard.scope + ". " + approvalCard.reason
                        Accessible.role: Accessible.Pane

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6
                            RowLayout {
                                Layout.fillWidth: true
                                Foundation.StatusPill { text: root.scopeLabel(approvalCard.scope); tone: Theme.warning }
                                Item { Layout.fillWidth: true }
                                Text { text: root.riskLabel(approvalCard.risk_level); color: Theme.warning; font.pixelSize: 11; font.weight: Font.Medium }
                            }
                            Text { Layout.fillWidth: true; text: approvalCard.reason || "Không có lý do"; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight }
                            Text { Layout.fillWidth: true; text: root.targetLabel(approvalCard.target); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideMiddle }
                            Text { visible: Boolean(approvalCard.commandState.message); Layout.fillWidth: true; text: String(approvalCard.commandState.message || ""); color: approvalCard.commandState.ok ? Theme.success : Theme.danger; font.pixelSize: 11; elide: Text.ElideRight }
                            Item { Layout.fillHeight: true }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                AppButton {
                                    objectName: "approvalPreviewButton_" + approvalCard.approvalId
                                    text: "Xem trước"
                                    implicitHeight: 30
                                    enabled: !approvalCard.busy && Boolean((approvalCard.preview_deep_link || {}).route)
                                    activeFocusOnTab: true
                                    Accessible.name: "Xem trước mục tiêu của " + approvalCard.approvalId
                                    onClicked: root.previewApproval(approvalCard.preview_deep_link)
                                }
                                Item { Layout.fillWidth: true }
                                AppButton {
                                    objectName: "approvalRejectButton_" + approvalCard.approvalId
                                    text: approvalCard.busy ? "Đang gửi" : "Từ chối"
                                    implicitHeight: 30
                                    enabled: !approvalCard.busy
                                    activeFocusOnTab: true
                                    onClicked: root.requestDecision(approvalCard.approvalId, "rejected")
                                }
                                AppButton {
                                    objectName: "approvalApproveButton_" + approvalCard.approvalId
                                    text: approvalCard.busy ? "Đang gửi" : "Phê duyệt"
                                    implicitHeight: 30
                                    primary: true
                                    enabled: !approvalCard.busy
                                    activeFocusOnTab: true
                                    onClicked: root.requestDecision(approvalCard.approvalId, "approved")
                                }
                            }
                        }
                    }
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

            ColumnLayout {
                id: activitySection
                objectName: "coordinationActivitySection"
                property bool expanded: true
                Layout.fillWidth: true
                spacing: 7

                Button {
                    objectName: "coordinationActivitySectionToggle"
                    Layout.fillWidth: true
                    implicitHeight: 34
                    activeFocusOnTab: true
                    Accessible.name: (activitySection.expanded ? "Thu gọn" : "Mở rộng")
                        + " lịch sử hoạt động"
                    onClicked: activitySection.expanded = !activitySection.expanded
                    contentItem: RowLayout {
                        Text { Layout.fillWidth: true; text: "Hoạt động gần đây"; color: Theme.text; font.pixelSize: 13; font.weight: Font.Bold }
                        UiIcon {
                            name: activitySection.expanded ? "ui/chevron-up" : "ui/chevron-down"
                            tone: Theme.textMuted
                            iconSize: 16
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                        }
                    }
                    background: Rectangle { color: "transparent" }
                }

                Foundation.EmptyState {
                    visible: activitySection.expanded && (root.operation.activity || []).length === 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 104
                    title: "Chưa có sự kiện"
                    description: "Backend chưa ghi nhận DomainEvent cho operation này."
                }

                Item {
                    visible: activitySection.expanded
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(0,
                        (root.operation.activity || []).length * 42 - 4)

                    Repeater {
                        model: root.operation.activity || []
                        delegate: Rectangle {
                        id: activityCard
                        required property int index
                        required property var modelData
                        readonly property var deepLink: activityCard.modelData.deep_link || ({})
                        readonly property bool linkAvailable: Boolean(activityCard.deepLink.route)
                        objectName: "operationActivity_" + String(activityCard.modelData.event_id || "unknown")
                        width: parent ? parent.width : 0
                        height: 38
                        y: activityCard.index * 42
                        radius: Theme.radiusMedium
                        color: Theme.elevated
                        Accessible.name: String(activityCard.modelData.summary || "Sự kiện không có mô tả")
                        Accessible.description: activityCard.linkAvailable
                            ? "Mở bằng chứng hoạt động được server liên kết"
                            : "Sự kiện không có deep link được cấp quyền"
                        Accessible.role: activityCard.linkAvailable
                            ? Accessible.Button : Accessible.ListItem
                        activeFocusOnTab: activityCard.linkAvailable
                        Accessible.focusable: activityCard.linkAvailable
                        Keys.onReturnPressed: if (activityCard.linkAvailable) root.navigateDeepLink(activityCard.deepLink)
                        Keys.onEnterPressed: if (activityCard.linkAvailable) root.navigateDeepLink(activityCard.deepLink)
                        Keys.onSpacePressed: if (activityCard.linkAvailable) root.navigateDeepLink(activityCard.deepLink)
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 7
                            spacing: 9
                            Rectangle { Layout.preferredWidth: 7; Layout.preferredHeight: 7; radius: 4; color: Theme.info }
                            Text {
                                Layout.fillWidth: true
                                text: String(activityCard.modelData.summary
                                    || "Sự kiện không có mô tả")
                                color: Theme.textMuted
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }
                            Foundation.RelativeTimeText {
                                objectName: "activityRelativeTime_"
                                    + String(activityCard.modelData.event_id || "unknown")
                                visible: Boolean(activityCard.modelData.occurred_at)
                                timestamp: String(activityCard.modelData.occurred_at || "")
                                referenceTimestamp: root.referenceTimestamp
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: activityCard.linkAvailable
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: root.navigateDeepLink(activityCard.deepLink)
                        }
                        }
                    }
                }
            }
        }
    }

    component DetailRow: RowLayout {
        id: detailRow
        property string label: ""
        property string value: ""
        property bool unknown: false
        Layout.fillWidth: true
        Text { text: detailRow.label; color: Theme.textFaint; font.pixelSize: 12 }
        Item { Layout.fillWidth: true }
        Text { Layout.maximumWidth: 220; text: detailRow.value; color: detailRow.unknown ? Theme.warning : Theme.textMuted; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
    }

    component EvidenceField: RowLayout {
        id: evidenceField
        property string label: ""
        property string displayValue: ""
        property bool available: false
        Layout.fillWidth: true
        Accessible.name: label + ". " + displayValue
        Accessible.role: Accessible.StaticText
        Text { text: evidenceField.label; color: Theme.textFaint; font.pixelSize: 12 }
        Item { Layout.fillWidth: true }
        Text { Layout.maximumWidth: 220; text: evidenceField.displayValue; color: evidenceField.available ? Theme.textMuted : Theme.warning; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
    }
}
