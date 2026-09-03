pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../foundation" as Foundation
import "automation" as Automation
import "distribution" as Distribution

Item {
    id: root
    objectName: "distributionPage"
    property bool embeddedMode: false
    Accessible.name: "Phân phối nội dung"
    Accessible.role: Accessible.Pane

    property string activeSection: "copilot"
    property var automationSnapshot: ({})
    property var snapshotError: ({})
    property string selectedPlanKey: ""
    property string feedbackMessage: ""
    // qmllint disable unqualified
    readonly property var plane: controlPlane
    // qmllint enable unqualified
    readonly property var snapshotData: root.map(root.map(root.automationSnapshot).data)
    readonly property var distributionData: root.map(root.snapshotData.distribution)
    readonly property var rulesData: root.map(root.snapshotData.rules)
    readonly property var activityData: root.map(root.snapshotData.activity)
    readonly property var runtimeData: root.map(root.snapshotData.runtime)
    readonly property var plansData: root.map(root.distributionData.plans)
    readonly property bool hasPlans: Number(root.plansData.total || 0) > 0
    readonly property bool primarySection: root.activeSection === "copilot"
        || root.activeSection === "sources" || root.activeSection === "workflows"
        || root.activeSection === "publishing"
    readonly property string viewState: root.resolveViewState()
    readonly property var sections: [
        {
            "key": "copilot",
            "label": "Channel Copilot",
            "icon": "semantic/workflow",
            "description": "Chat với AI để lập chiến lược, content plan và duyệt revision"
        },
        {
            "key": "sources",
            "label": "Nguồn tham khảo",
            "icon": "ui/layers",
            "description": "Tạo Reference Pack có revision/hash cho Channel Copilot"
        },
        {
            "key": "workflows",
            "label": "Giao nhanh",
            "icon": "ui/play",
            "description": "Giao chuỗi sản xuất, kênh và lịch cho Tool 1 chạy tuần tự"
        },
        {
            "key": "plans",
            "label": "Kế hoạch",
            "icon": "semantic/workflow",
            "description": "Nguồn video, kênh nhận, nhịp đăng và phê duyệt"
        },
        {
            "key": "calendar",
            "label": "Lịch phân phối",
            "icon": "ui/calendar",
            "description": "Các lượt đăng đã được xếp theo ngày và kênh"
        },
        {
            "key": "queue",
            "label": "Đang thực hiện",
            "icon": "ui/list",
            "description": "Lượt đăng đang chờ duyệt, đang chạy hoặc cần xác minh"
        },
        {
            "key": "publishing",
            "label": "Xuất bản",
            "icon": "semantic/upload-cloud",
            "description": "Lịch, PublishKit, đối soát tài khoản và bằng chứng"
        }
    ]

    function present(value) {
        return value !== null && value !== undefined
    }

    function map(value) {
        return root.present(value) ? value : ({})
    }

    function cloneMap(value) {
        const source = root.map(value)
        const result = ({})
        const keys = Object.keys(source)
        for (let index = 0; index < keys.length; ++index)
            result[keys[index]] = source[keys[index]]
        return result
    }

    function resolveViewState() {
        const snapshot = root.map(root.automationSnapshot)
        const error = root.map(root.snapshotError)
        const hasSnapshot = String(snapshot.snapshot_id || "").length > 0
        const code = String(error.code || "").toUpperCase()
        if (!hasSnapshot) {
            if (code === "PERMISSION_DENIED" || code === "FORBIDDEN")
                return "permission"
            return code ? "error" : "loading"
        }
        if (code === "NETWORK_ERROR" || code === "OFFLINE")
            return "offline"
        if (code)
            return "error"
        const freshness = String(root.map(snapshot.freshness).state || "fresh").toLowerCase()
        if (freshness === "partial" || freshness === "stale")
            return freshness
        return root.hasPlans ? "content" : "empty"
    }

    function reloadAutomation() {
        root.automationSnapshot = root.plane.snapshotStore.snapshot("automation")
        root.snapshotError = root.plane.snapshotStore.error("automation")
        const selected = root.map(root.plansData.selected)
        if (selected.plan_key)
            root.selectedPlanKey = String(selected.plan_key)
    }

    function requestPlans(overrides) {
        const extra = root.map(overrides)
        const query = {
            "tab": "rules",
            "limit": 50,
            "event_limit": 50,
            "activity_hours": 24
        }
        const key = String(extra.selected_rule_key !== undefined
            ? extra.selected_rule_key : root.selectedPlanKey)
        if (key)
            query.selected_rule_key = key
        root.plane.callTool("automation.snapshot", query)
    }

    function dispatchAction(action, overrides) {
        const descriptor = root.map(action)
        if (descriptor.available !== true || !descriptor.capability)
            return false
        const input = root.cloneMap(descriptor.input)
        const extra = root.map(overrides)
        const keys = Object.keys(extra)
        for (let index = 0; index < keys.length; ++index)
            input[keys[index]] = extra[keys[index]]
        const capability = String(descriptor.capability)
        if (capability.indexOf("automation.rule.") === 0) {
            const planKey = String(input.rule_key || "new-plan")
            const version = String(input.expected_version || 0)
            input.idempotency_key = "ui:" + capability + ":" + planKey + ":v" + version
        }
        root.plane.callTool(capability, input)
        return true
    }

    function openDeepLink(link) {
        const projected = root.map(link)
        const entity = root.map(projected.entity)
        const route = String(projected.route || "")
        if (!route)
            return false
        root.plane.navigateEntity(
            route,
            String(entity.type || ""),
            String(entity.id || ""),
            root.map(projected.context)
        )
        return true
    }

    function selectPlan(plan) {
        const key = String(root.map(plan).plan_key || "")
        if (!key || key === root.selectedPlanKey)
            return
        root.selectedPlanKey = key
        root.requestPlans({"selected_rule_key": key})
    }

    function sectionForSelection() {
        const selection = root.map(root.plane.entitySelection.current)
        const route = String(selection.route || "")
        const context = root.map(selection.context)
        const subview = String(context.subview || "")
        if (route === "schedule")
            return "publishing"
        if (route === "automation" || route === "distribution") {
            if (root.embeddedMode) {
                if (subview === "calendar" || subview === "queue"
                        || subview === "publish")
                    return "publishing"
                if (subview === "plans")
                    return "copilot"
            }
            if (subview === "copilot" || subview === "sources"
                    || subview === "workflows" || subview === "publishing"
                    || subview === "calendar" || subview === "queue"
                    || subview === "plans")
                return subview
            return "copilot"
        }
        return root.activeSection
    }

    function activateSection(key: string): void {
        let normalized = String(key || "copilot")
        if (root.embeddedMode) {
            if (normalized === "calendar" || normalized === "queue"
                    || normalized === "publish")
                normalized = "publishing"
            else if (["copilot", "sources", "workflows", "publishing"].indexOf(
                    normalized) < 0)
                normalized = "copilot"
        }
        root.activeSection = normalized
        // qmllint disable missing-property
        if ((normalized === "calendar" || normalized === "queue")
                && scheduleLoader.status === Loader.Ready)
            scheduleLoader.item.requestTab(normalized === "queue" ? "queue" : "calendar")
        // qmllint enable missing-property
    }

    function openCreatePlan() {
        planEditor.creating = true
        planEditor.syncForm()
        editorPopup.open()
    }

    function openEditPlan() {
        planEditor.creating = false
        planEditor.syncForm()
        editorPopup.open()
    }

    Connections {
        target: root.plane.snapshotStore
        function onChanged(route) {
            if (route === "automation")
                root.reloadAutomation()
        }
    }

    Connections {
        target: root.plane.entitySelection
        function onSelectionChanged() {
            root.activateSection(root.sectionForSelection())
        }
    }

    Connections {
        target: root.plane
        function onActionFinished(toolName, ok, data, message) {
            const name = String(toolName || "")
            if (name.indexOf("automation.rule.") !== 0)
                return
            root.feedbackMessage = ok
                ? "Kế hoạch đã được lưu và lịch sắp tới đã được cập nhật."
                : String(message || "Không thể lưu kế hoạch.")
            if (ok) {
                editorPopup.close()
                root.requestPlans({})
            }
        }
    }

    Component.onCompleted: {
        root.reloadAutomation()
        root.activateSection(root.sectionForSelection())
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.pageGutter
        anchors.rightMargin: Theme.pageGutter
        anchors.topMargin: root.activeSection === "copilot"
                || root.activeSection === "sources"
                || root.activeSection === "workflows"
                || root.activeSection === "publishing" ? 12 : Theme.pageGutter
        anchors.bottomMargin: Theme.pageGutter
        spacing: Theme.space3

        Panel {
            objectName: "distributionHeader"
            visible: root.activeSection !== "copilot"
                && root.activeSection !== "sources"
                && root.activeSection !== "workflows"
                && root.activeSection !== "publishing"
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? (root.primarySection ? 72 : 90) : 0
            color: root.primarySection ? "transparent" : Theme.panel
            border.width: root.primarySection ? 0 : 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: root.primarySection ? 0 : Theme.space4
                spacing: Theme.space4

                Rectangle {
                    visible: !root.primarySection
                    Layout.preferredWidth: 46
                    Layout.preferredHeight: 46
                    radius: 13
                    color: Theme.accentSoft
                    UiIcon { anchors.centerIn: parent; name: "semantic/workflow"; tone: Theme.accent; iconSize: 24 }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3
                    Text {
                        text: root.activeSection === "copilot"
                            ? "Channel Copilot · Automation Center"
                            : root.activeSection === "workflows"
                            ? "Giao nhanh · Automation Center" : "Phân phối"
                        color: Theme.text
                        font.pixelSize: Theme.fontPageTitle
                        font.weight: Font.Bold
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.activeSection === "copilot"
                            ? "AI Studio lập chiến lược và content plan; bạn duyệt rồi giao từng mục sang workflow native của Tool 1."
                            : root.activeSection === "workflows"
                            ? "Tạo một Assignment V2 trực tiếp cho workflow native; không nhận job qua server trung gian."
                            : "Chọn video hoàn chỉnh, kênh nhận và nhịp đăng. Hệ thống xếp lịch; bạn duyệt trước khi xuất bản."
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontBody
                        elide: Text.ElideRight
                    }
                }

                AppButton {
                    objectName: "distributionRefreshButton"
                    visible: !root.primarySection
                    text: "Làm mới"
                    leadingIcon: "ui/refresh-cw"
                    onClicked: root.requestPlans({})
                }
                AppButton {
                    objectName: "distributionCreatePlanButton"
                    visible: root.activeSection === "plans"
                    text: "Tạo kế hoạch"
                    leadingIcon: "ui/plus"
                    primary: true
                    enabled: root.map(root.map(root.plansData.actions).create).available === true
                    availabilityReason: String(root.map(root.map(root.plansData.actions).create).reason_code || "")
                    onClicked: root.openCreatePlan()
                }
            }
        }

        WorkspaceSectionTabs {
            objectName: "distributionSections"
            visible: !root.embeddedMode && root.activeSection !== "copilot"
            Layout.fillWidth: !root.primarySection
            Layout.preferredWidth: visible && root.primarySection ? 760 : -1
            sections: root.sections
            currentKey: root.activeSection
            onSectionRequested: function(key) { root.activateSection(key) }
        }

        Rectangle {
            visible: root.feedbackMessage.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 34 : 0
            radius: Theme.radiusSmall
            color: Theme.accentSoft
            Text {
                anchors.fill: parent
                anchors.margins: 8
                text: root.feedbackMessage
                color: Theme.accent
                font.pixelSize: Theme.fontMetadata
                verticalAlignment: Text.AlignVCenter
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Loader {
                id: copilotLoader
                objectName: "channelCopilotLoader"
                anchors.fill: parent
                active: root.activeSection === "copilot" || item !== null
                asynchronous: true
                visible: root.activeSection === "copilot" && status === Loader.Ready
                source: "automation/ChannelCopilotPanel.qml"
                onLoaded: item.controlPlaneBridge = root.plane
            }

            Loader {
                id: referencePackLoader
                objectName: "referencePackLoader"
                anchors.fill: parent
                active: root.activeSection === "sources" || item !== null
                asynchronous: true
                visible: root.activeSection === "sources"
                    && status === Loader.Ready
                source: "automation/ReferencePackPanel.qml"
                onLoaded: item.controlPlaneBridge = root.plane
            }

            Loader {
                id: publishingCenterLoader
                objectName: "publishingCenterLoader"
                anchors.fill: parent
                active: root.activeSection === "publishing" || item !== null
                asynchronous: true
                visible: root.activeSection === "publishing"
                    && status === Loader.Ready
                source: "automation/PublishingCenterPanel.qml"
                onLoaded: item.controlPlaneBridge = root.plane
            }

            Item {
                anchors.fill: parent
                visible: root.activeSection === "workflows"
                Automation.AssignmentCenterPanel {
                    anchors.fill: parent
                    controlPlaneBridge: root.plane
                    workflows: root.map(root.rulesData).local_workflows || []
                }
            }

            Foundation.AsyncStateView {
                id: planState
                objectName: "distributionAsyncState"
                anchors.fill: parent
                visible: root.activeSection === "plans"
                accessibleName: "Dữ liệu kế hoạch phân phối"
                viewState: root.viewState
                hasData: root.hasPlans
                emptyTitle: "Chưa có kế hoạch phân phối"
                emptyDescription: "Tạo kế hoạch để chọn nguồn video, nhóm kênh và nhịp đăng."
                emptyIconName: "semantic/workflow"
                emptyEyebrow: "CHƯA CÓ LỊCH PHÂN PHỐI"
                emptyGuidance: [
                    {"title": "Chọn nguồn", "description": "Dùng video đã hoàn thiện trong Studio"},
                    {"title": "Chọn kênh", "description": "Gán nhóm kênh và khoảng cách đăng"},
                    {"title": "Duyệt kế hoạch", "description": "Hệ thống chỉ chạy sau khi được phê duyệt"}
                ]
                emptyActionText: "Tạo kế hoạch"
                emptyActionIconName: "ui/plus"
                emptyActionEnabled: root.map(root.map(root.plansData.actions).create).available === true
                emptyActionReason: String(root.map(
                    root.map(root.plansData.actions).create).reason_code
                    || "DISTRIBUTION_PLAN_CREATE_UNAVAILABLE")
                emptySecondaryActionText: "Làm mới"
                emptySecondaryActionIconName: "ui/refresh-cw"
                onEmptyAction: root.openCreatePlan()
                onEmptySecondaryAction: root.requestPlans({})
                errorMessage: String(root.map(root.snapshotError).message || "Không thể tải kế hoạch phân phối.")
                requiredPermission: "workspace.read"
                freshnessBannerEnabled: false
                onRetry: {
                    if (String(root.map(root.automationSnapshot).snapshot_id || ""))
                        root.requestPlans({})
                    else
                        root.plane.refreshSnapshotTool("automation.snapshot")
                }

                Distribution.DistributionPlanWorkspace {
                    anchors.fill: parent
                    distribution: root.distributionData
                    activity: root.activityData
                    runtime: root.runtimeData
                    onPlanSelected: function(plan) { root.selectPlan(plan) }
                    onCreateRequested: root.openCreatePlan()
                    onEditRequested: function(plan) { root.openEditPlan() }
                    onDeepLinkRequested: function(link) { root.openDeepLink(link) }
                }
            }

            Loader {
                id: scheduleLoader
                objectName: "distributionScheduleLoader"
                anchors.fill: parent
                active: root.activeSection === "calendar" || item !== null
                asynchronous: true
                visible: root.activeSection === "calendar"
                    && status === Loader.Ready
                source: "SchedulePage.qml"
                onLoaded: {
                    item.embeddedMode = true
                    item.activeTab = "calendar"
                }
            }

            Automation.Tool1WorkOrdersPanel {
                anchors.fill: parent
                visible: root.activeSection === "queue"
                controlPlaneBridge: root.plane
            }
        }
    }

    Popup {
        id: editorPopup
        objectName: "distributionPlanEditorDialog"
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(1040, parent ? parent.width - 80 : 1040)
        height: Math.min(780, parent ? parent.height - 80 : 780)
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        padding: 0

        background: Rectangle {
            radius: Theme.radiusLarge
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            spacing: 0
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 58
                Layout.leftMargin: Theme.space4
                Layout.rightMargin: Theme.space3
                Text {
                    Layout.fillWidth: true
                    text: planEditor.creating ? "Tạo kế hoạch phân phối" : "Chỉnh kế hoạch phân phối"
                    color: Theme.text
                    font.pixelSize: Theme.fontSection
                    font.weight: Font.Bold
                }
                AppButton {
                    objectName: "distributionPlanEditorClose"
                    text: "Đóng"
                    subtle: true
                    onClicked: editorPopup.close()
                }
            }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
            Automation.AutomationRulePanel {
                id: planEditor
                objectName: "distributionPlanEditor"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: Theme.space4
                editorOnly: true
                rules: root.rulesData
                distribution: root.distributionData
                onActionRequested: function(action, overrides) {
                    root.dispatchAction(action, overrides)
                }
                onDeepLinkRequested: function(link) { root.openDeepLink(link) }
            }
        }
    }
}
