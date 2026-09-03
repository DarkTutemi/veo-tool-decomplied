pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

AutomationDialog {
    id: root
    objectName: "workflowCreateDialog"
    acceptButtonObjectName: "workflowCreateDialog_acceptButton"
    cancelButtonObjectName: "workflowCreateDialog_cancelButton"
    property var catalog: ({})
    property bool canCreate: false
    property var templateAction: ({})
    signal createRequested(var draft)
    width: 620
    title: "Tạo workflow từ catalog server"
    acceptText: root.templateMode ? "Tạo từ template" : "Tạo workflow"
    formValid: root.canSubmit
    invalidReason: !root.canCreate
        ? String(((root.catalog.actions || {}).create || {}).reason_code
            || "Thiếu quyền tạo workflow")
        : "Nhập mã, tên và chọn đủ cấu hình hợp lệ"
    onOpened: resetDraft()
    onSubmitRequested: root.createRequested(root.draft())

    readonly property var options: root.catalog.configuration || ({})
    readonly property var templatePrefill: root.templateAction.prefill || ({})
    readonly property bool templateMode:
        String(root.templateAction.capability || "") === "workflow.definition.create"
            && Object.keys(root.templatePrefill).length > 0
    readonly property bool canSubmit: root.canCreate
        && workflowKey.text.trim().length > 0
        && workflowName.text.trim().length > 0
        && (root.templateMode || (
            category.currentIndex >= 0
            && capability.currentIndex >= 0
            && channelScope.currentIndex >= 0
            && (String(channelScope.currentValue || "") !== "selected"
                || selectedChannel.currentIndex >= 0)
            && recipe.currentIndex >= 0
            && (String(recipe.currentValue || "") !== "pipeline"
                || pinnedPipeline.currentIndex >= 0)
            && missingPolicy.currentIndex >= 0
            && outputHandoff.currentIndex >= 0))

    function available(items) {
        const source = items || []
        const result = []
        for (let index = 0; index < source.length; index++) {
            if (source[index].available !== false)
                result.push(source[index])
        }
        return result
    }

    function resetDraft() {
        workflowKey.text = ""
        workflowName.text = root.templateMode
            ? String(root.templatePrefill.name || "") : ""
        category.currentIndex = root.indexFor(
            root.catalog.categories || [],
            String(root.templatePrefill.category || ""))
        if (category.currentIndex < 0)
            category.currentIndex = category.count > 0 ? 0 : -1
        capability.currentIndex = capability.count > 0 ? 0 : -1
        channelScope.currentIndex = channelScope.count > 0 ? 0 : -1
        selectedChannel.currentIndex = selectedChannel.count > 0 ? 0 : -1
        recipe.currentIndex = recipe.count > 0 ? 0 : -1
        pinnedPipeline.currentIndex = pinnedPipeline.count > 0 ? 0 : -1
        missingPolicy.currentIndex = missingPolicy.count > 0 ? 0 : -1
        outputHandoff.currentIndex = outputHandoff.count > 0 ? 0 : -1
        retryCount.value = Number((root.options.retry || {}).default || retryCount.from)
        timeout.value = Number(
            (root.options.per_channel_timeout_seconds || {}).default || timeout.from)
        concurrency.value = Number(
            (root.options.max_concurrency || {}).default || concurrency.from)
        root.pending = false
        root.pendingEntityId = ""
        root.errorMessage = ""
    }

    function indexFor(items, key) {
        const source = items || []
        for (let index = 0; index < source.length; ++index) {
            if (String(source[index].key || "") === String(key || ""))
                return index
        }
        return -1
    }

    function descriptor(section, key) {
        const source = root.options[section] || []
        for (let index = 0; index < source.length; ++index) {
            if (String(source[index].key || "") === String(key || ""))
                return source[index]
        }
        return ({})
    }

    function openCreate() {
        root.templateAction = ({})
        root.open()
    }

    function openTemplate(action) {
        root.templateAction = action || ({})
        root.open()
    }

    function draft() {
        return {
            "workflow_key": workflowKey.text.trim(),
            "name": workflowName.text.trim(),
            "category": String(category.currentValue || ""),
            "capability": String(capability.currentValue || ""),
            "channel_scope": String(channelScope.currentValue || ""),
            "channel_id": String(selectedChannel.currentValue || ""),
            "recipe": String(recipe.currentValue || ""),
            "pipeline_selection": String(pinnedPipeline.currentValue || ""),
            "missing_resource_policy": String(missingPolicy.currentValue || ""),
            "retry_count": retryCount.value,
            "timeout_seconds": timeout.value,
            "max_concurrency": concurrency.value,
            "output_handoff": String(outputHandoff.currentValue || ""),
            "template_action": root.templateMode ? root.templateAction : null
        }
    }

    contentItem: GridLayout {
        Accessible.name: "Form tạo workflow từ catalog server"
        Accessible.role: Accessible.Form
        columns: 2
        columnSpacing: 10
        rowSpacing: 8

        Text {
            Layout.columnSpan: 2
            Layout.fillWidth: true
            visible: root.templateMode
            text: root.templateMode
                ? "Template server: " + String(root.templatePrefill.name || "")
                    + " · definition v" + String(root.templateAction.version || "—")
                : ""
            color: Theme.accent
            font.pixelSize: 11
            wrapMode: Text.Wrap
        }
        Text { text: "Mã workflow"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowTextField {
            id: workflowKey
            objectName: "automationCreateWorkflowKey"
            Layout.fillWidth: true
            Accessible.name: "Mã workflow mới"
        }
        Text { text: "Tên"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowTextField {
            id: workflowName
            objectName: "automationCreateWorkflowName"
            Layout.fillWidth: true
            Accessible.name: "Tên workflow mới"
        }
        Text { visible: !root.templateMode; text: "Danh mục"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowComboBox {
            id: category
            objectName: "automationCreateCategory"
            Layout.fillWidth: true
            visible: !root.templateMode
            model: root.catalog.categories || []
            textRole: "label"
            valueRole: "key"
            Accessible.name: "Danh mục workflow"
        }
        Text { visible: !root.templateMode; text: "Capability đầu tiên"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowComboBox {
            id: capability
            objectName: "automationCreateCapability"
            Layout.fillWidth: true
            visible: !root.templateMode
            model: root.catalog.capabilities || []
            textRole: "label"
            valueRole: "key"
            Accessible.name: "Capability đầu tiên từ catalog server"
        }
        Text { visible: !root.templateMode; text: "Phạm vi kênh"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowComboBox {
            id: channelScope
            objectName: "automationCreateChannelScope"
            Layout.fillWidth: true
            visible: !root.templateMode
            model: root.available(root.options.channel_scopes)
            textRole: "label"
            valueRole: "key"
            Accessible.name: "Phạm vi kênh"
        }
        Text {
            visible: !root.templateMode
                && String(channelScope.currentValue || "") === "selected"
            text: "Kênh cụ thể"
            color: Theme.textMuted
            font.pixelSize: 11
        }
        WorkflowComboBox {
            id: selectedChannel
            objectName: "automationCreateSelectedChannel"
            Layout.fillWidth: true
            visible: !root.templateMode
                && String(channelScope.currentValue || "") === "selected"
            model: root.descriptor("channel_scopes", "selected").items || []
            textRole: "label"
            valueRole: "id"
            Accessible.name: "Kênh workspace cho workflow mới"
        }
        Text { visible: !root.templateMode; text: "Recipe"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowComboBox {
            id: recipe
            objectName: "automationCreateRecipe"
            Layout.fillWidth: true
            visible: !root.templateMode
            model: root.available(root.options.recipes)
            textRole: "label"
            valueRole: "key"
            Accessible.name: "Recipe"
        }
        Text {
            visible: !root.templateMode
                && String(recipe.currentValue || "") === "pipeline"
            text: "Pipeline cố định"
            color: Theme.textMuted
            font.pixelSize: 11
        }
        WorkflowComboBox {
            id: pinnedPipeline
            objectName: "automationCreatePinnedPipeline"
            Layout.fillWidth: true
            visible: !root.templateMode
                && String(recipe.currentValue || "") === "pipeline"
            model: root.descriptor("recipes", "pipeline").items || []
            textRole: "label"
            valueRole: "key"
            Accessible.name: "Pipeline Studio ghim cho workflow mới"
        }
        Text { visible: !root.templateMode; text: "Thiếu tài nguyên"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowComboBox {
            id: missingPolicy
            objectName: "automationCreateMissingPolicy"
            Layout.fillWidth: true
            visible: !root.templateMode
            model: root.available(root.options.missing_resource_policies)
            textRole: "label"
            valueRole: "key"
            Accessible.name: "Chính sách thiếu tài nguyên"
        }
        Text { visible: !root.templateMode; text: "Số lần thử"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowSpinBox {
            id: retryCount
            objectName: "automationCreateRetryCount"
            Layout.fillWidth: true
            visible: !root.templateMode
            from: Number((root.options.retry || {}).minimum || 1)
            to: Number((root.options.retry || {}).maximum || 1)
            Accessible.name: "Số lần thử"
        }
        Text { visible: !root.templateMode; text: "Timeout mỗi kênh"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowSpinBox {
            id: timeout
            objectName: "automationCreateTimeout"
            Layout.fillWidth: true
            visible: !root.templateMode
            from: Number((root.options.per_channel_timeout_seconds || {}).minimum || 30)
            to: Number((root.options.per_channel_timeout_seconds || {}).maximum || 30)
            stepSize: 30
            Accessible.name: "Timeout mỗi kênh tính bằng giây"
        }
        Text { visible: !root.templateMode; text: "Đồng thời tối đa"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowSpinBox {
            id: concurrency
            objectName: "automationCreateConcurrency"
            Layout.fillWidth: true
            visible: !root.templateMode
            from: Number((root.options.max_concurrency || {}).minimum || 1)
            to: Number((root.options.max_concurrency || {}).maximum || 1)
            Accessible.name: "Số kênh chạy đồng thời"
        }
        Text { visible: !root.templateMode; text: "Bàn giao đầu ra"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowComboBox {
            id: outputHandoff
            objectName: "automationCreateOutputHandoff"
            Layout.fillWidth: true
            visible: !root.templateMode
            model: root.available(root.options.output_handoffs)
            textRole: "label"
            valueRole: "key"
            Accessible.name: "Nơi bàn giao đầu ra"
        }
    }
}
