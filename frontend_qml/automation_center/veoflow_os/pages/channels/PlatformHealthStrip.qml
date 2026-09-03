pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Panel {
    id: root
    objectName: "platformHealthStrip"
    clip: true
    property var items
    readonly property real healthTileWidth: platformHealthTileList.count > 0
        ? Math.max(
            132,
            (platformHealthTileList.width
                - platformHealthTileList.spacing
                    * (platformHealthTileList.count - 1))
                / platformHealthTileList.count
        )
        : 0
    signal tileRequested(var link)
    signal reportRequested()
    Accessible.name: "Sức khỏe nền tảng"
    Accessible.role: Accessible.Pane

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text {
            text: "Tình trạng\nnền tảng"
            color: Theme.text
            font.pixelSize: 12
            font.weight: Font.Bold
            lineHeight: 1.15
            Layout.preferredWidth: 82
        }

        ListView {
            id: platformHealthTileList
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 8
            interactive: false
            clip: true
            model: root.items
            // The platform catalog is intentionally small. Keep every tile
            // instantiated so keyboard/accessibility and semantic deep-link
            // targets remain stable even before the first polish pass.
            cacheBuffer: 4096
            reuseItems: false
            delegate: Rectangle {
                id: healthTile
                required property int index
                required property string platform
                required property var total
                required property var healthy
                required property var attention
                required property var unknown
                required property var coverage
                required property var deepLink
                signal activate()
                objectName: "platformHealth_" + platform
                width: root.healthTileWidth
                height: platformHealthTileList.height
                radius: Theme.radiusMedium
                color: tileMouse.containsMouse ? Theme.hover : Theme.elevated
                border.width: activeFocus ? 2 : 1
                border.color: activeFocus ? Theme.accent : Theme.borderSoft
                activeFocusOnTab: true
                Accessible.name: healthTile.platform + ": "
                    + root.exact(healthTile.healthy) + " tốt, "
                    + root.exact(healthTile.attention) + " cần chú ý"
                Accessible.description: "Mở inventory tài khoản đã lọc theo nền tảng"
                Accessible.role: Accessible.Button
                onActivate: root.tileRequested(healthTile.deepLink || ({}))
                Keys.onSpacePressed: healthTile.activate()
                Keys.onReturnPressed: healthTile.activate()

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    SocialIcon {
                        platform: healthTile.platform
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        RowLayout {
                            Layout.fillWidth: true
                            Text { Layout.fillWidth: true; text: root.platformLabel(healthTile.platform); color: Theme.text; font.pixelSize: 11; font.weight: Font.Bold; elide: Text.ElideRight }
                            Text { text: root.exact(healthTile.total); color: Theme.text; font.pixelSize: 12; font.weight: Font.Bold }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.exact(healthTile.healthy) + " tốt · "
                                + root.exact(healthTile.attention) + " chú ý · "
                                + root.exact(healthTile.unknown) + " chưa rõ"
                            color: Number(healthTile.attention || 0) > 0
                                ? Theme.warning : Theme.success
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: Number((healthTile.coverage || {}).platformOperationEvidence || 0) === 0
                                ? "Thiếu bằng chứng platform operation"
                                : "Coverage có platform operation"
                            color: Number((healthTile.coverage || {}).platformOperationEvidence || 0) === 0
                                ? Theme.warning : Theme.textFaint
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }
                }
                MouseArea {
                    id: tileMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: healthTile.activate()
                }
            }
        }

        AppButton {
            id: platformReportButton
            objectName: "browserPlatformReport"
            Layout.preferredWidth: 126
            Layout.minimumWidth: 126
            Layout.maximumWidth: 126
            text: "Xem báo cáo  >"
            activeFocusOnTab: true
            Accessible.name: "Xem báo cáo sức khỏe nền tảng"
            onClicked: root.reportRequested()
        }
    }

    function exact(value) {
        return value === undefined || value === null ? "—" : String(value)
    }

    function platformLabel(value) {
        const normalized = String(value || "").toLowerCase()
        if (normalized === "tiktok") return "TikTok"
        if (normalized === "youtube") return "YouTube"
        if (normalized === "facebook") return "Facebook"
        if (normalized === "instagram") return "Instagram"
        if (normalized === "x") return "X"
        if (normalized === "linkedin") return "LinkedIn"
        return String(value || "Không rõ")
    }
}
