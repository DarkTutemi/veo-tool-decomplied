"""
Decompiled / Reconstructed Module: application.job_store_service
Source PyC: job_store_service.pyc

Docstring:
Headless-safe job state service for internal APIs.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_job_store = <application.job_store_service.HeadlessJobStoreService object at 0x00000264D46DFE90>

# --- Class: HeadlessJob ---
class HeadlessJob:
    """HeadlessJob(job_id: 'str', feature: 'str', status: 'str' = 'queued', prompt: 'str' = '', title: 'str' = '', input_assets: 'List[str]' = <factory>, image_path: 'Optional[str]' = None, progress: 'int' = 0, error_message: 'str' = '', meta: 'Dict[str, Any]' = <factory>, created_at: 'float' = <factory>, updated_at: 'float' = <factory>)"""
    status = 'queued'
    prompt = ''
    title = ''
    image_path = None
    progress = 0
    error_message = ''

    def to_dict(self) -> 'Dict[str, Any]':
        pass

    def __init__(self, job_id: 'str', feature: 'str', status: 'str' = 'queued', prompt: 'str' = '', title: 'str' = '', input_assets: 'List[str]' = <factory>, image_path: 'Optional[str]' = None, progress: 'int' = 0, error_message: 'str' = '', meta: 'Dict[str, Any]' = <factory>, created_at: 'float' = <factory>, updated_at: 'float' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: HeadlessJobStoreService ---
class HeadlessJobStoreService:
    """In-memory job store without Qt signals.

    This is the API-facing repository for the headless runtime. Persistence and
    real execution can be added behind the same service contract."""
    def __init__(self) -> 'None':
        pass

    def create_job(self, *, job_id: 'str' = '', feature: 'str', prompt: 'str' = '', title: 'str' = '', input_assets: 'Optional[List[str]]' = None, status: 'str' = 'queued', error_message: 'str' = '', meta: 'Optional[Dict[str, Any]]' = None) -> 'HeadlessJob':
        pass

    def list_jobs(self, *, tab_source: 'Optional[str]' = None, feature: 'Optional[str]' = None, status: 'Optional[str]' = None, limit: 'Optional[int]' = None) -> 'List[Dict[str, Any]]':
        pass

    def get_job(self, job_id: 'str') -> 'Optional[Dict[str, Any]]':
        pass

    def update_job(self, job_id: 'str', **updates: 'Any') -> 'Optional[Dict[str, Any]]':
        pass

    def remove_job(self, job_id: 'str') -> 'bool':
        pass

    def clear_all(self, tab_source: 'Optional[str]' = None) -> 'int':
        pass


# --- Top-Level Functions ---
def _feature_value(value: 'Any') -> 'str':
    pass

def _status_value(value: 'Any') -> 'str':
    pass

def set_headless_job_store(store_like: 'Any') -> 'Any':
    pass

def reset_headless_job_store() -> 'HeadlessJobStoreService':
    pass

def install_core_job_store_adapter() -> 'Any':
    pass

def _job_to_aggregate_dict(src: 'Any') -> 'Dict[str, Any]':
    pass

def list_jobs_by_runtime_ids(store: 'Any', runtime_ids: 'List[Any]') -> 'List[Dict[str, Any]]':
    pass

def get_headless_job_store() -> 'Any':
    pass
