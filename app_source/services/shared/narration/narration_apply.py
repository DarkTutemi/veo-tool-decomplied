"""
Decompiled / Reconstructed Module: services.shared.narration.narration_apply
Source PyC: narration_apply.pyc

Docstring:
Pre-dispatch narration apply — the "auto edit" step (owner, 2026-07-19).

Runs BETWEEN script generation and ``dispatch_scenes``. Owner 20/7 (second
correction): narration NEVER touches the video timeline — every scene keeps
exactly the user's clip duration and the user's MODEL (a duration bump used to
re-route the video model, breaking the credit/model choice). Tab-agnostic —
master calls it now, clone's remix mode later.

    audio first: TTS one take → transcribe (SRT) → forced-align → measured spans
    → cues are LAID OVER the fixed clip grid (a long cue flows into the next
    scene; the following cue is pushed later — never a bump, never a split)
    → narration scenes get the audio-to-video silent policy injected per scene
    → a merge plan (plan.json) is written for the narration-aware merger.

Never silently continue: a narration failure raises — a narrator job without its
narration track is the wrong product.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
AUDIO_MODE_MIXED = 'mixed'
AUDIO_MODE_NARRATION = 'narration'
NARRATED_MODES = ('narration', 'mixed')
EXTERNAL_NARRATOR_RULE = 'The app adds an off-screen narrator in post-production. The generated video must contain no speech, dialogue, narration, singing, vocal sounds, lip-sync, music, score, soundtrack, jingle, or rhythm c... [truncated]
SCENE_SILENT_POLICY = 'The app adds an off-screen narrator in post-production. The generated video must contain no speech, dialogue, narration, singing, vocal sounds, lip-sync, music, score, soundtrack, jingle, or rhythm c... [truncated]
PLAN_FILENAME = 'narration_plan.json'
PENDING_FILENAME = 'narration_pending.json'
FAILED_FILENAME = 'narration_failed.json'
DIRECTOR_FILENAME = 'narration_director.json'
DEFAULT_BED_GAIN = 0.32
DEFAULT_VIDEO_GAIN = 1.0
_EN_FUNCTION_WORDS = frozenset({'are', 'of', 'the', 'and', 'can', 'do', 'it', 'were', 'be', 'when', 'an', 'a', 'you', 'this', 'in', 'not', 'as', 'his', 'is', 'that', 'its', 'will', 'or', 'they', 'our', 'her', 'we', 'from'... [truncated]
_VI_MARKED_CHARS = {'ễ', 'ừ', 'ạ', 'í', 'à', 'ờ', 'ò', 'ỡ', 'ợ', 'ấ', 'ẽ', 'ụ', 'ổ', 'ề', 'ằ', 'ồ', 'ỳ', 'ẩ', 'ú', 'è', 'ộ', 'ứ', 'ó', 'â', 'ẻ', 'ô', 'ỹ', 'đ', 'ỉ', 'ỗ', 'ớ', 'ỷ', 'ẹ', 'ố', 'ủ', 'ắ', 'é', 'ĩ', 'ỵ', 'ẳ',... [truncated]

# --- Class: NarrationLanguageError ---
class NarrationLanguageError(RuntimeError):
    """The narrated lines are not written in the configured narration language —
    the script LLM composed/translated them wrong. Raised BEFORE any TTS spend:
    a wrong-language take costs a full TTS+ASR+align cycle and can NEVER align
    (E2E 20/7 run 14:17: LLM code-switched EN/VI, the LLM-TTS then re-translated
    parts on every regen → alignment sims pinned at ~0.25 forever)."""
    pass


# --- Top-Level Functions ---
def _foreign_narration_line(says: 'str', language: 'str') -> 'bool':
    """True when a narrator line is clearly NOT in the configured language (vi):
    near-zero Vietnamese-marked words plus multiple English function words.

    Word-level on purpose — the old any-non-ASCII check was blinded by a single
    curly apostrophe (E2E 20/7: 15 pure-English lines slipped through because
    the LLM types U+2019 for "doesn't")."""
    pass

def _inject_silent_policy(scene: 'Dict[str, Any]') -> 'None':
    pass

def _write_failed(output_dir: 'str', error: 'str') -> 'None':
    pass

def _scene_id(scene: 'Dict[str, Any]', fallback: 'str') -> 'str':
    pass

def _expected_dialogue_lines(scene: 'Dict[str, Any]') -> 'List[str]':
    pass

def log_wire_leak_check(scene_id: 'str', narrator_says: 'str', wire_text: 'str') -> 'bool':
    pass

def _resolve_narrator_identity(result_data: 'Dict[str, Any]', language: 'str', default_emotion: 'str' = '', voice_state: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
    pass

def plan_narration_for_director(result_data: 'Dict[str, Any]', *, output_dir: 'str', language: 'str' = 'vi', voice_state: 'Optional[Dict[str, Any]]' = None, on_lifecycle: 'Optional[Callable[[Dict[str, Any]], None]]' = None) -> 'Optional[Dict[str, Any]]':
    """Layer A of the post-video director flow (owner 2026-08): everything the
    DISPATCH needs from narrator mode — audio_mode stamping, silent policies,
    fixed durations, voice casting — WITHOUT touching TTS.

    The script LLM's ``narrator_voice.says`` paragraphs are kept as the DRAFT
    skeleton (xương sống kịch bản). The real narration text is authored AFTER the
    clips exist (``narration_director.run_narration_director`` at merge time),
    guided by the draft + the actual video frames + the native speech windows —
    so word budgets become exact and `mixed` lead-ins land in REAL silence.

    Writes ``narration_director.json`` (full scene snapshot + casting). Merge
    refuses to mux when that marker exists but the plan never appears — the
    director path is fail-closed like the classic one."""
    pass

def _narrator_draft_says(scene: 'Dict[str, Any]') -> 'str':
    pass

def apply_narration_to_result(result_data: 'Dict[str, Any]', *, output_dir: 'str', language: 'str' = 'vi', language_strict: 'bool' = True, tts: 'Any' = None, tts_route: 'str' = 'auto', voice_state: 'Optional[Dict[str, Any]]' = None, transcribe: 'Optional[Callable]' = None, progress: 'Optional[Callable[[str], None]]' = None, async_render: 'bool' = False, default_emotion: 'str' = '', strict_timing: 'bool' = False, max_pause_seconds: 'float' = 0.0, on_lifecycle: 'Optional[Callable[[Dict[str, Any]], None]]' = None, pre_rendered_take: 'Any' = None, preverified_segments: 'Optional[List[Dict[str, Any]]]' = None) -> 'Optional[Dict[str, Any]]':
    """Prepare scenes for dispatch (policies + durations, text-only, fast) and
    build the narration track/plan for the merger.

    ``async_render=False``: render inline; returns the full summary; a render
    failure raises (legacy behavior, used by tests/standalone callers).
    ``async_render=True`` (owner 20/7 — "tất cả hoạt động song song"): dispatch
    gets everything it needs in milliseconds; the TTS render + PCM timeline runs
    in a background thread and writes ``narration_plan.json`` (atomic) for the
    merger, which waits on the ``narration_pending.json`` marker. A background
    failure writes ``narration_failed.json`` and Auto Merge fails closed.
    Returns a ``{"status": "rendering", ...}`` stub.

    Returns None when the scene list has no narration scene (not an error)."""
    pass
