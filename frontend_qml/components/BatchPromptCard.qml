import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

// Extracted from WorkPanelWorkspace.qml (inline component). The single parent dep
// (maxMultiAssetReferenceImages) is now a property fed by BatchWorkspace.
Rectangle {
    id: batchCard

    property var card: ({})
    // Renamed from "index" to avoid shadowing the delegate context index
    // (see NormalPromptCard); a self-bound "index: index" stays 0.
    property int promptIndex: 0
    property int maxMultiAssetReferenceImages: 0

    signal actionRequested(string actionId, var payload)

    height: VfTheme.dp(56)
    radius: VfTheme.dp(8)
    color: VfTheme.surface
    border.width: 1
    border.color: VfTheme.border

    function cardId() {
        return String(card.id || card.row_id || card.batch_id || "")
    }

    function promptText() {
        return String(card.prompt || card.text || "")
    }

    function refItems() {
        return card.reference_previews || card.reference_images || card.references || card.refs || card.assets || []
    }

    function refCount() {
        var refs = batchCard.refItems()
        if (refs && refs.length !== undefined)
            return refs.length
        var ids = card.reference_image_ids || card.referenceImageIds || []
        return ids && ids.length !== undefined ? ids.length : 0
    }

    function refThumb(index) {
        var refs = batchCard.refItems()
        if (!refs || refs.length <= index)
            return ""
        var ref = refs[index]
        if (ref && typeof ref === "object")
            return String(ref.thumbnail_url || ref.thumbnail || ref.preview_path || ref.path || "")
        return String(ref || "")
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: VfTheme.dp(12)
        anchors.rightMargin: VfTheme.dp(12)
        anchors.topMargin: VfTheme.dp(8)
        anchors.bottomMargin: VfTheme.dp(8)
        spacing: VfTheme.dp(12)

        CheckBox {
            id: batchCardCheck

            checked: batchCard.card.selected !== false
            Layout.preferredWidth: VfTheme.dp(20)
            Layout.preferredHeight: VfTheme.dp(20)
            onClicked: {
                batchCard.actionRequested("prompt_card.selection", {
                    card: batchCard.card,
                    card_id: batchCard.cardId(),
                    row_id: batchCard.cardId(),
                    route: "batch",
                    index: batchCard.promptIndex,
                    selected: checked
                })
                checked = Qt.binding(function() { return batchCard.card.selected !== false })
            }

            indicator: Rectangle {
                implicitWidth: VfTheme.dp(18)
                implicitHeight: VfTheme.dp(18)
                x: batchCardCheck.leftPadding
                y: parent.height / 2 - height / 2
                radius: VfTheme.dp(4)
                color: batchCardCheck.checked ? VfTheme.primary : VfTheme.surface
                border.width: 1
                border.color: batchCardCheck.checked ? VfTheme.primary : VfTheme.borderStrong
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(36)
            radius: VfTheme.dp(6)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border
            clip: true

            TextField {
                id: batchPromptText
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(12)
                anchors.rightMargin: VfTheme.dp(12)
                text: batchCard.promptText()
                placeholderText: (void i18n.revision, i18n.t("batch_image.prompt_placeholder", "Describe the image you want to create..."))
                readOnly: true
                color: VfTheme.text
                placeholderTextColor: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                background: Item {}
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.IBeamCursor
                onClicked: batchCard.actionRequested("prompt_card.edit", {
                    card: batchCard.card,
                    card_id: batchCard.cardId(),
                    row_id: batchCard.cardId(),
                    route: "batch",
                    index: batchCard.promptIndex,
                    prompt: batchCard.promptText()
                })
            }
        }

        RowLayout {
            Layout.preferredWidth: Math.max(0, Math.min(batchCard.maxMultiAssetReferenceImages, batchCard.refCount()) * 32)
            Layout.preferredHeight: VfTheme.dp(32)
            visible: batchCard.refCount() > 0
            spacing: VfTheme.dp(4)

            Repeater {
                model: Math.min(batchCard.maxMultiAssetReferenceImages, batchCard.refCount())

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(28)
                    Layout.preferredHeight: VfTheme.dp(28)
                    radius: VfTheme.dp(4)
                    color: VfTheme.surfaceSoft
                    border.color: VfTheme.borderStrong
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: batchCard.refThumb(index)
                        fillMode: Image.PreserveAspectCrop
                        // A ~28dp slot must not decode a full-res reference image.
                        asynchronous: true
                        cache: true
                        sourceSize.width: width > 1 ? Math.ceil(width) : 0
                        sourceSize.height: height > 1 ? Math.ceil(height) : 0
                        visible: String(source).length > 0
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: batchCard.actionRequested("work_panel.batch_reference_remove", {
                            card: batchCard.card,
                            card_id: batchCard.cardId(),
                            row_id: batchCard.cardId(),
                            route: "batch",
                            index: batchCard.promptIndex,
                            ref_index: index
                        })
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: refCountText.implicitWidth + 12
            Layout.preferredHeight: VfTheme.dp(20)
            visible: batchCard.refCount() > 0
            radius: VfTheme.dp(4)
            color: VfTheme.violetFill
            border.color: VfTheme.indigoBorderSoft

            Text {
                id: refCountText
                anchors.centerIn: parent
                text: String(batchCard.refCount()) + " refs"
                color: VfTheme.primary
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.weight: VfTheme.weightStrong
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: VfTheme.dp(36)
            color: VfTheme.border
        }

        NormalToolbarButton {
            actionId: "work_panel.batch_reference_images"
            text: (void i18n.revision, i18n.t("batch_image.add_refs", "+ Refs"))
            minWidth: VfTheme.dp(70)
            blocked: batchCard.refCount() >= 10
            blockedTooltip: (void i18n.revision, i18n.t("batch_image.max_refs_reached", "Maximum 10 reference images per prompt."))
            Layout.preferredHeight: VfTheme.dp(32)
            onClicked: batchCard.actionRequested(actionId, {
                card: batchCard.card,
                card_id: batchCard.cardId(),
                row_id: batchCard.cardId(),
                route: "batch",
                route_tool: "batch_reference_images",
                index: batchCard.promptIndex
            })
        }

        VfButton {
            actionId: "prompt_card.delete"
            text: ""
            tooltip: "Delete"
            tone: "danger"
            minWidth: VfTheme.dp(32)
            Layout.preferredWidth: VfTheme.dp(32)
            Layout.preferredHeight: VfTheme.dp(32)
            onClicked: batchCard.actionRequested(actionId, {
                card: batchCard.card,
                card_id: batchCard.cardId(),
                row_id: batchCard.cardId(),
                route: "batch",
                index: batchCard.promptIndex
            })
        }
    }
}
