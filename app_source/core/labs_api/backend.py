"""
Decompiled / Reconstructed Module: core.labs_api.backend
Source PyC: backend.pyc

Docstring:
core/labs_api/backend.py — V2 generation backend re-exports.

Callers import the generation entry points from here.  The legacy V1 backend
(core.api_client) has been removed; every name now re-exports directly from
core.labs_api (V2).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['generate_text_video', 'generate_text_video_dict', 'generate_image_video', 'generate_image_video_dict', 'generate_image_video_with_auto_fix', 'generate_extend_video_with_auto_fix', 'generate_multi_asset_video_with_auto_fix', 'upscale_video_to_1080p', 'poll_and_download', 'download_video', 'labs_api_v2_enabled']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
__all__ = ['generate_text_video', 'generate_text_video_dict', 'generate_image_video', 'generate_image_video_dict', 'generate_image_video_with_auto_fix', 'generate_extend_video_with_auto_fix', 'generate_multi_as... [truncated]

# --- Top-Level Functions ---
def labs_api_v2_enabled() -> 'bool':
    pass
