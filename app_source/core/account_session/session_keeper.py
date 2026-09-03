"""
Decompiled / Reconstructed Module: core.account_session.session_keeper
Source PyC: session_keeper.pyc

Docstring:
Startup and keep-alive coordination for three browser owners.

BrowserManager owns the stable Google-login profile and authoritative cookie jar.
Normally that profile stays resident in ``headless=new`` at Labs Flow. Add/Relogin
temporarily presents the same serial owner headed and closes it only after the
login transaction commits; Account Open presents it headed until the user closes
it. BrowserFarm owns a separate disposable Flow worker for generation/tier/credit,
and AiStudioForkRuntime owns a separate persistent AI Studio + Gemini context.

No owner may navigate, close, reap, or replace another owner's browser/profile.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_started = False
_start_lock = <unlocked _thread.lock object at 0x00000264D8F05DC0>
_wake_event = <threading.Event at 0x264d8ee75c0: unset>
_requested_lock = <unlocked _thread.lock object at 0x00000264D8F05FC0>
_requested_accounts = set()
_retry_hint_lock = <unlocked _thread.lock object at 0x00000264D7717640>
_next_retry_hint_seconds = None
_probe_failures = {}

# --- Top-Level Functions ---
def _probe_fail_threshold() -> 'int':
    pass

def _fast_retry_seconds() -> 'float':
    pass

def _token_refresh_retry_seconds() -> 'float':
    pass

def _request_retry_hint(seconds: 'float') -> 'None':
    pass

def _take_retry_hint() -> 'float | None':
    pass

def _record_probe_failure(am, name: 'str', label: 'str', err_text: 'str') -> 'None':
    pass

def start_session_keepers(initial_delay: 'float' = 1.5, refresh_interval: 'float' = 1800.0) -> 'None':
    pass

def request_session_probe(account_name: 'str' = '') -> 'bool':
    pass

def _run(initial_delay: 'float', refresh_interval: 'float') -> 'None':
    pass

def _accounts_for_probe() -> 'list[dict]':
    pass

def _probe_identity_key(value) -> 'str':
    pass

def _prioritize_requested_accounts(accounts: 'list[dict]', requested_accounts) -> 'list[dict]':
    pass

def _browser_ownership(browser, account_name: 'str') -> 'tuple[bool, bool]':
    pass

def _ownership_interrupted(browser, account_name: 'str', *, user_open_at_start: 'bool') -> 'bool':
    pass

def _refresh_all(requested_accounts=None) -> 'bool':
    """Returns True if ANY enabled account ended the cycle unhealthy (Need-Login / transient
    miss), so the caller can schedule a fast re-probe (Fix B) instead of the full interval."""
    pass
