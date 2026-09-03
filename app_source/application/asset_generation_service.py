"""
Decompiled / Reconstructed Module: application.asset_generation_service
Source PyC: asset_generation_service.pyc

Docstring:
Headless contracts for asset preview generation and saving.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
VALID_ASSET_TYPES = {'background', 'character', 'style'}
VALID_COUNTS = {1, 2, 4}
VALID_ASPECT_RATIOS = {'IMAGE_ASPECT_RATIO_SQUARE', 'IMAGE_ASPECT_RATIO_PORTRAIT', 'IMAGE_ASPECT_RATIO_PORTRAIT_THREE_FOUR', 'IMAGE_ASPECT_RATIO_LANDSCAPE'}
CHARACTER_STYLE_BLOCKS = {'Realistic (Ảnh thật)': 'ultra-photorealistic, shot on full-frame DSLR, 85mm lens, f/2.0, natural skin texture with visible pores, soft catchlights in eyes, subtle skin tones - no plastic look, no ov... [truncated]
BACKGROUND_ENVIRONMENT_BLOCKS = {'Indoor (Trong nhà)': 'interior environment, warm soft window or practical lighting, tasteful furniture and props arranged like a real home/office, shallow depth of field - foreground area kept clear... [truncated]
_MARKET_SHORT_TO_CULTURAL = {'vn': 'vietnam', 'us': 'united_states', 'uk': 'united_kingdom', 'jp': 'japan', 'kr': 'south_korea', 'cn': 'china', 'tw': 'china', 'th': 'thailand', 'id': 'indonesia', 'my': 'malaysia', 'ph': 'philipp... [truncated]
_MARKET_ADJECTIVE = {'vietnam': 'Vietnamese', 'japan': 'Japanese', 'south_korea': 'Korean', 'united_states': 'American', 'china': 'Chinese', 'taiwan': 'Taiwanese', 'thailand': 'Thai', 'indonesia': 'Indonesian', 'malaysia... [truncated]
_CHAR_GENDER = {'male': 'man', 'female': 'woman'}
_CHAR_AGE = {'genz': 'Gen-Z (18-24 years old)', 'adult': 'young adult (25-34)', 'mature': 'mature adult (35-45)'}
_CHAR_SKIN = {'fair': 'fair skin', 'medium': 'medium skin tone', 'tan': 'warm tan skin'}
_CHAR_EXPR = {'smile': 'warm genuine smile', 'confident': 'confident charismatic expression', 'friendly': 'friendly approachable expression'}
_CHAR_MAKEUP = {'light': 'light natural makeup', 'natural': 'barely-there natural makeup', 'none': 'clean natural face, no makeup'}
_CHAR_TIER = {'koc': 'everyday relatable micro-creator (KOC) vibe, authentic and trustworthy', 'kol': 'polished professional KOL, well-groomed and camera-confident', 'celebrity': 'high-end celebrity-grade, luxury ... [truncated]
_CHAR_WARDROBE = {'office': 'smart business-casual / office outfit', 'casual': 'elevated casual-chic outfit', 'street': 'trendy modern streetwear outfit', 'sport': 'clean sporty activewear outfit', 'gala': 'glamorous ... [truncated]
_CHAR_FRAMING = {'portrait': 'tight head-and-shoulders portrait', 'half': 'head-to-chest half-body framing', 'full': 'full-body shot, full outfit visible', 'multi': 'multi-angle character sheet: front, 3/4 and side v... [truncated]
_LIGHT = {'studio': 'soft studio key+fill lighting', 'natural': 'soft natural daylight', 'cinematic': 'cinematic dramatic lighting'}
_CHAR_BG = {'white': 'pure clean WHITE seamless studio background', 'grey': 'seamless light-grey studio background', 'context': 'clean, softly out-of-focus contextual background (no clutter)'}
_BG_ENV = {'indoor': 'interior environment, tasteful real home/office props', 'outdoor': 'outdoor real-world location, natural daylight', 'studio': 'professional photo-studio seamless backdrop', 'lifestyle': 'c... [truncated]

# --- Class: AssetGenerationService ---
class AssetGenerationService:
    """Pure application service for dry-run asset generation contracts."""
    def generate_preview(self, payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def save_preview(self, payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def style_preview(self, style_id: 'str') -> 'Dict[str, Any]':
        pass

    @staticmethod
    def _validate_generate(asset_type: 'str', prompt: 'str', count: 'int', aspect_ratio: 'str') -> 'List[str]':
        pass

    @staticmethod
    def _is_valid_base64(value: 'str') -> 'bool':
        pass


# --- Top-Level Functions ---
def _resources_dir() -> 'Path':
    pass

def _style_definitions_path() -> 'Path':
    pass

def _load_style_definitions() -> 'Dict[str, Any]':
    pass

def _find_style(style_id: 'str') -> 'Optional[Dict[str, Any]]':
    pass

def _cultural_market_key(market: 'Optional[str]') -> 'str':
    pass

def _cultural_asset_clause(market: 'Optional[str]', asset_type: 'str') -> 'str':
    pass

def _opt(options: 'Optional[Dict[str, Any]]', key: 'str') -> 'str':
    pass

def _character_identity_clause(options: 'Optional[Dict[str, Any]]', market: 'Optional[str]') -> 'str':
    pass

def build_affiliate_prompt(*, asset_type: 'str', user_prompt: 'str', style_preset: 'Optional[str]' = None, environment_preset: 'Optional[str]' = None, market: 'Optional[str]' = None, options: 'Optional[Dict[str, Any]]' = None) -> 'str':
    pass

def _default_asset_seed(asset_type: 'str', product: 'Optional[Dict[str, Any]]' = None) -> 'str':
    pass

def generate_asset_image_prompt(asset_type: 'str', *, market: 'Optional[str]' = None, voice_language: 'Optional[str]' = None, product: 'Optional[Dict[str, Any]]' = None, base_style: 'str' = '', options: 'Optional[Dict[str, Any]]' = None) -> 'str':
    """Multi-step AI-gen STEP 1: compose a detailed image-gen prompt for an affiliate
    character/background via the LLM, conditioned on the target MARKET culture + the
    PRODUCT context (instead of a hardcoded description). STEP 2 (image gen) consumes it.

    Returns "" on any failure — callers fall back to ``_default_asset_seed`` /
    ``build_affiliate_prompt``. Pure + defensive (no Qt)."""
    pass

def get_asset_generation_service() -> 'AssetGenerationService':
    pass
