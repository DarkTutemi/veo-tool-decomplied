"""
Decompiled / Reconstructed Module: application.core_job_store_adapter
Source PyC: core_job_store_adapter.pyc

Docstring:
Adapter exposing the HeadlessJobStoreService interface, backed by core.JobStore.

Single source of truth (PyQt6 parity): ``SmartJobDispatcher`` writes job state to
``core.job_store.JobStore`` (a QObject that emits ``job_added`` / ``job_changed`` /
``job_removed``). This adapter lets the QML controller and route use-cases read and
write that SAME store through the interface they already use
(``list_jobs(tab_source=..., limit=...)`` etc.), and lets the controller connect to
its live signals — so the desktop job panel reflects real dispatcher progress like
the legacy PyQt app, instead of the parallel in-memory ``HeadlessJobStoreService``.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_FEATURE_ALIASES = {'text_video': <JobFeature.TEXT2VIDEO_16_9: 'text2video_16_9'>, 'text2video_16_9': <JobFeature.TEXT2VIDEO_16_9: 'text2video_16_9'>, 'text2video_9_16': <JobFeature.TEXT2VIDEO_9_16: 'text2video_9_16'>, ... [truncated]
_HEAVY_META_KEYS = {'preview', 'thumbnail_data', 'base64', 'thumbnail_base64', 'image_base64', 'image_data'}
_LIGHT_COPY_MAX_DEPTH = 6

# --- Class: _CreatedJobHandle ---
class _CreatedJobHandle:
    """Minimal handle so callers that read ``.job_id`` after create_job keep working."""
    def __init__(self, job: 'Any') -> 'None':
        pass

    def to_dict(self) -> 'Dict[str, Any]':
        pass


# --- Class: CoreJobStoreAdapter ---
class CoreJobStoreAdapter:
    """HeadlessJobStoreService-compatible facade over the real ``core.JobStore``."""
    core_store = <property object at 0x00000264D405FA60>

    def __init__(self) -> 'None':
        pass

    def list_jobs(self, *, tab_source: 'Optional[str]' = None, feature: 'Optional[str]' = None, status: 'Optional[str]' = None, limit: 'Optional[int]' = None) -> 'List[Dict[str, Any]]':
        pass

    def _resolve_job(self, job_id: 'str') -> 'Any':
        pass

    def get_job(self, job_id: 'str') -> 'Optional[Dict[str, Any]]':
        pass

    def get_job_light(self, job_id: 'str') -> 'Optional[Dict[str, Any]]':
        pass

    def create_job(self, *, job_id: 'str' = '', feature: 'Any', prompt: 'str' = '', title: 'str' = '', input_assets: 'Optional[List[str]]' = None, status: 'Any' = 'queued', error_message: 'str' = '', meta: 'Optional[Dict[str, Any]]' = None) -> '_CreatedJobHandle':
        pass

    def update_job(self, job_id: 'str', **updates: 'Any') -> 'Optional[Dict[str, Any]]':
        pass

    def remove_job(self, job_id: 'str') -> 'bool':
        pass

    def clear_all(self, tab_source: 'Optional[str]' = None) -> 'int':
        pass


# --- Top-Level Functions ---
def _as_feature(value: 'Any') -> 'JobFeature':
    pass

def _as_status(value: 'Any') -> 'JobStatus':
    pass

def _feature_value(job: 'Any') -> 'str':
    pass

def _value(value: 'Any') -> 'Any':
    pass

def _light_copy(value: 'Any', depth: 'int' = 0) -> 'Any':
    """Copy metadata for list views without carrying inline image blobs."""
    pass

def _job_to_light_dict(job: 'Any') -> 'Dict[str, Any]':
    pass
