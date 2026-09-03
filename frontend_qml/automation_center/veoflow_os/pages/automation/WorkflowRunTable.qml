pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Rectangle {
    id: root
    objectName: "workflowRunTable"
    property var runModel: null
    property var runItems: []
    property var nextCursor: null
    signal runSelected(var item)
    signal nextPageRequested()
    signal viewAllRequested()
    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    clip: true
    Accessible.name: "Lượt chạy workflow gần đây"
    Accessible.role: Accessible.Table

    function resultTone(state) {
        if (state === "succeeded") return Theme.success
        if (state === "failed" || state === "stopped") return Theme.danger
        if (state === "waiting_approval") return Theme.warning
        return Theme.accent
    }

    function durationText(seconds) {
        const value = Number(seconds)
        if (!isFinite(value) || value < 0)
            return "—"
        const minutes = Math.floor(value / 60)
        const remain = Math.floor(value % 60)
        return String(minutes).padStart(2, "0") + ":" + String(remain).padStart(2, "0")
    }

    function projectedItem(runId) {
        const key = String(runId || "")
        const rows = root.runItems || []
        for (let index = 0; index < rows.length; ++index) {
            if (String(rows[index].id || "") === key)
                return rows[index]
        }
        return ({})
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            Layout.leftMargin: 10
            Layout.rightMargin: 8
            Text { text: "Lượt chạy gần đây"; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
            Item { Layout.fillWidth: true }
            Text { text: String(root.runModel ? root.runModel.count : 0) + " lượt trong trang"; color: Theme.textFaint; font.pixelSize: 11 }
            Button {
                id: nextPageButton
                objectName: "workflowRunsNextPageButton"
                activeFocusOnTab: true
                text: "Trang tiếp"
                flat: true
                enabled: root.nextCursor !== null && String(root.nextCursor || "").length > 0
                Accessible.name: "Tải trang lượt chạy tiếp theo"
                Accessible.description: enabled ? "" : "Server không trả cursor trang tiếp"
                contentItem: Text { text: nextPageButton.text; color: nextPageButton.enabled ? Theme.accent : Theme.textFaint; font.pixelSize: 11 }
                onClicked: root.nextPageRequested()
            }
            AppButton {
                objectName: "workflowViewAllRunsButton"
                text: "Xem tất cả"
                trailingIcon: "ui/chevron-right"
                Accessible.name: text
                onClicked: root.viewAllRequested()
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 8
            Text { Layout.preferredWidth: 120; text: "Thời gian"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.fillWidth: true; text: "Workflow"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.preferredWidth: 82; text: "Trigger"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.preferredWidth: 90; text: "Phạm vi"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.preferredWidth: 60; text: "Thời lượng"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.preferredWidth: 86; text: "Kết quả"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.preferredWidth: 100; text: "Giai đoạn lỗi"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
        }
        ListView {
            id: runList
            objectName: "workflowRunListViewport"
            readonly property int visibleRowCapacity: 4
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.runModel
            boundsBehavior: Flickable.StopAtBounds
            delegate: Rectangle {
                id: runRow
                required property string run_id
                required property string workflow_key
                required property int workflow_version
                required property string trigger_type
                required property string state_value
                required property bool dry_run
                required property string started_at
                required property var finished_at
                required property var duration_seconds
                required property var actor_id
                required property var scope_refs
                required property var failed_stage
                required property var deep_link
                readonly property var projected: root.projectedItem(runRow.run_id)
                readonly property var triggerEvidence:
                    runRow.projected.trigger || ({})
                readonly property var platformEvidence:
                    runRow.projected.platform || ({})
                readonly property var resultEvidence:
                    runRow.projected.result || ({})
                readonly property var itemData: ({
                    "id": runRow.run_id,
                    "workflow_key": runRow.workflow_key,
                    "workflow_version": runRow.workflow_version,
                    "workflow_icon_key": runRow.projected.workflow_icon_key,
                    "trigger_type": runRow.trigger_type,
                    "trigger": runRow.triggerEvidence,
                    "platform": runRow.platformEvidence,
                    "state": runRow.state_value,
                    "result": runRow.resultEvidence,
                    "dry_run": runRow.dry_run,
                    "started_at": runRow.started_at,
                    "finished_at": runRow.finished_at,
                    "duration_seconds": runRow.duration_seconds,
                    "actor_id": runRow.actor_id,
                    "scope_refs": runRow.scope_refs,
                    "failed_stage": runRow.failed_stage,
                    "deep_link": runRow.deep_link
                })
                objectName: "workflowRunRow_" + runRow.run_id
                width: runList.width
                height: Math.max(
                    28, Math.floor(runList.height / runList.visibleRowCapacity))
                color: rowHover.hovered ? Theme.hover : "transparent"
                Accessible.name: "Lượt chạy " + runRow.run_id
                Accessible.role: Accessible.Row
                activeFocusOnTab: true
                Accessible.focusable: true
                Keys.onReturnPressed: runRow.activate()
                Keys.onEnterPressed: runRow.activate()
                Keys.onSpacePressed: runRow.activate()
                function activate() { root.runSelected(runRow.itemData) }
                HoverHandler { id: rowHover }
                TapHandler { onTapped: runRow.activate() }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8
                    Text { Layout.preferredWidth: 120; text: String(runRow.started_at || "—").replace("T", " ").slice(0, 16); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        UiIcon {
                            objectName: "workflowRecentWorkflowIcon_" + runRow.run_id
                            name: String(runRow.projected.workflow_icon_key || "")
                            tone: Theme.textMuted
                            iconSize: 14
                            visible: name.length > 0
                            Accessible.description:
                                String(runRow.projected.workflow_icon_reason_code || "")
                        }
                        Text { Layout.fillWidth: true; text: runRow.workflow_key + " · v" + String(runRow.workflow_version || "—"); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                    }
                    RowLayout {
                        Layout.preferredWidth: 82
                        spacing: 4
                        UiIcon {
                            objectName: "workflowRecentTriggerIcon_" + runRow.run_id
                            name: String(runRow.triggerEvidence.icon_key || "")
                            tone: Theme.textMuted
                            iconSize: 13
                            visible: name.length > 0
                        }
                        Text { Layout.fillWidth: true; text: String(runRow.triggerEvidence.label || runRow.triggerEvidence.reason_code || "—"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                    }
                    RowLayout {
                        Layout.preferredWidth: 90
                        spacing: 4
                        UiIcon {
                            objectName: "workflowRecentPlatformIcon_" + runRow.run_id
                            name: String(runRow.platformEvidence.icon_key || "")
                            tone: Theme.textMuted
                            iconSize: 13
                            visible: name.length > 0
                        }
                        Text { Layout.fillWidth: true; text: String(runRow.platformEvidence.label || runRow.platformEvidence.reason_code || "—"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                    }
                    Text { Layout.preferredWidth: 60; text: root.durationText(runRow.duration_seconds); color: Theme.textMuted; font.pixelSize: 11 }
                    RowLayout {
                        Layout.preferredWidth: 86
                        spacing: 3
                        UiIcon {
                            objectName: "workflowRecentResultIcon_" + runRow.run_id
                            name: String(runRow.resultEvidence.icon_key || "")
                            tone: root.resultTone(runRow.state_value)
                            iconSize: 13
                            visible: name.length > 0
                        }
                        Foundation.StatusPill {
                            Layout.fillWidth: true
                            text: String(runRow.resultEvidence.label
                                || runRow.state_value || "—")
                            tone: root.resultTone(runRow.state_value)
                        }
                    }
                    Text { Layout.preferredWidth: 100; text: String(runRow.failed_stage || "—"); color: runRow.failed_stage ? Theme.danger : Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                }
            }
        }
    }
}
