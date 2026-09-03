"""
Decompiled / Reconstructed Module: core.gemini_web.errors
Source PyC: errors.pyc

Docstring:
Errors for Gemini Web free path.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Class: GeminiWebError ---
class GeminiWebError(Exception):
    def __init__(self, message: 'str', *, category: 'str' = 'error', status: 'int' = 0):
        pass


# --- Class: GeminiWebAuthError ---
class GeminiWebAuthError(GeminiWebError):
    def __init__(self, message: 'str' = 'auth expired'):
        pass


# --- Class: GeminiWebQuotaError ---
class GeminiWebQuotaError(GeminiWebError):
    def __init__(self, message: 'str' = 'quota exhausted'):
        pass

