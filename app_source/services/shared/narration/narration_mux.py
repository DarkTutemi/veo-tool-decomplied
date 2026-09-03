"""
Decompiled / Reconstructed Module: services.shared.narration.narration_mux
Source PyC: narration_mux.pyc

Docstring:
Narration-aware merge — Phase 3 of NARRATOR_TIMELINE_SPEC (§6.6-6.7).

Sibling of AutoMergeService's xfade path, NEVER a replacement:
  - clips are TRIMMED to their measured target and concatenated with HARD CUTS
    (xfade eats time — the drift class behind the "video cuối 28s" report);
  - clip order comes from the merge PLAN (timeline-driven), not from guessing;
  - audio is a 3-layer MIX: native clip audio (kept! dialogue lives there,
    ducked to bed level under narration spans) + the narration track that is
    already structurally silent across dialogue scenes. The legacy
    ``_mux_source_audio`` REPLACES audio — correct for silent layers, fatal here.

The plan (``narration_plan.json``, written by narration_apply) is the single
contract: per-file target durations, narration bed spans, track/SRT names.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
_MIX_SAMPLE_RATE = 48000
_SPEECH_NOISE_DB = -27.0
_SPEECH_MIN_SILENCE_S = 0.4
_SPEECH_MIN_WINDOW_S = 0.25
_POLICE_MIN_WINDOW_S = 0.6
_POLICE_MAX_CLIP_FRACTION = 0.7
_POLICE_GAIN = 0.2
_CUE_COLLIDE_S = 0.3
_CUE_MARGIN_S = 0.15
_DUCK_ATTACK_S = 0.12
_DUCK_RELEASE_S = 0.28
_POLICE_ATTACK_S = 0.04
_POLICE_RELEASE_S = 0.1
_PENDING_BASENAME = 'narration_pending.json'
_FAILED_BASENAME = 'narration_failed.json'

# --- Top-Level Functions ---
def _detect_speech_windows(ffmpeg: 'str', path: 'str', duration_s: 'float') -> 'Optional[List[Tuple[float, float]]]':
    pass

def _subtract_intervals(intervals: 'List[Tuple[float, float]]', cuts: 'List[Tuple[float, float]]') -> 'List[Tuple[float, float]]':
    pass

def _find_gap(windows: 'List[Tuple[float, float]]', duration_s: 'float', need_s: 'float', occupied: 'Optional[List[Tuple[float, float]]]' = None) -> 'Optional[float]':
    pass

def _apply_track_moves(track_wav: 'str', out_path: 'str', moves: 'List[Tuple[Tuple[float, float], Tuple[float, float]]]') -> 'str':
    pass

def _waveform_guard(ffmpeg: 'str', video_files: 'List[str]', targets_s: 'List[float]', modes: 'List[str]', bed_spans: 'List[List[float]]', silent_inputs: 'List[bool]', track_wav: 'str', plan_dir: 'str') -> 'Tuple[str, List[List[float]], List[List[float]]]':
    """Returns (track_wav_to_use, adjusted_bed_spans, police_spans)."""
    pass

def wait_for_narration_plan(plan_path: 'str', *, timeout_s: 'float' = 600.0, poll_s: 'float' = 3.0) -> 'str':
    pass

def load_plan(plan_path: 'str') -> 'Optional[Dict[str, Any]]':
    pass

def _has_audio_stream(ffprobe: 'str', path: 'str') -> 'bool':
    pass

def _ffmpeg_run(cmd: 'List[str]', timeout: 'float'):
    pass

def write_picture_clock_concat_list(video_files: 'List[str]', targets_s: 'List[float]', list_path: 'str') -> 'None':
    pass

def build_picture_clock_concat_command(ffmpeg: 'str', list_path: 'str', output_path: 'str') -> 'List[str]':
    pass

def concat_picture_clock(ffmpeg: 'str', video_files: 'List[str]', targets_s: 'List[float]', output_path: 'str', timeout: 'float' = 3600.0) -> 'bool':
    pass

def build_narration_merge_command(ffmpeg: 'str', video_files: 'List[str]', targets_s: 'List[float]', track_wav: 'str', output_path: 'str', *, bed_spans: 'Optional[List[List[float]]]' = None, bed_gain: 'float' = 0.35, silent_inputs: 'Optional[List[bool]]' = None, police_spans: 'Optional[List[List[float]]]' = None, police_gain: 'float' = 0.2, video_gain: 'float' = 1.0, video_gains: 'Optional[List[float]]' = None) -> 'List[str]':
    """One ffmpeg invocation: per-clip trim (video+audio) → hard-cut concat →
    apply the optional per-clip native gain → smoothly duck native audio to
    ``bed_gain`` around narration spans (precomputed envelope, NOT a sidechain —
    we know exactly where narration lives) → amix with the narration track.

    ``video_gains`` is the plan path. Current plans keep every clip at full
    native volume outside narrator cues; old persisted plans that deliberately
    lowered narration clips remain replay-compatible.
    ``video_gain`` remains as the legacy whole-timeline fallback for old plans
    and direct callers that do not provide per-clip gains."""
    pass

def _smooth_gain_filter(spans: 'List[List[float]]', gain: 'float', *, attack_s: 'float', release_s: 'float') -> 'str':
    pass

def native_clip_gains(clips: 'List[Dict[str, Any]]', narration_gain: 'float') -> 'List[float]':
    pass

def plan_requires_dialogue_guard(clips: 'List[Dict[str, Any]]') -> 'bool':
    pass

def merge_with_narration(video_files: 'List[str]', plan_path: 'str', output_path: 'str', native_audio_mode: 'str' = 'auto') -> 'bool':
    """Timeline-driven merge per the narration plan.

    ``False`` is a loud, fail-closed result for narrator-aware jobs; Auto Merge
    must not publish a narrator-less legacy fallback."""
    pass
