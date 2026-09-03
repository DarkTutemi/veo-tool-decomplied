pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Item {
    id: root
    objectName: "deviceEvidenceStrip"

    property var evidenceItems: []
    property int maximumVisible: 4
    property string provenance: "production"
    property bool visualProductionFixture: false
    property bool compact: false
    property bool showProvenanceLabel: true
    property bool showCountChip: true
    readonly property bool isDemo: StatusCatalog.isDemoProvenance(root.provenance)
    readonly property int compactTileWidth: 20
    readonly property int compactTileHeight: 28
    readonly property int compactSpacing: 3
    readonly property int compactCountWidth: 26
    readonly property int compactRadius: 4
    readonly property color tileBorderColor: Theme.borderSoft

    readonly property int evidenceCount: root.evidenceItems !== null
        && root.evidenceItems !== undefined
        && typeof root.evidenceItems !== "string"
        && typeof root.evidenceItems.length === "number"
        ? root.evidenceItems.length : 0
    readonly property int visibleCount: Math.min(Math.max(0, root.maximumVisible), root.evidenceCount)
    // The thumbnails already show how many previews fit. The badge mirrors the
    // reference UI by reporting the authoritative total evidence count.
    readonly property string countLabel: String(root.evidenceCount)

    implicitWidth: Math.max(54, evidenceRow.implicitWidth)
    implicitHeight: root.compact ? root.compactTileHeight : 38
    Accessible.name: root.evidenceCount > 0
        ? (root.isDemo ? "DEMO, " : "") + String(root.evidenceCount)
            + " bằng chứng tham chiếu; bản xem trước cần được Control Plane cấp quyền"
        : "Không có bằng chứng"
    Accessible.role: Accessible.StaticText

    function itemAt(index) {
        if (index < 0 || index >= root.evidenceCount)
            return ({})
        const item = root.evidenceItems[index]
        return item && typeof item === "object" ? item : ({})
    }

    function safeArtifactId(item) {
        const value = String((item || {}).artifactId || "")
        return /^[A-Za-z0-9][A-Za-z0-9_.:-]{0,159}$/.test(value) ? value : ""
    }

    function normalizedVisualTone(item) {
        const value = String((item || {}).visualTone || "")
            .trim().toLowerCase()
        return ["neutral", "amber", "success", "danger", "accent"]
            .indexOf(value) >= 0 ? value : "neutral"
    }

    function visualToneColor(tone) {
        if (tone === "amber") return Theme.warning
        if (tone === "success") return Theme.success
        if (tone === "danger") return Theme.danger
        if (tone === "accent") return Theme.accent
        return "transparent"
    }

    function demoThumbnailSource(item) {
        if (!root.isDemo)
            return ""
        const key = String((item || {}).demoThumbnailKey || "")
        const packagedPosters = {
            "garden-creator": "garden-creator.jpg",
            "mountain-route": "mountain-route.jpg",
            "creator-products": "creator-products.jpg",
            "waterfall-travel": "waterfall-travel.jpg",
            "evidence-r1-c1": "evidence/evidence-r1-c1.png",
            "evidence-r1-c2": "evidence/evidence-r1-c2.png",
            "evidence-r1-c3": "evidence/evidence-r1-c3.png",
            "evidence-r2-c1": "evidence/evidence-r2-c1.png",
            "evidence-r2-c2": "evidence/evidence-r2-c2.png",
            "evidence-r2-c3": "evidence/evidence-r2-c3.png",
            "evidence-r3-c1": "evidence/evidence-r3-c1.png",
            "evidence-r3-c2": "evidence/evidence-r3-c2.png",
            "evidence-r3-c3": "evidence/evidence-r3-c3.png",
            "evidence-r4-c1": "evidence/evidence-r4-c1.png",
            "evidence-r4-c2": "evidence/evidence-r4-c2.png",
            "evidence-r4-c3": "evidence/evidence-r4-c3.png"
        }
        const fileName = packagedPosters[key]
        return fileName ? Qt.resolvedUrl("../../assets/demo/phone_farm/" + fileName) : ""
    }

    function hasEvidenceFrameKey(item) {
        const key = String((item || {}).demoThumbnailKey || "")
        return /^evidence-r[1-4]-c[1-3]$/.test(key)
    }

    RowLayout {
        id: evidenceRow
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.compact ? root.compactSpacing : 5

        Repeater {
            model: root.visibleCount
            delegate: Rectangle {
                id: evidenceTile
                required property int index
                objectName: "evidenceTile_" + String(index)
                readonly property var itemData: root.itemAt(index)
                readonly property string artifactId: root.safeArtifactId(itemData)
                readonly property string verificationState: StatusCatalog.normalize(
                    String(itemData.verificationState || "unknown")
                )
                readonly property string resolvedVisualTone:
                    root.normalizedVisualTone(itemData)
                readonly property color resolvedVisualToneColor:
                    root.visualToneColor(resolvedVisualTone)
                readonly property bool isEvidenceFrame:
                    root.hasEvidenceFrameKey(itemData)
                readonly property bool fixtureToneVisible:
                    root.visualProductionFixture
                    && !isEvidenceFrame
                    && resolvedVisualTone !== "neutral"
                readonly property url thumbnailSource: root.demoThumbnailSource(itemData)
                Layout.preferredWidth: root.compact ? root.compactTileWidth : 38
                Layout.preferredHeight: root.compact ? root.compactTileHeight : 32
                radius: root.compact ? root.compactRadius : Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: root.tileBorderColor
                Accessible.name: artifactId.length > 0
                    ? "Bằng chứng " + artifactId + ", " + StatusCatalog.label(verificationState)
                    : "Bằng chứng không hợp lệ"
                Accessible.role: Accessible.Graphic

                Image {
                    anchors.fill: parent
                    anchors.margins: root.compact ? 1 : 2
                    source: evidenceTile.thumbnailSource
                    visible: String(evidenceTile.thumbnailSource).length > 0
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                }

                Rectangle {
                    objectName: "evidenceVisualTone_" + String(evidenceTile.index)
                    anchors.fill: parent
                    radius: parent.radius
                    visible: evidenceTile.fixtureToneVisible
                    color: Qt.rgba(
                        evidenceTile.resolvedVisualToneColor.r,
                        evidenceTile.resolvedVisualToneColor.g,
                        evidenceTile.resolvedVisualToneColor.b,
                        0.16
                    )
                }

                UiIcon {
                    anchors.centerIn: parent
                    visible: String(evidenceTile.thumbnailSource).length === 0
                    name: "device/evidence"
                    tone: evidenceTile.artifactId.length > 0
                        ? StatusCatalog.tone(evidenceTile.verificationState) : Theme.textFaint
                    iconSize: root.compact ? 14 : 17
                }
            }
        }

        Rectangle {
            objectName: "evidenceCountChip"
            visible: root.showCountChip && root.evidenceCount > 0
            Layout.preferredWidth: root.compact ? root.compactCountWidth : 38
            Layout.preferredHeight: root.compact ? root.compactTileHeight : 32
            radius: root.compact ? root.compactRadius : Theme.radiusSmall
            color: Theme.elevated
            border.width: 1
            border.color: root.tileBorderColor
            Text {
                anchors.centerIn: parent
                text: root.countLabel
                color: Theme.textMuted
                font.pixelSize: root.compact ? 10 : 11
                font.weight: Font.DemiBold
            }
        }

        Text {
            visible: root.evidenceCount === 0
            text: "Không có bằng chứng"
            color: Theme.textFaint
            font.pixelSize: 11
        }
        Text {
            visible: root.isDemo && !root.visualProductionFixture
                && root.showProvenanceLabel
            text: "DEMO"
            color: Theme.accent
            font.pixelSize: 11
            font.weight: Font.Bold
        }
    }
}
