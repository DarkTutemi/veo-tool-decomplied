pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    property int stepNumber: 1
    property string title: ""
    property string detail: ""
    property string iconName: ""
    property color tone: Theme.accent

    implicitWidth: 184
    implicitHeight: 40
    radius: Theme.radiusMedium
    color: Qt.rgba(root.tone.r, root.tone.g, root.tone.b, 0.07)
    border.width: 1
    border.color: Qt.rgba(root.tone.r, root.tone.g, root.tone.b, 0.38)
    Accessible.name: String(root.stepNumber) + ". " + root.title + ". " + root.detail
    Accessible.role: Accessible.StaticText

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 7

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 12
            color: Qt.rgba(root.tone.r, root.tone.g, root.tone.b, 0.15)
            UiIcon {
                anchors.centerIn: parent
                name: root.iconName
                tone: root.tone
                iconSize: 14
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: String(root.stepNumber) + " · " + root.title
                color: Theme.text
                font.pixelSize: 11
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: root.detail
                color: Theme.textMuted
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
    }
}
