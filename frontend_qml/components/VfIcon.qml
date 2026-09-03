import QtQuick

import "IconRegistry.js" as IconRegistry

Item {
    id: root

    property string name: ""
    property string variant: "dark"
    property int size: 16
    property real imageOpacity: enabled ? 1.0 : 0.45

    readonly property string effectiveName: IconRegistry.normalizeIconName(name)
    readonly property string effectiveVariant: variant === "light" ? "light" : "dark"

    implicitWidth: size
    implicitHeight: size
    width: size
    height: size
    visible: effectiveName.length > 0

    Image {
        anchors.fill: parent
        source: root.effectiveName.length > 0
            ? Qt.resolvedUrl("../../resources/icons/lucide/" + root.effectiveVariant + "/" + root.effectiveName + ".svg")
            : ""
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        opacity: root.imageOpacity
        asynchronous: false
        cache: true
    }
}
