"""
Decompiled / Reconstructed Module: services.video_core.migration
Source PyC: migration.pyc

Docstring:
Migration helpers for old scene payloads.

The unified scene compiler only accepts `entity_library`. These helpers are
runtime-edge adapters for older jobs/history that still carry `asset_library`.
Do not import this module from the compiler.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List

# --- Top-Level Functions ---
def _as_list(value: 'Any') -> 'List[Any]':
    pass

def _merge_item_lists(*groups: 'Any') -> 'List[Any]':
    pass

def normalize_entity_library(entity_library: 'Dict[str, Any] | None') -> 'Dict[str, Any]':
    pass

def entity_library_from_asset_library(asset_library: 'Dict[str, Any] | None') -> 'Dict[str, Any]':
    pass

def legacy_asset_library_from_entity_library(entity_library: 'Dict[str, Any] | None') -> 'Dict[str, Any]':
    pass

def normalize_legacy_asset_library(asset_library: 'Dict[str, Any] | None') -> 'Dict[str, Any]':
    pass

def build_legacy_asset_library(*, characters: 'Any' = None, objects: 'Any' = None, settings: 'Any' = None, backgrounds: 'Any' = None, styles: 'Any' = None, products: 'Any' = None, data_subjects: 'Any' = None, map_subjects: 'Any' = None, style: 'str' = '', metadata: 'Dict[str, Any] | None' = None, reference_image_instruction: 'str' = '', narrator_voice: 'str' = '', base: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    pass

def merge_legacy_asset_libraries(*libraries: 'Dict[str, Any] | None') -> 'Dict[str, Any]':
    """Merge legacy asset libraries while preserving first non-empty metadata.

    Existing asset_library entries often contain runtime-only voice/media fields;
    those should win over derived entries from entity_library."""
    pass

def ensure_legacy_asset_library(result_data: 'Dict[str, Any] | None', *, write_back: 'bool' = False, sync_entity: 'bool' = False) -> 'Dict[str, Any]':
    """Return a legacy asset_library view for runtime consumers.

    The returned shape is for Step3/composite/history edges only. The model-facing
    compiler should continue using entity_library."""
    pass

def merge_entity_libraries(*libraries: 'Dict[str, Any] | None') -> 'Dict[str, Any]':
    pass

def ensure_entity_library(result_data: 'Dict[str, Any] | None') -> 'Dict[str, Any]':
    pass

def sync_legacy_characters_to_entity_library(result_data: 'Dict[str, Any] | None', asset_library: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    pass

def sync_legacy_asset_library_to_entity_library(result_data: 'Dict[str, Any] | None', asset_library: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    pass

def sync_result_libraries(result_data: 'Dict[str, Any] | None', asset_library: 'Dict[str, Any] | None' = None, *, preserve_existing_entity: 'bool' = False) -> 'Dict[str, Any]':
    pass

def apply_style_override_to_libraries(result_data: 'Dict[str, Any] | None', override_style: 'str', *, style_package: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    pass

def ensure_style_in_libraries(result_data: 'Dict[str, Any] | None', fallback_style: 'str') -> 'Dict[str, Any]':
    pass

def merge_provided_asset_library_into_result(result_data: 'Dict[str, Any] | None', provided_source: 'Dict[str, Any] | None', *, prefer_provided_anchors: 'bool' = False, preserve_reference_instruction: 'bool' = True) -> 'Dict[str, Any]':
    pass

def preserve_provided_character_voice_metadata(result_data: 'Dict[str, Any] | None', provided_source: 'Dict[str, Any] | None') -> 'Dict[str, Any]':
    pass

def replace_character_in_libraries(result_data: 'Dict[str, Any] | None', char_id: 'str', replacement: 'Dict[str, Any]') -> 'bool':
    pass

def set_characters_in_libraries(result_data: 'Dict[str, Any] | None', characters: 'List[Dict[str, Any]] | None') -> 'Dict[str, Any]':
    pass

def update_character_fields_in_libraries(result_data: 'Dict[str, Any] | None', char_id: 'str', fields: 'Dict[str, Any]') -> 'bool':
    pass

def remove_character_from_libraries(result_data: 'Dict[str, Any] | None', char_id: 'str') -> 'bool':
    pass

def update_legacy_asset_entry_fields(result_data: 'Dict[str, Any] | None', fields: 'Dict[str, Any]', *, logical_id: 'str | None' = None, index: 'int | None' = None, categories: 'List[str] | None' = None) -> 'Dict[str, Any]':
    pass

def anchor_library_from_entity_library(entity_library: 'Dict[str, Any] | None', ref_ids: 'List[str] | None' = None) -> 'Dict[str, Any]':
    pass
