"""
Decompiled / Reconstructed Module: application.reupscale_api_service
Source PyC: reupscale_api_service.pyc

Docstring:
Headless contracts for the re-upscale dialog API.

The real re-upscale worker is still Qt/account/session bound. This module
keeps the QML surface honest by normalizing job rows into preview payloads and
dry-run requests that can be validated without network or worker execution.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
RESOLUTIONS = [{'label': '1080p (HD)', 'value': '1080p'}, {'label': '4K (Ultra HD)', 'value': '4k'}]
DEFAULT_ASPECT_RATIO = 'VIDEO_ASPECT_RATIO_LANDSCAPE'
VIDEO_EXTENSIONS = {'.webm', '.mkv', '.mov', '.mp4', '.avi'}
IMAGE_EXTENSIONS = {'.png', '.jpg', '.gif', '.bmp', '.jpeg', '.webp'}
REAL_WORKER_BLOCKER = {'code': 'reupscale_worker_unavailable_headless', 'message': 'Re-upscale execution depends on UI-owned account/session workers.', 'hint': 'Call /internal/reupscale/start with dry_run=true, then dispat... [truncated]

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _first_text(*values: 'Any') -> 'str':
    pass

def _meta(row: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _row_value(row: 'Dict[str, Any]', *keys: 'str') -> 'Any':
    pass

def _row_list(row: 'Dict[str, Any]', *keys: 'str') -> 'list[Any]':
    pass

def _is_remote_path(value: 'str') -> 'bool':
    pass

def _local_path(value: 'str') -> 'Path':
    pass

def _path_exists(value: 'str') -> 'bool':
    pass

def _suffix(value: 'str') -> 'str':
    pass

def _filename(value: 'str') -> 'str':
    pass

def _normalize_resolution(value: 'Any') -> 'str':
    pass

def _normalize_asset(value: 'Any', index: 'int') -> 'Dict[str, Any]':
    pass

def list_options(tier_mode: 'str' = 'ultra') -> 'Dict[str, Any]':
    pass

def _plan_from_request(request: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def validate_request(payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def preview_asset(row: 'Dict[str, Any]', index: 'int' = 0, tier_mode: 'str' = 'ultra') -> 'Dict[str, Any]':
    pass

def reupscale_request_from_row(row: 'Dict[str, Any]', tier_mode: 'str' = 'ultra') -> 'Dict[str, Any]':
    pass

def start(payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass
