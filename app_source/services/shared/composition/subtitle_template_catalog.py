"""
Decompiled / Reconstructed Module: services.shared.composition.subtitle_template_catalog
Source PyC: subtitle_template_catalog.pyc

Docstring:
Handcrafted Subtitle Studio render contracts.

The gallery and ASS renderer consume the same rows.  The public catalog is a
small curated set of independent treatments: no family/edition multiplication,
no color-only variants, and no QML-only swatches.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['HANDCRAFTED_TEMPLATE_COUNT', 'SUBTITLE_TEMPLATE_CATALOG', 'build_subtitle_template_catalog']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_BASE_TEMPLATES = ({'preset_id': 'clean', 'label': 'Clean Outline', 'category': 'readable', 'description': 'Viền sạch, cân bằng cho mọi footage.', 'recommended_for': 'Master · Clone', 'sample': 'Phụ đề rõ trên mọi nền'... [truncated]
HANDCRAFTED_TEMPLATE_COUNT = 16
_HANDCRAFTED_IDS = ('clean', 'yellow_punch', 'red_sticker', 'blue_plate', 'cyan_neon', 'orange_italic', 'cinematic', 'documentary', 'news', 'minimal_mono', 'karaoke', 'active_word', 'typewriter', 'pop_bounce', 'dual_lan... [truncated]
_ARCHETYPES = {'clean': 'OUTLINE', 'yellow_punch': 'SLAM', 'red_sticker': 'STICKER', 'blue_plate': 'LOWER 3RD', 'cyan_neon': 'NEON', 'orange_italic': 'SPEED', 'cinematic': 'CINEMA', 'documentary': 'DOC CARD', 'news... [truncated]
_ASS_EFFECTS = {'clean': 'clean_hold', 'yellow_punch': 'impact_slam', 'red_sticker': 'sticker_bounce', 'blue_plate': 'lower_third_wipe', 'cyan_neon': 'neon_flicker', 'orange_italic': 'speed_streak', 'cinematic': 'ci... [truncated]
_PREVIEW_TIMES = {'clean': 0.62, 'yellow_punch': 0.15, 'red_sticker': 0.18, 'blue_plate': 0.22, 'cyan_neon': 0.11, 'orange_italic': 0.16, 'cinematic': 0.52, 'documentary': 0.56, 'news': 0.16, 'minimal_mono': 0.62, 'ka... [truncated]
_PREVIEW_ZOOM = {'clean': 2.35, 'yellow_punch': 2.05, 'red_sticker': 1.95, 'blue_plate': 1.9, 'cyan_neon': 2.1, 'orange_italic': 1.95, 'cinematic': 2.0, 'documentary': 2.0, 'news': 1.85, 'minimal_mono': 2.55, 'karaok... [truncated]
SUBTITLE_TEMPLATE_CATALOG = ({'preset_id': 'clean', 'label': 'Clean Outline', 'archetype': 'OUTLINE', 'category': 'readable', 'description': 'Viền sạch, cân bằng cho mọi footage.', 'recommended_for': 'Master · Clone', 'sample': ... [truncated]
__all__ = ['HANDCRAFTED_TEMPLATE_COUNT', 'SUBTITLE_TEMPLATE_CATALOG', 'build_subtitle_template_catalog']

# --- Top-Level Functions ---
def _handcrafted_tokens(base: 'dict[str, Any]') -> 'dict[str, Any]':
    pass

def build_subtitle_template_catalog() -> 'tuple[dict[str, Any], ...]':
    pass
