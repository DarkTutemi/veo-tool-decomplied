import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root

    property var navItems: []
    property string activeRoute: ""
    property bool wrapTabs: width < 1540

    // Guide-pick mode: tabs whose route is in guideRoutes pulse; clicking one asks
    // the parent to start that tab's tour (instead of just navigating).
    property bool guidePickActive: false
    property var guideRoutes: []

    function isTourTab(route) {
        return root.guidePickActive && root.guideRoutes.indexOf(String(route || "")) >= 0
    }

    readonly property color stripFill: VfTheme.dark ? "#0E1727" : "#EEF4FB"
    readonly property color inactiveFill: "transparent"
    readonly property color inactiveHoverFill: VfTheme.dark ? "#182439" : "#F0F6FF"
    readonly property color activeFill: VfTheme.dark ? "#18345F" : "#FFFFFF"

    signal routeSelected(string route)
    signal tabBlocked(string route, string message)
    signal guidePicked(string route)

    // Bumped on appController.featureStatesChanged so each tab re-queries its
    // license state (enabled / maintenance / not-purchased).
    property int featureRevision: 0

    function featureStateFor(route) {
        void root.featureRevision  // dependency so bindings refresh on change
        if (typeof appController === "undefined" || !appController)
            return { enabled: true, badge: "", message: "" }
        var st = appController.featureTabState(String(route || ""))
        return st || { enabled: true, badge: "", message: "" }
    }

    Connections {
        target: (typeof appController !== "undefined") ? appController : null
        function onFeatureStatesChanged() { root.featureRevision++ }
    }

    component TabBadge: Rectangle {
        property string label: ""
        visible: label.length > 0
        z: 4
        height: VfTheme.dp(12)
        width: badgeLabel.implicitWidth + VfTheme.dp(8)
        radius: height / 2
        color: label === (void i18n.revision, i18n.t("app_tab_strip.maintenance", "Bảo trì")) ? "#F59E0B"
            : (label === "Demo" ? VfTheme.primary
            : (label === "Miễn phí" ? "#22C55E" : VfTheme.textSubtle))
        Text {
            id: badgeLabel
            anchors.centerIn: parent
            text: parent.label
            color: "#FFFFFF"
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(7)
            font.weight: VfTheme.weightTitle
        }
    }

    function cleanLabel(value) {
        var text = String(value || "").trim()
        text = text.replace(/^[\uD800-\uDBFF][\uDC00-\uDFFF]\uFE0F?\s*/, "")
        text = text.replace(/^[\u2600-\u27BF]\uFE0F?\s*/, "")
        return text.trim()
    }

    function routeColor(route) {
        switch (String(route || "")) {
        case "home": return VfTheme.cyan
        case "master": return VfTheme.indigoBorder
        case "automation": return VfTheme.violet
        case "clone": return VfTheme.amber
        case "transcript": return VfTheme.primary
        case "research": return VfTheme.violet
        case "voice": return VfTheme.pinkBorder
        case "normal": return VfTheme.greenBorder
        case "extend": return VfTheme.cyanBorder
        case "batch": return VfTheme.violetBorder
        case "affiliate": return VfTheme.amberBorder
        case "settings": return VfTheme.textMuted
        case "history": return VfTheme.blueBorder
        default: return VfTheme.primary
        }
    }

    Layout.fillWidth: true
    Layout.preferredHeight: root.wrapTabs ? (wrappedTabs.implicitHeight + VfTheme.dp(14)) : VfTheme.dp(46)
    color: VfTheme.canvas
    border.color: "transparent"
    clip: true

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: VfTheme.dp(8)
        anchors.rightMargin: VfTheme.dp(8)
        anchors.topMargin: VfTheme.dp(5)
        anchors.bottomMargin: VfTheme.dp(5)
        radius: VfTheme.dp(7)
        color: root.stripFill
        border.width: 0
    }

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: VfTheme.dp(12)
        anchors.rightMargin: VfTheme.dp(12)
        anchors.topMargin: VfTheme.dp(7)
        anchors.bottomMargin: VfTheme.dp(7)
        visible: !root.wrapTabs
        contentWidth: tabRow.implicitWidth
        contentHeight: height
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalFlick
        clip: true

        Row {
            id: tabRow
            height: parent.height
            spacing: VfTheme.dp(6)

            Repeater {
                model: root.navItems

                Rectangle {
                    id: tabItem

                    property bool active: root.activeRoute === modelData.route
                    property bool hovered: tabMouse.containsMouse
                    property var fstate: root.featureStateFor(modelData.route)

                    width: Math.max(98, Math.min(188, tabContent.implicitWidth + VfTheme.dp(30)))
                    height: parent.height
                    radius: VfTheme.dp(7)
                    color: active ? root.activeFill : (hovered ? root.inactiveHoverFill : root.inactiveFill)
                    opacity: 1
                    border.width: 0
                    border.color: "transparent"

                    Rectangle {
                        visible: tabItem.active
                        z: 0
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: parent.height
                        radius: parent.radius
                        color: root.routeColor(modelData.route)
                        opacity: 0.12
                    }

                    Row {
                        id: tabContent
                        z: 1
                        anchors.centerIn: parent
                        width: parent.width - VfTheme.dp(16)
                        spacing: VfTheme.dp(6)
                        opacity: (tabItem.active ? 1 : (tabItem.hovered ? 0.95 : 0.72)) * (tabItem.fstate.enabled ? 1 : 0.45) * (root.guidePickActive && !root.isTourTab(modelData.route) ? 0.4 : 1)

                        VfAppIcon {
                            route: modelData.route
                            size: VfTheme.dp(17)
                            color: tabItem.active
                                ? root.routeColor(modelData.route)
                                : (tabItem.hovered
                                    ? root.routeColor(modelData.route)
                                    : (VfTheme.dark ? "#7094BE" : "#4A6080"))
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id: tabLabel
                            text: root.cleanLabel(modelData.label).toUpperCase()
                            color: tabItem.active
                                ? (VfTheme.dark ? "#EAF2FF" : "#0F172A")
                                : (tabItem.hovered
                                    ? (VfTheme.dark ? "#CBD5E1" : "#1E293B")
                                    : (VfTheme.dark ? "#94A3B8" : "#334155"))
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                            font.weight: tabItem.active ? Font.Black : VfTheme.weightStrong
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            maximumLineCount: 1
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    TabBadge {
                        z: 10
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: VfTheme.dp(0)
                        anchors.rightMargin: VfTheme.dp(2)
                        label: String(tabItem.fstate.badge || "")
                    }

                    // Guide-pick pulse — draws attention to tabs that have a tour.
                    Rectangle {
                        anchors.fill: parent
                        z: 6
                        radius: parent.radius
                        color: "transparent"
                        border.width: 2
                        border.color: root.routeColor(modelData.route)
                        visible: root.isTourTab(modelData.route)
                        SequentialAnimation on opacity {
                            running: root.isTourTab(modelData.route) && VfTheme.motion
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 0.3; duration: 620; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 0.3; to: 1.0; duration: 620; easing.type: Easing.InOutQuad }
                        }
                    }

                    MouseArea {
                        id: tabMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: tabItem.fstate.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                        onClicked: {
                            if (root.isTourTab(modelData.route)) {
                                root.guidePicked(modelData.route)
                                return
                            }
                            if (!tabItem.fstate.enabled)
                                root.tabBlocked(modelData.route, String(tabItem.fstate.message || ""))
                            else
                                root.routeSelected(modelData.route)
                        }
                    }
                }
            }
        }
    }

    Flow {
        id: wrappedTabs
        anchors.fill: parent
        anchors.leftMargin: VfTheme.dp(12)
        anchors.rightMargin: VfTheme.dp(12)
        anchors.topMargin: VfTheme.dp(8)
        anchors.bottomMargin: VfTheme.dp(8)
        visible: root.wrapTabs
        spacing: VfTheme.dp(6)

        Repeater {
            model: root.navItems

            Rectangle {
                id: wrappedTabItem

                property bool active: root.activeRoute === modelData.route
                property bool hovered: wrappedTabMouse.containsMouse
                property var fstate: root.featureStateFor(modelData.route)

                width: Math.max(90, Math.min(162, wrappedTabContent.implicitWidth + VfTheme.dp(26)))
                height: VfTheme.dp(30)
                radius: VfTheme.dp(7)
                color: active ? root.activeFill : (hovered ? root.inactiveHoverFill : root.inactiveFill)
                opacity: 1
                border.width: 0
                border.color: "transparent"

                Rectangle {
                    visible: wrappedTabItem.active
                    z: 0
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: parent.height
                    radius: parent.radius
                    color: root.routeColor(modelData.route)
                    opacity: 0.12
                }

                Row {
                    id: wrappedTabContent
                    z: 1
                    anchors.centerIn: parent
                    width: parent.width - VfTheme.dp(14)
                    spacing: VfTheme.dp(5)
                    opacity: (wrappedTabItem.active ? 1 : (wrappedTabItem.hovered ? 0.95 : 0.72)) * (wrappedTabItem.fstate.enabled ? 1 : 0.45) * (root.guidePickActive && !root.isTourTab(modelData.route) ? 0.4 : 1)

                    VfAppIcon {
                        route: modelData.route
                        size: VfTheme.dp(16)
                        color: wrappedTabItem.active
                            ? root.routeColor(modelData.route)
                            : (wrappedTabItem.hovered
                                ? root.routeColor(modelData.route)
                                : (VfTheme.dark ? "#7094BE" : "#4A6080"))
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        id: wrappedTabLabel
                        text: root.cleanLabel(modelData.label).toUpperCase()
                        color: wrappedTabItem.active
                            ? (VfTheme.dark ? "#EAF2FF" : "#0F172A")
                            : (wrappedTabItem.hovered
                                ? (VfTheme.dark ? "#CBD5E1" : "#1E293B")
                                : (VfTheme.dark ? "#94A3B8" : "#334155"))
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: wrappedTabItem.active ? Font.Black : VfTheme.weightStrong
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        maximumLineCount: 1
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                TabBadge {
                    z: 10
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: VfTheme.dp(0)
                    anchors.rightMargin: VfTheme.dp(2)
                    label: String(wrappedTabItem.fstate.badge || "")
                }

                Rectangle {
                    anchors.fill: parent
                    z: 6
                    radius: parent.radius
                    color: "transparent"
                    border.width: 2
                    border.color: root.routeColor(modelData.route)
                    visible: root.isTourTab(modelData.route)
                    SequentialAnimation on opacity {
                        running: root.isTourTab(modelData.route) && VfTheme.motion
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.3; duration: 620; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 0.3; to: 1.0; duration: 620; easing.type: Easing.InOutQuad }
                    }
                }

                MouseArea {
                    id: wrappedTabMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: wrappedTabItem.fstate.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: {
                        if (root.isTourTab(modelData.route)) {
                            root.guidePicked(modelData.route)
                            return
                        }
                        if (!wrappedTabItem.fstate.enabled)
                            root.tabBlocked(modelData.route, String(wrappedTabItem.fstate.message || ""))
                        else
                            root.routeSelected(modelData.route)
                    }
                }
            }
        }
    }
}
