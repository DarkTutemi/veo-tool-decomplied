import QtQuick
import QtQuick.Layouts

import "../theme"

// Chip asset gọn: thumb + tên + tóm tắt + nút ✕. Tách từ CharacterConsistencyPanel để dùng chung.
// Component DUMB: host tính sẵn imageSource / name / summary / iconName rồi truyền vào.
Rectangle {
    id: chip
    property string imageSource: ""
    property string name: ""
    property string summary: ""
    property string iconName: "busts-in-silhouette"
    property color accent: VfTheme.primary
    signal removeRequested()

    width: VfTheme.dp(142)
    height: VfTheme.dp(38)
    radius: VfTheme.dp(7)
    color: VfTheme.surface
    border.color: chip.accent
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(4)
        spacing: VfTheme.dp(5)

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(30)
            Layout.preferredHeight: VfTheme.dp(30)
            radius: VfTheme.dp(5)
            color: VfTheme.violetFill
            clip: true
            Image {
                anchors.fill: parent
                source: chip.imageSource
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
            }
            VfAppIcon {
                anchors.centerIn: parent
                name: chip.iconName
                size: VfTheme.dp(15)
                framed: false
                color: chip.accent
                visible: chip.imageSource.length === 0
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: chip.name
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: chip.summary
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(8)
                elide: Text.ElideRight
                visible: text.length > 0
            }
        }
        Rectangle {
            Layout.preferredWidth: VfTheme.dp(22)
            Layout.preferredHeight: VfTheme.dp(22)
            radius: VfTheme.dp(5)
            color: removeMouse.containsMouse ? VfTheme.redFill : "transparent"
            VfAppIcon { anchors.centerIn: parent; name: "cross-mark"; size: VfTheme.dp(11); framed: false; color: "#EF4444" }
            MouseArea {
                id: removeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: chip.removeRequested()
            }
        }
    }
}
