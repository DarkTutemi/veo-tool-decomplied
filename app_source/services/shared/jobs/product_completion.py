"""
Decompiled / Reconstructed Module: services.shared.jobs.product_completion
Source PyC: product_completion.pyc

Docstring:
Shared product-readiness contract for automated video routes.

Scene dispatch completion is only a production milestone. A row is ready for
handoff after every route-tracked post-production stage is terminal. Core media
stages must succeed; best-effort publishing enrichment may terminate as skipped.

This module is deliberately pure: it never stats files or performs other I/O,
so queue projection remains safe on the Qt GUI thread.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['CONTRACT_VERSION', 'STAGE_ORDER', 'create_product_completion', 'ensure_product_completion', 'mark_product_stage', 'mark_publish_kit_result', 'project_product_readiness', 'restart_product_completion', 'restart_product_meta_patch']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
Mapping = typing.Mapping
CONTRACT_VERSION = 1
STAGE_ORDER = ('generation', 'narration', 'merge', 'publish_kit', 'thumbnail')
TERMINAL_SUCCESS = {'completed', 'skipped', 'not_required', 'complete'}
TERMINAL_FAILURE = {'error', 'failed', 'cancelled'}
_REQUIRED_STAGE_ARTIFACTS = {'merge': ('video_path',), 'publish_kit': ('publish_info_path',), 'thumbnail': ('thumbnail_path',)}
_BEST_EFFORT_STAGES = frozenset({'thumbnail', 'publish_kit'})
_STAGE_MESSAGES = {'generation': 'Đang tạo các scene.', 'narration': 'Đã xong scene · đang xử lý giọng dẫn.', 'merge': 'Đã xong scene · đang ghép video cuối.', 'publish_kit': 'Video cuối đã sẵn sàng · đang xuất public ... [truncated]
__all__ = ['CONTRACT_VERSION', 'STAGE_ORDER', 'create_product_completion', 'ensure_product_completion', 'mark_product_stage', 'mark_publish_kit_result', 'project_product_readiness', 'restart_product_completion'... [truncated]

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _normalized_status(value: 'Any') -> 'str':
    pass

def create_product_completion(*, narration_required: 'bool', merge_required: 'bool', publish_kit_required: 'bool' = True, thumbnail_required: 'bool' = True) -> 'Dict[str, Any]':
    pass

def ensure_product_completion(current: 'Any', *, narration_required: 'bool', merge_required: 'bool', publish_kit_required: 'bool' = True, thumbnail_required: 'bool' = True) -> 'Dict[str, Any]':
    pass

def mark_product_stage(current: 'Any', stage: 'str', status: 'str', *, error: 'str' = '', artifacts: 'Mapping[str, Any] | None' = None) -> 'Dict[str, Any]':
    """Update one stage without mutating the caller's contract."""
    pass

def restart_product_completion(current: 'Any') -> 'Dict[str, Any]':
    pass

def restart_product_meta_patch(meta: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def mark_publish_kit_result(current: 'Any', result: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def _required_stages(contract: 'Mapping[str, Any]') -> 'Iterable[str]':
    pass

def project_product_readiness(row: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    """Project truthful row status from in-memory stage reports.

    The persisted PromptQueue batch may already be ``complete`` because all
    dispatcher children finished. This projection keeps the user-facing row
    running/finalizing until every tracked stage reaches a terminal outcome."""
    pass
