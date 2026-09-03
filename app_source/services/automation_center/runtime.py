"""
Decompiled / Reconstructed Module: services.automation_center.runtime
Source PyC: runtime.pyc

Docstring:
Tool 1-local automation runtime.

This runtime enforces local idempotency and workflow lifecycle semantics. It
has no network sync, remote lease, Worker Gateway, or object-storage role.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AutomationRuntime', 'WorkflowRegistry']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Iterable = typing.Iterable
Mapping = typing.Mapping
Sequence = typing.Sequence
__all__ = ['AutomationRuntime', 'WorkflowRegistry']

# --- Class: WorkflowRegistry ---
class WorkflowRegistry:
    def __init__(self, adapters: 'Iterable[WorkflowAdapter]' = ()) -> 'None':
        pass

    def register(self, adapter: 'WorkflowAdapter') -> 'None':
        pass

    def get(self, workflow: 'str') -> 'WorkflowAdapter':
        pass

    def capabilities(self) -> 'list[dict]':
        pass


# --- Class: AutomationRuntime ---
class AutomationRuntime:
    """Runs adapters without owning HTTP, threads, timers, or application startup."""
    def __init__(self, *, journal: 'SqliteRunJournal', registry: 'WorkflowRegistry') -> 'None':
        pass

    def capabilities(self) -> 'list[dict]':
        pass

    def validate(self, job: 'AutomationJob') -> 'None':
        pass

    def has_attempt(self, attempt_id: 'str') -> 'bool':
        pass

    def identity_for_attempt(self, attempt_id: 'str') -> 'AutomationIdentity':
        pass

    def refresh_lease(self, attempt_id: 'str', *, lease_id: 'str', lease_generation: 'int') -> 'AutomationIdentity':
        pass

    def save_checkpoint(self, attempt_id: 'str', checkpoint: 'Mapping[str, Any]', provider_job_ids: 'Sequence[str]' = ()) -> 'None':
        pass

    def active_count(self) -> 'int':
        pass

    def lease_heartbeats(self) -> 'list[dict]':
        pass

    def observations(self) -> 'list[dict]':
        pass

    def start(self, job: 'AutomationJob') -> 'WorkflowSnapshot':
        pass

    def snapshot(self, attempt_id: 'str') -> 'WorkflowSnapshot':
        pass

    def pause_at_safe_point(self, attempt_id: 'str') -> 'WorkflowSnapshot':
        pass

    def resume(self, attempt_id: 'str') -> 'WorkflowSnapshot':
        pass

    def request_cancel(self, attempt_id: 'str') -> 'WorkflowSnapshot':
        pass

    def ensure_started(self, attempt_id: 'str') -> 'WorkflowSnapshot':
        pass

    def reconcile(self, attempt_id: 'str') -> 'WorkflowSnapshot':
        pass

    def require_reconciliation(self, attempt_id: 'str', message: 'str', *, error_code: 'str' = 'RECONCILIATION_REQUIRED') -> 'WorkflowSnapshot':
        pass

    def confirm_artifacts_published(self, attempt_id: 'str', artifact_manifest_ids: 'Sequence[str]') -> 'WorkflowSnapshot':
        pass

    def confirm_local_artifacts_ready(self, attempt_id: 'str', artifact_evidence_ids: 'Sequence[str]') -> 'WorkflowSnapshot':
        """Complete a local-only attempt after every required artifact is verified.

        ``artifacts_published`` remains the legacy SQLite column name so existing
        worker-control journals stay readable.  The Automation Center uses this
        neutral API and never performs a server upload or manifest confirmation."""
        pass

    @staticmethod
    def _snapshot_from_record(record: 'RunRecord') -> 'WorkflowSnapshot':
        pass

    def _required_record(self, attempt_id: 'str') -> 'RunRecord':
        pass

    def _command_target(self, attempt_id: 'str') -> 'tuple[RunRecord, WorkflowAdapter]':
        pass

