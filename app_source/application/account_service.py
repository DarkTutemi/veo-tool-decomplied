"""
Decompiled / Reconstructed Module: application.account_service
Source PyC: account_service.pyc

Docstring:
Headless account catalog service.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
DB_NAME = 'veoflow.db'
ACCOUNT_NATIVE_ACTIONS = {'add_account': {'label': 'Add Account', 'category': 'account_browser', 'reason': 'requires visible Google browser login, cookie capture, and account catalog import', 'requires': ['native browser brid... [truncated]
ACCOUNT_ACTION_ALIASES = {'Add Account': 'add_account', 'Open Browser': 'open_browser', 'Refresh Account Cookies': 'refresh_cookies', 'Reset Browser Profiles': 'browser_profile_cleanup', 'Browser Profile Cleanup': 'browser_pr... [truncated]
ProxyCheckCallback = typing.Callable[[int, int, typing.Dict[str, typing.Any]], NoneType]
ProxyChecker = typing.Callable[[typing.Any], tuple[bool, float, str]]

# --- Class: AccountService ---
class AccountService:
    """Reads account metadata without importing Qt AccountManager."""
    def __init__(self, proxy_manager: 'Any | None' = None, *, browser_manager: 'Any | None' = None, account_manager: 'Any | None' = None, session_manager_factory: 'Callable[..., Any] | None' = None, credits_checker: 'Callable[..., Dict[str, Any]] | None' = None, browser_token_provider: 'Callable[..., Dict[str, Any]] | None' = None, account_session_provider: 'Any | None' = None) -> 'None':
        pass

    def list_accounts(self, include_inactive: 'bool' = True) -> 'List[Dict[str, Any]]':
        pass

    def _list_account_rows(self) -> 'List[Dict[str, Any]]':
        pass

    def get_account(self, *, account_id: 'int | str | None' = None, email: 'str | None' = None) -> 'Dict[str, Any] | None':
        pass

    def _browser_manager(self) -> 'Any':
        pass

    def _account_manager(self) -> 'Any | None':
        pass

    def _account_session_provider(self):
        pass

    def _session_manager_factory(self) -> 'Callable[..., Any]':
        pass

    def _credits_checker(self) -> 'Callable[..., Dict[str, Any]]':
        pass

    def _browser_token_provider(self) -> 'Callable[..., Dict[str, Any]]':
        pass

    def update_account(self, *, account_id: 'int | str | None' = None, email: 'str | None' = None, updates: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
        pass

    def delete_account(self, *, account_id: 'int | str | None' = None, email: 'str | None' = None) -> 'Dict[str, Any]':
        pass

    def _delete_json_row(self, *, account_id: 'int | str | None' = None, email: 'str | None' = None) -> 'bool':
        pass

    def toggle_account(self, email: 'str', enabled: 'bool') -> 'bool':
        pass

    def check_accounts(self, emails: 'Optional[List[str]]' = None) -> 'Dict[str, Any]':
        pass

    def list_proxies(self) -> 'List[Dict[str, Any]]':
        pass

    def proxy_choices(self, email: 'str') -> 'Dict[str, Any]':
        pass

    def add_proxies(self, raw_lines: 'List[str]', rotate_url: 'str' = '', test_flow: 'bool' = True) -> 'Dict[str, Any]':
        pass

    def remove_proxy(self, proxy_key: 'str') -> 'Dict[str, Any]':
        pass

    def remove_dead_proxies(self) -> 'Dict[str, Any]':
        pass

    def assign_proxy(self, email: 'str', proxy_key: 'str') -> 'Dict[str, Any]':
        pass

    def set_proxy_rotate_url(self, proxy_key: 'str', rotate_url: 'str') -> 'Dict[str, Any]':
        pass

    def rotate_proxy_ip(self, proxy_key: 'str') -> 'Dict[str, Any]':
        pass

    def clear_account_proxies(self, emails: 'Optional[List[str]]' = None) -> 'Dict[str, Any]':
        pass

    def move_proxy_assignment(self, old_email: 'str', new_email: 'str') -> 'Dict[str, Any]':
        pass

    def clear_proxy_assignment(self, email: 'str') -> 'Dict[str, Any]':
        pass

    def check_proxies(self, proxy_keys: 'Optional[List[str]]' = None, *, timeout: 'int' = 15, checker: 'ProxyChecker | None' = None, progress_callback: 'ProxyCheckCallback | None' = None) -> 'Dict[str, Any]':
        pass

    def account_action_blocker(self, action: 'str') -> 'Dict[str, Any]':
        pass

    def resource_action_blocker(self, action: 'str') -> 'Dict[str, Any]':
        pass

    def native_action_summary(self) -> 'Dict[str, Any]':
        pass

    def native_action_contract(self, action: 'str', context: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
        pass

    def resource_status(self) -> 'Dict[str, Any]':
        pass

    def open_resource_path_contract(self, path_kind: 'str') -> 'Dict[str, Any]':
        pass

    def open_database_path_contract(self) -> 'Dict[str, Any]':
        pass

    def open_local_tts_path_contract(self) -> 'Dict[str, Any]':
        pass

    def open_resources_path_contract(self) -> 'Dict[str, Any]':
        pass

    def add_account_contract(self) -> 'Dict[str, Any]':
        pass

    def open_browser_contract(self, *, account_id: 'int | str | None' = None, email: 'str | None' = None) -> 'Dict[str, Any]':
        pass

    def refresh_cookies_contract(self, *, account_id: 'int | str | None' = None, email: 'str | None' = None) -> 'Dict[str, Any]':
        pass

    def open_browser(self, *, account_id: 'int | str | None' = None, email: 'str | None' = None) -> 'Dict[str, Any]':
        pass

    def open_login_browser(self, *, account_id: 'int | str | None' = None, email: 'str | None' = None) -> 'Dict[str, Any]':
        pass

    def _open_existing_account_browser(self, *, account_id: 'int | str | None', email: 'str | None', login_flow: 'bool') -> 'Dict[str, Any]':
        pass

    def check_account(self, *, account_id: 'int | str | None' = None, email: 'str | None' = None) -> 'Dict[str, Any]':
        pass

    def move_database_contract(self) -> 'Dict[str, Any]':
        pass

    def move_local_tts_contract(self) -> 'Dict[str, Any]':
        pass

    def browser_profile_cleanup_contract(self) -> 'Dict[str, Any]':
        pass

    def browser_profile_cleanup(self) -> 'Dict[str, Any]':
        pass

    def move_database(self, target_dir: 'str') -> 'Dict[str, Any]':
        pass

    def move_local_tts(self, target_dir: 'str') -> 'Dict[str, Any]':
        pass

    def update_resource_install_dir(self, path: 'str') -> 'Dict[str, Any]':
        pass

    def set_local_tts_auto_start(self, enabled: 'bool') -> 'Dict[str, Any]':
        pass

    def resolve_credentials(self, *, account_id: 'int | str | None' = None, email: 'str | None' = None, name: 'str | None' = None) -> 'Dict[str, str]':
        pass

    def _proxy_manager(self) -> 'Any':
        pass


# --- Top-Level Functions ---
def _accounts_path() -> 'Path':
    pass

def _appdata_root() -> 'Path':
    pass

def _local_appdata_root() -> 'Path':
    pass

def _accounts_state_path() -> 'Path':
    pass

def _read_json(path: 'Path') -> 'Any':
    pass

def _write_json(path: 'Path', payload: 'Any') -> 'bool':
    pass

def _read_app_settings() -> 'Dict[str, Any]':
    pass

def _database_dir_readonly() -> 'Path':
    pass

def _default_resource_base() -> 'Path':
    pass

def _resource_base_readonly() -> 'Path':
    pass

def _local_tts_install_dir() -> 'Path':
    pass

def _local_tts_exe_path() -> 'Path':
    pass

def _format_bytes(size: 'int') -> 'str':
    pass

def _sqlite_size_bytes(db_path: 'Path') -> 'int':
    pass

def _folder_size_bytes(path: 'Path') -> 'tuple[int, int]':
    pass

def _safe_resolved(path: 'Path') -> 'str':
    pass

def _accounts_store() -> 'tuple[Any, Any]':
    pass

def _iter_account_items(container: 'Any') -> 'list[tuple[Any, Dict[str, Any]]]':
    pass

def _raw_accounts() -> 'List[Dict[str, Any]]':
    pass

def _save_accounts_store(raw: 'Any') -> 'bool':
    pass

def _read_state() -> 'Dict[str, Any]':
    pass

def _normalize_email(value: 'Any') -> 'str':
    pass

def _account_email(account: 'Dict[str, Any]') -> 'str':
    pass

def _account_name(account: 'Dict[str, Any]') -> 'str':
    pass

def _account_id(account: 'Dict[str, Any]') -> 'str':
    pass

def _find_account_item(container: 'Any', *, account_id: 'int | str | None' = None, email: 'str | None' = None) -> 'tuple[Any, Dict[str, Any] | None]':
    pass

def _normalize_account(raw: 'Dict[str, Any]', index: 'int', overrides: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _credential_value(account: 'Dict[str, Any]') -> 'str':
    pass

def _sync_enabled_override(old_email: 'str', new_email: 'str | None' = None, *, remove: 'bool' = False) -> 'None':
    pass

def _coerce_int(value: 'Any', fallback: 'int' = 0) -> 'int':
    pass

def _clean_updates(updates: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _enum_value(value: 'Any', default: 'str' = '') -> 'str':
    pass

def _proxy_status(proxy: 'Any') -> 'str':
    pass

def _proxy_type(proxy: 'Any') -> 'str':
    pass

def _proxy_row(proxy: 'Any', *, message: 'str' = '') -> 'Dict[str, Any]':
    pass

def _blocked_action(action: 'str', reason: 'str', *, label: 'str | None' = None, code: 'str | None' = None, category: 'str' = 'native', context: 'Dict[str, Any] | None' = None, requires: 'List[str] | None' = None, destructive: 'bool' = False) -> 'Dict[str, Any]':
    pass

def _open_local_path_contract(action: 'str', label: 'str', path: 'str', *, code: 'str', path_kind: 'str') -> 'Dict[str, Any]':
    pass

def get_account_service() -> 'AccountService':
    pass
