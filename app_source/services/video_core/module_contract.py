"""
Decompiled / Reconstructed Module: services.video_core.module_contract
Source PyC: module_contract.pyc

Docstring:
Shared timeline-module contract for video prompt generation.

The three long-form services (master prompt, clone video, audio/transcript)
all ask an LLM to convert source intent into short video scenes. This module
keeps that contract in one place: available modules, content-type profiles,
prompt guidance, timeline fallback, and the final visual compiler.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['MODULE_POOL', 'CONTENT_TYPE_PROFILES', 'WIRE_NOISE_KEYS', 'build_global_plan', 'build_model_facing_scene_payload', 'render_video_wire_as_natural_text', 'compact_timeline_for_model', 'prune_model_facing_value', 'relabel_dialogue_line_to_says', 'timeline_has_dialogue', 'timeline_has_person', 'build_timeline_from_control', 'build_video_scene_response_blueprint', 'build_video_scene_module_contract', 'clean_model_facing_scene_text', 'compile_scene_visual_from_timeline', 'content_type_profile', 'control_key_for_content_type', 'derive_audio_from_timeline', 'ensure_scene_module_contract', 'module_ids_for_content_type']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
_SYSTEM_ENTITY_ID_RE = re.compile('\\b(?:CHAR|OBJ|BG|SET|PRODUCT|DATA|MAP)_\\d{3}\\b')
_SYSTEM_ENTITY_WITH_NAME_RE = re.compile('\\b(?:CHAR|OBJ|BG|SET|PRODUCT|DATA|MAP)_\\d{3}\\s*\\(([^)]+)\\)')
_MODEL_TEXT_SKIP_KEYS = {'logical_id', 'id', 'media_id', 'asset_id', 'time', 'entity_id'}
MODULE_POOL = [{'id': 'context', 'purpose': 'environment, canvas, habitat, map scope, mood'}, {'id': 'objects', 'purpose': 'props/tools/products/labels that matter during the beat'}, {'id': 'camera', 'purpose': 'sh... [truncated]
CONTENT_TYPE_PROFILES = {'narrative_dialogue': {'visualization_type': 'CINEMATIC', 'control_key': 'cinematic_dialogue', 'module_ids': ['context', 'objects', 'camera', 'lighting', 'visual_action', 'effects', 'dialogue', 'cons... [truncated]
_PERFORMANCE_SIGNAL_RE = re.compile('\\b(?:smil\\w*|grin\\w*|frown\\w*|laugh\\w*|cry\\w*|gaze\\w*|look\\w*|expression\\w*|excited|joyful|confident|worried|angry|sad|happy|cười|ánh\\s+mắt|nhìn|hào\\s+hứng|vui|buồn|giận|lo\\s+l... [truncated]
_MODEL_BEAT_ORDER = ('time', 'context', 'camera', 'visual_action', 'objects', 'lighting', 'effects', 'motion_graphics', 'dialogue', 'narration', 'constraints')
WIRE_NOISE_KEYS = ('module_ids', 'content_type', 'visualization_type', 'source_time_range', 'duration_seconds', 'module_selection_reason', 'human_presence', 'human_presence_reason', 'speech_reason', 'narrator_voice', '... [truncated]
__all__ = ['MODULE_POOL', 'CONTENT_TYPE_PROFILES', 'WIRE_NOISE_KEYS', 'build_global_plan', 'build_model_facing_scene_payload', 'render_video_wire_as_natural_text', 'compact_timeline_for_model', 'prune_model_fac... [truncated]

# --- Top-Level Functions ---
def _as_list(value: 'Any') -> 'list':
    pass

def clean_model_facing_scene_text(text: 'str') -> 'str':
    pass

def _value_to_text(value: 'Any', *, skip_keys: 'set | None' = None) -> 'str':
    pass

def content_type_profile(content_type: 'str | None') -> 'Dict[str, Any]':
    pass

def module_ids_for_content_type(content_type: 'str | None') -> 'List[str]':
    pass

def control_key_for_content_type(content_type: 'str | None') -> 'str':
    pass

def build_global_plan(extra_rules: 'List[str] | None' = None) -> 'Dict[str, Any]':
    pass

def _scene_windows(clip_duration_seconds: 'int', count: 'int') -> 'List[str]':
    pass

def _window_to_source_range(window: 'str') -> 'str':
    pass

def build_video_scene_response_blueprint(*, duration: 'int', scene_count: 'int', clip_duration_seconds: 'int' = 8, source: 'str' = 'video', narrator_mode: 'bool' = False) -> 'Dict[str, Any]':
    pass

def _apply_clone_narrator_blueprint(envelope: 'Dict[str, Any]') -> 'None':
    """Narrator-mode variant of the CLONE blueprint: every scene declares
    ``audio_mode``; source editorial narration becomes scene-level
    ``narrator_voice`` (re-voiced by the app's TTS) instead of the model-voiced
    ``narration`` beat (which made Veo invent a drifting voice per clip)."""
    pass

def _generative_blueprint(duration: 'int', scene_count: 'int', clip: 'int', narrator_mode: 'bool' = False) -> 'Dict[str, Any]':
    pass

def build_video_scene_module_contract(clip_duration_seconds: 'int' = 8, source: 'str' = 'video', narrator_mode: 'bool' = False, adaptive_timeline: 'bool' = False, render_text_allowed: 'bool' = True) -> 'str':
    pass

def _timeline_windows(clip_duration_seconds: 'int') -> 'List[str]':
    pass

def _first_entity(scene: 'Dict[str, Any]', *groups: 'str') -> 'str':
    pass

def _control_body(scene: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _narration_event(scene: 'Dict[str, Any]') -> 'list':
    pass

def _sound_event(scene: 'Dict[str, Any]', body: 'Dict[str, Any]') -> 'list':
    pass

def derive_audio_from_timeline(scene: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _profile_key_for_scene(scene: 'Dict[str, Any]') -> 'str':
    pass

def _timeline_from_director_like(scene: 'Dict[str, Any]', source: 'Dict[str, Any]') -> 'List[Dict[str, Any]]':
    pass

def _timeline_from_visual(scene: 'Dict[str, Any]', clip_duration_seconds: 'int') -> 'List[Dict[str, Any]]':
    pass

def ensure_scene_module_contract(scene: 'Dict[str, Any]', clip_duration_seconds: 'int' = 8) -> 'Dict[str, Any]':
    pass

def build_timeline_from_control(scene: 'Dict[str, Any]', clip_duration_seconds: 'int' = 8) -> 'List[Dict[str, Any]]':
    pass

def compile_scene_visual_from_timeline(scene: 'Dict[str, Any]') -> 'str':
    pass

def _timeline_has_timed_audio(timeline: 'Any') -> 'bool':
    pass

def _wire_fragment(value: 'Any') -> 'str':
    pass

def _append_distinct(parts: 'List[str]', value: 'Any') -> 'None':
    pass

def _named_actor(item: 'Dict[str, Any]') -> 'str':
    pass

def _has_performance_signal(parts: 'List[str]') -> 'bool':
    pass

def compact_timeline_for_model(timeline: 'Any') -> 'List[Dict[str, Any]]':
    pass

def prune_model_facing_value(value: 'Any') -> 'Any':
    """Recursively remove empty model-facing fields without changing real values."""
    pass

def timeline_has_dialogue(timeline: 'Any') -> 'bool':
    pass

def timeline_has_person(timeline: 'Any') -> 'bool':
    pass

def _apply_scene_rules(scene: 'Dict[str, Any]', timeline: 'Any', *, has_person: 'bool') -> 'None':
    pass

def timeline_dialogue_speakers(timeline: 'Any') -> 'List[str]':
    pass

def relabel_dialogue_line_to_says(timeline: 'Any') -> 'None':
    pass

def build_model_facing_scene_payload(scene: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _natural_label(value: 'Any') -> 'str':
    pass

def _natural_scalar(value: 'Any') -> 'str':
    pass

def _natural_parts(value: 'Any', *, key_hint: 'str' = '') -> 'List[str]':
    """Flatten one clean model-facing value without exposing JSON syntax.

    The structured payload remains the source of truth. This helper is only a
    final wire projection for generative video models, which follow concise
    natural instructions more reliably than a deeply nested JSON dump."""
    pass

def render_video_wire_as_natural_text(payload: 'Dict[str, Any]') -> 'str':
    """Render clean scene JSON as semi-natural text immediately before Veo.

    ``payload`` is never mutated and remains the canonical JSON snapshot used by
    validation, history and regeneration. The projection keeps timed beats,
    dialogue, reference identity, style and hard rules while removing braces,
    internal field names and nested-schema noise from the actual model prompt."""
    pass
