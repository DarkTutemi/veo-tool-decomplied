"""
Decompiled / Reconstructed Module: services.tabs.timemachine.still_slideshow
Source PyC: still_slideshow.pyc

Docstring:
Image+narration Time Machine output: stills become the picture-lock.

Video mode interpolates START–END with Veo. This mode skips I2V, exports the
story stills, and encodes a silent still-hold clip per plate so the existing
narration / TGS / mux pipeline can run against a measured timeline.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Mapping = typing.Mapping
Sequence = typing.Sequence
OUTPUT_VIDEO = 'video'
OUTPUT_IMAGES_NARRATION = 'images_narration'
OUTPUT_KINDS = {'video', 'images_narration'}
OUTPUT_LABELS = {'video': 'VIDEO', 'images_narration': 'ẢNH'}
DEFAULT_STILL_HOLD_S = 4.0
MIN_STILL_HOLD_S = 3.0
MAX_STILL_HOLD_S = 8.0
STILL_FPS = 24

# --- Top-Level Functions ---
def normalize_output_kind(value: 'Any') -> 'str':
    pass

def is_images_narration(config: 'Mapping[str, Any] | None') -> 'bool':
    pass

def output_label_for_kind(kind: 'Any') -> 'str':
    pass

def still_frame_size(aspect: 'Any', quality: 'Any' = '720p') -> 'tuple[int, int]':
    pass

def still_hold_seconds(plan: 'Mapping[str, Any] | None', still_count: 'int') -> 'float':
    pass

def collect_story_stills(plan: 'Mapping[str, Any] | None') -> 'list[dict[str, Any]]':
    pass

def export_story_stills(stills: 'Sequence[Mapping[str, Any]]', stills_dir: 'str | Path') -> 'list[dict[str, Any]]':
    pass

def render_still_hold_clip(image_path: 'str', output_path: 'str', duration_s: 'float', width: 'int', height: 'int', ffmpeg: 'str' = '', runner: 'Callable[..., Any] | None' = None) -> 'dict[str, Any]':
    pass

def build_still_slideshow_clips(plan: 'Mapping[str, Any]', clips_dir: 'str | Path', stills_dir: 'str | Path', aspect: 'Any' = '16:9', quality: 'Any' = '720p', ffmpeg: 'str' = '', runner: 'Callable[..., Any] | None' = None) -> 'dict[str, Any]':
    pass

def build_still_merge_plan(clips: 'Sequence[Mapping[str, Any]]', xfade_s: 'float' = 0.4) -> 'dict[str, Any]':
    pass
