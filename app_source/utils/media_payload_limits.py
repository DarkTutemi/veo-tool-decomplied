"""
Decompiled / Reconstructed Module: utils.media_payload_limits

Docstring:
Shared guardrails for media routes that necessarily duplicate payloads.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
DEFAULT_MAX_INLINE_MEDIA_BYTES = 20971520

# --- Class: InlineMediaTooLargeError ---
class InlineMediaTooLargeError(ValueError):
    """Raised before a browser/base64 route can multiply a large media file."""
    pass


# --- Top-Level Functions ---
def max_inline_media_bytes() -> 'int':
    # [PyArmor BCC constants]: 'os', 'getenv', 'VEOFLOW_MAX_INLINE_MEDIA_MB', '20', 'max', 1, 'int', 20, 'TypeError', 'ValueError', 1024
    pass

def ensure_inline_path_allowed(path: 'str', *, route: 'str') -> 'int':
    # [PyArmor BCC constants]: 'os', 'path', 'getsize', 'max_inline_media_bytes', 'InlineMediaTooLargeError', ' chỉ dành cho media nhỏ: ', 1000000, '.1f', 'MB > ', '.0f', 'MB. Hãy dùng upload streaming/file URI.'
    pass

def ensure_inline_base64_allowed(encoded: 'str | bytes', *, route: 'str') -> 'int':
    # [PyArmor BCC constants]: 'estimated_base64_bytes', 'max_inline_media_bytes', 'InlineMediaTooLargeError', ' từ chối base64 khoảng ', 1000000, '.1f', 'MB > ', '.0f', 'MB. Hãy truyền file path/file URI.'
    pass

def ensure_inline_bytes_allowed(size: 'int', *, route: 'str') -> 'int':
    # [PyArmor BCC constants]: 'max_inline_media_bytes', 'int', 'InlineMediaTooLargeError', ' từ chối payload ', 1000000, '.1f', 'MB > ', '.0f', 'MB. Hãy dùng upload streaming/file URI.'
    pass
