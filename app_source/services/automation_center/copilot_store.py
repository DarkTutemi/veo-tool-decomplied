"""
Decompiled / Reconstructed Module: services.automation_center.copilot_store
Source PyC: copilot_store.pyc

Docstring:
Durable project/chat/revision store for Tool 1 Channel Copilot.

The store owns planning metadata only.  It cannot execute workflows, open a
browser, or publish.  Every connection is short lived so the frozen Windows
application can release the database cleanly during shutdown and upgrades.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['CopilotStore']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
UTC = datetime.timezone.utc
Iterator = typing.Iterator
_PROJECT_STATUSES = frozenset({'draft', 'active', 'approved', 'prepared'})
_MESSAGE_ROLES = frozenset({'assistant', 'system', 'user'})
_MESSAGE_STATUSES = frozenset({'pending', 'completed', 'failed', 'streaming'})
_ACTION_STATES = frozenset({'invalid', 'validated', 'none'})
_CONVERSATION_STATES = frozenset({'account_drift', 'active', 'bound', 'needs_attention'})
__all__ = ['CopilotStore']

# --- Class: CopilotStore ---
class CopilotStore:
    """SQLite-backed source of truth for Channel Copilot planning state."""
    def __init__(self, database_path: 'str | Path') -> 'None':
        pass

    def _connect(self) -> "Iterator[__assert_armored__((sqlite3, b'\\x81\\xa6\\x94\\x1bR\\xb4\\xfdR\\xbe&\\xa3'))]":
        pass

    def _initialize(self) -> 'None':
        pass

    @staticmethod
    def _add_column_if_missing(connection: 'sqlite3.Connection', table: 'str', column: 'str', declaration: 'str') -> 'None':
        pass

    @staticmethod
    def _recover_interrupted_turns(connection: 'sqlite3.Connection') -> 'None':
        pass

    def create_project(self, title: 'str', brief: 'str') -> 'dict[str, Any]':
        pass

    def get_project(self, project_id: 'str') -> 'dict[str, Any]':
        pass

    def list_projects(self) -> 'list[dict[str, Any]]':
        pass

    def set_channel_profile(self, project_id: 'str', channel_profile_id: 'str') -> 'dict[str, Any]':
        pass

    def set_reference_pack(self, project_id: 'str', reference_pack_id: 'str') -> 'dict[str, Any]':
        pass

    def upsert_sources(self, project_id: 'str', sources: 'Sequence[Mapping[str, Any]]') -> 'dict[str, Any]':
        pass

    def list_sources(self, project_id: 'str') -> 'list[dict[str, Any]]':
        pass

    def set_delivery(self, project_id: 'str', delivery: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    def get_delivery(self, project_id: 'str') -> 'dict[str, Any]':
        pass

    def append_message(self, project_id: 'str', role: 'str', content: 'str') -> 'dict[str, Any]':
        pass

    def get_conversation(self, project_id: 'str') -> 'dict[str, Any]':
        pass

    def bind_conversation(self, project_id: 'str', account: 'Mapping[str, Any]') -> 'dict[str, Any]':
        """Bind a project to one immutable account/surface before first send."""
        pass

    def mark_conversation_error(self, project_id: 'str', *, error_code: 'str', error_message: 'str', state: 'str' = 'needs_attention') -> 'dict[str, Any]':
        pass

    def begin_turn(self, project_id: 'str', user_message: 'str') -> 'dict[str, Any]':
        pass

    def get_message(self, message_id: 'str') -> 'dict[str, Any]':
        pass

    def complete_turn(self, project_id: 'str', assistant_message_id: 'str', assistant_message: 'str', conversation: 'Mapping[str, Any]', *, draft: 'Mapping[str, Any] | None' = None, action_state: 'str' = 'none', action_error_code: 'str' = '', action_error_message: 'str' = '', reference_pack: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def fail_turn(self, project_id: 'str', assistant_message_id: 'str', *, partial_content: 'str' = '', error_code: 'str', error_message: 'str') -> 'dict[str, Any]':
        pass

    def resume_conversation(self, project_id: 'str') -> 'dict[str, Any]':
        pass

    def reset_conversation(self, project_id: 'str', account: 'Mapping[str, Any]') -> 'dict[str, Any]':
        """Explicitly start a new chat generation while retaining message audit."""
        pass

    def _insert_revision(self, connection: 'sqlite3.Connection', project: 'Mapping[str, Any]', draft: 'Mapping[str, Any]', reference_pack: 'Mapping[str, Any]', now: 'str') -> 'int':
        pass

    def apply_draft(self, project_id: 'str', draft: 'Mapping[str, Any]', user_message: 'str' = '', reference_pack: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def approve_revision(self, project_id: 'str', revision: 'int') -> 'dict[str, Any]':
        pass

    def save_prepared_assignments(self, project_id: 'str', revision: 'int', definitions: 'Mapping[str, Mapping[str, Any]]') -> 'dict[str, Any]':
        pass

    def get_content_item(self, project_id: 'str', content_item_id: 'str') -> 'dict[str, Any]':
        pass

    def mark_assigned(self, project_id: 'str', content_item_id: 'str', order_id: 'str') -> 'dict[str, Any]':
        pass

    def snapshot(self, project_id: 'str' = '') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _project_row(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _message_row(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _conversation_row(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _content_row(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _source_row(row: 'sqlite3.Row') -> 'dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _utc_now() -> 'str':
    pass

def _json(value: 'Any') -> 'str':
    pass

def _load_json(value: 'Any', fallback: 'Any') -> 'Any':
    pass
