"""
Decompiled / Reconstructed Module: application.generation_handlers
Source PyC: generation_handlers.pyc

Docstring:
Headless generation handlers registered behind DispatcherPort.

These handlers intentionally call the Qt-free API client functions directly
instead of wrapping SmartJobDispatcher. They require explicit credentials in the
payload/config; account selection remains a separate headless port.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict

# --- Top-Level Functions ---
def _merged(payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _first(data: 'Dict[str, Any]', *keys: 'str', default: 'Any' = None) -> 'Any':
    pass

def _account_name(data: 'Dict[str, Any]') -> 'str':
    pass

def _account_email(data: 'Dict[str, Any]') -> 'Any':
    pass

def _model(data: 'Dict[str, Any]', feature: 'str' = 'text_to_video') -> 'str':
    pass

def _aspect(data: 'Dict[str, Any]', fallback: 'str' = '16:9') -> 'str':
    pass

def _output_count(data: 'Dict[str, Any]') -> 'int':
    pass

def _text(value: 'Any') -> 'str':
    pass

def _safe_int(value: 'Any', default: 'int' = 0) -> 'int':
    pass

def _safe_str_list(value: 'Any') -> 'list[str]':
    pass

def _image_aspect_ratio(value: 'Any') -> 'str':
    pass

def _ratio_folder_suffix(value: 'Any') -> 'str':
    pass

def _image_output_dir(data: 'Dict[str, Any]', job_key: 'str') -> 'Path':
    pass

def _filename_prefix_from_prompt(prompt: 'str') -> 'str':
    pass

def _persist_image(base64_data: 'str', output_dir: 'Path', job_key: 'str', index: 'int', *, prompt: 'str' = '', filename_format: 'str' = 'number') -> 'str':
    pass

def _live_account_for_image(data: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _update_job_progress(data: 'Dict[str, Any]', *, progress: 'int', message: 'str', patch: 'Dict[str, Any] | None' = None) -> 'None':
    pass

def image_generation_handler(payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def text_video_handler(payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def image_video_handler(payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def extend_video_handler(payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def multi_asset_video_handler(payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def register_generation_handlers(dispatcher: 'Any') -> 'None':
    pass
