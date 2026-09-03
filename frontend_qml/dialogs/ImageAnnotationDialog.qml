import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "ImageAnnotationDialog"

    property string imageBase64: ""
    property string currentTool: "pen"
    property string promptText: ""
    property string statusText: ""
    property var marks: []

    signal annotationComplete(string annotatedBase64, string prompt)

    parent: Overlay.overlay
    modal: true
    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("image_annotation.window_title", "Image Annotation"))
        iconName: "framed-picture"
        onCloseClicked: root.reject()
    }
    width: VfDialogMetrics.width(parent, VfTheme.dp(1200), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(820), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    function openFor(base64Image, prompt) {
        root.imageBase64 = String(base64Image || "")
        root.promptText = String(prompt || "")
        promptInput.text = root.promptText
        if (root.imageBase64.length > 0 && root.marks.length === 0) {
            root.marks = [
                { type: "rect", x: 0.18, y: 0.20, w: 0.26, h: 0.18, color: "#EF4444" },
                { type: "arrow", x: 0.58, y: 0.28, w: 0.20, h: 0.18, color: "#EF4444" }
            ]
        }
        root.open()
    }

    function imageSource() {
        return root.imageBase64.length > 0 ? "data:image/png;base64," + root.imageBase64 : ""
    }

    function setTool(tool) {
        root.currentTool = String(tool || "pen")
        return true
    }

    function setPromptForVisualTest(prompt) {
        promptInput.text = String(prompt || "")
        root.promptText = promptInput.text
        return true
    }

    function addMarkForVisualTest(typeName) {
        var next = [].concat(root.marks || [])
        next.push({ type: String(typeName || root.currentTool), x: 0.34, y: 0.48, w: 0.25, h: 0.14, color: "#22C55E" })
        root.marks = next
        return true
    }

    function markCountForVisualTest() {
        return (root.marks || []).length
    }

    function submitForVisualTest() {
        return root.submitAnnotation()
    }

    function submitAnnotation() {
        var prompt = promptInput.text.trim()
        if (prompt.length <= 0) {
            root.statusText = (void i18n.revision, i18n.t("image_annotation.enter_instructions_error", "Enter edit instructions first."))
            return false
        }
        root.promptText = prompt
        root.annotationComplete(root.imageBase64, prompt)
        root.accept()
        return true
    }

    background: Rectangle {
        radius: VfTheme.dp(10)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(72)
            color: "#1F2937"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(16)
                anchors.rightMargin: VfTheme.dp(16)
                spacing: VfTheme.dp(10)

                ToolButton { label: "Pen"; value: "pen" }
                ToolButton { label: "Arrow"; value: "arrow" }
                ToolButton { label: "Rect"; value: "rect" }
                ToolButton { label: "Text"; value: "text" }

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(34)
                    Layout.preferredHeight: VfTheme.dp(34)
                    radius: VfTheme.dp(17)
                    color: "#EF4444"
                    border.color: VfTheme.redBorderSoft
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.clear", "Clear"))
                    minWidth: VfTheme.dp(88)
                    onClicked: root.marks = []
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: (void i18n.revision, i18n.t("image_annotation.window_title", "Image Annotation"))
                    color: "#FFFFFF"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(18)
                    font.weight: Font.Bold
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: VfTheme.surfaceSoft

            Item {
                id: canvasHost
                anchors.fill: parent
                anchors.margins: 0

                Rectangle {
                    id: imageFrame
                    anchors.fill: parent
                    color: "#FFFFFF"
                    border.color: VfTheme.borderStrong
                    radius: 0
                    clip: true

                    Image {
                        id: sourceImage
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(12)
                        source: root.imageSource()
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }

                    Repeater {
                        model: root.marks || []
                        delegate: Item {
                            x: Number(modelData.x || 0) * imageFrame.width
                            y: Number(modelData.y || 0) * imageFrame.height
                            width: Math.max(24, Number(modelData.w || 0.15) * imageFrame.width)
                            height: Math.max(18, Number(modelData.h || 0.10) * imageFrame.height)

                            Rectangle {
                                visible: String(modelData.type || "") === "rect"
                                anchors.fill: parent
                                color: "transparent"
                                border.color: String(modelData.color || "#EF4444")
                                border.width: 4
                                radius: VfTheme.dp(4)
                            }

                            Rectangle {
                                visible: String(modelData.type || "") !== "rect"
                                width: parent.width
                                height: VfTheme.dp(4)
                                anchors.centerIn: parent
                                rotation: String(modelData.type || "") === "arrow" ? 28 : 0
                                color: String(modelData.color || "#EF4444")
                            }

                            Text {
                                visible: String(modelData.type || "") === "text"
                                text: "NOTE"
                                color: String(modelData.color || "#EF4444")
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(24)
                                font.weight: Font.Black
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(150)
            color: VfTheme.surface
            border.color: VfTheme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(14)
                spacing: VfTheme.dp(8)

                Text {
                    text: (void i18n.revision, i18n.t("image_annotation.edit_instructions_label", "Edit instructions"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(14)
                    font.weight: Font.Bold
                }

                TextArea {
                    id: promptInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.promptText
                    placeholderText: (void i18n.revision, i18n.t("image_annotation.edit_instructions_placeholder", "Describe the edit you want for this annotated image."))
                    wrapMode: TextArea.Wrap
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                    background: Rectangle {
                        radius: VfTheme.dp(8)
                        color: VfTheme.surfaceSoft
                        border.color: promptInput.activeFocus ? VfTheme.primary : VfTheme.borderStrong
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: root.statusText
                        color: "#DC2626"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        elide: Text.ElideRight
                    }
                    VfButton {
                        text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                        minWidth: VfTheme.dp(96)
                        onClicked: root.reject()
                    }
                    VfButton {
                        text: (void i18n.revision, i18n.t("image_annotation.apply_edits", "Apply edits"))
                        tone: "success"
                        minWidth: VfTheme.dp(130)
                        onClicked: root.submitAnnotation()
                    }
                }
            }
        }
    }

    component ToolButton: Rectangle {
        property string label: ""
        property string value: ""
        Layout.preferredWidth: VfTheme.dp(78)
        Layout.preferredHeight: VfTheme.dp(42)
        radius: VfTheme.dp(8)
        color: root.currentTool === value ? VfTheme.primary : VfTheme.textMuted
        border.color: root.currentTool === value ? VfTheme.blueBorderSoft : VfTheme.textMuted

        Text {
            anchors.centerIn: parent
            text: parent.label
            color: "#FFFFFF"
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(13)
            font.weight: Font.Bold
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.setTool(parent.value)
        }
    }
}
