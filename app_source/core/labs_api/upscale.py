"""
Decompiled / Reconstructed Module: core.labs_api.upscale
Source PyC: upscale.pyc

Docstring:
core/labs_api/upscale.py — upscale a generated video to 1080p / 4K.

Single attempt (the dispatcher owns retry). Strategy A: fetch the upscale request
via the farm browser, fall back to the Flow UI adapter on 403/recaptcha. The
server may finish immediately (download now) or run async (poll then download).
Returns the ``batch_result_info`` dict enriched with downloaded_video_path /
media_id / thumbnail_url, or an error dict the dispatcher categorizes.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional
_UPSCALE_URL = 'https://aisandbox-pa.googleapis.com/v1/video:batchAsyncGenerateVideoUpsampleVideo'
_RESOLUTION_MAP = {'720p': 'VIDEO_RESOLUTION_720P', '1080p': 'VIDEO_RESOLUTION_1080P', '4k': 'VIDEO_RESOLUTION_4K'}
_IN_PROGRESS = {'MEDIA_GENERATION_STATUS_SCHEDULED', 'MEDIA_GENERATION_STATUS_PENDING', 'MEDIA_GENERATION_STATUS_ACTIVE'}
_DOWNLOAD_FAILED = 'error_category:upscale_download_failed'

# --- Top-Level Functions ---
def _build_payload(media_id, project_id, session_id, resolution, aspect_ratio, tier_mode, workflow_id, user_tier: 'Optional[str]' = None) -> 'Dict[str, Any]':
    pass

def _resolve_account_tier(account_name: 'Optional[str]', account_email: 'Optional[str]') -> 'str':
    pass

def _account_can_afford_4k(account_name: 'Optional[str]', account_email: 'Optional[str]') -> 'bool':
    pass

def _out_filename(desired_filename: 'Optional[str]') -> 'str':
    pass

def _resolve_watermark_model(watermark_model, batch_result_info) -> 'Optional[str]':
    pass

def _handle_operation(operation, *, output_folder, account_email, account_name, resolution, is_auto_regen, watermark_model, desired_filename, media_items, main_window, result) -> 'Optional[Dict[str, Any]]':
    pass

def _download_finished(operation, output_folder, account_email, is_auto_regen, watermark_model, desired_filename, result) -> 'Dict[str, Any]':
    pass

def _error_result(e: 'Exception', media_id: 'str') -> 'Dict[str, Any]':
    pass

def upscale_video_to_1080p(media_id, account_name: 'str' = None, auto_monitor=True, prompt='upscale_1080p', prompt_index=None, main_window=None, aspect_ratio=None, video_type=None, batch_result_info=None, desired_filename=None, output_folder=None, account_email: 'str' = None, resolution: 'str' = '1080p', session_id: 'str' = None, is_auto_regen: 'bool' = False, tier_mode: 'str' = None, workflow_id: 'str' = None, on_api_success=None, watermark_model: 'str' = None):
    pass
