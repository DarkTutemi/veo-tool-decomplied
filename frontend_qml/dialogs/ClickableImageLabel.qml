import QtQuick
import "../theme"

Rectangle {
    id: root

    property string base64Data: ""
    property string imageSource: base64Data.length > 0 ? "data:image/png;base64," + base64Data : ""
    property string charId: ""
    property string placeholder: "Preview"

    signal openRequested(string charId, string base64Data)

    color: VfTheme.surfaceSoft
    border.color: VfTheme.borderStrong
    radius: 6
    clip: true

    Image {
        anchors.fill: parent
        anchors.margins: 4
        source: root.imageSource
        fillMode: Image.PreserveAspectFit
        visible: root.imageSource.length > 0
    }

    Text {
        anchors.centerIn: parent
        visible: root.imageSource.length === 0
        text: root.placeholder
        color: VfTheme.textSubtle
        font.pixelSize: 11
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.imageSource.length > 0
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.openRequested(root.charId, root.base64Data)
    }
}
