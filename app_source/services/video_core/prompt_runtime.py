"""
Decompiled / Reconstructed Module: services.video_core.prompt_runtime
Source PyC: prompt_runtime.pyc

Docstring:
Runtime prompt helpers shared by video tabs and dispatch.

These helpers sit at the edge between normalized scene data and the final
dispatcher/API payload. They do not know about UI tabs, accounts, or queues.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['NO_HUMAN_RULES', 'NO_VOICE_RULES', 'SCENE_STRIP_KEYS', 'clean_asset_library_for_veo3', 'generate_character_summary', 'generate_setting_summary', 'inject_jit_voice_into_timeline', 'inject_voice_into_dialogue', 'inject_voice_into_scene', 'prompt_text_for_job_record', 'prompt_text_from_payload', 'prompt_text_from_prompt_data', 'strip_asset_ids', 'strip_asset_ids_for_wire', 'strip_ids_from_spoken_text', 'strip_scene_for_veo3']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
NO_VOICE_RULES = 'No voice. No speech. No talking. No dialogue. No whispering. No lip movement. No mouth opening. No vocal sounds. Characters are completely silent. Show emotions through facial expressions and body la... [truncated]
NO_HUMAN_RULES = 'No people. No humans. No characters. No faces. No silhouettes of people. No hands. No body parts. Pure environment, scenery, or objects only.'
SCENE_STRIP_KEYS = ('action_extend', 'extend_of', 'extend', 'scene_id', 'visualization_type', 'audio_topic', 'style_video', 'camera_movement', 'style_structure', 'style_note', 'visual_quality', 'character_lock', 'enviro... [truncated]
__all__ = ['NO_HUMAN_RULES', 'NO_VOICE_RULES', 'SCENE_STRIP_KEYS', 'clean_asset_library_for_veo3', 'generate_character_summary', 'generate_setting_summary', 'inject_jit_voice_into_timeline', 'inject_voice_into_... [truncated]

# --- Top-Level Functions ---
def strip_ids_from_spoken_text(text: 'str') -> 'str':
    pass

def inject_voice_into_dialogue(dialogue: 'str', filtered_library: 'dict') -> 'str':
    pass

def inject_voice_into_scene(scene: 'dict', filtered_library: 'dict', voice_language: 'str' = 'en', inject_voice_descriptions: 'bool' = True, inject_narrator_voice_descriptions: 'Optional[bool]' = None) -> 'dict':
    pass

def inject_jit_voice_into_timeline(scene: 'dict', entity_library: 'dict') -> 'dict':
    """JIT voice for timeline scenes: attach each speaker's voice tone to the beat.

    When voice-lock is OFF, the video model itself speaks the lines — so the
    speaking character's / narrator's voice descriptor (authored by the AI in
    ``entity_library.characters[].voice`` and ``entity_library.narrators[].voice``)
    must travel with the spoken line. This walks ``scene.timeline[].dialogue`` and
    ``...narration`` and adds a ``voice`` field next to each ``{speaker, line}`` it
    can resolve. Mutates and returns ``scene``. No-op without a timeline or voice
    data, and never overwrites a ``voice`` the AI already wrote.

    (Voice-lock ON binds the voice through the Flow entity instead — no JIT here.)"""
    pass

def strip_scene_for_veo3(scene: 'dict') -> 'dict':
    pass

def strip_asset_ids(prompt_str: 'str') -> 'str':
    pass

def strip_asset_ids_for_wire(prompt_str: 'str') -> 'str':
    pass

def prompt_text_from_payload(payload: 'dict', *, indent: 'int | None' = None) -> 'str':
    pass

def prompt_text_from_prompt_data(prompt_data: 'dict', *, indent: 'int | None' = None) -> 'str':
    pass

def prompt_text_for_job_record(prompt_data: 'dict', *, indent: 'int | None' = 2) -> 'str':
    pass

def clean_asset_library_for_veo3(asset_library: 'dict', *, chars_with_ref: 'set | None' = None, keep_voice_lock: 'bool' = False) -> 'dict':
    pass

def generate_character_summary(character: 'dict') -> 'str':
    pass

def generate_setting_summary(setting: 'dict') -> 'str':
    pass
