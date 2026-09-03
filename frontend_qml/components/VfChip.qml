import QtQuick
import QtQuick.Controls
import "../theme"
import "AppIconRegistry.js" as AppIconRegistry

Rectangle {
    id: root

    property string text: ""
    property bool selected: false
    property color accent: VfTheme.primary
    property string actionId: ""
    property int minWidth: VfTheme.dp(86)
    property string iconName: ""
    property bool showLeadingIcon: true
    property string tooltip: ""
    property real fontPixelSize: VfTheme.fontControl
    readonly property real horizontalPadding: 11
    readonly property real iconSize: 18
    readonly property real iconSpacing: chipIcon.visible ? 6 : 0
    readonly property real iconSpan: chipIcon.visible ? (iconSize + iconSpacing) : 0
    readonly property real contentImplicitWidth: iconSpan + chipText.implicitWidth
    readonly property real contentAvailableWidth: Math.max(0, width - horizontalPadding * 2)

    signal clicked()

    function cleanText(value) {
        return AppIconRegistry.stripGlyph(String(value || "").trim())
    }

    readonly property string resolvedIconName: showLeadingIcon
        ? AppIconRegistry.resolveActionIcon(root.actionId, root.text, root.iconName)
        : ""

    implicitWidth: Math.max(root.minWidth, root.contentImplicitWidth + (root.horizontalPadding * 2))
    implicitHeight: VfTheme.chipHeight
    radius: VfTheme.radiusControl
    color: !enabled
        ? VfTheme.surfaceSoft
        : (selected ? accent : (chipMouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface))
    border.color: !enabled
        ? VfTheme.border
        : (selected ? accent : (chipMouse.containsMouse ? VfTheme.borderStrong : VfTheme.borderSoft))
    border.width: 1
    opacity: enabled ? 1.0 : 0.55

    Item {
        id: chipContent
        anchors.centerIn: parent
        width: Math.min(root.contentImplicitWidth, root.contentAvailableWidth)
        height: parent.height

        Row {
            id: chipRow
            anchors.fill: parent
            spacing: root.iconSpacing

            VfAppIcon {
                id: chipIcon
                name: root.resolvedIconName
                size: root.iconSize
                framed: false
                color: !root.enabled ? VfTheme.textSubtle : (root.selected ? "#FFFFFF" : (AppIconRegistry.iconColor(root.resolvedIconName) || VfTheme.text))
                anchors.verticalCenter: parent.verticalCenter
                visible: name.length > 0
            }

            Text {
                id: chipText
                width: Math.max(0, chipContent.width - root.iconSpan)
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                text: root.cleanText(root.text)
                color: !root.enabled ? VfTheme.textSubtle : (root.selected ? "#FFFFFF" : VfTheme.text)
                font.family: VfTheme.fontFamily
                font.pixelSize: root.fontPixelSize
                font.weight: root.selected && root.enabled ? VfTheme.weightStrong : VfTheme.weightControl
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: 1
            }
        }
    }

    MouseArea {
        id: chipMouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.enabled)
                root.clicked()
        }
    }

    readonly property string resolvedTooltip: AppIconRegistry.resolveActionTooltip(root.actionId, root.tooltip, root.text)
    ToolTip.visible: (chipMouse.containsMouse || disabledMouse.containsMouse) && resolvedTooltip.length > 0
    ToolTip.text: resolvedTooltip
    ToolTip.delay: 350

    MouseArea {
        id: disabledMouse
        anchors.fill: parent
        enabled: !root.enabled
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.ArrowCursor
    }
}
