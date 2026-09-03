import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string markdown: ""
    property string emptyText: "No content"
    property string placeholder: emptyText

    function setMarkdown(text) {
        root.markdown = String(text || "")
    }

    function appendMarkdown(text) {
        root.markdown += String(text || "")
        Qt.callLater(function() { bodyText.cursorPosition = bodyText.length })
    }

    function clear() {
        root.markdown = ""
    }

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: VfTheme.radiusControl
    color: VfTheme.surface
    border.color: VfTheme.borderBox
    clip: true

    ScrollView {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(10)
        clip: true

        TextArea {
            id: bodyText
            text: root.markdown.length > 0 ? root.markdown : root.emptyText
            textFormat: root.markdown.length > 0 ? TextEdit.MarkdownText : TextEdit.PlainText
            readOnly: true
            wrapMode: TextArea.Wrap
            selectByMouse: true
            color: root.markdown.length > 0 ? VfTheme.text : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontBody
            background: Rectangle {
                color: "transparent"
                border.color: "transparent"
            }
        }
    }
}
