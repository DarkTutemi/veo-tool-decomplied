pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: root
    property int selectedPackageIndex: -1
    property int selectedJobIndex: -1
    readonly property var selectedPackage: selectedPackageIndex >= 0 ? controlPlane.contentPackageModel.get(selectedPackageIndex) : ({})
    readonly property var selectedJob: selectedJobIndex >= 0 ? controlPlane.publishJobModel.get(selectedJobIndex) : ({})

    Connections { target: controlPlane.contentPackageModel; function onCountChanged() { if (controlPlane.contentPackageModel.count === 0) root.selectedPackageIndex = -1; else if (root.selectedPackageIndex < 0 || root.selectedPackageIndex >= controlPlane.contentPackageModel.count) root.selectedPackageIndex = 0 } }
    Connections { target: controlPlane.publishJobModel; function onCountChanged() { if (controlPlane.publishJobModel.count === 0) root.selectedJobIndex = -1; else if (root.selectedJobIndex < 0 || root.selectedJobIndex >= controlPlane.publishJobModel.count) root.selectedJobIndex = 0 } }

    Dialog {
        id: createJobDialog; anchors.centerIn: parent; modal: true; width: 480
        title: "Tạo publish job"; standardButtons: Dialog.Save | Dialog.Cancel
        onAccepted: controlPlane.callTool("publish.job.create", {"content_package_id": root.selectedPackage.packageId, "channel_id": root.selectedPackage.channelId, "platform": root.selectedPackage.platform, "scheduled_at": scheduledAt.text.trim(), "idempotency_key": "qml-publish-" + root.selectedPackage.packageId + "-" + scheduledAt.text.trim()})
        contentItem: ColumnLayout { spacing: 10
            Text { Layout.fillWidth: true; text: "Job luôn mở approval trên server. Operator chọn đúng phiên bản Content Package bất biến trước khi duyệt."; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
            Text { text: (root.selectedPackage.title || "Gói nội dung") + " · v" + (root.selectedPackage.version || 1); color: Theme.text; font.pixelSize: 12; font.weight: Font.Bold }
            TextField { id: scheduledAt; Layout.fillWidth: true; placeholderText: "Để trống để đăng ngay, hoặc 2026-08-05T09:00:00+07:00" }
        }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }
    Dialog {
        id: cancelJobDialog; anchors.centerIn: parent; modal: true; width: 420
        title: "Hủy publish job"; standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: controlPlane.callTool("publish.job.cancel", {"job_id": root.selectedJob.jobId})
        contentItem: Text { width: 370; text: "Chỉ hủy được trước ranh giới tác động bên ngoài. Approval đang chờ cũng sẽ bị thu hồi có kiểm soát."; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }

    RowLayout { anchors.fill: parent; spacing: 10
        Panel { Layout.fillWidth: true; Layout.fillHeight: true
            ColumnLayout { anchors.fill: parent; spacing: 0
                RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 56; Layout.leftMargin: 16; Layout.rightMargin: 14
                    ColumnLayout { spacing: 1; Text { text: "Gói sẵn sàng phát hành"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold } Text { text: controlPlane.contentPackageModel.count + " phiên bản mới nhất"; color: Theme.textFaint; font.pixelSize: 11 } }
                    Item { Layout.fillWidth: true }
                    AppButton { text: "Làm mới"; onClicked: controlPlane.refreshDashboard() }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                ListView { id: packageList; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; reuseItems: true; model: controlPlane.contentPackageModel
                    delegate: Rectangle {
                        id: packageRow
                        required property int index; required property string packageId; required property string packageKey; required property int version
                        required property string assetId; required property string channelId; required property string platform; required property string title
                        required property string caption; required property string visibility; required property string readinessState; required property int blockerCount; required property string createdAt
                        width: packageList.width; height: 70
                        color: root.selectedPackageIndex === index ? Theme.accentSoft : (mouse.containsMouse ? Theme.hover : "transparent")
                        border.width: 1; border.color: root.selectedPackageIndex === index ? Theme.accent : Theme.borderSoft
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 14; spacing: 12
                            SocialIcon { Layout.preferredWidth: 22; Layout.preferredHeight: 22; platform: packageRow.platform }
                            ColumnLayout { Layout.fillWidth: true; spacing: 2
                                Text { Layout.fillWidth: true; text: packageRow.title; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                Text { text: packageRow.packageKey + " · v" + packageRow.version; color: Theme.textFaint; font.pixelSize: 11 }
                            }
                            Text { text: packageRow.visibility; color: Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 70 }
                            Text { text: packageRow.readinessState; color: packageRow.readinessState === "ready" ? Theme.success : Theme.warning; font.pixelSize: 11; font.weight: Font.Bold; Layout.preferredWidth: 80 }
                        }
                        MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedPackageIndex = packageRow.index }
                    }
                }
                RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 50; Layout.leftMargin: 14; Layout.rightMargin: 14
                    Text { text: root.selectedPackage.packageId ? root.selectedPackage.blockerCount + " blocker" : "Chọn Content Package"; color: root.selectedPackage.blockerCount > 0 ? Theme.warning : Theme.textFaint; font.pixelSize: 11 }
                    Item { Layout.fillWidth: true }
                    AppButton { text: "Tạo job & xin duyệt"; primary: true; enabled: root.selectedPackage.readinessState === "ready" && !controlPlane.actionBusy; onClicked: createJobDialog.open() }
                }
            }
        }
        Panel { Layout.fillHeight: true; Layout.preferredWidth: 470
            ColumnLayout { anchors.fill: parent; spacing: 0
                RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 56; Layout.leftMargin: 16; Layout.rightMargin: 14
                    Text { text: "Hàng đợi phát hành"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold }
                    Item { Layout.fillWidth: true }
                    Text { text: String(controlPlane.publishJobModel.count); color: Theme.accent; font.pixelSize: 12; font.weight: Font.Bold }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                ListView { id: jobList; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 6; model: controlPlane.publishJobModel
                    delegate: Rectangle {
                        id: jobRow
                        required property int index; required property string jobId; required property string packageId; required property string channelId
                        required property string platform; required property string title; required property string publishState; required property string scheduledAt
                        required property string approvalId; required property string externalUrl; required property int attemptCount; required property string lastError; required property string createdAt
                        width: jobList.width; height: 76; radius: Theme.radiusMedium
                        color: root.selectedJobIndex === index ? Theme.accentSoft : Theme.elevated; border.width: 1; border.color: root.selectedJobIndex === index ? Theme.accent : Theme.borderSoft
                        RowLayout { anchors.fill: parent; anchors.margins: 12; spacing: 10
                            ColumnLayout { Layout.fillWidth: true; spacing: 2
                                Text { Layout.fillWidth: true; text: jobRow.title; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                Text { text: jobRow.scheduledAt || "Đăng ngay khi được duyệt"; color: Theme.textFaint; font.pixelSize: 11 }
                            }
                            Text { text: jobRow.publishState; color: jobRow.publishState === "published" ? Theme.success : jobRow.publishState === "failed" ? Theme.danger : Theme.warning; font.pixelSize: 11; font.weight: Font.Bold }
                        }
                        MouseArea { anchors.fill: parent; onClicked: root.selectedJobIndex = jobRow.index }
                    }
                }
                RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 50; Layout.leftMargin: 14; Layout.rightMargin: 14
                    Text { text: root.selectedJob.lastError || (root.selectedJob.jobId ? "Lần thử: " + root.selectedJob.attemptCount : "Chọn job để quản lý"); color: root.selectedJob.lastError ? Theme.danger : Theme.textFaint; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                    AppButton { text: "Hủy job"; enabled: Boolean(root.selectedJob.jobId) && !["published", "publishing", "verification_required", "cancelled"].includes(root.selectedJob.publishState); onClicked: cancelJobDialog.open() }
                }
            }
        }
    }
}
