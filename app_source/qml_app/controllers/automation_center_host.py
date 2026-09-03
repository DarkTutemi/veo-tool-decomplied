"""
Decompiled / Reconstructed Module: qml_app.controllers.automation_center_host

Docstring:
Tool 1-owned host for the in-process Automation Center tab.

The host is deliberately dormant at construction time: it does not touch the
database, native workflow queues, or a worker thread until ``start`` is called.
All AutomationCenterService work is serialized on one registered executor and
returned to Qt through a queued signal.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AutomationCenterHost']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
UTC = datetime.timezone.utc
_ACTIVE_STATES = {'starting', 'leased', 'queued', 'running', 'assigned', 'pausing', 'paused', 'retryable', 'cancelling'}
_MAX_PROFILE_IMPORT_BYTES = 2000000
_MAX_PROFILE_IMPORT_ROWS = 1000
_MAX_FROZEN_PROFILE_IMPORTS = 32
_SAFE_PROFILE_ID = re.compile('^[A-Za-z0-9_-]{1,128}$')
_STATUS_LABELS = {'assigned': 'Đã tiếp nhận', 'queued': 'Đang chờ', 'leased': 'Đã giữ lượt chạy', 'starting': 'Đang khởi động', 'dispatching': 'Đang giao việc', 'publishing': 'Đang đăng', 'running': 'Đang chạy', 'paus... [truncated]
_ROUTE_ALIASES = {'': 'today', 'overview': 'today', 'assignment': 'distribution', 'runs': 'distribution', 'profiles': 'channels_devices', 'production': 'studio'}
_ROUTE_PAGES = {'today': 0, 'coordination': 0, 'alerts': 0, 'agent': 0, 'content': 1, 'studio': 2, 'distribution': 3, 'automation': 3, 'schedule': 3, 'channels_devices': 4, 'channels': 4, 'reports': 5, 'settings': 6... [truncated]
__all__ = ['AutomationCenterHost']

# --- Class: AutomationCenterRunModel ---
class AutomationCenterRunModel(QAbstractListModel):
    """Stable list model with atomic structural swaps and narrow row updates."""
    _MODEL_DATA_ROLE = 257
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterRunModel" inherits "QAbstractListModel":
Properties:
  #1 "count", int [desi...

    countChanged = Signal()
    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    def roleNames(self) -> "dict[int, __assert_armored__((QtCore, b'\\x81\\xb4\\xb9\\x0cH\\xb4\\xdfT\\xa5(\\xb4'))]":
        # [PyArmor BCC constants]: '_MODEL_DATA_ROLE', 'QtCore', 'QByteArray'
        pass

    def rowCount(self, parent: 'QtCore.QModelIndex' = <PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x000001DFC250D240>) -> 'int':
        # [PyArmor BCC constants]: 'isValid', 0, 'len', '_rows'
        pass

    def data(self, index: 'QtCore.QModelIndex', role: 'int' = 0) -> 'Any':
        # [PyArmor BCC constants]: 'isValid', 0, 'row', 'len', '_rows', 'int', 'QtCore', 'Qt', 'ItemDataRole', 'DisplayRole', '_MODEL_DATA_ROLE', 'dict'
        pass

    def count(*args, **kwargs):
        pass

    def get(self, index: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 0, 'int', 'len', '_rows', 'dict'
        pass

    def setRows(self, rows: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'AutomationCenterRunModel.setRows', 'isinstance', 'Mapping', '_copy_row', '_rows', 'len', '_identity', 'beginResetModel', 'endResetModel', 'countChanged', 'emit', 1, 'enumerate', 'zip'
        pass

    def rows(self) -> 'list[dict[str, Any]]':
        pass


# --- Class: AutomationCenterChannelProfileModel ---
class AutomationCenterChannelProfileModel(_SnapshotListModel):
    """Versioned production settings keyed by semantic social channel."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterChannelProfileModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'channelProfileId', 'label', 'platform', 'channelId', 'socialProfileId', 'channelBindingId', 'channelBindingVersion', 'channelBindingHash', 'version', 'configHash', 'language', 'audience', 'positioning', 'characterIds', 'voiceId'
        pass


# --- Class: AutomationCenterAttentionModel ---
class AutomationCenterAttentionModel(_SnapshotListModel):
    """Unified unresolved work-order and schedule cases."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterAttentionModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'caseId', 'caseType', 'orderId', 'stepId', 'occurrenceId', 'recurrenceId', 'title', 'platform', 'channelId', 'stepKind', 'errorCode', 'errorMessage', 'details', 'actions', 'createdAt'
        pass


# --- Class: AutomationCenterCopilotContentModel ---
class AutomationCenterCopilotContentModel(_SnapshotListModel):
    """Current-revision content plan ready for review and assignment."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterCopilotContentModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'contentItemId', 'projectId', 'revision', 'position', 'title', 'angle', 'workflow', 'workflowLabel', 'inputMode', 'sourceId', 'content', 'rationale', 'caption', 'readiness', 'readinessLabel'
        pass


# --- Class: AutomationCenterCopilotMessageModel ---
class AutomationCenterCopilotMessageModel(_SnapshotListModel):
    """Ordered user/assistant conversation for the selected project."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterCopilotMessageModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'messageId', 'projectId', 'role', 'content', 'status', 'actionState', 'errorCode', 'errorMessage', 'conversationGeneration', 'createdAt', 'updatedAt'
        pass


# --- Class: AutomationCenterCopilotProjectModel ---
class AutomationCenterCopilotProjectModel(_SnapshotListModel):
    """Durable Channel Copilot projects, newest activity first."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterCopilotProjectModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'projectId', 'title', 'brief', 'status', 'statusLabel', 'activeRevision', 'approvedRevision', 'deliveryMode', 'platform', 'profileId', 'channelId', 'channelProfileId', 'channelProfileVersion', 'channelProfileHash', 'channelProfile'
        pass


# --- Class: AutomationCenterCopilotSourceModel ---
class AutomationCenterCopilotSourceModel(_SnapshotListModel):
    """Verified operator inputs available to the selected Copilot project."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterCopilotSourceModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'sourceId', 'projectId', 'position', 'workflow', 'workflowLabel', 'inputMode', 'inputModeLabel', 'title', 'content', 'status', 'statusLabel', 'errorCode', 'errorMessage', 'sourceHash', 'createdAt'
        pass


# --- Class: AutomationCenterOrderModel ---
class AutomationCenterOrderModel(_SnapshotListModel):
    """Newest-first work-order queue projection."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterOrderModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'orderId', 'title', 'status', 'statusLabel', 'totalSteps', 'completedSteps', 'progress', 'currentStepTitle', 'errorMessage', 'retryable', 'cancelRequested', 'cancelRequestedAt', 'definitionVersion', 'definitionHash', 'definitionSource'
        pass


# --- Class: AutomationCenterProfileModel ---
class AutomationCenterProfileModel(_SnapshotListModel):
    """Social publishing profiles without cookie or token material."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterProfileModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'profileId', 'channelId', 'platform', 'label', 'browserKey', 'proxyIdentity', 'timezoneName', 'status', 'statusLabel', 'busy', 'lastError', 'authState', 'authVerifiedAt', 'accountHandle', 'socialAccountId'
        pass


# --- Class: AutomationCenterPublishAttemptModel ---
class AutomationCenterPublishAttemptModel(_SnapshotListModel):
    """Bounded publish history with durable evidence and no provider payload."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterPublishAttemptModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'attemptId', 'profileId', 'platform', 'status', 'statusLabel', 'evidenceKind', 'externalPostId', 'postUrl', 'confirmation', 'evidencePath', 'evidenceSha256', 'errorCode', 'errorMessage', 'dispatchedAt', 'clickedAt'
        pass


# --- Class: AutomationCenterReferencePackModel ---
class AutomationCenterReferencePackModel(_SnapshotListModel):
    """Immutable research packs consumed by Channel Copilot planning."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterReferencePackModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'referencePackId', 'title', 'description', 'version', 'configHash', 'sourceCount', 'readyCount', 'invalidCount', 'sources', 'createdAt', 'updatedAt'
        pass


# --- Class: AutomationCenterScheduleCapacityModel ---
class AutomationCenterScheduleCapacityModel(_SnapshotListModel):
    """Latest immutable posting limits for each semantic channel."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterScheduleCapacityModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'policyId', 'policyKey', 'version', 'previousPolicyId', 'channelId', 'platform', 'timezone', 'dailyLimit', 'minimumGapMinutes', 'windows', 'configHash', 'state', 'createdAt', 'updatedAt'
        pass


# --- Class: AutomationCenterScheduleOccurrenceModel ---
class AutomationCenterScheduleOccurrenceModel(_SnapshotListModel):
    """Concrete conflict-gated occurrences with durable work-order lineage."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterScheduleOccurrenceModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'occurrenceId', 'occurrenceKey', 'recurrenceId', 'recurrenceKey', 'recurrenceVersion', 'localDate', 'localTime', 'scheduledAtUtc', 'timezone', 'durationSeconds', 'platform', 'channelId', 'profileId', 'capacityPolicyId', 'capacityPolicyKey'
        pass


# --- Class: AutomationCenterScheduleRecurrenceModel ---
class AutomationCenterScheduleRecurrenceModel(_SnapshotListModel):
    """Latest recurrence-rule versions, never executable by themselves."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterScheduleRecurrenceModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'recurrenceId', 'recurrenceKey', 'version', 'previousRecurrenceId', 'name', 'state', 'timezone', 'frequency', 'interval', 'weekdays', 'localTime', 'startsOn', 'endsOn', 'durationSeconds', 'platform'
        pass


# --- Class: AutomationCenterStepModel ---
class AutomationCenterStepModel(_SnapshotListModel):
    """Ordered timeline for the selected work order."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterStepModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'stepId', 'orderId', 'position', 'kind', 'workflow', 'title', 'status', 'statusLabel', 'jobId', 'attemptId', 'profileId', 'channelId', 'platform', 'deliveryMode', 'captionMode'
        pass


# --- Class: AutomationCenterHost ---
class AutomationCenterHost(QObject):
    """One-process Automation Center facade and embedded-workspace owner."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterHost" inherits "QObject":
Properties:
  #1 "runModel", QObject* [constant] [...

    busyChanged = Signal()
    initializedChanged = Signal()
    statsChanged = Signal()
    statusChanged = Signal()
    activeStateKnownChanged = Signal()
    capabilitiesChanged = Signal()
    executionChanged = Signal()
    selectedOrderChanged = Signal()
    profilePageChanged = Signal()
    publishAttemptPageChanged = Signal()
    schedulePageChanged = Signal()
    planDraftChanged = Signal()
    copilotChanged = Signal()
    localTimezoneChanged = Signal()
    workspaceActiveChanged = Signal()
    darkModeChanged = Signal()
    embeddedWorkspaceChanged = Signal()
    workspaceMountedChanged = Signal()
    workOrderCreated = Signal()
    socialProfileCreated = Signal()
    socialProfilesCreated = Signal()
    channelProfileSaved = Signal()
    referencePackSaved = Signal()
    operationCompleted = Signal()
    operationFailed = Signal()
    exitGuardRequested = Signal()
    _operationReady = Signal()
    _jobStorePush = Signal()
    _workspaceBridgeReady = Signal()
    _copilotStreamEvent = Signal()
    def __init__(self, service_factory: 'Callable[[], Any] | None' = None, qml_path: 'str | Path | None' = None, parent: 'QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'all', 'running', 'logged_in', 'attention'
        pass

    def runModel(*args, **kwargs):
        pass

    def orderModel(*args, **kwargs):
        pass

    def stepModel(*args, **kwargs):
        pass

    def allStepModel(*args, **kwargs):
        pass

    def profileModel(*args, **kwargs):
        pass

    def channelProfileModel(*args, **kwargs):
        pass

    def referencePackModel(*args, **kwargs):
        pass

    def publishAttemptModel(*args, **kwargs):
        pass

    def profilePage(*args, **kwargs):
        pass

    def publishAttemptPage(*args, **kwargs):
        pass

    def scheduleCapacityModel(*args, **kwargs):
        pass

    def scheduleRecurrenceModel(*args, **kwargs):
        pass

    def scheduleOccurrenceModel(*args, **kwargs):
        pass

    def attentionModel(*args, **kwargs):
        pass

    def scheduleOccurrencePage(*args, **kwargs):
        pass

    def attentionPage(*args, **kwargs):
        pass

    def copilotProjectModel(*args, **kwargs):
        pass

    def copilotMessageModel(*args, **kwargs):
        pass

    def copilotContentModel(*args, **kwargs):
        pass

    def copilotSourceModel(*args, **kwargs):
        pass

    def selectedOrderId(*args, **kwargs):
        pass

    def selectedOrder(*args, **kwargs):
        pass

    def planDraft(*args, **kwargs):
        pass

    def selectedCopilotProjectId(*args, **kwargs):
        pass

    def selectedCopilotProject(*args, **kwargs):
        pass

    def copilotStrategy(*args, **kwargs):
        pass

    def copilotRevision(*args, **kwargs):
        pass

    def localTimezone(*args, **kwargs):
        pass

    def workspaceActive(*args, **kwargs):
        pass

    def darkMode(*args, **kwargs):
        pass

    def embeddedWorkspace(*args, **kwargs):
        pass

    def workspaceMounted(*args, **kwargs):
        pass

    def busy(*args, **kwargs):
        pass

    def initialized(*args, **kwargs):
        pass

    def activeCount(*args, **kwargs):
        pass

    def totalCount(*args, **kwargs):
        pass

    def succeededCount(*args, **kwargs):
        pass

    def failedCount(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def activeStateKnown(*args, **kwargs):
        pass

    def capabilities(*args, **kwargs):
        pass

    def canSubmit(*args, **kwargs):
        pass

    def runActive(*args, **kwargs):
        pass

    def execution(*args, **kwargs):
        pass

    def attachEngine(self, engine: 'QObject', appController: 'QObject') -> 'None':
        # [PyArmor BCC constants]: '_engine', 'rootContext', 'setContextProperty', 'automationCenterHost', '_set_status', 'Không thể gắn Automation Center vào QML: ', 'Exception', '_app_controller', 'getattr', 'darkModeChanged', 'disconnect', '_sync_dark_mode', 'RuntimeError', 'TypeError', 'connect'
        pass

    def attachMainWindow(self, window: 'QObject') -> 'None':
        # [PyArmor BCC constants]: '_main_window', 'getattr', 'destroyed', 'connect', '_on_main_window_destroyed', 'RuntimeError', 'TypeError'
        pass

    def start(self) -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', '_started', True, '_set_status', 'Đang khởi tạo Automation Center…', 'refresh'
        pass

    def activateWorkspaceRoute(self, route: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', 'str', '', 'strip', '_pending_route', '_ensure_workspace_component', '_started', 'start', '_workspace', '_apply_requested_route'
        pass

    def mountWorkspace(self, parentItem: 'QObject', route: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', 'isinstance', 'QQuickItem', '_set_status', 'Automation Center cần một QQuickItem để mount', 'str', '', 'strip', '_pending_route', '_set_mount_target', '_workspace_active', True, 'workspaceActiveChanged', 'emit', '_ensure_workspace_component'
        pass

    def unmountWorkspace(self, parentItem: 'QObject') -> 'None':
        # [PyArmor BCC constants]: '_mount_target', '_set_mount_target', '_workspace', 'setParentItem', 'setProperty', 'workspaceActive', False, 'RuntimeError', '_workspace_active', 'workspaceActiveChanged', 'emit', '_set_workspace_mounted'
        pass

    def setWorkspaceActive(self, active: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_workspace_active', '_workspace', 'setProperty', 'workspaceActive', 'RuntimeError', 'workspaceActiveChanged', 'emit', '_clear_workspace_focus', 'QTimer', 'singleShot', 0
        pass

    def _clear_workspace_focus(self) -> 'None':
        # [PyArmor BCC constants]: '_workspace', 'setFocus', False, 'RuntimeError', '_main_window', 'getattr', 'contentItem', 'callable', 'forceActiveFocus', 'Qt', 'FocusReason', 'OtherFocusReason', 'AttributeError', 'TypeError'
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', '_started', 'start', '_refresh_inflight', True, '_refresh_again', '_submit_operation', 'refresh', '_refresh_worker', False
        pass

    def selectOrder(self, orderId: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_order_rows_by_id', '_set_selected_order'
        pass

    def createWorkOrder(self, title: 'str', workflow: 'str', inputMode: 'str', content: 'str', autoPublish: 'bool', profileId: 'str', caption: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', '_set_status', 'Hãy đặt tên cho work order', False, 'master', 'idea', 'script', 'clone', 'local_video', 'transcript', 'audio_file', 'text'
        pass

    def createWorkOrderV2(self, definition: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'str', 'get', 'title', '', 'strip', '_set_status', 'Hãy đặt tên cho work order', False, 'production_control', 'production', 'Work order chưa có cấu hình sản xuất', '_shutdown_requested'
        pass

    def draftAutomationPlan(self, brief: 'str', autoPublish: 'bool', profileId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy mô tả việc cần AI Studio lập kế hoạch', False, 'bool', 'Bản nháp tự đăng cần một hồ sơ mạng xã hội đã xác minh', '_shutdown_requested', '_started', 'start', '_submit_operation', 'draft_plan', 'partial', '_draft_plan_worker'
        pass

    def clearPlanDraft(self) -> 'None':
        pass

    def createCopilotProject(self, title: 'str', brief: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy mô tả mục tiêu kênh trước', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_create_project', 'partial', '_create_copilot_project_worker', 'invalidate_active_state', 'Đang tạo không gian lập kế hoạch kênh…'
        pass

    def importCopilotSources(self, projectId: 'str', sources: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'list', 'isinstance', 'Mapping', 'dict', '_set_status', 'Hãy tạo hoặc chọn một kế hoạch kênh', False, 'Hãy nhập ít nhất một nguồn', '_shutdown_requested', '_started', 'start', '_submit_operation'
        pass

    def configureCopilotDelivery(self, projectId: 'str', delivery: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'isinstance', 'Mapping', 'dict', '_set_status', 'Hãy tạo hoặc chọn một kế hoạch kênh', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_configure_delivery', 'partial'
        pass

    def selectCopilotProject(self, projectId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_shutdown_requested', False, '_started', 'start', '_submit_operation', 'copilot_select_project', 'partial', '_select_copilot_project_worker', 'invalidate_active_state'
        pass

    def sendCopilotMessage(self, projectId: 'str', message: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy tạo hoặc chọn một kế hoạch kênh', False, 'Hãy nhập yêu cầu cho Channel Copilot', '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_send_message', 'partial', '_send_copilot_message_worker', 'invalidate_active_state'
        pass

    def resumeCopilotConversation(self, projectId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_shutdown_requested', False, '_started', 'start', '_submit_operation', 'copilot_conversation_resume', 'partial', '_resume_copilot_conversation_worker', 'invalidate_active_state', '_set_status', 'Đang xác minh lại đúng account LLM trong browser…'
        pass

    def resetCopilotConversation(self, projectId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_shutdown_requested', False, '_started', 'start', '_submit_operation', 'copilot_conversation_reset', 'partial', '_reset_copilot_conversation_worker', 'invalidate_active_state', '_set_status', 'Đang tạo cuộc trò chuyện mới bằng account LLM đã chọn…'
        pass

    def approveCopilotPlan(self, projectId: 'str', revision: 'int') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'int', 0, '_set_status', 'Chưa có revision để duyệt', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_approve_plan', 'partial', '_approve_copilot_plan_worker'
        pass

    def prepareCopilotAssignments(self, projectId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_shutdown_requested', False, '_started', 'start', '_submit_operation', 'copilot_prepare_assignments', 'partial', '_prepare_copilot_assignments_worker', 'invalidate_active_state', '_set_status', 'Đang biên dịch các mục sẵn sàng sang Assignment V2…'
        pass

    def assignCopilotItem(self, projectId: 'str', contentItemId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_shutdown_requested', False, '_started', 'start', '_submit_operation', 'copilot_assign_item', 'partial', '_assign_copilot_item_worker', '_set_status', 'Đang giao content item vào coordinator tuần tự…'
        pass

    def assignAllCopilotItems(self, projectId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy tạo hoặc chọn một kế hoạch kênh', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_assign_all', 'partial', '_assign_all_copilot_items_worker', 'Đang xếp toàn bộ kế hoạch vào coordinator tuần tự…'
        pass

    def startOrder(self, orderId: 'str') -> 'bool':
        pass

    def pauseOrder(self, orderId: 'str') -> 'bool':
        pass

    def resumeOrder(self, orderId: 'str') -> 'bool':
        pass

    def retryOrder(self, orderId: 'str') -> 'bool':
        pass

    def cancelOrder(self, orderId: 'str') -> 'bool':
        pass

    def resolveOrderAttention(self, orderId: 'str', stepId: 'str', resolution: 'str', evidence: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', '_set_status', 'Chọn đúng bước cần đối soát trước', False, 'published', 'not_published', 'failed', 'Kết quả đối soát không hợp lệ', '_shutdown_requested', '_submit_operation', 'resolve_attention', 'partial'
        pass

    def createSocialProfile(self, platform: 'str', label: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'facebook', 'youtube', 'tiktok', '_set_status', 'Chỉ hỗ trợ TikTok, YouTube và Facebook', False, 'Hãy đặt tên cho hồ sơ đăng', '_shutdown_requested', '_started', 'start', '_submit_operation'
        pass

    def saveChannelProductionProfile(self, value: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'str', 'get', 'social_profile_id', 'profile_id', '', 'strip', '_set_status', 'Hãy chọn hồ sơ đăng cần lưu cấu hình kênh', False, '_shutdown_requested', '_started', 'start'
        pass

    def captureChannelProductionProfile(self, profileId: 'str', overrides: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy chọn hồ sơ đăng cần chụp cấu hình', False, 'isinstance', 'Mapping', 'dict', '_shutdown_requested', '_started', 'start', '_submit_operation', 'capture_channel_profile', 'partial'
        pass

    def cloneChannelProductionProfile(self, value: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'str', 'get', 'source_channel_profile_id', '', 'strip', '_set_status', 'Hãy chọn bộ cấu hình nguồn cần nhân bản', False, 'target_social_profile_id', 'Hãy chọn kênh đích cần nhận cấu hình', '_shutdown_requested', '_started'
        pass

    def loadChannelDevelopmentKit(self, channelProfileId: 'str', version: 'int') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy chọn cấu hình kênh cần mở', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'load_channel_kit', 'partial', '_load_channel_kit_worker', 'max', 0
        pass

    def captureChannelWorkflowConfig(self, channelProfileId: 'str', workflow: 'str', expectedVersion: 'int', expectedHash: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'master', 'timemachine', 'transcript', 'clone', 'affiliate', '_set_status', 'Hãy chọn kênh và feature Tool 1 cần capture', False, '_shutdown_requested', '_started', 'start'
        pass

    def saveChannelWorkflowConfig(self, channelProfileId: 'str', workflow: 'str', config: 'Any', expectedVersion: 'int', expectedHash: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'isinstance', 'Mapping', 'dict', 'master', 'timemachine', 'transcript', 'clone', 'affiliate', '_set_status', 'Hãy chọn kênh và feature Tool 1 cần lưu', False
        pass

    def diffChannelProfileVersions(self, channelProfileId: 'str', beforeVersion: 'int', afterVersion: 'int') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'int', 0, '_set_status', 'Hãy chọn hai revision cấu hình kênh để so sánh', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'diff_channel_profile', 'partial', '_diff_channel_profile_worker'
        pass

    def bindCopilotChannelProfile(self, projectId: 'str', channelProfileId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy chọn kế hoạch và cấu hình kênh', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_bind_channel_profile', 'partial', '_bind_copilot_channel_profile_worker', 'invalidate_active_state', 'Đang gắn kế hoạch với cấu hình sản xuất của kênh…'
        pass

    def saveReferencePack(self, value: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'str', 'get', 'title', '', 'strip', 'reference_pack_id', '_set_status', 'Hãy đặt tên cho Reference Pack', False, '_shutdown_requested', '_started', 'start'
        pass

    def bindCopilotReferencePack(self, projectId: 'str', referencePackId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy chọn một kế hoạch kênh', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_bind_reference_pack', 'partial', '_bind_copilot_reference_pack_worker', 'invalidate_active_state', 'Đang gắn Reference Pack cho revision kế hoạch tiếp theo…'
        pass

    def requestProfilePage(self, query: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'platform', '', 'strip', 'lower', 'facebook', 'youtube', 'tiktok', '_set_status', 'Nền tảng này chưa có Publish Executor', False, 'view', 'all'
        pass

    def requestPublishAttemptPage(self, query: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'platform', '', 'strip', 'lower', 'facebook', 'youtube', 'tiktok', '_set_status', 'Nền tảng này chưa có Publish Executor', False, 'int', 'limit'
        pass

    def requestScheduleOccurrencePage(self, query: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'int', 'get', 'limit', 100, 'offset', 'cursor', 0, '_set_status', 'Trang lịch đăng không hợp lệ', False, 'TypeError', 'ValueError', 1, 500
        pass

    def requestAttentionPage(self, query: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'int', 'get', 'limit', 100, 'offset', 'cursor', 0, '_set_status', 'Trang cần xử lý không hợp lệ', False, 'TypeError', 'ValueError', 1, 500
        pass

    def saveScheduleCapacityPolicy(self, value: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'channel_id', '', 'strip', '_set_status', 'Hãy chọn kênh cần giới hạn lịch đăng', False, '_submit_operation', 'save_schedule_capacity', 'partial', '_save_schedule_capacity_worker', 'invalidate_active_state', 'Đang lưu phiên bản công suất kênh…'
        pass

    def saveScheduleRecurrence(self, value: 'dict[str, Any]', assignmentDefinition: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', '_set_status', 'Lịch lặp cần rule và Assignment V2 đã review', False, '_submit_operation', 'save_schedule_recurrence', 'partial', '_save_schedule_recurrence_worker', 'invalidate_active_state', 'Đang đóng băng lịch lặp…'
        pass

    def previewScheduleConflict(self, value: 'dict[str, Any]') -> 'bool':
        pass

    def previewScheduleRecurrence(self, value: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'recurrence_id', 'recurrence_key', '', 'strip', 'window_start_utc', 'window_start', 'window_end_utc', 'window_end', '_set_status', 'Xem trước lịch lặp cần quy tắc và cửa sổ UTC', False, 'update'
        pass

    def materializeScheduleRecurrence(self, value: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'recurrence_id', '', 'strip', '_set_status', 'Hãy chọn lịch lặp cần tạo work order', False, '_submit_operation', 'materialize_schedule_recurrence', 'partial', '_materialize_schedule_recurrence_worker', 'Đang kiểm tra xung đột và tạo occurrence…'
        pass

    def setScheduleRecurrenceState(self, recurrenceId: 'str', state: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'active', 'paused', '_set_status', 'Lịch lặp hoặc trạng thái không hợp lệ', False, '_submit_operation', 'set_schedule_recurrence_state', 'partial', '_set_schedule_recurrence_state_worker', 'invalidate_active_state'
        pass

    def createSocialProfiles(self, platform: 'str', rowsText: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'facebook', 'youtube', 'tiktok', '_set_status', 'Chỉ hỗ trợ TikTok, YouTube và Facebook', False, 'Hãy nhập ít nhất một dòng ID | tên hồ sơ', '_shutdown_requested', '_started', 'start', '_submit_operation'
        pass

    def previewSocialProfileImport(self, payload: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'get', 'csv_content', '_set_status', 'Hãy nhập nội dung CSV hồ sơ', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'preview_profile_import', 'partial', '_preview_social_profile_import_worker', 'Đang kiểm tra CSV hồ sơ trên worker cục bộ…'
        pass

    def executeSocialProfileImport(self, importId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Thiếu import_id đã được xác nhận', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'execute_profile_import', 'partial', '_execute_social_profile_import_worker', 'Đang tạo hồ sơ từ bản preview đã đóng băng…'
        pass

    def openSocialProfile(self, profileId: 'str') -> 'bool':
        pass

    def closeSocialProfile(self, profileId: 'str') -> 'bool':
        pass

    def verifySocialProfile(self, profileId: 'str') -> 'bool':
        pass

    def preflightSocialProfile(self, profileId: 'str') -> 'bool':
        pass

    def _submit_order_action(self, action: 'str', order_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Chọn một work order trước', False, '_shutdown_requested', '_submit_operation', 'partial', '_order_action_worker', 'Đang cập nhật work order…'
        pass

    def _submit_profile_action(self, action: 'str', profile_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Chọn một hồ sơ đăng trước', False, '_shutdown_requested', '_submit_operation', 'partial', '_profile_action_worker', 'open_social_profile', 'Đang mở browser đăng nhập…', 'verify_social_profile', 'Đang kiểm tra đăng nhập và trang upload…', 'preflight_social_profile'
        pass

    def requestWindowClose(self, window: 'QObject') -> 'bool':
        # [PyArmor BCC constants]: '_active_state_known', True, 'runActive', 'execution', 'str', 'get', 'owner_workflow', 'automation', 'owner_state', 'unknown', '_active_count', 0, 'VeoFlow còn ', ' job đang chạy. Giữ Tool 1 mở cho đến khi các tác vụ provider kết thúc.', 'VeoFlow còn workflow '
        pass

    def setDarkMode(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', 'getattr', '_app_controller', 'setDarkMode', 'callable', '_set_status', 'Không thể đổi giao diện: ', 'Exception', '_sync_dark_mode', '_set_dark_mode'
        pass

    def shutdown(self) -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', '_started', '_initialized', '_pending_count', 0, True, False, '_refresh_again', '_workspace_active', '_scheduled_wake_timer', 'stop', 'getattr', '_app_controller', 'darkModeChanged', 'disconnect'
        pass

    def _build_default_service_worker(self) -> 'Any':
        pass

    def _ensure_service_worker(self) -> 'Any':
        # [PyArmor BCC constants]: '_service', '_service_factory', '_build_default_service_worker'
        pass

    def _refresh_worker(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_uses_default_service', 'get_prompt_queue_service', '_ensure_service_worker', '_snapshot_from_service_worker'
        pass

    def _snapshot_from_service_worker(self, service: 'Any', copilot_project_id: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'refresh_runs', 'str', 'get', 'local_timezone', '', 'strip', 'get_localzone_name', 'UTC', 'Exception', 'getattr', 'capabilities', 'callable', 'list', 'list_work_orders'
        pass

    def _create_work_order_worker(self, title: 'str', workflow: 'str', mode: 'str', content: 'str', auto_publish: 'bool', profile_id: 'str', caption: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'create_work_order', 'callable', 'RuntimeError', 'Work-order coordinator chưa được nạp', 'title', 'workflow', 'input_mode', 'content', 'options', 'config', 'auto_publish', 'profile_id', 'caption'
        pass

    def _create_work_order_v2_worker(self, definition: 'Mapping[str, Any]', order_id: 'str', submission_key: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'create_work_order_v2', 'callable', 'assignment_definition', 'dict', 'auto_start', True, 'order_id', 'str', '', 'submission_key', 'create_work_order', 'RuntimeError', 'Coordinator chưa hỗ trợ contract giao việc V2'
        pass

    def _acknowledge_assignment_create_worker(self, assignment_request_key: 'str', order_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'acknowledge_assignment_create', 'callable', 'RuntimeError', 'Coordinator chưa hỗ trợ xác nhận giao việc bền vững', 'bool', 'Không thể xác nhận receipt giao việc bền vững', '_snapshot_from_service_worker'
        pass

    def _draft_plan_worker(self, brief: 'str', auto_publish: 'bool', profile_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'draft_automation_plan', 'callable', 'draft_plan', 'RuntimeError', 'AI Studio planner chưa được nạp', 'auto_publish', 'profile_id', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'dict', 'plan_draft'
        pass

    def _create_copilot_project_worker(self, title: 'str', brief: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'create_copilot_project', 'callable', 'RuntimeError', 'Channel Copilot store chưa được nạp', 'str', 'isinstance', 'Mapping', 'get', 'selected_project_id', '', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _select_copilot_project_worker(self, project_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'copilot_snapshot', 'callable', 'RuntimeError', 'Channel Copilot store chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _import_copilot_sources_worker(self, project_id: 'str', sources: 'list[dict[str, Any]]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'import_copilot_sources', 'callable', 'RuntimeError', 'Channel Copilot source intake chưa được nạp', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'dict', 'get', 'source_import', 'copilot_project_id'
        pass

    def _configure_copilot_delivery_worker(self, project_id: 'str', delivery: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'configure_copilot_delivery', 'callable', 'RuntimeError', 'Channel Copilot delivery store chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _bind_copilot_channel_profile_worker(self, project_id: 'str', channel_profile_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'bind_copilot_channel_profile', 'callable', 'RuntimeError', 'Channel production profile binder chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _bind_copilot_reference_pack_worker(self, project_id: 'str', reference_pack_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'bind_copilot_reference_pack', 'callable', 'RuntimeError', 'Reference Pack binder chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _send_copilot_message_worker(self, project_id: 'str', message: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'send_copilot_message', 'callable', 'RuntimeError', 'Channel Copilot AI Studio chưa được nạp', '_copilotStreamEvent', 'emit', 'dict', 'on_stream', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _resume_copilot_conversation_worker(self, project_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'resume_copilot_conversation', 'callable', 'RuntimeError', 'Channel Copilot reconnect chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _reset_copilot_conversation_worker(self, project_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'reset_copilot_conversation', 'callable', 'RuntimeError', 'Channel Copilot reset chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _approve_copilot_plan_worker(self, project_id: 'str', revision: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'approve_copilot_plan', 'callable', 'RuntimeError', 'Channel Copilot approval store chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _prepare_copilot_assignments_worker(self, project_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'prepare_copilot_assignments', 'callable', 'RuntimeError', 'Channel Copilot Assignment V2 compiler chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _assign_copilot_item_worker(self, project_id: 'str', content_item_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'assign_copilot_item', 'callable', 'RuntimeError', 'Channel Copilot assignment adapter chưa được nạp', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'get', 'order', 'str', 'order_id', 'orderId', ''
        pass

    def _assign_all_copilot_items_worker(self, project_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'assign_all_copilot_items', 'callable', 'RuntimeError', 'Channel Copilot batch assignment chưa được nạp', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'list', 'get', 'order_ids', 'str', 'created_order_ids', 'int'
        pass

    def _order_action_worker(self, action: 'str', order_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'start_order', 'start_work_order', 'pause_order', 'pause_work_order', 'resume_order', 'resume_work_order', 'retry_order', 'retry_work_order', 'cancel_order', 'cancel_work_order', 'get', 'getattr', 'callable', 'RuntimeError'
        pass

    def _profile_page_worker(self, request: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'list_profiles_page', 'callable', 'RuntimeError', 'Publish Executor chưa hỗ trợ phân trang hồ sơ', 'profile_page', 'dict'
        pass

    def _publish_attempt_page_worker(self, request: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'list_publish_attempts_page', 'callable', 'RuntimeError', 'Publish Executor chưa hỗ trợ lịch sử phân trang', 'publish_attempt_page', 'dict'
        pass

    def _schedule_occurrence_page_worker(self, request: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'list_schedule_occurrences_page', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ phân trang occurrence', 'schedule_occurrence_page', 'dict'
        pass

    def _attention_page_worker(self, request: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'list_attention_page', 'callable', 'RuntimeError', 'Automation Center chưa có attention query', 'attention_page', 'dict'
        pass

    def _save_schedule_capacity_worker(self, value: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'save_schedule_capacity_policy', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ capacity policy', 'dict', '_snapshot_from_service_worker', 'schedule_capacity_result'
        pass

    def _save_schedule_recurrence_worker(self, value: 'Mapping[str, Any]', assignment: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'save_schedule_recurrence', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ recurrence', 'dict', '_snapshot_from_service_worker', 'schedule_recurrence_result'
        pass

    def _preview_schedule_conflict_worker(self, value: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'preview_schedule_conflict', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ conflict preview', 'platform', 'str', 'get', '', 'channel_id', 'scheduled_at_utc', 'timezone', 'duration_seconds', 'int'
        pass

    def _preview_schedule_recurrence_worker(self, value: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'preview_schedule_recurrence', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ recurrence preview', 'str', 'get', 'recurrence_id', '', 'window_start_utc', 'window_end_utc', 'int', 'limit', 100
        pass

    def _materialize_schedule_recurrence_worker(self, value: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'materialize_schedule_recurrence', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ materialize', 'str', 'get', 'recurrence_id', '', 'window_start_utc', 'window_end_utc', 'int', 'limit', 100
        pass

    def _set_schedule_recurrence_state_worker(self, recurrence_id: 'str', state: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'set_schedule_recurrence_state', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ pause/resume', '_snapshot_from_service_worker', 'dict', 'schedule_recurrence_result'
        pass

    def _resolve_attention_worker(self, order_id: 'str', step_id: 'str', resolution: 'str', evidence: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'resolve_work_order_attention', 'callable', 'resolve_order_attention', 'RuntimeError', 'Coordinator chưa hỗ trợ đối soát needs_attention', 'dict', '_snapshot_from_service_worker', 'selected_order_id'
        pass

    def _profile_action_worker(self, action: 'str', *args: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'callable', 'RuntimeError', 'Publish Executor chưa được nạp', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'dict', 'profile_result'
        pass

    def _save_channel_profile_worker(self, payload: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'save_channel_production_profile', 'callable', 'RuntimeError', 'Channel production profile store chưa được nạp', 'dict', '_snapshot_from_service_worker', 'channel_profile_result', 'get_channel_development_kit', 'str', 'isinstance', 'Mapping', 'get', 'channel_profile_id'
        pass

    def _capture_channel_profile_worker(self, social_profile_id: 'str', overrides: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'capture_channel_production_profile', 'callable', 'RuntimeError', 'Channel production profile capture chưa được nạp', 'dict', '_snapshot_from_service_worker', 'channel_profile_result', 'get_channel_development_kit', 'str', 'isinstance', 'Mapping', 'get', 'channel_profile_id'
        pass

    def _clone_channel_profile_worker(self, payload: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'clone_channel_production_profile', 'callable', 'RuntimeError', 'Tiện ích nhân bản Channel Production Kit chưa được nạp', 'dict', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'get', 'profile', 'channel_profile_result', 'channel_profile_clone_result', 'str'
        pass

    def _load_channel_kit_worker(self, channel_profile_id: 'str', version: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'get_channel_development_kit', 'callable', 'RuntimeError', 'Channel Production Kit V2 chưa được nạp', 'version', '_snapshot_from_service_worker', 'dict', 'channel_development_kit_result'
        pass

    def _capture_channel_workflow_worker(self, channel_profile_id: 'str', workflow: 'str', expected_version: 'int', expected_hash: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'capture_channel_workflow_config', 'callable', 'RuntimeError', 'Capture cấu hình theo feature chưa được nạp', 'expected_version', 'expected_hash', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'get', 'profile', 'dict', 'channel_profile_result'
        pass

    def _save_channel_workflow_worker(self, channel_profile_id: 'str', workflow: 'str', config: 'Mapping[str, Any]', expected_version: 'int', expected_hash: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'save_channel_workflow_config', 'callable', 'RuntimeError', 'Lưu cấu hình theo feature chưa được nạp', 'dict', 'expected_version', 'expected_hash', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'get', 'profile', 'channel_profile_result'
        pass

    def _diff_channel_profile_worker(self, channel_profile_id: 'str', before_version: 'int', after_version: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'diff_channel_profile_versions', 'callable', 'RuntimeError', 'So sánh revision cấu hình kênh chưa được nạp', '_snapshot_from_service_worker', 'dict', 'channel_profile_diff_result'
        pass

    def _save_reference_pack_worker(self, payload: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'save_reference_pack', 'callable', 'RuntimeError', 'Reference Pack store chưa được nạp', 'dict', '_snapshot_from_service_worker', 'reference_pack_result'
        pass

    def _create_social_profiles_text_worker(self, platform: 'str', rows_text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'splitlines', 'strip', 'RuntimeError', 'Hãy nhập ít nhất một dòng ID | tên hồ sơ', 'len', '_MAX_PROFILE_IMPORT_ROWS', 'Mỗi lần chỉ nhập tối đa 1.000 hồ sơ', 'enumerate', 'start', 1, 'partition', '|', 'Dòng ', ' phải có định dạng ID ổn định | tên hồ sơ', 'append'
        pass

    def _preview_social_profile_import_worker(self, payload: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'profile_id', 'platform', 'label', 'browser_key'
        pass

    def _execute_social_profile_import_worker(self, import_id: 'str') -> 'dict[str, Any]':
        pass

    def _remember_profile_import(self, frozen: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'len', '_profile_imports', '_MAX_FROZEN_PROFILE_IMPORTS', 'next', 'iter', '_forget_profile_import', 'str', 'get', 'id', '', 'idempotency_key', '_profile_import_keys'
        pass

    def _forget_profile_import(self, import_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_profile_imports', 'pop', 'str', 'get', 'idempotency_key', '', '_profile_import_keys'
        pass

    @staticmethod
    def _profile_import_summary(frozen: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'id', 'import_id', 'kind', 'state', 'total', 'valid', 'invalid', 'str', 'get', '', 'browser', 'preview', 'int', 0
        pass

    def _close_service_worker(self) -> 'None':
        # [PyArmor BCC constants]: '_profile_imports', 'clear', '_profile_import_keys', '_service', 'getattr', 'close', 'callable'
        pass

    @staticmethod
    def _coerce_snapshot(value: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'get', 'rows', 'stats', 'orders', 'profiles', 'channel_profiles', 'reference_packs', 'publish_attempts', 'schedule_capacities', 'schedule_recurrences', 'schedule_occurrences', 'attention_cases', 'steps_by_order'
        pass

    def _submit_operation(self, name: 'str', work: 'Callable[[], Any]', invalidate_active_state: 'bool' = True) -> 'bool':
        # [PyArmor BCC constants]: '_set_active_state_known', False, 1, '_next_token', '_pending_count', '_pending_names', '_set_busy', True, '_executor', 'submit', 'max', 0, 'pop', '_set_status', 'Automation Center không thể nhận thêm việc: '
        pass

    def _future_done(self, token: 'int', name: 'str', future: 'Future[Any]') -> 'None':
        # [PyArmor BCC constants]: 'result', 'ok', 'data', True, 'error', 'message', False, 'type', '__name__', 'str', 'Exception', '_operationReady', 'emit', 'RuntimeError'
        pass

    def _apply_operation_result(self, token: 'int', name: 'str', payload: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'max', 0, '_pending_count', 1, '_pending_names', 'pop', 'refresh', False, '_refresh_inflight', '_set_busy', '_shutdown_requested', 'isinstance', 'Mapping', 'dict', 'get'
        pass

    def _apply_snapshot(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'items', 'total', 'limit', 'offset', 'has_more'
        pass

    def _apply_profile_page(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'list', 'get', 'items', '_normalise_profile_row', 'view_counts', 'total', 'limit', 'offset', 'has_more', 'query', 'platform', 'status'
        pass

    def _apply_publish_attempt_page(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'list', 'get', 'items', '_normalise_publish_attempt_row', 'total', 'limit', 'offset', 'has_more', 'query', 'platform', 'profile_id', 'status'
        pass

    def _apply_schedule_occurrence_page(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'list', 'get', 'items', '_normalise_schedule_occurrence_row', 'total', 'limit', 'offset', 'has_more', 'query', 'platform', 'channel_id', 'status'
        pass

    def _apply_attention_page(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'list', 'get', 'items', '_normalise_attention_row', 'total', 'limit', 'offset', 'has_more', 'query', 'platform', 'channel_id', 'case_type'
        pass

    def _apply_copilot_stream_event(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'str', 'get', 'project_id', '', '_selected_copilot_project_id', '_shutdown_requested', 'phase', 'strip', 'lower', 'started', '_copilot_message_model', 'upsert_row'
        pass

    def _apply_copilot_snapshot(self, value: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'list', 'get', 'projects', 'isinstance', 'Mapping', '_normalise_copilot_project_row', 'messages', '_normalise_copilot_message_row', 'content_items', '_normalise_copilot_content_row', 'sources', '_normalise_copilot_source_row', 'selected_project', 'str', 'selected_project_id'
        pass

    def _arm_scheduled_wake(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: '_scheduled_wake_timer', 'stop', 'str', '', 'strip', '_shutdown_requested', '_started', 'datetime', 'fromisoformat', 'replace', 'Z', '+00:00', 'tzinfo', 'astimezone', 'UTC'
        pass

    def _on_scheduled_wake(self) -> 'None':
        pass

    def _connect_queue_bridge(self) -> 'None':
        # [PyArmor BCC constants]: '_uses_default_service', '_started', '_queue_bridge_connected', '_queue_push_bridge', 'connect_store', True, '_job_store_connected', 'get_job_store', '_job_store', 'getattr', 'connect', '_relay_job_store_changed', 'Exception'
        pass

    def _on_queue_push(self) -> 'None':
        pass

    def _relay_job_store_changed(self, job: 'object') -> 'None':
        pass

    def _on_job_store_changed(self, job: 'object') -> 'None':
        # [PyArmor BCC constants]: '_started', '_shutdown_requested', 'getattr', 'meta', 'isinstance', 'Mapping', 'dict', 'str', 'get', 'master_prompt_job_id', 'clone_job_id', 'transcript_job_id', 'affiliate_queue_row_id', 'timemachine_job_id', ''
        pass

    def _flush_job_store_refresh(self) -> 'None':
        # [PyArmor BCC constants]: False, '_job_refresh_pending', '_started', '_shutdown_requested', 'refresh'
        pass

    @staticmethod
    def _load_workspace_bridge_types_worker() -> 'tuple[type, type]':
        pass

    def _ensure_workspace_component(self) -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', '_workspace', '_component', '_bridge_load_inflight', '_engine', '_set_status', 'Automation Center chưa được gắn vào QML engine', '_bridge_types', True, '_executor', 'submit', '_load_workspace_bridge_types_worker', False, 'Không thể chuẩn bị Automation Center: ', 'RuntimeError'
        pass

    def _relay_workspace_bridge_ready(self, future: 'Future[Any]') -> 'None':
        # [PyArmor BCC constants]: True, 'result', False, 'str', 'Exception', '_workspaceBridgeReady', 'emit', 'RuntimeError'
        pass

    def _on_workspace_bridge_ready(self, payload: 'object') -> 'None':
        # [PyArmor BCC constants]: False, '_bridge_load_inflight', '_shutdown_requested', 'isinstance', 'tuple', '_set_status', 'Không thể chuẩn bị Automation Center: ', '_bridge_types', '_load_workspace_component'
        pass

    def _load_workspace_component(self) -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', '_workspace', '_component', '_qml_path', 'is_file', '_set_status', 'Không tìm thấy giao diện VeoFlow OS: ', '_prepare_vendor_qml_context', 'QQmlComponent', '_engine', 'statusChanged', 'connect', '_on_component_status_changed', 'loadUrl', 'QUrl'
        pass

    def _prepare_vendor_qml_context(self) -> 'None':
        # [PyArmor BCC constants]: '_qml_context', '_engine', 'RuntimeError', 'QML engine is not attached', '_bridge_types', 'workspace bridge types are not loaded', '_control_plane', '_appearance_proxy', 'QtQml', 'QQmlContext', 'rootContext', 'setContextProperty', 'controlPlane', 'appearance'
        pass

    def _dispose_qml_context(self) -> 'None':
        # [PyArmor BCC constants]: '_qml_context', 'deleteLater', 'AttributeError', 'RuntimeError'
        pass

    def _on_component_status_changed(self, status: 'Any') -> 'None':
        # [PyArmor BCC constants]: '_component', '_workspace', 'QQmlComponent', 'Status', 'Loading', 'Error', 'errors', 'toString', 'Exception', '; ', 'join', 3, 'QML component error', '_dispose_qml_context', 'deleteLater'
        pass

    def _set_mount_target(self, target: 'QQuickItem | None') -> 'None':
        # [PyArmor BCC constants]: '_mount_target', 'destroyed', 'disconnect', '_on_mount_target_destroyed', 'AttributeError', 'RuntimeError', 'TypeError', 'connect'
        pass

    def _mount_workspace(self) -> 'None':
        # [PyArmor BCC constants]: '_workspace', '_mount_target', 'setParentItem', 'setProperty', 'workspaceActive', '_workspace_active', '_set_status', 'Không thể mount Automation Center: ', 'RuntimeError', '_set_workspace_mounted', True
        pass

    def _apply_requested_route(self) -> 'None':
        # [PyArmor BCC constants]: '_workspace', 'str', '_pending_route', 'today', 'strip', 'lower', 'replace', '-', '_', '_ROUTE_ALIASES', 'get', 'getattr', 'activateRoute', 'callable', 'bool'
        pass

    def _on_workspace_destroyed(self, destroyed_object: 'QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: '_workspace', 'embeddedWorkspaceChanged', 'emit', '_component', 'deleteLater', 'RuntimeError', '_dispose_qml_context', '_set_workspace_mounted', False
        pass

    def _on_mount_target_destroyed(self, destroyed_object: 'QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: '_mount_target', '_workspace', 'setParentItem', 'setProperty', 'workspaceActive', False, 'RuntimeError', '_workspace_active', '_set_workspace_mounted'
        pass

    def _sync_dark_mode(self) -> 'None':
        # [PyArmor BCC constants]: 'getattr', '_app_controller', 'darkMode', '_dark_mode', 'callable', 'Exception', '_set_dark_mode', 'bool'
        pass

    def _on_main_window_destroyed(self, destroyed_object: 'QObject | None' = None) -> 'None':
        pass

    def _set_selected_order(self, order_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'dict', '_order_rows_by_id', 'get', '_selected_order_id', '_selected_order', '_step_model', 'setRows', '_steps_by_order', 'selectedOrderChanged', 'emit'
        pass

    def _set_plan_draft(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', '_plan_draft', 'planDraftChanged', 'emit'
        pass

    def _set_busy(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_busy', 'busyChanged', 'emit'
        pass

    def _set_initialized(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_initialized', 'initializedChanged', 'emit'
        pass

    def _set_status(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_status_message', 'statusChanged', 'emit'
        pass

    def _set_dark_mode(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_dark_mode', 'darkModeChanged', 'emit'
        pass

    def _set_workspace_mounted(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_workspace_mounted', 'workspaceMountedChanged', 'emit'
        pass

    def _set_execution(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: '_normalise_execution', '_execution', 'executionChanged', 'emit'
        pass

    def _set_active_state_known(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_active_state_known', 'activeStateKnownChanged', 'emit', 'executionChanged'
        pass


# --- Top-Level Functions ---
def _default_qml_path() -> 'Path':
    # [PyArmor BCC constants]: 'getattr', 'sys', 'frozen', False, 'Path', '_MEIPASS', 'executable', 'parent', 'qml', 'automation_center', 'veoflow_os', 'VeoFlowOsWorkspace.qml', '__file__', 'resolve', 'parents'
    pass

def _unknown_execution(reason: 'str' = 'state_unknown') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'can_submit', 'run_active', 'owner_attempt_id', 'owner_workflow', 'owner_state', 'reason', 'queue_depth', False, '', 'str', 'state_unknown', 0
    pass

def _normalise_execution(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', '_unknown_execution', 'dict', 'bool', 'get', 'run_active', False, 'can_submit', 'owner_attempt_id', 'owner_workflow', 'owner_state', 'reason', 'queue_depth', 'str'
    pass

def _status_text(value: 'Any') -> 'str':
    # [PyArmor BCC constants]: 'getattr', 'value', 'str', 'queued', 'strip', 'lower', '.', 'rsplit', 1
    pass

def _safe_int(value: 'Any', fallback: 'int' = 0) -> 'int':
    pass

def _safe_progress(value: 'Any') -> 'float':
    # [PyArmor BCC constants]: 'float', 0.0, 'TypeError', 'ValueError', 'isinstance', 'int', 'bool', 0, 100, 1.0, 100.0, 'max', 'min'
    pass

def _normalise_run_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'str', 'get', 'workflow', 'master', '_status_text', 'status', 'observed_state', 'message', '', 'error_message', 'active', 'is_active'
    pass

def _normalise_order_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', '_status_text', 'get', 'status', 'str', 'cancelRequestedAt', 'cancel_requested_at', '', 'bool', 'cancelRequested', 'cancel_requested', False, 'max'
    pass

def _normalise_step_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', '_status_text', 'get', 'status', 'evidence', 'stepId', 'orderId', 'position', 'kind', 'workflow', 'title', 'statusLabel', 'jobId'
    pass

def _normalise_profile_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'get', 'channel_profile', '_status_text', 'status', 'created', 'profileId', 'channelId', 'platform', 'label', 'browserKey', 'proxyIdentity', 'timezoneName'
    pass

def _normalise_channel_profile_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'get', 'brand', 'entities', 'asset_policy', 'assetPolicy', 'workflow_configs', 'workflowConfigs', 'source_policy', 'sourcePolicy', 'delivery_defaults', 'deliveryDefaults', 'channelProfileId'
    pass

def _normalise_reference_pack_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'enumerate', 'list', 'get', 'sources', '_normalise_copilot_source_row', 'position', 'append', 'referencePackId', 'title', 'description', 'version', 'configHash'
    pass

def _normalise_publish_attempt_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', '_status_text', 'get', 'status', 'attemptId', 'profileId', 'platform', 'statusLabel', 'evidenceKind', 'externalPostId', 'postUrl', 'confirmation', 'evidencePath'
    pass

def _normalise_schedule_capacity_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'policyId', 'policyKey', 'version', 'previousPolicyId', 'channelId', 'platform', 'timezone', 'dailyLimit', 'minimumGapMinutes', 'windows', 'configHash', 'state'
    pass

def _normalise_schedule_recurrence_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'recurrenceId', 'recurrenceKey', 'version', 'previousRecurrenceId', 'name', 'state', 'timezone', 'frequency', 'interval', 'weekdays', 'localTime', 'startsOn'
    pass

def _normalise_schedule_occurrence_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', '_status_text', 'get', 'status', 'blocked', 'Xung đột lịch', 'materialized', 'Đã tạo work order', '_STATUS_LABELS', 'replace', '_', ' ', 'title'
    pass

def _normalise_attention_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'get', 'details', 'caseId', 'caseType', 'orderId', 'stepId', 'occurrenceId', 'recurrenceId', 'title', 'platform', 'channelId', 'stepKind'
    pass

def _normalise_copilot_project_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'get', 'delivery', 'channel_profile', 'reference_pack', 'conversation', 'str', 'status', 'draft', 'strip', 'lower', 'Bản nháp AI', 'approved'
    pass

def _normalise_copilot_message_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'messageId', 'projectId', 'role', 'content', 'status', 'actionState', 'errorCode', 'errorMessage', 'conversationGeneration', 'createdAt', 'updatedAt', 'str'
    pass

def _normalise_copilot_content_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'str', 'get', 'workflow', '', 'strip', 'lower', 'readiness', 'needs_review', 'status', 'draft', 'master', 'Master Prompt'
    pass

def _normalise_copilot_source_row(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'str', 'get', 'workflow', '', 'strip', 'lower', 'inputMode', 'input_mode', 'status', 'invalid', 'master', 'Master Prompt'
    pass

def _normalise_copilot_strategy(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'title', 'objective', 'targetAudience', 'language', 'platforms', 'positioning', 'voice', 'contentPillars', 'cadence', 'str', 'get', ''
    pass

def _normalise_plan_draft(value: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'get', 'publish', 'approval', 'provenance', 'status', 'title', 'content', 'workflow', 'inputMode', 'steps', 'publishEnabled', 'platform'
    pass

def _assignment_submission_fingerprint(value: 'Mapping[str, Any]') -> 'str':
    # [PyArmor BCC constants]: 'json', 'dumps', 'dict', 'ensure_ascii', False, 'sort_keys', True, 'separators', 'allow_nan', 'hashlib', 'sha256', 'encode', 'utf-8', 'hexdigest'
    pass

def _has_ready_step_for_running_order(snapshot: 'Mapping[str, Any]') -> 'bool':
    # [PyArmor BCC constants]: 'list', 'get', 'orders', 'isinstance', 'Mapping', 'str', 'status', '', 'strip', 'lower', 'running', 'order_id', 'orderId', 'steps_by_order', False
    pass
