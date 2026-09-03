pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root

    property var orderModel: null

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            spacing: 8
            Text {
                Layout.fillWidth: true
                text: "Công việc gần đây"
                color: Theme.text
                font.pixelSize: Theme.fontSection
                font.weight: Font.DemiBold
            }
            Text {
                text: String(root.orderModel ? root.orderModel.count || 0 : 0)
                    + " work order"
                color: Theme.textFaint
                font.pixelSize: Theme.fontMetadata
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            color: Theme.elevated
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10
                Text { Layout.fillWidth: true; text: "Nội dung"; color: Theme.textFaint; font.pixelSize: 10; font.weight: Font.DemiBold }
                Text { Layout.preferredWidth: 190; text: "Bước hiện tại"; color: Theme.textFaint; font.pixelSize: 10; font.weight: Font.DemiBold }
                Text { Layout.preferredWidth: 90; text: "Tiến độ"; color: Theme.textFaint; font.pixelSize: 10; font.weight: Font.DemiBold }
                Text { Layout.preferredWidth: 112; text: "Trạng thái"; color: Theme.textFaint; font.pixelSize: 10; font.weight: Font.DemiBold }
                Text { Layout.preferredWidth: 110; text: "Cập nhật"; color: Theme.textFaint; font.pixelSize: 10; font.weight: Font.DemiBold }
            }
        }

        ListView {
            id: orderList
            objectName: "copilotRecentWorkList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            reuseItems: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.orderModel

            delegate: Rectangle {
                id: orderRow
                required property var modelData
                width: orderList.width
                height: 35
                color: orderHover.hovered ? Theme.hover : Theme.panel
                border.width: 0
                HoverHandler { id: orderHover }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: Theme.borderSoft
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10
                    Text {
                        Layout.fillWidth: true
                        text: String(orderRow.modelData.title || "Work order")
                        color: Theme.text
                        font.pixelSize: Theme.fontMetadata
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.preferredWidth: 190
                        text: String(orderRow.modelData.currentStepTitle || "Chờ thực thi")
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                        elide: Text.ElideRight
                    }
                    RowLayout {
                        Layout.preferredWidth: 90
                        spacing: 5
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 5
                            radius: 3
                            color: Theme.elevated
                            Rectangle {
                                width: parent.width * Math.max(0, Math.min(1,
                                    Number(orderRow.modelData.progress || 0) / 100))
                                height: parent.height
                                radius: parent.radius
                                color: Theme.accent
                            }
                        }
                        Text {
                            text: String(Number(orderRow.modelData.progress || 0)) + "%"
                            color: Theme.textFaint
                            font.pixelSize: 10
                        }
                    }
                    Foundation.StatusPill {
                        objectName: "copilotRecentStatus_" + String(
                            orderRow.modelData.orderId || "order")
                        Layout.preferredWidth: 112
                        text: String(orderRow.modelData.statusLabel
                            || orderRow.modelData.status || "")
                        iconName: String(orderRow.modelData.status || "") === "succeeded"
                            ? "semantic/check-circle"
                            : String(orderRow.modelData.status || "") === "failed"
                                || String(orderRow.modelData.status || "") === "needs_attention"
                            ? "semantic/alert-triangle"
                            : String(orderRow.modelData.status || "") === "running"
                            ? "ui/refresh-cw"
                            : String(orderRow.modelData.status || "") === "paused"
                            ? "ui/pause" : "ui/calendar"
                        tone: String(orderRow.modelData.status || "") === "succeeded"
                            ? Theme.success
                            : String(orderRow.modelData.status || "") === "failed"
                                || String(orderRow.modelData.status || "") === "needs_attention"
                            ? Theme.danger
                            : String(orderRow.modelData.status || "") === "running"
                            ? Theme.info : Theme.textMuted
                    }
                    Text {
                        Layout.preferredWidth: 110
                        text: String(orderRow.modelData.updatedAt || "Nội bộ Tool 1")
                        color: Theme.textFaint
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: !root.orderModel || Number(root.orderModel.count || 0) === 0
                text: "Chưa có công việc. Duyệt kế hoạch rồi chuẩn bị Assignment V2."
                color: Theme.textMuted
                font.pixelSize: Theme.fontBody
            }
        }
    }
}
