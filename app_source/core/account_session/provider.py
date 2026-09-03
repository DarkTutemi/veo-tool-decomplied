"""
Decompiled / Reconstructed Module: core.account_session.provider
Source PyC: provider.pyc
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_PROJECT_ID_PATTERN = re.compile('^[A-Za-z0-9][A-Za-z0-9._~-]{0,255}$')
_provider = None
_provider_lock = <unlocked _thread.lock object at 0x00000264D8EE3B40>

# --- Class: AccountSessionProvider ---
class AccountSessionProvider:
    def __init__(self, account_manager=None, browser_port=None, failure_policy=None):
        pass

    def _am(self):
        pass

    def _browser(self):
        pass

    def _project_lock(self, key: 'str') -> "__assert_armored__((threading, b'\\x81\\xa9\\x94\\x16W'))":
        pass

    def _refresh_lock(self, key: 'str') -> "__assert_armored__((threading, b'\\x81\\xa9\\x94\\x16W'))":
        pass

    def _find_account(self, *, account_name=None, account_email=None, account_id=None) -> 'dict[str, Any] | None':
        pass

    def resolve_identity(self, *, account_name=None, account_email=None, account_id=None) -> 'AccountIdentity':
        pass

    def _account_for_identity(self, identity: 'AccountIdentity') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _login_flow_active(browser, identity: 'AccountIdentity') -> 'bool':
        pass

    def _checkpoint_or_login_in_progress(self, identity: 'AccountIdentity') -> 'list[dict[str, Any]]':
        pass

    def get_auth_cookies(self, identity: 'AccountIdentity') -> 'list[dict[str, Any]]':
        pass

    def get_checkpoint_auth_cookies(self, identity: 'AccountIdentity') -> 'list[dict[str, Any]]':
        pass

    def _snapshot_from_account(self, identity: 'AccountIdentity', account: 'dict[str, Any]') -> 'SessionSnapshot':
        pass

    def _save_snapshot(self, snapshot: 'SessionSnapshot') -> 'None':
        pass

    def sync_from_browser(self, identity: 'AccountIdentity', *, force_refresh: 'bool' = False) -> 'SessionSnapshot':
        pass

    def _sync_via_port(self, identity: 'AccountIdentity', port) -> 'SessionSnapshot':
        pass

    def _snapshot_from_browser_result(self, identity: 'AccountIdentity', result: 'dict[str, Any]', *, persist: 'bool' = True) -> 'SessionSnapshot':
        pass

    def _sync_via_persistent(self, identity: 'AccountIdentity', *, force_refresh: 'bool' = False) -> 'SessionSnapshot':
        pass

    def get_access_token(self, identity: 'AccountIdentity', *, force_refresh: 'bool' = False) -> 'str':
        pass

    def peek_access_token(self, identity: 'AccountIdentity') -> 'str':
        pass

    def ensure_project(self, identity: 'AccountIdentity', *, tool_name: 'str' = 'PINHOLE') -> 'str':
        pass

    def list_projects(self, identity: 'AccountIdentity', *, tool_name: 'str' = 'PINHOLE', page_size: 'int' = 20) -> 'list[dict[str, Any]]':
        pass

    def set_project(self, identity: 'AccountIdentity', project_id: 'str') -> 'str':
        pass

    def invalidate_token(self, identity: 'AccountIdentity', reason: 'str' = '') -> 'None':
        pass

    def request_login_owner_probe(self, identity: 'AccountIdentity', *, invalidate_token: 'bool' = False) -> 'bool':
        pass

    def record_http_result(self, identity: 'AccountIdentity', *, status_code: 'int', error_text: 'str' = '', auto_act: 'bool' = True) -> 'AuthDecision':
        pass


# --- Top-Level Functions ---
def _normalize_project_id(value: 'Any') -> 'str':
    pass

def _cookie_identity(cookie: 'dict[str, Any]') -> 'tuple[str, str, str, str]':
    pass

def _merge_handoff_checkpoint(checkpoint: 'list[dict[str, Any]]', observed: 'list[dict[str, Any]]') -> 'list[dict[str, Any]]':
    pass

def get_account_session_provider() -> 'AccountSessionProvider':
    pass
