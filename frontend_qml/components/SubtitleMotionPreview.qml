pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    default property alias contentData: content.data
    property string motion: "static"
    property string effect: ""
    property real playhead: 0.0
    property real strength: 1.0
    property real canvasWidth: width
    property real canvasHeight: height
    property bool motionEnabled: true

    readonly property real phase: Math.max(0.0, Math.min(1.0, playhead))
    readonly property real entrance: Math.min(1.0, phase / 0.14)
    readonly property real easedEntrance: 1.0 - Math.pow(1.0 - entrance, 3.0)
    readonly property string effectName: String(effect || "")
    readonly property real previewScale: {
        if (!motionEnabled)
            return 1.0
        if (effectName === "impact_slam") {
            if (phase < 0.065)
                return 0.58 + 0.64 * phase / 0.065
            if (phase < 0.14)
                return 1.22 - 0.22 * (phase - 0.065) / 0.075
        } else if (effectName === "sticker_bounce") {
            if (phase < 0.07)
                return 0.78 + 0.37 * phase / 0.07
            if (phase < 0.16)
                return 1.15 - 0.15 * (phase - 0.07) / 0.09
        } else if (effectName === "neon_flicker") {
            if (phase < 0.04)
                return 0.94
            if (phase < 0.08)
                return 1.06
            if (phase < 0.14)
                return 0.98 + 0.02 * (phase - 0.08) / 0.06
        } else if (effectName === "cinematic_reveal") {
            return phase < 0.28 ? 1.06 - 0.06 * phase / 0.28 : 1.0
        } else if (effectName === "keyword_pulse") {
            if (phase < 0.08)
                return 0.92 + 0.14 * phase / 0.08
            if (phase < 0.18)
                return 1.06 - 0.06 * (phase - 0.08) / 0.10
        } else if (effectName === "comic_wobble") {
            if (phase < 0.07)
                return 0.70 + 0.46 * phase / 0.07
            if (phase < 0.18)
                return 1.16 - 0.16 * (phase - 0.07) / 0.11
        } else if (motion === "pop") {
            if (phase < 0.075)
                return 0.76 + 0.32 * phase / 0.075
            if (phase < 0.14)
                return 1.08 - 0.08 * (phase - 0.075) / 0.065
        } else if (motion === "bounce") {
            if (phase < 0.07)
                return 0.88 + 0.24 * phase / 0.07
            if (phase < 0.16)
                return 1.12 - 0.12 * (phase - 0.07) / 0.09
        } else if (motion === "pulse") {
            if (phase < 0.09)
                return 0.96 + 0.09 * phase / 0.09
            if (phase < 0.18)
                return 1.05 - 0.05 * (phase - 0.09) / 0.09
        } else if (motion === "wave") {
            if (phase < 0.09)
                return 0.96 + 0.08 * phase / 0.09
            if (phase < 0.18)
                return 1.04 - 0.04 * (phase - 0.09) / 0.09
        }
        return 1.0
    }
    readonly property real previewOpacity: {
        if (!motionEnabled || motion === "static")
            return 1.0
        if (effectName === "neon_flicker" && phase < 0.12)
            return phase < 0.035 ? 0.28 : (phase < 0.07 ? 1.0 : 0.62)
        var slowFade = effectName === "cinematic_reveal"
            || effectName === "documentary_dissolve"
            || effectName === "bilingual_stack"
            || effectName === "learning_focus"
        var enter = slowFade ? Math.min(1.0, phase / 0.20) : (motion === "fade"
            ? Math.min(1.0, phase / 0.08)
            : Math.min(1.0, phase / 0.035))
        var leave = Math.min(1.0, (1.0 - phase) / 0.055)
        return Math.max(0.0, Math.min(enter, leave))
    }
    readonly property real previewRotation: {
        if (!motionEnabled)
            return 0.0
        if (effectName === "sticker_bounce")
            return phase < 0.16 ? -4.0 + 4.0 * Math.min(1.0, phase / 0.16) : 0.0
        if (effectName === "comic_wobble") {
            if (phase < 0.07)
                return -6.0 + 10.0 * phase / 0.07
            if (phase < 0.18)
                return 4.0 - 4.0 * (phase - 0.07) / 0.11
            return 0.0
        }
        if (motion !== "wave")
            return 0.0
        if (phase < 0.09)
            return -1.8 + 3.2 * phase / 0.09
        if (phase < 0.18)
            return 1.4 - 1.4 * (phase - 0.09) / 0.09
        return 0.0
    }
    readonly property real previewOffsetX: {
        if (!motionEnabled)
            return 0.0
        if (effectName === "news_snap")
            return canvasWidth * 0.18 * strength * (1.0 - easedEntrance)
        if (effectName === "speed_streak")
            return -canvasWidth * 0.22 * strength * (1.0 - easedEntrance)
        if (effectName === "lower_third_wipe" || motion === "slide_left")
            return -canvasWidth * 0.10 * strength * (1.0 - easedEntrance)
        return 0.0
    }
    readonly property real previewOffsetY: {
        if (!motionEnabled)
            return 0.0
        if (effectName === "quote_drift")
            return canvasHeight * 0.018 * strength * (1.0 - easedEntrance)
        if (effectName === "glass_rise" || motion === "slide_up")
            return canvasHeight * 0.045 * strength * (1.0 - easedEntrance)
        return 0.0
    }

    scale: previewScale
    opacity: previewOpacity
    rotation: previewRotation
    transformOrigin: Item.Center
    transform: Translate {
        x: root.previewOffsetX
        y: root.previewOffsetY
    }

    Item {
        id: content
        anchors.fill: parent
    }
}
