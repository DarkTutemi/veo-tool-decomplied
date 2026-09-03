"""
Decompiled / Reconstructed Module: services.shared.voice.voice_api
Source PyC: voice_api.pyc

Docstring:
Shared Voice API — Qt-free, importable from any tab or service.

Wraps application/voice_service without adding any UI, Qt, or queue logic.
Gives any caller a single entry point to generate audio from text.

Usage:
    from services.shared.voice.voice_api import get_voice_api

    api = get_voice_api()
    result = api.generate("Xin chào thế giới")
    # → {ok, audio_path, duration, provider, voice_id}

    # Or with explicit config override:
    result = api.generate("...", {"provider": "minimax", "voice_id": "my_voice"})
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_instance = None
_lock = <unlocked _thread.lock object at 0x00000264E5134500>
_staged_consumer = {}
_staged_lock = <unlocked _thread.lock object at 0x00000264E5134D80>

# --- Class: VoiceAPI ---
class VoiceAPI:
    """Thin, Qt-free facade over the application voice service.

    All methods are synchronous and safe to call from background threads."""
    def generate(self, text: 'str', config: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def generate_omni(self, text: 'str', config: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    @staticmethod
    def list_narration_providers() -> 'list[dict[str, Any]]':
        pass

    @staticmethod
    def _selection_provider_options(provider: 'str', config: 'dict[str, Any] | None') -> 'tuple[dict[str, Any], dict[str, Any]]':
        pass

    def get_state(self) -> 'dict[str, Any]':
        pass

    def apply_state(self, delta: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def set_option(self, key: 'str', value: 'Any') -> 'dict[str, Any]':
        pass

    def get_narration_selection(self) -> 'dict[str, Any]':
        pass

    def get_consumer_narration_state(self) -> 'dict[str, Any]':
        pass

    def apply_narration_selection(self, provider: 'str', config: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def build_narration_snapshot(self, provider: 'str', config: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def preview_narration(self, provider: 'str', text: 'str', config: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def select_omni_voice(self, profile_id: 'str' = '', options: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def omni_config(self) -> 'dict[str, Any]':
        pass

    def get_compiled_config(self, mode: 'str' = 'manual') -> 'dict[str, Any]':
        pass

    def list_providers(self) -> 'list[dict[str, Any]]':
        pass

    def list_voices(self, provider: 'str' = '') -> 'list[dict[str, Any]]':
        pass

    def list_models(self, provider: 'str' = '') -> 'list[dict[str, Any]]':
        pass

    def list_omni_voices(self, server_url: 'str' = '') -> 'list[dict[str, Any]]':
        pass

    @staticmethod
    def list_omni_recipes() -> 'list[dict[str, Any]]':
        pass

    def config_schema(self, provider: 'str' = '') -> 'dict[str, Any]':
        pass

    def local_status(self) -> 'dict[str, Any]':
        pass

    def local_action(self, action: 'str') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _svc() -> 'Any':
        pass


# --- Top-Level Functions ---
def get_voice_api() -> 'VoiceAPI':
    pass

def stage_consumer_narration_draft(provider: 'str', config: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
    pass

def peek_staged_consumer_narration_draft() -> 'dict[str, Any]':
    pass

def freeze_job_narration_state(config: 'dict[str, Any] | None') -> 'dict[str, Any]':
    pass

def _gemini_consumer_route(state: 'dict[str, Any] | None') -> 'bool':
    pass

def _catalog_gemini_voice(raw: 'str') -> 'str':
    pass

def _stamp_gemini_narrator_identity(state: 'dict[str, Any] | None') -> 'dict[str, Any]':
    pass
