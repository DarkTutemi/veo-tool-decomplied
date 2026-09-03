"""
Decompiled / Reconstructed Module: services.video_core.compiler
Source PyC: compiler.pyc

Docstring:
Unified model-facing scene prompt compiler.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
WIRE_NOISE_KEYS = ('module_ids', 'content_type', 'visualization_type', 'source_time_range', 'duration_seconds', 'module_selection_reason', 'human_presence', 'human_presence_reason', 'speech_reason', 'narrator_voice', '... [truncated]
EXTERNAL_NARRATOR_RULE = 'The app adds an off-screen narrator in post-production. The generated video must contain no speech, dialogue, narration, singing, vocal sounds, lip-sync, music, score, soundtrack, jingle, or rhythm c... [truncated]
HANDS_ONLY_RULE = 'Anonymous hands only when the timeline explicitly requires product manipulation. No face, head, torso, full body, identifiable person, presenter, or extra character.'
NO_DIALOGUE_RULE = 'No spoken dialogue in this scene. No character speaks, narrates, or voices over. No lip movement or mouth opening for speech. Do NOT invent any speech, dialogue, or voiceover. Keep only ambient sound... [truncated]
NO_HUMAN_RULE = 'No people. No humans. No characters. No faces. No silhouettes of people. No hands. No body parts unless a locked character reference is explicitly attached.'
NO_MUSIC_RULE = "ABSOLUTE MUSIC BAN — the generated video must contain ZERO music of any kind. No background music, score, soundtrack, instrumental, melody, motif, jingle, song, singing, humming, beat, rhythm, drums,... [truncated]
NO_TEXT_OVERLAY_RULE = 'No subtitles. No captions. No on-screen text bars, lower-thirds, or title cards. No burned-in narration or dialogue text, no watermark overlays. Spoken lines are audio only — never render the spoken ... [truncated]
TIMED_DIALOGUE_ONLY_RULE = 'Only the exact timed character dialogue written in the timeline may be spoken. Do not add an off-screen narrator, voiceover, extra dialogue, singing, music, score, soundtrack, jingle, or rhythm cue. ... [truncated]
VERBATIM_DIALOGUE_RULE = 'Speak every dialogue and narration line EXACTLY as written, word for word, in its ORIGINAL language. Do NOT translate, dub, localize, or change the language of any spoken line (for example, a line wr... [truncated]
_R2V_ENTITY_FIELDS = ('name', 'summary')
_NON_MODEL_ENTITY_KEYS = frozenset({'anchor_reason', 'anchor_ref', 'anchor_kind', 'locked', 'is_locked', 'reference_images', 'asset_ref', 'library_media_id', 'reference_image', 'reference', 'media_id', 'chargen_asset_ref', 'v... [truncated]

# --- Top-Level Functions ---
def _as_list(value: 'Any') -> 'List[Any]':
    pass

def _item_id(item: 'Any') -> 'str':
    pass

def _entity_groups(entity_library: 'Dict[str, Any]') -> 'Dict[str, List[Dict[str, Any]]]':
    pass

def _entity_map(entity_library: 'Dict[str, Any]') -> 'Dict[str, Dict[str, Any]]':
    pass

def _model_entity_entry(item: 'Dict[str, Any]', *, full: 'bool' = False) -> 'Dict[str, Any]':
    pass

def _build_entity_context(entity_library: 'Dict[str, Any]', plan: 'ReferencePlan', scene: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
    pass

def _timeline_has_audio(timeline: 'Any') -> 'bool':
    pass

def _timeline_has_subjects(timeline: 'Any') -> 'bool':
    """A non-empty `subjects` beat = one-time human/character described in the scene.

    These aren't locked entity references, but they ARE intended people, so they
    must be allowed to appear (NO_HUMAN only guards against hallucinated humans in
    scenes that describe none)."""
    pass

def _build_rules(policy: 'ScenePolicy', reference_plan: 'ReferencePlan', *, has_human_subjects: 'bool' = False, has_dialogue: 'bool' = False, audio_mode: 'str' = '', human_presence: 'str' = '') -> 'List[str]':
    pass

def _metadata_media_library_id(meta: 'Dict[str, Any]') -> 'str':
    pass

def _metadata_image_media_ids(meta: 'Dict[str, Any]') -> 'List[str]':
    pass

def _metadata_image_base64_refs(character_id: 'str', meta: 'Dict[str, Any]') -> 'List[Dict[str, str]]':
    pass

def _build_flow_character_specs(*, entity_library: 'Dict[str, Any]', reference_plan: 'ReferencePlan', character_metadata: 'Dict[str, Dict[str, Any]]', enabled: 'bool', model_key: 'str', scene: 'Dict[str, Any]', identity_scope: 'str') -> 'List[Dict[str, Any]]':
    pass

def _bound_flow_character_refs(entity_library: 'Dict[str, Any]', reference_plan: 'ReferencePlan') -> 'tuple[List[str], Dict[str, str]]':
    pass

def compile_video_scene_prompt(*, scene: 'Dict[str, Any]', entity_library: 'Optional[Dict[str, Any]]' = None, anchor_plan: 'Optional[Dict[str, Any]]' = None, policy: 'Optional[ScenePolicy]' = None, tab_source: 'str' = 'master_prompt', model_key: 'str' = '', aspect_ratio: 'str' = '16:9', duration_seconds: 'Optional[int]' = None, style_override: 'str' = '', camera_override: 'str' = '', character_metadata: 'Optional[Dict[str, Dict[str, Any]]]' = None, enable_char_consistency: 'bool' = False, enable_anchor_consistency: 'bool' = False, enable_flow_voice_lock: 'bool' = False, total_ref_limit: 'Optional[int]' = None, character_ref_limit: 'Optional[int]' = None, identity_scope: 'str' = '') -> 'CompileResult':
    pass
