"""
Decompiled / Reconstructed Module: core.browser.page_resource_blocker
Source PyC: page_resource_blocker.pyc

Docstring:
Shared browser-side resource blocking rules.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_FALSE_VALUES = {'false', 'off', 'none', 'no', '0'}
_VIDEO_EXTENSIONS = ('.mp4', '.webm', '.mov', '.m4v', '.m3u8', '.mpd', '.ts')
_IMAGE_EXTENSIONS = ('.png', '.jpg', '.jpeg', '.gif', '.webp', '.avif', '.bmp')
_VIDEO_URL_MARKERS = ('/videoplayback', 'flow-content.google/video/', 'mime=video', 'type=video', 'video/mp4', 'video/webm', '_upsampled')
MEDIA_THROTTLE_INIT_SCRIPT = '\n(() => {\n  if (window.__veoflowMediaThrottleInstalled) return;\n  Object.defineProperty(window, "__veoflowMediaThrottleInstalled", { value: true, configurable: false });\n  const apply = (el) => {... [truncated]
MEDIA_RENDER_SUPPRESS_INIT_SCRIPT = '\n(() => {\n  if (window.__veoflowMediaRenderSuppressInstalled) return;\n  Object.defineProperty(window, "__veoflowMediaRenderSuppressInstalled", { value: true, configurable: false });\n\n  const ins... [truncated]

# --- Top-Level Functions ---
def browser_page_media_blocking_enabled() -> 'bool':
    pass

def browser_page_media_throttle_enabled() -> 'bool':
    pass

def browser_page_media_render_suppress_enabled() -> 'bool':
    pass

def browser_page_image_blocking_enabled() -> 'bool':
    pass

def browser_page_resource_blocking_enabled() -> 'bool':
    pass

def should_block_page_resource(url: 'str', resource_type: 'str' = '') -> 'bool':
    """Return True for heavy page preview assets, never for normal API traffic."""
    pass

def blocked_url_patterns() -> 'list[str]':
    pass

def resource_log_label(url: 'str', max_len: 'int' = 96) -> 'str':
    pass

def media_throttle_init_script() -> 'str':
    pass
