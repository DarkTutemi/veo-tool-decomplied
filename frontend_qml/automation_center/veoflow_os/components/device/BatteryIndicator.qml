import QtQuick
import "../.."

Item {
    id: root
    objectName: "batteryIndicator"

    property var percent: null
    property bool charging: false
    property string status: "unknown"
    property bool sampleFresh: false
    property bool showLabel: true
    property string provenance: "production"
    property bool compact: false
    property bool showDemoBadge: true
    property bool showProvenanceLabel: true

    readonly property bool validPercent: typeof root.percent === "number"
        && isFinite(root.percent) && root.percent >= 0 && root.percent <= 100
    readonly property string normalizedState: StatusCatalog.normalize(root.status)
    readonly property bool isDemo: StatusCatalog.isDemoProvenance(root.provenance)
    readonly property bool available: root.validPercent && root.sampleFresh
        && root.normalizedState !== "unknown" && root.normalizedState !== "unavailable"
    readonly property int displayPercent: root.available ? Math.round(root.percent) : 0
    readonly property color statusTone: root.available
        ? StatusCatalog.tone(root.normalizedState) : Theme.textFaint
    readonly property int compactBodyWidth: 21
    readonly property int compactBodyHeight: 10
    readonly property int outlineWidth: 1
    readonly property int bodyWidth: root.compact ? root.compactBodyWidth : 24
    readonly property int bodyHeight: root.compact ? root.compactBodyHeight : 12
    readonly property int glyphWidth: root.bodyWidth + (root.compact ? 3 : 4)

    implicitWidth: (root.showLabel ? (root.compact ? 54 : 66) : root.glyphWidth)
        + (root.isDemo && root.showDemoBadge && root.showProvenanceLabel ? 42 : 0)
    implicitHeight: root.compact ? 18 : 22
    Accessible.name: root.available
        ? (root.isDemo ? "DEMO, " : "") + "Pin " + String(root.displayPercent) + "%"
            + (root.charging ? ", đang sạc" : "")
            + ", " + StatusCatalog.label(root.normalizedState)
        : "Pin không khả dụng hoặc dữ liệu đã cũ"
    Accessible.role: Accessible.StaticText

    Row {
        id: contentRow
        objectName: "batteryContent"
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.compact ? 6 : 7

        Text {
            id: percentLabel
            objectName: "batteryPercentLabel"
            visible: root.showLabel
            anchors.verticalCenter: parent.verticalCenter
            text: root.available ? String(root.displayPercent) + "%" : "—"
            color: root.available ? Theme.textMuted : Theme.textFaint
            font.pixelSize: 11
            font.weight: Font.Normal
        }

        Item {
            id: batteryGlyph
            objectName: "batteryGlyph"
            width: root.glyphWidth
            height: root.compact ? 12 : 16
            Rectangle {
                id: batteryBody
                objectName: "batteryBody"
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: root.bodyWidth
                height: root.bodyHeight
                radius: root.compact ? 2 : 3
                color: "transparent"
                border.width: root.outlineWidth
                border.color: root.statusTone
                antialiasing: true
                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.available
                        ? Math.max(1, Math.round((parent.width - 4) * root.displayPercent / 100)) : 0
                    height: Math.max(3, parent.height - 4)
                    radius: 1
                    color: root.statusTone
                    visible: root.available
                }
            }
            Rectangle {
                objectName: "batteryTerminal"
                anchors.left: batteryBody.right
                anchors.leftMargin: 1
                anchors.verticalCenter: parent.verticalCenter
                width: root.compact ? 2 : 3
                height: root.compact ? 5 : 7
                radius: 1
                color: root.statusTone
            }
            Text {
                visible: root.charging && root.available
                anchors.centerIn: batteryBody
                text: "+"
                color: Theme.base
                font.pixelSize: 11
                font.weight: Font.Bold
            }
        }

        Text {
            visible: root.isDemo && root.showDemoBadge && root.showProvenanceLabel
            anchors.verticalCenter: parent.verticalCenter
            text: "DEMO"
            color: Theme.accent
            font.pixelSize: 11
            font.weight: Font.Bold
        }
    }
}
