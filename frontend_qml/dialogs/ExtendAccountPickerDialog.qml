import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

// Account picker for a new extend session (ported from the legacy AccountTabBar's
// AccountPickerDialog). Lists the Live accounts that still have a free session slot so
// the user knows WHICH account a session binds to. Data IN via `accounts`, choice OUT via
// `accountChosen`.
Dialog {
    id: root
    parent: Overlay.overlay

    property var accounts: []
    property int selectedIndex: -1

    signal accountChosen(var account)

    function trText(key, fallback) {
        if (typeof i18n !== "undefined" && i18n && i18n.t)
            return (void i18n.revision, i18n.t(key, fallback))
        return fallback
    }

    function openWith(list) {
        // extendAvailableAccounts() comes back as a QVariantList — Array.isArray() returns FALSE
        // for it, so this silently emptied the list and NO account could ever be picked (the "+"
        // dialog opened blank). Copy by .length, which works for a QVariantList AND a JS array.
        var arr = []
        if (list && typeof list !== "string" && list.length !== undefined) {
            for (var i = 0; i < list.length; i++)
                arr.push(list[i])
        }
        root.accounts = arr
        root.selectedIndex = root.accounts.length > 0 ? 0 : -1
        root.open()
    }

    modal: true
    width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(440), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.radiusPanel
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    header: VfDialogHeader {
        title: root.trText("account_tab.select_account_title", "Chọn tài khoản cho phiên")
        iconName: "busts-in-silhouette"
        onCloseClicked: root.reject()
    }

    contentItem: ColumnLayout {
        spacing: VfTheme.dp(10)

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: VfTheme.dp(14)
            Layout.topMargin: VfTheme.dp(10)
            text: root.trText("account_tab.select_account_label", "Mỗi tài khoản tối đa 5 phiên. Chọn tài khoản khả dụng:")
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            wrapMode: Text.WordWrap
        }

        VfListView {
            id: accountList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: VfTheme.dp(12)
            Layout.rightMargin: VfTheme.dp(12)
            Layout.bottomMargin: VfTheme.dp(4)
            spacing: VfTheme.dp(6)
            model: root.accounts  // perf-lint: disable=R2  modal one-shot picker, tiny static list

            delegate: Rectangle {
                width: ListView.view.width
                height: VfTheme.dp(54)
                radius: VfTheme.dp(8)
                property bool isSelected: index === root.selectedIndex
                color: isSelected ? VfTheme.blueFill : VfTheme.surfaceSoft
                border.color: isSelected ? VfTheme.primary : VfTheme.border
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectedIndex = index
                    onDoubleClicked: {
                        root.selectedIndex = index
                        root.acceptSelection()
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(12)
                    anchors.rightMargin: VfTheme.dp(12)
                    spacing: VfTheme.dp(2)

                    Text {
                        Layout.fillWidth: true
                        text: "👤 " + String((modelData || {}).name || (modelData || {}).email || "Account")
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        font.weight: VfTheme.weightStrong
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "💰 " + String((modelData || {}).credits || 0) + " credits"
                            + "  •  " + String((modelData || {}).sessions_used || 0)
                            + "/" + String((modelData || {}).max_slots || 5) + " phiên"
                            + "  •  " + String((modelData || {}).status || "Live")
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        elide: Text.ElideRight
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: VfTheme.dp(12)
            Layout.rightMargin: VfTheme.dp(12)
            Layout.bottomMargin: VfTheme.dp(12)
            spacing: VfTheme.dp(8)

            Item { Layout.fillWidth: true }

            VfButton {
                text: root.trText("common.cancel", "Hủy")
                minWidth: VfTheme.dp(96)
                onClicked: root.reject()
            }

            VfButton {
                text: root.trText("account_tab.create_session", "Tạo phiên")
                tone: "success"
                minWidth: VfTheme.dp(120)
                enabled: root.selectedIndex >= 0 && root.selectedIndex < root.accounts.length
                onClicked: root.acceptSelection()
            }
        }
    }

    function acceptSelection() {
        if (root.selectedIndex < 0 || root.selectedIndex >= root.accounts.length)
            return
        var account = root.accounts[root.selectedIndex]
        root.accept()
        root.accountChosen(account)
    }
}
