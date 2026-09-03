"""
Decompiled / Reconstructed Module: services.shared.audio.music_gate
Source PyC: music_gate.pyc

Docstring:
services/shared/audio/music_gate.py — "có nhạc thì regen" gate. DISABLED BY DEFAULT.

Owner 28/8/2026: Veo3 ALWAYS renders a full 8s audio bed — asking an LLM "is this
music?" on a uniformly-filled waveform fires spuriously, the regen loop re-hits the
same verdict, and jobs FAIL 10/10 (quota loss, nothing delivered). The mux layer
already owns native audio: transcript/audio-to-video REPLACES it (native_audio_mode
"off"), narration merges duck it ("auto"/"half"). So the gate is redundant cost.

Env:
  VEOFLOW_MUSIC_REGEN      "0" (default) DISABLED — gate never runs
                           "1" re-enable for a route experiment

Fail-open everywhere: provider unavailable / upload error / bad response →
return False (never block a job because the detector had a bad day). Verdicts
are cached per (path, size, mtime_ns) — a regen overwrites the file, so the new
take is re-checked naturally.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional
Tuple = typing.Tuple
_VERDICT_CACHE = {}
_WARNED = set()
_SOUND_INTENT_KEYS = ('allow_native_music', 'music_required', 'sound_required', 'native_audio_required')

# --- Top-Level Functions ---
def music_regen_enabled() -> 'bool':
    pass

def scene_skips_gate(prompt_data: 'Any') -> 'bool':
    pass

def _threshold() -> 'float':
    pass

def _cache_key(video_path: 'str') -> 'str':
    pass

def _extract_audio_proxy(ffmpeg: 'str', video_path: 'str', out_path: 'str', timeout: 'int' = 60) -> 'bool':
    pass

def _parse_verdict(raw: 'Any') -> 'Optional[Tuple[bool, float]]':
    pass

def _warn_once(key: 'str', message: 'str') -> 'None':
    pass

def clip_has_music(video_path: 'str', *, ffmpeg: 'str' = '', provider: 'Any' = None) -> 'bool':
    pass
