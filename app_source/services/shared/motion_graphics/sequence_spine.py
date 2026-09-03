"""
Decompiled / Reconstructed Module: services.shared.motion_graphics.sequence_spine
Source PyC: sequence_spine.pyc

Docstring:
Event-driven sequence rail derived from a resolved TGS.

Renderer-neutral: ASS and Skia both consume this spine.  It copies measured
overlay dates and picture-lock times; it does not invent years or labels.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['build_sequence_spine', '_build_sequence_spine', 'spine_viewer_copy']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
Sequence = typing.Sequence
_SEQUENCE_NUMERIC_TYPES = frozenset({'date_counter', 'century_ticks', 'chapter_progress', 'timeline_rail'})
_SEQUENCE_SEAM_DEDUP_WINDOW_S = 1.5
__all__ = ['build_sequence_spine', '_build_sequence_spine', 'spine_viewer_copy']

# --- Top-Level Functions ---
def _number(value: 'Any') -> 'float | None':
    pass

def build_sequence_spine(resolved_script: 'Mapping[str, Any]') -> 'dict[str, Any]':
    """Derive one persistent, event-driven navigation rail from resolved TGS."""
    pass

def spine_viewer_copy(spine: 'Mapping[str, Any] | None', locale_contract: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
    """Viewer-facing spine text. Never copies a visual-system / preset label."""
    pass

def _build_sequence_spine(resolved_script: 'Mapping[str, Any]') -> 'dict[str, Any]':
    """Derive one persistent, event-driven navigation rail from resolved TGS."""
    pass
