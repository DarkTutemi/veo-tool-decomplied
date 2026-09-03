import QtQuick
import "../theme"
import "AppIconRegistry.js" as AppIconRegistry

// Extracted from WorkPanelWorkspace.qml (inline component) — same-dir auto-resolve.
// Shared by the Extend + Affiliate route bodies, so it lives in its own file.
// root.cleanText → AppIconRegistry.stripGlyph (same pattern as NormalToolbarButton).
Rectangle {
    id: pill

    property string text: ""
    property color accent: VfTheme.primary

    function cleanText(value) { return AppIconRegistry.stripGlyph(String(value || "")) }

    implicitWidth: Math.max(62, pillText.implicitWidth + 20)
    implicitHeight: VfTheme.dp(28)
    radius: VfTheme.dp(14)
    color: VfTheme.blueFill
    border.color: accent

    Text {
        id: pillText
        anchors.centerIn: parent
        text: pill.cleanText(pill.text)
        color: accent
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontSmall
        font.weight: VfTheme.weightStrong
        elide: Text.ElideRight
        maximumLineCount: 1
    }
}
