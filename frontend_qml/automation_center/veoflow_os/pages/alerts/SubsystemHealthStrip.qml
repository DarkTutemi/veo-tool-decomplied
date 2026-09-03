pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Panel {
    id: root
    objectName: "subsystemHealthStrip"
    clip: true
    property var health: ({})
    property var healthModel: null
    readonly property var systemDetailsAction:
        ((root.health || {}).actions || {}).system_details || ({})
    readonly property var statusDescriptor:
        (root.health || {}).status_descriptor || ({})
    readonly property real healthTileWidth: subsystemHealthTileList.count > 0
        ? Math.max(
            148,
            (subsystemHealthTileList.width
                - subsystemHealthTileList.spacing
                    * (subsystemHealthTileList.count - 1))
                / subsystemHealthTileList.count
        )
        : 0
    signal actionRequested(var action)
    Accessible.name: "Sức khỏe các phân hệ"
    Accessible.role: Accessible.Pane

    function toneFor(key) {
        const value = String(key || "")
        if (value === "danger") return Theme.danger
        if (value === "warning") return Theme.warning
        if (value === "success") return Theme.success
        if (value === "info") return Theme.info
        if (value === "accent") return Theme.accent
        return Theme.textFaint
    }

    function heartbeatLabel(value) {
        const date = new Date(String(value || ""))
        if (isNaN(date.getTime())) return "Heartbeat không khả dụng"
        return "Heartbeat " + Qt.formatDateTime(date, "HH:mm:ss")
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        ColumnLayout {
            Layout.preferredWidth: 292
            Layout.minimumWidth: 292
            Layout.maximumWidth: 292
            spacing: 2
            Text { text: "SỨC KHỎE HỆ THỐNG"; color: Theme.text; font.pixelSize: Theme.fontBody; font.weight: Font.Bold }
            Text {
                id: healthStatus
                objectName: "subsystemHealthStatus"
                Layout.fillWidth: true
                text: String(root.statusDescriptor.label
                    || root.health.reason_code || "Không khả dụng")
                color: root.toneFor(root.statusDescriptor.tone_key)
                font.pixelSize: Theme.fontMetadata
                Layout.preferredHeight: 26
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: String(root.statusDescriptor.detail || "Dữ liệu kiểm tra từ máy chủ")
                color: Theme.textFaint
                font.pixelSize: Theme.fontMetadata
                elide: Text.ElideRight
            }
        }

        ListView {
            id: subsystemHealthTileList
            objectName: "subsystemHealthTileList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            model: root.healthModel
            orientation: ListView.Horizontal
            spacing: 8
            clip: true
            interactive: false
            delegate: Rectangle {
                id: healthTile
                required property string subsystem
                required property bool available
                required property string state_value
                required property var heartbeat_at
                required property string freshness
                required property string reason
                required property var availability_percent
                required property string label
                required property string icon_key
                required property string tone_key
                required property var state_descriptor
                required property var reason_code
                required property var deep_link
                readonly property bool percentageAvailable:
                    healthTile.availability_percent !== undefined
                    && healthTile.availability_percent !== null
                readonly property string availabilityText: healthTile.percentageAvailable
                    ? String(healthTile.availability_percent) + "%" : "Không khả dụng"
                readonly property string heartbeatDisplay: healthTile.heartbeat_at
                    ? root.heartbeatLabel(healthTile.heartbeat_at)
                    : String(healthTile.reason_code || "Heartbeat không khả dụng")
                signal activate()
                objectName: "subsystemHealth_" + healthTile.subsystem
                width: root.healthTileWidth
                height: subsystemHealthTileList.height
                radius: Theme.radiusMedium
                color: tileMouse.containsMouse ? Theme.hover : Theme.elevated
                border.width: activeFocus ? 2 : 1
                border.color: activeFocus ? Theme.accent : Theme.borderSoft
                activeFocusOnTab: true
                Accessible.name: healthTile.label + ", "
                    + String((healthTile.state_descriptor || {}).label || "Không khả dụng")
                    + ", availability " + healthTile.availabilityText
                Accessible.description: Boolean((healthTile.deep_link || {}).route)
                    ? "Mở chi tiết hệ thống theo deep link server"
                    : String(healthTile.reason_code || "Không có deep link chi tiết")
                Accessible.role: Accessible.Button
                onActivate: {
                    const link = healthTile.deep_link || ({})
                    if (link.route) root.actionRequested({
                        "available": true,
                        "kind": "navigation",
                        "deep_link": link
                    })
                }
                Keys.onSpacePressed: healthTile.activate()
                Keys.onReturnPressed: healthTile.activate()

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 2
                    RowLayout {
                        Layout.fillWidth: true
                        UiIcon {
                            name: healthTile.icon_key
                            tone: root.toneFor(healthTile.tone_key)
                            iconSize: 17
                            Layout.preferredWidth: 17
                            Layout.preferredHeight: 17
                        }
                        Text { Layout.fillWidth: true; text: healthTile.label; color: Theme.text; font.pixelSize: Theme.fontMetadata; font.weight: Font.Bold; elide: Text.ElideRight }
                        Text { text: healthTile.availabilityText; color: healthTile.percentageAvailable ? Theme.textMuted : Theme.warning; font.pixelSize: Theme.fontMetadata; font.weight: Font.DemiBold }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: String((healthTile.state_descriptor || {}).label || "Không khả dụng")
                            + " · " + String(healthTile.freshness || "Không rõ")
                        color: root.toneFor((healthTile.state_descriptor || {}).tone_key)
                        font.pixelSize: Theme.fontMetadata
                        elide: Text.ElideRight
                    }
                    Text { Layout.fillWidth: true; text: healthTile.heartbeatDisplay; color: Theme.textFaint; font.pixelSize: Theme.fontMetadata; elide: Text.ElideRight }
                }
                MouseArea {
                    id: tileMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: Boolean((healthTile.deep_link || {}).route)
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: healthTile.activate()
                }
            }
        }

        AppButton {
            objectName: "systemDetailsButton"
            Layout.preferredWidth: 190
            Layout.minimumWidth: 190
            Layout.maximumWidth: 190
            text: String(root.systemDetailsAction.label || "Chi tiết hệ thống")
            leadingIcon: String(root.systemDetailsAction.icon_key || "")
            activeFocusOnTab: true
            enabled: Boolean(root.systemDetailsAction.available)
            availabilityReason: String(root.systemDetailsAction.reason_code || "")
            onClicked: root.actionRequested(root.systemDetailsAction)
        }
    }
}
