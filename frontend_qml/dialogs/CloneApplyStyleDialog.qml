import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    parent: Overlay.overlay

    property var styleItems: []
    property int selectedIndex: 0
    property string validationMessage: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal applyRequested(var style)

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 420, 80)
    height: implicitHeight
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    header: null

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.dp(10)
        border.color: VfTheme.borderBox
    }

    function trText(key, fallback) {
        if (typeof i18n !== "undefined" && i18n && i18n.t)
            return (void i18n.revision, i18n.t(key, fallback))
        return fallback
    }

    function styleModel() {
        // Index 0 = auto-style (recommended default): the AI reads the source video's
        // look once and applies it to every scene, so no manual pick is needed.
        return [{
            id: "__auto_source__",
            name: root.trText("clone.auto_style_source", "🎨 Tự động theo video gốc"),
            veo3_prompt: "",
            auto_style: true
        }, {
            id: "",
            name: root.trText("clone.ai_style", "AI Style"),
            veo3_prompt: ""
        }].concat(root.styleItems || [])
    }

    function openFor(items) {
        root.styleItems = items || []
        root.selectedIndex = 0
        root.validationMessage = ""
        root.open()
    }

    function currentStyle() {
        var model = root.styleModel()
        if (root.selectedIndex < 0 || root.selectedIndex >= model.length)
            return model[0]
        return model[root.selectedIndex]
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || root.trText("common.notice", "Notice"))
        root.feedbackMessage = String(message || "")
        feedbackDialog.open()
    }

    function applyResult(result) {
        var payload = result || ({})
        if (payload.ok === false) {
            var message = String(payload.message || payload.error || payload.code || root.trText("common.apply_failed", "Apply failed."))
            root.validationMessage = message
            root.showFeedback(
                root.trText("clone.apply_style_failed_title", "Apply style failed"),
                message
            )
            return false
        }
        root.validationMessage = ""
        root.close()
        return true
    }

    contentItem: ColumnLayout {
        spacing: VfTheme.dp(14)

        Item { Layout.fillWidth: true; Layout.preferredHeight: VfTheme.dp(16) }

        Text {
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            text: root.trText("clone.apply_style_title", "Apply style to all")
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(17)
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            wrapMode: Text.WordWrap
            text: root.trText("clone.apply_style_label", "Choose a style to apply to every clone job currently in queue.")
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
        }

        NoScrollComboBox {
            id: styleCombo
            Layout.fillWidth: true
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            model: root.styleModel()
            textRole: "name"
            currentIndex: root.selectedIndex
            onActivated: index => root.selectedIndex = index
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            Layout.preferredHeight: Math.max(96, previewText.implicitHeight + 20)
            color: VfTheme.surfaceSoft
            radius: VfTheme.dp(8)
            border.color: VfTheme.border

            Text {
                id: previewText
                anchors.fill: parent
                anchors.margins: VfTheme.dp(10)
                wrapMode: Text.WordWrap
                text: {
                    var current = root.currentStyle()
                    if (current && current.auto_style)
                        return root.trText("clone.auto_style_desc", "AI phân tích style của video gốc (màu, ánh sáng, ống kính, nhịp) và áp cho mọi cảnh — không cần chọn style tay.")
                    var prompt = String(current.veo3_prompt || current.master_prompt_style || current.raw_style_prompt || "")
                    return prompt.length > 0
                        ? prompt
                        : root.trText("clone.ai_style_desc", "Use AI style for every queued clone job.")
                }
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            visible: root.validationMessage.length > 0
            text: root.validationMessage
            color: VfTheme.redText
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            Layout.bottomMargin: 18
            spacing: VfTheme.dp(8)

            Item { Layout.fillWidth: true }

            VfButton {
                text: root.trText("common.cancel", "Cancel")
                minWidth: VfTheme.dp(92)
                tone: "neutral"
                onClicked: root.close()
            }

            VfButton {
                text: root.trText("common.apply", "Apply")
                minWidth: VfTheme.dp(104)
                tone: "primary"
                onClicked: {
                    root.validationMessage = ""
                    root.applyRequested(root.currentStyle())
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
                    text: root.trText("common.ok", "OK")
                    minWidth: VfTheme.dp(88)
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }
}

