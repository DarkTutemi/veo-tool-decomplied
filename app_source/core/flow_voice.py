"""
Decompiled / Reconstructed Module: core.flow_voice
Source PyC: flow_voice.pyc

Docstring:
Shared Flow voice helpers.

This module is intentionally UI-free. Tabs/dialogs can use it to:
- read base voices from flow.projectInitialData
- build the Flow TTS preview/save payload
- persist/restore generated voice metadata
- build video referenceAudio entries for R2V/ingredient payloads
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
DEFAULT_FLOW_TOOL = 'PINHOLE'
FLOW_VOICE_RETRYABLE_GENERATION_CATEGORIES = {'browser_warmup_failed', 'browser_runtime_timeout', 'api_server_error', 'rate_limit', 'recaptcha_failed', 'network', 'session_bootstrap_pending', 'high_traffic', 'captcha_provider_down', 'server_erro... [truncated]

# --- Class: FlowVoice ---
class FlowVoice:
    """A base or generated Flow voice reference."""
    description = ''
    source = 'custom'
    base_voice = ''
    speaker = ''
    voice_performance = ''
    dialog = ''
    sample_url = ''
    workflow_id = ''
    project_id = ''
    model_key = 'gemini_v4s_tts_flow'
    visibility = ''

    def to_dict(self) -> 'Dict[str, Any]':
        pass

    @classmethod
    def from_dict(cls, data: 'Dict[str, Any]') -> "'FlowVoice'":
        pass

    def __init__(self, media_id: 'str', name: 'str', description: 'str' = '', source: 'str' = 'custom', base_voice: 'str' = '', speaker: 'str' = '', voice_performance: 'str' = '', dialog: 'str' = '', sample_url: 'str' = '', workflow_id: 'str' = '', project_id: 'str' = '', model_key: 'str' = 'gemini_v4s_tts_flow', visibility: 'str' = '', raw: 'Dict[str, Any]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: FlowVoiceBlueprint ---
class FlowVoiceBlueprint:
    """Local reusable recipe for generating the same custom Flow voice per account."""
    source = 'custom'
    base_voice = ''
    speaker = ''
    voice_performance = ''
    dialog = ''
    model_key = 'gemini_v4s_tts_flow'

    def to_dict(self) -> 'Dict[str, Any]':
        pass

    @classmethod
    def from_dict(cls, data: 'Dict[str, Any]') -> "'FlowVoiceBlueprint'":
        pass

    def sync_hash(self) -> 'str':
        pass

    def __init__(self, id: 'str', name: 'str', source: 'str' = 'custom', base_voice: 'str' = '', speaker: 'str' = '', voice_performance: 'str' = '', dialog: 'str' = '', model_key: 'str' = 'gemini_v4s_tts_flow', raw: 'Dict[str, Any]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: FlowVoiceAccountMapping ---
class FlowVoiceAccountMapping:
    """Generated Flow voice workflow for one local blueprint on one account."""
    project_id = ''
    media_id = ''
    workflow_id = ''
    remote_sync_hash = ''
    sync_status = 'synced'
    last_error = ''

    def to_dict(self) -> 'Dict[str, Any]':
        pass

    @classmethod
    def from_dict(cls, data: 'Dict[str, Any]') -> "'FlowVoiceAccountMapping'":
        pass

    def audio_reference(self) -> 'Dict[str, str]':
        pass

    def __init__(self, blueprint_id: 'str', account_key: 'str', project_id: 'str' = '', media_id: 'str' = '', workflow_id: 'str' = '', raw_response: 'Dict[str, Any]' = <factory>, remote_sync_hash: 'str' = '', sync_status: 'str' = 'synced', last_error: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def flow_voice_error_category(exc: 'Exception') -> 'str':
    pass

def flow_voice_retry_delay_seconds(attempt: 'int', category: 'str') -> 'float':
    pass

def _project_json(data: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def get_flow_tts_model_key(default: 'str' = 'gemini_v4s_tts_flow') -> 'str':
    pass

def normalize_session_id(session_id: 'str') -> 'str':
    pass

def extract_base_voices_from_project_initial_data(data: 'Dict[str, Any]') -> 'List[FlowVoice]':
    pass

def build_audio_generation_payload(*, project_id: 'str', session_id: 'str', recaptcha_token: 'str', dialog: 'str', voice_performance: 'str', speaker: 'str', base_voice: 'str', model_key: 'Optional[str]' = None, generation_type: 'str' = 'PREVIEW', tool: 'str' = 'PINHOLE') -> 'Dict[str, Any]':
    pass

def extract_audio_generation_request(payload: 'Dict[str, Any]') -> 'Dict[str, str]':
    pass

def _pick_live_flow_voice_account(accounts: 'Iterable[Dict[str, Any]]') -> 'Dict[str, Any]':
    pass

def generate_flow_voice_from_payload(payload: 'Dict[str, Any]', *, main_window=None, account: 'Optional[Dict[str, Any]]' = None, accounts: 'Optional[Iterable[Dict[str, Any]]]' = None, api_call: 'Optional[Callable[..., Dict[str, Any]]]' = None, max_attempts: 'int' = 3, retry_sleep: 'Optional[Callable[[float], None]]' = None) -> 'Dict[str, Any]':
    pass

def extract_generated_voice_from_response(response: 'Dict[str, Any]', *, fallback_name: 'str' = '', source: 'str' = 'custom') -> 'FlowVoice':
    pass

def _voice_media_id(item: 'Any') -> 'str':
    pass

def get_model_voice_slot_limit(model_key: 'str', default: 'int' = 0) -> 'int':
    pass

def build_reference_audio_entries(voices: 'Iterable[Any]', *, model_key: 'Optional[str]' = None, max_refs: 'Optional[int]' = None) -> 'List[Dict[str, str]]':
    pass
