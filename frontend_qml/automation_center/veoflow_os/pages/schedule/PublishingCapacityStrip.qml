pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "publishingCapacityStrip"
    property var capacity: ({})
    property var capacityModel: null
    property bool canWrite: false
    signal filterRequested(var filter)
    signal syncRequested
    signal createRequested
    signal editRequested(var policy)
    Accessible.name: "Tình trạng xuất bản hôm nay"
    Accessible.role: Accessible.Pane

    function normalizedOptional(value) {
        if (value === undefined || value === null)
            return ""
        const text = String(value).trim()
        const lowered = text.toLowerCase()
        return lowered === "undefined" || lowered === "null" ? "" : text
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 9
        spacing: 8
        ColumnLayout {
            id: capacitySummary
            objectName: "scheduleCapacitySummary"
            Layout.minimumWidth: 170
            Layout.preferredWidth: 170
            Layout.maximumWidth: 170
            spacing: 1
            Text {
                Layout.fillWidth: true
                text: "Sức chứa phát hành"
                color: Theme.text
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
            Text {
                Layout.fillWidth: true
                text: "Chính sách theo nền tảng hoặc từng kênh"
                color: Theme.textFaint
                font.pixelSize: 11
                elide: Text.ElideRight
            }
            RowLayout {
                objectName: "scheduleCapacityHeaderActions"
                Layout.fillWidth: true
                spacing: 5
                Text {
                    Layout.fillWidth: true
                    text: root.capacity.synced_at
                        ? "Đồng bộ " + String(root.capacity.synced_at).slice(11, 16)
                        : "Chưa đồng bộ"
                    color: Theme.textFaint
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
                Foundation.IconButton {
                    id: capacitySyncButton
                    objectName: "scheduleCapacitySyncButton"
                    text: ""
                    iconName: "ui/refresh-cw"
                    iconSize: 16
                    accessibleName: "Đồng bộ chính sách sức chứa từ hệ thống"
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0
                    Layout.minimumWidth: 28
                    Layout.preferredWidth: 28
                    Layout.maximumWidth: 28
                    Layout.minimumHeight: 24
                    Layout.preferredHeight: 24
                    activeFocusOnTab: true
                    background: Rectangle {
                        radius: Theme.radiusSmall
                        color: capacitySyncButton.down
                            ? Theme.accentSoft
                            : capacitySyncButton.hovered ? Theme.hover : Theme.elevated
                        border.width: 1
                        border.color: capacitySyncButton.activeFocus
                            ? Theme.accent : Theme.border
                    }
                    onClicked: root.syncRequested()
                }
                Foundation.IconButton {
                    id: capacityCreateButton
                    objectName: "scheduleCapacityCreateButton"
                    text: ""
                    iconName: "ui/plus"
                    iconSize: 16
                    accessibleName: "Tạo chính sách sức chứa"
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0
                    Layout.minimumWidth: 28
                    Layout.preferredWidth: 28
                    Layout.maximumWidth: 28
                    Layout.minimumHeight: 24
                    Layout.preferredHeight: 24
                    enabled: root.canWrite
                    activeFocusOnTab: true
                    Accessible.description: enabled ? "Mở biểu mẫu quy tắc sức chứa" : "Bạn không có quyền quản trị"
                    background: Rectangle {
                        radius: Theme.radiusSmall
                        color: !capacityCreateButton.enabled
                            ? Theme.elevated
                            : capacityCreateButton.down
                                ? Theme.accentSoft
                                : capacityCreateButton.hovered ? Theme.hover : Theme.elevated
                        border.width: 1
                        border.color: capacityCreateButton.activeFocus
                            ? Theme.accent : Theme.border
                    }
                    onClicked: root.createRequested()
                }
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: capacityList
                objectName: "scheduleCapacityList"
                anchors.fill: parent
                orientation: ListView.Horizontal
                spacing: 8
                clip: true
                model: root.capacityModel
                Accessible.name: "Danh sách quy tắc sức chứa"
                Accessible.role: Accessible.List

                delegate: Rectangle {
                    id: capacityTile
                    required property string entity_id
                    required property string policy_key
                    required property int version
                    required property var channel_id
                    required property var platform
                    required property int scheduled
                    required property var limit
                    required property int minimum_gap_minutes
                    required property string timezone
                    required property var windows
                    required property string policy_state
                    required property string health
                    required property string freshness
                    required property string observed_at
                    required property var expires_at
                    required property var scope
                    required property var evidence
                    required property var next_free_slot
                    objectName: "scheduleCapacity_" + capacityTile.entity_id
                    readonly property string normalizedChannelId:
                        root.normalizedOptional(capacityTile.channel_id)
                    readonly property string normalizedPlatform:
                        root.normalizedOptional(capacityTile.platform).toLowerCase()
                    function activate() {
                        const filter = ({})
                        if (capacityTile.normalizedChannelId)
                            filter.channel_id = capacityTile.normalizedChannelId
                        if (capacityTile.normalizedPlatform)
                            filter.platform = capacityTile.normalizedPlatform
                        root.filterRequested(filter)
                    }
                    readonly property var itemData: ({
                            "id": capacityTile.entity_id,
                            "policy_key": capacityTile.policy_key,
                            "version": capacityTile.version,
                            "channel_id": capacityTile.normalizedChannelId,
                            "platform": capacityTile.normalizedPlatform,
                            "daily_limit": capacityTile.limit,
                            "minimum_gap_minutes": capacityTile.minimum_gap_minutes,
                            "timezone": capacityTile.timezone,
                            "windows": capacityTile.windows,
                            "state": capacityTile.policy_state,
                            "observed_at": capacityTile.observed_at,
                            "expires_at": capacityTile.expires_at,
                            "scope": capacityTile.scope,
                            "evidence": capacityTile.evidence
                        })
                    width: Math.min(
                        292,
                        Math.max(
                            196,
                            (capacityList.width
                                - Math.max(0, capacityList.count - 1)
                                    * capacityList.spacing)
                                / Math.max(1, Math.min(5, capacityList.count))
                        )
                    )
                    height: capacityList.height
                    radius: Theme.radiusSmall
                    color: Theme.elevated
                    border.width: 1
                    border.color: capacityTile.freshness === "stale" ? Theme.warning : Theme.borderSoft
                    Accessible.name: "Sức chứa "
                        + root.platformLabel(capacityTile.normalizedPlatform)
                    activeFocusOnTab: true
                    Accessible.role: Accessible.Button
                    Accessible.focusable: true
                    Keys.onReturnPressed: capacityTile.activate()
                    Keys.onSpacePressed: capacityTile.activate()
                    MouseArea {
                        anchors.fill: parent
                        anchors.rightMargin: 58
                        cursorShape: Qt.PointingHandCursor
                        onClicked: capacityTile.activate()
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        spacing: 7
                        SocialIcon {
                            objectName: "scheduleCapacityIcon_" + capacityTile.entity_id
                            platform: capacityTile.normalizedPlatform || "generic"
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 1
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                Text {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    text: String((capacityTile.scope || {}).label
                                        || root.platformLabel(capacityTile.normalizedPlatform))
                                    color: Theme.text
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: capacityTile.health === "ready" ? "Tốt" : "Chú ý"
                                    color: capacityTile.health === "ready" ? Theme.success : Theme.warning
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                text: String(capacityTile.scheduled || 0) + " / " + String(capacityTile.limit ?? "—") + " đã lên lịch"
                                color: Theme.textMuted
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                            Text {
                                text: (capacityTile.next_free_slot || {}).state === "available"
                                    ? "Khe tiếp: " + String(
                                        (capacityTile.next_free_slot || {}).local_time
                                            || (capacityTile.next_free_slot || {}).run_at
                                            || "—"
                                    ).slice(11, 16)
                                    : "Khe tiếp theo: chưa khả dụng"
                                color: Theme.textFaint
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                            }
                        }
                        AppButton {
                            objectName: "scheduleCapacityEdit_" + capacityTile.entity_id
                            text: "Sửa"
                            Layout.minimumWidth: 48
                            Layout.preferredWidth: 48
                            Layout.maximumWidth: 48
                            Layout.minimumHeight: 24
                            Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignBottom
                            enabled: root.canWrite
                            activeFocusOnTab: true
                            Accessible.name: "Sửa sức chứa "
                                + String((capacityTile.scope || {}).label || "phát hành")
                            Accessible.description: enabled
                                ? "Mở bản nháp phiên bản " + capacityTile.version
                                : "Cần quyền quản trị không gian làm việc"
                            onClicked: root.editRequested(capacityTile.itemData)
                        }
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                visible: !root.capacityModel || root.capacityModel.count === 0
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                Text {
                    anchors.centerIn: parent
                    text: "Chưa có chính sách sức chứa"
                    color: Theme.textFaint
                    font.pixelSize: 11
                }
            }
        }
    }

    function platformLabel(value) {
        switch (value) {
        case "youtube":
            return "YouTube";
        case "tiktok":
            return "TikTok";
        case "facebook":
            return "Facebook";
        case "instagram":
            return "Instagram";
        case "linkedin":
            return "LinkedIn";
        case "x":
            return "X";
        default:
            return value || "Nền tảng";
        }
    }
}
