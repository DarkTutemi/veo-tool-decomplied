import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property string characterId: ""
    property string characterName: ""
    property string characterPrompt: ""
    property var characterItem: ({})
    property var characterMetadata: ({})
    property string statusText: ""

    signal saveRequested(string characterId, string name, string prompt)
    signal savePayloadRequested(var payload)
    signal saved(var payload)

    readonly property string dialogTitle: (void i18n.revision, i18n.t("character.edit_title", "Edit Character {char_id}"))
        .replace("{char_id}", String(root.characterId || root.characterName || ""))

    title: ""
    header: null
    modal: true
    parent: Overlay.overlay
    width: VfDialogMetrics.width(parent, VfTheme.dp(620), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(480), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton
    onOpened: syncFields()

    background: Rectangle {
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        radius: VfTheme.dp(12)
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(58)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            Text {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(16)
                anchors.rightMargin: VfTheme.dp(16)
                text: root.dialogTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(16)
                font.weight: VfTheme.weightTitle
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 16
            spacing: VfTheme.dp(8)

            Label {
                text: (void i18n.revision, i18n.t("character.name_label", "Name"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            TextField {
                id: nameInput
                Layout.fillWidth: true
                text: root.characterName
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
                leftPadding: VfTheme.dp(10)
                rightPadding: VfTheme.dp(10)
                topPadding: VfTheme.dp(8)
                bottomPadding: VfTheme.dp(8)
                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: VfTheme.surface
                    border.color: nameInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                    border.width: 1
                }
            }

            Label {
                text: (void i18n.revision, i18n.t("character.description_label", "Description"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            TextArea {
                id: promptInput
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.characterPrompt
                wrapMode: TextArea.Wrap
                selectByMouse: true
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
                leftPadding: VfTheme.dp(10)
                rightPadding: VfTheme.dp(10)
                topPadding: VfTheme.dp(8)
                bottomPadding: VfTheme.dp(8)
                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: VfTheme.surface
                    border.color: promptInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                    border.width: 1
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root.statusText.length > 0
                text: root.statusText
                color: VfTheme.redText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(64)
            color: VfTheme.surface
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(12)
                spacing: VfTheme.dp(8)

                Item {
                    Layout.fillWidth: true
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(86)
                    onClicked: root.reject()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    tone: "primary"
                    minWidth: VfTheme.dp(86)
                    onClicked: root.save()
                }
            }
        }
    }

    function openForCreate() {
        root.characterItem = ({})
        root.characterId = ""
        root.characterName = ""
        root.characterPrompt = ""
        root.characterMetadata = ({})
        root.statusText = ""
        root.open()
    }

    function syncFields() {
        nameInput.text = root.characterName
        promptInput.text = root.characterPrompt
    }

    function openForEdit(character) {
        var item = character || ({})
        root.characterItem = item
        root.characterId = String(item.id || item.character_id || "")
        root.characterName = String(item.name || item.title || "")
        root.characterPrompt = String(item.description || item.prompt || item.summary || "")
        root.characterMetadata = root.metadataFrom(item)
        root.statusText = ""
        root.open()
    }

    function metadataFrom(character) {
        var item = character || ({})
        var metadata = item.metadata || ({})
        var result = {}
        var hasMetadata = false
        for (var key in metadata) {
            result[key] = metadata[key]
            hasMetadata = true
        }
        var passthrough = ["source", "asset_type", "media_id", "path", "file_path", "source_path", "thumbnail_base64", "used_in_scenes", "has_image"]
        for (var i = 0; i < passthrough.length; i++) {
            var name = passthrough[i]
            if (item[name] !== undefined && item[name] !== null && item[name] !== "") {
                result[name] = item[name]
                hasMetadata = true
            }
        }
        return hasMetadata ? result : ({})
    }

    function payload() {
        var name = String(nameInput.text || "").trim()
        var prompt = String(promptInput.text || "").trim()
        var item = root.characterItem || ({})
        return {
            id: root.characterId,
            character_id: root.characterId,
            name: name,
            title: name,
            description: prompt,
            prompt: prompt,
            summary: prompt,
            asset_type: String(item.asset_type || root.characterMetadata.asset_type || "character"),
            source: String(item.source || root.characterMetadata.source || "qml_draft"),
            metadata: root.characterMetadata || ({}),
            original: item,
            service: "qml_app.controllers.work_panel_controller.WorkPanelController.saveRouteCharacter"
        }
    }

    function save() {
        var data = root.payload()
        root.statusText = ""
        root.saveRequested(data.character_id, data.name, data.description)
        root.savePayloadRequested(data)
    }
}
