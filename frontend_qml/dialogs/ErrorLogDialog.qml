import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    parent: Overlay.overlay

    property string logText: ""
    property string actionMessage: ""
    property bool actionError: false

    signal refreshRequested()
    signal clearRequested()

    function cleanLeadingIcon(value) {
        var text = String(value || "").trim()
        text = text.replace(/^[\uD800-\uDBFF][\uDC00-\uDFFF]\uFE0F?\s*/, "")
        text = text.replace(/^[\u2300-\u23FF]\uFE0F?\s*/, "")
        text = text.replace(/^[\u2600-\u27BF]\uFE0F?\s*/, "")
        text = text.replace(/^[\u2B00-\u2BFF]\uFE0F?\s*/, "")
        return text.trim()
    }

    function applyActionResult(result) {
        var response = result || ({})
        root.actionMessage = String(response.message || response.error || "")
        root.actionError = !Boolean(response.ok)
    }

    onOpened: {
        root.actionMessage = ""
        root.actionError = false
        root.refreshRequested()
    }

    Timer {
        interval: 2000
        running: root.visible
        repeat: true
        onTriggered: root.refreshRequested()
    }

    header: VfDialogHeader {
        title: root.cleanLeadingIcon((void i18n.revision, i18n.t("error_log.window_title", "Error Log")))
        iconName: "red-triangle"
        onCloseClicked: root.close()
    }
    modal: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, VfTheme.dp(1125), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(875), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.radiusPanel
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(20)
        spacing: VfTheme.dp(12)

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(32)
            color: VfTheme.surfaceSoft

            Text {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(6)
                text: root.cleanLeadingIcon((void i18n.revision, i18n.t("error_log.header", "Failed Jobs Log")))
                color: "#DC2626"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(23)
                font.weight: VfTheme.weightTitle
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        Text {
            Layout.fillWidth: true
            visible: root.actionMessage.length > 0
            text: root.actionMessage
            color: root.actionError ? "#DC2626" : "#059669"
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(13)
            elide: Text.ElideRight
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(32)
            color: VfTheme.surfaceSoft

            Text {
                anchors.fill: parent
                text: (void i18n.revision, i18n.t("error_log.description", "Failed jobs with full error details. Use Clear to remove the current log."))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: VfTheme.dp(8)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.borderStrong
            clip: true

            ScrollView {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(10)
                clip: true

                TextArea {
                    text: root.logText
                    readOnly: true
                    wrapMode: TextEdit.Wrap
                    color: VfTheme.text
                    selectedTextColor: VfTheme.text
                    selectionColor: VfTheme.amberFill
                    font.family: "Consolas"
                    font.pixelSize: VfTheme.dp(14)
                    background: Rectangle {
                        color: VfTheme.surface
                        border.color: VfTheme.borderBox
                        border.width: 1
                        radius: VfTheme.radiusControl
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(44)
            spacing: VfTheme.dp(12)

            Item { Layout.fillWidth: true }

            VfButton {
                text: root.cleanLeadingIcon((void i18n.revision, i18n.t("error_log.clear_log", "Clear Log")))
                tone: "danger"
                minWidth: VfTheme.dp(130)
                implicitHeight: VfTheme.dp(44)
                onClicked: root.clearRequested()
            }

            VfButton {
                text: root.cleanLeadingIcon((void i18n.revision, i18n.t("error_log.refresh", "Refresh")))
                tone: "primary"
                minWidth: VfTheme.dp(116)
                implicitHeight: VfTheme.dp(44)
                onClicked: root.refreshRequested()
            }

            VfButton {
                text: root.cleanLeadingIcon((void i18n.revision, i18n.t("common.close", "Close")))
                minWidth: VfTheme.dp(88)
                implicitHeight: VfTheme.dp(44)
                onClicked: root.close()
            }
        }
    }
}
