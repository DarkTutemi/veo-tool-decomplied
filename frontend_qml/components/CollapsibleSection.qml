import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string sectionId: ""
    property string actionId: ""
    property var actionPayload: ({})
    property bool expanded: true
    property bool fillBody: true
    property int contentMargins: 10
    property color accent: VfTheme.primary
    default property alias content: body.data

    signal toggled(bool expanded)
    signal actionRequested(string actionId, var payload)

    objectName: root.actionId
    Layout.fillWidth: true
    implicitHeight: header.height + (expanded ? body.implicitHeight + 12 : 0)
    radius: VfTheme.radiusPanel
    color: VfTheme.surface
    border.color: VfTheme.borderBox
    clip: true

    function resolvedPayload() {
        var data = {
            action_id: root.actionId,
            section_id: root.sectionId,
            title: root.title,
            expanded: root.expanded
        }
        for (var key in root.actionPayload)
            data[key] = root.actionPayload[key]
        return data
    }

    function toggleSection() {
        root.expanded = !root.expanded
        root.toggled(root.expanded)
        root.actionRequested(root.actionId, root.resolvedPayload())
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: header
            Layout.fillWidth: true
            height: VfTheme.dp(38)
            color: headerMouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(10)
                anchors.rightMargin: VfTheme.dp(10)
                spacing: VfTheme.dp(8)

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(4)
                    Layout.preferredHeight: VfTheme.dp(18)
                    radius: VfTheme.dp(2)
                    color: root.accent
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

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
                        font.pixelSize: VfTheme.fontTiny
                        elide: Text.ElideRight
                    }
                }

                Text {
                    text: root.expanded ? "-" : "+"
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(16)
                    font.weight: Font.Bold
                }
            }

            MouseArea {
                id: headerMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleSection()
            }
        }

        ColumnLayout {
            id: body
            visible: root.expanded
            Layout.fillWidth: true
            Layout.fillHeight: root.fillBody && root.expanded
            Layout.margins: root.contentMargins
            spacing: VfTheme.dp(8)
        }
    }
}
