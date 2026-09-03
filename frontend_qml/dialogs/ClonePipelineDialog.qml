import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "ClonePipelineDialog"

    property string rawInput: ""
    property var rawLines: []
    property var candidateVideos: []
    property var selectedVideoUrls: []
    property int stepIndex: 0
    property string videoType: "all"
    property int minViews: 0
    property string statusText: ""

    signal fetchRequested(var inputs, string videoType, int minViews)
    signal acceptedVideos(var urls)

    parent: Overlay.overlay
    modal: true
    width: VfDialogMetrics.width(parent, VfTheme.dp(980), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(700), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("clone_pipeline.window_title", "Clone Pipeline"))
        iconName: "movie-camera"
        onCloseClicked: root.reject()
    }

    function openFor(payload) {
        var data = payload || ({})
        root.rawInput = String(data.raw_input || "")
        inputEdit.text = root.rawInput
        root.candidateVideos = data.candidate_videos || []
        root.selectedVideoUrls = data.selected_video_urls || []
        root.videoType = String(data.video_type || root.videoType || "all")
        root.minViews = Number(data.min_views || root.minViews || 0)
        root.stepIndex = Number(data.step_index || (root.candidateVideos.length > 0 ? 1 : 0))
        root.statusText = String(data.status_text || "")
        root.open()
    }

    function parseInput() {
        var text = inputEdit.text.trim()
        if (text.length <= 0) {
            root.statusText = (void i18n.revision, i18n.t("clone_pipeline.paste_at_least_one", "Paste at least one YouTube URL or handle."))
            return false
        }
        var parts = text.split(/\r?\n/)
        var out = []
        for (var i = 0; i < parts.length; i++) {
            var line = String(parts[i] || "").trim()
            if (line.length > 0)
                out.push(line)
        }
        if (out.length <= 0) {
            root.statusText = (void i18n.revision, i18n.t("clone_pipeline.no_valid_line", "No valid line."))
            return false
        }
        root.rawInput = text
        root.rawLines = out
        root.stepIndex = 1
        root.statusText = (void i18n.revision, i18n.t("clone_pipeline.ready_to_fetch", "Ready to fetch videos."))
        return true
    }

    function requestFetch() {
        if (root.rawLines.length <= 0 && !root.parseInput())
            return false
        root.fetchRequested(root.rawLines, root.videoType, root.minViews)
        root.statusText = (void i18n.revision, i18n.t("clone_pipeline.fetch_requested", "Fetch requested."))
        return true
    }

    function setCandidatesForVisualTest(rows) {
        root.candidateVideos = rows || []
        var selected = []
        for (var i = 0; i < root.candidateVideos.length; i++) {
            var row = root.candidateVideos[i] || ({})
            if (Boolean(row.checked))
                selected.push(String(row.url || ""))
        }
        root.selectedVideoUrls = selected
        root.stepIndex = 1
        return true
    }

    function setInputForVisualTest(value) {
        inputEdit.text = String(value || "")
        root.rawInput = inputEdit.text
        return true
    }

    function selectedCountForVisualTest() {
        return (root.selectedVideoUrls || []).length
    }

    function selectedUrlsForVisualTest() {
        return (root.selectedVideoUrls || []).join("\n")
    }

    function isSelected(url) {
        return root.selectedVideoUrls.indexOf(String(url || "")) >= 0
    }

    function setSelected(url, selected) {
        var text = String(url || "")
        if (text.length <= 0)
            return
        var next = [].concat(root.selectedVideoUrls || [])
        var pos = next.indexOf(text)
        if (selected && pos < 0)
            next.push(text)
        if (!selected && pos >= 0)
            next.splice(pos, 1)
        root.selectedVideoUrls = next
    }

    function selectAllCandidates() {
        var rows = root.candidateVideos || []
        var next = []
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i] || {}
            // CHỈ chọn link fetch được (title+duration) — bỏ link lỗi/không hợp lệ,
            // tránh "chọn tất cả" kéo cả link fail vào queue.
            if (row.fetch_failed === true || row.invalid_url === true || row.token_valid === false)
                continue
            var url = String(row.url || "")
            if (url.length > 0)
                next.push(url)
        }
        root.selectedVideoUrls = next
        return true
    }

    function clearSelection() {
        root.selectedVideoUrls = []
        return true
    }

    function goReview() {
        root.stepIndex = 2
        root.statusText = (void i18n.revision, i18n.t("clone_pipeline.selected_videos", "Selected {count} video(s).")).replace("{count}", String(root.selectedVideoUrls.length))
        return true
    }

    function confirmSelection() {
        if (root.selectedVideoUrls.length <= 0) {
            root.statusText = (void i18n.revision, i18n.t("clone_pipeline.select_at_least_one", "Select at least one video."))
            return false
        }
        root.acceptedVideos(root.selectedVideoUrls)
        root.accept()
        return true
    }

    background: Rectangle {
        radius: VfTheme.dp(12)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(16)
        spacing: VfTheme.dp(12)

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)
            StepPill { text: "1. Input"; active: root.stepIndex === 0 }
            StepPill { text: "2. Fetch"; active: root.stepIndex === 1 }
            StepPill { text: "3. Review"; active: root.stepIndex === 2 }
            Item { Layout.fillWidth: true }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.stepIndex

            ColumnLayout {
                spacing: VfTheme.dp(10)

                GroupBox {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: (void i18n.revision, i18n.t("clone_pipeline.step1_title", "Step 1: Paste YouTube URLs"))

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: VfTheme.dp(10)

                        Text {
                            Layout.fillWidth: true
                            text: (void i18n.revision, i18n.t("clone_pipeline.step1_info", "Paste video, shorts, channel URLs, or @handles. One item per line."))
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(13)
                            wrapMode: Text.WordWrap
                        }

                        TextArea {
                            id: inputEdit
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: root.rawInput
                            placeholderText: (void i18n.revision, i18n.t("clone_pipeline.input_placeholder", "https://youtube.com/watch?v=...\n@channel_handle"))
                            wrapMode: TextArea.Wrap
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(13)
                            background: Rectangle {
                                radius: VfTheme.dp(8)
                                color: VfTheme.surfaceSoft
                                border.color: inputEdit.activeFocus ? VfTheme.primary : VfTheme.borderStrong
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Item { Layout.fillWidth: true }
                            VfButton {
                                text: (void i18n.revision, i18n.t("clone_pipeline.btn_parse", "Parse"))
                                tone: "primary"
                                minWidth: VfTheme.dp(110)
                                onClicked: root.parseInput()
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: VfTheme.dp(10)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(10)

                    GroupBox {
                        Layout.preferredWidth: VfTheme.dp(330)
                        title: (void i18n.revision, i18n.t("clone_pipeline.step2_title", "Video type"))
                        RowLayout {
                            anchors.fill: parent
                            RadioButton { text: (void i18n.revision, i18n.t("clone_pipeline.mode_all", "All")); checked: root.videoType === "all"; onToggled: if (checked) root.videoType = "all" }
                            RadioButton { text: (void i18n.revision, i18n.t("clone_pipeline.mode_shorts", "Shorts")); checked: root.videoType === "shorts"; onToggled: if (checked) root.videoType = "shorts" }
                            RadioButton { text: (void i18n.revision, i18n.t("clone_pipeline.mode_long", "Long")); checked: root.videoType === "long"; onToggled: if (checked) root.videoType = "long" }
                        }
                    }

                    GroupBox {
                        Layout.fillWidth: true
                        title: (void i18n.revision, i18n.t("clone_pipeline.filter_min_views", "Min views"))
                        RowLayout {
                            anchors.fill: parent
                            RadioButton { text: "0"; checked: root.minViews === 0; onToggled: if (checked) root.minViews = 0 }
                            RadioButton { text: "1k+"; checked: root.minViews === 1000; onToggled: if (checked) root.minViews = 1000 }
                            RadioButton { text: "10k+"; checked: root.minViews === 10000; onToggled: if (checked) root.minViews = 10000 }
                            RadioButton { text: "100k+"; checked: root.minViews === 100000; onToggled: if (checked) root.minViews = 100000 }
                        }
                    }

                    VfButton {
                        text: (void i18n.revision, i18n.t("clone_pipeline.btn_fetch", "Fetch"))
                        tone: "primary"
                        minWidth: VfTheme.dp(100)
                        onClicked: root.requestFetch()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: VfTheme.dp(8)
                    color: VfTheme.surface
                    border.color: VfTheme.borderStrong
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(36)
                            spacing: 0
                            HeaderCell { Layout.preferredWidth: VfTheme.dp(54); text: "Use" }
                            HeaderCell { Layout.fillWidth: true; text: (void i18n.revision, i18n.t("clone_pipeline.col_title", "Title")) }
                            HeaderCell { Layout.preferredWidth: VfTheme.dp(96); text: (void i18n.revision, i18n.t("clone_pipeline.col_views", "Views")) }
                            HeaderCell { Layout.preferredWidth: VfTheme.dp(96); text: (void i18n.revision, i18n.t("clone_pipeline.col_duration", "Duration")) }
                            HeaderCell { Layout.preferredWidth: VfTheme.dp(112); text: (void i18n.revision, i18n.t("clone_pipeline.col_tokens", "Tokens")) }
                            HeaderCell { Layout.preferredWidth: VfTheme.dp(184); text: (void i18n.revision, i18n.t("clone_pipeline.col_url", "URL")) }
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            reuseItems: true
                            model: root.candidateVideos || []

                            delegate: Rectangle {
                                id: rowDelegate
                                width: ListView.view.width
                                height: VfTheme.dp(42)
                                // Link KHÔNG fetch được (thiếu title/duration) / không hợp lệ /
                                // token lỗi = KHÔNG cho vào queue → tô đỏ + khoá chọn.
                                readonly property bool rowBad: modelData.fetch_failed === true
                                    || modelData.invalid_url === true
                                    || modelData.token_valid === false
                                color: rowBad
                                    ? VfTheme.redFill
                                    : (index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft)
                                border.color: rowBad ? VfTheme.redBorderSoft : VfTheme.border

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0
                                    CheckBox {
                                        Layout.preferredWidth: VfTheme.dp(54)
                                        // inline modelData (luôn có trong delegate) → khỏi ref id outer.
                                        enabled: !(modelData.fetch_failed === true
                                            || modelData.invalid_url === true
                                            || modelData.token_valid === false)
                                        checked: enabled && root.isSelected(modelData.url)
                                        onToggled: root.setSelected(modelData.url, checked)
                                    }
                                    BodyCell { Layout.fillWidth: true; text: String(modelData.title || "") }
                                    BodyCell { Layout.preferredWidth: VfTheme.dp(96); text: String(modelData.views || 0) }
                                    BodyCell { Layout.preferredWidth: VfTheme.dp(96); text: String(modelData.duration || "") }
                                    BodyCell {
                                        Layout.preferredWidth: VfTheme.dp(112)
                                        text: String(modelData.token_status || modelData.token_count || "")
                                        colorOverride: modelData.token_valid === false ? "#DC2626" : ""
                                    }
                                    BodyCell { Layout.preferredWidth: VfTheme.dp(184); text: String(modelData.url || "") }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    VfButton { text: (void i18n.revision, i18n.t("common.select_all", "Select all")); onClicked: root.selectAllCandidates() }
                    VfButton { text: (void i18n.revision, i18n.t("common.deselect_all", "Deselect all")); onClicked: root.clearSelection() }
                    Item { Layout.fillWidth: true }
                    VfButton { text: (void i18n.revision, i18n.t("clone_pipeline.btn_add_selected", "Review selected")); tone: "primary"; onClicked: root.goReview() }
                }
            }

            ColumnLayout {
                spacing: VfTheme.dp(16)
                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("clone_pipeline.selected_videos", "Selected {count} video(s).")).replace("{count}", String(root.selectedVideoUrls.length))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(18)
                    font.weight: Font.Bold
                }

                // ── Advisory: NÊN / KHÔNG NÊN clone dạng video nào (cảnh báo tốn tiền) ──
                // Clone = từ VIDEO gốc → dựng lại video tương tự. Video kể chuyện/ảnh tĩnh
                // chạy theo audio KHÔNG clone được mà đốt token (video càng dài càng đắt).
                Rectangle {
                    Layout.fillWidth: true
                    radius: VfTheme.radiusControl
                    color: VfTheme.amberFill
                    border.color: VfTheme.amberBorderSoft
                    border.width: 1
                    implicitHeight: cloneAdvisoryCol.implicitHeight + VfTheme.dp(24)

                    ColumnLayout {
                        id: cloneAdvisoryCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: VfTheme.dp(14)
                        anchors.rightMargin: VfTheme.dp(14)
                        spacing: VfTheme.dp(3)

                        Text {
                            Layout.fillWidth: true
                            text: (void i18n.revision, i18n.t("clone_pipeline.advisory_title", "⚠️ Clone phù hợp với video nào?"))
                            color: VfTheme.amberText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(14)
                            font.weight: Font.Bold
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            Layout.fillWidth: true
                            text: (void i18n.revision, i18n.t("clone_pipeline.advisory_body",
                                "Clone = phân tích VIDEO gốc → dựng lại video TƯƠNG TỰ.\n" +
                                "✅ Nên clone: video NGẮN, chủ đề linh hoạt, hình ảnh rõ ràng, dễ bắt chước.\n" +
                                "❌ Không nên: video kể chuyện / ảnh tĩnh chạy theo audio — clone không ra kết quả tốt mà còn TỐN CHI PHÍ LỚN (video càng dài càng đốt token).\n" +
                                "💡 Dạng kể chuyện: hãy dùng tab Transcript/Audio thay vì Clone."))
                            color: VfTheme.amberText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            lineHeight: 1.3
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: VfTheme.radiusControl
                    color: VfTheme.surface
                    border.color: VfTheme.borderBox
                    border.width: 1
                    clip: true

                    ScrollView {
                        id: urlsScroll
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(8)
                        contentWidth: availableWidth
                        contentHeight: urlsArea.implicitHeight
                        clip: true
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        TextArea {
                            id: urlsArea
                            width: urlsScroll.availableWidth
                            readOnly: true
                            text: root.selectedUrlsForVisualTest()
                            wrapMode: TextArea.WrapAnywhere
                            color: VfTheme.text
                            placeholderTextColor: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(13)
                            background: Item {}
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }
                    VfButton {
                        text: (void i18n.revision, i18n.t("clone_pipeline.btn_add_to_queue", "Add to queue"))
                        tone: "success"
                        minWidth: VfTheme.dp(140)
                        onClicked: root.confirmSelection()
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: root.statusText
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                elide: Text.ElideRight
            }
            VfButton {
                text: (void i18n.revision, i18n.t("clone_pipeline.btn_back", "Back"))
                enabled: root.stepIndex > 0
                onClicked: root.stepIndex = Math.max(0, root.stepIndex - 1)
            }
            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                onClicked: root.reject()
            }
        }
    }

    component StepPill: Rectangle {
        property string text: ""
        property bool active: false
        Layout.preferredWidth: VfTheme.dp(120)
        Layout.preferredHeight: VfTheme.dp(30)
        radius: VfTheme.dp(15)
        color: active ? VfTheme.blueFill : VfTheme.surfaceSoft
        border.color: active ? VfTheme.primary : VfTheme.borderStrong
        Text {
            anchors.centerIn: parent
            text: parent.text
            color: parent.active ? VfTheme.primary : VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
            font.weight: Font.Bold
        }
    }

    component HeaderCell: Text {
        color: VfTheme.textMuted
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(11)
        font.weight: Font.Bold
        verticalAlignment: Text.AlignVCenter
        leftPadding: VfTheme.dp(8)
        elide: Text.ElideRight
    }

    component BodyCell: Text {
        property var colorOverride: null
        color: colorOverride !== null && colorOverride !== undefined && colorOverride.toString().length > 0
            ? colorOverride
            : VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(11)
        verticalAlignment: Text.AlignVCenter
        leftPadding: VfTheme.dp(8)
        elide: Text.ElideRight
    }
}
