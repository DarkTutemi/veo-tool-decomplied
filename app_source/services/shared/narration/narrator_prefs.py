"""
Decompiled / Reconstructed Module: services.shared.narration.narrator_prefs
Source PyC: narrator_prefs.pyc

Docstring:
Narrator preferences — shared, Qt-free store + voice resolution.

The narrator control (master + clone + future features) shares ONE identity:
which voice reads the story, chosen how. Two modes:

  - "auto"   — the system picks a fitting voice for the content genre/language.
    v1 = deterministic rule table over the 30 Gemini voice profiles (below);
    the master/clone wiring may later let the LLM pick and pass its choice
    through ``resolve_narrator_voice(preferred=...)`` — the rule table stays as
    the deterministic fallback so auto NEVER fails.
  - "manual" — the user picked an exact Gemini voice.

Persistence rides ``json_settings_manager`` under its own category (the
voice_studio state has a whitelist in ``voice_service.apply_state`` — narrator
keys deliberately do NOT go there).

Qt-free on purpose: the pipeline (narration_service, later master/clone
dispatch) calls ``resolve_narrator_voice`` without any controller.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
SETTINGS_CATEGORY = 'narrator'
VOICE_MODE_AUTO = 'auto'
VOICE_MODE_MANUAL = 'manual'
_DEFAULT_STATE = {'voice_mode': 'auto', 'voice': '', 'emotion': '', 'voice2': '', 'asr_offer_dismissed': ''}
NARRATOR_IDENTITY_KEYS = ('voice_mode', 'voice', 'voice2', 'emotion')
_GENRE_CANDIDATES = [(('documentary', 'explainer', 'tài liệu', 'khoa học', 'science', 'education', 'hướng dẫn', 'tutorial'), ['Rasalgethi', 'Charon', 'Sadaltager', 'Orus']), (('storytelling', 'story', 'kể chuyện', 'truyệ... [truncated]
_DEFAULT_CANDIDATES = ['Charon', 'Kore', 'Rasalgethi']
_PREFER_MULTI_LANGS = {'ms', 'hi', 'pt', 'th', 'ru', 'vi', 'ur', 'id', 'ar', 'bn', 'tl', 'it'}
DIRECTION_STYLE_PRESETS = ('Vocal Smile', 'Newscaster', 'Whisper', 'Empathetic', 'Promo/Hype', 'Deadpan')
DIRECTION_PACE_PRESETS = ('Natural', 'Rapid Fire', 'The Drift', 'Staccato')
_DIRECTION_KEYS = ('style', 'pace', 'accent')
_DIRECTION_MAX_CHARS = 80
_VOICE_INTENT_TEXT_KEYS = ('tone', 'pace', 'credibility_role', 'accent', 'reason')
_VOICE_INTENT_MAX_CHARS = 160
_VOICE_GENDER_ALIASES = {'m': 'male', 'man': 'male', 'nam': 'male', 'male': 'male', 'f': 'female', 'woman': 'female', 'nữ': 'female', 'nu': 'female', 'female': 'female', 'neutral': 'neutral', 'nonbinary': 'neutral', 'non-bin... [truncated]
_VOICE_LIFE_STAGE_ALIASES = {'child': 'child', 'kid': 'child', 'teen': 'teen', 'teenager': 'teen', 'young': 'young_adult', 'youthful': 'young_adult', 'young_adult': 'young_adult', 'young adult': 'young_adult', 'adult': 'adult', ... [truncated]
_instance = None
_instance_lock = <unlocked _thread.lock object at 0x00000264E41FA2C0>

# --- Class: NarratorPrefs ---
class NarratorPrefs:
    """Process-wide narrator preference store (thread-safe, whitelisted keys)."""
    def __init__(self, settings: 'Any' = None) -> 'None':
        pass

    def _mgr(self) -> 'Any':
        pass

    def get_state(self) -> 'Dict[str, Any]':
        pass

    def apply_state(self, delta: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def resolve_voice(self, language: 'str' = '', genre_hint: 'str' = '', preferred: 'str' = '', voice_intent: 'Optional[Dict[str, Any]]' = None, state: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
        pass

    def resolve_voices(self, language: 'str' = '', genre_hint: 'str' = '', preferred: 'str' = '', preferred2: 'str' = '', voice_intent: 'Optional[Dict[str, Any]]' = None, state: 'Optional[Dict[str, Any]]' = None) -> 'List[Dict[str, Any]]':
        pass


# --- Top-Level Functions ---
def clean_narrator_voice_intent(raw: 'Any') -> 'Dict[str, str]':
    pass

def clean_narrator_direction(raw: 'Any') -> 'Dict[str, str]':
    pass

def _lang_key(language: 'str') -> 'str':
    pass

def _voice_profiles() -> 'List[Dict[str, Any]]':
    pass

def _catalog_voice_name(raw: 'Any') -> 'str':
    pass

def voice_catalog_prompt_block() -> 'str':
    """The 30-voice Gemini catalog as a prompt block, so an LLM can pick the
    narrator voice itself (owner: "LLM biết danh sách, biết giọng nào phù hợp").
    The picked name flows back through ``content_profile.narrator_voice_suggestion``
    → ``resolve_narrator_voices(preferred=...)`` — the deterministic table stays
    the fallback, so a hallucinated name can never break voice resolution."""
    pass

def auto_pick_second_voice(language: 'str' = '', genre_hint: 'str' = '', first: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
    """Contrasting second narrator: same genre table, opposite gender to ``first``
    (two same-gender narrators blur together in a voiceover)."""
    pass

def _profile_life_stages(profile: 'Dict[str, Any]') -> 'set[str]':
    pass

def _intent_style_score(profile: 'Dict[str, Any]', intent: 'Dict[str, str]') -> 'int':
    pass

def auto_pick_voice(language: 'str' = '', genre_hint: 'str' = '', voice_intent: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
    """Deterministic voice pick for (language, genre) — the auto-mode fallback.

    Returns ``{name, style, gender, lang, director, reason}``; never raises on
    unknown genre/language (falls back to a safe informative voice)."""
    pass

def get_narrator_prefs() -> 'NarratorPrefs':
    pass

def overlay_narrator_state(snapshot: 'Optional[Dict[str, Any]]' = None, live: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
    pass

def snapshot_narrator_identity(prefs: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, str]':
    pass

def resolve_narrator_voice(language: 'str' = '', genre_hint: 'str' = '', preferred: 'str' = '', voice_intent: 'Optional[Dict[str, Any]]' = None, state: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
    pass

def resolve_narrator_voices(language: 'str' = '', genre_hint: 'str' = '', preferred: 'str' = '', preferred2: 'str' = '', voice_intent: 'Optional[Dict[str, Any]]' = None, state: 'Optional[Dict[str, Any]]' = None) -> 'List[Dict[str, Any]]':
    pass
