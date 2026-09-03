pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property bool previewEnabled: false
    property string requestedStyle: "auto"
    property string requestedLength: "auto"
    property string requestedPosition: "auto"
    property string intensity: "balanced"
    property int seed: 1
    property real progress: 0
    property color accent: "#4E8CFF"
    property color secondary: "#7C5CFC"
    property color muted: "#C9D4E5"
    property bool bottomReserved: false
    property bool customEnabled: false
    property real thicknessScale: 1.0
    property real amplitudeScale: 1.0
    property real glowScale: 1.0
    property real customWidthRatio: 0.0
    property real customXNorm: -1.0
    property real customYNorm: -1.0
    property real layoutXNorm: -1.0
    property real layoutYNorm: -1.0
    property real layoutWidthNorm: 0.0
    property real layoutHeightNorm: 0.0
    property bool interactive: false
    signal positionPreviewed(real xNorm, real yNorm)
    signal positionCommitted(real xNorm, real yNorm)

    component PrimitiveGlow: Rectangle {
        required property color haloColor
        required property real sourceWidth
        required property real sourceHeight
        required property real sourceRadius
        required property real glowAmount
        anchors.centerIn: parent
        width: sourceWidth + Math.max(2, 7 * glowAmount)
        height: sourceHeight + Math.max(2, 7 * glowAmount)
        radius: Math.max(sourceRadius, Math.min(width, height) / 2)
        color: haloColor
        opacity: glowAmount > 0.01
            ? Math.min(0.32, 0.07 + glowAmount * 0.11) : 0
        visible: glowAmount > 0.01
        z: -1
    }

    readonly property int stableSeed: seed > 0 ? seed : 7919
    readonly property var timelineStyles: [
        "wave_line", "twin_ribbon", "peak_bars", "one_sided",
        "dot_trace", "capsule_chain", "heartbeat_trace",
        "stepped_blocks", "stereo_ribbon", "segmented_led",
        "reflection_wave", "needle_ticks", "split_channel"
    ]
    readonly property var visualizerStyles: [
        "live_equalizer", "mirror_spectrum", "oscilloscope",
        "three_band", "beat_pulse", "voice_meter", "spectral_columns",
        "dot_matrix", "radial_orbit", "led_spectrum", "octave_bands",
        "radial_spectrum", "radial_invert", "spectrum_reflection",
        "waterfall", "peak_hold", "particle_spine"
    ]
    readonly property var styleChoices: timelineStyles.concat(visualizerStyles)
    readonly property string resolvedStyle: requestedStyle === "auto"
        ? styleChoices[Math.abs(stableSeed) % styleChoices.length]
        : requestedStyle
    readonly property string resolvedMode:
        timelineStyles.indexOf(resolvedStyle) >= 0 ? "timeline" : "visualizer"
    readonly property string resolvedLength: requestedLength === "auto"
        ? (Math.abs(stableSeed * 17) % 100 < 58 ? "full" : "half")
        : requestedLength
    readonly property var fullPositions: ["top", "bottom"]
    readonly property var halfPositions: [
        "top_left", "top_right", "bottom_left", "bottom_right"
    ]
    readonly property var safeFullPositions: bottomReserved ? ["top"] : fullPositions
    readonly property var safeHalfPositions: bottomReserved
        ? ["top_left", "top_right"] : halfPositions
    readonly property string resolvedPosition: requestedPosition === "auto"
        ? (resolvedLength === "full"
            ? safeFullPositions[Math.abs(stableSeed * 31) % safeFullPositions.length]
            : safeHalfPositions[Math.abs(stableSeed * 31) % safeHalfPositions.length])
        : requestedPosition
    readonly property bool useSharedLayout: layoutWidthNorm > 0
        && layoutXNorm >= 0 && layoutYNorm >= 0
    readonly property real widthRatio: useSharedLayout
        ? layoutWidthNorm
        : (customEnabled && customWidthRatio > 0
            ? Math.max(0.20, Math.min(0.94, customWidthRatio))
            : (resolvedLength === "half" ? 0.46 : 0.98))
    readonly property real visualWidth: width * widthRatio
    readonly property real visualHeight: useSharedLayout
        ? height * layoutHeightNorm
        : (height * (resolvedMode === "visualizer"
            ? (intensity === "strong" ? 0.088
                : (intensity === "subtle" ? 0.052 : 0.070))
            : (intensity === "strong" ? 0.072
                : (intensity === "subtle" ? 0.040 : 0.054)))
            * Math.max(0.40, Math.min(2.0, amplitudeScale)))
    readonly property int itemCount: resolvedLength === "half" ? 34 : 62
    readonly property bool useCustomPosition: customEnabled && customXNorm >= 0
        && customYNorm >= 0 && (resolvedPosition === "custom"
            || waveformDragArea.pressed)
    readonly property real safeCenterX: useCustomPosition
        ? Math.max(widthRatio / 2, Math.min(1 - widthRatio / 2, customXNorm))
        : -1
    readonly property real startX: safeCenterX >= 0
        ? width * safeCenterX - visualWidth / 2
        : (useSharedLayout
            ? width * layoutXNorm - visualWidth / 2
            : (resolvedLength === "full"
                ? (width - visualWidth) / 2
                : (resolvedPosition.indexOf("right") >= 0
                    ? width - visualWidth - width * 0.015 : width * 0.015)))
    readonly property bool topLane: resolvedPosition.indexOf("top") === 0
        || resolvedPosition === "top"
    readonly property real centerY: useCustomPosition
        ? Math.max(visualHeight * 0.65 / height,
            Math.min(1 - visualHeight * 0.65 / height, customYNorm)) * height
        : (useSharedLayout
            ? height * layoutYNorm
            : (topLane ? height * 0.045 : height * 0.955))
    readonly property int activeIndex: Math.max(0, Math.min(
        itemCount - 1, Math.floor(progress * itemCount)))

    visible: previewEnabled
    Accessible.ignored: true

    function randomAt(index, salt) {
        var value = Math.sin((stableSeed + index * 37 + salt * 101)
            * 12.9898) * 43758.5453
        return value - Math.floor(value)
    }

    function amplitudeAt(index) {
        var wave = Math.abs(Math.sin(index * 0.41 + stableSeed * 0.0017))
        var voice = Math.abs(Math.sin(index * 0.137 + 1.3))
        return Math.max(0.08, Math.min(1,
            wave * 0.42 + voice * 0.23 + randomAt(index, 7) * 0.35))
    }

    function liveAmplitudeAt(index, salt) {
        var clock = Math.floor(progress * 180)
        return amplitudeAt(clock - itemCount + index + salt)
    }

    Repeater {
        model: root.itemCount - 1

        delegate: Rectangle {
            required property int index
            readonly property real step: root.visualWidth / root.itemCount
            readonly property real valueA: root.amplitudeAt(index)
            readonly property real valueB: root.amplitudeAt(index + 1)
            readonly property real xA: root.startX + step * (index + 0.5)
            readonly property real xB: root.startX + step * (index + 1.5)
            readonly property real sign: (root.resolvedStyle === "twin_ribbon"
                || root.resolvedStyle === "stereo_ribbon"
                || root.resolvedStyle === "reflection_wave")
                && index % 2 ? -1 : 1
            readonly property real shapeA: root.resolvedStyle === "heartbeat_trace"
                ? (index % 11 === 5 ? -valueA * 0.48
                    : (index % 11 === 6 ? valueA * 0.30
                        : (0.5 - valueA) * 0.10))
                : (root.resolvedStyle === "stereo_ribbon"
                    ? sign * (0.19 + valueA * 0.23)
                    : (root.resolvedStyle === "reflection_wave"
                        ? sign * valueA * 0.38
                        : sign * (0.5 - valueA) * 0.76))
            readonly property real shapeB: root.resolvedStyle === "heartbeat_trace"
                ? ((index + 1) % 11 === 5 ? -valueB * 0.48
                    : ((index + 1) % 11 === 6 ? valueB * 0.30
                        : (0.5 - valueB) * 0.10))
                : (root.resolvedStyle === "stereo_ribbon"
                    ? sign * (0.19 + valueB * 0.23)
                    : (root.resolvedStyle === "reflection_wave"
                        ? sign * valueB * 0.38
                        : sign * (0.5 - valueB) * 0.76))
            readonly property real yA: root.centerY + shapeA * root.visualHeight
            readonly property real yB: root.centerY + shapeB * root.visualHeight
            readonly property real dx: xB - xA
            readonly property real dy: yB - yA

            visible: root.previewEnabled && (root.resolvedStyle === "wave_line"
                || root.resolvedStyle === "twin_ribbon"
                || root.resolvedStyle === "heartbeat_trace"
                || root.resolvedStyle === "stereo_ribbon"
                || root.resolvedStyle === "reflection_wave")
            x: xA
            y: yA - height / 2
            width: Math.sqrt(dx * dx + dy * dy) + 1
            height: (root.resolvedStyle === "twin_ribbon" ? 2
                : (root.resolvedStyle === "stereo_ribbon" ? 5 : 3))
                * root.thicknessScale
            radius: height / 2
            rotation: Math.atan2(dy, dx) * 180 / Math.PI
            transformOrigin: Item.Left
            color: index <= root.activeIndex
                ? ((root.resolvedStyle === "twin_ribbon"
                    || root.resolvedStyle === "stereo_ribbon"
                    || root.resolvedStyle === "reflection_wave") && index % 2
                    ? root.secondary : root.accent)
                : Qt.rgba(root.muted.r, root.muted.g, root.muted.b, 0.25)

            PrimitiveGlow {
                haloColor: parent.color
                sourceWidth: parent.width
                sourceHeight: parent.height
                sourceRadius: parent.radius
                glowAmount: root.glowScale
            }
        }
    }

    Repeater {
        model: (root.resolvedLength === "half" ? 18 : 30) * 5

        delegate: Rectangle {
            id: segmentRect
            required property int index
            readonly property int columns: root.resolvedLength === "half" ? 18 : 30
            readonly property int columnIndex: index % columns
            readonly property int segmentIndex: Math.floor(index / columns)
            readonly property real step: root.visualWidth / columns
            readonly property real energy: root.amplitudeAt(columnIndex)
            readonly property bool segmentOn: segmentIndex < Math.max(1,
                Math.round(energy * 5))

            visible: root.previewEnabled && root.resolvedStyle === "segmented_led"
            x: root.startX + step * (columnIndex + 0.5) - width / 2
            y: root.centerY + root.visualHeight * 0.46
                - height * (segmentIndex + 0.5) * 1.22
            width: Math.max(2, step * 0.58 * root.thicknessScale)
            height: Math.max(2, root.visualHeight * 0.12)
            radius: 2
            color: columnIndex <= root.activeIndex * columns / root.itemCount
                && segmentOn ? (segmentIndex > 3 ? root.secondary : root.accent)
                : Qt.rgba(root.muted.r, root.muted.g, root.muted.b, 0.12)

            PrimitiveGlow {
                haloColor: parent.color
                sourceWidth: parent.width
                sourceHeight: parent.height
                sourceRadius: parent.radius
                glowAmount: segmentRect.segmentOn ? root.glowScale : 0
            }
        }
    }

    Repeater {
        model: root.resolvedLength === "half" ? 22 : 40

        delegate: Rectangle {
            required property int index
            readonly property int count: root.resolvedLength === "half" ? 22 : 40
            readonly property real step: root.visualWidth / count
            readonly property real energy: root.amplitudeAt(index)

            visible: root.previewEnabled && root.resolvedStyle === "needle_ticks"
            x: root.startX + step * (index + 0.5) - width / 2
            y: root.centerY - height / 2 + (0.5 - energy) * root.visualHeight * 0.28
            width: Math.max(1.5, 2.2 * root.thicknessScale)
            height: root.visualHeight * (0.30 + energy * 0.54)
            radius: width / 2
            rotation: (energy - 0.5) * 28
            color: index / count <= root.progress ? root.accent
                : Qt.rgba(root.muted.r, root.muted.g, root.muted.b, 0.22)

            PrimitiveGlow {
                haloColor: parent.color
                sourceWidth: parent.width
                sourceHeight: parent.height
                sourceRadius: parent.radius
                glowAmount: root.glowScale
            }
        }
    }

    Repeater {
        model: (root.resolvedLength === "half" ? 20 : 36) * 2

        delegate: Rectangle {
            required property int index
            readonly property int columns: root.resolvedLength === "half" ? 20 : 36
            readonly property int columnIndex: index % columns
            readonly property int channelIndex: Math.floor(index / columns)
            readonly property real step: root.visualWidth / columns
            readonly property real energy: root.amplitudeAt(
                columnIndex + channelIndex * 13)

            visible: root.previewEnabled && root.resolvedStyle === "split_channel"
            x: root.startX + step * (columnIndex + 0.5) - width / 2
            y: channelIndex === 0 ? root.centerY - height : root.centerY
            width: Math.max(2, step * 0.48 * root.thicknessScale)
            height: Math.max(2, root.visualHeight * energy * 0.48)
            radius: width / 2
            color: columnIndex / columns <= root.progress
                ? (channelIndex === 0 ? root.accent : root.secondary)
                : Qt.rgba(root.muted.r, root.muted.g, root.muted.b, 0.18)

            PrimitiveGlow {
                haloColor: parent.color
                sourceWidth: parent.width
                sourceHeight: parent.height
                sourceRadius: parent.radius
                glowAmount: root.glowScale
            }
        }
    }

    Repeater {
        model: root.itemCount

        delegate: Rectangle {
            required property int index
            readonly property real step: root.visualWidth / root.itemCount
            readonly property real amplitude: root.amplitudeAt(index)
            readonly property real barHeight: Math.max(
                2, root.visualHeight * amplitude)
            readonly property bool active: index <= root.activeIndex

            visible: root.previewEnabled && [
                "peak_bars", "one_sided", "capsule_chain", "stepped_blocks"
            ].indexOf(root.resolvedStyle) >= 0
            x: root.startX + step * index + (step - width) / 2
            y: root.resolvedStyle === "one_sided"
                ? (root.topLane ? root.centerY
                    : root.centerY - barHeight)
                : (root.resolvedStyle === "capsule_chain"
                    ? root.centerY + (index % 2 ? -1 : 1)
                        * root.visualHeight * amplitude * 0.18 - height / 2
                    : root.centerY - barHeight / 2)
            width: root.resolvedStyle === "capsule_chain"
                ? Math.max(5, step * (0.46 + amplitude * 0.34))
                : (root.resolvedStyle === "stepped_blocks"
                    ? Math.max(2, step * 0.82)
                    : Math.max(1.5, step * 0.55 * root.thicknessScale))
            height: root.resolvedStyle === "capsule_chain"
                ? Math.max(3, root.visualHeight * (0.08 + amplitude * 0.22))
                : barHeight
            radius: root.resolvedStyle === "capsule_chain" ? height / 2 : width / 2
            rotation: root.resolvedStyle === "capsule_chain"
                ? (index % 2 ? -1 : 1) * (4 + amplitude * 8) : 0
            color: active
                ? (index % 2 && root.resolvedStyle === "capsule_chain"
                    ? root.secondary : root.accent)
                : Qt.rgba(root.muted.r, root.muted.g, root.muted.b, 0.25)

            PrimitiveGlow {
                haloColor: parent.color
                sourceWidth: parent.width
                sourceHeight: parent.height
                sourceRadius: parent.radius
                glowAmount: root.glowScale
            }
        }
    }

    Repeater {
        model: root.itemCount

        delegate: Rectangle {
            required property int index
            readonly property real step: root.visualWidth / root.itemCount
            readonly property real amplitude: root.amplitudeAt(index)
            readonly property real size: Math.max(3, Math.min(8, step * 0.55))

            visible: root.previewEnabled && root.resolvedStyle === "dot_trace"
            x: root.startX + step * (index + 0.5) - size / 2
            y: root.centerY + (0.5 - amplitude) * root.visualHeight * 0.82
                - size / 2
            width: size
            height: size
            radius: size / 2
            color: index <= root.activeIndex ? root.accent
                : Qt.rgba(root.muted.r, root.muted.g, root.muted.b, 0.25)
            scale: index === root.activeIndex ? 1 + amplitude * 0.32 : 1

            PrimitiveGlow {
                haloColor: parent.color
                sourceWidth: parent.width
                sourceHeight: parent.height
                sourceRadius: parent.radius
                glowAmount: root.glowScale
            }
        }
    }

    Repeater {
        model: root.resolvedLength === "half" ? 9 : 15

        delegate: Item {
            id: spectralColumn
            required property int index
            readonly property int count: root.resolvedLength === "half" ? 9 : 15
            readonly property real step: root.visualWidth / count
            x: root.startX + step * index
            y: root.centerY - root.visualHeight * 0.48
            width: step
            height: root.visualHeight * 0.96
            visible: root.previewEnabled && root.resolvedStyle === "spectral_columns"

            Repeater {
                model: 3
                delegate: Rectangle {
                    required property int index
                    readonly property real energy: root.liveAmplitudeAt(
                        spectralColumn.index * 5, index * 23)
                    x: (spectralColumn.width - width) / 2
                    y: spectralColumn.height * (0.16 + index * 0.34)
                        - height / 2
                    width: Math.max(
                        2,
                        spectralColumn.width * 0.68 * root.thicknessScale)
                    height: Math.max(
                        2,
                        spectralColumn.height * (0.05 + energy * 0.19))
                    radius: index === 1 ? 2 : width / 2
                    color: index === 0 ? root.secondary
                        : (index === 1 ? root.accent : "#FFFFFF")
                    opacity: 0.38 + energy * 0.62
                }
            }
        }
    }

    Repeater {
        model: (root.resolvedLength === "half" ? 12 : 20) * 5

        delegate: Rectangle {
            required property int index
            readonly property int columns: root.resolvedLength === "half" ? 12 : 20
            readonly property int columnIndex: index % columns
            readonly property int rowIndex: Math.floor(index / columns)
            readonly property real cellWidth: root.visualWidth / columns
            readonly property real cellHeight: root.visualHeight / 5
            readonly property real energy: root.liveAmplitudeAt(columnIndex * 3,
                rowIndex * 29)
            readonly property bool activeDot: energy >= (1 - (rowIndex + 1) / 5) * 0.92
            readonly property real dotSize: Math.max(2,
                Math.min(cellWidth, cellHeight) * 0.34 * root.thicknessScale)

            visible: root.previewEnabled && root.resolvedStyle === "dot_matrix"
            x: root.startX + cellWidth * (columnIndex + 0.5) - width / 2
            y: root.centerY - root.visualHeight / 2
                + cellHeight * (rowIndex + 0.5) - height / 2
            width: dotSize
            height: dotSize
            radius: dotSize / 2
            color: rowIndex < 2 ? root.secondary : root.accent
            opacity: activeDot ? 0.58 + energy * 0.42 : 0.12
            scale: activeDot ? 0.8 + energy * 0.48 : 0.7
        }
    }

    Repeater {
        model: root.resolvedLength === "half" ? 10 : 16

        delegate: Rectangle {
            required property int index
            readonly property int count: root.resolvedLength === "half" ? 10 : 16
            readonly property real angle: Math.PI * 2 * index / count
            readonly property real energy: root.liveAmplitudeAt(index * 3, index * 17)
            readonly property real orbitRadius: Math.min(
                root.visualWidth, root.visualHeight) * 0.42
            readonly property real reach: orbitRadius * (0.72 + energy * 0.28)
            readonly property real dotSize: Math.max(
                5, Math.min(root.visualWidth, root.visualHeight)
                    * 0.08 * root.thicknessScale)

            visible: root.previewEnabled && root.resolvedStyle === "radial_orbit"
            x: root.startX + root.visualWidth / 2
                + Math.cos(angle) * reach - width / 2
            y: root.centerY
                + Math.sin(angle) * reach - height / 2
            width: dotSize
            height: dotSize
            radius: dotSize / 2
            color: index % 3 === 0 ? root.secondary : root.accent
            opacity: 0.42 + energy * 0.58
            scale: 0.62 + energy * 0.82
        }
    }

    Rectangle {
        visible: root.previewEnabled && root.resolvedStyle === "radial_orbit"
        x: root.startX + root.visualWidth / 2 - width / 2
        y: root.centerY - height / 2
        width: Math.min(root.visualWidth, root.visualHeight) * 0.14
        height: width
        radius: width / 2
        color: "#FFFFFF"
        border.width: Math.max(1, 2 * root.thicknessScale)
        border.color: root.accent
        scale: 0.72 + root.liveAmplitudeAt(0, 53) * 0.55
    }

    Repeater {
        model: (root.resolvedLength === "half" ? 12 : 20) * 7

        delegate: Rectangle {
            required property int index
            readonly property int bands: root.resolvedLength === "half" ? 12 : 20
            readonly property int bandIndex: index % bands
            readonly property int segmentIndex: Math.floor(index / bands)
            readonly property real bandStep: root.visualWidth / bands
            readonly property real energy: root.liveAmplitudeAt(bandIndex * 3,
                bandIndex * 17)
            readonly property real segmentHeight: root.visualHeight / (7 * 1.24)

            visible: root.previewEnabled && root.resolvedStyle === "led_spectrum"
            x: root.startX + bandStep * (bandIndex + 0.5) - width / 2
            y: root.centerY + root.visualHeight * 0.5
                - segmentHeight * (segmentIndex + 0.5) * 1.24
            width: Math.max(2, bandStep * 0.58 * root.thicknessScale)
            height: Math.max(2, segmentHeight)
            radius: 2
            color: segmentIndex > 4 ? root.secondary : root.accent
            opacity: energy >= (segmentIndex + 0.45) / 7
                ? 0.56 + energy * 0.44 : 0.08
        }
    }

    Repeater {
        model: root.resolvedLength === "half" ? 10 : 16

        delegate: Item {
            required property int index
            readonly property int count: root.resolvedLength === "half" ? 10 : 16
            readonly property real step: root.visualWidth / count
            readonly property real energy: root.liveAmplitudeAt(index * 2, index * 31)
            readonly property real barHeight: Math.max(3,
                root.visualHeight * (0.06 + energy * 0.94))

            visible: root.previewEnabled && ["octave_bands", "peak_hold"]
                .indexOf(root.resolvedStyle) >= 0
            x: root.startX + step * index
            y: root.centerY - root.visualHeight / 2
            width: step
            height: root.visualHeight

            Rectangle {
                x: (parent.width - width) / 2
                y: parent.height - height
                width: Math.max(3, parent.width * (0.42
                    + parent.index / parent.count * 0.26) * root.thicknessScale)
                height: parent.barHeight
                radius: root.resolvedStyle === "peak_hold" ? 2 : width / 2
                color: parent.index < parent.count * 0.34 ? root.secondary
                    : (parent.index > parent.count * 0.72 ? "#FFFFFF" : root.accent)
                opacity: 0.40 + parent.energy * 0.60
            }

            Rectangle {
                visible: root.resolvedStyle === "peak_hold"
                x: (parent.width - width) / 2
                y: Math.max(0, parent.height - parent.barHeight
                    - parent.height * (0.08 + root.randomAt(parent.index, 91) * 0.22))
                width: Math.max(4, parent.width * 0.62)
                height: Math.max(2, 2.4 * root.thicknessScale)
                radius: height / 2
                color: "#FFFFFF"
            }
        }
    }

    Repeater {
        model: (root.resolvedLength === "half" ? 12 : 20) * 2

        delegate: Rectangle {
            required property int index
            readonly property int bands: root.resolvedLength === "half" ? 12 : 20
            readonly property int bandIndex: index % bands
            readonly property int side: Math.floor(index / bands)
            readonly property real step: root.visualWidth / bands
            readonly property real energy: root.liveAmplitudeAt(bandIndex * 2,
                bandIndex * 43)

            visible: root.previewEnabled
                && root.resolvedStyle === "spectrum_reflection"
            x: root.startX + step * (bandIndex + 0.5) - width / 2
            y: side === 0 ? root.centerY - height : root.centerY + 2
            width: Math.max(2, step * 0.58 * root.thicknessScale)
            height: Math.max(2, root.visualHeight * energy
                * (side === 0 ? 0.58 : 0.34))
            radius: width / 2
            color: bandIndex % 4 === 0 ? root.secondary : root.accent
            opacity: side === 0 ? 0.46 + energy * 0.54
                : 0.08 + energy * 0.30
        }
    }

    Repeater {
        model: root.resolvedLength === "half" ? 16 : 20

        delegate: Rectangle {
            required property int index
            readonly property int count: root.resolvedLength === "half" ? 16 : 20
            readonly property real angle: Math.PI * 2 * index / count - Math.PI / 2
            readonly property real energy: root.liveAmplitudeAt(index * 2, index * 37)
            readonly property real span: Math.min(
                root.visualWidth, root.visualHeight)
            readonly property real ringRadius: span * 0.30
            readonly property bool inward: root.resolvedStyle === "radial_invert"
            readonly property real maxBar: span * 0.26
            readonly property real barHeight: {
                var grown = Math.max(5, maxBar * (0.14 + energy * 0.86))
                return inward ? Math.min(grown, ringRadius * 0.78) : grown
            }
            readonly property real centerDistance: inward
                ? ringRadius - barHeight / 2
                : ringRadius + barHeight / 2
            readonly property real slot: Math.PI * 2 * ringRadius / count
            readonly property real thin: Math.max(2.5,
                Math.min(span * 0.026 * root.thicknessScale, slot * 0.38))

            visible: root.previewEnabled && ["radial_spectrum", "radial_invert"]
                .indexOf(root.resolvedStyle) >= 0
            x: root.startX + root.visualWidth / 2
                + Math.cos(angle) * centerDistance - width / 2
            y: root.centerY + Math.sin(angle) * centerDistance - height / 2
            width: thin
            height: barHeight
            radius: thin * 0.45
            rotation: angle * 180 / Math.PI - 90
            color: index % 3 === 0 ? root.secondary : root.accent
            opacity: 0.47 + energy * 0.53
        }
    }

    Repeater {
        model: (root.resolvedLength === "half" ? 12 : 18) * 6

        delegate: Rectangle {
            required property int index
            readonly property int bands: root.resolvedLength === "half" ? 12 : 18
            readonly property int bandIndex: index % bands
            readonly property int rowIndex: Math.floor(index / bands)
            readonly property real cellWidth: root.visualWidth / bands
            readonly property real rowGap: root.visualHeight / 6
            readonly property real energy: root.liveAmplitudeAt(
                bandIndex * 2 - rowIndex * 3, bandIndex * 47)

            visible: root.previewEnabled && root.resolvedStyle === "waterfall"
            x: root.startX + cellWidth * (bandIndex + 0.5) - width / 2
            y: root.centerY - root.visualHeight / 2
                + rowGap * (rowIndex + 0.5) - height / 2
            width: Math.max(2, cellWidth * 0.82)
            height: Math.max(2, rowGap * 0.70)
            radius: 1
            color: energy > 0.74 ? "#FFFFFF"
                : (rowIndex < 2 ? root.secondary : root.accent)
            opacity: 0.05 + energy * (0.92 - rowIndex * 0.07)
            scale: 0.78 + energy * 0.34
        }
    }

    Repeater {
        model: root.resolvedLength === "half" ? 18 : 30

        delegate: Rectangle {
            required property int index
            readonly property int count: root.resolvedLength === "half" ? 18 : 30
            readonly property real step: root.visualWidth / count
            readonly property real energy: root.liveAmplitudeAt(index * 2, index * 59)
            readonly property real size: Math.max(
                4, root.visualHeight * 0.08 * root.thicknessScale)

            visible: root.previewEnabled && root.resolvedStyle === "particle_spine"
            x: root.startX + step * (index + 0.5) - size / 2
            y: root.centerY + (index % 2 ? -1 : 1)
                * root.visualHeight * energy * 0.42 - size / 2
            width: size
            height: size
            radius: size / 2
            color: index % 4 === 0 ? root.secondary : root.accent
            opacity: 0.28 + energy * 0.72
            scale: 0.55 + energy * 0.82
        }
    }

    Repeater {
        model: root.resolvedLength === "half" ? 18 : 28

        delegate: Rectangle {
            required property int index
            readonly property int count: root.resolvedLength === "half" ? 18 : 28
            readonly property real step: root.visualWidth / count
            readonly property real amplitude: root.liveAmplitudeAt(index, 0)
            readonly property real distance: Math.abs(index - (count - 1) / 2)
                / Math.max(1, count / 2)
            readonly property real bandValue: distance < 0.34
                ? root.liveAmplitudeAt(index, 11)
                : (distance < 0.68 ? root.liveAmplitudeAt(index, 23)
                    : root.liveAmplitudeAt(index, 41))

            visible: root.previewEnabled && [
                "live_equalizer", "mirror_spectrum"
            ].indexOf(root.resolvedStyle) >= 0
            x: root.startX + step * (index + 0.5) - width / 2
            width: Math.max(2, step * (root.resolvedStyle === "mirror_spectrum"
                ? 0.65 : 0.54) * root.thicknessScale)
            height: Math.max(3, root.visualHeight * (0.08
                + (root.resolvedStyle === "mirror_spectrum"
                    ? bandValue : amplitude) * 0.92))
            y: root.resolvedStyle === "live_equalizer"
                ? root.centerY + root.visualHeight / 2 - height
                : root.centerY - height / 2
            radius: root.resolvedStyle === "live_equalizer" ? 2 : width / 2
            color: root.resolvedStyle === "mirror_spectrum" && distance > 0.60
                ? root.secondary : root.accent
            opacity: 0.52 + amplitude * 0.48

            PrimitiveGlow {
                haloColor: parent.color
                sourceWidth: parent.width
                sourceHeight: parent.height
                sourceRadius: parent.radius
                glowAmount: root.glowScale
            }
        }
    }

    Repeater {
        model: root.itemCount - 1

        delegate: Rectangle {
            required property int index
            readonly property real step: root.visualWidth / root.itemCount
            readonly property real valueA: root.liveAmplitudeAt(index, 0)
            readonly property real valueB: root.liveAmplitudeAt(index + 1, 0)
            readonly property real signA: index % 4 < 2 ? -1 : 1
            readonly property real signB: (index + 1) % 4 < 2 ? -1 : 1
            readonly property real xA: root.startX + step * (index + 0.5)
            readonly property real xB: root.startX + step * (index + 1.5)
            readonly property real yA: root.centerY
                + signA * root.visualHeight * (0.08 + valueA * 0.36)
            readonly property real yB: root.centerY
                + signB * root.visualHeight * (0.08 + valueB * 0.36)
            readonly property real dx: xB - xA
            readonly property real dy: yB - yA

            visible: root.previewEnabled && root.resolvedStyle === "oscilloscope"
            x: xA
            y: yA - height / 2
            width: Math.sqrt(dx * dx + dy * dy) + 1
            height: 3 * root.thicknessScale
            radius: height / 2
            rotation: Math.atan2(dy, dx) * 180 / Math.PI
            transformOrigin: Item.Left
            color: root.accent
        }
    }

    Repeater {
        model: 3

        delegate: Item {
            required property int index
            readonly property real energy: root.liveAmplitudeAt(index * 7, index * 19)
            x: root.startX
            y: root.centerY + (index - 1) * root.visualHeight * 0.34
            width: root.visualWidth
            height: Math.max(3, root.visualHeight * 0.16 * root.thicknessScale)
            visible: root.previewEnabled && root.resolvedStyle === "three_band"

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Qt.rgba(root.muted.r, root.muted.g, root.muted.b, 0.18)
            }

            Rectangle {
                width: parent.width * parent.energy
                height: parent.height
                radius: height / 2
                color: parent.index === 0 ? root.secondary
                    : (parent.index === 1 ? root.accent : "#FFFFFF")
            }
        }
    }

    Repeater {
        model: root.resolvedLength === "half" ? 7 : 11

        delegate: Rectangle {
            required property int index
            readonly property int count: root.resolvedLength === "half" ? 7 : 11
            readonly property real step: root.visualWidth / count
            readonly property real transientEnergy: root.liveAmplitudeAt(index, 67)
            readonly property real distance: Math.abs(index - (count - 1) / 2)
            readonly property real wave: Math.max(0,
                1 - distance / (1.2 + transientEnergy * 4.2))
            readonly property real size: Math.max(
                6, root.visualHeight * 0.16 * root.thicknessScale)

            visible: root.previewEnabled && root.resolvedStyle === "beat_pulse"
            x: root.startX + step * (index + 0.5) - size / 2
            y: root.centerY - size / 2
            width: size
            height: size
            radius: size / 2
            color: index === Math.floor(count / 2) ? root.accent
                : Qt.rgba(root.muted.r, root.muted.g, root.muted.b, 0.46)
            border.width: 1
            border.color: root.accent
            opacity: 0.36 + wave * 0.64
            scale: 0.78 + wave * transientEnergy * 1.15
        }
    }

    Repeater {
        model: root.resolvedLength === "half" ? 18 : 28

        delegate: Rectangle {
            required property int index
            readonly property int count: root.resolvedLength === "half" ? 18 : 28
            readonly property real gap: root.visualWidth * 0.006
            readonly property real segmentWidth: Math.max(3,
                (root.visualWidth - gap * (count - 1)) / count)
            readonly property real energy: root.liveAmplitudeAt(0, 5)

            visible: root.previewEnabled && root.resolvedStyle === "voice_meter"
            x: root.startX + index * (segmentWidth + gap)
            y: root.centerY - height / 2
            width: segmentWidth
            height: root.visualHeight * (0.32 + index / count * 0.42)
                * root.thicknessScale
            radius: Math.min(3, width * 0.25)
            color: index < energy * count
                ? (index > count * 0.8 ? root.secondary : root.accent)
                : Qt.rgba(root.muted.r, root.muted.g, root.muted.b, 0.20)
        }
    }

    Rectangle {
        visible: root.previewEnabled && root.resolvedMode === "timeline"
        x: root.startX + root.visualWidth * root.progress - width / 2
        y: root.centerY - height / 2
        width: Math.max(2, root.height * 0.0025)
        height: root.visualHeight * 1.18
        radius: width / 2
        color: "#FFFFFF"
    }

    MouseArea {
        id: waveformDragArea
        objectName: "sequenceWaveformDragArea"
        visible: root.previewEnabled && root.interactive
        x: Math.max(0, root.startX - 10)
        y: Math.max(0, root.centerY - Math.max(18, root.visualHeight * 0.8))
        width: Math.min(root.width - x, root.visualWidth + 20)
        height: Math.min(root.height - y, Math.max(36, root.visualHeight * 1.6))
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        hoverEnabled: true

        function normalizedPosition(mouse) {
            var rootPoint = mapToItem(root, mouse.x, mouse.y)
            var half = root.widthRatio / 2
            return Qt.point(
                Math.max(half, Math.min(1 - half, rootPoint.x / root.width)),
                Math.max(0.03, Math.min(0.97, rootPoint.y / root.height)))
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
