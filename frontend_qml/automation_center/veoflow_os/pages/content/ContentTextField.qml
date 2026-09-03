import QtQuick
import QtQuick.Controls
import "../.."

TextField {
    id: control
    objectName: "contentTextField"
    property string leadingIcon: ""

    implicitHeight: 40
    leftPadding: control.leadingIcon.length > 0 ? 38 : 12
    rightPadding: 12
    color: Theme.text
    placeholderTextColor: Theme.textFaint
    selectionColor: Theme.accent
    selectedTextColor: "white"
    font.pixelSize: 13
    activeFocusOnTab: true
    verticalAlignment: TextInput.AlignVCenter
    Accessible.name: placeholderText || "Trường nhập liệu nội dung"

    UiIcon {
        visible: control.leadingIcon.length > 0
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        name: control.leadingIcon
        tone: Theme.textFaint
        iconSize: 15
        z: 2
    }

    background: Rectangle {
        objectName: control.objectName + "_background"
        radius: Theme.radiusSmall
        color: Theme.elevated
        border.width: 1
        border.color: control.activeFocus ? Theme.accent : Theme.border
    }
}
