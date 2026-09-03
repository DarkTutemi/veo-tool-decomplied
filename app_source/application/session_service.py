"""
Decompiled / Reconstructed Module: application.session_service
Source PyC: session_service.pyc

Docstring:
Headless session state service.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_DEFAULT_ALLOWED_FIELDS = {'upscale_enabled', 'auto_concat', 'generation_count', 'session_id', 'account_id', 'clips', 'extend_count', 'extend_fallback_chains', 'scene_count', 'aspect_ratio', 'cards_data', 'account_email', 'sta... [truncated]
_session_service = <application.session_service.SessionService object at 0x00000264D4DB2600>

# --- Class: SessionService ---
class SessionService:
    """In-memory account/session state without PyQt AccountTabBar."""
    def __init__(self) -> 'None':
        pass

    def create_session(self, account_id: 'int', account: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
        pass

    def ensure_default_session(self) -> 'Dict[str, Any]':
        pass

    def get_session(self, session_key: 'str') -> 'Optional[Dict[str, Any]]':
        pass

    def get_current_session(self) -> 'Optional[Dict[str, Any]]':
        pass

    def list_sessions(self) -> 'Dict[str, Any]':
        pass

    def open_session(self, session_key: 'str') -> 'Dict[str, Any]':
        pass

    def update_session(self, session_key: 'str', updates: 'Dict[str, Any]', allowed: 'set[str]') -> 'bool':
        pass

    def save_session(self, session_key: 'str', updates: 'Dict[str, Any]', allowed: 'set[str] | None' = None) -> 'Dict[str, Any]':
        pass

    def delete_session(self, session_key: 'str') -> 'bool':
        pass

    def delete_session_result(self, session_key: 'str') -> 'Dict[str, Any]':
        pass

    def add_clip(self, session_key: 'str', clip: 'Dict[str, Any]', concat_input: 'Optional[Dict[str, Any]]' = None) -> 'bool':
        pass

    def list_clips(self, session_key: 'str') -> 'List[Any]':
        pass

    def session_counts_by_account(self) -> 'Dict[int, int]':
        pass

    def _copy_state(self, state: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _summarize_session(self, state: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass


# --- Top-Level Functions ---
def get_session_service() -> 'SessionService':
    pass
