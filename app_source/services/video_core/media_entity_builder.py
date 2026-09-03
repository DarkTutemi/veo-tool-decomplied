"""
Decompiled / Reconstructed Module: services.video_core.media_entity_builder
Source PyC: media_entity_builder.pyc

Docstring:
Media Library to entity_library builders shared by video tabs.

Tabs should not each invent their own CHAR_000/OBJ_000/SET_000 mapping. This
module creates the stable entity contract used by the scene compiler, with a
legacy bridge for older services that still accept ``pre_selected_asset_library``.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
Optional = typing.Optional

# --- Top-Level Functions ---
def _as_list(value: 'Any') -> 'list':
    pass

def _clean_text(value: 'Any', default: 'str' = '') -> 'str':
    pass

def _media_structure(media: 'Optional[Dict[str, Any]]', selected: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _asset_type(media: 'Optional[Dict[str, Any]]', selected: 'Dict[str, Any]', default_asset_type: 'str') -> 'str':
    pass

def _get_media(media_id: 'str', *, fetch_media: 'bool', log_prefix: 'str') -> 'Optional[Dict[str, Any]]':
    pass

def build_entity_library_from_media_ids(media_ids: 'Iterable[str]', *, selected_data: 'Optional[Dict[str, Dict[str, Any]]]' = None, default_asset_type: 'str' = 'object', fetch_media: 'bool' = True, max_characters: 'Optional[int]' = None, anchor_refs: 'bool' = True, log_prefix: 'str' = '') -> 'Dict[str, Any]':
    pass

def build_preselected_character_entity_library(media_ids: 'Iterable[str]', *, selected_data: 'Optional[Dict[str, Dict[str, Any]]]' = None, fetch_media: 'bool' = False, log_prefix: 'str' = '') -> 'Dict[str, Any]':
    pass

def build_legacy_asset_library_from_media_ids(media_ids: 'Iterable[str]', *, selected_data: 'Optional[Dict[str, Dict[str, Any]]]' = None, default_asset_type: 'str' = 'character', fetch_media: 'bool' = False, max_characters: 'Optional[int]' = None, anchor_refs: 'bool' = True, log_prefix: 'str' = '') -> 'Dict[str, Any]':
    pass

def _entity_library_from_multi_asset_mapping(multi_asset_info: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def normalize_multi_asset_info(multi_asset_info: 'Dict[str, Any] | None', *, write_back: 'bool' = True) -> 'Dict[str, Any]':
    """Ensure multi_asset_info carries both entity_library and legacy view.

    The UI still stores selected assets in the older multi_asset_info shape.
    This function is the single boundary adapter: downstream services can read
    entity_library first, while legacy callers still get asset_library."""
    pass

def build_multi_asset_info_from_provided_characters(provided_characters: 'Iterable[Dict[str, Any]]', user_assets: 'Iterable[Dict[str, Any]]', *, log_prefix: 'str' = '') -> 'Dict[str, Any]':
    pass
