import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

// Extracted from WorkPanelWorkspace.qml — the BATCH route body + its helper functions
// and signals, following the CloneWorkspace pattern: data comes IN via properties,
// actions go OUT via signals (the parent re-emits them up to WorkPanelScreen). This
// isolates batch so editing it can't touch the other route bodies.
ColumnLayout {
    id: root

    property var cards: []
    property var cardModel: null
    property var currentBatchConfig: ({})
    property int maxMultiAssetReferenceImages: 0

    signal actionRequested(string actionId, var payload)
    signal addCardsRequested(string text)
    signal addBlankRequested()
    signal bulkImportRequested()
    signal submitAllRequested()
    signal clearQueueRequested()
    signal startQueueRequested()
    signal pauseQueueRequested()
    signal clearCompletedRequested()
    signal mediaCardRequested(var card)
    signal editCardRequested(var card)
    signal duplicateCardRequested(var card)
    signal deleteCardRequested(var card)
    signal submitCardRequested(var card)

    function requestAction(actionId, payload) {
        var data = { action_id: actionId, route: "batch" }
        for (var key in payload || ({}))
            data[key] = payload[key]
        root.actionRequested(actionId, data)
        return data
    }

    function requestBulkImport() {
        root.requestAction("work_panel.bulk_import", { source: "batch_toolbar" })
        root.bulkImportRequested()
    }

    function requestQueueAction(actionId) {
        if (actionId === "work_panel.submit_all") {
            root.submitAllRequested()
            return
        }
        root.requestAction(actionId, { source: "queue_toolbar" })
        if (actionId === "work_panel.pause_queue")
            root.pauseQueueRequested()
        else if (actionId === "work_panel.clear_completed")
            root.clearCompletedRequested()
        else if (actionId === "work_panel.clear_queue")
            root.clearQueueRequested()
        else if (actionId === "work_panel.start_queue")
            root.startQueueRequested()
    }

    function normalSelectedCount() {
        var items = root.cards || []
        if (items.length === 0)
            return 1
        var count = 0
        for (var i = 0; i < items.length; i++) {
            if (items[i].selected !== false)
                count += 1
        }
        return count
    }

    function handlePromptCardAction(actionId, payload) {
        var data = root.requestAction(actionId, payload || ({}))
        var card = data.card || ({})
        if (actionId === "prompt_card.media")
            root.mediaCardRequested(card)
        else if (actionId === "prompt_card.edit")
            root.editCardRequested(card)
        else if (actionId === "prompt_card.duplicate")
            root.duplicateCardRequested(card)
        else if (actionId === "prompt_card.delete")
            root.deleteCardRequested(card)
        else if (actionId === "prompt_card.submit")
            root.submitCardRequested(card)
    }

    spacing: 0

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(64)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.border
        clip: true

        RowLayout {
            id: batchToolbarRow
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(8)
            anchors.rightMargin: VfTheme.dp(8)
            anchors.topMargin: VfTheme.dp(8)
            anchors.bottomMargin: VfTheme.dp(8)
            spacing: VfTheme.dp(8)

            Flickable {
                id: batchToolbarFlickable
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalFlick
                interactive: contentWidth > width
                contentWidth: batchToolbar.implicitWidth
                contentHeight: height

                Row {
                    id: batchToolbar
                    y: Math.round((batchToolbarFlickable.height - height) / 2)
                    height: VfTheme.toolbarChipHeight
                    spacing: VfTheme.dp(8)

                    NormalButtonGroup {
                        NormalToolbarButton {
                            actionId: "work_panel.batch_save_to_library_toggle"
                            text: Boolean(root.currentBatchConfig.save_to_library)
                                ? (void i18n.revision, i18n.t("batch_image.save_to_library_on", "Library: On"))
                                : (void i18n.revision, i18n.t("batch_image.save_to_library_off", "Library: Off"))
                            tooltip: (void i18n.revision, i18n.t("batch_image.save_to_library_tooltip", "Save generated images to Media Library for later use"))
                            selected: Boolean(root.currentBatchConfig.save_to_library)
                            minWidth: VfTheme.dp(96)
                            onClicked: root.requestAction(actionId, {
                                enabled: !Boolean(root.currentBatchConfig.save_to_library),
                                source: "batch_toolbar"
                            })
                        }
                    }

                    Rectangle {
                        width: 1
                        height: VfTheme.dp(22)
                        color: VfTheme.border
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    NormalButtonGroup {
                        NormalToolbarButton {
                            actionId: "work_panel.batch_add_prompt"
                            text: (void i18n.revision, i18n.t("batch_image.add_prompt", "Add Prompt"))
                            minWidth: VfTheme.dp(96)
                            onClicked: root.requestAction(actionId, { source: "batch_toolbar" })
                        }
                    }

                    Rectangle {
                        width: 1
                        height: VfTheme.dp(22)
                        color: VfTheme.border
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    NormalButtonGroup {
                        NormalToolbarButton {
                            actionId: "work_panel.bulk_import"
                            text: (void i18n.revision, i18n.t("batch_image.import_prompts", "Import Prompts"))
                            minWidth: VfTheme.dp(96)
                            onClicked: root.requestBulkImport()
                        }
                        NormalToolbarButton {
                            actionId: "work_panel.batch_import_images"
                            text: (void i18n.revision, i18n.t("batch_image.import_images_short", "Import Images"))
                            minWidth: VfTheme.dp(96)
                            onClicked: root.requestAction(actionId, { source: "batch_toolbar" })
                        }
                        NormalToolbarButton {
                            actionId: "work_panel.bulk_import"
                            text: (void i18n.revision, i18n.t("batch_image.import_named_ref_short", "Named-Ref"))
                            minWidth: VfTheme.dp(96)
                            onClicked: root.requestAction(actionId, { mode: "named_ref", source: "batch_toolbar" })
                        }
                    }

                    Rectangle {
                        width: 1
                        height: VfTheme.dp(22)
                        color: VfTheme.border
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    NormalButtonGroup {
                        NormalToolbarButton {
                            actionId: "work_panel.clear_cards"
                            text: (void i18n.revision, i18n.t("batch_image.clear_all", "Clear All"))
                            danger: true
                            minWidth: VfTheme.dp(96)
                            onClicked: root.requestAction(actionId, { source: "batch_toolbar" })
                        }
                    }
                }
            }

            NormalButtonGroup {
                id: batchSubmitGroup

                NormalToolbarButton {
                    actionId: "work_panel.submit_all"
                    text: (void i18n.revision, i18n.t("batch_image.run_batch", "Run Batch"))
                    selected: true
                    blocked: root.normalSelectedCount() <= 0
                    blockedTooltip: (void i18n.revision, i18n.t("batch_image.no_selected_prompts", "No selected prompts."))
                    minWidth: VfTheme.dp(108)
                    onClicked: root.requestQueueAction("work_panel.submit_all")
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: VfTheme.surfaceSoft
        border.color: VfTheme.border
        clip: true

        ListView {
            id: batchList
            objectName: "debugBatchCardListView"
            anchors.fill: parent
            anchors.margins: VfTheme.dp(12)
            clip: true
            spacing: VfTheme.dp(8)
            reuseItems: true
            cacheBuffer: Math.max(0, height)
            boundsBehavior: Flickable.StopAtBounds
            // ARCHITECTURE NOTE:
            // Batch card rendering must use cardModel for large lists. Do not
            // switch this back to root.cards for 500-1000 cards; that copies a
            // large QVariantList through QML and makes import/scroll sluggish.
            model: root.cardModel && root.cardModel.count > 0 ? root.cardModel : [{
                id: "batch_draft_preview",
                prompt: "",
                selected: true,
                preview_only: true
            }]

            delegate: BatchPromptCard {
                width: batchList.width
                card: typeof cardData !== "undefined" ? cardData : modelData
                promptIndex: index
                maxMultiAssetReferenceImages: root.maxMultiAssetReferenceImages
                onActionRequested: (actionId, payload) => root.handlePromptCardAction(actionId, payload)
            }

            footer: Column {
                width: batchList.width
                spacing: VfTheme.dp(8)

                Item { width: VfTheme.dp(1); height: Math.max(460, batchList.height - 120) }

                Text {
                    width: batchList.width
                    text: (void i18n.revision, i18n.t("batch_image.ready", "Ready"))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
