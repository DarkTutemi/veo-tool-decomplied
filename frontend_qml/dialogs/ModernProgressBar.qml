import QtQuick
import QtQuick.Layouts

import "../theme"

Item {
    id: root

    property int value: 0
    property int maximum: 100
    property bool showText: false

    Layout.fillWidth: true
    implicitHeight: root.showText ? 18 : 4

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: VfTheme.border
        clip: true

        Rectangle {
            height: parent.height
            width: parent.width * Math.max(0, Math.min(1, root.maximum <= 0 ? 0 : root.value / root.maximum))
            radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#4F46E5" }
                GradientStop { position: 1.0; color: "#A855F7" }
            }

            Behavior on width {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: root.showText
        text: String(Math.round(root.value)) + "%"
        color: "#FFFFFF"
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontTiny
        font.weight: VfTheme.weightStrong
    }
}
