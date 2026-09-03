"""
Decompiled / Reconstructed Module: services.shared.style.style_writer
Source PyC: style_writer.pyc

Docstring:
Writer companion for user-created Style Manager v3 items.

Built-in styles/cameras live in bundled `resources/styles.json` and are treated
as app-owned read-only data. User-created styles/cameras are persisted to
AppData `user_styles.json` under `custom_items`.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional
logger = <Logger services.shared.style.style_writer (WARNING)>
CUSTOM_BUCKET = 'custom_items'
DELETED_BUCKET = 'deleted_custom_item_ids'
RESERVED_PREFIX = '__'
_STYLE_DERIVED_FRAMEWORK_KEYS = {'knowledge_brief', 'master_prompt_style', 'global_style_override', 'visual_identity', 'character_lock', 'object_lock', 'style_dispatch_override', 'dispatch_style_override', 'environment_lock', 'asset... [truncated]
_CAMERA_DERIVED_FRAMEWORK_KEYS = {'knowledge_brief', 'global_style_override', 'visual_identity', 'character_lock', 'object_lock', 'style_dispatch_override', 'dispatch_style_override', 'environment_lock', 'asset_generation_style', 'ma... [truncated]
_LIST_FRAMEWORK_KEYS = ('writing_rules', 'positive_rules', 'negative_style_rules', 'output_contract', 'camera_rules', 'movement_rules', 'framing_rules', 'good_examples', 'bad_examples', 'ontology_keywords')

# --- Top-Level Functions ---
def _atomic_write_json(path: 'str', data: 'Dict[str, Any]') -> 'None':
    pass

def _normalize_doc(doc: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _user_doc(custom_items: 'list', deleted_ids: 'Optional[list]' = None) -> 'Dict[str, Any]':
    pass

def _load_user_doc() -> 'Dict[str, Any]':
    pass

def save_doc(doc: 'Dict[str, Any]') -> 'None':
    pass

def _all_items(doc: 'Dict[str, Any]'):
    pass

def _bucket_for_kind(kind: 'str') -> 'str':
    pass

def _id_collides(doc: 'Dict[str, Any]', item_id: 'str', *, except_id: 'str' = '') -> 'bool':
    pass

def _default_framework(item: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _normalize_kind(kind: 'Any') -> 'str':
    pass

def _dedupe_framework_lists(fw: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def compact_framework_definition(fw: 'Dict[str, Any]', *, kind: 'str') -> 'Dict[str, Any]':
    pass

def compact_item_for_storage(item: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _ensure_style_contract_v2(item: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _ensure_camera_framework_v2(item: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def normalize_item_for_save(item: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _validate_item(item: 'Dict[str, Any]') -> 'None':
    pass

def add_item(bucket: 'Optional[str]', item: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _find_custom(doc: 'Dict[str, Any]', item_id: 'str'):
    pass

def _tombstone_custom_item(doc: 'Dict[str, Any]', item_id: 'str') -> 'bool':
    pass

def update_item(item_id: 'str', patch: 'Dict[str, Any]', *, bucket: 'Optional[str]' = None) -> 'Dict[str, Any]':
    pass

def delete_item(item_id: 'str', *, bucket: 'Optional[str]' = None) -> 'bool':
    pass

def is_custom(item: 'Dict[str, Any]') -> 'bool':
    pass
