pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "workflowConfigurationEditor"
    property var catalog: ({})
    property var configuration: ({})
    property var selectedStep: ({})
    property string selectedStepLabel: ""
    property var policies: ({})
    property bool editable: false
    property string editReason: ""
    signal configurationEditRequested(string field, var value)
    signal stepCapabilityChanged(int stepIndex, string capability)
    signal retryCountChanged(int stepIndex, int attempts)
    signal maxConcurrencyChanged(int value)
    property int selectedStepIndex: 0
    radius: Theme.radiusMedium
    color: Theme.elevated
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.name: "Cấu hình workflow AU-C01 đến AU-C07"
    Accessible.role: Accessible.Pane

    readonly property var options: root.catalog.configuration || ({})
    readonly property var selectedChannelScope: root.configuration.channel_scope || ({})
    readonly property var selectedRecipe: root.configuration.recipe || ({})

    function descriptor(section, key) {
        const source = root.options[section] || []
        for (let index = 0; index < source.length; ++index) {
            if (String(source[index].key || "") === String(key || ""))
                return source[index]
        }
        return ({})
    }

    function available(items) {
        const source = items || []
        const result = []
        for (let index = 0; index < source.length; index++) {
            if (source[index].available !== false)
                result.push(source[index])
        }
        return result
    }

    function indexFor(items, key) {
        const source = items || []
        for (let index = 0; index < source.length; index++) {
            if (String(source[index].key || "") === String(key || ""))
                return index
        }
        return source.length > 0 ? 0 : -1
    }

    function bound(value, descriptor) {
        const source = descriptor || ({})
        const minimum = Number(source.minimum || 0)
        const maximum = Number(source.maximum || 0)
        return Math.max(minimum, Math.min(maximum, Number(value || minimum)))
    }

    function unavailableReason(hasOptions) {
        if (!root.editable)
            return root.editReason || "Workflow hiện tại không cho phép chỉnh sửa"
        return hasOptions ? "" : "Catalog server không có lựa chọn khả dụng"
    }

    GridLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        columns: 4
        columnSpacing: 9
        rowSpacing: 2

        Text {
            Layout.columnSpan: 4
            Layout.fillWidth: true
            text: "Cấu hình · " + (root.selectedStepLabel
                || String(root.selectedStep.id || "Chưa chọn"))
            color: Theme.text
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        Text { text: "Phạm vi kênh"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowComboBox {
            id: channelScope
            objectName: "automationChannelScopeEditor"
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.maximumHeight: 32
            model: root.available(root.options.channel_scopes)
            textRole: "label"
            valueRole: "key"
            currentIndex: root.indexFor(
                model, String((root.configuration.channel_scope || {}).mode || ""))
            enabled: root.editable && count > 0
            availabilityReason: root.unavailableReason(count > 0)
            Accessible.name: "AU-C01 phạm vi kênh"
            onActivated: root.configurationEditRequested("channel_scope", currentValue)
        }

        Text {
            text: "Kênh cụ thể"
            color: Theme.textMuted
            font.pixelSize: 11
            visible: String(root.selectedChannelScope.mode || "") === "selected"
        }
        WorkflowComboBox {
            objectName: "automationSelectedChannelEditor"
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.maximumHeight: 32
            visible: String(root.selectedChannelScope.mode || "") === "selected"
            model: root.descriptor("channel_scopes", "selected").items || []
            textRole: "label"
            valueRole: "id"
            currentIndex: root.indexFor(
                model, String((root.selectedChannelScope.channel_ids || [""])[0] || ""))
            enabled: root.editable && count > 0
            availabilityReason: root.unavailableReason(count > 0)
            Accessible.name: "Kênh workspace được ghim vào workflow"
            onActivated: root.configurationEditRequested("channel_id", currentValue)
        }

        Text { text: "Recipe"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowComboBox {
            id: recipe
            objectName: "automationRecipeEditor"
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.maximumHeight: 32
            model: root.available(root.options.recipes)
            textRole: "label"
            valueRole: "key"
            currentIndex: root.indexFor(
                model, String((root.configuration.recipe || {}).mode || ""))
            enabled: root.editable && count > 0
            availabilityReason: root.unavailableReason(count > 0)
            Accessible.name: "AU-C02 recipe"
            onActivated: root.configurationEditRequested("recipe", currentValue)
        }

        Text {
            text: "Pipeline cố định"
            color: Theme.textMuted
            font.pixelSize: 11
            visible: String(root.selectedRecipe.mode || "") === "pipeline"
        }
        WorkflowComboBox {
            objectName: "automationPinnedPipelineEditor"
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.maximumHeight: 32
            visible: String(root.selectedRecipe.mode || "") === "pipeline"
            model: root.descriptor("recipes", "pipeline").items || []
            textRole: "label"
            valueRole: "key"
            currentIndex: root.indexFor(
                model,
                String(root.selectedRecipe.pipeline_key || "") + "@"
                    + String(root.selectedRecipe.version || ""))
            enabled: root.editable && count > 0
            availabilityReason: root.unavailableReason(count > 0)
            Accessible.name: "Pipeline Studio được ghim theo key và version"
            onActivated: root.configurationEditRequested(
                "pipeline_selection", currentValue)
        }

        Text { text: "Thiếu tài nguyên"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowComboBox {
            id: missingPolicy
            objectName: "automationMissingResourceEditor"
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.maximumHeight: 32
            model: root.available(root.options.missing_resource_policies)
            textRole: "label"
            valueRole: "key"
            currentIndex: root.indexFor(
                model, String(root.configuration.missing_resource_policy || ""))
            enabled: root.editable && count > 0
            availabilityReason: root.unavailableReason(count > 0)
            Accessible.name: "AU-C03 chính sách thiếu tài nguyên"
            onActivated: root.configurationEditRequested(
                "missing_resource_policy", currentValue)
        }

        Text { text: "Số lần thử"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowSpinBox {
            id: retryCount
            objectName: "automationRetryCountEditor"
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.maximumHeight: 32
            from: Number((root.options.retry || {}).minimum || 1)
            to: Number((root.options.retry || {}).maximum || 1)
            value: root.bound(
                Number((root.selectedStep.retry || {}).max_attempts || from),
                root.options.retry)
            enabled: root.editable
            availabilityReason: root.unavailableReason(true)
            Accessible.name: "AU-C04 số lần thử lại"
            onValueModified: root.retryCountChanged(root.selectedStepIndex, value)
        }

        Text { text: "Timeout mỗi kênh"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowSpinBox {
            id: timeout
            objectName: "automationChannelTimeoutEditor"
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.maximumHeight: 32
            from: Number((root.options.per_channel_timeout_seconds || {}).minimum || 30)
            to: Number((root.options.per_channel_timeout_seconds || {}).maximum || 30)
            value: root.bound(
                Number(root.configuration.per_channel_timeout_seconds || from),
                root.options.per_channel_timeout_seconds)
            stepSize: 30
            enabled: root.editable
            availabilityReason: root.unavailableReason(true)
            Accessible.name: "AU-C05 timeout mỗi kênh tính bằng giây"
            onValueModified: root.configurationEditRequested(
                "per_channel_timeout_seconds", value)
        }

        Text { text: "Đồng thời tối đa"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowSpinBox {
            id: concurrency
            objectName: "automationConcurrencyEditor"
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.maximumHeight: 32
            from: Number((root.options.max_concurrency || {}).minimum || 1)
            to: Number((root.options.max_concurrency || {}).maximum || 1)
            value: root.bound(
                Number(root.policies.max_concurrency || from),
                root.options.max_concurrency)
            enabled: root.editable
            availabilityReason: root.unavailableReason(true)
            Accessible.name: "AU-C06 số kênh chạy đồng thời"
            onValueModified: root.maxConcurrencyChanged(value)
        }

        Text { text: "Bàn giao đầu ra"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowComboBox {
            id: outputHandoff
            objectName: "automationOutputHandoffEditor"
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.maximumHeight: 32
            model: root.available(root.options.output_handoffs)
            textRole: "label"
            valueRole: "key"
            currentIndex: root.indexFor(
                model, String(root.configuration.output_handoff || ""))
            enabled: root.editable && count > 0
            availabilityReason: root.unavailableReason(count > 0)
            Accessible.name: "AU-C07 nơi bàn giao đầu ra"
            onActivated: root.configurationEditRequested("output_handoff", currentValue)
        }

        Text { text: "Capability bước"; color: Theme.textMuted; font.pixelSize: 11 }
        WorkflowComboBox {
            id: capability
            objectName: "automationStepCapabilityEditor"
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.maximumHeight: 32
            model: root.catalog.capabilities || []
            textRole: "label"
            valueRole: "key"
            currentIndex: root.indexFor(
                model, String(root.selectedStep.capability || ""))
            enabled: root.editable && count > 0
            availabilityReason: root.unavailableReason(count > 0)
            Accessible.name: "Capability bước từ catalog server"
            onActivated: root.stepCapabilityChanged(
                root.selectedStepIndex, String(currentValue || ""))
        }
    }
}
