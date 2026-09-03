import QtQuick
import QtQuick.Controls
import "../theme"

Rectangle {
    id: root

    property string text: ""
    property string tone: "neutral"
    property string actionId: ""
    property bool active: false
    property bool hovered: buttonMouse.containsMouse
    property string tooltip: ""

    signal clicked()

    function cleanText(value) {
        var text = String(value || "")
        while (text.length > 0) {
            var code = text.charCodeAt(0)
            if (code === 0x20) {
                text = text.slice(1)
                continue
            }
            if (code >= 0xD800 && code <= 0xDBFF) {
                text = text.slice(2).replace(/^[\ufe0f\u200d\s]+/, "")
                continue
            }
            if ((code >= 0x2600 && code <= 0x27BF) || code === 0x25A1 || code === 0xFFFD) {
                text = text.slice(1).replace(/^[\ufe0f\u200d\s]+/, "")
                continue
            }
            var mark1 = (void i18n.revision, i18n.t("status_bar_button.vn_diacritic_eth", "ð"))
            var mark2 = (void i18n.revision, i18n.t("status_bar_button.vn_diacritic_idotless", "ï"))
            var mark3 = (void i18n.revision, i18n.t("status_bar_button.vn_diacritic_acirc", "â"))
            if (text.indexOf(mark1) === 0 || text.indexOf(mark2) === 0 || text.indexOf(mark3) === 0) {
                var firstSpace = text.indexOf(" ")
                if (firstSpace >= 0) {
                    text = text.slice(firstSpace + 1)
                    continue
                }
            }
            break
        }
        return text
    }

    implicitWidth: Math.max(54, buttonText.implicitWidth + 18)
    implicitHeight: VfTheme.dp(22)
    radius: VfTheme.dp(4)
    color: {
        if (root.active && root.tone === "blue") return VfTheme.blueFill
        if (root.active && root.tone === "danger") return VfTheme.redFill
        if (root.active && root.tone === "green") return VfTheme.greenFill
        if (root.hovered && root.tone === "amber") return VfTheme.amberFill
        if (root.hovered && root.tone === "blue") return VfTheme.blueFill
        if (root.hovered && root.tone === "danger") return VfTheme.redFill
        if (root.hovered && root.tone === "green") return VfTheme.greenFill
        return "transparent"
    }
    border.width: 1
    border.color: {
        if (root.active && root.tone === "blue") return VfTheme.primary
        if (root.active && root.tone === "danger") return VfTheme.redBorder
        if (root.active && root.tone === "green") return VfTheme.greenBorder
        if (root.hovered && root.tone === "amber") return "#F59E0B"
        if (root.hovered && root.tone === "blue") return VfTheme.primary
        if (root.hovered && root.tone === "danger") return VfTheme.redBorder
        if (root.hovered && root.tone === "green") return VfTheme.greenBorder
        return VfTheme.border
    }

    Text {
        id: buttonText
        anchors.centerIn: parent
        width: parent.width - 12
        text: root.cleanText(root.text)
        color: {
            if (root.tone === "amber" && root.hovered) return "#D97706"
            if (root.tone === "blue" && (root.hovered || root.active)) return "#2563EB"
            if (root.tone === "danger" && (root.hovered || root.active)) return "#DC2626"
            if (root.tone === "green" && (root.hovered || root.active)) return "#059669"
            return VfTheme.textSubtle
        }
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontSmall
        font.weight: root.active ? VfTheme.weightStrong : VfTheme.weightControl
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    MouseArea {
        id: buttonMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    ToolTip.visible: root.tooltip.length > 0 && root.hovered
    ToolTip.text: root.tooltip
    ToolTip.delay: 450
}
