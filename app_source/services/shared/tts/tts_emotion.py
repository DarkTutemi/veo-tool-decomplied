"""
Decompiled / Reconstructed Module: services.shared.tts.tts_emotion
Source PyC: tts_emotion.pyc

Docstring:
Gemini-only TTS emotion presets (director notes).

MiniMax / ElevenLabs / Local TTS emotion maps removed with those providers.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Tuple = typing.Tuple
_GEMINI = [{'id': '', 'label': 'Tự nhiên'}, {'id': 'warm', 'label': 'Ấm áp', 'notes': 'Đọc với giọng ấm áp, chân thành, gần gũi.'}, {'id': 'sad', 'label': 'Buồn / xúc động', 'notes': 'Đọc với giọng buồn, trầm, ... [truncated]
_PRESETS = {'gemini': [{'id': '', 'label': 'Tự nhiên'}, {'id': 'warm', 'label': 'Ấm áp', 'notes': 'Đọc với giọng ấm áp, chân thành, gần gũi.'}, {'id': 'sad', 'label': 'Buồn / xúc động', 'notes': 'Đọc với giọng b... [truncated]
_PROVIDER_LABELS = {'gemini': 'Gemini'}
_MARKER_MAP = {'buồn': 'sad', 'sad': 'sad', 'khóc': 'sad', 'xúc động': 'sad', 'vui': 'happy', 'happy': 'happy', 'tươi': 'happy', 'vui tươi': 'happy', 'giận': 'angry', 'angry': 'angry', 'tức': 'angry', 'giận dữ': 'a... [truncated]
_MARKER_RE = re.compile('\\[([^\\[\\]]{1,24})\\]')

# --- Top-Level Functions ---
def _normalize(provider: 'str') -> 'str':
    pass

def provider_label(provider: 'str') -> 'str':
    pass

def emotion_presets(provider: 'str' = 'gemini') -> 'List[Dict[str, str]]':
    pass

def emotion_provider_options(provider: 'str', emotion_id: 'str') -> 'Dict[str, Any]':
    pass

def _canonical_emotion(word: 'str') -> 'str':
    pass

def has_emotion_markers(text: 'str') -> 'bool':
    pass

def strip_emotion_markers(text: 'str') -> 'str':
    pass

def parse_emotion_segments(text: 'str', base_emotion: 'str' = '') -> 'List[Tuple[str, str]]':
    pass
