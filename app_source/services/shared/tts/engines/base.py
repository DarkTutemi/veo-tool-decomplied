"""
Decompiled / Reconstructed Module: services.shared.tts.engines.base
Source PyC: base.pyc

Docstring:
Offline TTS engine contract — chuẩn hoá mọi engine về PCM L16 mono 24kHz.

Mỗi engine (VieNeu, OmniVoice, ...) là 1 adapter thoả TtsEngine; TTSService
route theo ``tts_route`` và chunk/concat/save y hệt free path Gemini, nên toàn
bộ máy móc phía trên (queue, progress, cancel, SRT math) dùng chung không đổi.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Tuple = typing.Tuple
TARGET_RATE = 24000

# --- Class: TtsEngineError ---
class TtsEngineError(RuntimeError):
    """Engine không chạy được / server không trả audio — message hiển thị thẳng cho user."""
    pass


# --- Class: TtsEngine ---
class TtsEngine(ABC):
    engine_id = ''
    label = ''
    chunk_chars = 800
    _abc_impl = <_abc._abc_data object at 0x00000264E48A9D40>

    def availability(self) -> 'Tuple[bool, str]':
        pass

    def capabilities(self) -> 'Dict[str, bool]':
        pass

    def list_voices(self) -> 'List[Dict[str, str]]':
        pass

    def list_styles(self) -> 'List[Dict[str, str]]':
        pass

    def prepare(self, progress=None, extra: 'Dict | None' = None) -> 'None':
        pass

    def synthesize_chunk(self, text: 'str', *, voice: 'str' = '', style: 'str' = '', ref_audio: 'str' = '', url: 'str' = '', extra: 'Dict | None' = None) -> 'bytes':
        pass


# --- Top-Level Functions ---
def float32_to_pcm16(samples) -> 'bytes':
    pass

def resample_pcm16(pcm: 'bytes', src_rate: 'int', dst_rate: 'int' = 24000) -> 'bytes':
    pass

def decode_wav_to_pcm16(content: 'bytes', dst_rate: 'int' = 24000) -> 'Tuple[bytes, Dict[str, int | str]]':
    pass

def normalize_audio_payload_to_pcm16(content: 'bytes', *, raw_rate: 'int' = 24000, dst_rate: 'int' = 24000) -> 'Tuple[bytes, Dict[str, int | str]]':
    pass
