pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Item {
    id: root
    objectName: "signalIndicator"

    property var level: null
    property var latencyMs: null
    property string status: "unknown"
    property bool sampleFresh: false
    property bool showBars: true
    property bool showLatency: true
    property string provenance: "production"
    property bool compact: false
    property bool showDemoBadge: true
    property bool showProvenanceLabel: true

    readonly property bool validLevel: typeof root.level === "number"
        && isFinite(root.level) && Math.floor(root.level) === root.level
        && root.level >= 0 && root.level <= 4
    readonly property bool validLatency: root.latencyMs === null
        || (typeof root.latencyMs === "number" && isFinite(root.latencyMs)
            && root.latencyMs >= 0)
    readonly property string normalizedState: StatusCatalog.normalize(root.status)
    readonly property bool isDemo: StatusCatalog.isDemoProvenance(root.provenance)
    readonly property bool available: root.validLevel && root.validLatency
        && root.sampleFresh && root.normalizedState !== "unknown"
        && root.normalizedState !== "unavailable"
    readonly property int displayLevel: root.available ? Number(root.level) : 0
    readonly property color statusTone: root.available
        ? StatusCatalog.tone(root.normalizedState) : Theme.textFaint
    readonly property int compactBarWidth: 2
    readonly property int compactBarSpacing: 2
    readonly property int compactBarsWidth: root.compactBarWidth * 4
        + root.compactBarSpacing * 3

    Layout.fillWidth: root.showBars && !root.showLatency
    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

    implicitWidth: (root.showBars ? (root.compact ? root.compactBarsWidth : 18) : 0)
        + (root.showBars && root.showLatency ? 6 : 0)
        + (root.showLatency ? (root.compact ? 36 : 40) : 0)
        + (root.isDemo && root.showDemoBadge && root.showProvenanceLabel ? 42 : 0)
    implicitHeight: root.compact ? 18 : 22
    Accessible.name: root.available
        ? (root.isDemo ? "DEMO, " : "")
            + "Chất lượng tín hiệu " + String(root.displayLevel) + " trên 4"
            + (root.latencyMs === null ? "" : ", độ trễ " + String(Math.round(root.latencyMs)) + " mili giây")
            + ", " + StatusCatalog.label(root.normalizedState)
        : "Tín hiệu không khả dụng hoặc dữ liệu đã cũ"
    Accessible.role: Accessible.StaticText

    Item {
        id: signalBars
        objectName: "signalBars"
        visible: root.showBars
        anchors.right: root.showLatency ? undefined : parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.compact ? 5 : 0
        width: root.compact ? root.compactBarsWidth : 18
        height: root.compact ? 14 : 18

        Repeater {
            model: 4
            delegate: Rectangle {
                required property int index
                objectName: "signalBar_" + String(index)
                x: index * (width + (root.compact ? root.compactBarSpacing : 2))
                anchors.bottom: parent.bottom
                width: root.compact ? root.compactBarWidth : 3
                height: (root.compact ? 4 : 5) + index * (root.compact ? 3 : 4)
                radius: 1
                color: index < root.displayLevel ? root.statusTone : Theme.border
                antialiasing: true
            }
        }
    }

    Text {
        id: latencyLabel
        objectName: "signalLatencyLabel"
        visible: root.showLatency
        anchors.left: root.showBars ? signalBars.right : parent.left
        anchors.leftMargin: root.showBars ? 6 : 0
        anchors.verticalCenter: parent.verticalCenter
        text: root.available && root.latencyMs !== null
            ? String(Math.round(root.latencyMs)) + "ms" : "—"
        color: root.statusTone
        font.pixelSize: 11
        font.weight: Font.DemiBold
    }
    Text {
        visible: root.isDemo && root.showDemoBadge && root.showProvenanceLabel
        anchors.left: root.showLatency ? latencyLabel.right
            : root.showBars ? signalBars.right : parent.left
        anchors.leftMargin: root.showLatency || root.showBars ? 6 : 0
        anchors.verticalCenter: parent.verticalCenter
        text: "DEMO"
        color: Theme.accent
        font.pixelSize: 11
        font.weight: Font.Bold
    }
}
