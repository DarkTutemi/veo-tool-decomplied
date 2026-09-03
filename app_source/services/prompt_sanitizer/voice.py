"""
Decompiled / Reconstructed Module: services.prompt_sanitizer.voice
Source PyC: voice.pyc

Docstring:
Voice-marker sanitizers for Flow voice-lock prompt paths.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional
_MULTI_SPACE = re.compile('\\s{2,}')
_DANGLING_PUNCT = re.compile('\\s+([,.;:!?])')
_SPEECH_VERBS = 'says|said|speaks|asks|replies|responds|whispers|shouts|calls|cries|laughs|noi|nói|hoi|hỏi|tra loi|trả lời'
_CHAR_VOICE_BEFORE_VERB = re.compile('\\bCHAR_\\d{3}\\s*\\((?P<inner>[^)]{3,240})\\)\\s*(?P<verb>says|said|speaks|asks|replies|responds|whispers|shouts|calls|cries|laughs|noi|nói|hoi|hỏi|tra loi|trả lời)\\b', re.IGNORECASE)
_NAME_VOICE_BEFORE_VERB = re.compile('(?P<speaker>\\b[^()\\n,\\":]{1,90}?)\\s*\\((?P<desc>[^)]{3,240})\\)\\s*(?P<verb>says|said|speaks|asks|replies|responds|whispers|shouts|calls|cries|laughs|noi|nói|hoi|hỏi|tra loi|trả lời)\\... [truncated]
_NAME_VOICE_AFTER_VERB = re.compile('(?P<speaker>\\b[^()\\n,\\":]{1,90}?)\\s*(?P<verb>says|said|speaks|asks|replies|responds|whispers|shouts|calls|cries|laughs|noi|nói|hoi|hỏi|tra loi|trả lời)\\s*\\((?P<desc>[^)]{3,240})\\)',... [truncated]
_NARRATOR_SPEAKERS = {'loi ke chuyen', 'narrator', 'nguoi ke chuyen', 'voiceover', 'voice over', 'nguoi dan chuyen', 'loi dan'}

# --- Top-Level Functions ---
def _normalize_speaker_label(label: str) -> str:
    pass

def _is_narrator_speaker(label: str) -> bool:
    pass

def strip_voice_lock_speech_descriptors(text: Optional[str]) -> str:
    pass
