import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property var templates: []
    property var ideas: []
    property string templateId: ""
    property var selectedTemplate: ({})
    property string seedTopic: ""
    property string statusText: ""
    property string pendingDeleteIdeaId: ""
    property string pendingDeleteIdeaTopic: ""

    signal templateRequested(string templateId)
    signal generateRequested(string templateId, string seedTopic)
    signal applyRequested(string templateId, string ideaId)
    signal deleteRequested(string templateId, string ideaId)

    readonly property string dialogTitle: (void i18n.revision, i18n.t("idea_bank.title", "Content planner"))

    title: ""
    header: null
    modal: true
    parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 900, 64)
    height: VfDialogMetrics.height(parent, 600, 64)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    function optionIndex(searchValue) {
        var items = root.templates || []
        for (var i = 0; i < items.length; i++) {
            if (String(items[i].id || "") === String(searchValue || ""))
                return i
        }
        return items.length > 0 ? 0 : -1
    }

    function templateById(searchValue) {
        var items = root.templates || []
        for (var i = 0; i < items.length; i++) {
            if (String(items[i].id || "") === String(searchValue || ""))
                return items[i]
        }
        return items.length > 0 ? items[0] : ({})
    }

    function openFor(initialTemplateId, topic) {
        root.seedTopic = String(topic || "")
        root.statusText = ""
        root.templateRequested(String(initialTemplateId || root.templateId || ""))
        root.open()
    }

    function requestDeleteIdea(idea) {
        var item = idea || ({})
        root.pendingDeleteIdeaId = String(item.id || "")
        root.pendingDeleteIdeaTopic = String(item.topic || "")
        if (root.pendingDeleteIdeaId.length === 0)
            return
        deleteConfirmDialog.open()
    }

    function applyGenerateResult(result) {
        var payload = result || ({})
        root.statusText = String(payload.message || payload.error || "")
    }

    function applyDeleteResult(result) {
        var payload = result || ({})
        root.statusText = String(payload.message || payload.error || "")
        if (payload.ok)
            deleteConfirmDialog.close()
    }

    function applyApplyResult(result) {
        var payload = result || ({})
        root.statusText = String(payload.message || payload.error || "")
        if (payload.ok)
            root.accept()
    }

    background: Rectangle {
        radius: VfTheme.dp(12)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(58)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(16)
                anchors.rightMargin: VfTheme.dp(16)
                spacing: VfTheme.dp(10)

                Text {
                    Layout.fillWidth: true
                    text: root.dialogTitle
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(18)
                    font.weight: VfTheme.weightTitle
                    elide: Text.ElideRight
                }

                Text {
                    Layout.maximumWidth: VfTheme.dp(280)
                    text: root.statusText
                    visible: root.statusText.length > 0
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    elide: Text.ElideRight
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Close"))
                    onClicked: root.close()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 14
            spacing: VfTheme.dp(12)

            VfPanel {
                Layout.preferredWidth: Math.max(300, Math.round(root.width * 0.36))
                Layout.fillHeight: true
                title: (void i18n.revision, i18n.t("idea_bank.filter_label", "Template"))
                subtitle: ""

                NoScrollComboBox {
                    id: templateCombo
                    Layout.fillWidth: true
                    height: VfTheme.dp(34)
                    model: root.templates || []
                    textRole: "name"
                    currentIndex: root.optionIndex(root.templateId)
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                    onActivated: {
                        var item = root.templates[currentIndex] || ({})
                        root.templateRequested(String(item.id || ""))
                    }

                    contentItem: Text {
                        leftPadding: VfTheme.dp(10)
                        rightPadding: VfTheme.dp(26)
                        text: templateCombo.displayText
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontBody
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        radius: VfTheme.radiusControl
                        color: VfTheme.surface
                        border.color: templateCombo.activeFocus ? VfTheme.primary : VfTheme.borderBox
                    }
                }

                Text {
                    Layout.fillWidth: true
                    textFormat: Text.RichText
                    text: "<b>" + (void i18n.revision, i18n.t("idea_bank.desc_label", "Mô tả:")) + "</b> "
                        + String(root.templateById(root.templateId).description || "")
                        + "<br><br>"
                        + (void i18n.revision, i18n.t("idea_bank.desc_placeholder", "Select a template to plan content ideas."))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    wrapMode: Text.WordWrap
                }

                VfButton {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("idea_bank.btn_generate_ai", "Generate AI ideas"))
                    tone: "primary"
                    minWidth: VfTheme.dp(180)
                    onClicked: root.generateRequested(root.templateId, root.seedTopic)
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.statusText.length > 0
                    text: root.statusText
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    wrapMode: Text.WordWrap
                }
            }

            VfPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: (void i18n.revision, i18n.t("idea_bank.saved_list_label", "Saved ideas"))
                subtitle: ""

                ScrollView {
                    id: ideasScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: availableWidth
                    contentHeight: ideasBody.implicitHeight
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        id: ideasBody
                        width: ideasScroll.availableWidth
                        spacing: VfTheme.dp(8)

                        Text {
                            Layout.fillWidth: true
                            visible: root.ideas.length === 0
                            text: (void i18n.revision, i18n.t("idea_bank.no_ideas_msg", "No ideas yet. Generate or add one manually."))
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontBody
                            horizontalAlignment: Text.AlignHCenter
                            topPadding: VfTheme.dp(48)
                        }

                        Repeater {
                            model: root.ideas || []

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: ideaRow.implicitHeight + 18
                                radius: VfTheme.dp(10)
                                color: modelData.used ? VfTheme.surfaceSoft : VfTheme.amberFill
                                border.color: modelData.used ? VfTheme.borderSoft : VfTheme.amberBorderSoft

                                RowLayout {
                                    id: ideaRow
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(10)
                                    spacing: VfTheme.dp(10)

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: VfTheme.dp(4)

                                        Text {
                                            Layout.fillWidth: true
                                            text: String(modelData.topic || "")
                                            color: modelData.used ? VfTheme.textSubtle : VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontBody
                                            font.weight: modelData.used ? VfTheme.weightRegular : VfTheme.weightStrong
                                            font.strikeout: !!modelData.used
                                            wrapMode: Text.WordWrap
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: String(modelData.created_at || "")
                                            color: VfTheme.textSubtle
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontTiny
                                            elide: Text.ElideRight
                                        }
                                    }

                                    ColumnLayout {
                                        spacing: VfTheme.dp(6)

                                        VfButton {
                                            text: modelData.used
                                                ? (void i18n.revision, i18n.t("idea_bank.btn_reuse", "Reuse"))
                                                : (void i18n.revision, i18n.t("idea_bank.btn_apply", "Apply"))
                                            tone: "primary"
                                            minWidth: VfTheme.dp(86)
                                            onClicked: root.applyRequested(root.templateId, String(modelData.id || ""))
                                        }

                                        VfButton {
                                            text: (void i18n.revision, i18n.t("history_common.delete_btn", "Delete"))
                                            tone: "danger"
                                            minWidth: VfTheme.dp(86)
                                            onClicked: root.requestDeleteIdea(modelData)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: deleteConfirmDialog
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        width: VfDialogMetrics.width(root, 420, 80)
        x: VfDialogMetrics.centerX(root, width)
        y: VfDialogMetrics.centerY(root, height)
        padding: 0
        header: null
        parent: Overlay.overlay

        background: Rectangle {
            radius: VfTheme.dp(10)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(54)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(16)
                    anchors.rightMargin: VfTheme.dp(16)
                    text: (void i18n.revision, i18n.t("idea_bank.confirm_delete_title", "Delete idea?"))
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
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 14
                Layout.bottomMargin: 14
                spacing: VfTheme.dp(12)

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("idea_bank.confirm_delete_msg", "Are you sure you want to delete this idea?"))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                    wrapMode: Text.WordWrap
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.pendingDeleteIdeaTopic.length > 0
                    text: root.pendingDeleteIdeaTopic
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    font.weight: VfTheme.weightStrong
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(8)

                    Item { Layout.fillWidth: true }

                    VfButton {
                        text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                        onClicked: deleteConfirmDialog.close()
                    }

                    VfButton {
                        text: (void i18n.revision, i18n.t("history_common.delete_btn", "Delete"))
                        tone: "danger"
                        onClicked: {
                            root.deleteRequested(root.templateId, root.pendingDeleteIdeaId)
                        }
                    }
                }
            }
        }

        onClosed: {
            root.pendingDeleteIdeaId = ""
            root.pendingDeleteIdeaTopic = ""
        }
    }
}
