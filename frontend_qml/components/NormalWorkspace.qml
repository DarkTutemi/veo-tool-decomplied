import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

// Extracted from WorkPanelWorkspace.qml — the NORMAL route body + its helpers,
// copied VERBATIM (root.X now resolves to this file's own props/funcs/signals),
// following the CloneWorkspace/BatchWorkspace pattern. Isolates normal.
ColumnLayout {
    id: root

    property var cards: []
    // Compatibility input from WorkPanelWorkspace's shared card model.
    property var cardModel: null
    property string normalFeature: "text"
    property int normalMultiAssetReferenceLimit: 3
    property var routeConfig: ({})

    signal actionRequested(string actionId, var payload)
    signal addCardsRequested(string text)
    signal addBlankRequested()
    signal bulkImportRequested()
    signal submitAllRequested()
    signal clearQueueRequested()
    signal clearCompletedRequested()
    signal startQueueRequested()
    signal pauseQueueRequested()
    signal historyRequested()
    signal routeToolRequested(string action)
    signal mediaCardRequested(var card)
    signal editCardRequested(var card)
    signal duplicateCardRequested(var card)
    signal deleteCardRequested(var card)
    signal submitCardRequested(var card)

    function routeName() { return "normal" }

    function requestAction(actionId, payload) {
        var data = {
            action_id: actionId,
            route: root.routeName()
        }
        for (var key in payload || ({}))
            data[key] = payload[key]
        root.actionRequested(actionId, data)
        return data
    }

    // Styled Bulk-Import dropdown item — consistent border/colour/text, full width
    // (no truncation). Mirrors HeaderComponent's HelpMenuItem.
    component BulkMenuItem: MenuItem {
        id: bmi
        implicitHeight: VfTheme.dp(38)
        leftPadding: VfTheme.dp(12)
        rightPadding: VfTheme.dp(14)
        contentItem: Text {
            text: bmi.text
            color: bmi.enabled ? VfTheme.text : VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontControl
            font.weight: VfTheme.weightControl
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            radius: VfTheme.dp(7)
            color: bmi.highlighted ? VfTheme.blueFill : "transparent"
        }
    }

    function requestAddCards(text) {
        root.requestAction("work_panel.add_from_text", {
            text: text,
            source: "prompt_input"
        })
        root.addCardsRequested(text)
    }

    function requestAddBlank(source) {
        root.requestAction("work_panel.add_blank", {
            source: source || "toolbar"
        })
        root.addBlankRequested()
    }

    function requestBulkImport() {
        root.requestAction("work_panel.bulk_import", { source: "toolbar" })
        root.bulkImportRequested()
    }

    function requestQueueAction(actionId) {
        if (actionId === "work_panel.submit_all") {
            root.submitAllRequested()
            return
        }
        root.requestAction(actionId, { source: "queue_toolbar" })
        if (actionId === "work_panel.pause_queue") {
            root.pauseQueueRequested()
        } else if (actionId === "work_panel.clear_completed") {
            root.clearCompletedRequested()
        } else if (actionId === "work_panel.clear_queue") {
            root.clearQueueRequested()
        } else if (actionId === "work_panel.start_queue") {
            root.startQueueRequested()
        }
    }

    function requestHistory(source) {
        root.requestAction("work_panel.history", { source: source || "toolbar" })
        root.historyRequested()
    }

    function requestRouteTool(action, actionId) {
        root.requestAction(actionId, {
            source: "route_tool",
            route_tool: action
        })
        root.routeToolRequested(action)
    }

    function selectNormalFeature(key) {
        root.normalFeature = key
        root.requestAction("work_panel.mode_toggle", {
            source: "normal_feature_bar",
            mode: key
        })
    }

    function normalCardModel() {
        if (root.cards && root.cards.length > 0)
            return root.cards
        return [{
            id: "normal_draft_preview",
            title: (void i18n.revision, i18n.t("prompt_card.prompt_label", "PROMPT: #{num}")).replace("{num}", "1"),
            prompt: "",
            status: "draft",
            selected: true,
            route: "normal",
            feature: root.normalFeature,
            preview_only: true
        }]
    }

    function normalCardCount() {
        return Math.max(1, root.cards ? root.cards.length : 0)
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

    function normalAssetCount() {
        if (root.normalFeature === "image")
            return 1
        if (root.normalFeature === "interpolation")
            return 2
        if (root.normalFeature === "multi_asset")
            return root.normalMultiAssetReferenceLimit
        return 0
    }

    function normalAssetLabel(slotIndex) {
        if (root.normalFeature === "image")
            return (void i18n.revision, i18n.t("prompt_card.add_image", "+ Image"))
        if (root.normalFeature === "interpolation")
            return slotIndex === 0 ? (void i18n.revision, i18n.t("prompt_card.add_start", "+ Start")) : (void i18n.revision, i18n.t("prompt_card.add_end", "+ End"))
        return (void i18n.revision, i18n.t("prompt_card.add_asset", "+ Asset {index}")).replace("{index}", String(slotIndex + 1))
    }

    function handlePromptCardAction(actionId, payload) {
        var data = root.requestAction(actionId, payload || ({}))
        var card = data.card || ({})
        if (actionId === "prompt_card.media") {
            root.mediaCardRequested(card)
        } else if (actionId === "prompt_card.edit") {
            root.editCardRequested(card)
        } else if (actionId === "prompt_card.duplicate") {
            root.duplicateCardRequested(card)
        } else if (actionId === "prompt_card.delete") {
            root.deleteCardRequested(card)
        } else if (actionId === "prompt_card.submit") {
            root.submitCardRequested(card)
        }
    }

        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(64)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(8)
                anchors.rightMargin: VfTheme.dp(8)
                anchors.topMargin: VfTheme.dp(8)
                anchors.bottomMargin: VfTheme.dp(8)
                spacing: VfTheme.dp(8)

            Flickable {
                id: normalToolbarFlickable

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalFlick
                interactive: contentWidth > width
                contentWidth: normalToolbar.implicitWidth
                contentHeight: height

                // Row (not RowLayout): a layout here inherits the Flickable
                // viewport width and squeezes later buttons to empty boxes.
                Row {
                    id: normalToolbar
                    y: Math.round((normalToolbarFlickable.height - height) / 2)
                    height: VfTheme.toolbarChipHeight
                    spacing: VfTheme.dp(8)

                    NormalButtonGroup {
                        id: normalFeatureGroup
                        segmented: true

                        // Static chips — NEVER a Repeater on a function-returned JS
                        // array. That rebuilds VfAppIcon/IconImage on every i18n/dp
                        // tick and races the threaded render loop
                        // ("Cannot find member data" → Qt6Qml +0x3fa03 AV).
                        NormalToolbarButton {
                            objectName: "normalMode_text"
                            text: (void i18n.revision, i18n.t("normal_panel.feature_text", "Text"))
                            iconName: "memo"
                            selected: root.normalFeature === "text"
                            flat: true
                            joinRight: true
                            minWidth: VfTheme.dp(108)
                            onClicked: root.selectNormalFeature("text")
                        }
                        NormalToolbarButton {
                            objectName: "normalMode_image"
                            text: (void i18n.revision, i18n.t("normal_panel.feature_image", "Image"))
                            iconName: "framed-picture"
                            selected: root.normalFeature === "image"
                            flat: true
                            joinLeft: true
                            joinRight: true
                            minWidth: VfTheme.dp(108)
                            onClicked: root.selectNormalFeature("image")
                        }
                        NormalToolbarButton {
                            objectName: "normalMode_interpolation"
                            text: (void i18n.revision, i18n.t("normal_panel.feature_interpolation", "2 Images"))
                            iconName: "shuffle"
                            selected: root.normalFeature === "interpolation"
                            flat: true
                            joinLeft: true
                            joinRight: true
                            minWidth: VfTheme.dp(108)
                            onClicked: root.selectNormalFeature("interpolation")
                        }
                        NormalToolbarButton {
                            objectName: "normalMode_multi_asset"
                            text: (void i18n.revision, i18n.t("normal_panel.feature_multi_asset", "Ingredients"))
                            iconName: "puzzle-piece"
                            selected: root.normalFeature === "multi_asset"
                            flat: true
                            joinLeft: true
                            minWidth: VfTheme.dp(108)
                            onClicked: root.selectNormalFeature("multi_asset")
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
                            actionId: "work_panel.add_blank"
                            text: (void i18n.revision, i18n.t("config_panel.add_row", "Add Row"))
                            minWidth: VfTheme.dp(96)
                            onClicked: root.requestAddBlank("normal_toolbar")
                        }

                        NormalToolbarButton {
                            id: normalBulkImportButton
                            actionId: "work_panel.bulk_import"
                            text: (void i18n.revision, i18n.t("config_panel.bulk_import_short", "Bulk Import"))
                            minWidth: VfTheme.dp(96)
                            readonly property bool hasImportMenu: true
                            onClicked: hasImportMenu ? normalBulkImportMenu.open() : root.requestBulkImport()

                            Menu {
                                id: normalBulkImportMenu
                                y: normalBulkImportButton.height
                                implicitWidth: VfTheme.dp(320)
                                padding: VfTheme.dp(6)
                                overlap: 0

                                background: Rectangle {
                                    implicitWidth: VfTheme.dp(320)
                                    color: VfTheme.surface
                                    border.color: VfTheme.border
                                    border.width: 1
                                    radius: VfTheme.dp(10)
                                }

                                BulkMenuItem {
                                    visible: root.normalFeature === "text"
                                    height: visible ? implicitHeight : 0
                                    text: (void i18n.revision, i18n.t("normal_panel.menu_text_import", "Import prompt"))
                                    onTriggered: root.requestBulkImport()
                                }

                                BulkMenuItem {
                                    visible: root.normalFeature !== "text"
                                    height: visible ? implicitHeight : 0
                                    text: (void i18n.revision, i18n.t("normal_panel.menu_standard_import", "Import theo thứ tự"))
                                    onTriggered: root.requestAction("work_panel.bulk_import", {
                                        mode: "standard",
                                        source: "normal_toolbar"
                                    })
                                }

                                BulkMenuItem {
                                    visible: root.normalFeature === "image" || root.normalFeature === "multi_asset"
                                    height: visible ? implicitHeight : 0
                                    text: (void i18n.revision, i18n.t("normal_panel.menu_named_ref_import", "Import theo tên ảnh trong prompt"))
                                    onTriggered: root.requestAction("work_panel.bulk_import", {
                                        mode: "named_ref",
                                        source: "normal_toolbar"
                                    })
                                }

                                BulkMenuItem {
                                    text: (void i18n.revision, i18n.t("normal_panel.menu_from_batch_image", "Import từ Tạo Hình Ảnh"))
                                    onTriggered: root.requestAction("work_panel.import_from_batch_image", {
                                        source: "normal_toolbar"
                                    })
                                }

                                MenuSeparator {
                                    padding: VfTheme.dp(6)
                                    contentItem: Rectangle { implicitHeight: 1; color: VfTheme.border }
                                }

                                // Hướng dẫn từng kiểu nhập — mở đúng mode + spotlight riêng.
                                BulkMenuItem {
                                    text: (void i18n.revision, i18n.t("normal_panel.menu_guide_text", "Hướng dẫn: nhập Text"))
                                    onTriggered: root.requestAction("work_panel.bulk_import_guide", {
                                        guide: "text",
                                        source: "normal_toolbar"
                                    })
                                }

                                BulkMenuItem {
                                    text: (void i18n.revision, i18n.t("normal_panel.menu_guide_image", "Hướng dẫn: nhập Ảnh"))
                                    onTriggered: root.requestAction("work_panel.bulk_import_guide", {
                                        guide: "image",
                                        source: "normal_toolbar"
                                    })
                                }

                                BulkMenuItem {
                                    text: (void i18n.revision, i18n.t("normal_panel.menu_guide_named_ref", "Hướng dẫn: Import theo tên ảnh"))
                                    onTriggered: root.requestAction("work_panel.bulk_import_guide", {
                                        guide: "named_ref",
                                        source: "normal_toolbar"
                                    })
                                }
                            }
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
                            actionId: "work_panel.select_all_cards"
                            tooltip: (void i18n.revision, i18n.t("config_panel.select_all", "Select All"))
                            onClicked: root.requestAction("work_panel.select_all_cards", { source: "normal_toolbar" })
                        }

                        NormalToolbarButton {
                            actionId: "work_panel.unselect_all_cards"
                            tooltip: (void i18n.revision, i18n.t("config_panel.unselect_all", "Unselect All"))
                            onClicked: root.requestAction("work_panel.unselect_all_cards", { source: "normal_toolbar" })
                        }

                        NormalToolbarButton {
                            actionId: "work_panel.clear_cards"
                            tooltip: (void i18n.revision, i18n.t("config_panel.clear_all", "Clear All"))
                            danger: true
                            onClicked: root.requestAction("work_panel.clear_cards", { source: "normal_toolbar" })
                        }

                        Rectangle {
                            width: Math.max(VfTheme.toolbarChipHeight, normalCounter.implicitWidth + VfTheme.dp(14))
                            height: VfTheme.toolbarChipHeight
                            radius: VfTheme.dp(8)
                            color: VfTheme.violetFill
                            border.width: 1
                            border.color: VfTheme.indigoBorderSoft

                            Text {
                                id: normalCounter
                                anchors.centerIn: parent
                                text: String(root.normalSelectedCount()) + "/" + String(root.normalCardCount())
                                color: VfTheme.indigoText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: VfTheme.weightStrong
                            }
                        }
                    }

                    Rectangle {
                        width: 1
                        height: VfTheme.dp(22)
                        color: VfTheme.border
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    VfToolbarSwitch {
                        actionId: "work_panel.normal_auto_merge_toggle"
                        text: (void i18n.revision, i18n.t("normal_panel.auto_merge", "AUTO Merge Video"))
                        tooltip: (void i18n.revision, i18n.t("clone.auto_merge_hint", "Ghép video ngay khi đủ cảnh."))
                        checked: !!((root.routeConfig || ({})).auto_merge)
                        accent: "#10B981"
                        controlHeight: VfTheme.toolbarChipHeight
                        minWidth: VfTheme.dp(96)
                        onToggled: function(enabled) {
                            root.requestAction("work_panel.normal_auto_merge_toggle", {
                                source: "normal_toolbar",
                                enabled: enabled
                            })
                        }
                    }

                    NormalButtonGroup {
                        visible: root.normalFeature === "multi_asset"

                        NormalToolbarButton {
                            readonly property bool voiceSupported: !!((root.routeConfig || ({})).normal_voice_lock_supported)
                            actionId: "work_panel.normal_voice_lock_toggle"
                            iconName: "studio-microphone"
                            text: (void i18n.revision, i18n.t("normal_panel.voice_sync", "Voice Sync"))
                            minWidth: VfTheme.dp(96)
                            blocked: !voiceSupported
                            blockedTooltip: (void i18n.revision, i18n.t("normal_panel.voice_sync_requires_r2v", "Chỉ model R2V (Omni/Abra) hỗ trợ đồng bộ giọng nói"))
                            selected: voiceSupported && !!((root.routeConfig || ({})).enable_flow_voice_lock)
                            onClicked: root.requestAction("work_panel.normal_voice_lock_toggle", {
                                source: "normal_toolbar",
                                enabled: !Boolean((root.routeConfig || ({})).enable_flow_voice_lock)
                            })
                        }
                    }

                }
            }

            NormalButtonGroup {
                id: normalSubmitGroup

                NormalToolbarButton {
                    id: normalCreateVideoButton
                    actionId: "work_panel.submit_all"
                    text: (void i18n.revision, i18n.t("normal_panel.create_video_count", "Create Video ({count})")).replace("{count}", String(root.normalSelectedCount()))
                    selected: true
                    blocked: root.normalSelectedCount() <= 0
                    blockedTooltip: (void i18n.revision, i18n.t("normal_panel.no_selected_cards", "No selected prompt cards."))
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
            clip: true

            Flickable {
                id: normalCardsFlick
                anchors.fill: parent
                clip: true
                contentWidth: width
                contentHeight: Math.max(height, normalCardsColumn.implicitHeight + 22)
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: normalCardsColumn
                    width: normalCardsFlick.width
                    spacing: VfTheme.dp(8)
                    padding: VfTheme.dp(10)

                    Repeater {
                        model: root.normalCardModel()

                        NormalPromptCard {
                            width: normalCardsColumn.width - normalCardsColumn.padding * 2
                            card: modelData
                            promptIndex: index
                            feature: root.normalFeature
                            assetCount: root.normalAssetCount()
                            voiceSyncEnabled: !!((root.routeConfig || ({})).enable_flow_voice_lock)
                            onActionRequested: (actionId, payload) => root.handlePromptCardAction(actionId, payload)
                        }
                    }
                }
            }
        }
}
