"""
Decompiled / Reconstructed Module: services.video_core.policies
Source PyC: policies.pyc

Docstring:
Tab-specific policy switches for the unified scene compiler.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Tuple = typing.Tuple
NO_VOICE_RULE = 'No speech. No dialogue. No lip movement. No mouth opening. No vocal sounds. External audio is handled outside the generated video.'
NO_HUMAN_RULE = 'No people. No humans. No characters. No faces. No silhouettes of people. No hands. No body parts unless a locked character reference is explicitly attached.'
HANDS_ONLY_RULE = 'Anonymous hands only when the timeline explicitly requires product manipulation. No face, head, torso, full body, identifiable person, presenter, or extra character.'
NO_DIALOGUE_RULE = 'No spoken dialogue in this scene. No character speaks, narrates, or voices over. No lip movement or mouth opening for speech. Do NOT invent any speech, dialogue, or voiceover. Keep only ambient sound... [truncated]
VERBATIM_DIALOGUE_RULE = 'Speak every dialogue and narration line EXACTLY as written, word for word, in its ORIGINAL language. Do NOT translate, dub, localize, or change the language of any spoken line (for example, a line wr... [truncated]
NO_MUSIC_RULE = "ABSOLUTE MUSIC BAN — the generated video must contain ZERO music of any kind. No background music, score, soundtrack, instrumental, melody, motif, jingle, song, singing, humming, beat, rhythm, drums,... [truncated]
EXTERNAL_NARRATOR_RULE = 'The app adds an off-screen narrator in post-production. The generated video must contain no speech, dialogue, narration, singing, vocal sounds, lip-sync, music, score, soundtrack, jingle, or rhythm c... [truncated]
TIMED_DIALOGUE_ONLY_RULE = 'Only the exact timed character dialogue written in the timeline may be spoken. Do not add an off-screen narrator, voiceover, extra dialogue, singing, music, score, soundtrack, jingle, or rhythm cue. ... [truncated]
NO_TEXT_OVERLAY_RULE = 'No subtitles. No captions. No on-screen text bars, lower-thirds, or title cards. No burned-in narration or dialogue text, no watermark overlays. Spoken lines are audio only — never render the spoken ... [truncated]
_POLICIES = {'master': ScenePolicy(name='master', force_silent_video=False, no_human_without_characters=False, no_speech_without_dialogue=True, lock_dialogue_language=True, strip_timed_audio_summary=True, enforce... [truncated]

# --- Class: ScenePolicy ---
class ScenePolicy:
    """ScenePolicy(name: 'str', force_silent_video: 'bool' = False, no_human_without_characters: 'bool' = False, no_speech_without_dialogue: 'bool' = False, lock_dialogue_language: 'bool' = False, strip_timed_audio_summary: 'bool' = True, enforce_audio_ownership: 'bool' = False, rules: 'Tuple[str, ...]' = ())"""
    force_silent_video = False
    no_human_without_characters = False
    no_speech_without_dialogue = False
    lock_dialogue_language = False
    strip_timed_audio_summary = True
    enforce_audio_ownership = False
    rules = ()

    def __init__(self, name: 'str', force_silent_video: 'bool' = False, no_human_without_characters: 'bool' = False, no_speech_without_dialogue: 'bool' = False, lock_dialogue_language: 'bool' = False, strip_timed_audio_summary: 'bool' = True, enforce_audio_ownership: 'bool' = False, rules: 'Tuple[str, ...]' = ()) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def get_scene_policy(name: 'str | None') -> 'ScenePolicy':
    pass
