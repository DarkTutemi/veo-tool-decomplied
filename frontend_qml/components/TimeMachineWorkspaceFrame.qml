pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"
import "MediaSourceResolver.js" as MediaSourceResolver

Item {
    id: frame
    objectName: "timeMachineWorkspaceFrame"

    property var controller: null
    property string actionError: ""
    property bool draftPrepared: false
    property int inputImageCount: 0
    property bool pairsExpanded: true
    property string previewPath: ""
    property string previewTitle: ""
    property string previewStatus: ""
    property int viewPage: 0
    property string followedJobId: ""

    signal enqueueRequested()
    signal editStageRequested(int stageIdx, string name, string visibleDescription)
    signal editCellRequested(string viewId, string viewLabel, int stageIdx, string prompt, bool locked)
    signal editMotionRequested(string motionKey, string viewLabel, int fromStage, int toStage, string prompt)
    signal openFolderRequested(string folder)

    readonly property var selectedJob: controller ? controller.selectedJob : ({})
    readonly property var queueStats: controller ? controller.queueStats : ({})
    readonly property var config: controller ? (controller.config || ({})) : ({})
    readonly property bool hasJob: String(selectedJob.id || "").length > 0
    readonly property bool selectedFailed:
        String(selectedJob.status || "") === "failed"
    readonly property bool pipelineBusy:
        Boolean(controller && controller.draftBusy)
        || String(selectedJob.status || "") === "running"
    readonly property bool runtimeActive:
        pipelineBusy || Number(queueStats.running || 0) > 0
    readonly property int pipelineProgress:
        Math.max(0, Math.min(100, Number(selectedJob.progress || 0)))
    readonly property var liveChain: selectedJob.live_chain || ({})
    readonly property string pipelineKind:
        String(selectedJob.pipeline_kind || "")
    readonly property bool liveChainEnabled:
        pipelineKind === "live_window"
        || (pipelineKind.length === 0
            && Boolean(selectedJob.live_chain_enabled))
    readonly property bool constructionEnabled:
        pipelineKind === "construction"
    readonly property bool imagesOutput:
        String(selectedJob.output_kind || "") === "images_narration"
    readonly property bool pairPanelEnabled:
        hasPlan && !imagesOutput
        && (liveChainEnabled || constructionEnabled)
    readonly property int liveChainProgress:
        Math.max(0, Math.min(100, Number(liveChain.overall_percent || 0)))
    readonly property int displayProgress:
        pairPanelEnabled && currentProcessStep() === 3
        ? liveChainProgress : pipelineProgress
    readonly property var processLabels: {
        var projected = selectedJob.pipeline_step_labels
        if (projected && projected.length === 7)
            return projected
        if (liveChainEnabled)
            return ["Timeline", "Storyboard", "Seed START–END", "Live Chain",
                    "Picture-lock", "Voice + Graphics", "Hoàn tất"]
        if (constructionEnabled)
            return ["Timeline", "Storyboard", "Peel START–END",
                    "I2V Start–End", "Picture-lock", "Voice + Graphics",
                    "Hoàn tất"]
        return ["Đầu vào & Timeline", "Storyboard", "Keyframe", "I2V",
                "Picture-lock", "Voice + Graphics", "Hoàn tất"]
    }
    readonly property bool postproductionActive:
        hasJob && currentProcessStep() >= 4
    readonly property string pipelineMessage:
        String(selectedJob.message || "Đang chuẩn bị workspace")
    readonly property bool hasPlan: controller
                                    && controller.chapterModel.count > 0
    readonly property int stageCount: hasPlan ? controller.stageModel.count : 5
    readonly property int viewCount: hasPlan
                                     ? controller.viewModel.count
                                     : Math.max(
                                           1,
                                           hasJob
                                           ? Number(selectedJob.input_count || 0)
                                           : inputImageCount)
    readonly property int plannedClipCount: hasPlan
                                            ? controller.motionModel.count
                                            : viewCount
                                              * Math.max(0, stageCount - 1)
    readonly property int uniqueStateCount: Math.max(
        0,
        Number(selectedJob.unique_state_count
               || selectedJob.scene_total
               || 0))
    readonly property bool portraitFrames:
        String(config.aspect_ratio || "") === "9:16"
        || String(config.aspect_ratio || "").indexOf("PORTRAIT") >= 0
    readonly property real rowHeight: VfTheme.dp(72)
    readonly property real labelWidth: VfTheme.dp(118)
    readonly property real minimumStageWidth: portraitFrames
                                              ? VfTheme.dp(104)
                                              : VfTheme.dp(118)
    readonly property int visibleStageCapacity:
        Math.max(1, Math.min(7, stageCount))
    readonly property int viewPageSize: 4
    readonly property int viewPageCount:
        Math.max(1, Math.ceil(viewCount / viewPageSize))
    readonly property int paddedViewCount:
        viewPageCount * viewPageSize
    readonly property int firstVisibleView:
        viewPage * viewPageSize + 1
    readonly property int lastVisibleView:
        Math.min(viewCount, (viewPage + 1) * viewPageSize)
    readonly property real stageWidth: Math.max(
        minimumStageWidth,
        (canvasPanel.width - labelWidth - VfTheme.dp(10))
        / visibleStageCapacity)
    readonly property real headerHeight: VfTheme.dp(31)
    readonly property real pipelineNaturalHeight:
        VfTheme.dp(120)
        + viewPageSize * rowHeight
        + (pairsExpanded ? VfTheme.dp(58) : VfTheme.dp(27))
    readonly property bool queueWide: width >= VfTheme.dp(1040)
    readonly property real queueRowHeight: VfTheme.dp(52)
    readonly property real queueProgressColumnWidth: queueWide
                                                      ? VfTheme.dp(220)
                                                      : VfTheme.dp(160)
    readonly property real queueFlexibleColumnsWidth: Math.max(
        VfTheme.dp(600),
        width - queueProgressColumnWidth - VfTheme.dp(103)
    )
    readonly property real queueJobColumnWidth:
        queueFlexibleColumnsWidth * 0.27
    readonly property real queueInputColumnWidth:
        queueFlexibleColumnsWidth * 0.16
    readonly property real queueScaleColumnWidth:
        queueFlexibleColumnsWidth * 0.15
    readonly property real queueImageColumnWidth:
        queueFlexibleColumnsWidth * 0.15
    readonly property real queueVideoColumnWidth:
        queueFlexibleColumnsWidth * 0.27
    readonly property int visibleQueueRows:
        Math.min(3, Number(queueStats.total || 0))
    readonly property real queueRowsHeight:
        visibleQueueRows > 0
        ? visibleQueueRows * queueRowHeight
          + Math.max(0, visibleQueueRows - 1) * VfTheme.dp(4)
        : VfTheme.dp(42)

    function cameraFamilyLabel(value) {
        var family = String(value || "")
        if (family === "aerial_orbit")
            return "FLYCAM ORBIT"
        if (family === "ground_orbit")
            return "ORBIT"
        if (family === "slow_arc")
            return "SLOW ARC"
        if (family === "pullback_reveal")
            return "PULL-BACK"
        return "CAMERA VIEW"
    }

    function queueAudioAndRevealLabel(row) {
        var label = Boolean(row.source_audio)
                    ? "Audio riêng"
                    : Boolean(row.source_srt)
                      ? "SRT → Gemini · "
                        + String(row.language_label || "Tự động")
                      : Boolean(row.narration_enabled)
                        ? "Gemini TTS"
                          + (String(row.tts_voice || "").length > 0
                             ? " · " + String(row.tts_voice) : "")
                        : "Không dẫn truyện"
        var nativeMode = String(row.native_audio_mode || "auto")
        label += nativeMode === "off"
                 ? " · tắt âm Veo"
                 : nativeMode === "half"
                   ? " · âm Veo 50%"
                   : " · auto duck âm Veo"
        if (Number(row.final_reveal_count || 0) > 0)
            label += " · Final "
                     + cameraFamilyLabel(row.final_reveal_camera)
        return label
    }
    readonly property real queueNaturalHeight:
        VfTheme.dp(98) + queueRowsHeight
    readonly property real queueFixedHeight: Math.min(
        VfTheme.dp(190),
        Math.max(VfTheme.dp(148), height * 0.27)
    )

    implicitHeight: VfTheme.dp(500)

    component QueueDivider: Rectangle {
        Layout.preferredWidth: 1
        Layout.fillHeight: true
        color: VfTheme.border
    }

    onViewCountChanged: {
        if (viewPage >= viewPageCount)
            viewPage = Math.max(0, viewPageCount - 1)
    }
    onSelectedJobChanged: Qt.callLater(frame.followActiveViewPage)
    onPipelineBusyChanged: {
        if (pipelineBusy)
            Qt.callLater(frame.followActiveViewPage)
    }

    function imageNumber(row) {
        var value = String(Number(row) + 1)
        return value.length < 2 ? "0" + value : value
    }

    function skeletonViewName(row) {
        return inputImageCount > 0
                ? "Ảnh " + frame.imageNumber(row)
                : "Ảnh mốc do AI tạo"
    }

    function setViewPage(page) {
        viewPage = Math.max(0, Math.min(viewPageCount - 1, Number(page)))
    }

    function followActiveViewPage() {
        var jobId = String(selectedJob.id || "")
        var changedJob = jobId !== followedJobId
        if (changedJob) {
            followedJobId = jobId
            viewPage = 0
        }
        if (!pipelineBusy)
            return
        var activeIndex = Number(selectedJob.active_view_index)
        if (isFinite(activeIndex) && activeIndex >= 0)
            chapterBoard.scrollToChapter(activeIndex)
    }

    function stageName(stage) {
        if (stage === 0)
            return "S0 · KHỞI ĐIỂM"
        if (stage === stageCount - 1)
            return "S" + stage + " · ẢNH MỐC"
        return "S" + stage
    }

    function queueStatusLabel(status) {
        var value = String(status || "").toLowerCase()
        if (value === "running")
            return "ĐANG CHẠY"
        if (value === "queued")
            return "ĐANG CHỜ"
        if (value === "complete")
            return "HOÀN THÀNH"
        if (value === "failed")
            return "CÓ LỖI"
        if (value === "paused")
            return "TẠM DỪNG"
        return value.length > 0 ? value.toUpperCase() : "BẢN NHÁP"
    }

    function queueInputSummary(row) {
        var count = Number(row.input_count || 0)
        var names = String(row.input_names || "")
        if (count <= 0)
            return "Ý tưởng thuần AI · không cần ảnh đầu vào"
        return count + " ảnh mốc" + (names.length > 0 ? " · " + names : "")
    }

    function queuePlanSummary(row) {
        return Number(row.chapter_count || row.view_count || 0)
                + " phân đoạn · "
                + Number(row.unique_state_count
                         || row.keyframe_count
                         || row.stage_count
                         || 0)
                + " mốc · "
                + Number(row.clip_count || 0) + " clip · "
                + String(row.aspect_label || "Auto") + " · "
                + String(row.quality_label || "Auto")
    }

    function queueModelSummary(row) {
        return "Ảnh: " + String(row.image_model_label || "Auto")
                + " · FL: " + String(row.video_model_label || "Auto Start–End")
    }

    function queueNarrationSummary(row) {
        var narration = Boolean(row.narration_enabled)
                ? "Dẫn truyện: "
                  + String(row.tts_provider || row.tts_voice || "Đã bật")
                  + " · " + String(row.language_label || "Tự động")
                : "Không dẫn truyện"
        var market = String(row.market_label || "")
        var folder = String(row.output_folder || "")
        return narration
                + (market.length > 0 ? " · Thị trường: " + market : "")
                + (folder.length > 0 ? " · Xuất: " + folder : "")
    }

    function currentProcessStep() {
        var projected = Number(selectedJob.pipeline_step)
        if (isFinite(projected) && projected >= 0 && projected <= 6)
            return Math.round(projected)
        var phase = String(selectedJob.phase || "")
        if (phase === "complete")
            return 6
        if (phase === "assembling" || phase === "muxing"
                || phase === "merging")
            return 6
        if (phase === "rendering" || phase === "still_slideshow"
                || phase === "live_chain"
                || phase === "live_chain_extract"
                || phase === "live_chain_upload"
                || phase === "live_chain_end")
            return 3
        if (phase === "narrating" || phase === "tts" || phase === "voice")
            return 4
        if (phase === "motion_prompting" || phase === "editing_timeline"
                || phase === "dispatching" || phase === "regressed"
                || phase === "regenerated" || phase === "draft_ready"
                || phase === "prepared")
            return 3
        if (phase === "regressing" || phase === "keyframes"
                || phase === "keyframe_generation")
            return 2
        if (phase === "planned" || phase === "plan_ready"
                || phase === "storyboard" || phase === "macro_planning"
                || phase === "chapter_expansion")
            return 1
        if (phase === "analyzing" || phase === "session_ready"
                || phase === "asset_owner" || phase === "anchor_prompt"
                || phase === "anchor_generation" || phase === "anchor_ready"
                || phase === "input_ready" || phase === "vision_ready"
                || phase === "anchor_brief_ready"
                || phase === "source_media"
                || phase === "source_media_ready"
                || phase === "timeline_classification"
                || phase === "story_architect"
                || phase === "story_critic"
                || phase === "story_blueprint_locked"
                || phase === "timeline_directing"
                || phase === "timeline_audit"
                || phase === "timeline_locked")
            return 0
        return draftPrepared ? 1 : 0
    }

    function phaseLabel() {
        var projected = String(selectedJob.phase_label || "")
        if (projected.length > 0)
            return projected
        var phase = String(selectedJob.phase || "")
        if (phase === "session_ready")
            return "ĐANG TẠO SESSION"
        if (phase === "asset_owner")
            return "ĐANG KHÓA TÀI KHOẢN TÀI NGUYÊN"
        if (phase === "source_media")
            return "ĐANG PHÂN TÍCH AUDIO / SRT"
        if (phase === "source_media_ready")
            return "ĐÃ KHÓA TIMELINE AUDIO / SRT"
        if (phase === "timeline_classification")
            return "ĐANG PHÂN LOẠI DÒNG THỜI GIAN"
        if (phase === "timeline_directing")
            return "LLM ĐANG ĐẠO DIỄN CÁC MỐC THỜI GIAN"
        if (phase === "timeline_audit")
            return "LLM ĐANG KIỂM TRA NIÊN ĐẠI & NHÂN QUẢ"
        if (phase === "timeline_locked")
            return "ĐÃ KHÓA TIMELINE TRI THỨC MÔ HÌNH"
        if (phase === "anchor_prompt")
            return "LLM ĐANG VIẾT ẢNH MỐC"
        if (phase === "anchor_generation")
            return "ĐANG SINH & KIỂM ĐỊNH ẢNH MỐC"
        if (phase === "vision_ready" || phase === "analyzing")
            return "LLM ĐANG NHẬN DIỆN ĐẦU VÀO"
        if (phase === "planned" || phase === "plan_ready"
                || phase === "storyboard")
            return "ĐANG LẬP STORYBOARD"
        if (phase === "macro_planning")
            return "ĐANG CHIA MACRO TIMELINE THÀNH CHAPTER"
        if (phase === "chapter_expansion")
            return "ĐANG MỞ RỘNG CHAPTER THEO MỐC"
        if (phase === "regressing" || phase === "keyframes"
                || phase === "keyframe_generation")
            return "ĐANG TẠO KEYFRAME THEO THỜI GIAN"
        if (phase === "motion_prompting")
            return "LLM ĐANG VIẾT PROMPT CHUYỂN ĐỘNG"
        if (phase === "editing_timeline")
            return "LLM ĐANG SẮP TIMELINE TỔNG"
        if (phase === "dispatching")
            return "ĐANG PHÂN PHỐI JOB RENDER"
        if (phase === "still_slideshow")
            return "ĐANG DỰNG SLIDESHOW TỪ ẢNH MỐC"
        if (phase === "rendering")
            return "JOBSTORE ĐANG RENDER CHILD JOB"
        if (phase === "live_chain" || phase === "live_chain_extract")
            return "ĐANG LẤY LAST FRAME LÀM START"
        if (phase === "live_chain_upload")
            return "ĐANG UPLOAD LIVE START"
        if (phase === "live_chain_end")
            return "ĐANG TẠO LIVE END KẾ TIẾP"
        if (phase === "picture_lock")
            return "PICTURE-LOCK ĐÃ KHÓA"
        if (phase === "post_analysis")
            return "AI ĐANG XEM VIDEO HOÀN CHỈNH"
        if (phase === "voice" || phase === "narrating" || phase === "tts")
            return "ĐANG TẠO DẪN TRUYỆN"
        if (phase === "graphics")
            return "ĐANG THIẾT KẾ ĐỒ HỌA THỜI GIAN"
        if (phase === "graphics_render")
            return "ĐANG RENDER ĐỒ HỌA THỜI GIAN"
        if (phase === "publish_kit")
            return "ĐANG TẠO PUBLIC KIT"
        if (phase === "merging" || phase === "muxing"
                || phase === "assembling")
            return "ĐANG GHÉP VIDEO HOÀN CHỈNH"
        return "AI ĐANG CHUẨN BỊ WORKSPACE"
    }

    function currentStepLabel() {
        var projected = String(selectedJob.pipeline_step_label || "")
        return projected.length > 0 ? projected : phaseLabel()
    }

    function checkpointDone(name) {
        var completed = selectedJob.causal_completed || []
        for (var i = 0; i < completed.length; ++i) {
            if (String(completed[i]) === String(name))
                return true
        }
        return false
    }

    function checkpointLabel(name) {
        if (name === "picture_lock")
            return "Picture-lock"
        if (name === "narration_plan")
            return "Lời dẫn"
        if (name === "graphics_master")
            return "Graphics"
        if (name === "audio_master")
            return "Audio master"
        return String(name || "")
    }

    function stateColor(state) {
        if (state === "ready" || state === "off")
            return VfTheme.greenText
        if (state === "working")
            return VfTheme.amberText
        if (state === "failed")
            return VfTheme.redText
        return VfTheme.textSubtle
    }

    function openPreview(path, title, status) {
        if (!String(path || "").length)
            return
        frame.previewPath = String(path)
        frame.previewTitle = String(title || "Xem nhanh keyframe")
        frame.previewStatus = String(status || "")
        quickPreview.open()
    }

    function selectPreview(path, title, status) {
        if (!String(path || "").length)
            return
        frame.previewPath = String(path)
        frame.previewTitle = String(title || "Xem nhanh keyframe")
        frame.previewStatus = String(status || "")
    }

    function showResult(result) {
        frame.actionError = result && result.ok
                ? ""
                : String((result || {}).message || "Không thể thực hiện thao tác.")
    }

    Rectangle {
        id: pipelineSection
        objectName: "timeMachinePipeline"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: queueSection.top
        anchors.bottomMargin: VfTheme.dp(8)
        radius: VfTheme.radiusPanel
        color: VfTheme.surface
        border.color: VfTheme.violetBorderSoft
        clip: true

        Rectangle {
            id: liveSweep
            visible: frame.runtimeActive
            z: 20
            y: 0
            width: Math.max(VfTheme.dp(90), pipelineSection.width * 0.16)
            height: Math.max(1, VfTheme.dp(2))
            radius: height / 2
            color: VfTheme.primary
            opacity: 0.72

            NumberAnimation on x {
                running: liveSweep.visible && VfTheme.motion
                loops: Animation.Infinite
                from: -liveSweep.width
                to: pipelineSection.width
                duration: 1900
                easing.type: Easing.InOutSine
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(7)
            spacing: VfTheme.dp(5)

            RowLayout {
                objectName: "timeMachineProcessRibbon"
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(30)
                spacing: VfTheme.dp(6)

                VfAppIcon {
                    name: "clockwise-arrows"
                    size: VfTheme.dp(18)
                    color: VfTheme.violetText
                }

                Text {
                    text: {
                        var pipeline = String(frame.selectedJob.pipeline_label || "")
                        var output = String(frame.selectedJob.output_label || "")
                        if (pipeline.length > 0 && frame.imagesOutput)
                            return pipeline + " · " + (output || "ẢNH")
                        if (pipeline.length > 0)
                            return pipeline
                        return "TRẠNG THÁI LÀM VIỆC REALTIME"
                    }
                    color: VfTheme.violetText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: Font.Bold
                }

                Rectangle {
                    Layout.preferredWidth: stateRow.implicitWidth + VfTheme.dp(14)
                    Layout.preferredHeight: VfTheme.dp(20)
                    radius: height / 2
                    color: frame.selectedFailed ? VfTheme.redFill
                          : frame.pipelineBusy ? VfTheme.blueFill
                          : frame.hasPlan ? VfTheme.greenFill
                          : frame.draftPrepared ? VfTheme.violetFill
                          : VfTheme.surfaceSoft
                    border.color: frame.selectedFailed ? VfTheme.redBorder
                                  : frame.pipelineBusy
                                    ? VfTheme.blueBorderSoft
                                  : frame.hasPlan ? VfTheme.greenBorder
                                  : frame.draftPrepared
                                    ? VfTheme.violetBorderSoft : VfTheme.border
                    Row {
                        id: stateRow
                        anchors.centerIn: parent
                        spacing: VfTheme.dp(4)

                        Item {
                            visible: frame.runtimeActive
                            width: visible ? VfTheme.dp(9) : 0
                            height: VfTheme.dp(9)

                            Rectangle {
                                anchors.centerIn: parent
                                width: VfTheme.dp(7)
                                height: width
                                radius: width / 2
                                color: "transparent"
                                border.color: VfTheme.primary
                                border.width: Math.max(1, VfTheme.dp(1))

                                SequentialAnimation on scale {
                                    running: frame.runtimeActive && VfTheme.motion
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        from: 0.7
                                        to: 1.8
                                        duration: 950
                                        easing.type: Easing.OutCubic
                                    }
                                    PauseAnimation { duration: 80 }
                                }
                                SequentialAnimation on opacity {
                                    running: frame.runtimeActive && VfTheme.motion
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        from: 0.75
                                        to: 0.0
                                        duration: 950
                                    }
                                    PauseAnimation { duration: 80 }
                                }
                            }
                            Rectangle {
                                anchors.centerIn: parent
                                width: VfTheme.dp(5)
                                height: width
                                radius: width / 2
                                color: VfTheme.primary
                            }
                        }

                        Text {
                            id: stateText
                            text: frame.selectedFailed
                                  ? "CÓ LỖI · XEM CHI TIẾT"
                                  : frame.pipelineBusy
                                  ? frame.pairPanelEnabled
                                    && frame.currentProcessStep() === 3
                                    ? Number(frame.liveChain.completed_clips || 0)
                                      + " / "
                                      + Number(frame.liveChain.total_clips || 0)
                                      + " CLIP · " + frame.displayProgress + "%"
                                    : frame.displayProgress
                                      + "% · "
                                      + frame.currentStepLabel().toUpperCase()
                                  : frame.hasPlan ? "ĐANG CẬP NHẬT REALTIME"
                                  : frame.draftPrepared ? "BẢN PHÁC THẢO"
                                  : "CHỜ PHÂN TÍCH"
                            color: frame.selectedFailed ? VfTheme.redText
                                   : frame.pipelineBusy ? VfTheme.blueText
                                   : frame.hasPlan ? VfTheme.greenText
                                   : frame.draftPrepared
                                     ? VfTheme.violetText : VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(8)
                            font.weight: Font.Bold
                        }
                    }
                }

                Repeater {
                    model: frame.processLabels
                    delegate: RowLayout {
                        id: processStep
                        required property int index
                        required property string modelData
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(3)

                        Rectangle {
                            Layout.preferredWidth: VfTheme.dp(18)
                            Layout.preferredHeight: width
                            radius: width / 2
                            color: processStep.index === frame.currentProcessStep()
                                   ? VfTheme.primary : VfTheme.surfaceSoft
                            border.color: processStep.index
                                          <= frame.currentProcessStep()
                                          ? VfTheme.primary : VfTheme.border
                            Text {
                                anchors.centerIn: parent
                                text: processStep.index + 1
                                color: processStep.index
                                       === frame.currentProcessStep()
                                       ? "white" : VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                font.weight: Font.Bold
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: processStep.modelData
                            color: processStep.index === frame.currentProcessStep()
                                   ? VfTheme.blueText : VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(8)
                            font.weight: processStep.index
                                         === frame.currentProcessStep()
                                         ? Font.Bold : Font.Normal
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: VfTheme.dp(7)

                Rectangle {
                    id: canvasPanel
                    objectName: "timeMachineChapterCanvas"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: VfTheme.dp(8)
                    color: VfTheme.surface
                    border.color: VfTheme.border
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(5)
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: frame.pipelineBusy
                                                    ? VfTheme.dp(31)
                                                    : VfTheme.dp(25)
                            spacing: VfTheme.dp(5)

                            Repeater {
                                model: (frame.liveChainEnabled
                                        ? [
                                            frame.viewCount + " chapter",
                                            Number(frame.liveChain.total_clips || 0)
                                            + " clip liên tục",
                                            Number(frame.liveChain.completed_clips || 0)
                                            + " đã hoàn thành",
                                            "Đang xử lý clip "
                                            + Number(frame.liveChain.current_clip_number || 0)
                                          ]
                                        : frame.imagesOutput
                                          ? [
                                              frame.viewCount + " chương",
                                              frame.uniqueStateCount + " ảnh mốc",
                                              "ẢNH"
                                            ]
                                        : frame.constructionEnabled
                                          ? [
                                              frame.viewCount + " chương",
                                              frame.uniqueStateCount + " mốc peel",
                                              frame.plannedClipCount
                                              + " clip START–END"
                                            ]
                                          : [
                                            frame.viewCount + " phân đoạn",
                                            frame.uniqueStateCount + " mốc",
                                            frame.plannedClipCount + " clip"
                                          ]).concat(
                                    frame.hasPlan
                                    ? [
                                        "CAUSAL · "
                                        + Number(
                                            frame.selectedJob
                                                 .causal_dependency_count || 0),
                                        Boolean(
                                            frame.selectedJob
                                                 .final_reveal_enabled)
                                        ? "FINAL · "
                                          + frame.cameraFamilyLabel(
                                              frame.selectedJob
                                                   .final_reveal_camera)
                                        : "FINAL · TẮT"
                                      ]
                                    : [])
                                delegate: Rectangle {
                                    id: summaryChip
                                    required property string modelData
                                    Layout.preferredWidth:
                                        summaryChipText.implicitWidth + VfTheme.dp(13)
                                    Layout.preferredHeight: VfTheme.dp(19)
                                    radius: height / 2
                                    color: VfTheme.blueFill
                                    border.color: VfTheme.blueBorderSoft
                                    Text {
                                        id: summaryChipText
                                        anchors.centerIn: parent
                                        text: summaryChip.modelData
                                        color: VfTheme.blueText
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(8)
                                        font.weight: Font.Bold
                                    }
                                }
                            }
                            Item {
                                Layout.fillWidth: !frame.pipelineBusy
                            }

                            BusyIndicator {
                                visible: frame.pipelineBusy
                                         && !frame.selectedFailed
                                running: visible
                                Layout.preferredWidth: VfTheme.dp(19)
                                Layout.preferredHeight: width
                            }

                            Text {
                                visible: frame.pipelineBusy
                                         && !frame.selectedFailed
                                text: frame.phaseLabel()
                                color: VfTheme.blueText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(9)
                                font.weight: Font.Bold
                            }

                            Text {
                                Layout.fillWidth: frame.pipelineBusy
                                text: frame.selectedFailed
                                      ? "Đã dừng an toàn · bấm job để xem thông báo tập trung"
                                      : frame.pipelineBusy
                                      ? frame.pipelineMessage
                                      : frame.hasPlan
                                      ? "Ảnh mốc ở cuối mỗi hàng · kéo ngang để xem toàn bộ quá khứ"
                                      : "AI quyết định số phân đoạn và ladder riêng sau phân tích"
                                color: frame.selectedFailed
                                       ? VfTheme.redText
                                       : Boolean(frame.controller
                                               && frame.controller.draftBusy)
                                       ? VfTheme.blueText : VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                visible: frame.pipelineBusy
                                         && !frame.selectedFailed
                                Layout.preferredWidth: VfTheme.dp(94)
                                Layout.preferredHeight: VfTheme.dp(7)
                                radius: height / 2
                                color: VfTheme.surface
                                border.color: VfTheme.blueBorderSoft
                                clip: true

                                Rectangle {
                                    id: progressFill
                                    width: Math.max(
                                        parent.height,
                                        parent.width
                                        * frame.displayProgress / 100)
                                    height: parent.height
                                    radius: height / 2
                                    color: VfTheme.primary

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 180
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    Rectangle {
                                        id: progressShimmer
                                        visible: frame.runtimeActive
                                        width: Math.max(VfTheme.dp(12),
                                                        progressFill.width * 0.35)
                                        height: parent.height
                                        radius: parent.radius
                                        color: "white"
                                        opacity: 0.28

                                        NumberAnimation on x {
                                            running: progressShimmer.visible && VfTheme.motion
                                            loops: Animation.Infinite
                                            from: -progressShimmer.width
                                            to: progressFill.width
                                            duration: 880
                                            easing.type: Easing.InOutSine
                                        }
                                    }
                                }
                            }

                            Text {
                                visible: frame.pipelineBusy
                                         && !frame.selectedFailed
                                text: frame.displayProgress + "%"
                                color: VfTheme.blueText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(9)
                                font.weight: Font.Bold
                            }
                            Rectangle {
                                visible: false
                                Layout.preferredWidth: VfTheme.dp(22)
                                Layout.preferredHeight: VfTheme.dp(19)
                                radius: VfTheme.dp(5)
                                color: frame.viewPage > 0
                                       ? VfTheme.blueFill : VfTheme.surfaceSoft
                                border.color: VfTheme.border
                                Text {
                                    anchors.centerIn: parent
                                    text: "‹"
                                    color: frame.viewPage > 0
                                           ? VfTheme.blueText : VfTheme.textSubtle
                                    font.pixelSize: VfTheme.dp(13)
                                    font.weight: Font.Bold
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    enabled: frame.viewPage > 0
                                    cursorShape: enabled
                                                 ? Qt.PointingHandCursor
                                                 : Qt.ArrowCursor
                                    onClicked: frame.setViewPage(
                                                   frame.viewPage - 1)
                                }
                            }
                            Text {
                                visible: false
                                text: "Phân đoạn " + frame.firstVisibleView
                                      + "–" + frame.lastVisibleView
                                      + " / " + frame.viewCount
                                      + " · Trang " + (frame.viewPage + 1)
                                      + "/" + frame.viewPageCount
                                color: VfTheme.blueText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                font.weight: Font.Bold
                            }
                            Rectangle {
                                visible: false
                                Layout.preferredWidth: VfTheme.dp(22)
                                Layout.preferredHeight: VfTheme.dp(19)
                                radius: VfTheme.dp(5)
                                color: frame.viewPage < frame.viewPageCount - 1
                                       ? VfTheme.blueFill : VfTheme.surfaceSoft
                                border.color: VfTheme.border
                                Text {
                                    anchors.centerIn: parent
                                    text: "›"
                                    color: frame.viewPage
                                           < frame.viewPageCount - 1
                                           ? VfTheme.blueText : VfTheme.textSubtle
                                    font.pixelSize: VfTheme.dp(13)
                                    font.weight: Font.Bold
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    enabled: frame.viewPage
                                             < frame.viewPageCount - 1
                                    cursorShape: enabled
                                                 ? Qt.PointingHandCursor
                                                 : Qt.ArrowCursor
                                    onClicked: frame.setViewPage(
                                                   frame.viewPage + 1)
                                }
                            }
                        }

                        TimeMachineChapterBoard {
                            id: chapterBoard
                            objectName: "timeMachineChapterBoard"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            controller: frame.controller
                            hasPlan: frame.hasPlan
                            portraitFrames: frame.portraitFrames
                            page: frame.viewPage
                            pageSize: frame.viewPageSize
                            inputImageCount: frame.inputImageCount
                            previewPath: frame.previewPath
                            busy: frame.pipelineBusy
                            progress: frame.displayProgress
                            activityTitle: frame.phaseLabel()
                            activityDetail: frame.pipelineMessage
                            onPreviewSelected: function(path, title, status) {
                                frame.selectPreview(path, title, status)
                            }
                            onPreviewOpened: function(path, title, status) {
                                frame.openPreview(path, title, status)
                            }
                            onEditCellRequested: function(
                                viewId, viewLabel, stageIdx, prompt, locked) {
                                frame.editCellRequested(
                                    viewId, viewLabel, stageIdx, prompt, locked)
                            }
                        }

                        // Legacy shared-ladder matrix kept inert for compatibility
                        // while old snapshots are migrated to chapterModel.
                        Row {
                            visible: false
                            Layout.fillWidth: true
                            Layout.preferredHeight: 0
                            Layout.minimumHeight: 0
                            Layout.maximumHeight: 0
                            spacing: 0

                            Rectangle {
                                width: frame.labelWidth
                                height: parent.height
                                color: VfTheme.surfaceSoft
                                border.color: VfTheme.border
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(8)
                                    text: "ẢNH / GÓC"
                                    verticalAlignment: Text.AlignVCenter
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    font.weight: Font.Bold
                                }
                            }

                            Flickable {
                                id: stageHeaderFlick
                                width: parent.width - frame.labelWidth
                                height: parent.height
                                contentWidth: frame.stageCount * frame.stageWidth
                                contentHeight: height
                                contentX: boardFlick.contentX
                                interactive: false
                                clip: true

                                Row {
                                    width: parent.contentWidth
                                    height: parent.height
                                    Repeater {
                                        model: 0
                                        delegate: Rectangle {
                                            id: stageHeader
                                            required property int index
                                            required property var model
                                            property int stageIdx:
                                                frame.hasPlan
                                                ? Number(model.stageIdx || 0)
                                                : index
                                            property string stageLabel:
                                                frame.hasPlan
                                                ? ("S" + stageIdx + " · "
                                                   + String(model.name || ""))
                                                : frame.stageName(index)
                                            width: frame.stageWidth
                                            height: frame.headerHeight
                                            color: stageHeader.stageIdx
                                                   === frame.stageCount - 1
                                                   ? VfTheme.amberFill
                                                   : VfTheme.surfaceSoft
                                            border.color: stageHeader.stageIdx
                                                          === frame.stageCount - 1
                                                          ? VfTheme.amberBorderSoft
                                                          : VfTheme.border
                                            Text {
                                                anchors.fill: parent
                                                anchors.leftMargin: VfTheme.dp(7)
                                                anchors.rightMargin: VfTheme.dp(7)
                                                text: stageHeader.stageLabel
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                color: VfTheme.text
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.dp(8)
                                                font.weight: Font.Bold
                                                elide: Text.ElideRight
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: frame.hasPlan
                                                             ? Qt.PointingHandCursor
                                                             : Qt.ArrowCursor
                                                onClicked: {
                                                    if (frame.hasPlan)
                                                        frame.editStageRequested(
                                                            stageHeader.stageIdx,
                                                            String(stageHeader.model.name || ""),
                                                            String(stageHeader.model.visibleDescription
                                                                   || ""))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Row {
                            visible: false
                            Layout.fillWidth: true
                            Layout.preferredHeight: 0
                            Layout.minimumHeight: 0
                            Layout.maximumHeight: 0
                            spacing: 0

                            ListView {
                                id: viewLabels
                                width: frame.labelWidth
                                height: parent.height
                                model: 0
                                interactive: false
                                reuseItems: true
                                contentY: frame.viewPage
                                          * frame.viewPageSize
                                          * frame.rowHeight
                                clip: true
                                footer: Item {
                                    width: viewLabels.width
                                    height: Math.max(
                                        0,
                                        frame.paddedViewCount - frame.viewCount)
                                        * frame.rowHeight
                                }

                                delegate: Rectangle {
                                    id: viewLabelCard
                                    required property int index
                                    required property var model
                                    property string rowLabel:
                                        frame.hasPlan
                                        ? String(model.label || "")
                                        : frame.skeletonViewName(index)
                                    width: viewLabels.width
                                    height: frame.rowHeight
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.border

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: VfTheme.dp(6)
                                        spacing: VfTheme.dp(6)
                                        Rectangle {
                                            Layout.preferredWidth: VfTheme.dp(28)
                                            Layout.preferredHeight: width
                                            radius: VfTheme.dp(6)
                                            color: VfTheme.blueFill
                                            border.color: VfTheme.blueBorderSoft
                                            Text {
                                                anchors.centerIn: parent
                                                text: frame.imageNumber(
                                                          viewLabelCard.index)
                                                color: VfTheme.blueText
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.dp(9)
                                                font.weight: Font.Bold
                                            }
                                        }
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 1
                                            Text {
                                                Layout.fillWidth: true
                                                text: viewLabelCard.rowLabel
                                                color: VfTheme.text
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.dp(9)
                                                font.weight: Font.Bold
                                                elide: Text.ElideRight
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                text: frame.hasPlan
                                                      ? "Theo dõi realtime"
                                                      : frame.inputImageCount > 0
                                                        ? "Chờ AI phân tích"
                                                        : "Sinh từ ý tưởng"
                                                color: VfTheme.textMuted
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.dp(8)
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }
                                }
                            }

                            Flickable {
                                id: boardFlick
                                width: parent.width - frame.labelWidth
                                height: parent.height
                                contentWidth: frame.stageCount * frame.stageWidth
                                contentHeight:
                                    frame.paddedViewCount * frame.rowHeight
                                contentY: frame.viewPage
                                          * frame.viewPageSize
                                          * frame.rowHeight
                                clip: true
                                flickableDirection: Flickable.HorizontalFlick
                                boundsBehavior: Flickable.StopAtBounds
                                ScrollBar.horizontal: ScrollBar {
                                    policy: boardFlick.contentWidth > boardFlick.width
                                            ? ScrollBar.AlwaysOn
                                            : ScrollBar.AsNeeded
                                }
                                ScrollBar.vertical: ScrollBar {
                                    policy: ScrollBar.AlwaysOff
                                }

                                Grid {
                                    columns: frame.stageCount
                                    spacing: 0

                                    Repeater {
                                        model: 0

                                        delegate: Rectangle {
                                            id: cell
                                            required property int index
                                            required property var model
                                            property int rowIdx:
                                                frame.hasPlan
                                                ? Number(model.rowIdx || 0)
                                                : Math.floor(index / frame.stageCount)
                                            property int stageIdx:
                                                frame.hasPlan
                                                ? Number(model.stageIdx || 0)
                                                : index % frame.stageCount
                                            property string viewId:
                                                frame.hasPlan
                                                ? String(model.viewId || "") : ""
                                            property string viewLabel:
                                                frame.hasPlan
                                                ? String(model.viewLabel || "")
                                                : frame.skeletonViewName(rowIdx)
                                            property string status:
                                                frame.hasPlan
                                                ? String(model.status || "waiting")
                                                : "waiting"
                                            property string imagePath:
                                                frame.hasPlan
                                                ? String(model.imagePath || "") : ""
                                            property string prompt:
                                                frame.hasPlan
                                                ? String(model.regressPrompt || "") : ""
                                            property bool locked:
                                                frame.hasPlan
                                                && Boolean(model.locked)
                                            width: frame.stageWidth
                                            height: frame.rowHeight
                                            color: cell.stageIdx
                                                   === frame.stageCount - 1
                                                   ? VfTheme.amberFill
                                                   : VfTheme.surface
                                            border.color: cell.stageIdx
                                                          === frame.stageCount - 1
                                                          ? VfTheme.amberBorderSoft
                                                          : cell.imagePath.length > 0
                                                            && cell.imagePath
                                                               === frame.previewPath
                                                            ? VfTheme.primary
                                                          : VfTheme.border
                                            border.width: cell.imagePath.length > 0
                                                          && cell.imagePath
                                                             === frame.previewPath
                                                          ? 2 : 1

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: VfTheme.dp(4)
                                                spacing: VfTheme.dp(2)

                                                Rectangle {
                                                    Layout.alignment:
                                                        Qt.AlignHCenter
                                                    Layout.preferredWidth:
                                                        frame.portraitFrames
                                                        ? VfTheme.dp(31)
                                                        : Math.min(
                                                              cell.width
                                                              - VfTheme.dp(8),
                                                              (frame.rowHeight
                                                               - VfTheme.dp(20))
                                                              * 16 / 9)
                                                    Layout.preferredHeight:
                                                        frame.portraitFrames
                                                        ? VfTheme.dp(52)
                                                        : (cell.width
                                                           - VfTheme.dp(8))
                                                          * 9 / 16
                                                    Layout.maximumHeight:
                                                        frame.rowHeight
                                                        - VfTheme.dp(20)
                                                    radius: VfTheme.dp(4)
                                                    color: VfTheme.surfaceSoft
                                                    border.color:
                                                        cell.imagePath.length > 0
                                                        ? VfTheme.blueBorderSoft
                                                        : VfTheme.border
                                                    clip: true

                                                    Image {
                                                        anchors.fill: parent
                                                        source:
                                                            MediaSourceResolver
                                                            .localFileUrl(
                                                                cell.imagePath)
                                                        fillMode:
                                                            Image.PreserveAspectCrop
                                                        asynchronous: true
                                                        cache: false
                                                        sourceSize.width: width
                                                        sourceSize.height: height
                                                        visible:
                                                            cell.imagePath.length > 0
                                                    }
                                                    Text {
                                                        anchors.centerIn: parent
                                                        visible:
                                                            cell.imagePath.length
                                                            === 0
                                                        text: cell.status === "working"
                                                              ? "◌" : "▧"
                                                        color:
                                                            frame.stateColor(
                                                                cell.status)
                                                        font.pixelSize:
                                                            VfTheme.dp(13)
                                                    }
                                                }

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight:
                                                        VfTheme.dp(12)
                                                    spacing: 1
                                                    Rectangle {
                                                        Layout.preferredWidth:
                                                            VfTheme.dp(5)
                                                        Layout.preferredHeight:
                                                            width
                                                        radius: width / 2
                                                        color: frame.stateColor(
                                                                   cell.status)
                                                    }
                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: cell.imagePath.length
                                                              ? "OK · xem nhanh"
                                                              : cell.status === "working"
                                                                ? "Đang tạo…"
                                                                : "Chờ AI"
                                                        color:
                                                            frame.stateColor(
                                                                cell.status)
                                                        font.family:
                                                            VfTheme.fontFamily
                                                        font.pixelSize:
                                                            VfTheme.dp(8)
                                                        elide: Text.ElideRight
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (cell.imagePath.length > 0) {
                                                        frame.selectPreview(
                                                            cell.imagePath,
                                                            cell.viewLabel
                                                            + " · S"
                                                            + cell.stageIdx,
                                                            cell.status)
                                                    } else if (frame.hasPlan) {
                                                        frame.editCellRequested(
                                                            cell.viewId,
                                                            cell.viewLabel,
                                                            cell.stageIdx,
                                                            cell.prompt,
                                                            cell.locked)
                                                    }
                                                }
                                                onDoubleClicked: {
                                                    if (cell.imagePath.length > 0) {
                                                        frame.openPreview(
                                                            cell.imagePath,
                                                            cell.viewLabel
                                                            + " · S"
                                                            + cell.stageIdx,
                                                            cell.status)
                                                    } else if (frame.hasPlan) {
                                                        frame.editCellRequested(
                                                            cell.viewId,
                                                            cell.viewLabel,
                                                            cell.stageIdx,
                                                            cell.prompt,
                                                            cell.locked)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                TimeMachineLiveChainPanel {
                    objectName: "timeMachineLiveChainPanel"
                    visible: frame.pairPanelEnabled
                             && frame.width >= VfTheme.dp(1060)
                    Layout.preferredWidth: visible ? VfTheme.dp(300) : 0
                    Layout.minimumWidth: visible ? VfTheme.dp(270) : 0
                    Layout.fillHeight: true
                    chainState: frame.liveChain
                    pipelineKind: frame.pipelineKind
                    busy: frame.pipelineBusy
                    portraitFrames: frame.portraitFrames
                    onPreviewRequested: function(path, title, status) {
                        frame.openPreview(path, title, status)
                    }
                }

            }

            Rectangle {
                objectName: "timeMachineVideoOrder"
                Layout.fillWidth: true
                Layout.preferredHeight: frame.pairsExpanded
                                        ? VfTheme.dp(58) : VfTheme.dp(27)
                radius: VfTheme.dp(6)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(6)
                    spacing: VfTheme.dp(4)
                    RowLayout {
                        Layout.fillWidth: true
                        VfAppIcon {
                            name: "movie-camera"
                            size: VfTheme.dp(14)
                            color: VfTheme.amberText
                        }
                        Text {
                            text: (frame.pairsExpanded ? "⌄ " : "› ")
                                  + "VIDEO ORDER · "
                                  + frame.plannedClipCount + " CLIP"
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(8)
                            font.weight: Font.Bold
                        }
                        Text {
                            visible: frame.pairPanelEnabled
                            text: Number(frame.liveChain.completed_clips || 0)
                                  + " / "
                                  + Number(frame.liveChain.total_clips || 0)
                                  + " · " + frame.liveChainProgress + "%"
                            color: VfTheme.cyanText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(7)
                            font.weight: Font.Bold
                        }
                        Repeater {
                            model: frame.postproductionActive
                                   && frame.width >= VfTheme.dp(980)
                                   ? ["picture_lock", "narration_plan",
                                      "graphics_master", "audio_master"]
                                   : []
                            delegate: Rectangle {
                                id: checkpointChip
                                required property string modelData
                                readonly property bool done:
                                    frame.checkpointDone(modelData)
                                Layout.preferredWidth:
                                    checkpointChipText.implicitWidth
                                    + VfTheme.dp(12)
                                Layout.preferredHeight: VfTheme.dp(18)
                                radius: height / 2
                                color: done ? VfTheme.greenFill
                                            : VfTheme.surface
                                border.color: done
                                              ? VfTheme.greenBorderSoft
                                              : VfTheme.border
                                Text {
                                    id: checkpointChipText
                                    anchors.centerIn: parent
                                    text: (checkpointChip.done ? "✓ " : "○ ")
                                          + frame.checkpointLabel(
                                              checkpointChip.modelData)
                                    color: checkpointChip.done
                                           ? VfTheme.greenText
                                           : VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(7)
                                    font.weight: Font.Bold
                                }
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: frame.pairsExpanded ? "Thu gọn" : "Xem danh sách"
                            color: VfTheme.blueText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(8)
                            font.weight: Font.Bold
                        }
                    }
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: frame.pairsExpanded
                        orientation: ListView.Horizontal
                        spacing: VfTheme.dp(5)
                        clip: true
                        reuseItems: true
                        model: frame.hasPlan ? frame.controller.motionModel : null
                        delegate: Rectangle {
                            id: pairCard
                            required property string motionKey
                            required property string viewLabel
                            required property int fromStage
                            required property int toStage
                            required property int editSeq
                            required property string status
                            required property int progress
                            required property string prompt
                            required property string clipKind
                            required property string cameraFamily
                            required property string jobId
                            required property string sourceType
                            width: VfTheme.dp(176)
                            height: VfTheme.dp(26)
                            radius: VfTheme.dp(5)
                            color: pairCard.clipKind === "final_reveal"
                                   ? VfTheme.amberFill
                                   : VfTheme.violetFill
                            border.color: pairCard.clipKind === "final_reveal"
                                          ? VfTheme.amberBorderSoft
                                          : VfTheme.violetBorderSoft
                            RowLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: VfTheme.dp(5)
                                spacing: VfTheme.dp(4)
                                Text {
                                    text: "#" + (pairCard.editSeq + 1)
                                    color: VfTheme.violetText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    font.weight: Font.Bold
                                }
                                Rectangle {
                                    Layout.preferredWidth: VfTheme.dp(5)
                                    Layout.preferredHeight: VfTheme.dp(5)
                                    radius: width / 2
                                    color: pairCard.status === "completed"
                                           ? VfTheme.greenText
                                           : pairCard.status === "failed"
                                             ? VfTheme.redText
                                             : pairCard.status === "running"
                                               ? VfTheme.blueText
                                               : VfTheme.textMuted
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: pairCard.clipKind === "final_reveal"
                                          ? "CẢNH KẾT · "
                                            + frame.cameraFamilyLabel(
                                                pairCard.cameraFamily)
                                          : pairCard.viewLabel + " · S"
                                            + pairCard.fromStage + " → S"
                                            + pairCard.toStage
                                    color: pairCard.clipKind === "final_reveal"
                                           ? VfTheme.amberText
                                           : VfTheme.violetText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    font.weight: Font.Bold
                                    elide: Text.ElideRight
                                }
                                Text {
                                    visible: pairCard.status === "running"
                                    text: pairCard.progress + "%"
                                    color: VfTheme.blueText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(7)
                                }
                            }
                            ProgressBar {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: VfTheme.dp(5)
                                anchors.rightMargin: VfTheme.dp(5)
                                anchors.bottomMargin: VfTheme.dp(2)
                                height: VfTheme.dp(2)
                                visible: pairCard.status === "running"
                                from: 0
                                to: 100
                                value: pairCard.progress
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: frame.editMotionRequested(
                                    pairCard.motionKey, pairCard.viewLabel,
                                    pairCard.fromStage, pairCard.toStage,
                                    pairCard.prompt)
                            }
                        }
                    }
                }
                MouseArea {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: VfTheme.dp(27)
                    cursorShape: Qt.PointingHandCursor
                    onClicked: frame.pairsExpanded = !frame.pairsExpanded
                }
            }
        }
    }

    Rectangle {
        id: queueSection
        objectName: "timeMachineQueue"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: frame.queueFixedHeight
        radius: VfTheme.radiusPanel
        color: VfTheme.surface
        border.color: VfTheme.amberBorderSoft
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(8)
            spacing: VfTheme.dp(5)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)

                VfAppIcon {
                    name: "inbox-tray"
                    size: VfTheme.dp(18)
                    color: VfTheme.amberText
                }

                VfButton {
                    actionId: "timemachine.queue.add"
                    compact: true
                    text: "+ THÊM VÀO HÀNG CHỜ"
                    tone: "accent"
                    onClicked: frame.enqueueRequested()
                }

                Text {
                    text: "Tổng " + Number(frame.queueStats.total || 0)
                          + " · Chờ " + Number(frame.queueStats.waiting || 0)
                          + " · Đang chạy "
                          + Number(frame.queueStats.running || 0)
                          + " · Xong "
                          + Number(frame.queueStats.complete || 0)
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                }

                Item { Layout.fillWidth: true }

                VfButton {
                    compact: true
                    text: Boolean(frame.queueStats.run_requested)
                          ? "AUTOPILOT ĐANG CHẠY" : "AUTOPILOT SẴN SÀNG"
                    tone: "primary"
                    enabled: false
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(27)
                radius: VfTheme.dp(5)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(6)
                    anchors.rightMargin: VfTheme.dp(6)
                    spacing: VfTheme.dp(7)
                    Text {
                        Layout.minimumWidth: 0
                        Layout.preferredWidth: frame.queueJobColumnWidth
                        Layout.maximumWidth: frame.queueJobColumnWidth
                        text: "JOB / Ý TƯỞNG"
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(8)
                        font.weight: Font.Bold
                    }
                    QueueDivider {}
                    Text {
                        Layout.minimumWidth: 0
                        Layout.preferredWidth: frame.queueInputColumnWidth
                        Layout.maximumWidth: frame.queueInputColumnWidth
                        text: "ĐẦU VÀO"
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(8)
                        font.weight: Font.Bold
                    }
                    QueueDivider {}
                    Text {
                        Layout.minimumWidth: 0
                        Layout.preferredWidth: frame.queueScaleColumnWidth
                        Layout.maximumWidth: frame.queueScaleColumnWidth
                        text: "QUY MÔ PIPELINE"
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(8)
                        font.weight: Font.Bold
                    }
                    QueueDivider {}
                    Text {
                        Layout.minimumWidth: 0
                        Layout.preferredWidth: frame.queueImageColumnWidth
                        Layout.maximumWidth: frame.queueImageColumnWidth
                        text: "MODEL ẢNH / STYLE"
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(8)
                        font.weight: Font.Bold
                    }
                    QueueDivider {}
                    Text {
                        Layout.minimumWidth: 0
                        Layout.preferredWidth: frame.queueVideoColumnWidth
                        Layout.maximumWidth: frame.queueVideoColumnWidth
                        text: "VIDEO / DẪN TRUYỆN / ĐẦU RA"
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(8)
                        font.weight: Font.Bold
                    }
                    QueueDivider {}
                    Text {
                        Layout.minimumWidth: 0
                        Layout.preferredWidth: frame.queueProgressColumnWidth
                        Layout.maximumWidth: frame.queueProgressColumnWidth
                        text: "TIẾN ĐỘ A–Z"
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(8)
                        font.weight: Font.Bold
                    }
                }
            }

            ListView {
                id: queueList
                objectName: "timeMachineQueueList"
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: frame.controller ? frame.controller.queueModel : null
                spacing: VfTheme.dp(4)
                clip: true
                reuseItems: true
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    id: queueRow
                    required property int index
                    required property var qrow
                    width: queueList.width
                    height: frame.queueRowHeight
                    radius: VfTheme.dp(6)
                    color: String(queueRow.qrow.id || "")
                           === String(frame.selectedJob.id || "")
                           ? VfTheme.blueFill : VfTheme.surfaceSoft
                    border.color: String(queueRow.qrow.id || "")
                                  === String(frame.selectedJob.id || "")
                                  ? VfTheme.blueBorderSoft : VfTheme.border

                    RowLayout {
                        z: 1
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(6)
                        spacing: VfTheme.dp(7)

                        ColumnLayout {
                            Layout.minimumWidth: 0
                            Layout.preferredWidth: frame.queueJobColumnWidth
                            Layout.maximumWidth: frame.queueJobColumnWidth
                            Layout.fillHeight: true
                            spacing: 1
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(5)
                                Rectangle {
                                    Layout.preferredWidth: VfTheme.dp(26)
                                    Layout.preferredHeight: VfTheme.dp(21)
                                    radius: VfTheme.dp(5)
                                    color: VfTheme.blueFill
                                    Text {
                                        anchors.centerIn: parent
                                        text: queueRow.index + 1 < 10
                                              ? "0" + (queueRow.index + 1)
                                              : String(queueRow.index + 1)
                                        color: VfTheme.blueText
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(8)
                                        font.weight: Font.Bold
                                    }
                                }
                                Text {
                                    Layout.minimumWidth: 0
                                    Layout.fillWidth: true
                                    text: String(queueRow.qrow.title || "")
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9)
                                    font.weight: Font.Bold
                                    maximumLineCount: 1
                                    wrapMode: Text.NoWrap
                                    elide: Text.ElideRight
                                    clip: true
                                }
                            }
                            Text {
                                Layout.minimumWidth: 0
                                Layout.fillWidth: true
                                text: String(queueRow.qrow.intent_summary
                                             || queueRow.qrow.title || "")
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                maximumLineCount: 1
                                wrapMode: Text.NoWrap
                                elide: Text.ElideRight
                                clip: true
                            }
                        }

                        QueueDivider {}

                        ColumnLayout {
                            Layout.minimumWidth: 0
                            Layout.preferredWidth: frame.queueInputColumnWidth
                            Layout.maximumWidth: frame.queueInputColumnWidth
                            Layout.fillHeight: true
                            spacing: 1
                            Text {
                                Layout.fillWidth: true
                                text: Boolean(queueRow.qrow.source_audio)
                                      ? "Audio "
                                        + Number(queueRow.qrow.source_duration_s
                                                 || 0).toFixed(0) + "s"
                                      : Boolean(queueRow.qrow.source_srt)
                                        ? "SRT · Gemini đọc"
                                        : Number(queueRow.qrow.input_count || 0) > 0
                                          ? Number(queueRow.qrow.input_count || 0)
                                            + " ảnh mốc"
                                          : "Ý tưởng thuần AI"
                                color: VfTheme.blueText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: (
                                    Number(queueRow.qrow.input_count || 0) > 0
                                    ? Number(queueRow.qrow.input_count || 0)
                                      + " ảnh · "
                                      + String(queueRow.qrow.view_labels || "")
                                    : "AI sinh ảnh mốc"
                                ) + (Boolean(queueRow.qrow.source_srt)
                                     ? " · có SRT" : "")
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                elide: Text.ElideRight
                            }
                        }

                        QueueDivider {}

                        ColumnLayout {
                            Layout.minimumWidth: 0
                            Layout.preferredWidth: frame.queueScaleColumnWidth
                            Layout.maximumWidth: frame.queueScaleColumnWidth
                            Layout.fillHeight: true
                            spacing: 1
                            Text {
                                Layout.fillWidth: true
                                text: Number(queueRow.qrow.chapter_count
                                             || queueRow.qrow.view_count || 0)
                                      + " phân đoạn · "
                                      + Number(queueRow.qrow.unique_state_count
                                               || queueRow.qrow.keyframe_count
                                               || 0) + " mốc"
                                color: VfTheme.blueText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: Number(queueRow.qrow.clip_count || 0)
                                      + " clip · "
                                      + String(queueRow.qrow.aspect_label || "Auto")
                                      + " · "
                                      + String(queueRow.qrow.quality_label || "Auto")
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                elide: Text.ElideRight
                            }
                        }

                        QueueDivider {}

                        ColumnLayout {
                            Layout.minimumWidth: 0
                            Layout.preferredWidth: frame.queueImageColumnWidth
                            Layout.maximumWidth: frame.queueImageColumnWidth
                            Layout.fillHeight: true
                            spacing: 1
                            Text {
                                Layout.fillWidth: true
                                text: String(queueRow.qrow.image_model_label
                                             || "Auto")
                                color: VfTheme.violetText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: String(queueRow.qrow.style_label
                                             || "Theo ảnh gốc")
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                elide: Text.ElideRight
                            }
                        }

                        QueueDivider {}

                        ColumnLayout {
                            Layout.minimumWidth: 0
                            Layout.preferredWidth: frame.queueVideoColumnWidth
                            Layout.maximumWidth: frame.queueVideoColumnWidth
                            Layout.fillHeight: true
                            spacing: 1
                            Text {
                                Layout.fillWidth: true
                                text: String(queueRow.qrow.video_model_label
                                             || "Auto Start–End")
                                color: VfTheme.violetText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: frame.queueAudioAndRevealLabel(
                                          queueRow.qrow)
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                elide: Text.ElideRight
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(11)
                                Text {
                                    anchors.fill: parent
                                    text: "Mở thư mục: "
                                          + String(queueRow.qrow.session_folder
                                                   || queueRow.qrow.output_folder
                                                   || "Chưa chọn")
                                    color: String(queueRow.qrow.session_folder
                                                  || queueRow.qrow.output_folder
                                                  || "").length > 0
                                           ? VfTheme.blueText
                                           : VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    font.underline: String(
                                                        queueRow.qrow.session_folder
                                                        || queueRow.qrow.output_folder
                                                        || "").length > 0
                                    elide: Text.ElideMiddle
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    enabled: String(
                                                 queueRow.qrow.session_folder
                                                 || queueRow.qrow.output_folder
                                                 || "").length > 0
                                    cursorShape: enabled
                                                 ? Qt.PointingHandCursor
                                                 : Qt.ArrowCursor
                                    onClicked: frame.openFolderRequested(
                                        String(queueRow.qrow.session_folder
                                               || queueRow.qrow.output_folder
                                               || ""))
                                }
                            }
                        }

                        QueueDivider {}

                        ColumnLayout {
                            Layout.minimumWidth: 0
                            Layout.preferredWidth: frame.queueProgressColumnWidth
                            Layout.maximumWidth: frame.queueProgressColumnWidth
                            Layout.fillHeight: true
                            spacing: 1
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: frame.queueStatusLabel(
                                              queueRow.qrow.status)
                                    color: String(queueRow.qrow.status || "")
                                           === "failed"
                                           ? VfTheme.redText
                                           : String(queueRow.qrow.status || "")
                                             === "running"
                                             ? VfTheme.greenText
                                             : VfTheme.blueText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: Number(queueRow.qrow.pipeline_done || 0)
                                          + "/"
                                          + Number(queueRow.qrow.pipeline_total || 0)
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    font.weight: Font.Bold
                                }
                            }
                            ProgressBar {
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(5)
                                from: 0
                                to: 100
                                value: queueRow.qrow.pipeline_progress !== undefined
                                       ? Number(queueRow.qrow.pipeline_progress)
                                       : Number(queueRow.qrow.progress || 0)
                            }
                            Text {
                                Layout.fillWidth: true
                                text: String(queueRow.qrow.status || "") === "failed"
                                      ? "Bấm để xem chi tiết lỗi"
                                      : String(queueRow.qrow.message || "")
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                elide: Text.ElideRight
                            }
                        }
                    }
                    MouseArea {
                        z: 0
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: frame.controller.selectJob(
                            String(queueRow.qrow.id || ""))
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: queueList.count === 0
                    text: "Chưa có job trong hàng chờ."
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                }
            }

            Text {
                Layout.fillWidth: true
                visible: frame.actionError.length > 0
                text: frame.actionError
                color: VfTheme.redText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                elide: Text.ElideRight
            }
        }
    }

    Dialog {
        id: quickPreview
        parent: Overlay.overlay
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        width: Math.min(parent ? parent.width - VfTheme.dp(70)
                               : VfTheme.dp(980), VfTheme.dp(1180))
        height: Math.min(parent ? parent.height - VfTheme.dp(70)
                                : VfTheme.dp(720), VfTheme.dp(760))
        x: parent ? (parent.width - width) / 2 : 0
        y: parent ? (parent.height - height) / 2 : 0
        padding: VfTheme.dp(10)

        background: Rectangle {
            radius: VfTheme.dp(10)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(8)
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: frame.previewTitle
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                Text {
                    text: frame.previewStatus
                    color: frame.stateColor(frame.previewStatus)
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                }
                VfButton {
                    compact: true
                    text: "ĐÓNG"
                    onClicked: quickPreview.close()
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(7)
                color: "#111827"
                clip: true
                Image {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    source: MediaSourceResolver.localFileUrl(frame.previewPath)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                }
            }
        }
    }
}
