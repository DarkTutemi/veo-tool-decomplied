"""
Decompiled / Reconstructed Module: core.labs_api.flow_ui_bridge
Source PyC: flow_ui_bridge.pyc

Docstring:
core/labs_api/flow_ui_bridge.py — Flow UI state adapter wrappers.

Thin orchestration layer that translates call-site arguments into the data
structures expected by `flow_ui_state_adapter` (hydrate + click Create), then
unpacks the result back for callers. No payload building here — the adapter owns
that by design (the WEBSITE builds the real payload, not us).

Ported verbatim from core/api_client.py (832-1155):
  _derive_flow_model_family_from_key · _flow_ui_video_model_selection
  _flow_edit_url · _flow_scene_url · _flow_scene_create_url
  _first_flow_scene_id · _create_flow_scene_via_browser
  call_flow_video_create_via_ui · _call_flow_edit_extend_via_ui
  _call_flow_edit_upscale_via_ui · call_flow_image_upscale_via_ui
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional

# --- Top-Level Functions ---
def flow_ui_native_enabled() -> 'bool':
    pass

def derive_flow_model_family(model_key: 'str') -> 'str':
    pass

def flow_ui_video_model_selection(model_key: 'str', *, video_api: 'str', default_duration_seconds: 'int' = 8) -> 'Dict[str, Any]':
    pass

def flow_edit_url(project_id: 'str', workflow_id: 'str') -> 'str':
    pass

def flow_scene_url(project_id: 'str', scene_id: 'str') -> 'str':
    pass

def flow_scene_create_url(project_id: 'str') -> 'str':
    pass

def _first_flow_scene_id(data: 'Dict[str, Any]') -> 'str':
    pass

def create_flow_scene_via_browser(*, project_id: 'str', workflow_id: 'str', account_id: 'str', timeout_ms: 'int' = 60000) -> 'str':
    pass

def _unpack_flow_ui_result(ui_result: 'Optional[Dict[str, Any]]', *, flow_ui: 'Dict[str, Any]', error_default: 'str') -> 'Dict[str, Any]':
    pass

def call_flow_video_create_via_ui(*, prompt: 'str', project_id: 'str', aspect_ratio: 'str' = 'LANDSCAPE', model_family: 'str' = 'abra', video_model_key: 'str' = '', video_api: 'str' = '', duration_seconds: 'int' = 10, outputs_per_prompt: 'int' = 1, mode: 'str' = 'VIDEO_REFERENCES', reference_images: 'Optional[List[Dict[str, Any]]]' = None, character_references: 'Optional[List[Dict[str, Any]]]' = None, account_name: 'Optional[str]' = None, account_email: 'Optional[str]' = None, timeout_ms: 'int' = 120000) -> 'Dict[str, Any]':
    pass

def call_flow_edit_extend_via_ui(*, prompt: 'str', project_id: 'str', workflow_id: 'str', media_id: 'str', scene_id: 'Optional[str]' = None, account_name: 'Optional[str]', account_email: 'Optional[str]', timeout_ms: 'int' = 120000) -> 'Dict[str, Any]':
    pass

def call_flow_edit_upscale_via_ui(*, project_id: 'str', workflow_id: 'str', media_id: 'str', resolution: 'str', media_type: 'str' = 'video', account_name: 'Optional[str]', account_email: 'Optional[str]', timeout_ms: 'int' = 120000) -> 'Dict[str, Any]':
    pass

def call_flow_image_upscale_via_ui(*, media_id: 'str', project_id: 'str', workflow_id: 'str', resolution: 'str' = '2k', account_name: 'Optional[str]' = None, account_email: 'Optional[str]' = None, timeout_ms: 'int' = 120000) -> 'Dict[str, Any]':
    pass
