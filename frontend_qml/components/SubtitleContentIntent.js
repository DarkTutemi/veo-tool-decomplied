.pragma library

function resolvedSource(profile, configuredLanguage) {
    var learning = (profile || {}).learning || (profile || {}).language_learning || ({})
    var requested = String(learning.learning_language || "content_config").toLowerCase()
    return requested === "content_config"
        ? String(configuredLanguage || "vi").toLowerCase()
        : requested
}

function semanticIntent(profile) {
    return (profile || {}).content_intent || ({})
}

function semanticSelection(profile) {
    return String(semanticIntent(profile).selection_mode || "auto").toLowerCase()
}

function semanticMode(profile) {
    var intent = semanticIntent(profile)
    var status = String(intent.status || "pending").toLowerCase()
    if (intent.locked === true
            && (status === "resolved" || status === "manual" || status === "fallback"))
        return String(intent.content_mode || "subtitle").toLowerCase()
    return "pending"
}

function isEnabled(profile) {
    var data = profile || ({})
    return data.enabled !== false && String(data.mode || "auto").toLowerCase() !== "off"
}

function presetLabel(profile) {
    var id = String((profile || {}).preset_id || (profile || {}).style_id || "clean")
    var labels = {
        clean: "Clean Outline",
        documentary: "Documentary",
        cinematic: "Cinematic",
        social_pop: "Social Pop",
        word_highlight: "Marker Highlight",
        karaoke: "Karaoke Flow",
        news: "News Lower Third",
        kids_bounce: "Kids Bounce",
        language_learning: "Language Learning",
        dual_language: "Dual Language"
    }
    if (labels[id])
        return labels[id]
    var words = id.replace(/_/g, " ").split(" ")
    for (var i = 0; i < words.length; ++i) {
        if (words[i].length > 0)
            words[i] = words[i].charAt(0).toUpperCase() + words[i].slice(1)
    }
    return words.join(" ")
}

function shortLabel(profile, configuredLanguage) {
    var data = profile || ({})
    if (!isEnabled(data))
        return "Đã tắt"
    var intent = semanticIntent(data)
    var selection = semanticSelection(data)
    var mode = semanticMode(data)
    if (selection === "auto" && mode === "pending")
        return "AUTO · chờ nội dung thật"
    if (mode === "subtitle")
        return (selection === "manual" ? "MANUAL" : "AUTO") + " · Đơn ngữ"
    if (mode === "bilingual" || mode === "learning") {
        var source = String(intent.learning_language || resolvedSource(data, configuredLanguage)).toUpperCase()
        var target = String(intent.explanation_language || "vi").toUpperCase()
        if (mode === "bilingual")
            return (selection === "manual" ? "MANUAL" : "AUTO") + " · A " + source + " · B " + target
        return (selection === "manual" ? "MANUAL" : "AUTO")
            + " · A " + source + " · R " + readingLabel(intent) + " · B " + target
    }
    var learning = data.learning || data.language_learning || ({})
    var enabled = String(learning.mode || "off").toLowerCase() === "on"
        || learning.enabled === true
    if (!enabled)
        return "Đơn ngữ"
    var source = resolvedSource(data, configuredLanguage).toUpperCase()
    var target = String(learning.translation_language || "vi").toUpperCase()
    return String(learning.layout || "") === "original_translation"
        ? "A " + source + " · B " + target
        : "A " + source + " · R " + readingLabel(learning) + " · B " + target
}

function readingLabel(learning) {
    var requested = String((learning || {}).reading_system || "auto").toLowerCase()
    var labels = {
        auto: "AUTO",
        ipa: "IPA",
        romanization: "LATIN",
        pinyin: "PINYIN",
        furigana: "FURI",
        romaji: "ROMAJI",
        none: "—"
    }
    return labels[requested] || requested.toUpperCase()
}

function workflowSummary(profile, configuredLanguage) {
    if (!isEnabled(profile))
        return "Không render chữ"
    return shortLabel(profile, configuredLanguage) + " · " + presetLabel(profile)
}

function learningOverlayOn(profile) {
    var data = profile || {}
    var overlay = data.overlay || {}
    var learning = data.learning || data.language_learning || {}
    var intent = semanticIntent(data)
    return Boolean(overlay.enabled)
        || String(learning.mode || "off").toLowerCase() === "on"
        || Boolean(learning.enabled)
        || String(intent.content_mode || "").toLowerCase() === "learning"
        || String(data.preset_id || "") === "language_learning"
}

function queueConfirmRow(profile, configuredLanguage) {
    var data = profile || {}
    if (!isEnabled(data))
        return { value: "Tắt", warn: false }
    var summary = workflowSummary(data, configuredLanguage)
    if (learningOverlayOn(data))
        return {
            value: "⚠ " + summary
                + " — học ngoại ngữ (từ + phiên âm). Tắt overlay nếu đây là phim/clone thường.",
            warn: true
        }
    return { value: summary, warn: false }
}

function tooltip(profile, configuredLanguage) {
    var label = shortLabel(profile, configuredLanguage)
    if (label.indexOf("AUTO · chờ") === 0)
        return "Auto đọc kịch bản hoặc transcript thật khi job chạy rồi khóa Đơn ngữ, Song ngữ hoặc A/R/B. Bấm phần chính để cấu hình; mở mũi tên để ghi đè thủ công."
    if (label.indexOf("AUTO ·") === 0)
        return label + ". Quyết định đã được khóa từ nội dung thật của job; preset, font và vị trí vẫn độc lập."
    if (label.indexOf("MANUAL ·") === 0)
        return label + ". Người dùng đã ghi đè nội dung; hệ thống không tự đổi A/R/B."
    if (label === "Đơn ngữ")
        return "Chỉ render lời gốc. Bấm để chọn Song ngữ hoặc Từ + phiên âm."
    return label + ". Bấm để đổi ngôn ngữ A, cách đọc và ngôn ngữ B."
}
