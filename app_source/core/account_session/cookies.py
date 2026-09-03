"""
Decompiled / Reconstructed Module: core.account_session.cookies
Source PyC: cookies.pyc
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
TRPC_ALLOWED_DOMAINS = {'.labs.google', 'labs.google'}
TRPC_REQUIRED_COOKIE_NAMES = {'NID', '__Host-next-auth.csrf-token', '__Secure-next-auth.session-token', 'next-auth.callback-url'}
TRPC_EXCLUDED_COOKIES = {'SSID', 'SAPISID', 'SID', 'APISID', '__Secure-3PSID', 'HSID', '__Secure-1PSID'}

# --- Top-Level Functions ---
def parse_cookie_jar(raw: 'str | list[dict[str, Any]] | tuple[dict[str, Any], ...] | None') -> 'list[dict[str, Any]]':
    pass

def serialize_cookie_jar(cookies: 'list[dict[str, Any]]') -> 'str':
    pass

def _cookie_is_unexpired(cookie: 'dict[str, Any]', *, now: 'float') -> 'bool':
    pass

def is_login_checkpoint_cookie(cookie: 'dict[str, Any]', *, now: 'float | None' = None) -> 'bool':
    pass

def select_login_checkpoint_cookies(cookies: 'list[dict[str, Any]]', *, now: 'float | None' = None) -> 'list[dict[str, Any]]':
    pass

def trpc_cookie_dict(cookies: 'list[dict[str, Any]]') -> 'dict[str, str]':
    pass
