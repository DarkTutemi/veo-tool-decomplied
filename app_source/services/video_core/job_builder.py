"""
Decompiled / Reconstructed Module: services.video_core.job_builder
Source PyC: job_builder.pyc

Docstring:
Shared prompt-data builders for video scene dispatch.

This module is deliberately free of tab-specific UI state. Tabs and old
dispatch code can call these helpers to build a consistent job envelope before
the dispatcher/API layer attaches account-specific media IDs.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Optional = typing.Optional
Tuple = typing.Tuple
EXTEND_STABILITY_RULES = 'Continuous motion from previous scene. Props remain consistent throughout. No new objects appear. No abrupt changes. Background stays stable.'
EXTEND_CAMERA_DEFAULT = 'Same camera angle, framing, and shot size as previous scene. No sudden camera changes.'

# --- Top-Level Functions ---
def build_model_intent(model_key: 'str', aspect_ratio: 'str' = '16:9', duration_seconds: 'int' = None) -> 'dict':
    pass

def build_prompt_data(*, text: 'str', scene_id: 'str', row_number: 'int', file_sequence: 'int', parent_job_id: 'str', parent_job_id_key: 'str' = 'master_prompt_job_id', scene_index: 'int', aspect_ratio: 'str', model: 'str', enable_upscale: 'bool', resolution: 'str', output_folder: 'str', output_count: 'int' = 1, card_mode: 'str' = 'text', payload: 'dict' = None, duration_seconds: 'int' = None) -> 'dict':
    pass

def build_scene_fallback_prompt_data(*, text: 'str', payload: 'Optional[Dict[str, Any]]' = None, tab_source: 'str', scene_id: 'str', row_number: 'int', file_sequence: 'int', parent_job_id: 'str', parent_job_id_key: 'str', scene_index: 'int', aspect_ratio: 'str', model_key: 'str', enable_upscale: 'bool', resolution: 'str', output_folder: 'str', output_count: 'int' = 1, card_mode: 'str' = 'text', duration_seconds: 'Optional[int]' = None) -> 'Dict[str, Any]':
    pass

def build_prompt_data_from_compiled_result(*, compiled: 'Any', scene_id: 'str', row_number: 'int', file_sequence: 'int', parent_job_id: 'str', parent_job_id_key: 'str', scene_index: 'int', aspect_ratio: 'str', model: 'str', enable_upscale: 'bool', resolution: 'str', output_folder: 'str', output_count: 'int' = 1, card_mode: 'str' = 'text', duration_seconds: 'Optional[int]' = None) -> 'Dict[str, Any]':
    """Wrap an already-compiled scene into the standard dispatcher job."""
    pass

def build_queue_prompt_item_from_compiled_result(*, compiled: 'Any', file_sequence: 'int', row_number: 'int', is_auto_regen: 'bool' = True) -> 'Dict[str, Any]':
    """Build the compact prompt item consumed by legacy tab receive_queue_job."""
    pass

def build_visual_timeline_scene(*, scene_id: 'str', prompt_text: 'str', duration_seconds: 'Optional[int]' = None, source_time_range: 'str' = '', content_type: 'str' = 'visual_prompt_scene', visualization_type: 'str' = 'CINEMATIC', entities: 'Optional[Dict[str, Any]]' = None, audio: 'Optional[Dict[str, Any]]' = None, extra_scene_fields: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
    """Adapt a text-only visual instruction into the new timeline scene contract.

    This is not the old asset-library prompt builder. It only creates a valid
    module/timeline scene so callers with visual-only input can still use the
    central compiler."""
    pass

def compile_visual_scene_prompt(*, scene: 'Dict[str, Any]', entity_library: 'Optional[Dict[str, Any]]' = None, anchor_plan: 'Optional[Dict[str, Any]]' = None, policy=None, tab_source: 'str', model_key: 'str', aspect_ratio: 'str', duration_seconds: 'Optional[int]' = None, style_override: 'str' = '', camera_override: 'str' = '', character_metadata: 'Optional[Dict[str, Dict[str, Any]]]' = None, enable_char_consistency: 'bool' = False, enable_anchor_consistency: 'bool' = False, enable_flow_voice_lock: 'bool' = False, total_ref_limit: 'Optional[int]' = None, character_ref_limit: 'Optional[int]' = None, identity_scope: 'str' = '', content_type: 'str' = 'visual_prompt_scene', visualization_type: 'str' = 'CINEMATIC') -> 'Any':
    pass

def compile_scene_prompt_data(*, scene: 'Dict[str, Any]', entity_library: 'Optional[Dict[str, Any]]' = None, anchor_plan: 'Optional[Dict[str, Any]]' = None, policy=None, tab_source: 'str', model_key: 'str', aspect_ratio: 'str', duration_seconds: 'Optional[int]' = None, style_override: 'str' = '', camera_override: 'str' = '', character_metadata: 'Optional[Dict[str, Dict[str, Any]]]' = None, enable_char_consistency: 'bool' = False, enable_anchor_consistency: 'bool' = False, enable_flow_voice_lock: 'bool' = False, total_ref_limit: 'Optional[int]' = None, character_ref_limit: 'Optional[int]' = None, identity_scope: 'str' = '', scene_id: 'str', row_number: 'int', file_sequence: 'int', parent_job_id: 'str', parent_job_id_key: 'str', scene_index: 'int', enable_upscale: 'bool', resolution: 'str', output_folder: 'str', output_count: 'int' = 1, card_mode: 'str' = 'text') -> 'Tuple[Dict[str, Any], Any]':
    pass

def compile_visual_scene_prompt_data(*, scene: 'Dict[str, Any]', entity_library: 'Optional[Dict[str, Any]]' = None, anchor_plan: 'Optional[Dict[str, Any]]' = None, policy=None, tab_source: 'str', model_key: 'str', aspect_ratio: 'str', duration_seconds: 'Optional[int]' = None, style_override: 'str' = '', camera_override: 'str' = '', character_metadata: 'Optional[Dict[str, Dict[str, Any]]]' = None, enable_char_consistency: 'bool' = False, enable_anchor_consistency: 'bool' = False, enable_flow_voice_lock: 'bool' = False, total_ref_limit: 'Optional[int]' = None, character_ref_limit: 'Optional[int]' = None, identity_scope: 'str' = '', content_type: 'str' = 'visual_prompt_scene', visualization_type: 'str' = 'CINEMATIC', scene_id: 'str', row_number: 'int', file_sequence: 'int', parent_job_id: 'str', parent_job_id_key: 'str', scene_index: 'int', enable_upscale: 'bool', resolution: 'str', output_folder: 'str', output_count: 'int' = 1, card_mode: 'str' = 'text') -> 'Tuple[Dict[str, Any], Any]':
    pass
