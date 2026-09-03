"""
Decompiled / Reconstructed Module: core.labs_api.audio
Source PyC: audio.pyc

Docstring:
core/labs_api/audio.py — Flow audio generation via batch API.

Ported from core/api_client_legacy.py:call_flow_audio_generation_api.
Uses transport.fetch_then_ui_fallback for the HTTP layer.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional

# --- Top-Level Functions ---
def call_flow_audio_generation_api(*, dialog: 'str', voice_performance: 'str', speaker: 'str', base_voice: 'str', main_window=None, account_name: 'Optional[str]' = None, account_email: 'Optional[str]' = None, generation_type: 'str' = 'PREVIEW', model_key: 'Optional[str]' = None) -> 'Dict[str, Any]':
    pass
