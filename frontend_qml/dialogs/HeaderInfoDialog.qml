import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "HeaderInfoDialog"

    property var payload: ({})
    property bool busy: false
    property string currentActionId: ""
    property int actionProgressValue: 0
    property string actionProgressText: ""
    property bool actionProgressIndeterminate: false

    signal actionRequested(string action, string value)

    parent: Overlay.overlay
    modal: true
    closePolicy: root.blocksDialogDismiss()
                 ? Popup.NoAutoClose
                 : (Popup.CloseOnEscape | Popup.CloseOnPressOutside)
    width: VfDialogMetrics.width(parent, 900, 64)
    height: VfDialogMetrics.height(parent, 680, 64)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    header: VfDialogHeader {
        title: String(root.payload.title || "VeoFlow")
        iconName: "notebook"
        showClose: !root.blocksDialogDismiss()
        onCloseClicked: root.closeDialog()
    }

    function sections() {
        return root.payload && root.payload.sections ? root.payload.sections : []
    }

    function actions() {
        return root.payload && root.payload.actions ? root.payload.actions : []
    }

    function modeText() {
        return String(root.payload && root.payload.mode || "")
    }

    function modeAccent() {
        var mode = root.modeText()
        if (mode === "data")
            return "#2563EB"
        if (mode.indexOf("update") === 0)
            return VfTheme.tealText
        if (mode === "store" || mode === "renew" || mode === "payment")
            return VfTheme.greenText
        if (mode === "credits")
            return "#7C3AED"
        if (mode === "license")
            return "#DC2626"
        return VfTheme.primary
    }

    function modeIconName() {
        var mode = root.modeText()
        if (mode === "data")
            return "computer-disk"
        if (mode.indexOf("update") === 0)
            return "down-arrow"
        if (mode === "store")
            return "shopping-bags"
        if (mode === "renew")
            return "clockwise-arrows"
        if (mode === "payment")
            return "money-bag"
        if (mode === "credits")
            return "money-bag"
        if (mode === "license")
            return "locked-with-key"
        return "notebook"
    }

    function showsUpdateProgress() {
        var mode = root.modeText()
        return mode === "update_download" || mode === "update_apply" || (root.busy && (mode === "update" || mode === "update_result" || mode === "update_apply_confirm"))
    }

    function blocksDialogDismiss() {
        return root.busy && root.currentActionId === "update_apply"
    }

    function closeDialog() {
        if (root.blocksDialogDismiss())
            return
        var mode = String(root.payload && root.payload.mode || "")
        if (root.busy && root.currentActionId === "update_download") {
            if (typeof headerController !== "undefined" && headerController.cancelCurrentAction)
                headerController.cancelCurrentAction()
            root.reject()
            return
        }
        if (mode === "update" || mode === "update_result" || mode === "update_download" || mode === "update_apply") {
            root.reject()
            return
        }
        root.close()
    }

    function runAction(action, value) {
        var actionText = String(action || "")
        var valueText = String(value || "")
        var mode = String(root.payload && root.payload.mode || "")
        if (actionText === "close") {
            root.closeDialog()
            return
        }
        if (actionText === "update_apply" && mode !== "update_apply_confirm") {
            if (typeof headerController !== "undefined" && headerController.openNestedDialog) {
                headerController.openNestedDialog("update_apply_confirm")
            } else {
                root.actionRequested("dialog", "update_apply_confirm")
            }
            return
        }
        if (actionText === "open_external_url") {
            root.actionRequested(actionText, valueText)
            return
        }
        if (actionText === "update_check"
                || actionText === "update_download"
                || actionText === "update_apply"
                || actionText.indexOf("commerce_") === 0) {
            if (typeof headerController !== "undefined" && headerController.executeAction) {
                headerController.executeAction(actionText, valueText)
            } else {
                root.actionRequested(actionText, valueText)
            }
            return
        }
        root.actionRequested(actionText, valueText)
    }

    background: Rectangle {
        radius: VfTheme.dp(10)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
    }

    contentItem: ColumnLayout {
        spacing: 0

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth
            contentHeight: headerInfoBody.implicitHeight
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                id: headerInfoBody
                width: parent.availableWidth
                spacing: VfTheme.dp(10)
                anchors.margins: VfTheme.dp(14)

                Repeater {
                    model: root.sections()

                    delegate: VfPanel {
                        property var sectionData: modelData

                        Layout.fillWidth: true
                        title: String(sectionData.title || "")
                        dense: true

                        Repeater {
                            model: sectionData.rows || []

                            delegate: Rectangle {
                                property var rowData: modelData

                                Layout.fillWidth: true
                                implicitHeight: Math.max(30, rowValue.implicitHeight + 12)
                                radius: VfTheme.radiusControl
                                color: rowMouse.containsMouse && String(rowData.action || "").length > 0 ? VfTheme.surfaceSoft : VfTheme.surface
                                border.color: VfTheme.borderSoft
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(10)
                                    anchors.rightMargin: VfTheme.dp(10)
                                    spacing: VfTheme.dp(10)

                                    Text {
                                        Layout.preferredWidth: VfTheme.dp(160)
                                        text: String(rowData.label || "")
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        font.weight: VfTheme.weightStrong
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Text {
                                        id: rowValue

                                        Layout.fillWidth: true
                                        text: String(rowData.value || "")
                                        color: String(rowData.action || "").length > 0 ? VfTheme.primary : VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontControl
                                        font.weight: VfTheme.weightControl
                                        wrapMode: Text.WrapAnywhere
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                MouseArea {
                                    id: rowMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: String(rowData.action || "").length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    enabled: String(rowData.action || "").length > 0
                                    onClicked: root.runAction(rowData.action, rowData.action_value || rowData.value)
                                }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(4)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 14
            Layout.rightMargin: 14
            Layout.topMargin: 12
            visible: root.showsUpdateProgress()
            implicitHeight: progressColumn.implicitHeight + 20
            radius: VfTheme.radiusPanel
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            ColumnLayout {
                id: progressColumn

                anchors.fill: parent
                anchors.margins: VfTheme.dp(10)
                spacing: VfTheme.dp(6)

                Text {
                    Layout.fillWidth: true
                    text: root.actionProgressText.length > 0
                          ? root.actionProgressText
                          : (root.busy ? (void i18n.revision, i18n.t("update_dialog.preparing", "Preparing update...")) : (void i18n.revision, i18n.t("update_dialog.completed", "Download complete")))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    font.weight: VfTheme.weightStrong
                    wrapMode: Text.Wrap
                }

                ProgressBar {
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    indeterminate: root.actionProgressIndeterminate && root.busy
                    value: root.actionProgressValue
                }

                Text {
                    Layout.fillWidth: true
                    visible: !root.actionProgressIndeterminate
                    text: root.actionProgressValue + "%"
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(54)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(14)
                anchors.rightMargin: VfTheme.dp(14)
                spacing: VfTheme.dp(8)

                Item {
                    Layout.fillWidth: true
                }

                VfButton {
                    visible: root.busy && root.currentActionId === "update_download"
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    tone: "danger"
                    onClicked: root.closeDialog()
                }

                Repeater {
                    model: root.actions()

                    delegate: VfButton {
                        property var actionData: modelData

                        text: String(actionData.label || "")
                        tone: String(actionData.tone || "neutral")
                        enabled: !root.busy
                        onClicked: root.runAction(actionData.action, actionData.value)
                    }
                }
            }
        }
    }
}
