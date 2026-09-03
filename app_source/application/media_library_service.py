"""
Decompiled / Reconstructed Module: application.media_library_service
Source PyC: media_library_service.pyc

Docstring:
Headless facade for the global media library.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_IMAGE_EXTENSIONS = {'.png', '.jpg', '.gif', '.bmp', '.jpeg', '.webp'}
_VIDEO_EXTENSIONS = {'.webm', '.mkv', '.mov', '.mp4', '.avi'}
_PREVIEW_EXTENSIONS = {'.png', '.gif', '.bmp', '.mov', '.webp', '.mp4', '.webm', '.mkv', '.jpg', '.jpeg', '.avi'}
_MAX_FOLDER_IMPORT_FILES = 500
_MEDIA_LIBRARY_SERVICE = None

# --- Class: MediaLibraryService ---
class MediaLibraryService:
    """Read/select API for QML without importing legacy PyQt dialogs."""
    def __init__(self) -> 'None':
        pass

    def set_on_changed(self, cb) -> 'None':
        pass

    def _on_manager_invalidated(self, reason: 'str') -> 'None':
        pass

    def _media_manager(self):
        pass

    def invalidate_cache(self, reason: 'str' = '') -> 'None':
        pass

    def _copy_list_payload(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def _cached_list_payload(self, key: 'str') -> 'dict[str, Any] | None':
        pass

    def _store_list_payload(self, key: 'str', payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def picker_contract(self, action: 'str', *, route: 'str' = 'media_library') -> 'dict[str, Any]':
        pass

    def settings(self) -> 'dict[str, Any]':
        pass

    def list_media(self, *, search: 'str' = '', asset_type: 'str' = '', limit: 'int' = 240) -> 'dict[str, Any]':
        pass

    def match_by_name(self, prompts: 'list[Any]', *, asset_type: 'str' = 'image', limit: 'int' = 1000) -> 'dict[str, Any]':
        pass

    def import_files(self, paths: 'list[str]', *, tags: 'list[str] | None' = None, asset_type: 'str' = '') -> 'dict[str, Any]':
        pass

    def analyze_media_ids(self, media_ids: 'list[str]', *, route: 'str' = 'media_library') -> 'dict[str, Any]':
        pass

    def upload_media_ids(self, media_ids: 'list[str]', *, route: 'str' = 'media_library') -> 'dict[str, Any]':
        pass

    def preview_contract(self, media_id: 'str', *, route: 'str' = 'media_library') -> 'dict[str, Any]':
        pass

    def crop_contract(self, payload: 'dict[str, Any]', *, route: 'str' = 'media_library') -> 'dict[str, Any]':
        pass

    def delete_media(self, media_id: 'str', *, route: 'str' = 'media_library') -> 'dict[str, Any]':
        pass

    def rename_media(self, media_id: 'str', new_name: 'str', *, route: 'str' = 'media_library') -> 'dict[str, Any]':
        pass

    def update_media_asset_type(self, media_id: 'str', asset_type: 'str', *, route: 'str' = 'media_library') -> 'dict[str, Any]':
        pass

    def delete_media_items(self, media_ids: 'list[Any]', *, route: 'str' = 'media_library') -> 'dict[str, Any]':
        pass

    def list_characters(self, *, search: 'str' = '', limit: 'int' = 240) -> 'dict[str, Any]':
        pass

    def get_media(self, media_id: 'str') -> 'dict[str, Any] | None':
        pass

    def get_character(self, character_id: 'str') -> 'dict[str, Any]':
        pass

    def extract_character_from_image(self, file_path: 'str', *, name: 'str', description: 'str' = '', tags: 'list[str] | None' = None) -> 'dict[str, Any]':
        pass

    def delete_character(self, character_id: 'str') -> 'dict[str, Any]':
        pass

    def media_voice_library_payload(self, search: 'str' = '') -> 'dict[str, Any]':
        pass

    def create_media_voice(self, name: 'str', base_voice: 'str') -> 'dict[str, Any]':
        pass

    def media_voice_base_options(self) -> 'dict[str, Any]':
        pass

    def generate_media_voice(self, name: 'str', base_voice: 'str', speaker: 'str', voice_performance: 'str', dialog: 'str', model_key: 'str' = '') -> 'dict[str, Any]':
        pass

    def media_voice_bound_characters(self, voice_row: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def preview_media_voice(self, voice_row: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def bind_media_voice_to_character(self, media_id: 'str', voice_row: 'dict[str, Any] | None' = None, *, presync: 'bool' = True) -> 'dict[str, Any]':
        pass

    def unbind_media_voice_from_character(self, media_id: 'str') -> 'dict[str, Any]':
        pass

    def open_source_contract(self, media_id: 'str', *, route: 'str' = 'media_library') -> 'dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _clean_path(value: 'Any') -> 'str':
    pass

def _is_image_file(path: 'Path') -> 'bool':
    pass

def _safe_resolved(path: 'Path') -> 'str':
    pass

def _file_url(path: 'Path') -> 'str':
    pass

def _clamp(value: 'float', minimum: 'float', maximum: 'float') -> 'float':
    pass

def _crop_box_from_rect(crop_rect: 'dict[str, Any]', *, width: 'int', height: 'int') -> 'tuple[int, int, int, int]':
    pass

def _temp_output_path(source: 'Path') -> 'Path':
    pass

def _path_metadata(value: 'Any') -> 'dict[str, Any]':
    pass

def _blob_path_metadata(value: 'Any', *, probe_exists: 'bool' = True) -> 'dict[str, Any]':
    pass

def _effective_media_path_metadata(item: 'dict[str, Any]') -> 'dict[str, Any]':
    pass

def _media_row_path_metadata(item: 'dict[str, Any]') -> 'dict[str, Any]':
    pass

def _resolve_ffplay() -> 'str':
    pass

def _play_audio_with_ffplay(path: 'Path') -> 'dict[str, Any]':
    pass

def _fallback_flow_voices() -> 'list[Any]':
    pass

def _load_available_flow_voices() -> 'list[Any]':
    pass

def _append_unique(paths: 'list[str]', seen: 'set[str]', path: 'Path') -> 'None':
    pass

def _expand_import_paths(raw_paths: 'list[str]') -> 'tuple[list[str], list[str], list[dict[str, Any]]]':
    pass

def _media_row(item: 'dict[str, Any]', active_account_keys: 'list[str] | None' = None) -> 'dict[str, Any]':
    pass

def _light_media_stats(items: 'list[dict[str, Any]]') -> 'dict[str, Any]':
    pass

def _map_ai_type_to_asset_type(ai_type: 'Any') -> 'str':
    pass

def _blocker(code: 'str', message: 'str', *, route: 'str', action: 'str', surface: 'str' = 'MediaLibraryDialog', **extra: 'Any') -> 'dict[str, Any]':
    pass

def get_media_library_service() -> 'MediaLibraryService':
    pass
