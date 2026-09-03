pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "assignmentCenterPanel"
    color: "transparent"
    border.width: 0
    property var controlPlaneBridge: null
    property var workflows: []
    property string activeView: "plan"
    Accessible.name: "Giao việc và theo dõi tiến trình"
    Accessible.role: Accessible.Pane

    readonly property int orderCount: Number(root.controlPlaneBridge
        && root.controlPlaneBridge.orderModel
        ? root.controlPlaneBridge.orderModel.count || 0 : 0)

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
                    text: "Giao việc"
                    color: Theme.text
                    font.pixelSize: Theme.fontPageTitle
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: "Tạo Assignment V2 hoặc theo dõi coordinator tuần tự; không chạy lại feature sản xuất trong màn này."
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontBody
                    elide: Text.ElideRight
                }
            }
            AppButton {
                objectName: "assignmentPlanViewButton"
                text: "Từ kế hoạch"
                leadingIcon: "semantic/workflow"
                primary: root.activeView === "plan"
                subtle: root.activeView !== "plan"
                onClicked: root.activeView = "plan"
            }
            AppButton {
                objectName: "assignmentQuickViewButton"
                text: "Tạo nhanh"
                leadingIcon: "ui/plus"
                primary: root.activeView === "quick"
                subtle: root.activeView !== "quick"
                onClicked: root.activeView = "quick"
            }
            AppButton {
                objectName: "assignmentProgressViewButton"
                text: "Tiến trình · " + String(root.orderCount)
                leadingIcon: "ui/list"
                primary: root.activeView === "progress"
                subtle: root.activeView !== "progress"
                onClicked: root.activeView = "progress"
            }
        }

        Loader {
            id: planLoader
            objectName: "assignmentPlanLoader"
            Layout.fillWidth: true
            Layout.fillHeight: true
            active: root.activeView === "plan" || item !== null
            asynchronous: true
            visible: root.activeView === "plan" && status === Loader.Ready
            source: "CopilotAssignmentPanel.qml"
            onLoaded: item.controlPlaneBridge = root.controlPlaneBridge
        }

        Loader {
            id: createLoader
            objectName: "assignmentQuickLoader"
            Layout.fillWidth: true
            Layout.fillHeight: true
            active: root.activeView === "quick" || item !== null
            asynchronous: true
            visible: root.activeView === "quick" && status === Loader.Ready
            source: "Tool1WorkflowPanel.qml"
            onLoaded: {
                item.controlPlaneBridge = root.controlPlaneBridge
                item.workflows = root.workflows
                item.runRequested.connect(function(payload) {
                    if (root.controlPlaneBridge)
                        root.controlPlaneBridge.callTool(
                            "tool1.assignment.create", payload)
                })
            }
        }

        Loader {
            id: progressLoader
            objectName: "assignmentProgressLoader"
            Layout.fillWidth: true
            Layout.fillHeight: true
            active: root.activeView === "progress" || item !== null
            asynchronous: true
            visible: root.activeView === "progress" && status === Loader.Ready
            source: "Tool1WorkOrdersPanel.qml"
            onLoaded: item.controlPlaneBridge = root.controlPlaneBridge
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 22
            spacing: Theme.space2
            Item { Layout.fillWidth: true }
            UiIcon {
                name: "semantic/info"
                tone: Theme.textFaint
                iconSize: 14
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
            }
            Text {
                text: "Mỗi work order chạy từng bước; bước sau chỉ mở khi bước trước có bằng chứng hoàn tất."
                color: Theme.textFaint
                font.pixelSize: Theme.fontMetadata
                elide: Text.ElideRight
            }
            Item { Layout.fillWidth: true }
        }
    }
}
