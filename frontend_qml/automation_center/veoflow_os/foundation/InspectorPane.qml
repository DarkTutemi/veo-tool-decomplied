import QtQuick
import ".."

Rectangle {
    id: root
    objectName: "inspectorPane"
    default property alias contentData: body.data
    property int preferredWidth: 360
    property string accessibleName: "Bảng chi tiết"
    implicitWidth: preferredWidth
    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.name: accessibleName
    Accessible.role: Accessible.Pane

    Item { id: body; anchors.fill: parent; anchors.margins: 16 }
}
