import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property var failedCharacters: []
    property var editedPrompts: ({})
    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal retryRequested(var editedCharacters)
    signal skipRequested()

    header: VfDialogHeader {
        title: root.cleanLeadingIcon((void i18n.revision, i18n.t("chargen_policy.title", "CharGen Policy")))
        iconName: "framed-picture"
        onCloseClicked: root.reject()
    }
    modal: true
    parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 875, 48)
    height: VfDialogMetrics.height(parent, 688, 48)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton

    function openFor(characters) {
        root.failedCharacters = characters || []
        root.editedPrompts = ({})
        root.statusText = ""
        root.open()
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || "")
        root.feedbackMessage = String(message || "")
        feedbackDialog.open()
    }

    function applyRetryResult(result) {
        var response = result || ({})
        if (response.ok === false) {
            var message = String(
                response.message
                || response.error
                || response.code
                || (void i18n.revision, i18n.t("chargen_policy.retry_failed", "CharGen retry failed."))
            )
            root.statusText = message
            root.showFeedback((void i18n.revision, i18n.t("common.warning", "Warning")), message)
            return
        }
        root.statusText = String(
            response.message
            || (void i18n.revision, i18n.t("chargen_policy.retry_submitted", "CharGen retry submitted."))
        )
        root.accept()
    }

    function cleanLeadingIcon(value) {
        var text = String(value || "").trim()
        text = text.replace(/^[\uD800-\uDBFF][\uDC00-\uDFFF]\uFE0F?\s*/, "")
        text = text.replace(/^[\u2300-\u23FF]\uFE0F?\s*/, "")
        text = text.replace(/^[\u2600-\u27BF]\uFE0F?\s*/, "")
        text = text.replace(/^[\u2B00-\u2BFF]\uFE0F?\s*/, "")
        return text.trim()
    }

    function characterId(item, index) {
        return String(item.char_id || item.charId || index)
    }

    function characterName(item) {
        return String(item.char_name || item.charName || item.name || "")
    }

    function characterPrompt(item) {
        return String(item.prompt || item.original_prompt || "")
    }

    function editedCharacters() {
        var result = []
        for (var i = 0; i < root.failedCharacters.length; i++) {
            var item = root.failedCharacters[i] || ({})
            var id = root.characterId(item, i)
            var original = root.characterPrompt(item)
            var nextPrompt = String(root.editedPrompts[id] === undefined ? original : root.editedPrompts[id]).trim()
            var data = Object.assign({}, item.char_data ? item.char_data : item)
            if (nextPrompt.length > 0 && nextPrompt !== original)
                data._edited_prompt = nextPrompt
            result.push(data)
        }
        return result
    }

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.radiusPanel
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.topMargin: 20
            spacing: VfTheme.dp(8)

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(24)
                color: VfTheme.surfaceSoft

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(4)
                    text: root.cleanLeadingIcon((void i18n.revision, i18n.t("chargen_policy.header", "Some character prompts were blocked by the image safety policy.")))
                    color: "#FFB74D"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(15)
                    font.weight: VfTheme.weightTitle
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(40)
                color: VfTheme.surfaceSoft

                Text {
                    anchors.fill: parent
                    text: (void i18n.revision, i18n.t("chargen_policy.description", "Edit the prompt manually, then retry. Unchanged characters will be retried with the original prompt."))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: VfTheme.border
            }

            Text {
                Layout.fillWidth: true
                visible: root.statusText.length > 0
                text: root.statusText
                color: "#FFB74D"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                wrapMode: Text.WordWrap
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20
            clip: true
            contentWidth: availableWidth
            contentHeight: chargenBody.implicitHeight
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                id: chargenBody
                width: parent.availableWidth
                spacing: VfTheme.dp(10)

                Repeater {
                    model: root.failedCharacters

                    delegate: Rectangle {
                        property var charInfo: modelData || ({})
                        property string charId: root.characterId(charInfo, index)

                        Layout.fillWidth: true
                        implicitHeight: charColumn.implicitHeight + 20
                        radius: VfTheme.dp(6)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.borderStrong

                        ColumnLayout {
                            id: charColumn
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(10)
                            spacing: VfTheme.dp(6)

                            Text {
                                Layout.fillWidth: true
                                text: charId + " - " + root.characterName(charInfo)
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                font.weight: VfTheme.weightTitle
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: String(charInfo.error || "").length > 0
                                text: String(charInfo.error || "").length > 150
                                    ? String(charInfo.error || "").slice(0, 150) + "..."
                                    : String(charInfo.error || "")
                                color: "#FF7043"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("chargen_policy.prompt_label", "Prompt"))
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(116)
                                radius: VfTheme.dp(4)
                                color: VfTheme.surface
                                border.color: charPromptArea.activeFocus ? VfTheme.primary : VfTheme.borderStrong
                                clip: true

                                ScrollView {
                                    id: charPromptScroll
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(4)
                                    contentWidth: availableWidth
                                    contentHeight: charPromptArea.implicitHeight
                                    clip: true
                                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                                    TextArea {
                                        id: charPromptArea
                                        width: charPromptScroll.availableWidth
                                        text: root.characterPrompt(charInfo)
                                        wrapMode: TextEdit.WordWrap
                                        selectByMouse: true
                                        color: VfTheme.text
                                        selectedTextColor: VfTheme.text
                                        selectionColor: "#FDE68A"
                                        font.family: "Consolas"
                                        font.pixelSize: VfTheme.dp(11)
                                        onTextChanged: {
                                            var next = root.editedPrompts
                                            next[charId] = text
                                            root.editedPrompts = next
                                        }
                                        background: Item {}
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(58)
            color: VfTheme.surface
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(20)
                anchors.rightMargin: VfTheme.dp(20)
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: root.cleanLeadingIcon((void i18n.revision, i18n.t("chargen_policy.skip", "Skip")))
                    minWidth: VfTheme.dp(100)
                    onClicked: {
                        root.skipRequested()
                        root.reject()
                    }
                }

                VfButton {
                    text: root.cleanLeadingIcon((void i18n.revision, i18n.t("chargen_policy.retry", "Retry")))
                    tone: "accent"
                    minWidth: VfTheme.dp(112)
                    onClicked: root.retryRequested(root.editedCharacters())
                }
            }
        }
    }

    Dialog {
        id: feedbackDialog

        modal: true
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(64))
        padding: 0
        anchors.centerIn: Overlay.overlay
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        parent: Overlay.overlay

        background: Rectangle {
            color: VfTheme.surface
            radius: VfTheme.dp(4)
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)
            anchors.fill: parent
            anchors.margins: VfTheme.dp(16)

            Text {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(16)
                font.weight: VfTheme.weightTitle
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
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
