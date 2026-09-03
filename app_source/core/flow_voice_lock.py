"""
Decompiled / Reconstructed Module: core.flow_voice_lock
Source PyC: flow_voice_lock.pyc

Docstring:
Omni/Abra character voice-lock planning helpers.

Flow voice lock is entity-based: the video request should reference
`referenceEntities`, and each entity owns imageReferences + audioReferences.
These helpers keep model capability checks and prompt knowledge outside UI code.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
Optional = typing.Optional

# --- Top-Level Functions ---
def _clean(value: 'Any') -> 'str':
    pass

def _generated_audio(raw: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def normalize_base_voice_entry(raw: 'Any') -> 'Dict[str, str]':
    pass

def get_base_voice_catalog(max_items: 'int' = 24) -> 'List[Dict[str, str]]':
    pass

def model_supports_flow_voice_lock(model_key: 'str') -> 'bool':
    pass

def resolve_flow_voice_lock_model_key(model_key: 'str', *, aspect_ratio: 'str' = '', tier_mode: 'str' = 'ultra', duration_seconds: 'Optional[int]' = None) -> 'str':
    pass

def voice_lock_capability(model_key: 'str', *, aspect_ratio: 'str' = '', tier_mode: 'str' = 'ultra', clip_duration_seconds: 'Optional[int]' = None) -> 'Dict[str, Any]':
    pass

def _model_aspect_matches(model_info: 'Dict[str, Any]', aspect_ratio: 'str') -> 'bool':
    pass

def resolve_flow_voice_lock_runtime_model_key(model_key: 'str', *, aspect_ratio: 'str' = '', tier_mode: 'str' = 'ultra', duration_seconds: 'Optional[int]' = None) -> 'str':
    pass

def voice_lock_uses_entity_path(model_key: 'str') -> 'bool':
    pass

def model_selection_supports_flow_voice_lock(model_key: 'str', *, aspect_ratio: 'str' = '', tier_mode: 'str' = 'ultra', duration_seconds: 'Optional[int]' = None) -> 'bool':
    pass

def resolve_base_voice_name(value: 'str', catalog: 'Optional[Iterable[Dict[str, Any]]]' = None) -> 'str':
    pass

def choose_base_voice_for_description(description: 'str', catalog: 'Optional[Iterable[Dict[str, Any]]]' = None) -> 'Dict[str, str]':
    pass

def stable_voice_blueprint_id(character_id: 'str', voice: 'Dict[str, Any]') -> 'str':
    pass

def build_flow_voice_lock_prompt_block(*, enabled: 'bool', model_key: 'str', aspect_ratio: 'str' = '', tier_mode: 'str' = 'ultra', duration_seconds: 'Optional[int]' = None, max_voices: 'int' = 24) -> 'str':
    """Prompt block that teaches AI how to choose base voice and emit lockable specs."""
    pass
