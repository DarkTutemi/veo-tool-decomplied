pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "copilotApprovalPanel"

    property var strategy: ({})
    property string purpose: "planning"
    property var selectedProject: ({})
    property var profileModel: null
    property var contentModel: null
    property string localTimezone: "UTC"
    property int contentCount: 0
    property int revision: 0
    property bool revisionApproved: false
    property bool planPrepared: false
    property bool actionBusy: false
    property bool deliveryEditorOpen: false
    property int assignableCount: 0
    property int assignedCount: 0

    readonly property bool assignmentMode: root.purpose === "assignment"

    signal approveRequested()
    signal prepareRequested()
    signal deliveryRequested(var delivery)
    signal assignAllRequested()

    function map(value): var {
        return value === null || value === undefined ? ({}) : value
    }

    readonly property var profile: root.profileForId(
        String(root.selectedProject.profileId || ""))
    readonly property var channelProduction: {
        const fromProfile = root.map(root.profile.channelProfile)
        if (String(fromProfile.channel_profile_id || ""))
            return fromProfile
        return root.map(root.selectedProject.channelProfile)
    }
    readonly property var channelBrand: root.map(root.channelProduction.brand)
    readonly property var channelEntities: root.map(root.channelProduction.entities)
    readonly property bool channelProductionReady: String(
        root.channelProduction.channel_profile_id || "").length > 0

    readonly property string platform: {
        const profilePlatform = String(root.profile.platform || "")
        if (profilePlatform) return profilePlatform
        const projectPlatform = String(root.selectedProject.platform || "")
        if (projectPlatform) return projectPlatform
        const platforms = root.strategy.platforms || []
        return platforms.length ? String(platforms[0]) : ""
    }
    readonly property var pipeline: [
        {"label": "Ý tưởng & kịch bản"},
        {"label": "Master / Clone / Audio / Affiliate"},
        {"label": "Kiểm tra artifact"},
        {"label": "PublishKit"},
        {"label": "Đăng hoặc đối soát"}
    ]

    component DetailRow: RowLayout {
        id: detailRow

        property string label: ""
        property string value: ""
        property string iconName: ""
        property string platform: ""
        property bool preserveIconColors: false
        property int valueElide: Text.ElideRight
        readonly property bool iconReady:
            (detailRow.platform.length === 0 || platformIcon.sourceReady)
            && (detailRow.iconName.length === 0 || valueIcon.sourceReady)

        spacing: 7

        Text {
            Layout.preferredWidth: 68
            text: detailRow.label
            color: Theme.textFaint
            font.pixelSize: Theme.fontMetadata
        }
        PlatformIcon {
            id: platformIcon
            objectName: detailRow.objectName.length > 0
                ? detailRow.objectName + "PlatformIcon" : ""
            visible: detailRow.platform.length > 0
            platform: detailRow.platform
            iconSize: 16
            Layout.preferredWidth: visible ? 16 : 0
            Layout.preferredHeight: 16
        }
        UiIcon {
            id: valueIcon
            objectName: detailRow.objectName.length > 0
                ? detailRow.objectName + "ValueIcon" : ""
            visible: detailRow.iconName.length > 0
            name: detailRow.iconName
            preserveColors: detailRow.preserveIconColors
            tone: Theme.textMuted
            iconSize: 16
            Layout.preferredWidth: visible ? 16 : 0
            Layout.preferredHeight: 16
        }
        Text {
            Layout.fillWidth: true
            text: detailRow.value
            color: Theme.text
            font.pixelSize: Theme.fontBody
            font.weight: Font.DemiBold
            elide: detailRow.valueElide
        }
    }

    function platformLabel(): string {
        const value = root.platform.toLowerCase()
        if (value === "youtube") return "YouTube"
        if (value === "facebook") return "Facebook"
        if (value === "tiktok") return "TikTok"
        return value ? root.platform : "Chưa gán"
    }

    function profileLabel(): string {
        const handle = String(root.profile.accountHandle || "")
        if (handle) return "@" + handle.replace(/^@/, "")
        return String(root.profile.label || "Chọn khi giao")
    }

    function channelProductionLabel(): string {
        if (!root.channelProductionReady)
            return "Chưa có · tạo ở Kênh & Browser"
        const version = Number(root.channelProduction.version || 0)
        const language = String(root.channelBrand.language || "")
        const characters = (root.channelEntities.character_ids || []).length
        return "Revision " + String(version)
            + (language ? " · " + language : "")
            + " · " + String(characters) + " nhân vật"
    }

    function profileForId(profileId): var {
        if (!root.profileModel || Number(root.profileModel.count || 0) <= 0)
            return ({})
        const cleanId = String(profileId || "")
        if (!cleanId)
            return ({})
        for (let index = 0; index < Number(root.profileModel.count || 0); ++index) {
            const row = root.profileModel.get(index) || ({})
            if (String(row.profileId || "") === cleanId)
                return row
        }
        return ({})
    }

    function refreshContentCounts(): void {
        let assignable = 0
        let assigned = 0
        if (root.contentModel) {
            for (let index = 0; index < Number(root.contentModel.count || 0); ++index) {
                const row = root.contentModel.get(index) || ({})
                if (Boolean(row.canAssign)) ++assignable
                if (String(row.status || "") === "assigned") ++assigned
            }
        }
        root.assignableCount = assignable
        root.assignedCount = assigned
    }

    function syncDeliveryForm(): void {
        const mode = String(root.selectedProject.deliveryMode || "none")
        for (let index = 0; index < deliveryModes.count; ++index) {
            if (String(deliveryModes.get(index).mode || "") === mode) {
                deliveryModePicker.currentIndex = index
                break
            }
        }
        const profileId = String(root.selectedProject.profileId || "")
        deliveryProfilePicker.currentIndex = -1
        if (root.profileModel) {
            for (let index = 0; index < Number(root.profileModel.count || 0); ++index) {
                const row = root.profileModel.get(index) || ({})
                if (String(row.profileId || "") === profileId) {
                    deliveryProfilePicker.currentIndex = index
                    break
                }
            }
            if (deliveryProfilePicker.currentIndex < 0
                    && Number(root.profileModel.count || 0) > 0)
                deliveryProfilePicker.currentIndex = 0
        }
        scheduleStartInput.text = String(
            root.selectedProject.scheduleStartUtc || "")
        if (!scheduleStartInput.text)
            scheduleStartInput.text = new Date(Date.now() + 3600000).toISOString()
        const productionDelivery = root.map(
            root.map(root.profile.channelProfile).delivery_defaults)
        scheduleInterval.value = Math.max(1, Number(
            root.selectedProject.intervalMinutes
                || productionDelivery.interval_minutes || 1440))
    }

    function saveDelivery(): void {
        const mode = String(deliveryModePicker.currentValue || "none")
        if (mode === "none") {
            root.deliveryRequested({"mode": "none"})
            return
        }
        if (!root.profileModel || deliveryProfilePicker.currentIndex < 0)
            return
        const profileRow = root.profileModel.get(
            deliveryProfilePicker.currentIndex) || ({})
        const payload = {
            "mode": mode,
            "platform": String(profileRow.platform || ""),
            "profile_id": String(profileRow.profileId || ""),
            "channel_id": String(profileRow.channelId
                || profileRow.profileId || ""),
            "caption_mode": "publish_kit",
            "timezone": String(root.map(
                root.map(profileRow.channelProfile).delivery_defaults).timezone
                || root.localTimezone || "UTC")
        }
        if (mode === "scheduled") {
            payload.start_at_utc = scheduleStartInput.text.trim()
            payload.interval_minutes = scheduleInterval.value
        }
        root.deliveryRequested(payload)
    }

    function finishDeliverySave(ok): void {
        if (ok) root.deliveryEditorOpen = false
    }

    onDeliveryEditorOpenChanged: {
        if (deliveryEditorOpen) Qt.callLater(root.syncDeliveryForm)
    }
    onSelectedProjectChanged: {
        if (deliveryEditorOpen) Qt.callLater(root.syncDeliveryForm)
    }
    Component.onCompleted: root.refreshContentCounts()

    Connections {
        target: root.contentModel
        function onModelReset() { root.refreshContentCounts() }
        function onRowsInserted() { root.refreshContentCounts() }
        function onRowsRemoved() { root.refreshContentCounts() }
        function onDataChanged() { root.refreshContentCounts() }
        function onCountChanged() { root.refreshContentCounts() }
    }

    Connections {
        target: root.profileModel
        function onModelReset() {
            if (root.deliveryEditorOpen) Qt.callLater(root.syncDeliveryForm)
        }
        function onCountChanged() {
            if (root.deliveryEditorOpen) Qt.callLater(root.syncDeliveryForm)
        }
    }

    ListModel {
        id: deliveryModes
        ListElement { label: "Chỉ sản xuất"; mode: "none" }
        ListElement { label: "Đăng sau sản xuất"; mode: "after_production" }
        ListElement { label: "Đăng theo lịch"; mode: "scheduled" }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 9

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            UiIcon {
                objectName: "copilotApprovalHeaderIcon"
                name: "ui/file-text"
                tone: Theme.accent
                iconSize: 18
                Layout.preferredWidth: 19
                Layout.preferredHeight: 19
            }
            Text {
                Layout.fillWidth: true
                text: root.assignmentMode
                    ? "Bàn giao kế hoạch" : "Kế hoạch chờ duyệt"
                color: Theme.text
                font.pixelSize: Theme.fontSection
                font.weight: Font.DemiBold
            }
            AppButton {
                objectName: "copilotDeliveryEditButton"
                visible: root.assignmentMode
                text: ""
                leadingIcon: "ui/calendar"
                subtle: true
                implicitWidth: 32
                implicitHeight: 28
                enabled: root.revision > 0 && !root.actionBusy
                Accessible.name: "Cấu hình kênh và lịch đăng"
                onClicked: root.deliveryEditorOpen = true
            }
            Foundation.StatusPill {
                visible: root.revision > 0
                text: "V" + String(root.revision)
                tone: root.revisionApproved ? Theme.success : Theme.warning
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 7

            DetailRow {
                objectName: "copilotPlatformDetail"
                Layout.fillWidth: true
                label: "Nền tảng"
                platform: root.platform
                value: root.platformLabel()
            }
            DetailRow {
                objectName: "copilotChannelDetail"
                Layout.fillWidth: true
                label: "Kênh đăng"
                iconName: "semantic/channels"
                value: root.profileLabel()
            }
            DetailRow {
                objectName: "copilotBrowserDetail"
                Layout.fillWidth: true
                label: "Hồ sơ"
                iconName: "product/chrome"
                preserveIconColors: true
                value: String(root.profile.browserKey || "Chưa chọn browser")
                valueElide: Text.ElideMiddle
            }
            DetailRow {
                objectName: "copilotTimezoneDetail"
                Layout.fillWidth: true
                label: "Múi giờ"
                iconName: "ui/globe"
                value: root.localTimezone || "UTC"
            }
            DetailRow {
                objectName: "copilotCadenceDetail"
                Layout.fillWidth: true
                label: "Nhịp đăng"
                iconName: "ui/calendar"
                value: String(root.strategy.cadence || "Chưa chốt lịch")
            }
            DetailRow {
                objectName: "copilotChannelProductionDetail"
                Layout.fillWidth: true
                label: "Cấu hình"
                iconName: "ui/settings"
                value: root.channelProductionLabel()
                valueElide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        Text {
            Layout.fillWidth: true
            text: "PIPELINE THỰC THI"
            color: Theme.textFaint
            font.pixelSize: Theme.fontMetadata
            font.weight: Font.Bold
            font.letterSpacing: 0.7
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Repeater {
                model: root.pipeline
                delegate: RowLayout {
                    id: pipelineRow
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    spacing: 7

                    Item {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 34

                        Rectangle {
                            visible: pipelineRow.index < root.pipeline.length - 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 23
                            width: 1
                            height: 18
                            color: Theme.border
                        }
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            width: 24
                            height: 24
                            radius: 12
                            color: pipelineRow.index === 0
                                ? Theme.accentSoft : Theme.elevated
                            Text {
                                anchors.centerIn: parent
                                text: String(pipelineRow.index + 1)
                                color: pipelineRow.index === 0
                                    ? Theme.accent : Theme.textMuted
                                font.pixelSize: Theme.fontMetadata
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: Theme.radiusSmall
                        color: Theme.panel
                        border.width: 1
                        border.color: Theme.borderSoft
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 9
                            spacing: 7
                            Text {
                                Layout.fillWidth: true
                                text: pipelineRow.modelData.label
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontMetadata
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: 7
            Text {
                Layout.fillWidth: true
                text: String(root.contentCount) + " nội dung"
                color: Theme.text
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
            }
            Text {
                text: root.revisionApproved ? "Đã duyệt" : "Chờ người dùng duyệt"
                color: root.revisionApproved ? Theme.success : Theme.warning
                font.pixelSize: Theme.fontMetadata
            }
        }

        AppButton {
            objectName: "copilotApprovePlanButton"
            visible: !root.assignmentMode
            Layout.fillWidth: true
            text: root.revisionApproved
                ? "Đã duyệt revision " + String(root.revision)
                : "Duyệt revision"
            leadingIcon: "ui/check-square"
            primary: !root.revisionApproved
            enabled: root.revision > 0 && !root.revisionApproved && !root.actionBusy
            visualEnabled: enabled || root.revisionApproved
            onClicked: root.approveRequested()
        }

        AppButton {
            objectName: "copilotPrepareAssignmentsButton"
            visible: root.assignmentMode
            Layout.fillWidth: true
            text: root.planPrepared
                ? (root.assignableCount > 0
                    ? "Giao toàn bộ (" + String(root.assignableCount) + ")"
                    : root.assignedCount > 0 ? "Đã giao toàn bộ" : "Không có mục sẵn sàng")
                : "Chuẩn bị giao việc"
            leadingIcon: root.planPrepared && root.assignableCount <= 0
                ? "ui/check" : "ui/play"
            primary: root.revisionApproved
                && (!root.planPrepared || root.assignableCount > 0)
            enabled: root.revisionApproved && !root.actionBusy
                && (!root.planPrepared || root.assignableCount > 0)
            visualEnabled: enabled || root.planPrepared
            onClicked: {
                if (root.planPrepared) root.assignAllRequested()
                else root.prepareRequested()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            UiIcon {
                objectName: "copilotApprovalSafetyIcon"
                name: "semantic/shield-check"
                tone: Theme.textFaint
                iconSize: 14
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
            }
            Text {
                Layout.fillWidth: true
                text: root.assignmentMode
                    ? "Chỉ Giao việc tạo order; coordinator chạy từng việc một."
                    : "Duyệt revision tại đây; sang Giao việc để gán kênh và chạy."
                color: Theme.textFaint
                font.pixelSize: 10
                wrapMode: Text.Wrap
            }
        }
    }

    Rectangle {
        id: deliveryEditor
        objectName: "copilotDeliveryEditor"
        anchors.fill: parent
        anchors.margins: 1
        z: 20
        visible: root.assignmentMode && root.deliveryEditorOpen
        radius: Theme.radiusMedium
        color: Theme.panel

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                UiIcon {
                    objectName: "copilotDeliveryEditorIcon"
                    name: "ui/calendar"
                    tone: Theme.accent
                    iconSize: 18
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                }
                Text {
                    Layout.fillWidth: true
                    text: "Đích đăng & lịch"
                    color: Theme.text
                    font.pixelSize: Theme.fontSection
                    font.weight: Font.DemiBold
                }
                AppButton {
                    objectName: "copilotDeliveryCloseButton"
                    text: "Đóng"
                    leadingIcon: "ui/close"
                    subtle: true
                    implicitHeight: 30
                    onClicked: root.deliveryEditorOpen = false
                }
            }

            Text {
                Layout.fillWidth: true
                text: "Đích này được kiểm tra ngay và đóng băng vào từng Assignment V2."
                color: Theme.textMuted
                font.pixelSize: Theme.fontMetadata
                wrapMode: Text.Wrap
            }

            Text {
                text: "Cách bàn giao"
                color: Theme.text
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
            }
            WorkflowComboBox {
                id: deliveryModePicker
                objectName: "copilotDeliveryModePicker"
                Layout.fillWidth: true
                model: deliveryModes
                textRole: "label"
                valueRole: "mode"
                enabled: !root.actionBusy
            }

            Text {
                visible: String(deliveryModePicker.currentValue || "none") !== "none"
                text: "Profile / kênh đã xác minh"
                color: Theme.text
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
            }
            WorkflowComboBox {
                id: deliveryProfilePicker
                objectName: "copilotDeliveryProfilePicker"
                visible: String(deliveryModePicker.currentValue || "none") !== "none"
                Layout.fillWidth: true
                model: root.profileModel
                textRole: "label"
                valueRole: "profileId"
                displayText: currentIndex >= 0 && root.profileModel
                    ? String((root.profileModel.get(currentIndex) || ({})).label
                        || (root.profileModel.get(currentIndex) || ({})).accountHandle
                        || "Hồ sơ đăng")
                    : "Chọn profile đã xác minh"
                leadingPlatform: currentIndex >= 0 && root.profileModel
                    ? String((root.profileModel.get(currentIndex) || ({})).platform || "")
                    : ""
                enabled: visible && root.profileModel
                    && Number(root.profileModel.count || 0) > 0 && !root.actionBusy
            }

            Rectangle {
                readonly property var selectedRow: deliveryProfilePicker.currentIndex >= 0
                        && root.profileModel
                    ? root.profileModel.get(deliveryProfilePicker.currentIndex) || ({})
                    : ({})
                visible: String(deliveryModePicker.currentValue || "none") !== "none"
                    && deliveryProfilePicker.currentIndex >= 0
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 58 : 0
                radius: Theme.radiusSmall
                color: Boolean(selectedRow.channelProfileReady)
                    ? Theme.successSoft : Theme.warningSoft
                border.width: 1
                border.color: Boolean(selectedRow.channelProfileReady)
                    ? Theme.success : Theme.warning
                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    text: parent.selectedRow.channelProfileReady
                        ? "Sẽ dùng cấu hình kênh revision "
                            + String(parent.selectedRow.channelProfileVersion || 0)
                            + "; Assignment sẽ đóng băng revision/hash này."
                        : "Kênh chưa có cấu hình sản xuất. Khi lưu đích đăng, Tool 1 sẽ chụp cấu hình hiện tại của 5 feature để tạo revision đầu tiên."
                    color: parent.selectedRow.channelProfileReady
                        ? Theme.success : Theme.warning
                    font.pixelSize: Theme.fontMetadata
                    wrapMode: Text.Wrap
                }
            }

            Rectangle {
                visible: String(deliveryModePicker.currentValue || "none") !== "none"
                    && (!root.profileModel || Number(root.profileModel.count || 0) === 0)
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 54 : 0
                radius: Theme.radiusSmall
                color: Theme.warningSoft
                border.width: 1
                border.color: Theme.warning
                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    text: "Chưa có hồ sơ YouTube, TikTok hoặc Facebook đã xác minh. Tạo và xác minh ở Kênh & Browser trước."
                    color: Theme.warning
                    font.pixelSize: Theme.fontMetadata
                    wrapMode: Text.Wrap
                }
            }

            Text {
                visible: String(deliveryModePicker.currentValue || "none") === "scheduled"
                text: "Bắt đầu (ISO-8601 UTC)"
                color: Theme.text
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
            }
            WorkflowTextField {
                id: scheduleStartInput
                objectName: "copilotDeliveryScheduleStart"
                visible: String(deliveryModePicker.currentValue || "none") === "scheduled"
                Layout.fillWidth: true
                placeholderText: "2030-01-01T09:00:00+00:00"
                enabled: visible && !root.actionBusy
            }

            Text {
                visible: String(deliveryModePicker.currentValue || "none") === "scheduled"
                text: "Khoảng cách giữa video (phút)"
                color: Theme.text
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
            }
            WorkflowSpinBox {
                id: scheduleInterval
                objectName: "copilotDeliveryInterval"
                visible: String(deliveryModePicker.currentValue || "none") === "scheduled"
                Layout.fillWidth: true
                from: 1
                to: 43200
                value: 1440
                enabled: visible && !root.actionBusy
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 7
                UiIcon {
                    name: "semantic/shield-check"
                    tone: Theme.textFaint
                    iconSize: 14
                    Layout.preferredWidth: 14
                    Layout.preferredHeight: 14
                }
                Text {
                    Layout.fillWidth: true
                    text: "PublishKit dùng artifact đã kiểm tra hash; không tự đăng khi target chưa hợp lệ."
                    color: Theme.textFaint
                    font.pixelSize: Theme.fontMetadata
                    wrapMode: Text.Wrap
                }
            }

            AppButton {
                objectName: "copilotSaveDeliveryButton"
                Layout.fillWidth: true
                text: root.actionBusy ? "Đang kiểm tra…" : "Lưu đích đăng"
                leadingIcon: "ui/check"
                primary: true
                enabled: !root.actionBusy
                    && (String(deliveryModePicker.currentValue || "none") === "none"
                        || deliveryProfilePicker.currentIndex >= 0)
                    && (String(deliveryModePicker.currentValue || "none") !== "scheduled"
                        || scheduleStartInput.text.trim().length > 0)
                onClicked: root.saveDelivery()
            }
        }
    }
}
