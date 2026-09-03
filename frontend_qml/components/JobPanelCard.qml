import QtQuick
import QtQuick.Window

import "../components"
import "../dialogs"
import "../theme"
import "MediaSourceResolver.js" as MediaSourceResolver

Rectangle {
    id: root

    property var row: ({})
    property string jobId: ""
    property string modelKind: ""
    property string modelTitle: ""
    property string modelSubtitle: ""
    property string modelStatus: ""
    property string modelStatusText: ""
    property string modelStatusChipText: ""
    property int modelProgress: -1
    property string modelThumbnailUrl: ""
    property string modelThumbnailPlaceholder: ""
    property var modelAssetPreviews: []
    property var modelAssetSlots: []
    property string modelAspectRatio: ""
    property string modelVideoPath: ""
    property string modelMediaId: ""
    property string modelSourceMediaId: ""
    property string modelSourceMediaName: ""
    property string modelCurrentResolution: ""
    property string modelOutputPath: ""
    property string modelOutputFolder: ""
    property string modelTierMode: ""
    property string modelAccountName: ""
    property string modelAccountEmail: ""
    property int modelCanRetry: -1
    property int modelCanUpscale: -1
    property int modelCanEdit: -1
    property int modelCanDelete: -1
    property int sequenceNumber: 0
    property bool animationsEnabled: true
    property bool lightweightMode: false

    signal viewRequested(var row)
    signal regenerateRequested(var row)
    signal deleteRequested(var row)
    signal editRequested(var row)
    signal assetRequested(var row, int index)
    signal assetPreviewRequested(string source, string title)
    signal commandRequested(string actionId, string jobId, int index)
    signal reupscaleRequested(var row, var payload)

    // All literals go through VfTheme.dp() so they scale with resolution like the
    // rest of the UI (dp(n) = n * scaleFactor, base 1920x1080). Breakpoints use
    // dp() too so they trip at the same DESIGN width on every screen.
    property int contentMargin: VfTheme.dp(8)
    readonly property int cardGap: width >= VfTheme.dp(360) ? VfTheme.dp(8) : VfTheme.dp(6)
    readonly property int assetGap: width >= VfTheme.dp(320) ? VfTheme.dp(4) : VfTheme.dp(3)
    readonly property int actionColumnWidth: width >= VfTheme.dp(360) ? VfTheme.dp(96) : VfTheme.dp(88)
    readonly property real availableThumbnailWidth: Math.max(VfTheme.dp(120), width - (contentMargin * 2) - actionColumnWidth - cardGap)
    // The job thumbnail viewport is always 16:9. Portrait/square outputs are
    // aspect-fitted and centered inside this frame so the card layout stays
    // stable and the media is never stretched.
    readonly property real thumbnailFrameAspect: 16 / 9
    readonly property real thumbnailWidth: Math.min(Math.round(VfTheme.dp(150) * thumbnailFrameAspect), availableThumbnailWidth, VfTheme.dp(220))
    readonly property int assetSize: width >= VfTheme.dp(360) ? VfTheme.dp(32) : VfTheme.dp(30)
    readonly property real thumbnailHeight: Math.round(thumbnailWidth / thumbnailFrameAspect)
    readonly property int actionButtonHeight: Math.max(VfTheme.dp(20), Math.min(VfTheme.dp(26), Math.floor((thumbnailHeight - (cardGap * 3)) / 4)))
    readonly property real topAreaHeight: Math.max(thumbnailHeight, (actionButtonHeight * 4) + (cardGap * 3))
    readonly property string thumbnailSourceValue: root.thumbnailSource()
    readonly property var displayAssets: root.assetSlots()
    // How many tiles the strip shows before it scrolls: image-gen cards show 10 refs,
    // everything else 7. (The Repeater still renders all slots; this only sizes the strip.)
    readonly property int assetStripVisibleCap: root.isImageGenRow() ? 10 : 7
    readonly property int assetStripHeight: root.displayAssets.length > 0 ? root.assetSize : 0
    readonly property bool mediaHydrationEnabled: !root.lightweightMode
    readonly property int chipHeight: VfTheme.dp(18)
    readonly property int chipRadius: VfTheme.dp(5)
    readonly property int chipMargin: VfTheme.dp(6)
    readonly property int chipHPad: VfTheme.dp(8)
    readonly property int chipFontSize: VfTheme.dp(9)
    readonly property bool hasThumbnail: root.thumbnailSourceValue.length > 0
    readonly property bool showWorkingPlaceholder: !root.hasThumbnail
        && (root.isGeneratingState || root.statusKey().indexOf("complete") >= 0 || root.statusKey() === "done"
            || root.statusKey().indexOf("pending") >= 0 || root.statusKey().indexOf("queue") >= 0)

    width: parent ? parent.width : 340
    implicitHeight: (contentMargin * 2) + topAreaHeight + (assetStripHeight > 0 ? assetStripHeight + cardGap : 0)
    height: implicitHeight
    radius: VfTheme.dp(12)
    color: VfTheme.surface
    border.color: VfTheme.border
    border.width: 1

    function firstText(value) {
        if (value === undefined || value === null)
            return ""
        return String(value)
    }

    function firstArrayValue(candidates) {
        for (var i = 0; i < candidates.length; i++) {
            var candidate = candidates[i]
            // Chấp nhận cả JS array LẪN QVariantList đi qua model layer
            // (Array.isArray() trả false cho cái sau). Ép về real array để
            // .slice()/.length/Repeater phía dưới hoạt động đúng.
            if (candidate && typeof candidate !== "string" && candidate.length > 0) {
                var arr = []
                for (var k = 0; k < candidate.length; k++)
                    arr.push(candidate[k])
                return arr
            }
        }
        return []
    }

    function isBatchImageRow() {
        var meta = (row && row.meta) ? row.meta : ({})
        var feature = firstText(row.feature || row.type || row.tab_source || row.route || row.mode_key || "").toLowerCase()
        var outputFeature = firstText(meta.dispatch_feature || row.dispatch_feature || meta.feature || "").toLowerCase()
        if (feature.indexOf("batch_image") >= 0 || feature.indexOf("image_generation") >= 0 || feature.indexOf("image_upscale") >= 0
                || outputFeature.indexOf("batch_image") >= 0 || outputFeature.indexOf("image_generation") >= 0
                || outputFeature.indexOf("transcript_image") >= 0 || outputFeature.indexOf("clone_image") >= 0
                || outputFeature.indexOf("image_upscale") >= 0)
            return true
        if (String(row.session_key || "") === "batch_image")
            return true
        return Boolean(row.batch_id && row.prompts && row.prompts.length > 0)
    }

    function firstPromptText() {
        var prompt = firstText(row.prompt || row.text || row.idea || "")
        if (prompt.length > 0)
            return prompt
        if (row.prompts && row.prompts.length > 0)
            return firstText(row.prompts[0].prompt || row.prompts[0].text || row.prompts[0].idea || "")
        return ""
    }

    function titleText() {
        if (root.modelTitle.length > 0)
            return root.modelTitle
        var prompt = root.firstPromptText()
        if (root.isBatchImageRow())
            return firstText(row.name || row.title || row.id || row.row_id || row.job_id || "Batch Image")
        return firstText(row.name || row.title || row.idea || row.prompt || prompt || row.id || row.row_id || (void i18n.revision, i18n.t("qml.master.queue_row", "Queue row")))
    }

    function rawProgress() {
        if (root.modelProgress >= 0)
            return Math.max(0, Math.min(100, root.modelProgress))
        var progress = Number(row.job_progress !== undefined ? row.job_progress : row.progress)
        if (isNaN(progress))
            progress = 0
        return Math.max(0, Math.min(100, progress))
    }

    function timestampSeconds(value) {
        if (value === undefined || value === null || String(value).length === 0)
            return 0
        var numeric = Number(value)
        if (!isNaN(numeric) && numeric > 0)
            return numeric > 100000000000 ? numeric / 1000 : numeric
        var parsed = Date.parse(String(value))
        if (!isNaN(parsed) && parsed > 0)
            return parsed / 1000
        return 0
    }

    function generationStartedAtSeconds() {
        var status = root.statusKey()
        if (status.indexOf("upscal") >= 0) {
            var upscaleStarted = row.upscaling_started_at || row.upscale_started_at
            if (upscaleStarted !== undefined && upscaleStarted !== null && String(upscaleStarted).length > 0)
                return root.timestampSeconds(upscaleStarted)
        }
        if (status.indexOf("poll") >= 0) {
            var pollingStarted = row.polling_started_at || row.generating_since || row.started_at
            return root.timestampSeconds(pollingStarted)
        }
        return root.timestampSeconds(row.generating_since || row.started_at)
    }

    function effectiveGenerationSeconds() {
        if (root.statusKey().indexOf("upscal") >= 0) {
            var upscaleSeconds = Number(
                row.upscale_generation_time
                || row.upscaleGenerationTimeSeconds
                || row.upscale_generation_time_seconds
                || 0
            )
            if (!isNaN(upscaleSeconds) && upscaleSeconds > 0)
                return upscaleSeconds
        }
        return Number(
            row.generation_time
            || row.generationTimeSeconds
            || row.generation_time_seconds
            || 0
        )
    }

    function effectiveSceneCount() {
        var summary = row.dispatcher_summary || ({})
        if (root.statusKey().indexOf("upscal") >= 0) {
            var upscaleCount = Number(row.upscale_image_total || row.output_count || 1)
            if (!isNaN(upscaleCount) && upscaleCount > 0)
                return upscaleCount
        }
        var count = Number(row.scene_count || row.total_jobs || summary.total || 1)
        if (isNaN(count) || count <= 0)
            return 1
        return count
    }

    function shouldSynthesizeGenerateProgress() {
        var status = root.statusKey()
        if (status.indexOf("upscal") >= 0)
            return root.effectiveGenerationSeconds() > 0
        if (status.indexOf("process") >= 0 || status.indexOf("merge") >= 0)
            return false
        // CHỈ đếm khi POLLING = server đã nhận job (sau submit 200) và đang render.
        // GENERATING = pha trước-200 (warmup/captcha/submit) → KHÔNG đếm, giữ 0%;
        // tính giờ từ đây sẽ sai vì nuốt cả thời gian warmup/403-hold/retry.
        return status.indexOf("poll") >= 0
    }

    // Đang ở trạng thái đang sinh (để bật synthesize progress theo thời gian).
    readonly property bool isGeneratingState: {
        var s = root.statusKey()
        return s.indexOf("generat") >= 0 || s.indexOf("process") >= 0
            || s.indexOf("poll") >= 0 || s.indexOf("upscal") >= 0
            || s.indexOf("running") >= 0
    }
    // Tick mỗi giây khi đang gen để bar bò mượt (KHÔNG poll server).
    property double progressTick: 0

    // % hiển thị: khi đang gen + có generation_time (giây/clip biết trước của
    // model) + started_at → synthesize theo thời gian, cap 95% tới khi xong;
    // luôn >= % thật (đếm scene) để không lùi. Ngược lại dùng % thật.
    function displayProgress() {
        var real = root.rawProgress()
        if (!root.isGeneratingState)
            return Math.round(real)
        if (!root.shouldSynthesizeGenerateProgress())
            return Math.round(real)
        var started = root.generationStartedAtSeconds()
        var gen = root.effectiveGenerationSeconds()
        var scenes = root.effectiveSceneCount()
        if (started <= 0 || gen <= 0)
            return Math.round(real)
        var nowSec = (root.progressTick > 0 ? root.progressTick : Date.now()) / 1000
        var elapsed = Math.max(0, nowSec - started)
        // Đếm % theo thời gian từ mốc bắt đầu (polling = server đang render):
        // mỗi giây ~ 100/ETA %. KHÔNG max với raw (raw chỉ là mốc 0/20, sẽ ghìm
        // bar đứng im tới khi timePct vượt 20). Xong sớm → isGeneratingState=false
        // → early-return raw=100 (snap). Cap 99 để chừa cho cú snap.
        // Cả generate LẪN upscale đều là 0→99 theo ETA của pha tương ứng
        // (upscale dùng upscaling_started_at + upscale_generation_time). Upscale
        // là pha độc lập: generate chạy lên 100% rồi upscale bò lại từ 0%.
        var timePct = Math.min(99, (elapsed / (scenes * gen)) * 100)
        return Math.round(timePct)
    }

    // shownProgress bám theo % thật nhưng animate mượt: đếm từng giây khi gen,
    // và "chạy vọt" lên 100% lúc complete thay vì nhảy tức thì.
    function progressText() {
        return String(Math.round(root.shownProgress))
    }

    // % thật, re-eval theo tick giây / đổi trạng thái.
    readonly property int targetProgress: root.displayProgress()
    // % hiển thị, animate tới targetProgress.
    property real shownProgress: 0
    // Tắt animate cho lần set đầu (card vừa tạo / load history) để không tự chạy 0→100.
    property bool progressAnimReady: false
    // true = set tức thời (bỏ animate) — dùng khi reset bar về 0 lúc vào pha upscale,
    // tránh cú "chạy ngược" 100→0 nhìn xấu.
    property bool progressSnap: false
    // Status đã commit % lần cuối — đổi mốc TRONG CÙNG status (vd polling
    // restart anchor) không được kéo % lùi; đổi status (poll→upscal) là đổi PHA.
    property string progressStatusKey: ""
    onTargetProgressChanged: {
        var s = root.statusKey()
        if (s === root.progressStatusKey) {
            // Cùng pha: không lùi (anchor đổi giữa pha không kéo bar về).
            if (root.isGeneratingState && root.targetProgress < root.shownProgress)
                return
            root.shownProgress = root.targetProgress
            return
        }
        // ĐỔI PHA. Vào upscale từ pha trước (poll/gen) → cho generate chạy vọt
        // lên 100% (báo xong pha 1), rồi reset 0 để upscale bò lại từ đầu.
        var enteringUpscale = s.indexOf("upscal") >= 0 && root.progressStatusKey.length > 0
        root.progressStatusKey = s
        if (enteringUpscale) {
            root.shownProgress = 100
            upscaleResetTimer.restart()
            return
        }
        root.shownProgress = root.targetProgress
    }
    Behavior on shownProgress {
        enabled: root.animationsEnabled && root.progressAnimReady && !root.progressSnap && VfTheme.motion
        NumberAnimation { duration: 360; easing.type: Easing.OutCubic }
    }

    // Sau khi generate chạy vọt 100%, reset bar về 0 (tức thời) rồi để upscale
    // bò 0→99 theo ETA upsampler.
    Timer {
        id: upscaleResetTimer
        interval: 520
        repeat: false
        onTriggered: {
            root.progressSnap = true
            root.shownProgress = 0
            root.progressSnap = false
            root.shownProgress = root.targetProgress
        }
    }

    Component.onCompleted: {
        root.shownProgress = root.displayProgress()
        root.progressAnimReady = true
    }

    function subtitleText() {
        if (root.modelSubtitle.length > 0)
            return root.modelSubtitle
        var value = firstText(row.progress_message || row.error_message || row.message || row.status_message || "")
        if (value.length > 0)
            return value
        if (root.isBatchImageRow()) {
            var cfg = (row && row.config) ? row.config : ({})
            var model = firstText(row.model || cfg.model || "")
            var ratio = firstText(row.aspect_ratio || cfg.aspect_ratio || "")
            var resolution = firstText(row.resolution || cfg.resolution || "")
            var variations = Number(row.variations || cfg.variations || 0)
            var parts = []
            if (model.length > 0)
                parts.push(model)
            if (ratio.length > 0)
                parts.push(ratio)
            if (resolution.length > 0)
                parts.push(resolution)
            if (variations > 0)
                parts.push("x" + String(variations))
            return parts.join(" / ")
        }
        if (root.videoPath().length > 0)
            return root.fileName(root.videoPath())
        return ""
    }

    // Nhãn độ phân giải pha upscale ("4K"/"2K"/"1080p"...) từ resolution/upscale_model.
    function upscaleResolutionLabel() {
        var res = firstText(row.resolution || row.upscale_resolution)
        if (res.length === 0) {
            var um = firstText(row.upscale_model).toUpperCase()
            if (um.indexOf("4K") >= 0 || um.indexOf("RESOLUTION_4") >= 0) res = "4K"
            else if (um.indexOf("2K") >= 0 || um.indexOf("RESOLUTION_2") >= 0) res = "2K"
        }
        if (res.length === 0)
            return ""
        var r = res.toUpperCase()
        if (r.indexOf("4K") >= 0 || r.indexOf("RESOLUTION_4") >= 0 || r === "UHD") return "4K"
        if (r.indexOf("2K") >= 0 || r.indexOf("RESOLUTION_2") >= 0) return "2K"
        if (r.indexOf("1080") >= 0) return "1080p"
        if (r.indexOf("720") >= 0) return "720p"
        return res
    }

    function statusText() {
        if (root.modelStatusText.length > 0)
            return root.modelStatusText
        // status_label chỉ là nhãn đẹp khi nó KHÁC raw status; nếu bị copy nguyên
        // từ raw status ("polling"/"generating") thì bỏ qua, map qua keyword bên dưới.
        var rawStatus = firstText(row.status)
        var label = firstText(row.status_label)
        if (label.length > 0 && label.toLowerCase() !== rawStatus.toLowerCase())
            return label

        var status = root.statusKey()
        if (status.indexOf("complete") >= 0 || status === "done")
            return (void i18n.revision, i18n.t("job_panel.status_completed", "Completed"))
        if (status.indexOf("fail") >= 0 || status.indexOf("error") >= 0 || status.indexOf("cancel") >= 0)
            return (void i18n.revision, i18n.t("job_panel.status_failed", "Failed"))
        if (status.indexOf("upscal") >= 0) {
            var upRes = root.upscaleResolutionLabel()
            if (upRes.length > 0)
                return (void i18n.revision, i18n.t("job_panel.status_upscale", "Upscale")) + " " + upRes
            return (void i18n.revision, i18n.t("job_panel.status_upscaling", "Upscaling"))
        }
        // Polling/running = vẫn đang generate (đã tính vào % theo time) → "Generating".
        // "running" = queue batch just advanced (gối đầu) before dispatcher job id lands.
        if (status.indexOf("generat") >= 0 || status.indexOf("process") >= 0 || status.indexOf("poll") >= 0 || status.indexOf("running") >= 0)
            return (void i18n.revision, i18n.t("job_panel.status_generating", "Generating"))
        if (status.indexOf("retry") >= 0)
            return (void i18n.revision, i18n.t("job_panel.status_retrying", "Retrying"))
        // Pending/Queued = waiting its turn in the chain → "Đang chuẩn bị"
        // (1 nhãn rõ ràng thay vì Pending/Queued rời rạc, đỡ trông đơ).
        if (status.indexOf("queue") >= 0 || status.indexOf("pending") >= 0)
            return (void i18n.revision, i18n.t("job_panel.status_preparing", "Preparing"))
        return (void i18n.revision, i18n.t("job_panel.status_preparing", "Preparing"))
    }

    function statusChipText() {
        if (root.modelStatusChipText.length > 0) {
            // modelStatusChipText là chuỗi Python-side với % RAW tĩnh (mốc
            // 20/60 server set). Khi đang gen + có ETA → thay phần % bằng %
            // synthesize theo thời gian của card (shownProgress) để chip bò.
            if (root.isGeneratingState && root.shouldSynthesizeGenerateProgress())
                return root.modelStatusChipText.replace(/\d+\s*%/, root.progressText() + "%")
            return root.modelStatusChipText
        }
        if (root.isBatchImageRow()) {
            var status = root.statusKey()
            var pct = root.progressText() + "%"
            if (status.indexOf("upscal") >= 0)
                return "Upscale " + pct
            if (status.indexOf("generat") >= 0 || status.indexOf("process") >= 0 || status.indexOf("poll") >= 0)
                return "Gen " + pct
            if (status.indexOf("complete") >= 0 || status === "done")
                return "Done " + pct
            if (status.indexOf("fail") >= 0 || status.indexOf("error") >= 0 || status.indexOf("cancel") >= 0)
                return "Fail " + pct
            if (status.indexOf("retry") >= 0)
                return "Retry " + pct
            return pct
        }
        return root.statusText() + " " + root.progressText() + "%"
    }

    function statusKey() {
        if (root.modelStatus.length > 0)
            return root.modelStatus.toLowerCase()
        return firstText(row.status || row.state || row.status_label || "pending").toLowerCase()
    }

    function statusColor() {
        var status = root.statusKey()
        if (status.indexOf("complete") >= 0 || status === "done")
            return "#059669"
        if (status.indexOf("fail") >= 0 || status.indexOf("error") >= 0 || status.indexOf("cancel") >= 0)
            return "#DC2626"
        if (status.indexOf("upscal") >= 0)
            return "#7C3AED"
        if (status.indexOf("generat") >= 0 || status.indexOf("process") >= 0 || status.indexOf("poll") >= 0 || status.indexOf("running") >= 0)
            return "#2563EB"
        if (status.indexOf("retry") >= 0)
            return "#D97706"
        return VfTheme.textSubtle
    }

    function rowValue(key) {
        if (row && row[key] !== undefined && row[key] !== null && String(row[key]).length > 0)
            return row[key]
        return ""
    }

    function firstRowValue(keys) {
        for (var i = 0; i < keys.length; i++) {
            var value = root.rowValue(keys[i])
            if (value !== undefined && value !== null && String(value).length > 0)
                return String(value)
        }
        return ""
    }

    function rowId() {
        return root.jobId.length > 0 ? root.jobId : root.firstRowValue(["id", "row_id", "job_id", "batch_id"])
    }

    function mediaId() {
        if (root.modelMediaId.length > 0)
            return root.modelMediaId
        if (root.isBatchImageRow()) {
            var imageId = root.batchImageUpscaleId()
            if (imageId.length > 0)
                return imageId
        }
        return root.firstRowValue(["media_id", "video_media_id", "veo_media_id"])
    }

    function aspectRatio() {
        if (root.modelAspectRatio.length > 0)
            return root.modelAspectRatio
        return root.firstRowValue(["aspect_ratio", "aspect"]) || "VIDEO_ASPECT_RATIO_LANDSCAPE"
    }

    function tierMode() {
        return (root.modelTierMode.length > 0 ? root.modelTierMode : (root.firstRowValue(["tier_mode", "account_tier_mode"]) || "ultra")).toLowerCase()
    }

    function videoPath() {
        if (root.modelVideoPath.length > 0)
            return root.modelVideoPath
        return root.firstRowValue([
            "upscaled_path",
            "video_path",
            "merged_output_path",
            "merged_video_path",
            "auto_merge_output",
            "final_merged_path",
            "output_path",
            "downloaded_video_path",
            "result_path",
        ])
    }

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

    function fileName(value) {
        var raw = String(value || "").replace(/\\/g, "/")
        if (raw.length === 0)
            return ""
        return raw.split("/").pop()
    }

    function isImagePath(value) {
        var lower = String(value || "").toLowerCase()
        return lower.endsWith(".png")
            || lower.endsWith(".jpg")
            || lower.endsWith(".jpeg")
            || lower.endsWith(".webp")
            || lower.endsWith(".bmp")
            || lower.endsWith(".gif")
            || lower.indexOf("data:image/") === 0
    }

    function looksLikeBase64(value) {
        var text = String(value || "").trim()
        if (text.length < 80)
            return false
        var allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=\r\n"
        for (var index = 0; index < Math.min(text.length, 256); index++) {
            if (allowed.indexOf(text[index]) < 0)
                return false
        }
        return true
    }

    function imageSourceFromValue(value) {
        var raw = String(value || "").trim()
        if (raw.length === 0)
            return ""
        var resolved = MediaSourceResolver.normalizedImageSource(raw)
        if (resolved.length > 0)
            return resolved
        return root.isImagePath(raw) ? root.fileUrl(raw) : ""
    }

    // Width/height ratio of the job's output. The outer thumbnail frame stays
    // 16:9; this remains available for metadata/actions without driving layout.
    function thumbnailAspect() {
        var s = String(root.modelAspectRatio || root.firstRowValue(["aspect_ratio", "aspect", "output_aspect_ratio"]) || "").toUpperCase()
        if (s.indexOf("PORTRAIT") >= 0 || s === "9:16")
            return 9 / 16
        if (s === "3:4")
            return 3 / 4
        if (s === "1:1" || s.indexOf("SQUARE") >= 0)
            return 1.0
        if (s === "4:3" || s.indexOf("FOUR_THREE") >= 0)
            return 4 / 3
        return 16 / 9
    }

    function thumbnailSource() {
        if (root.modelThumbnailUrl.length > 0)
            return root.imageSourceFromValue(root.modelThumbnailUrl)
        var candidates = [
            root.firstRowValue(["thumbnail_url", "thumbnail_path", "thumb_path", "thumbnail", "thumbnail_base64", "preview_image"]),
            root.firstRowValue(["preview_path"]),
        ]
        for (var i = 0; i < candidates.length; i++) {
            var source = root.imageSourceFromValue(candidates[i])
            if (source.length > 0)
                return source
        }
        return ""
    }

    function batchImageUpscaleId() {
        if (root.modelMediaId.length > 0)
            return root.modelMediaId
        if (root.modelSourceMediaName.length > 0)
            return root.modelSourceMediaName
        var sourceId = root.modelSourceMediaId.length > 0
            ? root.modelSourceMediaId
            : root.firstRowValue(["source_media_id", "veo_media_id", "mediaId", "google_media_id"])
        if (sourceId.length > 0)
            return sourceId
        return root.firstRowValue(["mediaName", "media_name", "veo_media_name", "google_media_name", "upscale_media_id", "media_id"])
    }

    function batchImageOutputPath() {
        return root.modelOutputPath.length > 0
            ? root.modelOutputPath
            : root.firstRowValue(["file_path", "path", "thumbnail_path", "thumbnail_url", "output_path"])
    }

    function currentImageResolution() {
        return root.modelCurrentResolution.length > 0
            ? root.modelCurrentResolution
            : root.firstRowValue(["upscale_resolution", "resolution", "target_resolution", "quality"])
    }

    function imageResolutionRank(value) {
        var raw = String(value || "").toLowerCase()
        if (raw.indexOf("4k") >= 0 || raw.indexOf("resolution_4") >= 0)
            return 2
        if (raw.indexOf("2k") >= 0 || raw.indexOf("resolution_2") >= 0)
            return 1
        return 0
    }

    function nextImageUpscaleResolution() {
        return root.imageResolutionRank(root.currentImageResolution()) >= 1 ? "4k" : "2k"
    }

    function assetList() {
        var modelAssets = root.firstArrayValue([root.modelAssetPreviews])
        if (modelAssets.length > 0)
            return modelAssets
        return root.firstArrayValue([
            row.assets,
            row.reference_previews,
            row.input_asset_items,
            row.input_assets,
            row.start_images,
            row.reference_images,
            row.reference_paths,
            row.asset_paths,
            row.reference_image_ids,
            row.reference_ids,
            row.refs,
        ])
    }

    // Shared structured asset slots: model-aware count, placeholders, and overflow scroll.
    // Image-GENERATION jobs (still out, not upscale) build each image from up to 10 refs —
    // mirror job_panel_list_model._is_image_gen_row so the fallback path agrees with the model.
    function isImageGenRow() {
        var meta = (row && row.meta) ? row.meta : ({})
        var feature = String(row.feature || row.type || row.tab_source || row.route || row.mode_key || "").toLowerCase()
        var dispatchFeature = String(meta.dispatch_feature || row.dispatch_feature || meta.feature || "").toLowerCase()
        if (feature.indexOf("upscale") >= 0 || dispatchFeature.indexOf("upscale") >= 0)
            return false
        return feature.indexOf("image_generation") >= 0
            || feature.indexOf("batch_image") >= 0
            || dispatchFeature.indexOf("transcript_image") >= 0
            || dispatchFeature.indexOf("clone_image") >= 0
            || dispatchFeature.indexOf("image_generation") >= 0
    }

    function isStillImageOutputRow() {
        // The list model owns output-kind classification. Transcript/Clone image
        // scene rows intentionally keep their tab feature (for example
        // `transcript_video`) while the narrow `kind` role is `IMG`. Re-reading
        // row.feature here therefore misroutes a valid image click to the video
        // output resolver. Keep row inspection only as compatibility fallback for
        // plain-array/tour cards that do not expose modelKind.
        if (String(root.modelKind || "").toUpperCase() === "IMG")
            return true
        return root.isImageGenRow() || root.isBatchImageRow()
    }

    function resolvedMaxRefs() {
        var cfg = (row && row.config) ? row.config : ({})
        var feature = String(row.feature || row.type || row.tab_source || row.route || "").toLowerCase()
        if (feature.indexOf("voice") >= 0 || feature.indexOf("audio") >= 0)
            return 0
        // Image-generation cards get the full 10 ref slots — checked BEFORE `explicit`
        // so a stale video-default (max_image_inputs=7) can't cap an image job at 7.
        if (root.isImageGenRow())
            return 10
        var explicit = Number(cfg.max_image_inputs || row.max_image_inputs || 0)
        if (explicit > 0)
            return Math.max(1, Math.min(7, explicit))
        var model = String(cfg.model_key || row.model_key || "").toLowerCase()
        if (model.indexOf("abra") >= 0 || model.indexOf("omni") >= 0)
            return 7
        return 3
    }

    function isMultiAssetSlots() {
        var cfg = (row && row.config) ? row.config : ({})
        if (cfg.multi_asset_mode || cfg.multi_asset_enabled)
            return true
        var info = cfg.multi_asset_info
        return Boolean(info && info.assets && info.assets.length > 0)
    }

    function _refAssets() {
        var cfg = (row && row.config) ? row.config : ({})
        var info = (row && row.multi_asset_info) || cfg.multi_asset_info
        if (info && info.assets && info.assets.length > 0)
            return root.firstArrayValue([info.assets])
        return root.assetList()
    }

    function assetSlotType(asset) {
        if (asset && typeof asset === "object") {
            var typeName = String(asset.asset_type || asset.type || asset.kind || "").toLowerCase()
            if (typeName === "character")
                return "character"
        }
        return "object"
    }

    function assetSlots() {
        var modelSlots = root.firstArrayValue([root.modelAssetSlots])
        if (modelSlots.length > 0)
            return modelSlots
        // One ordered strip for every route; overflow scrolls horizontally.
        var max = root.resolvedMaxRefs()
        var all = root._refAssets()
        if (max <= 0 && all.length > 0)
            max = Math.min(7, all.length)
        var slotCount = Math.max(max, all.length)
        var slots = []
        for (var i = 0; i < all.length; i++) {
            var asset = all[i] || null
            slots.push({ slotType: root.assetSlotType(asset), slotIndex: i, asset: asset, filled: Boolean(asset) })
        }
        for (var p = all.length; p < slotCount; p++)
            slots.push({ slotType: "object", slotIndex: p, asset: null, filled: false })
        return slots
    }

    function slotBadge(slotType) {
        return slotType === "character" ? "👤" : "📦"
    }

    function slotPreviewSource(slot, index) {
        if (!slot)
            return ""
        var projectedSource = String(slot.previewSrc || slot.preview_src || "")
        if (projectedSource.length > 0)
            return root.imageSourceFromValue(projectedSource)
        if (!slot.asset)
            return ""
        var source = root.assetPreviewSource(slot.asset)
        if (source.length > 0)
            return source
        return ""
    }

    function slotAt(index) {
        var assets = root.displayAssets
        if (!assets || assets.length <= index)
            return ({})
        var slot = assets[index]
        return slot && typeof slot === "object" ? slot : ({ asset: slot })
    }

    function assetAt(index) {
        var slot = root.slotAt(index)
        if (slot && typeof slot === "object" && slot.asset !== undefined)
            slot = slot.asset
        if (slot && typeof slot === "object")
            return slot
        return { path: String(slot || "") }
    }

    function assetPreviewSource(asset) {
        if (!asset || asset.overflow)
            return ""
        if (typeof asset === "string")
            return root.imageSourceFromValue(asset)
        return MediaSourceResolver.imageSource(asset)
    }

    // The strip intentionally displays a lightweight thumbnail, while the
    // in-app lightbox resolves the original/local image first. Older persisted
    // rows may only contain a thumbnail; slotPreviewSource remains their safe
    // fallback without handing the click to the operating-system viewer.
    function slotLightboxSource(index) {
        var slot = root.slotAt(index)
        var original = root.imageSourceFromValue(String(slot.path || ""))
        if (original.length > 0)
            return original

        var asset = root.assetAt(index)
        if (asset && typeof asset === "string") {
            original = root.imageSourceFromValue(asset)
        } else if (asset && !asset.overflow) {
            original = MediaSourceResolver.previewImageSource(asset)
        }
        if (original.length > 0)
            return original
        return root.slotPreviewSource(slot, index)
    }

    function slotLightboxTitle(index) {
        var slot = root.slotAt(index)
        var asset = root.assetAt(index)
        var title = String(
            slot.title
            || slot.name
            || (asset || {}).title
            || (asset || {}).name
            || ""
        ).trim()
        if (title.length > 0)
            return title
        var path = root.assetPath(index)
        return root.fileName(path) || ("Asset " + String(index + 1))
    }

    function assetPath(index) {
        var slot = root.slotAt(index)
        var projectedPath = String(slot.path || slot.previewSrc || slot.preview_src || "")
        if (projectedPath.length > 0)
            return projectedPath
        var asset = root.assetAt(index)
        if (!asset || asset.overflow)
            return ""
        return String(asset.path || asset.image_path || asset.video_path || asset.preview_path || asset.file_path || "")
    }

    function assetMediaId(index) {
        var slot = root.slotAt(index)
        var projectedMediaId = String(slot.mediaId || slot.media_id || "")
        if (projectedMediaId.length > 0)
            return projectedMediaId
        var asset = root.assetAt(index)
        if (!asset || asset.overflow)
            return ""
        return String(asset.media_id || asset.id || asset.veo_media_id || "")
    }

    function assetLabel(index) {
        var slot = root.slotAt(index)
        var projectedLabel = String(slot.label || "")
        if (projectedLabel.length > 0)
            return projectedLabel
        var asset = root.assetAt(index)
        if (asset && asset.overflow)
            return "+" + String(asset.count || 0)
        if (asset && typeof asset === "string")
            return root.fileName(asset) || ("A" + String(index + 1))

        var name = String((asset || {}).name || "")
        if (name.length > 0) {
            var compactName = name.trim()
            if (compactName.length <= 4)
                return compactName.toUpperCase()
            return compactName.split(/\s+/)[0].slice(0, 4).toUpperCase()
        }

        var media = root.assetMediaId(index)
        if (media.length > 0) {
            var parts = media.toUpperCase().split("_")
            return parts.length > 0 ? parts[0] : media.slice(0, 4)
        }

        var path = root.assetPath(index)
        if (path.length > 0) {
            var file = root.fileName(path)
            if (file.length > 0)
                return file.slice(0, 4).toUpperCase()
        }
        return "A" + String(index + 1)
    }

    function assetTone(index) {
        var media = root.assetMediaId(index).toUpperCase()
        if (media.indexOf("CHAR") === 0)
            return VfTheme.blueFill
        if (media.indexOf("VOICE") === 0)
            return VfTheme.pinkFill
        if (media.indexOf("SET") === 0 || media.indexOf("LIGHT") === 0 || media.indexOf("CAM") === 0)
            return VfTheme.greenFill
        return VfTheme.amberFill
    }

    function assetPreviewPayload(index) {
        var path = root.assetPath(index)
        var media = root.assetMediaId(index)
        return {
            row_id: root.rowId(),
            slot_index: index,
            slot_label: "Asset " + String(index + 1),
            title: root.fileName(path) || media || ("Asset " + String(index + 1)),
            row_title: root.titleText(),
            media_id: root.mediaId() || media,
            asset_media_id: media,
            preview_path: path || root.videoPath(),
            path: path || root.videoPath(),
            original_path: root.videoPath() || path,
            aspect_ratio: root.aspectRatio(),
            can_reupscale: root.canReupscale()
        }
    }

    function assetPreviewContract(index) {
        var preview = root.assetPreviewPayload(index)
        var controller = root.controllerObject()
        if (controller && controller.getRowAssetPreview) {
            try {
                var result = controller.getRowAssetPreview(root.rowId(), index)
                if (result)
                    preview = result
            } catch (err) {
            }
        }
        return preview
    }

    function reupscalePayload() {
        if (root.isBatchImageRow()) {
            return {
                is_image: true,
                image_upscale: true,
                media_id: root.batchImageUpscaleId(),
                source_media_id: root.modelSourceMediaId || root.firstRowValue(["source_media_id", "veo_media_id", "mediaId", "google_media_id"]),
                source_media_name: root.modelSourceMediaName || root.firstRowValue(["mediaName", "media_name", "veo_media_name", "google_media_name", "upscale_media_id"]),
                current_resolution: root.currentImageResolution(),
                resolution: root.nextImageUpscaleResolution(),
                original_path: root.batchImageOutputPath(),
                output_folder: root.modelOutputFolder || root.firstRowValue(["output_folder"]),
                aspect_ratio: root.aspectRatio(),
                tier_mode: root.tierMode(),
                title: root.titleText(),
                source_job_id: root.rowId(),
                tab_source: root.firstText(row.tab_source || row.route || row.feature || row.type) || "batch_image_generation",
                route: root.firstText(row.route || row.tab_source || row.feature || row.type) || "batch",
                account_name: root.modelAccountName || root.firstRowValue(["account_name", "profile_name"]),
                account_email: root.modelAccountEmail || root.firstRowValue(["account_email", "worker_account", "email"]),
                dry_run: true
            }
        }
        return {
            media_id: root.mediaId(),
            resolution: "1080p",
            original_path: root.videoPath(),
            aspect_ratio: root.aspectRatio(),
            tier_mode: root.tierMode(),
            title: root.titleText(),
            source_job_id: root.rowId(),
            tab_source: root.firstText(row.tab_source || row.route || row.feature || row.type) || "reupscale",
            route: root.firstText(row.route || row.tab_source || row.feature || row.type) || "reupscale",
            dry_run: true
        }
    }

    function reupscaleOptions() {
        if (root.isBatchImageRow()) {
            if (root.tierMode() === "premium") {
                return {
                    ok: true,
                    tier_mode: "premium",
                    start_enabled: false,
                    resolutions: [{ label: "Upscale not available for Premium", value: "none", disabled: true }],
                    blocker: { code: "premium_tier_not_supported", message: "Upscale requires an Ultra account." }
                }
            }
            if (root.batchImageUpscaleId().length === 0) {
                return {
                    ok: true,
                    tier_mode: root.tierMode(),
                    start_enabled: false,
                    resolutions: [{ label: "Missing image media id", value: "none", disabled: true }],
                    blocker: { code: "image_media_id_required", message: "This image has no Google media id for upscale." }
                }
            }
            var currentRank = root.imageResolutionRank(root.currentImageResolution())
            if (currentRank >= 2) {
                return {
                    ok: true,
                    tier_mode: root.tierMode(),
                    start_enabled: false,
                    resolutions: [{ label: "Already 4K", value: "none", disabled: true }],
                    blocker: { code: "image_already_4k", message: "This image is already 4K." }
                }
            }
            var resolutions = []
            if (currentRank < 1)
                resolutions.push({ label: "2K", value: "2k" })
            if (currentRank < 2)
                resolutions.push({ label: "4K", value: "4k" })
            return {
                ok: true,
                tier_mode: root.tierMode(),
                start_enabled: resolutions.length > 0,
                resolutions: resolutions,
                blocker: null
            }
        }
        if (root.tierMode() === "premium") {
            return {
                ok: true,
                tier_mode: "premium",
                start_enabled: false,
                resolutions: [{ label: "Upscale not available for Premium", value: "none", disabled: true }],
                blocker: { code: "premium_tier_not_supported", message: "Upscale requires an Ultra account." }
            }
        }
        return {
            ok: true,
            tier_mode: root.tierMode(),
            start_enabled: true,
            resolutions: [{ label: "1080p (HD)", value: "1080p" }, { label: "4K (Ultra HD)", value: "4k" }],
            blocker: null
        }
    }

    function canRegenerate() {
        if (root.modelCanRetry >= 0)
            return root.modelCanRetry > 0
        if (root.isBatchImageRow())
            return false
        var status = root.statusKey()
        var hasRunBefore = root.videoPath().length > 0 || root.firstText(root.rowValue("error_message") || "").length > 0 || status.indexOf("fail") >= 0 || status.indexOf("error") >= 0
        var isTerminal = status.indexOf("fail") >= 0 || status.indexOf("error") >= 0 || status.indexOf("complete") >= 0 || status === "done"
        return hasRunBefore && isTerminal
    }

    function canReupscale() {
        if (root.modelCanUpscale >= 0)
            return root.modelCanUpscale > 0
        var status = root.statusKey()
        var phase = root.firstText(root.rowValue("phase") || "").toLowerCase()
        if (root.isBatchImageRow()) {
            var batchCompleted = status.indexOf("complete") >= 0 || status === "done"
            var batchFailedUpscale = (status.indexOf("fail") >= 0 || status.indexOf("error") >= 0) && phase.indexOf("upscale") >= 0
            return root.batchImageUpscaleId().length > 0
                && root.tierMode() !== "premium"
                && root.imageResolutionRank(root.currentImageResolution()) < 2
                && (batchCompleted || batchFailedUpscale)
        }
        var hasMediaId = root.mediaId().length > 0
        var hasVideo = root.videoPath().length > 0
        var isCompleted = status.indexOf("complete") >= 0 || status === "done"
        var isFailedUpscale = (status.indexOf("fail") >= 0 || status.indexOf("error") >= 0) && phase.indexOf("upscale") >= 0
        return hasMediaId && (isCompleted || isFailedUpscale || hasVideo)
    }

    function canEdit() {
        return root.modelCanEdit < 0 || root.modelCanEdit > 0
    }

    function canDelete() {
        return root.modelCanDelete < 0 || root.modelCanDelete > 0
    }

    function controllerObject() {
        try {
            if (typeof workPanelController !== "undefined")
                return workPanelController
        } catch (err) {
        }
        try {
            if (typeof masterController !== "undefined")
                return masterController
        } catch (err) {
        }
        return null
    }

    function reupscaleDialogItem() {
        reupscaleDialogLoader.active = true
        return reupscaleDialogLoader.item
    }

    function applyReupscaleResult(result) {
        var dialog = reupscaleDialogLoader.item
        if (dialog && dialog.applyResult)
            dialog.applyResult(result)
    }

    function submitReupscalePayload(payload) {
        root.reupscaleRequested(root.row, payload)
        var controller = root.controllerObject()
        if (!controller || !controller.submitReupscaleDryRun) {
            root.applyReupscaleResult({
                ok: false,
                dry_run: true,
                accepted: false,
                blocker: { code: "controller_unavailable", message: "workPanelController.submitReupscaleDryRun is not available." },
                validation: { request: payload, errors: [], warnings: [] }
            })
            return
        }
        try {
            root.applyReupscaleResult(controller.submitReupscaleDryRun(payload))
        } catch (err) {
            root.applyReupscaleResult({
                ok: false,
                dry_run: true,
                accepted: false,
                blocker: { code: "controller_call_failed", message: String(err) },
                validation: { request: payload, errors: [], warnings: [] }
            })
        }
    }

    function startReupscalePayload(payload) {
        root.reupscaleRequested(root.row, payload)
        var controller = root.controllerObject()
        if (!controller || !controller.submitReupscaleStart) {
            return {
                ok: false,
                dry_run: false,
                accepted: false,
                blocker: {
                    code: "controller_unavailable",
                    message: "workPanelController.submitReupscaleStart is not available."
                }
            }
        }
        try {
            return controller.submitReupscaleStart(payload)
        } catch (err) {
            return {
                ok: false,
                dry_run: false,
                accepted: false,
                blocker: {
                    code: "controller_call_failed",
                    message: String(err)
                }
            }
        }
    }

    function typeText() {
        if (root.modelKind.length > 0)
            return root.modelKind
        if (root.isBatchImageRow())
            return "IMG"
        var cardType = firstText(row.card_type || row.job_type).toUpperCase()
        var feature = firstText(row.feature || row.type || row.tab_source || row.route || row.mode_key).toLowerCase()
        // Placeholder queue rows often lack feature=extend_video; card_type EXTEND is the truth.
        if (cardType === "EXTEND" || feature.indexOf("extend") >= 0 || row.is_extend
                || firstText(row.mode_key).toLowerCase() === "extend")
            return "EXT"
        if (feature.indexOf("image") >= 0)
            return "I2V"
        // Badge theo MODE THẬT của scene job — KHÔNG hardcode theo TAB (clone/transcript/normal
        // đều có thể T2V hoặc R2V per-scene tuỳ có nhân vật hay không). Ưu tiên MODEL_KEY đã
        // resolve của job: key có 'r2v'→R2V, 'i2v'/image→I2V, còn lại T2V. (Bug cũ: clone LUÔN
        // badge R2V dù dispatch T2V — Bố phát hiện qua log mode=t2v.)
        var mk = firstText(row.video_model_key || row.model_key || row.model).toLowerCase()
        if (mk.indexOf("r2v") >= 0)
            return "R2V"
        if (mk.indexOf("i2v") >= 0 || mk.indexOf("image_to_video") >= 0)
            return "I2V"
        // CHỈ tin key khi nó KHAI MODE rõ ('t2v' trong tên). Key generic không khai
        // mode ('veo2'…) mà chốt T2V luôn là BUG 23/7: job affiliate multi_asset (R2V,
        // dispatch_feature='multi_asset_video') bị dán nhãn T2V vì nhánh này nuốt
        // trước khi kịp soi dispatch_feature bên dưới.
        if (mk.indexOf("t2v") >= 0)
            return "T2V"
        // Key trống/generic: suy từ reference/asset thật.
        var df = String(row.dispatch_feature || "").toLowerCase()
        if (df.indexOf("asset") >= 0 || df.indexOf("reference") >= 0 || df.indexOf("r2v") >= 0)
            return "R2V"
        var mai = row.multi_asset_info
        if (mai && mai.assets && mai.assets.length > 0)
            return "R2V"
        if (feature.indexOf("asset") >= 0 || feature.indexOf("reference") >= 0)
            return "R2V"
        return "T2V"
    }

    function thumbnailPlaceholderText() {
        if (root.modelThumbnailPlaceholder.length > 0)
            return root.modelThumbnailPlaceholder
        if (root.isBatchImageRow()) {
            var status = root.statusKey()
            if ((status.indexOf("complete") >= 0 || status === "done") && root.thumbnailSourceValue.length === 0)
                return "FINALIZING PREVIEW"
            if (status.indexOf("complete") >= 0 || status === "done")
                return ""
            if (status.indexOf("generat") >= 0 || status.indexOf("process") >= 0 || status.indexOf("upscal") >= 0)
                return "GENERATING..."
            return ""
        }
        if (root.videoPath().length > 0)
            return "VIDEO READY"
        if (root.isGeneratingState)
            return "GENERATING..."
        var pstatus = root.statusKey()
        if (pstatus.indexOf("pending") >= 0 || pstatus.indexOf("queue") >= 0)
            return (void i18n.revision, i18n.t("job_panel.status_preparing", "Preparing"))
        return (void i18n.revision, i18n.t("job_panel.waiting", "WAITING..."))
    }

    component JobActionButton: VfButton {
        minWidth: 0
        showLeadingIcon: false
        implicitHeight: root.actionButtonHeight
        leftPadding: VfTheme.dp(8)
        rightPadding: VfTheme.dp(8)
        font.weight: Font.DemiBold
    }

    component AssetTile: Rectangle {
        id: assetTile

        property int slotIndex: -1
        property var slot: ({})
        readonly property string slotType: String((slot || {}).slotType || "object")
        readonly property string previewSrc: root.slotPreviewSource(slot, slotIndex)
        readonly property bool hasPayload: Boolean(previewSrc.length > 0 || root.assetPath(slotIndex).length > 0 || root.assetMediaId(slotIndex).length > 0)

        width: root.assetSize
        height: root.assetSize
        radius: VfTheme.dp(8)
        color: VfTheme.surface
        border.color: previewImage.visible && assetTile.slotType === "character" ? VfTheme.violetBorderSoft : VfTheme.borderStrong
        border.width: 1
        clip: true

        // Nền ô trống (placeholder) theo loại slot
        Rectangle {
            anchors.fill: parent
            visible: !previewImage.visible
            radius: parent.radius
            color: VfTheme.surfaceSoft
        }

        Image {
            id: previewImage
            anchors.fill: parent
            source: root.mediaHydrationEnabled ? assetTile.previewSrc : ""
            fillMode: Image.PreserveAspectCrop
            visible: String(source).length > 0
            asynchronous: true
            cache: true
            sourceSize.width: 80
            sourceSize.height: 80
        }

        Text {
            anchors.centerIn: parent
            visible: !previewImage.visible && assetTile.hasPayload
            text: root.assetLabel(assetTile.slotIndex)
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(9)
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            maximumLineCount: 1
            width: parent.width - VfTheme.dp(4)
        }

        // Ô trống: dấu +
        Text {
            anchors.centerIn: parent
            visible: false
            text: "+"
            color: VfTheme.textSubtle
            font.pixelSize: VfTheme.dp(16)
            font.weight: Font.Bold
        }

        // Badge góc trên-trái: 👤 character / 📦 object
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: VfTheme.dp(2)
            visible: assetTile.hasPayload && root.slotBadge(assetTile.slotType).length > 0
            width: VfTheme.dp(13)
            height: VfTheme.dp(13)
            radius: VfTheme.dp(3)
            color: VfTheme.surface
            opacity: 0.9
            border.color: assetTile.slotType === "character" ? VfTheme.violetBorderSoft : VfTheme.borderStrong
            Text {
                anchors.centerIn: parent
                text: root.slotBadge(assetTile.slotType)
                font.pixelSize: VfTheme.dp(8)
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: assetTile.hasPayload
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            // Click ô slot luôn xem nhanh trong Job Panel. Chỉ khi payload không
            // có bất kỳ nguồn ảnh nào mới chuyển về controller để route tự xử lý.
            onClicked: {
                var source = root.slotLightboxSource(assetTile.slotIndex)
                if (source.length > 0) {
                    root.assetPreviewRequested(source, root.slotLightboxTitle(assetTile.slotIndex))
                    return
                }
                root.commandRequested("job_panel.asset", root.rowId(), assetTile.slotIndex)
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: root.contentMargin

        Item {
            id: topArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: root.topAreaHeight

            Rectangle {
                id: thumbnailFrame
                width: root.thumbnailWidth
                height: root.thumbnailHeight
                anchors.left: parent.left
                anchors.top: parent.top
                radius: VfTheme.dp(12)
                color: VfTheme.border
                border.color: VfTheme.borderStrong
                clip: true

                gradient: Gradient {
                    GradientStop { position: 0.0; color: VfTheme.borderStrong }
                    GradientStop { position: 1.0; color: VfTheme.textSubtle }
                }

                Image {
                    id: thumbnailImage
                    anchors.fill: parent
                    source: root.mediaHydrationEnabled ? root.thumbnailSourceValue : ""
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    visible: String(source).length > 0
                    asynchronous: true
                    cache: true
                    sourceSize.width: Math.ceil(root.thumbnailWidth * 1.5)
                    sourceSize.height: Math.ceil(root.thumbnailHeight * 1.5)
                }

                // Generating: nền theo theme + 2 dải "aurora" xanh/tím trôi chéo
                // lệch pha + 1 sweep line mảnh — thay gradient trắng chớp nhoáng cũ.
                // Dark: nền navy tối. Light: nền xanh-ghi sáng để không lệch tông.
                Rectangle {
                    id: workingPulse
                    anchors.fill: parent
                    visible: root.showWorkingPlaceholder && !thumbnailImage.visible
                    radius: parent.radius
                    color: VfTheme.dark ? Qt.rgba(0.06, 0.09, 0.17, 0.92)
                                        : Qt.rgba(0.89, 0.92, 0.97, 0.95)
                    clip: true

                    // AURORA (bản gốc 3 lớp): 2 dải xanh/tím trôi chéo lệch pha + 1 sweep
                    // mảnh. Gradient oversized → luôn phủ kín, không gap/restart. Giờ panel
                    // bound-N (chỉ N card/trang) nên 3 lớp động RẺ. animationsEnabled=false
                    // (lightweight) → chỉ nền tĩnh. running tắt khi placeholder ẩn → 0 phí.
                    Rectangle {
                        id: wpBlue
                        width: workingPulse.width * 1.4; height: workingPulse.height * 1.1
                        y: -workingPulse.height * 0.05
                        rotation: -16; opacity: 0.6
                        visible: root.animationsEnabled
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.45; color: VfTheme.dark ? Qt.rgba(0.23, 0.51, 0.96, 0.40) : Qt.rgba(0.23, 0.51, 0.96, 0.22) }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                        SequentialAnimation on x {
                            running: workingPulse.visible && root.animationsEnabled && VfTheme.motion
                            loops: Animation.Infinite
                            NumberAnimation { from: -wpBlue.width * 0.9; to: workingPulse.width * 0.5; duration: 2600; easing.type: Easing.InOutSine }
                            NumberAnimation { from: workingPulse.width * 0.5; to: -wpBlue.width * 0.9; duration: 2600; easing.type: Easing.InOutSine }
                        }
                    }
                    Rectangle {
                        id: wpViolet
                        width: workingPulse.width * 1.2; height: workingPulse.height * 1.2
                        y: -workingPulse.height * 0.1
                        rotation: 14; opacity: 0.5
                        visible: root.animationsEnabled
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.5; color: VfTheme.dark ? Qt.rgba(0.55, 0.36, 0.96, 0.34) : Qt.rgba(0.55, 0.36, 0.96, 0.18) }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                        SequentialAnimation on x {
                            running: workingPulse.visible && root.animationsEnabled && VfTheme.motion
                            loops: Animation.Infinite
                            NumberAnimation { from: workingPulse.width * 0.4; to: -wpViolet.width * 0.8; duration: 3400; easing.type: Easing.InOutSine }
                            NumberAnimation { from: -wpViolet.width * 0.8; to: workingPulse.width * 0.4; duration: 3400; easing.type: Easing.InOutSine }
                        }
                    }
                    Rectangle {
                        id: wpSweep
                        width: VfTheme.dp(36); height: workingPulse.height * 1.4
                        y: -workingPulse.height * 0.2
                        rotation: 10; opacity: VfTheme.dark ? 0.22 : 0.30
                        visible: root.animationsEnabled
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.5; color: VfTheme.dark ? "#BFD7FF" : "#5B8DEF" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                        SequentialAnimation on x {
                            running: workingPulse.visible && root.animationsEnabled && VfTheme.motion
                            loops: Animation.Infinite
                            NumberAnimation { from: -wpSweep.width * 2; to: workingPulse.width + wpSweep.width; duration: 1900; easing.type: Easing.InOutCubic }
                            PauseAnimation { duration: 900 }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.thumbnailPlaceholderText()
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    font.weight: Font.Bold
                    visible: !thumbnailImage.visible && text.length > 0
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: root.chipMargin
                    radius: root.chipRadius
                    color: root.statusColor()
                    implicitWidth: statusChipLabel.implicitWidth + root.chipHPad
                    implicitHeight: root.chipHeight

                    Text {
                        id: statusChipLabel
                        anchors.centerIn: parent
                        text: root.statusChipText()
                        color: "#FFFFFF"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: root.chipFontSize
                        font.weight: Font.Bold
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: root.chipMargin
                    radius: root.chipRadius
                    color: "#1E293B"
                    opacity: 0.92
                    implicitWidth: typeChipLabel.implicitWidth + root.chipHPad
                    implicitHeight: root.chipHeight

                    Text {
                        id: typeChipLabel
                        anchors.centerIn: parent
                        text: root.typeText()
                        color: "#FFFFFF"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: root.chipFontSize
                        font.weight: Font.Bold
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: root.chipMargin
                    radius: root.chipRadius
                    color: "#0F172A"
                    opacity: 0.92
                    visible: root.sequenceNumber > 0
                    implicitWidth: sequenceChipLabel.implicitWidth + root.chipHPad
                    implicitHeight: root.chipHeight

                    Text {
                        id: sequenceChipLabel
                        anchors.centerIn: parent
                        text: "#" + String(root.sequenceNumber)
                        color: "#FFFFFF"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: root.chipFontSize
                        font.weight: Font.Bold
                    }
                }

                // Slim progress bar pinned to the thumbnail's bottom edge. Width
                // tracks shownProgress (already smoothly animated). Visible while the
                // job is working or mid-progress; hidden once complete/idle.
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: VfTheme.dp(5)
                    color: Qt.rgba(0, 0, 0, 0.42)
                    visible: root.isGeneratingState || (root.shownProgress > 0.5 && root.shownProgress < 99.5)
                    clip: true

                    Rectangle {
                        id: cardProgressFill
                        height: parent.height
                        width: parent.width * Math.max(0, Math.min(100, root.shownProgress)) / 100
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: Qt.lighter(root.statusColor(), 1.25) }
                            GradientStop { position: 1.0; color: root.statusColor() }
                        }

                        // Leading-edge glow accentuates the moving front while generating.
                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: VfTheme.dp(12)
                            height: parent.height
                            visible: root.isGeneratingState && cardProgressFill.width > width
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.6) }
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // Still-image rows already carry an actual local image,
                            // remote preview, or RAM image-provider URL. Open that
                            // source in the shared asynchronous lightbox; routing the
                            // click through Transcript/Clone's VIDEO output resolver
                            // produces a false "scene output file is missing" error.
                            if (root.isStillImageOutputRow()) {
                                var imagePreview = root.imageSourceFromValue(root.batchImageOutputPath())
                                if (imagePreview.length === 0)
                                    imagePreview = root.thumbnailSourceValue
                                if (imagePreview.length > 0) {
                                    root.assetPreviewRequested(imagePreview, root.titleText())
                                    return
                                }
                            }

                            // Video output keeps the existing OS-viewer behavior.
                            var openPath = root.videoPath()
                            if (openPath.length > 0 && typeof nativeShell !== "undefined") {
                                var result = nativeShell.openPath(openPath)
                                if (result && result.ok)
                                    return
                            }
                            // Chưa có file local (đang gen / chỉ có remote media) →
                            // để controller tự resolve/tải về.
                            root.commandRequested("job_panel.view", root.rowId(), -1)
                        }
                    }
                }
            }

            Column {
                anchors.top: parent.top
                anchors.left: thumbnailFrame.right
                anchors.leftMargin: root.cardGap
                spacing: root.cardGap

                JobActionButton {
                    objectName: "jobBtnRetry"
                    width: root.actionColumnWidth
                    text: (void i18n.revision, i18n.t("qml.master.regenerate_short", "Regen"))
                    tone: "primary"
                    enabled: root.canRegenerate()
                    onClicked: root.commandRequested("job_panel.regenerate", root.rowId(), -1)
                }

                JobActionButton {
                    objectName: "jobBtnUpscale"
                    width: root.actionColumnWidth
                    text: width >= 92 ? "Re-Upscale" : "Upscale"
                    enabled: root.canReupscale()
                    onClicked: {
                        var dialog = root.reupscaleDialogItem()
                        if (dialog)
                            dialog.openFor(root.reupscalePayload(), root.reupscaleOptions())
                    }
                }

                JobActionButton {
                    objectName: "jobBtnEdit"
                    width: root.actionColumnWidth
                    text: width >= 92 ? "Edit Prompt" : "Edit"
                    enabled: root.canEdit()
                    onClicked: root.commandRequested("job_panel.edit", root.rowId(), -1)
                }

                JobActionButton {
                    objectName: "jobBtnDelete"
                    width: root.actionColumnWidth
                    text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                    tone: "danger"
                    enabled: root.canDelete()
                    onClicked: root.commandRequested("job_panel.delete", root.rowId(), -1)
                }
            }
        }

        Flickable {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: Math.min(
                parent.width,
                Math.max(
                    root.thumbnailWidth,
                    (Math.min(root.assetStripVisibleCap, root.displayAssets.length) * root.assetSize)
                        + (Math.max(0, Math.min(root.assetStripVisibleCap, root.displayAssets.length) - 1) * root.assetGap)
                )
            )
            height: root.assetStripHeight
            contentWidth: assetRow.width
            contentHeight: height
            clip: true
            interactive: contentWidth > width
            visible: root.displayAssets.length > 0

            Row {
                id: assetRow
                spacing: root.assetGap

                Repeater {
                    model: root.displayAssets

                    delegate: AssetTile {
                        required property int index
                        required property var modelData
                        slotIndex: index
                        slot: modelData
                    }
                }
            }
        }
    }

    Loader {
        id: reupscaleDialogLoader
        active: false

        sourceComponent: Component {
            ReUpscaleDialog {
                onDryRunRequested: payload => root.submitReupscalePayload(payload)
                onUpscaleRequested: payload => root.applyReupscaleResult(root.startReupscalePayload(payload))
            }
        }
    }
}
