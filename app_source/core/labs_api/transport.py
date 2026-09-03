"""
Decompiled / Reconstructed Module: core.labs_api.transport
Source PyC: transport.pyc

Docstring:
core/labs_api/transport.py — fetch executor + Strategy-A fallback detection.

`call_api_via_browser` runs the API fetch INSIDE the farm browser (token + fetch
same context), classifies HTTP failures into error_category, raises on failure.

`result_needs_ui_fallback` / `exc_needs_ui_fallback` decide when a fetch result/
exception is a 403/recaptcha that should retry via the Flow UI adapter, and
`fetch_then_ui_fallback` is the shared Strategy-A orchestration used by every
per-feature call in calls.py.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Optional = typing.Optional
_STATUS_CATEGORY = {401: 'auth_expired', 403: 'recaptcha_failed', 404: 'media_id_expired', 408: 'browser_runtime_timeout'}
_UI_FALLBACK_CATEGORIES = {'captcha_provider_down', 'browser_runtime_empty_response', 'recaptcha_failed'}

# --- Top-Level Functions ---
def _classify_error_suffix(status: 'Optional[int]', body: 'str') -> 'str':
    """Map an HTTP status (+ body for 429) to a ``|error_category:<cat>`` suffix."""
    pass

def call_api_via_browser(account_name: 'str', url: 'str', payload: 'Dict[str, Any]', action: 'str' = 'VIDEO_GENERATION', max_retries: 'int' = 1, timeout_ms: 'int' = 60000, account_email: 'Optional[str]' = None, priority: 'int' = 2, sequence_number: 'int' = 0, request_type: 'str' = 'generate') -> 'Dict[str, Any]':
    pass

def call_browser_json(account_name: 'str', url: 'str', payload: 'Dict[str, Any]', *, account_email: 'Optional[str]' = None, timeout_ms: 'int' = 30000) -> 'Optional[Dict[str, Any]]':
    pass

def result_needs_ui_fallback(result) -> 'bool':
    pass

def exc_needs_ui_fallback(e: 'Exception') -> 'bool':
    pass

def fetch_then_ui_fallback(*, url: 'str', payload: 'Dict[str, Any]', account_name: 'str', account_email: 'Optional[str]', ui_fallback: 'Optional[Callable[[], Dict[str, Any]]]' = None, ui_supported: 'bool' = True, on_fetch_error: 'Optional[Callable[[Exception], Dict[str, Any]]]' = None, call_kwargs: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
    pass
