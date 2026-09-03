"""
Decompiled / Reconstructed Module: services.shared.flow.flow_character_service
Source PyC: flow_character_service.pyc

Docstring:
Runtime service for syncing local characters to Flow remote entities.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
Optional = typing.Optional

# --- Class: FlowCharacterService ---
class FlowCharacterService:
    """Sync local Flow characters into per-account Google Flow entities."""
    _entity_locks = {}
    _entity_locks_guard = <unlocked _thread.lock object at 0x00000264E222A200>
    _validated_entities = set()
    _validated_entities_guard = <unlocked _thread.lock object at 0x00000264E021E380>

    def __init__(self, *, store: 'Optional[FlowCharacterStore]' = None, create_entity: 'Optional[Callable[[Dict[str, Any]], Dict[str, Any]]]' = None, upload_character_image: 'Optional[Callable[..., Dict[str, Any]]]' = None, patch_entity: 'Optional[Callable[..., Dict[str, Any]]]' = None, voice_sync_service=None):
        pass

    def ensure_character_entity(self, character_id: 'str', account: 'Dict[str, Any]', *, validate_remote: 'bool' = False) -> 'str':
        pass

    def entity_has_image_refs(self, character_id: 'str', account: 'Dict[str, Any]') -> 'bool':
        pass

    @classmethod
    def _lock_for(cls, character_id: 'str', key: 'str') -> "__assert_armored__((threading, b'\\x81\\xb7\\xb7\\x1a_\\xba'))":
        pass

    def _ensure_character_entity_locked(self, character_id: 'str', account: 'Dict[str, Any]', key: 'str', *, validate_remote: 'bool' = False) -> 'str':
        pass

    def build_reference_entities(self, character_ids: 'Iterable[str]', account: 'Dict[str, Any]', *, validate_remote: 'bool' = False) -> 'List[Dict[str, str]]':
        pass

    @classmethod
    def _validation_cache_key(cls, character_id: 'str', account_key_value: 'str', entity_id: 'str', sync_hash: 'str') -> 'str':
        pass

    @classmethod
    def _is_validation_cached(cls, cache_key: 'str') -> 'bool':
        pass

    @classmethod
    def _remember_validation(cls, cache_key: 'str') -> 'None':
        pass

    @staticmethod
    def _should_recreate_entity(exc: 'Exception') -> 'bool':
        pass

    def presync_all_characters_for_account(self, account: 'Dict[str, Any]', *, max_workers: 'int' = 2) -> 'Dict[str, str]':
        pass

    def presync_character_for_available_accounts(self, character_id: 'str', *, accounts: 'Optional[Iterable[Dict[str, Any]]]' = None, max_workers: 'int' = 4) -> 'Dict[str, str]':
        pass

    @staticmethod
    def _available_accounts(accounts: 'Optional[Iterable[Dict[str, Any]]]' = None) -> 'List[Dict[str, Any]]':
        pass

    def _sync_images(self, character, account: 'Dict[str, Any]', entity_id: 'str', project_id: 'str' = '') -> 'List[Dict[str, Any]]':
        pass

    @staticmethod
    def _copy_source_media_id(character) -> 'str':
        pass

    @staticmethod
    def _raw_image_base64_refs(character) -> 'List[Dict[str, str]]':
        pass

    @staticmethod
    def _same_account_chargen_media_id(character, account_key_value: 'str') -> 'str':
        pass

    @staticmethod
    def _same_account_chargen_workflow_id(character, account_key_value: 'str') -> 'str':
        pass

    @staticmethod
    def _has_usable_image_refs(refs) -> 'bool':
        """A ref slot is usable only when it points at a real uploaded image."""
        pass

    @staticmethod
    def _is_auth_upload_error(exc: 'Exception') -> 'bool':
        pass

    def _character_has_image_source(self, character) -> 'bool':
        pass

    @staticmethod
    def _persist_image_workflow_id(media_id: 'str', account_key_value: 'str', result: 'Any', workflow_id: 'str') -> 'None':
        pass

    @staticmethod
    def _cached_image_workflow_id(media_id: 'str', account_key_value: 'str') -> 'str':
        pass

    def _resolve_audio_references(self, character, account: 'Dict[str, Any]') -> 'List[Dict[str, Any]]':
        pass

    @staticmethod
    def _workflow_id_from_upload_result(result: 'Any') -> 'str':
        pass

    def _call_create_entity(self, account: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    @staticmethod
    def _resolve_slot_base64(character, media_id: 'str') -> 'str':
        pass

    def _call_upload_character_image(self, **kwargs) -> 'Dict[str, Any]':
        pass

    def _call_patch_entity(self, **kwargs) -> 'Dict[str, Any]':
        pass


# --- Top-Level Functions ---
def account_key(account: 'Dict[str, Any]') -> 'str':
    pass
