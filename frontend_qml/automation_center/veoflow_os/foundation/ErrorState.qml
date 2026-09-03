import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: root
    objectName: "errorState"
    property string title: "Không thể tải dữ liệu"
    property string message: "Hãy thử lại hoặc kiểm tra kết nối."
    property bool retryable: true
    signal retry()
    implicitWidth: 360
    implicitHeight: 190
    Accessible.name: title + ". " + message
    Accessible.role: Accessible.Client

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(root.width - 32, 440)
        spacing: 10
        Rectangle { Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 42; Layout.preferredHeight: 42; radius: 12; color: Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.14); Text { anchors.centerIn: parent; text: "!"; color: Theme.danger; font.pixelSize: 20; font.weight: Font.Bold } }
        Text { Layout.fillWidth: true; text: root.title; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter }
        Text { Layout.fillWidth: true; text: root.message; color: Theme.textFaint; font.pixelSize: 12; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter }
        Button { objectName: "errorStateRetryButton"; visible: root.retryable; Layout.alignment: Qt.AlignHCenter; text: "Thử lại"; Accessible.name: text; onClicked: root.retry() }
    }
}
