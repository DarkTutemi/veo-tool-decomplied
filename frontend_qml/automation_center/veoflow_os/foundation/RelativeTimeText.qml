import QtQuick
import ".."

Text {
    id: root
    objectName: "relativeTimeText"
    property string timestamp: ""
    property string referenceTimestamp: ""
    property date now: new Date()
    text: relativeLabel(timestamp)
    color: Theme.textFaint
    font.pixelSize: 11
    Accessible.name: text
    Accessible.role: Accessible.StaticText

    Timer { interval: 30000; running: root.visible; repeat: true; onTriggered: root.now = new Date() }

    function parsedTimestamp(value) {
        const text = String(value || "").trim()
        if (!text)
            return new Date(NaN)
        const hasZone = /(?:Z|[+-]\d{2}:?\d{2})$/i.test(text)
        return new Date(hasZone ? text : text + "Z")
    }

    function relativeLabel(value) {
        if (!value) return "—"
        const parsed = root.parsedTimestamp(value)
        if (isNaN(parsed.getTime())) return "—"
        const reference = root.parsedTimestamp(root.referenceTimestamp)
        const referenceMs = root.referenceTimestamp.length > 0
            && !isNaN(reference.getTime()) ? reference.getTime() : root.now.getTime()
        const seconds = Math.max(0, Math.floor((referenceMs - parsed.getTime()) / 1000))
        if (seconds < 60) return "vừa xong"
        if (seconds < 3600) return Math.floor(seconds / 60) + " phút trước"
        if (seconds < 86400) return Math.floor(seconds / 3600) + " giờ trước"
        return Math.floor(seconds / 86400) + " ngày trước"
    }
}
