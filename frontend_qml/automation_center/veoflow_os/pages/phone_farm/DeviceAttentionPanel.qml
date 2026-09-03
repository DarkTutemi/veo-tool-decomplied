pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../components/device" as Device

Panel {
    id: root
    objectName: "deviceAttentionPanel"
    color: Theme.panel
    property var attentionModel: null
    property bool visualProductionFixture: false
    signal viewAllRequested()
    signal attentionRequested(var deepLink)
    Accessible.name: "Thiết bị cần chú ý"
    Accessible.role: Accessible.List

    function statusProvenance(provenance) {
        const source = String((provenance || {}).source || "").toLowerCase()
        return Boolean((provenance || {}).simulated)
                || ["demo_seed", "demo_only", "simulated"].indexOf(source) >= 0
            ? "demo_seed" : "production"
    }

    function attentionState(severity, status) {
        const projected = String(status || "").toLowerCase()
        if (["critical", "attention"].indexOf(projected) >= 0) return projected
        return String(severity || "").toLowerCase() === "critical"
            ? "critical" : "attention"
    }

    function attentionLabel(severity) {
        return String(severity || "").toLowerCase() === "critical"
            ? "Nghiêm trọng" : "Cần chú ý"
    }

    function attentionVisualFixture(candidate) {
        const value = candidate || ({})
        return root.visualProductionFixture
                && String(value.kind || "") === "production_parity"
                && String(value.provenance || "") === "demo_seed"
                && Boolean(value.simulated)
            ? value : ({})
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 7
        RowLayout {
            objectName: "deviceAttentionHeaderRow"
            Layout.fillWidth: true
            Layout.preferredHeight: root.visualProductionFixture ? 26 : -1
            Layout.maximumHeight: root.visualProductionFixture ? 26 : 16777215
            Text {
                objectName: "deviceAttentionTitle"
                Layout.fillWidth: true
                text: "Thiết bị cần chú ý ("
                    + String(root.attentionModel ? root.attentionModel.count : 0) + ")"
                color: Theme.text
                font.pixelSize: 14
                font.weight: Font.Bold
            }
            AppButton {
                objectName: "viewAllDeviceAttentionButton"
                Layout.preferredHeight: root.visualProductionFixture ? 24 : -1
                Layout.maximumHeight: root.visualProductionFixture
                    ? 24 : 16777215
                text: "Xem tất cả"
                subtle: true
                activeFocusOnTab: true
                Accessible.name: text + " thiết bị cần chú ý"
                onClicked: root.viewAllRequested()
            }
        }

        ListView {
            id: attentionList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.attentionModel
            spacing: 6
            clip: true
            reuseItems: true
            delegate: Button {
                id: attentionCard
                required property int index
                required property var incident_id
                required property string device_id
                required property var device_label
                required property var device_model
                required property var latency_ms
                required property var title
                required property string code
                required property string severity
                required property var summary
                required property var status
                required property var heartbeat_at
                required property var last_seen_at
                required property var deep_link
                required property var provenance
                required property var visual_fixture
                readonly property var visualFixture: root.attentionVisualFixture(
                    attentionCard.visual_fixture
                )
                readonly property bool hasVisualFixture:
                    Object.keys(attentionCard.visualFixture).length > 0
                readonly property string statusProvenance: root.statusProvenance(
                    attentionCard.provenance
                )
                readonly property string presentationState: root.attentionState(
                    attentionCard.severity,
                    attentionCard.status
                )
                readonly property color severityTone:
                    String(attentionCard.severity || "") === "critical"
                    ? Theme.danger : Theme.warning
                readonly property real outlineOpacity: 0.42
                readonly property real fillOpacity: 0.08
                readonly property int stripeWidth: 4
                objectName: "deviceAttentionCard_" + String(attentionCard.device_id || index)
                width: attentionList.width
                height: attentionCard.hasVisualFixture ? 86 : 78
                activeFocusOnTab: true
                Accessible.name: String(attentionCard.hasVisualFixture
                    ? attentionCard.device_label || attentionCard.device_id
                    : attentionCard.title || attentionCard.device_label
                        || attentionCard.device_id || "Thiết bị") + ", "
                    + (attentionCard.hasVisualFixture
                        ? String(attentionCard.visualFixture.issueLabel || "") + ", "
                        : "")
                    + String(attentionCard.code || "DEVICE_HEALTH_UNKNOWN") + ", "
                    + String(attentionCard.summary || "Không có mô tả")
                Accessible.description: "Heartbeat " + String(attentionCard.heartbeat_at || "không rõ")
                    + (root.visualProductionFixture
                        ? "; fixture production mô phỏng từ demo_seed" : "")
                Accessible.role: Accessible.ListItem

                function activate() {
                    root.attentionRequested(attentionCard.deep_link || ({}))
                    return true
                }

                onClicked: activate()
                contentItem: RowLayout {
                    spacing: attentionCard.hasVisualFixture ? 16 : 9
                    Rectangle {
                        objectName: "attentionSeverityStripe_"
                            + String(attentionCard.device_id
                                || attentionCard.index)
                        visible: !attentionCard.hasVisualFixture
                        Layout.preferredWidth: visible
                            ? attentionCard.stripeWidth : 0
                        Layout.fillHeight: true
                        radius: 2
                        color: attentionCard.severityTone
                    }
                    Device.DeviceAvatar {
                        objectName: "attentionAvatar_"
                            + String(attentionCard.device_id || attentionCard.index)
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        deviceId: String(attentionCard.device_id || "")
                        label: String(attentionCard.device_label || "")
                        healthState: attentionCard.presentationState
                        provenance: attentionCard.statusProvenance
                        visualProductionFixture:
                            attentionCard.hasVisualFixture
                        avatarSize: 34
                        showDemoBadge: false
                    }
                    ColumnLayout {
                        objectName: "attentionCardContent_"
                            + String(attentionCard.device_id
                                || attentionCard.index)
                        Layout.fillWidth: true
                        spacing: 3
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                objectName: "attentionDeviceLabel_"
                                    + String(attentionCard.device_id
                                        || attentionCard.index)
                                Layout.fillWidth: !attentionCard.hasVisualFixture
                                Layout.preferredWidth: attentionCard.hasVisualFixture
                                    ? Math.min(86, implicitWidth) : -1
                                text: String(attentionCard.hasVisualFixture
                                    ? attentionCard.device_label
                                        || attentionCard.device_id || "—"
                                    : attentionCard.title
                                        || attentionCard.device_label
                                        || attentionCard.device_id || "—")
                                color: Theme.text
                                font.pixelSize: attentionCard.hasVisualFixture
                                    ? 13 : 11
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }
                            Text {
                                objectName: "attentionIssueLabel_"
                                    + String(attentionCard.device_id
                                        || attentionCard.index)
                                visible: attentionCard.hasVisualFixture
                                Layout.fillWidth: false
                                Layout.preferredWidth: Math.min(
                                    implicitWidth,
                                    160
                                )
                                text: String(
                                    attentionCard.visualFixture.issueLabel || "—"
                                )
                                color: attentionCard.severityTone
                                font.pixelSize: attentionCard.hasVisualFixture
                                    ? 13 : 11
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Device.StatusBadge {
                                objectName: "attentionStatus_"
                                    + String(attentionCard.device_id || attentionCard.index)
                                status: attentionCard.presentationState
                                label: attentionCard.hasVisualFixture
                                    ? String(
                                        attentionCard.visualFixture.statusLabel
                                            || "—"
                                    )
                                    : root.attentionLabel(attentionCard.severity)
                                provenance: attentionCard.statusProvenance
                                visualProductionFixture:
                                    root.visualProductionFixture
                                compact: true
                                showDemoBadge: false
                                showIcon: !attentionCard.hasVisualFixture
                            }
                            Item {
                                objectName: "attentionFixtureInlineSpacer_"
                                    + String(attentionCard.device_id
                                        || attentionCard.index)
                                visible: attentionCard.hasVisualFixture
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                            }
                            Text {
                                text: attentionCard.latency_ms === null
                                    || attentionCard.latency_ms === undefined
                                    ? "—" : String(attentionCard.latency_ms) + "ms"
                                color: attentionCard.severityTone
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                        }
                        Text {
                            objectName: "attentionDetail_"
                                + String(attentionCard.device_id
                                    || attentionCard.index)
                            Layout.fillWidth: true
                            Layout.leftMargin:
                                attentionCard.hasVisualFixture ? 72 : 0
                            text: String(attentionCard.hasVisualFixture
                                ? attentionCard.visualFixture.detail || "—"
                                : attentionCard.summary
                                    || "Không có mô tả từ backend")
                            color: Theme.textMuted
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                        Text {
                            objectName: "attentionMetadata_"
                                + String(attentionCard.device_id || attentionCard.index)
                            Layout.fillWidth: true
                            Layout.leftMargin:
                                attentionCard.hasVisualFixture ? 72 : 0
                            text: attentionCard.hasVisualFixture
                                ? String(
                                    attentionCard.visualFixture.metadata || "—"
                                )
                                : String(attentionCard.code || "DEVICE_HEALTH_UNKNOWN")
                                + (attentionCard.statusProvenance !== "production"
                                    && !root.visualProductionFixture
                                    ? " · DEMO" : "")
                                + " · " + String(attentionCard.device_label
                                    || attentionCard.device_id || "Thiết bị")
                                + " · " + String(attentionCard.device_model || "Model không rõ")
                                + " · " + String(attentionCard.last_seen_at
                                    || "Chưa có thời điểm")
                            color: attentionCard.hasVisualFixture
                                ? Theme.textMuted : Theme.textFaint
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }
                }
                background: Rectangle {
                    objectName: "attentionCardBackground_"
                        + String(attentionCard.device_id
                            || attentionCard.index)
                    radius: Theme.radiusSmall
                    color: attentionCard.hasVisualFixture
                        ? (String(attentionCard.severity || "").toLowerCase()
                            === "critical" ? Theme.dangerSoft : Theme.warningSoft)
                        : Qt.rgba(
                            attentionCard.severityTone.r,
                            attentionCard.severityTone.g,
                            attentionCard.severityTone.b,
                            attentionCard.hovered
                                ? 0.12 : attentionCard.fillOpacity
                        )
                    border.width: 1
                    border.color: Qt.rgba(
                        attentionCard.severityTone.r,
                        attentionCard.severityTone.g,
                        attentionCard.severityTone.b,
                        attentionCard.outlineOpacity
                    )
                }
            }

            Text { anchors.centerIn: parent; visible: !root.attentionModel || root.attentionModel.count === 0; text: "Không có attention projection"; color: Theme.textFaint; font.pixelSize: 11 }
        }
    }
}
