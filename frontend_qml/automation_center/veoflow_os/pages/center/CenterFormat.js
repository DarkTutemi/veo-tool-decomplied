.pragma library

function clean(value) {
    return String(value === undefined || value === null ? "" : value)
}

function workflowLabel(value) {
    switch (clean(value).toLowerCase()) {
    case "master": return "MASTER PROMPT"
    case "clone": return "CLONE VIDEO"
    case "transcript": return "AUDIO TO VIDEO"
    case "affiliate": return "AFFILIATE"
    case "timemachine": return "TIME MACHINE"
    case "publish": return "PUBLISHKIT"
    default: return clean(value).replace(/_/g, " ").toUpperCase() || "WORKFLOW"
    }
}

function workflowTone(value) {
    switch (clean(value).toLowerCase()) {
    case "affiliate": return "info"
    case "transcript": return "violet"
    case "timemachine": return "violet"
    default: return "info"
    }
}

function statusKind(value) {
    const status = clean(value).toLowerCase()
    if (["succeeded", "completed", "ready", "verified", "published", "closed"].indexOf(status) >= 0)
        return "success"
    if (["failed", "cancelled", "error", "invalid"].indexOf(status) >= 0)
        return "danger"
    if (["needs_attention", "waiting_approval", "unverified", "conflict", "blocked"].indexOf(status) >= 0)
        return "warning"
    if (["running", "dispatching", "publishing", "active", "user_open"].indexOf(status) >= 0)
        return "info"
    return "neutral"
}

function statusLabel(value, fallback) {
    switch (clean(value).toLowerCase()) {
    case "queued": return "Đang chờ"
    case "running": return "Đang chạy"
    case "dispatching": return "Đang giao"
    case "publishing": return "Đang đăng"
    case "succeeded": return "Hoàn tất"
    case "completed": return "Hoàn tất"
    case "ready": return "Sẵn sàng"
    case "verified": return "Đã xác minh"
    case "closed": return "Sẵn sàng"
    case "user_open": return "Đang mở"
    case "failed": return "Thất bại"
    case "cancelled": return "Đã hủy"
    case "needs_attention": return "Cần xử lý"
    case "waiting_approval": return "Chờ duyệt"
    case "unverified": return "Cần đăng nhập"
    case "conflict": return "Xung đột"
    default: return clean(fallback) || clean(value) || "Chưa rõ"
    }
}

function platformLabel(value) {
    const key = clean(value).toLowerCase()
    if (key === "youtube") return "YouTube"
    if (key === "tiktok") return "TikTok"
    if (key === "facebook") return "Facebook"
    if (key === "instagram") return "Instagram"
    if (key === "linkedin") return "LinkedIn"
    return clean(value) || "Nền tảng"
}

function timeLabel(value) {
    const date = new Date(clean(value))
    if (isNaN(date.getTime())) return clean(value) || "—"
    const two = number => String(number).padStart(2, "0")
    return two(date.getDate()) + "/" + two(date.getMonth() + 1) + "/" + date.getFullYear()
        + " " + two(date.getHours()) + ":" + two(date.getMinutes())
}

function compactId(value) {
    const text = clean(value)
    if (text.length <= 18) return text || "—"
    return text.slice(0, 8) + "…" + text.slice(-6)
}

