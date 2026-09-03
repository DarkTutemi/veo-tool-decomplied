"""
Decompiled / Reconstructed Module: core.labs_api.download
Source PyC: download.pyc

Docstring:
core/labs_api/download.py — media item extraction, polling, download helpers.

Ported verbatim from core/api_client.py:
  _extract_media_items (3218) · _convert_media_to_operations (3242)
  extract_video_metadata (3302) · check_batch_video_status (2816)

poll_and_download and download_video are large (300+ lines each) and depend on
the still-active api_client globals (http_requests, VEO3GenerationError, etc.).
They are re-exported from api_client for now and will be ported in a later step
once the heavy generate/poll integration is stable.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional

# --- Top-Level Functions ---
def extract_media_items(api_result: 'Dict') -> 'List[Dict]':
    pass

def convert_media_to_operations(media_list: 'List[Dict]') -> 'List[Dict]':
    pass

def extract_video_metadata(operation: 'Dict') -> 'Dict[str, Any]':
    """Extract {video_url, media_id, project_id, media_key, thumbnail_url} from operation."""
    pass

def check_batch_video_status(operations: 'List[Dict]', account_name: 'Optional[str]' = None, account_email: 'Optional[str]' = None, media_items: 'Optional[List[Dict]]' = None, main_window=None) -> 'Optional[Dict[str, Any]]':
    pass
