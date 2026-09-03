"""
Decompiled / Reconstructed Module: core.multi_asset_limits
Source PyC: multi_asset_limits.pyc

Docstring:
Shared limits for ingredient/multi-asset video references.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional
DEFAULT_MULTI_ASSET_REFERENCE_LIMIT = 3
MAX_MULTI_ASSET_REFERENCE_LIMIT = 7
MAX_MULTI_ASSET_CHARACTER_REFERENCE_LIMIT = 3
DEFAULT_MULTI_ASSET_AUDIO_REFERENCE_LIMIT = 0
MAX_MULTI_ASSET_AUDIO_REFERENCE_LIMIT = 5

# --- Top-Level Functions ---
def clamp_reference_limit(value=None) -> int:
    pass

def multi_asset_slot_keys(max_slots: int = 7) -> list[str]:
    pass

def clamp_audio_reference_limit(value=None) -> int:
    pass

def multi_asset_voice_slot_keys(max_slots: int = 5) -> list[str]:
    pass

def _is_portrait_aspect(aspect_ratio: str) -> bool:
    pass

def _model_brand(model_key: str) -> str:
    pass

def resolve_reference_model_key(model_key: str, *, aspect_ratio: str = '', tier_mode: str = 'ultra', duration_seconds: Optional[int] = None) -> str:
    pass

def resolve_model_reference_image_limit(model_key: str, *, aspect_ratio: str = '', tier_mode: str = 'ultra', duration_seconds: Optional[int] = None, default: int = 3) -> int:
    pass

def resolve_model_character_reference_limit(model_key: str = '', *, default: int = 3) -> int:
    pass

def resolve_model_entity_limit(model_key: str = '') -> int:
    pass
