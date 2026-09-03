"""
Decompiled / Reconstructed Module: services.shared.tts.engines.omnivoice_config
Source PyC: omnivoice_config.pyc

Docstring:
Shared OmniVoice configuration contract.

The UI, Voice API and narration pipelines all persist the same flat state keys.
This module is deliberately Qt-free so a job can snapshot those keys once and
translate them to the engine wire format without depending on a screen.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
OMNI_STATE_KEYS = ('omni_url', 'omni_voice', 'omni_recipe', 'omni_mode', 'omni_speed', 'omni_language', 'omni_instruct', 'omni_gender', 'omni_age', 'omni_pitch', 'omni_style', 'omni_accent', 'omni_ref_audio', 'omni_ref... [truncated]
_OMNI_PRODUCER_ONLY_FIELDS = {'omni_ref_text', 'omni_accent', 'omni_gender', 'omni_age', 'omni_recipe', 'omni_pitch', 'omni_voice', 'omni_instruct', 'omni_style', 'omni_ref_audio', 'omni_mode', 'omni_url'}
OMNI_CONSUMER_SETTING_KEYS = ('omni_speed', 'omni_language', 'omni_num_step', 'omni_seed', 'omni_guidance', 'omni_denoise', 'omni_postprocess', 'omni_effect_preset', 'omni_duration', 'omni_t_shift', 'omni_position_temperature', '... [truncated]
OMNI_MODES = ('new', 'design', 'profile', 'clone')
OMNI_MODE_ALIASES = {'': 'new', 'auto': 'new', 'new': 'new', 'design': 'design', 'profile': 'profile', 'clone': 'clone'}
_OMNI_RECIPE_FIELDS = ('omni_recipe', 'omni_gender', 'omni_age', 'omni_pitch', 'omni_style', 'omni_accent', 'omni_instruct')
_OMNI_PROFILE_FIELDS = ('omni_voice',)
_OMNI_REFERENCE_FIELDS = ('omni_ref_audio', 'omni_ref_text')
_BUILTIN_RECIPES = {'builtin:warm_female': {'label': 'Nữ ấm áp · kể chuyện', 'gender': 'female', 'age': 'young adult', 'pitch': 'moderate pitch', 'style': 'auto', 'accent': 'auto', 'instruct': 'warm, friendly, natural s... [truncated]
_OMNI_INSTRUCT_CATEGORIES = (frozenset({'male', '男', '女', 'female'}), frozenset({'少年', '中年', 'elderly', 'middle-aged', 'young adult', '青年', '儿童', 'child', 'teenager', '老年'}), frozenset({'极高音调', '低音调', '极低音调', '中音调', 'very high p... [truncated]
_OMNI_TAG_CATEGORY = {'male': 0, '男': 0, '女': 0, 'female': 0, '少年': 1, '中年': 1, 'elderly': 1, 'middle-aged': 1, 'young adult': 1, '青年': 1, '儿童': 1, 'child': 1, 'teenager': 1, '老年': 1, '极高音调': 2, '低音调': 2, '极低音调': 2, '中音调'... [truncated]

# --- Top-Level Functions ---
def normalize_omni_instruct(options: 'Mapping[str, Any] | None') -> 'tuple[str, tuple[str, ...]]':
    pass

def builtin_omni_voices() -> 'list[dict[str, str]]':
    pass

def builtin_omni_recipes() -> 'list[dict[str, str]]':
    pass

def builtin_omni_recipe(recipe_id: 'str') -> 'dict[str, str]':
    pass

def normalize_omni_mode(value: 'Any') -> 'str':
    pass

def normalize_omni_state(state: 'Mapping[str, Any] | None', mode: 'Any | None' = None) -> 'dict[str, Any]':
    pass

def snapshot_omni_state(state: 'Mapping[str, Any] | None') -> 'dict[str, str]':
    pass

def normalize_omni_consumer_state(state: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
    pass

def compose_omni_instruct(options: 'Mapping[str, Any] | None') -> 'str':
    pass

def omni_engine_kwargs(state: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
    pass
