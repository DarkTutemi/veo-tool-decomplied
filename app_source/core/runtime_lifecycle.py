"""
Decompiled / Reconstructed Module: core.runtime_lifecycle
Source PyC: runtime_lifecycle.pyc

Docstring:
Process-wide lifecycle for long-lived executors and bounded app shutdown.

The QML window disappearing is not proof that CPython exited.  A live
``ThreadPoolExecutor`` owns non-daemon worker threads, so it can keep the
single-instance mutex, imported feature-pack modules and the whole process alive
after Qt's event loop has stopped.  Every persistent executor registers here;
the application shutdown seam cancels pending work and arms a last-resort
process-exit watchdog after state/handles have been flushed.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
_LOCK = <unlocked _thread.RLock object owner=0 count=0 at 0x00000264D8E98140>
_EXECUTORS = {}
_SHUTTING_DOWN = False
_WATCHDOG_ARMED = False

# --- Top-Level Functions ---
def is_process_shutting_down() -> 'bool':
    pass

def register_executor(executor: 'Any', name: 'str' = '') -> 'Any':
    pass

def unregister_executor(executor: 'Any') -> 'bool':
    pass

def _shutdown_executor(executor: 'Any') -> 'bool':
    pass

def shutdown_registered_executors() -> 'dict[str, Any]':
    pass

def _arm_hard_exit_watchdog(timeout_seconds: 'float', hard_exit: 'Callable[[int], Any]') -> 'bool':
    pass

def begin_process_shutdown(force_exit_after_seconds: 'float' = 12.0, hard_exit: 'Callable[[int], Any]' = <built-in function _exit>) -> 'dict[str, Any]':
    pass

def reset_runtime_lifecycle_for_tests() -> 'None':
    pass
