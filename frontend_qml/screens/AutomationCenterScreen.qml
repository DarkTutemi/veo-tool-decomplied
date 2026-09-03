pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root
    objectName: "automationCenterScreen"

    // qmllint disable unqualified
    readonly property var host: automationCenterHost
    // qmllint enable unqualified
    readonly property bool routeActive: root.visible
        && (!root.parent || root.parent.visible)

    onRouteActiveChanged: {
        if (root.host)
            root.host.setWorkspaceActive(root.routeActive)
    }

    Component.onCompleted: {
        if (!root.host)
            return
        root.host.mountWorkspace(workspaceMount, "distribution")
        root.host.setWorkspaceActive(root.routeActive)
    }

    Component.onDestruction: {
        if (root.host)
            root.host.unmountWorkspace(workspaceMount)
    }

    Item {
        id: workspaceMount
        objectName: "automationCenterWorkspaceMount"
        anchors.fill: parent
    }
}
