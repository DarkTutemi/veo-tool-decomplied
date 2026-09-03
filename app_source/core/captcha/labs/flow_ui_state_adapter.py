"""
Decompiled / Reconstructed Module: core.captcha.labs.flow_ui_state_adapter
Source PyC: flow_ui_state_adapter.pyc

Docstring:
Flow UI state adapter for browser-native video generation.

This path intentionally avoids replaying reCAPTCHA or telemetry by hand. It
hydrates the Flow prompt box through the app's own state store, then clicks the
real Create button so the browser runtime performs the normal submit sequence.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
Optional = typing.Optional
FLOW_GENERATE_URL_MARKER = 'aisandbox-pa.googleapis.com/v1/video:batchAsyncGenerate'
FLOW_EXTEND_URL_MARKER = 'aisandbox-pa.googleapis.com/v1/video:batchAsyncGenerateVideoExtendVideo'
FLOW_UPSCALE_URL_MARKER = 'aisandbox-pa.googleapis.com/v1/video:batchAsyncGenerateVideoUpsampleVideo'
FLOW_IMAGE_UPSCALE_URL_MARKER = 'aisandbox-pa.googleapis.com/v1/flow/upsampleImage'
FLOW_IMAGE_GENERATE_URL_MARKER = 'flowMedia:batchGenerateImages'
FLOW_FRONTEND_EVENT_URL = 'aisandbox-pa.googleapis.com/v1/flow:batchLogFrontendEvents'
FLOW_SCENE_PAGE_BASE = 'https://labs.google/fx/tools/flow/project'
REFERENCE_IMAGE_SOURCES = {'SCENE_BUILDER', 'REUSE_PROMPT', 'DRAG_AND_DROP', 'PLUS_BUTTON', 'ANIMATE_IMAGE', 'CONTEXT_MENU', 'EDIT_HISTORY', 'IMAGE_MOBILE_TILE', 'VIDEO_TILE_REFERENCE', 'TAG'}
HYDRATE_FLOW_UI_SCRIPT = '\n(payload) => {\n  const locateStore = () => {\n    if (window.__flowPromptBoxStore?.getState) return window.__flowPromptBoxStore;\n    const nodes = Array.from(document.querySelectorAll("*"));\n   ... [truncated]
_APP_READY_AFTER_RELOAD_JS = '\n() => {\n  const grecaptchaReady = typeof window.grecaptcha?.enterprise?.execute === "function";\n  if (!grecaptchaReady) return false;\n  if (window.__flowPromptBoxStore?.getState) return true;\n ... [truncated]
_CREATE_ENABLED_JS = "\n() => {\n  const btn = Array.from(document.querySelectorAll('button')).find(\n    (b) => /arrow_forward/.test(b.textContent || '') && /Create/.test(b.textContent || '')\n  );\n  return !!btn && !bt... [truncated]
_CLICK_CREATE_JS = "\n() => {\n  const btn = Array.from(document.querySelectorAll('button')).find(\n    (b) => /arrow_forward/.test(b.textContent || '') && /Create/.test(b.textContent || '')\n  );\n  if (!btn) return { ... [truncated]
_CREATE_DISABLED_DIAG_JS = '\n() => {\n  const out = { recaptcha_challenge: false, recaptcha_badge: false, store: false,\n                missing_actions: null, mode: null, model: null, ingredients: null,\n                promp... [truncated]
OPEN_FLOW_SCENE_EXTEND_MODE_SCRIPT = '\nasync () => {\n  const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));\n  const visible = (el) => {\n    const rect = el.getBoundingClientRect?.();\n    if (!rect || rect.width <... [truncated]
SET_FLOW_SCENE_EXTEND_PROMPT_SCRIPT = '\n({prompt}) => {\n  const keysOf = (el) => Array.from(new Set([...Object.keys(el), ...Object.getOwnPropertyNames(el)]));\n  const locateStore = () => {\n    if (window.__flowPromptBoxStore?.getState... [truncated]
CLICK_FLOW_SCENE_CREATE_SCRIPT = '\n() => {\n  const visible = (el) => {\n    const rect = el.getBoundingClientRect?.();\n    if (!rect || rect.width < 6 || rect.height < 6) return false;\n    const style = window.getComputedStyle(el... [truncated]
CLICK_FLOW_VIDEO_UPSCALE_REACT_MENU_SCRIPT = '\nasync ({workflowId, resolution}) => {\n  const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));\n  const visible = (el) => {\n    const rect = el.getBoundingClientRect?.();\n    c... [truncated]
HYDRATE_FLOW_UI_IMAGE_SCRIPT = '\nasync (payload) => {\n  const locateStore = () => {\n    if (window.__flowPromptBoxStore?.getState) return window.__flowPromptBoxStore;\n    for (const el of Array.from(document.querySelectorAll("*... [truncated]

# --- Class: FlowReferenceImage ---
class FlowReferenceImage:
    """Reference image to inject into Flow's prompt composer."""
    source = 'IMAGE_MOBILE_TILE'
    preferred_ingredient_type = 'REFERENCE'

    def __init__(self, image_id: 'str', source: 'str' = 'IMAGE_MOBILE_TILE', preferred_ingredient_type: 'str' = 'REFERENCE') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: FlowCharacterReference ---
class FlowCharacterReference:
    """Character/entity reference to inject into Flow's prompt composer."""
    source = 'TAG'
    preferred_ingredient_type = 'REFERENCE'

    def __init__(self, character_server_id: 'str', source: 'str' = 'TAG', preferred_ingredient_type: 'str' = 'REFERENCE') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: FlowUiVideoRequest ---
class FlowUiVideoRequest:
    """Normalized request for UI-driven Flow video generation."""
    project_id = ''
    aspect_ratio = 'LANDSCAPE'
    model_family = 'abra'
    video_model_key = ''
    video_api = ''
    duration_seconds = 10
    outputs_per_prompt = 1
    mode = 'VIDEO_REFERENCES'

    def __init__(self, prompt: 'str', project_id: 'str' = '', aspect_ratio: 'str' = 'LANDSCAPE', model_family: 'str' = 'abra', video_model_key: 'str' = '', video_api: 'str' = '', duration_seconds: 'int' = 10, outputs_per_prompt: 'int' = 1, mode: 'str' = 'VIDEO_REFERENCES', reference_images: 'List[FlowReferenceImage]' = <factory>, character_references: 'List[FlowCharacterReference]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: FlowUiImageRequest ---
class FlowUiImageRequest:
    """Normalized request for UI-driven Flow image generation."""
    project_id = ''
    image_model_name = ''
    image_model_family = ''
    image_aspect_ratio = 'LANDSCAPE'
    outputs_per_prompt = 1

    def __init__(self, prompt: 'str', project_id: 'str' = '', image_model_name: 'str' = '', image_model_family: 'str' = '', image_aspect_ratio: 'str' = 'LANDSCAPE', outputs_per_prompt: 'int' = 1, reference_images: 'List[FlowReferenceImage]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: FlowEditExtendRequest ---
class FlowEditExtendRequest:
    """Extend draft for Flow's edit/scene page."""
    scene_id = ''
    scene_url = ''
    project_id = ''
    workflow_id = ''
    source_media_id = ''
    edit_url = ''

    def __init__(self, prompt: 'str', scene_id: 'str' = '', scene_url: 'str' = '', project_id: 'str' = '', workflow_id: 'str' = '', source_media_id: 'str' = '', edit_url: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: FlowEditUpscaleRequest ---
class FlowEditUpscaleRequest:
    """Upscale draft for Flow's edit/scene page."""
    edit_url = ''
    project_id = ''
    workflow_id = ''
    source_media_id = ''
    resolution = '1080p'
    media_type = 'video'
    click_name_pattern = ''

    def __init__(self, edit_url: 'str' = '', project_id: 'str' = '', workflow_id: 'str' = '', source_media_id: 'str' = '', resolution: 'str' = '1080p', media_type: 'str' = 'video', click_name_pattern: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: FlowEntityNotInProjectError ---
class FlowEntityNotInProjectError(RuntimeError):
    """A requested character/entity was rejected by the page's entity registry.

    Flow's prompt-box `addCharacterIngredient` validates `characterServerId`
    against `projectContents.entities`, a snapshot loaded at page navigation.
    An entity created server-side (httpx tRPC) AFTER the page was loaded is not
    in that snapshot, so the ingredient is silently dropped (no error, no
    network). Verified live 2026-06-10: the validator is a synchronous local
    cache lookup. Reloading the page refetches the snapshot and recovers it."""
    pass


# --- Top-Level Functions ---
def _flow_aspect(value: 'str') -> 'str':
    pass

def _clamp_outputs(value: 'int') -> 'int':
    pass

def _server_image_id(value: 'str') -> 'str':
    pass

def _normalize_source(value: 'str') -> 'str':
    pass

def normalize_ui_video_request(data: 'FlowUiVideoRequest | Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _flow_scene_url(project_id: 'str', scene_id: 'str') -> 'str':
    pass

def normalize_edit_extend_request(data: 'FlowEditExtendRequest | Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def normalize_edit_upscale_request(data: 'FlowEditUpscaleRequest | Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def build_store_plan(payload: 'Dict[str, Any]') -> 'List[Dict[str, Any]]':
    """Render a normalized request payload → the ORDERED list of store commands that
    ``HYDRATE_FLOW_UI_SCRIPT`` issues in the browser. Pure + side-effect-free, so the
    intent→store conversion is inspectable and unit-testable WITHOUT a browser.

    Mirrors the script's action sequence exactly (keep in sync with HYDRATE_FLOW_UI_SCRIPT).
    Each item is ``{"action": <store action>, "args": <value/dict or None>}``. ``imageId`` is
    the value passed to the in-browser ``resolveImageId`` (server media id / fe_id), not the
    post-resolution id."""
    pass

def _expected_character_count(payload: 'Dict[str, Any]') -> 'int':
    pass

def _hydrated_character_server_ids(state: 'Dict[str, Any]') -> 'List[str]':
    pass

def hydrate_flow_ui(page: 'Any', request: 'FlowUiVideoRequest | Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _validate_hydrated_state(state: 'Dict[str, Any]', *, expected_character_count: 'int' = 0) -> 'Dict[str, Any]':
    pass

def hydrate_flow_ui_async(page: 'Any', request: 'FlowUiVideoRequest | Dict[str, Any]') -> 'Dict[str, Any]':
    """Hydrate Flow prompt box state on an async Playwright page."""
    pass

def _reload_for_entity_refetch(page: 'Any', timeout_ms: 'int' = 30000) -> 'None':
    pass

def _reload_for_entity_refetch_async(page: 'Any', timeout_ms: 'int' = 30000) -> 'None':
    pass

def hydrate_flow_ui_with_entity_recovery(page: 'Any', request: 'FlowUiVideoRequest | Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def hydrate_flow_ui_with_entity_recovery_async(page: 'Any', request: 'FlowUiVideoRequest | Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _safe_json_response(response: 'Any') -> 'Dict[str, Any]':
    pass

def _request_json(response: 'Any') -> 'Dict[str, Any]':
    pass

def _post_data_json(request: 'Any') -> 'Dict[str, Any]':
    pass

def _sanitize_request_payload(payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _safe_json_response_async(response: 'Any') -> 'Dict[str, Any]':
    pass

def _request_json_any(response: 'Any') -> 'Dict[str, Any]':
    pass

def _first_workflow_id(body: 'Dict[str, Any]') -> 'str':
    pass

def _first_media_id(body: 'Dict[str, Any]') -> 'str':
    pass

def _flow_create_response_has_job(body: 'Dict[str, Any]') -> 'bool':
    pass

def _flow_upscale_response_has_result(body: 'Dict[str, Any]') -> 'bool':
    pass

def _is_flow_extend_url(url: 'str') -> 'bool':
    pass

def _first_scene_id(body: 'Dict[str, Any]') -> 'str':
    pass

def _first_request_item(request_payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _video_input_media_id(request_item: 'Dict[str, Any]') -> 'str':
    pass

def _click_create(page: 'Any', timeout_ms: 'int' = 20000) -> 'None':
    pass

def _click_create_async(page: 'Any', timeout_ms: 'int' = 20000) -> 'None':
    pass

def _entity_pending_result(exc: 'FlowEntityNotInProjectError') -> 'Dict[str, Any]':
    pass

def submit_flow_ui_video(page: 'Any', request: 'FlowUiVideoRequest | Dict[str, Any]', *, timeout_ms: 'int' = 120000, frontend_event_timeout_ms: 'int' = 45000) -> 'Dict[str, Any]':
    pass

def _navigate_if_needed(page: 'Any', url: 'str', timeout_ms: 'int') -> 'None':
    pass

def _cancel_downloads(page: 'Any') -> 'Dict[str, Any]':
    pass

def submit_flow_ui_video_async(page: 'Any', request: 'FlowUiVideoRequest | Dict[str, Any]', *, timeout_ms: 'int' = 120000, frontend_event_timeout_ms: 'int' = 45000) -> 'Dict[str, Any]':
    """Hydrate a Flow draft on an async page and click the real Create button."""
    pass

def _open_scene_extend_mode(page: 'Any') -> 'Dict[str, Any]':
    pass

def _set_scene_extend_prompt(page: 'Any', prompt: 'str') -> 'Dict[str, Any]':
    pass

def _click_scene_create(page: 'Any') -> 'Dict[str, Any]':
    pass

def _optional_frontend_event(event_info: 'Any') -> 'Optional[Any]':
    pass

def _image_aspect(value: 'str') -> 'str':
    pass

def normalize_ui_image_request(data: 'FlowUiImageRequest | Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def hydrate_flow_ui_image_async(page: 'Any', request: 'FlowUiImageRequest | Dict[str, Any]') -> 'Dict[str, Any]':
    """Hydrate Flow prompt box cho image generation (async page)."""
    pass

def _click_create_real_async(page: 'Any', timeout_ms: 'int' = 20000) -> 'None':
    pass

def submit_flow_ui_image_async(page: 'Any', request: 'FlowUiImageRequest | Dict[str, Any]', *, timeout_ms: 'int' = 120000, frontend_event_timeout_ms: 'int' = 45000) -> 'Dict[str, Any]':
    """Hydrate image draft + click nút Create thật → bắt POST flowMedia:batchGenerateImages."""
    pass

def submit_flow_scene_extend_async(page: 'Any', request: 'FlowEditExtendRequest | Dict[str, Any]', *, timeout_ms: 'int' = 120000, frontend_event_timeout_ms: 'int' = 45000) -> 'Dict[str, Any]':
    """Submit an Extend job through Flow's scene page.

    The scene page path is the browser-native Flow path observed for real
    Extend: Add Clip -> Extend (Veo 3.1 - Lite) -> prompt store -> Create."""
    pass

def submit_flow_edit_extend_async(page: 'Any', request: 'FlowEditExtendRequest | Dict[str, Any]', *, timeout_ms: 'int' = 120000, frontend_event_timeout_ms: 'int' = 45000) -> 'Dict[str, Any]':
    """Submit an Extend job. Live callers (V1 legacy + V2 bridge) luôn tạo scene id
    trước, nên luôn đi scene-page (JS) path. Nhánh edit-page DOM-walk cũ đã gỡ vì
    dead code (không caller nào tới được — extend luôn có sceneId/sceneUrl)."""
    pass

def _click_upscale_action(page: 'Any', payload: 'Dict[str, Any]') -> 'None':
    pass

def submit_flow_edit_upscale_async(page: 'Any', request: 'FlowEditUpscaleRequest | Dict[str, Any]', *, timeout_ms: 'int' = 120000, frontend_event_timeout_ms: 'int' = 45000) -> 'Dict[str, Any]':
    """Submit an upscale job through Flow UI and capture the browser-built request."""
    pass
