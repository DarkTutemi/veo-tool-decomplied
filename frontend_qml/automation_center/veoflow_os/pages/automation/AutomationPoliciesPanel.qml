pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Rectangle {
    id: root
    objectName: "automationPoliciesPanel"
    property var section: ({})
    signal openWorkflowRequested(var item)

    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    clip: true
    Accessible.name: "Chính sách workflow hiệu lực từ server"
    Accessible.role: Accessible.Pane

    readonly property var items: root.section.items || []
    readonly property var globalInheritance: root.section.global_inheritance || ({})

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 10
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: "Chính sách"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.DemiBold }
                Text { text: String(root.section.total || root.items.length) + " policy set theo definition bất biến"; color: Theme.textFaint; font.pixelSize: 11 }
            }
            Foundation.StatusPill {
                text: String(root.globalInheritance.state || "unavailable") === "unavailable"
                    ? "Kế thừa toàn cục: chưa có bằng chứng"
                    : "Kế thừa toàn cục: " + String(root.globalInheritance.state)
                tone: String(root.globalInheritance.state || "unavailable") === "unavailable"
                    ? Theme.warning : Theme.success
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        Text {
            visible: String(root.globalInheritance.reason_code || "").length > 0
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 8
            text: "Bằng chứng: " + String(root.globalInheritance.reason_code || "")
            color: Theme.warning
            font.pixelSize: 11
            wrapMode: Text.Wrap
        }

        GridView {
            id: policyGrid
            objectName: "automationPolicyGrid"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 12
            cellWidth: Math.max(390, width / Math.max(1, Math.floor(width / 390)))
            cellHeight: 188
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.items
            delegate: Item {
                id: policyCell
                required property var modelData
                readonly property string identity: String(policyCell.modelData.workflow_key || "")
                    + "@" + String(policyCell.modelData.version || "")
                width: policyGrid.cellWidth
                height: policyGrid.cellHeight
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 5
                    radius: Theme.radiusMedium
                    color: Theme.elevated
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.name: "Chính sách " + policyCell.identity
                    Accessible.role: Accessible.Grouping
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 7
                        RowLayout {
                            Layout.fillWidth: true
                            Text { Layout.fillWidth: true; text: String(policyCell.modelData.name || policyCell.modelData.workflow_key || "Workflow"); color: Theme.text; font.pixelSize: 13; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            Foundation.StatusPill { text: "v" + String(policyCell.modelData.version || "—"); tone: Theme.accent }
                        }
                        Text { Layout.fillWidth: true; text: String(policyCell.modelData.category || "—") + " · " + policyCell.identity; color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 3
                            columnSpacing: 10
                            rowSpacing: 3
                            Text { text: "Đồng thời"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: "Lease bước"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: "Dừng khi lỗi"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: String((policyCell.modelData.effective || {}).max_concurrency ?? "—"); color: Theme.text; font.pixelSize: 13; font.weight: Font.DemiBold }
                            Text { text: (policyCell.modelData.effective || {}).step_lease_seconds === undefined ? "—" : String(policyCell.modelData.effective.step_lease_seconds) + " giây"; color: Theme.text; font.pixelSize: 11 }
                            Text { text: (policyCell.modelData.effective || {}).stop_on_failure === true ? "Bật" : (policyCell.modelData.effective || {}).stop_on_failure === false ? "Tắt" : "—"; color: (policyCell.modelData.effective || {}).stop_on_failure === true ? Theme.warning : Theme.textMuted; font.pixelSize: 11 }
                        }
                        Item { Layout.fillHeight: true }
                        RowLayout {
                            Layout.fillWidth: true
                            Foundation.StatusPill {
                                text: String((policyCell.modelData.inheritance || {}).state || "unavailable")
                                tone: String((policyCell.modelData.inheritance || {}).state || "unavailable") === "unavailable" ? Theme.warning : Theme.success
                            }
                            Item { Layout.fillWidth: true }
                            AppButton {
                                objectName: "automationPolicyOpen_" + policyCell.identity
                                text: Boolean(((policyCell.modelData.actions || {}).edit || {}).available)
                                    ? "Mở cấu hình" : "Xem workflow"
                                implicitHeight: 32
                                enabled: Boolean((policyCell.modelData.deep_link || {}).route)
                                availabilityReason: enabled ? "" : "Projection không có deep link workflow"
                                onClicked: root.openWorkflowRequested(policyCell.modelData)
                            }
                        }
                    }
                }
            }
        }

        Text {
            visible: root.items.length === 0
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 24
            text: "Không có policy workflow trong workspace"
            color: Theme.textFaint
            font.pixelSize: 12
        }
    }
}
