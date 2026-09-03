import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "deviceStatusBadge"

    property string status: "unknown"
    property string label: ""
    property string detail: ""
    property string iconName: ""
    property bool showIcon: true
    property string provenance: "production"
    property bool visualProductionFixture: false
    property bool compact: false
    property bool showDemoBadge: true
    property string visualStyle: "chip"
    property bool fixtureOutlined: false
    property bool showStatusDot: false
    property color statusTextColor: root.statusTone

    // The reference uses three distinct semantic treatments.  Unknown values
    // fail closed to a labelled chip so status meaning never disappears.
    readonly property string effectiveVisualStyle:
        ["chip", "icon_only", "dot_text"].indexOf(root.visualStyle) >= 0
        ? root.visualStyle : "chip"
    readonly property bool isIconOnly: root.effectiveVisualStyle === "icon_only"
    readonly property bool isDotText: root.effectiveVisualStyle === "dot_text"
    readonly property real horizontalPadding: root.compact ? 9 : 9
    readonly property int labelPixelSize: root.compact
        ? (root.visualProductionFixture ? 11 : 10) : 11
    readonly property int dotSize: 6
    readonly property int iconPixelSize: root.isIconOnly ? 14
        : (root.compact ? 12 : 14)
    readonly property real fillOpacity: root.isIconOnly || root.isDotText
        ? 0 : (root.compact ? 0.10 : 0.12)
    readonly property real outlineWidth:
        root.fixtureOutlined && !root.isIconOnly && !root.isDotText ? 1
        : root.compact || root.isIconOnly || root.isDotText ? 0 : 1
    readonly property real outlineOpacity:
        root.fixtureOutlined ? 0.32
        : root.compact || root.isIconOnly || root.isDotText ? 0 : 0.20

    readonly property string effectiveStatus: StatusCatalog.normalize(root.status)
    readonly property bool isDemo: StatusCatalog.isDemoProvenance(root.provenance)
    readonly property bool visualDemo: root.isDemo && !root.visualProductionFixture
    readonly property color statusTone: StatusCatalog.tone(root.effectiveStatus)
    readonly property string baseLabel: root.label.length > 0
        ? root.label : StatusCatalog.label(root.effectiveStatus)
    readonly property string resolvedLabel: (root.showDemoBadge && root.visualDemo
        && root.baseLabel.trim().toUpperCase() !== "DEMO" ? "DEMO · " : "") + root.baseLabel
    readonly property string resolvedIcon: /^(device|semantic|ui)\/[a-z0-9-]+$/.test(root.iconName)
        ? root.iconName : StatusCatalog.icon(root.effectiveStatus)

    implicitWidth: root.isIconOnly ? 16
        : (root.isDotText ? contentRow.implicitWidth
            : Math.max(root.compact ? 50 : 0,
                contentRow.implicitWidth + (root.horizontalPadding * 2)))
    implicitHeight: root.fixtureOutlined ? 20
        : root.compact || root.isIconOnly || root.isDotText ? 16 : 28
    radius: root.isIconOnly || root.isDotText ? 0
        : (root.compact ? 3 : height / 2)
    color: Qt.rgba(
        root.statusTone.r,
        root.statusTone.g,
        root.statusTone.b,
        root.fillOpacity
    )
    border.width: root.outlineWidth
    border.color: Qt.rgba(
        root.statusTone.r,
        root.statusTone.g,
        root.statusTone.b,
        root.outlineOpacity
    )
    Accessible.name: root.resolvedLabel + (root.detail.length > 0 ? ", " + root.detail : "")
        + (root.visualProductionFixture && root.isDemo
            ? ", fixture production mô phỏng từ demo_seed" : "")
    Accessible.role: Accessible.StaticText

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.isDotText ? 5
            : ((root.showIcon || root.showStatusDot) && !root.isIconOnly
                ? (root.compact ? 4 : 6) : 0)
        UiIcon {
            visible: root.isIconOnly
                || (root.showIcon && !root.showStatusDot && !root.isDotText)
            Layout.preferredWidth: visible ? iconSize : 0
            Layout.minimumWidth: 0
            Layout.maximumWidth: visible ? iconSize : 0
            name: root.resolvedIcon
            tone: root.statusTone
            iconSize: root.iconPixelSize
        }
        Rectangle {
            visible: root.isDotText
            Layout.preferredWidth: visible ? root.dotSize : 0
            Layout.preferredHeight: visible ? root.dotSize : 0
            Layout.minimumWidth: 0
            Layout.maximumWidth: visible ? root.dotSize : 0
            radius: root.dotSize / 2
            color: root.statusTone
        }
        Rectangle {
            visible: root.showStatusDot && !root.isDotText && !root.isIconOnly
            Layout.preferredWidth: visible ? root.dotSize : 0
            Layout.preferredHeight: visible ? root.dotSize : 0
            Layout.minimumWidth: 0
            Layout.maximumWidth: visible ? root.dotSize : 0
            radius: root.dotSize / 2
            color: root.statusTone
        }
        Text {
            visible: !root.isIconOnly
            Layout.preferredWidth: visible ? implicitWidth : 0
            Layout.minimumWidth: 0
            Layout.maximumWidth: visible ? implicitWidth : 0
            text: root.resolvedLabel
            color: root.statusTextColor
            font.pixelSize: root.labelPixelSize
            font.weight: Font.DemiBold
        }
    }
}
