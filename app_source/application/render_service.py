"""
Decompiled / Reconstructed Module: application.render_service
Source PyC: render_service.pyc

Docstring:
Headless contracts for the render dialog API.

This module preserves the dialog-side validation contract and can also execute
the local ffmpeg merge path directly without depending on the old Qt
``RenderWorker`` wrapper.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
QUALITY_PRESETS = {'Original (4K)': {'codec': 'libx264', 'crf': 15, 'preset': 'slow', 'audio_bitrate': '384k', 'description': 'Near-lossless 4K'}, 'YouTube 4K': {'codec': 'libx264', 'crf': 18, 'preset': 'slow', 'audio_... [truncated]
TRANSITION_TYPES = {'fade': 'Fade', 'fadeblack': 'Fade to Black', 'fadewhite': 'Fade to White', 'dissolve': 'Dissolve', 'wipeleft': 'Wipe Left', 'wiperight': 'Wipe Right', 'slideleft': 'Slide Left', 'slideright': 'Slide... [truncated]
OUTPUT_FORMATS = ['.mp4', '.mov', '.mkv']
VIDEO_CODECS = ['auto', 'libx264', 'libx265', 'copy', 'h264_nvenc']
ENCODING_PRESETS = ['ultrafast', 'superfast', 'veryfast', 'faster', 'fast', 'medium', 'slow', 'slower', 'veryslow']
AUDIO_BITRATES = ['128k', '192k', '256k', '320k', '384k']
VIDEO_EXTENSIONS = {'.webm', '.mkv', '.mov', '.mp4', '.avi'}

# --- Class: _RenderExecutionService ---
class _RenderExecutionService:
    _store = <property object at 0x00000264D4D79DA0>

    def __init__(self) -> 'None':
        pass

    def _render_sync(self, config: 'Dict[str, Any]', *, task_key: 'str') -> 'Dict[str, Any]':
        pass

    def _register_tracking_job(self, payload: 'Dict[str, Any]', config: 'Dict[str, Any]', task_key: 'str') -> 'str':
        pass

    def _finish_tracking_job(self, tracking_job_id: 'str', *, status: 'str', progress: 'int', error_message: 'str' = '', meta_updates: 'Dict[str, Any] | None' = None) -> 'None':
        pass

    def _run_task(self, *, task_key: 'str', tracking_job_id: 'str', config: 'Dict[str, Any]') -> 'None':
        pass

    def start(self, payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def cancel(self, tracking_job_id: 'str') -> 'Dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _as_path(value: 'str') -> 'Path':
    pass

def _safe_filename(value: 'str') -> 'str':
    pass

def _output_format(value: 'str') -> 'str':
    pass

def _file_url(path: 'Path') -> 'str':
    pass

def _thumbnail_path_for_video(path: 'Path') -> 'Path':
    pass

def _ensure_video_thumbnail(path: 'Path') -> 'tuple[str, str, Dict[str, str]]':
    pass

def _extract_video_numbers(filepath: 'str') -> 'tuple[int, int]':
    pass

def _group_videos_by_root(video_paths: 'List[str]') -> 'Dict[int, List[str]]':
    pass

def video_preview(path: 'str', title: 'str' = '', index: 'int' = 0, total: 'int' = 0) -> 'Dict[str, Any]':
    pass

def list_videos(source_folder: 'str' = '') -> 'Dict[str, Any]':
    pass

def options() -> 'Dict[str, Any]':
    pass

def validate_config(payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def get_render_service() -> '_RenderExecutionService':
    pass

def start(payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def cancel(tracking_job_id: 'str') -> 'Dict[str, Any]':
    pass
