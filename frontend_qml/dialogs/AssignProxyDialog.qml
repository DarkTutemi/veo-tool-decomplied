import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: dialog

    property string accountEmail: ""
    property string currentProxy: ""
    property string selectedProxyKey: "__NO_PROXY__"
    property var proxies: []
    readonly property var _proxyModel: [{ key: "__NO_PROXY__", label: (void i18n.revision, i18n.t("qml.settings.no_proxy", "No proxy")), status: "", assignedAccount: "" }].concat(dialog.proxies || [])
    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal assignRequested(string email, string proxyKey)

    parent: Overlay.overlay
    modal: true
    width: VfDialogMetrics.width(parent, 580, 80)
    height: VfDialogMetrics.height(parent, VfTheme.dp(460), VfTheme.dp(64))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("qml.settings.assign_proxy", "Assign Proxy"))
        iconName: "globe-with-meridians"
        onCloseClicked: dialog.reject()
    }

    signal addProxyRequested()

    function openFor(email, proxyRows, current) {
        dialog.accountEmail = String(email || "")
        dialog.proxies = proxyRows || []
        dialog.currentProxy = String(current || "")
        dialog.selectedProxyKey = "__NO_PROXY__"
        dialog.statusText = ""
        dialog.feedbackTitle = ""
        dialog.feedbackMessage = ""
        dialog.open()
    }

    function requestAssign() {
        dialog.assignRequested(dialog.accountEmail, dialog.selectedProxyKey)
    }

    function applyAssignResult(result) {
        var response = result || ({})
        if (response.pending) {
            dialog.statusText = String(response.message || (void i18n.revision, i18n.t("common.working", "Working...")))
            return
        }
        if (!response.ok) {
            var message = String(response.message || response.error || response.code || (void i18n.revision, i18n.t("common.save_failed", "Save failed.")))
            dialog.statusText = message
            dialog.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            dialog.feedbackMessage = message
            feedbackDialog.open()
            return
        }
        dialog.statusText = String(response.message || (void i18n.revision, i18n.t("common.saved", "Saved")))
        dialog.accept()
    }

    background: Rectangle {
        radius: VfTheme.radiusPanel
        color: VfTheme.surface
        border.color: VfTheme.borderBox
    }

    contentItem: ColumnLayout {
        spacing: 0

        ListView {
            id: proxyList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 12
            clip: true
            spacing: VfTheme.dp(7)
            model: dialog._proxyModel
            reuseItems: true

            delegate: Rectangle {
                width: proxyList.width
                height: VfTheme.dp(46)
                radius: VfTheme.radiusControl
                color: dialog.selectedProxyKey === String(modelData.key || "") ? VfTheme.blueFill : (proxyMouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface)
                border.color: dialog.selectedProxyKey === String(modelData.key || "") ? VfTheme.primary : VfTheme.borderBox

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    spacing: VfTheme.dp(8)

                    Rectangle {
                        Layout.preferredWidth: VfTheme.dp(12)
                        Layout.preferredHeight: VfTheme.dp(12)
                        radius: VfTheme.dp(6)
                        color: dialog.selectedProxyKey === String(modelData.key || "") ? VfTheme.primary : VfTheme.surface
                        border.color: dialog.selectedProxyKey === String(modelData.key || "") ? VfTheme.primary : VfTheme.borderBox
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            text: String(modelData.label || modelData.key || "")
                            color: modelData.key === "__NO_PROXY__" ? VfTheme.redBorder : VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                            font.weight: VfTheme.weightStrong
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: modelData.assignedAccount || modelData.status
                            text: (modelData.status ? String(modelData.status) : "") + (modelData.assignedAccount ? "  " + String(modelData.assignedAccount) : "")
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    id: proxyMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: dialog.selectedProxyKey = String(modelData.key || "")
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            visible: (dialog.proxies || []).length === 0
            text: (void i18n.revision, i18n.t("settings.no_available_proxy", "No available proxy"))
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            visible: dialog.statusText.length > 0
            text: dialog.statusText
            color: VfTheme.redBorder
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 12
            spacing: VfTheme.dp(8)

            VfButton {
                text: (void i18n.revision, i18n.t("settings.add_proxy", "Add Proxy"))
                minWidth: VfTheme.dp(110)
                onClicked: {
                    dialog.close()
                    dialog.addProxyRequested()
                }
            }

            Item {
                Layout.fillWidth: true
            }

            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                onClicked: dialog.reject()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("qml.settings.assign_proxy", "Assign Proxy"))
                tone: "primary"
                onClicked: dialog.requestAssign()
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
