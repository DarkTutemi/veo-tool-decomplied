pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../.."

ComboBox {
    id: control
    property string availabilityReason: ""
    property real popupWidth: Math.max(control.width, 280)
    property int lastSelectedIndex: -1
    property var lastSelectedOption: null
    property int selectionRevision: 0
    readonly property int optionHeight: Theme.controlHeight
    readonly property int maximumVisibleOptions: 9
    signal optionSelected(int index, var option)

    function selectOption(index: int): bool {
        if (index < 0 || index >= control.count) return false
        const candidate = control.model[index]
        const option = candidate === null || candidate === undefined
            ? ({}) : candidate
        control.currentIndex = index
        control.lastSelectedIndex = index
        control.lastSelectedOption = option
        control.selectionRevision += 1
        control.optionSelected(index, option)
        control.popup.close()
        return true
    }
    activeFocusOnTab: true
    Accessible.name: displayText
    Accessible.description: control.availabilityReason
    implicitHeight: Theme.controlHeight
    leftPadding: 12
    rightPadding: 34
    font.pixelSize: Theme.fontBody

    contentItem: Text {
        leftPadding: 0
        rightPadding: 0
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
        id: option
        required property int index
        required property var modelData
        readonly property bool labelTruncated: optionLabel.truncated
        readonly property real labelImplicitWidth: optionLabel.implicitWidth
        objectName: control.objectName + "_option_" + String(option.index)
        width: control.popup.width - 8
        height: control.optionHeight
        leftPadding: 10
        rightPadding: 10
        highlighted: control.highlightedIndex === option.index
        text: control.textRole.length > 0
            ? String(option.modelData[control.textRole] || "")
            : String(option.modelData)
        Accessible.name: text
        Accessible.role: Accessible.ListItem
        activeFocusOnTab: true
        onClicked: control.selectOption(option.index)
        Keys.onReturnPressed: function(event) {
            control.selectOption(option.index)
            event.accepted = true
        }
        Keys.onEnterPressed: function(event) {
            control.selectOption(option.index)
            event.accepted = true
        }
        Keys.onSpacePressed: function(event) {
            control.selectOption(option.index)
            event.accepted = true
        }
        contentItem: Text {
            id: optionLabel
            text: option.text
            color: Theme.textMuted
            font: control.font
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            color: option.highlighted ? Theme.hover : Theme.panel
        }
    }
    popup: Popup {
        x: Math.min(0, control.width - width)
        y: control.height + 3
        width: Math.max(control.width, control.popupWidth + 64)
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
            radius: Theme.radiusMedium
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }
}
