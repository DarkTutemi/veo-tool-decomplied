"""
Decompiled / Reconstructed Module: core.captcha.browser_runtime_health
Source PyC: browser_runtime_health.pyc

Docstring:
Integrity/smoke diagnostics for the managed VeoFlowOS Browser runtime.

This module never downloads or switches a release.  It proves one candidate
binary can complete the native named-pipe activation, start ``--headless=new``,
publish a DevTools websocket endpoint and accept a loopback TCP connection.
Every result is persisted under the app's fixed roaming diagnostics directory.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['browser_diagnostics_dir', 'latest_browser_failure', 'latest_browser_smoke', 'record_browser_failure', 'run_browser_smoke_test']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
_DIAGNOSTIC_KEEP_RUNS = 24
_DEFAULT_SMOKE_TIMEOUT_SECONDS = 35.0
__all__ = ['browser_diagnostics_dir', 'latest_browser_failure', 'latest_browser_smoke', 'record_browser_failure', 'run_browser_smoke_test']

# --- Top-Level Functions ---
def browser_diagnostics_dir() -> 'Path':
    pass

def _atomic_json(path: 'Path', payload: 'dict[str, Any]') -> 'None':
    pass

def _new_run_dir(kind: 'str') -> 'Path':
    pass

def _clean_old_runs() -> 'None':
    pass

def _text_tail(path: 'Path', limit: 'int' = 12000) -> 'str':
    pass

def _read_json(path: 'Path') -> 'dict[str, Any]':
    pass

def latest_browser_smoke() -> 'dict[str, Any]':
    pass

def latest_browser_failure() -> 'dict[str, Any]':
    pass

def record_browser_failure(reason: 'str', detail: 'str', executable: 'str', integrity: 'Optional[dict[str, Any]]' = None, extra: 'Optional[dict[str, Any]]' = None) -> 'dict[str, Any]':
    pass

def run_browser_smoke_test(executable: 'str | Path', version: 'str' = '', reason: 'str' = 'install', timeout: 'float' = 35.0) -> 'dict[str, Any]':
    pass
