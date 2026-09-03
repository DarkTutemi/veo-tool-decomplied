pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "studioProcessRail"
    property var processData: ({})
    property var stepModel: null
    property var workspaceFlowModel: null
    signal entityRequested(var entity)
    signal deepLinkRequested(var link)
    color: Theme.panel
    radius: Theme.radiusMedium
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.role: Accessible.Pane
    Accessible.name: "Bản đồ bàn giao nội dung"

    function toneFor(state) {
        const value = String(state || "").toLowerCase()
        if (value === "completed") return Theme.success
        if (value === "warning" || value === "waiting_approval") return Theme.warning
        if (value === "failed" || value === "blocked" || value === "cancelled") return Theme.danger
        if (value === "active" || value === "ready") return Theme.accent
        return Theme.textFaint
    }

    function stateLabel(state) {
        const value = String(state || "unknown").toLowerCase()
        if (value === "completed") return "Hoàn tất"
        if (value === "warning") return "Cần kiểm tra"
        if (value === "waiting_approval") return "Chờ phê duyệt"
        if (value === "failed") return "Thất bại"
        if (value === "blocked") return "Bị chặn"
        if (value === "cancelled") return "Đã hủy"
        if (value === "active") return "Đang chạy"
        if (value === "ready") return "Sẵn sàng"
        if (value === "optional") return "Tùy chọn · chưa gán"
        if (value === "pending") return "Chờ đầu vào"
        return "Chưa có trạng thái"
    }

    function iconFor(key) {
        const icons = {
            "content": "semantic/lightbulb",
            "studio": "semantic/video",
            "schedule": "ui/calendar",
            "automation": "semantic/workflow",
            "coordination": "semantic/workflow"
        }
        return String(icons[String(key || "")] || "semantic/workflow")
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        ColumnLayout {
            Layout.preferredWidth: 132
            Layout.fillHeight: true
            spacing: 3
            Text {
                objectName: "studioWorkspaceFlowTitle"
                Layout.fillWidth: true
                text: "TỪ NGUỒN ĐẾN KÊNH"
                color: Theme.text
                font.pixelSize: 11
                font.weight: Font.Bold
                elide: Text.ElideRight
            }
            Text {
                objectName: "studioWorkspaceFlowHint"
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Chọn bước để mở hồ sơ. Phê duyệt và việc cần xử lý nằm ở Hôm nay."
                color: Theme.textMuted
                font.pixelSize: 11
                lineHeight: 1.1
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
            }
        }

        Repeater {
            model: root.workspaceFlowModel
            delegate: Rectangle {
                id: stage
                required property int index
                required property string key
                required property string label
                required property string description
                required property string state_value
                required property bool required_value
                required property bool optional_value
                required property var reason_code
                required property string route
                required property var entity
                required property var deep_link
                required property var evidence
                readonly property string stageKey: String(stage.key || "unknown")
                readonly property bool canOpen: Boolean(stage.deep_link && stage.deep_link.route)
                objectName: "studioWorkspaceFlow_" + stage.stageKey
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 160
                radius: Theme.radiusSmall
                color: Qt.rgba(
                    root.toneFor(stage.state_value).r,
                    root.toneFor(stage.state_value).g,
                    root.toneFor(stage.state_value).b,
                    stage.state_value === "optional" ? 0.035 : 0.075
                )
                border.width: stage.activeFocus ? 2 : 1
                border.color: stage.activeFocus ? Theme.accent : Theme.borderSoft
                activeFocusOnTab: true
                Accessible.role: Accessible.Button
                Accessible.name: stage.label + ": " + root.stateLabel(stage.state_value)
                Accessible.description: stage.description + (stage.reason_code ? " · " + stage.reason_code : "")

                function activate() {
                    if (!stage.canOpen) return false
                    root.deepLinkRequested(stage.deep_link)
                    return true
                }
                Keys.onReturnPressed: stage.activate()
                Keys.onSpacePressed: stage.activate()

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 3
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Rectangle {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: 7
                            color: Qt.rgba(
                                root.toneFor(stage.state_value).r,
                                root.toneFor(stage.state_value).g,
                                root.toneFor(stage.state_value).b,
                                0.16
                            )
                            UiIcon {
                                anchors.centerIn: parent
                                name: root.iconFor(stage.stageKey)
                                tone: root.toneFor(stage.state_value)
                                iconSize: 14
                            }
                        }
                        Text {
                            objectName: "studioWorkspaceFlowLabel_" + stage.stageKey
                            Layout.fillWidth: true
                            text: stage.label
                            color: Theme.text
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }
                        Text {
                            visible: stage.optional_value
                            text: "Tùy chọn"
                            color: Theme.textFaint
                            font.pixelSize: 11
                        }
                    }
                    Text {
                        objectName: "studioWorkspaceFlowState_" + stage.stageKey
                        Layout.fillWidth: true
                        text: root.stateLabel(stage.state_value)
                        color: root.toneFor(stage.state_value)
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    Text {
                        objectName: "studioWorkspaceFlowDescription_" + stage.stageKey
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: stage.description
                        color: Theme.textMuted
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    objectName: "studioWorkspaceConnector_" + stage.stageKey
                    visible: stage.index < (root.workspaceFlowModel ? root.workspaceFlowModel.count - 1 : 0)
                    anchors.left: parent.right
                    anchors.leftMargin: 1
                    anchors.verticalCenter: parent.verticalCenter
                    width: 7
                    height: 2
                    color: Theme.border
                    z: 5
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: stage.canOpen
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: stage.activate()
                }
            }
        }
    }
}
