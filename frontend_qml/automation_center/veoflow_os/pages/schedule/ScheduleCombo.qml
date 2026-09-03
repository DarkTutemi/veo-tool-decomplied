pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

ComboBox {
    id: control
    objectName: "scheduleComboBox"

    property bool polishedDarkDropdown: true
    property int popupMaximumHeight: 252
    property var displayLabels: ({})

    function displayLabelAt(index) {
        const raw = control.textAt(index)
        const mapped = control.displayLabels[raw]
        return mapped === undefined || mapped === null || String(mapped).length === 0
            ? raw : String(mapped)
    }

    implicitHeight: Theme.controlHeight
    leftPadding: 10
    rightPadding: 30
    font.pixelSize: Theme.fontBody
    activeFocusOnTab: true
    hoverEnabled: true
    displayText: control.displayLabelAt(control.currentIndex)
    Accessible.role: Accessible.ComboBox
    Accessible.name: control.displayText || "Danh sách lựa chọn lịch trình"
    Accessible.description: "Dùng phím mũi tên để chọn, Enter để xác nhận"

    contentItem: Text {
        objectName: control.objectName + "Label"
        text: control.displayText
        color: control.enabled ? Theme.textMuted : Theme.textFaint
        font: control.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: UiIcon {
        objectName: control.objectName + "Chevron"
        x: control.width - width - 9
        y: control.topPadding + (control.availableHeight - height) / 2
        name: "ui/chevron-down"
        tone: control.activeFocus || control.down ? Theme.text : Theme.textFaint
        iconSize: 13
        rotation: control.down ? 180 : 0
        Behavior on rotation { NumberAnimation { duration: 110 } }
    }

    background: Rectangle {
        objectName: control.objectName + "Surface"
        radius: Theme.radiusSmall
        color: control.down
            ? Theme.accentSoft
            : (control.hovered ? Theme.hover : Theme.elevated)
        border.width: 1
        border.color: control.activeFocus
            ? Theme.accent
            : (control.hovered ? Theme.border : Theme.borderSoft)
    }

    delegate: ItemDelegate {
        id: option
        required property int index
        readonly property bool currentOption: option.index === control.currentIndex

        objectName: control.objectName + "Option_" + String(option.index)
        width: control.popup.width - control.popup.leftPadding
            - control.popup.rightPadding
        implicitHeight: Theme.controlHeight
        leftPadding: 9
        rightPadding: 9
        hoverEnabled: true
        highlighted: control.highlightedIndex === option.index
        Accessible.role: Accessible.MenuItem
        Accessible.name: control.displayLabelAt(option.index)
        Accessible.description: option.currentOption ? "Đang chọn" : "Chưa chọn"

        contentItem: RowLayout {
            spacing: 8
            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                text: control.displayLabelAt(option.index)
                color: option.currentOption || option.highlighted
                    ? Theme.text : Theme.textMuted
                font.pixelSize: Theme.fontBody
                font.weight: option.currentOption ? Font.DemiBold : Font.Normal
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            UiIcon {
                objectName: control.objectName + "OptionCheck_" + String(option.index)
                Layout.alignment: Qt.AlignVCenter
                visible: option.currentOption
                name: "semantic/check-circle"
                tone: Theme.success
                iconSize: 13
            }
        }

        background: Rectangle {
            radius: 5
            color: option.currentOption
                ? Theme.accentSoft
                : (option.highlighted || option.hovered ? Theme.hover : "transparent")
            border.width: option.currentOption ? 1 : 0
            border.color: option.currentOption ? Theme.accent : "transparent"
        }
    }

    popup: Popup {
        id: dropdownPopup
        objectName: control.objectName + "Popup"
        y: control.height + 4
        width: control.width
        implicitHeight: Math.min(
            contentItem.implicitHeight + topPadding + bottomPadding,
            control.popupMaximumHeight
        )
        padding: 4

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
