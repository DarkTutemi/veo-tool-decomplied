pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Panel {
    id: root
    objectName: "channelCopilotPanel"
    color: "transparent"
    border.width: 0
    Accessible.name: "Channel Copilot và điều phối nội dung"
    Accessible.role: Accessible.Pane

    property var controlPlaneBridge: null
    property string pendingAction: ""
    property string feedbackMessage: ""

    readonly property var projectModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.copilotProjectModel : null
    readonly property var messageModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.copilotMessageModel : null
    readonly property var contentModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.copilotContentModel : null
    readonly property var sourceModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.copilotSourceModel : null
    readonly property var profileModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.profileModel : null
    readonly property var referencePackModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.referencePackModel : null
    readonly property var selectedProject: root.map(root.controlPlaneBridge
        ? root.controlPlaneBridge.selectedCopilotProject : null)
    readonly property var strategy: root.map(root.controlPlaneBridge
        ? root.controlPlaneBridge.copilotStrategy : null)
    readonly property var firstProfile: root.profileModel
        && Number(root.profileModel.count || 0) > 0
        ? root.map(root.profileModel.get(0)) : ({})
    readonly property string selectedProjectId: String(root.controlPlaneBridge
        ? root.controlPlaneBridge.selectedCopilotProjectId || "" : "")
    readonly property int revision: Number(root.controlPlaneBridge
        ? root.controlPlaneBridge.copilotRevision || 0 : 0)
    readonly property int approvedRevision: Number(
        root.selectedProject.approvedRevision || 0)
    readonly property bool hasProject: root.selectedProjectId.length > 0
    readonly property bool actionBusy: Boolean(root.controlPlaneBridge
        && root.controlPlaneBridge.actionBusy)
    readonly property bool revisionApproved: root.revision > 0
        && root.approvedRevision === root.revision
    readonly property int contentCount: Number(root.contentModel
        ? root.contentModel.count || 0 : 0)
    readonly property string localTimezone: String(root.controlPlaneBridge
        ? root.controlPlaneBridge.localTimezone || "UTC" : "UTC")
    readonly property string selectedPlatform: root.projectPlatform(
        root.selectedProject)

    function map(value) {
        return value === null || value === undefined ? ({}) : value
    }

    function projectPlatform(project) {
        const row = root.map(project)
        const explicit = String(row.platform || "").trim().toLowerCase()
        if (explicit) return explicit
        const searchable = (String(row.title || "") + " "
            + String(row.brief || "")).toLowerCase()
        const supported = ["youtube", "tiktok", "facebook", "instagram", "x", "linkedin"]
        for (let index = 0; index < supported.length; ++index) {
            if (searchable.indexOf(supported[index]) >= 0)
                return supported[index]
        }
        const platforms = root.strategy.platforms || []
        return platforms.length ? String(platforms[0]).toLowerCase() : "generic"
    }

    function createProject(title, brief) {
        const cleanBrief = String(brief || "").trim()
        if (!root.controlPlaneBridge || !cleanBrief) return
        root.pendingAction = "tool1.copilot.project.create"
        root.controlPlaneBridge.callTool(root.pendingAction, {
            "title": String(title || "").trim(),
            "brief": cleanBrief
        })
    }

    function selectProject(projectId) {
        const cleanId = String(projectId || "")
        if (!root.controlPlaneBridge || !cleanId
                || cleanId === root.selectedProjectId) return
        root.pendingAction = "tool1.copilot.project.select"
        root.controlPlaneBridge.callTool(root.pendingAction, {
            "project_id": cleanId
        })
    }

    function sendMessage(message) {
        const cleanMessage = String(message || "").trim()
        if (!root.controlPlaneBridge || !root.hasProject || !cleanMessage) return
        root.pendingAction = "tool1.copilot.message.send"
        root.controlPlaneBridge.callTool(root.pendingAction, {
            "project_id": root.selectedProjectId,
            "message": cleanMessage
        })
    }

    function bindReferencePack(referencePackId) {
        if (!root.controlPlaneBridge || !root.hasProject)
            return
        root.pendingAction = "tool1.copilot.reference_pack.bind"
        root.controlPlaneBridge.callTool(root.pendingAction, {
            "project_id": root.selectedProjectId,
            "reference_pack_id": String(referencePackId || "")
        })
    }

    function approvePlan() {
        if (!root.controlPlaneBridge || !root.hasProject || root.revision <= 0) return
        root.pendingAction = "tool1.copilot.plan.approve"
        root.controlPlaneBridge.callTool(root.pendingAction, {
            "project_id": root.selectedProjectId,
            "revision": root.revision
        })
    }

    function syncProjectPicker() {
        if (!root.projectModel || !root.hasProject) {
            projectPicker.currentIndex = -1
            return
        }
        for (let index = 0; index < Number(root.projectModel.count || 0); ++index) {
            const row = root.projectModel.get(index) || ({})
            if (String(row.projectId || "") === root.selectedProjectId) {
                if (projectPicker.currentIndex !== index)
                    projectPicker.currentIndex = index
                return
            }
        }
        projectPicker.currentIndex = -1
    }

    function syncReferencePackPicker() {
        referencePackPicker.currentIndex = -1
        if (!root.referencePackModel)
            return
        const selectedId = String(root.selectedProject.referencePackId || "")
        for (let index = 0; index < Number(root.referencePackModel.count || 0); ++index) {
            const row = root.referencePackModel.get(index) || ({})
            if (String(row.referencePackId || "") === selectedId) {
                referencePackPicker.currentIndex = index
                return
            }
        }
    }

    onSelectedProjectIdChanged: {
        Qt.callLater(root.syncProjectPicker)
        Qt.callLater(root.syncReferencePackPicker)
    }
    Component.onCompleted: {
        Qt.callLater(root.syncProjectPicker)
        Qt.callLater(root.syncReferencePackPicker)
    }

    Connections {
        target: root.projectModel
        function onCountChanged() { Qt.callLater(root.syncProjectPicker) }
        function onModelReset() { Qt.callLater(root.syncProjectPicker) }
    }

    Connections {
        target: root.referencePackModel
        function onCountChanged() { Qt.callLater(root.syncReferencePackPicker) }
        function onModelReset() { Qt.callLater(root.syncReferencePackPicker) }
    }

    Connections {
        target: root.controlPlaneBridge
        function onActionFinished(toolName, ok, data, message) {
            const name = String(toolName || "")
            if (name.indexOf("tool1.copilot.") !== 0) return
            root.feedbackMessage = ok
                ? (name === "tool1.copilot.message.send"
                    ? "AI Studio đã tạo revision mới. Hãy duyệt trước khi giao."
                    : name === "tool1.copilot.plan.approve"
                    ? "Revision hiện tại đã được duyệt."
                    : name === "tool1.copilot.sources.import"
                    ? "Nguồn đã được xác minh và lưu cho dự án."
                    : name === "tool1.copilot.reference_pack.bind"
                    ? "Reference Pack sẽ được dùng cho revision AI tiếp theo."
                    : "Channel Copilot đã cập nhật.")
                : String(message || "Không thể cập nhật Channel Copilot.")
            if (ok && name === "tool1.copilot.project.create")
                projectRail.finishCreate()
            if (ok && name === "tool1.copilot.message.send")
                conversation.clearComposer()
            root.pendingAction = ""
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space3

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            spacing: Theme.space3

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Text {
                    Layout.fillWidth: true
                    text: "Lập kế hoạch & điều phối"
                    color: Theme.text
                    font.pixelSize: Theme.fontPageTitle
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: "AI hiểu các workflow Tool 1 và chuyển kế hoạch đã duyệt thành công việc thực thi."
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontBody
                    elide: Text.ElideRight
                }
            }

            WorkflowComboBox {
                id: projectPicker
                objectName: "copilotProjectPicker"
                Layout.preferredWidth: 276
                model: root.projectModel
                textRole: "title"
                valueRole: "projectId"
                displayText: root.hasProject
                    ? String(root.selectedProject.title || "Dự án kênh")
                    : "Chọn dự án kênh"
                leadingPlatform: root.selectedPlatform
                enabled: root.projectModel
                    && Number(root.projectModel.count || 0) > 0
                    && !root.actionBusy
                onActivated: root.selectProject(currentValue)
            }

            WorkflowComboBox {
                id: referencePackPicker
                objectName: "copilotReferencePackPicker"
                Layout.preferredWidth: 238
                model: root.referencePackModel
                textRole: "title"
                valueRole: "referencePackId"
                displayText: String(root.selectedProject.referencePackId || "")
                    ? "Nguồn · " + String(
                        (root.selectedProject.referencePack || {}).title
                        || "Reference Pack")
                    : "Chọn Reference Pack"
                leadingIcon: "ui/layers"
                enabled: root.hasProject && root.referencePackModel
                    && Number(root.referencePackModel.count || 0) > 0
                    && !root.actionBusy
                onActivated: root.bindReferencePack(currentValue)
            }

            AppButton {
                objectName: "copilotHeaderNewProjectButton"
                text: "Kế hoạch mới"
                leadingIcon: "ui/plus"
                primary: true
                enabled: !root.actionBusy
                onClicked: projectRail.openEditor()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.space3

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 760
                spacing: Theme.space3

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Theme.space3

                    CopilotProjectRail {
                        id: projectRail
                        Layout.preferredWidth: 282
                        Layout.minimumWidth: 250
                        Layout.fillHeight: true
                        projectModel: root.projectModel
                        selectedProjectId: root.selectedProjectId
                        actionBusy: root.actionBusy
                        onCreateRequested: function(title, brief) {
                            root.createProject(title, brief)
                        }
                        onSelectRequested: function(projectId) {
                            root.selectProject(projectId)
                        }
                    }

                    CopilotConversationPanel {
                        id: conversation
                        objectName: "copilotConversationPanel"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 430
                        messageModel: root.messageModel
                        contentModel: root.contentModel
                        sourceModel: root.sourceModel
                        controlPlaneBridge: root.controlPlaneBridge
                        strategy: root.strategy
                        selectedProject: root.selectedProject
                        hasProject: root.hasProject
                        actionBusy: root.actionBusy
                        revision: root.revision
                        revisionApproved: root.revisionApproved
                        feedbackMessage: root.feedbackMessage
                        platform: root.selectedPlatform
                        onSendRequested: function(message) {
                            root.sendMessage(message)
                        }
                    }
                }
            }

            CopilotApprovalPanel {
                id: approval
                purpose: "planning"
                Layout.preferredWidth: 318
                Layout.minimumWidth: 292
                Layout.preferredHeight: 544
                Layout.maximumHeight: 544
                Layout.alignment: Qt.AlignTop
                strategy: root.strategy
                selectedProject: root.selectedProject
                profileModel: root.profileModel
                contentModel: root.contentModel
                localTimezone: root.localTimezone
                contentCount: root.contentCount
                revision: root.revision
                revisionApproved: root.revisionApproved
                actionBusy: root.actionBusy
                onApproveRequested: root.approvePlan()
            }
        }
    }
}
