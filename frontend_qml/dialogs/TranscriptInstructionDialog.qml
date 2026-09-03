import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property string cardId: ""
    property string fileTitle: ""
    property string filePath: ""
    property string instructionText: ""
    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal saveRequested(string cardId, string instruction)

    modal: true
    parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 620, 80)
    height: VfDialogMetrics.height(parent, 480, 80)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    header: null

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.dp(10)
        border.color: VfTheme.borderBox
    }

    function openFor(payload) {
        var data = payload || ({})
        root.cardId = String(data.card_id || data.cardId || "")
        root.fileTitle = String(data.title || data.file_title || "")
        root.filePath = String(data.file_path || data.path || "")
        root.instructionText = String(data.instruction || "")
        root.statusText = ""
        editor.text = root.instructionText
        root.open()
    }

    function applySaveResult(result) {
        var response = result || ({})
        if (response.ok === false) {
            var message = String(response.message || response.error || response.code || (void i18n.revision, i18n.t("common.save_failed", "Save failed.")))
            root.statusText = message
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            root.feedbackMessage = message
            feedbackDialog.open()
            return
        }
        root.instructionText = String(editor.text || "")
        root.statusText = String(response.message || (void i18n.revision, i18n.t("common.saved", "Saved")))
        root.close()
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(68)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border
            // Bo 2 góc trên khớp với border bo của dialog (radius dp10) — nếu để
            // góc vuông, header che mất 2 góc bo của background.
            topLeftRadius: VfTheme.dp(10)
            topRightRadius: VfTheme.dp(10)

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(16)
                anchors.rightMargin: VfTheme.dp(16)
                anchors.topMargin: VfTheme.dp(12)
                anchors.bottomMargin: VfTheme.dp(12)
                spacing: VfTheme.dp(2)

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("transcript.script_control_dialog_title", "Điều khiển kịch bản"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(17)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root.fileTitle.length > 0 ? root.fileTitle : root.filePath
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    elide: Text.ElideMiddle
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 14
            Layout.bottomMargin: 14
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: (void i18n.revision, i18n.t("transcript.script_control_dialog_label", "Hướng dẫn AI cách HIỂU & PHÂN CẢNH lời thoại của file này: nhịp, trọng tâm, gộp/tách cảnh, giữ nguyên hay tóm tắt… (Phong cách hình ảnh đã chọn ở Style framework — không cần mô tả lại ở đây.)"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
            }

            TextArea {
                id: editor
                Layout.fillWidth: true
                Layout.fillHeight: true
                wrapMode: TextEdit.Wrap
                placeholderText: (void i18n.revision, i18n.t("transcript.script_control_placeholder", "VD: Nhấn mạnh đoạn mở đầu; mỗi câu = 1 cảnh; giữ nguyên lời thoại; tóm tắt phần giữa; nhịp chậm sâu lắng; làm nổi nhân vật chính…"))
                color: VfTheme.text
                placeholderTextColor: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                selectByMouse: true
                background: Rectangle {
                    color: VfTheme.surface
                    border.color: VfTheme.borderBox
                    border.width: 1
                    radius: VfTheme.radiusControl
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root.statusText.length > 0
                text: root.statusText
                color: VfTheme.redText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.clear", "Clear"))
                    tone: "danger"
                    minWidth: VfTheme.dp(84)
                    onClicked: editor.text = ""
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    tone: "neutral"
                    minWidth: VfTheme.dp(92)
                    onClicked: root.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.save", "Save"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: root.saveRequested(root.cardId, editor.text)
                }
            }
        }
    }

    Dialog {
        id: feedbackDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.borderBox
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }
}
