import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    parent: Overlay.overlay

    property string guideTitle: (void i18n.revision, i18n.t("script_splitting.guide_dialog_title", "VeoFlow Script Writing Guide"))
    property string guideText: ""
    property string guideResourcePath: "resources/script_authoring_guide.md"
    property string templateResourcePath: "resources/script_template.md"
    property string narratorTemplateResourcePath: "resources/script_template_narrator.md"
    property string copyButtonText: (void i18n.revision, i18n.t("script_splitting.guide_copy_btn", "Copy All"))
    property string templateButtonText: (void i18n.revision, i18n.t("script_splitting.template_btn", "Copy mẫu trống"))
    property string narratorButtonText: (void i18n.revision, i18n.t("script_splitting.narrator_template_btn", "Mẫu dẫn truyện"))

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 860, 64)
    height: VfDialogMetrics.height(parent, 620, 64)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    function fallbackGuideText() {
        return "Guide file not found."
    }

    function loadBundledGuide() {
        if (typeof nativeShell === "undefined")
            return {"ok": false, "text": fallbackGuideText(), "message": "nativeShell unavailable."}
        var loaded = nativeShell.readProjectTextFile(guideResourcePath)
        if (!loaded.ok)
            loaded.text = fallbackGuideText()
        return loaded
    }

    function openGuide() {
        var loaded = loadBundledGuide()
        root.guideTitle = (void i18n.revision, i18n.t("script_splitting.guide_dialog_title", "VeoFlow Script Writing Guide"))
        root.guideText = String(loaded.text || fallbackGuideText())
        root.copyButtonText = (void i18n.revision, i18n.t("script_splitting.guide_copy_btn", "Copy All"))
        root.templateButtonText = (void i18n.revision, i18n.t("script_splitting.template_btn", "Copy mẫu trống"))
        root.open()
    }

    function openWithContent(titleText, contentText) {
        root.guideTitle = String(titleText || (void i18n.revision, i18n.t("script_splitting.guide_dialog_title", "VeoFlow Script Writing Guide")))
        root.guideText = String(contentText || fallbackGuideText())
        root.copyButtonText = (void i18n.revision, i18n.t("script_splitting.guide_copy_btn", "Copy All"))
        root.open()
    }

    // Nạp SKELETON điền sẵn vào khung xem + copy thẳng vào clipboard, để user chỉ
    // việc dán vào ô "Kịch bản" (hoặc đưa cho AI ngoài điền hộ). Tách khỏi guide
    // (guide = giải thích; template = phần điền).
    function showTemplate() {
        if (typeof nativeShell === "undefined")
            return
        var loaded = nativeShell.readProjectTextFile(templateResourcePath)
        var tpl = String((loaded.ok ? loaded.text : "") || "")
        if (!tpl) {
            root.templateButtonText = (void i18n.revision, i18n.t("script_splitting.template_missing", "Không tìm thấy mẫu"))
            return
        }
        root.guideText = tpl
        root.guideTitle = (void i18n.revision, i18n.t("script_splitting.template_title", "Mẫu kịch bản — điền vào chỗ <...>"))
        var result = nativeShell.setClipboardText(tpl)
        if (result.ok)
            root.templateButtonText = (void i18n.revision, i18n.t("script_splitting.template_copied", "Đã copy mẫu ✓"))
    }

    // Mẫu kịch bản DẪN TRUYỆN: tự chứa hướng dẫn — copy nguyên khối đưa cho AI
    // ngoài (ChatGPT/Gemini) viết hộ, hoặc user tự điền để kiểm soát kịch bản.
    function showNarratorTemplate() {
        if (typeof nativeShell === "undefined")
            return
        var loaded = nativeShell.readProjectTextFile(narratorTemplateResourcePath)
        var tpl = String((loaded.ok ? loaded.text : "") || "")
        if (!tpl) {
            root.narratorButtonText = (void i18n.revision, i18n.t("script_splitting.template_missing", "Không tìm thấy mẫu"))
            return
        }
        root.guideText = tpl
        root.guideTitle = (void i18n.revision, i18n.t("script_splitting.narrator_template_title", "Mẫu kịch bản DẪN TRUYỆN — copy cho AI viết hoặc tự điền"))
        var result = nativeShell.setClipboardText(tpl)
        if (result.ok)
            root.narratorButtonText = (void i18n.revision, i18n.t("script_splitting.template_copied", "Đã copy mẫu ✓"))
        if (!root.opened)
            root.open()
    }

    background: Rectangle {
        radius: VfTheme.dp(10)
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
            // Bo góc trên khớp radius dialog (dp10) để header KHÔNG che/đè viền bo
            // tròn của dialog ở 2 góc trên (trước đây header vuông phủ lên viền).
            topLeftRadius: VfTheme.dp(10)
            topRightRadius: VfTheme.dp(10)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(14)
                anchors.rightMargin: VfTheme.dp(14)
                spacing: VfTheme.dp(10)

                Text {
                    Layout.fillWidth: true
                    text: root.guideTitle
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(18)
                    font.weight: VfTheme.weightTitle
                    elide: Text.ElideRight
                }

                VfButton {
                    text: root.narratorButtonText
                    onClicked: root.showNarratorTemplate()
                }

                VfButton {
                    text: root.templateButtonText
                    tone: "primary"
                    onClicked: root.showTemplate()
                }

                VfButton {
                    text: root.copyButtonText
                    onClicked: {
                        if (typeof nativeShell === "undefined")
                            return
                        var result = nativeShell.setClipboardText(root.guideText)
                        if (result.ok)
                            root.copyButtonText = (void i18n.revision, i18n.t("script_splitting.guide_copied", "Copied!"))
                    }
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Close"))
                    onClicked: root.close()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            // Góc trên vuông (nối liền header), góc dưới bo khớp radius dialog để
            // không che viền bo tròn ở 2 góc dưới.
            topLeftRadius: 0
            topRightRadius: 0
            bottomLeftRadius: VfTheme.dp(10)
            bottomRightRadius: VfTheme.dp(10)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.borderStrong
            clip: true

            ScrollView {
                id: guideScroll
                anchors.fill: parent
                anchors.margins: VfTheme.dp(16)
                contentWidth: availableWidth
                contentHeight: guideArea.implicitHeight
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                TextArea {
                    id: guideArea
                    width: guideScroll.availableWidth
                    readOnly: true
                    wrapMode: TextEdit.Wrap
                    textFormat: TextEdit.PlainText
                    text: root.guideText
                    color: VfTheme.text
                    selectedTextColor: "#FFFFFF"
                    selectionColor: VfTheme.primary
                    font.family: "Consolas"
                    font.pixelSize: VfTheme.dp(13)
                    background: Item {}
                    padding: VfTheme.dp(12)
                }
            }
        }
    }
}
