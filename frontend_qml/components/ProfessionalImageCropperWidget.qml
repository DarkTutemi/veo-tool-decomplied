import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string sourcePath: ""
    property string mediaId: ""
    property string aspectRatio: "16:9"
    property rect cropRect: Qt.rect(0, 0, 1, 1)
    property var contractResult: ({})

    signal cropChanged(var cropRect)
    signal sourceRequested()
    signal cropRequested(var payload)

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: VfTheme.radiusPanel
    color: "#0F172A"
    border.color: VfTheme.borderStrong
    clip: true

    Component.onCompleted: root.resetCropRect()
    onAspectRatioChanged: root.resetCropRect()

    function fileUrl(value) {
        var raw = String(value || "")
        if (raw.length === 0)
            return ""
        if (raw.indexOf("file:") === 0 || raw.indexOf("qrc:") === 0 || raw.indexOf("data:") === 0)
            return raw
        if (raw.indexOf("http://") === 0 || raw.indexOf("https://") === 0)
            return raw
        return "file:///" + raw.replace(/\\/g, "/")
    }

    function sourceName() {
        var raw = String(root.sourcePath || "").replace(/\\/g, "/")
        return raw.length > 0 ? raw.split("/").pop() : ""
    }

    function aspectSpec() {
        var parts = String(root.aspectRatio || "16:9").split(":")
        var widthPart = Number(parts[0] || 16)
        var heightPart = Number(parts[1] || 9)
        if (!isFinite(widthPart) || widthPart <= 0)
            widthPart = 16
        if (!isFinite(heightPart) || heightPart <= 0)
            heightPart = 9
        return { width: widthPart, height: heightPart, ratio: widthPart / heightPart }
    }

    function defaultCropRect() {
        var spec = root.aspectSpec()
        var maxExtent = 0.7
        var widthValue = maxExtent
        var heightValue = widthValue / spec.ratio
        if (heightValue > maxExtent) {
            heightValue = maxExtent
            widthValue = heightValue * spec.ratio
        }
        return Qt.rect((1 - widthValue) / 2, (1 - heightValue) / 2, widthValue, heightValue)
    }

    function clampCropRect(rect) {
        var next = rect || root.defaultCropRect()
        var widthValue = Math.max(0.05, Math.min(1, Number(next.width || 0)))
        var heightValue = Math.max(0.05, Math.min(1, Number(next.height || 0)))
        var xValue = Math.max(0, Math.min(1 - widthValue, Number(next.x || 0)))
        var yValue = Math.max(0, Math.min(1 - heightValue, Number(next.y || 0)))
        return Qt.rect(xValue, yValue, widthValue, heightValue)
    }

    function setCropRect(rect) {
        root.cropRect = root.clampCropRect(rect)
        root.cropChanged(root.normalizedCropRect())
    }

    function resetCropRect() {
        root.setCropRect(root.defaultCropRect())
    }

    function moveCropByNormalized(dx, dy) {
        root.setCropRect(Qt.rect(
            root.cropRect.x + Number(dx || 0),
            root.cropRect.y + Number(dy || 0),
            root.cropRect.width,
            root.cropRect.height
        ))
    }

    function resizeCropFromHandle(handle, normX, normY, startRect) {
        var spec = root.aspectSpec()
        var base = startRect || root.cropRect
        var pointerX = Math.max(0, Math.min(1, Number(normX || 0)))
        var pointerY = Math.max(0, Math.min(1, Number(normY || 0)))
        var minWidth = 0.08
        var minHeight = minWidth / spec.ratio
        var anchorX = 0
        var anchorY = 0
        var maxWidth = 1
        var maxHeight = 1
        var rectX = 0
        var rectY = 0

        if (handle === "bottom_right") {
            anchorX = base.x
            anchorY = base.y
            maxWidth = 1 - anchorX
            maxHeight = 1 - anchorY
            rectX = anchorX
            rectY = anchorY
        } else if (handle === "bottom_left") {
            anchorX = base.x + base.width
            anchorY = base.y
            maxWidth = anchorX
            maxHeight = 1 - anchorY
            rectY = anchorY
        } else if (handle === "top_right") {
            anchorX = base.x
            anchorY = base.y + base.height
            maxWidth = 1 - anchorX
            maxHeight = anchorY
            rectX = anchorX
        } else if (handle === "top_left") {
            anchorX = base.x + base.width
            anchorY = base.y + base.height
            maxWidth = anchorX
            maxHeight = anchorY
        } else {
            return
        }

        var desiredWidth = Math.max(minWidth, Math.abs(pointerX - anchorX))
        var desiredHeight = Math.max(minHeight, Math.abs(pointerY - anchorY))
        if (desiredWidth / desiredHeight > spec.ratio)
            desiredWidth = desiredHeight * spec.ratio
        else
            desiredHeight = desiredWidth / spec.ratio

        var maxAspectWidth = Math.max(minWidth, Math.min(maxWidth, maxHeight * spec.ratio))
        var widthValue = Math.max(minWidth, Math.min(desiredWidth, maxAspectWidth))
        var heightValue = widthValue / spec.ratio

        if (handle === "bottom_left" || handle === "top_left")
            rectX = anchorX - widthValue
        if (handle === "top_right" || handle === "top_left")
            rectY = anchorY - heightValue

        root.setCropRect(Qt.rect(rectX, rectY, widthValue, heightValue))
    }

    function normalizedCropRect() {
        var rect = root.clampCropRect(root.cropRect)
        return {
            x: rect.x,
            y: rect.y,
            width: rect.width,
            height: rect.height
        }
    }

    function cropPayload() {
        return {
            media_id: root.mediaId,
            source_path: root.sourcePath,
            aspect_ratio: root.aspectRatio,
            crop_rect: root.normalizedCropRect(),
            dry_run: true
        }
    }

    function applyResult(result) {
        root.contractResult = result || ({})
    }

    function resultText() {
        if (root.contractResult.blocker)
            return String(root.contractResult.blocker.message || root.contractResult.blocker.code)
        if (root.contractResult.ok)
            return "Crop saved to a temporary file. The selection can now return a cropped image path."
        return root.sourcePath.length > 0 ? "Select Crop & Save to produce a temporary cropped image." : "Select an image source to crop."
    }

    Item {
        id: cropArea

        anchors.fill: parent
        anchors.margins: VfTheme.dp(12)
        anchors.bottomMargin: VfTheme.dp(116)
        clip: true

        Image {
            anchors.fill: parent
            source: root.fileUrl(root.sourcePath)
            fillMode: Image.PreserveAspectFit
            visible: root.sourcePath.length > 0
        }

        Text {
            anchors.centerIn: parent
            visible: root.sourcePath.length === 0
            text: "Drop or select image"
            color: VfTheme.borderStrong
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSection
            font.weight: Font.Bold
        }

        Rectangle {
            id: cropFrame

            x: root.cropRect.x * cropArea.width
            y: root.cropRect.y * cropArea.height
            width: root.cropRect.width * cropArea.width
            height: root.cropRect.height * cropArea.height
            color: "transparent"
            border.color: "#60A5FA"
            border.width: 2

            Text {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: VfTheme.dp(8)
                text: root.aspectRatio + " crop plan"
                color: VfTheme.blueFill
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.weight: VfTheme.weightStrong
            }

            MouseArea {
                anchors.fill: parent
                z: 1
                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                property var startPoint: Qt.point(0, 0)
                property rect startRect: Qt.rect(0, 0, 1, 1)

                onPressed: mouse => {
                    startPoint = cropFrame.mapToItem(cropArea, mouse.x, mouse.y)
                    startRect = root.cropRect
                }
                onPositionChanged: mouse => {
                    if (!pressed || cropArea.width <= 0 || cropArea.height <= 0)
                        return
                    var currentPoint = cropFrame.mapToItem(cropArea, mouse.x, mouse.y)
                    root.setCropRect(Qt.rect(
                        startRect.x + (currentPoint.x - startPoint.x) / cropArea.width,
                        startRect.y + (currentPoint.y - startPoint.y) / cropArea.height,
                        startRect.width,
                        startRect.height
                    ))
                }
            }

            Repeater {
                model: ["top_left", "top_right", "bottom_left", "bottom_right"]

                delegate: Rectangle {
                    id: resizeHandle

                    property string handleName: String(modelData)

                    width: VfTheme.dp(13)
                    height: VfTheme.dp(13)
                    radius: VfTheme.dp(3)
                    color: VfTheme.surface
                    border.color: "#60A5FA"
                    border.width: 2
                    z: 2
                    x: handleName.indexOf("right") >= 0 ? cropFrame.width - width / 2 : -width / 2
                    y: handleName.indexOf("bottom") >= 0 ? cropFrame.height - height / 2 : -height / 2

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: resizeHandle.handleName === "top_left" || resizeHandle.handleName === "bottom_right"
                                     ? Qt.SizeFDiagCursor
                                     : Qt.SizeBDiagCursor
                        property rect startRect: Qt.rect(0, 0, 1, 1)

                        onPressed: {
                            startRect = root.cropRect
                        }
                        onPositionChanged: mouse => {
                            if (!pressed || cropArea.width <= 0 || cropArea.height <= 0)
                                return
                            var currentPoint = resizeHandle.mapToItem(cropArea, mouse.x, mouse.y)
                            root.resizeCropFromHandle(
                                resizeHandle.handleName,
                                currentPoint.x / cropArea.width,
                                currentPoint.y / cropArea.height,
                                startRect
                            )
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: VfTheme.dp(104)
        color: "#CC0F172A"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(10)
            spacing: VfTheme.dp(6)

            Text {
                Layout.fillWidth: true
                text: root.sourceName() || "No image selected"
                color: VfTheme.border
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightStrong
                elide: Text.ElideMiddle
            }

            Text {
                Layout.fillWidth: true
                text: root.resultText()
                color: VfTheme.borderStrong
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                VfButton {
                    text: "Select Source"
                    minWidth: VfTheme.dp(112)
                    onClicked: root.sourceRequested()
                }

                VfButton {
                    text: "Reset"
                    minWidth: VfTheme.dp(70)
                    onClicked: root.resetCropRect()
                }

                Item { Layout.fillWidth: true }

                VfButton {
                    text: "Crop & Save"
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    enabled: root.sourcePath.length > 0
                    onClicked: {
                        var payload = root.cropPayload()
                        root.cropChanged(payload.crop_rect)
                        root.cropRequested(payload)
                    }
                }
            }
        }
    }
}
