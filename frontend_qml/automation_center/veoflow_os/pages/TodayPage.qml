pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    objectName: "todayPage"
    Accessible.name: "Hôm nay"
    Accessible.role: Accessible.Pane

    property string activeSection: "overview"
    // qmllint disable unqualified
    readonly property var plane: controlPlane
    // qmllint enable unqualified
    readonly property var sections: [
        {
            "key": "overview",
            "label": "Công việc hôm nay",
            "icon": "semantic/check-circle",
            "description": "Tiến trình, hàng đợi và các kênh đang vận hành"
        },
        {
            "key": "attention",
            "label": "Cần xử lý",
            "icon": "semantic/alert-triangle",
            "description": "Phê duyệt, sự cố và kết quả cần kiểm tra"
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
        root.activeSection = route === "alerts" || route === "incident"
            || route === "incidents" ? "attention" : "overview"
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
            objectName: "todaySections"
            Layout.fillWidth: true
            sections: root.sections
            currentKey: root.activeSection
            onSectionRequested: function(key) { root.activeSection = key }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Loader {
                objectName: "todayOverviewLoader"
                anchors.fill: parent
                active: root.activeSection === "overview" || item !== null
                asynchronous: true
                visible: root.activeSection === "overview" && status === Loader.Ready
                source: "CoordinationPage.qml"
                onLoaded: item.embeddedMode = true
            }

            Loader {
                objectName: "todayAttentionLoader"
                anchors.fill: parent
                active: root.activeSection === "attention" || item !== null
                asynchronous: true
                visible: root.activeSection === "attention" && status === Loader.Ready
                source: "AlertsPage.qml"
                onLoaded: item.embeddedMode = true
            }
        }
    }
}
