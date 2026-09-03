import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "GeminiApiDialog"

    property string statusIcon: ""
    property string statusText: (void i18n.revision, i18n.t("gemini_api.creating_session", "Đang tạo phiên cấu hình..."))
    property string subText: (void i18n.revision, i18n.t("gemini_api.browser_auto_open", "Trình duyệt sẽ mở tự động"))
    property string configUrl: ""
    property bool configReady: false

    signal configRequested()
    signal openExternalRequested(string url)
    signal configDone()

    function openDialog() {
        root.statusIcon = ""
        root.statusText = (void i18n.revision, i18n.t("gemini_api.creating_session", "Đang tạo phiên cấu hình..."))
        root.subText = (void i18n.revision, i18n.t("gemini_api.browser_auto_open", "Trình duyệt sẽ mở tự động"))
        root.configUrl = ""
        root.configReady = false
        root.open()
        root.configRequested()
    }

    function applyConfigResult(result) {
        var payload = result || ({})
        var url = String(payload.config_url || payload.checkout_url || payload.url || "")
        if (payload.ok && url.length > 0) {
            root.configUrl = url
            root.configReady = true
            root.statusIcon = "globe-with-meridians"
            root.statusText = (void i18n.revision, i18n.t("gemini_api.browser_opened", "Đã mở trình duyệt — cấu hình Gemini API Key trên web"))
            root.subText = (void i18n.revision, i18n.t("gemini_api.finish_instruction", "Sau khi cấu hình xong, nhấn nút bên dưới"))
            root.openExternalRequested(url)
            return
        }

        root.configReady = false
        root.statusIcon = "cross-mark"
        root.statusText = (void i18n.revision, i18n.t("gemini_api.error_prefix", "Lỗi: %1")).arg(
            String(payload.message || payload.error || "Client not configured")
        )
        root.subText = (void i18n.revision, i18n.t("gemini_api.try_again_later", "Vui lòng thử lại sau"))
    }

    function reopenBrowser() {
        if (root.configUrl.length > 0)
            root.openExternalRequested(root.configUrl)
    }

    function markDone() {
        root.configDone()
        root.statusIcon = "check-mark-button"
        root.statusText = (void i18n.revision, i18n.t("gemini_api.done", "Đã gửi yêu cầu cập nhật"))
        root.subText = ""
        root.configReady = false
    }

    parent: Overlay.overlay
    modal: true
    title: (void i18n.revision, i18n.t("gemini_api.window_title", "Gemini API Key"))
    header: null
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(280), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.dp(10)
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(55)
            radius: VfTheme.dp(10)
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: "#8B5CF6" }
                GradientStop { position: 1; color: "#6366F1" }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: VfTheme.dp(10)
                color: "#6366F1"
            }

            Row {
                anchors.centerIn: parent
                spacing: VfTheme.dp(7)

                VfAppIcon {
                    name: "key"
                    size: VfTheme.dp(18)
                    framed: false
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: (void i18n.revision, i18n.t("gemini_api.title", "Gemini API Key"))
                    color: "#FFFFFF"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(18)
                    font.weight: VfTheme.weightTitle
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 24
            Layout.rightMargin: 24
            Layout.topMargin: 20
            Layout.bottomMargin: 16
            spacing: VfTheme.dp(10)

            VfAppIcon {
                Layout.alignment: Qt.AlignHCenter
                name: root.statusIcon
                size: VfTheme.dp(42)
                framed: false
                color: root.statusIcon === "cross-mark" ? "#F43F5E" : VfTheme.primary
                visible: name.length > 0
            }

            Text {
                Layout.fillWidth: true
                text: root.statusText
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(14)
                font.weight: VfTheme.weightStrong
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.subText
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(10)
                visible: root.configReady

                VfButton {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("gemini_api.reopen_browser", "Mở lại trình duyệt"))
                    leadingIcon: "globe-with-meridians"
                    tooltip: (void i18n.revision, i18n.t("gemini_api.reopen_browser", "Mở lại trình duyệt"))
                    onClicked: root.reopenBrowser()
                }

                VfButton {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("gemini_api.done_button", "Đã cấu hình xong"))
                    leadingIcon: "check-mark-button"
                    tooltip: (void i18n.revision, i18n.t("gemini_api.done_button", "Đã cấu hình xong"))
                    tone: "primary"
                    onClicked: root.markDone()
                }
            }

            VfButton {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("common.close", "Đóng"))
                tooltip: (void i18n.revision, i18n.t("common.close", "Đóng"))
                onClicked: root.accept()
            }
        }
    }
}
