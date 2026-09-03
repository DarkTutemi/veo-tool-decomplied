pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "CenterFormat.js" as Fmt

Item {
    id: root
    objectName: "centerChannelConfigurationPage"

    required property var plane
    signal navigateRequested(string route)
    signal openWorkflowRequested(string workflow)

    property int selectedProfileIndex: 0
    property int modelRevision: 0
    property string query: ""
    property string draftLanguage: ""
    property string draftAudience: ""
    property string draftPositioning: ""
    property string draftPillars: ""
    property string draftCharacterId: ""
    property string draftCharacterIds: ""
    property string draftVoiceId: ""
    property string draftStyleId: ""
    property string draftCharacterPolicy: "ai"
    property string draftObjectPolicy: "ai"
    property string draftBackgroundPolicy: "ai"
    property string draftCaptionMode: "publish_kit"
    property string draftTimezone: "UTC"
    property int draftIntervalMinutes: 1440
    property var sourcePolicyDraft: ({})
    property bool draftDirty: false
    property string activeEditorTab: "overview"
    property var channelKit: ({})
    property string loadedKitKey: ""
    property bool kitLoading: false
    property bool kitRequestPending: false
    property string kitError: ""
    property string selectedWorkflowKey: "master"
    property string workflowDraftText: "{}"
    property bool workflowDraftDirty: false
    property bool workflowDraftSyncing: false
    property string workflowDraftError: ""
    property string sourceDefaultsDraftText: "{}"
    property string sourceDefaultsError: ""
    property string feedbackMessage: ""
    property bool feedbackOk: false
    property var revisionDiff: ({})
    property int cloneTargetIndex: -1
    property string pendingCloneTargetProfileId: ""
    readonly property bool compactLayout: width < 1450
    readonly property bool shortLayout: height < 820

    readonly property var selectedProfile: root.profileAt(root.selectedProfileIndex)
    readonly property var selectedConfig: root.resolveConfig(root.selectedProfile)
    readonly property string channelProfileId: String(
        root.selectedConfig.channelProfileId
        || root.selectedProfile.channelProfileId || "")
    readonly property int channelProfileVersion: Math.max(0, Number(
        root.channelKit.channel_profile_version
        || root.selectedConfig.version
        || root.selectedProfile.channelProfileVersion || 0))
    readonly property string channelProfileHash: String(
        root.channelKit.channel_profile_hash
        || root.selectedConfig.configHash
        || root.selectedProfile.channelProfileHash || "")
    readonly property var selectedWorkflow: root.kitWorkflow(root.selectedWorkflowKey)
    readonly property var workflowRows: [
        {"key": "master", "label": "MASTER PROMPT"},
        {"key": "clone", "label": "CLONE VIDEO"},
        {"key": "transcript", "label": "AUDIO TO VIDEO"},
        {"key": "affiliate", "label": "AFFILIATE"},
        {"key": "timemachine", "label": "TIME MACHINE"}
    ]

    function profileAt(index) {
        const revision = root.modelRevision
        if (!root.plane.profileModel || index < 0
                || index >= Number(root.plane.profileModel.count || 0))
            return ({})
        return root.plane.profileModel.get(index) || ({})
    }

    function selectProfileById(profileId) {
        const wanted = String(profileId || "")
        const model = root.plane.profileModel
        if (!wanted || !model)
            return false
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const row = model.get(index) || ({})
            if (String(row.profileId || "") === wanted) {
                root.selectProfile(index)
                return true
            }
        }
        return false
    }

    function resolveConfig(profile) {
        const revision = root.modelRevision
        const embedded = profile && profile.channelProfile ? profile.channelProfile : ({})
        const profileId = String(profile.profileId || "")
        const channelId = String(profile.channelId || "")
        const model = root.plane.channelProfileModel
        if (model) {
            for (let index = 0; index < Number(model.count || 0); ++index) {
                const row = model.get(index) || ({})
                if (String(row.socialProfileId || "") === profileId
                        || (channelId && String(row.channelId || "") === channelId))
                    return row
            }
        }
        return embedded
    }

    function cloneJson(value) {
        try {
            return JSON.parse(JSON.stringify(value === undefined ? ({}) : value))
        } catch (error) {
            return ({})
        }
    }

    function compactValue(value) {
        if (value === null || value === undefined)
            return "null"
        if (typeof value === "string")
            return value
        try {
            const encoded = JSON.stringify(value)
            return encoded.length > 100 ? encoded.slice(0, 97) + "…" : encoded
        } catch (error) {
            return String(value)
        }
    }

    function joinLines(value) {
        const values = value || []
        const result = []
        for (let index = 0; index < values.length; ++index) {
            const clean = String(values[index] || "").trim()
            if (clean && result.indexOf(clean) < 0)
                result.push(clean)
        }
        return result.join("\n")
    }

    function splitLines(value) {
        const parts = String(value || "").split(/[\n,;]+/)
        const result = []
        for (let index = 0; index < parts.length; ++index) {
            const clean = String(parts[index] || "").trim()
            if (clean && result.indexOf(clean) < 0)
                result.push(clean)
        }
        return result
    }

    function assetSource(category) {
        const policy = root.selectedConfig.assetPolicy || root.channelKit.asset_policy || ({})
        const scopes = policy.scopes || policy
        const raw = scopes[String(category || "")] || "ai"
        const source = typeof raw === "object"
            ? String(raw.source || raw.source_policy || "ai")
            : String(raw || "ai")
        return ["ai", "hybrid", "library_only", "disabled"].indexOf(source) >= 0
            ? source : "ai"
    }

    function defaultSourcePolicy() {
        const result = ({})
        for (let index = 0; index < root.workflowRows.length; ++index) {
            const key = String(root.workflowRows[index].key)
            const modes = root.sourceModeCatalog(key)
            result[key] = {
                "enabled": true,
                "allowed_input_modes": modes.slice(0),
                "default_input_mode": modes.length > 0 ? modes[0] : "",
                "defaults": ({})
            }
        }
        return result
    }

    function sourceModeCatalog(workflow) {
        const catalogs = {
            "master": ["idea", "script"],
            "clone": ["video_url", "local_video"],
            "transcript": ["text", "audio_url", "audio_file"],
            "affiliate": ["prepared_product"],
            "timemachine": ["idea"]
        }
        return (catalogs[String(workflow || "")] || []).slice(0)
    }

    function policyFromKit() {
        const current = root.selectedConfig.sourcePolicy
            || root.selectedConfig.source_policy || ({})
        if (Object.keys(current).length > 0)
            return root.cloneJson(current)
        const result = root.defaultSourcePolicy()
        const rows = root.channelKit.workflows || []
        for (let index = 0; index < rows.length; ++index) {
            const row = rows[index] || ({})
            const key = String(row.workflow || "")
            if (key)
                result[key] = root.cloneJson(row.source_policy || result[key])
        }
        return result
    }

    function policyForWorkflow(workflow) {
        const key = String(workflow || "")
        const policy = root.sourcePolicyDraft[key]
        if (policy)
            return policy
        const fallback = root.defaultSourcePolicy()
        return fallback[key] || ({})
    }

    function updateSourcePolicy(workflow, patch) {
        const key = String(workflow || "")
        const all = root.cloneJson(root.sourcePolicyDraft)
        const current = root.cloneJson(all[key] || root.policyForWorkflow(key))
        const keys = Object.keys(patch || ({}))
        for (let index = 0; index < keys.length; ++index)
            current[keys[index]] = patch[keys[index]]
        if (current.enabled && (!current.allowed_input_modes
                || current.allowed_input_modes.length === 0)) {
            current.allowed_input_modes = root.sourceModeCatalog(key)
            current.default_input_mode = current.allowed_input_modes[0] || ""
        }
        all[key] = current
        root.sourcePolicyDraft = all
        root.draftDirty = true
    }

    function setSourceModeAllowed(workflow, mode, allowed) {
        const policy = root.cloneJson(root.policyForWorkflow(workflow))
        const modes = (policy.allowed_input_modes || []).slice(0)
        const index = modes.indexOf(mode)
        if (allowed && index < 0)
            modes.push(mode)
        else if (!allowed && index >= 0)
            modes.splice(index, 1)
        let defaultMode = String(policy.default_input_mode || "")
        if (modes.indexOf(defaultMode) < 0)
            defaultMode = modes[0] || ""
        root.updateSourcePolicy(workflow, {
            "allowed_input_modes": modes,
            "default_input_mode": defaultMode
        })
    }

    function syncDraft(force) {
        if (root.draftDirty && force !== true)
            return
        const config = root.selectedConfig || ({})
        const brand = config.brand || root.channelKit.brand || ({})
        const entities = config.entities || root.channelKit.entities || ({})
        const delivery = config.deliveryDefaults
            || root.channelKit.delivery_defaults || ({})
        root.draftLanguage = String(brand.language || config.language || "")
        root.draftAudience = String(brand.audience || config.audience || "")
        root.draftPositioning = String(brand.positioning || config.positioning || "")
        root.draftPillars = root.joinLines(brand.content_pillars || [])
        root.draftCharacterIds = root.joinLines(
            entities.character_ids || config.characterIds || [])
        root.draftCharacterId = String(root.splitLines(root.draftCharacterIds)[0] || "")
        root.draftVoiceId = String(entities.voice_id || config.voiceId || config.voice_id || "")
        root.draftStyleId = String(entities.style_id || config.styleId || config.style_id || "")
        root.draftCharacterPolicy = root.assetSource("characters")
        root.draftObjectPolicy = root.assetSource("objects")
        root.draftBackgroundPolicy = root.assetSource("backgrounds")
        root.draftCaptionMode = String(delivery.caption_mode || config.captionMode || "publish_kit")
        root.draftTimezone = String(delivery.timezone || config.timezone || "UTC")
        root.draftIntervalMinutes = Math.max(1, Math.min(43200,
            Number(delivery.interval_minutes || config.intervalMinutes || 1440)))
        root.sourcePolicyDraft = root.policyFromKit()
        root.draftDirty = false
    }

    function selectProfile(index) {
        root.loadedKitKey = ""
        root.channelKit = ({})
        root.kitError = ""
        root.workflowDraftDirty = false
        root.selectedProfileIndex = index
        Qt.callLater(function() {
            root.syncDraft(true)
            root.requestKit(true)
        })
    }

    function buildPolicyScope(source) {
        const normalized = String(source || "ai")
        return {
            "source": normalized,
            "missing": (normalized === "library_only" || normalized === "disabled")
                ? "omit" : "generate",
            "rewrite": normalized === "library_only"
                ? "fit_assets" : "replace_matching"
        }
    }

    function buildAssetPolicy() {
        return {
            "mode": "matrix",
            "scopes": {
                "characters": root.buildPolicyScope(root.draftCharacterPolicy),
                "objects": root.buildPolicyScope(root.draftObjectPolicy),
                "backgrounds": root.buildPolicyScope(root.draftBackgroundPolicy)
            },
            "mapping": "source_role_binding_exact_ids"
        }
    }

    function workflowConfigsForSave() {
        const configs = root.cloneJson(root.selectedConfig.workflowConfigs
            || root.selectedConfig.workflow_configs || ({}))
        const rows = root.channelKit.workflows || []
        for (let index = 0; index < rows.length; ++index) {
            const row = rows[index] || ({})
            const key = String(row.workflow || "")
            if (key)
                configs[key] = root.cloneJson(row.config || ({}))
        }
        return configs
    }

    function saveRevision() {
        const profileId = String(root.selectedProfile.profileId || "")
        if (!profileId)
            return
        const payload = {
            "social_profile_id": profileId,
            "channel_profile_id": root.channelProfileId,
            "platform": String(root.selectedProfile.platform || root.selectedConfig.platform || ""),
            "channel_id": String(root.selectedProfile.channelId || root.selectedConfig.channelId || ""),
            "label": String(root.selectedConfig.label || root.selectedProfile.label || ""),
            "expected_version": root.channelProfileVersion,
            "expected_hash": root.channelProfileHash,
            "brand": {
                "language": root.draftLanguage.trim(),
                "audience": root.draftAudience.trim(),
                "positioning": root.draftPositioning.trim(),
                "content_pillars": root.splitLines(root.draftPillars)
            },
            "entities": {
                "character_ids": root.splitLines(root.draftCharacterIds),
                "voice_id": root.draftVoiceId.trim(),
                "style_id": root.draftStyleId.trim()
            },
            "asset_policy": root.buildAssetPolicy(),
            "source_policy": root.cloneJson(root.sourcePolicyDraft),
            "workflow_configs": root.workflowConfigsForSave(),
            "delivery_defaults": {
                "caption_mode": root.draftCaptionMode,
                "timezone": root.draftTimezone.trim() || "UTC",
                "interval_minutes": root.draftIntervalMinutes
            }
        }
        root.feedbackMessage = ""
        if (root.channelProfileId) {
            root.plane.callTool("tool1.channel_profile.save", payload)
        } else {
            delete payload.expected_version
            delete payload.expected_hash
            delete payload.workflow_configs
            root.plane.callTool("tool1.channel_profile.capture", {
                "social_profile_id": profileId,
                "overrides": payload
            })
        }
    }

    function requestKit(force) {
        const profileId = root.channelProfileId
        if (!profileId) {
            root.channelKit = ({})
            root.loadedKitKey = ""
            root.kitLoading = false
            return
        }
        const key = profileId + ":current"
        if (force !== true && root.loadedKitKey === key)
            return
        if (root.plane.actionBusy) {
            root.kitRequestPending = true
            root.kitLoading = true
            return
        }
        root.kitRequestPending = false
        root.loadedKitKey = key
        root.kitLoading = true
        root.kitError = ""
        root.plane.callTool("tool1.channel_kit.get", {
            "channel_profile_id": profileId
        })
    }

    function kitWorkflow(key) {
        const rows = root.channelKit.workflows || []
        for (let index = 0; index < rows.length; ++index) {
            const row = rows[index] || ({})
            if (String(row.workflow || "") === String(key || ""))
                return row
        }
        const configs = root.selectedConfig.workflowConfigs
            || root.selectedConfig.workflow_configs || ({})
        const config = configs[String(key || "")] || ({})
        return {
            "workflow": String(key || ""),
            "enabled": Boolean(root.policyForWorkflow(key).enabled !== false),
            "ready": Object.keys(config).length > 0,
            "issues": [],
            "source_policy": root.policyForWorkflow(key),
            "config": config,
            "config_hash": "",
            "config_key_count": Object.keys(config).length,
            "fields": []
        }
    }

    function syncWorkflowDraft() {
        const row = root.selectedWorkflow || ({})
        const policy = root.policyForWorkflow(root.selectedWorkflowKey)
        root.workflowDraftSyncing = true
        root.workflowDraftText = JSON.stringify(row.config || ({}), null, 2)
        root.sourceDefaultsDraftText = JSON.stringify(policy.defaults || ({}))
        root.workflowDraftSyncing = false
        root.workflowDraftDirty = false
        root.workflowDraftError = ""
        root.sourceDefaultsError = ""
    }

    function updateSourceDefaults(value) {
        root.sourceDefaultsDraftText = String(value || "")
        let parsed = null
        try {
            parsed = JSON.parse(root.sourceDefaultsDraftText || "{}")
        } catch (error) {
            root.sourceDefaultsError = qsTr("Defaults phải là JSON object hợp lệ.")
            return
        }
        if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
            root.sourceDefaultsError = qsTr("Defaults phải là JSON object hợp lệ.")
            return
        }
        root.sourceDefaultsError = ""
        root.updateSourcePolicy(root.selectedWorkflowKey, {"defaults": parsed})
    }

    function captureSelectedWorkflow() {
        if (!root.channelProfileId || root.plane.actionBusy)
            return
        root.feedbackMessage = ""
        root.plane.callTool("tool1.channel_kit.workflow.capture", {
            "channel_profile_id": root.channelProfileId,
            "workflow": root.selectedWorkflowKey,
            "expected_version": root.channelProfileVersion,
            "expected_hash": root.channelProfileHash
        })
    }

    function saveSelectedWorkflow() {
        if (!root.channelProfileId || root.plane.actionBusy)
            return
        let parsed = null
        try {
            parsed = JSON.parse(root.workflowDraftText)
        } catch (error) {
            root.workflowDraftError = qsTr("JSON không hợp lệ: ") + String(error)
            return
        }
        if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
            root.workflowDraftError = qsTr("Cấu hình workflow phải là một JSON object.")
            return
        }
        root.workflowDraftError = ""
        root.feedbackMessage = ""
        root.plane.callTool("tool1.channel_kit.workflow.save", {
            "channel_profile_id": root.channelProfileId,
            "workflow": root.selectedWorkflowKey,
            "config": parsed,
            "expected_version": root.channelProfileVersion,
            "expected_hash": root.channelProfileHash
        })
    }

    function requestRevisionDiff() {
        const revisions = root.channelKit.revisions || []
        if (revisions.length < 2) {
            root.feedbackOk = false
            root.feedbackMessage = qsTr("Kênh này chưa có revision trước để so sánh.")
            return
        }
        root.revisionDiff = ({})
        root.plane.callTool("tool1.channel_kit.diff", {
            "channel_profile_id": root.channelProfileId,
            "before_version": Number(revisions[1].version || 0),
            "after_version": Number(revisions[0].version || 0)
        })
    }

    function openCloneDialog() {
        root.cloneTargetIndex = -1
        cloneDialog.open()
    }

    function cloneToSelectedTarget() {
        const target = root.profileAt(root.cloneTargetIndex)
        const targetProfileId = String(target.profileId || "")
        if (!targetProfileId || targetProfileId === String(
                root.selectedProfile.profileId || ""))
            return
        const targetConfig = root.resolveConfig(target)
        root.pendingCloneTargetProfileId = targetProfileId
        root.feedbackMessage = ""
        root.plane.callTool("tool1.channel_profile.clone", {
            "source_channel_profile_id": root.channelProfileId,
            "source_version": root.channelProfileVersion,
            "source_hash": root.channelProfileHash,
            "target_social_profile_id": targetProfileId,
            "replace_existing": String(targetConfig.channelProfileId || "").length > 0,
            "expected_target_version": Number(targetConfig.version || 0),
            "expected_target_hash": String(targetConfig.configHash || "")
        })
    }

    function workflowConfigured(key) {
        return Number(root.kitWorkflow(key).config_key_count || 0) > 0
    }

    function workflowReady(key) {
        return Boolean(root.kitWorkflow(key).ready)
    }

    function workflowIssueLabel(key) {
        const row = root.kitWorkflow(key)
        const issues = row.issues || []
        if (row.ready)
            return qsTr("Sẵn sàng")
        if (row.enabled === false)
            return qsTr("Đã tắt")
        if (issues.length > 0)
            return String(issues[0].message || qsTr("Cần cấu hình"))
        return qsTr("Cần cấu hình")
    }

    function backgroundPolicyLabel() {
        return String(root.draftBackgroundPolicy || qsTr("Theo workflow"))
            .replace(/_/g, " ")
    }

    function cadenceLabel() {
        const minutes = Number(root.draftIntervalMinutes || 0)
        if (minutes <= 0)
            return qsTr("Theo lịch")
        if (minutes % 1440 === 0)
            return qsTr("Mỗi %1 ngày").arg(Math.max(1, minutes / 1440))
        if (minutes % 60 === 0)
            return qsTr("Mỗi %1 giờ").arg(Math.max(1, minutes / 60))
        return qsTr("Mỗi %1 phút").arg(minutes)
    }

    onSelectedConfigChanged: Qt.callLater(function() {
        root.syncDraft(false)
        root.requestKit(false)
    })
    onSelectedWorkflowKeyChanged: Qt.callLater(root.syncWorkflowDraft)
    onChannelKitChanged: Qt.callLater(function() {
        root.syncDraft(false)
        root.syncWorkflowDraft()
    })

    Connections {
        target: root.plane.profileModel
        function onModelReset() {
            root.modelRevision++
            if (root.selectedProfileIndex >= Number(root.plane.profileModel.count || 0))
                root.selectedProfileIndex = Math.max(0, Number(root.plane.profileModel.count || 0) - 1)
            Qt.callLater(function() {
                root.syncDraft(false)
                root.requestKit(false)
            })
        }
        function onDataChanged() { root.modelRevision++ }
        function onCountChanged() { root.modelRevision++ }
    }
    Connections {
        target: root.plane.channelProfileModel
        function onModelReset() { root.modelRevision++; Qt.callLater(function() { root.syncDraft(false); root.requestKit(false) }) }
        function onDataChanged() { root.modelRevision++; Qt.callLater(function() { root.syncDraft(false); root.requestKit(false) }) }
        function onCountChanged() { root.modelRevision++; Qt.callLater(function() { root.syncDraft(false); root.requestKit(false) }) }
    }

    Connections {
        target: root.plane
        function onActionBusyChanged() {
            if (!root.plane.actionBusy && root.kitRequestPending)
                Qt.callLater(function() { root.requestKit(true) })
        }
        function onActionFinished(toolName, ok, data, message) {
            const name = String(toolName || "")
            if (name.indexOf("tool1.channel_kit") !== 0
                    && name !== "tool1.channel_profile.save"
                    && name !== "tool1.channel_profile.capture"
                    && name !== "tool1.channel_profile.clone")
                return
            if (name === "tool1.channel_kit.get")
                root.kitLoading = false
            if (!ok) {
                const errorText = String(message || qsTr("Không thể cập nhật bộ cấu hình kênh."))
                if (name === "tool1.channel_kit.get"
                        && errorText.indexOf("đang được xử lý") >= 0) {
                    root.kitRequestPending = true
                    root.loadedKitKey = ""
                    root.kitLoading = true
                    return
                }
                root.feedbackOk = false
                root.feedbackMessage = errorText
                if (name === "tool1.channel_profile.clone")
                    root.pendingCloneTargetProfileId = ""
                if (name === "tool1.channel_kit.get")
                    root.kitError = errorText
                if (errorText.indexOf("stale") >= 0
                        || errorText.indexOf("changed") >= 0)
                    root.loadedKitKey = ""
                return
            }
            const kit = (data || {}).channel_development_kit_result || ({})
            if (String(kit.channel_profile_id || "")
                    && String(kit.channel_profile_id) === root.channelProfileId) {
                root.channelKit = root.cloneJson(kit)
                root.loadedKitKey = root.channelProfileId + ":current"
                root.kitError = ""
            }
            if (name === "tool1.channel_kit.diff") {
                root.revisionDiff = root.cloneJson(
                    (data || {}).channel_profile_diff_result || ({}))
                revisionDialog.open()
                return
            }
            if (name !== "tool1.channel_kit.get") {
                root.feedbackOk = true
                root.feedbackMessage = name === "tool1.channel_profile.clone"
                    ? qsTr("Đã nhân bản bộ phát triển và rebind sang đúng kênh đích.")
                    : name.indexOf("workflow") >= 0
                    ? qsTr("Đã lưu revision mới cho đúng workflow; bốn workflow còn lại được giữ nguyên.")
                    : qsTr("Đã lưu revision bất biến mới cho kênh.")
                root.draftDirty = false
                root.workflowDraftDirty = false
                Qt.callLater(function() {
                    root.syncDraft(true)
                    root.syncWorkflowDraft()
                })
                if (name === "tool1.channel_profile.clone") {
                    cloneDialog.close()
                    const targetProfileId = root.pendingCloneTargetProfileId
                    root.pendingCloneTargetProfileId = ""
                    Qt.callLater(function() {
                        root.selectProfileById(targetProfileId)
                    })
                }
            } else {
                root.feedbackMessage = ""
            }
        }
    }

    Component.onCompleted: Qt.callLater(function() {
        root.syncDraft(true)
        root.requestKit(true)
    })

    component SectionTitle: Text {
        color: CenterTokens.text
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.sectionTitle
        font.weight: Font.DemiBold
    }

    component MetaText: Text {
        color: CenterTokens.muted
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.metadata + 1
        elide: Text.ElideRight
    }

    component ConfigField: Rectangle {
        id: fieldRoot
        required property string label
        property string value: ""
        property string placeholderText: ""
        property bool readOnly: false
        signal edited(string value)
        Layout.fillWidth: true
        implicitHeight: 40
        radius: CenterTokens.radiusSmall
        color: CenterTokens.panelSoft
        border.width: 1
        border.color: editor.activeFocus ? CenterTokens.primary : CenterTokens.border
        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 5
            anchors.bottomMargin: 4
            spacing: 1
            Text {
                text: fieldRoot.label
                color: CenterTokens.muted
                font.family: CenterTokens.fontFamily
                font.pixelSize: CenterTokens.metadata
            }
            TextField {
                id: editor
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: fieldRoot.value
                readOnly: fieldRoot.readOnly
                placeholderText: fieldRoot.placeholderText
                color: CenterTokens.text
                placeholderTextColor: CenterTokens.faint
                font.family: CenterTokens.fontFamily
                font.pixelSize: CenterTokens.body
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0
                selectByMouse: true
                background: Item {}
                onTextEdited: fieldRoot.edited(text)
                onTextChanged: {
                    if (!activeFocus)
                        Qt.callLater(function() { editor.cursorPosition = 0 })
                }
                onActiveFocusChanged: {
                    if (!activeFocus)
                        cursorPosition = 0
                }
                Component.onCompleted: cursorPosition = 0
            }
        }
    }

    component PolicyPicker: ColumnLayout {
        id: policyPicker
        required property string label
        property string value: "ai"
        signal selected(string value)
        Layout.fillWidth: true
        spacing: 3
        MetaText { text: policyPicker.label }
        StyledCombo {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            model: ["ai", "hybrid", "library_only", "disabled"]
            currentIndex: Math.max(0, model.indexOf(policyPicker.value))
            font.family: CenterTokens.fontFamily
            font.pixelSize: CenterTokens.metadata + 1
            onActivated: policyPicker.selected(String(currentValue || "ai"))
        }
    }

    component StyledCombo: ComboBox {
        id: combo
        leftPadding: 10
        rightPadding: 28
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.metadata + 1
        contentItem: Text {
            leftPadding: 0
            rightPadding: 0
            text: combo.displayText
            color: CenterTokens.text
            font: combo.font
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        indicator: Text {
            x: combo.width - width - 9
            y: (combo.height - height) / 2 - 1
            text: "⌄"
            color: CenterTokens.muted
            font.family: CenterTokens.fontFamily
            font.pixelSize: CenterTokens.body
        }
        background: Rectangle {
            radius: CenterTokens.radiusSmall
            color: CenterTokens.panel
            border.width: 1
            border.color: combo.activeFocus ? CenterTokens.primary : CenterTokens.border
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: CenterTokens.pageGutter
        anchors.rightMargin: CenterTokens.pageGutter
        anchors.topMargin: 14
        anchors.bottomMargin: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            spacing: 12
            ColumnLayout {
                spacing: 3
                Text {
                    text: qsTr("Kênh & cấu hình")
                    color: CenterTokens.text
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.pageTitle
                    font.weight: Font.Bold
                }
                Text {
                    text: qsTr("Đóng băng thương hiệu, tài nguyên và cấu hình sản xuất riêng cho từng kênh.")
                    color: CenterTokens.muted
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.body
                }
            }
            Item { Layout.fillWidth: true }
            CenterSearchField {
                Layout.preferredWidth: 225
                placeholderText: qsTr("Tìm kênh...")
                onQueryCommitted: query => root.query = query.toLowerCase()
            }
            AppButton {
                text: qsTr("Nhân bản cấu hình")
                leadingIcon: "ui/copy"
                enabled: root.channelProfileId.length > 0
                    && Number(root.plane.profileModel.count || 0) > 1
                    && !root.plane.actionBusy
                onClicked: root.openCloneDialog()
            }
            AppButton {
                text: qsTr("Thêm kênh")
                leadingIcon: "ui/plus"
                primary: true
                onClicked: root.navigateRequested("profiles")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: CenterTokens.gap

            CenterPanel {
                Layout.preferredWidth: Math.max(300, root.width * 0.215)
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: CenterTokens.panelPadding
                    spacing: 9
                    SectionTitle { text: qsTr("Danh sách kênh") }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Repeater {
                            model: [qsTr("Tất cả"), "YouTube", "TikTok", "Facebook"]
                            delegate: Rectangle {
                                id: filterChip
                                required property int index
                                required property string modelData
                                implicitWidth: filterLabel.implicitWidth + 18
                                implicitHeight: 28
                                radius: 14
                                color: filterChip.index === 0 ? CenterTokens.primarySoft : CenterTokens.panel
                                border.width: 1
                                border.color: filterChip.index === 0 ? CenterTokens.primary : CenterTokens.border
                                Text {
                                    id: filterLabel
                                    anchors.centerIn: parent
                                    text: filterChip.modelData
                                    color: filterChip.index === 0 ? CenterTokens.primary : CenterTokens.muted
                                    font.family: CenterTokens.fontFamily
                                    font.pixelSize: CenterTokens.metadata + 1
                                    font.weight: filterChip.index === 0 ? Font.DemiBold : Font.Normal
                                }
                            }
                        }
                    }
                    ListView {
                        id: channelList
                        objectName: "channelConfigurationList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: root.plane.profileModel
                        readonly property int cardGap: 8
                        spacing: 0
                        clip: true
                        reuseItems: true
                        boundsBehavior: Flickable.StopAtBounds
                        delegate: Item {
                            id: channelRow
                            required property int index
                            required property var modelData
                            readonly property bool matches: !root.query
                                || String(modelData.label || "").toLowerCase().indexOf(root.query) >= 0
                                || String(modelData.accountHandle || "").toLowerCase().indexOf(root.query) >= 0
                            width: ListView.view.width
                            height: matches ? channelCard.height + channelList.cardGap : 0
                            visible: matches
                            Rectangle {
                                id: channelCard
                                width: parent.width
                                height: 78
                                radius: CenterTokens.radius
                                color: root.selectedProfileIndex === channelRow.index
                                    ? CenterTokens.primarySoft : CenterTokens.panel
                                border.width: 1
                                border.color: root.selectedProfileIndex === channelRow.index
                                    ? CenterTokens.primary : CenterTokens.border

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10
                                    PlatformIcon {
                                        platform: String(channelRow.modelData.platform || "generic")
                                        iconSize: 24
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            Layout.fillWidth: true
                                            text: String(channelRow.modelData.label || qsTr("Kênh chưa đặt tên"))
                                            color: CenterTokens.text
                                            font.family: CenterTokens.fontFamily
                                            font.pixelSize: CenterTokens.body
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }
                                        MetaText {
                                            Layout.fillWidth: true
                                            text: String(channelRow.modelData.accountHandle
                                                ? "@" + channelRow.modelData.accountHandle
                                                : channelRow.modelData.channelId || "—")
                                        }
                                        CenterStatusBadge {
                                            text: Fmt.statusLabel(channelRow.modelData.authState,
                                                channelRow.modelData.statusLabel)
                                            status: Fmt.statusKind(channelRow.modelData.authState)
                                            iconName: channelRow.modelData.authState === "verified"
                                                ? "semantic/check-circle" : "semantic/alert-triangle"
                                        }
                                    }
                                    CenterStatusBadge {
                                        text: "v" + String(Math.max(1,
                                            Number(channelRow.modelData.channelProfileVersion || 1)))
                                        status: "info"
                                    }
                                }
                                TapHandler { onTapped: root.selectProfile(channelRow.index) }
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: channelList.count === 0
                            width: parent.width - 30
                            text: qsTr("Chưa có hồ sơ kênh. Tạo hồ sơ đăng trước rồi capture cấu hình sản xuất.")
                            color: CenterTokens.faint
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                        }
                    }
                    AppButton {
                        Layout.fillWidth: true
                        text: qsTr("Quản lý kênh & hồ sơ")
                        leadingIcon: "navigation/users"
                        subtle: true
                        onClicked: root.navigateRequested("profiles")
                    }
                }
            }

            CenterPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: CenterTokens.panelPadding
                    spacing: 9

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24
                        Layout.maximumHeight: 24
                        SectionTitle {
                            Layout.fillWidth: true
                            text: String(root.selectedProfile.label || qsTr("Chọn một kênh"))
                                + qsTr(" · Cấu hình v")
                                + String(Math.max(1, Number(root.selectedConfig.version
                                    || root.selectedProfile.channelProfileVersion || 1)))
                        }
                        CenterStatusBadge {
                            text: root.draftDirty ? qsTr("Chưa lưu") : qsTr("Đã đóng băng")
                            status: root.draftDirty ? "warning" : "success"
                            iconName: root.draftDirty ? "ui/pencil" : "semantic/shield-check"
                        }
                        CenterStatusBadge {
                            visible: root.kitLoading
                            text: qsTr("Đang đọc cấu hình hiệu lực")
                            status: "info"
                            iconName: "ui/refresh-cw"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 31
                        Layout.maximumHeight: 31
                        spacing: 4
                        Repeater {
                            model: [
                                {"key": "overview", "label": qsTr("Tổng quan")},
                                {"key": "brand", "label": qsTr("Thương hiệu")},
                                {"key": "resources", "label": qsTr("Tài nguyên")},
                                {"key": "workflow", "label": qsTr("Workflow")},
                                {"key": "distribution", "label": qsTr("Phân phối")}
                            ]
                            delegate: Button {
                                id: editorTab
                                required property var modelData
                                Layout.preferredWidth: 92
                                Layout.fillHeight: true
                                text: String(editorTab.modelData.label)
                                flat: true
                                onClicked: root.activeEditorTab = String(editorTab.modelData.key)
                                contentItem: Text {
                                    text: editorTab.text
                                    color: root.activeEditorTab === String(editorTab.modelData.key)
                                        ? CenterTokens.primary : CenterTokens.muted
                                    font.family: CenterTokens.fontFamily
                                    font.pixelSize: CenterTokens.metadata + 1
                                    font.weight: root.activeEditorTab === String(editorTab.modelData.key)
                                        ? Font.DemiBold : Font.Normal
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Item {
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        height: 2
                                        color: root.activeEditorTab === String(editorTab.modelData.key)
                                            ? CenterTokens.primary : "transparent"
                                    }
                                }
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }

                    CenterPanel {
                        visible: root.activeEditorTab === "overview" || root.activeEditorTab === "brand"
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.activeEditorTab === "overview" ? 108 : 0
                        Layout.maximumHeight: root.activeEditorTab === "overview" ? 108 : 100000
                        Layout.fillHeight: root.activeEditorTab === "brand"
                        elevated: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 11
                            spacing: 8
                            RowLayout {
                                Layout.fillWidth: true
                                SectionTitle { text: qsTr("Định vị kênh") }
                                Item { Layout.fillWidth: true }
                                CenterStatusBadge {
                                    visible: root.activeEditorTab === "brand"
                                    text: qsTr("Áp dụng cho mọi job của kênh")
                                    status: "info"
                                    iconName: "semantic/shield-check"
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                ConfigField {
                                    label: qsTr("Ngôn ngữ")
                                    value: root.draftLanguage
                                    placeholderText: qsTr("Ví dụ: English")
                                    onEdited: value => { root.draftLanguage = value; root.draftDirty = true }
                                }
                                ConfigField {
                                    label: qsTr("Đối tượng")
                                    value: root.draftAudience
                                    placeholderText: qsTr("Khán giả mục tiêu")
                                    onEdited: value => { root.draftAudience = value; root.draftDirty = true }
                                }
                                ConfigField {
                                    label: qsTr("Định vị")
                                    value: root.draftPositioning
                                    placeholderText: qsTr("Lời hứa của kênh")
                                    onEdited: value => { root.draftPositioning = value; root.draftDirty = true }
                                }
                            }
                            RowLayout {
                                visible: root.activeEditorTab === "overview"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20
                                spacing: 6
                                MetaText { text: qsTr("Trụ cột nội dung") }
                                Repeater {
                                    model: root.splitLines(root.draftPillars)
                                    delegate: CenterStatusBadge {
                                        required property var modelData
                                        text: String(modelData)
                                        status: "neutral"
                                    }
                                }
                                Item { Layout.fillWidth: true }
                            }
                            ConfigField {
                                visible: root.activeEditorTab === "brand"
                                Layout.fillWidth: true
                                label: qsTr("Trụ cột nội dung · ngăn cách bằng dấu phẩy")
                                value: root.draftPillars.replace(/\n/g, ", ")
                                placeholderText: qsTr("AI Tools, Tutorials, News & Updates")
                                onEdited: value => {
                                    root.draftPillars = value
                                    root.draftDirty = true
                                }
                            }
                            Text {
                                visible: root.activeEditorTab === "brand"
                                Layout.fillWidth: true
                                text: qsTr("AI Studio dùng ngôn ngữ, đối tượng, định vị và trụ cột này khi lên kế hoạch; Assignment V2 đóng băng chúng theo revision.")
                                color: CenterTokens.muted
                                font.family: CenterTokens.fontFamily
                                font.pixelSize: CenterTokens.metadata + 1
                                wrapMode: Text.Wrap
                            }
                            Item { visible: root.activeEditorTab === "brand"; Layout.fillHeight: true }
                        }
                    }

                    CenterPanel {
                        visible: root.activeEditorTab === "overview" || root.activeEditorTab === "resources"
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.activeEditorTab === "overview" ? 80 : 0
                        Layout.maximumHeight: root.activeEditorTab === "overview" ? 80 : 100000
                        Layout.fillHeight: root.activeEditorTab === "resources"
                        elevated: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 11
                            spacing: 8
                            SectionTitle { text: qsTr("Tài nguyên mặc định") }
                            RowLayout {
                                visible: root.activeEditorTab === "overview"
                                Layout.fillWidth: true
                                spacing: 6
                                ConfigField {
                                    label: qsTr("Character")
                                    value: root.draftCharacterId
                                    placeholderText: qsTr("Nhân vật mặc định")
                                    onEdited: value => {
                                        root.draftCharacterId = value
                                        root.draftCharacterIds = value
                                        root.draftDirty = true
                                    }
                                }
                                ConfigField {
                                    label: qsTr("Voice")
                                    value: root.draftVoiceId
                                    placeholderText: qsTr("Giọng dùng chung")
                                    onEdited: value => { root.draftVoiceId = value; root.draftDirty = true }
                                }
                                ConfigField {
                                    label: qsTr("Style")
                                    value: root.draftStyleId
                                    placeholderText: qsTr("Style dùng chung")
                                    onEdited: value => { root.draftStyleId = value; root.draftDirty = true }
                                }
                                ConfigField {
                                    label: qsTr("Background")
                                    value: root.backgroundPolicyLabel()
                                    readOnly: true
                                }
                                ConfigField {
                                    label: qsTr("Subtitle")
                                    value: root.draftCaptionMode
                                    readOnly: true
                                }
                            }
                            ColumnLayout {
                                visible: root.activeEditorTab === "resources"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 10
                                ConfigField {
                                    Layout.fillWidth: true
                                    label: qsTr("Character IDs · có thể gán nhiều nhân vật")
                                    value: root.draftCharacterIds.replace(/\n/g, ", ")
                                    placeholderText: qsTr("host-alex-v2, guest-maya-v1")
                                    onEdited: value => {
                                        root.draftCharacterIds = value
                                        root.draftCharacterId = String(root.splitLines(value)[0] || "")
                                        root.draftDirty = true
                                    }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    ConfigField {
                                        label: qsTr("Voice ID")
                                        value: root.draftVoiceId
                                        placeholderText: qsTr("Giọng mặc định cho kênh")
                                        onEdited: value => { root.draftVoiceId = value; root.draftDirty = true }
                                    }
                                    ConfigField {
                                        label: qsTr("Style ID")
                                        value: root.draftStyleId
                                        placeholderText: qsTr("Style hình ảnh mặc định")
                                        onEdited: value => { root.draftStyleId = value; root.draftDirty = true }
                                    }
                                }
                                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: CenterTokens.border }
                                SectionTitle { text: qsTr("Chính sách tài nguyên shared") }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    PolicyPicker {
                                        label: qsTr("Nhân vật")
                                        value: root.draftCharacterPolicy
                                        onSelected: value => {
                                            root.draftCharacterPolicy = value
                                            root.draftDirty = true
                                        }
                                    }
                                    PolicyPicker {
                                        label: qsTr("Đồ vật")
                                        value: root.draftObjectPolicy
                                        onSelected: value => {
                                            root.draftObjectPolicy = value
                                            root.draftDirty = true
                                        }
                                    }
                                    PolicyPicker {
                                        label: qsTr("Bối cảnh")
                                        value: root.draftBackgroundPolicy
                                        onSelected: value => {
                                            root.draftBackgroundPolicy = value
                                            root.draftDirty = true
                                        }
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: qsTr("Library only và Disabled fail/omit theo shared consistency contract; adapter không tự sinh lại tài nguyên đã khóa.")
                                    color: CenterTokens.muted
                                    font.family: CenterTokens.fontFamily
                                    font.pixelSize: CenterTokens.metadata + 1
                                    wrapMode: Text.Wrap
                                }
                                Item { Layout.fillHeight: true }
                            }
                        }
                    }

                    CenterPanel {
                        visible: root.activeEditorTab === "overview" || root.activeEditorTab === "workflow"
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.activeEditorTab === "overview" ? 180 : 0
                        Layout.maximumHeight: root.activeEditorTab === "overview" ? 180 : 100000
                        Layout.fillHeight: root.activeEditorTab === "workflow"
                        elevated: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 5
                            RowLayout {
                                Layout.fillWidth: true
                                SectionTitle { text: qsTr("Cấu hình workflow") }
                                Item { Layout.fillWidth: true }
                                CenterStatusBadge {
                                    visible: root.activeEditorTab === "workflow"
                                    text: qsTr("%1/%2 sẵn sàng").arg(
                                        Number(root.channelKit.ready_workflow_count || 0)).arg(
                                        Number(root.channelKit.enabled_workflow_count || 5))
                                    status: Boolean(root.channelKit.all_enabled_ready) ? "success" : "warning"
                                    iconName: Boolean(root.channelKit.all_enabled_ready)
                                        ? "semantic/check-circle" : "semantic/alert-triangle"
                                }
                            }
                            RowLayout {
                                visible: root.activeEditorTab === "overview"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 18
                                spacing: 8
                                MetaText { Layout.minimumWidth: 150; Layout.preferredWidth: 150; Layout.maximumWidth: 150; text: qsTr("Workflow") }
                                MetaText { Layout.fillWidth: true; text: qsTr("Cấu hình phiên bản") }
                                MetaText { Layout.minimumWidth: 105; Layout.preferredWidth: 105; Layout.maximumWidth: 105; text: qsTr("Trạng thái sẵn sàng") }
                            }
                            Repeater {
                                model: root.workflowRows
                                delegate: RowLayout {
                                    id: workflowRow
                                    required property var modelData
                                    Layout.fillWidth: true
                                    visible: root.activeEditorTab === "overview"
                                    Layout.preferredHeight: visible ? 24 : 0
                                    spacing: 8
                                    CenterStatusBadge {
                                        Layout.minimumWidth: 150
                                        Layout.preferredWidth: 150
                                        Layout.maximumWidth: 150
                                        text: String(workflowRow.modelData.label)
                                        status: Fmt.workflowTone(workflowRow.modelData.key)
                                    }
                                    MetaText {
                                        Layout.fillWidth: true
                                        text: root.workflowConfigured(workflowRow.modelData.key)
                                            ? "v" + String(Math.max(1, root.channelProfileVersion))
                                            : qsTr("Chưa có")
                                    }
                                    CenterStatusBadge {
                                        Layout.minimumWidth: 105
                                        Layout.preferredWidth: 105
                                        Layout.maximumWidth: 105
                                        text: root.workflowIssueLabel(workflowRow.modelData.key)
                                        status: root.workflowReady(workflowRow.modelData.key)
                                            ? "success" : root.kitWorkflow(workflowRow.modelData.key).enabled === false
                                            ? "neutral" : "warning"
                                        iconName: root.workflowReady(workflowRow.modelData.key)
                                            ? "semantic/check-circle" : "semantic/alert-triangle"
                                    }
                                }
                            }
                            RowLayout {
                                visible: root.activeEditorTab === "workflow"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 8
                                Rectangle {
                                    Layout.preferredWidth: 180
                                    Layout.fillHeight: true
                                    radius: CenterTokens.radiusSmall
                                    color: CenterTokens.panelSoft
                                    border.width: 1
                                    border.color: CenterTokens.border
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 7
                                        spacing: 5
                                        MetaText { text: qsTr("5 adapter native") }
                                        Repeater {
                                            model: root.workflowRows
                                            delegate: Rectangle {
                                                id: workflowPicker
                                                required property var modelData
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 48
                                                radius: CenterTokens.radiusSmall
                                                color: root.selectedWorkflowKey === String(workflowPicker.modelData.key)
                                                    ? CenterTokens.primarySoft : CenterTokens.panel
                                                border.width: 1
                                                border.color: root.selectedWorkflowKey === String(workflowPicker.modelData.key)
                                                    ? CenterTokens.primary : CenterTokens.border
                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 7
                                                    spacing: 2
                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: String(workflowPicker.modelData.label)
                                                        color: CenterTokens.text
                                                        font.family: CenterTokens.fontFamily
                                                        font.pixelSize: CenterTokens.metadata + 1
                                                        font.weight: Font.DemiBold
                                                        elide: Text.ElideRight
                                                    }
                                                    RowLayout {
                                                        Layout.fillWidth: true
                                                        MetaText {
                                                            Layout.fillWidth: true
                                                            text: qsTr("%1 key").arg(Number(
                                                                root.kitWorkflow(workflowPicker.modelData.key).config_key_count || 0))
                                                        }
                                                        CenterStatusBadge {
                                                            text: root.workflowReady(workflowPicker.modelData.key)
                                                                ? qsTr("Ready") : qsTr("Setup")
                                                            status: root.workflowReady(workflowPicker.modelData.key)
                                                                ? "success" : "warning"
                                                        }
                                                    }
                                                }
                                                TapHandler {
                                                    onTapped: root.selectedWorkflowKey = String(workflowPicker.modelData.key)
                                                }
                                            }
                                        }
                                        Item { Layout.fillHeight: true }
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            Layout.fillWidth: true
                                            text: String(root.selectedWorkflowKey || "").toUpperCase()
                                                + qsTr(" · snapshot v") + String(Math.max(1, root.channelProfileVersion))
                                            color: CenterTokens.text
                                            font.family: CenterTokens.fontFamily
                                            font.pixelSize: CenterTokens.body
                                            font.weight: Font.DemiBold
                                        }
                                        CenterStatusBadge {
                                            text: qsTr("%1 key").arg(Number(
                                                root.selectedWorkflow.config_key_count || 0))
                                            status: "info"
                                            iconName: "ui/settings"
                                        }
                                        AppButton {
                                            Layout.preferredHeight: 30
                                            text: qsTr("Mở tab")
                                            leadingIcon: "ui/external-link"
                                            onClicked: root.openWorkflowRequested(root.selectedWorkflowKey)
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 108
                                        radius: CenterTokens.radiusSmall
                                        color: CenterTokens.panelSoft
                                        border.width: 1
                                        border.color: root.sourceDefaultsError
                                            ? CenterTokens.danger : CenterTokens.border
                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 5
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 10
                                                ColumnLayout {
                                                    Layout.preferredWidth: 100
                                                    MetaText { text: qsTr("Nguồn được phép") }
                                                    Switch {
                                                        text: root.policyForWorkflow(root.selectedWorkflowKey).enabled
                                                            ? qsTr("Đang bật") : qsTr("Đã tắt")
                                                        checked: Boolean(root.policyForWorkflow(
                                                            root.selectedWorkflowKey).enabled)
                                                        onClicked: root.updateSourcePolicy(
                                                            root.selectedWorkflowKey, {"enabled": checked})
                                                    }
                                                }
                                                Repeater {
                                                    model: root.sourceModeCatalog(root.selectedWorkflowKey)
                                                    delegate: CheckBox {
                                                        id: sourceModeCheck
                                                        required property string modelData
                                                        text: String(sourceModeCheck.modelData).replace(/_/g, " ")
                                                        checked: (root.policyForWorkflow(
                                                            root.selectedWorkflowKey).allowed_input_modes || [])
                                                            .indexOf(sourceModeCheck.modelData) >= 0
                                                        onClicked: root.setSourceModeAllowed(
                                                            root.selectedWorkflowKey,
                                                            sourceModeCheck.modelData,
                                                            checked)
                                                    }
                                                }
                                                Item { Layout.fillWidth: true }
                                                ColumnLayout {
                                                    Layout.preferredWidth: 130
                                                    MetaText { text: qsTr("Mặc định") }
                                                    StyledCombo {
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: 32
                                                        model: root.policyForWorkflow(
                                                            root.selectedWorkflowKey).allowed_input_modes || []
                                                        currentIndex: Math.max(0, model.indexOf(String(
                                                            root.policyForWorkflow(root.selectedWorkflowKey)
                                                                .default_input_mode || "")))
                                                        onActivated: root.updateSourcePolicy(
                                                            root.selectedWorkflowKey,
                                                            {"default_input_mode": String(currentValue || "")})
                                                    }
                                                }
                                            }
                                            ConfigField {
                                                Layout.fillWidth: true
                                                label: root.sourceDefaultsError.length > 0
                                                    ? root.sourceDefaultsError
                                                    : qsTr("Input defaults JSON · merge vào options trước khi hash Assignment")
                                                value: root.sourceDefaultsDraftText
                                                placeholderText: "{}"
                                                onEdited: value => root.updateSourceDefaults(value)
                                            }
                                        }
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: 7
                                        Rectangle {
                                            Layout.preferredWidth: Math.max(220, parent.width * 0.38)
                                            Layout.fillHeight: true
                                            radius: CenterTokens.radiusSmall
                                            color: CenterTokens.panelSoft
                                            border.width: 1
                                            border.color: CenterTokens.border
                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 7
                                                spacing: 4
                                                MetaText { text: qsTr("Toàn bộ trường hiệu lực từ UI tab") }
                                                ListView {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    clip: true
                                                    reuseItems: true
                                                    boundsBehavior: Flickable.StopAtBounds
                                                    model: root.selectedWorkflow.fields || []
                                                    spacing: 3
                                                    delegate: Rectangle {
                                                        id: configFieldRow
                                                        required property var modelData
                                                        width: ListView.view.width
                                                        height: 42
                                                        radius: CenterTokens.radiusSmall
                                                        color: CenterTokens.panel
                                                        border.width: 1
                                                        border.color: CenterTokens.border
                                                        ColumnLayout {
                                                            anchors.fill: parent
                                                            anchors.margins: 5
                                                            spacing: 1
                                                            RowLayout {
                                                                Layout.fillWidth: true
                                                                Text {
                                                                    Layout.fillWidth: true
                                                                    text: String(configFieldRow.modelData.key || "")
                                                                    color: CenterTokens.text
                                                                    font.family: CenterTokens.fontFamily
                                                                    font.pixelSize: CenterTokens.metadata
                                                                    font.weight: Font.DemiBold
                                                                    elide: Text.ElideRight
                                                                }
                                                                MetaText { text: String(configFieldRow.modelData.group || "advanced") }
                                                            }
                                                            MetaText {
                                                                Layout.fillWidth: true
                                                                text: root.compactValue(configFieldRow.modelData.value)
                                                            }
                                                        }
                                                    }
                                                    Text {
                                                        anchors.centerIn: parent
                                                        visible: parent.count === 0
                                                        width: parent.width - 18
                                                        text: qsTr("Chưa có snapshot. Mở tab để cấu hình rồi bấm Capture.")
                                                        color: CenterTokens.faint
                                                        font.family: CenterTokens.fontFamily
                                                        font.pixelSize: CenterTokens.metadata + 1
                                                        horizontalAlignment: Text.AlignHCenter
                                                        wrapMode: Text.Wrap
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            radius: CenterTokens.radiusSmall
                                            color: CenterTokens.panelSoft
                                            border.width: 1
                                            border.color: root.workflowDraftError
                                                ? CenterTokens.danger : CenterTokens.border
                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 7
                                                spacing: 4
                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    MetaText { Layout.fillWidth: true; text: qsTr("JSON nâng cao · lưu thành revision mới") }
                                                    CenterStatusBadge {
                                                        visible: root.workflowDraftDirty
                                                        text: qsTr("Đã sửa")
                                                        status: "warning"
                                                    }
                                                }
                                                ScrollView {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    clip: true
                                                    contentWidth: availableWidth
                                                    TextArea {
                                                        id: workflowJsonEditor
                                                        width: parent.availableWidth
                                                        text: root.workflowDraftText
                                                        wrapMode: TextArea.NoWrap
                                                        selectByMouse: true
                                                        color: CenterTokens.text
                                                        selectionColor: CenterTokens.primary
                                                        selectedTextColor: "white"
                                                        font.family: "Consolas"
                                                        font.pixelSize: CenterTokens.metadata
                                                        background: Item {}
                                                        onTextChanged: {
                                                            if (!root.workflowDraftSyncing && activeFocus) {
                                                                root.workflowDraftText = text
                                                                root.workflowDraftDirty = true
                                                                root.workflowDraftError = ""
                                                            }
                                                        }
                                                    }
                                                }
                                                Text {
                                                    visible: root.workflowDraftError.length > 0
                                                    Layout.fillWidth: true
                                                    text: root.workflowDraftError
                                                    color: CenterTokens.danger
                                                    font.family: CenterTokens.fontFamily
                                                    font.pixelSize: CenterTokens.metadata
                                                    wrapMode: Text.Wrap
                                                }
                                            }
                                        }
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 7
                                        Text {
                                            Layout.fillWidth: true
                                            text: root.workflowIssueLabel(root.selectedWorkflowKey)
                                            color: root.workflowReady(root.selectedWorkflowKey)
                                                ? CenterTokens.success : CenterTokens.muted
                                            font.family: CenterTokens.fontFamily
                                            font.pixelSize: CenterTokens.metadata + 1
                                            elide: Text.ElideRight
                                        }
                                        AppButton {
                                            text: qsTr("Capture từ tab hiện tại")
                                            leadingIcon: "ui/download"
                                            enabled: root.channelProfileId.length > 0 && !root.plane.actionBusy
                                            onClicked: root.captureSelectedWorkflow()
                                        }
                                        AppButton {
                                            text: qsTr("Lưu JSON")
                                            leadingIcon: "ui/save"
                                            primary: true
                                            enabled: root.workflowDraftDirty
                                                && root.channelProfileId.length > 0
                                                && !root.plane.actionBusy
                                            onClicked: root.saveSelectedWorkflow()
                                        }
                                    }
                                }
                            }
                            Item { visible: root.activeEditorTab === "overview"; Layout.fillHeight: true }
                        }
                    }

                    CenterPanel {
                        visible: root.activeEditorTab === "overview" || root.activeEditorTab === "distribution"
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.activeEditorTab === "overview" ? 64 : 0
                        Layout.maximumHeight: root.activeEditorTab === "overview" ? 64 : 100000
                        Layout.fillHeight: root.activeEditorTab === "distribution"
                        elevated: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 3
                            SectionTitle { text: qsTr("Quy tắc sản xuất & phân phối") }
                            RowLayout {
                                visible: root.activeEditorTab === "overview"
                                Layout.fillWidth: true
                                spacing: 18
                                Repeater {
                                    model: [
                                        {"label": qsTr("Phụ đề"), "value": root.draftCaptionMode},
                                        {"label": qsTr("Nhịp đăng"), "value": root.cadenceLabel()},
                                        {"label": qsTr("Múi giờ"), "value": root.draftTimezone},
                                        {"label": qsTr("Bộ xuất bản"), "value": "PublishKit"}
                                    ]
                                    delegate: ColumnLayout {
                                        id: ruleCell
                                        required property var modelData
                                        Layout.fillWidth: true
                                        spacing: 1
                                        MetaText { text: String(ruleCell.modelData.label) }
                                        Text {
                                            Layout.fillWidth: true
                                            text: String(ruleCell.modelData.value)
                                            color: CenterTokens.text
                                            font.family: CenterTokens.fontFamily
                                            font.pixelSize: CenterTokens.metadata + 1
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                            ColumnLayout {
                                visible: root.activeEditorTab === "distribution"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 12
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    columnSpacing: 10
                                    rowSpacing: 10
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 300
                                        MetaText { text: qsTr("Chế độ caption") }
                                        StyledCombo {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 36
                                            model: ["publish_kit", "manual"]
                                            currentIndex: Math.max(0, model.indexOf(root.draftCaptionMode))
                                            onActivated: {
                                                root.draftCaptionMode = String(currentValue || "publish_kit")
                                                root.draftDirty = true
                                            }
                                        }
                                    }
                                    ConfigField {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 300
                                        label: qsTr("Múi giờ IANA")
                                        value: root.draftTimezone
                                        placeholderText: "Asia/Bangkok"
                                        onEdited: value => { root.draftTimezone = value; root.draftDirty = true }
                                    }
                                    ConfigField {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 300
                                        label: qsTr("Khoảng cách đăng · phút")
                                        value: String(root.draftIntervalMinutes)
                                        placeholderText: "1440"
                                        onEdited: value => {
                                            const parsed = Number(value)
                                            if (Number.isFinite(parsed)) {
                                                root.draftIntervalMinutes = Math.max(
                                                    1, Math.min(43200, Math.round(parsed)))
                                                root.draftDirty = true
                                            }
                                        }
                                    }
                                    ConfigField {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 300
                                        label: qsTr("Publish executor")
                                        value: "PublishKit · browser profile đã bind"
                                        readOnly: true
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: qsTr("Lịch đăng và caption là mặc định của kênh. Work order có thể đề xuất override, nhưng chỉ được compile sau khi operator duyệt và vẫn giữ đúng profile/binding revision.")
                                    color: CenterTokens.muted
                                    font.family: CenterTokens.fontFamily
                                    font.pixelSize: CenterTokens.metadata + 1
                                    wrapMode: Text.Wrap
                                }
                                Item { Layout.fillHeight: true }
                            }
                        }
                    }
                    Item {
                        visible: root.activeEditorTab === "overview"
                        Layout.fillHeight: true
                    }
                }
            }

            CenterPanel {
                Layout.preferredWidth: Math.max(300, root.width * 0.225)
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.compactLayout || root.shortLayout
                        ? 10 : CenterTokens.panelPadding
                    spacing: root.compactLayout || root.shortLayout ? 5 : 10
                    SectionTitle { text: qsTr("Liên kết vận hành") }
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: root.compactLayout || root.shortLayout ? 4 : 9
                        MetaText { text: qsTr("Nền tảng") }
                        RowLayout {
                            PlatformIcon {
                                platform: String(root.selectedProfile.platform || "generic")
                                iconSize: 14
                                Layout.preferredWidth: 14
                                Layout.preferredHeight: 14
                            }
                            MetaText { text: Fmt.platformLabel(root.selectedProfile.platform); color: CenterTokens.text }
                        }
                        MetaText { text: qsTr("Kênh") }
                        MetaText { text: String(root.selectedProfile.accountHandle || root.selectedProfile.channelId || "—"); color: CenterTokens.text }
                        MetaText { text: qsTr("Social profile") }
                        MetaText { text: String(root.selectedProfile.profileId || "—"); color: CenterTokens.text }
                        MetaText { text: qsTr("Browser profile") }
                        MetaText { text: String(root.selectedProfile.browserKey || "—"); color: CenterTokens.text }
                        MetaText { text: qsTr("Timezone") }
                        MetaText { text: String(root.draftTimezone || root.selectedProfile.timezoneName || "—"); color: CenterTokens.text }
                        MetaText { text: qsTr("Binding") }
                        MetaText { text: Fmt.compactId(root.selectedProfile.channelBindingHash); color: CenterTokens.text }
                        MetaText { text: qsTr("Config hash") }
                        MetaText { text: Fmt.compactId(root.channelProfileHash); color: CenterTokens.text }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: CenterTokens.border }
                    SectionTitle { text: qsTr("Trạng thái") }
                    CenterStatusBadge {
                        text: root.selectedProfile.authState === "verified"
                            ? qsTr("Browser đã xác minh") : qsTr("Cần xác minh browser")
                        status: root.selectedProfile.authState === "verified" ? "success" : "warning"
                        iconName: root.selectedProfile.authState === "verified"
                            ? "semantic/check-circle" : "semantic/alert-triangle"
                    }
                    CenterStatusBadge {
                        text: String(root.selectedProfile.channelBindingId || "").length > 0
                            ? qsTr("Channel binding hợp lệ") : qsTr("Chưa có channel binding")
                        status: String(root.selectedProfile.channelBindingId || "").length > 0
                            ? "success" : "warning"
                        iconName: "semantic/shield-check"
                    }
                    CenterStatusBadge {
                        text: qsTr("%1/%2 workflow sẵn sàng").arg(
                            Number(root.channelKit.ready_workflow_count || 0)).arg(
                            Number(root.channelKit.enabled_workflow_count || 5))
                        status: Boolean(root.channelKit.all_enabled_ready) ? "success" : "warning"
                        iconName: "semantic/workflow"
                    }
                    CenterStatusBadge {
                        visible: root.kitError.length > 0
                        text: root.kitError
                        status: "danger"
                        iconName: "semantic/alert-circle"
                    }
                    CenterPanel {
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.shortLayout ? 156
                            : root.compactLayout ? 180 : 210
                        elevated: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: root.compactLayout ? 8 : 10
                            spacing: root.compactLayout ? 5 : 7
                            RowLayout {
                                Layout.fillWidth: true
                                SectionTitle { text: qsTr("Phiên bản hiện tại") }
                                Item { Layout.fillWidth: true }
                                CenterStatusBadge {
                                    text: "v" + String(Math.max(1, root.channelProfileVersion))
                                    status: "info"
                                    iconName: "ui/history"
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                MetaText {
                                    Layout.fillWidth: true
                                    text: qsTr("Config: ") + Fmt.compactId(root.channelProfileHash)
                                }
                                MetaText { text: Fmt.timeLabel(root.selectedConfig.updatedAt) }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3
                                Repeater {
                                    model: (root.channelKit.revisions || []).slice(
                                        0, root.shortLayout ? 2 : 3)
                                    delegate: RowLayout {
                                        id: revisionRow
                                        required property var modelData
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 18
                                        Rectangle {
                                            Layout.preferredWidth: 7
                                            Layout.preferredHeight: 7
                                            radius: 4
                                            color: Boolean(revisionRow.modelData.is_current)
                                                ? CenterTokens.primary : CenterTokens.borderStrong
                                        }
                                        Text {
                                            text: "v" + String(revisionRow.modelData.version || 0)
                                            color: Boolean(revisionRow.modelData.is_current)
                                                ? CenterTokens.primary : CenterTokens.muted
                                            font.family: CenterTokens.fontFamily
                                            font.pixelSize: CenterTokens.metadata
                                            font.weight: Font.DemiBold
                                        }
                                        CenterStatusBadge {
                                            visible: Boolean(revisionRow.modelData.is_current)
                                            text: qsTr("Hiện tại")
                                            status: "info"
                                        }
                                        Item { Layout.fillWidth: true }
                                        MetaText { text: Fmt.timeLabel(revisionRow.modelData.created_at) }
                                    }
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 7
                                AppButton {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 30
                                    text: qsTr("Hoàn tác")
                                    leadingIcon: "ui/restore"
                                    enabled: root.draftDirty
                                    onClicked: root.syncDraft(true)
                                }
                                AppButton {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 30
                                    text: qsTr("Xem thay đổi")
                                    leadingIcon: "ui/history"
                                    enabled: (root.channelKit.revisions || []).length > 1
                                        && !root.plane.actionBusy
                                    onClicked: root.requestRevisionDiff()
                                }
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                    Text {
                        visible: root.feedbackMessage.length > 0
                        Layout.fillWidth: true
                        text: root.feedbackMessage
                        color: root.feedbackOk ? CenterTokens.success : CenterTokens.danger
                        font.family: CenterTokens.fontFamily
                        font.pixelSize: CenterTokens.metadata + 1
                        wrapMode: Text.Wrap
                    }
                    Text {
                        visible: !root.shortLayout
                        Layout.fillWidth: true
                        text: qsTr("Mỗi Assignment giữ nguyên profile version, binding version và config hash tại thời điểm giao.")
                        color: CenterTokens.muted
                        font.family: CenterTokens.fontFamily
                        font.pixelSize: CenterTokens.metadata + 1
                        wrapMode: Text.Wrap
                    }
                    AppButton {
                        Layout.fillWidth: true
                        text: root.draftDirty
                            ? qsTr("Lưu phiên bản mới")
                            : qsTr("Áp dụng cho việc mới")
                        leadingIcon: root.draftDirty ? "ui/save" : "ui/send"
                        primary: true
                        enabled: String(root.selectedProfile.profileId || "").length > 0
                            && !root.plane.actionBusy
                            && (root.draftDirty || Boolean(root.channelKit.can_assign))
                        onClicked: {
                            if (root.draftDirty)
                                root.saveRevision()
                            else
                                root.navigateRequested("coordination")
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: cloneDialog
        parent: Overlay.overlay
        modal: true
        focus: true
        width: Math.min(700, root.width - 80)
        height: Math.min(540, root.height - 80)
        x: Math.max(20, (parent.width - width) / 2)
        y: Math.max(20, (parent.height - height) / 2)
        title: qsTr("Nhân bản Channel Production Kit")
        closePolicy: Popup.CloseOnEscape
        contentItem: ColumnLayout {
            spacing: 8
            Text {
                Layout.fillWidth: true
                text: qsTr("Chọn kênh đích. Chỉ brand, tài nguyên, source policy, 5 workflow và delivery defaults được sao chép; browser/account/binding luôn lấy lại từ kênh đích.")
                color: CenterTokens.muted
                font.family: CenterTokens.fontFamily
                font.pixelSize: CenterTokens.body
                wrapMode: Text.Wrap
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                reuseItems: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.plane.profileModel
                spacing: 6
                delegate: Item {
                    id: cloneTargetRow
                    required property int index
                    required property var modelData
                    readonly property bool isSource: String(modelData.profileId || "")
                        === String(root.selectedProfile.profileId || "")
                    readonly property bool verified: String(modelData.authState || "") === "verified"
                    readonly property var targetConfig: root.resolveConfig(modelData)
                    width: ListView.view.width
                    height: isSource ? 0 : 64
                    visible: !isSource
                    Rectangle {
                        anchors.fill: parent
                        radius: CenterTokens.radius
                        color: root.cloneTargetIndex === cloneTargetRow.index
                            ? CenterTokens.primarySoft : CenterTokens.panelSoft
                        border.width: 1
                        border.color: root.cloneTargetIndex === cloneTargetRow.index
                            ? CenterTokens.primary : CenterTokens.border
                        opacity: cloneTargetRow.verified ? 1 : 0.62
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 9
                            spacing: 10
                            PlatformIcon {
                                platform: String(cloneTargetRow.modelData.platform || "generic")
                                iconSize: 22
                                Layout.preferredWidth: 22
                                Layout.preferredHeight: 22
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    Layout.fillWidth: true
                                    text: String(cloneTargetRow.modelData.label || qsTr("Kênh chưa đặt tên"))
                                    color: CenterTokens.text
                                    font.family: CenterTokens.fontFamily
                                    font.pixelSize: CenterTokens.body
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                MetaText {
                                    Layout.fillWidth: true
                                    text: String(cloneTargetRow.modelData.accountHandle
                                        || cloneTargetRow.modelData.profileId || "")
                                }
                            }
                            CenterStatusBadge {
                                text: String(cloneTargetRow.targetConfig.channelProfileId || "")
                                    ? qsTr("Tạo revision v%1").arg(
                                        Number(cloneTargetRow.targetConfig.version || 0) + 1)
                                    : qsTr("Tạo kit mới")
                                status: String(cloneTargetRow.targetConfig.channelProfileId || "")
                                    ? "warning" : "info"
                                iconName: "ui/copy"
                            }
                            CenterStatusBadge {
                                text: cloneTargetRow.verified
                                    ? qsTr("Đã xác minh") : qsTr("Chưa xác minh")
                                status: cloneTargetRow.verified ? "success" : "warning"
                            }
                        }
                        TapHandler {
                            enabled: cloneTargetRow.verified
                            onTapped: root.cloneTargetIndex = cloneTargetRow.index
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                AppButton {
                    text: qsTr("Hủy")
                    subtle: true
                    onClicked: cloneDialog.close()
                }
                AppButton {
                    text: qsTr("Nhân bản & rebind")
                    leadingIcon: "ui/copy"
                    primary: true
                    enabled: root.cloneTargetIndex >= 0 && !root.plane.actionBusy
                    onClicked: root.cloneToSelectedTarget()
                }
            }
        }
    }

    Dialog {
        id: revisionDialog
        parent: Overlay.overlay
        modal: true
        focus: true
        width: Math.min(860, root.width - 80)
        height: Math.min(620, root.height - 80)
        x: Math.max(20, (parent.width - width) / 2)
        y: Math.max(20, (parent.height - height) / 2)
        title: qsTr("Thay đổi Channel Production Kit")
        standardButtons: Dialog.Close
        contentItem: ColumnLayout {
            spacing: 8
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: qsTr("v%1 → v%2 · %3 thay đổi").arg(
                        Number(root.revisionDiff.before_version || 0)).arg(
                        Number(root.revisionDiff.after_version || 0)).arg(
                        Number(root.revisionDiff.change_count || 0))
                    color: CenterTokens.text
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.sectionTitle
                    font.weight: Font.DemiBold
                }
                CenterStatusBadge {
                    text: Fmt.compactId(root.revisionDiff.after_hash)
                    status: "info"
                    iconName: "semantic/shield-check"
                }
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                reuseItems: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.revisionDiff.changes || []
                spacing: 5
                delegate: Rectangle {
                    id: diffRow
                    required property var modelData
                    width: ListView.view.width
                    height: 56
                    radius: CenterTokens.radiusSmall
                    color: CenterTokens.panelSoft
                    border.width: 1
                    border.color: CenterTokens.border
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 7
                        spacing: 2
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                text: String(diffRow.modelData.path || "")
                                color: CenterTokens.text
                                font.family: "Consolas"
                                font.pixelSize: CenterTokens.metadata + 1
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            CenterStatusBadge {
                                text: String(diffRow.modelData.change || "changed")
                                status: String(diffRow.modelData.change || "") === "removed"
                                    ? "danger" : String(diffRow.modelData.change || "") === "added"
                                    ? "success" : "warning"
                            }
                        }
                        MetaText {
                            Layout.fillWidth: true
                            text: root.compactValue(diffRow.modelData.before)
                                + "  →  " + root.compactValue(diffRow.modelData.after)
                        }
                    }
                }
            }
        }
    }
}
