import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root
    objectName: "metricCell"
    property string value: "—"
    property string label: ""
    property string delta: ""
    property string iconName: ""
    property color tone: Theme.accent
    property bool pulse: false

    implicitWidth: 190
    implicitHeight: 68
    radius: Theme.radiusMedium
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.name: label + ": " + value + (delta.length ? ", " + delta : "")
    Accessible.role: Accessible.StaticText

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        spacing: 12

        Rectangle {
            id: iconBadge
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            Layout.alignment: Qt.AlignVCenter
            radius: 10
            color: Qt.rgba(root.tone.r, root.tone.g, root.tone.b, 0.12)
            border.width: 1
            border.color: Qt.rgba(root.tone.r, root.tone.g, root.tone.b, 0.26)

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: root.pulse
                NumberAnimation { to: 0.45; duration: 1100; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 1.0; duration: 1100; easing.type: Easing.InOutQuad }
            }

            UiIcon {
                objectName: root.objectName + "Icon"
                anchors.centerIn: parent
                visible: root.iconName.length > 0
                name: root.iconName
                tone: root.tone
                iconSize: 18
            }

            Rectangle {
                anchors.centerIn: parent
                visible: root.iconName.length === 0
                width: 8
                height: 8
                radius: 4
                color: root.tone
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            RowLayout {
                spacing: 6
                Text {
                    text: root.value
                    color: Theme.text
                    font.pixelSize: 20
                    font.weight: Font.Bold
                }
                Text {
                    Layout.fillWidth: true
                    text: root.label
                    color: Theme.textMuted
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }
            }

            Text {
                visible: root.delta.length > 0
                text: root.delta
                color: root.tone
                font.pixelSize: 11
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
        }
    }
}
