pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../foundation" as Foundation
import "alerts" as Alerts

Item {
    id: root
    objectName: "alertsPage"
    Accessible.name: "Trung tâm cảnh báo và sự cố"
    Accessible.role: Accessible.Pane

    // qmllint disable unqualified
    readonly property var plane: controlPlane
    // qmllint enable unqualified
    property var alertsSnapshot: ({})
    property bool embeddedMode: false
    property var snapshotError: ({})
    property string selectedIncidentId: ""
    property string selectionProjectionRequestedId: ""
    property var selectedIncidentIds: []
    property bool inspectorDismissed: false
    property int selectionRevision: 0
    property int commandRevision: 0
    property var pendingResolution: ({})
    property var resolutionAction: ({})
    property var pendingMute: ({})
    property var muteAction: ({})
    property var pendingRuleCommand: ({})
    property var ruleMutationAction: ({})
    property var pendingRuleArchive: ({})
    property string ruleMutationCapability: ""
    property string ruleEditorMode: "create"
    property string selectedRuleKey: ""
    property var ruleSeveritySelection: []
    property var ruleRecoverySelection: []
    property var pendingSeverityCommand: ({})
    property var severityAction: ({})
    property string bulkOperation: ""
    property var pendingBulkPreview: ({})
    property var pendingBulkBatch: ({})
    property var pendingBulkAction: ({})
    property string bulkFlowState: "idle"
    property string bulkPreviewIdempotencyKey: ""
    property int bulkRequestSequence: 0
    property string resolutionValidationError: ""
    property string muteValidationError: ""
    property string ruleValidationError: ""
    property string severityValidationError: ""
    property string bulkValidationError: ""
    property string commandOutcomeText: ""
    property bool commandOutcomeOk: true

    readonly property var projectionData: (root.alertsSnapshot || {}).data || ({})
    readonly property var filters: root.projectionData.filters || ({})
    readonly property var header: root.projectionData.header || ({})
    readonly property var summary: root.projectionData.summary || ({})
    readonly property var inbox: root.projectionData.inbox || ({})
    readonly property var incidentModel: root.plane.snapshotStore.collection("alerts", "incidents")
    readonly property var inspector: root.projectionData.inspector || ({})
    readonly property var inspectorIncident: root.inspector.incident || ({})
    readonly property var rules: root.projectionData.rules || ({})
    readonly property var ruleCatalog: root.rules.catalog || ({})
    readonly property var subsystemHealth: root.projectionData.subsystem_health || ({})
    readonly property var healthModel: root.plane.snapshotStore.collection("alerts", "health")
    readonly property var snapshotPage: (root.alertsSnapshot || {}).page || ({})
    readonly property int incidentCount: root.incidentModel.count
    readonly property int selectedCount: root.selectedIncidentIds.length
    readonly property var selectedIncident: {
        const revision = root.selectionRevision
        return root.incidentForId(root.selectedIncidentId)
    }
    readonly property bool inspectorDetailAvailable: Boolean(root.inspector.available)
        && String(root.inspectorIncident.id || "") === root.selectedIncidentId
    readonly property var selectedOccurrences: root.inspectorDetailAvailable
        ? (root.inspector.occurrences || []) : []
    readonly property var selectedResolution: root.inspectorDetailAvailable
        ? (root.inspector.resolution || null) : null
    readonly property bool canRead: root.hasPermission("incident.read")
    readonly property bool canWrite: root.hasPermission("incident.write")
    readonly property bool canResolve: root.hasPermission("incident.resolve")
    readonly property bool canManageRules: root.hasPermission("incident.rule.write")
    readonly property bool resolutionConfirmationReady:
        Object.keys(root.pendingResolution || {}).length > 0
    readonly property bool muteConfirmationReady:
        Object.keys(root.pendingMute || {}).length > 0
    readonly property bool ruleConfirmationReady:
        root.ruleMutationCapability.length > 0
        && Object.keys(root.pendingRuleCommand || {}).length > 0
    readonly property bool ruleArchiveConfirmationReady:
        Object.keys(root.pendingRuleArchive || {}).length > 0
    readonly property bool severityConfirmationReady:
        Object.keys(root.pendingSeverityCommand || {}).length > 0
    readonly property bool bulkConfirmationReady:
        root.bulkFlowState === "awaiting_confirmation"
        && String((root.pendingBulkBatch || {}).id || "").length > 0
    readonly property bool bulkLocked:
        ["previewing", "awaiting_confirmation", "executing"]
            .indexOf(root.bulkFlowState) >= 0
    readonly property bool muteCommandBusy: {
        const revision = root.commandRevision
        return root.plane.commandStore.isBusy("incident.mute", "global", "global")
    }
    readonly property string viewState: root.resolveViewState()
    readonly property string bulkStatusText: {
        if (root.bulkValidationError) return root.bulkValidationError
        const batch = root.pendingBulkBatch || ({})
        if (root.bulkFlowState === "previewing")
            return "Đang tạo server preview cho selection đã đóng băng…"
        if (root.bulkFlowState === "awaiting_confirmation")
            return "Preview " + String(batch.id || "—") + ": "
                + String(batch.eligible_count || 0) + " dòng đủ điều kiện."
        if (root.bulkFlowState === "executing")
            return "Đang thực thi batch " + String(batch.id || "—") + "…"
        if (root.bulkFlowState === "completed")
            return "Bulk operation đã có kết quả server; snapshot đang được làm mới."
        return ""
    }

    function reloadSnapshot() {
        root.alertsSnapshot = root.plane.snapshotStore.snapshot("alerts")
        root.snapshotError = root.plane.snapshotStore.error("alerts")
        root.selectionRevision += 1
        root.reconcileSelection()
        root.reconcileBulkSelection()
    }

    function hasPermission(permission) {
        const requested = String(permission || "").trim()
        if (!requested) return false
        const permissions = (root.alertsSnapshot || {}).permissions || []
        return permissions.indexOf(requested) >= 0
            || permissions.indexOf("workspace.admin") >= 0
    }

    function hasProjectionData() {
        return root.incidentModel.count > 0 || Object.keys(root.summary).length > 0
            || root.healthModel.count > 0
            || Boolean(root.inspector.available)
    }

    function resolveViewState() {
        const snapshot = root.alertsSnapshot || ({})
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
        const freshness = String((snapshot.freshness || {}).state || "fresh").toLowerCase()
        if (freshness === "partial" || freshness === "stale") return freshness
        return root.hasProjectionData() ? "content" : "empty"
    }

    function incidentForId(incidentId) {
        const identity = String(incidentId || "")
        if (String(root.inspectorIncident.id || "") === identity)
            return root.inspectorIncident
        for (let index = 0; index < root.incidentModel.count; index++) {
            const incident = root.incidentModel.get(index) || ({})
            if (String(incident.incident_id || "") === identity) return incident
        }
        return ({})
    }

    function projectedIncidentForId(incidentId) {
        const identity = String(incidentId || "")
        const items = (root.inbox || {}).items || []
        for (let index = 0; index < items.length; index++) {
            const item = items[index] || ({})
            if (String(item.id || item.incident_id || "") === identity) return item
        }
        return ({})
    }

    function ruleForKey(ruleKey) {
        const identity = String(ruleKey || "")
        const items = (root.rules || {}).items || []
        for (let index = 0; index < items.length; index++) {
            const item = items[index] || ({})
            if (String(item.rule_key || "") === identity) return item
        }
        return ({})
    }

    function ruleBusy(capability, ruleKey) {
        const revision = root.commandRevision
        return root.plane.commandStore.isBusy(
            String(capability || ""), "incident_rule", String(ruleKey || "")
        )
    }

    function bulkOperationDescriptor(operation) {
        const actions = (root.inbox || {}).bulk_actions || ({})
        const rows = actions.operations || []
        for (let index = 0; index < rows.length; index++) {
            const row = rows[index] || ({})
            if (String(row.key || "") === String(operation || ""))
                return row
        }
        return ({})
    }

    function bulkOperationAvailable(operation) {
        const descriptor = root.bulkOperationDescriptor(operation)
        const action = descriptor.action || ({})
        return Boolean(descriptor.available) && Boolean(action.available)
            && String(action.capability || "").length > 0
    }

    function reconcileSelection() {
        const selection = root.plane.entitySelection.current || ({})
        const entity = selection.entity || ({})
        if (String(selection.route || "") === "alerts"
                && String(entity.type || "") === "incident") {
            const linkedId = String(entity.id || "")
            if (linkedId) {
                root.inspectorDismissed = false
                root.selectedIncidentId = linkedId
                root.reconcileIncidentProjection()
                return
            }
        }
        if (root.inspectorDismissed) {
            root.selectedIncidentId = ""
            return
        }
        if (root.selectedIncidentId && root.incidentForId(root.selectedIncidentId).id) {
            root.reconcileIncidentProjection()
            return
        }
        const snapshotId = String(root.inspectorIncident.id || "")
        if (snapshotId && root.incidentForId(snapshotId).id) {
            root.selectedIncidentId = snapshotId
            root.reconcileIncidentProjection()
            return
        }
        root.selectedIncidentId = root.incidentModel.count > 0
            ? String((root.incidentModel.get(0) || {}).incident_id || "") : ""
        root.reconcileIncidentProjection()
    }

    function reconcileIncidentProjection() {
        const identity = String(root.selectedIncidentId || "")
        if (!identity || root.inspectorDismissed || !root.canRead)
            return
        if (Boolean(root.inspector.available)
                && String(root.inspectorIncident.id || "") === identity) {
            root.selectionProjectionRequestedId = identity
            return
        }
        if (root.selectionProjectionRequestedId === identity)
            return
        root.requestSnapshot(root.baseQuery(identity, root.filters.offset || 0))
    }

    function reconcileBulkSelection() {
        const available = ({})
        for (let index = 0; index < root.incidentModel.count; index++)
            available[String((root.incidentModel.get(index) || {}).incident_id || "")] = true
        const retained = []
        for (let index = 0; index < root.selectedIncidentIds.length; index++) {
            const identity = String(root.selectedIncidentIds[index] || "")
            if (available[identity]) retained.push(identity)
        }
        root.selectedIncidentIds = retained
    }

    function baseQuery(selectedId, offsetValue) {
        const limitValue = Math.max(1, Math.min(
            100, Number(root.filters.limit || 25))) | 0
        const offsetNumber = Number(offsetValue === undefined
            ? (root.filters.offset || 0) : offsetValue)
        const offset = Math.max(0, offsetNumber) | 0
        const query = {
            // Bitwise normalization keeps these strict JSON integers across
            // the QML -> QVariant -> Python boundary.
            "limit": limitValue,
            "offset": offset,
            "timezone": String(root.filters.timezone || "Asia/Bangkok")
        }
        if (root.filters.status) query.status = String(root.filters.status)
        if (root.filters.severity) query.severity = String(root.filters.severity)
        if (root.filters.source) query.source = String(root.filters.source)
        if (root.filters.owner_id) query.owner_id = String(root.filters.owner_id)
        if (root.filters.search) query.search = String(root.filters.search)
        if (root.filters.occurred_from)
            query.occurred_from = String(root.filters.occurred_from)
        if (root.filters.occurred_to)
            query.occurred_to = String(root.filters.occurred_to)
        if (root.filters.sort && String(root.filters.sort) !== "last_seen_desc")
            query.sort = String(root.filters.sort)
        const selection = String(selectedId === undefined
            ? root.selectedIncidentId : selectedId || "")
        if (selection) query.selected_incident_id = selection
        return query
    }

    function requestSnapshot(query) {
        if (!root.canRead) return false
        const payload = query || root.baseQuery()
        const selectedId = String(payload.selected_incident_id || "")
        if (selectedId)
            root.selectionProjectionRequestedId = selectedId
        root.plane.callTool("alerts.snapshot", payload)
        return true
    }

    function retrySnapshot() {
        const snapshot = root.alertsSnapshot || ({})
        if (String(snapshot.snapshot_id || "") && root.canRead)
            return root.requestSnapshot(root.baseQuery())
        if (!root.plane || !root.plane.refreshSnapshotTool) return false
        return root.plane.refreshSnapshotTool("alerts.snapshot")
    }

    function selectIncident(incidentId) {
        const identity = String(incidentId || "")
        if (!root.incidentForId(identity).id) return false
        root.inspectorDismissed = false
        root.selectedIncidentId = identity
        root.selectionRevision += 1
        root.selectionProjectionRequestedId = identity
        root.plane.navigateEntity("alerts", "incident", identity, {
            "subview": "detail", "source": "alerts"
        })
        root.requestSnapshot(root.baseQuery(identity, root.filters.offset || 0))
        return true
    }

    function setIncidentChecked(incidentId, checked) {
        const identity = String(incidentId || "")
        if (!identity) return false
        const next = root.selectedIncidentIds.slice()
        const index = next.indexOf(identity)
        if (checked && index < 0) next.push(identity)
        else if (!checked && index >= 0) next.splice(index, 1)
        root.selectedIncidentIds = next
        return true
    }

    function selectVisibleIncidents(checked) {
        if (!checked) {
            root.selectedIncidentIds = []
            return true
        }
        const identities = []
        for (let index = 0; index < root.incidentModel.count; index++) {
            const identity = String((root.incidentModel.get(index) || {}).incident_id || "")
            if (identity) identities.push(identity)
        }
        root.selectedIncidentIds = identities
        return true
    }

    function claimSelectedIncident() {
        return root.executeProjectedAction((root.inspector.actions || {}).claim)
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

    function handleHeaderAction(action) {
        const descriptor = action || ({})
        if (!descriptor.available) return false
        const capability = String(descriptor.capability || "")
        if (capability === "incident.rule.create")
            return root.openRuleCreate()
        if (capability === "incident.mute") {
            const input = descriptor.input || ({})
            root.muteAction = descriptor
            muteReason.text = String(input.reason || "")
            muteExpiry.text = String(input.expires_at || "")
            muteForm.open()
            return true
        }
        if (String(descriptor.kind || "") === "navigation")
            return root.followDeepLink(descriptor.deep_link || ({}))
        return false
    }

    function dismissInspector() {
        root.inspectorDismissed = true
        root.selectedIncidentId = ""
        root.selectionProjectionRequestedId = ""
        root.plane.entitySelection.clear()
        root.requestSnapshot(root.baseQuery("", root.filters.offset || 0))
        return true
    }

    function executeProjectedAction(action) {
        const descriptor = action || ({})
        if (!descriptor.available) return false
        const kind = String(descriptor.kind || "")
        if (kind === "navigation")
            return root.followDeepLink(descriptor.deep_link || ({}))
        if (kind === "dismiss") return root.dismissInspector()
        const capability = String(descriptor.capability || "")
        if (!capability) return false
        if (capability === "incident.severity.change") {
            root.severityAction = descriptor
            root.severityValidationError = ""
            root.pendingSeverityCommand = ({})
            root.setSeverityCombo(
                severityCombo, String(root.selectedIncident.severity || "info")
            )
            severityForm.open()
            return true
        }
        if (capability === "incident.resolve") {
            root.resolutionAction = descriptor
            root.resolutionValidationError = ""
            root.pendingResolution = ({})
            resolutionForm.open()
            return true
        }
        root.plane.callTool(capability, descriptor.input || ({}))
        return true
    }

    function isAlertOutcomeCapability(capability) {
        const name = String(capability || "")
        return name.indexOf("incident.") === 0
            || ["studio.render.retry", "workflow.step.retry", "task.retry"]
                .indexOf(name) >= 0
    }

    function prepareResolution() {
        root.resolutionValidationError = ""
        root.pendingResolution = ({})
        const descriptor = Object.keys(root.resolutionAction || {}).length > 0
            ? root.resolutionAction : ((root.inspector.actions || {}).resolve || ({}))
        root.resolutionAction = descriptor
        const base = descriptor.input || ({})
        const incidentId = String(base.incident_id || "")
        const code = resolutionCode.text.trim()
        const note = resolutionNote.text.trim()
        const evidenceType = resolutionEvidenceType.text.trim()
        const evidenceId = resolutionEvidenceId.text.trim()
        if (!root.canResolve || !incidentId || String(root.selectedIncident.status || "") !== "open") {
            root.resolutionValidationError = "Incident không thể resolve hoặc thiếu quyền."
            return false
        }
        if (!code || !note || !evidenceType || !evidenceId
                || /\s/.test(evidenceType) || /\s/.test(evidenceId)) {
            root.resolutionValidationError = "Cần mã, ghi chú và một evidence ref hợp lệ."
            return false
        }
        root.pendingResolution = Object.assign({}, base, {
            "resolution_code": code,
            "note": note,
            "evidence_refs": [{"type": evidenceType, "id": evidenceId}]
        })
        resolutionConfirm.open()
        return true
    }

    function confirmResolution() {
        const capability = String((root.resolutionAction || {}).capability || "")
        if (!root.resolutionConfirmationReady || capability.length === 0) return false
        resolutionForm.beginPending(capability, root.selectedIncidentId)
        root.plane.callTool(capability, root.pendingResolution)
        return true
    }

    function muteScopeValue(scope) {
        const normalized = String(scope || "")
        if (normalized === "all") return ""
        if (normalized === "source") return String(root.selectedIncident.source || "")
        if (normalized === "entity") {
            const entity = root.selectedIncident.entity || ({})
            if (!entity.type || !entity.id) return ""
            return String(entity.type) + ":" + String(entity.id)
        }
        return ""
    }

    function prepareMute() {
        root.muteValidationError = ""
        root.pendingMute = ({})
        const descriptor = Object.keys(root.muteAction || {}).length > 0
            ? root.muteAction : ((root.header.actions || {}).mute || ({}))
        root.muteAction = descriptor
        const base = descriptor.input || ({})
        const scope = String(base.scope_type || "")
        const scopeValue = String(base.scope_value || "")
        const reasonRaw = muteReason.text
        const expiryRaw = muteExpiry.text
        const reason = reasonRaw.trim()
        const expiry = expiryRaw.trim()
        const parsed = new Date(expiry)
        const now = new Date()
        if (!root.canWrite) {
            root.muteValidationError = "Thiếu quyền incident.write."
            return false
        }
        if ((scope !== "all" && !scopeValue) || !reason || reason !== reasonRaw
                || !expiry || expiry !== expiryRaw
                || !/(Z|[+-]\d{2}:\d{2})$/.test(expiry)
                || isNaN(parsed.getTime()) || parsed <= now
                || parsed.getTime() - now.getTime() > 30 * 24 * 60 * 60 * 1000) {
            root.muteValidationError = "Scope, lý do hoặc hạn tạm ẩn không hợp lệ."
            return false
        }
        root.pendingMute = Object.assign({}, base, {
            "reason": reason,
            "expires_at": expiry
        })
        muteConfirm.open()
        return true
    }

    function confirmMute() {
        if (!root.muteConfirmationReady || !root.canWrite) return false
        muteForm.beginPending("incident.mute", "global")
        root.plane.callTool("incident.mute", root.pendingMute)
        return true
    }

    function splitSemanticList(value, allowUppercase) {
        const raw = String(value || "").trim()
        if (!raw) return []
        const result = []
        const values = raw.split(",")
        const pattern = allowUppercase
            ? /^[A-Za-z][A-Za-z0-9_.:-]{0,159}$/
            : /^[a-z][a-z0-9_.:-]{0,119}$/
        for (let index = 0; index < values.length; index++) {
            const item = values[index].trim()
            if (!item || !pattern.test(item)) return null
            if (result.indexOf(item) < 0) result.push(item)
        }
        return result
    }

    function catalogIndex(model, value) {
        const identity = String(value || "")
        const rows = model || []
        for (let index = 0; index < rows.length; index++)
            if (String((rows[index] || {}).key || "") === identity) return index
        return rows.length > 0 ? 0 : -1
    }

    function setSeverityCombo(combo, value) {
        combo.currentIndex = root.catalogIndex(
            root.ruleCatalog.severities || [], value
        )
    }

    function toggleRuleSelection(kind, key, checked) {
        const identity = String(key || "")
        const source = kind === "severity"
            ? root.ruleSeveritySelection : root.ruleRecoverySelection
        const next = source.slice()
        const index = next.indexOf(identity)
        if (checked && index < 0) next.push(identity)
        else if (!checked && index >= 0) next.splice(index, 1)
        if (kind === "severity") root.ruleSeveritySelection = next
        else root.ruleRecoverySelection = next
    }

    function resetRuleEditor() {
        root.ruleValidationError = ""
        root.pendingRuleCommand = ({})
        root.ruleMutationAction = ({})
        root.ruleMutationCapability = ""
        const prefill = root.ruleCatalog.create_prefill || ({})
        ruleKeyField.text = ""
        ruleNameField.text = ""
        ruleSourceField.currentIndex = root.catalogIndex(
            root.ruleCatalog.sources || [],
            ((prefill.conditions || {}).source || "")
        )
        ruleEventTypeField.text = ""
        ruleCodeField.text = ""
        ruleEntityTypeField.text = ""
        root.ruleSeveritySelection = ((prefill.conditions || {}).severities || []).slice()
        root.ruleRecoverySelection = (prefill.recovery_capabilities || []).slice()
        ruleEnabled.checked = Boolean(prefill.enabled)
        rulePriority.value = prefill.priority === undefined ? 0 : prefill.priority
        ruleDedupe.value = prefill.dedupe_window_seconds === undefined
            ? ruleDedupe.from : prefill.dedupe_window_seconds
        ruleSla.value = prefill.sla_seconds === undefined
            ? ruleSla.from : prefill.sla_seconds
        ruleMute.value = prefill.mute_for_seconds === undefined
            ? ruleMute.from : prefill.mute_for_seconds
        ruleEscalationEnabled.checked = false
        ruleEscalationAfter.value = ruleEscalationAfter.from
        ruleEscalationSeverity.currentIndex = root.catalogIndex(
            root.ruleCatalog.severities || [], ""
        )
    }

    function openRuleCreate() {
        const action = ((root.rules.actions || {}).create || ({}))
        if (!Boolean(action.available)) return false
        root.ruleEditorMode = "create"
        root.selectedRuleKey = ""
        root.resetRuleEditor()
        root.ruleMutationAction = action
        ruleManager.open()
        return true
    }

    function openRuleRevision(ruleKey) {
        if (!Boolean(root.rules.available)) return false
        const rule = root.ruleForKey(ruleKey)
        const action = ((rule.actions || {}).revise || ({}))
        if (!rule.id || !Boolean(action.available)) return false
        root.ruleEditorMode = "revise"
        root.selectedRuleKey = String(rule.rule_key || "")
        root.resetRuleEditor()
        const base = action.input || ({})
        const conditions = base.conditions || ({})
        ruleKeyField.text = root.selectedRuleKey
        ruleNameField.text = String(base.name || "")
        ruleSourceField.currentIndex = root.catalogIndex(
            root.ruleCatalog.sources || [], conditions.source
        )
        ruleEventTypeField.text = (conditions.event_types || []).join(",")
        ruleCodeField.text = (conditions.codes || []).join(",")
        root.ruleSeveritySelection = (conditions.severities || []).slice()
        ruleEntityTypeField.text = (conditions.entity_types || []).join(",")
        ruleEnabled.checked = Boolean(base.enabled)
        rulePriority.value = base.priority
        ruleDedupe.value = base.dedupe_window_seconds
        ruleSla.value = base.sla_seconds
        ruleMute.value = base.mute_for_seconds
        const escalation = base.escalation || ({})
        ruleEscalationEnabled.checked = Boolean(escalation.after_seconds)
        ruleEscalationAfter.value = Number(escalation.after_seconds || 1800)
        root.setSeverityCombo(ruleEscalationSeverity, escalation.severity || "critical")
        root.ruleRecoverySelection = (base.recovery_capabilities || []).slice()
        root.ruleMutationAction = action
        ruleManager.open()
        return true
    }

    function rulePayload() {
        const key = ruleKeyField.text.trim()
        const name = ruleNameField.text.trim()
        const source = String(ruleSourceField.currentValue || "")
        const eventTypes = root.splitSemanticList(ruleEventTypeField.text, false)
        const codes = root.splitSemanticList(ruleCodeField.text, true)
        const severities = root.ruleSeveritySelection.slice()
        const entityTypes = root.splitSemanticList(ruleEntityTypeField.text, false)
        if (!/^[a-z][a-z0-9_.:-]{0,119}$/.test(key) || !name
                || !(source === "*" || /^[a-z][a-z0-9_.:-]{0,119}$/.test(source))
                || eventTypes === null || codes === null
                || entityTypes === null) {
            root.ruleValidationError = "Rule key, tên hoặc điều kiện semantic không hợp lệ."
            return ({})
        }
        const payload = Object.assign({}, (root.ruleMutationAction || {}).input || ({}), {
            "rule_key": key,
            "name": name,
            "enabled": Boolean(ruleEnabled.checked),
            "priority": rulePriority.value,
            "conditions": {
                "source": source,
                "event_types": eventTypes,
                "codes": codes,
                "severities": severities,
                "entity_types": entityTypes
            },
            "dedupe_window_seconds": ruleDedupe.value,
            "sla_seconds": ruleSla.value,
            "mute_for_seconds": ruleMute.value,
            "recovery_capabilities": root.ruleRecoverySelection.slice()
        })
        if (ruleEscalationEnabled.checked) {
            payload.escalation = {
                "after_seconds": ruleEscalationAfter.value,
                "severity": String(ruleEscalationSeverity.currentValue || "critical")
            }
        }
        return payload
    }

    function prepareRuleCreate() {
        root.ruleValidationError = ""
        if (!root.canManageRules || root.ruleEditorMode !== "create") return false
        const payload = root.rulePayload()
        if (!payload.rule_key) return false
        root.ruleMutationCapability = String(root.ruleMutationAction.capability || "")
        root.pendingRuleCommand = payload
        ruleMutationConfirm.open()
        return true
    }

    function prepareRuleRevision() {
        root.ruleValidationError = ""
        if (!root.canManageRules || root.ruleEditorMode !== "revise") return false
        const payload = root.rulePayload()
        const version = payload.expected_version
        if (!payload.rule_key || payload.rule_key !== root.selectedRuleKey
                || !Number.isInteger(Number(version)) || Number(version) < 1) {
            root.ruleValidationError = "Rule version không còn khả dụng; cần tải lại snapshot."
            return false
        }
        root.ruleMutationCapability = String(root.ruleMutationAction.capability || "")
        root.pendingRuleCommand = payload
        ruleMutationConfirm.open()
        return true
    }

    function confirmRuleMutation() {
        if (!root.ruleConfirmationReady || !root.canManageRules) return false
        ruleManager.beginPending(root.ruleMutationCapability, root.selectedRuleKey)
        root.plane.callTool(root.ruleMutationCapability, root.pendingRuleCommand)
        return true
    }

    function prepareRuleArchive(ruleKey) {
        root.pendingRuleArchive = ({})
        if (!root.canManageRules) return false
        const rule = root.ruleForKey(ruleKey)
        const action = ((rule.actions || {}).archive || ({}))
        if (!rule.id || !Boolean(action.available)) return false
        root.pendingRuleArchive = action.input || ({})
        root.ruleMutationAction = action
        ruleArchiveConfirm.open()
        return true
    }

    function confirmRuleArchive() {
        if (!root.ruleArchiveConfirmationReady || !root.canManageRules) return false
        root.plane.callTool(
            String(root.ruleMutationAction.capability || ""), root.pendingRuleArchive
        )
        return true
    }

    function prepareSeverityChange() {
        root.severityValidationError = ""
        root.pendingSeverityCommand = ({})
        const incident = root.selectedIncident || ({})
        const descriptor = Object.keys(root.severityAction || {}).length > 0
            ? root.severityAction
            : ((root.inspector.actions || {}).severity_change || ({}))
        root.severityAction = descriptor
        const base = descriptor.input || ({})
        const version = base.expected_version
        const severity = String(severityCombo.currentValue || "")
        const reasonRaw = severityReason.text
        const reason = reasonRaw.trim()
        if (!root.canWrite || String(incident.status || "") !== "open"
                || !Number.isInteger(Number(version)) || Number(version) < 1 || !reason
                || reason !== reasonRaw || severity === String(incident.severity || "")) {
            root.severityValidationError = "Cần version hiện tại, mức độ mới và lý do audit hợp lệ."
            return false
        }
        root.pendingSeverityCommand = Object.assign({}, base, {
            "severity": severity,
            "reason": reason
        })
        severityConfirm.open()
        return true
    }

    function confirmSeverityChange() {
        const capability = String((root.severityAction || {}).capability || "")
        if (!root.severityConfirmationReady || capability.length === 0) return false
        severityForm.beginPending(capability, root.selectedIncidentId)
        root.plane.callTool(capability, root.pendingSeverityCommand)
        return true
    }

    function selectedVersionTargets() {
        const rows = []
        const identities = root.selectedIncidentIds.slice().sort()
        for (let index = 0; index < identities.length; index++) {
            const incident = root.projectedIncidentForId(identities[index])
            const version = incident.version
            if (!incident.id || !Number.isInteger(Number(version))
                    || Number(version) < 1) return null
            rows.push({"incident_id": String(incident.id), "version": version})
        }
        return rows
    }

    function startBulkOperation(operation) {
        const normalized = String(operation || "")
        root.bulkValidationError = ""
        root.pendingBulkPreview = ({})
        root.pendingBulkBatch = ({})
        root.pendingBulkAction = ({})
        root.bulkFlowState = "idle"
        if (root.selectedCount < 1 || !root.bulkOperationAvailable(normalized)
                || (normalized === "resolve" ? !root.canResolve : !root.canWrite)) {
            root.bulkValidationError = "Bulk action không khả dụng cho quyền hoặc selection hiện tại."
            return false
        }
        root.bulkOperation = normalized
        root.pendingBulkAction = (
            root.bulkOperationDescriptor(normalized).action || ({})
        )
        root.bulkRequestSequence += 1
        root.bulkPreviewIdempotencyKey = "alerts-bulk-preview-"
            + String(Date.now()) + "-" + String(root.bulkRequestSequence)
        if (normalized === "claim") return root.requestBulkPreview()
        bulkForm.open()
        return true
    }

    function requestBulkPreview() {
        root.bulkValidationError = ""
        const targets = root.selectedVersionTargets()
        if (targets === null || targets.length < 1) {
            root.bulkValidationError = "Selection thiếu incident version; cần tải lại snapshot."
            return false
        }
        const action = root.pendingBulkAction || ({})
        const capability = String(action.capability || "")
        if (!action.available || !capability) {
            root.bulkValidationError = "Bulk preview descriptor không còn khả dụng."
            return false
        }
        const payload = Object.assign({}, action.input || ({}), {
            "operation": root.bulkOperation,
            "targets": targets,
            "idempotency_key": root.bulkPreviewIdempotencyKey
        })
        if (root.bulkOperation === "resolve") {
            const code = bulkResolutionCode.text.trim()
            const noteRaw = bulkResolutionNote.text
            const note = noteRaw.trim()
            if (!/^[A-Za-z][A-Za-z0-9_.:-]{0,159}$/.test(code)
                    || !note || note !== noteRaw) {
                root.bulkValidationError = "Cần resolution code và ghi chú audit hợp lệ."
                return false
            }
            payload.resolution_code = code
            payload.note = note
        } else if (root.bulkOperation === "change_severity") {
            const reasonRaw = bulkSeverityReason.text
            const reason = reasonRaw.trim()
            if (!reason || reason !== reasonRaw) {
                root.bulkValidationError = "Cần lý do đổi mức độ hợp lệ."
                return false
            }
            payload.severity = String(bulkSeverityCombo.currentValue || "")
            payload.reason = reason
        } else if (root.bulkOperation !== "claim") {
            root.bulkValidationError = "Bulk operation không được hỗ trợ."
            return false
        }
        root.pendingBulkPreview = payload
        root.bulkFlowState = "previewing"
        root.plane.callTool(capability, payload)
        bulkForm.close()
        return true
    }

    function confirmBulkExecution() {
        if (!root.bulkConfirmationReady) return false
        const batchId = String((root.pendingBulkBatch || {}).id || "")
        const capability = String(
            ((root.inbox || {}).bulk_actions || {}).execute_capability || ""
        )
        if (!capability) return false
        root.bulkFlowState = "executing"
        root.plane.callTool(capability, {
            "batch_id": batchId,
            "idempotency_key": "alerts-bulk-execute-" + batchId
        })
        return true
    }

    function reopenBulkExecution() {
        if (!String((root.pendingBulkBatch || {}).id || "")) return false
        root.bulkFlowState = "awaiting_confirmation"
        bulkExecutionConfirm.open()
        return true
    }

    Component.onCompleted: root.reloadSnapshot()

    Connections {
        target: root.plane.snapshotStore
        function onChanged(route) {
            if (route === "alerts") root.reloadSnapshot()
        }
    }
    Connections {
        target: root.plane.entitySelection
        function onSelectionChanged() {
            root.selectionRevision += 1
            root.reconcileSelection()
        }
    }
    Connections {
        target: root.plane.commandStore
        function onChanged(capability, entityType, entityId) {
            root.commandRevision += 1
            const name = String(capability || "")
            const state = root.plane.commandStore.state(
                name, String(entityType || ""), String(entityId || "")
            ) || ({})
            const terminal = !Boolean(state.busy)
                && ["succeeded", "failed"].indexOf(String(state.state || "")) >= 0
            if (terminal && root.isAlertOutcomeCapability(name)) {
                root.commandOutcomeOk = Boolean(state.ok)
                root.commandOutcomeText = Boolean(state.ok)
                    ? String(state.message || "Thao tác đã hoàn tất trên server")
                    : String(state.message || "Thao tác bị server từ chối")
            }
            const bulkPreviewCapability = String(
                (root.pendingBulkAction || {}).capability || ""
            )
            const bulkExecuteCapability = String(
                ((root.inbox || {}).bulk_actions || {}).execute_capability || ""
            )
            if (bulkPreviewCapability.length > 0
                    && name === bulkPreviewCapability && !Boolean(state.busy)) {
                const result = state.result || ({})
                const batch = result.batch || ({})
                if (Boolean(state.ok) && String(batch.id || "")) {
                    root.pendingBulkBatch = batch
                    root.bulkFlowState = "awaiting_confirmation"
                    bulkExecutionConfirm.open()
                } else if (String(state.state || "") === "failed") {
                    root.bulkFlowState = "preview_failed"
                    root.bulkValidationError = String(
                        state.message || "Không thể tạo bulk preview."
                    )
                }
            } else if (bulkExecuteCapability.length > 0
                    && name === bulkExecuteCapability && !Boolean(state.busy)) {
                if (Boolean(state.ok)) {
                    const result = state.result || ({})
                    if (String((result.batch || {}).id || ""))
                    root.pendingBulkBatch = result.batch
                    root.bulkFlowState = "completed"
                    root.selectedIncidentIds = []
                } else if (String(state.state || "") === "failed") {
                    root.bulkFlowState = "execute_failed"
                    root.bulkValidationError = String(
                        state.message || "Bulk execution chưa hoàn tất."
                    )
                }
            } else if (terminal && name === root.ruleMutationCapability) {
                ruleManager.finishPending(Boolean(state.ok), state.message)
                if (Boolean(state.ok)) {
                    root.pendingRuleCommand = ({})
                    root.ruleMutationAction = ({})
                    root.ruleMutationCapability = ""
                } else {
                    root.ruleValidationError = String(
                        state.message || "Server từ chối thay đổi quy tắc."
                    )
                }
            } else if (terminal && name === "incident.rule.archive") {
                if (Boolean(state.ok)) root.pendingRuleArchive = ({})
            } else if (terminal && name === "incident.severity.change") {
                severityForm.finishPending(Boolean(state.ok), state.message)
                if (Boolean(state.ok)) {
                    root.pendingSeverityCommand = ({})
                    root.severityAction = ({})
                } else {
                    root.severityValidationError = String(
                        state.message || "Server từ chối đổi mức độ."
                    )
                }
            } else if (terminal && name === "incident.resolve") {
                resolutionForm.finishPending(Boolean(state.ok), state.message)
                if (Boolean(state.ok)) {
                    root.pendingResolution = ({})
                    root.resolutionAction = ({})
                } else {
                    root.resolutionValidationError = String(
                        state.message || "Server từ chối resolution."
                    )
                }
            } else if (terminal && name === "incident.mute") {
                muteForm.finishPending(Boolean(state.ok), state.message)
                if (Boolean(state.ok)) root.pendingMute = ({})
                else root.muteValidationError = String(
                    state.message || "Server từ chối tạm ẩn cảnh báo."
                )
            }
        }
    }

    Alerts.AlertsDialog {
        id: ruleManager
        objectName: "incidentRuleManager"
        modal: true
        width: 940
        height: 650
        title: root.ruleEditorMode === "create"
            ? "Tạo quy tắc sự cố" : "Sửa quy tắc " + root.selectedRuleKey
        standardButtons: Dialog.NoButton
        contentItem: RowLayout {
            spacing: 12
            Panel {
                Layout.preferredWidth: 278
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    Text {
                        Layout.fillWidth: true
                        text: "QUY TẮC HIỆN TẠI"
                        color: Theme.textFaint
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentWidth: availableWidth
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ColumnLayout {
                            width: parent.width
                            spacing: 6
                            Repeater {
                                model: (root.rules || {}).items || []
                                delegate: Rectangle {
                                    id: ruleRow
                                    required property int index
                                    required property var modelData
                                    readonly property string ruleKey: String(
                                        ruleRow.modelData.rule_key || ""
                                    )
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 136
                                    radius: Theme.radiusMedium
                                    color: root.selectedRuleKey === ruleRow.ruleKey
                                        ? Theme.accentSoft : Theme.elevated
                                    border.width: 1
                                    border.color: root.selectedRuleKey === ruleRow.ruleKey
                                        ? Theme.accent : Theme.borderSoft
                                    Accessible.role: Accessible.ListItem
                                    Accessible.name: String(
                                        ruleRow.modelData.name || ruleRow.ruleKey
                                    ) + ", phiên bản " + String(
                                        ruleRow.modelData.version || "—"
                                    )
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 3
                                        Text {
                                            Layout.fillWidth: true
                                            text: String(ruleRow.modelData.name || ruleRow.ruleKey)
                                            color: Theme.text
                                            font.pixelSize: 12
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: ruleRow.ruleKey + " · v"
                                                + String(ruleRow.modelData.version || "—")
                                            color: Theme.textFaint
                                            font.pixelSize: 11
                                            elide: Text.ElideMiddle
                                        }
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            AppButton {
                                                readonly property var descriptor:
                                                    ((ruleRow.modelData.actions || {}).revise || ({}))
                                                objectName: "incidentRuleEdit_" + ruleRow.ruleKey
                                                Layout.fillWidth: true
                                                text: String(descriptor.label || "Sửa")
                                                leadingIcon: String(descriptor.icon_key || "")
                                                subtle: true
                                                activeFocusOnTab: true
                                                enabled: Boolean(descriptor.available)
                                                    && !root.ruleBusy(
                                                        String(descriptor.capability || ""),
                                                        ruleRow.ruleKey
                                                    )
                                                availabilityReason: String(descriptor.reason_code || "")
                                                Accessible.name: "Sửa quy tắc " + ruleRow.ruleKey
                                                onClicked: root.openRuleRevision(ruleRow.ruleKey)
                                            }
                                            AppButton {
                                                readonly property var descriptor:
                                                    ((ruleRow.modelData.actions || {}).archive || ({}))
                                                objectName: "incidentRuleArchive_" + ruleRow.ruleKey
                                                Layout.fillWidth: true
                                                text: String(descriptor.label || "Lưu trữ")
                                                leadingIcon: String(descriptor.icon_key || "")
                                                subtle: true
                                                activeFocusOnTab: true
                                                enabled: Boolean(descriptor.available)
                                                    && !root.ruleBusy(
                                                        String(descriptor.capability || ""),
                                                        ruleRow.ruleKey
                                                    )
                                                availabilityReason: String(descriptor.reason_code || "")
                                                Accessible.name: "Lưu trữ quy tắc " + ruleRow.ruleKey
                                                onClicked: root.prepareRuleArchive(ruleRow.ruleKey)
                                            }
                                        }
                                    }
                                }
                            }
                            Text {
                                visible: ((root.rules || {}).items || []).length === 0
                                Layout.fillWidth: true
                                text: "Chưa có rule được server projection."
                                color: Theme.textFaint
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                    AppButton {
                        readonly property var descriptor:
                            ((root.rules.actions || {}).create || ({}))
                        objectName: "incidentRuleNewButton"
                        Layout.fillWidth: true
                        text: String(descriptor.label || "Quy tắc mới")
                        leadingIcon: String(descriptor.icon_key || "")
                        primary: root.ruleEditorMode === "create"
                        activeFocusOnTab: true
                        enabled: Boolean(descriptor.available)
                        availabilityReason: String(descriptor.reason_code || "")
                        Accessible.name: text
                        onClicked: {
                            root.ruleEditorMode = "create"
                            root.selectedRuleKey = ""
                            root.resetRuleEditor()
                            root.ruleMutationAction = descriptor
                        }
                    }
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ColumnLayout {
                    width: parent.width
                    spacing: 9
                    Text {
                        Layout.fillWidth: true
                        text: root.ruleEditorMode === "create"
                            ? "Định nghĩa declarative mới"
                            : "Tạo phiên bản bất biến tiếp theo"
                        color: Theme.text
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Alerts.AlertsTextField {
                            id: ruleKeyField
                            objectName: "incidentRuleKeyField"
                            Layout.fillWidth: true
                            placeholderText: "rule-key semantic"
                            readOnly: root.ruleEditorMode === "revise"
                            activeFocusOnTab: true
                            Accessible.name: "Định danh quy tắc"
                        }
                        Alerts.AlertsTextField {
                            id: ruleNameField
                            objectName: "incidentRuleNameField"
                            Layout.fillWidth: true
                            placeholderText: "Tên quy tắc"
                            activeFocusOnTab: true
                            Accessible.name: "Tên quy tắc"
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Alerts.AlertsComboBox {
                            id: ruleSourceField
                            objectName: "incidentRuleSourceField"
                            Layout.fillWidth: true
                            model: root.ruleCatalog.sources || []
                            textRole: "label"
                            valueRole: "key"
                            enabled: count > 0
                            availabilityReason: enabled
                                ? "" : "INCIDENT_RULE_SOURCE_CATALOG_UNAVAILABLE"
                            activeFocusOnTab: true
                            Accessible.name: "Nguồn sự cố của quy tắc"
                        }
                        Alerts.AlertsTextField {
                            id: ruleEventTypeField
                            objectName: "incidentRuleEventTypeField"
                            Layout.fillWidth: true
                            placeholderText: "Event types, phân cách dấu phẩy"
                            activeFocusOnTab: true
                            Accessible.name: "Event types của quy tắc"
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Alerts.AlertsTextField {
                            id: ruleCodeField
                            objectName: "incidentRuleCodeField"
                            Layout.fillWidth: true
                            placeholderText: "Error codes, phân cách dấu phẩy"
                            activeFocusOnTab: true
                            Accessible.name: "Mã sự cố của quy tắc"
                        }
                        GridLayout {
                            objectName: "incidentRuleSeverityField"
                            Layout.fillWidth: true
                            columns: 2
                            Accessible.name: "Mức độ điều kiện của quy tắc"
                            Repeater {
                                model: root.ruleCatalog.severities || []
                                delegate: Alerts.AlertsCheckDelegate {
                                    id: severityRuleOption
                                    required property int index
                                    required property var modelData
                                    readonly property string severityKey:
                                        String(severityRuleOption.modelData.key || "")
                                    objectName: "incidentRuleSeverity_" + severityKey
                                    text: String(severityRuleOption.modelData.label || severityKey)
                                    checked: root.ruleSeveritySelection.indexOf(severityKey) >= 0
                                    activeFocusOnTab: true
                                    Accessible.name: text
                                    onToggled: root.toggleRuleSelection(
                                        "severity", severityKey, checked
                                    )
                                }
                            }
                        }
                        Alerts.AlertsTextField {
                            id: ruleEntityTypeField
                            objectName: "incidentRuleEntityTypeField"
                            Layout.fillWidth: true
                            placeholderText: "Entity types"
                            activeFocusOnTab: true
                            Accessible.name: "Loại đối tượng của quy tắc"
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Alerts.AlertsCheckDelegate {
                            id: ruleEnabled
                            objectName: "incidentRuleEnabled"
                            text: "Bật rule"
                            checked: true
                            activeFocusOnTab: true
                            Accessible.name: text
                        }
                        ColumnLayout {
                            spacing: 2
                            Text { text: "Priority"; color: Theme.textFaint; font.pixelSize: 11 }
                            Alerts.AlertsSpinBox {
                                id: rulePriority
                                objectName: "incidentRulePriorityField"
                                from: Number((root.ruleCatalog.limits || {}).priority
                                    ? root.ruleCatalog.limits.priority.minimum : 0)
                                to: Number((root.ruleCatalog.limits || {}).priority
                                    ? root.ruleCatalog.limits.priority.maximum : 0)
                                value: 100
                                activeFocusOnTab: true
                                Accessible.name: "Priority của quy tắc"
                            }
                        }
                        ColumnLayout {
                            spacing: 2
                            Text { text: "Dedupe (giây)"; color: Theme.textFaint; font.pixelSize: 11 }
                            Alerts.AlertsSpinBox {
                                id: ruleDedupe
                                objectName: "incidentRuleDedupeField"
                                from: Number((root.ruleCatalog.limits || {}).dedupe_window_seconds
                                    ? root.ruleCatalog.limits.dedupe_window_seconds.minimum : 0)
                                to: Number((root.ruleCatalog.limits || {}).dedupe_window_seconds
                                    ? root.ruleCatalog.limits.dedupe_window_seconds.maximum : 0)
                                value: 300
                                activeFocusOnTab: true
                                Accessible.name: "Cửa sổ dedupe của quy tắc"
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { text: "SLA (giây)"; color: Theme.textFaint; font.pixelSize: 11 }
                            Alerts.AlertsSpinBox {
                                id: ruleSla
                                objectName: "incidentRuleSlaField"
                                Layout.fillWidth: true
                                from: Number((root.ruleCatalog.limits || {}).sla_seconds
                                    ? root.ruleCatalog.limits.sla_seconds.minimum : 0)
                                to: Number((root.ruleCatalog.limits || {}).sla_seconds
                                    ? root.ruleCatalog.limits.sla_seconds.maximum : 0)
                                value: 14400
                                activeFocusOnTab: true
                                Accessible.name: "SLA của quy tắc"
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { text: "Mute (giây)"; color: Theme.textFaint; font.pixelSize: 11 }
                            Alerts.AlertsSpinBox {
                                id: ruleMute
                                objectName: "incidentRuleMuteField"
                                Layout.fillWidth: true
                                from: Number((root.ruleCatalog.limits || {}).mute_for_seconds
                                    ? root.ruleCatalog.limits.mute_for_seconds.minimum : 0)
                                to: Number((root.ruleCatalog.limits || {}).mute_for_seconds
                                    ? root.ruleCatalog.limits.mute_for_seconds.maximum : 0)
                                value: 0
                                activeFocusOnTab: true
                                Accessible.name: "Thời hạn mute tự động của quy tắc"
                            }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                    Text { text: "ESCALATION"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                    RowLayout {
                        Layout.fillWidth: true
                        Alerts.AlertsCheckDelegate {
                            id: ruleEscalationEnabled
                            objectName: "incidentRuleEscalationEnabled"
                            text: "Escalate theo thời hạn"
                            activeFocusOnTab: true
                            Accessible.name: text
                        }
                        Alerts.AlertsSpinBox {
                            id: ruleEscalationAfter
                            objectName: "incidentRuleEscalationAfterField"
                            from: Number((root.ruleCatalog.limits || {}).escalation_after_seconds
                                ? root.ruleCatalog.limits.escalation_after_seconds.minimum : 0)
                            to: Number((root.ruleCatalog.limits || {}).escalation_after_seconds
                                ? root.ruleCatalog.limits.escalation_after_seconds.maximum : 0)
                            value: 1800
                            enabled: ruleEscalationEnabled.checked
                            availabilityReason: enabled ? ""
                                : "Bật Escalate theo thời hạn để chỉnh thời gian"
                            activeFocusOnTab: true
                            Accessible.name: "Số giây trước escalation"
                        }
                        Alerts.AlertsComboBox {
                            id: ruleEscalationSeverity
                            objectName: "incidentRuleEscalationSeverity"
                            model: root.ruleCatalog.severities || []
                            textRole: "label"
                            valueRole: "key"
                            popupWidth: 220
                            enabled: ruleEscalationEnabled.checked
                            availabilityReason: enabled ? ""
                                : "Bật Escalate theo thời hạn để chọn mức độ"
                            activeFocusOnTab: true
                            Accessible.name: "Mức độ escalation"
                        }
                    }
                    Text { text: "SAFE RECOVERY ALLOW-LIST"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        Repeater {
                            model: root.ruleCatalog.recovery_capabilities || []
                            delegate: Alerts.AlertsCheckDelegate {
                                id: recoveryOption
                                required property int index
                                required property var modelData
                                readonly property string capabilityKey:
                                    String(recoveryOption.modelData.key || "")
                                objectName: "incidentRecovery_" + capabilityKey
                                text: String(recoveryOption.modelData.label || capabilityKey)
                                checked: root.ruleRecoverySelection.indexOf(capabilityKey) >= 0
                                activeFocusOnTab: true
                                Accessible.name: text
                                onToggled: root.toggleRuleSelection(
                                    "recovery", capabilityKey, checked
                                )
                            }
                        }
                    }
                    Text {
                        visible: root.ruleValidationError.length > 0
                        Layout.fillWidth: true
                        text: root.ruleValidationError
                        color: Theme.danger
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
        footer: Rectangle {
            objectName: "incidentRuleManagerFooter"
            implicitHeight: 62
            color: Theme.panel
            border.width: 1
            border.color: Theme.borderSoft
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                anchors.topMargin: 10
                anchors.bottomMargin: 10
                spacing: 8
                Item { Layout.fillWidth: true }
                AppButton {
                    objectName: "incidentRuleManagerCloseButton"
                    text: "Đóng"
                    activeFocusOnTab: true
                    onClicked: ruleManager.close()
                }
                AppButton {
                    objectName: "incidentRuleSubmitButton"
                    text: root.ruleEditorMode === "create"
                        ? "Kiểm tra & tạo" : "Kiểm tra & tạo version"
                    primary: true
                    activeFocusOnTab: true
                    enabled: Boolean(root.ruleMutationAction.available)
                        && !ruleManager.pending
                    availabilityReason: ruleManager.pending
                        ? "Lệnh rule đang được server xử lý"
                        : String(root.ruleMutationAction.reason_code || "")
                    Accessible.name: text
                    onClicked: root.ruleEditorMode === "create"
                        ? root.prepareRuleCreate() : root.prepareRuleRevision()
                }
            }
        }
        background: Rectangle {
            objectName: "incidentRuleManagerBackground"
            radius: Theme.radiusLarge
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }

    Foundation.ConfirmDialog {
        id: ruleMutationConfirm
        objectName: "incidentRuleMutationConfirm"
        title: root.ruleMutationCapability === "incident.rule.create"
            ? "Xác nhận tạo quy tắc" : "Xác nhận tạo phiên bản quy tắc"
        message: "Server sẽ ghi một phiên bản rule bất biến và áp dụng CAS khi revise."
        confirmText: "Xác nhận"
        onAccepted: root.confirmRuleMutation()
    }
    Foundation.ConfirmDialog {
        id: ruleArchiveConfirm
        objectName: "incidentRuleArchiveConfirm"
        title: "Xác nhận lưu trữ quy tắc"
        message: "Lưu trữ tạo một phiên bản disabled mới; lịch sử cũ không bị xóa."
        confirmText: "Lưu trữ"
        destructive: true
        onAccepted: root.confirmRuleArchive()
    }

    Alerts.AlertsDialog {
        id: severityForm
        objectName: "incidentSeverityForm"
        modal: true
        width: 460
        title: "Đổi mức độ sự cố"
        standardButtons: Dialog.NoButton
        contentItem: ColumnLayout {
            spacing: 9
            Alerts.AlertsComboBox {
                id: severityCombo
                objectName: "incidentSeverityCombo"
                Layout.fillWidth: true
                model: root.ruleCatalog.severities || []
                textRole: "label"
                valueRole: "key"
                activeFocusOnTab: true
                Accessible.name: "Mức độ mới của sự cố"
            }
            Alerts.AlertsTextField {
                id: severityReason
                objectName: "incidentSeverityReasonField"
                Layout.fillWidth: true
                placeholderText: "Lý do audit"
                activeFocusOnTab: true
                Accessible.name: "Lý do đổi mức độ"
            }
            Text {
                visible: root.severityValidationError.length > 0
                Layout.fillWidth: true
                text: root.severityValidationError
                color: Theme.danger
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                AppButton { objectName: "incidentSeverityCancelButton"; text: "Hủy"; activeFocusOnTab: true; onClicked: severityForm.close() }
                AppButton {
                    objectName: "incidentSeveritySubmitButton"
                    text: "Tiếp tục xác nhận"
                    primary: true
                    activeFocusOnTab: true
                    Accessible.name: text
                    onClicked: root.prepareSeverityChange()
                }
            }
        }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }
    Foundation.ConfirmDialog {
        id: severityConfirm
        objectName: "incidentSeverityConfirm"
        title: "Xác nhận đổi mức độ"
        message: "Thao tác dùng incident version hiện tại và sẽ fail nếu incident đã thay đổi."
        confirmText: "Đổi mức độ"
        onAccepted: root.confirmSeverityChange()
    }

    Alerts.AlertsDialog {
        id: bulkForm
        objectName: "incidentBulkForm"
        modal: true
        width: 520
        title: root.bulkOperation === "resolve"
            ? "Chuẩn bị giải quyết hàng loạt" : "Chuẩn bị đổi mức độ hàng loạt"
        standardButtons: Dialog.NoButton
        contentItem: ColumnLayout {
            spacing: 9
            Text {
                Layout.fillWidth: true
                text: "Đã chọn " + String(root.selectedCount)
                    + " incident. Server sẽ preview lại từng ID/version."
                color: Theme.textMuted
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            Alerts.AlertsTextField {
                id: bulkResolutionCode
                objectName: "incidentBulkResolutionCodeField"
                visible: root.bulkOperation === "resolve"
                Layout.fillWidth: true
                placeholderText: "Resolution code"
                activeFocusOnTab: true
                Accessible.name: "Mã giải quyết hàng loạt"
            }
            Alerts.AlertsTextArea {
                id: bulkResolutionNote
                objectName: "incidentBulkResolutionNoteField"
                visible: root.bulkOperation === "resolve"
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 84 : 0
                placeholderText: "Ghi chú/evidence audit áp dụng cho selection"
                activeFocusOnTab: true
                Accessible.name: "Ghi chú giải quyết hàng loạt"
            }
            Alerts.AlertsComboBox {
                id: bulkSeverityCombo
                objectName: "incidentBulkSeverityCombo"
                visible: root.bulkOperation === "change_severity"
                Layout.fillWidth: true
                model: root.ruleCatalog.severities || []
                textRole: "label"
                valueRole: "key"
                activeFocusOnTab: true
                Accessible.name: "Mức độ mới hàng loạt"
            }
            Alerts.AlertsTextField {
                id: bulkSeverityReason
                objectName: "incidentBulkSeverityReasonField"
                visible: root.bulkOperation === "change_severity"
                Layout.fillWidth: true
                placeholderText: "Lý do audit"
                activeFocusOnTab: true
                Accessible.name: "Lý do đổi mức độ hàng loạt"
            }
            Text {
                visible: root.bulkValidationError.length > 0
                Layout.fillWidth: true
                text: root.bulkValidationError
                color: Theme.danger
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                AppButton { objectName: "incidentBulkCancelButton"; text: "Hủy"; activeFocusOnTab: true; onClicked: bulkForm.close() }
                AppButton {
                    objectName: "incidentBulkPreviewSubmitButton"
                    text: "Tạo preview"
                    primary: true
                    activeFocusOnTab: true
                    Accessible.name: text
                    onClicked: root.requestBulkPreview()
                }
            }
        }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }
    Foundation.ConfirmDialog {
        id: bulkExecutionConfirm
        objectName: "incidentBulkExecutionConfirm"
        title: "Xác nhận thực thi hàng loạt"
        message: "Server preview xác nhận "
            + String((root.pendingBulkBatch || {}).eligible_count || 0)
            + " incident đủ điều kiện trong "
            + String(((root.pendingBulkBatch || {}).preview_rows || []).length)
            + " dòng. Chỉ các dòng vẫn đúng version mới được ghi."
        confirmText: "Thực thi"
        destructive: root.bulkOperation === "resolve"
        onAccepted: root.confirmBulkExecution()
    }

    Alerts.AlertsDialog {
        id: resolutionForm
        objectName: "incidentResolutionForm"
        modal: true
        width: 520
        title: "Giải quyết sự cố"
        standardButtons: Dialog.NoButton
        contentItem: ColumnLayout {
            spacing: 9
            Alerts.AlertsTextField {
                id: resolutionCode
                objectName: "incidentResolutionCodeField"
                Layout.fillWidth: true
                placeholderText: "Mã giải quyết, ví dụ RENDER_RECIPE_FIXED"
                activeFocusOnTab: true
                Accessible.name: "Mã giải quyết sự cố"
            }
            Alerts.AlertsTextArea {
                id: resolutionNote
                objectName: "incidentResolutionNoteField"
                Layout.fillWidth: true
                Layout.preferredHeight: 84
                placeholderText: "Ghi chú xác minh"
                activeFocusOnTab: true
                Accessible.name: "Ghi chú giải quyết"
            }
            RowLayout {
                Layout.fillWidth: true
                Alerts.AlertsTextField {
                    id: resolutionEvidenceType
                    objectName: "incidentResolutionEvidenceTypeField"
                    Layout.fillWidth: true
                    placeholderText: "Loại evidence"
                    activeFocusOnTab: true
                    Accessible.name: "Loại bằng chứng"
                }
                Alerts.AlertsTextField {
                    id: resolutionEvidenceId
                    objectName: "incidentResolutionEvidenceIdField"
                    Layout.fillWidth: true
                    placeholderText: "Evidence ID"
                    activeFocusOnTab: true
                    Accessible.name: "Định danh bằng chứng"
                }
            }
            Text {
                visible: root.resolutionValidationError.length > 0
                Layout.fillWidth: true
                text: root.resolutionValidationError
                color: Theme.danger
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                AppButton { objectName: "incidentResolutionCancelButton"; text: "Hủy"; activeFocusOnTab: true; onClicked: resolutionForm.close() }
                AppButton {
                    objectName: "incidentResolutionSubmitButton"
                    text: "Tiếp tục xác nhận"
                    primary: true
                    activeFocusOnTab: true
                    Accessible.name: text
                    onClicked: root.prepareResolution()
                }
            }
        }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }

    Alerts.AlertsDialog {
        id: muteForm
        objectName: "incidentMuteForm"
        modal: true
        width: 500
        title: "Tạm ẩn cảnh báo có thời hạn"
        standardButtons: Dialog.NoButton
        contentItem: ColumnLayout {
            spacing: 9
            Alerts.AlertsComboBox {
                id: muteScope
                objectName: "incidentMuteScopeFilter"
                Layout.fillWidth: true
                model: []
                visible: false
                enabled: visible
                activeFocusOnTab: true
                Accessible.name: "Phạm vi tạm ẩn"
            }
            Alerts.AlertsTextField {
                id: muteReason
                objectName: "incidentMuteReasonField"
                Layout.fillWidth: true
                placeholderText: "Lý do audit"
                activeFocusOnTab: true
                Accessible.name: "Lý do tạm ẩn"
            }
            Alerts.AlertsTextField {
                id: muteExpiry
                objectName: "incidentMuteExpiryField"
                Layout.fillWidth: true
                placeholderText: "ISO-8601 có timezone, tối đa 30 ngày"
                activeFocusOnTab: true
                Accessible.name: "Thời hạn tạm ẩn"
            }
            Text {
                visible: root.muteValidationError.length > 0
                Layout.fillWidth: true
                text: root.muteValidationError
                color: Theme.danger
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                AppButton { objectName: "incidentMuteCancelButton"; text: "Hủy"; activeFocusOnTab: true; onClicked: muteForm.close() }
                AppButton {
                    objectName: "incidentMuteSubmitButton"
                    text: "Tiếp tục xác nhận"
                    primary: true
                    activeFocusOnTab: true
                    Accessible.name: text
                    onClicked: root.prepareMute()
                }
            }
        }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }

    Foundation.ConfirmDialog {
        id: resolutionConfirm
        objectName: "incidentResolutionConfirmDialog"
        title: "Xác nhận giải quyết sự cố"
        message: "Resolution sẽ được server ghi lịch sử và đóng episode hiện tại. Tiếp tục?"
        confirmText: "Giải quyết"
        destructive: true
        onAccepted: root.confirmResolution()
    }
    Foundation.ConfirmDialog {
        id: muteConfirm
        objectName: "incidentMuteConfirmDialog"
        title: "Xác nhận tạm ẩn cảnh báo"
        message: "Tạm ẩn không xóa incident nhưng sẽ suppress attention trong phạm vi và thời hạn đã chọn."
        confirmText: "Tạm ẩn"
        destructive: true
        onAccepted: root.confirmMute()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.embeddedMode ? 0 : 14
        spacing: 10

        Alerts.IncidentHeader {
            Layout.fillWidth: true
            Layout.preferredHeight: 152
            header: root.header
            summary: root.summary
            rules: root.rules
            canWrite: root.canWrite
            canManageRules: root.canManageRules
            ruleBusy: root.ruleMutationCapability.length > 0
                && root.ruleBusy(root.ruleMutationCapability,
                    String((root.pendingRuleCommand || {}).rule_key || ""))
            muteBusy: root.muteCommandBusy
            onActionRequested: function(action) { root.handleHeaderAction(action) }
        }

        Foundation.AsyncStateView {
            id: alertsStateView
            objectName: "alertsAsyncState"
            Layout.fillWidth: true
            Layout.fillHeight: true
            viewState: root.viewState
            hasData: root.hasProjectionData()
            accessibleName: "Nội dung trung tâm sự cố"
            emptyTitle: "Không có sự cố"
            emptyDescription: "Incident projection hiện không có bản ghi phù hợp."
            errorMessage: String((root.snapshotError || {}).message || "Không thể tải Incident Center.")
            requiredPermission: "incident.read"
            freshnessBannerEnabled: false
            onRetry: root.retrySnapshot()

            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                Rectangle {
                    id: alertsSourceStatus
                    objectName: "alertsSourceStatus"
                    visible: alertsStateView.showFreshnessBanner
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? 44 : 0
                    radius: Theme.radiusSmall
                    color: Theme.warningSoft
                    border.width: 1
                    border.color: Theme.warning
                    Accessible.role: Accessible.AlertMessage
                    Accessible.name: sourceStatusText.text
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 8
                        spacing: 8
                        UiIcon {
                            name: "semantic/alert-triangle"
                            tone: Theme.warning
                            iconSize: 17
                        }
                        Text {
                            id: sourceStatusText
                            Layout.fillWidth: true
                            text: root.viewState === "offline"
                                ? "Ngoại tuyến · đang dùng snapshot gần nhất; tránh quyết định dựa trên dữ liệu thời gian thực."
                                : root.viewState === "stale"
                                    ? "Dữ liệu có thể đã cũ · kiểm tra heartbeat hệ thống trước khi xử lý."
                                    : root.viewState === "error"
                                        ? "Làm mới thất bại · snapshot gần nhất vẫn được giữ để đối soát."
                                        : String((root.subsystemHealth.status_descriptor || {}).detail
                                            || "Một phần nguồn giám sát chưa sẵn sàng; mở chi tiết hệ thống để kiểm tra.")
                            color: Theme.warning
                            font.pixelSize: Theme.fontMetadata
                            elide: Text.ElideRight
                        }
                        AppButton {
                            objectName: "alertsSourceStatusDetails"
                            text: "Kiểm tra nguồn"
                            leadingIcon: "semantic/info"
                            subtle: true
                            onClicked: root.executeProjectedAction(
                                ((root.subsystemHealth.actions || {}).system_details || ({})))
                        }
                    }
                }
                Rectangle {
                    objectName: "incidentCommandOutcome"
                    visible: root.commandOutcomeText.length > 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? 38 : 0
                    radius: Theme.radiusSmall
                    color: root.commandOutcomeOk
                        ? Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.10)
                        : Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.10)
                    border.width: 1
                    border.color: root.commandOutcomeOk ? Theme.success : Theme.danger
                    Accessible.role: Accessible.StaticText
                    Accessible.name: root.commandOutcomeText
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 6
                        Text {
                            Layout.fillWidth: true
                            text: root.commandOutcomeText
                            color: root.commandOutcomeOk ? Theme.success : Theme.danger
                            font.pixelSize: Theme.fontMetadata
                            elide: Text.ElideRight
                        }
                        Foundation.IconButton {
                            objectName: "incidentCommandOutcomeDismiss"
                            iconName: "ui/close"
                            accessibleName: "Đóng thông báo kết quả"
                            onClicked: root.commandOutcomeText = ""
                        }
                    }
                }
                Rectangle {
                    objectName: "incidentBulkStatus"
                    visible: root.bulkStatusText.length > 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? 40 : 0
                    radius: Theme.radiusSmall
                    color: root.bulkValidationError.length > 0
                        ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.10)
                        : Theme.accentSoft
                    border.width: 1
                    border.color: root.bulkValidationError.length > 0
                        ? Theme.danger : Theme.borderSoft
                    Accessible.role: Accessible.StaticText
                    Accessible.name: root.bulkStatusText
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 8
                        spacing: 8
                        Text {
                            Layout.fillWidth: true
                            text: root.bulkStatusText
                            color: root.bulkValidationError.length > 0
                                ? Theme.danger : Theme.textMuted
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                        AppButton {
                            objectName: "incidentBulkReopenConfirm"
                            visible: root.bulkFlowState === "awaiting_confirmation"
                                || root.bulkFlowState === "execute_failed"
                            text: root.bulkFlowState === "execute_failed"
                                ? "Thử execute lại" : "Xem preview"
                            activeFocusOnTab: true
                            Accessible.name: text
                            onClicked: root.reopenBulkExecution()
                        }
                        AppButton {
                            objectName: "incidentBulkRetryPreview"
                            visible: root.bulkFlowState === "preview_failed"
                            text: "Thử preview lại"
                            activeFocusOnTab: true
                            Accessible.name: text
                            onClicked: root.requestBulkPreview()
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10
                    Alerts.IncidentInbox {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        inbox: root.inbox
                        incidentModel: root.incidentModel
                        filters: root.filters
                        page: root.snapshotPage
                        selectedIncidentId: root.selectedIncidentId
                        selectedIncidentIds: root.selectedIncidentIds
                        canWrite: root.canWrite
                        canResolve: root.canResolve
                        bulkBusy: root.bulkLocked
                        onIncidentSelected: function(incidentId) { root.selectIncident(incidentId) }
                        onIncidentChecked: function(incidentId, checked) { root.setIncidentChecked(incidentId, checked) }
                        onSelectVisibleRequested: function(checked) { root.selectVisibleIncidents(checked) }
                        onClearSelectionRequested: root.selectedIncidentIds = []
                        onSnapshotRequested: function(query) { root.requestSnapshot(query) }
                        onBulkRequested: function(operation) {
                            root.startBulkOperation(operation)
                        }
                    }
                    Alerts.IncidentInspector {
                        Layout.preferredWidth: Math.max(600, alertsStateView.width * 0.40)
                        Layout.fillHeight: true
                        inspector: root.inspector
                        incident: root.selectedIncident
                        occurrences: root.selectedOccurrences
                        resolution: root.selectedResolution
                        detailAvailable: root.inspectorDetailAvailable
                        canWrite: root.canWrite
                        canResolve: root.canResolve
                        controlPlaneBridge: root.plane
                        commandRevision: root.commandRevision
                        onActionRequested: function(action) {
                            root.executeProjectedAction(action)
                        }
                    }
                }
                Alerts.SubsystemHealthStrip {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 114
                    health: root.subsystemHealth
                    healthModel: root.healthModel
                    onActionRequested: function(action) {
                        root.executeProjectedAction(action)
                    }
                }
            }
        }
    }
}
