import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "deviceMetricStatusRow"

    property string iconName: "device/health"
    property string label: ""
    property string value: "—"
    property string detail: ""
    property string status: "unknown"
    property string provenance: "production"
    property bool visualProductionFixture: false
    property bool compact: false
    property bool showDemoBadge: true
    property bool showStatusBadge: true
    property string statusVisualStyle: "chip"
    property string statusIconName: ""
    property string statusLabel: ""
    property real iconColumnWidth: 0
    property real labelColumnWidth: 0
    property real valueColumnWidth: 0
    property real statusColumnWidth: 0

    readonly property string effectiveStatus: StatusCatalog.normalize(root.status)
    readonly property bool isDemo: StatusCatalog.isDemoProvenance(root.provenance)
    readonly property color statusTone: StatusCatalog.tone(root.effectiveStatus)
    readonly property string resolvedStatusLabel: statusBadge.resolvedLabel
    property color statusTextColor: root.statusTone

    implicitWidth: 280
    implicitHeight: root.compact ? 22 : 42
    radius: Theme.radiusSmall
    color: "transparent"
    Accessible.name: (root.label || "Chỉ số thiết bị") + ": " + (root.value || "—")
        + (root.isDemo ? ", dữ liệu DEMO" : "")
        + ", " + StatusCatalog.label(root.effectiveStatus)
        + (root.detail.length > 0 ? ", " + root.detail : "")
    Accessible.role: Accessible.StaticText

    RowLayout {
        anchors.fill: parent
        spacing: 9
        Item {
            id: iconColumn
            objectName: root.objectName + "IconColumn"
            Layout.preferredWidth: root.iconColumnWidth > 0
                ? root.iconColumnWidth : metricIcon.implicitWidth
            Layout.minimumWidth: Layout.preferredWidth
            Layout.maximumWidth: Layout.preferredWidth
            Layout.fillHeight: true

            UiIcon {
                id: metricIcon
                anchors.centerIn: parent
                name: /^(device|semantic|ui)\/[a-z0-9-]+$/.test(root.iconName)
                    ? root.iconName : "device/health"
                tone: root.statusTone
                iconSize: root.compact ? 14 : 17
            }
        }
        Text {
            objectName: root.objectName + "LabelColumn"
            Layout.fillHeight: true
            Layout.fillWidth: root.labelColumnWidth <= 0
            Layout.preferredWidth: root.labelColumnWidth > 0
                ? root.labelColumnWidth : implicitWidth
            Layout.minimumWidth: root.labelColumnWidth > 0
                ? root.labelColumnWidth : 0
            Layout.maximumWidth: root.labelColumnWidth > 0
                ? root.labelColumnWidth : Number.POSITIVE_INFINITY
            text: root.label || "Chỉ số"
            color: Theme.textMuted
            font.pixelSize: 11
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        Text {
            objectName: root.objectName + "ValueColumn"
            Layout.fillHeight: true
            Layout.fillWidth: root.valueColumnWidth <= 0
            Layout.preferredWidth: root.valueColumnWidth > 0
                ? root.valueColumnWidth : implicitWidth
            Layout.minimumWidth: root.valueColumnWidth > 0
                ? root.valueColumnWidth : 0
            Layout.maximumWidth: root.valueColumnWidth > 0
                ? root.valueColumnWidth : Number.POSITIVE_INFINITY
            text: root.value || "—"
            color: root.effectiveStatus === "unknown" ? Theme.textFaint : Theme.text
            font.pixelSize: 11
            font.weight: Font.DemiBold
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        Item {
            id: statusColumn
            objectName: root.objectName + "StatusColumn"
            Layout.fillWidth: root.statusColumnWidth > 0
            Layout.preferredWidth: root.statusColumnWidth > 0
                ? root.statusColumnWidth
                : (statusBadge.visible ? statusBadge.implicitWidth : 0)
            Layout.minimumWidth: root.statusColumnWidth > 0
                ? root.statusColumnWidth : 0
            Layout.preferredHeight: Math.max(
                root.compact ? 22 : 42,
                statusBadge.visible ? statusBadge.implicitHeight : 0
            )
            clip: true

            StatusBadge {
                id: statusBadge
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.showStatusBadge
                status: root.effectiveStatus
                label: root.statusLabel
                iconName: root.statusIconName
                provenance: root.provenance
                visualProductionFixture: root.visualProductionFixture
                compact: root.compact
                visualStyle: root.statusVisualStyle
                statusTextColor: root.statusTextColor
                showIcon: root.statusVisualStyle === "icon_only"
                showDemoBadge: root.showDemoBadge
            }
        }
    }
}
