pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    RowLayout { anchors.fill: parent; spacing: 10
        Panel { Layout.fillWidth: true; Layout.fillHeight: true
            ColumnLayout { anchors.fill: parent; spacing: 0
                RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 56; Layout.leftMargin: 16; Layout.rightMargin: 14
                    ColumnLayout { spacing: 1; Text { text: "Trung tâm thông báo"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold } Text { text: controlPlane.notificationModel.count + " sự kiện gần nhất"; color: Theme.textFaint; font.pixelSize: 11 } }
                    Item { Layout.fillWidth: true }
                    AppButton { text: "Làm mới"; onClicked: controlPlane.refreshNotifications() }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                ListView { id: notificationList; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 6; model: controlPlane.notificationModel
                    delegate: Rectangle {
                        id: row
                        required property string notificationId; required property string notificationType; required property string severity; required property string title
                        required property string body; required property string source; required property string entityType; required property string entityId
                        required property string createdAt; required property bool isRead; required property bool isAcknowledged
                        width: notificationList.width; height: 86; radius: Theme.radiusMedium
                        color: row.isRead ? Theme.panel : Theme.accentSoft; border.width: 1; border.color: row.severity === "critical" || row.severity === "error" ? Theme.danger : Theme.borderSoft
                        RowLayout { anchors.fill: parent; anchors.margins: 12; spacing: 10
                            Rectangle { Layout.preferredWidth: 8; Layout.preferredHeight: 8; radius: 4; color: row.severity === "critical" || row.severity === "error" ? Theme.danger : row.severity === "warning" ? Theme.warning : Theme.info }
                            ColumnLayout { Layout.fillWidth: true; spacing: 2
                                Text { Layout.fillWidth: true; text: row.title; color: Theme.text; font.pixelSize: 11; font.weight: Font.Bold; elide: Text.ElideRight }
                                Text { Layout.fillWidth: true; text: row.body; color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                                Text { text: row.source + " · " + row.createdAt; color: Theme.textFaint; font.pixelSize: 11 }
                            }
                            AppButton { text: row.isAcknowledged ? "Đã nhận" : "Xác nhận"; enabled: !row.isAcknowledged; onClicked: controlPlane.updateNotification(row.notificationId, true) }
                            AppButton { text: "Đã đọc"; visible: !row.isRead; onClicked: controlPlane.updateNotification(row.notificationId, false) }
                        }
                    }
                }
            }
        }
        ColumnLayout { Layout.fillHeight: true; Layout.preferredWidth: 430; spacing: 10
            Panel { Layout.fillWidth: true; Layout.fillHeight: true
                ColumnLayout { anchors.fill: parent; spacing: 0
                    RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 50; Layout.leftMargin: 14; Layout.rightMargin: 12
                        Text { text: "Công việc lỗi / bị chặn"; color: Theme.text; font.pixelSize: 13; font.weight: Font.Bold } Item { Layout.fillWidth: true } Text { text: String(controlPlane.failureModel.count); color: Theme.danger; font.pixelSize: 11; font.weight: Font.Bold }
                    }
                    ListView { id: failureList; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: controlPlane.failureModel
                        delegate: Rectangle { id: failureRow
                            required property string taskId; required property string taskType; required property string taskState; required property int priority
                            required property string channelId; required property string campaignId; required property string scheduledAt; required property string startedAt
                            required property string finishedAt; required property int attemptCount; required property string errorMessage
                            width: failureList.width; height: 68; color: "transparent"; border.width: 1; border.color: Theme.borderSoft
                            ColumnLayout { anchors.fill: parent; anchors.margins: 10; spacing: 2
                                RowLayout { Layout.fillWidth: true; Text { Layout.fillWidth: true; text: failureRow.taskType; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight } Text { text: failureRow.taskState; color: Theme.danger; font.pixelSize: 11; font.weight: Font.Bold } }
                                Text { Layout.fillWidth: true; text: failureRow.errorMessage || failureRow.taskId; color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                            }
                        }
                    }
                }
            }
            Panel { Layout.fillWidth: true; Layout.fillHeight: true
                ColumnLayout { anchors.fill: parent; spacing: 0
                    RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 46; Layout.leftMargin: 14; Layout.rightMargin: 12
                        Text { text: "Audit gần đây"; color: Theme.text; font.pixelSize: 13; font.weight: Font.Bold } Item { Layout.fillWidth: true } Text { text: String(controlPlane.auditModel.count); color: Theme.textFaint; font.pixelSize: 11 }
                    }
                    ListView { id: auditList; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: controlPlane.auditModel
                        delegate: RowLayout { id: auditRow; required property string auditId; required property string toolName; required property string actorId; required property string resultState; required property string targetType; required property string createdAt
                            width: auditList.width; height: 36; spacing: 8
                            Text { Layout.leftMargin: 12; Layout.fillWidth: true; text: auditRow.toolName; color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                            Text { text: auditRow.resultState; color: auditRow.resultState === "success" ? Theme.success : Theme.warning; font.pixelSize: 11; Layout.preferredWidth: 58 }
                        }
                    }
                }
            }
        }
    }
}
