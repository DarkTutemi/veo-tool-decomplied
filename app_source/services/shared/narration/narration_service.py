"""
Decompiled / Reconstructed Module: services.shared.narration.narration_service
Source PyC: narration_service.pyc

Docstring:
Phase-1 orchestrator: scenes → narration WAV + timeline + cut plan + SRT.

Runs Stages A→E + H of the spec pipeline end-to-end, standalone (no master/clone
knowledge). Normal Master/Clone jobs derive paragraph timing from the exact PCM
chunk map already returned by TTS, then snap internal paragraph cuts to waveform
pauses. Transcript verification remains an explicit strict mode for workflows
that must prove verbatim speech before dispatch (currently Affiliate).

Ordering constraint honoured by CALLERS later (Phase 4/5): this must complete
BEFORE ``dispatch_scenes`` because the measured spans decide each clip's
generated duration (§7.3).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
DEFAULT_ALIGN_THRESHOLD = 0.8
DEFAULT_MAX_REGEN_ROUNDS = 2
_CHUNK_MAP_MIN_DURATION_RATIO = 0.72
_CHUNK_MAP_MAX_DURATION_RATIO = 2.5
_TTS_EXPECTED_CHARS_PER_SECOND = 16.0

# --- Class: NarrationTimelineOverflowError ---
class NarrationTimelineOverflowError(RuntimeError):
    """Measured narrator audio exceeds the fixed generated-video timeline."""
    pass


# --- Class: NarrationBuildResult ---
class NarrationBuildResult:
    """NarrationBuildResult(script: 'NarrationScript', take: 'RenderedTake', alignment: 'AlignmentResult', timeline: 'NarrationTimeline', track_wav_path: 'str', srt_path: 'str', srt_text: 'str', warnings: 'List[str]' = <factory>)"""
    total_duration_s = <property object at 0x00000264E42101D0>

    def __init__(self, script: 'NarrationScript', take: 'RenderedTake', alignment: 'AlignmentResult', timeline: 'NarrationTimeline', track_wav_path: 'str', srt_path: 'str', srt_text: 'str', warnings: 'List[str]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: VerifiedNarrationTake ---
class VerifiedNarrationTake:
    """A rendered take whose final PCM is proven against its canonical script."""
    regeneration_rounds = 0

    def __init__(self, take: 'RenderedTake', segments: 'List[Dict[str, Any]]', alignment: 'AlignmentResult', regenerated_chunks: 'List[int]' = <factory>, regeneration_rounds: 'int' = 0) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _alignment_from_rendered_chunk_map(script: 'NarrationScript', take: 'RenderedTake', *, threshold: 'float', failed_indices: 'List[int]', validate_duration: 'bool' = True, fallback_reason: 'str' = '') -> 'Optional[AlignmentResult]':
    """Build timing from the already-rendered take without another provider call.

    ``render_take`` owns exact PCM and exact paragraph membership for every
    provider chunk. Use those hard chunk boundaries and distribute each chunk
    across its paragraphs by spoken-character weight. ``build_timeline``
    subsequently snaps every estimated inter-paragraph boundary to the quietest
    waveform window, so these are search regions rather than blind final cuts.

    Strict transcript fallback refuses suspiciously short/long affected chunks.
    The normal PCM path does not repeat that heuristic because ``render_take``
    already performs the authoritative truncation gate before returning a take."""
    pass

def verify_and_repair_rendered_take(script: 'NarrationScript', take: 'RenderedTake', initial_segments: 'List[Dict[str, Any]]', *, transcribe: 'Callable[..., Optional[List[Dict[str, Any]]]]', tts: 'Any' = None, strict_align_threshold: 'float' = 0.6, max_regen_rounds: 'int' = 1, post_rerender: 'Optional[Callable[[RenderedTake], Optional[float]]]' = None, progress_callback: 'Optional[Callable[[str], None]]' = None, cancel_checker: 'Optional[Callable[[], bool]]' = None) -> 'VerifiedNarrationTake':
    """Repair only TTS chunks missing from a known-script semantic transcript.

    Clone IMAGE/VIDEO already owns a complete canonical script and a rendered
    take, so it must not replay source analysis or regenerate sibling chapters.
    A semantic transcript is checked once; failed paragraph IDs map back to the
    exact local TTS chunks, which are regenerated and listened to once more."""
    pass

def build_narration_timeline(scenes: 'List[Dict[str, Any]]', *, output_dir: 'str', voice_name: 'str', base_name: 'str' = 'narration', model: 'str' = '', language: 'str' = 'vi', emotion: 'str' = '', direction: 'Optional[Dict[str, str]]' = None, casting_intent: 'Optional[Dict[str, str]]' = None, director_notes: 'str' = '', audio_profile: 'str' = '', scene_hint: 'str' = '', sample_context: 'str' = '', tts: 'Any' = None, tts_route: 'str' = 'auto', voice_state: 'Optional[Dict[str, Any]]' = None, fit: 'str' = 'flow', transcribe: 'Optional[Callable[..., List[Dict[str, Any]]]]' = None, verify_transcript: 'bool' = True, qa_narrator: 'bool' = True, align_threshold: 'float' = 0.8, strict_alignment: 'bool' = False, strict_align_threshold: 'float' = 0.6, max_regen_rounds: 'int' = 2, exact_durations: 'bool' = False, reject_overflow: 'bool' = False, wps_store_path: 'str' = '', max_pause_seconds: 'float' = 0.0, progress_callback: 'Optional[Callable]' = None, cancel_checker: 'Optional[Callable[[], bool]]' = None, pre_rendered_take: 'Optional[RenderedTake]' = None, preverified_segments: 'Optional[List[Dict[str, Any]]]' = None) -> 'NarrationBuildResult':
    """Scenes + voice config → ``{paragraph spans, cut plan, narration WAV, total}``.

    ``verify_transcript=False`` is the normal Master/Clone path: the returned
    TTS PCM/chunk map is the timing source and no narrator ASR/LLM call is made.
    ``verify_transcript=True`` keeps the bounded one-listen transcript +
    semantic-verification QA loop for strict workflows. Legacy injected
    transcribers without verdict metadata fall back to forced alignment.
    ``transcribe`` is injectable for tests / alternative engines; ``tts``
    likewise (default ``TTSService``). Artifacts land in
    ``output_dir``:
    ``<base>_take.wav`` (one-take TTS), ``<base>_track.wav`` (timeline-shifted
    narration track, silent across dialogue), ``<base>.srt`` (final cue map)."""
    pass
