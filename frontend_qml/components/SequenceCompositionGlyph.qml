import QtQuick

Canvas {
    id: glyph

    property string compositionGrammar: "horizontal_rail"
    property color accent: "#FFFFFF"
    property color secondary: "#A8B0BA"
    property color ink: "#FFFFFF"
    property color panel: "#07111F"

    function line(ctx, x1, y1, x2, y2, color, thickness) {
        ctx.beginPath()
        ctx.moveTo(x1, y1)
        ctx.lineTo(x2, y2)
        ctx.strokeStyle = color
        ctx.lineWidth = thickness
        ctx.lineCap = "round"
        ctx.stroke()
    }

    function dot(ctx, x, y, radius, color) {
        ctx.beginPath()
        ctx.arc(x, y, radius, 0, Math.PI * 2)
        ctx.fillStyle = color
        ctx.fill()
    }

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        var active = String(accent)
        var second = String(secondary)
        var white = String(ink)
        var dim = "rgba(255,255,255,0.28)"
        var left = width * 0.08
        var right = width * 0.92
        var span = right - left
        var y = height * 0.68
        var i

        // Same compact upper-left information footprint in every thumbnail.
        ctx.fillStyle = active
        ctx.fillRect(left, height * 0.14, width * 0.19, 2)
        ctx.fillRect(left, height * 0.22, width * 0.30, 4)
        ctx.fillStyle = white
        ctx.fillRect(left, height * 0.31, width * 0.22, 8)

        if (compositionGrammar === "archive_ledger") {
            for (i = 0; i <= 24; ++i)
                dot(ctx, left + span * i / 24, y, i % 6 === 0 ? 2.5 : 1.2,
                    i <= 12 ? active : dim)
        } else if (compositionGrammar === "zigzag_milestones") {
            for (i = 0; i < 10; ++i)
                line(ctx, left + span * i / 10, y,
                    left + span * (i + 0.55) / 10, y,
                    i < 5 ? active : dim, i < 5 ? 4 : 2)
        } else if (compositionGrammar === "geological_strata") {
            line(ctx, left, y, right, y, dim, 2)
            line(ctx, left, y, left + span * 0.52, y, active, 3)
            for (i = 0; i <= 20; ++i) {
                var tickX = left + span * i / 20
                line(ctx, tickX, y - (i % 5 === 0 ? 8 : 4), tickX,
                    y + (i % 5 === 0 ? 8 : 4),
                    i <= 10 ? active : dim, i % 5 === 0 ? 2 : 1)
            }
        } else if (compositionGrammar === "filmstrip") {
            for (i = 0; i < 12; ++i) {
                ctx.fillStyle = i < 6 ? (i % 2 ? second : active) : dim
                ctx.fillRect(left + span * i / 12, y - 4,
                    span / 15, i < 6 ? 8 : 5)
            }
        } else if (compositionGrammar === "split_era") {
            line(ctx, left, y - 3, right, y - 3, dim, 2)
            line(ctx, left, y - 3, left + span * 0.52, y - 3, active, 4)
            for (i = 0; i < 15; i += 2)
                line(ctx, left + span * i / 15, y + 5,
                    left + span * (i + 0.8) / 15, y + 5,
                    i < 8 ? second : dim, 2)
        } else if (compositionGrammar === "evolution_tree") {
            for (i = 0; i <= 25; ++i)
                dot(ctx, left + span * i / 25, y,
                    1.5 + Math.abs(Math.sin(i * 0.8)) * 2,
                    i <= 13 ? active : dim)
        } else {
            var glow = compositionGrammar === "vertical_chronology"
                || compositionGrammar === "radial_clock"
            ctx.shadowColor = glow ? active : "transparent"
            ctx.shadowBlur = glow ? 10 : 0
            line(ctx, left, y, right, y, dim, 2)
            line(ctx, left, y, left + span * 0.52, y,
                compositionGrammar === "chapter_cards" ? white : active,
                compositionGrammar === "vertical_chronology" ? 5 : 3)
            ctx.shadowBlur = 0
        }

        for (i = 0; i < 5; ++i)
            dot(ctx, left + span * i / 4, y, i === 2 ? 4 : 2.5,
                i <= 2 ? active : dim)
    }

    onCompositionGrammarChanged: requestPaint()
    onAccentChanged: requestPaint()
    onSecondaryChanged: requestPaint()
    onInkChanged: requestPaint()
    onPanelChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    Component.onCompleted: requestPaint()
}
