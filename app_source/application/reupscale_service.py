"""
Decompiled / Reconstructed Module: application.reupscale_service
Source PyC: reupscale_service.pyc

Docstring:
Service facade for QML re-upscale and local preview contracts.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_IMAGE_RESOLUTION_ENUMS = {'2k': 'UPSAMPLE_IMAGE_RESOLUTION_2K', '4k': 'UPSAMPLE_IMAGE_RESOLUTION_4K'}
_IMAGE_EXTENSIONS = {'.png', '.jpg', '.gif', '.bmp', '.jpeg', '.webp'}

# --- Class: ReUpscaleService ---
class ReUpscaleService:
    """Expose QML re-upscale preview/dry-run contracts plus the real start path."""
    _store = <property object at 0x00000264D4DE6390>

    def __init__(self) -> 'None':
        pass

    def _bind_manager_signals(self) -> 'None':
        pass

    @staticmethod
    def _history_meta_for_request(request: 'dict[str, Any]', *, run_id: 'str', item_id: 'str', feature: 'str', title: 'str', model: 'str') -> 'dict[str, Any]':
        pass

    def _register_tracking_job(self, request: 'dict[str, Any]', task_key: 'str') -> 'str':
        pass

    def _tracked_job_ids(self, media_id: 'str') -> 'list[str]':
        pass

    def _finish_tracked_jobs(self, media_id: 'str', *, status: 'str', progress: 'int', error_message: 'str' = '', extra_meta: 'dict[str, Any] | None' = None) -> 'None':
        pass

    def _on_job_started(self, media_id: 'str') -> 'None':
        pass

    def _on_job_progress(self, media_id: 'str', message: 'str') -> 'None':
        pass

    def _on_job_completed(self, media_id: 'str', output_path: 'str') -> 'None':
        pass

    def _on_job_failed(self, media_id: 'str', error_message: 'str') -> 'None':
        pass

    def options(self, tier_mode: 'str' = 'ultra') -> 'dict[str, Any]':
        pass

    def preview_asset(self, row: 'dict[str, Any]', index: 'int' = 0, tier_mode: 'str' = 'ultra') -> 'dict[str, Any]':
        pass

    def _validate_image_request(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def _image_dry_run(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def _register_image_upscale_job(self, request: 'dict[str, Any]') -> 'str':
        pass

    def _run_image_upscale_job(self, job_id: 'str', request: 'dict[str, Any]') -> 'None':
        pass

    def _start_image_real(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def _start_real(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def start(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def video_preview(self, path: 'str', title: 'str' = '', index: 'int' = 0, total: 'int' = 0) -> 'dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _is_image_request(payload: 'dict[str, Any]') -> 'bool':
    pass

def _normalize_image_resolution(value: 'Any') -> 'str':
    pass

def _image_resolution_label(value: 'Any') -> 'str':
    pass

def _image_upscale_model_key(value: 'Any') -> 'str':
    pass

def _image_upscale_time_seconds(value: 'Any') -> 'int':
    pass

def _image_resolution_rank(value: 'Any') -> 'int':
    pass

def _local_path_text(value: 'Any') -> 'str':
    pass

def _is_remote_path(value: 'str') -> 'bool':
    pass

def _safe_stem(value: 'Any', fallback: 'str') -> 'str':
    pass

def _image_output_path(request: 'dict[str, Any]', job_id: 'str') -> 'Path':
    pass

def _decode_image_base64(value: 'Any') -> 'bytes':
    pass

def get_reupscale_service() -> 'ReUpscaleService':
    pass
