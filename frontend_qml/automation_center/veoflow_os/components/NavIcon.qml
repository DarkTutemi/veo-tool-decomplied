import QtQuick
import QtQuick.Controls.impl
import ".."

Item {
    id: root
    property string name: "dashboard"
    property bool active: false
    readonly property string renderMode: "direct-tinted-svg"
    readonly property bool sourceReady: sourceIcon.status === Image.Ready

    implicitWidth: 20
    implicitHeight: 20

    IconImage {
        id: sourceIcon
        anchors.fill: parent
        source: Qt.resolvedUrl("../assets/navigation/" + root.name + ".svg")
        color: root.active ? Theme.accent : Theme.textFaint
        sourceSize.width: 48
        sourceSize.height: 48
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        asynchronous: false
    }
}
