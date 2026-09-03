"""
Decompiled / Reconstructed Module: services.shared.tts.engines.__init__
Source PyC: __init__.pyc

Docstring:
Registry engine TTS offline — xem VOICE_API_SPEC.md §engine.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
TARGET_RATE = 24000
_ENGINES = {'vieneu': <services.shared.tts.engines.vieneu_engine.VieneuEngine object at 0x00000264E5116DB0>, 'omnivoice': <services.shared.tts.engines.omnivoice_engine.OmnivoiceEngine object at 0x00000264E5116E7... [truncated]
ENGINE_IDS = ('vieneu', 'omnivoice', 'moss', 'moss_nano')
_LOCAL_TTS_PREFERENCE = ('omnivoice', 'moss', 'moss_nano', 'vieneu')
_LOCAL_TTS_LABELS = {'omnivoice': 'OmniVoice', 'moss': 'MOSS', 'moss_nano': 'MOSS Nano', 'vieneu': 'VieNeu'}

# --- Class: LocalTtsFallback ---
class LocalTtsFallback(Exception):
    """Gemini TTS quota is exhausted; finish the take on a ready local engine."""
    def __init__(self, engine_id: 'str'):
        pass

    def label(self) -> 'str':
        pass


# --- Top-Level Functions ---
def local_tts_engine_label(engine_id: 'str') -> 'str':
    pass

def ready_local_tts_engine() -> 'str':
    pass

def get_engine(engine_id: 'str') -> 'TtsEngine':
    pass

def engine_route_options() -> 'list[dict]':
    pass

def engine_status(engine_id: 'str') -> 'dict':
    pass
