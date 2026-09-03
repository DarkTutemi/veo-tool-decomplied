pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import "../foundation" as Foundation
import "studio" as Studio

Item {
    id: root
    objectName: "studioPage"
    Accessible.role: Accessible.Pane
    Accessible.name: "Studio hoàn thiện video"

    // qmllint disable unqualified
    readonly property var plane: controlPlane
    // qmllint enable unqualified
    property var studioSnapshot: ({})
    property var snapshotError: ({})
    property int commandRevision: 0
    property int selectionRevision: 0

    readonly property var studioData: (root.studioSnapshot || {}).data || ({})
    readonly property var headerData: root.studioData.header || ({})
    readonly property var inputsData: root.studioData.inputs || ({})
    readonly property var sourceData: root.studioData.source || ({})
    readonly property var recipeData: root.studioData.recipe || ({})
    readonly property var previewData: root.studioData.preview || ({})
    readonly property var qcData: root.studioData.qc || ({})
    readonly property var renderData: root.studioData.render || ({})
    readonly property var processData: root.studioData.process || ({})
    readonly property var estimatorsData: root.studioData.estimators || ({})
    readonly property var assetModel: root.plane.snapshotStore.collection("studio", "assets")
    readonly property var qcRuleModel: root.plane.snapshotStore.collection("studio", "qc_rules")
    readonly property var qcGroupModel: root.plane.snapshotStore.collection("studio", "qc_groups")
    readonly property var qcAdvisoryModel: root.plane.snapshotStore.collection("studio", "qc_advisories")
    readonly property var processStepModel: root.plane.snapshotStore.collection("studio", "process_steps")
    readonly property var workspaceFlowModel: root.plane.snapshotStore.collection("studio", "workspace_flow")

    property string selectedAssetId: ""
    property string selectedChannelId: ""
    property string aspectRatio: "9:16"
    property string studioMode: "manual"
    property var draftDefinition: ({})
    property string draftId: ""
    property string draftBaseFingerprint: ""
    property int draftRevision: 0
    property bool draftDirty: false
    property var compiledPreview: ({})
    property int pendingPreviewRevision: -1
    property string pendingPreviewAssetId: ""
    property string activeRecipeTab: "recipe"
    property string renderKind: "final"
    property int renderPriority: 50
    property string assignmentOverridePolicy: "allow_manual"
    property var batchSelection: ({})
    readonly property int batchSelectionCount: Object.keys(root.batchSelection || ({})).length

    readonly property var editorData: (root.recipeData || {}).editor || ({})
    readonly property var deliveryData: root.editorData.delivery || ({})
    readonly property var renderPolicyData: root.deliveryData.render_policy || ({})
    readonly property var assignmentData: (root.recipeData || {}).assignment || ({})
    readonly property bool deliveryAvailable: Boolean(root.deliveryData.available)

    readonly property bool canRead: root.hasPermission("studio.read")
    readonly property bool hasData: root.hasProjectionData()
    readonly property string viewState: root.resolveViewState()
    readonly property bool previewAfterAvailable: Boolean(
        (root.compiledPreview || {}).valid
        && (((root.compiledPreview || {}).proxy || {}).available)
    )
    readonly property bool previewBusy: {
        const revision = root.commandRevision
        return Boolean(root.draftId) && root.plane.commandStore.isBusy(
            "studio.preview.compile", "studio_draft", root.draftId
        )
    }
    readonly property bool snapshotBusy: {
        const revision = root.commandRevision
        return root.plane.commandStore.isBusy(
            "studio.workspace.snapshot", "global", "global"
        )
    }
    readonly property bool qcBusy: {
        const revision = root.commandRevision
        return Boolean(root.selectedAssetId) && root.plane.commandStore.isBusy(
            "studio.qc.run", "asset", root.selectedAssetId
        )
    }
    readonly property bool saveBusy: {
        const revision = root.commandRevision
        const channelId = String((root.recipeData.channel || {}).id || "")
        const pipelineKey = String(root.recipeData.pipeline_key || "")
        if (pipelineKey)
            return root.plane.commandStore.isBusy(
                "studio.pipeline.revise", "studio_pipeline", pipelineKey
            )
        return root.plane.commandStore.isBusy(
            "studio.pipeline.create", channelId ? "channel" : "global", channelId || "global"
        )
    }
    readonly property bool renderBusy: {
        const revision = root.commandRevision
        const channelId = String((root.recipeData.channel || {}).id || "")
        return root.plane.commandStore.isBusy(
            "studio.render.create", channelId ? "target_channel" : "global", channelId || "global"
        )
    }
    readonly property bool batchRenderBusy: {
        const revision = root.commandRevision
        const channelId = String((root.recipeData.channel || {}).id || "")
        return root.plane.commandStore.isBusy(
            "studio.render.batch.create",
            channelId ? "target_channel" : "global",
            channelId || "global"
        )
    }
    readonly property bool assignmentBusy: {
        const revision = root.commandRevision
        const channelId = String((root.recipeData.channel || {}).id || "")
        return Boolean(channelId) && root.plane.commandStore.isBusy(
            "studio.assignment.set", "channel", channelId
        )
    }

    function cloneValue(value) {
        if (value === undefined || value === null) return ({})
        return JSON.parse(JSON.stringify(value))
    }

    function hasPermission(permission) {
        const requested = String(permission || "").trim()
        if (!requested) return false
        const permissions = (root.studioSnapshot || {}).permissions || []
        return permissions.indexOf(requested) >= 0
            || permissions.indexOf("workspace.admin") >= 0
    }

    function hasProjectionData() {
        return root.assetModel && root.assetModel.count > 0
    }

    function resolveViewState() {
        const snapshot = root.studioSnapshot || ({})
        const error = root.snapshotError || ({})
        const hasSnapshot = String(snapshot.snapshot_id || "").length > 0
        const errorCode = String(error.code || "").toUpperCase()
        if (!hasSnapshot) {
            if (errorCode === "PERMISSION_DENIED" || errorCode === "FORBIDDEN")
                return "permission"
            return errorCode.length > 0 ? "error" : "loading"
        }
        if (!root.canRead) return "permission"
        if (errorCode === "NETWORK_ERROR" || errorCode === "OFFLINE") return "offline"
        if (errorCode.length > 0) return "error"
        if (!root.hasData) return "empty"
        const freshness = String((snapshot.freshness || {}).state || "fresh").toLowerCase()
        if (freshness === "partial" || freshness === "stale") return freshness
        return "content"
    }

    function assetForId(assetId) {
        const identity = String(assetId || "")
        if (!root.assetModel) return ({})
        for (let index = 0; index < root.assetModel.count; index++) {
            const item = root.assetModel.get(index) || ({})
            if (String(item.asset_id || "") === identity) return item
        }
        return ({})
    }

    function reconcileSelection() {
        const projected = String(root.inputsData.selected_asset_id || "")
        if (projected && root.assetForId(projected).asset_id) {
            if (root.selectedAssetId !== projected) {
                root.selectedAssetId = projected
                root.invalidatePreview()
            }
            return
        }
        if (root.selectedAssetId && root.assetForId(root.selectedAssetId).asset_id) return
        root.selectedAssetId = root.assetModel && root.assetModel.count > 0
            ? String((root.assetModel.get(0) || {}).asset_id || "") : ""
        root.invalidatePreview()
    }

    function channelOption(channelId) {
        const identity = String(channelId || "")
        const options = root.headerData.channels || []
        for (let index = 0; index < options.length; index++) {
            if (String((options[index] || {}).id || "") === identity)
                return options[index]
        }
        return ({})
    }

    function reconcileChannel() {
        const projected = String((root.recipeData.channel || {}).id || "")
        if (projected && root.channelOption(projected).id) {
            root.selectedChannelId = projected
            return false
        }
        if (root.selectedChannelId && root.channelOption(root.selectedChannelId).id)
            return false
        const options = root.headerData.channels || []
        root.selectedChannelId = options.length > 0
            ? String((options[0] || {}).id || "") : ""
        return root.selectedChannelId.length > 0
    }

    function hydrateDraft() {
        const recipe = root.recipeData || ({})
        const definition = recipe.definition || ({})
        const fingerprint = String(recipe.definition_fingerprint || "")
        const key = String(recipe.pipeline_key || "new")
        const version = Number(recipe.version || 0)
        const nextId = "studio-draft-" + key + "-v" + version
        if (root.draftDirty && root.draftBaseFingerprint === fingerprint) return
        if (root.draftBaseFingerprint === fingerprint
                && root.draftId === nextId
                && Object.keys(root.draftDefinition).length > 0) return
        root.draftDefinition = root.cloneValue(definition)
        root.draftBaseFingerprint = fingerprint
        root.draftId = nextId
        root.draftRevision = 0
        root.draftDirty = false
        root.syncDeliveryOptions()
        root.invalidatePreview()
    }

    function syncDeliveryOptions() {
        const policy = root.renderPolicyData || ({})
        const options = policy.priority_options || []
        const finalPriority = Number(policy.final_priority || 50)
        if (!root.deliveryAvailable) {
            root.renderKind = "final"
            root.renderPriority = 50
            return
        }
        if (["draft", "final"].indexOf(root.renderKind) < 0)
            root.renderKind = "final"
        const preferred = root.renderKind === "draft"
            ? Number(policy.draft_priority || finalPriority) : finalPriority
        if (options.indexOf(root.renderPriority) < 0)
            root.renderPriority = preferred
    }

    function reloadSnapshot() {
        root.studioSnapshot = root.plane.snapshotStore.snapshot("studio")
        root.snapshotError = root.plane.snapshotStore.error("studio")
        const headerAspect = String(root.headerData.aspect_ratio || "")
        const headerMode = String(root.headerData.mode || "")
        if (!root.draftDirty && headerAspect) root.aspectRatio = headerAspect
        if (headerMode) root.studioMode = headerMode
        root.reconcileSelection()
        const shouldLoadChannel = root.reconcileChannel()
        root.hydrateDraft()
        root.selectionRevision += 1
        if (shouldLoadChannel)
            Qt.callLater(function() {
                // The channel-less bootstrap snapshot may have selected a
                // render that belongs to a different recipe context. Clear
                // every stale contextual selector so this single refetch can
                // project the default channel, source, recipe and exact QC.
                root.requestSnapshot({
                    "cursor": "0",
                    "channel_id": root.selectedChannelId,
                    "selected_pipeline_key": undefined,
                    "selected_pipeline_version": undefined,
                    "selected_render_id": undefined
                })
            })
    }

    function invalidatePreview() {
        root.compiledPreview = ({})
        root.pendingPreviewRevision = -1
        root.pendingPreviewAssetId = ""
    }

    function markDraftChanged(nextDefinition) {
        root.draftDefinition = root.cloneValue(nextDefinition)
        const output = (nextDefinition || {}).output || ({})
        const width = Number(output.width || 0)
        const height = Number(output.height || 0)
        if (width > 0 && height > 0) {
            if (width * 16 === height * 9) root.aspectRatio = "9:16"
            else if (width * 9 === height * 16) root.aspectRatio = "16:9"
            else if (width === height) root.aspectRatio = "1:1"
        }
        root.draftRevision += 1
        root.draftDirty = true
        root.invalidatePreview()
    }

    function outputPreset(aspect) {
        const options = root.headerData.aspect_ratios || []
        for (let index = 0; index < options.length; index++) {
            const option = options[index] || ({})
            if (String(option.key || "") === aspect) return option
        }
        return ({})
    }

    function setAspectRatio(value: string): bool {
        const nextAspect = String(value || "")
        if (["16:9", "9:16"].indexOf(nextAspect) < 0) return false
        if (root.aspectRatio === nextAspect) return true
        root.aspectRatio = nextAspect
        if (root.studioMode === "auto") {
            root.invalidatePreview()
            return root.requestSnapshot({
                "cursor": "0",
                "aspect_ratio": nextAspect,
                "mode": "auto",
                "selected_pipeline_key": undefined,
                "selected_pipeline_version": undefined
            })
        }
        const definition = root.cloneValue(root.draftDefinition)
        if (!definition.output) definition.output = ({})
        const preset = root.outputPreset(nextAspect)
        if (preset.profile) definition.output.profile = String(preset.profile)
        if (Number(preset.width || 0) > 0) definition.output.width = Number(preset.width)
        if (Number(preset.height || 0) > 0) definition.output.height = Number(preset.height)
        root.markDraftChanged(definition)
        return true
    }

    function setModeValue(value: string): bool {
        const nextMode = String(value || "")
        if (["manual", "auto"].indexOf(nextMode) < 0) return false
        const modes = root.headerData.modes || []
        for (let index = 0; index < modes.length; index++) {
            const option = modes[index] || ({})
            if (String(option.key || "") !== nextMode) continue
            if (option.available === false) return false
            root.studioMode = nextMode
            root.invalidatePreview()
            return root.requestSnapshot({"cursor": "0", "mode": nextMode})
        }
        return false
    }

    function selectRecipeTab(key: string): bool {
        const target = String(key || "")
        const tabs = root.recipeData.tabs || []
        for (let index = 0; index < tabs.length; index++) {
            const tab = tabs[index] || ({})
            if (String(tab.key || "") === target && Boolean(tab.available)) {
                root.activeRecipeTab = target
                return true
            }
        }
        return false
    }

    function selectChannel(channelId: string): bool {
        const identity = String(channelId || "")
        if (!root.channelOption(identity).id || root.draftDirty)
            return false
        if (root.selectedChannelId === identity
                && String((root.recipeData.channel || {}).id || "") === identity)
            return true
        root.selectedChannelId = identity
        root.invalidatePreview()
        return root.requestSnapshot({
            "cursor": "0",
            "channel_id": identity,
            "selected_pipeline_key": undefined,
            "selected_pipeline_version": undefined,
            "selected_render_id": undefined
        })
    }

    function strictQuery(overrides) {
        const patch = overrides || ({})
        const query = {
            "media_type": "video",
            "readiness": String(inputPane.readinessValue || "all"),
            "qc_status": String(inputPane.qcValue || "all"),
            "limit": 5,
            "aspect_ratio": root.aspectRatio,
            "mode": root.studioMode
        }
        const search = String(inputPane.searchText || "").trim()
        const source = String(inputPane.sourceValue || "").trim()
        if (search) query.search = search
        if (source) query.source = source
        if (root.selectedAssetId) query.selected_asset_id = root.selectedAssetId
        if (root.selectedChannelId) query.channel_id = root.selectedChannelId
        const pipelineKey = String(root.recipeData.pipeline_key || "")
        const pipelineVersion = root.recipeData.version
        if (pipelineKey) query.selected_pipeline_key = pipelineKey
        if (pipelineKey && pipelineVersion > 0) query.selected_pipeline_version = pipelineVersion
        const renderId = String(root.renderData.id || "")
        if (renderId) query.selected_render_id = renderId
        for (const key in patch) {
            if (patch[key] === undefined || patch[key] === null || patch[key] === "")
                delete query[key]
            else
                query[key] = patch[key]
        }
        return query
    }

    function requestSnapshot(overrides) {
        if (!root.canRead || root.snapshotBusy) return false
        root.plane.callTool("studio.workspace.snapshot", root.strictQuery(overrides))
        return true
    }

    function applyFilters() {
        return root.requestSnapshot(({}))
    }

    function nextPage() {
        const cursor = String(root.inputsData.next_cursor || "")
        if (!cursor) return false
        return root.requestSnapshot({"cursor": cursor})
    }

    function previousPage() {
        const cursor = Math.max(0, Number(root.inputsData.cursor || 0) - 5)
        if (Number(root.inputsData.cursor || 0) <= 0) return false
        return root.requestSnapshot({"cursor": String(cursor)})
    }

    function selectAsset(assetId) {
        const identity = String(assetId || "")
        if (!root.assetForId(identity).asset_id) return false
        if (root.selectedAssetId !== identity) {
            root.selectedAssetId = identity
            root.invalidatePreview()
        }
        return root.requestSnapshot({"cursor": "0", "selected_asset_id": identity})
    }

    function previewBindings() {
        const definition = root.draftDefinition || ({})
        const bindings = root.cloneValue(definition.default_bindings || ({}))
        if (root.selectedAssetId) bindings.primary = root.selectedAssetId
        return {"assets": bindings}
    }

    function compilePreview() {
        const action = root.headerData.actions ? root.headerData.actions.preview || ({}) : ({})
        if (!root.canRead || !Boolean(action.enabled) || root.previewBusy
                || !root.selectedAssetId || Object.keys(root.draftDefinition).length === 0)
            return false
        root.pendingPreviewRevision = root.draftRevision
        root.pendingPreviewAssetId = root.selectedAssetId
        root.plane.callTool("studio.preview.compile", {
            "definition": root.cloneValue(root.draftDefinition),
            "bindings": root.previewBindings(),
            "output_name": "preview-" + root.selectedAssetId + ".mp4",
            "draft_id": root.draftId
        })
        return true
    }

    function canRunQc() {
        const target = root.qcData.target || ({})
        const platform = String(target.platform || "").toLowerCase()
        return root.canRead && !root.qcBusy && Boolean(root.selectedAssetId)
            && Object.keys(root.draftDefinition).length > 0
            && Boolean(target.supported)
            && (target.supported_platforms || []).indexOf(platform) >= 0
    }

    function runQc() {
        if (!root.canRunQc()) return false
        const platform = String((root.qcData.target || {}).platform || "").toLowerCase()
        root.plane.callTool("studio.qc.run", {
            "asset_id": root.selectedAssetId,
            "definition": root.cloneValue(root.draftDefinition),
            "platforms": [platform]
        })
        return true
    }

    function canSaveRecipe() {
        const action = (root.headerData.actions || {}).save_recipe || ({})
        return root.canRead && Boolean(action.enabled) && root.draftDirty
            && !root.saveBusy && Object.keys(root.draftDefinition).length > 0
    }

    function saveRecipe() {
        if (!root.canSaveRecipe()) return false
        const recipe = root.recipeData || ({})
        const channel = recipe.channel || ({})
        const key = String(recipe.pipeline_key || "")
        if (key) {
            root.plane.callTool("studio.pipeline.revise", {
                "pipeline_key": key,
                "base_version": recipe.version,
                "name": String(recipe.name || "Studio recipe"),
                "description": String(recipe.description || ""),
                "definition": root.cloneValue(root.draftDefinition),
                "state": "active",
                "idempotency_key": "studio-save-" + root.draftId + "-r" + root.draftRevision
            })
        } else {
            const payload = {
                "name": String(recipe.name || "Studio recipe"),
                "description": String(recipe.description || ""),
                "definition": root.cloneValue(root.draftDefinition),
                "idempotency_key": "studio-create-" + root.draftId + "-r" + root.draftRevision
            }
            if (channel.id) payload.channel_id = String(channel.id)
            root.plane.callTool("studio.pipeline.create", payload)
        }
        return true
    }

    function canRenderVideo() {
        const action = (root.headerData.actions || {}).render || ({})
        const summary = root.qcData.summary || ({})
        const scope = root.qcData.scope || ({})
        return root.canRead && Boolean(action.enabled) && !root.renderBusy
            && !root.draftDirty && Boolean(root.selectedAssetId)
            && Boolean(root.recipeData.pipeline_key) && Number(root.recipeData.version || 0) > 0
            && String(root.recipeData.status || "") === "active"
            && String(root.qcData.state || "") === "available"
            && Boolean(scope.exact_recipe) && Number(summary.failed || 0) === 0
    }

    function projectedOutputName() {
        const naming = root.deliveryData.output_naming || ({})
        const example = String(naming.example || "")
        if (/^[A-Za-z0-9][A-Za-z0-9._-]{0,195}\.mp4$/.test(example))
            return example
        return "render-" + root.selectedAssetId + "-v"
            + Number(root.recipeData.version || 0) + ".mp4"
    }

    function renderVideo() {
        if (!root.canRenderVideo()) return false
        const channelId = String((root.recipeData.channel || {}).id || "")
        const payload = {
            "pipeline_key": String(root.recipeData.pipeline_key),
            "pipeline_version": root.recipeData.version,
            "bindings": root.previewBindings(),
            "output_name": root.projectedOutputName(),
            "priority": root.deliveryAvailable ? root.renderPriority : 50,
            "idempotency_key": "studio-render-" + String(root.recipeData.pipeline_key)
                + "-v" + String(root.recipeData.version) + "-" + root.selectedAssetId
        }
        if (root.deliveryAvailable) {
            payload.render_kind = root.renderKind
            payload.idempotency_key += "-" + root.renderKind + "-p" + root.renderPriority
        }
        if (channelId) payload.target_channel_id = channelId
        root.plane.callTool("studio.render.create", payload)
        return true
    }

    function batchAssetIds() {
        const ids = []
        for (const assetId in (root.batchSelection || ({}))) {
            if (root.batchSelection[assetId] && root.assetForId(assetId).asset_id)
                ids.push(String(assetId))
        }
        ids.sort()
        return ids
    }

    function canRenderBatch() {
        const action = (root.headerData.actions || {}).batch_render || ({})
        const ids = root.batchAssetIds()
        const minimum = Number(action.min_items || 2)
        const maximum = Number(action.max_items || 25)
        return root.canRead && Boolean(action.enabled) && !root.batchRenderBusy
            && !root.draftDirty && Boolean(root.recipeData.pipeline_key)
            && Number(root.recipeData.version || 0) > 0
            && ids.length >= minimum && ids.length <= maximum
            && Boolean((root.editorData.timing || {}).current.slot)
    }

    function batchOutputName(assetId, index) {
        const asset = root.assetForId(assetId) || ({})
        const raw = String(asset.file_name || assetId).replace(/\.[^.]+$/, "")
        const stem = raw.replace(/[^A-Za-z0-9._-]+/g, "-").replace(/^-+|-+$/g, "")
        return (stem || ("video-" + (index + 1))) + "-v"
            + Number(root.recipeData.version || 0) + ".mp4"
    }

    function renderBatch() {
        if (!root.canRenderBatch()) return false
        const ids = root.batchAssetIds()
        const timing = (root.editorData.timing || {}).current || ({})
        const primarySlot = String(timing.slot || "")
        const shared = root.cloneValue((root.draftDefinition || {}).default_bindings || ({}))
        delete shared[primarySlot]
        const channelId = String((root.recipeData.channel || {}).id || "")
        const payload = {
            "pipeline_key": String(root.recipeData.pipeline_key),
            "pipeline_version": root.recipeData.version,
            "primary_slot": primarySlot,
            "items": ids.map(function(assetId, index) {
                return {"asset_id": assetId, "output_name": root.batchOutputName(assetId, index)}
            }),
            "shared_bindings": {"assets": shared},
            "render_kind": root.deliveryAvailable ? root.renderKind : "final",
            "priority": root.deliveryAvailable ? root.renderPriority : 50,
            "idempotency_key": "studio-batch-" + String(root.recipeData.pipeline_key)
                + "-v" + String(root.recipeData.version) + "-" + ids.join("-")
        }
        if (channelId) payload.target_channel_id = channelId
        root.plane.callTool("studio.render.batch.create", payload)
        return true
    }

    function setRenderOptions(kind: string, priority: int): bool {
        const nextKind = String(kind || "")
        const nextPriority = Number(priority || 0)
        const options = root.renderPolicyData.priority_options || []
        if (!root.deliveryAvailable || ["draft", "final"].indexOf(nextKind) < 0
                || options.indexOf(nextPriority) < 0)
            return false
        root.renderKind = nextKind
        root.renderPriority = nextPriority
        return true
    }

    function canSetChannelAssignment() {
        const action = (root.headerData.actions || {}).set_assignment || ({})
        return root.canRead && Boolean(action.enabled) && !root.assignmentBusy
            && !root.draftDirty && Boolean((root.recipeData.channel || {}).id)
            && Boolean(root.recipeData.pipeline_key)
            && Number(root.recipeData.version || 0) > 0
            && root.deliveryAvailable
    }

    function setChannelAssignment(): bool {
        if (!root.canSetChannelAssignment()) return false
        const channelId = String((root.recipeData.channel || {}).id || "")
        const version = root.recipeData.version
        const assignmentVersion = root.assignmentData.version
        const payload = {
            "channel_id": channelId,
            "aspect_ratio": root.aspectRatio,
            "pipeline_key": String(root.recipeData.pipeline_key),
            "pipeline_version": version,
            "default_mode": "auto",
            "override_policy": root.assignmentOverridePolicy,
            "idempotency_key": "studio-assignment-" + channelId + "-"
                + root.aspectRatio + "-" + String(root.recipeData.pipeline_key)
                + "-v" + version + "-base" + assignmentVersion
        }
        if (assignmentVersion > 0) payload.base_version = assignmentVersion
        root.plane.callTool("studio.assignment.set", payload)
        return true
    }

    function followDeepLink(link) {
        const target = link || ({})
        const entity = target.entity || ({})
        if (!target.route) return false
        root.plane.navigateEntity(
            String(target.route), String(entity.type || ""), String(entity.id || ""),
            target.context || ({})
        )
        return true
    }

    function openQcGroup(groupKey) {
        const link = root.cloneValue(root.qcData.deep_link || ({}))
        if (!link.context) link.context = ({})
        link.context.rule_group = String(groupKey || "")
        return root.followDeepLink(link)
    }

    Component.onCompleted: root.reloadSnapshot()

    Connections {
        target: root.plane.snapshotStore
        function onChanged(route) {
            if (route === "studio") root.reloadSnapshot()
        }
    }
    Connections {
        target: root.plane.commandStore
        function onChanged(capability, entityType, entityId) {
            root.commandRevision += 1
        }
    }
    Connections {
        target: root.plane
        function onActionFinished(toolName, ok, data, message) {
            if ((toolName === "studio.pipeline.create" || toolName === "studio.pipeline.revise") && ok) {
                root.draftDirty = false
                root.requestSnapshot(({}))
                return
            }
            if (toolName === "studio.assignment.set" && ok) {
                root.studioMode = "auto"
                root.requestSnapshot({"cursor": "0", "mode": "auto"})
                return
            }
            if (toolName === "studio.render.create" && ok) {
                const render = (data || {}).render || ({})
                const renderId = String(render.id || "")
                root.requestSnapshot(renderId ? {"selected_render_id": renderId} : ({}))
                return
            }
            if (toolName === "studio.render.batch.create" && ok) {
                root.batchSelection = ({})
                root.requestSnapshot(({}))
                return
            }
            if (toolName !== "studio.preview.compile" || !ok) return
            const result = data || ({})
            if (String(result.draft_id || "") !== root.draftId) return
            if (root.pendingPreviewRevision !== root.draftRevision) return
            if (root.pendingPreviewAssetId !== root.selectedAssetId) return
            root.compiledPreview = root.cloneValue(result)
        }
    }

    FileDialog {
        id: sourceDialog
        title: "Chọn video nguồn"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Video (*.mp4 *.mov *.mkv *.webm *.avi *.m4v)"]
        onAccepted: root.plane.callTool("asset.register.local", {
            // qmllint disable unqualified
            "path": root.plane.localPath(selectedFile),
            // qmllint enable unqualified
            "provider": "native_operator",
            "provenance": {"surface": "studio", "mode": root.studioMode},
            "platforms": ["youtube", "tiktok", "facebook"]
        })
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Studio.StudioHeader {
            id: studioHeader
            Layout.fillWidth: true
            Layout.preferredHeight: 72
            headerData: root.headerData
            aspectRatio: root.aspectRatio
            modeValue: root.studioMode
            canRead: root.canRead
            draftDirty: root.draftDirty
            saveEnabled: root.canSaveRecipe()
            saveBusy: root.saveBusy
            renderEnabled: root.canRenderVideo()
            renderBusy: root.renderBusy
            renderPolicy: root.renderPolicyData
            renderKind: root.renderKind
            renderPriority: root.renderPriority
            onAspectRequested: value => root.setAspectRatio(value)
            onModeRequested: value => root.setModeValue(value)
            onSaveRequested: root.saveRecipe()
            onRenderRequested: root.renderVideo()
            onRenderOptionsRequested: (kind, priority) => root.setRenderOptions(kind, priority)
        }

        Foundation.AsyncStateView {
            id: stateView
            objectName: "studioAsyncState"
            Layout.fillWidth: true
            Layout.fillHeight: true
            viewState: root.viewState
            hasData: root.hasData
            accessibleName: "Không gian Studio"
            emptyTitle: "Chưa có video trong Studio"
            emptyDescription: "Nhập video nguồn để bắt đầu chỉnh sửa và tạo video hoàn chỉnh."
            emptyIconName: "semantic/video"
            emptyEyebrow: "STUDIO ĐÃ SẴN SÀNG"
            emptyGuidance: [
                {"title": "Chọn video", "description": "Nhập MP4, MOV, MKV hoặc WebM"},
                {"title": "Chỉnh video", "description": "Cắt khung, thêm logo, phụ đề và chỉnh âm thanh"},
                {"title": "Kiểm tra & xuất", "description": "Xem trước chất lượng rồi tạo video hoàn chỉnh"}
            ]
            emptyActionText: "Nhập video"
            emptyActionIconName: "semantic/upload-cloud"
            emptyActionEnabled: root.canRead && !root.snapshotBusy
            emptyActionReason: emptyActionEnabled ? "" : "Studio chưa sẵn sàng nhận video"
            emptySecondaryActionText: "Làm mới"
            emptySecondaryActionIconName: "ui/refresh-cw"
            emptySecondaryActionEnabled: !root.snapshotBusy
            emptySecondaryActionReason: emptySecondaryActionEnabled ? "" : "Đang tải Studio"
            onEmptyAction: sourceDialog.open()
            onEmptySecondaryAction: root.requestSnapshot(({}))
            errorMessage: String(root.snapshotError.message || "Không thể tải Studio.")
            requiredPermission: "studio.read"
            onRetry: root.requestSnapshot(({}))

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8

                    Studio.StudioInputPane {
                        id: inputPane
                        Layout.preferredWidth: 300
                        Layout.minimumWidth: 285
                        Layout.fillHeight: true
                        inputsData: root.inputsData
                        assetModel: root.assetModel
                        controlPlaneBridge: root.plane
                        snapshotRevision: root.selectionRevision
                        selectedAssetId: root.selectedAssetId
                        batchSelection: root.batchSelection
                        canRead: root.canRead
                        busy: root.snapshotBusy
                        onImportRequested: sourceDialog.open()
                        onRefreshRequested: root.requestSnapshot(({}))
                        onFiltersRequested: root.applyFilters()
                        onAssetRequested: assetId => root.selectAsset(assetId)
                        onBatchSelectionRequested: selection => root.batchSelection = root.cloneValue(selection)
                        onBatchRenderRequested: root.renderBatch()
                        onPreviousRequested: root.previousPage()
                        onNextRequested: root.nextPage()
                    }

                    Studio.StudioPreviewPane {
                        id: previewPane
                        Layout.preferredWidth: 390
                        Layout.minimumWidth: 370
                        Layout.fillHeight: true
                        sourceData: root.sourceData
                        previewData: root.previewData
                        compiledPreview: root.compiledPreview
                        controlPlaneBridge: root.plane
                        aspectRatio: root.aspectRatio
                        previewBusy: root.previewBusy
                        afterAvailable: root.previewAfterAvailable
                        canCompile: root.canRead
                            && Boolean(((root.headerData.actions || {}).preview || {}).enabled)
                            && Boolean(root.selectedAssetId)
                            && Object.keys(root.draftDefinition).length > 0
                        qcData: root.qcData
                        onCompileRequested: root.compilePreview()
                        onQcDetailsRequested: root.followDeepLink(root.qcData.deep_link)
                    }

                    Studio.RecipeEditor {
                        id: recipeEditor
                        Layout.fillWidth: true
                        Layout.minimumWidth: 405
                        Layout.fillHeight: true
                        recipeData: root.recipeData
                        draftDefinition: root.draftDefinition
                        activeTab: root.activeRecipeTab
                        aspectRatio: root.aspectRatio
                        draftDirty: root.draftDirty
                        canEdit: root.canRead
                        assetModel: root.assetModel
                        channelOptions: root.headerData.channels || []
                        selectedChannelId: root.selectedChannelId
                        assignmentOverridePolicy: root.assignmentOverridePolicy
                        onTabRequested: key => root.selectRecipeTab(key)
                        onDefinitionChanged: definition => root.markDraftChanged(definition)
                        onChannelRequested: channelId => root.selectChannel(channelId)
                        onAssignmentRequested: root.setChannelAssignment()
                        onAssignmentOverrideRequested: policy => root.assignmentOverridePolicy = policy
                    }

                    Studio.QcInspector {
                        id: qcInspector
                        Layout.preferredWidth: 280
                        Layout.minimumWidth: 270
                        Layout.fillHeight: true
                        qcData: root.qcData
                        ruleModel: root.qcRuleModel
                        groupModel: root.qcGroupModel
                        advisoryModel: root.qcAdvisoryModel
                        estimatorsData: root.estimatorsData
                        recipeData: root.recipeData
                        canRun: root.canRunQc()
                        runBusy: root.qcBusy
                        onRunRequested: root.runQc()
                        onReportRequested: root.followDeepLink(root.qcData.deep_link)
                        onGroupRequested: key => root.openQcGroup(key)
                        onFixRequested: targetTab => root.selectRecipeTab(targetTab)
                    }
                }

                Studio.StudioProcessRail {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 112
                    processData: root.processData
                    stepModel: root.processStepModel
                    workspaceFlowModel: root.workspaceFlowModel
                    onEntityRequested: entity => {
                        if (!entity || !entity.type || !entity.id) return
                        const route = entity.type === "asset" || entity.type === "asset_qc"
                            ? "content" : "studio"
                        root.plane.navigateEntity(route, String(entity.type), String(entity.id), {"subview": "detail"})
                    }
                    onDeepLinkRequested: link => root.followDeepLink(link)
                }
            }
        }
    }
}
