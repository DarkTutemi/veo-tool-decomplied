"""
Decompiled / Reconstructed Module: services.shared.media.google_labs_image_service
Source PyC: google_labs_image_service.pyc

Docstring:
Google Labs Image Service - Generate images using Google Labs API
Replaces Whisk image generation with direct Google Labs batchGenerateImages API
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
http_requests = <core.labs_api.proxy.ProxyRequests object at 0x00000264D3ABF260>
_IMAGE_MODEL_QUOTA_LOCK = <unlocked _thread.lock object at 0x00000264E0705240>
_IMAGE_MODEL_QUOTA_DAY = ''
_IMAGE_MODEL_QUOTA_BLOCKED = set()
_HUMAN_VISUAL_FIELDS = (('visual_description', 'Complete appearance'), ('summary', 'Core appearance'), ('description', 'Visible description'), ('appearance', 'Appearance'), ('physical_description', 'Body and complexion'), (... [truncated]
_ANIMAL_VISUAL_FIELDS = (('visual_description', 'Complete appearance'), ('summary', 'Core appearance'), ('description', 'Visible description'), ('appearance', 'Appearance'), ('anatomy', 'Anatomy lock'), ('anatomy_lock', 'Ana... [truncated]
_OBJECT_VISUAL_FIELDS = (('visual_subject', 'Object class'), ('object_class', 'Object class'), ('product_type', 'Object class'), ('item_type', 'Object class'), ('visual_description', 'Complete appearance'), ('summary', 'Core... [truncated]
_RETRYABLE_UPSAMPLE_CATEGORIES = frozenset({'browser_runtime_timeout', 'rate_limit', 'recaptcha_failed', 'empty_media', 'network', 'browser_runtime_empty_response', 'captcha_provider_down', 'server_error', 'timeout'})
_UPSAMPLE_RETRY_WAVES = 3
_UPSAMPLE_RETRY_DELAY_S = 5.0

# --- Class: GoogleLabsImageService ---
class GoogleLabsImageService:
    """Generate images using Google Labs batchGenerateImages API"""
    def __init__(self):
        pass

    def upsample_image(self, media_id: str, account_name: str = None, resolution: str = 'UPSAMPLE_IMAGE_RESOLUTION_2K', account_email: str = None, workflow_id: str = None, project_id: str = None) -> Dict:
        pass

    def _build_chargen_prompt(self, char: dict, idx: int, visual_style: str = '') -> tuple:
        pass

    def _generate_single_character(self, char_key: str, prompt: str, account_name: str, aspect_ratio: str) -> dict:
        pass

    def generate_character_assets_batch(self, characters: list, output_dir: str = None, account_name: Optional[str] = None, visual_style: str = '', aspect_ratio: str = 'IMAGE_ASPECT_RATIO_LANDSCAPE') -> Dict[str, str]:
        pass

    def generate_images(self, prompt: str, account_name: str = None, output_count: int = 1, model: str = '', aspect_ratio: str = 'IMAGE_ASPECT_RATIO_LANDSCAPE', image_inputs: List[Dict] = None, will_upscale: bool = False, defer_base64_download: bool = False, max_403_retries: int = None, account_email: str = None, timeout_ms: int = 60000) -> Dict:
        """Generate images using Google Labs API

        Args:
            prompt: Text prompt for image generation
            account_name: Account name for session (auto-selected if None)
            output_count: Number of images to generate (1-4, default: 4)
            model: Model to use (GEM_PIX_2, IMAGEN_3_5, etc.)
            aspect_ratio: Aspect ratio (IMAGE_ASPECT_RATIO_LANDSCAPE or IMAGE_ASPECT_RATIO_PORTRAIT)
            image_inputs: Optional list of reference images (max 4)
            will_upscale: If True, skip downloading base64 (upscale API will provide it)
            defer_base64_download: If True, return mediaName/fifeUrl metadata
                without downloading the generated file into base64.

        Returns:
            Dict with 'success', 'images', 'total' or 'error'"""
        pass


# --- Top-Level Functions ---
def _image_quota_day() -> str:
    pass

def _quota_account_key(account_name: str = '', account_email: str = '') -> str:
    pass

def _reset_image_quota_cache_if_needed() -> None:
    pass

def _mark_image_model_quota(account_name: str, account_email: str, model: str) -> None:
    pass

def _image_model_quota_blocked(account_name: str, account_email: str, model: str) -> bool:
    pass

def _is_per_model_daily_quota(error: str) -> bool:
    pass

def _image_model_fallback_plan(requested_model: str) -> list[str]:
    pass

def _record_images_generated(count: int) -> None:
    pass

def _infer_human_demographic_hint(char: dict, text_blob: str) -> str:
    """Keep generated portraits grounded when the AI left ethnicity underspecified."""
    pass

def _face_details_to_prose(face: dict) -> str:
    pass

def _hair_to_prose(hair: dict) -> str:
    pass

def _scrub_entity_identity(text: object, entity: dict, replacement: str = '') -> str:
    pass

def _visual_value_text(value: object, entity: dict) -> str:
    """Flatten one explicitly allow-listed visual value into concise prose."""
    pass

def _collect_visual_traits(entity: dict, fields: tuple[tuple[str, str], ...]) -> list[str]:
    pass

def _is_elderly_character(char: dict) -> bool:
    """Recognize an explicitly older character without treating ``28 years old`` as elderly."""
    pass

def _uses_abstract_character_language(visual_style: str) -> bool:
    """Whether the framework represents people as graphic symbols, not portraits."""
    pass

def _character_style_anchor(visual_style: str) -> str:
    pass

def _character_white_background_contract() -> str:
    pass

def _object_style_anchor(visual_style: str) -> str:
    pass

def _character_rendering_block(char: dict, char_type: str, visual_style: str = '') -> str:
    pass

def _object_rendering_block() -> str:
    pass

def build_chargen_prompt(char: dict, visual_style: str = '') -> str:
    """Single source of truth for character reference sheet prompts.

    Generates a 3-panel horizontal layout optimized for 16:9:
      LEFT   — large face close-up (head + upper chest, maximum detail)
      CENTER — full body front view (complete outfit)
      RIGHT  — full body back view (outfit back, hair from behind)

    Handles both human and animal/creature character types.
    Parses structured fields (physical_description, face_details, hair,
    clothing as dicts) as well as flat string fields.

    Args:
        char: Character dict from asset_library (any tab)
        visual_style: Optional style suffix (e.g. "Pixar 3D animation")

    Returns:
        Ready-to-send prompt string for Imagen."""
    pass

def build_objgen_prompt(obj: dict, visual_style: str = '') -> str:
    pass

def _classify_upsample_failure(error: str, explicit_category: str = '') -> tuple[str, bool]:
    pass
