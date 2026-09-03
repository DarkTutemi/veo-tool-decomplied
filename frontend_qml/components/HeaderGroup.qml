import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root

    property color borderColor: VfTheme.borderStrong
    property color fillColor: VfTheme.surface
    default property alias content: groupRow.data

    implicitWidth: groupRow.implicitWidth + 10
    implicitHeight: VfTheme.dp(32)
    width: implicitWidth
    height: implicitHeight
    Layout.preferredHeight: implicitHeight
    Layout.preferredWidth: implicitWidth
    radius: VfTheme.radiusControl
    color: fillColor
    border.color: borderColor
    border.width: 1

    Row {
        id: groupRow
        anchors.fill: parent
        anchors.margins: VfTheme.dp(3)
        spacing: VfTheme.dp(3)
    }
}
