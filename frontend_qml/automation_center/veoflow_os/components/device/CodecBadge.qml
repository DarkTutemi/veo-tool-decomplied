import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "deviceCodecBadge"

    property string label: ""
    property color tone: Theme.textMuted
    property string status: "unavailable"
    property bool authoritative: false
    property string provenance: "production"
    property bool visualProductionFixture: false
    property bool compact: false
    property int compactWidth: 55

    // Reference token: the compact cast badge is a 45 x 15 flat chip.  The
    // outline in the previous version made the 1 px edge dominate an 8 px
    // label, especially on the selected indigo cast card.
    readonly property real compactHorizontalPadding: 3
    readonly property int compactMaximumWidth:
        root.visualProductionFixture ? 55 : 45
    readonly property int labelPixelSize: root.compact
        ? (root.visualProductionFixture ? 11 : 8) : 11
    readonly property real fillOpacity: root.compact ? 0.10 : 0.12
    readonly property real outlineWidth: root.compact ? 0 : 1
    readonly property real outlineOpacity: root.compact ? 0 : 0.20

    readonly property bool isDemo: StatusCatalog.isDemoProvenance(root.provenance)
    readonly property bool visualDemo: root.isDemo && !root.visualProductionFixture
    readonly property string effectiveState: StatusCatalog.normalize(root.status)
    readonly property color effectiveTone: root.visualDemo ? Theme.textMuted : root.tone
    readonly property bool available: root.visualDemo
        || (root.authoritative && root.label.trim().length > 0
            && root.effectiveState !== "unknown"
            && root.effectiveState !== "unavailable")
    readonly property string displayLabel: root.visualDemo
        ? (root.compact ? "Poster demo" : "DEMO · "
            + (root.label.trim().length > 0 ? root.label.trim() : "POSTER"))
        : (root.available ? root.label.trim() : "CODEC —")
    readonly property string visualLabel: root.visualDemo && root.compact
        ? "Poster" : root.displayLabel
    readonly property bool labelTruncated: labelText.truncated
        || (!root.compact && labelText.paintedWidth > labelText.width + 0.5)

    implicitWidth: root.compact
        ? Math.max(root.visualProductionFixture ? 55 : 40,
            Math.min(root.compactMaximumWidth, root.compactWidth))
        : contentRow.implicitWidth + 16
    implicitHeight: root.compact
        ? (root.visualProductionFixture ? 17 : 15) : 26
    radius: root.compact ? 3 : 7
    clip: true
    color: root.visualProductionFixture && root.compact
        ? Theme.successSoft
        : Qt.rgba(
            root.effectiveTone.r,
            root.effectiveTone.g,
            root.effectiveTone.b,
            root.fillOpacity
        )
    border.width: root.outlineWidth
    border.color: Qt.rgba(
        root.effectiveTone.r,
        root.effectiveTone.g,
        root.effectiveTone.b,
        root.outlineOpacity
    )
    Accessible.name: root.visualProductionFixture && root.isDemo
        ? root.displayLabel + ", fixture production mô phỏng từ demo_seed; không phải bằng chứng cast trực tiếp"
        : root.isDemo
        ? "DEMO, poster đóng gói, không phải live codec hoặc bằng chứng codec trực tiếp"
        : (root.available ? root.displayLabel + ", codec đã được nguồn có thẩm quyền xác nhận"
            : "Codec không khả dụng hoặc chưa được xác nhận")
    Accessible.role: Accessible.StaticText

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 5
        UiIcon {
            visible: !root.compact
            name: "device/codec"
            tone: root.effectiveTone
            iconSize: root.compact ? 12 : 14
        }
        Text {
            id: labelText
            Layout.preferredWidth: root.compact
                ? root.width - (root.compactHorizontalPadding * 2)
                : implicitWidth
            Layout.maximumWidth: root.compact
                ? root.width - (root.compactHorizontalPadding * 2)
                : implicitWidth
            Layout.preferredHeight: root.compact ? root.height - 2 : implicitHeight
            text: root.visualLabel
            color: root.effectiveTone
            font.pixelSize: root.labelPixelSize
            font.weight: root.compact ? Font.DemiBold : Font.Bold
            font.letterSpacing: 0
            fontSizeMode: root.compact ? Text.Fit : Text.FixedSize
            minimumPixelSize: 4
            wrapMode: Text.NoWrap
            elide: root.compact ? Text.ElideNone : Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
