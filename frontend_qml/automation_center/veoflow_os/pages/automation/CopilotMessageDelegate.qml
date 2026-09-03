pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Item {
    id: root
    required property var modelData

    readonly property bool isUser: String(root.modelData.role || "") === "user"

    width: ListView.view ? ListView.view.width : 620
    implicitHeight: messageBubble.implicitHeight + 4
    height: implicitHeight
    Accessible.role: Accessible.ListItem
    Accessible.name: (root.isUser ? "Bạn: " : "Channel Copilot: ")
        + String(root.modelData.content || "")

    Rectangle {
        id: messageBubble
        x: root.isUser ? root.width - width : 0
        width: Math.min(root.width * (root.isUser ? 0.68 : 0.92), 680)
        implicitHeight: messageRow.implicitHeight + 14
        radius: Theme.radiusSmall
        color: root.isUser ? Theme.accentSoft : Theme.panel
        border.width: 1
        border.color: root.isUser ? Theme.accent : Theme.borderSoft

        RowLayout {
            id: messageRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 7
            spacing: 7

            UiIcon {
                visible: !root.isUser
                objectName: "copilotAssistantIcon_" + String(
                    root.modelData.messageId || "message")
                name: "ui/sparkles"
                tone: Theme.accent
                iconSize: 15
                Layout.preferredWidth: visible ? 16 : 0
                Layout.preferredHeight: 16
            }
            Text {
                Layout.fillWidth: true
                text: String(root.modelData.content || "")
                color: Theme.text
                font.pixelSize: Theme.fontMetadata
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }
        }
    }
}
