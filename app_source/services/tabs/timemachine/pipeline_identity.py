"""
Decompiled / Reconstructed Module: services.tabs.timemachine.pipeline_identity
Source PyC: pipeline_identity.pyc

Docstring:
Time Machine dual-pipeline identity: construction vs live-window.

Construction keeps official Veo first+last on a reverse-peeled still ladder.
Live-window is the last-frame START chain. Cinematic 1-image is reserved and
must not be selected by current jobs.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
OUTPUT_IMAGES_NARRATION = 'images_narration'
I2V_FRAME_AUTO = 'auto'
I2V_FRAME_START_END = 'start_end'
I2V_FRAME_START_ONLY = 'start_only'
I2V_FRAME_MODES = {'start_end', 'auto', 'start_only'}
I2V_FRAME_LABELS = {'auto': 'AUTO', 'start_end': 'START–END', 'start_only': '1 ẢNH'}
PIPELINE_CONSTRUCTION = 'construction'
PIPELINE_LIVE_WINDOW = 'live_window'
PIPELINE_CINEMATIC = 'cinematic'
PIPELINE_KINDS = {'construction', 'live_window'}
PIPELINE_LABELS = {'construction': 'XÂY DỰNG · START–END', 'live_window': 'CỬA SỔ LỊCH SỬ · LIVE CHAIN'}
PIPELINE_HINTS = {'construction': 'Reverse peel · mỗi clip nội suy START–END đã khóa', 'live_window': 'Last frame thật làm START · một END mới mỗi clip'}
CONSTRUCTION_PROCESS_LABELS = ('Timeline', 'Storyboard', 'Peel START–END', 'I2V Start–End', 'Picture-lock', 'Voice + Graphics', 'Hoàn tất')
LIVE_WINDOW_PROCESS_LABELS = ('Timeline', 'Storyboard', 'Seed START–END', 'Live Chain', 'Picture-lock', 'Voice + Graphics', 'Hoàn tất')

# --- Top-Level Functions ---
def normalize_i2v_frame_mode(value: 'Any') -> 'str':
    pass

def resolve_i2v_frame_mode_for_plan(plan: 'Mapping[str, Any] | None', config: 'Mapping[str, Any] | None' = None) -> 'str':
    pass

def is_start_only_i2v(config: 'Mapping[str, Any] | None') -> 'bool':
    pass

def pipeline_kind_for_plan(plan: 'Mapping[str, Any] | None') -> 'str':
    pass

def pipeline_projection(plan: 'Mapping[str, Any] | None', output_kind: 'Any' = '', i2v_frame_mode: 'Any' = '') -> 'dict[str, Any]':
    pass
