"""
Decompiled / Reconstructed Module: core.labs_api.util
Source PyC: util.pyc

Docstring:
core/labs_api/util.py — shared utilities (filename, URLs, workflow id, misc).

Ported verbatim from core/api_client.py:
  raise_generation_error (537) · _is_stop_requested (560) · _cancelled_* (570)
  generate_video_filename (588) · build_video_url (648) · build_thumbnail_url (659)
  validate_media_on_account (669) · extract_workflow_id_from_response (3343)
  filter_heavy_blobs (1167) · extract_error_message (1195)
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional

# --- Top-Level Functions ---
def raise_generation_error(message: 'str', cached_data: 'dict' = None, category: 'str' = None) -> 'None':
    pass

def is_stop_requested(stop_check) -> 'bool':
    pass

def generate_video_filename(row_number: 'int', output_index: 'int', output_folder: 'str', extension: 'str' = '.mp4', prefix: 'str' = '', anti_overwrite: 'bool' = True) -> 'str':
    pass

def build_video_url(media_uuid: 'str') -> 'Optional[str]':
    pass

def build_thumbnail_url(media_uuid: 'str') -> 'Optional[str]':
    pass

def validate_media_on_account(media_uuid: 'str', account_name: 'str') -> 'bool':
    pass

def extract_workflow_id_from_response(api_result: 'Dict') -> 'Optional[str]':
    pass

def filter_heavy_blobs(data: 'Any', max_str_len: 'int' = 200) -> 'Any':
    pass

def extract_error_message(result: 'Dict[str, Any]') -> 'Optional[str]':
    pass
