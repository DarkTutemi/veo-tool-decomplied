import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

ColumnLayout {
    id: root
    property alias label: labelItem.text
    property alias value: input.text
    property bool readOnly: false
    spacing: 6

    Text {
        id: labelItem
        color: Theme.textFaint
        font.pixelSize: 11
        font.weight: Font.DemiBold
    }

    TextField {
        id: input
        Layout.fillWidth: true
        implicitHeight: 38
        readOnly: root.readOnly
        color: Theme.text
        selectionColor: Theme.accent
        selectedTextColor: "white"
        font.pixelSize: 13
        leftPadding: 11
        rightPadding: 11
        background: Rectangle {
            radius: Theme.radiusSmall
            color: Theme.elevated
            border.width: 1
            border.color: input.activeFocus ? Theme.accent : Theme.borderSoft
        }
    }
}
