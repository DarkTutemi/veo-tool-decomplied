"""
Decompiled / Reconstructed Module: application.job_panel_row_enrich
Source PyC: job_panel_row_enrich.pyc

Docstring:
Enrich job-panel rows với các field suy từ model — DÙNG CHUNG mọi tab.

Thay vì lặp logic ở master_controller / work_panel_controller, gom 1 chỗ:
  - max_image_inputs / max_character_refs : số slot asset (Abra=7, VEO=3; char=3)
  - multi_asset_info                      : assets có asset_type (char/obj) cho card
  - generation_time                       : giây/clip biết trước của model (initialData)
  - started_at                            : mốc bắt đầu để card synthesize progress mượt
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
_DEFAULT_IMAGE_GENERATION_SECONDS = 40
_JOB_PANEL_REGEN_TERMINAL = {'completed', 'canceled', 'error', 'complete', 'done', 'failed', 'cancelled'}
_HEAVY_ROW_KEYS = ('base64', 'thumbnail_base64', 'image_base64', 'thumbnail_data', 'image_data', 'preview')
_HEAVY_RECURSE_KEYS = ('meta', 'result_data', 'result', 'images', 'assets', 'reference_previews', 'preview')
_ASSET_FILEURI_CACHE = {}
_RENDERABLE_ASSET_KEYS = ('thumbnail_file_url', 'blob_file_url', 'file_url', 'thumbnail_url', 'thumbnail_path', 'preview_path', 'file_path', 'path', 'image_path', 'video_path')

# --- Top-Level Functions ---
def strip_heavy_inplace(obj: 'Any', _depth: 'int' = 0) -> 'Any':
    pass

def _text(value: 'Any') -> 'str':
    pass

def _positive_int(value: 'Any') -> 'int':
    pass

def clear_asset_fileuri_cache() -> 'None':
    pass

def _is_inline_blob(value: 'str') -> 'bool':
    pass

def _asset_has_renderable_source(asset: 'Dict[str, Any]') -> 'bool':
    pass

def _resolve_asset_fileuri_from_library(media_id: 'str') -> 'Dict[str, str] | None':
    pass

def _hydrate_asset_list(assets: 'Any') -> 'tuple[list[Any], bool]':
    pass

def _hydrate_asset_slot_fileuris(row: 'Dict[str, Any]') -> 'None':
    pass

def enrich_job_panel_row(row: 'Dict[str, Any]', meta: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    pass
