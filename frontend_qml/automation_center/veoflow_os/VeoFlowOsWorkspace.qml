pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "."
import "pages/center" as Center

Page {
    id: window
    objectName: "veoflowOsWorkspace"
    anchors.fill: parent
    implicitWidth: 1708
    implicitHeight: 800

    property var shellWindow: null
    property bool workspaceActive: true
    property alias activePage: workspace.activePage
    readonly property string activeRoute: workspace.activeRoute
    readonly property int navigationCount: workspace.navigation.length
    // qmllint disable unqualified
    readonly property var plane: controlPlane
    readonly property var appearanceBridge: typeof appearance === "undefined" ? null : appearance
    readonly property var tool1App: typeof appController === "undefined" ? null : appController
    // qmllint enable unqualified

    visible: window.workspaceActive
    background: Rectangle { color: CenterTokens.canvas }

    Binding {
        target: Theme
        property: "mode"
        value: window.appearanceBridge ? window.appearanceBridge.mode : "light"
        when: window.appearanceBridge !== null
    }

    function activateRoute(route) {
        return workspace.activateRoute(route)
    }

    function closeTransientSurfaces() {
        const seen = []
        function visit(item, depth) {
            if (!item || depth > 64 || seen.indexOf(item) >= 0)
                return
            seen.push(item)
            if (item !== window && item.opened !== undefined
                    && item.visible && item.close)
                item.close()
            const childLists = [item.children, item.data]
            if (item.contentItem)
                childLists.push([item.contentItem])
            for (let listIndex = 0; listIndex < childLists.length; ++listIndex) {
                const children = childLists[listIndex]
                if (!children)
                    continue
                for (let childIndex = 0; childIndex < children.length; ++childIndex)
                    visit(children[childIndex], depth + 1)
            }
        }
        visit(window, 0)
    }

    onWorkspaceActiveChanged: {
        if (!window.workspaceActive)
            window.closeTransientSurfaces()
    }

    Center.CenterWorkspace {
        id: workspace
        anchors.fill: parent
        plane: window.plane
        appBridge: window.tool1App
    }
}
