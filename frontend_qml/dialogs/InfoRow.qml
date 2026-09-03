import QtQuick
import QtQuick.Layouts

import "../theme"

RowLayout {
    id: root

    property string label: ""
    property string value: ""
    property bool clickable: false

    signal valueClicked(string value)

    Layout.fillWidth: true
    spacing: VfTheme.dp(8)

    Text {
        Layout.preferredWidth: VfTheme.dp(140)
        text: root.label
        color: VfTheme.textMuted
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontSmall
        elide: Text.ElideRight
    }

    Text {
        Layout.fillWidth: true
        visible: !root.clickable
        text: root.value
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontSmall
        font.weight: Font.DemiBold
        wrapMode: Text.WordWrap
    }

    ClickableLabel {
        Layout.fillWidth: true
        visible: root.clickable
        text: root.value
        font.pixelSize: VfTheme.fontSmall
        font.weight: Font.DemiBold
        wrapMode: Text.WordWrap
        onClicked: root.valueClicked(root.value)
    }
}
