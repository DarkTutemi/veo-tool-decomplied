"""
Decompiled / Reconstructed Module: core.gemini_web.models
Source PyC: models.pyc

Docstring:
Model header helpers for Gemini Web StreamGenerate.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
MODEL_CATALOG = {'flash': {'model_id': '56fdd199312815e2', 'name': 'gemini-3-flash-plus', 'tail': 4}, 'flash_basic': {'model_id': 'fbb127bbb056c959', 'name': 'gemini-3-flash', 'tail': 1}, 'pro': {'model_id': 'e6fa609... [truncated]
MODEL_HEADER_KEY = 'x-goog-ext-525001261-jspb'

# --- Top-Level Functions ---
def build_model_header(model_id: 'str', capacity_tail: 'int | str' = 4) -> 'dict[str, str]':
    pass

def resolve_model_headers(model: 'str' = 'flash') -> 'dict[str, str]':
    """Map friendly name → request headers. Unknown → empty (server default)."""
    pass

def list_models() -> 'list[dict[str, Any]]':
    pass

def model_display_name(model: 'str' = 'flash') -> 'str':
    pass
