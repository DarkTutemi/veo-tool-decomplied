"""
Decompiled / Reconstructed Module: services.shared.tts.voice_config_presets
Source PyC: voice_config_presets.pyc

Docstring:
Named Voice Studio configuration presets.

These records are deliberately separate from approved voice profiles.  A
configuration preset stores reproducible provider controls; it never stores API
credentials, disposable preview anchors, or uploaded reference audio.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
_STORE_LOCK = <unlocked _thread.RLock object owner=0 count=0 at 0x00000264E3687580>
_SCHEMA_VERSION = 1
_PROVIDERS = {'vieneu', 'gemini', 'moss', 'omnivoice'}
_COMMON_KEYS = {'tts_route'}
_PROVIDER_KEYS = {'gemini': {'sample_context', 'gemini_voice', 'gemini_audio_profile', 'gemini_director_notes', 'emotion', 'voice', 'scene', 'voice2', 'dialogue_enabled', 'speakers', 'preset_id', 'gemini_model', 'voic... [truncated]
_BLOCKED_KEY_PARTS = ('api_key', 'apikey', 'token', 'secret', 'password', 'cookie', 'ref_audio', 'ref_text', 'anchor', 'preview_path', 'audio_path', 'server_url', 'omni_url')
_STORE = None

# --- Class: VoiceConfigPresetStore ---
class VoiceConfigPresetStore:
    """Small atomic JSON store; callers run its methods off the GUI thread."""
    def __init__(self, path: 'str | Path | None' = None) -> 'None':
        pass

    def _read(self) -> 'list[dict[str, Any]]':
        pass

    def _write(self, rows: 'list[dict[str, Any]]') -> 'None':
        pass

    @staticmethod
    def _public(row: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    def list(self) -> 'dict[str, Any]':
        pass

    def save(self, name: 'str', provider: 'str', config: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
        pass

    def rename(self, preset_id: 'str', name: 'str') -> 'dict[str, Any]':
        pass

    def update(self, preset_id: 'str', provider: 'str', config: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
        pass

    def delete(self, preset_id: 'str') -> 'dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _now() -> 'str':
    pass

def _text(value: 'Any') -> 'str':
    pass

def _provider(value: 'Any') -> 'str':
    pass

def _json_value(value: 'Any') -> 'Any':
    """Copy only values that are safe to serialize into the preset document."""
    pass

def sanitize_config(provider: 'str', config: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
    """Return the provider-specific, credential-free preset payload."""
    pass

def get_voice_config_preset_store() -> 'VoiceConfigPresetStore':
    pass
