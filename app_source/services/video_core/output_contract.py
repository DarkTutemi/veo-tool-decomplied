"""
Decompiled / Reconstructed Module: services.video_core.output_contract
Source PyC: output_contract.pyc

Docstring:
Shared output-quality contract for generated video and still-image routes.

Veo renders the base clip at 720p. Higher qualities are post-generation video
upscale targets. Omni 360p (6cr) renders natively at 360p — UI 720p is the
only legal upscale (omni_upsampler_360p), not a no-upscale generate.
Image routes map the same selector to still-image targets:
720p -> base image, 1080p -> 2K image, 4K -> 4K image.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['image_output_contract', 'normalize_video_quality', 'preferred_video_output_path', 'video_output_contract']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Mapping = typing.Mapping
__all__ = ['image_output_contract', 'normalize_video_quality', 'preferred_video_output_path', 'video_output_contract']

# --- Top-Level Functions ---
def normalize_video_quality(value: 'Any') -> 'str':
    pass

def video_output_contract(value: 'Any', model_key: 'str' = '') -> 'Dict[str, Any]':
    pass

def image_output_contract(value: 'Any') -> 'Dict[str, Any]':
    pass

def preferred_video_output_path(source: 'Any') -> 'str':
    pass
