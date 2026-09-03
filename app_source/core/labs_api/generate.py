"""
Decompiled / Reconstructed Module: core.labs_api.generate
Source PyC: generate.pyc

Docstring:
core/labs_api/generate.py — high-level video generation orchestration.

Each ``generate_*`` runs a single attempt (no retry — SmartJobDispatcher owns
job-level retry): fan out ``output_count`` API calls under one batch_id, merge
their operations, then poll_and_download. ``*_dict`` wrappers return plain dicts
for the dispatch handlers; the rich form returns a GenerationResult.

Upload (Phase J) and extend-chain (Phase L) helpers are not in labs_api yet and
are bridged from core.api_client during the additive refactor.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple

# --- Class: _GenerationCancelled ---
class _GenerationCancelled(Exception):
    """Internal signal: user cancelled mid-generation → return cancelled_result()."""
    pass


# --- Top-Level Functions ---
def _merge_api_results(results: 'List[Dict[str, Any]]') -> 'Tuple[Dict[str, Any], Optional[str]]':
    pass

def _resolve_filename(desired_filename: 'Optional[str]', extend_chain_id: 'Optional[str]', root_card_index: 'int', row_number: 'int') -> 'str':
    pass

def _result_from_download(dl_result: 'Dict[str, Any]', workflow_id: 'Optional[str]', **extra) -> 'GenerationResult':
    pass

def _call_loop(output_count: 'int', stop_check, call_one) -> 'List[Dict[str, Any]]':
    pass

def generate_text_video(prompt: 'str', model: 'str', output_count: 'int', account_name: 'str', aspect_ratio: 'str' = '16:9', row_number: 'int' = 1, progress_cb=None, main_window=None, enable_upscale: 'bool' = False, row_id: 'Optional[str]' = None, output_folder: 'Optional[str]' = None, extend_chain_id: 'Optional[str]' = None, root_card_index: 'int' = 1, account_email: 'Optional[str]' = None, mode: 'str' = 'landscape', batch_id: 'Optional[str]' = None, is_auto_regen: 'bool' = False, user_tier: 'str' = 'PAYGATE_TIER_TWO', resolution: 'str' = '', on_poll_start=None, stop_check=None, desired_filename: 'Optional[str]' = None, heartbeat_cb=None) -> 'GenerationResult':
    pass

def generate_text_video_dict(prompt: 'str', model: 'str', output_count: 'int', account_name: 'str', **kwargs) -> 'Dict[str, Any]':
    pass

def _upload_image_with_retry(*, image_path: 'Optional[str]', media_library_id: 'Optional[str]', account_name: 'str', account_email: 'Optional[str]', main_window, stop_check, label: 'str', force_upload: 'bool' = False) -> 'str':
    pass

def _prepare_i2v_local_plate(image_path: 'Optional[str]') -> 'Tuple[str, bool, str]':
    pass

def _i2v_prefer_local_plate(image_path: 'Optional[str]', media_id: 'Optional[str]', media_library_id: 'Optional[str]') -> 'Tuple[str, Optional[str], Optional[str], bool, str]':
    pass

def _upload_from_media_library(media_id: 'Optional[str]', account_name: 'str', account_email: 'Optional[str]', label: 'str') -> 'Optional[str]':
    pass

def generate_image_video(image_path: 'str', prompt: 'str', model: 'str', account_name: 'str', aspect_ratio: 'str' = 'VIDEO_ASPECT_RATIO_LANDSCAPE', is_interpolation: 'bool' = False, end_image_path: 'Optional[str]' = None, output_count: 'int' = 1, row_number: 'int' = 1, progress_cb=None, main_window=None, enable_upscale: 'bool' = False, mode: 'str' = 'landscape', row_id: 'Optional[str]' = None, start_media_id: 'Optional[str]' = None, end_media_id: 'Optional[str]' = None, account_email: 'Optional[str]' = None, output_folder: 'Optional[str]' = None, is_auto_regen: 'bool' = False, user_tier: 'str' = 'PAYGATE_TIER_TWO', media_library_id: 'Optional[str]' = None, end_media_library_id: 'Optional[str]' = None, on_poll_start=None, stop_check=None, desired_filename: 'Optional[str]' = None, heartbeat_cb=None, use_pinhole: 'bool' = False) -> 'GenerationResult':
    pass

def generate_image_video_dict(image_path: 'str', prompt: 'str', model: 'str', account_name: 'str', **kwargs) -> 'Dict[str, Any]':
    pass

def generate_image_video_with_auto_fix(image_path: 'str', prompt: 'str', model: 'str', account_name: 'str', **kwargs) -> 'Dict[str, Any]':
    pass

def _preupload_last_frame(extend_chain_id: 'str', aspect_ratio: 'str', model: 'str', account_name: 'str', account_email: 'Optional[str]') -> 'None':
    """Upload the previous clip's last frame BEFORE the extend call (web parity:
    the server links it via session_id as a quality reference). Best-effort — any
    failure is non-fatal. Downloads the 720p clip to a temp file when no local
    copy exists, extracts the last frame, and uploads it base64."""
    pass

def generate_extend_video_with_auto_fix(prompt: 'str', media_id: 'str', model: 'str', account_name: 'str', aspect_ratio: 'str' = 'VIDEO_ASPECT_RATIO_PORTRAIT', start_frame_index: 'int' = 168, end_frame_index: 'int' = 191, row_number: 'int' = 1, extend_position: 'int' = 1, progress_cb=None, main_window=None, row_id: 'str' = None, output_folder: 'str' = None, extend_chain_id: 'Optional[str]' = None, root_card_index: 'int' = 1, image_media_id: 'Optional[str]' = None, account_email: 'Optional[str]' = None, enable_upscale: 'bool' = False, resolution: 'str' = '1080p', desired_filename: 'Optional[str]' = None, user_tier: 'str' = 'PAYGATE_TIER_TWO', workflow_id: 'Optional[str]' = None, on_poll_start=None, is_auto_regen: 'bool' = False, stop_check=None, heartbeat_cb=None) -> 'Dict[str, Any]':
    """Single-attempt extend generation (dispatcher owns retry). Returns a flat
    dict {video_path, media_id, thumbnail_url, fife_url, duration, workflow_id}.
    Raises on failure (400 media errors become 'media_id_expired')."""
    pass
