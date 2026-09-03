"""
Decompiled / Reconstructed Module: core.captcha.labs.request_js
Source PyC: request_js.pyc

Docstring:
JavaScript builders for Google Labs calls executed inside browser context.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
RECAPTCHA_WEBSITE_KEY = '6LdsFiUsAAAAAIjVDZcuLhaHiDn5nnHVXVRQGeMV'
LABS_API_KEY = 'AIzaSyBtrm0o5ab1c-Ec8ZuLcGt3oJAA5VWt3pY'
STRING_VALUE_TYPE = 'type.googleapis.com/google.protobuf.StringValue'

# --- Top-Level Functions ---
def _env_bool(name: 'str', default: 'bool' = False) -> 'bool':
    pass

def frontend_event_preflight_enabled() -> 'bool':
    pass

def iframe_mint_enabled() -> 'bool':
    pass

def frontend_event_native_logger_enabled() -> 'bool':
    pass

def frontend_event_preflight_delay_ms() -> 'int':
    pass

def frontend_event_native_builder_enabled() -> 'bool':
    pass

def _string_param(value: 'Any') -> 'dict[str, str]':
    pass

def _first_request(payload: 'dict[str, Any]') -> 'dict[str, Any]':
    pass

def _api_pathname(url: 'str') -> 'str':
    pass

def _media_type(url: 'str', request: 'dict[str, Any]') -> 'str':
    pass

def _is_audio_generation_request(url: 'str', request: 'dict[str, Any]') -> 'bool':
    pass

def _clean_aspect_ratio(value: 'Any', default: 'str' = 'LANDSCAPE') -> 'str':
    pass

def _prompt_text(request: 'dict[str, Any]') -> 'str':
    pass

def _structured_prompt(request: 'dict[str, Any]') -> 'dict[str, Any]':
    pass

def _model_key(request: 'dict[str, Any]') -> 'str':
    pass

def _outputs_per_prompt(payload: 'dict[str, Any]', request: 'dict[str, Any]') -> 'int':
    pass

def _media_id(item: 'Any') -> 'str':
    pass

def _reference_images_from_image_inputs(request: 'dict[str, Any]') -> 'list[dict[str, Any]]':
    pass

def _reference_images(request: 'dict[str, Any]') -> 'list[dict[str, Any]]':
    pass

def _reference_audio_ids(request: 'dict[str, Any]') -> 'list[str]':
    pass

def _image_ref_event_params(source: 'str', tier: 'str') -> 'dict[str, dict[str, str]]':
    pass

def _frontend_event(event_type: 'str', session_id: 'str', params: 'dict[str, Any]') -> 'dict[str, Any]':
    pass

def _app_event(event: 'str', session_id: 'str', properties: 'list[dict[str, Any]]') -> 'dict[str, Any]':
    pass

def _native_event_from_frontend_event(event: 'dict[str, Any]') -> 'dict[str, Any]':
    pass

def _voice_customization_event_params(status: 'str', *, tier: 'str', model_key: 'str') -> 'dict[str, dict[str, str]]':
    pass

def _voice_customization_app_properties(status: 'str', *, tier: 'str', model_key: 'str') -> 'list[dict[str, str]]':
    pass

def build_media_generation_settings(url: 'str', payload: 'dict[str, Any]') -> 'dict[str, Any]':
    pass

def build_frontend_event_plan(url: 'str', payload: 'dict[str, Any]') -> 'dict[str, Any]':
    pass

def build_api_js(url: 'str', payload: 'dict[str, Any]', action: 'str', timeout_ms: 'int') -> 'str':
    pass

def build_get_tokens_js(action: 'str', timeout_ms: 'int') -> 'str':
    pass
