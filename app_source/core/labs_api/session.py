"""
Decompiled / Reconstructed Module: core.labs_api.session
Source PyC: session.pyc

Docstring:
core/labs_api/session.py — identity / token / project / cookies / session id.

Single source of truth = AccountSessionProvider (DB-backed, refreshed by the farm
browser). Pure delegation + a thread-local for per-thread provider exclusion.

Ported verbatim from core/api_client.py:
  _identity (25) · _access_token (37) · _project_id (43) · set/clear_exclude_providers
  (56-63) · _labs_session_id (1157) · _trpc_cookies_for_account (5307)
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
Dict = typing.Dict
Set = typing.Set
_thread_local = <_thread._local object at 0x00000264DD1750D0>
http_requests = <core.labs_api.proxy.ProxyRequests object at 0x00000264DD151E20>

# --- Top-Level Functions ---
def resolve_identity(account_name: 'Optional[str]' = None, account_email: 'Optional[str]' = None, account_id=None) -> 'AccountIdentity':
    pass

def access_token(identity: 'AccountIdentity', *, force_refresh: 'bool' = False) -> 'str':
    pass

def project_id(identity: 'AccountIdentity', *, tool_name: 'str' = 'PINHOLE') -> 'str':
    pass

def labs_session_id(session_id: 'Optional[str]' = None) -> 'str':
    pass

def trpc_cookies_for_account(account_name: 'str') -> 'Optional[Dict[str, str]]':
    pass

def refresh_trpc_cookies_for_account(account_name: 'str') -> 'Optional[Dict[str, str]]':
    pass

def set_exclude_providers(providers: 'Optional[Set[str]]') -> 'None':
    pass

def clear_exclude_providers() -> 'None':
    pass

def get_exclude_providers() -> 'Optional[Set[str]]':
    pass

def get_access_token(account_name: 'Optional[str]' = None, account_email: 'Optional[str]' = None, main_window=None) -> 'Optional[Dict]':
    pass
