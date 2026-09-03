"""
Decompiled / Reconstructed Module: services.tabs.timemachine.output_router
Source PyC: output_router.pyc

Docstring:
Time Machine Auto/manual output routing.

`output_mode` is the user request (auto | image | video), matching Clone /
Transcript. `output_kind` is the resolved pipeline switch (video |
images_narration). `i2v_frame_mode` is auto | start_end | start_only.

Explicit user locks always win. Auto asks a small JSON classify; if the
provider is missing or garbled, a keyword/template heuristic is used. A
missing classify never routes to image — video is the safe default.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
I2V_FRAME_AUTO = 'auto'
I2V_FRAME_START_END = 'start_end'
I2V_FRAME_START_ONLY = 'start_only'
OUTPUT_IMAGES_NARRATION = 'images_narration'
OUTPUT_VIDEO = 'video'
OUTPUT_MODE_AUTO = 'auto'
OUTPUT_MODE_IMAGE = 'image'
OUTPUT_MODE_VIDEO = 'video'
OUTPUT_MODES = {'auto', 'image', 'video'}
OUTPUT_ROUTE_SCHEMA = {'type': 'object', 'properties': {'output_mode': {'type': 'string', 'enum': ['image', 'video']}, 'i2v_frame_mode': {'type': 'string', 'enum': ['start_end', 'start_only']}, 'reason': {'type': 'string'}... [truncated]
_IMAGE_NEEDLES = ('bộ ảnh', 'bo anh', 'slideshow', 'photo essay', 'ảnh tĩnh', 'anh tinh', 'catalog', 'poster', 'minh họa', 'minh hoa', 'images + narration', 'ảnh + lời', 'anh + loi', 'still series', 'picture book')
_VIDEO_NEEDLES = ('video', 'timelapse', 'time-lapse', 'time lapse', 'xem quá trình', 'xem qua trinh', 'chuyển động', 'chuyen dong', 'watch the process', 'motion')
_START_END_NEEDLES = ('chế tạo', 'che tao', 'lắp ráp', 'lap rap', 'xây dựng', 'xay dung', 'xây', 'peel', 'lắp đặt', 'lap dat', 'making', 'assembly', 'construction', 'phục chế', 'phuc che', 'restoration', 'restore', 'sáng ... [truncated]
_START_ONLY_NEEDLES = ('lịch sử', 'lich su', 'history', 'thế kỷ', 'the ky', 'century', 'thành phố', 'thanh pho', 'city', 'evolution', 'theo thời gian', 'theo thoi gian', '100000', '100.000', '100,000', 'năm trước', 'nam tr... [truncated]
_START_END_TEMPLATES = {'making', 'creative', 'construction', 'restoration'}
_START_ONLY_TEMPLATES = {'growth', 'kids_story'}
_SYSTEM_BRIEF = 'You route a Time Machine job. Time Machine turns an idea into a\nlocked still ladder, then either Veo video or a still+narration slideshow.\n\nOUTPUT FAMILIES\n- video: Veo interpolates the stills. U... [truncated]

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def normalize_output_mode(value: 'Any') -> 'str':
    pass

def output_kind_for_mode(mode: 'Any') -> 'str':
    pass

def heuristic_timemachine_output(intent: 'Any', intent_template: 'Any' = 'auto') -> 'dict[str, str]':
    """Deterministic fallback used when Auto has no LLM or the call fails."""
    pass

def classify_timemachine_output(intent: 'Any', intent_template: 'Any' = 'auto', provider: 'Any' = None) -> 'dict[str, str]':
    pass

def _already_resolved(config: 'Mapping[str, Any]') -> 'bool':
    pass

def resolve_output_routing(config: 'Mapping[str, Any] | None', intent: 'Any' = '', intent_template: 'Any' = 'auto', provider: 'Any' = None) -> 'dict[str, Any]':
    pass
