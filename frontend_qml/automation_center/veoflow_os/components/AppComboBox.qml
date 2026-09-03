pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

ComboBox {
    id: control
    objectName: "appComboBox"

    property bool polishedDarkDropdown: true
    property int popupMaximumHeight: 288
    property string availabilityReason: ""
    readonly property bool displayTextTruncated: displayLabel.truncated
    readonly property real displayTextWidth: displayLabel.width
    readonly property real displayTextImplicitWidth: displayLabel.implicitWidth

    implicitHeight: Theme.controlHeight
    leftPadding: 12
    rightPadding: 34
    font.pixelSize: Theme.fontBody
    activeFocusOnTab: true
    hoverEnabled: true
    Accessible.role: Accessible.ComboBox
    Accessible.name: control.displayText
    Accessible.description: control.enabled
        ? "Dùng phím mũi tên để chọn, Enter để xác nhận"
        : control.availabilityReason

    contentItem: Text {
        id: displayLabel
        objectName: control.objectName + "Label"
        text: control.displayText
        color: control.enabled ? Theme.textMuted : Theme.textFaint
        font: control.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: UiIcon {
        objectName: control.objectName + "Chevron"
        x: control.width - width - 10
        y: control.topPadding + (control.availableHeight - height) / 2
        name: "ui/chevron-down"
        tone: control.activeFocus || control.down ? Theme.text : Theme.textFaint
        iconSize: 14
        rotation: control.down ? 180 : 0
        Behavior on rotation { NumberAnimation { duration: 110 } }
    }

    background: Rectangle {
        objectName: control.objectName + "Surface"
        radius: Theme.radiusSmall
        color: control.down ? Theme.accentSoft
            : (control.hovered ? Theme.hover : Theme.elevated)
        border.width: 1
        border.color: control.activeFocus ? Theme.accent
            : (control.hovered ? Theme.border : Theme.borderSoft)
    }

    delegate: ItemDelegate {
        id: option
        required property int index
        readonly property bool currentOption: option.index === control.currentIndex

        objectName: control.objectName + "Option_" + String(option.index)
        width: control.popup.width - control.popup.leftPadding - control.popup.rightPadding
        implicitHeight: Theme.controlHeight
        leftPadding: 10
        rightPadding: 10
        hoverEnabled: true
        highlighted: control.highlightedIndex === option.index
        Accessible.role: Accessible.MenuItem
        Accessible.name: control.textAt(option.index)
        Accessible.description: option.currentOption ? "Đang chọn" : "Chưa chọn"

        contentItem: RowLayout {
            spacing: Theme.space2
            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                text: control.textAt(option.index)
                color: option.currentOption || option.highlighted
                    ? Theme.text : Theme.textMuted
                font.pixelSize: Theme.fontBody
                font.weight: option.currentOption ? Font.DemiBold : Font.Normal
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            UiIcon {
                objectName: control.objectName + "OptionCheck_" + String(option.index)
                visible: option.currentOption
                name: "semantic/check-circle"
                tone: Theme.success
                iconSize: 14
                Layout.preferredWidth: visible ? 14 : 0
                Layout.preferredHeight: 14
            }
        }

        background: Rectangle {
            radius: Theme.radiusSmall
            color: option.currentOption ? Theme.accentSoft
                : (option.highlighted || option.hovered ? Theme.hover : "transparent")
            border.width: option.currentOption ? 1 : 0
            border.color: option.currentOption ? Theme.accent : "transparent"
        }
    }

    popup: Popup {
        id: dropdownPopup
        objectName: control.objectName + "Popup"
        y: control.height + Theme.space1
        width: control.width
        implicitHeight: Math.min(
            contentItem.implicitHeight + topPadding + bottomPadding,
            control.popupMaximumHeight
        )
        padding: Theme.space1

        contentItem: ListView {
            objectName: control.objectName + "OptionList"
            clip: true
            implicitHeight: contentHeight
            model: dropdownPopup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 0
            boundsBehavior: Flickable.StopAtBounds
            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            objectName: control.objectName + "PopupSurface"
            radius: Theme.radiusMedium
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }
}
