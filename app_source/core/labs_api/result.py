"""
Decompiled / Reconstructed Module: core.labs_api.result
Source PyC: result.pyc

Docstring:
core/labs_api/result.py — GenerationResult DTO + cancellation helpers.

Unified return type for every generate_*() function so SmartJobDispatcher and the
dispatch handlers get one consistent shape. ``to_dict()`` keeps backward-compat
with callers that still consume plain dicts.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional

# --- Class: GenerationResult ---
class GenerationResult:
    """Unified result for all video generation functions."""
    success = True
    video_path = None
    media_id = None
    thumbnail_url = None
    video_url_720p = None
    start_media_id = None
    end_media_id = None
    duration = None
    error = None
    error_category = None
    workflow_id = None
    cancelled = False
    retryable = None

    def to_dict(self) -> 'Dict[str, Any]':
        pass

    @classmethod
    def from_error(cls, error: 'Exception') -> "'GenerationResult'":
        pass

    def __init__(self, success: 'bool' = True, video_paths: 'List[str]' = <factory>, video_path: 'Optional[str]' = None, media_ids: 'List[str]' = <factory>, media_id: 'Optional[str]' = None, thumbnail_urls: 'List[str]' = <factory>, thumbnail_url: 'Optional[str]' = None, video_urls: 'List[str]' = <factory>, video_url_720p: 'Optional[str]' = None, start_media_id: 'Optional[str]' = None, end_media_id: 'Optional[str]' = None, duration: 'Optional[float]' = None, error: 'Optional[str]' = None, error_category: 'Optional[str]' = None, workflow_id: 'Optional[str]' = None, cancelled: 'bool' = False, retryable: 'Optional[bool]' = None) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def cancelled_result(message: 'str' = 'Job cancelled') -> 'GenerationResult':
    pass

def cancelled_dict(message: 'str' = 'Job cancelled') -> 'Dict[str, Any]':
    pass
