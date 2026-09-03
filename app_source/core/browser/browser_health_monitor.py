"""
Decompiled / Reconstructed Module: core.browser.browser_health_monitor
Source PyC: browser_health_monitor.pyc

Docstring:
Browser health monitor driven by 403 bursts.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional
_monitor = None
_monitor_lock = <unlocked _thread.lock object at 0x00000264DA0C5780>

# --- Class: BrowserHealthState ---
class BrowserHealthState:
    """BrowserHealthState(account_id: 'str', status: 'str' = 'unknown', score: 'Optional[float]' = None, consecutive_403: 'int' = 0, total_403: 'int' = 0, last_403_at: 'float' = 0.0, last_success_at: 'float' = 0.0, gate_until_success: 'bool' = False, gate_failures: 'int' = 0, error: 'str' = '', recommendation: 'str' = 'Chua co du lieu browser health.')"""
    status = 'unknown'
    score = None
    consecutive_403 = 0
    total_403 = 0
    last_403_at = 0.0
    last_success_at = 0.0
    gate_until_success = False
    gate_failures = 0
    error = ''
    recommendation = 'Chua co du lieu browser health.'

    def snapshot(self) -> 'dict[str, Any]':
        pass

    def __init__(self, account_id: 'str', status: 'str' = 'unknown', score: 'Optional[float]' = None, consecutive_403: 'int' = 0, total_403: 'int' = 0, last_403_at: 'float' = 0.0, last_success_at: 'float' = 0.0, gate_until_success: 'bool' = False, gate_failures: 'int' = 0, error: 'str' = '', recommendation: 'str' = 'Chua co du lieu browser health.') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: BrowserHealthMonitor ---
class BrowserHealthMonitor:
    """Score browser health only when repeated 403s justify the extra probe."""
    def __init__(self) -> 'None':
        pass

    def _key(self, account_id: 'Optional[str]') -> 'str':
        pass

    def _state_locked(self, key: 'str') -> 'BrowserHealthState':
        pass

    def record_403(self, account_id: 'Optional[str]', account: 'Optional[dict[str, Any]]' = None) -> 'dict[str, Any]':
        pass

    def record_success(self, account_id: 'Optional[str]') -> 'None':
        pass

    def recommend_delay(self, account_id: 'Optional[str]', base_delay: 'float') -> 'float':
        pass

    def get_account_status(self, account_id: 'Optional[str]') -> 'dict[str, Any]':
        pass

    def get_status(self) -> 'dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _env_float(name: 'str', default: 'float') -> 'float':
    pass

def _env_int(name: 'str', default: 'int', minimum: 'int' = 1, maximum: 'int' = 100) -> 'int':
    pass

def get_browser_health_monitor() -> 'BrowserHealthMonitor':
    pass
