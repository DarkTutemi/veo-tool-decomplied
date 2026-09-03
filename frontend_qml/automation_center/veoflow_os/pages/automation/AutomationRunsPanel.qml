pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Rectangle {
    id: root
    objectName: "automationRunsPanel"
    property var section: ({})
    property var controlPlaneBridge
    property int commandRevision: 0
    signal filtersRequested(string workflowKey, string state)
    signal nextPageRequested()
    signal exportRequested(string workflowKey, string state)
    signal runSelected(var item)

    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    clip: true
    Accessible.name: "Danh sách lượt chạy workflow từ server"
    Accessible.role: Accessible.Table

    readonly property var items: root.section.items || []
    readonly property var exportAction: (root.section.actions || {}).export || ({})
    readonly property bool exportBusy: {
        const revision = root.commandRevision
        return root.controlPlaneBridge && root.controlPlaneBridge.commandStore.isBusy(
            "workflow.run.export", "global", "global")
    }
    readonly property var stateOptions:
        ((root.section.filter_options || {}).states || [])

    function stateTone(state) {
        const value = String(state || "")
        if (value === "succeeded") return Theme.success
        if (value === "failed" || value === "stopped") return Theme.danger
        if (value === "waiting_approval") return Theme.warning
        if (value === "running" || value === "paused") return Theme.accent
        return Theme.textFaint
    }

    function durationText(seconds) {
        const value = Number(seconds)
        if (!isFinite(value) || value < 0) return "—"
        const minutes = Math.floor(value / 60)
        const remain = Math.floor(value % 60)
        return String(minutes).padStart(2, "0") + ":" + String(remain).padStart(2, "0")
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
            Layout.preferredHeight: 66
            Layout.leftMargin: 16
            Layout.rightMargin: 12
            spacing: 8
            ColumnLayout {
                Layout.preferredWidth: 240
                spacing: 2
                Text { text: "Lượt chạy"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.DemiBold }
                Text { text: String(root.section.total || root.items.length) + " lượt theo bộ lọc server"; color: Theme.textFaint; font.pixelSize: 11 }
            }
            Item { Layout.fillWidth: true }
            WorkflowTextField {
                id: workflowFilter
                objectName: "automationRunsWorkflowFilter"
                Layout.preferredWidth: 220
                placeholderText: "Workflow key"
                text: String((root.section.filter || {}).workflow_key || "")
                Accessible.name: "Lọc lượt chạy theo workflow key"
                onAccepted: root.filtersRequested(text.trim(), String(stateFilter.currentValue || ""))
            }
            WorkflowComboBox {
                id: stateFilter
                objectName: "automationRunsStateFilter"
                Layout.preferredWidth: 180
                model: root.stateOptions
                textRole: "label"
                valueRole: "key"
                currentIndex: {
                    const selected = String((root.section.filter || {}).state || "")
                    for (let index = 0; index < root.stateOptions.length; ++index) {
                        if (String(root.stateOptions[index].key) === selected) return index
                    }
                    return 0
                }
                enabled: root.stateOptions.length > 0
                availabilityReason: enabled ? "" : "Server chưa cung cấp bộ lọc trạng thái"
                Accessible.name: "Lọc lượt chạy theo trạng thái"
            }
            AppButton {
                objectName: "automationRunsApplyFiltersButton"
                text: "Áp dụng"
                onClicked: root.filtersRequested(
                    workflowFilter.text.trim(), String(stateFilter.currentValue || ""))
            }
            AppButton {
                objectName: "automationRunsExportButton"
                text: "Xuất dữ liệu"
                leadingIcon: "ui/external-link"
                enabled: Boolean(root.exportAction.available) && !root.exportBusy
                availabilityReason: enabled ? "" : String(root.exportAction.reason_code || "Server không cho phép xuất")
                onClicked: root.exportRequested(
                    workflowFilter.text.trim(), String(stateFilter.currentValue || ""))
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 8
            Text { Layout.preferredWidth: 132; text: "Thời gian"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.fillWidth: true; text: "Workflow"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.preferredWidth: 110; text: "Trigger"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.preferredWidth: 110; text: "Phạm vi"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.preferredWidth: 82; text: "Thời lượng"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.preferredWidth: 116; text: "Kết quả"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.preferredWidth: 150; text: "Giai đoạn lỗi"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
        }

        ListView {
            id: runsList
            objectName: "automationRunsList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            spacing: 2
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.items
            delegate: Rectangle {
                id: runRow
                required property var modelData
                readonly property string runId: String(runRow.modelData.id || "")
                objectName: "automationRunsRow_" + runId
                width: runsList.width
                height: 44
                radius: Theme.radiusSmall
                color: rowHover.hovered ? Theme.hover : "transparent"
                Accessible.name: "Lượt chạy " + runId
                Accessible.role: Accessible.Row
                activeFocusOnTab: true
                Accessible.focusable: true
                Keys.onReturnPressed: runRow.activate()
                Keys.onEnterPressed: runRow.activate()
                Keys.onSpacePressed: runRow.activate()
                function activate() { root.runSelected(runRow.modelData) }
                HoverHandler { id: rowHover }
                TapHandler { onTapped: runRow.activate() }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8
                    Text { Layout.preferredWidth: 132; text: String(runRow.modelData.started_at || "—").replace("T", " ").slice(0, 16); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                    Text { Layout.fillWidth: true; text: String(runRow.modelData.workflow_key || "—") + " · v" + String(runRow.modelData.workflow_version || "—"); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                    Text { Layout.preferredWidth: 110; text: String(runRow.modelData.trigger_type || "—"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                    Text { Layout.preferredWidth: 110; text: String((runRow.modelData.scope_refs || []).length) + " tham chiếu"; color: Theme.textMuted; font.pixelSize: 11 }
                    Text { Layout.preferredWidth: 82; text: root.durationText(runRow.modelData.duration_seconds); color: Theme.textMuted; font.pixelSize: 11 }
                    Foundation.StatusPill { Layout.preferredWidth: 116; text: String(runRow.modelData.state || "—"); tone: root.stateTone(runRow.modelData.state) }
                    Text { Layout.preferredWidth: 150; text: String(runRow.modelData.failed_stage || "—"); color: runRow.modelData.failed_stage ? Theme.danger : Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            Layout.leftMargin: 16
            Layout.rightMargin: 12
            Text { text: String(root.items.length) + " / " + String(root.section.total || root.items.length); color: Theme.textFaint; font.pixelSize: 11 }
            Item { Layout.fillWidth: true }
            AppButton {
                objectName: "automationRunsNextPageButton"
                text: "Trang tiếp"
                enabled: root.section.next_cursor !== null
                    && String(root.section.next_cursor || "").length > 0
                availabilityReason: enabled ? "" : "Server không trả cursor trang tiếp"
                onClicked: root.nextPageRequested()
            }
        }
    }
}
