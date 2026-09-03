import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root

    property string label: ""
    property string value: ""
    property string tone: "neutral"

    implicitHeight: VfTheme.dp(32)
    implicitWidth: pillContent.implicitWidth + 24
    radius: VfTheme.dp(16)
    color: {
        if (tone === "green") return VfTheme.greenFill
        if (tone === "blue") return VfTheme.blueFill
        if (tone === "red") return VfTheme.redFill
        return "#222731"
    }
    border.color: {
        if (tone === "green") return VfTheme.greenBorder
        if (tone === "blue") return VfTheme.blueBorder
        if (tone === "red") return VfTheme.redBorder
        return "#363D49"
    }

    RowLayout {
        id: pillContent
        anchors.centerIn: parent
        spacing: VfTheme.dp(6)

        Text {
            text: root.label
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
        }

        Text {
            text: root.value
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            font.weight: Font.DemiBold
        }
    }
}
