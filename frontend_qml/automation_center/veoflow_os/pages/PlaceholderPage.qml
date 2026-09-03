import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    property string title: "Trang"
    property string description: "Mockup đang được chuyển sang QML native."

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 52
            Layout.preferredHeight: 52
            radius: 14
            color: Theme.accentSoft
            UiIcon { anchors.centerIn: parent; name: "semantic/workflow"; tone: Theme.accent; iconSize: 24 }
        }
        Text { Layout.alignment: Qt.AlignHCenter; text: root.title; color: Theme.text; font.pixelSize: 22; font.weight: Font.Bold }
        Text { Layout.alignment: Qt.AlignHCenter; text: root.description; color: Theme.textFaint; font.pixelSize: 13 }
    }
}
