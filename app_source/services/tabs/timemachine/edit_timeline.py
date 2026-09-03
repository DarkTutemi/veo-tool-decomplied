"""
Decompiled / Reconstructed Module: services.tabs.timemachine.edit_timeline
Source PyC: edit_timeline.pyc

Docstring:
Clip-centric editorial timeline for Time Machine.

The generation timeline is keyframe-centric and must remain chapter-contiguous
so every local Start-End edge can be rendered.  The editorial timeline is a
permutation of those already valid clips.  It can interleave chapters without
duplicating keyframes or losing a transition.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['build_clip_candidates', 'build_causal_graph', 'build_resource_timeline', 'default_edit_timeline', 'edit_beat_id', 'generate_edit_timeline', 'resource_timeline_for_plan', 'validate_edit_timeline']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Mapping = typing.Mapping
Optional = typing.Optional
Sequence = typing.Sequence
__all__ = ['build_clip_candidates', 'build_causal_graph', 'build_resource_timeline', 'default_edit_timeline', 'edit_beat_id', 'generate_edit_timeline', 'resource_timeline_for_plan', 'validate_edit_timeline']

# --- Top-Level Functions ---
def edit_beat_id(view_id: 'str', from_stage: 'int', to_stage: 'int') -> 'str':
    pass

def build_resource_timeline(chapters: 'Sequence[Mapping[str, Any]]') -> 'list[Dict[str, Any]]':
    pass

def resource_timeline_for_plan(plan: 'Mapping[str, Any]') -> 'list[Dict[str, Any]]':
    pass

def build_clip_candidates(*, resource_timeline: 'Sequence[Mapping[str, Any]]', chapters: 'Sequence[Mapping[str, Any]]') -> 'list[Dict[str, Any]]':
    """Project every continuous resource edge into one stable clip candidate."""
    pass

def _is_directed_timeline_candidate(candidate: 'Mapping[str, Any]') -> 'bool':
    pass

def _is_directed_timeline(candidates: 'Sequence[Mapping[str, Any]]') -> 'bool':
    pass

def validate_edit_timeline(beat_ids: 'Sequence[Any]', *, candidates: 'Sequence[Mapping[str, Any]]', factual_lock: 'bool' = False) -> 'list[Dict[str, Any]]':
    pass

def default_edit_timeline(candidates: 'Sequence[Mapping[str, Any]]') -> 'list[Dict[str, Any]]':
    pass

def _decode_editor_response(response: 'Any') -> 'Dict[str, Any]':
    pass

def build_causal_graph(*, beats: 'Sequence[Mapping[str, Any]]', candidates: 'Sequence[Mapping[str, Any]]', story_mode: 'str' = 'global_causal', dependencies: 'Sequence[Mapping[str, Any]]' = (), factual_lock: 'bool' = False) -> 'Dict[str, Any]':
    pass

def _media_part(provider: 'Any', path: 'str', *, uri_cache: 'Dict[str, str]') -> 'Dict[str, str]':
    pass

def _ordered_keyframes(grid: 'Mapping[str, Any]', chapters: 'Sequence[Mapping[str, Any]]') -> 'list[Dict[str, Any]]':
    pass

def _contact_sheet_sources(cells: 'Sequence[Mapping[str, Any]]') -> 'tuple[list[str], list[Dict[str, Any]]]':
    pass

def generate_edit_timeline(*, topic: 'str', intent: 'str', chapters: 'Sequence[Mapping[str, Any]]', resource_timeline: 'Sequence[Mapping[str, Any]]', grid: 'Mapping[str, Any]', motion_trace: 'Sequence[Mapping[str, Any]]' = (), provider: 'Optional[Any]' = None, uri_cache: 'Optional[Dict[str, str]]' = None, progress: 'Optional[Callable[[str], None]]' = None, factual_lock: 'bool' = False) -> 'Dict[str, Any]':
    pass
