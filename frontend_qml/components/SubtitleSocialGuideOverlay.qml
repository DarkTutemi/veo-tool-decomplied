pragma ComponentBehavior: Bound

import QtQuick

import "../theme"

Item {
    id: root

    required property var guide
    property bool maskMode: false

    readonly property string guideId: String(guide.id || "")
    readonly property string kind: String(guide.kind || "")
    readonly property string guideLabel: String(guide.label || "")
    readonly property string coordinateLabel: String(guide.coordinate_label || "")
    readonly property bool isDanger: kind === "action_rail"
        || kind === "cta"
        || kind === "caption"
    readonly property color accent: isDanger ? "#FB7185" : "#F59E0B"

    objectName: "subtitleSocialGuide_" + guideId
    x: parent.width * Number(guide.left || 0)
    y: parent.height * Number(guide.top || 0)
    width: parent.width * Math.max(0, Number(guide.right || 1) - Number(guide.left || 0))
    height: parent.height * Math.max(0, Number(guide.bottom || 1) - Number(guide.top || 0))
    Accessible.ignored: true

    Rectangle {
        anchors.fill: parent
        visible: root.maskMode
        radius: String(root.guide.shape || "rect") === "pill"
            ? height / 2
            : VfTheme.dp(4)
        color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.18)
        border.width: Math.max(1, VfTheme.dp(1))
        border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.88)

        Text {
            anchors.centerIn: parent
            width: Math.max(0, parent.width - VfTheme.dp(10))
            visible: parent.height >= VfTheme.dp(22)
                && parent.width >= VfTheme.dp(54)
            text: root.guideLabel
            color: "#FFFFFF"
            font.family: VfTheme.fontFamily
            font.pixelSize: Math.max(VfTheme.dp(7), Math.min(VfTheme.fontTiny,
                parent.height * 0.18))
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            style: Text.Outline
            styleColor: "#99000000"
        }
    }
}
