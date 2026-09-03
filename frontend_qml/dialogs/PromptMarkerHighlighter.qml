import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root
    objectName: "promptMarkerHighlighter"

    property string text: ""
    property string placeholderText: ""
    property color markerColor: VfTheme.blueFill
    property color markerBorderColor: "#60A5FA"

    signal textChangedByUser(string text)
    signal markerRequested(string selectedText)

    function clear() {
        editor.clear()
    }

    function hasSelection() {
        return editor.selectionStart !== editor.selectionEnd
    }

    function selectionStart() {
        return Math.min(editor.selectionStart, editor.selectionEnd)
    }

    function selectionEnd() {
        return Math.max(editor.selectionStart, editor.selectionEnd)
    }

    function selectedText() {
        return editor.selectedText
    }

    function focusEditor() {
        editor.forceActiveFocus()
    }

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: VfTheme.radiusControl
    color: VfTheme.surface
    border.color: VfTheme.borderBox

    TextArea {
        id: editor
        anchors.fill: parent
        anchors.margins: VfTheme.dp(8)
        text: root.text
        wrapMode: TextArea.Wrap
        selectByMouse: true
        placeholderText: root.placeholderText
        placeholderTextColor: VfTheme.textSubtle
        selectedTextColor: "#FFFFFF"
        selectionColor: VfTheme.primary
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontBody
        background: Rectangle {
            color: "transparent"
        }
        onTextChanged: root.textChangedByUser(text)
    }

    Row {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: VfTheme.dp(8)
        spacing: VfTheme.dp(6)

        Repeater {
            model: [
                { label: "[START_PROMPT_1]", color: root.markerColor },
                { label: "[END_PROMPT_1]", color: VfTheme.redFill }
            ]

            Rectangle {
                width: markerText.implicitWidth + 12
                height: VfTheme.dp(22)
                radius: VfTheme.dp(11)
                color: modelData.color
                border.color: root.markerBorderColor

                Text {
                    id: markerText
                    anchors.centerIn: parent
                    text: modelData.label
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    font.weight: VfTheme.weightStrong
                }
            }
        }
    }
}
