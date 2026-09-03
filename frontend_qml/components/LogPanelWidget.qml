import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Rectangle {
    id: root

    property var entries: []
    property bool paused: false
    property string actionMessage: ""
    property bool actionError: false

    signal refreshRequested()
    signal clearRequested()
    signal copyRequested()
    signal closeRequested()

    onVisibleChanged: {
        if (visible) {
            root.actionMessage = ""
            root.actionError = false
            root.refreshRequested()
        }
    }

    Timer {
        interval: 1000
        running: root.visible && !root.paused
        repeat: true
        onTriggered: root.refreshRequested()
    }

    radius: VfTheme.dp(10)
    color: "#111827"
    border.color: VfTheme.textMuted
    border.width: 1
    clip: true

    function lineText(entry) {
        var timestamp = String(entry.timestamp || "")
        var source = String(entry.source || "")
        var message = String(entry.message || "")
        var prefix = timestamp.length > 0 ? "[" + timestamp + "] " : ""
        if (source.length > 0)
            prefix += source + " "
        return prefix + message
    }

    function applyActionResult(result) {
        var response = result || ({})
        root.actionMessage = String(response.message || response.error || "")
        root.actionError = !Boolean(response.ok)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(34)
            color: "#1F2937"
            border.color: VfTheme.textMuted

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(8)
                anchors.rightMargin: VfTheme.dp(8)
                spacing: VfTheme.dp(6)

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("qml.status_dialogs.log_panel", "System Log"))
                    color: VfTheme.border
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    font.weight: VfTheme.weightTitle
                }

                VfButton {
                    text: root.paused ? (void i18n.revision, i18n.t("common.resume", "Resume")) : (void i18n.revision, i18n.t("common.pause", "Pause"))
                    onClicked: root.paused = !root.paused
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.refresh", "Refresh"))
                    onClicked: root.refreshRequested()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.clear", "Clear"))
                    tone: "danger"
                    onClicked: root.clearRequested()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.copy", "Copy"))
                    onClicked: root.copyRequested()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Close"))
                    onClicked: root.closeRequested()
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.topMargin: 6
            visible: root.actionMessage.length > 0
            text: root.actionMessage
            color: root.actionError ? "#FCA5A5" : "#86EFAC"
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
            elide: Text.ElideRight
        }

        Timer {
            id: scrollEndTimer
            interval: 150
            repeat: false
            onTriggered: logList.positionViewAtEnd()
        }

        ListView {
            id: logList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            reuseItems: true   // delegate is a pure data-driven Text → safe to recycle
            model: root.entries || []
            onCountChanged: {
                if (!root.paused && logList.atYEnd)
                    scrollEndTimer.restart()
            }

            delegate: Text {
                width: logList.width - 12
                leftPadding: VfTheme.dp(8)
                rightPadding: VfTheme.dp(8)
                topPadding: VfTheme.dp(2)
                bottomPadding: VfTheme.dp(2)
                text: root.lineText(modelData)
                color: String(modelData.source || "") === "stderr" ? "#FCA5A5" : VfTheme.borderStrong
                font.family: "Consolas"
                font.pixelSize: VfTheme.dp(11)
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
        }
    }
}
