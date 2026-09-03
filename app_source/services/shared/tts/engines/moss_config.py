"""
Decompiled / Reconstructed Module: services.shared.tts.engines.moss_config
Source PyC: moss_config.pyc

Docstring:
Shared persisted-state contract for MOSS-TTS v1.5.

All narration callers store the same flat ``moss_*`` keys.  This module is the
single translator from that state into the generic :class:`TTSService` engine
contract, so Master, Clone and Voice Studio cannot silently drift apart.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
MOSS_STATE_KEYS = ('moss_backend', 'moss_mode', 'moss_language', 'moss_ref_audio', 'moss_prompt_text', 'moss_nano_voice', 'moss_nano_cpu_threads', 'moss_nano_max_frames', 'moss_nano_text_normalization', 'moss_nano_samp... [truncated]
MOSS_DEFAULTS = {'moss_backend': 'auto', 'moss_mode': 'direct', 'moss_language': 'vi', 'moss_ref_audio': '', 'moss_prompt_text': '', 'moss_nano_voice': 'Ava', 'moss_nano_cpu_threads': '4', 'moss_nano_max_frames': '37... [truncated]
MOSS_FULL_GPU_MIN_VRAM_GB = 16.0
MOSS_HYBRID_MIN_VRAM_GB = 12.0

# --- Top-Level Functions ---
def snapshot_moss_state(state: 'Mapping[str, Any] | None') -> 'dict[str, str]':
    pass

def moss_engine_kwargs(state: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
    pass

def resolve_moss_engine_id(state: 'Mapping[str, Any] | None') -> 'str':
    pass

def resolve_moss_runtime_profile(state: 'Mapping[str, Any] | None') -> 'str':
    pass
