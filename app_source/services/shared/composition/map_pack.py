"""
Decompiled / Reconstructed Module: services.shared.composition.map_pack
Source PyC: map_pack.pyc

Docstring:
Validated geographic path pack for the shared Revideo composition engine.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['MapPackValidationError', 'normalize_map_pack']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
_PROJECTIONS = {'local', 'equirectangular', 'mercator'}
_POSITIONS = {'bottom_right', 'center', 'top_left', 'top_right', 'bottom_left'}
__all__ = ['MapPackValidationError', 'normalize_map_pack']

# --- Class: MapPackValidationError ---
class MapPackValidationError(ValueError):
    """Map/path data cannot be projected safely."""
    pass


# --- Top-Level Functions ---
def _coordinate(value: 'Any', *, index: 'int') -> 'tuple[float, float]':
    pass

def _project_rows(rows: 'list[tuple[float, float]]') -> 'list[list[float]]':
    pass

def normalize_map_pack(raw: 'Mapping[str, Any] | None', *, duration_s: 'float') -> 'dict[str, Any]':
    pass
