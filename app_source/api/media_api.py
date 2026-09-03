"""
Decompiled / Reconstructed Module: api.media_api
Source PyC: media_api.pyc

Docstring:
Global Media API
Cổng truy cập toàn cục vào Media Library

🎯 NHIỆM VỤ:
- Cung cấp singleton instance của MediaLibraryManager
- API đơn giản để các module khác truy cập media
- Không có business logic, chỉ là gateway

💡 USAGE:
    from api.media_api import MediaAPI
    
    # Get all media
    items = MediaAPI.get_all_media()
    
    # Get media by ID
    media = MediaAPI.get_media(media_id)
    
    # Add media
    media_id = MediaAPI.add_media(file_path, name="My Image")
    
    # Update AI metadata (from external service)
    MediaAPI.update_ai_metadata(media_id, structure, asset_type)
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional
List = typing.List
Dict = typing.Dict

# --- Class: MediaAPI ---
class MediaAPI:
    """Global API để truy cập Media Library"""
    _instance = None

    @classmethod
    def _get_manager(cls) -> config.media_library_manager.MediaLibraryManager:
        pass

    @classmethod
    def get_media(cls, media_id: str) -> Optional[Dict]:
        pass

    @classmethod
    def get_media_light(cls, media_id: str) -> Optional[Dict]:
        pass

    @classmethod
    def get_media_file_path(cls, media_id: str) -> str:
        pass

    @classmethod
    def get_thumbnail_file_path(cls, media_id: str) -> str:
        pass

    @classmethod
    def find_by_file_hash(cls, file_hash: str) -> Optional[Dict]:
        pass

    @classmethod
    def get_all_media(cls, filters: Dict = None) -> List[Dict]:
        pass

    @classmethod
    def get_stats(cls) -> Dict:
        pass

    @classmethod
    def add_media(cls, file_path: str, name: str = None, tags: List[str] = None, asset_type: str = None) -> Optional[str]:
        pass

    @classmethod
    def update_media(cls, media_id: str, updates: Dict) -> bool:
        pass

    @classmethod
    def delete_media(cls, media_id: str) -> bool:
        pass

    @classmethod
    def update_ai_metadata(cls, media_id: str, structure: Dict, asset_type: str, sub_type: str = None) -> bool:
        pass

    @classmethod
    def batch_set_asset_type(cls, media_ids: List[str], asset_type: str) -> int:
        pass

    @classmethod
    def sync_structure_names(cls) -> int:
        pass

    @classmethod
    def batch_import(cls, file_paths: List[str], tags: List[str] = None, asset_type: str = None) -> List[str]:
        pass

    @classmethod
    def last_batch_errors(cls) -> dict:
        pass

    @classmethod
    def get_base64(cls, media_id: str) -> Optional[str]:
        pass

    @classmethod
    def get_thumbnail(cls, media_id: str) -> Optional[str]:
        pass

    @classmethod
    def get_ai_structure(cls, media_id: str) -> Optional[Dict]:
        pass

    @classmethod
    def is_analyzed(cls, media_id: str) -> bool:
        pass

    @classmethod
    def select_media(cls, parent=None, filter_type: str = None) -> Optional[str]:
        pass

    @classmethod
    def select_multiple_media(cls, parent=None, filter_type: str = None) -> List[str]:
        pass

    @classmethod
    def get_veo3_media_id(cls, media_id: str, account_name: str) -> Optional[str]:
        pass

    @classmethod
    def get_veo3_upload(cls, media_id: str, account_name: str) -> Optional[Dict]:
        pass

    @classmethod
    def set_veo3_media_id(cls, media_id: str, account_name: str, veo3_media_id: str) -> bool:
        pass

    @classmethod
    def set_veo3_upload(cls, media_id: str, account_name: str, veo3_media_id: str, *, remote_handle: str = '', project_id: str = '', kind: str = 'image', extra: Optional[Dict] = None) -> bool:
        pass

    @classmethod
    def has_veo3_media_id(cls, media_id: str, account_name: str) -> bool:
        pass

    @classmethod
    def remove_veo3_media_id(cls, media_id: str, account_name: str) -> bool:
        pass

    @classmethod
    def remove_all_veo3_media_ids_for_account(cls, account_name: str) -> int:
        pass

    @classmethod
    def get_all_veo3_media_ids(cls, media_id: str) -> Dict[str, str]:
        pass

    @classmethod
    def get_all_veo3_uploads(cls, media_id: str) -> Dict[str, Dict]:
        pass

    @classmethod
    def find_veo3_upload_by_remote_media_id(cls, account_name: str, veo3_media_id: str) -> Optional[Dict]:
        pass

    @classmethod
    def clear_veo3_media_id(cls, media_id: str, account_name: str = None) -> bool:
        pass

    @classmethod
    def clear_expired_veo3_media_id(cls, media_id: str, account_email: str) -> bool:
        pass

    @classmethod
    def update_base64(cls, media_id: str, new_base64: str) -> bool:
        pass


# --- Top-Level Functions ---
def get_media(media_id: str) -> Optional[Dict]:
    pass

def get_media_light(media_id: str) -> Optional[Dict]:
    pass

def find_by_file_hash(file_hash: str) -> Optional[Dict]:
    pass

def get_all_media(filters: Dict = None) -> List[Dict]:
    pass

def add_media(file_path: str, **kwargs) -> Optional[str]:
    pass

def select_media(parent=None, filter_type: str = None) -> Optional[str]:
    pass
