pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: root
    property int selectedIndex: -1
    property string applyBatchId: ""
    property int applyCount: 0
    readonly property var selectedTemplate: selectedIndex >= 0 ? controlPlane.browserTemplateModel.get(selectedIndex) : ({})

    Connections {
        target: controlPlane.browserTemplateModel
        function onCountChanged() {
            if (controlPlane.browserTemplateModel.count === 0) root.selectedIndex = -1
            else if (root.selectedIndex < 0 || root.selectedIndex >= controlPlane.browserTemplateModel.count) root.selectedIndex = 0
        }
    }
    Connections {
        target: controlPlane
        function onActionFinished(toolName, ok, data, message) {
            if (toolName !== "browser.template.apply.preview" || !ok) return
            const batch = data.batch || {}
            root.applyBatchId = String(batch.id || "")
            root.applyCount = Number(batch.total || 0)
            if (root.applyBatchId) applyDialog.open()
        }
    }

    function openEditor(editing) {
        const value = editing ? root.selectedTemplate : {}
        templateId.text = String(value.templateId || "")
        templateName.text = String(value.name || "")
        templateDescription.text = String(value.description || "")
        templatePlatform.currentIndex = Math.max(0, templatePlatform.model.indexOf(String(value.platform || "youtube")))
        templateOs.currentIndex = Math.max(0, templateOs.model.indexOf(String(value.osName || "windows")))
        templateLocale.text = String(value.locale || "vi-VN")
        templateTimezone.text = String(value.timezoneName || "Asia/Bangkok")
        launchMode.currentIndex = String(value.launchMode || "headed") === "headless_new" ? 1 : 0
        muteAudio.checked = value.muteAudio === undefined ? true : Boolean(value.muteAudio)
        templateDefault.checked = Boolean(value.isDefault)
        editorDialog.open()
    }
    function saveTemplate() {
        const payload = {
            "name": templateName.text.trim(), "description": templateDescription.text.trim(),
            "platform": templatePlatform.currentText, "os": templateOs.currentText,
            "locale": templateLocale.text.trim(), "timezone": templateTimezone.text.trim(),
            "is_default": templateDefault.checked,
            "runtime_policy": {"launch_mode": launchMode.currentText, "mute_audio": muteAudio.checked,
                "block_notifications": blockNotifications.checked, "keep_background_active": keepBackground.checked,
                "max_runtime_minutes": 0, "startup_mode": "blank", "startup_url": null}
        }
        if (templateId.text) { payload.id = templateId.text; payload.expected_version = Number(root.selectedTemplate.version || 1) }
        controlPlane.callTool("browser.template.upsert", payload)
    }

    Dialog {
        id: editorDialog; anchors.centerIn: parent; modal: true; width: 590
        title: templateId.text ? "Cập nhật template" : "Tạo template browser"; standardButtons: Dialog.Save | Dialog.Cancel
        onAccepted: root.saveTemplate()
        contentItem: GridLayout { columns: 2; columnSpacing: 12; rowSpacing: 10
            TextField { id: templateId; visible: false }
            TextField { id: templateName; Layout.columnSpan: 2; Layout.fillWidth: true; placeholderText: "Tên template" }
            TextArea { id: templateDescription; Layout.columnSpan: 2; Layout.fillWidth: true; Layout.preferredHeight: 66; placeholderText: "Mục đích vận hành"; wrapMode: TextEdit.Wrap }
            ComboBox { id: templatePlatform; Layout.fillWidth: true; model: ["youtube", "tiktok", "facebook", "linkedin", "generic"] }
            ComboBox { id: templateOs; Layout.fillWidth: true; model: ["windows", "macos", "linux"] }
            TextField { id: templateLocale; Layout.fillWidth: true; placeholderText: "vi-VN" }
            TextField { id: templateTimezone; Layout.fillWidth: true; placeholderText: "Asia/Bangkok" }
            ComboBox { id: launchMode; Layout.fillWidth: true; model: ["headed", "headless_new"] }
            CheckBox { id: muteAudio; text: "Tắt âm thanh"; checked: true }
            CheckBox { id: blockNotifications; text: "Chặn notification"; checked: true }
            CheckBox { id: keepBackground; text: "Giữ tác vụ nền hoạt động" }
            CheckBox { id: templateDefault; Layout.columnSpan: 2; text: "Dùng làm template mặc định" }
        }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }
    Dialog {
        id: applyDialog; anchors.centerIn: parent; modal: true; width: 450
        title: "Áp dụng template"; standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: controlPlane.callTool("browser.template.apply.execute", {"batch_id": root.applyBatchId})
        contentItem: Text { width: 400; text: "Áp dụng snapshot template v" + root.selectedTemplate.version + " cho " + root.applyCount + " browser đang đóng?"; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }

    Panel { anchors.fill: parent
        ColumnLayout { anchors.fill: parent; spacing: 0
            RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 64; Layout.leftMargin: 18; Layout.rightMargin: 14
                ColumnLayout { spacing: 2
                    Text { text: "Template browser"; color: Theme.text; font.pixelSize: 16; font.weight: Font.Bold }
                    Text { text: "Identity mặc định và runtime policy được version hóa"; color: Theme.textFaint; font.pixelSize: 11 }
                }
                Item { Layout.fillWidth: true }
                AppButton { text: "+  Tạo template"; primary: true; onClicked: root.openEditor(false) }
            }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
            ListView { id: templateList; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; reuseItems: true; model: controlPlane.browserTemplateModel
                delegate: Rectangle {
                    id: row
                    required property int index; required property string templateId; required property string name; required property string description
                    required property bool isDefault; required property string templateStatus; required property int version; required property string platform
                    required property string osName; required property string locale; required property string timezoneName; required property int profileCount
                    required property string launchMode; required property bool muteAudio
                    width: templateList.width; height: 76
                    color: root.selectedIndex === index ? Theme.accentSoft : (mouse.containsMouse ? Theme.hover : "transparent")
                    border.width: 1; border.color: root.selectedIndex === index ? Theme.accent : Theme.borderSoft
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 18; anchors.rightMargin: 16; spacing: 12
                        ColumnLayout { Layout.preferredWidth: 260; spacing: 2
                            RowLayout { Text { text: row.name; color: Theme.text; font.pixelSize: 12; font.weight: Font.Bold } Text { text: row.isDefault ? "DEFAULT" : ""; color: Theme.accent; font.pixelSize: 11; font.weight: Font.Bold } }
                            Text { text: row.description || "Không có mô tả"; color: Theme.textFaint; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                        }
                        Text { text: row.platform.toUpperCase(); color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.Bold; Layout.preferredWidth: 80 }
                        Text { text: row.osName + " · " + row.locale; color: Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 140 }
                        Text { text: row.launchMode + (row.muteAudio ? " · muted" : ""); color: Theme.textMuted; font.pixelSize: 11; Layout.fillWidth: true }
                        Text { text: row.profileCount + " browser"; color: Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 90 }
                        Text { text: "v" + row.version; color: Theme.accent; font.pixelSize: 11; font.weight: Font.Bold; Layout.preferredWidth: 42 }
                    }
                    MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedIndex = row.index }
                }
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            }
            RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 54; Layout.leftMargin: 14; Layout.rightMargin: 14
                Text { text: root.selectedTemplate.templateId ? "Đã chọn: " + root.selectedTemplate.name + " · v" + root.selectedTemplate.version : "Chọn template để quản lý"; color: Theme.textFaint; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
                AppButton { text: "Chỉnh sửa"; enabled: Boolean(root.selectedTemplate.templateId); onClicked: root.openEditor(true) }
                AppButton { text: "Preview áp dụng"; primary: true; enabled: Boolean(root.selectedTemplate.templateId); onClicked: controlPlane.callTool("browser.template.apply.preview", {"template_id": root.selectedTemplate.templateId, "expected_template_version": root.selectedTemplate.version, "select": {}, "idempotency_key": "qml-template-" + root.selectedTemplate.templateId + "-v" + root.selectedTemplate.version + "-" + Date.now()}) }
            }
        }
    }
}
