pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Panel {
    id: root
    objectName: "reportAttributionPanel"
    clip: true
    property var attribution: ({})
    readonly property var evidenceBackedItems: root.filterEvidenceBackedItems()
    readonly property int evidenceBackedCount: root.evidenceBackedItems.length
    readonly property bool available: Boolean(root.attribution.available)
        && root.evidenceBackedCount > 0
    readonly property string availabilityReason: root.available ? "" : String(
        root.attribution.available && root.evidenceBackedCount === 0
            ? "ATTRIBUTION_EVIDENCE_UNAVAILABLE"
            : root.attribution.reason || "ATTRIBUTION_MODEL_UNAVAILABLE"
    )
    Accessible.name: "Hiệu suất chiến dịch và affiliate. " + (root.available
        ? String(root.evidenceBackedCount) + " bản ghi có evidence"
        : "Không khả dụng: " + root.availabilityReason)
    Accessible.role: Accessible.Pane

    function filterEvidenceBackedItems() {
        const source = root.attribution.items || []
        const safe = []
        for (let index = 0; index < source.length; index++) {
            const item = source[index] || ({})
            const evidence = item.evidence_refs || []
            if (evidence.length > 0 && String(item.model || "").length > 0)
                safe.push(item)
        }
        return safe
    }

    function roiText(item) {
        const roi = (item || {}).roi || ({})
        if (roi.available && roi.value !== null && roi.value !== undefined)
            return "ROI " + String(roi.value) + String(roi.unit || "")
        return "ROI — · " + String(roi.reason_label
            || "Chưa nối được chi phí với doanh thu")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 9
        spacing: 4
        RowLayout {
            Layout.fillWidth: true
            Text { Layout.fillWidth: true; text: "Chiến dịch / Affiliate"; color: Theme.text; font.pixelSize: 12; font.weight: Font.Bold }
            Text { text: root.available ? "Có bằng chứng" : "Chưa đủ dữ liệu"; color: root.available ? Theme.success : Theme.warning; font.pixelSize: 11; font.weight: Font.DemiBold }
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2
            Text {
                objectName: "reportAttributionSummary"
                visible: !root.available
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: String((root.attribution.operator_guidance || {}).detail
                    || root.attribution.reason_label
                    || "Chưa có dữ liệu đủ điều kiện tính đóng góp và ROI.")
                color: Theme.warning
                font.pixelSize: 11
                wrapMode: Text.Wrap
                verticalAlignment: Text.AlignVCenter
            }
            Repeater {
                model: root.available ? root.evidenceBackedItems.slice(0, 1) : []
                delegate: ColumnLayout {
                    id: attributionItem
                    required property int index
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        Layout.fillWidth: true
                        text: String(attributionItem.modelData.campaign_label
                                || "Chiến dịch chưa đặt tên")
                            + " · " + String(attributionItem.modelData.platform_label
                                || attributionItem.modelData.platform || "—")
                            + " · " + String(attributionItem.modelData.fact_count || 0)
                            + " số liệu"
                        color: Theme.textMuted
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    Text {
                        objectName: "reportAttributionRoi_" + String(attributionItem.modelData.campaign_id || attributionItem.index)
                        Layout.fillWidth: true
                        text: root.roiText(attributionItem.modelData)
                        color: text.indexOf("—") >= 0 ? Theme.warning : Theme.success
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    Text {
                        objectName: "reportAttributionSummary"
                        Layout.fillWidth: true
                        text: String((root.attribution.operator_guidance || {}).detail
                            || "Dữ liệu đóng góp đã được đối chiếu.")
                        color: Theme.textFaint
                        font.pixelSize: Theme.fontMetadata
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
