"""
Decompiled / Reconstructed Module: services.video_core.normalizer
Source PyC: normalizer.pyc

Docstring:
Normalize AI scene output into the unified module contract.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
_ROUTING_KEYS = {'entities', 'locked_entities', 'asset_requirements', 'entity_locks', 'required_entities'}

# --- Class: SceneSchemaError ---
class SceneSchemaError(ValueError):
    """Raised when a scene violates the new non-legacy scene contract."""
    pass


# --- Top-Level Functions ---
def _duration_label(clip_duration_seconds: 'int') -> 'str':
    pass

def _clean_model_facing_value(value: 'Any', *, parent_key: 'str' = '') -> 'Any':
    pass

def normalize_scene(scene: 'Dict[str, Any]', *, clip_duration_seconds: 'int' = 8) -> 'Dict[str, Any]':
    pass

def clean_model_facing_value(value: 'Any') -> 'Any':
    pass
