pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Panel {
    id: root
    objectName: "settingsNavigation"
    property int currentIndex: -1
    property var entries: []
    signal sectionSelected(int index)
    Accessible.name: "Danh mục cài đặt"
    Accessible.role: Accessible.Pane

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 3

        Repeater {
            model: root.entries
            delegate: Button {
                id: navButton
                required property int index
                required property var modelData
                readonly property string availabilityReason: enabled ? ""
                    : String(modelData.reason_code
                        || "Nhóm cài đặt chưa được backend cung cấp")
                objectName: "settingsNav_" + String(modelData.key || index)
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                activeFocusOnTab: true
                hoverEnabled: true
                enabled: modelData.available === true
                text: String(modelData.label || modelData.section || "")
                Accessible.name: text
                Accessible.description: enabled ? "Mở nhóm " + text
                    : navButton.availabilityReason
                Accessible.role: Accessible.Button
                Keys.onReturnPressed: clicked()
                Keys.onEnterPressed: clicked()
                Keys.onSpacePressed: clicked()
                onClicked: root.sectionSelected(index)

                contentItem: RowLayout {
                    spacing: 9
                    Rectangle {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        radius: 7
                        color: navButton.index === root.currentIndex
                            ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18)
                            : "transparent"
                        UiIcon {
                            anchors.centerIn: parent
                            name: String(navButton.modelData.icon_key || "")
                            tone: navButton.index === root.currentIndex ? Theme.accent : Theme.textFaint
                            iconSize: 15
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: navButton.text
                        color: navButton.index === root.currentIndex ? Theme.text : Theme.textMuted
                        font.pixelSize: 12
                        font.weight: navButton.index === root.currentIndex ? Font.DemiBold : Font.Normal
                        elide: Text.ElideRight
                    }
                }

                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: navButton.index === root.currentIndex
                        ? Theme.accentSoft
                        : navButton.hovered ? Theme.hover : "transparent"
                    border.width: navButton.activeFocus ? 1 : 0
                    border.color: Theme.accent
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
