import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root
    property string text: ""
    property string status: "neutral"
    property string iconName: ""
    readonly property color tone: {
        switch (root.status) {
        case "success": return CenterTokens.success
        case "warning": return CenterTokens.warning
        case "danger": return CenterTokens.danger
        case "info": return CenterTokens.primary
        case "violet": return CenterTokens.violet
        default: return CenterTokens.muted
        }
    }
    readonly property color fill: {
        switch (root.status) {
        case "success": return CenterTokens.successSoft
        case "warning": return CenterTokens.warningSoft
        case "danger": return CenterTokens.dangerSoft
        case "info": return CenterTokens.primarySoft
        case "violet": return CenterTokens.violetSoft
        default: return CenterTokens.panelSoft
        }
    }

    implicitWidth: content.implicitWidth + 16
    implicitHeight: 24
    radius: 6
    color: root.fill
    border.width: 1
    border.color: Qt.rgba(root.tone.r, root.tone.g, root.tone.b, 0.28)
    Accessible.role: Accessible.StaticText
    Accessible.name: root.text

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 5
        UiIcon {
            visible: root.iconName.length > 0
            name: root.iconName
            tone: root.tone
            iconSize: 13
            Layout.preferredWidth: visible ? 13 : 0
            Layout.preferredHeight: 13
        }
        Rectangle {
            visible: root.iconName.length === 0
            Layout.preferredWidth: 6
            Layout.preferredHeight: 6
            radius: 3
            color: root.tone
        }
        Text {
            text: root.text
            color: root.tone
            font.family: CenterTokens.fontFamily
            font.pixelSize: CenterTokens.metadata + 1
            font.weight: Font.DemiBold
        }
    }
}

