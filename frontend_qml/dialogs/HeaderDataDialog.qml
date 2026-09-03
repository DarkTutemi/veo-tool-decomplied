import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "HeaderDataDialog"

    property var payload: ({})

    signal actionRequested(string action, string value)

    parent: Overlay.overlay
    modal: true
    width: VfDialogMetrics.width(parent, VfTheme.dp(1180), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(780), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    header: VfDialogHeader {
        title: String(root.payload.title || "Data & Resources")
        iconName: "computer-disk"
        onCloseClicked: root.close()
    }

    function openFromPayload(data) {
        root.payload = data || ({})
        root.open()
    }

    function sections() {
        return root.payload && root.payload.sections ? root.payload.sections : []
    }

    function actions() {
        return root.payload && root.payload.actions ? root.payload.actions : []
    }

    function localRows() {
        return sections().length > 0 ? (sections()[0].rows || []) : []
    }

    function targetRows() {
        return sections().length > 1 ? (sections()[1].rows || []) : []
    }

    function runtimeRows() {
        return sections().length > 2 ? (sections()[2].rows || []) : []
    }

    function runAction(action, value) {
        var actionText = String(action || "")
        var valueText = String(value || "")
        if (actionText === "close") {
            root.close()
            return
        }
        root.actionRequested(actionText, valueText)
    }

    background: Rectangle {
        radius: VfTheme.dp(16)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
    }

    component StatCard: Rectangle {
        id: statCardRoot
        property string title: ""
        property string value: ""
        property string iconName: "open-folder"
        property color accent: "#2563EB"

        radius: VfTheme.dp(12)
        color: VfTheme.dark ? Qt.darker(accent, 2.4) : Qt.lighter(accent, 1.92)
        border.color: VfTheme.dark ? Qt.darker(accent, 1.4) : Qt.lighter(accent, 1.45)
        implicitHeight: VfTheme.dp(84)
        Layout.fillWidth: true

        RowLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(12)
            spacing: VfTheme.dp(12)

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(40)
                Layout.preferredHeight: VfTheme.dp(40)
                radius: VfTheme.dp(12)
                color: statCardRoot.accent

                VfAppIcon {
                    anchors.centerIn: parent
                    name: statCardRoot.iconName
                    size: VfTheme.dp(20)
                    framed: false
                    color: "#FFFFFF"
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(2)

                Text {
                    Layout.fillWidth: true
                    text: statCardRoot.title
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: statCardRoot.value
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(18)
                    font.weight: VfTheme.weightTitle
                    elide: Text.ElideRight
                }
            }
        }
    }

    component ActionTile: Rectangle {
        id: actionTileRoot
        property string title: ""
        property string detail: ""
        property string action: ""
        property string actionValue: ""
        property string iconName: "open-folder"
        property color accent: "#2563EB"

        signal activated(string action, string value)

        radius: VfTheme.dp(12)
        color: mouse.containsMouse ? (VfTheme.dark ? Qt.darker(accent, 2.3) : Qt.lighter(accent, 1.88)) : VfTheme.surface
        border.color: mouse.containsMouse ? (VfTheme.dark ? Qt.darker(accent, 1.4) : Qt.lighter(accent, 1.35)) : VfTheme.borderBox
        border.width: 1
        implicitHeight: VfTheme.dp(88)
        Layout.fillWidth: true

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: actionTileRoot.action.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: actionTileRoot.action.length > 0
            onClicked: actionTileRoot.activated(actionTileRoot.action, actionTileRoot.actionValue)
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(12)
            spacing: VfTheme.dp(12)

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(40)
                Layout.preferredHeight: VfTheme.dp(40)
                radius: VfTheme.dp(12)
                color: actionTileRoot.accent

                VfAppIcon {
                    anchors.centerIn: parent
                    name: actionTileRoot.iconName
                    size: VfTheme.dp(20)
                    framed: false
                    color: "#FFFFFF"
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(2)

                Text {
                    Layout.fillWidth: true
                    text: actionTileRoot.title
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                    font.weight: VfTheme.weightTitle
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: actionTileRoot.detail
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                }
            }
        }
    }

    component ResourceRow: Rectangle {
        id: resourceRowRoot
        property string label: ""
        property string value: ""
        property string action: ""
        property string actionValue: ""

        signal activated(string action, string value)

        radius: VfTheme.dp(10)
        color: mouse.containsMouse && action.length > 0 ? VfTheme.surfaceSoft : VfTheme.surface
        border.color: VfTheme.borderSoft
        border.width: 1
        implicitHeight: VfTheme.dp(48)
        Layout.fillWidth: true

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: resourceRowRoot.action.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: resourceRowRoot.action.length > 0
            onClicked: resourceRowRoot.activated(resourceRowRoot.action, resourceRowRoot.actionValue)
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(12)
            anchors.rightMargin: VfTheme.dp(12)
            spacing: VfTheme.dp(10)

            Text {
                Layout.preferredWidth: VfTheme.dp(150)
                text: resourceRowRoot.label
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightStrong
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: resourceRowRoot.value
                color: resourceRowRoot.action.length > 0 ? VfTheme.primary : VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                elide: Text.ElideMiddle
            }

            VfButton {
                visible: resourceRowRoot.action.length > 0
                text: "Open"
                actionId: "header.data.open"
                minWidth: VfTheme.dp(84)
                onClicked: resourceRowRoot.activated(resourceRowRoot.action, resourceRowRoot.actionValue)
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth
            contentHeight: headerDataBody.implicitHeight
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                id: headerDataBody
                width: parent.availableWidth
                spacing: VfTheme.dp(12)
                anchors.margins: VfTheme.dp(15)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(10)

                    StatCard {
                        title: "Local folders"
                        value: String(root.localRows().length)
                        iconName: "open-folder"
                        accent: "#2563EB"
                    }

                    StatCard {
                        title: "Workspace targets"
                        value: String(root.targetRows().length)
                        iconName: "computer-disk"
                        accent: "#0F766E"
                    }

                    StatCard {
                        title: "Primary action"
                        value: root.actions().length > 0 ? String((root.actions()[0] || {}).label || "Ready") : "Ready"
                        iconName: "locked-with-key"
                        accent: "#7C3AED"
                    }
                }

                VfPanel {
                    Layout.fillWidth: true
                    title: "Quick actions"
                    subtitle: "Shortcuts into data folders, managers, and runtime monitors."
                    dense: true

                    GridLayout {
                        Layout.fillWidth: true
                        columns: width >= 860 ? 3 : 2
                        columnSpacing: VfTheme.dp(10)
                        rowSpacing: VfTheme.dp(10)

                        ActionTile {
                            title: "Open app data"
                            detail: "Open the main local data directory."
                            action: root.actions().length > 0 ? String((root.actions()[0] || {}).action || "") : ""
                            actionValue: root.actions().length > 0 ? String((root.actions()[0] || {}).value || "") : ""
                            iconName: "open-folder"
                            accent: "#2563EB"
                            onActivated: (action, value) => root.runAction(action, value)
                        }

                        ActionTile {
                            title: "Account settings"
                            detail: "Jump to API keys, accounts, and local resources."
                            action: "route"
                            actionValue: "settings"
                            iconName: "locked-with-key"
                            accent: "#0F766E"
                            onActivated: (action, value) => root.runAction(action, value)
                        }

                        ActionTile {
                            title: "Style manager"
                            detail: "Open the style framework manager from Master Prompt."
                            action: "master_style_manager"
                            actionValue: "style_manager"
                            iconName: "notebook"
                            accent: "#7C3AED"
                            onActivated: (action, value) => root.runAction(action, value)
                        }

                        ActionTile {
                            title: "Job monitor"
                            detail: "Open the live background job monitor."
                            action: "status_job_monitor"
                            actionValue: ""
                            iconName: "clipboard"
                            accent: "#0F766E"
                            onActivated: (action, value) => root.runAction(action, value)
                        }

                        ActionTile {
                            title: "Error log"
                            detail: "Open failed job details and clear the log if needed."
                            action: "status_error_log"
                            actionValue: ""
                            iconName: "red-triangle"
                            accent: "#DC2626"
                            onActivated: (action, value) => root.runAction(action, value)
                        }

                        ActionTile {
                            title: "System log"
                            detail: "Toggle the live system log panel."
                            action: "status_log_panel"
                            actionValue: ""
                            iconName: "notebook"
                            accent: "#D97706"
                            onActivated: (action, value) => root.runAction(action, value)
                        }
                    }
                }

                VfPanel {
                    Layout.fillWidth: true
                    title: "Local resources"
                    subtitle: "Folders and JSON files that back the QML shell."
                    dense: true

                    Repeater {
                        model: root.localRows()

                        delegate: ResourceRow {
                            label: String(modelData.label || "")
                            value: String(modelData.value || "")
                            action: String(modelData.action || "")
                            actionValue: String(modelData.action_value || modelData.value || "")
                            onActivated: (action, value) => root.runAction(action, value)
                        }
                    }
                }

                VfPanel {
                    Layout.fillWidth: true
                    title: "Workspace targets"
                    subtitle: "Mapped QML destinations for settings, styles, themes, and history."
                    dense: true

                    Repeater {
                        model: root.targetRows()

                        delegate: ResourceRow {
                            label: String(modelData.label || "")
                            value: String(modelData.value || "")
                            action: String(modelData.action || "")
                            actionValue: String(modelData.action_value || modelData.value || "")
                            onActivated: (action, value) => root.runAction(action, value)
                        }
                    }
                }

                VfPanel {
                    Layout.fillWidth: true
                    title: "Runtime tools"
                    subtitle: "Current browser health plus log and monitor entry points."
                    dense: true
                    visible: root.runtimeRows().length > 0

                    Repeater {
                        model: root.runtimeRows()

                        delegate: ResourceRow {
                            label: String(modelData.label || "")
                            value: String(modelData.value || "")
                            action: String(modelData.action || "")
                            actionValue: String(modelData.action_value || modelData.value || "")
                            onActivated: (action, value) => root.runAction(action, value)
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(60)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(14)
                anchors.rightMargin: VfTheme.dp(14)
                spacing: VfTheme.dp(8)

                Item {
                    Layout.fillWidth: true
                }

                Repeater {
                    model: root.actions()

                    delegate: VfButton {
                        property var actionData: modelData

                        text: String(actionData.label || "")
                        tone: String(actionData.tone || "neutral")
                        actionId: "header.data.footer"
                        onClicked: root.runAction(actionData.action, actionData.value)
                    }
                }
            }
        }
    }
}
