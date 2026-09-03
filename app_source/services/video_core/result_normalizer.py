"""
Decompiled / Reconstructed Module: services.video_core.result_normalizer
Source PyC: result_normalizer.pyc

Docstring:
Normalize service AI result data into the shared scene contract.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['clean_model_facing_text', 'fallback_shot_plan_from_scene', 'normalize_result_scene_contract', 'scene_actor_names', 'strip_ids_from_model_plan']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
__all__ = ['clean_model_facing_text', 'fallback_shot_plan_from_scene', 'normalize_result_scene_contract', 'scene_actor_names', 'strip_ids_from_model_plan']

# --- Top-Level Functions ---
def clean_model_facing_text(text: 'Any') -> 'str':
    pass

def strip_ids_from_model_plan(value: 'Any') -> 'None':
    pass

def scene_actor_names(scene: 'Dict[str, Any]') -> 'list[str]':
    pass

def fallback_shot_plan_from_scene(scene: 'Dict[str, Any]', clip_duration: 'int') -> 'Dict[str, Any]':
    pass

def _derive_scene_duration(scene: 'Dict[str, Any]', default: 'int') -> 'int':
    pass

def normalize_result_scene_contract(result_data: 'Dict[str, Any]', clip_duration: 'int') -> 'Dict[str, Any]':
    pass
