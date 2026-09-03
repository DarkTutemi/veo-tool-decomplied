import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string iconText: ""
    property string featureId: ""
    property string route: ""
    property string iconName: ""
    property string badgeText: ""
    property string stateText: ""
    property string actionId: ""
    property bool selected: false
    property bool available: true
    property color accent: VfTheme.primary

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: VfTheme.dp(84)
    radius: VfTheme.radiusPanel
    color: selected ? VfTheme.blueFill : (mouse.containsMouse && available ? VfTheme.surfaceSoft : VfTheme.surface)
    opacity: available ? 1.0 : 0.58
    border.color: selected ? accent : VfTheme.borderBox
    border.width: selected ? 2 : 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(10)
        spacing: VfTheme.dp(10)

        VfAppIcon {
            featureId: root.featureId.length > 0 ? root.featureId : root.actionId
            route: root.route
            name: root.iconName
            size: VfTheme.dp(46)
            framed: true
            frameColor: root.available ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.08) : VfTheme.surfaceSoft
            Layout.preferredWidth: VfTheme.dp(46)
            Layout.preferredHeight: VfTheme.dp(46)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(3)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)

                Text {
                    Layout.fillWidth: true
                    text: root.title
                    color: root.available ? VfTheme.text : VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Rectangle {
                    visible: root.badgeText.length > 0 || root.stateText.length > 0
                    Layout.preferredWidth: badgeLabel.implicitWidth + 12
                    Layout.preferredHeight: VfTheme.dp(20)
                    radius: VfTheme.dp(10)
                    color: root.available ? VfTheme.blueFill : VfTheme.surfaceSoft
                    border.color: root.available ? root.accent : VfTheme.borderStrong

                    Text {
                        id: badgeLabel
                        anchors.centerIn: parent
                        text: root.badgeText.length > 0 ? root.badgeText : root.stateText
                        color: root.available ? root.accent : VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.subtitle
                color: root.available ? VfTheme.textMuted : VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.available ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: {
            if (root.available) {
                root.clicked()
            }
        }
    }
}
