pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "." as CenterPages

Item {
    id: root
    objectName: "automationCenterV2Workspace"

    required property var plane
    property var appBridge: null
    property int activePage: 0
    readonly property var navigation: [
        {"route": "coordination", "label": qsTr("Điều phối"), "icon": "semantic/workflow"},
        {"route": "channels", "label": qsTr("Kênh & cấu hình"), "icon": "semantic/channels"},
        {"route": "progress", "label": qsTr("Tiến trình"), "icon": "ui/list"},
        {"route": "schedule", "label": qsTr("Lịch đăng"), "icon": "ui/calendar"},
        {"route": "profiles", "label": qsTr("Hồ sơ đăng"), "icon": "navigation/users"},
        {"route": "attention", "label": qsTr("Cần xử lý"), "icon": "semantic/alert-circle"},
        {"route": "history", "label": qsTr("Lịch sử"), "icon": "ui/restore"}
    ]
    readonly property string activeRoute: root.navigation[root.activePage]
        ? String(root.navigation[root.activePage].route) : "coordination"
    readonly property var currentLoader: root.activePage === 0 ? coordinationLoader
        : root.activePage === 1 ? channelsLoader
        : root.activePage === 2 ? progressLoader
        : root.activePage === 3 ? scheduleLoader
        : root.activePage === 4 ? profilesLoader
        : root.activePage === 5 ? attentionLoader : historyLoader

    function pageForRoute(route) {
        const normalized = String(route || "").trim().toLowerCase().replace(/-/g, "_")
        const aliases = {
            "": "coordination",
            "today": "coordination",
            "overview": "coordination",
            "distribution": "coordination",
            "automation": "coordination",
            "assignment": "coordination",
            "copilot": "coordination",
            "channel": "channels",
            "channel_config": "channels",
            "settings": "channels",
            "runs": "progress",
            "queue": "progress",
            "calendar": "schedule",
            "publishing": "schedule",
            "channels_devices": "profiles",
            "browser": "profiles",
            "alerts": "attention",
            "incident": "attention",
            "incidents": "attention",
            "reports": "history",
            "audit": "history"
        }
        const semantic = aliases[normalized] || normalized
        for (let index = 0; index < root.navigation.length; ++index) {
            if (String(root.navigation[index].route) === semantic)
                return index
        }
        return -1
    }

    function activateRoute(route) {
        const page = root.pageForRoute(route)
        if (page < 0)
            return false
        root.activePage = page
        return true
    }

    function refreshActivePage() {
        if (!root.plane)
            return
        switch (root.activePage) {
        case 3:
            root.plane.callTool("tool1.schedule.occurrences.page", {"limit": 120, "offset": 0})
            break
        case 4:
            root.plane.callTool("browser.inventory.snapshot", {"limit": 20, "offset": 0})
            break
        case 5:
            root.plane.callTool("tool1.attention.page", {"limit": 50, "offset": 0})
            break
        case 6:
            root.plane.callTool("tool1.publish.history.page", {"limit": 50, "offset": 0})
            break
        default:
            root.plane.refresh()
            break
        }
    }

    function openNativeWorkflow(workflow) {
        if (!root.appBridge || !root.appBridge.setRoute)
            return false
        const routes = {
            "master": "master",
            "clone": "clone",
            "transcript": "transcript",
            "affiliate": "affiliate",
            "timemachine": "timemachine"
        }
        const route = routes[String(workflow || "").toLowerCase()]
        if (!route)
            return false
        root.appBridge.setRoute(route)
        return true
    }

    onActivePageChanged: refreshActivePage()

    Component.onCompleted: {
        root.plane.start()
        root.plane.refresh()
    }

    Shortcut { sequence: "Ctrl+1"; enabled: root.visible; onActivated: root.activePage = 0 }
    Shortcut { sequence: "Ctrl+2"; enabled: root.visible; onActivated: root.activePage = 1 }
    Shortcut { sequence: "Ctrl+3"; enabled: root.visible; onActivated: root.activePage = 2 }
    Shortcut { sequence: "Ctrl+4"; enabled: root.visible; onActivated: root.activePage = 3 }
    Shortcut { sequence: "Ctrl+5"; enabled: root.visible; onActivated: root.activePage = 4 }
    Shortcut { sequence: "Ctrl+6"; enabled: root.visible; onActivated: root.activePage = 5 }
    Shortcut { sequence: "Ctrl+7"; enabled: root.visible; onActivated: root.activePage = 6 }
    Shortcut { sequence: StandardKey.Refresh; enabled: root.visible; onActivated: root.refreshActivePage() }

    Rectangle {
        anchors.fill: parent
        color: CenterTokens.canvas
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: navigationBar
            objectName: "centerNavigationBar"
            Layout.fillWidth: true
            Layout.preferredHeight: CenterTokens.navHeight
            color: CenterTokens.panel
            border.width: 1
            border.color: CenterTokens.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 4

                Repeater {
                    model: root.navigation
                    delegate: CenterNavButton {
                        required property int index
                        required property var modelData
                        text: String(modelData.label)
                        iconName: String(modelData.icon)
                        checked: root.activePage === index
                        badgeCount: index === 5 && root.plane && root.plane.attentionModel
                            ? Number(root.plane.attentionModel.count || 0) : 0
                        onClicked: root.activePage = index
                    }
                }
                Item { Layout.fillWidth: true }
            }
        }

        StackLayout {
            id: pages
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.activePage

            Loader {
                id: coordinationLoader
                objectName: "centerPageLoader_coordination"
                Layout.fillWidth: true
                Layout.fillHeight: true
                active: root.activePage === 0 || item !== null
                asynchronous: true
                sourceComponent: Component {
                    CenterPages.CoordinationPage {
                        plane: root.plane
                        onOpenWorkflowRequested: workflow => root.openNativeWorkflow(workflow)
                        onNavigateRequested: route => root.activateRoute(route)
                    }
                }
            }
            Loader {
                id: channelsLoader
                objectName: "centerPageLoader_channels"
                Layout.fillWidth: true
                Layout.fillHeight: true
                active: root.activePage === 1 || item !== null
                asynchronous: true
                sourceComponent: Component {
                    CenterPages.ChannelConfigurationPage {
                        plane: root.plane
                        onOpenWorkflowRequested: workflow => root.openNativeWorkflow(workflow)
                        onNavigateRequested: route => root.activateRoute(route)
                    }
                }
            }
            Loader {
                id: progressLoader
                objectName: "centerPageLoader_progress"
                Layout.fillWidth: true
                Layout.fillHeight: true
                active: root.activePage === 2 || item !== null
                asynchronous: true
                sourceComponent: Component {
                    CenterPages.ProgressPage {
                        plane: root.plane
                        onOpenWorkflowRequested: workflow => root.openNativeWorkflow(workflow)
                    }
                }
            }
            Loader {
                id: scheduleLoader
                objectName: "centerPageLoader_schedule"
                Layout.fillWidth: true
                Layout.fillHeight: true
                active: root.activePage === 3 || item !== null
                asynchronous: true
                sourceComponent: Component { CenterPages.PublishingSchedulePage { plane: root.plane } }
            }
            Loader {
                id: profilesLoader
                objectName: "centerPageLoader_profiles"
                Layout.fillWidth: true
                Layout.fillHeight: true
                active: root.activePage === 4 || item !== null
                asynchronous: true
                sourceComponent: Component { CenterPages.PublishingProfilesPage { plane: root.plane } }
            }
            Loader {
                id: attentionLoader
                objectName: "centerPageLoader_attention"
                Layout.fillWidth: true
                Layout.fillHeight: true
                active: root.activePage === 5 || item !== null
                asynchronous: true
                sourceComponent: Component {
                    CenterPages.AttentionPage {
                        plane: root.plane
                        onNavigateRequested: route => root.activateRoute(route)
                    }
                }
            }
            Loader {
                id: historyLoader
                objectName: "centerPageLoader_history"
                Layout.fillWidth: true
                Layout.fillHeight: true
                active: root.activePage === 6 || item !== null
                asynchronous: true
                sourceComponent: Component {
                    CenterPages.AutomationHistoryPage {
                        plane: root.plane
                        onNavigateRequested: route => root.activateRoute(route)
                        onOpenWorkflowRequested: workflow => root.openNativeWorkflow(workflow)
                    }
                }
            }
        }

        Rectangle {
            id: statusBar
            objectName: "centerRuntimeStatusBar"
            Layout.fillWidth: true
            Layout.preferredHeight: CenterTokens.statusHeight
            color: CenterTokens.panel
            border.width: 1
            border.color: CenterTokens.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 26
                anchors.rightMargin: 26
                spacing: 18

                component RuntimeState: RowLayout {
                    id: runtime
                    required property string label
                    property bool ready: true
                    spacing: 8
                    Rectangle {
                        Layout.preferredWidth: 7
                        Layout.preferredHeight: 7
                        radius: 4
                        color: runtime.ready ? CenterTokens.success : CenterTokens.warning
                    }
                    Text {
                        text: runtime.label
                        color: CenterTokens.muted
                        font.family: CenterTokens.fontFamily
                        font.pixelSize: CenterTokens.body
                        elide: Text.ElideRight
                    }
                }

                RuntimeState {
                    label: root.activeRoute === "progress"
                        ? qsTr("Cập nhật theo sự kiện · Không polling toàn bộ queue")
                        : root.plane && root.plane.statusLabel
                        ? String(root.plane.statusLabel) : qsTr("Engine nội bộ sẵn sàng")
                    ready: !(root.plane && root.plane.actionBusy)
                }
                Rectangle {
                    visible: root.activeRoute !== "progress"
                    Layout.preferredWidth: visible ? 1 : 0
                    Layout.preferredHeight: 20
                    color: CenterTokens.border
                }
                RuntimeState {
                    visible: root.activeRoute !== "progress"
                    label: String(root.plane && root.plane.orderModel
                        ? root.plane.orderModel.count : 0) + qsTr(" work order cục bộ")
                }
                Rectangle {
                    visible: root.activeRoute !== "progress"
                    Layout.preferredWidth: visible ? 1 : 0
                    Layout.preferredHeight: 20
                    color: CenterTokens.border
                }
                RuntimeState {
                    visible: root.activeRoute !== "progress"
                    label: qsTr("Browser đăng bài cần preflight")
                }
                Item { Layout.fillWidth: true }
                UiIcon {
                    name: "semantic/upload-cloud"
                    tone: CenterTokens.muted
                    iconSize: 15
                    Layout.preferredWidth: 15
                    Layout.preferredHeight: 15
                }
                Text {
                    text: qsTr("Lưu cục bộ")
                    color: CenterTokens.muted
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.body
                }
            }
        }
    }

    Rectangle {
        id: loadingOverlay
        visible: root.currentLoader && root.currentLoader.status === Loader.Loading
        anchors.centerIn: parent
        width: 176
        height: 48
        radius: CenterTokens.radius
        color: CenterTokens.panel
        border.width: 1
        border.color: CenterTokens.border
        RowLayout {
            anchors.centerIn: parent
            spacing: 9
            BusyIndicator { running: loadingOverlay.visible; Layout.preferredWidth: 20; Layout.preferredHeight: 20 }
            Text {
                text: qsTr("Đang mở màn hình…")
                color: CenterTokens.muted
                font.family: CenterTokens.fontFamily
                font.pixelSize: CenterTokens.body
            }
        }
    }
}
