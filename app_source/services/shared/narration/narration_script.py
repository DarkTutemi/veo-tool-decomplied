"""
Decompiled / Reconstructed Module: services.shared.narration.narration_script
Source PyC: narration_script.pyc

Docstring:
Stage A — collect the narrator script from scenes + word-budget planning (§5, §6.1).

The LLM writes NO timestamps anywhere: scene order + ``clip_duration`` is all it
gets. This module walks the scenes in order, takes ``narrator_voice.says`` from
every ``audio_mode == "narration"`` scene, and joins them with a blank line —
one paragraph per scene. Dialogue/ambient scenes contribute NOTHING to the script;
they become structural gaps later (narration_edit).

The word budget is a PLANNING AID, never a gate: it keeps a measured span inside
the clip quantization range (max tier 10s). The measured span defines the scene
length, not the reverse.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
AUDIO_MODE_NARRATION = 'narration'
AUDIO_MODE_DIALOGUE = 'dialogue'
AUDIO_MODE_AMBIENT = 'ambient'
AUDIO_MODE_MIXED = 'mixed'
_AUDIO_MODES = ('narration', 'dialogue', 'ambient', 'mixed')
NARRATED_MODES = ('narration', 'mixed')
_TERMINAL_CHARS = '.!?…。！？'
PARAGRAPH_PAUSE_TAG = '[pause 0.35s]'
PARAGRAPH_JOIN = '\n\n[pause 0.35s]\n\n'
_DELIVERY_TAG_MAX_CHARS = 180
_WPS_PLANNER = {'vi': {'default': 2.2}, 'en': {'default': 2.4, 'news': 2.0}, 'es': {'default': 3.0}, 'it': {'default': 3.0}, 'de': {'default': 2.15}, 'zh': {'default': 3.6}}
_DEFAULT_WPS = 2.2
_BREATHING_ROOM = 0.9
_MAX_WPS_SAMPLES = 50
_MIN_WPS_SAMPLES = 3

# --- Class: NarrationScriptError ---
class NarrationScriptError(ValueError):
    """Scene list violates the narrator contract — refuse BEFORE spending TTS."""
    def __init__(self, problems: 'List[str]'):
        pass


# --- Class: NarrationParagraph ---
class NarrationParagraph:
    """NarrationParagraph(index: 'int', scene_id: 'Any', text: 'str', emotion: 'str' = '', delivery_tag: 'str' = '')"""
    emotion = ''
    delivery_tag = ''
    tts_text = <property object at 0x00000264E41DEC00>

    def __init__(self, index: 'int', scene_id: 'Any', text: 'str', emotion: 'str' = '', delivery_tag: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: NarrationScript ---
class NarrationScript:
    """NarrationScript(paragraphs: 'List[NarrationParagraph]', emotion: 'str' = '', warnings: 'List[str]' = <factory>)"""
    emotion = ''
    script_text = <property object at 0x00000264E41DEDE0>

    def __init__(self, paragraphs: 'List[NarrationParagraph]', emotion: 'str' = '', warnings: 'List[str]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _clean_delivery_tag(value: 'Any') -> 'str':
    pass

def _timeline_has_dialogue(scene: 'Dict[str, Any]') -> 'bool':
    pass

def _narrator_says(scene: 'Dict[str, Any]') -> 'str':
    pass

def scene_audio_mode(scene: 'Dict[str, Any]') -> 'str':
    pass

def _ensure_terminal(text: 'str') -> 'str':
    pass

def collect_script(scenes: 'List[Dict[str, Any]]', default_emotion: 'str' = '') -> 'NarrationScript':
    pass

def _lang_key(language: 'str') -> 'str':
    pass

def wps_for(language: 'str', style: 'str' = '') -> 'float':
    pass

def count_words(text: 'str', language: 'str' = '') -> 'int':
    """zh counts CJK characters (chars/s standard); everything else whitespace
    tokens (Vietnamese: syllable = word, which IS the whitespace token)."""
    pass

def word_budget(clip_duration_s: 'float', language: 'str', style: 'str' = '', wps: 'Optional[float]' = None) -> 'int':
    pass

def _default_wps_store() -> 'str':
    pass

def _load_wps_store(store_path: 'str') -> 'Dict[str, Any]':
    pass

def record_wps_sample(voice: 'str', language: 'str', words: 'int', seconds: 'float', store_path: 'str' = '') -> 'Optional[float]':
    pass

def learned_wps(voice: 'str', language: 'str', store_path: 'str' = '', min_samples: 'int' = 3) -> 'Optional[float]':
    pass

def effective_wps(language: 'str', style: 'str' = '', voice: 'str' = '', store_path: 'str' = '') -> 'float':
    pass
