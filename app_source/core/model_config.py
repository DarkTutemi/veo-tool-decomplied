"""
Decompiled / Reconstructed Module: core.model_config
Source PyC: model_config.pyc

Docstring:
Global Model Configuration
Single source of truth for all VEO models
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple

# --- Class: ModelConfig ---
class ModelConfig:
    """Global model configuration manager
    Single source of truth for all VEO models across the application

    TIER SYSTEM (data-driven, NOT speed-based):
    - Tier availability = creditMapping (see _is_model_for_tier): a model is usable
      by a tier when its credit_mapping has a cost for that tier's credit_key.
    - `speed` is the QUALITY family (lite/fast/quality), orthogonal to tier — set by
      the loader from videoModelFamily, never parsed from the key's `_ultra` suffix."""
    DISABLED_KEYWORDS = {'relaxedd'}
    TIER_ADVANCED = 'advanced'
    TIER_INTERMEDIATE = 'intermediate'
    TIER_ENTRY = 'entry'
    VIDEO_MODELS = {}
    IMAGE_MODELS = {}
    FEATURE_FLAGS = {}
    _update_callbacks = []
    _callbacks_lock = None
    VIDEO_MODELS_JSON = 'video_models.json'
    VIDEO_MODELS_CACHE_JSON = 'video_models_cache.json'
    _DEFAULT_SPEED_PREFERENCE = ('fast', 'ultra', 'quality', 'lite', 'relaxed', 'standard')
    TIER_DEFAULT_FAMILIES = {}
    AUDIO_MODEL_KEY = ''
    BASE_AUDIO_REFERENCES = []
    SPEED_ORDER = {'lite': 0, 'fast': 1, 'ultra': 2, 'quality': 3, 'relaxed': 4, 'standard': 5}

    @classmethod
    def is_model_disabled(cls, model_key: str) -> bool:
        pass

    @classmethod
    def is_model_enabled(cls, model_key: str) -> bool:
        pass

    @classmethod
    def requires_ultra(cls, model_key: str) -> bool:
        pass

    @classmethod
    def _infer_duration_seconds(cls, model_key: str, model_info: Optional[dict] = None) -> Optional[int]:
        pass

    @classmethod
    def _is_video_edit_usage(cls, info: dict | None) -> bool:
        """True for Flow VIDEO_EDIT usages (e.g. abra_edit). Not a gen picker model."""
        pass

    @classmethod
    def _duration_matches(cls, model_key: str, model_info: dict, duration_seconds: Optional[int]) -> bool:
        pass

    @classmethod
    def get_model_duration_seconds(cls, model_key: str) -> Optional[int]:
        pass

    @classmethod
    def get_available_durations(cls, video_type: Optional[str] = None, aspect_ratio: Optional[str] = None, tier_mode: str = 'ultra', speed: Optional[str] = None, include_auxiliary: bool = False) -> List[int]:
        pass

    @classmethod
    def get_models_for_tier(cls, tier_mode: str, video_type: str = None, aspect_ratio: Optional[str] = None, duration_seconds: Optional[int] = None) -> List[Dict]:
        pass

    @classmethod
    def get_default_model_for_tier(cls, feature: str, tier_mode: str) -> str:
        pass

    @classmethod
    def _is_model_for_tier(cls, model_info: dict, tier_mode: str) -> bool:
        pass

    @classmethod
    def _tier_mode_to_credit_key(cls, tier_mode: str) -> str:
        pass

    @classmethod
    def _tier_mode_to_service_tier(cls, tier_mode: str) -> str:
        pass

    @classmethod
    def _normalize_tier_mode(cls, tier: str) -> str:
        pass

    @classmethod
    def resolve_in_family(cls, family_id: str, model_type: str, tier_mode: str, duration_seconds: Optional[int] = None, aspect_ratio: Optional[str] = None, source_model_key: Optional[str] = None) -> str:
        pass

    @classmethod
    def model_credits(cls, model_key: str, tier_mode: str = 'ultra') -> int:
        pass

    @classmethod
    def model_available_for_tier(cls, model_key: str, tier_mode: str = 'ultra') -> bool:
        pass

    @classmethod
    def coerce_model_to_tier(cls, model_key: str, tier_mode: str, duration_seconds: Optional[int] = None) -> str:
        pass

    @classmethod
    def set_dynamic_catalog_metadata(cls, tier_defaults: Optional[dict] = None, audio_model_key: Optional[str] = None, base_audio_references: Optional[list] = None):
        pass

    @classmethod
    def get_audio_model_key(cls, default: str = 'gemini_v4s_tts_flow') -> str:
        pass

    @classmethod
    def get_base_audio_references(cls) -> List[Dict]:
        pass

    @classmethod
    def get_default_family_for_tier(cls, tier_mode: str, media_kind: str = 'video') -> str:
        pass

    @classmethod
    def _find_dynamic_default_model(cls, video_type: str, tier_mode: str = 'ultra') -> str:
        pass

    @classmethod
    def _model_supports_aspect(cls, info: dict, target_aspect: str) -> bool:
        pass

    @classmethod
    def get_models_by_type(cls, video_type: str, aspect_ratio: Optional[str] = None, tier_mode: str = 'ultra', variant: Optional[str] = 'exclude_fl', duration_seconds: Optional[int] = None) -> List[Dict]:
        pass

    @classmethod
    def image_generation_models(cls) -> List[str]:
        pass

    @classmethod
    def is_valid_image_model(cls, key: str) -> bool:
        pass

    @classmethod
    def image_model_options(cls) -> List[Dict[str, str]]:
        pass

    @classmethod
    def get_default_image_model(cls) -> str:
        pass

    @classmethod
    def get_default_model(cls, video_type: str, tier_mode: Optional[str] = None) -> str:
        pass

    @classmethod
    def get_model_info(cls, model_key: str) -> Optional[Dict]:
        pass

    @classmethod
    def find_model_info(cls, model_key: str) -> Optional[Dict]:
        pass

    @classmethod
    def get_generation_time_seconds(cls, model_key: str, default: int = 0) -> int:
        pass

    @classmethod
    def get_api_model_key(cls, model_key: str) -> str:
        pass

    @classmethod
    def get_model_max_image_inputs(cls, model_key: str, default: int = 3) -> int:
        pass

    @classmethod
    def get_model_max_audio_references(cls, model_key: str, default: int = 0) -> int:
        pass

    @classmethod
    def add_dynamic_model(cls, key: str, entry: dict):
        pass

    @classmethod
    def _get_writable_json_path(cls) -> str:
        pass

    @classmethod
    def _get_legacy_writable_json_path(cls) -> str:
        pass

    @classmethod
    def _get_bundled_json_path(cls) -> str:
        pass

    @classmethod
    def save_to_json(cls):
        pass

    @classmethod
    def load_from_json(cls) -> bool:
        pass

    @classmethod
    def _get_callbacks_lock(cls):
        pass

    @classmethod
    def register_update_callback(cls, callback):
        pass

    @classmethod
    def unregister_update_callback(cls, callback):
        pass

    @classmethod
    def notify_models_updated(cls):
        pass

    @classmethod
    def get_model_by_type_and_speed(cls, video_type: str, speed: str, is_portrait: bool = False, variant: str = None, tier_mode: str = 'ultra', duration_seconds: Optional[int] = None) -> str:
        pass

    @classmethod
    def resolve_model(cls, feature: str, aspect_ratio: str = '16:9', speed: str = 'ultra', tier: str = 'ultra', variant: str = None, duration_seconds: Optional[int] = None) -> str:
        pass

    @classmethod
    def get_aspect_ratio(cls, model_key: str) -> str:
        pass

    @classmethod
    def get_display_name(cls, model_key: str) -> str:
        pass

    @classmethod
    def get_credits(cls, model_key: str, tier: str = 'advanced') -> int:
        pass

    @classmethod
    def is_valid_model(cls, model_key: str) -> bool:
        pass

    @classmethod
    def _find_upscale_model(cls, resolution: str) -> str:
        pass

    @classmethod
    def get_upscale_model(cls) -> str:
        pass

    @classmethod
    def allowed_upscale_resolutions(cls, model_key: str) -> list:
        """Upscale targets *model_key*'s OUTPUT may legally reach — DATA-DRIVEN from
        projectInitialData (27/8/2026 Omni rule): source entry's supported_resolutions
        ∩ each upsampler's supported_input_resolutions.

        360p Omni model → ['720p'] (omni_upsampler_360p only);
        720p model → ['1080p', '4k']; unknown/legacy entry (no supported_resolutions)
        → fail-open assumes the legacy 720p base → ['1080p', '4k']."""
        pass

    @classmethod
    def get_upscale_model_for_resolution(cls, resolution: str = '1080p', tier_mode: str = None, source_model_key: str = '') -> str:
        pass

    @classmethod
    def set_feature_flags(cls, flags: Dict) -> None:
        pass

    @classmethod
    def feature_enabled(cls, name: str, default: bool = True) -> bool:
        pass

    @classmethod
    def image_upscale_allowed(cls, resolution_4k: bool, tier_mode: str) -> bool:
        pass

    @classmethod
    def get_api_client_dict(cls) -> Dict[str, str]:
        pass

    @staticmethod
    def normalize_aspect_ratio(aspect_ratio: str) -> str:
        pass

    @staticmethod
    def is_portrait(aspect_ratio: str) -> bool:
        pass


# --- Top-Level Functions ---
def _verbose_init_logs() -> bool:
    pass
