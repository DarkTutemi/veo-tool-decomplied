"""
Decompiled / Reconstructed Module: services.shared.composition.subtitle_intent
Source PyC: subtitle_intent.pyc

Docstring:
Resolve subtitle content intent once from canonical job content.

This module deliberately does not select fonts, visual presets or geometry.
It only answers whether the measured content should remain a normal subtitle,
be bilingual, or become an A/R/B language-learning track.  The decision is
frozen into the job snapshot before dispatch so the final composition gateway
only enriches the real, time-measured SRT instead of classifying the job again.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['SUBTITLE_CONTENT_INTENT_VERSION', 'bind_full_video_subtitle_intent_to_phase0', 'build_subtitle_content_intent_prompt_contract', 'default_subtitle_content_intent', 'extract_subtitle_content_intent_decision', 'extract_subtitle_content_text', 'freeze_subtitle_content_intent_snapshot', 'merge_subtitle_content_intent_decisions', 'normalize_subtitle_content_intent', 'resolve_subtitle_content_intent', 'subtitle_intent_requires_resolution']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
Sequence = typing.Sequence
SUBTITLE_CONTENT_INTENT_VERSION = 1
_CONTENT_MODES = frozenset({'subtitle', 'bilingual', 'learning'})
_LANGUAGE_CODES = frozenset({'ko', 'en', 'pt', 'vi', 'zh', 'th', 'bn', 'fr', 'it', 'ms', 'hi', 'ru', 'es', 'ur', 'de', 'id', 'ar', 'ja', 'tl', 'tr'})
_LANGUAGE_ALIASES = {'vietnamese': 'vi', 'tiếng việt': 'vi', 'viet': 'vi', 'vi': 'vi', 'english': 'en', 'tiếng anh': 'en', 'anh': 'en', 'en': 'en', 'chinese': 'zh', 'mandarin': 'zh', 'tiếng trung': 'zh', 'trung quốc': 'z... [truncated]
_TEXT_KEYS = ('transcript', 'transcript_text', 'script', 'script_text', 'full_script', 'narration_script', 'narration', 'voiceover', 'dialogue', 'dialogue_text', 'spoken_text', 'speech', 'text')
_COLLECTION_KEYS = ('transcript_segments', 'segments', 'scenes', 'scene_list', 'chapters', 'blocks')
__all__ = ['SUBTITLE_CONTENT_INTENT_VERSION', 'bind_full_video_subtitle_intent_to_phase0', 'build_subtitle_content_intent_prompt_contract', 'default_subtitle_content_intent', 'extract_subtitle_content_intent_de... [truncated]

# --- Top-Level Functions ---
def _clean_text(value: 'Any') -> 'str':
    pass

def _language_code(value: 'Any', fallback: 'str' = '') -> 'str':
    pass

def default_subtitle_content_intent() -> 'dict[str, Any]':
    pass

def normalize_subtitle_content_intent(raw: 'Mapping[str, Any] | None', selection_mode: 'str' = 'auto') -> 'dict[str, Any]':
    pass

def _collect_spoken_text(value: 'Any', rows: 'list[str]', depth: 'int' = 0) -> 'None':
    pass

def extract_subtitle_content_text(result_data: 'Mapping[str, Any] | Sequence[Any] | None', fallback_text: 'str' = '', max_chars: 'int' = 32000) -> 'str':
    pass

def subtitle_intent_requires_resolution(profile: 'Mapping[str, Any] | None') -> 'bool':
    pass

def build_subtitle_content_intent_prompt_contract(profile: 'Mapping[str, Any] | None', *, route: 'str', configured_content_language: 'str' = '', source_kind: 'str' = '') -> 'str':
    pass

def bind_full_video_subtitle_intent_to_phase0(blocks: 'Sequence[dict[str, Any]] | None') -> 'None':
    pass

def extract_subtitle_content_intent_decision(result_data: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
    pass

def merge_subtitle_content_intent_decisions(decisions: 'Sequence[Mapping[str, Any]] | None', coverage_weights: 'Sequence[float] | None' = None) -> 'dict[str, Any]':
    """Conservatively merge unavoidable physical source-window decisions.

    Semantic long-form blocks must use one whole-source Phase-0 decision instead.
    This fallback exists only when provider media limits force physical windowing.
    A special mode must cover at least half of measured source duration, so one
    short lesson/translation fragment cannot flip an otherwise ordinary video.
    No provider is consulted here."""
    pass

def _fingerprint(text: 'str', context: 'Mapping[str, Any]') -> 'str':
    pass

def _fallback_decision(text: 'str', explanation_language: 'str') -> 'dict[str, Any]':
    pass

def _intent_prompt(text: 'str', context: 'Mapping[str, Any]') -> 'str':
    pass

def _apply_decision_to_profile(profile: 'Mapping[str, Any]', decision: 'Mapping[str, Any]', status: 'str', source: 'str', fingerprint: 'str') -> 'dict[str, Any]':
    pass

def resolve_subtitle_content_intent(profile: 'Mapping[str, Any] | None', *, route: 'str', canonical_text: 'str', content_language: 'str' = '', narration_language: 'str' = '', market: 'str' = '', provider: 'Any' = None, decision_hint: 'Mapping[str, Any] | None' = None, allow_provider_call: 'bool' = False, source_context: 'Mapping[str, Any] | None' = None, progress_callback: 'Any' = None) -> 'dict[str, Any]':
    pass

def freeze_subtitle_content_intent_snapshot(config: 'Mapping[str, Any] | None', *, route: 'str', result_data: 'Mapping[str, Any] | Sequence[Any] | None', fallback_text: 'str' = '', provider: 'Any' = None, source_context: 'Mapping[str, Any] | None' = None, progress_callback: 'Any' = None) -> 'dict[str, Any]':
    pass
