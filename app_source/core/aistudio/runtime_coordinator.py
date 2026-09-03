"""
Decompiled / Reconstructed Module: core.aistudio.runtime_coordinator
Source PyC: runtime_coordinator.pyc

Docstring:
Process-wide readiness coordination for the AI Studio browser runtime.

The boot keeper and feature workers used to warm the same account independently.
That left a cold-start race: a job could begin while the keeper was launching or
repairing the fork and then fail immediately.  This coordinator gives every
account one readiness owner while other callers wait for the same result.

Only background/job threads may call :meth:`ensure_ready`; this module never
touches Qt and never schedules work on the GUI thread.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
_log = <Logger core.aistudio.runtime_coordinator (WARNING)>
_ACTIVE_STATES = frozenset({'repairing', 'starting'})
_COORDINATOR = <core.aistudio.runtime_coordinator.AiStudioRuntimeCoordinator object at 0x00000264D96D5DC0>

# --- Class: AiStudioRuntimeStartError ---
class AiStudioRuntimeStartError(RuntimeError):
    """A cached fork-start failure observed by a waiting caller."""
    category = 'not_ready'


# --- Class: AiStudioRuntimeWaitTimeout ---
class AiStudioRuntimeWaitTimeout(TimeoutError):
    """A caller waited for the single warm owner longer than its job budget."""
    category = 'not_ready'


# --- Class: AiStudioRuntimeSnapshot ---
class AiStudioRuntimeSnapshot:
    """AiStudioRuntimeSnapshot(account: 'str', state: 'str', generation: 'int', source: 'str', last_error: 'str')"""
    def __init__(self, account: 'str', state: 'str', generation: 'int', source: 'str', last_error: 'str') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: _RuntimeEntry ---
class _RuntimeEntry:
    """_RuntimeEntry(account: 'str', state: 'str' = 'idle', generation: 'int' = 0, source: 'str' = '', last_error: 'str' = '', last_exception: 'BaseException | None' = None, runtime_token: 'object | None' = None)"""
    state = 'idle'
    generation = 0
    source = ''
    last_error = ''
    last_exception = None
    runtime_token = None

    def __init__(self, account: 'str', state: 'str' = 'idle', generation: 'int' = 0, source: 'str' = '', last_error: 'str' = '', last_exception: 'BaseException | None' = None, runtime_token: 'object | None' = None) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AiStudioRuntimeCoordinator ---
class AiStudioRuntimeCoordinator:
    """Serialize fork startup/repair per account and publish its outcome."""
    def __init__(self) -> 'None':
        pass

    @staticmethod
    def _key(account: 'str') -> 'str':
        pass

    def _entry_locked(self, account: 'str') -> '_RuntimeEntry':
        pass

    @staticmethod
    def _snapshot(entry: '_RuntimeEntry') -> 'AiStudioRuntimeSnapshot':
        pass

    def snapshot(self, account: 'str') -> 'AiStudioRuntimeSnapshot':
        pass

    def ensure_ready(self, account: 'str', warm: 'Callable[[], bool | None]', wait_timeout_seconds: 'float' = 150.0, source: 'str' = 'job', retry_failed: 'bool' = False, runtime_token: 'object | None' = None) -> 'AiStudioRuntimeSnapshot':
        pass

    def mark_ready(self, account: 'str', source: 'str' = 'job', runtime_token: 'object | None' = None) -> 'None':
        pass

    def mark_failed(self, account: 'str', error: 'BaseException', source: 'str' = 'job', runtime_token: 'object | None' = None) -> 'None':
        pass

    def invalidate(self, account: 'str', source: 'str' = 'recovery', runtime_token: 'object | None' = None) -> 'None':
        pass

    def clear(self) -> 'None':
        pass


# --- Top-Level Functions ---
def get_aistudio_runtime_coordinator() -> 'AiStudioRuntimeCoordinator':
    pass
