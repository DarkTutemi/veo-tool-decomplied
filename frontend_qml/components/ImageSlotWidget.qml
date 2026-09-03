import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string title: "Asset"
    property string path: ""
    property string caption: ""
    property string mediaId: ""
    property string assetType: ""
    property string aspectRatio: "VIDEO_ASPECT_RATIO_LANDSCAPE"
    property string tierMode: "ultra"
    property bool selected: false
    property color accent: VfTheme.primary

    signal clicked()
    signal removeRequested()
    signal previewRequested(var preview)
    signal openRequested(var preview)
    signal reupscaleRequested(var payload)

    Layout.fillWidth: true
    implicitHeight: VfTheme.dp(112)
    radius: VfTheme.radiusControl
    color: mouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface
    border.color: root.selected ? root.accent : VfTheme.borderBox
    border.width: root.selected ? 2 : 1
    clip: true

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

    function extension() {
        var raw = root.path.split("?")[0].toLowerCase()
        var dot = raw.lastIndexOf(".")
        return dot >= 0 ? raw.slice(dot) : ""
    }

    function isImagePath() {
        var ext = root.extension()
        return [".png", ".jpg", ".jpeg", ".webp", ".bmp", ".gif"].indexOf(ext) >= 0
    }

    function isVideoPath() {
        var ext = root.extension()
        return [".mp4", ".mov", ".avi", ".mkv", ".webm"].indexOf(ext) >= 0
    }

    function previewPayload() {
        return {
            title: root.title,
            path: root.path,
            preview_path: root.path,
            media_id: root.mediaId,
            asset_type: root.assetType || (root.isVideoPath() ? "video" : (root.isImagePath() ? "image" : "asset")),
            is_video: root.isVideoPath(),
            is_image: root.isImagePath(),
            caption: root.caption
        }
    }

    function canReupscale() {
        return root.mediaId.length > 0 && root.isVideoPath() && root.tierMode.toLowerCase() !== "premium"
    }

    function reupscalePayload() {
        return {
            media_id: root.mediaId,
            resolution: "1080p",
            original_path: root.path,
            aspect_ratio: root.aspectRatio,
            tier_mode: root.tierMode.toLowerCase(),
            dry_run: true
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.clicked()
            root.previewRequested(root.previewPayload())
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(8)
        spacing: VfTheme.dp(8)
        z: 1

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(92)
            Layout.fillHeight: true
            radius: VfTheme.dp(8)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.borderSoft
            clip: true

            Image {
                anchors.fill: parent
                source: root.path.length > 0 && root.isImagePath() ? root.fileUrl(root.path) : ""
                fillMode: Image.PreserveAspectCrop
                // Decode at display size (not native res) off the GUI thread — a full-res
                // asset image otherwise blocks + wastes texture memory on a small slot.
                asynchronous: true
                cache: true
                sourceSize.width: width > 1 ? Math.ceil(width) : 0
                sourceSize.height: height > 1 ? Math.ceil(height) : 0
                visible: root.path.length > 0 && root.isImagePath()
            }

            Text {
                anchors.centerIn: parent
                visible: root.path.length === 0 || !root.isImagePath()
                text: root.path.length === 0 ? "+" : (root.isVideoPath() ? "VIDEO" : "ASSET")
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: root.path.length === 0 ? 24 : 11
                font.weight: Font.Bold
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: VfTheme.dp(4)

            Text {
                Layout.fillWidth: true
                text: root.title
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.caption || root.path || "No asset selected"
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)

                VfButton {
                    text: "Preview"
                    minWidth: VfTheme.dp(72)
                    implicitHeight: VfTheme.dp(26)
                    enabled: root.path.length > 0 || root.mediaId.length > 0
                    onClicked: root.previewRequested(root.previewPayload())
                }

                VfButton {
                    text: "Open"
                    minWidth: VfTheme.dp(58)
                    implicitHeight: VfTheme.dp(26)
                    enabled: root.path.length > 0
                    onClicked: root.openRequested(root.previewPayload())
                }

                VfButton {
                    text: "Re-upscale"
                    minWidth: VfTheme.dp(86)
                    implicitHeight: VfTheme.dp(26)
                    enabled: root.canReupscale()
                    onClicked: root.reupscaleRequested(root.reupscalePayload())
                }

                Item { Layout.fillWidth: true }

                VfButton {
                    text: "Remove"
                    minWidth: VfTheme.dp(70)
                    implicitHeight: VfTheme.dp(26)
                    onClicked: root.removeRequested()
                }
            }
        }
    }
}
