"""
Decompiled / Reconstructed Module: core.dispatch.job_queue
Source PyC: job_queue.pyc

Docstring:
core/dispatch/job_queue.py — Thread-safe priority job queue.

Replaces: job_queues (per-feature PriorityQueue) + backoff_jobs + DelayedQueue
in smart_job_dispatcher.py.

Key design:
- Single heapq keyed by (priority, global_sequence) — strict FIFO within tier.
- Inner DelayedQueue holds items with not_before timestamps; move_ready()
  drains them back into the main queue when their time comes.
- All public methods are guarded by a single threading.Lock.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
List = typing.List
Optional = typing.Optional
_global_seq = count(0)
_HEAP_PRI_NORMAL = 0
_HEAP_PRI_RETRY = 1

# --- Class: _DelayedEntry ---
class _DelayedEntry:
    """_DelayedEntry(not_before: 'float', seq: 'int', handle: 'JobHandle')"""
    def __init__(self, not_before: 'float', seq: 'int', handle: 'JobHandle') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: DelayedQueue ---
class DelayedQueue:
    """Items held until their *not_before* wall-clock time has passed.

    Thread-safe via the lock passed in (shared with the parent JobQueue so
    that move_ready() → main-queue enqueue is atomic)."""
    def __init__(self, lock: 'threading.Lock') -> 'None':
        pass

    def _put_locked(self, handle: 'JobHandle', not_before: 'float') -> 'None':
        pass

    def _move_ready_locked(self, main_heap: 'list', now: 'float') -> 'int':
        pass

    def size(self) -> 'int':
        pass

    def put(self, handle: 'JobHandle', not_before: 'float') -> 'None':
        pass


# --- Class: JobQueue ---
class JobQueue:
    """Thread-safe priority queue for :class:`JobHandle` objects.

    Ordering: (priority_int, global_sequence) — strict FIFO within same priority.

    ``global_sequence`` is taken from ``handle.retry_count * 0 + original seq``
    i.e. the handle's own sequence is preserved so retried jobs keep their
    place in line relative to other jobs with the same priority."""
    def __init__(self) -> 'None':
        pass

    def enqueue(self, handle: 'JobHandle', priority: 'int' = 0) -> 'None':
        pass

    def dequeue_batch(self, max_items: 'int') -> 'List[JobHandle]':
        pass

    def requeue(self, handle: 'JobHandle', delay_seconds: 'float' = 0.0) -> 'None':
        pass

    def move_ready(self) -> 'int':
        pass

    def size(self) -> 'int':
        pass

    def delayed_size(self) -> 'int':
        pass

    def is_empty(self) -> 'bool':
        pass


# --- Top-Level Functions ---
def _next_seq() -> 'int':
    pass
