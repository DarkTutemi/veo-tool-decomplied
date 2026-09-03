import QtQuick
import QtQuick.Controls
import ".."

Rectangle {
    id: root
    property alias text: field.text
    property string placeholderText: "Tìm kiếm..."
    property int debounceInterval: 220
    signal queryCommitted(string query)

    implicitWidth: 240
    implicitHeight: CenterTokens.controlHeight
    radius: CenterTokens.radiusSmall
    color: CenterTokens.panel
    border.width: 1
    border.color: field.activeFocus ? CenterTokens.primary : CenterTokens.border

    Timer {
        id: debounce
        interval: root.debounceInterval
        repeat: false
        onTriggered: root.queryCommitted(field.text.trim())
    }

    UiIcon {
        id: searchIcon
        anchors.left: parent.left
        anchors.leftMargin: 11
        anchors.verticalCenter: parent.verticalCenter
        name: "ui/search"
        tone: CenterTokens.faint
        iconSize: 15
    }

    TextField {
        id: field
        anchors.left: searchIcon.right
        anchors.leftMargin: 7
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height - 2
        placeholderText: root.placeholderText
        color: CenterTokens.text
        placeholderTextColor: CenterTokens.faint
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.body
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        selectByMouse: true
        background: Item {}
        onTextChanged: debounce.restart()
        onAccepted: {
            debounce.stop()
            root.queryCommitted(text.trim())
        }
    }
}

