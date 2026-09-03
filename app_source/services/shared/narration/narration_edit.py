"""
Decompiled / Reconstructed Module: services.shared.narration.narration_edit
Source PyC: narration_edit.pyc

Docstring:
Stage D+E — energy-verified cut plan + sample-exact timeline assembly (§6.4-6.5).

Never cut the WAV at SRT timestamps (rejected alt #6): transcription timestamps
carry ±100-300ms jitter and would clip word tails. The alignment gives the SEARCH
REGION between two paragraphs; waveform energy (windowed RMS) picks the exact
sample. No true pause in the region → log LOUDLY and fall back to the region
midpoint rather than guessing elsewhere.

Timeline math is arithmetic on absolute sample positions (proven in the
image-story assembler): narration scenes get MEASURED spans (a boundary-partition
of the take, so Σ narration samples == take samples exactly), dialogue/ambient
scenes get FIXED grid spans. Overlap prevention is STRUCTURAL — the narration
track is physically silent across a dialogue span because the timeline was
shifted by exactly that clip's duration (rejected alt #4: no mix setting can
break that).

Also here: clip quantization planning (§6.6) and final-timeline SRT export (§6.8).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
SUPPORTED_FIXED_CLIP_DURATIONS = (4, 6, 8, 10)
AUDIO_MODE_NARRATION = 'narration'
NARRATED_MODES = ('narration', 'mixed')
SAMPLE_RATE = 24000
SAMPLE_WIDTH = 2
_WIN_MS = 30
_HOP_MS = 10
_FADE_MS = 10
_UNVERIFIED_FADE_MS = 80
_ABS_SILENCE_RMS = 60.0
_REL_SILENCE_FACTOR = 0.1
_EMPTY_REGION_PAD_S = 0.35

# --- Class: CutSearch ---
class CutSearch:
    """CutSearch(sample: 'int', rms: 'float', verified: 'bool')"""
    def __init__(self, sample: 'int', rms: 'float', verified: 'bool') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: Boundary ---
class Boundary:
    """Boundary(after_paragraph: 'int', sample: 'int', verified: 'bool', physical: 'bool')"""
    def __init__(self, after_paragraph: 'int', sample: 'int', verified: 'bool', physical: 'bool') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: SceneSpan ---
class SceneSpan:
    """SceneSpan(scene_id: 'Any', audio_mode: 'str', start_sample: 'int', end_sample: 'int', take_start: 'Optional[int]' = None, take_end: 'Optional[int]' = None, clip_plan: 'List[int]' = <factory>, sample_rate: 'int' = 24000, cue_start: 'Optional[int]' = None)"""
    take_start = None
    take_end = None
    sample_rate = 24000
    cue_start = None
    cue_end = <property object at 0x00000264E41BDCB0>
    start_s = <property object at 0x00000264E41BDC10>
    end_s = <property object at 0x00000264E41BDB70>
    span_s = <property object at 0x00000264E41BC860>

    def __init__(self, scene_id: 'Any', audio_mode: 'str', start_sample: 'int', end_sample: 'int', take_start: 'Optional[int]' = None, take_end: 'Optional[int]' = None, clip_plan: 'List[int]' = <factory>, sample_rate: 'int' = 24000, cue_start: 'Optional[int]' = None) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: NarrationTimeline ---
class NarrationTimeline:
    """NarrationTimeline(scene_spans: 'List[SceneSpan]', boundaries: 'List[Boundary]', take_samples: 'int', total_samples: 'int', sample_rate: 'int' = 24000)"""
    sample_rate = 24000
    total_duration_s = <property object at 0x00000264E41BE390>

    def __init__(self, scene_spans: 'List[SceneSpan]', boundaries: 'List[Boundary]', take_samples: 'int', total_samples: 'int', sample_rate: 'int' = 24000) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _rms(samples: 'array', start: 'int', end: 'int') -> 'float':
    pass

def median_take_rms(pcm: 'bytes', sample_rate: 'int' = 24000) -> 'float':
    pass

def find_cut_sample(pcm: 'bytes', sample_rate: 'int', region_start_s: 'float', region_end_s: 'float', *, ref_rms: 'float', win_ms: 'int' = 30, hop_ms: 'int' = 10) -> 'CutSearch':
    pass

def plan_clip_durations(span_s: 'float') -> 'List[int]':
    pass

def build_timeline(scenes: 'List[Dict[str, Any]]', script: 'NarrationScript', alignment: 'AlignmentResult', take_pcm: 'bytes', *, sample_rate: 'int' = 24000, default_clip: 'int' = 8, fit: 'str' = 'flow', exact_durations: 'bool' = False) -> 'NarrationTimeline':
    """§6.5 — walk scenes in order; narration audio is MEASURED, video length is
    the CLIP GRID.

    ``fit`` (owner decision 20/7, second correction — "giọng dẫn đừng can thiệp
    vào timeline"):
      - "flow" (default; "pad" is an accepted alias): the video grid is 100%
        the USER'S — every scene keeps exactly its own clip duration, NEVER
        bumped to a covering tier, NEVER split (a duration change re-routes the
        video MODEL, breaking the user's model/credit choice). The narration is
        a separate layer laid over that fixed grid: each cue is anchored at its
        scene's start, and a cue longer than its scene simply FLOWS into the
        next scene ("giọng dẫn 10 giây ăn 1 cảnh 8 giây và 2 giây của cảnh kế
        tiếp"); the following cue is pushed later accordingly.
      - "trim": legacy tight-sync — the scene span IS the measured speech span
        and the merger trims the clip to it.

    A boundary is computed between EVERY consecutive paragraph pair (energy-first,
    widened-scan fallback) in BOTH modes: boundaries slice the take into
    per-scene speech segments, so Σ narration speech samples == take samples
    EXACTLY by construction."""
    pass

def _apply_fades(segment: 'bytes', *, fade_in_samples: 'int', fade_out_samples: 'int') -> 'bytes':
    pass

def assemble_track(take_pcm: 'bytes', timeline: 'NarrationTimeline', *, fade_ms: 'int' = 10) -> 'bytes':
    pass

def export_srt_segments(timeline: 'NarrationTimeline', script: 'NarrationScript', alignment: 'AlignmentResult') -> 'List[Dict[str, Any]]':
    pass

def export_srt(timeline: 'NarrationTimeline', script: 'NarrationScript', alignment: 'AlignmentResult') -> 'str':
    pass
