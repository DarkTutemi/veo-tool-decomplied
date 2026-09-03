pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "scheduleBacklog"
    property var backlog: ({})
    property var backlogModel: null
    property var controlPlaneBridge: null
    property bool canWrite: false
    property string selectedBacklogId: ""
    property string activePlatformFilter: String(
        (((root.backlog.filters || {}).platform || {}).selected) || ""
    )
    readonly property string evidenceState: String(root.backlog.state || "unavailable")
    readonly property var platformFilterData:
        (root.backlog.filters || {}).platform || ({})
    readonly property var platformOptions: root.platformFilterData.options || []
    readonly property var platformChoices: root.buildPlatformChoices()
    signal scheduleRequested(var item)
    signal queryRequested(var query)
    signal deepLinkRequested(var link)
    Accessible.name: "Nội dung chưa lên lịch"
    Accessible.role: Accessible.Pane

    function formatDuration(seconds) {
        const value = Math.max(0, Number(seconds || 0))
        const minutes = Math.floor(value / 60)
        const remainder = Math.floor(value % 60)
        return String(minutes).padStart(2, "0") + ":"
            + String(remainder).padStart(2, "0")
    }

    function readinessLabel(state) {
        switch (String(state || "")) {
        case "ready": return "Sẵn sàng"
        case "blocked": return "Chưa sẵn sàng"
        default: return "Chưa xác minh"
        }
    }

    function buildPlatformChoices() {
        const values = [{"value": "", "label": "Tất cả nền tảng", "count": root.backlog.total}]
        for (let index = 0; index < root.platformOptions.length; ++index) {
            const option = root.platformOptions[index] || ({})
            const value = String(option.value || "")
            const label = String(option.label || "")
            if (value && label)
                values.push({"value": value, "label": label, "count": option.count})
        }
        return values
    }

    function applyPlatformFilter(platform) {
        root.activePlatformFilter = String(platform || "")
        backlogFilterPopup.close()
        root.queryRequested({"platform": root.activePlatformFilter})
    }

    function ensureRows() {
        backlogList.forceLayout()
    }

    onBacklogChanged: root.activePlatformFilter = String(
        (((root.backlog.filters || {}).platform || {}).selected) || ""
    )
    onEvidenceStateChanged: Qt.callLater(root.ensureRows)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            Layout.leftMargin: 14
            Layout.rightMargin: 12
            Text { text: "Chưa lên lịch"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.DemiBold }
            Rectangle {
                implicitWidth: countText.implicitWidth + 14
                implicitHeight: 22
                radius: 11
                color: Theme.elevated
                Text {
                    id: countText
                    anchors.centerIn: parent
                    text: root.backlog.total === null || root.backlog.total === undefined
                        ? "—" : String(root.backlog.total)
                    color: Theme.textMuted
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
            }
            Item { Layout.fillWidth: true }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 6
            ScheduleField {
                id: backlogSearch
                objectName: "scheduleBacklogSearch"
                Layout.fillWidth: true
                placeholderText: "Tìm nội dung…"
                enabled: root.evidenceState === "ready"
                Accessible.name: "Tìm backlog nội dung"
                Accessible.description: enabled
                    ? "Truy vấn tìm kiếm phía server"
                    : "Backlog chưa có evidence sẵn sàng"
                onAccepted: root.queryRequested({"search": text.trim()})
            }
            Foundation.IconButton {
                objectName: "scheduleBacklogApplySearch"
                iconName: "ui/chevron-right"
                text: ""
                accessibleName: "Áp dụng tìm kiếm backlog phía server"
                enabled: root.evidenceState === "ready"
                Accessible.description: enabled
                    ? "Gửi truy vấn tìm kiếm backlog phía server"
                    : "Backlog chưa có evidence sẵn sàng"
                onClicked: root.queryRequested({"search": backlogSearch.text.trim()})
            }
            Foundation.IconButton {
                objectName: "scheduleBacklogFilterButton"
                iconName: "ui/filter"
                text: ""
                accessibleName: "Bộ lọc backlog"
                enabled: root.evidenceState === "ready"
                    && root.platformOptions.length > 0
                Accessible.description: enabled
                    ? "Lọc platform phía server"
                    : root.evidenceState !== "ready"
                        ? "Backlog chưa có evidence sẵn sàng"
                        : "Server chưa trả platform filter options"
                onClicked: backlogFilterPopup.open()
            }
        }
        Item {
            Layout.preferredWidth: 0
            Layout.preferredHeight: 0
            Popup {
                id: backlogFilterPopup
                objectName: "scheduleBacklogFilterPopup"
                parent: root
                x: Math.max(8, root.width - width - 10)
                y: 86
                width: 178
                padding: 5
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                contentItem: ColumnLayout {
                spacing: 3
                Repeater {
                    model: root.platformChoices
                    delegate: ItemDelegate {
                        id: filterOption
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 32
                        objectName: "scheduleBacklogFilter_"
                            + (String(filterOption.modelData.value || "all"))
                        Accessible.name: String(filterOption.modelData.label)
                        contentItem: RowLayout {
                            spacing: 7
                            SocialIcon {
                                visible: Boolean(filterOption.modelData.value)
                                platform: String(filterOption.modelData.value || "generic")
                                Layout.preferredWidth: 14
                                Layout.preferredHeight: 14
                            }
                            Text {
                                Layout.fillWidth: true
                                text: String(filterOption.modelData.label)
                                    + (filterOption.modelData.count === null
                                        || filterOption.modelData.count === undefined
                                        ? "" : "  ·  " + String(filterOption.modelData.count))
                                color: Theme.textMuted
                                font.pixelSize: 11
                            }
                            UiIcon {
                                visible: root.activePlatformFilter
                                    === String(filterOption.modelData.value)
                                name: "semantic/check-circle"
                                tone: Theme.success
                                iconSize: 12
                            }
                        }
                        background: Rectangle {
                            radius: Theme.radiusSmall
                            color: filterOption.hovered ? Theme.hover : "transparent"
                        }
                        onClicked: root.applyPlatformFilter(
                            String(filterOption.modelData.value)
                        )
                    }
                }
            }
                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: Theme.panel
                    border.width: 1
                    border.color: Theme.border
                }
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ListView {
                id: backlogList
                objectName: "scheduleBacklogList"
                anchors.fill: parent
                anchors.margins: 8
                visible: root.evidenceState === "ready"
                spacing: 6
                clip: true
                model: root.backlogModel
                delegate: Rectangle {
                    id: backlogCard
                    required property string entity_id
                    required property string content_id
                    required property string content_package_id
                    required property string title
                    required property string platform
                    required property var channel
                    required property var duration_seconds
                    required property var readiness
                    required property var thumbnail
                    required property var deep_link
                    objectName: "scheduleBacklogCard_" + String(backlogCard.entity_id || "unknown")
                    readonly property var itemData: ({
                        "id": backlogCard.entity_id,
                        "content_id": backlogCard.content_id,
                        "content_package_id": backlogCard.content_package_id,
                        "title": backlogCard.title,
                        "platform": backlogCard.platform,
                        "channel": backlogCard.channel,
                        "duration_seconds": backlogCard.duration_seconds,
                        "readiness": backlogCard.readiness,
                        "thumbnail": backlogCard.thumbnail,
                        "deep_link": backlogCard.deep_link
                    })
                    function activate() {
                        root.selectedBacklogId = String(backlogCard.entity_id)
                    }
                    function stage() {
                        root.selectedBacklogId = String(backlogCard.entity_id)
                        if (!root.canWrite || String((backlogCard.readiness || {}).state)
                                !== "ready")
                            return false
                        root.scheduleRequested(backlogCard.itemData)
                        return true
                    }
                    function openContent() {
                        root.selectedBacklogId = String(backlogCard.entity_id)
                        root.deepLinkRequested(backlogCard.deep_link)
                    }
                    function openActions() {
                        const point = backlogCard.mapToItem(
                            root, Math.max(8, backlogCard.width - 178), 28
                        )
                        backlogActionPopup.x = point.x
                        backlogActionPopup.y = point.y
                        backlogActionPopup.open()
                    }
                    width: backlogList.width
                    height: 82
                    radius: Theme.radiusSmall
                    color: root.selectedBacklogId === backlogCard.entity_id
                        ? Theme.accentSoft : Theme.elevated
                    border.width: 1
                    border.color: root.selectedBacklogId === backlogCard.entity_id
                        ? Theme.accent : Theme.borderSoft
                    Accessible.name: String(backlogCard.title || "Nội dung backlog")
                    Accessible.description: root.canWrite
                        && String((backlogCard.readiness || {}).state) === "ready"
                        ? "Chọn để xem; kéo để mở bản nháp lập lịch; menu có thao tác backend"
                        : "Chọn để xem; lập lịch không khả dụng vì thiếu quyền hoặc readiness"
                    Accessible.role: Accessible.ListItem
                    activeFocusOnTab: true
                    Accessible.focusable: true
                    Keys.onReturnPressed: backlogCard.activate()
                    Keys.onEnterPressed: backlogCard.activate()
                    Keys.onSpacePressed: backlogCard.activate()
                    RowLayout {
                        z: 1
                        anchors.fill: parent
                        anchors.margins: 10
                        Rectangle {
                            Layout.preferredWidth: 54
                            Layout.preferredHeight: 54
                            radius: Theme.radiusSmall
                            color: Theme.elevated
                            clip: true
                            Image {
                                id: backlogThumbnail
                                objectName: "scheduleBacklogThumbnail_"
                                    + String(backlogCard.entity_id || "unknown")
                                anchors.fill: parent
                                readonly property string resolvedThumbnailUrl:
                                    Boolean((backlogCard.thumbnail || {}).available)
                                    && root.controlPlaneBridge
                                    ? String(root.controlPlaneBridge.authorizedThumbnailUrl(
                                        String((backlogCard.thumbnail || {}).asset_id || ""),
                                        String((backlogCard.thumbnail || {}).thumbnail_url || "")) || "")
                                    : ""
                                readonly property bool loadReady: status === Image.Ready
                                visible: Boolean(resolvedThumbnailUrl)
                                    && status !== Image.Error
                                source: resolvedThumbnailUrl
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: false
                            }
                            SocialIcon {
                                objectName: "scheduleBacklogThumbnailFallback_"
                                    + String(backlogCard.entity_id || "unknown")
                                anchors.centerIn: parent
                                visible: !Boolean((backlogCard.thumbnail || {}).available)
                                    || !Boolean(backlogThumbnail.resolvedThumbnailUrl)
                                    || backlogThumbnail.status === Image.Error
                                platform: String(backlogCard.platform || "generic")
                                width: 22
                                height: 22
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                SocialIcon {
                                    platform: String(backlogCard.platform || "generic")
                                    Layout.preferredWidth: 13
                                    Layout.preferredHeight: 13
                                }
                                Text { Layout.fillWidth: true; text: String(backlogCard.title || ""); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            }
                            Text { Layout.fillWidth: true; text: String((backlogCard.channel || {}).display_name || ""); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Text {
                                    objectName: "scheduleBacklogDuration_"
                                        + String(backlogCard.entity_id || "unknown")
                                    text: root.formatDuration(backlogCard.duration_seconds)
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                }
                                Text {
                                    objectName: "scheduleBacklogReadiness_"
                                        + String(backlogCard.entity_id || "unknown")
                                    text: root.readinessLabel(
                                        (backlogCard.readiness || {}).state
                                    )
                                    color: String((backlogCard.readiness || {}).state)
                                        === "ready" ? Theme.success : Theme.warning
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }
                                Item { Layout.fillWidth: true }
                            }
                        }
                        Foundation.IconButton {
                            objectName: "scheduleBacklogOverflow_"
                                + String(backlogCard.entity_id || "unknown")
                            iconName: "ui/more-vertical"
                            text: ""
                            accessibleName: "Thao tác " + String(backlogCard.title)
                            Accessible.description: "Mở nội dung hoặc mở bản nháp lập lịch"
                            onClicked: backlogCard.openActions()
                        }
                    }
                    Popup {
                        id: backlogActionPopup
                        objectName: "scheduleBacklogMenu_"
                            + String(backlogCard.entity_id || "unknown")
                        parent: root
                        width: 174
                        padding: 5
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                        contentItem: ColumnLayout {
                            spacing: 3
                            AppButton {
                                objectName: "scheduleBacklogOpen_"
                                    + String(backlogCard.entity_id || "unknown")
                                Layout.fillWidth: true
                                text: "Mở nội dung"
                                leadingIcon: "ui/external-link"
                                availabilityReason: String((backlogCard.deep_link || {}).route || "")
                                    ? "" : "Snapshot không trả deep link nội dung"
                                enabled: !availabilityReason
                                onClicked: {
                                    backlogActionPopup.close()
                                    backlogCard.openContent()
                                }
                            }
                            AppButton {
                                objectName: "scheduleBacklogSchedule_"
                                    + String(backlogCard.entity_id || "unknown")
                                Layout.fillWidth: true
                                text: "Lập lịch"
                                leadingIcon: "ui/plus"
                                enabled: root.canWrite
                                    && String((backlogCard.readiness || {}).state)
                                        === "ready"
                                availabilityReason: enabled
                                    ? "" : !root.canWrite
                                        ? "Thiếu quyền workspace.write"
                                        : String(((backlogCard.readiness || {}).reason_codes || [])[0] || "Content chưa sẵn sàng")
                                Accessible.name: "Lập lịch " + String(backlogCard.title)
                                onClicked: {
                                    backlogActionPopup.close()
                                    backlogCard.stage()
                                }
                            }
                        }
                        background: Rectangle {
                            radius: Theme.radiusSmall
                            color: Theme.panel
                            border.width: 1
                            border.color: Theme.border
                        }
                    }
                    MouseArea {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.rightMargin: 42
                        z: 0
                        cursorShape: Qt.OpenHandCursor
                        property real startX: 0
                        property real startY: 0
                        onPressed: function(mouse) {
                            startX = mouse.x
                            startY = mouse.y
                            cursorShape = Qt.ClosedHandCursor
                        }
                        onReleased: function(mouse) {
                            cursorShape = Qt.OpenHandCursor
                            const delta = Math.abs(mouse.x - startX)
                                + Math.abs(mouse.y - startY)
                            if (delta >= 10)
                                backlogCard.stage()
                            else
                                backlogCard.activate()
                        }
                    }
                }
            }
            ColumnLayout {
                anchors.centerIn: parent
                width: Math.max(160, parent.width - 34)
                visible: root.evidenceState !== "ready"
                spacing: 8
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 18
                    color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.14)
                    UiIcon { anchors.centerIn: parent; name: "semantic/alert-triangle"; tone: Theme.warning; iconSize: 18 }
                }
                Text { Layout.fillWidth: true; text: "Nguồn nội dung chưa khả dụng"; color: Theme.text; font.pixelSize: 13; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter }
                Text {
                    Layout.fillWidth: true
                    text: "Nguồn nội dung chưa được liên kết với không gian làm việc này."
                    color: Theme.textFaint
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            color: Theme.elevated
            Text {
                anchors.centerIn: parent
                width: parent.width - 24
                text: root.evidenceState === "ready"
                    ? "Chọn nội dung để xem; bấm Lập lịch để mở bản nháp"
                    : "Không có thao tác khi nguồn dữ liệu chưa xác thực"
                color: Theme.textFaint
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }
    }
}
