import QtQuick
import QtQuick.Controls

import "../theme"

ComboBox {
    id: control
    objectName: control.actionId.length > 0 ? control.actionId : control.fallbackObjectName

    property string actionId: ""
    property color accent: VfTheme.primary
    property bool wheelBlocked: true
    readonly property string fallbackObjectName: "noScrollComboBox"

    implicitHeight: VfTheme.controlHeight
    leftPadding: VfTheme.dp(8)
    rightPadding: VfTheme.dp(8)
    font.family: VfTheme.fontFamily
    font.pixelSize: VfTheme.fontControl
    palette.base: VfTheme.surface
    palette.button: VfTheme.surface
    palette.window: VfTheme.surface
    palette.text: VfTheme.text
    palette.buttonText: VfTheme.text
    palette.windowText: VfTheme.text
    palette.highlight: VfTheme.blueFill
    palette.highlightedText: VfTheme.text

    contentItem: Text {
        leftPadding: VfTheme.dp(8)
        rightPadding: VfTheme.dp(8)
        text: control.displayText
        color: control.enabled ? VfTheme.text : VfTheme.textSubtle
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontControl
        font.weight: VfTheme.weightControl
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    background: Rectangle {
        radius: VfTheme.radiusControl
        color: control.enabled ? VfTheme.surface : VfTheme.surfaceSoft
        border.width: 1
        border.color: control.activeFocus ? control.accent : (control.hovered ? VfTheme.borderStrong : VfTheme.borderBox)
    }

    indicator: Item {
        width: 0
        height: 0
    }

    popup: Popup {
        // Defensive pin (no-op on the Basic style, whose default is already
        // Popup.Item): never let a Qt/style upgrade move this dropdown into a
        // separate native window — those fail on broken-compositor machines.
        // See VfSelectField.qml for the full story.
        popupType: Popup.Item
        y: control.height + 4
        width: control.width
        padding: VfTheme.dp(4)
        implicitHeight: Math.min(contentItem.implicitHeight + topPadding + bottomPadding, 260)
        onOpened: Qt.callLater(function() {
            if (contentItem && control.currentIndex >= 0)
                contentItem.positionViewAtIndex(control.currentIndex, ListView.Center)
        })

        contentItem: ListView { // perf-lint: disable=R1  ComboBox dropdown with fixed options, recycling pointless
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex >= 0 ? control.highlightedIndex : control.currentIndex
            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            radius: VfTheme.radiusControl
            color: VfTheme.surface
            border.width: 1
            border.color: VfTheme.borderBox
        }
    }

    WheelHandler {
        enabled: control.wheelBlocked
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            event.accepted = true
        }
    }

    delegate: ItemDelegate {
        width: control.width
        height: VfTheme.controlHeight
        highlighted: control.highlightedIndex >= 0 ? control.highlightedIndex === index : control.currentIndex === index
        leftPadding: control.leftPadding

        background: Rectangle {
            radius: VfTheme.radiusControl - 2
            color: parent.highlighted ? VfTheme.blueFill : VfTheme.surface
            border.width: parent.highlighted ? 1 : 0
            border.color: parent.highlighted ? VfTheme.blueBorderSoft : "transparent"
        }

        contentItem: Text {
            text: modelData && modelData.label !== undefined ? modelData.label : String(modelData)
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontControl
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
}
