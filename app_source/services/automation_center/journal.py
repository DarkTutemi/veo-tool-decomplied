"""
Decompiled / Reconstructed Module: services.automation_center.journal
Source PyC: journal.pyc

Docstring:
Small local recovery journal.

This is not a central job database.  It only prevents one Tool 1 installation
from blindly starting the same leased attempt twice after retries or restart.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['RunRecord', 'SqliteRunJournal']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
UTC = datetime.timezone.utc
Mapping = typing.Mapping
Sequence = typing.Sequence
__all__ = ['RunRecord', 'SqliteRunJournal']

# --- Class: RunRecord ---
class RunRecord:
    """RunRecord(attempt_id: 'str', job_id: 'str', workflow: 'str', request_hash: 'str', lease_id: 'str', lease_generation: 'int', internal_run_id: 'str' = '', observed_state: 'ObservedState' = <ObservedState.STARTING: 'starting'>, stage: 'str' = 'reserved', progress: 'int' = 0, local_ready: 'bool' = False, artifacts_published: 'bool' = False, artifacts: 'Sequence[ArtifactCandidate]' = <factory>, artifact_manifest_ids: 'Sequence[str]' = <factory>, checkpoint: 'Mapping[str, Any]' = <factory>, provider_job_ids: 'Sequence[str]' = <factory>, error_code: 'str' = '', error_message: 'str' = '')"""
    internal_run_id = ''
    observed_state = <ObservedState.STARTING: 'starting'>
    stage = 'reserved'
    progress = 0
    local_ready = False
    artifacts_published = False
    error_code = ''
    error_message = ''

    def __init__(self, attempt_id: 'str', job_id: 'str', workflow: 'str', request_hash: 'str', lease_id: 'str', lease_generation: 'int', internal_run_id: 'str' = '', observed_state: 'ObservedState' = <ObservedState.STARTING: 'starting'>, stage: 'str' = 'reserved', progress: 'int' = 0, local_ready: 'bool' = False, artifacts_published: 'bool' = False, artifacts: 'Sequence[ArtifactCandidate]' = <factory>, artifact_manifest_ids: 'Sequence[str]' = <factory>, checkpoint: 'Mapping[str, Any]' = <factory>, provider_job_ids: 'Sequence[str]' = <factory>, error_code: 'str' = '', error_message: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: SqliteRunJournal ---
class SqliteRunJournal:
    """Explicitly-created SQLite journal with atomic attempt reservation."""
    def __init__(self, path: 'str | Path') -> 'None':
        pass

    def _connect(self) -> "__assert_armored__((sqlite3, b'\\x81\\xa6\\x94\\x1bR\\xb4\\xfdR\\xbe&\\xa3'))":
        pass

    def _initialize(self) -> 'None':
        pass

    def reserve(self, job: 'AutomationJob') -> 'tuple[RunRecord, bool]':
        pass

    def get(self, attempt_id: 'str') -> 'RunRecord | None':
        pass

    def list_active(self) -> 'tuple[RunRecord, ...]':
        pass

    def list_all(self) -> 'tuple[RunRecord, ...]':
        pass

    def attach_run(self, attempt_id: 'str', internal_run_id: 'str') -> 'RunRecord':
        pass

    def refresh_lease(self, attempt_id: 'str', *, lease_id: 'str', lease_generation: 'int') -> 'RunRecord':
        pass

    def record_snapshot(self, attempt_id: 'str', snapshot: 'WorkflowSnapshot') -> 'RunRecord':
        pass

    def save_checkpoint(self, attempt_id: 'str', checkpoint: 'Mapping[str, Any]', provider_job_ids: 'Sequence[str]' = ()) -> 'RunRecord':
        pass

    def record_start_failure(self, attempt_id: 'str', error: 'WorkerControlError') -> 'RunRecord':
        pass

    def mark_reconciliation_required(self, attempt_id: 'str', message: 'str', *, error_code: 'str' = 'RUN_ID_UNCERTAIN') -> 'RunRecord':
        pass

    def mark_artifacts_published(self, attempt_id: 'str', artifact_manifest_ids: 'Sequence[str]') -> 'RunRecord':
        pass

    def _update(self, attempt_id: 'str', **changes: 'object') -> 'RunRecord':
        pass

    @staticmethod
    def _record(row: 'sqlite3.Row') -> 'RunRecord':
        pass


# --- Top-Level Functions ---
def _now() -> 'str':
    pass
