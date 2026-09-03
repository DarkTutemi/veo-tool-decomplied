"""
Decompiled / Reconstructed Module: services.tabs.clone_video.clone_image_timeline
Source PyC: clone_image_timeline.pyc

Docstring:
Clone-image native timeline alignment.

The clone LLM already owns the story, entity library, narration paragraphs and
still-image descriptions.  After the one-take TTS call, SRT is used only as the
audio clock: this module maps the existing narration paragraphs onto the SRT
timeline without asking another LLM to reinterpret or rewrite the content.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
Sequence = typing.Sequence
Tuple = typing.Tuple
_WORD_RE = re.compile('[\\wÀ-ỹ]+')
_DIRECTION_RE = re.compile('^\\s*(?:\\([^)]{1,120}\\)|\\[[^\\]]{1,120}\\])\\s*')
_NONSPEECH_AUDIO_ROLES = {'visual_only', 'ambient', 'music', 'silence', 'sfx'}
_AUDIO_ROLE_ALIASES = {'no_speech': 'silence', 'silent': 'silence', 'visual': 'visual_only', 'visual-only': 'visual_only', 'sound_effect': 'sfx', 'sound-effects': 'sfx'}

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _says_text(value: 'Any') -> 'str':
    pass

def _narration(scene: 'Dict[str, Any]') -> 'str':
    pass

def ordered_clone_image_scenes(raw: 'Any') -> 'List[Dict[str, Any]]':
    pass

def _collect_spoken_chunks(value: 'Any', acc: 'List[str]', depth: 'int' = 0) -> 'None':
    pass

def _spoken_fallback(scene: 'Dict[str, Any]') -> 'str':
    pass

def _normalize_narrator_voice(scene: 'Dict[str, Any]', says: 'str') -> 'None':
    pass

def prepare_clone_image_narration_scenes(raw: 'Any') -> 'List[Dict[str, Any]]':
    pass

def count_clone_image_spoken_units(scenes: 'Any') -> 'int':
    """How many IMAGE beats carry TTS words after prepare/normalize."""
    pass

def clone_image_audio_role(scene: 'Dict[str, Any]') -> 'str':
    pass

def clone_image_gap_seconds(scene: 'Dict[str, Any]') -> 'float':
    pass

def _tokens(value: 'Any') -> 'List[str]':
    pass

def _speech_segments(segments: 'Iterable[Dict[str, Any]]') -> 'List[Dict[str, Any]]':
    pass

def _paragraph_cut_samples(script: 'Any', take: 'Any') -> 'Tuple[Dict[int, int], set[int]]':
    pass

def ensure_clone_image_structural_gaps(scenes: 'Sequence[Dict[str, Any]]', script: 'Any', take: 'Any') -> 'Dict[str, Any]':
    """Insert real PCM silence for explicit non-speech Clone IMAGE scenes.

    TTS is still generated once. This post-step only inserts zero-valued PCM at
    quiet paragraph boundaries, so intro/outro/music/SFX/silence beats receive a
    real clock interval for SRT and image assembly without regenerating voice."""
    pass

def _transcript_tokens_with_boundaries(segments: 'Sequence[Dict[str, Any]]', audio_duration: 'float') -> 'Tuple[List[str], List[float]]':
    pass

def _transcript_tokens_with_spans(segments: 'Sequence[Dict[str, Any]]') -> 'Tuple[List[str], List[float], List[float]]':
    pass

def _script_index_spans(speech: 'Sequence[Dict[str, Any]]', paragraph_count: 'int') -> 'List[Tuple[float, float]] | None':
    pass

def _aligned_speech_spans(scene_token_lists: 'Sequence[Sequence[str]]', speech: 'Sequence[Dict[str, Any]]', audio_duration: 'float') -> 'Tuple[List[Tuple[float, float]], float, str]':
    pass

def _split_weighted(start: 'float', end: 'float', scene_indices: 'Sequence[int]', scenes: 'Sequence[Dict[str, Any]]') -> 'List[float]':
    pass

def _all_scene_boundaries(scenes: 'Sequence[Dict[str, Any]]', narration_indices: 'Sequence[int]', speech_spans: 'Sequence[Tuple[float, float]]', audio_duration: 'float') -> 'Tuple[List[float], int]':
    """Build one contiguous visual timeline while preserving non-speech gaps."""
    pass

def _map_script_position(position: 'int', anchors: 'Sequence[Tuple[int, int]]', transcript_size: 'int') -> 'float':
    pass

def _time_for_token_position(position: 'float', boundaries: 'Sequence[float]') -> 'float':
    pass

def _aligned_boundaries(scene_word_counts: 'Sequence[int]', scene_tokens: 'Sequence[str]', transcript_tokens: 'Sequence[str]', transcript_boundaries: 'Sequence[float]', audio_duration: 'float') -> 'Tuple[List[float], float, str]':
    pass

def build_timed_clone_image_scenes(scenes: 'Sequence[Dict[str, Any]]', srt_segments: 'Sequence[Dict[str, Any]]', audio_duration: 'float') -> 'List[Dict[str, Any]]':
    pass
