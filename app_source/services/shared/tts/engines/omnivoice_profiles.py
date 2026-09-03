"""
Decompiled / Reconstructed Module: services.shared.tts.engines.omnivoice_profiles
Source PyC: omnivoice_profiles.pyc

Docstring:
Explicit OmniVoice profile-library workflow.

Recipes only describe how to sample a new tone. They never enter this library.
A profile is created exclusively from a WAV that the user has previewed and
approved. All HTTP/filesystem work in this module is called from a worker.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
_PROFILE_CATALOG_LOCK = <unlocked _thread.RLock object owner=0 count=0 at 0x00000264E2BB1500>
_PROFILE_CATALOG_VERSION = 1

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _profile_catalog_path() -> 'Path':
    pass

def _normalized_profiles(rows: 'Any') -> 'list[dict[str, Any]]':
    pass

def _read_cached_profiles() -> 'list[dict[str, Any]]':
    pass

def _write_cached_profiles(rows: 'list[dict[str, Any]]') -> 'None':
    pass

def _upsert_cached_profile(profile: 'Mapping[str, Any]') -> 'None':
    pass

def _rename_cached_profile(profile_id: 'str', name: 'str') -> 'None':
    pass

def _remove_cached_profile(profile_id: 'str') -> 'None':
    pass

def _approved_audio_dir() -> 'Path':
    pass

def _resolve_existing_audio(raw: 'str', pid: 'str' = '') -> 'str':
    pass

def approved_profile_audio(profile_id: 'str') -> 'str':
    pass

def _merge_local_approved(profiles: 'list[dict[str, Any]]') -> 'list[dict[str, Any]]':
    pass

def _studio_database_path() -> 'Path':
    pass

def _read_studio_profiles() -> 'list[dict[str, Any]] | None':
    pass

def _base_url(server_url: 'str' = '', *, start: 'bool') -> 'str':
    pass

def sample_text(language: 'str') -> 'str':
    pass

def normalize_profile(raw: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def list_profiles(server_url: 'str' = '', *, start: 'bool' = False) -> 'dict[str, Any]':
    pass

def create_approved_profile(*, name: 'str', audio_path: 'str', sample_transcript: 'str', language: 'str', server_url: 'str' = '') -> 'dict[str, Any]':
    pass

def rename_profile(profile_id: 'str', name: 'str', server_url: 'str' = '') -> 'dict[str, Any]':
    pass

def delete_profile(profile_id: 'str', server_url: 'str' = '') -> 'dict[str, Any]':
    pass

def profile_audio(profile_id: 'str', server_url: 'str' = '') -> 'dict[str, Any]':
    pass
