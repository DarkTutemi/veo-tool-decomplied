import QtQuick
import "../theme"
import "AppIconRegistry.js" as AppIconRegistry

// Extracted from WorkPanelWorkspace.qml (inline component) — same-dir auto-resolve.
// Shared by the Extend + Affiliate route bodies. root.cleanText → stripGlyph.
Rectangle {
    id: box

    property string title: ""
    default property alias content: boxContent.data

    function cleanText(value) { return AppIconRegistry.stripGlyph(String(value || "")) }

    radius: VfTheme.dp(10)
    color: VfTheme.surface
    border.color: VfTheme.borderStrong
    clip: true

    Text {
        anchors.left: parent.left
        anchors.leftMargin: VfTheme.dp(14)
        anchors.top: parent.top
        anchors.topMargin: VfTheme.dp(12)
        text: box.cleanText(box.title)
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontSection
        font.weight: VfTheme.weightTitle
    }

    Item {
        id: boxContent
        anchors.fill: parent
    }
}
