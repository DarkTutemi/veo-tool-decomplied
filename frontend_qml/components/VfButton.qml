import QtQuick
import QtQuick.Controls
import "../theme"
import "AppIconRegistry.js" as AppIconRegistry

Button {
    id: control

    property string tone: "neutral"
    property string actionId: ""
    property int minWidth: VfTheme.dp(80)
    property string tooltip: ""
    property string iconName: ""
    property string leadingIcon: ""
    property bool showLeadingIcon: true
    property bool compact: false
    property real fontPixelSize: control.compact ? VfTheme.dp(11) : VfTheme.fontControl

    function cleanText(value) {
        return AppIconRegistry.stripGlyph(String(value || "").trim())
    }

    function iconVariant() {
        if (control.tone === "primary" || control.tone === "danger" || control.tone === "success" || control.tone === "green" || control.tone === "accent")
            return "light"
        return "dark"
    }

    readonly property string resolvedIconName: showLeadingIcon
        ? AppIconRegistry.resolveActionIcon(control.actionId, control.text, control.iconName.length > 0 ? control.iconName : control.leadingIcon)
        : ""

    implicitHeight: Math.max(control.compact ? VfTheme.dp(28) : VfTheme.controlHeight, buttonContent.implicitHeight + topPadding + bottomPadding)
    implicitWidth: Math.max(control.compact ? control.minWidth : Math.max(control.minWidth, VfTheme.buttonMinWidth), buttonContent.implicitWidth + leftPadding + rightPadding)
    leftPadding: control.compact ? VfTheme.dp(10) : VfTheme.dp(13)
    rightPadding: control.compact ? VfTheme.dp(10) : VfTheme.dp(13)
    topPadding: control.compact ? VfTheme.dp(4) : VfTheme.dp(6)
    bottomPadding: control.compact ? VfTheme.dp(4) : VfTheme.dp(6)

    contentItem: Item {
        implicitWidth: buttonContent.implicitWidth
        implicitHeight: buttonContent.implicitHeight

        Row {
            id: buttonContent
            anchors.centerIn: parent
            spacing: iconImage.visible ? (control.compact ? 5 : 7) : 0

            VfAppIcon {
                id: iconImage
                name: control.resolvedIconName
                size: control.compact ? VfTheme.dp(14) : VfTheme.actionIconSize
                framed: false
                // Filled buttons (primary/danger/success/accent) need a light icon
                // or the SVG blends into the colored background and disappears.
                color: {
                    if (!control.enabled) return VfTheme.textSubtle
                    if (control.tone === "primary" || control.tone === "danger" || control.tone === "success" || control.tone === "green" || control.tone === "accent")
                        return "#FFFFFF"
                    return AppIconRegistry.iconColor(control.resolvedIconName) || VfTheme.text
                }
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: buttonLabel
                text: control.cleanText(control.text)
                color: {
                    if (!control.enabled) return VfTheme.textSubtle
                    if (control.tone === "primary" || control.tone === "danger" || control.tone === "success" || control.tone === "green" || control.tone === "accent") return "#FFFFFF"
                    return VfTheme.text
                }
                font.family: VfTheme.fontFamily
                font.pixelSize: control.fontPixelSize
                font.weight: control.tone === "neutral" ? VfTheme.weightControl : VfTheme.weightStrong
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                maximumLineCount: 1
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    background: Rectangle {
        radius: VfTheme.radiusControl
        color: {
            if (!control.enabled) return VfTheme.surfaceSoft
            if (control.hovered) {
                if (control.tone === "primary") return VfTheme.primaryHover
                if (control.tone === "danger") return "#DC2626"
                if (control.tone === "success" || control.tone === "green") return "#16A34A"
                if (control.tone === "accent") return "#6D28D9"
                return VfTheme.surfaceSoft
            }
            if (control.down) return control.tone === "neutral" ? VfTheme.border : VfTheme.primaryPressed
            if (control.tone === "primary") return VfTheme.primary
            if (control.tone === "danger") return VfTheme.redBorder
            if (control.tone === "success" || control.tone === "green") return "#16A34A"
            if (control.tone === "accent") return "#7C3AED"
            return VfTheme.surface
        }
        border.width: 1
        border.color: {
            if (!control.enabled) return VfTheme.borderStrong
            if (control.tone === "primary") return VfTheme.primary
            if (control.tone === "danger") return VfTheme.redBorder
            if (control.tone === "success" || control.tone === "green") return "#16A34A"
            if (control.tone === "accent") return "#7C3AED"
            return control.hovered ? VfTheme.textSubtle : VfTheme.borderBox
        }
    }

    ToolTip.visible: control.hovered && (control.tooltip.length > 0 || control.text.length > 0)
    ToolTip.text: control.tooltip.length > 0 ? control.tooltip : control.text
    ToolTip.delay: 450
}
