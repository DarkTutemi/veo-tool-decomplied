"""
Decompiled / Reconstructed Module: core.dispatch.policy_fixer
Source PyC: policy_fixer.pyc

Docstring:
core/dispatch/policy_fixer.py — content-policy violation handling.

Ports _handle_policy_retry / _handle_image_policy_ai_fix / _fallback_extend_to_*.

When a generation is blocked by a content-safety filter (error_category in
POLICY_CATEGORIES, including prominent_person_policy) the dispatcher does NOT
just retry the same prompt:

- normal jobs  → AI-rewrite the prompt (fix_policy_violation_prompt) and retry,
  up to MAX_AI_FIX_ATTEMPTS. The rewriter itself verifies (via
  _validate_fixed_prompt_shape) that every asset ID (CHAR_/OBJ_/BG_/SET_) and every
  scene_id key survived, so there is no separate character-ref guard here.
- extend jobs  → the input frame (image) triggers the filter, so an AI text-fix
  is useless; fall back to R2V (character refs) or plain T2V instead.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
Optional = typing.Optional
Tuple = typing.Tuple
logger = <Logger core.dispatch.policy_fixer (WARNING)>
MAX_AI_FIX_ATTEMPTS = 10
POLICY_CATEGORIES = ('policy', 'content_policy', 'content_policy_violation', 'image_policy', 'input_image_policy', 'output_filtered', 'prominent_person_policy')
IP_T2V_API_JOB_VALUES = frozenset({'multi_asset', 'image_video', 'r2v_visual', 'r2v_character'})
IDENTITY_BLOCK_CATEGORIES = frozenset({'prominent_person_policy', 'input_image_policy'})
_REFERENCE_INPUT_KEYS = frozenset({'first_frame_path', 'image_media_id', 'last_frame_path', 'reference_images', 'reference_entities', 'start_media_id', 'image_paths', 'character_ids', 'start_image_path', 'asset_paths', 'refe... [truncated]
_TECHNICAL_STRING_KEYS = frozenset({'file_path', 'source_id', 'media_id', 'output_folder', 'asset_id', 'workflow_id', 'url', 'character_id', 'job_id', 'data_url', 'base64', 'desired_filename', 'path', 'scene_id'})
_DESCRIPTION_KEYS = frozenset({'wardrobe', 'action', 'label', 'visual', 'display_name', 'text', 'prompt', 'identity', 'name', 'setting', 'appearance', 'description'})

# --- Top-Level Functions ---
def is_character_identity_block(error_category: 'str', error: 'str' = '') -> 'bool':
    pass

def _prompt_text(pd: 'dict') -> 'str':
    pass

def _is_technical_string_key(key: 'str') -> 'bool':
    pass

def _replace_name(value: 'str', source: 'str', replacement: 'str') -> 'Tuple[str, int]':
    pass

def apply_ip_replacements_to_prompt_data(prompt_data: 'dict', replacements: 'Iterable[dict]') -> 'Tuple[dict, int]':
    """Apply one verified IP-name map to every human-readable nested value.

    Dict keys and technical IDs/paths/base64 values remain byte-stable so R2V bindings,
    filenames and media lookups cannot break.  Names/descriptions in entity_library,
    character_metadata, scene payloads and both prompt fields are updated together."""
    pass

def _collect_text_reference_descriptions(value: 'Any') -> 'list[str]':
    pass

def _drop_reference_inputs(value: 'Any') -> 'Any':
    pass

def sanitize_identity_prompt_data(prompt_data: 'dict') -> 'dict':
    pass

def build_ip_t2v_fallback(prompt_data: 'dict') -> 'dict':
    """Convert one blocked reference-video scene into a self-contained T2V scene.

    The same job/scene identity, output path, timing and repaired narrative are kept.
    Only reference-bearing request fields are removed.  Safe entity descriptions are
    embedded in the text so the scene remains visually meaningful without an image."""
    pass

def fix_prompt_data(prompt_data: 'dict', error_message: 'str', attempt_num: 'int', previous_prompt: 'str' = '') -> 'Optional[dict]':
    pass

def build_extend_fallback(prompt_data: 'dict') -> 'Tuple[str, dict]':
    pass
