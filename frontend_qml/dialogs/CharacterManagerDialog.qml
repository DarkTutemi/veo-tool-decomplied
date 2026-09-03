import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../components/MediaSourceResolver.js" as MediaSourceResolver
import "../theme"

Dialog {
    id: root

    property var characters: []
    property var selectedCharacter: ({})
    property var serviceAdapter: typeof workPanelController !== "undefined" ? workPanelController : null
    property string statusText: ""
    property var pendingDeleteCharacter: ({})
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal replaceImageRequested(var character)
    signal saved(var result)
    signal blocked(var payload)

    title: (void i18n.revision, i18n.t("character.manager_title", "Character Manager"))
    header: null
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, VfTheme.dp(1250), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(750), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.radiusPanel
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    function findCharacter(characterId) {
        var target = String(characterId || "")
        var list = root.characters || []
        for (var i = 0; i < list.length; i++) {
            if (String(list[i].id || list[i].media_id || "") === target)
                return list[i]
        }
        return ({})
    }

    function deleteMessage(character) {
        var item = character || ({})
        var charId = String(item.id || item.media_id || "")
        var base = (void i18n.revision, i18n.t("character.confirm_delete", "Are you sure you want to delete {char_id}?"))
            .replace("{char_id}", charId)
        var scenes = item.used_in_scenes || item.scenes || []
        if (scenes && scenes.length > 0) {
            base += "\n\n" + (void i18n.revision, i18n.t("character.used_in_scenes", "This character appears in {count} scenes: {scenes}"))
                .replace("{count}", String(scenes.length))
                .replace("{scenes}", scenes.join(", "))
            base += "\n" + (void i18n.revision, i18n.t("character.refs_will_be_deleted", "All references will be deleted."))
        }
        return base
    }

    function requestDelete(characterId) {
        root.pendingDeleteCharacter = root.findCharacter(characterId)
        deleteConfirmDialog.open()
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || "")
        root.feedbackMessage = String(message || "")
        feedbackDialog.open()
    }

    function applyDeleteResult(result, fallbackCharacter) {
        var payload = result && typeof result === "object" ? result : ({})
        var item = fallbackCharacter || root.pendingDeleteCharacter || ({})
        var charId = String(item.id || item.media_id || payload.character_id || "")
        var charName = String(item.name || (payload.removed && payload.removed.name) || charId)

        if (!payload.ok) {
            root.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(
                    payload.message
                    || payload.error
                    || (void i18n.revision, i18n.t("character.delete_failed", "Could not delete the selected character."))
                )
            )
            return false
        }

        root.selectedCharacter = root.characters && root.characters.length > 0 ? root.characters[0] : ({})
        root.showFeedback(
            (void i18n.revision, i18n.t("common.success", "Success")),
            (void i18n.revision, i18n.t("character.delete_success", "Deleted character {char_id}."))
                .replace("{char_id}", charName)
        )
        return true
    }

    function applySelectResult(result, fallbackCharacter) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            root.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(
                    payload.message
                    || payload.error
                    || (void i18n.revision, i18n.t("character.select_failed", "Could not select the chosen character."))
                )
            )
            return false
        }
        var item = payload.character || fallbackCharacter || root.selectedCharacter || ({})
        root.selectedCharacter = item
        root.statusText = String(payload.message || "Character selected.")
        root.accept()
        return true
    }

    function commitSelect(character) {
        var item = character || root.selectedCharacter || ({})
        if (root.serviceAdapter && typeof root.serviceAdapter.selectRouteCharacter === "function") {
            root.applySelectResult(root.serviceAdapter.selectRouteCharacter(item), item)
            return
        }

        var blocker = root.structuredBlocker(
            "character_route_select_controller_missing",
            "character.route.select",
            "No WorkPanelController.selectRouteCharacter host contract is registered."
        )
        root.blocked(blocker)
        root.statusText = blocker.message
        root.showFeedback((void i18n.revision, i18n.t("common.warning", "Warning")), blocker.message)
    }

    function applyReplaceImageResult(result, fallbackCharacter) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            root.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(
                    payload.message
                    || payload.error
                    || (void i18n.revision, i18n.t("character.replace_failed", "Could not replace the selected character image."))
                )
            )
            return false
        }
        var item = payload.character || payload.item || fallbackCharacter || root.selectedCharacter || ({})
        root.selectedCharacter = item
        if (payload.characters)
            root.characters = payload.characters
        root.statusText = String(payload.message || "Character image replaced.")
        return true
    }

    function commitDelete(character) {
        var item = character || root.pendingDeleteCharacter || ({})
        var charId = String(item.id || item.media_id || "")
        if (charId.length === 0) {
            root.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                (void i18n.revision, i18n.t("character.delete_failed", "Could not delete the selected character."))
            )
            return
        }

        if (root.serviceAdapter && typeof root.serviceAdapter.removeRouteCharacter === "function") {
            root.applyDeleteResult(root.serviceAdapter.removeRouteCharacter(charId), item)
            return
        }
        var blocker = root.structuredBlocker(
            "character_route_delete_controller_missing",
            "character.route.delete",
            "No WorkPanelController.removeRouteCharacter host contract is registered."
        )
        root.blocked(blocker)
        root.statusText = blocker.message
        root.showFeedback((void i18n.revision, i18n.t("common.warning", "Warning")), blocker.message)
    }

    function openCharacterPreview(character) {
        if (typeof nativeShell === "undefined")
            return
        var item = character || ({})
        var path = String(
            item.blob_path
            || item.source_path
            || item.file_path
            || item.path
            || item.thumbnail_file_path
            || item.thumbnail_path
            || ""
        )
        if (path.length > 0) {
            nativeShell.openPath(path)
            return
        }
        var raw = String(item.thumbnail_base64 || item.image_base64 || item.base64 || "")
        if (raw.length === 0)
            return
        var saved = nativeShell.saveBase64TempImage(raw, "char_preview_" + String(item.id || item.media_id || "image") + "_", ".png")
        if (saved && saved.ok && String(saved.path || "").length > 0)
            nativeShell.openPath(String(saved.path))
    }

    contentItem: ColumnLayout {
        spacing: 0

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 14
            Layout.preferredHeight: VfTheme.dp(36)
            text: (void i18n.revision, i18n.t("character.manager_header", "Quản lý nhân vật đã tạo"))
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(16)
            font.weight: VfTheme.weightTitle
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 14
            Layout.rightMargin: 14
            Layout.preferredHeight: VfTheme.dp(52)
            color: VfTheme.surfaceSoft

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(18)
                    anchors.rightMargin: VfTheme.dp(18)
                    text: (void i18n.revision, i18n.t("character.manager_info", "You can replace images, delete unnecessary characters, or edit information.\nWhen deleting a character, all references in scenes will be automatically removed."))
                    color: "#666666"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.statusText.length > 0 ? 32 : 0
            visible: root.statusText.length > 0
            color: VfTheme.surface

            Text {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(10)
                anchors.rightMargin: VfTheme.dp(10)
                text: root.statusText
                color: "#0D9488"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.italic: true
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 14
            Layout.rightMargin: 14
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
            radius: VfTheme.dp(4)
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                CharacterTableHeader {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(46)
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: availableWidth
                    contentHeight: charListCol.implicitHeight
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    Column {
                        id: charListCol
                        width: parent.availableWidth
                        spacing: 0

                        Repeater {
                            model: root.characters || []  // perf-lint: disable=R2  static/single-populate config list — one-time rebuild, no continuous cost

                            CharacterRow {
                                width: parent.width
                                character: modelData
                                selected: String((root.selectedCharacter || ({})).id || "") === String(modelData.id || "")
                                onSelectedRequested: character => root.selectedCharacter = character
                                onEditRequested: character => {
                                    root.selectedCharacter = character
                                    editDialog.openForEdit(character)
                                }
                                onReplaceImageRequested: character => {
                                    root.selectedCharacter = character
                                    root.replaceImageRequested(character)
                                }
                                onDeleteRequested: characterId => root.requestDelete(characterId)
                            }
                        }

                        Text {
                            width: parent.width
                            height: VfTheme.dp(80)
                            visible: (root.characters || []).length === 0
                            text: (void i18n.revision, i18n.t("character.no_characters", "No characters."))
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 14
            Layout.rightMargin: 14
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            spacing: VfTheme.dp(8)

            Item { Layout.fillWidth: true }

            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                minWidth: VfTheme.dp(90)
                onClicked: root.reject()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("common.apply", "Apply"))
                tone: "success"
                minWidth: VfTheme.dp(104)
                onClicked: root.commitSelect(root.selectedCharacter)
            }
        }
    }

    CharacterEditDialog {
        id: editDialog
        onSavePayloadRequested: payload => root.saveCharacterPayload(payload)
    }

    Dialog {
        id: deleteConfirmDialog

        modal: true
        width: VfDialogMetrics.width(parent, VfTheme.dp(460), VfTheme.dp(64))
        padding: 0
        header: null
        title: (void i18n.revision, i18n.t("character.confirm_delete_title", "Confirm delete"))
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        parent: Overlay.overlay
        anchors.centerIn: parent

        background: Rectangle {
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
            radius: VfTheme.dp(6)
        }

        contentItem: ColumnLayout {
            spacing: 0

            Text {
                Layout.fillWidth: true
                Layout.margins: 16
                text: root.deleteMessage(root.pendingDeleteCharacter)
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: VfTheme.border
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 12
                spacing: VfTheme.dp(8)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(90)
                    onClicked: deleteConfirmDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                    tone: "danger"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        deleteConfirmDialog.close()
                        root.commitDelete(root.pendingDeleteCharacter)
                    }
                }
            }
        }
    }

    Dialog {
        id: feedbackDialog

        modal: true
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        parent: Overlay.overlay
        anchors.centerIn: parent
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

    onCharactersChanged: {
        if (!root.selectedCharacter || !root.selectedCharacter.id) {
            if (root.characters && root.characters.length > 0)
                root.selectedCharacter = root.characters[0]
            return
        }
        var selectedId = String(root.selectedCharacter.id || "")
        for (var i = 0; i < root.characters.length; i++) {
            if (String(root.characters[i].id || "") === selectedId) {
                root.selectedCharacter = root.characters[i]
                return
            }
        }
        root.selectedCharacter = root.characters && root.characters.length > 0 ? root.characters[0] : ({})
    }

    function saveCharacterPayload(payload) {
        var data = payload || ({})
        if (root.serviceAdapter && typeof root.serviceAdapter.saveRouteCharacter === "function") {
            var result = root.serviceAdapter.saveRouteCharacter(data)
            root.applySaveResult(result, data)
            return
        }

        var blocker = root.structuredBlocker(
            "character_route_host_contract_missing",
            "character.route.save",
            "No WorkPanelController.saveRouteCharacter host contract is registered."
        )
        root.blocked(blocker)
        root.statusText = blocker.message
    }

    function applySaveResult(result, fallbackPayload) {
        var response = result || ({ ok: true, item: fallbackPayload })
        if (response.ok === false) {
            var blocker = response.blocker || response
            root.blocked(blocker)
            var message = String(response.message || response.error || response.code || "Character save failed.")
            root.statusText = message
            editDialog.statusText = message
            root.feedbackTitle = (void i18n.revision, i18n.t("common.warning", "Warning"))
            root.feedbackMessage = message
            feedbackDialog.open()
            return
        }
        var item = response.item || response.character || fallbackPayload || ({})
        root.selectedCharacter = item
        if (response.characters)
            root.characters = response.characters
        editDialog.statusText = ""
        editDialog.accept()
        root.saved(response)
        root.statusText = String(response.message || "Character reference saved for this route.")
    }

    function structuredBlocker(code, action, message) {
        return {
            ok: false,
            blocked: true,
            code: code,
            error: code,
            action: action,
            message: message,
            blocker: {
                code: code,
                action: action,
                message: message,
                requires: ["WorkPanelController.saveRouteCharacter"]
            }
        }
    }

    component CharacterTableHeader: Rectangle {
        color: VfTheme.surfaceSoft
        border.color: VfTheme.borderStrong

        RowLayout {
            anchors.fill: parent
            spacing: 0

            HeaderCell { text: "Preview"; Layout.preferredWidth: VfTheme.dp(100) }
            HeaderCell { text: "ID"; Layout.preferredWidth: VfTheme.dp(80) }
            HeaderCell { text: (void i18n.revision, i18n.t("common.name", "Tên")); Layout.preferredWidth: VfTheme.dp(150) }
            HeaderCell { text: (void i18n.revision, i18n.t("common.description", "Mô tả")); Layout.fillWidth: true }
            HeaderCell { text: "Scenes"; Layout.preferredWidth: VfTheme.dp(80) }
            HeaderCell { text: (void i18n.revision, i18n.t("character_manager_dialog.actions", "Thao tác")); Layout.preferredWidth: VfTheme.dp(450) }
        }
    }

    component HeaderCell: Rectangle {
        property string text: ""

        Layout.fillHeight: true
        color: "transparent"
        border.color: VfTheme.borderStrong
        border.width: 1

        Text {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(8)
            anchors.rightMargin: VfTheme.dp(8)
            text: parent.text
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontControl
            font.weight: VfTheme.weightTitle
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    component CharacterRow: Rectangle {
        id: row

        property var character: ({})
        property bool selected: false

        signal selectedRequested(var character)
        signal editRequested(var character)
        signal replaceImageRequested(var character)
        signal deleteRequested(string characterId)

        function charId() {
            return String(row.character.id || "")
        }

        function charName() {
            return String(row.character.name || "")
        }

        function charDescription() {
            var value = String(row.character.description || row.character.prompt || row.character.summary || "")
            return value.length > 100 ? value.slice(0, 100) + "..." : value
        }

        function scenesText() {
            var scenes = row.character.used_in_scenes || row.character.scenes || []
            if (scenes && scenes.length > 0)
                return scenes.join(", ")
            return (void i18n.revision, i18n.t("character.not_used", "Not used"))
        }

        function hasImage() {
            return row.imageSource().length > 0
        }

        function imageSource() {
            return MediaSourceResolver.imageSource(row.character || ({}))
        }

        function actuallyUsed() {
            return row.character.actually_used !== false
        }

        height: VfTheme.dp(125)
        color: row.selected ? VfTheme.blueFill : VfTheme.surface
        opacity: row.actuallyUsed() ? 1.0 : 0.55
        border.color: VfTheme.border
        border.width: 1

        MouseArea {
            anchors.fill: parent
            onClicked: row.selectedRequested(row.character)
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            PreviewCell {
                Layout.preferredWidth: VfTheme.dp(100)
                Layout.fillHeight: true
                imageSource: row.imageSource()
                base64Data: String(row.character.thumbnail_base64 || row.character.image_base64 || row.character.base64 || "")
                charId: row.charId()
                placeholder: row.hasImage() ? "!" : "..."
                onOpenRequested: root.openCharacterPreview(row.character)
            }

            BodyCell {
                Layout.preferredWidth: VfTheme.dp(80)
                Layout.fillHeight: true
                text: row.charId()
                center: true
            }

            BodyCell {
                Layout.preferredWidth: VfTheme.dp(150)
                Layout.fillHeight: true
                text: row.charName()
            }

            BodyCell {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: row.charDescription()
                tooltip: String(row.character.description || row.character.prompt || row.character.summary || "")
            }

            BodyCell {
                Layout.preferredWidth: VfTheme.dp(80)
                Layout.fillHeight: true
                text: row.scenesText()
                center: true
                danger: !row.actuallyUsed()
            }

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(450)
                Layout.fillHeight: true
                color: "transparent"
                border.color: VfTheme.border

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(5)
                    spacing: VfTheme.dp(3)

                    VfButton {
                        text: (void i18n.revision, i18n.t("character.edit", "Edit"))
                        minWidth: VfTheme.dp(90)
                        onClicked: row.editRequested(row.character)
                    }

                    VfButton {
                        text: (void i18n.revision, i18n.t("character.replace_image", "Replace"))
                        minWidth: VfTheme.dp(110)
                        onClicked: row.replaceImageRequested(row.character)
                    }

                    VfButton {
                        text: (void i18n.revision, i18n.t("character.delete", "Delete"))
                        tone: "danger"
                        minWidth: VfTheme.dp(90)
                        onClicked: row.deleteRequested(row.charId())
                    }
                }
            }
        }
    }

    component PreviewCell: ClickableImageLabel {
        property string placeholder: "..."

        width: VfTheme.dp(80)
        height: VfTheme.dp(80)
    }

    component BodyCell: Rectangle {
        property string text: ""
        property string tooltip: ""
        property bool center: false
        property bool danger: false

        color: "transparent"
        border.color: VfTheme.border

        Text {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(8)
            text: parent.text
            color: parent.danger ? "#EF4444" : VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontControl
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: parent.center ? Text.AlignHCenter : Text.AlignLeft
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight

            ToolTip.visible: parent.tooltip.length > 0 && cellMouse.containsMouse
            ToolTip.text: parent.tooltip
        }

        MouseArea {
            id: cellMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }
    }
}
