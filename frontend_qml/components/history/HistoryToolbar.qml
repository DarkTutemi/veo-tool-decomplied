pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ".."
import "../../theme"

Rectangle {
    id: root

    required property var sources
    required property var stateFilters
    property string currentSource: "all"
    property string currentState: "all"
    property string searchText: ""
    property bool busy: false

    signal sourceSelected(string value)
    signal stateSelected(string value)
    signal searchCommitted(string value)
    signal refreshRequested()

    implicitHeight: VfTheme.dp(44)
    radius: VfTheme.dp(7)
    color: VfTheme.surface
    border.color: VfTheme.borderSoft

    RowLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(6)
        spacing: VfTheme.dp(7)

        Text {
            text: "HISTORY"
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
            font.weight: Font.Bold
        }

        ComboBox {
            id: sourceCombo
            Layout.preferredWidth: VfTheme.dp(150)
            Layout.preferredHeight: VfTheme.dp(31)
            model: root.sources // perf-lint: disable=R2 immutable filter configuration
            textRole: "label"
            currentIndex: {
                for (var i = 0; i < model.length; ++i) {
                    if (String(model[i].key) === root.currentSource)
                        return i
                }
                return 0
            }
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            onActivated: index => root.sourceSelected(String(model[index].key || "all"))
            background: Rectangle {
                radius: VfTheme.dp(5)
                color: VfTheme.surface
                border.color: VfTheme.borderBox
            }
        }

        ComboBox {
            id: stateCombo
            Layout.preferredWidth: VfTheme.dp(135)
            Layout.preferredHeight: VfTheme.dp(31)
            model: root.stateFilters // perf-lint: disable=R2 immutable filter configuration
            textRole: "label"
            currentIndex: {
                for (var i = 0; i < model.length; ++i) {
                    if (String(model[i].key) === root.currentState)
                        return i
                }
                return 0
            }
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            onActivated: index => root.stateSelected(String(model[index].key || "all"))
            background: Rectangle {
                radius: VfTheme.dp(5)
                color: VfTheme.surface
                border.color: VfTheme.borderBox
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.minimumWidth: VfTheme.dp(180)
            Layout.preferredHeight: VfTheme.dp(31)
            radius: VfTheme.dp(5)
            color: VfTheme.surface
            border.color: VfTheme.borderBox

            Timer {
                id: searchDebounce
                interval: 220
                repeat: false
                onTriggered: root.searchCommitted(searchInput.text)
            }

            TextInput {
                id: searchInput
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(10)
                anchors.rightMargin: VfTheme.dp(30)
                text: root.searchText
                color: VfTheme.text
                selectByMouse: true
                verticalAlignment: TextInput.AlignVCenter

                ContextMenu.menu: VfTextEditingContextMenu {
                    editor: searchInput
                }
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                onTextChanged: searchDebounce.restart()

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: searchInput.text.length === 0
                    text: "Tìm run, tiêu đề hoặc prompt…"
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                }
            }

            VfAppIcon {
                anchors.right: parent.right
                anchors.rightMargin: VfTheme.dp(8)
                anchors.verticalCenter: parent.verticalCenter
                name: "search"
                size: VfTheme.dp(14)
                framed: false
                color: VfTheme.textMuted
            }
        }

        VfButton {
            compact: true
            text: "Làm mới"
            iconName: "clockwise-arrows"
            enabled: !root.busy
            onClicked: root.refreshRequested()
        }
    }
}
