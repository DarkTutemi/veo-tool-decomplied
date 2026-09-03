pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../.."

ComboBox {
    id: root
    implicitHeight: Theme.controlHeight
    implicitWidth: 116
    activeFocusOnTab: true
    Accessible.role: Accessible.ComboBox
    Accessible.name: "Lựa chọn " + displayText

    contentItem: Text {
        leftPadding: 10
        rightPadding: 24
        text: root.displayText
        color: root.enabled ? Theme.textMuted : Theme.textFaint
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font.pixelSize: Theme.fontBody
    }
    indicator: UiIcon {
        x: root.width - width - 8
        anchors.verticalCenter: parent.verticalCenter
        name: "ui/chevron-down"
        tone: Theme.textFaint
        iconSize: 14
    }
    background: Rectangle {
        radius: Theme.radiusMedium
        color: Theme.elevated
        border.width: 1
        border.color: root.activeFocus ? Theme.accent : Theme.borderSoft
    }
    delegate: ItemDelegate {
        id: option
        required property var model
        required property int index
        property var modelData: undefined
        width: ListView.view ? ListView.view.width : root.width
        height: Theme.controlHeight
        highlighted: root.highlightedIndex === option.index
        activeFocusOnTab: true
        Accessible.role: Accessible.ListItem
        Accessible.name: optionText.text
        contentItem: Row {
            spacing: 7
            UiIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: "ui/chevron-right"
                tone: Theme.accent
                iconSize: 12
                visible: root.currentIndex === option.index
                width: 12
            }
            Text {
                id: optionText
                width: parent.width - 19
                anchors.verticalCenter: parent.verticalCenter
                text: root.textRole
                    ? String(option.model[root.textRole] || "")
                    : String(option.modelData === undefined ? option.model : option.modelData)
                color: option.enabled ? Theme.text : Theme.textFaint
                font.pixelSize: Theme.fontBody
                elide: Text.ElideRight
            }
        }
        background: Rectangle {
            radius: 5
            color: option.highlighted ? Theme.accentSoft
                : option.hovered ? Theme.hover : "transparent"
        }
    }
    popup: Popup {
        y: root.height + 4
        width: root.width
        implicitHeight: Math.min(contentItem.implicitHeight + 8, 260)
        padding: 4
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: root.delegateModel
            currentIndex: root.highlightedIndex
        }
        background: Rectangle {
            radius: Theme.radiusMedium
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }
}
