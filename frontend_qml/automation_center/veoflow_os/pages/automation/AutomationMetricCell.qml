pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    property string metricKey: ""
    property string value: "—"
    property string label: ""
    property string delta: ""
    property string iconName: ""
    property color tone: Theme.accent
    objectName: "automationMetric_" + root.metricKey
    implicitWidth: 142
    implicitHeight: 72
    radius: Theme.radiusMedium
    color: Theme.elevated
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.name: root.label + ": " + root.value
        + (root.delta.length > 0 ? ", " + root.delta : "")
    Accessible.role: Accessible.StaticText

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: 16
            color: Qt.rgba(root.tone.r, root.tone.g, root.tone.b, 0.14)

            UiIcon {
                objectName: "automationMetric_" + root.metricKey + "Icon"
                anchors.centerIn: parent
                name: root.iconName
                tone: root.tone
                iconSize: 18
                visible: root.iconName.length > 0
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                objectName: "automationMetric_" + root.metricKey + "Value"
                Layout.fillWidth: true
                Layout.minimumHeight: 23
                text: root.value
                color: Theme.text
                font.pixelSize: 19
                font.weight: Font.Bold
                elide: Text.ElideRight
            }
            Text {
                objectName: "automationMetric_" + root.metricKey + "Label"
                Layout.fillWidth: true
                Layout.minimumHeight: 14
                text: root.label
                color: Theme.textMuted
                font.pixelSize: 11
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                Layout.minimumHeight: visible ? 14 : 0
                visible: root.delta.length > 0
                text: root.delta
                color: root.tone
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
    }
}
