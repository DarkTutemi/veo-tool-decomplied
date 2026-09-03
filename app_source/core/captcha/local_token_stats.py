"""
Decompiled / Reconstructed Module: core.captcha.local_token_stats
Source PyC: local_token_stats.pyc

Docstring:
Local token statistics tracker for captcha operations.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
Optional = typing.Optional

# --- Class: LocalTokenStats ---
class LocalTokenStats:
    """Thread-safe singleton for tracking captcha token and API statistics."""
    _instance = None
    _lock = <unlocked _thread.lock object at 0x00000264D83C3100>

    def __init__(self) -> None:
        pass

    def _reset_counters(self) -> None:
        pass

    def set_enabled(self, enabled: bool) -> None:
        pass

    def set_available(self, available: bool) -> None:
        pass

    def record_token_request(self, success: bool, time_ms: float = 0, provider: Optional[str] = None) -> None:
        pass

    def record_api_result(self, success: bool, error_code: Optional[int] = None, provider: Optional[str] = None) -> None:
        pass

    def record_video_download(self, success: bool = True) -> None:
        pass

    def record_image_download(self, success: bool = True) -> None:
        pass

    def record_images_generated(self, count: int = 1) -> None:
        pass

    def get_stats(self) -> Dict[str, Any]:
        pass

    def reset_stats(self) -> None:
        pass


# --- Top-Level Functions ---
def get_local_token_stats() -> core.captcha.local_token_stats.LocalTokenStats:
    pass

def record_video_download_safe(success: bool = True) -> None:
    pass

def record_image_download_safe(success: bool = True) -> None:
    pass

def record_images_generated_safe(count: int = 1) -> None:
    pass
