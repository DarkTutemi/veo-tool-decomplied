import QtQuick
import QtQuick.Controls
import "../theme"
import "AppIconRegistry.js" as AppIconRegistry

Button {
    id: control

    property string tone: "neutral"
    property string actionId: ""
    property string iconName: ""
    property string tooltip: ""
    property int buttonWidth: 108

    readonly property string resolvedIconName: AppIconRegistry.resolveActionIcon(control.actionId, control.text, control.iconName)
    readonly property int resolvedGap: headerIcon.visible ? VfTheme.dp(6) : 0

    // Width fits content (icon + gap + label) — no fixed buttonWidth, so icon
    // and text stay tight together and the full label always shows.
    implicitHeight: VfTheme.toolbarButtonHeight
    implicitWidth: control.leftPadding + control.rightPadding + headerButtonContent.implicitWidth
    leftPadding: VfTheme.dp(10)
    rightPadding: VfTheme.dp(10)
    topPadding: VfTheme.dp(5)
    bottomPadding: VfTheme.dp(5)

    contentItem: Row {
        id: headerButtonContent
        spacing: control.resolvedGap
        anchors.centerIn: parent

        readonly property color contentColor: {
            if (!control.enabled) return VfTheme.textSubtle
            if (control.tone === "blue") return VfTheme.blueText
            if (control.tone === "green") return VfTheme.greenText
            if (control.tone === "indigo") return VfTheme.indigoText
            if (control.tone === "danger") return VfTheme.redText
            return VfTheme.textMuted
        }

        VfAppIcon {
            id: headerIcon
            name: control.resolvedIconName
            size: VfTheme.headerIconSize
            framed: false
            color: (control.enabled && control.tone === "neutral")
                ? (AppIconRegistry.iconColor(control.resolvedIconName) || headerButtonContent.contentColor)
                : headerButtonContent.contentColor
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: headerButtonLabel
            text: control.text
            color: headerButtonContent.contentColor
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontControl
            font.weight: control.tone === "neutral" ? VfTheme.weightControl : VfTheme.weightStrong
            verticalAlignment: Text.AlignVCenter
            maximumLineCount: 1
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Borderless, independent buttons. Tone buttons keep a soft fill so CTAs
    // (Store/Renew/License) stand out; neutral buttons are flat until hovered.
    background: Rectangle {
        radius: VfTheme.radiusControl
        border.width: 0
        color: {
            if (!control.enabled) return "transparent"
            if (control.down) {
                if (control.tone === "blue") return VfTheme.blueBorderSoft
                if (control.tone === "green") return VfTheme.greenBorderSoft
                if (control.tone === "indigo") return VfTheme.indigoBorderSoft
                if (control.tone === "danger") return VfTheme.redBorderSoft
                return VfTheme.border
            }
            if (control.hovered) {
                if (control.tone === "blue") return VfTheme.blueFill
                if (control.tone === "green") return VfTheme.greenFill
                if (control.tone === "indigo") return VfTheme.indigoFill
                if (control.tone === "danger") return VfTheme.redFill
                return VfTheme.surfaceSoft
            }
            if (control.tone === "blue") return VfTheme.blueFill
            if (control.tone === "green") return VfTheme.greenFill
            if (control.tone === "indigo") return VfTheme.indigoFill
            if (control.tone === "danger") return VfTheme.redFill
            return "transparent"
        }
    }

    ToolTip.visible: control.hovered && (control.tooltip.length > 0 || control.text.length > 0)
    ToolTip.text: control.tooltip.length > 0 ? control.tooltip : control.text
    ToolTip.delay: 450
}
