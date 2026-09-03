"""
Decompiled / Reconstructed Module: services.shared.narration.narration_director
Source PyC: narration_director.pyc

Docstring:
Post-video narration director — Layer C of the director flow (owner 2026-08).

Classic flow (narration_apply): the script LLM writes narration BEFORE any video
exists, so the text can describe shots Veo never rendered — the "narrator không
khớp" class. The director flow keeps that text only as the DRAFT skeleton
(xương sống) and authors the REAL narration here, at merge time, after the clips
are downloaded:

    per narrated scene: 3 frames + exact clip duration + native speech windows
    (dialogue_guard-style bandpass probe) + the draft paragraph + control knobs
    → ONE multimodal call rewrites the narration to fit WHAT IS ON SCREEN

Budgets become exact (duration × wps), `mixed` lead-ins land in REAL measured
silence before the character's line, and the language guard still runs before a
single TTS credit. Everything downstream (collect_script → TTS take → cue grid
→ plan.json → narration_mux) re-enters UNCHANGED via apply_narration_to_result —
the director only fills ``narrator_voice`` on the frozen scene snapshot.

Fail-closed: any director failure writes ``narration_failed.json`` so AutoMerge
refuses a narrator-less output (same contract as the classic background render).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['DIRECTOR_FILENAME', 'run_narration_director']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
DIRECTOR_FILENAME = 'narration_director.json'
_FRAME_COUNT = 3
__all__ = ['DIRECTOR_FILENAME', 'run_narration_director']

# --- Top-Level Functions ---
def _load_marker(output_dir: 'str') -> 'Dict[str, Any]':
    pass

def _extract_frames(video_path: 'str', duration_s: 'float', work_dir: 'str') -> 'List[str]':
    pass

def _speech_windows(video_path: 'str') -> 'List[List[float]]':
    pass

def _ffmpeg_bin() -> 'str':
    pass

def _default_provider():
    pass

def _scene_rows_for_prompt(rows: 'List[Dict[str, Any]]', frames_by_row: 'List[List[str]]', windows_by_row: 'List[List[List[float]]]') -> 'str':
    pass

def _frame_index(rows: 'List[Dict]', row_idx: 'int', frame_idx: 'int') -> 'int':
    pass

def _build_prompt(marker: 'Dict[str, Any]', rows: 'List[Dict[str, Any]]', frames_by_row: 'List[List[str]]', windows_by_row: 'List[List[List[float]]]') -> 'str':
    pass

def _parse_reply(text: 'str', rows: 'List[Dict[str, Any]]') -> 'Dict[str, Dict[str, str]]':
    pass

def run_narration_director(output_dir: 'str', *, video_files: 'Optional[List[str]]' = None, provider: 'Any' = None, strict_language: 'bool' = True, progress: 'Optional[Callable[[str], None]]' = None) -> 'Dict[str, Any]':
    """Author the narration text from the REAL clips, then run the unchanged
    classic render (TTS take → measure → narration_plan.json). Blocking; called
    by AutoMerge right before it waits for the plan."""
    pass
