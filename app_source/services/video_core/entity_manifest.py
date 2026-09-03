"""
Decompiled / Reconstructed Module: services.video_core.entity_manifest
Source PyC: entity_manifest.pyc

Docstring:
Locked entity routing for video generation.

This module separates two concepts that older asset-library routing mixed:

- scene mentions/context: useful text for the model
- locked entities: hard references that may consume image/entity slots

Only locked entities are allowed to drive reference image/entity attachment.
Ordinary BG/OBJ fields remain prompt context.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['EntityRouteValidationError', 'extract_locked_entity_refs', 'filter_asset_library_for_locked_refs', 'forced_locked_reference_ids_from_scenes', 'sanitize_scene_entity_routes', 'validate_scene_entity_routes']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
Mapping = typing.Mapping
Set = typing.Set
Tuple = typing.Tuple
_GLOBAL_LIBRARY_KEYS = ('styles', 'narrator_voice', 'genre', 'genre_subtype', 'dominant_approach', 'mood_arc', 'color_palette', 'lighting_style', 'render_style', 'visualization_mix', 'scene_writing_rules', 'style_framework_... [truncated]
_CATEGORY_PREFIX = {'characters': 'CHAR_', 'objects': 'OBJ_', 'backgrounds': ('BG_', 'SET_'), 'settings': 'SET_'}
_ROUTE_GROUPS = {'characters': {'characters'}, 'objects': {'products', 'props', 'data_subjects', 'objects', 'map_subjects'}, 'backgrounds': {'locations', 'settings', 'backgrounds'}}
__all__ = ['EntityRouteValidationError', 'extract_locked_entity_refs', 'filter_asset_library_for_locked_refs', 'forced_locked_reference_ids_from_scenes', 'sanitize_scene_entity_routes', 'validate_scene_entity_r... [truncated]

# --- Class: EntityRouteValidationError ---
class EntityRouteValidationError(ValueError):
    """A scene routes an unknown or wrongly typed entity ID."""
    pass


# --- Top-Level Functions ---
def _canonical_entity_lookup(entity_library: 'Mapping[str, Any]') -> 'Tuple[Dict[str, Dict[str, Any]], Dict[str, str]]':
    pass

def sanitize_scene_entity_routes(scene: 'Mapping[str, Any]', entity_library: 'Mapping[str, Any]', *, scene_id: 'str' = '') -> 'list[str]':
    pass

def validate_scene_entity_routes(scene: 'Mapping[str, Any]', entity_library: 'Mapping[str, Any]', *, scene_id: 'str' = '') -> 'None':
    pass

def _asset_id(item: 'Any') -> 'str':
    pass

def _allowed_ids(asset_library: 'Dict[str, Any]') -> 'Dict[str, Set[str]]':
    pass

def _asset_map(asset_library: 'Dict[str, Any]') -> 'Dict[str, Dict[str, Any]]':
    pass

def _append_unique(target: 'List[str]', value: 'Any', allowed: 'Set[str] | None' = None) -> 'None':
    pass

def _collect_locked_block(block: 'Any', allowed: 'Dict[str, Set[str]]') -> 'Dict[str, List[str]]':
    pass

def _merge_refs(target: 'Dict[str, List[str]]', source: 'Dict[str, List[str]]') -> 'None':
    pass

def _explicit_locked_refs(scene: 'Dict[str, Any]', asset_library: 'Dict[str, Any]') -> 'Dict[str, List[str]]':
    pass

def extract_locked_entity_refs(asset_library: 'Dict[str, Any]', scene: 'Dict[str, Any]') -> 'Dict[str, List[str]]':
    pass

def filter_asset_library_for_locked_refs(asset_library: 'Dict[str, Any]', scene: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def forced_locked_reference_ids_from_scenes(scenes: 'Iterable[Dict[str, Any]]', id_pattern: 'str') -> 'Set[str]':
    pass
