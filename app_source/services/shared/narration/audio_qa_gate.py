"""
Decompiled / Reconstructed Module: services.shared.narration.audio_qa_gate
Source PyC: audio_qa_gate.pyc

Docstring:
Audio QA Gate — the professional, unified quality gate for narrator jobs
(owner 2026-08). Two gates, one report, one repair router:

    GATE A — NARRATOR (TTS time, before plan.json)
        WHAT  : the rendered narrator take WAV (app-owned voice)
        HOW   : upload once → 1 LLM call listens (narrator_qa.audit_take)
        VERDICT: per paragraph — ok | mixed | wrong_language | missing + score
        REPAIR: regen ONLY the failed TTS chunks, up to (max_regen_rounds + 1)
                audit rounds → text-level rewrite (director flow) → fail-closed
        FILES : services/shared/narration/narrator_qa.py

    GATE B — NATIVE CLIP AUDIO (Veo voice, merge time)
        WHAT  : the native audio of every generated clip (character dialogue,
                stray speech), via the dialogue_guard speech-map proxy
        HOW   : 1 LLM call listens to the concatenated proxy audio
                (dialogue_guard.transcribe_native_speech_once)
        VERDICT: per clip (dialogue_guard.plan_dialogue_guard → clip_verdicts)
                 pass | police | review_clip | regen_clip
        REPAIR: police      → auto-applied (stray voice in narration/ambient
                              scenes is hard-muted in the mix)
                regen_clip  → the clip generated WITHOUT its character speech —
                              actionable for the per-scene regen flow; strict
                              mode fails the merge instead
                review_clip → speech present but text drifted (ASR may be
                              loose) — logged, merge proceeds
        FILES : services/shared/narration/dialogue_guard.py

GATE REPORT — ``audio_gate_report.json`` in the narration folder: the single
artefact carrying both gates' verdicts, so a job's audio QA is auditable after
the fact and repair actions are explicit instead of implicit in logs.

Verdicts/actions are computed in PYTHON from LLM measurements — the model never
gets the final word on quality.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['REPORT_FILENAME', 'A_PASS', 'A_POLICE', 'A_REVIEW_CLIP', 'A_REGEN_CLIP', 'A_REGEN_NARRATOR', 'A_FAIL', 'summarize_clip_verdicts', 'write_report', 'route_repairs']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
REPORT_FILENAME = 'audio_gate_report.json'
A_PASS = 'pass'
A_POLICE = 'police'
A_REVIEW_CLIP = 'review_clip'
A_REGEN_CLIP = 'regen_clip'
A_REGEN_NARRATOR = 'regen_narrator'
A_FAIL = 'fail'
__all__ = ['REPORT_FILENAME', 'A_PASS', 'A_POLICE', 'A_REVIEW_CLIP', 'A_REGEN_CLIP', 'A_REGEN_NARRATOR', 'A_FAIL', 'summarize_clip_verdicts', 'write_report', 'route_repairs']

# --- Top-Level Functions ---
def summarize_clip_verdicts(clip_verdicts: 'List[Dict[str, Any]]') -> 'Dict[str, int]':
    pass

def write_report(output_dir: 'str', *, clip_verdicts: 'Optional[List[Dict[str, Any]]]' = None, police_spans: 'Optional[List[List[float]]]' = None, qa_warnings: 'Optional[List[str]]' = None, narrator_section: 'Optional[Dict[str, Any]]' = None) -> 'str':
    pass

def route_repairs(clip_verdicts: 'List[Dict[str, Any]]', *, strict_clip_audio: 'bool' = False) -> 'Dict[str, Any]':
    pass
