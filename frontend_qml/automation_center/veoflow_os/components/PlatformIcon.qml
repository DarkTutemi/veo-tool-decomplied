import QtQuick

Item {
    id: root

    property string platform: "generic"
    property int iconSize: 18
    readonly property bool sourceReady: sourceIcon.status === Image.Ready

    implicitWidth: root.iconSize
    implicitHeight: root.iconSize

    SocialIcon {
        id: sourceIcon
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        platform: root.platform
    }
}
