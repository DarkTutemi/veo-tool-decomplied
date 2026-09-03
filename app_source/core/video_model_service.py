"""
Decompiled / Reconstructed Module: core.video_model_service
Source PyC: video_model_service.pyc

Docstring:
Video Model Service - Auto-sync model config from Google API
Single source of truth for VEO models with live API data
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_service_instance = None

# --- Class: VideoModelService ---
class VideoModelService:
    """Service để fetch và quản lý video model config từ Google API

    API Endpoint: /fx/api/trpc/flow.projectInitialData?input={"json":{"projectId":"..."}}

    Tier System (creditMapping):
    - SERVICE_TIER_ADVANCED = Ultra (PAYGATE_TIER_TWO)
    - SERVICE_TIER_INTERMEDIATE = Premium
    - SERVICE_TIER_ENTRY = Free/Entry

    Requirements mapping (thay capabilities cũ):
    - VIDEO_REQUIREMENT_TEXT → text_to_video
    - VIDEO_REQUIREMENT_START_IMAGE → image_to_video
    - VIDEO_REQUIREMENT_START_IMAGE + VIDEO_REQUIREMENT_END_IMAGE → interpolation
    - VIDEO_REQUIREMENT_EXTENSION → extend
    - VIDEO_REQUIREMENT_REFERENCES → r2v (multi-asset)
    - VIDEO_REQUIREMENT_UPSAMPLE1080 → upscale_1080p
    - VIDEO_REQUIREMENT_UPSAMPLE4K → upscale_4k
    - VIDEO_REQUIREMENT_OBJECT_INSERTION → object_insertion
    - VIDEO_REQUIREMENT_OBJECT_REMOVAL → object_removal
    - VIDEO_REQUIREMENT_RESHOOT → reshoot"""
    API_ENDPOINT = 'https://labs.google/fx/api/trpc/flow.projectInitialData'
    CACHE_TTL = 3600
    TIER_ADVANCED = 'SERVICE_TIER_ADVANCED'
    TIER_INTERMEDIATE = 'SERVICE_TIER_INTERMEDIATE'
    TIER_ENTRY = 'SERVICE_TIER_ENTRY'
    PAYGATE_ULTRA = 'PAYGATE_TIER_TWO'
    REQUIREMENT_MAP = {'VIDEO_REQUIREMENT_TEXT': 'text_to_video', 'VIDEO_REQUIREMENT_START_IMAGE': 'image_to_video', 'VIDEO_REQUIREMENT_END_IM...
    ASPECT_MAP = {'LANDSCAPE': 'VIDEO_ASPECT_RATIO_LANDSCAPE', 'PORTRAIT': 'VIDEO_ASPECT_RATIO_PORTRAIT'}
    ASPECT_LANDSCAPE = 'VIDEO_ASPECT_RATIO_LANDSCAPE'
    ASPECT_PORTRAIT = 'VIDEO_ASPECT_RATIO_PORTRAIT'
    SUPPORTED_FEATURES = {'upscale_4k', 'upscale_1080p', 'r2v', 'extend', 'image_to_video', 'text_to_video', 'interpolation', 'upscale_720p'}
    has_api_data = <property object at 0x00000264D8EA6110>
    cache_is_fresh = <property object at 0x00000264D8EA6160>

    @staticmethod
    def _coerce_int(value) -> Optional[int]:
        pass

    def __init__(self):
        pass

    def _parse_api_response(self, data: Dict) -> bool:
        pass

    def _requirements_to_features(self, requirements: List) -> List[str]:
        pass

    def _image_requirements_to_features(self, requirements: List) -> List[str]:
        """Convert image-model requirements to feature type list."""
        pass

    @staticmethod
    def _family_to_speed(family_id: str) -> str:
        pass

    def _build_video_entry(self, family_id: str, family_name: str, usage: dict, deprecated_keys: set):
        pass

    def sync_to_model_config(self):
        """Sync API data vào ModelConfig.VIDEO_MODELS.

        Rebuild hoàn toàn từ API data:
        1. Convert tất cả API models → ModelConfig entries
        2. Replace VIDEO_MODELS (giữ models không parse được từ API)
        3. Mark deprecated models
        4. Persist ra JSON file"""
        pass

    def fetch_sync(self, account_name: str, project_id: str) -> bool:
        pass

    def auto_sync_if_needed(self, account_name: str, project_id: str, force: bool = False):
        pass

    def sync_all_live_accounts(self, force: bool = False) -> int:
        pass

    def start_periodic_sync(self, interval_seconds: int = 3600):
        pass


# --- Top-Level Functions ---
def get_video_model_service() -> core.video_model_service.VideoModelService:
    pass
