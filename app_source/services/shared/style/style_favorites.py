"""
Decompiled / Reconstructed Module: services.shared.style.style_favorites
Source PyC: style_favorites.pyc

Docstring:
Favorites + last-used tracker for style picker.

Persists a tiny JSON map at `<writable_data_dir>/style_favorites.json`:
    {
      "<style_id>": {"favorite": bool, "last_used": <unix_ts>}
    }

Public API:
    is_favorite(style_id) -> bool
    toggle_favorite(style_id) -> bool       # returns new value
    mark_used(style_id) -> None             # bumps last_used to now
    last_used(style_id) -> float            # 0.0 if never
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
logger = <Logger services.shared.style.style_favorites (WARNING)>
_CACHE = {}
_CACHE_LOADED = False

# --- Top-Level Functions ---
def _path() -> 'str':
    pass

def _load() -> 'Dict[str, Dict[str, Any]]':
    pass

def _save() -> 'None':
    pass

def _entry(style_id: 'str') -> 'Dict[str, Any]':
    pass

def is_favorite(style_id: 'str') -> 'bool':
    pass

def toggle_favorite(style_id: 'str') -> 'bool':
    pass

def mark_used(style_id: 'str') -> 'None':
    pass

def last_used(style_id: 'str') -> 'float':
    pass
