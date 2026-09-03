import QtQuick

QtObject {
    id: root

    function cleanItems(items) {
        var out = []
        for (var i = 0; i < items.length; i++) {
            var text = String(items[i] || "").replace(/\s+/g, " ").trim()
            text = text.replace(/^Scene\s*(\d+\s*:|\(\s*\d+\)\s*:|\s*:)/i, "").trim()
            if (text.length > 0)
                out.push(text)
        }
        return out
    }

    function splitParagraphs(text) {
        return cleanItems(String(text || "").trim().split(/(?:\r?\n\s*){2,}/))
    }

    function detectBestPattern(text) {
        var raw = String(text || "")
        if ((raw.match(/\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}/g) || []).length >= 2)
            return { pattern: "json_blocks", confidence: 0.98 }
        if (splitParagraphs(raw).length >= 2)
            return { pattern: "double_newline", confidence: 0.90 }
        if (/Scene\s*(?:\(\s*\d+\s*\)|\d+)?\s*:/i.test(raw))
            return { pattern: "scene", confidence: 0.95 }
        if (/^\s*\d+\.\s+/m.test(raw))
            return { pattern: "numbered", confidence: 0.90 }
        if (/^\s*[-*]\s+/m.test(raw))
            return { pattern: "bullet", confidence: 0.85 }
        return { pattern: "heuristic", confidence: 0.60 }
    }

    function parse(text) {
        var raw = String(text || "")
        if (!raw.trim().length)
            return []

        var jsonBlocks = raw.match(/\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}/g) || []
        if (jsonBlocks.length >= 2)
            return cleanItems(jsonBlocks)

        var paragraphs = splitParagraphs(raw)
        if (paragraphs.length >= 2)
            return paragraphs

        var sceneMatches = []
        var sceneRegex = /(?:^|\s)Scene\s*(?:\(\s*\d+\s*\)|\d+)?\s*:/gi
        var matches = []
        var match
        while ((match = sceneRegex.exec(raw)) !== null)
            matches.push({ start: match.index, end: sceneRegex.lastIndex })
        for (var i = 0; i < matches.length; i++) {
            var end = i + 1 < matches.length ? matches[i + 1].start : raw.length
            sceneMatches.push(raw.slice(matches[i].end, end))
        }
        if (sceneMatches.length >= 2)
            return cleanItems(sceneMatches)

        var numbered = cleanItems(raw.split(/^\s*\d+\.\s+/m))
        if (numbered.length >= 2)
            return numbered

        var bullets = cleanItems(raw.split(/^\s*[-*]\s+/m))
        if (bullets.length >= 2)
            return bullets

        return cleanItems(raw.split(/\r?\n/))
    }
}
