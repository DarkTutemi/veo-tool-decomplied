"""
Decompiled / Reconstructed Module: services.automation_center.adapters.timemachine
Source PyC: timemachine.pyc

Docstring:
Durable Tool 1 bridge for Time Machine automation.

The native Time Machine parent runtime is still owned by its Qt controller.
Automation Center workers therefore never call that controller directly.  They
commit an immutable request to SQLite first and then emit a process-local wakeup
that a GUI-thread consumer may receive through a queued Qt signal.

The durable target id is derived from the Automation Center attempt id.  A
process restart never re-submits an uncertain request: non-terminal records from
another process boot are projected as ``reconciliation_required``.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['TimeMachineAutomationStore', 'TimeMachineWorkflowAdapter', 'has_timemachine_consumer', 'notify_timemachine_consumers', 'register_timemachine_consumer', 'stable_timemachine_target_id', 'unregister_timemachine_consumer']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
UTC = datetime.timezone.utc
NAMESPACE_URL = UUID('6ba7b811-9dad-11d1-80b4-00c04fd430c8')
_PROCESS_BOOT_ID = 'boot-432d85c9-cb40-4132-87ab-f6adabfa3860'
_NON_TERMINAL_STATES = {'running', 'dispatching', 'queued', 'paused'}
_SUCCESS_STAGE_STATES = {'completed', 'skipped', 'not_required', 'complete'}
_IMAGE_EXTENSIONS = {'.png', '.jpg', '.jpeg', '.webp'}
_CONSUMER_LOCK = <unlocked _thread.RLock object owner=0 count=0 at 0x00000264E020CE80>
_CONSUMERS = {}
__all__ = ['TimeMachineAutomationStore', 'TimeMachineWorkflowAdapter', 'has_timemachine_consumer', 'notify_timemachine_consumers', 'register_timemachine_consumer', 'stable_timemachine_target_id', 'unregister_ti... [truncated]

# --- Class: _ClosingConnection ---
class _ClosingConnection(Connection):
    def __exit__(self, exc_type: 'object', exc_value: 'object', traceback: 'object') -> 'bool':
        pass


# --- Class: TimeMachineAutomationStore ---
class TimeMachineAutomationStore:
    """Short-lived-connection SQLite inbox and parent-run projection."""
    def __init__(self, database_path: 'str | Path', boot_id: 'str' = 'boot-432d85c9-cb40-4132-87ab-f6adabfa3860') -> 'None':
        pass

    def enqueue(self, job: 'AutomationJob') -> 'dict[str, Any]':
        pass

    def claim_next(self, consumer_id: 'str') -> 'dict[str, Any] | None':
        pass

    def acknowledge(self, target_run_id: 'str') -> 'None':
        pass

    def reject(self, target_run_id: 'str', code: 'str', message: 'str') -> 'None':
        pass

    def update_projections(self, projections: 'Sequence[Mapping[str, Any]]') -> 'int':
        pass

    def get_by_target(self, target_run_id: 'str') -> 'dict[str, Any] | None':
        pass

    def reconcile_restart(self) -> 'int':
        """Fail closed for requests owned by another process boot."""
        pass

    def list_all(self) -> 'list[dict[str, Any]]':
        pass

    def _connect(self) -> "__assert_armored__((sqlite3, b'\\x81\\xa6\\x94\\x1bR\\xb4\\xfdR\\xbe&\\xa3'))":
        pass

    def _initialize(self) -> 'None':
        pass

    @staticmethod
    def _row(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass


# --- Class: TimeMachineWorkflowAdapter ---
class TimeMachineWorkflowAdapter:
    """Adapter from the local runtime into the durable Time Machine inbox."""
    workflow = 'timemachine'
    schema_versions = ('1.0',)

    def __init__(self, database_path: 'str | Path', config_provider: 'Callable[[], Mapping[str, Any]] | None' = None, admission_provider: 'Callable[[], Mapping[str, Any] | None] | None' = None, boot_id: 'str' = 'boot-432d85c9-cb40-4132-87ab-f6adabfa3860') -> 'None':
        pass

    def capabilities(self) -> 'dict[str, Any]':
        pass

    def validate(self, job: 'AutomationJob') -> 'None':
        pass

    def start(self, job: 'AutomationJob', *, on_internal_run_created: 'Callable[[str], None]') -> 'str':
        pass

    def snapshot(self, internal_run_id: 'str') -> 'WorkflowSnapshot':
        pass

    def collect_artifacts(self, internal_run_id: 'str') -> 'tuple[ArtifactCandidate, ...]':
        pass

    def ensure_started(self, internal_run_id: 'str') -> 'WorkflowSnapshot':
        pass

    def pause_at_safe_point(self, internal_run_id: 'str') -> 'WorkflowSnapshot':
        pass

    def request_cancel(self, internal_run_id: 'str') -> 'WorkflowSnapshot':
        pass

    def reconcile(self, internal_run_id: 'str', *, checkpoint: 'dict[str, Any]', provider_job_ids: 'tuple[str, ...]') -> 'WorkflowSnapshot':
        pass

    def _admission_blocker(self) -> 'dict[str, Any] | None':
        pass

    def _automation_config(self, job: 'AutomationJob') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _request_payload(job: 'AutomationJob') -> 'dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _utc_now() -> 'str':
    pass

def _text(value: 'Any') -> 'str':
    pass

def _mapping(value: 'Any') -> 'dict[str, Any]':
    pass

def _json_object(value: 'Any') -> 'str':
    pass

def _decode_object(value: 'Any') -> 'dict[str, Any]':
    pass

def stable_timemachine_target_id(attempt_id: 'str') -> 'str':
    pass

def _database_key(database_path: 'str | Path') -> 'str':
    pass

def register_timemachine_consumer(database_path: 'str | Path', wakeup: 'Callable[[], None]') -> 'str':
    pass

def unregister_timemachine_consumer(database_path: 'str | Path', token: 'str') -> 'None':
    pass

def has_timemachine_consumer(database_path: 'str | Path') -> 'bool':
    pass

def notify_timemachine_consumers(database_path: 'str | Path') -> 'int':
    pass

def _projection_state(item: 'Mapping[str, Any]') -> 'str':
    pass

def _default_config_provider() -> 'Mapping[str, Any]':
    pass

def _default_admission_provider() -> 'Mapping[str, Any] | None':
    pass

def _completion_error(row: 'Mapping[str, Any]') -> 'tuple[str, str] | None':
    pass

def _artifact_candidates(row: 'Mapping[str, Any]') -> 'tuple[ArtifactCandidate, ...]':
    pass
