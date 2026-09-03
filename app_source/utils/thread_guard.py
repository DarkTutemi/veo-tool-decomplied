"""
Decompiled / Reconstructed Module: utils.thread_guard

Docstring:
Dev thread-guard — WARN (never crash) when a QML-bound model is mutated off the GUI
thread.

A QAbstractListModel is NON-REENTRANT: mutating it (set_rows / dataChanged / begin*Rows)
from a non-GUI thread races the QML engine's binding evaluation on the main thread →
Qt6Qml.dll 0xC0000005 access violation. Instead of GUESSING whether such a race exists,
this prints the offending thread name at the exact mutation site, so we can CONFIRM (or
rule out) the race from real evidence.

Gated by VEOFLOW_THREAD_GUARD (default ON) — flip to "0" to silence. One cheap
QThread comparison per mutation; no behavioural change.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_ON = True

# --- Top-Level Functions ---
def warn_if_off_gui(obj: 'object', tag: 'str') -> 'bool':
    # [PyArmor BCC constants]: '_ON', False, 'QThread', 'currentThread', 'thread', 'print', '[THREAD-GUARD] ', ' mutated OFF the GUI thread (current=', 'threading', 'current_thread', 'name', ')', 'flush', True, 'Exception'
    pass
