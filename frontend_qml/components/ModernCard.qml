import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string title: ""
    property string icon: ""
    property string featureId: ""
    property string iconName: ""
    property string cardType: "secondary"
    property bool required: false
    property color accent: VfTheme.primary
    default property alias content: body.data

    Layout.fillWidth: true
    implicitHeight: cardLayout.implicitHeight + 32
    radius: VfTheme.dp(8)
    color: VfTheme.surface
    border.width: 1
    border.color: VfTheme.border
    clip: true

    Rectangle {
        visible: root.cardType === "primary"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: VfTheme.dp(4)
        color: root.accent
    }

    ColumnLayout {
        id: cardLayout
        anchors.fill: parent
        anchors.margins: VfTheme.dp(16)
        spacing: VfTheme.dp(12)

        RowLayout {
            visible: root.title.length > 0 || root.icon.length > 0 || root.featureId.length > 0 || root.iconName.length > 0 || root.required
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            VfAppIcon {
                visible: root.featureId.length > 0 || root.iconName.length > 0
                featureId: root.featureId
                name: root.iconName
                size: VfTheme.dp(24)
                framed: true
                Layout.preferredWidth: VfTheme.dp(24)
                Layout.preferredHeight: VfTheme.dp(24)
            }

            Text {
                Layout.fillWidth: true
                visible: root.title.length > 0
                text: root.title
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                font.weight: VfTheme.weightStrong
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                visible: root.required
                implicitWidth: requiredLabel.implicitWidth + 16
                implicitHeight: requiredLabel.implicitHeight + 4
                radius: VfTheme.dp(4)
                color: VfTheme.amberFill

                Text {
                    id: requiredLabel
                    anchors.centerIn: parent
                    text: (void i18n.revision, i18n.t("common.required", "Required"))
                    color: VfTheme.amberText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    font.weight: VfTheme.weightControl
                }
            }
        }

        ColumnLayout {
            id: body
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)
        }
    }
}
