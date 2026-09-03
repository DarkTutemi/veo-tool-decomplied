"""
Decompiled / Reconstructed Module: qml_app.controllers.off_thread

Docstring:
Reusable off-thread refresh helper — the qml-patterns Law-1 pattern in ONE place so
controllers stop hand-rolling (and forgetting) it.

A `@pyqtSlot` / `@pyqtProperty` must NEVER do blocking I/O (SQLite, HTTP, socket, disk walk)
on the GUI thread. The fix is always the same shape: run the heavy fetch on a daemon worker,
marshal the result back to the GUI thread via a queued `pyqtSignal(dict)`, and have the GUI
slot only assign state + emit. This helper is that shape.

Usage in a controller:

    class FooController(QObject):
        _fooReady = pyqtSignal(dict)            # worker → GUI

        def __init__(self):
            ...
            self._foo_inflight = Inflight()
            self._fooReady.connect(self._apply_foo)   # AutoConnection marshals worker→GUI

        @pyqtSlot()
        def refresh(self):
            # capture GUI state into plain values BEFORE the worker (no self.<qml> reads off-thread)
            arg = self._search
            run_off_thread(
                self._foo_inflight, self._fooReady,
                lambda: self._service.list_foo(arg),   # PURE-DATA: no QObject touched
            )

        @pyqtSlot(dict)
        def _apply_foo(self, payload):                  # runs on the GUI thread
            self._foo_inflight.done()
            if payload.get("ok"):
                self._foo = payload["data"]
            self.fooChanged.emit()

The worker callable MUST be pure-data: it may read DB/disk/network and build dicts/lists, but
it must not touch any QObject, set a pyqtProperty, or emit a signal directly. Verify the data
stores it reads are thread-safe (SQLite: thread-local conn + check_same_thread=False; in-memory:
RLock + return copies).
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable

# --- Class: Inflight ---
class Inflight:
    """A 1-slot coalescing guard: refuses a new run while one is pending."""
    _busy = <member '_busy' of 'Inflight' objects>

    def __init__(self) -> 'None':
        pass

    def begin(self) -> 'bool':
        pass

    def done(self) -> 'None':
        pass


# --- Top-Level Functions ---
def run_off_thread(inflight: 'Inflight | None', result_signal: 'Any', work: 'Callable[[], Any]', *, name: 'str' = 'OffThread') -> 'bool':
    # [PyArmor BCC constants]: 'begin', False, 'ok', 'data', True, 'error', 'type', '__name__', 'Exception', 'emit', 'RuntimeError', 'threading', 'Thread', 'target', 'daemon'
    pass
