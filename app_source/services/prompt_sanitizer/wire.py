"""
Decompiled / Reconstructed Module: services.prompt_sanitizer.wire
Source PyC: wire.pyc

Docstring:
Final API-bound prompt sanitizer.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
_ASSET_ID_RE = re.compile('^(?:CHAR|OBJ|SET|BG)_\\d{3}$')
_ASSET_ID_KEY_RE = re.compile('^(?:id|asset_id|entity_id|character_id|object_id|setting_id|background_id)$', re.IGNORECASE)
_ASSET_ID_LIST_KEY_RE = re.compile('^(?:scene_asset_ids|referenced_ids|asset_refs|entity_refs|character_refs|object_refs|setting_refs|background_refs)$', re.IGNORECASE)
_NARRATOR_KEY_RE = re.compile('^(?:narrator|narrator_voice|tts_narration|voiceover|voice_over)$', re.IGNORECASE)
_NARRATION_AUDIO_TYPES = {'narrator', 'narration', 'voiceover', 'voice_over'}
_SPEECH_VERBS = 'says|said|speaks|asks|replies|responds|whispers|shouts|calls|cries|laughs|noi|nói|hoi|hỏi|tra loi|trả lời|narrates'
_CHAR_SPEAKER_MARKER = re.compile('\\bCHAR_\\d{3}\\s*\\((?P<inner>[^)]{1,260})\\)\\s*(?P<verb>says|said|speaks|asks|replies|responds|whispers|shouts|calls|cries|laughs|noi|nói|hoi|hỏi|tra loi|trả lời|narrates)\\b', re.IGNOR... [truncated]

# --- Top-Level Functions ---
def _strip_entity_tokens_preserving_voice_markers(text: str) -> str:
    pass

def _sanitize_wire_value(value, *, strip_voice_descriptors: bool):
    pass

def sanitize_wire_prompt(prompt_str: str, *, strip_voice_descriptors: bool = True) -> str:
    pass
