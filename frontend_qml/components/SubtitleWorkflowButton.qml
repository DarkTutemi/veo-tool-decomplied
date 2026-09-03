pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "."
import "../theme"

Rectangle {
    id: root
    objectName: "subtitleWorkflowButton"
    property var profile: ({})
    property string configuredLanguage: "vi"
    property string actionId: ""
    property real minWidth: VfTheme.dp(166)
    property real controlHeight: VfTheme.dp(38)
    readonly property bool subtitleEnabled: Boolean((profile || {}).enabled)
    readonly property var caption: (profile || {}).caption || ({})
    readonly property var overlay: (profile || {}).overlay || ({})
    signal clicked()

    implicitWidth: minWidth
    implicitHeight: controlHeight
    radius: VfTheme.dp(8)
    color: subtitleEnabled ? VfTheme.cyanFill : VfTheme.surface
    border.width: 1
    border.color: subtitleEnabled ? VfTheme.cyan : VfTheme.borderStrong

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: VfTheme.dp(9)
        anchors.rightMargin: VfTheme.dp(8)
        spacing: VfTheme.dp(7)

        VfAppIcon {
            name: "memo"
            size: VfTheme.dp(16)
            framed: false
            color: root.subtitleEnabled ? VfTheme.cyan : VfTheme.textMuted
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: "PHỤ ĐỀ · " + (root.subtitleEnabled ? "BẬT" : "TẮT")
                color: root.subtitleEnabled ? VfTheme.text : VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(8.5)
                font.weight: Font.Bold
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: {
                    var mode = String(root.caption.mode || "subtitle")
                    var captionLabel = mode === "bilingual"
                        ? qsTr("Song ngữ")
                        : (mode === "auto" ? qsTr("Tự động") : qsTr("Đơn ngữ"))
                    return Boolean(root.overlay.enabled)
                        ? captionLabel + " · " + qsTr("Từ + phiên âm")
                        : captionLabel
                }
                color: root.subtitleEnabled ? VfTheme.cyanText : VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(7)
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(7)
            Layout.preferredHeight: width
            radius: width / 2
            color: root.subtitleEnabled ? VfTheme.greenBorder : VfTheme.textSubtle
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Accessible.role: Accessible.Button
    Accessible.name: "Phụ đề " + (subtitleEnabled ? "đang bật" : "đang tắt")
}
