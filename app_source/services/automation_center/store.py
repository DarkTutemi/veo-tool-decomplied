"""
Decompiled / Reconstructed Module: services.automation_center.store
Source PyC: store.pyc

Docstring:
SQLite metadata store for the Tool 1 Automation Center.

The store shares one database file with ``SqliteRunJournal`` while keeping its
UI metadata in a separate table.  Connections are short-lived so the service
can be cleanly reconstructed after an application restart.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AutomationCenterStore']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
UTC = datetime.timezone.utc
_TERMINAL_STATES = {'succeeded', 'failed', 'cancelled'}
_KNOWN_STATES = {'leased', 'succeeded', 'paused', 'cancelling', 'failed', 'running', 'queued', 'reconciliation_required', 'pausing', 'starting', 'cancelled'}
_GATE_SLOT = 1
__all__ = ['AutomationCenterStore']

# --- Class: _ClosingConnection ---
class _ClosingConnection(Connection):
    """Commit or roll back, then release the Windows file handle."""
    def __exit__(self, exc_type: 'object', exc_value: 'object', traceback: 'object') -> 'bool':
        pass


# --- Class: AutomationCenterStore ---
class AutomationCenterStore:
    """Own Automation Center metadata in the shared local journal database."""
    def __init__(self, database_path: 'str | Path') -> 'None':
        pass

    def close(self) -> 'None':
        pass

    def put_job(self, job: 'AutomationJob', input_mode: 'str', title: 'str') -> 'dict[str, Any]':
        pass

    def assert_can_submit(self) -> 'None':
        pass

    def claim_submission(self, job: 'AutomationJob', input_mode: 'str', title: 'str') -> 'dict[str, Any]':
        pass

    def execution_snapshot(self) -> 'dict[str, Any]':
        pass

    def update_status(self, attempt_id: 'str', state: 'str', stage: 'str', progress: 'int', message: 'str', error_code: 'str', error_message: 'str') -> 'None':
        pass

    def get(self, attempt_id: 'str') -> 'dict[str, Any] | None':
        pass

    def list_all(self) -> 'list[dict[str, Any]]':
        pass

    def _connect(self) -> "__assert_armored__((sqlite3, b'\\x81\\xa6\\x94\\x1bR\\xb4\\xfdR\\xbe&\\xa3'))":
        pass

    def _initialize(self) -> 'None':
        pass

    def _put_job(self, connection: 'sqlite3.Connection', job: 'AutomationJob', input_mode: 'str', title: 'str', *, now: 'str | None' = None) -> 'None':
        pass

    def _resolve_owner(self, connection: 'sqlite3.Connection') -> 'dict[str, Any] | None':
        pass

    def _current_owner(self, connection: 'sqlite3.Connection', gate: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    def _find_unresolved_owner(self, connection: 'sqlite3.Connection') -> 'dict[str, Any] | None':
        pass

    def _sync_owner_state(self, connection: 'sqlite3.Connection', attempt_id: 'str', state: 'str') -> 'None':
        pass

    @staticmethod
    def _blocking_reason(state: 'str', *, source: 'str', internal_run_id: 'str' = '') -> 'str':
        pass

    @staticmethod
    def _execution_snapshot(owner: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _raise_run_active(snapshot: 'Mapping[str, Any]') -> 'None':
        pass

    def _ensure_open(self) -> 'None':
        pass

    @staticmethod
    def _row_dict(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _utc_now() -> 'str':
    pass

def _json_object(value: 'Mapping[str, Any]') -> 'str':
    pass

def _json_mapping(value: 'object') -> 'dict[str, Any]':
    pass
