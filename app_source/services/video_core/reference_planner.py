"""
Decompiled / Reconstructed Module: services.video_core.reference_planner
Source PyC: reference_planner.pyc

Docstring:
Reference selection for unified video scenes.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
Set = typing.Set
_PRIORITY_RANK = {'high': 0, 'hard': 0, 'locked': 0, 'medium': 1, 'med': 1, 'low': 2}

# --- Class: ReferencePlan ---
class ReferencePlan:
    """ReferencePlan(characters: 'List[str]' = <factory>, text_only_characters: 'List[str]' = <factory>, anchors: 'List[str]' = <factory>, text_only_anchors: 'List[str]' = <factory>, total_ref_limit: 'int' = 3, character_ref_limit: 'int' = 3)"""
    total_ref_limit = 3
    character_ref_limit = 3
    all_refs = <property object at 0x00000264E77C72E0>

    def __init__(self, characters: 'List[str]' = <factory>, text_only_characters: 'List[str]' = <factory>, anchors: 'List[str]' = <factory>, text_only_anchors: 'List[str]' = <factory>, total_ref_limit: 'int' = 3, character_ref_limit: 'int' = 3) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _as_list(value: 'Any') -> 'List[Any]':
    pass

def _item_id(item: 'Any') -> 'str':
    pass

def _entity_map(entity_library: 'Dict[str, Any]') -> 'Dict[str, Dict[str, Any]]':
    pass

def _scene_entity_ids(scene: 'Dict[str, Any]', *groups: 'str') -> 'List[str]':
    pass

def _locked_ids(anchor_plan: 'Dict[str, Any] | None', scene: 'Dict[str, Any]') -> 'Set[str]':
    pass

def _is_anchor(item: 'Dict[str, Any]', locked: 'Set[str]') -> 'bool':
    pass

def _priority_rank(item: 'Dict[str, Any]') -> 'int':
    pass

def _clamp(value: 'Any', default: 'int', low: 'int', high: 'int') -> 'int':
    pass

def plan_scene_references(scene: 'Dict[str, Any]', entity_library: 'Dict[str, Any]', *, anchor_plan: 'Dict[str, Any] | None' = None, total_ref_limit: 'int' = 3, character_ref_limit: 'int' = 3, enable_char_consistency: 'bool' = False, enable_anchor_consistency: 'bool' = False) -> 'ReferencePlan':
    pass
