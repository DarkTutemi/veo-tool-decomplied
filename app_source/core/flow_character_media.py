"""
Decompiled / Reconstructed Module: core.flow_character_media
Source PyC: flow_character_media.pyc

Docstring:
Helpers for storing Flow character metadata in Media Library.

Media Library should keep the character identity and optional voice-lock recipe
together. The video pipeline can then rehydrate a saved character with the same
legacy text voice or Flow entity voice recipe.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
_STRUCTURE_KEYS = ('id', 'name', 'display_name', 'type', 'role', 'gender', 'age_group', 'voice_tone', 'voice_language', 'voice_sample_dialog', 'species', 'summary', 'description', 'personality', 'personality_notes', 'a... [truncated]

# --- Top-Level Functions ---
def _clean_text(value: 'Any') -> 'str':
    pass

def _copy_jsonish(value: 'Any') -> 'Any':
    pass

def normalize_flow_voice_recipe(value: 'Any') -> 'Dict[str, Any]':
    """Normalize a Flow voice recipe from AI output or saved structure."""
    pass

def build_media_library_character_structure(character: 'Dict[str, Any]') -> 'Dict[str, Any]':
    """Build Media Library ai_metadata.structure for a generated character."""
    pass

def apply_flow_voice_recipe_to_character_structure(structure: 'Dict[str, Any]', flow_voice: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def enrich_asset_library_character_from_structure(entry: 'Dict[str, Any]', structure: 'Dict[str, Any]') -> 'Dict[str, Any]':
    """Copy saved character voice metadata back into asset_library entry."""
    pass

def merge_provided_character_voice_metadata(asset_library: 'Dict[str, Any]', provided_asset_library: 'Dict[str, Any]') -> 'Dict[str, Any]':
    """Preserve voice fields from user-provided library characters.

    AI script generation may rewrite asset_library.characters and drop optional
    fields. The user-provided library remains the source of truth for voice
    identity and Flow voice-lock recipes."""
    pass
