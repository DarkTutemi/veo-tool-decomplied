pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property string sourceText: ""
    property string wordState: "off"
    property real playhead: 0.0
    property color primaryColor: "white"
    property color accentColor: "#FACC15"
    property color outlineColor: "#0B1220"
    property string fontFamily: ""
    property real fontPixelSize: 32
    property real minimumFontPixelSize: 1
    property int fontWeight: Font.DemiBold
    property bool fontItalic: false
    property bool fontUnderline: false
    property bool fontStrikeout: false
    property bool uppercase: false
    property real letterSpacing: 0.0
    property int horizontalAlignment: Text.AlignHCenter
    property bool outlineEnabled: false

    readonly property real phase: Math.max(0.0, Math.min(1.0, playhead))
    readonly property string displayText: uppercase
        ? String(sourceText || "").toUpperCase() : String(sourceText || "")
    readonly property real paintedLeft: horizontalAlignment === Text.AlignLeft
        ? 0.0 : (horizontalAlignment === Text.AlignRight
        ? Math.max(0.0, width - baseText.paintedWidth)
        : Math.max(0.0, (width - baseText.paintedWidth) / 2.0))
    readonly property real paintedWidth: baseText.paintedWidth
    readonly property real paintedHeight: baseText.paintedHeight

    implicitHeight: baseText.implicitHeight
    Accessible.name: displayText

    function escapedHtml(value) {
        return String(value || "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/\"/g, "&quot;")
    }

    function accentHtml(value) {
        var words = String(value || "").split(/\s+/).filter(function(word) {
            return word.length > 0
        })
        if (words.length < 2)
            return escapedHtml(value)
        var selected = Math.floor(words.length / 2)
        var primary = String(root.primaryColor)
        var accent = String(root.accentColor)
        return words.map(function(word, index) {
            var color = index === selected ? accent : primary
            return "<span style=\"color:" + color + "\">"
                + root.escapedHtml(word) + "</span>"
        }).join(" ")
    }

    function revealText(value, progress) {
        var words = String(value || "").split(/\s+/).filter(function(word) {
            return word.length > 0
        })
        var count = Math.max(0, Math.min(words.length,
            Math.floor(Number(progress || 0) * (words.length + 1))))
        return words.slice(0, count).join(" ")
    }

    Text {
        id: baseText
        width: root.width
        text: root.wordState === "reveal"
            ? root.revealText(root.displayText, root.phase)
            : (root.wordState === "color"
            ? root.accentHtml(root.displayText) : root.displayText)
        textFormat: root.wordState === "color" ? Text.RichText : Text.PlainText
        color: root.primaryColor
        font.family: root.fontFamily
        font.pixelSize: root.fontPixelSize
        fontSizeMode: Text.HorizontalFit
        minimumPixelSize: Math.max(1, Math.min(root.fontPixelSize,
            root.minimumFontPixelSize))
        font.weight: root.fontWeight
        font.italic: root.fontItalic
        font.underline: root.fontUnderline
        font.strikeout: root.fontStrikeout
        font.letterSpacing: root.letterSpacing
        horizontalAlignment: root.horizontalAlignment
        wrapMode: Text.NoWrap
        elide: Text.ElideNone
        style: root.outlineEnabled ? Text.Outline : Text.Normal
        styleColor: root.outlineColor
    }

    Item {
        x: root.paintedLeft
        width: baseText.paintedWidth * root.phase
        height: root.height
        visible: root.wordState === "karaoke"
        clip: true

        Text {
            x: -root.paintedLeft
            width: root.width
            text: root.displayText
            color: root.accentColor
            font.family: root.fontFamily
            font.pixelSize: root.fontPixelSize
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: Math.max(1, Math.min(root.fontPixelSize,
                root.minimumFontPixelSize))
            font.weight: root.fontWeight
            font.italic: root.fontItalic
            font.underline: root.fontUnderline
            font.strikeout: root.fontStrikeout
            font.letterSpacing: root.letterSpacing
            horizontalAlignment: root.horizontalAlignment
            wrapMode: Text.NoWrap
            elide: Text.ElideNone
            style: root.outlineEnabled ? Text.Outline : Text.Normal
            styleColor: root.outlineColor
        }
    }
}
