import QtQuick
import QtQuick.Controls.impl
import ".."

Item {
    id: root

    property string name: ""
    property color tone: Theme.textMuted
    property int iconSize: 18
    property bool preserveColors: false
    readonly property bool sourceReady: root.name.length === 0
        || sourceIcon.status === Image.Ready
    readonly property url sourceUrl: root.name.length > 0
        ? Qt.resolvedUrl("../assets/icons/" + root.name + ".svg") : ""

    implicitWidth: root.iconSize
    implicitHeight: root.iconSize

    IconImage {
        id: sourceIcon
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        source: root.sourceUrl
        color: root.preserveColors ? "transparent" : root.tone
        sourceSize.width: Math.max(24, root.iconSize * 2)
        sourceSize.height: Math.max(24, root.iconSize * 2)
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        asynchronous: false
    }
}
