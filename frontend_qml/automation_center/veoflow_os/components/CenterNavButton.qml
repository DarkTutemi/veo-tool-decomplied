import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Button {
    id: root
    property string iconName: ""
    property int badgeCount: 0
    property color iconTone: checked ? CenterTokens.primary : CenterTokens.muted
    checkable: true
    autoExclusive: true
    implicitHeight: CenterTokens.navHeight
    implicitWidth: Math.max(112, row.implicitWidth + 30)
    hoverEnabled: true
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: text

    contentItem: RowLayout {
        id: row
        spacing: 8
        UiIcon {
            name: root.iconName
            tone: root.iconTone
            iconSize: 17
            Layout.preferredWidth: 17
            Layout.preferredHeight: 17
        }
        Text {
            text: root.text
            color: root.checked ? CenterTokens.primary : CenterTokens.muted
            font.family: CenterTokens.fontFamily
            font.pixelSize: CenterTokens.navLabel
            font.weight: root.checked ? Font.DemiBold : Font.Medium
            elide: Text.ElideRight
        }
        Rectangle {
            visible: root.badgeCount > 0
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            radius: 9
            color: CenterTokens.danger
            Text {
                anchors.centerIn: parent
                text: String(Math.min(99, root.badgeCount))
                color: "white"
                font.family: CenterTokens.fontFamily
                font.pixelSize: 10
                font.weight: Font.Bold
            }
        }
    }

    background: Item {
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 2
            color: CenterTokens.primary
            visible: root.checked
        }
        Rectangle {
            anchors.fill: parent
            color: root.hovered && !root.checked ? CenterTokens.panelSoft : "transparent"
            opacity: 0.8
        }
    }
}

