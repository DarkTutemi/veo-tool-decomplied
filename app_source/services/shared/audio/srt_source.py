"""
Decompiled / Reconstructed Module: services.shared.audio.srt_source
Source PyC: srt_source.pyc

Docstring:
Shared transcript-source resolver for audio analysis.

The caller owns the policy. Image mode injects the LLM transcriber and requires a
complete SRT before timing analysis. Video mode passes ``llm_transcribe=None`` and
uses only an explicit/sibling SRT as an optional text accelerator; otherwise it
continues with the cached audio URI. Priority chain (see
``resolve_transcript_segments``):

  1. USER-SUPPLIED .srt — explicit `srt_path`, or a sibling `<audio>.srt` cache.
  2. LLM transcribe — injected `llm_transcribe`
     (``services.shared.audio.srt_transcribe.transcribe_audio_to_srt``):
     verbatim heard speech, standard SRT timestamps, thinking off. This
     REPLACED whisper (23/7: whisper was slow, GPU-bound, and misheard
     Vietnamese tones — "Liêu"←"Lưu" — desyncing the DP alignment).
  3. None — caller decides whether audio mode is valid or SRT is mandatory.

Segments use the SAME shape as the analyzer's enriched transcript:
  {"start": float, "end": float, "kind": "speech|music|silence|sfx",
   "text": str, "voice": str}
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
_TIME_RE = re.compile('(\\d{1,2}):(\\d{2}):(\\d{2})[,.](\\d{1,3})\\s*-->\\s*(\\d{1,2}):(\\d{2}):(\\d{2})[,.](\\d{1,3})')
_SENTENCE_SPLIT_RE = re.compile('(?<=[.!?。！？])\\s+')
_SENTENCE_MARK_RE = re.compile('[.!?。！？]+')
_LEADING_PAREN = re.compile('^\\(([^)]{3,80})\\)\\s+')
_VOICE_TAG_HINT = re.compile('\\b(narrator|voice[\\s-]?over|voiceover|speaker|tone|male|female|gentle|calm|warm|soft|deep|philosophical|whisper|newscaster)\\b', re.IGNORECASE)

# --- Top-Level Functions ---
def _looks_like_voice_tag(inner: 'str') -> 'bool':
    """True for LLM tone tags, not spoken asides like (2024) or (US)."""
    pass

def split_srt_voice_prefix(text: 'Any') -> 'tuple[str, str]':
    pass

def _srt_time(h: 'str', m: 'str', s: 'str', ms: 'str') -> 'float':
    pass

def parse_srt_file(path: 'str') -> 'List[Dict[str, Any]]':
    pass

def fill_nonspeech_gaps(segments: 'List[Dict[str, Any]]', audio_duration: 'float', min_gap: 'float' = 2.0) -> 'List[Dict[str, Any]]':
    pass

def validate_segments(segments: 'List[Dict[str, Any]]', audio_duration: 'float') -> 'Tuple[bool, str]':
    """Cheap sanity gate: non-empty, monotonic, and the last timestamp lands near the
    audio's real end (a mismatched SRT desyncs EVERY scene — reject early)."""
    pass

def _text_chunks(text: 'str', max_words: 'int', max_sentences: 'int') -> 'List[str]':
    pass

def split_overlong_rows(segments: 'List[Dict[str, Any]]', audio_duration: 'float', max_duration: 'float' = 29.0, max_words: 'int' = 40, max_sentences: 'int' = 2) -> 'List[Dict[str, Any]]':
    """Repair rows that violate the image-story anchor contract LOCALLY — split at
    sentence boundaries with capped, monotonic timing instead of discarding a whole
    transcript over one bad row (bug 28/8: 454 good rows + ONE 46s row → full
    23-minute re-transcribe → failed again the same way).

    Timing model (the "khoảng nghỉ lớn" case): we cannot hear where the pause sits
    inside a 46s row, so speech time is distributed word-proportionally and then
    water-filled under ``max_duration`` — every slice stays gate-compliant and the
    row span is preserved exactly. Fail-open: untouched segments pass through."""
    pass

def validate_image_story_segments(segments: 'List[Dict[str, Any]]', audio_duration: 'float') -> 'Tuple[bool, str]':
    pass

def validate_fixed_image_story_segments(segments: 'List[Dict[str, Any]]', audio_duration: 'float', target_count: 'int') -> 'Tuple[bool, str]':
    pass

def sibling_srt_path(audio_path: 'str') -> 'Optional[str]':
    pass

def save_sibling_srt(audio_path: 'str', segments: 'List[Dict[str, Any]]', replace_existing: 'bool' = False) -> 'str':
    pass

def split_srt_paths(srt_path: 'Any') -> 'List[str]':
    pass

def merge_segment_lists(lists: 'List[List[Dict[str, Any]]]') -> 'List[Dict[str, Any]]':
    pass

def summarize_srt_clock(segments: 'List[Dict[str, Any]]') -> 'Dict[str, Any]':
    """Compact clock stats for long-audio subtitle drift debug (grep ``[SRT-CLOCK]``)."""
    pass

def format_srt_clock_summary(stats: 'Dict[str, Any]') -> 'str':
    pass

def _fmt_srt_ts(sec: 'float') -> 'str':
    pass

def segments_to_srt(segments: 'List[Dict[str, Any]]') -> 'str':
    pass

def resolve_transcript_segments(*, audio_path: 'str', audio_duration: 'float', srt_path: 'str' = '', progress: 'Optional[Callable[[str], None]]' = None, llm_transcribe: 'Optional[Callable[..., Optional[List[Dict[str, Any]]]]]' = None, use_sibling: 'bool' = True, quality_validator: 'Optional[Callable[[List[Dict[str, Any]], float], Tuple[bool, str]]]' = None) -> 'Optional[List[Dict[str, Any]]]':
    pass
