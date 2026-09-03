"""
Decompiled / Reconstructed Module: services.video_pipeline.manual_character_guard
Source PyC: manual_character_guard.pyc

Docstring:
Manual character mode guards for the unified video pipeline.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
CHAR_ID_RE = re.compile('\\bCHAR_\\d{3}\\b')

# --- Top-Level Functions ---
def allowed_characters_from_config(config: 'Any') -> 'List[Dict[str, Any]]':
    pass

def normalize_manual_character_payload(payload: 'Dict[str, Any]', *, allowed_characters: 'Iterable[Dict[str, Any]]', source: 'str' = 'manual_guard') -> 'Dict[str, Any]':
    """Clamp AI character IDs to the user-selected manual character set."""
    pass
