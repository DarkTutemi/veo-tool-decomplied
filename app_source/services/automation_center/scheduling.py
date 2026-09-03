"""
Decompiled / Reconstructed Module: services.automation_center.scheduling
Source PyC: scheduling.pyc

Docstring:
Tool 1-owned recurrence, capacity, and schedule-occurrence state.

The scheduler is deliberately a local persistence/domain service.  It never
starts a worker, opens a browser, or publishes by itself.  A caller previews a
rule, freezes an allowed occurrence into Assignment V2, and only then asks the
existing sequential work-order coordinator to execute it.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['LocalSchedulingStore', 'normalize_capacity_policy', 'normalize_recurrence_rule']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
UTC = datetime.timezone.utc
Iterator = typing.Iterator
NAMESPACE_URL = UUID('6ba7b811-9dad-11d1-80b4-00c04fd430c8')
_SUPPORTED_PLATFORMS = frozenset({'tiktok', 'youtube', 'facebook'})
_FREQUENCIES = frozenset({'weekly', 'daily'})
_RESERVED_OCCURRENCE_STATES = ('materialized', 'queued', 'running', 'published', 'needs_attention')
_MAX_PREVIEW_DAYS = 366
_MAX_PREVIEW_ITEMS = 500
_MAX_ASSIGNMENT_BYTES = 33554432
__all__ = ['LocalSchedulingStore', 'normalize_capacity_policy', 'normalize_recurrence_rule']

# --- Class: LocalSchedulingStore ---
class LocalSchedulingStore:
    """Versioned local schedule policy, recurrence, and occurrence store."""
    def __init__(self, database_path: 'str | Path') -> 'None':
        pass

    def _connect(self) -> "Iterator[__assert_armored__((sqlite3, b'\\x81\\xa6\\x94\\x1bR\\xb4\\xfdR\\xbe&\\xa3'))]":
        pass

    def _initialize(self) -> 'None':
        pass

    def save_capacity_policy(self, value: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    def list_capacity_policies(self) -> 'list[dict[str, Any]]':
        pass

    def latest_capacity_policy(self, platform: 'str', channel_id: 'str') -> 'dict[str, Any] | None':
        pass

    def save_recurrence_rule(self, value: 'Mapping[str, Any]', assignment: 'AssignmentDefinition') -> 'dict[str, Any]':
        pass

    def list_recurrence_rules(self) -> 'list[dict[str, Any]]':
        pass

    def get_recurrence_rule(self, identity: 'str') -> 'dict[str, Any] | None':
        pass

    def set_recurrence_state(self, identity: 'str', state: 'str') -> 'dict[str, Any]':
        pass

    def preview_recurrence(self, identity: 'str', window_start_utc: 'str', window_end_utc: 'str', limit: 'int' = 100) -> 'dict[str, Any]':
        pass

    def preview_conflict(self, *, platform: 'str', channel_id: 'str', scheduled_at_utc: 'str', timezone_name: 'str', duration_seconds: 'int' = 60, exclude_occurrence_id: 'str' = '', reservations: 'Iterable[Mapping[str, Any]]' = ()) -> 'dict[str, Any]':
        pass

    def get_occurrence(self, occurrence_id: 'str') -> 'dict[str, Any] | None':
        pass

    def record_occurrence(self, proposal: 'Mapping[str, Any]', assignment: 'AssignmentDefinition', *, order_id: 'str' = '', status: 'str', conflicts: 'Sequence[Mapping[str, Any]]' = ()) -> 'dict[str, Any]':
        pass

    def list_occurrences_page(self, *, platform: 'str' = '', channel_id: 'str' = '', status: 'str' = '', query: 'str' = '', limit: 'int' = 100, offset: 'int' = 0) -> 'dict[str, Any]':
        pass

    def list_attention_page(self, *, platform: 'str' = '', channel_id: 'str' = '', case_type: 'str' = '', query: 'str' = '', limit: 'int' = 100, offset: 'int' = 0) -> 'dict[str, Any]':
        """Page every actionable uncertainty from one local read model."""
        pass

    def _expand_rule(self, rule: 'Mapping[str, Any]', start: 'datetime', end: 'datetime', limit: 'int') -> 'tuple[list[dict[str, Any]], list[dict[str, Any]]]':
        pass

    def _bookings(self, platform: 'str', channel_id: 'str', exclude_occurrence_id: 'str') -> 'list[dict[str, Any]]':
        pass

    @staticmethod
    def _conflict_blockers(run_at: 'datetime', duration_seconds: 'int', timezone_name: 'str', policy: 'Mapping[str, Any] | None', bookings: 'Sequence[Mapping[str, Any]]') -> 'list[dict[str, Any]]':
        pass

    def _recommend_slot(self, run_at: 'datetime', duration_seconds: 'int', timezone_name: 'str', policy: 'Mapping[str, Any]', bookings: 'Sequence[Mapping[str, Any]]') -> 'dict[str, Any] | None':
        pass

    @staticmethod
    def _capacity_row(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _recurrence_row(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _occurrence_row(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _attention_row(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _utc_now() -> 'str':
    pass

def _canonical_json(value: 'Any', *, code: 'str', message: 'str') -> 'str':
    pass

def _config_hash(value: 'Any') -> 'str':
    pass

def _bounded_text(value: 'Any', field: 'str', maximum: 'int' = 256) -> 'str':
    pass

def _required_text(value: 'Any', field: 'str', maximum: 'int' = 256) -> 'str':
    pass

def _timezone_name(value: 'Any') -> 'str':
    pass

def _utc_iso(value: 'Any', field: 'str') -> 'str':
    pass

def _date_text(value: 'Any', field: 'str') -> 'str':
    pass

def _local_time_text(value: 'Any', field: 'str' = 'local_time') -> 'str':
    pass

def _weekdays(value: 'Any', *, required: 'bool' = False) -> 'list[int]':
    pass

def _capacity_windows(value: 'Any') -> 'list[dict[str, Any]]':
    pass

def normalize_capacity_policy(value: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def normalize_recurrence_rule(value: 'Mapping[str, Any]', assignment: 'AssignmentDefinition') -> 'dict[str, Any]':
    pass
