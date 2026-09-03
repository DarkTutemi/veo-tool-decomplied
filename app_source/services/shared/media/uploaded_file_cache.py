"""
Decompiled / Reconstructed Module: services.shared.media.uploaded_file_cache
Source PyC: uploaded_file_cache.pyc

Docstring:
Uploaded File Cache Service

Lưu trữ thông tin các file đã upload lên Gemini File API để tránh upload lại
Cache được lưu trong AppData để persistent và dễ quản lý
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional
Dict = typing.Dict
CLIENT_UPLOAD_CACHE_REUSE_ENABLED = False
_cache_instance = None

# --- Class: UploadedFileCache ---
class UploadedFileCache:
    """Cache for uploaded files to Gemini File API"""
    def __init__(self, cache_file: str = 'uploaded_files_cache.json'):
        pass

    def _load_cache(self) -> Dict:
        pass

    def _save_cache(self):
        pass

    def _cleanup_expired_entries(self, cache: Dict, expiry_hours: int = 48) -> Dict:
        pass

    def get(self, file_path: str) -> Optional[Dict]:
        pass

    def add(self, file_path: str, file_uri: str, duration_seconds: int = 0, file_size: int = 0, api_key_suffix: str = '', api_key_full: str = ''):
        pass

    def remove(self, file_path: str):
        pass

    def clear(self):
        pass

    def cleanup_expired(self, expiry_hours: int = 48):
        pass

    def is_valid(self, file_path: str, expiry_hours: int = 47) -> bool:
        pass

    def get_all_uploads(self) -> Dict[str, Dict]:
        pass

    def get_recent_uploads(self, limit: int = 50) -> list:
        pass


# --- Top-Level Functions ---
def get_uploaded_file_cache() -> services.shared.media.uploaded_file_cache.UploadedFileCache:
    pass
