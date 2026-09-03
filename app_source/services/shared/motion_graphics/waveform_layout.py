"""
Decompiled / Reconstructed Module: services.shared.motion_graphics.waveform_layout
Source PyC: waveform_layout.pyc

Docstring:
Canonical Sequence Graphics waveform placement.

Preview and Revideo both consume this contract.  Positions are normalized
to the video frame so 720p / 1080p / 4K share the same relative placement,
and 16:9 / 9:16 only change the pixel canvas, not the rule.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['BOTTOM_Y_NORM', 'FULL_WIDTH_NORM', 'HALF_WIDTH_NORM', 'SIDE_INSET_NORM', 'TOP_Y_NORM', 'canvas_size_for_aspect', 'layouts_share_norms', 'normalize_aspect_ratio', 'relocate_reserved_position', 'resolve_auto_length', 'resolve_auto_position', 'resolve_waveform_layout']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Collection = typing.Collection
Mapping = typing.Mapping
TOP_Y_NORM = 0.045
BOTTOM_Y_NORM = 0.955
SIDE_INSET_NORM = 0.015
FULL_WIDTH_NORM = 0.98
HALF_WIDTH_NORM = 0.46
MIN_WIDTH_NORM = 0.2
MAX_WIDTH_NORM = 0.98
_HEIGHT_NORM = {'visualizer': {'strong': 0.088, 'subtle': 0.052, 'balanced': 0.07}, 'timeline': {'strong': 0.072, 'subtle': 0.04, 'balanced': 0.054}}
_RADIAL_STYLES = frozenset({'radial_spectrum', 'radial_orbit', 'radial_invert'})
_RADIAL_HEIGHT_NORM = 0.22
_RESOLUTION_SHORT_EDGE = {'720p': 720, '1080p': 1080, '4k': 2160, '2160p': 2160}
_RESERVED_BOTTOM_CLEAR_Y = 0.72
_RESERVED_TOP_CLEAR_Y = 0.22
__all__ = ['BOTTOM_Y_NORM', 'FULL_WIDTH_NORM', 'HALF_WIDTH_NORM', 'SIDE_INSET_NORM', 'TOP_Y_NORM', 'canvas_size_for_aspect', 'layouts_share_norms', 'normalize_aspect_ratio', 'relocate_reserved_position', 'resol... [truncated]

# --- Top-Level Functions ---
def normalize_aspect_ratio(value: 'str') -> 'str':
    pass

def canvas_size_for_aspect(aspect_ratio: 'str', *, resolution_name: 'str' = '1080p') -> 'tuple[int, int]':
    pass

def relocate_reserved_position(position: 'str', reserved_edges: 'Collection[str]') -> 'str':
    pass

def resolve_auto_length(length: 'str', seed: 'int') -> 'str':
    pass

def resolve_auto_position(position: 'str', length: 'str', seed: 'int', reserved_edges: 'Collection[str]' = ()) -> 'str':
    pass

def _clamp(value: 'float', low: 'float', high: 'float') -> 'float':
    pass

def _mode_for_style(style: 'str', requested_mode: 'str' = '') -> 'str':
    pass

def _keep_off_reserved_lane(x_norm: 'float', y_norm: 'float', height_norm: 'float', position: 'str', reserved_edges: 'Collection[str]') -> 'tuple[float, float, str]':
    pass

def resolve_waveform_layout(variant: 'Mapping[str, Any] | None', *, width: 'int', height: 'int', reserved_edges: 'Collection[str]' = (), safe_bounds: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
    pass

def layouts_share_norms(left: 'Mapping[str, Any]', right: 'Mapping[str, Any]') -> 'bool':
    pass
