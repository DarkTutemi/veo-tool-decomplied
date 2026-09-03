import QtQuick
import QtQuick.Controls as Controls

import "../components"
import "../components/AppIconRegistry.js" as AppIconRegistry
import "../theme"

Controls.Button {
    id: control

    property string actionId: ""
    property string iconName: ""
    property string tone: ""
    property string tooltip: ""
    property int minWidth: VfTheme.buttonMinWidth
    property bool danger: false
    property bool success: false
    property bool showLeadingIcon: true

    readonly property string resolvedTone: {
        if (control.danger)
            return "danger"
        if (control.success)
            return "success"
        if (String(control.tone || "").length > 0)
            return control.tone
        return control.highlighted ? "primary" : "neutral"
    }
    readonly property string resolvedIconName: control.showLeadingIcon
        ? AppIconRegistry.resolveActionIcon(control.actionId, control.text, control.iconName)
        : ""

    implicitHeight: VfTheme.dp(38)
    implicitWidth: Math.max(control.minWidth, buttonRow.implicitWidth + control.leftPadding + control.rightPadding)
    leftPadding: VfTheme.dp(14)
    rightPadding: VfTheme.dp(14)
    topPadding: VfTheme.dp(7)
    bottomPadding: VfTheme.dp(7)
    font.family: VfTheme.fontFamily
    font.pixelSize: VfTheme.dp(14)
    font.weight: control.resolvedTone === "neutral" ? VfTheme.weightControl : VfTheme.weightStrong

    contentItem: Row {
        id: buttonRow
        spacing: buttonIcon.visible ? 8 : 0
        anchors.centerIn: parent

        VfAppIcon {
            id: buttonIcon
            name: control.resolvedIconName
            size: VfTheme.dp(18)
            framed: false
        }

        Text {
            text: String(control.text || "")
            color: {
                if (!control.enabled)
                    return VfTheme.textSubtle
                if (control.resolvedTone === "primary" || control.resolvedTone === "danger" || control.resolvedTone === "success" || control.resolvedTone === "accent")
                    return "#FFFFFF"
                return VfTheme.text
            }
            font: control.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    background: Rectangle {
        radius: VfTheme.radiusControl
        color: {
            if (!control.enabled)
                return VfTheme.surfaceSoft
            if (control.down) {
                if (control.resolvedTone === "primary")
                    return VfTheme.primaryPressed
                if (control.resolvedTone === "danger")
                    return "#DC2626"
                if (control.resolvedTone === "success")
                    return "#0F9F6E"
                if (control.resolvedTone === "accent")
                    return "#6D28D9"
                return VfTheme.border
            }
            if (control.hovered) {
                if (control.resolvedTone === "primary")
                    return VfTheme.primaryHover
                if (control.resolvedTone === "danger")
                    return "#EF4444"
                if (control.resolvedTone === "success")
                    return "#10B981"
                if (control.resolvedTone === "accent")
                    return "#7C3AED"
                return VfTheme.surfaceSoft
            }
            if (control.resolvedTone === "primary")
                return VfTheme.primary
            if (control.resolvedTone === "danger")
                return VfTheme.redBorder
            if (control.resolvedTone === "success")
                return VfTheme.greenBorder
            if (control.resolvedTone === "accent")
                return VfTheme.violet
            return VfTheme.surface
        }
        border.width: 1
        border.color: {
            if (!control.enabled)
                return VfTheme.borderStrong
            if (control.resolvedTone === "primary")
                return VfTheme.primary
            if (control.resolvedTone === "danger")
                return VfTheme.redBorder
            if (control.resolvedTone === "success")
                return VfTheme.greenBorder
            if (control.resolvedTone === "accent")
                return VfTheme.violet
            return control.hovered ? VfTheme.borderStrong : VfTheme.borderBox
        }
    }

    Controls.ToolTip.visible: control.hovered && (control.tooltip.length > 0 || control.text.length > 0)
    Controls.ToolTip.text: control.tooltip.length > 0 ? control.tooltip : control.text
    Controls.ToolTip.delay: 400
}
