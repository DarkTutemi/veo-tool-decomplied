pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Panel {
    id: root
    objectName: "reportFunnelPanel"
    clip: true
    property var funnel: ({})
    readonly property var stages: (root.funnel || {}).stages || []
    Accessible.name: "Phễu chuyển đổi. " + (root.funnel.compatible_population
        ? "Population tương thích" : "Không khả dụng: " + String(root.funnel.reason || "UNKNOWN"))
    Accessible.role: Accessible.Pane

    function stageLabel(value) {
        const labels = {
            "published": "Đã đăng",
            "viewed": "Đã xem",
            "engaged": "Đã tương tác",
            "clicked": "Đã nhấp",
            "converted": "Đã chuyển đổi"
        }
        return labels[String(value || "")] || String(value || "Chưa xác định")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 4
        RowLayout {
            Layout.fillWidth: true
            Text { Layout.fillWidth: true; text: "Phễu chuyển đổi"; color: Theme.text; font.pixelSize: 12; font.weight: Font.Bold }
            Text { text: root.funnel.compatible_population ? "Đã nối dữ liệu" : "Chưa đủ dữ liệu"; color: root.funnel.compatible_population ? Theme.success : Theme.warning; font.pixelSize: 11; font.weight: Font.DemiBold }
        }
        Repeater {
            model: root.stages
            delegate: Rectangle {
                id: stageRow
                required property int index
                required property var modelData
                readonly property string displayValue: stageRow.modelData.available
                    && stageRow.modelData.value !== null
                    && stageRow.modelData.value !== undefined
                    ? String(stageRow.modelData.value) : "—"
                readonly property string availabilityReason: String(stageRow.modelData.reason || "")
                objectName: "reportFunnelStage_" + String(stageRow.modelData.stage || "unknown")
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radiusSmall
                color: stageRow.modelData.available ? Theme.elevated
                    : Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.08)
                border.width: 1
                border.color: stageRow.modelData.available ? Theme.borderSoft : Theme.warning
                Accessible.name: root.stageLabel(stageRow.modelData.stage) + ": "
                    + stageRow.displayValue + ". " + stageRow.availabilityReason
                Accessible.role: Accessible.StaticText
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 7
                    Rectangle { Layout.preferredWidth: 18; Layout.preferredHeight: 18; radius: 9; color: stageRow.modelData.available ? Theme.accentSoft : Theme.elevated; Text { anchors.centerIn: parent; text: String(stageRow.index + 1); color: stageRow.modelData.available ? Theme.accent : Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold } }
                    Text { Layout.fillWidth: true; text: String(stageRow.modelData.label || root.stageLabel(stageRow.modelData.stage)); color: Theme.textMuted; font.pixelSize: 11 }
                    Text { text: stageRow.displayValue; color: stageRow.displayValue === "—" ? Theme.warning : Theme.text; font.pixelSize: 11; font.weight: Font.Bold }
                }
            }
        }
        Text {
            objectName: "reportFunnelReasonText"
            Layout.fillWidth: true
            text: root.funnel.compatible_population
                ? "Các bước cùng dùng một nhóm người xem."
                : String((root.funnel.operator_guidance || {}).detail
                    || root.funnel.reason_label
                    || "Chưa thể nối cùng một nhóm người xem qua các bước")
            color: root.funnel.compatible_population ? Theme.textFaint : Theme.warning
            font.pixelSize: 11
            wrapMode: Text.WordWrap
            maximumLineCount: 2
        }
    }
}
