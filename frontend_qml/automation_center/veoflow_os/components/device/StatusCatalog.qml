pragma Singleton
import QtQuick
import "../.."

QtObject {
    readonly property var knownStates: [
        "active", "attention", "bound", "cancelled", "connected", "connecting",
        "critical", "current", "danger", "degraded", "demo_only", "derived",
        "error", "excellent", "expired", "expiring", "fair", "failed", "good",
        "healthy", "hot", "idle", "incompatible", "info", "low", "match",
        "mismatch", "neutral", "none", "normal", "not_required", "offline",
        "online", "open", "paused", "pending", "poor", "poster_only", "queued",
        "ready", "redacted", "referenced", "rejected", "reported", "required", "running",
        "signature_failed", "stable", "stale", "streaming", "stopped",
        "stop_requested", "succeeded", "unavailable", "unbound", "unknown",
        "unleased", "unverified", "update_available", "verified",
        "verification_required", "waiting_approval", "warm", "warning"
    ]

    function normalize(status) {
        const key = String(status || "").trim().toLowerCase()
        if (knownStates.indexOf(key) >= 0)
            return key
        return "unknown"
    }

    function normalizeProvenance(provenance) {
        const key = String(provenance || "").trim().toLowerCase()
        if (["production", "demo_seed", "demo_only", "simulated"].indexOf(key) >= 0)
            return key
        return "unknown"
    }

    function isDemoProvenance(provenance) {
        const key = normalizeProvenance(provenance)
        return key === "demo_seed" || key === "demo_only" || key === "simulated"
    }

    function tone(status) {
        const key = normalize(status)
        if (["healthy", "stable", "normal", "excellent", "good", "online",
             "connected", "ready", "current", "verified", "succeeded", "bound",
             "match"].indexOf(key) >= 0)
            return Theme.success
        if (["active", "running", "streaming", "queued", "referenced", "reported",
             "derived", "connecting", "paused", "stop_requested", "info"].indexOf(key) >= 0)
            return Theme.info
        if (["attention", "degraded", "low", "fair", "warm", "stale", "expiring",
             "pending", "open", "required", "warning", "mismatch",
             "waiting_approval", "update_available", "verification_required"].indexOf(key) >= 0)
            return Theme.warning
        if (["critical", "failed", "expired", "incompatible", "rejected", "poor",
             "hot", "error", "danger", "signature_failed", "cancelled"].indexOf(key) >= 0)
            return Theme.danger
        if (key === "demo_only" || key === "poster_only")
            return Theme.accent
        return Theme.textFaint
    }

    function icon(status) {
        const key = normalize(status)
        if (["healthy", "stable", "normal", "excellent", "good", "online",
             "connected", "ready", "current", "verified", "succeeded", "bound",
             "match"].indexOf(key) >= 0)
            return "semantic/check-circle"
        if (["critical", "failed", "expired", "incompatible", "rejected", "poor",
             "hot", "error", "danger", "signature_failed", "cancelled"].indexOf(key) >= 0)
            return "semantic/alert-circle"
        if (["attention", "degraded", "low", "fair", "warm", "stale", "expiring",
             "warning", "mismatch", "open", "required", "waiting_approval",
             "update_available", "verification_required"].indexOf(key) >= 0)
            return "semantic/alert-triangle"
        if (key === "referenced")
            return "device/evidence"
        if (key === "poster_only")
            return "device/cast"
        if (["active", "running", "streaming", "queued", "pending", "reported",
             "derived", "connecting", "paused", "stop_requested", "info"].indexOf(key) >= 0)
            return "device/operation"
        return "semantic/info"
    }

    function label(status) {
        const key = normalize(status)
        const labels = {
            "active": "Đang hoạt động",
            "attention": "Cần chú ý",
            "bound": "Đã ràng buộc",
            "cancelled": "Đã hủy",
            "connected": "Đã kết nối",
            "connecting": "Đang kết nối",
            "critical": "Nghiêm trọng",
            "current": "Mới nhất",
            "danger": "Nguy hiểm",
            "degraded": "Suy giảm",
            "demo_only": "DEMO",
            "derived": "Đã tổng hợp",
            "error": "Lỗi",
            "excellent": "Xuất sắc",
            "expired": "Đã hết hạn",
            "expiring": "Sắp hết hạn",
            "fair": "Trung bình",
            "failed": "Thất bại",
            "good": "Tốt",
            "healthy": "Bình thường",
            "hot": "Quá nóng",
            "idle": "Đang rảnh",
            "incompatible": "Không tương thích",
            "info": "Thông tin",
            "low": "Mức thấp",
            "match": "Khớp",
            "mismatch": "Không khớp",
            "neutral": "Trung tính",
            "none": "Không có",
            "normal": "Bình thường",
            "not_required": "Không cần phê duyệt",
            "offline": "Ngoại tuyến",
            "online": "Trực tuyến",
            "open": "Đang mở",
            "paused": "Tạm dừng",
            "pending": "Đang chờ",
            "poor": "Kém",
            "poster_only": "Poster DEMO",
            "queued": "Đã xếp hàng",
            "ready": "Sẵn sàng",
            "redacted": "Đã ẩn",
            "referenced": "Đã tham chiếu",
            "rejected": "Bị từ chối",
            "reported": "Đã báo cáo",
            "required": "Bắt buộc",
            "running": "Đang chạy",
            "signature_failed": "Sai chữ ký",
            "stable": "Ổn định",
            "stale": "Đã cũ",
            "streaming": "Đang truyền",
            "stopped": "Đã dừng",
            "stop_requested": "Đang dừng an toàn",
            "succeeded": "Thành công",
            "unavailable": "Không khả dụng",
            "unbound": "Chưa ràng buộc",
            "unknown": "Không rõ",
            "unleased": "Chưa có lease",
            "unverified": "Chưa xác minh",
            "update_available": "Có bản cập nhật",
            "verified": "Đã xác minh",
            "verification_required": "Cần đối soát",
            "waiting_approval": "Chờ phê duyệt",
            "warm": "Hơi nóng",
            "warning": "Cảnh báo"
        }
        return labels[key] || labels.unknown
    }
}
