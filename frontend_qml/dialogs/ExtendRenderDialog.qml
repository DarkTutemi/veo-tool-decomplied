import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property string sourceFolder: ""
    property string outputFolder: ""
    property string filename: "merged_video"
    property string format: ".mp4"
    property string encoder: "ffmpeg"
    property bool isRendering: false
    property real progressValue: 0
    property var videoFiles: []
    property string statusText: ""
    property bool statusIsError: false
    property string sourceListingMessage: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property var pendingOverwritePayload: null
    property string trackingJobId: ""

    signal browseSourceRequested()
    signal browseOutputRequested()
    signal renderRequested(var payload)
    signal trackingStatusRequested(string trackingJobId)
    signal cancelRequested(string trackingJobId)

    function normalizeVideoItem(item) {
        if (typeof item === "string")
            return { path: item, name: root.fileName(item), checked: true }
        if (!item)
            return { path: "", name: "", checked: true }
        return {
            path: String(item.path || item.file_path || item.source || ""),
            name: String(item.name || root.fileName(item.path || item.file_path || item.source || "")),
            checked: item.checked === undefined ? true : Boolean(item.checked)
        }
    }

    function normalizeVideoFiles(items) {
        var rawItems = items || []
        var normalized = []
        for (var i = 0; i < rawItems.length; ++i)
            normalized.push(root.normalizeVideoItem(rawItems[i]))
        return normalized
    }

    function openFor(payload) {
        var data = payload || ({})
        root.sourceFolder = String(data.source_folder || data.sourceFolder || root.sourceFolder || "")
        root.outputFolder = String(data.output_folder || data.outputFolder || root.outputFolder || "")
        root.filename = String(data.filename || data.output_filename || root.filename || "merged_video")
        root.format = String(data.format || data.output_format || root.format || ".mp4")
        root.videoFiles = root.normalizeVideoFiles(data.video_files || data.videoFiles || [])
        root.encoder = String(data.encoder || "ffmpeg")
        root.progressValue = Number(data.progress || 0)
        root.statusText = ""
        root.statusIsError = false
        root.isRendering = false
        root.sourceListingMessage = ""
        root.pendingOverwritePayload = null
        root.trackingJobId = ""
        trackingTimer.stop()
        root.updateSourceListingMessage()
        root.open()
    }

    function fileName(path) {
        var value = String(path || "")
        if (!value.length)
            return ""
        var normalized = value.replace(/\\/g, "/")
        return normalized.split("/").pop()
    }

    function videoPath(item) {
        return String((item || {}).path || item || "")
    }

    function videoLabel(item) {
        var data = root.normalizeVideoItem(item)
        return String(data.name || root.fileName(data.path))
    }

    function videoCountText() {
        if (root.sourceListingMessage.length)
            return root.sourceListingMessage
        if (root.videoFiles.length <= 0)
            return (void i18n.revision, i18n.t("extend_render.no_videos", "Chưa có video"))
        return (void i18n.revision, i18n.t("extend_render.video_count", "{count} videos loaded")).replace("{count}", String(root.videoFiles.length))
    }

    function extractVideoNumbers(path) {
        var filename = root.fileName(path)
        var nameWithoutExt = filename.replace(/\.[^.]+$/, "")
        var match = nameWithoutExt.match(/^(\d+)\.(\d+)$/)
        if (match)
            return { rootIndex: Number(match[1]), position: Number(match[2]) }
        var numbers = nameWithoutExt.match(/\d+/g)
        if (numbers && numbers.length >= 2)
            return { rootIndex: Number(numbers[0]), position: Number(numbers[1]) }
        if (numbers && numbers.length === 1)
            return { rootIndex: Number(numbers[0]), position: 0 }
        return { rootIndex: 999, position: 999 }
    }

    function compareVideoItems(a, b) {
        var left = root.normalizeVideoItem(a)
        var right = root.normalizeVideoItem(b)
        var leftKey = root.extractVideoNumbers(left.path)
        var rightKey = root.extractVideoNumbers(right.path)
        if (leftKey.rootIndex !== rightKey.rootIndex)
            return leftKey.rootIndex - rightKey.rootIndex
        if (leftKey.position !== rightKey.position)
            return leftKey.position - rightKey.position
        return left.name.localeCompare(right.name, undefined, { numeric: true, sensitivity: "base" })
    }

    function sourceGroupSummary(items) {
        var groups = {}
        var keys = []
        for (var i = 0; i < items.length; ++i) {
            var data = root.normalizeVideoItem(items[i])
            var key = root.extractVideoNumbers(data.path).rootIndex
            var stringKey = String(key)
            if (groups[stringKey] === undefined) {
                groups[stringKey] = 0
                keys.push(key)
            }
            groups[stringKey] += 1
        }
        keys.sort(function(a, b) { return a - b })
        var groupInfo = []
        for (var index = 0; index < keys.length; ++index) {
            var currentKey = keys[index]
            groupInfo.push("#" + String(currentKey) + "(" + String(groups[String(currentKey)] || 0) + ")")
        }
        return {
            count: items.length,
            groupCount: keys.length,
            primaryChain: keys.length > 0 ? keys[0] : 0,
            groupInfo: groupInfo.join(", ")
        }
    }

    function updateSourceListingMessage() {
        if (root.videoFiles.length <= 0) {
            root.sourceListingMessage = root.sourceFolder.length
                ? (void i18n.revision, i18n.t("extend_render.no_videos_found", "Không tìm thấy video trong thư mục"))
                : (void i18n.revision, i18n.t("extend_render.no_videos", "Chưa có video"))
            return
        }
        var summary = root.sourceGroupSummary(root.videoFiles)
        if (summary.groupCount <= 1) {
            root.sourceListingMessage = (void i18n.revision, i18n.t("extend_render.found_videos_single_chain", "Tìm thấy {count} video (chuỗi #{chain})"))
                .replace("{count}", String(summary.count))
                .replace("{chain}", String(summary.primaryChain))
            return
        }
        root.sourceListingMessage = (void i18n.revision, i18n.t("extend_render.found_videos_multiple_chains", "{num_chains} chuỗi video: {group_info}"))
            .replace("{num_chains}", String(summary.groupCount))
            .replace("{group_info}", summary.groupInfo)
    }

    function cleanLeadingIcon(value) {
        var text = String(value || "").trim()
        text = text.replace(/^[\uD800-\uDBFF][\uDC00-\uDFFF]\uFE0F?\s*/, "")
        text = text.replace(/^[\u2600-\u27BF]\uFE0F?\s*/, "")
        return text.trim()
    }

    function moveVideo(fromIndex, delta) {
        var toIndex = fromIndex + delta
        if (fromIndex < 0 || toIndex < 0 || fromIndex >= root.videoFiles.length || toIndex >= root.videoFiles.length)
            return
        var next = root.videoFiles.slice()
        var item = next.splice(fromIndex, 1)[0]
        next.splice(toIndex, 0, item)
        root.videoFiles = next
        root.updateSourceListingMessage()
    }

    function removeVideo(index) {
        if (index < 0 || index >= root.videoFiles.length)
            return
        var next = root.videoFiles.slice()
        next.splice(index, 1)
        root.videoFiles = next
        root.updateSourceListingMessage()
    }

    function payload() {
        var paths = []
        for (var i = 0; i < root.videoFiles.length; ++i) {
            var path = root.videoPath(root.videoFiles[i])
            if (path.length)
                paths.push(path)
        }
        return {
            source_folder: root.sourceFolder,
            output_folder: root.outputFolder,
            filename: root.filename,
            format: root.format,
            encoder: root.encoder,
            overwrite: false,
            video_files: root.normalizeVideoFiles(root.videoFiles),
            videos: paths
        }
    }

    function hasOutputExistsWarning(result) {
        var response = result || ({})
        var validation = response.validation || {}
        var warnings = validation.warnings || []
        for (var i = 0; i < warnings.length; ++i) {
            var warning = warnings[i] || {}
            if (String(warning.code || "") === "output_exists")
                return true
        }
        return false
    }

    function outputFilenameWithFormat() {
        return String(root.filename || "merged_video") + String(root.format || ".mp4")
    }

    function requestRender(overwrite) {
        var request = root.payload()
        request.overwrite = Boolean(overwrite)
        root.pendingOverwritePayload = request
        root.renderRequested(request)
    }

    function autoSortVideos() {
        var next = root.normalizeVideoFiles(root.videoFiles)
        next.sort(root.compareVideoItems)
        root.videoFiles = next
        root.updateSourceListingMessage()
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || "")
        root.feedbackMessage = String(message || "")
        feedbackDialog.open()
    }

    function applyRenderResult(result) {
        var response = result || ({})
        var accepted = response.ok !== false && response.accepted !== false
        if (!accepted) {
            var message = String(response.message || response.error || response.code || (void i18n.revision, i18n.t("extend_render.render_failed", "Extend render validation failed")))
            root.statusText = message
            root.statusIsError = true
            root.isRendering = false
            root.showFeedback((void i18n.revision, i18n.t("common.error", "Error")), message)
            return
        }
        if (root.hasOutputExistsWarning(response)) {
            overwriteConfirmDialog.open()
            root.statusText = (void i18n.revision, i18n.t("extend_render.file_exists_overwrite", "Output file {filename} already exists. Overwrite?"))
                .replace("{filename}", root.outputFilenameWithFormat())
            root.statusIsError = false
            return
        }
        root.trackingJobId = String(response.tracking_job_id || "")
        root.progressValue = Number(response.progress || 0) / 100.0
        root.isRendering = root.trackingJobId.length > 0
        root.statusIsError = false
        root.statusText = String(response.message || (void i18n.revision, i18n.t("extend_render.render_started", "Render request accepted")))
        if (root.trackingJobId.length > 0)
            trackingTimer.restart()
    }

    function applyTrackingStatus(result) {
        var response = result || ({})
        if (response.ok === false) {
            var errorMessage = String(response.message || response.error || response.code || (void i18n.revision, i18n.t("extend_render.render_tracking_failed", "Could not update render status")))
            root.statusText = errorMessage
            root.statusIsError = true
            root.isRendering = false
            trackingTimer.stop()
            return
        }

        var status = String(response.status || "")
        var progress = Number(response.progress || 0)
        root.progressValue = Math.max(0, Math.min(1, progress / 100.0))
        root.statusText = String(response.status_message || response.message || root.statusText)
        root.statusIsError = Boolean(response.failed)

        if (response.complete) {
            root.isRendering = false
            trackingTimer.stop()
            root.progressValue = 1.0
            root.statusText = String(response.message || (void i18n.revision, i18n.t("extend_render.render_complete", "Extend render completed")))
            root.statusIsError = false
            return
        }
        if (response.failed) {
            root.isRendering = false
            trackingTimer.stop()
            root.showFeedback((void i18n.revision, i18n.t("common.error", "Error")), root.statusText)
            return
        }
        if (status === "cancelled") {
            root.isRendering = false
            trackingTimer.stop()
            root.statusText = String(response.message || response.status_message || (void i18n.revision, i18n.t("extend_render.cancelled", "Extend render cancelled by user.")))
            root.statusIsError = true
            return
        }
        root.isRendering = Boolean(response.active)
        if (!root.isRendering)
            trackingTimer.stop()
    }

    function applyCancelResult(result) {
        var response = result || ({})
        if (response.ok === false) {
            var message = String(response.message || response.error || response.code || (void i18n.revision, i18n.t("extend_render.cancel_failed", "Could not cancel extend render.")))
            root.showFeedback((void i18n.revision, i18n.t("common.error", "Error")), message)
            return
        }
        root.statusText = String(response.message || (void i18n.revision, i18n.t("extend_render.cancel_requested", "Extend render cancellation requested.")))
        root.statusIsError = true
        root.isRendering = false
        trackingTimer.stop()
    }

    function applySourceListingResult(result) {
        var response = result || ({})
        if (response.ok) {
            root.videoFiles = root.normalizeVideoFiles(response.items || [])
            if (!root.outputFolder.length)
                root.outputFolder = root.sourceFolder
            root.updateSourceListingMessage()
            root.statusText = String(response.message || root.sourceListingMessage)
            return
        }

        root.videoFiles = []
        root.sourceListingMessage = (void i18n.revision, i18n.t("extend_render.error_loading", "Lỗi khi tải video"))
        var message = String(
            response.message
            || response.error
            || (response.blocker && response.blocker.message)
            || (void i18n.revision, i18n.t("extend_render.source_failed", "Could not load videos from the selected folder."))
        )
        root.statusText = message
        root.showFeedback((void i18n.revision, i18n.t("common.error", "Error")), message)
    }

    header: VfDialogHeader {
        title: root.cleanLeadingIcon((void i18n.revision, i18n.t("extend_render.window_title", "Render Extend Video")))
        iconName: "video-camera"
        onCloseClicked: root.reject()
    }
    modal: true
    parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 725, 48)
    height: VfDialogMetrics.height(parent, 975, 48)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.radiusPanel
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    Timer {
        id: trackingTimer
        interval: 900
        repeat: true
        running: false
        onTriggered: {
            if (!root.trackingJobId.length) {
                trackingTimer.stop()
                return
            }
            root.trackingStatusRequested(root.trackingJobId)
        }
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(30)
        spacing: VfTheme.dp(18)

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(34)
            color: VfTheme.surfaceSoft

            Text {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(8)
                text: root.cleanLeadingIcon((void i18n.revision, i18n.t("extend_render.title_label", "Render Extend Video")))
                color: "#059669"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(22)
                font.weight: VfTheme.weightTitle
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(18)
            color: VfTheme.surfaceSoft

            Text {
                anchors.fill: parent
                text: (void i18n.revision, i18n.t("extend_render.info_text", "Ghép liền mạch với hiệu ứng crossfade 2 frame giữa các video"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        VfPanel {
            Layout.fillWidth: true
            title: (void i18n.revision, i18n.t("extend_render.encoder", "Bộ mã hóa"))
            dense: false

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(14)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(12)

                    Text {
                        Layout.preferredWidth: VfTheme.dp(96)
                        text: (void i18n.revision, i18n.t("extend_render.method", "Phương thức:"))
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                    }

                    NoScrollComboBox {
                        id: encoderCombo
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(50)
                        model: [(void i18n.revision, i18n.t("extend_render.ffmpeg_nvenc", "FFmpeg NVENC (GPU)"))]
                        enabled: false
                        opacity: 1
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("extend_render.encoder_info", "Sử dụng GPU NVIDIA để mã hóa video nhanh hơn"))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    wrapMode: Text.WordWrap
                }
            }
        }

        VfPanel {
            Layout.fillWidth: true
            title: (void i18n.revision, i18n.t("extend_render.source_folder", "Thư mục nguồn"))
            dense: false

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(10)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(10)

                    TextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(50)
                        text: root.sourceFolder
                        readOnly: true
                        selectByMouse: true
                        placeholderText: (void i18n.revision, i18n.t("extend_render.select_folder_placeholder", "Chọn thư mục chứa các đoạn video..."))
                        color: VfTheme.text
                        placeholderTextColor: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        onTextChanged: root.sourceFolder = text
                        background: Rectangle {
                            color: VfTheme.surface
                            border.color: VfTheme.borderBox
                            border.width: 1
                            radius: VfTheme.radiusControl
                        }
                    }

                    VfButton {
                        text: (void i18n.revision, i18n.t("extend_render.browse", "Duyệt..."))
                        minWidth: VfTheme.dp(124)
                        implicitHeight: VfTheme.dp(50)
                        onClicked: root.browseSourceRequested()
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: root.videoCountText()
                    color: root.videoFiles.length > 0 ? "#059669" : VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(146)
                    radius: VfTheme.radiusControl
                    color: VfTheme.surfaceSoft
                    border.color: VfTheme.borderBox
                    clip: true

                    ListView {
                        id: videoList
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(5)
                        model: root.videoFiles
                        clip: true
                        currentIndex: -1
                        reuseItems: true

                        delegate: Rectangle {
                            width: videoList.width
                            height: VfTheme.dp(30)
                            radius: VfTheme.dp(4)
                            color: ListView.isCurrentItem ? VfTheme.blueFill : videoMouse.containsMouse ? VfTheme.border : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(8)
                                anchors.rightMargin: VfTheme.dp(8)
                                spacing: VfTheme.dp(8)

                                Text {
                                    text: String(index + 1) + "."
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                }

                                 Text {
                                     Layout.fillWidth: true
                                    text: root.videoLabel(modelData)
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    elide: Text.ElideMiddle
                                }
                            }

                            MouseArea {
                                id: videoMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: videoList.currentIndex = index
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(10)

                    VfButton {
                        text: (void i18n.revision, i18n.t("extend_render.move_up", "▲ Lên"))
                        minWidth: VfTheme.dp(100)
                        enabled: videoList.currentIndex > 0
                        onClicked: root.moveVideo(videoList.currentIndex, -1)
                    }

                    VfButton {
                        text: (void i18n.revision, i18n.t("extend_render.move_down", "▼ Xuống"))
                        minWidth: VfTheme.dp(110)
                        enabled: videoList.currentIndex >= 0 && videoList.currentIndex < root.videoFiles.length - 1
                        onClicked: root.moveVideo(videoList.currentIndex, 1)
                    }

                    VfButton {
                        text: (void i18n.revision, i18n.t("extend_render.remove", "× Xóa"))
                        tone: "danger"
                        minWidth: VfTheme.dp(108)
                        enabled: videoList.currentIndex >= 0
                        onClicked: root.removeVideo(videoList.currentIndex)
                    }

                    VfButton {
                        text: (void i18n.revision, i18n.t("extend_render.auto_sort", "Tự động sắp xếp"))
                        tone: "primary"
                        minWidth: VfTheme.dp(144)
                        enabled: root.videoFiles.length > 1
                        onClicked: root.autoSortVideos()
                    }

                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("extend_render.reorder_hint", "Kéo thả hoặc dùng nút"))
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        elide: Text.ElideRight
                    }
                }
            }
        }

        VfPanel {
            Layout.fillWidth: true
            title: (void i18n.revision, i18n.t("extend_render.output_settings", "Cài đặt xuất"))
            dense: false

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(14)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(10)

                    Text {
                        Layout.preferredWidth: VfTheme.dp(66)
                        text: (void i18n.revision, i18n.t("extend_render.filename", "Tên file:"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                    }

                    TextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(50)
                        text: root.filename
                        selectByMouse: true
                        color: VfTheme.text
                        placeholderTextColor: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        onTextEdited: root.filename = text
                        background: Rectangle {
                            color: VfTheme.surface
                            border.color: VfTheme.borderBox
                            border.width: 1
                            radius: VfTheme.radiusControl
                        }
                    }

                    NoScrollComboBox {
                        id: formatCombo
                        Layout.preferredWidth: VfTheme.dp(108)
                        Layout.preferredHeight: VfTheme.dp(50)
                        model: [".mp4", ".mov", ".mkv"]
                        currentIndex: Math.max(0, model.indexOf(root.format))
                        onActivated: root.format = currentText
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(10)

                    Text {
                        Layout.preferredWidth: VfTheme.dp(66)
                        text: (void i18n.revision, i18n.t("extend_render.save_to", "Lưu vào:"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                    }

                    TextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(50)
                        text: root.outputFolder
                        readOnly: true
                        selectByMouse: true
                        placeholderText: (void i18n.revision, i18n.t("extend_render.select_output_placeholder", "Chọn thư mục xuất..."))
                        color: VfTheme.text
                        placeholderTextColor: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        onTextChanged: root.outputFolder = text
                        background: Rectangle {
                            color: VfTheme.surface
                            border.color: VfTheme.borderBox
                            border.width: 1
                            radius: VfTheme.radiusControl
                        }
                    }

                    VfButton {
                        text: (void i18n.revision, i18n.t("extend_render.browse_ellipsis", "Duyệt..."))
                        minWidth: VfTheme.dp(124)
                        implicitHeight: VfTheme.dp(50)
                        onClicked: root.browseOutputRequested()
                    }
                }
            }
        }

        ProgressBar {
            Layout.fillWidth: true
            visible: root.isRendering || root.progressValue > 0
            from: 0
            to: 1
            value: Math.max(0, Math.min(1, root.progressValue))
        }

        Text {
            Layout.fillWidth: true
            visible: root.statusText.length > 0
            text: root.statusText
            color: root.statusIsError ? VfTheme.redText : VfTheme.greenText
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            wrapMode: Text.WordWrap
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(16)

            Item { Layout.fillWidth: true }

            VfButton {
                text: (void i18n.revision, i18n.t("extend_render.cancel", "Hủy"))
                minWidth: VfTheme.dp(150)
                implicitHeight: VfTheme.dp(56)
                enabled: true
                onClicked: {
                    if (root.isRendering && root.trackingJobId.length) {
                        root.cancelRequested(root.trackingJobId)
                        return
                    }
                    root.reject()
                }
            }

            VfButton {
                text: (void i18n.revision, i18n.t("extend_render.start_render", "Bắt đầu Render"))
                tone: "primary"
                minWidth: VfTheme.dp(200)
                implicitHeight: VfTheme.dp(56)
                enabled: !root.isRendering && root.videoFiles.length > 0
                onClicked: root.requestRender(false)
            }
        }
    }

    Dialog {
        id: overwriteConfirmDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        modal: true
        width: VfDialogMetrics.width(parent, VfTheme.dp(460), VfTheme.dp(64))
        title: (void i18n.revision, i18n.t("extend_render.file_exists", "File exists"))
        standardButtons: Dialog.NoButton

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("extend_render.file_exists_overwrite", "Output file {filename} already exists. Overwrite?"))
                    .replace("{filename}", root.outputFilenameWithFormat())
                wrapMode: Text.WordWrap
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.no", "No"))
                    minWidth: VfTheme.dp(96)
                    onClicked: overwriteConfirmDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.yes", "Yes"))
                    tone: "danger"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        overwriteConfirmDialog.close()
                        root.requestRender(true)
                    }
                }
            }
        }
    }

    Dialog {
        id: feedbackDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        modal: true
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(64))
        title: root.feedbackTitle
        standardButtons: Dialog.Ok

        contentItem: Text {
            text: root.feedbackMessage
            wrapMode: Text.WordWrap
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontBody
        }
    }
}

