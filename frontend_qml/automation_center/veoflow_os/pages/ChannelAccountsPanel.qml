pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: root
    property int selectedIndex: -1
    readonly property var selectedAccount: selectedIndex >= 0
        ? controlPlane.accountModel.get(selectedIndex) : ({})

    onSelectedIndexChanged: controlPlane.loadSubchannels(selectedAccount.accountId || "")
    Component.onCompleted: {
        if (controlPlane.accountModel.count > 0) selectedIndex = 0
    }
    Connections {
        target: controlPlane.accountModel
        function onCountChanged() {
            if (controlPlane.accountModel.count === 0) root.selectedIndex = -1
            else if (root.selectedIndex < 0 || root.selectedIndex >= controlPlane.accountModel.count)
                root.selectedIndex = 0
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 10
        Panel {
            Layout.fillWidth: true; Layout.fillHeight: true
            ColumnLayout {
                anchors.fill: parent; spacing: 0
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: 58
                    Layout.leftMargin: 16; Layout.rightMargin: 14
                    ColumnLayout { spacing: 1
                        Text { text: "Tài khoản đã nhận diện"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold }
                        Text { text: controlPlane.accountModel.count + " tài khoản từ các browser profile"; color: Theme.textFaint; font.pixelSize: 11 }
                    }
                    Item { Layout.fillWidth: true }
                    AppButton { text: "Làm mới"; onClicked: controlPlane.refreshDashboard() }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                ListView {
                    id: accountList
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; reuseItems: true
                    model: controlPlane.accountModel
                    delegate: Rectangle {
                        id: accountRow
                        required property int index
                        required property string accountId
                        required property string browserProfileId
                        required property string platform
                        required property string displayName
                        required property string username
                        required property string status
                        width: accountList.width; height: 62
                        color: root.selectedIndex === index ? Theme.accentSoft : (mouse.containsMouse ? Theme.hover : "transparent")
                        border.width: 1; border.color: root.selectedIndex === index ? Theme.accent : Theme.borderSoft
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 14; spacing: 12
                            SocialIcon { platform: accountRow.platform; Layout.preferredWidth: 20; Layout.preferredHeight: 20 }
                            ColumnLayout { Layout.fillWidth: true; spacing: 2
                                Text { text: accountRow.displayName; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight; Layout.fillWidth: true }
                                Text { text: accountRow.username || accountRow.accountId; color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideMiddle; Layout.fillWidth: true }
                            }
                            Text { text: accountRow.platform; color: Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 90; font.capitalization: Font.Capitalize }
                            Text { text: accountRow.status; color: accountRow.status === "active" ? Theme.success : Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 90 }
                        }
                        MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedIndex = accountRow.index }
                    }
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                }
            }
        }
        Panel {
            Layout.fillHeight: true; Layout.preferredWidth: 390
            ColumnLayout {
                anchors.fill: parent; spacing: 0
                ColumnLayout { Layout.fillWidth: true; Layout.margins: 16; spacing: 4
                    Text { text: root.selectedAccount.displayName || "Chọn tài khoản"; color: Theme.text; font.pixelSize: 16; font.weight: Font.Bold; Layout.fillWidth: true; elide: Text.ElideRight }
                    Text { text: root.selectedAccount.browserProfileId ? "Browser " + root.selectedAccount.browserProfileId : "Chưa liên kết browser"; color: Theme.textFaint; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideMiddle }
                    RowLayout { Layout.fillWidth: true; Layout.topMargin: 8
                        AppButton { Layout.fillWidth: true; text: "Mở browser"; primary: true; enabled: Boolean(root.selectedAccount.browserProfileId) && !controlPlane.actionBusy; onClicked: controlPlane.callTool("browser.profile.launch", {"profile_id": root.selectedAccount.browserProfileId, "headless": false, "holder_type": "operator", "holder_id": "native-desktop"}) }
                        AppButton { Layout.fillWidth: true; text: "Scan lại"; enabled: Boolean(root.selectedAccount.browserProfileId) && !controlPlane.actionBusy; onClicked: controlPlane.callTool("browser.profile.scan", {"browser_profile_id": root.selectedAccount.browserProfileId, "platform": root.selectedAccount.platform}) }
                    }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                Text { Layout.leftMargin: 16; Layout.topMargin: 14; text: "KÊNH & TRANG ĐƯỢC QUẢN LÝ"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                ListView {
                    id: subchannelList
                    Layout.fillWidth: true; Layout.fillHeight: true; Layout.margins: 10
                    spacing: 6; clip: true; model: controlPlane.subchannelModel
                    delegate: Rectangle {
                        id: subRow
                        required property string platform
                        required property string displayName
                        required property string handle
                        required property string kind
                        required property string status
                        width: subchannelList.width; height: 60; radius: Theme.radiusSmall
                        color: Theme.elevated; border.width: 1; border.color: Theme.borderSoft
                        RowLayout { anchors.fill: parent; anchors.margins: 10; spacing: 10
                            SocialIcon { platform: subRow.platform; Layout.preferredWidth: 19; Layout.preferredHeight: 19 }
                            ColumnLayout { Layout.fillWidth: true; spacing: 1
                                Text { text: subRow.displayName; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; Layout.fillWidth: true; elide: Text.ElideRight }
                                Text { text: subRow.handle || subRow.kind; color: Theme.textFaint; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                            }
                            Text { text: subRow.kind; color: Theme.accent; font.pixelSize: 11; font.weight: Font.DemiBold }
                        }
                    }
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                }
                Text { visible: controlPlane.subchannelModel.count === 0; Layout.alignment: Qt.AlignHCenter; Layout.bottomMargin: 18; text: "Scan browser để nhận diện kênh và page"; color: Theme.textFaint; font.pixelSize: 11 }
            }
        }
    }
}
