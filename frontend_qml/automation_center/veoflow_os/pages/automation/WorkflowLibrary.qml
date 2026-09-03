pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "workflowLibrary"
    property var workflowModel: null
    property var libraryItems: []
    property var categoryGroups: []
    property var categoryCounts: ({})
    property var categoryCatalog: []
    property var statusOptions: []
    property string selectedWorkflowKey: ""
    property var controlPlaneBridge
    property string searchText: ""
    property string statusFilter: ""
    property string categoryFilter: ""
    property var nextCursor: null
    property int commandRevision: 0
    signal workflowSelected(var item)
    signal enabledChangeRequested(var item, bool enabled)
    signal filtersRequested(string search, string status, string category)
    signal nextPageRequested()
    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    clip: true
    Accessible.name: "Thư viện workflow"
    Accessible.role: Accessible.List

    readonly property var categoryOptions: {
        const values = [{"value": "", "label": "Tất cả danh mục"}]
        const source = root.categoryCatalog || []
        for (let index = 0; index < source.length; index++) {
            const item = source[index] || ({})
            const key = String(item.key || "")
            if (key.length > 0)
                values.push({"value": key, "label": String(item.label || key)})
        }
        return values
    }

    function categoryDescriptor(value) {
        const key = String(value || "")
        const groups = root.categoryGroups || []
        for (let index = 0; index < groups.length; ++index) {
            if (String(groups[index].key || "") === key)
                return groups[index]
        }
        const source = root.categoryCatalog || []
        for (let index = 0; index < source.length; ++index) {
            if (String(source[index].key || "") === key)
                return source[index]
        }
        return ({})
    }

    function categoryLabel(value) {
        const key = String(value || "")
        const descriptor = root.categoryDescriptor(key)
        return String(descriptor.label || key || "Khác")
    }

    function categoryIconKey(value) {
        return String(root.categoryDescriptor(value).icon_key || "")
    }

    function projectedItem(workflowKey) {
        const key = String(workflowKey || "")
        const source = root.libraryItems || []
        for (let index = 0; index < source.length; ++index) {
            if (String(source[index].workflow_key || "") === key)
                return source[index]
        }
        return ({})
    }

    function stateLabel(value) {
        const state = String(value || "")
        if (state === "succeeded") return "Thành công"
        if (state === "failed") return "Thất bại"
        if (state === "running") return "Đang chạy"
        if (state === "waiting_approval") return "Chờ duyệt"
        return state || "Chưa chạy"
    }

    Connections {
        target: root.controlPlaneBridge ? root.controlPlaneBridge.commandStore : null
        function onChanged(capability, entityType, entityId) {
            root.commandRevision++
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.topMargin: 10
            Layout.bottomMargin: 8
            spacing: 7
            RowLayout {
                Layout.fillWidth: true
                Text { text: "Workflow của bạn"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.DemiBold }
                Item { Layout.fillWidth: true }
                Text { text: String(root.workflowModel ? root.workflowModel.count : 0); color: Theme.textFaint; font.pixelSize: 11 }
            }
            TextField {
                id: searchField
                objectName: "workflowSearch"
                activeFocusOnTab: true
                Layout.fillWidth: true
                implicitHeight: 34
                placeholderText: "Tìm workflow…"
                text: root.searchText
                color: Theme.text
                font.pixelSize: 11
                selectByMouse: true
                Accessible.name: "Tìm workflow"
                background: Rectangle { radius: Theme.radiusSmall; color: Theme.elevated; border.width: 1; border.color: searchField.activeFocus ? Theme.accent : Theme.borderSoft }
                onTextEdited: searchDelay.restart()
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                WorkflowComboBox {
                    id: statusBox
                    objectName: "workflowStatusFilter"
                    activeFocusOnTab: true
                    Layout.fillWidth: true
                    implicitHeight: 32
                    textRole: "label"
                    valueRole: "key"
                    model: root.statusOptions
                    enabled: root.statusOptions.length > 0
                    availabilityReason: enabled ? ""
                        : "Server chưa cung cấp bộ lọc trạng thái workflow"
                    Accessible.name: "Lọc workflow theo trạng thái"
                    onActivated: root.filtersRequested(searchField.text.trim(), String(currentValue || ""), root.categoryFilter)
                }
                WorkflowComboBox {
                    id: categoryBox
                    objectName: "workflowCategoryFilter"
                    activeFocusOnTab: true
                    Layout.fillWidth: true
                    implicitHeight: 32
                    textRole: "label"
                    valueRole: "value"
                    model: root.categoryOptions
                    Accessible.name: "Lọc workflow theo danh mục"
                    onActivated: root.filtersRequested(searchField.text.trim(), root.statusFilter, String(currentValue || ""))
                }
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        ListView {
            id: workflowList
            objectName: "workflowList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 6
            spacing: 3
            clip: true
            cacheBuffer: Math.max(0, height * 2)
            model: root.workflowModel
            boundsBehavior: Flickable.StopAtBounds
            section.property: "category"
            section.criteria: ViewSection.FullString
            section.delegate: Rectangle {
                id: categoryHeader
                required property string section
                readonly property var descriptor: root.categoryDescriptor(categoryHeader.section)
                readonly property string labelText: String(categoryHeader.descriptor.label || categoryHeader.section)
                readonly property string iconKey: String(categoryHeader.descriptor.icon_key || "")
                readonly property int groupTotal: Number(categoryHeader.descriptor.total || 0)
                objectName: "workflowCategoryHeader_" + categoryHeader.section
                width: workflowList.width
                height: 26
                color: Theme.panel
                z: 1
                Accessible.name: categoryHeader.labelText + ", "
                    + String(categoryHeader.groupTotal) + " workflow"
                Accessible.role: Accessible.Heading

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 7
                    anchors.rightMargin: 5
                    spacing: 6
                    UiIcon {
                        objectName: "workflowCategoryHeaderIcon_" + categoryHeader.section
                        name: categoryHeader.iconKey
                        tone: Theme.textMuted
                        iconSize: 14
                        visible: categoryHeader.iconKey.length > 0
                    }
                    Text {
                        text: categoryHeader.labelText
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                        font.weight: Font.DemiBold
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        Layout.preferredWidth: Math.max(20, countLabel.implicitWidth + 10)
                        Layout.preferredHeight: 18
                        radius: 9
                        color: Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft
                        Text {
                            id: countLabel
                            anchors.centerIn: parent
                            text: String(categoryHeader.groupTotal)
                            color: Theme.textFaint
                            font.pixelSize: Theme.fontMetadata
                        }
                    }
                }
            }

            delegate: Rectangle {
                id: workflowRow
                required property string definition_id
                required property string workflow_key
                required property int version
                required property string name
                required property string category
                required property string state_value
                required property bool enabled_value
                required property int step_count
                required property var last_run
                required property var deep_link
                readonly property var projected: root.projectedItem(workflowRow.workflow_key)
                readonly property string categoryIconKey:
                    String(workflowRow.projected.category_icon_key
                        || root.categoryIconKey(workflowRow.category))
                readonly property string workflowIconKey:
                    String(workflowRow.projected.icon_key || "")
                readonly property string workflowIconReason:
                    String(workflowRow.projected.icon_reason_code || "")
                readonly property string categoryLabelText:
                    String(workflowRow.projected.category_label
                        || root.categoryLabel(workflowRow.category))
                readonly property var setEnabledAction:
                    (workflowRow.projected.actions || {}).set_enabled || ({})
                readonly property var itemData: ({
                    "id": workflowRow.definition_id,
                    "workflow_key": workflowRow.workflow_key,
                    "version": workflowRow.version,
                    "name": workflowRow.name,
                    "category": workflowRow.category,
                    "category_label": workflowRow.categoryLabelText,
                    "category_icon_key": workflowRow.categoryIconKey,
                    "icon_key": workflowRow.workflowIconKey,
                    "icon_reason_code": workflowRow.workflowIconReason,
                    "state": workflowRow.state_value,
                    "enabled": workflowRow.enabled_value,
                    "step_count": workflowRow.step_count,
                    "last_run": workflowRow.last_run,
                    "deep_link": workflowRow.deep_link,
                    "actions": workflowRow.projected.actions || ({})
                })
                width: workflowList.width
                height: 52
                radius: Theme.radiusSmall
                color: workflowRow.workflow_key === root.selectedWorkflowKey
                    ? Theme.accentSoft : (rowHover.hovered ? Theme.hover : "transparent")
                border.width: workflowRow.workflow_key === root.selectedWorkflowKey ? 1 : 0
                border.color: Theme.accent
                objectName: "workflowRow_" + workflowRow.workflow_key
                Accessible.name: String(workflowRow.name || "Workflow")
                Accessible.role: Accessible.ListItem
                activeFocusOnTab: true
                Accessible.focusable: true
                Keys.onReturnPressed: workflowRow.activate()
                Keys.onEnterPressed: workflowRow.activate()
                Keys.onSpacePressed: workflowRow.activate()
                readonly property bool busy: {
                    const revision = root.commandRevision
                    return root.controlPlaneBridge
                        ? root.controlPlaneBridge.commandStore.isBusy(
                            "workflow.definition.set_enabled",
                            "workflow",
                            workflowRow.workflow_key
                        ) : false
                }
                function activate() { root.workflowSelected(workflowRow.itemData) }
                function toggleEnabled() {
                    if (workflowRow.setEnabledAction.available && !busy)
                        root.enabledChangeRequested(workflowRow.itemData, !workflowRow.enabled_value)
                }

                HoverHandler { id: rowHover }
                TapHandler { onTapped: workflowRow.activate() }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 9
                    anchors.rightMargin: 7
                    spacing: 8
                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 8
                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.16)
                        visible: workflowRow.workflowIconKey.length > 0
                        Accessible.name: "Biểu tượng " + String(workflowRow.name || "workflow")
                        Accessible.description: workflowRow.workflowIconReason
                        UiIcon {
                            objectName: "workflowIcon_" + workflowRow.workflow_key
                            anchors.centerIn: parent
                            name: workflowRow.workflowIconKey
                            tone: Theme.accent
                            iconSize: 18
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { Layout.fillWidth: true; text: String(workflowRow.name || workflowRow.workflow_key || "Workflow"); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                        Text {
                            Layout.fillWidth: true
                            text: "v" + String(workflowRow.version || "—") + " · "
                                + (workflowRow.last_run
                                    ? root.stateLabel(workflowRow.last_run.state)
                                    : "Chưa có lượt chạy")
                            color: workflowRow.last_run ? Theme.textMuted : Theme.textFaint
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }
                    AutomationSwitch {
                        objectName: "workflowEnable_" + workflowRow.workflow_key
                        activeFocusOnTab: true
                        checkable: false
                        checked: workflowRow.enabled_value
                        enabled: Boolean(workflowRow.setEnabledAction.available)
                            && !workflowRow.busy
                        Accessible.name: (checked ? "Tắt " : "Bật ") + String(workflowRow.name || "workflow")
                        availabilityReason: enabled ? ""
                            : String(workflowRow.setEnabledAction.reason_code
                                || "Server chưa công bố action bật/tắt")
                        onClicked: workflowRow.toggleEnabled()
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.bottomMargin: 8
            Layout.preferredHeight: 28
            Text { text: String(root.workflowModel ? root.workflowModel.count : 0) + " / " + String(root.categoryCounts ? Object.values(root.categoryCounts).reduce((a, b) => a + b, 0) : 0); color: Theme.textFaint; font.pixelSize: 11 }
            Item { Layout.fillWidth: true }
            AppButton {
                objectName: "workflowLibraryNextPageButton"
                text: "Trang tiếp"
                implicitHeight: 28
                enabled: root.nextCursor !== null && String(root.nextCursor || "").length > 0
                availabilityReason: enabled ? "" : "Server không trả cursor trang tiếp"
                onClicked: root.nextPageRequested()
            }
        }
    }

    Timer {
        id: searchDelay
        interval: 260
        repeat: false
        onTriggered: root.filtersRequested(searchField.text.trim(), root.statusFilter, root.categoryFilter)
    }
}
