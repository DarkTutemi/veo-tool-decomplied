pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Item {
    id: root
    objectName: "reportsKpiStrip"
    property var kpis: ({})
    Accessible.name: "Các KPI có nguồn"
    Accessible.role: Accessible.Pane

    function compact(value) {
        const number = Number(value)
        if (!isFinite(number)) return "—"
        const absolute = Math.abs(number)
        if (absolute >= 1000000000) return (number / 1000000000).toFixed(2).replace(/0+$/, "").replace(/\.$/, "") + "B"
        if (absolute >= 1000000) return (number / 1000000).toFixed(2).replace(/0+$/, "").replace(/\.$/, "") + "M"
        if (absolute >= 1000) return (number / 1000).toFixed(1).replace(/\.0$/, "") + "K"
        return Number.isInteger(number) ? String(number) : String(Math.round(number * 100) / 100)
    }

    function display(metric) {
        const item = metric || ({})
        if (!item.available || item.value === null || item.value === undefined) return "—"
        const value = root.compact(item.value)
        if (item.unit === "percent") return value + "%"
        if (item.unit && item.unit !== "count") return value + " " + String(item.unit)
        return value
    }

    function delta(metric) {
        const item = (metric || {}).delta || ({})
        if (!item.available || item.value === null || item.value === undefined) return "—"
        const value = Number(item.value)
        return (value > 0 ? "+" : "") + String(Math.round(value * 100) / 100) + "%"
    }

    function source(metric) {
        const provenance = (metric || {}).provenance || ({})
        const sources = provenance.sources || []
        return sources.length > 0 ? sources.join(", ") : "Nguồn không khả dụng"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8
        Repeater {
            model: [
                {"key": "published", "suffix": "Published", "label": "Nội dung đã xuất bản", "tone": Theme.accent, "icon": "semantic/upload-cloud"},
                {"key": "views", "suffix": "Views", "label": "Lượt xem", "tone": Theme.info, "icon": "semantic/video"},
                {"key": "engagement_rate", "suffix": "Engagement", "label": "Tương tác", "tone": Theme.success, "icon": "semantic/heart"},
                {"key": "conversions", "suffix": "Conversions", "label": "Chuyển đổi", "tone": Theme.warning, "icon": "semantic/workflow"},
                {"key": "estimated_revenue", "suffix": "EstimatedRevenue", "label": "Doanh thu ước tính", "tone": Theme.success, "icon": "semantic/bar-chart"},
                {"key": "operating_cost", "suffix": "OperatingCost", "label": "Chi phí vận hành", "tone": Theme.danger, "icon": "semantic/alert-circle"}
            ]
            delegate: Rectangle {
                id: card
                required property int index
                required property var modelData
                readonly property var metric: root.kpis[card.modelData.key] || ({})
                readonly property string displayValue: root.display(card.metric)
                readonly property string deltaText: root.delta(card.metric)
                readonly property var displayCopy: card.metric.display || ({})
                readonly property string sourceText: root.source(card.metric)
                readonly property string detailText: String(
                    card.displayCopy.detail || "Dữ liệu đã được xác minh")
                readonly property string comparisonText: String(
                    card.displayCopy.comparison || "Bật so sánh để xem xu hướng")
                readonly property string qualityText: String(
                    card.displayCopy.quality_label || "Trạng thái dữ liệu chưa xác định")
                readonly property string availabilityReason: card.metric.available
                    ? String(card.metric.reason || "") : String(card.metric.reason || "METRIC_UNAVAILABLE")
                objectName: "reportKpi" + String(card.modelData.suffix)
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radiusMedium
                color: Theme.panel
                border.width: 1
                border.color: Theme.borderSoft
                Accessible.name: String(card.modelData.label) + ": " + card.displayValue
                    + ", " + card.comparisonText + ", " + card.detailText
                Accessible.role: Accessible.StaticText
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 3
                    RowLayout {
                        Layout.fillWidth: true
                        UiIcon {
                            Layout.preferredWidth: 17
                            Layout.preferredHeight: 17
                            name: String(card.modelData.icon || "semantic/bar-chart")
                            tone: card.modelData.tone
                            iconSize: 17
                        }
                        Text { Layout.fillWidth: true; text: String(card.modelData.label); color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                        Text { text: card.deltaText; color: card.deltaText.startsWith("+") ? Theme.success : card.deltaText === "—" ? Theme.textFaint : Theme.danger; font.pixelSize: 11; font.weight: Font.Bold }
                    }
                    Text { text: card.displayValue; color: card.displayValue === "—" ? Theme.warning : Theme.text; font.pixelSize: 23; font.weight: Font.Bold }
                    Text {
                        objectName: "reportKpi" + String(card.modelData.suffix) + "Detail"
                        Layout.fillWidth: true
                        text: card.displayValue === "—"
                            ? String(card.displayCopy.reason_label || card.sourceText)
                            : card.detailText
                        color: card.displayValue === "—" ? Theme.warning : Theme.textFaint
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        Rectangle {
                            Layout.preferredWidth: 6
                            Layout.preferredHeight: 6
                            radius: 3
                            color: card.metric.available
                                ? (card.metric.reason ? Theme.warning : Theme.success)
                                : Theme.warning
                        }
                        Text {
                            objectName: "reportKpi" + String(card.modelData.suffix) + "Quality"
                            Layout.fillWidth: true
                            text: card.qualityText
                            color: card.metric.available && !card.metric.reason
                                ? Theme.success : Theme.warning
                            font.pixelSize: Theme.fontMetadata
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
