import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property string themeId: ""
    property string themeName: ""
    property string themePrompt: ""
    property var themeKeywords: []
    property string mode: "create"
    property var themeItem: ({})
    property bool managementMode: false
    property var managerItems: []
    property string managerSearchText: ""
    property string selectedThemeId: ""
    property string pendingDeleteThemeId: ""
    property string pendingDeleteThemeName: ""
    property var serviceAdapter: typeof taxonomyController !== "undefined" ? taxonomyController : null
    property bool autoAcceptWithoutAdapter: false
    property int selectedKeywordIndex: -1
    property string statusText: ""
    property string errorText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property var pendingSavePayload: ({})
    readonly property bool editMode: root.mode === "update"

    signal saved(var result)
    signal deleted(var result)
    signal blocked(string reason)
    signal hostBlocked(var payload)

    modal: true
    parent: Overlay.overlay
    width: VfDialogMetrics.width(parent, root.managementMode ? VfTheme.dp(880) : VfTheme.dp(660), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, root.managementMode ? VfTheme.dp(700) : VfTheme.dp(540), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    standardButtons: Dialog.NoButton
    onOpened: syncFields()

    header: VfDialogHeader {
        title: root.managementMode
            ? (void i18n.revision, i18n.t("themes.window_title", "Themes Management"))
            : (root.editMode ? (void i18n.revision, i18n.t("themes.edit_theme", "Edit Theme")) : (void i18n.revision, i18n.t("themes.add_theme", "Add Theme")))
        iconName: "artist-palette"
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

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(16)
        spacing: VfTheme.dp(10)

        Label {
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("themes.management_description", "Theme records are saved through application.taxonomy_service payloads."))
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.managementMode ? 168 : 0
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
                        text: (void i18n.revision, i18n.t("common.add", "Add"))
                        tone: "primary"
                        onClicked: root.startCreate()
                    }

                    ModernButton {
                        text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                        tone: "danger"
                        enabled: root.selectedThemeId.length > 0
                        onClicked: root.deleteSelected()
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: availableWidth
                    contentHeight: themeListCol.implicitHeight
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        id: themeListCol
                        width: parent.availableWidth
                        spacing: VfTheme.dp(4)

                        Repeater {
                            model: root.managerItems

                            Rectangle {
                                property var itemData: modelData
                                property bool selected: String(root.selectedThemeId || "") === String(itemData.theme_id || itemData.id || "")

                                Layout.fillWidth: true
                                implicitHeight: VfTheme.dp(34)
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
                                        text: String(itemData.theme_id || itemData.id || "")
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        elide: Text.ElideRight
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: String(itemData.name || itemData.display_name || "")
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        elide: Text.ElideRight
                                    }

                                    Label {
                                        Layout.preferredWidth: VfTheme.dp(120)
                                        text: String((itemData.keywords || []).length || 0) + " " + (void i18n.revision, i18n.t("themes.keywords_count_suffix", "keyword(s)"))
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.selectTheme(itemData)
                                }
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            visible: root.managerItems.length === 0
                            text: (void i18n.revision, i18n.t("themes.no_themes", "No themes found."))
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
                text: (void i18n.revision, i18n.t("themes.theme_id", "Theme ID"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            TextField {
                id: idInput
                Layout.fillWidth: true
                enabled: !root.editMode
                text: root.themeId
                placeholderText: (void i18n.revision, i18n.t("themes.placeholder_id", "theme_id"))
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
                text: (void i18n.revision, i18n.t("themes.display_name", "Display Name"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            TextField {
                id: nameInput
                Layout.fillWidth: true
                text: root.themeName
                placeholderText: (void i18n.revision, i18n.t("themes.placeholder_name", "Human-readable theme name"))
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
            text: (void i18n.revision, i18n.t("themes.keywords", "Keywords"))
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontBody
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(118)
            radius: VfTheme.radiusControl
            color: VfTheme.surface
            border.color: VfTheme.borderBox
            clip: true

            ScrollView {
                id: keywordsScroll
                anchors.fill: parent
                anchors.margins: VfTheme.dp(8)
                clip: true
                contentWidth: availableWidth
                contentHeight: keywordsCol.implicitHeight
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    id: keywordsCol
                    width: keywordsScroll.availableWidth
                    spacing: VfTheme.dp(6)

                    Repeater {
                        model: root.themeKeywords

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: VfTheme.dp(30)
                            radius: VfTheme.dp(8)
                            color: index === root.selectedKeywordIndex ? VfTheme.blueFill : VfTheme.surfaceSoft
                            border.color: index === root.selectedKeywordIndex ? VfTheme.primary : VfTheme.borderSoft

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                onClicked: root.selectedKeywordIndex = index
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(10)
                                anchors.rightMargin: VfTheme.dp(6)
                                spacing: VfTheme.dp(8)

                                Label {
                                    Layout.fillWidth: true
                                    text: String(modelData)
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    elide: Text.ElideRight
                                }

                                ModernButton {
                                    text: (void i18n.revision, i18n.t("themes.remove_keyword", "Remove keyword"))
                                    tone: "neutral"
                                    minWidth: VfTheme.dp(76)
                                    onClicked: root.removeKeyword(index)
                                }
                            }
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        visible: root.themeKeywords.length === 0
                        text: (void i18n.revision, i18n.t("themes.no_keywords", "No keywords yet."))
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            TextField {
                id: keywordInput
                Layout.fillWidth: true
                placeholderText: (void i18n.revision, i18n.t("themes.add_keyword", "Add keyword"))
                font.family: VfTheme.fontFamily
                onAccepted: root.addKeyword(keywordInput.text)
                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: VfTheme.surface
                    border.color: keywordInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                }
            }

            ModernButton {
                text: (void i18n.revision, i18n.t("common.add", "Add"))
                tone: "primary"
                onClicked: root.addKeyword(keywordInput.text)
            }
        }

        Label {
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("common.description", "Description"))
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontBody
        }

        TextArea {
            id: promptInput
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: root.themePrompt
            placeholderText: (void i18n.revision, i18n.t("themes.placeholder_desc", "Describe this theme."))
            wrapMode: TextArea.Wrap
            selectByMouse: true
            color: VfTheme.text
            placeholderTextColor: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontBody
            background: Rectangle {
                radius: VfTheme.radiusControl
                color: VfTheme.surface
                border.color: promptInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
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
        var item = root.themeItem || ({})
        root.themeId = String(item.theme_id || item.id || root.themeId || "")
        root.themeName = String(item.name || item.display_name || root.themeName || "")
        root.themePrompt = String(item.description || item.prompt || root.themePrompt || "")
        root.themeKeywords = root.cleanKeywords(item.keywords || root.themeKeywords || [])
        idInput.text = root.themeId
        nameInput.text = root.themeName
        promptInput.text = root.themePrompt
        root.selectedKeywordIndex = -1
        root.selectedThemeId = root.themeId
    }

    function openFor(theme) {
        var item = theme || ({})
        root.managementMode = false
        root.themeItem = item
        root.mode = "update"
        root.themeId = String(item.theme_id || item.id || "")
        root.themeName = String(item.name || item.display_name || "")
        root.themePrompt = String(item.description || item.prompt || "")
        root.themeKeywords = root.cleanKeywords(item.keywords || [])
        root.errorText = ""
        root.statusText = ""
        root.open()
    }

    function openNew() {
        root.managementMode = false
        root.startCreate()
        root.open()
    }

    function add_theme() {
        root.managementMode = true
        root.startCreate()
        return root.payload()
    }

    function edit_theme(theme) {
        root.managementMode = true
        root.selectTheme(theme || ({}))
        return root.payload()
    }

    function openManager(search) {
        root.managementMode = true
        root.managerSearchText = String(search || "")
        root.errorText = ""
        root.statusText = ""
        root.refreshManager(root.managerSearchText)
        if (root.managerItems.length > 0)
            root.selectTheme(root.managerItems[0])
        else
            root.startCreate()
        root.open()
    }

    function startCreate() {
        root.themeItem = ({})
        root.mode = "create"
        root.themeId = ""
        root.themeName = ""
        root.themePrompt = ""
        root.themeKeywords = []
        root.errorText = ""
        root.statusText = ""
        idInput.text = ""
        nameInput.text = ""
        promptInput.text = ""
        root.selectedKeywordIndex = -1
        root.selectedThemeId = ""
    }

    function selectTheme(theme) {
        var item = theme || ({})
        root.themeItem = item
        root.mode = "update"
        root.themeId = String(item.theme_id || item.id || "")
        root.themeName = String(item.name || item.display_name || "")
        root.themePrompt = String(item.description || item.prompt || "")
        root.themeKeywords = root.cleanKeywords(item.keywords || [])
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
            items = root.serviceAdapter && root.serviceAdapter.themes ? root.serviceAdapter.themes : []
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
            root.statusText = "Theme manager refreshed."
            return
        }
        root.applyBlocker(
            "taxonomy_theme_manager_controller_missing",
            "taxonomy.theme.manager.refresh",
            "No taxonomyController/serviceAdapter is registered for theme management."
        )
    }

    function cleanKeywords(values) {
        var next = []
        var seen = ({})
        var source = values || []
        for (var i = 0; i < source.length; i++) {
            var value = String(source[i] || "").trim()
            var key = value.toLowerCase()
            if (value.length > 0 && !seen[key]) {
                seen[key] = true
                next.push(value)
            }
        }
        return next
    }

    function addKeyword(value) {
        var clean = String(value || "").trim()
        if (!clean)
            return
        var next = root.cleanKeywords(root.themeKeywords.concat([clean]))
        if (next.length === root.themeKeywords.length) {
            root.statusText = (void i18n.revision, i18n.t("themes.keyword_exists", "Keyword already exists."))
            root.showFeedback(
                (void i18n.revision, i18n.t("common.error", "Error")),
                root.statusText
            )
            keywordInput.forceActiveFocus()
            return
        }
        root.themeKeywords = next
        root.selectedKeywordIndex = root.themeKeywords.length - 1
        keywordInput.text = ""
        root.statusText = ""
    }

    function add_keyword(value) {
        return root.addKeyword(value)
    }

    function removeKeyword(index) {
        var next = []
        for (var i = 0; i < root.themeKeywords.length; i++) {
            if (i !== index)
                next.push(root.themeKeywords[i])
        }
        root.themeKeywords = next
        root.selectedKeywordIndex = -1
    }

    function remove_keyword(index) {
        return root.removeKeyword(index)
    }

    function payload() {
        var cleanId = String(idInput.text || "").trim()
        var cleanName = String(nameInput.text || "").trim()
        var description = String(promptInput.text || "").trim()
        return {
            kind: "theme",
            mode: root.editMode ? "update" : "create",
            action: root.editMode ? "update" : "create",
            id: cleanId,
            theme_id: cleanId,
            name: cleanName,
            keywords: root.cleanKeywords(root.themeKeywords),
            description: description,
            prompt: description,
            service: "application.taxonomy_service.TaxonomyService.save_theme_payload"
        }
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || "")
        root.feedbackMessage = String(message || "")
        feedbackDialog.open()
    }

    function performSave(data) {
        if (root.serviceAdapter && typeof root.serviceAdapter.saveTheme === "function") {
            var result = root.serviceAdapter.saveTheme(data)
            root.applySaveResult(result, data)
            return
        }

        var blocker = root.applyBlocker(
            "taxonomy_theme_save_controller_missing",
            "taxonomy.theme.save",
            "No taxonomyController/serviceAdapter is registered for ThemeEditDialog."
        )
        if (root.autoAcceptWithoutAdapter) {
            root.saved(blocker)
            root.accept()
        }
    }

    function save() {
        root.errorText = ""
        var data = root.payload()
        if (!data.theme_id) {
            root.errorText = (void i18n.revision, i18n.t("themes.enter_id", "Please enter a theme ID."))
            root.showFeedback((void i18n.revision, i18n.t("common.error", "Error")), root.errorText)
            idInput.forceActiveFocus()
            return
        }
        if (!data.name) {
            root.errorText = (void i18n.revision, i18n.t("themes.enter_name", "Please enter a theme name."))
            root.showFeedback((void i18n.revision, i18n.t("common.error", "Error")), root.errorText)
            nameInput.forceActiveFocus()
            return
        }
        if ((data.keywords || []).length === 0) {
            root.pendingSavePayload = data
            noKeywordsConfirmDialog.open()
            return
        }
        root.performSave(data)
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
        root.statusText = response.action === "create" ? "Theme created." : "Theme saved."
        if (root.managementMode) {
            if (response.themes)
                root.syncManagerItemsFrom(response.themes)
            if (response.item)
                root.selectTheme(response.item)
            root.saved(response)
            return
        }
        root.saved(response)
        root.accept()
    }

    function deleteSelected() {
        var themeId = String(root.selectedThemeId || idInput.text || "").trim()
        if (!themeId) {
            root.errorText = (void i18n.revision, i18n.t("themes.select_to_delete", "Select a theme to delete."))
            root.showFeedback(
                (void i18n.revision, i18n.t("common.error", "Error")),
                root.errorText
            )
            return
        }
        root.pendingDeleteThemeId = themeId
        root.pendingDeleteThemeName = String(root.themeName || nameInput.text || themeId)
        deleteConfirmDialog.open()
    }

    function executeDeleteSelected() {
        var themeId = String(root.pendingDeleteThemeId || "").trim()
        if (!themeId)
            return
        if (root.serviceAdapter && typeof root.serviceAdapter.deleteTheme === "function") {
            var result = root.serviceAdapter.deleteTheme(themeId)
            root.applyDeleteResult(result)
            return
        }
        root.applyBlocker(
            "taxonomy_theme_delete_controller_missing",
            "taxonomy.theme.delete",
            "No taxonomyController/serviceAdapter is registered for deleting themes."
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
        if (response.themes)
            root.syncManagerItemsFrom(response.themes)
        root.statusText = "Theme deleted."
        root.deleted(response)
        if (root.managerItems.length > 0)
            root.selectTheme(root.managerItems[0])
        else
            root.startCreate()
    }

    function structuredBlocker(code, action, message) {
        return {
            ok: false,
            blocked: true,
            kind: "theme",
            code: code,
            error: code,
            action: action,
            message: message,
            blocker: {
                code: code,
                action: action,
                kind: "theme",
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
        width: VfDialogMetrics.width(parent, VfTheme.dp(360), VfTheme.dp(64))
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
                text: (void i18n.revision, i18n.t(
                    "dialog.confirm_delete",
                    "Delete this item?"
                )) + (root.pendingDeleteThemeName.length ? "\n\n" + root.pendingDeleteThemeName : "")
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
            root.pendingDeleteThemeId = ""
            root.pendingDeleteThemeName = ""
        }
    }

    Dialog {
        id: noKeywordsConfirmDialog

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
                text: (void i18n.revision, i18n.t("dialog.no_keyword", "No keywords were added. Continue anyway?"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                ModernButton {
                    text: (void i18n.revision, i18n.t("common.no", "No"))
                    onClicked: noKeywordsConfirmDialog.close()
                }

                ModernButton {
                    text: (void i18n.revision, i18n.t("common.yes", "Yes"))
                    tone: "primary"
                    onClicked: {
                        var data = root.pendingSavePayload || ({})
                        noKeywordsConfirmDialog.close()
                        root.performSave(data)
                    }
                }
            }
        }

        onClosed: root.pendingSavePayload = ({})
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
