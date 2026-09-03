.pragma library

function timestampMs(value) {
    if (typeof value === "number" && isFinite(value) && value > 0)
        return value < 1e12 ? Math.round(value * 1000) : Math.round(value)
    var text = String(value || "").trim()
    if (!text.length)
        return 0
    text = text.replace(/(\.\d{3})\d+/, "$1")
    var parsed = Date.parse(text)
    return isNaN(parsed) ? 0 : parsed
}

function isEpochMs(value) {
    return typeof value === "number" && isFinite(value) && value > 1e12
}

function wallNowMs(value) {
    var n = Number(value)
    return isEpochMs(n) ? Math.round(n) : Date.now()
}

function formatElapsedSeconds(totalSeconds) {
    var n = Math.round(Number(totalSeconds))
    if (!isFinite(n) || n < 0)
        n = 0
    var hours = Math.floor(n / 3600)
    var minutes = Math.floor((n % 3600) / 60)
    var seconds = n % 60
    if (hours > 0)
        return String(hours) + "h " + String(minutes) + "m"
    if (minutes > 0)
        return String(minutes) + "m " + String(seconds) + "s"
    return String(seconds) + "s"
}

function elapsedText(row, nowMs, statusKey, fallbackStartMs) {
    var item = row || {}
    var stored = Number(item.elapsed_seconds || 0)
    if (!isFinite(stored) || stored < 0)
        stored = 0
    var start = Number(item.started_at_ms)
    if (!isEpochMs(start))
        start = timestampMs(item.started_at || "")
    if (!isEpochMs(start))
        start = Number(fallbackStartMs)
    if (!isEpochMs(start))
        return stored > 0 ? formatElapsedSeconds(stored) : "0s"
    var end = wallNowMs(nowMs)
    var status = String(statusKey || item.status || item.job_status || "").toLowerCase()
    if (status === "complete" || status === "completed" || status === "failed"
            || status === "error" || status === "cancelled" || status === "paused") {
        var stopped = Number(item.stopped_at_ms)
        if (!isEpochMs(stopped))
            stopped = timestampMs(item.stopped_at || item.updated_at || "")
        if (isEpochMs(stopped))
            end = stopped
        else if (stored > 0)
            return formatElapsedSeconds(stored)
    }
    return formatElapsedSeconds(Math.max(0, Math.round((end - start) / 1000)))
}

function rowElapsedLabel(row, nowMs, statusKey) {
    var text = elapsedText(row, nowMs, statusKey, 0)
    var status = String(statusKey || (row || {}).status || (row || {}).job_status || "").toLowerCase()
    var live = status === "running" || status === "processing" || status === "routing"
        || status === "cloning" || status === "generating" || status === "creating_script"
        || status === "pending_script" || status === "analyzing" || status === "merging"
        || status === "polling" || status === "upscaling" || status === "downloading"
    if (text === "0s" && !live)
        return "—"
    return text
}
