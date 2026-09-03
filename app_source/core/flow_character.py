"""
Decompiled / Reconstructed Module: core.flow_character
Source PyC: flow_character.pyc

Docstring:
Shared Flow character entity helpers.

Google Flow binds voice and character imagery at the entity layer. Video
generation then references those bindings with requests[].referenceEntities.
This module keeps that contract UI-free so Media Library, Normal Panel, Master,
Clone, and dispatcher code can share the same model.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
Optional = typing.Optional
CHARACTER_ENTITY_TYPE = 'CHARACTER'
DEFAULT_CHARACTER_IMAGE_SLOTS = 2
CHARACTER_PATCH_UPDATE_MASK = 'entityInfo.displayName,entityInfo.characterInfo.personalityNotes,entityInfo.characterInfo.audioReferences,entityInfo.characterInfo.imageReferences'

# --- Class: FlowCharacter ---
class FlowCharacter:
    """Local character profile that can be synced into Flow per account."""
    personality_notes = ''

    def to_dict(self) -> 'Dict[str, Any]':
        pass

    @classmethod
    def from_dict(cls, data: 'Dict[str, Any]') -> "'FlowCharacter'":
        pass

    def audio_references(self) -> 'List[Dict[str, str]]':
        pass

    def sync_hash(self) -> 'str':
        pass

    def __init__(self, id: 'str', display_name: 'str', personality_notes: 'str' = '', image_media_ids: 'List[str]' = <factory>, voice_ref: 'Dict[str, Any]' = <factory>, raw: 'Dict[str, Any]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: FlowCharacterEntity ---
class FlowCharacterEntity:
    """Remote Flow entity mapping for a local character on one account."""
    remote_sync_hash = ''
    sync_status = 'synced'
    last_error = ''

    def to_dict(self) -> 'Dict[str, Any]':
        pass

    @classmethod
    def from_dict(cls, data: 'Dict[str, Any]') -> "'FlowCharacterEntity'":
        pass

    def __init__(self, character_id: 'str', account_key: 'str', project_id: 'str', entity_id: 'str', image_references: 'List[Dict[str, Any]]' = <factory>, audio_references: 'List[Dict[str, Any]]' = <factory>, raw_entity: 'Dict[str, Any]' = <factory>, remote_sync_hash: 'str' = '', sync_status: 'str' = 'synced', last_error: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _list_of_strings(value: 'Any') -> 'List[str]':
    pass

def _list_of_dicts(value: 'Any') -> 'List[Dict[str, Any]]':
    pass

def _stable_json(value: 'Any') -> 'str':
    pass

def _raw_image_fingerprints(raw: 'Dict[str, Any]') -> 'List[str]':
    pass

def normalize_image_references(image_references: 'Iterable[Dict[str, Any]]', *, min_slots: 'int' = 2) -> 'List[Dict[str, Any]]':
    pass

def build_character_patch_payload(*, project_id: 'str', entity_id: 'str', character: 'FlowCharacter', image_references: 'Optional[List[Dict[str, Any]]]' = None, audio_references: 'Optional[List[Dict[str, Any]]]' = None) -> 'Dict[str, Any]':
    pass

def _entity_id_from_item(item: 'Any') -> 'str':
    pass

def build_reference_entities(items: 'Iterable[Any]') -> 'List[Dict[str, str]]':
    pass
