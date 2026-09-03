pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "contentReuseStrip"
    property var reuseData: ({})
    property var reuseModel
    property var controlPlaneBridge: null
    property bool recommendationAvailable: Boolean(root.reuseData.recommendation_available)
    property string title: String(root.reuseData.label || (
        root.recommendationAvailable
            ? "Đề xuất tái sử dụng" : "Tài nguyên gần đây"
    ))
    readonly property string reasonText: root.recommendationAvailable
        ? String(root.reuseData.reason_label
            || "Tương thích aspect, quyền, brand, ngôn ngữ và platform đã được xác minh")
        : String(root.reuseData.reason_code || "")
            === "REUSE_COMPATIBILITY_EVIDENCE_INCOMPLETE"
            ? "Chưa đủ bằng chứng tương thích · sắp theo gần đây"
            : "Không xếp hạng tương thích · chỉ sắp theo gần đây"
    signal itemRequested(var item)

    function durationText(value) {
        const seconds = Math.max(0, Math.round(Number(value || 0)))
        if (seconds <= 0) return ""
        const minutes = Math.floor(seconds / 60)
        const remainder = seconds % 60
        return String(minutes) + ":" + (remainder < 10 ? "0" : "")
            + String(remainder)
    }

    function platformKey(value) {
        const key = String(value || "").toLowerCase()
        if (key.indexOf("tiktok") >= 0) return "tiktok"
        if (key.indexOf("youtube") >= 0) return "youtube"
        if (key.indexOf("facebook") >= 0) return "facebook"
        if (key.indexOf("instagram") >= 0) return "instagram"
        if (key === "x" || key.indexOf("twitter") >= 0) return "x"
        return ""
    }

    function platformIcon(value) {
        const key = root.platformKey(value)
        return key ? "product/" + key : "semantic/video"
    }

    function platformTone(value) {
        const key = root.platformKey(value)
        if (key === "youtube") return "#ff4d5f"
        if (key === "facebook") return "#5f8cff"
        if (key === "instagram") return "#e65ea3"
        if (key === "tiktok") return "#5eead4"
        if (key === "x") return "#5b6472"
        return Theme.textMuted
    }

    function compatibilityMatched(value) {
        const compatibility = value || ({})
        return Boolean(compatibility.available)
            && Number(compatibility.score) === 100
    }

    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.name: root.title
    Accessible.role: Accessible.Pane

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: root.title
                color: Theme.text
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
            AppButton {
                objectName: "contentReuseViewAllButton"
                text: "Xem tất cả"
                subtle: true
                enabled: Boolean((root.reuseData.deep_link || {}).route)
                availabilityReason: enabled ? "" : "Snapshot không có deep link xem toàn bộ"
                Accessible.name: text
                onClicked: root.itemRequested({"deep_link": root.reuseData.deep_link})
            }
            Text {
                Layout.fillWidth: true
                visible: !root.recommendationAvailable
                text: root.reasonText
                color: Theme.warning
                font.pixelSize: 11
            }
            Item { Layout.fillWidth: root.recommendationAvailable }
            Text {
                visible: !root.recommendationAvailable
                text: String(root.reuseModel ? root.reuseModel.count : 0) + " tài nguyên"
                color: Theme.textFaint
                font.pixelSize: 11
            }
            AppButton {
                objectName: "contentReuseNextButton"
                text: ""
                leadingIcon: "ui/chevron-right"
                subtle: true
                enabled: reuseList.contentWidth > reuseList.width
                    && reuseList.contentX < reuseList.contentWidth - reuseList.width
                availabilityReason: enabled ? "" : "Không còn thẻ đề xuất phía sau"
                Accessible.name: "Xem đề xuất tiếp theo"
                onClicked: reuseList.contentX = Math.min(
                    reuseList.contentWidth - reuseList.width,
                    reuseList.contentX + 220
                )
            }
        }

        ListView {
            id: reuseList
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 8
            clip: true
            model: root.reuseModel
            boundsBehavior: Flickable.StopAtBounds
            delegate: Rectangle {
                id: card
                required property string entity_id
                required property var file_name
                required property var media_type
                required property var display_name
                required property var type_label
                required property var duration_seconds
                required property var probe
                required property var reuse_count
                required property var compatibility
                required property var source
                required property var channel
                required property var platform
                required property var thumbnail
                required property var deep_link
                objectName: "contentReuseCard_" + String(card.entity_id || "unknown")
                width: 224
                height: ListView.view.height
                radius: Theme.radiusMedium
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                Accessible.name: String(card.display_name || card.file_name || "Tài nguyên")
                Accessible.role: Accessible.ListItem
                activeFocusOnTab: true
                Accessible.focusable: true
                Keys.onReturnPressed: root.itemRequested({"id": card.entity_id, "deep_link": card.deep_link})
                Keys.onEnterPressed: root.itemRequested({"id": card.entity_id, "deep_link": card.deep_link})
                Keys.onSpacePressed: root.itemRequested({"id": card.entity_id, "deep_link": card.deep_link})

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8
                    Rectangle {
                        Layout.preferredWidth: 78
                        Layout.fillHeight: true
                        radius: Theme.radiusSmall
                        color: Theme.hover
                        Image {
                            id: reuseThumbnailImage
                            readonly property string resolvedThumbnailUrl:
                                Boolean((card.thumbnail || {}).available)
                                    && root.controlPlaneBridge
                                ? root.controlPlaneBridge.authorizedThumbnailUrl(
                                    String((card.thumbnail || {}).asset_id || ""),
                                    String((card.thumbnail || {}).thumbnail_url || ""))
                                : ""
                            objectName: "contentReuseThumbnail_" + String(
                                card.entity_id || "unknown")
                            anchors.fill: parent
                            anchors.margins: 1
                            visible: resolvedThumbnailUrl.length > 0
                            source: resolvedThumbnailUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                        UiIcon {
                            anchors.centerIn: parent
                            visible: reuseThumbnailImage.resolvedThumbnailUrl.length === 0
                            name: "semantic/video"
                            tone: Theme.textFaint
                            iconSize: 20
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            objectName: "contentReuseDisplayName_" + String(
                                card.entity_id || "unknown")
                            Layout.fillWidth: true
                            text: String(card.display_name || card.file_name || "Tài nguyên")
                            color: Theme.text
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                Layout.fillWidth: true
                                text: String(card.type_label || card.media_type || "Tài nguyên")
                                    + (root.durationText(card.duration_seconds
                                        || (card.probe || {}).duration_seconds)
                                        ? " · " + root.durationText(card.duration_seconds
                                            || (card.probe || {}).duration_seconds)
                                        : "")
                                color: Theme.textFaint
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                            Rectangle {
                                objectName: "contentReuseCount_" + String(
                                    card.entity_id || "unknown")
                                Layout.preferredWidth: reuseCountLabel.implicitWidth + 10
                                Layout.preferredHeight: 19
                                radius: 9
                                color: Qt.rgba(Theme.warning.r, Theme.warning.g,
                                    Theme.warning.b, 0.13)
                                Text {
                                    id: reuseCountLabel
                                    anchors.centerIn: parent
                                    text: String(Number(card.reuse_count || 0)) + " lượt"
                                    color: Theme.warning
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            Rectangle {
                                objectName: "contentReusePlatformMark_" + String(
                                    card.entity_id || "unknown")
                                Layout.preferredWidth: 22
                                Layout.preferredHeight: 22
                                radius: 6
                                color: root.platformTone(card.platform
                                    || (card.channel || {}).platform)
                                UiIcon {
                                    anchors.centerIn: parent
                                    name: root.platformIcon(card.platform
                                        || (card.channel || {}).platform)
                                    tone: "white"
                                    iconSize: 13
                                }
                            }
                            Text {
                                objectName: "contentReuseSource_" + String(
                                    card.entity_id || "unknown")
                                Layout.fillWidth: true
                                text: String((card.channel || {}).name
                                    || (card.source || {}).label || "Nguồn chưa xác định")
                                color: Theme.textMuted
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                            UiIcon {
                                objectName: "contentReuseCompatibilityCheck_"
                                    + String(card.entity_id || "unknown")
                                visible: root.compatibilityMatched(card.compatibility)
                                name: "semantic/check-circle"
                                tone: Theme.success
                                iconSize: 13
                            }
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.itemRequested({
                        "id": card.entity_id,
                        "deep_link": card.deep_link
                    })
                }
            }
        }
    }
}
