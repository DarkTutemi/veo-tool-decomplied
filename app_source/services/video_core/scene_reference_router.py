"""
Decompiled / Reconstructed Module: services.video_core.scene_reference_router
Source PyC: scene_reference_router.pyc

Docstring:
Shared scene reference routing for Master, Clone, and Transcript flows.

This module owns one decision only: given a scene and an asset library, decide
which CHAR/OBJ/BG/SET IDs the scene references. Callers can then attach runtime
refs, build voice-lock specs, or keep assets text-only using their own pipeline
rules.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
Set = typing.Set
_ID_PATTERNS = {'characters': re.compile('CHAR_\\d{3}'), 'backgrounds': re.compile('(?:BG|SET)_\\d{3}'), 'objects': re.compile('OBJ_\\d{3}')}
_GLOBAL_LIBRARY_KEYS = ('styles', 'narrator_voice', 'genre', 'genre_subtype', 'dominant_approach', 'mood_arc', 'color_palette', 'lighting_style', 'render_style', 'visualization_mix', 'scene_writing_rules', 'style_framework_... [truncated]
_SKIP_WALK_KEYS = {'visual_assets', 'asset_library', 'character_metadata', 'bg_metadata', 'obj_metadata', 'character_images_base64', 'composite_frames'}

# --- Class: _RefCollector ---
class _RefCollector:
    def __init__(self, asset_library: 'Dict[str, Any]'):
        pass

    def add(self, value: 'Any') -> 'None':
        pass

    def scan_text(self, value: 'str') -> 'None':
        pass

    def scan_scene(self, scene: 'Dict[str, Any]') -> 'None':
        pass

    def as_lists(self) -> 'Dict[str, List[str]]':
        pass

    def as_sets(self) -> 'Dict[str, Set[str]]':
        pass

    def _append(self, category: 'str', asset_id: 'str') -> 'None':
        pass


# --- Top-Level Functions ---
def extract_scene_reference_lists(asset_library: 'Dict[str, Any]', scene: 'Dict[str, Any]') -> 'Dict[str, List[str]]':
    pass

def extract_scene_reference_ids(asset_library: 'Dict[str, Any]', scene: 'Dict[str, Any]') -> 'Dict[str, Set[str]]':
    pass

def filter_asset_library_for_scene(asset_library: 'Dict[str, Any]', scene: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def forced_reference_ids_from_scenes(scenes: 'Iterable[Dict[str, Any]]', id_pattern: 'str', *, require_route_hint: 'bool' = False) -> 'Set[str]':
    pass

def _explicit_scene_values(scene: 'Dict[str, Any]') -> 'Iterable[str]':
    pass

def _allowed_ids(asset_library: 'Dict[str, Any]') -> 'Dict[str, Set[str]]':
    pass

def _ids_from_items(items: 'Iterable[Any]') -> 'Set[str]':
    pass

def _asset_key(item: 'Any') -> 'str':
    pass

def _walk_strings(value: 'Any') -> 'Iterable[str]':
    pass
