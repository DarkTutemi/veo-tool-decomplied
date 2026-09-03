import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property string strategyId: ""
    property string strategyName: ""
    property string strategyText: ""
    property string mode: "create"
    property var strategyItem: ({})
    property bool managementMode: false
    property var managerItems: []
    property string managerSearchText: ""
    property string selectedStrategyId: ""
    property string pendingDeleteStrategyId: ""
    property string pendingDeleteStrategyName: ""
    property var serviceAdapter: typeof taxonomyController !== "undefined" ? taxonomyController : null
    property bool autoAcceptWithoutAdapter: false
    property string statusText: ""
    property string errorText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    readonly property bool editMode: root.mode === "update"

    signal saved(var result)
    signal deleted(var result)
    signal blocked(string reason)
    signal hostBlocked(var payload)

    modal: true
    parent: Overlay.overlay
    width: VfDialogMetrics.width(parent, root.managementMode ? VfTheme.dp(840) : VfTheme.dp(620), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, root.managementMode ? VfTheme.dp(620) : VfTheme.dp(460), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    standardButtons: Dialog.NoButton
    onOpened: syncFields()

    header: VfDialogHeader {
        title: root.managementMode
            ? (void i18n.revision, i18n.t("strategies_mgmt.window_title", "Strategies Management"))
            : (root.editMode
                ? (void i18n.revision, i18n.t("strategies_mgmt.edit_title", "Edit Strategy"))
                : (void i18n.revision, i18n.t("strategies_mgmt.add_title", "Add Strategy")))
        iconName: "busts-in-silhouette"
        onCloseClicked: root.reject()
    }

    background: Rectangle {
        radius: VfTheme.dp(12)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
    }

    footer: Rectangle {
        implicitHeight: VfTheme.dp(56)
        color: VfTheme.surface
        border.color: VfTheme.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(12)

            Item { Layout.fillWidth: true }

            VfButton {
                text: root.managementMode ? (void i18n.revision, i18n.t("common.close", "Close")) : (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                minWidth: VfTheme.dp(112)
                onClicked: {
                    if (root.managementMode)
                        root.accept()
                    else
                        root.reject()
                }
            }
        }
    }

    function formatNameText(templateText, nameText) {
        var value = String(nameText || "")
        return String(templateText || "")
            .replace("{name}", value)
            .replace("%1", value)
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(16)
        spacing: VfTheme.dp(10)

        Label {
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t(
                "strategies_mgmt.description",
                "Manage strategy records and save them through application.taxonomy_service payloads."
            ))
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.managementMode ? 160 : 0
            visible: root.managementMode
            radius: VfTheme.radiusControl
            color: VfTheme.surfaceSoft
            border.color: VfTheme.borderBox
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(8)
                spacing: VfTheme.dp(6)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(8)

                    TextField {
                        id: managerSearchInput
                        Layout.fillWidth: true
                        text: root.managerSearchText
                        placeholderText: (void i18n.revision, i18n.t("common.search", "Search"))
                        font.family: VfTheme.fontFamily
                        onAccepted: root.refreshManager(managerSearchInput.text)
                        background: Rectangle {
                            radius: VfTheme.radiusControl
                            color: VfTheme.surface
                            border.color: managerSearchInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                        }
                    }

                    ModernButton {
                        text: (void i18n.revision, i18n.t("common.refresh", "Refresh"))
                        onClicked: root.refreshManager(managerSearchInput.text)
                    }

                    ModernButton {
                        text: (void i18n.revision, i18n.t("strategies_mgmt.add_btn", "Add"))
                        tone: "primary"
                        onClicked: root.startCreate()
                    }

                    ModernButton {
                        text: (void i18n.revision, i18n.t("strategies_mgmt.delete_btn", "Delete"))
                        tone: "danger"
                        enabled: root.selectedStrategyId.length > 0
                        onClicked: root.deleteSelected()
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: availableWidth
                    contentHeight: strategyBody.implicitHeight
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        id: strategyBody
                        width: parent.availableWidth
                        spacing: VfTheme.dp(4)

                        Repeater {
                            model: root.managerItems

                            Rectangle {
                                property var itemData: modelData
                                property bool selected: String(root.selectedStrategyId || "") === String(itemData.strategy_id || itemData.id || "")

                                Layout.fillWidth: true
                                implicitHeight: VfTheme.dp(32)
                                radius: VfTheme.dp(8)
                                color: selected ? VfTheme.blueFill : VfTheme.surface
                                border.color: selected ? VfTheme.primary : VfTheme.borderSoft

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(10)
                                    anchors.rightMargin: VfTheme.dp(10)
                                    spacing: VfTheme.dp(8)

                                    Label {
                                        Layout.preferredWidth: VfTheme.dp(140)
                                        text: String(itemData.strategy_id || itemData.id || "")
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        elide: Text.ElideRight
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: String(itemData.display_name || itemData.name || "")
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.selectStrategy(itemData)
                                }
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            visible: root.managerItems.length === 0
                            text: (void i18n.revision, i18n.t("strategies_mgmt.no_strategies", "No strategies found."))
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            Label {
                Layout.preferredWidth: VfTheme.dp(92)
                text: (void i18n.revision, i18n.t("strategies_mgmt.strategy_id_label", "Strategy ID"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            TextField {
                id: idInput
                Layout.fillWidth: true
                enabled: !root.editMode
                text: root.strategyId
                placeholderText: (void i18n.revision, i18n.t("strategies_mgmt.strategy_id_placeholder", "strategy_id"))
                font.family: VfTheme.fontFamily
                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: idInput.enabled ? VfTheme.surface : VfTheme.surfaceSoft
                    border.color: idInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            Label {
                Layout.preferredWidth: VfTheme.dp(92)
                text: (void i18n.revision, i18n.t("strategies_mgmt.display_name_label", "Display Name"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            TextField {
                id: nameInput
                Layout.fillWidth: true
                text: root.strategyName
                placeholderText: (void i18n.revision, i18n.t("strategies_mgmt.display_name_placeholder", "Human-readable strategy name"))
                font.family: VfTheme.fontFamily
                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: VfTheme.surface
                    border.color: nameInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("strategies_mgmt.description_label", "Description"))
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontBody
        }

        TextArea {
            id: textInput
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: root.strategyText
            placeholderText: (void i18n.revision, i18n.t("strategies_mgmt.description_placeholder", "Describe when this strategy should be used."))
            wrapMode: TextArea.Wrap
            selectByMouse: true
            color: VfTheme.text
            placeholderTextColor: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontBody
            background: Rectangle {
                radius: VfTheme.radiusControl
                color: VfTheme.surface
                border.color: textInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
            }
        }

        Label {
            Layout.fillWidth: true
            visible: root.errorText.length > 0 || root.statusText.length > 0
            text: root.errorText.length > 0 ? root.errorText : root.statusText
            color: root.errorText.length > 0 ? VfTheme.redBorder : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            Item { Layout.fillWidth: true }
            ModernButton {
                text: (void i18n.revision, i18n.t("common.save", "Save"))
                tone: "primary"
                onClicked: root.save()
            }
        }
    }

    Connections {
        target: root.serviceAdapter
        ignoreUnknownSignals: true
        function onPayloadChanged() {
            if (root.managementMode)
                root.syncManagerItems()
        }
    }

    function syncFields() {
        var item = root.strategyItem || ({})
        root.strategyId = String(item.strategy_id || item.id || root.strategyId || "")
        root.strategyName = String(item.display_name || item.name || root.strategyName || "")
        root.strategyText = String(item.description || item.text || root.strategyText || "")
        idInput.text = root.strategyId
        nameInput.text = root.strategyName
        textInput.text = root.strategyText
        root.selectedStrategyId = root.strategyId
    }

    function openFor(strategy) {
        var item = strategy || ({})
        root.managementMode = false
        root.strategyItem = item
        root.mode = "update"
        root.strategyId = String(item.strategy_id || item.id || "")
        root.strategyName = String(item.display_name || item.name || "")
        root.strategyText = String(item.description || item.text || "")
        root.errorText = ""
        root.statusText = ""
        root.open()
    }

    function openNew() {
        root.managementMode = false
        root.startCreate()
        root.open()
    }

    function add_strategy() {
        root.managementMode = true
        root.startCreate()
        return root.payload()
    }

    function edit_strategy(strategy) {
        root.managementMode = true
        root.selectStrategy(strategy || ({}))
        return root.payload()
    }

    function openManager(search) {
        root.managementMode = true
        root.managerSearchText = String(search || "")
        root.errorText = ""
        root.statusText = ""
        root.refreshManager(root.managerSearchText)
        if (root.managerItems.length > 0)
            root.selectStrategy(root.managerItems[0])
        else
            root.startCreate()
        root.open()
    }

    function startCreate() {
        root.strategyItem = ({})
        root.mode = "create"
        root.strategyId = ""
        root.strategyName = ""
        root.strategyText = ""
        root.errorText = ""
        root.statusText = ""
        idInput.text = ""
        nameInput.text = ""
        textInput.text = ""
        root.selectedStrategyId = ""
    }

    function selectStrategy(strategy) {
        var item = strategy || ({})
        root.strategyItem = item
        root.mode = "update"
        root.strategyId = String(item.strategy_id || item.id || "")
        root.strategyName = String(item.display_name || item.name || "")
        root.strategyText = String(item.description || item.text || "")
        root.errorText = ""
        root.statusText = ""
        root.syncFields()
    }

    function syncManagerItemsFrom(items) {
        var next = []
        var source = items || []
        for (var i = 0; i < source.length; i++)
            next.push(source[i])
        root.managerItems = next
    }

    function syncManagerItems() {
        var items = []
        try {
            items = root.serviceAdapter && root.serviceAdapter.strategies ? root.serviceAdapter.strategies : []
        } catch (error) {
            items = []
        }
        root.syncManagerItemsFrom(items)
    }

    function refreshManager(search) {
        root.managerSearchText = String(search || "")
        if (root.serviceAdapter && typeof root.serviceAdapter.refresh === "function") {
            root.serviceAdapter.refresh(root.managerSearchText)
            root.syncManagerItems()
            root.statusText = "Strategy manager refreshed."
            return
        }
        root.applyBlocker(
            "taxonomy_strategy_manager_controller_missing",
            "taxonomy.strategy.manager.refresh",
            "No taxonomyController/serviceAdapter is registered for strategy management."
        )
    }

    function payload() {
        var cleanId = String(idInput.text || "").trim()
        var cleanName = String(nameInput.text || "").trim()
        var description = String(textInput.text || "").trim()
        return {
            kind: "strategy",
            mode: root.editMode ? "update" : "create",
            action: root.editMode ? "update" : "create",
            id: cleanId,
            strategy_id: cleanId,
            name: cleanName,
            display_name: cleanName,
            description: description,
            text: description,
            service: "application.taxonomy_service.TaxonomyService.save_strategy_payload"
        }
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || "")
        root.feedbackMessage = String(message || "")
        feedbackDialog.open()
    }

    function save() {
        root.errorText = ""
        var data = root.payload()
        if (!data.strategy_id) {
            root.errorText = (void i18n.revision, i18n.t("strategies_mgmt.error_enter_id", "Please enter a strategy ID."))
            root.showFeedback((void i18n.revision, i18n.t("common.error", "Error")), root.errorText)
            idInput.forceActiveFocus()
            return
        }
        if (!data.display_name) {
            root.errorText = (void i18n.revision, i18n.t("strategies_mgmt.error_enter_name", "Please enter a display name."))
            root.showFeedback((void i18n.revision, i18n.t("common.error", "Error")), root.errorText)
            nameInput.forceActiveFocus()
            return
        }

        if (root.serviceAdapter && typeof root.serviceAdapter.saveStrategy === "function") {
            var result = root.serviceAdapter.saveStrategy(data)
            root.applySaveResult(result, data)
            return
        }

        var blocker = root.applyBlocker(
            "taxonomy_strategy_save_controller_missing",
            "taxonomy.strategy.save",
            "No taxonomyController/serviceAdapter is registered for StrategyEditDialog."
        )
        if (root.autoAcceptWithoutAdapter) {
            root.saved(blocker)
            root.accept()
        }
    }

    function applySaveResult(result, fallbackPayload) {
        var response = result || ({ ok: true, item: fallbackPayload })
        if (response.ok === false) {
            root.errorText = String(response.error || response.code || "Save failed.")
            root.showFeedback(
                (void i18n.revision, i18n.t("common.error", "Error")),
                root.errorText
            )
            return
        }
        root.statusText = response.action === "create" ? "Strategy created." : "Strategy saved."
        if (root.managementMode) {
            if (response.strategies)
                root.syncManagerItemsFrom(response.strategies)
            if (response.item)
                root.selectStrategy(response.item)
            root.saved(response)
            return
        }
        root.saved(response)
        root.accept()
    }

    function deleteSelected() {
        var strategyId = String(root.selectedStrategyId || idInput.text || "").trim()
        if (!strategyId) {
            root.errorText = (void i18n.revision, i18n.t("strategies_mgmt.error_select_to_delete", "Select a strategy to delete."))
            root.showFeedback(
                (void i18n.revision, i18n.t("common.error", "Error")),
                root.errorText
            )
            return
        }
        root.pendingDeleteStrategyId = strategyId
        root.pendingDeleteStrategyName = String(root.strategyName || nameInput.text || strategyId)
        deleteConfirmDialog.open()
    }

    function executeDeleteSelected() {
        var strategyId = String(root.pendingDeleteStrategyId || "").trim()
        if (!strategyId)
            return
        if (root.serviceAdapter && typeof root.serviceAdapter.deleteStrategy === "function") {
            var result = root.serviceAdapter.deleteStrategy(strategyId)
            root.applyDeleteResult(result)
            return
        }
        root.applyBlocker(
            "taxonomy_strategy_delete_controller_missing",
            "taxonomy.strategy.delete",
            "No taxonomyController/serviceAdapter is registered for deleting strategies."
        )
    }

    function applyDeleteResult(result) {
        var response = result || ({})
        if (response.ok === false) {
            root.errorText = String(response.error || response.code || "Delete failed.")
            root.showFeedback(
                (void i18n.revision, i18n.t("common.error", "Error")),
                root.errorText
            )
            return
        }
        if (response.strategies)
            root.syncManagerItemsFrom(response.strategies)
        root.statusText = "Strategy deleted."
        root.deleted(response)
        if (root.managerItems.length > 0)
            root.selectStrategy(root.managerItems[0])
        else
            root.startCreate()
    }

    function structuredBlocker(code, action, message) {
        return {
            ok: false,
            blocked: true,
            kind: "strategy",
            code: code,
            error: code,
            action: action,
            message: message,
            blocker: {
                code: code,
                action: action,
                kind: "strategy",
                message: message,
                requires: ["taxonomyController", "application.taxonomy_service.TaxonomyService"]
            }
        }
    }

    function applyBlocker(code, action, message) {
        var payload = root.structuredBlocker(code, action, message)
        root.errorText = message
        root.blocked(message)
        root.hostBlocked(payload)
        return payload
    }

    Dialog {
        id: deleteConfirmDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(380), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Label {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightStrong
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: root.formatNameText(
                    (void i18n.revision, i18n.t("strategies_mgmt.confirm_delete", "Delete strategy '{name}'?")),
                    root.pendingDeleteStrategyName.length ? root.pendingDeleteStrategyName : root.pendingDeleteStrategyId
                )
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                ModernButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    onClicked: deleteConfirmDialog.close()
                }

                ModernButton {
                    text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                    tone: "danger"
                    onClicked: {
                        root.executeDeleteSelected()
                        deleteConfirmDialog.close()
                    }
                }
            }
        }

        onClosed: {
            root.pendingDeleteStrategyId = ""
            root.pendingDeleteStrategyName = ""
        }
    }

    Dialog {
        id: feedbackDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(380), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Label {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightStrong
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                ModernButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }
}
