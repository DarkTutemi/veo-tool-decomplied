"""
Decompiled / Reconstructed Module: core.video_timing_knowledge
Source PyC: video_timing_knowledge.pyc
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
SUPPORTED_FIXED_CLIP_DURATIONS = (4, 6, 8, 10)
DEFAULT_CLIP_DURATION_SECONDS = 8

# --- Top-Level Functions ---
def normalize_clip_duration(duration_seconds: 'Optional[int]', default: 'int' = 8) -> 'int':
    pass

def smallest_clip_duration_covering(remainder_seconds: 'int', default: 'int' = 8) -> 'int':
    pass

def scene_count_for_target_duration(target_duration_seconds: 'int', clip_duration_seconds: 'int') -> 'int':
    pass

def clip_duration_from_model_key(model_key: 'str', default: 'int' = 8) -> 'int':
    pass

def build_fixed_duration_knowledge(duration_seconds: 'int', *, scene_count: 'int' = 0, available_durations: "'list | None'" = None, adaptive_timeline: 'bool' = False) -> 'str':
    pass

def timeline_window_examples(duration_seconds: 'int') -> 'list[str]':
    pass

def build_shot_plan_duration_rules(duration_seconds: 'int') -> 'str':
    pass

def timestamp_windows_for_duration(duration_seconds: 'int', count: 'int', *, start: 'int' = 0) -> 'list[str]':
    pass

def last_scene_start_for_target_duration(target_duration_seconds: 'int', clip_duration_seconds: 'int') -> 'int':
    pass

def block_scene_duration_line(duration_seconds: 'int', *, same_format: 'bool' = False) -> 'str':
    pass

def _timestamp_examples(duration: 'int', count: 'int') -> 'str':
    pass

def _micro_timing_profile(duration: 'int') -> 'str':
    pass
