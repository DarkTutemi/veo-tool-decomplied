import QtQuick
import ".."

Rectangle {
    id: root
    objectName: "skeleton"
    property bool running: visible
    implicitWidth: 160
    implicitHeight: 14
    radius: Math.min(6, height / 2)
    color: Theme.elevated
    opacity: 0.45
    Accessible.ignored: true

    SequentialAnimation on opacity {
        running: root.running
        loops: Animation.Infinite
        NumberAnimation { to: 0.85; duration: 720; easing.type: Easing.InOutQuad }
        NumberAnimation { to: 0.38; duration: 720; easing.type: Easing.InOutQuad }
    }
}
