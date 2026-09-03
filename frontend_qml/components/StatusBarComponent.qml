import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root

    // Stable tour target — single global bottom status bar (App.qml).
    objectName: "statusBar"

    property string route: ""
    property string statusMessage: "Ready"
    property var stats: ({})
    property real uiScale: 1.0
    property string dispatcherLabel: ""
    property string serverQueueLabel: ""
    property bool pageBusy: false
    property int errorCount: 0
    property bool logPanelVisible: false

    signal tokenRequested()
    signal monitorRequested()
    signal errorLogRequested()
    signal logPanelRequested()
    signal refreshRequested()

    function dispatcherCompleted() {
        var label = String(root.dispatcherLabel || "")
        return label.indexOf("completed") >= 0 || label.indexOf("dispatcher.completed") >= 0
    }

    Layout.fillWidth: true
    Layout.preferredHeight: VfTheme.dp(30)
    color: VfTheme.surfaceSoft
    border.color: VfTheme.border

    readonly property bool toolBusy:
        root.pageBusy
        || (root.dispatcherLabel.length > 0 && !root.dispatcherCompleted())

    // Top accent line — lights up blue while the tool is actively working.
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Math.max(1, VfTheme.dp(2))
        color: root.toolBusy ? VfTheme.primary : VfTheme.border
        opacity: root.toolBusy ? 0.9 : 0.45
        Behavior on color { ColorAnimation { duration: 300 } }
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    Timer {
        interval: 3000
        running: Qt.application.active && (typeof appController === "undefined" || !appController.bootstrapVisible)
        repeat: true
        onTriggered: {
            root.refreshRequested()
            if (typeof statusController !== "undefined" && statusController.refresh)
                statusController.refresh()
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: VfTheme.dp(8)
        anchors.rightMargin: VfTheme.dp(8)
        spacing: VfTheme.dp(7)

        Item {
            id: liveDot
            Layout.preferredWidth: VfTheme.dp(14)
            Layout.preferredHeight: VfTheme.dp(14)
            Layout.alignment: Qt.AlignVCenter
            readonly property color dotColor: root.toolBusy ? VfTheme.primary
                                              : (root.errorCount > 0 ? VfTheme.redBorder : VfTheme.greenBorder)

            Rectangle {
                anchors.centerIn: parent
                width: VfTheme.dp(10)
                height: width
                radius: width / 2
                color: "transparent"
                border.width: Math.max(1, VfTheme.dp(1.5))
                border.color: liveDot.dotColor
                visible: root.toolBusy
                SequentialAnimation on scale {
                    running: root.toolBusy && VfTheme.motion
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.7; to: 2.0; duration: 1500; easing.type: Easing.OutCubic }
                    PauseAnimation { duration: 80 }
                }
                SequentialAnimation on opacity {
                    running: root.toolBusy && VfTheme.motion
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.5; to: 0.0; duration: 1500; easing.type: Easing.OutCubic }
                    PauseAnimation { duration: 80 }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: VfTheme.dp(8)
                height: width
                radius: width / 2
                color: liveDot.dotColor
            }
        }

        Text {
            Layout.preferredWidth: Math.min(520, Math.max(160, implicitWidth + 8))
            Layout.maximumWidth: VfTheme.dp(520)
            text: root.statusMessage
            color: root.toolBusy ? VfTheme.text : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            font.weight: VfTheme.weightControl
            elide: Text.ElideRight
            maximumLineCount: 1
            verticalAlignment: Text.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        StatusBarButton {
            visible: root.dispatcherLabel.length > 0
            Layout.preferredWidth: Math.min(430, implicitWidth)
            Layout.maximumWidth: VfTheme.dp(430)
            actionId: "status.dispatcher"
            text: root.dispatcherLabel
            tone: root.dispatcherCompleted() ? "green" : "blue"
            active: !root.dispatcherCompleted()
            tooltip: (void i18n.revision, i18n.t("qml.status.open_monitor", "Open Job Monitor"))
            onClicked: root.monitorRequested()
        }

        StatusBarButton {
            visible: root.serverQueueLabel.length > 0
            Layout.preferredWidth: Math.min(280, implicitWidth)
            Layout.maximumWidth: VfTheme.dp(280)
            actionId: "status.server_queue"
            text: root.serverQueueLabel
            tone: "blue"
            tooltip: (void i18n.revision, i18n.t("qml.status.open_monitor", "Open Job Monitor"))
            onClicked: root.monitorRequested()
        }

        StatusBarButton {
            actionId: "status.tokens"
            text: (void i18n.revision, i18n.t("qml.status.tokens", "Tokens"))
            tone: "amber"
            tooltip: (void i18n.revision, i18n.t("qml.status_dialogs.token_title", "Token Monitor"))
            onClicked: root.tokenRequested()
        }

        StatusBarButton {
            actionId: "status.monitor"
            text: (void i18n.revision, i18n.t("qml.status.monitor", "Monitor"))
            tone: "blue"
            tooltip: (void i18n.revision, i18n.t("qml.status_dialogs.job_title", "Job Monitor"))
            onClicked: root.monitorRequested()
        }

        StatusBarButton {
            actionId: "status.errors"
            text: (void i18n.revision, i18n.t("qml.status.errors", "Errors")) + ": " + String(root.errorCount)
            tone: "danger"
            active: root.errorCount > 0
            tooltip: (void i18n.revision, i18n.t("qml.status_dialogs.error_title", "Error Log"))
            onClicked: root.errorLogRequested()
        }

        StatusBarButton {
            actionId: "status.log"
            text: (void i18n.revision, i18n.t("qml.status.log", "Log"))
            tone: "blue"
            active: root.logPanelVisible
            tooltip: (void i18n.revision, i18n.t("qml.status_dialogs.log_panel", "System Log"))
            onClicked: root.logPanelRequested()
        }

    }
}
