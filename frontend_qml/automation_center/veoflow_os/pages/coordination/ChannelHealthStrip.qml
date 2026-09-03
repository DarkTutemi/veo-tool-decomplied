pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Rectangle {
    id: root
    objectName: "channelHealthStrip"
    property var healthModel
    property string referenceTimestamp: ""
    signal channelActivated(string channelId, string healthCode)
    signal addChannelRequested()

    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.name: "Tình trạng kênh"
    Accessible.role: Accessible.Pane

    function healthTone(value) {
        const state = String(value || "").toLowerCase()
        if (state === "healthy") return Theme.success
        if (state === "warning" || state === "degraded") return Theme.warning
        if (state === "blocked" || state === "unhealthy") return Theme.danger
        return Theme.textFaint
    }

    function healthLabel(value) {
        const labels = {
            "healthy": "Tốt",
            "warning": "Cảnh báo",
            "degraded": "Suy giảm",
            "blocked": "Bị chặn",
            "unhealthy": "Không khỏe",
            "unknown": "Không rõ"
        }
        return labels[String(value || "unknown").toLowerCase()] || String(value || "Không rõ")
    }

    Item {
        anchors.fill: parent
        anchors.margins: 10

        RowLayout {
            id: healthHeading
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 20
            spacing: 10
            Text { text: "Tình trạng kênh"; color: Theme.text; font.pixelSize: 13; font.weight: Font.Bold }
            Text {
                objectName: "channelHealthEvidenceCount"
                Layout.fillWidth: true
                text: (root.healthModel ? root.healthModel.count : 0) + " kênh có bằng chứng sức khỏe"
                color: Theme.textFaint
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }

        ListView {
            id: healthList
            objectName: "channelHealthList"
            anchors.left: parent.left
            anchors.right: addChannelButton.left
            anchors.rightMargin: 10
            anchors.top: healthHeading.bottom
            anchors.topMargin: 6
            anchors.bottom: parent.bottom
            orientation: ListView.Horizontal
            model: root.healthModel
            spacing: 8
            clip: true
            reuseItems: true
            boundsBehavior: Flickable.StopAtBounds
            Accessible.name: "Danh sách tình trạng kênh"
            Accessible.role: Accessible.List

            delegate: Rectangle {
                id: healthTile
                objectName: "channelHealthTile_" + healthTile.channelId
                required property string channel_id
                required property var platform
                required property var display_name
                required property var handle
                required property var health_state
                required property var health_code
                required property var health_summary
                required property var last_checked_at

                readonly property string channelId: String(healthTile.channel_id || "")
                readonly property string displayName: String(healthTile.display_name || "")
                readonly property string healthState: String(healthTile.health_state || "unknown")
                readonly property string healthCode: String(healthTile.health_code || "UNKNOWN")
                readonly property string healthSummary: String(healthTile.health_summary || "")
                readonly property string lastCheckedAt: String(healthTile.last_checked_at || "")

                function activate() {
                    root.channelActivated(healthTile.channelId, healthTile.healthCode)
                }

                width: Math.max(160, Math.min(220,
                    (healthList.width - healthList.spacing
                        * Math.max(0, healthList.count - 1))
                        / Math.max(1, healthList.count)))
                height: healthList.height
                radius: Theme.radiusMedium
                color: tileMouse.containsMouse ? Theme.hover : Theme.elevated
                border.width: 1
                border.color: root.healthTone(healthTile.healthState)
                activeFocusOnTab: true
                Accessible.name: healthTile.displayName + ". "
                    + root.healthLabel(healthTile.healthState) + ". "
                    + (healthTile.healthSummary || "Không có mô tả sức khỏe")
                Accessible.role: Accessible.Button
                Keys.onReturnPressed: healthTile.activate()
                Keys.onEnterPressed: healthTile.activate()

                Behavior on color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 9
                    SocialIcon {
                        platform: healthTile.platform || "generic"
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        Layout.alignment: Qt.AlignVCenter
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1
                        Text { Layout.fillWidth: true; text: healthTile.displayName || "Kênh chưa có tên"; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
                        Text { Layout.fillWidth: true; text: healthTile.handle || healthTile.healthCode || "Không rõ định danh"; color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                        Foundation.RelativeTimeText {
                            objectName: "channelRelativeTime_" + healthTile.channelId
                            visible: healthTile.lastCheckedAt.length > 0
                            timestamp: healthTile.lastCheckedAt
                            referenceTimestamp: root.referenceTimestamp
                        }
                    }
                    Foundation.StatusPill {
                        Layout.alignment: Qt.AlignVCenter
                        text: root.healthLabel(healthTile.healthState)
                        tone: root.healthTone(healthTile.healthState)
                        pulse: healthTile.healthState === "healthy"
                    }
                }

                MouseArea {
                    id: tileMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        healthTile.forceActiveFocus()
                        healthTile.activate()
                    }
                }
                ToolTip.visible: tileMouse.containsMouse
                ToolTip.text: healthTile.healthSummary || "Không có mô tả sức khỏe"
            }

            ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }

            Text {
                anchors.centerIn: parent
                visible: healthList.count === 0
                text: "Chưa có dữ liệu sức khỏe kênh"
                color: Theme.textFaint
                font.pixelSize: 11
            }
        }

        Button {
            id: addChannelButton
            objectName: "coordinationAddChannelButton"
            activeFocusOnTab: true
            width: 110
            anchors.right: parent.right
            anchors.top: healthHeading.bottom
            anchors.topMargin: 6
            anchors.bottom: parent.bottom
            text: "+ Thêm kênh"
            hoverEnabled: true
            Accessible.name: "Mở quy trình thêm kênh"
            Accessible.role: Accessible.Button
            onClicked: root.addChannelRequested()
            contentItem: Text { text: addChannelButton.text; color: Theme.textMuted; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            background: Rectangle {
                radius: Theme.radiusMedium
                color: addChannelButton.hovered ? Theme.hover : "transparent"
                border.width: 1
                border.color: Theme.border
            }
        }
    }
}
