pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

ComboBox {
    id: control
    property string availabilityReason: ""
    property string leadingPlatform: ""
    property string leadingIcon: ""
    property bool leadingIconPreserveColors: false
    readonly property bool leadingGraphicReady:
        (control.leadingPlatform.length === 0 || platformGraphic.sourceReady)
        && (control.leadingIcon.length === 0 || uiGraphic.sourceReady)
    readonly property int optionHeight: Theme.controlHeight
    readonly property int maximumVisibleOptions: 9
    implicitHeight: Theme.controlHeight
    leftPadding: 10
    rightPadding: 32
    font.pixelSize: Theme.fontBody
    activeFocusOnTab: true
    Accessible.name: displayText
    Accessible.description: control.availabilityReason
    hoverEnabled: true

    contentItem: RowLayout {
        spacing: 7

        PlatformIcon {
            id: platformGraphic
            objectName: control.objectName.length > 0
                ? control.objectName + "PlatformIcon" : ""
            visible: control.leadingPlatform.length > 0
            platform: control.leadingPlatform
            iconSize: 17
            Layout.preferredWidth: visible ? 17 : 0
            Layout.preferredHeight: 17
        }

        UiIcon {
            id: uiGraphic
            objectName: control.objectName.length > 0
                ? control.objectName + "LeadingIcon" : ""
            visible: control.leadingIcon.length > 0
            name: control.leadingIcon
            preserveColors: control.leadingIconPreserveColors
            tone: control.enabled ? Theme.textMuted : Theme.textFaint
            iconSize: 17
            Layout.preferredWidth: visible ? 17 : 0
            Layout.preferredHeight: 17
        }

        Text {
            Layout.fillWidth: true
            text: control.displayText
            color: control.enabled ? Theme.text : Theme.textFaint
            font: control.font
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    indicator: UiIcon {
        objectName: control.objectName.length > 0
            ? control.objectName + "IndicatorIcon" : ""
        x: control.width - width - 9
        anchors.verticalCenter: parent.verticalCenter
        name: control.popup.visible ? "ui/chevron-up" : "ui/chevron-down"
        tone: control.enabled ? Theme.textMuted : Theme.textFaint
        iconSize: 14
    }

    delegate: ItemDelegate {
        id: optionDelegate
        required property int index
        objectName: control.objectName + "_option_" + String(index)
        width: control.width - 8
        height: control.optionHeight
        leftPadding: 10
        rightPadding: 10
        highlighted: control.highlightedIndex === index
        text: control.textAt(index)
        font: control.font
        Accessible.name: text
        contentItem: Text {
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
        y: control.height + 4
        width: control.width
        height: Math.min(
            Math.max(control.optionHeight, control.count * control.optionHeight)
                + topPadding + bottomPadding,
            control.maximumVisibleOptions * control.optionHeight
                + topPadding + bottomPadding)
        padding: 4
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: ListView {
            clip: true
            reuseItems: true
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
