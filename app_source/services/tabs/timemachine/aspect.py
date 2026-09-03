"""
Decompiled / Reconstructed Module: services.tabs.timemachine.aspect
Source PyC: aspect.pyc

Docstring:
Aspect-ratio mapping for Time Machine image and video stages.

The UI stores the same canonical values as the other video tabs (``16:9`` or
``9:16``). Image generation and video dispatch use different API enums, so the
conversion happens only at their respective boundaries.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['image_aspect_ratio', 'is_portrait', 'normalize_timemachine_aspect', 'video_aspect_ratio']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
__all__ = ['image_aspect_ratio', 'is_portrait', 'normalize_timemachine_aspect', 'video_aspect_ratio']

# --- Top-Level Functions ---
def normalize_timemachine_aspect(value: 'Any') -> 'str':
    pass

def is_portrait(value: 'Any') -> 'bool':
    pass

def image_aspect_ratio(value: 'Any') -> 'str':
    pass

def video_aspect_ratio(value: 'Any') -> 'str':
    pass
