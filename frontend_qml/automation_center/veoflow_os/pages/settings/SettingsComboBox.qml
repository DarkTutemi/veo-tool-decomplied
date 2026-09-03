pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../.."

ComboBox {
    id: control
    objectName: "settingsComboBox"

    property string availabilityReason: ""
    property real popupWidth: Math.max(control.width, 260)
    readonly property int optionHeight: Theme.controlHeight
    readonly property int maximumVisibleOptions: 8
    readonly property bool displayTextTruncated: comboLabel.truncated
    signal optionSelected(int index, var option)

    function optionLabel(option) {
        if (option === null || option === undefined)
            return ""
        if (typeof option === "object")
            return String(option.label === undefined ? option.key || "" : option.label)
        return String(option)
    }

    function optionValue(option) {
        if (option === null || option === undefined)
            return ""
        if (typeof option === "object")
            return option.value === undefined ? option.key : option.value
        return option
    }

    function selectOption(index) {
        if (index < 0 || index >= control.count)
            return false
        const option = control.model[index]
        control.currentIndex = index
        control.optionSelected(index, option)
        control.popup.close()
        return true
    }

    activeFocusOnTab: true
    displayText: control.currentIndex >= 0 && control.currentIndex < control.count
        ? control.optionLabel(control.model[control.currentIndex]) : ""
    Accessible.name: displayText
    Accessible.description: control.availabilityReason
    implicitHeight: Theme.controlHeight
    leftPadding: 12
    rightPadding: 34
    font.pixelSize: Theme.fontBody

    contentItem: Text {
        id: comboLabel
        objectName: control.objectName + "_displayText"
        text: control.displayText
        color: control.enabled ? Theme.textMuted : Theme.textFaint
        font: control.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    indicator: UiIcon {
        x: control.width - width - 10
        y: (control.height - height) / 2
        name: "ui/chevron-down"
        tone: control.enabled ? Theme.textMuted : Theme.textFaint
        iconSize: 15
    }
    background: Rectangle {
        radius: Theme.radiusSmall
        color: control.activeFocus || control.down ? Theme.hover : Theme.elevated
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? Theme.accent : Theme.border
    }
    delegate: ItemDelegate {
        id: optionDelegate
        required property int index
        required property var modelData
        readonly property bool labelTruncated: optionLabel.truncated
        readonly property real labelImplicitWidth: optionLabel.implicitWidth
        objectName: control.objectName + "_option_" + String(optionDelegate.index)
        width: control.popup.width - 8
        height: control.optionHeight
        leftPadding: 10
        rightPadding: 10
        highlighted: control.highlightedIndex === optionDelegate.index
        text: control.optionLabel(optionDelegate.modelData)
        Accessible.name: text
        Accessible.role: Accessible.ListItem
        activeFocusOnTab: true
        onClicked: control.selectOption(optionDelegate.index)
        Keys.onReturnPressed: function(event) {
            control.selectOption(optionDelegate.index)
            event.accepted = true
        }
        Keys.onEnterPressed: function(event) {
            control.selectOption(optionDelegate.index)
            event.accepted = true
        }
        Keys.onSpacePressed: function(event) {
            control.selectOption(optionDelegate.index)
            event.accepted = true
        }
        contentItem: Text {
            id: optionLabel
            text: optionDelegate.text
            color: Theme.textMuted
            font: control.font
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            color: optionDelegate.highlighted ? Theme.hover : Theme.panel
        }
    }
    popup: Popup {
        x: Math.min(0, control.width - width)
        y: control.height + 3
        width: Math.max(control.width, control.popupWidth)
        height: Math.min(
            Math.max(control.optionHeight, control.count * control.optionHeight)
                + topPadding + bottomPadding,
            control.maximumVisibleOptions * control.optionHeight
                + topPadding + bottomPadding)
        padding: 4
        onOpened: Qt.callLater(function() {
            if (control.currentIndex >= 0)
                optionsView.positionViewAtIndex(control.currentIndex, ListView.Center)
        })
        contentItem: ListView {
            id: optionsView
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }
        background: Rectangle {
            objectName: control.objectName + "_popupBackground"
            radius: Theme.radiusMedium
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }
}
