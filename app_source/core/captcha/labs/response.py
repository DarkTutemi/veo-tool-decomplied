"""
Decompiled / Reconstructed Module: core.captcha.labs.response
Source PyC: response.pyc

Docstring:
Response classification helpers for browser-side Google Labs fetch results.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def classify_api_result(result: 'dict[str, Any] | None') -> 'str':
    """Return the shared error_category for a browser-side API result."""
    pass

def ensure_error_category(result: 'dict[str, Any] | None') -> 'dict[str, Any] | None':
    pass
