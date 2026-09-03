"""
Decompiled / Reconstructed Module: services.tabs.timemachine.input_media
Source PyC: input_media.pyc

Docstring:
Freeze and understand optional Time Machine audio/SRT input.

Disk and provider work in this module is worker-only.  It reuses the app's
shared SRT resolver and windowed LLM transcriber, so user SRT, sibling cache and
audio transcription follow the same priority order as Audio-to-Video.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AUDIO_EXTENSIONS', 'IMAGE_EXTENSIONS', 'SUBTITLE_EXTENSIONS', 'analyze_time_machine_source_media', 'input_media_kind', 'probe_audio_duration', 'split_time_machine_inputs']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Mapping = typing.Mapping
Sequence = typing.Sequence
IMAGE_EXTENSIONS = {'.png', '.jpg', '.avif', '.gif', '.bmp', '.jpeg', '.webp'}
AUDIO_EXTENSIONS = {'.opus', '.ogg', '.mp3', '.flac', '.m4a', '.wma', '.aac', '.wav'}
SUBTITLE_EXTENSIONS = {'.srt', '.vtt'}
__all__ = ['AUDIO_EXTENSIONS', 'IMAGE_EXTENSIONS', 'SUBTITLE_EXTENSIONS', 'analyze_time_machine_source_media', 'input_media_kind', 'probe_audio_duration', 'split_time_machine_inputs']

# --- Top-Level Functions ---
def input_media_kind(path: 'str', explicit: 'str' = '') -> 'str':
    pass

def split_time_machine_inputs(inputs: 'Sequence[Mapping[str, Any]]') -> 'Dict[str, Any]':
    pass

def probe_audio_duration(path: 'str') -> 'float':
    pass

def analyze_time_machine_source_media(*, audio_path: 'str' = '', srt_path: 'str' = '', progress: 'Callable[[str], None] | None' = None) -> 'Dict[str, Any]':
    """Return one frozen timing/transcript context for the storyboard planner."""
    pass
