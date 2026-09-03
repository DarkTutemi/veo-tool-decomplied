import QtQuick

import "../theme"

Rectangle {
    id: root

    readonly property string primitiveContract: "JobPanelScrollShell is the lightweight, same-height scroll delegate for large job panels."

    property int sequenceNumber: 0
    property string statusChipText: ""
    property string typeText: ""
    property string titleText: ""
    property string subtitleText: ""
    property int assetCount: 0

    property int contentMargin: VfTheme.dp(8)
    readonly property int cardGap: width >= VfTheme.dp(360) ? VfTheme.dp(8) : VfTheme.dp(6)
    readonly property int assetGap: width >= VfTheme.dp(320) ? VfTheme.dp(4) : VfTheme.dp(3)
    readonly property int actionColumnWidth: width >= VfTheme.dp(360) ? VfTheme.dp(96) : VfTheme.dp(88)
    readonly property real availableThumbnailWidth: Math.max(VfTheme.dp(120), width - (contentMargin * 2) - actionColumnWidth - cardGap)
    readonly property real thumbnailFrameAspect: 16 / 9
    readonly property real thumbnailWidth: Math.min(Math.round(VfTheme.dp(150) * thumbnailFrameAspect), availableThumbnailWidth, VfTheme.dp(220))
    readonly property int assetSize: width >= VfTheme.dp(360) ? VfTheme.dp(32) : VfTheme.dp(30)
    readonly property real thumbnailHeight: Math.round(thumbnailWidth / thumbnailFrameAspect)
    readonly property int actionButtonHeight: Math.max(VfTheme.dp(20), Math.min(VfTheme.dp(26), Math.floor((thumbnailHeight - (cardGap * 3)) / 4)))
    readonly property real topAreaHeight: Math.max(thumbnailHeight, (actionButtonHeight * 4) + (cardGap * 3))
    readonly property int assetStripHeight: assetCount > 0 ? assetSize : 0
    readonly property int chipHeight: VfTheme.dp(18)
    readonly property int chipRadius: VfTheme.dp(5)
    readonly property int chipMargin: VfTheme.dp(6)
    readonly property int chipHPad: VfTheme.dp(8)
    readonly property int chipFontSize: VfTheme.dp(9)

    width: parent ? parent.width : 340
    implicitHeight: (contentMargin * 2) + topAreaHeight + (assetStripHeight > 0 ? assetStripHeight + cardGap : 0)
    height: implicitHeight
    radius: VfTheme.dp(12)
    color: VfTheme.surface
    border.color: VfTheme.border
    border.width: 1

    Item {
        anchors.fill: parent
        anchors.margins: root.contentMargin

        Item {
            id: topArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: root.topAreaHeight

            Rectangle {
                id: thumbnailFrame
                width: root.thumbnailWidth
                height: root.thumbnailHeight
                anchors.left: parent.left
                anchors.top: parent.top
                radius: VfTheme.dp(12)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderStrong
                border.width: 1

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: root.chipMargin
                    radius: root.chipRadius
                    color: VfTheme.borderStrong
                    implicitWidth: statusShellLabel.implicitWidth + root.chipHPad
                    implicitHeight: root.chipHeight
                    visible: statusShellLabel.text.length > 0

                    Text {
                        id: statusShellLabel
                        anchors.centerIn: parent
                        text: root.statusChipText
                        color: "#FFFFFF"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: root.chipFontSize
                        font.weight: Font.Bold
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: root.chipMargin
                    radius: root.chipRadius
                    color: "#1E293B"
                    implicitWidth: typeShellLabel.implicitWidth + root.chipHPad
                    implicitHeight: root.chipHeight
                    visible: typeShellLabel.text.length > 0

                    Text {
                        id: typeShellLabel
                        anchors.centerIn: parent
                        text: root.typeText
                        color: "#FFFFFF"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: root.chipFontSize
                        font.weight: Font.Bold
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: root.chipMargin
                    radius: root.chipRadius
                    color: "#0F172A"
                    opacity: 0.92
                    implicitWidth: sequenceShellLabel.implicitWidth + root.chipHPad
                    implicitHeight: root.chipHeight
                    visible: root.sequenceNumber > 0

                    Text {
                        id: sequenceShellLabel
                        anchors.centerIn: parent
                        text: "#" + String(root.sequenceNumber)
                        color: "#FFFFFF"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: root.chipFontSize
                        font.weight: Font.Bold
                    }
                }
            }

            Column {
                anchors.top: parent.top
                anchors.left: thumbnailFrame.right
                anchors.leftMargin: root.cardGap
                width: root.actionColumnWidth
                spacing: root.cardGap

                Repeater {
                    model: 4
                    Rectangle {
                        width: root.actionColumnWidth
                        height: root.actionButtonHeight
                        radius: VfTheme.dp(6)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border
                        border.width: 1
                    }
                }
            }
        }

        Row {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            spacing: root.assetGap
            visible: root.assetStripHeight > 0

            Repeater {
                model: Math.min(7, root.assetCount)
                Rectangle {
                    width: root.assetSize
                    height: root.assetSize
                    radius: VfTheme.dp(8)
                    color: VfTheme.surfaceSoft
                    border.color: VfTheme.borderStrong
                    border.width: 1
                }
            }
        }
    }
}
