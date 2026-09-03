"""
Decompiled / Reconstructed Module: services.tabs.affiliate.lifecycle
Source PyC: lifecycle.pyc

Docstring:
Pure projections for the unified Affiliate preparation/production conveyor.

The prompt queue remains the execution queue.  Preparation rows are UI-only
projections keyed by the product column; they never enter PromptQueueService.
Keeping the merge pure lets the controller apply one atomic model update on the
GUI thread while workers report small lifecycle events through a Qt signal.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
_PREPARATION_STAGES = {'imported': ('Đã nhập sản phẩm', 2), 'queued': ('Chờ phân tích sản phẩm', 5), 'analyzing': ('Đang nhận diện sản phẩm', 12), 'prepared': ('Đã nhận diện sản phẩm', 22), 'normalizing': ('Đang chuẩn hoá ... [truncated]
_PRODUCT_STATUS_TO_STAGE = {'product attached': 'imported', 'pool preparing': 'planning', 'pool failed': 'prep_failed'}
_PIPELINE_STAGE_INDEX = {'imported': 0, 'queued': 0, 'analyzing': 0, 'prepared': 0, 'normalizing': 1, 'normalize_failed': 1, 'ready': 1, 'planning': 2, 'resolving_assets': 3, 'rendering_narration': 4, 'generating_start_frame... [truncated]

# --- Top-Level Functions ---
def _list(value: 'Any') -> 'list[Any]':
    pass

def _int(value: 'Any', default: 'int' = 0) -> 'int':
    pass

def _asset_count(source: 'Dict[str, Any]', category: 'str') -> 'int':
    """Count one category from package summaries or multi_asset_info."""
    pass

def _image_count(product: 'Dict[str, Any]', event: 'Dict[str, Any]') -> 'int':
    pass

def _display_package(source: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _display_job(source: 'Dict[str, Any]', product: 'Dict[str, Any]', event: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    pass

def normalize_stage(value: 'Any') -> 'str':
    pass

def preparation_row(card: 'Dict[str, Any]', event: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    pass

def production_row(row: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def merge_lifecycle_rows(cards: 'Iterable[Dict[str, Any]]', events: 'Dict[str, Dict[str, Any]]', queue_rows: 'Iterable[Dict[str, Any]]') -> 'List[Dict[str, Any]]':
    """Project explicitly admitted work plus durable production rows.

    Product import owns reversible preparation (analysis + identity sheet), but
    it is not queue admission.  Those pre-admission stages stay on the product
    card/workspace and must not appear in the work list.  Once the user admits a
    product, its planning/package lifecycle is shown until a real production row
    for the same product exists.  This keeps the handoff atomic without making an
    imported product look queued."""
    pass

def lifecycle_counts(rows: 'Iterable[Dict[str, Any]]') -> 'Dict[str, int]':
    pass
