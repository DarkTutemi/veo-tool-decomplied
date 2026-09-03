import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string titleLeadingIcon: ""
    property color accent: "transparent"
    property bool dense: false
    property bool showFrame: true
    default property alias content: body.data

    function cleanText(value) {
        var text = String(value || "").trim()
        text = text.replace(/^[\uD800-\uDBFF][\uDC00-\uDFFF]\uFE0F?\s*/, "")
        text = text.replace(/^[\u2600-\u27BF]\uFE0F?\s*/, "")
        return text.trim()
    }

    radius: VfTheme.radiusPanel
    color: VfTheme.surface
    border.color: root.showFrame ? VfTheme.borderBox : "transparent"
    border.width: root.showFrame ? 1 : 0
    clip: true

    implicitHeight: panelLayout.implicitHeight + (root.dense ? 18 : 24)

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 0
        visible: false
    }

    ColumnLayout {
        id: panelLayout
        anchors.fill: parent
        anchors.margins: root.dense ? 8 : 10
        spacing: root.dense ? 6 : 8

        ColumnLayout {
            visible: root.title.length > 0 || root.subtitle.length > 0
            spacing: VfTheme.dp(2)
            Layout.fillWidth: true

            Row {
                spacing: VfTheme.dp(5)
                visible: root.title.length > 0

                VfAppIcon {
                    name: root.titleLeadingIcon
                    size: root.dense ? VfTheme.dp(13) : VfTheme.dp(14)
                    framed: false
                    color: VfTheme.text
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.titleLeadingIcon.length > 0
                }

                Text {
                    text: root.cleanText(root.title)
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: root.dense ? VfTheme.fontSection : 14
                    font.weight: VfTheme.weightTitle
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                text: root.subtitle
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                visible: root.subtitle.length > 0
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            id: body
            Layout.fillWidth: true
            // Fill remaining panel height so fillHeight children (e.g. queue
            // ListView) can expand instead of collapsing to implicit height.
            Layout.fillHeight: true
            spacing: root.dense ? 6 : 8
        }
    }
}
