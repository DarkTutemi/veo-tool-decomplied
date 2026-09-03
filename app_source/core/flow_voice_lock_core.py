"""
Decompiled / Reconstructed Module: core.flow_voice_lock_core
Source PyC: flow_voice_lock_core.pyc

Docstring:
Shared voice-lock profile planning for Flow character entities.

This module is the single backend boundary for turning an asset-library
character into a lockable voice profile. UI tabs and dispatch code should feed
it character metadata + optional scene dialogue, then use the returned recipe to
materialize Flow CHARACTER entities.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
Optional = typing.Optional
_SPEECH_VERB_RE = 'says|said|speaks|asks|replies|responds|whispers|shouts|calls|cries|laughs|narrates|noi|hoi|tra loi'

# --- Top-Level Functions ---
def _clean(value: 'Any') -> 'str':
    pass

def _lower_blob(*values: 'Any') -> 'str':
    pass

def _scene_text_candidates(scene: 'Optional[Dict[str, Any]]') -> 'List[str]':
    pass

def _scene_dialog_sample_for_character(character: 'Dict[str, Any]', scene: 'Optional[Dict[str, Any]]') -> 'str':
    pass

def _matching_speech_for_character(text: 'str', character: 'Dict[str, Any]') -> 'str':
    pass

def _spoken_line_for_character_in_text(text: 'str', character: 'Dict[str, Any]') -> 'str':
    pass

def _clean_voice_sample_dialog(text: 'Any', character: 'Dict[str, Any]') -> 'str':
    pass

def _strip_voice_marker_dialogue(text: 'str', character: 'Dict[str, Any]') -> 'str':
    pass

def extract_voice_marker(character: 'Dict[str, Any]', scene: 'Optional[Dict[str, Any]]') -> 'Dict[str, str]':
    pass

def _has_voice_lock_intent(character: 'Dict[str, Any]', scene: 'Optional[Dict[str, Any]]') -> 'bool':
    pass

def _infer_gender(character: 'Dict[str, Any]', tone: 'str', role: 'str') -> 'str':
    pass

def _infer_age_group(character: 'Dict[str, Any]', tone: 'str') -> 'str':
    pass

def normalize_voice_lock_character_profile(character: 'Dict[str, Any]', *, scene: 'Optional[Dict[str, Any]]' = None, default_language: 'str' = '') -> 'Dict[str, str]':
    pass

def _resolve_catalog_entry(value: 'str', catalog: 'Optional[Iterable[Dict[str, Any]]]' = None) -> 'Dict[str, str]':
    pass

def build_voice_lock_recipe_for_character(character: 'Dict[str, Any]', *, scene: 'Optional[Dict[str, Any]]' = None, catalog: 'Optional[Iterable[Dict[str, Any]]]' = None, default_language: 'str' = '') -> 'Dict[str, Any]':
    """Build a Flow voice recipe from character fields and optional scene marker."""
    pass

def enrich_voice_lock_character(character: 'Dict[str, Any]', *, scene: 'Optional[Dict[str, Any]]' = None, catalog: 'Optional[Iterable[Dict[str, Any]]]' = None, default_language: 'str' = '') -> 'Dict[str, Any]':
    pass

def _scene_mentions_character(scene: 'Dict[str, Any]', character: 'Dict[str, Any]') -> 'bool':
    pass

def _first_scene_for_character(scenes: 'Optional[Iterable[Dict[str, Any]]]', character: 'Dict[str, Any]') -> 'Optional[Dict[str, Any]]':
    pass

def enrich_voice_lock_asset_library_characters(asset_library: 'Dict[str, Any]', *, scenes: 'Optional[Iterable[Dict[str, Any]]]' = None, enabled: 'bool', model_key: 'str', catalog: 'Optional[Iterable[Dict[str, Any]]]' = None, default_language: 'str' = '') -> 'Dict[str, Any]':
    pass
