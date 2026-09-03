"""
Decompiled / Reconstructed Module: services.shared.tts.engines.moss_nano_engine
Source PyC: moss_nano_engine.pyc

Docstring:
MOSS-TTS-Nano ONNX/CPU adapter.

The managed server is a sealed executable and keeps the ONNX runtime/model in
its own process. VeoFlow talks to it through a small HTTP contract and receives
48 kHz stereo WAV, normalized here to the shared mono 24 kHz PCM contract.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_BUILTIN_VOICES = ('Ava', 'Bella', 'Adam', 'Nathan', 'Junhao', 'Zhiming', 'Weiguo', 'Xiaoyu', 'Yuewen', 'Lingyu', 'Soyo', 'Saki', 'Mortis', 'Umiri', 'Mei', 'Anon', 'Arisa', 'Trump')

# --- Class: MossNanoEngine ---
class MossNanoEngine(TtsEngine):
    engine_id = 'moss_nano'
    label = 'MOSS-TTS Nano · CPU'
    chunk_chars = 12000
    _abc_impl = <_abc._abc_data object at 0x00000264E48CA240>

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
def _clamp_int(value, default: 'int', low: 'int', high: 'int') -> 'int':
    pass
