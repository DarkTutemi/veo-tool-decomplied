"""
Decompiled / Reconstructed Module: services.shared.flow.flow_character_auto_builder
Source PyC: flow_character_auto_builder.pyc

Docstring:
Create FlowCharacter rows from AI-generated character/image/voice specs.
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
DEFAULT_FLOW_TTS_MODEL_KEY = 'gemini_v4s_tts_flow'
_SCENE_CHARACTER_ID_RE = re.compile('^CHAR_\\d{3}$')
_blueprint_presync_in_progress = set()
_blueprint_presync_guard = <unlocked _thread.lock object at 0x00000264E221DFC0>
_SPEECH_VERB_RE = 'says|said|speaks|asks|replies|responds|whispers|shouts|calls|cries|laughs|noi|nói|hoi|hỏi|tra loi|trả lời'

# --- Class: FlowCharacterAutoBuilder ---
class FlowCharacterAutoBuilder:
    """Build local character records that can later sync into Flow entities."""
    def __init__(self, *, character_store: 'Optional[FlowCharacterStore]' = None, voice_store: 'Optional[FlowVoiceStore]' = None):
        pass

    def upsert_generated_characters(self, specs: 'Iterable[Dict[str, Any]]') -> 'List[str]':
        pass

    def _upsert_voice_blueprint(self, spec: 'Dict[str, Any]') -> 'Dict[str, str]':
        pass


# --- Top-Level Functions ---
def _safe_identity_part(value: 'str', fallback: 'str') -> 'str':
    pass

def is_scene_character_id(value: 'str') -> 'bool':
    pass

def generated_flow_character_id(scope_id: 'str', logical_id: 'str') -> 'str':
    pass

def _trigger_blueprint_presync_all_accounts(blueprint_id: 'str') -> 'None':
    pass

def media_library_flow_character_id(media_id: 'str') -> 'str':
    pass

def _media_character_structure(media: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _is_character_media(media: 'Dict[str, Any]') -> 'bool':
    pass

def materialize_media_library_character(media_id: 'str', media: 'Dict[str, Any]', *, builder: 'Optional[FlowCharacterAutoBuilder]' = None) -> 'str':
    pass

def presync_flow_character_to_live_accounts_async(character_id: 'str') -> 'bool':
    pass

def prepare_voice_locked_media_library_characters(asset_ids: 'Iterable[str]', *, model_key: 'str', aspect_ratio: 'str' = '', tier_mode: 'str' = 'ultra', duration_seconds: 'Optional[int]' = None, media_lookup: 'Optional[Callable[[str], Dict[str, Any]]]' = None, builder: 'Optional[FlowCharacterAutoBuilder]' = None, max_characters: 'int' = 3) -> 'Dict[str, List[str]]':
    pass

def bind_voice_row_to_media_library_character(media_id: 'str', voice_row: 'Dict[str, Any]', *, media_lookup: 'Optional[Callable[[str], Dict[str, Any]]]' = None, metadata_update: 'Optional[Callable[[str, Dict[str, Any], str, str], bool]]' = None, builder: 'Optional[FlowCharacterAutoBuilder]' = None) -> 'Dict[str, Any]':
    pass

def unbind_voice_from_media_library_character(media_id: 'str', *, media_lookup: 'Optional[Callable[[str], Dict[str, Any]]]' = None, metadata_update: 'Optional[Callable[[str, Dict[str, Any], str, str], bool]]' = None, builder: 'Optional[FlowCharacterAutoBuilder]' = None) -> 'Dict[str, Any]':
    pass

def materialize_saved_media_library_character_if_voice_locked(media_id: 'str', media: 'Dict[str, Any]', *, builder: 'Optional[FlowCharacterAutoBuilder]' = None, presync: 'bool' = True) -> 'str':
    pass

def _list_characters(asset_library: 'Dict[str, Any]') -> 'List[Dict[str, Any]]':
    pass

def _metadata_image_media_ids(meta: 'Dict[str, Any]') -> 'List[str]':
    pass

def _metadata_media_library_id(meta: 'Dict[str, Any]') -> 'str':
    pass

def _metadata_prefers_generated_base64(meta: 'Dict[str, Any]') -> 'bool':
    pass

def _metadata_image_base64_refs(character_id: 'str', meta: 'Dict[str, Any]') -> 'List[Dict[str, str]]':
    pass

def _scene_dialog_sample_for_character(character: 'Dict[str, Any]', scene: 'Optional[Dict[str, Any]]') -> 'str':
    pass

def _scene_voice_performance_for_character(character: 'Dict[str, Any]', scene: 'Optional[Dict[str, Any]]') -> 'str':
    pass

def _voice_spec_for_character(character: 'Dict[str, Any]', scene: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
    pass

def build_flow_character_specs_from_scene_assets(*, asset_library: 'Dict[str, Any]', character_metadata: 'Dict[str, Dict[str, Any]]', enabled: 'bool', model_key: 'str', max_characters: 'int' = 3, scene: 'Optional[Dict[str, Any]]' = None, identity_scope: 'str' = '') -> 'List[Dict[str, Any]]':
    pass

def enrich_result_data_for_flow_voice_lock(result_data: 'Dict[str, Any]', *, enabled: 'bool', model_key: 'str', default_language: 'str' = '', source: 'str' = 'shared') -> 'Dict[str, Any]':
    pass

def attach_flow_character_entities(prompt_data: 'Dict[str, Any]', character_specs: 'Optional[Iterable[Dict[str, Any]]]' = None, *, builder: 'Optional[FlowCharacterAutoBuilder]' = None) -> 'Dict[str, Any]':
    pass
