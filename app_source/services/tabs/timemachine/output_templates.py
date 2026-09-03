"""
Decompiled / Reconstructed Module: services.tabs.timemachine.output_templates
Source PyC: output_templates.pyc

Docstring:
Named Time Machine output packages (built-in + user store).

A template is a mode package: output family, I2V frame mode, narration, and
image rhythm. Models/style/folder stay on the live config bar. Apply writes
those keys; Auto templates leave routing to `output_router`.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
OUTPUT_MODE_AUTO = 'auto'
OUTPUT_MODE_IMAGE = 'image'
OUTPUT_MODE_VIDEO = 'video'
I2V_FRAME_AUTO = 'auto'
I2V_FRAME_START_END = 'start_end'
I2V_FRAME_START_ONLY = 'start_only'
_TEMPLATE_KEYS = ('output_mode', 'i2v_frame_mode', 'narration_enabled', 'image_rhythm_mode', 'image_rhythm_target', 'native_audio_mode')
BUILTIN_OUTPUT_TEMPLATES = ({'id': 'auto', 'label': 'Auto hệ thống', 'hint': 'LLM chọn Ảnh/Video và 1 ảnh / START–END từ ý tưởng.', 'builtin': True, 'output_mode': 'auto', 'i2v_frame_mode': 'auto', 'narration_enabled': True, 'i... [truncated]

# --- Top-Level Functions ---
def template_snapshot(config: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
    pass

def apply_template_payload(config: 'Mapping[str, Any] | None', template: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
    pass

def builtin_template_rows() -> 'list[dict[str, Any]]':
    pass

def normalize_user_templates(rows: 'Any') -> 'list[dict[str, Any]]':
    pass

def template_option_rows(user_templates: 'Any' = None) -> 'list[dict[str, Any]]':
    pass

def find_template(template_id: 'Any', user_templates: 'Any' = None) -> 'dict[str, Any] | None':
    pass

def make_user_template(name: 'Any', config: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
    pass
