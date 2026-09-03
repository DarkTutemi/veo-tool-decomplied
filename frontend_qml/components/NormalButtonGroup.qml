import QtQuick
import QtQuick.Layouts
import "../theme"

// Toolbar cluster. Default is a silent row (no outer box). `segmented` is ONE
// shell: no inner pad. Nested pad+radius was the "khung lồng khung" inset.
Rectangle {
    id: group

    default property alias content: groupRow.data
    property bool danger: false
    property bool success: false
    property bool segmented: false

    readonly property int chipHeight: VfTheme.toolbarChipHeight

    implicitWidth: groupRow.implicitWidth
    implicitHeight: chipHeight
    Layout.fillWidth: false
    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.alignment: Qt.AlignVCenter
    radius: segmented ? VfTheme.dp(8) : 0
    color: segmented ? VfTheme.surface : "transparent"
    border.color: segmented
        ? (success ? VfTheme.greenBorderSoft : (danger ? VfTheme.redBorderSoft : VfTheme.borderBox))
        : "transparent"
    border.width: segmented ? 1 : 0

    Row {
        id: groupRow
        anchors.fill: parent
        spacing: group.segmented ? 0 : VfTheme.dp(4)
    }
}
