"""
Decompiled / Reconstructed Module: application.api_keys_service
Source PyC: api_keys_service.pyc

Docstring:
Headless application service for server-managed API keys.

This mirrors the legacy Gemini API keys dialog behavior without importing PyQt
or UI code.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
Optional = typing.Optional
SUPPORTED_PROVIDERS = {'gemini'}

# --- Class: ApiKeysService ---
class ApiKeysService:
    """Use-cases for React API key management."""
    def list_keys(self, provider: 'str' = '') -> 'Dict[str, Any]':
        pass

    def get_key(self, key_id: 'int') -> 'Dict[str, Any]':
        pass

    def add_key(self, provider: 'str', api_key: 'str', label: 'str' = '') -> 'Dict[str, Any]':
        pass

    def remove_key(self, key_id: 'int') -> 'Dict[str, Any]':
        pass

    def update_mode(self, api_mode: 'str') -> 'Dict[str, Any]':
        pass

    def start_gemini_config(self) -> 'Dict[str, Any]':
        pass

    def test_key(self, provider: 'str', api_key: 'str') -> 'Dict[str, Any]':
        pass

    @staticmethod
    def _license_manager():
        pass

    @staticmethod
    def _normalize_provider(provider: 'str', *, allow_empty: 'bool' = False) -> 'str':
        pass

    @staticmethod
    def _normalize_keys(keys: 'Iterable[Dict[str, Any]]') -> 'List[Dict[str, Any]]':
        pass

    @staticmethod
    def _normalize_key(key: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    @staticmethod
    def _error(data: 'Optional[Dict[str, Any]]') -> 'Dict[str, Any]':
        pass

    @staticmethod
    def _clear_voice_cache(provider: 'str') -> 'None':
        pass


# --- Top-Level Functions ---
def get_api_keys_service() -> 'ApiKeysService':
    pass
