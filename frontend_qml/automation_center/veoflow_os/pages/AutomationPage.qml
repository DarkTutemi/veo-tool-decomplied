pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../foundation" as Foundation
import "automation" as Automation

Item {
    id: root
    objectName: "automationPage"
    Accessible.name: "Trung tâm tự động hóa theo kênh"
    Accessible.role: Accessible.Pane

    property var automationSnapshot: ({})
    property var snapshotError: ({})
    property bool embeddedMode: false
    property string activeTab: "fleet"
    property string searchText: ""
    property string platformFilter: ""
    property string groupFilter: ""
    property string stateFilter: ""
    property string activityKind: ""
    property string selectedChannelId: ""
    property string selectedRuleKey: ""
    property string cursor: ""
    property var fleetSelectedChannelIds: []
    property string bannerMessage: ""
    // qmllint disable unqualified
    readonly property var plane: controlPlane
    // qmllint enable unqualified
    readonly property var snapshotData: root.mapOrEmpty(
        root.mapOrEmpty(root.automationSnapshot).data)
    readonly property var fleetData: root.mapOrEmpty(root.snapshotData.fleet)
    readonly property var rulesData: root.mapOrEmpty(root.snapshotData.rules)
    readonly property var distributionData: root.mapOrEmpty(
        root.snapshotData.distribution)
    readonly property var activityData: root.mapOrEmpty(root.snapshotData.activity)
    readonly property var runtimeData: root.mapOrEmpty(root.snapshotData.runtime)
    readonly property var systemAutomation: root.mapOrEmpty(
        root.mapOrEmpty(root.plane.systemStatus).automation)
    readonly property var effectiveRuntime: root.liveRuntimeState()
    readonly property var navigationData: root.snapshotData.navigation || []
    readonly property var selectedChannel: root.mapOrEmpty(
        root.snapshotData.selected_channel)
    readonly property bool hasProjectionData: root.navigationData.length > 0
        || Number(root.fleetData.total || 0) > 0
        || Number(root.rulesData.total || 0) > 0
        || Number(root.activityData.total || 0) > 0
    readonly property string viewState: root.resolveViewState()

    function mapOrEmpty(value) {
        return value === null || value === undefined ? ({}) : value
    }

    function authorizedThumbnail(preview) {
        const item = root.mapOrEmpty(preview)
        const assetId = String(item.asset_id || "")
        const thumbnail = String(item.thumbnail_url || "")
        if (!assetId || !thumbnail)
            return ""
        return root.plane.authorizedThumbnailUrl(assetId, thumbnail)
    }

    function reloadSnapshot() {
        root.automationSnapshot = root.plane.snapshotStore.snapshot("automation")
        root.snapshotError = root.plane.snapshotStore.error("automation")
        const projectedTab = String(root.snapshotData.active_tab || "")
        if (projectedTab)
            root.activeTab = projectedTab
        const selected = root.mapOrEmpty(root.selectedChannel.channel)
        if (selected.id)
            root.selectedChannelId = String(selected.id)
        const selectedRule = root.mapOrEmpty(root.rulesData.selected)
        if (selectedRule.rule_key)
            root.selectedRuleKey = String(selectedRule.rule_key)
    }

    function resolveViewState() {
        const snapshot = root.mapOrEmpty(root.automationSnapshot)
        const error = root.mapOrEmpty(root.snapshotError)
        const hasSnapshot = String(snapshot.snapshot_id || "").length > 0
        const code = String(error.code || "").toUpperCase()
        if (!hasSnapshot) {
            if (code === "PERMISSION_DENIED" || code === "FORBIDDEN")
                return "permission"
            return code ? "error" : "loading"
        }
        if (code === "NETWORK_ERROR" || code === "OFFLINE")
            return "offline"
        if (code)
            return "error"
        const freshness = String(root.mapOrEmpty(snapshot.freshness).state || "fresh").toLowerCase()
        if (freshness === "partial" || freshness === "stale")
            return freshness
        return root.hasProjectionData ? "content" : "empty"
    }

    function snapshotQuery(overrides) {
        const extra = root.mapOrEmpty(overrides)
        const query = {"tab": String(extra.tab !== undefined ? extra.tab : root.activeTab)}
        const search = String(extra.search !== undefined ? extra.search : root.searchText)
        const platform = String(extra.platform !== undefined ? extra.platform : root.platformFilter)
        const group = String(extra.group_key !== undefined ? extra.group_key : root.groupFilter)
        const state = String(extra.fleet_state !== undefined ? extra.fleet_state : root.stateFilter)
        const channelId = String(extra.selected_channel_id !== undefined
            ? extra.selected_channel_id : root.selectedChannelId)
        const ruleKey = String(extra.selected_rule_key !== undefined
            ? extra.selected_rule_key : root.selectedRuleKey)
        const kind = String(extra.activity_kind !== undefined
            ? extra.activity_kind : root.activityKind)
        const nextCursor = String(extra.cursor !== undefined ? extra.cursor : root.cursor)
        if (search) query.search = search
        if (platform) query.platform = platform
        if (group) query.group_key = group
        if (state) query.fleet_state = state
        if (channelId) query.selected_channel_id = channelId
        if (ruleKey) query.selected_rule_key = ruleKey
        if (kind) query.activity_kind = kind
        if (nextCursor) query.cursor = nextCursor
        query.limit = 50
        query.event_limit = 50
        query.activity_hours = 24
        return query
    }

    function requestSnapshot(overrides) {
        root.plane.callTool("automation.snapshot", root.snapshotQuery(overrides))
    }

    function openDeepLink(link) {
        const projected = root.mapOrEmpty(link)
        const entity = root.mapOrEmpty(projected.entity)
        const route = String(projected.route || "")
        if (!route)
            return false
        root.plane.navigateEntity(
            route,
            String(entity.type || ""),
            String(entity.id || ""),
            root.mapOrEmpty(projected.context)
        )
        return true
    }

    function requestTab(tabKey) {
        root.activeTab = String(tabKey || "fleet")
        root.cursor = ""
        root.requestSnapshot({"tab": root.activeTab, "cursor": ""})
    }

    function openCreatePlan() {
        root.activeTab = "rules"
        rulePanel.openCreate()
    }

    function selectChannel(item) {
        const channel = root.mapOrEmpty(root.mapOrEmpty(item).channel)
        const id = String(channel.id || "")
        if (!id)
            return
        root.selectedChannelId = id
        root.requestSnapshot({"selected_channel_id": id})
    }

    function selectRule(item) {
        const candidate = root.mapOrEmpty(item)
        const key = String(candidate.plan_key || candidate.rule_key || "")
        if (!key)
            return
        root.selectedRuleKey = key
        root.requestSnapshot({"tab": "rules", "selected_rule_key": key})
    }

    function cloneMap(value) {
        const source = root.mapOrEmpty(value)
        const result = ({})
        const keys = Object.keys(source)
        for (let index = 0; index < keys.length; ++index)
            result[keys[index]] = source[keys[index]]
        return result
    }

    function liveRuntimeState() {
        const projected = root.mapOrEmpty(root.runtimeData)
        const system = root.mapOrEmpty(root.systemAutomation)
        const result = root.cloneMap(projected)
        const keys = ["publish_runner", "care_runner", "real_hands"]
        for (let index = 0; index < keys.length; ++index) {
            const key = keys[index]
            const live = root.mapOrEmpty(system[key])
            result[key] = Object.keys(live).length > 0
                ? root.cloneMap(live)
                : root.cloneMap(root.mapOrEmpty(projected[key]))
        }
        return result
    }

    function dispatchAction(action, overrides) {
        const descriptor = root.mapOrEmpty(action)
        if (descriptor.available !== true || !descriptor.capability)
            return false
        const input = root.cloneMap(root.mapOrEmpty(descriptor.input))
        const extra = root.mapOrEmpty(overrides)
        const keys = Object.keys(extra)
        for (let index = 0; index < keys.length; ++index)
            input[keys[index]] = extra[keys[index]]
        if (String(descriptor.capability).indexOf("automation.rule.") === 0) {
            const capability = String(descriptor.capability)
            const ruleKey = String(input.rule_key || "new-rule")
            const version = String(input.expected_version || 0)
            input.idempotency_key = "ui:" + capability + ":" + ruleKey + ":v" + version
        }
        root.plane.callTool(String(descriptor.capability), input)
        return true
    }

    function toggleFleetChannel(channelId, checked) {
        const id = String(channelId || "")
        const next = []
        for (let index = 0; index < root.fleetSelectedChannelIds.length; ++index) {
            const current = String(root.fleetSelectedChannelIds[index])
            if (current !== id)
                next.push(current)
        }
        if (checked && id)
            next.push(id)
        root.fleetSelectedChannelIds = next
    }

    function selectFleetPage() {
        const rows = root.fleetData.items || []
        const next = []
        for (let index = 0; index < rows.length; ++index) {
            const channel = root.mapOrEmpty(rows[index].channel)
            if (channel.id)
                next.push(String(channel.id))
        }
        root.fleetSelectedChannelIds = next
    }

    function applyRuleToFleet(rule) {
        const selectedRule = root.mapOrEmpty(rule)
        const action = root.mapOrEmpty(root.mapOrEmpty(selectedRule.actions).apply)
        root.dispatchAction(action, {
            "mode": "add",
            "channel_ids": root.fleetSelectedChannelIds
        })
    }

    Connections {
        target: root.plane.snapshotStore
        function onChanged(route) {
            if (route === "automation")
                root.reloadSnapshot()
        }
    }

    Connections {
        target: root.plane
        function onActionFinished(toolName, ok, data, message) {
            const name = String(toolName || "")
            if (name.indexOf("automation.rule.") === 0) {
                root.bannerMessage = ok
                    ? "Kế hoạch đã được lưu thành phiên bản mới."
                    : String(message || "Không thể lưu thay đổi của kế hoạch.")
                if (ok)
                    root.requestSnapshot({})
            }
        }
    }

    Component.onCompleted: root.reloadSnapshot()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.embeddedMode ? 0 : 22
        spacing: root.embeddedMode ? 0 : 12

        Automation.AutomationFleetHeader {
            objectName: "automationFleetHeader"
            Layout.fillWidth: true
            Layout.preferredHeight: root.embeddedMode ? 0 : 156
            visible: !root.embeddedMode
            navigation: root.navigationData
            activeTab: root.activeTab
            runtime: root.effectiveRuntime
            fleet: root.fleetData
            rules: root.rulesData
            activity: root.activityData
            bannerMessage: root.bannerMessage
            onTabRequested: function(tabKey) { root.requestTab(tabKey) }
            onCreateRuleRequested: {
                root.requestTab("rules")
                rulePanel.openCreate()
            }
            onRefreshRequested: root.requestSnapshot({})
        }

        Foundation.AsyncStateView {
            id: asyncState
            objectName: "automationAsyncState"
            Layout.fillWidth: true
            Layout.fillHeight: true
            accessibleName: "Dữ liệu tự động hóa theo kênh"
            viewState: root.viewState
            hasData: root.hasProjectionData
            emptyTitle: "Chưa có kênh tự động"
            emptyDescription: "Kênh xuất hiện sau khi được thêm và sở hữu bởi workspace."
            errorMessage: String(root.mapOrEmpty(root.snapshotError).message
                || "Không thể tải Automation Fleet.")
            requiredPermission: "workspace.read"
            freshnessBannerEnabled: false
            onRetry: {
                if (String(root.mapOrEmpty(root.automationSnapshot).snapshot_id || ""))
                    root.requestSnapshot({})
                else
                    root.plane.refreshSnapshotTool("automation.snapshot")
            }

            Automation.AutomationFleetPanel {
                objectName: "automationFleetPanel"
                anchors.fill: parent
                visible: root.activeTab === "fleet"
                fleet: root.fleetData
                selectedChannel: root.selectedChannel
                runtime: root.effectiveRuntime
                rules: root.rulesData
                controlPlaneBridge: root.plane
                selectedChannelIds: root.fleetSelectedChannelIds
                searchText: root.searchText
                groupFilter: root.groupFilter
                platformFilter: root.platformFilter
                stateFilter: root.stateFilter
                onFiltersRequested: function(search, group, platform, state) {
                    root.searchText = search
                    root.groupFilter = group
                    root.platformFilter = platform
                    root.stateFilter = state
                    root.cursor = ""
                    root.requestSnapshot({
                        "search": search,
                        "group_key": group,
                        "platform": platform,
                        "fleet_state": state,
                        "cursor": ""
                    })
                }
                onChannelSelected: function(item) { root.selectChannel(item) }
                onDeepLinkRequested: function(link) { root.openDeepLink(link) }
                onActionRequested: function(action) { root.dispatchAction(action, {}) }
                onSelectionToggled: function(channelId, checked) {
                    root.toggleFleetChannel(channelId, checked)
                }
                onSelectPageRequested: root.selectFleetPage()
                onClearSelectionRequested: root.fleetSelectedChannelIds = []
                onBulkRuleRequested: function(rule) { root.applyRuleToFleet(rule) }
                onNextPageRequested: {
                    root.cursor = String(root.fleetData.next_cursor || "")
                    root.requestSnapshot({"cursor": root.cursor})
                }
            }

            Automation.AutomationRulePanel {
                id: rulePanel
                objectName: "automationRulePanel"
                anchors.fill: parent
                visible: root.activeTab === "rules"
                rules: root.rulesData
                distribution: root.distributionData
                onRuleSelected: function(item) { root.selectRule(item) }
                onActionRequested: function(action, overrides) {
                    root.dispatchAction(action, overrides)
                }
                onDeepLinkRequested: function(link) { root.openDeepLink(link) }
            }

            Automation.AutomationActivityPanel {
                id: activityPanel
                objectName: "automationActivityPanel"
                anchors.fill: parent
                visible: root.activeTab === "activity"
                activity: root.activityData
                controlPlaneBridge: root.plane
                kindFilter: root.activityKind
                groupFilter: root.groupFilter
                platformFilter: root.platformFilter
                onFiltersRequested: function(group, platform, kind) {
                    root.groupFilter = group
                    root.platformFilter = platform
                    root.activityKind = kind
                    activityPanel.resetPage()
                    root.requestSnapshot({
                        "group_key": group,
                        "platform": platform,
                        "activity_kind": kind
                    })
                }
                onDeepLinkRequested: function(link) { root.openDeepLink(link) }
            }
        }
    }
}
