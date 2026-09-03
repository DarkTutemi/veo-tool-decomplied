"""
Decompiled / Reconstructed Module: services.shared.character_assets
Source PyC: character_assets.pyc

Docstring:
Shared character-consistency asset logic.

Các hàm THUẦN (không phụ thuộc settings/state của tab nào) để 3 tab
master / clone / audio(transcript) cùng dựng MỘT contract `multi_asset_info`
mà pipeline tiêu thụ (services/video_pipeline step3_assets / step5_dispatch).

Tách từ application/master_options_service.py (bản "chuẩn") để clone & audio
import dùng chung thay vì mỗi tab tự code logic riêng.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Mapping = typing.Mapping
Tuple = typing.Tuple
_PROVIDED_APPEARANCE_KEYS = ('physical_description', 'face_details', 'hair', 'clothing', 'visual_description', 'anatomy', 'distinctive_features')

# --- Top-Level Functions ---
def text(value: 'Any') -> 'str':
    pass

def library_character_identity_name(item: 'Mapping[str, Any] | None') -> 'str':
    pass

def character_identity_tokens(value: 'Any') -> 'set[str]':
    pass

def characters_share_identity(left: 'Any', right: 'Any') -> 'bool':
    pass

def strip_generated_appearance(character: 'Mapping[str, Any] | None') -> 'Dict[str, Any]':
    pass

def string_list(values: 'Any') -> 'List[str]':
    pass

def character_role_from_item(item: 'Dict[str, Any]') -> 'str':
    pass

def library_asset_bucket(value: 'Any') -> 'str':
    pass

def _normalize_non_character_asset(item: 'Dict[str, Any]', bucket: 'str', index: 'int') -> 'Dict[str, Any]':
    pass

def compose_character_multi_asset_info(assets: 'List[Dict[str, Any]]', existing_info: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    pass

def compose_library_multi_asset_info(character_assets: 'List[Dict[str, Any]] | None' = None, object_assets: 'List[Dict[str, Any]] | None' = None, background_assets: 'List[Dict[str, Any]] | None' = None, existing_info: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    pass

def character_assets_from_multi_asset_info(info: 'Dict[str, Any] | None') -> 'List[Dict[str, Any]]':
    pass

def character_ids_and_data_from_multi_asset_info(info: 'Mapping[str, Any] | None') -> 'tuple[list[str], dict[str, Any]]':
    pass

def resolve_character_assets_from_selection(selection: 'Dict[str, Any] | None', available_items: 'List[Dict[str, Any]] | None') -> 'List[Dict[str, Any]]':
    pass

def resolve_library_assets_from_selection(category: 'Any', selection: 'Dict[str, Any] | None', available_items: 'List[Dict[str, Any]] | None') -> 'List[Dict[str, Any]]':
    pass

def reorder_character_assets(assets: 'List[Dict[str, Any]]', media_id: 'Any', offset: 'Any') -> 'Tuple[List[Dict[str, Any]], bool]':
    """Di chuyển character `media_id` đi `offset` vị trí. Trả (assets_mới, changed)."""
    pass

def filter_out_character_asset(assets: 'List[Dict[str, Any]]', media_id: 'Any') -> 'List[Dict[str, Any]]':
    pass

def asset_image_base64(asset: 'Mapping[str, Any]') -> 'str':
    pass

def _char_id_of(item: 'Mapping[str, Any]') -> 'str':
    pass

def library_reuse_character_ids(characters: 'List[Mapping[str, Any]] | None' = None, multi_asset_info: 'Mapping[str, Any] | None' = None, selected_character_ids: 'List[Any] | None' = None) -> 'set[str]':
    """CHAR ids that already have a Media Library image and must not go to CharGen.

    Covers the three Clone/ATV lookup keys: picker CHAR_000 order, id_mapping,
    and identity-name match after the LLM remaps ids."""
    pass

def resolve_character_images(characters: 'List[Mapping[str, Any]]', multi_asset_info: 'Mapping[str, Any] | None', char_mode: 'str', chargen_fn=None) -> 'Dict[str, str]':
    pass
