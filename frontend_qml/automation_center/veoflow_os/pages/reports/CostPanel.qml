pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Panel {
    id: root
    objectName: "reportCostPanel"
    clip: true
    property var costs: ({})
    readonly property int evidenceCount: Number((root.costs.provenance || {}).evidence_count || 0)
    readonly property bool available: Boolean(root.costs.available) && root.evidenceCount > 0
    readonly property string availabilityReason: root.available ? "" : String(
        root.costs.available && root.evidenceCount === 0
            ? "COST_EVIDENCE_UNAVAILABLE"
            : root.costs.reason || "USAGE_LEDGER_UNAVAILABLE"
    )
    readonly property string displaySummary: String(
        (root.costs.operator_guidance || {}).detail
        || root.costs.reason_label
        || "Chưa ghi nhận chi phí vận hành trong kỳ")
    Accessible.name: "Chi phí và thời gian tiết kiệm. " + (root.available
        ? String(root.evidenceCount) + " evidence refs" : "Không khả dụng: " + root.availabilityReason)
    Accessible.role: Accessible.Pane

    function metricText(key) {
        const value = (root.costs.metrics || {})[key]
        if (!root.available || value === null || value === undefined)
            return "—"
        const numeric = Number(value)
        return isFinite(numeric) ? String(Math.round(numeric * 100) / 100) : String(value)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 9
        spacing: 4
        RowLayout {
            Layout.fillWidth: true
            Text { Layout.fillWidth: true; text: "Chi phí & thời gian tiết kiệm"; color: Theme.text; font.pixelSize: 12; font.weight: Font.Bold }
            Text { text: root.available ? String(root.costs.currency || "—") : "Chưa có số liệu"; color: root.available ? Theme.textMuted : Theme.warning; font.pixelSize: 11 }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6
            Repeater {
                model: [
                    {"key": "render_credits", "label": "Render"},
                    {"key": "ai_tokens", "label": "AI tokens"},
                    {"key": "browser_hours", "label": "Browser"},
                    {"key": "retry_cost", "label": "Retry"},
                    {"key": "time_saved_minutes", "label": "Tiết kiệm"}
                ]
                delegate: ColumnLayout {
                    id: costItem
                    required property int index
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 1
                    Text { Layout.fillWidth: true; text: String(costItem.modelData.label); color: Theme.textFaint; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight }
                    Text {
                        objectName: "reportCostValue_" + String(costItem.modelData.key)
                        Layout.fillWidth: true
                        text: root.metricText(String(costItem.modelData.key))
                        color: text === "—" ? Theme.warning : Theme.text
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
        Text {
            objectName: "reportCostSummary"
            Layout.fillWidth: true
            text: root.available
                ? root.evidenceCount + " bản ghi bằng chứng đã được đối soát"
                : root.displaySummary
            color: root.available ? Theme.textFaint : Theme.warning
            font.pixelSize: 11
            elide: Text.ElideRight
        }
    }
}
