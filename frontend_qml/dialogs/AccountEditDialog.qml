import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Dialogs

import "../components"
import "../theme"

Dialog {
    id: root

    property var account: ({})
    property string accountId: ""
    property string originalEmail: ""
    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal saveRequested(string accountId, string originalEmail, string name, string email, string status, string credits, string tier, string accountType, string cookieType, string browserType, string tag, string totpSecret)

    parent: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 720, 64)
    height: VfDialogMetrics.height(parent, 540, 64)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("qml.settings.edit_account", "Edit Account"))
        iconName: "pencil"
        onCloseClicked: root.reject()
    }

    function openFor(accountData) {
        root.account = accountData || ({})
        root.accountId = String(root.account.id || "")
        root.originalEmail = String(root.account.email || "")
        nameInput.text = String(root.account.name || "")
        emailInput.text = String(root.account.email || "")
        statusInput.text = String(root.account.status || "")
        creditsInput.text = String(root.account.credits || 0)
        tierInput.text = String(root.account.tier || "")
        accountTypeInput.text = String(root.account.accountType || "")
        cookieTypeInput.text = String(root.account.cookieType || "")
        browserTypeInput.text = String(root.account.browserType || "")
        tagInput.text = String(root.account.tag || "")
        totpSecretInput.text = String(root.account.totpSecret || "")
        root.statusText = ""
        root.open()
    }

    function applySaveResult(result) {
        var response = result || ({})
        if (response.pending) {
            root.statusText = String(response.message || (void i18n.revision, i18n.t("common.working", "Working...")))
            return
        }
        if (response.ok === false) {
            var message = String(response.message || response.error || response.code || (void i18n.revision, i18n.t("common.save_failed", "Save failed.")))
            root.statusText = message
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            root.feedbackMessage = message
            feedbackDialog.open()
            return
        }
        root.statusText = String(response.message || (void i18n.revision, i18n.t("common.saved", "Saved")))
        root.close()
    }

    background: Rectangle {
        radius: VfTheme.radiusPanel
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
    }

    contentItem: ColumnLayout {
        spacing: 0

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 14
            columns: 2
            rowSpacing: VfTheme.dp(10)
            columnSpacing: VfTheme.dp(12)

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)
                Text { text: (void i18n.revision, i18n.t("common.name", "Name")); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontControl; font.weight: VfTheme.weightStrong }
                Dialogs.TextField {
                    id: nameInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    color: VfTheme.text
                    selectedTextColor: "#FFFFFF"
                    selectionColor: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)
                Text { text: (void i18n.revision, i18n.t("common.email", "Email")); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontControl; font.weight: VfTheme.weightStrong }
                Dialogs.TextField {
                    id: emailInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    color: VfTheme.text
                    selectedTextColor: "#FFFFFF"
                    selectionColor: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)
                Text { text: (void i18n.revision, i18n.t("common.status", "Status")); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontControl; font.weight: VfTheme.weightStrong }
                Dialogs.TextField {
                    id: statusInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    color: VfTheme.text
                    selectedTextColor: "#FFFFFF"
                    selectionColor: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)
                Text { text: (void i18n.revision, i18n.t("settings.col_credits", "Credits")); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontControl; font.weight: VfTheme.weightStrong }
                Dialogs.TextField {
                    id: creditsInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 0 }
                    color: VfTheme.text
                    selectedTextColor: "#FFFFFF"
                    selectionColor: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)
                Text { text: (void i18n.revision, i18n.t("settings.col_tier", "Tier")); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontControl; font.weight: VfTheme.weightStrong }
                Dialogs.TextField {
                    id: tierInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    color: VfTheme.text
                    selectedTextColor: "#FFFFFF"
                    selectionColor: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)
                Text { text: (void i18n.revision, i18n.t("qml.settings.browser_type", "Browser Type")); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontControl; font.weight: VfTheme.weightStrong }
                Dialogs.TextField {
                    id: browserTypeInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    color: VfTheme.text
                    selectedTextColor: "#FFFFFF"
                    selectionColor: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)
                Text { text: (void i18n.revision, i18n.t("qml.settings.account_type", "Account Type")); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontControl; font.weight: VfTheme.weightStrong }
                Dialogs.TextField {
                    id: accountTypeInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    color: VfTheme.text
                    selectedTextColor: "#FFFFFF"
                    selectionColor: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)
                Text { text: (void i18n.revision, i18n.t("qml.settings.cookie_type", "Cookie Type")); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontControl; font.weight: VfTheme.weightStrong }
                Dialogs.TextField {
                    id: cookieTypeInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    color: VfTheme.text
                    selectedTextColor: "#FFFFFF"
                    selectionColor: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                }
            }

            ColumnLayout {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)
                Text { text: (void i18n.revision, i18n.t("common.tag", "Tag")); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontControl; font.weight: VfTheme.weightStrong }
                Dialogs.TextField {
                    id: tagInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    color: VfTheme.text
                    selectedTextColor: "#FFFFFF"
                    selectionColor: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                }
            }

            ColumnLayout {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)
                Text {
                    text: (void i18n.revision, i18n.t("qml.settings.totp_secret", "2FA TOTP secret (optional)"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    font.weight: VfTheme.weightStrong
                }
                Dialogs.TextField {
                    id: totpSecretInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(34)
                    placeholderText: (void i18n.revision, i18n.t("qml.settings.totp_secret_ph", "Base32 secret — auto-fill Google Authenticator on Drive consent"))
                    echoMode: TextInput.PasswordEchoOnEdit
                    color: VfTheme.text
                    selectedTextColor: "#FFFFFF"
                    selectionColor: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                }
                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("qml.settings.totp_secret_hint", "Leave empty to clear. When Drive OAuth asks for Authenticator, the tool generates and fills the code. Without a secret, a headed window opens for manual 2FA."))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    wrapMode: Text.WordWrap
                }
            }

            Text {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("qml.settings.account_edit_note", "This updates local account metadata only. Browser login, cookie refresh, and profile rename remain native/browser flows."))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.columnSpan: 2
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
            Layout.preferredHeight: VfTheme.dp(38)
            spacing: VfTheme.dp(8)

            Item { Layout.fillWidth: true }

            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                onClicked: root.close()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("common.save", "Save"))
                tone: "primary"
                onClicked: root.saveRequested(root.accountId, root.originalEmail, nameInput.text, emailInput.text, statusInput.text, creditsInput.text, tierInput.text, accountTypeInput.text, cookieTypeInput.text, browserTypeInput.text, tagInput.text, totpSecretInput.text)
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
