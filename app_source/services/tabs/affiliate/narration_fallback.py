"""
Decompiled / Reconstructed Module: services.tabs.affiliate.narration_fallback
Source PyC: narration_fallback.pyc

Docstring:
Affiliate-only graceful degradation for exhausted Gemini TTS quota.

Affiliate videos may still be useful without the app-owned narrator because the
user can add voice in an external editor. Only quota/rate-limit exhaustion may
take this path. Alignment, malformed payload, policy and audio-integrity errors
remain hard failures so broken output is never silently accepted.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional
TTS_MODELS = ['gemini-3.1-flash-tts-preview', 'gemini-2.5-flash-preview-tts', 'gemini-2.5-pro-preview-tts']
NARRATION_QUOTA_SKIPPED = 'quota_skipped'
_MARKER_NAME = 'narration_quota_skipped.json'
_SCRIPT_NAME = 'narration_script_for_external_voice.txt'
_STALE_NARRATION_ARTIFACTS = ('narration_plan.json', 'narration_pending.json', 'narration_failed.json')

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _narrator_script(result_data: 'Dict[str, Any]') -> 'str':
    pass

def degrade_narration_on_quota(result_data: 'Dict[str, Any]', *, output_dir: 'str', error: 'BaseException') -> 'Optional[Dict[str, Any]]':
    pass
