import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property string sourcePath: ""
    property string mediaId: ""
    property string aspectRatio: "16:9"
    property var cropResult: ({})
    property string croppedImagePath: ""

    signal sourceRequested()
    signal cropRequested(var payload)
    signal cropCompleted(var result)

    modal: true
    parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 900, 48)
    height: VfDialogMetrics.height(parent, 700, 48)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    header: null

    function openFor(payload) {
        var data = payload || ({})
        root.sourcePath = String(data.sourcePath || data.source_path || "")
        root.mediaId = String(data.mediaId || data.media_id || "")
        root.aspectRatio = String(data.aspectRatio || data.aspect_ratio || "16:9")
        root.cropResult = ({})
        root.croppedImagePath = ""
        root.open()
    }

    function applyResult(result) {
        root.cropResult = result || ({})
        root.croppedImagePath = String(root.cropResult.cropped_image_path || root.cropResult.output_path || "")
        cropper.applyResult(root.cropResult)
        if (root.cropResult.ok && root.croppedImagePath.length > 0)
            root.cropCompleted(root.cropResult)
    }

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.dp(12)
        border.color: VfTheme.borderBox
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(60)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(16)
                spacing: VfTheme.dp(10)

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(2)

                    Text {
                        text: (void i18n.revision, i18n.t("image_cropper.title", "Crop Image " + root.aspectRatio)).replace("{ratio}", root.aspectRatio)
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(18)
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        text: (void i18n.revision, i18n.t("image_cropper.subtitle", "Select the crop area, then save the temporary image."))
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        elide: Text.ElideRight
                    }
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Close"))
                    minWidth: VfTheme.dp(88)
                    tone: "neutral"
                    onClicked: root.reject()
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 16
            spacing: VfTheme.dp(12)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                VfButton {
                    text: "16:9"
                    tone: root.aspectRatio === "16:9" ? "primary" : "neutral"
                    minWidth: VfTheme.dp(72)
                    onClicked: {
                        root.aspectRatio = "16:9"
                        cropper.aspectRatio = root.aspectRatio
                    }
                }

                VfButton {
                    text: "9:16"
                    tone: root.aspectRatio === "9:16" ? "primary" : "neutral"
                    minWidth: VfTheme.dp(72)
                    onClicked: {
                        root.aspectRatio = "9:16"
                        cropper.aspectRatio = root.aspectRatio
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: String(root.sourcePath || "").replace(/\\/g, "/").split("/").pop() || "No image selected"
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    elide: Text.ElideMiddle
                    Layout.maximumWidth: VfTheme.dp(360)
                }
            }

            ProfessionalImageCropperWidget {
                id: cropper

                Layout.fillWidth: true
                Layout.fillHeight: true
                sourcePath: root.sourcePath
                mediaId: root.mediaId
                aspectRatio: root.aspectRatio
                onSourceRequested: root.sourceRequested()
                onCropRequested: payload => root.cropRequested(payload)
            }
        }
    }
}
