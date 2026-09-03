import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"
import "AppIconRegistry.js" as AppIconRegistry

// Compact almost-square toolbar chip. Size from CONTENT (icon + label), never
// from parent.width — a width bind inside RowLayout used to collapse labels.
Rectangle {
    id: button

    property string text: ""
    property string tooltip: ""
    property bool selected: false
    property bool danger: false
    property bool blocked: false
    property string blockedTooltip: ""
    property int minWidth: 0
    property string actionId: ""
    property string iconName: ""
    property bool flat: false
    // Compact chip (24dp) cho chỗ hẹp: header section (strip 38dp) và hàng queue
    // (chip 40dp từng tràn ra ngoài khung chứa — khoanh đỏ 26/8).
    property bool compact: false
    // Segmented cluster: square off the joined side so the fill sits flush in
    // the outer shell (no inner pad / nested radius).
    property bool joinLeft: false
    property bool joinRight: false

    opacity: blocked ? 0.45 : 1.0

    readonly property string resolvedIconName: AppIconRegistry.resolveActionIcon(actionId, text, iconName)
    readonly property bool showIcon: resolvedIconName.length > 0
    readonly property string labelText: button.cleanText(button.text)
    readonly property bool iconOnly: labelText.length === 0
    readonly property int boxSize: VfTheme.toolbarChipHeight

    signal clicked()

    function cleanText(value) {
        return AppIconRegistry.stripGlyph(String(value || "").trim())
    }

    implicitHeight: compact ? VfTheme.dp(24) : boxSize
    implicitWidth: iconOnly
        ? boxSize
        : Math.max(minWidth > 0 ? minWidth : boxSize, contentRow.implicitWidth + VfTheme.dp(18))
    Layout.fillWidth: false
    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.alignment: Qt.AlignVCenter
    radius: {
        if (flat && joinLeft && joinRight)
            return 0
        if (flat && (joinLeft || joinRight))
            return VfTheme.dp(8)
        return flat ? 0 : VfTheme.dp(8)
    }
    color: {
        if (danger)
            return mouse.containsMouse ? VfTheme.redFill : (flat ? "transparent" : VfTheme.surface)
        if (selected)
            return mouse.containsMouse ? VfTheme.primaryHover : VfTheme.primary
        if (flat)
            return mouse.containsMouse ? VfTheme.borderSoft : "transparent"
        return mouse.containsMouse ? VfTheme.panelRaised : VfTheme.surface
    }
    border.width: (flat || selected) ? 0 : 1
    border.color: danger ? VfTheme.redBorder : VfTheme.borderBox

    Rectangle {
        visible: button.joinRight && button.radius > 0
        anchors.right: parent.right
        width: button.radius
        height: parent.height
        color: parent.color
    }

    Rectangle {
        visible: button.joinLeft && button.radius > 0
        anchors.left: parent.left
        width: button.radius
        height: parent.height
        color: parent.color
    }

    Rectangle {
        visible: button.joinLeft
        width: 1
        height: parent.height
        color: VfTheme.borderSoft
    }

    readonly property string _tooltip: button.blocked && button.blockedTooltip.length > 0
        ? button.blockedTooltip
        : AppIconRegistry.resolveActionTooltip(actionId, tooltip, text)
    ToolTip.visible: mouse.containsMouse && _tooltip.length > 0
    ToolTip.text: _tooltip
    ToolTip.delay: 350

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: icon.visible && label.visible ? VfTheme.dp(6) : 0

        VfAppIcon {
            id: icon
            visible: button.showIcon
            name: button.resolvedIconName
            size: VfTheme.headerIconSize
            framed: false
            color: button.danger ? "#DC2626" : (button.selected ? "#FFFFFF" : (AppIconRegistry.iconColor(button.resolvedIconName) || VfTheme.text))
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: label
            visible: button.labelText.length > 0
            text: button.labelText
            color: {
                if (button.danger)
                    return VfTheme.redText
                if (button.selected)
                    return "#FFFFFF"
                return VfTheme.text
            }
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontControl
            font.weight: button.selected ? VfTheme.weightStrong : VfTheme.weightControl
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            maximumLineCount: 1
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: button.blocked ? Qt.ForbiddenCursor : Qt.PointingHandCursor
        onClicked: if (!button.blocked) button.clicked()
    }
}
