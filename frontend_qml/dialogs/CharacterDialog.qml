import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Dialogs
import "../theme"

Dialog {
    id: root

    property var slots: []
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal chooseRequested()
    signal createAiRequested()
    signal removeRequested(string assetId)
    signal closeRequested()

    function slotSource(slot) {
        var item = slot || ({})
        var base64Data = String(item.base64 || item.thumbnail_base64 || item.image_base64 || "")
        if (base64Data.length > 0)
            return "data:image/png;base64," + base64Data
        var raw = String(item.file_url || item.preview_path || item.path || item.file_path || "")
        if (raw.length === 0)
            return ""
        if (raw.indexOf("data:") === 0 || raw.indexOf("file:") === 0 || raw.indexOf("http://") === 0 || raw.indexOf("https://") === 0)
            return raw
        return "file:///" + raw.replace(/\\/g, "/")
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || "Notice")
        root.feedbackMessage = String(message || "")
        feedbackDialog.open()
    }

    function applyRemoveResult(result) {
        var payload = result || ({})
        if (payload.ok)
            return true
        root.showFeedback(
            (void i18n.revision, i18n.t("common.remove_failed", "Remove failed")),
            String(payload.message || payload.error || (void i18n.revision, i18n.t("media_library.remove_char_failed", "Could not remove the selected character asset.")))
        )
        return false
    }

    title: (void i18n.revision, i18n.t("character_dialog.title", "Nhân vật KOL"))
    header: Label {
        text: root.title
        visible: text.length > 0
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(16)
        font.weight: Font.DemiBold
        leftPadding: VfTheme.dp(16)
        rightPadding: VfTheme.dp(16)
        topPadding: VfTheme.dp(14)
        bottomPadding: VfTheme.dp(4)
    }
    modal: true
    parent: Overlay.overlay
    width: VfDialogMetrics.width(parent, 720, 48)
    height: VfDialogMetrics.height(parent, 360, 48)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 14
    standardButtons: Dialog.NoButton

    background: Rectangle {
        color: VfTheme.surface
        border.color: VfTheme.border
        radius: 10
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Label {
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("character_dialog.description", "Tối đa 3 ảnh KOL — rotate qua các sản phẩm.\nAI dùng làm reference cho character consistency."))
            color: VfTheme.textSubtle
            font.family: "Segoe UI"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Flow {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: root.slots || []

                    Rectangle {
                        width: 108
                        height: 120
                        radius: 8
                        color: VfTheme.surface
                        border.width: 1
                        border.color: VfTheme.borderStrong
                        clip: true

                        Image {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 6
                            height: 82
                            source: root.slotSource(modelData)
                            fillMode: Image.PreserveAspectCrop
                            visible: String(source).length > 0
                        }

                        Label {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 6
                            text: String((modelData || {}).name || (modelData || {}).title || "KOL")
                            color: VfTheme.text
                            horizontalAlignment: Text.AlignHCenter
                            font.family: "Segoe UI"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 4
                            width: 18
                            height: 18
                            radius: 9
                            color: "#DC2626"

                            Label {
                                anchors.centerIn: parent
                                text: "×"
                                color: "#FFFFFF"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.removeRequested(String((modelData || {}).id || (modelData || {}).media_id || ""))
                            }
                        }
                    }
                }

                Rectangle {
                    width: 108
                    height: 120
                    radius: 8
                    color: VfTheme.surface
                    border.width: 1
                    border.color: VfTheme.borderStrong
                    visible: (root.slots || []).length === 0

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Label {
                            text: "+"
                            color: VfTheme.textSubtle
                            horizontalAlignment: Text.AlignHCenter
                            font.family: "Segoe UI"
                            font.pixelSize: 18
                        }

                        Label {
                            text: (void i18n.revision, i18n.t("character_dialog.no_images", "Chưa có ảnh"))
                            color: VfTheme.textSubtle
                            horizontalAlignment: Text.AlignHCenter
                            font.family: "Segoe UI"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            Dialogs.Button {
                text: (void i18n.revision, i18n.t("character_dialog.choose_image", "Chọn ảnh"))
                actionId: "choose character image"
                tone: "neutral"
                tooltip: (void i18n.revision, i18n.t("character_dialog.choose_image_tooltip", "Chọn ảnh nhân vật từ máy"))
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.rightMargin: 14
                minWidth: 74
                implicitHeight: 30
                font.family: "Segoe UI"
                font.pixelSize: 12
                onClicked: root.chooseRequested()
            }
        }

        Dialogs.Button {
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("character_dialog.create_ai", "Tạo nhân vật bằng AI"))
            actionId: "generate ai character"
            tone: "accent"
            tooltip: (void i18n.revision, i18n.t("character_dialog.create_ai_tooltip", "Tạo nhân vật bằng AI từ mô tả"))
            implicitHeight: 38
            font.family: "Segoe UI"
            font.pixelSize: 13
            onClicked: root.createAiRequested()
        }

        RowLayout {
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
            }

            Dialogs.Button {
                text: (void i18n.revision, i18n.t("character_dialog.done", "Xong"))
                actionId: "dialog.confirm"
                tone: "success"
                tooltip: (void i18n.revision, i18n.t("character_dialog.finish_tooltip", "Hoàn tất chọn nhân vật"))
                minWidth: 78
                implicitHeight: 34
                font.family: "Segoe UI"
                font.pixelSize: 12
                onClicked: {
                    root.closeRequested()
                    root.accept()
                }
            }
        }
    }

    Dialog {
        id: feedbackDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, 390, 64)
        padding: 20
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: 12
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: 12

            Label {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: "Segoe UI"
                font.pixelSize: 18
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textSubtle
                font.family: "Segoe UI"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                Dialogs.Button {
                    text: (void i18n.revision, i18n.t("character_dialog.ok", "OK"))
                    actionId: "dialog.ok"
                    tone: "primary"
                    tooltip: (void i18n.revision, i18n.t("character_dialog.close_notification_tooltip", "Đóng thông báo"))
                    minWidth: 88
                    implicitHeight: 32
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }
}
