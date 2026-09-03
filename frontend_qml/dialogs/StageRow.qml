import QtQuick
import QtQuick.Layouts

import "../theme"

Item {
    id: root

    property string name: ""
    property string description: ""
    property string state: "pending"
    property string detail: ""
    property int progress: -1

    Layout.fillWidth: true
    implicitHeight: body.implicitHeight

    function stateColor(value) {
        var normalized = String(value || "pending")
        if (normalized === "running")
            return "#7C3AED"
        if (normalized === "ok")
            return "#059669"
        if (normalized === "warn")
            return "#D97706"
        if (normalized === "error")
            return "#DC2626"
        if (normalized === "skip")
            return VfTheme.textSubtle
        return VfTheme.borderStrong
    }

    function stateFill(value) {
        var normalized = String(value || "pending")
        if (normalized === "running")
            return VfTheme.violetFill
        if (normalized === "ok")
            return VfTheme.greenFill
        if (normalized === "warn")
            return VfTheme.amberFill
        if (normalized === "error")
            return VfTheme.redFill
        return VfTheme.surfaceSoft
    }

    ColumnLayout {
        id: body
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: VfTheme.dp(6)

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(10)

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(14)
                Layout.preferredHeight: VfTheme.dp(14)
                radius: VfTheme.dp(7)
                color: root.stateColor(root.state)
                opacity: root.state === "pending" ? 0.55 : 1.0

                SequentialAnimation on opacity {
                    running: root.state === "running"
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.45; duration: 520 }
                    NumberAnimation { to: 1.0; duration: 520 }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: root.name
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root.detail || root.description
                    color: root.state === "pending" ? VfTheme.textSubtle : root.stateColor(root.state)
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(78)
                Layout.preferredHeight: VfTheme.dp(20)
                radius: VfTheme.dp(10)
                color: root.stateFill(root.state)
                border.color: Qt.rgba(0, 0, 0, 0)

                Text {
                    anchors.centerIn: parent
                    text: String(root.state || "pending").toUpperCase()
                    color: root.stateColor(root.state)
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                    font.weight: VfTheme.weightStrong
                }
            }
        }

        ModernProgressBar {
            Layout.leftMargin: 24
            Layout.preferredHeight: VfTheme.dp(6)
            visible: root.progress >= 0
            value: Math.max(0, Math.min(100, root.progress))
            maximum: 100
        }
    }
}
