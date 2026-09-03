"""
Decompiled / Reconstructed Module: services.shared.composition.subtitle_safe_zones
Source PyC: subtitle_safe_zones.pyc

Docstring:
Versioned social-platform guides shared by preview and render contracts.

The source of truth is integer design pixels. Portrait guides use a
1080x1920 top-left coordinate space; normalized values are derived once for
QML scaling and quality checks. Button centers were calibrated against the
approved 1080x1920 VeoFlow visual references. ``All`` is derived from the union
of the three PNG alpha masks plus a measured clearance, not from hand-drawn
approximation rectangles. Platform chrome still changes by device, locale,
caption length and app version, so these are versioned visual guides, not
immutable platform APIs.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['ALL_PLATFORM_ALPHA_CLEARANCE_PX', 'ALL_PLATFORM_CONTENT_BOUNDS_PX', 'ALL_PLATFORM_OCCUPANCY_ASSET', 'LANDSCAPE_REFERENCE_CANVAS', 'PLATFORM_OVERLAY_ASSETS', 'PLATFORM_GUIDE_SELECTOR_IDS', 'PLATFORM_SAFE_ZONE_IDS', 'PORTRAIT_REFERENCE_CANVAS', 'SOCIAL_GUIDE_SCHEMA', 'SOCIAL_GUIDE_VERSION', 'STANDARD_OUTPUT_SIZES', 'normalize_platform_safe_zone', 'platform_safe_zone_options', 'recommended_caption_geometry', 'recommended_overlay_geometry', 'resolve_platform_safe_zone', 'scale_platform_safe_zone', 'standard_output_size']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Iterable = typing.Iterable
Mapping = typing.Mapping
SOCIAL_GUIDE_SCHEMA = 'subtitle_social_guide/4'
SOCIAL_GUIDE_VERSION = '2026-08-20'
PORTRAIT_REFERENCE_CANVAS = {'width': 1080, 'height': 1920}
LANDSCAPE_REFERENCE_CANVAS = {'width': 1920, 'height': 1080}
STANDARD_OUTPUT_SIZES = {'9:16': {'720p': (720, 1280), '1080p': (1080, 1920), '4k': (2160, 3840)}, '16:9': {'720p': (1280, 720), '1080p': (1920, 1080), '4k': (3840, 2160)}}
PLATFORM_OVERLAY_ASSETS = {'tiktok': 'tiktok_overlay_1080x1920.png', 'facebook': 'facebook_reels_overlay_1080x1920.png', 'youtube': 'youtube_shorts_overlay_1080x1920.png'}
ALL_PLATFORM_OCCUPANCY_ASSET = 'all_platforms_occupancy_1080x1920.png'
ALL_PLATFORM_ALPHA_CLEARANCE_PX = 48
ALL_PLATFORM_CONTENT_BOUNDS_PX = {'left': 72, 'top': 192, 'right': 876, 'bottom': 1386}
PLATFORM_SAFE_ZONE_IDS = ('auto', 'average', 'tiktok', 'facebook', 'youtube', 'none')
PLATFORM_GUIDE_SELECTOR_IDS = ('auto', 'tiktok', 'facebook', 'youtube', 'none')
_PLATFORM_LABELS = {'auto': 'All · an toàn cả 3 nền tảng', 'average': 'Trung bình · chế độ tương thích', 'tiktok': 'TikTok', 'facebook': 'Facebook', 'youtube': 'YouTube', 'none': 'Tắt'}
_PORTRAIT_ZONES = {'tiktok': {'source_basis': 'VeoFlow TikTok 1080x1920 visual reference; LTR controls calibrated 2026-08-20', 'content_bounds': {'left': 0.111111, 'top': 0.125, 'right': 0.722222, 'bottom': 0.65625}, '... [truncated]
__all__ = ['ALL_PLATFORM_ALPHA_CLEARANCE_PX', 'ALL_PLATFORM_CONTENT_BOUNDS_PX', 'ALL_PLATFORM_OCCUPANCY_ASSET', 'LANDSCAPE_REFERENCE_CANVAS', 'PLATFORM_OVERLAY_ASSETS', 'PLATFORM_GUIDE_SELECTOR_IDS', 'PLATFORM_... [truncated]

# --- Top-Level Functions ---
def platform_safe_zone_options() -> 'list[dict[str, str]]':
    pass

def standard_output_size(aspect_ratio: 'Any', tier: 'Any') -> 'tuple[int, int]':
    pass

def _norm(value: 'float', total: 'int') -> 'float':
    pass

def _bounds(rect_px: 'Mapping[str, float]', canvas: 'Mapping[str, int]') -> 'dict[str, Any]':
    pass

def _guide(guide_id: 'str', label: 'str', kind: 'str', rect: 'tuple[int, int, int, int]', canvas: 'Mapping[str, int]', platform: 'str', shape: 'str' = 'rect', control_center: 'tuple[int, int] | None' = None) -> 'dict[str, Any]':
    pass

def _portrait_platform(platform: 'str', content_rect: 'tuple[int, int, int, int]', guide_rows: 'Iterable[tuple[str, str, str, tuple[int, int, int, int], str, tuple[int, int] | None]]', source_basis: 'str') -> 'dict[str, Any]':
    pass

def _combined_portrait(platform: 'str', strategy: 'str') -> 'dict[str, Any]':
    pass

def normalize_platform_safe_zone(value: 'Any') -> 'str':
    pass

def _contract_base(platform: 'str', canvas: 'Mapping[str, int]', aspect: 'str') -> 'dict[str, Any]':
    pass

def resolve_platform_safe_zone(value: 'Any', *, aspect_ratio: 'str') -> 'dict[str, Any]':
    pass

def scale_platform_safe_zone(value: 'Any', *, aspect_ratio: 'str', output_width: 'int', output_height: 'int') -> 'dict[str, Any]':
    """Scale one design-pixel guide into the backend output coordinate space.

    The renderer is allowed to scale the 1080x1920 or 1920x1080 design canvas,
    but it must not silently stretch a guide into a different aspect ratio."""
    pass

def recommended_caption_geometry(value: 'Any', *, aspect_ratio: 'str') -> 'dict[str, Any]':
    pass

def recommended_overlay_geometry(value: 'Any', *, aspect_ratio: 'str') -> 'dict[str, Any]':
    pass
