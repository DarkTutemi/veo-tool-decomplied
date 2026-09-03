"""
Decompiled / Reconstructed Module: services.prompt_sanitizer.risky_names
Source PyC: risky_names.pyc

Docstring:
Convert risky/famous character names to safe generic stand-in names.

Google Labs blocks generating real, religious, historical, or copyrighted
figures (HTTP 400 PUBLIC_ERROR_UNSAFE_GENERATION / PUBLIC_ERROR_PROMINENT_
PEOPLE_FILTER). When a clone/master script names a character e.g. "The Buddha"
the chargen image and the video both fail policy.

This module maps such names to SHORT GENERIC names ("The Buddha" -> "the monk")
so the character stays a coherent, usable named entity but passes policy. It is
the single source of truth for famous-name → generic conversion, shared by:
  - the deterministic policy-fix (services/shared/ai/ai_providers.py)
  - any proactive entity-name sanitization

Keep replacements SHORT and name-like (not long descriptions), so they can be
dropped into a prompt or a character `name` field without breaking structure.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
List = typing.List
Tuple = typing.Tuple
_RAW_RULES = [('\\bgautama(?:\\s+buddha)?\\b', 'the monk'), ('\\b(?:the\\s+|lord\\s+)?buddha\\b', 'the monk'), ('\\bth[íi]ch\\s+ca(?:\\s+mâu\\s+ni)?\\b', 'the monk'), ('\\b(?:đức\\s+|đ?ức\\s+)?phật(?:\\s+tổ)?\\b',... [truncated]
_RULES = [(re.compile('\\bgautama(?:\\s+buddha)?\\b', re.IGNORECASE), 'the monk'), (re.compile('\\b(?:the\\s+|lord\\s+)?buddha\\b', re.IGNORECASE), 'the monk'), (re.compile('\\bth[íi]ch\\s+ca(?:\\s+mâu\\s+ni)?... [truncated]
_COLLAPSE = [re.compile('\\b(the\\ monk)(?:\\s+the\\ monk\\b)+', re.IGNORECASE), re.compile('\\b(the\\ bodhisattva)(?:\\s+the\\ bodhisattva\\b)+', re.IGNORECASE), re.compile('\\b(the\\ preacher)(?:\\s+the\\ preac... [truncated]
_SKIP_KEY_HINTS = ('base64', 'b64', 'image_data', 'thumbnail', 'fife', 'media_name', 'mediaid', 'media_id')

# --- Top-Level Functions ---
def sanitize_risky_names(text: 'str') -> 'str':
    pass

def has_risky_name(text: 'str') -> 'bool':
    """True when *text* contains a known risky famous/religious name."""
    pass

def sanitize_character_name(name: 'str') -> 'str':
    pass

def sanitize_result_data_names(result_data):
    """Recursively convert risky names in a clone/master result dict.

    Renames "The Buddha" → "the monk" across the ENTITY library AND scene prose
    so chargen, video and voice all reference the same safe name. Idempotent.
    Skips base64/binary-bearing fields. Returns a new structure; the original is
    left unmodified."""
    pass
