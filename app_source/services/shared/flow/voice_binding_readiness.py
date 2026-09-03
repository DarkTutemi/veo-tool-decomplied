"""
Decompiled / Reconstructed Module: services.shared.flow.voice_binding_readiness
Source PyC: voice_binding_readiness.pyc

Docstring:
Readiness view-model for Media Library character+voice bindings.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Iterable = typing.Iterable
Mapping = typing.Mapping

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _file_url(path: 'Path') -> 'str':
    pass

def _thumbnail_file(media: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def _structure(media: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def _flow_voice(media: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def _generic_state(synced_count: 'int', required_count: 'int') -> 'str':
    pass

def _synced_entity(entity: 'Any') -> 'bool':
    pass

def _synced_voice_mapping(mapping: 'Any') -> 'bool':
    pass

def _voice_ref(character: 'Any') -> 'dict[str, Any]':
    pass

def _voice_readiness(character_id: 'str', account_keys: 'list[str]', character_store: 'Any', voice_store: 'Any') -> 'dict[str, Any]':
    pass

def build_voice_binding_card(media: 'Mapping[str, Any]', *, account_keys: 'Iterable[str] | None' = None, character_store: 'Any' = None, voice_store: 'Any' = None) -> 'dict[str, Any]':
    pass
