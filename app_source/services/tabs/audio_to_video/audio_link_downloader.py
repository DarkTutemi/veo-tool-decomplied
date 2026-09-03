"""
Decompiled / Reconstructed Module: services.tabs.audio_to_video.audio_link_downloader
Source PyC: audio_link_downloader.pyc

Docstring:
Download the audio track of a public URL via yt-dlp + ffmpeg.

Used by the Audio-to-Video tab so a user can paste a link (YouTube, TikTok,
Facebook, direct media, …) and get a local audio file added to the queue, the
same as picking a local file. Network + ffmpeg work — ALWAYS call off the UI
thread (the controller runs it in a daemon thread).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Optional = typing.Optional

# --- Class: _AudioDlLogger ---
class _AudioDlLogger:
    """yt-dlp logger that tolerates bytes (Windows) and stays quiet."""
    def debug(self, msg: 'Any') -> 'None':
        pass

    def warning(self, msg: 'Any') -> 'None':
        pass

    def error(self, msg: 'Any') -> 'None':
        pass


# --- Top-Level Functions ---
def _ffmpeg_dir() -> 'Optional[str]':
    pass

def fetch_link_metadata(url: 'str', timeout: 'int' = 20) -> 'Dict[str, Any]':
    pass

def download_audio_from_url(url: 'str', output_dir: 'str', audio_format: 'str' = 'mp3', on_progress: 'Optional[Callable[[float, str], None]]' = None) -> 'Dict[str, Any]':
    pass
