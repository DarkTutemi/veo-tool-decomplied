"""
Decompiled / Reconstructed Module: services.shared.audio.srt_transcribe
Source PyC: srt_transcribe.pyc

Docstring:
Shared audio → standard SRT.

Every tab (Clone IMAGE, Audio-to-Video, narration clock, picture-lock, Time
Machine) must use this prompt. The model only transcribes what it hears.
Thinking is off. Intended-script QA does not belong in this call — the backend
may still compare word-count after the fact and retry.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
SRT_TRANSCRIBE_THINKING = {'enable': False}
SRT_TRANSCRIBE_TEMPERATURE = 0.0
_REPEAT_SPOT_LINE = 180

# --- Top-Level Functions ---
def _srt_clock(value: 'float') -> 'str':
    pass

def build_srt_transcribe_prompt(start_s: 'float', end_s: 'float', total_s: 'float', retry_hint: 'str' = '', minimum_rows: 'int' = 0) -> 'str':
    pass

def _clip_repeat_spot_line(text: 'str') -> 'str':
    pass

def build_transcribe_repeat_spot_prompt(prior_texts: 'List[str]', later_texts: 'List[str]') -> 'str':
    """Text-only judge: which LATER rows copy PRIOR, any language."""
    pass

def transcribe_audio_to_srt(audio_path: 'str', duration: 'float', *, feature: 'str' = 'transcript_srt', progress: 'Optional[Callable[..., Any]]' = None, provider: 'Any' = None, cached_file_uri: 'Optional[str]' = None, cached_mime_type: 'Optional[str]' = None, expected_script: 'Optional[List[Dict[str, Any]]]' = None, cache_sibling: 'bool' = True) -> 'Optional[List[Dict[str, Any]]]':
    pass
