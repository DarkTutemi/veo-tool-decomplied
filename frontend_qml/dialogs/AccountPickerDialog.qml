import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property var accounts: []
    property string selectedEmail: ""
    property int selectedIndex: -1
    property var selectedAccount: ({})

    signal accountSelected(var account)

    parent: Overlay.overlay
    modal: true
    width: VfDialogMetrics.width(parent, 440, 80)
    height: VfDialogMetrics.height(parent, 360, 80)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    function openFor(rows, selected) {
        root.accounts = rows || []
        root.selectedEmail = String(selected || "")
        root.selectedAccount = ({})
        root.selectedIndex = -1
        for (var i = 0; i < root.accounts.length; i++) {
            if (String(root.accounts[i].email || "") === root.selectedEmail) {
                root.selectedAccount = root.accounts[i]
                root.selectedIndex = i
                break
            }
        }
        root.open()
    }

    background: Rectangle {
        radius: VfTheme.radiusPanel
        color: VfTheme.surface
        border.color: VfTheme.borderBox
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(58)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.borderSoft

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: VfTheme.dp(16)
                anchors.rightMargin: VfTheme.dp(16)
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("account_tab.select_account_title", "Pick Account"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(16)
                    font.weight: VfTheme.weightTitle
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("account_tab.select_account_label", "Select an account to use for this action."))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    elide: Text.ElideRight
                }
            }
        }

        ListView {
            id: accountList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 12
            clip: true
            spacing: 0
            reuseItems: true
            model: root.accounts  // perf-lint: disable=R2  static/single-populate config list — one-time rebuild, no continuous cost

            delegate: Rectangle {
                width: accountList.width
                height: VfTheme.dp(44)
                radius: 0
                color: root.selectedIndex === index ? "#2563EB" : (accountMouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface)
                border.color: VfTheme.surfaceSoft
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(10)
                    anchors.rightMargin: VfTheme.dp(10)
                    spacing: VfTheme.dp(8)

                    VfAppIcon {
                        featureId: "account.accounts"
                        size: VfTheme.actionIconSize
                        framed: false
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        text: String(modelData.name || modelData.email || "Unknown")
                        color: root.selectedIndex === index ? "#FFFFFF" : VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        font.weight: root.selectedIndex === index ? VfTheme.weightStrong : VfTheme.weightControl
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        text: "\u2022"
                        color: root.selectedIndex === index ? "#FFFFFF" : VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        verticalAlignment: Text.AlignVCenter
                    }

                    VfAppIcon {
                        featureId: "account.paid_credits"
                        size: VfTheme.actionIconSize
                        framed: false
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: String(modelData.credits || 0) + " credits"
                        color: root.selectedIndex === index ? "#FFFFFF" : VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        font.weight: root.selectedIndex === index ? VfTheme.weightStrong : VfTheme.weightControl
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        text: "\u2022"
                        color: root.selectedIndex === index ? "#FFFFFF" : VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        text: String(modelData.status || "Unknown")
                        color: root.selectedIndex === index ? "#FFFFFF" : VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        font.weight: root.selectedIndex === index ? VfTheme.weightStrong : VfTheme.weightControl
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MouseArea {
                    id: accountMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selectedEmail = String(modelData.email || "")
                        root.selectedAccount = modelData
                        root.selectedIndex = index
                    }
                    onDoubleClicked: {
                        root.selectedEmail = String(modelData.email || "")
                        root.selectedAccount = modelData
                        root.selectedIndex = index
                        root.accountSelected(root.selectedAccount)
                        root.close()
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 12
            spacing: VfTheme.dp(8)

            Item {
                Layout.fillWidth: true
            }

            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                onClicked: root.close()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("common.ok", "OK"))
                tone: "primary"
                enabled: root.selectedIndex >= 0
                onClicked: {
                    root.accountSelected(root.selectedAccount)
                    root.close()
                }
            }
        }
    }
}
