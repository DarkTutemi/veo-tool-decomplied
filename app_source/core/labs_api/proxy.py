"""
Decompiled / Reconstructed Module: core.labs_api.proxy
Source PyC: proxy.pyc

Docstring:
core/labs_api/proxy.py — proxy resolution, HTTP headers, fallback stats.

Ported verbatim from core/api_client.py (73-269):
  get_proxy_for_account · get_proxy_dict · get_httpx_proxy · get_unified_headers
  ProxyFallbackError · ProxyFallbackStats · get_proxy_fallback_stats
  _get_proxy_fallback_mode · _log_proxy_fallback
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional
_PROXY_ENABLED = False
_PROXY_URL = None
_CURRENT_ACCOUNT_EMAIL = None
http_requests = <core.labs_api.proxy.ProxyRequests object at 0x00000264DD151E20>

# --- Class: ProxyFallbackError ---
class ProxyFallbackError(Exception):
    """Raised when proxy fails and fallback_mode is 'strict'."""
    def __init__(self, message: 'str', proxy_url: 'str' = None, original_error: 'Exception' = None):
        pass


# --- Class: ProxyFallbackStats ---
class ProxyFallbackStats:
    """Track proxy fallback statistics for monitoring (process singleton)."""
    _instance = None
    _lock = <unlocked _thread.lock object at 0x00000264DD167640>

    def __init__(self):
        pass

    @classmethod
    def get_instance(cls) -> "'ProxyFallbackStats'":
        pass

    def record_fallback(self, account_email: 'Optional[str]' = None):
        pass

    def get_stats(self) -> 'Dict[str, Any]':
        pass

    def get_total_fallbacks(self) -> 'int':
        pass

    def reset(self):
        pass


# --- Class: ProxyRequests ---
class ProxyRequests:
    """Wrapper for requests with automatic proxy support and configurable fallback.

    Moved out of the api_client god-file so the V2 package owns its own HTTP
    transport (no backward import from the legacy module). Behavior is verbatim."""
    @staticmethod
    def _log_proxy_usage(account_email: 'Optional[str]', proxies: 'Optional[Dict]', method: 'str', url: 'str'):
        pass

    @staticmethod
    def _handle_proxy_failure(method: 'str', url: 'str', proxies: 'Dict', error: 'Exception', account_email: 'Optional[str]', args, kwargs) -> "__assert_armored__((requests, b'\\x81\\xb7\\x9e\\x06L\\xbe\\xf0U\\xb2'))":
        pass

    @staticmethod
    def post(*args, account_email: 'Optional[str]' = None, **kwargs):
        pass

    @staticmethod
    def get(*args, account_email: 'Optional[str]' = None, **kwargs):
        pass

    @staticmethod
    def patch(*args, account_email: 'Optional[str]' = None, **kwargs):
        pass


# --- Top-Level Functions ---
def get_proxy_for_account(email: 'Optional[str]' = None) -> 'Optional[Dict[str, str]]':
    pass

def get_proxy_dict(account_email: 'Optional[str]' = None) -> 'Optional[Dict[str, str]]':
    pass

def get_httpx_proxy(account_email: 'Optional[str]' = None) -> 'Optional[str]':
    pass

def get_unified_headers(include_auth: 'bool' = False, authority: 'str' = 'aisandbox-pa.googleapis.com') -> 'dict':
    pass

def get_credits_headers(access_token: 'str') -> 'dict':
    pass

def get_proxy_fallback_stats() -> 'ProxyFallbackStats':
    pass

def _get_proxy_fallback_mode() -> 'str':
    pass

def _log_proxy_fallback(method: 'str', url: 'str', proxy_url: 'str', error: 'Exception', account_email: 'Optional[str]'):
    pass
