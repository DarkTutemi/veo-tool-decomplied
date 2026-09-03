"""
Decompiled / Reconstructed Module: services.shared.tts.engines.moss_engine
Source PyC: moss_engine.pyc

Docstring:
OpenMOSS MOSS-TTS Local v1.5 adapter.

Wire: official FastAPI demo ``/api/generate-stream/*``.  The server returns
48 kHz stereo WAV; this adapter normalizes it to the VeoFlow contract
(PCM s16le mono 24 kHz).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
TARGET_RATE = 24000
_LANGUAGES = {'auto': '', 'ar': 'Arabic', 'cs': 'Czech', 'da': 'Danish', 'de': 'German', 'el': 'Greek', 'en': 'English', 'es': 'Spanish', 'fa': 'Persian', 'fi': 'Finnish', 'fr': 'French', 'he': 'Hebrew', 'hi': 'Hi... [truncated]
_WIRE_MODES = {'direct': 'voice_clone', 'clone': 'voice_clone', 'continuation': 'continuation', 'continuation_clone': 'continuation_clone'}
_PAUSE_TAG_RE = re.compile('\\[\\s*pause(?:\\s+([0-9]+(?:\\.[0-9]+)?)\\s*(ms|s)?)?\\s*\\]', re.IGNORECASE)

# --- Class: MossTtsEngine ---
class MossTtsEngine(TtsEngine):
    engine_id = 'moss'
    label = 'MOSS-TTS v1.5 (open-source)'
    chunk_chars = 6000
    _abc_impl = <_abc._abc_data object at 0x00000264E48C8B00>

    def __init__(self) -> 'None':
        pass

    def availability(self):
        pass

    def capabilities(self):
        pass

    def list_voices(self):
        pass

    @staticmethod
    def validate_request(*, ref_audio='', extra=None):
        pass

    def prepare(self, progress=None, extra=None):
        pass

    def synthesize_chunk(self, text, *, voice='', style='', ref_audio='', url='', extra=None):
        pass


# --- Top-Level Functions ---
def _normalize_pause_tags(text: 'str', default_seconds: 'float' = 0.35) -> 'str':
    pass

def _clamp_float(value, default: 'float', low: 'float', high: 'float') -> 'float':
    pass

def _clamp_int(value, default: 'int', low: 'int', high: 'int') -> 'int':
    pass

def _parse_wav(content: 'bytes') -> 'bytes':
    pass
