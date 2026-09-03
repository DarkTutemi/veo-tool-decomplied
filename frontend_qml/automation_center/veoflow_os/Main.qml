pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "."

ApplicationWindow {
    id: window
    objectName: "veoflowMainWindow"
    width: 1600
    height: 980
    minimumWidth: 1180
    minimumHeight: 760
    visible: true
    title: "VeoFlow OS"
    color: Theme.base
    flags: Qt.Window | Qt.FramelessWindowHint

    property alias activePage: workspace.activePage
    property alias activeRoute: workspace.activeRoute
    property alias navigationCount: workspace.navigationCount

    function activateRoute(route: string): bool {
        return workspace.activateRoute(route)
    }

    VeoFlowOsWorkspace {
        id: workspace
        anchors.fill: parent
        shellWindow: window
    }
}
