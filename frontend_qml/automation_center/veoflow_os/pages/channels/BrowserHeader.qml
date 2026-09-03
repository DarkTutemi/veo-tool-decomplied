pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "browserHeader"
    property var counts: ({})
    property bool canWrite: false
    property int selectionCount: 0
    signal addRequested()
    signal bulkRequested()
    signal bulkMenuRequested()
    Accessible.name: "Tổng quan Browser và hành động"
    Accessible.role: Accessible.Pane

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 14
        spacing: 12

        ColumnLayout {
            Layout.preferredWidth: 330
            spacing: 3
            Text {
                text: "Kênh & Browser"
                color: Theme.text
                font.pixelSize: Theme.fontPageTitle
                font.weight: Font.Bold
            }
            Text {
                text: "Danh tính bền vững, phiên đăng nhập và sức khỏe phát hành"
                color: Theme.textFaint
                font.pixelSize: 11
            }
        }

        HeaderMetric {
            objectName: "browserKpiBrowsers"
            label: "Browser"
            value: root.exactCount(root.counts.browsers)
            tone: Theme.accent
            iconName: "product/chrome"
        }
        HeaderMetric {
            objectName: "browserKpiAccounts"
            label: "Tài khoản"
            value: root.exactCount(root.counts.accounts)
            tone: Theme.info
            iconName: "device/account-link"
        }
        HeaderMetric {
            objectName: "browserKpiChannels"
            label: "Kênh"
            value: root.exactCount(root.counts.channels)
            tone: Theme.success
            iconName: "semantic/video"
        }
        HeaderMetric {
            objectName: "browserKpiAttention"
            label: "Cần xử lý"
            value: root.exactCount(root.counts.attention)
            tone: Theme.warning
            iconName: "semantic/alert-triangle"
        }

        Item { Layout.fillWidth: true }

        AppButton {
            objectName: "browserAddButton"
            text: "Thêm Browser"
            leadingIcon: "ui/plus"
            primary: true
            activeFocusOnTab: true
            enabled: root.canWrite
            Accessible.name: text
            Accessible.description: enabled
                ? "Mở trình tạo hoặc nhập browser có kiểm soát"
                : "Cần quyền browser.write"
            onClicked: root.addRequested()
        }
        AppButton {
            objectName: "browserBulkButton"
            text: root.selectionCount > 0
                ? "Thao tác hàng loạt · " + String(root.selectionCount)
                : "Thao tác hàng loạt"
            leadingIcon: "ui/columns-3"
            activeFocusOnTab: true
            enabled: root.canWrite && root.selectionCount > 0
            Accessible.name: text
            Accessible.description: enabled
                ? "Mở trình preview thao tác trên các browser đã chọn"
                : "Chọn ít nhất một browser và cần quyền browser.write"
            onClicked: root.bulkRequested()
        }
        Foundation.IconButton {
            objectName: "browserBulkChevron"
            iconName: "ui/chevron-down"
            text: ""
            accessibleName: "Mở menu thao tác hàng loạt"
            activeFocusOnTab: true
            enabled: root.canWrite && root.selectionCount > 0
            Accessible.description: enabled
                ? "Mọi thao tác sẽ qua preview server"
                : "Chọn ít nhất một browser và cần quyền browser.write"
            onClicked: root.bulkMenuRequested()
        }
    }

    function exactCount(value) {
        return value === undefined || value === null ? "—" : String(value)
    }

    component HeaderMetric: Rectangle {
        id: metric
        required property string label
        required property string value
        required property color tone
        required property string iconName
        Layout.preferredWidth: 116
        Layout.preferredHeight: 56
        Layout.alignment: Qt.AlignVCenter
        radius: Theme.radiusMedium
        color: Theme.elevated
        border.width: 1
        border.color: Theme.borderSoft
        Accessible.name: metric.label + ": " + metric.value
        Accessible.role: Accessible.StaticText
        RowLayout {
            anchors.fill: parent
            anchors.margins: 11
            spacing: 9
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 8
                color: Qt.rgba(metric.tone.r, metric.tone.g, metric.tone.b, 0.14)
                UiIcon {
                    anchors.centerIn: parent
                    name: metric.iconName
                    tone: metric.tone
                    iconSize: 17
                    preserveColors: metric.iconName === "product/chrome"
                }
            }
            ColumnLayout {
                spacing: 0
                Text {
                    objectName: metric.objectName + "_value"
                    text: metric.value
                    color: Theme.text
                    font.pixelSize: 22
                    font.weight: Font.Bold
                }
                Text {
                    objectName: metric.objectName + "_label"
                    text: metric.label
                    color: Theme.textMuted
                    font.pixelSize: 11
                }
            }
        }
    }
}
