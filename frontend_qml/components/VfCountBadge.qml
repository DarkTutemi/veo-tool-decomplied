import QtQuick
import "../theme"

// Pill đếm số (bo tròn, viền accent). Tách từ CharacterConsistencyPanel để dùng chung.
Rectangle {
    id: badge
    property int count: 0
    property color accent: VfTheme.primary

    implicitWidth: countText.implicitWidth + VfTheme.dp(12)
    implicitHeight: VfTheme.dp(20)
    radius: VfTheme.dp(10)
    color: VfTheme.surfaceSoft
    border.color: badge.accent
    border.width: 1

    Text {
        id: countText
        anchors.centerIn: parent
        text: String(badge.count)
        color: badge.accent
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(10)
        font.weight: Font.Bold
    }
}
