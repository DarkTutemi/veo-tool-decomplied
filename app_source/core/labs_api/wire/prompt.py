"""
Decompiled / Reconstructed Module: core.labs_api.wire.prompt
Source PyC: prompt.pyc

Docstring:
core/labs_api/wire/prompt.py — prompt sanitization before API wire.

Strips internal entity IDs (CHAR/OBJ/SET/BG) that exist for mapping/retry/regen
but must NOT reach the Google/VEO payload. Only called at the final API boundary.
Ported verbatim from core/api_client._strip_prompt_for_wire (1327).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def strip_for_wire(prompt: 'str', *, context: 'str' = 'API') -> 'str':
    pass
