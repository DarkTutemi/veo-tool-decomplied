"""
Decompiled / Reconstructed Module: services.automation_center.work_orders
Source PyC: work_orders.pyc

Docstring:
Durable sequential work orders for the Tool 1 Automation Center.

This module deliberately owns only local orchestration state.  It does not
dispatch Qt signals, open browsers, or call a workflow provider.  Callers
claim one step, durably bind the native attempt, and then mirror the native
result back into this store.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AutomationWorkOrderStore', 'ORDER_STATUSES', 'STEP_STATUSES', 'WorkOrderStore']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
UTC = datetime.timezone.utc
ORDER_STATUSES = frozenset({'running', 'queued', 'failed', 'needs_attention', 'succeeded', 'paused', 'cancelled'})
STEP_STATUSES = frozenset({'dispatching', 'skipped', 'failed', 'running', 'queued', 'needs_attention', 'succeeded', 'cancelled'})
_ACTIVE_STEP_STATUSES = ('dispatching', 'running')
_COMPLETED_STEP_STATUSES = ('succeeded', 'skipped')
_RETRYABLE_STEP_STATUSES = ('failed', 'needs_attention')
__all__ = ['AutomationWorkOrderStore', 'ORDER_STATUSES', 'STEP_STATUSES', 'WorkOrderStore']

# --- Class: _ClosingConnection ---
class _ClosingConnection(Connection):
    """Commit or roll back, then release the SQLite handle on Windows."""
    def __exit__(self, exc_type: 'object', exc_value: 'object', traceback: 'object') -> 'bool':
        pass


# --- Class: AutomationWorkOrderStore ---
class AutomationWorkOrderStore:
    """Persist fixed, sequential Automation Center work orders in SQLite."""
    def __init__(self, database_path: 'str | Path') -> 'None':
        pass

    def close(self) -> 'None':
        pass

    def pending_assignment_request(self, request_key: 'str') -> 'dict[str, Any] | None':
        pass

    def reserve_assignment_request(self, request_key: 'str', definition_hash: 'str', order_id: 'str' = '', frozen_definition_json: 'str' = '', frozen_definition_hash: 'str' = '') -> 'dict[str, Any]':
        """Reserve/reuse an order ID until the Tool 1 UI acknowledges success."""
        pass

    def acknowledge_assignment_request(self, request_key: 'str', order_id: 'str') -> 'bool':
        pass

    def create_order(self, title: 'str', steps: 'Sequence[Mapping[str, Any]]', order_id: 'str' = '', assignment_definition: 'AssignmentDefinition | Mapping[str, Any] | None' = None, approval_grant: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def get_order(self, order_id: 'str') -> 'dict[str, Any] | None':
        pass

    def list_orders(self) -> 'list[dict[str, Any]]':
        pass

    def list_steps(self, order_id: 'str') -> 'list[dict[str, Any]]':
        pass

    def step_lineage_by_attempt_ids(self, attempt_ids: 'Sequence[str]') -> 'dict[str, dict[str, Any]]':
        """Resolve bounded publish-attempt lineage without an N+1 query."""
        pass

    def start_order(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def start(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def pause_order(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def pause(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def resume_order(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def resume(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def cancel_order(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def cancel(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def claim_next_step(self, order_id: 'str' = '') -> 'dict[str, Any] | None':
        pass

    def next_wake_at(self, order_id: 'str' = '') -> 'str':
        pass

    def bind_attempt(self, step_id: 'str', job_id: 'str', attempt_id: 'str') -> 'dict[str, Any]':
        pass

    def mark_step_running(self, step_id: 'str') -> 'dict[str, Any]':
        pass

    def mark_step_succeeded(self, step_id: 'str', evidence: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def mark_step_failed(self, step_id: 'str', error_code: 'str' = '', error_message: 'str' = '') -> 'dict[str, Any]':
        pass

    def mark_step_needs_attention(self, step_id: 'str', error_code: 'str' = '', error_message: 'str' = '', evidence: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def mark_step_cancelled(self, step_id: 'str', evidence: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def resolve_step_attention(self, step_id: 'str', resolution: 'str', *, evidence: 'Mapping[str, Any] | None' = None, error_code: 'str' = '', error_message: 'str' = '') -> 'dict[str, Any]':
        pass

    def retry_step(self, step_id: 'str') -> 'dict[str, Any]':
        pass

    def reconcile_restart(self) -> 'list[dict[str, Any]]':
        pass

    def _connect(self) -> "__assert_armored__((sqlite3, b'\\x81\\xa6\\x94\\x1bR\\xb4\\xfdR\\xbe&\\xa3'))":
        pass

    def _initialize(self) -> 'None':
        pass

    @staticmethod
    def _add_columns_if_missing(connection: 'sqlite3.Connection', table: 'str', columns: 'Mapping[str, str]') -> 'None':
        pass

    @staticmethod
    def _assignment_request_key(value: 'str') -> 'str':
        pass

    def _transition_order(self, order_id: 'str', allowed: 'tuple[str, ...]', target: 'str', idempotent: 'tuple[str, ...]', set_started: 'bool' = False) -> 'dict[str, Any]':
        pass

    @staticmethod
    def _finalize_cancel(connection: 'sqlite3.Connection', order_id: 'str', now: 'str') -> 'None':
        pass

    def _stop_on_step_error(self, step_id: 'str', target: 'str', error_code: 'str', error_message: 'str', evidence: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
        pass

    def _finish_order_if_complete(self, connection: 'sqlite3.Connection', order_id: 'str', now: 'str') -> 'bool':
        pass

    def _required_step_dict(self, step_id: 'str') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _require_step(connection: 'sqlite3.Connection', step_id: 'str') -> "__assert_armored__((sqlite3, b'\\x81\\xb7\\x94\\x02'))":
        pass

    @staticmethod
    def _require_order(connection: 'sqlite3.Connection', order_id: 'str') -> "__assert_armored__((sqlite3, b'\\x81\\xb7\\x94\\x02'))":
        pass

    def _select_order(self, connection: 'sqlite3.Connection', order_id: 'str') -> "__assert_armored__((sqlite3, b'\\x81\\xb7\\x94\\x02')) | None":
        pass

    @staticmethod
    def _order_summary_sql(where: 'str' = '', order_by: 'str' = '') -> 'str':
        pass

    def _assert_same_definition(self, connection: 'sqlite3.Connection', existing: 'sqlite3.Row', title: 'str', steps: 'list[dict[str, Any]]', assignment_definition: 'AssignmentDefinition | None') -> 'None':
        pass

    @classmethod
    def _normalize_steps(cls, order_id: 'str', steps: 'Sequence[Mapping[str, Any]]') -> 'list[dict[str, Any]]':
        pass

    @staticmethod
    def _normalize_assignment_definition(value: 'AssignmentDefinition | Mapping[str, Any] | None') -> 'AssignmentDefinition | None':
        pass

    @staticmethod
    def _definition_from_row(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _definition_from_mapping(step: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _order_dict(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _step_dict(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _new_id(prefix: 'str') -> 'str':
        pass

    def _ensure_open(self) -> 'None':
        pass


# --- Class: WorkOrderStore ---
class WorkOrderStore:
    """Persist fixed, sequential Automation Center work orders in SQLite."""
    def __init__(self, database_path: 'str | Path') -> 'None':
        pass

    def close(self) -> 'None':
        pass

    def pending_assignment_request(self, request_key: 'str') -> 'dict[str, Any] | None':
        pass

    def reserve_assignment_request(self, request_key: 'str', definition_hash: 'str', order_id: 'str' = '', frozen_definition_json: 'str' = '', frozen_definition_hash: 'str' = '') -> 'dict[str, Any]':
        """Reserve/reuse an order ID until the Tool 1 UI acknowledges success."""
        pass

    def acknowledge_assignment_request(self, request_key: 'str', order_id: 'str') -> 'bool':
        pass

    def create_order(self, title: 'str', steps: 'Sequence[Mapping[str, Any]]', order_id: 'str' = '', assignment_definition: 'AssignmentDefinition | Mapping[str, Any] | None' = None, approval_grant: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def get_order(self, order_id: 'str') -> 'dict[str, Any] | None':
        pass

    def list_orders(self) -> 'list[dict[str, Any]]':
        pass

    def list_steps(self, order_id: 'str') -> 'list[dict[str, Any]]':
        pass

    def step_lineage_by_attempt_ids(self, attempt_ids: 'Sequence[str]') -> 'dict[str, dict[str, Any]]':
        """Resolve bounded publish-attempt lineage without an N+1 query."""
        pass

    def start_order(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def start(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def pause_order(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def pause(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def resume_order(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def resume(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def cancel_order(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def cancel(self, order_id: 'str') -> 'dict[str, Any]':
        pass

    def claim_next_step(self, order_id: 'str' = '') -> 'dict[str, Any] | None':
        pass

    def next_wake_at(self, order_id: 'str' = '') -> 'str':
        pass

    def bind_attempt(self, step_id: 'str', job_id: 'str', attempt_id: 'str') -> 'dict[str, Any]':
        pass

    def mark_step_running(self, step_id: 'str') -> 'dict[str, Any]':
        pass

    def mark_step_succeeded(self, step_id: 'str', evidence: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def mark_step_failed(self, step_id: 'str', error_code: 'str' = '', error_message: 'str' = '') -> 'dict[str, Any]':
        pass

    def mark_step_needs_attention(self, step_id: 'str', error_code: 'str' = '', error_message: 'str' = '', evidence: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def mark_step_cancelled(self, step_id: 'str', evidence: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def resolve_step_attention(self, step_id: 'str', resolution: 'str', *, evidence: 'Mapping[str, Any] | None' = None, error_code: 'str' = '', error_message: 'str' = '') -> 'dict[str, Any]':
        pass

    def retry_step(self, step_id: 'str') -> 'dict[str, Any]':
        pass

    def reconcile_restart(self) -> 'list[dict[str, Any]]':
        pass

    def _connect(self) -> "__assert_armored__((sqlite3, b'\\x81\\xa6\\x94\\x1bR\\xb4\\xfdR\\xbe&\\xa3'))":
        pass

    def _initialize(self) -> 'None':
        pass

    @staticmethod
    def _add_columns_if_missing(connection: 'sqlite3.Connection', table: 'str', columns: 'Mapping[str, str]') -> 'None':
        pass

    @staticmethod
    def _assignment_request_key(value: 'str') -> 'str':
        pass

    def _transition_order(self, order_id: 'str', allowed: 'tuple[str, ...]', target: 'str', idempotent: 'tuple[str, ...]', set_started: 'bool' = False) -> 'dict[str, Any]':
        pass

    @staticmethod
    def _finalize_cancel(connection: 'sqlite3.Connection', order_id: 'str', now: 'str') -> 'None':
        pass

    def _stop_on_step_error(self, step_id: 'str', target: 'str', error_code: 'str', error_message: 'str', evidence: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
        pass

    def _finish_order_if_complete(self, connection: 'sqlite3.Connection', order_id: 'str', now: 'str') -> 'bool':
        pass

    def _required_step_dict(self, step_id: 'str') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _require_step(connection: 'sqlite3.Connection', step_id: 'str') -> "__assert_armored__((sqlite3, b'\\x81\\xb7\\x94\\x02'))":
        pass

    @staticmethod
    def _require_order(connection: 'sqlite3.Connection', order_id: 'str') -> "__assert_armored__((sqlite3, b'\\x81\\xb7\\x94\\x02'))":
        pass

    def _select_order(self, connection: 'sqlite3.Connection', order_id: 'str') -> "__assert_armored__((sqlite3, b'\\x81\\xb7\\x94\\x02')) | None":
        pass

    @staticmethod
    def _order_summary_sql(where: 'str' = '', order_by: 'str' = '') -> 'str':
        pass

    def _assert_same_definition(self, connection: 'sqlite3.Connection', existing: 'sqlite3.Row', title: 'str', steps: 'list[dict[str, Any]]', assignment_definition: 'AssignmentDefinition | None') -> 'None':
        pass

    @classmethod
    def _normalize_steps(cls, order_id: 'str', steps: 'Sequence[Mapping[str, Any]]') -> 'list[dict[str, Any]]':
        pass

    @staticmethod
    def _normalize_assignment_definition(value: 'AssignmentDefinition | Mapping[str, Any] | None') -> 'AssignmentDefinition | None':
        pass

    @staticmethod
    def _definition_from_row(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _definition_from_mapping(step: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _order_dict(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _step_dict(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _new_id(prefix: 'str') -> 'str':
        pass

    def _ensure_open(self) -> 'None':
        pass


# --- Top-Level Functions ---
def _utc_now() -> 'str':
    pass

def _json_value(value: 'object') -> 'str':
    pass

def _json_load(value: 'object') -> 'Any':
    pass

def _json_round_trip(value: 'object') -> 'Any':
    pass

def _available_at_utc(value: 'object') -> 'str':
    pass
