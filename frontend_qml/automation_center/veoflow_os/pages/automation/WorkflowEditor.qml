pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Rectangle {
    id: root
    objectName: "workflowEditor"
    property var workflow: ({})
    property var selectedRun: ({})
    property var catalog: ({})
    property var controlPlaneBridge
    property string draftName: String((workflow || {}).name || "")
    property var draftDefinition: ({})
    property bool definitionDirty: false
    property int selectedStageIndex: 0
    property int commandRevision: 0
    signal testRunRequested()
    signal saveRequested(string name, var definition)
    signal enabledChangeRequested(bool enabled)
    signal duplicateRequested()
    signal exportRequested()
    signal archiveRequested()
    signal historyRequested()
    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    clip: true
    Accessible.name: "Trình cấu hình workflow"
    Accessible.role: Accessible.Pane

    readonly property var graph: root.workflow.graph || ({})
    readonly property var steps: root.draftDefinition.steps || []
    readonly property var policies: root.workflow.policies || ({})
    readonly property var effectivePolicies: root.draftDefinition.policies || ({})
    readonly property var configuration: root.draftDefinition.configuration || ({})
    readonly property var selectedDraftStep: root.steps.length > root.selectedStageIndex
        ? root.steps[root.selectedStageIndex] : ({})
    readonly property real stageCardWidth: 160
    readonly property real stageSlotWidth: 180
    readonly property string workflowRevisionKey:
        String((root.workflow || {}).workflow_key || "") + "@"
        + String((root.workflow || {}).version || "") + ":"
        + String((root.workflow || {}).definition_fingerprint || "")
    readonly property bool canEdit: Boolean(((root.workflow.actions || {}).edit || {}).available)
    readonly property bool canTest: Boolean(((root.workflow.actions || {}).test_run || {}).available)
    readonly property string testAvailabilityReason: {
        const action = (root.workflow.actions || {}).test_run || ({})
        if (!root.canTest)
            return String(action.reason_code || "Server chưa công bố action chạy thử")
        if (root.controlPlaneBridge.commandStore.isBusy(
                "workflow.run.preview", "workflow", String(root.workflow.workflow_key || "")))
            return "Đang chờ kết quả chạy thử từ server"
        return ""
    }
    readonly property string saveAvailabilityReason: {
        const action = (root.workflow.actions || {}).edit || ({})
        if (!root.canEdit)
            return String(action.reason_code || "Workflow hiện tại không cho phép chỉnh sửa")
        if (!root.draftName.trim())
            return "Tên workflow không được để trống"
        if (root.draftName.trim() === String(root.workflow.name || "")
                && !root.definitionDirty)
            return "Chưa có thay đổi để lưu"
        if (root.controlPlaneBridge.commandStore.isBusy(
                "workflow.definition.revise", "workflow",
                String(root.workflow.workflow_key || "")))
            return "Đang chờ server lưu revision"
        return ""
    }

    onWorkflowChanged: root.resetDraft()
    onWorkflowRevisionKeyChanged: root.resetDraft()

    Component.onCompleted: root.resetDraft()

    function copy(value) {
        if (value === null || value === undefined)
            return value
        if (Array.isArray(value)
                || (typeof value === "object" && value.length !== undefined)) {
            const items = []
            for (let index = 0; index < value.length; ++index)
                items.push(root.copy(value[index]))
            return items
        }
        if (typeof value === "object") {
            const result = ({})
            const keys = Object.keys(value)
            for (let index = 0; index < keys.length; ++index)
                result[keys[index]] = root.copy(value[keys[index]])
            return result
        }
        return value
    }

    function definitionFromWorkflow() {
        const graph = root.graph || ({})
        const sourceSteps = graph.steps || []
        const steps = []
        for (let index = 0; index < sourceSteps.length; index++) {
            const source = sourceSteps[index] || ({})
            const retry = source.retry || ({})
            steps.push({
                "id": String(source.step_id || source.id || "step_" + String(index + 1)),
                "capability": String(source.capability || ""),
                "depends_on": root.copy(source.depends_on || []),
                "input": root.copy(source.input || ({})),
                "retry": {
                    "max_attempts": retry.max_attempts === undefined
                        ? 1 : retry.max_attempts,
                    "backoff_seconds": retry.backoff_seconds === undefined
                        ? 0 : retry.backoff_seconds,
                    "strategy": String(retry.strategy || "fixed")
                },
                "allow_manual_retry": Boolean(source.allow_manual_retry),
                "allow_skip": Boolean(source.allow_skip),
                "skip_requires_approval": source.skip_requires_approval !== false,
                "failure_policy": String(source.failure_policy || "stop"),
                "resource_key": source.resource_key === undefined
                    ? null : source.resource_key
            })
        }
        return {
            "schema_version": graph.schema_version === undefined
                ? 1 : graph.schema_version,
            "steps": steps,
            "triggers": root.copy(graph.triggers || []),
            "policies": root.copy((root.policies || {}).effective || ({})),
            "configuration": root.copy(root.workflow.configuration || ({}))
        }
    }

    function resetDraft() {
        root.draftName = String((root.workflow || {}).name || "")
        root.draftDefinition = root.definitionFromWorkflow()
        root.definitionDirty = false
        root.selectedStageIndex = 0
    }

    function capabilityAllowed(value) {
        const options = root.catalog.capabilities || []
        for (let index = 0; index < options.length; index++) {
            if (String(options[index].key || "") === String(value || "")
                    && options[index].definition_allowed === true)
                return true
        }
        return false
    }

    function optionAllowed(section, value) {
        const options = ((root.catalog.configuration || ({}))[section]) || []
        for (let index = 0; index < options.length; index++) {
            if (String(options[index].key || "") === String(value || "")
                    && options[index].available !== false)
                return true
        }
        return false
    }

    function catalogOption(section, value) {
        const options = ((root.catalog.configuration || ({}))[section]) || []
        for (let index = 0; index < options.length; index++) {
            if (String(options[index].key || "") === String(value || ""))
                return options[index]
        }
        return null
    }

    function setDraftConfiguration(field, value) {
        if (!root.canEdit)
            return false
        const next = root.copy(root.draftDefinition)
        const configuration = next.configuration || ({})
        if (field === "channel_scope") {
            if (!root.optionAllowed("channel_scopes", value)) return false
            const descriptor = root.catalogOption("channel_scopes", value) || ({})
            const items = descriptor.items || []
            configuration.channel_scope = String(value) === "selected"
                ? {"mode": "selected", "channel_ids": items.length > 0
                    ? [String(items[0].id || "")] : []}
                : {"mode": "runtime", "channel_ids": []}
        } else if (field === "channel_id") {
            const descriptor = root.catalogOption("channel_scopes", "selected") || ({})
            const items = descriptor.items || []
            let allowed = false
            for (let index = 0; index < items.length; ++index) {
                if (String(items[index].id || "") === String(value || "")) {
                    allowed = true
                    break
                }
            }
            if (!allowed) return false
            configuration.channel_scope = {
                "mode": "selected", "channel_ids": [String(value)]
            }
        } else if (field === "recipe") {
            if (!root.optionAllowed("recipes", value)) return false
            const descriptor = root.catalogOption("recipes", value) || ({})
            const items = descriptor.items || []
            configuration.recipe = String(value) === "pipeline" && items.length > 0
                ? {
                    "mode": "pipeline",
                    "pipeline_key": String(items[0].pipeline_key || ""),
                    "version": items[0].version
                }
                : {"mode": "channel_default"}
        } else if (field === "pipeline_selection") {
            const descriptor = root.catalogOption("recipes", "pipeline") || ({})
            const items = descriptor.items || []
            let selected = null
            for (let index = 0; index < items.length; ++index) {
                if (String(items[index].key || "") === String(value || "")) {
                    selected = items[index]
                    break
                }
            }
            if (!selected) return false
            configuration.recipe = {
                "mode": "pipeline",
                "pipeline_key": String(selected.pipeline_key || ""),
                "version": selected.version
            }
        } else if (field === "missing_resource_policy") {
            if (!root.optionAllowed("missing_resource_policies", value)) return false
            configuration.missing_resource_policy = String(value)
        } else if (field === "output_handoff") {
            if (!root.optionAllowed("output_handoffs", value)) return false
            configuration.output_handoff = String(value)
        } else if (field === "per_channel_timeout_seconds") {
            const descriptor = (root.catalog.configuration || ({})).per_channel_timeout_seconds || ({})
            const numeric = Number(value)
            if (!Number.isInteger(numeric)
                    || numeric < Number(descriptor.minimum || 0)
                    || numeric > Number(descriptor.maximum || 0)) return false
            configuration.per_channel_timeout_seconds = value
        } else {
            return false
        }
        next.configuration = configuration
        root.draftDefinition = next
        root.definitionDirty = true
        return true
    }

    function setDraftStepCapability(stepIndex, capability) {
        if (!root.canEdit || !root.capabilityAllowed(capability))
            return false
        const index = Number(stepIndex)
        if (!Number.isInteger(index) || index < 0 || index >= root.steps.length)
            return false
        const next = root.copy(root.draftDefinition)
        next.steps[index].capability = String(capability)
        root.draftDefinition = next
        root.definitionDirty = true
        return true
    }

    function setDraftRetryCount(stepIndex, attempts) {
        if (!root.canEdit)
            return false
        const index = Number(stepIndex)
        const numeric = Number(attempts)
        const descriptor = (root.catalog.configuration || ({})).retry || ({})
        if (!Number.isInteger(index) || index < 0 || index >= root.steps.length
                || !Number.isInteger(numeric)
                || numeric < Number(descriptor.minimum || 0)
                || numeric > Number(descriptor.maximum || 0))
            return false
        const next = root.copy(root.draftDefinition)
        next.steps[index].retry.max_attempts = attempts
        root.draftDefinition = next
        root.definitionDirty = true
        return true
    }

    function setDraftMaxConcurrency(value) {
        if (!root.canEdit)
            return false
        const numeric = Number(value)
        const descriptor = (root.catalog.configuration || ({})).max_concurrency || ({})
        if (!Number.isInteger(numeric)
                || numeric < Number(descriptor.minimum || 0)
                || numeric > Number(descriptor.maximum || 0))
            return false
        const next = root.copy(root.draftDefinition)
        next.policies.max_concurrency = value
        root.draftDefinition = next
        root.definitionDirty = true
        return true
    }

    function runStepState(stepId) {
        const rows = (root.selectedRun || {}).steps || []
        for (let index = 0; index < rows.length; index++) {
            if (String(rows[index].step_id || "") === String(stepId || ""))
                return String(rows[index].state || "")
        }
        return "not_started"
    }

    function stateTone(state) {
        if (state === "succeeded") return Theme.success
        if (state === "failed") return Theme.danger
        if (state === "waiting_approval" || state === "retry_wait") return Theme.warning
        if (state === "running" || state === "ready") return Theme.accent
        return Theme.textFaint
    }

    function stateLabel(state) {
        const value = String(state || "")
        if (value === "succeeded") return "Hoàn thành"
        if (value === "running") return "Đang chạy"
        if (value === "ready") return "Sẵn sàng"
        if (value === "waiting_approval") return "Chờ phê duyệt"
        if (value === "retry_wait") return "Chờ thử lại"
        if (value === "failed") return "Thất bại"
        if (value === "pending" || value === "not_started") return "Chưa chạy"
        return value.replace(/_/g, " ") || "Chưa chạy"
    }

    function stageTitle(step) {
        const source = step || ({})
        const labels = ({
            "ingest_trigger": "Nhận gói nội dung",
            "validate": "Kiểm tra đầu vào",
            "validate_source": "Kiểm tra đầu vào",
            "transform_video": "Tạo video",
            "approval_gate": "Chờ phê duyệt",
            "publish": "Phát hành",
            "publish_video": "Phát hành"
        })
        const stepId = String(source.id || source.step_id || "Bước")
        if (labels[stepId]) return labels[stepId]
        const words = stepId.replace(/[_-]+/g, " ").trim()
        return words.length > 0
            ? words.charAt(0).toUpperCase() + words.slice(1) : "Bước workflow"
    }

    function configKeys(input) {
        const keys = Object.keys(input || ({}))
        return keys.length > 0 ? keys.join(", ") : "Không có input tĩnh"
    }

    function projectedStage(draftStep) {
        const step = draftStep || ({})
        const projected = root.graph.steps || []
        for (let index = 0; index < projected.length; ++index) {
            const candidate = projected[index] || ({})
            if (String(candidate.step_id || candidate.id || "")
                    === String(step.id || step.step_id || "")
                    && String(candidate.capability || "")
                    === String(step.capability || ""))
                return candidate
        }
        return ({})
    }

    function stageIconKey(draftStep) {
        return String(root.projectedStage(draftStep).icon_key || "")
    }

    function stageIconReason(draftStep) {
        return String(root.projectedStage(draftStep).icon_reason_code || "")
    }

    function outcomeLabel(item) {
        const value = item || ({})
        const success = value.on_success || []
        const failure = String(value.on_failure || "")
        if (failure)
            return "Lỗi → " + (failure === "stop" ? "Dừng workflow" : failure)
        if (success.length > 0)
            return "Thành công → " + success.join(", ")
        return "Kết quả do server xác định"
    }

    function policyReasonLabel(reasonCode) {
        const code = String(reasonCode || "")
        if (code === "WORKFLOW_GLOBAL_POLICY_EVIDENCE_UNAVAILABLE")
            return "Chưa có bằng chứng chính sách toàn cục"
        return code.replace(/_/g, " ").toLowerCase()
    }

    function previewRun() {
        if (root.canTest)
            root.testRunRequested()
    }

    function saveDraft() {
        const name = root.draftName.trim()
        const nameDirty = name !== String(root.workflow.name || "")
        if (root.canEdit && name && (nameDirty || root.definitionDirty)) {
            root.saveRequested(
                name, root.definitionDirty ? root.copy(root.draftDefinition) : null)
            return true
        }
        return false
    }

    Connections {
        target: root.controlPlaneBridge ? root.controlPlaneBridge.commandStore : null
        function onChanged(capability, entityType, entityId) { root.commandRevision++ }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 74
            Layout.leftMargin: 14
            Layout.rightMargin: 10
            spacing: 9
            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 220
                spacing: 2
                TextField {
                    id: nameField
                    objectName: "workflowNameField"
                    activeFocusOnTab: true
                    Layout.fillWidth: true
                    text: root.draftName
                    readOnly: !root.canEdit
                    color: Theme.text
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    selectByMouse: true
                    Accessible.name: "Tên workflow"
                    background: Rectangle { color: nameField.activeFocus ? Theme.elevated : "transparent"; radius: Theme.radiusSmall; border.width: nameField.activeFocus ? 1 : 0; border.color: Theme.accent }
                    onTextEdited: root.draftName = text
                }
                RowLayout {
                    spacing: 7
                    Foundation.StatusPill {
                        text: Boolean(root.workflow.enabled) ? "Bật" : "Tắt"
                        tone: Boolean(root.workflow.enabled) ? Theme.success : Theme.textFaint
                    }
                    Text { text: "v" + String(root.workflow.version || "—"); color: Theme.textMuted; font.pixelSize: 11 }
                    Text { text: String(root.workflow.category || ""); color: Theme.textFaint; font.pixelSize: 11 }
                    Text { text: String(root.workflow.description || ""); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight; Layout.maximumWidth: 310 }
                }
            }
            AutomationSwitch {
                objectName: "workflowEnabledToggle"
                Layout.minimumWidth: 58
                Layout.preferredWidth: 58
                Layout.maximumWidth: 58
                activeFocusOnTab: true
                checkable: false
                checked: Boolean(root.workflow.enabled)
                enabled: Boolean(((root.workflow.actions || {}).set_enabled || {}).available)
                    && !root.controlPlaneBridge.commandStore.isBusy(
                        "workflow.definition.set_enabled", "workflow", String(root.workflow.workflow_key || ""))
                availabilityReason: enabled ? ""
                    : String((((root.workflow.actions || {}).set_enabled || {}).reason_code)
                        || "Server chưa công bố action bật/tắt")
                Accessible.name: checked ? "Tắt workflow" : "Bật workflow"
                onClicked: root.enabledChangeRequested(!Boolean(root.workflow.enabled))
            }
            AppButton {
                objectName: "workflowTestRunButton"
                Layout.minimumWidth: 104
                Layout.preferredWidth: 104
                Layout.maximumWidth: 104
                text: "▷  Chạy thử"
                Accessible.name: "Chạy thử workflow bằng preview phía server"
                enabled: root.canTest && !root.controlPlaneBridge.commandStore.isBusy(
                    "workflow.run.preview", "workflow", String(root.workflow.workflow_key || ""))
                availabilityReason: root.testAvailabilityReason
                onClicked: root.previewRun()
            }
            AppButton {
                objectName: "workflowSaveButton"
                Layout.minimumWidth: 132
                Layout.preferredWidth: 132
                Layout.maximumWidth: 132
                text: "Lưu thay đổi"
                primary: true
                Accessible.name: "Lưu revision workflow"
                enabled: root.canEdit && root.draftName.trim().length > 0
                    && (root.draftName.trim() !== String(root.workflow.name || "")
                        || root.definitionDirty)
                    && !root.controlPlaneBridge.commandStore.isBusy(
                        "workflow.definition.revise", "workflow", String(root.workflow.workflow_key || ""))
                availabilityReason: root.saveAvailabilityReason
                onClicked: root.saveDraft()
            }
            AppButton {
                id: overflowButton
                objectName: "workflowOverflowButton"
                Layout.minimumWidth: 42
                Layout.preferredWidth: 42
                Layout.maximumWidth: 42
                text: ""
                leadingIcon: "ui/more-vertical"
                enabled: String(root.workflow.workflow_key || "").length > 0
                availabilityReason: enabled ? "" : "Chưa chọn workflow"
                activeFocusOnTab: true
                Accessible.name: "Thao tác workflow: nhân bản, xuất, lưu trữ và lịch sử"
                onClicked: overflowPopup.open()
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        Flickable {
            objectName: "workflowStageViewport"
            Layout.fillWidth: true
            Layout.preferredHeight: 205
            contentWidth: Math.max(width, stageRow.implicitWidth + 28)
            contentHeight: height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Text {
                id: stageSectionLabel
                objectName: "workflowStageSectionLabel"
                x: 14
                y: 10
                text: "LUỒNG XỬ LÝ · " + String(root.steps.length) + " BƯỚC"
                color: Theme.textFaint
                font.pixelSize: 11
                font.weight: Font.Bold
                font.letterSpacing: 0.5
            }

            Row {
                id: stageRow
                x: 14
                y: 43
                spacing: 0
                Repeater {
                    model: root.steps
                    delegate: Item {
                        id: stageGroup
                        required property var modelData
                        required property int index
                        width: stageGroup.index === root.steps.length - 1
                            ? root.stageCardWidth : root.stageSlotWidth
                        height: 132
                        Rectangle {
                            id: stageCard
                            objectName: "workflowStage_" + String(stageGroup.modelData.id || "")
                            width: root.stageCardWidth
                            height: 132
                            radius: Theme.radiusMedium
                            color: Theme.elevated
                            border.width: 1
                            border.color: root.selectedStageIndex === stageGroup.index
                                ? Theme.accent
                                : root.stateTone(root.runStepState(stageGroup.modelData.id))
                            Accessible.name: "Bước " + String(stageGroup.index + 1)
                                + ". " + String(stageGroup.modelData.id || "")
                            Accessible.role: Accessible.Button
                            Accessible.focusable: true
                            activeFocusOnTab: true
                            Keys.onReturnPressed: root.selectedStageIndex = stageGroup.index
                            Keys.onSpacePressed: root.selectedStageIndex = stageGroup.index
                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 4
                                Row {
                                    width: parent.width
                                    spacing: 7
                                    Rectangle {
                                        width: 22; height: 22; radius: 11
                                        color: root.stateTone(root.runStepState(stageGroup.modelData.id))
                                        Text { anchors.centerIn: parent; text: String(stageGroup.index + 1); color: Theme.base; font.pixelSize: 11; font.weight: Font.Bold }
                                    }
                                    UiIcon {
                                        objectName: "workflowStageIcon_"
                                            + String(stageGroup.modelData.id || stageGroup.index)
                                        name: root.stageIconKey(stageGroup.modelData)
                                        tone: Theme.text
                                        iconSize: 17
                                        visible: name.length > 0
                                        Accessible.description:
                                            root.stageIconReason(stageGroup.modelData)
                                    }
                                    Text {
                                        text: "BƯỚC " + String(stageGroup.index + 1)
                                        color: Theme.textFaint
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                    }
                                }
                                Text {
                                    objectName: "workflowStageTitle_"
                                        + String(stageGroup.modelData.id || stageGroup.index)
                                    width: parent.width
                                    text: root.stageTitle(stageGroup.modelData)
                                    color: Theme.text
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    height: 28
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }
                                Text {
                                    width: parent.width
                                    text: String(stageGroup.modelData.capability || "")
                                    color: Theme.accent
                                    font.pixelSize: 11
                                    elide: Text.ElideMiddle
                                }
                                Text {
                                    width: parent.width
                                    text: root.stateLabel(root.runStepState(stageGroup.modelData.id))
                                    color: root.stateTone(root.runStepState(stageGroup.modelData.id))
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedStageIndex = stageGroup.index
                            }
                        }
                        UiIcon {
                            visible: stageGroup.index !== root.steps.length - 1
                            x: root.stageCardWidth
                                + Math.round((root.stageSlotWidth
                                    - root.stageCardWidth - width) / 2)
                            anchors.verticalCenter: parent.verticalCenter
                            name: "ui/chevron-right"
                            tone: Theme.border
                            iconSize: 18
                        }
                    }
                }
            }
        }

        Flickable {
            id: outcomeViewport
            objectName: "workflowOutcomeViewport"
            Layout.fillWidth: true
            Layout.leftMargin: 14
            Layout.rightMargin: 14
            Layout.preferredHeight: 94
            contentWidth: outcomeRow.implicitWidth
            contentHeight: height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            Text {
                objectName: "workflowOutcomeSectionLabel"
                x: 0
                y: 2
                text: "KHI BƯỚC THẤT BẠI"
                color: Theme.textFaint
                font.pixelSize: 11
                font.weight: Font.Bold
                font.letterSpacing: 0.5
            }
            Row {
                id: outcomeRow
                y: 19
                height: parent.height - y
                spacing: 0
                Repeater {
                    model: (root.graph.outcomes || {}).items || []
                    delegate: Item {
                        id: outcomeBranch
                        required property var modelData
                        required property int index
                        width: outcomeBranch.index
                            === ((root.graph.outcomes || {}).items || []).length - 1
                            ? root.stageCardWidth : root.stageSlotWidth
                        height: outcomeViewport.height

                        Rectangle {
                            id: branchConnector
                            objectName: "workflowOutcomeConnector_"
                                + String(outcomeBranch.modelData.step_id || outcomeBranch.index)
                            anchors.top: parent.top
                            x: Math.round((root.stageCardWidth - width) / 2)
                            width: 2
                            height: 14
                            radius: 1
                            color: Theme.border
                        }
                        Rectangle {
                            x: Math.round((root.stageCardWidth - width) / 2)
                            y: 11
                            width: 7
                            height: 7
                            radius: 4
                            color: Theme.textMuted
                            border.width: 1
                            border.color: Theme.panel
                        }
                        Rectangle {
                            id: outcomeCard
                            objectName: "workflowOutcome_"
                                + String(outcomeBranch.modelData.step_id || outcomeBranch.index)
                            width: root.stageCardWidth
                            anchors.top: parent.top
                            anchors.topMargin: 20
                            height: 54
                            radius: Theme.radiusSmall
                            color: Theme.elevated
                            border.width: 1
                            border.color: String(outcomeBranch.modelData.on_failure || "").length > 0
                                ? Theme.warning : Theme.borderSoft
                            Accessible.name: "Kết quả bước "
                                + String(outcomeBranch.modelData.step_id || "")
                            Accessible.role: Accessible.StaticText
                            Column {
                                anchors.fill: parent
                                anchors.margins: 7
                                spacing: 2
                                Row {
                                    width: parent.width
                                    spacing: 6
                                    UiIcon {
                                        objectName: "workflowOutcomeIcon_"
                                            + String(outcomeBranch.modelData.step_id
                                                || outcomeBranch.index)
                                        name: String(outcomeBranch.modelData.icon_key || "")
                                        tone: Theme.text
                                        iconSize: 15
                                        visible: name.length > 0
                                        Accessible.description:
                                            String(outcomeBranch.modelData.icon_reason_code || "")
                                    }
                                    Text {
                                        width: parent.width - 22
                                        text: root.stageTitle({
                                            "id": outcomeBranch.modelData.step_id,
                                            "capability": root.steps.length > outcomeBranch.index
                                                ? root.steps[outcomeBranch.index].capability : ""
                                        })
                                        color: Theme.text
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                }
                                Text {
                                    width: parent.width
                                    text: root.outcomeLabel(outcomeBranch.modelData)
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
            Text {
                anchors.centerIn: parent
                visible: ((root.graph.outcomes || {}).items || []).length === 0
                text: "Nhánh kết quả chưa có bằng chứng: "
                    + String((root.graph.outcomes || {}).reason_code || "unavailable")
                color: Theme.warning
                font.pixelSize: 11
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 12
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                WorkflowConfigurationEditor {
                    anchors.fill: parent
                    catalog: root.catalog
                    configuration: root.configuration
                    selectedStep: root.selectedDraftStep
                    selectedStepLabel: root.stageTitle(root.selectedDraftStep)
                    selectedStepIndex: root.selectedStageIndex
                    policies: root.effectivePolicies
                    editable: root.canEdit
                    editReason: String((((root.workflow.actions || {}).edit || {}).reason_code)
                        || "")
                    onConfigurationEditRequested: function(field, value) {
                        root.setDraftConfiguration(field, value)
                    }
                    onStepCapabilityChanged: function(stepIndex, capability) {
                        root.setDraftStepCapability(stepIndex, capability)
                    }
                    onRetryCountChanged: function(stepIndex, attempts) {
                        root.setDraftRetryCount(stepIndex, attempts)
                    }
                    onMaxConcurrencyChanged: function(value) {
                        root.setDraftMaxConcurrency(value)
                    }
                }
            }

            Rectangle {
                id: policyEvidence
                objectName: "policyInheritanceEvidence"
                property string evidenceState: String((root.policies.inheritance || {}).state || "unavailable")
                Layout.preferredWidth: 236
                Layout.fillHeight: true
                radius: Theme.radiusMedium
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                Accessible.name: "Chính sách workflow. Kế thừa toàn cục " + evidenceState
                Accessible.role: Accessible.Pane
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6
                    Text { text: "Chính sách hiệu lực"; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Tối đa đồng thời"; color: Theme.textFaint; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                        Text { text: root.effectivePolicies.max_concurrency === undefined ? "—" : String(root.effectivePolicies.max_concurrency); color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Lease bước"; color: Theme.textFaint; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                        Text { text: root.effectivePolicies.step_lease_seconds === undefined ? "—" : String(root.effectivePolicies.step_lease_seconds) + " giây"; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Dừng khi lỗi"; color: Theme.textFaint; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                        Foundation.StatusPill {
                            text: root.effectivePolicies.stop_on_failure === true ? "Bật" : root.effectivePolicies.stop_on_failure === false ? "Tắt" : "Chưa rõ"
                            tone: root.effectivePolicies.stop_on_failure === true ? Theme.warning : Theme.textFaint
                        }
                    }
                    Item { Layout.fillHeight: true }
                    Foundation.StatusPill {
                        text: policyEvidence.evidenceState === "unavailable" ? "Kế thừa: chưa có bằng chứng" : "Kế thừa: " + policyEvidence.evidenceState
                        tone: policyEvidence.evidenceState === "unavailable" ? Theme.warning : Theme.success
                    }
                    Text {
                        objectName: "policyInheritanceReasonText"
                        Layout.fillWidth: true
                        visible: text.length > 0
                        text: root.policyReasonLabel(
                            (root.policies.inheritance || {}).reason_code)
                        color: Theme.textFaint
                        font.pixelSize: 11
                        maximumLineCount: 2
                        wrapMode: Text.WrapAnywhere
                        elide: Text.ElideRight
                        Accessible.description: String(
                            (root.policies.inheritance || {}).reason_code || "")
                    }
                }
            }
        }
    }

    Popup {
        id: overflowPopup
        objectName: "workflowOverflowPopup"
        parent: root
        x: Math.max(8, root.width - width - 12)
        y: 66
        width: 218
        padding: 8
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            radius: Theme.radiusMedium
            color: Theme.elevated
            border.width: 1
            border.color: Theme.border
        }
        contentItem: ColumnLayout {
            spacing: 4
            AppButton {
                objectName: "workflowDuplicateAction"
                Layout.fillWidth: true
                text: "Nhân bản workflow"
                enabled: Boolean(((root.workflow.actions || {}).duplicate || {}).available)
                availabilityReason: enabled ? ""
                    : String((((root.workflow.actions || {}).duplicate || {}).reason_code)
                        || "Server chưa cho phép nhân bản")
                activeFocusOnTab: true
                Accessible.name: text
                onClicked: {
                    overflowPopup.close()
                    root.duplicateRequested()
                }
            }
            AppButton {
                objectName: "workflowExportAction"
                Layout.fillWidth: true
                text: "Xuất definition"
                enabled: Boolean(((root.workflow.actions || {}).export || {}).available)
                availabilityReason: enabled ? ""
                    : String((((root.workflow.actions || {}).export || {}).reason_code)
                        || "Server chưa cho phép xuất definition")
                activeFocusOnTab: true
                Accessible.name: text
                onClicked: {
                    overflowPopup.close()
                    root.exportRequested()
                }
            }
            AppButton {
                objectName: "workflowHistoryAction"
                Layout.fillWidth: true
                text: "Xem lịch sử phiên bản"
                enabled: Boolean(((root.workflow.actions || {}).history || {}).available)
                availabilityReason: enabled ? ""
                    : String((((root.workflow.actions || {}).history || {}).reason_code)
                        || "Server chưa cho phép đọc lịch sử")
                activeFocusOnTab: true
                Accessible.name: text
                onClicked: {
                    overflowPopup.close()
                    root.historyRequested()
                }
            }
            AppButton {
                objectName: "workflowArchiveAction"
                Layout.fillWidth: true
                text: "Lưu trữ workflow"
                enabled: Boolean(((root.workflow.actions || {}).archive || {}).available)
                availabilityReason: enabled ? ""
                    : String((((root.workflow.actions || {}).archive || {}).reason_code)
                        || "Server chưa cho phép lưu trữ")
                activeFocusOnTab: true
                Accessible.name: text
                onClicked: {
                    overflowPopup.close()
                    root.archiveRequested()
                }
            }
        }
    }
}
