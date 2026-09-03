"""
Decompiled / Reconstructed Module: core.labs_api.multi_asset
Source PyC: multi_asset.pyc

Docstring:
core/labs_api/multi_asset.py — reference-to-video (R2V / multi-asset) generation.

Three ways to provide reference images converge on ONE call path: a pre-uploaded
character mediaId map, direct local files, or media-library ids (lazy-uploaded).
Raw asset inputs are first resolved to account-scoped remote mediaIds, then one
referenceImages builder feeds the single calls.call_multi_asset invocation.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_INTERNAL_KEY_RE = re.compile('(CHAR|OBJ|BG|SET)_\\d{3}')

# --- Top-Level Functions ---
def _REF_IMAGE(media_id):
    pass

def _clean_payload(prompt: 'str') -> 'str':
    pass

def _resolve_model(aspect_ratio: 'str', user_tier: 'str' = 'PAYGATE_TIER_TWO') -> 'str':
    pass

def _model_ref_limit(model: 'str') -> 'int':
    pass

def _validate_result(result: 'Optional[Dict[str, Any]]') -> 'Dict[str, Any]':
    pass

def _char_token(value: 'Any') -> 'str':
    pass

def _filter_entity_duplicate_char_refs(character_mediaId_map, reference_entities, entity_char_ids=None) -> 'dict':
    pass

def _prompt_text_for_matching(prompt: 'str') -> 'tuple':
    """Return (text_used_for_name_matching, parsed_json_or_None). Supports the
    V6/V7 (characters+video_direction), V5 ({scene}), and script-beat shapes;
    falls back to the raw prompt for plain text."""
    pass

def _resolve_unique_chars(prompt: 'str', character_mediaId_map: 'dict', reference_limit: 'int') -> 'List[str]':
    """The characters/refs to use, capped at the model's reference limit. Internal
    ref keys (CHAR/OBJ/BG/COMPOSITE/I2V) are authoritative; otherwise match names
    against the prompt text. Raises when nothing matches (no silent T2V fallback)."""
    pass

def _build_char_map_refs(prompt: 'str', model: 'str', character_mediaId_map: 'dict', lookup_key: 'str') -> 'List[Dict[str, str]]':
    """Build referenceImages from a pre-uploaded character mediaId map, preferring
    COMBO_ images (cover multiple chars in one slot) before single-char images."""
    pass

def _account_cache_key(account_name: 'str', account_email: 'Optional[str]') -> 'str':
    pass

def _normalize_asset_refs(asset_refs: 'Optional[List[Dict[str, Any]]]', asset_ids: 'Optional[List[str]]', asset_paths: 'Optional[List[str]]') -> 'List[Dict[str, str]]':
    pass

def _upload_local_asset(path: 'str', *, account_key: 'str', main_window) -> 'Optional[str]':
    pass

def _upload_library_asset(media_id: 'str', *, account_name: 'str', account_key: 'str') -> 'Optional[str]':
    pass

def _build_asset_reference_images(*, asset_ids: 'Optional[List[str]]', asset_paths: 'Optional[List[str]]', asset_refs: 'Optional[List[Dict[str, Any]]]', model: 'str', account_name: 'str', account_email: 'Optional[str]', main_window) -> 'List[Dict[str, str]]':
    pass

def _sync_flow_entities(flow_character_ids, reference_entities, account_name, account_email, model=''):
    pass

def call_multi_asset_batch_api(prompt: 'str', model: 'str', output_count: 'int', account_name: 'str', asset_ids: 'List[str]', main_window=None, character_mediaId_map: 'dict' = None, account_email: 'str' = None, aspect_ratio: 'str' = '16:9', user_tier: 'str' = 'PAYGATE_TIER_TWO', asset_paths: 'List[str]' = None, batch_id: 'str' = None, voice_ids: 'List[str]' = None, reference_entities: 'List[Any]' = None, flow_character_ids: 'List[str]' = None, asset_refs: 'List[Dict[str, Any]]' = None, resolution: 'str' = '') -> 'dict':
    pass

def generate_multi_asset_video_with_auto_fix(prompt: 'str', model: 'str', output_count: 'int', account_name: 'str', asset_ids: 'List[str]', character_mediaId_map: 'dict' = None, aspect_ratio: 'str' = '16:9', row_number: 'int' = 1, progress_cb=None, main_window=None, enable_upscale: 'bool' = False, row_id: 'str' = None, is_auto_regen: 'bool' = False, output_folder: 'str' = None, max_retries: 'int' = 1, account_email: 'str' = None, user_tier: 'str' = 'PAYGATE_TIER_TWO', asset_paths: 'List[str]' = None, voice_ids: 'List[str]' = None, reference_entities: 'List[Any]' = None, flow_character_ids: 'List[str]' = None, on_poll_start=None, stop_check=None, desired_filename: 'str' = None, heartbeat_cb=None, asset_refs: 'List[Dict[str, Any]]' = None, resolution: 'str' = '') -> 'Dict[str, Any]':
    pass
