"""
Decompiled / Reconstructed Module: services.shared.audio.final_audio_master
Source PyC: final_audio_master.pyc

Docstring:
Picture-lock audio master shared by every final-video route.

The video duration is the only authoritative clock.  Native Veo audio and an
authored track (user audio or TTS) are padded/trimmed to that clock before they
are mixed, so a short native stream can never truncate the delivered audio or
the waveform used by final composition.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['bounded_audio_filter', 'build_final_audio_master', 'has_audio_stream', 'mux_audio_master', 'normalize_native_audio_mode', 'picture_lock_mix_filter', 'probe_media_duration']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Iterable = typing.Iterable
_SAMPLE_RATE = 48000
_CHANNEL_LAYOUT = 'stereo'
__all__ = ['bounded_audio_filter', 'build_final_audio_master', 'has_audio_stream', 'mux_audio_master', 'normalize_native_audio_mode', 'picture_lock_mix_filter', 'probe_media_duration']

# --- Top-Level Functions ---
def _unlink_quietly(path: 'Path') -> 'None':
    pass

def normalize_native_audio_mode(value: 'str') -> 'str':
    pass

def probe_media_duration(media_path: 'str', *, ffprobe: 'str' = '', runner: 'Callable[..., Any]' = <function run at 0x00000264D3A2EC00>) -> 'float':
    pass

def has_audio_stream(media_path: 'str', *, ffprobe: 'str' = '', runner: 'Callable[..., Any]' = <function run at 0x00000264D3A2EC00>) -> 'bool':
    pass

def bounded_audio_filter(input_label: 'str', output_label: 'str', *, duration_s: 'float', prefix_filters: 'Iterable[str]' = (), suffix_filters: 'Iterable[str]' = ()) -> 'str':
    """Build one audio chain bounded to the picture-lock duration."""
    pass

def picture_lock_mix_filter(input_labels: 'Iterable[str]', output_label: 'str', *, duration_s: 'float', limiter: 'bool' = False) -> 'str':
    pass

def build_final_audio_master(*, video_path: 'str', output_path: 'str', track_wav: 'str' = '', ffmpeg: 'str' = '', ffprobe: 'str' = '', video_duration_s: 'float' = 0.0, native_audio_mode: 'str' = 'auto', runner: 'Callable[..., Any]' = <function run at 0x00000264D3A2EC00>) -> 'Dict[str, Any]':
    pass

def mux_audio_master(*, video_path: 'str', audio_master_path: 'str', output_path: 'str', ffmpeg: 'str' = '', ffprobe: 'str' = '', video_duration_s: 'float' = 0.0, runner: 'Callable[..., Any]' = <function run at 0x00000264D3A2EC00>) -> 'Dict[str, Any]':
    pass
