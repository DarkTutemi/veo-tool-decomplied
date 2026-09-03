import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "ApiKeysDialog"

    property var keys: []
    // Legacy props kept so App.qml / AccountSettings bindings don't break.
    // Mode (Studio / Server / Personal) lives on AI dashboard only.
    property string apiMode: "personal"
    property string previousApiMode: "personal"
    property string selectedKeyId: ""
    property string statusText: (void i18n.revision, i18n.t("common.ready", "Ready"))
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal refreshRequested()
    signal addRequested(string provider, string label, string key)
    signal deleteRequested(string keyId)
    signal modeRequested(string mode)  // unused — mode is Settings → Nguồn AI

    parent: Overlay.overlay
    modal: true
    width: VfDialogMetrics.width(parent, 820, 56)
    height: VfDialogMetrics.height(parent, 540, 56)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("api_keys.window_title", "Cấu hình Gemini API"))
        iconName: "locked-with-key"
        onCloseClicked: root.reject()
    }

    onOpened: root.refreshRequested()

    function openForAddGemini() {
        root.selectedKeyId = ""
        root.open()
        Qt.callLater(function() {
            root.statusText = (void i18n.revision, i18n.t("api_keys.add_gemini_hint", "Dán Gemini API key rồi bấm Save key."))
            keyInput.forceActiveFocus()
        })
    }

    function keyId(item) {
        return String(item.id || item.key_id || "")
    }

    function maskedKey(item) {
        return String(item.masked_key || item.key_masked || item.api_key_masked || item.key || "")
    }

    function keyLabel(item) {
        return String(item.label || item.name || item.provider || "")
    }

    function createdAt(item) {
        return String(item.created_at || item.created || item.updated_at || "")
    }

    function hasKeyId(keyId) {
        var target = String(keyId || "")
        if (!target.length)
            return false
        var rows = root.keys || []
        for (var i = 0; i < rows.length; i++) {
            if (root.keyId(rows[i]) === target)
                return true
        }
        return false
    }

    function setMode(mode) {
        // No-op: routing mode is controlled by Settings → AI & API Providers.
        root.apiMode = "personal"
        root.previousApiMode = "personal"
    }

    function saveKey() {
        var apiKey = keyInput.text.trim()
        if (!apiKey.length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("api_keys.missing_key_title", "Missing key"))
            root.feedbackMessage = (void i18n.revision, i18n.t("api_keys.missing_key", "Enter a Gemini API key first."))
            feedbackDialog.open()
            root.statusText = root.feedbackMessage
            return
        }
        root.statusText = (void i18n.revision, i18n.t("api_keys.saved_pending_refresh", "Save requested."))
        root.addRequested("gemini", labelInput.text.trim(), apiKey)
    }

    function requestDeleteKey() {
        if (!root.selectedKeyId.length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("api_keys.no_key_selected_title", "No key selected"))
            root.feedbackMessage = (void i18n.revision, i18n.t("api_keys.no_key_selected", "Select a key first."))
            feedbackDialog.open()
            root.statusText = root.feedbackMessage
            return
        }
        root.deleteRequested(root.selectedKeyId)
    }

    function applyAddResult(result) {
        var response = result || ({})
        if (response.pending) {
            root.statusText = String(response.message || root.statusText)
            return
        }
        if (response.ok) {
            keyInput.text = ""
            labelInput.text = ""
        } else {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            root.feedbackMessage = String(response.message || response.error || "API key save failed")
            feedbackDialog.open()
        }
        root.statusText = String(response.message || response.error || root.statusText)
    }

    function applyDeleteResult(result) {
        var response = result || ({})
        if (response.pending) {
            root.statusText = String(response.message || root.statusText)
            return
        }
        if (response.ok) {
            if (String(response.key_id || "") === root.selectedKeyId || !root.hasKeyId(root.selectedKeyId))
                root.selectedKeyId = ""
        } else {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            root.feedbackMessage = String(response.message || response.error || "API key remove failed")
            feedbackDialog.open()
        }
        root.statusText = String(response.message || response.error || root.statusText)
    }

    function applyModeResult(result) {
        // Mode UI removed — ignore server mode payloads; keep dialog usable for keys only.
        var response = result || ({})
        if (response.pending) {
            root.statusText = String(response.message || root.statusText)
            return
        }
        root.apiMode = "personal"
        root.previousApiMode = "personal"
        if (response.message)
            root.statusText = String(response.message)
    }

    function statusTextForVisualTest() {
        return String(root.statusText || "")
    }

    function closeFeedbackForVisualTest() {
        feedbackDialog.close()
        return true
    }

    function setApiModeForVisualTest(mode) {
        root.previousApiMode = String(root.apiMode || "server")
        root.apiMode = String(mode || "server")
        return true
    }

    function setKeyFieldsForVisualTest(label, key) {
        labelInput.text = String(label || "")
        keyInput.text = String(key || "")
        return true
    }

    function labelInputForVisualTest() {
        return String(labelInput.text || "")
    }

    function keyInputLengthForVisualTest() {
        return String(keyInput.text || "").length
    }

    function clearSelectedKeyForVisualTest() {
        root.selectedKeyId = ""
        return true
    }

    background: Rectangle {
        color: VfTheme.surfaceSoft
        radius: VfTheme.dp(8)
        border.color: VfTheme.borderStrong
    }

    Dialog {
        id: feedbackDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(440), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.border
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

    contentItem: ColumnLayout {
        spacing: VfTheme.dp(12)

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 14
            spacing: VfTheme.dp(12)

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(3)

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("api_keys.gemini_config", "Gemini API Configuration"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(18)
                    font.weight: Font.Black
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("api_keys.subtitle_v2", "Thêm / xóa Gemini API key dùng cho nguồn «API Cá nhân». Chọn nguồn AI (Studio / Server / Cá nhân) ở màn Settings — không chỉnh mode trong hộp này."))
                    color: VfTheme.textSubtle
                    wrapMode: Text.WordWrap
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    maximumLineCount: 3
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(118)
                Layout.preferredHeight: VfTheme.dp(28)
                radius: VfTheme.dp(6)
                color: VfTheme.cyanFill
                border.color: VfTheme.cyanBorderSoft

                Text {
                    anchors.centerIn: parent
                    text: "PERSONAL KEYS"
                    color: VfTheme.cyanText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    font.weight: Font.Black
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(12)
                spacing: VfTheme.dp(12)

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: VfTheme.dp(8)
                    color: VfTheme.surface
                    border.color: VfTheme.borderStrong
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(36)
                            color: VfTheme.surfaceSoft
                            border.color: VfTheme.borderStrong

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(8)
                                anchors.rightMargin: VfTheme.dp(8)
                                spacing: 0

                                HeaderCell { Layout.preferredWidth: VfTheme.dp(70); text: "ID"; horizontalAlignment: Text.AlignHCenter }
                                HeaderCell { Layout.fillWidth: true; text: (void i18n.revision, i18n.t("api_keys.col_label", "Name")) }
                                HeaderCell { Layout.fillWidth: true; text: (void i18n.revision, i18n.t("api_keys.col_masked", "Masked key")) }
                                HeaderCell { Layout.preferredWidth: VfTheme.dp(170); text: (void i18n.revision, i18n.t("api_keys.col_created", "Created at")) }
                            }
                        }

                        ListView {
                            id: keyTable
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            reuseItems: true
                            model: root.keys || []

                            delegate: Rectangle {
                                width: keyTable.width
                                height: VfTheme.dp(38)
                                color: root.selectedKeyId === root.keyId(modelData) ? VfTheme.blueFill : VfTheme.surface
                                border.color: VfTheme.border

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(8)
                                    anchors.rightMargin: VfTheme.dp(8)
                                    spacing: 0

                                    BodyCell { Layout.preferredWidth: VfTheme.dp(70); text: root.keyId(modelData); horizontalAlignment: Text.AlignHCenter }
                                    BodyCell { Layout.fillWidth: true; text: root.keyLabel(modelData) }
                                    BodyCell { Layout.fillWidth: true; text: root.maskedKey(modelData) }
                                    BodyCell { Layout.preferredWidth: VfTheme.dp(170); text: root.createdAt(modelData) }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.selectedKeyId = root.keyId(modelData)
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: (root.keys || []).length === 0
                            text: (void i18n.revision, i18n.t("api_keys.no_keys", "No Gemini keys."))
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(76)
                    radius: VfTheme.dp(8)
                    color: VfTheme.surfaceSoft
                    border.color: VfTheme.borderStrong

                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(12)
                        columns: 2
                        columnSpacing: VfTheme.dp(10)
                        rowSpacing: VfTheme.dp(6)

                        FieldLabel { text: (void i18n.revision, i18n.t("api_keys.label_name", "Label")) }
                        FieldLabel { text: (void i18n.revision, i18n.t("api_keys.gemini_key", "Gemini API key")) }

                        TextField {
                            id: labelInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(32)
                            placeholderText: (void i18n.revision, i18n.t("api_keys.label_placeholder", "Example: Gemini backup"))
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            background: FieldBackground { active: labelInput.activeFocus }
                        }

                        TextField {
                            id: keyInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(32)
                            placeholderText: "AIza..."
                            echoMode: TextInput.PasswordEchoOnEdit
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            background: FieldBackground { active: keyInput.activeFocus }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 14
            spacing: VfTheme.dp(8)

            Text {
                Layout.fillWidth: true
                text: root.statusText
                color: root.statusText.indexOf("failed") >= 0 || root.statusText.indexOf("Enter") >= 0 ? "#DC2626" : VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                elide: Text.ElideRight
            }

            VfButton {
                text: (void i18n.revision, i18n.t("common.refresh", "Refresh"))
                minWidth: VfTheme.dp(88)
                onClicked: root.refreshRequested()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                tone: "danger"
                minWidth: VfTheme.dp(76)
                onClicked: root.requestDeleteKey()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("api_keys.save_key", "Save key"))
                tone: "primary"
                minWidth: VfTheme.dp(94)
                onClicked: root.saveKey()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("common.close", "Close"))
                minWidth: VfTheme.dp(78)
                onClicked: root.accept()
            }
        }
    }

    component HeaderCell: Text {
        color: VfTheme.textMuted
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(10)
        font.weight: Font.Black
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    component BodyCell: Text {
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(11)
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    component FieldLabel: Text {
        color: VfTheme.textSubtle
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(10)
        font.weight: Font.Black
    }

    component FieldBackground: Rectangle {
        property bool active: false
        radius: VfTheme.dp(6)
        color: VfTheme.surface
        border.color: active ? "#0EA5E9" : VfTheme.borderStrong
    }

}
