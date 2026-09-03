pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../.."

ComboBox {
    id: control
    objectName: "alertsComboBox"

    property string availabilityReason: ""
    property real popupWidth: control.width
    readonly property int optionHeight: Theme.controlHeight
    readonly property int maximumVisibleOptions: 9

    implicitHeight: Theme.controlHeight
    leftPadding: 10
    rightPadding: 32
    font.pixelSize: Theme.fontBody
    activeFocusOnTab: true
    hoverEnabled: true
    Accessible.name: displayText
    Accessible.description: control.availabilityReason

    contentItem: Text {
        text: control.displayText
        color: control.enabled ? Theme.text : Theme.textFaint
        font: control.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: UiIcon {
        x: control.width - width - 9
        anchors.verticalCenter: parent.verticalCenter
        name: control.popup.visible ? "ui/chevron-up" : "ui/chevron-down"
        tone: control.enabled ? Theme.textMuted : Theme.textFaint
        iconSize: 14
    }

    delegate: ItemDelegate {
        id: optionDelegate
        required property int index
        readonly property bool labelTruncated: optionLabel.truncated
        readonly property real labelImplicitWidth: optionLabel.implicitWidth
        objectName: control.objectName + "_option_" + String(index)
        width: control.popup.width - 8
        height: control.optionHeight
        leftPadding: 10
        rightPadding: 10
        highlighted: control.highlightedIndex === index
        text: control.textAt(index)
        font: control.font
        Accessible.name: text
        contentItem: Text {
            id: optionLabel
            text: optionDelegate.text
            color: optionDelegate.enabled ? Theme.text : Theme.textFaint
            font: optionDelegate.font
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            radius: Theme.radiusSmall
            color: optionDelegate.highlighted || optionDelegate.hovered
                ? Theme.hover : "transparent"
        }
    }

    background: Rectangle {
        radius: Theme.radiusSmall
        color: control.down || control.popup.visible ? Theme.hover : Theme.elevated
        border.width: 1
        border.color: control.activeFocus || control.popup.visible
            ? Theme.accent : Theme.borderSoft
    }

    popup: Popup {
        x: Math.min(0, control.width - width)
        y: control.height + 4
        width: Math.max(control.width, control.popupWidth + Theme.space4)
        height: Math.min(
            Math.max(control.optionHeight, control.count * control.optionHeight)
                + topPadding + bottomPadding,
            control.maximumVisibleOptions * control.optionHeight
                + topPadding + bottomPadding)
        padding: 4
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            boundsBehavior: Flickable.StopAtBounds
            ScrollIndicator.vertical: ScrollIndicator {}
        }
        background: Rectangle {
            radius: Theme.radiusMedium
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }
}
