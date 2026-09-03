pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: root
    property int selectedIndex: -1
    readonly property var selectedComment: selectedIndex >= 0 ? controlPlane.commentModel.get(selectedIndex) : ({})
    Connections { target: controlPlane.commentModel; function onCountChanged() { if (controlPlane.commentModel.count === 0) root.selectedIndex = -1; else if (root.selectedIndex < 0 || root.selectedIndex >= controlPlane.commentModel.count) root.selectedIndex = 0 } }

    Dialog {
        id: draftDialog; anchors.centerIn: parent; modal: true; width: 520
        title: "Soạn phản hồi"; standardButtons: Dialog.Save | Dialog.Cancel
        onOpened: replyText.text = root.selectedComment.replyText || ""
        onAccepted: controlPlane.callTool("comment.reply.draft", {"comment_id": root.selectedComment.commentId, "reply_text": replyText.text.trim()})
        contentItem: ColumnLayout { spacing: 9
            Text { Layout.fillWidth: true; text: "@" + (root.selectedComment.author || "viewer") + ": " + (root.selectedComment.commentText || ""); color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
            TextArea { id: replyText; Layout.fillWidth: true; Layout.preferredHeight: 110; placeholderText: "Nhập phản hồi. Lưu sẽ tạo approval comment_reply trên server."; wrapMode: TextEdit.Wrap }
        }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }

    RowLayout { anchors.fill: parent; spacing: 10
        Panel { Layout.fillWidth: true; Layout.fillHeight: true
            ColumnLayout { anchors.fill: parent; spacing: 0
                RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 58; Layout.leftMargin: 16; Layout.rightMargin: 14; spacing: 8
                    ColumnLayout { spacing: 1; Text { text: "Hộp thư bình luận"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold } Text { text: controlPlane.commentModel.count + " bình luận đã ingest"; color: Theme.textFaint; font.pixelSize: 11 } }
                    Item { Layout.fillWidth: true }
                    ComboBox { id: careChannel; Layout.preferredWidth: 190; model: controlPlane.channelModel; textRole: "displayName"; valueRole: "channelId" }
                    AppButton { text: "Quét ngay"; enabled: careChannel.currentIndex >= 0; onClicked: controlPlane.callTool("care.run", {"channel_id": careChannel.currentValue, "run_now": true}) }
                    AppButton { text: "AI soạn phản hồi"; primary: true; enabled: careChannel.currentIndex >= 0; onClicked: controlPlane.callTool("care.reply", {"channel_id": careChannel.currentValue, "limit": 20}) }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                ListView { id: commentList; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; reuseItems: true; model: controlPlane.commentModel
                    delegate: Rectangle {
                        id: commentRow
                        required property int index; required property string commentId; required property string channelId; required property string platform
                        required property string author; required property string commentText; required property string sentiment; required property string commentState
                        required property string replyText; required property string approvalId; required property int attemptCount; required property string lastError
                        width: commentList.width; height: 72
                        color: root.selectedIndex === index ? Theme.accentSoft : (mouse.containsMouse ? Theme.hover : "transparent")
                        border.width: 1; border.color: root.selectedIndex === index ? Theme.accent : Theme.borderSoft
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 14; spacing: 12
                            SocialIcon { Layout.preferredWidth: 22; Layout.preferredHeight: 22; platform: commentRow.platform }
                            ColumnLayout { Layout.fillWidth: true; spacing: 2
                                Text { text: "@" + commentRow.author; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                                Text { Layout.fillWidth: true; text: commentRow.commentText; color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                            }
                            Text { text: commentRow.sentiment; color: commentRow.sentiment === "negative" ? Theme.danger : commentRow.sentiment === "positive" ? Theme.success : Theme.textFaint; font.pixelSize: 11; Layout.preferredWidth: 65 }
                            Text { text: commentRow.commentState; color: Theme.accent; font.pixelSize: 11; font.weight: Font.Bold; Layout.preferredWidth: 105 }
                        }
                        MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedIndex = commentRow.index }
                    }
                }
            }
        }
        Panel { Layout.fillHeight: true; Layout.preferredWidth: 380
            ColumnLayout { anchors.fill: parent; spacing: 0
                Text { Layout.fillWidth: true; Layout.leftMargin: 16; Layout.topMargin: 18; text: "Chi tiết chăm sóc"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold }
                ColumnLayout { Layout.fillWidth: true; Layout.margins: 16; spacing: 11
                    Text { Layout.fillWidth: true; text: root.selectedComment.commentText || "Chọn một bình luận"; color: Theme.text; font.pixelSize: 13; font.weight: Font.DemiBold; wrapMode: Text.Wrap }
                    Text { text: "@" + (root.selectedComment.author || "—") + " · " + (root.selectedComment.platform || "—"); color: Theme.textMuted; font.pixelSize: 11 }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                    Text { text: "PHẢN HỒI ĐANG SOẠN"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                    Text { Layout.fillWidth: true; text: root.selectedComment.replyText || "Chưa có phản hồi"; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
                    Text { visible: Boolean(root.selectedComment.approvalId); text: "Đang chờ approval server"; color: Theme.warning; font.pixelSize: 11; font.weight: Font.Bold }
                    Text { visible: Boolean(root.selectedComment.lastError); Layout.fillWidth: true; text: root.selectedComment.lastError; color: Theme.danger; font.pixelSize: 11; wrapMode: Text.Wrap }
                    AppButton { Layout.fillWidth: true; text: "Soạn / sửa phản hồi"; primary: true; enabled: Boolean(root.selectedComment.commentId) && !["reply_published", "reply_sending"].includes(root.selectedComment.commentState); onClicked: draftDialog.open() }
                }
                Item { Layout.fillHeight: true }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 74; color: Theme.base; border.width: 1; border.color: Theme.borderSoft
                    Text { anchors.fill: parent; anchors.margins: 13; text: "AI chỉ tạo draft. Gửi phản hồi ra nền tảng chỉ xảy ra sau approval comment_reply do server xác nhận."; color: Theme.textFaint; font.pixelSize: 11; wrapMode: Text.Wrap }
                }
            }
        }
    }
}
