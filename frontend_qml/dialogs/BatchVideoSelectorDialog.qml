import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "BatchVideoSelectorDialog"

    property var videoPaths: []
    property string promptText: ""
    property string selectedVideo: ""
    property string statusText: ""

    signal videoSelected(string path)
    signal playRequested(string path)
    signal playAllRequested(var paths)

    parent: Overlay.overlay
    modal: true
    title: (void i18n.revision, i18n.t("batch_video.window_title", "Batch Video Selector"))
    header: null
    width: VfDialogMetrics.width(parent, 1000, 56)
    height: VfDialogMetrics.height(parent, 750, 56)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    function openFor(paths, prompt) {
        root.videoPaths = paths || []
        root.promptText = String(prompt || "")
        root.selectedVideo = root.videoPaths.length > 0 ? String(root.videoPaths[0] || "") : ""
        root.statusText = root.videoPaths.length > 0
            ? (void i18n.revision, i18n.t("batch_video.video_count", "{count} video(s)")).replace("{count}", String(root.videoPaths.length))
            : (void i18n.revision, i18n.t("batch_video.no_video", "No videos."))
        root.open()
    }

    function basename(path) {
        var text = String(path || "")
        var parts = text.split(/[\\/]/)
        return parts.length > 0 ? parts[parts.length - 1] : text
    }

    function selectVideo(path) {
        root.selectedVideo = String(path || "")
        root.videoSelected(root.selectedVideo)
        root.statusText = root.basename(root.selectedVideo)
        return true
    }

    function selectIndexForVisualTest(index) {
        var i = Number(index || 0)
        if (i < 0 || i >= root.videoPaths.length)
            return false
        return root.selectVideo(String(root.videoPaths[i] || ""))
    }

    function selectedVideoForVisualTest() {
        return String(root.selectedVideo || "")
    }

    function videoCountForVisualTest() {
        return (root.videoPaths || []).length
    }

    function requestPlaySelected() {
        if (root.selectedVideo.length <= 0)
            return false
        root.playRequested(root.selectedVideo)
        if (typeof nativeShell !== "undefined" && nativeShell.openPath)
            nativeShell.openPath(root.selectedVideo)
        return true
    }

    function requestPlayAll() {
        var paths = root.videoPaths || []
        root.playAllRequested(paths)
        return paths.length > 0
    }

    background: Rectangle {
        radius: VfTheme.dp(10)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(24)
        spacing: VfTheme.dp(12)

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(66)
            radius: VfTheme.dp(8)
            gradient: Gradient {
                GradientStop { position: 0; color: "#4F7DF3" }
                GradientStop { position: 1; color: "#7C3AED" }
            }

            Row {
                anchors.centerIn: parent
                spacing: VfTheme.dp(8)

                VfAppIcon {
                    name: "movie-camera"
                    size: VfTheme.dp(24)
                    framed: false
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: (void i18n.revision, i18n.t("batch_video.window_title", "Batch Video Selector"))
                    color: "#FFFFFF"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(26)
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(54)
            radius: VfTheme.dp(6)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border
            border.width: 1

            Text {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(18)
                anchors.rightMargin: VfTheme.dp(18)
                text: "Prompt: " + (root.promptText.length > 0 ? root.promptText : (void i18n.revision, i18n.t("batch_video.pick_prompt", "Pick one generated video to preview or use.")))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(14)
                font.italic: true
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(42)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border
            border.width: 1

            Text {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(14)
                text: (void i18n.revision, i18n.t("batch_video.generated_count", "Generated {count} videos. Click a video to play:"))
                    .replace("{count}", String(root.videoPaths.length))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(14)
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
            border.width: 1
            clip: true

            GridView {
                id: videoGrid
                anchors.fill: parent
                anchors.margins: VfTheme.dp(8)
                cellWidth: 236
                cellHeight: 292
                clip: true
                reuseItems: true
                model: root.videoPaths || []

                delegate: Rectangle {
                    width: VfTheme.dp(224)
                    height: VfTheme.dp(276)
                    radius: VfTheme.dp(8)
                    color: root.selectedVideo === String(modelData || "") ? VfTheme.blueFill : VfTheme.surface
                    border.width: 2
                    border.color: root.selectedVideo === String(modelData || "") ? "#60A5FA" : VfTheme.borderStrong

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(10)
                        spacing: VfTheme.dp(8)

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(28)
                            radius: VfTheme.dp(6)
                            color: root.selectedVideo === String(modelData || "") ? VfTheme.blueFill : VfTheme.surfaceSoft

                            Text {
                                anchors.centerIn: parent
                                text: (void i18n.revision, i18n.t("batch_video.video_index", "Video {index}/{total}"))
                                    .replace("{index}", String(index + 1))
                                    .replace("{total}", String(root.videoPaths.length))
                                color: root.selectedVideo === String(modelData || "") ? VfTheme.blueText : VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                font.weight: Font.Bold
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(128)
                            radius: VfTheme.dp(8)
                            color: VfTheme.surfaceSoft
                            border.color: VfTheme.borderStrong

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: VfTheme.dp(4)

                                Text {
                                    text: "VIDEO"
                                    color: "#2563EB"
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(20)
                                    font.weight: Font.Black
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Text {
                                    text: (void i18n.revision, i18n.t("batch_video.thumbnail_async", "Preview thumbnail"))
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: root.basename(modelData)
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }

                        VfButton {
                            Layout.fillWidth: true
                            text: root.selectedVideo === String(modelData || "")
                                ? (void i18n.revision, i18n.t("batch_video.selected", "Selected"))
                                : (void i18n.revision, i18n.t("batch_video.select", "Select"))
                            tone: root.selectedVideo === String(modelData || "") ? "primary" : "neutral"
                            onClicked: root.selectVideo(String(modelData || ""))
                        }

                        VfButton {
                            Layout.fillWidth: true
                            text: (void i18n.revision, i18n.t("batch_video.play", "Play"))
                            tone: "success"
                            onClicked: {
                                root.selectVideo(String(modelData || ""))
                                root.requestPlaySelected()
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        acceptedButtons: Qt.LeftButton
                        onClicked: root.selectVideo(String(modelData || ""))
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                text: root.statusText
                color: VfTheme.borderStrong
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                elide: Text.ElideMiddle
            }

            VfButton {
                text: (void i18n.revision, i18n.t("batch_video.play_all", "Play all"))
                tone: "success"
                minWidth: VfTheme.dp(130)
                enabled: root.videoPaths.length > 0
                onClicked: root.requestPlayAll()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("common.close", "Close"))
                minWidth: VfTheme.dp(90)
                onClicked: root.reject()
            }
        }
    }
}
