import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property string rulesText: ""
    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal saveRequested(string text)

    parent: Overlay.overlay
    modal: true
    width: VfDialogMetrics.width(parent, VfTheme.dp(640), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(420), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton

    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("config_panel.rules_dialog_title", "Extend Rules"))
        iconName: "pencil"
        onCloseClicked: root.close()
    }

    function openFor(text) {
        root.rulesText = String(text || "")
        root.statusText = ""
        editor.text = root.rulesText
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
        root.rulesText = String(response.rules !== undefined ? response.rules : editor.text)
        root.statusText = String(response.message || (void i18n.revision, i18n.t("common.saved", "Saved")))
        root.close()
    }

    background: Rectangle {
        radius: VfTheme.dp(14)
        color: VfTheme.surface
        border.width: 1
        border.color: VfTheme.border
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 16
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: (void i18n.revision, i18n.t("config_panel.rules_dialog_placeholder", "Enter extend rules. These rules are appended to extend prompts."))
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                color: VfTheme.textSubtle
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(10)
                color: VfTheme.surface
                border.width: 1
                border.color: VfTheme.borderStrong

                ScrollView {
                    id: editorScroll
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    contentWidth: availableWidth
                    contentHeight: editor.implicitHeight
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    TextArea {
                        id: editor
                        width: editorScroll.availableWidth
                        wrapMode: TextEdit.Wrap
                        color: VfTheme.text
                        placeholderText: (void i18n.revision, i18n.t("config_panel.rules_dialog_placeholder", "Enter extend rules. These rules are appended to extend prompts."))
                        placeholderTextColor: VfTheme.textSubtle
                        selectedTextColor: "#FFFFFF"
                        selectionColor: "#2563EB"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                        background: Item {}
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root.statusText.length > 0
                text: root.statusText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                color: VfTheme.redText
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: root.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.save", "Save"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: root.saveRequested(editor.text)
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
