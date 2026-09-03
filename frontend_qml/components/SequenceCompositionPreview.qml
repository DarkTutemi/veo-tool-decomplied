pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property string compositionGrammar: "horizontal_rail"
    property color accent: "#FFFFFF"
    property color secondary: "#A8B0BA"
    property color primary: "#FFFFFF"
    property color muted: "#D7DEE8"
    property color panel: "#07111F"
    property color panelAlt: "#111C2B"
    property string visualSystemId: "clean_white_line"
    property string material: "transparent_overlay"
    property string headlineFontRole: "display"
    property string bodyFontRole: "display"
    property string numericFontRole: "data"
    property real progress: 0
    property int markerCount: 5
    property bool previewEnabled: true
    property string presetTitle: "CLEAN WHITE LINE"
    property real railY: 0.91
    property real glowScale: 0
    property real shadowScale: 0
    property real fontScale: 1
    property bool mirrorEnabled: false
    property bool interactive: false
    property real layoutXNorm: 0.5
    property real layoutYNorm: 0.5
    property real layoutWidthNorm: 1.0
    property real layoutHeightNorm: 1.0
    property string selectedTextRole: "heading"
    property color headingTextColor: accent
    property color eventTextColor: primary
    property color axisTextColor: muted
    property string headingTextFontRole: headlineFontRole
    property string eventTextFontRole: bodyFontRole
    property string axisTextFontRole: numericFontRole
    property real headingTextScale: fontScale
    property real eventTextScale: fontScale
    property real axisTextScale: 1.0
    property real headingTextGlow: glowScale
    property real eventTextGlow: glowScale
    property real axisTextGlow: glowScale
    property real headingTextShadow: shadowScale
    property real eventTextShadow: shadowScale
    property real axisTextShadow: shadowScale
    signal textRoleClicked(string role)
    signal positionPreviewed(real xNorm, real yNorm)
    signal positionCommitted(real xNorm, real yNorm)
    readonly property real resolvedLayoutWidth: Math.max(
        0.20, Math.min(1.0, root.layoutWidthNorm))
    readonly property real resolvedLayoutHeight: Math.max(
        0.20, Math.min(1.0, root.layoutHeightNorm))
    readonly property real resolvedLayoutX: Math.max(
        resolvedLayoutWidth / 2,
        Math.min(1 - resolvedLayoutWidth / 2, root.layoutXNorm))
    readonly property real resolvedLayoutY: Math.max(
        resolvedLayoutHeight / 2,
        Math.min(1 - resolvedLayoutHeight / 2, root.layoutYNorm))
    readonly property real layoutLeftNorm:
        resolvedLayoutX - resolvedLayoutWidth / 2
    readonly property real layoutTopNorm:
        resolvedLayoutY - resolvedLayoutHeight / 2
    readonly property real resolvedRailY: Math.max(
        0.72, Math.min(0.95, root.railY))
    readonly property real timelineReservedTopNorm: Math.max(
        0, Math.min(1, root.layoutTopNorm + root.resolvedLayoutHeight
            * Math.max(0.64, root.resolvedRailY - 0.08)))

    FontLoader {
        id: editorialFont
        source: "../../resources/fonts/timemachine/NotoSerif-SemiBold.ttf"
    }
    FontLoader {
        id: displayFont
        source: "../../resources/fonts/timemachine/BeVietnamPro-SemiBold.ttf"
    }
    FontLoader {
        id: roundedFont
        source: "../../resources/fonts/timemachine/BeVietnamPro-Bold.ttf"
    }
    FontLoader {
        id: dataFont
        source: "../../resources/fonts/timemachine/IBMPlexSans-SemiBold.ttf"
    }
    FontLoader {
        id: condensedFont
        source: "../../resources/fonts/timemachine/BarlowCondensed-SemiBold.ttf"
    }

    function familyForRole(role) {
        if (role === "editorial")
            return editorialFont.name
        if (role === "rounded")
            return roundedFont.name
        if (role === "data")
            return dataFont.name
        if (role === "condensed")
            return condensedFont.name
        return displayFont.name
    }

    function yearAt(index) {
        var years = ["1800", "1850", "1946", "2000", "2024"]
        return years[Math.max(0, Math.min(years.length - 1, index))]
    }

    function labelAt(index) {
        var labels = ["Khởi nguyên", "Chuyển dịch", "Bước ngoặt",
                      "Mở rộng", "Hiện tại"]
        return labels[Math.max(0, Math.min(labels.length - 1, index))]
    }

    readonly property string headlineFamily: familyForRole(headingTextFontRole)
    readonly property string bodyFamily: familyForRole(eventTextFontRole)
    readonly property string numericFamily: familyForRole(axisTextFontRole)
    readonly property int activeIndex: Math.max(0, Math.min(
        markerCount - 1, Math.floor(progress * markerCount)))
    readonly property real motionEnvelope: {
        var edge = 0.10
        if (progress < edge)
            return progress / edge
        if (progress > 1 - edge)
            return (1 - progress) / edge
        return 1
    }

    opacity: previewEnabled ? 0.38 + 0.62 * motionEnvelope : 0

    // The footprint is invariant across every rail style. Nothing is allowed
    // to create a panel in the footage centre.
    Item {
        id: infoBlock
        x: parent.width * (root.layoutLeftNorm
            + root.resolvedLayoutWidth * 0.045)
        y: parent.height * (root.layoutTopNorm
            + root.resolvedLayoutHeight * 0.075)
        width: parent.width * root.resolvedLayoutWidth * 0.38
        height: parent.height * root.resolvedLayoutHeight * 0.25
        scale: 0.985 + 0.015 * root.motionEnvelope
        transform: Translate {
            x: -12 * (1 - root.motionEnvelope)
        }

        Rectangle {
            width: parent.width * 0.30
            height: 3
            radius: 2
            color: root.accent
        }
        Text {
            id: headingText
            y: parent.height * 0.10
            width: parent.width
            text: root.presetTitle.toUpperCase()
                + "  ·  " + String(root.activeIndex + 1).padStart(2, "0")
                + " / " + String(root.markerCount).padStart(2, "0")
            color: root.headingTextColor
            font.family: root.headlineFamily
            font.pixelSize: Math.max(8, parent.height * 0.12 * root.headingTextScale)
            font.weight: Font.Bold
            font.letterSpacing: 1.2
            elide: Text.ElideRight
            maximumLineCount: 1
            style: root.headingTextGlow > 0.01 ? Text.Outline : Text.Raised
            styleColor: root.headingTextGlow > 0.01
                ? Qt.rgba(root.headingTextColor.r, root.headingTextColor.g,
                    root.headingTextColor.b, Math.min(0.82,
                        0.32 + root.headingTextGlow * 0.24))
                : Qt.rgba(0, 0, 0, 0.55 + root.headingTextShadow * 0.25)
        }
        Text {
            id: eventYearText
            y: parent.height * 0.31
            text: root.yearAt(root.activeIndex)
            color: root.eventTextColor
            font.family: root.numericFamily
            font.pixelSize: Math.max(22, parent.height * 0.34 * root.eventTextScale)
            font.weight: Font.Bold
            style: root.eventTextGlow > 0.01 ? Text.Outline : Text.Raised
            styleColor: root.eventTextGlow > 0.01
                ? Qt.rgba(root.eventTextColor.r, root.eventTextColor.g,
                    root.eventTextColor.b, Math.min(0.82,
                        0.32 + root.eventTextGlow * 0.24))
                : Qt.rgba(0, 0, 0, 0.55 + root.eventTextShadow * 0.25)
        }
        Text {
            id: eventLabelText
            y: parent.height * 0.70
            width: parent.width
            text: root.labelAt(root.activeIndex)
            color: root.eventTextColor
            font.family: root.bodyFamily
            font.pixelSize: Math.max(10, parent.height * 0.16 * root.eventTextScale)
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            style: root.eventTextGlow > 0.01 ? Text.Outline : Text.Raised
            styleColor: root.eventTextGlow > 0.01
                ? Qt.rgba(root.eventTextColor.r, root.eventTextColor.g,
                    root.eventTextColor.b, Math.min(0.82,
                        0.32 + root.eventTextGlow * 0.24))
                : Qt.rgba(0, 0, 0, 0.55 + root.eventTextShadow * 0.25)
        }

        Rectangle {
            visible: root.interactive && root.selectedTextRole === "heading"
            x: -6
            y: headingText.y - 4
            width: Math.min(parent.width, headingText.implicitWidth + 12)
            height: headingText.implicitHeight + 8
            radius: 3
            color: "transparent"
            border.width: 1
            border.color: root.accent
        }
        Rectangle {
            visible: root.interactive && root.selectedTextRole === "event"
            x: -6
            y: eventYearText.y - 5
            width: Math.min(parent.width, Math.max(
                eventYearText.implicitWidth, eventLabelText.implicitWidth) + 12)
            height: eventLabelText.y + eventLabelText.implicitHeight
                - eventYearText.y + 10
            radius: 3
            color: "transparent"
            border.width: 1
            border.color: root.accent
        }
        MouseArea {
            objectName: "sequenceHeadingTextHitArea"
            visible: root.interactive
            x: -8
            y: headingText.y - 7
            width: Math.min(parent.width, headingText.implicitWidth + 16)
            height: headingText.implicitHeight + 14
            cursorShape: Qt.PointingHandCursor
            onClicked: root.textRoleClicked("heading")
        }
        MouseArea {
            objectName: "sequenceEventTextHitArea"
            visible: root.interactive
            x: -8
            y: eventYearText.y - 7
            width: Math.min(parent.width, Math.max(
                eventYearText.implicitWidth, eventLabelText.implicitWidth) + 16)
            height: eventLabelText.y + eventLabelText.implicitHeight
                - eventYearText.y + 14
            cursorShape: Qt.PointingHandCursor
            onClicked: root.textRoleClicked("event")
        }
    }

    Item {
        id: railArea
        x: parent.width * (root.layoutLeftNorm
            + root.resolvedLayoutWidth * 0.05)
        y: parent.height * root.timelineReservedTopNorm
        width: parent.width * root.resolvedLayoutWidth * 0.90
        height: parent.height * root.resolvedLayoutHeight * 0.16

        Canvas {
            id: railCanvas
            anchors.fill: parent

            function paintLine(ctx, x1, y1, x2, y2, color, width) {
                ctx.beginPath()
                ctx.moveTo(x1, y1)
                ctx.lineTo(x2, y2)
                ctx.strokeStyle = color
                ctx.lineWidth = width
                ctx.lineCap = "round"
                ctx.stroke()
            }

            function paintDot(ctx, x, y, radius, color) {
                ctx.beginPath()
                ctx.arc(x, y, radius, 0, Math.PI * 2)
                ctx.fillStyle = color
                ctx.fill()
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var y = height * 0.62
                var left = width * 0.02
                var right = width * 0.98
                var span = right - left
                var progressX = left + span * root.progress
                var active = String(root.accent)
                var second = String(root.secondary)
                var white = String(root.primary)
                var dim = "rgba(255,255,255,0.30)"
                var grammar = root.compositionGrammar
                var i

                ctx.shadowBlur = root.glowScale > 0.01 ? 10 * root.glowScale : 0
                ctx.shadowColor = root.glowScale > 0.01 ? active : "transparent"

                if (grammar === "archive_ledger") {
                    for (i = 0; i <= 54; ++i) {
                        var dotX = left + span * i / 54
                        paintDot(ctx, dotX, y, i % 9 === 0 ? 3.4 : 1.8,
                            dotX <= progressX ? active : dim)
                    }
                } else if (grammar === "zigzag_milestones") {
                    for (i = 0; i < 18; ++i) {
                        var dashX = left + span * i / 18
                        var dashEnd = left + span * (i + 0.58) / 18
                        paintLine(ctx, dashX, y, dashEnd, y,
                            dashEnd <= progressX ? active : dim,
                            dashEnd <= progressX ? 6 : 3)
                    }
                } else if (grammar === "geological_strata") {
                    paintLine(ctx, left, y, right, y, dim, 2)
                    paintLine(ctx, left, y, progressX, y, active, 3)
                    for (i = 0; i <= 30; ++i) {
                        var tickX = left + span * i / 30
                        var major = i % 5 === 0
                        paintLine(ctx, tickX, y - (major ? 15 : 8), tickX,
                            y + (major ? 15 : 8),
                            tickX <= progressX ? active : dim, major ? 3 : 1.5)
                    }
                } else if (grammar === "filmstrip") {
                    var segmentGap = span * 0.008
                    var segmentWidth = (span - segmentGap * 13) / 14
                    for (i = 0; i < 14; ++i) {
                        var segmentX = left + i * (segmentWidth + segmentGap)
                        var enabled = segmentX + segmentWidth <= progressX
                        ctx.fillStyle = enabled ? (i % 2 ? second : active) : dim
                        ctx.fillRect(segmentX, y - (enabled ? 5 : 3),
                            segmentWidth, enabled ? 10 : 6)
                    }
                } else if (grammar === "split_era") {
                    paintLine(ctx, left, y - 5, right, y - 5, dim, 2)
                    paintLine(ctx, left, y - 5, progressX, y - 5, active, 5)
                    for (i = 0; i < 32; ++i) {
                        var dualX = left + span * i / 32
                        if (i % 2 === 0)
                            paintLine(ctx, dualX, y + 6,
                                Math.min(right, dualX + span / 52), y + 6,
                                dualX <= progressX ? second : dim, 3)
                    }
                } else if (grammar === "evolution_tree") {
                    for (i = 0; i <= 42; ++i) {
                        var signalX = left + span * i / 42
                        var wave = Math.abs(Math.sin(i * 0.78))
                        var distance = Math.abs(signalX - progressX) / span
                        var radius = 2 + wave * 2 + (distance < 0.06 ? 3 : 0)
                        paintDot(ctx, signalX, y, radius,
                            signalX <= progressX ? active : dim)
                    }
                } else {
                    var glow = grammar === "vertical_chronology"
                        || grammar === "radial_clock"
                    ctx.shadowColor = glow ? active : "transparent"
                    ctx.shadowBlur = glow ? 16 : 0
                    paintLine(ctx, left, y, right, y, dim,
                        grammar === "chapter_cards" ? 2 : 3)
                    paintLine(ctx, left, y, progressX, y,
                        grammar === "chapter_cards" ? white : active,
                        grammar === "vertical_chronology" ? 7 : 4)
                    ctx.shadowBlur = 0
                }

                // Common event markers preserve the same semantic geometry.
                for (i = 0; i < root.markerCount; ++i) {
                    var markerX = left + span * i / Math.max(1, root.markerCount - 1)
                    var isActive = i === root.activeIndex
                    var passed = i <= root.activeIndex
                    var isSquare = grammar === "zigzag_milestones"
                        || grammar === "filmstrip"
                    ctx.fillStyle = passed ? active : dim
                    ctx.strokeStyle = white
                    ctx.lineWidth = isActive ? 2.5 : 1
                    if (isSquare) {
                        var size = isActive ? 13 : 9
                        ctx.save()
                        ctx.translate(markerX, y)
                        if (grammar === "zigzag_milestones")
                            ctx.rotate(Math.PI / 4)
                        ctx.fillRect(-size / 2, -size / 2, size, size)
                        ctx.strokeRect(-size / 2, -size / 2, size, size)
                        ctx.restore()
                    } else {
                        paintDot(ctx, markerX, y, isActive ? 7 : 4,
                            passed ? active : dim)
                    }
                }

                ctx.shadowColor = grammar === "vertical_chronology"
                    || grammar === "radial_clock"
                    || grammar === "split_era" ? active : "transparent"
                ctx.shadowBlur = ctx.shadowColor === "transparent" ? 0 : 18
                paintDot(ctx, progressX, y,
                    grammar === "chapter_cards" ? 4 : 7,
                    grammar === "chapter_cards" ? white : active)
                ctx.shadowBlur = 0
                if (root.mirrorEnabled) {
                    ctx.save()
                    ctx.translate(0, 2 * y + 8)
                    ctx.scale(1, -1)
                    ctx.globalAlpha = 0.28
                    paintLine(ctx, left, y, right, y, dim, 2)
                    paintLine(ctx, left, y, progressX, y, active, 4)
                    for (i = 0; i < root.markerCount; ++i) {
                        var mx = left + span * i / Math.max(1, root.markerCount - 1)
                        paintDot(ctx, mx, y, i <= root.activeIndex ? 3.2 : 2, active)
                    }
                    ctx.restore()
                }
            }

            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            Component.onCompleted: requestPaint()
            Connections {
                target: root
                function onProgressChanged() { railCanvas.requestPaint() }
                function onCompositionGrammarChanged() { railCanvas.requestPaint() }
                function onAccentChanged() { railCanvas.requestPaint() }
                function onSecondaryChanged() { railCanvas.requestPaint() }
                function onPrimaryChanged() { railCanvas.requestPaint() }
                function onMarkerCountChanged() { railCanvas.requestPaint() }
                function onGlowScaleChanged() { railCanvas.requestPaint() }
                function onMirrorEnabledChanged() { railCanvas.requestPaint() }
            }
        }

        Repeater {
            model: root.markerCount
            delegate: Text {
                id: markerLabel
                required property int index
                x: railArea.width * (0.02 + 0.96 * index
                    / Math.max(1, root.markerCount - 1)) - width / 2
                y: railArea.height * 0.08
                text: root.yearAt(markerLabel.index)
                color: root.axisTextColor
                font.family: root.numericFamily
                font.pixelSize: Math.max(8,
                    railArea.height * 0.16 * root.axisTextScale)
                font.weight: markerLabel.index === root.activeIndex
                    ? Font.Bold : Font.DemiBold
                style: root.axisTextGlow > 0.01 ? Text.Outline : Text.Raised
                styleColor: root.axisTextGlow > 0.01
                    ? Qt.rgba(root.axisTextColor.r, root.axisTextColor.g,
                        root.axisTextColor.b, Math.min(0.82,
                            0.32 + root.axisTextGlow * 0.24))
                    : Qt.rgba(0, 0, 0, 0.55 + root.axisTextShadow * 0.25)
            }
        }

        Rectangle {
            visible: root.interactive && root.selectedTextRole === "axis"
            x: 0
            y: 0
            width: parent.width
            height: parent.height * 0.36
            radius: 3
            color: "transparent"
            border.width: 1
            border.color: root.accent
        }
        MouseArea {
            objectName: "sequenceAxisTextHitArea"
            visible: root.interactive
            x: 0
            y: 0
            width: parent.width
            height: parent.height * 0.40
            cursorShape: Qt.PointingHandCursor
            onClicked: root.textRoleClicked("axis")
        }
    }

    Rectangle {
        id: positionHandle
        objectName: "sequenceTimelinePositionHandle"
        visible: root.previewEnabled && root.interactive
        x: root.width * (root.layoutLeftNorm + root.resolvedLayoutWidth)
            - width
        y: root.height * root.layoutTopNorm
        width: Math.max(30, Math.min(74, root.width * 0.13))
        height: Math.max(20, Math.min(34, root.height * 0.045))
        radius: height / 2
        color: "#D9141C2B"
        border.width: 1
        border.color: root.accent
        z: 20

        Text {
            anchors.centerIn: parent
            text: "✥  Kéo"
            color: "#FFFFFF"
            font.family: root.bodyFamily
            font.pixelSize: Math.max(8, parent.height * 0.42)
            font.weight: Font.Bold
        }

        MouseArea {
            id: timelineDragArea
            objectName: "sequenceTimelineDragArea"
            anchors.fill: parent
            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            property real offsetXNorm: 0
            property real offsetYNorm: 0

            function rootPoint(mouse) {
                return mapToItem(root, mouse.x, mouse.y)
            }

            function normalizedPosition(mouse) {
                var point = rootPoint(mouse)
                return Qt.point(
                    Math.max(root.resolvedLayoutWidth / 2,
                        Math.min(1 - root.resolvedLayoutWidth / 2,
                            point.x / Math.max(1, root.width) + offsetXNorm)),
                    Math.max(root.resolvedLayoutHeight / 2,
                        Math.min(1 - root.resolvedLayoutHeight / 2,
                            point.y / Math.max(1, root.height) + offsetYNorm)))
            }

            onPressed: mouse => {
                var point = rootPoint(mouse)
                offsetXNorm = root.resolvedLayoutX
                    - point.x / Math.max(1, root.width)
                offsetYNorm = root.resolvedLayoutY
                    - point.y / Math.max(1, root.height)
            }
            onPositionChanged: mouse => {
                if (!pressed)
                    return
                var point = normalizedPosition(mouse)
                root.positionPreviewed(point.x, point.y)
            }
            onReleased: mouse => {
                var point = normalizedPosition(mouse)
                root.positionPreviewed(point.x, point.y)
                root.positionCommitted(point.x, point.y)
            }
        }
    }
}
