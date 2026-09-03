import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root
    objectName: "statusPill"
    property string text: ""
    property color tone: Theme.textMuted
    property color fill: Qt.rgba(tone.r, tone.g, tone.b, 0.14)
    property bool showDot: true
    property bool pulse: false
    property string iconName: ""
    property bool preserveIconColors: false
    readonly property bool iconReady: root.iconName.length === 0
        || statusIcon.sourceReady

    implicitWidth: row.implicitWidth + 18
    implicitHeight: 26
    radius: height / 2
    color: fill
    border.width: 1
    border.color: Qt.rgba(tone.r, tone.g, tone.b, 0.34)
    Accessible.name: text
    Accessible.role: Accessible.StaticText

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Rectangle {
            id: dot
            visible: root.showDot && root.iconName.length === 0
            Layout.preferredWidth: 6
            Layout.preferredHeight: 6
            Layout.alignment: Qt.AlignVCenter
            radius: 3
            color: root.tone

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: root.pulse && root.visible
                NumberAnimation { to: 0.35; duration: 1000; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
            }
        }

        UiIcon {
            id: statusIcon
            objectName: root.objectName.length > 0
                ? root.objectName + "Icon" : ""
            visible: root.iconName.length > 0
            name: root.iconName
            tone: root.tone
            preserveColors: root.preserveIconColors
            iconSize: 13
            Layout.preferredWidth: visible ? 13 : 0
            Layout.preferredHeight: 13
        }

        Text {
            text: root.text
            color: root.tone
            font.pixelSize: 11
            font.weight: Font.DemiBold
        }
    }
}
