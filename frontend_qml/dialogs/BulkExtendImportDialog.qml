import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "bulkExtendImportDialog"   // tour: closed by finding this on Overlay.overlay
    parent: Overlay.overlay

    property bool queueMode: false
    property int pendingCount: 0
    property bool editMode: false
    property string editBatchId: ""
    property bool ignoreEmptyLines: true
    property var previewItems: []
    property var initialItems: []
    property string statusText: ""
    property string errorText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal importItemsRequested(var items, bool queueMode)
    signal batchUpdated(string batchId, var items)

    header: VfDialogHeader {
        title: root.editMode
            ? root.trText("bulk_extend.edit_batch_title", "Edit batch")
            : root.trText("bulk_extend.window_title", "Bulk Extend Import")
        iconName: "clipboard"
        onCloseClicked: root.reject()
    }
    modal: true
    width: VfDialogMetrics.width(parent, VfTheme.dp(1125), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(875), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.radiusPanel
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    onOpened: {
        if (root.initialItems && root.initialItems.length > 0) {
            promptInput.text = root.serializeItems(root.initialItems)
            root.previewItems = root.recalculate(root.initialItems)
            root.initialItems = []
        } else {
            root.reparse()
        }
    }

    function trText(key, fallback) {
        if (typeof i18n !== "undefined" && i18n && i18n.t)
            return (void i18n.revision, i18n.t(key, fallback))
        return fallback
    }

    function openForImport(nextQueueMode, nextPendingCount) {
        root.editMode = false
        root.editBatchId = ""
        root.queueMode = Boolean(nextQueueMode)
        root.pendingCount = Number(nextPendingCount || 0)
        promptInput.text = ""
        root.initialItems = []
        root.previewItems = []
        root.statusText = ""
        root.errorText = ""
        root.open()
    }

    function openForItems(items, batchId, nextQueueMode) {
        root.editMode = true
        root.editBatchId = String(batchId || "")
        root.queueMode = Boolean(nextQueueMode)
        root.pendingCount = 0
        root.initialItems = root.toJsArray(items)   // QVariantList-safe (Array.isArray fails on it)
        promptInput.text = ""
        root.previewItems = []
        root.statusText = ""
        root.errorText = ""
        root.open()
    }

    function openForGenerated(items) {
        root.editMode = false
        root.editBatchId = ""
        root.queueMode = false
        root.pendingCount = 0
        // `items` is a QVariantList from the controller — Array.isArray() returns FALSE for it
        // (a sequence, not a real JS Array), so Array.isArray?…:[] silently produced an EMPTY
        // dialog. Copy by iterating `.length` instead.
        root.initialItems = root.toJsArray(items)
        promptInput.text = ""
        root.previewItems = []
        root.statusText = ""
        root.errorText = ""
        root.open()
    }

    function toJsArray(value) {
        var out = []
        var len = (value && value.length !== undefined) ? value.length : 0
        var i = 0
        for (i = 0; i < len; i++)
            out.push(value[i])
        return out
    }

    function applyCommitResult(result) {
        var response = result || ({ ok: false, error: "missing_extend_import_result", message: "No extend import result returned." })
        if (response.ok === false) {
            var message = String(response.message || response.error || response.code || "Extend import failed.")
            root.errorText = message
            root.statusText = ""
            root.feedbackTitle = "Import failed"
            root.feedbackMessage = message
            feedbackDialog.open()
            return
        }
        root.errorText = ""
        root.statusText = String(response.message || "Extend import saved.")
        root.accept()
    }

    function parseLines(text) {
        var jsonPrompts = root.tryParseJsonBlocks(text)
        if (jsonPrompts !== null)
            return jsonPrompts

        var lines = String(text || "").split(/\r?\n/)
        var prompts = []
        for (var i = 0; i < lines.length; i++) {
            var raw = String(lines[i] || "").trim()
            if (raw.length === 0 || raw === "---") {
                if (!root.ignoreEmptyLines && prompts.length > 0)
                    prompts.push(null)
                continue
            }
            prompts.push(raw)
        }
        return prompts
    }

    function appendExtractedPrompt(target, value) {
        if (Array.isArray(value)) {
            for (var i = 0; i < value.length; i++)
                root.appendExtractedPrompt(target, value[i])
            return
        }
        var text = String(value || "").trim()
        if (text.length > 0)
            target.push(text)
    }

    function extractPromptFromJson(value) {
        if (typeof value === "string") {
            var textValue = value.trim()
            return textValue.length > 0 ? textValue : null
        }
        if (Array.isArray(value)) {
            var arrayPrompts = []
            for (var i = 0; i < value.length; i++)
                root.appendExtractedPrompt(arrayPrompts, root.extractPromptFromJson(value[i]))
            return arrayPrompts.length > 0 ? arrayPrompts : null
        }
        if (value && typeof value === "object") {
            var keys = ["prompt", "text", "content"]
            for (var j = 0; j < keys.length; j++) {
                if (value[keys[j]] !== undefined && value[keys[j]] !== null) {
                    var nested = root.extractPromptFromJson(value[keys[j]])
                    if (nested !== null)
                        return nested
                }
            }
        }
        return null
    }

    function tryParseJsonBlocks(text) {
        var stripped = String(text || "").trim()
        if (stripped.length === 0)
            return null
        var firstChar = stripped.charAt(0)
        if (firstChar !== "{" && firstChar !== "[" && firstChar !== "\"")
            return null

        var blocks = stripped.split(/\n\s*\n+/)
        var prompts = []
        for (var i = 0; i < blocks.length; i++) {
            var block = String(blocks[i] || "").trim()
            if (block.length === 0)
                continue
            try {
                root.appendExtractedPrompt(prompts, root.extractPromptFromJson(JSON.parse(block)))
            } catch (error) {
                return null
            }
        }
        return prompts.length > 0 ? prompts : null
    }

    function reparse() {
        var prompts = parseLines(promptInput.text)
        var items = []
        var chainIndex = 0
        var position = 0
        for (var i = 0; i < prompts.length; i++) {
            var prompt = prompts[i]
            if (prompt === null) {
                if (position > 0) {
                    chainIndex += 1
                    position = 0
                }
                continue
            }
            var cardType = items.length === 0 || position === 0 ? "ROOT" : "EXTEND"
            items.push({
                prompt: String(prompt),
                card_type: cardType,
                chain_index: chainIndex,
                position_in_chain: position
            })
            position += 1
        }
        root.previewItems = items
    }

    function serializeItems(items) {
        var lines = []
        var lastChain = null
        for (var i = 0; i < items.length; i++) {
            var item = items[i] || {}
            var chainIndex = String(item.chain_index === undefined ? "" : item.chain_index)
            if (lastChain !== null && chainIndex !== lastChain)
                lines.push("---")
            lines.push(String(item.prompt || item.text || ""))
            lastChain = chainIndex
        }
        return lines.join("\n")
    }

    function recalculate(items) {
        var chainIndex = 0
        var position = 0
        var next = []
        for (var i = 0; i < items.length; i++) {
            var item = Object.assign({}, items[i])
            if (item.card_type === "ROOT") {
                if (position > 0)
                    chainIndex += 1
                position = 0
            }
            item.chain_index = chainIndex
            item.position_in_chain = position
            next.push(item)
            position += 1
        }
        return next
    }

    function toggleItem(index) {
        if (index <= 0 || index >= root.previewItems.length)
            return
        var items = root.previewItems.slice()
        var item = Object.assign({}, items[index])
        item.card_type = item.card_type === "ROOT" ? "EXTEND" : "ROOT"
        items[index] = item
        root.previewItems = root.recalculate(items)
    }

    function countByType(type) {
        var total = 0
        for (var i = 0; i < root.previewItems.length; i++) {
            if (root.previewItems[i].card_type === type)
                total += 1
        }
        return total
    }

    function chainCount() {
        var seen = {}
        for (var i = 0; i < root.previewItems.length; i++)
            seen[String(root.previewItems[i].chain_index)] = true
        return Object.keys(seen).length
    }

    function asSingleChain() {
        return root.chainCount() <= 1
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(16)
        spacing: VfTheme.dp(8)

        Text {
            Layout.fillWidth: true
            Layout.topMargin: 12
            text: (void i18n.revision, i18n.t("bulk_extend_import_dialog.title", "Bulk Import - Paste prompts, điều chỉnh type, rồi Import"))
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(14)
            font.weight: Font.Bold
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            text: (void i18n.revision, i18n.t("bulk_extend_import_dialog.hint_root_extend", "Prompt 1 = ROOT | Các dòng sau = EXTEND | Click item để đổi ROOT/EXTEND và tạo hoặc gộp chain"))
            color: VfTheme.textSubtle
            wrapMode: Text.WordWrap
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12

            CheckBox {
                id: ignoreEmpty
                objectName: "bulkExtendIgnoreEmptyToggle"   // tour
                text: (void i18n.revision, i18n.t("bulk_extend_import_dialog.ignore_empty_lines", "Bỏ qua dòng trống"))
                checked: root.ignoreEmptyLines
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                onToggled: {
                    root.ignoreEmptyLines = checked
                    root.reparse()
                }
            }

            Item { Layout.fillWidth: true }
        }

        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            orientation: Qt.Horizontal

            Rectangle {
                SplitView.preferredWidth: Math.min(VfTheme.dp(420), Math.max(VfTheme.dp(300), Math.round(root.width * 0.42)))
                SplitView.minimumWidth: Math.min(VfTheme.dp(280), Math.max(VfTheme.dp(220), Math.round(root.width * 0.28)))
                color: VfTheme.surface

                ColumnLayout {
                    anchors.fill: parent
                    anchors.rightMargin: VfTheme.dp(5)
                    spacing: VfTheme.dp(6)

                    Text {
                        text: (void i18n.revision, i18n.t("bulk_extend_import_dialog.paste_prompts_label", "Paste Prompts (mỗi dòng = 1 card):"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: VfTheme.dp(6)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.borderStrong

                        ScrollView {
                            id: promptScroll
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(10)
                            contentWidth: availableWidth
                            contentHeight: promptInput.implicitHeight
                            clip: true
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                            TextArea {
                                id: promptInput
                                objectName: "bulkExtendInput"   // tour
                                width: promptScroll.availableWidth
                                property string emptyHint: (void i18n.revision, i18n.t("bulk_extend_import_dialog.empty_hint", "Paste prompts ở đây (mỗi dòng = 1 card):\n\nScene 1: Mở đầu trong rừng\nScene 2: Nhân vật đi bộ\nScene 3: Gặp con gấu\nScene 4: ...\n...\n\nPrompt 1 = ROOT (tự động)\nCòn lại = EXTEND (tự động)\nDòng trống hoặc --- có thể tạo chain mới khi tắt bỏ qua dòng trống\nClick item để đổi ROOT/EXTEND"))
                                placeholderText: ""
                                wrapMode: TextArea.Wrap
                                selectByMouse: true
                                font.family: "Consolas"
                                font.pixelSize: VfTheme.dp(12)
                                background: Item {}
                                onTextChanged: root.reparse()
                            }
                        }

                        Text {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(22)
                            visible: promptInput.text.length === 0
                            text: promptInput.emptyHint
                            color: VfTheme.textSubtle
                            wrapMode: Text.WordWrap
                            font.family: "Consolas"
                            font.pixelSize: VfTheme.dp(14)
                        }
                    }
                }
            }

            Rectangle {
                SplitView.fillWidth: true
                SplitView.minimumWidth: Math.min(VfTheme.dp(360), Math.max(VfTheme.dp(260), Math.round(root.width * 0.32)))
                color: VfTheme.surface

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(5)
                    spacing: VfTheme.dp(6)

                    Text {
                        text: (void i18n.revision, i18n.t("bulk_extend_import_dialog.preview_label", "Preview (click để đổi type):"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: VfTheme.dp(6)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.borderStrong
                        clip: true

                        ListView {
                            id: previewList
                            objectName: "bulkExtendPreview"   // tour
                            anchors.fill: parent
                            model: root.previewItems
                            clip: true
                            reuseItems: true

                            delegate: Rectangle {
                                width: previewList.width
                                height: VfTheme.dp(44)
                                color: modelData.card_type === "ROOT" ? VfTheme.blueFill : VfTheme.greenFill
                                border.color: VfTheme.border

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(12)
                                    anchors.rightMargin: VfTheme.dp(12)
                                    spacing: VfTheme.dp(8)

                                    Text {
                                        Layout.preferredWidth: VfTheme.dp(96)
                                        text: (modelData.card_type === "ROOT" ? "ROOT" : "EXTEND") + " #" + (modelData.chain_index + 1) + "." + (modelData.position_in_chain + 1)
                                        color: modelData.card_type === "ROOT" ? VfTheme.blueText : VfTheme.greenText
                                        font.family: "Consolas"
                                        font.pixelSize: VfTheme.dp(12)
                                        font.weight: Font.Bold
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        // Prefer the readable `visual` prose; the `prompt` is the full
                                        // JSON scene (shown/edited in the paste area, dispatched as text).
                                        text: String(modelData.visual || modelData.prompt || "")
                                        color: VfTheme.text
                                        font.family: "Consolas"
                                        font.pixelSize: VfTheme.dp(12)
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: index > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: root.toggleItem(index)
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: root.previewItems.length === 0
                            text: (void i18n.revision, i18n.t("bulk_extend_import_dialog.zero_cards", "0 cards"))
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                        }
                    }

                    Text {
                        text: root.previewItems.length + " cards | " + root.chainCount() + " " + (void i18n.revision, i18n.t("bulk_extend_import_dialog.chains_label", "chuỗi")) + " | ROOT: " + root.countByType("ROOT") + " | EXTEND: " + root.countByType("EXTEND")
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: root.errorText.length > 0 || root.statusText.length > 0
                        text: root.errorText.length > 0 ? root.errorText : root.statusText
                        color: root.errorText.length > 0 ? VfTheme.redText : VfTheme.textSubtle
                        wrapMode: Text.WordWrap
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            Layout.bottomMargin: 12
            spacing: VfTheme.dp(8)

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: VfTheme.dp(34)
                radius: VfTheme.dp(4)
                color: VfTheme.surfaceSoft

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(12)
                    anchors.rightMargin: VfTheme.dp(12)
                    verticalAlignment: Text.AlignVCenter
                    text: (void i18n.revision, i18n.t("bulk_extend_import_dialog.click_item_hint", "Click item: EXTEND <-> ROOT để tạo chain mới hoặc gộp vào chain trước"))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    elide: Text.ElideRight
                }
            }

            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Hủy"))
                minWidth: VfTheme.dp(96)
                onClicked: root.reject()
            }

            VfButton {
                objectName: "bulkExtendAccept"   // tour
                text: root.editMode ? (void i18n.revision, i18n.t("bulk_extend_import_dialog.save_changes", "Lưu thay đổi")) : (root.queueMode ? (void i18n.revision, i18n.t("bulk_extend_import_dialog.add_to_queue", "Thêm vào hàng chờ")) : (void i18n.revision, i18n.t("bulk_extend_import_dialog.import_run_now", "Import & Chạy ngay")))
                tone: root.queueMode ? "warning" : "success"
                minWidth: VfTheme.dp(150)
                enabled: root.previewItems.length > 0
                onClicked: {
                    root.errorText = ""
                    if (root.editMode)
                        root.batchUpdated(root.editBatchId, root.previewItems)
                    else
                        root.importItemsRequested(root.previewItems, root.queueMode)
                }
            }
        }
    }

    Dialog {
        id: feedbackDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        modal: true
        title: root.feedbackTitle
        standardButtons: Dialog.Ok

        contentItem: Text {
            width: VfDialogMetrics.width(parent, VfTheme.dp(320), VfTheme.dp(64))
            wrapMode: Text.WordWrap
            text: root.feedbackMessage
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
        }
    }
}
