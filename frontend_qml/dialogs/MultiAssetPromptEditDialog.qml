import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property string dialogTitle: (void i18n.revision, i18n.t("multi_asset_edit.header", "Edit Prompt"))
    property string cardId: ""
    property string simpleText: ""
    property string advancedJsonText: ""
    property bool advancedMode: false
    property string statusText: ""
    property string pendingSaveText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal saveRequested(string cardId, string text, bool advancedMode)

    function openFor(payload) {
        var data = payload || ({})
        root.cardId = String(data.id || data.row_id || data.batch_id || "")
        root.dialogTitle = String(data.title || (void i18n.revision, i18n.t("multi_asset_edit.header", "Edit Prompt")))
        root.simpleText = String(data.veo3_prompt || data.prompt || "")
        root.advancedJsonText = String(data.full_json_text || data.json || "")
        root.advancedMode = Boolean(data.advanced_mode)
        root.statusText = ""
        updateEditorContent()
        root.open()
    }

    function updateEditorContent() {
        editor.text = root.advancedMode ? root.advancedJsonText : root.simpleText
        updateCharacterCount()
    }

    function updateCharacterCount() {
        charCountLabel.text = (void i18n.revision, i18n.t("multi_asset_edit.characters_count", "Characters: {count}")).replace("{count}", String(editor.text.length))
    }

    function validateAndSave() {
        var text = String(editor.text || "").trim()
        if (!text.length) {
            root.statusText = (void i18n.revision, i18n.t("multi_asset_edit.empty_content_msg", "Content cannot be empty."))
            root.feedbackTitle = (void i18n.revision, i18n.t("multi_asset_edit.empty_content_title", "Empty content"))
            root.feedbackMessage = root.statusText
            feedbackDialog.open()
            return
        }
        if (root.advancedMode) {
            try {
                JSON.parse(text)
            } catch (error) {
                root.statusText = (void i18n.revision, i18n.t("multi_asset_edit.invalid_json_msg", "Invalid JSON: {error}")).replace("{error}", String(error))
                root.feedbackTitle = (void i18n.revision, i18n.t("multi_asset_edit.invalid_json_title", "Invalid JSON"))
                root.feedbackMessage = root.statusText
                feedbackDialog.open()
                return
            }
            root.pendingSaveText = text
            advancedSaveConfirmDialog.open()
            return
        } else {
            root.simpleText = text
        }
        root.statusText = ""
        root.saveRequested(root.cardId, text, root.advancedMode)
    }

    function commitAdvancedSave() {
        root.advancedJsonText = root.pendingSaveText
        root.statusText = ""
        root.saveRequested(root.cardId, root.pendingSaveText, true)
        root.pendingSaveText = ""
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
        if (root.advancedMode)
            root.advancedJsonText = String(root.pendingSaveText || editor.text || "")
        else
            root.simpleText = String(editor.text || "")
        root.pendingSaveText = ""
        root.statusText = String(response.message || (void i18n.revision, i18n.t("common.saved", "Saved")))
        root.accept()
    }

    title: root.dialogTitle
    header: null
    modal: true
    parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 980, 48)
    height: VfDialogMetrics.height(parent, 760, 48)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.dp(8)
        border.color: VfTheme.borderStrong
    }

    Dialog {
        id: advancedSaveConfirmDialog
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
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(16)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("multi_asset_edit.confirm_save_title", "Confirm Save"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightTitle
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("multi_asset_edit.confirm_save_msg", "Are you sure you want to save changes to the full JSON payload?"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.no", "No"))
                    minWidth: VfTheme.dp(110)
                    onClicked: {
                        root.pendingSaveText = ""
                        advancedSaveConfirmDialog.close()
                    }
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.yes", "Yes"))
                    tone: "primary"
                    minWidth: VfTheme.dp(120)
                    onClicked: {
                        advancedSaveConfirmDialog.close()
                        root.commitAdvancedSave()
                    }
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
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(16)

            Text {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightTitle
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    tone: "primary"
                    minWidth: VfTheme.dp(110)
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(60)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(18)
                anchors.rightMargin: VfTheme.dp(18)
                spacing: VfTheme.dp(12)

                Text {
                    Layout.fillWidth: true
                    text: root.dialogTitle
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(18)
                    font.weight: VfTheme.weightTitle
                    elide: Text.ElideRight
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20
            spacing: VfTheme.dp(14)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(12)

                CheckBox {
                    id: advancedToggle
                    text: (void i18n.revision, i18n.t("multi_asset_edit.advanced_mode_checkbox", "Advanced: Edit Full JSON"))
                    checked: root.advancedMode
                    onToggled: {
                        root.advancedMode = checked
                        root.statusText = ""
                        root.updateEditorContent()
                    }
                }

                Item { Layout.fillWidth: true }
            }

            Text {
                Layout.fillWidth: true
                text: root.advancedMode
                    ? (void i18n.revision, i18n.t("multi_asset_edit.instruction_advanced", "Edit full JSON payload (Advanced):"))
                    : (void i18n.revision, i18n.t("multi_asset_edit.instruction_simple", "Enter prompt for video (plain text):"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            Rectangle {
                Layout.fillWidth: true
                visible: root.advancedMode
                implicitHeight: warningText.implicitHeight + 20
                radius: VfTheme.dp(6)
                color: VfTheme.amberFill
                border.color: "#FBBF24"

                Text {
                    id: warningText
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    text: (void i18n.revision, i18n.t("multi_asset_edit.advanced_warning", "Caution: incorrect JSON structure may corrupt data."))
                    color: VfTheme.amberText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    wrapMode: Text.WordWrap
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(6)
                color: VfTheme.surfaceSoft
                border.color: editor.activeFocus ? "#3B82F6" : VfTheme.borderStrong

                TextArea {
                    id: editor
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    wrapMode: TextEdit.Wrap
                    selectByMouse: true
                    color: VfTheme.text
                    placeholderTextColor: VfTheme.textSubtle
                    font.family: root.advancedMode ? "Consolas" : VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                    placeholderText: (void i18n.revision, i18n.t("multi_asset_edit.placeholder", "Enter prompt or JSON..."))
                    onTextChanged: root.updateCharacterCount()
                    background: Rectangle {
                        color: VfTheme.surface
                        border.color: VfTheme.borderBox
                        border.width: 1
                        radius: VfTheme.radiusControl
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(10)

                Text {
                    id: charCountLabel
                    text: ""
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                }

                Item { Layout.fillWidth: true }

                Text {
                    visible: root.statusText.length > 0
                    text: root.statusText
                    color: VfTheme.redText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    elide: Text.ElideRight
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(62)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(18)
                anchors.rightMargin: VfTheme.dp(18)
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("multi_asset_edit.cancel_btn", "Cancel"))
                    minWidth: VfTheme.dp(120)
                    onClicked: root.reject()
                }

                VfButton {
                    text: root.advancedMode
                        ? (void i18n.revision, i18n.t("multi_asset_edit.save_json_btn", "Save JSON"))
                        : (void i18n.revision, i18n.t("multi_asset_edit.save_btn", "Save"))
                    tone: "primary"
                    minWidth: VfTheme.dp(140)
                    onClicked: root.validateAndSave()
                }
            }
        }
    }
}
