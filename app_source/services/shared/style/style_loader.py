"""
Decompiled / Reconstructed Module: services.shared.style.style_loader
Source PyC: style_loader.pyc

Docstring:
Style Manager v3 loader.

Canonical runtime buckets are `styles`, `cameras`, and `custom_items`. Built-in
styles/cameras are read from bundled `resources/styles.json`; user-created items
are read from writable AppData `user_styles.json`.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Set = typing.Set
Tuple = typing.Tuple
logger = <Logger services.shared.style.style_loader (WARNING)>
SCHEMA_VERSION = 3
CAMERA_AUTO_ID = '__camera_auto__'
CANONICAL_BUCKETS = ('styles', 'cameras', 'custom_items')
ALL_BUCKETS = ('styles', 'cameras', 'custom_items')
_CACHE = {}
_CACHE_KEY = (('', 0.0, 0), ('', 0.0, 0), ('', 0.0, 0), ('', 0.0, 0))

# --- Top-Level Functions ---
def _resolve_builtin_styles_path() -> 'str':
    pass

def _resolve_styles_path() -> 'str':
    pass

def _resolve_custom_styles_path() -> 'str':
    pass

def _resolve_legacy_user_styles_path() -> 'str':
    pass

def _resolve_qml_custom_styles_path() -> 'str':
    pass

def _stat_key(path: 'str') -> 'Tuple[str, float, int]':
    pass

def _empty_doc() -> 'Dict[str, Any]':
    pass

def _empty_user_doc() -> 'Dict[str, Any]':
    pass

def _migrate_in_memory(data: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _with_origin(item: 'Dict[str, Any]', origin: 'str') -> 'Dict[str, Any]':
    pass

def _with_custom_draw_contract(item: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _canonical_doc(data: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _read_json(path: 'str', fallback: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _user_doc(data: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def load_styles() -> 'Dict[str, Any]':
    pass

def invalidate_cache() -> 'None':
    pass

def _builtin_bucket(bucket: 'str') -> 'List[Dict[str, Any]]':
    pass

def get_bucket(bucket: 'str') -> 'List[Dict[str, Any]]':
    pass

def list_styles() -> 'List[Dict[str, Any]]':
    pass

def list_cameras() -> 'List[Dict[str, Any]]':
    pass

def find_item(item_id: 'str', *, bucket: 'Optional[str]' = None) -> 'Optional[Tuple[str, Dict[str, Any]]]':
    pass

def find_style(style_id: 'str') -> 'Optional[Dict[str, Any]]':
    pass

def find_camera(camera_id: 'str') -> 'Optional[Dict[str, Any]]':
    pass

def get_camera_auto() -> 'Dict[str, Any]':
    pass

def get_framework_by_id(item_id: 'str', *, bucket: 'Optional[str]' = None) -> 'Optional[Dict[str, Any]]':
    pass

def _ids(items: 'List[Dict[str, Any]]') -> 'Set[str]':
    pass

def get_all_structural_style_ids() -> 'Set[str]':
    pass

def get_all_structural_camera_ids() -> 'Set[str]':
    pass

def is_structural_style(style_id: 'str') -> 'bool':
    pass

def is_structural_camera(style_id: 'str') -> 'bool':
    pass
