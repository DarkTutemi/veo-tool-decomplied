import QtQuick
import ".."

Item {
    id: root
    objectName: "progressMeter"
    property real value: 0
    property color tone: Theme.accent
    property bool indeterminate: false
    implicitWidth: 140
    implicitHeight: 8
    Accessible.name: indeterminate ? "Đang xử lý" : "Tiến độ " + Math.round(clamped * 100) + "%"
    Accessible.role: Accessible.ProgressBar
    readonly property real clamped: Math.max(0, Math.min(1, value))

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.elevated
    }
    Rectangle {
        id: bar
        height: parent.height
        width: root.indeterminate ? Math.max(28, parent.width * 0.28) : parent.width * root.clamped
        radius: height / 2
        color: root.tone
        x: 0

        Behavior on width {
            enabled: !root.indeterminate
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        SequentialAnimation on x {
            running: root.indeterminate && root.visible
            loops: Animation.Infinite
            NumberAnimation { from: 0; to: Math.max(0, root.width - bar.width); duration: 850; easing.type: Easing.InOutQuad }
            NumberAnimation { from: Math.max(0, root.width - bar.width); to: 0; duration: 850; easing.type: Easing.InOutQuad }
        }
    }
}
