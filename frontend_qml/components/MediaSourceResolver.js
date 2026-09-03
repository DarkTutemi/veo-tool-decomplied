.pragma library

function _text(value) {
    return String(value || "").trim()
}

function _isDirectSource(value) {
    var raw = _text(value)
    return raw.indexOf("data:") === 0
        || raw.indexOf("file:") === 0
        || raw.indexOf("image:") === 0
        || raw.indexOf("qrc:") === 0
        || raw.indexOf("http://") === 0
        || raw.indexOf("https://") === 0
}

function _isLocalPath(value) {
    var raw = _text(value)
    return raw.match(/^[A-Za-z]:[\\/]/)
        || raw.charAt(0) === "/"
        || raw.indexOf("\\\\") === 0
        || raw.indexOf("\\") >= 0
}

function _looksBase64(value) {
    var raw = _text(value).replace(/\s+/g, "")
    return raw.length > 80 && /^[A-Za-z0-9+/=]+$/.test(raw)
}

function dataImageMime(raw, item) {
    item = item || ({})
    var mime = _text(item.thumbnail_mime_type || item.mime_type || item.image_mime_type)
    if (mime.indexOf("image/") === 0)
        return mime
    raw = _text(raw)
    if (raw.indexOf("/9j/") === 0)
        return "image/jpeg"
    if (raw.indexOf("iVBOR") === 0)
        return "image/png"
    if (raw.indexOf("UklGR") === 0)
        return "image/webp"
    if (raw.indexOf("R0lGOD") === 0)
        return "image/gif"
    return "image/png"
}

function dataImageUrl(raw, item) {
    raw = _text(raw)
    if (raw.length === 0)
        return ""
    if (_isDirectSource(raw))
        return raw
    return "data:" + dataImageMime(raw, item || ({})) + ";base64," + raw
}

function localFileUrl(value) {
    var raw = _text(value)
    if (raw.length === 0)
        return ""
    if (_isDirectSource(raw))
        return raw
    if (!_isLocalPath(raw))
        return ""
    return "file:///" + raw.replace(/\\/g, "/")
}

function normalizedImageSource(value, item) {
    var raw = _text(value)
    if (raw.length === 0)
        return ""
    if (_isDirectSource(raw))
        return raw
    if (_looksBase64(raw))
        return dataImageUrl(raw, item || ({}))
    return localFileUrl(raw)
}

function _appendUnique(target, value, item) {
    var source = normalizedImageSource(value, item)
    if (source.length === 0 || target.indexOf(source) >= 0)
        return
    target.push(source)
}

function imageSources(item) {
    item = item || ({})
    var out = []
    var candidates = [
        // File URL trước (webp trên disk, Qt cache theo URL) — nhanh hơn data: URL.
        item.thumbnail_file_url,
        item.thumbnail_url,
        item.preview_url,
        item.blob_file_url,
        item.file_url,
        item.thumbnail_file_path,
        item.thumbnail_path,
        item.thumb_path,
        item.preview_path,
        // Base64 thumbnail nhỏ (webp) — fallback khi không có file URL.
        item.thumbnail_base64,
        item.thumbnail_data,
        // Đường dẫn nguồn full-size — chỉ dùng khi không còn lựa chọn nhẹ hơn.
        item.original_source_path,
        item.source_path,
        item.file_path,
        item.path,
        item.croppedImagePath,
        item.cropped_image_path,
        item.image_base64,
        item.base64,
        item.thumbnail
    ]
    for (var i = 0; i < candidates.length; ++i)
        _appendUnique(out, candidates[i], item)
    return out
}

function imageSource(item) {
    var sources = imageSources(item || ({}))
    return sources.length > 0 ? String(sources[0] || "") : ""
}

function previewImageSource(item) {
    item = item || ({})
    var out = []
    var candidates = [
        item.file_url,
        item.blob_file_url,
        item.preview_url,
        item.source_path,
        item.file_path,
        item.path,
        item.blob_path,
        item.thumbnail_file_url,
        item.thumbnail_base64,
        item.thumbnail_path,
        item.thumbnail
    ]
    for (var i = 0; i < candidates.length; ++i)
        _appendUnique(out, candidates[i], item)
    return out.length > 0 ? String(out[0] || "") : ""
}
