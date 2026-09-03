import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property var analysisData: ({})
    property var scenes: []
    property int selectedIndex: 0
    property string validationMessage: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property string rawJson: ""

    signal saveSceneRequested(string sceneId, string title, string prompt, string notes)
    signal copyJsonRequested(string rowId)

    parent: Overlay.overlay
    modal: true
    width: VfDialogMetrics.width(parent, VfTheme.dp(1120), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(760), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    closePolicy: Popup.CloseOnEscape

    function openFor(data) {
        root.analysisData = data || ({})
        root.scenes = (root.analysisData.scenes || []).slice()
        root.selectedIndex = 0
        root.validationMessage = ""
        root.rawJson = String(root.analysisData.raw_json || "")
        root.open()
    }

    function sceneAt(index) {
        var items = root.scenes || []
        if (index < 0 || index >= items.length)
            return ({})
        return items[index] || ({})
    }

    function selectedScene() {
        return sceneAt(root.selectedIndex)
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || (void i18n.revision, i18n.t("common.notice", "Notice")))
        root.feedbackMessage = String(message || "")
        feedbackDialog.open()
    }

    function applySaveResult(result, fallbackSceneId, title, prompt, notes) {
        var payload = result || ({})
        if (payload.ok === false) {
            var message = String(payload.message || payload.error || payload.code || (void i18n.revision, i18n.t("common.save_failed", "Save failed.")))
            root.validationMessage = message
            root.showFeedback(
                (void i18n.revision, i18n.t("clone.scene_save_failed_title", "Save scene failed")),
                message
            )
            return false
        }

        var sceneId = String(payload.scene_id || fallbackSceneId || "")
        var updatedScene = payload.scene || ({
            scene_id: sceneId,
            title: title,
            prompt: prompt,
            notes: notes
        })
        var items = (root.scenes || []).slice()
        var replaced = false
        for (var i = 0; i < items.length; i++) {
            var currentId = String((items[i] || {}).scene_id || (items[i] || {}).id || "")
            if (currentId === sceneId) {
                items[i] = Object.assign({}, items[i] || {}, updatedScene)
                replaced = true
                break
            }
        }
        if (!replaced && sceneId.length > 0)
            items.push(updatedScene)
        root.scenes = items
        root.validationMessage = ""
        return true
    }

    background: Rectangle {
        radius: VfTheme.dp(16)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.border
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(72)
            color: VfTheme.blueFill
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(20)
                spacing: VfTheme.dp(14)

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(42)
                    Layout.preferredHeight: VfTheme.dp(42)
                    radius: VfTheme.dp(12)
                    color: VfTheme.blueFill

                    Text {
                        anchors.centerIn: parent
                        text: "SC"
                        color: "#2563EB"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(15)
                        font.weight: Font.DemiBold
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(2)

                    Text {
                        text: (void i18n.revision, i18n.t("clone.scene_analysis_title", "Clone Scene Analysis"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(22)
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: (void i18n.revision, i18n.t(
                            "clone.scene_analysis_subtitle",
                            "Review heuristic scenes from the selected clone row and refine prompts before continuing."
                        ))
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                    }
                }

                Text {
                    text: String((root.analysisData.scenes || []).length) + " scene(s)"
                    color: VfTheme.blueText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                    font.weight: Font.Medium
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(360)
                Layout.fillHeight: true
                color: VfTheme.surface
                border.color: VfTheme.border

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(16)
                    spacing: VfTheme.dp(10)

                    Text {
                        text: (void i18n.revision, i18n.t("clone.scene_list", "Scene list"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(15)
                        font.weight: Font.DemiBold
                    }

                    ListView {
                        id: sceneList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: root.scenes || []
                        currentIndex: root.selectedIndex
                        spacing: VfTheme.dp(8)
                        reuseItems: true

                        delegate: Rectangle {
                            required property var modelData
                            required property int index

                            width: sceneList.width
                            height: VfTheme.dp(108)
                            radius: VfTheme.dp(12)
                            color: ListView.isCurrentItem ? VfTheme.blueFill : VfTheme.surfaceSoft
                            border.color: ListView.isCurrentItem ? VfTheme.blueBorderSoft : VfTheme.border

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.selectedIndex = index
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(12)
                                spacing: VfTheme.dp(6)

                                Text {
                                    text: String(modelData.scene_id || modelData.id || ("SCENE_" + String(index + 1)))
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(13)
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: String(modelData.title || modelData.prompt || "")
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(13)
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: String(modelData.notes || modelData.status || "")
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(12)
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: VfTheme.blueFill
                border.color: VfTheme.border

                Flickable {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(18)
                    contentWidth: width
                    contentHeight: editorColumn.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: editorColumn
                        width: parent.width
                        spacing: VfTheme.dp(12)

                        VfPanel {
                            Layout.fillWidth: true
                            title: (void i18n.revision, i18n.t("clone.scene_context", "Scene context"))
                            subtitle: ""
                            accent: VfTheme.blueBorderSoft
                            dense: true

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(8)

                                Text {
                                    text: (void i18n.revision, i18n.t("clone.analysis_note", "Analysis note")) + ": " + String(root.analysisData.note || "heuristic")
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(12)
                                }

                                Text {
                                    text: (void i18n.revision, i18n.t("clone.analysis_row", "Row")) + ": " + String(root.analysisData.row_id || "")
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(12)
                                }
                            }
                        }

                        VfPanel {
                            Layout.fillWidth: true
                            title: String(root.selectedScene().scene_id || root.selectedScene().id || (void i18n.revision, i18n.t("clone.scene_editor", "Scene editor")))
                            subtitle: ""
                            accent: VfTheme.blueBorderSoft
                            dense: true

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(10)

                                TextField {
                                    id: titleField
                                    Layout.fillWidth: true
                                    placeholderText: (void i18n.revision, i18n.t("clone.scene_title_placeholder", "Short scene title"))
                                    text: String(root.selectedScene().title || "")
                                    color: VfTheme.text
                                    placeholderTextColor: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    background: Rectangle {
                                        color: VfTheme.surface
                                        border.color: VfTheme.borderBox
                                        border.width: 1
                                        radius: VfTheme.radiusControl
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: VfTheme.dp(240)
                                    radius: VfTheme.radiusControl
                                    color: VfTheme.surface
                                    border.color: VfTheme.borderBox
                                    border.width: 1
                                    clip: true

                                    ScrollView {
                                        id: promptScroll
                                        anchors.fill: parent
                                        anchors.margins: VfTheme.dp(6)
                                        contentWidth: availableWidth
                                        contentHeight: promptArea.implicitHeight
                                        clip: true
                                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                                        TextArea {
                                            id: promptArea
                                            width: promptScroll.availableWidth
                                            wrapMode: TextEdit.Wrap
                                            placeholderText: (void i18n.revision, i18n.t("clone.scene_prompt_placeholder", "Scene prompt / visual description"))
                                            text: String(root.selectedScene().prompt || "")
                                            color: VfTheme.text
                                            placeholderTextColor: VfTheme.textSubtle
                                            font.family: VfTheme.fontFamily
                                            background: Item {}
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: VfTheme.dp(120)
                                    radius: VfTheme.radiusControl
                                    color: VfTheme.surface
                                    border.color: VfTheme.borderBox
                                    border.width: 1
                                    clip: true

                                    ScrollView {
                                        id: notesScroll
                                        anchors.fill: parent
                                        anchors.margins: VfTheme.dp(6)
                                        contentWidth: availableWidth
                                        contentHeight: notesArea.implicitHeight
                                        clip: true
                                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                                        TextArea {
                                            id: notesArea
                                            width: notesScroll.availableWidth
                                            wrapMode: TextEdit.Wrap
                                            placeholderText: (void i18n.revision, i18n.t("clone.scene_notes_placeholder", "Notes"))
                                            text: String(root.selectedScene().notes || "")
                                            color: VfTheme.text
                                            placeholderTextColor: VfTheme.textSubtle
                                            font.family: VfTheme.fontFamily
                                            background: Item {}
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true

                                    Item { Layout.fillWidth: true }

                                    VfButton {
                                        text: (void i18n.revision, i18n.t("common.save", "Save"))
                                        tone: "primary"
                                        minWidth: VfTheme.dp(104)
                                        enabled: String(root.selectedScene().scene_id || root.selectedScene().id || "").length > 0
                                        onClicked: {
                                            var sceneId = String(root.selectedScene().scene_id || root.selectedScene().id || "")
                                            root.validationMessage = ""
                                            root.saveSceneRequested(sceneId, titleField.text, promptArea.text, notesArea.text)
                                        }
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: root.validationMessage.length > 0
                                    text: root.validationMessage
                                    color: VfTheme.redText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(11)
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(64)
            color: VfTheme.surface
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(16)
                spacing: VfTheme.dp(12)

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("clone.scene_analysis_footer", "Review scenes here, then continue clone flow from the main tab."))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("clone.copy_json", "Copy JSON"))
                    minWidth: VfTheme.dp(112)
                    enabled: root.rawJson.length > 0
                    onClicked: root.copyJsonRequested(String(root.analysisData.row_id || ""))
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Close"))
                    minWidth: VfTheme.dp(104)
                    onClicked: root.close()
                }
            }
        }
    }

    Dialog {
        id: feedbackDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: VfDialogMetrics.width(parent, VfTheme.dp(360), VfTheme.dp(64))
        standardButtons: Dialog.NoButton
        title: root.feedbackTitle
        header: Label {
            text: feedbackDialog.title
            visible: text.length > 0
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(16)
            font.weight: Font.DemiBold
            leftPadding: VfTheme.dp(16)
            rightPadding: VfTheme.dp(16)
            topPadding: VfTheme.dp(14)
            bottomPadding: VfTheme.dp(4)
        }

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.width: 1
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(16)

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                wrapMode: Text.WordWrap
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                color: VfTheme.text
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    minWidth: VfTheme.dp(88)
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }
}
