"""
Decompiled / Reconstructed Module: services.shared.media.runtime_upload_service
Source PyC: runtime_upload_service.pyc

Docstring:
Runtime upload boundary for generated or local reference images.

Generated image jobs usually receive a Google media UUID plus a temporary file
URI. Keep that lightweight reference through the pipeline and only materialize
bytes at the final upload boundary for accounts that cannot reuse the source
media UUID directly.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional

# --- Class: RuntimeUploadService ---
class RuntimeUploadService:
    """Upload lightweight runtime image refs to VEO accounts."""
    _download_locks = {}
    _download_locks_guard = <unlocked _thread.lock object at 0x00000264E22B36C0>

    @staticmethod
    def account_key(account: 'dict') -> 'str':
        pass

    @staticmethod
    def account_name(account: 'dict') -> 'str':
        pass

    @staticmethod
    def normalize_ref(ref: 'dict | None', **fallbacks) -> 'Dict':
        pass

    @staticmethod
    def has_payload(ref: 'dict | None') -> 'bool':
        pass

    @staticmethod
    def _same_account(ref: 'Dict', account: 'dict') -> 'bool':
        pass

    @staticmethod
    def _suffix_from_content_type(content_type: 'str') -> 'str':
        pass

    @staticmethod
    def _download_uri_to_cache(uri: 'str', source_account: 'str' = '') -> 'Optional[str]':
        pass

    @staticmethod
    def _download_uri_to_cache_locked(uri: 'str', source_account: 'str', cache_dir: 'str', uri_hash: 'str') -> 'Optional[str]':
        pass

    @staticmethod
    def upload_ref_to_account(ref: 'dict', account: 'dict', *, mime_type: 'str' = 'image/png', save_to_media_id: 'Optional[str]' = None) -> 'Optional[str]':
        pass

    @staticmethod
    def upload_ref_to_accounts(ref: 'dict', accounts: 'List[dict]', *, mime_type: 'str' = 'image/png') -> 'Dict[str, str]':
        pass

