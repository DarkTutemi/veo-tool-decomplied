import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    objectName: "promptEditDialog"

    property var card: ({})
    property string cardId: ""
    property string promptText: ""
    property bool readOnlyMode: false
    property string dialogTitle: ""
    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property bool allowRegenerate: false
    property bool regeneratePending: false
    property var assetSlots: []

    signal saveRequested(string cardId, string title, string prompt)
    signal promptSaved(string prompt)
    signal regenerateRequested(string cardId, string prompt, var card)
    signal assetReplaceRequested(string jobId, int slotIndex)

    title: root.dialogTitle.length > 0
        ? root.dialogTitle
        : (root.readOnlyMode
            ? (void i18n.revision, i18n.t("prompt_view.title_view", "View Prompt"))
            : (void i18n.revision, i18n.t("prompt_view.title_edit", "Edit Prompt")))
    header: null
    parent: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, readOnlyMode ? 980 : 875, 48)
    height: VfDialogMetrics.height(parent, readOnlyMode ? 720 : 625, 48)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    function resolvePrompt(cardData) {
        var payload = cardData || ({})
        var prompt = String(payload.prompt || payload.text || "")
        if (prompt.length === 0 && payload.prompts && payload.prompts.length > 0)
            prompt = String(payload.prompts[0].prompt || payload.prompts[0].text || payload.prompts[0].idea || "")
        return prompt
    }

    function openFor(cardData, readOnly) {
        root.card = cardData || ({})
        root.readOnlyMode = readOnly === undefined
            ? Boolean(root.card.read_only || root.card.readOnly)
            : Boolean(readOnly)
        root.cardId = String(
            root.card.id || root.card.row_id || root.card.batch_id
            || root.card.job_id || ""
        )
        root.promptText = resolvePrompt(root.card)
        root.dialogTitle = String(
            root.card.dialog_title || root.card.dialogTitle
            || (root.readOnlyMode
                ? (void i18n.revision, i18n.t("prompt_view.title_view", "View Prompt"))
                : (void i18n.revision, i18n.t("prompt_view.title_edit", "Edit Prompt")))
        )
        root.allowRegenerate = Boolean(
            root.card.allow_regenerate || root.card.allowRegenerate
        )
        root.assetSlots = root.card.assetSlots || root.card.asset_slots || []
        root.regeneratePending = false
        root.statusText = ""
        promptInput.text = root.promptText
        root.open()
    }

    function wordCount(text) {
        var normalized = String(text || "").trim()
        if (normalized.length === 0)
            return 0
        return normalized.split(/\s+/).length
    }

    function countColor(text) {
        var length = String(text || "").length
        if (length > 1000)
            return "#DC2626"
        if (length > 500)
            return "#F59E0B"
        return "#10B981"
    }

    function resetText() {
        promptInput.text = root.promptText
        root.statusText = ""
    }

    function openReadOnly(cardData) {
        root.openFor(cardData, true)
    }

    function applyRegenerateResult(result) {
        var response = result || ({})
        root.regeneratePending = false
        if (response.ok === false) {
            var message = String(
                response.message || response.error || response.code
                || "Không thể tạo lại."
            )
            root.statusText = message
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            root.feedbackMessage = message
            feedbackDialog.open()
            return
        }
        root.statusText = String(response.message || "Đã gửi yêu cầu tạo lại.")
        root.accept()
    }

    function promptTextForVisualTest() {
        return String(promptInput.text || root.promptText || "")
    }

    function setPromptForVisualTest(text) {
        promptInput.text = String(text || "")
        return true
    }

    function requestSaveForVisualTest() {
        if (root.readOnlyMode)
            return false
        var prompt = promptInput.text.trim()
        root.promptText = prompt
        root.statusText = ""
        root.promptSaved(prompt)
        root.saveRequested(root.cardId, "", prompt)
        return true
    }

    function setAssetSlots(slots) {
        root.assetSlots = slots || []
    }

    function slotIsCharacter(slot) {
        if (!slot)
            return false
        var typeName = String(slot.slotType || slot.asset_type || slot.type || "")
        if (typeName.toLowerCase() === "character")
            return true
        var asset = slot.asset || ({})
        var id = String(slot.id || asset.id || "")
        return id.toUpperCase().indexOf("CHAR_") === 0
    }

    function slotReplaceLocked(slot) {
        return !(slot && slot.filled)
    }

    function assetPreview(slot) {
        if (!slot)
            return ""
        var raw = String(slot.previewSrc || slot.preview_src || slot.path || "")
        if (raw.length === 0 && slot.asset)
            raw = String(slot.asset.previewSrc || slot.asset.path || "")
        if (raw.length === 0)
            return ""
        if (raw.indexOf("file:") === 0 || raw.indexOf("image://") === 0
                || raw.indexOf("qrc:") === 0 || raw.indexOf("data:") === 0
                || raw.indexOf("http://") === 0 || raw.indexOf("https://") === 0)
            return raw
        return encodeURI("file:///" + raw.replace(/\\/g, "/"))
    }

    function applySaveResult(result, fallbackPrompt) {
        var response = result || ({})
        if (response.ok === false) {
            var message = String(response.message || response.error || response.code || "Save failed.")
            root.statusText = message
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            root.feedbackMessage = message
            feedbackDialog.open()
            return
        }
        var prompt = String(fallbackPrompt || promptInput.text || "")
        if (response.row && response.row.prompt !== undefined)
            prompt = String(response.row.prompt || "")
        if (response.card && response.card.prompt !== undefined)
            prompt = String(response.card.prompt || "")
        root.promptText = prompt
        promptInput.text = prompt
        root.statusText = String(response.message || "Prompt saved.")
        root.accept()
    }

    background: Rectangle {
        radius: VfTheme.radiusPanel
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(25)
        spacing: VfTheme.dp(12)

        Text {
            Layout.fillWidth: true
            text: root.dialogTitle.length > 0
                ? root.dialogTitle
                : (root.readOnlyMode
                    ? (void i18n.revision, i18n.t("prompt_view.title_view", "View Prompt"))
                    : (void i18n.revision, i18n.t("prompt_view.title_edit", "Edit Prompt")))
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(16)
            font.weight: Font.Bold
        }

        Text {
            Layout.fillWidth: true
            visible: root.assetSlots && root.assetSlots.length > 0
            text: (void i18n.revision, i18n.t("job_panel.edit_assets_hint", "Object/image slots can be replaced. Characters stay locked."))
            color: VfTheme.textMuted
            wrapMode: Text.Wrap
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
        }

        Row {
            Layout.fillWidth: true
            spacing: VfTheme.dp(6)
            visible: root.assetSlots && root.assetSlots.length > 0
            Repeater {
                model: root.assetSlots
                Rectangle {
                    id: slotTile
                    required property var modelData
                    required property int index
                    width: VfTheme.dp(52)
                    height: VfTheme.dp(52)
                    radius: VfTheme.dp(8)
                    color: VfTheme.canvas
                    border.color: VfTheme.border
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 1
                        source: root.assetPreview(slotTile.modelData)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: String(root.assetPreview(slotTile.modelData) || "").length === 0
                        text: "+"
                        color: VfTheme.textSubtle
                        font.pixelSize: VfTheme.dp(16)
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: VfTheme.dp(2)
                        width: VfTheme.dp(14)
                        height: VfTheme.dp(14)
                        radius: VfTheme.dp(3)
                        color: VfTheme.surface
                        opacity: 0.92
                        Text {
                            anchors.centerIn: parent
                            text: root.slotIsCharacter(slotTile.modelData) ? "👤" : "📦"
                            font.pixelSize: VfTheme.dp(8)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: !root.slotReplaceLocked(slotTile.modelData)
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.assetReplaceRequested(root.cardId, Number(slotTile.index))
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: VfTheme.dp(8)
            color: VfTheme.surfaceSoft
            border.color: promptInput.activeFocus ? "#3B82F6" : VfTheme.borderStrong
            border.width: 1
            clip: true

            ScrollView {
                id: promptScroll
                anchors.fill: parent
                anchors.margins: VfTheme.dp(12)
                contentWidth: availableWidth
                contentHeight: promptInput.implicitHeight
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                TextArea {
                    id: promptInput
                    width: promptScroll.availableWidth
                    text: root.promptText
                    wrapMode: TextArea.Wrap
                    selectByMouse: true
                    readOnly: root.readOnlyMode
                    color: VfTheme.text
                    placeholderTextColor: VfTheme.textSubtle
                    selectedTextColor: "#FFFFFF"
                    selectionColor: "#3B82F6"
                    font.family: "Segoe UI"
                    font.pixelSize: VfTheme.dp(13)
                    background: Item {}
                }
            }
        }

        Text {
            Layout.fillWidth: true
            visible: !root.readOnlyMode && root.statusText.length > 0
            text: root.statusText
            color: VfTheme.redText
            wrapMode: Text.WordWrap
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
        }

        Text {
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("prompt_view.char_count", "Characters: {char_count} | Words: {word_count}"))
                .replace("{char_count}", String(promptInput.text.length))
                .replace("{word_count}", String(root.wordCount(promptInput.text)))
            color: root.countColor(promptInput.text)
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(46)
            spacing: VfTheme.dp(14)

            Item {
                Layout.preferredWidth: resetButton.visible
                    ? resetButton.implicitWidth : 0
                Layout.preferredHeight: VfTheme.dp(42)

                VfButton {
                    id: resetButton
                    anchors.fill: parent
                    visible: !root.readOnlyMode
                    text: (void i18n.revision, i18n.t("prompt_view.btn_reset", "Reset"))
                    minWidth: VfTheme.dp(90)
                    implicitHeight: VfTheme.dp(42)
                    onClicked: root.resetText()
                }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: VfTheme.dp(10)

                VfButton {
                    visible: !root.readOnlyMode
                    text: (void i18n.revision, i18n.t("prompt_view.btn_cancel", "Cancel"))
                    minWidth: VfTheme.dp(70)
                    implicitHeight: VfTheme.dp(42)
                    onClicked: root.reject()
                }

                VfButton {
                    visible: root.readOnlyMode
                    text: (void i18n.revision, i18n.t("prompt_view.btn_close", "Close"))
                    minWidth: VfTheme.dp(90)
                    implicitHeight: VfTheme.dp(42)
                    onClicked: root.accept()
                }

                VfButton {
                    visible: root.allowRegenerate
                    enabled: !root.regeneratePending
                             && String(promptInput.text || "").trim().length > 0
                    text: root.regeneratePending
                        ? "ĐANG GỬI..."
                        : (void i18n.revision, i18n.t(
                            "job_panel.regenerate_btn", "TẠO LẠI"
                        ))
                    tone: "primary"
                    minWidth: VfTheme.dp(132)
                    implicitHeight: VfTheme.dp(42)
                    onClicked: {
                        root.regeneratePending = true
                        root.regenerateRequested(
                            root.cardId,
                            String(promptInput.text || "").trim(),
                            root.card
                        )
                    }
                }

                VfButton {
                    visible: !root.readOnlyMode
                    text: (void i18n.revision, i18n.t("prompt_view.btn_save", "Save"))
                    tone: "primary"
                    minWidth: VfTheme.dp(160)
                    implicitHeight: VfTheme.dp(42)
                    onClicked: {
                        var prompt = promptInput.text.trim()
                        root.promptText = prompt
                        root.statusText = ""
                        root.promptSaved(prompt)
                        root.saveRequested(root.cardId, "", prompt)
                    }
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
}
