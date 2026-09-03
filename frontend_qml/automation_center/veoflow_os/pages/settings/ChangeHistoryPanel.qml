pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Panel {
    id: root
    objectName: "changeHistoryPanel"
    property var historyModel: null
    property var viewAllAction: ({})
    property var controlPlaneBridge: null
    signal actionRequested(var action)
    Accessible.name: "Lịch sử thay đổi cài đặt"
    Accessible.role: Accessible.Table
    implicitHeight: 184

    function timeText(value) {
        const raw = String(value || "")
        if (!raw) return "—"
        const parsed = new Date(raw)
        return isNaN(parsed.getTime()) ? raw
            : Qt.formatDateTime(parsed, "dd/MM/yyyy HH:mm")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 5
        Text { text: "Lịch sử thay đổi"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }

        Text {
            visible: !root.historyModel || root.historyModel.count === 0
            Layout.fillWidth: true
            text: "Chưa có lịch sử từ backend"
            color: Theme.warning
            font.pixelSize: 11
        }

        Repeater {
            model: root.historyModel
            delegate: RowLayout {
                id: historyRow
                required property int index
                required property string change_id
                required property string created_at
                required property var actor_id
                required property int from_version
                required property int to_version
                required property var changes
                objectName: "settingsHistoryRow_" + historyRow.change_id
                visible: index < 3
                Layout.preferredHeight: visible ? 30 : 0
                Layout.fillWidth: true
                spacing: 8
                Accessible.name: String(created_at || "Không rõ thời gian")
                    + ", " + String(actor_id || "không rõ người dùng")
                    + ", phiên bản " + String(from_version)
                    + " sang " + String(to_version)
                Accessible.role: Accessible.Row
                Text { Layout.preferredWidth: 128; text: root.timeText(parent.created_at); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                Text { Layout.preferredWidth: 100; text: String(parent.actor_id || "—"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                Text {
                    Layout.fillWidth: true
                    text: {
                        const changes = parent.changes || []
                        return changes.length > 0 ? String(changes[0].key || "Thay đổi cài đặt") : "Không có chi tiết"
                    }
                    color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight
                }
                Text { text: String(parent.from_version) + " → " + String(parent.to_version); color: Theme.textFaint; font.pixelSize: 11 }
            }
        }

        Item { Layout.fillHeight: true }
        AppButton {
            objectName: "viewAllSettingsHistoryButton"
            Layout.alignment: Qt.AlignHCenter
            text: String(root.viewAllAction.label || "Xem tất cả lịch sử")
            subtle: true
            activeFocusOnTab: true
            enabled: root.viewAllAction.available === true
            availabilityReason: enabled ? "" : String(
                root.viewAllAction.reason_code || "Lịch sử cài đặt không khả dụng")
            Accessible.name: text
            Accessible.description: enabled
                ? "Tải projection lịch sử cài đặt đầy đủ"
                : availabilityReason
            onClicked: root.actionRequested(root.viewAllAction)
        }
    }
}
