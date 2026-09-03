"""
Decompiled / Reconstructed Module: qml_app.models.automation_center_models

Docstring:
Atomic QML list models for Tool 1's local Automation Center.

The coordinator publishes complete snapshots.  QML therefore never observes a
partially-mutated order, step, or social-profile list while a route is being
swapped.  Each model exposes one ``modelData`` role so the Python/QML boundary
stays explicit and cheap.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AutomationCenterAttentionModel', 'AutomationCenterChannelProfileModel', 'AutomationCenterCopilotContentModel', 'AutomationCenterCopilotMessageModel', 'AutomationCenterCopilotProjectModel', 'AutomationCenterCopilotSourceModel', 'AutomationCenterOrderModel', 'AutomationCenterProfileModel', 'AutomationCenterPublishAttemptModel', 'AutomationCenterReferencePackModel', 'AutomationCenterScheduleCapacityModel', 'AutomationCenterScheduleOccurrenceModel', 'AutomationCenterScheduleRecurrenceModel', 'AutomationCenterStepModel']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
__all__ = ['AutomationCenterAttentionModel', 'AutomationCenterChannelProfileModel', 'AutomationCenterCopilotContentModel', 'AutomationCenterCopilotMessageModel', 'AutomationCenterCopilotProjectModel', 'Automati... [truncated]

# --- Class: _SnapshotListModel ---
class _SnapshotListModel(QAbstractListModel):
    """Apply full row snapshots with stable identity-aware updates."""
    _MODEL_DATA_ROLE = 257
    staticMetaObject = PySide6.QtCore.QMetaObject("_SnapshotListModel" inherits "QAbstractListModel":
Properties:
  #1 "count", int [designable...

    countChanged = Signal()
    def __init__(self, row_keys: 'Sequence[str]', identity_keys: 'Sequence[str]', parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    def roleNames(self) -> "dict[int, __assert_armored__((QtCore, b'\\x81\\xb4\\xb9\\x0cH\\xb4\\xdfT\\xa5(\\xb4'))]":
        # [PyArmor BCC constants]: '_MODEL_DATA_ROLE', 'QtCore', 'QByteArray'
        pass

    def rowCount(self, parent: 'QtCore.QModelIndex' = <PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x0000021AD08AD980>) -> 'int':
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
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'type', '__name__', '.setRows', 'isinstance', 'Mapping', '_row_keys', 'get', '_rows', 'len', '_identity', 'beginResetModel', 'endResetModel', 'countChanged', 'emit'
        pass

    def rows(self) -> 'list[dict[str, Any]]':
        pass

    def upsert_row(self, row: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'type', '__name__', '.upsert_row', '_row_keys', 'get', '_identity', 'enumerate', '_rows', 'index', 0, 'dataChanged', 'emit', '_MODEL_DATA_ROLE', 'len'
        pass

    def patch_row(self, identity: 'Mapping[str, Any]', changes: 'Mapping[str, Any]') -> 'bool':
        """Patch one stable row and emit one narrow modelData change."""
        pass

    def _identity(self, row: 'Mapping[str, Any]') -> 'tuple[str, ...]':
        pass


# --- Class: AutomationCenterOrderModel ---
class AutomationCenterOrderModel(_SnapshotListModel):
    """Newest-first work-order queue projection."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterOrderModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'orderId', 'title', 'status', 'statusLabel', 'totalSteps', 'completedSteps', 'progress', 'currentStepTitle', 'errorMessage', 'retryable', 'cancelRequested', 'cancelRequestedAt', 'definitionVersion', 'definitionHash', 'definitionSource'
        pass


# --- Class: AutomationCenterStepModel ---
class AutomationCenterStepModel(_SnapshotListModel):
    """Ordered timeline for the selected work order."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterStepModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'stepId', 'orderId', 'position', 'kind', 'workflow', 'title', 'status', 'statusLabel', 'jobId', 'attemptId', 'profileId', 'channelId', 'platform', 'deliveryMode', 'captionMode'
        pass


# --- Class: AutomationCenterProfileModel ---
class AutomationCenterProfileModel(_SnapshotListModel):
    """Social publishing profiles without cookie or token material."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterProfileModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'profileId', 'channelId', 'platform', 'label', 'browserKey', 'proxyIdentity', 'timezoneName', 'status', 'statusLabel', 'busy', 'lastError', 'authState', 'authVerifiedAt', 'accountHandle', 'socialAccountId'
        pass


# --- Class: AutomationCenterChannelProfileModel ---
class AutomationCenterChannelProfileModel(_SnapshotListModel):
    """Versioned production settings keyed by semantic social channel."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterChannelProfileModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'channelProfileId', 'label', 'platform', 'channelId', 'socialProfileId', 'channelBindingId', 'channelBindingVersion', 'channelBindingHash', 'version', 'configHash', 'language', 'audience', 'positioning', 'characterIds', 'voiceId'
        pass


# --- Class: AutomationCenterPublishAttemptModel ---
class AutomationCenterPublishAttemptModel(_SnapshotListModel):
    """Bounded publish history with durable evidence and no provider payload."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterPublishAttemptModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'attemptId', 'profileId', 'platform', 'status', 'statusLabel', 'evidenceKind', 'externalPostId', 'postUrl', 'confirmation', 'evidencePath', 'evidenceSha256', 'errorCode', 'errorMessage', 'dispatchedAt', 'clickedAt'
        pass


# --- Class: AutomationCenterScheduleCapacityModel ---
class AutomationCenterScheduleCapacityModel(_SnapshotListModel):
    """Latest immutable posting limits for each semantic channel."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterScheduleCapacityModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'policyId', 'policyKey', 'version', 'previousPolicyId', 'channelId', 'platform', 'timezone', 'dailyLimit', 'minimumGapMinutes', 'windows', 'configHash', 'state', 'createdAt', 'updatedAt'
        pass


# --- Class: AutomationCenterScheduleRecurrenceModel ---
class AutomationCenterScheduleRecurrenceModel(_SnapshotListModel):
    """Latest recurrence-rule versions, never executable by themselves."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterScheduleRecurrenceModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'recurrenceId', 'recurrenceKey', 'version', 'previousRecurrenceId', 'name', 'state', 'timezone', 'frequency', 'interval', 'weekdays', 'localTime', 'startsOn', 'endsOn', 'durationSeconds', 'platform'
        pass


# --- Class: AutomationCenterScheduleOccurrenceModel ---
class AutomationCenterScheduleOccurrenceModel(_SnapshotListModel):
    """Concrete conflict-gated occurrences with durable work-order lineage."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterScheduleOccurrenceModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'occurrenceId', 'occurrenceKey', 'recurrenceId', 'recurrenceKey', 'recurrenceVersion', 'localDate', 'localTime', 'scheduledAtUtc', 'timezone', 'durationSeconds', 'platform', 'channelId', 'profileId', 'capacityPolicyId', 'capacityPolicyKey'
        pass


# --- Class: AutomationCenterAttentionModel ---
class AutomationCenterAttentionModel(_SnapshotListModel):
    """Unified unresolved work-order and schedule cases."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterAttentionModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'caseId', 'caseType', 'orderId', 'stepId', 'occurrenceId', 'recurrenceId', 'title', 'platform', 'channelId', 'stepKind', 'errorCode', 'errorMessage', 'details', 'actions', 'createdAt'
        pass


# --- Class: AutomationCenterReferencePackModel ---
class AutomationCenterReferencePackModel(_SnapshotListModel):
    """Immutable research packs consumed by Channel Copilot planning."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterReferencePackModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'referencePackId', 'title', 'description', 'version', 'configHash', 'sourceCount', 'readyCount', 'invalidCount', 'sources', 'createdAt', 'updatedAt'
        pass


# --- Class: AutomationCenterCopilotProjectModel ---
class AutomationCenterCopilotProjectModel(_SnapshotListModel):
    """Durable Channel Copilot projects, newest activity first."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterCopilotProjectModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'projectId', 'title', 'brief', 'status', 'statusLabel', 'activeRevision', 'approvedRevision', 'deliveryMode', 'platform', 'profileId', 'channelId', 'channelProfileId', 'channelProfileVersion', 'channelProfileHash', 'channelProfile'
        pass


# --- Class: AutomationCenterCopilotMessageModel ---
class AutomationCenterCopilotMessageModel(_SnapshotListModel):
    """Ordered user/assistant conversation for the selected project."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterCopilotMessageModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'messageId', 'projectId', 'role', 'content', 'status', 'actionState', 'errorCode', 'errorMessage', 'conversationGeneration', 'createdAt', 'updatedAt'
        pass


# --- Class: AutomationCenterCopilotContentModel ---
class AutomationCenterCopilotContentModel(_SnapshotListModel):
    """Current-revision content plan ready for review and assignment."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterCopilotContentModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'contentItemId', 'projectId', 'revision', 'position', 'title', 'angle', 'workflow', 'workflowLabel', 'inputMode', 'sourceId', 'content', 'rationale', 'caption', 'readiness', 'readinessLabel'
        pass


# --- Class: AutomationCenterCopilotSourceModel ---
class AutomationCenterCopilotSourceModel(_SnapshotListModel):
    """Verified operator inputs available to the selected Copilot project."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterCopilotSourceModel" inherits "_SnapshotListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'sourceId', 'projectId', 'position', 'workflow', 'workflowLabel', 'inputMode', 'inputModeLabel', 'title', 'content', 'status', 'statusLabel', 'errorCode', 'errorMessage', 'sourceHash', 'createdAt'
        pass

