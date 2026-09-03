import QtQuick
import "../theme"

// Extracted verbatim from WorkPanelWorkspace.qml (inline component, 0 parent deps).
// Shared by the Extend + Affiliate route bodies.
Rectangle {
    id: slot

    property string title: (void i18n.revision, i18n.t("prompt_card.add_asset_default", "+ Asset"))
    property int slotIndex: -1
    property var assetData: ({})
    property string imageSource: ""
    property string nameText: ""
    property bool placeholder: true

    signal clicked(int slotIndex)
    signal removeRequested(int slotIndex, string assetId)

    width: VfTheme.dp(112)
    height: VfTheme.dp(156)
    radius: VfTheme.dp(9)
    color: assetMouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface
    border.color: VfTheme.borderStrong
    border.width: 1

    Text {
        anchors.centerIn: parent
        width: parent.width - 14
        text: slot.placeholder ? slot.title : (slot.nameText || slot.title)
        color: slot.placeholder ? VfTheme.textMuted : "#FFFFFF"
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontControl
        font.weight: VfTheme.weightStrong
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        visible: slot.placeholder || slot.imageSource.length === 0
    }

    Image {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(6)
        source: slot.imageSource
        fillMode: Image.PreserveAspectCrop
        visible: !slot.placeholder && slot.imageSource.length > 0
        clip: true
        asynchronous: true
        sourceSize.width: 320
        sourceSize.height: 240
    }

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: VfTheme.dp(6)
        anchors.topMargin: VfTheme.dp(6)
        width: VfTheme.dp(20)
        height: VfTheme.dp(20)
        radius: VfTheme.dp(10)
        color: "#DC2626"
        visible: !slot.placeholder

        Text {
            anchors.centerIn: parent
            text: "×"
            color: "#FFFFFF"
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
            font.weight: VfTheme.weightStrong
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: slot.removeRequested(slot.slotIndex, String((slot.assetData || {}).id || (slot.assetData || {}).media_id || ""))
        }
    }

    MouseArea {
        id: assetMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: slot.clicked(slot.slotIndex)
    }
}
