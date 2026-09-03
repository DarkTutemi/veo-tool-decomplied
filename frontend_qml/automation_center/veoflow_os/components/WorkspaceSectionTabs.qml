pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root
    property var sections: []
    property string currentKey: ""
    signal sectionRequested(string key)

    implicitHeight: 48
    radius: Theme.radiusMedium
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.name: "Điều hướng khu vực"
    Accessible.role: Accessible.Pane

    RowLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5

        Repeater {
            model: root.sections

            delegate: AppButton {
                id: sectionButton
                required property var modelData
                objectName: "workspaceSection_" + String(sectionButton.modelData.key)
                Layout.preferredWidth: Math.max(132, implicitWidth)
                Layout.fillHeight: true
                text: String(sectionButton.modelData.label || "")
                leadingIcon: String(sectionButton.modelData.icon || "")
                primary: root.currentKey === String(sectionButton.modelData.key)
                subtle: !primary
                Accessible.role: Accessible.PageTab
                Accessible.name: text
                Accessible.description: String(sectionButton.modelData.description || "")
                onClicked: root.sectionRequested(String(sectionButton.modelData.key))
            }
        }

        Item { Layout.fillWidth: true }
    }
}
