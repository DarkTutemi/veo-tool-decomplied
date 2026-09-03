"""
Decompiled / Reconstructed Module: utils.telemetry_sanitizer

Docstring:
Telemetry payload sanitizer for diagnostics uploads.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_TOKEN_PATTERNS = [re.compile('Bearer\\s+[A-Za-z0-9._\\-]+', re.IGNORECASE), re.compile('access_token\\s*[:=]\\s*[\'\\"][^\'\\"]+[\'\\"]', re.IGNORECASE), re.compile('refresh_token\\s*[:=]\\s*[\'\\"][^\'\\"]+[\'\\"]', ... [truncated]
_EMAIL_PATTERN = re.compile('\\b([A-Z0-9._%+-]{1,3})[A-Z0-9._%+-]*@([A-Z0-9.-]+\\.[A-Z]{2,})\\b', re.IGNORECASE)

# --- Top-Level Functions ---
def _sanitize_text(value: 'str') -> 'str':
    # [PyArmor BCC constants]: '_TOKEN_PATTERNS', 'sub', '[REDACTED]', '_EMAIL_PATTERN'
    pass

def sanitize_payload(data: 'Any') -> 'Any':
    # [PyArmor BCC constants]: 'token', 'cookie', 'authorization', 'password', 'secret'
    pass
