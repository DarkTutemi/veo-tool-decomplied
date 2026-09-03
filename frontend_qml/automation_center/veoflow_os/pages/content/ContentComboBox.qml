pragma ComponentBehavior: Bound
import QtQuick
import "../.."

AppComboBox {
    id: control
    objectName: "contentComboBox"
    polishedDarkDropdown: true
    textRole: "label"
    valueRole: "id"
    font.pixelSize: 11
}
