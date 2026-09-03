import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: dialog

    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal saveRequested(string provider, string apiKey, string label)

    parent: Overlay.overlay
    modal: true
    width: VfDialogMetrics.width(parent, 560, 80)
    height: VfDialogMetrics.height(parent, VfTheme.dp(330), VfTheme.dp(64))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("api_keys.add_title", "Add Gemini API Key"))
        iconName: "key"
        onCloseClicked: dialog.reject()
    }

    function resetForm() {
        providerCombo.currentIndex = 0
        labelInput.text = ""
        keyInput.text = ""
        dialog.statusText = ""
    }

    function applySaveResult(result) {
        var response = result || ({})
        if (response.pending) {
            dialog.statusText = String(response.message || (void i18n.revision, i18n.t("common.working", "Working...")))
            return
        }
        if (response.ok === false) {
            var message = String(response.message || response.error || response.code || (void i18n.revision, i18n.t("common.save_failed", "Save failed.")))
            dialog.statusText = message
            dialog.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            dialog.feedbackMessage = message
            feedbackDialog.open()
            return
        }
        dialog.statusText = String(response.message || (void i18n.revision, i18n.t("common.saved", "Saved")))
        dialog.resetForm()
        dialog.close()
    }

    background: Rectangle {
        radius: VfTheme.radiusPanel
        color: VfTheme.surface
        border.color: VfTheme.borderBox
    }

    contentItem: ColumnLayout {
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 14
            spacing: VfTheme.dp(10)

            NoScrollComboBox {
                id: providerCombo
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(34)
                model: [
                    { label: "Gemini", value: "gemini" }
                ]
                textRole: "label"
                valueRole: "value"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
            }

            TextField {
                id: labelInput
                Layout.fillWidth: true
                placeholderText: (void i18n.revision, i18n.t("qml.settings.key_label", "Label"))
                color: VfTheme.text
                placeholderTextColor: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                background: Rectangle {
                    color: VfTheme.surface
                    border.color: VfTheme.borderBox
                    border.width: 1
                    radius: VfTheme.radiusControl
                }
            }

            TextField {
                id: keyInput
                Layout.fillWidth: true
                placeholderText: (void i18n.revision, i18n.t("qml.settings.api_key", "API key"))
                echoMode: TextInput.Password
                color: VfTheme.text
                placeholderTextColor: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                background: Rectangle {
                    color: VfTheme.surface
                    border.color: VfTheme.borderBox
                    border.width: 1
                    radius: VfTheme.radiusControl
                }
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("api_keys.subtitle", "Manage Gemini keys on the server for go-gateway. MiniMax and ElevenLabs remain local-only in the client."))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                visible: dialog.statusText.length > 0
                text: dialog.statusText
                color: VfTheme.redText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Item {
                    Layout.fillWidth: true
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    onClicked: dialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.save", "Save"))
                    tone: "primary"
                    enabled: keyInput.text.length > 0
                    onClicked: dialog.saveRequested(String(providerCombo.currentValue), keyInput.text, labelInput.text)
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
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: dialog.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightTitle
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: dialog.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
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
