pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "copilotAssignmentPanel"
    color: "transparent"
    border.width: 0

    property var controlPlaneBridge: null
    property string pendingAction: ""
    property string feedbackMessage: ""
    property bool feedbackOk: false

    readonly property var projectModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.copilotProjectModel : null
    readonly property var contentModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.copilotContentModel : null
    readonly property var profileModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.profileModel : null
    readonly property var selectedProject: root.map(root.controlPlaneBridge
        ? root.controlPlaneBridge.selectedCopilotProject : null)
    readonly property var strategy: root.map(root.controlPlaneBridge
        ? root.controlPlaneBridge.copilotStrategy : null)
    readonly property string selectedProjectId: String(root.controlPlaneBridge
        ? root.controlPlaneBridge.selectedCopilotProjectId || "" : "")
    readonly property int revision: Number(root.controlPlaneBridge
        ? root.controlPlaneBridge.copilotRevision || 0 : 0)
    readonly property int approvedRevision: Number(
        root.selectedProject.approvedRevision || 0)
    readonly property bool revisionApproved: root.revision > 0
        && root.approvedRevision === root.revision
    readonly property bool planPrepared: ["prepared", "active"].indexOf(
        String(root.selectedProject.status || "")) >= 0
    readonly property bool actionBusy: Boolean(root.controlPlaneBridge
        && root.controlPlaneBridge.actionBusy)
    readonly property int contentCount: Number(root.contentModel
        ? root.contentModel.count || 0 : 0)
    readonly property string localTimezone: String(root.controlPlaneBridge
        ? root.controlPlaneBridge.localTimezone || "UTC" : "UTC")
    readonly property string platform: root.projectPlatform(root.selectedProject)

    Accessible.name: "Bàn giao kế hoạch đã duyệt thành Assignment V2"
    Accessible.role: Accessible.Pane

    function map(value) {
        return value === null || value === undefined ? ({}) : value
    }

    function projectPlatform(project) {
        const explicit = String(root.map(project).platform || "").trim().toLowerCase()
        if (explicit) return explicit
        const platforms = root.strategy.platforms || []
        return platforms.length ? String(platforms[0]).toLowerCase() : "generic"
    }

    function syncProjectPicker() {
        projectPicker.currentIndex = -1
        if (!root.projectModel || !root.selectedProjectId)
            return
        for (let index = 0; index < Number(root.projectModel.count || 0); ++index) {
            const row = root.projectModel.get(index) || ({})
            if (String(row.projectId || "") === root.selectedProjectId) {
                projectPicker.currentIndex = index
                return
            }
        }
    }

    function selectProject(projectId) {
        const cleanId = String(projectId || "")
        if (!root.controlPlaneBridge || !cleanId
                || cleanId === root.selectedProjectId)
            return
        root.pendingAction = "tool1.copilot.project.select"
        root.controlPlaneBridge.callTool(root.pendingAction, {
            "project_id": cleanId
        })
    }

    function configureDelivery(delivery) {
        if (!root.controlPlaneBridge || !root.selectedProjectId)
            return
        root.pendingAction = "tool1.copilot.delivery.configure"
        root.controlPlaneBridge.callTool(root.pendingAction, {
            "project_id": root.selectedProjectId,
            "delivery": delivery || ({"mode": "none"})
        })
    }

    function prepareAssignments() {
        if (!root.controlPlaneBridge || !root.revisionApproved)
            return
        root.pendingAction = "tool1.copilot.assignments.prepare"
        root.controlPlaneBridge.callTool(root.pendingAction, {
            "project_id": root.selectedProjectId
        })
    }

    function assignItem(contentItemId) {
        const cleanId = String(contentItemId || "")
        if (!root.controlPlaneBridge || !root.selectedProjectId || !cleanId)
            return
        root.pendingAction = "tool1.copilot.item.assign"
        root.controlPlaneBridge.callTool(root.pendingAction, {
            "project_id": root.selectedProjectId,
            "content_item_id": cleanId
        })
    }

    function assignAllItems() {
        if (!root.controlPlaneBridge || !root.selectedProjectId
                || !root.planPrepared)
            return
        root.pendingAction = "tool1.copilot.items.assign_all"
        root.controlPlaneBridge.callTool(root.pendingAction, {
            "project_id": root.selectedProjectId
        })
    }

    onSelectedProjectIdChanged: Qt.callLater(root.syncProjectPicker)
    Component.onCompleted: Qt.callLater(root.syncProjectPicker)

    Connections {
        target: root.projectModel
        function onCountChanged() { Qt.callLater(root.syncProjectPicker) }
        function onModelReset() { Qt.callLater(root.syncProjectPicker) }
    }

    Connections {
        target: root.controlPlaneBridge
        function onActionFinished(toolName, ok, data, message) {
            const name = String(toolName || "")
            if ([
                    "tool1.copilot.project.select",
                    "tool1.copilot.delivery.configure",
                    "tool1.copilot.assignments.prepare",
                    "tool1.copilot.item.assign",
                    "tool1.copilot.items.assign_all"
                ].indexOf(name) < 0)
                return
            root.feedbackOk = Boolean(ok)
            root.feedbackMessage = ok
                ? (name === "tool1.copilot.delivery.configure"
                    ? "Đã kiểm tra và lưu đích kênh/lịch."
                    : name === "tool1.copilot.assignments.prepare"
                    ? "Đã compile các mục đủ điều kiện thành Assignment V2."
                    : name === "tool1.copilot.item.assign"
                    ? "Đã đưa một mục vào coordinator tuần tự."
                    : name === "tool1.copilot.items.assign_all"
                    ? "Đã đưa toàn bộ mục sẵn sàng vào coordinator tuần tự."
                    : "Đã chọn kế hoạch bàn giao.")
                : String(message || "Không thể bàn giao kế hoạch.")
            if (name === "tool1.copilot.delivery.configure")
                approval.finishDeliverySave(ok)
            root.pendingAction = ""
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space3

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            spacing: Theme.space3

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    Layout.fillWidth: true
                    text: "Từ kế hoạch đã duyệt"
                    color: Theme.text
                    font.pixelSize: Theme.fontSection
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: "Chọn revision, gán đích đăng/lịch rồi tạo order; feature native chỉ nhận config đã đóng băng."
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontMetadata
                    elide: Text.ElideRight
                }
            }

            WorkflowComboBox {
                id: projectPicker
                objectName: "assignmentPlanPicker"
                Layout.preferredWidth: 310
                model: root.projectModel
                textRole: "title"
                valueRole: "projectId"
                displayText: currentIndex >= 0 && root.projectModel
                    ? String((root.projectModel.get(currentIndex) || ({})).title
                        || "Kế hoạch kênh")
                    : "Chọn kế hoạch kênh"
                enabled: root.projectModel
                    && Number(root.projectModel.count || 0) > 0
                    && !root.actionBusy
                onActivated: root.selectProject(currentValue)
            }

            Foundation.StatusPill {
                text: root.revisionApproved
                    ? "Đã duyệt V" + String(root.revision)
                    : root.revision > 0 ? "Chưa duyệt" : "Chưa có revision"
                tone: root.revisionApproved ? Theme.success : Theme.warning
            }
        }

        Rectangle {
            visible: root.feedbackMessage.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 34 : 0
            radius: Theme.radiusSmall
            color: root.feedbackOk ? Theme.successSoft : Theme.dangerSoft
            Text {
                anchors.fill: parent
                anchors.margins: 8
                text: root.feedbackMessage
                color: root.feedbackOk ? Theme.success : Theme.danger
                font.pixelSize: Theme.fontMetadata
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.space3

            Panel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 520

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: String(root.contentCount) + " mục nội dung"
                            color: Theme.text
                            font.pixelSize: Theme.fontBody
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: root.revisionApproved
                                ? "Sẵn sàng kiểm tra bàn giao"
                                : "Duyệt tại Kế hoạch kênh trước"
                            color: root.revisionApproved ? Theme.success : Theme.warning
                            font.pixelSize: Theme.fontMetadata
                        }
                    }

                    ListView {
                        id: assignmentContentList
                        objectName: "assignmentPlanContentList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6
                        clip: true
                        reuseItems: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: root.contentModel
                        delegate: CopilotContentItemDelegate {
                            platform: root.platform
                            showAssignmentAction: true
                            onAssignRequested: function(contentItemId) {
                                root.assignItem(contentItemId)
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !root.contentModel
                                || Number(root.contentModel.count || 0) === 0
                            width: Math.min(parent.width - 40, 420)
                            text: root.selectedProjectId
                                ? "Kế hoạch chưa có content item. Quay lại Kế hoạch kênh để làm việc với AI Studio."
                                : "Chọn một Kế hoạch kênh để bàn giao."
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontBody
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            CopilotApprovalPanel {
                id: approval
                purpose: "assignment"
                Layout.preferredWidth: 334
                Layout.minimumWidth: 310
                Layout.fillHeight: true
                strategy: root.strategy
                selectedProject: root.selectedProject
                profileModel: root.profileModel
                contentModel: root.contentModel
                localTimezone: root.localTimezone
                contentCount: root.contentCount
                revision: root.revision
                revisionApproved: root.revisionApproved
                planPrepared: root.planPrepared
                actionBusy: root.actionBusy
                onPrepareRequested: root.prepareAssignments()
                onDeliveryRequested: function(delivery) {
                    root.configureDelivery(delivery)
                }
                onAssignAllRequested: root.assignAllItems()
            }
        }
    }
}
