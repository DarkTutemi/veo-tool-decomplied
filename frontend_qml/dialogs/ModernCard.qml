import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property color accent: VfTheme.primary
    default property alias content: body.data

    Layout.fillWidth: true
    implicitHeight: cardLayout.implicitHeight + 20
    radius: VfTheme.radiusPanel
    color: VfTheme.surface
    border.color: VfTheme.borderBox
    clip: true

    ColumnLayout {
        id: cardLayout
        anchors.fill: parent
        anchors.margins: VfTheme.dp(10)
        spacing: VfTheme.dp(8)

        RowLayout {
            visible: root.title.length > 0 || root.subtitle.length > 0
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(4)
                Layout.preferredHeight: VfTheme.dp(22)
                radius: VfTheme.dp(2)
                color: root.accent
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: root.title
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.subtitle.length > 0
                    text: root.subtitle
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    elide: Text.ElideRight
                }
            }
        }

        ColumnLayout {
            id: body
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)
        }
    }
}
