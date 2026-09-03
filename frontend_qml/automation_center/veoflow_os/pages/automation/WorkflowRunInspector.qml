pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Rectangle {
    id: root
    objectName: "workflowRunInspector"
    property var run: ({})
    property var eventModel: null
    property var eventItems: []
    property var attention: ({})
    property var runtimeEvidence: ({})
    property var controlPlaneBridge
    property int commandRevision: 0
    signal pauseOrResumeRequested()
    signal safeStopRequested()
    signal loadEventsRequested()
    signal retryRequested(var item)
    signal skipRequested(var item)
    signal deepLinkRequested(var link)
    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    clip: true
    Accessible.name: "Trạng thái lượt chạy và hàng chờ xử lý"
    Accessible.role: Accessible.Pane

    readonly property var progress: root.run.progress || ({})
    readonly property var approval: root.run.approval || ({})
    readonly property var guards: root.run.guards || ({})
    readonly property var attentionItems: root.attention.items || []
    readonly property var runActions: root.run.actions || ({})
    readonly property var actor: root.run.actor || ({})
    readonly property var channelEvidence: root.run.channel || ({})
    readonly property var artifactEvidence: root.run.artifact || ({})
    readonly property var logEvidence: root.run.log || ({})
    readonly property var triggerEvidence: root.run.trigger || ({})
    readonly property var platformEvidence: root.run.platform
        || root.channelEvidence.platform_identity || ({})
    readonly property var resultEvidence: root.run.result || ({})
    readonly property bool resumeMode: ["paused", "pause_requested"].indexOf(
        String(root.run.state || "")) >= 0
    readonly property var pauseResumeAction: root.resumeMode
        ? root.runActions.resume || ({}) : root.runActions.pause || ({})
    readonly property var stopAction: root.runActions.stop || ({})
    readonly property var eventsAction: root.runActions.events || ({})

    function stateLabel(value) {
        const state = String(value || "")
        if (state === "running") return "Đang chạy"
        if (state === "pause_requested") return "Đang yêu cầu tạm dừng"
        if (state === "paused") return "Đã tạm dừng"
        if (state === "stop_requested") return "Đang dừng an toàn"
        if (state === "waiting_approval") return "Chờ phê duyệt"
        if (state === "succeeded") return "Thành công"
        if (state === "failed") return "Thất bại"
        if (state === "stopped") return "Đã dừng"
        return state || "Không có lượt chạy"
    }

    function stateTone(value) {
        const state = String(value || "")
        if (state === "succeeded") return Theme.success
        if (state === "failed" || state === "stopped") return Theme.danger
        if (state === "waiting_approval" || state === "pause_requested" || state === "stop_requested") return Theme.warning
        if (state === "running") return Theme.accent
        return Theme.textFaint
    }

    function formatDuration(seconds) {
        const total = Number(seconds)
        if (!isFinite(total) || total < 0)
            return "—"
        const hours = Math.floor(total / 3600)
        const minutes = Math.floor((total % 3600) / 60)
        const remain = Math.floor(total % 60)
        return (hours > 0 ? String(hours).padStart(2, "0") + ":" : "")
            + String(minutes).padStart(2, "0") + ":" + String(remain).padStart(2, "0")
    }

    function projectedEvent(eventId) {
        const key = String(eventId || "")
        const rows = root.eventItems || []
        for (let index = 0; index < rows.length; ++index) {
            if (String(rows[index].id || "") === key)
                return rows[index]
        }
        return ({})
    }

    function pauseOrResume() {
        if (root.pauseResumeAction.available)
            root.pauseOrResumeRequested()
    }
    function safeStop() {
        if (root.stopAction.available)
            root.safeStopRequested()
    }
    function loadAllEvents() {
        if (root.eventsAction.available)
            root.loadEventsRequested()
    }
    function openApproval() {
        if (root.approval.deep_link)
            root.deepLinkRequested(root.approval.deep_link)
    }

    Connections {
        target: root.controlPlaneBridge ? root.controlPlaneBridge.commandStore : null
        function onChanged(capability, entityType, entityId) { root.commandRevision++ }
    }

    ScrollView {
        id: inspectorScroll
        objectName: "workflowRunInspectorScroll"
        anchors.fill: parent
        clip: true
        contentWidth: Math.max(0, root.width - 14)
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn

        ColumnLayout {
            objectName: "workflowRunInspectorContent"
            width: Math.max(0, root.width - 16)
            implicitWidth: Math.max(0, root.width - 16)
            spacing: 0

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.maximumWidth: Math.max(0, root.width - 16)
                Layout.margins: 12
                spacing: 8
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Trạng thái trực tiếp"; color: Theme.text; font.pixelSize: 13; font.weight: Font.DemiBold }
                    Item { Layout.fillWidth: true }
                    UiIcon {
                        objectName: "workflowRunResultIcon"
                        name: String(root.resultEvidence.icon_key || "")
                        tone: root.stateTone(root.run.state)
                        iconSize: 14
                        visible: name.length > 0
                        Accessible.description:
                            String(root.resultEvidence.reason_code || "")
                    }
                    Foundation.StatusPill {
                        text: String(root.resultEvidence.label
                            || root.stateLabel(root.run.state))
                        tone: root.stateTone(root.run.state)
                    }
                }
                Text { text: String(root.run.id || "Chưa chọn run"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideMiddle; Layout.fillWidth: true }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    UiIcon {
                        objectName: "workflowRunActorIcon"
                        name: String(root.actor.icon_key || "")
                        tone: Theme.textFaint
                        iconSize: 14
                        visible: name.length > 0
                    }
                    Text {
                        objectName: "workflowRunActorEvidence"
                        Layout.fillWidth: true
                        text: "Bắt đầu: " + String(root.run.started_at || "—")
                            + " · Bởi: " + String(root.actor.display_name || root.actor.id || "—")
                        color: Theme.textFaint
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        Accessible.name: text
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    UiIcon {
                        objectName: "workflowRunTriggerIcon"
                        name: String(root.triggerEvidence.icon_key || "")
                        tone: Theme.accent
                        iconSize: 14
                        visible: name.length > 0
                        Accessible.description:
                            String(root.triggerEvidence.reason_code || "")
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Trigger: " + String(root.triggerEvidence.label
                            || root.triggerEvidence.reason_code || "—")
                        color: root.triggerEvidence.state === "available"
                            ? Theme.textMuted : Theme.warning
                        font.pixelSize: Theme.fontMetadata
                        elide: Text.ElideRight
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "Giai đoạn"; color: Theme.textFaint; font.pixelSize: 11 }
                        Text { text: String(root.run.active_stage || root.run.failed_stage || "—"); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "Tiến độ"; color: Theme.textFaint; font.pixelSize: 11 }
                        Text { text: root.progress.percent === undefined ? "—" : String(root.progress.percent) + "%"; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "Thời gian"; color: Theme.textFaint; font.pixelSize: 11 }
                        Text { text: root.formatDuration(root.run.duration_seconds); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                    }
                }
                Foundation.ProgressMeter {
                    Layout.fillWidth: true
                    value: Number(root.progress.percent || 0) / 100
                    tone: root.stateTone(root.run.state)
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "Kênh"; color: Theme.textFaint; font.pixelSize: 11 }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            UiIcon {
                                objectName: "workflowRunPlatformIcon"
                                name: String(root.platformEvidence.icon_key || "")
                                tone: Theme.textMuted
                                iconSize: 14
                                visible: name.length > 0
                                Accessible.description:
                                    String(root.platformEvidence.reason_code || "")
                            }
                            Text {
                                objectName: "workflowRunChannelEvidence"
                                Layout.fillWidth: true
                                text: root.channelEvidence.state === "available"
                                    ? String(root.channelEvidence.display_name
                                        || root.channelEvidence.handle
                                        || root.channelEvidence.id || "—")
                                    : String(root.channelEvidence.reason_code || "Không có kênh")
                                color: root.channelEvidence.state === "available"
                                    ? Theme.textMuted : Theme.warning
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                Accessible.name: text
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "Artifact hiện tại"; color: Theme.textFaint; font.pixelSize: 11 }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            UiIcon {
                                objectName: "workflowRunArtifactIcon"
                                name: String(root.artifactEvidence.icon_key || "")
                                tone: Theme.textMuted
                                iconSize: 14
                                visible: name.length > 0
                            }
                            Text {
                                objectName: "workflowRunArtifactEvidence"
                                Layout.fillWidth: true
                                text: root.artifactEvidence.state === "available"
                                    ? String(root.artifactEvidence.name
                                        || root.artifactEvidence.artifact_id
                                        || root.artifactEvidence.id || "—")
                                    : String(root.artifactEvidence.reason_code || "Không có artifact")
                                color: root.artifactEvidence.state === "available"
                                    ? Theme.textMuted : Theme.warning
                                font.pixelSize: 11
                                elide: Text.ElideMiddle
                                Accessible.name: text
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    AppButton {
                        objectName: "workflowRunPauseResumeButton"
                        Layout.fillWidth: true
                        text: root.resumeMode ? "Tiếp tục" : "Tạm dừng"
                        leadingIcon: String(root.pauseResumeAction.icon_key || "")
                        enabled: String(root.run.id || "").length > 0
                            && Boolean(root.pauseResumeAction.available)
                            && !root.controlPlaneBridge.commandStore.isBusy(
                                String(root.pauseResumeAction.capability || (
                                    root.resumeMode ? "workflow.run.resume" : "workflow.run.pause")),
                                "workflow_run", String(root.run.id || ""))
                        availabilityReason: enabled ? ""
                            : String(root.pauseResumeAction.reason_code
                                || "Run chưa có action tạm dừng/tiếp tục khả dụng")
                        onClicked: root.pauseOrResume()
                    }
                    AppButton {
                        objectName: "workflowRunSafeStopButton"
                        Layout.fillWidth: true
                        text: "Dừng an toàn"
                        leadingIcon: String(root.stopAction.icon_key || "")
                        enabled: String(root.run.id || "").length > 0
                            && Boolean(root.stopAction.available)
                            && !root.controlPlaneBridge.commandStore.isBusy(
                                String(root.stopAction.capability || "workflow.run.stop"),
                                "workflow_run", String(root.run.id || ""))
                        availabilityReason: enabled ? ""
                            : String(root.stopAction.reason_code
                                || "Run chưa có action dừng an toàn khả dụng")
                        onClicked: root.safeStop()
                    }
                    AppButton {
                        objectName: "workflowViewLogButton"
                        Layout.fillWidth: true
                        readonly property var logLink: root.logEvidence.deep_link
                            || root.run.log_deep_link || ({})
                        text: "Xem log"
                        leadingIcon: String(root.logEvidence.icon_key || "")
                        enabled: root.logEvidence.state === "available"
                            && Boolean(logLink.route)
                        availabilityReason: enabled
                            ? "" : String(root.logEvidence.reason_code
                                || "Run projection chưa có log deep link được cấp quyền")
                        Accessible.name: text
                        onClicked: root.deepLinkRequested(logLink)
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.maximumWidth: Math.max(0, root.width - 16)
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                spacing: 7
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Sự kiện gần đây"; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
                    Item { Layout.fillWidth: true }
                    AppButton {
                        id: allEventsButton
                        objectName: "workflowViewAllEventsButton"
                        text: "Xem tất cả"
                        leadingIcon: String(root.eventsAction.icon_key || "")
                        subtle: true
                        implicitHeight: 30
                        enabled: String(root.run.id || "").length > 0
                            && Boolean(root.eventsAction.available)
                        availabilityReason: enabled ? ""
                            : String(root.eventsAction.reason_code
                                || "Server chưa công bố action đọc sự kiện")
                        Accessible.name: "Xem tất cả sự kiện của lượt chạy"
                        onClicked: root.loadAllEvents()
                    }
                }
                Repeater {
                    model: root.eventModel
                    delegate: RowLayout {
                        id: eventRow
                        required property int index
                        required property string event_id
                        required property string event_type
                        required property string state_value
                        required property string summary
                        readonly property var projected:
                            root.projectedEvent(eventRow.event_id)
                        visible: eventRow.index < 4
                        Layout.preferredHeight: visible ? implicitHeight : 0
                        Layout.fillWidth: true
                        spacing: 7
                        UiIcon {
                            objectName: "workflowEventIcon_" + eventRow.event_id
                            name: String(eventRow.projected.icon_key || "")
                            tone: root.stateTone(eventRow.state_value)
                            iconSize: 13
                            visible: name.length > 0
                        }
                        Text { Layout.fillWidth: true; text: String(eventRow.summary || eventRow.event_type || "Sự kiện"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                        Text { text: eventRow.state_value; color: Theme.textFaint; font.pixelSize: 11 }
                    }
                }
                Text { visible: !root.eventModel || root.eventModel.count === 0; text: "Chưa có sự kiện được chiếu"; color: Theme.textFaint; font.pixelSize: 11 }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.maximumWidth: Math.max(0, root.width - 16)
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                spacing: 7
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Cần xử lý"; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
                    Item { Layout.fillWidth: true }
                    Foundation.StatusPill { text: String(root.attention.total || 0); tone: Theme.warning }
                }
                Repeater {
                    model: root.attentionItems.slice(0, 4)
                    delegate: Rectangle {
                        id: attentionCard
                        required property var modelData
                        required property int index
                        objectName: "attentionCard_"
                            + String(attentionCard.modelData.step_run_id || "")
                        Layout.fillWidth: true
                        Layout.preferredWidth: Math.max(0, root.width - 24)
                        Layout.maximumWidth: Math.max(0, root.width - 24)
                        Layout.preferredHeight: 80
                        radius: Theme.radiusSmall
                        color: Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft
                        Accessible.name: "Bước cần xử lý " + String(modelData.step_id || "")
                        Accessible.role: Accessible.ListItem
                        readonly property bool retryBusy: {
                            const revision = root.commandRevision
                            return root.controlPlaneBridge.commandStore.isBusy(
                                "workflow.step.retry", "workflow_step_run", String(modelData.step_run_id || ""))
                        }
                        readonly property bool skipBusy: {
                            const revision = root.commandRevision
                            return root.controlPlaneBridge.commandStore.isBusy(
                                "workflow.step.skip", "workflow_step_run", String(modelData.step_run_id || ""))
                        }
                        readonly property real actionWidth:
                            Math.max(72, (width - 28) / 3)
                        function retryStep() {
                            if (!retryBusy)
                                root.retryRequested(modelData)
                        }
                        function skipStep() {
                            if (!skipBusy)
                                root.skipRequested(modelData)
                        }
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 24
                                spacing: 7
                                UiIcon {
                                    objectName: "workflowAttentionIcon_"
                                        + String(attentionCard.modelData.step_id
                                            || attentionCard.index)
                                    name: String(attentionCard.modelData.icon_key || "")
                                    tone: Theme.warning
                                    iconSize: 18
                                    visible: name.length > 0
                                    Accessible.description:
                                        String(attentionCard.modelData.icon_reason_code || "")
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text { text: String(attentionCard.modelData.step_id || "Bước"); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                                    Text { text: String(attentionCard.modelData.workflow_key || "") + " · " + String(attentionCard.modelData.state || ""); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                                }
                            }
                            RowLayout {
                                id: attentionActions
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                spacing: 6
                                AppButton {
                                    objectName: "workflowRetryStep_"
                                        + String(attentionCard.modelData.step_id || attentionCard.index)
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    Layout.preferredWidth: attentionCard.actionWidth
                                    Layout.maximumWidth: attentionCard.actionWidth
                                    text: "Thử lại"
                                    leadingIcon: String((((attentionCard.modelData.actions || {}).retry || {}).icon_key) || "")
                                    leftPadding: 8
                                    rightPadding: 8
                                    iconSize: 14
                                    font.pixelSize: Theme.fontMetadata
                                    implicitHeight: 30
                                    enabled: Boolean(((attentionCard.modelData.actions || {}).retry || {}).available) && !attentionCard.retryBusy
                                    availabilityReason: enabled ? "" : String((((attentionCard.modelData.actions || {}).retry || {}).reason_code) || "Server không cho phép thử lại")
                                    onClicked: attentionCard.retryStep()
                                }
                                AppButton {
                                    objectName: "workflowSkipStep_"
                                        + String(attentionCard.modelData.step_id || attentionCard.index)
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    Layout.preferredWidth: attentionCard.actionWidth
                                    Layout.maximumWidth: attentionCard.actionWidth
                                    text: "Bỏ qua"
                                    leadingIcon: String((((attentionCard.modelData.actions || {}).skip || {}).icon_key) || "")
                                    leftPadding: 8
                                    rightPadding: 8
                                    iconSize: 14
                                    font.pixelSize: Theme.fontMetadata
                                    implicitHeight: 30
                                    enabled: Boolean(((attentionCard.modelData.actions || {}).skip || {}).available) && !attentionCard.skipBusy
                                    availabilityReason: enabled ? "" : String((((attentionCard.modelData.actions || {}).skip || {}).reason_code) || "Server không cho phép bỏ qua")
                                    onClicked: attentionCard.skipStep()
                                }
                                AppButton {
                                    objectName: "workflowSupplyStep_"
                                        + String(attentionCard.modelData.step_id || attentionCard.index)
                                    readonly property var supplyAction:
                                        (attentionCard.modelData.actions || {}).supply || ({})
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    Layout.preferredWidth: attentionCard.actionWidth
                                    Layout.maximumWidth: attentionCard.actionWidth
                                    text: "Cấp dữ liệu"
                                    leadingIcon: String(supplyAction.icon_key || "")
                                    leftPadding: 8
                                    rightPadding: 8
                                    iconSize: 14
                                    font.pixelSize: Theme.fontMetadata
                                    implicitHeight: 30
                                    enabled: Boolean(supplyAction.available)
                                        && Boolean((supplyAction.deep_link || {}).route)
                                    availabilityReason: enabled
                                        ? "" : String(supplyAction.reason_code
                                            || "Chưa có supply action được policy công bố")
                                    Accessible.name: text
                                    onClicked: root.deepLinkRequested(supplyAction.deep_link)
                                }
                            }
                        }
                    }
                }
                Text { visible: root.attentionItems.length === 0; text: "Không có bước cần can thiệp"; color: Theme.textFaint; font.pixelSize: 11 }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.maximumWidth: Math.max(0, root.width - 16)
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.topMargin: 8
                Layout.bottomMargin: 8
                spacing: 7
                Text { text: "Bảo vệ & bằng chứng"; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: 6
                    rowSpacing: 6
                    Repeater {
                        model: [
                            {"key": "approval", "label": "Phê duyệt", "descriptor": root.guards.approval || ({})},
                            {"key": "idempotency", "label": "Idempotency", "descriptor": root.guards.idempotency || ({})},
                            {"key": "audit", "label": "Audit", "descriptor": root.guards.audit || ({})}
                        ]
                        delegate: Rectangle {
                            id: guardTile
                            required property var modelData
                            readonly property string guardState:
                                String(guardTile.modelData.descriptor.state || "unavailable")
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            radius: Theme.radiusSmall
                            color: Theme.elevated
                            border.width: 1
                            border.color: guardTile.guardState === "verified"
                                ? Theme.success : Theme.warning
                            Row {
                                anchors.centerIn: parent
                                spacing: 5
                                UiIcon {
                                    objectName: "workflowGuardIcon_"
                                        + String(guardTile.modelData.key || "")
                                    name: String(guardTile.modelData.descriptor.icon_key || "")
                                    tone: guardTile.guardState === "verified"
                                        ? Theme.success : Theme.warning
                                    iconSize: 15
                                    visible: name.length > 0
                                }
                                Column {
                                    spacing: 2
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: guardTile.modelData.label; color: Theme.textFaint; font.pixelSize: 11 }
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: guardTile.guardState === "verified" ? "Đã xác minh" : guardTile.guardState; color: guardTile.guardState === "verified" ? Theme.success : Theme.warning; font.pixelSize: 11; font.weight: Font.DemiBold }
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    id: executorEvidence
                    objectName: "executorEvidence"
                    property string evidenceState: String((root.runtimeEvidence.executor || {}).state || "unavailable")
                    property string evidenceReason: String((root.runtimeEvidence.executor || {}).reason_code || "")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    radius: Theme.radiusSmall
                    color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.10)
                    border.width: 1
                    border.color: Theme.warning
                    Accessible.name: "Bằng chứng executor " + evidenceState
                    Accessible.description: evidenceReason
                    Accessible.role: Accessible.StaticText
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 9
                        anchors.rightMargin: 9
                        UiIcon {
                            objectName: "workflowEvidenceIcon_executor"
                            name: String((root.runtimeEvidence.executor || {}).icon_key || "")
                            tone: Theme.warning
                            iconSize: 15
                            visible: name.length > 0
                        }
                        Text { text: "Executor"; color: Theme.textMuted; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                        Text { text: executorEvidence.evidenceState === "unavailable" ? "Chưa có bằng chứng tin cậy" : executorEvidence.evidenceState; color: Theme.warning; font.pixelSize: 11; font.weight: Font.DemiBold }
                    }
                }
                Rectangle {
                    id: workerEvidence
                    objectName: "workerEvidence"
                    property string evidenceState: String((root.runtimeEvidence.worker || {}).state || "unavailable")
                    property string evidenceReason: String((root.runtimeEvidence.worker || {}).reason_code || "")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    radius: Theme.radiusSmall
                    color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.10)
                    border.width: 1
                    border.color: Theme.warning
                    Accessible.name: "Bằng chứng worker " + evidenceState
                    Accessible.description: evidenceReason
                    Accessible.role: Accessible.StaticText
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 9
                        anchors.rightMargin: 9
                        UiIcon {
                            objectName: "workflowEvidenceIcon_worker"
                            name: String((root.runtimeEvidence.worker || {}).icon_key || "")
                            tone: Theme.warning
                            iconSize: 15
                            visible: name.length > 0
                        }
                        Text { text: "Worker"; color: Theme.textMuted; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                        Text { text: workerEvidence.evidenceState === "unavailable" ? "Chưa có worker được xác thực" : workerEvidence.evidenceState; color: Theme.warning; font.pixelSize: 11; font.weight: Font.DemiBold }
                    }
                }
                AppButton {
                    objectName: "workflowApprovalDeepLinkButton"
                    Layout.fillWidth: true
                    text: root.approval.deep_link ? "Mở phê duyệt trên server" : "Không có phê duyệt liên kết"
                    leadingIcon: String(root.approval.icon_key || "")
                    enabled: Boolean(root.approval.deep_link)
                    availabilityReason: enabled ? "" : "Run không có approval deep link"
                    onClicked: root.openApproval()
                }
            }
        }
    }
}
