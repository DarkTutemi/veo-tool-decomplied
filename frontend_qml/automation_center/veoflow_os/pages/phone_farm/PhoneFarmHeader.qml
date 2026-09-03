pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "phoneFarmHeader"
    property var counts: ({})
    property bool canOperate: false
    signal addDeviceRequested()
    signal bulkRequested()
    signal bulkMenuRequested()
    Accessible.name: "Phone Farm và chỉ số đội thiết bị"
    Accessible.role: Accessible.Pane
    implicitHeight: 78

    function metricText(key) {
        const value = (root.counts || {})[key]
        return value === undefined || value === null ? "—" : String(value)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 18
            Layout.rightMargin: 14
            spacing: 10

            ColumnLayout {
                Layout.preferredWidth: 260
                spacing: 2
                Text { text: "Phone Farm"; color: Theme.text; font.pixelSize: 25; font.weight: Font.Bold }
                Text { text: "Điều phối đội thiết bị Android qua lease và lệnh semantic"; color: Theme.textFaint; font.pixelSize: 11 }
            }

            Repeater {
                model: [
                    {"key": "total", "label": "thiết bị", "name": "phoneFarmKpiTotal", "tone": Theme.info, "icon": "semantic/smartphone"},
                    {"key": "online", "label": "trực tuyến", "name": "phoneFarmKpiOnline", "tone": Theme.success, "icon": "semantic/check-circle"},
                    {"key": "running", "label": "đang chạy", "name": "phoneFarmKpiRunning", "tone": Theme.accent, "icon": "ui/play"},
                    {"key": "attention", "label": "cần xử lý", "name": "phoneFarmKpiAttention", "tone": Theme.warning, "icon": "semantic/alert-triangle"}
                ]
                delegate: Rectangle {
                    id: kpiCard
                    required property var modelData
                    objectName: String(modelData.name)
                    Layout.minimumWidth: 118
                    Layout.preferredWidth: 118
                    Layout.minimumHeight: 54
                    Layout.preferredHeight: 54
                    radius: Theme.radiusSmall
                    color: Theme.elevated
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.name: root.metricText(modelData.key) + " " + String(modelData.label)
                    Accessible.role: Accessible.StaticText
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        UiIcon {
                            objectName: String(kpiCard.modelData.name) + "Icon"
                            name: String(kpiCard.modelData.icon)
                            tone: kpiCard.modelData.tone
                            iconSize: 17
                        }
                        ColumnLayout {
                            spacing: 0
                            Text { text: root.metricText(kpiCard.modelData.key); color: Theme.text; font.pixelSize: 20; font.weight: Font.Bold }
                            Text { text: String(kpiCard.modelData.label); color: Theme.textFaint; font.pixelSize: 11 }
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }
            AppButton {
                objectName: "phoneFarmAddDeviceButton"
                text: "Thêm thiết bị"
                leadingIcon: "ui/plus"
                primary: true
                activeFocusOnTab: true
                enabled: root.canOperate
                Accessible.name: text
                Accessible.description: "Mở quy trình enrollment; không gửi raw ADB"
                onClicked: root.addDeviceRequested()
            }
            RowLayout {
                spacing: 2
                AppButton {
                    objectName: "phoneFarmBulkButton"
                    text: "Thao tác hàng loạt"
                    leadingIcon: "ui/columns-3"
                    activeFocusOnTab: true
                    enabled: root.canOperate
                    Accessible.name: text
                    Accessible.description: "Mở preview batch semantic"
                    onClicked: root.bulkRequested()
                }
                Foundation.IconButton {
                    objectName: "phoneFarmBulkChevronButton"
                    text: ""
                    iconName: "ui/chevron-down"
                    accessibleName: "Mở tùy chọn thao tác hàng loạt"
                    activeFocusOnTab: true
                    enabled: root.canOperate
                    onClicked: root.bulkMenuRequested()
                }
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
    }
}
