"""
Decompiled / Reconstructed Module: utils.video_frame_extractor

Docstring:
Video Frame Extractor Utility
Extract frames from videos for Phase 3 Hybrid Video Generation
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['extract_last_frame', 'extract_last_frame_ffmpeg', 'extract_first_frame_ffmpeg', 'extract_last_frame_cv2', 'check_ffmpeg_available', 'extract_frames_at_interval']

# --- Module Constants & Globals ---
Optional = typing.Optional
List = typing.List
__all__ = ['extract_last_frame', 'extract_last_frame_ffmpeg', 'extract_first_frame_ffmpeg', 'extract_last_frame_cv2', 'check_ffmpeg_available', 'extract_frames_at_interval']

# --- Top-Level Functions ---
def _verbose_runtime_logs() -> bool:
    # [PyArmor BCC constants]: 'os', 'environ', 'get', 'VEOFLOW_VERBOSE_RUNTIME', '1'
    pass

def get_ffmpeg_binary(binary_name: str = 'ffmpeg') -> str:
    # [PyArmor BCC constants]: 'get_runtime_resource_manager', 'lower', 'endswith', '.exe', 'ensure', 'ffmpeg', 'file', '_verbose_runtime_logs', 'print', '✅ [FFMPEG] Using runtime resource: ', 'str', 'FileNotFoundError', 'Managed FFmpeg runtime is unavailable (', '): ', 'Exception'
    pass

def get_deno_binary() -> str:
    # [PyArmor BCC constants]: 'get_runtime_resource_manager', 'ensure', 'deno', 'file', 'deno.exe', '_verbose_runtime_logs', 'print', '✅ [DENO] Using runtime resource: ', 'str', 'FileNotFoundError', 'Managed Deno runtime is unavailable: ', 'Exception'
    pass

def extract_last_frame_ffmpeg(video_path: str, output_path: Optional[str] = None) -> Optional[str]:
    # [PyArmor BCC constants]: 'os', 'path', 'exists', 'print', '❌ Video file not found: ', 'splitext', 0, '_last_frame.png', 'get_ffmpeg_binary', 'ffmpeg', '-y', '-sseof', '-0.1', '-i', '-vframes'
    pass

def extract_first_frame_ffmpeg(video_path: str, output_path: Optional[str] = None, *, seek_seconds: float = 0.5, max_width: int = 480) -> Optional[str]:
    # [PyArmor BCC constants]: 'os', 'path', 'exists', 'splitext', 0, '_thumb.jpg', 'get_ffmpeg_binary', 'ffmpeg', '-y', '-ss', 'str', 'max', 0.0, 'float', '-i'
    pass

def extract_last_frame_cv2(video_path: str, output_path: Optional[str] = None, frames_before_end: int = 2) -> Optional[str]:
    # [PyArmor BCC constants]: 'os', 'path', 'exists', 'print', '❌ Video file not found: ', 'splitext', 0, '_last_frame.jpg', '_verbose_runtime_logs', '🎬 Extracting last frame (cv2) from: ', 'cv2', 'VideoCapture', 'isOpened', '❌ Cannot open video: ', 'int'
    pass

def extract_last_frame(video_path: str, output_path: Optional[str] = None, method: str = 'auto') -> Optional[str]:
    # [PyArmor BCC constants]: 'ffmpeg', 'extract_last_frame_ffmpeg', 'cv2', 'extract_last_frame_cv2', 'print', '⚠️ FFmpeg failed, trying cv2 fallback...'
    pass

def check_ffmpeg_available() -> bool:
    # [PyArmor BCC constants]: 'get_ffmpeg_binary', 'ffmpeg', 'subprocess', 'run', '-version', 'capture_output', True, 'timeout', 5, 'returncode', 0, False, 'Exception'
    pass

def extract_frames_at_interval(video_path: str, interval: int = 8, output_folder: Optional[str] = None) -> List[str]:
    # [PyArmor BCC constants]: 'os', 'path', 'exists', 'print', '❌ Video file not found: ', 'dirname', 'makedirs', 'exist_ok', True, 'get_ffmpeg_binary', 'ffmpeg', 'ffprobe', '-v', 'error', '-show_entries'
    pass
