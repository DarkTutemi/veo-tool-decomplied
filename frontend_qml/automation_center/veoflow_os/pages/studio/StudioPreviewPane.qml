pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtMultimedia
import "../.."

Rectangle {
    id: root
    objectName: "studioPreviewPane"
    property var sourceData: ({})
    property var previewData: ({})
    property var compiledPreview: ({})
    property var qcData: ({})
    property var controlPlaneBridge: null
    property string aspectRatio: "9:16"
    property bool previewBusy: false
    property bool afterAvailable: false
    property bool canCompile: false
    property string selectedView: "before"
    property bool fullscreenMode: false
    property bool previewPrimed: false
    property bool fullscreenFrameReady: false
    property bool fullscreenWasPlaying: false
    signal compileRequested()
    signal qcDetailsRequested()
    readonly property var sourceAsset: root.sourceData.asset || ({})
    readonly property var beforeData: root.previewData.before || ({})
    readonly property var manifest: root.compiledPreview.manifest || ({})
    readonly property var proxyData: root.compiledPreview.proxy || ({})
    readonly property string managedMediaUrl: String(root.beforeData.media_url || root.sourceAsset.media_url || "")
    readonly property string managedThumbnailUrl: String(root.sourceAsset.thumbnail_url || "")
    readonly property string mediaAssetId: String(root.beforeData.asset_id || root.sourceAsset.id || "")
    readonly property string authorizedMediaUrl: {
        const sourceId = String(root.sourceAsset.id || "")
        const beforeId = String(root.beforeData.asset_id || "")
        if (!root.controlPlaneBridge || !root.managedMediaUrl || !root.mediaAssetId)
            return ""
        if (sourceId && beforeId && sourceId !== beforeId)
            return ""
        return String(root.controlPlaneBridge.authorizedMediaUrl(
            root.mediaAssetId, root.managedMediaUrl
        ) || "")
    }
    readonly property bool nativePlayable: root.isAuthorizedDesktopMediaUrl(
        root.authorizedMediaUrl, root.mediaAssetId
    )
    readonly property string authorizedThumbnailUrl: root.controlPlaneBridge
        && root.mediaAssetId && root.managedThumbnailUrl
        ? String(root.controlPlaneBridge.authorizedThumbnailUrl(
            root.mediaAssetId, root.managedThumbnailUrl
        ) || "") : ""
    readonly property string previewId: String(root.proxyData.preview_id || "")
    readonly property string authorizedProxyUrl: root.controlPlaneBridge
        && root.previewId && root.proxyData.media_url
        ? String(root.controlPlaneBridge.authorizedPreviewUrl(
            root.previewId, String(root.proxyData.media_url)
        ) || "") : ""
    readonly property bool proxyPlayable: root.isAuthorizedDesktopProxyUrl(
        root.authorizedProxyUrl, root.previewId
    )
    readonly property bool showingAfter: root.selectedView === "after" && root.afterAvailable
    readonly property bool currentPlayable: root.showingAfter ? root.proxyPlayable : root.nativePlayable
    readonly property bool videoFrameReady: root.currentPlayable
        && root.previewPrimed && player.position > 0
    color: Theme.panel
    radius: Theme.radiusMedium
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.role: Accessible.Pane
    Accessible.name: "Xem trước video"

    function bytesText(raw) {
        const bytes = Number(raw || 0)
        if (bytes <= 0) return "—"
        if (bytes >= 1024 * 1024 * 1024) return (bytes / 1024 / 1024 / 1024).toFixed(2) + " GB"
        if (bytes >= 1024 * 1024) return (bytes / 1024 / 1024).toFixed(1) + " MB"
        return Math.round(bytes / 1024) + " KB"
    }

    function clock(milliseconds) {
        const seconds = Math.max(0, Math.round(Number(milliseconds || 0) / 1000))
        const minutes = Math.floor(seconds / 60)
        const rest = seconds % 60
        return String(minutes).padStart(2, "0") + ":" + String(rest).padStart(2, "0")
    }

    function isAuthorizedDesktopMediaUrl(value, assetId) {
        const normalizedAsset = String(assetId || "")
        if (!/^asset_[0-9a-f]{32}$/.test(normalizedAsset)) return false
        const normalizedUrl = String(value || "")
        if (!/^file:\/\/\/(?:[A-Za-z]:\/|\/)/.test(normalizedUrl)) return false
        if (/[?#]/.test(normalizedUrl)) return false
        return !/(?:^|\/)\.\.(?:\/|$)/.test(normalizedUrl)
    }

    function isAuthorizedDesktopProxyUrl(value, previewId) {
        if (!/^studio_preview_[0-9a-f]{32}$/.test(String(previewId || ""))) return false
        const normalizedUrl = String(value || "")
        if (!/^file:\/\/\/(?:[A-Za-z]:\/|\/)/.test(normalizedUrl)) return false
        if (/[?#]/.test(normalizedUrl)) return false
        return !/(?:^|\/)\.\.(?:\/|$)/.test(normalizedUrl)
    }

    function setFullscreen(value: bool): bool {
        const nextValue = Boolean(value)
        root.fullscreenMode = nextValue
        if (nextValue) fullscreenPopup.open()
        else fullscreenPopup.close()
        return true
    }

    function toggleFullscreen(): bool {
        return root.setFullscreen(!root.fullscreenMode)
    }

    function stopPreviewPlayback(): void {
        previewPrimeTimer.stop()
        fullscreenPrimeTimer.stop()
        if (root.fullscreenMode)
            root.setFullscreen(false)
        player.stop()
    }

    onVisibleChanged: {
        // Hidden Studio pages stay instantiated in the main route stack. Stop
        // the FFmpeg worker as soon as the operator leaves Studio instead of
        // deferring native teardown until application destruction.
        if (!visible)
            root.stopPreviewPlayback()
    }

    Component.onDestruction: {
        root.stopPreviewPlayback()
        player.videoOutput = null
    }

    MediaPlayer {
        id: player
        objectName: "studioPreviewPlayer"
        source: root.showingAfter
            ? (root.proxyPlayable ? root.authorizedProxyUrl : "")
            : (root.nativePlayable ? root.authorizedMediaUrl : "")
        videoOutput: nativeVideo
        audioOutput: AudioOutput { id: previewAudio; muted: true; volume: 0.8 }
        onSourceChanged: root.previewPrimed = false
        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.LoadedMedia
                    && root.currentPlayable && !root.previewPrimed) {
                root.previewPrimed = true
                player.play()
                previewPrimeTimer.restart()
            }
        }
    }

    Timer {
        id: previewPrimeTimer
        interval: 120
        repeat: false
        onTriggered: {
            if (player.playbackState === MediaPlayer.PlayingState) {
                player.pause()
                player.position = Math.min(40, Math.max(0, player.duration - 1))
            }
        }
    }

    Timer {
        id: fullscreenPrimeTimer
        interval: 360
        repeat: false
        onTriggered: {
            root.fullscreenFrameReady = true
            if (!root.fullscreenWasPlaying
                    && player.playbackState === MediaPlayer.PlayingState)
                player.pause()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Xem trước"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }
            Item { Layout.fillWidth: true }
            StudioButton {
                id: beforeButton
                objectName: "studioPreviewBefore"
                text: "Trước"
                checkable: true
                checked: root.selectedView === "before"
                enabled: Boolean(root.beforeData.available)
                activeFocusOnTab: true
                Accessible.name: "Xem video trước xử lý"
                onClicked: root.selectedView = "before"
            }
            StudioButton {
                id: afterButton
                objectName: "studioPreviewAfter"
                text: "Sau"
                checkable: true
                checked: root.selectedView === "after"
                enabled: root.afterAvailable
                activeFocusOnTab: true
                Accessible.name: root.afterAvailable ? "Xem manifest sau xử lý" : "Bản xem sau chưa được biên dịch"
                onClicked: root.selectedView = "after"
            }
        }

        Rectangle {
            id: previewStage
            objectName: "studioPreviewStage"
            Layout.fillWidth: true
            Layout.preferredHeight: 440
            Layout.minimumHeight: 260
            Layout.maximumHeight: 440
            color: "#07090D"
            radius: 9
            clip: true
            Accessible.role: Accessible.Graphic
            Accessible.name: root.showingAfter ? "Bố cục manifest đã biên dịch" : "Video nguồn"

            Item {
                id: canvas
                anchors.centerIn: parent
                width: root.aspectRatio === "9:16"
                    ? Math.min(parent.width - 26, (parent.height - 20) * 9 / 16)
                    : root.aspectRatio === "1:1"
                        ? Math.min(parent.width - 20, parent.height - 20)
                    : Math.min(parent.width - 20, (parent.height - 26) * 16 / 9)
                height: root.aspectRatio === "9:16" ? width * 16 / 9
                    : root.aspectRatio === "1:1" ? width : width * 9 / 16

                Rectangle { anchors.fill: parent; color: Theme.base; border.width: 1; border.color: Theme.border }
                Image {
                    id: previewPoster
                    objectName: "studioPreviewPoster"
                    anchors.fill: parent
                    source: root.authorizedThumbnailUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    visible: !root.showingAfter && source.toString().length > 0
                        && !root.videoFrameReady
                }
                VideoOutput {
                    id: nativeVideo
                    anchors.fill: parent
                    visible: root.currentPlayable
                        && (root.showingAfter || root.videoFrameReady)
                    fillMode: VideoOutput.PreserveAspectCrop
                }
                Column {
                    anchors.centerIn: parent
                    width: parent.width - 24
                    spacing: 5
                    visible: !nativeVideo.visible && !previewPoster.visible
                    UiIcon { anchors.horizontalCenter: parent.horizontalCenter; name: "ui/play"; tone: Theme.textFaint; iconSize: 24 }
                    Text { width: parent.width; text: String(root.sourceAsset.file_name || "Nguồn chưa sẵn sàng"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideMiddle; horizontalAlignment: Text.AlignHCenter }
                    Text { width: parent.width; text: root.managedMediaUrl ? "Media được quản lý bởi backend" : "Không có media URL"; color: Theme.textFaint; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter }
                }

                Repeater {
                    model: root.showingAfter && !root.proxyPlayable
                        ? (root.manifest.layers || []) : []
                    delegate: Rectangle {
                        id: layerFrame
                        required property var modelData
                        readonly property var transformValue: layerFrame.modelData.transform || ({})
                        x: Number(transformValue.x || 0) * canvas.width
                        y: Number(transformValue.y || 0) * canvas.height
                        width: Math.max(18, Number(transformValue.width || 1) * canvas.width)
                        height: Math.max(12, Number(transformValue.height || 1) * canvas.height)
                        color: "transparent"
                        border.width: 1
                        border.color: Theme.accent
                        opacity: Number(transformValue.opacity === undefined ? 1 : transformValue.opacity)
                        Text {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.margins: 3
                            text: String(layerFrame.modelData.slot || layerFrame.modelData.type || "layer")
                            color: Theme.accent
                            font.pixelSize: 11
                        }
                    }
                }

                Rectangle {
                    objectName: "studioPreviewSafeArea"
                    visible: root.showingAfter && Object.keys(root.manifest.safe_area || {}).length > 0
                    anchors.fill: parent
                    anchors.leftMargin: parent.width * Number(((root.manifest.safe_area || {}).margins || {}).left || 0)
                    anchors.rightMargin: parent.width * Number(((root.manifest.safe_area || {}).margins || {}).right || 0)
                    anchors.topMargin: parent.height * Number(((root.manifest.safe_area || {}).margins || {}).top || 0)
                    anchors.bottomMargin: parent.height * Number(((root.manifest.safe_area || {}).margins || {}).bottom || 0)
                    color: "transparent"
                    border.width: 1
                    border.color: Theme.warning
                    Accessible.role: Accessible.Border
                    Accessible.name: "Vùng an toàn " + String((root.manifest.safe_area || {}).profile || "")
                }
            }
        }

        Item {
            id: proxyState
            objectName: "studioPreviewProxyState"
            property string reasonCode: root.proxyData.available ? "" : String(
                root.proxyData.reason_code
                || ((root.previewData.after || {}).reason_code || "")
            )
            Layout.fillWidth: true
            Layout.preferredHeight: reasonCode ? 18 : 0
            visible: root.selectedView === "after" && reasonCode.length > 0
            Accessible.role: Accessible.Note
            Accessible.name: "Proxy preview: " + reasonCode
            Text { anchors.fill: parent; text: proxyState.reasonCode; color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            StudioButton {
                id: backButton
                objectName: "studioPreviewBack10"
                text: ""
                iconName: "ui/rewind-10"
                enabled: root.currentPlayable && player.duration > 0
                activeFocusOnTab: true
                Accessible.name: "Lùi 10 giây"
                onClicked: player.position = Math.max(0, player.position - 10000)
            }
            StudioButton {
                id: playButton
                objectName: "studioPreviewPlay"
                text: ""
                iconName: player.playbackState === MediaPlayer.PlayingState
                    ? "ui/pause" : "ui/play"
                enabled: root.currentPlayable
                activeFocusOnTab: true
                Accessible.name: player.playbackState === MediaPlayer.PlayingState ? "Tạm dừng" : "Phát video"
                onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
            }
            Slider {
                id: seekSlider
                objectName: "studioPreviewSlider"
                Layout.fillWidth: true
                from: 0
                to: Math.max(1, player.duration)
                value: player.position
                enabled: root.currentPlayable && player.duration > 0
                activeFocusOnTab: true
                Accessible.name: "Vị trí phát video"
                onMoved: player.position = value
                background: Rectangle {
                    x: seekSlider.leftPadding
                    y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                    width: seekSlider.availableWidth
                    height: 4
                    radius: 2
                    color: Theme.elevated
                    Rectangle {
                        width: seekSlider.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: Theme.accent
                    }
                }
                handle: Rectangle {
                    x: seekSlider.leftPadding + seekSlider.visualPosition
                        * (seekSlider.availableWidth - width)
                    y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                    implicitWidth: 12
                    implicitHeight: 12
                    radius: 6
                    color: seekSlider.enabled ? Theme.accent : Theme.textFaint
                    border.width: 2
                    border.color: Theme.panel
                }
            }
            StudioButton {
                id: forwardButton
                objectName: "studioPreviewForward10"
                text: ""
                iconName: "ui/forward-10"
                enabled: root.currentPlayable && player.duration > 0
                activeFocusOnTab: true
                Accessible.name: "Tiến 10 giây"
                onClicked: player.position = Math.min(player.duration, player.position + 10000)
            }
            Text {
                objectName: "studioPreviewTimecode"
                text: root.clock(player.position) + " / " + root.clock(player.duration || Number(root.sourceAsset.duration_seconds || 0) * 1000)
                color: Theme.textFaint
                font.pixelSize: 11
                Accessible.name: text
            }
            StudioButton {
                id: volumeButton
                objectName: "studioPreviewVolume"
                text: ""
                iconName: previewAudio.muted ? "ui/volume-x" : "ui/volume-2"
                activeFocusOnTab: true
                Accessible.name: previewAudio.muted ? "Bật âm thanh xem trước" : "Tắt âm thanh xem trước"
                onClicked: previewAudio.muted = !previewAudio.muted
            }
            StudioButton {
                id: fullscreenButton
                objectName: "studioPreviewFullscreen"
                text: ""
                iconName: root.fullscreenMode ? "ui/restore" : "ui/maximize"
                activeFocusOnTab: true
                Accessible.name: root.fullscreenMode ? "Thoát xem lớn" : "Xem lớn"
                onClicked: root.toggleFullscreen()
            }
        }

        Item {
            id: previewSummary
            objectName: "studioPreviewSummary"
            Layout.fillWidth: true
            Layout.preferredHeight: 154
            Layout.minimumHeight: 140
            Layout.maximumHeight: 164
            Accessible.role: Accessible.Grouping
            Accessible.name: "Thông tin nguồn và QC"

            RowLayout {
                anchors.fill: parent
                spacing: 6

                Rectangle {
                    id: sourceCard
                    objectName: "studioPreviewSourceCard"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.elevated
                    radius: 9
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.role: Accessible.Grouping
                    Accessible.name: "Thông tin nguồn"
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        spacing: 3
                        Text { text: "Thông số video"; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 5
                            rowSpacing: 3
                            Text { text: "Tệp"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { objectName: "studioPreviewSummaryFile"; Layout.fillWidth: true; text: String(root.sourceAsset.file_name || "—"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideMiddle }
                            Text { text: "Khung"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { Layout.fillWidth: true; text: Number(root.sourceAsset.width || 0) > 0 ? Number(root.sourceAsset.width) + "×" + Number(root.sourceAsset.height) : "—"; color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                            Text { text: "FPS"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: root.sourceAsset.fps ? Number(root.sourceAsset.fps).toFixed(2) + " fps" : "—"; color: Theme.textMuted; font.pixelSize: 11 }
                            Text { text: "Codec"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { Layout.fillWidth: true; text: [root.sourceAsset.video_codec, root.sourceAsset.audio_codec].filter(Boolean).join(" / ") || "—"; color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                            Text { text: "Cỡ"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: root.bytesText(root.sourceAsset.size_bytes); color: Theme.textMuted; font.pixelSize: 11 }
                            Text { text: "Dài"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: root.clock(Number(root.sourceAsset.duration_seconds || 0) * 1000); color: Theme.textMuted; font.pixelSize: 11 }
                        }
                    }
                }

                Rectangle {
                    id: qcCard
                    objectName: "studioPreviewQcCard"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.elevated
                    radius: 9
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.role: Accessible.Grouping
                    Accessible.name: "Tóm tắt kiểm tra chất lượng"
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        spacing: 3
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Kiểm tra chất lượng"; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                            Item { Layout.fillWidth: true }
                            Text {
                                id: summaryQc
                                objectName: "studioPreviewSummaryQc"
                                text: String(root.qcData.state || "unavailable") === "available"
                                    ? "QC " + Number((root.qcData.summary || {}).passed || 0)
                                        + " / " + Number((root.qcData.summary || {}).total || 0)
                                    : "—"
                                color: String(root.qcData.status || "") === "failed" ? Theme.danger
                                    : String(root.qcData.status || "") === "warning" ? Theme.warning : Theme.success
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                        }
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 3
                            Text { text: "Tổng"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: String((root.qcData.summary || {}).total || 0); color: Theme.textMuted; font.pixelSize: 11 }
                            Text { text: "Đạt"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: String((root.qcData.summary || {}).passed || 0); color: Theme.success; font.pixelSize: 11 }
                            Text { text: "Cảnh báo"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: String((root.qcData.summary || {}).warnings || 0); color: Theme.warning; font.pixelSize: 11 }
                            Text { text: "Lỗi"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: String((root.qcData.summary || {}).failed || 0); color: Theme.danger; font.pixelSize: 11 }
                        }
                        Item { Layout.fillHeight: true }
                        RowLayout {
                            Layout.fillWidth: true
                            StudioButton {
                                id: detailsButton
                                objectName: "studioQcDetailsButton"
                                Layout.fillWidth: true
                                text: "Chi tiết kiểm tra"
                                enabled: Boolean((root.qcData.deep_link || {}).route)
                                activeFocusOnTab: true
                                Accessible.name: "Xem chi tiết kiểm tra"
                                onClicked: root.qcDetailsRequested()
                            }
                            StudioButton {
                                id: compileButton
                                primary: true
                                objectName: "studioPreviewCompileButton"
                                Layout.fillWidth: true
                                visible: !root.afterAvailable
                                text: root.previewBusy ? "Đang tạo thử…" : "Xem thử"
                                enabled: root.canCompile && !root.previewBusy
                                activeFocusOnTab: true
                                Accessible.name: "Tạo bản xem thử từ cấu hình hiện tại"
                                onClicked: root.compileRequested()
                            }
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: fullscreenPopup
        objectName: "studioPreviewFullscreenOverlay"
        parent: root.Overlay.overlay ? root.Overlay.overlay : root
        anchors.centerIn: parent
        width: parent ? parent.width : root.width
        height: parent ? parent.height : root.height
        modal: true
        focus: true
        padding: 22
        closePolicy: Popup.CloseOnEscape
        onOpened: {
            root.fullscreenMode = true
            root.fullscreenFrameReady = false
            root.fullscreenWasPlaying = player.playbackState === MediaPlayer.PlayingState
            player.videoOutput = fullscreenVideo
            if (root.currentPlayable) {
                if (!root.fullscreenWasPlaying) player.play()
                fullscreenPrimeTimer.restart()
            }
        }
        onClosed: {
            fullscreenPrimeTimer.stop()
            root.fullscreenMode = false
            player.videoOutput = nativeVideo
        }
        background: Rectangle { color: "#05070A" }
        contentItem: Item {
            Accessible.role: Accessible.Pane
            Accessible.name: "Xem trước toàn màn hình"
            Rectangle {
                anchors.fill: parent
                anchors.margins: 24
                color: "#07090D"
                radius: 12
                border.width: 1
                border.color: Theme.border
                Image {
                    id: fullscreenPoster
                    objectName: "studioPreviewFullscreenPoster"
                    anchors.fill: parent
                    anchors.margins: 2
                    source: root.authorizedThumbnailUrl
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: true
                    visible: !root.showingAfter && source.toString().length > 0
                }
                VideoOutput {
                    id: fullscreenVideo
                    anchors.fill: parent
                    anchors.margins: 2
                    fillMode: VideoOutput.PreserveAspectFit
                    visible: root.currentPlayable
                        && (root.showingAfter || root.fullscreenFrameReady)
                }
                Text {
                    anchors.centerIn: parent
                    width: parent.width - 80
                    visible: !root.currentPlayable && !fullscreenPoster.visible
                    text: String(root.sourceAsset.file_name || "Preview chưa sẵn sàng")
                    color: Theme.textMuted
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideMiddle
                }
            }
            StudioButton {
                objectName: "studioPreviewFullscreenClose"
                anchors.top: parent.top
                anchors.right: parent.right
                iconName: "ui/close"
                text: ""
                activeFocusOnTab: true
                Accessible.name: "Đóng xem trước toàn màn hình"
                onClicked: root.setFullscreen(false)
            }
        }
    }
}
