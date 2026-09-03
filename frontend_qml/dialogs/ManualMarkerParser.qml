import QtQuick

QtObject {
    id: root

    function parse(text) {
        var raw = String(text || "")
        var prompts = []
        var marker = /\[START_PROMPT_(\d+)\]([\s\S]*?)\[END_PROMPT_\1\]/gi
        var match
        while ((match = marker.exec(raw)) !== null) {
            var prompt = String(match[2] || "").trim()
            if (prompt.length > 0)
                prompts.push(prompt)
        }
        return prompts
    }

    function addMarkers(text, startPos, endPos, promptId) {
        var raw = String(text || "")
        var start = Math.max(0, Math.min(startPos, endPos))
        var end = Math.max(0, Math.max(startPos, endPos))
        var startMarker = "[START_PROMPT_" + String(promptId) + "]"
        var endMarker = "[END_PROMPT_" + String(promptId) + "]"
        return raw.slice(0, start) + startMarker + raw.slice(start, end) + endMarker + raw.slice(end)
    }

    function removeAllMarkers(text) {
        return String(text || "").replace(/\[START_PROMPT_\d+\]|\[END_PROMPT_\d+\]/g, "")
    }
}
