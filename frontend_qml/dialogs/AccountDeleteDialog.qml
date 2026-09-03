import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property var account: ({})
    property string accountId: ""
    property string email: ""
    property string name: ""
    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal deleteRequested(string accountId, string email)

    parent: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 520, 64)
    height: VfDialogMetrics.height(parent, VfTheme.dp(284), VfTheme.dp(64))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("qml.settings.delete_account", "Delete Account"))
        iconName: "red-triangle"
        onCloseClicked: root.reject()
    }

    function openFor(accountData) {
        root.account = accountData || ({})
        root.accountId = String(root.account.id || "")
        root.email = String(root.account.email || "")
        root.name = String(root.account.name || root.email || "")
        root.statusText = ""
        root.feedbackTitle = ""
        root.feedbackMessage = ""
        root.open()
    }

    function applyDeleteResult(result) {
        var response = result || ({})
        if (response.pending) {
            root.statusText = String(response.message || (void i18n.revision, i18n.t("common.working", "Working...")))
            return
        }
        if (!response.ok) {
            var message = String(response.message || response.error || response.code || (void i18n.revision, i18n.t("common.delete_failed", "Delete failed.")))
            root.statusText = message
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            root.feedbackMessage = message
            feedbackDialog.open()
            return
        }
        root.statusText = String(response.message || (void i18n.revision, i18n.t("common.deleted", "Deleted")))
        root.close()
    }

    background: Rectangle {
        radius: VfTheme.radiusPanel
        color: VfTheme.surface
        border.color: VfTheme.redBorder
    }

    contentItem: ColumnLayout {
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 16
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("qml.settings.delete_account_warning", "This removes the account from the local account catalog."))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
                font.weight: VfTheme.weightStrong
                wrapMode: Text.WordWrap
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(58)
                radius: VfTheme.radiusControl
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderBox

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(9)
                    spacing: 1

                    Text {
                        Layout.fillWidth: true
                        text: root.name
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        font.weight: VfTheme.weightStrong
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.email
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        elide: Text.ElideRight
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("qml.settings.delete_account_note", "Browser profile cleanup and re-login remain native/browser flows."))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                visible: root.statusText.length > 0
                text: root.statusText
                color: VfTheme.redText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 14
            Layout.preferredHeight: VfTheme.dp(44)
            spacing: VfTheme.dp(8)

            Item { Layout.fillWidth: true }

            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                onClicked: root.close()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("common.delete_short", "Delete"))
                tone: "danger"
                onClicked: root.deleteRequested(root.accountId, root.email)
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
            border.color: VfTheme.redBorder
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

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
