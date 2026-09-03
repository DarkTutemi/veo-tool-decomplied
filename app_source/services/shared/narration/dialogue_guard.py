"""
Decompiled / Reconstructed Module: services.shared.narration.dialogue_guard
Source PyC: dialogue_guard.pyc

Docstring:
LLM speech map for narration-aware video merges.

The generated video clips already carry the final native audio (dialogue, music
and SFX).  Instead of guessing speech from waveform energy, build one tiny audio
proxy for the complete clip grid and ask Gemini for the human-speech timestamps
once.  The returned speech map is then combined with the scene contract:

* dialogue/mixed speech is protected from the external narrator;
* speech generated inside narration/ambient scenes is a policy violation and is
  muted at merge time;
* a collided mixed-scene narrator cue is moved as one PCM segment.  No TTS is
  regenerated, so the voice identity cannot drift;
* when no full gap remains under protected dialogue, the cue is trimmed into the
  largest safe gap or dropped with a non-blocking QA warning — dense dialogue
  must not kill the entire final merge.

All planning functions are pure and unit-testable.  Provider and ffmpeg work is
kept at the edge in :func:`build_dialogue_guard`.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['DialogueGuardError', 'DialogueGuardResult', 'build_dialogue_guard', 'build_native_audio_probe_command', 'plan_dialogue_guard', 'transcribe_native_speech_once']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Sequence = typing.Sequence
Tuple = typing.Tuple
_PROBE_SAMPLE_RATE = 16000
_PROBE_BITRATE = '48k'
_SPEECH_PAD_S = 0.35
_CUE_MARGIN_S = 0.15
_MIN_SPEECH_S = 0.08
_MIN_TRIMMED_CUE_S = 0.45
_EXPECTED_DIALOGUE_MIN_MATCH = 0.3
__all__ = ['DialogueGuardError', 'DialogueGuardResult', 'build_dialogue_guard', 'build_native_audio_probe_command', 'plan_dialogue_guard', 'transcribe_native_speech_once']

# --- Class: DialogueGuardError ---
class DialogueGuardError(RuntimeError):
    """Speech-map infrastructure failed (proxy/provider/plan shape)."""
    pass


# --- Class: DialogueGuardResult ---
class DialogueGuardResult:
    """DialogueGuardResult(narration_cues: 'List[Dict[str, Any]]', bed_spans: 'List[List[float]]', protected_spans: 'List[List[float]]', police_spans: 'List[List[float]]', moves: 'List[Tuple[Tuple[float, float], Tuple[float, float]]]', speech_segments: 'List[Dict[str, Any]]' = <factory>, dialogue_segments: 'List[Dict[str, Any]]' = <factory>, qa_warnings: 'List[str]' = <factory>, proxy_path: 'str' = '', speech_map_path: 'str' = '', cache_hit: 'bool' = False, clip_verdicts: 'List[Dict[str, Any]]' = <factory>)"""
    proxy_path = ''
    speech_map_path = ''
    cache_hit = False

    def __init__(self, narration_cues: 'List[Dict[str, Any]]', bed_spans: 'List[List[float]]', protected_spans: 'List[List[float]]', police_spans: 'List[List[float]]', moves: 'List[Tuple[Tuple[float, float], Tuple[float, float]]]', speech_segments: 'List[Dict[str, Any]]' = <factory>, dialogue_segments: 'List[Dict[str, Any]]' = <factory>, qa_warnings: 'List[str]' = <factory>, proxy_path: 'str' = '', speech_map_path: 'str' = '', cache_hit: 'bool' = False, clip_verdicts: 'List[Dict[str, Any]]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _clip_offsets(targets_s: 'Sequence[float]') -> 'List[float]':
    pass

def _normalize_text(text: 'str') -> 'str':
    pass

def _text_similarity(expected: 'Sequence[str]', heard: 'Sequence[str]') -> 'float':
    pass

def _merge_intervals(intervals: 'Sequence[Tuple[float, float]]', *, total_s: 'float') -> 'List[Tuple[float, float]]':
    pass

def _subtract_intervals(domain: 'Tuple[float, float]', occupied: 'Sequence[Tuple[float, float]]') -> 'List[Tuple[float, float]]':
    pass

def _overlap_s(a: 'float', b: 'float', intervals: 'Sequence[Tuple[float, float]]') -> 'float':
    pass

def _scene_dialogue_lines(clip: 'Dict[str, Any]') -> 'List[str]':
    pass

def build_native_audio_probe_command(ffmpeg: 'str', video_files: 'Sequence[str]', targets_s: 'Sequence[float]', silent_inputs: 'Sequence[bool]', output_path: 'str') -> 'List[str]':
    pass

def _proxy_fingerprint(video_files: 'Sequence[str]', targets_s: 'Sequence[float]', clips: 'Sequence[Dict[str, Any]]') -> 'str':
    pass

def _load_cached_speech_map(path: 'str', fingerprint: 'str') -> 'Optional[List[Dict[str, Any]]]':
    pass

def _write_json_atomic(path: 'str', payload: 'Dict[str, Any]') -> 'None':
    pass

def _response_has_segments_container(raw: 'Any') -> 'bool':
    pass

def transcribe_native_speech_once(audio_path: 'str', duration_s: 'float', clips: 'Sequence[Dict[str, Any]]', targets_s: 'Sequence[float]', *, provider: 'Any' = None) -> 'List[Dict[str, Any]]':
    """Upload once and make one semantic speech-map request.

    This intentionally does not use the general windowed transcriber: a clone
    merge needs one sparse speech map, not a full music/silence transcript, and
    one long audio prompt is supported by the provider."""
    pass

def _split_speech_by_clip(segments: 'Sequence[Dict[str, Any]]', targets_s: 'Sequence[float]') -> 'List[List[Tuple[float, float, str]]]':
    pass

def _dialogue_segments_for_srt(segments: 'Sequence[Dict[str, Any]]', targets_s: 'Sequence[float]', clips: 'Sequence[Dict[str, Any]]') -> 'List[Dict[str, Any]]':
    pass

def plan_dialogue_guard(*, targets_s: 'Sequence[float]', clips: 'Sequence[Dict[str, Any]]', narration_cues: 'Sequence[Dict[str, Any]]', speech_segments: 'Sequence[Dict[str, Any]]', silent_inputs: 'Optional[Sequence[bool]]' = None) -> 'DialogueGuardResult':
    """Return deterministic PCM moves and native-audio mute windows."""
    pass

def build_dialogue_guard(*, ffmpeg: 'str', video_files: 'Sequence[str]', targets_s: 'Sequence[float]', clips: 'Sequence[Dict[str, Any]]', narration_cues: 'Sequence[Dict[str, Any]]', silent_inputs: 'Sequence[bool]', plan_dir: 'str', provider: 'Any' = None) -> 'DialogueGuardResult':
    """Create/reuse the proxy, transcribe once, then make a fail-safe plan."""
    pass
