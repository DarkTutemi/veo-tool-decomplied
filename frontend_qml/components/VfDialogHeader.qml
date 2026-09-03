import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"
import "AppIconRegistry.js" as AppIconRegistry

// Standard dialog header: white bar, bottom border, optional leading SVG icon,
// title, and a close button with tooltip. Use as a Dialog's `header:`.
Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string iconName: ""
    property bool showClose: true
    property bool compact: false

    signal closeClicked()

    function cleanText(value) {
        var text = String(value || "").trim()
        text = text.replace(/^[\uD800-\uDBFF][\uDC00-\uDFFF]️?\s*/, "")
        text = text.replace(/^[☀-➿]️?\s*/, "")
        return text.trim()
    }

    implicitHeight: VfTheme.dp(subtitle.length > 0 ? (compact ? 52 : 60) : (compact ? 42 : 50))
    color: VfTheme.surface
    radius: VfTheme.dp(12)

    // Square off the bottom corners so the rounded top meets the body cleanly.
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: VfTheme.dp(12)
        color: VfTheme.surface
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: VfTheme.border
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.compact ? VfTheme.dp(12) : VfTheme.dp(16)
        anchors.rightMargin: VfTheme.dp(8)
        spacing: root.compact ? VfTheme.dp(8) : VfTheme.dp(10)

        VfAppIcon {
            name: root.iconName
            size: root.compact ? VfTheme.dp(16) : VfTheme.dp(18)
            framed: false
            visible: name.length > 0
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.cleanText(root.title)
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: root.compact ? VfTheme.dp(14) : VfTheme.dp(15)
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                elide: Text.ElideRight
            }
        }

        Rectangle {
            visible: root.showClose
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: root.compact ? VfTheme.dp(28) : VfTheme.dp(32)
            Layout.preferredHeight: root.compact ? VfTheme.dp(28) : VfTheme.dp(32)
            radius: VfTheme.dp(8)
            color: closeMouse.containsMouse ? VfTheme.redFill : "transparent"

            VfAppIcon {
                anchors.centerIn: parent
                name: "cross-mark"
                size: root.compact ? VfTheme.dp(14) : VfTheme.dp(16)
                framed: false
                color: closeMouse.containsMouse ? "#DC2626" : VfTheme.textMuted
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.closeClicked()
            }

            ToolTip.visible: closeMouse.containsMouse
            ToolTip.text: (void i18n.revision, i18n.t("common.close", "Close"))
            ToolTip.delay: 350
        }
    }
}
