"""
Decompiled / Reconstructed Module: utils.crash_breadcrumbs

Docstring:
In-memory breadcrumb ring — the WHAT-was-happening trail, flushed beside a crash
dump so a native Qt6Qml access violation (where the Python stack is just app.exec())
still tells us the app-level sequence that led to it.

Lock-free by design: a bounded ``collections.deque``. CPython guarantees thread-safe
``append`` and atomic ``list(deque)`` snapshots under the GIL, so:
  • ``drop()`` is safe from ANY thread — including the GUI thread in a hot path —
    at sub-microsecond cost, with ZERO disk I/O (a per-event file write in a hot path
    would be a Law-1 violation; this is pure RAM until a crash flushes it).
  • a crash handler can snapshot the ring WITHOUT taking a lock, so it can never
    deadlock against a thread that faulted mid-``drop()``.

Wire ``drop()`` at the chokepoints that matter for crash correlation (route change,
model reset/apply, dispatch submit, feed flush). The crash handlers (minidump,
CrashLogger, perf watchdog) flush the ring on the way down.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_MAXLEN = 256
_RING = deque([], maxlen=256)
_SEQ = count(1)
_flusher = None

# --- Top-Level Functions ---
def drop(category: 'str', message: 'str', **fields: 'Any') -> 'None':
    # [PyArmor BCC constants]: 'time', '_RING', 'append', 'n', 't', 'thread', 'cat', 'msg', 'kv', 'next', '_SEQ', 'strftime', '%H:%M:%S', 'localtime', '.'
    pass

def snapshot(limit: 'int | None' = None) -> 'list':
    pass

def dump_to(path) -> 'bool':
    # [PyArmor BCC constants]: 'snapshot', 'open', 'w', 'encoding', 'utf-8', 'write', 'dumps', 'ensure_ascii', False, '\n', True, 'Exception'
    pass

def dump_beside(dump_path) -> 'bool':
    # [PyArmor BCC constants]: 'dump_to', 'str', '.crumbs.jsonl', False, 'Exception'
    pass

def start_periodic_flush(path, interval: 'float' = 2.0) -> 'bool':
    # [PyArmor BCC constants]: '_flusher', True, 'sleep', 'dump_to', 'Exception', 'Thread', 'target', 'name', 'breadcrumb-flush', 'daemon', 'start', False
    pass
