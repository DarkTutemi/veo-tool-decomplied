import QtQuick
import "../theme"

// Segment chọn 1 trong N (bo tròn, fill accent khi chọn). Tách từ CharacterConsistencyPanel.
// Đặt trong RowLayout với Layout.fillWidth để chia đều bề ngang.
Rectangle {
    id: sseg
    property string text: ""
    property bool selected: false
    property color accent: VfTheme.primary
    signal clicked()

    implicitHeight: VfTheme.dp(30)
    radius: VfTheme.dp(7)
    color: sseg.selected ? sseg.accent : VfTheme.surfaceSoft
    border.color: sseg.selected ? sseg.accent : VfTheme.borderSoft
    border.width: 1

    Text {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(4)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: sseg.text
        color: sseg.selected ? "#FFFFFF" : VfTheme.textMuted
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(10)
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sseg.clicked() }
}
