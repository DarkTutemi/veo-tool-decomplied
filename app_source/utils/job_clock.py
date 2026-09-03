"""
Decompiled / Reconstructed Module: utils.job_clock

Docstring:
JS-safe job wall-clock stamps for queue rows.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
_TERMINAL_STATUSES = frozenset({'paused', 'error', 'canceled', 'completed', 'cancelled', 'failed', 'complete'})
_HISTORY_MAX = 80
_HISTORY_LOCK = <unlocked _thread.lock object at 0x000001DF91EA9F80>
_HISTORY = []

# --- Top-Level Functions ---
def job_clock_iso() -> 'str':
    # [PyArmor BCC constants]: 'datetime', 'now', 'strftime', '%Y-%m-%dT%H:%M:%S.', 'int', 'microsecond', 1000, '03d'
    pass

def job_clock_ms(value: 'Any') -> 'int':
    # [PyArmor BCC constants]: 'isinstance', 'int', 'float', 0, 1000000000000.0, 1000, 'str', '', 'strip', 0.0, 'TypeError', 'ValueError', 'datetime', 'fromisoformat', 'timestamp'
    pass

def as_unix_seconds(value: 'Any') -> 'float':
    # [PyArmor BCC constants]: 'job_clock_ms', 0, 1000.0, 0.0
    pass

def format_elapsed_label(seconds: 'Any') -> 'str':
    # [PyArmor BCC constants]: 'max', 0, 'int', 'float', 'TypeError', 'ValueError', '-', 'divmod', 3600, 60, 'h ', '02d', 'm', 'm ', 's'
    pass

def job_elapsed_seconds(row: 'Mapping[str, Any] | None' = None, now: 'float | None' = None) -> 'int':
    # [PyArmor BCC constants]: 'dict', 'max', 0, 'int', 'float', 'get', 'elapsed_seconds', 'TypeError', 'ValueError', 'as_unix_seconds', 'started_at_ms', 'started_at', 'created_at', 10000000, 'str'
    pass

def attach_job_clock(row: 'dict[str, Any]', meta: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'dict', 'str', 'get', 'started_at', '', 'strip', 'stopped_at', 'updated_at', 'job_clock_ms', 'started_at_ms', 'stopped_at_ms', 'int', 'elapsed_seconds', 0, 'TypeError'
    pass

def record_job_history(entry: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'dict', 'str', 'get', 'id', 'job_id', 'batch_id', '', 'strip', 'started_at', 'created_at', 'stopped_at', 'job_clock_iso', 'prompt', 'name', 'title'
    pass

def list_job_history(limit: 'int' = 80) -> 'list[dict[str, Any]]':
    # [PyArmor BCC constants]: 'max', 1, 'int', '_HISTORY_MAX', '_HISTORY_LOCK', '_HISTORY', 'dict'
    pass

def reset_job_history() -> 'None':
    pass

def stamp_queue_stopped(batch: 'Any', session_key: 'str', status: 'str') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'dict', 'getattr', 'meta', 'str', 'get', 'stopped_at', '', 'strip', 'job_clock_iso', 'started_at', 'created_at', 'job_elapsed_seconds', 'status', 'complete', 'lower'
    pass
