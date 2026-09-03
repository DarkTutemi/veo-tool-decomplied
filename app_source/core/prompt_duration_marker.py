"""
Decompiled / Reconstructed Module: core.prompt_duration_marker
Source PyC: prompt_duration_marker.pyc

Docstring:
Prompt duration marker parsing utilities.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
SUPPORTED_PROMPT_DURATIONS = (4, 6, 8, 10)
_MARKER_RE = re.compile('^\\s*\\[\\s*(?:(?:duration|time)\\s*[:=]\\s*)?(4|6|8|10)\\s*s\\s*\\]\\s*', re.IGNORECASE)

# --- Class: PromptDurationMarker ---
class PromptDurationMarker(dict):
    pass


# --- Top-Level Functions ---
def format_duration_marker(duration_seconds: 'Optional[int]') -> 'str':
    pass

def parse_prompt_duration_marker(text: 'str') -> 'PromptDurationMarker':
    pass
