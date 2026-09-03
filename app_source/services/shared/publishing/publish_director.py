"""
Decompiled / Reconstructed Module: services.shared.publishing.publish_director
Source PyC: publish_director.pyc

Docstring:
Final-stage publishing director shared by every video route.

The analyzer/architect produces a useful draft while it still understands the
story.  This module runs after the assets/video exist, enriches that draft with
the real production result, asks the LLM to put its strongest complete thumbnail
prompt first, and sends that prompt directly to the image model. It deliberately
does not score, inspect or rerank the finished image, does not own route-specific
orchestration, and never draws typography locally.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['build_publish_context', 'collect_publish_references', 'direct_publish_package', 'finalize_publish_package', 'snapshot_publish_data']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
Mapping = typing.Mapping
PUBLISH_JSON_FILENAME = 'publish_kit.json'
PUBLISH_STATUS_FILENAME = 'publish_kit_status.json'
THUMBNAIL_BASENAME = 'thumbnail'
_WORK_DIRNAME = '.publish_kit_work'
_MAX_CONTEXT_CHARS = 750000
_MAX_REFERENCES = 3
_EXPLICIT_SOURCE_REFERENCE_ID = 'SOURCE_IMAGE'
_DIRECT_RENDER_MODE = 'image_model_llm_prompt_direct'
_DIRECTOR_SEMANTIC_ATTEMPTS = 2
_DROP_KEYS = {'authorization', 'blob', 'refresh_token', 'cookie', 'audio_base64', 'thumbnail_base64', 'bytes', 'base64_data', 'raw_audio', 'access_token', 'base64', 'cookies', 'image_base64'}
_CONTEXT_KEYS = ('route', 'mode', 'title', 'topic', 'language', 'language_name', 'market', 'platform', 'aspect_ratio', 'output_aspect_ratio', 'video_aspect_ratio', 'style', 'visual_style', 'selected_style', 'selected... [truncated]
__all__ = ['build_publish_context', 'collect_publish_references', 'direct_publish_package', 'finalize_publish_package', 'snapshot_publish_data']

# --- Top-Level Functions ---
def normalize_publish_aspect_ratio(value: 'Any', default: 'str' = '') -> 'str':
    pass

def resolve_publish_aspect_ratio(data: 'Any', explicit_ratio: 'Any' = '') -> 'str':
    pass

def resolve_publish_style_hint(data: 'Any', explicit_hint: 'str' = '') -> 'str':
    pass

def _text(value: 'Any') -> 'str':
    pass

def _audience_text(package: 'Mapping[str, Any]') -> 'str':
    pass

def _dominant_script(text: 'str') -> 'str':
    pass

def _unexpected_script_switch(draft: 'Mapping[str, Any]', directed: 'Mapping[str, Any]') -> 'bool':
    pass

def _json_safe(value: 'Any', *, depth: 'int' = 0) -> 'Any':
    """Copy useful planning data without credentials or giant inline payloads."""
    pass

def snapshot_publish_data(data: 'Any') -> 'Any':
    pass

def build_publish_context(data: 'Any', *, seed_text: 'str' = '') -> 'Dict[str, Any]':
    """Build a bounded, JSON-safe final-production dossier for the director."""
    pass

def _parse_json_response(raw: 'Any') -> 'Dict[str, Any]':
    pass

def _complete_package(raw: 'Any', draft: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def _primary_thumbnail_prompt(package: 'Mapping[str, Any]') -> 'str':
    pass

def direct_publish_package(data: 'Any', *, seed_text: 'str' = '', language_hint: 'str' = '', style_hint: 'str' = '', aspect_ratio: 'str' = '') -> 'Dict[str, Any]':
    pass

def _file_uri_to_path(value: 'str') -> 'str':
    pass

def _resolve_media_library_path(media_id: 'str') -> 'str':
    pass

def _normalize_reference(raw: 'Any', *, entity_id: 'str' = '', role: 'str' = '') -> 'Dict[str, Any]':
    pass

def _iter_entity_records(data: 'Mapping[str, Any]') -> 'Iterable[tuple[str, str, Dict[str, Any]]]':
    pass

def _explicit_source_reference(data: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def _reference_description(raw: 'Mapping[str, Any]') -> 'str':
    pass

def _thumbnail_reference_catalog(data: 'Mapping[str, Any]') -> 'list[Dict[str, str]]':
    pass

def _video_path(item: 'Any') -> 'str':
    pass

def _extract_hook_frame(data: 'Mapping[str, Any]', candidate: 'Mapping[str, Any]', work_folder: 'str') -> 'Dict[str, Any]':
    pass

def collect_publish_references(data: 'Any', candidate: 'Mapping[str, Any]', session_folder: 'str') -> 'list[Dict[str, Any]]':
    """Resolve real hook/entity assets requested by one thumbnail concept."""
    pass

def _write_status(folder: 'str', state: 'str', **fields: 'Any') -> 'Dict[str, Any]':
    pass

def finalize_publish_package(data: 'Any', session_folder: 'str', *, generate_thumbnail: 'bool' = True, aspect_ratio: 'str' = '', source_image_path: 'str' = '', source_image_ref: 'Any' = None, source_account_name: 'str' = '', image_model: 'str' = '', seed_text: 'str' = '', language_hint: 'str' = '', style_hint: 'str' = '', force: 'bool' = False) -> 'Dict[str, Any]':
    pass
