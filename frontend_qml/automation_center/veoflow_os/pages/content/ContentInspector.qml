pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Rectangle {
    id: root
    objectName: "contentInspector"
    property var selection: ({})
    property var historyData: ({})
    property var historyModel
    property var controlPlaneBridge: null
    property bool canWrite: false
    property bool packageBusy: false
    property bool deleteBusy: false
    property bool updateBusy: false
    property int activeSection: 0
    signal openDeepLink(var link)
    signal packageRequested()
    signal updateStageRequested()
    signal archiveRequested()
    signal deleteRequested()
    signal closeRequested()

    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    clip: true
    Accessible.name: "Chi tiết nội dung"
    Accessible.role: Accessible.Pane

    readonly property bool available: String(root.selection.state || "") === "available"
        && Boolean((root.selection.content || {}).id)
    readonly property var content: root.available ? (root.selection.content || ({})) : ({})
    readonly property var readiness: root.available ? (root.selection.readiness || ({})) : ({})
    readonly property var actions: root.available ? (root.selection.actions || ({})) : ({})
    readonly property var relatedAssets: root.available ? (root.selection.related_assets || []) : []
    readonly property bool canCreatePackage: root.canWrite
        && Boolean((root.actions.create_package || {}).enabled)
        && root.relatedAssets.length > 0
        && Boolean((root.content.channel || {}).id)
        && !root.packageBusy
    readonly property bool canDelete: root.canWrite
        && Boolean(root.content.id)
        && !root.deleteBusy
    readonly property bool canUpdate: root.canWrite
        && Boolean(root.content.id)
        && Number(root.content.version || 0) > 0
        && !root.updateBusy

    function createPackageAvailabilityReason() {
        if (root.packageBusy)
            return "Đang tạo gói sản xuất"
        if (!root.available)
            return "Chưa chọn nội dung"
        if (!root.canWrite)
            return "Không có quyền tạo gói sản xuất"
        const action = root.actions.create_package || ({})
        if (!Boolean(action.enabled))
            return String(action.reason_code || "Tạo gói sản xuất không khả dụng")
        if (root.relatedAssets.length === 0)
            return "Cần ít nhất một tài nguyên liên quan"
        if (!Boolean((root.content.channel || {}).id))
            return "Nội dung chưa gắn kênh"
        return ""
    }

    function scoreText() {
        const score = root.readiness.score || ({})
        if (score.passed === undefined || score.total === undefined)
            return "—"
        return String(score.passed) + "/" + String(score.total)
    }

    function sectionName(index) {
        return ["Tổng quan", "Kịch bản", "Tài nguyên", "Lịch sử"][index] || ""
    }

    function estimatedDurationText() {
        const duration = root.content.estimated_duration || ({})
        if (!Boolean(duration.available))
            return "Chưa có bằng chứng thời lượng"
        const label = String(duration.label || "")
        if (label) return label + (Boolean(duration.estimated) ? " · ước tính" : "")
        const seconds = Number(duration.seconds || 0)
        return seconds > 0
            ? String(Math.round(seconds)) + " giây"
                + (Boolean(duration.estimated) ? " · ước tính" : "")
            : "Chưa có bằng chứng thời lượng"
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

    function formatLabel(value, aspectRatio) {
        const key = String(value || "").toLowerCase()
        const aspect = String(aspectRatio || "")
        if (key === "vertical_video")
            return "Vertical Video" + (aspect ? " (" + aspect + ")" : "")
        if (key === "short_video")
            return "Video ngắn" + (aspect ? " (" + aspect + ")" : "")
        if (key === "carousel") return "Carousel"
        if (key === "image") return "Hình ảnh"
        return String(value || "—") + (aspect ? " (" + aspect + ")" : "")
    }

    function languageLabel(value) {
        const key = String(value || "").toLowerCase()
        if (key === "vi" || key === "vi-vn") return "Tiếng Việt"
        if (key === "en" || key.indexOf("en-") === 0) return "English"
        if (key === "th" || key.indexOf("th-") === 0) return "ภาษาไทย"
        if (key === "id" || key.indexOf("id-") === 0) return "Bahasa Indonesia"
        return String(value || "—")
    }

    function pillarLabel(value) {
        const key = String(value || "").toLowerCase()
        if (key === "lifestyle") return "Đời sống"
        if (key === "education") return "Giáo dục"
        if (key === "product") return "Sản phẩm"
        if (key === "community") return "Cộng đồng"
        return String(value || "—")
    }

    function readinessStateText(item) {
        const data = item || ({})
        if (String(data.state || "") === "ready") return "Sẵn sàng"
        return String(data.reason_label || data.reason || data.message
            || data.missing_label || "Thiếu bằng chứng")
    }

    function scheduleText(value) {
        if (!value) return "Chưa có lịch"
        const parsed = new Date(String(value))
        return isNaN(parsed.getTime())
            ? "Lịch đã lên"
            : Qt.formatDateTime(parsed, "dd/MM · HH:mm")
    }

    function durationText(value) {
        const seconds = Math.max(0, Math.round(Number(value || 0)))
        if (seconds <= 0) return ""
        const minutes = Math.floor(seconds / 60)
        const remainder = seconds % 60
        return String(minutes) + ":" + (remainder < 10 ? "0" : "")
            + String(remainder)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            id: inspectorTabs
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            Layout.leftMargin: 14
            Layout.rightMargin: 10
            Text {
                Layout.fillWidth: true
                text: "Chi tiết nội dung"
                color: Theme.text
                font.pixelSize: Theme.fontSection
                font.weight: Font.DemiBold
            }
            Foundation.StatusPill {
                visible: root.available
                text: String((root.content.stage || {}).label || "—")
                tone: Boolean(root.readiness.ready) ? Theme.success : Theme.warning
            }
            Foundation.IconButton {
                objectName: "contentInspectorCloseButton"
                iconName: "ui/close"
                text: ""
                accessibleName: "Đóng chi tiết nội dung"
                activeFocusOnTab: true
                onClicked: root.closeRequested()
            }
        }

        Rectangle {
            objectName: "contentInspectorHero"
            Layout.fillWidth: true
            Layout.preferredHeight: root.available ? 120 : 64
            Layout.minimumHeight: root.available ? 120 : 64
            Layout.maximumHeight: root.available ? 120 : 64
            color: Theme.elevated
            border.width: 1
            border.color: Theme.borderSoft
            Loader {
                anchors.fill: parent
                anchors.margins: 12
                active: root.available
                sourceComponent: RowLayout {
                    spacing: 10
                    Rectangle {
                        objectName: "contentInspectorThumbnailFrame"
                        Layout.preferredWidth: 142
                        Layout.minimumWidth: 142
                        Layout.maximumWidth: 142
                        Layout.fillHeight: true
                        radius: Theme.radiusSmall
                        color: Theme.hover
                        border.width: 1
                        border.color: Theme.borderSoft
                        Image {
                            id: inspectorThumbnailImage
                            readonly property string resolvedThumbnailUrl:
                                Boolean((root.content.thumbnail || {}).available)
                                    && root.controlPlaneBridge
                                ? root.controlPlaneBridge.authorizedThumbnailUrl(
                                    String((root.content.thumbnail || {}).asset_id || ""),
                                    String((root.content.thumbnail || {}).thumbnail_url || ""))
                                : ""
                            objectName: "contentInspectorThumbnail"
                            anchors.fill: parent
                            anchors.margins: 1
                            visible: resolvedThumbnailUrl.length > 0
                            source: resolvedThumbnailUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                        Column {
                            anchors.centerIn: parent
                            visible: inspectorThumbnailImage.resolvedThumbnailUrl.length === 0
                            spacing: 4
                            Accessible.name: "Thumbnail "
                                + String(root.content.aspect_ratio || "không rõ tỷ lệ")
                                + " chưa khả dụng"
                            Accessible.role: Accessible.StaticText
                            UiIcon {
                                objectName: "contentInspectorThumbnailPlaceholderIcon"
                                anchors.horizontalCenter: parent.horizontalCenter
                                name: "semantic/video"
                                tone: Theme.textFaint
                                iconSize: 18
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: String(root.content.aspect_ratio || "—")
                                color: Theme.textFaint
                                font.pixelSize: 11
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text {
                            Layout.fillWidth: true
                            text: String(root.content.title || "")
                            color: Theme.text
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 7
                            Rectangle {
                                objectName: "contentInspectorPlatformMark"
                                Layout.preferredWidth: 26
                                Layout.preferredHeight: 26
                                radius: 7
                                color: root.platformTone(
                                    (root.content.channel || {}).platform)
                                UiIcon {
                                    anchors.centerIn: parent
                                    name: root.platformIcon(
                                        (root.content.channel || {}).platform)
                                    tone: "white"
                                    iconSize: 15
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Text {
                                    Layout.fillWidth: true
                                    text: String((root.content.channel || {}).name
                                        || "Chưa gắn kênh")
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String((root.content.channel || {}).platform || "")
                                    color: Theme.textFaint
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }

                }
            }
            Text {
                visible: !root.available
                anchors.centerIn: parent
                text: String(root.selection.state || "empty") === "not_found"
                    ? "Không tìm thấy nội dung đã chọn"
                    : "Chọn một nội dung để xem chi tiết"
                color: Theme.textFaint
                font.pixelSize: 11
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            Row {
                id: contentInspectorTabRow
                anchors.fill: parent
                spacing: 0
                InspectorTabButton { sectionIndex: 0 }
                InspectorTabButton { sectionIndex: 1 }
                InspectorTabButton { sectionIndex: 2 }
                InspectorTabButton { sectionIndex: 3 }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                anchors.fill: parent
                visible: root.activeSection === 0
                clip: true
                contentWidth: availableWidth
                ColumnLayout {
                    width: parent.width
                    spacing: 0
                    DetailRow { label: "Hook"; value: String(root.content.hook || "—") }
                    DetailRow { label: "Đối tượng"; value: String(root.content.target_audience || "—") }
                    DetailRow { label: "Mục tiêu"; value: String(root.content.objective || "—") }
                    DetailRow {
                        label: "Pillar"
                        value: root.pillarLabel(root.content.pillar)
                    }
                    DetailRow {
                        objectName: "contentFormatDetail"
                        label: "Định dạng"
                        value: root.formatLabel(
                            root.content.format, root.content.aspect_ratio)
                    }
                    DetailRow {
                        objectName: "contentEstimatedDuration"
                        label: "Thời lượng"
                        value: root.estimatedDurationText()
                    }
                    DetailRow {
                        objectName: "contentLanguageDetail"
                        label: "Ngôn ngữ"
                        value: root.languageLabel(root.content.language)
                    }
                    DetailRow { label: "CTA"; value: String(root.content.cta || "—") }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: Theme.elevated
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            Text {
                                Layout.fillWidth: true
                                text: "Mức độ sẵn sàng sản xuất"
                                color: Theme.text
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                            Text {
                                id: readinessText
                                objectName: "contentReadinessText"
                                text: root.scoreText()
                                color: Boolean(root.readiness.ready) ? Theme.success : Theme.warning
                                font.pixelSize: 12
                                font.weight: Font.Bold
                            }
                        }
                    }
                    Repeater {
                        model: root.readiness.items || []
                        delegate: Button {
                            id: readinessRow
                            required property var modelData
                            objectName: "contentReadinessItem_"
                                + String(readinessRow.modelData.key || "unknown")
                            Layout.fillWidth: true
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            Layout.preferredHeight: 26
                            activeFocusOnTab: true
                            enabled: Boolean(
                                (readinessRow.modelData.deep_link || {}).route
                            )
                            Accessible.name: "Chi tiết điều kiện "
                                + String(readinessRow.modelData.label
                                    || readinessRow.modelData.key || "không rõ")
                            Accessible.description: enabled
                                ? "Mở bằng chứng do Control Plane chiếu"
                                : String(readinessRow.modelData.reason_code
                                    || "Checklist chưa có deep link chi tiết")
                            onClicked: root.openDeepLink(
                                readinessRow.modelData.deep_link || ({})
                            )
                            background: Rectangle {
                                radius: Theme.radiusSmall
                                color: readinessRow.hovered ? Theme.hover : "transparent"
                            }
                            contentItem: RowLayout {
                                spacing: 7
                                UiIcon {
                                    name: String(readinessRow.modelData.state || "")
                                        === "ready"
                                        ? "semantic/check-circle" : "semantic/alert-circle"
                                    tone: String(readinessRow.modelData.state || "")
                                        === "ready" ? Theme.success : Theme.warning
                                    iconSize: 14
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(readinessRow.modelData.label
                                        || readinessRow.modelData.key || "")
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                }
                                Text {
                                    visible: String(readinessRow.modelData.state || "")
                                        !== "ready"
                                    Layout.maximumWidth: 142
                                    text: root.readinessStateText(readinessRow.modelData)
                                    color: Theme.warning
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                                UiIcon {
                                    visible: String(readinessRow.modelData.state || "")
                                        === "ready"
                                    name: "semantic/check-circle"
                                    tone: Theme.success
                                    iconSize: 14
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 0
                        color: Theme.elevated
                        visible: false
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            ColumnLayout {
                                Layout.fillWidth: true
                                Text { text: "Sẵn sàng phát hành"; color: Theme.textMuted; font.pixelSize: 11 }
                                Text {
                                    text: (root.selection.publication_readiness || {}).ready
                                        ? "Đã đủ lineage" : "Chưa đủ lineage phát hành"
                                    color: (root.selection.publication_readiness || {}).ready
                                        ? Theme.success : Theme.warning
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        Layout.topMargin: 8
                        Text {
                            Layout.fillWidth: true
                            text: "Tài nguyên liên quan"
                            color: Theme.text
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: String(root.relatedAssets.length)
                            color: Theme.textFaint
                            font.pixelSize: 11
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        Layout.preferredHeight: 78
                        spacing: 6
                        Repeater {
                            model: root.relatedAssets.slice(0, 3)
                            delegate: Button {
                                id: overviewAsset
                                required property int index
                                required property var modelData
                                objectName: "contentOverviewRelatedAsset_"
                                    + String(overviewAsset.modelData.id || "unknown")
                                Layout.fillWidth: true
                                Layout.preferredHeight: 74
                                activeFocusOnTab: true
                                enabled: Boolean((overviewAsset.modelData.deep_link || {}).route)
                                Accessible.name: "Mở tài nguyên "
                                    + String(overviewAsset.modelData.file_name || overviewAsset.index + 1)
                                Accessible.description: enabled
                                    ? "Mở deep link do Control Plane cung cấp"
                                    : "Tài nguyên không có deep link được cấp quyền"
                                onClicked: root.openDeepLink(
                                    overviewAsset.modelData.deep_link || ({})
                                )
                                background: Rectangle {
                                    radius: Theme.radiusSmall
                                    color: Theme.elevated
                                    border.width: 1
                                    border.color: overviewAsset.enabled
                                        ? Theme.border : Theme.borderSoft
                                }
                                contentItem: Item {
                                    Image {
                                        id: overviewThumbnail
                                        readonly property string resolvedThumbnailUrl:
                                            Boolean((overviewAsset.modelData.thumbnail || {}).available)
                                                && root.controlPlaneBridge
                                            ? root.controlPlaneBridge.authorizedThumbnailUrl(
                                                String((overviewAsset.modelData.thumbnail || {}).asset_id || ""),
                                                String((overviewAsset.modelData.thumbnail || {}).thumbnail_url || ""))
                                            : ""
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        visible: resolvedThumbnailUrl.length > 0
                                        source: resolvedThumbnailUrl
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                    }
                                    UiIcon {
                                        anchors.centerIn: parent
                                        visible: overviewThumbnail.resolvedThumbnailUrl.length === 0
                                        name: "semantic/video"
                                        tone: Theme.textFaint
                                        iconSize: 18
                                    }
                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        anchors.margins: 3
                                        width: durationLabel.implicitWidth + 6
                                        height: 17
                                        radius: 4
                                        color: Qt.rgba(0, 0, 0, 0.68)
                                        visible: Number(
                                            overviewAsset.modelData.duration_seconds
                                            || (overviewAsset.modelData.probe || {}).duration_seconds || 0
                                        ) > 0
                                        Text {
                                            id: durationLabel
                                            objectName: "contentOverviewRelatedAssetDuration_"
                                                + String(overviewAsset.modelData.id || "unknown")
                                            anchors.centerIn: parent
                                            text: root.durationText(
                                                overviewAsset.modelData.duration_seconds
                                                || (overviewAsset.modelData.probe || {}).duration_seconds)
                                            color: "white"
                                            font.pixelSize: 11
                                        }
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        Layout.bottomMargin: 8
                        spacing: 8
                        AppButton {
                            id: campaignButton
                            readonly property var campaign: root.content.campaign || ({})
                            objectName: "contentRelatedCampaignButton"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 58
                            text: campaign.name
                                ? "Campaign: " + String(campaign.name)
                                : "Chưa gắn campaign"
                            enabled: Boolean((campaign.deep_link || {}).route)
                            availabilityReason: enabled
                                ? "" : "Không có campaign deep link được cấp quyền"
                            Accessible.name: text
                            onClicked: root.openDeepLink(campaign.deep_link || ({}))
                            contentItem: ColumnLayout {
                                spacing: 3
                                Text {
                                    objectName: "contentRelatedCampaignHeading"
                                    Layout.fillWidth: true
                                    text: "Campaign liên quan"
                                    color: Theme.textFaint
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    Rectangle {
                                        Layout.preferredWidth: 7
                                        Layout.preferredHeight: 7
                                        radius: 4
                                        color: campaignButton.campaign.name
                                            ? Theme.success : Theme.textFaint
                                    }
                                    Text {
                                        objectName: "contentRelatedCampaignName"
                                        Layout.fillWidth: true
                                        text: String(campaignButton.campaign.name
                                            || "Chưa gắn campaign")
                                        color: Theme.textMuted
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                        AppButton {
                            id: scheduleButton
                            readonly property var scheduleSlot: root.selection.schedule || ({})
                            objectName: "contentScheduleSlotButton"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 58
                            text: scheduleSlot.scheduled_at
                                ? root.scheduleText(scheduleSlot.scheduled_at)
                                : "Chưa có lịch"
                            enabled: Boolean((scheduleSlot.deep_link || {}).route)
                            availabilityReason: enabled
                                ? "" : "Không có schedule deep link được cấp quyền"
                            Accessible.name: text
                            onClicked: root.openDeepLink(scheduleSlot.deep_link || ({}))
                            contentItem: ColumnLayout {
                                spacing: 3
                                Text {
                                    objectName: "contentScheduleSlotHeading"
                                    Layout.fillWidth: true
                                    text: "Slot lên lịch"
                                    color: Theme.textFaint
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    Text {
                                        objectName: "contentScheduleSlotValue"
                                        Layout.fillWidth: true
                                        text: root.scheduleText(
                                            scheduleButton.scheduleSlot.scheduled_at)
                                        color: Theme.textMuted
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    UiIcon {
                                        name: "semantic/upload-cloud"
                                        tone: Theme.textFaint
                                        iconSize: 13
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ScrollView {
                anchors.fill: parent
                visible: root.activeSection === 1
                clip: true
                contentWidth: availableWidth
                ColumnLayout {
                    width: parent.width
                    spacing: 8
                    Text {
                        Layout.fillWidth: true
                        Layout.margins: 12
                        text: "Kịch bản từ snapshot"
                        color: Theme.text
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                    Repeater {
                        model: root.content.script || []
                        delegate: Rectangle {
                            id: scriptRow
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            Layout.preferredHeight: 64
                            radius: Theme.radiusSmall
                            color: Theme.elevated
                            border.width: 1
                            border.color: Theme.borderSoft
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                Text {
                                    Layout.fillWidth: true
                                    text: String(scriptRow.modelData.text || scriptRow.modelData.content || "")
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                    wrapMode: Text.Wrap
                                }
                                Text {
                                    text: scriptRow.modelData.duration !== undefined
                                        ? String(scriptRow.modelData.duration) + "s" : ""
                                    color: Theme.textFaint
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                    Text {
                        visible: (root.content.script || []).length === 0
                        Layout.fillWidth: true
                        Layout.margins: 12
                        text: "Chưa có kịch bản trong projection."
                        color: Theme.textFaint
                        font.pixelSize: 11
                    }
                }
            }

            ScrollView {
                anchors.fill: parent
                visible: root.activeSection === 2
                clip: true
                contentWidth: availableWidth
                ColumnLayout {
                    width: parent.width
                    spacing: 8
                    Text {
                        Layout.fillWidth: true
                        Layout.margins: 12
                        text: "Tài nguyên liên quan · " + String(root.relatedAssets.length)
                        color: Theme.text
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                    Repeater {
                        model: root.relatedAssets
                        delegate: Rectangle {
                            id: assetRow
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            Layout.preferredHeight: 68
                            radius: Theme.radiusSmall
                            color: Theme.elevated
                            border.width: 1
                            border.color: Theme.borderSoft
                            Accessible.name: String(assetRow.modelData.file_name || "Tài nguyên")
                            Accessible.role: Accessible.ListItem
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                Rectangle {
                                    Layout.preferredWidth: 46
                                    Layout.fillHeight: true
                                    radius: 6
                                    color: Theme.hover
                                    UiIcon { anchors.centerIn: parent; name: "semantic/video"; tone: Theme.textFaint; iconSize: 17 }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(assetRow.modelData.file_name || "Tài nguyên")
                                        color: Theme.text
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: String(assetRow.modelData.role || "asset")
                                            + " · " + String(assetRow.modelData.slot || "")
                                        color: Theme.textFaint
                                        font.pixelSize: 11
                                    }
                                }
                                Foundation.StatusPill {
                                    text: String((assetRow.modelData.qc || {}).status || "Chưa QC")
                                    tone: String((assetRow.modelData.qc || {}).status || "") === "passed"
                                        ? Theme.success : Theme.warning
                                }
                                Foundation.IconButton {
                                    objectName: "contentRelatedAsset_"
                                        + String(assetRow.modelData.id || "unknown")
                                    iconName: "ui/external-link"
                                    text: ""
                                    accessibleName: "Mở tài nguyên "
                                        + String(assetRow.modelData.file_name || "liên quan")
                                    enabled: Boolean((assetRow.modelData.deep_link || {}).route)
                                    Accessible.description: enabled
                                        ? "Mở deep link do server cung cấp"
                                        : "Tài nguyên không có deep link được cấp quyền"
                                    onClicked: root.openDeepLink(assetRow.modelData.deep_link)
                                }
                            }
                        }
                    }
                }
            }

            ScrollView {
                anchors.fill: parent
                visible: root.activeSection === 3
                clip: true
                contentWidth: availableWidth
                ColumnLayout {
                    width: parent.width
                    spacing: 8
                    Text {
                        Layout.fillWidth: true
                        Layout.margins: 12
                        text: "Nhật ký bất biến · " + String(Number(root.historyData.total || 0))
                        color: Theme.text
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                    Repeater {
                        model: root.historyModel
                        delegate: Rectangle {
                            id: historyRow
                            required property string event_id
                            required property var summary
                            required property var event_type
                            required property var actor
                            required property var occurred_at
                            objectName: "contentHistoryEvent_" + String(historyRow.event_id || "unknown")
                            Layout.fillWidth: true
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            Layout.preferredHeight: 72
                            radius: Theme.radiusSmall
                            color: Theme.elevated
                            border.width: 1
                            border.color: Theme.borderSoft
                            Accessible.name: String(historyRow.summary || historyRow.event_type || "Sự kiện")
                            Accessible.role: Accessible.ListItem
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 2
                                Text {
                                    Layout.fillWidth: true
                                    text: String(historyRow.summary || historyRow.event_type || "Sự kiện")
                                    color: Theme.text
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: String((historyRow.actor || {}).id || "system")
                                        + " · " + String(historyRow.occurred_at || "")
                                    color: Theme.textFaint
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            color: Theme.elevated
            border.width: 1
            border.color: Theme.borderSoft
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6
                AppButton {
                    id: studioButton
                    objectName: "contentOpenStudioButton"
                    Layout.fillWidth: true
                    text: "Mở trong Studio"
                    primary: true
                    enabled: root.available
                        && Boolean((root.actions.open_studio || {}).enabled)
                    Accessible.name: text
                    onClicked: root.openDeepLink(
                        (root.actions.open_studio || {}).deep_link || ({})
                    )
                }
                AppButton {
                    objectName: "contentCreatePackageButton"
                    text: root.packageBusy ? "Đang tạo..." : "Tạo gói sản xuất"
                    enabled: root.canCreatePackage
                    availabilityReason: enabled
                        ? "" : root.createPackageAvailabilityReason()
                    Accessible.name: "Tạo gói sản xuất"
                    onClicked: root.packageRequested()
                }
                AppButton {
                    objectName: "contentInspectorOverflowButton"
                    text: ""
                    leadingIcon: "ui/more-horizontal"
                    implicitWidth: 38
                    enabled: root.available
                    availabilityReason: enabled ? "" : "Chưa chọn nội dung"
                    Accessible.name: "Thao tác nội dung bổ sung"
                    onClicked: inspectorMenu.open()
                }
            }
            Menu {
                id: inspectorMenu
                objectName: "contentInspectorOverflowMenu"
                MenuItem {
                    objectName: "contentOpenScheduleButton"
                    text: "Lên lịch"
                    enabled: root.available
                        && Boolean((root.actions.schedule || {}).enabled)
                    Accessible.name: text
                    onTriggered: root.openDeepLink(
                        (root.actions.schedule || {}).deep_link || ({})
                    )
                }
                MenuItem {
                    objectName: "contentUpdateStageButton"
                    text: root.updateBusy ? "Đang cập nhật..." : "Đổi giai đoạn"
                    enabled: root.canUpdate
                    Accessible.name: "Đổi giai đoạn nội dung theo phiên bản"
                    onTriggered: root.updateStageRequested()
                }
                MenuItem {
                    objectName: "contentArchiveButton"
                    text: "Lưu trữ"
                    enabled: root.canUpdate
                    Accessible.name: "Lưu trữ nội dung theo phiên bản"
                    onTriggered: root.archiveRequested()
                }
                MenuItem {
                    objectName: "contentDeleteButton"
                    text: "Xóa nội dung"
                    enabled: root.canDelete
                    Accessible.name: text
                    onTriggered: root.deleteRequested()
                }
                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: Theme.panel
                    border.width: 1
                    border.color: Theme.border
                }
            }
        }
    }

    component InspectorTabButton: Button {
        id: sectionButton
        required property int sectionIndex
        objectName: "contentInspectorTab_" + String(sectionIndex)
        width: contentInspectorTabRow.width / 4
        height: contentInspectorTabRow.height
        text: root.sectionName(sectionIndex)
        flat: true
        enabled: root.available
        activeFocusOnTab: true
        Accessible.name: text
        onClicked: root.activeSection = sectionIndex
        contentItem: Text {
            text: sectionButton.text
            color: root.activeSection === sectionButton.sectionIndex
                ? Theme.accent : Theme.textMuted
            font.pixelSize: 11
            font.weight: root.activeSection === sectionButton.sectionIndex
                ? Font.DemiBold : Font.Normal
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: "transparent"
            Rectangle {
                visible: root.activeSection === sectionButton.sectionIndex
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 2
                color: Theme.accent
            }
        }
    }

    component DetailRow: Rectangle {
        id: detailRow
        property string label: ""
        property string value: ""
        readonly property string text: value
        Layout.fillWidth: true
        Layout.preferredHeight: 27
        color: "transparent"
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10
            Text {
                Layout.preferredWidth: 84
                text: detailRow.label
                color: Theme.textFaint
                font.pixelSize: 11
            }
            Text {
                id: valueText
                Layout.fillWidth: true
                text: detailRow.value
                color: Theme.textMuted
                font.pixelSize: 11
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }
}
