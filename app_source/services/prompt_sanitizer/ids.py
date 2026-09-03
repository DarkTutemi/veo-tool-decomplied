"""
Decompiled / Reconstructed Module: services.prompt_sanitizer.ids
Source PyC: ids.pyc

Docstring:
Entity-token sanitizers for prompt text.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional
_TOKEN_PATTERN = re.compile('\\b(CHAR|BG|OBJ|SET|PROP|ENV|LOC)_\\d{3}\\b')
_TOKEN_WITH_PAREN = re.compile('\\b(CHAR|BG|OBJ|SET|PROP|ENV|LOC)_\\d{3}\\s*\\(([^)]+)\\)')
_MULTI_SPACE = re.compile('\\s{2,}')
_DANGLING_PUNCT = re.compile('\\s+([,.;:!?])')

# --- Top-Level Functions ---
def strip_entity_tokens(text: Optional[str]) -> str:
    pass
