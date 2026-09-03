"""
Decompiled / Reconstructed Module: core.dispatch.slot_wait
Source PyC: slot_wait.pyc

Docstring:
Pause generation timeouts while the account pool is saturated.

One live account shared across clone / master / transcript / affiliate / image
jobs fills every slot. Image/CharGen work then sits in the dispatcher queue —
that is a wait, not a hang. The 600s generation timeout must only count
inactivity while a slot is actually available (or after a job has started
and then stalled). Heartbeat status keeps the parent job card from looking
frozen.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Optional = typing.Optional
Tuple = typing.Tuple
STEPPER_LOCK_STAGES = frozenset({'chargen_completed', 'video_jobs_submitted', 'chargen_started'})

# --- Class: PoolSnapshot ---
class PoolSnapshot:
    """PoolSnapshot(free: 'int', inflight: 'int', accounts: 'int', saturated: 'bool')"""
    def __init__(self, free: 'int', inflight: 'int', accounts: 'int', saturated: 'bool') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: GenerationWaitClock ---
class GenerationWaitClock:
    """Timeout that only counts inactivity while the pool has free slots.

    - Progress (a newly completed asset) resets the inactivity clock.
    - Pool saturation pauses the clock and accumulates ``slot_waited``.
    - ``timeout_seconds <= 0`` means wait forever (caller still cancels)."""
    def __init__(self, timeout_seconds: 'float') -> 'None':
        pass

    def tick(self, poll: 'float', *, saturated: 'bool', progressed: 'bool') -> 'bool':
        pass


# --- Top-Level Functions ---
def snapshot_account_pool(owner: 'Any' = None) -> 'Optional[PoolSnapshot]':
    pass

def format_wait_duration(seconds: 'float') -> 'str':
    pass

def format_slot_wait_message(label: 'str', completed: 'int', total: 'int', waited_seconds: 'float', snapshot: 'Optional[PoolSnapshot]') -> 'str':
    pass

def is_slot_wait_message(message: 'str') -> 'bool':
    pass

def charcore_status_patch(current_status: 'str', message: 'str') -> 'dict':
    pass

def emit_progress(callback: 'Optional[Callable]', message: 'str') -> 'None':
    pass

def drive_wait_loop(is_finished: 'Callable[[], Any]', peek_progress: 'Callable[[], Tuple[int, int]]', pool_owner: 'Any', timeout_seconds: 'float', poll_interval: 'float', progress_callback: 'Optional[Callable]' = None, label: 'str' = 'ImageGen', sleep: 'Callable[[float], None]' = <built-in function sleep>) -> 'Tuple[Any, bool]':
    pass
