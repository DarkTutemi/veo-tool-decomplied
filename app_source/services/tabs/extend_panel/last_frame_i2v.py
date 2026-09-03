"""
Decompiled / Reconstructed Module: services.tabs.extend_panel.last_frame_i2v
Source PyC: last_frame_i2v.pyc

Docstring:
Hybrid native-Extend / last-frame-I2V execution for Extend segments.

An Extend child prefers the native Extend sibling while the locked account can
afford it.  A confirmed insufficient balance switches the chain to:

    predecessor clip -> exact last frame -> same-account image upload -> 0cr I2V

All model and credit decisions are catalog-driven and fail closed.  In
particular, an unknown credit balance never means zero and never authorises a
paid native request.

The module is deliberately UI-free.  FFmpeg, download and upload work is called
from :class:`application.extend_service.ExtendQueueService`'s dispatch worker.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict

# --- Class: LastFrameI2VError ---
class LastFrameI2VError(RuntimeError):
    """A classified handoff failure surfaced on the Extend queue row."""
    def __init__(self, code: 'str', message: 'str', retryable: 'bool' = False) -> 'None':
        pass


# --- Class: CreditMatchedI2VModel ---
class CreditMatchedI2VModel:
    """CreditMatchedI2VModel(key: 'str', display_name: 'str', duration_seconds: 'int', credit_cost: 'int', source_model_key: 'str', family_id: 'str', speed: 'str', tier_mode: 'str')"""
    def __init__(self, key: 'str', display_name: 'str', duration_seconds: 'int', credit_cost: 'int', source_model_key: 'str', family_id: 'str', speed: 'str', tier_mode: 'str') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: NativeExtendModel ---
class NativeExtendModel:
    """NativeExtendModel(key: 'str', display_name: 'str', duration_seconds: 'int', credit_cost: 'int', source_model_key: 'str', family_id: 'str', speed: 'str', tier_mode: 'str')"""
    def __init__(self, key: 'str', display_name: 'str', duration_seconds: 'int', credit_cost: 'int', source_model_key: 'str', family_id: 'str', speed: 'str', tier_mode: 'str') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _safe_slug(value: 'Any', fallback: 'str') -> 'str':
    pass

def _is_portrait(aspect_ratio: 'Any') -> 'bool':
    pass

def _exact_credit(mapping: 'Any', credit_key: 'str') -> 'int | None':
    pass

def _source_model_contract(source_model_key: 'str', tier_mode: 'str') -> 'tuple[str, str, str, int, str]':
    pass

def _requested_video_contract(source_model_key: 'str', duration_seconds: 'Any', aspect_ratio: 'Any') -> 'tuple[int, str]':
    pass

def resolve_credit_matched_i2v_model(source_model_key: 'str', duration_seconds: 'Any', aspect_ratio: 'Any', tier_mode: 'str' = 'ultra') -> 'CreditMatchedI2VModel':
    pass

def resolve_native_extend_model(source_model_key: 'str', duration_seconds: 'Any', aspect_ratio: 'Any', tier_mode: 'str' = 'ultra') -> 'NativeExtendModel':
    pass

def resolve_zero_credit_i2v_model(source_model_key: 'str', duration_seconds: 'Any', aspect_ratio: 'Any', tier_mode: 'str' = 'ultra') -> 'CreditMatchedI2VModel':
    pass

def resolve_account_tier_mode(account: 'Dict[str, Any]') -> 'str':
    pass

def resolve_session_account(account_email: 'str', account_name: 'str' = '') -> 'Dict[str, Any]':
    pass

def refresh_account_credit_snapshot(account: 'Dict[str, Any]', checker: 'Callable[..., Any] | None' = None, attempts: 'int' = 1, retry_delay_seconds: 'float' = 0.0) -> 'Dict[str, Any]':
    pass

def _job_meta(job: 'Any') -> 'Dict[str, Any]':
    pass

def _job_model_key(job: 'Any') -> 'str':
    pass

def _existing_video_path(job: 'Any') -> 'str':
    pass

def _job_video_url(job: 'Any') -> 'str':
    pass

def _job_output_media_id(job: 'Any') -> 'str':
    pass

def _job_workflow_id(job: 'Any') -> 'str':
    pass

def prepare_native_extend_card(card: 'Dict[str, Any]', predecessor_job: 'Any', account: 'Dict[str, Any]', output_folder: 'str', route_config: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    pass

def materialize_predecessor_video(job: 'Any', handoff_dir: 'str', account_email: 'str', file_stem: 'str', downloader: 'Callable[..., Any] | None' = None) -> 'str':
    pass

def prepare_last_frame_i2v_card(card: 'Dict[str, Any]', predecessor_job: 'Any', account: 'Dict[str, Any]', output_folder: 'str', route_config: 'Dict[str, Any] | None' = None, extractor: 'Callable[..., Any] | None' = None, uploader: 'Callable[..., Any] | None' = None, downloader: 'Callable[..., Any] | None' = None, force_zero_credit: 'bool' = False) -> 'Dict[str, Any]':
    pass
