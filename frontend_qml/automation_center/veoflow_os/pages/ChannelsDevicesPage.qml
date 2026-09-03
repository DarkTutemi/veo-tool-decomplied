pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    objectName: "channelsDevicesPage"
    Accessible.name: "Kênh và thiết bị"
    Accessible.role: Accessible.Pane

    property string activeSection: "browser"
    // qmllint disable unqualified
    readonly property var plane: controlPlane
    // qmllint enable unqualified
    readonly property var sections: [
        {
            "key": "browser",
            "label": "Kênh & Browser",
            "icon": "semantic/channels",
            "description": "Tài khoản, phiên đăng nhập và browser profile"
        },
        {
            "key": "devices",
            "label": "Thiết bị Android",
            "icon": "ui/smartphone",
            "description": "Phone Farm, lease và ứng dụng thực thi"
        }
    ]

    function present(value) {
        return value !== null && value !== undefined
    }

    function map(value) {
        return root.present(value) ? value : ({})
    }

    function syncSelection() {
        const selection = root.map(root.plane.entitySelection.current)
        const route = String(selection.route || "")
        const context = root.map(selection.context)
        const subview = String(context.subview || "")
        root.activeSection = route === "phone_farm" || subview === "devices"
            ? "devices" : "browser"
    }

    Connections {
        target: root.plane.entitySelection
        function onSelectionChanged() { root.syncSelection() }
    }


    Component.onCompleted: root.syncSelection()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.pageGutter
        spacing: Theme.space3

        WorkspaceSectionTabs {
            objectName: "channelsDevicesSections"
            Layout.fillWidth: true
            sections: root.sections
            currentKey: root.activeSection
            onSectionRequested: function(key) { root.activeSection = key }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Loader {
                objectName: "channelsBrowserLoader"
                anchors.fill: parent
                active: root.activeSection === "browser" || item !== null
                asynchronous: true
                visible: root.activeSection === "browser" && status === Loader.Ready
                source: "ChannelsPage.qml"
                onLoaded: item.embeddedMode = true
            }

            Loader {
                objectName: "channelsDevicesLoader"
                anchors.fill: parent
                active: root.activeSection === "devices" || item !== null
                asynchronous: true
                visible: root.activeSection === "devices" && status === Loader.Ready
                source: "PhoneFarmPage.qml"
                onLoaded: item.embeddedMode = true
            }
        }
    }
}
