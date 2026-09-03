"""
Decompiled / Reconstructed Module: application.ui_emit_gate
Source PyC: ui_emit_gate.pyc

Docstring:
Change-detection for UI list/stats signals — re-render QML only when data changed.

Controllers drive the UI by emitting ``*RowsChanged`` / ``statsChanged`` on a
~1.5s poll timer. Emitting unconditionally forces QML to re-evaluate every binding
that reads those lists (filtering 100+ rows for failed/queued counts, rebuilding
stats text, etc.) on EVERY tick — a periodic animation hitch even when nothing
visible changed. The job CARDS animate via the model's narrow ``dataChanged``
regardless, so the list-property emits only need to fire when the data actually
changed.

Usage (one EmitGate per controller):

    self._gate = EmitGate()
    ...
    if self._gate.changed("queue", rows_signature(self._queue_rows)):
        self.queueRowsChanged.emit()
    if self._gate.changed("stats", stats_signature(self._stats)):
        self.statsChanged.emit()
    # job panel: status-only — progress ticks animate via the model, not this list
    if self._gate.changed("jobpanel", rows_signature(rows, with_progress=False)):
        self.jobPanelRowsChanged.emit()
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_UNSET = <object object at 0x00000264D01A9770>

# --- Class: EmitGate ---
class EmitGate:
    """Per-key last-emitted signature tracker. ``changed`` is True only when the
    signature differs from the previous emit for that key."""
    _last = <member '_last' of 'EmitGate' objects>

    def __init__(self) -> 'None':
        pass

    def changed(self, key: 'str', signature: 'Any') -> 'bool':
        pass

    def reset(self, key: 'str | None' = None) -> 'None':
        pass


# --- Top-Level Functions ---
def rows_signature(rows: 'Any', *, with_progress: 'bool' = True) -> 'tuple':
    pass

def stats_signature(stats: 'Any') -> 'tuple':
    pass
