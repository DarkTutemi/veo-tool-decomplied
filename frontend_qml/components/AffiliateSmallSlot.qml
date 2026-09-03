import QtQuick
import "../theme"

// Small 78×78 asset thumbnail with a remove badge. Extracted from the old inline
// `AffiliateSmallSlot`; parent.parent chains replaced with the `slot` id.
Rectangle {
    id: slot

    property var assetData: ({})
    property string imageSource: ""
    property string nameText: ""
    property bool placeholder: false
    property bool disabled: false   // AI mode → slot mờ + ⚡, không bấm
    property int slotIndex: -1
    property string voiceName: ""   // nếu nhân vật đã bind giọng → badge tên voice

    signal removeRequested(string assetId)
    signal clicked(int index)

    width: VfTheme.dp(78)
    height: VfTheme.dp(78)
    radius: VfTheme.dp(8)
    color: VfTheme.surface
    border.color: VfTheme.borderStrong
    border.width: 2
    clip: true
    opacity: slot.disabled ? 0.38 : 1.0

    Image {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(4)
        source: slot.imageSource
        fillMode: Image.PreserveAspectCrop
        visible: String(source).length > 0 && !slot.placeholder
        asynchronous: true
        sourceSize.width: 320
        sourceSize.height: 240
    }

    Text {
        anchors.centerIn: parent
        text: slot.disabled ? "⚡" : (slot.placeholder ? "+" : (slot.nameText.length > 0 ? slot.nameText : "+"))
        color: slot.disabled ? VfTheme.violet : (slot.placeholder ? VfTheme.primary : "#FFFFFF")
        font.family: VfTheme.fontFamily
        font.pixelSize: (slot.placeholder || slot.disabled) ? 22 : VfTheme.fontTiny
        font.weight: slot.placeholder ? VfTheme.weightControl : VfTheme.weightStrong
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        width: slot.width - 10
        wrapMode: Text.WordWrap
        maximumLineCount: slot.placeholder ? 1 : 2
        visible: slot.disabled || slot.placeholder || slot.imageSource.length === 0
    }

    MouseArea {
        anchors.fill: parent
        enabled: !slot.disabled
        cursorShape: Qt.PointingHandCursor
        onClicked: slot.clicked(slot.slotIndex)
    }

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: VfTheme.dp(4)
        anchors.topMargin: VfTheme.dp(4)
        width: VfTheme.dp(18)
        height: VfTheme.dp(18)
        radius: VfTheme.dp(9)
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
            onClicked: slot.removeRequested(String((slot.assetData || {}).id || (slot.assetData || {}).media_id || ""))
        }
    }

    // Voice-bind badge (bottom): nhân vật đã gán giọng nào.
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: VfTheme.dp(15)
        color: Qt.rgba(0, 0, 0, 0.6)
        visible: !slot.placeholder && slot.voiceName.length > 0

        Text {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(4)
            anchors.rightMargin: VfTheme.dp(4)
            text: "♪ " + slot.voiceName
            color: "#FFFFFF"
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
}
