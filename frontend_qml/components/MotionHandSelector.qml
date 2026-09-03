pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import "../theme"

ComboBox {
    id: root

    property var options: []
    property string value: "auto"
    property int minWidth: VfTheme.dp(154)
    property color accent: "#F59E0B"
    property string tooltip: ""

    signal selected(string value)

    function optionIndex(searchValue) {
        var items = root.options || []
        for (var i = 0; i < items.length; i += 1) {
            if (String(items[i].value) === String(searchValue))
                return i
        }
        return items.length > 0 ? 0 : -1
    }

    function optionObject(option) {
        return option && typeof option === "object"
            ? option
            : ({ label: String(option || ""), value: option, symbol: "" })
    }

    function currentOption() {
        var items = root.options || []
        var index = root.optionIndex(root.value)
        return index >= 0 && index < items.length ? root.optionObject(items[index]) : ({})
    }

    implicitWidth: minWidth
    implicitHeight: VfTheme.dp(34)
    width: implicitWidth
    height: implicitHeight
    model: root.options || []
    textRole: "label"
    valueRole: "value"
    currentIndex: root.optionIndex(root.value)
    enabled: (root.options || []).length > 0
    clip: true
    font.family: VfTheme.fontFamily
    font.pixelSize: VfTheme.dp(11)
    palette.base: VfTheme.surface
    palette.button: VfTheme.surface
    palette.window: VfTheme.surface
    palette.text: VfTheme.text
    palette.buttonText: VfTheme.text
    palette.windowText: VfTheme.text
    palette.highlight: VfTheme.amberFill
    palette.highlightedText: VfTheme.text
    onActivated: root.selected(String(root.currentValue || "auto"))

    HoverHandler { id: selectorHover }
    ToolTip.visible: selectorHover.hovered && root.tooltip.length > 0
    ToolTip.text: root.tooltip
    ToolTip.delay: 350

    contentItem: Item {
        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: VfTheme.dp(8)
            anchors.rightMargin: VfTheme.dp(24)
            spacing: VfTheme.dp(6)

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: VfTheme.dp(17)
                text: String(root.currentOption().symbol || "✍")
                color: VfTheme.text
                font.family: "Segoe UI Emoji"
                font.pixelSize: VfTheme.dp(13)
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(0, parent.width - VfTheme.dp(23))
                text: root.displayText || String(root.currentOption().label || "Hand / tool")
                color: root.enabled ? VfTheme.text : VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
        }
    }

    background: Rectangle {
        radius: VfTheme.dp(7)
        color: VfTheme.surface
        border.color: root.activeFocus ? root.accent : VfTheme.borderSoft
        border.width: 1
    }

    indicator: Text {
        x: root.width - width - VfTheme.dp(7)
        y: Math.round((root.height - height) / 2)
        width: VfTheme.dp(10)
        height: root.height
        text: "⌄"
        color: VfTheme.textSubtle
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(12)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    delegate: ItemDelegate {
        id: optionDelegate
        required property int index
        required property var modelData
        width: root.popup ? root.popup.width - root.popup.leftPadding - root.popup.rightPadding : root.width
        height: VfTheme.dp(30)
        highlighted: root.highlightedIndex === index || root.currentIndex === index

        background: Rectangle {
            radius: VfTheme.dp(6)
            color: optionDelegate.highlighted ? VfTheme.amberFill : VfTheme.surface
            border.color: optionDelegate.highlighted ? root.accent : "transparent"
        }

        contentItem: Row {
            spacing: VfTheme.dp(7)

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: VfTheme.dp(18)
                text: String(root.optionObject(optionDelegate.modelData).symbol || "✍")
                color: VfTheme.text
                font.family: "Segoe UI Emoji"
                font.pixelSize: VfTheme.dp(13)
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(0, parent.width - VfTheme.dp(25))
                text: String(root.optionObject(optionDelegate.modelData).label || "")
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                elide: Text.ElideRight
            }
        }
    }

    popup: Popup {
        popupType: Popup.Item
        y: root.height + VfTheme.dp(4)
        x: Math.min(0, root.width - width)
        width: Math.max(root.width, VfTheme.dp(210))
        padding: VfTheme.dp(4)
        implicitHeight: Math.min(contentItem.implicitHeight + topPadding + bottomPadding, VfTheme.dp(330))

        onAboutToShow: {
            var overlay = root.Overlay.overlay
            if (!overlay)
                return
            var pos = root.mapToItem(overlay, 0, 0)
            var margin = VfTheme.dp(6)
            var minX = margin - pos.x
            var maxX = overlay.width - margin - pos.x - width
            x = Math.max(minX, Math.min(Math.min(0, root.width - width), maxX))
            var wantedHeight = Math.min((root.options || []).length * VfTheme.dp(30)
                                        + topPadding + bottomPadding, VfTheme.dp(330))
            y = (pos.y + root.height + VfTheme.dp(4) + wantedHeight > overlay.height - margin
                 && pos.y - wantedHeight - VfTheme.dp(4) >= margin)
                ? -wantedHeight - VfTheme.dp(4)
                : root.height + VfTheme.dp(4)
        }

        contentItem: ListView { // perf-lint: disable=R1 tiny static catalog
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? (root.options || []) : null
            currentIndex: root.highlightedIndex >= 0 ? root.highlightedIndex : root.currentIndex
            ScrollIndicator.vertical: ScrollIndicator { }

            delegate: ItemDelegate {
                id: popupDelegate
                required property int index
                required property var modelData
                width: ListView.view ? ListView.view.width : root.width
                height: VfTheme.dp(30)
                leftPadding: VfTheme.dp(8)
                rightPadding: VfTheme.dp(8)
                topPadding: 0
                bottomPadding: 0
                hoverEnabled: true
                highlighted: hovered || ListView.isCurrentItem
                onClicked: {
                    var option = root.optionObject(popupDelegate.modelData)
                    root.selected(String(option.value || "auto"))
                    root.popup.close()
                }

                background: Rectangle {
                    radius: VfTheme.dp(6)
                    color: popupDelegate.highlighted ? VfTheme.amberFill : VfTheme.surface
                    border.color: popupDelegate.highlighted ? root.accent : "transparent"
                }

                contentItem: Row {
                    spacing: VfTheme.dp(7)

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: VfTheme.dp(18)
                        text: String(root.optionObject(popupDelegate.modelData).symbol || "✍")
                        color: VfTheme.text
                        font.family: "Segoe UI Emoji"
                        font.pixelSize: VfTheme.dp(13)
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.max(0, parent.width - VfTheme.dp(25))
                        text: String(root.optionObject(popupDelegate.modelData).label || "")
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        elide: Text.ElideRight
                    }
                }
            }
        }

        background: Rectangle {
            color: VfTheme.surface
            border.color: VfTheme.border
            border.width: 1
            radius: VfTheme.dp(8)
        }
    }
}
