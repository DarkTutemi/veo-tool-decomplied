pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "contentHeader"
    property var headerData: ({})
    property bool canWrite: false
    property bool createBusy: false
    property bool importBusy: false
    signal createRequested()
    signal importRequested()

    radius: 0
    color: "transparent"
    border.width: 0
    border.color: "transparent"
    Accessible.name: "Tổng quan kho nội dung"
    Accessible.role: Accessible.Pane

    readonly property var actions: root.headerData.actions || ({})
    readonly property bool canCreate: root.canWrite
        && Boolean((root.actions.create || {}).enabled)
        && !root.createBusy
    readonly property bool canImport: root.canWrite
        && Boolean((root.actions.import || {}).enabled)
        && !root.importBusy

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 28
        anchors.rightMargin: 0
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 310
            spacing: 2
            Text {
                text: "Nội dung"
                color: Theme.text
                font.pixelSize: Theme.fontPageTitle
                font.weight: Font.Bold
            }
            Text {
                Layout.fillWidth: true
                text: "Lập kế hoạch, quản lý tài nguyên và chuẩn bị gói sản xuất theo từng kênh"
                color: Theme.textFaint
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        Rectangle {
            objectName: "contentMetricGroup"
            Layout.preferredWidth: 538
            Layout.minimumWidth: 500
            Layout.preferredHeight: 56
            radius: Theme.radiusMedium
            color: Theme.panel
            border.width: 1
            border.color: Theme.border

            RowLayout {
                anchors.fill: parent
                spacing: 0

                MetricTile {
                    metricKey: "content_total"
                    value: Number(root.headerData.content_total || 0)
                    label: "Nội dung"
                    iconName: "semantic/video"
                    tone: Theme.textMuted
                }
                MetricTile {
                    metricKey: "preparing"
                    value: Number(root.headerData.preparing || 0)
                    label: "Đang chuẩn bị"
                    iconName: "semantic/workflow"
                    tone: Theme.warning
                }
                MetricTile {
                    metricKey: "waiting_production"
                    value: Number(root.headerData.waiting_production || 0)
                    label: "Chờ sản xuất"
                    iconName: "semantic/check-circle"
                    tone: Theme.info
                }
                MetricTile {
                    metricKey: "needs_attention"
                    value: Number(root.headerData.needs_attention || 0)
                    label: "Cần xử lý"
                    iconName: "semantic/alert-triangle"
                    tone: Theme.danger
                    showDivider: false
                }
            }
        }

        AppButton {
            objectName: "contentCreateButton"
            Layout.preferredWidth: 150
            Layout.preferredHeight: 56
            Layout.minimumHeight: 56
            Layout.maximumHeight: 56
            text: root.createBusy ? "Đang tạo..." : "Tạo nội dung"
            leadingIcon: "ui/plus"
            iconSize: 18
            primary: true
            enabled: root.canCreate
            Accessible.name: "Tạo nội dung mới"
            onClicked: root.createRequested()
        }
        AppButton {
            objectName: "contentImportButton"
            Layout.preferredWidth: 170
            Layout.preferredHeight: 56
            Layout.minimumHeight: 56
            Layout.maximumHeight: 56
            text: root.importBusy ? "Đang nhập..." : "Nhập tài nguyên"
            leadingIcon: "semantic/upload-cloud"
            iconSize: 18
            enabled: root.canImport
            Accessible.name: "Nhập tài nguyên cục bộ"
            onClicked: root.importRequested()
        }
        AppButton {
            objectName: "contentImportChevronButton"
            Layout.preferredHeight: 56
            Layout.minimumHeight: 56
            Layout.maximumHeight: 56
            text: ""
            leadingIcon: "ui/chevron-down"
            implicitWidth: 44
            enabled: root.canImport
            availabilityReason: enabled ? "" : "Không có quyền nhập tài nguyên"
            Accessible.name: "Tùy chọn nhập tài nguyên"
            onClicked: importMenu.open()
        }
    }

    Menu {
        id: importMenu
        objectName: "contentImportMenu"
        MenuItem {
            objectName: "contentImportLocalOption"
            text: "File cục bộ"
            enabled: root.canImport
            Accessible.name: "Nhập file cục bộ"
            onTriggered: root.importRequested()
        }
        background: Rectangle {
            radius: Theme.radiusSmall
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }

    component MetricTile: Item {
        id: metric
        property string metricKey: ""
        property int value: 0
        property string label: ""
        property string iconName: "semantic/info"
        property color tone: Theme.accent
        property bool showDivider: true
        Layout.fillWidth: true
        Layout.preferredHeight: 54
        Accessible.name: metric.label + ": " + metric.value
        Accessible.role: Accessible.StaticText

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 10
            spacing: 8
            Rectangle {
                objectName: "contentMetricIcon_" + metric.metricKey
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 7
                color: Qt.rgba(metric.tone.r, metric.tone.g, metric.tone.b, 0.12)
                UiIcon {
                    anchors.centerIn: parent
                    name: metric.iconName
                    tone: metric.tone
                    iconSize: 16
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Text {
                    text: String(metric.value)
                    color: Theme.text
                    font.pixelSize: 16
                    font.weight: Font.Bold
                }
                Text {
                    Layout.fillWidth: true
                    text: metric.label
                    color: Theme.textFaint
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }
        }
        Rectangle {
            visible: metric.showDivider
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: 32
            color: Theme.borderSoft
        }
    }
}
