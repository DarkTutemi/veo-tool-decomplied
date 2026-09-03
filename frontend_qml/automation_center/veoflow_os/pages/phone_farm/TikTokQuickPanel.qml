pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation
import "../../components/device" as Device

Panel {
    id: root
    objectName: "tiktokQuickPanel"
    clip: true

    property var device: ({})
    property var operationModel: null
    property var controlPlaneBridge: null
    property int commandRevision: 0
    property var permissionChecker: null
    property bool visualProductionFixture: Boolean(
        (((root.device || {}).microStatuses || {}).visual_production_fixture)
    )
    color: Theme.panel

    signal openTikTokRequested()
    signal screenshotRequested()
    signal safeStopRequested()
    signal selectContentRequested()
    signal operationRequested(var action)

    readonly property string deviceId: String((root.device || {}).deviceId || "")
    readonly property string leaseId: String((root.device || {}).leaseId || "")
    readonly property int leaseFencingToken: Number((root.device || {}).leaseFencingToken || 0)
    readonly property string activeOperationId: String((root.device || {}).activeOperationId || "")
    readonly property bool demoReadOnly: Boolean((root.device || {}).demoReadOnly)
    readonly property var quickActions: (root.device || {}).quickActions || ({})
    readonly property var microStatuses: (root.device || {}).microStatuses || ({})
    readonly property string statusProvenance: root.provenanceKey(
        root.microStatuses, root.device.presentationProvenance
    )
    readonly property var stagedMedia: root.quickActions.stagedMedia || ({})
    readonly property var virtualCamera: root.quickActions.virtualCamera || ({})
    readonly property var flowDefinition: root.quickActions.flow || ({})
    readonly property var publishDefinition: root.quickActions.publish || ({})
    readonly property var openAction: (root.quickActions.openTikTok || ({})).action || ({})
    readonly property var removeMediaAction: (root.stagedMedia.actions || ({})).remove || ({})
    readonly property var cameraAction: (root.virtualCamera.actions || ({})).configure || ({})
    readonly property var cameraSources: root.virtualCamera.sources || []
    readonly property var flowStartAction: (root.flowDefinition.actions || ({})).start || ({})
    readonly property var flowPauseAction: (root.flowDefinition.actions || ({})).pause || ({})
    readonly property var publishAction: (root.publishDefinition.actions || ({})).submit || ({})
    readonly property var commandStore: root.controlPlaneBridge
        ? root.controlPlaneBridge.commandStore : null

    readonly property var recentPublishOperation: root.findRecentPublishOperation()
    readonly property var publishCommandResult: root.findPublishCommandResult()
    readonly property var publishProjection: root.recentPublishOperation
        ? root.recentPublishOperation
        : (root.publishCommandResult ? root.publishCommandResult : root.publishDefinition)
    readonly property string publishState: root.publishProjection
        ? String(root.publishProjection.state || root.publishProjection.operation_state || "unavailable")
        : "unavailable"
    readonly property string publishApprovalId: root.publishProjection
        ? String(root.publishProjection.approval_id || root.publishProjection.approvalId || "")
        : ""

    readonly property bool openBusy: {
        const revision = root.commandRevision
        return root.commandStore && root.deviceId.length > 0
            ? root.commandStore.isBusy("device.operation.start", "device", root.deviceId)
            : false
    }
    readonly property bool stopBusy: {
        const revision = root.commandRevision
        return root.commandStore && root.activeOperationId.length > 0
            ? root.commandStore.isBusy("device.operation.stop", "operation", root.activeOperationId)
            : false
    }

    readonly property bool stagedMediaSourceAvailable: Boolean(root.stagedMedia.available)
    readonly property bool virtualCameraSourceAvailable: Boolean(root.virtualCamera.available)
    readonly property bool flowDefinitionAvailable: Boolean(root.flowDefinition.available)
    readonly property bool publishSourceAvailable: Boolean(root.publishDefinition.available)
    readonly property string stagedMediaSummary: root.stagedMediaSourceAvailable
        ? String(root.stagedMedia.displayName || "Media") + " · "
            + root.formatDuration(Number(root.stagedMedia.durationSeconds || 0)) + " · "
            + String(root.stagedMedia.resolution || "—")
        : "Chưa có media đã duyệt"
    readonly property string flowSummary: root.flowDefinitionAvailable
        ? String(root.flowDefinition.displayName || "Flow") + " · "
            + String(root.flowDefinition.currentStep || 0) + "/"
            + String(root.flowDefinition.totalSteps || 0) + " · "
            + String(root.flowDefinition.currentStepLabel || "Chưa có bước")
        : "Chưa có flow versioned"
    readonly property real flowProgressValue: {
        if (!root.flowDefinitionAvailable) return 0
        const explicitValue = Number(root.flowDefinition.progress)
        if (isFinite(explicitValue) && explicitValue >= 0)
            return Math.max(0, Math.min(100, explicitValue))
        const current = Number(root.flowDefinition.currentStep || 0)
        const total = Number(root.flowDefinition.totalSteps || 0)
        return total > 0 ? Math.max(0, Math.min(100, current * 100 / total)) : 0
    }
    readonly property url stagedMediaThumbnailSource: root.resolveStagedMediaThumbnail()

    Accessible.role: Accessible.Pane
    Accessible.name: root.deviceId.length > 0
        ? "Thao tác TikTok nhanh cho " + String(root.device.label || root.deviceId)
        : "Thao tác TikTok nhanh, chưa chọn thiết bị"

    function can(permission) {
        return root.permissionChecker
            ? Boolean(root.permissionChecker(String(permission || ""))) : false
    }

    function actionAvailable(action) {
        return action !== null && action !== undefined
            && action.available === true
            && String(action.capability || "") === "device.operation.start"
    }

    function actionReason(action, fallback) {
        if (root.actionAvailable(action)) return "Sẵn sàng theo snapshot server"
        const reason = action !== null && action !== undefined
            ? String(action.reason_code || "") : ""
        return reason.length > 0 ? reason : String(fallback || "Không khả dụng")
    }

    function provenanceKey(statuses, fallback) {
        const source = String(((statuses || {}).provenance || {}).source || fallback || "")
            .toLowerCase()
        const simulated = Boolean(((statuses || {}).provenance || {}).simulated)
        return simulated || ["demo_seed", "demo_only", "simulated"].indexOf(source) >= 0
            ? "demo_seed" : "production"
    }

    function formatDuration(seconds) {
        const value = Math.max(0, Math.floor(Number(seconds || 0)))
        const minutes = Math.floor(value / 60)
        const remaining = value % 60
        return String(minutes).padStart(2, "0") + ":"
            + String(remaining).padStart(2, "0")
    }

    function resolveStagedMediaThumbnail() {
        if (!root.stagedMediaSourceAvailable)
            return ""
        const source = (root.device || {}).visualSource || ({})
        const key = String(source.posterKey || "")
        const posters = {
            "garden-creator": "garden-creator.jpg",
            "mountain-route": "mountain-route.jpg",
            "creator-products": "creator-products.jpg",
            "waterfall-travel": "waterfall-travel.jpg"
        }
        if (String(source.kind || "") !== "demo_poster"
                || String(source.provenance || "") !== "demo_seed"
                || !Boolean(source.isDemo) || !posters[key])
            return ""
        return Qt.resolvedUrl("../../assets/demo/phone_farm/" + posters[key])
    }

    function findRecentPublishOperation() {
        if (!root.operationModel)
            return null
        for (let index = 0; index < root.operationModel.count; index++) {
            const operation = root.operationModel.get(index) || {}
            if (String(operation.device_id || operation.deviceId || "") === root.deviceId
                    && String(operation.semantic_type || operation.semanticType || "")
                        === "device.tiktok.publish.request")
                return operation
        }
        return null
    }

    function findPublishCommandResult() {
        const revision = root.commandRevision
        if (!root.commandStore || root.deviceId.length === 0)
            return null
        const command = root.commandStore.state(
            "device.operation.start", "device", root.deviceId
        )
        const result = command && command.result ? command.result : null
        if (!result)
            return null
        const operation = result.operation || result
        if (String(operation.semantic_type || operation.semanticType || "")
                !== "device.tiktok.publish.request")
            return null
        const resultDeviceId = String(operation.device_id || operation.deviceId || "")
        if (resultDeviceId.length > 0 && resultDeviceId !== root.deviceId)
            return null
        return operation
    }

    function publishStatusLabel() {
        const state = root.publishState.toLowerCase()
        if (root.demoReadOnly)
            return state === "waiting_approval"
                ? "Cần phê duyệt" : String(state || "preview_only")
        if (state === "waiting_approval")
            return "Cần phê duyệt"
        if (state === "verification_required")
            return "Cần xác minh từ server"
        if (state === "queued")
            return "Đã xếp hàng"
        if (state === "running")
            return "Đang đăng"
        if (state === "succeeded")
            return "Đã đăng thành công"
        if (["failed", "cancelled", "stopped"].indexOf(state) >= 0)
            return "Publish " + state
        return "Chưa có dữ liệu publish"
    }

    function publishTone() {
        const state = root.publishState.toLowerCase()
        if (state === "succeeded")
            return Theme.success
        if (["failed", "cancelled", "stopped"].indexOf(state) >= 0)
            return Theme.danger
        if (["waiting_approval", "verification_required"].indexOf(state) >= 0)
            return Theme.warning
        if (["queued", "running"].indexOf(state) >= 0)
            return Theme.info
        return Theme.textFaint
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 14
        anchors.topMargin: root.visualProductionFixture ? 6 : 10
        anchors.bottomMargin: root.visualProductionFixture ? 6 : 10
        width: Math.max(0, root.width - 28)
        spacing: root.visualProductionFixture ? 4 : 5

        RowLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 8
            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                radius: 8
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                SocialIcon {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    platform: "tiktok"
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: 1
                Text {
                    objectName: "tiktokQuickTitle"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: "TikTok nhanh"
                    color: Theme.text
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: root.deviceId.length > 0
                        ? String(root.device.handle || root.device.label || root.deviceId)
                        : "Chưa chọn thiết bị"
                    color: Theme.textFaint
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }
            Foundation.StatusPill {
                objectName: "tiktokDemoBadge"
                visible: root.demoReadOnly && !root.visualProductionFixture
                text: "DEMO"
                tone: Theme.warning
                showDot: true
                Accessible.name: "DEMO read-only"
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        Text {
            text: "Ứng dụng"
            color: Theme.textFaint
            font.pixelSize: 11
            font.weight: Font.DemiBold
        }
        AppButton {
            objectName: "phoneOpenTikTokButton"
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            Layout.minimumWidth: 0
            clip: true
            text: root.openBusy ? "Đang mở TikTok…" : "Mở TikTok"
            leadingIcon: "ui/play"
            primary: true
            activeFocusOnTab: true
            enabled: root.actionAvailable(root.openAction) && !root.openBusy
            visualEnabled: enabled || (root.visualProductionFixture
                && root.deviceId.length > 0)
            Accessible.name: text
            Accessible.description: enabled
                ? "Yêu cầu semantic operation mở TikTok bằng lease hiện tại"
                : "Cần thiết bị, lease hợp lệ, quyền vận hành và command rảnh"
            onClicked: root.operationRequested(root.openAction)
        }

        Text {
            text: "Nguồn video"
            color: Theme.textFaint
            font.pixelSize: 11
            font.weight: Font.DemiBold
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 6
            AppButton {
                objectName: "phoneLoadVideoButton"
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                Layout.minimumWidth: 0
                clip: true
                text: root.stagedMediaSourceAvailable ? "Đổi video" : "Chọn video"
                leadingIcon: "semantic/video"
                activeFocusOnTab: true
                enabled: root.stagedMediaSourceAvailable && root.can("content.read")
                visualEnabled: enabled || (root.visualProductionFixture
                    && root.stagedMediaSourceAvailable)
                Accessible.name: text
                Accessible.description: "Không khả dụng: snapshot chưa cung cấp nguồn media đã duyệt"
                onClicked: root.selectContentRequested()
            }
            AppButton {
                objectName: "phoneRemoveVideoButton"
                Layout.minimumWidth: 0
                Layout.preferredHeight: 36
                clip: true
                text: "Gỡ"
                leadingIcon: "ui/close"
                activeFocusOnTab: true
                enabled: root.actionAvailable(root.removeMediaAction)
                visualEnabled: enabled || (root.visualProductionFixture
                    && root.stagedMediaSourceAvailable)
                Accessible.name: text
                Accessible.description: root.actionReason(
                    root.removeMediaAction,
                    "Chưa có media được stage trên thiết bị"
                )
                onClicked: root.operationRequested(root.removeMediaAction)
            }
        }

        Rectangle {
            objectName: "phoneStagedMediaCard"
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.preferredHeight: visible ? 56 : 0
            visible: root.stagedMediaSourceAvailable
            radius: Theme.radiusSmall
            color: Theme.elevated
            border.width: 1
            border.color: Theme.borderSoft
            Accessible.name: root.stagedMediaSummary
            Accessible.role: Accessible.StaticText

            RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 8
                Rectangle {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 50
                    radius: 6
                    color: Theme.base
                    clip: true
                    Image {
                        objectName: "phoneStagedMediaThumbnail"
                        anchors.fill: parent
                        source: root.stagedMediaThumbnailSource
                        visible: String(source).length > 0
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        Accessible.name: "Poster DEMO của media đã stage"
                        Accessible.description: "Poster đóng gói allowlist; không phải frame live"
                        Accessible.role: Accessible.Graphic
                    }
                    UiIcon {
                        anchors.centerIn: parent
                        visible: String(root.stagedMediaThumbnailSource).length === 0
                        name: "semantic/video"
                        tone: Theme.textFaint
                        iconSize: 18
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    spacing: 3
                    Text {
                        objectName: "phoneStagedMediaSummary"
                        Layout.fillWidth: true
                        text: String(root.stagedMedia.displayName || "Media")
                        color: Theme.text
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        elide: Text.ElideMiddle
                    }
                    Text {
                        objectName: "phoneStagedMediaMetadata"
                        Layout.fillWidth: true
                        text: root.formatDuration(Number(root.stagedMedia.durationSeconds || 0))
                            + " · " + String(root.stagedMedia.resolution || "—")
                        color: Theme.textMuted
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }
                }
            }
        }
        Text {
            visible: !root.stagedMediaSourceAvailable
            Layout.fillWidth: true
            text: "Chưa có media đã duyệt"
            color: Theme.warning
            font.pixelSize: 11
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 8
            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                text: "Virtual Camera"
                color: Theme.textMuted
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
            PhoneFarmToggle {
                id: virtualCameraSwitch
                objectName: "phoneVirtualCameraSwitch"
                fixtureVisualActive: root.visualProductionFixture
                    && root.virtualCameraSourceAvailable
                    && Boolean(root.virtualCamera.enabled)
                checked: root.virtualCameraSourceAvailable
                    && Boolean(root.virtualCamera.enabled)
                activeFocusOnTab: true
                text: "Bật hoặc tắt Virtual Camera"
                enabled: root.actionAvailable(root.cameraAction)
                availabilityReason: root.actionReason(
                    root.cameraAction,
                    "Thiếu manifest runtime và nguồn camera đã xác minh"
                )
                onClicked: root.operationRequested(root.cameraAction)
            }
        }
        PhoneFarmFilterComboBox {
            objectName: "phoneVirtualCameraSource"
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            Layout.minimumWidth: 0
            model: root.cameraSources.length > 0
                ? root.cameraSources
                : [{"label": "Không có nguồn khả dụng"}]
            textRole: "label"
            activeFocusOnTab: true
            enabled: root.cameraSources.length > 1
            opacity: 1
            Accessible.role: Accessible.ComboBox
            Accessible.name: "Nguồn Virtual Camera"
            Accessible.description: root.cameraSources.length > 1
                ? "Chọn nguồn camera do server cung cấp"
                : "Chỉ có một nguồn camera đã xác minh"
        }

        Text {
            text: "Flow"
            color: Theme.textFaint
            font.pixelSize: 11
            font.weight: Font.DemiBold
        }
        RowLayout {
            objectName: "phoneFlowActionRow"
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.minimumHeight: root.visualProductionFixture ? 38 : 0
            Layout.preferredHeight: root.visualProductionFixture ? 38 : 36
            Layout.maximumHeight: root.visualProductionFixture ? 38 : 16777215
            spacing: 6
            AppButton {
                objectName: "phoneRunFlowButton"
                Layout.fillWidth: true
                Layout.preferredHeight: root.visualProductionFixture ? 32 : 36
                Layout.minimumWidth: 0
                clip: true
                text: "Chạy flow"
                leadingIcon: "semantic/workflow"
                activeFocusOnTab: true
                enabled: root.actionAvailable(root.flowStartAction)
                visualEnabled: enabled || (root.visualProductionFixture
                    && root.flowDefinitionAvailable)
                Accessible.name: text
                Accessible.description: root.actionReason(
                    root.flowStartAction,
                    "Snapshot chưa có flow versioned đã duyệt"
                )
                onClicked: root.operationRequested(root.flowStartAction)
            }
            AppButton {
                objectName: "phonePauseFlowButton"
                Layout.fillWidth: true
                Layout.preferredHeight: root.visualProductionFixture ? 32 : 36
                Layout.minimumWidth: 0
                clip: true
                text: "Tạm dừng"
                leadingIcon: "ui/columns-3"
                activeFocusOnTab: true
                enabled: root.actionAvailable(root.flowPauseAction)
                visualEnabled: enabled || (root.visualProductionFixture
                    && root.flowDefinitionAvailable
                    && root.activeOperationId.length > 0)
                Accessible.name: text
                Accessible.description: root.actionReason(
                    root.flowPauseAction,
                    "Chưa có flow run projection"
                )
                onClicked: root.operationRequested(root.flowPauseAction)
            }
        }

        Text {
            objectName: "phoneFlowSummary"
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            visible: !root.visualProductionFixture
            text: root.flowSummary
            color: root.flowDefinitionAvailable ? Theme.textMuted : Theme.warning
            font.pixelSize: 11
            elide: Text.ElideRight
        }

        Rectangle {
            objectName: "phoneCurrentFlowCard"
            property bool interactive: false
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.preferredHeight: visible
                ? (root.visualProductionFixture ? 80 : 88) : 0
            visible: root.visualProductionFixture
                && root.flowDefinitionAvailable
            enabled: false
            radius: 5
            color: Qt.rgba(
                Theme.elevated.r,
                Theme.elevated.g,
                Theme.elevated.b,
                0.78
            )
            border.width: 1
            border.color: Theme.borderSoft
            Accessible.name: "Flow hiện tại, "
                + String(root.flowDefinition.displayName || "Flow")
                + ", bước " + String(root.flowDefinition.currentStep || 0)
                + " trên " + String(root.flowDefinition.totalSteps || 0)
            Accessible.description: "Fixture production chỉ đọc; không thực thi flow"
            Accessible.role: Accessible.Pane

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.visualProductionFixture ? 6 : 8
                spacing: 2
                Text {
                    Layout.fillWidth: true
                    text: "Flow hiện tại"
                    color: Theme.textFaint
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text {
                        objectName: "phoneCurrentFlowName"
                        Layout.fillWidth: true
                        text: String(root.flowDefinition.displayName || "Flow")
                        color: Theme.text
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }
                    Text {
                        objectName: "phoneCurrentFlowStep"
                        text: "Bước "
                            + String(root.flowDefinition.currentStep || 0)
                            + " / " + String(root.flowDefinition.totalSteps || 0)
                        color: Theme.textMuted
                        font.pixelSize: 9
                        font.weight: Font.DemiBold
                    }
                }
                Text {
                    objectName: "phoneCurrentFlowStepLabel"
                    Layout.fillWidth: true
                    text: String(root.flowDefinition.currentStepLabel || "—")
                    color: Theme.textMuted
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }
                Rectangle {
                    id: flowProgress
                    objectName: "phoneCurrentFlowProgress"
                    property real progressValue: root.flowProgressValue
                    Layout.fillWidth: true
                    Layout.preferredHeight: 5
                    radius: 3
                    color: Theme.border
                    Rectangle {
                        width: parent.width * flowProgress.progressValue / 100
                        height: parent.height
                        radius: parent.radius
                        color: Theme.accent
                    }
                }
            }
        }

        AppButton {
            objectName: "phoneSafeStopButton"
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            Layout.minimumWidth: 0
            clip: true
            text: root.stopBusy ? "Đang yêu cầu dừng…" : "Dừng an toàn"
            leadingIcon: "semantic/alert-triangle"
            activeFocusOnTab: true
            enabled: root.activeOperationId.length > 0 && root.can("device.operate")
                && !root.demoReadOnly && !root.stopBusy
            visualEnabled: enabled || (root.visualProductionFixture
                && root.activeOperationId.length > 0)
            Accessible.name: text
            Accessible.description: enabled
                ? "Yêu cầu server dừng operation đang hoạt động"
                : "Không có operation hoạt động, thiếu quyền hoặc đang xử lý"
            onClicked: root.safeStopRequested()
        }

        Item {
            Layout.fillHeight: !root.visualProductionFixture
            Layout.preferredHeight: root.visualProductionFixture ? 0 : -1
        }

        Text {
            text: "Publish"
            color: Theme.textFaint
            font.pixelSize: 11
            font.weight: Font.DemiBold
        }
        Item {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.minimumHeight: root.visualProductionFixture ? 50 : 44
            Layout.preferredHeight: root.visualProductionFixture ? 50 : 44
            Layout.maximumHeight: root.visualProductionFixture ? 50 : 44
            Button {
                id: publishButton
                objectName: "phonePublishButton"
                anchors.fill: parent
                implicitHeight: 44
                property bool visuallyDominant: true
                property color emphasisTone: Theme.warning
                text: "Đăng video"
                activeFocusOnTab: true
                enabled: root.actionAvailable(root.publishAction)
                Accessible.name: text
                Accessible.description: enabled
                    ? "Gửi yêu cầu publish qua capability đã duyệt"
                    : root.actionReason(
                        root.publishAction,
                        "Đang khóa: approval publish chỉ do server cấp"
                    )
                onClicked: root.operationRequested(root.publishAction)
                contentItem: Item {
                    id: publishContent
                    objectName: "phonePublishContent"
                    RowLayout {
                        id: publishPrimaryContent
                        objectName: "phonePublishPrimaryContent"
                        anchors.centerIn: parent
                        spacing: 7
                        UiIcon {
                            id: publishLockIcon
                            objectName: "phonePublishLockIcon"
                            Layout.preferredWidth: root.visualProductionFixture ? 20 : 17
                            Layout.preferredHeight: Layout.preferredWidth
                            name: publishButton.enabled ? "semantic/upload-cloud" : "ui/lock"
                            tone: Theme.text
                            iconSize: root.visualProductionFixture ? 20 : 17
                        }
                        Text {
                            id: publishText
                            objectName: "phonePublishText"
                            text: publishButton.text
                            color: Theme.text
                            font.pixelSize: root.visualProductionFixture ? 15 : 13
                            font.weight: Font.Bold
                        }
                    }
                }
                background: Rectangle {
                    objectName: "phonePublishBackground"
                    readonly property int outlineWidth: border.width
                    radius: 5
                    color: publishButton.emphasisTone
                    border.width: root.visualProductionFixture ? 1 : 0
                    border.color: root.visualProductionFixture
                        ? Qt.darker(Theme.warning, 1.12) : "transparent"
                }
            }
            Foundation.IconButton {
                objectName: "phonePublishChevronButton"
                anchors.right: parent.right
                anchors.rightMargin: root.visualProductionFixture ? 38 : 6
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                text: ""
                iconName: "ui/chevron-down"
                activeFocusOnTab: true
                enabled: root.publishSourceAvailable && root.can("content.read")
                accessibleName: "Mở nội dung dùng để publish"
                onClicked: root.selectContentRequested()
            }
        }

        Device.StatusBadge {
            objectName: "phoneApprovalStatus"
            Layout.alignment: Qt.AlignHCenter
            Layout.minimumWidth: 0
            Layout.maximumWidth: Math.max(0, root.width - 28)
            clip: true
            status: root.publishState
            label: root.publishStatusLabel()
            detail: root.publishApprovalId
            iconName: "device/approval"
            provenance: root.statusProvenance
            visualProductionFixture: root.visualProductionFixture
            compact: true
            showDemoBadge: false
            property string text: resolvedLabel
            Accessible.name: resolvedLabel
            Accessible.description: root.publishApprovalId.length > 0
                ? "Approval do server cấp: " + root.publishApprovalId
                : "Không có approval publish do server cấp"
        }
        Text {
            objectName: "phonePublishApprovalNote"
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.publishApprovalId.length > 0
                ? "Approval do server cấp · " + root.publishApprovalId
                : "Hành động này yêu cầu phê duyệt theo chính sách."
            color: Theme.textFaint
            font.pixelSize: 10
            wrapMode: Text.Wrap
        }
    }
}
