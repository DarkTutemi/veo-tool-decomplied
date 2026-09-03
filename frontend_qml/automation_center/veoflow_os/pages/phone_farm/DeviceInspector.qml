pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../components/device" as Device

Panel {
    id: root
    objectName: "deviceInspector"
    clip: true

    property var device: ({})
    property var controlPlaneBridge: null
    property int commandRevision: 0
    property var permissionChecker: null
    property int selectedTab: 0
    property bool visualProductionFixture: Boolean(
        (((root.device || {}).microStatuses || {}).visual_production_fixture)
    )
    property var visualFixture: (root.device || {}).visualFixture || ({})
    color: Theme.panel
    readonly property real statusIconColumnWidth: 17
    readonly property real statusLabelColumnWidth: 94
    readonly property real statusValueColumnWidth: 138
    readonly property real statusBadgeColumnWidth: 62

    signal acquireLeaseRequested()
    signal extendLeaseRequested()
    signal releaseLeaseRequested()
    signal inspectRuntimeRequested()

    readonly property string deviceId: String((root.device || {}).deviceId || "")
    readonly property string leaseId: String((root.device || {}).leaseId || "")
    readonly property int leaseFencingToken: Number((root.device || {}).leaseFencingToken || 0)
    readonly property bool demoReadOnly: Boolean((root.device || {}).demoReadOnly)
    readonly property var inspectorProjection: (root.device || {}).inspector || ({})
    readonly property var virtualCameraProjection: root.inspectorProjection.virtualCamera || ({})
    readonly property var identityTemplateProjection: root.inspectorProjection.identityTemplate || ({})
    readonly property var residentEndpointProjection: root.inspectorProjection.residentEndpoint || ({})
    readonly property var runtimeProjection: root.inspectorProjection.runtime || ({})
    readonly property var flowProjection: ((root.device || {}).quickActions || {}).flow || ({})
    readonly property var microStatuses: (root.device || {}).microStatuses || ({})
    readonly property var healthStatus: root.microStatuses.health || ({})
    readonly property var networkStatus: root.microStatuses.network || ({})
    readonly property var powerStatus: root.microStatuses.power || ({})
    readonly property var agentStatus: root.microStatuses.agent || ({})
    readonly property var runtimeStatus: root.microStatuses.runtime || ({})
    readonly property var bindingStatus: root.microStatuses.binding || ({})
    readonly property var leaseStatus: root.microStatuses.lease || ({})
    readonly property var relayStatus: root.microStatuses.relay || ({})
    readonly property var castStatus: root.microStatuses.cast || ({})
    readonly property string statusProvenance: root.provenanceKey(
        root.microStatuses, root.device.presentationProvenance
    )
    readonly property string virtualCameraLabel: root.visualProductionFixture
            && root.hasValue((root.visualFixture || {}).virtualCameraLabel)
        ? String(root.visualFixture.virtualCameraLabel)
        : root.exact(root.virtualCameraProjection.label)
    readonly property string identityTemplateLabel: root.hasValue(
        root.visualProductionFixture
            ? (root.visualFixture || {}).identityTemplateLabel
            : root.identityTemplateProjection.label
    )
        ? String(root.visualProductionFixture
            ? root.visualFixture.identityTemplateLabel
            : root.identityTemplateProjection.label)
            + (!root.visualProductionFixture
                    && root.hasValue(root.identityTemplateProjection.matchPercent)
                ? " · " + String(root.identityTemplateProjection.matchPercent) + "%" : "")
        : "Không khả dụng"
    readonly property string residentEndpointLabel:
        root.visualProductionFixture
                && root.hasValue((root.visualFixture || {}).residentEndpointLabel)
        ? String(root.visualFixture.residentEndpointLabel)
        : root.hasValue(root.residentEndpointProjection.label)
        ? String(root.residentEndpointProjection.label)
        : String(root.residentEndpointProjection.state || "").toLowerCase()
            === "demo_only"
        ? "Không có endpoint"
        : root.exact(root.residentEndpointProjection.state)
    readonly property string runtimeChannelLabel: root.exact(root.runtimeProjection.channel)
    readonly property string runtimeSignatureLabel: root.exact(root.runtimeProjection.signatureState)
    readonly property string heartbeatDisplayLabel: root.compactTimestamp(
        root.device.heartbeatAt
    )
    readonly property string castSummaryLabel: root.visualProductionFixture
            && root.hasValue(root.castStatus.codecLabel)
        ? String(root.castStatus.codecLabel)
            + (root.hasValue(root.castStatus.resolution)
                ? " · " + String(root.castStatus.resolution) : "")
            + (root.hasValue(root.castStatus.fps)
                ? " · " + String(root.castStatus.fps) + "fps" : "")
        : root.exact(root.castStatus.codecLabel
            || root.device.castState || root.castStatus.state)
    readonly property string castDisplayLabel: root.visualProductionFixture
            && root.hasValue(root.castStatus.codecLabel)
        ? String(root.castStatus.codecLabel)
            + (root.hasValue(root.castStatus.resolution)
                ? " · " + String(root.castStatus.resolution).replace(/[xX]/, "×") : "")
        : root.castSummaryLabel
    readonly property string castFpsLabel: root.visualProductionFixture
            && root.hasValue(root.castStatus.fps)
        ? String(root.castStatus.fps) + " FPS" : ""
    readonly property var commandStore: root.controlPlaneBridge
        ? root.controlPlaneBridge.commandStore : null

    readonly property bool acquireBusy: {
        const revision = root.commandRevision
        return root.commandStore && root.deviceId.length > 0
            ? root.commandStore.isBusy("device.lease.acquire", "device", root.deviceId)
            : false
    }
    readonly property bool extendBusy: {
        const revision = root.commandRevision
        return root.commandStore && root.leaseId.length > 0
            ? root.commandStore.isBusy("device.lease.extend", "lease", root.leaseId)
            : false
    }
    readonly property bool releaseBusy: {
        const revision = root.commandRevision
        return root.commandStore && root.leaseId.length > 0
            ? root.commandStore.isBusy("device.lease.release", "lease", root.leaseId)
            : false
    }

    Accessible.role: Accessible.Pane
    Accessible.name: root.deviceId.length > 0
        ? "Chi tiết thiết bị " + String(root.device.label || root.deviceId)
        : "Chi tiết thiết bị, chưa chọn thiết bị"

    function hasValue(value) {
        return value !== undefined && value !== null && String(value).length > 0
    }

    function exact(value, suffix) {
        if (!root.hasValue(value))
            return "Không khả dụng"
        return String(value) + String(suffix || "")
    }

    function compactTimestamp(value) {
        if (!root.hasValue(value))
            return "Không khả dụng"
        const match = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})/.exec(
            String(value)
        )
        return match
            ? match[3] + "/" + match[2] + " · " + match[4] + ":" + match[5]
            : String(value)
    }

    function can(permission) {
        return root.permissionChecker
            ? Boolean(root.permissionChecker(String(permission || ""))) : false
    }

    function stateLabel(value) {
        const state = String(value || "unknown").toLowerCase()
        const labels = {
            "healthy": "Bình thường",
            "verified": "Đã xác minh",
            "ready": "Sẵn sàng",
            "connected": "Đã kết nối",
            "attention": "Cần chú ý",
            "degraded": "Suy giảm",
            "incompatible": "Không tương thích",
            "failed": "Lỗi",
            "error": "Lỗi",
            "offline": "Ngoại tuyến",
            "unavailable": "Không khả dụng",
            "unknown": "Không rõ"
        }
        return labels[state] || String(value || "Không rõ")
    }

    function stateTone(value) {
        const state = String(value || "unknown").toLowerCase()
        if (["healthy", "verified", "ready", "connected"].indexOf(state) >= 0)
            return Theme.success
        if (["attention", "degraded"].indexOf(state) >= 0)
            return Theme.warning
        if (["incompatible", "failed", "error"].indexOf(state) >= 0)
            return Theme.danger
        return Theme.textFaint
    }

    function provenanceKey(statuses, fallback) {
        const source = String(((statuses || {}).provenance || {}).source || fallback || "")
            .toLowerCase()
        const simulated = Boolean(((statuses || {}).provenance || {}).simulated)
        return simulated || ["demo_seed", "demo_only", "simulated"].indexOf(source) >= 0
            ? "demo_seed" : "production"
    }

    function presentStatus(value, fallback) {
        const state = String(value || fallback || "unknown").toLowerCase()
        const aliases = {
            "bound": "verified",
            "match": "verified",
            "normal": "healthy",
            "low": "attention",
            "poster_only": "demo_only",
            "reported": "verified"
        }
        return aliases[state] || state
    }

    function percentage(value) {
        return root.hasValue(value) ? String(Math.round(Number(value))) + "%" : "—"
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 14
        anchors.topMargin: 14
        anchors.bottomMargin: 14
        width: Math.max(0, root.width - 28)
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: 2
                Text {
                    objectName: "deviceInspectorTitle"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: "Chi tiết thiết bị"
                    color: Theme.text
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: root.deviceId.length > 0
                        ? String(root.device.label || root.deviceId) + " · " + root.deviceId
                        : "Chưa chọn thiết bị"
                    color: Theme.textFaint
                    font.pixelSize: 11
                    elide: Text.ElideMiddle
                }
            }

            Device.StatusBadge {
                objectName: "deviceInspectorDemoBadge"
                visible: root.statusProvenance !== "production"
                    && !root.visualProductionFixture
                status: "demo_only"
                label: "DEMO"
                provenance: root.statusProvenance
                showIcon: false
                compact: true
            }

        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            InspectorTab {
                objectName: "deviceInspectorTabOverview"
                label: "Tổng quan"
                selected: root.selectedTab === 0
                onActivated: root.selectedTab = 0
            }
            InspectorTab {
                objectName: "deviceInspectorTabAccount"
                label: "Tài khoản"
                selected: root.selectedTab === 1
                onActivated: root.selectedTab = 1
            }
            InspectorTab {
                objectName: "deviceInspectorTabNetwork"
                label: "Mạng"
                selected: root.selectedTab === 2
                onActivated: root.selectedTab = 2
            }
            InspectorTab {
                objectName: "deviceInspectorTabRuntime"
                label: "Runtime"
                selected: root.selectedTab === 3
                onActivated: root.selectedTab = 3
            }
            InspectorTab {
                objectName: "deviceInspectorTabAutomation"
                label: "Tự động"
                selected: root.selectedTab === 4
                onActivated: root.selectedTab = 4
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            currentIndex: root.selectedTab

            ScrollView {
                id: overviewStatusScroll
                objectName: "deviceInspectorStatusStack"
                clip: true
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    width: overviewStatusScroll.availableWidth
                    spacing: 0

                    Device.MetricStatusRow {
                        objectName: "deviceStatusModel"
                        showDemoBadge: false
                        showStatusBadge: false
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "semantic/smartphone"
                        label: "Thiết bị"
                        value: root.exact(root.device.model)
                        status: root.presentStatus(root.healthStatus.state, root.device.healthState)
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceStatusAndroid"
                        showDemoBadge: false
                        showStatusBadge: false
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/runtime"
                        label: "Android"
                        value: root.exact(root.device.androidVersion)
                        status: root.presentStatus(
                            root.runtimeStatus.compatibilityState,
                            root.device.compatibilityState
                        )
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceStatusAgent"
                        showDemoBadge: false
                        showStatusBadge: effectiveStatus !== "demo_only"
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/agent"
                        label: "Agent"
                        value: root.exact(root.agentStatus.version || root.device.agentVersion)
                        status: root.presentStatus(root.agentStatus.state, "unknown")
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceRuntimeCurrentStatus"
                        showDemoBadge: false
                        showStatusBadge: true
                        statusVisualStyle: "chip"
                        statusLabel: effectiveStatus === "demo_only"
                            ? "Bản demo" : (effectiveStatus === "current" ? "Mới nhất" : "")
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/runtime"
                        label: "Runtime"
                        value: root.exact(root.runtimeStatus.version || root.device.runtimeVersion)
                        status: root.presentStatus(root.runtimeStatus.state, "unknown")
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceStatusHeartbeat"
                        showDemoBadge: false
                        showStatusBadge: false
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/health"
                        label: "Heartbeat"
                        value: root.heartbeatDisplayLabel
                        detail: root.exact(root.device.heartbeatAt)
                        status: root.presentStatus(root.networkStatus.state, "unknown")
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceStatusPower"
                        showDemoBadge: false
                        showStatusBadge: false
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/health"
                        label: "Pin"
                        value: root.percentage(root.powerStatus.batteryPercent)
                        status: root.presentStatus(root.powerStatus.state, "unknown")
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceStatusTemperature"
                        showDemoBadge: false
                        showStatusBadge: false
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/temperature"
                        label: "Nhiệt độ"
                        value: root.exact(
                            root.device.temperature,
                            root.hasValue(root.device.temperature) ? "°C" : ""
                        )
                        status: root.presentStatus(root.powerStatus.state, "unknown")
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceStatusForeground"
                        showDemoBadge: false
                        showStatusBadge: false
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/operation"
                        label: "Foreground"
                        value: root.exact(root.device.foreground)
                        status: root.hasValue(root.device.foreground) ? "active" : "unavailable"
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceBindingVerifiedStatus"
                        showDemoBadge: false
                        showStatusBadge: ["verified", "bound", "match"].indexOf(
                            effectiveStatus
                        ) >= 0
                        statusVisualStyle: "icon_only"
                        statusIconName: "semantic/check-circle"
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/account-link"
                        label: "Tài khoản"
                        value: root.exact(root.device.handle || root.device.accountId)
                        status: root.presentStatus(root.bindingStatus.state, "unavailable")
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceStatusNetwork"
                        showDemoBadge: false
                        showStatusBadge: false
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/relay"
                        label: "Proxy / Khu vực"
                        value: root.exact(root.networkStatus.region || root.device.proxyRegion)
                        detail: root.exact(root.networkStatus.exitIp || root.device.exitIp)
                        status: root.presentStatus(root.networkStatus.state, "unknown")
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceStatusResident"
                        showDemoBadge: false
                        showStatusBadge: effectiveStatus !== "demo_only"
                        statusLabel: root.visualProductionFixture
                                && effectiveStatus === "online"
                            ? "Online" : ""
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/agent"
                        label: "Resident Agent"
                        value: root.residentEndpointLabel
                        status: root.presentStatus(
                            root.residentEndpointProjection.state,
                            root.agentStatus.state
                        )
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceStatusRelay"
                        showDemoBadge: false
                        showStatusBadge: true
                        statusVisualStyle: "chip"
                        statusLabel: root.visualProductionFixture
                                && root.hasValue(root.relayStatus.rttMs)
                            ? String(root.relayStatus.rttMs) + "ms"
                            : (effectiveStatus === "demo_only" ? "Không relay" : "")
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/relay"
                        label: "Relay"
                        value: root.demoReadOnly && !root.visualProductionFixture
                            ? "Không có relay trực tiếp"
                            : root.exact(
                                root.visualProductionFixture
                                    ? (root.visualFixture || {}).relayEndpointLabel
                                    : root.relayStatus.endpointLabel
                                || root.device.relayState
                                || root.relayStatus.state
                            )
                        status: root.presentStatus(root.relayStatus.state, "unavailable")
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceStatusVirtualCamera"
                        showDemoBadge: false
                        showStatusBadge: effectiveStatus !== "demo_only"
                        statusLabel: root.visualProductionFixture
                                && ["ready", "active"].indexOf(effectiveStatus) >= 0
                            ? "Bật" : ""
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "ui/camera"
                        label: "Camera ảo"
                        value: root.virtualCameraLabel
                        status: root.presentStatus(
                            root.virtualCameraProjection.state,
                            "unavailable"
                        )
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceStatusCast"
                        showDemoBadge: false
                        showStatusBadge: true
                        statusVisualStyle: "chip"
                        statusLabel: root.visualProductionFixture
                                && ["ready", "streaming"].indexOf(
                                    effectiveStatus
                                ) >= 0
                            ? root.castFpsLabel
                            : (effectiveStatus === "demo_only" ? "Poster" : "")
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/cast"
                        label: "Screen Cast"
                        value: root.demoReadOnly && !root.visualProductionFixture
                            ? "Poster DEMO"
                            : root.castDisplayLabel
                        detail: root.castSummaryLabel
                        status: root.presentStatus(root.castStatus.state, "unavailable")
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceStatusIdentity"
                        showDemoBadge: false
                        showStatusBadge: effectiveStatus !== "demo_only"
                        statusLabel: root.visualProductionFixture
                                && effectiveStatus === "verified"
                                && root.hasValue(
                                    root.identityTemplateProjection.matchPercent
                                )
                            ? "Khớp "
                                + String(
                                    root.identityTemplateProjection.matchPercent
                                ) + "%"
                            : ""
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/account-link"
                        label: "Identity Template"
                        value: root.identityTemplateLabel
                        status: root.presentStatus(
                            root.bindingStatus.regionMatchState,
                            "unavailable"
                        )
                        provenance: root.statusProvenance
                        compact: true
                    }
                    Device.MetricStatusRow {
                        objectName: "deviceOperationalHealthStatus"
                        visualProductionFixture: root.visualProductionFixture
                        showDemoBadge: false
                        statusVisualStyle: "dot_text"
                        statusTextColor: root.visualProductionFixture
                            ? Theme.textMuted : statusTone
                        statusLabel: effectiveStatus === "healthy"
                            ? "Ổn định" : root.stateLabel(effectiveStatus)
                        iconColumnWidth: root.statusIconColumnWidth
                        labelColumnWidth: root.statusLabelColumnWidth
                        valueColumnWidth: root.statusValueColumnWidth
                        statusColumnWidth: root.statusBadgeColumnWidth
                        Layout.fillWidth: true
                        iconName: "device/health"
                        label: "Health"
                        value: root.stateLabel(
                            root.healthStatus.state || root.device.healthState
                        )
                        status: root.presentStatus(
                            root.healthStatus.state,
                            root.device.healthState
                        )
                        provenance: root.statusProvenance
                        compact: true
                    }
                }
            }

            InspectorSection {
                rows: [
                    {"label": "Account", "value": root.exact(root.device.accountId)},
                    {"label": "Channel", "value": root.exact(root.device.channelId)},
                    {"label": "Handle", "value": root.exact(root.device.handle)},
                    {"label": "Ràng buộc", "value": root.hasValue(root.device.accountId) ? "Một tài khoản / thiết bị" : "Không khả dụng"}
                ]
            }

            InspectorSection {
                rows: [
                    {"label": "Khu vực proxy", "value": root.exact(root.device.proxyRegion)},
                    {"label": "Exit IP", "value": root.exact(root.device.exitIp)},
                    {"label": "Độ trễ", "value": root.exact(root.device.latencyMs, root.hasValue(root.device.latencyMs) ? " ms" : "")},
                    {"label": "Resident endpoint", "value": root.residentEndpointLabel},
                    {"label": "Relay", "value": root.exact(root.device.relayState)}
                ]
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6
                    InspectorSection {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        rows: [
                            {"label": "Agent", "value": root.exact(root.device.agentVersion)},
                            {"label": "Runtime", "value": root.exact(root.device.runtimeVersion)},
                            {"label": "Protocol", "value": root.exact(root.device.residentProtocolVersion)},
                            {"label": "Kiến trúc", "value": root.exact(root.device.architecture)},
                            {"label": "Kênh rollout", "value": root.runtimeChannelLabel},
                            {"label": "Chữ ký runtime", "value": root.runtimeSignatureLabel}
                        ]
                    }
                    AppButton {
                        objectName: "deviceRuntimeInspectButton"
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        clip: true
                        text: "Kiểm tra runtime"
                        activeFocusOnTab: true
                        enabled: root.deviceId.length > 0 && root.leaseId.length > 0
                            && root.leaseFencingToken > 0 && root.can("device.operate")
                            && !root.demoReadOnly
                        Accessible.name: text
                        Accessible.description: enabled
                            ? "Tạo device.runtime.inspect dưới lease và fencing token hiện tại"
                            : "Cần thiết bị, lease hợp lệ và quyền device.operate"
                        onClicked: root.inspectRuntimeRequested()
                    }
                }
            }

            InspectorSection {
                rows: [
                    {"label": "Operation đang chạy", "value": root.exact(root.device.activeOperationId)},
                    {"label": "Flow run", "value": root.exact(root.flowProjection.displayName)},
                    {"label": "Bước gần nhất", "value": root.exact(root.flowProjection.currentStepLabel)},
                    {"label": "Trạng thái flow", "value": root.exact(root.flowProjection.state)}
                ]
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 7

            Device.LeaseBanner {
                objectName: "deviceLeaseBanner"
                Layout.fillWidth: true
                leaseId: String(root.leaseStatus.leaseId || root.leaseId || "")
                holderLabel: String(root.leaseStatus.holderLabel
                    || root.device.leaseHolder || "")
                leaseState: root.demoReadOnly && !root.visualProductionFixture
                    ? "demo_only"
                    : String(root.leaseStatus.state
                        || (root.leaseId.length > 0 ? "active" : "none"))
                remainingSeconds: Number(root.leaseStatus.remainingSeconds === undefined
                    ? -1 : root.leaseStatus.remainingSeconds)
                fencingToken: Number(root.leaseStatus.fencingToken
                    || root.leaseFencingToken || 0)
                ownedByOperator: Boolean(root.leaseStatus.ownedByOperator)
                demoReadOnly: root.demoReadOnly
                visualProductionFixture: root.visualProductionFixture
                fixtureOwnerLabel: String(
                    (root.visualFixture || {}).leaseOwnerLabel || ""
                )
                fixtureSinceLabel: String(
                    (root.visualFixture || {}).leaseSinceLabel || ""
                )
                extendActionObjectName: "deviceLeaseExtendButton"
                showExtendAction: root.leaseId.length > 0
                extendActionEnabled: root.leaseId.length > 0
                    && root.leaseFencingToken > 0 && root.can("device.operate")
                    && !root.demoReadOnly && !root.releaseBusy
                extendBusy: root.extendBusy
                onExtendRequested: root.extendLeaseRequested()
            }

            RowLayout {
                objectName: "deviceLeaseExternalActionRow"
                Layout.fillWidth: true
                spacing: 6
                visible: !root.demoReadOnly
                AppButton {
                    objectName: "deviceLeaseAcquireButton"
                    visible: root.leaseId.length === 0
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    clip: true
                    text: root.acquireBusy ? "Đang yêu cầu…" : "Nhận lease"
                    primary: true
                    activeFocusOnTab: true
                    enabled: root.deviceId.length > 0 && root.can("device.operate")
                        && !root.demoReadOnly && !root.acquireBusy
                    Accessible.name: text
                    Accessible.description: enabled
                        ? "Yêu cầu server cấp lease độc quyền cho thiết bị"
                        : "Thiếu thiết bị, quyền vận hành hoặc đang xử lý"
                    onClicked: root.acquireLeaseRequested()
                }
                AppButton {
                    objectName: "deviceLeaseReleaseButton"
                    visible: root.leaseId.length > 0
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    clip: true
                    text: root.releaseBusy ? "Đang nhả…" : "Nhả lease"
                    activeFocusOnTab: true
                    enabled: root.leaseId.length > 0 && root.leaseFencingToken > 0
                        && root.can("device.operate") && !root.demoReadOnly
                        && !root.releaseBusy && !root.extendBusy
                    Accessible.name: text
                    Accessible.description: enabled
                        ? "Nhả lease bằng fencing token hiện tại"
                        : "Lease không hợp lệ, thiếu quyền hoặc đang xử lý"
                    onClicked: root.releaseLeaseRequested()
                }
            }
        }
    }

    component InspectorTab: AppButton {
        id: tab
        required property string label
        required property bool selected
        signal activated()
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        implicitHeight: 30
        clip: true
        leftPadding: 4
        rightPadding: 4
        text: tab.label
        primary: tab.selected
        activeFocusOnTab: true
        Accessible.name: tab.label
        Accessible.description: tab.selected ? "Tab đang chọn" : "Chuyển tab chi tiết thiết bị"
        onClicked: tab.activated()
    }

    component InspectorSection: ScrollView {
        id: section
        required property var rows
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: section.availableWidth
            spacing: 0

            Repeater {
                model: section.rows
                delegate: Item {
                    id: detailRow
                    required property int index
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    Accessible.role: Accessible.Row
                    Accessible.name: String(detailRow.modelData.label) + ", " + String(detailRow.modelData.value)

                    RowLayout {
                        anchors.fill: parent
                        spacing: 8
                        Text {
                            Layout.preferredWidth: 104
                            text: String(detailRow.modelData.label)
                            color: Theme.textFaint
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            text: String(detailRow.modelData.value)
                            color: text === "Không khả dụng" ? Theme.warning : Theme.textMuted
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideMiddle
                        }
                    }
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: Theme.borderSoft
                    }
                }
            }
        }
    }
}
