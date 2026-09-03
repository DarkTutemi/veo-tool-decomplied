import QtQuick
import QtQuick.Controls.impl

import "AppIconRegistry.js" as AppIconRegistry
import "../theme"

Item {
    id: root

    property string featureId: ""
    property string route: ""
    property string name: ""
    property int size: 40
    property bool framed: false
    property color frameColor: VfTheme.surface
    // Tint applied to the line icon. Defaults to the icon's semantic color
    // (falls back to neutral muted text); callers can override with a state color.
    property color color: AppIconRegistry.iconColor(resolvedName) || VfTheme.textMuted

    readonly property string resolvedName: AppIconRegistry.resolveFeatureIcon(featureId, route, name)

    implicitWidth: size
    implicitHeight: size
    width: size
    height: size
    visible: resolvedName.length > 0

    Rectangle {
        anchors.fill: parent
        visible: root.framed
        radius: Math.max(8, Math.round(root.size * 0.24))
        color: root.frameColor
        border.color: VfTheme.border
    }

    // IconImage (QtQuick.Controls.impl) recolors the monochrome line SVG natively: it
    // feeds `color` into the SVG's `currentColor`, so the strokes render directly in the
    // tint. Flat replace like the old ColorOverlay, but with NO ShaderEffectSource — the
    // thing that raced/crashed the threaded render loop (the +0x3fa03 AV). MultiEffect was
    // wrong here: its `colorization` multiplies the tint by source luminance, so the black
    // `currentColor` strokes (luminance 0) came out black regardless of the tint.
    IconImage {
        id: glyph
        anchors.centerIn: parent
        width: root.framed ? Math.round(root.size * 0.74) : root.size
        height: width
        source: root.resolvedName.length > 0
            ? Qt.resolvedUrl("../../resources/icons/app/line/" + root.resolvedName + ".svg")
            : ""
        sourceSize.width: Math.round(width * 2)
        sourceSize.height: Math.round(height * 2)
        color: root.color
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        cache: true
        // Keep the node in the scene graph. Toggling visible with Image.Ready
        // add/removes the texture while the threaded render loop is painting
        // (Qt6Qml +0x3fa03 AV, same class as the old ColorOverlay race).
        opacity: glyph.status === Image.Ready ? 1 : 0
    }
}
