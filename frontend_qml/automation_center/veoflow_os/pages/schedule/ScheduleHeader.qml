pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Panel {
    id: root
    objectName: "scheduleHeader"
    property var headerData: ({})
    property string activeTab: "calendar"
    property bool canWrite: false
    property bool canAutoAllocate: false
    property string autoAllocateReason: "Chưa có backlog sẵn sàng hoặc capacity policy khả dụng"
    property bool allocationBusy: false
    property string bannerMessage: ""
    signal tabRequested(string tabKey)
    signal createRequested()
    signal autoAllocateRequested()
    Accessible.name: "Tiêu đề, chỉ số và tab lịch trình"
    Accessible.role: Accessible.Pane

    readonly property var today: root.headerData.today || ({})
    readonly property var waiting: root.headerData.waiting || ({})
    readonly property var conflicts: root.headerData.conflicts || ({})
    readonly property var onTime: root.headerData.on_time || ({})

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 14
        anchors.topMargin: 10
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            spacing: 12
            ColumnLayout {
                Layout.preferredWidth: 310
                spacing: 1
                Text {
                    text: "Lịch trình"
                    color: Theme.text
                    font.pixelSize: Theme.fontPageTitle
                    font.weight: Font.Bold
                }
                Text {
                    text: root.bannerMessage || "Lên lịch sản xuất và xuất bản trên mọi kênh"
                    color: root.bannerMessage ? Theme.warning : Theme.textFaint
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
            Rectangle {
                Layout.preferredWidth: 412
                Layout.preferredHeight: 50
                radius: Theme.radiusMedium
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    Metric {
                        value: String(root.today.value !== undefined ? root.today.value : "—")
                        label: "Hôm nay"
                        tone: Theme.success
                    }
                    Separator {}
                    Metric {
                        value: String(root.waiting.value !== undefined ? root.waiting.value : "—")
                        label: "Đang chờ"
                        tone: Theme.warning
                    }
                    Separator {}
                    Metric {
                        value: String(root.conflicts.value !== undefined ? root.conflicts.value : "—")
                        label: "Xung đột"
                        tone: Theme.danger
                    }
                    Separator {}
                    Metric {
                        value: root.onTime.available
                            ? Math.round(Number(root.onTime.value_percent || 0)) + "%" : "—"
                        label: "Đúng giờ"
                        tone: Theme.info
                    }
                }
            }
            Item { Layout.fillWidth: true }
            AppButton {
                objectName: "scheduleCreateButton"
                text: "+  Lên lịch"
                primary: true
                enabled: root.canWrite
                activeFocusOnTab: true
                Accessible.name: text
                Accessible.description: enabled
                    ? "Mở biểu mẫu tạo lịch; không tự duyệt hoặc xuất bản"
                    : "Thiếu quyền workspace.write"
                onClicked: root.createRequested()
            }
            AppButton {
                objectName: "scheduleAutoAllocateButton"
                text: root.allocationBusy ? "Đang tính…" : "Tự động phân bổ"
                enabled: root.canAutoAllocate && !root.allocationBusy
                activeFocusOnTab: true
                Accessible.name: text
                Accessible.description: enabled
                    ? "Yêu cầu server tính đề xuất; chưa tạo lịch cho tới khi xác nhận"
                    : root.autoAllocateReason
                onClicked: root.autoAllocateRequested()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 4
            Repeater {
                model: [
                    {"key": "calendar", "label": "Lịch xuất bản"},
                    {"key": "queue", "label": "Hàng đợi"},
                    {"key": "recurrence", "label": "Quy tắc định kỳ"},
                    {"key": "history", "label": "Lịch sử"}
                ]
                delegate: Rectangle {
                    id: tab
                    required property var modelData
                    objectName: "scheduleTab_" + String(tab.modelData.key)
                    Layout.preferredWidth: 126
                    Layout.fillHeight: true
                    color: root.activeTab === String(tab.modelData.key)
                        ? Theme.accentSoft : "transparent"
                    radius: Theme.radiusSmall
                    Accessible.name: String(tab.modelData.label)
                    Accessible.role: Accessible.PageTab
                    Accessible.focusable: true
                    activeFocusOnTab: true
                    Keys.onReturnPressed: root.tabRequested(String(tab.modelData.key))
                    Keys.onEnterPressed: root.tabRequested(String(tab.modelData.key))
                    Keys.onSpacePressed: root.tabRequested(String(tab.modelData.key))
                    Text {
                        anchors.centerIn: parent
                        text: String(tab.modelData.label)
                        color: root.activeTab === String(tab.modelData.key)
                            ? Theme.accent : Theme.textMuted
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                    Rectangle {
                        visible: root.activeTab === String(tab.modelData.key)
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 2
                        color: Theme.accent
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.tabRequested(String(tab.modelData.key))
                    }
                }
            }
            Item { Layout.fillWidth: true }
        }
    }

    component Metric: Item {
        id: metric
        property string value: "—"
        property string label: ""
        property color tone: Theme.text
        Layout.fillWidth: true
        Layout.fillHeight: true
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0
            Text { text: metric.value; color: metric.tone; font.pixelSize: 17; font.weight: Font.Bold; Layout.alignment: Qt.AlignHCenter }
            Text { text: metric.label; color: Theme.textFaint; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
        }
    }

    component Separator: Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 32
        color: Theme.borderSoft
    }
}
