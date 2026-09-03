import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"
import "MediaSourceResolver.js" as MediaSourceResolver

// Extracted verbatim from WorkPanelWorkspace.qml inline component (0 parent deps).
Rectangle {
    id: normalCard

    property var card: ({})
    // NOTE: named promptIndex (not "index") on purpose — a delegate property
    // called "index" shadows the Repeater's context index, so `index: index`
    // self-binds to 0 and every card renders "#1". See call site.
    property int promptIndex: 0
    property string feature: "multi_asset"
    property int assetCount: 0
    property bool voiceSyncEnabled: false

    signal actionRequested(string actionId, var payload)

    function assetIsCharacter(slotIndex) {
        var asset = assetAt(slotIndex)
        return Boolean(asset && (asset.is_character || asset.asset_type === "character"))
    }

    function assetHasVoice(slotIndex) {
        var asset = assetAt(slotIndex)
        return Boolean(asset && asset.has_bound_voice)
    }

    height: VfTheme.dp(142)
    radius: VfTheme.dp(8)
    color: VfTheme.surface
    border.width: 1
    border.color: VfTheme.border
    clip: true

    function textValue(key, fallback) {
        if (normalCard.card && normalCard.card[key] !== undefined && normalCard.card[key] !== null && String(normalCard.card[key]).length > 0)
            return String(normalCard.card[key])
        return fallback || ""
    }

    function cardId() {
        return textValue("id", textValue("row_id", textValue("batch_id", "")))
    }

    function promptText() {
        return textValue("prompt", textValue("text", ""))
    }

    function promptLabel() {
        var raw = (void i18n.revision, i18n.t("prompt_card.prompt_label", "PROMPT: #{num}"))
        return raw.replace("{num}", String(normalCard.promptIndex + 1)).replace("#N", "#" + String(normalCard.promptIndex + 1))
    }

    function durationLabel() {
        var raw = normalCard.card ? (normalCard.card.duration_seconds || normalCard.card.duration || "") : ""
        var value = Number(raw || 0)
        if (value > 0)
            return String(value) + "s"
        return String((normalCard.card || {}).duration_marker || "")
    }

    function slotKey(slotIndex) {
        if (normalCard.feature === "image")
            return "single"
        if (normalCard.feature === "interpolation")
            return slotIndex === 0 ? "start" : "end"
        return "asset" + String(slotIndex + 1)
    }

    // Model chỉ gắn entity/voice cho tối đa 3 nhân vật; slot còn lại là object.
    readonly property int characterSlotLimit: 3

    function slotIsCharacterSlot(slotIndex) {
        return normalCard.feature === "multi_asset" && slotIndex < normalCard.characterSlotLimit
    }

    function slotLabel(slotIndex) {
        if (normalCard.feature === "image")
            return (void i18n.revision, i18n.t("prompt_card.add_image", "+ Image"))
        if (normalCard.feature === "interpolation")
            return slotIndex === 0 ? (void i18n.revision, i18n.t("prompt_card.add_start", "+ Start")) : (void i18n.revision, i18n.t("prompt_card.add_end", "+ End"))
        if (normalCard.feature === "multi_asset") {
            if (slotIndex < normalCard.characterSlotLimit)
                return (void i18n.revision, i18n.t("prompt_card.add_character", "+ Character {index}")).replace("{index}", String(slotIndex + 1))
            return (void i18n.revision, i18n.t("prompt_card.add_object", "+ Obj {index}")).replace("{index}", String(slotIndex - normalCard.characterSlotLimit + 1))
        }
        return (void i18n.revision, i18n.t("prompt_card.add_asset", "+ Asset {index}")).replace("{index}", String(slotIndex + 1))
    }

    function slotWidth() {
        return normalCard.feature === "multi_asset" ? 90 : 100
    }

    function assetPaneWidth() {
        if (normalCard.assetCount <= 0)
            return 0
        return normalCard.assetCount * normalCard.slotWidth() + (normalCard.assetCount - 1) * 6
    }

    function assetAt(slotIndex) {
        var assets = normalCard.card.assets || []
        // Nếu có asset gắn slot_index -> render theo slot_index (đúng ô đã click).
        var hasSlotted = false
        for (var i = 0; i < assets.length; ++i) {
            if (assets[i] && assets[i].slot_index !== undefined) { hasSlotted = true; break }
        }
        if (hasSlotted) {
            for (var k = 0; k < assets.length; ++k) {
                if (assets[k] && Number(assets[k].slot_index) === slotIndex)
                    return assets[k]
            }
            return ({})
        }
        // Legacy/bulk chưa tag slot_index -> positional.
        return assets.length > slotIndex ? assets[slotIndex] : ({})
    }

    function assetTitle(slotIndex) {
        var asset = assetAt(slotIndex)
        return String(asset.name || asset.title || asset.file_name || asset.path || normalCard.slotLabel(slotIndex))
    }

    function assetName(slotIndex) {
        var asset = assetAt(slotIndex)
        return String(asset.name || asset.title || asset.file_name || "")
    }

    function slotRoleLabel(slotIndex) {
        if (normalCard.feature !== "multi_asset")
            return ""
        if (slotIndex < normalCard.characterSlotLimit)
            return (void i18n.revision, i18n.t("prompt_card.role_character", "Character {index}")).replace("{index}", String(slotIndex + 1))
        return (void i18n.revision, i18n.t("prompt_card.role_object", "Obj {index}")).replace("{index}", String(slotIndex - normalCard.characterSlotLimit + 1))
    }

    function slotMediaFilterType(slotIndex) {
        if (normalCard.feature !== "multi_asset")
            return ""
        return normalCard.slotIsCharacterSlot(slotIndex) ? "character" : "object"
    }

    function slotCaption(slotIndex) {
        var name = normalCard.assetName(slotIndex)
        if (name.length === 0)
            return ""
        var role = normalCard.slotRoleLabel(slotIndex)
        return role.length > 0 ? role + " · " + name : name
    }

    function normalizedImageSource(value) {
        return MediaSourceResolver.normalizedImageSource(value)
    }

    function assetSource(slotIndex) {
        var asset = assetAt(slotIndex)
        var candidates = [
            asset.thumbnail_base64 || "",
            asset.thumbnail_file_url || "",
            asset.thumbnail_url || "",
            asset.file_url || "",
            asset.preview_url || "",
            asset.blob_file_url || "",
            asset.thumbnail_path || "",
            asset.thumbnail_file_path || "",
            asset.blob_path || "",
            asset.preview_path || "",
            asset.original_source_path || "",
            asset.path || "",
            asset.source_path || "",
            asset.file_path || "",
            asset.image_base64 || "",
            asset.base64 || "",
            asset.thumbnail || ""
        ]
        for (var i = 0; i < candidates.length; ++i) {
            var source = normalCard.normalizedImageSource(candidates[i])
            if (source.length > 0)
                return source
        }
        return ""
    }

    function fileUrl(value) {
        return MediaSourceResolver.localFileUrl(value)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(8)
        spacing: VfTheme.dp(6)

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(28)
            spacing: VfTheme.dp(8)

            CheckBox {
                id: normalCardCheck

                checked: normalCard.card.selected !== false
                Layout.preferredWidth: VfTheme.dp(22)
                Layout.preferredHeight: VfTheme.dp(22)

                // CheckBox tự toggle `checked` khi click (phá binding). Gửi action
                // cập nhật backend rồi khôi phục binding để bám nguồn sự thật.
                onClicked: {
                    normalCard.actionRequested("prompt_card.selection", {
                        card: normalCard.card,
                        card_id: normalCard.cardId(),
                        row_id: normalCard.cardId(),
                        route: "normal",
                        index: normalCard.promptIndex,
                        selected: checked
                    })
                    checked = Qt.binding(function() { return normalCard.card.selected !== false })
                }

                indicator: Rectangle {
                    implicitWidth: VfTheme.dp(22)
                    implicitHeight: VfTheme.dp(22)
                    x: normalCardCheck.leftPadding
                    y: parent.height / 2 - height / 2
                    radius: VfTheme.dp(4)
                    color: normalCardCheck.checked ? VfTheme.primary : VfTheme.surface
                    border.width: 1
                    border.color: normalCardCheck.checked ? VfTheme.primary : VfTheme.borderStrong
                }
            }

            Text {
                text: normalCard.promptLabel()
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                font.weight: VfTheme.weightTitle
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                visible: normalCard.durationLabel().length > 0
                Layout.preferredWidth: visible ? Math.max(46, normalDurationBadgeText.implicitWidth + 16) : 0
                Layout.preferredHeight: VfTheme.dp(24)
                radius: VfTheme.dp(12)
                color: VfTheme.amberFill
                border.width: 1
                border.color: "#F59E0B"

                Text {
                    id: normalDurationBadgeText
                    anchors.centerIn: parent
                    text: normalCard.durationLabel()
                    color: VfTheme.amberText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    font.weight: VfTheme.weightStrong
                }
            }

            Item { Layout.fillWidth: true }

            VfButton {
                actionId: "prompt_card.delete"
                text: (void i18n.revision, i18n.t("prompt_card.delete", "Delete"))
                tone: "danger"
                minWidth: VfTheme.dp(72)
                Layout.preferredHeight: VfTheme.dp(29)
                onClicked: normalCard.actionRequested(actionId, {
                    card: normalCard.card,
                    card_id: normalCard.cardId(),
                    row_id: normalCard.cardId(),
                    route: "normal",
                    index: normalCard.promptIndex
                })
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: VfTheme.dp(10)

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(4)
                color: VfTheme.surface
                border.color: VfTheme.borderStrong
                clip: true

                TextArea {
                    id: normalPromptInput
                    objectName: "normalPromptInput"
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(6)
                    text: normalCard.promptText()
                    placeholderText: (void i18n.revision, i18n.t("prompt_card.prompt_placeholder", "Enter prompt here..."))
                    wrapMode: TextEdit.Wrap
                    selectByMouse: true
                    color: VfTheme.text
                    placeholderTextColor: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                    background: Item {}
                    // Commit inline edits to the backing card on every change.
                    // The "Create Video" button is a MouseArea that does NOT
                    // steal keyboard focus, so a focus-loss commit is unreliable;
                    // committing per keystroke keeps card.prompt current for submit.
                    // The controller updates the card in place WITHOUT emitting
                    // cardsChanged so the text cursor is not reset mid-typing.
                    onTextChanged: {
                        if (text !== normalCard.promptText())
                            normalCard.actionRequested("prompt_card.inline_prompt", {
                                card_id: normalCard.cardId(),
                                row_id: normalCard.cardId(),
                                route: "normal",
                                preview_only: !!(normalCard.card || {}).preview_only,
                                prompt: text
                            })
                    }
                }
            }

            Rectangle {
                visible: normalCard.assetCount > 0
                Layout.preferredWidth: visible ? normalCard.assetPaneWidth() : 0
                Layout.preferredHeight: VfTheme.dp(90)
                Layout.alignment: Qt.AlignTop
                radius: 0
                color: VfTheme.surfaceSoft
                border.width: 0
                clip: true

                Row {
                    anchors.fill: parent
                    spacing: VfTheme.dp(6)

                    Repeater {
                        model: normalCard.assetCount

                        Item {
                            width: normalCard.slotWidth()
                            height: VfTheme.dp(90)

                            Rectangle {
                                id: assetButton
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: VfTheme.dp(76)
                                radius: VfTheme.dp(8)
                                color: slotMouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface
                                border.color: slotMouse.containsMouse ? VfTheme.violet : VfTheme.borderStrong
                                border.width: 2
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(4)
                                    source: normalCard.assetSource(index)
                                    fillMode: Image.PreserveAspectCrop
                                    visible: String(source).length > 0
                                    asynchronous: true
                                    sourceSize.width: 320
                                    sourceSize.height: 240
                                }

                                Text {
                                    anchors.centerIn: parent
                                    width: parent.width - 12
                                    text: normalCard.assetTitle(index)
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    font.weight: VfTheme.weightControl
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    wrapMode: Text.WordWrap
                                    visible: normalCard.assetSource(index).length === 0
                                }

                                Rectangle {
                                    id: voiceBadge
                                    visible: normalCard.assetHasVoice(index)
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: VfTheme.dp(3)
                                    width: VfTheme.dp(20)
                                    height: VfTheme.dp(20)
                                    radius: width / 2
                                    color: normalCard.voiceSyncEnabled ? VfTheme.violet : VfTheme.surfaceSoft
                                    border.width: 1
                                    border.color: VfTheme.violet
                                    opacity: normalCard.voiceSyncEnabled ? 1.0 : 0.65

                                    Text {
                                        anchors.centerIn: parent
                                        text: "🎤"
                                        font.pixelSize: VfTheme.dp(11)
                                    }
                                }
                            }

                            Text {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: assetButton.bottom
                                anchors.topMargin: VfTheme.dp(2)
                                text: normalCard.slotCaption(index)
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(9)
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                visible: text.length > 0
                            }

                            MouseArea {
                                id: slotMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: normalCard.actionRequested("prompt_card.media", {
                                    card: normalCard.card,
                                    card_id: normalCard.cardId(),
                                    row_id: normalCard.cardId(),
                                    route: "normal",
                                    index: normalCard.promptIndex,
                                    slot_index: index,
                                    slot_key: normalCard.slotKey(index),
                                    slot_role: normalCard.slotMediaFilterType(index),
                                    media_filter_type: normalCard.slotMediaFilterType(index)
                                })
                            }
                        }
                    }
                }
            }
        }
    }
}
