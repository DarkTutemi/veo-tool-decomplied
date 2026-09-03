import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    objectName: "pageHeader"
    property string eyebrow: ""
    property string title: ""
    property string description: ""
    default property alias actions: actionHost.data
    implicitHeight: 72
    Accessible.name: title + ". " + description
    Accessible.role: Accessible.Heading

    RowLayout {
        anchors.fill: parent; spacing: 18
        ColumnLayout {
            Layout.fillWidth: true; spacing: 2
            Text { visible: root.eyebrow.length > 0; text: root.eyebrow.toUpperCase(); color: Theme.accent; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 1.1 }
            Text { text: root.title; color: Theme.text; font.pixelSize: Theme.fontPageTitle; font.weight: Font.Bold }
            Text { visible: root.description.length > 0; text: root.description; color: Theme.textFaint; font.pixelSize: Theme.fontBody; elide: Text.ElideRight; Layout.maximumWidth: 720 }
        }
        RowLayout { id: actionHost; spacing: 8 }
    }
}
