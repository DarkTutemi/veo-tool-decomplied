pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: root
    property int selectedAction: 0
    property string previewBatchId: ""
    property int previewTotal: 0
    property string previewRisk: "low"
    readonly property var actions: [
        { "title": "Kiểm tra cache", "operation": "cache.inspect", "detail": "Đo dung lượng cache của nhóm browser mà không thay đổi dữ liệu.", "icon": "dashboard", "tone": Theme.info },
        { "title": "Dọn cache", "operation": "cache.clean", "detail": "Xóa cache dùng một lần, giữ nguyên cookie và hồ sơ đăng nhập.", "icon": "automation", "tone": Theme.warning },
        { "title": "Đóng browser", "operation": "close", "detail": "Đóng có kiểm soát các browser đang chạy trong phạm vi đã chọn.", "icon": "studio", "tone": Theme.accent },
        { "title": "Sửa hồ sơ", "operation": "repair", "detail": "Kiểm tra và sửa layout, metadata hồ sơ browser theo template.", "icon": "channels", "tone": Theme.success }
    ]
    readonly property var selected: actions[selectedAction]

    function createPreview() {
        root.previewBatchId = ""
        const platform = scopeCombo.currentValue || ""
        controlPlane.callTool("browser.batch.preview", {
            "operation": root.selected.operation,
            "select": platform ? {"platform": platform} : {},
            "params": {},
            "idempotency_key": "qml-batch-" + root.selected.operation.replace(".", "-") + "-" + platform + "-" + Date.now()
        })
    }

    Connections {
        target: controlPlane
        function onActionFinished(toolName, ok, data, message) {
            if (!ok || toolName !== "browser.batch.preview") return
            const batch = data.batch || {}
            root.previewBatchId = batch.id || ""
            root.previewTotal = Number(batch.total || 0)
            root.previewRisk = batch.risk_level || "low"
        }
    }

    Dialog {
        id: executeDialog
        anchors.centerIn: parent
        modal: true
        width: 430
        title: "Thực thi batch browser"
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: controlPlane.callTool("browser.batch.execute", {"batch_id": root.previewBatchId})
        contentItem: Text { width: 380; text: "Thực thi “" + root.selected.title + "” trên " + root.previewTotal + " browser? Batch đã được đóng băng và sẽ ghi audit từng profile."; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 14; spacing: 10
        Panel {
            Layout.fillWidth: true; Layout.preferredHeight: 86
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 16
                ColumnLayout { spacing: 2
                    Text { text: "AUTOMATION CONTROL"; color: Theme.accent; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 1.1 }
                    Text { text: "Tự động hóa"; color: Theme.text; font.pixelSize: 22; font.weight: Font.Bold }
                    Text { text: "Batch browser, proxy, template và luồng chăm sóc có kiểm soát"; color: Theme.textFaint; font.pixelSize: 11 }
                }
                Item { Layout.fillWidth: true }
                Metric { value: controlPlane.browserModel.totalCount; label: "Browser sẵn sàng"; tone: Theme.success }
                Metric { value: root.actions.length; label: "Nhóm thao tác"; tone: Theme.accent }
                Metric { value: root.previewBatchId ? 1 : 0; label: "Batch đã preview"; tone: Theme.warning }
                AppButton { text: "Xem batch"; onClicked: controlPlane.callTool("browser.batch.list", {"limit": 20}) }
            }
        }

        RowLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 10
            Panel {
                Layout.fillWidth: true; Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 12
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout { spacing: 1
                            Text { text: "Công cụ vận hành"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold }
                            Text { text: "Chọn một thao tác để cấu hình và xem trước"; color: Theme.textFaint; font.pixelSize: 11 }
                        }
                        Item { Layout.fillWidth: true }
                        AppButton { text: "Làm mới"; onClicked: controlPlane.refreshDashboard() }
                    }
                    GridLayout {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        columns: 2; columnSpacing: 12; rowSpacing: 12
                        Repeater {
                            model: root.actions
                            delegate: ActionCard {
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true; Layout.fillHeight: true
                                action: modelData; selected: root.selectedAction === index
                                onClicked: {
                                    root.selectedAction = index
                                    root.previewBatchId = ""
                                }
                            }
                        }
                    }
                }
            }
            Panel {
                Layout.fillHeight: true; Layout.preferredWidth: 390; Layout.minimumWidth: 360; Layout.maximumWidth: 420
                ColumnLayout {
                    anchors.fill: parent; spacing: 0
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 58; Layout.leftMargin: 16; Layout.rightMargin: 14
                        Text { text: "Cấu hình thao tác"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold }
                        Item { Layout.fillWidth: true }
                        Rectangle { Layout.preferredWidth: 78; Layout.preferredHeight: 24; radius: 12; color: Theme.accentSoft
                            Text { anchors.centerIn: parent; text: "Preview"; color: Theme.accent; font.pixelSize: 11; font.weight: Font.DemiBold }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                    ColumnLayout {
                        Layout.fillWidth: true; Layout.margins: 18; spacing: 14
                        RowLayout {
                            Layout.fillWidth: true; spacing: 12
                            Rectangle { Layout.preferredWidth: 46; Layout.preferredHeight: 46; radius: 13; color: Theme.accentSoft
                                NavIcon { anchors.centerIn: parent; width: 22; height: 22; name: root.selected.icon; active: true }
                            }
                            ColumnLayout { Layout.fillWidth: true; spacing: 2
                                Text { text: root.selected.title; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold }
                                Text { text: "browser.batch.preview · " + root.selected.operation; color: Theme.accent; font.pixelSize: 11 }
                            }
                        }
                        Text { Layout.fillWidth: true; text: root.selected.detail; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap; lineHeight: 1.25 }
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                        ComboBox {
                            id: scopeCombo
                            Layout.fillWidth: true
                            model: [{text: "Tất cả browser", value: ""}, {text: "TikTok", value: "tiktok"}, {text: "YouTube", value: "youtube"}, {text: "Facebook", value: "facebook"}, {text: "LinkedIn", value: "linkedin"}]
                            textRole: "text"; valueRole: "value"
                            onActivated: root.previewBatchId = ""
                        }
                        Field { label: "Concurrency"; value: "4 worker" }
                        Field { label: "On failure"; value: "Dừng profile lỗi, tiếp tục phần còn lại" }
                        Field { label: "Audit"; value: "Bắt buộc" }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 72; radius: Theme.radiusMedium
                            color: Theme.base; border.width: 1; border.color: Theme.borderSoft
                            RowLayout { anchors.fill: parent; anchors.margins: 12; spacing: 10
                                Rectangle { Layout.preferredWidth: 8; Layout.preferredHeight: 8; radius: 4; color: Theme.warning }
                                Text { Layout.fillWidth: true; text: "Preview không thay đổi dữ liệu. Execute sẽ yêu cầu policy và approval phù hợp."; color: Theme.textFaint; font.pixelSize: 11; wrapMode: Text.Wrap }
                            }
                        }
                        AppButton { Layout.fillWidth: true; text: "Tạo bản xem trước"; primary: true; enabled: !controlPlane.actionBusy; onClicked: root.createPreview() }
                        AppButton { Layout.fillWidth: true; text: root.previewBatchId ? "Thực thi " + root.previewTotal + " browser" : "Chưa có preview"; enabled: Boolean(root.previewBatchId) && !controlPlane.actionBusy; onClicked: executeDialog.open() }
                    }
                    Item { Layout.fillHeight: true }
                }
            }
        }
    }

    component Metric: Rectangle {
        id: metric
        property int value; property string label; property color tone
        Layout.preferredWidth: 122; Layout.preferredHeight: 50; radius: Theme.radiusMedium
        color: Theme.elevated; border.width: 1; border.color: Theme.borderSoft
        ColumnLayout { anchors.centerIn: parent; spacing: 0
            Text { text: String(metric.value); color: metric.tone; font.pixelSize: 16; font.weight: Font.Bold; Layout.alignment: Qt.AlignHCenter }
            Text { text: metric.label; color: Theme.textFaint; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
        }
    }
    component ActionCard: Rectangle {
        id: card
        property var action
        property bool selected: false
        signal clicked()
        radius: Theme.radiusLarge
        color: selected ? Theme.accentSoft : (mouse.containsMouse ? Theme.hover : Theme.panel)
        border.width: 1; border.color: selected ? Theme.accent : Theme.borderSoft
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 9
            RowLayout { Layout.fillWidth: true
                Rectangle { Layout.preferredWidth: 42; Layout.preferredHeight: 42; radius: 12; color: Theme.elevated
                    NavIcon { anchors.centerIn: parent; width: 20; height: 20; name: card.action.icon; active: card.selected }
                }
                Item { Layout.fillWidth: true }
                UiIcon { name: "ui/chevron-right"; tone: card.selected ? Theme.accent : Theme.textFaint; iconSize: 18 }
            }
            Text { text: card.action.title; color: Theme.text; font.pixelSize: 14; font.weight: Font.Bold }
            Text { Layout.fillWidth: true; text: card.action.detail; color: Theme.textFaint; font.pixelSize: 11; wrapMode: Text.Wrap; lineHeight: 1.2 }
            Item { Layout.fillHeight: true }
            Text { text: card.action.operation; color: Theme.textMuted; font.pixelSize: 11 }
        }
        MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: card.clicked() }
    }
    component Field: RowLayout {
        id: field
        property string label; property string value
        Layout.fillWidth: true; spacing: 10
        Text { text: field.label; color: Theme.textFaint; font.pixelSize: 11 }
        Item { Layout.fillWidth: true }
        Text { text: field.value; color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold; Layout.maximumWidth: 250; elide: Text.ElideRight }
    }
}
