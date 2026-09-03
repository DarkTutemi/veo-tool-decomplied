import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    objectName: "permissionState"
    property string permission: ""
    property string message: "Tài khoản hiện tại không có quyền xem nội dung này."
    implicitWidth: 360
    implicitHeight: 170
    Accessible.name: message
    Accessible.role: Accessible.Client

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(root.width - 32, 440)
        spacing: 10
        Rectangle { Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 42; Layout.preferredHeight: 42; radius: 21; color: Theme.elevated; Text { anchors.centerIn: parent; text: "○"; color: Theme.warning; font.pixelSize: 24 } }
        Text { Layout.fillWidth: true; text: "Không có quyền truy cập"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter }
        Text { Layout.fillWidth: true; text: root.message; color: Theme.textFaint; font.pixelSize: 12; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter }
        Text { visible: root.permission.length > 0; Layout.fillWidth: true; text: root.permission; color: Theme.textFaint; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter }
    }
}
