"""
Decompiled / Reconstructed Module: services.shared.library_control
Source PyC: library_control.pyc

Docstring:
Shared Media Library intent rules for video-generation routes.

This module is intentionally Qt-free. UI/controllers select Media Library
assets, then routes ask this module to normalize intent and render the prompt
block appropriate for their source type.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
_CATEGORY_ALIASES = {'character': 'characters', 'characters': 'characters', 'person': 'characters', 'people': 'characters', 'actor': 'characters', 'actors': 'characters', 'object': 'objects', 'objects': 'objects', 'prop'... [truncated]
_LEGACY_CATEGORY = {'characters': 'characters', 'objects': 'objects', 'backgrounds': 'settings'}
_PROMPT_CATEGORY = {'characters': 'characters', 'objects': 'objects', 'backgrounds': 'backgrounds'}
_SOURCE_POLICIES = {'ai', 'hybrid', 'disabled', 'library_only'}
_CONSISTENCY_CATEGORIES = ('characters', 'objects', 'backgrounds')
_LIBRARY_CONTROL_ENABLE_KEYS = ('character_consistency', 'char_consistency', 'enable_char_consistency')
_SCENE_CONSISTENCY_KEYS = ('scene_consistency', 'anchor_consistency', 'enable_scene_consistency')
LIBRARY_SCOPE_LABELS_VI = {'characters': 'Nhân vật', 'objects': 'Đồ vật', 'backgrounds': 'Bối cảnh'}
_LIBRARY_ONLY_SOURCES = {'library_only', 'library', 'only_library', 'manual'}
_ENTITY_KEYS = {'characters': 'characters', 'objects': 'props', 'backgrounds': 'locations'}
_SCENE_ENTITY_KEYS = {'characters': 'characters', 'objects': 'objects', 'backgrounds': 'backgrounds'}

# --- Top-Level Functions ---
def _bool_flag(value: 'Any') -> 'bool':
    pass

def matrix_scope_sources(library_policy: 'Mapping[str, Any] | None') -> 'Dict[str, str] | None':
    pass

def consistency_active_categories(library_policy: 'Mapping[str, Any] | None') -> 'set':
    pass

def library_control_enabled_from_config(config: 'Mapping[str, Any] | None') -> 'bool':
    pass

def sync_scene_consistency_with_library_control(config: 'Dict[str, Any]', *, scene_keys: 'Iterable[str]' = ('scene_consistency', 'anchor_consistency', 'enable_scene_consistency')) -> 'bool':
    pass

def _source_policy(value: 'Any', default: 'str' = 'ai') -> 'str':
    pass

def _missing_policy(value: 'Any', source_policy: 'str') -> 'str':
    pass

def _rewrite_policy(value: 'Any', source_policy: 'str') -> 'str':
    pass

def _text(value: 'Any') -> 'str':
    pass

def _mode(value: 'Any', char_mode: 'Any' = '') -> 'str':
    pass

def normalize_library_category(value: 'Any') -> 'str':
    pass

def normalize_library_categories(values: 'Any') -> 'List[str]':
    pass

def _join_with_or(values: 'Iterable[str]') -> 'str':
    pass

def _rewrite_strategy(route: 'str', source_mode: 'str') -> 'str':
    pass

def _asset_id_for(category: 'str', index: 'int') -> 'str':
    pass

def _append_asset(out: 'Dict[str, List[Dict[str, str]]]', seen: 'Dict[str, set]', category: 'str', item: 'Mapping[str, Any]', media_id_hint: 'str' = '') -> 'None':
    pass

def assets_by_category_from_multi_asset_info(multi_asset_info: 'Mapping[str, Any] | None', *, selected_characters_data: 'Mapping[str, Any] | None' = None, selected_character_ids: 'Iterable[Any] | None' = None) -> 'Dict[str, List[Dict[str, str]]]':
    pass

def categories_from_multi_asset_info(multi_asset_info: 'Mapping[str, Any] | None') -> 'List[str]':
    pass

def build_library_control_intent(*, route: 'str', source_mode: 'str', mode: 'str' = 'full_ai', char_mode: 'str' = '', categories: 'Any' = None, scope_policies: 'Mapping[str, Any] | None' = None, mapping: 'str' = '', strictness: 'str' = '', multi_asset_info: 'Mapping[str, Any] | None' = None, selected_characters_data: 'Mapping[str, Any] | None' = None, selected_character_ids: 'Iterable[Any] | None' = None) -> 'Dict[str, Any]':
    pass

def build_library_control_intent_from_policy(*, route: 'str', source_mode: 'str', char_mode: 'str', library_policy: 'Mapping[str, Any] | None', multi_asset_info: 'Mapping[str, Any] | None', selected_characters_data: 'Mapping[str, Any] | None' = None, selected_character_ids: 'Iterable[Any] | None' = None) -> 'Dict[str, Any]':
    pass

def find_starved_library_scopes(*, char_mode: 'str' = '', library_policy: 'Mapping[str, Any] | None' = None, multi_asset_info: 'Mapping[str, Any] | None' = None, selected_characters_data: 'Mapping[str, Any] | None' = None, selected_character_ids: 'Iterable[Any] | None' = None) -> 'List[str]':
    pass

def library_only_categories(library_policy: 'Mapping[str, Any] | None') -> 'set':
    pass

def disabled_categories(library_policy: 'Mapping[str, Any] | None') -> 'set':
    pass

def char_consistency_effective(raw_flag: 'Any', library_policy: 'Mapping[str, Any] | None') -> 'bool':
    pass

def scene_consistency_effective(raw_flag: 'Any', library_policy: 'Mapping[str, Any] | None') -> 'bool':
    pass

def normalize_library_policy_config(policy: 'Mapping[str, Any] | None', *, char_mode: 'Any' = '', categories: 'Any' = None) -> 'Dict[str, Any]':
    pass

def ensure_matrix_library_policy_config(policy: 'Mapping[str, Any] | None', *, family_enabled: 'Any', char_mode: 'Any' = '', categories: 'Any' = None) -> 'Dict[str, Any]':
    pass

def _strategy_sentence(intent: 'Mapping[str, Any]') -> 'str':
    pass

def _mode_label(source_policy: 'str') -> 'str':
    pass

def _rewrite_policy_sentence(category: 'str', rewrite_policy: 'str') -> 'str':
    pass

def _scope_policy_sentence(category: 'str', source: 'str', missing: 'str', rewrite_policy: 'str') -> 'str':
    pass

def _disabled_rule_lines(disabled: 'List[str]') -> 'List[str]':
    pass

def render_library_control_prompt(intent: 'Mapping[str, Any] | None') -> 'str':
    pass

def _entity_dedupe_key(item: 'Any') -> 'str':
    pass

def _asset_to_entity(category: 'str', asset: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def _merge_selected_with_existing(category: 'str', selected: 'List[Mapping[str, Any]]', existing: 'List[Any]') -> 'List[Dict[str, Any]]':
    pass

def apply_library_control_response_guard(result_data: 'Dict[str, Any] | None', *, route: 'str', source_mode: 'str', char_mode: 'str' = '', library_policy: 'Mapping[str, Any] | None' = None, multi_asset_info: 'Mapping[str, Any] | None' = None, selected_characters_data: 'Mapping[str, Any] | None' = None, selected_character_ids: 'Iterable[Any] | None' = None) -> 'Dict[str, Any] | None':
    """Apply matrix/library-only constraints after the AI returns JSON.

    Prompt rules tell the model what to do. This guard enforces the entity
    library/runtime-reference surface for locked scopes so downstream dispatch
    cannot accidentally use AI-created assets where the user asked for Library
    control."""
    pass
